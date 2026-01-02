--[[
  Early Warning Radar Script - 2.0.0 - created 07/11/2016
  Last Update by Apple 30/11/2023

  New update:
  Fixed some issues with error due to dcs latest object.getCategory.
  Custom messages output.
  Last update by Leka 2025-05-03
  
  
  Requires MOOSE to run: https://github.com/FlightControl-Master
  
  Allows use of units with radars to provide Bearing Range and Altitude information via text display to player aircraft
  
  Features:
    - Uses in-game radar information to detect targets so terrain masking, beaming, low altitude flying, etc is effective for avoiding detection
    - Dynamic. If valid units with radar are created during a mission (eg. via chopper with CTLD), they will be added to the EWRS radar network
    - Can allow / disable BRA messages to fighters or sides
    - Uses player aircraft or mission bullseye for BRA reference, can be changed via F10 radio menu or restricted to one reference in the script settings
    - Can switch between imperial (feet, knots, NM) or metric (meters, km/h, km) measurements using F10 radio menu
    - Ability to change the message display time and automated update interval
    - Can choose to disable automated messages and allow players to request BRA from F10 menu
    - Can allow players to request Bogey Dope at any time through F10 radio menu

    
  At the moment, because of limitations within DCS to not show messages to individual units, the reference, measurements, and messages
  are done per group. So a group of 4 fighters will each receive 4 BRA messages. Each message however, will have the player's name
  in it, that its refering to. Its unfortunate, but nothing I can do about it.

  Changes:
  - 2.0 - Updated to use Moose. Removed airplane and radar type name dependencies.
  - 1.3 - Added Option to allow picture report to be requested thru F10 menu instead of an automated display
      - Fixed bug where a known unit type would sometimes still display as ???
  - 1.4 - Added setting to be able to limit the amount of threats displayed in a picture report
      - Added option to enable Bogey Dopes
        * Mission designer can turn on / off in script settings
        * Pilots can request thru the F10 menu and it will show the BRA to the nearest hostile aircraft that has
        been detected. It will always reference the requesting pilot's own aircraft.
      - Finally implemented a cleaner workaround for some ground units being detected and listed in picture report
  - 1.4.1 - Added some ships to search radar list, you will need to remove the comment markers (--) at the start of the line to activate
  - 1.5 - Added ability to request picture of friendly aircraft positions referencing your own aircraft - Mission designer chooses if this feature is active or not
  - 1.5.1 - Added Gazelle to acCategories
  - 1.5.2 - Added F5E to acCategories
  - 1.5.3 - Fixed bug with maxThreatDisplay set at 0 not displaying any threats
      - Added Mistral Gazelle
      - Added C-101CC
]]

ewrs = {} --DO NOT REMOVE
ewrs.HELO = 1
ewrs.ATTACK = 2
ewrs.FIGHTER = 3
ewrs.version = "2.0.0"
ewrs.rangeOptions = { km = {10,20,40,60,80,100,150}, nm = {5,10,20,40,60,80,100} }

----SCRIPT OPTIONS----

ewrs.messageUpdateInterval = 60 --How often EWRS will update automated BRA messages (seconds)
ewrs.messageDisplayTime = 15 --How long EWRS BRA messages will show for (seconds)
ewrs.restrictToOneReference = false -- Disables the ability to change the BRA calls from pilot's own aircraft or bullseye. If this is true, set ewrs.defaultReference to the option you want to restrict to.
ewrs.defaultReference = "self" --The default reference for BRA calls - can be changed via f10 radio menu if ewrs.restrictToOneReference is false (self or bulls)
ewrs.defaultMeasurements = "imperial" --Default measurement units - can be changed via f10 radio menu (imperial or metric)
ewrs.disableFightersBRA = false -- disables BRA messages to fighters when true
ewrs.enableRedTeam = true -- enables / disables EWRS for the red team
ewrs.enableBlueTeam = true -- enables / disables EWRS for the blue team
ewrs.disableMessageWhenNoThreats = true -- disables message when no threats are detected - Thanks Rivvern - NOTE: If using ewrs.onDemand = true, this has no effect
ewrs.useImprovedDetectionLogic = true --this makes the messages more realistic. If the radar doesn't know the type or distance to the detected threat, it will be reflected in the picture report / BRA message
ewrs.onDemand = false --Setting to true will disable the automated messages to everyone and will add an F10 menu to get picture / BRA message.
ewrs.maxThreatDisplay = 5 -- Max amounts of threats to display on picture report (0 will display all)
ewrs.allowBogeyDope = true -- Allows pilots to request a bogey dope even with the automated messages running. It will display only the cloest threat, and will always reference the players own aircraft.
ewrs.allowFriendlyPicture = true -- Allows pilots to request picture of friendly aircraft
ewrs.maxFriendlyDisplay = 5 -- Limits the amount of friendly aircraft shown on friendly picture
ewrs.showType = true -- if true it will show the type of the unit
ewrs.hiddenFriendlyReportingNames = { Sentry = true }
ewrs.specialPlaneTypes = {
  ["F-4E-45MC"] = true,
  ["MiG-29 Fulcrum"] = true,
  ["F-5E-3_FC"] = true,
  ["C-130J-30"] = true,
}

local function ewrs_isSpecialPlaneType(unitType)
  return unitType and ewrs.specialPlaneTypes[unitType] == true
end

local function ewrs_isSpecialPlaneUnit(unit)
  if not unit then return false end
  local typeName
  if type(unit) == "table" then
    if unit.getTypeName then
      typeName = unit:getTypeName()
    elseif unit.GetTypeName then
      typeName = unit:GetTypeName()
    end
  end
  return ewrs_isSpecialPlaneType(typeName)
end

