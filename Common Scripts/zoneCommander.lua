local map = env.mission.theatre

SCHEDULER:New(nil, function()
env.info("[ZoneCommander] Loading for map: "..tostring(map))
end, {}, 2)

missionMarkId = missionMarkId or 900000000
if Era == 'Gulfwar' then Era = 'Coldwar' end

PATH_CACHE=PATH_CACHE or{}
Respawn = {}
farpBuiltByConvoy={}
ActiveCurrentMission = ActiveCurrentMission or {}
_awacsRepositionSched = nil
local escortFarpToZone={}

local zoneByName = nil
local customZoneCache = {}
local triggerZoneCache = {}
local mooseZoneCache = {}
local airbaseCache = {}
local function getAirbaseByName(name)
    local ab = airbaseCache[name]
    if ab == nil then
        ab = AIRBASE:FindByName(name) or Airbase.getByName(name) or false
        airbaseCache[name] = ab
    end
    if ab == false then return nil end
    return ab
end

local dcsAirbaseCache = {}
local function getDcsAirbaseByName(name)
    local ab = dcsAirbaseCache[name]
    if ab == nil then
        ab = Airbase.getByName(name) or false
        dcsAirbaseCache[name] = ab
    end
    if ab == false then return nil end
    return ab
end

local function getTriggerZone(name)
    local z = triggerZoneCache[name]
    if z == nil then
        z = trigger.misc.getZone(name) or false
        triggerZoneCache[name] = z
    end
    if z == false then return nil end
    return z
end

function getMooseZone(name)
    local z = mooseZoneCache[name]
    if z == nil then
        z = ZONE:FindByName(name) or false
        mooseZoneCache[name] = z
    end
    if z == false then return nil end
    return z
end
local function buildZoneByName()
    zoneByName = {}
    for _, z in ipairs(env.mission.triggers.zones or {}) do
        zoneByName[z.name] = z
    end
end

--[[ for n,_ in pairs(LandingSpots) do
     env.info("[LZ] stored key: "..n)
end ]]
LandingSpots = {}

local NM = 1852
local NEAR_BLUE_METERS = 50 * NM

local headingTrigCache = {}

local function _headingToRad(deg)
  if deg<=180 then return math.rad(deg) else return -math.rad(360-deg) end
end

local function _getHeadingTrig(headingDeg)
  local hdg = headingDeg or 0
  local cached = headingTrigCache[hdg]
  if not cached then
    local h = _headingToRad(hdg)
    cached = { h = h, psi = -h, cos = math.cos(h), sin = math.sin(h) }
    headingTrigCache[hdg] = cached
  end
  return cached
end

local function _bearingDegFromDelta(dx, dy)
  local h = math.deg(math.atan2(dx, dy))
  if h < 0 then h = h + 360 end
  return h
end

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
                local forced = {}
                local idx = 0
                while true do
                    local fname = string.format("%s-land-forced-%d", zname, idx)
                    local fz = getTriggerZone(fname)
                    if not fz then break end
                    table.insert(forced, {x=fz.point.x, z=fz.point.z})
                    idx = idx + 1
                end
                if #forced > 0 then
                    LandingSpots[zname] = forced
                else
                    trigger.action.outText(string.format("[LZ] Zone %s has no valid landing spots", zname), 10)
                    env.info(string.format("[LZ] Zone %s has no valid landing spots", zname))
                end
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
            local zObj = getMooseZone(zName)
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

function buildTemplateCache()
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

  local newGrp = coalition.addGroup(tpl.countryId, Group.Category[CAT[tpl.category] or "GROUND"], tpl)
  if not newGrp then
	env.error("Respawn: addGroup failed for group '"..groupName.."'")
	return nil
  end
  return newGrp
end

function Respawn.SpawnAtPoint(grpName, coord, headingDeg, distNm, alt, spd)
  local tpl = FetchMETemplate(grpName); if not tpl then return end
  
  local ALT = alt and UTILS.FeetToMeters(alt) or tpl.units[1].alt or UTILS.FeetToMeters(25000)

  local cx, cz = coord.x, coord.z
  if coord.GetVec3 then local v = coord:GetVec3(); cx,cz = v.x, v.z end
  local ht = _getHeadingTrig(headingDeg)
  local h = ht.h
  local psi = ht.psi
  local c, s = ht.cos, ht.sin
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
  local newGrp = coalition.addGroup(tpl.countryId,Group.Category[CAT[tpl.category] or "GROUND"],tpl)
  if not newGrp then env.error("Respawn: addGroup failed - "..tostring(newGrp)) return nil end
  return newGrp
end


local subZoneCache = {}

local function collectSubZones(baseName)
    if subZoneCache[baseName] then return subZoneCache[baseName] end
    local zones = {}
    for i = 1, 100, 1 do
        local zname = baseName .. '-' .. i
        if getTriggerZone(zname) then
            zones[#zones + 1] = zname
        else
            break
        end
    end
    subZoneCache[baseName] = zones
    return zones
end

local zoneCenterCache = {}
	function getZoneCenter(name)
		if zoneCenterCache[name] then return zoneCenterCache[name] end
		local z = getTriggerZone(name)
		if not z or not z.point then return nil end
		local c = { x = z.point.x, y = z.point.z or z.point.y or 0 }
		zoneCenterCache[name] = c
		return c
	end

function StartBomberAuftrag(tag, grpName, tgtList, escortGroup)
	local bomber = FLIGHTGROUP:New(grpName)
	local coords = bomber:GetCoordinate()
	local homebase, distance = coords:GetClosestAirbase(0, 1)
	if homebase then
		bomber:SetHomebase(homebase)
		env.info(string.format("[BomberAuftrag] Bomber %s homebase set to %s (%.1f km)", grpName, homebase:GetName(), distance/1000))
	end
	if type(tgtList) ~= "table" then tgtList = { tgtList } end
	local choice = nil
	do
		local valid = {}
		for _, v in ipairs(tgtList) do
			local z = bc.indexedZones[v]
			if z and z.side == 2 and not z.suspended then valid[#valid+1] = v end
		end
		local best = math.huge
		for _, v in ipairs(valid) do
			local z = bc.indexedZones[v]
			local zcoord = nil
			local mz = getMooseZone(z.zone or v)
			if mz then
				zcoord = mz:GetCoordinate()
			else
				local c = getZoneCenter(z.zone or v)
				if c then zcoord = COORDINATE:New(c.x,0,c.y) end
			end
			if zcoord then
				local d = coords:Get2DDistance(zcoord)
				if d < best then best = d ; choice = v end
			end
		end
		if not choice and #valid > 0 then choice = valid[math.random(1,#valid)] end
	end
	local setGroup = SET_GROUP:New()
	local zn = choice and bc.indexedZones[choice] or nil
	if zn and zn.built then
		for _, v in pairs(zn.built) do
			local grp = GROUP:FindByName(v)
			if grp then
				setGroup:AddGroup(grp)
			end
		end
	end
	local auftrag = AUFTRAG:NewBAI(setGroup, 25000)
	auftrag:SetMissionAltitude(25000)
	auftrag.missionWaypointOffsetNM = 25
	auftrag:AddConditionSuccess(function() return bomber:IsOutOfBombs() end)
	auftrag:SetWeaponExpend(AI.Task.WeaponExpend.HALF)
	auftrag:SetEngageAsGroup(true)
	auftrag:SetMissionSpeed(780)
	bomber:AddMission(auftrag)
	bomber:MissionStart(auftrag)
	function bomber:OnAfterLanded(From, Event, To)
		self:ScheduleOnce(5, function() self:Destroy() end)
	end
	function bomber:OnAfterDead(From, Event, To)
		local landed = (From=="Landed") or (From=="Arrived")
		self:__Stop(1)
	end
	if escortGroup then
		timer.scheduleFunction(function()
			local bgr = Group.getByName(grpName)
			local egr = Group.getByName(escortGroup)
			if bgr and egr then
				local c = egr:getController()
				c:setTask({
					id = 'ComboTask',
					params = { tasks = {
						{
							id = 'Escort',
							params = {
								groupId = bgr:getID(),
								pos = { x = -20, y = 2000, z = 50 },
								lastWptIndexFlag = false,
								engagementDistMax = 30*NM,
								targetTypes = { 'plane' }
							}
						}
					}}
				})
			end
		end,{},timer.getTime()+5)
	end
	_G[tag..'Bomber'] = bomber
	_G[tag..'Mission'] = auftrag
	return bomber, auftrag, choice
end


CustomZone = {}
do
	function CustomZone:getByName(name)
		local cached = customZoneCache[name]
		if cached ~= nil then
			if cached == false then return nil end
				return cached
		end
			obj = {}
			obj.name = name
			obj.isHidden = name:lower():find("hidden", 1, true) ~= nil
			if not zoneByName then buildZoneByName() end
			local zd = zoneByName[name]
			if not zd then
				customZoneCache[name] = false
				return nil
			end				

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
		customZoneCache[name] = obj
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
		end
	end

	function GetValidCords(zoneName, allowed, attempts)
		local zone = getMooseZone(zoneName); if not zone then return nil end
		attempts = attempts or 100
		for _=1,attempts do
			local coord = zone:GetRandomCoordinate()
			if coord then
				local st = coord:GetSurfaceType()
				if st ~= land.SurfaceType.RUNWAY and (not allowed or allowed[st]) then return coord end
			end
		end
		env.info("GetValidCords: no valid coord in "..tostring(zoneName))
		if env.mission.theatre=="GermanyCW" then
			for _=1,attempts do
				local coord = zone:GetRandomCoordinate()
				if coord then return coord end
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
		if grname:find("Red SAM") or grname:find("Dog Ear") or grname:find("blueHAWK") or grname:find("bluePD") or grname:find("bluePATRIOT") then
		spawn = spawn:InitHiddenOnMFD()
		end
		if grname:find("IsNotShown") or grname:find("Red EWR") then
		spawn = spawn:InitHiddenOnMap(true)
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
		return g and { name = g:GetName() } or trigger.action.outText("Failed to spawn group: "..grname.." in zone "..self.name,10)
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

	trigger.action.outText("Failed to spawn group: "..grname.." in zone "..self.name,5)
	env.info("Failed to spawn group: "..grname.." in zone "..self.name)
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
	

-- Utility functions for file system operations
function createDirectoryRecursive(path)
    -- Remove trailing slash if present
    path = path:gsub("/$", "")
    
    -- Split path into components
    local parts = {}
    for part in path:gmatch("[^/\\]+") do
        table.insert(parts, part)
    end
    
    -- Create each directory level
    local currentPath = ""
    for _, part in ipairs(parts) do
        currentPath = currentPath .. part .. "/"
        pcall(function() lfs.mkdir(currentPath) end)
    end
end

function writeToFile(filepath, content)
    -- Extract directory path from filepath
    local dir = filepath:match("(.*/)")
    
    -- Create full directory structure if needed
    if dir then
        createDirectoryRecursive(dir)
    end
    
    -- Attempt to open file in write mode
    local file, err = io.open(filepath, "w")
    
    -- Check if file opening succeeded
    if not file then
        env.info("Error opening file " .. filepath .. ": " .. tostring(err))
        return false
    end
    
    -- Attempt to write content
    local success, writeErr = pcall(function()
        file:write(content)
    end)
    
    -- Always close the file, even if an error occurred
    file:close()
    
    -- Check write result
    if not success then
        env.info("Error writing to file " .. filepath .. ": " .. tostring(writeErr))
        return false
    end
    
    return true
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
		local z = bc.indexedZones[zoneName]; z:updateLabel()
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
			end
			intelExpireTimes[n] = nil
			if intelActiveZones then intelActiveZones[n] = false end
			bc:buildZoneStatusMenuForGroup()
			local z = bc.indexedZones[n]
			if z and z.updateLabel then z:updateLabel() end
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
			if i == 'zones' and type(v) == 'table' then
				str = str..'\n'..variablename..'[\''..i..'\'] = {}'
				for zoneName, zoneState in pairs(v) do
					str = str..'\n'..variablename..'[\''..i..'\'][\''..zoneName..'\'] = '..Utils.serializeValue(zoneState)
				end
			else
				str = str..'\n'..variablename..'[\''..i..'\'] = '..Utils.serializeValue(v)
			end
		end
	
		File = io.open(filename, "w")
		File:write(str)
		File:close()
	end

	
	function Utils.serializeValue(value, indent, oneLine)
		indent = indent or 0
		local res = ''
		if type(value)=='number' or type(value)=='boolean' then
			res = res..tostring(value)
		elseif type(value)=='string' then
			res = res..string.format('%q', value) -- escape the strings before serializing them (solves the problem with multilines missions descriptions)
		elseif type(value)=='table' then
			local pad = string.rep(' ', indent)
			local pad2 = string.rep(' ', indent + 2)
			local nl = oneLine and '' or '\n'
			res = res..'{'..(oneLine and ' ' or nl)
			for i,v in pairs(value) do
				local k
				if type(i)=='number' then
					k = '['..i..']='
				else
					k = '[\''..i..'\']='
				end
				res = res..(oneLine and '' or pad2)..k..Utils.serializeValue(v, indent + 2, oneLine)..','..nl
			end
			if not oneLine then
				res = res..pad..'}'
			else
				if res:sub(-1) == ' ' then
					res = res
				end
				if res:sub(-2) == ', ' then
					res = res:sub(1,-3)
				elseif res:sub(-1) == ',' then
					res = res:sub(1,-2)
				end
				res = res..' }'
			end
		end
		return res
	end
	
	function Utils.loadTable(filename)
		if not Utils.canAccessFS then return end
		if not lfs then
			Utils.canAccessFS = false
			trigger.action.outText('Persistance disabled, Save file can not be created\n\nDe-Sanitize DCS missionscripting.lua', 600)
			return
		end
		if not lfs.attributes(filename) then return end

		local chunk = loadfile(filename)
		if chunk then chunk(); return end

		local f = io.open(filename, "r"); if not f then return end
		local lines = {}
		for line in f:lines() do
			local bad = (line:match("%['[^%]]*[\\/]")) or (line:match("%['\\'"))
			if not bad then lines[#lines+1] = line end
		end
		f:close()
		local fixed = table.concat(lines, "\n")
		local chunk = loadstring(fixed)
		if chunk then chunk() end
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

	local renameCache = {}

	function renameType(tgttype)
			if not tgttype then return "Unknown" end
			local cached = renameCache[tgttype]
			if cached then return cached end
			for pattern, name in pairs(renameMap) do
			if string.find(tgttype, pattern) then
					renameCache[tgttype] = name
					return name
				end
			end
			renameCache[tgttype] = tgttype
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
						local p = tgtunit:getPoint()
						local distSteps = {50,55,60,65,70,75,80,85,90,95,100}
						local dist = distSteps[math.random(#distSteps)]
						local ang = math.random() * 2 * math.pi
						local sx = p.x + dist * math.cos(ang)
						local sz = p.z + dist * math.sin(ang)
						local smokePoint = { x = sx, y = p.y, z = sz }
						trigger.action.smoke(smokePoint, col)
						local bearing = Utils.getBearing({x=smokePoint.x,z=smokePoint.z},{x=p.x,z=p.z})
						if bearing < 0 then bearing = bearing + 360 end
						local dir
						if bearing >= 337.5 or bearing < 22.5 then dir = 'north'
						elseif bearing < 67.5 then dir = 'north east'
						elseif bearing < 112.5 then dir = 'east'
						elseif bearing < 157.5 then dir = 'south east'
						elseif bearing < 202.5 then dir = 'south'
						elseif bearing < 247.5 then dir = 'south west'
						elseif bearing < 292.5 then dir = 'west'
						else dir = 'north west' end
						local dStr = tostring(dist) .. ' meters'
						trigger.action.outTextForCoalition(dr.side,'Target is '..dStr..' '..dir..' of the '..JTAC.smokeColors[col]..' smoke at '..dr.tgtzone.zone,15)

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
            id = 'SetUnlimitedFuel', 
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
	GlobalSettings.capRearlineNmRed = 60    		-- red CAP cutoff behind frontline (nm)
	GlobalSettings.frontlineMaxSegmentNm = 120    	
	GlobalSettings.frontlineDistanceLimitBlue = 30
	GlobalSettings.frontlineDistanceLimitRed  = 60
	GlobalSettings.proximityWakeNm = 30    			-- wake up zones within this nm of front
	GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
	GlobalSettings.autoSuspendNmRed = 120   		-- suspend red zones deeper than this nm
	GlobalSettings.blockedDespawnTime = 12*60 		-- used to despawn aircraft that are stuck taxiing for some reason
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
		supply = { dead=15*60, hangar=15*60, preparing=5*60},
		patrol = { dead=15*60, hangar=15*60, preparing=5*60},
		attack = { dead=15*60, hangar=15*60, preparing=5*60}
	}
	
	GlobalSettings.defaultRespawns[2] = {
		supply = { dead=15*60, hangar=15*60, preparing=5*60},
		patrol = { dead=15*60, hangar=15*60, preparing=5*60},
		attack = { dead=15*60, hangar=15*60, preparing=5*60}
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

_globalArrowCounter = 1201
_activeArrowIds = {}

MissionTargets        = {}
MissionGroups         = {}
ScoreTargets          = {}
ActiveMission         = {}
MissionMarks          = {}

function RegisterUnitTarget(uname,reward,stat,flagName)
    if flagName then
        MissionTargets[uname]={reward=reward,stat=stat,flag=flagName}
    else
        MissionTargets[uname]={reward=reward,stat=stat}
    end
end

function RegisterStaticGroup(groupKey,source,reward,stat,flagName)
	local list = (source and source.criticalObjects) and source.criticalObjects or source
	if not list or #list==0 then return end
	local alive = {}
	for i=1,#list do
		local n = list[i]
		local obj = StaticObject.getByName(n)
		if obj and (obj:getLife() or 0) > 1 then alive[#alive+1] = n end
	end
	if #alive==0 then
		if flagName then
			CustomFlags[flagName] = true
			if ActiveMission[flagName] then ActiveMission[flagName] = nil end
		end
		return
	end
	local tab = {reward = reward, stat = stat, alive = {}, remaining = 0, killers = {}}
	if flagName then tab.flag = flagName end
	for i=1,#alive do
		local n = alive[i]
		tab.alive[n] = true
		tab.remaining = tab.remaining + 1
		MissionTargets[n] = {group = groupKey}
		if flagName then MissionTargets[n].flag = flagName end
	end
	MissionGroups[groupKey] = tab
	if flagName then flag = flagName end
	if flagName then ActiveMission[flagName] = true end
	local cnt = #alive
	for i=1,cnt do
		local n = alive[i]
		local obj = StaticObject.getByName(n)
		local p = obj and obj:getPoint()
		if p then
			if i==1 then
				missionMarkId = missionMarkId + 1
				local label = stat and ((cnt>1) and (stat.." "..i) or stat) or groupKey
				trigger.action.markToCoalition(missionMarkId,label,p,2,false,false)
				MissionMarks[groupKey] = missionMarkId
			end
		end
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
    local units = g:getUnits()
    local cnt = #units
    local s = getGroupSpeed(g)
	if g:isExist() and g:getSize()>0 and s < 1 then
		local u = units[1]
		if u and u:isExist() then
			local p = u:getPoint()
			missionMarkId = missionMarkId + 1
			local label = stat or groupName
			trigger.action.markToCoalition(missionMarkId,label,p,2,false,false)
			MissionMarks[groupName] = missionMarkId
		end
	end
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
	--group:getController():setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.OPEN_FIRE)
	group:getController():setOption(AI.Option.Air.id.MISSILE_ATTACK, AI.Option.Air.val.MISSILE_ATTACK.MAX_RANGE)
	group:getController():setOption(AI.Option.Air.id.RTB_ON_OUT_OF_AMMO, 268402688) -- AnyMissile
end


Frontline = Frontline or {}
Frontline._centroidCache = Frontline._centroidCache or {}
Frontline._zoneAwareness = Frontline._zoneAwareness or nil



function Frontline.DebugExplain(zname)
  local bc = bc or _G.bc
  local function b(v) return v and "true" or "false" end
  local zi = Frontline._zoneInfo and Frontline._zoneInfo[zname]
  local z  = bc and bc.getZoneByName and bc.indexedZones[zname] or nil
  local cz = CustomZone and CustomZone:getByName(zname) or nil
  env.info(string.format("[FL-EXPL] name=%s presentIn_zoneInfo=%s", tostring(zname), b(zi~=nil)))
  env.info(string.format("[FL-EXPL] bc:getZoneByName -> %s", z and "FOUND" or "nil"))
  if z then
    env.info(string.format("[FL-EXPL] side=%s active=%s suspended=%s hidden=%s",
      tostring(z.side), b(z.active), b(z.suspended), b(z.zone and z.isHidden)))
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
            if not zc.isHidden and zc.active ~= false then
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
        local maxSegNm = (GlobalSettings.frontlineMaxSegmentNm or 120)
        for i=1,#fromList do
            local aName = fromList[i]
            local ai = zoneInfo[aName]
            if ai and ai.suspended ~= true then
                local best,bd
                for j=1,#toList do
                    local bName = toList[j]
                    local bi = zoneInfo[bName]
                    if bi and bi.suspended ~= true then
                        local d = vlen(vsub(bi.center, ai.center))
                        if (d / NM) <= maxSegNm then
                            if not bd or d < bd then
                                best,bd = bName,d
                            end
                        end
                    end
                end
                if best then
                    local A,B = ai.center, zoneInfo[best].center
                    local n = (fromSide==2) and vnorm(vsub(B,A)) or vnorm(vsub(A,B))
                    local m = vmul(vadd(A,B), 0.5)
                    segs[#segs+1] = {A=A,B=B,m=m,n=n,aName=aName,bName=best}
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
            local dist = math.sqrt(dist2)
            local distNm = dist / NM
            local hdgAB = _bearingDegFromDelta(dx, dy)
            local hdgBA = _bearingDegFromDelta(-dx, -dy)
            local vecAB = v2(dx, dy)
            local vecBA = v2(-dx, -dy)
			if ai.side and bi.side then
				local same = (ai.side == bi.side) or (ai.side == 0) or (bi.side == 0) or (ai.active == false) or (bi.active == false)
				if same then
					ai.sameSideNeighbors[#ai.sameSideNeighbors+1] = {name=bName, vec=vecAB, dist2=dist2, dist=dist, distanceNm=distNm, headingDeg=hdgAB}
					bi.sameSideNeighbors[#bi.sameSideNeighbors+1] = {name=aName, vec=vecBA, dist2=dist2, dist=dist, distanceNm=distNm, headingDeg=hdgBA}
				else
					ai.enemyNeighbors[#ai.enemyNeighbors+1] = {name=bName, vec=vecAB, dist2=dist2, dist=dist, distanceNm=distNm, headingDeg=hdgAB, side=bi.side}
					bi.enemyNeighbors[#bi.enemyNeighbors+1] = {name=aName, vec=vecBA, dist2=dist2, dist=dist, distanceNm=distNm, headingDeg=hdgBA, side=ai.side}
				end
			else
				ai.sameSideNeighbors[#ai.sameSideNeighbors+1] = {name=bName, vec=vecAB, dist2=dist2, dist=dist, distanceNm=distNm, headingDeg=hdgAB}
				bi.sameSideNeighbors[#bi.sameSideNeighbors+1] = {name=aName, vec=vecBA, dist2=dist2, dist=dist, distanceNm=distNm, headingDeg=hdgBA}
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
  local seg = zi.frontSeg
  --env.info(string.format("[FRONTLINE] zone %s distToFrontNm=%.1f via segment %s <-> %s", tostring(zoneName), zi.distToFrontNm, tostring(seg and seg.aName), tostring(seg and seg.bName)))

  return zi.distToFrontNm
end

--Frontline.ZoneDistToFrontNm('Raqqa')

AWACS_GROUPS = {
    [1] = "AWACS_RED",
    [2] = "AWACS_BLUE",
    [3] = "AWACS_BLUE_SECONDARY"
}


_awacsFG,_awacsZone,_awacsMissionParams = {},{},{}

local _anyZoneSideIndex = {}
local _densestZoneIndex = {}
local _enemyDistIndex = {}

local function _anyZoneOfSide(side)
    local cached = _anyZoneSideIndex[side]; if cached then return cached end
    local zi = Frontline._zoneInfo
    if not zi then return nil end
    for name,info in pairs(zi) do
        if info and info.center and info.side == side then _anyZoneSideIndex[side] = name; return name end
    end
    return nil
end

local function _bearingDeg(a, b)
    return _bearingDegFromDelta(b.x - a.x, b.y - a.y)
end

local function _pickDensestZone(side, radiusNm)
    local r = radiusNm or 80
    if _densestZoneIndex[side] and _densestZoneIndex[side][r] then return _densestZoneIndex[side][r] end
    local zi = Frontline._zoneInfo or {}
    local best, bestCnt = nil, -1
    local r2 = r * 1852; r2 = r2 * r2
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
    _densestZoneIndex[side] = _densestZoneIndex[side] or {}
    _densestZoneIndex[side][r] = best
    return best
end

local function _minDistPointToEnemiesNm(px, pz, mySide)
    local zi = Frontline._zoneInfo or {}
    local best2 = 1e18
    for name,info in pairs(zi) do
        if info and info.center and info.side and info.side ~= 0 and info.side ~= mySide and info.active ~= false then
            local dx = info.center.x - px
            local dy = info.center.y - pz
            local d2 = dx*dx + dy*dy
            if d2 < best2 then best2 = d2 end
        end
    end
    if best2 == 1e18 then return 1e9 end
    return math.sqrt(best2) / 1852
end

local function _minDistToEnemyNm(zoneName, mySide)
    local cached = _enemyDistIndex[zoneName]; if cached then return cached end
    local zi = Frontline._zoneInfo or {}
    local info = zi[zoneName]; if not info or not info.enemyNeighbors then return 1e9 end
    local best2 = 1e18
    for i=1,#info.enemyNeighbors do
        local nb = info.enemyNeighbors[i]
        local de = zi[nb.name]
        if nb.side and nb.side ~= 0 and nb.side ~= (mySide or info.side) and de and de.active ~= false and nb.dist2 and nb.dist2 < best2 then
            best2 = nb.dist2
        end
    end
    local nm = (best2 == 1e18) and 1e9 or (math.sqrt(best2) / 1852)
    _enemyDistIndex[zoneName] = nm
    return nm
end

function Frontline.BuildZoneAwareness(radiusNm, options)
	Frontline._zoneAwareness = nil
    local zi = Frontline._zoneInfo or {}
    local opt = options or {}
    local radius = radiusNm or opt.radiusNm or 160
    local avoidEnemyMinNm = math.max(0, opt.avoidEnemyMinNm or opt.avoidEnemyBuffer or 0)
    local forwardJitterNm = opt.forwardJitterNm
    local maxTargets = opt.maxTargets or 10
    local includeSuspended = opt.includeSuspended == true

    local r2 = nil
    if radius and radius > 0 then
        local rm = radius * NM
        r2 = rm * rm
    end

    local awareness = {}
    for name,info in pairs(zi) do
        if info and info.center and info.side and info.side ~= 0 and (includeSuspended or info.active ~= false) then
            local entry = {
                name = name,
                side = info.side,
                center = { x = info.center.x, y = info.center.y },
                radiusNm = radius,
                avoidEnemyMinNm = avoidEnemyMinNm,
                friendlyZones = {},
                enemyZones = {},
                capTargets = {}
            }

            for i=1,#(info.sameSideNeighbors or {}) do
                local nb = info.sameSideNeighbors[i]
                local dist2 = nb and nb.dist2
                if dist2 and (not r2 or dist2 <= r2) then
                    local ni = zi[nb.name]
                    if ni and ni.center and (includeSuspended or ni.active ~= false) then
                        local distNm = nb.distanceNm or (math.sqrt(dist2) / NM)
                        local headingDeg = nb.headingDeg or _bearingDeg(info.center, ni.center)
                        entry.friendlyZones[#entry.friendlyZones+1] = {
                            name = nb.name,
                            distanceNm = distNm,
                            headingDeg = headingDeg
                        }
                    end
                end
            end

            for i=1,#(info.enemyNeighbors or {}) do
                local nb = info.enemyNeighbors[i]
                local dist2 = nb and nb.dist2
                if dist2 and (not r2 or dist2 <= r2) then
                    local ni = zi[nb.name]
                    if ni and ni.center and ni.side and ni.side ~= 0 and (includeSuspended or ni.active ~= false) then
                        local distNm = nb.distanceNm or (math.sqrt(dist2) / NM)
                        local headingDeg = nb.headingDeg or _bearingDeg(info.center, ni.center)
                        entry.enemyZones[#entry.enemyZones+1] = {
                            name = nb.name,
                            side = ni.side,
                            distanceNm = distNm,
                            headingDeg = headingDeg
                        }
                    end
                end
            end

            local limit = math.min(maxTargets, #entry.enemyZones)
            for i=1,limit do
                local tgt = entry.enemyZones[i]
                local desiredForward = tgt.distanceNm
                if type(forwardJitterNm) == "number" then
                    desiredForward = math.max(0, math.min(tgt.distanceNm, forwardJitterNm))
                end
                local capPoint = Frontline.PickCapStationFromOrigin(name, tgt.name, info.side, desiredForward, avoidEnemyMinNm)
                entry.capTargets[#entry.capTargets+1] = {
                    targetZone = tgt.name,
                    targetSide = tgt.side,
                    distanceNm = tgt.distanceNm,
                    headingDeg = tgt.headingDeg,
                    requestedForwardNm = desiredForward,
                    avoidEnemyMinNm = avoidEnemyMinNm,
                    capPoint = capPoint
                }
            end

            if #entry.capTargets > 0 then
                entry.primaryTarget = entry.capTargets[1].targetZone
            end

            entry.friendlyCount = #entry.friendlyZones
            entry.enemyCount = #entry.enemyZones

            awareness[name] = entry
        end
    end

    Frontline._zoneAwareness = awareness
    return awareness
end

function Frontline.GetZoneAwareness(zoneName)
    local cache = Frontline._zoneAwareness
    if not cache then return nil end
    return cache[zoneName]
end


function Frontline.ReindexZoneCalcs()
    _anyZoneSideIndex = {}
    _densestZoneIndex = {}
    _enemyDistIndex = {}
    local zi = Frontline._zoneInfo or {}
    for name,info in pairs(zi) do
        if info and info.side then
            if not _anyZoneSideIndex[info.side] and info.center then _anyZoneSideIndex[info.side] = name end
            _enemyDistIndex[name] = _minDistToEnemyNm(name, info.side)
        end
    end
    _pickDensestZone(1, 160)
    _pickDensestZone(2, 160)
	Frontline.BuildZoneAwareness(160, { forwardJitterNm = 120, avoidEnemyMinNm = 40 })
end

local function _computeAwacsStationWithZone(side)
    local cfg = AWACS_CFG[side] or {}
    local zi  = Frontline._zoneInfo or {}
    local sep = cfg.sep or 0
    if (not _enemyDistIndex) or (next(_enemyDistIndex) == nil) then
        if Frontline.ReindexZoneCalcs then Frontline.ReindexZoneCalcs() end
    end

    local myPick, bestD = nil, 1e9
    for name,info in pairs(zi) do
        if info and info.center and info.side == side and info.active ~= false then
            local d = (_enemyDistIndex and _enemyDistIndex[name]) or _minDistToEnemyNm(name, side)
            if d < bestD then bestD, myPick = d, name end
        end
    end
    if not myPick then myPick = _anyZoneOfSide(side) end; if not myPick then return nil, nil end

    local bestName, bestCnt, bestNear = nil, -1, 1e9
    for name,info in pairs(zi) do
        if info and info.center and info.side == side and info.active ~= false then
            local d = (_enemyDistIndex and _enemyDistIndex[name]) or _minDistToEnemyNm(name, side)
            local near = math.abs(d - sep)
            local cnt = 0
            if info.sameSideNeighbors then
                for i=1,#info.sameSideNeighbors do
                    local n = info.sameSideNeighbors[i]
                    local ni = zi[n.name]
                    if ni and ni.center and ni.side == side and n.dist2 then cnt = cnt + 1 else break end
                end
            end
            if (near < bestNear) or (near == bestNear and cnt > bestCnt) then
                bestName, bestCnt, bestNear = name, cnt, near
            end
        end
    end
    if not bestName then bestName = myPick end

    local myInfo = zi[bestName]; if not myInfo or not myInfo.center then return nil, nil end
    local myC = myInfo.center

    local function nearestEnemyCenter(px, pz)
        local cx, cy, best2 = nil, nil, 1e18
        if myInfo.enemyNeighbors and #myInfo.enemyNeighbors > 0 then
            for i=1,#myInfo.enemyNeighbors do
                local nb = myInfo.enemyNeighbors[i]
                if nb.side and nb.side ~= 0 and nb.side ~= side and nb.dist2 and nb.dist2 < best2 then
                    local de = zi[nb.name]
                    if de and de.center then best2, cx, cy = nb.dist2, de.center.x, de.center.y end
                end
            end
        end

        local sx, sy, sBest2 = nil, nil, 1e18
        for n,inf in pairs(zi) do
            if inf and inf.center and inf.side and inf.side ~= 0 and inf.side ~= side then
                local dx = px - inf.center.x
                local dy = pz - inf.center.y
                local d2 = dx*dx + dy*dy
                if d2 < sBest2 then sBest2, sx, sy = d2, inf.center.x, inf.center.y end
            end
        end

        if sx then
            return sx, sy
        end
        return cx, cy
    end

    local dNow = _minDistPointToEnemiesNm(myC.x, myC.y, side)
    if dNow < sep then
        local ex, ey = nearestEnemyCenter(myC.x, myC.y)
        if ex and ey then
            local dir = vnorm(v2(myC.x - ex, myC.y - ey))
            myC = vadd(myC, vmul(dir, (sep - dNow) * NM))
            for i=1,3 do
                local d2 = _minDistPointToEnemiesNm(myC.x, myC.y, side)
                if d2 >= sep then break end
                local ex2, ey2 = nearestEnemyCenter(myC.x, myC.y)
                if not ex2 then break end
                local dir2 = vnorm(v2(myC.x - ex2, myC.y - ey2))
                myC = vadd(myC, vmul(dir2, (sep - d2) * NM))
            end
        end
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
    return COORDINATE:New(myC.x, UTILS.FeetToMeters(alt), myC.y), bestName, hdg, toward
end


local function _computeAwacsStationWithZoneSecondary(side, avoidX, avoidZ, minSepNm)
    local cfg = AWACS_CFG[side] or {}
    local zi  = Frontline._zoneInfo or {}
    local sep = cfg.sep or 0
    if (not _enemyDistIndex) or (next(_enemyDistIndex) == nil) then
        if Frontline.ReindexZoneCalcs then Frontline.ReindexZoneCalcs() end
    end

    local myPick, bestD = nil, 1e9
    for name,info in pairs(zi) do
        if info and info.center and info.side == side and info.active ~= false then
            local d = (_enemyDistIndex and _enemyDistIndex[name]) or _minDistToEnemyNm(name, side)
            if d < bestD then bestD, myPick = d, name end
        end
    end
    if not myPick then myPick = _anyZoneOfSide(side) end; if not myPick then return nil, nil end

    local minSep = (minSepNm or 0) * NM
    local minSep2 = minSep * minSep

    if not avoidX or not avoidZ then return nil, nil end

    local bestName, bestCnt, bestNear, bestSep2 = nil, -1, 1e9, -1
    for name,info in pairs(zi) do
        if info and info.center and info.side == side and info.active ~= false then
            local dx = info.center.x - avoidX
            local dy = info.center.y - avoidZ
            local sep2 = dx*dx + dy*dy
            if sep2 >= minSep2 then
                local d = (_enemyDistIndex and _enemyDistIndex[name]) or _minDistToEnemyNm(name, side)
                local near = math.abs(d - sep)
                local cnt = 0
                if info.sameSideNeighbors then
                    for i=1,#info.sameSideNeighbors do
                        local n = info.sameSideNeighbors[i]
                        local ni = zi[n.name]
                        if ni and ni.center and ni.side == side and n.dist2 then cnt = cnt + 1 else break end
                    end
                end
                if (near < bestNear) or (near == bestNear and cnt > bestCnt) or (near == bestNear and cnt == bestCnt and sep2 > bestSep2) then
                    bestName, bestCnt, bestNear, bestSep2 = name, cnt, near, sep2
                end
            end
        end
    end
    if not bestName then return nil, nil end

    local myInfo = zi[bestName]; if not myInfo or not myInfo.center then return nil, nil end
    local myC = myInfo.center

    local function nearestEnemyCenter(px, pz)
        local cx, cy, best2 = nil, nil, 1e18
        if myInfo.enemyNeighbors and #myInfo.enemyNeighbors > 0 then
            for i=1,#myInfo.enemyNeighbors do
                local nb = myInfo.enemyNeighbors[i]
                if nb.side and nb.side ~= 0 and nb.side ~= side and nb.dist2 and nb.dist2 < best2 then
                    local de = zi[nb.name]
                    if de and de.center then best2, cx, cy = nb.dist2, de.center.x, de.center.y end
                end
            end
        end

        local sx, sy, sBest2 = nil, nil, 1e18
        for n,inf in pairs(zi) do
            if inf and inf.center and inf.side and inf.side ~= 0 and inf.side ~= side then
                local dx = px - inf.center.x
                local dy = pz - inf.center.y
                local d2 = dx*dx + dy*dy
                if d2 < sBest2 then sBest2, sx, sy = d2, inf.center.x, inf.center.y end
            end
        end

        if sx then
            return sx, sy
        end
        return cx, cy
    end

    local dNow = _minDistPointToEnemiesNm(myC.x, myC.y, side)
    if dNow < sep then
        local ex, ey = nearestEnemyCenter(myC.x, myC.y)
        if ex and ey then
            local dir = vnorm(v2(myC.x - ex, myC.y - ey))
            myC = vadd(myC, vmul(dir, (sep - dNow) * NM))
            for i=1,3 do
                local d2 = _minDistPointToEnemiesNm(myC.x, myC.y, side)
                if d2 >= sep then break end
                local ex2, ey2 = nearestEnemyCenter(myC.x, myC.y)
                if not ex2 then break end
                local dir2 = vnorm(v2(myC.x - ex2, myC.y - ey2))
                myC = vadd(myC, vmul(dir2, (sep - d2) * NM))
            end
        end
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
    return COORDINATE:New(myC.x, UTILS.FeetToMeters(alt), myC.y), bestName, hdg, toward
end

 function RepositionAwacsToFront()
    env.info("AWACS is checking the frontline")
	local blueVec = nil
	for side=1,2 do
		local coord, z, h = _computeAwacsStationWithZone(side)
		if coord then
			if side == 2 then blueVec = coord.GetVec3 and coord:GetVec3() or nil end
			setAwacsRacetrack(side, coord, h, nil, z)
		else env.info("AWACS compute failed") end
	end
	if IsGroupActive(AWACS_GROUPS[3]) then
		local avoidX = (blueVec and blueVec.x) or (_awacsMissionParams[2] and _awacsMissionParams[2].x) or nil
		local avoidZ = (blueVec and blueVec.z) or (_awacsMissionParams[2] and _awacsMissionParams[2].z) or nil
		local coord2, z2, h2 = _computeAwacsStationWithZoneSecondary(2, avoidX, avoidZ, 150)
		if coord2 then setAwacsRacetrack(3, coord2, h2, nil, z2) else env.info("AWACS compute failed") end
	else
		spawnAwacs(3, nil, nil)
	end
end

function setAwacsRacetrack(side, coord, heading, leg, zoneName)
    local fg = _awacsFG[side] or nil; if not fg or not coord then return end
    local cfgSide = (side == 3) and 2 or side
    local cfg = AWACS_CFG[cfgSide] or {}
    local alt = cfg.alt or 30000
    local spd = cfg.speed or 350
    local hdg = heading or cfg.hdg or 270
    local leglen = leg or cfg.leg or 10
    local vec = coord.GetVec3 and coord:GetVec3() or nil
    local params = _awacsMissionParams[side]

    if params and vec and params.x and params.z then
        local dx = vec.x - params.x
        local dz = vec.z - params.z
        if (dx*dx + dz*dz) <= 2500 then return end
    end

    local cur = fg:GetMissionCurrent(); if cur then cur:__Cancel(5) end
    local auf = AUFTRAG:NewAWACS(coord, alt, spd, hdg, leglen)
    _awacsZone[side] = zoneName or _awacsZone[side]
    _awacsMissionParams[side] = {
        x = vec and vec.x or nil,
        z = vec and vec.z or nil,
        zone = _awacsZone[side]
    }
	auf:SetMissionSpeed(350)
	auf:SetMissionAltitude(30000)
    fg:AddMission(auf)
end

function spawnAwacs(side, heading, leg)
    local cfgSide = (side == 3) and 2 or side
    local coord, z, ch, toward
    if side == 3 then
        local avoidX = (_awacsMissionParams[2] and _awacsMissionParams[2].x) or nil
        local avoidZ = (_awacsMissionParams[2] and _awacsMissionParams[2].z) or nil
        coord, z, ch, toward = _computeAwacsStationWithZoneSecondary(2, avoidX, avoidZ, 150); if not coord then return end
    else
        coord, z, ch, toward = _computeAwacsStationWithZone(side); if not coord then return end
    end
    local aim = toward or z
    local zobj = aim and ZONE:FindByName(aim) or nil
    local targetCoord = (zobj and zobj:GetCoordinate()) or (Frontline._zoneInfo[aim] and COORDINATE:New(Frontline._zoneInfo[aim].center.x, coord.y, Frontline._zoneInfo[aim].center.y)) or nil
    local hdgCalc = targetCoord and coord:GetAngleDegrees(coord:GetDirectionVec3(targetCoord)) or ch
    local hdg = heading or hdgCalc or AWACS_CFG[cfgSide].hdg
    local alt = AWACS_CFG[cfgSide].alt
    local spd = AWACS_CFG[cfgSide].speed
    local lg  = leg or AWACS_CFG[cfgSide].leg
    local g = Respawn.SpawnAtPoint(AWACS_GROUPS[side], coord, hdg, lg, alt, spd)
    if not g then return end
    timer.scheduleFunction(function(group, time)
        local spawnedGroup = GROUP:FindByName(group:getName())
        local fg = FLIGHTGROUP:New(spawnedGroup)
		_awacsFG[side] = fg
		fg:SwitchInvisible(true)
		fg:SwitchImmortal(true)
        fg:GetGroup():CommandSetUnlimitedFuel(true)
        local auf = AUFTRAG:NewAWACS(coord, alt, spd, hdg, lg)
        fg:AddMission(auf)
        _awacsZone[side] = z
        local vec = coord.GetVec3 and coord:GetVec3() or nil
        _awacsMissionParams[side] = {
            x = vec and vec.x or nil,
            z = vec and vec.z or nil,
            hdg = hdg,
            leg = lg,
            zone = _awacsZone[side]
        }
        if side == 2 and vec then
            local coord2, z2, h2 = _computeAwacsStationWithZoneSecondary(2, vec.x, vec.z, 150)
            if coord2 then
                if IsGroupActive(AWACS_GROUPS[3]) then
                    setAwacsRacetrack(3, coord2, h2, nil, z2)
                else
                    spawnAwacs(3, nil, lg)
                end
            end
        end
    end, g, timer.getTime() + 0.5)
end


function Frontline.PickCapStationFromOrigin(myZoneName, targetZoneName, mySide, forwardJitterNm, avoidEnemyMinNm)
    local zi = Frontline._zoneInfo or {}
    local tInfo = zi[targetZoneName]; if not (tInfo and tInfo.center) then return nil end
    local aInfo = zi[myZoneName]; if not (aInfo and aInfo.center) then return nil end

    local f = vnorm(v2(tInfo.center.x - aInfo.center.x, tInfo.center.y - aInfo.center.y)); if f.x==0 and f.y==0 then f = v2(1,0) end
    local sep = math.max(0, avoidEnemyMinNm or 0)
    local want = math.max(0, forwardJitterNm or 0)

    local distToTargetNm = vlen(v2(tInfo.center.x - aInfo.center.x, tInfo.center.y - aInfo.center.y)) / NM
    local ubNm = math.min(math.max(0, distToTargetNm - sep), want)

    local aw = Frontline.GetZoneAwareness and Frontline.GetZoneAwareness(myZoneName) or nil
    if aw and aw.enemyZones and #aw.enemyZones > 0 then
        local hdg = _bearingDeg(aInfo.center, tInfo.center)
        for i=1,#aw.enemyZones do
            local ez = aw.enemyZones[i]
            local d = math.abs(((ez.headingDeg - hdg + 180) % 360) - 180)
            if d <= 60 then
                local cap = math.max(0, ez.distanceNm - sep)
                if cap < ubNm then ubNm = cap end
            end
        end
    end

    local lo, hi = 0, ubNm
    for _=1,7 do
        local mid = (lo + hi) * 0.5
        local ptest = vadd(aInfo.center, vmul(f, mid * NM))
        local mdEnemy = _minDistPointToEnemiesNm(ptest.x, ptest.y, mySide)
        local mdTarget = vlen(v2(tInfo.center.x - ptest.x, tInfo.center.y - ptest.y)) / NM
        if mdEnemy >= sep and mdTarget >= sep then lo = mid else hi = mid end
    end

    local p = vadd(aInfo.center, vmul(f, lo * NM))
    return { x = p.x, y = p.y }
end






function Frontline.PickStationNearZone(zoneName, mySide, offsetNmTowardFriendly, lateralJitterNm, forwardJitterNm, minBufferNm, avoidEnemyMinNm)
    local zi = Frontline._zoneInfo[zoneName]; if not zi or not zi.center then return nil end
    local safe = math.max(0, avoidEnemyMinNm or 0)

    local bestE, bestD2 = nil, 1e18
    local aw = Frontline.GetZoneAwareness and Frontline.GetZoneAwareness(zoneName) or nil
    if aw and aw.enemyZones and aw.enemyZones[1] then
        local ez = aw.enemyZones[1]
        local ei = Frontline._zoneInfo[ez.name]
        if ei and ei.center then
            bestE = ei.center
            local dx = ei.center.x - zi.center.x
            local dy = ei.center.y - zi.center.y
            bestD2 = dx*dx + dy*dy
        end
    end
    if not bestE then
        for name,info in pairs(Frontline._zoneInfo) do
            if info and info.center and info.side and info.side ~= 0 and info.side ~= (mySide or zi.side) and info.active ~= false then
                local dx = info.center.x - zi.center.x
                local dy = info.center.y - zi.center.y
                local d2 = dx*dx + dy*dy
                if d2 < bestD2 then bestD2, bestE = d2, info.center end
            end
        end
    end
    local e = bestE or zi.center
    local toEnemy = vnorm(v2(e.x - zi.center.x, e.y - zi.center.y)); if toEnemy.x==0 and toEnemy.y==0 then toEnemy = v2(1,0) end

    local offNm = offsetNmTowardFriendly or 0
    local towardEnemy = (offNm < 0)
    local wantNm = math.abs(offNm)
    local distEnemyNm = math.sqrt(bestD2) / NM
    local maxAdvNm = math.max(0, distEnemyNm - safe)
    local advNm = math.min(wantNm, maxAdvNm)
    if forwardJitterNm and forwardJitterNm > 0 then
        local extra = math.min(forwardJitterNm, math.max(0, maxAdvNm - advNm))
        advNm = advNm + extra
    end

    local dir = towardEnemy and toEnemy or v2(-toEnemy.x, -toEnemy.y)
    local p = vadd(zi.center, vmul(dir, advNm * NM))

    local md = _minDistPointToEnemiesNm(p.x, p.y, mySide)
    if md < avoidEnemyMinNm then p = vadd(p, vmul(toEnemy, -(avoidEnemyMinNm - md) * NM)) end

    return { x = p.x, y = p.y }
end




DynamicConvoy = DynamicConvoy or {}
local dc = DynamicConvoy
dc.ROUTE_CACHE = dc.ROUTE_CACHE or { attack = {}, supply = {} }
dc.TARGET_SUBZONES = dc.TARGET_SUBZONES or {}
dc.RSTATE = dc.RSTATE or (1 + math.floor((((timer and timer.getTime) and timer.getTime()) or 0) * 1000))
dc.TARGET_TAIL_CACHE = dc.TARGET_TAIL_CACHE or {}
dc.DEFAULT_SPEED = 20
dc.DEFAULT_WAYPOINTS_IN_TARGET = 8
dc.PATH_CACHE = dc.PATH_CACHE or {}
dc.OFFROAD_PENALTY = 1.25
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
    if not startV2 then env.info("DC.BAIL startV2_nil") return nil end
    if #tSubs == 0 then
        tSubs = scanTargetSubzones(targetZoneName)
        dc.TARGET_SUBZONES[targetZoneName] = tSubs
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
			return { id = "Mission", params = { route = { points = pts } } }, startV2
		end
	end
	pts[#pts+1] = ground_buildWP(startV2, "Off Road", s_kmh)
	pts[#pts].formation = frm
	pts[#pts+1] = ground_buildWP(anchorSub, "Off Road", s_kmh)
	pts[#pts].formation = frm
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
    for i = 1, #zones do
        for j = 1, #zones do
            if i ~= j then
                local a, b = zones[i], zones[j]
                local key = keyPair(a,b)
                if not dc.ROUTE_CACHE.attack[key] then dc.GetAttackConvoyRoute(a,b) end
                if not dc.ROUTE_CACHE.supply[key] then dc.GetSupplyConvoyRoute(a,b) end
            end
        end
    end
    return zones
end

function dc.GetAttackConvoyRoute(originZoneName, targetZoneName, speed)
    local key = keyPair(originZoneName, targetZoneName)
    local cached = dc.ROUTE_CACHE.attack[key]
    if cached then return cached.task, cached.startV2 end
    local task, startV2 = dc.BuildAttackConvoyRoute(originZoneName, targetZoneName, speed)
    if task and startV2 then
        dc.ROUTE_CACHE.attack[key] = { task = task, startV2 = startV2 }
    end
    return task, startV2
end

function dc.GetSupplyConvoyRoute(originZoneName, targetZoneName, speed)
    local key = keyPair(originZoneName, targetZoneName)
    local cached = dc.ROUTE_CACHE.supply[key]
    if cached then return cached.task, cached.startV2 end
    local task, startV2 = dc.BuildSupplyConvoyRoute(originZoneName, targetZoneName, speed)
    if task and startV2 then
        dc.ROUTE_CACHE.supply[key] = { task = task, startV2 = startV2 }
    end
    return task, startV2
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
		obj.saveFile = 'zoneCommander.lua'
		if savepath then
			obj.saveFile = savepath
		end
		
		if not updateFrequency then updateFrequency = 10 end
		if not saveFrequency then saveFrequency = 60 end
		
		obj.difficulty = difficulty
		obj.updateFrequency = updateFrequency
		obj.saveFrequency = saveFrequency

		obj.rankThresholds = obj.rankThresholds or {0,3000,5000,8000,12000,16000,22000,30000,45000,65000,90000}
		obj.rankNames      = obj.rankNames      or {"Recruit","Aviator","Airman","Senior Airman","Staff Sergeant","Technical Sergeant","Master Sergeant","Senior Master Sergeant","Chief Master Sergeant","Second Lieutenant","First Lieutenant"}
		
		
		setmetatable(obj, self)
		self.__index = self
		return obj
	end
	
	function BattleCommander:_jointIsSharing(p)
		return self.jointPairs and self.jointPairs[p] ~= nil
	end

	function BattleCommander:_jointPartner(p)
		return self.jointPairs and self.jointPairs[p] or nil
	end

	function BattleCommander:_jointEnd(p)
		local q = self.jointPairs and self.jointPairs[p]
		if q then
			self.jointPairs[q] = nil
			self.jointPairs[p] = nil
		end
	end

	function BattleCommander:_jointPartnerAlive(p)
		local pls = coalition.getPlayers(1)
		for _, u in pairs(pls) do
			if u and u:isExist() and u:getLife() > 0 and u:getPlayerName() == p then
				return true
			end
		end
		pls = coalition.getPlayers(2)
		for _, u in pairs(pls) do
			if u and u:isExist() and u:getLife() > 0 and u:getPlayerName() == p then
				return true
			end
		end
	end

	function BattleCommander:_jointLeave(groupid)
		self.playerNames = self.playerNames or {}
		local a = self.playerNames[groupid]
		if not a then
			trigger.action.outTextForGroup(groupid, 'No player found for this group', 10)
			return
		end
		local b = self.jointPairs and self.jointPairs[a]
		if b then
			self.jointPairs[b] = nil
			self.jointPairs[a] = nil
			trigger.action.outTextForGroup(groupid, 'Left joint mission', 15)
			local gid2 = self.groupByPlayer and self.groupByPlayer[b]
			if gid2 then
				trigger.action.outTextForGroup(gid2, '['..a..'] left the joint mission', 15)
			end
		else
			trigger.action.outTextForGroup(groupid, "You're already alone", 10)
		end
	end

	function BattleCommander:_jointGenCode(groupid, side)
		self.jointCodes = self.jointCodes or {}
		for code, data in pairs(self.jointCodes) do
			if data.gid == groupid and data.side == side then
				trigger.action.outTextForGroup(groupid, 'Joint code: ' .. code, 30)
				return
			end
		end
		local c
		repeat
			c = tostring(math.random(1000, 9999))
		until not self.jointCodes[c]
		self.jointCodes[c] = { gid = groupid, side = side }
		trigger.action.outTextForGroup(groupid, 'Joint code: ' .. c, 30)
	end

	function BattleCommander:_jointAcceptCode(groupid, code, side)
		self.jointPairs = self.jointPairs or {}
		self.playerNames = self.playerNames or {}
		local host = self.jointCodes and self.jointCodes[tostring(code)]
		if not host then
			trigger.action.outTextForGroup(groupid, 'Invalid code', 15)
			return
		end
		if host.side ~= side then
			trigger.action.outTextForGroup(groupid, 'Must be same coalition', 10)
			return
		end
		local a = self.playerNames[host.gid]
		local b = self.playerNames[groupid]
		if not a or not b then
			return
		end
		if a == b then
			trigger.action.outTextForGroup(groupid, "You can't join your own code you silly, get friends!", 15)
			return
		end
		if self.jointPairs[a] or self.jointPairs[b] then
			trigger.action.outTextForGroup(groupid, 'Already sharing', 15)
			return
		end
		self.jointPairs[a] = b
		self.jointPairs[b] = a
		self.jointCodes[tostring(code)] = nil
		trigger.action.outTextForGroup(groupid, 'Joined ' .. a, 20)
		if host.gid then
			trigger.action.outTextForGroup(host.gid, '['..b..'] joined your joint mission', 20)
		end
	end
	

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
	
function BattleCommander:addShopItem(coalition,id,ammount,prio,reqRank)
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
				if RankingSystem and reqRank then sitem.reqRank = reqRank end
			else
				self.shops[coalition][id] = {name=item.name,cost=item.cost,stock=ammount,prio=prio}
				if RankingSystem and reqRank then self.shops[coalition][id].reqRank = reqRank end
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
	
	function BattleCommander:_findNearestFriendlyAirbase(point, coalition)
		if not point then return nil end
		local px = point.x
		local pz = point.z or point.y
		if not px or not pz then return nil end
		local nearest, distM = nil, nil
		for _, z in ipairs(self.zones) do
			if z.airbaseName and z.side == coalition then
				local ab = getAirbaseByName(z.airbaseName)
				local bvec = nil
				if ab and ab.GetCoordinate then
					local coord = ab:GetCoordinate()
					if coord then bvec = coord:GetVec3() end
				elseif ab and ab.getPoint then
					bvec = ab:getPoint()
				end
				if bvec then
					local d = UTILS.VecDist2D({x=px,y=pz},{x=bvec.x,y=bvec.z})
					if (not distM) or d < distM then
						distM = d
						nearest = ab
					end
				end
			end
		end
		return nearest, distM
	end


	function BattleCommander:_enemyZoneTooClose(point, minDistance)
		for _, z in ipairs(self.zones) do
			if z.side == 1 then
				local cz = CustomZone:getByName(z.zone)
				if cz then
					local clearance = UTILS.VecDist2D({x=point.x,y=point.z},{x=cz.point.x,y=cz.point.z}) - (cz.radius or 0)
					if clearance < minDistance then
						return true, z.zone
					end
				end
			end
		end
		return false
	end

	function BattleCommander:_findFlatSpotNear(point, radius, attempts, maxSlope)
		radius = radius or 100
		attempts = attempts or 30
		maxSlope = maxSlope or 8
		local best
		for i=1,attempts do
			local ang = math.random() * math.pi * 2
			local dist = math.random() * radius
			local cand = { x = point.x + math.cos(ang) * dist, z = point.z + math.sin(ang) * dist }
			local st = land.getSurfaceType({x=cand.x,y=0,z=cand.z})
			if st ~= land.SurfaceType.RUNWAY then
				local slope = Utils.getTerrainSlopeAtPoint(cand, 20)
				if slope <= maxSlope then
					cand.y = land.getHeight({x=cand.x,y=0,z=cand.z})
					return cand
				elseif not best or slope < best.slope then
					best = { x=cand.x, z=cand.z, slope=slope }
				end
			end
		end
		if best and (not best.slope or best.slope <= maxSlope) then
			best.y = land.getHeight({x=best.x,y=0,z=best.z})
			return best
		end
		return nil
	end

	function BattleCommander:registerDynamicFarp(name, coord, side)
		self.dynamicFarpsBySide = self.dynamicFarpsBySide or { [1]={}, [2]={} }
		self.dynamicFarpsByName = self.dynamicFarpsByName or {}
		local v = coord and coord.GetVec2 and coord:GetVec2() or nil
		if not v then return end
		local s = side or 2
		local entry = { name = name, side = s, x = v.x, z = v.y }
		self.dynamicFarpsByName[name] = entry
		local list = self.dynamicFarpsBySide[s]
		list[#list+1] = entry
	end

	function BattleCommander:CopyWarehouse(FName, fromSave)
		if not FName then return end
		if not (STORAGE and STORAGE.FindByName and WEAPONSLIST and WEAPONSLIST.GetAllItems) then return end
		local dstStore = STORAGE:FindByName(FName)
		if not dstStore then return end

		local function safeSet(itemName, qty)
		if not itemName then return end
		pcall(function() dstStore:SetItem(itemName, qty) end)
		end

		for _, ammoName in ipairs(WEAPONSLIST.GetAllItems() or {}) do
			if WarehouseLogistics == true and fromSave == true then
				safeSet(ammoName, 0)
			elseif WarehouseLogistics == true then
				safeSet(ammoName, 30)
			else
				safeSet(ammoName, 1073741823)
			end
		end

		if allZones then
			allZones[#allZones + 1] = FName
		end

		  if supplyZones then
			supplyZones[#supplyZones + 1] = FName
			supplyZonesSet[FName] = true
		end  

		local unlimitedPlanes = {}
		if Era == "Coldwar" and type(allowedPlanes) == "table" then
		unlimitedPlanes = allowedPlanes
		elseif type(restockAircraft) == "table" then
		unlimitedPlanes = restockAircraft
		end
		for _, planeName in ipairs(unlimitedPlanes) do
		safeSet(planeName, 1073741823)
		end
	end


	function BattleCommander:_minEnemyDistanceNmWithFarps(z)
		local dist = self:_minEnemyDistanceNm(z)
		local farps = self.dynamicFarpsBySide
		if not farps then return dist end
		local enemySide = (z.side == 2) and 1 or 2
		local list = farps[enemySide]
		if not list or #list == 0 then return dist end
		local cz = CustomZone:getByName(z.zone)
		if not cz or not cz.point then return dist end
		local zx, zz = cz.point.x, cz.point.z
		local best2 = nil
		for i=1,#list do
			local f = list[i]
			local dx = zx - f.x
			local dz = zz - f.z
			local d2 = dx*dx + dz*dz
			if (not best2) or d2 < best2 then best2 = d2 end
		end
		if not best2 then return dist end
		local dnm = math.sqrt(best2) / 1852
		if (not dist) or dnm < dist then return dnm end
		return dist
	end


	function BattleCommander:_dispatchMarkerFarpFlight(startAb, landingPoint, customName)
		if not startAb or not landingPoint then return 'No valid airbase or landing point' end
		local template = 'BLUE_CH-47'
		self._mapFarpChinookSpawnId = (self._mapFarpChinookSpawnId or 0) + 1
		local abObj = startAb
		if startAb and (not startAb.ClassName) and startAb.getName then abObj = getAirbaseByName(startAb:getName()) end
		local landingCoord = COORDINATE:NewFromVec3({x=landingPoint.x,y=landingPoint.y or land.getHeight({x=landingPoint.x,y=0,z=landingPoint.z}),z=landingPoint.z})
		local wasAirborne = false
		local gname
		local function assignRoute()
			local g = Group.getByName(gname)
			if not g then return end
			local u = g:getUnit(1)
			if not u then return end
			local pos = u:getPoint()
			local destx, desty = landingPoint.x, landingPoint.z
			local spd = 180
			local dx, dz = destx - pos.x, desty - pos.z
			local L = math.sqrt(dx*dx + dz*dz)
			local back = 2 * 1852
			local apx = (L > 10) and (destx - dx / L * back) or destx
			local apy = (L > 10) and (desty - dz / L * back) or desty
			local task = { id='Mission', params={ route={ airborne=true, points={} } } }
			table.insert(task.params.route.points, {
				type=AI.Task.WaypointType.TURNING_POINT, x=apx, y=apy, speed=spd, speed_locked=true,
				action=AI.Task.TurnMethod.FLY_OVER_POINT, alt=1500, alt_type=AI.Task.AltitudeType.RADIO
			})
			table.insert(task.params.route.points, {
				type=AI.Task.WaypointType.TURNING_POINT, x=apx, y=apy, speed=spd, speed_locked=true,
				action=AI.Task.TurnMethod.FIN_POINT, alt=1500, alt_type=AI.Task.AltitudeType.RADIO,
				task={ id='ComboTask', params={ tasks={{ number=1, auto=false, id='Land', params={ point={ x=destx, y=desty }, duration=30, durationEnabled=true } }} } }
			})
			local c = g:getController()
			if c then c:setTask(task) end
		end
		local spawn = SPAWN:NewWithAlias(template, template..'_MAPFARP_'..tostring(self._mapFarpChinookSpawnId))
		spawn:OnSpawnGroup(function(g)
			gname = g:GetName()
			assignRoute()
		end)
		local spawned = spawn:SpawnAtAirbase(abObj or startAb, SPAWN.Takeoff.Hot)
		if not spawned then return 'Unable to launch Chinook' end
		spawned:OptionPreferVerticalLanding()
		local function monitor()
			local g = Group.getByName(gname)
			if not g then return end
			local u = g:getUnit(1)
			if not u then return timer.getTime()+20 end
			local pos = u:getPoint()
			local dx = landingPoint.x - pos.x
			local dz = landingPoint.z - pos.z
			local dist = math.sqrt(dx*dx + dz*dz)
			local isLanded = Utils.isLanded(u, true)
			if not wasAirborne then
				if not isLanded then wasAirborne = true end
				return timer.getTime()+20
			end
			if isLanded and dist <= 100 then
				BuildAFARP(landingCoord)
				g:destroy()
				return
			end
			return timer.getTime()+20
		end
		timer.scheduleFunction(function() return monitor() end, {}, timer.getTime()+20)
		return true
	end



	function BattleCommander:processMapFarpPurchase(params)
		if not params or not params.point then return 'No marker position found' end
		local coalition = params.coalition or 2
		if coalition ~= 2 then return 'Map FARPs are only available for blue coalition' end
		local pos = params.point
		local st = land.getSurfaceType({x=pos.x,y=0,z=pos.z})
		--if st == land.SurfaceType.WATER or st == land.SurfaceType.SHALLOW_WATER then return 'Cannot build FARP on water' end
		if self:getZoneOfPoint(pos) then return 'Cannot build inside another zone' end
		local tooClose, name = self:_enemyZoneTooClose(pos, 10*1852)
		if tooClose then return 'Too close to enemy zone: '..tostring(name)..' (needs 10nm clearance)' end
		local landing = self:_findFlatSpotNear(pos, 100, 40, 12)
		if not landing then return 'No suitable landing area within 100m' end
		local ab, distM = self:_findNearestFriendlyAirbase(pos, coalition)
		if not ab then return 'No available friendly airbase to launch Chinook' end
		if distM and distM > UTILS.NMToMeters(100) then return 'Too far from friendly airbase (max 100nm)' end
		return self:_dispatchMarkerFarpFlight(ab, landing, params.customName)

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
	
function BattleCommander:debit(coalition, amount, buyerGroupId, buyerGroupObj, reason, reqRank)
    if not amount or amount <= 0 then return true end
    local buyerName = "Unknown"
    if buyerGroupId and self.playerNames and self.playerNames[buyerGroupId] then
        buyerName = self.playerNames[buyerGroupId]
    elseif buyerGroupObj and buyerGroupObj.isExist and buyerGroupObj:isExist() and buyerGroupObj.getName then
        buyerName = buyerGroupObj:getName()
    elseif buyerGroupId then
        buyerName = "Group " .. tostring(buyerGroupId)
    end
    local label = reason or "CTLD action"

    local requiredRank = tonumber(reqRank) or 0
    if requiredRank > 0 and RankingSystem and buyerGroupId and self.playerNames and self.playerNames[buyerGroupId] then
        local pname = self.playerNames[buyerGroupId]
        local myRank = self:getPlayerRank(pname) or 0
        if myRank < requiredRank then
            local msg = string.format("Insufficient rank for %s. Need rank %d, you are rank %d.", label, requiredRank, myRank)
            trigger.action.outTextForGroup(buyerGroupId, msg, 12)
            return false
        end
    end

    self.accounts[coalition] = tonumber(self.accounts[coalition]) or 0
    if self.accounts[coalition] < amount then
		local msg = string.format("Our team does not have enough credits for %s. %d are needed and we currently have %d.\nMore credits are available by completing missions.", label, amount, self.accounts[coalition])
        if buyerGroupId then
            trigger.action.outTextForGroup(buyerGroupId, msg, 12)
        else
            trigger.action.outTextForCoalition(coalition, msg, 12)
        end
        return false
    end

    self.accounts[coalition] = math.max(0, self.accounts[coalition] - amount)
    self:addStat(buyerName, "Points spent", amount)
    trigger.action.outTextForCoalition(
        coalition,
        string.format("%s spent %d credits on CTLD %s.\n\n%d coalition credits remaining.",
            buyerName, amount, label, self.accounts[coalition]),
        12
    )
    return true
end


function BattleCommander:credit(coalition, amount, buyerGroupId, buyerGroupObj, reason)
    if not amount or amount <= 0 then return true end
    local buyerName = "Unknown"
    if buyerGroupId and self.playerNames and self.playerNames[buyerGroupId] then
        buyerName = self.playerNames[buyerGroupId]
    elseif buyerGroupObj and buyerGroupObj.isExist and buyerGroupObj:isExist() and buyerGroupObj.getName then
        buyerName = buyerGroupObj:getName()
    elseif buyerGroupId then
        buyerName = "Group " .. tostring(buyerGroupId)
    end
    local label = reason or "refund"
    self.accounts[coalition] = tonumber(self.accounts[coalition]) or 0
    self.accounts[coalition] = self.accounts[coalition] + amount
    local spent = ((self.playerStats or {})[buyerName] or {})["Points spent"] or 0
    local delta = -amount
    if spent + delta < 0 then delta = -spent end
    if delta ~= 0 then
        self:addStat(buyerName, "Points spent", delta)
    end

    local msg = string.format("%s — %d credits refunded.", label, amount)
    if buyerGroupId then
        trigger.action.outTextForGroup(buyerGroupId, msg, 12)
    else
        trigger.action.outTextForCoalition(coalition, msg, 12)
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
				trigger.action.outTextForGroup(buyerGroupId,"Item not found in shop",10)
			else
				trigger.action.outTextForCoalition(coalition,"Item not found in shop",10)
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
				if v.active and v.side == 0 and (not v.ForceNeutral or v.firstCaptureByRed or v.suspended)
				   and not v.isHidden
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
					trigger.action.outTextForGroup(buyerGroupId, success, 10)
				else
					trigger.action.outTextForCoalition(coalition, success, 10)
				end
			else
				if buyerGroupId then
					trigger.action.outTextForGroup(buyerGroupId, 'Not available at the current time', 10)
				else
					trigger.action.outTextForCoalition(coalition, 'Not available at the current time', 10)
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

	local pname = (self.playerNames and self.playerNames[groupId]) or nil
	if (not pname) and groupObj and groupObj:isExist() then
		local u = groupObj:getUnit(1)
		if u then pname = u:getPlayerName() end
	end
	local myRank = self:getPlayerRank(pname) or 0

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
		local req = info.data.reqRank
		if (not req) or (myRank >= req) then
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
        if (not v.isHidden) and (targetzoneside == nil or v.side == targetzoneside) and (not allow or allow[v.zone]) and (not v.suspended) then
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
	self._emergencyNeutralZoneMenus = self._emergencyNeutralZoneMenus or {}
	local key = tostring(coalition) .. "|" .. tostring(menuname)
	local st = self._emergencyNeutralZoneMenus[key]
	if not st then
		st = { menu=nil, items={}, callback=nil }
		self._emergencyNeutralZoneMenus[key] = st
	end
	st.callback = callback or st.callback
	for i=1,#st.items do
		missionCommands.removeItemForCoalition(coalition, st.items[i])
	end
	st.items = {}
	if not st.callback then return st.menu end

	local eligible = 0
	for _, v in ipairs(self.zones) do
		if v.active and v.side == 0 and (not v.ForceNeutral or v.firstCaptureByRed or v.suspended)
		   and not v.isHidden
		then
			eligible = eligible + 1
		end
	end
	if eligible == 0 and not st.menu and callback then
		return 'No eligible neutral zones'
	end

	if not st.menu then
		st.menu = missionCommands.addSubMenuForCoalition(coalition, menuname)
	end

	if eligible > 0 then
		for _, v in ipairs(self.zones) do
			if v.active and v.side == 0 and (not v.ForceNeutral or v.firstCaptureByRed or v.suspended)
			   and not v.isHidden
			then
				st.items[#st.items+1] = missionCommands.addCommandForCoalition(coalition, v.zone, st.menu, st.callback, v.zone)
			end
		end
	end

	return st.menu
end
	
function findNearestAvailableSupplyCommander(chosenZone)
		local bestAir=nil
		local bestAirDist=99999999
		local bestSurface=nil
		local bestSurfaceDist=99999999
		for _,zC in ipairs(bc.zones) do
			if zC.side==2 and zC.active then
				for _,grpCmd in ipairs(zC.groups) do
					if grpCmd.mission=='supply' and grpCmd.side==2 and not grpCmd.suspended and grpCmd.targetzone==chosenZone.zone then
						local st=grpCmd.state
						if st=='preparing' or st=='takeoff' or st=='inair' or st=='landed' or st=='enroute' or st=='atdestination' then
							return nil,'inprogress'
						elseif st=='dead' or st=='inhangar' then
							local znA=zC.zone
							local znB=chosenZone.zone
							local dist=ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB] or 99999999
							if grpCmd.type~='surface' then
								if dist<bestAirDist then bestAirDist=dist bestAir=grpCmd end
							else
								if dist<bestSurfaceDist then bestSurfaceDist=dist bestSurface=grpCmd end
							end
						end
					end
				end
			end
		end
		if bestAir then return bestAir,nil end
		if bestSurface then return bestSurface,nil end
		return nil,nil
	end





function measureDistanceZoneToZone(zoneA,zoneB)

	local czA=zoneA._cz or CustomZone:getByName(zoneA.zone)
	local czB=zoneB._cz or CustomZone:getByName(zoneB.zone)
	
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
		env.info('Engage zone '..tgtzone..' by group '..groupname)
		if group and zn.side == group:getCoalition() then
			return 'Can not engage friendly zone'
		end
		
		if not group then
			return 'Not available'
		end
		
		local cnt=group:getController()
		cnt:popTask()
		
		local expCount = AI.Task.WeaponExpend.ONE
		if expendAmmount then
			expCount = expendAmmount
		end
		
		local wepType = Weapon.flag.AnyWeapon
		if weapon then
			wepType = weapon
		end
		
		for i,v in pairs(zn.built) do
			local g = Group.getByName(v)
			if g then
				local task = { 
				  id = 'AttackGroup', 
				  params = { 
					groupId = g:getID(),
					expend = expCount,
					weaponType = wepType,
					groupAttack = true
				  } 
				}
				
				cnt:pushTask(task)
			else
				local s = StaticObject.getByName(v)
				if s then
					local task = { 
					  id = 'AttackUnit', 
					  params = { 
						groupId = s:getID(),
						expend = expCount,
						weaponType = wepType,
						groupAttack = true
					  } 
					}
					
					cnt:pushTask(task)
				end
			end
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
		extraUpgrade      = {},
		lat_long 	  	  = v.lat_long,
		logisticCenter   = (v.LogisticCenter == true)
        }
        if v.extraUpgrade then
            for _,grp in ipairs(v.extraUpgrade) do
                if type(grp)=="table" and grp.side then
                    table.insert(states.zones[v.zone].extraUpgrade, {side=grp.side, name=grp.name})
                else
                    table.insert(states.zones[v.zone].extraUpgrade, {side=v.side, name=grp})
                end
            end
		end
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
	if ewrs and ewrs.exportPlayerSettings then
		states.ewrsSettings = ewrs.exportPlayerSettings()
	end

    if not self.zonesDetails_cache then
        self.zonesDetails_cache = {}
        local zonesCount = 0
        for i,v in ipairs(self.zones) do
            local cleanFlavorText = nil
            if v.flavorText then
                -- Remove trailing newlines and whitespace from flavorText
                cleanFlavorText = v.flavorText:gsub("[\n\r]+$", ""):gsub("^%s+", ""):gsub("%s+$", "")
            end
            self.zonesDetails_cache[v.zone] = {
                flavorText = cleanFlavorText,
                hidden     = v.isHidden or false
            }
            zonesCount = zonesCount + 1
        end
    end
    states.zonesDetails = self.zonesDetails_cache or {}

    -- Add active missions
    if mc and mc.missions then
		states.missions = {}
		local activeMissionCount = 0
        for _, mission in pairs(mc.missions) do
            if mission.isRunning or (mission.isActive and mission:isActive()) then
                local missionTitle = type(mission.title) == "function" and mission.title() or mission.title
                local missionDescription = type(mission.description) == "function" and mission.description() or mission.description
                local missionInfo = {
                    title = missionTitle,
                    description = missionDescription,
                    isRunning = mission.isRunning,
                    isEscortMission = mission.isEscortMission or false
                }
                table.insert(states.missions, missionInfo)
                activeMissionCount = activeMissionCount + 1
            end
        end
    else
        env.info("MissionCommander (mc) not available or has no missions")
    end

    -- Add connections schema
    if not self.connections_cache then
        self.connections_cache = {}
		local connectionCount = 0
        if self.connections then
            for _, connection in pairs(self.connections) do
				table.insert(self.connections_cache, {
					from = connection.from,
					to = connection.to
				})
				connectionCount = connectionCount + 1
            end
        end
    end
    states.connections = self.connections_cache or {}

    -- Add players positions
    states.players = {}
    local nbPlayers = 0
    if self.playersState then
        for _, playerTable in ipairs(self.playersState) do
            table.insert(states.players, playerTable)
            nbPlayers = nbPlayers + 1
        end
    end

    -- Add ejected pilots positions
    states.ejectedPilots = {}
    local nbEjectedPilots = 0
    if lc and lc.ejectedPilotsState then
        for _, ejectedPilotTable in ipairs(lc.ejectedPilotsState) do
            table.insert(states.ejectedPilots, ejectedPilotTable)
            nbEjectedPilots = nbEjectedPilots + 1
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
			local z = v._cz or CustomZone:getByName(v.zone)
			if z and z:isInside(point) then
				return v
			end
		end
		
		return nil
	end
	
	function BattleCommander:addZone(zone)
		if zone and zone.zone and zone.isHidden == nil then
			zone.isHidden = zone.zone:lower():find("hidden", 1, true) ~= nil
		end
			table.insert(self.zones, zone)
			zone.index = self:getZoneIndexByName(zone.zone)+3000
			zone.battleCommander = self
			self.indexedZones[zone.zone] = zone
			self:refreshConnectionCache()
	end

	function BattleCommander:addZone(zone)
		if zone and zone.zone and zone.isHidden == nil then
			zone.isHidden = zone.zone:lower():find("hidden", 1, true) ~= nil
		end
			zone._cz = CustomZone:getByName(zone.zone)
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
		self:_cacheConnectionZones()
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
					local zn=v2._cz or CustomZone:getByName(v2.zone)
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
		local nearestBlue = {}
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
				if zoneB.side == 2 then
					local current = nearestBlue[znA]
					if (not current) or dist < current then nearestBlue[znA] = dist end
				end
				if zoneA.side == 2 then
					local current = nearestBlue[znB]
					if (not current) or dist < current then nearestBlue[znB] = dist end
				end
			end
		end
		ZONE_NEAREST_BLUE = nearestBlue
		ZONE_NEAR_BLUE = {}
		for _, zoneObj in ipairs(self.zones) do
			local znA = zoneObj.zone
			local best = nearestBlue[znA]
			if zoneObj.side == 1 and best and best <= NEAR_BLUE_METERS then
				ZONE_NEAR_BLUE[znA] = true
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
											--env.info("[DEBUG roamGroupsToLocalSubZone] Sending "..gpName.." -> "..zoneSub.." formation="..formation.." speed="..s)
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
					toprint = toprint..'\nupgradeallblue: - upgrade all blue zones to the max.'
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

					local myRank = 0
					if RankingSystem and event.initiator and event.initiator.getPlayerName then
						local pn = event.initiator:getPlayerName()
						if pn and self.context.getPlayerRank then myRank = self.context:getPlayerRank(pn) or 0 end
					end

					toprint = toprint..'\n'
					local sorted = {}
					for i,v in pairs(self.context.shops[event.coalition]) do
						if not RankingSystem or not v.reqRank or myRank >= v.reqRank then
						table.insert(sorted,{i,v})
						end
					end
					table.sort(sorted, function(a,b) return a[2].name < b[2].name end)

					for i2,v2 in ipairs(sorted) do
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
					local gid = event.initiator and event.initiator:getGroup():getID() or nil
					local gobj = event.initiator and event.initiator:getGroup() or nil

					local myRank = 0
					local pn = event.initiator and event.initiator.getPlayerName and event.initiator:getPlayerName() or nil
					if RankingSystem and pn and self.context.getPlayerRank then myRank = self.context:getPlayerRank(pn) or 0 end
                    	local shopItem = item and self.context.shops[event.coalition] and self.context.shops[event.coalition][item] or nil

					if RankingSystem and shopItem and shopItem.reqRank and myRank < shopItem.reqRank then
						local credits = 0
						if pn and self.context and self.context.getPlayerCredits then credits = self.context:getPlayerCredits(pn) or 0 elseif pn and self.getPlayerCredits then credits = self:getPlayerCredits(pn) or 0 end
						local rankThresholds = (self.context and self.context.rankThresholds) or self.rankThresholds or {}
						local nextT = rankThresholds[myRank+1]
						local curNm = (self.context and self.context.getRankName and self.context:getRankName(myRank)) or (self.getRankName and self:getRankName(myRank)) or tostring(myRank)
						local nextNm = (self.context and self.context.getRankName and self.context:getRankName(myRank+1)) or (self.getRankName and self:getRankName(myRank+1)) or tostring(myRank+1)
						local reqNm  = (self.context and self.context.getRankName and self.context:getRankName(shopItem.reqRank)) or (self.getRankName and self:getRankName(shopItem.reqRank)) or tostring(shopItem.reqRank)
						local remainLine = nextT and ('Remaining until '..(nextNm or (myRank+1))..': '..math.max(0, nextT - credits)..'') or 'To next: Max'
						local toprint = 'Player: '..(pn or 'Unknown')..'\nInsufficient rank for ['..(shopItem and shopItem.name or item)..']\nRequired Rank: '..reqNm..'\nYour Rank: '..curNm..'\n'..remainLine
						if gid then
							trigger.action.outTextForGroup(gid, toprint, 10)
						else
							trigger.action.outTextForCoalition(event.coalition, toprint, 10)
						end
					else
						self.context:buyShopItem(event.coalition,item,{zone = zn, point=event.pos, coalition = event.coalition, customName = customName}, gid, gobj)
					end
					success = true
					end
				end
				if event.text:find('^adminbuy') then
					if event.text == 'adminbuy' then
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
					elseif event.text:find('^adminbuy\:') then
						local item = event.text:gsub('^adminbuy\:', '')
						local zn = self.context:getZoneOfPoint(event.pos)
						self.context:buyShopItem(event.coalition,item,{zone = zn, point=event.pos})
						success = true
					end
				end
				if event.text=='debug' then
					local z = bc:getZoneOfPoint(event.pos)
					if z then
						local anyResolved = false
						env.info('-----------------------------------debug '..z.zone..'------------------------------------------')
						for i,v in pairs(z.built) do
							local gr = Group.getByName(v)
							if gr then
								anyResolved = true
								env.info(gr:getName()..' '..gr:getSize()..'/'..gr:getInitialSize())
								for i2,u in ipairs(gr:getUnits()) do
									env.info('-'..u:getName()..' '..u:getLife()..'/'..u:getLife0())
								end
							else
								local st = StaticObject.getByName(v)
								if st then
									anyResolved = true
									local life  = (st.getLife  and st:getLife())  or 0
									local life0 = (st.getLife0 and st:getLife0()) or math.max(life,1)
									local pct   = math.floor((life / life0) * 100 + 0.5)
									env.info('Static: '..v..' '..pct..'%')
								else
									if not z.suspended then
										env.info('Dangling entry in built: '..tostring(v)..' (no Group/Static found)')
									end
								end
							end
						end
						if not anyResolved and not z.suspended then
							local list='{}'
							do
								local t={} for _,n in pairs(z.built) do t[#t+1]=tostring(n) end
								if #t>0 then list='{ '..table.concat(t,', ')..' }' end
							end
							env.info('Built table (unresolved entries): '..list)
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
				if event.text=='upgradeallblue' then
					upgradeBlueZones()
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
                if event.text and event.text:lower():find('^additems') then
                    local zn = self.context:getZoneOfPoint(event.pos)
                    local gid = event.initiator and event.initiator:getGroup():getID() or nil

					if (not (zn and zn.zone))  then
						local p = event.pos
						local alt = land.getHeight({x=p.x,y=p.z})
						local coord = COORDINATE:New(p.x,alt,p.z)
						for i = 1, #supplyZones do
							local zoneName = supplyZones[i]
							local mooseZone = ZONE:FindByName(zoneName)
							if mooseZone and mooseZone:IsCoordinateInZone(coord) then
								zn = { zone = zoneName }
								break
							end
						end
					end

                    local s = tostring(event.text)
                    local amtStr = s:match("^[Aa][Dd][Dd][Ii][Tt][Ee][Mm][Ss]%s*:%s*(%d+)%s*$")
                    local amount = tonumber(amtStr) or 50

                    local ok, msg = self.context:addWarehouseItemsAtZone(zn, event.coalition, amount)
                    if gid then
                        trigger.action.outTextForGroup(gid, msg, 12)
                    else
                        trigger.action.outTextForCoalition(event.coalition, msg, 12)
                    end

                    trigger.action.removeMark(event.idx)
                    success = true
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
				if event.text=='whynot' then
					local zn = self.context:getZoneOfPoint(event.pos)
					if zn then
						local gid = event.initiator and event.initiator:getGroup():getID() or nil
						self.context:explainSuspendDecision(zn.zone, gid)
					end
					trigger.action.removeMark(event.idx)
					success = true
				end
				if event.text and event.text:lower():find('^farphere') then
					local gid = event.initiator and event.initiator:getGroup():getID() or nil
					local gobj = event.initiator and event.initiator:getGroup() or nil
					local params = { zone = self.context:getZoneOfPoint(event.pos), point = event.pos, coalition = event.coalition }
					self.context:buyShopItem(event.coalition,'farphere',params,gid,gobj)
					trigger.action.removeMark(event.idx)
					success=true
				end
				if event.text and event.text:lower():find('^givemefarp') then
					local p=event.pos
					local alt=land.getHeight({x=p.x,y=p.z})
					local coord=COORDINATE:New(p.x,alt,p.z)
					BuildAFARP(coord)
					trigger.action.removeMark(event.idx)
					success=true
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

	function BattleCommander:init()
		self:startMonitorPlayerMarkers()
		self:initializeRestrictedGroups()

		if self.difficulty then
			self.lastDiffChange = timer.getAbsTime()
		end

		table.sort(self.zones, function(a, b) return a.zone < b.zone end)
		for i, v in ipairs(self.zones) do
			local n = v and v.airbaseName
			if n and n ~= '' then
				getAirbaseByName(n)
				getDcsAirbaseByName(n)
			end
			v:init()
		end

--[[ 		for i, v in ipairs(self.connections) do
			local from = CustomZone:getByName(v.from)
			local to = CustomZone:getByName(v.to)
			if from and to then
				local function edgePoint(a,b)
					local sx,sy,sz = a.point.x, a.point.y, a.point.z
					local ox,oz    = b.point.x, b.point.z
					local dx,dz    = ox - sx, oz - sz
					local len      = math.sqrt(dx*dx + dz*dz)
					if len == 0 then return {x = sx, y = sy, z = sz} end
					local ux,uz    = dx/len, dz/len
					if a:isCircle() then
						return {x = sx + ux * a.radius, y = sy, z = sz + uz * a.radius}
					elseif a:isQuad() and a.vertices and #a.vertices >= 3 then
						local bestT = nil
						local function cross(ax,az,bx,bz) return ax*bz - az*bx end
						for idx = 1, #a.vertices do
							local v1 = a.vertices[idx]
							local v2 = a.vertices[(idx % #a.vertices) + 1]
							local ex,ez = v2.x - v1.x, v2.z - v1.z
							local qpx,qpz = v1.x - sx, v1.z - sz
							local denom = cross(ux,uz,ex,ez)
							if math.abs(denom) > 1e-6 then
								local t = cross(qpx,qpz,ex,ez) / denom
								local u = cross(qpx,qpz,ux,uz) / denom
								if t >= 0 and u >= 0 and u <= 1 then
									if not bestT or t < bestT then bestT = t end
								end
							end
						end
						if bestT then
							return {x = sx + ux * bestT, y = sy, z = sz + uz * bestT}
						end
					end
					return {x = sx, y = sy, z = sz}
				end
				local p1 = edgePoint(from, to)
				local p2 = edgePoint(to, from)
				trigger.action.lineToAll(-1, 1000 + i, p1, p2, {1, 1, 1, 0.5}, 2)
			end
		end ]]
		self:DrawConnectionLines()


		--missionCommands.addCommandForCoalition(1, 'Budget overview', nil, self.printShopStatus, self, 1)
		--missionCommands.addCommandForCoalition(2, 'Budget overview', nil, self.printShopStatus, self, 2)

		--self:refreshShopMenuForCoalition(1)
		--self:refreshShopMenuForCoalition(2)
	SCHEDULER:New(self,function(o)o:_autoZoneSuspend()end,{},1,60)
	SCHEDULER:New(self,function(o)o:_proximityWakeSuspendedZones()end,{},10,30)
	SCHEDULER:New(self,function(o)o:update()end,{},2,self.updateFrequency)
	SCHEDULER:New(self,function(o)o:saveToDisk()end,{},30,self.saveFrequency)
end


function BattleCommander:restaggerCapHangarDelays()
    local byKey={}
    for _,zc in ipairs(self.zones or {}) do
        for _,gc in ipairs(zc.groups or {}) do
            if gc and gc.MissionType=='CAP' and (gc.mission=='patrol' or gc.mission=='attack') and gc.state=='inhangar' and gc.targetzone then
                local k=gc.targetzone.."|"..tostring(gc.side).."|"..gc.mission
                local t=byKey[k]; if not t then t={} byKey[k]=t end
                t[#t+1]=gc
            end
        end
    end
    for _,list in pairs(byKey) do
        local ranked,unranked,times={}, {}, {}
        for i=1,#list do
            local gc=list[i]
            local ri=CapRankIndex and CapRankIndex[gc.name]
            if ri and ri.rank then ranked[#ranked+1]={gc=gc,rank=ri.rank} else unranked[#unranked+1]=gc end
            times[#times+1]=gc.lastStateTime or 0
        end
        if #ranked>0 then
            table.sort(ranked,function(a,b) return a.rank<b.rank end)
            table.sort(times)
            local ti=1
            for i=1,#ranked do ranked[i].gc.lastStateTime=times[ti]; ti=ti+1 end
            for i=1,#unranked do unranked[i].lastStateTime=times[ti]; ti=ti+1 end
        end
    end
end


CapSpawnBucket=CapSpawnBucket or { [1]={ patrol={}, attack={} }, [2]={ patrol={}, attack={} } }
CapTargets=CapTargets or { [1]={ patrol={}, attack={} }, [2]={ patrol={}, attack={} } }
CapRankIndex=CapRankIndex or {}
CapRef = CapRef or {}
CapAnchors=CapAnchors or { [1]={ patrol={}, attack={} }, [2]={ patrol={}, attack={} } }
CapAnchorRowByZoneName=CapAnchorRowByZoneName or {}



function BattleCommander:buildCapSpawnBuckets()
    local t_sort=table.sort
    local missions={'patrol','attack'}
    for s=1,2 do
        CapSpawnBucket[s]=CapSpawnBucket[s] or { patrol={}, attack={} }; CapSpawnBucket[s].patrol={}; CapSpawnBucket[s].attack={}
        CapTargets[s]=CapTargets[s] or { patrol={}, attack={} }; CapTargets[s].patrol={}; CapTargets[s].attack={}
        CapAnchors[s]=CapAnchors[s] or { patrol={}, attack={} }; CapAnchors[s].patrol={}; CapAnchors[s].attack={}
    end
    CapRankIndex={}
    CapRef={}

    local tmp={ [1]={ patrol={}, attack={} }, [2]={ patrol={}, attack={} } }
    local anchorSet={}
    for _,zc in ipairs(self.zones or {}) do
        for _,gc in ipairs(zc.groups or {}) do
            if gc and (gc.type=='air' or gc.type=='carrier_air') and gc.MissionType=='CAP' and (gc.mission=='patrol' or gc.mission=='attack') and gc.targetzone then
                anchorSet[gc.targetzone]=true
                local row=ZONE_DISTANCES and ZONE_DISTANCES[zc.zone]
                local d=(row and row[gc.targetzone]) or 1000000000000
                local s=gc.side
                local m=gc.mission
                local bucket=tmp[s][m]
                local bucketByZone=bucket[gc.targetzone]
                if not bucketByZone then bucketByZone={} bucket[gc.targetzone]=bucketByZone end
                local idx=#bucketByZone+1
                bucketByZone[idx]={name=gc.name,origin=zc.zone,dist=d,state=gc.state}
                CapRef[gc.name]=gc
            end
        end
    end
    for s=1,2 do
        local mtab=tmp[s]
        if mtab then
            for _,m in ipairs(missions) do
                local ttab=mtab[m]
                if ttab then
                    for tz,list in pairs(ttab) do
                        t_sort(list,function(a,b) if a.dist==b.dist then if a.origin==b.origin then return a.name<b.name else return a.origin<b.origin end end return a.dist<b.dist end)
                local names={}
                local t={ candidates={}, ranksByName={} }
                for i=1,#list do
                    local rec=list[i]
                    local nm=rec.name
                    names[i]=nm
                    t.candidates[i]=rec
                    t.ranksByName[nm]=i
                    CapRankIndex[nm]={side=s,mission=m,target=tz,rank=i}
                end
					CapSpawnBucket[s][m][tz]=names
					CapTargets[s][m][tz]=t
                    end
                end
            end
        end
    end
    local anchors={}
    for z,_ in pairs(anchorSet) do
        local cz=CustomZone:getByName(z)
        if cz then anchors[#anchors+1]={zoneName=z} end
    end
     t_sort(anchors,function(a,b) return a.zoneName<b.zoneName end)
    for s=1,2 do
        for _,m in ipairs(missions) do
            CapAnchors[s][m]=anchors
        end
    end
	CapAnchorRowByZoneName={}
    for _, z in ipairs(self.zones or {}) do
        local cz=CustomZone:getByName(z.zone)
        if cz then CapAnchorRowByZoneName[z.zone]=ZONE_DISTANCES[z.zone] end
    end
    self:restaggerCapHangarDelays()
    self:buildNonCapSpawnBuckets()
end

function BattleCommander:updateBlueZoneCount()
	local n = 0
	local blueActiveZones = {}
	local blueAirbaseZones = {}
	local airbaseNames = {}
	local airbaseSeen = {}
	-- For warehouse persistence we also keep a list that includes suspended zones
	-- (as long as they are blue & active & not hidden).
	local airbaseNamesWarehouse = {}
	local airbaseSeenWarehouse = {}

	for _, z in ipairs(self.zones) do
		if z.side == 2 and z.active and not z.isHidden and not z.suspended then
			n = n + 1
			blueActiveZones[#blueActiveZones + 1] = z

			local abName = z.airbaseName
			if abName and abName ~= '' then
				blueAirbaseZones[#blueAirbaseZones + 1] = z
				if not airbaseSeen[abName] then
					airbaseSeen[abName] = true
					airbaseNames[#airbaseNames + 1] = abName
				end
			end
		end

		-- Warehouse persistence: include suspended blue zones too.
		if z.side == 2 and z.active and not z.isHidden then
			local abName = z.airbaseName
			if abName and abName ~= '' then
				if not airbaseSeenWarehouse[abName] then
					airbaseSeenWarehouse[abName] = true
					airbaseNamesWarehouse[#airbaseNamesWarehouse + 1] = abName
				end
			end
		end
	end
	table.sort(airbaseNames)
	table.sort(airbaseNamesWarehouse)
	self.blueZoneCount = n > 2 and n - 2 or 0
	self._blueActiveZones = blueActiveZones
	self._blueAirbaseZones = blueAirbaseZones
	self._blueAirbaseNames = airbaseNames
	self._blueAirbaseNamesWarehouse = airbaseNamesWarehouse
end

SCHEDULER:New(nil, function()
        bc:updateBlueZoneCount()
end, {}, 0.1)


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
							local shouldSpawn = gc:shouldSpawn()
							if mission == 'attack' then
								if shouldSpawn or gc.state=='takeoff' or gc.state=='inair' or gc.state=='landed' or gc.state=='enroute' or gc.state=='atdestination' then
									if originName then activeOrigins[originName] = true end
								end
							end
							local tz = self:getZoneByName(targetName)
							if tz and tz.active and not tz.suspended and tz.side ~= 0 then
								local tzName = tz.zone
								if tzName and not tzName.isHidden then
									if shouldSpawn or gc.state=='takeoff' or gc.state=='inair' or gc.state=='landed' or gc.state=='enroute' or gc.state=='atdestination' then
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

	local rngPlane = 15*1852
	local searchPlane = InvisibleA10 and
		{ id='EngageTargets', params={ maxDist=rngPlane, maxDistEnabled=true, targetTypes={'Multirole fighters','Interceptors','Bombers'} } } or
		{ id='EngageTargets', params={ maxDist=rngPlane, maxDistEnabled=true, targetTypes={'Planes'} } }
	local pts = mis.params.route.points
	if pts then
		if pts[2] and pts[2].task and pts[2].task.params and pts[2].task.params.tasks then table.insert(pts[2].task.params.tasks, searchPlane) end
		if pts[3] and pts[3].task and pts[3].task.params and pts[3].task.params.tasks then table.insert(pts[3].task.params.tasks, searchPlane) end
	end

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
		local zn = bc.indexedZones[targetZoneName]
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
		miss:AddConditionSuccess(function() local z=bc.indexedZones[targetZoneName]; return z and z.side==0 end)
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
		local zn = bc.indexedZones[targetZoneName]
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
		miss:AddConditionSuccess(function() local z=bc.indexedZones[targetZoneName]; return z and z.side==0 end)
		miss:SetWeaponExpend(expend or AI.Task.WeaponExpend.ONE)
		miss:SetEngageAsGroup(false)
		miss:SetMissionSpeed(160)
		fg:AddMission(miss)
	end

	Runway_Bomb_MISSION = Runway_Bomb_MISSION or {}
	function BattleCommander:EngageRunwayBombAuftrag(homeBase, targetZoneName, groupName, altitudeFt, coalitionSide)
		local gr = GROUP:FindByName(groupName); if not gr or not gr:IsAlive() then return end
		local fg = FLIGHTGROUP:New(gr)
		FG_BY_GROUP[groupName] = fg
		if self.side == 2 then fg:SwitchInvisible(true) end
		local zn = self:getZoneByName(targetZoneName) if not zn then return end
		local abName = zn and zn.airbaseName or nil
		if abName then
		fg:SetHomebase(homeBase)
		
		local Airdrome = getAirbaseByName(abName)
				fg:GetGroup():SetOptionRadioSilence(true)


		local altitudeFt = altitudeFt or 25000
		local miss = AUFTRAG:NewBOMBRUNWAY(Airdrome,altitudeFt)
			Runway_Bomb_MISSION[groupName] = miss
			local tgZone = zn
			miss:AddConditionFailure(function() return fg and (tgZone.side == self.side or tgZone.side == 0) end)
			--local miss = AUFTRAG:NewBAI(setGroup, altitudeFt)
			--miss.missionWaypointOffsetNM = 20
			miss:SetEngageAsGroup(true)
			miss:SetMissionSpeed(450)
			fg:AddMission(miss)
			function fg:OnAfterDead(From, Event, To)
				self:__Stop(3)
			end
		end
	end

	function BattleCommander:EngageAntiShipMission(tgtzone, groupname, expendAmmount, weapon, altitude, landUnitID)
		local zn = self:getZoneByName(tgtzone)
		local group = Group.getByName(groupname)
		if group and zn.side == group:getCoalition() then return 'Can not engage friendly zone' end
		if not group then return 'Not available' end

		local expCount = AI.Task.WeaponExpend.ALL
		if expendAmmount then expCount = expendAmmount end

		local altm = 4572
		if altitude then altm = altitude/3.281 end

		local attack = { id = 'ComboTask', params = { tasks = {} } }

		local firstpos = nil
		local own = group:getUnit(1):getPoint()
		local cand = {}
		for _, v in pairs(zn.built) do
			local gg = Group.getByName(v)
			if gg and gg:getSize()>0 then
				local u = gg:getUnit(1)
				if u and u:isExist() and u:getDesc() and u:getDesc().category == Unit.Category.SHIP then
					local p = u:getPoint()
					local dx,dy = p.x-own.x, p.z-own.z
					local d2 = dx*dx + dy*dy
					table.insert(cand, { d2=d2, gg=gg, pos=p })
				end
			end
		end
		table.sort(cand, function(a,b) return a.d2 < b.d2 end)
		local maxTargets = 3
		for i=1, math.min(#cand, maxTargets) do
			local gg = cand[i].gg
			local t = { id='AttackGroup', params={ groupId=gg:getID(), expend=expCount, altitudeEnabled=true, altitude=altm } }
			if weapon then t.params.weaponType = weapon end
			table.insert(attack.params.tasks, t)
			if not firstpos then firstpos = cand[i].pos end
		end

		if #attack.params.tasks == 0 then return 'No ship targets' end

		local startPos = group:getUnit(1):getPoint()
		local mis = self:getDefaultWaypoints(startPos, attack, firstpos, altm, landUnitID)

		local rng = 30 * 1852
		local search2 = { number=1, auto=false, id='EngageTargets', enabled=true, params={ maxDist=rng, maxDistEnabled=true, targetTypes={ 'Ships' }, priority=0 } }
		local search3 = { number=2, auto=false, id='EngageTargets', enabled=true, params={ maxDist=rng, maxDistEnabled=true, targetTypes={ 'Ships' }, priority=0 } }
		local pts = mis.params.route.points
		if pts then
			if pts[2] and pts[2].task and pts[2].task.params and pts[2].task.params.tasks then
				table.insert(pts[2].task.params.tasks, search2)
			end
			if pts[3] and pts[3].task and pts[3].task.params and pts[3].task.params.tasks then
				table.insert(pts[3].task.params.tasks, search3)
			end
		end

		group:getController():setTask(mis)
		--self:setDefaultAGSHIP(group)
		self:setDefaultAG(group)
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
		local zn = bc.indexedZones[targetZoneName]
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
		miss:AddConditionSuccess(function() local z=bc.indexedZones[targetZoneName]; return z and z.side==0 end)

		fg:AddMission(miss)
	end
--[[ 
function BattleCommander:EngageHeloCasMission(tgtzone, groupname, expendAmmount, altitudeFt, landUnitID)
	local zn = self:getZoneByName(tgtzone)
	local group = Group.getByName(groupname)
	if zn and zn.suspended then if group and group:isExist() then group:destroy() end return end
	if group and zn and zn.side == group:getCoalition() then return 'Can not engage friendly zone' end
	if not group or not group:isExist() or group:getSize()==0 then return 'Not available' end

	local startPos = group:getUnit(1):getPoint()
	local expCount = expendAmmount or AI.Task.WeaponExpend.ONE
	local alt = ((altitudeFt and altitudeFt > 0) and (altitudeFt/3.281)) or (300/3.281)
	local rng = 10 * 1852

	local viable = {}
	if zn and zn.built then
		for _, name in ipairs(zn.built) do
			local g = Group.getByName(name)
			if g and g:getCoalition() ~= group:getCoalition() then viable[#viable+1] = name end
		end
	end

	local c = zoneCentroid and zoneCentroid(zn.zone) or nil
	local tx, tz = c and c.x or startPos.x, c and c.y or startPos.z
	local dx, dz = tx - startPos.x, tz - startPos.z
	local len = math.sqrt(dx*dx + dz*dz) ; if len <= 0 then len = 1 end
	local ux, uz = dx/len, dz/len

	local midx, midz = startPos.x + ux*(1*1852), startPos.z + uz*(1*1852)
	local apx,  apz  = tx        - ux*(4*1852),  tz        - uz*(4*1852)

	local mis = { id='Mission', params={ route={ airborne=true, points={} } } }

	table.insert(mis.params.route.points, {
		type=AI.Task.WaypointType.TURNING_POINT,
		x=midx, y=midz, speed=70,
		action=AI.Task.TurnMethod.FLY_OVER_POINT,
		alt=alt, alt_type=AI.Task.AltitudeType.RADIO
	})

	table.insert(mis.params.route.points, {
		type=AI.Task.WaypointType.TURNING_POINT,
		x=apx, y=apz, speed=70,
		action=AI.Task.TurnMethod.FLY_OVER_POINT,
		alt=alt, alt_type=AI.Task.AltitudeType.RADIO
	})

	local landParams = {
		type=AI.Task.WaypointType.LAND,
		x=startPos.x, y=startPos.z, speed=70,
		action=AI.Task.TurnMethod.FIN_POINT,
		alt=alt, alt_type=AI.Task.AltitudeType.RADIO,
		task={ id='Land', params={ point={ x=startPos.x, y=startPos.z } } }
	}
	if landUnitID then landParams.linkUnit = landUnitID ; landParams.helipadId = landUnitID end
	table.insert(mis.params.route.points, landParams)

	local mooseGr = GROUP:FindByName(groupname)
	if mooseGr then
		local wp1 = mis.params.route.points[1]
		local tlist = {}
		tlist[#tlist+1] = mooseGr:EnRouteTaskEngageTargets(rng, {'Ground Units'}, 0)
		for _, name in ipairs(viable) do
			local g = GROUP:FindByName(name)
			if g and g:IsAlive() and g:GetCoalition() ~= group:getCoalition() then
				tlist[#tlist+1] = mooseGr:EnRouteTaskEngageGroup(g, 1, nil, expCount, 1, nil, alt, false)
			end
		end
		if #tlist > 0 then mooseGr:SetTaskWaypoint(wp1, mooseGr:TaskCombo(tlist)) end
	end

	group:getController():setTask(mis)
	self:setDefaultAG(group)
end
 ]]


function SetUpCAP(group, point, altitudeFt, rangeNm, landUnitID, bufferNm, side)
	if not group or not group:isExist() or group:getSize()==0 then return end
	local unit = group:getUnit(1)
	if not unit or not unit:isExist() then return end
	local startPos = unit:getPoint()
	if not startPos or startPos == nil then return end

	local rng = (rangeNm or 25) * NM
	local altm = (altitudeFt or 15000) * 0.3048

	local search = {
		id = 'EngageTargets',
		params = {
			maxDist = rng,
			maxDistEnabled = true,
			targetTypes = InvisibleA10 and { 'Multirole fighters','Interceptors','Bombers' } or ((side == 2) and { 'Planes','Helicopters' } or { 'Planes' }),
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
	if Frontline._zoneInfo and bufNm > 0 then
		local side
		if not side then side = group:getCoalition() end
		local best,bd = nil,1e18
		for name,info in pairs(Frontline._zoneInfo) do
			if info and info.center and info.side ~= nil and info.side ~= 0 and info.side ~= side and info.active ~= false then
				local dx0,dy0 = point.x - info.center.x, point.z - info.center.y
				local d2 = dx0*dx0 + dy0*dy0
				if d2 < bd then best,bd = info.center,d2 end
			end
		end
		if best then
			local ax, ay = p2.x - p1.x, p2.y - p1.y
			local al = math.sqrt(ax*ax + ay*ay); if al > 0 then ax, ay = ax/al, ay/al else ax, ay = 0, 0 end

			local vex, vey = best.x - point.x, best.y - point.z
			local proj = ax*vex + ay*vey
			local perp2 = (vex*vex + vey*vey) - proj*proj

			local dxp, dyp = point.x - best.x, point.z - best.y
			local len = math.sqrt(dxp*dxp + dyp*dyp)
			if len > 0 then
				local dnm = len / NM
				local need = bufNm - dnm

				if proj > 0 and perp2 <= (bufNm*NM)*(bufNm*NM) and need > 0 then
					local bump = need * NM
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
			speed = 250,
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
		task={ id='ComboTask', params={ tasks={
			{ number=1, auto=false, id='EngageTargets', enabled=true, params=search.params }
		}}}
	})

	table.insert(task.params.route.points, {
		type=AI.Task.WaypointType.TURNING_POINT,
		x=p1.x, y=p1.y, speed=280,
		action=AI.Task.TurnMethod.FLY_OVER_POINT,
		alt=altm, alt_type=AI.Task.AltitudeType.BARO
	})

	table.insert(task.params.route.points, {
		type=AI.Task.WaypointType.TURNING_POINT,
		x=p2.x, y=p2.y, speed=280,
		action=AI.Task.TurnMethod.FLY_OVER_POINT,
		alt=altm, alt_type=AI.Task.AltitudeType.BARO,
		task={ id='ComboTask', params={ tasks={
			{ number=1, auto=false, id='EngageTargets', enabled=true, params=search.params },
			{ number=2, auto=false, id='Orbit', enabled=true, params=orbit.params }
		}}}
	})

	if landUnitID then
		local ab = AIRBASE:FindByID(landUnitID)
		if ab then
			table.insert(task.params.route.points, ab:GetCoordinate():WaypointAirLanding(UTILS.MpsToKmph(50), ab, {}, "RTB Land (Airbase)"))
		end
	end
	group:getController():setTask(task)
	SetUpCAP_DefaultAA(group)
end

	function BattleCommander:EngageCasMission(tgtzone, groupname, expendAmmount, weapon, altitude, landUnitID, side)
		local zn = self:getZoneByName(tgtzone)
		local group = Group.getByName(groupname)
		if group and zn.side == side then return 'Can not engage friendly zone' end
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

		local rngGround = 10 * 1852
		local rngPlane  = 20 * 1852
		local searchGround = { id = 'EngageTargets', params = { maxDist = rngGround, maxDistEnabled = true, targetTypes = { 'Ground Units' } } }
		local searchPlane  = { id = 'EngageTargets', params = { maxDist = rngPlane,  maxDistEnabled = true, targetTypes = InvisibleA10 and { 'Multirole fighters','Interceptors','Bombers' } or ((side == 2) and { 'Planes','Helicopters' } or { 'Planes' }) } }
		local pts = mis.params.route.points
		if pts then
			for _,search in ipairs({searchGround,searchPlane}) do
				if pts[2] and pts[2].task and pts[2].task.params and pts[2].task.params.tasks then
					table.insert(pts[2].task.params.tasks, search)
				end
				if pts[3] and pts[3].task and pts[3].task.params and pts[3].task.params.tasks then
					table.insert(pts[3].task.params.tasks, search)
				end
			end
		end

		group:getController():setTask(mis)
		self:setDefaultAG(group)
	end

function BattleCommander:EngageHeloCasMission(tgtzone, groupname, expendAmmount, altitudeFt, landUnitID)
	local zn = self:getZoneByName(tgtzone)
	

	local gmoose = GROUP:FindByName(groupname) if not gmoose or not gmoose:IsAlive() then return 'Not available' end
	local sp = gmoose:GetUnit(1):GetVec3()
	gmoose:SetOptionRadarUsing(3)

	local aglMeters = ((altitudeFt and altitudeFt>0) and (altitudeFt/3.281)) or (300/3.281)
	local groundAlt = land.getHeight({ x=sp.x, y=sp.z })
	local altBaro   = math.max(groundAlt + aglMeters, sp.y)
	local rng      = 10 * 1852
	local speedKmh = UTILS.MpsToKmph(70)
	local landKmh  = UTILS.MpsToKmph(50)


	local c  = zoneCentroid(zn.zone) or {x=sp.x,y=sp.z}
	local tx,tz = c.x, c.y
	local dx,dz = tx - sp.x, tz - sp.z
	local len   = math.sqrt(dx*dx + dz*dz) ; if len<=0 then len=1 end
	local ux,uz = dx/len, dz/len


	local mid  = COORDINATE:New(sp.x + ux*UTILS.NMToMeters(3.0),  altBaro, sp.z + uz*UTILS.NMToMeters(3.0))

	local app  = COORDINATE:New(tx - ux*UTILS.NMToMeters(5.0),    altBaro, tz - uz*UTILS.NMToMeters(5.0))

	local enroute = gmoose:EnRouteTaskEngageTargets(rng, {'Ground Units'}, 0)

	local wp = {}
	wp[#wp+1] = { type=AI.Task.WaypointType.TAKEOFF, x=sp.x, y=sp.z, speed=0, action=AI.Task.TurnMethod.FIN_POINT, alt=0, alt_type=AI.Task.AltitudeType.RADIO }
	wp[#wp+1] = mid:WaypointAirTurningPoint("RADIO", speedKmh, { enroute }, "CAS Mid 3 NM")
	wp[#wp+1] = app:WaypointAirTurningPoint("RADIO", speedKmh, {}, "CAS Approach 5 NM")
	local landingWp
	if landUnitID then
		local ab = AIRBASE:FindByID(landUnitID)
		if ab then
			landingWp = ab:GetCoordinate():WaypointAirLanding(landKmh, ab, {}, "RTB Land (Airbase)")
		env.info("land at airbase "..tostring(ab:GetName()))
		else
			landingWp = COORDINATE:New(sp.x, 0, sp.z):WaypointAirTurningPoint(
				"RADIO", landKmh, { gmoose:TaskLandAtVec2({ x=sp.x, y=sp.z }, nil, false, nil) }, "RTB Land (Vec2)"
			)
		end
	elseif self.Airbase then
		local ab = AIRBASE:FindByName(self.Airbase)
		if ab then
			landingWp = ab:GetCoordinate():WaypointAirLanding(landKmh, ab, {}, "RTB Land (Airbase)")
		else
			landingWp = COORDINATE:New(sp.x, 0, sp.z):WaypointAirTurningPoint(
				"RADIO", landKmh, { gmoose:TaskLandAtVec2({ x=sp.x, y=sp.z }, nil, false, nil) }, "RTB Land (Vec2)"
			)
		end
	else
		landingWp = COORDINATE:New(sp.x, 0, sp.z):WaypointAirTurningPoint(
			"RADIO", landKmh, { gmoose:TaskLandAtVec2({ x=sp.x, y=sp.z }, nil, false, nil) }, "RTB Land (Vec2)"
		)
	end
	wp[#wp+1] = landingWp

	gmoose:Route(wp, 1)
	--gmoose:CommandSwitchWayPoint(2)
	local group = Group.getByName(groupname)
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

	function BattleCommander:setDefaultAG(group,search)
		group:getController():setOption(AI.Option.Air.id.JETT_TANKS_IF_EMPTY, true)
		group:getController():setOption(AI.Option.Air.id.PROHIBIT_JETT, true)
		group:getController():setOption(AI.Option.Air.id.RTB_ON_BINGO, true)
		group:getController():setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.ALLOW_ABORT_MISSION)
		--group:getController():setOption(AI.Option.Air.id.ROE,AI.Option.Air.val.ROE.OPEN_FIRE)
		if search then group:getController():setOption(AI.Option.Air.id.RADAR_USING,AI.Option.Air.val.RADAR_USING.FOR_CONTINUOUS_SEARCH) end
		local weapons = 2147485694 + 30720 + 4161536
		group:getController():setOption(AI.Option.Air.id.RTB_ON_OUT_OF_AMMO, weapons)
		end

	function BattleCommander:setDefaultAGSHIP(group)
		group:getController():setOption(AI.Option.Air.id.JETT_TANKS_IF_EMPTY, true)
		group:getController():setOption(AI.Option.Air.id.PROHIBIT_JETT, true)
		group:getController():setOption(AI.Option.Air.id.RTB_ON_BINGO, true)
		group:getController():setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.BYPASS_AND_ESCAPE)
		group:getController():setOption(AI.Option.Air.id.ROE,AI.Option.Air.val.ROE.OPEN_FIRE_WEAPON_FREE)
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
		local defwp = { id='Mission', params={ route={ points={} } } }

		local wp1 = COORDINATE:New(startPos.x, alt, startPos.z):WaypointAirTurningPoint("RADIO", 257, {}, "WP1")
		wp1.task = task
		table.insert(defwp.params.route.points, wp1)

		if tgpos then
			local wp2 = COORDINATE:New(tgpos.x, alt, tgpos.z):WaypointAirTurningPoint("RADIO", 257, {}, "WP2")
			wp2.task = task
			table.insert(defwp.params.route.points, wp2)
		end

		if landUnitID then
			local ab = AIRBASE:FindByID(landUnitID)
			if ab then
				local landwp = ab:GetCoordinate():WaypointAirLanding(UTILS.MpsToKmph(50), ab, {}, "RTB Land (Airbase)")
				table.insert(defwp.params.route.points, landwp)
			end
		end

		return defwp
	end

	function BattleCommander:_rebalanceRedDifficulty()
		local total, blue = 0, 0
		for _, z in ipairs(self.zones) do
			if z.active and not z.suspended and z.side~=0 and not z.isHidden then
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
		self.proximityWakeClients = self.proximityWakeClients or SET_CLIENT:New():FilterActive():FilterStart()
		self.playersState = self.playersState or {}
		for i = #self.playersState, 1, -1 do
			self.playersState[i] = nil
		end

		local players = {}
		self.proximityWakeClients:ForEachClient(function(client)
			if client:IsAlive() then
				local u = client:GetDCSObject()
				local pv = u:getPoint()
				if pv then
					local coalitionSide = u:getCoalition()
					local coalitionName = "neutral"
					if coalitionSide == coalition.side.BLUE then coalitionName = "blue" end
					if coalitionSide == coalition.side.RED then coalitionName = "red" end
					if coalitionSide == coalition.side.BLUE then
						players[#players+1] = { coalition = coalitionSide, point = pv }
					end
					local playerTable = {}
					playerTable.coalition = coalitionName
					playerTable.playerName = u:getPlayerName()
					playerTable.unitType = u:getTypeName()
					playerTable.latitude, playerTable.longitude, playerTable.altitude = coord.LOtoLL(pv)
					self.playersState[#self.playersState+1] = playerTable
				end
			end
		end)

		local limit = (GlobalSettings.proximityWakeNm or 30)
		local changed = false
		for _,z in ipairs(self.zones) do
			if z.suspended and z.side == 1 then
				local cz = CustomZone:getByName(z.zone)
				if cz and cz.point then
					local zp = cz.point
					for _,p in ipairs(players) do
						local up = p.point
						local dx = up.x - zp.x
						local dz = up.z - zp.z
						local dnm = math.sqrt(dx*dx + dz*dz) / 1852
						if dnm <= limit then
							z._proximityWakeUntil = timer.getTime() + (GlobalSettings.proximityWakeHoldSeconds or 120)
							z:resume()

							changed = true
							break
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
				if other.side ~= 0 and other.side ~= z.side and other.active and not other.suspended and not other.isHidden then
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
			if gc and gc.targetzone and (gc.mission=='attack' or gc.mission=='patrol') then
				local st=gc.state
				if st=='takeoff' or st=='inair' then
					self._activeAttackOrPatrol[gc.targetzone]=true
				end
			end
		end
	end
	return self._activeAttackOrPatrol
end

function BattleCommander:explainSuspendDecision(zoneName, groupId)
	local z = self:getZoneByName(zoneName); if not z then return end
	local function b(v) return v and "true" or "false" end
	local dist = self:_minEnemyDistanceNm(z)
	local limit = (z.side==2) and (GlobalSettings.autoSuspendNmBlue or 70) or (GlobalSettings.autoSuspendNmRed or 150)

	local hasOppositeNeighbor, hasNeutralNeighbor = false, false
	local nbrs = self.connectionMap and self.connectionMap[z.zone]
	if nbrs then
		for n,_ in pairs(nbrs) do
			local nz = self:getZoneByName(n)
			if nz and nz.active and not nz.isHidden then
				if nz.side ~= 0 and nz.side ~= z.side then hasOppositeNeighbor = true end
				if nz.side == 0 and (not nz.ForceNeutral or z.side ~= 1) then hasNeutralNeighbor = true end
			end
		end
	end

	local originList = {}
	for _, gc in ipairs(z.groups or {}) do
		if gc and (gc.mission=='attack' or gc.mission=='patrol') then
			local live = (gc.state=='takeoff' or gc.state=='inair' or gc.state=='landed' or gc.state=='enroute' or gc.state=='atdestination')
			local spawnable = (not live) and gc.shouldSpawn and gc:shouldSpawn() or false
			local qualifies = false
			if gc.mission=='attack' then
				qualifies = spawnable or live
			else
				local tz = self:getZoneByName(gc.targetzone)
				if tz and tz.active and not tz.suspended and tz.side~=0 then
					local dnm = self:_minEnemyDistanceNm(tz)
					if dnm then
						local lim = (tz.side==2) and (GlobalSettings.autoSuspendNmBlue or 70) or (GlobalSettings.autoSuspendNmRed or 150)
						qualifies = (spawnable or live) and (dnm <= lim)
					end
				end
			end
			if qualifies then
				originList[#originList+1] = string.format("%s [%s→%s] state=%s", gc.name or "?", gc.mission, tostring(gc.targetzone), tostring(gc.state))
			end
		end
	end
	local originActive = (#originList > 0)

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

	local supportersOut, supportersDetail = 0, {}
	if nbrs then
		for n,_ in pairs(nbrs) do
			local nz = self:getZoneByName(n)
			if nz and nz.active and nz.side==z.side and not nz.isHidden and not nz.zone:lower():find("carrier") then
				for _, gc in ipairs(z.groups or {}) do
					if gc and gc.mission=='supply' and gc.side==z.side and gc.targetzone==nz.zone then
						if gc.state ~= 'inhangar' and gc.state ~= 'dead' then
							supportersOut = supportersOut + 1
							supportersDetail[#supportersDetail+1] = string.format("%s -> %s (%s)", gc.name or "?", nz.zone, gc.state or "?")
						end
						break
					end
				end
			end
		end
	end
	local supplierHold = supportersOut > 0

	local shouldSuspend = (not hasOppositeNeighbor) and (not hasNeutralNeighbor) and (not originActive) and (not incoming) and (dist and dist > limit) and (not canReceive) and (not supplierHold)

	local header = string.format("[SUSPEND-CHECK] %s\nside=%d active=%s suspended=%s\nminEnemyDist=%.1fNm limit=%.1fNm\noppNbr=%s neutNbr=%s incoming=%s canReceive=%s",
		z.zone, z.side, b(z.active), b(z.suspended), (dist or -1), limit, b(hasOppositeNeighbor), b(hasNeutralNeighbor), b(incoming), b(canReceive))
	local origins = (#originList>0) and ("\noriginActive=true\n - "..table.concat(originList, "\n - ")) or "\noriginActive=false"
	local supportersLine = (#supportersDetail>0) and ("\nsupplierHold=true supporters="..tostring(supportersOut).."\n - "..table.concat(supportersDetail, "\n - ")) or "\nsupplierHold=false supporters=0"
	local verdict = "\n=> shouldSuspend="..b(shouldSuspend)

	local msg = header..origins..supportersLine..verdict
	if groupId then trigger.action.outTextForGroup(groupId, msg, 25) else trigger.action.outText(msg, 25) end
end


function BattleCommander:_autoZoneSuspend()
		self:reindexCombatZones()
		local changed = false
		local toUpdate = {}
		local toSuspend = {}
		local toResume  = {}
		local neighborToResume = {}
		local supplierHold = {}
		local incomingActiveSupply = {}
		local hasSupplyToTarget = {}
		for _, oz in ipairs(self.zones) do
			for _, gc in ipairs(oz.groups or {}) do
				if gc and gc.mission == 'supply' then
					local targetName = gc.targetzone
					if targetName then
						local st = gc.state
						if st ~= 'inhangar' and st ~= 'dead' then incomingActiveSupply[targetName] = true end
						local originName = oz.zone
						if originName then
							local row = hasSupplyToTarget[originName]
							if not row then row = {}; hasSupplyToTarget[originName] = row end
							local mask = row[targetName] or 0
							if gc.side == 1 then
								if mask == 0 or mask == 2 then mask = mask + 1 end
							elseif gc.side == 2 then
								if mask == 0 or mask == 1 then mask = mask + 2 end
							end
							row[targetName] = mask
						end
					end
				end
			end
		end

		for _, z in ipairs(self.zones) do
			if not z.suspended and z.active and z.side~=0 and not z.isHidden and not z.zone:lower():find("red carrier") then
				if z:canRecieveSupply() then
					local nbrs = self.connectionMap and self.connectionMap[z.zone]
					if nbrs then
						local picked = 0
						for n,_ in pairs(nbrs) do
							if picked >= 2 then break end
							local nz = self:getZoneByName(n)
							if nz and nz.active and nz.side==z.side and not nz.isHidden and not nz.zone:lower():find("red carrier") then
								local hasSupplyToZ = false
								local row = hasSupplyToTarget[nz.zone]
								local mask = row and row[z.zone]
								if mask and ((z.side == 1 and (mask == 1 or mask == 3)) or (z.side == 2 and (mask == 2 or mask == 3))) then hasSupplyToZ = true end
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
								if nz and nz.active and nz.side==z.side and not nz.isHidden and not nz.zone:lower():find("red carrier") then
									local hasSupplyToZ = false
									local row = hasSupplyToTarget[nz.zone]
									local mask = row and row[z.zone]
									if mask and ((z.side == 1 and (mask == 1 or mask == 3)) or (z.side == 2 and (mask == 2 or mask == 3))) then hasSupplyToZ = true end
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
			if z.active and z.side==0 and not z.isHidden and not z.zone:lower():find("red carrier") then
				local nbrs = self.connectionMap and self.connectionMap[z.zone]
				if nbrs then
					local picked = 0
					for n,_ in pairs(nbrs) do
						if picked >= 2 then break end
						local nz = self:getZoneByName(n)
						if nz and nz.active and nz.side~=0 and nz.suspended and not nz.isHidden and not nz.zone:lower():find("red carrier") then
							local di = self:_minEnemyDistanceNmWithFarps(nz)
							local li = (nz.side==2) and (GlobalSettings.autoSuspendNmBlue or 70) or (GlobalSettings.autoSuspendNmRed or 150)
							local hasOpp = false
							local nb2 = self.connectionMap and self.connectionMap[nz.zone]
							if nb2 then
								for n2,_ in pairs(nb2) do
									local oz = self:getZoneByName(n2)
									if oz and oz.active and oz.side~=0 and oz.side~=nz.side and not oz.isHidden then hasOpp = true break end
								end
							end
							local inc = incomingActiveSupply[nz.zone] == true
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

			if not z.isHidden and not z.zone:lower():find("red carrier") then
				if z.side ~= 0 and z.active then
					local dist = self:_minEnemyDistanceNmWithFarps(z)
					if dist then
						local hasOppositeNeighbor = false
						local hasNeutralNeighbor = false
						local nbrs = self.connectionMap and self.connectionMap[z.zone]
						if nbrs then
							for n,_ in pairs(nbrs) do
								local nz = self:getZoneByName(n)
								if nz and nz.active and not nz.isHidden then
									if nz.side ~= 0 and nz.side ~= z.side then hasOppositeNeighbor = true break end
									if nz.side == 0 and (not nz.ForceNeutral or z.side ~= 1) then hasNeutralNeighbor = true end
								end
							end
						end


						local limit  = (z.side==2) and (GlobalSettings.autoSuspendNmBlue or 70) or (GlobalSettings.autoSuspendNmRed or 150)
						local combat = self._activeAttackOrPatrol and self._activeAttackOrPatrol[z.zone]
						local originActive = self._activeOrigin and self._activeOrigin[z.zone]
						local canReceive = z:canRecieveSupply()
						local incoming = false
						if canReceive then
							incoming = incomingActiveSupply[z.zone] == true
						end
						local now = timer.getTime()
						local proximityHold = z._proximityWakeUntil and z._proximityWakeUntil > now
						local shouldSuspend = (not proximityHold) and (not hasOppositeNeighbor) and (not hasNeutralNeighbor) and (not combat) and (not originActive) and (not incoming) and (dist > limit) and (not canReceive) and (not supplierHold[z])

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
                               --env.info(string.format("[KEEP] zone=%s oppNbr=%s neutNbr=%s combat=%s origin=%s incoming=%s dist=%.1fNm limit=%dNm canReceive=%s supplierHold=%s",z.zone,tostring(hasOppositeNeighbor),tostring(hasNeutralNeighbor),tostring(combat~=nil),tostring(originActive~=nil),tostring(incoming),dist, limit,tostring(canReceive),tostring(supplierHold[z]~=nil)))
							end
						end
					end
		end
	end
end
		local neighborWakeMeters = 15*NM
		local anchorSet = {}
		for _, z in ipairs(self.zones) do
			if z.active and z.side~=0 and not z.isHidden and not z.zone:lower():find("red carrier") then
				local isCandidate = false
				for i=1,#toSuspend do
					if toSuspend[i] == z then
						isCandidate = true
						break
					end
				end
				if not isCandidate then
					anchorSet[#anchorSet+1] = z
				end
			end
		end
		local protectedByProximity = {}
		for _, anchor in ipairs(anchorSet) do
			local row = ZONE_DISTANCES and ZONE_DISTANCES[anchor.zone]
			if row then
				for _, z in ipairs(self.zones) do
					if z.active and z.side==anchor.side and not z.isHidden and not z.zone:lower():find("red carrier") then
						if z ~= anchor then
							local d = row[z.zone]
							if d and d <= neighborWakeMeters then
								protectedByProximity[z] = true
								if z.suspended then
									neighborToResume[#neighborToResume+1] = z
								end
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
		for z,_ in pairs(protectedByProximity) do wakeSet[z] = true end
		local finalSuspend = {}
		for _,z in ipairs(toSuspend) do if not wakeSet[z] then finalSuspend[#finalSuspend+1] = z end end
		for _, d in ipairs(self.zones) do
			if d._supplySupporters and not d:canRecieveSupply() then
				for name,_ in pairs(d._supplySupporters) do
					local sz = self:getZoneByName(name)
					if sz and sz.active and sz.side~=0 and not sz.isHidden and not wakeSet[sz] then
						local dist = self:_minEnemyDistanceNmWithFarps(sz)
						local limit = (sz.side==2) and (GlobalSettings.autoSuspendNmBlue or 70) or (GlobalSettings.autoSuspendNmRed or 150)
						local hasOppositeNeighbor = false
						local nbrs2 = self.connectionMap and self.connectionMap[sz.zone]
						if nbrs2 then
							for n2,_ in pairs(nbrs2) do
								local oz = self:getZoneByName(n2)
								if oz and oz.active and oz.side~=0 and oz.side~=sz.side and not oz.isHidden then hasOppositeNeighbor = true break end
							end
						end
						if dist and dist <= limit then hasOppositeNeighbor = true end
						local combat2 = self._activeAttackOrPatrol and self._activeAttackOrPatrol[sz.zone]
						local originActive2 = self._activeOrigin and self._activeOrigin[sz.zone]
						local canReceive2 = sz:canRecieveSupply()
						local incoming2 = false
						if canReceive2 then
							incoming2 = incomingActiveSupply[sz.zone] == true
						end
						local shouldSuspend2 = (not hasOppositeNeighbor) and (not combat2) and (not originActive2) and (not incoming2) and dist and (dist > limit) and (not canReceive2)
						if shouldSuspend2 then finalSuspend[#finalSuspend+1] = sz end
					end
				end
				d._supplySupporters = nil
			end
		end
		for _,zz in ipairs(finalSuspend) do
			if not zz.suspended then
				zz:suspend()
				changed = true
				toUpdate[#toUpdate+1]=zz
			end
		end
		for _,zz in ipairs(toResume) do
			if zz.suspended then
				env.info("[RESUME] "..zz.zone)
				zz:resume()
				changed = true
				toUpdate[#toUpdate+1]=zz
			end
		end
		for _,zz in ipairs(neighborToResume) do
			if zz.suspended then
				env.info("[RESUME] "..zz.zone)
				zz:resume()
				changed = true
				toUpdate[#toUpdate+1]=zz
			end
		end
		if changed then
			SCHEDULER:New(nil,function() self:buildZoneStatusMenuForGroup() for _,zz in ipairs(toUpdate) do zz:updateLabel() end end,{},2)
		end
	end

DRAW_SUPPLY_ARROWS_DEBUG_LOGGING = false -- Set to true to enable debug logging

-- Helper functions for debug logging
local function supplyArrowLog(message)
	if DRAW_SUPPLY_ARROWS_DEBUG_LOGGING then
		env.info(message)
	end
end

function BattleCommander:DrawConnectionLines()
env.info("DEBUG: Drawiing Connection lines")
for _, id in ipairs(_activeArrowIds) do
trigger.action.removeMark(id)
end
_activeArrowIds = {}
self.ConnectionArrowIds = {}

env.info("DEBUG: Cleared existing arrows.")

if not self.connections or #self.connections == 0 then
env.info("DEBUG: No supply connections to draw.")
return
end

local hasConn = {}
for _, c in ipairs(self.connections) do
	hasConn[c.from.."=>"..c.to] = true
end

local function edgePoint(a,b)
	local sx,sy,sz = a.point.x, a.point.y, a.point.z
	local ox,oz    = b.point.x, b.point.z
	local dx,dz    = ox - sx, oz - sz
	local len      = math.sqrt(dx*dx + dz*dz)
	if len == 0 then return {x = sx, y = sy, z = sz} end
	local ux,uz    = dx/len, dz/len
	if a:isCircle() then
		return {x = sx + ux * a.radius, y = sy, z = sz + uz * a.radius}
	elseif a:isQuad() and a.vertices and #a.vertices >= 3 then
		local bestT = nil
		local function cross(ax,az,bx,bz) return ax*bz - az*bx end
		for idx = 1, #a.vertices do
			local v1 = a.vertices[idx]
			local v2 = a.vertices[(idx % #a.vertices) + 1]
			local ex,ez = v2.x - v1.x, v2.z - v1.z
			local qpx,qpz = v1.x - sx, v1.z - sz
			local denom = cross(ux,uz,ex,ez)
			if math.abs(denom) > 1e-6 then
				local t = cross(qpx,qpz,ex,ez) / denom
				local u = cross(qpx,qpz,ux,uz) / denom
				if t >= 0 and u >= 0 and u <= 1 then
					if not bestT or t < bestT then bestT = t end
				end
			end
		end
		if bestT then
			return {x = sx + ux * bestT, y = sy, z = sz + uz * bestT}
		end
	end
	return {x = sx, y = sy, z = sz}
end

for i, v in ipairs(self.connections) do
local fromZone = self:getZoneByName(v.from)
local toZone   = self:getZoneByName(v.to)

local from = (fromZone and fromZone._cz) or CustomZone:getByName(v.from)
local to = (toZone and toZone._cz) or CustomZone:getByName(v.to)

	if not (fromZone and toZone and fromZone.side == 0 and toZone.side == 2 and hasConn[v.to.."=>"..v.from]) then
		_globalArrowCounter = _globalArrowCounter + 1
		local arrowId = _globalArrowCounter
		table.insert(_activeArrowIds, arrowId)


			if fromZone and toZone and from and to then
				local pFrom = edgePoint(from,to)
				local pTo   = edgePoint(to,from)
				local headPos = pTo
				local tailPos = pFrom
				if fromZone.side == 1 and toZone.side == 2 then
					headPos = pFrom
					tailPos = pTo
				end
				if (not fromZone.active) or (not toZone.active) then
					--trigger.action.arrowToAll(-1, arrowId, headPos, tailPos, {0, 0, 0, 0.5}, {0.1,0.1,0.1,0.5}, 0.5)
				elseif fromZone.side == 2 and toZone.side ~= 1  then
					supplyArrowLog(string.format("DEBUG: Drawing BLUE arrow for connection %d", i))
					trigger.action.arrowToAll(-1, arrowId, headPos, tailPos, {0, 0, 0, 0.5}, {0, 0, 1, 0.5}, 0.5)
				elseif fromZone.side == 1 and toZone.side ~= 2 then
					supplyArrowLog(string.format("DEBUG: Drawing RED arrow for connection %d", i))
					trigger.action.arrowToAll(-1, arrowId, headPos, tailPos, {0, 0, 0, 0.5}, {1, 0, 0, 0.5}, 0.5)
				else
					supplyArrowLog(string.format("DEBUG: Drawing NEUTRAL arrow for connection %d", i))
					trigger.action.arrowToAll(-1, arrowId, headPos, tailPos, {0, 0, 0, 0.5}, {1, 1, 1, 0.5}, 0.5)
				end
				self.ConnectionArrowIds[v.from.."=>"..v.to] = arrowId
			else
				env.info(string.format("DEBUG: Skipping connection %d due to nil zone/point data.", i))
			end
		end
	end
end

function BattleCommander:RefreshConnectionsLines(zoneName)
	if not self.connections or not self.connections then return end

	local hasConn = {}
	for _, c in ipairs(self.connections) do
		hasConn[c.from.."=>"..c.to] = true
	end

	local function edgePoint(a,b)
		local sx,sy,sz = a.point.x, a.point.y, a.point.z
		local ox,oz    = b.point.x, b.point.z
		local dx,dz    = ox - sx, oz - sz
		local len      = math.sqrt(dx*dx + dz*dz)
		if len == 0 then return {x = sx, y = sy, z = sz} end
		local ux,uz    = dx/len, dz/len
		if a:isCircle() then
			return {x = sx + ux * a.radius, y = sy, z = sz + uz * a.radius}
		elseif a:isQuad() and a.vertices and #a.vertices >= 3 then
			local bestT = nil
			local function cross(ax,az,bx,bz) return ax*bz - az*bx end
			for idx = 1, #a.vertices do
				local v1 = a.vertices[idx]
				local v2 = a.vertices[(idx % #a.vertices) + 1]
				local ex,ez = v2.x - v1.x, v2.z - v1.z
				local qpx,qpz = v1.x - sx, v1.z - sz
				local denom = cross(ux,uz,ex,ez)
				if math.abs(denom) > 1e-6 then
					local t = cross(qpx,qpz,ex,ez) / denom
					local u = cross(qpx,qpz,ux,uz) / denom
					if t >= 0 and u >= 0 and u <= 1 then
						if not bestT or t < bestT then bestT = t end
					end
				end
			end
			if bestT then
				return {x = sx + ux * bestT, y = sy, z = sz + ux * bestT}
			end
		end
		return {x = sx, y = sy, z = sz}
	end

	for i, v in ipairs(self.connections) do
		if v.from == zoneName or v.to == zoneName then
			local key = v.from.."=>"..v.to
			local existingId = self.ConnectionArrowIds[key]
			if existingId then
				trigger.action.removeMark(existingId)
				self.ConnectionArrowIds[key] = nil
			end

			local fromZone = self:getZoneByName(v.from)
			local toZone   = self:getZoneByName(v.to)
			if not (fromZone and toZone and fromZone.side == 0 and toZone.side == 2 and hasConn[v.to.."=>"..v.from]) then
				local from = CustomZone:getByName(v.from)
				local to = CustomZone:getByName(v.to)
				if fromZone and toZone and from and to then
					local pFrom = edgePoint(from,to)
					local pTo   = edgePoint(to,from)
					local headPos = pTo
					local tailPos = pFrom
					if fromZone.side == 1 and toZone.side == 2 then
						headPos = pFrom
						tailPos = pTo
					end
					_globalArrowCounter = _globalArrowCounter + 1
					local arrowId = _globalArrowCounter
					self.ConnectionArrowIds[key] = arrowId
					if (not fromZone.active) or (not toZone.active) then
						--trigger.action.arrowToAll(-1, arrowId, headPos, tailPos, {0, 0, 0, 0.5}, {0.1,0.1,0.1,0.5}, 0.5)
					elseif fromZone.side == 2 and toZone.side ~= 1  then
						trigger.action.arrowToAll(-1, arrowId, headPos, tailPos, {0, 0, 0, 0.5}, {0, 0, 1, 0.5}, 0.5)
					elseif fromZone.side == 1 and toZone.side ~= 2 then
						trigger.action.arrowToAll(-1, arrowId, headPos, tailPos, {0, 0, 0, 0.5}, {1, 0, 0, 0.5}, 0.5)
					else
						trigger.action.arrowToAll(-1, arrowId, headPos, tailPos, {0, 0, 0, 0.5}, {1, 1, 1, 0.5}, 0.5)
					end
				end
			end
		end
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
			if not v.isHidden and not v.suspended then
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
		if not self.multicrewTempStatGuard then
			self.multicrewTempStatGuard=true
			local crew=self:getMulticrewPlayersNow(playerName)
			if #crew>1 and statKey ~= 'Points' then
				for i=1,#crew do
					local n=crew[i]
					self.tempStats = self.tempStats or {}
					self.tempStats[n] = self.tempStats[n] or {}
					self.tempStats[n][statKey] = self.tempStats[n][statKey] or 0
					self.tempStats[n][statKey] = self.tempStats[n][statKey] + value
					self.sessionStats = self.sessionStats or {}
					self.sessionStats[n] = self.sessionStats[n] or {}
					self.sessionStats[n][statKey] = (self.sessionStats[n][statKey] or 0) + value
				end
				self.multicrewTempStatGuard=false
				return
			end
			self.multicrewTempStatGuard=false
		end
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
	
	function BattleCommander:resetTempStats(playerName,force)
		local crew=self:getMulticrewPlayersNow(playerName)
		if #crew>1 and not force then
			local pid=self:_multicrewGetPidByName(playerName)
			if not pid then return end
			local slot=net.get_player_info(pid,'slot')
			if not slot or slot=='' then return end
			if tonumber(slot) then return end
			local us=string.find(slot,'_')
			if not us then return end
			local subslot=tonumber(string.sub(slot,us+1)) or 0
			if subslot==0 then return end
		end
		self.tempStats = self.tempStats or {}
		self.tempStats[playerName] = {}
	end
	
	function BattleCommander:printTempStats(side, player, opts)
		self.tempStats = self.tempStats or {}
		self.tempStats[player] = self.tempStats[player] or {}
		local sorted = {}
		for i,v in pairs(self.tempStats[player]) do
			if not (opts and opts.excludePoints and i == 'Points') then
				table.insert(sorted,{i,v})
			end
		end
		table.sort(sorted, function(a,b) return a[1] < b[1] end)
		
		local indent = opts and opts.indent or ''
		local message = (opts and opts.noHeader) and '' or '['..player..']'
		for i,v in ipairs(sorted) do
			message = message..'\n'..indent..'+'..v[2]..' '..v[1]
		end
		
		if opts and opts.returnOnly then return message end
		trigger.action.outTextForCoalition(side, message , (opts and opts.duration) or 10)
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
			['SAM'] = 0,
			['Deaths'] = 0,
			['Captured by enemy'] = 0,
			['Points'] = 0,
			['Points spent'] = 0,
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
			elseif statKey == 'Captured by enemy' then
				playerStats['Captured by enemy'] = statValue
			elseif statKey == 'Points' then
				playerStats['Points'] = statValue
			elseif statKey == 'Zone capture' then
				playerStats['Zone capture'] = statValue
			elseif statKey == 'Zone upgrade' then
				playerStats['Zone upgrade'] = statValue
			elseif statKey == 'Pilot Rescue' then
				playerStats['Pilot Rescue'] = statValue
			elseif statKey == 'Points spent' then
				playerStats['Points spent'] = statValue
			end
		end

		local message = '[' .. player .. ']\nLeaderboard rank: ' .. (rank or '')
		if RankingSystem == true then
			local cr = self:getPlayerCredits(player)
			local idx = self:getPlayerRank(player)
			local nm  = self:getRankName(idx)
			local nextT = (self.rankThresholds or {})[idx+1]
			local nextNm = self:getRankName(idx+1)
			local remain = nextT and math.max(0,(nextT - cr)) or nil
			if nm then message = message .. '\nCurrent rank: ' .. nm end
			if nextNm then message = message .. '\nNext rank: ' .. nextNm end
			if remain then message = message .. ', remaining: ' .. remain end
		end

		local displayOrder = {'Air', 'Helo', 'Ground Units', 'Ship', 'SAM', 'Structure', 'Deaths', 'Captured by enemy', 'Zone capture', 'Zone upgrade', 'Pilot Rescue', 'Points', 'Points spent'}

		for _, statKey in ipairs(displayOrder) do
			local v = playerStats[statKey] or 0
			if v > 0 or statKey == 'Air' or statKey == 'Helo' or statKey == 'Ground Units' or statKey == 'Ship' or statKey == 'SAM' or statKey == 'Structure' or statKey == 'Deaths' or statKey == 'Points' or statKey == 'Points spent' then
				message = message .. statKey .. ': ' .. v .. '\n'
			end
		end

		trigger.action.outTextForUnit(unitid, message, 10)
	end

function BattleCommander:printRankHelp(groupid)
	self.rankThresholds = self.rankThresholds or {0,3000,5000,8000,12000,16000,22000,30000,45000,65000,90000}
	self.rankNames      = self.rankNames      or {"Recruit","Aviator","Airman","Senior Airman","Staff Sergeant","Technical Sergeant","Master Sergeant","Senior Master Sergeant","Chief Master Sergeant","Second Lieutenant","First Lieutenant"}
	local maxLen=0
	for i=1,#self.rankNames do
		local l=#self.rankNames[i]
		if l>maxLen then maxLen=l end
	end
	local txt='Rank requirements (total credits):\n\n'
	for i=1,#self.rankNames do
		local name=self.rankNames[i]
		local dots = string.rep('.',(maxLen-#name)+2)
		txt = txt .. name .. dots .. ' ' .. (self.rankThresholds[i] or 0) .. '+\n'
	end
	trigger.action.outTextForGroup(groupid, txt, 30)
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
			if RankingSystem == true then
				local idx = self:getPlayerRank(v[1])
				local nm  = self:getRankName(idx)
				if nm then message = message .. 'Rank: ' .. nm .. '\n' end
			end

			local playerStats = {
				['Air'] = 0,
				['Helo'] = 0,
				['Ground Units'] = 0,
				['SAM'] = 0,
				['Deaths'] = 0,
				['Captured by enemy'] = 0,
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
				elseif statKey == 'Captured by enemy' then
					playerStats['Captured by enemy'] = statValue
				elseif statKey == 'Points' then
					playerStats['Points'] = statValue
				elseif statKey == 'Zone capture' then
					playerStats['Zone capture'] = statValue
				elseif statKey == 'Zone upgrade' then
					playerStats['Zone upgrade'] = statValue
				elseif statKey == 'Pilot Rescue' then
					playerStats['Pilot Rescue'] = statValue
				elseif statKey == 'Points spent' then
					playerStats['Points spent'] = statValue
				end
			end


		local displayOrder = {'Air', 'Helo', 'Ground Units', 'Ship', 'SAM', 'Structure', 'Deaths', 'Captured by enemy', 'Zone capture', 'Zone upgrade', 'Pilot Rescue', 'Points', 'Points spent'}

			for _, statKey in ipairs(displayOrder) do
				local v = playerStats[statKey] or 0
				if v > 0 or statKey == 'Air' or statKey == 'Helo' or statKey == 'Ground Units' or statKey == 'Ship' or statKey == 'SAM' or statKey == 'Structure' or statKey == 'Deaths' or statKey == 'Points' or statKey == 'Points spent' then
					message = message .. '\n' .. statKey .. ': ' .. v
				end
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
			
			self:resetTempStats(playerName, true)
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
        local ab = getAirbaseByName(n)
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

function BattleCommander:_multicrewGetPidByName(pname)
	self.playerIdByName=self.playerIdByName or {}
	local pid=self.playerIdByName[pname]
	if pid then
		local plist=net.get_player_list() or {}
		for i=1,#plist do
			local p=plist[i]
			if p==pid then
				if net.get_name(p)==pname then return pid end
				break
			end
		end
		self.playerIdByName[pname]=nil
	end
	local plist=net.get_player_list() or {}
	for i=1,#plist do
		local p=plist[i]
		if net.get_name(p)==pname then
			self.playerIdByName[pname]=p
			return p
		end
	end
	return nil
end

function BattleCommander:_multicrewGetMasterSlotByPid(pid)
	local slot=net.get_player_info(pid,'slot')
	if not slot or slot=='' then return nil end
	if tonumber(slot) then return tonumber(slot) end
	local s=string.find(slot,'_%d+')
	if s then return tonumber(string.sub(slot,1,s-1)) end
	return nil
end


function BattleCommander:getMulticrewPlayersNow(pname)
	local pid=self:_multicrewGetPidByName(pname)
	if not pid then return {pname} end
	local master=self:_multicrewGetMasterSlotByPid(pid)
	if not master then return {pname} end
	local plist=net.get_player_list() or {}
	local crew={}
	for i=1,#plist do
		local p=plist[i]
		local m=self:_multicrewGetMasterSlotByPid(p)
		if m==master then
			local n=net.get_name(p)
			if n and n~='' then
				self.playerIdByName=self.playerIdByName or {}
				self.playerIdByName[n]=p
				crew[#crew+1]=n
			end
		end
	end
	if #crew==0 then return {pname} end
	return crew
end


function BattleCommander:addContribution(playerName, side, amount)
	self.playerContributions[side][playerName]=(self.playerContributions[side][playerName] or 0)+amount
	local crew=self:getMulticrewPlayersNow(playerName)
	for i=1,#crew do
		local n=crew[i]
		if n~=playerName then
			self.playerContributions[side][n]=(self.playerContributions[side][n] or 0)+amount
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
	self.playerJointBonus = self.playerJointBonus or { [1]={}, [2]={} }
	self.jointPairs = self.jointPairs or {}


	function ev:onEvent(event)
		local unit = event.initiator
		if unit and Object.getCategory(unit) == Object.Category.UNIT and (Unit.getCategoryEx(unit) == Unit.Category.AIRPLANE or Unit.getCategoryEx(unit) == Unit.Category.HELICOPTER) then
			local side = unit:getCoalition()
			local groupid = unit:getGroup():getID()
			local pname = unit:getPlayerName()
			local jp = self.context.jointPairs[pname] or nil
							
			if event.id == 6 then -- Pilot ejected
				if pname then
					local crew=bc:getMulticrewPlayersNow(pname)
					for i=1,#crew do
						local n=crew[i]
						if self.context.playerContributions[side][n]~=nil and self.context.playerContributions[side][n]>0 then
							local tenp=math.floor(self.context.playerContributions[side][n]*0.25)
							self.context:addFunds(side,tenp)
							trigger.action.outTextForCoalition(side,'['..n..'] ejected. +'..tenp..' credits (25% of earnings). Kill statistics lost.',5)
							self.context:addStat(n,'Points',tenp)
							self.context:addStat(n,'Deaths',1)
							self.context:resetTempStats(n)
							local aircraftID=event.initiator.id_
							self.context.csarPlayerAircraftByAircraft = self.context.csarPlayerAircraftByAircraft or {}
							self.context.csarPlayerAircraftByAircraft[aircraftID]=true
							local lostCredits=self.context.playerContributions[side][n]*0.75
							self.context.playerContributions[side][n]=0
							for _,g in pairs(MissionGroups) do g.killers[n]=nil end
							ejectedPilotOwnersByAircraft = ejectedPilotOwnersByAircraft or {}
							ejectedPilotOwnersByAircraft[aircraftID] = ejectedPilotOwnersByAircraft[aircraftID] or {}
							ejectedPilotOwnersByAircraft[aircraftID][#ejectedPilotOwnersByAircraft[aircraftID]+1] = {player=n,lostCredits=lostCredits,coalition=side}
							if capMissionTarget~=nil and capKillsByPlayer[n]then
								capKillsByPlayer[n]=0
							end
							if casMissionTarget ~= nil and casKillsByPlayer[n] then 
								casKillsByPlayer[n] = 0 
							end
							if Hunt then
								bc.huntDone[n] = nil
							end
							local jp = self.context.jointPairs and self.context.jointPairs[n]
							if jp then
								local gid2 = self.context.groupByPlayer and self.context.groupByPlayer[jp]
								self.context:_jointEnd(n)
								trigger.action.outTextForGroup(groupid,'You have left the joint mission',15)
								if gid2 then trigger.action.outTextForGroup(gid2,'['..n..'] left the joint mission',15) end
							end
						end
					end
					if trackedGroups[groupid] then
						trackedGroups[groupid]=nil
						removeMenusForGroupID(groupid)
						for zName,groupTable in pairs(missionGroupIDs) do
							if groupTable[groupid] then
								groupTable[groupid]=nil
							end
						end
					end
				end
			end

			if pname then
				local gObj=unit:getGroup()
				-- Pilot death (NEW)
                if event.id == 9 then -- S_EVENT_PILOT_DEAD
                    local crew=bc:getMulticrewPlayersNow(pname)
                    for i=1,#crew do
                        local n=crew[i]
                        self.context:addStat(n,'Deaths',1)
                        if capMissionTarget~=nil and capKillsByPlayer[n] then
                            capKillsByPlayer[n]=0
                        end
                        if casMissionTarget ~= nil and casKillsByPlayer[n] then 
                            casKillsByPlayer[n] = 0 
                        end
                        for _,g in pairs(MissionGroups) do g.killers[n]=nil end
                        if Hunt then bc.huntDone[n]=nil end
                        local jp = self.context.jointPairs and self.context.jointPairs[n]
                        if jp then
                            local gid2 = self.context.groupByPlayer and self.context.groupByPlayer[jp]
                            self.context:_jointEnd(n)
                            if gid2 then trigger.action.outTextForGroup(gid2,'['..n..'] have died and left the joint mission',15) end
                        end
                    end
                    if trackedGroups[groupid] then
                        trackedGroups[groupid]=nil
                        removeMenusForGroupID(groupid)
                        for zName,groupTable in pairs(missionGroupIDs) do
                            if groupTable[groupid] then groupTable[groupid]=nil end
                        end
                    end
                    
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
					local crew = self.context:getMulticrewPlayersNow(pname)
					local resetPilot = (#crew == 0)

					if not resetPilot then
						local didCrew = false
						for i=1,#crew do
							local n = crew[i]
							local pid = self.context:_multicrewGetPidByName(n)
							local slot = pid and net.get_player_info(pid,'slot') or nil
							local subslot = 0
							if slot and slot ~= '' and not tonumber(slot) then
								local us = string.find(slot,'_')
								if us then subslot = tonumber(string.sub(slot,us+1)) or 0 end
							end
							if subslot > 0 then
								didCrew = true
								self.context.playerContributions[side][n] = 0
								for _,g in pairs(MissionGroups) do g.killers[n]=nil end
								self.context:resetTempStats(n)
							end
						end
						if not didCrew then resetPilot = true end
					end

					if resetPilot then
						self.context.playerContributions[side][pname] = 0
						for _,g in pairs(MissionGroups) do g.killers[pname]=nil end
						self.context:resetTempStats(pname)
					end
					if Hunt then
					bc.huntDone[pname] = nil
					end
					if self.context.jointPairs and self.context.jointPairs[pname] then
						local jp = self.context.jointPairs[pname]
						local gid2 = self.context.groupByPlayer and self.context.groupByPlayer[jp]
						trigger.action.outTextForGroup(groupid,'Left joint mission due to respawn',15)
						if gid2 then trigger.action.outTextForGroup(gid2,'['..pname..'] left the joint mission due to respawn',15) end
						self.context:_jointEnd(pname)
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
												bc:addContribution(kn,side,share)
											end
											local processed={}
											local jointed={}
											for _,kn in ipairs(names) do
												local jp = self.context.jointPairs[kn]
												if jp and not processed[kn] and not processed[jp] and self.context:_jointPartnerAlive(kn) and self.context:_jointPartnerAlive(jp) then
													bc:addContribution(kn,side,(gtab.reward-share))
													if self.context.playerContributions[side][jp] ~= nil then
														if gtab.killers[jp] then
															bc:addContribution(jp,side,(gtab.reward-share))
														else
															bc:addContribution(jp,side,gtab.reward)
														end
														jointed[jp]=true
													end
													jointed[kn]=true
													processed[kn]=true
													processed[jp]=true
												end
											end
											for _,kn in ipairs(names) do
												if gtab.stat then
													if jointed[kn] then self.context:addTempStat(kn,gtab.stat..' (Joint mission)',1) else self.context:addTempStat(kn,gtab.stat,1) end
												end
											end
											table.sort(names)
											local plist=table.concat(names,', ')
											if kc==1 then
												local lone=names[1]
												local jp = self.context.jointPairs[lone]
												local jointOK = jp and self.context:_jointPartnerAlive(lone) and self.context:_jointPartnerAlive(jp) and self.context.playerContributions[side][jp] ~= nil
												if jointOK then
													trigger.action.outTextForCoalition(2,gtab.stat..' mission completed by '..lone..' and '..jp..'. +'..gtab.reward..' credits each - land to redeem.',15)
												else
													trigger.action.outTextForCoalition(2,gtab.stat..' mission completed by '..lone..'. +'..gtab.reward..' credits - land to redeem.',15)
												end
												trigger.action.outSoundForCoalition(2,"cancel.ogg")
											else
												trigger.action.outTextForCoalition(2,gtab.stat..' mission completed by '..plist..'. +'..share..' credits each - land to redeem.',15)
												trigger.action.outSoundForCoalition(2,"cancel.ogg")
											end
											do
												local done={}
												for _,kn in ipairs(names) do
													if jointed[kn] then
														local jp = self.context.jointPairs[kn]
														if not done[jp] then
															local jgn = self.context.groupNameByPlayer[jp]
															local jgr = Group.getByName(jgn)
															if jgr then
																local ju = jgr:getUnit(1)
																if ju and not Utils.isInAir(ju) then
																	SCHEDULER:New(nil,function()
																		if ju and ju:isExist() then
																			world.onEvent({id=world.event.S_EVENT_LAND,time=timer.getAbsTime(),initiator=ju,initiatorPilotName=jp,initiator_unit_type=ju:getTypeName(),initiator_coalition=ju:getCoalition(),skipRewardMsg=true})
																		end
																	end,{},5,0)
																end
															end
															done[jp]=true
														end
													end
												end
											end

											local mk = MissionMarks[mt.group]; if mk then trigger.action.removeMark(mk) MissionMarks[mt.group]=nil end
											if gtab.flag and MissionMarks[gtab.flag] then trigger.action.removeMark(MissionMarks[gtab.flag]) MissionMarks[gtab.flag]=nil end
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
										bc:addContribution(pname,side,mt.reward)
										if jp and self.context:_jointPartnerAlive(pname) and self.context:_jointPartnerAlive(jp) then
											if self.context.playerContributions[side][jp] ~= nil then
												bc:addContribution(jp,side,mt.reward)
												if mt.stat then self.context:addTempStat(jp,mt.stat..' (Joint mission)',1) end
											end
											if mt.stat then self.context:addTempStat(pname,mt.stat..' (Joint mission)',1) end
											trigger.action.outTextForCoalition(2,mt.stat..' mission completed by '..pname..' and '..jp..'. +'..mt.reward..' credits each - land to redeem.',15)
											local jgn = self.context.groupNameByPlayer[jp]
											local jgr = Group.getByName(jgn)
											if jgr then
												local ju = jgr:getUnit(1)
												if ju and not Utils.isInAir(ju) then
													SCHEDULER:New(nil,function()
														if ju and ju:isExist() then
															world.onEvent({id=world.event.S_EVENT_LAND,time=timer.getAbsTime(),initiator=ju,initiatorPilotName=jp,initiator_unit_type=ju:getTypeName(),initiator_coalition=ju:getCoalition(),skipRewardMsg=true})
														end
													end,{},5,0)
												end
											end
										else
											if mt.stat then self.context:addTempStat(pname,mt.stat,1) end
											trigger.action.outTextForCoalition(2,mt.stat..' mission completed by '..pname..'. +'..mt.reward..' credits - land to redeem.',15)
										end
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
									bc:addContribution(pname,side,earning)
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
								bc:addContribution(pname,side,st.reward)
								if jp and self.context:_jointPartnerAlive(pname) and self.context:_jointPartnerAlive(jp) then
									if self.context.playerContributions[side][jp] ~= nil then
										bc:addContribution(jp,side,st.reward)
										bc:addTempStat(jp,st.stat..' (Joint mission)',1)
									end
									bc:addTempStat(pname,st.stat..' (Joint mission)',1)
									trigger.action.outTextForCoalition(2,st.stat..' destroyed by '..pname..' and '..jp..'. +'..st.reward..' credits each - land to redeem.',15)
									local jgn = self.context.groupNameByPlayer[jp]
									if jgn then
										local jgr = Group.getByName(jgn)
										if jgr then
											local ju = jgr:getUnit(1)
											if ju and not Utils.isInAir(ju) then
												SCHEDULER:New(nil,function()
													if ju and ju:isExist() then
														world.onEvent({id=world.event.S_EVENT_LAND,time=timer.getAbsTime(),initiator=ju,initiatorPilotName=jp,initiator_unit_type=ju:getTypeName(),initiator_coalition=ju:getCoalition(),skipRewardMsg=true})
													end
												end,{},5,0)
											end
										end
									end
								else
									bc:addTempStat(pname,st.stat,1)
									trigger.action.outTextForCoalition(2,st.stat..' destroyed by '..pname..'. +'..st.reward..' credits - land to redeem.',15)
								end
								trigger.action.outSoundForCoalition(2,'cancel.ogg')
								if MissionMarks[flag] then trigger.action.removeMark(MissionMarks[flag]) MissionMarks[flag]=nil end
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
						local function scheduleCreditClaim(zoneData, zoneName, waitSeconds, zoneMooseWrapper)
							if not event.skipRewardMsg then
								trigger.action.outTextForGroup(groupid, '[' .. pname .. '] landed at ' .. zoneName .. '.\nWait ' .. waitSeconds .. ' seconds to claim credits...', 5)
							end							
								local claimfunc = function(context, zone, player, unitname)
								local un = Unit.getByName(unitname)
								if un then
									local insideZone = Utils.isInZone(un, zone.zone)
									if not insideZone then
										local mooseZone = zoneMooseWrapper or zone.mooseZone or getMooseZone(zone.zone)
										if mooseZone then
											local unitWrapper = UNIT:Find(un)
											if unitWrapper and unitWrapper:IsInZone(mooseZone) then
												insideZone = true
											end
										end
									end

									if (insideZone or zone.wasBlue) and Utils.isLanded(un, true)  then
										if un:getLife() > 0 then
											local coalitionSide = zone.side
											if zone.wasBlue then
												coalitionSide = 2
											end
											local crew=bc:getMulticrewPlayersNow(player)
											local redeemMsg = 'Player Redeem :'
											local did = false
											for i=1,#crew do
												local n=crew[i]
												local add = ((context.playerContributions[coalitionSide] and context.playerContributions[coalitionSide][n]) or 0)
												if add > 0 then
													did = true
													local before = context:getPlayerRank(n)
													context:addFunds(coalitionSide, add)
													redeemMsg = redeemMsg..'\n'..tostring(n)..': '..tostring(add)..' credits'..context:printTempStats(coalitionSide, n, { returnOnly=true, noHeader=true, indent='  ', excludePoints=true })
													context:addTempStat(n, 'Points', add)
													context:commitTempStats(n)
													context.playerContributions[coalitionSide][n] = 0
													if RankingSystem == true then
														context:addPlayerRankCredits(n, add)
														context:saveRanksToDisk()
														local after = context:getPlayerRank(n)
														if after > before then
															local name = context:getRankName(after)
															trigger.action.outTextForCoalition(coalitionSide, n..' has been promoted to '..name..'!', 12)
															trigger.action.outSoundForCoalition(coalitionSide,"Rank.ogg")
															local g = un:getGroup()
															if g and g:isExist() then context:refreshShopMenuForGroup(g:getID(), g) end
														end
													end
													if Hunt then
														bc.huntDone[n] = nil
													end
												end
											end
											if did then
												trigger.action.outTextForCoalition(coalitionSide, redeemMsg, 15)
											end
										end
									end
								end
							end
							SCHEDULER:New(nil,claimfunc,{self.context,zoneData,pname,unit:getName()},waitSeconds,0)
						end
							local foundZone = false
							local function unloadIfPilot()
								local grObj = unit and unit:getGroup()
								if not grObj or not lc or not lc.carriedPilots then return end
								local gid = grObj:getID()
								local carried = lc.carriedPilots[gid] or 0
								if carried > 0 then
									lc:unloadPilot(grObj:getName())
								end
							end

							for i, v in ipairs(self.context:getZones()) do
								if ((side == v.side) or (v.wasBlue and side == 2)) and Utils.isInZone(unit, v.zone) then
									foundZone = true
									unloadIfPilot()
									scheduleCreditClaim(v, v.zone, 5)
									break
								end
							end

							if not foundZone then
								local group = unit:getGroup()
								local groupName = group and group:getName()
								local groupWrapper = groupName and GROUP:FindByName(groupName)
								if groupWrapper then
									for _, zName in ipairs(lc.supplyZones) do
										if string.find(zName, 'CTLD FARP') or string.find(zName, 'Escort Mission FARP') then
											local zoneWrapper = getMooseZone(zName)
											if zoneWrapper and groupWrapper:IsInZone(zoneWrapper) then
												local zoneInfo = self.context:getZoneByName(zName)
												if zoneInfo then
													if (zoneInfo.side == side) or (zoneInfo.wasBlue and side == 2) then
														foundZone = true
														unloadIfPilot()
														scheduleCreditClaim(zoneInfo, zoneInfo.zone, 5, zoneWrapper)
														break
													end
												else
													foundZone = true
													unloadIfPilot()
													scheduleCreditClaim({ zone = zName, side = side, wasBlue = false, mooseZone = zoneWrapper }, zName, 5, zoneWrapper)
													break
												end
											end
										end
									end
								end
							end

							if not foundZone and unit:getDesc().category == Unit.Category.AIRPLANE and unit:isExist() then
							local carrierHull = GetNearestCarrierName(UNIT:Find(unit):GetCoordinate())
							if carrierHull then
								local carrierUnit   = Unit.getByName(carrierHull)
								local carrierCoord  = UNIT:Find(carrierUnit):GetCoordinate()
								local playerCoord   = UNIT:Find(unit):GetCoordinate()
								local distance      = carrierCoord:Get2DDistance(playerCoord)

								if distance < 200 then
									local prettyName = hullPrettyAndTCN(carrierHull)
									trigger.action.outTextForGroup(groupid,'[' .. pname .. '] landed on the ' .. prettyName .. '.\nWait 10 seconds to claim credits...',6)
									unloadIfPilot()

									local claimfunc = function(context, player, unitname)
										local un = Unit.getByName(unitname)
										if un and Utils.isLanded(un,true) then
											if un:getLife() > 0 then
												local coalitionSide = un:getCoalition()
												local crew=bc:getMulticrewPlayersNow(player)
												local redeemMsg = 'Player Redeem :'
												local did = false
												for i=1,#crew do
													local n=crew[i]
													local add = ((context.playerContributions[coalitionSide] and context.playerContributions[coalitionSide][n]) or 0)
													if add > 0 then
														did = true
														local before = context:getPlayerRank(n)
														context:addFunds(coalitionSide,add)
														redeemMsg = redeemMsg..'\n'..tostring(n)..': '..tostring(add)..' credits'..context:printTempStats(coalitionSide, n, { returnOnly=true, noHeader=true, indent='  ', excludePoints=true })
														context:addTempStat(n,'Points',add)
														context:commitTempStats(n)
														context.playerContributions[coalitionSide][n] = 0
														if RankingSystem == true then
															context:addPlayerRankCredits(n, add)
															context:saveRanksToDisk()
															local after = context:getPlayerRank(n)
															if after > before then
																local name = context:getRankName(after)
																trigger.action.outTextForCoalition(coalitionSide, n..' has been promoted to '..name..'!', 12)
																local g = un:getGroup()
																if g and g:isExist() then context:refreshShopMenuForGroup(g:getID(), g) end
															end
														end
														if Hunt then bc.huntDone[n] = nil end
													end
												end
												if did then
													trigger.action.outTextForCoalition(coalitionSide, redeemMsg, 15)
												end
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
				local keep=false
				local plist=net.get_player_list() or {}
				for x=1,#plist do
					local pid=plist[x]
					if net.get_name(pid)==i and net.get_player_info(pid,'side')==side then
						keep=true
						break
					end
				end
				if not keep then
					context.playerContributions[side][i] = 0
				end
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
	
function BattleCommander:addPlayerCredits(pname, amount)
	if not RankingSystem then return end
		if not pname or not amount then return end
		RankSave = RankSave or {players={},version=1}
		RankSave.players = RankSave.players or {}
		RankSave.ucidToName = RankSave.ucidToName or {}
		local rec = RankSave.players[pname] or {credits=0,lastSeen=0}
		rec.credits = (rec.credits or 0) + amount
		rec.lastSeen = timer.getTime()
		RankSave.players[pname] = rec
		if bc and bc.rankFile and Utils and Utils.saveTable then
			Utils.saveTable(bc.rankFile, 'RankSave', RankSave)
			env.info('Added '..amount..' credits to '..pname..' (saved to '..bc.rankFile..')')
		else
			env.info('Added '..amount..' credits to '..pname..' (not saved, bc.rankFile or Utils missing)')
		end
	end

	function BattleCommander:loadRanksFromDisk()
		if not self.rankFile then
			local p = 'Foothold_Ranks.lua'
			if lfs then
				local dir = lfs.writedir()..'Missions/Saves/'
				lfs.mkdir(dir)
				p = dir..'Foothold_Ranks.lua'
			end
			self.rankFile = p
		end
		Utils.loadTable(self.rankFile)
		RankSave = RankSave or {players={},version=1}
		RankSave.players = RankSave.players or {}
		RankSave.ucidToName = RankSave.ucidToName or {}
	end

	function BattleCommander:saveRanksToDisk()
		if self.rankFile and RankSave then
			Utils.saveTable(self.rankFile,'RankSave',RankSave)
		end
	end

	function BattleCommander:getPlayerCredits(pname)
		if not pname or not RankSave or not RankSave.players then return 0 end
		local r = RankSave.players[pname]
		return (r and r.credits) or 0
	end

	function BattleCommander:getPlayerRank(pname)
		local cr = self:getPlayerCredits(pname)
		local t  = self.rankThresholds or {}
		local r  = 0
		for i=1,#t do
			if cr >= t[i] then r = i else break end
		end
		return r
	end

	function BattleCommander:getRankName(idx)
		local n = self.rankNames or {}
		return n[idx] or ("Rank "..tostring(idx))
	end

	function BattleCommander:addPlayerRankCredits(pname, amount)
		if not pname or not amount or amount<=0 then return end
		RankSave = RankSave or {players={},version=1}
		RankSave.players = RankSave.players or {}
		local rec = RankSave.players[pname] or {credits=0,lastSeen=0}
		rec.credits = (rec.credits or 0) + amount
		rec.lastSeen = timer and timer.getAbsTime() or 0
		RankSave.players[pname] = rec
	end

	function BattleCommander:saveToDisk()
		local statedata = self:getStateTable()
		statedata.customFlags       = CustomFlags
		statedata.globalExtraUnlock = self.globalExtraUnlock
		Utils.saveTable(self.saveFile,'zonePersistance',statedata)
		
		-- Create SITAC status file for external tools
		if lfs and io then
			if self.saveFile then
				local sitac_filename = lfs.writedir() .. [[Missions/Saves/foothold.status]]
				local result = writeToFile(sitac_filename, self.saveFile .. "\n")
				if result then
					--env.info("Created SITAC file in " .. sitac_filename)
				end
			else
				env.info("Skipping SITAC file creation: persistence filename unavailable")
			end
		end
		if RankingSystem == true then
		self:saveRanksToDisk()
		end
	end


function BattleCommander:loadFromDisk()
		if RankingSystem == true then
		self:loadRanksFromDisk()
		end
		Utils.loadTable(self.saveFile)
		if zonePersistance then
			if zonePersistance.zones then
				self.saveLoaded = true
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
						
						zn.upgrades = zn.upgrades or {}
						zn.upgrades.blue = zn.upgrades.blue or {}
						zn.upgrades.red  = zn.upgrades.red  or {}

						local raw = v.extraUpgrade
						zn.extraUpgrade = (type(raw)=="table") and raw or {}
						if type(raw)=="string" and zn.side==2 then
							table.insert(zn.upgrades.blue, raw)
						end

						for _,grp in ipairs(zn.extraUpgrade) do
							if type(grp)=="table" then
								local s = grp.side
								local n = grp.name
								if s==2 and n then
									table.insert(zn.upgrades.blue, n)
								elseif s==1 and n then
									table.insert(zn.upgrades.red, n)
								elseif (not s) and n and zn.side==2 then
									table.insert(zn.upgrades.blue, n)
								end
							elseif zn.side==2 then
								table.insert(zn.upgrades.blue, grp)
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

						local savedLogistic = v.logisticCenter
						if savedLogistic == nil then
							savedLogistic = v.LogisticCenter
						end
						if savedLogistic ~= nil then
							zn.LogisticCenter = savedLogistic and true or false
						end 
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
							merged[side][id] = {name=def.name,cost=def.cost,stock=-1,prio=def.prio,reqRank=def.reqRank}
						end
					end
					for id,saved in pairs(zonePersistance.shops[side] or {}) do
						local def = (self.shops[side] or {})[id]
						merged[side][id] = saved
						if def and def.reqRank then
							merged[side][id].reqRank = def.reqRank
						end
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

				local changed = false
				RankSave = RankSave or {players={},version=1}
				RankSave.players = RankSave.players or {}
				RankSave.ucidToName = RankSave.ucidToName or {}
				for pname,stats in pairs(self.playerStats or {}) do
					local pts = stats and stats["Points"] or 0
					if pts and pts > 0 then
						local rec = RankSave.players[pname] or {credits=0,lastSeen=0}
						if (rec.credits or 0) < pts then
							rec.credits = pts
							RankSave.players[pname] = rec
							changed = true
						end
					end
				end
				if changed then self:saveRanksToDisk() end
			end
			
			if zonePersistance.customFlags then
				CustomFlags = zonePersistance.customFlags
			end

			if zonePersistance.ewrsSettings then
				if ewrs and ewrs.importPlayerSettings then
					ewrs.importPlayerSettings(zonePersistance.ewrsSettings)
				else
					EWRS_PENDING_PLAYER_SETTINGS = zonePersistance.ewrsSettings
				end
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

		dcs_zone = trigger.misc.getZone(obj.zone)
		if dcs_zone and dcs_zone.point then
			latitude, longitude, altitude = coord.LOtoLL(dcs_zone.point)
			obj.lat_long = {
				latitude = latitude,
				longitude = longitude,
				altitude = altitude
			}
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
		self._hibernated = self._hibernated or {}
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

	function ZoneCommander:resume(internal)
		if self._resuming and not internal then return end
		self._resuming = true
		local cz = CustomZone:getByName(self.zone)
		if cz then cz:clearUsedSpawnZones(self.zone) end
		local pending = {}
		for gName,_ in pairs(self._hibernated or {}) do
			if Group.getByName(gName) then
				if not self:_builtHas(gName) then pending[gName] = true end
			else
				local ok = false
				if cz and cz.spawnGroup then
					local r = cz:spawnGroup(gName, false)
					if r and r.name then
						for i,v in pairs(self.built) do if v == gName then self.built[i] = r.name break end end
						if Group.getByName(r.name) then ok = true end
					end
				end
				if not ok then env.info("Spawn failed: "..gName.." in zone "..self.zone); pending[gName] = true end
			end
		end
		self._hibernated = pending
		if next(self._hibernated) then
			SCHEDULER:New(nil, function(z) z:resume(true) end, {self}, 2, 0)
		else
			self.suspended = false
			self.remainingUnitsSnapshot = nil
			self._resuming = nil
		end
	end

	
	function ZoneCommander:addExtraSlot(groupName)
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		local cur = self.upgradesUsed or 0
		if cur >= max then return false end

		self.upgradesUsed = cur + 1
		self.level        = self.level + 1

		self.extraUpgrade = self.extraUpgrade or {}
		table.insert(self.extraUpgrade, { side = self.side, name = groupName })

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

		if self.suspended and self.remainingUnitsSnapshot then
			local res = {}
			for idx,_ in pairs(self.remainingUnitsSnapshot) do
				local name = upgrades[idx]
				if name then res[#res+1] = name end
			end
			return res
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

	function ZoneCommander:activateScoreTargetsForCritical(flag, reward, stat)
		if self._critScoreActive or CustomFlags[flag] then return end
		local list = self.criticalObjects or {}
		local alive = 0
		for i=1,#list do
			local obj = StaticObject.getByName(list[i])
			if obj and (obj:getLife() or 0) > 1 then alive = alive + 1 end
		end
		if alive == 0 and #list > 0 then
			CustomFlags[flag] = true
			ActiveMission[flag] = nil
			self._critScoreActive = true
			return
		end
		for i=1,#list do
			local obj = StaticObject.getByName(list[i])
			if obj then RegisterScoreTarget(flag, obj, reward, stat) end
		end
		ActiveMission[flag] = true
		self._critScoreActive = true
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
			
			if self.airbaseName and self.airbaseName ~= 'CVN-72' and self.airbaseName ~= 'CVN-73' then
				env.info("Disabling airbase " .. self.airbaseName)
				local ab = getDcsAirbaseByName(self.airbaseName)
				if ab then
					if self.wasBlue and not self.active then
						if ab:autoCaptureIsOn() then ab:autoCapture(false) end
						ab:setCoalition(2)
						if RespawnStaticsForAirbase then
							RespawnStaticsForAirbase(self.airbaseName, 2)
						end
					end
				else
					env.info("Airbase " .. self.airbaseName .. " is not found ask leka")
					trigger.action.outText("Airbase " .. self.airbaseName .. " is not found", 10)
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
		bc:_buildHunterBaseList()
		bc:_hasActiveAttackOrPatrolOnZone()	
        self:updateLabel()
		self.battleCommander:RefreshConnectionsLines(self.zone)
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
            if self.suspended and self.remainingUnitsSnapshot then
                for idx,_ in pairs(self.remainingUnitsSnapshot) do
                    local v = self.built[idx]
                    if v then
                        status=status.."\n  "..cleanName(v).." 100%"
                    end
                end
            else
                local anyResolved=false
                local unresolved={}
                for i,v in pairs(self.built) do
                    local gr=Group.getByName(v)
                    if gr then
                        anyResolved=true
                        local grhealth=math.ceil((gr:getSize()/gr:getInitialSize())*100)
                        grhealth=math.min(grhealth,100)
                        grhealth=math.max(grhealth,1)
                        status=status.."\n  "..cleanName(v).." "..grhealth.."%"
                    else
                        local st=StaticObject.getByName(v)
                        if st then
                            anyResolved=true
                            status=status.."\n  "..cleanName(v).." 100%"
                        else
                            unresolved[#unresolved+1]=cleanName(v)
                        end
                    end
                end
                if overrideIntel and not self.suspended and not anyResolved then
                    if #unresolved>0 then
                        status=status.."\n  (unresolved in built): "..table.concat(unresolved, ", ")
                    else
                        local up=self:getFilteredUpgrades() or {}
                        if #up>0 then
                            local want={}
                            for _,nm in pairs(up) do want[#want+1]=cleanName(nm) end
                            status=status.."\n  (expected from upgrades): "..table.concat(want, ", ")
                        else
                            status=status.."\n  (no built entries and no expected upgrades)"
                        end
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
            if self.suspended and self.remainingUnitsSnapshot then
                for idx,_ in pairs(self.remainingUnitsSnapshot) do
                    local v = self.built[idx]
                    if v then
                        status=status.."\n  "..v.." 100%"
                    end
                end
            else
                local anyResolved=false
                local unresolved={}
                for i,v in pairs(self.built) do
                    local gr=Group.getByName(v)
                    if gr then
                        anyResolved=true
                        local grhealth=math.ceil((gr:getSize()/gr:getInitialSize())*100)
                        grhealth=math.min(grhealth,100)
                        grhealth=math.max(grhealth,1)
                        status=status.."\n  "..v.." "..grhealth.."%"
                    else
                        local st=StaticObject.getByName(v)
                        if st then
                            anyResolved=true
                            status=status.."\n  "..v.." 100%"
                        else
                            unresolved[#unresolved+1]=tostring(v)
                        end
                    end
                end
                if overrideIntel and not self.suspended and not anyResolved then
                    if #unresolved>0 then
                        status=status.."\n  (unresolved in built): "..table.concat(unresolved, ", ")
                    else
                        local up=self:getFilteredUpgrades() or {}
                        if #up>0 then
                            local want={}
                            for _,nm in pairs(up) do want[#want+1]=cleanName(nm) end
                            status=status.."\n  (expected from upgrades): "..table.concat(want, ", ")
                        else
                            status=status.."\n  (no built entries and no expected upgrades)"
                        end
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


function ZoneCommander:MakeZoneredandupgradednow() -- for disabledfriendlyzone to make them go red and suspend
   if self.active and self.side ~= 2 then
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
        if not v.isHidden and v.side == 1 and not v.suspended then
            local z = bc.indexedZones[v.zone]
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
            local z = bc.indexedZones[zname]
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
----------------------- upgrade all blue zones --------------------------
function upgradeBlueZones()
    if upgradeBlueZonesBusy then
        trigger.action.outText("Upgrade process is already running.", 15)
        return
    end
    upgradeBlueZonesBusy = true
	
    local blueZones = {}
    local zones = bc:getZones()
    for i, v in ipairs(zones) do
        if not v.isHidden and v.side == 2 and not v.suspended then
            local z = bc.indexedZones[v.zone]
            if z and z.side == 2 then
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
                    BASE:I("upgradeBlueZones: candidate " .. tostring(v.zone))
                    table.insert(blueZones, v.zone)
                end
            end
        end
    end
    if #blueZones == 0 then
        BASE:I("All blue zones are now fully upgraded.")
        trigger.action.outText("All blue zones are now fully upgraded.", 15)
        upgradeBlueZonesBusy = false
        return
    end
	trigger.action.outText('Command accepted, pending', 20)
    local function process(idx)
        local zname = blueZones[idx]
        if zname then
            local z = bc.indexedZones[zname]
            if z and z.side == 2 then
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
                    BASE:I("Upgrading Blue zone: " .. z.zone .. " (" .. builtNow .. "/" .. totalUpgrades .. ")")
                    local function upgradeZone()
                        local target = needsRepair()
                        if target then
                            local gr = GROUP:FindByName(target)
                            if gr and gr:GetSize() and gr:GetInitialSize() and gr:GetSize() < gr:GetInitialSize() then
                                CustomRespawn(target)
                            else
                                local cz = CustomZone:getByName(z.zone)
                                if not cz or not cz.spawnGroup then
                                    BASE:E("upgradeBlueZones: spawnGroup missing for zone "..tostring(z.zone).." target="..tostring(target))
                                else
                                    BASE:I("upgradeBlueZones: respawning target "..tostring(target).." in zone "..tostring(z.zone))
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
                                BASE:I("Zone fully upgraded for Blue: " .. z.zone)
                            end
                        end
                    end
                    timer.scheduleFunction(upgradeZone, {}, timer.getTime() + 1)
                else
                    BASE:I("Zone already fully upgraded for Blue: " .. z.zone)
                end
            end
            timer.scheduleFunction(function() process(idx + 1) end, {}, timer.getTime() + 10)
        else
			BASE:I("All blue zones are now fully upgraded.")
            trigger.action.outText("All blue zones are now fully upgraded.", 15)
            upgradeBlueZonesBusy = false
        end
    end
    process(1)
end

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


function BattleCommander:addWarehouseItemsAtZone(zoneObj, coalition, amountPerItem)
    if not zoneObj then
        return false, "[Warehouse] No zone at this point."
    end

    local zoneName = zoneObj.zone
    local abName = zoneObj.airbaseName or zoneObj.baseName or zoneName
    if not abName or abName == "" then
        return false, string.format("[Warehouse] %s has no airbase.", tostring(zoneName or "Zone"))
    end

    if not WarehouseLogistics then
        return false, "[Warehouse] WarehouseLogistics is disabled."
    end

    local storage = STORAGE and STORAGE.FindByName and STORAGE:FindByName(abName) or nil
    if not storage and zoneName and abName ~= zoneName then
        storage = STORAGE and STORAGE.FindByName and STORAGE:FindByName(zoneName) or nil
        if storage then
            abName = zoneName
        end
    end
    if not storage then
        return false, string.format("[Warehouse] No storage found for airbase: %s", tostring(abName))
    end

    local amount = tonumber(amountPerItem) or 50
    amount = math.max(1, math.floor(amount))

    local items = (WEAPONSLIST and WEAPONSLIST.GetAllItems and WEAPONSLIST.GetAllItems()) or {}
    local added = 0

    for _, item in ipairs(items) do
        -- Always respect Coldwar restrictions
        if not (Era == "Coldwar" and WEAPONSLIST and WEAPONSLIST.IsRestricted and WEAPONSLIST.IsRestricted(item)) then
            storage:AddItem(item, amount)
            added = added + 1
        end
    end

    return true, string.format("[Warehouse] Added %d item types x%d to %s (zone: %s).",added, amount, tostring(abName), tostring(zoneName or "unknown"))
end

local function _autoRestockFriendlyAirbases()
	if WarehouseLogistics ~= true then return end
	if not bc or not (bc.zones or bc.getZones) then return end
	if not (bc.addWarehouseItemsAtZone) then return end

	for _, zoneObj in ipairs(bc.zones or bc:getZones() or {}) do
		if zoneObj and zoneObj.side == 2 and not zoneObj.suspended and zoneObj.airbaseName then
			local amount = AutoFillResources or 5
			bc:addWarehouseItemsAtZone(zoneObj, 2, amount)
		end
	end
end

if WarehouseLogistics == true and AutoFillResources > 0 then
	SCHEDULER:New(nil, function()
		_autoRestockFriendlyAirbases()
	end, {}, 900, 900)
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
	if self.destroyOnInit then
		for i,v in pairs(self.destroyOnInit) do
			local st = StaticObject.getByName(v)
			if st then
				--trigger.action.explosion(st:getPosition().p, st:getLife())
				st:destroy()
			end
		end
	end
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

	if self.side ~= 0 and self.ForceNeutral == true then
		self.ForceNeutral = false
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

	if self.airbaseName and self.airbaseName ~= 'CVN-72' and self.airbaseName ~= 'CVN-73' then

		timer.scheduleFunction(function()
			local ab = getDcsAirbaseByName(self.airbaseName)
			if ab then
				if ab:autoCaptureIsOn() then ab:autoCapture(false) end
				if self.side == 0 or (not self.active and not self.wasBlue) then
					if RespawnStaticsForAirbase then
						RespawnStaticsForAirbase(self.airbaseName, 0)						
					end
					ab:setCoalition(1)
					if WarehouseLogistics == true and not self.LogisticCenter then
						WEAPONSLIST.ClearWeaponsAtAirbase(self.airbaseName)
					end					
				end
				if self.side == 1 then
					if RespawnStaticsForAirbase then
						RespawnStaticsForAirbase(self.airbaseName, 1)
						if self.LogisticCenter then self.LogisticCenter = false
						end
					end
					ab:setCoalition(1)
				end
				if self.wasBlue then
					if RespawnStaticsForAirbase then
						RespawnStaticsForAirbase(self.airbaseName, 2)
					end
						ab:setCoalition(2)
					if WarehouseLogistics == true and not self.LogisticCenter then
						WEAPONSLIST.ClearWeaponsAtAirbase(self.airbaseName)
					end
				end
			else
				env.info("Airbase " .. self.airbaseName .. " not found")
			end
		end, {}, timer.getTime() +1)
	end

	local upgrades = self:getFilteredUpgrades()

	for i, v in pairs(self.built) do
		local gr = Group.getByName(v)
		local st = StaticObject.getByName(v)
		if not gr and not st then self.built[i] = nil end
	end

		if not self._validatedUpgrades then
		for i, v in pairs(upgrades) do
			if v and not tostring(v):find("dismounted") then
				local gr = Group.getByName(v)
				local st = StaticObject.getByName(v)
				local hasTpl = _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and _DATABASE.Templates.Groups[v]
				if not gr and not st and not hasTpl then
					local msg = "ZoneCommander INIT: upgrade group "..tostring(v).." missing for zone ["..tostring(self.zone).."] index ["..tostring(i).."]"
					env.info(msg)
					trigger.action.outText(msg, 15)
				end
			end
		end
		self._validatedUpgrades = true
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
	if not self.isHidden then
		local waypointLabel = WaypointList and WaypointList[self.zone] or ""
		local msg = " " .. self.zone .. "" .. waypointLabel
		if missions and missions[self.zone] then
			local m = missions[self.zone]
			local tz = bc.indexedZones[m.TargetZone]
			if tz and (self.side == 2 and tz.side == 1) then
				msg = msg .. "\n Mission!"
			end
		end
		if self.side == 2 then
			if self.LogisticCenter then
				msg = msg .. "\n [WH]"
			end
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

if WarehouseLogistics == true then 
	env.info("ZoneCommander: WarehouseLogistics is enabled")

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
		if self.suspended then return end
		if not self.active then return end
		self:checkCriticalObjects()

			local toRemove = {}
			local marked   = {}

			for i,v in pairs(self.built) do
				local gr = Group.getByName(v)
				local st = StaticObject.getByName(v)

				if gr and not gr:isExist() then
					gr = nil
				end

				if st and st:isExist() == false then
					st = nil
				end

				if gr and gr:getSize() == 0 then
					gr:destroy()
					if not marked[i] then marked[i]=true; toRemove[#toRemove+1]={key=i,name=v} end
				end

				if gr and gr:getSize() > 0 and not marked[i] then
					local anyAlive = false
					local unitCount = gr:getSize()
					for uidx=1,unitCount do
						local u = gr:getUnit(uidx)
						local life = (u and u:isExist() and u.getLife and u:getLife()) or 0
						if life >= 1 then anyAlive = true; break end
					end
					if not anyAlive then
						gr:destroy()
						if not marked[i] then marked[i] = true; toRemove[#toRemove+1] = { key = i, name = v } end
					end
				end
				
				if not gr and not marked[i] then
					local stLife = (st and st.getLife and st:getLife()) or 0
					if st and stLife < 1 then
						st:destroy()
						if not marked[i] then marked[i] = true; toRemove[#toRemove+1] = { key = i, name = v } end
					end
				end

				if not gr and not st then
					if not marked[i] then marked[i] = true; toRemove[#toRemove+1] = { key = i, name = v } end
				end
			end

			local anyRemoved = false
			for _,rem in ipairs(toRemove) do
				self.built[rem.key] = nil
				anyRemoved = true
				if GlobalSettings.messages.grouplost then trigger.action.outText(self.zone..' lost group '..rem.name, 5) end
			end
			if anyRemoved then self:updateLabel() end

	--[[ 		
				local empty = true
			for i,v in pairs(self.built) do
				if v then
					empty = false
					break
				end
			end
	]]

			local empty = (next(self.built) == nil)

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
			SCHEDULER:New(nil, Frontline.ReindexZoneCalcs, {}, 2, 0)
			self.battleCommander:RefreshConnectionsLines(self.zone)


			local cz = CustomZone:getByName(self.zone)
			if cz then cz:clearUsedSpawnZones(self.zone) end
			self.battleCommander:buildZoneStatusMenuForGroup()
			if self.airbaseName and self.airbaseName ~= 'CVN-72' and self.airbaseName ~= 'CVN-73' then

				local ab = getDcsAirbaseByName(self.airbaseName)
				if ab then
					local currentCoalition = ab:getCoalition()
					--if currentCoalition ~= coalition.side.RED then
						if RespawnStaticsForAirbase then
						RespawnStaticsForAirbase(self.airbaseName, coalition.side.NEUTRAL)
						end
						ab:setCoalition(1)
						if WarehouseLogistics == true and not self.LogisticCenter then
							WEAPONSLIST.ClearWeaponsAtAirbase(self.airbaseName)
						end
					--end
				end
			end	
			if self.active and GlobalSettings.messages.zonelost and not self.isHidden then
				trigger.action.outText(self.zone .. ' is now neutral ', 15)
				if trigger.misc.getUserFlag(180) == 0 then
					trigger.action.outSoundForCoalition(2, "ding.ogg")
				end
            if WarehouseLogistics then
                local zn = tostring(self.zone or "")
                if string.find(zn, "Carrier") then
                    if not self._carrierAutoRecapScheduled then
                        self._carrierAutoRecapScheduled = true
                        local zc = self
                        timer.scheduleFunction(function()
                            if not zc then return end
                            zc._carrierAutoRecapScheduled = false
                            -- only if it’s still neutral when the timer fires
                            if zc.active and zc.side == 0 then
                                if map == "Syria" then
                                    local sz = zc.battleCommander:getZoneByName('Silkworm Site')
                                    if sz and sz.active then return end
                                end
                                zc:capture(2)
                            end
                        end, nil, timer.getTime() + 5)
                    end
                end
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
							local src = bc.indexedZones[m.zone]
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

			bc:showEmergencyNeutralZoneMenu(2,'Select Zone for Emergency capture')
		
			if addCTLDZonesForBlueControlled then
				addCTLDZonesForBlueControlled(self.zone)
			end
			if SpawnFriendlyAssets then
				SCHEDULER:New(nil,SpawnFriendlyAssets,{},2,0)
			end

			SCHEDULER:New(nil,bc:buildCapSpawnBuckets(),{},5,0)


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
		if self.isHidden then return end
		local waypointLabel = WaypointList and WaypointList[self.zone] or ""
		local msg = " " .. self.zone .. "" .. waypointLabel
		if missions then
			for _, m in pairs(missions) do
				if m.zone == self.zone then
					local ownZone   = bc.indexedZones[m.zone]
					local targetZone = bc.indexedZones[m.TargetZone]
					if ownZone and targetZone and self.side == 2 and targetZone.side == 1 then
						msg = msg .. "\n Mission!"
					end
					break
				end
			end
		end
		if self.LogisticCenter then
			msg = msg .. "\n [WH]"
		end
		if self.side == 2 and WarehouseLowSupplies and WarehouseLowSupplies[self.zone] and not self.LogisticCenter then
			local supply = WarehouseLowSupplies[self.zone]
			local avg = supply.avg
			local entries = supply.entries
			if (type(entries) == "number" and entries < 500) or (type(avg) == "number" and avg < 10) then
				msg = msg .. "\n Empty warehouse!"
			elseif type(avg) == "number" and avg < 50 then
				msg = msg .. "\n Low warehouse!"
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
		self.ForceNeutral = false
		
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
		self.battleCommander:RefreshConnectionsLines(self.zone)
        SCHEDULER:New(bc, bc.abortSupplyToOpposite, {self.zone, self.side}, 10, 0)
        if _awacsRepositionSched then _awacsRepositionSched:Stop() end
        _awacsRepositionSched = SCHEDULER:New(nil, RepositionAwacsToFront, {}, 15)
		
		Frontline.ReindexZoneCalcs()

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
			if CaptureZoneIfNeutral then CaptureZoneIfNeutral() end
		end
		
        if self.wasBlue and self.isHeloSpawn then
            trigger.action.setMarkupTypeLine(self.index, 2)
            trigger.action.setMarkupColor(self.index, {0, 1, 0, 1})
        end  
			if self.airbaseName and self.airbaseName ~= 'CVN-72' and self.airbaseName ~= 'CVN-73' then
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
					v.lastStateTime = timer.getAbsTime() + 30
				else
					v.lastStateTime = timer.getAbsTime() + math.random(60, GlobalSettings.initialDelayVariance * 60) 
				end
			end
		end
		bc:buildCapSpawnBuckets()

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
				local src = bc.indexedZones[m.zone]
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
		 local zn = getTriggerZone(self.zone)
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
				self.battleCommander:RefreshConnectionsLines(self.zone)
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
			for i,v in ipairs(upgrades) do
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
    
    obj.urgent = obj.urgent or false

    setmetatable(obj, self)
    self.__index = self
    return obj
end
function GroupCommander:_applyHangarDelay(isInitial)
    local now = timer.getAbsTime()
    local urgent = type(self.urgent) == "function" and self.urgent() or self.urgent

    local delay = 0
    if urgent then
        if isInitial then
            delay = 20
        end
    else
        local variance = 25
        local maxSeconds = math.max(math.floor(variance * 60), 0)
        if maxSeconds > 0 then
            local minDelay = isInitial and 60 or 0
            if maxSeconds < minDelay then
                delay = maxSeconds
            else
                delay = math.random(minDelay, maxSeconds)
            end
        end
    end

    self.lastStateTime = now + delay
end

function GroupCommander:_enterHangar(isInitial)
    self.state = 'inhangar'
    self:_applyHangarDelay(isInitial)
end

function GroupCommander:init()
    self.state = 'inhangar'
    if type(self.spawnDelayFactor)=='function' then self.spawnDelayFactor=self.spawnDelayFactor(self) end
    self:_applyHangarDelay(true)

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
				if (self.type == 'air' or self.type == 'carrier_air') then local us=gr:getUnits(); local cnt=us and #us or 0; if not self.AirCount or cnt>self.AirCount then self.AirCount=cnt end end
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
                    if (self.type == 'air' or self.type == 'carrier_air') then local us=gr:getUnits(); self.AirCount=(us and #us) or 0 end
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
    local bel = (AirbaseBelonging and AirbaseBelonging[abName]) or nil
    if bel then for i=1,#bel do chain[#chain+1]=bel[i] end end
    local need = math.max(self.AirCount or 2, 1)
    local termType = self.terminalType or AIRBASE.TerminalType.OpenMedOrBig
    for ni=1,#chain do
        local ab = getAirbaseByName(chain[ni])
        local co = (ab and ab.GetCoalition) and ab:GetCoalition() or nil
        local sideOk = (self.side == 1 and co == coalition.side.RED) or (self.side == 2 and co == coalition.side.BLUE)
        if ab and ab:IsAirdrome() and sideOk then
            local free = (ab and ab.GetFreeParkingSpotsTable) and ab:GetFreeParkingSpotsTable(termType, false) or {}
            if type(free) ~= 'table' then free = {} end
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

function GroupCommander:_assignPlaneRoute(grName, zoneName, altitude,ownZone, ownside,skipWarehouseAdjust)
    local group = GROUP:FindByName(grName); if not group or not group:IsAlive() then return end
    local tz = self.zoneCommander.battleCommander:getZoneByName(zoneName); if not tz then return end
    local ab, abn = nil, tz.airbaseName
    if abn then ab = getAirbaseByName(abn)
        if ab and ab:GetCoalition() ~= tz.side then
            ab:SetCoalition(0)
        end
    end
    if not ab then return end

    local wp = {}
    local sp = group:GetUnit(1):GetVec3()
    wp[#wp+1] = { type=AI.Task.WaypointType.TAKEOFF, x=sp.x, y=sp.z, speed=0, action=AI.Task.TurnMethod.FIN_POINT, alt=0, alt_type=AI.Task.AltitudeType.RADIO }

    local abC = ab:GetCoordinate()
    local cruiseAlt = altitude or UTILS.FeetToMeters(10000)
    local approachHdg = abC:HeadingTo(COORDINATE:NewFromVec3(sp))
    local apCoord = abC:Translate(20*1852, approachHdg):SetAltitude(cruiseAlt)
    wp[#wp+1] = apCoord:WaypointAirTurningPoint(UTILS.MpsToKmph(50), cruiseAlt, AI.Task.AltitudeType.BARO, "Approach")

    wp[#wp+1] = abC:WaypointAirLanding(UTILS.MpsToKmph(50), ab, {}, "RTB Land (Airbase)")
    group:Route(wp, 1)
	if not skipWarehouseAdjust then
		self:_adjustWarehouseStock(ownZone, -50)
	end
end

local function _buildMooseWaypointAirLike(coord, altType, wpType, wpAction, speedKmh, speedLocked, airbase, dcsTasks, description, timeReFuAr)
	altType = altType or "RADIO"
	if speedLocked == nil then speedLocked = true end
	speedKmh = speedKmh or 500

	local RoutePoint = {}
	RoutePoint.x = coord.x
	RoutePoint.y = coord.z
	RoutePoint.alt = coord.y
	RoutePoint.alt_type = altType
	RoutePoint.type = wpType
	RoutePoint.action = wpAction
	RoutePoint.speed = speedKmh / 3.6
	RoutePoint.speed_locked = speedLocked
	RoutePoint.ETA = 0
	RoutePoint.ETA_locked = false
	RoutePoint.name = description

	if airbase then
		local AirbaseID = airbase:GetID()
		local AirbaseCategory = airbase:GetAirbaseCategory()
		if AirbaseCategory == Airbase.Category.SHIP or AirbaseCategory == Airbase.Category.HELIPAD then
			RoutePoint.linkUnit = AirbaseID
			RoutePoint.helipadId = AirbaseID
			RoutePoint.airdromeId = airbase:IsAirdrome() and AirbaseID or nil
		elseif AirbaseCategory == Airbase.Category.AIRDROME then
			RoutePoint.airdromeId = AirbaseID
		else
			env.info("[Route] ERROR: Unknown airbase category in _buildMooseWaypointAirLike")
		end
	end

	if wpType == "LandingReFuAr" then
		RoutePoint.timeReFuAr = timeReFuAr or 10
	end

	RoutePoint.task = { id = "ComboTask", params = { tasks = dcsTasks or {} } }
	return RoutePoint
end

-- Small MOOSE-style helper: build a DCS CargoTransportation task that can be placed into a waypoint ComboTask.
-- This allows doing helo logistics with GROUP:Route() without using AUFTRAG.
if COORDINATE and not COORDINATE.TaskCargoTransportation then
	function COORDINATE:TaskCargoTransportation(cargoGroupId, dropZoneId)
		return { number = 1, auto = false, id = 'CargoTransportation', params = { groupId = cargoGroupId, zoneId = dropZoneId } }
	end
end


function GroupCommander:_assignHeloLogisticsRoute(groupName, targetZoneName, ownZone, side)
	local staticType = "container_cargo"
	local staticCategory = "Cargos"
	local cargoMassKg = 600
	local cargoCountryId = side == 1 and country.id.RUSSIA or country.id.USA

	local gr = Group.getByName(groupName); if not gr then env.info("No group found for name " .. groupName) return end
	local c = gr:getController(); if not c then env.info("No controller found for group " .. groupName) return end
	local un = gr:getUnit(1); if not un then env.info("No unit found for group " .. groupName) return end
	local pos = un:getPoint()
	local destx, desty
	local useAirbase = false

	local sub = collectSubZones(targetZoneName)
	local pickName = (#sub > 0) and sub[math.random(#sub)] or targetZoneName

	local dropZone = getMooseZone(pickName)
	if not dropZone or not dropZone.ZoneID then return end

	local fz = getTriggerZone(pickName)
	if not fz or not fz.point then return end
	local dropx, dropy = fz.point.x, fz.point.z


	local spawnCoord = nil
	local prefix = ownZone.."-land"
	local pooledLand = {}
	local lastSpawn = self._lastGroundSpawnSpot and self._lastGroundSpawnSpot.zone or nil
	for name,list in pairs(LandingSpots) do
		if name:sub(1, #prefix) == prefix then
			for i=1,#list do
				if not (lastSpawn and lastSpawn == name) then
					local spot = list[i]
					if spot and spot.x and spot.z then
						pooledLand[#pooledLand+1] = { name = name, x = spot.x, z = spot.z }
					end
				end
			end
		end
	end
	if #pooledLand > 0 then
		local pick = pooledLand[math.random(#pooledLand)]
		spawnCoord = COORDINATE:New(pick.x, 0, pick.z)
	else
		local heading = un and un.getHeading and un:getHeading() or 0
		local behind = (heading + math.pi) % (2 * math.pi)
		local azDeg = math.deg(behind)
		spawnCoord = COORDINATE:New(pos.x, pos.y, pos.z):Translate(20, azDeg)
	end

	local tag = self.name .. "_LOGI"
	local cargoName = string.format("%s_CARGO_%d", tostring(tag), math.random(100000,999999))
	
	--local sp = SPAWNSTATIC:NewFromStatic("AI Cargo", cargoCountryId)
	
	local sp = SPAWNSTATIC:NewFromType(staticType, staticCategory, cargoCountryId)
	sp:InitCoordinate(spawnCoord)
	sp:InitCargo(true)
	sp:InitCargoMass(cargoMassKg)
	local cargo = sp:Spawn(0, cargoName)
	if not cargo then return end
	self._logiCargoByGroup = self._logiCargoByGroup or {}
	self._logiCargoByGroup[self.name] = cargoName
	if AIDeliveryamount == nil then AIDeliveryamount = 20 end
	self:_adjustWarehouseStock(ownZone, -AIDeliveryamount)

	local prefix2 = targetZoneName.."-land"
	local pooledLand2 = {}
	for name,list in pairs(LandingSpots) do
		if name:sub(1, #prefix2) == prefix2 then
			for i=1,#list do pooledLand2[#pooledLand2+1] = list[i] end
		end
	end
	if #pooledLand2 > 0 then
		local pick = pooledLand2[math.random(#pooledLand2)]
		env.info('Landing spot for ' .. targetZoneName .. ' found, picking')
		destx, desty = pick.x, pick.z
	end

	if not destx then
		local pooledForced = {}
		local idx = 0
		while true do
			local fname = string.format("%s-land-forced-%d", targetZoneName, idx)
			local fz = trigger.misc.getZone(fname)
			if not fz then break end
			pooledForced[#pooledForced+1] = { x=fz.point.x, z=fz.point.z }
			idx = idx + 1
		end
		if #pooledForced > 0 then
			local pick = pooledForced[math.random(#pooledForced)]
			destx, desty = pick.x, pick.z
		end
	end

	if not destx then
		local tz = self.zoneCommander.battleCommander:getZoneByName(targetZoneName)
		local abn = tz and tz.airbaseName
		if abn then
			local ab = AIRBASE:FindByName(abn)
			if ab and ab:GetCoalition()==gr:getCoalition() then
				useAirbase = true
			end
		end
	end

	if not destx and not useAirbase then
		local lz = self:_findFlatLZ(targetZoneName.."-", 200, math.tan(math.rad(15)))
		if not lz then lz = self:_findFlatLZ(targetZoneName, 200, math.tan(math.rad(15))) end
		if lz then destx, desty = lz.x, lz.z end
	end
	if not destx and not useAirbase then return end

	if useAirbase then
		local tz = self.zoneCommander.battleCommander:getZoneByName(targetZoneName)
		local abn = tz and tz.airbaseName
		local airb = abn and AIRBASE:FindByName(abn) or nil
		if airb and airb.GetCoordinate then
			local cc = airb:GetCoordinate(); if cc and cc.GetVec2 then local v=cc:GetVec2(); destx, desty = v.x, v.y end
		end
	end
	if not destx or not desty then return end

	local kmh = 289
	local spd = kmh / 3.6
	local alt = 500

	-- Use MOOSE route engine end-to-end (this also gives the 1s delayed SetTask that Route(...,1) uses).
	local gmoose = GROUP:FindByName(groupName)
	if not gmoose or not gmoose:IsAlive() then return end

	local route = {}
	-- WP1 at cargo location: execute CargoTransportation (pick up here, deliver to dropZone.ZoneID).
	local cargoTask = (COORDINATE and COORDINATE.TaskCargoTransportation) and COORDINATE:TaskCargoTransportation(cargo:GetID(), dropZone.ZoneID)
	local pickupCoord = COORDINATE:New(spawnCoord.x, spawnCoord.y, spawnCoord.z):SetAltitude(alt)
	route[#route + 1] = pickupCoord:WaypointAirTurningPoint("RADIO", kmh, { cargoTask }, "Cargo")

	-- WP2 at drop point: fly over.
	route[#route + 1] = COORDINATE:New(dropx, alt, dropy):WaypointAirFlyOverPoint("RADIO", kmh)

	-- WP3 landing: if airbase, pin to airbase; else land at coordinate.
	if useAirbase then
		local tz = self.zoneCommander.battleCommander:getZoneByName(targetZoneName)
		local abn = tz and tz.airbaseName
		local airb = abn and AIRBASE:FindByName(abn) or nil
		if not airb then return end
		route[#route + 1] = airb:GetCoordinate():WaypointAirLanding(kmh, airb, {}, "Landing")
	else
		local landTask = { id='Land', params={ point={ x=destx, y=desty }, duration=20, durationEnabled=true } }
		route[#route + 1] = COORDINATE:New(dropx, alt, dropy):WaypointAirTurningPoint("RADIO", kmh, { landTask }, "Landing")
	end

	gmoose:Route(route, 1)
end

function ManualAdjustWarehouse(zoneName, deltaPerItem)
    if not bc or type(zoneName) ~= "string" then
        env.info("[ManualAdjustWarehouse] Missing battle commander or zone name")
        return
    end
    local proxy = setmetatable({
        name = "ManualAdjust",
        side = 2,
        zoneCommander = { battleCommander = bc },
    }, { __index = GroupCommander })

    proxy:_adjustWarehouseStock(zoneName, deltaPerItem)
end

-- Example:
-- ManualAdjustWarehouse("Naumburg FARP", -10)

function GroupCommander:_adjustWarehouseStock(zoneName, deltaPerItem)
	if WarehouseLogistics ~= true then return end
	if type(deltaPerItem) ~= "number" or deltaPerItem == 0 then return end
	if not zoneName then return end
	if self.side ~= 2 then return end

	local originZone = self.zoneCommander.battleCommander:getZoneByName(zoneName) or zoneName
	local abName = originZone and originZone.airbaseName or zoneName
	if not abName then return end

	local storage = STORAGE:FindByName(abName)
	if not storage then return end

	local items = WEAPONSLIST.GetAllItems() or {}
	for _, item in ipairs(items) do
		local current = 0
		local amt = storage:GetItemAmount(item)
		if type(amt) == "number" then
			current = amt
		end
		local target = current + deltaPerItem
		if target < 0 then target = 0 end
		pcall(function() storage:SetItem(item, target) end)
	end

	env.info(string.format("Group [%s] adjusted warehouse [%s] by %+d per item (zone=%s)", tostring(self.name), tostring(abName), deltaPerItem, tostring(zoneName)))
end


function GroupCommander:_assignHeloRoute(grName, zoneName)
    local gr = Group.getByName(grName); if not gr then env.info("No group found for name " .. grName) return end
    local c = gr:getController(); if not c then env.info("No controller found for group " .. grName) return end
    local un = gr:getUnit(1); if not un then env.info("No unit found for group " .. grName) return end
    local pos = un:getPoint()
    local destx, desty
    local useAirbase = false
	
    local prefix = zoneName.."-land"
    local pooledLand = {}
    for name,list in pairs(LandingSpots) do
        if name:sub(1, #prefix) == prefix then
            for i=1,#list do pooledLand[#pooledLand+1] = list[i] end
        end
    end
    if #pooledLand > 0 then
        local pick = pooledLand[math.random(#pooledLand)]
        destx, desty = pick.x, pick.z
    end

    if not destx then
        local pooledForced = {}
        local idx = 0
        while true do
            local fname = string.format("%s-land-forced-%d", zoneName, idx)
            local fz = trigger.misc.getZone(fname)
            if not fz then break end
            pooledForced[#pooledForced+1] = { x=fz.point.x, z=fz.point.z }
            idx = idx + 1
        end
        if #pooledForced > 0 then
            local pick = pooledForced[math.random(#pooledForced)]
            destx, desty = pick.x, pick.z
        end
    end

	if not destx then
		local tz = self.zoneCommander.battleCommander:getZoneByName(zoneName)
		local abn = tz and tz.airbaseName
		if abn then
			local ab = AIRBASE:FindByName(abn)
			if ab and ab:GetCoalition()==gr:getCoalition() then
			useAirbase = true
			end
		end
	end

    if not destx and not useAirbase then
        local lz = self:_findFlatLZ(zoneName.."-", 200, math.tan(math.rad(15)))
        if not lz then lz = self:_findFlatLZ(zoneName, 200, math.tan(math.rad(15))) end
        if lz then destx, desty = lz.x, lz.z end
    end
    if not destx and not useAirbase then return end

    local spd = 180
    if useAirbase then
        local tz = self.zoneCommander.battleCommander:getZoneByName(zoneName)
        local abn = tz and tz.airbaseName
        local airb = abn and AIRBASE:FindByName(abn) or nil
        local tvx, tvy = destx, desty
        if (not tvx or not tvy) and airb and airb.GetCoordinate then
            local c = airb:GetCoordinate(); if c and c.GetVec2 then local v=c:GetVec2(); tvx, tvy = v.x, v.y end
        end
        tvx, tvy = tvx or pos.x, tvy or pos.z
        local dx, dz = tvx - pos.x, tvy - pos.z
        local L = math.sqrt(dx*dx + dz*dz)
        local back = 3 * 1852
        local apx = (L > 10) and (tvx - dx / L * back) or tvx
        local apy = (L > 10) and (tvy - dz / L * back) or tvy

        local gmoose = GROUP:FindByName(grName); if not gmoose or not gmoose:IsAlive() then return end
        local kmh = math.floor((spd or 280) * 3.6)

        local route = {}
        route[#route+1] = COORDINATE:New(apx, 1500, apy):WaypointAirFlyOverPoint("RADIO", kmh)
        local passAb = (useAirbase and airb) or nil
        route[#route+1] = COORDINATE:New(tvx, 0, tvy):WaypointAirLanding(kmh, passAb)

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
            action=AI.Task.TurnMethod.FLY_OVER_POINT, alt=1500, alt_type=AI.Task.AltitudeType.RADIO
        })
        table.insert(task.params.route.points, {
            type=AI.Task.WaypointType.TURNING_POINT, x=apx, y=apy, speed=spd, speed_locked=true,
            action=AI.Task.TurnMethod.FIN_POINT, alt=1500, alt_type=AI.Task.AltitudeType.RADIO,
            task={ id='ComboTask', params={ tasks={{ number=1, auto=false, id='Land', params={ point={ x=destx, y=desty }, duration=20, durationEnabled=true } }} } }
        })
        c:setTask(task)
    end
end


function BattleCommander:abortSupplyToOpposite(zoneName, newSide)
	for _, oz in ipairs(self.zones) do
		for _, gc in ipairs(oz.groups or {}) do
			if gc and gc.mission=='supply' and (gc.unitCategory==Unit.Category.HELICOPTER or gc.unitCategory==Unit.Category.AIRPLANE) and gc.targetzone==zoneName and gc.side ~= newSide then
				if gc.state == 'inair' then
					if gc.unitCategory==Unit.Category.HELICOPTER then
						gc:_assignHeloRoute(gc.name, gc.zoneCommander.zone)
					else
						gc:_assignPlaneRoute(gc.name, gc.zoneCommander.zone, gc.Altitude, gc.zoneCommander.zone, gc.side, true)
					end
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
    local abName = zc.airbaseName
    if type(abName) == "table" then
        abName = abName[zc.side]
    end
    local need = self.AirCount
    local termType = self.terminalType or AIRBASE.TerminalType.OpenMedOrBig
    local helipadId

    -- if abName then
	-- 	local ab = AIRBASE:FindByName(abName)

    if abName and not abName:find("^H%s*FRG") and not abName:find("^H%s*GDR") then
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
				if ab.IsShip and ab:IsShip() and not IsGroupActive(ab:GetName()) then
                    return nil
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
                            return { kind='parking', airbase=ab, spots=ids, helipadId=helipadId, airbaseId=(ab and ab.GetID) and ab:GetID() or nil, isShip=(ab and ab.IsShip and ab:IsShip()) or false }
                        end
                    end
                    local ids={}
                    for i=1,need do ids[i]=free[i].TerminalID end
                    return { kind='parking', airbase=ab, spots=ids, helipadId=helipadId, airbaseId=(ab and ab.GetID) and ab:GetID() or nil, isShip=(ab and ab.IsShip and ab:IsShip()) or false }
                end
            end
        end
    end
    return nil
end

AnyPlayers = AnyPlayers or {}

function getAnyPlayersCount()
    local cnt = 0
    for _ in pairs(AnyPlayers) do
        cnt = cnt + 1
    end
    return cnt
end

function serverHasPlayers()
    return next(AnyPlayers) ~= nil
end

playerListBlueCas = {}

CasCountExtraTypes = {
	["AH-64D_BLK_II"] = true,
	["UH-60L_DAP"] = true,
	["Mi-24P"] = true,
	["Ka-50_3"] = true,
	["Ka-50"] = true,
	["OH58D"] = true,
	["A-10C_2"] = true,
}

function getBlueCasPlayersCount()
    local cnt = 0
    for _ in pairs(playerListBlueCas) do
        cnt = cnt + 1
    end
    return cnt
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

--AJS37
function refreshPlayers()
    local oldBlue = getBluePlayersCount()
    local oldBlueCas = getBlueCasPlayersCount()
    local oldAny = getAnyPlayersCount()

    local b = coalition.getPlayers(coalition.side.BLUE)
    local currentBlue = {}
    local currentBlueCas = {}
    local currentAll = {}
    for _, unit in ipairs(b) do
        local nm = unit:getPlayerName()
        if nm then
            currentAll[nm] = true
            local desc = unit:getDesc()
            local unitType = unit:getTypeName()
            if desc and desc.category == Unit.Category.AIRPLANE then
                if unitType ~= "A-10C_2" and unitType ~= "Hercules" and unitType ~= "A-10A" and unitType ~= "AV8BNA"
				and unitType ~= "AJS37" and unitType ~= "C-130J-30" then
                    currentBlue[nm] = true
                    currentBlueCas[nm] = true
                end
            elseif CasCountExtraTypes[unitType] then
                currentBlueCas[nm] = true
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
    for storedName in pairs(playerListBlueCas) do
        if not currentBlueCas[storedName] then
            playerListBlueCas[storedName] = nil
        end
    end
    for newName in pairs(currentBlueCas) do
        playerListBlueCas[newName] = true
    end

    local r = coalition.getPlayers(coalition.side.RED)
    local currentRed = {}
    for _, unit in ipairs(r) do
        local nm = unit:getPlayerName()
        if nm then
            currentAll[nm] = true
            local desc = unit:getDesc()
            if desc and desc.category == Unit.Category.AIRPLANE then
                if unit:getTypeName() ~= "A-10C_2" and unit:getTypeName() ~= "Hercules" and unit:getTypeName() ~= "A-10A" and unit:getTypeName() ~= "AV8BNA" and unit:getTypeName() ~= "C-130J-30" then
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

    for name in pairs(AnyPlayers) do
        if not currentAll[name] then
            AnyPlayers[name] = nil
        end
    end
    for name in pairs(currentAll) do
        AnyPlayers[name] = true
    end
    for name in pairs(playerZoneSpawn or {}) do
        if not currentAll[name] then
            playerZoneSpawn[name] = nil
        end
    end

    local newBlue = getBluePlayersCount()
    local newBlueCas = getBlueCasPlayersCount()
    local newAny = getAnyPlayersCount()
    if newBlue ~= oldBlue or newBlueCas ~= oldBlueCas or newAny ~= oldAny then
        CapLiveMeta = CapLiveMeta or { [1]={ patrol=nil, attack=nil }, [2]={ patrol=nil, attack=nil } }
        for s=1,2 do
            local bp = getBluePlayersCount() or 0
            local limit = (s==2) and getBlueCapLimit(bp) or getCapLimit(bp)
            local curP = bc:getActiveCAPCount(s, 'patrol')
            local leftP = limit - curP
            if leftP < 1 then leftP = 1 end
            CapLiveMeta[s].patrol = { side=s, mission='patrol', bluePlayers=bp, limit=limit, currentCap=curP, capLeft=leftP }
            local curA = bc:getActiveCAPCount(s, 'attack')
            local leftA = limit - curA
            if leftA < 1 then leftA = 1 end
            CapLiveMeta[s].attack = { side=s, mission='attack', bluePlayers=bp, limit=limit, currentCap=curA, capLeft=leftA }
        end
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
		return 4
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
        return 4
	elseif numPlayers == 5 then
        return 5
	elseif numPlayers == 6 then
        return 5
	elseif numPlayers == 7 then
        return 5
	elseif numPlayers == 8 then
        return 5
	elseif numPlayers == 9 then
        return 5
	elseif numPlayers == 10 then
        return 6
    else
        return 7
    end
end

function getRedCapBoost(numPlayers)
	numPlayers = numPlayers or getBluePlayersCount()
	if numPlayers < 3 then
		return 0
	end
	local totalRedCap = bc:getActiveCAPCount(1, 'patrol') + bc:getActiveCAPCount(1, 'attack')
	if totalRedCap > 0 then
		return 0
	end
	local n = math.floor(numPlayers / 3)
	if n < 1 then n = 1 end
	return n
end

function getBlueSeadLimit(numPlayers)
  numPlayers = numPlayers or getBluePlayersCount()
  if numPlayers <= 0 then
    return 1
  elseif numPlayers == 1 then
    return 1
  else
    return 0
  end
end

function getBlueCasLimit(numPlayers)
  numPlayers = numPlayers or getBlueCasPlayersCount()
  if numPlayers <= 0 then
    return 1
  elseif numPlayers == 1 then
    return 1
  else
    return 0
  end
end


function getBlueCapLimit(numPlayers)
  numPlayers = numPlayers or getBluePlayersCount()
  if numPlayers <= 0 then
    return 1
  elseif numPlayers == 1 then
    return 1
  else
    return 0
  end
end

function BattleCommander:buildNonCapSpawnBuckets()
	self._activeSupplyCount = { [1]={}, [2]={} }
	self._activeCasSeadCount = { [1]={_all=0}, [2]={_all=0} }
	self._activeStrikeCount = { [1]={}, [2]={} }
	self._nonCapBucketsBuilt = true
	for _,zc in ipairs(self.zones or {}) do
		for _,gc in ipairs(zc.groups or {}) do
			if gc then
				gc._nonCapSupplySide=nil
				gc._nonCapSupplyZone=nil
				gc._nonCapCasSeadSide=nil
				gc._nonCapCasSeadMission=nil
				gc._nonCapStrikeSide=nil
				gc._nonCapStrikeMission=nil
				gc._nonCapStrikeRole=nil
				gc._nonCapStrikeUnitCategory=nil
				self:_syncNonCapSpawnBucketsForGroup(gc)
			end
		end
	end
end

function BattleCommander:_nonCapDeltaSupply(side, targetZone, delta)
	local bySide = self._activeSupplyCount[side]
	if not bySide then bySide={} self._activeSupplyCount[side]=bySide end
	local n = (bySide[targetZone] or 0) + delta
	if n <= 0 then bySide[targetZone]=nil else bySide[targetZone]=n end
end

function BattleCommander:_nonCapDeltaCasSead(side, missionType, delta)
	local bySide = self._activeCasSeadCount[side]
	if not bySide then bySide={_all=0} self._activeCasSeadCount[side]=bySide end
	bySide._all = (bySide._all or 0) + delta
	if bySide._all < 0 then bySide._all = 0 end
	if missionType then
		local n = (bySide[missionType] or 0) + delta
		if n <= 0 then bySide[missionType]=nil else bySide[missionType]=n end
	end
end

function BattleCommander:_nonCapDeltaStrike(side, missionType, missionRole, unitCategory, delta)
	local bySide = self._activeStrikeCount[side]
	if not bySide then bySide={} self._activeStrikeCount[side]=bySide end
	local byMission = bySide[missionType]
	if not byMission then byMission={} bySide[missionType]=byMission end
	local byRole = byMission[missionRole]
	if not byRole then byRole={_all=0} byMission[missionRole]=byRole end
	byRole._all = (byRole._all or 0) + delta
	if byRole._all < 0 then byRole._all = 0 end
	if unitCategory ~= nil then
		local n = (byRole[unitCategory] or 0) + delta
		if n <= 0 then byRole[unitCategory]=nil else byRole[unitCategory]=n end
	end
end

function BattleCommander:_syncNonCapSpawnBucketsForGroup(gc)
	if not self._nonCapBucketsBuilt then return end

	local st = gc.state

	local supplyActive = (gc.mission == 'supply') and gc.targetzone and (st == 'takeoff' or st == 'inair' or st == 'landed')
	if supplyActive then
		local side = gc.side
		local targetZone = gc.targetzone
		if gc._nonCapSupplySide then
			if gc._nonCapSupplySide ~= side or gc._nonCapSupplyZone ~= targetZone then
				self:_nonCapDeltaSupply(gc._nonCapSupplySide, gc._nonCapSupplyZone, -1)
				self:_nonCapDeltaSupply(side, targetZone, 1)
				gc._nonCapSupplySide = side
				gc._nonCapSupplyZone = targetZone
			end
		else
			self:_nonCapDeltaSupply(side, targetZone, 1)
			gc._nonCapSupplySide = side
			gc._nonCapSupplyZone = targetZone
		end
	else
		if gc._nonCapSupplySide then
			self:_nonCapDeltaSupply(gc._nonCapSupplySide, gc._nonCapSupplyZone, -1)
			gc._nonCapSupplySide = nil
			gc._nonCapSupplyZone = nil
		end
	end

	local mt = gc.MissionType
	local casSeadType = (mt == 'CAS' or mt == 'SEAD' or mt == 'RUNWAYSTRIKE' or mt == 'ANTISHIP')
	local casSeadActive = casSeadType and gc.Spawned and st ~= 'dead' and st ~= 'inhangar'
	if casSeadActive then
		local side = gc.side
		local missionType = gc.mission
		if gc._nonCapCasSeadSide then
			if gc._nonCapCasSeadSide ~= side or gc._nonCapCasSeadMission ~= missionType then
				self:_nonCapDeltaCasSead(gc._nonCapCasSeadSide, gc._nonCapCasSeadMission, -1)
				self:_nonCapDeltaCasSead(side, missionType, 1)
				gc._nonCapCasSeadSide = side
				gc._nonCapCasSeadMission = missionType
			end
		else
			self:_nonCapDeltaCasSead(side, missionType, 1)
			gc._nonCapCasSeadSide = side
			gc._nonCapCasSeadMission = missionType
		end
	else
		if gc._nonCapCasSeadSide then
			self:_nonCapDeltaCasSead(gc._nonCapCasSeadSide, gc._nonCapCasSeadMission, -1)
			gc._nonCapCasSeadSide = nil
			gc._nonCapCasSeadMission = nil
		end
	end

	local strikeActive = gc.mission and gc.MissionType and (st == 'takeoff' or st == 'inair' or gc.Spawned)
	if strikeActive then
		local side = gc.side
		local missionType = gc.mission
		local missionRole = gc.MissionType
		local unitCategory = gc.unitCategory
		if gc._nonCapStrikeSide then
			if gc._nonCapStrikeSide ~= side or gc._nonCapStrikeMission ~= missionType or gc._nonCapStrikeRole ~= missionRole or gc._nonCapStrikeUnitCategory ~= unitCategory then
				self:_nonCapDeltaStrike(gc._nonCapStrikeSide, gc._nonCapStrikeMission, gc._nonCapStrikeRole, gc._nonCapStrikeUnitCategory, -1)
				self:_nonCapDeltaStrike(side, missionType, missionRole, unitCategory, 1)
				gc._nonCapStrikeSide = side
				gc._nonCapStrikeMission = missionType
				gc._nonCapStrikeRole = missionRole
				gc._nonCapStrikeUnitCategory = unitCategory
			end
		else
			self:_nonCapDeltaStrike(side, missionType, missionRole, unitCategory, 1)
			gc._nonCapStrikeSide = side
			gc._nonCapStrikeMission = missionType
			gc._nonCapStrikeRole = missionRole
			gc._nonCapStrikeUnitCategory = unitCategory
		end
	else
		if gc._nonCapStrikeSide then
			self:_nonCapDeltaStrike(gc._nonCapStrikeSide, gc._nonCapStrikeMission, gc._nonCapStrikeRole, gc._nonCapStrikeUnitCategory, -1)
			gc._nonCapStrikeSide = nil
			gc._nonCapStrikeMission = nil
			gc._nonCapStrikeRole = nil
			gc._nonCapStrikeUnitCategory = nil
		end
	end
end

function BattleCommander:getActiveSupplyCount(side, targetZone)
	if not self._nonCapBucketsBuilt then
		self:buildNonCapSpawnBuckets()
	end
	if self._nonCapBucketsBuilt then
		local bySide = self._activeSupplyCount and self._activeSupplyCount[side]
		if bySide then return bySide[targetZone] or 0 end
	end
    local count = 0
    for _, zoneCom in ipairs(self.zones) do
        for _, groupCom in ipairs(zoneCom.groups) do
            if groupCom.side == side and groupCom.mission == 'supply' and groupCom.targetzone == targetZone then
                if groupCom.state == 'takeoff' or groupCom.state == 'inair' or groupCom.state == 'landed' then
                    count = count + 1
                end
            end
        end
    end
    return count
end

function BattleCommander:getActiveCasSeadCount(side, missionType)
	if not self._nonCapBucketsBuilt then
		self:buildNonCapSpawnBuckets()
	end
	if self._nonCapBucketsBuilt then
		local bySide = self._activeCasSeadCount and self._activeCasSeadCount[side]
		if bySide then
			if not missionType then return bySide._all or 0 end
			return bySide[missionType] or 0
		end
	end
    local count = 0
    for _, zoneCom in ipairs(self.zones) do
        for _, groupCom in ipairs(zoneCom.groups) do
            if groupCom.side == side and (groupCom.MissionType == 'CAS' or groupCom.MissionType == 'SEAD' or groupCom.MissionType == 'RUNWAYSTRIKE' or groupCom.MissionType == 'ANTISHIP') then
                if not missionType or groupCom.mission == missionType then
                    if groupCom.Spawned and groupCom.state ~= 'dead' and groupCom.state ~= 'inhangar' then
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
end

function BattleCommander:getActiveStrikeCount(side, missionType, missionRole, unitCategory)
	if not self._nonCapBucketsBuilt then
		self:buildNonCapSpawnBuckets()
	end
	if self._nonCapBucketsBuilt then
		local bySide = self._activeStrikeCount and self._activeStrikeCount[side]
		local byMission = bySide and bySide[missionType]
		local byRole = byMission and byMission[missionRole]
		if byRole then
			if unitCategory ~= nil then return byRole[unitCategory] or 0 end
			return byRole._all or 0
		end
	end
	local count = 0
	for _, zoneCom in ipairs(self.zones) do
		for _, groupCom in ipairs(zoneCom.groups) do
			if groupCom.side == side and groupCom.mission == missionType and groupCom.MissionType == missionRole then
				if (not unitCategory) or groupCom.unitCategory == unitCategory then
					if groupCom.state == 'takeoff' or groupCom.state == 'inair' or groupCom.Spawned then
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
                        if groupCom.state == 'takeoff' or groupCom.state == 'inair' or groupCom.Spawned then
                            count = count + 1
                        end
                    end
                else
                    if groupCom.state == 'takeoff' or groupCom.state == 'inair' or groupCom.Spawned then
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
end

DebugIsOn = false
DebugIsOnCAP = false
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
			if bz.side == 2 and bz.active and not bz.suspended then blueAnchors[#blueAnchors + 1] = bz.zone end
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
      if bz.side==2 and bz.active and not bz.suspended then blueAnchors[#blueAnchors+1]=bz.zone end
    end
    for _,z in ipairs(bc.zones) do
      if z.side==1 and z.active and not z.suspended and z.airbaseName and
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
      --env.info(string.format("RUNWAY-DBG: option %d  %s  dist=%.0f  score=%d",i,e.zone.zone,e.dist,e.score))
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
  --env.info('RUNWAY-DBG: picked airdrome '..runwayTargetZone.. ' with '..need..' runways to hit')
  RunwayHandler=EVENT:New()
  function RunwayHandler:OnEventShot(EventData)
    if not (EventData and EventData.IniUnit and EventData.weapon and EventData.IniPlayerName) then return end
    local wp=WEAPON:New(EventData.weapon)
    if not wp:IsBomb() then return end
    --env.info('RUNWAY-DBG: '..EventData.IniPlayerName..' dropped '..wp:GetTypeName()..' on '..runwayTargetZone)
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
			local reward = (need>1 and 200 or 100)
           	bc:addContribution(bomberName, 2, reward)
			local jp = bc.jointPairs and bc.jointPairs[bomberName]
			if jp and bc:_jointPartnerAlive(bomberName) and bc:_jointPartnerAlive(jp) and bc.playerContributions[2][jp] ~= nil then
				bc:addContribution(jp, 2, reward)
				bc:addTempStat(jp,'Bomb runway (Joint mission)',1)
				bc:addTempStat(bomberName,'Bomb runway (Joint mission)',1)
				runwayPartnerName = jp
				env.info('RUNWAY-DBG: '..bomberName..' and '..jp..' completed runway strike mission at '..runwayTargetZone)
			else
				 bc:addTempStat(bomberName,'Bomb runway',1)
				runwayPartnerName = nil
				env.info('RUNWAY-DBG: '..bomberName..' completed runway strike mission at '..runwayTargetZone)
			end
			end
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
	casTargetKills = math.random(10,16)
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
				and (groupCom.state == 'inair' or groupCom.state == 'takeoff') then
					countInAir = countInAir + 1
				end
			end
		end
	end
	local players = getBluePlayersCount()
	local limit = getCapLimit(players)
	if players == 0 then return end
	if countInAir >= 1 then
		local target = 0
		if limit == 1 then
			target = math.random(1,2)
		elseif limit == 2 then
			target = math.random(2,4)
		elseif limit == 3 then
			target = math.random(2,5)
		elseif limit == 4 then
			target = math.random(3,6)
		elseif limit == 5 then
			target = math.random(4,6)
		elseif limit == 99999 then
			target = math.random(4,6)
		end
		if target > 0 then
			capTargetPlanes = target
			capMissionTarget = "Active"
		end
	end
end

function getClosestCapZonesToPlayers(missionType, side, preMeta)
	local t_sort=table.sort
	local zoneSide
	if missionType == 'patrol' then
		zoneSide = side
	elseif missionType == 'attack' then
		zoneSide = (side == 1) and 2 or 1
	else
		zoneSide = (side == 1) and 2 or 1
	end

	local anchorSide = (missionType == 'patrol') and ((side == 1) and 2 or 1) or side
	local spawnList = playerZoneSpawn
	local anchors = {}
	if type(spawnList) == 'table' then
		for _, spawnZoneName in pairs(spawnList) do
			local spawnZC = bc.indexedZones[spawnZoneName]
			if spawnZC and spawnZC.side==anchorSide and spawnZC.active and not spawnZC.suspended and not spawnZC.isHidden and CapAnchorRowByZoneName[spawnZC.zone] then
				anchors[#anchors+1] = { zoneName = spawnZC.zone }
			end
		end
	end
	if #anchors == 0 then
		local cached = (CapAnchors and CapAnchors[side] and CapAnchors[side][missionType]) or {}
		for i=1,#cached do anchors[i]=cached[i] end
	end
	if #anchors == 0 then return {}, preMeta end

	local anchorCount = #anchors
	local anchorRows = {}
	for i=1,anchorCount do
		anchorRows[i] = CapAnchorRowByZoneName[anchors[i].zoneName]
	end

	local candidates = {}
	local enemyAdjMap = {}
	local ttab = CapTargets and CapTargets[side] and CapTargets[side][missionType] or nil
	if ttab then
		local connectionMap = bc.connectionMap or {}
		local function hasEnemyNeighbor(zoneName, s)
			local neighbors = connectionMap[zoneName]; if not neighbors then return false end
			for k,v in pairs(neighbors) do
				local n = (type(k)=="string") and k or v
				local nz = bc.indexedZones[n]
				if nz and not nz.isHidden and nz.active and not nz.suspended and nz.side~=0 and nz.side~=s then return true end
			end
			return false
		end
		for tz,_ in pairs(ttab) do
			local z = bc.indexedZones[tz]
			if z and z.active and not z.suspended and not z.isHidden then
				local ok = (missionType=='patrol') and (z.side==zoneSide) or ((missionType=='attack') and (z.side~=side and z.side~=0))
				if ok then
					candidates[#candidates+1] = tz
					enemyAdjMap[tz] = hasEnemyNeighbor(tz, zoneSide) and true or false
				end
			end
		end
	end

	local BIG=99999999
	local zoneDistances = {}
	for i=1,#candidates do
		local znB = candidates[i]
		local sum = 0
		for j=1,anchorCount do
			local row = anchorRows[j]
			local d = (row and row[znB]) or BIG
			sum = sum + d
		end
		local avg = sum / anchorCount
		if enemyAdjMap[znB] then avg = avg * 0.6 end
		zoneDistances[#zoneDistances+1] = { zone = znB, distance = avg }
	end
	t_sort(zoneDistances, function(a,b) return a.distance < b.distance end)

	local capMeta = preMeta
	if missionType=='patrol' or missionType=='attack' then
		local targets = (CapTargets and CapTargets[side] and CapTargets[side][missionType]) or {}
		if not capMeta then
			local bluePlayers = getBluePlayersCount() or 0
			local limit = (side==2) and getBlueCapLimit(bluePlayers) or getCapLimit(bluePlayers)
			local currentCap = bc:getActiveCAPCount(side, missionType)
			local capLeft = limit - currentCap
			if capLeft < 1 then capLeft = 1 end
			capMeta = { side=side, mission=missionType, bluePlayers=bluePlayers, limit=limit, currentCap=currentCap, capLeft=capLeft, targets=targets, enemyAdj=enemyAdjMap }
		else
			capMeta.targets = targets
			capMeta.enemyAdj = enemyAdjMap
		end
	end

	if DebugIsOnCAP then
		env.info("[DEBUG] Anchors for "..missionType..":")
		for i=1,#anchors do env.info("  - "..tostring(anchors[i].zoneName)) end
		env.info("[DEBUG] Candidates for "..missionType.." (side="..tostring(zoneSide).."):")
		for i=1,#candidates do
			local znB = candidates[i]
			local tCZ = CustomZone:getByName(znB)
			if tCZ and not tCZ.isHidden then
				local sum, bad = 0, 0
				for j=1,#anchors do
					local znA = anchors[j].zoneName
					local d = ((CapAnchorRowByZoneName[znA]) and CapAnchorRowByZoneName[znA][znB]) or nil
					if not d then bad = bad + 1 ; d = BIG end
					sum = sum + d
				end
				local avg = sum / #anchors
				if enemyAdjMap[znB] then avg = avg * 0.6 end
				env.info(string.format("[DEBUG] cand=%s avg=%.0f missing=%d", tostring(znB), avg, bad))
			else
				env.info("[DEBUG] cand skipped (no CZ): "..tostring(znB))
			end
		end
	end

	return zoneDistances, capMeta
end


function GroupCommander:shouldSpawn(ignore)
	local plane = Unit.Category.AIRPLANE
	local heli = Unit.Category.HELICOPTER

	if not self.zoneCommander.active then
		return false
	end

	if self.zoneCommander.suspended then 
		return false 
	end

	local tg = self.zoneCommander.battleCommander:getZoneByName(self.targetzone)

	if not tg or tg.suspended or tg.active == false then return false end

	
	if self.condition and not self.condition() then return false end

	if self.Bluecondition then 
		if self.side == 2 then
			if not self.Bluecondition() then return false end
		else
			return false
		end
	end

	if self.Redcondition then 
		if self.side == 1 then
			if not self.Redcondition() then return false end
		else
			return false
		end
	end

	local isUrgent = type(self.urgent) == "function" and self.urgent() or self.urgent

	local distNm = Frontline.ZoneDistToFrontNm(self.targetzone)
	if distNm == nil then
		return false
	end

	if self.mission ~= 'supply' then
	
	local cutoff = (self.side == 2) and GlobalSettings.frontlineDistanceLimitBlue or GlobalSettings.frontlineDistanceLimitRed
	if distNm < -cutoff then return false end
	end
		

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

    if self.side ~= self.zoneCommander.side then
		return false 
	end

	if self.side==2 and self.MissionType=='CAP' then
		if distNm and distNm < -(GlobalSettings.capRearlineNmBlue or 30) then return false end
	end


	if self.side==1 and self.MissionType=='CAP' then
		if distNm and distNm < -(GlobalSettings.capRearlineNmRed or 60) then return false end
	end

  

    if tg and tg.active then
		if self.mission=='attack' and (self.MissionType=='CAS' or self.MissionType=='SEAD' or self.MissionType=='RUNWAYSTRIKE' or self.MissionType=='ANTISHIP') then
			if tg.side ~= self.side and tg.side ~= 0 then
				if self.side == 1 then
					if self.MissionType=='SEAD' and not self.zoneCommander.battleCommander:HasSeadTargets(tg.zone) then
						return false
					end
					if self.unitCategory ~= plane then return true end
					local players = getBluePlayersCount() or 0
					local limit = getRedStrikeLimit(players) or 0
					if limit <= 0 then return false end
					local active = self.zoneCommander.battleCommander:getActiveStrikeCount(1,'attack',self.MissionType,self.unitCategory)
					if active >= limit then
						return false
					end
					if self.MissionType ~='CAS' and players == 0 then
						return false
					end
					return true
				end
				if self.side==2 then
					if self.MissionType=='SEAD' and not self.zoneCommander.battleCommander:HasSeadTargets(tg.zone) then
						return false
					end
					local players = getBluePlayersCount() or 0
					local playersCas = getBlueCasPlayersCount() or 0
					if self.MissionType=='ANTISHIP' and players > 1 then return false end
					local limit   = getBlueSeadLimit(players) or 0
					if limit <= 0 then return false end
					if self.MissionType=='CAS' and playersCas > 1 then return false end
					local limit   = getBlueCasLimit(playersCas) or 0
					if limit <= 0 then return false end
					local active = self.zoneCommander.battleCommander:getActiveCasSeadCount(2,'attack')
					if active >= limit then
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
					local cost = 0
					if self.side==2 and getAnyPlayersCount() > 0 then
						local zones = bc.blueZoneCount or 0
						cost = math.min(zones * 10, 100)
						if (bc.accounts[2] ~= nil and bc.accounts[2] < cost) then
							env.info(string.format("[SUPPLY-SPAWN] not enough funds for supply in %s (have %d, need %d)", tg.zone, bc.accounts[2] or 0, cost))
							return false
						end
					end
					if self.side == 2 then
						self._pendingBlueSupplyCost = (cost > 0) and cost or nil
					end
					return true
				end
				return false
			end
			return false
		end

        if (self.mission == 'patrol') and (self.MissionType == 'CAP') then
            if tg.side == self.side then
                local bluePlayers = getBluePlayersCount() or 0
                local limit = (self.side==2) and getBlueCapLimit(bluePlayers) or getCapLimit(bluePlayers)
                local currentCap = bc:getActiveCAPCount(self.side, 'patrol')
				if self.side == 1 then
					local boost = getRedCapBoost(bluePlayers)
					if boost > 0 then
						limit = boost
					end
				end

                if self.side==2 and limit==0 then return false end
                if currentCap >= limit then
                    if DebugIsOn then
                        env.info(string.format("[DEBUG] CAP patrol limit reached: currentCap=%d, limit=%d, mission=%s", currentCap, limit, self.name))
                    end
                    return false
                end
                local capLeft = limit - currentCap
                if capLeft < 1 then capLeft = 1 end
                local zoneDistances, capMeta = getClosestCapZonesToPlayers('patrol', self.side, nil)
				if #zoneDistances==0 then return true end
                local capWindow = math.min(#zoneDistances, capLeft)
                local tgRank=nil; for i=1,#zoneDistances do if zoneDistances[i].zone==tg.zone then tgRank=i break end end
                
				local enemyAdj = (capMeta and capMeta.enemyAdj and capMeta.enemyAdj[tg.zone]) or false
                
				local bonusTop = math.max(3, capWindow)
                if not tgRank or (tgRank>capWindow and not (enemyAdj and tgRank<=bonusTop)) then
                    if DebugIsOn then
                        env.info(string.format("[DEBUG] CAP patrol is not within the top %d zones; skipping spawn: mission=%s", capWindow, self.name))
                        local topN = math.min(capWindow, #zoneDistances)
                        for i=1,topN do
                            local zdi=zoneDistances[i]
                            env.info(string.format("[CAP TOP] #%d %s dist=%.0f", i, zdi.zone, zdi.distance))
                        end
                    end
                    self:_enterHangar(false)
                    return false
                end
                local ctx = capMeta and capMeta.targets and capMeta.targets[tg.zone]
                if ctx then
                    local myRank = ctx.ranksByName and ctx.ranksByName[self.name] or nil
                    local capLeft = capMeta and capMeta.capLeft or (limit - currentCap)
                    if myRank then
                        local activeAhead=0
                        for i=1,myRank-1 do
                            local rec=ctx.candidates[i]
                            local gc=CapRef and CapRef[rec.name]
                            local st=gc and gc.state or rec.state
                            if st=='preparing' then activeAhead=activeAhead+1 end
                        end
                        if activeAhead>=capLeft then
                            self:_enterHangar(false)
                            return false
                        end
                    end
                end
                if DebugIsOn then
                    env.info(string.format("[CAP PATROL] target=%s rank=%s capWindow=%d", tg.zone, tostring(tgRank), capWindow))
                    local topN = math.min(capWindow, #zoneDistances)
                    for i=1,topN do
                        local zdi=zoneDistances[i]
                        env.info(string.format("[CAP TOP] #%d %s dist=%.0f", i, zdi.zone, zdi.distance))
                    end
                end
                return true
            end
            return false
        end

        if (self.mission == 'attack') and (self.MissionType == 'CAP') then
            if tg.side ~= self.side and tg.side ~= 0 then
                local bluePlayers = getBluePlayersCount() or 0
                local limit = (self.side==2) and getBlueCapLimit(bluePlayers) or getCapLimit(bluePlayers)
                local currentCap = bc:getActiveCAPCount(self.side, 'attack')
				if self.side == 1 then
					local boost = getRedCapBoost(bluePlayers)
					if boost > 0 then
						limit = boost
					end
				end
                if self.side==2 and limit==0 then return false end
                if self.side==1 and bluePlayers==0 then return false end
                if currentCap >= limit then
                    if DebugIsOn then
                        env.info(string.format("[DEBUG] CAP attack limit reached: currentCap=%d, limit=%d, mission=%s", currentCap, limit, self.name))
                    end
                    return false
                end
                local capLeft = limit - currentCap
                if capLeft < 1 then capLeft = 1 end
                local zoneDistances, capMeta = getClosestCapZonesToPlayers('attack', self.side, nil)
				if #zoneDistances==0 then return true end
                local capWindow = math.min(#zoneDistances, capLeft)

                local tgRank=nil; for i=1,#zoneDistances do if zoneDistances[i].zone==tg.zone then tgRank=i break end end
				
				local enemyAdj = (capMeta and capMeta.enemyAdj and capMeta.enemyAdj[tg.zone]) or false
                
				local bonusTop = math.max(3, capWindow)
                if not tgRank or (tgRank>capWindow and not (enemyAdj and tgRank<=bonusTop)) then
                    if DebugIsOn then
                        env.info(string.format("[DEBUG] attack CAP is not within the top %d zones; skipping spawn: mission=%s", capWindow, self.name))
                    end
                    return false
                end
                local ctx = capMeta and capMeta.targets and capMeta.targets[tg.zone]
                if ctx then
                    local myRank = ctx.ranksByName and ctx.ranksByName[self.name] or nil
                    local capLeft = capMeta and capMeta.capLeft or (limit - currentCap)
                    if myRank then
                        local activeAhead=0
                        for i=1,myRank-1 do
                            local rec=ctx.candidates[i]
                            local gc=CapRef and CapRef[rec.name]
                            local st=gc and gc.state or rec.state
                            if st=='preparing' then activeAhead=activeAhead+1 end
                        end
                        if activeAhead>=capLeft then
                            return false
                        end
                    end
                end
                return true
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

function GroupCommander:_spawnFromGroundAt(resolved, originZone, targetZone, hot)
	if self.unitCategory == Unit.Category.AIRPLANE then return nil end
    local tpl = self:_getAirTemplate(resolved); if not tpl then return nil end
    local base = originZone and (originZone.."-land") or nil
    local pool = nil
	if base and LandingSpots then
		pool = {}
		for n, lst in pairs(LandingSpots) do
			if n:sub(1, #base) == base then
				for i=1,#lst do
					local spot = lst[i]
					if spot and spot.x and spot.z then
						pool[#pool+1] = { name = n, x = spot.x, z = spot.z }
					end
				end
			end
		end
        if #pool == 0 then
            local idx = 0
            while true do
                local fname = string.format("%s-land-forced-%d", originZone, idx)
                local fz = trigger.misc.getZone(fname)
                if not fz then break end
				pool[#pool+1] = { name=fname, x=fz.point.x, z=fz.point.z }
                idx = idx + 1
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
		if lz then p = { name = string.format("%s-flat", originZone or "unknown"), x=lz.x, z=lz.z } end
    end
    if not p then return nil end
    local jitter = 20
    local lx, lz = p.x + math.random(-jitter,jitter), p.z + math.random(-jitter,jitter)

    local ly = land.getHeight({x=lx, y=lz})
    tpl.x = lx; tpl.y = lz
    tpl.route = tpl.route or {}; tpl.route.points = tpl.route.points or {}; tpl.route.points[1] = tpl.route.points[1] or {}
	tpl.route.points[1].type = hot and "TakeOffGroundHot" or "TakeOffGround"; tpl.route.points[1].action = hot and "From Ground Area Hot" or "From Ground Area"; tpl.route.points[1].x = lx; tpl.route.points[1].y = lz; tpl.route.points[1].alt = 0; tpl.route.points[1].alt_type = "RADIO"
	for i=1,#tpl.units do local u=tpl.units[i]; local dx=(#tpl.units==2) and 0 or (i-1)*4; local dy=(#tpl.units==2) and ((i==1) and -15 or 15) or 0; u.x=lx+dx; u.y=lz+dy; u.alt=ly; u.parking=nil; u.parking_id=nil end
    self._lastGroundSpawnSpot = { zone = p.name or base or originZone, x = lx, z = lz }
    local sp = SPAWN:NewFromTemplate(tpl, resolved, self.name, true)
    if self.mission=='supply' and self.unitCategory==Unit.Category.HELICOPTER then
		if WarehouseLogistics == true and (not self.NotCargo) then
        sp = sp:OnSpawnGroup(function(g) self:_assignHeloLogisticsRoute(g:GetName(), self.targetzone, originZone, self.side) end)
		else
		 sp = sp:OnSpawnGroup(function(g) self:_assignHeloRoute(g:GetName(), self.targetzone) end)
		end
    elseif self.MissionType=='CAS' and self.unitCategory==Unit.Category.HELICOPTER and self.template then
        sp = sp:OnSpawnGroup(function(g) bc:EngageHeloCasMission(self.targetzone, g:GetName(), nil, nil, self._landUnitID) end)
    elseif self.MissionType=='CAS' and self.unitCategory==Unit.Category.AIRPLANE and self.template then
        sp = sp:OnSpawnGroup(function(g) bc:EngageCasMission(self.targetzone, g:GetName(), nil, nil, self.Altitude or self.AltitudeFt, self._landUnitID) end)
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

	function GroupCommander:_getDcsGroupCached()
		local currentName = self.spawnedName or self.name
		if self._dcsGroup and self._dcsGroup:isExist() and self._dcsGroup:getName() == currentName then
			return self._dcsGroup
		end
		if not currentName then return nil end
		local gr = Group.getByName(currentName)
		if gr and gr:isExist() then
			self._dcsGroup = gr
			return gr
		end
		self._dcsGroup = nil
		return nil
	end

	ProblemGroups = {}
	function GroupCommander:processAir()
		local originZone = self.zoneCommander.zone
		local gr = self:_getDcsGroupCached()
		--local gr = Group.getByName(self.spawnedName or self.name)
		local zside = self.zoneCommander.side
		local plane = Unit.Category.AIRPLANE
		local heli = Unit.Category.HELICOPTER
		if self.unitCategory and self.unitCategory ~= plane and self.unitCategory ~= heli then
			if not self._processAirErrorReported then
				trigger.action.outText("GroupCommander:processAir called for non-air unit "..tostring(self.name).." Report it to leka",30)
				self._processAirErrorReported = true
			end
			return
		end
		
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
		
		if self.Spawned then self.Spawned = false end

		if (not gr) or (not gr:isExist()) or (gr:getSize() == 0) then
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
			else
				self:_enterHangar(false)
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
						self.Spawned = false
						local resolved = self:_resolveTemplateName()
						local SpawnType = self:_resolveSpawn()
						self._landUnitID = SpawnType and SpawnType.airbaseId or nil
						if SpawnType and SpawnType.isShip then self.landsatcarrier = true end
						if (not SpawnType or not (SpawnType.airbase and SpawnType.spots and #SpawnType.spots>0)) and self.unitCategory==Unit.Category.AIRPLANE then
							SpawnType = self:_resolveParkingWithBelonging()
						end
						if (self.Airbase) or (SpawnType and SpawnType.kind == 'parking' and SpawnType.airbase and SpawnType.spots and #SpawnType.spots>0) then
							local tpl = self:_getAirTemplate(resolved)
							if tpl then
								local sp = SPAWN:NewFromTemplate(tpl, resolved, self.name, true)
								sp = sp:InitSkill("Excellent"):OnSpawnGroup(function(g)

										if self.MissionType == 'CAP' and self.mission== 'patrol' then
											local gr = Group.getByName(g:GetName()); if not gr then return end
											local side = self.side
											local offsetNm = (side == 1) and math.random(10, 20) or math.random(1, 5)
											local towardEnemyNm = 35
											local off = (self.side == 2) and -towardEnemyNm or towardEnemyNm
											local safe = (self.side == 1) and 40 or 30
											local st = Frontline.PickStationNearZone(self.targetzone, self.side, off, 0, 0, 0, safe)
											if not st then return end
											local dist = (side == 1) and math.random(30, 40) or math.random(30, 40)
											SetUpCAP(gr, { x = st.x, z = st.y }, self.Altitude, dist, self._landUnitID, safe, side)

										elseif self.MissionType == 'CAP' and self.mission== 'attack' then
											local gr = Group.getByName(g:GetName()); if not gr then return end
											local side = self.side
											local offsetNm = (side == 1) and 35 or 25
											local st = Frontline.PickCapStationFromOrigin(originZone, self.targetzone, side, 100, offsetNm)
											if not st then return end
											local dist = (side == 1) and math.random(35, 45) or math.random(35, 40)
											SetUpCAP(gr, { x = st.x, z = st.y }, self.Altitude, dist, self._landUnitID, offsetNm, side)

										elseif self.mission == 'supply' and self.unitCategory == heli then
											if self.side == 2 and self._pendingBlueSupplyCost and self._pendingBlueSupplyCost > 0 then
												self.zoneCommander.battleCommander.accounts[2] = math.max((self.zoneCommander.battleCommander.accounts[2] or 0) - self._pendingBlueSupplyCost, 0)
												self._pendingBlueSupplyCost = nil end
												if WarehouseLogistics == true and (not self.NotCargo) then
													self:_assignHeloLogisticsRoute(g:GetName(), self.targetzone, originZone, self.side)
												else
													self:_assignHeloRoute(g:GetName(), self.targetzone)
												end

										elseif self.mission == 'supply' and self.unitCategory == plane then
											if self.side == 2 and self._pendingBlueSupplyCost and self._pendingBlueSupplyCost > 0 then
												self.zoneCommander.battleCommander.accounts[2] = math.max((self.zoneCommander.battleCommander.accounts[2] or 0) - self._pendingBlueSupplyCost, 0)
												self._pendingBlueSupplyCost = nil end
											self:_assignPlaneRoute(g:GetName(), self.targetzone, self.Altitude,originZone,self.side)

										elseif self.MissionType=='CAS' and self.unitCategory == plane then
											bc:EngageCasMission(self.targetzone, g:GetName(), nil, nil, self.Altitude, self._landUnitID, self.side)
											
										elseif self.MissionType=='CAS' and self.unitCategory == heli then
											bc:EngageHeloCasMission(self.targetzone, g:GetName(), nil, nil, self._landUnitID)
										elseif self.MissionType=='SEAD' and self.unitCategory == plane then
											bc:EngageSeadMission(self.targetzone, g:GetName(), nil, self.Altitude, self._landUnitID)

										elseif self.MissionType=='RUNWAYSTRIKE' and self.unitCategory == plane then
											bc:EngageRunwayBombAuftrag(self.zoneCommander.airbaseName, self.targetzone, g:GetName(), self.Altitude, self.side)
										
										elseif self.MissionType=='ANTISHIP' and self.unitCategory == plane then
											bc:EngageAntiShipMission(self.targetzone, g:GetName(),nil,nil, self.Altitude, self._landUnitID)
										end

								end)
									local tk = (self.mission == 'supply' and self.side == 2) and SPAWN.Takeoff.Hot or SPAWN.Takeoff.Cold
									local spawned = nil
								if self.ForceFromGround and self.unitCategory == heli then
									local tk = (self.mission == 'supply' and self.side == 2) and true or false
									spawned = self:_spawnFromGroundAt(resolved, originZone, self.targetzone, tk)
								else
									if not self.Airbase then
										spawned = sp:SpawnAtParkingSpot(SpawnType.airbase, SpawnType.spots, tk)
										if not spawned then spawned = sp:SpawnAtAirbase(SpawnType.airbase, tk) end
										if spawned and self.unitCategory == heli then spawned:OptionPreferVerticalLanding() end
									else
										local ab = AIRBASE:FindByName(self.Airbase)
										if ab and ab:GetCoalition()==self.side then
											self._landUnitID = ab:GetID()
											if ab:IsShip() then if IsGroupActive(ab:GetName()) then
												self.landsatcarrier = true
												spawned = sp:SpawnAtAirbase(ab, tk) end
											else
												spawned = sp:SpawnAtAirbase(ab, tk)
											end
										end
									end
								end
								if not spawned then self:_enterHangar(false); return end
								if spawned then spawned:OptionPreferVerticalLanding(); self.spawnedName = spawned:GetName(); didSpawn = true end
							end
						else
							if self.unitCategory == plane then
								self:_enterHangar(false)
							else
								local tk = (self.mission == 'supply' and self.side == 2) and SPAWN.Takeoff.Hot or SPAWN.Takeoff.Cold
								local spawned = self:_spawnFromGroundAt(resolved, originZone, self.targetzone, tk)
								if spawned then
									if (self.mission=='supply' or self.MissionType=='CAS') and self.unitCategory == heli then spawned:OptionPreferVerticalLanding() end
									self.spawnedName = spawned:GetName()
									didSpawn = true
								end
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
				if didSpawn then
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
				else
					self:_enterHangar(false)
				end
			end
		end

		elseif self.state == 'takeoff' then
			if timer.getAbsTime() - self.lastStateTime > GlobalSettings.blockedDespawnTime then
				if gr and Utils.allGroupIsLanded(gr, self.landsatcarrier) then
				gr:destroy()
				self:_enterHangar(false)
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
			if self.mission == 'supply' and self.unitCategory == heli and timer.getAbsTime() - self.lastStateTime > 240 then
				local hb = self.zoneCommander.battleCommander:getZoneByName(self.zoneCommander.zone)
				if hb and gr and Utils.someOfGroupInZone(gr, hb.zone) then
					if self._logiCargoByGroup then
						local cname = self._logiCargoByGroup[self.name]
						if cname then
							local cargo = StaticObject.getByName(cname)
							if cargo and cargo:isExist() then cargo:destroy() end
							self._logiCargoByGroup[self.name] = nil
						end
					end
					if gr and gr:isExist() then gr:destroy() end
					self.state = 'preparing'
					self.lastStateTime = timer.getAbsTime()
					self._zonePinged = nil
					self.pinged = false
					return
				end
			end
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
				self._landedAt = self._landedAt or self.lastStateTime
			end
		elseif self.state == 'landed' then
			self._landedAt = self._landedAt or timer.getAbsTime()
			if self.mission == 'supply' then
				local tg = self.zoneCommander.battleCommander:getZoneByName(self.targetzone)
				if tg and gr and Utils.someOfGroupInZone(gr, tg.zone) then
					self:_enterHangar(false)
					self._landedAt = nil
					if tg.side == 0 then
						env.info("Group [" .. self.name .. "] landed in zone [" .. tg.zone .. "], capturing zone for side " .. self.side)
						SCHEDULER:New(nil,function() tg:capture(self.side) end,{},0.3,0)
					elseif tg.side == self.side then
						env.info("Group [" .. self.name .. "] landed in zone [" .. tg.zone .. "], upgrading zone for side " .. self.side)
						tg:upgrade()
					end
					local abName = tg.airbaseName
					if abName and WarehouseLogistics and self.side == 2 then
						if AIDeliveryamount == nil then AIDeliveryamount = 20 end
						local amount = (self.unitCategory == plane) and 50 or AIDeliveryamount
						local bcObj =self.zoneCommander.battleCommander
						if bcObj and bcObj.addWarehouseItemsAtZone then
							bcObj:addWarehouseItemsAtZone(tg, self.side, amount)
						end
						if self._logiCargoByGroup then
							local cname = self._logiCargoByGroup[self.name]
							if cname then
								local cargo = StaticObject.getByName(cname)
								if cargo and cargo:isExist() then cargo:destroy() end
								self._logiCargoByGroup[self.name] = nil
							end
						end
					end
					SCHEDULER:New(nil,function() if gr and gr:isExist() then gr:destroy() end end,{},0.5,0) return
				else
					local hb = self.zoneCommander.battleCommander:getZoneByName(self.zoneCommander.zone)
					if hb and gr and Utils.someOfGroupInZone(gr, hb.zone) then
						self:_enterHangar(false)
						self._landedAt = nil
						SCHEDULER:New(nil,function() if gr and gr:isExist() then gr:destroy() end end,{},0.5,0) return
					end
				end
				local landedDespawnTime = (self.unitCategory == plane) and 180 or GlobalSettings.landedDespawnTime
				if timer.getAbsTime() - (self._landedAt or self.lastStateTime) > landedDespawnTime then
					if gr and gr:isExist() then gr:destroy() end
					self:_enterHangar(false)
					self._landedAt = nil
				end
			else
				local hb = self.zoneCommander.battleCommander:getZoneByName(self.zoneCommander.zone)
				if hb and gr and Utils.someOfGroupInZone(gr, hb.zone) then
					self:_enterHangar(false)
					self._landedAt = nil
					SCHEDULER:New(nil,function() if gr and gr:isExist() then gr:destroy() end end,{},0.5,0) return
				else
					local landedDespawnTime = (self.unitCategory == plane) and 180 or GlobalSettings.landedDespawnTime
					if timer.getAbsTime() - (self._landedAt or self.lastStateTime) > landedDespawnTime then
						self:_enterHangar(false)
						self._landedAt = nil
						SCHEDULER:New(nil,function() if gr and gr:isExist() then gr:destroy() end end,{},0.5,0)
					end
				end
			end
		elseif self.state == 'dead' then
			if timer.getAbsTime() - self.lastStateTime > (respawnTimers.dead * spawnDelayFactor) then
				if self:shouldSpawn() then
					self:_enterHangar(false)
				end
			end
		end
	end

	
	function GroupCommander:processSurface()
		local gr
		if self.spawnedName and self.spawnedName ~= "" then gr = Group.getByName(self.spawnedName) end
		if not gr and self.name and self.name ~= "" then gr = Group.getByName(self.name) end

		if self.template then
			if self.zoneCommander.side and self.zoneCommander.side ~= 0 and self.zoneCommander.side ~= self.side then self.side = self.zoneCommander.side end
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
                     local startVec2
                    if self.mission == 'supply' then
                        local _, sv = dc.GetSupplyConvoyRoute(self.zoneCommander.zone, self.targetzone, dc.DEFAULT_SPEED)
                        startVec2 = sv
                    else
                        local _, sv = dc.GetAttackConvoyRoute(self.zoneCommander.zone, self.targetzone, dc.DEFAULT_SPEED)
                        startVec2 = sv
                    end
					if startVec2 then
                        local chosenTemplate = self:_resolveTemplateName()
                        if chosenTemplate then
                            local tpl = self:_getAirTemplate(chosenTemplate)
                            if tpl then
                                local sp = SPAWN:NewFromTemplate(tpl, chosenTemplate, self.name, true)
                                sp = sp:OnSpawnGroup(function(g)
									local task
									if self.mission == 'supply' then
										task = dc.GetSupplyConvoyRoute(self.zoneCommander.zone, self.targetzone, dc.DEFAULT_SPEED)
									else
										task = dc.GetAttackConvoyRoute(self.zoneCommander.zone, self.targetzone, dc.DEFAULT_SPEED)
									end
									if not task then return end
									local gr = Group.getByName(g:GetName()); if not gr then return end
									local c = gr:getController()
									if c then
										SCHEDULER:New(nil,function() c:setTask(task) end,{},2)
										--c:setTask(task)
									end
								end)
                                local p = COORDINATE:NewFromVec2(startVec2)
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
                self:_jtacMessage('JTAC: We spotted enemy convoy ', nil, self.zoneCommander.zone)
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
					if shouldWeSend > 98 then
						if self.mission == 'supply' then
							trigger.action.outTextForCoalition(2,"Intel: Enemy supply convoy is inbound from " .. self.zoneCommander.zone .. ", headed toward " .. self.targetzone .. ".",15)
							self.groundconvoyMessaged = true
						else
							trigger.action.outTextForCoalition(2,"Intel: Enemy attack convoy is inbound from " .. self.zoneCommander.zone .. ", headed toward " .. self.targetzone .. ".",15)
							self.groundconvoyMessaged = true
						end
					end
				end
			end
		elseif self.state == 'atdestination' then
			if self.mission == 'supply' then
				if timer.getAbsTime() - self.lastStateTime > GlobalSettings.landedDespawnTime then
					local tg = self.zoneCommander.battleCommander:getZoneByName(self.targetzone)
					if tg and gr and Utils.someOfGroupInZone(gr, tg.zone) then
						self:_enterHangar(false)
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
							self:_enterHangar(false)
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
			local prevState=self.state
			local prevSpawned=self.Spawned and true or false
			local prevSide=self.side
			local prevMission=self.mission
			local prevMissionType=self.MissionType
			local prevUnitCategory=self.unitCategory
			local prevTargetzone=self.targetzone

			self:processAir()

			local spawnedNow=self.Spawned and true or false
			if prevState~=self.state or prevSpawned~=spawnedNow or prevSide~=self.side or prevMission~=self.mission or prevMissionType~=self.MissionType or prevUnitCategory~=self.unitCategory or prevTargetzone~=self.targetzone then
				self.zoneCommander.battleCommander:_syncNonCapSpawnBucketsForGroup(self)
			end
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
		--['F-14B'] =     	{ minDist = 40,  maxDeviation = 160,  laserOffset = { x = 1.01, y = 0.1, z = 0 }   },
		--['F-14A-135-GR'] =  { minDist = 40,  maxDeviation = 160,  laserOffset = { x = 1.01, y = 0.1, z = 0 }   },
		--['F-14A-135-GR-Early'] =  { minDist = 40,  maxDeviation = 160,  laserOffset = { x = 1.01, y = 0.1, z = 0 }   },
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
	LogisticCommander.allowedTypes['C-130J-30'] = true
	LogisticCommander.allowedTypes['MH-6J'] = true
	LogisticCommander.allowedTypes['AH-6J'] = true

LogisticCommander.AllowedToCarrySupplies = {
    ['Ka-50'] = false,
    ['Ka-50_3'] = false,
    ['Mi-24P'] = true,
    ['SA342Mistral'] = false,
    ['SA342L'] = false,
    ['SA342M'] = false,
    ['SA342Minigun'] = false,
    ['UH-60L'] = true,
    ['UH-60L_DAP'] = true,
    ['AH-64D_BLK_II'] = false,
    ['UH-1H'] = true,
    ['Mi-8MT'] = true,
    ['Hercules'] = true,
    ['OH58D'] = false,
    ['CH-47Fbl1'] = true,
    ['Bronco-OV-10A'] = true,
    ['OH-6A'] = true,
    ['C-130J-30'] = true,
	['MH-6J'] = true,
	['AH-6J'] = true,
}

LogisticCommander.AllowedCsar = {
    ['Ka-50'] = 1,
    ['Ka-50_3'] = 1,
    ['Mi-24P'] = 8,
    ['SA342Mistral'] = 3,
    ['SA342L'] = 3,
    ['SA342M'] = 3,
    ['SA342Minigun'] = 3,
    ['UH-60L'] = 11,
    ['UH-60L_DAP'] = 11,
    ['AH-64D_BLK_II'] = 2,
    ['UH-1H'] = 11,
    ['Mi-8MT'] = 24,
    ['Hercules'] = 0,
    ['OH58D'] = 1,
    ['CH-47Fbl1'] = 32,
    ['Bronco-OV-10A'] = 5,
    ['OH-6A'] = 2,
    ['C-130J-30'] = 0,
    ['MH-6J'] = 4,
    ['AH-6J'] = 4,
}

	LogisticCommander.doubleSupplyTypes = {}
	LogisticCommander.doubleSupplyTypes['CH-47Fbl1'] = true
	LogisticCommander.doubleSupplyTypes['Hercules'] = true
	LogisticCommander.doubleSupplyTypes['C-130J-30'] = true

	--LogisticCommander.maxCarriedPilots = 4
	LogisticCommander.PilotWeight = 80
	LogisticCommander.csarHoverDistance = 15
	LogisticCommander.csarHoverHeight = 40
	LogisticCommander.csarHoverSeconds = 10
	
	LogisticCommander.mooseLogisticsMenus = {}

	--{ battleCommander = object, supplyZones = { 'zone1', 'zone2'...}}
	function LogisticCommander:new(obj)
		obj = obj or {}
		obj.groupMenus = {} -- groupid = path
		obj.csarGroupMenus = {}
		obj.groupIdToName = {}
		obj.statsMenus = {}
		obj.carriedCargo = {} -- groupid = source
		obj.ejectedPilots = {}
		obj.carriedPilots = {} -- groupid = count
		obj.carriedPilotData = {}
		obj.csarGroups = {}
		obj.csarSet = (SET_GROUP and SET_GROUP.New) and SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryHelicopter():FilterStart() or nil
		obj.csarVisibleMsg = {}
		obj.csarCloseMsg = {}
		obj.csarRunEta = {}
		obj.csarSmokeTick = {}
		obj.csarNextTick = {}
		obj.csarLastAutoDrop = {}
		obj.csarApproachNear = 3000
		obj.csarExtractDistance = 650
		obj.csarLoadDistance = 20
		
		setmetatable(obj, self)
		self.__index = self
		return obj
	end
end



	function LogisticCommander:loadSupplies(groupName, supplyCount)
		local gr = Group.getByName(groupName)
		if gr then
			local un = gr:getUnit(1)
			if un then
				if Utils.isInAir(un) then
					trigger.action.outTextForGroup(gr:getID(), 'Cannot load supplies while in air', 10)
					return
				end
				
				self._lastLoadTs = self._lastLoadTs or {}
				local gid = gr:getID()
				local now = timer.getTime()
				if self._lastLoadTs[gid] and now - self._lastLoadTs[gid] < 1 then return end
				self._lastLoadTs[gid] = now

				local unitType = un:getTypeName()
				local loadCount = supplyCount or 1
				if loadCount > 1 then
					if not (LogisticCommander.doubleSupplyTypes and LogisticCommander.doubleSupplyTypes[unitType]) then
						loadCount = 1
					end
				end
				if loadCount < 1 then
					loadCount = 1
				end
				local existingCargo = self.carriedCargo[gr:getID()]
				if existingCargo then
					local count = type(existingCargo) == "table" and existingCargo.count or 1
					local cap = (LogisticCommander.doubleSupplyTypes and LogisticCommander.doubleSupplyTypes[unitType]) and 2 or 1
					if count < cap then
						local newCount = count + loadCount
						if newCount > cap then newCount = cap end
						self.carriedCargo[gr:getID()] = { source = (type(existingCargo) == "table" and existingCargo.source or existingCargo), count = newCount }
						trigger.action.setUnitInternalCargo(un:getName(), 100 * newCount)
						local msg
						if newCount > 1 then
							msg = newCount.." supplies loaded"
						else
							msg = "Supplies loaded"
						end
						trigger.action.outTextForGroup(gr:getID(), msg, 10)
					else
						local msg
						if count > 1 then
							msg = "Already loaded "..count.." supplies"
						else
							msg = "Supplies already loaded"
						end
						trigger.action.outTextForGroup(gr:getID(), msg, 10)
					end
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
							self.carriedCargo[gr:getID()] = { source = carrierUnit:getName(), count = loadCount }
							trigger.action.setUnitInternalCargo(un:getName(), 100 * loadCount)
							local msg
							if loadCount > 1 then
								msg = loadCount.. " Supplies loaded"
							else
								msg = "Supplies loaded"
							end
							trigger.action.outTextForGroup(gr:getID(), msg, 20)
							return
						end
					else
						local group = GROUP:FindByName(groupName)
						if group then
							for _, zName in ipairs(self.supplyZones) do
								if string.find(zName, "CTLD FARP") or string.find(zName, "Escort Mission FARP") then
									local zObj = ZONE:FindByName(zName)
									if zObj and group:IsInZone(zObj) then
										self.carriedCargo[gr:getID()] = { source = zName, count = loadCount }
										trigger.action.setUnitInternalCargo(un:getName(), 100 * loadCount)
										local msg
										if loadCount > 1 then
											msg = loadCount.." supplies loaded"
										else
											msg = "Supplies loaded"
										end
										trigger.action.outTextForGroup(gr:getID(), msg, 20)
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
				for i, v in ipairs(self.supplyZones) do
					if v == zn.zone then
						self.carriedCargo[gr:getID()] = { source = zn.zone, count = loadCount }
						trigger.action.setUnitInternalCargo(un:getName(), 100 * loadCount)
						local msg
						if loadCount > 1 then
							msg = loadCount.." supplies loaded"
						else
							msg = "Supplies loaded"
						end
						trigger.action.outTextForGroup(gr:getID(), msg, 20)
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
				local playerName = un:getPlayerName()
				if Utils.isInAir(un) then
					trigger.action.outTextForGroup(gr:getID(), 'Can not unload supplies while in air', 10)
					return
				end

				local cargoData = self.carriedCargo[gr:getID()]
				if not cargoData then
					trigger.action.outTextForGroup(gr:getID(),'No supplies loaded',10)
					return
				end

				local originalSource = type(cargoData) == "table" and cargoData.source or cargoData
				local totalDrops = type(cargoData) == "table" and cargoData.count or 1
				if not totalDrops or totalDrops < 1 then
					totalDrops = 1
				end
				local remainingDrops = totalDrops
				local didLandingEvent = false
				local didAnnounce = false

				local function handleZoneRewards(zone)
					if not zone then
						return false
					end
					if originalSource == zone.zone then
						return false
					end
					if zone.side == 0 and zone.active then
						if self.battleCommander.playerRewardsOn then
							if playerName and bc.playerContributions[2][playerName] ~= nil then
								bc:addContribution(playerName, 2, self.battleCommander.rewards.crate)
								self.battleCommander:addTempStat(playerName, 'Zone capture', 1)
								--trigger.action.outTextForCoalition(un:getCoalition(),'['..playerName..'] Capture +'..self.battleCommander.rewards.crate..' credits',10)
							else
								self.battleCommander:addFunds(un:getCoalition(), self.battleCommander.rewards.crate)
								trigger.action.outTextForCoalition(un:getCoalition(),'Capture +'..self.battleCommander.rewards.crate..' credits',10)
							end
						end
						zone:capture(un:getCoalition())
						return true
					elseif zone.side == un:getCoalition() then
						if self.battleCommander.playerRewardsOn then
							if zone:canRecieveSupply() then
								if playerName and bc.playerContributions[2][playerName] ~= nil then
									bc:addContribution(playerName, 2, self.battleCommander.rewards.crate)
									self.battleCommander:addTempStat(playerName, 'Zone upgrade', 1)
									--trigger.action.outTextForCoalition(un:getCoalition(),'['..playerName..'] Resupply +'..self.battleCommander.rewards.crate..' credits',5)
								else
									self.battleCommander:addFunds(un:getCoalition(), self.battleCommander.rewards.crate)
									trigger.action.outTextForCoalition(un:getCoalition(),'Resupply +'..self.battleCommander.rewards.crate..' credits',5)
								end
							else
								local reward = self.battleCommander.rewards.crate * 0.25
								if playerName and bc.playerContributions[2][playerName] ~= nil then
									bc:addContribution(playerName, 2, reward)
									self.battleCommander:addTempStat(playerName, 'Zone upgrade', 1)
									trigger.action.outTextForCoalition(un:getCoalition(),'['..playerName..'] Resupply +'..reward..' credits (-75% due to no demand)',5)
								else
									self.battleCommander:addFunds(un:getCoalition(), reward)
									trigger.action.outTextForCoalition(un:getCoalition(),'Resupply +'..reward..' credits (-75% due to no demand)',5)
								end
							end
						end
						zone:upgrade()
						return true
					end
					return false
				end

				local function performDrop(zone)
					if remainingDrops <= 0 then
						return
					end
					if not didAnnounce then
						local msg = totalDrops > 1 and ("Unloaded "..totalDrops.." supplies") or "Supplies unloaded"
						trigger.action.outTextForGroup(gr:getID(), msg, 10)
						didAnnounce = true
					end
					self.carriedCargo[gr:getID()] = nil
					trigger.action.setUnitInternalCargo(un:getName(), 0)
					local wasNeutral = zone and zone.side == 0 and zone.active
					local changed = handleZoneRewards(zone)
					if zone and totalDrops > 1 and (wasNeutral or zone.side == un:getCoalition()) then
						SCHEDULER:New(nil,function()
							local z2 = self.battleCommander:getZoneOfUnit(un:getName()) or zone
							handleZoneRewards(z2)
						end,{},3,0)
					end
					if changed and not didLandingEvent then
						SCHEDULER:New(nil,function()
							if zone and zone.wasBlue and un:isExist() then
								local landingEvent = {
									id = world.event.S_EVENT_LAND,
									time = timer.getAbsTime(),
									initiator = un,
									initiatorPilotName = un:getPlayerName(),
									initiator_unit_type = un:getTypeName(),
									initiator_coalition = un:getCoalition(),
									skipRewardMsg = true,
								}
								world.onEvent(landingEvent)
							end
						end,{},5,0)
						didLandingEvent = true
					end
					remainingDrops = 0
				end


				local function scheduleAdditionalDrops(initialZone)
					if remainingDrops <= 0 then
						return
					end
					SCHEDULER:New(nil,function()
						if not un:isExist() then
							remainingDrops = 0
							return
						end
						if not self.carriedCargo[gr:getID()] then
							remainingDrops = 0
							trigger.action.setUnitInternalCargo(un:getName(),0)
							return
						end
						local followZone = self.battleCommander:getZoneOfUnit(un:getName()) or initialZone
						performDrop(followZone)
						didLandingEvent = false
						return
					end,{},1,0)
				end

				local zn = self.battleCommander:getZoneOfUnit(un:getName())
				if not zn then
					local carrierName = GetNearestCarrierName(COORDINATE:NewFromVec3(un:getPoint()))
					if carrierName then
						performDrop(nil)
						scheduleAdditionalDrops(nil)
						return
					end

					local group = GROUP:FindByName(groupName)
					if group then
						for _, zName in ipairs(self.supplyZones) do
							if string.find(zName, "CTLD FARP") or string.find(zName, "Escort Mission FARP") then
								local zObj = ZONE:FindByName(zName)
								if zObj and group:IsInZone(zObj) then
									performDrop(nil)
									scheduleAdditionalDrops(nil)

									return
								end
							end
						end
					end

					trigger.action.outTextForGroup(gr:getID(),'Can only unload supplies while within a friendly or neutral zone',10)
					env.info('LogisticCommander:unloadSupplies - no zone found for unit '..un:getName())
					return
				end
				if not(zn.side == un:getCoalition() or zn.side == 0)then
					trigger.action.outTextForGroup(gr:getID(),'Can only unload supplies while within a friendly or neutral zone',10)
					env.info('LogisticCommander:unloadSupplies - wrong side for unit '..un:getName()..' in zone '..zn.zone)
					return
				end
				if originalSource == zn.zone then
					self.carriedCargo[gr:getID()] = nil
					trigger.action.setUnitInternalCargo(un:getName(), 0)
					local msg = totalDrops > 1 and ("Unloaded "..totalDrops.." supplies") or "Supplies unloaded"
					trigger.action.outTextForGroup(gr:getID(), msg, 10)
					return
				end
				scheduleAdditionalDrops(zn)
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
			local unitType=un:getTypeName()
			local maxCarriedPilots = LogisticCommander.AllowedCsar[unitType]
			if self.carriedPilots[groupid]>=maxCarriedPilots then
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
					trigger.action.outTextForGroup(groupid,"Pilot onboard ["..self.carriedPilots[groupid].."/"..maxCarriedPilots.."]",15)
					return
				end
			end
			trigger.action.outTextForGroup(groupid,"No ejected pilots nearby",15)
		end
	end

	function LogisticCommander:unloadPilot(groupname)
			local gr=Group.getByName(groupname)
			if gr then
				local groupid=gr:getID()
				local un=gr:getUnit(1)
				if (self.carriedPilots[groupid] or 0)==0 then
					trigger.action.outTextForGroup(groupid,"No one onboard",15)
					return
				end
--[[ 				if Utils.isInAir(un) then
					trigger.action.outTextForGroup(groupid,"Can not drop off pilots while in air",15)
					return
				end ]]
				local playerName=un:getPlayerName()
					local count=self.carriedPilots[groupid] or 0
					trigger.action.outTextForGroup(groupid,"Pilots dropped off",15)
					if self.battleCommander.playerRewardsOn then
						local rescuedPlayers=self.carriedPilotData[groupid] or {}
						local dropped={}
						for _,pilotData in ipairs(rescuedPlayers) do
							local pname=pilotData and pilotData.player
							if pname and pname~='' then
								self.battleCommander:addStat(pname,'Deaths',-1)
								dropped[#dropped+1]=pname
							end
						end
						if #dropped>0 then
							trigger.action.outTextForCoalition(un:getCoalition(),"["..playerName.."] dropped off "..table.concat(dropped,", ")..".",5)
						end
					end
					self.carriedPilotData[groupid]=nil
					self.carriedPilots[groupid]=0
					trigger.action.setUnitInternalCargo(un:getName(),0)
				return
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
	
	function LogisticCommander:printPilotInfo(pilotObj,groupid,referenceUnit,duration,short)
		self.csarBeaconFreq = self.csarBeaconFreq or {}
		self.csarPilotDataByObject = self.csarPilotDataByObject or {}
		if not pilotObj or not pilotObj:isExist() then return end
		local pnt=pilotObj:getPoint() or nil
		if not pnt then return end
		local objectID=pilotObj:getObjectID()
		local pilotData=landedPilotOwners[objectID] or self.csarPilotDataByObject[objectID] or ejectedPilotOwners[objectID]
		local freq=self.csarBeaconFreq[objectID]
		local c=COORDINATE:NewFromVec3(pnt)

			if short then
			local pilotName = (pilotData and pilotData.player and pilotData.player~='') and ('['..pilotData.player..']') or 'Downed pilot'
			local plural = false
			if self.ejectedPilots then
				for _, other in ipairs(self.ejectedPilots) do
					if other and other:isExist() and other ~= pilotObj then
						local op = other:getPoint()
						if op then
							local dx = op.x - pnt.x
							local dz = op.z - pnt.z
							if (dx*dx + dz*dz) <= (92*92) then
								plural = true
								break
							end
						end
					end
				end
			end
			local toprint=pilotName..(plural and '  We hear you! Request smoke if needed.' or '  I hear you! Request smoke if needed.')
			if freq and freq>0 then
				toprint = toprint .. '\n\nADF: ' .. string.format('%.0f',freq/1000) .. ' kHz'
			end
			if referenceUnit then
				local dist=UTILS.VecDist3D(referenceUnit:getPoint(),pilotObj:getPoint())
				local dstkm=string.format('%.2f',dist/1000)
				local dstnm=string.format('%.2f',dist/1852)
				toprint=toprint..'\n\nDist: '..dstkm..'km | '..dstnm..'nm'
				local brg=COORDINATE:NewFromVec3(referenceUnit:getPoint()):HeadingTo(c)
				toprint=toprint..'\nBearing: '..math.floor(brg)
			end
			trigger.action.outTextForGroup(groupid,toprint,duration)
			return
		end


		local toprint='Pilot in need of extraction:'
		if (pilotData and pilotData.player) then		

			toprint = toprint .. '\n\n[' .. pilotData.player .. '] '
			toprint = toprint .. ' Lost: ' .. pilotData.lostCredits .. ' Credits'
			toprint = toprint .. '\n\nSave the pilot to retrive the lost credits'
		end
		if freq and freq>0 then
			toprint = toprint .. '\n\nADF: ' .. string.format('%.0f',freq/1000) .. ' kHz'
		end
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
		self.csarBeaconName = self.csarBeaconName or {}
		self.csarBeaconFreq = self.csarBeaconFreq or {}
		self.csarBeaconNext = self.csarBeaconNext or {}
		self.csarAssignedGroup = self.csarAssignedGroup or {}
		self.csarRouteIssued = self.csarRouteIssued or {}
		self.csarPilotDataByObject = self.csarPilotDataByObject or {}
		self.csarHoverStatus = self.csarHoverStatus or {}
		self.csarNearStatus = self.csarNearStatus or {}
		local tocleanup = {}
		self.ejectedPilotsState = self.ejectedPilotsState or {}
		for i = #self.ejectedPilotsState, 1, -1 do
			self.ejectedPilotsState[i] = nil
		end

		for i, v in ipairs(self.ejectedPilots) do
			if v and v:isExist() then
				local keep = true
				if v.getLife and v:getLife() <= 0 then
					table.insert(tocleanup, { index = i, kia = true })
					keep = false
				end
				if keep then
					local ejectedPilotTable = {
						playerName = "Unknown",
						lostCredits = 0
					}
					local objectID = v:getObjectID()
					local pilotData = (landedPilotOwners and landedPilotOwners[objectID]) or self.csarPilotDataByObject[objectID] or (ejectedPilotOwners and ejectedPilotOwners[objectID])
					if pilotData then
						ejectedPilotTable.playerName = pilotData.player or "Unknown"
						ejectedPilotTable.lostCredits = pilotData.lostCredits or 0
					end
					local point = v:getPoint()
					if point then
						ejectedPilotTable.latitude, ejectedPilotTable.longitude, ejectedPilotTable.altitude = coord.LOtoLL(point)
					end
					table.insert(self.ejectedPilotsState, ejectedPilotTable)
				end
			else
				table.insert(tocleanup, { index = i, kia = true })
			end
		end

		local function boardPilot(pilotObj, heliUnit, groupid, fromScheduler)
			local pid = pilotObj:getObjectID()
			local pilotData = landedPilotOwners[pid] or self.csarPilotDataByObject[pid] or ejectedPilotOwners[pid]
			local current = self.carriedPilots[groupid] or 0
			local unitType = heliUnit:getTypeName()
			local maxCarriedPilots = LogisticCommander.AllowedCsar[unitType]

			if Utils.isInAir(heliUnit) then
				local pp = pilotObj:getPoint()
				local hp = heliUnit:getPoint()
				local dx = hp.x - pp.x
				local dz = hp.z - pp.z
				local hoverDist = LogisticCommander.csarHoverDistance or 10
				if (dx*dx + dz*dz) <= (hoverDist*hoverDist) then
					local agl = Utils.getAGL(heliUnit)
					if agl <= (LogisticCommander.csarHoverHeight or 20) and UTILS.VecNorm(heliUnit:getVelocity()) <= 5 then
						self.csarHoverStatus = self.csarHoverStatus or {}
						local st = self.csarHoverStatus[pid]
						if not st then
							st = {}
							self.csarHoverStatus[pid] = st
						end
						local now = timer.getTime()
						local deadline = st[groupid]
						if not deadline then
							deadline = now + (LogisticCommander.csarHoverSeconds or 10)
							st[groupid] = deadline
							if not st["sched_"..groupid] then
								st["sched_"..groupid] = true
								timer.scheduleFunction(function()
									if not self.csarHoverStatus or not self.csarHoverStatus[pid] or not self.csarHoverStatus[pid][groupid] then
										st["sched_"..groupid] = nil
										return
									end
									if boardPilot(pilotObj, heliUnit, groupid, true) then
										st["sched_"..groupid] = nil
										return
									end
									if not self.csarHoverStatus or not self.csarHoverStatus[pid] or not self.csarHoverStatus[pid][groupid] then
										st["sched_"..groupid] = nil
										return
									end
									return timer.getTime() + 2
								end, {}, now + 0.1)
							end
						end
						local remaining = math.floor((deadline - now) + 0.999)
						if remaining > 0 then
							if fromScheduler then
								local pilotName = (pilotData and pilotData.player and pilotData.player~='') and pilotData.player or "Downed pilot"
								trigger.action.outTextForGroup(groupid, "Picking up " .. pilotName .. ". Hold hover for " .. remaining .. "s.", 1)
							end
							return false
						end
						st[groupid] = nil
					else
						if self.csarHoverStatus and self.csarHoverStatus[pid] then
							self.csarHoverStatus[pid][groupid] = nil
						end
						return false
					end
				else
					if self.csarHoverStatus and self.csarHoverStatus[pid] then
						self.csarHoverStatus[pid][groupid] = nil
					end
					return false
				end
			else
				if self.csarHoverStatus and self.csarHoverStatus[pid] then
					self.csarHoverStatus[pid][groupid] = nil
				end
			end

			if current >= maxCarriedPilots then
				trigger.action.outTextForGroup(groupid, "At max capacity", 8)
				return false
			end
			self.carriedPilots[groupid] = current + 1
			self.carriedPilotData[groupid] = self.carriedPilotData[groupid] or {}
			if pilotData then table.insert(self.carriedPilotData[groupid], pilotData) end
			landedPilotOwners[pid] = nil
			self.csarPilotDataByObject[pid] = nil
			ejectedPilotOwners[pid] = nil
			self.csarNextTick[pid] = nil
			self.csarHoverStatus[pid] = nil
			trigger.action.setUnitInternalCargo(heliUnit:getName(), (self.carriedPilots[groupid] or 0) * (LogisticCommander.PilotWeight or 80))
			local playerName = heliUnit:getPlayerName()
			local pickupReward=0
			if self.battleCommander.playerRewardsOn and playerName and bc.playerContributions[2][playerName] ~= nil then
				local restoreAmount = (pilotData and pilotData.lostCredits) or 0
				local totalReward = (self.battleCommander.rewards.rescue or 0) + restoreAmount
				if totalReward>0 then
					bc:addContribution(playerName, 2, totalReward)
					self.battleCommander:addTempStat(playerName,'Pilot Rescue',1)
					pickupReward=totalReward
					if pilotData then
						pilotData.rescueRewardPaid=true
						pilotData.rescueRewardPaidAmount=totalReward
						pilotData.lostCredits=0
					end
				end
			end
			if playerName then
				local pilotName = (pilotData and pilotData.player and pilotData.player~='') and pilotData.player or "Downed pilot"
				if pickupReward>0 then
					trigger.action.outTextForCoalition(heliUnit:getCoalition(),"["..playerName.."] rescued ["..pilotName.."] +"..pickupReward.." credits. Land at any friendly zone to drop off.",10)
				else
					trigger.action.outTextForCoalition(heliUnit:getCoalition(),"["..playerName.."] rescued ["..pilotName.."]. Land at any friendly zone to drop off.",10)
				end
			end
			if fromScheduler then
				for j = #self.ejectedPilots, 1, -1 do
					local p = self.ejectedPilots[j]
					if p and p:getObjectID() == pid then
						table.remove(self.ejectedPilots, j)
						break
					end
				end
			end

			pilotObj:destroy()
			trigger.action.outTextForGroup(groupid, "Pilot onboard ["..self.carriedPilots[groupid].."/"..maxCarriedPilots.."]", 10)
			self.csarAssignedGroup[pid] = nil
			self.csarRouteIssued[pid] = nil
			self.csarVisibleMsg[pid] = nil
			self.csarCloseMsg[pid] = nil
			self.csarRunEta[pid] = nil

			return true

		end

		local function refreshPilotBeacon(pid, pilotObj)
			local bname = self.csarBeaconName[pid]
			local freq = self.csarBeaconFreq[pid]
			if not bname then
				bname = "FOOTHOLD_CSAR_"..pid.."_BEACON"
				freq = 250000 + math.random(0,1000)*1000
				self.csarBeaconName[pid] = bname
				self.csarBeaconFreq[pid] = freq
				self.csarBeaconNext[pid] = 0
			end
			local nextT = self.csarBeaconNext[pid] or 0
			local t = timer.getTime()
			if t >= nextT then
				trigger.action.stopRadioTransmission(bname)
				trigger.action.radioTransmission("l10n/DEFAULT/beacon.ogg", pilotObj:getPoint(), 0, true, freq, 1000, bname)
				self.csarBeaconNext[pid] = t + 25
			end
		end

		local function runPilotToHelo(pilotObj, heliUnit)
			local grp = GROUP:FindByName(pilotObj:getGroup():getName())
			grp:SetAIOn()
			grp:OptionAlarmStateGreen()
			local dest = heliUnit:getPoint()
			grp:RouteToVec2({ x = dest.x, y = dest.z },5)
			env.info("CSAR: RouteToVec2 "..grp:GetName().." -> "..heliUnit:getName())
		end

		local function approachMessage(pid, heliUnit, pilotObj)
			local gid = heliUnit:getGroup():getID()
			local shown = self.csarVisibleMsg[pid]
			if not shown then
				shown = {}
				self.csarVisibleMsg[pid] = shown
			end
			if not shown[gid] then
				self.csarApproachClusterMsg = self.csarApproachClusterMsg or {}
				local now = timer.getTime()
				local p = pilotObj:getPoint()
				local cluster = self.csarApproachClusterMsg[gid]
				if cluster and (now - cluster.t) < 20 and p then
					local dx = p.x - cluster.x
					local dz = p.z - cluster.z
					if (dx*dx + dz*dz) <= (92*92) then
						shown[gid] = true
						return
					end
				end
				if p then
					self.csarApproachClusterMsg[gid] = { t = now, x = p.x, z = p.z }
				end
				self:printPilotInfo(pilotObj, gid, heliUnit, 15, true)
				shown[gid] = true
			end
		end

		local function closeMessage(pid, heliUnit, pilotObj)
			local gid = heliUnit:getGroup():getID()
			local shown = self.csarCloseMsg[pid]
			if not shown then
				shown = {}
				self.csarCloseMsg[pid] = shown
			end
			if not shown[gid] then
				self.csarCloseClusterMsg = self.csarCloseClusterMsg or {}
				local now = timer.getTime()
				local p = pilotObj:getPoint()
				local cluster = self.csarCloseClusterMsg[gid]
				if cluster and (now - cluster.t) < 20 and p then
					local dx = p.x - cluster.x
					local dz = p.z - cluster.z
					if (dx*dx + dz*dz) <= (92*92) then
						shown[gid] = true
						return
					end
				end
				if p then
					self.csarCloseClusterMsg[gid] = { t = now, x = p.x, z = p.z }
				end
				local msg = "You're close now! Land in a safe place, we will come to you."
				local hp = heliUnit:getPoint()
				if hp and p then
					local bearing = math.deg(math.atan2(p.z - hp.z, p.x - hp.x))
					if bearing < 0 then bearing = bearing + 360 end
					local pos = heliUnit:getPosition()
					local heading = math.deg(math.atan2(pos.x.z, pos.x.x))
					if heading < 0 then heading = heading + 360 end
					local rel = bearing - heading
					rel = rel % 360
					local clock = math.floor((rel + 15) / 30)
					if clock == 0 then clock = 12 end
					msg = "You're close now! I'm at your " .. clock .. " o'clock. Land in a safe place, we will come to you."
				end
				trigger.action.outTextForGroup(gid, msg, 10)
				shown[gid] = true
			end
		end


		-- iterate helos vs pilots
		local now = timer.getTime()
		for i, pilotObj in ipairs(self.ejectedPilots) do
			if pilotObj and pilotObj:isExist() then
				local pid = pilotObj:getObjectID()
				refreshPilotBeacon(pid, pilotObj)
				local pilotPoint = pilotObj:getPoint()

				-- collect candidate player helos via Moose SET_GROUP (mirroring CSAR) and drop stale hulks with no player
				local candidates = {}
				local seen = {}
				local function addUnit(un)
					if not un or not un:isExist() then return end
					if not un:getPlayerName() then return end -- ignore empty or ejected hulks
					local g = un:getGroup()
					if not g then return end
					local gid = g:getID()
					if seen[gid] then return end
					if not self.csarGroupMenus[gid] then return end
					seen[gid] = true
					candidates[#candidates+1] = { unit = un, groupid = gid }
				end

			local heliSet = self.csarSet
			if heliSet and heliSet.ForEachGroupAlive then
				heliSet:ForEachGroupAlive(function(mooseGroup)
					local gidObj = mooseGroup and mooseGroup:GetDCSObject()
					local gid = gidObj and gidObj:getID()
					local unitWrapper = mooseGroup and mooseGroup:GetUnit(1)
					local unitRef = unitWrapper and unitWrapper:GetDCSObject()
					if unitRef and unitRef:isExist() and unitRef:getPlayerName() and self.allowedTypes[unitRef:getTypeName()] then
						local gname = mooseGroup:GetName()
						if gid then self.csarGroups[gid] = { name = gname, player = unitRef:getPlayerName() } end
						addUnit(unitRef)
					elseif gid then
						self.csarGroups[gid] = nil
					end
				end)
			else
				for gid, entry in pairs(self.csarGroups) do
					local gname = (entry and entry.name) or (self.groupIdToName and self.groupIdToName[gid])
					local gr = gname and Group.getByName(gname) or nil
					local unitRef = gr and gr:getUnit(1) or nil
					if unitRef and unitRef:isExist() and unitRef:getPlayerName() and self.allowedTypes[unitRef:getTypeName()] then
						entry.name = gname
						entry.player = unitRef:getPlayerName()
						addUnit(unitRef)
					else
						self.csarGroups[gid] = nil
					end
				end
			end

				local assignedGroupid = self.csarAssignedGroup[pid]
				if assignedGroupid then
					local assignedFound = false
					for _, entry in ipairs(candidates) do
						if entry.groupid == assignedGroupid then
							assignedFound = true
							break
						end
					end
					if not assignedFound then
						self.csarAssignedGroup[pid] = nil
						assignedGroupid = nil
					end
				end
				local anyNear = false
				local bestNextTick = now + 10
				for _, entry in ipairs(candidates) do
					local un = entry.unit
					local groupid = entry.groupid
					if not assignedGroupid or groupid == assignedGroupid then
						local dist = UTILS.VecDist3D(un:getPoint(), pilotPoint)

						if dist < 2500 then
							if not self.csarNearStatus[pid] then
								self.csarNearStatus[pid] = true
								timer.scheduleFunction(function()
									if not self.csarNearStatus or not self.csarNearStatus[pid] then return end
									if not pilotObj or not pilotObj:isExist() then
										self.csarNearStatus[pid] = nil
										return
									end
									local pilotPointFast = pilotObj:getPoint()
									local candidatesFast = {}
									local seenFast = {}
									local function addUnitFast(unFast)
										if not unFast or not unFast:isExist() then return end
										if not unFast:getPlayerName() then return end
										local gFast = unFast:getGroup()
										if not gFast then return end
										local gidFast = gFast:getID()
										if seenFast[gidFast] then return end
										if not self.csarGroupMenus[gidFast] then return end
										seenFast[gidFast] = true
										candidatesFast[#candidatesFast+1] = { unit = unFast, groupid = gidFast }
									end

									local heliSetFast = self.csarSet
									if heliSetFast and heliSetFast.ForEachGroupAlive then
										heliSetFast:ForEachGroupAlive(function(mooseGroup)
											local unitWrapper = mooseGroup and mooseGroup:GetUnit(1)
											local unitRef = unitWrapper and unitWrapper:GetDCSObject()
											if unitRef and unitRef:isExist() and unitRef:getPlayerName() and self.allowedTypes[unitRef:getTypeName()] then
												addUnitFast(unitRef)
											end
										end)
									else
										for gid, entry in pairs(self.csarGroups) do
											local gname = (entry and entry.name) or (self.groupIdToName and self.groupIdToName[gid])
											local gr = gname and Group.getByName(gname) or nil
											local unitRef = gr and gr:getUnit(1) or nil
											if unitRef and unitRef:isExist() and unitRef:getPlayerName() and self.allowedTypes[unitRef:getTypeName()] then
												addUnitFast(unitRef)
											end
										end
									end

									local anyCloseFast = false
									for _, entryFast in ipairs(candidatesFast) do
										local unFast = entryFast.unit
										local groupidFast = entryFast.groupid
										local distFast = UTILS.VecDist3D(unFast:getPoint(), pilotPointFast)

										if distFast < 2500 then
											anyCloseFast = true
										end

										if distFast < self.csarApproachNear then
											approachMessage(pid, unFast, pilotObj)
										end
										if distFast < self.csarExtractDistance then
											closeMessage(pid, unFast, pilotObj)
										end
										if not Utils.isInAir(unFast) and distFast < self.csarExtractDistance then
											if not self.csarAssignedGroup[pid] then
												self.csarAssignedGroup[pid] = groupidFast
											end
											local runEta = self.csarRunEta[pid]
											if not runEta then
												runEta = {}
												self.csarRunEta[pid] = runEta
											end
											if not runEta[groupidFast] then
												local pilotData = landedPilotOwners[pid] or self.csarPilotDataByObject[pid] or ejectedPilotOwners[pid]
												local pilotName = (pilotData and pilotData.player and pilotData.player~='') and pilotData.player or "Downed pilot"
												local eta = math.floor((distFast - self.csarLoadDistance) / 3.6)
												if eta < 0 then eta = 0 end
												runEta[groupidFast] = eta
												trigger.action.outTextForGroup(groupidFast, pilotName..": I\'m coming to you.\nETA "..eta.." seconds.", 10)
											end
											if self.csarRouteIssued[pid] ~= groupidFast then
												self.csarRouteIssued[pid] = groupidFast
												runPilotToHelo(pilotObj, unFast)
											end
										end

										if distFast < self.csarLoadDistance then
											if boardPilot(pilotObj, unFast, groupidFast) then
												for j = #self.ejectedPilots, 1, -1 do
													if self.ejectedPilots[j] == pilotObj then
														table.remove(self.ejectedPilots, j)
														break
													end
												end
												self.csarNearStatus[pid] = nil
												self.csarNextTick[pid] = nil
												return
											end
										elseif Utils.isInAir(unFast) and distFast < ((LogisticCommander.csarHoverDistance or 10) + (LogisticCommander.csarHoverHeight or 20)) then
											if boardPilot(pilotObj, unFast, groupidFast) then
												for j = #self.ejectedPilots, 1, -1 do
													if self.ejectedPilots[j] == pilotObj then
														table.remove(self.ejectedPilots, j)
														break
													end
												end
												self.csarNearStatus[pid] = nil
												self.csarNextTick[pid] = nil
												return
											end
										end
									end

									if not anyCloseFast then
										self.csarNearStatus[pid] = nil
										return
									end

									return timer.getTime() + 3
								end, {}, timer.getTime() + 3)
							end
						end

						if assignedGroupid and (Utils.isInAir(un) or dist > self.csarExtractDistance) then
							self.csarAssignedGroup[pid] = nil
							self.csarRouteIssued[pid] = nil
							assignedGroupid = nil
						end

						local skip = false
						if dist < self.csarApproachNear then
							anyNear = true
						end
						if dist >= self.csarApproachNear then
							local nextAllowed = self.csarNextTick[pid] or 0
							if now < nextAllowed then
								skip = true
							end
						end
						if not skip then
							if dist < self.csarApproachNear then
								approachMessage(pid, un, pilotObj)
							end							
							if dist < self.csarExtractDistance then
								closeMessage(pid, un, pilotObj)
							end
							if not Utils.isInAir(un) and dist < self.csarExtractDistance then
								if not assignedGroupid then
									self.csarAssignedGroup[pid] = groupid
									assignedGroupid = groupid
								end
								local runEta = self.csarRunEta[pid]
								if not runEta then
									runEta = {}
									self.csarRunEta[pid] = runEta
								end
								if not runEta[groupid] then
									local pilotData = landedPilotOwners[pid] or self.csarPilotDataByObject[pid] or ejectedPilotOwners[pid]
									local pilotName = (pilotData and pilotData.player and pilotData.player~='') and pilotData.player or "Downed pilot"
									local eta = math.floor((dist - self.csarLoadDistance) / 3.6)
									if eta < 0 then eta = 0 end
									runEta[groupid] = eta
									trigger.action.outTextForGroup(groupid, pilotName..": I\'m coming to you.\nETA "..eta.." seconds.", 10)
								end
								if self.csarRouteIssued[pid] ~= groupid then
									self.csarRouteIssued[pid] = groupid
									runPilotToHelo(pilotObj, un)
								end
							end
							if dist < self.csarLoadDistance then
								if boardPilot(pilotObj, un, groupid) then
									self.csarNextTick[pid] = nil
									table.remove(self.ejectedPilots, i)
									return
								end
							elseif Utils.isInAir(un) and dist < ((LogisticCommander.csarHoverDistance or 10) + (LogisticCommander.csarHoverHeight or 20)) then
								if boardPilot(pilotObj, un, groupid) then
									self.csarNextTick[pid] = nil
									table.remove(self.ejectedPilots, i)
									return
								end
							end
							local candidateNextTick
							if dist < self.csarLoadDistance then
								candidateNextTick = now + 1
							elseif Utils.isInAir(un) and dist < ((LogisticCommander.csarHoverDistance or 10) + (LogisticCommander.csarHoverHeight or 20)) then
								candidateNextTick = now + 1
							elseif dist < self.csarExtractDistance then
								candidateNextTick = now + 3
							elseif dist >= self.csarApproachNear then
								candidateNextTick = now + 10
							else
								candidateNextTick = now + 5
							end
							if candidateNextTick < bestNextTick then
								bestNextTick = candidateNextTick
							end
						end
					end
				end
				self.csarNextTick[pid] = bestNextTick
				if not anyNear then
					self.csarVisibleMsg[pid] = nil
					self.csarCloseMsg[pid] = nil
					self.csarRunEta[pid] = nil
				end
			end
		end

		for i = #tocleanup, 1, -1 do
			local entry = tocleanup[i]
			local index = entry.index
			local pilot = self.ejectedPilots[index]

			if entry.kia then
				local pid = pilot and pilot:isExist() and pilot:getObjectID() or nil
				local pilotData = pid and (landedPilotOwners[pid] or self.csarPilotDataByObject[pid] or ejectedPilotOwners[pid]) or nil
				local pname = pilotData and pilotData.player
				local coal = pilotData and pilotData.coalition or 2
				local msg
				if pname and pname~='' then
					msg = "["..pname.."] is KIA."
				else
					msg = "Downed pilot is KIA."
				end
				for groupid in pairs(self.csarGroupMenus) do
					trigger.action.outTextForGroup(groupid,msg,10)
				end
				if pid then
					landedPilotOwners[pid]=nil
					self.csarPilotDataByObject[pid]=nil
					ejectedPilotOwners[pid]=nil
					self.csarAssignedGroup[pid]=nil
					self.csarRouteIssued[pid]=nil
					self.csarNextTick[pid]=nil
					self.csarVisibleMsg[pid]=nil
					self.csarCloseMsg[pid]=nil
					self.csarRunEta[pid]=nil
					self.csarSmokeTick[pid]=nil
					local bname = self.csarBeaconName[pid]
					if bname then trigger.action.stopRadioTransmission(bname) end
					self.csarBeaconName[pid]=nil
					self.csarBeaconFreq[pid]=nil
					self.csarBeaconNext[pid]=nil
				end
				if pilot and pilot:isExist() then
					pilot:destroy()
				end
			end
			table.remove(self.ejectedPilots, index)
		end
	end

playerZoneSpawn = playerZoneSpawn or {}

function LogisticCommander:init()
	local ev = {}
    ev.context = self
    function ev:onEvent(event)
		if event.id == 15 and event.initiator and event.initiator.getPlayerName then
            local player = event.initiator:getPlayerName()
            if player then
					local plist = net.get_player_list()
					local un = event.initiator
					local zn = BattleCommander:getZoneOfUnit(un:getName())
					local gr = un:getGroup()
					local groupId = gr:getID()
					local unitCat = Unit.getCategoryEx(un)
					local hasIllegalName = player:find("[\'/\\]")

					if hasIllegalName then
						for i, v in pairs(plist) do
							if net.get_name(v) == player then
								net.send_chat_to("Your name contains illegal characters ( ' / \\ ). Please remove them and rejoin.", v)
								timer.scheduleFunction(function(param, time)
									net.force_player_slot(param, 0, '')
								end, v, timer.getTime() + 0.1)
								break
							end
						end
						if event.initiator and event.initiator:isExist() then
							event.initiator:destroy()
						end
						return
					end
				if  Object.getCategory(un) == Object.Category.UNIT and
					(unitCat == Unit.Category.AIRPLANE or unitCat == Unit.Category.HELICOPTER) then
					if zn then
						local isDifferentSide = zn.side ~= un:getCoalition()
						
						if isDifferentSide and not zn.wasBlue and not zn.isHidden then
							for i, v in pairs(plist) do
								if net.get_name(v) == player then
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
							return
						else
							if handleMission and unitCat == Unit.Category.HELICOPTER then
								timer.scheduleFunction(function()
									if gr and gr:isExist() then
										handleMission(zn.zone, gr:getName(), gr:getID(), gr)
									end
								end, {}, timer.getTime() + 30)
							end
							if unitCat == Unit.Category.AIRPLANE then
								if capMissionTarget ~= nil and capKillsByPlayer[player] then
									capKillsByPlayer[player] = 0
								end
							if un:getTypeName() ~= "A-10C_2" and un:getTypeName() ~= "Hercules" and un:getTypeName() ~= "A-10A" and un:getTypeName() ~= "AV8BNA"
							and un:getTypeName() ~= "C-130J-30" then
									playerZoneSpawn[player] = zn.zone
								end
							end
							if casMissionTarget ~= nil and casKillsByPlayer[player] then casKillsByPlayer[player] = 0 end
						end
					else
						zn=getEscortFarpZoneOfUnit(un:getName())
						if zn then
							if handleMission and unitCat == Unit.Category.HELICOPTER then
								if gr and gr:isExist() then
										timer.scheduleFunction(function()
										handleMission(zn.zone, gr:getName(), gr:getID(), gr)
									end, {}, timer.getTime() + 30)
								end
							end
						end
					end
				end

				RankSave = RankSave or {players={},version=1}
				RankSave.players = RankSave.players or {}
				RankSave.ucidToName = RankSave.ucidToName or {}
				local ucid = nil
				for i = 1, #plist do
					local pid = plist[i]
					if net.get_name(pid) == player then
						ucid = net.get_player_info(pid, 'ucid')
						break
					end
				end

				if ucid and ucid ~= "" then
					local oldName = RankSave.ucidToName[ucid]
					if oldName and oldName ~= player then
						if RankSave.players[oldName] and not RankSave.players[player] then
							RankSave.players[player] = RankSave.players[oldName]
							RankSave.players[oldName] = nil
						end
						if self.context.battleCommander.playerStats and self.context.battleCommander.playerStats[oldName] and not self.context.battleCommander.playerStats[player] then
							self.context.battleCommander.playerStats[player] = self.context.battleCommander.playerStats[oldName]
							self.context.battleCommander.playerStats[oldName] = nil
						end
					end
					RankSave.ucidToName[ucid] = player
				end
                local groupObj = gr
                local groupid = groupId
                local groupname = groupObj:getName()
                local desc = un:getDesc()
                local unitType = desc.typeName
				self.context.battleCommander.playerNames = self.context.battleCommander.playerNames or {}
                self.context.battleCommander.playerNames[groupid] = player
				self.context.battleCommander:refreshShopMenuForGroup(groupid, groupObj)

				self.context.battleCommander.groupByPlayer = self.context.battleCommander.groupByPlayer or {}
				self.context.battleCommander.groupNameByPlayer = self.context.battleCommander.groupNameByPlayer or {}
				self.context.battleCommander.groupByPlayer[player] = groupid
				self.context.battleCommander.groupNameByPlayer[player] = groupname


                if not self.context.statsMenus[groupid] then

					local statsMenu = missionCommands.addSubMenuForGroup(groupid, 'Stats and Budget')
					local statsSubMenu = missionCommands.addSubMenuForGroup(groupid, 'Stats', statsMenu)
					missionCommands.addCommandForGroup(groupid, 'My Stats', statsSubMenu, self.context.battleCommander.printMyStats, self.context.battleCommander, event.initiator:getID(), player)
					missionCommands.addCommandForGroup(groupid, 'All Stats', statsSubMenu, self.context.battleCommander.printStats, self.context.battleCommander, event.initiator:getID())
					missionCommands.addCommandForGroup(groupid, 'Top 5 Players', statsSubMenu, self.context.battleCommander.printStats, self.context.battleCommander, event.initiator:getID(), 5)
					missionCommands.addCommandForGroup(groupid, 'Top 5 Today', statsSubMenu, self.context.battleCommander.printDailyTop, self.context.battleCommander, event.initiator:getID(), 5)
					missionCommands.addCommandForGroup(groupid, 'Rank Help', statsSubMenu, self.context.battleCommander.printRankHelp, self.context.battleCommander, groupid)			
					missionCommands.addCommandForGroup(groupid, 'Budget Overview', statsMenu, self.context.battleCommander.printShopStatus, self.context.battleCommander, groupid, event.initiator:getCoalition())
					
					self.context.statsMenus[groupid] = statsMenu
				end
				MissionsRootMenus = MissionsRootMenus or {}
				local missionsRoot = MissionsRootMenus[groupid] or missionCommands.addSubMenuForGroup(groupid, 'Missions')
				MissionsRootMenus[groupid] = missionsRoot
				printMissionMenus = printMissionMenus or {}
			if not printMissionMenus[groupid] then
				printMissionMenus[groupid] = missionCommands.addCommandForGroup(groupid, 'Missions', missionsRoot, mc.printMissions, mc, groupid)
				
				local playerCoalition = event.initiator:getCoalition()
				SCHEDULER:New(nil, function()
				local jm = missionCommands.addSubMenuForGroup(groupid, 'Joint missions', missionsRoot)
				missionCommands.addCommandForGroup(groupid, 'Invite to joint mission', jm, self.context.battleCommander._jointGenCode, self.context.battleCommander, groupid, playerCoalition)
				local dial = missionCommands.addSubMenuForGroup(groupid, 'Join another player', jm)
				for d1=1,9,1 do
					local m1 = missionCommands.addSubMenuForGroup(groupid, tostring(d1)..'___', dial)
					for d2=0,9,1 do
						local m2 = missionCommands.addSubMenuForGroup(groupid, tostring(d1)..tostring(d2)..'__', m1)
						for d3=0,9,1 do
							local m3 = missionCommands.addSubMenuForGroup(groupid, tostring(d1)..tostring(d2)..tostring(d3)..'_', m2)
							for d4=0,9,1 do
								local code = tonumber(tostring(d1)..tostring(d2)..tostring(d3)..tostring(d4))
								missionCommands.addCommandForGroup(groupid, 'code '..tostring(code), m3, self.context.battleCommander._jointAcceptCode, self.context.battleCommander, groupid, code, playerCoalition)
							end
						end
					end
				end

				missionCommands.addCommandForGroup(groupid, 'Leave Joint mission', jm, self.context.battleCommander._jointLeave, self.context.battleCommander, groupid)
				missionCommands.addCommandForGroup(groupid, 'Joint mission status', jm, function()
					local bcx = self.context.battleCommander
					local pname = bcx.playerNames and bcx.playerNames[groupid]
					local jp = pname and bcx.jointPairs and bcx.jointPairs[pname]
					if jp and bcx:_jointPartnerAlive(pname) and bcx:_jointPartnerAlive(jp) then
						trigger.action.outTextForGroup(groupid, 'In Joint mission with '..jp, 15)
					else
						trigger.action.outTextForGroup(groupid, "You're alone", 15)
					end
				end)
				missionCommands.addCommandForGroup(groupid, 'Help', jm, function()
					local txt = 'Joint missions lets two players get up to double the rewards of the mission credits.\n\n'
						.. 'How it works:\n'
						.. '• Host selects "Invite to joint mission" to receive a 4-digit code.\n'
						.. '• Teammate opens "Join another player" and enters the code.\n'
						.. '• Credits will be rewarded to both for missions. Not any regular kills.\n'
						.. '• Valid for CAS, CAP, Bomb runway, Strike missions.\n'
						.. '• If your partner is dead/despawned, you will still keep your earnings plus the extra reward.\n'
						.. '• Same-coalition only.'
					trigger.action.outTextForGroup(groupid, txt, 30)
				end)
				end, {}, 1)
			

				if self.context.allowedTypes[unitType] then
					if not LogisticCommander.mooseLogisticsMenus[groupid] and not self.context.groupMenus[groupid] then
						self.context.carriedCargo[groupid] = 0
						self.context.carriedPilots[groupid] = 0

						local mooseMenu = LogisticCommander.mooseLogisticsMenus[groupid]
						if mooseMenu then
							if mooseMenu.Remove then
								mooseMenu:Remove()
							end
							LogisticCommander.mooseLogisticsMenus[groupid] = nil
						elseif self.context.groupMenus[groupid] then
							missionCommands.removeItemForGroup(groupid, self.context.groupMenus[groupid])
						end
							self.context.groupMenus[groupid] = nil
					if LogisticCommander.AllowedCsar[unitType] > 0 then
						self.context.csarGroupMenus[groupid] = true
						local csar = missionCommands.addSubMenuForGroup(groupid, 'CSAR')
						missionCommands.addCommandForGroup(groupid, 'Info on closest pilot', csar, self.context.infoPilot, self.context, groupname)
						missionCommands.addCommandForGroup(groupid, 'Deploy smoke at closest pilot', csar, self.context.markPilot, self.context, groupname)
						missionCommands.addCommandForGroup(groupid, 'Deploy flare at closest pilot', csar, self.context.flarePilot, self.context, groupname)
						missionCommands.addCommandForGroup(groupid, 'Smoke nearest zone', csar, function() Foothold_ctld:SmokeZoneNearBy(GROUP:FindByName(groupname):GetUnit(1), false) end)
						missionCommands.addCommandForGroup(groupid, 'Flare nearest zone', csar, function() Foothold_ctld:SmokeZoneNearBy(GROUP:FindByName(groupname):GetUnit(1), true) end)
						--missionCommands.addCommandForGroup(groupid, 'Pick up pilot', csar, self.context.loadPilot, self.context, groupname)
						--missionCommands.addCommandForGroup(groupid, 'Drop off pilot', csar, self.context.unloadPilot, self.context, groupname)
						--missionCommands.addCommandForGroup(groupid, 'Info on closest pilot with credits', csar, self.context.infoHumanPilot, self.context, groupname)
					else
						self.context.csarGroupMenus[groupid] = nil
					end
					SCHEDULER:New(nil, function()
						local cargomenuObj = nil
						local mooseGroup = GROUP and GROUP:FindByName(groupname) or nil
						if mooseGroup and MENU_GROUP and MENU_GROUP.New then
							cargomenuObj = MENU_GROUP:New(mooseGroup, 'Logistics', nil)
							LogisticCommander.mooseLogisticsMenus[groupid] = cargomenuObj
						end
						local cargomenu = cargomenuObj and cargomenuObj.MenuPath or missionCommands.addSubMenuForGroup(groupid, 'Logistics')
						if LogisticCommander.AllowedToCarrySupplies[unitType] and WarehouseLogistics == false then
							missionCommands.addCommandForGroup(groupid, 'Load supplies', cargomenu, self.context.loadSupplies, self.context, groupname)
							if LogisticCommander.doubleSupplyTypes and LogisticCommander.doubleSupplyTypes[unitType] then
								missionCommands.addCommandForGroup(groupid, 'Load 2 supplies', cargomenu, self.context.loadSupplies, self.context, groupname, 2)
							end
							missionCommands.addCommandForGroup(groupid, 'Unload supplies', cargomenu, self.context.unloadSupplies, self.context, groupname)
							missionCommands.addCommandForGroup(groupid, 'List supply zones', cargomenu, self.context.listSupplyZones, self.context, groupname)
							missionCommands.addCommandForGroup(groupid, 'Supplies Status', cargomenu, self.context.checkSuppliesStatus, self.context, groupid)
						end
                        -- duplicate CTLD static cargo menus under Logistics

						if Foothold_ctld and Foothold_ctld.Cargo_Statics and WarehouseLogistics == true then
							missionCommands.addCommandForGroup(groupid, 'Supplies help', cargomenu, function()
								local txt = 'Logistics overview\n\n'
									.. 'Zone supplies (Upgrades + initial stock)\n'
									.. '• Use "Zone supplies" to pick up supply crates.\n'
									.. '• Load/unload using Ground Crew.\n'
									.. '• 1 crate = 1 zone upgrade.\n'
									.. '• Crates are very heavy. Carry multiple only if your aircraft allows it.\n'
									.. '• You can slingload, or combine 1 internal + 1 slingload.\n'
									.. '• Each crate delivers 10 of every warehouse item (bombs, missiles, guided bombs, rockets, A/G missiles, etc).\n\n'
									.. 'Warehouse supplies (Extra weapons)\n'
									.. '• Use "Warehouse supplies" to deliver larger weapon quantities.\n'
									.. '• Warehouse supplies do not capture zones.\n\n'
									.. 'Capturing with troops\n'
									.. '• CTLD troops can capture/upgrade zones.\n'
									.. '• 1 troop group = 1 upgrade.\n'
									.. '• If a zone is already fully upgraded, extra troops are refunded.'
								trigger.action.outTextForGroup(groupid, txt, 45)
							end)
						
							self.context.staticMenus = self.context.staticMenus or {}
							self.context.staticMenus[groupid] = self.context.staticMenus[groupid] or {}
							local staticMenuPages = {}
							local crateStockSummary = nil
							if Foothold_ctld.showstockinmenuitems then
								crateStockSummary = Foothold_ctld:_CountStockPlusInHeloPlusAliveGroups(false)
							end
                            local function ensureStaticSubMenu(label)
                                if self.context.staticMenus[groupid][label] then
                                    return self.context.staticMenus[groupid][label]
                                end
                                local handle
                                if cargomenuObj then
                                    handle = MENU_GROUP:New(mooseGroup, label, cargomenuObj)
                                else
                                    handle = missionCommands.addSubMenuForGroup(groupid, label, cargomenu)
                                end
                                self.context.staticMenus[groupid][label] = handle
                                return handle
                            end

							local function getPagedStaticMenu(label)
								local state = staticMenuPages[label]
								if not state then
									state = { current = ensureStaticSubMenu(label), count = 0 }
									staticMenuPages[label] = state
								end
								if state.count >= 9 then
									local nextHandle
									if cargomenuObj then
										nextHandle = MENU_GROUP:New(mooseGroup, 'More', state.current)
									else
										nextHandle = missionCommands.addSubMenuForGroup(groupid, 'More', state.current)
									end
									state.current = nextHandle
									state.count = 0
								end
								state.count = state.count + 1
								return state.current
							end

                            local function unitCanCarryStatic(cargoObj)
                                if not cargoObj or not cargoObj.UnitCanCarry then
                                    return true
                                end
                                local unitRef = mooseGroup and mooseGroup:GetUnit(1)
                                return unitRef and cargoObj:UnitCanCarry(unitRef) or false
                            end

                            local function addStaticCommand(cargoObj)
                                if not unitCanCarryStatic(cargoObj) then return end
								local parentMenu = getPagedStaticMenu(cargoObj.Subcategory or "Statics")
                                local needed = cargoObj:GetCratesNeeded() or 1
                                local mass = cargoObj.PerCrateMass or 0
                                local title
                                if needed > 1 then
                                    title = string.format("%d crate%s %s (%dkg)",needed,needed==1 and "" or "s",cargoObj.Name,mass)
                                else
                                    title = string.format("%s (%dkg)",cargoObj.Name,mass)
                                end
                                if cargoObj.Location then title = title.."[R]" end
                                if Foothold_ctld.showstockinmenuitems then
                                    local suffix = Foothold_ctld:_FormatCrateStockSuffix(cargoObj,crateStockSummary)
                                    if suffix then title = title..suffix end
                                end
                                if cargomenuObj then
                                    local unitRef = mooseGroup and mooseGroup:GetUnit(1)
                                    if unitRef then
                                        local mSet = MENU_GROUP:New(mooseGroup, title, parentMenu)
                                        Foothold_ctld:_AddCrateQuantityMenus(mooseGroup, unitRef, mSet, cargoObj, crateStockSummary)
                                    end
                                else
                                    local function handler()
                                        local unitRef = mooseGroup and mooseGroup:GetUnit(1)
                                        if unitRef then
                                            Foothold_ctld:_GetCrates(mooseGroup, unitRef, cargoObj, cargoObj:GetCratesNeeded())
                                        end
                                    end
                                    missionCommands.addCommandForGroup(groupid, title, parentMenu, handler)
                                end
                            end

							for _, cargoObj in pairs(Foothold_ctld.Cargo_Statics) do
								if cargoObj then
									addStaticCommand(cargoObj)
								end
							end
							
                        end
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
						self.context.groupIdToName[groupid] = groupname
						self.context.csarGroups[groupid] = { name = groupname, player = player }
						if self.context.csarSet and self.context.csarSet.AddGroup then
							local mg = GROUP and GROUP:FindByName(groupname) or nil
							if mg then self.context.csarSet:AddGroup(mg) end
						end
						self.context.carriedCargo[groupid] = nil
					end, {}, 0.5)
				  end
				end
				local unitNameForMoose = un:getName()
				local zoneNameForMoose = zn and zn.zone or nil
				SCHEDULER:New(nil, function()
					local mooseUnit = UNIT:FindByName(unitNameForMoose)
					if mooseUnit and mooseUnit:IsAlive() then
						static:processPlayerSpawn(mooseUnit, zoneNameForMoose)
					end
				end, {}, 0.5)
				local stats = SelfJtac.getAircraftStats(desc.typeName)
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
	end

        if event.id == world.event.S_EVENT_TAKEOFF
           and event.initiator and event.initiator.getPlayerName and WarehouseLogistics == false
        then
            local groupid = event.initiator:getGroup():getID()
            local unitType = event.initiator:getDesc()['typeName']
            local player = event.initiator:getPlayerName()
            local un = event.initiator
            local zn = self.context.battleCommander:getZoneOfUnit(un:getName())

            if zn and (zn.side == un:getCoalition() or (un:getCoalition() == 2 and zn.wasBlue)) then
                for _, v in ipairs(self.context.supplyZones) do
                    if v == zn.zone then
                        if self.context.AllowedToCarrySupplies[unitType] and not self.context.carriedCargo[groupid] then
                            trigger.action.outTextForGroup(groupid, 'Warning: Supplies not loaded', 30,true)
                            if trigger.misc.getUserFlag(180) == 0 then
                                trigger.action.outSoundForGroup(groupid, "micclick.ogg")
                            end
                        end
                        return
                    end
                end
            else
                local group = GROUP:FindByName(un:getGroup():getName())
                if group and un:getCoalition() == 2 then
                    for _, zName in ipairs(self.context.supplyZones) do
                        if string.find(zName, "CTLD FARP") or string.find(zName, "Escort Mission FARP") then
                            local zObj = ZONE:FindByName(zName)
                            if zObj and group:IsInZone(zObj) then
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
            end
        end


		if event.id==world.event.S_EVENT_LANDING_AFTER_EJECTION then
			local aircraftID=event.place and event.place.id_
			local coalitionSide = event.initiator:getCoalition()
			local pilotObjectID=event.initiator and event.initiator:getObjectID()
			ejectedPilotOwnersByAircraft = ejectedPilotOwnersByAircraft or {}
			local list = aircraftID and ejectedPilotOwnersByAircraft[aircraftID]
			local pilotData = list and table.remove(list,1) or nil
			if list and #list == 0 then ejectedPilotOwnersByAircraft[aircraftID] = nil end

			self.context.csarPilotProcessedByAircraft = self.context.csarPilotProcessedByAircraft or {}
			local processed = aircraftID and (self.context.csarPilotProcessedByAircraft[aircraftID] or 0) or 0
			if pilotData then
				processed = processed + 1
				if aircraftID then self.context.csarPilotProcessedByAircraft[aircraftID] = processed end
			end

			
			local function pointInActiveZone(obj)
				if not obj then return nil end
				local bc = self.context and self.context.battleCommander
				for _, z in ipairs(bc.zones) do
					if z.active and z.side and z.side ~= 0 and z.zone then
						if Utils.isInZone(obj, z.zone) then
							return z.side, z.zone
						end
					end
				end
				return nil
			end

			if coalitionSide == coalition.side.RED then
				event.initiator:destroy()
				return
			end

			local zoneSide, zoneName = pointInActiveZone(event.initiator)
			if zoneSide then
				if pilotData and pilotData.player and pilotData.player ~= '' then
					if pilotData.coalition and zoneSide ~= pilotData.coalition then
						self.context.battleCommander:addStat(pilotData.player,'Captured by enemy',1)
						trigger.action.outTextForCoalition(2,"["..pilotData.player.."] has been captured by enemy forces in "..zoneName..". Assumed dead.",10)
					else
						self.context.battleCommander:addStat(pilotData.player,'Deaths',-1)
						trigger.action.outTextForCoalition(2,"["..pilotData.player.."] landed safely in "..zoneName..".",10)
					end
				end
				landedPilotOwners[pilotObjectID]=nil
				event.initiator:destroy()
				return
			end

			self.context.csarPilotByAircraft = self.context.csarPilotByAircraft or {}
			local existingPilot = aircraftID and self.context.csarPilotByAircraft[aircraftID]
			local isPlayerAircraft = aircraftID and self.context.csarPlayerAircraftByAircraft and self.context.csarPlayerAircraftByAircraft[aircraftID]
			if not pilotData and not isPlayerAircraft and existingPilot and existingPilot:isExist() then
				landedPilotOwners[pilotObjectID]=nil
				if event.initiator and event.initiator:isExist() then
					event.initiator:destroy()
				end
				return
			end

			local function spawnDownedPilot()
				local templateName = "Downed Pilot"
				local coord = event.initiator and event.initiator:getPoint()
				if not coord then return nil end
				local spawnCoord = COORDINATE:NewFromVec3(coord)
				if not spawnCoord then return nil end
				local alias = "FOOTHOLD_CSAR_"..tostring(aircraftID or math.random(1000,9999)).."_"..tostring(pilotObjectID or math.random(1000,9999))
				local sp = SPAWN:NewWithAlias(templateName, alias)
				if sp.InitCoalition then
					sp = sp:InitCoalition(coalitionSide)
				end
				local spawned = sp:SpawnFromPointVec3(spawnCoord)
				if not spawned then return nil end
				local unitWrapper = spawned:GetUnit(1)
				env.info('[FOOTHOLD CSAR] Spawned downed pilot '..alias or nil)
				return unitWrapper and unitWrapper:GetDCSObject() or nil	
			end

			local newPilotObj = spawnDownedPilot()
			local pilotObj = newPilotObj or event.initiator
			local newObjectID = pilotObj and pilotObj:getObjectID()
			if pilotData then
				self.csarPilotDataByObject = self.csarPilotDataByObject or {}
				if pilotObjectID then
					landedPilotOwners[pilotObjectID] = pilotData
					self.csarPilotDataByObject[pilotObjectID] = pilotData
				end
				if newObjectID and newObjectID ~= pilotObjectID then
					landedPilotOwners[newObjectID] = pilotData
					self.csarPilotDataByObject[newObjectID] = pilotData
				end
			end


			if aircraftID and not pilotData then
				self.context.csarPilotByAircraft[aircraftID] = pilotObj
				processed = processed + 1
				self.context.csarPilotProcessedByAircraft[aircraftID] = processed
			end

			table.insert(self.context.ejectedPilots,pilotObj)
			for i in pairs(self.context.csarGroupMenus) do
				local groupid=i
				SCHEDULER:New(nil,function()
					if pilotObj and pilotObj:isExist() then
						self.context:printPilotInfo(pilotObj,groupid,nil,15)
					end
				end,{},15,0)
			end

			if newPilotObj and event.initiator and event.initiator:isExist() then
				event.initiator:destroy()
			end
		end
    end
    world.addEventHandler(ev)
	SCHEDULER:New(nil,self.update,{self},10,10)
end


function LogisticCommander:checkSuppliesStatus(groupid)
	local cargo = self.carriedCargo[groupid]
	if cargo then
			local count = type(cargo) == "table" and cargo.count or 1
		if count and count > 1 then
			trigger.action.outTextForGroup(groupid, count.. ' Supplies loaded', 10)
		else
			trigger.action.outTextForGroup(groupid, 'Supplies loaded', 10)
		end
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
				if event.initiator and event.initiator:isExist() then
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
			return
		end
		
		MissionsRootMenus = MissionsRootMenus or {}
		local parent = MissionsRootMenus[groupId]
		if parent then
			printMissionMenus[groupId] = missionCommands.addCommandForGroup(groupId, "Available missions", parent, function() self:printMissions(groupId) end)
		else
			return
		end
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
			local currentZone = bc.indexedZones[mission.TargetZone]
			if not currentZone then if mission._autoCapSch then mission._autoCapSch:Stop() mission._autoCapSch = nil end return end
			if currentZone.side == 2 then if mission._autoCapSch then mission._autoCapSch:Stop() mission._autoCapSch = nil end return end
			if currentZone.side == 0 and Utils.someOfGroupInZone(group, mission.TargetZone) then currentZone:capture(2) if mission._autoCapSch then mission._autoCapSch:Stop() mission._autoCapSch = nil end return end
		end, {}, 2, 5)
	end

function canStartMission(mission)
    if not mission then return false end
    local targetZone = bc.indexedZones[mission.TargetZone]
    if not targetZone or targetZone.side ~= 1 then return false end
    if not missions[mission.zone] then return false end
    return not IsGroupActive(mission.missionGroup)
end

--[[ 	local z = bc.indexedZones['Al Dahid']
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
    local TgtZone = bc.indexedZones[mission.TargetZone]
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
						if z and z.side == 0 and not z.firstCaptureByRed then
					env.info("DEBUG: Activating zone for mission: "..mission.ActivateZone)		
					z:MakeZoneRedAndUpgrade() end
						
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
local FARPFreq = 129
local MapFARPCount=0
function FarpHere(Coordinate, customName)
  if bc:getZoneOfPoint(Coordinate:GetVec3()) then return end
  MapFARPCount=MapFARPCount+1
  local baseLabel=customName and customName or tostring(MapFARPCount)
  local FName="CTLD Farp "..baseLabel
  FARPFreq=FARPFreq+1
  ZONE_RADIUS:New(FName,Coordinate:GetVec2(),120,false)
 if Era=="Coldwar" then
 	UTILS.SpawnFARPAndFunctionalStatics(FName,Coordinate,ENUMS.FARPType.INVISIBLE,Foothold_ctld.coalition,country.id.USA,MapFARPCount,FARPFreq,radio.modulation.AM,nil,nil,nil,10000,0,0,nil,true,true,3,80,80)
else
  	UTILS.SpawnFARPAndFunctionalStatics(FName,Coordinate,ENUMS.FARPType.INVISIBLE,Foothold_ctld.coalition,country.id.USA,MapFARPCount,FARPFreq,radio.modulation.AM,nil,nil,nil,10000, 0,1073741823,nil,true,true,3,80,80)
end
  Foothold_ctld:AddCTLDZone(FName,CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,false)
  MESSAGE:New(string.format("%s in operation!",FName),15):ToBlue()
 
SCHEDULER:New(nil, function() bc:CopyWarehouse(FName) end, {}, 2)
bc:registerDynamicFarp(FName, Coordinate, 2)
  if not NextMarkupId then NextMarkupId=120000 end
  local markId=NextMarkupId; NextMarkupId=NextMarkupId+1
  trigger.action.circleToAll(-1,markId,Coordinate:GetVec3(),120,{0,0,1,1},{0,0,1, 0.25},1)
  trigger.action.setMarkupTypeLine(markId,2)
  trigger.action.setMarkupColor(markId,{0,1,0,1})
  local textId=NextMarkupId; NextMarkupId=NextMarkupId+1
  local textPoint={x=Coordinate.x,y=Coordinate.y,z=Coordinate.z+120}
  trigger.action.textToAll(-1,textId,textPoint,{0,0,0.7,0.8},{0.7,0.7,0.7,0.8},18,true,FName)
  trigger.action.setMarkupText(textId,FName)
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
  if Era=="Coldwar" then
  UTILS.SpawnFARPAndFunctionalStatics(FName,Coordinate,ENUMS.FARPType.INVISIBLE,Foothold_ctld.coalition,country.id.USA,EscortFARPCount,FARPFreq,radio.modulation.AM,nil,nil,nil,5000,0,0,nil,true,true, 3, 80, 80)
  else
  UTILS.SpawnFARPAndFunctionalStatics(FName,Coordinate,ENUMS.FARPType.INVISIBLE,Foothold_ctld.coalition,country.id.USA,EscortFARPCount,FARPFreq,radio.modulation.AM,nil,nil,nil,10000, 0,1073741823,nil,true,true, 3, 80, 80)
  end
 
  Foothold_ctld:AddCTLDZone(FName,CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,false)
  MESSAGE:New(string.format("%s in operation!",FName),15):ToBlue()

  SCHEDULER:New(nil, function() bc:CopyWarehouse(FName) end, {}, 2)

  local markId = 96000 + EscortFARPCount
  trigger.action.circleToAll(-1,markId,Coordinate:GetVec3(),120,{0,0,1,1},{0,0,1,0.25},1)
  trigger.action.setMarkupTypeLine(markId, 2)
  trigger.action.setMarkupColor(markId, {0,1,0,1})

  local textId = 96500 + EscortFARPCount
  local textPoint = {x = Coordinate.x, y = Coordinate.y, z = Coordinate.z + 120}
  trigger.action.textToAll(-1, textId, textPoint,{0,0,0.7,0.8},{0.7,0.7,0.7,0.8},18,true,FName)
  trigger.action.setMarkupText(textId, FName)
    bc:registerDynamicFarp(FName, Coordinate, 2)
  
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
		and (not v.isHidden)
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

-- BASE:TraceOn()
-- 
-- BASE:TraceClass("MANTIS")
-- BASE:TraceClass("CTLD_ENGINEERING")
-- BASE:TraceClass("AUFTRAG")
-- BASE:TraceClass("INTEL")

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
ARCO_PROX_RADIUS_M = UTILS.FeetToMeters(2000)
ARCO_PROX_ALT_M = UTILS.FeetToMeters(500)

TEXACO_PROX_RADIUS_M = UTILS.FeetToMeters(2000)
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

-- BASE:TraceOn()
-- BASE:TraceClass("AUFTRAG")

function setTexacoRacetrack(coord, heading, leg, zone)
    if not TexacoGroup then return end
    local currentMission = TexacoGroup:GetMissionCurrent()
    if currentMission then
        currentMission:__Cancel(5)
    end
    local TexacoTanker2 = AUFTRAG:NewTANKER(coord, 16000, 280, heading, leg)
    
	TexacoTanker2:SetMissionSpeed(361)
	TexacoTanker2:SetMissionAltitude(16000)
	TexacoGroup:AddMission(TexacoTanker2)


	function TexacoTanker2:OnAfterStarted(From, Event, To)
--[[ 		TexacoGroup:SetAltitude(4876)
		TexacoGroup:SetSpeed(UTILS.KnotsToMps(400)) ]]

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
    local ArcoTanker2 = AUFTRAG:NewTANKER(coord, 18000, 280, heading, leg)
	ArcoTanker2:SetMissionSpeed(371)
	ArcoTanker2:SetMissionAltitude(18000)
    ArcoGroup:AddMission(ArcoTanker2)

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
			self:SwitchROE(2)
			trigger.action.outText("CAP is out of missiles, returning to base", 20)
			end
		end
		
		function capGroup:OnAfterDead(From, Event, To)
			local landed = (From=="Landed") or (From=="Arrived")
			self:__Stop(1)
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
		ArcoGroup:SwitchInvisible(true):SwitchImmortal(true):GetGroup():CommandSetUnlimitedFuel(true)
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
			self:__Stop(1)
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
		TexacoGroup:SwitchInvisible(true):SwitchImmortal(true):GetGroup():CommandSetUnlimitedFuel(true)
		--TexacoGroup:GetGroup():CommandSetImmortal(true):CommandSetInvisible(true)
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
			self:__Stop(1)
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
    local zn = bc.indexedZones[targetZoneName]
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
	CasMission:AddConditionSuccess(function() return bc.indexedZones[targetZoneName].side == 0 end)
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
		self:__Stop(1)
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
    local zn = bc.indexedZones[targetZoneName]
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
    local zn = bc.indexedZones[targetZoneName]
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
			self:__Stop(1)
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
	local zn = bc.indexedZones[targetZoneName]
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
		self:__Stop(1)
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
    local zn = bc.indexedZones[targetZoneName]
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
	BombMission:AddConditionSuccess(function() return bc.indexedZones[targetZoneName].side == 0 end)
	BombMission:AddConditionFailure(function() return BomberGroup and bc.indexedZones[targetZoneName].side == 1 and BomberGroup:IsOutOfBombs() end)
	BombMission:SetMissionAltitude(27000)
	if era == 'Coldwar' then
		BombMission:SetWeaponExpend(AI.Task.WeaponExpend.FOUR)
	else
		BombMission:SetWeaponExpend(AI.Task.WeaponExpend.ONE)
	end
	
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
	BombMission:AddConditionSuccess(function() return bc.indexedZones[targetZoneName].side == 0 end)
	BombMission:AddConditionFailure(function() return bc.indexedZones[targetZoneName].side == 1 and BomberGroup:IsOutOfBombs() end)
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
		self:__Stop(1) 
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
    local zn = bc.indexedZones[targetZoneName]
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
		self:__Stop(5) 
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


function checkGroupState(groupName)
    if not groupName or not bc or not bc.zones then return end
    for _, z in ipairs(bc.zones) do
        if z.groups then
            for _, g in ipairs(z.groups) do
                if g.name == groupName then
                    env.info("Group ["..groupName.."] state: "..tostring(g.state))
                    return
                end
            end
        end
    end
    env.info("GroupCommander not found: "..tostring(groupName))
end

--checkGroupState("Taftanaz-attack-Duhur-Cas")


-- Start Mantis efter 10 Seconds.

SCHEDULER:New(nil, function()
--if IsGroupActive("AWACS_RED") then
	--FootholdMantis = MANTIS:New("Foothold MANTIS","Red SAM","Red EWR",nil,"red",true,"AWACS_RED")
--else
	FootholdMantis = MANTIS:New("Foothold MANTIS","Red SAM","Red EWR",nil,"red",true,nil)
--end
FootholdMantis:SetSAMRange(110)
FootholdMantis:SetDetectInterval(10)
FootholdMantis:SetAccousticDetectionOn(3000)
--FootholdMantis:SetSmokeDecoy(true)
ZoneTable_Mantis = SET_ZONE:New():FilterPrefixes("Scoot"):FilterStart()
FootholdMantis:AddScootZones(ZoneTable_Mantis, 3, true, "Cone")
FootholdMantis.autorelocate = true
FootholdMantis:Start()
end, {}, 3)


--FootholdMantis:Debug(true)
--[[ BASE:TraceOn()
BASE:TraceClass("AUFTRAG")
BASE:TraceClass("FLIGHTGROUP") ]]

WarehouseExtraAirbases = WarehouseExtraAirbases or {}
WarehousePersistence = WarehousePersistence or {}
do

	local function _shouldSkip(name)
		if not name or name == "" then return true end
		if name == 'CVN-72' or name == 'CVN-73' or name == 'CVN-74' or name == 'CVN-59' or name == 'Tarawa' or name == 'HMS Invincible' then return true end
		if Airbase and Airbase.getByName and Airbase.Category then
			local dcsAb = Airbase.getByName(name)
			if dcsAb and dcsAb.getDesc then
				local desc = dcsAb:getDesc()
				if desc and desc.category == Airbase.Category.SHIP then return true end
			end
		end
		if AIRBASE and AIRBASE.FindByName then
			local ab = AIRBASE:FindByName(name)
			if ab and ab.IsShip and ab:IsShip() then return true end
		end
		return false
	end

	function WarehousePersistence.RegisterExtraAirbase(name)
		if _shouldSkip(name) then return false end
		WarehouseExtraAirbases = WarehouseExtraAirbases or {}
		WarehouseExtraAirbases[name] = true
		return true
	end

    local function _airbases(zonesTbl)
        local zs = zonesTbl
        if zs and zs.zones then zs = zs.zones end
        zs = zs or zones or {}
        local names, seen = {}, {}
		local logistic = {}
        for _, z in pairs(zs) do
            if z and z.airbaseName and z.LogisticCenter then
				logistic[z.airbaseName] = true
			end
            if z and z.side == 2 and z.active and not z.isHidden and not z.LogisticCenter then
                local n = z.airbaseName
                if n and not logistic[n] and not _shouldSkip(n) and not seen[n] then
                    seen[n] = true
                    names[#names + 1] = n
                end
            end
        end
        for extraName in pairs(WarehouseExtraAirbases or {}) do
            if extraName and not logistic[extraName] and not seen[extraName] and not _shouldSkip(extraName) then
                seen[extraName] = true
                names[#names + 1] = extraName
            end
        end
        table.sort(names)
        return names
    end

	local function _pathFile(opts)
		local path = (opts and opts.path) or (lfs and lfs.writedir and (lfs.writedir() .. "Missions\\Saves")) or nil
		local filename = (opts and opts.filename)
		if not filename then
			if FootholdSaveBaseName and tostring(FootholdSaveBaseName) ~= "" then
				filename = tostring(FootholdSaveBaseName) .. "_storage.csv"
			else
				filename = "Foothold_storage.csv"
			end
		end
		return path, filename
	end

  function WarehousePersistence.ClearFile(opts)
    opts = opts or {}
    if not (io and lfs and lfs.writedir) then return false end

    local path, filename = _pathFile(opts)
    if not (path and filename) then return false end

    local full = path .. "\\" .. filename
    local ok, err = pcall(function()
      local f = assert(io.open(full, "wb"))
      f:write("")
      f:close()
    end)

    if ok then
      env.info(string.format("[WarehousePersistence] Cleared storage file %s", tostring(full)))
      return true
    end

    env.info(string.format("[WarehousePersistence] Failed clearing storage file %s (%s)", tostring(full), tostring(err)))
    return false
  end

  
	function WarehousePersistence.Save(zonesTbl, opts)
		opts = opts or {}
		if WarehouseLogistics ~= true and opts.force ~= true then return false end
		if not (lfs and io and UTILS and UTILS.SaveToFile) then return false end
		if not (STORAGE and STORAGE.FindByName and WEAPONSLIST and WEAPONSLIST.GetAllItems) then return false end
		local path, filename = _pathFile(opts); if not path then return false end
		local airbases = opts.airbases or _airbases(zonesTbl)
		local out = {'AIRBASE;KIND;NAME;QTY'}
		local saved = 0

		local wsItems = {}
		for _, item in ipairs(WEAPONSLIST.GetAllItems() or {}) do
			if type(item) == 'table' then
				wsItems[#wsItems + 1] = item
			end
		end

		local zs = zonesTbl
		if zs and zs.zones then zs = zs.zones end
		zs = zs or zones or {}
		local zoneByAirbase = {}
		for _, z in pairs(zs) do
			if z and z.airbaseName and z.side == 2 and z.active and not z.isHidden and not z.LogisticCenter then
				zoneByAirbase[z.airbaseName] = z.zone
			end
		end
		local lowAvg = {}

		for _, ab in ipairs(airbases) do
			local st = STORAGE:FindByName(ab)
			if st and st.GetInventory then
				local sumQty, countQty, nonZeroEntries, hasUnlimited = 0, 0, 0, false
				local _, _, wp = st:GetInventory()
				if type(wp) == 'table' then
					for item, qty in pairs(wp) do
						qty = tonumber(qty) or 0
						if qty < 0 then
							hasUnlimited = true
						else
							if qty > 0 then
								sumQty = sumQty + qty
								countQty = countQty + 1
							end
						end
						if qty ~= 0 then
							nonZeroEntries = nonZeroEntries + 1
							out[#out + 1] = string.format('%s;W;%s;%d', ab, tostring(item), qty)
						end
					end
				end
				if st.GetItemAmount then
					for i = 1, #wsItems do
						local w = wsItems[i]
						local qty = tonumber(st:GetItemAmount(w)) or 0
						if qty < 0 then
							hasUnlimited = true
						else
							if qty > 0 then
								sumQty = sumQty + qty
								countQty = countQty + 1
							end
						end
						if qty ~= 0 then
							nonZeroEntries = nonZeroEntries + 1
							out[#out + 1] = string.format('%s;W;{%d,%d,%d,%d};%d', ab, tonumber(w[1]) or 0, tonumber(w[2]) or 0, tonumber(w[3]) or 0, tonumber(w[4]) or 0, qty)
						end
					end
				end
				local zoneName = zoneByAirbase[ab]
				if zoneName and not hasUnlimited then
					local avg = (countQty > 0) and (sumQty / countQty) or 0
					if nonZeroEntries < 500 or avg < 50 then
						lowAvg[zoneName] = { avg = avg, entries = nonZeroEntries }
					end
				end
				saved = saved + 1
			end
		end

		local ok = UTILS.SaveToFile(path, filename, table.concat(out, '\n') .. '\n')
		if ok then env.info(string.format('[WarehousePersistence] Saved %d storages to %s\\%s', saved, tostring(path), tostring(filename))) end

		local zonesToUpdate = {}
		WarehouseLowSupplies = WarehouseLowSupplies or {}
		for zn in pairs(WarehouseLowSupplies) do
			zonesToUpdate[zn] = true
			if not lowAvg[zn] then
				WarehouseLowSupplies[zn] = nil
			end
		end
		for zn in pairs(lowAvg) do
			WarehouseLowSupplies[zn] = lowAvg[zn]
			zonesToUpdate[zn] = true
		end
		for _, zn in pairs(zoneByAirbase) do
			zonesToUpdate[zn] = true
		end
		for zn in pairs(zonesToUpdate) do
			local z = bc:getZoneByName(zn) ; if z then z:updateLabel() end
		end
		if not next(WarehouseLowSupplies) then WarehouseLowSupplies = nil end
		return ok
	end


	function WarehousePersistence.Load(zonesTbl, opts)
		opts = opts or {}
		if WarehouseLogistics ~= true and opts.force ~= true then return false end
		if not (lfs and io and UTILS and UTILS.LoadFromFile and UTILS.Split) then return false end
		if not (STORAGE and STORAGE.FindByName) then return false end
		local path, filename = _pathFile(opts); if not path then return false end
		local logistic = {}
		local zs = zonesTbl
		if zs and zs.zones then zs = zs.zones end
		zs = zs or zones or {}
		for _, z in pairs(zs) do
			if z and z.airbaseName and z.LogisticCenter then
				logistic[z.airbaseName] = true
			end
		end
		local allowed = {}
		for _, ab in ipairs(opts.airbases or _airbases(zonesTbl)) do
			if not logistic[ab] then
				allowed[ab] = true
			end
		end
		local ok, lines = UTILS.LoadFromFile(path, filename)
		if not ok or type(lines) ~= 'table' then return false end
		local byBase = {}
		for i = 2, #lines do
			local row = lines[i]
			if row and row ~= '' then
				local cols = UTILS.Split(row, ';')
				local ab = cols and cols[1]
				local kind = cols and cols[2]
				local name = cols and cols[3]
				local qty = cols and tonumber(cols[4] or '0') or 0
				if ab and allowed[ab] and not logistic[ab] and kind == 'W' and name and qty and not _shouldSkip(ab) then
					byBase[ab] = byBase[ab] or {}
					byBase[ab][name] = qty
				end
			end
		end
		local loaded = 0
		for ab, items in pairs(byBase) do
			local st = STORAGE:FindByName(ab)
			if st and st.SetItem then
				WEAPONSLIST.ClearWeaponsAtAirbase(ab)
				for name, qty in pairs(items) do
					local key = name
					if type(name) == 'string' then
						local a, b, c, d = name:match("^%{%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%}$")
						if a then
							key = { tonumber(a), tonumber(b), tonumber(c), tonumber(d) }
						end
					end
					st:SetItem(key, tonumber(qty) or 0)
				end
				loaded = loaded + 1
			end
		end
if loaded > 0 then trigger.action.outText(string.format('[WarehousePersistence] Loaded %d storages from %s', loaded, tostring(filename)), 10) end
return loaded > 0
	end


	function WarehousePersistence.Start(zonesTbl, opts)
		opts = opts or {}
		if WarehouseLogistics ~= true and opts.force ~= true then return false end
		local loadDelay = tonumber(opts.loadDelay) or 15
		local saveDelay = tonumber(opts.saveDelay) or 30
		local interval = tonumber(opts.interval) or 300
		local function _load()
			WarehousePersistence.Load(zonesTbl or zones, opts)
		end
		local function _save()
			WarehousePersistence.Save(zonesTbl or zones, opts)
		end
		if loadDelay >= 0 then
			if TIMER and TIMER.New then
				TIMER:New(_load):Start(loadDelay)
			else
				SCHEDULER:New(nil, _load, {}, loadDelay)
			end
		else
			_load()
		end
		if saveDelay >= 0 then
			if TIMER and TIMER.New then
				TIMER:New(_save):Start(saveDelay, interval)
			else
				SCHEDULER:New(nil, _save, {}, saveDelay, interval)
			end
		end
		return true
	end
end
function startWarehousePersistence()
	if WarehouseLogistics == true and WarehousePersistence and WarehousePersistence.Start then
		local opts = { loadDelay = 10, saveDelay = 30, interval = 300 }
		if FootholdSavePath then opts.path = FootholdSavePath end
		if FootholdSaveBaseName and tostring(FootholdSaveBaseName) ~= "" then
			opts.filename = tostring(FootholdSaveBaseName) .. "_storage.csv"
		end
		WarehousePersistence.Start(bc, opts)
		trigger.action.outText('WarehousePersistence started', 10)
	end
end


WEAPONSLIST = WEAPONSLIST or {}


if Era == 'Modern' and AllowMods then

WEAPONSLIST.ItemCategory = {
    AA_MISSILES = "AA_MISSILES",
    AG_MISSILES = "AG_MISSILES",
    AG_ROCKETS = "AG_ROCKETS",
    AG_BOMBS = "AG_BOMBS",
    AG_GUIDED_BOMBS = "AG_GUIDED_BOMBS",
    FUEL_TANKS = "FUEL_TANKS",
    MISC = "MISC",
	MODS = "MODS",
    ALL = "ALL",
}

WEAPONSLIST.CategoryOrder = {
    WEAPONSLIST.ItemCategory.AA_MISSILES,
    WEAPONSLIST.ItemCategory.AG_MISSILES,
    WEAPONSLIST.ItemCategory.AG_ROCKETS,
    WEAPONSLIST.ItemCategory.AG_BOMBS,
    WEAPONSLIST.ItemCategory.AG_GUIDED_BOMBS,
    WEAPONSLIST.ItemCategory.FUEL_TANKS,
    WEAPONSLIST.ItemCategory.MISC,
    WEAPONSLIST.ItemCategory.MODS,
}

else

WEAPONSLIST.ItemCategory = {
    AA_MISSILES = "AA_MISSILES",
    AG_MISSILES = "AG_MISSILES",
    AG_ROCKETS = "AG_ROCKETS",
    AG_BOMBS = "AG_BOMBS",
    AG_GUIDED_BOMBS = "AG_GUIDED_BOMBS",
    FUEL_TANKS = "FUEL_TANKS",
	MODS = "MODS",
    MISC = "MISC",
    ALL = "ALL",
}

WEAPONSLIST.CategoryOrder = {
    WEAPONSLIST.ItemCategory.AA_MISSILES,
    WEAPONSLIST.ItemCategory.AG_MISSILES,
    WEAPONSLIST.ItemCategory.AG_ROCKETS,
    WEAPONSLIST.ItemCategory.AG_BOMBS,
    WEAPONSLIST.ItemCategory.AG_GUIDED_BOMBS,
    WEAPONSLIST.ItemCategory.FUEL_TANKS,
    WEAPONSLIST.ItemCategory.MISC,
}

end



WEAPONSLIST.Items = {
[WEAPONSLIST.ItemCategory.AA_MISSILES] = {
    -- AA MISSILES
         'weapons.missiles.CATM_9M',
        'weapons.missiles.Mistral',
        'weapons.missiles.Igla_1E',
        'weapons.missiles.R_550',
        'weapons.missiles.P_60',
        'weapons.missiles.AIM_120C',
        'weapons.missiles.AIM_120',
        'weapons.missiles.P_33E',
        'weapons.missiles.Rb 24',
        'weapons.missiles.Rb 24J',
        'weapons.missiles.Rb 74',
        'weapons.missiles.P_27P',
        'weapons.missiles.AIM-9P',
        'weapons.missiles.AIM_9X',
        'weapons.missiles.P_27PE',
        'weapons.missiles.P_27T',
        'weapons.missiles.P_27TE',
        'weapons.missiles.P_73',
        'weapons.missiles.P_77',
        'weapons.missiles.MICA_T',
        'weapons.missiles.AIM_7',
        'weapons.missiles.AIM_9',
        'weapons.missiles.AIM_54',
        'weapons.missiles.P_24T',
        'weapons.missiles.GAR-8',
        'weapons.missiles.AIM-9P5',
        'weapons.missiles.AIM-9L',
        'weapons.missiles.AIM-7E',
        'weapons.missiles.AIM-7F',
        'weapons.missiles.P_40T',
        'weapons.missiles.AIM-7MH',
        'weapons.missiles.MICA_R',
        'weapons.missiles.PL-5EII',
        'weapons.missiles.SD-10',
        'weapons.missiles.PL-12',
        'weapons.missiles.PL-8B',
        'weapons.missiles.PL-8A',
        'weapons.missiles.AIM_54A_Mk47',
        'weapons.missiles.AIM_54A_Mk60',
        'weapons.missiles.AIM_54C_Mk47',
        'weapons.missiles.MMagicII',
        'weapons.missiles.R-13M',
        'weapons.missiles.R-13M1',
        'weapons.missiles.R-3S',
        'weapons.missiles.R-3R',
        'weapons.missiles.RS2US',
        'weapons.missiles.R-55',
        'weapons.missiles.R-60',
        'weapons.missiles.Matra Super 530D',
        'weapons.missiles.AIM-9J',
        'weapons.missiles.AIM-9JULI',
        'weapons.missiles.R_530F_EM',
        'weapons.missiles.R_530F_IR',
        'weapons.missiles.AIM-7P',
        'weapons.missiles.Super_530D',
        'weapons.missiles.R_550_M1',
        'weapons.missiles.AIM_54C_Mk60',
        'weapons.missiles.Super_530F',
        'weapons.missiles.AIM-7E-2',
        'weapons.missiles.AIM-9P3',
        'weapons.missiles.HB-AIM-7E',
        'weapons.missiles.HB-AIM-7E-2',
        'weapons.missiles.AIM-9E',
        'weapons.missiles.OH58D_FIM_92',
        'weapons.missiles.P_40R',
        'weapons.missiles.P_24R',
    },

[WEAPONSLIST.ItemCategory.AG_MISSILES] = {
    -- AG MISSILES
        'weapons.missiles.TGM_65G',
        'weapons.missiles.HB_AGM_78',
        'weapons.missiles.TGM_65G',
        'weapons.missiles.TGM_65D',
        'weapons.missiles.CATM_65K',
        'weapons.missiles.TGM_65H',
        'weapons.missiles.BK90_MJ1_MJ2',
        'weapons.missiles.Rb 05A',
        'weapons.missiles.Rb_04',
        'weapons.missiles.RB75',
        'weapons.missiles.RB75T',
        'weapons.missiles.RB75B',
        'weapons.missiles.BK90_MJ1',
        'weapons.missiles.BK90_MJ2',
        'weapons.missiles.Rb 04E',
        'weapons.missiles.Rb 15F',
        'weapons.missiles.TOW',
        'weapons.missiles.AGM_154',
        'weapons.missiles.S_25L',
        'weapons.missiles.AGM_65H',
        'weapons.missiles.AGM_65G',
        'weapons.missiles.Rb 15F (for A.I.)',
        'weapons.missiles.Rb 04E (for A.I.)',
        'weapons.missiles.AGM_65F',
        'weapons.missiles.AGM_65L',
        'weapons.missiles.AGM_65A',
        'weapons.missiles.AGM_65B',
        'weapons.missiles.AGM_84D',
        'weapons.missiles.AGM_84H',
        'weapons.missiles.AGM_154A',
        'weapons.missiles.AGM_154B',
        'weapons.missiles.DWS39_MJ1',
        'weapons.missiles.DWS39_MJ2',
        'weapons.missiles.DWS39_MJ1_MJ2',
        'weapons.missiles.Kh25MP_PRGS1VP',
        'weapons.missiles.ADM_141A',
        'weapons.missiles.ADM_141B',
        'weapons.missiles.AGR_20A',
        'weapons.missiles.AGR_20_M282',
        'weapons.missiles.GB-6',
        'weapons.missiles.GB-6-SFW',
        'weapons.missiles.GB-6-HE',
        'weapons.missiles.BRM-1_90MM',
        'weapons.missiles.YJ-83K',
        'weapons.missiles.CM-802AKG',
        'weapons.missiles.LD-10',
        'weapons.missiles.AKD-10',
        'weapons.missiles.Kh-66_Grom',
        'weapons.missiles.Ataka_9M220',
        'weapons.missiles.Ataka_9M120',
        'weapons.missiles.Ataka_9M120F',
        'weapons.missiles.YJ-12',
        'weapons.missiles.C_802AK',
        'weapons.missiles.CM_802AKG',
        'weapons.missiles.AGM_86C',
        'weapons.missiles.AGM_114K',
        'weapons.missiles.AGM_119',
        'weapons.missiles.HOT3_MBDA',
        'weapons.missiles.X_22',
        'weapons.missiles.KD_20',
        'weapons.missiles.C_701T',
        'weapons.missiles.AGM_12B',
        'weapons.missiles.AGM_12A',
        'weapons.missiles.KD_63',
        'weapons.missiles.KD_63B',
        'weapons.missiles.LS_6',
        'weapons.missiles.LS_6_500',
        'weapons.missiles.AGM_45B',
        'weapons.missiles.AGM_78B',
        'weapons.missiles.AGM_78A',
        'weapons.missiles.AGM_12C_ED',
        'weapons.missiles.X_28',
        'weapons.missiles.SPIKE_ER',
        'weapons.missiles.SPIKE_ER2',
        'weapons.missiles.HJ-12',
        'weapons.missiles.CM-400AKG',
        'weapons.missiles.X_25ML',
        'weapons.missiles.X_58',
        'weapons.missiles.X_555',
        'weapons.missiles.X_101',
        'weapons.missiles.C_701IR',
        'weapons.missiles.ASM_N_2',
        'weapons.missiles.X_25MP',
        'weapons.missiles.AT_6',
        'weapons.missiles.X_29L',
        'weapons.missiles.X_65',
        'weapons.missiles.X_31A',
        'weapons.missiles.X_59M',
        'weapons.missiles.X_35',
        'weapons.missiles.X_41',
        'weapons.missiles.Vikhr_M',
        'weapons.missiles.AGM_114',
        'weapons.missiles.AGM_45A',
        'weapons.missiles.AGM_65K',
        'weapons.missiles.AGM_84A',
        'weapons.missiles.AGM_84E',
        'weapons.missiles.AGM_86',
        'weapons.missiles.AGM_88',
        'weapons.missiles.Sea_Eagle',
        'weapons.missiles.AGM_122',
        'weapons.missiles.AGM_65E',
        'weapons.missiles.AGM_130',
        'weapons.missiles.ALARM',
        'weapons.missiles.X_25MR',
        'weapons.missiles.X_29T',
        'weapons.missiles.X_31P',
        'weapons.missiles.AGM_65D',
        'weapons.missiles.Kormoran',
    },


[WEAPONSLIST.ItemCategory.AG_ROCKETS] = {
    -- AG ROCKETS
       'weapons.nurs.ARAKM70BHE',
        'weapons.nurs.ARAKM70BAP',
        'weapons.nurs.ARAKM70BAPPX',
        'weapons.nurs.HYDRA_70_MK1',
        'weapons.nurs.HYDRA_70_MK5',
        'weapons.nurs.HYDRA_70_MK61',
        'weapons.nurs.HYDRA_70_M151',
        'weapons.nurs.HYDRA_70_M156',
        'weapons.nurs.HYDRA_70_WTU1B',
        'weapons.nurs.HYDRA_70_M274',
        'weapons.nurs.HYDRA_70_M257',
        'weapons.nurs.C_8OFP2',
        'weapons.nurs.C_8OM',
        'weapons.nurs.HVAR',
        'weapons.nurs.C_8CM_GN',
        'weapons.nurs.C_8CM_RD',
        'weapons.nurs.C_8CM_WH',
        'weapons.nurs.C_8CM_BU',
        'weapons.nurs.C_8CM_YE',
        'weapons.nurs.C_8CM_VT',
        'weapons.nurs.R4M',
        'weapons.nurs.WGr21',
        'weapons.nurs.M8rocket',
        'weapons.nurs.FFAR Mk1 HE',
        'weapons.nurs.FFAR Mk5 HEAT',
        'weapons.nurs.FFAR M156 WP',
        'weapons.nurs.C_8CM',
        'weapons.nurs.C_5',
        'weapons.nurs.C_8',
        'weapons.nurs.RS-82',
        'weapons.nurs.S5M1_HEFRAG_FFAR',
        'weapons.nurs.C_13',
        'weapons.nurs.S5MO_HEFRAG_FFAR',
        'weapons.nurs.C_24',
        'weapons.nurs.S-5M',
        'weapons.nurs.S-24A',
        'weapons.nurs.S-24B',
        'weapons.nurs.C_25',
        'weapons.nurs.HYDRA_70_M282',
        'weapons.nurs.British_HE_60LBFNo1_3INCHNo1',
        'weapons.nurs.British_HE_60LBSAPNo2_3INCHNo1',
        'weapons.nurs.British_AP_25LBNo1_3INCHNo1',
        'weapons.nurs.ARF8M3HEI',
        'weapons.nurs.ARF8M3API',
        'weapons.nurs.ARF8M3TPSM',
        'weapons.nurs.S-25-O',
        'weapons.nurs.Zuni_127',
        'weapons.nurs.HYDRA_70_M229',
        'weapons.nurs.SNEB_TYPE250_F1B',
        'weapons.nurs.SNEB_TYPE251_F1B',
        'weapons.nurs.SNEB_TYPE251_H1',
        'weapons.nurs.SNEB_TYPE252_F1B',
        'weapons.nurs.SNEB_TYPE252_H1',
        'weapons.nurs.SNEB_TYPE253_F1B',
        'weapons.nurs.SNEB_TYPE253_H1',
        'weapons.nurs.SNEB_TYPE254_F1B_RED',
        'weapons.nurs.SNEB_TYPE254_H1_RED',
        'weapons.nurs.SNEB_TYPE254_F1B_YELLOW',
        'weapons.nurs.SNEB_TYPE254_H1_YELLOW',
        'weapons.nurs.SNEB_TYPE254_F1B_GREEN',
        'weapons.nurs.SNEB_TYPE254_H1_GREEN',
        'weapons.nurs.SNEB_TYPE256_F1B',
        'weapons.nurs.SNEB_TYPE256_H1',
        'weapons.nurs.SNEB_TYPE257_F1B',
        'weapons.nurs.SNEB_TYPE257_H1',
        'weapons.nurs.SNEB_TYPE259E_F1B',
        'weapons.nurs.SNEB_TYPE259E_H1',
        'weapons.nurs.HYDRA_70_M259',
        'weapons.nurs.HYDRA_70_M151_M433',
        'weapons.nurs.FFAR_Mk61',
        'weapons.nurs.S_5KP',
        'weapons.nurs.S_5M',
        'weapons.nurs.Tiny Tim',
        'weapons.nurs.HVAR USN Mk28 Mod4',
        'weapons.nurs.Rkt_90-1_HE',
    },

[WEAPONSLIST.ItemCategory.AG_BOMBS] = {
    -- AG BOMBS (UNGUIDED / CLUSTER / GENERAL)
        'weapons.containers.BRD-4-250',
        'weapons.bombs.BetAB_500',
        'weapons.bombs.BETAB-500S',
        'weapons.bombs.BAP_100',
        'weapons.bombs.BAP-100',
        'weapons.bombs.BetAB_500ShP',
        'weapons.bombs.Type_200A',
        'weapons.bombs.Durandal',
        'weapons.bombs.RBK_250',
        'weapons.bombs.RBK_500AO',
        'weapons.bombs.BL_755',
        'weapons.bombs.AB_250_2_SD_2',
        'weapons.bombs.AB_250_2_SD_10A',
        'weapons.bombs.AB_500_1_SD_10A',
        'weapons.bombs.BLG66',
        'weapons.bombs.RBK_250_275_AO_1SCH',
        'weapons.bombs.RBK_500U_OAB_2_5RT',
        'weapons.bombs.CBU_99',
        'weapons.bombs.BLG66_BELOUGA',
        'weapons.bombs.CBU_97',
        'weapons.bombs.ROCKEYE',
        'weapons.bombs.BLG66_EG',
        'weapons.bombs.BLU-3_GROUP',
        'weapons.bombs.BLU-3B_GROUP',
        'weapons.bombs.BLU-4B_GROUP',
        'weapons.bombs.CBU_87',
        'weapons.bombs.CBU_105',
        'weapons.bombs.CBU_103',
        'weapons.bombs.RBK_500U',
        'weapons.bombs.CBU_52B',
        'weapons.bombs.LYSBOMB 11086',
        'weapons.bombs.LYSBOMB 11087',
        'weapons.bombs.LYSBOMB 11088',
        'weapons.bombs.LYSBOMB 11089',
        'weapons.bombs.SAB_250_200',
        'weapons.bombs.SAB_100MN',
        'weapons.bombs.LUU_2B',
        'weapons.bombs.HEBOMB',
        'weapons.bombs.HEBOMBD',
        'weapons.bombs.SC_50',
        'weapons.bombs.SC_250_T1_L2',
        'weapons.bombs.SC_250_T3_J',
        'weapons.bombs.SC_500_J',
        'weapons.bombs.SC_500_L2',
        'weapons.bombs.SD_250_Stg',
        'weapons.bombs.SD_500_A',
        'weapons.bombs.British_GP_250LB_Bomb_Mk1',
        'weapons.bombs.British_GP_250LB_Bomb_Mk4',
        'weapons.bombs.British_GP_250LB_Bomb_Mk5',
        'weapons.bombs.British_GP_500LB_Bomb_Mk1',
        'weapons.bombs.British_GP_500LB_Bomb_Mk4',
        'weapons.bombs.British_GP_500LB_Bomb_Mk4_Short',
        'weapons.bombs.British_GP_500LB_Bomb_Mk5',
        'weapons.bombs.British_MC_250LB_Bomb_Mk1',
        'weapons.bombs.British_MC_250LB_Bomb_Mk2',
        'weapons.bombs.British_MC_500LB_Bomb_Mk1_Short',
        'weapons.bombs.British_MC_500LB_Bomb_Mk2',
        'weapons.bombs.British_SAP_250LB_Bomb_Mk5',
        'weapons.bombs.British_SAP_500LB_Bomb_Mk5',
        'weapons.bombs.AN_M30A1',
        'weapons.bombs.AN_M57',
        'weapons.bombs.AN_M65',
        'weapons.bombs.AN_M66',
        'weapons.bombs.BEER_BOMB',
        'weapons.bombs.Mk_81',
        'weapons.bombs.Mk_82',
        'weapons.bombs.Mk_82Y',
        'weapons.bombs.Mk_83CT',
        'weapons.bombs.BDU_45',
        'weapons.bombs.BDU_45B',
        'weapons.bombs.BIN_200',
        'weapons.bombs.BR_250',
        'weapons.bombs.BR_500',
        'weapons.bombs.Mk_83',
        'weapons.bombs.FAB_100SV',
        'weapons.bombs.P-50T',
        'weapons.bombs.OFAB-100 Jupiter',
        'weapons.bombs.FAB_50',
        'weapons.bombs.FAB_100M',
        'weapons.bombs.IAB-500',
        'weapons.bombs.RN-24',
        'weapons.bombs.RN-28',
        'weapons.bombs.Mk_84',
        'weapons.bombs.ODAB-500PM',
        'weapons.bombs.FAB-500M54',
        'weapons.bombs.FAB-500TA',
        'weapons.bombs.FAB-500SL',
        'weapons.bombs.FAB-500M54TU',
        'weapons.bombs.OFAB-100-120TU',
        'weapons.bombs.FAB-250M54TU',
        'weapons.bombs.FAB-250M54',
        'weapons.bombs.BETAB-500M',
        'weapons.bombs.M_117',
        'weapons.bombs.250-2',
        'weapons.bombs.250-3',
        'weapons.bombs.FAB-250-M62',
        'weapons.bombs.BAT-120',
        'weapons.bombs.MK76',
        'weapons.bombs.MK106',
        'weapons.bombs.SAMP125LD',
        'weapons.bombs.SAMP250LD',
        'weapons.bombs.SAMP250HD',
        'weapons.bombs.SAMP400LD',
        'weapons.bombs.SAMP400HD',
        'weapons.bombs.Mk_84AIR_GP',
        'weapons.bombs.Mk_84AIR_TP',
        'weapons.bombs.HB_F4E_GBU15V1',
        'weapons.bombs.OH58D_Red_Smoke_Grenade',
        'weapons.bombs.OH58D_Blue_Smoke_Grenade',
        'weapons.bombs.OH58D_Green_Smoke_Grenade',
        'weapons.bombs.OH58D_Violet_Smoke_Grenade',
        'weapons.bombs.OH58D_Yellow_Smoke_Grenade',
        'weapons.bombs.OH58D_White_Smoke_Grenade',
        'weapons.bombs.FAB_100',
        'weapons.bombs.Mk_83AIR',
        'weapons.bombs.FAB_250',
        'weapons.bombs.BDU_33',
        'weapons.bombs.FAB_500',
        'weapons.bombs.BDU_50LD',
        'weapons.bombs.BDU_50HD',
        'weapons.bombs.MK_82AIR',
        'weapons.bombs.MK_82SNAKEYE',
        'weapons.bombs.FAB_1500',
        'weapons.bombs.AN_M64',
		'weapons.bombs.BKF_PTAB2_5KO',

		'weapons.bombs.BKF_AO2_5RT',
    },

[WEAPONSLIST.ItemCategory.AG_GUIDED_BOMBS] = {
    -- AG GUIDED BOMBS
        'weapons.bombs.KAB_500',
        'weapons.bombs.KAB_500Kr',
        'weapons.bombs.KAB_1500Kr',
        'weapons.bombs.KAB_1500T',
        'weapons.bombs.KAB_1500LG',
        'weapons.bombs.KAB_500S',
		'weapons.bombs.KAB_500KrOD',
        'weapons.bombs.GBU_31_V_2B',
        'weapons.bombs.GBU_31_V_4B',
        'weapons.bombs.GBU_32_V_2B',
        'weapons.bombs.GBU_54_V_1B',
        'weapons.bombs.BDU_45LGB',
        'weapons.bombs.GBU_10',
        'weapons.bombs.GBU_12',
        'weapons.bombs.GBU_16',
        'weapons.bombs.GBU_24',
        'weapons.bombs.GBU_15_V_31_B',
        'weapons.bombs.GBU_27',
        'weapons.bombs.AGM_62_I',
        'weapons.bombs.LS_6_100',
        'weapons.bombs.AGM_62',
        'weapons.bombs.GBU_39',
        'weapons.bombs.GBU_8_B',
        'weapons.bombs.GBU_28',
        'weapons.bombs.GBU_15_V_1_B',
        'weapons.bombs.BDU_50LGB',
        'weapons.bombs.GBU_31',
        'weapons.bombs.GBU_38',
        'weapons.bombs.GBU_31_V_3B',
        'weapons.bombs.GBU_43', -- MOAB
    },

[WEAPONSLIST.ItemCategory.FUEL_TANKS] = {
    -- FUEL TANKS
        'weapons.droptanks.fuel_tank_230',
        'weapons.droptanks.HB_A6E_AERO1D_EMPTY',
        'weapons.droptanks.HB_A6E_D704',
        'weapons.droptanks.HB_A6E_AERO1D',
        'weapons.droptanks.PTB_1200_F1',
        'weapons.droptanks.PTB_580G_F1',
        'weapons.droptanks.oiltank',
        'weapons.droptanks.MB339_FT330',
        'weapons.droptanks.MB339_TT500_L',
        'weapons.droptanks.MB339_TT500_R',
        'weapons.droptanks.MB339_TT320_L',
        'weapons.droptanks.MB339_TT320_R',
        'weapons.droptanks.AV8BNA_AERO1D',
        'weapons.droptanks.AV8BNA_AERO1D_EMPTY',
        'weapons.droptanks.M2KC_02_RPL541_EMPTY',
        'weapons.droptanks.M2KC_08_RPL541_EMPTY',
        'weapons.droptanks.M2KC_RPL_522_EMPTY',
        'weapons.droptanks.',
        'weapons.droptanks.F-15E_Drop_Tank',
        'weapons.droptanks.F-15E_Drop_Tank_Empty',
        'weapons.droptanks.HB_F-4E_EXT_WingTank',
        'weapons.droptanks.HB_F-4E_EXT_WingTank_R',
        'weapons.droptanks.HB_F-4E_EXT_Center_Fuel_Tank',
        'weapons.droptanks.HB_HIGH_PERFORMANCE_CENTERLINE_600_GAL',
        'weapons.droptanks.HB_F-4E_EXT_WingTank_EMPTY',
        'weapons.droptanks.HB_F-4E_EXT_WingTank_R_EMPTY',
        'weapons.droptanks.HB_F-4E_EXT_Center_Fuel_Tank_EMPTY',
        'weapons.droptanks.Drop_Tank_300_Liter',
        'weapons.droptanks.FW-190_Fuel-Tank',
        'weapons.droptanks.droptank_108_gal',
        'weapons.droptanks.droptank_110_gal',
        'weapons.droptanks.droptank_150_gal',
        'weapons.droptanks.Spitfire_slipper_tank',
        'weapons.droptanks.Spitfire_tank_1',
        'weapons.droptanks.F4U-1D_Drop_Tank_Aux',
        'weapons.droptanks.F4U-1D_Drop_Tank_Mk5',
        'weapons.droptanks.F4U-1D_Drop_Tank_Mk6',
        'weapons.droptanks.PTB_1500_MIG29A',
        'weapons.droptanks.LNS_VIG_XTANK',
        'weapons.droptanks.800L Tank',
        'weapons.droptanks.1100L Tank',
        'weapons.droptanks.PTB_200_F86F35',
        'weapons.droptanks.PTB_120_F86F35',
        'weapons.droptanks.HB_F14_EXT_DROPTANK_EMPTY',
        'weapons.droptanks.HB_F14_EXT_DROPTANK',
        'weapons.droptanks.FPU_8A',
        'weapons.droptanks.i16_eft',
        'weapons.droptanks.FuelTank_150L',
        'weapons.droptanks.FuelTank_350L',
        'weapons.droptanks.M2KC_02_RPL541',
        'weapons.droptanks.M2KC_08_RPL541',
        'weapons.droptanks.M2KC_RPL_522',
        'weapons.droptanks.PTB400_MIG15',
        'weapons.droptanks.PTB600_MIG15',
        'weapons.droptanks.PTB300_MIG15',
        'weapons.droptanks.PTB400_MIG19',
        'weapons.droptanks.PTB760_MIG19',
        'weapons.droptanks.PTB-490-MIG21',
        'weapons.droptanks.PTB-490C-MIG21',
        'weapons.droptanks.PTB-800-MIG21',
        'weapons.droptanks.Mosquito_Drop_Tank_50gal',
        'weapons.droptanks.Mosquito_Drop_Tank_100gal',
        'weapons.droptanks.PTB-450',
        'weapons.droptanks.800L Tank Empty',
        'weapons.droptanks.1100L Tank Empty',
        'weapons.droptanks.fueltank450',
        'weapons.droptanks.fueltank200',
        'weapons.droptanks.C130J_Ext_Tank_R',
        'weapons.droptanks.C130J_Ext_Tank_L',
        'weapons.droptanks.fueltank230',
        'weapons.droptanks.uh60l_iafts',
    },

[WEAPONSLIST.ItemCategory.MISC] = {
    -- MISC (ADAPTERS / PODS / GUNMOUNTS / OTHER)
		
        'weapons.containers.AAQ-28_LITENING',
        'weapons.containers.MB339_Vinten',
        'weapons.containers.F-15E_AAQ-13_LANTIRN',
        'weapons.containers.F-15E_AAQ-14_LANTIRN',
        'weapons.containers.F-15E_AAQ-28_LITENING',
        'weapons.containers.F-15E_AAQ-33_XR_ATP-SE',
        'weapons.containers.F-15E_AXQ-14_DATALINK',
        'weapons.containers.KINGAL',
        'weapons.containers.ah-64d_radar',
        'weapons.containers.HB_ALE_40_0_0',
        'weapons.containers.HB_ALE_40_0_120',
        'weapons.containers.HB_ALE_40_30_60',
        'weapons.containers.HB_ALE_40_15_90',
        'weapons.containers.HB_ALE_40_30_0',
        'weapons.containers.HB_ORD_Pave_Spike',
        'weapons.containers.HB_ORD_Pave_Spike_Fast',
        'weapons.containers.HB_F14_EXT_TARPS',
        'weapons.containers.HB_F14_EXT_ECA',
        'weapons.containers.LANTIRN',
        'weapons.containers.AN_AAQ_33',
        'weapons.containers.APK-9',
        'weapons.containers.PAVETACK',
        'weapons.containers.ANAWW_13',
        'weapons.containers.aaq-28LEFT litening',
        'weapons.containers.AN_ASQ_228',
        'weapons.containers.dlpod_akg',
        'weapons.containers.wmd7',
        'weapons.containers.{F14-LANTIRN-TP}',
        'weapons.containers.LANTIRN-F14-TARGET',
        'weapons.containers.TANGAZH',
        'weapons.containers.ETHER',
        'weapons.containers.SHPIL',
        'weapons.containers.Fantasm',
        'weapons.containers.F-18-FLIR-POD',
        'weapons.containers.F-18-LDT-POD',
        'weapons.containers.16c_hts_pod',
        'weapons.containers.Spear',
        'weapons.containers.ALQ-184',
        'weapons.containers.SORBCIJA_R',
        'weapons.containers.BARAX',
        'weapons.containers.MATRA-PHIMAT',
        'weapons.containers.HB_F14_EXT_AN_APQ-167',
        'weapons.containers.ALQ-131',
        'weapons.containers.SORBCIJA_L',
        'weapons.containers.U22',
        'weapons.containers.U22A',
        'weapons.containers.SPS-141',
        'weapons.containers.AV8BNA_ALQ164',
        'weapons.containers.SKY_SHADOW',
        'weapons.containers.kg600',
        'weapons.containers.',
        'weapons.containers.SPS-141-100',
        'weapons.containers.{ECM_POD_L_175V}',
        'weapons.containers.MPS-410',
        'weapons.containers.alq-184long',
        'weapons.containers.ais-pod-t50_r',
        'weapons.containers.sa342_dipole_antenna',
        'weapons.containers.MB339_TravelPod',
		'weapons.adapters.MBD-3-LAU-61',
        'weapons.adapters.lau-88',
		'weapons.adapters.MBD-3-LAU-68',
		'weapons.containers.SPRD_99Twin',
        'weapons.containers.FAS',
        'weapons.containers.IRDeflector',
        'weapons.containers.{EclairM_60}',
        'weapons.containers.{EclairM_51}',
        'weapons.containers.{EclairM_42}',
        'weapons.containers.{EclairM_33}',
        'weapons.containers.{EclairM_24}',
        'weapons.containers.{EclairM_15}',
        'weapons.containers.{EclairM_06}',
        'weapons.containers.KBpod',
        'weapons.containers.BOZ-100',
        'weapons.containers.{Eclair}',
        'weapons.containers.ASO-2',
        'weapons.containers.{M2KC_AGF}',
        'weapons.containers.{M2KC_AAF}',
        'weapons.containers.MB339_SMOKE-POD',
        'weapons.containers.{US_M10_SMOKE_TANK_RED}',
        'weapons.containers.{US_M10_SMOKE_TANK_YELLOW}',
        'weapons.containers.{US_M10_SMOKE_TANK_ORANGE}',
        'weapons.containers.{US_M10_SMOKE_TANK_GREEN}',
        'weapons.containers.{US_M10_SMOKE_TANK_BLUE}',
        'weapons.containers.{US_M10_SMOKE_TANK_WHITE}',
        'weapons.containers.{F4U1D_SMOKE_WHITE}',
        'weapons.containers.{SMOKE_WHITE}',
        'weapons.containers.smoke_pod',
        'weapons.containers.{CE2_SMOKE_WHITE}',
        'weapons.containers.HVAR_rocket',
        'weapons.containers.{MIG21_SMOKE_WHITE}',
        'weapons.containers.{MIG21_SMOKE_RED}',
        'weapons.containers.pl5eii',
        'weapons.containers.HB_F14_EXT_BRU34',
        'weapons.containers.F4-PILON',
        'weapons.containers.SPRD-99',
        'weapons.containers.ais-pod-t50',
        'weapons.containers.rightSeat',
        'weapons.containers.leftSeat',
        'weapons.containers.rearCargoSeats',
        'weapons.containers.ais-pod-t50_l',
        'weapons.containers.HB_F14_EXT_LAU-7',
        'weapons.containers.fullCargoSeats',
        'weapons.containers.lau-105',
        'weapons.containers.HB_ORD_MER',
        'weapons.containers.HB_ORD_Missile_Well_Adapter',


        'weapons.shells.KDA_35_FAPDS',
        'weapons.shells.Rh202_20_HE',
        'weapons.shells.Mauser7.92x57_S.m.K.',
        'weapons.shells.Mauser7.92x57_S.m.K._Ub.m.Zerl.',
        'weapons.shells.N37_37x155_HEI_T',
        'weapons.shells.MG_20x82_API',
        'weapons.shells.GSH23_23_AP',
        'weapons.shells.M2_12_7',
        'weapons.shells.L23A1_APFSDS',
        'weapons.shells.DEFA553_30HE',
        'weapons.shells.KS19_100HE',
        'weapons.shells.50Browning_API_M8_Corsair',
        'weapons.shells.MG_13x64_HEI_T',
        'weapons.shells.2A38_30_AP',
        'weapons.shells.20mm_M70LD_SAPHEI',
        'weapons.shells.ZTZ_125_HE',
        'weapons.shells.HP30_30_AP',
        'weapons.shells.M256_120_HE',
        'weapons.shells.7_62x51tr',
        'weapons.shells.AK176_76',
        'weapons.shells.M393A3_105_HE',
        'weapons.shells.M61_20_AP',
        'weapons.shells.DM53_120_AP',
        'weapons.shells.PJ26_76_PFHE',
        'weapons.shells.HEDPM430',
        'weapons.shells.GSH_23_HE',
        'weapons.shells.Hispano_Mk_II_SAP/I',
        'weapons.shells.DEFA554_30_HE',
        'weapons.shells.50Browning_Ball_M2',
        'weapons.shells.50Browning_I_M1',
        'weapons.shells.British303_Ball_Mk8',
        'weapons.shells.ZTZ_7_62',
        'weapons.shells.Mauser7.92x57_B.',
        'weapons.shells.M39_20_HEI',
        "weapons.shells.Mauser7.92x57_S.m.K._L'spur(weiss)",
        'weapons.shells.3UBM11_100mm_AP',
        'weapons.shells.MK_108_MGsch',
        'weapons.shells.ship_Bofors_40mm_HE',
        'weapons.shells.GSh_30_2K_AP_Tr',
        'weapons.shells.M383',
        'weapons.shells.M53_APT_RED',
        'weapons.shells.75mm_AA_JAP',
        'weapons.shells.2A28_73',
        'weapons.shells.GAU8_30_AP',
        'weapons.shells.British303_Ball_Mk1c',
        'weapons.shells.L31_120mm_HESH',
        'weapons.shells.20mm_M53_API',
        'weapons.shells.MINGR55_NO_TRC',
        'weapons.shells.British303_G_Mk4',
        'weapons.shells.CHAP_76_PFHE',
        'weapons.shells.PJ87_100_PFHE',
        'weapons.shells.2A42_30_AP',
        'weapons.shells.37mm_Type_100_JAP',
        'weapons.shells.M2_12_7_T',
        'weapons.shells.2A42_30_HE',
        'weapons.shells.M230_HEI M799',
        'weapons.shells.Sprgr_34_L48',
        'weapons.shells.7_62x39',
        'weapons.shells.GSH23_23_HE',
        'weapons.shells.British303_G_Mk2',
        'weapons.shells.M242_25_AP_M919',
        'weapons.shells.M322_120_AP',
        'weapons.shells.M242_25_HE_M792',
        'weapons.shells.M46',
        'weapons.shells.CHAP_76_HE_T',
        'weapons.shells.2A38_30_HE',
        'weapons.shells.British303_G_Mk5',
        'weapons.shells.M39_20_TP',
        'weapons.shells.GAU8_30_HE',
        'weapons.shells.KDA_35_AP',
        'weapons.shells.CL3143_120_AP',
        'weapons.shells.M61_20_TP_T',
        'weapons.shells.NR23_23x115_API',
        'weapons.shells.KPVT_14_5',
        'weapons.shells.L14A2_30_APDS',
        'weapons.shells.L21A1_30_HE',
        'weapons.shells.GSh_30_2K_HE',
        'weapons.shells.M39_20_API',
        'weapons.shells.2A46M_125_AP',
        'weapons.shells.M61_20_HEIT_RED',
        'weapons.shells.KS19_100AP',
        'weapons.shells.20mm_M56_HEI',
        'weapons.shells.M61',
        'weapons.shells.2A46M_125_HE',
        'weapons.shells.50Browning_T_M1',
        'weapons.shells.NR30_30x155_APT',
        'weapons.shells.AK630_30_AP',
        'weapons.shells.L23_120_AP',
        'weapons.shells.25mm_AA_JAP',
        'weapons.shells.MK_108_HEI',
        'weapons.shells.MG_13x64_I_T',
        'weapons.shells.OF_350',
        'weapons.shells.M134_7_62_T',
        'weapons.shells.DM33_120_AP',
        'weapons.shells.M256_120_HE_L55',
        'weapons.shells.YakB_12_7',
        'weapons.shells.M230_30',
        'weapons.shells.VOG17',
        'weapons.shells.GSh_30_2K_AP',
        'weapons.shells.M61_20_PGU30',
        'weapons.shells.120_EXPL_F1_120mm_HE',
        'weapons.shells.PGU32_SAPHEI_T',
        'weapons.shells.British303_W_Mk1z',
        'weapons.shells.5_56x45_NOtr',
        'weapons.shells.50Browning_API_M8',
        'weapons.shells.5_45x39',
        'weapons.shells.M39_20_HEI_T',
        'weapons.shells.CHAP_125_3BM69_APFSDS_T',
        'weapons.shells.3BM59_125_AP',
        'weapons.shells.6_5mm_Type_91_JAP',
        'weapons.shells.M61_20_PGU28',
        'weapons.shells.NR30_30x155_APHE',
        'weapons.shells.7_7mm_Type_97_JAP',
        'weapons.shells.PINK_PROJECTILE',
        'weapons.shells.CHAP_76_HESH_T',
        'weapons.shells.PKT_7_62',
        'weapons.shells.OFL_120F2_AP',
        'weapons.shells.DM12_L55_120mm_HEAT_MP_T',
        'weapons.shells.British303_O_Mk1',
        'weapons.shells.M256_120_AP',
        'weapons.shells.UOF412_100HE',
        'weapons.shells.M61_20_HE_gr',
        'weapons.shells.M61_20_PGU27',
        'weapons.shells.Utes_12_7x108',
        'weapons.shells.2A7_23_HE',
        'weapons.shells.British303_G_Mk3',
        'weapons.shells.M61_20_AP_gr',
        'weapons.shells.M485_155_IL',
        'weapons.shells.2A64_152',
        'weapons.shells.M61_20_HE',
        'weapons.shells.57mm_Type_90_JAP',
        'weapons.shells.DEFA554_30_HE_TRACERS',
        'weapons.shells.Hispano_Mk_II_MKIIZ_AP',
        'weapons.shells.M256_120_AP_L55',
        'weapons.shells.MG_13x64_HE',
        'weapons.shells.Hispano_Mk_II_Tracer_G',
        'weapons.shells.20mm_M220_Tracer',
        'weapons.shells.Bofors_40mm_Essex',
        'weapons.shells.MG_13x64_I',
        'weapons.shells.Pzgr_39/40',
        'weapons.shells.2A60_120',
        'weapons.shells.MK_108_MGsch_T',
        'weapons.shells.HP30_30_HE',
        'weapons.shells.L31A7_HESH',
        'weapons.shells.GSH301_30_AP',
        'weapons.shells.M55A2_TP_RED',
        'weapons.shells.MG_13x64_API',
        'weapons.shells.DM23_105_AP',
        'weapons.shells.Bofors_40mm_HE',
        'weapons.shells.7_62x54',
        'weapons.shells.DM12_120mm_HEAT_MP_T',
        'weapons.shells.DEFA553_30AP',
        'weapons.shells.76mm_AA_JAP',
        'weapons.shells.PLZ_155_HE',
        'weapons.shells.GSH301_30_HE',
        'weapons.shells.Br303',
        'weapons.shells.DANA_152',
        'weapons.shells.MK45_127',
        'weapons.shells.M230_TP M788',
        'weapons.shells.Utes_12_7x108_T',
        'weapons.shells.7_92x57sS',
        'weapons.shells.M20_50_aero_APIT',
        'weapons.shells.20MM_M242_HEI-T',
        'weapons.shells.M339_120mm_HEAT_MP_T',
        'weapons.shells.M68_105_HE',
        'weapons.shells.50Browning_APIT_M20',
        'weapons.shells.M197_20',
        'weapons.shells.KDA_35_HE',
        'weapons.shells.British303_Ball_Mk6',
        'weapons.shells.7_62x54_NOTRACER',
        'weapons.shells.ZTZ_14_5',
        'weapons.shells.A222_130',
        'weapons.shells.50Browning_AP_M2_Corsair',
        'weapons.shells.M68_105_AP',
        'weapons.shells.Mauser7.92x57_S.m.K.H.',
        'weapons.shells.BR_354N',
        'weapons.shells.British303_G_Mk6z',
        'weapons.shells.KPVT_14_5_T',
        'weapons.shells.NR23_23x115_HEI_T',
        'weapons.shells.M56A3_HE_RED',
        'weapons.shells.GSh_30_2K_HE_Tr',
        'weapons.shells.K307_155HE',
        'weapons.shells.Oerlikon_20mm_Essex',
        'weapons.shells.HESH_105',
        'weapons.shells.M242_25_AP_M791',
        'weapons.shells.BK_27',
        'weapons.shells.M185_155',
        'weapons.shells.British303_B_Mk4z',
        'weapons.shells.M246_20_HE_gr',
        'weapons.shells.Hispano_Mk_II_MKI_HE/I',
        'weapons.shells.2A7_23_AP',
        'weapons.shells.MG_13x64_APT',
        'weapons.shells.M2_50_aero_AP',
        'weapons.shells.2A18_122',
        'weapons.shells.YakB_12_7_T',
        'weapons.shells.N37_37x155_API_T',
        'weapons.shells.MG_20x82_MGsch',
        'weapons.shells.British303_G_Mk1',
        'weapons.shells.M53_AP_RED',
        'weapons.shells.British303_Ball_Mk7',
        'weapons.shells.7_62x51',
        'weapons.shells.Hispano_Mk_II_AP/T',
        'weapons.shells.GSH_23_AP',
        'weapons.shells.MK75_76',
        'weapons.shells.50Browning_Ball_M2_Corsair',
        'weapons.shells.GAU8_30_TP',
        'weapons.shells.MK45_127mm_AP_Essex',
        'weapons.shells.NR30_30x155_HEI_T',
        'weapons.shells.PKT_7_62_T',
        'weapons.shells.7_92x57_Smkl',
        'weapons.shells.M2_12_7_TG',
        'weapons.shells.M230_ADEM/DEFA',
        'weapons.shells.9x19_m882',
        'weapons.shells.2A33_152',
        'weapons.shells.M825A1_155_SM',
        'weapons.shells.53-UBR-281U',
        'weapons.shells.MINGR55',
        'weapons.shells.MK45_127mm_Essex',
        'weapons.shells.MAUZER30_30',
        'weapons.shells.MG_20x82_HEI_T',
        'weapons.shells.DEFA552_30',
        'weapons.shells.50Browning_AP_M2',
        'weapons.shells.5_56x45',
        'weapons.shells.M61_20_TP',
        'weapons.shells.AK100_100',
        'weapons.shells.53-UOR-281U',
        'weapons.shells.ZTZ_125_AP',
        'weapons.shells.50Browning_APIT_M20_Corsair',
        'weapons.shells.British303_B_Mk6z',
        'weapons.shells.M61_20_HE_INVIS',
        'weapons.shells.M230_HEDP M789',
        'weapons.shells.Rh202_20_AP',
        'weapons.shells.Br303_tr',
        'weapons.shells.UOF_17_100HE',
        'weapons.shells.5_45x39_NOtr',
        'weapons.shells.GSH23_23_HE_T',
        'weapons.shells.AK630_30_HE',
        'weapons.shells.Flak18_Sprgr_39',
        "weapons.shells.Mauser7.92x57_S.m.K._L'spur(gelb)",
        'weapons.shells.DEFA553_30APIT',
        "weapons.shells.Mauser7.92x57_P.m.K.",
        'weapons.shells.Hispano_Mk_II_Mk_Z_Ball',
        'weapons.shells.Oerlikon_20mm_HE',
        'weapons.shells.HE_T_MkII_40mm',
        'weapons.shells.RM_15cm_HE',
        'weapons.shells.Mk_20_HE_shell',
        'weapons.shells.Flak41_Sprgr_39',
        'weapons.shells.Pzgr_39/42',
        'weapons.shells.M1_37mm_37AP-T',
        'weapons.shells.Pzgr_39_5cm',
        'weapons.shells.Sprgr_38',
        'weapons.shells.Pzgr_39/43',
        'weapons.shells.Sprgr_39',
        'weapons.shells.37x263_AP',
        'weapons.shells.20x138B_AP',
        'weapons.shells.Besa7_92x57T',
        'weapons.shells.Sprgr_34_L70',
        'weapons.shells.QF94_AA_HE',
        'weapons.shells.M63_37HE',
        'weapons.shells.QF95_206R_fixed',
        'weapons.shells.UBR_365_85AP',
        'weapons.shells.M101',
        'weapons.shells.HE_M1_Shell',
        'weapons.shells.M42A1_HE',
        'weapons.shells.UO_365K_85HE',
        'weapons.shells.M1_37mm_HE-T',
        'weapons.shells.QF17_HE',
        'weapons.shells.2A20_115mm_HE',
        'weapons.shells.Pzgr_39',
        'weapons.shells.2A20_115mm_AP',
        'weapons.shells.Besa7_92x57',
        'weapons.shells.leFH18_105HE',
        'weapons.shells.I_Gr_33',
        'weapons.shells.Sprgr_43_L71',
        'weapons.shells.M62_APC',
        'weapons.shells.APCBC',
        'weapons.shells.20x138B_HE',
        'weapons.shells.AP_T_MkI_40mm',
        'weapons.shells.Mk_12_HE_shell',
        'weapons.shells.M51_37AP',
        'weapons.shells.37x263_HE',



        'weapons.gunmounts.NR-30',
        'weapons.gunmounts.{MB339_ANM3_L}',
        'weapons.gunmounts.OH58D_M3P_L500',
        'weapons.gunmounts.C130_M4_Rifle',
        'weapons.gunmounts.{C130-M18-Sidearm}',
        'weapons.gunmounts.MINIGUN',
        'weapons.gunmounts.{GIAT_M621_SAPHEI}',
        'weapons.gunmounts.{C130-Cargo-Bay-M4}',
        'weapons.gunmounts.{CC420_GUN_POD}',
        'weapons.gunmounts.{MB339_DEFA553_R}',
        'weapons.gunmounts.PKT_7_62',
        'weapons.gunmounts.{UH60_GAU19_LEFT}',
        'weapons.gunmounts.defa_553',
        'weapons.gunmounts.{CH47_STBD_M60D}',
        'weapons.gunmounts.N-37',
        'weapons.gunmounts.{CH47_AFT_M60D}',
        'weapons.gunmounts.M-61A1',
        'weapons.gunmounts.UH60L_M134',
        'weapons.gunmounts.{AN-M3}',
        'weapons.gunmounts.NR-23',
        'weapons.gunmounts.UPK_23_25',
        'weapons.gunmounts.{UH60L_M134_GUNNER}',
        'weapons.gunmounts.{SUU_23_POD}',
        'weapons.gunmounts.{SA342_M134_SIDE_R}',
        'weapons.gunmounts.HMP400',
        'weapons.gunmounts.M134_R',
        'weapons.gunmounts.OH_58_BRAUNING',
        'weapons.gunmounts.{UH60L_M60_GUNNER}',
        'weapons.gunmounts.M60_SIDE_L',
        'weapons.gunmounts.KORD_12_7_MI24_R',
        'weapons.gunmounts.KORD_12_7_MI24_L',
        'weapons.gunmounts.M60_SIDE_R',
        'weapons.gunmounts.{GAU_12_Equalizer_HE}',
        'weapons.gunmounts.{FN_HMP400_100}',
        'weapons.gunmounts.MG_151_20',
        'weapons.gunmounts.C130_M18_Sidearm',
        'weapons.gunmounts.m3_browning',
        'weapons.gunmounts.{AKAN_NO_TRC}',
        'weapons.gunmounts.A20_TopTurret_M2_R',
        'weapons.gunmounts.MG_131',
        'weapons.gunmounts.GUV_VOG',
        'weapons.gunmounts.GIAT_M261',
        'weapons.gunmounts.GSh-23-2 tail defense',
        'weapons.gunmounts.HispanoMkII',
        'weapons.gunmounts.{ADEN_GUNPOD}',
        'weapons.gunmounts.OH58D_M3P',
        'weapons.gunmounts.{GAU_12_Equalizer}',
        'weapons.gunmounts.CPG_M4',
        'weapons.gunmounts.M134_L',
        'weapons.gunmounts.{UH60_M134_LEFT}',
        'weapons.gunmounts.{UH60_M230_RIGHT}',
        'weapons.gunmounts.M134_SIDE_R',
        'weapons.gunmounts.UH-60L GAU-19',
        'weapons.gunmounts.{AKAN}',
        'weapons.gunmounts.GAU_12',
        'weapons.gunmounts.OH58D_M3P_L300',
        'weapons.gunmounts.{GAU_12_Equalizer_AP}',
        'weapons.gunmounts.{MB339_ANM3_R}',
        'weapons.gunmounts.MK_108',
        'weapons.gunmounts.UH60_M134',
        'weapons.gunmounts.OH58D_M3P_L100',
        'weapons.gunmounts.{CH47_PORT_M240H}',
        'weapons.gunmounts.{GIAT_M621_HEAP}',
        'weapons.gunmounts.{GIAT_M621_HE}',
        'weapons.gunmounts.SPPU_22',
        'weapons.gunmounts.{FN_HMP400_200}',
        'weapons.gunmounts.{PK-3}',
        'weapons.gunmounts.A20_TopTurret_M2_L',
        'weapons.gunmounts.{UH60_GAU19_RIGHT}',
        'weapons.gunmounts.{CH47_PORT_M134D}',
        'weapons.gunmounts.{GIAT_M621_AP}',
        'weapons.gunmounts.AKAN_NO_TRC',
        'weapons.gunmounts.BrowningM2',
        'weapons.gunmounts.{CH47_AFT_M240H}',
        'weapons.gunmounts.OH58D_M3P_L400',
        'weapons.gunmounts.M230',
        'weapons.gunmounts.{MB339_DEFA553_L}',
        'weapons.gunmounts.M-61',
        'weapons.gunmounts.GSH_23',
        'weapons.gunmounts.M134_SIDE_L',
        'weapons.gunmounts.GUV_YakB_GSHP',
        'weapons.gunmounts.KORD_12_7',
        'weapons.gunmounts.AKAN',
        'weapons.gunmounts.Browning303MkII',
        'weapons.gunmounts.DEFA_553',
        'weapons.gunmounts.{C-101-DEFA553}',
        'weapons.gunmounts.{CH47_STBD_M240H}',
        'weapons.gunmounts.{UH60_M134_RIGHT}',
        'weapons.gunmounts.{FN_HMP400}',
        'weapons.gunmounts.{GIAT_M621_APHE}',
        'weapons.gunmounts.SHKAS_GUN',
        'weapons.gunmounts.{UH60_M230_LEFT}',
        'weapons.gunmounts.{CH47_AFT_M3M}',
        'weapons.gunmounts.OH58D_M3P_L200',
        'weapons.gunmounts.{CH47_PORT_M60D}',
        'weapons.gunmounts.DEFA 554',
        'weapons.gunmounts.{UH60L_M2_GUNNER}',
        'weapons.gunmounts.{CH47_STBD_M134D}',
		'weapons.gunmounts.B17_TailTurret_M2_L',
		'weapons.gunmounts.B17_BallTurret_M2_L',
		'weapons.gunmounts.B17_BallTurret_M2_R',
		'weapons.gunmounts.B17_TopTurret_M2_R',
		'weapons.gunmounts.B17_Waist_Right_M2',
		'weapons.gunmounts.Ju88_Turret_Top_Right_MG_81',
		'weapons.gunmounts.Ju88_Turret_Bottom_MG_81_L',
		'weapons.gunmounts.B17_ChinTurret_M2_L',
		'weapons.gunmounts.B17_ChinTurret_M2_R',
		'weapons.gunmounts.B17_Right_Nose_M2',
		'weapons.gunmounts.Ju88_Turret_Bottom_MG_81_R',
		'weapons.gunmounts.Ju88_Turret_ahead_MG_81',
		'weapons.gunmounts.B17_Waist_Left_M2',
		'weapons.gunmounts.B17_TailTurret_M2_R',
		'weapons.gunmounts.B17_Left_Nose_M2',
		'weapons.gunmounts.Ju88_Turret_Top_Left_MG_81',
		'weapons.gunmounts.B17_TopTurret_M2_L',
		'weapons.adapters.B-8V20A',
		'weapons.torpedoes.G7A_T1',
		'weapons.torpedoes.YU-6',
		'weapons.torpedoes.Mark_46',
		'weapons.torpedoes.mk46torp_name',
		'weapons.torpedoes.LTF_5B',

		{4,15,46,2492},
		{4,15,46,2491},
		{4,15,46,2490},	
		{4,15,46,2489},
		{4,15,46,2488},
		{4,15,46,2493},
		{4,15,46,2494},
		{4,15,46,2495},
		{4,15,46,20},
		{4,5,32,95},
		{4,5,32,94},
		{4,15,46,2611},
		{4,15,46,2610},
		{4,15,46,2609},
		{4,15,46,2608},
		{4,15,46,2607},
		{4,15,46,18},
		{4,15,46,183},
		{4,15,46,1771},
		{4,15,46,1294},
		{4,15,46,1295},
		{4,15,46,1770},
		{4,15,46,1769},
		{4,15,46,1768},
		{4,15,46,1767},
		{4,15,46,1766},
		{4,15,46,1765},
		{4,15,46,1764},
		{4,15,46,1057},
		{4,15,46,160},
		{4,15,46,161},
		{4,15,46,170},
		{4,15,46,171},
		{4,15,46,174},
		{4,15,46,175},
		{4,15,46,176},
		{4,15,46,177},
		{4,15,46,184},
		{4,15,46,3169},
		{4,15,46,3102},
		{4,15,46,3163},
		{4,15,46,3164},
		{4,15,46,3165},
		{4,15,46,3166},
		{4,15,46,3167},
		{4,15,46,3168},
		{4,15,46,3170},
		{4,15,46,3171},

		-- little bird

		{1,3,43,464},
		{4,15,46,3155},
		{4,15,46,3156},
		{4,15,46,3157},
		{4,15,46,3158},
		{4,15,46,3172},
		{4,15,46,3173},
		{4,15,46,3174},
		{4,15,46,3175},
		{4,15,46,3176},
		{4,15,46,3177},
		{4,15,46,3178},
		{4,15,46,3179},
		{4,15,46,3180},
		{4,4,8,11209},
		{4,4,8,11210},
		{4,4,8,11211},
		{4,4,8,11212},
		{1,3,43,3159},
		"weapons.bombs.AH6_SMOKE_RED",
		"weapons.bombs.AH6_SMOKE_GREEN",
		"weapons.bombs.AH6_SMOKE_YELLOW",
		"weapons.bombs.AH6_SMOKE_BLUE",

    },
}

local WEAPONSLIST_MODS_ITEMS = {
		-- FUEL TANKS
		'weapons.adapters.HB_F-4E_ORD_LAU_77',
		'weapons.adapters.hb_a-6e_lau7_adu299',
		'weapons.adapters.UB-13',
		'weapons.adapters.APU-60-1',
		'weapons.adapters.M-2000C_AUF2',
		'weapons.adapters.Carrier_N-1_EM_EF',
		'weapons.adapters.RB15pylon',
		'weapons.adapters.UB_32A',
		'weapons.adapters.OH58D_M260',
		'weapons.adapters.HB_F14_EXT_SHOULDER_PHX_L',
		'weapons.adapters.sa342_ATAM_Tube_2x',
		'weapons.adapters.CHAP_Mi28N_ataka',
		'weapons.adapters.B-8V20A',
		'weapons.adapters.apu-13mt',
		'weapons.adapters.HB_ORD_Missile_Well_Adapter',
		'weapons.adapters.KMGU-2',
		'weapons.adapters.9M114-PYLON_EMPTY',
		'weapons.adapters.adapter_gdj_kd63',
		'weapons.adapters.LAU-117',
		'weapons.adapters.Spitfire_pilon2L',
		'weapons.adapters.adapter_df4b',
		'weapons.adapters.b52-mbd_mk84',
		'weapons.adapters.J-11A_twinpylon_l',
		'weapons.adapters.aero-3b',
		'weapons.adapters.F4-PILON',
		'weapons.adapters.mbd-4',
		'weapons.adapters.m559',
		'weapons.adapters.BRU-42_LS_(LAU-131)',
		'weapons.adapters.LAU-61',
		'weapons.adapters.mer2',
		'weapons.adapters.30-6-M2',
		'weapons.adapters.LAU-10',
		'weapons.adapters.HB_F14_EXT_LAU-7',
		'weapons.adapters.PU_9S846_STRELEC',
		'weapons.adapters.b-52_CSRL_ALCM',
		'weapons.adapters.9M114-PILON',
		'weapons.adapters.CLB_4',
		'weapons.adapters.CHAP_Mi28N_igla',
		'weapons.adapters.hj12-launcher-tube',
		'weapons.adapters.9m114-pilon',
		'weapons.adapters.b52-mbd_m117',
		'weapons.adapters.OH58D_HRACK_R',
		'weapons.adapters.F4E_dual_LAU7',
		'weapons.adapters.HB_F14_EXT_SPARROW_PYLON',
		'weapons.adapters.tu-22m3-mbd',
		'weapons.adapters.HB_F-4E_BRU-42',
		'weapons.adapters.MBD-2-67',
		'weapons.adapters.OH58D_SRACK_R',
		'weapons.adapters.UB-16',
		'weapons.adapters.APU-170',
		'weapons.adapters.adapter_df4a',
		'weapons.adapters.Rocket_Launcher_4_5inch',
		'weapons.adapters.JF-17_PF12_twin',
		'weapons.adapters.CLB_30',
		'weapons.adapters.9M120_pylon',
		'weapons.adapters.oro-57k.edm',
		'weapons.adapters.suu-25',
		'weapons.adapters.LAU-3',
		'weapons.adapters.F-15E_LAU-117',
		'weapons.adapters.SA342_LAU_HOT3_2x',
		'weapons.adapters.Schloss_500XIIC',
		'weapons.adapters.mbd-3',
		'weapons.adapters.b52-mbd_agm86',
		'weapons.adapters.Spitfire_pilon2R',
		'weapons.adapters.apu-60-2_R',
		'weapons.adapters.MER-5E',
		'weapons.adapters.gdj-iv1',
		'weapons.adapters.14-3-M2',
		'weapons.adapters.OH-58D_Gorgona',
		'weapons.adapters.ARAKM70B',
		'weapons.adapters.apu-6',
		'weapons.adapters.BRU-42_LS',
		'weapons.adapters.M299_AGM114',
		'weapons.adapters.BRU-42_LS_(LAU-68)',
		'weapons.adapters.B-1B_Conventional_Rotary_Launcher',
		'weapons.adapters.LAU-105',
		'weapons.adapters.ER4_Rack',
		'weapons.adapters.lau-118a',
		'weapons.adapters.b-52_suu67',
		'weapons.adapters.JF-17_GDJ-II19L',
		'weapons.adapters.AUF2_RACK',
		'weapons.adapters.kmgu-2',
		'weapons.adapters.JF-17_GDJ-II19R',
		'weapons.adapters.F-15E_LAU-88',
		'weapons.adapters.9k121',
		'weapons.adapters.MAK-79_VAR_4',
		'weapons.adapters.BRU_42A',
		'weapons.adapters.APU-12-40',
		'weapons.adapters.HB_F14_EXT_BRU34',
		'weapons.adapters.apu-13u-2',
		'weapons.adapters.UB-32',
		'weapons.adapters.HB_ORD_LAU-88',
		'weapons.adapters.ptab-2_5ko_block1',
		'weapons.adapters.XM158',
		'weapons.adapters.CBLS-200',
		'weapons.adapters.ao-2_5rt_block1',
		'weapons.adapters.MAK-79_VAR_2',
		'weapons.adapters.UB_32A_24',
		'weapons.adapters.tow-pilon',
		'weapons.adapters.apu-7',
		'weapons.adapters.BRU-42_HS',
		'weapons.adapters.TER-9A',
		'weapons.adapters.LAU-115C',
		'weapons.adapters.M-2000C_LRF4.edm',
		'weapons.adapters.su-27-twinpylon',
		'weapons.adapters.BRU_33A',
		'weapons.adapters.T45_PMBR',
		'weapons.adapters.M-2000c_BAP_Rack',
		'weapons.adapters.apu-60-2_L',
		'weapons.adapters.BRD-4-250',
		'weapons.adapters.lau-117',
		'weapons.adapters.uh60l_lwl12',
		'weapons.adapters.HB_ORD_SUU_7',
		'weapons.adapters.9m120',
		'weapons.adapters.APU-68',
		'weapons.adapters.OH58D_HRACK_L',
		'weapons.adapters.APU-73',
		'weapons.adapters.CHAP_Tu95MS_rotary_launcher',
		'weapons.adapters.MAK-79_VAR_3',
		'weapons.adapters.hf20_pod',
		'weapons.adapters.LAU_127',
		'weapons.adapters.M272_AGM114',
		'weapons.adapters.M272',
		'weapons.adapters.HB_F14_EXT_SHOULDER_PHX_R',
		'weapons.adapters.rb04pylon',
		'weapons.adapters.M-2000C_LRF4',
		'weapons.adapters.mbd',
		'weapons.adapters.PylonM71',
		'weapons.adapters.b-52_CRL_mod1',
		'weapons.adapters.9K114_Shturm',
		'weapons.adapters.f4-pilon',
		'weapons.adapters.M261',
		'weapons.adapters.B-20',
		'weapons.adapters.BR21-Gerat',
		'weapons.adapters.LAU-68',
		'weapons.adapters.HB_F-4E_LAU-34',
		'weapons.adapters.LR-25',
		'weapons.adapters.b-52_HSAB',
		'weapons.adapters.BRU_57',
		'weapons.adapters.MAK-79_VAR_1',
		'weapons.adapters.SA342_Telson8',
		'weapons.adapters.LAU-115C+2_LAU127',
		'weapons.adapters.BRU-42_LS_(SUU-25)',
		'weapons.adapters.9M120_pylon2',
		'weapons.adapters.LAU-131',
		'weapons.adapters.apu-68um3',
		'weapons.adapters.OH58D_SRACK_L',
		'weapons.adapters.rb05pylon',
		'weapons.adapters.B-1B_28-store_Conventional_Bomb_Module',
		'weapons.adapters.C-25PU',
		'weapons.adapters.HB_F4E_LAU117',
		'weapons.adapters.UB-16-57UMP',
		'weapons.adapters.mbd3-u6-68',
		'weapons.adapters.b-20',
		'weapons.adapters.c-25pu',
		'weapons.adapters.Matra-F1-Rocket',
		'weapons.adapters.J-11A_twinpylon_r',
		'weapons.adapters.M299',
		'weapons.adapters.Spitfire_pilon1',
		'weapons.adapters.adapter_gdj_yj83k',
		'weapons.adapters.HB_ORD_MER',
		'weapons.adapters.9m114_pylon2',
		'weapons.adapters.boz-100',
		'weapons.adapters.BRU_55',
		'weapons.adapters.lau-105',
		'weapons.adapters.apu-68m3',
		'weapons.adapters.B-1B_10-store_Conventional_Bomb_Module',
		'weapons.adapters.AKU-58',
		'weapons.adapters.HB_F14_EXT_BRU42',
		'weapons.adapters.SA342_LAU_HOT3_1x',
		'weapons.adapters.MBD-2-67U',
		'weapons.adapters.BRU_41A',
		'weapons.adapters.9m120m',
		'weapons.adapters.M260',
		'weapons.missiles.HQ-16',
		'weapons.missiles.MALUTKA',
		'weapons.missiles.SM_6',
		'weapons.missiles.Sea_Dart',
		'weapons.missiles.SA48H6E2',
		'weapons.missiles.Sea_Cat',
		'weapons.missiles.FIM_92C',
		'weapons.missiles.SM_2ER',
		'weapons.missiles.SA9M338K',
		'weapons.missiles.M39A1',
		'weapons.missiles.SA3M9M',
		'weapons.missiles.HQ-7B',
		'weapons.missiles.SA5B55',
		'weapons.missiles.9M723',
		'weapons.missiles.SVIR',
		'weapons.missiles.REFLEX',
		'weapons.missiles.HOT2',
		'weapons.missiles.Rapier',
		'weapons.missiles.YJ-83',
		'weapons.missiles.BGM_109B',
		'weapons.missiles.ROLAND_R',
		'weapons.missiles.SPIKE_ERA',
		'weapons.missiles.TOW2',
		'weapons.missiles.SA9M333',
		'weapons.missiles.P_9M133',
		'weapons.missiles.RIM_116A',
		'weapons.missiles.Sea_Wolf',
		'weapons.missiles.M30',
		'weapons.missiles.SA_IRIS_T_SL',
		'weapons.missiles.9M317',
		'weapons.missiles.SA9M31',
		'weapons.missiles.HHQ-9',
		'weapons.missiles.MIM_104',
		'weapons.missiles.SM_1',
		'weapons.missiles.HAWK_RAKETA',
		'weapons.missiles.HY-2',
		'weapons.missiles.SA57E6',
		'weapons.missiles.P_500',
		'weapons.missiles.9M723_HE',
		'weapons.missiles.SA2V755',
		'weapons.missiles.SCUD_RAKETA',
		'weapons.missiles.SA9M38M1',
		'weapons.missiles.SA9M33',
		'weapons.missiles.SA5B27',
		'weapons.missiles.M31',
		'weapons.missiles.SM_2',
		'weapons.missiles.KONKURS',
		'weapons.missiles.SA9M311',
		'weapons.missiles.P_700',
		'weapons.missiles.MIM_72G',
		'weapons.missiles.SeaSparrow',
		'weapons.missiles.SA9M330',
		'weapons.missiles.M48',
		'weapons.missiles.YJ-62',
		'weapons.missiles.P_9M117',
		'weapons.missiles.SA5V28',
		'weapons.missiles.AGM_84S',
		'weapons.missiles.X_29TE',
		'weapons.missiles.YJ-82',
		'weapons.missiles.Barrel',
		'weapons.nurs.SMERCH_9M55F',
		'weapons.nurs.M26',
		'weapons.nurs.AGR_20_M282_unguided',
		'weapons.nurs.AGR_20_M151_unguided',
		'weapons.nurs.BRM1_90MM_UG',
		'weapons.nurs.PG_9V',
		'weapons.nurs.PG_16V',
		'weapons.nurs.GRAD_9M22U',
		'weapons.nurs.URAGAN_9M27F',
		'weapons.nurs.M26HE',
		'weapons.nurs.SMERCH_9M55K',
		'weapons.nurs.MO_10104M',
		'weapons.bombs.M485_FLARE',
		'weapons.bombs.GBU_30',
		'weapons.bombs.S_8OM_FLARE',
		'weapons.bombs.RBK_500SOAB',
		'weapons.bombs.RBK_500U_BETAB_M',
		'weapons.bombs.SAB_100_FLARE',
		'weapons.bombs.AO_2_5RT',
		'weapons.bombs.GBU_11',
		'weapons.bombs.LUU_2BB',
		'weapons.bombs.RBK_250S',
		'weapons.bombs.PTAB_2_5KO',
		'weapons.bombs.GBU_17',
		'weapons.bombs.LUU_19',
		'weapons.bombs.AH6_SMOKE_BLUE',
		'weapons.bombs.AH6_SMOKE_GREEN',
		'weapons.bombs.AH6_SMOKE_RED',
		'weapons.bombs.AH6_SMOKE_YELLOW',

		'weapons.bombs.M257_FLARE',
		'weapons.bombs.LYSBOMB_CANDLE',
		'weapons.bombs.SAB_250_FLARE',
		'weapons.bombs.GBU_29',
		'weapons.bombs.LUU_2AB',
		'weapons.adapters.aku-58',
		'weapons.adapters.AMBER',
		'weapons.adapters.BRU_33AA',
		'weapons.adapters.f-15ex_pylon1',
		'weapons.adapters.jas39_arakm70b',
		'weapons.adapters.jas39_brimstone_triple_rack',
		'weapons.adapters.jas39_bru_61',
		'weapons.adapters.jas39_PylonM71',
		'weapons.adapters.jas39_spear_triple_rack',
		'weapons.adapters.Lau_33_A',
		'weapons.adapters.lau-131',
		'weapons.adapters.lau-61',
		'weapons.adapters.LWL_12',
		'weapons.adapters.null',
		'weapons.adapters.OH-6_XM158',
		'weapons.adapters.PAMC',
		'weapons.adapters.placeholder',
		'weapons.adapters.STA02_SUU80+SUU79+SUU79_OFFSET_RACK',
		'weapons.adapters.STA03_SUU80+SUU79+SUU79_OFFSET_RACK',
		'weapons.adapters.STA09_SUU80+SUU79+SUU79_OFFSET_RACK',
		'weapons.adapters.STA10_SUU80+SUU79+SUU79_OFFSET_RACK',
		'weapons.adapters.TLAU_127',
		'weapons.adapters.TWP_35',
		'weapons.adapters.WingLauncher',
		'weapons.bombs.jas_gbu-31',
		'weapons.bombs.jas_gbu-31_blu109',
		'weapons.bombs.jas_gbu-32',
		'weapons.bombs.jas_gbu-38',
		'weapons.bombs.jas_gbu-49',
		'weapons.bombs.jas_sdb',
		'weapons.bombs.jas39_gbu-10',
		'weapons.bombs.jas39_gbu-12',
		'weapons.bombs.jas39_gbu-16',
		'weapons.bombs.M71HD',
		'weapons.bombs.M71LD',
		'weapons.bombs.Mk-82 500 lb GP Bomb',
		'weapons.bombs.Mk-83 1000 lb GP Bomb',
		'weapons.bombs.Mk-84 2000 lb GP Bomb',
		'weapons.bombs.OH6_FRAG',
		'weapons.bombs.OH6_SMOKE_BLUE',
		'weapons.bombs.OH6_SMOKE_GREEN',
		'weapons.bombs.OH6_SMOKE_RED',
		'weapons.bombs.OH6_SMOKE_YELLOW',
		'weapons.droptanks.A-29B TANK',
		'weapons.droptanks.AA42R',
		'weapons.droptanks.Bidon',
		'weapons.droptanks.Drop tank 1100 litre',
		'weapons.droptanks.DUMMY_STORE',
		'weapons.droptanks.F-15EX Mods',
		'weapons.droptanks.F22_LDTP',
		'weapons.droptanks.FPU_12_FUEL_TANK',
		'weapons.droptanks.FPU_12_FUEL_TANKHighVis',
		'weapons.gunmounts.bk_27',
		'weapons.gunmounts.M_60',
		'weapons.gunmounts.MG_20',
		'weapons.gunmounts.Mk11mod0',
		'weapons.gunmounts.OH-6_M134',
		'weapons.gunmounts.OH-6_M134_Door',
		'weapons.gunmounts.OH-6_M60_Door',
		'weapons.gunmounts.{OH-6_M134_Minigun1}',
		'weapons.gunmounts.{OH-6_M134_Minigun2}',
		'weapons.gunmounts.{OH-6_M134_Minigun3}',
		'weapons.gunmounts.{OH-6_M134_Minigun4}',
		'weapons.gunmounts.{OH-6_M134_Minigun5}',
		'weapons.gunmounts.{OH-6_M134_Minigun6}',
		'weapons.gunmounts.{OH-6_M134_Minigun7}',
		'weapons.gunmounts.{OH-6_M134_Minigun8}',
		'weapons.gunmounts.{OH-6_M134_Minigun9}',
		'weapons.gunmounts.{OH-6_M134_Minigun10}',
		'weapons.gunmounts.{OH-6_M134_Minigun11}',
		'weapons.gunmounts.{OH-6_M134_Minigun12}',
		'weapons.gunmounts.{OH-6_M134_Minigun13}',
		'weapons.gunmounts.{OH-6_M134_Minigun14}',
		'weapons.gunmounts.{ACH_47_M230_Combat_Mix}',
		'weapons.gunmounts.{OH-6_M134_Door}',
		'weapons.gunmounts.{OH-6_M60_Door}',
		'weapons.gunmounts.{MK4_Mod0_OV10}',
		'weapons.missiles.IRIS-T IR AAM',
		'weapons.gunmounts.ACH_47_M230_NT',
		'weapons.gunmounts.ACH_47_M230',
		'weapons.missiles.Personal',
		'weapons.adapters.ACH_47F_GL',
		'weapons.missiles.V1',
		'weapons.missiles.A-Darter IR AAM',
		'weapons.missiles.Ammo',
		'weapons.missiles.APKWS-II-IR',
		'weapons.missiles.AGM-114L',
		'weapons.missiles.AGM-88G AARGM-ER',
		'weapons.missiles.AIM_120C7',
		'weapons.missiles.AIM_120C8',
		'weapons.missiles.AIM_120D3',
		'weapons.missiles.AIM_260A',
		'weapons.missiles.AIM-120B AMRAAM Active Rdr AAM',
		'weapons.missiles.AIM-120C-5 AMRAAM - Active Rdr AAM',
		'weapons.missiles.AIM-120C-5 AMRAAM Active Rdr AAM',
		'weapons.missiles.AIM-120D',
		'weapons.missiles.AIM-120D AMRAAM - Active Radar AAM',
		'weapons.missiles.AIM-132 ASRAAM IR AAM',
		'weapons.missiles.AIM-200A Peregrine Active Rdr AAM',
		'weapons.missiles.AIM-260A JATM - Active Radar AAM',
		'weapons.missiles.AIM-92C',
		'weapons.missiles.AIM-92E',
		'weapons.missiles.AIM-92J',
		'weapons.missiles.AIM-9L Sidewinder IR AAM',
		'weapons.missiles.AIM-9M Sidewinder IR AAM',
		'weapons.missiles.AIM-9X Blk II+ Sidewinder IR AAM',
		'weapons.missiles.AIM-9X Sidewinder IR AAM',
		'weapons.missiles.AIM9X_BLKII',
		'weapons.missiles.Brimstone Laser Guided Missile',
		'weapons.missiles.GBU32_JDAM',
		'weapons.missiles.I-Derby ER BVRAAM Active Rdr AAM',
		'weapons.missiles.jas_agm_65h',
		'weapons.missiles.jas_agm_65k',
		'weapons.missiles.jas_dws39_arm',
		'weapons.missiles.jas_dws39_tv',
		'weapons.missiles.jas39_kepd350_arm',
		'weapons.missiles.JAS39_RBS15_MK4',
		'weapons.missiles.jas39_stormshadow_arm',
		'weapons.missiles.KH-31P (AS-17 Krypton)',
		'weapons.missiles.MAKO_A2A_C',
		'weapons.missiles.MAKO_A2G_C',
		'weapons.missiles.mar1',
		'weapons.missiles.Meteor BVRAAM Active Rdr AAM',
		'weapons.missiles.Python-5 IR AAM',
		'weapons.missiles.R-33',
		'weapons.missiles.R-37',
		'weapons.missiles.R-37M',
		'weapons.missiles.R-73L',
		'weapons.missiles.R-77M',
		'weapons.missiles.RBS-15 Mk4 AShM',
		'weapons.missiles.RVV-BD',
		'weapons.missiles.SPEAR-3 Anti-Radiation Missile',
		'weapons.missiles.SPEAR-EW Decoy',
		'weapons.missiles.AIM-120C-7 AMRAAM Active Rdr AAM',
		'weapons.missiles.AIM-120C-7 AMRAAM - Active Rdr AAM',
		'weapons.nurs.jas_m70bap',
		'weapons.nurs.jas_m70bhe',
		'weapons.nurs.LWL_MPP',
		'weapons.nurs.LWL_RP',
		'weapons.nurs.M49PSRAK145HEAT',
		'weapons.nurs.M56ARAK135HE',
		'weapons.nurs.OH6Rocket FFAR',
		'weapons.shells.OH-6 7.62x51mm M61',
		'weapons.shells.MG_20x64_HEI',
		'weapons.shells.BK_27_AP',
		'weapons.shells.MG_20x64_APT',
		'weapons.shells.BK_27_PELET',
		'weapons.shells.OH-6 7.62x51mm M80',
		'weapons.shells.20x110mm HE-I',
		'weapons.gunmounts.Akan M/55 30mm',
		'weapons.shells.20x110mm AP-T',
		'weapons.shells.20x110mm AP-I',
		'weapons.shells.OH-6 7.62x51mm M62',
		'weapons.shells.M39_20_TP_T',
		'weapons.shells.BK_27_PELE',
		'weapons.shells.OH-6 7.62x51mm HE-I',
		'weapons.shells.7.62x51mm',
		"weapons.containers.ALQ-167",
		"weapons.containers.{SPRAYER_P}",
		"weapons.gunmounts.{ACH_47_M230_NoTracers}",
		"weapons.gunmounts.{5d5aa063-a002-4de8-8a89-6eda1e80ee7b}",
		"weapons.containers.{SPRAYER_F}",
		"weapons.containers.{OV10_SMOKE}",
		"weapons.containers.ACH_47F_Right",
		"weapons.containers.ACH_47F_Left",
		"weapons.adapters.DAGR_Launcher",
		"weapons.containers.Litening III Targeting Pod",
		"weapons.containers.TLAU_127",
		"weapons.containers.{SPRAY_P}",
		"weapons.containers.{SPRAY_F}",
		"weapons.containers.OV-10A_Paratrooper",
		"weapons.containers.FLIR-STAR-SAFIRE",
		"weapons.containers.ACH_47F_GL",
		"weapons.containers.Legion Pod",
		"weapons.containers.A29B_SMOKE-POD",
		"weapons.shells.BK_27_HE",
		"weapons.shells.BK_27_APHE",
		"weapons.missiles.Fuel",
		"weapons.shells.DroneBombShell",
		"weapons.gunmounts.{DroneBomb}",
		"weapons.gunmounts.DroneBombMount",
		"weapons.containers.A29B_SMOKE-POD",
		"weapons.containers.null",

	}

if AllowMods then
  WEAPONSLIST.Items[WEAPONSLIST.ItemCategory.MODS] = WEAPONSLIST_MODS_ITEMS
end

local function _flattenUnique(itemsByCat, cats)
    local out, seen = {}, {}
    for _, cat in ipairs(cats) do
        local items = itemsByCat[cat]
        if items then
            for _, item in ipairs(items) do
                if not seen[item] then
                    out[#out + 1] = item
                    seen[item] = true
                end
            end
        end
    end
    return out
end


local function _wsShouldFilterRestricted()

  return (Era == "Coldwar") and (WEAPONSLIST and WEAPONSLIST.IsRestricted) ~= nil
end

local function _wsFilterRestricted(list)
  if not _wsShouldFilterRestricted() then
    return list or {}
  end
  local out = {}
  for i = 1, #(list or {}) do
    local item = list[i]
    if not WEAPONSLIST.IsRestricted(item) then
      out[#out + 1] = item
    end
  end
  return out
end

	local storageCache = {}
	local function getStorageByName(name)
		local st = storageCache[name]
		if st ~= nil then
			return st or nil
		end
		st = STORAGE:FindByName(name) or false
		storageCache[name] = st
		if st == false then return nil end
		return st
	end

function WEAPONSLIST.GetItems(category)
  local raw
  if (category == nil) or (category == WEAPONSLIST.ItemCategory.ALL) or (category == "ALL") then
    raw = _flattenUnique(WEAPONSLIST.Items, WEAPONSLIST.CategoryOrder)
  else
    raw = WEAPONSLIST.Items[category] or {}
  end
  return _wsFilterRestricted(raw)
end

function WEAPONSLIST.GetAllItems()
  return WEAPONSLIST.GetItems("ALL")
end

function WEAPONSLIST.ClearWeaponsInStorage(storage)
	if not storage then return false end
	for _, itemName in ipairs(WEAPONSLIST.GetAllItems() or {}) do
		pcall(function() storage:SetItem(itemName, 0) end)
	end
	return true
end

function WEAPONSLIST.ClearWeaponsAtAirbase(airbaseName)
	if not airbaseName then return false end
	if not (STORAGE and STORAGE.FindByName) then return false end
	local storage = getStorageByName(airbaseName)
	if not storage then return false end
	return WEAPONSLIST.ClearWeaponsInStorage(storage)
end

local restrictedWeapons = {
    -- Apache Radar
    "weapons.containers.ah-64d_radar",
    -- Missiles
    "weapons.missiles.AIM_120C",
    "weapons.missiles.AIM_120",
    "weapons.missiles.AGM_154",
    "weapons.missiles.AIM_9X",
    "weapons.missiles.ADM_141B",
    "weapons.missiles.AGM_119",
    "weapons.missiles.AGM_130",
    "weapons.missiles.AGM_154A",
    "weapons.missiles.AGM_154B",
    "weapons.missiles.AGM_65G",
    "weapons.missiles.AGM_65H",
    "weapons.missiles.AGM_65K",
    "weapons.missiles.AGM_65L",
    "weapons.missiles.AGM_84E",
    "weapons.missiles.AGM_84H",
    "weapons.missiles.AGM_86C",
    "weapons.missiles.ALARM",
    "weapons.missiles.Ataka_9M120F",
    "weapons.missiles.Ataka_9M220",
    "weapons.missiles.Vikhr_M",
    "weapons.missiles.BK90_MJ1",
    "weapons.missiles.BK90_MJ2",
    "weapons.missiles.BK90_MJ1_MJ2",
    "weapons.missiles.BRM-1_90MM",
    "weapons.missiles.C_701T",
    "weapons.missiles.C_802AK",
    "weapons.missiles.CM-400AKG",
    "weapons.missiles.CM-802AKG",
    "weapons.missiles.DWS39_MJ1",
    "weapons.missiles.DWS39_MJ2",
    "weapons.missiles.DWS39_MJ1_MJ2",
    "weapons.missiles.GB-6",
    "weapons.missiles.GB-6-HE",
    "weapons.missiles.GB-6-SFW",
    "weapons.missiles.HJ-12",
    "weapons.missiles.HOT3_MBDA",
    "weapons.missiles.KD_20",
    "weapons.missiles.KD_63",
    "weapons.missiles.KD_63B",
    "weapons.missiles.LD-10",
    "weapons.missiles.LS_6",
    "weapons.missiles.LS_6_500",
    "weapons.missiles.MICA_R",
    "weapons.missiles.MICA_T",
    "weapons.missiles.Mistral",
    "weapons.missiles.PL-12",
    "weapons.missiles.PL-5EII",
    "weapons.missiles.PL-8B",
    "weapons.missiles.S_25L",
    "weapons.missiles.SD-10",
    "weapons.missiles.SPIKE_ER",
    "weapons.missiles.SPIKE_ER2",
    "weapons.missiles.TGM_65G",
    "weapons.missiles.TGM_65H",
    "weapons.missiles.X_35",
    "weapons.missiles.X_41",
    "weapons.missiles.X_59M",
    "weapons.missiles.YJ-12",
    "weapons.missiles.YJ-83",
    "weapons.containers.ALQ-184",
    "weapons.containers.alq-184long",
    --"weapons.containers.AN_ASQ_228",
    "weapons.missiles.AGM_114L",
    "weapons.missiles.AGM_114",
     --"weapons.missiles.AGM_114K",
    --"weapons.missiles.AGM_65F",

    -- Bombs
    
    "weapons.bombs.GBU_31_V_4B",
    "weapons.bombs.CBU_105",
    "weapons.bombs.CBU_103",
    "weapons.bombs.CBU_97",
    "weapons.bombs.GBU_28",
    "weapons.bombs.GBU_31",
    "weapons.bombs.GBU_31_V_2B",
    "weapons.bombs.GBU_31_V_3B",
    "weapons.bombs.GBU_32_V_2B",
    "weapons.bombs.GBU_38",
    "weapons.bombs.GBU_39",
    "weapons.bombs.GBU_54_V_1B",
    "weapons.bombs.KAB_500S",
    "weapons.bombs.KAB_1500LG",
    "weapons.bombs.KAB_1500T",
    "weapons.bombs.LS_6_100",
    "weapons.bombs.GBU-43/B(MOAB)",}


allowedPlanes = {
  "MiG-19P","Mirage-F1AD","F/A-18A","Su-24MR","F-4E-45MC","MiG-23MLD","Mirage-F1CR","SA342Mistral","Mi-24V","F-15E","AJS37","UH-1H",
  "UH-60L","MB-339A","F-14A-135-GR", "F-14A-135-GR-Early", "F-15C","F-16A MLU","Mirage-F1BD","P3C_Orion","Mirage-F1M-EE","An-30M","F-5E-3_FC",
  "Mirage-F1EQ","A-10A", "Mirage-F1M-CE","Mirage-F1ED","Ka-27","E-2C","UH-60A","Mirage-F1C","Mirage-F1CE","AH-1W","MiG-21Bis","Mirage-F1BE",
  "MB-339APAN","Hercules","Su-25","SA342M","Mirage-F1EDA","OH58D","MiG-15bis_FC","Mirage-F1CZ", "Mirage-F1BQ", "Mirage-F1B",
  "Mirage-F1C-200","Mirage-F1DDA","MiG-15bis","Mirage-F1CJ","Mirage-F1CK","Mirage-F1AZ", "A-10C_2", "Mirage-F1CT","A-10C","M-2000C",
  "Mirage-F1EH","Mirage-F1CH","SA342Minigun","MiG-29A","Bronco-OV-10A","OH-6A", "Mirage-F1CG","F-5E-3","F-86F Sabre","F-14A","L-39C","C-101CC",
  "SA342L","Mi-8MT","Mirage-F1EE","Mi-24P","CH-47Fbl1","FA-18C_hornet","F-16C_50", "MiG-29 Fulcrum","UH-60L_DAP","C-130J-30","F-14B","AH-64D_BLK_II","MH-6J","AH-6J"}

restockAircraft = {
"FA-18FT","EA-18G","F-22A","FA-18E","B-52H","FA-18F","FA-18ET","F15EX","A-29B","F-23A","Ka-50_3","Ka-50",
"Bronco-OV-10A","JAS39Gripen_AG","MiG-31BM","JAS39Gripen","Su-35S","UH-60L","OH-6A","Su-35","JAS39Gripen_BVR","SK-60","T-45","UH-60L_DAP", "MiG-29 Fulcrum","MH-6J","AH-6J"}



local restrictedWeaponSet = {}
for _,weapon in ipairs(restrictedWeapons) do
    restrictedWeaponSet[weapon] = true
end

local restockWeapons = WEAPONSLIST.GetAllItems()

function WEAPONSLIST.IsRestricted(itemName)
    return restrictedWeaponSet[itemName] == true
end

function checkWeaponsList(airbase)
	if airbase and Era ~= 'Coldwar' then
		local storage = STORAGE:FindByName(airbase)
		if storage then
			local allWeapons = WEAPONSLIST.GetAllItems()
			for _, name in ipairs(allWeapons or {}) do
				local okAmt, amt = pcall(storage.GetItemAmount, storage, name)
				if (not okAmt) or (amt == nil) or (amt == 0) or (amt >= 0 and amt < 10000000) then
					pcall(storage.SetItem, storage, name, 1073741823)
				end
			end

			for _, acName in ipairs(restockAircraft) do
				local okAmt, amt = pcall(storage.GetItemAmount, storage, acName)
				if (not okAmt) or (amt == nil) or (amt >= 0 and amt < 10000000) then
					pcall(storage.SetItem, storage, acName, 1073741823)
				end
			end
		end
		return
	end	
    local function isLogisticCenterAirbase(airbaseName)
        if not airbaseName then return false end
        for _, zref in ipairs(bc:getZones() or {}) do
            local z = bc.indexedZones[zref.zone]
            if z and z.airbaseName == airbaseName then
                return z.LogisticCenter == true
            end
        end
        return false
    end

    local function removeRestricted(storage, airbaseName)
        if not storage then return end
		local unlimitedDetected = false
        for _, weapon in ipairs(restrictedWeapons or {}) do
            local amt = storage:GetItemAmount(weapon)
			if amt == 1000000 then unlimitedDetected = true end
            if amt and amt > 0 then
               storage:RemoveItem(weapon, amt)
            end
        end
		if unlimitedDetected then
			trigger.action.outText('Unlimited warehouse detected at '..tostring(airbaseName),15)
		end
    end

    local function restockColdwarLogisticCenter(storage,airbaseName)
        if not storage then return end
        if not storage.GetInventory then return end

        local ac, lq, wp = storage:GetInventory()
		if WarehouseLogistics ~= true or isLogisticCenterAirbase(airbaseName) then
			for name, _ in pairs(wp or {}) do
				if not (restrictedWeaponSet and restrictedWeaponSet[name]) then
					storage:SetItem(name, 1073741823)
				end
			end
		end

        for name, _ in pairs(ac or {}) do
            storage:SetItem(name, 0)
        end

        for _, acName in ipairs(restockAircraft or {}) do
           storage:SetItem(acName, 0)
        end

        for _, plane in ipairs(allowedPlanes or {}) do
           storage:SetItem(plane, 1073741823)
        end
    end

    local function processColdwarAirbase(airbaseName)
        local storage = getStorageByName(airbaseName)
        if not storage then return end

        removeRestricted(storage, airbaseName)
        restockColdwarLogisticCenter(storage,airbaseName)
    end

    if Era == 'Coldwar' then
        if airbase then
            processColdwarAirbase(airbase)
            return
        end

        local airbaseList, seen = {}, {}

        for _, zref in ipairs(bc:getZones() or {}) do
            local z = bc.indexedZones[zref.zone]
            local abName = z and z.airbaseName
            if abName and not seen[abName] and (not abName:find("^CVN%-")) and (abName ~= "Tarawa") and (abName ~= "HMS Invincible") then
                seen[abName] = true
                airbaseList[#airbaseList + 1] = abName
            end
        end

        for _, n in ipairs({"FOB ALPHA", "CVN-72","CVN-73","Tarawa","CVN-59","CVN-74","HMS Invincible"}) do
            if not seen[n] and IsGroupActive(n) then
                seen[n] = true
                airbaseList[#airbaseList + 1] = n
            end
        end

        for _, airbaseName in ipairs(airbaseList) do
            processColdwarAirbase(airbaseName)
        end

        return
    end

     local fillAll = (WarehouseLogistics == false)
    local airbaseList, seen = {}, {}

    for _, z in ipairs(bc:getZones() or {}) do
        local zobj = bc.indexedZones[z.zone]
        local ab = zobj and zobj.airbaseName
        if ab and not seen[ab] and (fillAll or zobj.LogisticCenter == true) then
            seen[ab] = true
            airbaseList[#airbaseList + 1] = ab
        end
    end


    local allWeapons = WEAPONSLIST.GetAllItems()
    for _, airbaseName in ipairs(airbaseList) do
        local storage = STORAGE:FindByName(airbaseName)
        if storage then

            for _, name in ipairs(allWeapons or {}) do
                local okAmt, amt = pcall(storage.GetItemAmount, storage, name)
                if (not okAmt) or (amt == nil) or (amt == 0) or (amt >= 0 and amt < 10000000) then
                    pcall(storage.SetItem, storage, name, 1073741823)
                end
            end

            for _, acName in ipairs(restockAircraft) do
                local okAmt, amt = pcall(storage.GetItemAmount, storage, acName)
                if (not okAmt) or (amt == nil) or (amt >= 0 and amt < 10000000) then
                    pcall(storage.SetItem, storage, acName, 1073741823)
                end
            end
        end
    end
end

timer.scheduleFunction(function()
    checkWeaponsList()
end, {}, timer.getTime() + 1)
