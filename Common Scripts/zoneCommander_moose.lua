if Era == 'Gulfwar' then Era = 'Coldwar' end
PATH_CACHE=PATH_CACHE or{}
Respawn = {}
farpBuiltByConvoy={}
ActiveCurrentMission = ActiveCurrentMission or {}
_awacsRepositionSched = nil
local escortFarpToZone={}

local zoneByName = nil
local function buildZoneByName()
    zoneByName = {}
    for _, z in ipairs(env.mission.triggers.zones or {}) do
        zoneByName[z.name] = z
    end
end

LandingSpots = {}

--[[ for n,_ in pairs(LandingSpots) do
     env.info("[LZ] stored key: "..n)
end ]]

function PrecomputeLandingSpots(maxPerZone, attemptsPerZone, maxSlopeDeg)
    maxPerZone = maxPerZone or 5
    attemptsPerZone = attemptsPerZone or 300
    maxSlopeDeg = maxSlopeDeg or 15

    for _, z in ipairs(env.mission.triggers.zones or {}) do
        local zname = z.name
        local lname = zname:lower()
		if lname:sub(-5) == "-land" or lname:match("%-land%-%d+$") then
            local spots = {}
            local allowed = { [land.SurfaceType.LAND]=true, [land.SurfaceType.ROAD]=true }
            for _=1,attemptsPerZone do
                local coord = GetValidCords(zname, allowed, 1)
                if coord then
                    local v = coord:GetVec3()
                    if Utils.getTerrainSlopeAtPoint({x=v.x,z=v.z},20) <= maxSlopeDeg then
                        table.insert(spots, {x=v.x, z=v.z})
                        if #spots >= maxPerZone then break end
                    end
                end
            end
            if #spots > 0 then
                LandingSpots[zname] = spots
            else
                trigger.action.outText(string.format("[LZ] Zone %s has no valid landing spots", zname), 10)
                env.info(string.format("[LZ] Zone %s has no valid landing spots", zname))
            end
        end
    end
end

function getEscortFarpZoneOfUnit(unitName)
    local grp = GROUP:FindByName(unitName)
    if not grp or not grp:IsAlive() then
        local u = UNIT:FindByName(unitName)
        if not u then return nil end
        grp = u:GetGroup()
    end
    if not grp or not supplyZones then return nil end
    for _, zName in ipairs(supplyZones) do
        if string.find(zName, "Escort Mission FARP") then
            local zObj = ZONE:FindByName(zName)
            if zObj and grp:IsInZone(zObj) then
                return {zone = (escortFarpToZone and escortFarpToZone[zName]) or zName,
                    side = grp:GetCoalition()}
            end
        end
    end
end

local function DeepCopy(o, s)
  if type(o)~="table" then return o end
  if s and s[o] then return s[o] end
  local t, s = {}, s or {} ; s[o] = t
  for k,v in pairs(o) do t[DeepCopy(k,s)] = DeepCopy(v,s) end
  return setmetatable(t,getmetatable(o))
end

local gid, uid = 7000, 90000
local function freshIds(t)
  t.groupId = gid ;  gid = gid + 1
  for _,u in ipairs(t.units) do
    u.unitId = uid ; uid = uid + 1
  end
end

local function FixSelfTasks(route, newGrpId, newUnitId)
  if not route or not route.points then return end
  for _,pt in ipairs(route.points) do
    local tasks = (((pt.task or {}).params) or {}).tasks
    if tasks then
      for _,tk in ipairs(tasks) do
        local act = (tk.params or {}).action
        if act and act.id == "EPLRS"          then act.params.groupId = newGrpId end
        if act and act.id == "ActivateBeacon" then act.params.unitId  = newUnitId end
        if act and act.id == "ActivateICLS"   then act.params.unitId  = newUnitId end
      end
    end
  end
end

local CAT={plane="AIRPLANE",helicopter="HELICOPTER",vehicle="GROUND",ship="SHIP",static="STATIC"}


local groupTemplateCache = nil

local function buildTemplateCache()
  groupTemplateCache = {}
  for coaName, coa in pairs(env.mission.coalition) do
    if type(coa)=="table" and coa.country then
      for _,country in pairs(coa.country) do
        for cat,catTbl in pairs(country) do
          if type(catTbl)=="table" and catTbl.group then
            for _,g in ipairs(catTbl.group) do
              local t       = DeepCopy(g)
              t.category    = cat
              t.countryId   = country.id
              t.coaSideEnum = coalition.side[string.upper(coaName)]
              groupTemplateCache[g.name] = t
            end
          end
        end
      end
    end
  end
end

local function FetchMETemplate(name)
  if not groupTemplateCache then
    buildTemplateCache()
  end
  local tpl = groupTemplateCache[name]
  if tpl then
    return DeepCopy(tpl)
  end
  return nil
end

function Respawn.Group(groupName, uncontrolled)
  local live = Group.getByName(groupName)
  if live and live:isExist() then live:destroy() end

  local tpl = FetchMETemplate(groupName)
  if not tpl then env.error("Respawn: ME template '"..groupName.."' not found") return end

  freshIds(tpl)
  tpl.lateActivation = false

  if uncontrolled and (tpl.category=="plane" or tpl.category=="helicopter") then
    tpl.uncontrolled = true
    local wp1 = tpl.route and tpl.route.points and tpl.route.points[1]
    if wp1 then
      wp1.type   = "TakeOffParking"
      wp1.action = "From Parking Area"
    end
  end

  FixSelfTasks(tpl.route, tpl.groupId, tpl.units[1].unitId)

  local ok, newGrp = pcall(coalition.addGroup, tpl.countryId, Group.Category[CAT[tpl.category] or "GROUND"], tpl)
  if not ok then env.error("Respawn: addGroup failed - "..tostring(newGrp)) end
  return newGrp
end

function Respawn.SpawnAtPoint(grpName, coord, headingDeg, distNm, alt, spd)
  local tpl = FetchMETemplate(grpName); if not tpl then return end
  
  local ALT = alt and UTILS.FeetToMeters(alt) or tpl.units[1].alt or UTILS.FeetToMeters(25000)

  local cx, cz = coord.x, coord.z
  if coord.GetVec3 then local v = coord:GetVec3(); cx,cz = v.x, v.z end
  local function toRad(deg) if deg<=180 then return math.rad(deg) else return -math.rad(360-deg) end end
  local h = toRad(headingDeg or 0)
  local psi = -h
  local c, s = math.cos(h), math.sin(h)
  local refX, refZ = tpl.units[1].x, tpl.units[1].y
  for _,u in ipairs(tpl.units) do
    local dx, dz = u.x-refX, u.y-refZ
    u.x = cx + dx*c - dz*s
    u.y = cz + dx*s + dz*c
    u.heading = h
    u.psi = psi
    u.alt = ALT
  end
  local d = (distNm or 5)*1852
  local wpX = cx + d*math.cos(h)
  local wpZ = cz + d*math.sin(h)
  if not tpl.route then tpl.route = {points={}} end
  if not tpl.route.points then tpl.route.points = {} end
  tpl.route.points[1] = {type="Turning Point",action="Turning Point",x=tpl.units[1].x,y=tpl.units[1].y,alt=ALT,alt_type="BARO",speed=spd or tpl.units[1].speed or 380,psi=psi,task={id="ComboTask",params={tasks={}}}}
  tpl.route.points[2] = {type="Turning Point",action="Turning Point",x=wpX,y=wpZ,alt=ALT,alt_type="BARO",speed=spd or tpl.route.points[1].speed,psi=psi,task={id="ComboTask",params={tasks={}}}}
  freshIds(tpl)
  tpl.lateActivation = false
  FixSelfTasks(tpl.route, tpl.groupId, tpl.units[1].unitId)
  local ok,newGrp = pcall(coalition.addGroup,tpl.countryId,Group.Category[CAT[tpl.category] or "GROUND"],tpl)
  if not ok then env.error("Respawn: addGroup failed - "..tostring(newGrp)) return nil end
  return newGrp
end


local subZoneCache = {}

local function collectSubZones(baseName)
    if subZoneCache[baseName] then return subZoneCache[baseName] end
    local zones = {}
    for i = 1, 100, 1 do
        local zname = baseName .. '-' .. i
        if trigger.misc.getZone(zname) then
            zones[#zones + 1] = zname
        else
            break
        end
    end
    subZoneCache[baseName] = zones
    return zones
end

local zoneCenterCache = {}
	local function getZoneCenter(name)
		if zoneCenterCache[name] then return zoneCenterCache[name] end
		local z = trigger.misc.getZone(name)
		if not z or not z.point then return nil end
		local c = { x = z.point.x, y = z.point.z or z.point.y or 0 }
		zoneCenterCache[name] = c
		return c
	end

CustomZone = {}
do
        function CustomZone:getByName(name)
                obj = {}
                obj.name = name
                if not zoneByName then buildZoneByName() end
                local zd = zoneByName[name]
                if not zd then return nil end

                obj.type = zd.type -- 2 == quad, 0 == circle
                if obj.type == 2 then
                        obj.vertices = {}
                        for _,v in ipairs(zd.verticies) do
				local vertex = {
					x = v.x,
					y = 0,
					z = v.y
				}
				table.insert(obj.vertices, vertex)
			end
		end
		
		obj.radius = zd.radius
		obj.point = {
			x = zd.x,
			y = 0,
			z = zd.y
		}
		
		setmetatable(obj, self)
		self.__index = self
		return obj
	end
	
	function CustomZone:isQuad()
		return self.type==2
	end
	
	function CustomZone:isCircle()
		return self.type==0
	end
	
	function CustomZone:isInside(point)
		if self:isCircle() then
			local dist=UTILS.VecDist2D({x=point.x,y=point.z},{x=self.point.x,y=self.point.z})
			return dist<self.radius
		elseif self:isQuad() then
			return UTILS.IsPointInPolygon({x=point.x,y=point.z},self.vertices)
		end
	end
	
	function CustomZone:getZoneBuildings()
		buildingCache                 = buildingCache or {}
		if buildingCache[self.name] then return buildingCache[self.name] end

		local pts, vol = {}, nil
		if self:isCircle() then
			vol = { id = world.VolumeType.SPHERE,
					params = { point = self.point, radius = self.radius } }
		else
			local r = 0
			for _,v in ipairs(self.vertices) do
				local d = UTILS.VecDist2D({x = v.x, y = v.z},
										{x = self.point.x, y = self.point.z})
				if d > r then r = d end
			end
			vol = { id = world.VolumeType.SPHERE,
					params = { point = self.point, radius = r } }
		end

		world.searchObjects(Object.Category.SCENERY, vol, function(o)
			if o then
				local d = o:getDesc()
				if d and d.attributes and d.attributes.Buildings then
					local p = o:getPoint()
					if self:isInside(p) then pts[#pts + 1] = p end
				end
			end
		end)

		buildingCache[self.name] = pts
		return pts
	end

	function CustomZone:draw(id, border, background)

		if not self.name:lower():find("hidden") then
			if self:isCircle() then
				trigger.action.circleToAll(-1, id, self.point, self.radius, border, background, 1)
			elseif self:isQuad() then
				trigger.action.quadToAll(-1, id, self.vertices[4], self.vertices[3], self.vertices[2], self.vertices[1], border, background, 1)
			end
		else
			env.info("Zone [" .. self.name .. "] is marked as hidden and will not be drawn.")
		end
	end

function GetValidCords(zoneName, allowed, attempts)
	local zone = ZONE:FindByName(zoneName); if not zone then return nil end
	attempts = attempts or 100
	for _=1,attempts do
		local coord = zone:GetRandomCoordinate()
		if coord then
			local st = coord:GetSurfaceType()
			if st ~= land.SurfaceType.RUNWAY and (not allowed or allowed[st]) then return coord end
		end
	end
	return nil
end

	function CustomZone:getRandomSpawnZone()
		local spawnZones = collectSubZones(self.name)
		if #spawnZones == 0 then return nil end
		local choice = math.random(1, #spawnZones)
		return spawnZones[choice]
	end

	function SpawnCustom(grname, zoneName)
	spawnCounter[grname] = (spawnCounter[grname] or 0) + 1
	local alias = string.format("%s # %d", grname, spawnCounter[grname])

	local grp = GROUP:FindByName(grname)
	local tpl = grp and grp:GetTemplate()
	if grp then grp:Destroy() end
	if not tpl then return nil end

	local isCarrierZone = zoneName and zoneName:lower():find("carrier")
	local gr

	if zoneName then
		local allowed = isCarrierZone and {
		[land.SurfaceType.WATER] = true,
		[land.SurfaceType.SHALLOW_WATER] = true
		} or {
		[land.SurfaceType.LAND] = true,
		[land.SurfaceType.ROAD] = true
		}

		local spawn = SPAWN:NewFromTemplate(tpl, grname, alias, true):InitSkill("Excellent")
		if (not grname:find("Red SAM") or grname:find("Dog Ear")) and not grname:find("bluePD") and not grname:find("blueHAWK") and not grname:find("bluePATRIOT") then
		spawn = isCarrierZone and spawn:InitRandomizeUnits(true, 1500, 1000) or spawn:InitRandomizeUnits(true, 100, 30):InitHeading(1, 359)
		end
		if grname:find("Red SAM") then
		spawn = spawn:InitHiddenOnMFD()
		end
		local tries = 0
		while tries < 10 and not gr do
			local coord = zoneName and GetValidCords(zoneName, allowed)
			if coord then
			gr = spawn:SpawnFromCoordinate(coord)
			end
			tries = tries + 1
		end
		return gr
		end
	end


	USED_SUB_ZONES = USED_SUB_ZONES or {}

	function CustomZone:getRandomUnusedSpawnZone(markUsed)
		if markUsed == nil then markUsed = true end
		self.usedSpawnZones = self.usedSpawnZones or {}
		local all = collectSubZones(self.name)
		local unused = {}
		for _, zname in ipairs(all) do
			if not self.usedSpawnZones[zname] and not USED_SUB_ZONES[zname] then
				unused[#unused + 1] = zname
			end
		end
		if #unused == 0 then
			self.usedSpawnZones = {}
			return nil
		end
		local pool = (#unused > 0) and unused or all
		local selected = pool[math.random(1, #pool)]
		if markUsed then
			self.usedSpawnZones[selected] = true
			USED_SUB_ZONES[selected]      = true
		end
		return selected
	end
	
	spawnCounter = spawnCounter or {}



	function CustomZone:spawnGroup(grname, forceFirst)
	if not grname or type(grname)~="string" then
		trigger.action.outText("Error: grname is nil or not a valid string",5)
		return nil
	end

	if grname:find("Fixed") then
		local grp = GROUP:FindByName(grname)
		if not grp then trigger.action.outText(grname.." not found, Report it to leka and what map", 60) end
		local tpl = grp and grp:GetTemplate() or UTILS.DeepCopy(_DATABASE.Templates.Groups[grname].Template)
		if grp and grp:IsAlive() then grp:Destroy() end
		local g   = SPAWN:NewFromTemplate(tpl,grname,nil,true):InitHiddenOnMFD():Spawn()
		return g and { name = g:GetName() } or trigger.action.outText("Failed to spawn group: "..grname,10)
	end

	local all    = collectSubZones(self.name)
	local unused = {}
	for _, z in ipairs(all) do
			if not (self.usedSpawnZones and self.usedSpawnZones[z]) and not USED_SUB_ZONES[z] then
					unused[#unused + 1] = z
			end
	end
	local zonePool = (#unused > 0) and unused or all
	if #zonePool==0 then zonePool[#zonePool+1]=self.name end

	while #zonePool>0 do
		local idx       = math.random(#zonePool)
		local spawnzone = table.remove(zonePool, idx)
		local g         = SpawnCustom(grname, spawnzone)
		if g then
		self.usedSpawnZones            = self.usedSpawnZones or {}
		self.usedSpawnZones[spawnzone] = true
		USED_SUB_ZONES[spawnzone]      = true
		return { name = g:GetName() }
		end
	end

	trigger.action.outText("Failed to spawn group: "..grname,5)
	env.info("Failed to spawn group: "..grname)
	return nil
	end

	function CustomZone:clearUsedSpawnZones(zone)
		local prefix = zone or self.name
		for z,_ in pairs(USED_SUB_ZONES) do
			if z:sub(1,#prefix+1) == prefix.."-" then
				USED_SUB_ZONES[z] = nil
			end
		end
	end
end


local formations = {
    65537,   -- Line Abreast Close
    131073,  -- Trail Close
    196609,  -- Wedge Close
    262145,  -- Echelon Right Close
    327681,  -- Echelon Left Close
    393217,  -- Finger Four Close
    458753,  -- Spread Close
    786433,  -- Bomber Element Close
    851968,  -- Bomber Element Height Close
    917505,  -- Fighter Vic Close
    65538,   -- Line Abreast Open
    131074,  -- Trail Open
    196610,  -- Wedge Open
    262146,  -- Echelon Right Open
    327682,  -- Echelon Left Open
    393218,  -- Finger Four Open
    458754,  -- Spread Open
    786434,  -- Bomber Element Open
    917506,  -- Fighter Vic Open
    65539,   -- Line Abreast Group Close
    131075,  -- Trail Group Close
    196611,  -- Wedge Group Close
    262147,  -- Echelon Right Group Close
    327683,  -- Echelon Left Group Close
    393219,  -- Finger Four Group Close
    458755,  -- Spread Group Close
    786435,  -- Bomber Element Group Close
}

	local function vecmag(vec)
		return (vec.x^2 + vec.y^2 + vec.z^2)^0.5
	end

	local function getGroupSpeed(group)
		if group then
			local units = group:getUnits()
			if units and #units > 0 then
				local s = 0
				local ms = 1000
				local u = 0
				for u, uData in pairs(units) do
					u = u + 1
					local us = vecmag(uData:getVelocity())
					if us and us >= 0 then
						s = s + us
						if us < ms then
							ms = us
						end
					end
				end
				return s, ms
			else
				return nil
			end
		else
			return nil
		end
	end
	

Utils = {}
do

	function Utils.getTerrainSlopeAtPoint(p1, radius)
		radius = radius or 10
		local offsets = {
			{x= radius, z= 0}, {x=-radius, z= 0},
			{x= 0, z= radius}, {x= 0, z=-radius},
			{x= radius, z= radius}, {x= radius, z=-radius},
			{x=-radius, z= radius}, {x=-radius, z=-radius}
		}
		local alt1 = land.getHeight({x=p1.x,y=0,z=p1.z})
		local slopes = {}
		for i=1,#offsets do
			local off = offsets[i]
			local alt2 = land.getHeight({x=p1.x+off.x,y=0,z=p1.z+off.z})
			local dz = alt2 - alt1
			local dxz = math.sqrt(off.x*off.x + off.z*off.z)
			if dxz > 0 then
				local slope = math.deg(math.atan2(dz, dxz))
				if slope < 0 then slope = -slope end
				slopes[#slopes+1] = slope
			end
		end
		table.sort(slopes)
		if #slopes == 0 then return 0 end
		return slopes[math.floor(#slopes/2)+1]
	end

		function Utils.getRandomFormation()
    return formations[math.random(1, #formations)]
	end

	function Utils.getPointOnSurface(point)
		return {x = point.x, y = land.getHeight({x = point.x, y = point.z}), z= point.z}
	end
	
	function Utils.getTableSize(tbl)
		local cnt = 0
		for i,v in pairs(tbl) do cnt=cnt+1 end
		return cnt
	end
	
	function Utils.getBearing(fromvec, tovec)
		local fx = fromvec.x
		local fy = fromvec.z
		
		local tx = tovec.x
		local ty = tovec.z
		
		local brg = math.atan2(ty - fy, tx - fx)
		if brg < 0 then
			 brg = brg + 2 * math.pi
		end
		
		brg = brg * 180 / math.pi
		return brg
	end
	
	function Utils.getAGL(object)
		local pt = object:getPoint()
		return pt.y - land.getHeight({ x = pt.x, y = pt.z })
	end
	
	function Utils.isLanded(unit, ignorespeed)
		if not unit then return false end
		local airborne=(unit.inAir and unit:inAir()) or (unit.InAir and unit:InAir()) or false
		if ignorespeed then
			return not airborne
		else
			local v=unit:getVelocity()
			local kmh=math.sqrt(v.x*v.x+v.y*v.y+v.z*v.z)*3.6
			return (not airborne) and kmh<4
		end
	end
	
	function IsGroupActive(groupName)
		local group = GROUP:FindByName(groupName)
		if group then
			return group:IsAlive()
		else
			return false
		end
	end

	function activateGroupIfNotActive(groupName)
		if not IsGroupActive(groupName) then
			local group = Group.getByName(groupName)
			if group then
				group:activate()
			else
				return false
			end
		end
	end
	function destroyGroupIfActive(groupName)
		if IsGroupActive(groupName) then
			local group = Group.getByName(groupName)
			if group then
				group:destroy()
			else
				return false
			end
		end
	end
	function SpawnGroupIfNotActive(groupName)
		if not IsGroupActive(groupName) then
			Respawn.Group(groupName)
		end
	end
	
	zoneIntels = zoneIntels or {} intelExpireTimes = intelExpireTimes or {}

	function startZoneIntel(zoneName)
		if zoneIntels[zoneName] then return end
		local intel = INTEL:New(SET_GROUP:New(), "blue", "intel_" .. zoneName)
		intel:SetDetectStatics(true)
		intel:SetClusterAnalysis(false, true)
		function intel:OnAfterNewContact(_, _, _, c) c.marker = MARKER:New(c.position, c.groupname):ToCoalition(self.coalition) end
		function intel:onafterLostContact(_, _, _, c) if c.marker then c.marker:Remove() end end
		intel:__Start(0)
		zoneIntels[zoneName] = intel
		intelExpireTimes[zoneName] = timer.getTime() + 3600
		local z = bc:getZoneByName(zoneName); z:updateLabel()
		for _, gName in pairs(z.built) do
			local obj = GROUP:FindByName(gName) or STATIC:FindByName(gName)
			if obj then intel:KnowObject(obj, zoneName) end
		end
		timer.scheduleFunction(function(a)
			local n = a[1]
			local i = zoneIntels[n]
			if i then
				for _, c in pairs(i.Contacts) do if c.marker then c.marker:Remove() end end
				i:Stop()
				zoneIntels[n] = nil
				intelExpireTimes[n] = nil
				bc:buildZoneStatusMenuForGroup()
				local z = bc:getZoneByName(n) if z and z.updateLabel then z:updateLabel() end
			end
		end, { zoneName }, intelExpireTimes[zoneName])
	end
	
	function GetNearestCarrierName(coord)
		if not coord then return nil end
		local nearest=nil local number=math.huge
		for _,name in ipairs({"CVN-73","CVN-72","CVN-59","CVN-74"}) do
			if IsGroupActive(name) then
				local unit=UNIT:FindByName(name)
				if unit then
					local distance=coord:Get2DDistance(unit:GetCoordinate())
					if distance<number then number=distance nearest=name end
				end
			end
		end
		if number<200 then return nearest end
	end

	function Utils.allGroupIsLanded(group, ignorespeed)
		for _,unit in ipairs(group:getUnits()) do
			if not Utils.isLanded(unit, ignorespeed) then return false end
		end
		return true
	end

	Group.getByNameBase = Group.getByName

	function Utils.isGroupActive(group)
		if not group or group:getSize()==0 then return false end
		local c=group:getController()
		if c and (not c.hasTask or c:hasTask()) then
			return not Utils.allGroupIsLanded(group,true)
		end
		return false
	end
	
	function Utils.isInAir(unit)
	if not unit then return false end
	if unit.InAir then
		return unit:InAir()
	else
		return unit:inAir()
	end
	end
	
	function Utils.isInZone(unit, zonename)
		local zn = CustomZone:getByName(zonename)
		if zn then
			return zn:isInside(unit:getPosition().p)
		end
		
		return false
	end
	
	function Utils.isCrateSettledInZone(crate, zonename)
		local zn = CustomZone:getByName(zonename)
		if zn and crate then
			return (zn:isInside(crate:getPosition().p) and Utils.getAGL(crate)<1)
		end
		
		return false
	end
	
	function Utils.someOfGroupInZone(group, zonename)
		for i,v in pairs(group:getUnits()) do
			if Utils.isInZone(v, zonename) then
				return true
			end
		end
		
		return false
	end
	
	function Utils.allGroupIsLanded(group, ignorespeed)
		for i,v in pairs(group:getUnits()) do
			if not Utils.isLanded(v, ignorespeed) then
				return false
			end
		end
		
		return true
	end
	
	function Utils.someOfGroupInAir(group)
		for i,v in pairs(group:getUnits()) do
			if Utils.isInAir(v) then
				return true
			end
		end
		
		return false
	end
	
	Utils.canAccessFS = true
	function Utils.saveTable(filename, variablename, data)
		if not Utils.canAccessFS then 
			return
		end
		
		if not io then
			Utils.canAccessFS = false
			trigger.action.outText('Persistance disabled, Save file can not be created', 600)
			return
		end
	
		local str = variablename..' = {}'
		for i,v in pairs(data) do
			str = str..'\n'..variablename..'[\''..i..'\'] = '..Utils.serializeValue(v)
		end
	
		File = io.open(filename, "w")
		File:write(str)
		File:close()
	end
	
	function Utils.serializeValue(value)
		local res = ''
		if type(value)=='number' or type(value)=='boolean' then
			res = res..tostring(value)
		elseif type(value)=='string' then
			res = res..'\''..value..'\''
		elseif type(value)=='table' then
			res = res..'{ '
			for i,v in pairs(value) do
				if type(i)=='number' then
					res = res..'['..i..']='..Utils.serializeValue(v)..','
				else
					res = res..'[\''..i..'\']='..Utils.serializeValue(v)..','
				end
			end
			res = res:sub(1,-2)
			res = res..' }'
		end
		return res
	end
	
	function Utils.loadTable(filename)
		if not Utils.canAccessFS then 
			return
		end
		
		if not lfs then
			Utils.canAccessFS = false
			trigger.action.outText('Persistance disabled, Save file can not be created\n\nDe-Sanitize DCS missionscripting.lua', 600)
			return
		end
		
		if lfs.attributes(filename) then
			dofile(filename)
		end
	end
end

	function Utils.log(func)
		return function(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
			local err, msg = pcall(func,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
			if not err then
				env.info("ERROR - callFunc\n"..msg)
				env.info('Traceback\n'..debug.traceback())
			end
		end
	end


	local renameMap = {
			["ZU%-23 Emplacement"] = "ZU-23 Emplacement",
			["BTR_D"]              = "BTR-D",
			["Shilka"]             = "Shilka",
			["4320T"]              = "Ural Truck",
			["GAZ%-66"]            = "GAZ Truck",
			["BTR%-82A"]           = "BTR 82A",
			["BMP%-3"]             = "BMP 3",
			["ZSU_57_2"]           = "ZSU 58",
			["generator_5i57"]     = "SA-10 Generator",
			["tt_ZU%-23"]          = "ZU-23",
			["SON_9"]              = "SON-9 Fire Control Radar",
			["HL_ZU%-23"]          = "HL ZU-23",
			["tt_DSHK"]            = "DSHK Technical",
			["HL_KORD"]            = "HL Technical",
			["HL_DSHK"]            = "HL Technical",
			["tt_KORD"]            = "KORD Technical",
			["APA%-80"]            = "Zil-131",
			["_Phalanx"]           = "C-RAM",
			["TorM2"]              = "SA-15 M2",
			["9A331"]              = "SA-15",
			["Pantsir"]            = "Pantsir S1",
			["Osa"]                = "SA-8",
			["manpad"]             = "MANPAD",
			["Tunguska"]           = "SA-19",
			["Kub 1S91 str"]       = "SA-6 STR",
			["Kub 2P25 ln"]        = "SA-6 LN",
			["snr s%-125 tr"]      = "SA-3 TR",
			["40B6M tr"]           = "SA-10 TR",
			["RPC_5N62V"]          = "SA-5 TR",
			["RLS_19J6"]           = "SA-5 SR",
			["S%-200_Launcher"]    = "SA-5 LN",
			["SA%-11 Buk LN"]      = "SA-11 LN",
			["9S18M1"]             = "SA-11 SnowDrift SR",
			["9S4770M1"]           = "SA-11 Command Center",
			["S%-60_Type59"]       = "60 mm AA Gun",
			["CHAP_FV101"]         = "Scorpion FV101",
			["CHAP_FV107"]         = "Scimitar FV107",
			["CHAP_M1130"]         = "Stryker CV",
			["KS%-19"]             = "100 mm AA Gun",
			["p%-19 s%-125 s"]     = "P19 SAM SR",
			["64H6E sr"]           = "SA-10 SR 64H6E",
			["40B6MD sr"]          = "SA-10 SR 40B6MD",
			["5P85C"]              = "SA-10 LN",
			["5P85D"]              = "SA-10 LN",
			["54K6"]               = "SA-10 CP",
			["5p73"]               = "SA-3 LN",
			["SNR_75V"]            = "SA-2 TR",
			["Volhov"]             = "SA-2 LN",
			["Merkava"]            = "Merkava Tank",
			["T%-72"]              = "MBT T-72",
			["T%-90"]              = "MBT T-90",
			["CHAP_T84"]           = "MBT T-84",
			["CHAP_BMPT"]          = "BMPT Terminator",
	}

	function renameType(tgttype)
			if not tgttype then return "Unknown" end
			for pattern, name in pairs(renameMap) do
					if string.find(tgttype, pattern) then
							return name
					end
			end
			return tgttype
	end


JTAC = {}
do	
	jtacQueue = jtacQueue or {}
	JTAC.categories = {}
	JTAC.categories['SAM'] = {'SAM SR', 'SAM TR', 'IR Guided SAM'}
	if UseStatics then
	JTAC.categories['Structures'] = {'StaticObjects'}
	end
	JTAC.categories['Infantry'] = {'Infantry'}
	JTAC.categories['Armor'] = {'Tanks','IFV','APC'}
	JTAC.categories['Support'] = {'Unarmed vehicles','Artillery','SAM LL','SAM CC'}
	
	
	--{name = 'groupname'}
	function JTAC:new(obj)
		obj = obj or {}
		obj.lasers = {tgt=nil, ir=nil}
		obj.target = nil
		obj.timerReference = nil
		obj.tgtzone = nil
		obj.priority = nil
		obj.jtacMenu = nil
		obj.laserCode = 1688
		obj._holdUntil = 0
		obj.randomNext = nil
		obj.side = Group.getByName(obj.name):getCoalition()
		obj.smokeColor = obj.smokeColor or 3
		setmetatable(obj, self)
		self.__index = self
		obj:initCodeListener()
		return obj
	end
	
	JTAC.smokeColors = { [0] = 'GREEN', [1] = 'RED', [2] = 'WHITE', [3] = 'ORANGE', [4] = 'BLUE' }

	function JTAC:initCodeListener()
		local ev = {}
		ev.context = self
		function ev:onEvent(event)
			if event.id == 26 then
				if event.text:find('^jtac%-code:') then
					local s = event.text:gsub('^jtac%-code:', '')
					local code = tonumber(s)
					self.context:setCode(code)
                    trigger.action.removeMark(event.idx)
				end
			end
		end

		world.addEventHandler(ev)
	end
	
	function JTAC:sortByThreat(targets)
		local threatRank = {
			['SAM TR']          = 1,
			['IR Guided SAM']   = 2,
			['SAM SR']          = 3,
			['AAA']          	= 4,
			['Tanks']           = 5,
			['IFV']             = 6,
			['APC']             = 7,
			['Artillery']       = 8,
			['SAM LL']          = 9,
			['SAM CC']          = 10,
			['Unarmed vehicles']= 11,
			['Infantry']        = 12,
			['Structures']   	= 13
		}

        local function getScore(u)
            local best = 999
            local hasAAA = u:hasAttribute('AAA')
            for attr, rank in pairs(threatRank) do
                if u:hasAttribute(attr) and rank < best then
                    best = rank
                end
            end
            if hasAAA and (u:hasAttribute('SAM TR') or u:hasAttribute('SAM SR')) then
                best = best + 0.1          -- guns lose to missiles at same rank
            end
            return best
        end

		table.sort(targets, function(a,b) return getScore(a) < getScore(b) end)
		return targets
	end

	function JTAC:setCode(code)
        if code>=1111 and code <= 1788 then
            self.laserCode = code
            trigger.action.outTextForCoalition(self.side,'JTAC code set to '..code..' at '..self.tgtzone.zone,15)
        else
            trigger.action.outTextForCoalition(self.side, 'Invalid laser code. Must be between 1111 and 1788 ', 10)
        end
    end
	
	function JTAC:showMenu()
		local gr = Group.getByName(self.name)
		if not gr then
			return
		end
		
		if self.jtacMenu then
			missionCommands.removeItemForCoalition(self.side, self.jtacMenu)
			self.jtacMenu = nil
		end

		if not self.jtacMenu then
			self.jtacMenu = missionCommands.addSubMenuForCoalition(self.side, self.tgtzone.zone .. ' JTAC')
			
			missionCommands.addCommandForCoalition(self.side, 'Target report', self.jtacMenu, function(dr)
				if Group.getByName(dr.name) then
					dr:printTarget(true)
				else
					missionCommands.removeItemForCoalition(dr.side, dr.jtacMenu)
					dr.jtacMenu = nil
				end
			end, self)

			missionCommands.addCommandForCoalition(self.side,'Next Target',self.jtacMenu,function(dr)
				if Group.getByName(dr.name) then
					dr.randomNext=true
					dr:searchTarget()
				else
					missionCommands.removeItemForCoalition(dr.side,dr.jtacMenu)
					dr.jtacMenu=nil
				end
			end,self)
			
			missionCommands.addCommandForCoalition(self.side, 'Smoke on target', self.jtacMenu, function(dr)
				if Group.getByName(dr.name) then
					local tgtunit = Unit.getByName(dr.target)
					if not tgtunit then
						tgtunit = StaticObject.getByName(dr.target)
					end
					if tgtunit then
						local col = dr.smokeColor or 3
						trigger.action.smoke(tgtunit:getPoint(), col)
						trigger.action.outTextForCoalition(dr.side,'JTAC target marked with '..JTAC.smokeColors[col]..' smoke at '..dr.tgtzone.zone,15)
					end
				else
					missionCommands.removeItemForCoalition(dr.side, dr.jtacMenu)
					dr.jtacMenu = nil
				end
			end, self)

			self.smokeMenu = missionCommands.addSubMenuForCoalition(self.side, 'Change Smoke Color', self.jtacMenu)
			self._smokeCmds = self._smokeCmds or {}
			for i=0,4 do
				local label = JTAC.smokeColors[i] .. ((self.smokeColor == i) and ' (current)' or '')
				local h = missionCommands.addCommandForCoalition(self.side, label, self.smokeMenu, function(dr, c)
					dr.smokeColor = c
					trigger.action.outTextForCoalition(dr.side,'JTAC smoke color set to '..JTAC.smokeColors[c]..' at '..dr.tgtzone.zone,10)
					if dr._smokeCmds then
						for _,cmd in ipairs(dr._smokeCmds) do missionCommands.removeItemForCoalition(dr.side, cmd) end
					end
					dr._smokeCmds = {}
					for j=0,4 do
						local lbl = JTAC.smokeColors[j] .. ((dr.smokeColor == j) and ' (current)' or '')
						local h2 = missionCommands.addCommandForCoalition(dr.side, lbl, dr.smokeMenu, function(drr, cc)
							drr.smokeColor = cc
							trigger.action.outTextForCoalition(drr.side,'JTAC smoke color set to '..JTAC.smokeColors[cc]..' at '..drr.tgtzone.zone,10)
							if drr._smokeCmds then
								for _,cmd2 in ipairs(drr._smokeCmds) do missionCommands.removeItemForCoalition(drr.side, cmd2) end
							end
							drr._smokeCmds = {}
							for k=0,4 do
								local lbl2 = JTAC.smokeColors[k] .. ((drr.smokeColor == k) and ' (current)' or '')
								local h3 = missionCommands.addCommandForCoalition(drr.side, lbl2, drr.smokeMenu, Utils.log(function(ctx,col) ctx.smokeColor=col end), drr, k)
								table.insert(drr._smokeCmds, h3)
							end
						end, dr, j)
						table.insert(dr._smokeCmds, h2)
					end
				end, self, i)
				table.insert(self._smokeCmds, h)
			end

			local priomenu = missionCommands.addSubMenuForCoalition(self.side, 'Set Priority', self.jtacMenu)
			for i,v in pairs(JTAC.categories) do
				missionCommands.addCommandForCoalition(self.side, i, priomenu, function(dr, cat)
					if Group.getByName(dr.name) then
						dr:setPriority(cat)
						dr:searchTarget()
					else
						missionCommands.removeItemForCoalition(dr.side, dr.jtacMenu)
						dr.jtacMenu = nil
					end
				end, self, i)
			end

			missionCommands.addCommandForCoalition(self.side, "Clear", priomenu, function(dr)
				if Group.getByName(dr.name) then
					dr:clearPriority()
					dr:searchTarget()
				else
					missionCommands.removeItemForCoalition(dr.side, dr.jtacMenu)
					dr.jtacMenu = nil
				end
			end, self)
            local dial = missionCommands.addSubMenuForCoalition(self.side, 'Set Laser Code', self.jtacMenu)
            for i2=1,7,1 do
                local digit2 = missionCommands.addSubMenuForCoalition(self.side, '1'..i2..'__', dial)
                for i3=1,9,1 do
                    local digit3 = missionCommands.addSubMenuForCoalition(self.side, '1'..i2..i3..'_', digit2)
                    for i4=1,9,1 do
                        local digit4 = missionCommands.addSubMenuForCoalition(self.side, '1'..i2..i3..i4, digit3)
                        local code = tonumber('1'..i2..i3..i4)
                        missionCommands.addCommandForCoalition(self.side, 'Accept', digit4, Utils.log(self.setCode), self, code)
                    end
                end
            end
			self.selectTargetMenu = missionCommands.addSubMenuForCoalition(self.side, 'Select Target', self.jtacMenu)
		end
	end


	function JTAC:setPriority(prio)
		self.priority = JTAC.categories[prio]
		self.prioname = prio
	end
	
	function JTAC:clearPriority()
		self.priority = nil
	end
	
function JTAC:setTarget(unit)

	if self.lasers.tgt then
		self.lasers.tgt:destroy()
		self.lasers.tgt = nil
	end

	if self.lasers.ir then
		self.lasers.ir:destroy()
		self.lasers.ir = nil
	end

	local me = Group.getByName(self.name)
	if not me then return end


	local pnt = unit:getPoint()
	local adjustedPoint = { x = pnt.x, y = pnt.y + 1.0, z = pnt.z }
	self.lasers.tgt = Spot.createLaser(me:getUnit(1), { x = 0, y = 2.0, z = 0 }, pnt, self.laserCode)
	self.lasers.ir = Spot.createInfraRed(me:getUnit(1), { x = 0, y = 2.0, z = 0 }, pnt)
	self.target = unit:getName()
end



function JTAC:printTarget(makeitlast)
	local toprint=''
	if self.target and self.tgtzone then
		local tgtunit=Unit.getByName(self.target)
		local isStatic=false
		if not tgtunit then
			tgtunit=StaticObject.getByName(self.target)
			isStatic=true
		end
		if tgtunit then
			local pnt=tgtunit:getPoint()
			local tgttype=isStatic and tgtunit:getName() or renameType(tgtunit:getTypeName())
			if self.priority then toprint='Priority targets: '..self.prioname..'\n' end
			local movingLine=''
			if not isStatic then
				local vel=tgtunit:getVelocity()
				if vel then
					local spd=math.sqrt(vel.x^2+vel.z^2)
					if spd>1 then
						local hdg=UTILS.VecHdg(vel);if hdg<0 then hdg=hdg+360 end
						local dir
						if hdg>=337.5 or hdg<22.5 then dir='north bound'
						elseif hdg<67.5 then dir='north east bound'
						elseif hdg<112.5 then dir='east bound'
						elseif hdg<157.5 then dir='south east bound'
						elseif hdg<202.5 then dir='south bound'
						elseif hdg<247.5 then dir='south west bound'
						elseif hdg<292.5 then dir='west bound'
						else dir='north west bound' end
						movingLine='\nTarget is moving '..dir
					end
				end
			end
			toprint=toprint..'Lasing '..tgttype..' at '..self.tgtzone.zone..movingLine..'\nCode: '..self.laserCode..'\n'
			local lat,lon,alt=coord.LOtoLL(pnt)
			local c=COORDINATE:NewFromVec3(pnt)
			local function ddm(v,h)local d=math.floor(math.abs(v))local m=(math.abs(v)-d)*60 return string.format("[%s %02d %06.3f']",h,d,m)end
			local function dms(v,h)local a=math.abs(v)local d=math.floor(a)local m=math.floor((a-d)*60)local s=((a-d)*60-m)*60 return string.format("[%s %02d %02d' %05.2f\"]",h,d,m,s)end
			local ddmStr=ddm(lat,lat>=0 and 'N' or 'S')..'⇢ '..ddm(lon,lon>=0 and 'E' or 'W')
			local dmsStr=dms(lat,lat>=0 and 'N' or 'S')..'⇢ '..dms(lon,lon>=0 and 'E' or 'W')
			local mgrs=c:ToStringMGRS():gsub("^MGRS%s*","")
			toprint=toprint..'\nDDM:  '..ddmStr
			toprint=toprint..'\nDMS:  '..dmsStr
			toprint=toprint..'\nMGRS: '..mgrs
			toprint=toprint..'\n\nAlt: '..math.floor(alt)..'m | '..math.floor(alt*3.280839895)..'ft'
		else
			makeitlast=false
			toprint='No Target'
		end
	else
		makeitlast=false
		toprint='No target'
	end
	local gr=Group.getByName(self.name)
	if makeitlast then
		trigger.action.outTextForCoalition(gr:getCoalition(),toprint,30,true)
	else
		trigger.action.outTextForCoalition(gr:getCoalition(),toprint,10)
	end
end

	
	function JTAC:clearTarget()
		self.target = nil
		jtacIntelActive[self.tgtzone.zone] = false
		if self.lasers.tgt then
			self.lasers.tgt:destroy()
			self.lasers.tgt = nil
		end
		if self.lasers.ir then
			self.lasers.ir:destroy()
			self.lasers.ir = nil
		end
		if self.timerReference then
			self.timerReference:Stop()
			self.timerReference=nil
		end
		local gr = Group.getByName(self.name)
		if gr then
			gr:destroy()
		end
		missionCommands.removeItemForCoalition(self.side, self.jtacMenu)
		self.jtacMenu = nil
		for i,v in ipairs(jtacQueue) do
			if v == self then table.remove(jtacQueue,i) break end
		end
	end
	
	function JTAC:searchTarget(printKill)
		local gr = Group.getByName(self.name)
		if gr then
			if self.tgtzone and self.tgtzone.side~=0 and self.tgtzone.side~=gr:getCoalition() then
				local viabletgts = {}
				if not self.sortByThreat then
                    self.sortByThreat = JTAC.sortByThreat
                end
				for i,v in pairs(self.tgtzone.built) do
					local tgtgr = Group.getByName(v)
					if tgtgr and tgtgr:getSize()>0 then
						for i2,v2 in ipairs(tgtgr:getUnits()) do
							if v2:getLife()>=1 then
								table.insert(viabletgts, v2)
							end
						end
					else
						tgtgr = StaticObject.getByName(v)
						if tgtgr and tgtgr:isExist() then
							local isCritical=false for _,co in ipairs(self.tgtzone.criticalObjects) do if co==v then isCritical=true break end end
							if not isCritical then table.insert(viabletgts, tgtgr) end
						end
					end
				end
				
				if self.priority then
					local priorityTargets = {}
					for i,v in ipairs(viabletgts) do
						for i2,v2 in ipairs(self.priority) do
							if v2 == "StaticObjects" then
								if Object.getCategory(v) == Object.Category.STATIC and v:getName() then
									table.insert(priorityTargets,v)
									break
								end
							elseif v:hasAttribute(v2) and v:getLife()>=1 then
								table.insert(priorityTargets,v)
								break
							end
						end
					end
					
					if #priorityTargets>0 then
						viabletgts = priorityTargets
					else
						self:clearPriority()
						trigger.action.outTextForCoalition(gr:getCoalition(), 'JTAC: No priority targets found', 10)
					end
				end
				
                if #viabletgts > 0 then
                    if self.sortByThreat then viabletgts = self:sortByThreat(viabletgts) end
                    if printKill then
                        trigger.action.outTextForCoalition(self.side,'Kill confirmed, switching targets',4)
                        self._holdUntil = timer.getTime() + 5
                        timer.scheduleFunction(function(dr)
                            if dr and dr.name and Group.getByName(dr.name) then
                                dr:searchTarget()
                            end
                        end, self, self._holdUntil)
                        return
                    end
                    local _rnd = self.randomNext self.randomNext = nil
                    local chosentgt = _rnd and math.random(1,#viabletgts) or 1
                    self:setTarget(viabletgts[chosentgt])
                    self:printTarget()
                    self:buildSelectTargetMenu()
                else
                    self:clearTarget()
					trigger.action.outTextForCoalition(self.side,'JTAC: No more targets, leaving.',4)
                end
			else
				self:clearTarget()
				--trigger.action.outTextForCoalition(self.side,'No more targets, leaving.',4)
			end
		end
	end

	
	function JTAC:searchIfNoTarget()
		if not Group.getByName(self.name) then
			self:clearTarget()
			return
		end
		if timer.getTime() < self._holdUntil then 
			return 
		end
		if not self.target then
			self:searchTarget()
			return
		end
	
		local un = Unit.getByName(self.target) or StaticObject.getByName(self.target)
		if un and un:isExist() and un:getLife() >= 1 then

			self:setTarget(un)
			if self.tgtzone and self.tgtzone.built then
				local oldCount = self._lastViableCount or 0
				local newCount = 0
				for _, v in pairs(self.tgtzone.built) do
					local tgtgr = Group.getByName(v)
					if tgtgr and tgtgr:getSize() > 0 then
						for _,unitObj in ipairs(tgtgr:getUnits()) do
							if unitObj:getLife() >= 1 then
								newCount = newCount + 1
							end
						end
					else
						local st = StaticObject.getByName(v)
						if st and st:isExist() then
							local isCritical = false
							for _,co in ipairs(self.tgtzone.criticalObjects) do
								if co == v then
									isCritical = true
									break
								end
							end
							if not isCritical then
								newCount = newCount + 1
							end
						end
					end
				end
	
				if newCount < oldCount then
					self:buildSelectTargetMenu()
				end
				self._lastViableCount = newCount
			end
	
        else
            self:searchTarget(true)
        end
	end
	
	jtacIntelActive = jtacIntelActive or {}


	function JTAC:deployAtZone(zoneCom)
		self.tgtzone=zoneCom
		jtacIntelActive[zoneCom.zone]=true
		local p=CustomZone:getByName(self.tgtzone.zone).point
		local coord=COORDINATE:New(p.x,6000,p.z)
		local tpl=UTILS.DeepCopy(_DATABASE.Templates.Groups[self.name].Template)
		self.spawnObj=SPAWN:NewFromTemplate(tpl,self.name,nil,true)
		
			:OnSpawnGroup(function()self:setOrbit(self.tgtzone.zone,p)end)
		self.spawnObj:SpawnFromCoordinate(coord)
		if not self.timerReference then
			self.timerReference=SCHEDULER:New(nil,self.searchIfNoTarget,{self},20,5)
		end
	end


	function JTAC:setOrbit(zonename, point)
		local gr = Group.getByName(self.name)
		if not gr then 
			return
		end
		local GroupID = gr:getID()

		local cnt = gr:getController()
		cnt:setCommand({ 
			id = 'SetInvisible', 
			params = { 
				value = true
			} 
		})
		cnt:setCommand({ 
			id = 'SetImmortal', 
			params = { 
				value = true
			} 
		})
		cnt:setCommand({ 
			id = 'EPLRS', 
			params = { 
				value = true,
				groupId = GroupID
			} 
		})
		cnt:setOption(AI.Option.Air.id.SILENCE, true)
		cnt:setTask({ 
			id = 'Orbit', 
			params = { 
				pattern = 'Circle',
				point = {x = point.x, y=point.z},
				altitude = 6000
			} 
		})
		trigger.action.outTextForCoalition(gr:getCoalition(),'JTAC is deployed, Looking for targets, standby',15)
		timer.scheduleFunction(function() if Group.getByName(self.name) then self:searchTarget() end end, {}, timer.getTime()+15)
	end




	function JTAC:buildSelectTargetMenu()
		if not self.jtacMenu then
			return
		end

		if self.selectTargetMenu then
			missionCommands.removeItemForCoalition(self.side, self.selectTargetMenu)
		end

		self.selectTargetMenu = missionCommands.addSubMenuForCoalition(self.side, 'Select Target', self.jtacMenu)

		local gr = Group.getByName(self.name)
		if not gr or not self.tgtzone or self.tgtzone.side == 0 or self.tgtzone.side == gr:getCoalition() then
			missionCommands.addCommandForCoalition(self.side, 'No valid targets', self.selectTargetMenu, function() end)
			return
		end

		local viabletgts = {}
		for i,v in pairs(self.tgtzone.built) do
			local tgtgr = Group.getByName(v)
			if tgtgr and tgtgr:getSize() > 0 then
				for i2,v2 in ipairs(tgtgr:getUnits()) do
					if v2:getLife() >= 1 then
						table.insert(viabletgts, v2)
					end
				end
			else
				local st = StaticObject.getByName(v)
				if st and st:isExist() then
					local isCritical=false for _,co in ipairs(self.tgtzone.criticalObjects) do if co==v then isCritical=true break end end
					if not isCritical and Object.getCategory(st) == Object.Category.STATIC and st:getName() then
						table.insert(viabletgts, st)
					end
				end
			end
		end
		if self.priority then
			local priorityTargets = {}
			for i,v in ipairs(viabletgts) do
				for i2,v2 in ipairs(self.priority) do
					if v2 == "StaticObjects" then
						if Object.getCategory(v) == Object.Category.STATIC and v:getName() then
							table.insert(priorityTargets,v)
							break
						end
					elseif v:hasAttribute(v2) and v:getLife() >= 1 then
						table.insert(priorityTargets,v)
						break
					end
				end
			end
			if #priorityTargets > 0 then
				viabletgts = priorityTargets
			else
				self:clearPriority()
				trigger.action.outTextForCoalition(gr:getCoalition(), 'JTAC: No priority targets found', 10)
			end
		end

		if #viabletgts == 0 then
			missionCommands.addCommandForCoalition(self.side, 'No valid targets', self.selectTargetMenu, function() end)
			return
		end

		if self.sortByThreat then
			viabletgts = self:sortByThreat(viabletgts)
		end

		local subMenuRef = nil
		for i, unitObj in ipairs(viabletgts) do
			local thisUnit = unitObj
			local label
			if Object.getCategory(thisUnit) == Object.Category.STATIC then
				label = '('..i..') '..(thisUnit:getName() or "Unknown")
			else
				local tgttype = renameType(thisUnit:getTypeName())
				label = '('..i..') '..tgttype
			end
			if self.target == thisUnit:getName() then
				label = label .. ' (Lasing)'
			end
			
			local callback = function()
				self.isManualTarget = true
				self:setTarget(thisUnit)
				self:printTarget(true)
				self:buildSelectTargetMenu()
			end

			if i < 10 then
				missionCommands.addCommandForCoalition(self.side, label, self.selectTargetMenu, callback)
					--env.info("[JTAC] Selected unitObj: " .. (thisUnit:getName() or "NIL"))

			elseif i == 10 then
				subMenuRef = missionCommands.addSubMenuForCoalition(self.side, 'More', self.selectTargetMenu)
				missionCommands.addCommandForCoalition(self.side, label, subMenuRef, callback)
					--env.info("[JTAC] Selected unitObj: " .. (thisUnit:getName() or "NIL"))

			elseif (i - 10) % 9 == 0 then
				subMenuRef = missionCommands.addSubMenuForCoalition(self.side, 'More', subMenuRef)
				missionCommands.addCommandForCoalition(self.side, label, subMenuRef, callback)
					--env.info("[JTAC] Selected unitObj: " .. (thisUnit:getName() or "NIL"))
			else
				missionCommands.addCommandForCoalition(self.side, label, subMenuRef, callback)
					--env.info("[JTAC] Selected unitObj: " .. (thisUnit:getName() or "NIL"))
			end
		end
	end
end
------------------------------------------ jtac 9 line AM --------------------------------------------
JTAC9line = {}
do
    function JTAC9line:new(obj)
        obj = obj or {}
        obj.side = Group.getByName(obj.name):getCoalition()
        setmetatable(obj, self)
        self.__index = self
        return obj
    end

	function JTAC9line:deployAtZone(zoneCom)
		self.tgtzone=zoneCom
		local p=CustomZone:getByName(self.tgtzone.zone).point
		local coord=COORDINATE:New(p.x,6000,p.z)
		local tpl=UTILS.DeepCopy(_DATABASE.Templates.Groups[self.name].Template)
		self.spawnObj=SPAWN:NewFromTemplate(tpl,self.name,nil,true)
			:OnSpawnGroup(function()self:setTasks(self.tgtzone.zone,p)end)
		self.spawnObj:SpawnFromCoordinate(coord)
	end


    function JTAC9line:setTasks(zonename, point)
        local gr = Group.getByName(self.name)
        if gr then
            local cnt = gr:getController()
            cnt:setCommand({
                id = 'SetInvisible', 
                params = { 
                    value = true 
                } 
            })

            -- Set ComboTask with FAC and Orbit as sequential tasks
            local comboTask = {
                id = 'ComboTask',
                params = {
                    tasks = {
                        [1] = {  -- FAC Task
                            id = 'FAC',
                            params = {
                                frequency = 241000000,
                                modulation = 0,
                                callname = 2,
                                number = 1,
                                designation = 'Auto',
                                datalink = true,
                                priority = 1
                            }
                        },
                        [2] = {  -- Orbit Task
                            id = 'Orbit',
                            params = {
                                pattern = 'Circle',
                                point = {x = point.x, y = point.z},
                                altitude = 6000,
                                number = 2
                            }
                        }
                    }
                }
            }

            cnt:setTask(comboTask)
        else
            trigger.action.outText("JTAC Group not found after deployment: " .. self.name, 10)
        end
    end
end

----------------------------------------- jtac 9 line fm --------------------------------------------
JTAC9linefmr = {}
do
    function JTAC9linefmr:new(obj)
        obj = obj or {}
        obj.side = Group.getByName(obj.name):getCoalition()
        setmetatable(obj, self)
        self.__index = self
        return obj
    end

	function JTAC9linefmr:deployAtZone(zoneCom)
		self.tgtzone=zoneCom
		local p=CustomZone:getByName(self.tgtzone.zone).point
		local coord=COORDINATE:New(p.x,6000,p.z)
		local tpl=UTILS.DeepCopy(_DATABASE.Templates.Groups[self.name].Template)
		self.spawnObj=SPAWN:NewFromTemplate(tpl,self.name,nil,true)
			:OnSpawnGroup(function()self:setTasks(self.tgtzone.zone,p)end)
		self.spawnObj:SpawnFromCoordinate(coord)
	end

    function JTAC9linefmr:setTasks(zonename, point)
        local gr = Group.getByName(self.name)
        if gr then
            local cnt = gr:getController()
            cnt:setCommand({
                id = 'SetInvisible', 
                params = { 
                    value = true 
                } 
            })

            -- Set ComboTask with FAC and Orbit as sequential tasks for 31 MHz FM
            local comboTask = {
                id = 'ComboTask',
                params = {
                    tasks = {
                        [1] = {  -- FAC Task
                            id = 'FAC',
                            params = {
                                frequency = 31000000,  -- 31 MHz
                                modulation = 1,        -- FM modulation
                                callname = 3,
                                number = 1,
                                designation = 'Auto',
                                datalink = true,
                                priority = 1
                            }
                        },
                        [2] = {  -- Orbit Task
                            id = 'Orbit',
                            params = {
                                pattern = 'Circle',
                                point = {x = point.x, y = point.z},
                                altitude = 6000,
                                number = 2
                            }
                        }
                    }
                }
            }

            cnt:setTask(comboTask)
        else
            trigger.action.outText("JTAC Group not found after deployment: " .. self.name, 10)
        end
    end
end

----------------------------------------- END jtac 9 line FM --------------------------------------------

function CustomRespawn(grpName)
    local g = GROUP:FindByName(grpName)
    if g and g:IsAlive() then
        local tpl       = g:GetTemplate()
        local firstUnit = g:GetUnit(1)
        local coord     = firstUnit and firstUnit:GetCoordinate()

        if coord then
            local sp = SPAWN:NewFromTemplate(tpl, grpName, nil, true)
            sp:InitSkill("Excellent")
            if not string.find(grpName, "Fixed") then
                sp:InitRandomizePosition(true, 75, 30):InitPositionCoordinate(coord)
            end
            sp:Spawn()
        else
           local SP2 = SPAWN:NewFromTemplate(tpl, grpName, nil, true)
			 if not string.find(grpName, "Fixed") then
                SP2:InitRandomizePosition(true, 75, 30)
			 end	
			SP2:Spawn()
        end
    else
        local tpl = UTILS.DeepCopy(_DATABASE.Templates.Groups[grpName].Template)
        SPAWN:NewFromTemplate(tpl, grpName, nil, true):InitSkill("Excellent"):Spawn()
    end
end

function RespawnGroup(grpName)
  local old=GROUP:FindByName(grpName)
  if not old then trigger.action.outText("Group "..tostring(grpName).." not found, please report it to Leka",30) 
	env.info("Group "..tostring(grpName).." not found, please report it to Leka")
	end
  if old then old:Destroy() end
  local tpl=UTILS.DeepCopy(_DATABASE.Templates.Groups[grpName].Template)
  tpl.name=grpName
  return SPAWN:NewFromTemplate(tpl,grpName,nil,true):InitRadioCommsOnOff(false):Spawn()
end

GlobalSettings = {}
do
	GlobalSettings.maxSupplyPerZoneBlue = 1  		-- max supply per to the same target zone at once
	GlobalSettings.maxSupplyPerZoneRed = 2  		-- max supply per to the same target zone at once
	-- GlobalSettings.upgradeSlowMax = 1.0      		-- max slowdown multiplier from upgrades
    -- GlobalSettings.upgradeSlowExpo = 1.0    		-- curve for non-supply slowdown
	-- GlobalSettings.supplySlowMax =  1.0     		-- max slowdown if no upgrades built
	GlobalSettings.capRearlineNmBlue = 30    		-- blue CAP cutoff behind frontline (nm)
	GlobalSettings.frontlineDistanceLimitBlue = 30
	GlobalSettings.frontlineDistanceLimitRed  = 30
	GlobalSettings.proximityWakeNm = 30    			-- wake up zones within this nm of front
	GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
	GlobalSettings.autoSuspendNmRed = 120   		-- suspend red zones deeper than this nm
	GlobalSettings.blockedDespawnTime = 10*60 		-- used to despawn aircraft that are stuck taxiing for some reason
	GlobalSettings.landedDespawnTime = 1*60
	GlobalSettings.initialDelayVariance = 20 		-- minutes
	
	GlobalSettings.messages = {
		grouplost = false,
		captured = true,
		upgraded = true,
		repaired = true,
		zonelost = true,
		disabled = true
	}
	
	GlobalSettings.urgentRespawnTimers = {
    dead = 35,
    hangar = 20,
    preparing = 5
	}
	
	GlobalSettings.defaultRespawns = {}
	GlobalSettings.defaultRespawns[1] = {
		supply = { dead=30*60, hangar=15*60, preparing=5*60},
		patrol = { dead=30*60, hangar=15*60, preparing=5*60},
		attack = { dead=30*60, hangar=15*60, preparing=5*60}
	}
	
	GlobalSettings.defaultRespawns[2] = {
		supply = { dead=30*60, hangar=15*60, preparing=5*60},
		patrol = { dead=30*60, hangar=15*60, preparing=5*60},
		attack = { dead=30*60, hangar=15*60, preparing=5*60}
	}
	
	GlobalSettings.respawnTimers = {}
	
	function GlobalSettings.resetDifficultyScaling()
		GlobalSettings.respawnTimers[1] = {
			supply = { 
				dead = GlobalSettings.defaultRespawns[1].supply.dead, 
				hangar = GlobalSettings.defaultRespawns[1].supply.hangar, 
				preparing = GlobalSettings.defaultRespawns[1].supply.preparing
			},
			patrol = { 
				dead = GlobalSettings.defaultRespawns[1].patrol.dead, 
				hangar = GlobalSettings.defaultRespawns[1].patrol.hangar, 
				preparing = GlobalSettings.defaultRespawns[1].patrol.preparing
			},
			attack = { 
				dead = GlobalSettings.defaultRespawns[1].attack.dead, 
				hangar = GlobalSettings.defaultRespawns[1].attack.hangar, 
				preparing = GlobalSettings.defaultRespawns[1].attack.preparing
			}
		}
		
		GlobalSettings.respawnTimers[2] = {
			supply = { 
				dead = GlobalSettings.defaultRespawns[2].supply.dead, 
				hangar = GlobalSettings.defaultRespawns[2].supply.hangar, 
				preparing = GlobalSettings.defaultRespawns[2].supply.preparing
			},
			patrol = { 
				dead = GlobalSettings.defaultRespawns[2].patrol.dead, 
				hangar = GlobalSettings.defaultRespawns[2].patrol.hangar, 
				preparing = GlobalSettings.defaultRespawns[2].patrol.preparing
			},
			attack = { 
				dead = GlobalSettings.defaultRespawns[2].attack.dead, 
				hangar = GlobalSettings.defaultRespawns[2].attack.hangar, 
				preparing = GlobalSettings.defaultRespawns[2].attack.preparing
			}
		}
	end
	
	function GlobalSettings.setDifficultyScaling(value, coalition)
		GlobalSettings.resetDifficultyScaling()
		for i,v in pairs(GlobalSettings.respawnTimers[coalition]) do
			for i2,v2 in pairs(v) do
				GlobalSettings.respawnTimers[coalition][i][i2] = math.floor(GlobalSettings.respawnTimers[coalition][i][i2] * value)
			end
		end
	end
	
	GlobalSettings.resetDifficultyScaling()
end

ejectedPilotOwners = {}
landedPilotOwners = {}

MissionTargets        = {}
MissionGroups         = {}
ScoreTargets          = {}
ActiveMission         = {}

function RegisterUnitTarget(uname,reward,stat,flagName)
    if flagName then
        MissionTargets[uname]={reward=reward,stat=stat,flag=flagName}
    else
        MissionTargets[uname]={reward=reward,stat=stat}
    end
end

function RegisterGroupTarget(groupName,reward,stat,flagName)
    local g = Group.getByName(groupName)
    if not g then return end
    local tab = {reward = reward, stat = stat, alive = {}, remaining = 0, killers = {}}
    if flagName then tab.flag = flagName end
    for _,u in ipairs(g:getUnits()) do
        local n = u:getName()
        tab.alive[n] = true
        tab.remaining = tab.remaining + 1
        MissionTargets[n] = {group = groupName}
        if flagName then MissionTargets[n].flag = flagName end
    end
    MissionGroups[groupName] = tab
    if flagName then flag = flagName end
end

function RegisterScoreTarget(flag,obj,reward,stat)
    local st = ScoreTargets[flag]
    if not st then
        st = {objects={},remaining=0,reward=reward,stat=stat}
        ScoreTargets[flag] = st
    end
    st.objects[#st.objects+1] = obj
    st.remaining = st.remaining + 1
end

function SetUpCAP_DefaultAA(group)
	group:getController():setOption(AI.Option.Air.id.PROHIBIT_AG, true)
	group:getController():setOption(AI.Option.Air.id.ALLOW_FORMATION_SIDE_SWAP, true)
	group:getController():setOption(AI.Option.Air.id.JETT_TANKS_IF_EMPTY, true)
	group:getController():setOption(AI.Option.Air.id.PROHIBIT_JETT, true)
	group:getController():setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
	group:getController():setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.OPEN_FIRE)
	group:getController():setOption(AI.Option.Air.id.MISSILE_ATTACK, AI.Option.Air.val.MISSILE_ATTACK.MAX_RANGE)
	group:getController():setOption(AI.Option.Air.id.RTB_ON_OUT_OF_AMMO, 268402688) -- AnyMissile
end


Frontline = Frontline or {}
Frontline._centroidCache = Frontline._centroidCache or {}

local NM = 1852



function Frontline.DebugExplain(zname)
  local bc = bc or _G.bc
  local function b(v) return v and "true" or "false" end
  local zi = Frontline._zoneInfo and Frontline._zoneInfo[zname]
  local z  = bc and bc.getZoneByName and bc:getZoneByName(zname) or nil
  local cz = CustomZone and CustomZone:getByName(zname) or nil
  env.info(string.format("[FL-EXPL] name=%s presentIn_zoneInfo=%s", tostring(zname), b(zi~=nil)))
  env.info(string.format("[FL-EXPL] bc:getZoneByName -> %s", z and "FOUND" or "nil"))
  if z then
    env.info(string.format("[FL-EXPL] side=%s active=%s suspended=%s hidden=%s",
      tostring(z.side), b(z.active), b(z.suspended), b(z.zone and z.zone:lower():find("hidden"))))
  end
  env.info(string.format("[FL-EXPL] CustomZone:getByName -> %s", cz and "FOUND" or "nil"))
  if cz then
    local kind = cz.isCircle and cz:isCircle() and "circle" or (cz.isQuad and cz:isQuad() and "quad" or "other")
    env.info(string.format("[FL-EXPL] CZ kind=%s point=(%.0f,%.0f)", kind, cz.point.x, cz.point.z))
  end
  local cached = Frontline._centroidCache and Frontline._centroidCache[zname]
  env.info(string.format("[FL-EXPL] centroidCached=%s", b(cached~=nil)))
  if not zi then
    env.info("[FL-EXPL] Rebuilding Frontline from zones to see if it appears…")
    local ok,err = pcall(function() Frontline.BuildFromZones((bc and bc.indexedZones) or (bc and bc.zones) or {}) end)
    env.info(string.format("[FL-EXPL] rebuild ok=%s err=%s", b(ok), tostring(err)))
    local zi2 = Frontline._zoneInfo and Frontline._zoneInfo[zname]
    env.info(string.format("[FL-EXPL] presentAfterRebuild=%s", b(zi2~=nil)))
  end
  if not z then
    local guesses = {}
    if bc and bc.zones then
      for _,zz in ipairs(bc.zones) do
        if zz and zz.zone and zz.zone:lower():find((zname or ""):lower(), 1, true) then
          guesses[#guesses+1] = zz.zone
        end
      end
    end
    if #guesses>0 then env.info("[FL-EXPL] name-like matches: "..table.concat(guesses,", ")) end
  end
end


--Frontline.DebugExplain('samathe')

local function v2(x,y) return {x=x,y=y} end
local function vsub(a,b) return v2(a.x-b.x,a.y-b.y) end
local function vadd(a,b) return v2(a.x+b.x,a.y+b.y) end
local function vmul(a,s) return v2(a.x*s,a.y*s) end
local function vdot(a,b) return a.x*b.x + a.y*b.y end
local function vlen(a) return math.sqrt(a.x*a.x + a.y*a.y) end
local function vnorm(a) local L=vlen(a) return (L>0) and v2(a.x/L,a.y/L) or v2(0,0) end

local function zoneCentroid(zname)
  local cache = Frontline._centroidCache
  local cached = cache and cache[zname]
  if cached then return cached end

  local cz = CustomZone:getByName(zname); if not cz then return nil end
  local centroid
  if cz:isCircle() then
    centroid = v2(cz.point.x, cz.point.z)
  elseif cz:isQuad() then
    local sx,sy=0,0
    for i=1,#cz.vertices do sx=sx+cz.vertices[i].x; sy=sy+cz.vertices[i].z end
    local n=#cz.vertices; centroid = v2(sx/n, sy/n)
  else
    centroid = v2(cz.point.x, cz.point.z)
  end

  cache[zname] = centroid
  return centroid
end



function Frontline.BuildFromZones(zonesTbl)
    local zoneInfo = {}
    local blues, reds = {}, {}
    for _,zc in pairs(zonesTbl or {}) do
        local name,side = zc.zone, zc.side
        if name then
            local lowered = string.lower(name)
            if not lowered:find("hidden") then
                local c = zoneCentroid(name)
                if c then
                    zoneInfo[name] = {center=c, side=side, active=zc.active}
                    if side==2 then
                        blues[#blues+1] = name
                    elseif side==1 then
                        reds[#reds+1] = name
                    end
                end
            end
        end
    end
    Frontline._zoneInfo = zoneInfo
    local segs = {}
    local function nearestOpposite(fromList, toList, fromSide)
        for i=1,#fromList do
            local aName = fromList[i]
            local ai = zoneInfo[aName]
            if ai then
                local best,bd
                for j=1,#toList do
                    local bName = toList[j]
                    local bi = zoneInfo[bName]
                    if bi then
                        local d = vlen(vsub(bi.center, ai.center))
                        if not bd or d < bd then
                            best,bd = bName,d
                        end
                    end
                end
                if best then
                    local A,B = ai.center, zoneInfo[best].center
                    local n = (fromSide==2) and vnorm(vsub(B,A)) or vnorm(vsub(A,B))
                    local m = vmul(vadd(A,B), 0.5)
                    segs[#segs+1] = {A=A,B=B,m=m,n=n}
                end
            end
        end
    end
    if #blues > 0 and #reds > 0 then
        nearestOpposite(blues, reds, 2)
        nearestOpposite(reds, blues, 1)
    end
    Frontline._segs = segs
    local zoneNames = {}
    for name,info in pairs(zoneInfo) do
        info.sameSideNeighbors = {}
        info.enemyNeighbors = {}
        zoneNames[#zoneNames+1] = name
    end
    table.sort(zoneNames)
    for i=1,#zoneNames do
        local aName = zoneNames[i]
        local ai = zoneInfo[aName]
        for j=i+1,#zoneNames do
            local bName = zoneNames[j]
            local bi = zoneInfo[bName]
            local dx = bi.center.x - ai.center.x
            local dy = bi.center.y - ai.center.y
            local dist2 = dx*dx + dy*dy
            local vecAB = v2(dx, dy)
            local vecBA = v2(-dx, -dy)
			if ai.side and bi.side then
				local same = (ai.side == bi.side) or (ai.side == 0) or (bi.side == 0) or (ai.active == false) or (bi.active == false)
				if same then
					ai.sameSideNeighbors[#ai.sameSideNeighbors+1] = {name=bName, vec=vecAB, dist2=dist2}
					bi.sameSideNeighbors[#bi.sameSideNeighbors+1] = {name=aName, vec=vecBA, dist2=dist2}
				else
					ai.enemyNeighbors[#ai.enemyNeighbors+1] = {name=bName, vec=vecAB, dist2=dist2, side=bi.side}
					bi.enemyNeighbors[#bi.enemyNeighbors+1] = {name=aName, vec=vecBA, dist2=dist2, side=ai.side}
				end
			else
				ai.sameSideNeighbors[#ai.sameSideNeighbors+1] = {name=bName, vec=vecAB, dist2=dist2}
				bi.sameSideNeighbors[#bi.sameSideNeighbors+1] = {name=aName, vec=vecBA, dist2=dist2}
			end
        end
    end
    local function sortByDist2(a,b) return a.dist2 < b.dist2 end
    for _,info in pairs(zoneInfo) do
        table.sort(info.sameSideNeighbors, sortByDist2)
        table.sort(info.enemyNeighbors, sortByDist2)
    end
    for name,info in pairs(zoneInfo) do
        local signed, seg = (function(p)
            local best,bd = nil, math.huge
            for i=1,#segs do
                local s = segs[i]
                local d = vlen(vsub(p, s.m))
                if d < bd then best,bd = s, d end
            end
            if not best then return 1e9, nil end
            local signed = vdot(vsub(p, best.m), best.n)
            return signed, best
        end)(info.center)
        info.distToFrontNm = signed / NM
        info.frontSeg = seg
    end
    return segs
end

local function nearestSegSigned(p)
  local segs = Frontline._segs or {}
  local best,bd = nil, math.huge
  for i=1,#segs do
    local s = segs[i]
    local d = vlen(vsub(p, s.m))
    if d < bd then best,bd = s, d end
  end
  if not best then return 1e9, nil end
  local signed = vdot(vsub(p, best.m), best.n)
  return signed, best
end


function Frontline.DistToFrontMeters(coord_or_vec2)
  local p
  if coord_or_vec2.GetVec2 then
    local v = coord_or_vec2:GetVec2(); p = v2(v.x, v.y)
  elseif coord_or_vec2.x and coord_or_vec2.y then
    p = coord_or_vec2
  else
    return 1e9
  end
  local signed = nearestSegSigned(p)
  return signed
end

function Frontline.GetZoneInfo(zoneName)
  local zi = Frontline._zoneInfo
  if not zi then return nil end
  return zi[zoneName]
end

--Frontline.BuildFromZones(bc.indexedZones)  -- see fix below
--Frontline._debugDump()

function Frontline._debugDump()
  local zi = Frontline._zoneInfo or {}
  local segs = Frontline._segs or {}
  local cnt = 0
  for _ in pairs(zi) do cnt = cnt + 1 end
  env.info(string.format("[FRONTLINE] zoneInfo=%d segments=%d", cnt, #segs))
end

function Frontline.ZoneDistToFrontNm(zoneName)
  local zi = Frontline.GetZoneInfo(zoneName)
  if not zi then
    env.info(string.format("[FRONTLINE] missing zone in _zoneInfo: %s", tostring(zoneName)))
    return nil
  end
  if zi.distToFrontNm == nil then
    zi.distToFrontNm = Frontline.DistToFrontMeters(zi.center) / NM
  end
  return zi.distToFrontNm
end




function Frontline.PickStationNearZone(zoneName, mySide, offsetNmTowardFriendly, lateralJitterNm, forwardJitterNm, minBufferNm)
    local zi = Frontline._zoneInfo[zoneName]; if not zi then return nil end
    local signed, seg = nearestSegSigned(zi.center); if not seg then local _dir=(zi.side == (mySide or zi.side)) and 1 or -1; local _off=(offsetNmTowardFriendly or 20) * NM * _dir; return vadd(zi.center, v2(_off,0)) end
    local dir = (zi.side == (mySide or zi.side)) and 1 or -1
    local off = (offsetNmTowardFriendly or 20) * NM * dir
    local t = vnorm(v2(-seg.n.y, seg.n.x))
    local lateral = 0
    local sameNeighbors = zi.sameSideNeighbors
    if sameNeighbors and #sameNeighbors > 0 then
        local leftProj, rightProj
        for i=1,#sameNeighbors do
            local nb = sameNeighbors[i]
            local proj = vdot(nb.vec, t)
            if proj < -1 then
                if not leftProj or proj > leftProj then leftProj = proj end
            elseif proj > 1 then
                if not rightProj or proj < rightProj then rightProj = proj end
            end
        end
        if leftProj and rightProj then
            lateral = (leftProj + rightProj) * 0.5
        elseif leftProj then
            lateral = leftProj * 0.5
        elseif rightProj then
            lateral = rightProj * 0.5
        end
        local latLimitNm = (lateralJitterNm and lateralJitterNm > 0) and (lateralJitterNm * NM) or nil
        if latLimitNm then
            if lateral > latLimitNm then lateral = latLimitNm end
            if lateral < -latLimitNm then lateral = -latLimitNm end
        end
    end
    local minBufM = (minBufferNm or 0) * NM
    local clampedOff = off
    if minBufM > 0 then
        local enemies = zi.enemyNeighbors
        if enemies and #enemies > 0 then
            for i=1,#enemies do
                local proj = vdot(enemies[i].vec, seg.n)
                local limit = proj - minBufM * dir
                if dir == 1 then
                    if clampedOff > limit then clampedOff = limit end
                else
                    if clampedOff < limit then clampedOff = limit end
                end
            end
        end
    end
    local base = vadd(zi.center, vmul(seg.n, clampedOff))
    local st = vadd(base, vmul(t, lateral))
    return st
end



DynamicConvoy = DynamicConvoy or {}
local dc = DynamicConvoy
dc.TARGET_SUBZONES = dc.TARGET_SUBZONES or {}
dc.RSTATE = dc.RSTATE or (1 + math.floor((((timer and timer.getTime) and timer.getTime()) or 0) * 1000))
dc.TARGET_TAIL_CACHE = dc.TARGET_TAIL_CACHE or {}
dc.DEFAULT_SPEED = 20
dc.DEFAULT_WAYPOINTS_IN_TARGET = dc.DEFAULT_WAYPOINTS_IN_TARGET or 5
dc.PATH_CACHE = dc.PATH_CACHE or {}
dc.OFFROAD_PENALTY = dc.OFFROAD_PENALTY or 1.25
dc.OFFROAD_EXIT_EARLY_METERS = math.random(100, 300)

local function dcrand()
    local a, c, m = 1103515245, 12345, 2147483648
    dc.RSTATE = (a * dc.RSTATE + c) % m
    return dc.RSTATE / m
end

local function keyPair(a,b)
    return a..">"..b
end

local function dcrandIndex(n)
    if n <= 1 then return 1 end
    return 1 + math.floor(dcrand() * n)
end

local function vec2FromSubzoneName(subName)
return getZoneCenter(subName)
end

local function pickClosestSubzoneToPoint(subnames, px, py)
    if not subnames or #subnames == 0 then return nil end
    local best,bd = nil,math.huge
    for _, name in ipairs(subnames) do
        local v = vec2FromSubzoneName(name)
        if v then
            local dx,dy = v.x - px, v.y - py
            local d = dx*dx + dy*dy
            if d < bd then best,bd = v,d end
        end
    end
    return best
end

local function ground_buildWP(pt, form, spd)
	return {
		x      = pt.x,
		y      = pt.z or pt.y,                -- DCS route uses “y” for ground
		type   = "Turning Point",
		action = (form=="On Road"  or form=="on_road")  and "On Road"
				or (form=="Off Road" or form=="off_road") and "Off Road"
				or form or "Off Road",
		speed  = (spd or 20) / 3.6            -- m/s, default 20 km/h
	}
end

function dc.InitTargetTails(insideCount)
    dc.DEFAULT_WAYPOINTS_IN_TARGET = insideCount or dc.DEFAULT_WAYPOINTS_IN_TARGET
    for _, zoneObj in ipairs(bc.zones or {}) do
        local zn = zoneObj.zone
        local subnames = ZONE_VALID_SUBZONES[zn] or {}
        local v2list = {}
        for _, subName in ipairs(subnames) do
            local v2 = vec2FromSubzoneName(subName)
            if v2 then v2list[#v2list + 1] = v2 end
        end
        dc.TARGET_SUBZONES[zn] = v2list
    end
end

function dc.InitRoadPathCache(zoneNames)
    local list = zoneNames or {}
    for i = 1, #list do
        for j = 1, #list do
            if i ~= j then
                local a, b = list[i], list[j]
				if not dc.PATH_CACHE[keyPair(a,b)] then
					local aSubs = ZONE_VALID_SUBZONES[a] or {}
					local bSubs = ZONE_VALID_SUBZONES[b] or {}
					if #aSubs > 0 and #bSubs > 0 then
							local bCenter = getZoneCenter(b)
							local bx, by = bCenter and bCenter.x or 0, bCenter and bCenter.y or 0
							local start = pickClosestSubzoneToPoint(aSubs, bx, by)
							local entry = pickClosestSubzoneToPoint(bSubs, start and start.x or bx, start and start.y or by)
						if start and entry then
							local path = land.findPathOnRoads("roads", start.x, start.y, entry.x, entry.y)
							if path and #path > 0 then
								local vlist = {}
								for _, p in ipairs(path) do
									vlist[#vlist+1] = { x = p.x, y = p.z or p.y or 0 }
								end
								dc.PATH_CACHE[keyPair(a,b)] = vlist
							end
						end
					end
				end
            end
        end
    end
end

function dc.GetOrderedTail(targetZoneName, entry)
    local cached = dc.TARGET_TAIL_CACHE[targetZoneName]
    if cached and cached.entry and cached.entry.x == entry.x and cached.entry.y == entry.y then return cached.list end
    local list = {}
    for _,v in ipairs(dc.TARGET_SUBZONES[targetZoneName] or {}) do
        list[#list+1] = { x = v.x, y = v.y }
    end
    table.sort(list, function(a,b)
        local dax,day = a.x - entry.x, a.y - entry.y
        local dbx,dby = b.x - entry.x, b.y - entry.y
        return (dax*dax + day*day) < (dbx*dbx + dby*dby)
    end)
    dc.TARGET_TAIL_CACHE[targetZoneName] = { entry = { x = entry.x, y = entry.y }, list = list }
    return list
end
local function scanTargetSubzones(zoneName)
    local t = {}
    for _, sub in ipairs(collectSubZones(zoneName)) do
        local v = getZoneCenter(sub)
        if v then t[#t+1] = v end
    end
    return t
end
function dc.BuildAttackConvoyRoute(originZoneName, targetZoneName, speed)
	local formations = {"Off Road","Cone","Diamond","Vee"}
    local aSubs = ZONE_VALID_SUBZONES[originZoneName] or {}
    local tSubs = dc.TARGET_SUBZONES and dc.TARGET_SUBZONES[targetZoneName] or {}
    if ZONE_DISTANCES and ZONE_DISTANCES[originZoneName] and ZONE_DISTANCES[originZoneName][targetZoneName] then
        local d = ZONE_DISTANCES[originZoneName][targetZoneName] or -1
        if d > (40*1852) then env.info("DC.BAIL distance_cap meters="..tostring(d)) return nil end
    else
        env.info("DC.INFO no_distance_entry_for_pair")
    end
    local startV2
    if #aSubs > 0 then
        local tCenter = getZoneCenter(targetZoneName)
        local tx, ty = tCenter and tCenter.x or 0, tCenter and tCenter.y or 0
        startV2 = pickClosestSubzoneToPoint(aSubs, tx, ty)
		if not startV2 then env.info("DC.BAIL no_start_from_subzones") return nil end
    else
        local v2c = getZoneCenter(originZoneName)
        if not v2c then return nil end
        startV2 = v2c
    end
    if not startV2 then env.info("DC.BAIL startV2_nil") return nil end
    if #tSubs == 0 then
    tSubs = scanTargetSubzones(targetZoneName)
    dc.TARGET_SUBZONES[targetZoneName] = tSubs
    --env.info("DC.FIX rebuilt_target_subzones zone="..tostring(targetZoneName).." count="..tostring(#tSubs))
    if #tSubs == 0 then env.info("DC.BAIL target_subzones_empty_scan_failed") return nil end
	end
	local frm = formations[dcrandIndex(#formations)]
	local anchorSub = tSubs[1]
	local rx, rz = land.getClosestPointOnRoads("roads", startV2.x, startV2.y)
	local roadStart = rx and { x = rx, y = rz } or nil
	local s_kmh = math.floor(((speed or dc.DEFAULT_SPEED or 13.8) * 3.6) + 0.5)

	local pts = {}
	if roadStart then
		local ax, ay = roadStart.x, roadStart.y
		local best, bd = anchorSub, math.huge
		for i = 1, #tSubs do
			local v = tSubs[i]
			local dx, dy = v.x - ax, v.y - ay
			local d = dx*dx + dy*dy
			if d < bd then best, bd = v, d end
		end
		anchorSub = best
	end
	if roadStart then
	local aimx, aimy = anchorSub.x, anchorSub.y
	local early = dc.OFFROAD_EXIT_EARLY_METERS or 0
		if early > 0 then
			local dx, dy = anchorSub.x - startV2.x, anchorSub.y - startV2.y
			local d = math.sqrt(dx*dx + dy*dy)
			if d > early and d > 0 then
				local ux, uy = dx/d, dy/d
				aimx = anchorSub.x - ux * early
				aimy = anchorSub.y - uy * early
			end
		end
		local erx, ery = land.getClosestPointOnRoads("roads", aimx, aimy)
		if erx then
			local endRoad = { x = erx, y = ery }
			pts[#pts+1] = ground_buildWP(startV2, "on_road", s_kmh)
			pts[#pts+1] = ground_buildWP(endRoad,  "on_road", s_kmh)
			pts[#pts+1] = ground_buildWP(anchorSub, "Off Road", s_kmh)
			pts[#pts].formation = frm

			local order = dc.GetOrderedTail(targetZoneName, endRoad)
			local need  = (dc.DEFAULT_WAYPOINTS_IN_TARGET or 5)
			local rem, seq = {}, {}
			for i = 1, #order do
				local v = order[i]
				if not (v.x == anchorSub.x and v.y == anchorSub.y) then rem[#rem+1] = i end
			end
			local cur = anchorSub
			while #rem > 0 and #seq < need do
				local bestk, bestd = 1, 1e18
				for k = 1, #rem do
					local v = order[ rem[k] ]
					local dx, dy = v.x - cur.x, v.y - cur.y
					local d = dx*dx + dy*dy
					if d < bestd then bestd, bestk = d, k end
				end
				local v = order[ rem[bestk] ]
				seq[#seq+1] = v
				cur = v
				table.remove(rem, bestk)
			end
			for i = 1, #seq do
				pts[#pts+1] = ground_buildWP(seq[i], "Off Road", s_kmh)
				pts[#pts].formation = frm
			end
			return { id = "Mission", params = { route = { points = pts } } }, startV2
		end
	end
	local sorted = {}
	for i = 1, #tSubs do sorted[i] = tSubs[i] end
	table.sort(sorted, function(a,b)
		local dax,day = a.x - startV2.x, a.y - startV2.y
		local dbx,dby = b.x - startV2.x, b.y - startV2.y
		return (dax*dax+day*day) < (dbx*dbx+dby*dby)
	end)
	pts[#pts+1] = ground_buildWP(startV2, "Off Road", s_kmh)
	pts[#pts].formation = frm
	local need2 = 1 + (dc.DEFAULT_WAYPOINTS_IN_TARGET or 5)
	for i = 1, math.min(need2, #sorted) do pts[#pts+1] = ground_buildWP(sorted[i], "Off Road", s_kmh); pts[#pts].formation = frm end
	return { id = "Mission", params = { route = { points = pts } } }, startV2
end

function dc.BuildSupplyConvoyRoute(originZoneName, targetZoneName, speed)
    local formations = {"Off Road","Cone","Diamond","Vee"}
    local aSubs = ZONE_VALID_SUBZONES[originZoneName] or {}
    local tSubs = dc.TARGET_SUBZONES and dc.TARGET_SUBZONES[targetZoneName] or {}
    if ZONE_DISTANCES and ZONE_DISTANCES[originZoneName] and ZONE_DISTANCES[originZoneName][targetZoneName] then
        local d = ZONE_DISTANCES[originZoneName][targetZoneName] or -1
        if d > (40*1852) then env.info("DC.BAIL distance_cap meters="..tostring(d)) return nil end
    else
        env.info("DC.INFO no_distance_entry_for_pair")
    end

    local startV2
    if #aSubs > 0 then
        local tCenter = getZoneCenter(targetZoneName)
        local tx, ty = tCenter and tCenter.x or 0, tCenter and tCenter.y or 0
        startV2 = pickClosestSubzoneToPoint(aSubs, tx, ty)
        if not startV2 then env.info("DC.BAIL no_start_from_subzones") return nil end
    else
        local v2c = getZoneCenter(originZoneName)
        if not v2c then return nil end
        startV2 = v2c
    end

    if #tSubs == 0 then
        tSubs = scanTargetSubzones(targetZoneName)
        dc.TARGET_SUBZONES[targetZoneName] = tSubs
        if #tSubs == 0 then env.info("DC.BAIL target_subzones_empty_scan_failed") return nil end
    end

    local rx, rz = land.getClosestPointOnRoads("roads", startV2.x, startV2.y)
    local roadStart = rx and { x = rx, y = rz } or nil

    local bestSub, bestER, bestD2 = nil, nil, math.huge
    for i = 1, #tSubs do
        local v = tSubs[i]
        local erx, ery = land.getClosestPointOnRoads("roads", v.x, v.y)
        if erx then
            local dx, dy = v.x - erx, v.y - ery
            local d2 = dx*dx + dy*dy
            if d2 < bestD2 then
                bestD2 = d2
                bestSub = v
                bestER  = { x = erx, y = ery }
            end
        end
    end
    if not bestSub then bestSub = tSubs[1] end

    local s_kmh = math.floor(((speed or dc.DEFAULT_SPEED or 13.8) * 3.6) + 0.5)
    local frm = formations[dcrandIndex(#formations)]
    local pts = {}

    if roadStart and bestER then
        local aimx, aimy = bestSub.x, bestSub.y
        local early = dc.OFFROAD_EXIT_EARLY_METERS or 0
        if early > 0 then
            local dx, dy = bestSub.x - startV2.x, bestSub.y - startV2.y
            local d = math.sqrt(dx*dx + dy*dy)
            if d > early and d > 0 then
                local ux, uy = dx/d, dy/d
                aimx = bestSub.x - ux * early
                aimy = bestSub.y - uy * early
            end
        end
        local erx2, ery2 = land.getClosestPointOnRoads("roads", aimx, aimy)
        local endRoad = (erx2 and { x = erx2, y = ery2 }) or bestER

        pts[#pts+1] = ground_buildWP(startV2, "on_road", s_kmh); pts[#pts].formation = frm
        pts[#pts+1] = ground_buildWP(endRoad,  "on_road", s_kmh); pts[#pts].formation = frm
        pts[#pts+1] = ground_buildWP({x = bestSub.x, z = bestSub.y}, "Off Road", s_kmh); pts[#pts].formation = frm

        return { id = "Mission", params = { route = { points = pts } } }, startV2
    end

    pts[#pts+1] = ground_buildWP(startV2, "Off Road", s_kmh); pts[#pts].formation = frm
    pts[#pts+1] = ground_buildWP({x = bestSub.x, z = bestSub.y}, "Off Road", s_kmh); pts[#pts].formation = frm
    return { id = "Mission", params = { route = { points = pts } } }, startV2
end

function dc.CollectZonesFromCommanders(list)
    local seen, out = {}, {}
    for _, c in ipairs(list or {}) do
        if c and c.type == 'surface' and c.template then
            local origin = c.zoneCommander and c.zoneCommander.zone
            local target = c.targetzone
            if origin and not seen[origin] then seen[origin]=true out[#out+1]=origin end
            if target and not seen[target] then seen[target]=true out[#out+1]=target end
        end
    end
    return out
end


dc.KNOWN_ZONES = dc.KNOWN_ZONES or {}

function dc.InitRoadPathCacheFromCommanders(list)
    local zones = dc.CollectZonesFromCommanders(list)
    dc.KNOWN_ZONES = zones
    return zones
end


BattleCommander = {}
do
	BattleCommander.zones = {}
	BattleCommander.indexedZones = {}
	BattleCommander.connections = {}
	BattleCommander.accounts = { [1]=0, [2]=0} -- 1 = red coalition, 2 = blue coalition
	BattleCommander.shops = {[1]={}, [2]={}}
	BattleCommander.shopItems = {}
	BattleCommander.monitorROE = {}
	BattleCommander.playerContributions = {[1]={}, [2]={}}
	BattleCommander.playerRewardsOn = false
	BattleCommander.rewards = {}
	BattleCommander.creditsCap = nil
	BattleCommander.difficultyModifier = 0
	BattleCommander.lastDiffChange = 0
	CustomFlags = CustomFlags or {}
	BattleCommander.groupSupportMenus = {}
	ZONE_DISTANCES = {}

	function BattleCommander:RemoveMenuForCoalition(coalition)
		missionCommands.removeItemForCoalition(coalition, {[1]='shop'})
	end
	function BattleCommander:refreshShopMenuForCoalition(coalition)
		missionCommands.removeItemForCoalition(coalition, {[1]='shop'})
		
		local shopmenu = missionCommands.addSubMenuForCoalition(coalition, 'shop')
		local sub1
		local count = 0
		
		local sorted = {}
		for i,v in pairs(self.shops[coalition]) do table.insert(sorted,{i,v}) end
		table.sort(sorted, function(a,b) return a[2].name < b[2].name end)
		
		for i2,v2 in pairs(sorted) do
			local i = v2[1]
			local v = v2[2]
			count = count +1
			if count<10 then
				missionCommands.addCommandForCoalition(coalition, '['..v.cost..'] '..v.name, shopmenu, self.buyShopItem, self, coalition, i)
			elseif count==10 then
				sub1 = missionCommands.addSubMenuForCoalition(coalition, "More", shopmenu)
				missionCommands.addCommandForCoalition(coalition, '['..v.cost..'] '..v.name, sub1, self.buyShopItem, self, coalition, i)
			elseif count%9==1 then
				sub1 = missionCommands.addSubMenuForCoalition(coalition, "More", sub1)
				missionCommands.addCommandForCoalition(coalition, '['..v.cost..'] '..v.name, sub1, self.buyShopItem, self, coalition, i)
			else
				missionCommands.addCommandForCoalition(coalition, '['..v.cost..'] '..v.name, sub1, self.buyShopItem, self, coalition, i)
			end
		end
	end
	

	function BattleCommander:refreshShopMenuForAllGroupsInCoalition(coal)
		local groups = coalition.getGroups(coal)
		if not groups then return end
		for _, g in pairs(groups) do
			if g and g:isExist() then
				self:refreshShopMenuForGroup(g:getID(), g)
			end
		end
	end
	
	function BattleCommander:new(savepath, updateFrequency, saveFrequency, difficulty) -- difficulty = {start = 1.4, min = -0.5, max = 0.5, escalation = 0.1, fade = 0.1, fadeTime = 30*60, coalition=1} --coalition 1:red 2:blue
		local obj = {}
		obj.saveFile = 'zoneCommander_moose.lua'
		if savepath then
			obj.saveFile = savepath
		end
		
		if not updateFrequency then updateFrequency = 10 end
		if not saveFrequency then saveFrequency = 60 end
		
		obj.difficulty = difficulty
		obj.updateFrequency = updateFrequency
		obj.saveFrequency = saveFrequency

		
		setmetatable(obj, self)
		self.__index = self
		return obj
	end
	
	
	function BattleCommander:restoreDisabledFriendlyZones()
		local list = {}
		for _, z in ipairs(self.zones) do
			if z.wasBlue and not z.active and not z.zone:lower():find("hidden") then
				list[#list+1] = z
			end
		end
		self.disabledBlueZones = list
		for i = 1, #list do
			list[i]:RecaptureBlueZone()
		end
		timer.scheduleFunction(function()
			local l = self.disabledBlueZones or {}
			for i = 1, #l do
				if not l[i].zone:lower():find("hidden") then
					l[i]:MakeZoneSideAndUpgraded()
				end
			end
		end, {}, timer.getTime() + 30)
	end

	function BattleCommander:activateNeutralStartZones()
		for _, z in ipairs(self.zones) do
			if z.side == 0 and z.NeutralAtStart and not z.firstCaptureByRed and not z.zone:lower():find("hidden") then
				z:MakeZoneRedAndUpgraded()
			end
		end
	end

	--difficulty scaling
	
	function BattleCommander:increaseDifficulty()
		self.difficultyModifier = math.max(self.difficultyModifier-self.difficulty.escalation, self.difficulty.min)
		GlobalSettings.setDifficultyScaling(self.difficulty.start + self.difficultyModifier, self.difficulty.coalition)
		self.lastDiffChange = timer.getAbsTime()
		env.info('increasing diff: '..self.difficultyModifier)
	end
	
	function BattleCommander:decreaseDifficulty()
		self.difficultyModifier = math.min(self.difficultyModifier+self.difficulty.fade, self.difficulty.max)
		GlobalSettings.setDifficultyScaling(self.difficulty.start + self.difficultyModifier,self.difficulty.coalition)
		self.lastDiffChange = timer.getAbsTime()
		env.info('decreasing diff: '..self.difficultyModifier)
	end
	
	--end difficulty scaling
	
	-- shops and currency functions
	function BattleCommander:registerShopItem(id, name, cost, action, altAction)
		self.shopItems[id] = { name=name, cost=cost, action=action, altAction = altAction }
	end
	
	function BattleCommander:addShopItem(coalition,id,ammount,prio)
		local item  = self.shopItems[id]
		local sitem = self.shops[coalition][id]
		if item then
			if sitem then
				if ammount == -1 then
					sitem.stock = -1
				else
					sitem.stock = sitem.stock+ammount
				end
				if prio then sitem.prio = prio end
			else
				self.shops[coalition][id] = {name=item.name,cost=item.cost,stock=ammount,prio=prio}
				self:refreshShopMenuForAllGroupsInCoalition(coalition)
			end
		end
	end
	
	function BattleCommander:removeShopItem(coalition, id)
		self.shops[coalition][id] = nil
		self:refreshShopMenuForAllGroupsInCoalition(coalition)
	end
	
	function BattleCommander:addFunds(coalition, ammount)
		local newAmmount = math.max(self.accounts[coalition] + ammount,0)
		if self.creditsCap then
			newAmmount = math.min(newAmmount, self.creditsCap)
		end
		
		self.accounts[coalition] = newAmmount
	end
	
	function BattleCommander:printDailyTop(unitid, top)
		self.sessionStats = self.sessionStats or {}
		local list = {}
		for name, stats in pairs(self.sessionStats) do
			list[#list+1] = {name, stats['Points'] or 0}
		end
		table.sort(list, function(a,b) return a[2] > b[2] end)
		local n = top or 5
		local msg = '[Top '..n..' today]'
		local c = 0
		for i,v in ipairs(list) do
			c = c + 1
			if c > n then break end
			msg = msg..'\n\n'..i..'. ['..v[1]..']\nPoints: '..v[2]
		end
		if unitid then
			trigger.action.outTextForUnit(unitid, msg, 10)
		else
			trigger.action.outText(msg, 10)
		end
	end


	function BattleCommander:printShopStatus(groupID, coalition)
		-- backward-compat: if only one argument was supplied it is the coalition
		if coalition == nil then
			coalition = groupID
			groupID   = nil
		end

		local text = 'Credits: '..self.accounts[coalition]
		if self.creditsCap then
			text = text..'/'..self.creditsCap
		end

		text = text..'\n'
		local sorted = {}
		for i, v in pairs(self.shops[coalition]) do
			sorted[#sorted + 1] = {i, v}
		end
		table.sort(sorted, function(a, b) return a[2].name < b[2].name end)

		for _, item in ipairs(sorted) do
			local v = item[2]
			text = text..'\n[Cost: '..v.cost..'] '..v.name
			if v.stock ~= -1 then
				text = text..' [Available: '..v.stock..']'
			end
		end

		if self.playerContributions[coalition] then
			local header = false
			for player, credits in pairs(self.playerContributions[coalition]) do
				if credits > 0 then
					if not header then
						text = text..'\n\nUnclaimed credits'
						header = true
					end
					text = text..'\n '..player..' ['..credits..']'
				end
			end
		end

		if groupID then
			trigger.action.outTextForGroup(groupID, text, 30)
		else
			trigger.action.outTextForCoalition(coalition, text, 10)
		end
	end
	
function BattleCommander:debit(coalition, amount, buyerGroupId, buyerGroupObj, reason)
    if not amount or amount <= 0 then return true end
    local buyerName = "Unknown"
    if buyerGroupId and self.playerNames and self.playerNames[buyerGroupId] then
        buyerName = self.playerNames[buyerGroupId]
    elseif buyerGroupObj and buyerGroupObj.isExist and buyerGroupObj:isExist() and buyerGroupObj.getName then
        buyerName = buyerGroupObj:getName()
    elseif buyerGroupId then
        buyerName = "Group " .. tostring(buyerGroupId)
    end
	local cleanReason = reason or "CTLD action"
	cleanReason = cleanReason:gsub("%s*%([^%)]*cr[^%)]*%)", "")
	cleanReason = cleanReason:gsub("%s*%[[^%]]+%]$", "")
    self.accounts[coalition] = tonumber(self.accounts[coalition]) or 0
    if self.accounts[coalition] < amount then
        local msg = string.format("Not enough credits for %s. Need %d, have %d.", cleanReason or "this action", amount, self.accounts[coalition])
        if buyerGroupId then
            trigger.action.outTextForGroup(buyerGroupId, msg, 12)
        else
            trigger.action.outTextForCoalition(coalition, msg, 12)
        end
        return false
    end
    self.accounts[coalition] = math.max(0, self.accounts[coalition] - amount)
    self:addStat(buyerName, "Points spent", amount)
	trigger.action.outTextForCoalition(coalition, string.format("%s spent %d credits on CTLD %s.\n\n%d coalition credits remaining.", buyerName, amount, cleanReason, self.accounts[coalition]), 12)
    return true
end
function BattleCommander:credit(coalition, amount, buyerGroupId, reason)
    if not amount or amount <= 0 then return true end
    self.accounts[coalition] = tonumber(self.accounts[coalition]) or 0
    self.accounts[coalition] = self.accounts[coalition] + amount
	local clean = (reason or "refund"):gsub("%s*%([^%)]*cr[^%)]*%)",""):gsub("%s*%[[^%]]+%]$","")
	if buyerGroupId then
        trigger.action.outTextForGroup(buyerGroupId, string.format("%s returned to base — %d credits refunded.", clean, amount), 12)
	else
		trigger.action.outTextForCoalition(coalition, string.format("%s returned to base — %d credits refunded.", clean, amount), 12)
	end
    return true
end
function BattleCommander:buyShopItem(coalition,id,alternateParams,buyerGroupId,buyerGroupObj)
			local item   = self.shops[coalition][id]
			local shop   = self.shops[coalition]
			local player = buyerGroupObj and buyerGroupObj:isExist() and buyerGroupObj:getName() or nil
			local pname  = buyerGroupId and (self.playerNames and self.playerNames[buyerGroupId] or player or ("Group "..tostring(buyerGroupId))) or nil
			local earned = pname and self.playerStats and self.playerStats[pname] and self.playerStats[pname]["Points"] or 0
			local exempt = pname == "[MA] Leka"

		if not item then
			if buyerGroupId then
				trigger.action.outTextForGroup(buyerGroupId,"Item not found in shop",5)
			else
				trigger.action.outTextForCoalition(coalition,"Item not found in shop",5)
			end
			return
		end
		if StoreLimit == true then
			if item.cost > 250 and buyerGroupId and not exempt and earned < 100 then
				trigger.action.outTextForGroup(buyerGroupId,"You need to earn at least 100 personal credits first, "..pname.." to increase in rank.",20)
				return
			end
			if item.cost > 1000 and buyerGroupId and not exempt and earned < 1000 then
				trigger.action.outTextForGroup(buyerGroupId,"You need to earn at least 1000 personal credits first, "..pname.." to increase in rank.",20)
				return
			end
			if item.cost > 2000 and buyerGroupId and not exempt and earned < 2000 then
				trigger.action.outTextForGroup(buyerGroupId,"You need to earn at least 2000 personal credits first, "..pname.." to increase in rank.",20)
				return
			end
			if item.cost > 3000 and buyerGroupId and not exempt and earned < 3000 then
				trigger.action.outTextForGroup(buyerGroupId,"You need to earn at least 3000 personal credits first, "..pname.." to increase in rank.",20)
				return
			end
		end
		if id == 'supplies' or id == 'supplies2' then
			local allUpgraded = true
			for _, zone in pairs(self:getZones()) do
				if zone.side == 2 then
					local upgradeCount = Utils.getTableSize(zone.built)
					local totalUpgrades = #zone.upgrades.blue
					if upgradeCount < totalUpgrades then
						allUpgraded = false
						break
					end
					for _, grpName in pairs(zone.built) do
						local gr = Group.getByName(grpName)
						if not gr or gr:getCoalition() ~= 2 or gr:getSize() < gr:getInitialSize() then
							allUpgraded = false
							break
						end
					end
				end
			end
			if allUpgraded then
				if buyerGroupId then
					trigger.action.outTextForGroup(buyerGroupId, "All zones are fully upgraded! No resupply is needed.", 10)
				else
					trigger.action.outTextForCoalition(coalition, "All zones are fully upgraded! No resupply is needed.", 10)
				end
				return
			end
		end

		if id == 'capture' then
			local foundAny = false
			for _, v in ipairs(self:getZones()) do
				if v.active and v.side == 0 and (not v.NeutralAtStart or v.firstCaptureByRed)
				   and not v.zone:lower():find("hidden")
				then
					foundAny = true
					break
				end
			end
			if not foundAny then
				if buyerGroupId then
					trigger.action.outTextForGroup(buyerGroupId, "No valid neutral zones found", 15)
				else
					trigger.action.outTextForCoalition(coalition, "No valid neutral zones found", 15)
				end
				return
			end
		end

		if self.accounts[coalition] < item.cost then
			if buyerGroupId then
				trigger.action.outTextForGroup(buyerGroupId, "Not enough credits for ["..item.name.."]", 5)
			else
				trigger.action.outTextForCoalition(coalition, "Can not afford ["..item.name.."]", 5)
			end
			return
		end

		if item.stock ~= -1 and item.stock <= 0 then
			if buyerGroupId then
				trigger.action.outTextForGroup(buyerGroupId, "["..item.name.."] out of stock", 5)
			else
				trigger.action.outTextForCoalition(coalition, "["..item.name.."] out of stock", 5)
			end
			return
		end

		local success = true
		local sitem = self.shopItems[id]
		if alternateParams ~= nil and type(sitem.altAction) == 'function' then
			success = sitem:altAction(alternateParams)
		elseif type(sitem.action) == 'function' then
			success = sitem:action()
		end

		if success == true or success == nil then
			self.accounts[coalition] = self.accounts[coalition] - item.cost
			if item.stock > 0 then
				item.stock = item.stock - 1
			end
			if item.stock == 0 then
				self.shops[coalition][id] = nil
			end

			if buyerGroupId then
				local buyerName = "Group " .. tostring(buyerGroupId)
				if self.playerNames and self.playerNames[buyerGroupId] then
					buyerName = self.playerNames[buyerGroupId]
				elseif buyerGroupObj and buyerGroupObj:isExist() then
					buyerName = buyerGroupObj:getName()
				end
				self:addStat(buyerName, "Points spent", item.cost)
				trigger.action.outTextForCoalition(
				  coalition,
				  buyerName.." bought:\n["..item.name.."] for "..item.cost.." credits.\n"..self.accounts[coalition].." credits remaining.",5)
				if item.stock == 0 then
					trigger.action.outTextForCoalition(coalition, "["..item.name.."] went out of stock", 5)
				end
			else
				trigger.action.outTextForCoalition(
					coalition,
					"Bought ["..item.name.."] for "..item.cost.."\n"..
					self.accounts[coalition].." credits remaining",
					5
				)
				if item.stock == 0 then
					trigger.action.outTextForCoalition(coalition, "["..item.name.."] went out of stock", 5)
				end
			end

		else
			if type(success) == 'string' then
				if buyerGroupId then
					trigger.action.outTextForGroup(buyerGroupId, success, 5)
				else
					trigger.action.outTextForCoalition(coalition, success, 5)
				end
			else
				if buyerGroupId then
					trigger.action.outTextForGroup(buyerGroupId, 'Not available at the current time', 5)
				else
					trigger.action.outTextForCoalition(coalition, 'Not available at the current time', 5)
				end
			end
			return success
		end
	end

	

function BattleCommander:refreshShopMenuForGroup(groupId, groupObj)
	if not groupObj or not groupObj:isExist() then return end
	local coalition = groupObj:getCoalition()
	if not self.groupSupportMenus[groupId] then
		self.groupSupportMenus[groupId] = {menu = missionCommands.addSubMenuForGroup(groupId,"Support"), items = {}}
	end
	local parent   = self.groupSupportMenus[groupId].menu
	local oldItems = self.groupSupportMenus[groupId].items
	for _,h in ipairs(oldItems) do missionCommands.removeItemForGroup(groupId,h) end
	self.groupSupportMenus[groupId].items = {}
	local track   = self.groupSupportMenus[groupId].items
	local shopData = self.shops[coalition]
	if not shopData then return end
	local sorted = {}
	for id,data in pairs(shopData) do sorted[#sorted+1] = {id=id,data=data} end
	table.sort(sorted,function(a,b)
		local pa=a.data.prio or 999
		local pb=b.data.prio or 999
		if pa~=pb then return pa<pb end
		return a.data.name<b.data.name
	end)
	local count, subMenu = 0, nil
	for _,info in ipairs(sorted) do
		count = count + 1
		local label = "["..info.data.cost.."] "..info.data.name
		local tgt
		if count < 10 then
			tgt = parent
		elseif count == 10 then
			subMenu = missionCommands.addSubMenuForGroup(groupId,"More",parent)
			track[#track+1] = subMenu
			tgt = subMenu
		elseif count % 9 == 1 then
			subMenu = missionCommands.addSubMenuForGroup(groupId,"More",subMenu)
			track[#track+1] = subMenu
			tgt = subMenu
		else
			tgt = subMenu
		end
		local h = missionCommands.addCommandForGroup(groupId,label,tgt,self.buyShopItem,self,coalition,info.id,nil,groupId,groupObj)
		track[#track+1] = h
	end
end

	
	function BattleCommander:addMonitoredROE(groupname)
		table.insert(self.monitorROE, groupname)
	end
	
	function BattleCommander:checkROE(groupname)
		local gr = Group.getByName(groupname)
		if gr then
			local controller = gr:getController()
			if controller:hasTask() then
				controller:setOption(0, 2) -- roe = open fire
			else
				controller:setOption(0, 4) -- roe = weapon hold
			end
		end
	end


function BattleCommander:showTargetZoneMenu(coalition, menuname, action, targetzoneside, showUpgradeStatus,allow)
    local executeAction = function(act, params)
        local err = act(params.zone, params.menu) 
        if not err then
            if params.zone and not self:getZoneByName(params.zone).fullyUpgraded then
                missionCommands.removeItemForCoalition(params.coalition, params.menu)
            end
        end
    end

    local menu = missionCommands.addSubMenuForCoalition(coalition, menuname)
    local sub1
    local zones = bc:getZones()
    local count = 0
	
     local cand = {}
    for i, v in ipairs(zones) do
        if (not v.zone:lower():find("hidden")) and (targetzoneside == nil or v.side == targetzoneside) and (not allow or allow[v.zone]) and (not v.suspended) then
            local suf   = WaypointList[v.zone]
            local wpNum = suf and tonumber(suf:match("%d+"))
            cand[#cand+1] = {z = v, wp = wpNum}
        end
    end
	table.sort(cand,function(a,b)
			if a.wp and b.wp       then return a.wp < b.wp end
			if a.wp                then return true        end
			if b.wp                then return false       end
			return a.z.zone < b.z.zone
	end)

    count = 0
    for _, wrap in ipairs(cand) do
        local v   = wrap.z
        local zoneDisplayName = wrap.wp and (v.zone .. WaypointList[v.zone]) or v.zone
        if showUpgradeStatus and v.side == 2 then
            local upgradeCount     = 0
            local totalUpgrades    = #v.upgrades.blue
            for _, builtUnit in pairs(v.built) do
                local gr = Group.getByName(builtUnit)
                if gr and gr:getCoalition() == 2 and gr:getSize() == gr:getInitialSize() then
                    upgradeCount = upgradeCount + 1
                end
            end
            zoneDisplayName = zoneDisplayName .. " " .. upgradeCount .. "/" .. totalUpgrades
        end

        count = count + 1
        if count < 10 then
            missionCommands.addCommandForCoalition(coalition, zoneDisplayName, menu, executeAction, action, {zone = v.zone, menu = menu, coalition = coalition})
        elseif count == 10 then
            sub1 = missionCommands.addSubMenuForCoalition(coalition, "More", menu)
            missionCommands.addCommandForCoalition(coalition, zoneDisplayName, sub1, executeAction, action, {zone = v.zone, menu = menu, coalition = coalition})
        elseif count % 9 == 1 then
            sub1 = missionCommands.addSubMenuForCoalition(coalition, "More", sub1)
            missionCommands.addCommandForCoalition(coalition, zoneDisplayName, sub1, executeAction, action, {zone = v.zone, menu = menu, coalition = coalition})
        else
            missionCommands.addCommandForCoalition(coalition, zoneDisplayName, sub1, executeAction, action, {zone = v.zone, menu = menu, coalition = coalition})
        end
    end

    return menu
end

	function BattleCommander:showEmergencyNeutralZoneMenu(coalition, menuname, callback)
	if not coalition then coalition = 2 end
		local menu = missionCommands.addSubMenuForCoalition(coalition, menuname)
		for _, v in ipairs(self.zones) do
			if v.active and v.side == 0 and (not v.NeutralAtStart or v.firstCaptureByRed or v.suspended)
			   and not v.zone:lower():find("hidden")
			then
				missionCommands.addCommandForCoalition(coalition, v.zone, menu, callback, v.zone)
			end
		end
		return menu
	end
	
	function findNearestAvailableSupplyCommander(chosenZone)
		local best=nil
		local bestDist=99999999
		local inProgressForZone=false
		for _,zC in ipairs(bc.zones) do
			if zC.side==2 and zC.active then
				for _,grpCmd in ipairs(zC.groups) do
					if grpCmd.mission=='supply' and grpCmd.side==2 and not grpCmd.suspended then
						local heloOk = (grpCmd.unitCategory==Unit.Category.HELICOPTER)
						if not heloOk and grpCmd._tplBySide and grpCmd._tplBySide[2] and #grpCmd._tplBySide[2]>0 then
							local tn=grpCmd._tplBySide[2][1]; local gr=Group.getByName(tn); if gr then local u=gr:getUnit(1); if u and u:getDesc().category==Unit.Category.HELICOPTER then heloOk=true end end
						end
						if heloOk and grpCmd.targetzone==chosenZone.zone then
							local st=grpCmd.state
							if st=='takeoff' or st=='inair' or st=='landed' or st=='enroute' or st=='atdestination' then
								inProgressForZone=true
							elseif st=='dead' or st=='inhangar' or st=='preparing' then
								local znA = zC.zone
								local znB = chosenZone.zone
								local dist = ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB] or 99999999
								if dist<bestDist then
									bestDist=dist
									best=grpCmd
								end
							end
						end
					end
				end
			end
		end
		if not best and inProgressForZone then
			return nil,'inprogress'
		end
		return best,nil
	end


function measureDistanceZoneToZone(zoneA,zoneB)

	local czA=CustomZone:getByName(zoneA.zone)
	local czB=CustomZone:getByName(zoneB.zone)
	
	if not czA or not czB then return 99999 end
	
	return UTILS.VecDist2D({x=czA.point.x,y=czA.point.z},{x=czB.point.x,y=czB.point.z})
end

	function BattleCommander:getRandomSurfaceUnitInZone(tgtzone, myside)
		local zn = self:getZoneByName(tgtzone)
		
		local selectedUnit = nil
		
		local units = {}
		for _,v in pairs(zn.built) do
			local g = Group.getByName(v)
			if g and g:getCoalition() ~= myside then
				for _,unit in ipairs(g:getUnits()) do
					table.insert(units, unit)
				end
			end
		end
		
		for _,v in ipairs(zn.groups) do
			local g = Group.getByName(v.name)
			
			if g and v.type == 'surface' and v.side ~= myside then
				for _,unit in ipairs(g:getUnits()) do
					table.insert(units, unit)
				end
			end
		end
			
		if #units > 0 then
		 return units[math.random(1, #units)]
		end
	end
	
	function BattleCommander:moveToUnit(tgtunitname, groupname)
		timer.scheduleFunction(function(params, time)
			local group = Group.getByName(params.groupname)
			local unit = Unit.getByName(params.tgtunitname)
			
			if not group or not unit then return end -- do not recalculate route, either target or hunter stopped existing
			
			local pos = unit:getPoint()
			local cnt = group:getController()
			local task = {
				id = "Mission",
				params = {
					airborne = false,
					route = {
						points = {
							[1] = { 
								type=AI.Task.WaypointType.TURNING_POINT, 
								action=AI.Task.TurnMethod.FLY_OVER_POINT,
								speed = 100, 
								x = pos.x + math.random(-100,100), 
								y = pos.z + math.random(-100,100)
							}
						}
					}
				}
			}
			
			cnt:setTask(task)
			return time+50
		end, {tgtunitname = tgtunitname, groupname = groupname}, timer.getTime() + 2)
	end
	
	
	function BattleCommander:startHuntUnitsInZone(tgtzone, groupname)
		if not self.huntedunits then self.huntedunits = {} end
		
		timer.scheduleFunction(function(param, time)
			local group = Group.getByName(param.group)
			
			if not group then 
				param.context.huntedunits[param.group] = nil
				return -- group stopped existing, shut down the hunt
			end
			
			local huntedunit = param.context.huntedunits[param.group]
			if huntedunit and Unit.getByName(huntedunit) then return time+60 end -- hunted unit still exists, check again in a minute
		
			local tgtunit = param.context:getRandomSurfaceUnitInZone(param.zone, group:getCoalition())
			if tgtunit then
				param.context.huntedunits[param.group] = tgtunit:getName()
				param.context:moveToUnit(tgtunit:getName(), param.group)
				return time+120 -- new unit selected, check again in 2 minutes if we should select a new one
			else
				return time+600 -- no unit in zone, try again in 10 minutes
			end
					
		end, {context = self, zone = tgtzone, group = groupname}, timer.getTime()+2)
	end

	function BattleCommander:engageSead(tgtzone, groupname, expendAmmount, weapon)
		local zn = self:getZoneByName(tgtzone)
		local group = Group.getByName(groupname)
		if zn.suspended then
			if group and group:isExist() then group:destroy() end
			return
		end
		if group and zn.side == group:getCoalition() then
			return 'Can not engage friendly zone'
		end
		if not group then
			return 'Not available'
		end
		local cnt=group:getController()
		cnt:popTask()
		local expCount = AI.Task.WeaponExpend.ALL
		if expendAmmount then
			expCount = expendAmmount
		end
		
		local wepType = Weapon.flag.AnyWeapon
		if weapon then
			wepType = weapon
		end
		for _,v in pairs(zn.built) do
			local g=Group.getByName(v)
			if g then
				for _,u in ipairs(g:getUnits()) do
					if u:hasAttribute('SAM SR') or u:hasAttribute('SAM TR') or u:hasAttribute('IR Guided SAM') then
						local task={
							id='AttackUnit',
							params={
								unitId=u:getID(),
								expend=expCount,
								weaponType=wepType,
								groupAttack=false
							}
						}
						cnt:pushTask(task)
					else
						local task={
							id='AttackGroup',
							params={
								groupId=g:getID(),
								expend=expCount,
								weaponType=wepType,
								groupAttack=false
							}
						}
						cnt:pushTask(task)
					end
				end
			end
		end
	end

	function BattleCommander:engageZone(tgtzone, groupname, expendAmmount, weapon)
		local zn = self:getZoneByName(tgtzone)
		local group = Group.getByName(groupname)
		if zn.suspended then
			if group and group:isExist() then group:destroy() end
			return
		end
		if group and zn.side == group:getCoalition() then
			return 'Can not engage friendly zone'
		end
		
		if not group then
			return 'Not available'
		end
		
		local cnt = group:getController()
		cnt:popTask()
		
		local expCount = AI.Task.WeaponExpend.ONE
		if expendAmmount then
			expCount = expendAmmount
		end
		
		local wepType = Weapon.flag.AnyWeapon
		if weapon then
			wepType = weapon
		end
		
		-- Build up a table of tasks we want to perform.
		local tasks = {}
		for _, v in pairs(zn.built) do
			local g = Group.getByName(v)
			if g then
				table.insert(tasks, {
					id = 'AttackGroup',
					params = {
						groupId     = g:getID(),
						expend      = expCount,
						weaponType  = wepType,
						groupAttack = false
					}
				})
			end
			
			local s = StaticObject.getByName(v)
			if s then
				table.insert(tasks, {
					id = 'AttackUnit',
					params = {
						unitId      = s:getID(),
						expend      = expCount,
						weaponType  = wepType,
						groupAttack = false
					}
				})
			end
		end
		if #tasks > 0 then
			local comboTask = {
				id = 'ComboTask',
				params = {
					tasks = tasks
				}
			}
			cnt:pushTask(comboTask)
		end
	end

	function BattleCommander:carpetBombRandomUnitInZone(tgtzone, groupname)
		local zn = self:getZoneByName(tgtzone)
		local group = Group.getByName(groupname)
		if zn.suspended then
			if group and group:isExist() then group:destroy() end
			return
		end
		if group and zn.side == group:getCoalition() then
			return 'Can not engage friendly zone'
		end
		
		if not group then
			return 'Not available'
		end
		
		local cnt=group:getController()
		cnt:popTask()
		local viabletgts = {}
		for i,v in pairs(zn.built) do
			if not zn.suspended then
				local g = Group.getByName(v)
				if g then
					for i2,v2 in ipairs(g:getUnits()) do
						table.insert(viabletgts, v2)
					end
				else
					local s = StaticObject.getByName(v)
					if s then
						table.insert(viabletgts,s)
					end
				end
			end
		end
		if #viabletgts == 0 then
			return 'No targets found within zone'
		end
		
		local choice = viabletgts[math.random(1,#viabletgts)]
		local p = choice:getPoint()
		local task = { 
		  id = 'CarpetBombing', 
		  params = { 
			attackType = 'Carpet',
			carpetLength = 1000,
			expend = AI.Task.WeaponExpend.ALL,
			weaponType = Weapon.flag.AnyUnguidedBomb,
			groupAttack = true,
			attackQty = 1,
			altitudeEnabled = true,
			altitude = 7000,
			point = {x=p.x, y=p.z}
		  } 
		}
		cnt:pushTask(task)
	end
	
	function BattleCommander:jamRadarsAtZone(groupname, zonename)
		local gr = Group.getByName(groupname)
		local zn = self:getZoneByName(zonename)
		if zn.suspended then 
			if gr and gr:isExist() then gr:destroy() end
			return 
		end
		if not gr then return 'EW group dead' end
		if not zn then return 'Zone not found' end
		if zn.side == gr:getCoalition() then return 'Can not jam friendly zone' end
		
		timer.scheduleFunction(function (param, time)
			local gr = Group.getByName(param.ewgroup)
			local zn = param.context:getZoneByName(param.target)
			if not Utils.isGroupActive(gr) or zn.side == gr:getCoalition() then
				for i,v in pairs(zn.built) do
					local g = Group.getByName(v)
					if g then
						for i2,v2 in ipairs(g:getUnits()) do
							if v2:hasAttribute('SAM SR') or v2:hasAttribute('SAM TR') then
								v2:getController():setOption(0,2)
								v2:getController():setOption(9,2)
							end
						end
					end
				end
				return nil
			else
				for i,v in pairs(zn.built) do
					local g = Group.getByName(v)
					if g then
						for i2,v2 in ipairs(g:getUnits()) do
							if v2:hasAttribute('SAM SR') or v2:hasAttribute('SAM TR') then
								v2:getController():setOption(0,4)
								v2:getController():setOption(9,1)
							end
						end
					end
				end
			end
			
			return time+10
		end, {ewgroup = groupname, target = zonename, context = self}, timer.getTime()+10)
	end
	
	function BattleCommander:startFiringAtZone(groupname, zonename, minutes)
		timer.scheduleFunction(function(param, time)
			local gr = Group.getByName(param.group)
			local abu = param.context:getZoneByName(param.zone)
			if abu and abu.suspended then 
				if gr and gr:isExist() then gr:destroy() end
				return nil 
			end
			
			if not abu or abu.side ~= 2 then return nil end
			if not gr then return nil end
			
			param.context:fireAtZone(abu.zone, param.group, true, 1, 50)
			return time+(param.period*60)
			
		end, {group = groupname, zone = zonename, context=self, period = minutes}, timer.getTime()+5)
	end
	
	function BattleCommander:fireAtZone(tgtzone, groupname, precise, ammount, ammountPerTarget)
		local zn = self:getZoneByName(tgtzone)
		local launchers = Group.getByName(groupname)
		if zn.suspended then 
			if launchers and launchers:isExist() then launchers:destroy() end
			return 
		end 
		if precise == nil then precise = true end
		if launchers and zn.side == launchers:getCoalition() then
			return 'Can not launch attack on friendly zone'
		end
		
		if not launchers then
			return 'Not available'
		end
		
		if ammountPerTarget==nil then
			ammountPerTarget = 1
		end
		
		if precise then
			local units = {}
			for i,v in pairs(zn.built) do
				local g = Group.getByName(v)
				if g then
					for i2,v2 in ipairs(g:getUnits()) do
						table.insert(units, v2)
					end
				else
					local s = StaticObject.getByName(v)
					if s then
						table.insert(units, s)
					end
				end
			end
			
			if #units == 0 then
				return 'No targets found within zone'
			end
			
			local selected = {}
			for i=1,ammount,1 do
				if #units == 0 then 
					break
				end
				
				local tgt = math.random(1,#units)
				
				table.insert(selected, units[tgt])
				table.remove(units, tgt)
			end
			
			while #selected < ammount do
				local ind = math.random(1,#selected)
				table.insert(selected, selected[ind])
			end
			
			for i,v in ipairs(selected) do
				local unt = v
				if unt then
					local target = {}
					target.x = unt:getPosition().p.x
					target.y = unt:getPosition().p.z
					target.radius = 50
					target.expendQty = ammountPerTarget
					target.expendQtyEnabled = true
					local fire = {id = 'FireAtPoint', params = target}
					
					launchers:getController():pushTask(fire)
				end
			end
		else
			local tz = CustomZone:getByName(zn.zone)
			local target = {}
			target.x = tz.point.x
			target.y = tz.point.y
			target.radius = tz.radius
			target.expendQty = ammount
			target.expendQtyEnabled = true
			local fire = {id = 'FireAtPoint', params = target}
			
			local launchers = Group.getByName(groupname)
			launchers:getController():pushTask(fire)
		end
	end
	
function BattleCommander:getStateTable()
    local states = {zones = {}, accounts = {}}
    
    for i,v in ipairs(self.zones) do
        local unitTable = {}
        for i2,v2 in pairs(v.built) do
            unitTable[i2] = {}
            local gr = Group.getByName(v2)
            if gr then
                for i3,v3 in ipairs(gr:getUnits()) do
                    table.insert(unitTable[i2], v3:getDesc().typeName)
                end
            end
        end
        if v.wasBlue then v.firstCaptureByRed = true end
        if v.side == 1 or v.side == 2 or not v.active then v.firstCaptureByRed = true end
        states.zones[v.zone] = {
            side              = v.side,
            level             = Utils.getTableSize(v.built),
            remainingUnits    = unitTable,
            destroyed         = v:getDestroyedCriticalObjects(),
            active            = v.active,
            triggers          = {},
            wasBlue           = v.wasBlue or false,
            firstCaptureByRed = v.firstCaptureByRed or false,
            upgradesUsed      = v.upgradesUsed,
			extraUpgrade      = v.extraUpgrade
        }
        for i2,v2 in ipairs(v.triggers) do
            if v2.id then states.zones[v.zone].triggers[v2.id] = v2.hasRun end
        end
        if v.triggers['FriendlyDestroyed'] then
            states.zones[v.zone].triggers['FriendlyDestroyed'] = true
        end
    end

    states.accounts = self.accounts
    states.difficultyModifier = self.difficultyModifier

    local shopState = {}
    for side,items in pairs(self.shops) do
        shopState[side] = {}
        for id,data in pairs(items) do
            if data.stock ~= -1 then
                shopState[side][id] = data
            end
        end
    end
    states.shops = shopState

    states.playerStats = {}
    if self.playerStats then
        for n,val in pairs(self.playerStats) do
            local s = n:gsub("\\","\\\\"):gsub("'","\\'")
            states.playerStats[s] = val
        end
    end
    return states
end


	
	function BattleCommander:getZoneOfUnit(unitname)
		local un = Unit.getByName(unitname)
		
		if not un then 
			return nil
		end
		
		for i,v in ipairs(self.zones) do
			if Utils.isInZone(un, v.zone) then
				return v
			end
		end
		
		return nil
	end
	function BattleCommander:getZoneOfGroup(groupName)
		local gr = Group.getByName(groupName)
		if gr and gr:isExist() then
			local unit = gr:getUnit(1)
			if unit then
				local point = unit:getPoint()
				for i,v in ipairs(self.zones) do
					if Utils.isInZone(unit, v.zone) then
						return v
					end
				end
			end
		end
		return nil
	end
	function BattleCommander:getZoneOfWeapon(weapon)
		if not weapon then 
			return nil
		end
		
		for i,v in ipairs(self.zones) do
			if Utils.isInZone(weapon, v.zone) then
				return v
			end
		end
		
		return nil
	end
	
	function BattleCommander:getZoneOfPoint(point)
		for i,v in ipairs(self.zones) do
			local z = CustomZone:getByName(v.zone)
			if z and z:isInside(point) then
				return v
			end
		end
		
		return nil
	end
	
	function BattleCommander:addZone(zone)
			table.insert(self.zones, zone)
			zone.index = self:getZoneIndexByName(zone.zone)+3000
			zone.battleCommander = self
			self.indexedZones[zone.zone] = zone
			self:refreshConnectionCache()
	end

	function BattleCommander:getZoneByName(name)
			return self.indexedZones[name]
	end

	function BattleCommander:_cacheConnectionZones(connection)
			if not connection then return end
			connection.fromZone = self:getZoneByName(connection.from)
			connection.toZone = self:getZoneByName(connection.to)
	end

	function BattleCommander:refreshConnectionCache()
			for _, connection in ipairs(self.connections) do
					self:_cacheConnectionZones(connection)
			end
	end

	function BattleCommander:getConnectionZones(connection)
			if not connection then return nil end
			local fromZone, toZone = connection.fromZone, connection.toZone
			if not fromZone or not toZone or fromZone.zone ~= connection.from or toZone.zone ~= connection.to then
					self:_cacheConnectionZones(connection)
					fromZone, toZone = connection.fromZone, connection.toZone
			end
			return fromZone, toZone
	end

	function BattleCommander:addConnection(f, t)
			local connection = {from=f, to=t}
			self:_cacheConnectionZones(connection)
			table.insert(self.connections, connection)
	end
	
	function BattleCommander:getZoneIndexByName(name)
		for i,v in ipairs(self.zones) do
			if v.zone == name then
				return i
			end
		end
	end
	
	function BattleCommander:getZones()
		return self.zones
	end
	
	function BattleCommander:initializeRestrictedGroups()
		for i,v in pairs(_DATABASE.Templates.Groups) do
			local t=v.Template
			if t.units[1].skill=='Client' then
				for i2,v2 in ipairs(self.zones) do
					local zn=CustomZone:getByName(v2.zone)
					local pos3d={x=t.units[1].x,y=0,z=t.units[1].y}
					if zn and zn:isInside(pos3d) then
						local coa=0
						if t.CoalitionID==coalition.side.BLUE then
							coa=2
						elseif t.CoalitionID==coalition.side.RED then
							coa=1
						end
						v2:addRestrictedPlayerGroup({name=t.name,side=coa})
					end
				end
			end
		end
	end

	function shuffleTable(tbl)
		for i = #tbl, 2, -1 do
			local j = math.random(1, i)
			tbl[i], tbl[j] = tbl[j], tbl[i]
		end
	end




	local getRoadPt = land.getClosestPointOnRoads
	local function isRoadClose(pt,limit)
		local rx,rz = getRoadPt('roads',pt.x,pt.z)
		if not rx then return false end
		local dx, dz = pt.x-rx, pt.z-rz
		return dx*dx + dz*dz <= (limit or 1000)^2
	end

	SUBZONE_NEAR_ROAD = {}
	ZONE_VALID_SUBZONES = {}
	function buildSubZoneRoadCache()
		for _, zone in ipairs(bc.zones) do
			local zn = zone.zone
			ZONE_VALID_SUBZONES[zn] = {}
			local j = 1
			while true do
				local subName = zn .. "-" .. j
				local center = getZoneCenter(subName)
				if not center then break end
				local px, pz = center.x, center.y
				local roadClose = isRoadClose({x = px, z = pz},1000)
				SUBZONE_NEAR_ROAD[subName] = roadClose and true or false
				if roadClose then
						local st = land.getSurfaceType({x = px, y = pz})
						if st == 1 or st == 4 then
								table.insert(ZONE_VALID_SUBZONES[zn], subName)
						end
					end
					j = j + 1
				end
			end
        end

	ZONE_CONNECTED_TO_BLUE = {}
	ZONE_CONNECTED_TO_RED  = {}
	ZONE_CONNECTED_BLUE_COUNT = {}
	function BattleCommander:buildConnectionMap()
    ZONE_CONNECTED_TO_BLUE = {}
    ZONE_CONNECTED_TO_RED  = {}
    ZONE_CONNECTED_BLUE_COUNT = {}
    self.connectionMap = {}
    self:refreshConnectionCache()
    for _, c in ipairs(self.connections or {}) do
        local fromZone, toZone = self:getConnectionZones(c)
        local from = c.from
        local to = c.to
        self.connectionMap[from] = self.connectionMap[from] or {}
        self.connectionMap[to]   = self.connectionMap[to]   or {}
        self.connectionMap[from][to] = true
        self.connectionMap[to][from] = true
        if fromZone and toZone then
            if fromZone.side == 2 then
                ZONE_CONNECTED_TO_BLUE[to] = true
                ZONE_CONNECTED_BLUE_COUNT[to] = (ZONE_CONNECTED_BLUE_COUNT[to] or 0) + 1
            end
            if toZone.side == 2 then
                ZONE_CONNECTED_TO_BLUE[from] = true
                ZONE_CONNECTED_BLUE_COUNT[from] = (ZONE_CONNECTED_BLUE_COUNT[from] or 0) + 1
            end
        end
    end

		ZONE_NEAR_BLUE = {}
		for _, zoneObj in ipairs(self.zones) do
			local znA = zoneObj.zone
			if zoneObj.side == 1 then
				local best = math.huge
				for _, zB in ipairs(self.zones) do
					if zB.side == 2 then
						local znB = zB.zone
						local d = ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB]
						if d and d < best then best = d end
					end
				end
				if best <= 50*1852 then ZONE_NEAR_BLUE[znA] = true end
			end
		end
	end

	function BattleCommander:buildZoneDistanceCache()
		for i = 1, #self.zones do
			local zoneA  = self.zones[i]
			local znA    = zoneA.zone
			ZONE_DISTANCES[znA] = ZONE_DISTANCES[znA] or {}
			for j = i, #self.zones do
				local zoneB = self.zones[j]
				local znB   = zoneB.zone
				local dist  = (i == j) and 0 or measureDistanceZoneToZone(zoneA, zoneB)
				ZONE_DISTANCES[znA][znB] = dist
				ZONE_DISTANCES[znB] = ZONE_DISTANCES[znB] or {}
				ZONE_DISTANCES[znB][znA] = dist
			end
		end
	end
	GROUP_ZONE_CACHE = {}
	ZONE_FRIENDLY_CACHE = {}
	function BattleCommander:roamGroupsToLocalSubZone(prefix, distanceNm,skip)
		local formations = {"Off Road","On Road","Cone","Diamond","Vee"}  
		local formationsTall = {"Off Road","Cone","Vee"}
		
		local liveSets={}
		if type(prefix)=="table" then
			for _,p in ipairs(prefix) do liveSets[p]=SET_GROUP:New():FilterPrefixes(p):FilterStart() end
		else
			liveSets[prefix]=SET_GROUP:New():FilterPrefixes(prefix):FilterStart()
		end

		local SkipZones = {}
		if type(skip)=="table" then
			for _,zn in pairs(skip) do SkipZones[zn]=true end
		end

		local currentZoneData
		local zonePtr = 1
		local rangeMeters = (distanceNm or 50)*1852
		local function isNearFriendlyZone(currentZone, rangeMeters)
			for _, testZone in ipairs(self.zones) do
				if testZone.side == 2 then
					local dist = ZONE_DISTANCES[currentZone.zone] and ZONE_DISTANCES[currentZone.zone][testZone.zone]
					if dist and dist <= rangeMeters then
						return true
					end
				end
			end
			return false
		end
	
		-- Finds how close a zone is to ANY friendly zone
		local function getCachedZoneDistanceToFriendly(self, zoneObj)
			local best = math.huge
			local znA = zoneObj.zone
			for _, zB in ipairs(self.zones) do
				if zB.side == 2 then
					local znB = zB.zone
					local d = ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB]
					if d and d < best then
						best = d
					end
				end
			end
			return best
		end

		local function collectGroups(prefixList,rangeMeters)
			local zoneGroups={}
			
			
			local function scanPrefix(thisPrefix)
					local set=liveSets[thisPrefix];if not set then return end
					set:ForEachGroup(function(PrefixGroups)
					local gName=PrefixGroups:GetName()
					local gr=Group.getByName(gName)
					if gr and gr:isExist() and gr:getSize()>0 then
						local pForms=(gr:getSize()>4) and formationsTall or formations
						local z = GROUP_ZONE_CACHE[gName]
						if not z then
							z = self:getZoneOfGroup(gName)
							if z then GROUP_ZONE_CACHE[gName] = z end
						end
						if z and not SkipZones[z.zone] then
							local zn=z.zone
							local zoneIsNear=ZONE_FRIENDLY_CACHE[zn]
							if zoneIsNear==nil then
								zoneIsNear = ZONE_CONNECTED_TO_BLUE[zn] or ZONE_NEAR_BLUE[zn] or false
								local count=ZONE_CONNECTED_BLUE_COUNT[zn] or 0
								if not zoneIsNear and count<3 then
									zoneIsNear=isNearFriendlyZone(z,rangeMeters)
								end
								ZONE_FRIENDLY_CACHE[zn] = zoneIsNear
							end
							if zoneIsNear then
								zoneGroups[zn]=zoneGroups[zn] or{}
								zoneGroups[zn][#zoneGroups[zn]+1]={gName=gName,ctrl=gr:getController(),formations=pForms}
							end
						end
					end
				end)
			end
			if type(prefixList)=="table" then
				for _,pfx in ipairs(prefixList) do scanPrefix(pfx) end
			else
				scanPrefix(prefixList)
			end
			return zoneGroups
		end
	
		local function buildCycleData()
			local zoneGroups = collectGroups(prefix,rangeMeters)
			local list = {}
			for zoneName,groupList in pairs(zoneGroups) do
				if not SkipZones[zoneName] then
					local zoneObj = self:getZoneByName(zoneName)
					if zoneObj then
						local d = getCachedZoneDistanceToFriendly(self, zoneObj)
						list[#list+1] = {zoneName=zoneName,groups=groupList,distance=d}
					end
				end
			end
			table.sort(list,function(a,b)return a.distance<b.distance end)
			local connected,other={},{}
			for _,it in ipairs(list) do
				if (ZONE_CONNECTED_BLUE_COUNT[it.zoneName] or 0)>0 then
					connected[#connected+1]=it
				else
					other[#other+1]=it
				end
			end
			local new={}
			for i=1,math.min(2,#connected) do new[#new+1]=connected[i] end
			for i=1,#other do new[#new+1]=other[i] end
			for i=3,#connected do new[#new+1]=connected[i] end
			currentZoneData = new
		end

		local function innerRoam()
			if not currentZoneData or zonePtr>#currentZoneData then return nil end
			local offset = 0
			local scheduledCount = 0


			local maxZonesToMove = 3
			local zoneCounter = 0
			while zonePtr<=#currentZoneData do
                local zData = currentZoneData[zonePtr]
                zonePtr = zonePtr + 1
				local zoneName = zData.zoneName
			  if not SkipZones[zoneName] then
                zoneCounter = zoneCounter + 1
				if zoneCounter > maxZonesToMove then
					break
				end
			  end
                local groupList = zData.groups
                local cz        = CustomZone:getByName(zoneName)
                if cz then
					cz.usedSpawnZones = cz.usedSpawnZones or {}
                    local totalGroups = #groupList
                    local moveCount   = math.random(1, math.min(3, totalGroups))
                    shuffleTable(groupList)
                    local chosenThisPass = {}
					for i = 1, moveCount do
						local gData   = groupList[i]
						local pick    = nil
						local cand    = cz:getRandomUnusedSpawnZone(false)
						if not cand then
							cand = cz:getRandomSpawnZone()
							if cand and USED_SUB_ZONES[cand] then cand = nil end
						end
						if not cand then
							cand = cz:getRandomSpawnZone()
						end
						if cand and not chosenThisPass[cand] then
							pick                          = cand
						end
						if not pick then
							local subZones = {}
							for j = 1, 100 do
								local sub = zoneName.."-"..j
								if not trigger.misc.getZone(sub) then break end
								if not chosenThisPass[sub] then
									subZones[#subZones+1] = sub
								end
							end
							if #subZones > 0 then
								pick = subZones[math.random(1,#subZones)]
							end
						end
					if pick then
						local grp2 = Group.getByName(gData.gName)
						if grp2 and grp2:isExist() and not (underAttack and underAttack[grp2:getID()]) then
							local p0 = grp2:getUnit(1):getPoint()
							local z = trigger.misc.getZone(pick)
							if z then
								local dest = {x = z.point.x, y = z.point.y, z = z.point.z}
								local directD = ((p0.x - dest.x)^2 + (p0.z - dest.z)^2)^0.5

								chosenThisPass[pick] = true
								USED_SUB_ZONES[pick] = true
                                local hopMax = math.min(1000, directD * 0.8)
                                local subz = nil
                                local main = bc:getZoneOfPoint(p0)
                                if main then
                                    for _, cand in ipairs(ZONE_VALID_SUBZONES[main.zone] or {}) do
                                        local cz = CustomZone:getByName(cand)
                                        if cz and cz:isInside(p0) then
                                            subz = cand
                                            break
                                        end
                                    end
                                end
                                local nearDestRoad  = SUBZONE_NEAR_ROAD[pick] or false
                                local nearStartRoad = subz and SUBZONE_NEAR_ROAD[subz] or isRoadClose(p0, hopMax * 1.5)
                                local tripLong      = directD > 700
                                local useRd         = (nearStartRoad or nearDestRoad) and tripLong
								local candForms = {}
								for _, f in ipairs(gData.formations) do
									if useRd or f ~= "On Road" then
										candForms[#candForms + 1] = f
									end
								end
								if #candForms == 0 then
									candForms[1] = "Off Road"
								end
								local form      = useRd and "On Road" or candForms[math.random(1, #candForms)]
								--local DispTimer = math.random(60, 300)
								local spd       = math.random(30, 60)
							
									local function moveGroup(gpName, zoneSub, formations, s, theCtrl)
										local grp2=Group.getByName(gpName);if(not grp2)or(not grp2:isExist())or(grp2:getSize()<1)then return end
										local vel=grp2:getUnit(1):getVelocity()or{x=0,y=0,z=0}
										if UTILS.VecNorm(vel)<1 then
											local p0=grp2:getUnit(1):getPoint()
											local subz=nil
											local main=bc:getZoneOfPoint(p0)
											if main then
												for _,cand in ipairs(ZONE_VALID_SUBZONES[main.zone] or{})do
													local cz=CustomZone:getByName(cand)
													if cz and cz:isInside(p0)then subz=cand break end
												end
											end
											--env.info("[TEST] "..gpName.." in "..tostring(subz or"no-subzone"))
											local z=trigger.misc.getZone(zoneSub);if not z then return end
											local dest={x=z.point.x,y=z.point.y,z=z.point.z}
											local directD=((p0.x-dest.x)^2+(p0.z-dest.z)^2)^0.5
											if directD>3*1852 then return end
											local tripLong=directD>500
                                            local nearDestRoad = SUBZONE_NEAR_ROAD[zoneSub] or false
                                            local nearStartRoad
                                            if subz then
                                                nearStartRoad = SUBZONE_NEAR_ROAD[subz] or false
                                            else
                                                nearStartRoad = isRoadClose(p0, math.min(1000, directD * 0.8) * 1.5)
                                            end
                                            local useRd = (nearStartRoad or nearDestRoad) and tripLong

											local path=nil
											local key=nil
											if useRd then
												local key=math.floor(p0.x/100)..':'..math.floor(p0.z/100)..':'..math.floor(dest.x/100)..':'..math.floor(dest.z/100)
												path=PATH_CACHE[key]
												if not path then
													path=land.findPathOnRoads("roads",p0.x,p0.z,dest.x,dest.z) PATH_CACHE[key]=path
												end
												if directD>1000 then
													if path and#path>0 then
														local rd,prev=0,{x=p0.x,y=p0.z}
														for _,pt in ipairs(path)do pt.z=pt.z or pt.y;rd=rd+UTILS.VecDist2D(prev,{x=pt.x,y=pt.z});if rd>directD*2.0 then useRd=false break end;prev={x=pt.x,y=pt.z} end
													else useRd=false end
												end
											end
											local formation
											if useRd then formation="On Road" else repeat formation=formations[math.random(1,#formations)] until formation~="On Road" end
											env.info("[DEBUG roamGroupsToLocalSubZone] Sending "..gpName.." -> "..zoneSub.." formation="..formation.." speed="..s)
											if not useRd then GROUP:FindByName(gpName):RouteGroundTo(COORDINATE:New(dest.x,0,dest.z),s,formation,1) return end

											theCtrl:popTask()
											local wp1=ground_buildWP(p0,"on_road",s)
											local exitPt=dest
											if path and#path>0 then
												local roadSoFar,prev=0,{x=p0.x,y=p0.z}
												for _,pt in ipairs(path)do pt.z=pt.z or pt.y;local pt2={x=pt.x,y=pt.z};roadSoFar=roadSoFar+UTILS.VecDist2D(prev,pt2);pt._roadDist=roadSoFar;prev=pt2 end
												local offMax=math.min(700,directD*0.8)
												local gainMin=math.max(500,directD*0.5)
												for i=#path,1,-1 do local pt=path[i];local off=UTILS.VecDist2D({x=pt.x,y=pt.z},{x=dest.x,y=dest.z});local gain=directD-(pt._roadDist+off);if off<=offMax and gain>=gainMin then exitPt=pt break end end
												local roadLen=exitPt._roadDist or roadSoFar
												if roadLen>directD*2.0 and(roadLen-directD)>2.0*1852 then exitPt=dest end
											end
											local wp2=ground_buildWP(exitPt,"on_road",s)
											local wp3=ground_buildWP(dest,"Off Road",s)
											theCtrl:setTask({id="Mission",params={route={points={wp1,wp2,wp3}}}})
											if key then PATH_CACHE[key]=nil end
										end
									end

									if zoneCounter % 3 == 0 then
										offset = offset+math.random(300,900)
									end
										
									offset = offset + math.random(60,120)
									--env.info("[DEBUG roamGroupsToLocalSubZone] Scheduling "..gData.gName.." -> "..pick.." formation="..form.." speed="..spd)
									SCHEDULER:New(nil, moveGroup, {gData.gName, pick, gData.formations, spd, gData.ctrl}, offset)
									scheduledCount = scheduledCount + 1
								end
							end
						end
					end
				end
			end
	
			local nextRun = timer.getTime()+offset+10
			return nextRun
		end
	
		local nextBigTime
		local function innerLoop()
			local nxt=innerRoam()
			if nxt and nxt<nextBigTime-1 then SCHEDULER:New(nil,innerLoop,{},nxt-timer.getTime(),0) end
		end
		local function bigLoop()
			USED_SUB_ZONES={}
			buildCycleData()
			nextBigTime=timer.getTime()+math.random(900,2400)
			SCHEDULER:New(nil,bigLoop,{},nextBigTime - timer.getTime(),0)
			innerLoop()
		end
		SCHEDULER:New(nil,bigLoop,{},math.random(10,30),0)
	end
	function forceMissionComplete()
		if not missionCompleted then
				missionCompleted = true
				trigger.action.setUserFlag(180, true)
				trigger.action.outText("Enemy has been defeated.\n\nMission Complete.\n\nYou can restart the mission from the radio menu.", 120)
	
				timer.scheduleFunction(function()
					trigger.action.outSoundForCoalition(2, "BH.ogg")
				end, {}, timer.getTime() + 5)
	
				local subMenu = missionCommands.addSubMenuForCoalition(2, "Restart and Reset?", nil)
				missionCommands.addCommandForCoalition(2, "Yes", subMenu, function()
						Utils.saveTable(bc.saveFile, 'zonePersistance', {})
						if resetSaveFileAndFarp then
						resetSaveFileAndFarp()
						end
					trigger.action.outText("Restarting now..", 120)
					timer.scheduleFunction(function()
						trigger.action.setUserFlag(181, true)
					end, {}, timer.getTime() + 5)
				end)
				missionCommands.addCommandForCoalition(2, "No", subMenu, function()
			end)
		end
	end

	function BattleCommander:startMonitorPlayerMarkers()
		markEditedEvent = {}
		markEditedEvent.context = self
		function markEditedEvent:onEvent(event)
			if event.id == 26 and event.text and (event.coalition == 1 or event.coalition == 2) then -- mark changed
				local success = false
				
				if event.text=='help' then
					local toprint = 'Available Commands:'
					toprint = toprint..'\nbuy - display available support items'
					toprint = toprint..'\nbuy:item - buy support item'
					toprint = toprint..'\nstatus - display zone status for 60 seconds'
					toprint = toprint..'\nstats - display complete leaderboard'
					toprint = toprint..'\ntop - display top 5 players from leaderboard'
					toprint = toprint..'\nmystats - display your personal statistics (only in MP)'
					toprint = toprint..'\nmissions display all the active missions'
					
					if event.initiator then
						trigger.action.outTextForGroup(event.initiator:getGroup():getID(), toprint, 20)
					else
						trigger.action.outTextForCoalition(event.coalition, toprint, 20)
					end
					
					success = true
				end
				if event.text=='debughelp' then
					local toprint = 'Available Commands:'
					toprint = toprint..'\nspawn - Spawns the stuff in that zone where the marker was used if the spawn is valid.'
					toprint = toprint..'\nrensa - clears out a zone of units.'
					toprint = toprint..'\nintelstatus - force to display status message all though without intel bought.'
					toprint = toprint..'\ncapture: - capture:2 or capture:1. can be used to capture a neutral zone'
					toprint = toprint..'\nmaxxa - upgrades a zone to the max, current coalition.'
					toprint = toprint..'\nevent - shows in the log the events that is in the script'
					toprint = toprint..'\nevent: will start the event if the canexecute is true. event:eventID'
					toprint = toprint..'\naddfunds: - addfunds:1000 - adds 1000 credits to the blue coalition.'
					toprint = toprint..'\ndebug:  - shows the status of the zone in the log.'
					toprint = toprint..'\naddshop: - Add shop for the coalition and can be used from f10.'
					toprint = toprint..'\nremoveshop: - remove shop for the coalition.'
					toprint = toprint..'\nupgradeallred: - upgrade all red zones to the max.'
					toprint = toprint..'\n-code: - This is a pure lua entry. Can be used to call function for example\n-code:zones.name:upgrade() to upgrade the zone'
					if event.initiator then
						trigger.action.outTextForGroup(event.initiator:getGroup():getID(), toprint, 30)
					else
						trigger.action.outTextForCoalition(event.coalition, toprint, 30)
					end
					
					success = true
				end
				
				if event.text:find('^buy') then
					if event.text == 'buy' then
						local toprint = 'Credits: '..self.context.accounts[event.coalition]
						if self.context.creditsCap then
							toprint = toprint..'/'..self.context.creditsCap
						end
						
						toprint = toprint..'\n'
						local sorted = {}
						for i,v in pairs(self.context.shops[event.coalition]) do table.insert(sorted,{i,v}) end
						table.sort(sorted, function(a,b) return a[2].name < b[2].name end)
						
						for i2,v2 in pairs(sorted) do
							local i = v2[1]
							local v = v2[2]
							toprint = toprint..'\n[Cost: '..v.cost..'] '..v.name..'   buy:'..i
							if v.stock ~= -1 then
								toprint = toprint..' [Available: '..v.stock..']'
							end
						end
						
						if event.initiator then
							trigger.action.outTextForGroup(event.initiator:getGroup():getID(), toprint, 20)
						else
							trigger.action.outTextForCoalition(event.coalition, toprint, 20)
						end
						
						success = true
					elseif event.text:find('^buy\:') then
						local item = event.text:gsub('^buy\:', '')
						local zn = self.context:getZoneOfPoint(event.pos)
						self.context:buyShopItem(event.coalition,item,{zone = zn, point=event.pos})
						success = true
					end
				end
				if event.text=='debug' then
					local z = bc:getZoneOfPoint(event.pos)
					if z then
						local status = ""  -- initialize it
						env.info('-----------------------------------debug '..z.zone..'------------------------------------------')
						for i,v in pairs(z.built) do
							local gr = Group.getByName(v)
							if gr then
								env.info(gr:getName()..' '..gr:getSize()..'/'..gr:getInitialSize())
								for i2,v2 in ipairs(gr:getUnits()) do
									env.info('-'..v2:getName()..' '..v2:getLife()..'/'..v2:getLife0(),30)
								end
							else
								local st = StaticObject.getByName(v)
								if st then
									status = status..'\n  '..v..' 100%'
									env.info('Static: '..v..' 100%')
								end
							end
						end
						env.info('-----------------------------------end debug '..z.zone..'------------------------------------------')
		  
						trigger.action.removeMark(event.idx)
					end
				end
				if event.text=='spawn' then
					local z = bc:getZoneOfPoint(event.pos)
					if z then
						for i,v in ipairs(z.groups) do
							if v.state == 'inhangar' or v.state == 'dead' then
								v.state='preparing'
								v.lastStateTime = timer.getAbsTime()-999999
							end
						end
						trigger.action.removeMark(event.idx)
					end
				end
				if event.text=='prepp' then
					local z = bc:getZoneOfPoint(event.pos)
					if z then
						for i,v in ipairs(z.groups) do
							if v.state == 'dead' then
								v.state='inhangar'
								v.lastStateTime = timer.getAbsTime()-999999
							end
						end
						trigger.action.removeMark(event.idx)
					end
				end
				if event.text=='addshop' then
					bc:refreshShopMenuForCoalition(2)
						trigger.action.removeMark(event.idx)
						success = true
				end
				if event.text=='upgradeallred' then
					upgradeRedZones()
						trigger.action.removeMark(event.idx)
						success = true
				end
				if event.text=='removeshop' then
					bc:RemoveMenuForCoalition(2)
						trigger.action.removeMark(event.idx)
						success = true
				end
			
				if event.text=='status' then
					local zn = self.context:getZoneOfPoint(event.pos)
					if zn then
						if event.initiator then
							zn:displayStatus(event.initiator:getGroup():getID(), 60)
						else
							zn:displayStatus(nil, 30)
						end
						
						success = true
					else
						success = true
						if event.initiator then
							trigger.action.outTextForGroup(event.initiator:getGroup():getID(), 'Status command only works inside a zone', 20)
						else
							trigger.action.outTextForCoalition(event.coalition, 'Status command only works inside a zone', 20)
						end
					end
				end
				if event.text=='event' then
					for i,v in ipairs(evc.events) do
						env.info(v.id)
					end
					trigger.action.removeMark(event.idx)
				end
				if event.text:find('^event\:') then
					local s = event.text:gsub('^event\:', '')
					local eventname = s
					evc:triggerEvent(eventname)
					trigger.action.removeMark(event.idx)
				end
				if event.text=='rensa' then
					local z = bc:getZoneOfPoint(event.pos)
					if z then
						z:killAll()
						trigger.action.removeMark(event.idx)
						success = true
					end
				end
				if event.text:find('^Message%s*:') then
					local msg = event.text:gsub('^Message%s*:%s*', '')
					trigger.action.outText(msg, 10)
					trigger.action.removeMark(event.idx)
					success = true
				end
				if event.text:find('SpelaMusik') then
					trigger.action.setUserFlag(180, true)
					trigger.action.outSoundForCoalition(2, "BH.ogg")
					trigger.action.removeMark(event.idx)
					success = true
					SCHEDULER:New(nil,function()
						trigger.action.setUserFlag(180, false)
					end,{},300,0)
				end
				if event.text=='AvslutaFoothold' then
					if forceMissionComplete then
						forceMissionComplete()
						trigger.action.removeMark(event.idx)
						success = true
					end
				end
				if event.text=='intelstatus' then
					local z=bc:getZoneOfPoint(event.pos)
					if z then
						if event.initiator then
							z:displayStatus(event.initiator:getGroup():getID(),60,true)
						else
							z:displayStatus(nil,30,true)
						end
						trigger.action.removeMark(event.idx)
						success=true
					end
				end
                if event.text=='missions' then
					mc:printMissions(nil)
                    success = true
                    trigger.action.removeMark(event.idx)
                end
				if event.text:find('^addfunds\:') then
					local s = event.text:gsub('^addfunds\:', '')
					local amount = tonumber(s)
					bc:addFunds(2,amount)
                    success = true
                    trigger.action.removeMark(event.idx)
                end
				if event.text=='upgradera' then
					local z = bc:getZoneOfPoint(event.pos)
					if z then
						z:upgrade()
						trigger.action.removeMark(event.idx)
					end
				end
				if event.text=='recapture' then
					local z = bc:getZoneOfPoint(event.pos)
					if z then
						z:RecaptureBlueZone()
						trigger.action.removeMark(event.idx)
					end
				end
				if event.text=='maxxa' then
					local z = bc:getZoneOfPoint(event.pos)
					if z then
						z:MakeZoneSideAndUpgraded()
						trigger.action.removeMark(event.idx)
					end
				end
				if event.text:find('^capture\:') then
					local s = event.text:gsub('^capture\:', '')
					local side = tonumber(s)
					if side == 1 or side == 2 then
						local z = bc:getZoneOfPoint(event.pos)
						if z then
							z:capture(side)
							trigger.action.removeMark(event.idx)
							success = true
						end
					end
				end
				if event.text=='blå' then
					local z = bc:getZoneOfPoint(event.pos)
					if z then
						z:capture(2)
						trigger.action.removeMark(event.idx)
						success = true
					end
				end
				if event.text=='röd' then
					local z = bc:getZoneOfPoint(event.pos)
					if z then
						z:capture(1)
						trigger.action.removeMark(event.idx)
						success = true
					end
				end
                if event.text:sub(1,6)=='-code:' then
                    local cmd=event.text:sub(7)
                    local f,err=loadstring(cmd)
                    if f then
                        local ok,res=pcall(f)
                        if not ok then env.info('ERROR '..tostring(res)) end
                    else
                        env.info('LOAD ERROR '..tostring(err))
                    end
                    trigger.action.removeMark(event.idx)
                    success=true
                end		
				if event.text=='stats' then
					if event.initiator then
						self.context:printStats(event.initiator:getID())
						success = true
					else
						self.context:printStats()
						success = true
					end
				end
				if event.text=='top' then
					if event.initiator then
						self.context:printStats(event.initiator:getID(), 5)
						success = true
					else
						self.context:printStats(nil, 5)
						success = true
					end
				end
				
				if event.text=='mystats' then
					if event.initiator then
						self.context:printMyStats(event.initiator:getID(), event.initiator:getPlayerName())
						success = true
					end
				end
				
				
				if success then
					trigger.action.removeMark(event.idx)
				end
			end
		end
		
		world.addEventHandler(markEditedEvent)
	end
--[[
function BattleCommander:buildZoneStatusMenu()
    if not self.zoneStatusMenu then
        self.zoneStatusMenu = missionCommands.addSubMenu('Zone Status')
    end

    if self.redSideMenu then
        missionCommands.removeItem(self.redSideMenu)
    end
    if self.blueSideMenu then
        missionCommands.removeItem(self.blueSideMenu)
    end

    self.redSideMenu = missionCommands.addSubMenu('Red Side', self.zoneStatusMenu)
    self.blueSideMenu = missionCommands.addSubMenu('Blue Side', self.zoneStatusMenu)

    local sub1Red, sub1Blue

    self.redSideZones = {}
    self.blueSideZones = {}

    for i, v in ipairs(self.zones) do
        if not v.zone:lower():find("hidden") then
            if v.side == 1 then
                table.insert(self.redSideZones, v)
            elseif v.side == 2 then
                table.insert(self.blueSideZones, v)
            end
        end
    end

    for i, v in ipairs(self.redSideZones) do
        if i < 10 then
            missionCommands.addCommand(v.zone, self.redSideMenu, v.displayStatus, v)
        elseif i == 10 then
            sub1Red = missionCommands.addSubMenu("More", self.redSideMenu)
            missionCommands.addCommand(v.zone, sub1Red, v.displayStatus, v)
        elseif i % 9 == 1 then
            sub1Red = missionCommands.addSubMenu("More", sub1Red)
            missionCommands.addCommand(v.zone, sub1Red, v.displayStatus, v)
        else
            missionCommands.addCommand(v.zone, sub1Red, v.displayStatus, v)
        end
    end

    for i, v in ipairs(self.blueSideZones) do
        if i < 10 then
            missionCommands.addCommand(v.zone, self.blueSideMenu, v.displayStatus, v)
        elseif i == 10 then
            sub1Blue = missionCommands.addSubMenu("More", self.blueSideMenu)
            missionCommands.addCommand(v.zone, sub1Blue, v.displayStatus, v)
        elseif i % 9 == 1 then
            sub1Blue = missionCommands.addSubMenu("More", sub1Blue)
            missionCommands.addCommand(v.zone, sub1Blue, v.displayStatus, v)
        else
            missionCommands.addCommand(v.zone, sub1Blue, v.displayStatus, v)
        end
    end
end
--]]

	function BattleCommander:init()
		self:startMonitorPlayerMarkers()
		self:initializeRestrictedGroups()

		if self.difficulty then
			self.lastDiffChange = timer.getAbsTime()
		end

		table.sort(self.zones, function(a, b) return a.zone < b.zone end)
		for i, v in ipairs(self.zones) do
			v:init()
		end

		for i, v in ipairs(self.connections) do
			local from = CustomZone:getByName(v.from)
			local to = CustomZone:getByName(v.to)

			trigger.action.lineToAll(-1, 1000 + i, from.point, to.point, {1, 1, 1, 0.5}, 2)
		end


		--missionCommands.addCommandForCoalition(1, 'Budget overview', nil, self.printShopStatus, self, 1)
		--missionCommands.addCommandForCoalition(2, 'Budget overview', nil, self.printShopStatus, self, 2)

		--self:refreshShopMenuForCoalition(1)
		--self:refreshShopMenuForCoalition(2)
	SCHEDULER:New(self,function(o)o:_autoZoneSuspend()end,{},1,60)
	SCHEDULER:New(self,function(o)o:_proximityWakeSuspendedZones()end,{},60,60)
	SCHEDULER:New(self,function(o)o:update()end,{},2,self.updateFrequency)
	SCHEDULER:New(self,function(o)o:saveToDisk()end,{},30,self.saveFrequency)

	playerZoneSpawn = playerZoneSpawn or {}
	ev = {}
	function ev:onEvent(event)
		if event.id == world.event.S_EVENT_BIRTH and
		event.initiator and Object.getCategory(event.initiator) == Object.Category.UNIT and
		(Unit.getCategoryEx(event.initiator) == Unit.Category.AIRPLANE or Unit.getCategoryEx(event.initiator) == Unit.Category.HELICOPTER) then
			local pname = event.initiator:getPlayerName()
			if pname then
				local un = event.initiator
				local zn = BattleCommander:getZoneOfUnit(un:getName())
				local gr = event.initiator:getGroup()
				local groupId = gr:getID()
				mc:createMissionsMenuForGroup(groupId)
				bc:buildZoneStatusMenuForGroup(groupId)
				if zn then
					local isDifferentSide = zn.side ~= un:getCoalition()
					
					if isDifferentSide and not zn.wasBlue then
						for i, v in pairs(net.get_player_list()) do
							if net.get_name(v) == pname then
								net.send_chat_to('Cannot spawn as '..gr:getName()..' in enemy/neutral zone', v)
								timer.scheduleFunction(function(param, time)
									net.force_player_slot(param, 0, '')
								end, v, timer.getTime() + 0.1)
								break
							end
						end
						trigger.action.outTextForGroup(gr:getID(), 'Cannot spawn as '..gr:getName()..' in enemy/neutral zone', 5)
						if event.initiator and event.initiator:isExist() then
							event.initiator:destroy()
						end
					else
						if handleMission and Unit.getCategoryEx(un) == Unit.Category.HELICOPTER then
							timer.scheduleFunction(function()
								if gr and gr:isExist() then
									handleMission(zn.zone, gr:getName(), gr:getID(), gr)
								end
							end, {}, timer.getTime() + 30)
						end
						if Unit.getCategoryEx(un) == Unit.Category.AIRPLANE then
							if capMissionTarget ~= nil and capKillsByPlayer[pname] then
								capKillsByPlayer[pname] = 0
							end
						if un:getTypeName() ~= "A-10C_2" and un:getTypeName() ~= "Hercules" and un:getTypeName() ~= "A-10A" and un:getTypeName() ~= "AV8BNA" then
								playerZoneSpawn[pname] = zn.zone
							end
						end
						if casMissionTarget ~= nil and casKillsByPlayer[pname] then casKillsByPlayer[pname] = 0 end
					end
				else
					zn=getEscortFarpZoneOfUnit(un:getName())
					if zn then
						if handleMission and Unit.getCategoryEx(un) == Unit.Category.HELICOPTER then
							if gr and gr:isExist() then
									timer.scheduleFunction(function()
									handleMission(zn.zone, gr:getName(), gr:getID(), gr)
								end, {}, timer.getTime() + 30)
							end
						end
					end
				end
			end
		end
	end
	world.addEventHandler(ev)
end


function BattleCommander:updateBlueZoneCount()
    local n = 0
    for _, z in ipairs(self.zones) do
        if z.side == 2 and z.active and not z.zone:lower():find("hidden") then
            n = n + 1
        end
    end
    self.blueZoneCount = n > 2 and n - 2 or 0
end

SCHEDULER:New(nil, function()
        bc:updateBlueZoneCount()
end, {}, 4, 0)

--[[ 
-- this one below is the one working best
function BattleCommander:reindexCombatZones()
	Frontline.BuildFromZones(self.indexedZones or self.zones)
	self._activeAttackOrPatrol = {}
		for _, zone in ipairs(self.zones) do
			for _, gc in ipairs(zone.groups or {}) do
				if gc and gc.targetzone and (gc.mission == 'attack' or gc.mission == 'patrol') then
					if gc:shouldSpawn() then
						local tz = self:getZoneByName(gc.targetzone)
						if tz then
							if gc.mission == 'attack' then
								self._activeAttackOrPatrol[gc.targetzone] = true
							elseif gc.mission == 'patrol' then
								local dnm = self:_minEnemyDistanceNm(tz)
								if dnm then
									local lim = (tz.side==2) and (GlobalSettings.autoSuspendNmBlue or 70) or (GlobalSettings.autoSuspendNmRed or 150)
									if dnm <= lim then
										self._activeAttackOrPatrol[gc.targetzone] = true
									end
								end
							end
						end
					end
				end
			end
		end
	end

 ]]
function BattleCommander:reindexCombatZones()
	Frontline.BuildFromZones(self.indexedZones or self.zones)
	self._activeAttackOrPatrol = {}
	self._activeOrigin = {}

	local activeTargets = self._activeAttackOrPatrol
	local activeOrigins = self._activeOrigin
	local zones = self.zones or {}
	local autoSuspendBlue = GlobalSettings.autoSuspendNmBlue or 70
	local autoSuspendRed = GlobalSettings.autoSuspendNmRed or 120

	for i=1,#zones do
		local zone = zones[i]
		local originName = zone and zone.zone
		local groups = zone and zone.groups
		if groups then
			for j=1,#groups do
				local gc = groups[j]
				if gc then
					local mission = gc.mission
					if mission == 'attack' or mission == 'patrol' then
						local targetName = gc.targetzone
						if targetName then
							if mission == 'attack' then
								if gc:shouldSpawn() or gc.state=='takeoff' or gc.state=='inair' or gc.state=='landed' or gc.state=='enroute' or gc.state=='atdestination' then
									if originName then activeOrigins[originName] = true end
								end
							end
							local tz = self:getZoneByName(targetName)
							if tz and tz.active and not tz.suspended and tz.side ~= 0 then
								local tzName = tz.zone
								if tzName and not tzName:lower():find("hidden") then
									if gc:shouldSpawn() or gc.state=='takeoff' or gc.state=='inair' or gc.state=='landed' or gc.state=='enroute' or gc.state=='atdestination' then
										if mission == 'attack' then
                                            activeTargets[targetName] = true
                                            if originName then
                                                activeOrigins[originName] = true
                                            end
										else
											local dnm = self:_minEnemyDistanceNm(tz)
											if dnm then
												local lim = (tz.side == 2) and autoSuspendBlue or autoSuspendRed
												if dnm <= lim then
                                                    activeTargets[targetName] = true
                                                    if originName then
                                                        activeOrigins[originName] = true
                                                        --env.info(string.format("[ORIGIN] %s via %s -> %s (patrol, dnm<=%d)", originName, tostring(gc.name or "group"), targetName, lim))
                                                    end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end


function BattleCommander:EngageSeadMission(tgtzone, groupname, expend, altitude, landUnitID)
	local zn = self:getZoneByName(tgtzone)
	local group = Group.getByName(groupname)
	if zn and zn.suspended then
		if group and group:isExist() then group:destroy() end
		return
	end
	if group and zn and zn.side == group:getCoalition() then return 'Can not engage friendly zone' end
	if not group or not group:isExist() or group:getSize()==0 then return 'Not available' end
	local startPos = group:getUnit(1):getPoint()
	local expCount = expend or AI.Task.WeaponExpend.ALL
	local altm = altitude and (altitude/3.281) or 4572

	local viable = {}
	if zn and zn.built then
		for _, name in ipairs(zn.built) do
			local g = Group.getByName(name)
			if g and g:getCoalition() ~= group:getCoalition() then
				for _,unit in ipairs(g:getUnits() or {}) do
					if unit:hasAttribute('SAM SR') or unit:hasAttribute('SAM TR') then
						table.insert(viable, unit:getName())
					end
				end
			end
		end
	end

	local attack = { id='ComboTask', params={ tasks={ { id='EngageTargets', params={ targetTypes={'SAM SR','SAM TR'} } } } } }
	for _, uname in ipairs(viable) do
		local task = self:getAttackTask(uname, expCount, altm)
		if task then table.insert(attack.params.tasks, task) end
	end

	local firstunitpos = nil
	if viable[1] then local u = Unit.getByName(viable[1]); if u then firstunitpos = u:getPoint() end end

	local mis = self:getDefaultWaypoints(startPos, attack, firstunitpos, altm, landUnitID)
	group:getController():setTask(mis)
	self:setDefaultAG(group)
end


FG_BY_GROUP = FG_BY_GROUP or {}
CAS_MISSION = CAS_MISSION or {}
-- BASE:TraceOn()
-- BASE:TraceClass("FLIGHTGROUP")
-- BASE:TraceClass("AUFTRAG")

	function BattleCommander:EngageCasAuftrag(targetZoneName, groupName, altitudeFt, expend, coalitionSide)
		local gr = GROUP:FindByName(groupName); if not gr or not gr:IsAlive() then return end
		local zn = self:getZoneByName(targetZoneName)
		if not gr or not gr:IsAlive() then return end 
		if zn.suspended then if gr and gr:IsAlive() then gr:Destroy() end return end
		local fg = FLIGHTGROUP:New(gr)
		FG_BY_GROUP[groupName] = fg
		local targetZone = ZONE:FindByName(targetZoneName)
		fg:GetGroup():SetOptionRadioSilence(true)
		fg:SetOutOfAGMRTB(true)
		local u = gr:GetUnit(1)
		if coalitionSide and u then
			local coord = gr:GetCoordinate()
			local homebase = coord and coord:GetClosestAirbase(0, coalitionSide)
			if homebase then fg:SetHomebase(homebase) end
		end

		local setGroup = SET_GROUP:New()
		local setStatic = SET_STATIC:New()
		local zn = bc:getZoneByName(targetZoneName)
		if zn and zn.built then
			for _, v in pairs(zn.built) do
				local g = GROUP:FindByName(v)
				if g and g:IsAlive() then setGroup:AddGroup(g) end
				local s = STATIC:FindByName(v,false)
				if s and s:IsAlive() then setStatic:AddStatic(s) end
			end
		end

		local altitudeFt = altitudeFt or 15000
		local miss = AUFTRAG:NewCASENHANCED(targetZone,altitudeFt,400,15,nil,"Ground Units")
		CAS_MISSION[groupName] = miss
		--local miss = AUFTRAG:NewBAI(setGroup, altitudeFt)
		--miss.missionWaypointOffsetNM = 15
		miss:SetMissionAltitude(altitudeFt)
		miss:AddConditionSuccess(function() local z=bc:getZoneByName(targetZoneName); return z and z.side==0 end)
		miss:AddConditionFailure(function() return fg and fg:IsOutOfBombs() end)
		miss:SetWeaponExpend(expend or AI.Task.WeaponExpend.ONE)
		miss:SetEngageAsGroup(false)
		miss:SetMissionSpeed(400)
		miss:SetFormation(Utils.getRandomFormation())
		fg:AddMission(miss)
	end

HELO_CAS_MISSION = HELO_CAS_MISSION or {}
	function BattleCommander:EngageHeloCasAuftrag(targetZoneName, groupName, altitudeFt, expend, coalitionSide)
		local gr = GROUP:FindByName(groupName); if not gr or not gr:IsAlive() then return end
		local zn = self:getZoneByName(targetZoneName)
		if not gr or not gr:IsAlive() then return end 
		if zn.suspended then if gr and gr:IsAlive() then gr:Destroy() end return end
		local fg = FLIGHTGROUP:New(gr)
		FG_BY_GROUP[groupName] = fg
		local targetZone = ZONE:FindByName(targetZoneName)
		fg:GetGroup():SetOptionRadioSilence(true)
		fg:SetOutOfAGMRTB(true)
		local u = gr:GetUnit(1)
		if coalitionSide and u then
			local coord = gr:GetCoordinate()
			local homebase = coord and coord:GetClosestAirbase(0, coalitionSide)
			if homebase then fg:SetHomebase(homebase) end
		end

		local setGroup = SET_GROUP:New()
		local setStatic = SET_STATIC:New()
		local zn = bc:getZoneByName(targetZoneName)
		if zn and zn.built then
			for _, v in pairs(zn.built) do
				local g = GROUP:FindByName(v)
				if g and g:IsAlive() then setGroup:AddGroup(g) end
				local s = STATIC:FindByName(v,false)
				if s and s:IsAlive() then setStatic:AddStatic(s) end
			end
		end

		local altitudeFt = altitudeFt or 400
		local miss = AUFTRAG:NewCASENHANCED(targetZone,altitudeFt,150,5,nil,"Ground Units")
		HELO_CAS_MISSION[groupName] = miss
		--local miss = AUFTRAG:NewBAI(setGroup, altitudeFt)
		miss.missionWaypointOffsetNM = 5
		miss:AddConditionSuccess(function() local z=bc:getZoneByName(targetZoneName); return z and z.side==0 end)
		miss:SetWeaponExpend(expend or AI.Task.WeaponExpend.ONE)
		miss:SetEngageAsGroup(false)
		miss:SetMissionSpeed(160)
		fg:AddMission(miss)
	end

	Runway_Bomb_MISSION = Runway_Bomb_MISSION or {}
	function BattleCommander:EngageRunwayBombAuftrag(homeBase, targetZoneName, groupName, altitudeFt, coalitionSide)
		local gr = GROUP:FindByName(groupName); if not gr or not gr:IsAlive() then return end
		local zn = self:getZoneByName(targetZoneName)
		if not gr or not gr:IsAlive() then return end 
		if zn.suspended then if gr and gr:IsAlive() then gr:Destroy() end return end
		local fg = FLIGHTGROUP:New(gr)
		FG_BY_GROUP[groupName] = fg
		local zn = bc:getZoneByName(targetZoneName) if not zn then return end
		local abName = zn and zn.airbaseName or nil
		if abName then
		fg:SetHomebase(homeBase)
		
		local Airdrome = AIRBASE:FindByName(abName)
				fg:GetGroup():SetOptionRadioSilence(true)


		local altitudeFt = altitudeFt or 25000
		local miss = AUFTRAG:NewBOMBRUNWAY(Airdrome,altitudeFt)
		env.info("Creating Runway Bombing mission for "..groupName.." at "..abName)
			Runway_Bomb_MISSION[groupName] = miss
			local tgZone = bc:getZoneByName(targetZoneName)
			miss:AddConditionFailure(function() return fg and (tgZone.side == self.side or tgZone.side == 0) end)
			--local miss = AUFTRAG:NewBAI(setGroup, altitudeFt)
			--miss.missionWaypointOffsetNM = 20
			miss:SetEngageAsGroup(true)
			miss:SetMissionSpeed(480)
			fg:AddMission(miss)
		end
	end


	SEAD_MISSION = SEAD_MISSION or {}

	function BattleCommander:EngageSeadAuftrag(targetZoneName, groupName, altitudeFt, expend, coalitionSide)
		local zn = self:getZoneByName(targetZoneName)
		local gr = GROUP:FindByName(groupName); if not gr or not gr:IsAlive() then return end
		if zn.suspended then
			if gr and gr:IsAlive() then gr:Destroy() end
			return
		end
		local fg = FLIGHTGROUP:New(gr)
		FG_BY_GROUP[groupName] = fg
		fg:GetGroup():SetOptionRadioSilence(true)
		fg:SetOutOfAGMRTB(true)

		local targetZone = ZONE:FindByName(targetZoneName)
		local u = gr:GetUnit(1)
		if coalitionSide and u then
			local coord = u:GetCoordinate()
			local homebase = coord and coord:GetClosestAirbase(0, coalitionSide)
			if homebase then fg:SetHomebase(homebase) end
		end

		local setTargets = SET_UNIT:New()
		local zn = bc:getZoneByName(targetZoneName)
		if zn and zn.built then
			for _, v in pairs(zn.built) do
			local g = GROUP:FindByName(v)
				if g and g:IsAlive() then
					for _, unit in ipairs(g:GetUnits() or {}) do
						if unit:HasAttribute('SAM TR')
							or unit:HasAttribute('SAM SR') then
							setTargets:AddUnit(unit)
						end
					end
				end
			end
		end
		if setTargets:Count() == 0 then return end

		altitudeFt = altitudeFt or 28000
		local miss = AUFTRAG:NewSEAD(setTargets, altitudeFt)
		SEAD_MISSION[groupName] = miss

		miss:SetMissionAltitude(altitudeFt)
		miss:SetMissionSpeed(600)
		miss:SetWeaponExpend(expend or AI.Task.WeaponExpend.ALL)
		miss:AddConditionSuccess(function() local z=bc:getZoneByName(targetZoneName); return z and z.side==0 end)

		fg:AddMission(miss)
	end

	function BattleCommander:EngageHeloCasMission(tgtzone, groupname, expendAmmount, altitudeFt, landUnitID)
		local zn = self:getZoneByName(tgtzone)
		local group = Group.getByName(groupname)
		if zn.suspended then if group and group:isExist() then group:destroy() end return end
		
		local unit
		if group then
			unit = group:getUnit(1)
		end
		local alt
		if unit then
			local pos = unit:getPoint()
			alt = pos.y
		end

		local rng = 5 * 1852

		if group and zn.side == group:getCoalition() then return 'Can not engage friendly zone' end
		if not group then return 'Not available' end

		local startPos = group:getUnit(1):getPoint()

		local search = { 
			id = 'EngageTargets',
			params = {
				maxDist = rng,
				targetTypes = { 'Ground Units' }
			} 
		}

		local attack = {
			id = 'ComboTask',
			params = {
				tasks = {
				}
			}
		}

		local expCount = AI.Task.WeaponExpend.ONE
		if expendAmmount then expCount = expendAmmount end

		alt = alt + (300 / 3.28084)
		if altitudeFt then alt = altitudeFt/3.281 end

		for _, name in ipairs(zn.built) do
			local g = Group.getByName(name)
			if g and g:getCoalition() ~= group:getCoalition() then
				local task = self:getAttackTask(name, expCount, alt)
				if task then table.insert(attack.params.tasks, task) end
			end
		end

		local tx,tz
		do
			local c = zoneCentroid and zoneCentroid(zn.zone) or nil
			if c then tx, tz = c.x, c.y end
			if not tx then tx, tz = startPos.x, startPos.z end
		end
		local dx, dz = tx - startPos.x, tz - startPos.z
		local len = math.sqrt(dx*dx + dz*dz)
		local apx, apz
		if len > 4*1852 then
			apx = tx - dx/len*(4*1852)
			apz = tz - dz/len*(4*1852)
		else
			apx = startPos.x
			apz = startPos.z
		end

	local land = {
		id='Land',
		params = {
				point = {x = startPos.x, y = startPos.z},
				x = startPos.x,
				y = startPos.z
			}
		}

	local mis = {
			id='Mission',
			params = {
				route = { airborne = true, 
				points = {} 
				}
			}
		}
		table.insert(mis.params.route.points, {
				type= AI.Task.WaypointType.TAKEOFF,
				x = startPos.x,
				y = startPos.z,
				speed = 0,
				action = AI.Task.TurnMethod.FIN_POINT,
				alt = 0,
				alt_type = AI.Task.AltitudeType.RADIO,
				task = search
		})

		table.insert(mis.params.route.points, {
				type= AI.Task.WaypointType.TURNING_POINT,
				x = apx,
				y = apz,
				speed = 150,
				action = AI.Task.TurnMethod.FLY_OVER_POINT,
				alt = alt,
				alt_type = AI.Task.AltitudeType.RADIO,
				task = attack
		})

		table.insert(mis.params.route.points, {
				type= AI.Task.WaypointType.TURNING_POINT,
				x = startPos.x,
				y = startPos.z,
				speed = 150,
				action = AI.Task.TurnMethod.FIN_POINT,
				alt = alt,
				alt_type = AI.Task.AltitudeType.RADIO,
				task = land
		})
		group:getController():setTask(mis)
		self:setDefaultAG(group)
	end


	function SetUpCAP(group, point, altitudeFt, rangeNm, landUnitID, bufferNm)
	if not group or not group:isExist() or group:getSize()==0 then return end
	local unit = group:getUnit(1)
	if not unit or not unit:isExist() then return end
	local startPos = unit:getPoint()
	if not startPos or startPos == nil then return end

	local rng = (rangeNm or 25) * 1852
	local altm = (altitudeFt or 15000) * 0.3048

	local search = { 
		id = 'EngageTargets',
		params = {
			maxDist = rng,
			maxDistEnabled = true,
			targetTypes = { 'Planes' },
			priority = 0
		} 
	}

	local distFromPoint = math.random(10000,15000)
	local theta = math.random() * 2 * math.pi
	local dx = distFromPoint * math.cos(theta)
	local dy = distFromPoint * math.sin(theta)

	local p1 = { x = point.x + dx, y = point.z + dy }
	local p2 = { x = point.x - dx, y = point.z - dy }

	local bufNm = bufferNm or 0
	if Frontline and Frontline._zoneInfo then
		local side = group:getCoalition()
		local best,bd = nil,1e18
		for name,info in pairs(Frontline._zoneInfo) do
			if info.side and info.side ~= side then
				local dx0,dy0 = point.x - info.center.x, point.z - info.center.y
				local d2 = dx0*dx0 + dy0*dy0
				if d2 < bd then best,bd = info.center,d2 end
			end
		end
		if best then
			local dxp, dyp = point.x - best.x, point.z - best.y
			local len = math.sqrt(dxp*dxp + dyp*dyp)
			if len > 0 then
				local dnm = len / 1852
				local need = bufNm - dnm
				if need > 0 then
					local bump = (need + 2) * 1852
					local ux,uy = dxp/len, dyp/len
					p1.x = p1.x + ux*bump
					p1.y = p1.y + uy*bump
					p2.x = p2.x + ux*bump
					p2.y = p2.y + uy*bump
				end
			end
		end
	end

	local orbit = {
		id = 'Orbit',
		params = {
			pattern = AI.Task.OrbitPattern.RACE_TRACK,
			point = p1,
			point2 = p2,
			speed = 300,
			altitude = altm,
			alt_type = AI.Task.AltitudeType.BARO
		}
	}

	local task = { id='Mission', params={ route={ airborne=false, points={} } } }

	table.insert(task.params.route.points, {
		type=AI.Task.WaypointType.TAKEOFF,
		x=startPos.x, y=startPos.z, speed=0,
		action=AI.Task.TurnMethod.FIN_POINT,
		alt=0, alt_type=AI.Task.AltitudeType.RADIO,
		task=search
	})

	table.insert(task.params.route.points, {
		type=AI.Task.WaypointType.TURNING_POINT,
		x=p1.x, y=p1.y, speed=320,
		action=AI.Task.TurnMethod.FLY_OVER_POINT,
		alt=altm, alt_type=AI.Task.AltitudeType.BARO
	})

	table.insert(task.params.route.points, {
		type=AI.Task.WaypointType.TURNING_POINT,
		x=p2.x, y=p2.y, speed=320,
		action=AI.Task.TurnMethod.FLY_OVER_POINT,
		alt=altm, alt_type=AI.Task.AltitudeType.BARO,
		task=orbit
	})

	if landUnitID then
		table.insert(task.params.route.points, {
			type=AI.Task.WaypointType.LAND,
			linkUnit=landUnitID, helipadId=landUnitID,
			x=startPos.x, y=startPos.z, speed=220,
			action=AI.Task.TurnMethod.FIN_POINT,
			alt=0, alt_type=AI.Task.AltitudeType.RADIO
		})
	else
		table.insert(task.params.route.points, {
			type=AI.Task.WaypointType.LAND,
			x=startPos.x, y=startPos.z, speed=220,
			action=AI.Task.TurnMethod.FIN_POINT,
			alt=0, alt_type=AI.Task.AltitudeType.RADIO
		})
	end

	group:getController():setTask(task)
	SetUpCAP_DefaultAA(group)
end


	function BattleCommander:EngageCasMission(tgtzone, groupname, expendAmmount, weapon, altitude, landUnitID)
		local zn = self:getZoneByName(tgtzone)
		local group = Group.getByName(groupname)
		if zn.suspended then if group and group:isExist() then group:destroy() end return end
		if group and zn.side == group:getCoalition() then return 'Can not engage friendly zone' end
		if not group then return 'Not available' end

		local expCount = AI.Task.WeaponExpend.ONE
		if expendAmmount then expCount = expendAmmount end

		local altm = 4572
		if altitude then altm = altitude/3.281 end

		local attack = { id = 'ComboTask', params = { tasks = {} } }

		local firstpos = nil
		for _, v in pairs(zn.built) do
			local task = self:getAttackTask(v, expCount, altm)
			if task then
				table.insert(attack.params.tasks, task)
				if not firstpos then
					local p = self:getTargetPos(v)
					if p then firstpos = p else
						local gg = Group.getByName(v)
						if gg and gg:getSize()>0 then firstpos = gg:getUnit(1):getPoint() end
					end
				end
			end
		end

		if #attack.params.tasks == 0 then return 'No targets' end

		local startPos = group:getUnit(1):getPoint()
		local mis = self:getDefaultWaypoints(startPos, attack, firstpos, altm, landUnitID)

		local rng = 10 * 1852
		local search = { id = 'EngageTargets', params = { maxDist = rng, targetTypes = { 'Ground Units', 'Planes' } } }
		local pts = mis.params.route.points
		if pts and pts[2] and pts[2].task and pts[2].task.params and pts[2].task.params.tasks then
			table.insert(pts[2].task.params.tasks, search)
		end

		group:getController():setTask(mis)
		self:setDefaultAG(group)
	end

	function BattleCommander:getAttackTask(targetName, expend, altitude)
		local tgt = Group.getByName(targetName)
		if tgt then
			return {
				id = 'AttackGroup',
				params = {
					groupId = tgt:getID(),
					expend = expend,
					weaponType = Weapon.flag.AnyWeapon,
					groupAttack = false,
					altitudeEnabled = (altitude ~= nil),
					altitude = altitude
				}
			}
		else
			tgt = StaticObject.getByName(targetName)
			if not tgt then tgt = Unit.getByName(targetName) end
			if tgt then
				return {
					id = 'AttackUnit',
					params = {
						unitId = tgt:getID(),
						expend = expend,
						weaponType = Weapon.flag.AnyWeapon,
						groupAttack = true,
						altitudeEnabled = (altitude ~= nil),
						altitude = altitude
					}
				}
			end
		end
	end


	function BattleCommander:getTargetPos(targetName)
		local tgt = StaticObject.getByName(targetName)
		if not tgt then tgt = Unit.getByName(targetName) end
		if tgt then
			return tgt:getPoint()
		end
		local gg = Group.getByName(targetName)
		if gg and gg:getSize()>0 then
			local u = gg:getUnit(1)
			if u then return u:getPoint() end
		end
	end

	function BattleCommander:setDefaultAG(group)
		group:getController():setOption(AI.Option.Air.id.JETT_TANKS_IF_EMPTY, true)
		group:getController():setOption(AI.Option.Air.id.PROHIBIT_JETT, true)
		group:getController():setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
		group:getController():setOption(AI.Option.Air.id.ROE,AI.Option.Air.val.ROE.OPEN_FIRE)
		local weapons = 2147485694 + 30720 + 4161536
		group:getController():setOption(AI.Option.Air.id.RTB_ON_OUT_OF_AMMO, weapons)
		end


	function BattleCommander:HasSeadTargets(targetZoneName)
	local zn = self:getZoneByName(targetZoneName)
		if not (zn and zn.built) then return false end
			for _, v in pairs(zn.built) do
				local g = GROUP:FindByName(v)
				if g and g:IsAlive() then
					for _, unit in ipairs(g:GetUnits() or {}) do
						if unit:HasAttribute('SAM TR')
						or unit:HasAttribute('SAM SR') then
						return true
						end
					end
				end
			end
		return false
	end


	function BattleCommander:getDefaultWaypoints(startPos, task, tgpos, altitude, landUnitID)
		local alt = altitude or 4572
		local defwp = {
			id = 'Mission',
			params = {
				route = {
					airborne = true,
					points = {}
				}
			}
		}

			table.insert(defwp.params.route.points, {
				type = AI.Task.WaypointType.TAKEOFF,
				x = startPos.x,
				y = startPos.z,
				speed = 0,
				action = AI.Task.TurnMethod.FIN_POINT,
				alt = 0,
				alt_type = AI.Task.AltitudeType.RADIO
			})

			table.insert(defwp.params.route.points, {
				type = AI.Task.WaypointType.TURNING_POINT,
				x = startPos.x,
				y = startPos.z,
				speed = 257,
				action = AI.Task.TurnMethod.FLY_OVER_POINT,
				alt = alt,
				alt_type = AI.Task.AltitudeType.BARO,
				task = task
			})
		

		if tgpos then
			table.insert(defwp.params.route.points, {
				type = AI.Task.WaypointType.TURNING_POINT,
				x = tgpos.x,
				y = tgpos.z,
				speed = 257,
				action = AI.Task.TurnMethod.FLY_OVER_POINT,
				alt = alt,
				alt_type = AI.Task.AltitudeType.BARO,
				task = task
			})
		end

		if landUnitID then
			table.insert(defwp.params.route.points, {
				type = AI.Task.WaypointType.LAND,
				linkUnit = landUnitID,
				helipadId = landUnitID,
				x = startPos.x,
				y = startPos.z,
				speed = 257,
				action = AI.Task.TurnMethod.FIN_POINT,
				alt = 0,
				alt_type = AI.Task.AltitudeType.RADIO
			})
		else
			table.insert(defwp.params.route.points, {
				type = AI.Task.WaypointType.LAND,
				x = startPos.x,
				y = startPos.z,
				speed = 257,
				action = AI.Task.TurnMethod.FIN_POINT,
				alt = 0,
				alt_type = AI.Task.AltitudeType.RADIO
			})
		end

		return defwp
	end

	function BattleCommander:_rebalanceRedDifficulty()
		local total, blue = 0, 0
		for _, z in ipairs(self.zones) do
			if z.active and not z.suspended and z.side~=0 and not z.zone:lower():find("hidden") then
				total = total + 1
				if z.side==2 then blue = blue + 1 end
			end
		end
		if total == 0 then return end
		local frac = blue / total
		if frac >= 0.90 then
			GlobalSettings.setDifficultyScaling(0.60, 1)
		else
			GlobalSettings.setDifficultyScaling(1.00, 1)
		end
	end

	function BattleCommander:_proximityWakeSuspendedZones()
		local players = {}
		local pb = coalition.getPlayers and coalition.getPlayers(coalition.side.BLUE) or {}
		local pr = coalition.getPlayers and coalition.getPlayers(coalition.side.RED) or {}
		for _,u in pairs(pb) do local t=u:getTypeName() if t~="A-10C" and t~="A-10C_2" then players[#players+1]=u end end
		for _,u in pairs(pr) do local t=u:getTypeName() if t~="A-10C" and t~="A-10C_2" then players[#players+1]=u end end
		local limit = (GlobalSettings.proximityWakeNm or 30)
		local changed = false
		for _,z in ipairs(self.zones) do
			if z.suspended then
				local cz = CustomZone:getByName(z.zone)
				if cz and cz.point then
					local zp = cz.point
					for _,u in ipairs(players) do
						if not u:isExist() then break end
						local up = u:getPoint()
						if up then
							local dx = up.x - zp.x
							local dz = up.z - zp.z
							local dnm = math.sqrt(dx*dx + dz*dz) / 1852
							if dnm <= limit then z:resume() changed = true break end
						end
					end
				end
			end
		end
		if changed then self:buildZoneStatusMenuForGroup() end
	end


	function BattleCommander:_minEnemyDistanceNm(z)
		local best = math.huge
		local row = ZONE_DISTANCES and ZONE_DISTANCES[z.zone]
		if row then
			for _, other in ipairs(self.zones) do
				if other.side ~= 0 and other.side ~= z.side and other.active and not other.suspended and not other.zone:lower():find("hidden") then
					local d = row[other.zone]
					if d and d < best then best = d end
				end
			end
		end
		if best == math.huge then return nil end
		return best / 1852
	end

function BattleCommander:_hasActiveAttackOrPatrolOnZone()
	self._activeAttackOrPatrol = {}
	for _, zone in ipairs(self.zones) do
		for _, gc in ipairs(zone.groups or {}) do
			if gc and gc.targetzone and (gc.mission == 'attack' or gc.mission == 'patrol') then
				local st = gc.state
				if gc.Spawned and st ~= 'dead' then
					self._activeAttackOrPatrol[gc.targetzone] = true
				end
			end
		end
	end
	return self._activeAttackOrPatrol
end


function BattleCommander:_autoZoneSuspend()
		self:reindexCombatZones()
		local changed = false
		local toUpdate = {}
		local toSuspend = {}
		local toResume  = {}
		local neighborToResume = {}
		local supplierHold = {}
		for _, z in ipairs(self.zones) do
			if not z.suspended and z.active and z.side~=0 and not z.zone:lower():find("hidden") and not z.zone:lower():find("carrier") then
				if z:canRecieveSupply() then
					local nbrs = self.connectionMap and self.connectionMap[z.zone]
					if nbrs then
						local picked = 0
						for n,_ in pairs(nbrs) do
							if picked >= 2 then break end
							local nz = self:getZoneByName(n)
							if nz and nz.active and nz.side==z.side and not nz.zone:lower():find("hidden") and not nz.zone:lower():find("carrier") then
								local hasSupplyToZ = false
								for _, gc in ipairs(nz.groups or {}) do
									if gc and gc.mission == 'supply' and gc.side == z.side and gc.targetzone == z.zone then hasSupplyToZ = true break end
								end
								if hasSupplyToZ and not nz.suspended then
									supplierHold[nz] = true
									z._supplySupporters = z._supplySupporters or {}
									z._supplySupporters[nz.zone] = true
									picked = picked + 1
								end
							end
						end
						if picked < 2 then
							for n,_ in pairs(nbrs) do
								if picked >= 2 then break end
								local nz = self:getZoneByName(n)
								if nz and nz.active and nz.side==z.side and not nz.zone:lower():find("hidden") and not nz.zone:lower():find("carrier") then
									local hasSupplyToZ = false
									for _, gc in ipairs(nz.groups or {}) do
										if gc and gc.mission == 'supply' and gc.side == z.side and gc.targetzone == z.zone then hasSupplyToZ = true break end
									end
									if hasSupplyToZ and nz.suspended then
										supplierHold[nz] = true
										neighborToResume[#neighborToResume+1] = nz
										z._supplySupporters = z._supplySupporters or {}
										z._supplySupporters[nz.zone] = true
										picked = picked + 1
									end
								end
							end
						end
					end
				else
					z._supplySupporters = z._supplySupporters
				end
			end
		end
		for _, z in ipairs(self.zones) do
			if z.active and z.side==0 and not z.zone:lower():find("hidden") and not z.zone:lower():find("carrier") then
				local nbrs = self.connectionMap and self.connectionMap[z.zone]
				if nbrs then
					local picked = 0
					for n,_ in pairs(nbrs) do
						if picked >= 2 then break end
						local nz = self:getZoneByName(n)
						if nz and nz.active and nz.side~=0 and nz.suspended and not nz.zone:lower():find("hidden") and not nz.zone:lower():find("carrier") then
							local di = self:_minEnemyDistanceNm(nz)
							local li = (nz.side==2) and (GlobalSettings.autoSuspendNmBlue or 70) or (GlobalSettings.autoSuspendNmRed or 150)
							local hasOpp = false
							local nb2 = self.connectionMap and self.connectionMap[nz.zone]
							if nb2 then
								for n2,_ in pairs(nb2) do
									local oz = self:getZoneByName(n2)
									if oz and oz.active and oz.side~=0 and oz.side~=nz.side and not oz.zone:lower():find("hidden") then hasOpp = true break end
								end
							end
							local inc = false
							for _, oz in ipairs(self.zones) do
								for _, gc in ipairs(oz.groups or {}) do
									if gc and gc.targetzone == nz.zone and gc.mission == 'supply' then
										local st = gc.state
										if st ~= 'inhangar' and st ~= 'dead' then inc = true break end
									end
								end
								if inc then break end
							end
							local canR = nz:canRecieveSupply()
							local allowResume = hasOpp or (di and di <= li) or inc or canR
							if allowResume then
								neighborToResume[#neighborToResume+1] = nz
								picked = picked + 1
							end
						end
					end
				end
			end
		end
		for _, z in ipairs(self.zones) do

			if not z.zone:lower():find("hidden") and not z.zone:lower():find("carrier") then
				if z.side ~= 0 and z.active then
					local dist = self:_minEnemyDistanceNm(z)
					if dist then
						local hasOppositeNeighbor = false
						local hasNeutralNeighbor = false
						local nbrs = self.connectionMap and self.connectionMap[z.zone]
						if nbrs then
							for n,_ in pairs(nbrs) do
								local nz = self:getZoneByName(n)
								if nz and nz.active and not nz.zone:lower():find("hidden") then
									if nz.side ~= 0 and nz.side ~= z.side then hasOppositeNeighbor = true break end
									if nz.side == 0 then hasNeutralNeighbor = true end
								end
							end
						end

						local limit  = (z.side==2) and (GlobalSettings.autoSuspendNmBlue or 70) or (GlobalSettings.autoSuspendNmRed or 150)
						local combat = self._activeAttackOrPatrol and self._activeAttackOrPatrol[z.zone]
						local originActive = self._activeOrigin and self._activeOrigin[z.zone]
						local incoming = false
						for _, oz in ipairs(self.zones) do
							for _, gc in ipairs(oz.groups or {}) do
								if gc and gc.targetzone == z.zone and gc.mission == 'supply' then
									local st = gc.state
									if st ~= 'inhangar' and st ~= 'dead' then incoming = true break end
								end
							end
							if incoming then break end
						end
						local canReceive = z:canRecieveSupply()
						local shouldSuspend = (not hasOppositeNeighbor) and (not hasNeutralNeighbor) and (not combat) and (not originActive) and (not incoming) and (dist > limit) and (not canReceive) and (not supplierHold[z])

						if shouldSuspend then
							toSuspend[#toSuspend+1] = z
							--env.info(string.format("[DECIDE] suspend zone=%s dist=%.1fNm limit=%dNm combat=%s origin=%s incoming=%s canReceive=%s", z.zone, dist, limit, tostring(combat~=nil), tostring(originActive~=nil), tostring(incoming), tostring(canReceive)))
						else
							if z.suspended then
								local now = timer.getTime()
								local justSuspended = z._lastSuspendedAt and (now - z._lastSuspendedAt) < 10
								if not justSuspended then
									toResume[#toResume+1] = z
									--env.info(string.format("[DECIDE] would-resume zone=%s dist=%.1fNm limit=%dNm combat=%s origin=%s incoming=%s", z.zone, dist, limit, tostring(combat~=nil), tostring(originActive~=nil), tostring(incoming)))
								else
									--env.info(string.format("[DECIDE] skip-resume-cooldown zone=%s secs=%.1f", z.zone, now - z._lastSuspendedAt))
								end
							else
                               -- env.info(string.format("[KEEP] zone=%s oppNbr=%s neutNbr=%s combat=%s origin=%s incoming=%s dist=%.1fNm limit=%dNm canReceive=%s supplierHold=%s",z.zone,tostring(hasOppositeNeighbor),tostring(hasNeutralNeighbor),tostring(combat~=nil),tostring(originActive~=nil),tostring(incoming),dist, limit,tostring(canReceive),tostring(supplierHold[z]~=nil)))
							end
						end
					end
				end
			end
		end
		local wakeSet = {}
		for _,z in ipairs(toResume) do wakeSet[z] = true end
		for _,z in ipairs(neighborToResume) do wakeSet[z] = true end
		for z,_ in pairs(supplierHold) do wakeSet[z] = true end
		local finalSuspend = {}
		for _,z in ipairs(toSuspend) do if not wakeSet[z] then finalSuspend[#finalSuspend+1] = z end end
		for _, d in ipairs(self.zones) do
			if d._supplySupporters and not d:canRecieveSupply() then
				for name,_ in pairs(d._supplySupporters) do
					local sz = self:getZoneByName(name)
					if sz and sz.active and sz.side~=0 and not sz.zone:lower():find("hidden") and not wakeSet[sz] then
						local dist = self:_minEnemyDistanceNm(sz)
						local limit = (sz.side==2) and (GlobalSettings.autoSuspendNmBlue or 70) or (GlobalSettings.autoSuspendNmRed or 150)
						local hasOppositeNeighbor = false
						local nbrs2 = self.connectionMap and self.connectionMap[sz.zone]
						if nbrs2 then
							for n2,_ in pairs(nbrs2) do
								local oz = self:getZoneByName(n2)
								if oz and oz.active and oz.side~=0 and oz.side~=sz.side and not oz.zone:lower():find("hidden") then hasOppositeNeighbor = true break end
							end
						end
						if dist and dist <= limit then hasOppositeNeighbor = true end
						local combat2 = self._activeAttackOrPatrol and self._activeAttackOrPatrol[sz.zone]
						local originActive2 = self._activeOrigin and self._activeOrigin[sz.zone]
						local incoming2 = false
						for _, oz in ipairs(self.zones) do
							for _, gc in ipairs(oz.groups or {}) do
								if gc and gc.targetzone == sz.zone and gc.mission == 'supply' then
									local st = gc.state
									if st ~= 'inhangar' and st ~= 'dead' then incoming2 = true break end
								end
							end
							if incoming2 then break end
						end
						local canReceive2 = sz:canRecieveSupply()
						local shouldSuspend2 = (not hasOppositeNeighbor) and (not combat2) and (not originActive2) and (not incoming2) and dist and (dist > limit) and (not canReceive2)
						if shouldSuspend2 then finalSuspend[#finalSuspend+1] = sz end
					end
				end
				d._supplySupporters = nil
			end
		end
		for _,zz in ipairs(finalSuspend) do
			if not zz.suspended then zz:suspend() changed = true toUpdate[#toUpdate+1]=zz end
		end
		for _,zz in ipairs(toResume) do
			if zz.suspended then env.info("[RESUME] "..zz.zone) zz:resume() changed = true toUpdate[#toUpdate+1]=zz end
		end
		for _,zz in ipairs(neighborToResume) do
			if zz.suspended then env.info("[RESUME] "..zz.zone) zz:resume() changed = true toUpdate[#toUpdate+1]=zz end
		end
		if changed then
			SCHEDULER:New(nil,function() self:buildZoneStatusMenuForGroup() for _,zz in ipairs(toUpdate) do zz:updateLabel() end end,{},2)
		end
	end





BattleCommander.zoneStatusMenus = {}
BattleCommander.redSideMenus    = {}
BattleCommander.blueSideMenus   = {}

	function BattleCommander:buildZoneStatusMenuForGroup(groupId)
		if not groupId then
			for storedGroupId,_ in pairs(self.zoneStatusMenus) do
				self:buildZoneStatusMenuForGroup(storedGroupId)
			end
			return
		end
		if self.redSideMenus[groupId] then
			missionCommands.removeItemForGroup(groupId, self.redSideMenus[groupId])
			self.redSideMenus[groupId] = nil
		end
		if self.blueSideMenus[groupId] then
			missionCommands.removeItemForGroup(groupId, self.blueSideMenus[groupId])
			self.blueSideMenus[groupId] = nil
		end
		if not self.zoneStatusMenus[groupId] then
			self.zoneStatusMenus[groupId] = missionCommands.addSubMenuForGroup(groupId, "Zone Status")
		end
		self.redSideMenus[groupId] = missionCommands.addSubMenuForGroup(groupId,"Red Side", self.zoneStatusMenus[groupId])
		self.blueSideMenus[groupId] = missionCommands.addSubMenuForGroup(groupId,"Blue Side", self.zoneStatusMenus[groupId])
		local sub1Red, sub1Blue = nil, nil
		self.redSideZones, self.blueSideZones = {}, {}
		for i,v in ipairs(self.zones) do
			if not v.zone:lower():find("hidden") and not v.suspended then
				if v.side==1 then table.insert(self.redSideZones,v)
				elseif v.side==2 then table.insert(self.blueSideZones,v) end
			end
		end
		for i,v in ipairs(self.redSideZones) do
			if i<10 then
				missionCommands.addCommandForGroup(groupId,v.zone,self.redSideMenus[groupId],v.displayStatus,v,groupId)
			elseif i==10 then
				sub1Red=missionCommands.addSubMenuForGroup(groupId,"More",self.redSideMenus[groupId])
				missionCommands.addCommandForGroup(groupId,v.zone,sub1Red,v.displayStatus,v,groupId)
			elseif i%9==1 then
				sub1Red=missionCommands.addSubMenuForGroup(groupId,"More",sub1Red)
				missionCommands.addCommandForGroup(groupId,v.zone,sub1Red,v.displayStatus,v,groupId)
			else
				missionCommands.addCommandForGroup(groupId,v.zone,sub1Red,v.displayStatus,v,groupId)
			end
		end
		for i,v in ipairs(self.blueSideZones) do
			if i<10 then
				missionCommands.addCommandForGroup(groupId,v.zone,self.blueSideMenus[groupId],v.displayStatus,v,groupId)
			elseif i==10 then
				sub1Blue=missionCommands.addSubMenuForGroup(groupId,"More",self.blueSideMenus[groupId])
				missionCommands.addCommandForGroup(groupId,v.zone,sub1Blue,v.displayStatus,v,groupId)
			elseif i%9==1 then
				sub1Blue=missionCommands.addSubMenuForGroup(groupId,"More",sub1Blue)
				missionCommands.addCommandForGroup(groupId,v.zone,sub1Blue,v.displayStatus,v,groupId)
			else
				missionCommands.addCommandForGroup(groupId,v.zone,sub1Blue,v.displayStatus,v,groupId)
			end
		end
	end

	function BattleCommander:addTempStat(playerName, statKey, value)
		self.tempStats = self.tempStats or {}
		self.tempStats[playerName] = self.tempStats[playerName] or {}
		self.tempStats[playerName][statKey] = self.tempStats[playerName][statKey] or 0
		self.tempStats[playerName][statKey] = self.tempStats[playerName][statKey] + value
		self.sessionStats = self.sessionStats or {}
		self.sessionStats[playerName] = self.sessionStats[playerName] or {}
		self.sessionStats[playerName][statKey] = (self.sessionStats[playerName][statKey] or 0) + value
	end
	
	function BattleCommander:addStat(playerName, statKey, value)
		self.playerStats = self.playerStats or {}
		self.playerStats[playerName] = self.playerStats[playerName] or {}
		self.playerStats[playerName][statKey] = self.playerStats[playerName][statKey] or 0
		self.playerStats[playerName][statKey] = self.playerStats[playerName][statKey] + value
		self.sessionStats = self.sessionStats or {}
		self.sessionStats[playerName] = self.sessionStats[playerName] or {}
		self.sessionStats[playerName][statKey] = (self.sessionStats[playerName][statKey] or 0) + value
	end
	
	function BattleCommander:resetTempStats(playerName)
		self.tempStats = self.tempStats or {}
		self.tempStats[playerName] = {}
	end
	
	function BattleCommander:printTempStats(side, player)
		self.tempStats = self.tempStats or {}
		self.tempStats[player] = self.tempStats[player] or {}
		local sorted = {}
		for i,v in pairs(self.tempStats[player]) do table.insert(sorted,{i,v}) end
		table.sort(sorted, function(a,b) return a[1] < b[1] end)
		
		local message = '['..player..']'
		for i,v in ipairs(sorted) do
			message = message..'\n+'..v[2]..' '..v[1]
		end
		
		trigger.action.outTextForCoalition(side, message , 10)
	end
	
	function BattleCommander:printMyStats(unitid, player)
		self.playerStats = self.playerStats or {}
		self.playerStats[player] = self.playerStats[player] or {}

		local rank = nil
		local sorted2 = {}
		for i, v in pairs(self.playerStats) do
			table.insert(sorted2, {i, v})
		end
		table.sort(sorted2, function(a, b)
			return (a[2]['Points'] or 0) > (b[2]['Points'] or 0)
		end)
		for i, v in ipairs(sorted2) do
			if v[1] == player then
				rank = i
				break
			end
		end

		local playerStats = {
			['Air'] = 0,
			['Helo'] = 0,
			['Ground Units'] = 0,
			['Infantry'] = 0,
			['Ship'] = 0,
			['SAM'] = 0,
			['Structure'] = 0,
			['Deaths'] = 0,
			['Points'] = 0,
			['Points spent'] = 0
		}

		for statKey, statValue in pairs(self.playerStats[player]) do
			if statKey == 'Air' then
				playerStats['Air'] = statValue
			elseif statKey == 'Helo' then
				playerStats['Helo'] = statValue
			elseif statKey == 'SAM' then
				playerStats['SAM'] = statValue
			elseif statKey == 'Ground Units' then
				playerStats['Ground Units'] = (playerStats['Ground Units'] or 0) + statValue
			elseif statKey == 'Infantry' then
				playerStats['Infantry'] = statValue
			elseif statKey == 'Ship' then
				playerStats['Ship'] = statValue
			elseif statKey == 'Structure' then
				playerStats['Structure'] = statValue
			elseif statKey == 'Deaths' then
				playerStats['Deaths'] = statValue
			elseif statKey == 'Points' then
				playerStats['Points'] = statValue
			elseif statKey == 'Points spent' then
				playerStats['Points spent'] = statValue
				
			end
		end

		local message = rank .. ' [' .. player .. ']'

		local displayOrder = {'Air', 'Helo', 'Ground Units', 'Infantry', 'Ship', 'SAM', 'Structure', 'Deaths', 'Points', 'Points spent'}

		for _, statKey in ipairs(displayOrder) do
			message = message .. '\n' .. statKey .. ': ' .. (playerStats[statKey] or 0)
		end

		trigger.action.outTextForUnit(unitid, message, 10)
	end


	function BattleCommander:printStats(unitid, top)
		self.playerStats = self.playerStats or {}
		local sorted = {}
		for i, v in pairs(self.playerStats) do
			table.insert(sorted, {i, v})
		end
		table.sort(sorted, function(a, b)
			return (a[2]['Points'] or 0) > (b[2]['Points'] or 0)
		end)

		local message = '[Leaderboards]'
		if top then
			message = '[Top ' .. top .. ' players]'
		end

		local counter = 0
		for i, v in ipairs(sorted) do
			counter = counter + 1
			if top and counter > top then
				break
			end

			message = message .. '\n\n' .. i .. '. [' .. v[1] .. ']\n'


			local playerStats = {
				['Air'] = 0,
				['Helo'] = 0,
				['Ground Units'] = 0,
				['Ship'] = 0,
				['SAM'] = 0,
				['Structure'] = 0,
				['Deaths'] = 0,
				['Points'] = 0,
				['Points spent'] = 0,
			}

		for statKey, statValue in pairs(v[2]) do
			if statKey == 'Air' then
				playerStats['Air'] = statValue
			elseif statKey == 'Helo' then
				playerStats['Helo'] = statValue
			elseif statKey == 'SAM' then
				playerStats['SAM'] = statValue
			elseif statKey == 'Ground Units' or statKey == 'Infantry' then
				playerStats['Ground Units'] = (playerStats['Ground Units'] or 0) + statValue
			elseif statKey == 'Ship' then
				playerStats['Ship'] = statValue
			elseif statKey == 'Structure' then
				playerStats['Structure'] = statValue
			elseif statKey == 'Deaths' then
				playerStats['Deaths'] = statValue
			elseif statKey == 'Points' then
				playerStats['Points'] = statValue
			elseif statKey == 'Points spent' then
				playerStats['Points spent'] = statValue
			end
		end

			local displayOrder = {'Air', 'Helo', 'Ground Units', 'Ship', 'SAM', 'Structure', 'Deaths', 'Points', 'Points spent'}

			for _, statKey in ipairs(displayOrder) do
				message = message .. statKey .. ': ' .. (playerStats[statKey] or 0) .. '\n'
			end
		end

		if unitid then
			trigger.action.outTextForUnit(unitid, message, 15)
		else
			trigger.action.outText(message, 15)
		end
	end
	
	function BattleCommander:commitTempStats(playerName)
		self.tempStats = self.tempStats or {}
		local stats = self.tempStats[playerName]
		if stats then
			for key,value in pairs(stats) do
				self:addStat(playerName, key, value)
			end
			
			self:resetTempStats(playerName)
		end
	end


-- hunter script
function BattleCommander:initHunter(threshold)
  self.huntThreshold      = threshold or 9999
  self.huntKills          = {}
  self.huntDone           = {}
  self.huntBases          = nil
end


function BattleCommander:_buildHunterBaseList()
  local list, seen = {}, {}
  for _,z in ipairs(self.zones) do
    if z.side == 1 and z.active then
      local n = z.airbaseName
      if n and not seen[n] then
        local ab = AIRBASE:FindByName(n)
        if ab and ab:IsAirdrome() then
          list[#list+1] = ab
          seen[n]       = true
        end
      end
    end
  end
  self.huntBases = list
end

function BattleCommander:_pickHunterBase(coord,termType,need)
if not self.huntBases or #self.huntBases==0 then self:_buildHunterBaseList() end
    do
        local dirty=false
        for _,ab in ipairs(self.huntBases) do
            local abName=ab:GetName()
            local zside=nil
            for _,z in ipairs(self.zones) do if z.airbaseName==abName then zside=z.side break end end
            if zside~=1 then dirty=true break end
        end
        if dirty then self.huntBases=nil self:_buildHunterBaseList() end
    end
    local min=30*1852
    local minHard=15*1852
    local cand={}
    for _,ab in ipairs(self.huntBases) do
        if ab:GetCoalition()==coalition.side.RED then
            local d=coord:Get2DDistance(ab:GetCoordinate())
            cand[#cand+1]={ab=ab,d=d,okFar=d>=min,okMin=d>=minHard}
        end
    end
    table.sort(cand,function(a,b) return a.d<b.d end)
    local tried=0
    for pass=1,2 do
        for _,c in ipairs(cand) do
            if (pass==1 and c.okFar) or (pass==2 and c.okMin and not c.okFar) then
                local free=c.ab:GetFreeParkingSpotsTable(termType,false)
                if #free>=need then
                    table.sort(free,function(a,b)
                        local da=a.Coordinate:Get2DDistance(b.Coordinate)
                        return da<0
                    end)
                    local best1,best2,bestd=nil,nil,nil
                    for i=1,#free-1 do
                        for j=i+1,#free do
                            local d2=free[i].Coordinate:Get2DDistance(free[j].Coordinate)
                            if not bestd or d2<bestd then
                                best1,best2,bestd=free[i],free[j],d2
                            end
                        end
                    end
                    return c.ab,{best1,best2}
                end
                tried=tried+1 ; if tried==3 then return nil end
            end
        end
    end
end



function BattleCommander:_spawnHunterForPlayer(pname,u,termType)
  local unit = UNIT:FindByName(u:getName()) ; if not unit or not unit:IsAlive() then return end
  termType   = termType or AIRBASE.TerminalType.OpenMedOrBig
  local home, spots = self:_pickHunterBase(unit:GetCoordinate(), termType, 2) ; if not home then return end
  do
    local zside=nil
    local abName=home:GetName()
    for _,z in ipairs(self.zones) do if z.airbaseName==abName then zside=z.side break end end
    if zside~=1 then
      self.huntBases=nil ; self:_buildHunterBaseList()
      home, spots = self:_pickHunterBase(unit:GetCoordinate(), termType, 2) ; if not home then return end
    end
  end

  if not spots or #spots < 2 then
    env.info(string.format('HUNT-DBG: only %s free spots @%s', spots and #spots or 0, home:GetName()))
    return
  end

  table.sort(spots, function(a,b) return a.TerminalID < b.TerminalID end)

  local s1, s2
  for i = 1, #spots - 1 do
    if spots[i+1].TerminalID == spots[i].TerminalID + 1 then
      s1, s2 = spots[i].TerminalID, spots[i+1].TerminalID
      break
    end
  end
  if not s1 then s1, s2 = spots[1].TerminalID, spots[2].TerminalID end
local template = Era=='Coldwar' and 'RED_MIG23_TEMPLATE' or 'RED_MIG29_TEMPLATE'
local hunter   = SPAWN:NewWithAlias(template, 'HUNTER_'..pname)
  hunter:OnSpawnGroup(function(g)
    Hunt = FLIGHTGROUP:New(g)
    Hunt:SetHomebase(home)
    Intercept = AUFTRAG:NewINTERCEPT(unit:GetGroup())
    Hunt:AddMission(Intercept)
    Intercept:SetMissionAltitude(25000)
    Intercept:SetMissionSpeed(500)
    Hunt:MissionStart(Intercept)
	function Hunt:OnAfterTakeoff(from,event,to)
		local currentMission = self:GetMissionCurrent()
		 if (not unit:IsAlive()) and currentMission then
			currentMission:__Cancel(5) 
		end
	end
	function Hunt:OnAfterTakeoff(from,event,to)
		trigger.action.outTextForCoalition(2, pname..', Enemy is scrambling 2 jets to hunt you down!', 30)
	local BlueVictory = USERSOUND:New( "Watch your six.ogg" )
	local PlayerUnit = CLIENT:FindByPlayerName(pname)
	if PlayerUnit then
	BlueVictory:ToClient( PlayerUnit )
	end
	end
	function Hunt:OnAfterDead(from,event,to)
	bc.huntDone[pname]=nil ; bc.huntKills[pname]=0
	end
	function Hunt:OnAfterLanded(From, Event, To)
    	self:ScheduleOnce(5, function() self:Destroy() end)
	end
  end)
  hunter:SpawnAtParkingSpot(home, {s1, s2}, SPAWN.Takeoff.Hot)
  env.info('Enemy is scrambling 2 jets to hunt you down!')
  --trigger.action.outTextForUnit(u:getID(), pname..', Enemy is scrambling 2 jets to hunt you down!', 30)
end


function BattleCommander:registerHuntKill(pname, initiatorUnit)
  if not playerListBlue[pname] then return end
  if not initiatorUnit or not initiatorUnit:isExist() then return end

  local d = initiatorUnit:getDesc()
  if d and (d.category == Unit.Category.HELICOPTER or d.attributes.Helicopters) then return end

  local t = initiatorUnit:getTypeName()
  if t=="A-10C_2" or t=="A-10A" or t=="AV8BNA" then return end

  self.huntKills[pname] = (self.huntKills[pname] or 0) + 1

	if self.huntKills[pname] >= self.huntThreshold
	and not self.huntDone[pname] then
	local roll = math.random(100)
	--env.info(string.format("HUNT-DBG: roll=%d for %s", roll, pname))
	if roll < 10 then
		self.huntDone[pname] = true
		self:_spawnHunterForPlayer(pname, initiatorUnit)
	end
	end
end

	-- defaultReward - base pay, rewards = {airplane=0, helicopter=0, ground=0, ship=0, structure=0, infantry=0, sam=0, crate=0, rescue=0} - overrides
function BattleCommander:startRewardPlayerContribution(defaultReward, rewards)
	self.playerRewardsOn = true
	self.rewards = rewards
	self.defaultReward = defaultReward
	local ev = {}
	ev.context = self
	ev.rewards = rewards
	ev.default = defaultReward


	function ev:onEvent(event)
		local unit = event.initiator
		if unit and Object.getCategory(unit) == Object.Category.UNIT and (Unit.getCategoryEx(unit) == Unit.Category.AIRPLANE or Unit.getCategoryEx(unit) == Unit.Category.HELICOPTER) then
			local side = unit:getCoalition()
			local groupid = unit:getGroup():getID()
			local pname = unit:getPlayerName()
							
			if event.id == 6 then -- Pilot ejected
				if pname then
					if self.context.playerContributions[side][pname]~=nil and self.context.playerContributions[side][pname]>0 then
						local tenp=math.floor(self.context.playerContributions[side][pname]*0.25)
						self.context:addFunds(side,tenp)
						trigger.action.outTextForCoalition(side,'['..pname..'] ejected. +'..tenp..' credits (25% of earnings). Kill statistics lost.',5)
						self.context:addStat(pname,'Points',tenp)
						self.context:addTempStat(pname,'Deaths',1)
						self.context:addStat(pname,'Deaths',1)
						local initiatorObjectID=unit:getObjectID()
						local lostCredits=self.context.playerContributions[side][pname]*0.75
						self.context.playerContributions[side][pname]=0
						for _,g in pairs(MissionGroups) do g.killers[pname]=nil end
						local initiatorObjectID=event.initiator:getObjectID()
						ejectedPilotOwners[initiatorObjectID]={player=pname,lostCredits=lostCredits,coalition=side}
						if trackedGroups[groupid] then
							trackedGroups[groupid]=nil
							removeMenusForGroupID(groupid)
							for zName,groupTable in pairs(missionGroupIDs) do
								if groupTable[groupid] then
									groupTable[groupid]=nil
								end
							end
						end
						if capMissionTarget~=nil and capKillsByPlayer[pname]then
							capKillsByPlayer[pname]=0
						end
						if casMissionTarget ~= nil and casKillsByPlayer[pname] then 
							casKillsByPlayer[pname] = 0 
						end
						if Hunt then
							bc.huntDone[pname] = nil
						end	
					end
				end
			end
			if pname then
				local gObj=unit:getGroup()
				-- Pilot death (NEW)
                if event.id == 9 then -- S_EVENT_PILOT_DEAD
                    self.context:addTempStat(pname,'Deaths',1)
                    self.context:addStat(pname,'Deaths',1)
                    if trackedGroups[groupid] then
                        trackedGroups[groupid]=nil
                        removeMenusForGroupID(groupid)
                        for zName,groupTable in pairs(missionGroupIDs) do
                            if groupTable[groupid] then groupTable[groupid]=nil end
                        end
                        if Hunt then bc.huntDone[pname]=nil end
                    end
                    if capMissionTarget~=nil and capKillsByPlayer[pname] then
                        capKillsByPlayer[pname]=0
                    end
					if casMissionTarget ~= nil and casKillsByPlayer[pname] then 
						casKillsByPlayer[pname] = 0 
					end
					for _,g in pairs(MissionGroups) do g.killers[pname]=nil end
                    
                    if gObj then
                        local gName=gObj:getName()
                        local escortGroup=escortGroups[gName]
                        if escortGroup then
                            escortGroup:Destroy()
                            escortGroups[gName]=nil
                        end
                    end
                end

				if event.id == 15 then
					self.context.playerContributions[side][pname] = 0
					for _,g in pairs(MissionGroups) do g.killers[pname]=nil end
					self.context:resetTempStats(pname)
					if Hunt then
					bc.huntDone[pname] = nil
					end
				end
				if (event.id==28) then --killed unit
					if self.context.playerContributions[side][pname] ~= nil then
						if event.target.getCoalition and side ~= event.target:getCoalition() then
							local tgtName = event.target:getName()
							local mt = MissionTargets[tgtName]
							if mt then
								if mt.group then
									local gtab = MissionGroups[mt.group]
									if gtab and gtab.alive[tgtName] then
										gtab.alive[tgtName]=nil
										gtab.remaining=gtab.remaining-1
										gtab.killers[pname]=true
										if gtab.remaining==0 then
											local names={}
											for kn in pairs(gtab.killers) do
												if self.context.playerContributions[side][kn] ~= nil then
													names[#names+1]=kn
												end
											end
											local kc=#names
											if #names == 0 then return end
											local share=math.floor(gtab.reward/kc)
											for _,kn in ipairs(names) do
												bc.playerContributions[side][kn]=(bc.playerContributions[side][kn] or 0)+share
												if gtab.stat then self.context:addTempStat(kn,gtab.stat,1) end
											end
											table.sort(names)
											local plist=table.concat(names,', ')
											if kc==1 then
												local lone=names[1]
												trigger.action.outTextForCoalition(2,gtab.stat..' mission completed by '..lone..'. +'..gtab.reward..' credits - land to redeem.',15)
												trigger.action.outSoundForCoalition(2,"cancel.ogg")
											else
												trigger.action.outTextForCoalition(2,gtab.stat..' mission completed by '..plist..'. +'..share..' credits each - land to redeem.',15)
												trigger.action.outSoundForCoalition(2,"cancel.ogg")
											end
											if gtab.flag then
											if ActiveMission[gtab.flag] then ActiveMission[gtab.flag] = nil end
											CustomFlags[gtab.flag] = true
											end
											MissionGroups[mt.group]=nil
										end
									end
								else
									if self.context.playerContributions[side][pname] ~= nil then
										MissionTargets[tgtName]=nil
										bc.playerContributions[side][pname]=(bc.playerContributions[side][pname] or 0)+mt.reward
										if mt.stat then self.context:addTempStat(pname,mt.stat,1) end
										trigger.action.outTextForCoalition(2,mt.stat..' mission completed by '..pname..'. +'..mt.reward..' credits - land to redeem.',15)
										trigger.action.outSoundForCoalition(2,"cancel.ogg")
										if mt.flag then CustomFlags[mt.flag]=true end
										 if ActiveMission[mt.flag] then ActiveMission[mt.flag] = nil end
									end
								end
									if capMissionTarget ~= nil then
										if (event.target:hasAttribute('Planes') or 
											event.target:hasAttribute('Helicopters')) then
											capKillsByPlayer[pname] = (capKillsByPlayer[pname] or 0) + 1
											local killsSoFar = capKillsByPlayer[pname]
											if killsSoFar >= capTargetPlanes then
												capWinner = pname
												capMissionTarget = nil
												
											end
										end
									end
									if casMissionTarget ~= nil then
										if event.target:hasAttribute('Ground Units') or event.target:hasAttribute('SAM') or event.target:hasAttribute('Infantry') or event.target:hasAttribute('Fortifications') then
											casKillsByPlayer[pname] = (casKillsByPlayer[pname] or 0) + 1
											if casKillsByPlayer[pname] >= casTargetKills then
												casWinner = pname
												casMissionTarget = nil
											end
										end
									end
								return
							end
							local tgtCoal = event.target:getCoalition()
							if tgtCoal ~= 0 and side ~= tgtCoal then
								local earning,message,stat = self.context:objectToRewardPoints2(event.target)
								if earning and message then
									if ShowKills == true then
										trigger.action.outTextForGroup(groupid,'['..pname..'] '..message, 5)
									end
									self.context.playerContributions[side][pname] = self.context.playerContributions[side][pname] + earning
								end
								if stat then
									self.context:addTempStat(pname,stat,1)
									if Hunt and (stat=='Ground Units' or stat=='SAM' or stat=='Infantry') then bc:registerHuntKill(pname, event.initiator) end
								end
								if capMissionTarget ~= nil then
									if (event.target:hasAttribute('Planes') or 
										event.target:hasAttribute('Helicopters')) then
										capKillsByPlayer[pname] = (capKillsByPlayer[pname] or 0) + 1
										local killsSoFar = capKillsByPlayer[pname]
										if killsSoFar >= capTargetPlanes then
											capWinner = pname
											capMissionTarget = nil
											
										end
									end
								end
								if casMissionTarget ~= nil then
									if event.target:hasAttribute('Ground Units') or event.target:hasAttribute('SAM') or event.target:hasAttribute('Infantry') or event.target:hasAttribute('Fortifications') then
										casKillsByPlayer[pname] = (casKillsByPlayer[pname] or 0) + 1
										if casKillsByPlayer[pname] >= casTargetKills then
											casWinner = pname
											casMissionTarget = nil
										end
									end
								end
							end
						end
					end
				end
				if event.id==29 and next(ScoreTargets) then
					if self.context.playerContributions[side][pname] ~= nil then
						for flag,st in pairs(ScoreTargets) do
							for i,obj in ipairs(st.objects) do
								if obj and obj:GetRelativeLife()<=50 then
									st.objects[i]=nil
									st.remaining=st.remaining-1
								end
							end
							if st.remaining==0 then
								bc.playerContributions[side][pname]=(bc.playerContributions[side][pname] or 0)+st.reward
								bc:addTempStat(pname,st.stat,1)
								trigger.action.outTextForCoalition(2,st.stat..' destroyed by '..pname..'. +'..st.reward..' credits - land to redeem.',15)
								trigger.action.outSoundForCoalition(2,'cancel.ogg')
								CustomFlags[flag]=true
								ScoreTargets[flag]=nil
							end
						end
					end
					return
				end
				if event.id == 4 then -- Landing event
					if self.context.playerContributions[side][pname]~=nil and self.context.playerContributions[side][pname] 
					and self.context.playerContributions[side][pname] > 0 then
						local foundZone = false
						for i, v in ipairs(self.context:getZones()) do
							if ((side == v.side) or (v.wasBlue and side == 2)) and Utils.isInZone(unit, v.zone) then
								foundZone = true
								trigger.action.outTextForGroup(groupid, '[' .. pname .. '] landed at ' .. v.zone .. '.\nWait 5 seconds to claim credits...', 5)

								local claimfunc = function(context, zone, player, unitname)
									local un = Unit.getByName(unitname)
									if un and (Utils.isInZone(un, zone.zone) or zone.wasBlue) and Utils.isLanded(un, true) and un:getPlayerName() == player then
										if un:getLife() > 0 then
											local coalitionSide = zone.side
											if zone.wasBlue then
												coalitionSide = 2
											end
											context:addFunds(coalitionSide, context.playerContributions[coalitionSide][player])
											trigger.action.outTextForCoalition(coalitionSide, '[' .. player .. '] redeemed ' .. context.playerContributions[coalitionSide][player] .. ' credits', 15)
											context:printTempStats(coalitionSide, player)
											context:addTempStat(player, 'Points', context.playerContributions[coalitionSide][player])
											context:commitTempStats(player)
											context.playerContributions[coalitionSide][player] = 0											
											context:saveToDisk()
											if Hunt then
											bc.huntDone[pname] = nil
											end
										end
									end
								end

								SCHEDULER:New(nil,claimfunc,{self.context,v,pname,unit:getName()},5,0)
								break
							end
						end

						if not foundZone and unit:getDesc().category == Unit.Category.AIRPLANE then
							local carrierHull = GetNearestCarrierName(UNIT:Find(unit):GetCoordinate())
							if carrierHull then
								local carrierUnit   = Unit.getByName(carrierHull)
								local carrierCoord  = UNIT:Find(carrierUnit):GetCoordinate()
								local playerCoord   = UNIT:Find(unit):GetCoordinate()
								local distance      = carrierCoord:Get2DDistance(playerCoord)

								if distance < 200 then
									local prettyName = hullPrettyAndTCN(carrierHull)
									trigger.action.outTextForGroup(groupid,'[' .. pname .. '] landed on the ' .. prettyName .. '.\nWait 10 seconds to claim credits...',6)

									local claimfunc = function(context, player, unitname)
										local un = Unit.getByName(unitname)
										if un and Utils.isLanded(un,true) and un:getPlayerName() == player then
											if un:getLife() > 0 then
												local coalitionSide = un:getCoalition()
												context:addFunds(coalitionSide,context.playerContributions[coalitionSide][player])
												trigger.action.outTextForCoalition(coalitionSide,'[' .. player .. '] redeemed ' .. context.playerContributions[coalitionSide][player] .. ' credits',15)
												context:printTempStats(coalitionSide,player)
												context:addTempStat(player,'Points',context.playerContributions[coalitionSide][player])
												context:commitTempStats(player)
												context.playerContributions[coalitionSide][player] = 0
												if Hunt then bc.huntDone[pname] = nil end
											end
										end
									end
									SCHEDULER:New(nil,claimfunc,{self.context,pname,unit:getName()},10,0)
								end
							end
						end
					end
					if gObj then
						local gName = gObj:getName()
						local escortGroup = escortGroups[gName]
						if escortGroup then
							escortGroup:Destroy()
						end
					end
				end
				if CreditLosewhenKilled and CreditLosewhenKilled == true then
					if event.id == world.event.S_EVENT_UNIT_LOST then
						self.context:addFunds(side,-100)
						trigger.action.outTextForCoalition(side,'['..pname..'] aircraft lost, -100 credits',10)
					end
				end
			end
		end
	end
	world.addEventHandler(ev)

	local resetPoints = function(context, side)
		local plys = coalition.getPlayers(side)

		local players = {}
		for i, v in pairs(plys) do
			local nm = v:getPlayerName()
			if nm then
				players[nm] = true
			end
		end

		for i, v in pairs(context.playerContributions[side]) do
			if not players[i] then
				context.playerContributions[side][i] = 0
			end
		end
	end

	SCHEDULER:New(nil,resetPoints,{self,1},1,60)
	SCHEDULER:New(nil,resetPoints,{self,2},1,60)
end


	function BattleCommander:objectToRewardPoints(object) -- returns points,message
		local objName = object and object:getName() or ""
		for _, zone in ipairs(self.zones or {}) do
			for _, co in ipairs(zone.criticalObjects or {}) do
				if co == objName then
					return -- Skip awarding if it's a critical static
				end
			end
		end

		if Object.getCategory(object) == Object.Category.UNIT then
			local targetType = object:getDesc().category
			local earning = self.defaultReward
			local message = 'Unit kill +'..earning..' credits'
			
			if targetType == Unit.Category.AIRPLANE and self.rewards.airplane then
				earning = self.rewards.airplane
				message = 'Aircraft kill +'..earning..' credits'
			elseif targetType == Unit.Category.HELICOPTER and self.rewards.helicopter then
				earning = self.rewards.helicopter
				message = 'Helicopter kill +'..earning..' credits'
			elseif targetType == Unit.Category.GROUND_UNIT then
				if (object:hasAttribute('SAM SR') or object:hasAttribute('SAM TR') or object:hasAttribute('IR Guided SAM')) and self.rewards.sam then
					earning = self.rewards.sam
					message = 'SAM kill +'..earning..' credits'							
				elseif object:hasAttribute('Infantry') and self.rewards.infantry then
					earning = self.rewards.infantry
					message = 'Infantry kill +'..earning..' credits'
				else
					earning = self.rewards.ground
					message = 'Ground kill +'..earning..' credits'
				end
			elseif targetType == Unit.Category.SHIP and self.rewards.ship then
				earning = self.rewards.ship
				message = 'Ship kill +'..earning..' credits'
			elseif targetType == Unit.Category.STRUCTURE and self.rewards.structure then
				earning = self.rewards.structure
				message = 'Structure kill +'..earning..' credits'
			end
			
			return earning,message
		end
	end
	
	function BattleCommander:objectToRewardPoints2(object) -- returns points,message
		
		local objName = object and object:getName() or ""
		for _, zone in ipairs(self.zones or {}) do
			for _, co in ipairs(zone.criticalObjects or {}) do
				if co == objName then
					return -- Skip awarding if it's a critical static
				end
			end
		end
		
		local earning = self.defaultReward
		local message = 'Unit kill +'..earning..' credits'
		local statname = 'Ground Units'
		
		if object:hasAttribute('Planes') and self.rewards.airplane then
			earning = self.rewards.airplane
			message = 'Aircraft kill +'..earning..' credits'
			statname = 'Air'
		elseif object:hasAttribute('Helicopters') and self.rewards.helicopter then
			earning = self.rewards.helicopter
			message = 'Helicopter kill +'..earning..' credits'
			statname = 'Helo'
		elseif (object:hasAttribute('SAM SR') or object:hasAttribute('SAM TR') or object:hasAttribute('IR Guided SAM')) and self.rewards.sam then
			earning = self.rewards.sam
			message = 'SAM kill +'..earning..' credits'
			statname = 'SAM'
		elseif object:hasAttribute('Infantry') and self.rewards.infantry then
			earning = self.rewards.infantry
			message = 'Infantry kill +'..earning..' credits'
			statname = 'Infantry'
		elseif object:hasAttribute('Ships') and self.rewards.ship then
			earning = self.rewards.ship
			message = 'Ship kill +'..earning..' credits'
			statname = 'Ship'
		elseif object:hasAttribute('Ground Units') then
			earning = self.rewards.ground
			message = 'Vehicle kill +'..earning..' credits'
			statname = 'Ground Units'
		elseif object:hasAttribute('Buildings') and self.rewards.structure then
			earning = self.rewards.structure
			message = 'Structure kill +'..earning..' credits'
			statname = 'Structure'
		elseif Object.getCategory(object) == Object.Category.STATIC then
			local desc = object:getDesc()
			if desc and desc.category == 4 and self.rewards.structure then
				local name = object:getName()
				local foundInBuilt = false
				local isCritical = false
		
				for _, zone in ipairs(self.zones or {}) do
					if zone.built then
						for _, builtName in pairs(zone.built) do
							if builtName == name then
								foundInBuilt = true
								break
							end
						end
					end
		
					if foundInBuilt then
						if zone.criticalObjects then
							for _, critName in ipairs(zone.criticalObjects) do
								if critName == name then
									isCritical = true
									break
								end
							end
						end
						break
					end
				end
		
				if not foundInBuilt or isCritical then
					earning = nil
					message = nil
					statname = nil
				else
					earning = self.rewards.structure
					message = 'Structure kill +'..earning..' credits'
					statname = 'Structer'
				end
			end
		else
			return -- object does not have any of the attributes
		end
		return earning,message,statname
	end
	
	function BattleCommander:update()
		for i,v in ipairs(self.zones) do
			v:update()
			
		end
		
		for i,v in ipairs(self.monitorROE) do
			self:checkROE(v)
		end
		
		if self.difficulty then
			if timer.getAbsTime()-self.lastDiffChange > self.difficulty.fadeTime then
				self:decreaseDifficulty()
			end
		end
	end
	


	function BattleCommander:saveToDisk()
			local statedata = self:getStateTable()
			statedata.customFlags       = CustomFlags
			statedata.globalExtraUnlock = self.globalExtraUnlock
			Utils.saveTable(self.saveFile,'zonePersistance',statedata)
	end


	function BattleCommander:loadFromDisk()
		Utils.loadTable(self.saveFile)
		if zonePersistance then
			if zonePersistance.zones then
				for i, v in pairs(zonePersistance.zones) do
					local zn = self:getZoneByName(i)
					if zn then
						zn.side = v.side
						zn.level = v.level
						
						if v.remainingUnits then
							zn.remainingUnits = v.remainingUnits
						end
						
						if type(v.active) == 'boolean' then
							zn.active = v.active
						end
						
					zn.extraUpgrade = v.extraUpgrade or {}
					if #zn.extraUpgrade > 0 then
						for _,grp in ipairs(zn.extraUpgrade) do
							if zn.side == 2 then
								table.insert(zn.upgrades.blue, grp)
							elseif zn.side == 1 then
								table.insert(zn.upgrades.red,  grp)
							end
						end
					end
					zn.upgradesUsed = v.upgradesUsed or 0

						if not zn.active then
							zn.side = 0
							zn.level = 0
						end
						
						if v.destroyed then
							zn.destroyOnInit = v.destroyed
						end
						
						if v.triggers then
							for i2, v2 in ipairs(zn.triggers) do
								local tr = v.triggers[v2.id]
								if tr then
									v2.hasRun = tr
								end
							end
						end
						if zonePersistance.globalExtraUnlock then
							self.globalExtraUnlock = true
						end
												
						zn.wasBlue = v.wasBlue or false

						zn.firstCaptureByRed = v.firstCaptureByRed or false 
					end
				end
			end
			
			if zonePersistance.accounts then
				self.accounts = zonePersistance.accounts
			end
			
			if zonePersistance.shops then
				local merged = {}
				for side = 1,2 do
					merged[side] = {}
					for id,def in pairs(self.shops[side] or {}) do
						if def.stock == -1 then
							merged[side][id] = {name=def.name,cost=def.cost,stock=-1,prio=def.prio}
						end
					end
					for id,saved in pairs(zonePersistance.shops[side] or {}) do
						merged[side][id] = saved
					end
				end
				self.shops = merged
			end
			
			if zonePersistance.difficultyModifier then
				self.difficultyModifier = zonePersistance.difficultyModifier
				if self.difficulty then
					GlobalSettings.setDifficultyScaling(self.difficulty.start + self.difficultyModifier, self.difficulty.coalition)
				end
			end
			
			if zonePersistance.playerStats then
				self.playerStats = zonePersistance.playerStats
			end
			
			if zonePersistance.customFlags then
				CustomFlags = zonePersistance.customFlags
			end
		end
	end
end

ZoneCommander = {}
do
	--{ zone='zonename', side=[0=neutral, 1=red, 2=blue], level=int, upgrades={red={}, blue={}}, crates={}, flavourtext=string, income=number }
	function ZoneCommander:new(obj)
		obj = obj or {}
		obj.built = {}
		obj.index = -1
		obj.battleCommander = {}
		obj.groups = {}
		obj.restrictedGroups = {}
		obj.criticalObjects = {}
		obj.active = true
		obj.destroyOnInit = {}
		obj.triggers = {}
		obj.upgradesUsed = 0
		obj.suspended = false
		obj._hibernated = {}

		if obj.upgrades then
		local nb={} for i,v in ipairs(obj.upgrades.blue) do nb[i]=v end
		local nr={} for i,v in ipairs(obj.upgrades.red)  do nr[i]=v end
		obj.upgrades={blue=nb,red=nr}
		end
		
		if obj.side ~= 0 then
			obj.firstCaptureByRed = true

		end
		
		setmetatable(obj, self)
		self.__index = self
		return obj
	end

--[[
	function ZoneCommander:addExtraSlot(groupName)
		if self.upgradesUsed >= 1 + (bc.globalExtraUnlock and 1 or 0) then return end
		self.upgradesUsed  = self.upgradesUsed + 1
		self.extraUpgrade  = self.extraUpgrade or {}
		table.insert(self.extraUpgrade, groupName)
		self.level         = self.level + 1
		if self.side == 2 then
			table.insert(self.upgrades.blue, groupName)
		elseif self.side == 1 then
			table.insert(self.upgrades.red,  groupName)
		end
	end
 ]]

	function ZoneCommander:_builtHas(name)
		for i,v in pairs(self.built) do
			if v == name then return true end
		end
		return false
	end

function ZoneCommander:suspend()
		self.suspended = true
		env.info("[SUSPEND] "..self.zone)
		if not self.remainingUnitsSnapshot then
			local snap = {}
			for i2,v2 in pairs(self.built) do
				local gr = Group.getByName(v2)
				if gr then
					local units = gr:getUnits()
					if units and #units > 0 then
						snap[i2] = {}
						for _,u in ipairs(units) do
							table.insert(snap[i2], u:getDesc().typeName)
						end
					end
				end
			end
			self.remainingUnitsSnapshot = snap
		end
		for _, gName in pairs(self.built) do
			local g = Group.getByName(gName)
			if g and g:isExist() and g:getSize() > 0 then
				self._hibernated[gName] = true
				g:destroy()
			end
		end
	end

	function ZoneCommander:resume()
			self.suspended = false
			local cz = CustomZone:getByName(self.zone)
			local pending = {}
			for gName,_ in pairs(self._hibernated or {}) do
				if Group.getByName(gName) then
					if self:_builtHas(gName) then
					else
						pending[gName] = true
					end
				else
					local ok = false
					if cz and cz.spawnGroup then
						local r = cz:spawnGroup(gName,false)
						if r and r.name then
							for i,v in pairs(self.built) do
								if v == gName then self.built[i] = r.name break end
							end
							if Group.getByName(r.name) then
								ok = true
							else
								pending[r.name] = true
							end
						end
					end
					if not ok and not pending[gName] then
						pending[gName] = true
					end
				end
			end
			self._hibernated = pending
		end
	
	function ZoneCommander:addExtraSlot(groupName)
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		local cur = self.upgradesUsed or 0
		if cur >= max then return false end

		self.upgradesUsed = cur + 1
		self.level        = self.level + 1

		self.extraUpgrade = self.extraUpgrade or {}
		table.insert(self.extraUpgrade, groupName)

		if self.side == 2 then
			table.insert(self.upgrades.blue, groupName)
		elseif self.side == 1 then
			table.insert(self.upgrades.red , groupName)
		end

		return true
	end

	function ZoneCommander:getFilteredUpgrades()
																								
		local upgrades
		if self.side == 1 then
			upgrades = self.upgrades.red
		elseif self.side == 2 then
			upgrades = self.upgrades.blue
		else
			upgrades = {}
		end

		if UseStatics then return upgrades end
	
		local res = {}
		for idx, name in pairs(upgrades) do
			local isStatic = false
			if self.newStatics then
				for _, data in ipairs(self.newStatics) do
					if data.name == name then
						isStatic = true
						break
					end
				end
			end
	
			if isStatic then
				local st = StaticObject.getByName(name)
				if st and st:isExist() then st:destroy() end
			else
				res[#res + 1] = name
			end
		end
		return res
	end
	

	function ZoneCommander:addRestrictedPlayerGroup(groupinfo)
		table.insert(self.restrictedGroups, groupinfo)
	end
	
	function ZoneCommander:markWithSmoke(requestingCoalition)
		if requestingCoalition and (self.side ~= requestingCoalition and self.side ~= 0) then
			return
		end
	
		local zone = CustomZone:getByName(self.zone)
		local p = Utils.getPointOnSurface(zone.point)
		trigger.action.smoke(p, 0)
	end
	
	--if all critical onjects are lost in a zone, that zone turns neutral and can never be recaptured
	function ZoneCommander:addCriticalObject(staticname)
		table.insert(self.criticalObjects, staticname)
	end
	
	function ZoneCommander:getDestroyedCriticalObjects()
		local destroyed = {}
		for i,v in ipairs(self.criticalObjects) do
			local st = StaticObject.getByName(v)
			if not st or st:getLife()<1 then
				table.insert(destroyed, v)
			end
		end
		
		return destroyed
	end
	
	--zone triggers 
	-- trigger types= captured, upgraded, repaired, lost, destroyed
	function ZoneCommander:registerTrigger(eventType, action, id, timesToRun)
		table.insert(self.triggers, {eventType = eventType, action = action, id = id, timesToRun = timesToRun, hasRun=0})
	end
	
	--return true from eventhandler to end event after run
	function ZoneCommander:runTriggers(eventType)
		for i,v in ipairs(self.triggers) do
			if v.eventType == eventType then
				if not v.timesToRun or v.hasRun < v.timesToRun then
					v.action(v,self)
					v.hasRun = v.hasRun + 1
				end
			end
		end
	end
	--end zone triggers
	-------------------------------------------------------- DISABLE FRIENDLY ZONE ---------------------------------------------------------------------------

	function ZoneCommander:disableFriendlyZone(force)
		if not force then	
			if not self.active or not self.wasBlue then return false end
		end
		if (self.active and self.side == 2) or force then
			self.wasBlue = true
			print("Zone was blue before disabling: " .. self.zone)

			for i, v in pairs(self.built) do
				local gr = Group.getByName(v)
				if gr and gr:getSize() > 0 then
					gr:destroy()
				elseif gr and gr:getSize() == 0 then
					gr:destroy()
				end

				if not gr then
					local st = StaticObject.getByName(v)
					if st and st:getLife() < 1 then
						st:destroy()
					end
				end

				self.built[i] = nil    
			end

			self.side = 0
			self.active = false
			
			if self.airbaseName then
				env.info("Disabling airbase " .. self.airbaseName)
				local ab = Airbase.getByName(self.airbaseName)
				if ab then
					if self.wasBlue and not self.active then
						if ab:autoCaptureIsOn() then ab:autoCapture(false) end
						ab:setCoalition(2)
						if RespawnStaticsForAirbase then
							RespawnStaticsForAirbase(self.airbaseName, 2)
						end
					end
				else
					env.info("Airbase " .. self.airbaseName .. " is not found")
				end
			end
			if self.wasBlue and not self.active then
				trigger.action.setMarkupColor(2000 + self.index, {0, 0, 0.7, 1})
				trigger.action.setMarkupColorFill(self.index, {0, 0, 1, 0.3})
				trigger.action.setMarkupColor(self.index, {0, 0, 1, 0.3})
				
				if self.isHeloSpawn then
					trigger.action.setMarkupTypeLine(self.index, 2)
					trigger.action.setMarkupColor(self.index, {0, 1, 0, 1})
				end
			end
			
			self:runTriggers('FriendlyDestroyed')
            self:updateLabel()
		end
	end

	function ZoneCommander:DestroyHiddenZone()
	if not self.active or not self.side == 1 then return false end
		print("Destroying Hidden zone" .. self.zone)

		for i, v in pairs(self.built) do
			local gr = Group.getByName(v)
			if gr and gr:getSize() > 0 then
				gr:destroy()
			elseif gr and gr:getSize() == 0 then
				gr:destroy()
			end

			if not gr then
				local st = StaticObject.getByName(v)
				if st and st:getLife() < 1 then
					st:destroy()
				end
			end

			self.built[i] = nil    
		end

		self.side = 0
		self.active = false
	end

	function ZoneCommander:disableZone()
    if self.active then
        if self.side == 2 then
            self.wasBlue = true
        elseif self.side == 1 then
            self.wasBlue = false
        else
            self.wasBlue = false
        end

        for i, v in pairs(self.built) do
            local gr = Group.getByName(v)
            if gr and gr:getSize() == 0 then
                gr:destroy()
            end
            if not gr then
                local st = StaticObject.getByName(v)
                if st and st:getLife() < 1 then
                    st:destroy()
                end
            end
            self.built[i] = nil    
        end

        self.side = 0
		if CheckJtacStatus then
			CheckJtacStatus()
		end
        self.active = false
		
		if SpawnFriendlyAssets then
		
			SCHEDULER:New(nil,SpawnFriendlyAssets,{},5,0)
		end
        if GlobalSettings.messages.disabled then
            trigger.action.outText(self.zone .. ' has been destroyed', 5)
			if trigger.misc.getUserFlag(180) == 0 then
				trigger.action.outSoundForCoalition(2, "ding.ogg")
			end
		end
		if not self.active then
			trigger.action.setMarkupColor(2000 + self.index, {0.1,0.1,0.1,1})
			trigger.action.setMarkupColorFill(self.index, {0.1,0.1,0.1,0.3})
			trigger.action.setMarkupColor(self.index, {0.1,0.1,0.1,0.3})
		end
		self:runTriggers('destroyed')
		bc:buildConnectionMap()
		--bc:_autoZoneSuspend()
		bc:_buildHunterBaseList()
		bc:_hasActiveAttackOrPatrolOnZone()	
        self:updateLabel()       
    end
end
	
intelActiveZones = intelActiveZones or {}

function ZoneCommander:displayStatus(grouptoshow, messagetimeout, overrideIntel)
    local upgrades=0
    local sidename='Neutral'
    if self.side==1 then
        sidename='Red'
        upgrades = #self:getFilteredUpgrades()
    elseif self.side==2 then
        sidename='Blue'
        upgrades = #self:getFilteredUpgrades()
    end
    if not self.active then
        sidename='None'
    end
    if not self.active and self.wasBlue then
        sidename='Blue'
    end
    local count=0
    if self.built then
        count=Utils.getTableSize(self.built)
    end
    local count = 0
    if self.built then
        count = Utils.getTableSize(self.built)
    end

    local intelTime  = ""
    local intelActive = (intelActiveZones[self.zone] == true)
    local jtacActive  = (jtacIntelActive and jtacIntelActive[self.zone] == true)

    if intelActive and intelExpireTimes[self.zone] then
        local r = math.max(0, math.floor((intelExpireTimes[self.zone] - timer.getTime()) / 60))
        intelTime = "\nIntel: " .. r .. " min remaining"
    end

    status = self.zone .. " status\n Controlled by: " .. sidename .. intelTime
	local function cleanName(s) return (s:gsub("%s*#%s*%d+",""):gsub("%s+Fixed",""):gsub("%s%s+"," "):gsub("^%s+",""):gsub("%s+$","")) end

    local isEnemy     = (self.side == 1)
    local canSeeEnemy = intelActive or jtacActive
    if overrideIntel and isEnemy then
        canSeeEnemy = true
    end
    if isEnemy and bc.shops and bc.shops[2] and bc.shops[2].intel then
        if canSeeEnemy and self.built and count>0 then
            status=status.."\n Upgrades: "..count.."/"..upgrades
            status=status.."\n Groups:"
            for i,v in pairs(self.built) do
                local gr=Group.getByName(v)
                if gr then
                    local grhealth=math.ceil((gr:getSize()/gr:getInitialSize())*100)
                    grhealth=math.min(grhealth,100)
                    grhealth=math.max(grhealth,1)
                    status=status.."\n  "..cleanName(v).." "..grhealth.."%"
                else
                    local st=StaticObject.getByName(v)
                    if st then
                        status=status.."\n  "..cleanName(v).." 100%"
                    end
                end
            end
        else
            status=status.."\n\nBuy intel or deploy a JTAC to gather information on enemy units."
        end
    else
        if self.built and count>0 then
            status=status.."\n Upgrades: "..count.."/"..upgrades
            status=status.."\n Groups:"
            for i,v in pairs(self.built) do
                local gr=Group.getByName(v)
                if gr then
                    local grhealth=math.ceil((gr:getSize()/gr:getInitialSize())*100)
                    grhealth=math.min(grhealth,100)
                    grhealth=math.max(grhealth,1)
                    status=status.."\n  "..v.." "..grhealth.."%"
                else
                    local st=StaticObject.getByName(v)
                    if st then
                        status=status.."\n  "..v.." 100%"
                    end
                end
            end
        end
    end
    if self.flavorText and self.active then
        status=status.."\n\n"..self.flavorText
    end
    if not self.active and not self.wasBlue then
        status=status.."\n\n WARNING: This zone has been irreparably damaged and is no longer of any use"
    end
    if not self.active and self.wasBlue then
        status=status.."\n\nFriendly zone. All units have repositioned near the front line."
        if self.isHeloSpawn then
            status=status.."\n\nFarp/Airfield is operational."
        end
    end
    local zn=CustomZone:getByName(self.zone)
	if zn then
		local pnt      = zn.point
		local c        = COORDINATE:NewFromVec3(pnt)
		local lat, lon = coord.LOtoLL(pnt)

		local function ddm(v,h)
			local d = math.floor(math.abs(v))
			local m = (math.abs(v) - d) * 60
			return string.format("[%s %02d %06.3f']", h, d, m)
		end
		local function dms(v,h)
			local av = math.abs(v)
			local d  = math.floor(av)
			local m  = math.floor((av - d) * 60)
			local s  = ((av - d) * 60 - m) * 60
			return string.format("[%s %02d %02d' %05.2f\"]", h, d, m, s)
		end

		local ddmStr = ddm(lat, lat >= 0 and "N" or "S") .. "⇢ " .. ddm(lon, lon >= 0 and "E" or "W")
		local dmsStr = dms(lat, lat >= 0 and "N" or "S") .. "⇢ " .. dms(lon, lon >= 0 and "E" or "W")
		local mgrs   = c:ToStringMGRS():gsub("^MGRS%s*", "")
		local alt    = c:GetLandHeight()

		status = status
			.. "\n\nDDM:  " .. ddmStr
			.. "\nDMS:  " .. dmsStr
			.. "\nMGRS: " .. mgrs
			.. "\n\nAlt: " .. math.floor(alt) .. "m | " .. math.floor(alt * 3.280839895) .. "ft"
	end
	local timeout = messagetimeout or 15
	if grouptoshow then
		trigger.action.outTextForGroup(grouptoshow, status, timeout)
	else
		trigger.action.outText(status, timeout)
	end
end


---------------------- Capture a zone on command BLUE ---------------------------------

function ZoneCommander:MakeZoneBlue()
	if not self.active or self.wasBlue then return
	end
    if self.active and not self.wasBlue then
        BASE:I("Making this zone Blue: " .. self.zone)
        local unitsInZone = coalition.getGroups(1)
        for _, group in ipairs(unitsInZone) do
            local groupUnits = group:getUnits()
            for _, unit in ipairs(groupUnits) do
                if Utils.isInZone(unit, self.zone) then
                    unit:destroy()
                end
            end
        end
        timer.scheduleFunction(function()
            self:capture(2,true)
            BASE:I("Zone captured by Blue: " .. self.zone)
			self.wasBlue = true
        end, nil, timer.getTime() + 12)
    else
        BASE:I("Zone is either inactive or not controlled by the blue side, no action taken.")
    end
end

function ZoneCommander:MakeZoneRed()
    if self.active and self.side == 0 and self.NeutralAtStart and not self.firstCaptureByRed then
        BASE:I("Making this zone Red: " .. self.zone)

        timer.scheduleFunction(function()
            self:capture(1, true)
            BASE:I("Zone captured by Red: " .. self.zone)
        end, {}, timer.getTime() + 2)
    else
        BASE:I("Zone is either inactive or not eligible for red capture, no action taken.")
    end
end
---------------------- Capture a zone on command RED ---------------------------------      
function ZoneCommander:MakeZoneRedAndUpgrade()
    if self.active and self.side==0 and self.NeutralAtStart and not self.firstCaptureByRed then
        self:capture(1,true)
        local upgrades=self:getFilteredUpgrades()
        local totalUpgrades=#upgrades
               local function upgradeZone()
            local builtNow=Utils.getTableSize(self.built)
            if builtNow<totalUpgrades then
                self:upgrade(true)
                builtNow=Utils.getTableSize(self.built)
                timer.scheduleFunction(upgradeZone,{},timer.getTime()+2)
            end
        end
        timer.scheduleFunction(upgradeZone,{},timer.getTime()+1)
    else
        BASE:I("Zone " ..self.zone.. " is either inactive or not eligible for red capture and upgrade, no action taken.")
    end
end

function ZoneCommander:MakeZoneRedAndUpgraded() -- for disabledfriendlyzone to make them go red and suspend
    if self.side==0 and self.NeutralAtStart and not self.firstCaptureByRed then
        self:capture(1, true)
        local upgrades=self:getFilteredUpgrades()
        local totalUpgrades=#upgrades
        local function upgradeZone()
            local builtNow=Utils.getTableSize(self.built)
            if builtNow<totalUpgrades then
                self:upgrade(true)
                timer.scheduleFunction(upgradeZone,{},timer.getTime()+2)
            end
        end
        timer.scheduleFunction(upgradeZone,{},timer.getTime()+1)
    end
end

------------------------ UPGRADE RED ZONE ON COMMAND ------------------------------------

function ZoneCommander:MakeRedZoneUpgraded()
    if self.active and self.side==1 then
        local upgrades=self:getFilteredUpgrades()
        local totalUpgrades=#upgrades
        local function upgradeZone()
            local builtNow=Utils.getTableSize(self.built)
            if builtNow<totalUpgrades then
                self:upgrade(true)

                builtNow=Utils.getTableSize(self.built)
                BASE:I("Zone upgraded "..builtNow.."/"..totalUpgrades.." for Red: "..self.zone)
                timer.scheduleFunction(upgradeZone,{},timer.getTime()+2)
            else
                BASE:I("Zone fully upgraded for Red: "..self.zone)
            end
        end
        timer.scheduleFunction(upgradeZone,{},timer.getTime()+1)
    else
        BASE:I("Zone is either inactive or not Red, no action taken.")
    end
end
---------------------- End of Capture a zone on command ---------------------------------
----------------------- upgrade all red zones --------------------------

function upgradeRedZones()
    if upgradeRedZonesBusy then
        trigger.action.outText("Upgrade process is already running.", 15)
        return
    end
    upgradeRedZonesBusy = true
	
    local redZones = {}
    local zones = bc:getZones()
    for i, v in ipairs(zones) do
        if not v.zone:lower():find("hidden") and v.side == 1 then
            local z = bc:getZoneByName(v.zone)
            if z and z.side == 1 then
                local function needsRepair()
                    for _,name in pairs(z.built or {}) do
                        if not string.find(name,"dismounted") then
                            local base = string.gsub(name,"#%d+$","")
                            local isStatic = false
                            for _,data in ipairs(z.newStatics or {}) do if data.name == base then isStatic = true break end end
                            if isStatic then
                                local so = StaticObject.getByName(name) or StaticObject.getByName(base)
                                if not so or (so.isExist and not so:isExist()) then return true end
                            else
                                local gr = GROUP:FindByName(name)
                                if gr and gr:IsAlive() then
                                    local sz = gr:GetSize()
                                    local isz = gr:GetInitialSize()
                                    if (isz and sz and sz < isz) or (not isz) then return true end
                                else
                                    return true
                                end
                            end
                        end
                    end
                    return false
                end
                local upgrades = z:getFilteredUpgrades()
                local totalUpgrades = #upgrades
                local builtNow = Utils.getTableSize(z.built or {})
                if needsRepair() or (totalUpgrades > 0 and builtNow < totalUpgrades) then
                    BASE:I("upgradeRedZones: candidate " .. tostring(v.zone))
                    table.insert(redZones, v.zone)
                end
            end
        end
    end
    if #redZones == 0 then
        BASE:I("All red zones are now fully upgraded.")
        trigger.action.outText("All red zones are now fully upgraded.", 15)
        upgradeRedZonesBusy = false
        return
    end
	trigger.action.outText('Command accepted, pending', 20)
    local function process(idx)
        local zname = redZones[idx]
        if zname then
            local z = bc:getZoneByName(zname)
            if z and z.side == 1 then
                local upgrades = z:getFilteredUpgrades()
                local totalUpgrades = #upgrades
                local function needsRepair()
                    for _,name in pairs(z.built or {}) do
                        if not string.find(name,"dismounted") then
                            local base = string.gsub(name,"#%d+$","")
                            local isStatic = false
                            for _,data in ipairs(z.newStatics or {}) do if data.name == base then isStatic = true break end end
                            if isStatic then
                                local so = StaticObject.getByName(name) or StaticObject.getByName(base)
                                if not so or (so.isExist and not so:isExist()) then return name end
                            else
                                local gr = GROUP:FindByName(name)
                                if gr and gr:IsAlive() then
                                    local sz = gr:GetSize()
                                    local isz = gr:GetInitialSize()
                                    if (isz and sz and sz < isz) or (not isz) then return name end
                                else
                                    return name
                                end
                            end
                        end
                    end
                    return nil
                end
                local builtNow = Utils.getTableSize(z.built or {})
                local need = needsRepair()
                if need or (totalUpgrades > 0 and builtNow < totalUpgrades) then
                    BASE:I("Upgrading Red zone: " .. z.zone .. " (" .. builtNow .. "/" .. totalUpgrades .. ")")
                    local function upgradeZone()
                        local target = needsRepair()
                        if target then
                            local gr = GROUP:FindByName(target)
                            if gr and gr:GetSize() and gr:GetInitialSize() and gr:GetSize() < gr:GetInitialSize() then
                                CustomRespawn(target)
                            else
                                local cz = CustomZone:getByName(z.zone)
                                if not cz or not cz.spawnGroup then
                                    BASE:E("upgradeRedZones: spawnGroup missing for zone "..tostring(z.zone).." target="..tostring(target))
                                else
                                    BASE:I("upgradeRedZones: respawning target "..tostring(target).." in zone "..tostring(z.zone))
                                    local baseTarget = string.gsub(target,"#%d+$","")
                                    local isStatic = false
                                    local stData = nil
                                    for _,data in ipairs(z.newStatics or {}) do if data.name == baseTarget then isStatic = true stData = data break end end
                                    if isStatic and stData then
                                        if stData.country == 1 then stData.country = country.id.RUSSIA else stData.country = country.id.USA end
                                        local spawnTemplate = { name = stData.name, type = stData.type, country = stData.country, shape_name = stData.shapeName, heading = math.rad(stData.heading), position = stData.point }
                                        local spawnStatic = SPAWNSTATIC:NewFromTemplate(spawnTemplate, stData.country)
                                        local spawnedObject = spawnStatic:SpawnFromCoordinate(COORDINATE:NewFromVec3(stData.point))
                                        if spawnedObject then
                                            z.built = z.built or {}
                                            for i,name in pairs(z.built) do
                                                local b = string.gsub(name,"#%d+$","")
                                                if name == target or b == baseTarget then z.built[i] = spawnedObject:GetName() break end
                                            end
                                        end
                                    else
                                        local g = cz:spawnGroup(target,false)
                                        if g and g.name then
                                            z.built = z.built or {}
                                            for i,name in pairs(z.built) do if name == target then z.built[i] = g.name break end end
                                        end
                                    end
                                end
                            end
                            timer.scheduleFunction(upgradeZone, {}, timer.getTime() + 2)
                        else
                            local b = Utils.getTableSize(z.built or {})
                            if totalUpgrades > 0 and b < totalUpgrades then
                                z:upgrade(true)
                                timer.scheduleFunction(upgradeZone, {}, timer.getTime() + 2)
                            else
                                BASE:I("Zone fully upgraded for Red: " .. z.zone)
                            end
                        end
                    end
                    timer.scheduleFunction(upgradeZone, {}, timer.getTime() + 1)
                else
                    BASE:I("Zone already fully upgraded for Red: " .. z.zone)
                end
            end
            timer.scheduleFunction(function() process(idx + 1) end, {}, timer.getTime() + 10)
        else
			BASE:I("All red zones are now fully upgraded.")
            trigger.action.outText("All red zones are now fully upgraded.", 15)
            upgradeRedZonesBusy = false
        end
    end
    process(1)
end

----------------------- end upgrade all red zones --------------------------

function ZoneCommander:MakeZoneNeutralAgain()
    if not self.active or self.wasBlue then
        return
    end

	self:killAll()

    timer.scheduleFunction(function()
        self.firstCaptureByRed = false
        BASE:I("Zone " .. self.zone .. " has been reset to neutral.")
    end, nil, timer.getTime() + 5)
end
-------------------------- RECAPTURE BLUE ZONE FROM DISABLED STATE ---------------------      
	function ZoneCommander:RecaptureBlueZone()
		env.info("Recapturing Blue zone: " .. self.zone)
	if self.active then
		BASE:I("Zone is already active: " .. self.zone)
		return
	end
		self.active = true
	timer.scheduleFunction(function()
		
		self:capture(2,true)
		
		BASE:I("Zone: " .. self.zone .. " is now active again")

	end, {}, timer.getTime() + 2)
end


-------------------------- RECAPTURE BLUE ZONE FROM DISABLED STATE ---------------------
function ZoneCommander:MakeZoneRed()
    if self.active and self.side == 0 and self.NeutralAtStart and not self.firstCaptureByRed then
        BASE:I("Making this zone Red: " .. self.zone)

        timer.scheduleFunction(function()
            self:capture(1, true)
            BASE:I("Zone captured by Red: " .. self.zone)
        end, {}, timer.getTime() + 2)
    else
        BASE:I("Zone is either inactive or not eligible for red capture, no action taken.")
    end
end
-------------------------------- maxxa --------------------------------------------------------


function ZoneCommander:MakeZoneSideAndUpgraded()
    if self.active and self.side~=0 and not self.suspended then
        self:capture(self.side, true)
		local upgrades=self:getFilteredUpgrades()
        local totalUpgrades=#upgrades
        local sideText=(self.side==1) and "Red" or "Blue"
        BASE:I("Zone captured by "..sideText..": "..self.zone.." ("..Utils.getTableSize(self.built).."/"..totalUpgrades..")")
        local function upgradeZone()
            local builtNow=Utils.getTableSize(self.built)
            if builtNow<totalUpgrades then
                self:upgrade(true)
                builtNow=Utils.getTableSize(self.built)
                timer.scheduleFunction(upgradeZone,{},timer.getTime()+2)
            else
                BASE:I("Zone fully upgraded for "..sideText..": "..self.zone)
            end
        end
        timer.scheduleFunction(upgradeZone,{},timer.getTime()+1)
    end
end

function ZoneCommander:init()
	local zone = CustomZone:getByName(self.zone)
	if not zone then
		trigger.action.outText('ERROR: zone ['..self.zone..'] cannot be found in the mission', 60)
		env.info('ERROR: zone ['..self.zone..'] cannot be found in the mission')
	end

	local color = {0.7, 0.7, 0.7, 0.3}
	local textColor = {0.3, 0.3, 0.3, 1}
	if self.side == 1 then
		color = {1, 0, 0, 0.3}
		textColor = {0.7, 0, 0, 0.8}
	elseif self.side == 2 then
		color = {0, 0, 1, 0.3}
		textColor = {0, 0, 0.7, 0.8}
		self.wasBlue = true
	elseif self.side == 0 and self.wasBlue then
		color = {0, 0, 1, 0.3}
		textColor = {0, 0, 0.7, 1}
	end

	if not self.active then
		if self.wasBlue then
			color = {0, 0, 1, 0.3}
			textColor = {0, 0, 0.7, 0.8}
		else
			color = {0.1, 0.1, 0.1, 0.3}
			textColor = {0.1, 0.1, 0.1, 1}
		end
	end

	zone:draw(self.index, color, color)

	local point = zone.point
	if zone:isCircle() then
		point = { x = zone.point.x, y = zone.point.y, z = zone.point.z + zone.radius }
	elseif zone:isQuad() then
		local largestZ = zone.vertices[1].z
		local largestX = zone.vertices[1].x
		for i = 2, 4 do
			if zone.vertices[i].z > largestZ then
				largestZ = zone.vertices[i].z
				largestX = zone.vertices[i].x
			end
		end
		point = { x = largestX, y = zone.point.y, z = largestZ }
	end

	if self.airbaseName then
		timer.scheduleFunction(function()
			local ab = Airbase.getByName(self.airbaseName)
			if ab then
				if ab:autoCaptureIsOn() then ab:autoCapture(false) end
				if not self.active and not self.wasBlue then
					if RespawnStaticsForAirbase then
						RespawnStaticsForAirbase(self.airbaseName, 1)						
					end
					ab:setCoalition(0)
				end
				if self.side == 0 or self.side == 1 then
					if RespawnStaticsForAirbase then
						RespawnStaticsForAirbase(self.airbaseName, 1)		
					end
					ab:setCoalition(1)
				end
				if self.wasBlue then
					if RespawnStaticsForAirbase then
						RespawnStaticsForAirbase(self.airbaseName, 2)
					end
					ab:setCoalition(2)	
				end
			else
				env.info("Airbase " .. self.airbaseName .. " not found")
			end
		end, {}, timer.getTime() +3)
	end

	local upgrades = self:getFilteredUpgrades()

	for i, v in pairs(self.built) do
		local gr = Group.getByName(v)
		local st = StaticObject.getByName(v)
		if not gr and not st then self.built[i] = nil end
	end

	if UseStatics then
		for i, name in pairs(upgrades) do
			if not self.built[i] then
				local st = StaticObject.getByName(name)
				if st and st:isExist() then self.built[i] = name end
			end
		end
	end

	if self.remainingUnits then
		for i, v in pairs(self.remainingUnits) do
			if not self.built[i] then
				local upg = upgrades[i]
				if not upg then
				else
					local staticObj = StaticObject.getByName(upg)
					if staticObj then
						if UseStatics then
							self.built[i] = upg
						end
					else
						if not tostring(upg):find("dismounted") then
							local gr = zone:spawnGroup(upg, false)
							if gr then
								self.built[i] = gr.name
							else
								trigger.action.outText('Upgrade group '..tostring(upg)..' missing, skipped.',10)
								env.info('zoneCommander ERROR: spawnGroup returned nil for zone ['..self.zone..'] extra upgrade index '..tostring(i)..' name='..(upg or 'nil'))
							end							
						end
					end
				end
			end
		end
	else
		if Utils.getTableSize(self.built) < self.level then
			for i, v in pairs(upgrades) do
				if not self.built[i] and i <= self.level then
					local staticObj = StaticObject.getByName(v)
					if staticObj then
						if UseStatics then
							self.built[i] = v
						end
					else
						if not tostring(v):find("dismounted") then
							local gr = zone:spawnGroup(v, false)
							if not gr then
								trigger.action.outText("Failed to spawn group for upgrade: " .. (v or "nil"), 10)
								env.info("zoneCommander DEBUG: spawnGroup returned nil for zone ["..self.zone.."] upgrade index "..tostring(i).." name="..(v or "nil"))
							else
								self.built[i] = gr.name
							end
						end
					end
				end
			end
		end
	end
	

		local allUpgrades = {}
		if not self.upgrades then
			env.info(string.format('Zone "%s" is missing its upgrades table', self.zone or 'unknown'))
			trigger.action.outText(string.format('Zone "%s" is missing its upgrades table', self.zone or 'unknown'), 60)
		else
			if self.upgrades.red then
				for i, v in pairs(self.upgrades.red) do
					allUpgrades[v] = true
				end
			end
		end
		for v, _ in pairs(allUpgrades) do
			local staticObj = STATIC:FindByName(v, false)
			if staticObj then
				if not self.newStatics then self.newStatics = {} end
				local point = staticObj:GetPointVec3()
				local desc = staticObj:GetDesc()
				local shapeName = desc and desc.shapeName
				local typeName  = staticObj:GetTypeName()
				if typeName == ".Command Center" then
					shapeName = shapeName or "ComCenter"
				end
				if typeName == ".Ammunition depot" then
					shapeName = shapeName or "SkladC"
				end
				--env.info("[ZoneCommander DEBUG] For "..v.." type="..typeName.." shape="..(shapeName or "nil"))
				table.insert(self.newStatics, {
					name = v,
					point = point,
					type = typeName,
					heading = staticObj:GetHeading(),
					country = staticObj:GetCoalition(),
					shapeName = shapeName,
				})
				--env.info("[ZoneCommander DEBUG] Stored static "..v)
			end
		end
    if not self.zone:lower():find("hidden") then
        local waypointLabel = WaypointList and WaypointList[self.zone] or ""
        local msg = " " .. self.zone .. "" .. waypointLabel
        if missions and missions[self.zone] then
            local m = missions[self.zone]
            local tz = bc:getZoneByName(m.TargetZone)
            if tz and (self.side == 2 and tz.side == 1) then
                msg = msg .. "\n Mission!"
            end
        end
        if self.side == 2 then
            local upgrades = self:getFilteredUpgrades()
            local builtCount = 0
            for _ in pairs(self.built) do builtCount = builtCount + 1 end
            local total = #upgrades
            msg = msg .. "\n " .. builtCount .. "/" .. total
        end
        local backgroundColor = {0.7, 0.7, 0.7, 0.8}
        trigger.action.textToAll(-1, 2000 + self.index, point, textColor, backgroundColor, 18, true, msg)
        trigger.action.setMarkupText(2000 + self.index, msg)
    end


	if self.side == 2 and self.isHeloSpawn then
		trigger.action.setMarkupTypeLine(self.index, 2)
		trigger.action.setMarkupColor(self.index, {0,1,0,1})
	end
	if self.wasBlue and not self.active and self.isHeloSpawn then
		trigger.action.setMarkupTypeLine(self.index, 2)
		trigger.action.setMarkupColor(self.index, {0,1,0,1})
	end
	self:weedOutRemainingUnits()
	for i, v in ipairs(self.restrictedGroups) do
		trigger.action.setUserFlag(v.name, v.side ~= self.side)
	end
	for i, v in ipairs(self.groups) do
		v:init()
	end
end


	function ZoneCommander:weedOutRemainingUnits()
		local destroyPersistedUnits = function(context)
			if context.remainingUnits then
				for i2, v2 in pairs(context.built) do
					local bgr = Group.getByName(v2)
					if bgr then
						local ru = context.remainingUnits[i2]
						if ru and #ru > 0 then
							local need = {}
							for _, t in ipairs(ru) do
								need[t] = (need[t] or 0) + 1
							end
							for i3, v3 in ipairs(bgr:getUnits()) do
								local budesc = v3:getDesc()
								if need[budesc.typeName] and need[budesc.typeName] > 0 then
									need[budesc.typeName] = need[budesc.typeName] - 1
								else
									v3:destroy()
								end
							end
						end
					end
				end
			end
			if context.newStatics then
				for _, v4 in ipairs(context.newStatics) do
					local staticName = type(v4) == "table" and v4.name or v4
					local st = StaticObject.getByName(staticName)
					if st and st:isExist() then
						local foundInBuilt = false
						for _, builtName in pairs(context.built) do
							if builtName == staticName then
								foundInBuilt = true
								break
							end
						end
						if not foundInBuilt then
							st:destroy()
						end
					end
				end
			end
		end
		
		SCHEDULER:New(nil,destroyPersistedUnits,{self},2,0)
		SCHEDULER:New(nil, destroyPersistedUnits, {self},4,0)
	end


	function ZoneCommander:checkCriticalObjects()
		if not self.active then
			return
		end
		
		local stillactive = false
		if self.criticalObjects and #self.criticalObjects > 0 then
			for i,v in ipairs(self.criticalObjects) do
				local st = StaticObject.getByName(v)
				if st and st:getLife()>1 then
					stillactive = true
				end
				
				--clean up statics that still exist for some reason even though they're dead
				if st and st:getLife()<1 then
					st:destroy()
				end
			end
		else
			stillactive = true
		end
		
		if not stillactive then
			self:disableZone()
		end
	end
	
function ZoneCommander:update()
    self:checkCriticalObjects()
	--env.info("ZoneCommander: Updating zone " .. self.zone)
	--if self.suspended then return end

		for i,v in pairs(self.built) do
			local gr = Group.getByName(v)
			local st = StaticObject.getByName(v)
			local isH = (self._hibernated and (self._hibernated[v] or next(self._hibernated)~=nil)) or false
			if gr and gr:getSize() == 0 and not isH and not self.suspended then
				gr:destroy()
			end
			
			if not gr then
				if st and st:getLife()<1 and not isH and not self.suspended then
					st:destroy()
				end
			end

			if not gr and not st and not isH and not self.suspended then
				self.built[i] = nil
				self:updateLabel()
				if GlobalSettings.messages.grouplost then trigger.action.outText(self.zone..' lost group '..v, 5) end
			end		
			
			if gr and gr:getSize() == 0 and not isH and not self.suspended then
				self.built[i] = nil
				self:updateLabel()
				if GlobalSettings.messages.grouplost then trigger.action.outText(self.zone..' lost group '..v, 5) end
			end	
			
			if st and st:getLife()<1 and not isH and not self.suspended then
				self.built[i] = nil
				self:updateLabel()
				if GlobalSettings.messages.grouplost then trigger.action.outText(self.zone..' lost group '..v, 5) end
			end			
        end
    		local empty = true
		for i,v in pairs(self.built) do
			if v then
				empty = false
				break
			end
		end
		if self._hibernated and next(self._hibernated) then empty = false end
		if self.suspended then empty = false end

		local upgrades = self:getFilteredUpgrades()
		local total = #upgrades
		local built = 0
		for _ in pairs(self.built) do built = built + 1 end
		self.upgradeCompletion = (total > 0) and math.min(1, built / total) or 0

		if empty and self.side ~= 0 and self.active then


        if self.battleCommander.difficulty and self.side == self.battleCommander.difficulty.coalition then
            self.battleCommander:increaseDifficulty()           
		end
		self.side = 0
		self.wasBlue = false
        self:runTriggers('lost')
		bc:buildConnectionMap()
		buildCapControlMenu()
		bc.huntBases = nil
		bc:_buildHunterBaseList()
		


		local cz = CustomZone:getByName(self.zone)
		if cz then cz:clearUsedSpawnZones(self.zone) end
		self.battleCommander:buildZoneStatusMenuForGroup()
		if self.airbaseName then
			local ab = Airbase.getByName(self.airbaseName)
			if ab then
				local currentCoalition = ab:getCoalition()
				if currentCoalition ~= coalition.side.RED then
					if RespawnStaticsForAirbase then
					RespawnStaticsForAirbase(self.airbaseName, coalition.side.RED)
					end
					ab:setCoalition(coalition.side.RED)
				end
			end
		end	
		if self.active and GlobalSettings.messages.zonelost and not self.zone:lower():find("hidden") then
			trigger.action.outText(self.zone .. ' is now neutral ', 15)
			if trigger.misc.getUserFlag(180) == 0 then
				trigger.action.outSoundForCoalition(2, "ding.ogg")
			end
		end
        if self.active then   
            trigger.action.setMarkupColor(2000 + self.index, {0.3, 0.3, 0.3, 1})
            trigger.action.setMarkupColorFill(self.index, {0.7, 0.7, 0.7, 0.3})
            trigger.action.setMarkupColor(self.index, {0.7, 0.7, 0.7, 0.3})
            self:updateLabel()
			if missions then
				for _, m in pairs(missions) do
					if m.TargetZone == self.zone then
						local src = bc:getZoneByName(m.zone)
						if src then src:updateLabel() end
					end
				end
			end
        end
		
		if CaptureZoneIfNeutral then
			CaptureZoneIfNeutral()
		end
		if CheckJtacStatus then
			CheckJtacStatus()
		end
	
		if addCTLDZonesForBlueControlled then
			addCTLDZonesForBlueControlled(self.zone)
		end
		if SpawnFriendlyAssets then
			SCHEDULER:New(nil,SpawnFriendlyAssets,{},2,0)
		end
        bc:_hasActiveAttackOrPatrolOnZone()
        self.battleCommander:_rebalanceRedDifficulty()
    end

    for i, v in ipairs(self.groups) do
        v:update()
    end

    if self.crates then
        for i, v in ipairs(self.crates) do
            local crate = StaticObject.getByName(v)
            if crate and Utils.isCrateSettledInZone(crate, self.zone) then
                if self.side == 0 then
                    self:capture(crate:getCoalition())
                    if self.battleCommander.playerRewardsOn then
                        self.battleCommander:addFunds(self.side, self.battleCommander.rewards.crate)
                        trigger.action.outTextForCoalition(self.side, 'Capture +' .. self.battleCommander.rewards.crate .. ' credits', 5)
                    end
                elseif self.side == crate:getCoalition() then
                    if self.battleCommander.playerRewardsOn then
                        if self:canRecieveSupply() then
                            self.battleCommander:addFunds(self.side, self.battleCommander.rewards.crate)
                            trigger.action.outTextForCoalition(self.side, 'Resupply +' .. self.battleCommander.rewards.crate .. ' credits', 5)
                        else
                            local reward = self.battleCommander.rewards.crate * 0.25
                            self.battleCommander:addFunds(self.side, reward)
                            trigger.action.outTextForCoalition(self.side, 'Resupply +' .. reward .. ' credits (-75% due to no demand)', 5)
                        end
                    end
                    self:upgrade()
                end

                crate:destroy()
            end
        end
    end

    for i, v in ipairs(self.restrictedGroups) do
        trigger.action.setUserFlag(v.name, v.side ~= self.side)
    end

    if self.income and self.side ~= 0 and self.active then
        self.battleCommander:addFunds(self.side, self.income)
    end
end

	function ZoneCommander:updateLabel()
		if self.zone:lower():find("hidden") then return end
		local waypointLabel = WaypointList and WaypointList[self.zone] or ""
		local msg = " " .. self.zone .. "" .. waypointLabel
		if missions then
			for _, m in pairs(missions) do
				if m.zone == self.zone then
					local ownZone   = bc:getZoneByName(m.zone)
					local targetZone = bc:getZoneByName(m.TargetZone)
					if ownZone and targetZone and self.side == 2 and targetZone.side == 1 then
						msg = msg .. "\n Mission!"
					end
					break
				end
			end
		end
        if ActiveCurrentMission[self.zone] then
            local cur = ActiveCurrentMission[self.zone]
            if type(cur) == "table" then
                for k in pairs(cur) do
                    msg = msg .. "\n " .. k .. "!"
                end
            else
                msg = msg .. "\n " .. cur .. "!"
            end
        end
		local intelActive = (intelActiveZones and intelActiveZones[self.zone] == true)
		if (self.side == 2 and not self.suspended) or intelActive then
			local upgrades = self:getFilteredUpgrades()
			local builtCount = 0
			if self.built then for _ in pairs(self.built) do builtCount = builtCount + 1 end end
			local total = #upgrades
			if total > 0 then msg = msg .. "\n " .. builtCount .. "/" .. total end
		end
		trigger.action.setMarkupText(2000 + self.index, msg)
	end

	
	function ZoneCommander:addGroup(group)
		table.insert(self.groups, group)
		group.zoneCommander = self
	end
	
	function ZoneCommander:addGroups(groups)
		for i,v in ipairs(groups) do
			table.insert(self.groups, v)
			v.zoneCommander = self
			
		end
	end
	
	function ZoneCommander:validateTargetzones()
		for i,v in ipairs(self.groups or {}) do
			if v.targetzone then
				local tz = self.battleCommander and self.battleCommander:getZoneByName(v.targetzone)
				if not tz then
					trigger.action.outText(string.format("WARNING: unknown targetzone=%s in group=%s zone=%s", tostring(v.targetzone), tostring(v.name), tostring(self.zone)), 15)
					env.info(string.format("[WARN] unknown targetzone=%s in group=%s zone=%s", tostring(v.targetzone), tostring(v.name), tostring(self.zone)))
				end
			end
		end
	end

SCHEDULER:New(nil,function() for i,v in pairs(bc.zones or {}) do v:validateTargetzones() end end,{},1,0)

	function ZoneCommander:killAll()
		for i,v in pairs(self.built) do
			local gr = GROUP:FindByName(v)
			if gr then
				gr:Destroy()
			else
				local st = StaticObject.getByName(v)
				if st then
					st:destroy()
				end
			end
		end
	end
	

	
function ZoneCommander:capture(newside,silent)
    if self.active and self.side == 0 and newside ~= 0 then
        self.side = newside
		self.battleCommander:buildZoneStatusMenuForGroup()
        local sidename = ''
        local color = {0.7,0.7,0.7,0.3}
        local textcolor = {0.7,0.7,0.7,0.3}
        self.wasBlue = false
		
        trigger.action.setMarkupColor(2000 + self.index, textcolor)

        if self.side == 1 then
            sidename = 'RED'
            color = {1,0,0,0.3}
            textcolor = {0.7,0,0,0.8}
            self.wasBlue = false
			
            if self.NeutralAtStart and not self.firstCaptureByRed then
                self.firstCaptureByRed = true
																			 
            end

        elseif self.side == 2 then
            sidename = 'BLUE'
            color = {0,0,1,0.3}
            textcolor = {0,0,0.7,0.8}
            self.wasBlue = true
	end
		
		if SpawnFriendlyAssets then
			SCHEDULER:New(nil,SpawnFriendlyAssets,{},5,0)	
		end
		if addCTLDZonesForBlueControlled then
			addCTLDZonesForBlueControlled(self.zone)
		end
        trigger.action.setMarkupColor(2000 + self.index, textcolor)
        trigger.action.setMarkupColorFill(self.index, color)
        trigger.action.setMarkupColor(self.index, color)
        self:runTriggers('captured')
        bc:buildConnectionMap()
		bc.huntBases = nil
        bc:_buildHunterBaseList()
		bc:updateBlueZoneCount()
        bc:_hasActiveAttackOrPatrolOnZone()
        self.battleCommander:_rebalanceRedDifficulty()
        SCHEDULER:New(bc, bc.abortSupplyToOpposite, {self.zone, self.side}, 10, 0)
        if _awacsRepositionSched then _awacsRepositionSched:Stop() end
        _awacsRepositionSched = SCHEDULER:New(nil, RepositionAwacsToFront, {}, 15)
        --bc:_autoZoneSuspend()
		


		if checkAndDisableFriendlyZones then
			checkAndDisableFriendlyZones()
		end
		if not silent then
			if GlobalSettings.messages.captured and self.active then 
            	trigger.action.outText(self.zone .. ' captured by ' .. sidename, 20)
        	elseif GlobalSettings.messages.captured and not self.active and self.wasBlue then 
           	 	trigger.action.outText(self.zone .. ' captured by BLUE\n\nZone is now disabled due to progress, great job!', 20)
			end
		end
		
		if self.active then
			if not silent then
				self:upgrade()
			else
				self:upgrade(true)
			end
		end
		
        if self.wasBlue and self.isHeloSpawn then
            trigger.action.setMarkupTypeLine(self.index, 2)
            trigger.action.setMarkupColor(self.index, {0, 1, 0, 1})
        end  
			if self.airbaseName then
				local ab = Airbase.getByName(self.airbaseName)
				if ab then
					if self.wasBlue then
						self.side = 2
					end
					ab:setCoalition(self.side)
					if RespawnStaticsForAirbase then
					RespawnStaticsForAirbase(self.airbaseName, self.side)
					end
					local baseCaptureEvent = {
						id = world.event.S_EVENT_BASE_CAPTURED,
						initiator = ab,
						place = ab,
						coalition = self.side,
					}
					world.onEvent(baseCaptureEvent)
				end
				bc.huntBases = nil
				
			end
		local isUrgent = type(self.urgent) == "function" and self.urgent() or self.urgent
		
        for _, v in ipairs(self.groups) do
		if v.state == 'inhangar' or v.state == 'dead' then
			 if isUrgent then
					self.lastStateTime = timer.getAbsTime() + 30
				else
					self.lastStateTime = timer.getAbsTime() + math.random(60, GlobalSettings.initialDelayVariance * 60) 
				end
			end
		end

        if self.battleCommander.difficulty and newside == self.battleCommander.difficulty.coalition then
            self.battleCommander:decreaseDifficulty()
        end
    end
	if not silent then		
		if not self.active and not self.wasBlue then
			if GlobalSettings.messages.disabled then
				trigger.action.outText(self.zone .. ' has been destroyed and can no longer be captured', 5)
				SCHEDULER:New(nil,function()
					trigger.action.setMarkupColor(2000 + self.index, {0.1, 0.1, 0.1, 1})
				end,{},0.5,0)
			end
		end
	end
	self:updateLabel()
	if missions then
		for _, m in pairs(missions) do
			if m.TargetZone == self.zone then
				local src = bc:getZoneByName(m.zone)
				if src then src:updateLabel() end
			end
		end
	end
end

	
	function ZoneCommander:canRecieveSupply()
		if not self.active then
			return false
		end

		if self.suspended then
			return false
		end

		if self.side == 0 then 
			return true
		end
		local upgrades = self:getFilteredUpgrades()

		for i, v in pairs(self.built) do
			if not string.find(v, "dismounted") then
				local gr = Group.getByName(v)
				if gr and gr:getSize() < gr:getInitialSize() then
					return true
				end
			end
		end

		if Utils.getTableSize(self.built) < #upgrades then
			return true
		end

		return false
	end

	function ZoneCommander:clearWreckage()
		 local zn = trigger.misc.getZone(self.zone)
		 local pos =  {
		x = zn.point.x, 
		y = land.getHeight({x = zn.point.x, y = zn.point.z}), 
		z= zn.point.z
		}
		local radius = zn.radius
		world.removeJunk({id = world.VolumeType.SPHERE,params = {point = pos ,radius = radius}})
	end
	
function ZoneCommander:upgrade(silent)
	if self.active and self.side ~= 0 then
		local zone = CustomZone:getByName(self.zone)
		local upgrades       = self:getFilteredUpgrades()
		local totalUpgrades  = #upgrades
		local function calculateUpgradeCount()
			local fullyRepairedGroups = {}
			for i,v in pairs(self.built) do
				success = false
				local gr = Group.getByName(v)
				if gr then
					local allUnitsRepaired = true
					for _,u in ipairs(gr:getUnits()) do
						if u and u:isExist() then
							if u:getLife() < u:getLife0() then
								allUnitsRepaired = false
								break
							end
						end
					end
					if allUnitsRepaired and gr:getSize() == gr:getInitialSize() then
						table.insert(fullyRepairedGroups,gr)
					end
				end
			end
			return #fullyRepairedGroups
		end
		local upgradeCount = calculateUpgradeCount()
		local repaired     = false
		local success    = false
		for i,v in pairs(self.built) do
			if not string.find(v,"dismounted") then
				local gr = GROUP:FindByName(v)
				if gr then	
					if gr:GetSize() and gr:GetInitialSize() then
						if gr:GetSize() < gr:GetInitialSize() then
							CustomRespawn(v)
							success = true
						end
					else
						zone:spawnGroup(v,false)
						success = true
					end
				end
			if success then
				if not silent then
					if GlobalSettings.messages.repaired then
						if self.side == 1 then
							trigger.action.outText(self.zone..' has been repaired',10)
						else
							trigger.action.outText('Group '..v..' at '..self.zone..' was repaired',10)
						end
					end
				end
				self:runTriggers('repaired')
				self:clearWreckage()
				repaired = true
                self:updateLabel()
				break
			end
		 end
		end
		if not repaired and upgradeCount == totalUpgrades then
			if self.side == 2 and not silent then
				trigger.action.outText(self.zone..' is already fully upgraded!',10)
			end
			return false
		end
		if not repaired and Utils.getTableSize(self.built) < #upgrades then
			local zone = CustomZone:getByName(self.zone)
			for i,v in pairs(upgrades) do
				if not self.built[i] then
					local isStatic = false
					local stData   = nil
					for _,data in ipairs(self.newStatics or {}) do
						if data.name == v then
							isStatic = true
							stData   = data
							break
						end
					end
					if isStatic and stData then
						if stData.country == 1 then
							stData.country = country.id.RUSSIA
						else
							stData.country = country.id.USA
						end
						local spawnTemplate = {
							name       = stData.name,
							type       = stData.type,
							country    = stData.country,
							shape_name = stData.shapeName,
							heading    = math.rad(stData.heading),
							position   = stData.point
						}
						local spawnStatic = SPAWNSTATIC:NewFromTemplate(spawnTemplate,stData.country)
						local spawnedObject = spawnStatic:SpawnFromCoordinate(COORDINATE:NewFromVec3(stData.point))
						self.built[i] = spawnedObject:GetName()
					else
						local gr   = zone:spawnGroup(v,false)
						if gr then
							self.built[i] = gr.name
						else
							env.info("spawnGroup FAILED for "..tostring(v))
							trigger.action.outText('SpawnGroup Failed '..tostring(v)..' Report it to Leka', 30)
						end
					end
					SCHEDULER:New(nil,function()
						upgradeCount = calculateUpgradeCount()
						if self.side == 2 then
							if GlobalSettings.messages.upgraded and not silent then
								trigger.action.outText(self.zone..' upgraded '..upgradeCount..'/'..totalUpgrades,10)
							end
						else
							if not silent then
								if GlobalSettings.messages.upgraded then
									trigger.action.outText(self.zone..' defenses upgraded',10)
								end
							end
						end
					end,{},1,0)
					self:runTriggers('upgraded')
					self:clearWreckage()
                    self:updateLabel()
					break
				end
			end
		end
		return true
	end
	if not self.active then
		if GlobalSettings.messages.disabled and not silent then
			trigger.action.outText(self.zone..' has been destroyed and can no longer be upgraded',10)
		end
	end
	return false
end
end
GroupCommander = {}
do
	--{ name='groupname', mission=['patrol', 'supply', 'attack'], targetzone='zonename', type=['air','carrier_air','surface'] }
function GroupCommander:new(obj)
    obj = obj or {}
    
	obj.diceChance = obj.diceChance or 0
	
    if not obj.type then
        obj.type = 'air'
    end
	obj.Era = obj.Era

    obj.state = 'inhangar' 
    obj.lastStateTime = timer.getAbsTime()
    obj.zoneCommander = {}
    obj.landsatcarrier = obj.type == 'carrier_air'
    obj.side = 0
    

    
    obj.condition = obj.condition or function() return true end
    obj.Redcondition = obj.Redcondition or function() return true end
    obj.Bluecondition = obj.Bluecondition or function() return true end

    
    obj.urgent = obj.urgent or false

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function GroupCommander:init()
	self.state = 'inhangar'

	local isUrgent = type(self.urgent) == "function" and self.urgent() or self.urgent
	if isUrgent then
		self.lastStateTime = timer.getAbsTime() + 20
	else
		self.lastStateTime = timer.getAbsTime() + math.random(1, GlobalSettings.initialDelayVariance * 60)
	end

	local templateName = self.template or self.name
	self:_ensureTemplateCache()
	local list = self._tplAll
	local resolved = (#list>0) and nil or templateName

	if list and #list>0 then
		self._tplBySide = { [1]={}, [2]={} }
		local filtered = {}
		for i=1,#list do
			local tn = list[i]
			local gr = Group.getByName(tn)
			local hasTpl = (_DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and _DATABASE.Templates.Groups[tn]) or gr
			if gr and hasTpl then
				local s = gr:getCoalition()
				if s==1 then self._tplBySide[1][#self._tplBySide[1]+1]=tn elseif s==2 then self._tplBySide[2][#self._tplBySide[2]+1]=tn end
				filtered[#filtered+1] = tn
				if self.side == 0 then self.side = s end
				if not self.unitCategory then local u = gr:getUnit(1); if u then self.unitCategory = u:getDesc().category end end
				if self.type == 'air' then local us=gr:getUnits(); local cnt=us and #us or 0; if not self.AirCount or cnt>self.AirCount then self.AirCount=cnt end end
				if self.type ~= 'air' then local uu=gr:getUnit(1); local cat=uu and uu:getDesc().category or nil; if not (cat==Unit.Category.AIRPLANE or cat==Unit.Category.HELICOPTER) then gr:destroy() end end


			else
				trigger.action.outText('ERROR: group ['..tostring(tn)..'] template missing', 30)
				env.info('ERROR: group ['..tostring(tn)..'] template missing')
			end
		end
		self._tplAll = filtered
		if self.side == 0 and #filtered>0 then
			local gfirst = Group.getByName(filtered[1])
			if gfirst then self.side = gfirst:getCoalition() if self.type ~= 'air' then 
			local uu=gfirst:getUnit(1); local cat=uu and uu:getDesc().category or nil; if not (cat==Unit.Category.AIRPLANE or cat==Unit.Category.HELICOPTER) then gfirst:destroy() end end end

		end
        if self.side == 0 then
            trigger.action.outText('ERROR: could not resolve coalition for dynamic set ['..templateName..']', 20)
            env.info('ERROR: could not resolve coalition for dynamic set ['..templateName..']')
        end
        self._tplCache = true
   else
        if not self.template then
            local gr = Group.getByName(self.name)
            if gr then
                self.side = gr:getCoalition()
                local u = gr:getUnit(1)
                if u then
                    local cat = u:getDesc().category
                    self.unitCategory = cat
                    if self.type == 'air' then local us=gr:getUnits(); self.AirCount=(us and #us) or 0 end
                else
                    env.info('ERROR: group ['..self.name..'] has no units')
                end
                if self.type ~= 'air' then local uu=gr:getUnit(1); local cat=uu and uu:getDesc().category or nil; if not (cat==Unit.Category.AIRPLANE or cat==Unit.Category.HELICOPTER) then gr:destroy() end end
            else
                trigger.action.outText('ERROR: group ['..self.name..'] can not be found in the mission', 60)
                env.info('ERROR: group ['..self.name..'] can not be found in the mission')
            end
        else
            trigger.action.outText('ERROR: template ['..templateName..'] has no valid group entries', 60)
            env.info('ERROR: template ['..templateName..'] has no valid group entries')
        end
    end
end


function GroupCommander:_findFlatLZ(originZoneName, attempts, maxSlope)
    local zn = originZoneName and ZONE:FindByName(originZoneName)
    if not zn then return nil end
    attempts = attempts or 100
    maxSlope = maxSlope or 0.06
    for i=1,attempts do
        local c = zn:GetRandomCoordinate()
        if c then
            local v = c:GetVec3()
            local function H(x,z) return land.getHeight({x=x,y=z}) end
            local dx,dy = 8,8
            local hx1,hx2 = H(v.x+dx,v.z), H(v.x-dx,v.z)
            local hy1,hy2 = H(v.x,v.z+dy), H(v.x,v.z-dy)
            local sx = (hx1 - hx2)/(2*dx)
            local sy = (hy1 - hy2)/(2*dy)
            local slope = math.sqrt(sx*sx + sy*sy)
            if slope <= maxSlope then
                return { x = v.x, z = v.z }
            end
        end
    end
    return nil
end

function GroupCommander:_resolveParkingWithBelonging()
    if self.unitCategory ~= Unit.Category.AIRPLANE then return nil end
    local zc = self.zoneCommander
    local abName = zc and zc.airbaseName
    if not abName or abName=="" then return nil end
    local chain = { abName }
    local bel = AirbaseBelonging[abName]
    if bel then for i=1,#bel do chain[#chain+1]=bel[i] end end
    local need = math.max(self.AirCount or 2, 1)
    local termType = self.terminalType or AIRBASE.TerminalType.OpenMedOrBig
    for ni=1,#chain do
        local ab = AIRBASE:FindByName(chain[ni])
        if ab and ab:IsAirdrome() then
            local free = ab:GetFreeParkingSpotsTable(termType, false)
            table.sort(free, function(a,b) return a.TerminalID < b.TerminalID end)
            if #free >= need then
                local run=1
                for i=2,#free do
                    if free[i].TerminalID == free[i-1].TerminalID + 1 then run=run+1 else run=1 end
                    if run>=need then
                        local ids={}
                        for j=i-run+1,i do ids[#ids+1]=free[j].TerminalID end
                        return { kind='parking', airbase=ab, spots=ids }
                    end
                end
                local ids={}
                for i=1,need do ids[i]=free[i].TerminalID end
                return { kind='parking', airbase=ab, spots=ids }
            end
        end
    end
    return nil
end

function GroupCommander:_assignPlaneRoute(grName, zoneName)
    local gr = Group.getByName(grName); if not gr then return end
    local gmoose = GROUP:FindByName(grName); if not gmoose or not gmoose:IsAlive() then return end
    local tz = self.zoneCommander.battleCommander:getZoneByName(zoneName); if not tz then return end
    local abn = tz.airbaseName; if not abn then return end
    local ab = AIRBASE:FindByName(abn); if not ab then return end

	env.info("Assigning plane route to group "..grName.." for zone "..zoneName.." via airbase "..abn)

    local rwy = ab.GetActiveRunwayLanding and ab:GetActiveRunwayLanding()
    local hdg
    if rwy and rwy.heading then
        hdg = rwy.heading - 180
    else
        hdg = -(ab:GetCoordinate():GetWind() or 0)
    end
	env.info("  Runway heading: "..tostring(rwy and rwy.heading).."  Approach heading: "..tostring(hdg))

    local d1 = UTILS.NMToMeters(30.0)
    local d2 = UTILS.NMToMeters(5.0)
    local alpha = math.rad(3)
    local h1 = d1 * math.tan(alpha)
    local h2 = d2 * math.tan(alpha)

    local papp = ab:GetCoordinate():Translate(d1, hdg):SetAltitude(h1)
    local pland = ab:GetCoordinate():Translate(d2, hdg):SetAltitude(h2)

	env.info('landing waypoints are now done')

    local wp = {}
    wp[#wp+1] = papp:WaypointAirTurningPoint("BARO", UTILS.KnotsToKmph(250), nil, "Initial Approach")
    wp[#wp+1] = pland:WaypointAirLanding(UTILS.KnotsToKmph(160), ab, {}, "Landing")
    gmoose:Route(wp, 1)
end

function GroupCommander:_assignHeloRoute(grName, zoneName, helipadId)
    local gr = Group.getByName(grName); if not gr then env.info("No group found for name " .. grName) return end
    local c = gr:getController(); if not c then env.info("No controller found for group " .. grName) return end
    local un = gr:getUnit(1); if not un then env.info("No unit found for group " .. grName) return end
    local pos = un:getPoint()
    local destx, desty

    local prefix = zoneName.."-land"
    local pooled = {}
	for name,list in pairs(LandingSpots) do
		if name:sub(1, #prefix) == prefix then
			for i=1,#list do pooled[#pooled+1] = list[i] end
		end
	end
    if #pooled > 0 then
       -- env.info("Using predefined landing spots for prefix " .. prefix)
        local pick = pooled[math.random(#pooled)]
        destx, desty = pick.x, pick.z
	else
		--env.info("No predefined landing spots for prefix " .. prefix)
	end

    if not destx then
        local tz = self.zoneCommander.battleCommander:getZoneByName(zoneName)
        local abn = tz and tz.airbaseName
        if abn then
            local ab = AIRBASE:FindByName(abn)
            if ab then
                local free = ab.GetFreeParkingSpotsTable and ab:GetFreeParkingSpotsTable(AIRBASE.TerminalType.HelicopterUsable, false) or {}
                if #free > 0 then
                    table.sort(free, function(a,b) return a.TerminalID < b.TerminalID end)
                    local c = ab.GetCoordinateParking and ab:GetCoordinateParking(free[1].TerminalID)
                    if c and c.GetVec2 then
                        local pv2 = c:GetVec2()
                        destx, desty = pv2.x, pv2.y
                    end
                end
                if not destx and ab.GetCoordinate then
                    local c = ab:GetCoordinate()
                    if c and c.GetVec2 then
                        local pv2 = c:GetVec2()
                        destx, desty = pv2.x, pv2.y
                    end
                end
                if ab.IsHelipad and ab:IsHelipad() and ab.GetID and ab.GetCoalition and ab:GetCoalition()==gr:getCoalition() then
                    if not helipadId then helipadId = ab:GetID() end
                    if not destx and ab.GetCoordinate then
                        local c = ab:GetCoordinate()
                        if c and c.GetVec2 then local v=c:GetVec2(); destx,desty=v.x,v.y end
                    end
                end
            end
        end
    end
    if not destx then
        local lz = self:_findFlatLZ(zoneName.."-", 200, math.tan(math.rad(15)))
        if not lz then lz = self:_findFlatLZ(zoneName, 200, math.tan(math.rad(15))) end
        if lz then destx, desty = lz.x, lz.z end
    end
    if not destx then return end

    local spd = 180
    if helipadId then
        local dx, dz = destx - pos.x, desty - pos.z
        local L = math.sqrt(dx*dx + dz*dz)
        local back = 2 * 1852
        local apx = (L > 10) and (destx - dx / L * back) or destx
        local apy = (L > 10) and (desty - dz / L * back) or desty

        local gmoose = GROUP:FindByName(grName); if not gmoose or not gmoose:IsAlive() then return end
        local tz = self.zoneCommander.battleCommander:getZoneByName(zoneName)
        local abn = tz and tz.airbaseName
        local airb = abn and AIRBASE:FindByName(abn) or nil
        local kmh = math.floor((spd or 280) * 3.6)

        local route = {}
        route[#route+1] = COORDINATE:New(apx, 500, apy):WaypointAirFlyOverPoint("RADIO", kmh)
        route[#route+1] = COORDINATE:New(destx, 0, desty):WaypointAirLanding(kmh, airb)

        gmoose:Route(route, 1)
    else
        local task = { id='Mission', params={ route={ airborne=true, points={} } } }
        local dx, dz = destx - pos.x, desty - pos.z
        local L = math.sqrt(dx*dx + dz*dz)
        local back = 2 * 1852
        local apx = (L > 10) and (destx - dx / L * back) or destx
        local apy = (L > 10) and (desty - dz / L * back) or desty

        table.insert(task.params.route.points, {
            type=AI.Task.WaypointType.TURNING_POINT, x=apx, y=apy, speed=spd, speed_locked=true,
            action=AI.Task.TurnMethod.FLY_OVER_POINT, alt=500, alt_type=AI.Task.AltitudeType.RADIO
        })
        table.insert(task.params.route.points, {
            type=AI.Task.WaypointType.TURNING_POINT, x=apx, y=apy, speed=spd, speed_locked=true,
            action=AI.Task.TurnMethod.FIN_POINT, alt=500, alt_type=AI.Task.AltitudeType.RADIO,
            task={ id='ComboTask', params={ tasks={{ number=1, auto=false, id='Land', params={ point={ x=destx, y=desty }, duration=5, durationEnabled=true } }} } }
        })
        c:setTask(task)
    end
end


function BattleCommander:abortSupplyToOpposite(zoneName, newSide)
	for _, oz in ipairs(self.zones) do
		for _, gc in ipairs(oz.groups or {}) do
			if gc and gc.mission=='supply' and gc.unitCategory==Unit.Category.HELICOPTER and gc.targetzone==zoneName and gc.side ~= newSide then
				if gc.state == 'inair' then
					gc:_assignHeloRoute(gc.name, gc.zoneCommander.zone)
				elseif gc.state == 'takeoff' then
					local g = Group.getByName(gc.name)
					if g then g:destroy() end
					gc.state = 'preparing'
					gc.lastStateTime = timer.getAbsTime()
				end
			end
		end
	end
end

function GroupCommander:_ensureTemplateCache()
	if self._tplCache then return end
	local templateKey = self.template or self.name
	local set = ((_G[templateKey] and type(_G[templateKey])=="table" and #_G[templateKey]>0 and type(_G[templateKey][1])=="string") and _G[templateKey] or nil)
	self._tplAll = set or {}
	self._tplBySide = { [1]={}, [2]={} }
	if set and #set>0 then
		for i=1,#set do
			local tn = set[i]
			local tpl = _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and _DATABASE.Templates.Groups[tn] or nil
			local cnum=nil
			if tpl then
				local cv=tpl.Coalition or tpl.coalition
				if type(cv)=="number" then cnum=cv elseif cv=="blue" or cv=="BLUE" then cnum=2 elseif cv=="red" or cv=="RED" then cnum=1 end
			end
			if not cnum then
				local grm=Group.getByName(tn)
				if grm then cnum=grm:getCoalition() end
			end
			if cnum==1 then self._tplBySide[1][#self._tplBySide[1]+1]=tn elseif cnum==2 then self._tplBySide[2][#self._tplBySide[2]+1]=tn end
		end
	end
	self._tplCache = true
end


function GroupCommander:_getTemplateSet(templateKey)
	local g = _G[templateKey]
	if type(g) == "table" and #g>0 and type(g[1])=="string" then return g end
	if dc and dc.SETS then
		local s = dc.SETS[templateKey]
		if type(s) == "table" and #s>0 and type(s[1])=="string" then return s end
	end
	return nil
end

function GroupCommander:_resolveTemplateName()
	self:_ensureTemplateCache()
	if not self.template then return self.name end
	local side = self.side
	if side~=0 then
		local list = self._tplBySide[side]
		if list and #list>0 then return list[math.random(1,#list)] else return nil end
	end
	return nil
end

function GroupCommander:_resolveSpawn()
    local zc = self.zoneCommander
    local abName = zc and zc.airbaseName
    local need = self.AirCount
    local termType = self.terminalType or AIRBASE.TerminalType.OpenMedOrBig
    local helipadId

    if abName then
        local ab = AIRBASE:FindByName(abName)
        if ab then
            if self.unitCategory == Unit.Category.AIRPLANE and not (ab:IsAirdrome() or ab:IsShip()) then
                ab = nil
            end
            if self.unitCategory == Unit.Category.HELICOPTER and not (ab:IsAirdrome() or ab:IsHelipad() or ab:IsShip()) then
                ab = nil
            end
            if ab then
                if self.unitCategory == Unit.Category.HELICOPTER and (ab:IsHelipad() or ab:IsShip()) and ab.GetID then
                    helipadId = ab:GetID()
                end
                local ttype = (self.unitCategory == Unit.Category.HELICOPTER) and AIRBASE.TerminalType.HelicopterUsable or termType
                local free = ab:GetFreeParkingSpotsTable(ttype, false)
                if #free < need then
                    local free2 = ab:GetFreeParkingSpotsTable(ttype, true)
                    if #free2 > #free then free = free2 end
                end
                table.sort(free, function(a,b) return a.TerminalID < b.TerminalID end)
                if #free >= need then
                    local run=1
                    for i=2,#free do
                        if free[i].TerminalID == free[i-1].TerminalID + 1 then run=run+1 else run=1 end
                        if run>=need then
                            local ids={}
                            for j=i-run+1,i do ids[#ids+1]=free[j].TerminalID end
                            return { kind='parking', airbase=ab, spots=ids, helipadId=helipadId, airbaseId=(ab and ab.GetID) and ab:GetID() or nil }
                        end
                    end
                    local ids={}
                    for i=1,need do ids[i]=free[i].TerminalID end
                    return { kind='parking', airbase=ab, spots=ids, helipadId=helipadId, airbaseId=(ab and ab.GetID) and ab:GetID() or nil }
                end
            end
        end
    end
    return nil
end


playerListBlue = playerListBlue or {}
playerListRed  = playerListRed  or {}
function getBluePlayersCount()
    local cnt = 0
    for _ in pairs(playerListBlue) do
        cnt = cnt + 1
    end
    return cnt
end
function getRedPlayersCount()
    local cnt = 0
    for _ in pairs(playerListRed) do
        cnt = cnt + 1
    end
    return cnt
end


function refreshPlayers()
    local b = coalition.getPlayers(coalition.side.BLUE)
    local currentBlue = {}
    for _, unit in ipairs(b) do
        local nm = unit:getPlayerName()
        if nm then
            local desc = unit:getDesc()
            if desc and desc.category == Unit.Category.AIRPLANE then
				if unit:getTypeName() ~= "A-10C_2" and unit:getTypeName() ~= "Hercules" and unit:getTypeName() ~= "A-10A" and unit:getTypeName() ~= "AV8BNA" then
					currentBlue[nm] = true
				end
            end
        end
    end
    for storedName in pairs(playerListBlue) do
        if not currentBlue[storedName] then
            playerListBlue[storedName] = nil
        end
    end
    for newName in pairs(currentBlue) do
        playerListBlue[newName] = true
    end

    local r = coalition.getPlayers(coalition.side.RED)
    local currentRed = {}
    for _, unit in ipairs(r) do
        local nm = unit:getPlayerName()
        if nm then
            local desc = unit:getDesc()
            if desc and desc.category == Unit.Category.AIRPLANE then
				if unit:getTypeName() ~= "A-10C_2" and unit:getTypeName() ~= "Hercules" and unit:getTypeName() ~= "A-10A" and unit:getTypeName() ~= "AV8BNA" then
					currentRed[nm] = true
				end
            end
        end
    end
    for storedName in pairs(playerListRed) do
        if not currentRed[storedName] then
            playerListRed[storedName] = nil
        end
    end
    for newName in pairs(currentRed) do
        playerListRed[newName] = true
    end
end

SCHEDULER:New(nil,refreshPlayers,{},10,60)

function getRedStrikeLimit(numPlayers)
	numPlayers = numPlayers or getBluePlayersCount()
	if numPlayers == 0 then
		return 1
	elseif numPlayers == 1 then
		return 1
	elseif numPlayers == 2 then
		return 2
	elseif numPlayers == 3 then
		return 2
	elseif numPlayers == 4 then
		return 3
	else
		return 99999
	end
end


function getCapLimit(numPlayers)
	numPlayers = numPlayers or getBluePlayersCount()
    if numPlayers == 0 then
        return 1
    elseif numPlayers == 1 then
        return 2
	elseif numPlayers == 2 then
        return 3
    elseif numPlayers == 3 then
        return 4
	elseif numPlayers == 4 then
        return 5
	elseif numPlayers == 5 then
        return 6
	elseif numPlayers == 6 then
        return 7
    else
        return 99999
    end
end

function getBlueCasLimit(numPlayers)
  numPlayers = numPlayers or getBluePlayersCount()
  if numPlayers <= 0 then
    return 2
  elseif numPlayers == 1 then
    return 1
  else
    return 0
  end
end


function getBlueCapLimit(numPlayers)
  numPlayers = numPlayers or getBluePlayersCount()
  if numPlayers <= 0 then
    return 3
  elseif numPlayers == 1 then
    return 2
  elseif numPlayers == 2 then
    return 1
  elseif numPlayers == 3 then
    return 1
  else
    return 0
  end
end

function BattleCommander:getActiveSupplyCount(side, targetZone)
    local count = 0
    for _, zoneCom in ipairs(self.zones) do
        for _, groupCom in ipairs(zoneCom.groups) do
            if groupCom.side == side and groupCom.mission == 'supply' and groupCom.targetzone == targetZone then
                if groupCom.Spawned and groupCom.state ~= 'dead' then
                    count = count + 1
                end
            end
        end
    end
    return count
end

function BattleCommander:getActiveCasSeadCount(side, missionType)
    local count = 0
    for _, zoneCom in ipairs(self.zones) do
        for _, groupCom in ipairs(zoneCom.groups) do
            if groupCom.side == side and (groupCom.MissionType == 'CAS' or groupCom.MissionType == 'SEAD') then
                if not missionType or groupCom.mission == missionType then
                    if groupCom.Spawned and groupCom.state ~= 'dead' then
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
end


function BattleCommander:getActiveStrikeCount(side, missionType, missionRole, unitCategory)
	local count = 0
	for _, zoneCom in ipairs(self.zones) do
		for _, groupCom in ipairs(zoneCom.groups) do
			if groupCom.side == side and groupCom.mission == missionType and groupCom.MissionType == missionRole then
				if (not unitCategory) or groupCom.unitCategory == unitCategory then
					if groupCom.state == 'takeoff' or groupCom.state == 'inair' then
						count = count + 1
					end
				end
			end
		end
	end
	return count
end

function BattleCommander:getActiveCAPCount(side, missionType)
    local count = 0
    for _, zoneCom in ipairs(self.zones) do
        for _, groupCom in ipairs(zoneCom.groups) do
            if groupCom.side == side and groupCom.MissionType == 'CAP' then
                if missionType then
                    if groupCom.mission == missionType then
                        if groupCom.state == 'takeoff' or groupCom.state == 'inair' then
                            count = count + 1
                        end
                    end
                else
                    if groupCom.state == 'takeoff' or groupCom.state == 'inair' then
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
end

DebugIsOn = false
RunwayHandler = nil
RUNWAY_ZONE_COOLDOWN = {}
runwayCooldown = 0
runwayCompleted = false
function generateRunwayStrikeMission()
  if runwayMission or runwayTarget then return end
  if timer.getTime() < runwayCooldown then return end
local cand, capCand = {}, {}
	for _, z in ipairs(bc.zones) do
		if z.side == 1 and z.active and not z.suspended and z.airbaseName and ZONE_CONNECTED_TO_BLUE[z.zone]
			and (RUNWAY_ZONE_COOLDOWN[z.zone] or 0) < timer.getTime()
		then
			local hostile, capCnt = false, 0
			for _, g in ipairs(z.groups or {}) do
				if g.side == 1 and g.unitCategory == 0 then
					if g.mission == 'attack' or g.mission == 'patrol' then hostile = true end
					if g.MissionType == 'CAP' then capCnt = capCnt + 1 end
				end
			end
			if hostile then
				local ab = AIRBASE:FindByName(z.airbaseName)
				if ab and ab:IsAirdrome() then
					local entry = { zone = z, airbase = ab }
					if capCnt > 2 then capCand[#capCand + 1] = entry else cand[#cand + 1] = entry end
				end
			end
		end
	end
	cand = (#capCand > 0) and capCand or cand
	do
		local blueAnchors = {}
		for _, bz in ipairs(bc.zones) do
			if bz.side == 2 and bz.active then blueAnchors[#blueAnchors + 1] = bz.zone end
		end
		for _, e in ipairs(cand) do
			local best = math.huge
			local znB = e.zone.zone
			for _, znA in ipairs(blueAnchors) do
				local d = ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB] or math.huge
				if d < best then best = d end
			end
			e.dist = best
		end
		table.sort(cand, function(a, b) return a.dist < b.dist end)
		local rankBonus = {5, 3, 0}
		for idx, e in ipairs(cand) do
			local grpScore = 0
			for _, g in ipairs(e.zone.groups or {}) do
				if g.side == 1 and g.unitCategory == 0 then
					grpScore = grpScore + 2
					if g.MissionType == 'CAP' then grpScore = grpScore + 1 end
				end
			end
			e.score = grpScore + (rankBonus[math.min(idx, 3)] or 0)
		end
		table.sort(cand, function(a, b)
			if a.score == b.score then return a.dist < b.dist else return a.score > b.score end
		end)
	end
  if #cand==0 then
    local blueAnchors={}
    for _,bz in ipairs(bc.zones) do
      if bz.side==2 and bz.active then blueAnchors[#blueAnchors+1]=bz.zone end
    end
    for _,z in ipairs(bc.zones) do
      if z.side==1 and z.active and z.airbaseName and
	  (RUNWAY_ZONE_COOLDOWN[z.zone] or 0) < timer.getTime() then
        local hostile=false
        if z.groups then
          for _,g in ipairs(z.groups) do
            if g.side==1 and g.unitCategory == 0 and (g.mission=='attack' or g.mission=='patrol') then
			hostile=true 
			break 
			end
          end
        end
        if hostile then
          local bestdist=math.huge
          local znB=z.zone
          for _,znA in ipairs(blueAnchors) do
            local d=ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB] or math.huge
            if d<bestdist then bestdist=d end
          end
          if bestdist<=60*1852 then
            local ab=AIRBASE:FindByName(z.airbaseName)
            if ab and ab:IsAirdrome() then
              local score=0
              for _,g in ipairs(z.groups or {}) do
                if g.side==1 and g.unitCategory==0 then
                  score=score+2
                  if g.MissionType=="CAP" then score=score+1 end
                end
              end
              cand[#cand+1]={zone=z,airbase=ab,dist=bestdist,score=score}
            end
          end
        end
      end
    end
	table.sort(cand,function(a,b) return a.dist<b.dist end)
	local rankBonus={5,3,0}
	for i,e in ipairs(cand) do
	e.score=(e.score or 0)+(rankBonus[i] or 0)
	end
	table.sort(cand,function(a,b) return a.score>b.score end)
	end
    for i=1,math.min(3,#cand) do
      local e=cand[i]
      env.info(string.format("RUNWAY-DBG: option %d  %s  dist=%.0f  score=%d",i,e.zone.zone,e.dist,e.score))
    end
  
  if #cand==0 then return end
  if not cand[1] then return end
  local ab=cand[1].airbase
  local hitZones={}
  runwayNames={}
  local done = {}
  
  do
    local seen={}
    local runwaytgt=ab:GetRunways() or {}
    for _,r in ipairs(runwaytgt) do
      if r.zone then
        local hdg=(r.heading or 0)%360
        local num=math.floor((hdg+5)/10)%36 ; if num==0 then num=36 end
        local side=r.isLeft==nil and '' or (r.isLeft and 'L' or 'R')
        if num>18 then num=num-18 ; if side=='L' then side='R' elseif side=='R' then side='L' end end
        local id=(num<10 and'0'or'')..tostring(num)..side
        if not seen[id] then
          hitZones[#hitZones+1]=r.zone
          runwayNames[#runwayNames+1]=id
          seen[id]=true
        end
      end
    end
  end
  if #hitZones==0 then return end
  hits,need=0,#hitZones
  runwayTarget=ab:GetName()
  runwayTargetZone = cand[1].zone.zone
  runwayMission = "Active"
  runwayCompleted = false
  env.info('RUNWAY-DBG: picked airdrome '..runwayTargetZone.. ' with '..need..' runways to hit')
  RunwayHandler=EVENT:New()
  function RunwayHandler:OnEventShot(EventData)
    if not (EventData and EventData.IniUnit and EventData.weapon and EventData.IniPlayerName) then return end
    local wp=WEAPON:New(EventData.weapon)
    if not wp:IsBomb() then return end
    env.info('RUNWAY-DBG: '..EventData.IniPlayerName..' dropped '..wp:GetTypeName()..' on '..runwayTargetZone)
    local pilot = EventData.IniPlayerName or 'Unknown hero'
	local playerUnit = EventData.IniUnit
    wp:SetFuncImpact(function(self)
      local p=self:GetImpactVec3()
    if not p or not runwayMission or not runwayTargetZone then
	self:StopTrack() return	end
      for i, z in ipairs(hitZones) do
        local cp=COORDINATE:NewFromVec3(p)
		if not done[z] and (z:IsVec3InZone(p) or z:GetCoordinate():Get2DDistance(cp)<=10) then
		env.info('RUNWAY-DBG: bomb hit '..z:GetName())
		done[z] = true
          hits=hits+1
		 if #runwayNames > 1 then  MESSAGE:New(runwayNames[i] .. ' HIT!', 10, ''):ToUnit(playerUnit) end
          if hits>=need then
			self:StopTrack()
			bomberName = pilot
			runwayCompleted = true
			if bc.playerContributions[2][bomberName]~=nil then
			bc.playerContributions[2][bomberName] = (bc.playerContributions[2][bomberName] or 0) + 100
            bc:addTempStat(bomberName,'Bomb runway',1)
			end
            env.info('RUNWAY-DBG: '..bomberName..' completed runway strike mission at '..runwayTargetZone)
			if 	RunwayHandler then
				RunwayHandler:UnHandleEvent(EVENTS.Shot)
				RunwayHandler=nil
				runwayMission = nil
			end
          end
          break
        end
      end
    end)
    wp:StartTrack()
  end
  RunwayHandler:HandleEvent(EVENTS.Shot)
  end

function checkAndGenerateCASMission()
	if casMissionTarget ~= nil or timer.getTime() < casMissionCooldownUntil then
		return
	end
	casTargetKills = math.random(8,16)
	casMissionTarget = 'Active'
end

function checkAndGenerateCAPMission()
	if capMissionTarget ~= nil or timer.getTime() < capMissionCooldownUntil then
		return
	end
	local countInAir = 0
	for _, zC in pairs(bc.zones) do
		if zC.side == 1 and zC.active then
			for _, groupCom in ipairs(zC.groups) do
				if groupCom.side == 1
				and (groupCom.mission == 'attack' or groupCom.mission == 'patrol')
				and groupCom.state == 'inair' then
					countInAir = countInAir + 1
				end
			end
		end
	end
	local players = getBluePlayersCount()
	local limit = getCapLimit(players)
	if players == 0 then return end
	if countInAir >= 1 then
		if limit == 1 then
			capTargetPlanes = math.random(1,2)
		elseif limit == 2 then
			capTargetPlanes = math.random(2,4)
		elseif limit == 3 then
			capTargetPlanes = math.random(2,5)
		elseif limit == 4 then
			capTargetPlanes = math.random(3,6)
		elseif limit == 5 then
			capTargetPlanes = math.random(4,6)
		elseif limit == 99999 then
			capTargetPlanes = math.random(4,6)
		end
		capMissionTarget = "Active"
	end
end

function getClosestCapZonesToPlayers(missionType, side)
	local zoneSide
	if missionType == 'patrol' then
		zoneSide = (side == 1) and 2 or 1
	elseif missionType == 'attack' then
		zoneSide = side
	else
		zoneSide = (side == 1) and 2 or 1
	end


	local anchors = {}
	local spawnList =
		(side == 2) and (playerZoneSpawnBlue or playerZoneSpawn) or playerZoneSpawnRed
	if type(spawnList) == 'table' then
		for _, spawnZoneName in pairs(spawnList) do
			local spawnZC = bc:getZoneByName(spawnZoneName)
			if spawnZC then
				anchors[#anchors+1] = { zoneName = spawnZC.zone }
			end
		end
	end
	if #anchors == 0 then
		for _, z in ipairs(bc.zones) do
			if z.side == side and z.active then
				local cz = CustomZone:getByName(z.zone)
				if cz then
					anchors[#anchors+1] = { zoneName = z.zone }
				end
			end
		end
	end
	if #anchors == 0 then
		return {}
	end

	local zoneDistances = {}
	local seen = {}
	for _, zoneCom in ipairs(bc.zones) do
		if zoneCom.active and zoneCom.side == zoneSide then
			local znB = zoneCom.zone
			if not seen[znB] then
				local tCZ = CustomZone:getByName(znB)
				if tCZ then
					local sumDist = 0
					for _, p in ipairs(anchors) do
						local znA = p.zoneName
						local d = (ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB]) or 99999999
						sumDist = sumDist + d
					end
					local avgDist = sumDist / #anchors
					table.insert(zoneDistances, { zone = znB, distance = avgDist })
					seen[znB] = true
				end
			end
		end
	end

	table.sort(zoneDistances, function(a, b)
		return a.distance < b.distance
	end)
 	
	if DebugIsOnCAP then
		env.info("[DEBUG] Anchors for "..missionType..":")
		for i=1,#anchors do env.info("  - "..tostring(anchors[i].zoneName)) end
		env.info("[DEBUG] Candidates for "..missionType.." (side="..tostring(zoneSide).."):")
		for _, zoneCom in ipairs(bc.zones) do
			if zoneCom.side == zoneSide and zoneCom.active then
				for _, groupCom in ipairs(zoneCom.groups) do
					if groupCom.MissionType == 'CAP' then
						local znB = groupCom.targetzone
						local tCZ = CustomZone:getByName(znB)
						if tCZ then
							local sum, bad = 0, 0
							for _, p in ipairs(anchors) do
								local znA = p.zoneName
								local d = (ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB]) or nil
								if not d then bad = bad + 1 ; d = 99999999 end
								sum = sum + d
							end
							local avg = sum / #anchors
							env.info(string.format("[DEBUG] cand=%s avg=%.0f missing=%d", tostring(znB), avg, bad))
						else
							env.info("[DEBUG] cand skipped (no CZ): "..tostring(znB))
						end
					end
				end
			end
		end
	end 

	return zoneDistances
end

function GroupCommander:shouldSpawn(ignore)
	if Era and self.Era and self.mission ~= 'supply' and self.Era ~= Era then
		return false
	end

	local tg = self.zoneCommander.battleCommander:getZoneByName(self.targetzone)

	if (tg and tg.suspended) or self.zoneCommander.suspended then return false end

    if self.side ~= self.zoneCommander.side then
		return false 
	end

    if self.condition and not self.condition() then
        return false
    end

	if self.side == 2 and self.Bluecondition and not self.Bluecondition() then
        return false
    end

	if self.side == 1 and self.Redcondition and not self.Redcondition() then
        return false
    end

    local isUrgent = type(self.urgent) == "function" and self.urgent() or self.urgent
	
		
		local distNm = Frontline.ZoneDistToFrontNm(self.targetzone)
		if distNm == nil then
			env.info(("WARNING: could not determine distance to frontline for zone %s"):format(tostring(self.targetzone)))
			return false
		end
		local cutoff = (self.side == 2) and GlobalSettings.frontlineDistanceLimitBlue or GlobalSettings.frontlineDistanceLimitRed
		if distNm < -cutoff then return false end


	if self.template then
        self:_ensureTemplateCache()
        local zside = self.zoneCommander.side
        if zside~=0 and self.side~=zside then
            local lst=self._tplBySide[zside]
            if lst and #lst>0 then self.side=zside else return false end
        end
        if self.side~=0 then
            local lst=self._tplBySide[self.side]
            if not lst or #lst==0 then return false end
        end
    end

	if self.side==2 and self.MissionType=='CAP' then
		if tg then
			local originName = (self.zoneCommander and self.zoneCommander.zone) or nil
			if not originName or tg.zone ~= originName then
				local zn = tg.zone
				if Frontline._zoneInfo and Frontline._zoneInfo[zn] then
					local dnm = Frontline.ZoneDistToFrontNm(zn)
					if dnm and math.abs(dnm) > (GlobalSettings.capRearlineNmBlue or 30) then
						return false
					end
				end
			end
		end
	end

  

    if tg and tg.active then
		if self.mission=='attack' and (self.MissionType=='CAS' or self.MissionType=='SEAD' or self.MissionType=='RUNWAYSTRIKE') then
			if tg.side ~= self.side and tg.side ~= 0 then
				if self.side == 1 then
					if self.MissionType=='SEAD' and not self.zoneCommander.battleCommander:HasSeadTargets(tg.zone) then
						self.state = 'inhangar'
						self.lastStateTime = timer.getAbsTime()
						env.info(string.format("[SEAD-SPAWN] no SEAD targets in %s -> skip", tg.zone))
						return false
					end
					local players = getBluePlayersCount and getBluePlayersCount() or 0
					local limit = getRedStrikeLimit and getRedStrikeLimit(players) or 0
					if limit <= 0 then return false end
					local active = self.zoneCommander.battleCommander:getActiveStrikeCount(1,'attack',self.MissionType,self.unitCategory)
					if active >= limit then
						self.state = 'inhangar'
						self.lastStateTime = timer.getAbsTime()
						return false
					end
					return true
				end
				if self.side==2 then
					if self.MissionType=='SEAD' and not self.zoneCommander.battleCommander:HasSeadTargets(tg.zone) then
						self.state = 'inhangar'
						self.lastStateTime = timer.getAbsTime()
						env.info(string.format("[SEAD-SPAWN] no SEAD targets in %s -> skip", tg.zone))
						return false
					end
					local players = getBluePlayersCount and getBluePlayersCount() or 0
					local limit   = getBlueCasLimit and getBlueCasLimit(players) or 0
					if limit <= 0 then return false end
					local active = self.zoneCommander.battleCommander:getActiveCasSeadCount(2,'attack')
					if active >= limit then
						self.state = 'inhangar'
						self.lastStateTime = timer.getAbsTime()
						return false
					end
					return true
				end
			end
		end
		if self.mission == 'supply' then
			if tg.side == 0 and (not tg.firstCaptureByRed or self.ForceUrgent) then
				if isUrgent then return true end
			end
			if tg.side == self.side or tg.side == 0 then
				self.urgent = false
				if tg:canRecieveSupply() then
					local cap = (self.side==2) and (GlobalSettings.maxSupplyPerZoneBlue or 1) or (GlobalSettings.maxSupplyPerZoneRed or 2)
					local active = self.zoneCommander.battleCommander:getActiveSupplyCount(self.side, self.targetzone)
					if active >= cap then return false end
					local zones = bc.blueZoneCount or 0
					local cost = zones * 10
					if self.side==2 and (bc.accounts[2] ~= nil and bc.accounts[2] < cost) then
						env.info(string.format("[SUPPLY-SPAWN] not enough funds for supply in %s (have %d, need %d)", tg.zone, bc.accounts[2] or 0, cost))
						return false
					end
					self._pendingBlueSupplyCost = cost
					return true
				end
				return false
			end
			return false
		end


        if (self.mission == 'patrol') and (self.MissionType == 'CAP') then
            if tg.side == self.side then
                local totalPlayers = getBluePlayersCount() or 0
                local limit
                if self.side==2 then
                    limit = getBlueCapLimit(totalPlayers)
                else
                    limit = getCapLimit(totalPlayers)
                end
                local currentCap = self.zoneCommander.battleCommander:getActiveCAPCount(self.side, 'patrol')

                if self.side==2 and limit==0 then
                    self.state = 'inhangar'
                    self.lastStateTime = timer.getAbsTime()
                    return false
                end

                if currentCap >= limit then
                    if DebugIsOn then
                        env.info(string.format("[DEBUG] CAP patrol limit reached: currentCap=%d, limit=%d, mission=%s",
                            currentCap, limit, self.name))
                    end
                    self.state = 'inhangar'
                    self.lastStateTime = timer.getAbsTime() + math.random(60, 1800)
                    return false
                end

                local zoneDistances = getClosestCapZonesToPlayers('patrol', (self.side==2) and 1 or 2)
				local enemyPlayers = (self.side==2)
				and (getRedPlayersCount and getRedPlayersCount() or 0)
				or (getBluePlayersCount and getBluePlayersCount() or 0)
				if #zoneDistances==0 or enemyPlayers==0 then return true end
                local capLeft = limit - currentCap
                if capLeft < 1 then capLeft = 1 end
                local capWindow = math.min(#zoneDistances, capLeft)
                local allowedZones, seen, count = {}, {}, 0
                for i=1,#zoneDistances do
                    if zoneDistances[i].zone == tg.zone and not seen[tg.zone] then
                        seen[tg.zone] = true
                        allowedZones[#allowedZones+1] = tg.zone
                        count = count + 1
                        break
                    end
                end
                for i=1,#zoneDistances do
                    local zn = zoneDistances[i].zone
                    if not seen[zn] then
                        seen[zn] = true
                        allowedZones[#allowedZones+1] = zn
                        count = count + 1
                        if count >= capWindow then break end
                    end
                end
                for _, zName in ipairs(allowedZones) do
                    if zName == tg.zone then return true end
                end
                if DebugIsOn then
                    env.info(string.format("[DEBUG] CAP patrol is not within the top %d zones; skipping spawn: mission=%s", capWindow, self.name))
                end
                self.state = 'inhangar'
                self.lastStateTime = timer.getAbsTime()
                return false
            end
            return false
        end


        if (self.mission == 'attack') and (self.MissionType == 'CAP') then
            if tg.side ~= self.side and tg.side ~= 0 then
                local totalPlayers = getBluePlayersCount() or 0
                local limit = (self.side==2) and getBlueCapLimit(totalPlayers) or getCapLimit(totalPlayers)
                local currentCap = self.zoneCommander.battleCommander:getActiveCAPCount(self.side, 'attack')
                if self.side==2 and limit==0 then
                    self.state = 'inhangar'
                    self.lastStateTime = timer.getAbsTime()
                    return false
				end

                if currentCap >= limit then
                    if DebugIsOn then
                        env.info(string.format("[DEBUG] CAP attack limit reached: currentCap=%d, limit=%d, mission=%s",
                            currentCap, limit, self.name))
                    end
                    self.state = 'inhangar'
					self.lastStateTime = timer.getAbsTime()
                    return false
                end

                local zoneDistances = getClosestCapZonesToPlayers('attack', (self.side==2) and 1 or 2)
                if #zoneDistances==0 then return true end
                local capLeft = limit - currentCap
                if capLeft < 1 then capLeft = 1 end
                local capWindow = math.min(#zoneDistances, capLeft)
                for i=1,#zoneDistances do
                    if zoneDistances[i].zone == tg.zone then return true end
                end
                if DebugIsOn then
                    env.info(string.format("[DEBUG] attack CAP is not within the top %d zones; skipping spawn: mission=%s", capWindow, self.name))
                end
                self.state = 'inhangar'
                self.lastStateTime = timer.getAbsTime()
                return false
            end
        end

        if (self.mission == 'attack') and not (self.MissionType == 'CAP' or self.MissionType == 'CAS' or self.MissionType == 'SEAD' or self.MissionType == 'RUNWAYSTRIKE') then
            if tg.side ~= self.side and tg.side ~= 0 then
                return true
            end
        end

		if (self.mission == 'patrol') and not (self.MissionType == 'CAP' or self.MissionType == 'CAS' or self.MissionType == 'SEAD') then
            if tg.side == self.side then
                return true
            end
        end

        return false
    end
    return false
end

	function GroupCommander:clearWreckage()
		local tg = self.zoneCommander.battleCommander:getZoneByName(self.targetzone)
		tg:clearWreckage()
	end

function GroupCommander:_jtacMessage(txt, instant, z)
    z = z or self.targetzone or (self.zoneCommander and self.zoneCommander.zone)
    if not z then return end
    for _,v in ipairs(jtacQueue or {}) do
        if v.tgtzone and v.tgtzone.zone and v.tgtzone.zone == z then
            if instant then
                trigger.action.outTextForCoalition(2, txt..' '..z, 25)
            else
                timer.scheduleFunction(
                    function() trigger.action.outTextForCoalition(2, txt..' '..z, 25) end,
                    {}, timer.getTime() + math.random(30,60)
                )
            end
            break
        end
    end
end

function GroupCommander:_spawnFromGroundAt(resolved, originZone, targetZone)
    local tpl = self:_getAirTemplate(resolved); if not tpl then return nil end
    local base = originZone and (originZone.."-land") or nil
    local pool = nil
    if base and LandingSpots then
        pool = {}
        for n, lst in pairs(LandingSpots) do
            if n:sub(1, #base) == base then
                for i=1,#lst do pool[#pool+1] = lst[i] end
            end
        end
    end
    local p
    if pool and #pool>0 then
        LandingSpotsUsedIndex = LandingSpotsUsedIndex or {}
        local idx = ((LandingSpotsUsedIndex[base] or 0) % #pool) + 1
        LandingSpotsUsedIndex[base] = idx
        p = pool[idx]
    else
        local lz = self:_findFlatLZ(originZone, 50, 0.06)
        if lz then p = {x=lz.x, z=lz.z} end
    end
    if not p then return nil end
    local jitter = 8
    local lx, lz = p.x + math.random(-jitter,jitter), p.z + math.random(-jitter,jitter)

    local ly = land.getHeight({x=lx, y=lz})
    tpl.x = lx; tpl.y = lz
    tpl.route = tpl.route or {}; tpl.route.points = tpl.route.points or {}; tpl.route.points[1] = tpl.route.points[1] or {}
    tpl.route.points[1].type = "TakeOffGround"; tpl.route.points[1].action = "From Ground Area"; tpl.route.points[1].x = lx; tpl.route.points[1].y = lz; tpl.route.points[1].alt = 0; tpl.route.points[1].alt_type = "RADIO"
    for i=1,#tpl.units do local u=tpl.units[i]; u.x=lx; u.y=lz; u.alt=ly; u.parking=nil; u.parking_id=nil end
    local sp = SPAWN:NewFromTemplate(tpl, resolved, self.name, true)
    if self.mission=='supply' and self.unitCategory==Unit.Category.HELICOPTER then
        sp = sp:OnSpawnGroup(function(g) self:_assignHeloRoute(g:GetName(), self.targetzone) end)
    end
    return sp:Spawn()
end

function GroupCommander:_getAirTemplate(resolved)
	local grp = GROUP:FindByName(resolved)
	local tpl = (_DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and _DATABASE.Templates.Groups[resolved] and UTILS.DeepCopy(_DATABASE.Templates.Groups[resolved].Template)) or (grp and grp:GetTemplate())
	return tpl
end

function GroupCommander:_getAirType()
	local gr = Group.getByName(self.name)
	if gr then
		local u = gr:getUnit(1)
		if u then
			local name = UTILS.GetReportingName(u:getTypeName())
			name = name:gsub("_%u$", ""):gsub("_", " ")
			local cnt  = gr:getSize()
			if cnt and cnt > 1 then
				return cnt .. " enemy " .. name .. "s"
			end
			return "enemy " .. name
		end
	end
	return "enemy Bogey"
end

	ProblemGroups = {}
	function GroupCommander:processAir()
		local originZone = self.zoneCommander.zone
		local gr = Group.getByName(self.spawnedName or self.name)
		local zside = self.zoneCommander.side
		local plane = Unit.Category.AIRPLANE
		local heli = Unit.Category.HELICOPTER
		
		if self.template then
			if zside and zside ~= 0 and zside ~= self.side then self.side = zside end
		end

		local coalition = self.side
		local isUrgent = type(self.urgent) == "function" and self.urgent() or self.urgent
		--local respawnTimers = isUrgent and GlobalSettings.urgentRespawnTimers or GlobalSettings.respawnTimers[coalition][self.mission]
		local rt=GlobalSettings and GlobalSettings.respawnTimers
		local respawnTimers=isUrgent and GlobalSettings.urgentRespawnTimers or (rt and rt[coalition] and rt[coalition][self.mission])
		if not respawnTimers then if coalition ~= 0 then local reason=(not GlobalSettings and "GlobalSettings") or (not rt and "GlobalSettings.respawnTimers") or (rt[coalition]==nil and ("respawnTimers["..tostring(coalition).."]")) or ("respawnTimers["..tostring(coalition).."]["..tostring(self.mission).."]"); local msg="ERROR: Report to Leka and send log! respawnTimers nil "..reason.." name="..tostring(self.name).." mission="..tostring(self.mission).." side="..tostring(coalition).." urgent="..tostring(isUrgent); env.info(msg); trigger.action.outText(msg,30); ProblemGroups[self.name]=true end; return end

		local spawnDelayFactor = self.spawnDelayFactor or 1
		
		
		if self.mission == 'supply' and not isUrgent and self.side == 1 then
			local pc = getBluePlayersCount()
			if pc == 0 then
				spawnDelayFactor = spawnDelayFactor * 1.5
			elseif pc == 1 then
				spawnDelayFactor = spawnDelayFactor * 1.3
			end
		end

		if not gr or gr:getSize() == 0 then
			if gr and gr:getSize() == 0 then
				gr:destroy()
			end

			if self.state ~= 'inhangar' and self.state ~= 'preparing' and self.state ~= 'dead' then
				self.state = 'dead'
				self.lastStateTime = timer.getAbsTime()
			end
		end

    if self.state == 'inhangar' then
        if timer.getAbsTime() - self.lastStateTime > (respawnTimers.hangar * spawnDelayFactor) then
            if self.diceChance and self.diceChance > 0 and not self.diceRolled then
                self.diceRolled = true
                local roll = math.random(1, 100)
                if roll > self.diceChance then
                    self.state = 'dead'
                    self.lastStateTime = timer.getAbsTime()
                    self.diceRolled = false
                    return
                end
            end

            if self:shouldSpawn() then
                self.state = 'preparing'
                self.lastStateTime = timer.getAbsTime()
            end
        end
	elseif self.state == 'preparing' then
		if timer.getAbsTime() - self.lastStateTime > respawnTimers.preparing then
			if self:shouldSpawn() then
				self:clearWreckage()
				local didSpawn = false
				if self.template then
					local set = self:_getTemplateSet(self.template)
					if set and #set > 0 then
						local resolved = self:_resolveTemplateName()
						local SpawnType = self:_resolveSpawn()
						self._landUnitID = SpawnType and SpawnType.airbaseId or nil
						if (not SpawnType or not (SpawnType.airbase and SpawnType.spots and #SpawnType.spots>0)) and self.unitCategory==Unit.Category.AIRPLANE then
							SpawnType = self:_resolveParkingWithBelonging()
						end
						if SpawnType and SpawnType.kind == 'parking' and SpawnType.airbase and SpawnType.spots and #SpawnType.spots>0 then
							local tpl = self:_getAirTemplate(resolved)
							if tpl then
								local sp = SPAWN:NewFromTemplate(tpl, resolved, self.name, true)
								sp = sp:OnSpawnGroup(function(g)
									SCHEDULER:New(nil,function()
										if self.MissionType == 'CAP' and self.template then
											local gr = Group.getByName(g:GetName()); if not gr then return end
											local side = self.side
											local offsetNm = (side == 1) and math.random(10, 20) or math.random(1, 5)
											local st = Frontline.PickStationNearZone(self.targetzone, originZone, 0, 0, 0, 0)
											if not st then return end
											local dist = (side == 1) and math.random(30, 35) or math.random(30, 40)
											SetUpCAP(gr, { x = st.x, z = st.y }, self.Altitude or self.AltitudeFt, dist, self._landUnitID, 35)
										elseif self.mission == 'supply' and self.unitCategory == heli then
											if self.side == 2 and self._pendingBlueSupplyCost then
												self.zoneCommander.battleCommander.accounts[2] = math.max((self.zoneCommander.battleCommander.accounts[2] or 0) - self._pendingBlueSupplyCost, 0)
												self._pendingBlueSupplyCost = nil end
											self:_assignHeloRoute(g:GetName(), self.targetzone, self._landUnitID)
										elseif self.mission == 'supply' and self.unitCategory == plane then
											if self.side == 2 and self._pendingBlueSupplyCost then
												self.zoneCommander.battleCommander.accounts[2] = math.max((self.zoneCommander.battleCommander.accounts[2] or 0) - self._pendingBlueSupplyCost, 0)
												self._pendingBlueSupplyCost = nil end
											self:_assignPlaneRoute(g:GetName(), self.targetzone)
										elseif self.MissionType=='CAS' and self.unitCategory == plane and self.template then
											bc:EngageCasMission(self.targetzone, g:GetName(), nil, nil, self.Altitude or self.AltitudeFt, self._landUnitID)
										elseif self.MissionType=='CAS' and self.unitCategory == heli and self.template then
											bc:EngageHeloCasMission(self.targetzone, g:GetName(), nil, nil, self._landUnitID)
										elseif self.MissionType=='SEAD' and self.unitCategory == plane and self.template then
											bc:EngageSeadMission(self.targetzone, g:GetName(), nil, self.Altitude or self.AltitudeFt)
										elseif self.MissionType=='RUNWAYSTRIKE' and self.unitCategory == plane and self.template then
											bc:EngageRunwayBombAuftrag(self.zoneCommander.airbaseName, self.targetzone, g:GetName(), self.Altitude or self.AltitudeFt, self.side)
										end
									end,{},1)
								end)
								local tk = (self.mission == 'supply' and self.side == 2) and SPAWN.Takeoff.Hot or SPAWN.Takeoff.Cold
								local spawned = sp:SpawnAtParkingSpot(SpawnType.airbase, SpawnType.spots, tk)
								if spawned then spawned:OptionPreferVerticalLanding(); self.spawnedName = spawned:GetName(); didSpawn = true end
							end
						else
							local spawned = self:_spawnFromGroundAt(resolved, originZone, self.targetzone)
							if spawned then
								if (self.mission=='supply' or self.MissionType=='CAS') and self.unitCategory == heli then spawned:OptionPreferVerticalLanding() end
								self.spawnedName = spawned:GetName()
								didSpawn = true
							end
						end
					end
				else
					if self.side == zside then
						Respawn.Group(self.name)
						self.spawnedName = self.name
						didSpawn = true
					end
				end

				if isUrgent then env.info("Group [" .. self.name .. "] is spawning urgently!") else env.info("Group [" .. self.name .. "] is spawning normally.") end
				local gv = Group.getByName(self.spawnedName or self.name)
				if gv and Utils.someOfGroupInZone(gv, originZone) then
				local tp = self:_getAirType()
				self.pinged = false
				self:_jtacMessage('JTAC: We spotted '..tp..' starting up at', nil, originZone)
				self._zonePinged = nil
				self.pinged = true
				end
				self.Spawned = true
				self.state = 'takeoff'
				self.lastStateTime = timer.getAbsTime()
			end
		end

		elseif self.state == 'takeoff' then
			if timer.getAbsTime() - self.lastStateTime > GlobalSettings.blockedDespawnTime then
				if gr and Utils.allGroupIsLanded(gr, self.landsatcarrier) then
					gr:destroy()
					self.state = 'inhangar'
					self.lastStateTime = timer.getAbsTime()
				end
			elseif gr and Utils.someOfGroupInAir(gr) then
					if self.pinged then
					local tp = self:_getAirType()
						self:_jtacMessage('JTAC: '..tp..' just took off from', true, originZone)
					end
					--env.info("Group [" .. self.name .. "] is airborne")
					self.state = 'inair'
					self.pinged = false
					self.lastStateTime = timer.getAbsTime()
			end

		elseif self.state == 'inair' then
			if self.mission=='supply' and not self._zonePinged then
				local tg = self.zoneCommander.battleCommander:getZoneByName(self.targetzone)
				if tg and gr and Utils.someOfGroupInZone(gr, tg.zone) then
					local tp = self:_getAirType()
					self:_jtacMessage('JTAC: Have eyes on '..tp..' inbound and about to land at',true,tg.zone)
					self._zonePinged = true
				end
			end
			if gr and Utils.allGroupIsLanded(gr, self.landsatcarrier) then
				self.state = 'landed'
				self.lastStateTime = timer.getAbsTime()
			end
		
		elseif self.state == 'landed' then
			self._landedAt = self._landedAt or timer.getAbsTime()
			if self.mission == 'supply' then
				local tg = self.zoneCommander.battleCommander:getZoneByName(self.targetzone)
				if tg and gr and Utils.someOfGroupInZone(gr, tg.zone) then
					self.state = 'inhangar'
					self.lastStateTime = timer.getAbsTime()
					self._landedAt = nil
					if tg.side == 0 then
						env.info("Group [" .. self.name .. "] landed in zone [" .. tg.zone .. "], capturing zone for side " .. self.side)
						SCHEDULER:New(nil,function() tg:capture(self.side) end,{},0.3,0)
					elseif tg.side == self.side then
						env.info("Group [" .. self.name .. "] landed in zone [" .. tg.zone .. "], upgrading zone for side " .. self.side)
						tg:upgrade()
					end
					SCHEDULER:New(nil,function() if gr and gr:isExist() then gr:destroy() end end,{},0.5,0)
				else
					local hb = self.zoneCommander.battleCommander:getZoneByName(self.zoneCommander.zone)
					if hb and gr and Utils.someOfGroupInZone(gr, hb.zone) then
						self.state = 'inhangar'
						self.lastStateTime = timer.getAbsTime()
						self._landedAt = nil
						SCHEDULER:New(nil,function() if gr and gr:isExist() then gr:destroy() end end,{},0.5,0)
					end
				end
			end
			local landedDespawnTime = (self.mission == 'supply' and self.unitCategory == plane ) and 180 or GlobalSettings.landedDespawnTime
			if timer.getAbsTime() - (self._landedAt or self.lastStateTime) > landedDespawnTime then
				if gr then gr:destroy() end
				self.state = 'inhangar'
				self.lastStateTime = timer.getAbsTime()
				self._landedAt = nil
			end
		elseif self.state == 'dead' then
			if timer.getAbsTime() - self.lastStateTime > (respawnTimers.dead * spawnDelayFactor) then
				if self:shouldSpawn() then
					self.state = 'preparing'
					self.lastStateTime = timer.getAbsTime()
				end
			end
		end
	end

	
	function GroupCommander:processSurface()
		local originZone = self.zoneCommander and self.zoneCommander.zone
		local gr
		if self.spawnedName and self.spawnedName ~= "" then gr = Group.getByName(self.spawnedName) end
		if not gr and self.name and self.name ~= "" then gr = Group.getByName(self.name) end
		local zside
		if self.template then
			zside = self.zoneCommander.side
			if zside and zside ~= 0 and zside ~= self.side then self.side = zside end
		end
		local coalition = self.side
		local isUrgent = type(self.urgent) == "function" and self.urgent() or self.urgent
		local respawnTimers = isUrgent and GlobalSettings.urgentRespawnTimers or GlobalSettings.respawnTimers[coalition][self.mission]
		local spawnDelayFactor = self.spawnDelayFactor or 1
		if self.mission == 'supply' and not isUrgent and self.side == 1 then
			local pc = getBluePlayersCount()
			if pc == 0 then
				spawnDelayFactor = spawnDelayFactor * 3
			elseif pc == 1 then
				spawnDelayFactor = spawnDelayFactor * 2.5
			elseif pc == 2 then
				spawnDelayFactor = spawnDelayFactor * 2
			elseif pc == 3 then
				spawnDelayFactor = spawnDelayFactor * 1.5				
			end
			--env.info(string.format("[SUPPLY_DELAY] players=%d factor=%.2f mission=%s", pc, spawnDelayFactor, self.name))
		elseif self.mission == 'attack' and not isUrgent then
			local pc = getBluePlayersCount()
			if pc == 0 then
				spawnDelayFactor = spawnDelayFactor * 3
			elseif pc == 1 then
				spawnDelayFactor = spawnDelayFactor * 2.5
			elseif pc == 2 then
				spawnDelayFactor = spawnDelayFactor * 2
			elseif pc == 3 then
				spawnDelayFactor = spawnDelayFactor * 1.5
			elseif pc == 4 then
				spawnDelayFactor = spawnDelayFactor * 1.25
			end
		end
		-- local uc = (self.zoneCommander and self.zoneCommander.upgradeCompletion) or 0
		-- local lack = 1 - uc
		-- local expo = (self.mission == 'supply') and 1 or (GlobalSettings.upgradeSlowExpo or 1)
		-- local maxm = (self.mission == 'supply') and (GlobalSettings.supplySlowMax or 1.0) or (GlobalSettings.upgradeSlowMax or 1)
		-- local slowMul = 1 + (lack ^ expo) * maxm
		-- spawnDelayFactor = spawnDelayFactor * slowMul

		if not gr or gr:getSize() == 0 then
			if gr and gr:getSize() == 0 then
				gr:destroy()
			end

			if self.state ~= 'inhangar' and self.state ~= 'preparing' and self.state ~= 'dead' then
				self.state = 'dead'
				self.lastStateTime = timer.getAbsTime()
			end
		end

   		 if self.state == 'inhangar' then
			if timer.getAbsTime() - self.lastStateTime > (respawnTimers.hangar * spawnDelayFactor) then
				if self.diceChance and self.diceChance > 0 and not self.diceRolled then
					self.diceRolled = true
					local roll = math.random(1, 100)
					if roll > self.diceChance then
						self.state = 'dead'
						self.lastStateTime = timer.getAbsTime()
						self.diceRolled = false
						return
					end
				end
            if self:shouldSpawn() then
                self.state = 'preparing'
                self.lastStateTime = timer.getAbsTime()
            end
        end
    elseif self.state == 'preparing' then
        if timer.getAbsTime() - self.lastStateTime > (respawnTimers.preparing * spawnDelayFactor) then
            if self:shouldSpawn() then
				self:clearWreckage()             
				local templateName = self.template or self.name
                self:_ensureTemplateCache()
                local set = self:_getTemplateSet(templateName)
                if set and #set>0 then
                    local originZoneName = self.zoneCommander and self.zoneCommander.zone
                    local targetZoneName = self.targetzone
                    local task, startVec2
                    if self.mission == 'supply' then
                        task, startVec2 = dc.BuildSupplyConvoyRoute(originZoneName, targetZoneName, dc.DEFAULT_SPEED)
                    else
                        task, startVec2 = dc.BuildAttackConvoyRoute(originZoneName, targetZoneName, dc.DEFAULT_SPEED)
                    end
                    if task and startVec2 then
                        local chosenTemplate = self:_resolveTemplateName()
                        if chosenTemplate then
                            local tpl = self:_getAirTemplate(chosenTemplate)
                            if tpl then
                                local sp = SPAWN:NewFromTemplate(tpl, chosenTemplate, self.name, true)
                                SCHEDULER:New(nil,function() 
									local g = Group.getByName(self.name)
									if g then
										local c = g:getController()
										if c then
											c:setTask(task)
										end
									end
								end,{},2,0)
                                local p = POINT_VEC2:New(startVec2.x, startVec2.y)
                                local spawned = sp:SpawnFromPointVec2(p)
                                if spawned then
                                    self.spawnedName = spawned:GetName()
                                    if isUrgent then env.info("Dynamic Group [" .. self.name .. "] is spawning urgently!") else env.info("Dynamic Group [" .. self.name .. "] is spawning normally.") end
                                else
                                    env.info("ERROR: Dynamic Group [" .. self.name .. "] failed to spawn!")
                                end
                            else
                                env.info("ERROR: No template found for ["..tostring(chosenTemplate).."]")
                            end
                        else
                            env.info("ERROR: No valid template for side "..tostring(self.side).." in set "..tostring(self.template))
                        end
					end
                else
                    Respawn.Group(self.name)
                    if isUrgent then env.info("Group [" .. self.name .. "] is spawning urgently!") else env.info("Group [" .. self.name .. "] is spawning normally.") end
                end
                self:_jtacMessage('JTAC: We spotted enemy convoy headed outside', nil, originZone)
                self.state = 'enroute'
				self.groundconvoyMessaged = false
                self.lastStateTime = timer.getAbsTime()
            end
        end

		elseif self.state == 'enroute' then
			local tg = self.zoneCommander.battleCommander:getZoneByName(self.targetzone)
			if tg and gr and Utils.someOfGroupInZone(gr, tg.zone) then
				self.state = 'atdestination'
				self.lastStateTime = timer.getAbsTime()
			else
				if not self.groundconvoyMessaged and self.side == 1 then
					local shouldWeSend = math.random(0,100)
					if shouldWeSend > 95 then
						trigger.action.outTextForCoalition(2,"Intel: Enemy convoy is headed toward " .. self.targetzone .. ".",15)
						self.groundconvoyMessaged = true
					end
				end
			end

		elseif self.state == 'atdestination' then
			if self.mission == 'supply' then
				if timer.getAbsTime() - self.lastStateTime > GlobalSettings.landedDespawnTime then
					local tg = self.zoneCommander.battleCommander:getZoneByName(self.targetzone)
					if tg and gr and Utils.someOfGroupInZone(gr, tg.zone) then
						self.state         = 'inhangar'
						self.lastStateTime = timer.getAbsTime()
						if tg.side == 0 then
							SCHEDULER:New(nil,function()
							tg:capture(self.side)
							end,{},1.0,0)
						elseif tg.side == self.side then
							tg:upgrade()
						end
						if gr then
							gr:destroy()
						end
					end
				end
		elseif self.mission == 'attack' then
			if timer.getAbsTime() - self.lastStateTime > GlobalSettings.landedDespawnTime then
				local tg = self.zoneCommander.battleCommander:getZoneByName(self.targetzone)
				if tg and gr and Utils.someOfGroupInZone(gr, tg.zone) then
					if tg.side == 0 then
						tg:capture(self.side)
						gr:destroy()
						self.state = 'inhangar'
						self.lastStateTime = timer.getAbsTime()
					end
				end
			end
		end
		elseif self.state == 'dead' then
			if timer.getAbsTime() - self.lastStateTime > (respawnTimers.dead * spawnDelayFactor) then
				if self:shouldSpawn() then
					self.state = 'preparing'
					self.lastStateTime = timer.getAbsTime()
				end
			end
		end
	end

	function GroupCommander:update()
		if self.type == 'air' or self.type == 'carrier_air' then
			self:processAir()
		elseif self.type == 'surface' then
			self:processSurface()
		end
	end
end

BudgetCommander = {}
do
	--{ battleCommander = object, side=coalition, decissionFrequency=seconds, decissionVariance=seconds, skipChance=percent}
	function BudgetCommander:new(obj)
		obj = obj or {}
		setmetatable(obj, self)
		self.__index = self
		return obj
	end
	
	function BudgetCommander:update()
		local budget = self.battleCommander.accounts[self.side]
		local options = self.battleCommander.shops[self.side]
		local canAfford = {}
		for i,v in pairs(options) do
			if v.cost<=budget and (v.stock==-1 or v.stock>0) then
				table.insert(canAfford, i)
			end
		end
		
		local dice = math.random(1,100)
		if dice > self.skipChance then
			for i=1,10,1 do
				local choice = math.random(1, #canAfford)
				local err = self.battleCommander:buyShopItem(self.side, canAfford[choice])
				if not err then
					break
				else
					canAfford[choice]=nil
				end
			end
		end
	end
	
	function BudgetCommander:scheduleDecission()
		local variance = math.random(1, self.decissionVariance)
		SCHEDULER:New(nil,self.update,{self},variance,0)
	end
	
	function BudgetCommander:init()
		SCHEDULER:New(nil,self.scheduleDecission,{self},self.decissionFrequency,self.decissionFrequency)
	end
end

EventCommander = {}
do
	--{ decissionFrequency=seconds, decissionVariance=seconds, skipChance=percent}
	function EventCommander:new(obj)
		obj = obj or {}
		obj.events = {}
		setmetatable(obj, self)
		self.__index = self
		return obj
	end
	
	function EventCommander:addEvent(event)--{id=string, action=function, canExecute=function}
		table.insert(self.events, event)
	end
	
	function EventCommander:triggerEvent(id)
		for _,v in ipairs(self.events) do
			if v.id == id and v:canExecute() then
				v:action()
				break
			end
		end
	end
	
	function EventCommander:chooseAndStart(time)
		local canRun = {}
		for i,v in ipairs(self.events) do
			if v:canExecute() then
				table.insert(canRun, v)
			end
		end
		
		if #canRun == 0 then return end
		
		local dice = math.random(1,100)
		if dice > self.skipChance then
			local choice = math.random(1, #canRun)
			local err = canRun[choice]:action()
		end
	end
	
	function EventCommander:scheduleDecission(time)
		local variance = math.random(1, self.decissionVariance)
		timer.scheduleFunction(self.chooseAndStart, self, time + variance)
		return time + self.decissionFrequency + variance
	end
	
	function EventCommander:init()
		timer.scheduleFunction(self.scheduleDecission, self, timer.getTime() + self.decissionFrequency)
	end
end
SelfJtac = {}

do
    SelfJtac.categories = {}
	SelfJtac.categories['SAM'] = {'SAM SR', 'SAM TR', 'IR Guided SAM'}
	SelfJtac.categories['Infantry'] = {'Infantry'}
	SelfJtac.categories['Armor'] = {'Tanks','IFV','APC'}
	SelfJtac.categories['Support'] = {'Unarmed vehicles','Artillery','SAM LL','SAM CC'}
	SelfJtac.categories['Structures'] = {'StaticObjects'}

    	--{name = 'groupname'}
	function SelfJtac:new(obj)
		obj = obj or {}
		obj.lasers = {tgt=nil, ir=nil}
		obj.target = nil
		obj.priority = nil
		obj.jtacMenu = nil
		obj.laserCode = 1688
        obj.groupID = Group.getByName(obj.name):getID()
		obj.side = Group.getByName(obj.name):getCoalition()
        obj.timer = nil
		obj.distUnit='NM'
		obj.autoTimer=nil
		setmetatable(obj, self)
		self.__index = self
		return obj
	end

    function SelfJtac:setCode(code)
        if code>=1111 and code <= 1788 then
            self.laserCode = code
            trigger.action.outTextForGroup(self.groupID, 'Laser code set to '..code, 10)
        else
            trigger.action.outTextForGroup(self.groupID, 'Invalid laser code. Must be between 1111 and 1788 ', 10)
        end
    end
	
	function SelfJtac:showMenu()
		local gr = Group.getByName(self.name)
		if not gr then
			return
		end
		
		if not self.jtacMenu then
			self.jtacMenu = missionCommands.addSubMenuForGroup(self.groupID, 'Laser Designator')

			missionCommands.addCommandForGroup(self.groupID, 'Search', self.jtacMenu, function(dr)
				if Group.getByName(dr.name) then
					dr:searchTarget()
				end
			end, self)
			
			missionCommands.addCommandForGroup(self.groupID, 'Target info', self.jtacMenu, function(dr)
				if Group.getByName(dr.name) then
					dr:printTarget(true)
				end
			end, self)
			
			missionCommands.addCommandForGroup(self.groupID, 'Mark with Smoke', self.jtacMenu, function(dr)
				if Group.getByName(dr.name) then
					dr:markWithSmoke()
				end
			end, self)
            
			missionCommands.addCommandForGroup(self.groupID, 'Clear', self.jtacMenu, function(dr)
				if Group.getByName(dr.name) then
					dr:clearTarget()
                    trigger.action.outTextForGroup(dr.groupID, 'Target cleared', 10)
				end
			end, self)
			
			local priomenu = missionCommands.addSubMenuForGroup(self.groupID, 'Priority', self.jtacMenu)
			for i,v in pairs(SelfJtac.categories) do
				missionCommands.addCommandForGroup(self.groupID, i, priomenu, function(dr, cat)
					if Group.getByName(dr.name) then
						dr:setPriority(cat)
                        if dr.target then
						    dr:searchTarget()
                        end
					end
				end, self, i)
			end
			local opt=missionCommands.addSubMenuForGroup(self.groupID,'Options',self.jtacMenu)
			missionCommands.addCommandForGroup(self.groupID,'Toggle KM / NM',opt,SelfJtac.toggleUnit,self)
			missionCommands.addCommandForGroup(self.groupID,'Toggle Auto-Search',opt,SelfJtac.toggleAuto,self)
			missionCommands.addCommandForGroup(self.groupID,'Toggle Auto-Next target',opt,SelfJtac.toggleNext,self)
            
			local dial = missionCommands.addSubMenuForGroup(self.groupID, 'Code', opt)
            for i2=1,7,1 do
                local digit2 = missionCommands.addSubMenuForGroup(self.groupID, '1'..i2..'__', dial)
                for i3=1,9,1 do
                    local digit3 = missionCommands.addSubMenuForGroup(self.groupID, '1'..i2..i3..'_', digit2)
                    for i4=1,9,1 do
                        local code = tonumber('1'..i2..i3..i4)
                        missionCommands.addCommandForGroup(self.groupID, '1'..i2..i3..i4, digit3, self.setCode, self, code)
                    end
                end
            end
			
			missionCommands.addCommandForGroup(self.groupID, "Clear", priomenu, function(dr)
				if Group.getByName(dr.name) then
					dr:clearPriority()
				end
			end, self)
			self.selectTargetMenu = missionCommands.addSubMenuForGroup(self.groupID, 'Select Target', self.jtacMenu)
		end
	end

	function SelfJtac:toggleUnit()
		self.distUnit = self.distUnit=='NM' and 'KM' or 'NM'
		trigger.action.outTextForGroup(self.groupID,'Distance: '..self.distUnit,10)
		self:printTarget(true)
	end

	function SelfJtac:toggleAuto()
		if self.autoTimer then
			timer.removeFunction(self.autoTimer)
			self.autoTimer = nil
			trigger.action.outTextForGroup(self.groupID,'Auto search OFF',10)
		else
			self.autoTimer = timer.scheduleFunction(function(p) p:searchTarget(true) return timer.getTime()+30 end, self, timer.getTime()+30)
			trigger.action.outTextForGroup(self.groupID,'Auto search ON',10)
		end
	end
	
	function SelfJtac:setPriority(prio)
		self.priority = SelfJtac.categories[prio]
		self.prioname = prio
        trigger.action.outTextForGroup(self.groupID, 'Focusing on '..prio, 10)
	end
	
	function SelfJtac:toggleNext()
	self.autoNext = not self.autoNext
		local state = self.autoNext and 'ON' or 'OFF'
		trigger.action.outTextForGroup(self.groupID,'Auto-next '..state,5)
	end

	function SelfJtac:clearPriority()
		self.priority = nil
	end
	
	function SelfJtac:setTarget(unit)
		
		local me = Group.getByName(self.name)
		if not me then return end

        local meun = me:getUnit(1)
        local stats = SelfJtac.getAircraftStats(meun:getDesc().typeName)
		
		local pnt = unit:getPoint()

        local unitPos = meun:getPosition()
        local unitheading = math.deg(math.atan2(unitPos.x.z, unitPos.x.x))
        local bearing = SelfJtac.getBearing(meun:getPoint(), pnt)
        local unitDistance = SelfJtac.getDist(pnt, meun:getPoint())
        
        local deviation = math.abs(SelfJtac.getHeadingDiff(unitheading, bearing))

        local from = meun:getPoint()
        from.y = from.y+1.5
        local to = unit:getPoint()
        to.y = to.y+1.5

        if unitDistance > (stats.minDist * 1000) or deviation > stats.maxDeviation or not land.isVisible(from, to) then
            self:clearTarget()
			trigger.action.outTextForGroup(self.groupID, "Target out of bounds, stoping laser", 10)
            return
        end

        local dst = 99999
        if self.prevPnt then
            dst = SelfJtac.getDist(pnt, self.prevPnt)
        end
        
        if not self.prevPnt or dst >= 0.5 then

            if self.lasers.tgt then
                self.lasers.tgt:setPoint(pnt)
            else
                self.lasers.tgt = Spot.createLaser(meun, { x = 0, y = 5.0, z = 0 }, SelfJtac.getPointOnSurface(pnt), self.laserCode)
            end
            
            if self.lasers.ir then
                self.lasers.ir:setPoint(pnt)
            else
                self.lasers.ir = Spot.createInfraRed(meun, stats.laserOffset, pnt)
            end

            self.prevPnt = pnt
        end
		
		self.target = unit:getName()

        timer.scheduleFunction(function(param, time)
            param:updateTarget()
        end, self, timer.getTime()+0.5)
	end
	
function SelfJtac:printTarget(makeitlast)
		local toprint = ''
		if self.target then
			local tgtunit = Unit.getByName(self.target)
			local isStructure = false
			if not tgtunit then 
				tgtunit = StaticObject.getByName(self.target)
				isStructure = true
			end
			if tgtunit and tgtunit:isExist() and (not tgtunit.isActive or tgtunit:isActive()) and tgtunit:getLife()>=1 then
				local pnt = tgtunit:getPoint()
				local meun = Group.getByName(self.name):getUnit(1)
				local bearing = math.floor(SelfJtac.getBearing(meun:getPoint(), pnt)+0.5)
				local dist = SelfJtac.getDist(meun:getPoint(), pnt)
				local distStr=self.distUnit=='KM' and string.format('%.2f km',dist/1000) or string.format('%.1f NM',dist/1852)
				local tgttype = "Unidentified"
				if isStructure then
					tgttype = "Structure"
				else
					tgttype = renameType(tgtunit:getTypeName())
				end
				if self.priority then
					toprint = 'Priority targets: '..self.prioname..'\n'
				end
				toprint = toprint..'Lasing '..tgttype..'\nCode: '..self.laserCode..'\n\nBearing: '..string.format('%03d',bearing)..'°  Dist: '..distStr..'\n'
				local lat,lon,alt = coord.LOtoLL(pnt)
				local c = COORDINATE:NewFromVec3(pnt)
				local function ddm(v,h)local d=math.floor(math.abs(v))local m=(math.abs(v)-d)*60 return string.format("[%s %02d %06.3f']",h,d,m)end
				local function dms(v,h)local a=math.abs(v)local d=math.floor(a)local m=math.floor((a-d)*60)local s=((a-d)*60-m)*60 return string.format("[%s %02d %02d' %05.2f\"]",h,d,m,s)end
				local ddmStr = ddm(lat,lat>=0 and 'N' or 'S')..'⇢ '..ddm(lon,lon>=0 and 'E' or 'W')
				local dmsStr = dms(lat,lat>=0 and 'N' or 'S')..'⇢ '..dms(lon,lon>=0 and 'E' or 'W')
				local mgrs = c:ToStringMGRS():gsub("^MGRS%s*","")
				toprint = toprint..'\nDDM:  '..ddmStr
				toprint = toprint..'\nDMS:  '..dmsStr
				toprint = toprint..'\nMGRS: '..mgrs
				toprint = toprint..'\n\nAlt: '..math.floor(alt)..'m | '..math.floor(alt*3.280839895)..'ft'
			else
				makeitlast = false
				toprint = 'No Target'
			end
		else
			makeitlast = false
			toprint = 'No target'
		end
		local gr = Group.getByName(self.name)
		if makeitlast then
			trigger.action.outTextForCoalition(gr:getCoalition(), toprint, 60, true)
		else
			trigger.action.outTextForCoalition(gr:getCoalition(), toprint, 10)
		end
	end

	
	function SelfJtac:markWithSmoke()
		if self.target then
			local tgtunit = Unit.getByName(self.target) or StaticObject.getByName(self.target)
			if tgtunit and tgtunit:isExist() and (not tgtunit.isActive or tgtunit:isActive()) and tgtunit:getLife()>=1 then
				local pnt = tgtunit:getPoint()
				trigger.action.smoke(pnt, trigger.smokeColor.Blue)
				trigger.action.outTextForGroup(self.groupID, "Marking with blue Smoke", 10)
			else
				trigger.action.outTextForGroup(self.groupID, "Invalid Objetive", 10)
			end
		else
			trigger.action.outTextForGroup(self.groupID, "No objetive", 10)
		end
	end

	function SelfJtac:clearTarget()
		self.target = nil
        self.prevPnt = nil
		self.targetList = {}
	
		if self.lasers.tgt then
			self.lasers.tgt:destroy()
			self.lasers.tgt = nil
		end
		
		if self.lasers.ir then
			self.lasers.ir:destroy()
			self.lasers.ir = nil
		end
		self:buildSelectTargetMenu()
	end

	function SelfJtac:updateTarget()
		local player = Group.getByName(self.name)
		if not player or player:getSize() == 0 then
			self:clearTarget()
			return
		end
		if self.target then
			local un = Unit.getByName(self.target)
			if un and un:isExist() then
				if un:getLife() >= 1 then
					self:setTarget(un)
					self:buildSelectTargetMenu()
				else
				self:clearTarget()
				if self.autoNext then
					self:searchTarget(true)
					if #self.targetList > 0 then
						for _,obj in ipairs(self.targetList) do
							if obj and obj:isExist() and obj:getLife()>=1 then
								self:setTarget(obj)
								trigger.action.outTextForGroup(self.groupID,'Kill confirmed',5)
								timer.scheduleFunction(function()
								self:printTarget(true)
								end, {}, timer.getTime() + 5)
								break
							end
						end
					end
				else
					trigger.action.outTextForGroup(self.groupID,'Kill confirmed. Stoping laser',10)
				end
			end
		else
			self:clearTarget()
				if self.autoNext then
					self:searchTarget(true)
					if #self.targetList > 0 then
						for _,obj in ipairs(self.targetList) do
							if obj and obj:isExist() and obj:getLife()>=1 then
								self:setTarget(obj)
								trigger.action.outTextForGroup(self.groupID,'Kill confirmed',5)
								timer.scheduleFunction(function()
								self:printTarget(true)
								end, {}, timer.getTime() + 5)
								break
							end
						end
					end
				else
					trigger.action.outTextForGroup(self.groupID,'Kill confirmed. Stoping laser',10)
				end
			end
		end
	end


	function SelfJtac.getBearing(fromvec, tovec)
		local fx = fromvec.x
		local fy = fromvec.z
		
		local tx = tovec.x
		local ty = tovec.z
		
		local brg = math.atan2(ty - fy, tx - fx)
		
		
		if brg < 0 then
			 brg = brg + 2 * math.pi
		end
		
		brg = brg * 180 / math.pi
		

		return brg
	end

    function SelfJtac.getPointOnSurface(point)
		return {x = point.x, y = land.getHeight({x = point.x, y = point.z}), z= point.z}
	end

	function SelfJtac.getHeadingDiff(heading1, heading2) -- heading1 + result == heading2
		local diff = heading1 - heading2
		local absDiff = math.abs(diff)
		local complementaryAngle = 360 - absDiff
	
		if absDiff <= 180 then 
			return -diff
		elseif heading1 > heading2 then
			return complementaryAngle
		else
			return -complementaryAngle
		end
	end

    function SelfJtac.getDist(point1, point2)
        local vec = {x = point1.x - point2.x, y = point1.y - point2.y, z = point1.z - point2.z}
        return (vec.x^2 + vec.y^2 + vec.z^2)^0.5
    end
	
		function SelfJtac:searchTarget(silent)
			local gr = Group.getByName(self.name)
			if not gr or not gr:isExist() then
				if self.autoTimer then           -- cancel 30-s scheduler
					timer.removeFunction(self.autoTimer)
					self.autoTimer = nil
				end
				return
			end
			local un = gr:getUnit(1)
			if not un then
				self:clearTarget()
				if self.autoTimer then
					timer.removeFunction(self.autoTimer)
					self.autoTimer = nil
				end
				return
			end
            local stats = SelfJtac.getAircraftStats(un:getDesc().typeName)

            local ppos = un:getPoint()
            local volume = {
                id = world.VolumeType.SPHERE,
                params = {
                    point = {x = ppos.x, z = ppos.z, y = land.getHeight({x = ppos.x, y = ppos.z})},
                    radius = stats.minDist * 1000
                }
            }

            local targets = {}
            world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, volume, function(unit, collection)
                if unit and unit:isExist() and (not unit.isActive or unit:isActive()) then
                    collection[unit:getName()] = unit
                end
                return true
            end, targets)

            local viabletgts = {}
            for i, v in pairs(targets) do
                if v and v:isExist() and v:getLife() >= 1 and i ~= un:getName() and v:getCoalition() ~= un:getCoalition() then
                    local unitPos = un:getPosition()
                    local unitheading = math.deg(math.atan2(unitPos.x.z, unitPos.x.x))
                    local bearing = SelfJtac.getBearing(un:getPoint(), v:getPoint())
                    local deviation = math.abs(SelfJtac.getHeadingDiff(unitheading, bearing))
                    local unitDistance = SelfJtac.getDist(un:getPoint(), v:getPoint())

                    if unitDistance <= (stats.minDist * 1000) and deviation <= stats.maxDeviation then
                        local from = un:getPoint()
                        from.y = from.y + 1.5
                        local to = v:getPoint()
                        to.y = to.y + 1.5
                        if land.isVisible(from, to) then
                            table.insert(viabletgts, v)
                        end
                    end
                end
            end

            if self.priority then
                local priorityTargets = {}
                for _, v in ipairs(viabletgts) do
                    for _, v2 in ipairs(self.priority) do
                        if v2 == "StaticObjects" and Object.getCategory(v) == Object.Category.STATIC then
                            table.insert(priorityTargets, v)
                            break
                        elseif v:hasAttribute(v2) and v:getLife() >= 1 then
                            table.insert(priorityTargets, v)
                            break
                        end
                    end
                end
                if #priorityTargets > 0 then
                    viabletgts = priorityTargets
                else
                    trigger.action.outTextForGroup(self.groupID, 'No priority targets found, searching for anything...', 10)
                end
            end

		self.targetList = viabletgts

		if self.target then
			if #viabletgts == 0 then
				self:clearTarget()
				if not silent then
					trigger.action.outTextForGroup(self.groupID,'Target lost',5)
				end
			end
		else
			if #viabletgts > 0 then
				self:setTarget(viabletgts[1])
				self:printTarget(true)
			elseif not silent then
				trigger.action.outTextForGroup(self.groupID,'No targets found',10)
			end
		end

		self:buildSelectTargetMenu()
	end

	function SelfJtac:sortByThreat(targets)
		local threatRank = {
			['SAM TR']          = 1,
			['IR Guided SAM']   = 2,
			['SAM SR']          = 3,
			['Tanks']           = 4,
			['IFV']             = 5,
			['APC']             = 6,
			['Artillery']       = 7,
			['SAM LL']          = 8,
			['SAM CC']          = 9,
			['Unarmed vehicles']= 10,
			['Infantry']        = 11,
			['Structures']   	= 12
		}

		local function getScore(u)
			local best = 999
			for attr, rank in pairs(threatRank) do
				if u:hasAttribute(attr) and rank < best then
					best = rank
				end
			end
			return best
		end

		table.sort(targets, function(a,b) return getScore(a) < getScore(b) end)
		return targets
	end

	function SelfJtac:buildSelectTargetMenu()
		if not self.jtacMenu then return end
		if not self.selectTargetMenu then
			self.selectTargetMenu = missionCommands.addSubMenuForGroup(self.groupID,'Select Target',self.jtacMenu)
			self._cmdIds = {}
			self._moreMenus = {}
		end
		for _,id in ipairs(self._cmdIds or {}) do missionCommands.removeItemForGroup(self.groupID,id) end
		for _,m in ipairs(self._moreMenus or {}) do missionCommands.removeItemForGroup(self.groupID,m) end
		self._cmdIds = {}
		self._moreMenus = {}
		local tgtlist = self.targetList or {}
		if #tgtlist == 0 then
			table.insert(self._cmdIds,missionCommands.addCommandForGroup(self.groupID,'No valid targets',self.selectTargetMenu,function() end))
			return
		end
		if self.sortByThreat then tgtlist = self:sortByThreat(tgtlist) end
		local sub = nil
		for i,obj in ipairs(tgtlist) do
			if obj and obj:isExist() and (not obj.isActive or obj:isActive()) and obj:getLife()>=1 then
				local label
				if Object.getCategory(obj)==Object.Category.STATIC then
					label='('..i..') '..(obj:getName() or 'Unknown')
				else
					label='('..i..') '..renameType(obj:getTypeName())
				end
				if self.target==obj:getName() then label=label..' (Lasing)' end
				local cb=function()
					self:setTarget(obj)
					self:printTarget(true)
					self:buildSelectTargetMenu()
				end
				local id
				if i<10 then
					id=missionCommands.addCommandForGroup(self.groupID,label,self.selectTargetMenu,cb)
				elseif i==10 then
					sub=missionCommands.addSubMenuForGroup(self.groupID,'More',self.selectTargetMenu)
					table.insert(self._moreMenus,sub)
					id=missionCommands.addCommandForGroup(self.groupID,label,sub,cb)
				elseif (i-10)%9==0 then
					sub=missionCommands.addSubMenuForGroup(self.groupID,'More',sub)
					table.insert(self._moreMenus,sub)
					id=missionCommands.addCommandForGroup(self.groupID,label,sub,cb)
				else
					id=missionCommands.addCommandForGroup(self.groupID,label,sub,cb)
				end
				table.insert(self._cmdIds,id)
			end
		end
	end


    function SelfJtac.getAircraftStats(aircraftType)
        local stats = SelfJtac.aircraftStats[aircraftType]
        if not stats then
            return
        end

        return stats
    end

    SelfJtac.aircraftStats = {
        ['SA342L'] =        { minDist = 10, maxDeviation = 120, laserOffset = { x = 1.4, y = 1.1, z = -0.35 }  },
        ['SA342M'] =        { minDist = 15, maxDeviation = 120, laserOffset =  { x = 1.4, y = 1.23, z = -0.35 }   },
        ['UH-60L'] =        { minDist = 8,  maxDeviation = 45,  laserOffset = { x = 4.65, y = -1.8, z = 0 }   },
        ['UH-60L_DAP'] =     { minDist = 8,  maxDeviation = 45,  laserOffset = { x = 4.65, y = -1.8, z = 0 }   },
        ['OH-6A']  =        { minDist = 8,  maxDeviation = 45,  laserOffset = { x = 1.35, y = 0.1, z = 0 }   },
		['Bronco-OV-10A'] = { minDist = 30,  maxDeviation = 160,  laserOffset = { x = 1.01, y = 0.1, z = 0 }   },		
		['F-4E-45MC'] =     { minDist = 30,  maxDeviation = 160,  laserOffset = { x = 1.01, y = 0.1, z = 0 }   },
		['F-15ESE'] =       { minDist = 40,  maxDeviation = 160,  laserOffset = { x = 1.01, y = 0.1, z = 0 }   },
    }

    SelfJtac.jtacs = {}
end



LogisticCommander = {}
do
	LogisticCommander.allowedTypes = {}
	LogisticCommander.allowedTypes['Ka-50'] = true
	LogisticCommander.allowedTypes['Ka-50_3'] = true
	LogisticCommander.allowedTypes['Mi-24P'] = true
	LogisticCommander.allowedTypes['SA342Mistral'] = true
	LogisticCommander.allowedTypes['SA342L'] = true
	LogisticCommander.allowedTypes['SA342M'] = true
	LogisticCommander.allowedTypes['SA342Minigun'] = true
	LogisticCommander.allowedTypes['UH-60L'] = true
	LogisticCommander.allowedTypes['UH-60L_DAP'] = true
	LogisticCommander.allowedTypes['AH-64D_BLK_II'] = true
	LogisticCommander.allowedTypes['UH-1H'] = true
	LogisticCommander.allowedTypes['Mi-8MT'] = true
	LogisticCommander.allowedTypes['Hercules'] = true
	LogisticCommander.allowedTypes['OH58D'] = true
	LogisticCommander.allowedTypes['CH-47Fbl1'] = true
	LogisticCommander.allowedTypes['Bronco-OV-10A'] = true
	LogisticCommander.allowedTypes['OH-6A'] = true
	
	LogisticCommander.maxCarriedPilots = 4
	
	--{ battleCommander = object, supplyZones = { 'zone1', 'zone2'...}}
	function LogisticCommander:new(obj)
		obj = obj or {}
		obj.groupMenus = {} -- groupid = path
		obj.statsMenus = {}
		obj.carriedCargo = {} -- groupid = source
		obj.ejectedPilots = {}
		obj.carriedPilots = {} -- groupid = count
		obj.carriedPilotData = {}
		
		setmetatable(obj, self)
		self.__index = self
		return obj
	end
end



	function LogisticCommander:loadSupplies(groupName)
	local gr = Group.getByName(groupName)
	if gr then
		local un = gr:getUnit(1)
		if un then
			if Utils.isInAir(un) then
				trigger.action.outTextForGroup(gr:getID(), 'Cannot load supplies while in air', 10)
				return
			end
            local zn = self.battleCommander:getZoneOfUnit(un:getName())
            if not zn then
                local carrierUnit
                local nearestCarrier = GetNearestCarrierName(COORDINATE:NewFromVec3(un:getPoint()))
                if nearestCarrier then
                    carrierUnit = Unit.getByName(nearestCarrier)
                end

                if carrierUnit then
                    local carrierPos  = carrierUnit:getPoint()
                    local playerPos   = un:getPoint()
                    if COORDINATE:NewFromVec3(carrierPos):Get2DDistance(playerPos) < 200 then
                        self.carriedCargo[gr:getID()] = carrierUnit:getName()
                        trigger.action.setUnitInternalCargo(un:getName(),100)
                        trigger.action.outTextForGroup(gr:getID(),'Supplies loaded from the carrier',20)
                        return
                    end
                else
					local group = GROUP:FindByName(groupName)
					if group then
						for _, zName in ipairs(self.supplyZones) do
							if string.find(zName, "CTLD FARP") or string.find(zName, "Escort Mission FARP") then
								local zObj = ZONE:FindByName(zName)
								if zObj and group:IsInZone(zObj) then
									self.carriedCargo[gr:getID()] = zName
									trigger.action.setUnitInternalCargo(un:getName(), 100)
									trigger.action.outTextForGroup(gr:getID(), 'Supplies loaded', 20)
									return
								end
							end
						end
					end
				end
				trigger.action.outTextForGroup(gr:getID(), 'Can only load supplies while within a friendly supply zone or on the carrier', 10)
				return
			end
			if zn.side ~= un:getCoalition() and not zn.wasBlue then
				trigger.action.outTextForGroup(gr:getID(), 'Can only load supplies while within a friendly supply zone', 10)
				return
			end
			if self.carriedCargo[gr:getID()] then
				if type(self.carriedCargo[gr:getID()]) == "string" and self.carriedCargo[gr:getID()] == "CVN-72" then
					trigger.action.outTextForGroup(gr:getID(), 'Supplies already loaded from the carrier', 10)
				else
					trigger.action.outTextForGroup(gr:getID(), 'Supplies already loaded', 10)
				end
				return
			end
			for i, v in ipairs(self.supplyZones) do
				if v == zn.zone then
					self.carriedCargo[gr:getID()] = zn.zone
					trigger.action.setUnitInternalCargo(un:getName(), 100)
					trigger.action.outTextForGroup(gr:getID(), 'Supplies loaded', 20)
					return
				end
			end
			trigger.action.outTextForGroup(gr:getID(), 'Can only load supplies while within a friendly supply zone', 10)
			return
		end
	end
end

	function LogisticCommander:unloadSupplies(groupName)
		local gr = Group.getByName(groupName)
		if gr then
			local un = gr:getUnit(1)
			if un then
				if Utils.isInAir(un) then
					trigger.action.outTextForGroup(gr:getID(), 'Can not unload supplies while in air', 10)
					return
				end
				
                local zn = self.battleCommander:getZoneOfUnit(un:getName())
                if not zn then
                    local carrierName = GetNearestCarrierName(COORDINATE:NewFromVec3(un:getPoint()))
                    if carrierName then
                        if not self.carriedCargo[gr:getID()] then
                            trigger.action.outTextForGroup(gr:getID(),'No supplies loaded',10)
                            return
                        end
                        self.carriedCargo[gr:getID()] = nil
                        trigger.action.setUnitInternalCargo(un:getName(),0)
                        trigger.action.outTextForGroup(gr:getID(),'Supplies unloaded',10)
                        return
                    end

                    local group = GROUP:FindByName(groupName)
                    if group then
                        for _, zName in ipairs(self.supplyZones) do
                            if string.find(zName, "CTLD FARP") or string.find(zName, "Escort Mission FARP") then
                                local zObj = ZONE:FindByName(zName)
                                if zObj and group:IsInZone(zObj) then
                                    if not self.carriedCargo[gr:getID()] then
                                        trigger.action.outTextForGroup(gr:getID(),'No supplies loaded',10)
                                        return
                                    end
                                    self.carriedCargo[gr:getID()] = nil
                                    trigger.action.setUnitInternalCargo(un:getName(),0)
                                    trigger.action.outTextForGroup(gr:getID(),'Supplies unloaded',10)
                                    return
                                end
                            end
                        end
                    end

                    trigger.action.outTextForGroup(gr:getID(),'Can only unload supplies while within a friendly or neutral zone',10)
                    return
                end
                if not (zn.side == un:getCoalition() or zn.side == 0) then
                    trigger.action.outTextForGroup(gr:getID(),'Can only unload supplies while within a friendly or neutral zone',10)
                    return
                end
                if not self.carriedCargo[gr:getID()] then
                    trigger.action.outTextForGroup(gr:getID(),'No supplies loaded',10)
                    return
                end
				
				trigger.action.outTextForGroup(gr:getID(), 'Supplies unloaded', 10)
				if self.carriedCargo[gr:getID()] ~= zn.zone then
					if zn.side == 0 and zn.active then 
						if self.battleCommander.playerRewardsOn then
							self.battleCommander:addFunds(un:getCoalition(), self.battleCommander.rewards.crate)
							trigger.action.outTextForCoalition(un:getCoalition(),'Capture +'..self.battleCommander.rewards.crate..' credits',10)
						end
							zn:capture(un:getCoalition())
						SCHEDULER:New(nil,function()
							if zn.wasBlue and un:isExist() then
							local landingEvent = {
								id = world.event.S_EVENT_LAND,
								time = timer.getAbsTime(),
								initiator = un,
								initiatorPilotName = un:getPlayerName(),
								initiator_unit_type = un:getTypeName(),
								initiator_coalition = un:getCoalition(),
							}
							
								world.onEvent(landingEvent)
							end
						end,{},5,0)
					elseif zn.side == un:getCoalition() then
						if self.battleCommander.playerRewardsOn then
							if zn:canRecieveSupply() then
								self.battleCommander:addFunds(un:getCoalition(), self.battleCommander.rewards.crate)
								trigger.action.outTextForCoalition(un:getCoalition(),'Resupply +'..self.battleCommander.rewards.crate..' credits',5)
							else
								local reward = self.battleCommander.rewards.crate * 0.25
								self.battleCommander:addFunds(un:getCoalition(), reward)
								trigger.action.outTextForCoalition(un:getCoalition(),'Resupply +'..reward..' credits (-75% due to no demand)',5)
							end
						end
						
						zn:upgrade()
					end
				end
				
				self.carriedCargo[gr:getID()] = nil
				trigger.action.setUnitInternalCargo(un:getName(), 0)
				return
			end
		end
	end
	

	
	function LogisticCommander:listSupplyZones(groupName)
		local gr = Group.getByName(groupName)
		if gr then
			local msg = 'Friendly supply zones:'
			for i,v in ipairs(self.supplyZones) do
				local z = self.battleCommander:getZoneByName(v)
				if z and z.side == gr:getCoalition() then
					msg = msg..'\n'..v
				end
			end
			
			trigger.action.outTextForGroup(gr:getID(), msg, 15)
		end
	end

	function LogisticCommander:loadPilot(groupname)
		local gr=Group.getByName(groupname)
		local groupid=gr:getID()
		if gr then
			local un=gr:getUnit(1)
			if Utils.getAGL(un)>50 then
				trigger.action.outTextForGroup(groupid,"You are too high",15)
				return
			end
			if UTILS.VecNorm(un:getVelocity()) > 5 then
				trigger.action.outTextForGroup(groupid,"You are moving too fast",15)
				return
			end
			if self.carriedPilots[groupid]>=LogisticCommander.maxCarriedPilots then
				trigger.action.outTextForGroup(groupid,"At max capacity",15)
				return
			end
			for i,v in ipairs(self.ejectedPilots)do
				local dist=UTILS.VecDist3D(un:getPoint(),v:getPoint())
				if dist<150 then
					self.carriedPilots[groupid]=self.carriedPilots[groupid]+1
					self.carriedPilotData=self.carriedPilotData or {}
					self.carriedPilotData[groupid]=self.carriedPilotData[groupid] or {}
					local pid=v:getObjectID()
					local pilotData=landedPilotOwners[pid]
					if pilotData then
						table.insert(self.carriedPilotData[groupid],pilotData)
						landedPilotOwners[pid]=nil
					end
					table.remove(self.ejectedPilots,i)
					v:destroy()
					trigger.action.outTextForGroup(groupid,"Pilot onboard ["..self.carriedPilots[groupid].."/"..LogisticCommander.maxCarriedPilots.."]",15)
					return
				end
			end
			trigger.action.outTextForGroup(groupid,"No ejected pilots nearby",15)
		end
	end
function LogisticCommander:unloadPilot(groupname)
		local gr=Group.getByName(groupname)
		local groupid=gr:getID()
		if gr then
			local un=gr:getUnit(1)
			if self.carriedPilots[groupid]==0 then
				trigger.action.outTextForGroup(groupid,"No one onboard",15)
				return
			end
			if Utils.isInAir(un) then
				trigger.action.outTextForGroup(groupid,"Can not drop off pilots while in air",15)
				return
			end

			local zn=self.battleCommander:getZoneOfUnit(un:getName())
			local friendly=false
			if zn and (zn.active and zn.side==gr:getCoalition() or zn.wasBlue) then
				friendly=true
			else
				for _,zName in ipairs(self.supplyZones) do
					if string.find(zName, "CTLD FARP") or string.find(zName, "Escort Mission FARP") then
						local zObj=ZONE:FindByName(zName)
						if zObj and GROUP:FindByName(groupname):IsInZone(zObj) then
							friendly=true
							break
						end
					end
				end
			end

			if friendly then
				local count=self.carriedPilots[groupid]
				trigger.action.outTextForGroup(groupid,"Pilots dropped off",15)
				if self.battleCommander.playerRewardsOn then
					self.battleCommander:addFunds(un:getCoalition(),self.battleCommander.rewards.rescue*count)
					trigger.action.outTextForCoalition(un:getCoalition(),count.." pilots were rescued. +"..self.battleCommander.rewards.rescue*count.." credits",5)
					local rescuedPlayers=self.carriedPilotData[groupid] or {}
					for _,pilotData in ipairs(rescuedPlayers) do
						local pname=pilotData.player
						local restoreAmount=pilotData.lostCredits
						self.battleCommander:addFunds(un:getCoalition(),restoreAmount)
						self.battleCommander:addStat(pname,"Points",restoreAmount)
						trigger.action.outTextForCoalition(un:getCoalition(),"["..pname.."] recovered. +"..restoreAmount.." credits restored.",5)
					end
					self.carriedPilotData[groupid]=nil
				end
				self.carriedPilots[groupid]=0
				return
			end

			trigger.action.outTextForGroup(groupid,"Can only drop off pilots in a friendly zone",15)
		end
	end

	function LogisticCommander:markPilot(groupname)
		local gr = Group.getByName(groupname)
		if gr then
			local un = gr:getUnit(1)
			
			local maxdist = 300000
			local targetpilot = nil
			for i, v in ipairs(self.ejectedPilots) do
				local dist = UTILS.VecDist3D(un:getPoint(), v:getPoint())
				if dist < maxdist then
					maxdist = dist
					targetpilot = v
				end
			end
			
			if targetpilot then
				trigger.action.smoke(targetpilot:getPoint(), 4)
				trigger.action.outTextForGroup(gr:getID(), 'Ejected pilot has been marked with blue smoke', 15)
			else
				trigger.action.outTextForGroup(gr:getID(), 'No ejected pilots nearby', 15)
			end
		end
	end
	
	function LogisticCommander:flarePilot(groupname)
		local gr = Group.getByName(groupname)
		if gr then
			local un = gr:getUnit(1)
			
			local maxdist = 300000
			local targetpilot = nil
			for i,v in ipairs(self.ejectedPilots) do
				local dist = UTILS.VecDist3D(un:getPoint(), v:getPoint())
				if dist<maxdist then
					maxdist = dist
					targetpilot = v
				end
			end
			
			if targetpilot then
				trigger.action.signalFlare(targetpilot:getPoint(), 0, math.floor(math.random(0,359)))
			else
				trigger.action.outTextForGroup(gr:getID(), 'No ejected pilots nearby', 15)
			end
		end
	end
	
	function LogisticCommander:infoPilot(groupname)
		local gr = Group.getByName(groupname)
		if gr then
			local un = gr:getUnit(1)
			
			local maxdist = 300000
			local targetpilot = nil
			for i,v in ipairs(self.ejectedPilots) do
				local dist = UTILS.VecDist3D(un:getPoint(), v:getPoint())
				if dist<maxdist then
					maxdist = dist
					targetpilot = v
				end
			end
			
			if targetpilot then
				self:printPilotInfo(targetpilot, gr:getID(), un, 60)
			else
				trigger.action.outTextForGroup(gr:getID(), 'No ejected pilots nearby', 15)
			end
		end
	end
	
		function LogisticCommander:infoHumanPilot(groupname)
		local gr = Group.getByName(groupname)
		if not gr then return end
		local un = gr:getUnit(1)
		if not un or not un:isExist() then return end
		local maxdist = 300000
		local targetpilot = nil
		for i,ejectedObj in ipairs(self.ejectedPilots) do
			local pid = ejectedObj:getObjectID()
			local pilotData = landedPilotOwners[pid] or ejectedPilotOwners[pid]
			if pilotData and pilotData.player then
				local dist = UTILS.VecDist3D(un:getPoint(), ejectedObj:getPoint())
				if dist < maxdist then
					maxdist = dist
					targetpilot = ejectedObj
				end
			end
		end
		if targetpilot then
			self:printPilotInfo(targetpilot, gr:getID(), un, 60)
		else
			trigger.action.outTextForGroup(gr:getID(), 'No ejected friendly pilots nearby', 15)
		end
	end
	
	function LogisticCommander:printPilotInfo(pilotObj,groupid,referenceUnit,duration)
		local pnt=pilotObj:getPoint()
		local toprint='Pilot in need of extraction:'
		local objectID=pilotObj:getObjectID()
		local pilotData=landedPilotOwners[objectID]
		if (pilotData and pilotData.player) then		

			toprint = toprint .. '\n\n[' .. pilotData.player .. '] '
			toprint = toprint .. ' Lost: ' .. pilotData.lostCredits .. ' Credits'
			toprint = toprint .. '\n\nSave the pilot to retrive the lost credits'
		end
	local c=COORDINATE:NewFromVec3(pnt)
	local ddm=c:ToStringLLDDM():gsub("^LL DDM%s*","")
	local dms=c:ToStringLLDMS():gsub("^LL DMS%s*","")
	local mgrs=c:ToStringMGRS():gsub("^MGRS%s*","")
	local alt=c:GetLandHeight()
	toprint=toprint..'\n\nDDM:  '..ddm
	toprint=toprint..'\nDMS:  '..dms
	toprint=toprint..'\nMGRS: '..mgrs
	toprint=toprint..'\n\nAlt: '..math.floor(alt)..'m | '..math.floor(alt*3.280839895)..'ft'
	if referenceUnit then
		local dist=UTILS.VecDist3D(referenceUnit:getPoint(),pilotObj:getPoint())
		local dstkm=string.format('%.2f',dist/1000)
		local dstnm=string.format('%.2f',dist/1852)
		toprint=toprint..'\n\nDist: '..dstkm..'km | '..dstnm..'nm'
		local brg=COORDINATE:NewFromVec3(referenceUnit:getPoint()):HeadingTo(c)
		toprint=toprint..'\nBearing: '..math.floor(brg)
	end
	trigger.action.outTextForGroup(groupid,toprint,duration)
	end

	function LogisticCommander:update()
		local tocleanup = {}

		for i, v in ipairs(self.ejectedPilots) do
			if v and v:isExist() then
				for _, v2 in ipairs(self.battleCommander.zones) do
					if v2.active and v2.side ~= 0 and Utils.isInZone(v, v2.zone) then
						table.insert(tocleanup, i)
						break
					end
				end
			else
				table.insert(tocleanup, i)
			end
		end

		for i = #tocleanup, 1, -1 do
			local index = tocleanup[i]
			local pilot = self.ejectedPilots[index]

			if pilot and pilot:isExist() then
				pilot:destroy()
				landedPilotOwners[pilot:getName()]=nil
			end

			table.remove(self.ejectedPilots, index)
		end
	end


function LogisticCommander:init()
    local ev = {}
    ev.context = self
    function ev:onEvent(event)
        if event.id == 15 and event.initiator and event.initiator.getPlayerName then
            local player = event.initiator:getPlayerName()
            if player then
                local groupObj = event.initiator:getGroup()
                local groupid = groupObj:getID()
                local groupname = groupObj:getName()
                local unitType = event.initiator:getDesc()['typeName']
				self.context.battleCommander.playerNames = self.context.battleCommander.playerNames or {}
                self.context.battleCommander.playerNames[groupid] = player
				self.context.battleCommander:refreshShopMenuForGroup(groupid, groupObj)


                if self.context.statsMenus[groupid] then
                    missionCommands.removeItemForGroup(groupid, self.context.statsMenus[groupid])
                    self.context.statsMenus[groupid] = nil
                end

                local statsMenu = missionCommands.addSubMenuForGroup(groupid, 'Stats and Budget')
                local statsSubMenu = missionCommands.addSubMenuForGroup(groupid, 'Stats', statsMenu)
                missionCommands.addCommandForGroup(groupid, 'My Stats', statsSubMenu, self.context.battleCommander.printMyStats, self.context.battleCommander, event.initiator:getID(), player)
                missionCommands.addCommandForGroup(groupid, 'All Stats', statsSubMenu, self.context.battleCommander.printStats, self.context.battleCommander, event.initiator:getID())
                missionCommands.addCommandForGroup(groupid, 'Top 5 Players', statsSubMenu, self.context.battleCommander.printStats, self.context.battleCommander, event.initiator:getID(), 5)
				missionCommands.addCommandForGroup(groupid, 'Top 5 Today', statsSubMenu, self.context.battleCommander.printDailyTop, self.context.battleCommander, event.initiator:getID(), 5)
				missionCommands.addCommandForGroup(groupid, 'Budget Overview', statsMenu, self.context.battleCommander.printShopStatus, self.context.battleCommander, groupid, event.initiator:getCoalition())

                self.context.statsMenus[groupid] = statsMenu

                if self.context.allowedTypes[unitType] then
                    self.context.carriedCargo[groupid] = 0
                    self.context.carriedPilots[groupid] = 0

                    if self.context.groupMenus[groupid] then
                        missionCommands.removeItemForGroup(groupid, self.context.groupMenus[groupid])
                        self.context.groupMenus[groupid] = nil
                    end

                    local cargomenu = missionCommands.addSubMenuForGroup(groupid, 'Logistics')
                    missionCommands.addCommandForGroup(groupid, 'Load supplies', cargomenu, self.context.loadSupplies, self.context, groupname)
                    missionCommands.addCommandForGroup(groupid, 'Unload supplies', cargomenu, self.context.unloadSupplies, self.context, groupname)
                    missionCommands.addCommandForGroup(groupid, 'List supply zones', cargomenu, self.context.listSupplyZones, self.context, groupname)
                    missionCommands.addCommandForGroup(groupid, 'Supplies Status', cargomenu, self.context.checkSuppliesStatus, self.context, groupid)

                    local csar = missionCommands.addSubMenuForGroup(groupid, 'CSAR', cargomenu)
                    missionCommands.addCommandForGroup(groupid, 'Pick up pilot', csar, self.context.loadPilot, self.context, groupname)
                    missionCommands.addCommandForGroup(groupid, 'Drop off pilot', csar, self.context.unloadPilot, self.context, groupname)
                    missionCommands.addCommandForGroup(groupid, 'Info on closest pilot', csar, self.context.infoPilot, self.context, groupname)
                    missionCommands.addCommandForGroup(groupid, 'Info on closest pilot with credits', csar, self.context.infoHumanPilot, self.context, groupname)
                    missionCommands.addCommandForGroup(groupid, 'Deploy smoke at closest pilot', csar, self.context.markPilot, self.context, groupname)
                    missionCommands.addCommandForGroup(groupid, 'Deploy flare at closest pilot', csar, self.context.flarePilot, self.context, groupname)

                    local main = missionCommands.addSubMenuForGroup(groupid, 'Mark Zone', cargomenu)
                    local sub1
                    for i, v in ipairs(self.context.battleCommander.zones) do
                        if i < 10 then
                            missionCommands.addCommandForGroup(groupid, v.zone, main, v.markWithSmoke, v, event.initiator:getCoalition())
                        elseif i == 10 then
                            sub1 = missionCommands.addSubMenuForGroup(groupid, "More", main)
                            missionCommands.addCommandForGroup(groupid, v.zone, sub1, v.markWithSmoke, v, event.initiator:getCoalition())
                        elseif i % 9 == 1 then
                            sub1 = missionCommands.addSubMenuForGroup(groupid, "More", sub1)
                            missionCommands.addCommandForGroup(groupid, v.zone, sub1, v.markWithSmoke, v, event.initiator:getCoalition())
                        else
                            missionCommands.addCommandForGroup(groupid, v.zone, sub1, v.markWithSmoke, v, event.initiator:getCoalition())
                        end
                    end

                    self.context.groupMenus[groupid] = cargomenu
                end
                if self.context.carriedCargo[groupid] then
                    self.context.carriedCargo[groupid] = nil
                end
				local stats = SelfJtac.getAircraftStats(event.initiator:getDesc().typeName)
                if stats then
                    if SelfJtac.jtacs[groupid] then
                        local oldjtac = SelfJtac.jtacs[groupid]
                        oldjtac:clearTarget()
                        missionCommands.removeItemForGroup(groupid, oldjtac.jtacMenu)
                        SelfJtac.jtacs[groupid] = nil
                    end

                    if not SelfJtac.jtacs[groupid] then
                        local newjtac = SelfJtac:new({name = groupname})
                        newjtac:showMenu()
                        SelfJtac.jtacs[groupid] = newjtac
                    end
                end
			end
        end

        if event.id == world.event.S_EVENT_TAKEOFF
           and event.initiator and event.initiator.getPlayerName -- ADDED: Checking for getPlayerName
        then
            local groupid = event.initiator:getGroup():getID()
            local unitType = event.initiator:getDesc()['typeName']
            local player = event.initiator:getPlayerName()
            local un = event.initiator
            local zn = self.context.battleCommander:getZoneOfUnit(un:getName())

            if zn and (zn.side == un:getCoalition() or (un:getCoalition() == 2 and zn.wasBlue)) then
                for _, v in ipairs(self.context.supplyZones) do
                    if v == zn.zone then
                        if self.context.allowedTypes[unitType] and not self.context.carriedCargo[groupid] then
                            trigger.action.outTextForGroup(groupid, 'Warning: Supplies not loaded', 30,true)
                            if trigger.misc.getUserFlag(180) == 0 then
                                trigger.action.outSoundForGroup(groupid, "micclick.ogg")
                            end
                        end
                        return
                    end
                end
            end
        end

		if event.id==world.event.S_EVENT_LANDING_AFTER_EJECTION then
			local aircraftID=event.place and event.place.id_
			local coalitionSide = event.initiator:getCoalition()
			local pilotObjectID=event.initiator and event.initiator:getObjectID()
			local pilotData=ejectedPilotOwners[aircraftID]
			

			if coalitionSide == coalition.side.RED then
				event.initiator:destroy()
				return
			end

			if pilotData then
				landedPilotOwners[pilotObjectID]=pilotData
				ejectedPilotOwners[aircraftID]=nil
			end

			table.insert(self.context.ejectedPilots,event.initiator)
			for i in pairs(self.context.groupMenus) do
				self.context:printPilotInfo(event.initiator,i,nil,15)
			end
		end
    end
    world.addEventHandler(ev)
    SCHEDULER:New(nil,self.update,{self},10,10)
end


function LogisticCommander:checkSuppliesStatus(groupid)
	if self.carriedCargo[groupid] then
		trigger.action.outTextForGroup(groupid, 'Supplies loaded', 10)
	else
		trigger.action.outTextForGroup(groupid, 'Supplies not loaded', 10)
	end
end

HercCargoDropSupply = {}
do
	HercCargoDropSupply.allowedCargo = {}
	HercCargoDropSupply.allowedCargo['weapons.bombs.Generic Crate [20000lb]'] = true
	HercCargoDropSupply.herculesRegistry = {} -- {takeoffzone = string, lastlanded = time}

	HercCargoDropSupply.battleCommander = nil
	function HercCargoDropSupply.init(bc)
		HercCargoDropSupply.battleCommander = bc
		
		cargodropev = {}
		function cargodropev:onEvent(event)
			if event.id == world.event.S_EVENT_SHOT then
				local name = event.weapon:getDesc().typeName
				if HercCargoDropSupply.allowedCargo[name] then
					local alt = Utils.getAGL(event.weapon)
					if alt < 5 then
						HercCargoDropSupply.ProcessCargo(event)
					else
						timer.scheduleFunction(HercCargoDropSupply.CheckCargo, event, timer.getTime() + 0.1)
					end
				end
			end
			
			if event.id == world.event.S_EVENT_TAKEOFF then
				if event.initiator and event.initiator.getDesc then
					local desc = event.initiator:getDesc()
					if desc and desc.typeName == 'Hercules' then
						local herc = HercCargoDropSupply.herculesRegistry[event.initiator:getName()]
						local zn = HercCargoDropSupply.battleCommander:getZoneOfUnit(event.initiator:getName())
						if zn then
							if not herc then
								HercCargoDropSupply.herculesRegistry[event.initiator:getName()] = {takeoffzone = zn.zone}
							elseif not herc.lastlanded or (herc.lastlanded + 30) < timer.getTime() then
								HercCargoDropSupply.herculesRegistry[event.initiator:getName()].takeoffzone = zn.zone
							end
						end
					end
				end
			end
			
			if event.id == world.event.S_EVENT_LAND then
				if event.initiator then
					local desc = event.initiator:getDesc()
					if desc and desc.typeName == 'Hercules' then
						local herc = HercCargoDropSupply.herculesRegistry[event.initiator:getName()]
						
						if not herc then
							HercCargoDropSupply.herculesRegistry[event.initiator:getName()] = {}
						end
						
						HercCargoDropSupply.herculesRegistry[event.initiator:getName()].lastlanded = timer.getTime()
					end
				end
			end
		end
		
		world.addEventHandler(cargodropev)
	end

	function HercCargoDropSupply.ProcessCargo(shotevent)
		local cargo = shotevent.weapon
		local zn = HercCargoDropSupply.battleCommander:getZoneOfWeapon(cargo)
		if zn and zn.active and shotevent.initiator and shotevent.initiator:isExist() then
			local herc = HercCargoDropSupply.herculesRegistry[shotevent.initiator:getName()]
			if not herc or herc.takeoffzone == zn.zone then
				cargo:destroy()
				return
			end
			
			local cargoSide = cargo:getCoalition()
			if zn.side == 0 then
				if HercCargoDropSupply.battleCommander.playerRewardsOn then
					HercCargoDropSupply.battleCommander:addFunds(cargoSide, HercCargoDropSupply.battleCommander.rewards.crate)
					trigger.action.outTextForCoalition(cargoSide,'Capture +'..HercCargoDropSupply.battleCommander.rewards.crate..' credits',5)
				end
				
				zn:capture(cargoSide)
			elseif zn.side == cargoSide then
				if HercCargoDropSupply.battleCommander.playerRewardsOn then
					if zn:canRecieveSupply() then
						HercCargoDropSupply.battleCommander:addFunds(cargoSide, HercCargoDropSupply.battleCommander.rewards.crate)
						trigger.action.outTextForCoalition(cargoSide,'Resupply +'..HercCargoDropSupply.battleCommander.rewards.crate..' credits',5)
					else
						local reward = HercCargoDropSupply.battleCommander.rewards.crate * 0.25
						HercCargoDropSupply.battleCommander:addFunds(cargoSide, reward)
						trigger.action.outTextForCoalition(cargoSide,'Resupply +'..reward..' credits (-75% due to no demand)',5)
					end
				end
				
				zn:upgrade()
			end
			
			cargo:destroy()
		end
	end
	
	function HercCargoDropSupply.CheckCargo(shotevent, time)
		local cargo = shotevent.weapon
		if not cargo:isExist() then
			return nil
		end
		
		local alt = Utils.getAGL(cargo)
		if alt < 5 then
			HercCargoDropSupply.ProcessCargo(shotevent)
			return nil
		end
		return time+0.1
	end
end
MissionCommander = {}
do
    function MissionCommander:new(obj)
        obj = obj or {}
        obj.missions = {}
        obj.missionsType = {}
        obj.missionFlags = {}
        if obj.checkFrequency then
            obj.checkFrequency = 15
        end
        setmetatable(obj, self)
        self.__index = self
        return obj
    end

	function MissionCommander:printMissions(groupId)
		local output = 'Active Missions'
		output = output .. '\n------------------------------------------------'

		for _, v in ipairs(self.missions) do
			if v.isRunning then
				output = output .. '\n[' .. self:decodeMessage(v.title) .. ']'
				output = output .. '\n' .. self:decodeMessage(v.description)
				output = output .. '\n------------------------------------------------'
			end
		end

		local hasAvailableEscortMissions = false
		for _, v in ipairs(self.missions) do
			if v.isEscortMission and not v.isRunning and not v.accept and v:isActive() and not v.denied then 
				hasAvailableEscortMissions = true
				break
			end
		end

		if self.escortMissionGenerated and hasAvailableEscortMissions then
			output = output .. '\nAvailable Missions'
			output = output .. '\n------------------------------------------------'
			for _, v in ipairs(self.missions) do
				if v.isEscortMission and not v.isRunning and not v.accept and v:isActive() then
					output = output .. '\n[' .. self:decodeMessage(v.MainTitle) .. ']'
					output = output .. '\n' .. self:decodeMessage(v.description)
					output = output .. '\n------------------------------------------------'
				end
			end
		end
	  if groupId then
		trigger.action.outTextForGroup(groupId, output, 30)
	  else
		trigger.action.outTextForCoalition(2, output, 10)
	  end
	end
	function MissionCommander:trackMission(params)

		if params.isEscortMission and params.zoneName then
			for _, existing in ipairs(self.missions) do
				if existing.isEscortMission and existing.zoneName == params.zoneName then
					return
				end
			end
		end
		params.isRunning = false
		params.accept = false
		params.notified = false
		table.insert(self.missions, params)
	end

	function MissionCommander:checkMissions(time)
		for i, v in ipairs(self.missions) do
			if v.isRunning then
				if v.missionFail and v:isActive() and v:missionFail() then
					v.isRunning = false
					table.remove(self.missions, i)
				if v.startOver then v:startOver() end
				elseif not v:isActive() then
					if v.messageEnd then trigger.action.outTextForCoalition(self.side, self:decodeMessage(v.messageEnd), 30) end
					if v.reward then self.battleCommander:addFunds(self.side, v.reward) end
					if v.endAction then v:endAction() end
					v.isRunning = false
					return time + 2
				end
			elseif v:isActive() and not v.isEscortMission then
				if v.canExecute and type(v.canExecute) == 'function' then
					if v:canExecute() then
						if v.messageStart then
							trigger.action.outTextForCoalition(self.side, self:decodeMessage(v.messageStart), 30) end
						if v.startAction then v:startAction() end
						v.isRunning = true
						--return time + 4
					end
				else
					if v.messageStart then
						trigger.action.outTextForCoalition(self.side, self:decodeMessage(v.messageStart), 30) end
					if v.startAction then v:startAction() end
					v.isRunning = true
					return time + 6
				end
			elseif v.isEscortMission and v:isActive() and not v.isRunning then
				if not v.notified then
					if v.titleBefore then
					v:titleBefore() end
					v.notified = true
				end
				if v:isActive() and v.notified and v:returnAccepted() and not v.isRunning then
					if v.startAction then v.startAction() end
					v.isRunning = true
					return time + 4
				end
			elseif v.isEscortMission and not v:isActive() and v.notified then
				v.notified = false
			end
		end

		return time + self.checkFrequency
	end

	function MissionCommander:acceptMission(mission)
		local targetMissionGroup = mission.missionGroup
		for _, v in ipairs(self.missions) do
			if v.isEscortMission and v.missionGroup == targetMissionGroup then
				v.accept = true
				v.isRunning = true
				return
			end
		end
	end



	function MissionCommander:init()
		--missionCommands.addCommandForCoalition(self.side, 'Missions', nil, self.printMissions, self)
		timer.scheduleFunction(self.checkMissions, self, timer.getTime() + 15)
	end
	printMissionMenus = printMissionMenus or {}
	function MissionCommander:createMissionsMenuForGroup(groupId)
		env.info("DEBUG: Creating menu for groupId="..tostring(groupId))
		
		if printMissionMenus[groupId] then
			missionCommands.removeItemForGroup(groupId, printMissionMenus[groupId])
		end
		
		printMissionMenus[groupId] = missionCommands.addCommandForGroup(groupId, "Missions", nil, function() self:printMissions(groupId) end)
	end

	function MissionCommander:decodeMessage(param)
		if type(param) == "function" then
			return param()
		elseif type(param) == "string" then
			return param
		end
	end
end

function isZoneUnderSEADMission(zoneName)
    for _, mission in ipairs(mc.missions) do
        if mission.zone == zoneName and mission.missionType == "SEAD" and mission:isActive() then
            return true
        end
    end
    return false
end

function isAnyOtherMissionActive(currentMissionZone)
    local missionData = missions[currentMissionZone]
    if missionData and IsGroupActive(missionData.missionGroup) then
        return true, missionData
    end
    return false, nil
end

function startNextMission(missionZone)
    local mission = missions[missionZone]
    if not mission then
        return
    end
    for trackedGroupName, _ in pairs(trackedGroups) do
        if IsGroupActive(trackedGroupName) then
            local trackedGroup = Group.getByName(trackedGroupName)
            if trackedGroup then
                local groupID = trackedGroup:getID()
                missionMenus[groupID] = missionMenus[groupID] or {}

                local isActive, activeMission = isAnyOtherMissionActive(missionZone)
                if isActive then
                    local activeMissionZone = activeMission.zone
                    local inProgressMenu = missionCommands.addSubMenuForGroup(groupID, "Current mission in progress. Continue?")
                    missionMenus[groupID].inProgressMenu = inProgressMenu

                    missionCommands.addCommandForGroup(groupID, "Yes", inProgressMenu, function()
                        removeMissionMenuForAll(activeMissionZone, nil, true)

                        if mission.missionGroup and type(mission.missionGroup) == "string" then
							local grpObj = GROUP:FindByName(mission.missionGroup)
							if grpObj then
								grpObj:Respawn()
							end
                            timer.scheduleFunction(function()
                                local groundUnitGroup = Group.getByName(mission.missionGroup)
                                if groundUnitGroup then
                                    trigger.action.groupStopMoving(groundUnitGroup)
                                end
                            end, {}, timer.getTime() + 2)

                            monitorFlagForMission(mission, trackedGroup, groupID)
                            createControlMenuForGroup(trackedGroup, mission, groupID)
                        else
                            trigger.action.outTextForGroup(groupID, "Error: Escort group not defined or invalid.", 10)
                        end
                    end)

                    missionCommands.addCommandForGroup(groupID, "No", inProgressMenu, function()
                        if missionMenus[groupID].inProgressMenu then
                            missionCommands.removeItemForGroup(groupID, missionMenus[groupID].inProgressMenu)
                            missionMenus[groupID].inProgressMenu = nil
                        end
                    end)

                    return
                end
            end
        end
    end
end


	if ManualHold == nil then ManualHold = false end
	function monitorFlagForMission(mission, group, groupID)
		if mission.MissionType ~= "Escort" then return end
		--env.info("DEBUG: Monitoring flag for mission: " .. mission.zone)
		mission.lastFlagValue = nil
		mission.wasStopped = false
		ManualHold = false

		local missionGroup = GROUP:FindByName(mission.missionGroup)
		if not missionGroup or not missionGroup:IsAlive() then return end

		local triggerZone = ZONE_GROUP:New(mission.missionGroup .. "_Zone", missionGroup, mission.radius)
		local groupSet = SET_GROUP:New():FilterCoalitions("red"):FilterCategories('ground'):FilterAlive():FilterStart()
		
		triggerZone.OnAfterEnteredZone = function(self, From, Event, To, triggeringGroup)
			if mission.wasStopped then return end
			mission.wasStopped = true
			if missionGroup:IsAlive() then
				local txt = sendRandomMessage("halt")
				local snd = getRandomSound("halt")
				local checkpoint = false
				local moving = "We got intel on enemy convoy heading toward us!\n\nConvoy holding position"
				local movingsound = 'Frontal.ogg'
				local ms
				if triggeringGroup then
					local dcsGroup = Group.getByName(triggeringGroup:GetName())
					if dcsGroup and dcsGroup:isExist() then
						for _, u in ipairs(dcsGroup:getUnits()) do
							if u:isExist() and u:getLife() > 0 and u:hasAttribute("Fortifications") and triggerZone:IsVec3InZone(u:getPosition().p) then
								checkpoint = true
								break
							end
						end
						local _, speed = getGroupSpeed(dcsGroup)
						ms = speed
					end
				end
				if checkpoint then
					txt = "Enemy checkpoint ahead.\n\nConvoy holding position, clear it out"
				end
				local function broadcastAndStop()
					if missionGroupIDs[mission.zone] then
						for _, data in pairs(missionGroupIDs[mission.zone]) do
							local grp = data.group
							if grp and grp:isExist() then
								if ms and ms > 1 then
									trigger.action.outTextForGroup(data.groupID, moving, 30)
									trigger.action.outSoundForGroup(data.groupID, movingsound)
								else
									trigger.action.outTextForGroup(data.groupID, txt, 30)
									trigger.action.outSoundForGroup(data.groupID, snd)
								end
							end
						end
					end
					if missionGroup:IsAlive() then missionGroup:RouteStop() end
				end
				
				if not ms or ms <= 1 then
					timer.scheduleFunction(function()
						if triggeringGroup then
							local dcsGroup = Group.getByName(triggeringGroup:GetName())
							if dcsGroup and dcsGroup:isExist() then
								local _, speed = getGroupSpeed(dcsGroup)
								ms = speed
							end
						end
						broadcastAndStop()
					end, {}, timer.getTime() + 15)
				else
					broadcastAndStop()
				end
			else
				for trackedGroupName,_ in pairs(trackedGroups) do
					local tracked = GROUP:FindByName(trackedGroupName)
					if not tracked or not tracked:IsAlive() then
						trackedGroups[trackedGroupName] = nil
					end
				end
			end
			
		end
		triggerZone.OnAfterZoneEmpty = function(self, From, Event, To)
			if ManualHold then 
				mission.wasStopped = false
				env.info('Manual hold is active, not resuming mission.')
				return 
			end
			if missionGroup:IsAlive() then
				local _, ms = getGroupSpeed(missionGroup:GetDCSObject() or Group.getByName(mission.missionGroup))
				local txt = sendRandomMessage("moving")
				local snd = getRandomSound("moving")
				if missionGroupIDs[mission.zone] then
					for _, data in pairs(missionGroupIDs[mission.zone]) do
						local grp = data.group
						if grp and grp:isExist() then
							if not ms or ms <= 1 then
								trigger.action.outTextForGroup(data.groupID, txt, 30)
								trigger.action.outSoundForGroup(data.groupID, snd)
							end
						end
					end
				end
				missionGroup:RouteResume()
			else
				for trackedGroupName,_ in pairs(trackedGroups) do
					local tracked = GROUP:FindByName(trackedGroupName)
					if not tracked or not tracked:IsAlive() then
						trackedGroups[trackedGroupName] = nil
					end
				end
			end
			mission.wasStopped = false
		end
		triggerZone:SetPartlyInside()
		triggerZone:Trigger(groupSet)
	end

	function ArmEscortAutoCapture(mission)
		if not mission or mission.MissionType ~= "Escort" then return end
		if mission._autoCapSch then mission._autoCapSch:Stop() mission._autoCapSch = nil end
		local zone = ZONE:FindByName(mission.TargetZone)
		if not zone then return end
		mission._autoCapSch = SCHEDULER:New(nil, function()
			local group = Group.getByName(mission.missionGroup)
			if not group or not group:isExist() then if mission._autoCapSch then mission._autoCapSch:Stop() mission._autoCapSch = nil end return end
			local currentZone = bc:getZoneByName(mission.TargetZone)
			if not currentZone then if mission._autoCapSch then mission._autoCapSch:Stop() mission._autoCapSch = nil end return end
			if currentZone.side == 2 then if mission._autoCapSch then mission._autoCapSch:Stop() mission._autoCapSch = nil end return end
			if currentZone.side == 0 and Utils.someOfGroupInZone(group, mission.TargetZone) then currentZone:capture(2) if mission._autoCapSch then mission._autoCapSch:Stop() mission._autoCapSch = nil end return end
		end, {}, 2, 5)
	end

function canStartMission(mission)
    if not mission then return false end
    local targetZone = bc:getZoneByName(mission.TargetZone)
    if not targetZone or targetZone.side ~= 1 then return false end
    if not missions[mission.zone] then return false end
    return not IsGroupActive(mission.missionGroup)
end

--[[ 	local z = bc:getZoneByName('Al Dahid')
	if z and z.triggers then
		for i,v in ipairs(z.triggers) do
			env.info(string.format('trigger %d  id=%s  event=%s',i,v.id,tostring(v.eventType)))
		end
	end ]]

function AutoHoldPosition(convoyName)
    env.info("AutoHoldPosition start "..tostring(convoyName))
    if not IsGroupActive(convoyName) then env.info("AutoHoldPosition exit: inactive "..tostring(convoyName)) return end
    local mission
    for _, v in pairs(missions) do
        if v.missionGroup == convoyName then mission = v break end
    end
    if not mission then env.info("AutoHoldPosition exit: no mission for "..tostring(convoyName)) return end
    local zoneName = mission.zone
    local TgtZone = bc:getZoneByName(mission.TargetZone)
    if not TgtZone or TgtZone.side ~= 1 then env.info("AutoHoldPosition exit: zone "..tostring(mission.TargetZone).." side="..tostring(TgtZone and TgtZone.side or "nil")) return end
    local convoy = Group.getByName(convoyName)
    if convoy then trigger.action.groupStopMoving(convoy) env.info("AutoHoldPosition stop issued "..tostring(convoyName)) end
    local txt = "Escort group: Nearing the target area, Clear it out\n\nConvoy holding position"
    ManualHold = true
    if missionGroupIDs[zoneName] then
        for _, d in pairs(missionGroupIDs[zoneName]) do
            local grp = d.group
            if grp and grp:isExist() then
                mission.wasStopped = true
                trigger.action.outSoundForGroup(d.groupID, "TakingCoverNowSir.ogg")
                trigger.action.outTextForGroup(d.groupID, txt, 20)
            end
        end
    end
    local tid=mission.TargetZone..'lost'
    for i=#(TgtZone.triggers or {}),1,-1 do local t=TgtZone.triggers[i] if t.id==tid and t.eventType=='lost' then table.remove(TgtZone.triggers,i) end end
    TgtZone:registerTrigger('lost', function(_, zone)
        if zone~=TgtZone then return end
        local ConvoyGroup = Group.getByName(convoyName)
		if ConvoyGroup and ConvoyGroup:isExist() then 
			trigger.action.groupContinueMoving(ConvoyGroup)
			local txt2="Escort group: Alright, moving!"
			ManualHold = false
			mission.wasStopped = false
			if missionGroupIDs[zoneName] then
				for _,d in pairs(missionGroupIDs[zoneName]) do
					local grp=d.group
					if grp and grp:isExist() then
						timer.scheduleFunction(function()
						trigger.action.outSoundForGroup(d.groupID,"AllClear.ogg")
						trigger.action.outTextForGroup(d.groupID,txt2,10)
						end, {}, timer.getTime() + 2)

					end
				end
			end
		end
    end,tid,1)
end

function SwitchWaypointIfFarpBuilt(groupName, fromIdx, toIdx)
    --if farpBuiltByConvoy[groupName] ~= true then return end
    local g = Group.getByName(groupName); if not g or not g:isExist() then return end
    local c = g:getController(); if not c then return end
    c:setCommand({ id = 'SwitchWaypoint', params = { fromWaypointIndex = fromIdx, goToWaypointIndex = toIdx } })
end

function PromptFarpSetup(convoyName)
	if farpBuiltByConvoy[convoyName] then return end
    local convoyGrp = Group.getByName(convoyName)
    if convoyGrp then trigger.action.groupStopMoving(convoyGrp) end
    if not trackedGroups then return end
    for trackedName,_ in pairs(trackedGroups) do
        local tg = Group.getByName(trackedName)
        if tg and tg:isExist() then
            local gid = tg:getID()
            local parent = missionMenus[gid] and missionMenus[gid].groupMenu
            if parent then
				trigger.action.outTextForGroup(gid,"Escort group: FARP deployment possible - Choose from the Escort radio menu",15)
				trigger.action.outSoundForGroup(gid,"AwaitingForCommand.ogg")
                local sub = missionCommands.addSubMenuForGroup(gid,"Set up FARP?",parent)
                missionMenus[gid].farpMenu = sub
                missionCommands.addCommandForGroup(gid,"Yes",sub,function()
					trigger.action.outTextForGroup(gid,"Escort group: Roger - creating FARP, standby. We will move little further",15,true)
					trigger.action.outSoundForGroup(gid,"CopyThat.ogg")
					if convoyGrp then trigger.action.groupContinueMoving(convoyGrp) end
					local mission
					for _, v in pairs(missions) do if v.missionGroup==convoyName then mission=v break end end
					if mission then mission.wasStopped=true end
                    farpBuiltByConvoy[convoyName]=true
					BuildFarpHere(convoyName)

                    missionCommands.removeItemForGroup(gid,sub)
                    missionMenus[gid].farpMenu = nil
					
                end)
                missionCommands.addCommandForGroup(gid,"No",sub,function()
                    if convoyGrp then trigger.action.groupContinueMoving(convoyGrp) end
					local mission
					for _, v in pairs(missions) do if v.missionGroup==convoyName then mission=v break end end
					if mission then mission.wasStopped=false end
					trigger.action.outTextForGroup(gid,"Escort group: Copy that, Proceeding with mission",10)
					trigger.action.outSoundForGroup(gid,"RogerProceedMission.ogg")
                    missionCommands.removeItemForGroup(gid,sub)
                    missionMenus[gid].farpMenu = nil
                end)
            end
        end
    end
end

function createControlMenuForGroup(group, mission, groupID)

    if mission.MissionType ~= "Escort" then return end
    missionMenus[groupID] = missionMenus[groupID] or {}

    for _, existingMission in pairs(missions) do
        if not trackedGroups[group:getName()] and mission.zone == existingMission.zone then
            trackedGroups[group:getName()] = true
        end
    end

    if not IsGroupActive(mission.missionGroup) then

		RespawnGroup(mission.missionGroup)

        timer.scheduleFunction(function()
            local missionGroup = Group.getByName(mission.missionGroup)
            if missionGroup then
                trigger.action.groupStopMoving(missionGroup)
                monitorFlagForMission(mission, group, groupID)
				ArmEscortAutoCapture(mission)
            end
        end, {}, timer.getTime() + 2)
    end

    local groupMenu = missionCommands.addSubMenuForGroup(groupID, mission.menuTitle)
    missionMenus[groupID].groupMenu = groupMenu

	missionCommands.addCommandForGroup(groupID, "Move", groupMenu, function()
		if IsGroupActive(mission.missionGroup) then
			local groundUnitGroup = Group.getByName(mission.missionGroup)
			local _, ms = getGroupSpeed(groundUnitGroup)

			local snd       = getRandomSound("CommandMove")
			local commander = ""
			local leader    = group:getUnit(1)
			if leader then
				local name = leader:getPlayerName()
				if name and name ~= "" then commander = name end
			end

			if ms and ms > 1 then
				local txt = commander ~= "" and "Escort group: We're already on the move, " .. commander .. "." or "Escort group: We're already on the move, sir."
				if missionGroupIDs[mission.zone] then
					for _, data in pairs(missionGroupIDs[mission.zone]) do
						local grp = data.group
						if grp and grp:isExist() then
							trigger.action.outSoundForGroup(data.groupID, snd)
							trigger.action.outTextForGroup(data.groupID, txt, 10)
						end
					end
				end
				return
			end
			mission.wasStopped = false
			trigger.action.groupContinueMoving(groundUnitGroup)
			local txt = commander ~= "" and "Escort group: Copy that " .. commander .. ", moving."
			                             or  "Escort group: Moving."
			if missionGroupIDs[mission.zone] then
				for _, data in pairs(missionGroupIDs[mission.zone]) do
					local grp = data.group
					if grp and grp:isExist() then
						trigger.action.outSoundForGroup(data.groupID, snd)
						trigger.action.outTextForGroup(data.groupID, txt, 10)
					end
				end
			end
		else
			trigger.action.outTextForGroup(groupID, "Ground unit not found.", 10)
		end
	end)

	missionCommands.addCommandForGroup(groupID, "Hold position", groupMenu, function()
		if IsGroupActive(mission.missionGroup) then
			local groundUnitGroup = Group.getByName(mission.missionGroup)
			local _, ms = getGroupSpeed(groundUnitGroup)

			local snd       = getRandomSound("CommandStop")
			local commander = ""
			local leader    = group:getUnit(1)
			if leader then
				local name = leader:getPlayerName()
				if name and name ~= "" then commander = name end
			end

			if ms and ms < 1 then
				local txt = commander ~= "" and "Escort group: We're already stopped " .. commander .. "."
				                             or  "Escort group: We're already stopped, sir."
				if missionGroupIDs[mission.zone] then
					for _, data in pairs(missionGroupIDs[mission.zone]) do
						local grp = data.group
						if grp and grp:isExist() then
							trigger.action.outSoundForGroup(data.groupID, snd)
							trigger.action.outTextForGroup(data.groupID, txt, 10)
						end
					end
				end
				return
			end
			mission.wasStopped = true
			trigger.action.groupStopMoving(groundUnitGroup)
			local txt = commander ~= "" and "Escort group: Copy that " .. commander .. ", holding position."
			                             or  "Escort group: Holding position."
			if missionGroupIDs[mission.zone] then
				for _, data in pairs(missionGroupIDs[mission.zone]) do
					local grp = data.group
					if grp and grp:isExist() then
						trigger.action.outSoundForGroup(data.groupID, snd)
						trigger.action.outTextForGroup(data.groupID, txt, 10)
					end
				end
			end
		else
			trigger.action.outTextForGroup(groupID, "Ground unit not found.", 10)
		end
	end)


    missionCommands.addCommandForGroup(groupID, "Deploy smoke near the convoy", groupMenu, function()
        if IsGroupActive(mission.missionGroup) then
            local groundUnitGroup = Group.getByName(mission.missionGroup)
            local lastAliveUnit = nil
            for _, unit in ipairs(groundUnitGroup:getUnits()) do
                if unit:isExist() and unit:getLife() > 0 then
                    lastAliveUnit = unit
                end
            end
            if lastAliveUnit then
                local position = lastAliveUnit:getPoint()
                trigger.action.smoke({x = position.x, y = position.y, z = position.z - 10}, trigger.smokeColor.Blue)
                trigger.action.outTextForGroup(groupID, "Escort group: Blue smoke deployed", 10)
            else
                trigger.action.outTextForGroup(groupID, "No alive units found in the escort group.", 10)
            end
        else
            trigger.action.outTextForGroup(groupID, "Escort group not found.", 10)
        end
    end)

	missionCommands.addCommandForGroup(groupID,"Get Bearing to the Convoy",groupMenu,function()
		if IsGroupActive(mission.missionGroup) then
			local groundUnitGroup=Group.getByName(mission.missionGroup)
			local lastAliveUnit=nil
			for _,unit in ipairs(groundUnitGroup:getUnits()) do
				if unit:isExist() and unit:getLife()>0 then lastAliveUnit=unit end
			end
			if lastAliveUnit then
				local convoyPosition=lastAliveUnit:getPoint()
				local groupLeader=group:getUnit(1)
				if groupLeader then
					local groupLeaderPosition=groupLeader:getPoint()
					local dist=UTILS.VecDist3D(groupLeaderPosition,convoyPosition)
					local dstkm=string.format('%.2f',dist/1000)
					local bearing=Utils.getBearing(groupLeaderPosition,convoyPosition)
					trigger.action.outTextForGroup(groupID,"Escort group: "..math.floor(bearing).."°\n\nDistance: "..dstkm.." km",20)
				else
					trigger.action.outTextForGroup(groupID,"Could not determine group leader's position.",10)
				end
			else
				trigger.action.outTextForGroup(groupID,"No alive units found in the escort group.",10)
			end
		else
			trigger.action.outTextForGroup(groupID,"Escort group not found.",10)
		end
	end)
	
	local holdMenu = missionCommands.addSubMenuForGroup(groupID, "Manual Hold", groupMenu)
	missionMenus[groupID].holdMenu = holdMenu
	missionCommands.addCommandForGroup(groupID, "Enable forced Hold", holdMenu, function()
		ManualHold = true
		if missionGroupIDs[mission.zone] then
			for _, d in pairs(missionGroupIDs[mission.zone]) do
				local grp = d.group
				if grp and grp:isExist() then
					trigger.action.outSoundForGroup(d.groupID, "OkRoggerThat.ogg")
					trigger.action.outTextForGroup(d.groupID, "Escort group: Ok, Rogher that. Enabled forced hold", 10)
				end
			end
		end
	end)
	missionCommands.addCommandForGroup(groupID, "Disable forced Hold", holdMenu, function()
		ManualHold = false
		if missionGroupIDs[mission.zone] then
			for _, d in pairs(missionGroupIDs[mission.zone]) do
				local grp = d.group
				if grp and grp:isExist() then
					trigger.action.outSoundForGroup(d.groupID, "OkRoggerThat.ogg")
					trigger.action.outTextForGroup(d.groupID, "Escort group: Rogher that. Disabled forced hold", 10)
				end
			end
		end
	end)

    local restartMenu = missionCommands.addSubMenuForGroup(groupID, "Restart Mission", groupMenu)
    missionMenus[groupID].restartMenu = restartMenu

    missionCommands.addCommandForGroup(groupID, "Yes", restartMenu, function()
        if mission.missionGroup then
            destroyGroupIfActive(mission.missionGroup)
        end
        removeMissionMenuForAll(mission.zone)
		RespawnGroup(mission.missionGroup)
        timer.scheduleFunction(function()
            local missionGroup = Group.getByName(mission.missionGroup)
            if missionGroup then
                trigger.action.groupStopMoving(missionGroup)
            end
		trigger.action.outSoundForGroup(groupID, "YourCommand.ogg")
		trigger.action.outTextForGroup(groupID, "Escort group:\n\nWe are standing by and ready to move on your command.", 10)
        end, {}, timer.getTime() + 2)
        createControlMenuForGroup(group, mission, groupID)
		monitorFlagForMission(mission, group, groupID)
    end)

    missionCommands.addCommandForGroup(groupID, "No", restartMenu, function()
        missionCommands.removeItemForGroup(groupID, restartMenu)
        trigger.action.outTextForGroup(groupID, "Restart canceled.", 10)
    end)
    return missionMenus[groupID]
end


function handleMission(zoneName, groupName, groupID, group)
	if not missions then return end
    if not group or not group:isExist() then return end
    if not missions[zoneName] then return end
    local currentMission = missions[zoneName]

    for _, mission in pairs(missions) do
        if not trackedGroups[groupName] and zoneName == mission.zone then
            trackedGroups[groupName] = true
            missionMenus[groupID] = missionMenus[groupID] or {}

            if IsGroupActive(mission.missionGroup) then
                --monitorFlagForMission(mission, group, groupID)
				generateEscortMission(zoneName, groupName, groupID, group, currentMission)
				missionGroupIDs[zoneName] = missionGroupIDs[zoneName] or {}
				missionGroupIDs[zoneName][groupID] = {
					groupID = groupID,	
					group = group
				}
                missionMenus[groupID] = createControlMenuForGroup(group, mission, groupID)
                return
            end

            if canStartMission(mission) then
				--[[
				for _, v in ipairs(mc.missions) do
					if v.zoneName == zoneName and v.isEscortMission then
						if v.denied == true then v.denied = false end
						break
					end
				end
				--]]
				generateEscortMission(zoneName, groupName, groupID, group)

                local acceptMenu = missionCommands.addSubMenuForGroup(group:getID(), mission.missionTitle)
                missionMenus[groupID].acceptMenu = acceptMenu

				missionCommands.addCommandForGroup(group:getID(), "Accept Mission", acceptMenu, function()
					mc:acceptMission(mission)
					if mission.ActivateZone then
						local z = zones[mission.ActivateZone]
						if z and z.side == 0 and not z.firstCaptureByRed then z:MakeZoneRedAndUpgrade() end
						env.info("DEBUG: Activating zone for mission: "..mission.ActivateZone)
					end					
					createControlMenuForGroup(group, mission, groupID)

					local commander=""
					local leader=group:getUnit(1)
					if leader then
						local name=leader:getPlayerName()
						if name and name~="" then commander=name end
					end

					for trackedGroupName,_ in pairs(trackedGroups) do
						local trackedGroup=Group.getByName(trackedGroupName)
						if trackedGroup and trackedGroup:isExist() then
							local trackedGroupID=trackedGroup:getID()
							if missionMenus[trackedGroupID] and missionMenus[trackedGroupID].acceptMenu then
								removeMissionMenuForAll(mission.zone)
							end
							if commander~="" then
								trigger.action.outTextForGroup(trackedGroupID,"Escort mission accepted by "..commander..".",10)
								trigger.action.outSoundForGroup(trackedGroupID,"ding.ogg")
							end
                            timer.scheduleFunction(function()
                                createControlMenuForGroup(trackedGroup,mission,trackedGroupID)
                                trigger.action.outTextForGroup(trackedGroupID,"Escort group:\n\nWe are standing by and ready to move on your command.",15)
                                local audio = ({'YourCommand.ogg','Duty.ogg'})[math.random(2)]
                                trigger.action.outSoundForGroup(trackedGroupID,audio)
                                if IsGroupActive(mission.missionGroup) then
                                    local g = Group.getByName(mission.missionGroup)
                                    if g then
                                        local u
                                        for _, unit in ipairs(g:getUnits()) do
                                            if unit:isExist() and unit:getLife() > 0 then u = unit end
                                        end
                                        if u then
                                            local p = u:getPoint()
                                            trigger.action.smoke({x = p.x, y = p.y, z = p.z - 10}, trigger.smokeColor.Blue)
                                        end
                                    end
                                end
                            end,nil,timer.getTime()+5)
						else
							trackedGroups[trackedGroupName]=nil
						end
					end
				end)
                missionCommands.addCommandForGroup(group:getID(), "Deny Mission", acceptMenu, function()
                    trigger.action.outTextForGroup(group:getID(), "Mission denied.", 10)
					for _, v in ipairs(mc.missions) do
						if v.zoneName == zoneName and v.isEscortMission then
							v.denied = true
							break
						end
					end
                    if missionMenus[groupID] and missionMenus[groupID].acceptMenu then
                        missionCommands.removeItemForGroup(groupID, missionMenus[groupID].acceptMenu)
                        missionMenus[groupID].acceptMenu = nil
                    end
                end)
            end
        end
    end
end

function removeMissionMenuForAll(zoneName, groupID, destroyIfActive)
    local mission = missions[zoneName]
    if not mission then return end
    if not trackedGroups then return end

    if groupID then
		if missionMenus[groupID] then
			if missionMenus[groupID].restartMenu then
				missionCommands.removeItemForGroup(groupID, missionMenus[groupID].restartMenu)
				missionMenus[groupID].restartMenu = nil
			end
			if missionMenus[groupID].acceptMenu then
				missionCommands.removeItemForGroup(groupID, missionMenus[groupID].acceptMenu)
				missionMenus[groupID].acceptMenu = nil
			end
			if missionMenus[groupID].inProgressMenu then
				missionCommands.removeItemForGroup(groupID, missionMenus[groupID].inProgressMenu)
				missionMenus[groupID].inProgressMenu = nil
			end
			if missionMenus[groupID].groupMenu then
				missionCommands.removeItemForGroup(groupID, missionMenus[groupID].groupMenu)
				missionMenus[groupID].groupMenu = nil
			end
			missionMenus[groupID] = nil
		end
    else
        for trackedGroupName, _ in pairs(trackedGroups) do
            local trackedGroup = Group.getByName(trackedGroupName)
            if trackedGroup and trackedGroup:isExist() then
                local groupID = trackedGroup:getID()
                if missionMenus[groupID] then
                    if missionMenus[groupID].restartMenu then
                        missionCommands.removeItemForGroup(groupID, missionMenus[groupID].restartMenu)
                        missionMenus[groupID].restartMenu = nil
                    end
                    if missionMenus[groupID].acceptMenu then
                        missionCommands.removeItemForGroup(groupID, missionMenus[groupID].acceptMenu)
                        missionMenus[groupID].acceptMenu = nil
                    end
                    if missionMenus[groupID].inProgressMenu then
                        missionCommands.removeItemForGroup(groupID, missionMenus[groupID].inProgressMenu)
                        missionMenus[groupID].inProgressMenu = nil
                    end
                    if missionMenus[groupID].groupMenu then
                        missionCommands.removeItemForGroup(groupID, missionMenus[groupID].groupMenu)
                        missionMenus[groupID].groupMenu = nil
                    end
                    missionMenus[groupID] = nil
                end
            end
        end
    end

    if destroyIfActive then
            destroyGroupIfActive(mission.missionGroup)
        
    end
end

function removeMenusForGroupID(groupID)
    local trackedGroup = Group.getByID(groupID)
    if not trackedGroup then return end
    if missionMenus[groupID] then
        if missionMenus[groupID].restartMenu then
            missionCommands.removeItemForGroup(groupID, missionMenus[groupID].restartMenu)
            missionMenus[groupID].restartMenu = nil
        end
        if missionMenus[groupID].acceptMenu then
            missionCommands.removeItemForGroup(groupID, missionMenus[groupID].acceptMenu)
            missionMenus[groupID].acceptMenu = nil
        end
        if missionMenus[groupID].inProgressMenu then
            missionCommands.removeItemForGroup(groupID, missionMenus[groupID].inProgressMenu)
            missionMenus[groupID].inProgressMenu = nil
        end
        if missionMenus[groupID].groupMenu then
            missionCommands.removeItemForGroup(groupID, missionMenus[groupID].groupMenu)
            missionMenus[groupID].groupMenu = nil
        end
        missionMenus[groupID] = nil
    end
end
function sendRandomMessage(context)
    local messages = {
		halt = {
			"Recon confirms enemy activity ahead.\n\nConvoy holding position, awaiting clearance.",
			"Hostile movement detected nearby.\n\nConvoy halted. Secure the area before resuming.",
			"Enemy presence confirmed ahead.\n\nConvoy stopped, standing by for further orders.",
			"Potential threat identified.\n\nConvoy holding. Clear the area to proceed."
		},
		moving = {
			"Convoy rolling out.\n\nStay sharp and maintain visual.",
			"Convoy is Oscar Mike.\n\nKeep formation tight and eyes open for threats.",
			"Convoy underway.\n\nScan the route ahead for hostiles.",
			"Route clear. Convoy advancing toward destination."
		}
    }
    local selectedMessages = messages[context] or {"Unknown context provided. Please verify the convoy's status."}
    return selectedMessages[math.random(#selectedMessages)]
end
function getRandomSound(context)
    local sounds = {
		halt = {
			"ApprachingTheEnemy.ogg",
			"TakingCoverNowSir.ogg"
		},
		moving = {
			"AllrightLetsMoveIt.ogg",
			"AllClear.ogg",
			"LetsGo.ogg",
			"MoveOut.ogg"
		},
		CommandMove = {
			"RogerProceedMission.ogg",
			"OkRoggerThat.ogg",
			"CopyThat.ogg",
			"MoveOut.ogg"
		},
		CommandStop = {
			"TakingCover.ogg",
			"OkRoggerThat.ogg",
			"CopyThat.ogg",
			"TakingCoverNowSir.ogg"
		}
    }
    local selectedSounds = sounds[context] or {"Unknown context provided. Please verify the convoy's status."}
    return selectedSounds[math.random(#selectedSounds)]
end


local FARPFreq=129
local EscortFARPCount=0
function CustomBuildAFARP(Coordinate,startZone)
  if bc:getZoneOfPoint(Coordinate:GetVec3()) then return end
  EscortFARPCount=EscortFARPCount+1
  local FName="Escort Mission FARP "..EscortFARPCount
  FARPFreq=FARPFreq+1
  escortFarpToZone[FName]=startZone
  ZONE_RADIUS:New(FName,Coordinate:GetVec2(),120,false)
  if supplyZones then supplyZones[#supplyZones+1]=FName end
  if allZones then allZones[#allZones+1]=FName end
  UTILS.SpawnFARPAndFunctionalStatics(FName,Coordinate,ENUMS.FARPType.INVISIBLE,Foothold_ctld.coalition,country.id.USA,EscortFARPCount,FARPFreq,radio.modulation.AM,nil,nil,nil,200,100,20,nil,true,true)
  Foothold_ctld:AddCTLDZone(FName,CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,false)
  MESSAGE:New(string.format("%s in operation!",FName),15):ToBlue()
  local function CopyWarehouse()
    local srcStore=nil
    if zones then
      for _,zone in pairs(zones) do
        local n=zone.airbaseName
        if n then
          srcStore=STORAGE:FindByName(n)
          if srcStore then break end
        end
      end
    end
    if srcStore then
      local dstStore=STORAGE:FindByName(FName)
      if dstStore then
        for item,qty in pairs(srcStore:GetInventory()) do
          if qty>0 then dstStore:SetItem(item,qty) end
        end
      end
    end
  end
  if Era=='Coldwar' then SCHEDULER:New(nil,CopyWarehouse,nil,10) else CopyWarehouse() end
  local markId = 96000 + EscortFARPCount
  trigger.action.circleToAll(-1,markId,Coordinate:GetVec3(),120,{0,0,1,1},{0,0,1,0.25},1)
end

function BuildFarpHere(name)
    if not name then env.info('BuildFarpHere: No name provided') return end
    local gw = GROUP:FindByName(name)
    if not gw then trigger.action.outTextForCoalition(2,'Group is invalid: '..name,10) return end
    local g = Group.getByName(name)
    local coord = gw:GetCoordinate()
    if not coord then
        trigger.action.outTextForCoalition(2,'BuildFarpHere: No coordinate found for group: '..name,10)
        return
    end
    --if g then trigger.action.groupContinueMoving(g) end
    local startZone = nil
    for _,m in pairs(missions) do
        if string.find(name,m.missionGroup,1,true) or string.find(m.missionGroup,name,1,true) then
            startZone = m.zone
            break
        end
    end
    timer.scheduleFunction(function()
        if g and g:isExist() then trigger.action.groupStopMoving(g) end
        CustomBuildAFARP(coord,startZone)
    end,nil,timer.getTime()+25)
end


local function orderedZones(side, allow, capMode)
	local zt = bc:getZones()
	local c  = {}
	for _, v in ipairs(zt) do
		if v.active
		and ((side == nil or v.side == side)
			or (capMode and v.side == 0 and (not v.NeutralAtStart or v.firstCaptureByRed)))
		and (not v.zone:lower():find("hidden"))
		and (not allow or allow[v.zone]) and (not v.suspended) then
			local suf = WaypointList[v.zone]
			local wp  = suf and tonumber(suf:match("%d+"))
			c[#c+1]   = { z = v, wp = wp, disp = (wp and v.zone .. suf or v.zone) }
		end
	end
	table.sort(c, function(a, b)
		if a.wp and b.wp then return a.wp < b.wp end
		if a.wp       then return true  end
		if b.wp       then return false end
		return a.z.zone < b.z.zone
	end)
	return c
end


missionMenus = {}
trackedGroups = trackedGroups or {}
missionGroupIDs = {}
ArcoSpawnIndex = 1
capSpawnIndex = 1
capParentMenu = nil
capControlMenu = nil
ArcoParentMenu = nil

capActive = false
ArcoActive = false
TexacoActive = false
ArcoGroup = nil
TexacoGroup = nil
capGroup = nil
capTemplate = (Era == 'Coldwar') and 'CAP_Template_CW' or 'CAP_Template'
capAltitude = 28000
capSpeed = 380
capHeadings = {
    ["Hot 360"] = 360,
    ["Hot 045"] = 45,
    ["Hot 090"] = 90,
    ["Hot 135"] = 135,
    ["Hot 180"] = 180,
    ["Hot 225"] = 225,
    ["Hot 270"] = 270,
    ["Hot 315"] = 315
}
capLegs = {["Orbit"] = 0,["10 NM Leg"] = 10, ["20 NM Leg"] = 20, ["30 NM Leg"] = 30, ["40 NM Leg"] = 40, ["50 NM Leg"] = 50}
function despawnCap()
    if capGroup then
        capGroup:Despawn()
    end
end
function despawnArco()
	stopArcoProximityWatch()
    if ArcoGroup then
        ArcoGroup:Despawn()
    end
end
function despawnTexaco()
	stopTexacoProximityWatch()
    if TexacoGroup then
        TexacoGroup:Despawn()
    end
end

AWACS_GROUPS = {
    [1] = "AWACS_RED",
    [2] = "AWACS_BLUE"
}

AWACS_CFG = {
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=150 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=60 }   -- blue
}


_awacsFG,_awacsZone,_awacsMissionParams = {},{},{}

local function _anyZoneOfSide(side)
    local zi = Frontline._zoneInfo
    if not zi then return nil end
    for name,info in pairs(zi) do
        if info and info.center and info.side == side then return name end
    end
    return nil
end

local function _bearingDeg(a, b)
    local dx = b.x - a.x
    local dy = b.y - a.y
    local h = math.deg(math.atan2(dx, dy))
    if h < 0 then h = h + 360 end
    return h
end

local function _pickDensestZone(side, radiusNm)
    local zi = Frontline._zoneInfo or {}
    local best, bestCnt = nil, -1
    local r2 = (radiusNm or 80) * 1852; r2 = r2 * r2
    for name,info in pairs(zi) do
        if info and info.center and info.side == side and info.sameSideNeighbors then
            local cnt = 0
            for i=1,#info.sameSideNeighbors do
                local n = info.sameSideNeighbors[i]
                if n.dist2 <= r2 then cnt = cnt + 1 else break end
            end
            if cnt > bestCnt then best, bestCnt = name, cnt end
        end
    end
    return best
end

local function _minDistToEnemyNm(zoneName, mySide)
    local zi = Frontline._zoneInfo or {}
    local info = zi[zoneName]; if not info or not info.enemyNeighbors then return 1e9 end
    local best2 = 1e18
    for i=1,#info.enemyNeighbors do
        local nb = info.enemyNeighbors[i]
        if nb.side and nb.side ~= 0 and nb.side ~= mySide then
            best2 = nb.dist2; break
        end
    end
    if best2 == 1e18 then return 1e9 end
    return math.sqrt(best2) / 1852
end

local function _nearestFriendlyTo(anchorEnemy, mySide, minNm)
    local zi = Frontline._zoneInfo or {}
    local enemyInfo = zi[anchorEnemy]; if not enemyInfo or not enemyInfo.enemyNeighbors then return nil end
    for i=1,#enemyInfo.enemyNeighbors do
        local nb = enemyInfo.enemyNeighbors[i]
        if nb.side == mySide then
            if _minDistToEnemyNm(nb.name, mySide) >= (minNm or 0) then return nb.name end
        end
    end
    return nil
end

local function _computeAwacsStationWithZone(side)
	local cfg = AWACS_CFG[side] or {}
    local zi  = Frontline._zoneInfo or {}
    local enemy = (side == 1) and 2 or 1
	local sep = cfg.sep or 0
    local enemyAnchor = _pickDensestZone(enemy, 80) or _anyZoneOfSide(enemy); if not enemyAnchor then return nil, nil end
    local myPick = _nearestFriendlyTo(enemyAnchor, side, sep) or _anyZoneOfSide(side); if not myPick then return nil, nil end
    local myInfo = zi[myPick]; if not myInfo or not myInfo.center then return nil, nil end
    local myC = myInfo.center
	local need = sep - _minDistToEnemyNm(myPick, side)
    if need > 0 then
        local eInfo = zi[enemyAnchor]
        local eC = (eInfo and eInfo.center) or myC
        if myInfo.enemyNeighbors and #myInfo.enemyNeighbors > 0 then
            for i=1,#myInfo.enemyNeighbors do
                local nb = myInfo.enemyNeighbors[i]
                if nb.side and nb.side ~= 0 and nb.side ~= side then
                    local directEnemy = zi[nb.name]
                    if directEnemy and directEnemy.center then eC = directEnemy.center end
                    break
                end
            end
        end
        local dir = vnorm(v2(myC.x - eC.x, myC.y - eC.y))
        myC = vadd(myC, vmul(dir, (need + 5) * NM))
    end
    local alt = cfg.alt or 30000
    local hdg = cfg.hdg or 270
    local toward = nil
    if myInfo.sameSideNeighbors and #myInfo.sameSideNeighbors > 0 then
        for i=1,#myInfo.sameSideNeighbors do
            local nname = myInfo.sameSideNeighbors[i].name
            local ninfo = nname and zi[nname] or nil
            if ninfo and ninfo.center and ninfo.side == side and ninfo.active ~= false then
                local tC = ninfo.center
                hdg = _bearingDeg({x=myC.x,y=myC.y},{x=tC.x,y=tC.y})
                toward = nname
                break
            end
        end
    end
    return COORDINATE:New(myC.x, UTILS.FeetToMeters(alt), myC.y), myPick, hdg, toward
end


function RepositionAwacsToFront()
    env.info("AWACS is checking the frontline")
    for side=1,2 do
        local coord, z, h = _computeAwacsStationWithZone(side)
        if coord and (_awacsZone[side] ~= z) then setAwacsRacetrack(side, coord, h, nil, z) else env.info("AWACS is already in the correct zone") end
    end
end

function setAwacsRacetrack(side, coord, heading, leg, zoneName)
    local fg = _awacsFG[side] or nil; if not fg or not coord then return end
    local cfg = AWACS_CFG[side] or {}
    local alt = cfg.alt or 30000
    local spd = cfg.speed or 350
    local hdg = heading or cfg.hdg or 270
    local leglen = leg or cfg.leg or 10
    local vec = coord.GetVec3 and coord:GetVec3() or nil
    local params = _awacsMissionParams[side]
    local activeZone = params and params.zone or _awacsZone[side]
    local currentZone = zoneName or activeZone
    if currentZone == activeZone then return end
    local cur = fg:GetMissionCurrent(); if cur then cur:__Cancel(5) end
    local auf = AUFTRAG:NewAWACS(coord, alt, spd, hdg, leglen)
    _awacsZone[side] = currentZone
    _awacsMissionParams[side] = {
        x = vec and vec.x or nil,
        z = vec and vec.z or nil,
        hdg = hdg,
        leg = leglen,
        zone = _awacsZone[side]
    }
    fg:AddMission(auf)
end

function spawnAwacs(side, heading, leg)
    local coord, z, ch, toward = _computeAwacsStationWithZone(side); if not coord then return end
    local aim = toward or z
    local zobj = aim and ZONE:FindByName(aim) or nil
    local targetCoord = (zobj and zobj:GetCoordinate()) or (Frontline._zoneInfo[aim] and COORDINATE:New(Frontline._zoneInfo[aim].center.x, coord.y, Frontline._zoneInfo[aim].center.y)) or nil
    local hdgCalc = targetCoord and coord:GetAngleDegrees(coord:GetDirectionVec3(targetCoord)) or ch
    local hdg = heading or hdgCalc or AWACS_CFG[side].hdg
    local alt = AWACS_CFG[side].alt
    local spd = AWACS_CFG[side].speed
    local lg  = leg or AWACS_CFG[side].leg
    local g = Respawn.SpawnAtPoint(AWACS_GROUPS[side], coord, hdg, lg, alt, spd)
    if not g then return end
    timer.scheduleFunction(function(group, time)
        local spawnedGroup = GROUP:FindByName(group:getName())
        local fg = FLIGHTGROUP:New(spawnedGroup)
        fg:GetGroup():CommandSetInvisible(true):CommandSetImmortal(true):CommandSetUnlimitedFuel(true)
        local auf = AUFTRAG:NewAWACS(coord, alt, spd, hdg, lg)
        fg:AddMission(auf)
        _awacsFG[side] = fg
        _awacsZone[side] = z
        local vec = coord.GetVec3 and coord:GetVec3() or nil
        _awacsMissionParams[side] = {
            x = vec and vec.x or nil,
            z = vec and vec.z or nil,
            hdg = hdg,
            leg = lg,
            zone = _awacsZone[side]
        }
    end, g, timer.getTime() + 1)
end


--[[ 

BASE:TraceClass("FLIGHTGROUP")
BASE:TraceClass("AUFTRAG")
BASE:TraceOn()
BASE:TraceClass("INTEL")
]]
function setCapRacetrack(coord, heading, leg, zone)
    if not capGroup then return end
	local currentMission = capGroup:GetMissionCurrent()
    if currentMission then
        currentMission:__Cancel(5)
    end
	local formation = 196610
	if leg == 0 then
		local capSpeed = 360
		formation = 393217
		--CapMissionOrbit2 = AUFTRAG:NewORBIT_CIRCLE_EngageTargets(coord,capAltitude,capSpeed,8,formation,50)
		CapMissionOrbit2 = AUFTRAG:NewORBIT_CIRCLE(coord, capAltitude, capSpeed)
		CapMissionOrbit2:SetMissionAltitude(28000)
		CapMissionOrbit2.missionTask=ENUMS.MissionTask.CAP
		CapMissionOrbit2:SetEngageDetected(40, {"Air"})
		CapMissionOrbit2:SetROT(2)
		CapMissionOrbit2:SetROE(2)
		capGroup:AddMission(CapMissionOrbit2)
		function CapMissionOrbit2:OnAfterExecuting(From, Event, To)
			CapMissionOrbit2:SetMissionSpeed(330)
			if zone then
				trigger.action.outTextForCoalition(2, "CAP: Orbiting at " .. zone, 10)
			else
				trigger.action.outTextForCoalition(2, "CAP: Orbiting", 10)
			end
		end
	else
    	--CapMission2 = AUFTRAG:NewPATROLRACETRACK_EngageTargets(coord,capAltitude,capSpeed,heading,leg,327681,50)
		CapMission2 = AUFTRAG:NewORBIT(coord, capAltitude, capSpeed, heading, leg)
		CapMission2:SetMissionAltitude(28000)
		CapMission2.missionTask=ENUMS.MissionTask.CAP
		CapMission2:SetEngageDetected(40, {"Air"})
		CapMission2:SetROT(2)
		CapMission2:SetROE(2)
		CapMission2:SetMissionSpeed(450)
		capGroup:AddMission(CapMission2)
		function CapMission2:OnAfterExecuting(From, Event, To)
		CapMission2:SetMissionSpeed(400)
			if zone then
				trigger.action.outTextForCoalition(2, "CAP: Racetrack at " .. zone .. " with heading " .. heading .. "° and leg distance " .. leg .. " NM", 10)
			else
				trigger.action.outTextForCoalition(2, "CAP: Racetrack with heading " .. heading .. "° and leg distance " .. leg .. " NM", 10)
			end
		end
	end
end

-- tankers
TexacoZone = nil
ArcoZone = nil
BlueClients = SET_CLIENT:New():FilterCoalitions("blue"):FilterCategories("plane"):FilterActive():FilterStart()
ARCO_PROX_RADIUS_M = UTILS.FeetToMeters(1000)
ARCO_PROX_ALT_M = UTILS.FeetToMeters(500)

TEXACO_PROX_RADIUS_M = UTILS.FeetToMeters(1000)
TEXACO_PROX_ALT_M = UTILS.FeetToMeters(500)

function stopArcoProximityWatch()
    if ArcoZone and ArcoZone.ZoneTimer then
        ArcoZone.ZoneTimer:Stop()
    end
    ArcoZone = nil
end

function stopTexacoProximityWatch()
    if TexacoZone and TexacoZone.ZoneTimer then
        TexacoZone.ZoneTimer:Stop()
    end
    TexacoZone = nil
end

function ArcoRepositionCheckAndSet(coord, heading, leg, zone)
    if not isArcoRepositionAllowed() then
        MESSAGE:New("Players currently near the tanker. Try again later.", 10):ToAll()
        return
    end
    setArcoRacetrack(coord, heading, leg, zone)
	return true
end

function TexacoRepositionCheckAndSet(coord, heading, leg, zone)
    if not isTexacoRepositionAllowed() then
        MESSAGE:New("Players currently near the tanker. Try again later.", 10):ToAll()
        return
    end
    setTexacoRacetrack(coord, heading, leg, zone)
	return true
end

function isArcoRepositionAllowed()
    if not ArcoGroup then return true end
    local u = ArcoGroup:GetUnit(1)
    if not u or not u:IsAlive() then return true end
    local tv = u:GetPointVec3()
    local occupied = false
    BlueClients:ForEachClient(function(client)
        if occupied then return end
        if client:IsAlive() then
            local pv = client:GetPointVec3()
            if math.abs(pv.y - tv.y) <= ARCO_PROX_ALT_M then
                local dx = pv.x - tv.x
                local dz = pv.z - tv.z
                if (dx*dx + dz*dz) <= (ARCO_PROX_RADIUS_M*ARCO_PROX_RADIUS_M) then
                    occupied = true
                end
            end
        end
    end)
    return not occupied
end

function isTexacoRepositionAllowed()
    if not TexacoGroup then return true end
    local u = TexacoGroup:GetUnit(1)
    if not u or not u:IsAlive() then return true end
    local tv = u:GetPointVec3()
    local occupied = false
    BlueClients:ForEachClient(function(client)
        if occupied then return end
        if client:IsAlive() then
            local pv = client:GetPointVec3()
            if math.abs(pv.y - tv.y) <= TEXACO_PROX_ALT_M then
                local dx = pv.x - tv.x
                local dz = pv.z - tv.z
                if (dx*dx + dz*dz) <= (TEXACO_PROX_RADIUS_M*TEXACO_PROX_RADIUS_M) then
                    occupied = true
                end
            end
        end
    end)
    return not occupied
end

function startArcoProximityWatch()
    if not ArcoGroup then return end
    local u = ArcoGroup:GetUnit(1)
    if not u or not u:IsAlive() then return end
    ArcoZone = ZONE_UNIT:New("Arco_Prox", u, ARCO_PROX_RADIUS_M)
    ArcoZone.OnAfterEnteredZone = function(self, From, Event, To, triggeringClient)
        if not triggeringClient then return end
        local cu = triggeringClient:GetPointVec3()
        local tu = u:GetPointVec3()
        if math.abs(cu.y - tu.y) <= ARCO_PROX_ALT_M then
            MESSAGE:New("Approaching Arco, BTN 14, 260.00", 20):ToClient(triggeringClient)
        end
    end
    ArcoZone:Trigger(BlueClients)
end

function startTexacoProximityWatch()
    if not TexacoGroup then return end
    local u = TexacoGroup:GetUnit(1)
    if not u or not u:IsAlive() then return end
    TexacoZone = ZONE_UNIT:New("Texaco_Prox", u, TEXACO_PROX_RADIUS_M)
    TexacoZone.OnAfterEnteredZone = function(self, From, Event, To, triggeringClient)
        if not triggeringClient then return end
        local cu = triggeringClient:GetPointVec3()
        local tu = u:GetPointVec3()
        if math.abs(cu.y - tu.y) <= TEXACO_PROX_ALT_M then
            MESSAGE:New("Approaching Texaco, BTN 20, 266.00", 20):ToClient(triggeringClient)
        end
    end
    TexacoZone:Trigger(BlueClients)
end

function setTexacoRacetrack(coord, heading, leg, zone)
    if not TexacoGroup then return end
    local currentMission = TexacoGroup:GetMissionCurrent()
    if currentMission then
        currentMission:__Cancel(5)
    end
    local TexacoTanker2 = AUFTRAG:NewTANKER(coord, 16000, 380, heading, leg)
    TexacoGroup:AddMission(TexacoTanker2)
	function TexacoTanker2:OnAfterStarted(From, Event, To)
		TexacoGroup:SetAltitude(4876)
	end
	function TexacoTanker2:OnAfterExecuting(From, Event, To)
		if leg == 0 then
			if zone then
				trigger.action.outTextForCoalition(2, "Texaco: Orbiting at " .. zone, 10)
			else
				trigger.action.outTextForCoalition(2, "Texaco: Orbiting", 10)
			end
		else
			if zone then
				trigger.action.outTextForCoalition(2, "Texaco: Racetrack at " .. zone .. " with heading " .. heading .. "° and leg distance " .. leg .. " NM", 10)
			else
				trigger.action.outTextForCoalition(2, "Texaco: Racetrack with heading " .. heading .. "° and leg distance " .. leg .. " NM", 10)
			end
		end
	end
end




function setArcoRacetrack(coord, heading, leg, zone)
    if not ArcoGroup then return end
    local currentMission = ArcoGroup:GetMissionCurrent()
    if currentMission then
        currentMission:__Cancel(5)
    end
    local ArcoTanker2 = AUFTRAG:NewTANKER(coord, 18000, 380, heading, leg)
    ArcoGroup:AddMission(ArcoTanker2)
	function ArcoTanker2:OnAfterStarted(From, Event, To)
		ArcoGroup:SetAltitude(5486)
	end
	function ArcoTanker2:OnAfterExecuting(From, Event, To)
		if leg == 0 then
			if zone then
				trigger.action.outTextForCoalition(2, "Arco: Orbiting at " .. zone, 10)
			else
				trigger.action.outTextForCoalition(2, "Arco: Orbiting", 10)
			end
		else
			if zone then
				trigger.action.outTextForCoalition(2, "Arco: Racetrack at " .. zone .. " with heading " .. heading .. "° and leg distance " .. leg .. " NM", 10)
			else
				trigger.action.outTextForCoalition(2, "Arco: Racetrack with heading " .. heading .. "° and leg distance " .. leg .. " NM", 10)
			end
		end
	end
end

capPositionDirections = {["Reposition 360"] = 360, ["Reposition 045"] = 45, ["Reposition 090"] = 90, ["Reposition 135"] = 135, ["Reposition 180"] = 180, ["Reposition 225"] = 225, ["Reposition 270"] = 270, ["Reposition 315"] = 315}
capPositionDistances = {["0 NM"] = 0,["10 NM"] = 10, ["20 NM"] = 20, ["30 NM"] = 30, ["40 NM"] = 40, ["50 NM"] = 50, ["60 NM"] = 60, ["70 NM"] = 70, ["80 NM"] = 80, ["90 NM"] = 90, ["100 NM"] = 100}

destroyCasMenuItem = nil
destroySeadMenuItem = nil
destroyDecoyMenuItem = nil
destroyBomberMenuItem = nil
destroyStructureMenuItem = nil
------------------------------------------------------ Dynamic Shop -----------------------------------------------------------

function isZoneSafeForSpawn(friendlyZoneName, minDistNM)
    for _, v in ipairs(bc.zones) do
        if v.side == 1 then -- enemy zone
            local dist_m = ZONE_DISTANCES[friendlyZoneName][v.zone]
            local dist = UTILS.MetersToNM(dist_m)
            if dist and dist < minDistNM then
                --env.info("Blue zone " .. friendlyZoneName .. " is not safe: enemy zone " .. v.zone .. " is only " .. string.format("%.1f", dist) .. " NM away.")
                return false
            end
        end
    end
    return true
end

function findClosestBlueZoneOutside(targetZoneName,minDistNM)
    local bestZone,bestDist=nil,nil
    local altZone,altDist=nil,0
    for _,z in ipairs(bc.zones) do
        if z.side==2 and isZoneSafeForSpawn(z.zone,20) then
            local d=UTILS.MetersToNM(ZONE_DISTANCES[z.zone][targetZoneName])
            if d then
                if d>=minDistNM then
                    if not bestDist or d<bestDist then
                        bestZone,bestDist=z.zone,d
                    end
                elseif d>altDist then
                    altZone,altDist=z.zone,d
                end
            end
        end
    end
    if bestZone then
        return bestZone,bestDist
    else
        return altZone,altDist
    end
end
-- cap
function buildCapControlMenu()
    if capControlMenu then
        missionCommands.removeItemForCoalition(2, capControlMenu)
        capControlMenu = nil
    end
    capControlMenu = missionCommands.addSubMenuForCoalition(2, "Dynamic Control")

    if not (capActive or casActive or seadActive or decoyActive or bomberActive or StructureActive or ArcoActive or TexacoActive) then
        if capControlMenu then
            missionCommands.removeItemForCoalition(2, capControlMenu)
            capControlMenu = nil
        end
        return
    end

    if destroyCasMenuItem then
        missionCommands.removeItemForCoalition(2, destroyCasMenuItem)
        destroyCasMenuItem = nil
    end
    if casActive then
        destroyCasMenuItem = missionCommands.addCommandForCoalition(2, "CAS: Destroy", capControlMenu, despawnCas)
    end

    if destroyBomberMenuItem then
        missionCommands.removeItemForCoalition(2, destroyBomberMenuItem)
        destroyBomberMenuItem = nil
    end
    if bomberActive then
        destroyBomberMenuItem = missionCommands.addCommandForCoalition(2, "Bomber: Destroy", capControlMenu, despawnBomber)
    end

    if destroySeadMenuItem then
        missionCommands.removeItemForCoalition(2, destroySeadMenuItem)
        destroySeadMenuItem = nil
    end
    if seadActive then
        destroySeadMenuItem = missionCommands.addCommandForCoalition(2, "SEAD: Destroy", capControlMenu, despawnSead)
    end

    if destroyDecoyMenuItem then
        missionCommands.removeItemForCoalition(2, destroyDecoyMenuItem)
        destroyDecoyMenuItem = nil
    end
    if decoyActive then
        destroyDecoyMenuItem = missionCommands.addCommandForCoalition(2, "DECOY: Destroy", capControlMenu, despawnDecoy)
    end

    if destroyStructureMenuItem then
        missionCommands.removeItemForCoalition(2, destroyStructureMenuItem)
        destroyStructureMenuItem = nil
    end
    if StructureActive then
        destroyStructureMenuItem = missionCommands.addCommandForCoalition(2, "Building strike: Destroy", capControlMenu, despawnStructure)
    end

    if capActive then
        local capSubMenu = missionCommands.addSubMenuForCoalition(2, "CAP Control", capControlMenu)
        missionCommands.addCommandForCoalition(2, "CAP: Destroy", capSubMenu, despawnCap)
        missionCommands.addCommandForCoalition(2, "CAP: Hold Racetrack", capSubMenu, function()
            if capGroup then
                capGroup:SwitchROE(2)
            end
            MESSAGE:New("CAP is set to (Engage If Engaged)", 15):ToAll()
        end)
        missionCommands.addCommandForCoalition(2, "CAP: Flightsweep", capSubMenu, function()
            if capGroup then
                capGroup:SwitchROE(1)
            end
            MESSAGE:New("CAP set to Engage All", 15):ToAll()
        end)

        local zoneMenu = missionCommands.addSubMenuForCoalition(2, "CAP: Reposition by Zone", capSubMenu)
        local count = 0
        local sub1
        for _, wrap in ipairs(orderedZones(2, nil, true)) do
            local v = wrap.z
            local zoneSubMenu
            count = count + 1
            if count < 10 then
                zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, zoneMenu)
            elseif count == 10 then
                sub1 = missionCommands.addSubMenuForCoalition(2, "More", zoneMenu)
                zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, sub1)
            elseif count % 9 == 1 then
                sub1 = missionCommands.addSubMenuForCoalition(2, "More", sub1)
                zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, sub1)
            else
                zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, sub1)
            end
            for _, headingName in ipairs({"Orbit","Hot 360","Hot 045","Hot 090","Hot 135","Hot 180","Hot 225","Hot 270","Hot 315"}) do
                if headingName == "Orbit" then
                    missionCommands.addCommandForCoalition(2, headingName, zoneSubMenu, function()
                        local zone = ZONE:FindByName(v.zone)
                        if not zone then return end
                        local coord = zone:GetCoordinate()
                        setCapRacetrack(coord, 045, 0, v.zone)
                        MESSAGE:New("CAP is en route to " .. v.zone .. ".", 20):ToAll()
                    end)
                else
                    local headingVal = capHeadings[headingName]
                    local headingMenu = missionCommands.addSubMenuForCoalition(2, headingName, zoneSubMenu)
                    for _, legName in ipairs({"Orbit","10 NM Leg","20 NM Leg","30 NM Leg","40 NM Leg","50 NM Leg"}) do
                        local legVal = capLegs[legName]
                        missionCommands.addCommandForCoalition(2, legName, headingMenu, function()
                            local zone = ZONE:FindByName(v.zone)
                            if not zone then return end
                            local coord = zone:GetCoordinate()
                            setCapRacetrack(coord, headingVal, legVal)
                            MESSAGE:New("CAP is repositioning at " .. v.zone .. " with a new racetrack, heading " .. headingVal .. "°, " .. tostring(legVal) .. " miles leg.", 20):ToAll()
                        end)
                    end
                end
            end
        end

        local posMenu = missionCommands.addSubMenuForCoalition(2, "CAP: Reposition by Position", capSubMenu)
        for _, dirName in ipairs({"Reposition 360", "Reposition 045", "Reposition 090", "Reposition 135", "Reposition 180", "Reposition 225", "Reposition 270", "Reposition 315"}) do
            local dirVal = capPositionDirections[dirName]
            local dirMenu = missionCommands.addSubMenuForCoalition(2, dirName, posMenu)
            for _, distName in ipairs({"0 NM", "10 NM", "20 NM", "30 NM", "40 NM", "50 NM", "60 NM", "70 NM", "80 NM", "90 NM", "100 NM"}) do
                local distVal = capPositionDistances[distName]
                local distMenu = missionCommands.addSubMenuForCoalition(2, distName, dirMenu)
                for _, headingName in ipairs({"Orbit","Hot 360","Hot 045","Hot 090","Hot 135","Hot 180","Hot 225","Hot 270","Hot 315"}) do
                    if headingName == "Orbit" then
                        missionCommands.addCommandForCoalition(2, headingName, distMenu, function()
                            if capGroup then
                                local offsetCoord = capGroup:GetCoordinate():Translate(UTILS.NMToMeters(distVal), dirVal, true)
                                setCapRacetrack(offsetCoord, 045, 0)
                                MESSAGE:New("CAP is about to " .. dirName .. " for " .. distName .. " and orbit.", 20):ToAll()
                            end
                        end)
                    else
                        local headingVal = capHeadings[headingName]
                        local headingMenu = missionCommands.addSubMenuForCoalition(2, headingName, distMenu)
                        for _, legName in ipairs({"Orbit", "10 NM Leg", "20 NM Leg", "30 NM Leg", "40 NM Leg", "50 NM Leg"}) do
                            local legVal = capLegs[legName]
                            missionCommands.addCommandForCoalition(2, legName, headingMenu, function()
                                if capGroup then
                                    local offsetCoord = capGroup:GetCoordinate():Translate(UTILS.NMToMeters(distVal), dirVal, true)
                                    setCapRacetrack(offsetCoord, headingVal, legVal)
                                    MESSAGE:New("CAP is about to " .. dirName .. " " .. distName .. " with a new racetrack, heading " .. headingVal .. "°, " .. tostring(legVal) .. " miles leg.", 20):ToAll()
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
	local tankersMenu
	if ArcoActive or TexacoActive then
		tankersMenu = missionCommands.addSubMenuForCoalition(2, "Dynamic Tankers", capControlMenu)
	end
	if ArcoActive then
		local zoneMenu = missionCommands.addSubMenuForCoalition(2, "Arco (Drogue): Reposition by Zone", tankersMenu)
		local count = 0
		local sub1
		for _, wrap in ipairs(orderedZones(2, nil, false)) do
			local v = wrap.z
			local zoneSubMenu
			count = count + 1
			if count < 10 then
				zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, zoneMenu)
			elseif count == 10 then
				sub1 = missionCommands.addSubMenuForCoalition(2, "More", zoneMenu)
				zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, sub1)
			elseif count % 9 == 1 then
				sub1 = missionCommands.addSubMenuForCoalition(2, "More", sub1)
				zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, sub1)
			else
				zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, sub1)
			end
			for _, headingName in ipairs({"Orbit","Hot 360","Hot 045","Hot 090","Hot 135","Hot 180","Hot 225","Hot 270","Hot 315"}) do
				if headingName == "Orbit" then
					missionCommands.addCommandForCoalition(2, headingName, zoneSubMenu, function()
						local zone = ZONE:FindByName(v.zone)
						if not zone then return end
						local coord = zone:GetCoordinate()
						if ArcoRepositionCheckAndSet(coord, 045, 0, v.zone) then
							MESSAGE:New("Arco is en route to " .. v.zone .. ".", 20):ToAll()
						end
					end)
				else
					local headingVal = capHeadings[headingName]
					local headingMenu = missionCommands.addSubMenuForCoalition(2, headingName, zoneSubMenu)
					for _, legName in ipairs({"Orbit","10 NM Leg","20 NM Leg","30 NM Leg","40 NM Leg","50 NM Leg"}) do
						local legVal = capLegs[legName]
						missionCommands.addCommandForCoalition(2, legName, headingMenu, function()
							local zone = ZONE:FindByName(v.zone)
							if not zone then return end
							local coord = zone:GetCoordinate()
							if ArcoRepositionCheckAndSet(coord, headingVal, legVal) then
								MESSAGE:New("Arco is repositioning to " .. v.zone .. " with a new racetrack, heading " .. headingVal .. "°, " .. tostring(legVal) .. " miles leg.", 20):ToAll()
							end
						end)
					end
				end
			end
		end

		local posMenu = missionCommands.addSubMenuForCoalition(2, "Arco (Drogue): Reposition by Position", tankersMenu)
		for _, dirName in ipairs({"Reposition 360", "Reposition 045", "Reposition 090", "Reposition 135", "Reposition 180", "Reposition 225", "Reposition 270", "Reposition 315"}) do
			local dirVal = capPositionDirections[dirName]
			local dirMenu = missionCommands.addSubMenuForCoalition(2, dirName, posMenu)
			for _, distName in ipairs({"0 NM", "10 NM", "20 NM", "30 NM", "40 NM", "50 NM", "60 NM", "70 NM", "80 NM", "90 NM", "100 NM"}) do
				local distVal = capPositionDistances[distName]
				local distMenu = missionCommands.addSubMenuForCoalition(2, distName, dirMenu)
				for _, headingName in ipairs({"Orbit","Hot 360","Hot 045","Hot 090","Hot 135","Hot 180","Hot 225","Hot 270","Hot 315"}) do
					if headingName == "Orbit" then
						missionCommands.addCommandForCoalition(2, headingName, distMenu, function()
							if ArcoGroup then
								local offsetCoord = ArcoGroup:GetCoordinate():Translate(UTILS.NMToMeters(distVal), dirVal, true)
								if ArcoRepositionCheckAndSet(offsetCoord, 045, 0) then
									MESSAGE:New("Arco is about to " .. dirName .. " for " .. distName .. " and orbit.", 20):ToAll()
								end
							end
						end)
					else
						local headingVal = capHeadings[headingName]
						local headingMenu = missionCommands.addSubMenuForCoalition(2, headingName, distMenu)
						for _, legName in ipairs({"Orbit","10 NM Leg","20 NM Leg","30 NM Leg","40 NM Leg","50 NM Leg"}) do
							local legVal = capLegs[legName]
							missionCommands.addCommandForCoalition(2, legName, headingMenu, function()
								if ArcoGroup then
									local offsetCoord = ArcoGroup:GetCoordinate():Translate(UTILS.NMToMeters(distVal), dirVal, true)
									if ArcoRepositionCheckAndSet(offsetCoord, headingVal, legVal) then
										MESSAGE:New("Arco is about to " .. dirName .. " " .. distName .. " with a new racetrack, heading " .. headingVal .. "°, " .. tostring(legVal) .. " miles leg.", 20):ToAll()
									end
								end
							end)
							
						end
					end
				end
			end
		end
		missionCommands.addCommandForCoalition(2, "Arco: Destroy", tankersMenu, despawnArco)
	end
	if TexacoActive then
		local zoneMenu = missionCommands.addSubMenuForCoalition(2, "Texaco (Boom): Reposition by Zone", tankersMenu)
		local count = 0
		local sub1
		for _, wrap in ipairs(orderedZones(2, nil, false)) do
			local v = wrap.z
			local zoneSubMenu
			count = count + 1
			if count < 10 then
				zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, zoneMenu)
			elseif count == 10 then
				sub1 = missionCommands.addSubMenuForCoalition(2, "More", zoneMenu)
				zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, sub1)
			elseif count % 9 == 1 then
				sub1 = missionCommands.addSubMenuForCoalition(2, "More", sub1)
				zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, sub1)
			else
				zoneSubMenu = missionCommands.addSubMenuForCoalition(2, wrap.disp, sub1)
			end
			for _, headingName in ipairs({"Orbit","Hot 360","Hot 045","Hot 090","Hot 135","Hot 180","Hot 225","Hot 270","Hot 315"}) do
				if headingName == "Orbit" then
					missionCommands.addCommandForCoalition(2, headingName, zoneSubMenu, function()
						local zone = ZONE:FindByName(v.zone)
						if not zone then return end
						local coord = zone:GetCoordinate()
						if TexacoRepositionCheckAndSet(coord, 045, 0, v.zone) then
							MESSAGE:New("Texaco is en route to " .. v.zone .. ".", 20):ToAll()
						end
					end)
				else
					local headingVal = capHeadings[headingName]
					local headingMenu = missionCommands.addSubMenuForCoalition(2, headingName, zoneSubMenu)
					for _, legName in ipairs({"Orbit","10 NM Leg","20 NM Leg","30 NM Leg","40 NM Leg","50 NM Leg"}) do
						local legVal = capLegs[legName]
						missionCommands.addCommandForCoalition(2, legName, headingMenu, function()
							local zone = ZONE:FindByName(v.zone)
							if not zone then return end
							local coord = zone:GetCoordinate()
							if TexacoRepositionCheckAndSet(coord, headingVal, legVal) then
								MESSAGE:New("Texaco is repositioning to " .. v.zone .. " with a new racetrack, heading " .. headingVal .. "°, " .. tostring(legVal) .. " miles leg.", 20):ToAll()
							end
						end)
					end
				end
			end
		end

		local posMenu = missionCommands.addSubMenuForCoalition(2, "Texaco (Boom): Reposition by Position", tankersMenu)
		for _, dirName in ipairs({"Reposition 360", "Reposition 045", "Reposition 090", "Reposition 135", "Reposition 180", "Reposition 225", "Reposition 270", "Reposition 315"}) do
			local dirVal = capPositionDirections[dirName]
			local dirMenu = missionCommands.addSubMenuForCoalition(2, dirName, posMenu)
			for _, distName in ipairs({"0 NM", "10 NM", "20 NM", "30 NM", "40 NM", "50 NM", "60 NM", "70 NM", "80 NM", "90 NM", "100 NM"}) do
				local distVal = capPositionDistances[distName]
				local distMenu = missionCommands.addSubMenuForCoalition(2, distName, dirMenu)
				for _, headingName in ipairs({"Orbit","Hot 360","Hot 045","Hot 090","Hot 135","Hot 180","Hot 225","Hot 270","Hot 315"}) do
					if headingName == "Orbit" then
						missionCommands.addCommandForCoalition(2, headingName, distMenu, function()
							if TexacoGroup then
								local offsetCoord = TexacoGroup:GetCoordinate():Translate(UTILS.NMToMeters(distVal), dirVal, true)
								if TexacoRepositionCheckAndSet(offsetCoord, 045, 0) then
									MESSAGE:New("Texaco is about to " .. dirName .. " for " .. distName .. " and orbit.", 20):ToAll()
								end
							end
						end)
					else
						local headingVal = capHeadings[headingName]
						local headingMenu = missionCommands.addSubMenuForCoalition(2, headingName, distMenu)
						for _, legName in ipairs({"Orbit","10 NM Leg","20 NM Leg","30 NM Leg","40 NM Leg","50 NM Leg"}) do
							local legVal = capLegs[legName]
							missionCommands.addCommandForCoalition(2, legName, headingMenu, function()
								if TexacoGroup then
									local offsetCoord = TexacoGroup:GetCoordinate():Translate(UTILS.NMToMeters(distVal), dirVal, true)
									if TexacoRepositionCheckAndSet(offsetCoord, headingVal, legVal) then
										MESSAGE:New("Texaco is about to " .. dirName .. " " .. distName .. " with a new racetrack, heading " .. headingVal .. "°, " .. tostring(legVal) .. " miles leg.", 20):ToAll()
									end
								end
							end)
						end
					end
				end
			end
		end
		missionCommands.addCommandForCoalition(2, "Texaco: Destroy", tankersMenu, despawnTexaco)
	end
end



function spawnCapAt(zoneName, heading, leg)
    if capActive then return end
    local zone = ZONE:FindByName(zoneName)
    if not zone then return end
    local coordVec3 = zone:GetCoordinate():GetVec3()
	local SpawnCords = zone:GetCoordinate()
	local coord = COORDINATE:NewFromVec3(coordVec3, heading)
	local capSpawnName = capTemplate .. "_" .. tostring(capSpawnIndex)
		local g = Respawn.SpawnAtPoint( capTemplate, coord, heading, 2, 28000 )
				if not g then return end
	timer.scheduleFunction(function(group, time)
		local spawnedGroup = GROUP:FindByName(group:getName())
        capGroup = FLIGHTGROUP:New(spawnedGroup)
		capGroup:GetGroup():CommandSetUnlimitedFuel(true):SetOptionRadarUsingForContinousSearch(true):SetOptionRadioSilence(true)
		capGroup:SetOutOfAAMRTB(true):SetSpeed(600)
		local homebase, distance = SpawnCords:GetClosestAirbase(0, 2)
		if homebase then
			capGroup:SetHomebase(homebase)
		end
		local formation = 196610
		if leg == 0 then
			capSpeed = 330
			formation = 393217
			-- CapMissionOrbit = AUFTRAG:NewORBIT_CIRCLE_EngageTargets(coord,capAltitude,capSpeed,8,formation,50)
			CapMissionOrbit = AUFTRAG:NewORBIT_CIRCLE(coord, capAltitude, capSpeed)
			CapMissionOrbit.missionTask=ENUMS.MissionTask.CAP
			CapMissionOrbit:SetEngageDetected(40, {"Air"})
			CapMissionOrbit:SetROT(2)
			CapMissionOrbit:SetROE(2)
			CapMissionOrbit:SetFormation(196610)
			capGroup:AddMission(CapMissionOrbit)
			capGroup:MissionStart(CapMissionOrbit)
		else
			local capSpeed = 350
			-- CapMissionPatrol = AUFTRAG:NewPATROLRACETRACK_EngageTargets(coord,capAltitude,capSpeed,heading,leg,formation,50)
			CapMissionPatrol = AUFTRAG:NewORBIT(coord, capAltitude, capSpeed, heading, leg)
			CapMissionPatrol.missionTask=ENUMS.MissionTask.CAP
			CapMissionPatrol:SetEngageDetected(40, {"Air"})
			CapMissionPatrol:SetROT(2)
			CapMissionPatrol:SetROE(2)
			CapMissionPatrol:SetFormation(196610)
			capGroup:AddMission(CapMissionPatrol)
			capGroup:MissionStart(CapMissionPatrol)
		end

		function capGroup:OnAfterLanded(From, Event, To)
    	self:ScheduleOnce(5, function() self:Destroy() end)
		end
		function capGroup:OnAfterOutOfMissilesAA(From, Event, To)
			if capGroup then
			capGroup:SwitchROE(2)
			trigger.action.outText("CAP is out of missiles, returning to base", 20)
			end
		end
		
		function capGroup:OnAfterDead(From, Event, To)
			local landed = (From=="Landed") or (From=="Arrived")
			capGroup:__Stop(1)
			capGroup  = nil
			capActive = false
			buildCapControlMenu()
			if landed then
				trigger.action.outText("CAP group have landed", 20)
			else
				trigger.action.outText("CAP group have been killed", 20)
			end
		end

		local msg = (leg == 0)
            and ("CAP on station orbiting at " .. zoneName .. ".")
            or  ("CAP on station at " .. zoneName .. ", setting up racetrack " .. heading .. "°, " .. tostring(leg) .. " miles leg.")
		MESSAGE:New(msg, 20):ToAll()

		if capParentMenu then
		missionCommands.removeItemForCoalition(2, capParentMenu)
		capParentMenu = nil
		end
	end, g, timer.getTime() + 1)
    capActive = true
	buildCapControlMenu()


	capSpawnIndex = capSpawnIndex + 1
end



	function buildCapMenu()
		if capParentMenu then
			missionCommands.removeItemForCoalition(2, capParentMenu)
			capParentMenu = nil
		end
		capParentMenu = missionCommands.addSubMenuForCoalition(2, "Request CAP from")
		local count = 0
		local sub1
		local zoneMenu
		for _, wrap in ipairs(orderedZones(2)) do
			local v = wrap.z
			local zoneName = v.zone
			local zoneDisplayName = wrap.disp
			count = count + 1
			if count < 10 then
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, capParentMenu)
			elseif count == 10 then
				sub1 = missionCommands.addSubMenuForCoalition(2, "More", capParentMenu)
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, sub1)
			elseif count % 9 == 1 then
				sub1 = missionCommands.addSubMenuForCoalition(2, "More", sub1)
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, sub1)
			else
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, sub1)
			end
			for _, headingName in ipairs({ "Orbit", "Hot 360", "Hot 045", "Hot 090", "Hot 135", "Hot 180", "Hot 225", "Hot 270", "Hot 315" }) do
				if headingName == "Orbit" then
					missionCommands.addCommandForCoalition(2, headingName, zoneMenu, function()
						spawnCapAt(zoneName, 045, 0)
					end)
				else
					local headingVal = capHeadings[headingName]
					local headingMenu = missionCommands.addSubMenuForCoalition(2, headingName, zoneMenu)
					for _, legName in ipairs({ "10 NM Leg", "20 NM Leg", "30 NM Leg", "40 NM Leg", "50 NM Leg" }) do
						local legVal = capLegs[legName]
						missionCommands.addCommandForCoalition(2, legName, headingMenu, function()
							spawnCapAt(zoneName, headingVal, legVal)
						end)
					end
				end
			end
		end
	end
-------------------------------------------------------- Dynamic Tankers -----------------------------------------------------
--Arco

function spawnArcoAt(zoneName, heading, leg)
    if ArcoActive then return end
    local zone = ZONE:FindByName(zoneName)
    if not zone then return end
    local coordVec3 = zone:GetCoordinate():GetVec3()
	local SpawnCords = zone:GetCoordinate()
	local coord = COORDINATE:NewFromVec3(coordVec3, heading)
		local g = Respawn.SpawnAtPoint( 'Arco', coord, heading, 2, 18000, 286 )
				if not g then return end
	timer.scheduleFunction(function(group, time)
		local spawnedGroup = GROUP:FindByName(group:getName())
        ArcoGroup = FLIGHTGROUP:New(spawnedGroup)
		--:CommandSetUnlimitedFuel(true)
		ArcoGroup:GetGroup():CommandSetInvisible(true):CommandSetImmortal(true)
		ArcoGroup:SetDefaultTACAN("101", "ARC", "Arco", "Y")
		local homebase, distance = SpawnCords:GetClosestAirbase(0, 2)
		if homebase then
			ArcoGroup:SetHomebase(homebase)
		end
		local speed
		if leg == 0 then 
		speed = 280
		else
		speed = 286
		end
		function ArcoGroup:OnAfterFuelLow(From, Event, To)
			trigger.action.outText("Arco is low on fuel, returning to base", 20)
		end
		ArcoTanker = AUFTRAG:NewTANKER(coord, 18000, speed, heading, leg)
		--ArcoTanker:SetTACAN(101, "ARCO", "Arco", "Y")
		ArcoGroup:AddMission(ArcoTanker)
		ArcoGroup:MissionStart(ArcoTanker)
		startArcoProximityWatch()

		function ArcoGroup:OnAfterLanded(From, Event, To)
    	self:ScheduleOnce(5, function() self:Destroy() end)
		end
	
		function ArcoGroup:OnAfterDead(From, Event, To)
			stopArcoProximityWatch()
			local landed = (From=="Landed") or (From=="Arrived")
			ArcoGroup:__Stop(1)
			ArcoGroup  = nil
			ArcoActive = false
			buildCapControlMenu()
			if landed then
				trigger.action.outText("Arco have landed", 20)
			else
				trigger.action.outText("Arco have been killed", 20)
			end
		end

		local msg = (leg == 0)
            and ("Arco (BTN-14, 260.00, TCN 101Y)\nOn station orbiting at " .. zoneName .. ".")
            or  ("Arco (BTN-14, 260.00, TCN 101Y)\nOn station at " .. zoneName .. ", setting up racetrack " .. heading .. "°, " .. tostring(leg) .. " miles leg.")
		MESSAGE:New(msg, 20):ToAll()

		if ArcoParentMenu then
		missionCommands.removeItemForCoalition(2, ArcoParentMenu)
		ArcoParentMenu = nil
		end
	end, g, timer.getTime() + 1)
    ArcoActive = true
	buildCapControlMenu()

	ArcoSpawnIndex = ArcoSpawnIndex + 1
end



	function buildArcoMenu()
		if ArcoParentMenu then
			missionCommands.removeItemForCoalition(2, ArcoParentMenu)
			ArcoParentMenu = nil
		end
		ArcoParentMenu = missionCommands.addSubMenuForCoalition(2, "Request (Drogue) tanker from")
		local count = 0
		local sub1
		local zoneMenu
		for _, wrap in ipairs(orderedZones(2)) do
			local v = wrap.z
			local zoneName = v.zone
			local zoneDisplayName = wrap.disp
			count = count + 1
			if count < 10 then
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, ArcoParentMenu)
			elseif count == 10 then
				sub1 = missionCommands.addSubMenuForCoalition(2, "More", ArcoParentMenu)
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, sub1)
			elseif count % 9 == 1 then
				sub1 = missionCommands.addSubMenuForCoalition(2, "More", sub1)
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, sub1)
			else
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, sub1)
			end
			for _, headingName in ipairs({ "Orbit", "Hot 360", "Hot 045", "Hot 090", "Hot 135", "Hot 180", "Hot 225", "Hot 270", "Hot 315" }) do
				if headingName == "Orbit" then
					missionCommands.addCommandForCoalition(2, headingName, zoneMenu, function()
						spawnArcoAt(zoneName, 045, 0)
					end)
				else
					local headingVal = capHeadings[headingName]
					local headingMenu = missionCommands.addSubMenuForCoalition(2, headingName, zoneMenu)
					for _, legName in ipairs({ "10 NM Leg", "20 NM Leg", "30 NM Leg", "40 NM Leg", "50 NM Leg" }) do
						local legVal = capLegs[legName]
						missionCommands.addCommandForCoalition(2, legName, headingMenu, function()
							spawnArcoAt(zoneName, headingVal, legVal)
						end)
					end
				end
			end
		end
	end


-- Texaco

function spawnTexacoAt(zoneName, heading, leg)
    if TexacoActive then return end
    local zone = ZONE:FindByName(zoneName)
    if not zone then return end
    local coordVec3 = zone:GetCoordinate():GetVec3()
	local SpawnCords = zone:GetCoordinate()
	local coord = COORDINATE:NewFromVec3(coordVec3, heading)
		local g = Respawn.SpawnAtPoint( 'Texaco', coord, heading, 2, 16000, 286 )
				if not g then return end
	timer.scheduleFunction(function(group, time)
		local spawnedGroup = GROUP:FindByName(group:getName())
        TexacoGroup = FLIGHTGROUP:New(spawnedGroup)
		--:CommandSetUnlimitedFuel(true)
		TexacoGroup:GetGroup():CommandSetImmortal(true):CommandSetInvisible(true)
		TexacoGroup:SetDefaultTACAN("102", "TEX", "Texaco", "Y")
		local homebase, distance = SpawnCords:GetClosestAirbase(0, 2)
		if homebase then
			TexacoGroup:SetHomebase(homebase)
		end
		function TexacoGroup:OnAfterFuelLow(From, Event, To)
			trigger.action.outText("Texaco is low on fuel, returning to base", 20)
		end
		local speed
		if leg == 0 then 
		speed = 280
		else
		speed = 286
		end
		TexacoTanker = AUFTRAG:NewTANKER(coord, 16000, speed, heading, leg)
		--TexacoTanker:SetTACAN(102, "TEX", "Texaco", "Y")
		TexacoGroup:AddMission(TexacoTanker)
		TexacoGroup:MissionStart(TexacoTanker)
		startTexacoProximityWatch()

		function TexacoGroup:OnAfterLanded(From, Event, To)
    	self:ScheduleOnce(5, function() self:Destroy() end)
		end

		function TexacoGroup:OnAfterDead(From, Event, To)
			stopTexacoProximityWatch()
			local landed = (From=="Landed") or (From=="Arrived")
			TexacoGroup:__Stop(1)
			TexacoGroup  = nil
			TexacoActive = false
			buildCapControlMenu()
			if landed then
				trigger.action.outText("Texaco have landed", 20)
			else
				trigger.action.outText("Texaco have been killed", 20)
			end
		end

		local msg = (leg == 0)
            and ("Texaco (BTN-20, 266.00, TCN 102Y)\non station orbiting at " .. zoneName .. ".")
            or  ("Texaco (BTN-20, 266.00, TCN 102Y)\non station at " .. zoneName .. ", setting up racetrack " .. heading .. "°, " .. tostring(leg) .. " miles leg.")
		MESSAGE:New(msg, 20):ToAll()

		if TexacoParentMenu then
		missionCommands.removeItemForCoalition(2, TexacoParentMenu)
		TexacoParentMenu = nil
		end
	end, g, timer.getTime() + 1)
    TexacoActive = true
	buildCapControlMenu()

end



	function buildTexacoMenu()
		if TexacoParentMenu then
			missionCommands.removeItemForCoalition(2, TexacoParentMenu)
			TexacoParentMenu = nil
		end
		TexacoParentMenu = missionCommands.addSubMenuForCoalition(2, "Request Texaco (Boom) tanker from")
		local count = 0
		local sub1
		local zoneMenu
		for _, wrap in ipairs(orderedZones(2)) do
			local v = wrap.z
			local zoneName = v.zone
			local zoneDisplayName = wrap.disp
			count = count + 1
			if count < 10 then
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, TexacoParentMenu)
			elseif count == 10 then
				sub1 = missionCommands.addSubMenuForCoalition(2, "More", TexacoParentMenu)
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, sub1)
			elseif count % 9 == 1 then
				sub1 = missionCommands.addSubMenuForCoalition(2, "More", sub1)
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, sub1)
			else
				zoneMenu = missionCommands.addSubMenuForCoalition(2, zoneDisplayName, sub1)
			end
			for _, headingName in ipairs({ "Orbit", "Hot 360", "Hot 045", "Hot 090", "Hot 135", "Hot 180", "Hot 225", "Hot 270", "Hot 315" }) do
				if headingName == "Orbit" then
					missionCommands.addCommandForCoalition(2, headingName, zoneMenu, function()
						spawnTexacoAt(zoneName, 045, 0)
					end)
				else
					local headingVal = capHeadings[headingName]
					local headingMenu = missionCommands.addSubMenuForCoalition(2, headingName, zoneMenu)
					for _, legName in ipairs({ "10 NM Leg", "20 NM Leg", "30 NM Leg", "40 NM Leg", "50 NM Leg" }) do
						local legVal = capLegs[legName]
						missionCommands.addCommandForCoalition(2, legName, headingMenu, function()
							spawnTexacoAt(zoneName, headingVal, legVal)
						end)
					end
				end
			end
		end
	end

-- Cas
casActive = false
casGroup = nil
casTemplate = (Era == 'Coldwar') and 'DynamicCas_Template_CW' or 'DynamicCas_Template'
casSpawnIndex = 7
CASTargetMenu = nil

function despawnCas()
  if casGroup then
    casGroup:Despawn()
  end
end


function spawnCasAt(zoneName, targetZoneName, offsetNM)
    if casActive then return end
    local zone = ZONE:FindByName(zoneName)
    local targetZone = ZONE:FindByName(targetZoneName)
    if not zone or not targetZone then return end
    local coord = zone:GetCoordinate()
	local SpawnCords = zone:GetCoordinate()
	coord:SetAltitude(7620)
    local targetCoord = targetZone:GetCoordinate()
    local heading = coord:GetAngleDegrees(coord:GetDirectionVec3(targetCoord))
	if offsetNM and offsetNM > 0 then
	coord = coord:Translate(UTILS.NMToMeters(offsetNM), heading + 180, true)
	end
    local casSpawnName = casTemplate .. tostring(casSpawnIndex)
    local tpl = UTILS.DeepCopy(_DATABASE.Templates.Groups[casTemplate].Template)
    local casSpawn = SPAWN:NewFromTemplate(tpl, casSpawnName, nil, true)
   casSpawn:InitHeading(heading):InitSkill("Excellent"):OnSpawnGroup(function(spawnedGroup)
	casGroup = FLIGHTGROUP:New(spawnedGroup)
	casGroup:GetGroup():CommandSetUnlimitedFuel(true):SetOptionRadioSilence(true)
	casGroup:SetOutOfAGMRTB(true):SetSpeed(600)
	local homebase, distance = SpawnCords:GetClosestAirbase(0, 2)
	if homebase then
		casGroup:SetHomebase(homebase)
	end
    local setGroup   = SET_GROUP:New()
    local setStatic = SET_STATIC:New()
    local zn = bc:getZoneByName(targetZoneName)
    if zn.built then
        for _, v in pairs(zn.built) do
            local grp = GROUP:FindByName(v)
            if grp then
                setGroup:AddGroup(grp)
            end
            local st = STATIC:FindByName(v,false)
            if st then
                setStatic:AddStatic(st)
            end
        end
    end

local CasMission = AUFTRAG:NewBAI(setGroup, 27000)
	CasMission.missionWaypointOffsetNM= 14
	CasMission:SetMissionAltitude(27000)
	CasMission:AddConditionSuccess(function() return bc:getZoneByName(targetZoneName).side == 0 end)
	CasMission:SetWeaponExpend(AI.Task.WeaponExpend.ONE)
	CasMission:SetEngageAsGroup(false)
	CasMission:SetMissionSpeed(700)
	casGroup:AddMission(CasMission)
	casGroup:MissionStart(CasMission)
	function CasMission:OnAfterExecuting(From, Event, To)
		casGroup:SwitchROE(2)
		CasMission:SetFormation(131075)
		CasMission:SetMissionSpeed(380)
	end
	function CasMission:OnAfterSuccess(From, Event, To)
		if setStatic:Count() < 0 then
			trigger.action.outTextForCoalition(2, "CAS group has successfully completed its mission", 15)
		end
	end
if setStatic:Count() > 0 then
    local auftragstatic = AUFTRAG:NewBAI(setStatic, 25000)
	auftragstatic.missionWaypointOffsetNM = 14
	auftragstatic:SetWeaponExpend(AI.Task.WeaponExpend.ONE)
	auftragstatic:SetEngageAsGroup(false)
	auftragstatic:SetMissionSpeed(600)
	casGroup:AddMission(auftragstatic)
	function auftragstatic:OnAfterExecuting(From, Event, To)
		casGroup:SwitchROE(1)
		auftragstatic:SetFormation(131075)
		auftragstatic:SetMissionSpeed(380)
	end
	function auftragstatic:OnAfterSuccess(From, Event, To)
		trigger.action.outTextForCoalition(2, "CAS group has successfully completed its mission", 15)
	end
end
	function casGroup:OnAfterLanded(From, Event, To)
		self:ScheduleOnce(5, function() self:Destroy() end)
	end
	function casGroup:OnAfterOutOfMissilesAG(From, Event, To)
		if casGroup then
		casGroup:SwitchROE(2)
		trigger.action.outTextForCoalition(2, "CAS group is Winchester, returning to base", 15)
		end
	end
	function casGroup:OnAfterDead(From, Event, To)
		local landed = (From=="Landed") or (From=="Arrived")
		casGroup:__Stop(1)
		casGroup = nil
		casActive = false
		buildCapControlMenu()
		if landed then
			trigger.action.outText("CAS group have landed",20)
		else
			trigger.action.outText("CAS group have been killed",20)
		end
	end

    trigger.action.outTextForCoalition(2, "CAS flight launched from " .. zoneName .. " to attack " .. targetZoneName, 15)
	end)
    casGroup = nil
    casActive = true
    casSpawn:SpawnFromCoordinate(coord)
    casSpawnIndex = casSpawnIndex + 1
	buildCapControlMenu()
end
-- decoy
decoyActive = false
decoyGroup = nil
decoyTemplate = (Era == 'Coldwar') and "DynamicDecoy_Template_CW" or 'DynamicDecoy_Template'
decoySpawnIndex = 1
DECOYTargetMenu = nil
function despawnDecoy()
  if decoyGroup then
    decoyGroup:Despawn()
  end
end

function getMinNMForZone(targetZoneName)
    local minNM = 40
    local zn = bc:getZoneByName(targetZoneName)
    if zn and zn.built then
        for _, v in pairs(zn.built) do
            local g = GROUP:FindByName(v)
            if g then
                local tn = g:GetTypeName() or ""
                if tn:find("RPC_5N62V") then
                    minNM = 80
                    break
                end
            end
        end
    end
    return minNM
end


function spawnDecoyAt(zoneName, targetZoneName, offsetNM, altitude)
	if decoyActive then return end
	if not altitude then altitude = 30000 end
    local zone = ZONE:FindByName(zoneName)
    local targetZone = ZONE:FindByName(targetZoneName)
    if not zone or not targetZone then return end
    local coord = zone:GetCoordinate()
    local SpawnCords = zone:GetCoordinate()
    local targetCoord = targetZone:GetCoordinate()
    local heading = coord:GetAngleDegrees(coord:GetDirectionVec3(targetCoord))
	if offsetNM and offsetNM > 0 then
	coord = coord:Translate(UTILS.NMToMeters(offsetNM), heading + 180, true)
	end
	local g = Respawn.SpawnAtPoint( decoyTemplate, coord, heading, 5 ,altitude,600)
	if not g then return end
	timer.scheduleFunction(function(group, time)
    decoyGroup = FLIGHTGROUP:New(group:getName())
	decoyGroup:GetGroup():SetOptionRadioSilence(true)
    local homebase, distance = SpawnCords:GetClosestAirbase(0, 2)
    if homebase then
        decoyGroup:SetHomebase(homebase)
    end
    local decoyTargets = SET_GROUP:New()
    local zn = bc:getZoneByName(targetZoneName)
    if zn and zn.built then
        for _, v in pairs(zn.built) do
            local group = GROUP:FindByName(v)
            if group then
                decoyTargets:AddGroup(group)
            end
        end
    end
	local missionAlt = altitude - 1000
	--local DecoyMission = AUFTRAG:NewCASENHANCED(targetZone,27000,550,35,nil,"Air Defence")
	local DecoyMission = AUFTRAG:NewBAI(decoyTargets, missionAlt)
	local offsetNM = 33
	for _, u in pairs(decoyTargets:GetSet()) do
		if string.find(u:GetTypeName(), "40B6M") then
			offsetNM = 35
			break
		elseif string.find(u:GetTypeName(), "RPC_5N62V") then
			offsetNM = 60
			break
		end
	end
	DecoyMission.missionWaypointOffsetNM = offsetNM
	DecoyMission:SetWeaponExpend(AI.Task.WeaponExpend.ALL)
	DecoyMission.engageWeaponType=ENUMS.WeaponType.Any
	DecoyMission:SetMissionSpeed(750)
	DecoyMission:SetEngageAsGroup(true)
	decoyGroup:AddMission(DecoyMission)
	function DecoyMission:OnAfterStarted(From, Event, To)
	DecoyMission:SetFormation(65538)
    end
    function DecoyMission:OnAfterExecuting(From, Event, To)
    -- DecoyMission:SetROE(1)
	DecoyMission:SetMissionSpeed(450)
    end
    function decoyGroup:OnAfterLanded(From, Event, To)
        self:ScheduleOnce(5, function() self:Destroy() end)
    end
	function DecoyMission:OnAfterSuccess(From, Event, To)
		trigger.action.outTextForCoalition(2, "Decoy Group has successfully completed its mission", 15)
	end
    function decoyGroup:OnAfterOutOfMissilesAG(From, Event, To)
		if decoyGroup then
        trigger.action.outTextForCoalition(2, "Decoy Group is now RTB", 15)
		end
    end
    function decoyGroup:OnAfterDead(From, Event, To)
		local landed = (From=="Landed") or (From=="Arrived")
			decoyGroup:__Stop(1)
			decoyActive = false
			decoyGroup = nil
			buildCapControlMenu()
            if landed then
                trigger.action.outText("Decoy group have landed", 20)
            else
                trigger.action.outText("Decoy group have been killed", 20)
            end
        end
    trigger.action.outTextForCoalition(2, "Decoy flight launched from " .. zoneName .. " to attack " .. targetZoneName, 15)
	end, g, timer.getTime() + 1)
    decoyActive = true
    buildCapControlMenu()
end


seadActive = false
seadGroup = nil
seadTemplate = (Era == 'Coldwar') and "DynamicSead_Template_CW" or 'DynamicSead_Template'
local seadSpawnIndex = 1
local SEADTargetMenu = nil


function despawnSead()
  if seadGroup then
    seadGroup:Despawn()
  end
end

function spawnSeadAt(zoneName, targetZoneName, offsetNM,altitude)
    if seadActive then return end
	if not altitude then altitude = 28000 end
    local zone = ZONE:FindByName(zoneName)
    local targetZone = ZONE:FindByName(targetZoneName)
    if not zone or not targetZone then return end
    local coord = zone:GetCoordinate()
    local SpawnCords = zone:GetCoordinate()
    coord:SetAltitude(7620)
    local targetCoord = targetZone:GetCoordinate()
    local heading = coord:GetAngleDegrees(coord:GetDirectionVec3(targetCoord))
	if offsetNM and offsetNM > 0 then
		coord = coord:Translate(UTILS.NMToMeters(offsetNM), heading + 180, true)
	end
    local seadSpawnName = seadTemplate .. tostring(seadSpawnIndex)
    local g = Respawn.SpawnAtPoint(seadTemplate, coord, heading, 5, altitude, 600)
	if not g then return end
	timer.scheduleFunction(function(group, time)
		local SpawnGroup = GROUP:FindByName(group:getName())
		seadGroup = FLIGHTGROUP:New(SpawnGroup)
		seadGroup:GetGroup():CommandSetUnlimitedFuel(true):SetOptionRadioSilence(true)
		seadGroup:SetOutOfAGMRTB(true):SetSpeed(600)
		local homebase, distance = SpawnCords:GetClosestAirbase(0, 2)
		if homebase then
			seadGroup:SetHomebase(homebase)
		end	
		
	local fallbackUnits = {}
	local seadTargets = SET_UNIT:New()
	local zn = bc:getZoneByName(targetZoneName)
	for _, v in pairs(zn.built) do
		local group = GROUP:FindByName(v)
		if group then
				local units = group:GetUnits()
				for _, unit in ipairs(units or {}) do  
				if unit:HasAttribute('SAM TR')
				or unit:HasAttribute('SAM SR')
				or unit:HasAttribute('SR SAM')
				or unit:HasAttribute('MR SAM')
				or unit:HasAttribute('AAA')
				or unit:HasAttribute('LR SAM') then
				seadTargets:AddUnit(unit)
				else
				table.insert(fallbackUnits, unit)
				end
			end
		end	
	end
	seadTargets:ForEachUnit(function(unit)end)
	local missionAlt = altitude - 1000
	local SeadMission
	if seadTargets:Count() > 0 then
		SeadMission = AUFTRAG:NewBAI(seadTargets, missionAlt)
		
	else
		for _, u in ipairs(fallbackUnits) do
			seadTargets:AddUnit(u)
		end
		SeadMission = AUFTRAG:NewBAI(seadTargets, missionAlt)
	end
	if seadTargets:Count() == 0 and #fallbackUnits == 0 then
		trigger.action.outTextForCoalition(2, "No valid SEAD targets in "..targetZoneName.." Refunded 500 credits", 15)
		timer.scheduleFunction(function()
			seadGroup:Despawn()
		end, nil, timer.getTime() + 5)
		bc:addFunds(2, 500)
	else
		local offsetNM = 25
		for _, u in pairs(seadTargets:GetSet()) do
			if string.find(u:GetTypeName(), "40B6M") then
				offsetNM = 35
				break
			elseif string.find(u:GetTypeName(), "RPC_5N62V") then
				offsetNM = 60
				break
			end
		end
		SeadMission.missionWaypointOffsetNM = offsetNM
	end
	fallbackUnits = nil
	SeadMission:SetWeaponExpend(AI.Task.WeaponExpend.ALL)
	SeadMission.engageWeaponType=ENUMS.WeaponType.Any
	SeadMission:SetMissionSpeed(600)
	seadGroup:AddMission(SeadMission)
	function SeadMission:OnAfterExecuting(From, Event, To)
	seadGroup:SwitchROE(1)
	--SeadMission:SetEngageDetected(15)
	seadGroup:SwitchROT(3)
	SeadMission:SetMissionSpeed(450)
	end
	function SeadMission:OnAfterSuccess(From, Event, To)
		trigger.action.outTextForCoalition(2, "SEAD Group has successfully completed its mission", 15)
	end
	function seadGroup:OnAfterLanded(From, Event, To)

		self:ScheduleOnce(5, function() self:Destroy() end)
	end
	function seadGroup:OnAfterOutOfMissilesAG(From, Event, To)
		if seadGroup then
		seadGroup:SwitchROE(2)
		trigger.action.outTextForCoalition(2, "SEAD Group is now RTB", 15)
		end
	end
	function seadGroup:OnAfterDead(From, Event, To)
		local landed = (From=="Landed") or (From=="Arrived")
		seadGroup:__Stop(1)
		seadGroup  = nil
		seadActive = false
		buildCapControlMenu()
		if landed then
			trigger.action.outTextForCoalition(2, "SEAD Group have landed", 15)
		else
			trigger.action.outTextForCoalition(2, "SEAD Group have been killed", 15)
		end
	end
	trigger.action.outTextForCoalition(2, "SEAD flight launched from " .. zoneName .. " to attack " .. targetZoneName, 15)
  end, g, timer.getTime() + 1)
	seadActive = true
	buildCapControlMenu()
    seadSpawnIndex = seadSpawnIndex + 1
end

-- Bomber
bomberActive = false
BomberGroup = nil
bombTemplate = (Era == 'Coldwar') and 'DynamicBomber_Template_CW' or 'DynamicBomber_Template'
bombSpawnIndex = 7
BomberTargetMenu = nil

function despawnBomber()
  if BomberGroup then
    BomberGroup:Despawn()
  end
end


function spawnBomberAt(zoneName, targetZoneName,offsetNM)
    if bomberActive then return end
    local zone = ZONE:FindByName(zoneName)
    local targetZone = ZONE:FindByName(targetZoneName)
    if not zone or not targetZone then return end
    local coord = zone:GetCoordinate()
	local SpawnCords = zone:GetCoordinate()
	coord:SetAltitude(7620)
    local targetCoord = targetZone:GetCoordinate()
    local heading = coord:GetAngleDegrees(coord:GetDirectionVec3(targetCoord))
	if offsetNM and offsetNM > 0 then
	coord = coord:Translate(UTILS.NMToMeters(offsetNM), heading + 180, true)
	end
	local g = Respawn.SpawnAtPoint( bombTemplate, coord, heading, 5 ,27000)
		if not g then return end
	timer.scheduleFunction(function(group, time)
	local SpawnGroup = GROUP:FindByName(group:getName())
	BomberGroup = FLIGHTGROUP:New(SpawnGroup)
	BomberGroup:GetGroup():SetOptionRadioSilence(true)
	BomberGroup:SetOutOfAGMRTB(true)

	local homebase, distance = SpawnCords:GetClosestAirbase(0, 2)
	if homebase then
		BomberGroup:SetHomebase(homebase)
	end

    local BomberTargets   = SET_GROUP:New()
    local setStaticBomber = SET_STATIC:New()
    local zn = bc:getZoneByName(targetZoneName)
    if zn.built then
        for _, v in pairs(zn.built) do
            local grp = GROUP:FindByName(v)
            if grp then
                BomberTargets:AddGroup(grp)
            end
            local st = STATIC:FindByName(v,false)
            if st then
                setStaticBomber:AddStatic(st)
            end
        end
    end

local BombMission = AUFTRAG:NewCASENHANCED(targetZone,27000,550,15,nil)
	BombMission.missionWaypointOffsetNM= 15
	BombMission:SetEngageAsGroup(false)
	BombMission:SetMissionSpeed(550)
	BombMission:AddConditionSuccess(function() return bc:getZoneByName(targetZoneName).side == 0 end)
	BombMission:AddConditionFailure(function() return BomberGroup and bc:getZoneByName(targetZoneName).side == 1 and BomberGroup:IsOutOfBombs() end)
	BombMission:SetMissionAltitude(27000)
	BombMission:SetWeaponExpend(AI.Task.WeaponExpend.ONE)
	BomberGroup:AddMission(BombMission)
function BombMission:OnAfterExecuting(From, Event, To)
	BombMission:SetROE(1)
	BombMission:SetROT(4)
	BombMission:SetMissionSpeed(450)
	end
--[[ 
local BombMission = AUFTRAG:NewBAI(BomberTargets,27000)
	BombMission.missionWaypointOffsetNM= 15
	BombMission:SetEngageAsGroup(false)
	BombMission:SetWeaponExpend(AI.Task.WeaponExpend.ONE)
	BombMission:SetMissionSpeed(550)
	BombMission:AddConditionSuccess(function() return bc:getZoneByName(targetZoneName).side == 0 end)
	BombMission:AddConditionFailure(function() return bc:getZoneByName(targetZoneName).side == 1 and BomberGroup:IsOutOfBombs() end)
	BomberGroup:AddMission(BombMission)
	function BombMission:OnAfterExecuting(From, Event, To)
	BombMission:SetROE(2)
	BombMission:SetROT(4)
	--BombMission:SetEngageDetected(15)
	BombMission:SetMissionSpeed(450)
	end ]]
	function BombMission:OnAfterSuccess(From, Event, To)
		trigger.action.outTextForCoalition(2, "Bomber Group has successfully completed its mission", 15)
	end
	if setStaticBomber:Count() > 0 then
		local auftragstatic = AUFTRAG:NewBAI(setStaticBomber, 25000)
		auftragstatic.missionWaypointOffsetNM= 15
		auftragstatic:SetWeaponExpend(AI.Task.WeaponExpend.ONE)
		auftragstatic:SetEngageAsGroup(false)
		auftragstatic:SetMissionSpeed(600)
		BomberGroup:AddMission(auftragstatic)
		function auftragstatic:OnAfterExecuting(From, Event, To)
		BomberGroup:SwitchROE(2)
		auftragstatic:SetFormation(131075)
		auftragstatic:SetMissionSpeed(380)
		end
		function auftragstatic:OnAfterSuccess(From, Event, To)
			if setStaticBomber:Count() > 0 then
			trigger.action.outTextForCoalition(2, "Bomber Group has successfully completed its mission", 15)
			end
		end
	end

	function BomberGroup:OnAfterLanded(From, Event, To)
		self:ScheduleOnce(5, function() self:Destroy() end)
	end
	function BomberGroup:OnAfterOutOfMissilesAG(From, Event, To)
		if BomberGroup then
		BomberGroup:SwitchROE(2)
		trigger.action.outTextForCoalition(2, "Bomber Group, returning to base", 15)
		end
	end
	function BomberGroup:OnAfterDead(From, Event, To)
		local landed = (From=="Landed") or (From=="Arrived")
		BomberGroup:__Stop(1) 
		BomberGroup  = nil
		bomberActive = false
		buildCapControlMenu()
		if landed then
			trigger.action.outTextForCoalition(2, "Bomber Group have landed", 15)
		else
			trigger.action.outTextForCoalition(2, "Bomber Group have been killed", 15)
		end
	end
	trigger.action.outTextForCoalition(2, "Bomber flight launched from " .. zoneName .. " to attack " .. targetZoneName, 15)
  end, g, timer.getTime() + 1)
	bomberActive = true
	buildCapControlMenu()
	bombSpawnIndex = bombSpawnIndex + 1
end

StructureActive = false
StructureGroup = nil
StructureTemplate = (Era == 'Coldwar') and 'DynamicStructure_Template_CW' or 'DynamicStructure_Template'
StructureTargetMenu = nil

function despawnStructure()
  if StructureGroup then
    StructureGroup:Despawn()
  end
end


function spawnStructureAt(zoneName, targetZoneName,offsetNM)
    if StructureActive then return end
    local zone = ZONE:FindByName(zoneName)
    local targetZone = ZONE:FindByName(targetZoneName)
    if not zone or not targetZone then return end
    local coord = zone:GetCoordinate()
	local SpawnCords = zone:GetCoordinate()
	coord:SetAltitude(7620)
    local targetCoord = targetZone:GetCoordinate()
    local heading = coord:GetAngleDegrees(coord:GetDirectionVec3(targetCoord))
	if offsetNM and offsetNM > 0 then
		coord = coord:Translate(UTILS.NMToMeters(offsetNM), heading + 180, true)
	end
	local g = Respawn.SpawnAtPoint(StructureTemplate, coord, heading, 5 ,27000)
		if not g then return end
	timer.scheduleFunction(function(group, time)
	local SpawnGroup = GROUP:FindByName(group:getName())
	StructureGroup = FLIGHTGROUP:New(SpawnGroup)
	StructureGroup:GetGroup():SetOptionRadioSilence(true)
	StructureGroup:SetOutOfAGMRTB(true)

	local homebase, distance = SpawnCords:GetClosestAirbase(0, 2)
	if homebase then
		StructureGroup:SetHomebase(homebase)
	end

    local setStaticBomber = SET_STATIC:New()
    local zn = bc:getZoneByName(targetZoneName)
    if zn.built then
        for _, v in pairs(zn.built) do
            local st = STATIC:FindByName(v,false)
            if st then
                setStaticBomber:AddStatic(st)
            end
        end
    end
	if setStaticBomber:Count() > 0 then
		local auftragstatic = AUFTRAG:NewBAI(setStaticBomber, 25000)
		auftragstatic.missionWaypointOffsetNM = 14
		auftragstatic:SetWeaponExpend(AI.Task.WeaponExpend.ONE)
		auftragstatic:SetEngageAsGroup(false)
		auftragstatic:SetMissionSpeed(600)
		StructureGroup:AddMission(auftragstatic)
		function auftragstatic:OnAfterExecuting(From, Event, To)
		StructureGroup:SwitchROE(2)
		auftragstatic:SetFormation(131075)
		auftragstatic:SetMissionSpeed(380)
		end
		function auftragstatic:OnAfterSuccess(From, Event, To)
			trigger.action.outTextForCoalition(2, "Strike Group has successfully completed its mission", 15)
		end
	end

	function StructureGroup:OnAfterLanded(From, Event, To)
		self:ScheduleOnce(5, function() self:Destroy() end)
	end
	function StructureGroup:OnAfterOutOfMissilesAG(From, Event, To)
		if StructureGroup then
		StructureGroup:SwitchROE(2)
		trigger.action.outTextForCoalition(2, "Infrastructure Group is now RTB", 15)
		end
	end
	function StructureGroup:OnAfterDead(From, Event, To)
		local landed = (From=="Landed") or (From=="Arrived")
		StructureGroup:__Stop(5) 
		StructureGroup  = nil
		StructureActive = false
		buildCapControlMenu()
		if landed then
			trigger.action.outTextForCoalition(2, "Strike Group have landed", 15)
		else
			trigger.action.outTextForCoalition(2, "Strike Group have been killed", 15)
		end
	end
	trigger.action.outTextForCoalition(2, "Strike Group launched from " .. zoneName .. " to attack " .. targetZoneName, 15)
  end, g, timer.getTime() + 1)
	StructureActive = true
	buildCapControlMenu()
end
--trigger.action.outTextForCoalition(2,"", 10)
--trigger.action.outText("", 10)


SCHEDULER:New(nil, function()
    if bc and bc.restoreDisabledFriendlyZones then
        bc:restoreDisabledFriendlyZones()
    end
end, {}, 5, 0)

SCHEDULER:New(nil, function()
    if bc and bc.activateNeutralStartZones then
        bc:activateNeutralStartZones()
    end
end, {}, 7, 0)

function HasLandingSpots(zoneName)
    local base = zoneName.."-land"
    if not LandingSpots then return false end
    local total = 0
    for n, lst in pairs(LandingSpots) do
        if n:sub(1,#base) == base and #lst > 0 then
            env.info(string.format("[LZ] %s has %d landing spots", n, #lst))
            total = total + #lst
        end
    end
    if total > 0 then
        env.info(string.format("[LZ] %s total pooled spots: %d", base, total))
    end
end