function ewrs.shouldHideFriendlyReportingName(name)
  return name and ewrs.hiddenFriendlyReportingNames[name] == true
end

ewrs.runtimeCache = { units = {}, friendlyGroups = {}, groupSettings = {} }

function ewrs.resetRuntimeCache()
  ewrs.runtimeCache.units = {}
  ewrs.runtimeCache.friendlyGroups = {}
  ewrs.runtimeCache.groupSettings = {}
end

function ewrs.getCachedUnitByName(name)
  if not name then return nil end
  local cached = ewrs.runtimeCache.units[name]
  if cached and cached:isExist() and cached:isActive() then
    return cached
  end
  local unit = Unit.getByName(name)
  if unit and unit:isExist() and unit:isActive() then
    ewrs.runtimeCache.units[name] = unit
  else
    ewrs.runtimeCache.units[name] = nil
  end
  return unit
end

function ewrs.getCachedCoalitionGroups(coalitionId)
  local cached = ewrs.runtimeCache.friendlyGroups[coalitionId]
  if cached then return cached end
  local groups = coalition.getGroups(coalitionId) or {}
  ewrs.runtimeCache.friendlyGroups[coalitionId] = groups
  return groups
end

function ewrs.getGroupSettingsTable(groupID)
  local key = tostring(groupID)
  local cached = ewrs.runtimeCache.groupSettings[key]
  if cached then return cached end
  if ewrs.groupSettings[key] == nil then
    ewrs.addGroupSettings(key)
  end
  ewrs.runtimeCache.groupSettings[key] = ewrs.groupSettings[key]
  return ewrs.runtimeCache.groupSettings[key]
end

local function ewrs_flagSettingsDirty(settings)
  if settings then
    settings._dirty = true
  end
end


ewrs.resetRuntimeCache()

ewrs.savedPlayerSettings = {}

local function ewrs_clonePersistentSettings(src)
  if not src then return {} end
  return {
    reference = src.reference,
    measurements = src.measurements,
    rangeLimit = src.rangeLimit,
    showFriendlies = src.showFriendlies,
    maxFriendlies = src.maxFriendlies,
    messages = src.messages,
    customized = src.customized or src._hasCustomizations or false,
  }
end

local function ewrs_settingsEqual(a, b)
  if a == b then return true end
  if type(a) ~= "table" or type(b) ~= "table" then return false end
  local keys = {"reference","measurements","rangeLimit","showFriendlies","maxFriendlies","messages"}
  for _,key in ipairs(keys) do
    if a[key] ~= b[key] then
      return false
    end
  end
  return true
end

local function ewrs_pruneLegacyProfiles(profiles)
  if not profiles then return end
  local heli = profiles.helicopter
  if not heli or heli.customized then return end
  local compare = profiles.plane or profiles.default
  if compare and ewrs_settingsEqual(heli, compare) then
    profiles.helicopter = nil
  end
end

local function ewrs_getProfileTable(playerName)
  if not playerName then return nil end
  local entry = ewrs.savedPlayerSettings[playerName]
  if entry and entry.categories then
    entry.categories = entry.categories or {}
    return entry.categories
  end
  if entry then
    entry = { categories = { default = ewrs_clonePersistentSettings(entry) } }
  else
    entry = { categories = {} }
  end
  ewrs.savedPlayerSettings[playerName] = entry
  return entry.categories
end

local function ewrs_storePlayerProfile(playerName, category, settings)
  if not playerName or not settings then return end
  local profiles = ewrs_getProfileTable(playerName)
  if not profiles then return end
  profiles[category or "default"] = ewrs_clonePersistentSettings(settings)
end

local function ewrs_fetchPlayerProfile(playerName, category)
  if not playerName then return nil end
  local entry = ewrs.savedPlayerSettings[playerName]
  if not entry then return nil end
  if not entry.categories then
    entry = { categories = { default = ewrs_clonePersistentSettings(entry) } }
    ewrs.savedPlayerSettings[playerName] = entry
  end
  local profiles = entry.categories or {}
  local bucket = category or "default"
  local saved = profiles[bucket]

  if not saved then
    if bucket == "plane" then
      saved = profiles.default
    elseif bucket == "default" then
      saved = profiles.default
    elseif bucket == "plane_special" then
      saved = nil
    else
      saved = nil
    end
  end

  if (not saved) and bucket == "default" then
    for _,profile in pairs(profiles) do
      saved = profile
      break
    end
  end
  return saved
end

function ewrs.applySavedSettings(playerName, groupID, unit)
  if not playerName or not groupID then return end
  local category = ewrs.getGroupCategory(unit) or "default"
  if category == "none" then category = "default" end
  local saved = ewrs_fetchPlayerProfile(playerName, category)
  if not saved then return end
  local settings = ewrs.getGroupSettingsTable(groupID)
  if not settings then return end
  for k,v in pairs(saved) do
    if k ~= "customized" then
      settings[k]=v
    end
  end
end

function ewrs.persistGroupSettings(groupID)
  if not groupID then return end
  local settings = ewrs.getGroupSettingsTable(groupID)
  if not settings or not settings._dirty then return end
  local savedAny = false
  for _,player in ipairs(ewrs.activePlayers or {}) do
    if player.groupID == groupID then
      local unitObj = ewrs.getCachedUnitByName(player.unitname)
      local category = ewrs.getGroupCategory(unitObj) or "default"
      if category == "none" then category = "default" end
      settings._hasCustomizations = true
      ewrs_storePlayerProfile(player.player, category, settings)
      savedAny = true
    end
  end
  if savedAny then
    settings._dirty = false
    settings._hasCustomizations = true
  end
end

