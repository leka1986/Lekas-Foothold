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

	function renameType(tgttype)
		if not tgttype then
			return "Unknown"
		end
		if string.find(tgttype,"ZU%-23 Emplacement") then
			return "ZU-23 Emplacement"
		elseif string.find(tgttype,"BTR_D") then
			return "BTR-D"
		elseif string.find(tgttype,"Shilka") then
			return "Shilka"
		elseif string.find(tgttype,"4320T") then
			return "Ural Truck"
		elseif string.find(tgttype,"GAZ%-66") then
			return "GAZ Truck"
		elseif string.find(tgttype,"BTR%-82A") then
			return "BTR 82A"
		elseif string.find(tgttype,"BMP%-3") then
			return "BMP 3"
		elseif string.find(tgttype,"ZSU_57_2") then
			return "ZSU 58"
		elseif string.find(tgttype,"generator_5i57") then
			return "SA-10 Generator"
		elseif string.find(tgttype,"tt_ZU%-23") then
			return "ZU-23"
		elseif string.find(tgttype,"HL_ZU%-23") then
			return "HL ZU-23"
		elseif string.find(tgttype,"tt_DSHK") then
			return "DSHK Technical"
		elseif string.find(tgttype,"HL_KORD") then
			return "HL Technical"
		elseif string.find(tgttype,"HL_DSHK") then
			return "HL Technical"
		elseif string.find(tgttype,"tt_KORD") then
			return "KORD Technical"
		elseif string.find(tgttype,"APA%-80") then
			return "Zil-131"
		elseif string.find(tgttype,"_Phalanx") then
			return "C-RAM"
		elseif string.find(tgttype,"Tor") then
			return "SA-15"
		elseif string.find(tgttype,"Osa") then
			return "SA-8"
		elseif string.find(tgttype,"manpad") then
			return "MANPAD"
		elseif string.find(tgttype,"Tunguska") then
			return "SA-19"
		elseif string.find(tgttype,"Kub 1S91 str") then
			return "SA-6 STR"
		elseif string.find(tgttype,"Kub 2P25 ln") then
			return "SA-6 LN"
		elseif string.find(tgttype,"snr s%-125 tr") then
			return "SA-3 TR"
		elseif string.find(tgttype,"40B6M tr") then
			return "SA-10 TR"
		elseif string.find(tgttype,"RPC_5N62V") then
			return "SA-5 TR"
		elseif string.find(tgttype,"RLS_19J6") then
			return "SA-5 SR"
		elseif string.find(tgttype,"S%-200_Launcher") then
			return "SA-5 LN"
		elseif string.find(tgttype,"SA%-11 Buk LN") then
			return "SA-11 LN"
		elseif string.find(tgttype,"9S18M1") then
			return "SA-11 SnowDrift SR"
		elseif string.find(tgttype,"9S4770M1") then
			return "SA-11 Command Center"
		elseif string.find(tgttype,"S%-60_Type59") then
			return "S-60 Artillery"
		elseif string.find(tgttype,"p%-19 s%-125 s") then
			return "P19 SAM SR"
		elseif string.find(tgttype,"64H6E sr") then
			return "SA-10 SR 64H6E"
		elseif string.find(tgttype,"40B6MD sr") then
			return "SA-10 SR 40B6MD"
		elseif string.find(tgttype,"5P85C") then
			return "SA-10 LN"
		elseif string.find(tgttype,"5P85D") then
			return "SA-10 LN"
		elseif string.find(tgttype,"54K6") then
			return "SA-10 CP"
		elseif string.find(tgttype,"5p73") then
			return "SA-3 LN"
		elseif string.find(tgttype,"SNR_75V") then
			return "SA-2 TR"
		elseif string.find(tgttype,"Volhov") then
			return "SA-2 LN"
		elseif string.find(tgttype,"Merkava") then
			return "Merkava Tank"
		elseif string.find(tgttype,"T-72") then
			return "MBT T-72"
		elseif string.find(tgttype,"T-90") then
			return "MBT T-90"
		end
		return tgttype
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
        ['OH-6A']  =        { minDist = 8,  maxDeviation = 45,  laserOffset = { x = 1.35, y = 0.1, z = 0 }   },
		['Bronco-OV-10A'] = { minDist = 30,  maxDeviation = 160,  laserOffset = { x = 1.01, y = 0.1, z = 0 }   },		
		['F-4E-45MC'] =     { minDist = 30,  maxDeviation = 160,  laserOffset = { x = 1.01, y = 0.1, z = 0 }   },
		['F-15ESE'] =       { minDist = 40,  maxDeviation = 160,  laserOffset = { x = 1.01, y = 0.1, z = 0 }   },
    }

    SelfJtac.jtacs = {}
	    local ev = {}
    function ev:onEvent(event)
        if (event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT or event.id == world.event.S_EVENT_BIRTH) and event.initiator and event.initiator.getPlayerName then
            local player = event.initiator:getPlayerName()
            if player then
                local stats = SelfJtac.getAircraftStats(event.initiator:getDesc().typeName)
                if stats then
                    local groupid = event.initiator:getGroup():getID()
                    local groupname = event.initiator:getGroup():getName()
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
    
    world.addEventHandler(ev)
end