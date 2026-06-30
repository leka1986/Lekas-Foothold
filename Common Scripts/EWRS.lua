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
local L10N = FH_L10N
ewrs.HELO = 1
ewrs.ATTACK = 2
ewrs.FIGHTER = 3
ewrs.version = "2.0.0"

local function ewrsBuildRangeOptions(maxKm, maxNm)
  local function build(values, maxValue)
    local result = {}
    local limit = tonumber(maxValue) or values[#values]
    for _,value in ipairs(values) do
      if value <= limit then
        result[#result + 1] = value
      end
    end
    if #result == 0 then
      result[1] = values[1]
    end
    return result
  end

  return {
    km = build({10,20,40,60,80,100,150}, maxKm),
    nm = build({5,10,20,40,60,80,100}, maxNm)
  }
end

ewrs.maxRangeKm = ewrs_maxRangeKm or 150
ewrs.maxRangeNm = ewrs_maxRangeNm or 100
ewrs.rangeOptions = ewrs_rangeOptions or ewrsBuildRangeOptions(ewrs.maxRangeKm, ewrs.maxRangeNm)

local function ewrsGetMaxRangeOption(unit)
  local maxOption = nil
  for _,value in ipairs((ewrs.rangeOptions and ewrs.rangeOptions[unit]) or {}) do
    local numberValue = tonumber(value)
    if numberValue and (maxOption == nil or numberValue > maxOption) then
      maxOption = numberValue
    end
  end
  return maxOption
end

local function ewrsClampDefaultRangeLimit(rangeLimit, measurements)
  local limit = tonumber(rangeLimit) or 0
  if limit <= 0 then return limit end
  local unit = measurements == "metric" and "km" or "nm"
  local maxOption = ewrsGetMaxRangeOption(unit)
  if maxOption and limit > maxOption then return maxOption end
  return limit
end

local function ewrsAltitudeDisplayModeValue(value)
  local mode = string.lower(tostring(value or "modern"))
  if mode == "wwii" or mode == "ww2" then return "wwii" end
  return "modern"
end

----SCRIPT OPTIONS----

ewrs.messageUpdateInterval = ewrs_messageUpdateInterval or 60 --How often EWRS will update automated BRA messages (seconds)
ewrs.messageDisplayTime = ewrs_messageDisplayTime or 15 --How long EWRS BRA messages will show for (seconds)
if ewrs_restrictToOneReference ~= nil then ewrs.restrictToOneReference = ewrs_restrictToOneReference else ewrs.restrictToOneReference = false end -- Disables the ability to change the BRA calls from pilot's own aircraft or bullseye. If this is true, set ewrs.defaultReference to the option you want to restrict to.
ewrs.defaultReference = ewrs_defaultReference or "self" --The default reference for BRA calls - can be changed via f10 radio menu if ewrs.restrictToOneReference is false (self or bulls)
ewrs.defaultMeasurements = ewrs_defaultMeasurements or "imperial" --Default measurement units - can be changed via f10 radio menu (imperial or metric)
ewrs.defaultAircraftRangeLimit = ewrs_defaultAircraftRangeLimit or 60
ewrs.defaultHelicopterRangeLimit = ewrs_defaultHelicopterRangeLimit or 20
if ewrs_defaultShowTankers ~= nil then ewrs.defaultShowTankers = ewrs_defaultShowTankers else ewrs.defaultShowTankers = false end -- Default show tankers in picture report
if ewrs_enableRedTeam ~= nil then ewrs.enableRedTeam = ewrs_enableRedTeam else ewrs.enableRedTeam = true end -- enables / disables EWRS for the red team
if ewrs_enableBlueTeam ~= nil then ewrs.enableBlueTeam = ewrs_enableBlueTeam else ewrs.enableBlueTeam = true end -- enables / disables EWRS for the blue team
if ewrs_disableMessageWhenNoThreats ~= nil then ewrs.disableMessageWhenNoThreats = ewrs_disableMessageWhenNoThreats else ewrs.disableMessageWhenNoThreats = true end -- disables message when no threats are detected - Thanks Rivvern - NOTE: If using ewrs.onDemand = true, this has no effect
if ewrs_onDemand ~= nil then ewrs.onDemand = ewrs_onDemand else ewrs.onDemand = false end --Setting to true will disable the automated messages to everyone and will add an F10 menu to get picture / BRA message.
ewrs.maxThreatDisplay = ewrs_maxThreatDisplay or 5 -- Max amounts of threats to display on picture report (0 will display all)
if ewrs_allowBogeyDope ~= nil then ewrs.allowBogeyDope = ewrs_allowBogeyDope else ewrs.allowBogeyDope = true end -- Allows pilots to request a bogey dope even with the automated messages running. It will display only the cloest threat, and will always reference the players own aircraft.
if ewrs_allowFriendlyPicture ~= nil then ewrs.allowFriendlyPicture = ewrs_allowFriendlyPicture else ewrs.allowFriendlyPicture = true end -- Allows pilots to request picture of friendly aircraft
ewrs.maxFriendlyDisplay = ewrs_maxFriendlyDisplay or 5 -- Limits the amount of friendly aircraft shown on friendly picture
if ewrs_showType ~= nil then ewrs.showType = ewrs_showType else ewrs.showType = true end -- if true it will show the type of the unit
ewrs.defaultReportStyle = tonumber(ewrs_defaultReportStyle) or 1
if ewrs.defaultReportStyle ~= 2 then ewrs.defaultReportStyle = 1 end
ewrs.altitudeDisplayMode = ewrsAltitudeDisplayModeValue(ewrs_altitudeDisplayMode)
ewrs.mergedRangeNm = tonumber(ewrs_mergedRangeNm) or 5
ewrs.hiddenFriendlyReportingNames = ewrs_hiddenFriendlyReportingNames or { Sentry = true }
ewrs.specialPlaneTypes = ewrs_specialPlaneTypes or {
  ["F-4E-45MC"] = true,
  ["MiG-29 Fulcrum"] = true,
  ["F-5E-3_FC"] = true,
  ["C-130J-30"] = true,
}
ewrs.reportingNameOverrides = {
  ["A-20G"] = "A-20G",
  ["B-17G"] = "B-17G",
  ["P-51D-30-NA"] = "Mustang",
  ["SpitfireLFMkIX"] = "Spitfire",
  ["MosquitoFBMkVI"] = "Mosquito",
  ["Bf-109K-4"] = "Bf 109",
  ["FW-190A8"] = "FW 190 A-8",
  ["FW-190D9"] = "FW 190 D-9",
  ["C-47"] = "Skytrain",
  ["F4U-1D"] = "Corsair",
  ["F4U-1D_CW"] = "Corsair",
  ["I-16"] = "I-16",
  ["Ju-88A4"] = "Ju 88 A-4",
  ["P-47D-30"] = "Thunderbolt",
  ["P-47D-30bl1"] = "Thunderbolt",
  ["P-47D-40"] = "Thunderbolt",
  ["P-51D"] = "Mustang",
  ["SpitfireLFMkIXCW"] = "Spitfire",
  ["La-7"] = "La-7",
  ["TF-51D"] = "Mustang",
}

local function ewrs_isSpecialPlaneType(unitType)
  return unitType and ewrs.specialPlaneTypes[unitType] == true
end

local function ewrsGetUnitTypeName(unit)
  if not unit then return nil end
  if unit.getTypeName then return unit:getTypeName() end
  if unit.GetTypeName then return unit:GetTypeName() end
  return nil
end

local function ewrs_isSpecialPlaneUnit(unit)
  return ewrs_isSpecialPlaneType(ewrsGetUnitTypeName(unit))
end

function ewrs.shouldHideFriendlyReportingName(name)
  return name and ewrs.hiddenFriendlyReportingNames[name] == true
end

local function ewrsGetPlayerDisplayName(playerName)
  if not playerName then
    return playerName
  end
  if type(getPlayerDisplayName) == "function" then
    return getPlayerDisplayName(playerName)
  end
  if type(getPlayerAssignment) == "function" then
    local callsign = select(1, getPlayerAssignment(playerName))
    if callsign and callsign ~= "" then
      return callsign
    end
  end
  return playerName
end

local function ewrsStatusLabel(value, caps, translator)
  local T = translator or L10N
  if caps then
    return T:Get(value and "EWRS_STATUS_ON_CAPS" or "EWRS_STATUS_OFF_CAPS")
  end
  return T:Get(value and "EWRS_STATUS_ON" or "EWRS_STATUS_OFF")
end

local function ewrsReferenceLabel(reference, translator)
  local T = translator or L10N
  if reference == "bulls" then return T:Get("EWRS_REFERENCE_BULLS") end
  if reference == "self" then return T:Get("EWRS_REFERENCE_SELF") end
  return tostring(reference)
end

local function ewrsMeasurementLabel(measurements, translator)
  local T = translator or L10N
  if measurements == "imperial" then return T:Get("EWRS_MEASUREMENTS_IMPERIAL") end
  if measurements == "metric" then return T:Get("EWRS_MEASUREMENTS_METRIC") end
  return tostring(measurements)
end

local function ewrsReportStyleValue(value)
  local style = tonumber(value) or 1
  if style == 2 then return 2 end
  return 1
end

local function ewrsReportStyleLabel(style, translator)
  local T = translator or L10N
  return T:Get(ewrsReportStyleValue(style) == 2 and "EWRS_REPORT_STYLE_2" or "EWRS_REPORT_STYLE_1")
end

local function ewrsAspectLabel(aspect, translator)
  local T = translator or L10N
  local key = "EWRS_ASPECT_" .. string.upper(tostring(aspect or ""))
  local text = T:Get(key)
  if text ~= key then return text end
  return string.upper(tostring(aspect or ""))
end

local function ewrsUnitTypeLabel(unitType, translator)
  local T = translator or L10N
  return unitType or T:Get("EWRS_UNKNOWN")
end

local function ewrsReportingNameOverride(typeName)
  local override = typeName and ewrs.reportingNameOverrides[typeName]
  if type(override) == "string" and override ~= "" then return override end
  return nil
end

local function ewrsContactUnitTypeLabel(contact, translator)
  local T = translator or L10N
  if not ewrs.showType then return T:Get("EWRS_UNKNOWN") end
  local override = ewrsReportingNameOverride(contact.typeName)
  if override then return override end
  local unitType = ewrsUnitTypeLabel(contact.unitType, T)
  if contact.isFriendly and unitType == "Bogey" then unitType = T:Get("EWRS_UNKNOWN") end
  return unitType
end

ewrs.runtimeCache = { units = {}, friendlyGroups = {}, friendlyAirUnits = {}, groupSettings = {} }

function ewrs.resetRuntimeCache()
  ewrs.runtimeCache.units = {}
  ewrs.runtimeCache.friendlyGroups = {}
  ewrs.runtimeCache.friendlyAirUnits = {}
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

function ewrs.getCachedFriendlyAirUnits(coalitionId)
  local cached = ewrs.runtimeCache.friendlyAirUnits[coalitionId]
  if cached then return cached end
  local friendlyUnits = {}
  local groups = ewrs.getCachedCoalitionGroups(coalitionId)
  for _,grp in ipairs(groups) do
    local gname=grp:getName()
    if gname~="Arco" and gname~="Texaco" then
      local units=grp:getUnits() or{}
      for _,u in ipairs(units) do
        if u and u:isExist() and u:isActive() and u:inAir() and u:getLife()>0 then
          friendlyUnits[#friendlyUnits+1]=u
        end
      end
    end
  end
  ewrs.runtimeCache.friendlyAirUnits[coalitionId] = friendlyUnits
  return friendlyUnits
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
    maxThreats = src.maxThreats,
    showFriendlies = src.showFriendlies,
    showTankers = src.showTankers,
    maxFriendlies = src.maxFriendlies,
    messages = src.messages,
    reportStyle = src.reportStyle,
    customized = src.customized or src._hasCustomizations or false,
  }
end

local function ewrs_settingsEqual(a, b)
  if a == b then return true end
  if type(a) ~= "table" or type(b) ~= "table" then return false end
  local keys = {"reference","measurements","rangeLimit","maxThreats","showFriendlies","showTankers","maxFriendlies","messages","reportStyle"}
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
      saved = profiles.plane or profiles.default
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
  ewrs.buildActivePlayers()
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
    local dcsTypeName=ewrsGetUnitTypeName(obj)
    local unit=UNIT:Find(obj) if unit then bogeyType=unit:GetNatoReportingName() end
    if not bogeyType then bogeyType = "Unknown" end  
    local bearing = (math.floor((ewrs.getBearing(referenceX,referenceZ,bogeypos.p.x,bogeypos.p.z)+2.5)/5)*5) % 360
    if bearing == 0 then bearing = 360 end
    local heading=ewrs.getHeading(velocity)
    local aspect=ewrs.getAspect(bearing,heading)
    local range=ewrs.getDistance(referenceX,referenceZ,bogeypos.p.x,bogeypos.p.z)
    local rawRangeNm=UTILS.MetersToNM(range)
    local altitude=bogeypos.p.y
    local altitudeFeet=UTILS.MetersToFeet(altitude)
    local speed=ewrs.getSpeed(velocity)
    if useMetric then
      local km=range/1000
      if km>=60 then range=UTILS.Round(km,-1) elseif km>=20 then range=UTILS.Round(km/5,0)*5 else range=UTILS.Round(km,0) end
      speed=UTILS.Round(UTILS.MpsToKmph(speed),-1)
      altitude=UTILS.Round(altitude,-1)
    else
      local nm=rawRangeNm
      if nm>=60 then range=UTILS.Round(nm,-1) elseif nm>=20 then range=UTILS.Round(nm/5,0)*5 else range=UTILS.Round(nm,0) end
      speed=UTILS.Round(UTILS.MpsToKnots(speed),-1)
      altitude=UTILS.Round(UTILS.MetersToFeet(altitude),-3)
    end
    if rangeLimit==0 or range<=rangeLimit then
      local j=#threatTable+1
      threatTable[j]={}
      threatTable[j].unitType=bogeyType
      threatTable[j].typeName=dcsTypeName
      threatTable[j].bearing=bearing
      threatTable[j].range=range
      threatTable[j].rawRangeNm=rawRangeNm
      threatTable[j].altitude=altitude
      threatTable[j].altitudeFeet=altitudeFeet
      threatTable[j].speed=speed
      threatTable[j].heading=heading
      threatTable[j].aspect=aspect
    end
  end
    if activePlayer.side==2 and not bogeyDope and groupSettings.showTankers then

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
        local altitudeFeet=UTILS.MetersToFeet(altitude)
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
        threatTable[j].altitudeFeet=altitudeFeet
        threatTable[j].speed=speed
        threatTable[j].heading=heading
        threatTable[j].aspect=aspect
      end
    end
    addTanker("Arco","Drouge")
    addTanker("Texaco","Boom")
    addTanker("Shell","Boom")
  end
  if groupSettings.showFriendlies and not bogeyDope then
    local units=ewrs.getCachedFriendlyAirUnits(activePlayer.side)
    for _,u in ipairs(units) do
      if u:getName()~=activePlayer.unitname then
        local tp=u:getPosition()
        local vel=u:getVelocity()
        local bearing=(math.floor((ewrs.getBearing(referenceX,referenceZ,tp.p.x,tp.p.z)+2.5)/5)*5)%360
        if bearing==0 then bearing=360 end
        local heading=ewrs.getHeading(vel)
        local aspect=ewrs.getAspect(bearing,heading)
        local range=ewrs.getDistance(referenceX,referenceZ,tp.p.x,tp.p.z)
        local altitude=tp.p.y
        local altitudeFeet=UTILS.MetersToFeet(altitude)
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
          local dcsTypeName=ewrsGetUnitTypeName(u)
          if unit then bogeyType=unit:GetNatoReportingName() end
          if not bogeyType then bogeyType="Unknown" end
          if not ewrs.shouldHideFriendlyReportingName(bogeyType) then
            local j=#threatTable+1
            threatTable[j]={}
            threatTable[j].unitType=bogeyType
            threatTable[j].typeName=dcsTypeName
            threatTable[j].isFriendly=true
            threatTable[j].bearing=bearing
            threatTable[j].range=range
            threatTable[j].altitude=altitude
            threatTable[j].altitudeFeet=altitudeFeet
            threatTable[j].speed=speed
            threatTable[j].heading=heading
            threatTable[j].aspect=aspect
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

local function ewrsAltitudeText(contact, altUnits)
  if ewrs.altitudeDisplayMode == "wwii" then
    local altitudeFeet = tonumber(contact.altitudeFeet)
    if not altitudeFeet then
      local altitude = tonumber(contact.altitude) or 0
      altitudeFeet = altUnits == "m" and UTILS.MetersToFeet(altitude) or altitude
    end
    if altitudeFeet < 5000 then return "Low" end
    if altitudeFeet < 10000 then return "Medium" end
    return "High"
  end
  return contact.altitude..altUnits
end


function ewrs.formatContactLine(contact, groupSettings, rangeUnits, altUnits, translator)
  local T = translator or L10N
  local unitType = ewrsContactUnitTypeLabel(contact, T)
  local asp = ewrsAspectLabel(contact.aspect, T)
  local altitudeText = ewrsAltitudeText(contact, altUnits)
  if ewrsReportStyleValue(groupSettings.reportStyle) == 2 then
    local line = T:Format("EWRS_CONTACT_LINE_STYLE_2", contact.bearing, contact.range.." "..rangeUnits, altitudeText, asp, unitType)
    if not contact.isFriendly and contact.rawRangeNm and ewrs.mergedRangeNm > 0 and contact.rawRangeNm < ewrs.mergedRangeNm then
      line = line .. " | " .. T:Get("EWRS_MERGED")
    end
    return line
  end
  return T:Format("EWRS_CONTACT_LINE", unitType, contact.bearing, contact.range..rangeUnits, altitudeText, asp)
end

function ewrs.getFriendlyHeader(groupSettings, translator)
  local T = translator or L10N
  if ewrsReportStyleValue(groupSettings.reportStyle) == 2 then
    return T:Get("EWRS_FRIENDLY_HEADER_STYLE_2")
  end
  return T:Get("EWRS_FRIENDLY_HEADER")
end


function ewrs.outText(activePlayer, threatTable, bogeyDope, greeting)
  local status, result = pcall(function()
    
    local message = {}
    local groupSettings = ewrs.getGroupSettingsTable(activePlayer.groupID)
    local T = L10N:ForGroup(activePlayer.groupID)
    local displayPlayerName = ewrsGetPlayerDisplayName(activePlayer.player)
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
          messageGreeting = T:Format("EWRS_BOGEY_DOPE_FOR", displayPlayerName)
        else
          local threatLimit = groupSettings.maxThreats
          if threatLimit == nil then
            threatLimit = ewrs.maxThreatDisplay
          end
          if threatLimit == 0 then
            maxThreats = 999
          else
            maxThreats = threatLimit
          end
          messageGreeting = T:Format("EWRS_REPORT_RELATIVE", displayPlayerName, ewrsReferenceLabel(groupSettings.reference, T))
        end
      else
        messageGreeting = greeting
        local friendlyLimit = groupSettings.maxFriendlies
        if friendlyLimit == nil then
          friendlyLimit = ewrs.maxFriendlyDisplay
        end
        if friendlyLimit == 0 then
          maxThreats = 999
        else
          maxThreats = friendlyLimit
        end
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
              table.insert(message,T:Format("EWRS_POSITION_UNKNOWN", ewrsUnitTypeLabel(t.unitType, T)))
            else
              table.insert(message,ewrs.formatContactLine(t, groupSettings, rangeUnits, altUnits, T))
            end
            shown=shown+1
            if shown<maxThreats then table.insert(message,"\n") end
          end
        end
        for k=1,#threatTable do
          local t=threatTable[k]
          if t and t.isFriendly then
            if not friendlyHeader then if message[#message] ~= "\n" then table.insert(message,"\n") end table.insert(message,"\n"); table.insert(message,ewrs.getFriendlyHeader(groupSettings, T)); table.insert(message,"\n"); friendlyHeader=true end
            if t.range==ewrs.notAvailable then
              table.insert(message,T:Format("EWRS_POSITION_UNKNOWN", ewrsUnitTypeLabel(t.unitType, T)))
            else
              table.insert(message,ewrs.formatContactLine(t, groupSettings, rangeUnits, altUnits, T))
            end
            if k<#threatTable then table.insert(message,"\n") end
          end
        end
      else
        for k=1,maxThreats do
          if threatTable[k]==nil then break end
          if greeting==nil and not friendlyHeader and threatTable[k].isFriendly then table.insert(message,"\n"); table.insert(message,ewrs.getFriendlyHeader(groupSettings, T)); table.insert(message,"\n"); friendlyHeader=true end
          if threatTable[k].range==ewrs.notAvailable then
            table.insert(message,T:Format("EWRS_POSITION_UNKNOWN", ewrsUnitTypeLabel(threatTable[k].unitType, T)))
          else
            table.insert(message,ewrs.formatContactLine(threatTable[k], groupSettings, rangeUnits, altUnits, T))
          end
          if threatTable[k+1]~=nil then
          table.insert(message,"\n")
          end
        end
      end
       trigger.action.outTextForGroup(activePlayer.groupID,table.concat(message),ewrs.messageDisplayTime)
    else
      if bogeyDope then
        trigger.action.outTextForGroup(activePlayer.groupID, T:Format("EWRS_BOGEY_DOPE_FOR", displayPlayerName) .. "\n" .. T:Get("EWRS_NO_TARGETS_DETECTED"), ewrs.messageDisplayTime)
      elseif (not ewrs.disableMessageWhenNoThreats) and greeting == nil then
        trigger.action.outTextForGroup(activePlayer.groupID, T:Format("EWRS_PICTURE_REPORT_FOR", displayPlayerName) .. "\n" .. T:Get("EWRS_NO_TARGETS_DETECTED"), ewrs.messageDisplayTime)
      end
      if greeting ~= nil then
        trigger.action.outTextForGroup(activePlayer.groupID, T:Format("EWRS_FRIENDLY_PICTURE_FOR", displayPlayerName) .. "\n" .. T:Get("EWRS_NO_FRIENDLIES_DETECTED"), ewrs.messageDisplayTime)
      end
    end
  end)
  if not status then
    env.error(string.format("EWRS outText Error: %s", result))
  end
end



function ewrs.onDemandMessage(args)
  local status, result = pcall(function()
    ewrs.runtimeCache.friendlyAirUnits = {}
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
      local dcsTypeName=ewrsGetUnitTypeName(v)
      if not bogeyType then bogeyType = "Unknown" end
      if not ewrs.shouldHideFriendlyReportingName(bogeyType) and pos.p.x~=selfpos.p.x and pos.p.z~=selfpos.p.z then
        local bearing=ewrs.getBearing(referenceX,referenceZ,pos.p.x,pos.p.z)
        local heading=ewrs.getHeading(velocity)
        local range=ewrs.getDistance(referenceX,referenceZ,pos.p.x,pos.p.z)
        local altitude=pos.p.y
        local altitudeFeet=UTILS.MetersToFeet(altitude)
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
        friendlyTable[j].typeName=dcsTypeName
        friendlyTable[j].isFriendly=true
        friendlyTable[j].bearing=bearing
        friendlyTable[j].range=range
        friendlyTable[j].altitude=altitude
        friendlyTable[j].altitudeFeet=altitudeFeet
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
        local T = L10N:ForGroup(ewrs.activePlayers[i].groupID)
        local greeting = T:Format("EWRS_FRIENDLY_PICTURE_FOR", ewrsGetPlayerDisplayName(ewrs.activePlayers[i].player))
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


function ewrs.addPlayer(playerName, groupID, unit, unitType)
  if not playerName or not groupID or not unit then return end

  local isHelo = unit:hasAttribute("Helicopters")
  local unitType = unitType or unit:getTypeName()
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
    ewrs.activePlayers[i].unitType = unitType
    ewrs.activePlayers[i].side = unit:getCoalition() 
    ewrs.groupUnitTypes = ewrs.groupUnitTypes or {}
    ewrs.groupUnitTypes[tostring(groupID)] = unitType
  
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

function ewrs.removeActivePlayersForGroup(groupID)
  if not groupID then return end
  local stringGroupID = tostring(groupID)
  local kept = {}
  for i = 1, #(ewrs.activePlayers or {}) do
    local activePlayer = ewrs.activePlayers[i]
    if tostring(activePlayer.groupID) ~= stringGroupID then
      kept[#kept + 1] = activePlayer
    end
  end
  ewrs.activePlayers = kept
end

function ewrs.registerPlayer(playerName, groupID, unit, unitType)
  if not playerName or not groupID or not unit then return end
  local stringGroupID = tostring(groupID)
  ewrs.removeActivePlayersForGroup(groupID)
  ewrs.groupSettings[stringGroupID] = nil
  ewrs.runtimeCache.groupSettings[stringGroupID] = nil
  ewrs.groupUnitTypes = ewrs.groupUnitTypes or {}
  ewrs.groupUnitTypes[stringGroupID] = unitType or unit:getTypeName()
  ewrs.addPlayer(playerName, groupID, unit, ewrs.groupUnitTypes[stringGroupID])
  ewrs.ensureGroupF10Menu(groupID)
end

function ewrs.pruneGroup(groupID)
  if not groupID then return end
  local stringGroupID = tostring(groupID)
  ewrs.removeActivePlayersForGroup(groupID)
  ewrs.groupSettings[stringGroupID] = nil
  ewrs.runtimeCache.groupSettings[stringGroupID] = nil
  ewrs.groupUnitTypes = ewrs.groupUnitTypes or {}
  ewrs.groupUnitTypes[stringGroupID] = nil
  if EWRS_MENU_PARENT_BY_GROUP then
    EWRS_MENU_PARENT_BY_GROUP[stringGroupID] = nil
  end
  ewrs.removeGroupF10Menu(groupID)
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
  ewrs.groupSettings[groupID].rangeLimit=ewrsClampDefaultRangeLimit(isHelo and ewrs.defaultHelicopterRangeLimit or ewrs.defaultAircraftRangeLimit, ewrs.groupSettings[groupID].measurements)
  ewrs.groupSettings[groupID].maxThreats=ewrs.maxThreatDisplay
  ewrs.groupSettings[groupID].showFriendlies=showFriendlies and true or false
  ewrs.groupSettings[groupID].showTankers=ewrs.defaultShowTankers
  ewrs.groupSettings[groupID].maxFriendlies=ewrs.maxFriendlyDisplay
  ewrs.groupSettings[groupID].reportStyle=ewrs.defaultReportStyle
end

function ewrs.removeGroupF10Menu(groupID)
  local stringGroupID = tostring(groupID)
  local menuHandle = ewrs.builtF10Menus[stringGroupID]
  if menuHandle then
    missionCommands.removeItemForGroup(groupID, menuHandle)
    ewrs.builtF10Menus[stringGroupID] = nil
  end
end

function ewrs.ensureGroupF10Menu(groupID)
  ewrs.buildF10Menu(groupID)
end

function ewrs.refreshGroupF10Menu(groupID)
  ewrs.removeGroupF10Menu(groupID)
  ewrs.ensureGroupF10Menu(groupID)
end

function ewrs.setGroupMaxFriendlies(args)
  local groupID=args[1]
  local value=args[2]
  local settings=ewrs.getGroupSettingsTable(groupID)
  settings.maxFriendlies=value
  ewrs_flagSettingsDirty(settings)
  local T = L10N:ForGroup(groupID)
  local msg
  if value==0 then
    msg=T:Get("EWRS_FRIENDLY_CONTACT_LIMIT_ALL")
  else
    msg=T:Format("EWRS_FRIENDLY_CONTACT_LIMIT_VALUE", value)
  end
  trigger.action.outTextForGroup(groupID,msg,ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
  ewrs.refreshGroupF10Menu(groupID)
end
function ewrs.setGroupMaxThreats(args)
  local groupID=args[1]
  local value=args[2]
  local settings=ewrs.getGroupSettingsTable(groupID)
  settings.maxThreats=value
  ewrs_flagSettingsDirty(settings)
  local T = L10N:ForGroup(groupID)
  local msg
  if value==0 then
    msg=T:Get("EWRS_THREAT_LIMIT_ALL")
  else
    msg=T:Format("EWRS_THREAT_LIMIT_VALUE", value)
  end
  trigger.action.outTextForGroup(groupID,msg,ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
  ewrs.refreshGroupF10Menu(groupID)
end
function ewrs.setGroupShowFriendlies(args)
  local groupID=args[1]
  local settings=ewrs.getGroupSettingsTable(groupID)
  settings.showFriendlies=args[2]
  ewrs_flagSettingsDirty(settings)
  local T = L10N:ForGroup(groupID)
  local onOff=ewrsStatusLabel(args[2], false, T)
  trigger.action.outTextForGroup(groupID,T:Format("EWRS_FRIENDLY_CONTACTS_TURNED", onOff),ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
  ewrs.refreshGroupF10Menu(groupID)
end

function ewrs.setGroupShowTankers(args)
  local groupID=args[1]
  local settings=ewrs.getGroupSettingsTable(groupID)
  settings.showTankers=args[2]
  ewrs_flagSettingsDirty(settings)
  local T = L10N:ForGroup(groupID)
  local onOff=ewrsStatusLabel(args[2], false, T)
  trigger.action.outTextForGroup(groupID,T:Format("EWRS_TANKER_CONTACTS_TURNED", onOff),ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
  ewrs.refreshGroupF10Menu(groupID)
end

function ewrs.setGroupReference(args)
  local groupID = args[1]
  local settings = ewrs.getGroupSettingsTable(groupID)
  settings.reference = args[2]
  ewrs_flagSettingsDirty(settings)
  local T = L10N:ForGroup(groupID)
  trigger.action.outTextForGroup(groupID,T:Format("EWRS_REFERENCE_CHANGED", ewrsReferenceLabel(args[2], T)),ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
  ewrs.refreshGroupF10Menu(groupID)
end

function ewrs.setGroupMeasurements(args)
  local groupID = args[1]
  local groupSettings = ewrs.getGroupSettingsTable(groupID)
  local oldUnits = groupSettings.measurements
  local newUnits = args[2]
  if oldUnits ~= newUnits then
    if newUnits == "metric" then
      groupSettings.rangeLimit = UTILS.Round((groupSettings.rangeLimit or 0) * 1.852, 0)
    else
      groupSettings.rangeLimit = UTILS.Round((groupSettings.rangeLimit or 0) / 1.852, 0)
    end
  end
  groupSettings.measurements = newUnits
  ewrs_flagSettingsDirty(groupSettings)
  local T = L10N:ForGroup(groupID)
  trigger.action.outTextForGroup(groupID,T:Format("EWRS_MEASUREMENT_UNITS_CHANGED", ewrsMeasurementLabel(newUnits, T)),ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
  ewrs.refreshGroupF10Menu(groupID)
end

function ewrs.setGroupReportStyle(args)
  local groupID = args[1]
  local settings = ewrs.getGroupSettingsTable(groupID)
  local style = ewrsReportStyleValue(args[2])
  settings.reportStyle = style
  ewrs_flagSettingsDirty(settings)
  local T = L10N:ForGroup(groupID)
  trigger.action.outTextForGroup(groupID,T:Format("EWRS_REPORT_STYLE_CHANGED", ewrsReportStyleLabel(style, T)),ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
  ewrs.refreshGroupF10Menu(groupID)
end

function ewrs.setGroupMessages(args)
  local groupID = args[1]
  local settings = ewrs.getGroupSettingsTable(groupID)
  settings.messages = args[2]
  ewrs_flagSettingsDirty(settings)
  local T = L10N:ForGroup(groupID)
  local onOff = ewrsStatusLabel(args[2], false, T)
  trigger.action.outTextForGroup(groupID,T:Format("EWRS_AUTO_PICTURE_TURNED", onOff),ewrs.messageDisplayTime)
  ewrs.persistGroupSettings(groupID)
  ewrs.refreshGroupF10Menu(groupID)
end

function ewrs.buildF10Menu(targetGroupID)
  local status, result = pcall(function()
    local targetKey = targetGroupID and tostring(targetGroupID) or nil
    for i = 1, #ewrs.activePlayers do
      local groupID = ewrs.activePlayers[i].groupID
      local stringGroupID = tostring(groupID)
      if not targetKey or stringGroupID == targetKey then
      local groupSettings = ewrs.getGroupSettingsTable(groupID)
      local T = L10N:ForGroup(groupID)

      if ewrs.builtF10Menus[stringGroupID] == nil then
        local desiredParent = nil
        if EWRS_MENU_PARENT_BY_GROUP and EWRS_MENU_PARENT_BY_GROUP[stringGroupID] then
          desiredParent = EWRS_MENU_PARENT_BY_GROUP[stringGroupID]
        end
        local rootPath = missionCommands.addSubMenuForGroup(groupID, T:Get("EWRS_MENU_ROOT"), desiredParent)
        
        if ewrs.allowBogeyDope and (ewrs.onDemand or not groupSettings.messages) then
          missionCommands.addCommandForGroup(groupID, T:Get("EWRS_REQUEST_BOGEY_DOPE"),rootPath,ewrs.onDemandMessage,{groupID,true})
        end
        
        if ewrs.onDemand then
          missionCommands.addCommandForGroup(groupID, T:Get("EWRS_REQUEST_PICTURE"),rootPath,ewrs.onDemandMessage,{groupID})
        end
        local rangeMenu = missionCommands.addSubMenuForGroup(groupID,T:Get("EWRS_SET_DETECTION_RANGE"),rootPath)
        for _,u in ipairs({"km","nm"}) do
          local subLabel = u:upper()
          local selectedMeasurements = (u == "km") and "metric" or "imperial"
          if groupSettings.measurements == selectedMeasurements then
            subLabel = subLabel .. T:Get("EWRS_CURRENT_SUFFIX")
          end
          local sub = missionCommands.addSubMenuForGroup(groupID,subLabel,rangeMenu)
          for _,r in ipairs(ewrs.rangeOptions[u]) do
            local label = r.." "..u
            if groupSettings.measurements == selectedMeasurements and groupSettings.rangeLimit == r then
              label = label .. T:Get("EWRS_CURRENT_SUFFIX")
            end
            missionCommands.addCommandForGroup(groupID,label,sub, function(args)
              local gid=args[1]
              local range=args[2]
              local selectedUnit=args[3]
              local settings = ewrs.getGroupSettingsTable(gid)
              if selectedUnit == "km" then
                settings.measurements = "metric"
              elseif selectedUnit == "nm" then
                settings.measurements = "imperial"
              end
              settings.rangeLimit = range
              ewrs_flagSettingsDirty(settings)
              local TGroup = L10N:ForGroup(gid)
              trigger.action.outTextForGroup(gid,TGroup:Format("EWRS_RANGE_SET", range, selectedUnit),ewrs.messageDisplayTime)
              ewrs.persistGroupSettings(gid)
              ewrs.refreshGroupF10Menu(gid)
            end, {groupID,r,u})
          end
        end
        local threatLimitPath = missionCommands.addSubMenuForGroup(groupID,T:Get("EWRS_SET_THREAT_LIMIT"),rootPath)
        for _,value in ipairs({1,2,3,4,5}) do
          local label = tostring(value) .. ((groupSettings.maxThreats == value) and T:Get("EWRS_CURRENT_SUFFIX") or "")
          missionCommands.addCommandForGroup(groupID,label,threatLimitPath,ewrs.setGroupMaxThreats,{groupID,value})
        end
        local allThreatsLabel = T:Get("EWRS_ALL") .. ((groupSettings.maxThreats == 0) and T:Get("EWRS_CURRENT_SUFFIX") or "")
        missionCommands.addCommandForGroup(groupID,allThreatsLabel,threatLimitPath,ewrs.setGroupMaxThreats,{groupID,0})

        local friendliesPath = missionCommands.addSubMenuForGroup(groupID,T:Get("EWRS_FRIENDLIES"),rootPath)
        local showFriendliesLabel = T:Format("EWRS_SHOW_FRIENDLIES_CURRENT", ewrsStatusLabel(groupSettings.showFriendlies, true, T))
        missionCommands.addCommandForGroup(groupID,showFriendliesLabel,friendliesPath,ewrs.setGroupShowFriendlies,{groupID,not groupSettings.showFriendlies})
        local friendLimitPath=missionCommands.addSubMenuForGroup(groupID,T:Get("EWRS_SET_FRIENDLY_LIMIT"),friendliesPath)
        for _,value in ipairs({1,2,3,4,5}) do
          local label = tostring(value) .. ((groupSettings.maxFriendlies == value) and T:Get("EWRS_CURRENT_SUFFIX") or "")
          missionCommands.addCommandForGroup(groupID,label,friendLimitPath,ewrs.setGroupMaxFriendlies,{groupID,value})
        end
        local showTankersLabel = T:Format("EWRS_SHOW_TANKERS_CURRENT", ewrsStatusLabel(groupSettings.showTankers, true, T))
        missionCommands.addCommandForGroup(groupID,showTankersLabel,friendliesPath,ewrs.setGroupShowTankers,{groupID,not groupSettings.showTankers})

        if not ewrs.onDemand then
          local autoPictureLabel = T:Format("EWRS_AUTO_PICTURE_CURRENT", ewrsStatusLabel(groupSettings.messages, true, T))
          missionCommands.addCommandForGroup(groupID, autoPictureLabel, rootPath, ewrs.setGroupMessages, {groupID, not groupSettings.messages})
        end

        local groupSettingsPath = missionCommands.addSubMenuForGroup(groupID,T:Get("EWRS_GROUP_SETTINGS"),rootPath)

        if not ewrs.restrictToOneReference then
          local referenceSetPath = missionCommands.addSubMenuForGroup(groupID,T:Get("EWRS_SET_GROUP_REFERENCE"), groupSettingsPath)
          local bullsLabel = T:Get("EWRS_SET_TO_BULLSEYE") .. ((groupSettings.reference == "bulls") and T:Get("EWRS_CURRENT_SUFFIX") or "")
          local selfLabel = T:Get("EWRS_SET_TO_SELF") .. ((groupSettings.reference == "self") and T:Get("EWRS_CURRENT_SUFFIX") or "")
          missionCommands.addCommandForGroup(groupID, bullsLabel,referenceSetPath,ewrs.setGroupReference,{groupID, "bulls"})
          missionCommands.addCommandForGroup(groupID, selfLabel,referenceSetPath,ewrs.setGroupReference,{groupID, "self"})
        end
      
        local measurementsSetPath = missionCommands.addSubMenuForGroup(groupID,T:Get("EWRS_SET_GROUP_MEASUREMENTS"),groupSettingsPath)
        local imperialLabel = T:Get("EWRS_SET_TO_IMPERIAL") .. ((groupSettings.measurements == "imperial") and T:Get("EWRS_CURRENT_SUFFIX") or "")
        local metricLabel = T:Get("EWRS_SET_TO_METRIC") .. ((groupSettings.measurements == "metric") and T:Get("EWRS_CURRENT_SUFFIX") or "")
        missionCommands.addCommandForGroup(groupID, imperialLabel,measurementsSetPath,ewrs.setGroupMeasurements,{groupID, "imperial"})
        missionCommands.addCommandForGroup(groupID, metricLabel,measurementsSetPath,ewrs.setGroupMeasurements,{groupID, "metric"})

        local reportStylePath = missionCommands.addSubMenuForGroup(groupID,T:Get("EWRS_SET_REPORT_STYLE"),groupSettingsPath)
        for _,style in ipairs({1,2}) do
          local reportStyleLabel = ewrsReportStyleLabel(style, T) .. ((ewrsReportStyleValue(groupSettings.reportStyle) == style) and T:Get("EWRS_CURRENT_SUFFIX") or "")
          missionCommands.addCommandForGroup(groupID, reportStyleLabel, reportStylePath, ewrs.setGroupReportStyle, {groupID, style})
        end

        ewrs.builtF10Menus[stringGroupID] = rootPath
      end
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
ewrs.groupUnitTypes = {}
ewrs.groupSettings = {}
ewrs.builtF10Menus = {}
ewrs.notAvailable = 999999

ewrs.update()
if not ewrs.onDemand then
  timer.scheduleFunction(function(param, time)
  ewrs.resetRuntimeCache()
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