function ewrs.exportPlayerSettings()
  local list = {}
  for name,_ in pairs(ewrs.savedPlayerSettings or {}) do
    local profiles = ewrs_getProfileTable(name)
    local payload = { name = name, profiles = {} }
    for cat, settings in pairs(profiles or {}) do
      payload.profiles[cat] = ewrs_clonePersistentSettings(settings)
    end
    list[#list+1] = payload
  end
  return list
end

function ewrs.importPlayerSettings(entries)
  ewrs.savedPlayerSettings = {}
  if type(entries) ~= "table" then return end
  for _,entry in ipairs(entries) do
    if entry and entry.name then
      if entry.profiles and type(entry.profiles)=="table" then
        for cat,settings in pairs(entry.profiles) do
          ewrs_storePlayerProfile(entry.name, cat, settings)
        end
        ewrs_pruneLegacyProfiles(ewrs_getProfileTable(entry.name))
      elseif entry.settings then
        ewrs_storePlayerProfile(entry.name, "default", entry.settings)
      end
    end
  end
end

if EWRS_PENDING_PLAYER_SETTINGS then
  ewrs.importPlayerSettings(EWRS_PENDING_PLAYER_SETTINGS)
  EWRS_PENDING_PLAYER_SETTINGS = nil
end

----END OF SCRIPT OPTIONS----


----INTERNAL FUNCTIONS ***** Be Careful changing things below here ***** ----


function ewrs.getDistance(obj1PosX, obj1PosZ, obj2PosX, obj2PosZ)
  local xDiff = obj1PosX - obj2PosX
  local yDiff = obj1PosZ - obj2PosZ
  return math.sqrt(xDiff * xDiff + yDiff * yDiff) -- meters
end

function ewrs.getBearing(obj1PosX, obj1PosZ, obj2PosX, obj2PosZ)
    local bearing = math.atan2(obj2PosZ - obj1PosZ, obj2PosX - obj1PosX)
    if bearing < 0 then
        bearing = bearing + 2 * math.pi
    end
    bearing = bearing * 180 / math.pi
    return bearing    -- degrees
end

function ewrs.getHeading(vec)
    local heading = math.atan2(vec.z,vec.x)
    if heading < 0 then
        heading = heading + 2 * math.pi
    end
    heading = heading * 180 / math.pi
    return heading -- degrees
end

function ewrs.getSpeed(velocity)
  local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2) --m/s
  return speed -- m/s
end

function ewrs.update()
  ewrs.resetRuntimeCache()
  timer.scheduleFunction(ewrs.update, nil, timer.getTime() + 5)
  ewrs.buildActivePlayers()
  ewrs.buildF10Menu()
end

function ewrs.getAspect(bearing, heading)
  local toRef = (bearing + 180) % 360
  local diff = math.abs(((heading - toRef + 540) % 360) - 180)

  if diff <= 30 then
    return "Hot"
  elseif diff <= 60 then
    return "Flanking"
  elseif diff <= 120 then
    return "Beaming"
  else
    return "Cold"
  end
end

function ewrs.buildThreatTable(activePlayer,bogeyDope)
  local function sortRanges(v1,v2) if v1.isFriendly and not v2.isFriendly then return false end if v2.isFriendly and not v1.isFriendly then return true end return v1.range<v2.range end
  local targets={}
  if activePlayer.side==2 then targets=ewrs.currentlyDetectedRedUnits else targets=ewrs.currentlyDetectedBlueUnits end
  local bogeyDope=bogeyDope or false
  local groupSettings=ewrs.getGroupSettingsTable(activePlayer.groupID)
  local playerUnit=ewrs.getCachedUnitByName(activePlayer.unitname)
  local referenceX
  local referenceZ
  if groupSettings.reference=="self" or bogeyDope then
    if not playerUnit then return {} end
    local selfpos=playerUnit:getPosition()
    referenceX=selfpos.p.x
    referenceZ=selfpos.p.z
  else
    local bullseye=coalition.getMainRefPoint(activePlayer.side)
    referenceX=bullseye.x
    referenceZ=bullseye.z
  end
  local useMetric=groupSettings.measurements=="metric"
  local rangeLimit=groupSettings.rangeLimit or 0
  local threatTable={}
  for _,obj in pairs(targets) do
    local velocity=obj:getVelocity()
    local bogeypos=obj:getPosition()
    local bogeyType=nil
    local unit=UNIT:Find(obj) if unit then bogeyType=unit:GetNatoReportingName() end
    if not bogeyType then bogeyType = "Unknown" end  
    local bearing = (math.floor((ewrs.getBearing(referenceX,referenceZ,bogeypos.p.x,bogeypos.p.z)+2.5)/5)*5) % 360
    if bearing == 0 then bearing = 360 end
    local heading=ewrs.getHeading(velocity)
    local aspect=ewrs.getAspect(bearing,heading)
    local range=ewrs.getDistance(referenceX,referenceZ,bogeypos.p.x,bogeypos.p.z)
    local altitude=bogeypos.p.y
    local speed=ewrs.getSpeed(velocity)
    if useMetric then
      local km=range/1000
      if km>=60 then range=UTILS.Round(km,-1) elseif km>=20 then range=UTILS.Round(km/5,0)*5 else range=UTILS.Round(km,0) end
      speed=UTILS.Round(UTILS.MpsToKmph(speed),-1)
      altitude=UTILS.Round(altitude,-1)
    else
      local nm=UTILS.MetersToNM(range)
      if nm>=60 then range=UTILS.Round(nm,-1) elseif nm>=20 then range=UTILS.Round(nm/5,0)*5 else range=UTILS.Round(nm,0) end
      speed=UTILS.Round(UTILS.MpsToKnots(speed),-1)
      altitude=UTILS.Round(UTILS.MetersToFeet(altitude),-3)
    end
    if rangeLimit==0 or range<=rangeLimit then
      local j=#threatTable+1
      threatTable[j]={}
      threatTable[j].unitType=bogeyType
      threatTable[j].bearing=bearing
      threatTable[j].range=range
      threatTable[j].altitude=altitude
      threatTable[j].speed=speed
      threatTable[j].heading=heading
      threatTable[j].aspect=aspect
    end
  end
    if activePlayer.side==2 and ewrs.inAuto and not bogeyDope and ewrs.getGroupCategory(playerUnit)=="plane" then

    local function addTanker(name,label)
      local g=Group.getByName(name)
      local t=g and g:isExist() and g:getUnits() and g:getUnits()[1] or nil
      if t and t:isExist() and t:isActive() and t:getLife()>0 then
        local tp=t:getPosition()
        local vel=t:getVelocity()
        local bearing=(math.floor((ewrs.getBearing(referenceX,referenceZ,tp.p.x,tp.p.z)+2.5)/5)*5)%360
        if bearing==0 then bearing=360 end
        local heading=ewrs.getHeading(vel)
        local aspect=ewrs.getAspect(bearing,heading)
        local range=ewrs.getDistance(referenceX,referenceZ,tp.p.x,tp.p.z)
        local altitude=tp.p.y
        local speed=ewrs.getSpeed(vel)
        if useMetric then
          local km=range/1000
          if km>=60 then range=UTILS.Round(km,-1) elseif km>=20 then range=UTILS.Round(km/5,0)*5 else range=UTILS.Round(km,0) end
          speed=UTILS.Round(UTILS.MpsToKmph(speed),-1)
          altitude=UTILS.Round(altitude,-1)
        else
          local nm=UTILS.MetersToNM(range)
          if nm>=60 then range=UTILS.Round(nm,-1) elseif nm>=20 then range=UTILS.Round(nm/5,0)*5 else range=UTILS.Round(nm,0) end
          speed=UTILS.Round(UTILS.MpsToKnots(speed),-1)
          altitude=UTILS.Round(UTILS.MetersToFeet(altitude),-3)
        end
        local j=#threatTable+1
        threatTable[j]={}
        threatTable[j].unitType=name
        threatTable[j].isFriendly=true
        threatTable[j].isTanker=true
        threatTable[j].bearing=bearing
        threatTable[j].range=range
        threatTable[j].altitude=altitude
        threatTable[j].speed=speed
        threatTable[j].heading=heading
        threatTable[j].aspect=aspect
      end
    end
    addTanker("Arco","Drouge")
    addTanker("Texaco","Boom")
  end
  if groupSettings.showFriendlies and not bogeyDope then
    local friendCoal=activePlayer.side
    local groups=ewrs.getCachedCoalitionGroups(friendCoal)
    for _,grp in ipairs(groups) do
      local gname=grp:getName()
      if gname~="Arco" and gname~="Texaco" then
        local units=grp:getUnits() or{}
        for _,u in ipairs(units) do
          if u and u:isExist() and u:isActive() and u:inAir() and u:getLife()>0 then
            if u:getName()~=activePlayer.unitname then
              local tp=u:getPosition()
              local vel=u:getVelocity()
              local bearing=(math.floor((ewrs.getBearing(referenceX,referenceZ,tp.p.x,tp.p.z)+2.5)/5)*5)%360
              if bearing==0 then bearing=360 end
              local heading=ewrs.getHeading(vel)
              local aspect=ewrs.getAspect(bearing,heading)
              local range=ewrs.getDistance(referenceX,referenceZ,tp.p.x,tp.p.z)
              local altitude=tp.p.y
              local speed=ewrs.getSpeed(vel)
              if useMetric then
                local km=range/1000
                if km>=60 then range=UTILS.Round(km,-1) elseif km>=20 then range=UTILS.Round(km/5,0)*5 else range=UTILS.Round(km,0) end
                speed=UTILS.Round(UTILS.MpsToKmph(speed),-1)
                altitude=UTILS.Round(altitude,-1)
              else
                local nm=UTILS.MetersToNM(range)
                if nm>=60 then range=UTILS.Round(nm,-1) elseif nm>=20 then range=UTILS.Round(nm/5,0)*5 else range=UTILS.Round(nm,0) end
                speed=UTILS.Round(UTILS.MpsToKnots(speed),-1)
                altitude=UTILS.Round(UTILS.MetersToFeet(altitude),-3)
              end
              if rangeLimit==0 or range<=rangeLimit then
                local unit=UNIT:Find(u)
                local bogeyType=nil
                if unit then bogeyType=unit:GetNatoReportingName() end
                if not bogeyType then bogeyType="Unknown" end
                if not ewrs.shouldHideFriendlyReportingName(bogeyType) then
                  local j=#threatTable+1
                  threatTable[j]={}
                  threatTable[j].unitType=bogeyType
                  threatTable[j].isFriendly=true
                  threatTable[j].bearing=bearing
                  threatTable[j].range=range
                  threatTable[j].altitude=altitude
                  threatTable[j].speed=speed
                  threatTable[j].heading=heading
                  threatTable[j].aspect=aspect
                end
              end
            end
          end
        end
      end
    end
  end
  table.sort(threatTable,sortRanges)
  local maxFriendlies=groupSettings.maxFriendlies or 0
  if maxFriendlies>0 then
    local friendlyCount=0
    local filtered={}
    for _,entry in ipairs(threatTable) do
      if entry.isFriendly and not entry.isTanker then
        if friendlyCount<maxFriendlies then
          friendlyCount=friendlyCount+1
          filtered[#filtered+1]=entry
        end
      else
        filtered[#filtered+1]=entry
      end
    end
    threatTable=filtered
  end
  return threatTable
end



function ewrs.outText(activePlayer, threatTable, bogeyDope, greeting)
  local status, result = pcall(function()
    
    local message = {}
    local groupSettings = ewrs.getGroupSettingsTable(activePlayer.groupID)
    local altUnits
    local speedUnits
    local rangeUnits
    local bogeyDope = bogeyDope or false
    if groupSettings.measurements == "metric" then
      altUnits = "m"
      speedUnits = "km/h"
      rangeUnits = "km"
    else
      altUnits = "ft"
      speedUnits = "kts"
      rangeUnits = "NM"
    end
    
    if #threatTable >= 1 then
      local maxThreats = nil
      local messageGreeting = nil
      if greeting == nil then
        if bogeyDope then
          maxThreats = 1
          messageGreeting = "EWRS Bogey Dope for: " .. activePlayer.player
        else
          if ewrs.maxThreatDisplay == 0 then
            maxThreats = 999
          else
            maxThreats = ewrs.maxThreatDisplay
          end
          messageGreeting = "EWRS : " .. activePlayer.player .. " | relative to " .. groupSettings.reference
        end
      else
        messageGreeting = greeting
        maxThreats = ewrs.maxFriendlyDisplay
      end
      
      table.insert(message,messageGreeting)
      table.insert(message,"\n")
      local friendlyHeader=false
      

      if greeting==nil and not bogeyDope then
        local shown=0
        for k=1,#threatTable do
          local t=threatTable[k]
          if t==nil then break end
          if not t.isFriendly and shown<maxThreats then
            if t.range==ewrs.notAvailable then
              table.insert(message,string.format("%s Position: Unknown",(t.unitType or "Unknown")))
            else
              local asp = string.upper(t.aspect)
              table.insert(message,string.format("\n%s\t\tBRA\t\t%03d for %s\t\t%s\t\t%s",(ewrs.showType and t.unitType or "Unknown"),t.bearing,t.range..rangeUnits,t.altitude..altUnits,asp))
            end
            shown=shown+1
            if shown<maxThreats then table.insert(message,"\n") end
          end
        end
        for k=1,#threatTable do
          local t=threatTable[k]
          if t and t.isFriendly then
            if not friendlyHeader then if message[#message] ~= "\n" then table.insert(message,"\n") end table.insert(message,"\n"); table.insert(message,"-------------------------------->  Friendly  <---------------------------------"); table.insert(message,"\n"); friendlyHeader=true end
            if t.range==ewrs.notAvailable then
              table.insert(message,string.format("%s Position: Unknown",(t.unitType or "Unknown")))
            else
              local asp = string.upper(t.aspect)
              table.insert(message,string.format("\n%s\t\tBRA\t\t%03d for %s\t\t%s\t\t%s",(ewrs.showType and t.unitType or "Unknown"),t.bearing,t.range..rangeUnits,t.altitude..altUnits,asp))
            end
            if k<#threatTable then table.insert(message,"\n") end
          end
        end
      else
        for k=1,maxThreats do
          if threatTable[k]==nil then break end
          if greeting==nil and not friendlyHeader and threatTable[k].isFriendly then table.insert(message,"\n"); table.insert(message,"-------------------------------->  Friendly  <---------------------------------"); table.insert(message,"\n"); friendlyHeader=true end
          if threatTable[k].range==ewrs.notAvailable then
            table.insert(message,string.format("%s Position: Unknown",(threatTable[k].unitType or "Unknown")))
          else
            local asp = string.upper(threatTable[k].aspect)
            table.insert(message,string.format("\n%s\t\tBRA\t\t%03d for %s\t\t%s\t\t%s",
            (ewrs.showType and threatTable[k].unitType or "Unknown"),
            threatTable[k].bearing,
            threatTable[k].range..rangeUnits,
            threatTable[k].altitude..altUnits,
            asp))
          end
          if threatTable[k+1]~=nil then
          table.insert(message,"\n")
          end
        end
      end
       trigger.action.outTextForGroup(activePlayer.groupID,table.concat(message),ewrs.messageDisplayTime)
    else
      if bogeyDope then
        trigger.action.outTextForGroup(activePlayer.groupID, "EWRS Bogey Dope for: " .. activePlayer.player .. "\nNo targets detected", ewrs.messageDisplayTime)
      elseif (not ewrs.disableMessageWhenNoThreats) and greeting == nil then
        trigger.action.outTextForGroup(activePlayer.groupID, "EWRS Picture Report for: " .. activePlayer.player .. "\nNo targets detected", ewrs.messageDisplayTime)
      end
      if greeting ~= nil then
        trigger.action.outTextForGroup(activePlayer.groupID, "EWRS Friendly Picture for: " .. activePlayer.player .. "\nNo friendlies detected", ewrs.messageDisplayTime)
      end
    end
  end)
  if not status then
    env.error(string.format("EWRS outText Error: %s", result))
  end
end



function ewrs.onDemandMessage(args)
  local status, result = pcall(function()
    ewrs.findRadarUnits()
    ewrs.getDetectedTargets()
    for i = 1, #ewrs.activePlayers do
      if ewrs.activePlayers[i].groupID == args[1] then
        ewrs.outText(ewrs.activePlayers[i], ewrs.buildThreatTable(ewrs.activePlayers[i],args[2]),args[2])
      end
    end
  end)
  if not status then
    env.error(string.format("EWRS onDemandMessage Error: %s", result))
  end
end

function ewrs.buildFriendlyTable(friendlyNames,activePlayer)
  local function sortRanges(v1,v2) return v1.range<v2.range end

  local groupSettings=ewrs.getGroupSettingsTable(activePlayer.groupID)
  local useMetric=groupSettings.measurements=="metric"
  local units={}
  for i=1,#friendlyNames do
    local unit=ewrs.getCachedUnitByName(friendlyNames[i])
    if unit and unit:isActive() then table.insert(units,unit) end
  end

  local _self=ewrs.getCachedUnitByName(activePlayer.unitname)
  if not _self then return {} end
  local selfpos=_self:getPosition()
  local referenceX=selfpos.p.x
  local referenceZ=selfpos.p.z

  local friendlyTable={}

  for k,v in pairs(units) do
    local velocity=v:getVelocity()
    local pos=v:getPosition()
    local unit=UNIT:Find(v)
    if unit then                                           -- << guard >>
      local bogeyType=unit:GetNatoReportingName()
      if not bogeyType then bogeyType = "Unknown" end
      if not ewrs.shouldHideFriendlyReportingName(bogeyType) and pos.p.x~=selfpos.p.x and pos.p.z~=selfpos.p.z then
        local bearing=ewrs.getBearing(referenceX,referenceZ,pos.p.x,pos.p.z)
        local heading=ewrs.getHeading(velocity)
        local range=ewrs.getDistance(referenceX,referenceZ,pos.p.x,pos.p.z)
        local altitude=pos.p.y
        local speed=ewrs.getSpeed(velocity)

    if useMetric then
      local km=range/1000
      if km>=20 then range=UTILS.Round(km,-1) else range=UTILS.Round(km,0) end
      speed=UTILS.Round(UTILS.MpsToKmph(speed),-1)
      altitude=UTILS.Round(altitude,-1)
    else
      local nm=UTILS.MetersToNM(range)
      if nm>=20 then range=UTILS.Round(nm,-1) else range=UTILS.Round(nm,0) end
      speed=UTILS.Round(UTILS.MpsToKnots(speed),-1)
      altitude=UTILS.Round(UTILS.MetersToFeet(altitude),-3)
    end

        local j=#friendlyTable+1
        friendlyTable[j]={}
        friendlyTable[j].unitType=bogeyType
        friendlyTable[j].bearing=bearing
        friendlyTable[j].range=range
        friendlyTable[j].altitude=altitude
        friendlyTable[j].speed=speed
        friendlyTable[j].heading=heading
      end
    end
  end
  table.sort(friendlyTable,sortRanges)
  return friendlyTable
end

function ewrs.friendlyPicture(args)
  local status, result = pcall(function()
    for i = 1, #ewrs.activePlayers do
      if ewrs.activePlayers[i].groupID == args[1] then
        local sideString = nil
        if  ewrs.activePlayers[i].side == 1 then
          sideString = "[red]"
        else
          sideString = "[blue]"
        end
        --local filter = {sideString.."[helicopter]", sideString.."[plane]"}
        --local friendlies = mist.makeUnitTable(filter) --find a way to do this only once if there is more then 1 person in a group
        local friendlies = SET_UNIT:New():FilterCoalitions(sideString):FilterTypes({"helicopter","plane"}):FilterOnce()
        local friendlyTable = ewrs.buildFriendlyTable(friendlies:GetSetNames(),ewrs.activePlayers[i])
        local greeting = "EWRS Friendly Picture for: " .. ewrs.activePlayers[i].player
        ewrs.outText(ewrs.activePlayers[i],friendlyTable,false,greeting)
      end
    end
  end)
  if not status then
    env.error(string.format("EWRS friendlyPicture Error: %s", result))
  end
end

function ewrs.buildActivePlayers()
  local status, result = pcall(function()
    local all_units = SET_CLIENT:New():FilterActive(true):FilterOnce()
    local all_vecs = all_units:GetSetNames()
    --UTILS.PrintTableToLog(all_vecs,1)
    ewrs.activePlayers = {}
    for i = 1, #all_vecs do
      local vec = Unit.getByName(all_vecs[i])
      if vec and vec:isActive() then
        local playerName = Unit.getPlayerName(vec)    -- static call is OK
        local groupID    = ewrs.getGroupId(vec)
        if playerName then
          -- use colon again when you need the coalition of THAT unit
          if ewrs.enableBlueTeam and vec:getCoalition() == 2 then
            ewrs.addPlayer(playerName, groupID, vec)
          elseif ewrs.enableRedTeam and vec:getCoalition() == 1 then
            ewrs.addPlayer(playerName, groupID, vec)
          end
        end
      end
    end
  end) -- pcall
  
  if not status then
    env.error(string.format("EWRS buildActivePlayers Error: %s", result))
  end
end

function ewrs.getGroupId(_unit)
  if not _unit then return nil end
  local unit = UNIT:Find(_unit)
  if unit and unit:GetGroup() then
    return unit:GetGroup():GetID()
  end
  return nil
end

function ewrs.getGroupCategory(unit)
  if not unit then return nil end
  local unit = UNIT:Find(unit)
  local category = "none"

  if unit and unit:IsAirPlane() then
    if ewrs_isSpecialPlaneUnit(unit) then
      category = "plane_special"
    else
      category = "plane"
    end
  end
  if unit and unit:IsHelicopter() then category = "helicopter" end
  return category
end


function ewrs.addPlayer(playerName, groupID, unit)
  if not playerName or not groupID or not unit then return end

  local isHelo = unit:hasAttribute("Helicopters")
  local unitType = unit:getTypeName()
  local isSpecialPlane = (not isHelo) and ewrs_isSpecialPlaneType(unitType)
  local autoShowFriendlies = isSpecialPlane
    if ewrs.groupSettings[tostring(groupID)]==nil then
    ewrs.addGroupSettings(tostring(groupID),isHelo,autoShowFriendlies)
    end
  local status, result = pcall(function()
    local i = #ewrs.activePlayers + 1
    ewrs.activePlayers[i] = {}
    ewrs.activePlayers[i].player = playerName
    ewrs.activePlayers[i].groupID = groupID
    ewrs.activePlayers[i].unitname = unit:getName()
    ewrs.activePlayers[i].side = unit:getCoalition() 
  
    -- add default settings to settings table if it hasn't been done yet
    if ewrs.groupSettings[tostring(groupID)] == nil then
      ewrs.addGroupSettings(tostring(groupID))
    end

    ewrs.applySavedSettings(playerName, groupID, unit)

  end)
  if not status then
    env.error(string.format("EWRS addPlayer Error: %s", result))
  end
end


function ewrs.getDetectedTargets()
  if ewrs.enableBlueTeam then
    ewrs.currentlyDetectedRedUnits  = ewrs.findDetectedTargets("red")
  end
  if ewrs.enableRedTeam then
    ewrs.currentlyDetectedBlueUnits = ewrs.findDetectedTargets("blue")
  end
end

  function ewrs.findDetectedTargets(side)
    local dets = {}
    local tgtCoal = side == "red" and 2 or 1

    for _, grp in ipairs(coalition.getGroups(tgtCoal)) do
      for _, u in ipairs(grp:getUnits()) do
        if u:isExist() 
          and (u:hasAttribute("SAM SR") or u:hasAttribute("EWR") or u:hasAttribute("AWACS")) 
        then
          for _, d in ipairs(u:getController():getDetectedTargets(Controller.Detection.RADAR)) do
            local obj = d.object
            if obj and obj:isExist() and obj:inAir()
              and (obj:hasAttribute("Planes") or obj:hasAttribute("Helicopters")) 
            then
              dets[obj:getName()] = obj
            end
          end
        end
      end
    end

    local out = {}
    for _, o in pairs(dets) do
      out[#out+1] = o
    end
    return out
  end

function ewrs.findRadarUnits()
  local allunitsB = SET_UNIT:New():FilterHasSEAD():FilterCategories({"plane","ground","ship"}):FilterCoalitions("blue"):FilterOnce()
  local allunitsR = SET_UNIT:New():FilterHasSEAD():FilterCategories({"plane","ground","ship"}):FilterCoalitions("red"):FilterOnce()
  
  if ewrs.enableBlueTeam then
    ewrs.blueEwrUnits = allunitsB:GetSetNames()
    --UTILS.PrintTableToLog(ewrs.blueEwrUnits ,indent)
  end
  if ewrs.enableRedTeam then
    ewrs.redEwrUnits = allunitsR:GetSetNames()
    --UTILS.PrintTableToLog(ewrs.redEwrUnits ,indent)
  end
end

function ewrs.addGroupSettings(groupID,isHelo,showFriendlies)
  ewrs.groupSettings[groupID]={}
  ewrs.groupSettings[groupID].reference=ewrs.defaultReference
  ewrs.groupSettings[groupID].measurements=ewrs.defaultMeasurements
  ewrs.groupSettings[groupID].messages=true
  ewrs.groupSettings[groupID].rangeLimit=isHelo and 5 or 60
  ewrs.groupSettings[groupID].showFriendlies=showFriendlies and true or false
  ewrs.groupSettings[groupID].maxFriendlies=5
end
function ewrs.setGroupMaxFriendlies(args)
  local groupID=args[1]
  local value=args[2]
  local settings=ewrs.getGroupSettingsTable(groupID)
  settings.maxFriendlies=value
  ewrs_flagSettingsDirty(settings)
  local msg
  if value==0 then
    msg="Friendly contact limit set to ALL"
  else
    msg="Friendly contact limit set to "..value
  end
  trigger.action.outTextForGroup(groupID,msg,ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
end
function ewrs.setGroupShowFriendlies(args)
  local groupID=args[1]
  local settings=ewrs.getGroupSettingsTable(groupID)
  settings.showFriendlies=args[2]
  ewrs_flagSettingsDirty(settings)
  local onOff=args[2] and "on" or "off"
  trigger.action.outTextForGroup(groupID,"Friendly contacts in picture turned "..onOff,ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
end

function ewrs.setGroupReference(args)
  local groupID = args[1]
  local settings = ewrs.getGroupSettingsTable(groupID)
  settings.reference = args[2]
  ewrs_flagSettingsDirty(settings)
  trigger.action.outTextForGroup(groupID,"Reference changed to "..args[2],ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
end

function ewrs.setGroupMeasurements(args)
  local groupID = args[1]
  local groupSettings = ewrs.getGroupSettingsTable(groupID)
  local oldUnits = groupSettings.measurements
  local newUnits = args[2]
  if oldUnits ~= newUnits then
    if newUnits == "metric" then
      groupSettings.rangeLimit = UTILS.Round(groupSettings.rangeLimit * 1.852, -1)
    else
      groupSettings.rangeLimit = UTILS.Round(groupSettings.rangeLimit / 1.852, -1)
    end
  end
  groupSettings.measurements = newUnits
  ewrs_flagSettingsDirty(groupSettings)
  trigger.action.outTextForGroup(groupID,"Measurement units changed to "..newUnits,ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
end

function ewrs.setGroupMessages(args)
  local groupID = args[1]
  local onOff
  if args[2] then onOff = "on" else onOff = "off" end
  local settings = ewrs.getGroupSettingsTable(groupID)
  settings.messages = args[2]
  ewrs_flagSettingsDirty(settings)
  trigger.action.outTextForGroup(groupID,"Picture reports for group turned "..onOff,ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
end

function ewrs.buildF10Menu()
  local status, result = pcall(function()
    for i = 1, #ewrs.activePlayers do
      local groupID = ewrs.activePlayers[i].groupID
      local stringGroupID = tostring(groupID)
      if ewrs.builtF10Menus[stringGroupID] == nil then
        local rootPath = missionCommands.addSubMenuForGroup(groupID, "EWRS")
        
        if ewrs.allowBogeyDope then
          missionCommands.addCommandForGroup(groupID, "Request Bogey Dope",rootPath,ewrs.onDemandMessage,{groupID,true})
        end
        
        if ewrs.onDemand then
          missionCommands.addCommandForGroup(groupID, "Request Picture",rootPath,ewrs.onDemandMessage,{groupID})
        end
        local rangeMenu = missionCommands.addSubMenuForGroup(groupID,"Set detection range",rootPath)
        for _,u in ipairs({"km","nm"}) do
          local sub = missionCommands.addSubMenuForGroup(groupID,u:upper(),rangeMenu)
          for _,r in ipairs(ewrs.rangeOptions[u]) do
            missionCommands.addCommandForGroup(groupID,r.." "..u,sub, function(args)
              local gid=args[1]
              local range=args[2]
              local settings = ewrs.getGroupSettingsTable(gid)
              settings.rangeLimit = range
              ewrs_flagSettingsDirty(settings)
              trigger.action.outTextForGroup(gid,"Range set to "..range..u,ewrs.messageDisplayTime)
              ewrs.persistGroupSettings(gid)
            end, {groupID,r})
          end
        end
        
        if ewrs.allowFriendlyPicture then
          missionCommands.addCommandForGroup(groupID, "Request Friendly Picture",rootPath,ewrs.friendlyPicture,{groupID})
        end
        
        if not ewrs.restrictToOneReference then
          local referenceSetPath = missionCommands.addSubMenuForGroup(groupID,"Set GROUP's reference point", rootPath)
          missionCommands.addCommandForGroup(groupID, "Set to Bullseye",referenceSetPath,ewrs.setGroupReference,{groupID, "bulls"})
          missionCommands.addCommandForGroup(groupID, "Set to Self",referenceSetPath,ewrs.setGroupReference,{groupID, "self"})
        end
      
        local measurementsSetPath = missionCommands.addSubMenuForGroup(groupID,"Set GROUP's measurement units",rootPath)
        missionCommands.addCommandForGroup(groupID, "Set to Imperial (feet, knts)",measurementsSetPath,ewrs.setGroupMeasurements,{groupID, "imperial"})
        missionCommands.addCommandForGroup(groupID, "Set to Metric (meters, km/h)",measurementsSetPath,ewrs.setGroupMeasurements,{groupID, "metric"})

        local showFriendliesPath=missionCommands.addSubMenuForGroup(groupID,"Show friendlies in Picture",rootPath)
        missionCommands.addCommandForGroup(groupID,"Show Friendlies ON",showFriendliesPath,ewrs.setGroupShowFriendlies,{groupID,true})
        missionCommands.addCommandForGroup(groupID,"Show Friendlies OFF",showFriendliesPath,ewrs.setGroupShowFriendlies,{groupID,false})
        local friendLimitPath=missionCommands.addSubMenuForGroup(groupID,"Set friendly limit",showFriendliesPath)
        missionCommands.addCommandForGroup(groupID,"1",friendLimitPath,ewrs.setGroupMaxFriendlies,{groupID,1})
        missionCommands.addCommandForGroup(groupID,"2",friendLimitPath,ewrs.setGroupMaxFriendlies,{groupID,2})
        missionCommands.addCommandForGroup(groupID,"3",friendLimitPath,ewrs.setGroupMaxFriendlies,{groupID,3})
        missionCommands.addCommandForGroup(groupID,"4",friendLimitPath,ewrs.setGroupMaxFriendlies,{groupID,4})
        missionCommands.addCommandForGroup(groupID,"5",friendLimitPath,ewrs.setGroupMaxFriendlies,{groupID,5})

        if not ewrs.onDemand then
          local messageOnOffPath = missionCommands.addSubMenuForGroup(groupID, "Turn Picture Report On/Off",rootPath)
          missionCommands.addCommandForGroup(groupID, "Message ON", messageOnOffPath, ewrs.setGroupMessages, {groupID, true})
          missionCommands.addCommandForGroup(groupID, "Message OFF", messageOnOffPath, ewrs.setGroupMessages, {groupID, false})
        end

        ewrs.builtF10Menus[stringGroupID] = true
      end
    end
  end)
  
  if not status then
    env.error(string.format("EWRS buildF10Menu Error: %s", result))
  end
end




--SCRIPT INIT
ewrs.currentlyDetectedRedUnits = {}
ewrs.currentlyDetectedBlueUnits = {}
ewrs.redEwrUnits = {}
ewrs.blueEwrUnits = {}
ewrs.activePlayers = {}
ewrs.groupSettings = {}
ewrs.builtF10Menus = {}
ewrs.notAvailable = 999999

ewrs.update()
if not ewrs.onDemand then
  timer.scheduleFunction(function(param, time)
  ewrs.resetRuntimeCache()
  ewrs.findRadarUnits()
  ewrs.getDetectedTargets()
  ewrs.inAuto=true
  for i = 1, #ewrs.activePlayers do
    local p = ewrs.activePlayers[i]
    if ewrs.groupSettings[tostring(p.groupID)].messages then
      ewrs.outText(p, ewrs.buildThreatTable(p))
    end
  end
  ewrs.inAuto=false
  return time + 20
end, nil, timer.getTime() + 6)
end
--trigger.action.outText("EWRS by Steggles is now running",15)
env.info("EWRS "..ewrs.version.." Running")
