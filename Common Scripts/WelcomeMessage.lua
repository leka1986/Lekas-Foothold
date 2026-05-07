-- This script handles statics, Welcome messages, Callsign assigement, Escort, Missle tracking, Radio menu for ATIS and getting closest Airbase.

-- This script needs cuople of things, Static unit called EventMan and the carrier named CVN-72 or change those names bellow,
-- most importantly it needs Moose.

local function getFootholdLocalization()
    local localization = FH_L10N or FootholdLocalization
    if not localization then
        error("Foothold_Localization.lua must be loaded before using localized welcome text.", 2)
    end
    return localization
end

local L10N = {
    Get = function(_, ...) return getFootholdLocalization():Get(...) end,
    Format = function(_, ...) return getFootholdLocalization():Format(...) end,
    Text = function(_, ...) return getFootholdLocalization():Text(...) end,
    ForGroup = function(_, ...) return getFootholdLocalization():ForGroup(...) end,
}

local function getMooseGroupTranslator(group)
    local groupID = nil
    if group then
        if group.GetID then
            groupID = group:GetID()
        elseif group.getID then
            groupID = group:getID()
        end
    end
    return groupID and L10N:ForGroup(groupID) or getFootholdLocalization():ForLocale()
end

local function getMooseUnitTranslator(unit)
    local group = nil
    if unit then
        if unit.GetGroup then
            group = unit:GetGroup()
        elseif unit.getGroup then
            group = unit:getGroup()
        end
    end
    return getMooseGroupTranslator(group)
end

static = STATIC:FindByName("EventMan", true)

atisZones = {}

allZones = {}
local allZoneSet = {}
local allZoneObjects = {}
local atisAirbaseObjects = {}
local atisZoneByAirbaseName = {}

local function GetAirbaseByNameCached(airbaseName)
    if type(airbaseName) ~= "string" or airbaseName == "" then
        return nil
    end
    local cached = atisAirbaseObjects[airbaseName]
    if cached then
        return cached
    end
    local airbase = AIRBASE:FindByName(airbaseName)
    if airbase then
        atisAirbaseObjects[airbaseName] = airbase
    end
    return airbase
end

local function BuildAllZonesFromFootholdZones()
    local built = {}
    local seen = {}
    if type(zones) ~= "table" then
        return built
    end

    for _, zone in pairs(zones) do
        -- Match the previous manual list: only include the player/spawn bases.
        if zone and zone.isHeloSpawn == true then
            local zoneName = zone.zone
            if type(zoneName) == "string" and zoneName ~= "" and not seen[zoneName] then
                table.insert(built, zoneName)
                seen[zoneName] = true
            end
        end
    end
    return built
end

local function InitAllZones()
    allZones = BuildAllZonesFromFootholdZones()
    allZoneSet = {}
    allZoneObjects = {}
    for _, zoneName in ipairs(allZones) do
        allZoneSet[zoneName] = true
        allZoneObjects[zoneName] = ZONE:New(zoneName)
    end
end

function RegisterWelcomeZone(zoneName)
    if type(zoneName) ~= "string" or zoneName == "" then
        return false
    end

    if not allZoneSet[zoneName] then
        table.insert(allZones, zoneName)
        allZoneSet[zoneName] = true
    end

    if not allZoneObjects[zoneName] then
        allZoneObjects[zoneName] = ZONE:New(zoneName)
    end

    return allZoneObjects[zoneName] ~= nil
end


local function BuildAtisZonesFromFootholdZones()
    local built = {}
    local builtCount = 0
    atisZoneByAirbaseName = {}
    if type(zones) ~= "table" then
        return built
    end

    for _, zone in pairs(zones) do
        local zoneName = zone and zone.zone
        local airbaseName = zone and zone.airbaseName
        if type(zoneName) == "string" and zoneName ~= "" and type(airbaseName) == "string" and airbaseName ~= "" then
            local airbase = GetAirbaseByNameCached(airbaseName)
            if airbase and airbase:IsAirdrome() then
                built[zoneName] = { airbaseName = airbaseName }
                atisZoneByAirbaseName[airbaseName] = zoneName
                builtCount = builtCount + 1
            end
        end
    end
    return built
end

local function InitAtisZones()
    atisZones = BuildAtisZonesFromFootholdZones()
end

local function zoneNameContainsToken(zoneName, token)
    if not token or token == "" then return false end
    local zoneText = tostring(zoneName or "")
    if zoneText == "" then return false end
    local tokenText = tostring(token)
    if string.find(zoneText, tokenText, 1, true) then return true end
    return string.find(string.lower(zoneText), string.lower(tokenText), 1, true) ~= nil
end

local function isCarrierZoneName(zoneName)
    if zoneNameContainsToken(zoneName, "carrier") then return true end
    local extraCarrierZoneNames = GlobalSettings.carrierZoneNames or CarrierZoneNames
    if type(extraCarrierZoneNames) == "table" then
        for _, token in ipairs(extraCarrierZoneNames) do
            if zoneNameContainsToken(zoneName, token) then
                return true
            end
        end
    end
    return false
end

-- Build once at script load (this file is executed after Foothold `zones` is created).
InitAllZones()
InitAtisZones()

if EscortTakeoffFromGround == nil then
    EscortTakeoffFromGround = false
end

EscortTypeByPlayerType = EscortTypeByPlayerType or {
    ["C-130J-30"]      = { true, 1 },
    ["AV8BNA"]         = { true, 1 },
    ["A-10C_2"]        = { true, 1 },
    ["A-10C"]          = { true, 1 },
    ["A-10A"]          = { true, 1 },
    ["Hercules"]       = { true, 1 },
    ["F-15ESE"]        = { true, 2 },
    ["AJS37"]          = { true, 1 },
    ["MiG-29 Fulcrum"] = { false, 2 },
    ["F-16C_50"]       = { false, 2 },
    ["FA-18C_hornet"]  = { false, 2 },
    ["MiG-21Bis"]      = { false, 3 },
    ["Su-25T"]         = { false, 3 },
    ["Su-25"]          = { false, 3 },
    ["M-2000C"]        = { false, 2 },
    ["Bronco-OV-10A"]  = { false, 1 },

}



followID={}
staticDetails = {}
spawnedGroups = {}
escortGroups = {}
escortPendingJoin = {}
menuEscortRequest = {}
escortRequestMenus = {}
escortMenus = {}

function GatherStaticDetails()
    for airbaseName, staticNames in pairs(airbaseStatics) do
        for _, staticName in ipairs(staticNames) do
            local static = STATIC:FindByName(staticName,true)
            if static and static:IsAlive() then
                local point = static:GetPointVec3()
                local typeName = static:GetTypeName()
                if typeName == ".Command Center" then
                shapeName = shapeName or "ComCenter"
                end
                local coalitionSide = static:GetCoalition()
                local heading = static:GetHeading()
                staticDetails[staticName] = {
                    airbaseName = airbaseName,
                    typeName = typeName,
                    shapeName = shapeName,
                    coalitionSide = coalitionSide,
                    point = point,
                    heading = heading,
                }
            else
            end
        end
    end
end

function RespawnStaticsForAirbase(airbaseName, coalitionSide)
    local statics = airbaseStatics[airbaseName]
    if not statics then
        return
    end

    local countryID
    if coalitionSide == coalition.side.BLUE then
        countryID = country.id.USA
    elseif coalitionSide == coalition.side.RED then
        countryID = country.id.RUSSIA
    elseif coalitionSide == coalition.side.NEUTRAL then
        countryID = country.id.UN_PEACEKEEPERS
    else
        return
    end

    for _, staticName in ipairs(statics) do
        local static = STATIC:FindByName(staticName, false)
        if static and static:IsAlive() then
            static:ReSpawn(countryID)
        else
            local details = staticDetails[staticName]
            if details then
                local headingInRadians = math.rad(details.heading)
                local spawnTemplate = {
                    ["name"] = staticName,
                    ["type"] = details.typeName,
                    ["category"] = "Static",
                    ["country"] = countryID,
                    ["heading"] = headingInRadians,
                    ["position"] = details.point,
                }
                local spawnStatic = SPAWNSTATIC:NewFromTemplate(spawnTemplate, countryID)
                spawnStatic:SpawnFromCoordinate(COORDINATE:NewFromVec3(details.point))
            end
        end
    end
end

GatherStaticDetails()


local zoneAssignments = {}
local playerZoneVisits = {}
local globalCallsignAssignments = {}

function logZoneAssignments()
end
local function isCallsignUsedInOtherZones(fullCallsign, currentZone)
    for zone, assignments in pairs(zoneAssignments) do
        if assignments[fullCallsign] then
            if zone ~= currentZone then
                return true
            elseif assignments[fullCallsign] then
                return true
            end
        end
    end
    return false
end

function getPlayerAssignment(playerName)
    if globalCallsignAssignments[playerName] then
        local callsignInfo = globalCallsignAssignments[playerName]
        return callsignInfo.callsign, callsignInfo.zoneName
    end
    return nil, nil
end

function getPlayerDisplayName(playerName)
    if not playerName then
        return playerName
    end
    local callsign = select(1, getPlayerAssignment(playerName))
    if callsign and callsign ~= "" then
        return callsign
    end
    return playerName
end

function findOrAssignSlot(playerName, groupName, zoneName)
    local existingCallsign, assignedZone = getPlayerAssignment(playerName)
    if existingCallsign then
        if assignedZone == zoneName then
            for prefix, typeAssignments in pairs(aircraftAssignments) do
                if string.find(groupName, prefix) then
                    for callsign, details in pairs(typeAssignments) do
                        if string.find(existingCallsign, callsign) then
                            local number = tonumber(string.sub(existingCallsign, -1))
                            if number then
                                local IFF = details.IFFs[number]
                                return existingCallsign, IFF
                            end
                        end
                    end
                end
            end
        else
            releaseSlot(playerName, assignedZone)
            globalCallsignAssignments[playerName] = nil
        end
    end

    zoneAssignments[zoneName] = zoneAssignments[zoneName] or {}

    local prefix, preferredOrder = getPreferredOrder(groupName)
    if not preferredOrder then return nil, nil end

    if #preferredOrder == 1 then
        local baseCallsign = preferredOrder[1]
        local maxNumber = 0
        for zone, assignments in pairs(zoneAssignments) do
            for fullCallsign in pairs(assignments) do
                if string.find(fullCallsign, baseCallsign) then
                    local number = tonumber(string.sub(fullCallsign, -1))
                    if number and number > maxNumber then maxNumber = number end
                end
            end
        end
        local newCallsign = baseCallsign .. (maxNumber + 1)
        local IFF = aircraftAssignments[prefix][baseCallsign].IFFs[(maxNumber % #aircraftAssignments[prefix][baseCallsign].IFFs) + 1]
        zoneAssignments[zoneName][newCallsign] = playerName
        globalCallsignAssignments[playerName] = {callsign = newCallsign, zoneName = zoneName, groupName = groupName}
        logZoneAssignments()
        return newCallsign, IFF
    end

    local availableMainCallsign, existingPrefixInZone
    for _, mainCallsign in ipairs(preferredOrder) do
        for i = 1, #aircraftAssignments[prefix][mainCallsign].IFFs do
            local fullCallsign = mainCallsign .. "" .. i
            if zoneAssignments[zoneName][fullCallsign] then
                existingPrefixInZone = mainCallsign
                break
            end
        end
        if existingPrefixInZone then break end
    end

    if not existingPrefixInZone then
        for _, mainCallsign in ipairs(preferredOrder) do
            local usedElsewhere = false
            for zone, assignments in pairs(zoneAssignments) do
                if zone ~= zoneName then
                    for fullCallsign in pairs(assignments) do
                        if string.find(fullCallsign, mainCallsign) then usedElsewhere = true break end
                    end
                end
            end
            if not usedElsewhere then availableMainCallsign = mainCallsign break end
        end
    else
        availableMainCallsign = existingPrefixInZone
    end

    if availableMainCallsign then
        for i, IFF in ipairs(aircraftAssignments[prefix][availableMainCallsign].IFFs) do
            local fullCallsign = availableMainCallsign .. "" .. i
            if not zoneAssignments[zoneName][fullCallsign] then
                zoneAssignments[zoneName][fullCallsign] = playerName
                globalCallsignAssignments[playerName] = {callsign = fullCallsign, zoneName = zoneName, groupName=groupName}
                logZoneAssignments()
                return fullCallsign, IFF
            end
        end
    end

    for _, mainCallsign in ipairs(preferredOrder) do
        for i, IFF in ipairs(aircraftAssignments[prefix][mainCallsign].IFFs) do
            local fullCallsign = mainCallsign .. "" .. i
            if not isCallsignUsedInOtherZones(fullCallsign, zoneName) and not zoneAssignments[zoneName][fullCallsign] then
                zoneAssignments[zoneName][fullCallsign] = playerName
                globalCallsignAssignments[playerName] = {callsign = fullCallsign, zoneName = zoneName, groupName=groupName}
                logZoneAssignments()
                return fullCallsign, IFF
            end
        end
    end

    for _, mainCallsign in ipairs(preferredOrder) do
        for i, IFF in ipairs(aircraftAssignments[prefix][mainCallsign].IFFs) do
            local fullCallsign = mainCallsign .. "" .. i
            if not zoneAssignments[zoneName][fullCallsign] then
                zoneAssignments[zoneName][fullCallsign] = playerName
                globalCallsignAssignments[playerName] = {callsign = fullCallsign, zoneName = zoneName,groupName=groupName}
                logZoneAssignments()
                return fullCallsign, IFF
            end
        end
    end

    return nil, nil
end

local defaultPreferredOrder = {
    ["F.A.18"] = {"Arctic1","Bender2","Crimson3","Dusty4","Lion3"},
    ["F.16CM"] = {"Indy9","Jester1","Venom4"},
    ["A.10C"] = {"Hawg8","Tusk2","Pig7"},
    ["AH.64D"] = {"Rage9","Salty1"},
    ["AJS37"] = {"Fenris6","Grim7"},
    ["UH.1H"] = {"Nitro5"},
    ["CH.47F"] = {"Greyhound3"},
    ["F.15E.S4"] = {"Hitman3"},
    ["F.14B"] = {"Elvis5","Mustang4"},
    [".OH.58D"] = {"Blackjack4"},
    ["Ka.50.III"] = {"Orca6"},
    ["AV.8B"] = {"Quarterback1"},
    ["M.2000"] = {"Quebec8"},
    ["F.4E.45MC"] = {"Savage1","Scary2"},
    ["MiG.29A.Fulcrum"] = {"Wedge7"},
    ["Mi.24P"] = {"Scorpion3"},
    ["C.130J.30"] = {"Mighty1"},
}

local function splitCallsignParts(callsign)
    local stem, numberPart = string.match(callsign, "^(.-)(%d+)$")
    if stem then
        return stem, tonumber(numberPart)
    end
    return callsign, nil
end

local function pickReplacementCallsign(baseCallsign, remainingAssignments)
    local baseStem, baseNumber = splitCallsignParts(baseCallsign)
    local selectedCallsign = nil
    local selectedDistance = nil

    for callsign in pairs(remainingAssignments) do
        local stem, number = splitCallsignParts(callsign)
        if stem == baseStem then
            local distance = math.abs((number or 0) - (baseNumber or 0))
            if (not selectedCallsign)
                or (distance < selectedDistance)
                or (distance == selectedDistance and callsign < selectedCallsign) then
                selectedCallsign = callsign
                selectedDistance = distance
            end
        end
    end

    return selectedCallsign
end

local function resolvePreferredOrder(prefix, typeAssignments)
    local preferredOrder = {}
    local remainingAssignments = {}
    local baseOrder = defaultPreferredOrder[prefix] or {}

    for callsign in pairs(typeAssignments) do
        remainingAssignments[callsign] = true
    end

    for _, baseCallsign in ipairs(baseOrder) do
        local selectedCallsign = nil
        if remainingAssignments[baseCallsign] then
            selectedCallsign = baseCallsign
        else
            selectedCallsign = pickReplacementCallsign(baseCallsign, remainingAssignments)
        end

        if selectedCallsign then
            preferredOrder[#preferredOrder + 1] = selectedCallsign
            remainingAssignments[selectedCallsign] = nil
        end
    end

    local extras = {}
    for callsign in pairs(remainingAssignments) do
        extras[#extras + 1] = callsign
    end
    table.sort(extras)

    for _, callsign in ipairs(extras) do
        preferredOrder[#preferredOrder + 1] = callsign
    end

    return preferredOrder
end

local function applyCallsignOverrides()
    if type(CallsignOverrides) ~= "table" then
        return
    end

    for prefix, configuredAssignments in pairs(CallsignOverrides) do
        if type(configuredAssignments) == "table" then
            local rebuiltAssignments = {}
            for callsign, configuredIFFs in pairs(configuredAssignments) do
                rebuiltAssignments[callsign] = {
                    IFFs = configuredIFFs,
                    assignments = {}
                }
            end
            aircraftAssignments[prefix] = rebuiltAssignments
        end
    end
end

function getPreferredOrder(groupName)
    for prefix, typeAssignments in pairs(aircraftAssignments) do
        if string.find(groupName, prefix) then
            return prefix, resolvePreferredOrder(prefix, typeAssignments)
        end
    end
end
aircraftAssignments = {
    ["F.A.18"] = {
        ["Arctic1"] = {
            IFFs = {1400, 1401, 1402, 1403},
            assignments = {}
        },
        ["Bender2"] = {
            IFFs = {1404, 1405, 1406, 1407},
            assignments = {}
        },
        ["Crimson3"] = {
            IFFs = {1410, 1411, 1412, 1413},
            assignments = {}
        },
        ["Dusty4"] = {
            IFFs = {1300, 1301, 1302, 1303},
            assignments = {}
        },
        ["Lion3"] = {
            IFFs = {1310, 1311, 1312, 1313},
            assignments = {}
        },
    },
    ["F.16CM"] = {
        ["Jester1"] = {
            IFFs = {1510, 1511, 1512, 1513},
            assignments = {}
        },
        ["Indy9"] = {
            IFFs = {1500, 1501, 1502, 1503},
            assignments = {}
        },
        ["Venom4"] = {
            IFFs = {1610, 1611, 1612, 1613},
            assignments = {}
        },
    },
    ["A.10C"] = {
        ["Hawg8"] = {
            IFFs = {1330, 1331, 1332, 1333},
            assignments = {}
        },
        ["Tusk2"] = {
            IFFs = {1350, 1351, 1352, 1353},
            assignments = {}
        },
        ["Pig7"] = {
            IFFs = {1340, 1341, 1342, 1343},
            assignments = {}
        },
    },
    ["AH.64D"] = {
        ["Rage9"] = {
            IFFs = {1610, 1611, 1612, 1613},
            assignments = {}
        },
        ["Salty1"] = {
            IFFs = {1620, 1621, 1622, 1623},
            assignments = {}
        },
    },
    ["Ka.50.III"] = {
        ["Orca6"] = {
            IFFs = {1560, 1561, 1562, 1563},
            assignments = {}
        },
    },
    ["AJS37"] = {
        ["Fenris6"] = {
            IFFs = {1060, 1061, 1062, 1063},
            assignments = {}
        },
        ["Grim7"] = {
            IFFs = {1070, 1071, 1072, 1073},
            assignments = {}
        },
    },
    ["UH.1H"] = {
        ["Nitro5"] = {
            IFFs = {1050, 1051, 1052, 1053},
            assignments = {}
        },
    },
    ["CH.47F"] = { 
        ["Greyhound3"] = { 
            IFFs = {1370, 1371, 1372, 1373}, 
            assignments = {}
        },
    },
    ["F.15E.S4"] = { 
        ["Hitman3"] = { 
            IFFs = {1360, 1361, 1362, 1363}, 
            assignments = {}
        },
    },
    ["AV.8B"] = {
        ["Quarterback1"] = {
            IFFs = {1434, 1435, 1436, 1437},
            assignments = {}
        },
    },
    ["M.2000"] = {
        ["Quebec8"] = {
            IFFs = {1600, 1601, 1602, 1603},
            assignments = {}
        },
    },
	[".OH.58D"] = { 
        ["Blackjack4"] = { 
            IFFs = {1440, 1441, 1442, 1443}, 
            assignments = {}
        },
    },
    ["F.14B"] = { 
        ["Elvis5"] = { 
            IFFs = {1100, 1101, 1102, 1103}, 
            assignments = {}
        },
        ["Mustang4"] = { 
            IFFs = {1104, 1105, 1106, 1107}, 
            assignments = {}
        },
    },
    ["F.4E.45MC"] = { 
        ["Savage1"] = { 
            IFFs = {0120, 0121, 0122, 0123}, 
            assignments = {}
        },
        ["Scary2"] = { 
            IFFs = {0130, 0131, 0132, 0133}, 
            assignments = {}
        },
    },
    ["MiG.29A.Fulcrum"] = { 
        ["Wedge7"] = { 
            IFFs = {0524, 0525, 0526, 0527}, 
            assignments = {}
        },
    },
    ["Mi.24P"] = { 
        ["Scorpion3"] = { 
            IFFs = {0610, 0611, 0612, 0613}, 
            assignments = {}
        },
    },
    ["C.130J.30"] = { 
        ["Mighty1"] = { 
            IFFs = {1160, 1161, 1162, 1163}, 
            assignments = {}
        },
    },
}

applyCallsignOverrides()

function releaseSlot(playerName, zoneName)
    if zoneAssignments[zoneName] then
        for callsign, assignedPlayer in pairs(zoneAssignments[zoneName]) do
            if assignedPlayer == playerName then
                zoneAssignments[zoneName][callsign] = nil

                globalCallsignAssignments[playerName] = nil

                break
            end
        end
    end
end
function sendGreetingToPlayer(unitName,greetingMessage)
	local u=UNIT:FindByName(unitName)
	if not(u and u:IsAlive())then return end
	MESSAGE:New(greetingMessage,55,Information,true):ToUnit(u)
end
function sendDetailedMessageToPlayer(playerUnitID, message, playerGroupID, unitName)
    local u = UNIT:FindByName(unitName)
    if not (u and u:IsAlive()) then return end
    local g = u:GetGroup()
    if g then playerGroupID = g:GetID() end

    local dur = 120
    if u:InAir() then
    dur = 10 end
    MESSAGE:New(message, dur):ToUnit(u)
    if playerGroupID and trigger.misc.getUserFlag(180) == 0 then
        trigger.action.outSoundForGroup(playerGroupID, "admin.wav")
    end
end
local function getAltimeter(translator)
    local T = translator or L10N
    local coord = COORDINATE:NewFromVec3({x = 0, y = 0, z = 0})
    local pressure_hPa = coord:GetPressure(0)  
    local pressureInHg = pressure_hPa * 0.0295300
    return T:Format("WELCOME_ALTIMETER", pressureInHg)
end

local _AIRBOSS = {}
local WelcomeCarrierNames = {"CVN-73","CVN-72","CVN-59","CVN-74","CVN-75"}

local function AirBoss(name)
    if not _AIRBOSS[name] then
        _AIRBOSS[name] = AIRBOSS:New(name)
    end
    return _AIRBOSS[name]
end

local function getFirstActiveCarrierName()
    for _, name in ipairs(WelcomeCarrierNames) do
        if IsGroupActive(name) then
            return name
        end
    end
end

function refreshBeacons()
    if IsGroupActive("CVN-73") then
        local ab = AirBoss("CVN-73")
        if not ab then return end
        ab.beacon:ActivateTACAN(73, "X", "GWN", true)
        ab.beacon:ActivateICLS(13, "GWN")
    end

    if IsGroupActive("CVN-72") then
        local ab = AirBoss("CVN-72")
        if not ab then return end
        ab.beacon:ActivateTACAN(72, "X", "ABE", true)
        ab.beacon:ActivateICLS(12, "ABE")
    end

    if IsGroupActive("CVN-59") then
        local ab = AirBoss("CVN-59")
        if not ab then return end
        ab.beacon:ActivateTACAN(59, "X", "FTS", true)
        ab.beacon:ActivateICLS(9,  "FTS")
    end
    if IsGroupActive("CVN-74") then
        local ab = AirBoss("CVN-74")
        if not ab then return end
        ab.beacon:ActivateTACAN(74, "X", "JCS", true)
        ab.beacon:ActivateICLS(14, "JCS")
    end
    if IsGroupActive("CVN-75") then
        local ab = AirBoss("CVN-75")
        if not ab then return end
        ab.beacon:ActivateTACAN(75, "X", "HST", true)
        ab.beacon:ActivateICLS(15, "HST")
    end
end

SCHEDULER:New(nil, refreshBeacons, {}, 30, 1200)

local function IsThereACarrier()
    return getFirstActiveCarrierName() ~= nil
end

local function getBRC(cvnName, translator)
    local T = translator or L10N
    if cvnName and IsGroupActive(cvnName) then
        return T:Format("WELCOME_BRC", AirBoss(cvnName):GetBRC())
    end
    local activeCarrierName = getFirstActiveCarrierName()
    if activeCarrierName then
        return T:Format("WELCOME_BRC", AirBoss(activeCarrierName):GetBRC())
    end
    return T:Get("WELCOME_BRC_UNAVAILABLE")
end

function hullPrettyAndTCN(name)
    if name=="CVN-73" then return "George Washington","73X" end
    if name=="CVN-72" then return "Abraham Lincoln","72X" end
    if name=="CVN-59" then return "Forrestal","59X" end
    if name=="CVN-74" then return "John C. Stennis","74X" end
    if name=="CVN-75" then return "Harry S. Truman","75X" end
end

local function getCarrierWind(cvnName, translator)
    local T = translator or L10N
    local cvn

    if cvnName then
        cvn = UNIT:FindByName(cvnName)
    else
        local activeCarrierName = getFirstActiveCarrierName()
        if activeCarrierName then
            cvn = UNIT:FindByName(activeCarrierName)
        end
    end
    if not cvn then
        return T:Get("WELCOME_CARRIER_NOT_FOUND")
    end
    local dir, spd = cvn:GetCoordinate():GetWind(18)
    if not dir or not spd then
        return T:Get("WELCOME_WIND_UNAVAILABLE")
    end
    return T:Format("WELCOME_WIND_AT_KNOTS", (dir + 360) % 360, spd * 1.94384)
end

function getCarrierInfo()
    local activeCarrierName = getFirstActiveCarrierName()
    if activeCarrierName then
        return hullPrettyAndTCN(activeCarrierName)
    end
end

local function getAirbaseWind(airbaseName, translator)
    local T = translator or L10N
    local airbase = GetAirbaseByNameCached(airbaseName)
    if airbase then
        local airbaseCoord = airbase:GetCoordinate()  
        local windDirection, windSpeed = airbaseCoord:GetWind(10)
        if windDirection and windSpeed then
            local windSpeedKnots = math.floor(windSpeed * 1.94384)
            windDirection = (windDirection + 360) % 360
            return T:Format("WELCOME_WIND_AT", windDirection, windSpeedKnots), windDirection
        else
            return T:Get("WELCOME_WIND_UNAVAILABLE"), nil
        end
    else
        return T:Get("WELCOME_AIRBASE_NOT_FOUND"), nil
    end
end

local function fetchActiveRunway(zoneName, translator)
    local T = translator or L10N
    local zoneData = atisZones[zoneName]
    if not zoneData or not zoneData.airbaseName then
        return T:Get("WELCOME_AIRBASE_DATA_UNAVAILABLE")
    end
    local airbase = GetAirbaseByNameCached(zoneData.airbaseName)
    if not airbase then
        trigger.action.outText(L10N:Format("WELCOME_AIRBASE_CONFLICT", zoneData.airbaseName), 10)
        return T:Get("WELCOME_AIRBASE_DATA_UNAVAILABLE")
    end
    local landingRunway, takeoffRunway = airbase:GetActiveRunway()
    if not landingRunway and not takeoffRunway then
        return T:Get("WELCOME_NO_ACTIVE_RUNWAY")
    end
    local landingRunwayName
    local takeoffRunwayName
    if landingRunway then
        landingRunwayName = airbase:GetRunwayName(landingRunway)
    end
    if takeoffRunway then
        takeoffRunwayName = airbase:GetRunwayName(takeoffRunway)
    end
    if landingRunwayName and takeoffRunwayName then
        if landingRunwayName == takeoffRunwayName then
            return T:Format("WELCOME_ACTIVE_RUNWAY", landingRunwayName)
        else
            return T:Format("WELCOME_ACTIVE_RUNWAY_LANDING_TAKEOFF", landingRunwayName, takeoffRunwayName)
        end
    elseif landingRunwayName then
        return T:Format("WELCOME_ACTIVE_RUNWAY_LANDING", landingRunwayName)
    elseif takeoffRunwayName then
        return T:Format("WELCOME_ACTIVE_RUNWAY_TAKEOFF", takeoffRunwayName)
    else
        return T:Get("WELCOME_NO_ACTIVE_RUNWAY")
    end
end

local function getPlayerWind(playerCoord, translator)
    local T = translator or L10N
    local playerPosition = playerCoord:GetVec3()
    local windVector = atmosphere.getWind(playerPosition)
    if windVector then
        local windSpeedMps = math.sqrt(windVector.x^2 + windVector.z^2)
        local windSpeedKnots = math.floor(windSpeedMps * 1.94384)
        local originalWindDirection = math.deg(math.atan2(windVector.z, windVector.x))
        originalWindDirection = (originalWindDirection + 360) % 360
        local originatingWindDirection = (originalWindDirection + 180) % 360
        return T:Format("WELCOME_WIND_AT", originatingWindDirection, windSpeedKnots), originatingWindDirection
    else
        return T:Get("WELCOME_WIND_UNAVAILABLE"), nil
    end
end
local function getPlayerTemperature(playerCoord, translator)
    local T = translator or L10N
    local playerPosition = playerCoord:GetVec3()
    local temperatureCelsius = playerCoord:GetTemperature(playerPosition.y)
    
    if temperatureCelsius then
        return T:Format("WELCOME_TEMPERATURE", temperatureCelsius)
    else
        return T:Get("WELCOME_TEMPERATURE_UNAVAILABLE")
    end
end

-- ATIS MENU --

local function sendATISInformation(client, group, zoneName)
    if not client then return end
    local T = getMooseUnitTranslator(client)
    if isCarrierZoneName(zoneName) then
        local altimeter = getAltimeter(T)
        local lines = {}

        for _, carrierName in ipairs(WelcomeCarrierNames) do
            if IsGroupActive(carrierName) then
                local prettyName = hullPrettyAndTCN(carrierName)
                table.insert(lines,
                    T:Format("WELCOME_ATIS_FOR_FULL",
                                  prettyName, getCarrierWind(carrierName, T), altimeter, getBRC(carrierName, T)))
            end
        end

        if #lines == 0 then
            table.insert(lines,
                T:Format("WELCOME_ATIS_FOR_FULL",
                              T:Get("WELCOME_CARRIER_NOT_FOUND"), T:Get("WELCOME_WIND_UNAVAILABLE"), altimeter, T:Get("WELCOME_BRC_UNAVAILABLE")))
        end

        MESSAGE:New(table.concat(lines,"\n------------------------------------------------\n"),15,""):ToUnit(client)
    else
        local wind,dir = getAirbaseWind(atisZones[zoneName].airbaseName, T)
        if wind==T:Get("WELCOME_WIND_UNAVAILABLE") or wind==T:Get("WELCOME_AIRBASE_NOT_FOUND") then
            MESSAGE:New(T:Format("WELCOME_ATIS_FOR_SIMPLE",zoneName,wind),15,""):ToUnit(client)
        else
            local run = fetchActiveRunway(zoneName, T) or T:Get("WELCOME_RUNWAY_INFO_UNAVAILABLE")
            local altimeter = getAltimeter(T)
            local msg = T:Format("WELCOME_ATIS_FOR_FULL_PERIOD",zoneName,wind,altimeter,run)
            MESSAGE:New(msg,20,""):ToUnit(client)
        end
    end
end



local MainMenu = {}

local function getNearestCarrierName(coord)
    local nearest=nil local minDist=math.huge
    for _,name in ipairs(WelcomeCarrierNames) do
        if IsGroupActive(name) then
            local unit=UNIT:FindByName(name)
            if unit then
                local distance=coord:Get2DDistance(unit:GetCoordinate())
                if distance<minDist then minDist=distance nearest=name end
            end
        end
    end
    if minDist<200 then return nearest end
end



function getClosestFriendlyAirbaseInfo(client)
    if not client or not client:IsAlive() then
        return
    end
    local T = getMooseUnitTranslator(client)
    local playerCoord = client:GetCoordinate()
    if not playerCoord then
        MESSAGE:New(T:Get("WELCOME_PLAYER_POSITION_UNKNOWN"),15,""):ToUnit(client)
        return
    end
    local clientType      = client:GetTypeName()
    local considerCarrier = (clientType == "FA-18C_hornet" or clientType == "F-14B")
    local lines           = {}

    if considerCarrier then
        for _,name in ipairs(WelcomeCarrierNames) do
            if IsGroupActive(name) then
                local cvn = UNIT:FindByName(name)
                if cvn then
                    local ccoord   = cvn:GetCoordinate()
                    local cdist    = playerCoord:Get2DDistance(ccoord)
                    local cbrg     = (playerCoord:HeadingTo(ccoord,nil) - playerCoord:GetMagneticDeclination() + 360) % 360
                    local pretty,tacan = hullPrettyAndTCN(name)
                    local msg = T:Format("WELCOME_CARRIER_INFO",
                                              pretty,cdist*0.000539957,cbrg,tacan,getBRC(name, T))
                    table.insert(lines,msg)
                end
            end
        end
    end

    local closestNormalZoneName,closestNormalDistance,closestNormalBearing = nil,math.huge,nil
    for zoneName,details in pairs(atisZones) do
        local airbase = GetAirbaseByNameCached(details.airbaseName)
        if airbase and airbase:GetCoalition() == coalition.side.BLUE then
            local dist     = playerCoord:Get2DDistance(airbase:GetCoordinate())
            local trueBrg  = playerCoord:HeadingTo(airbase:GetCoordinate(),nil)
            local magDecl  = playerCoord:GetMagneticDeclination()
            local magBrg   = (trueBrg - magDecl + 360) % 360
            if not isCarrierZoneName(zoneName) and dist < closestNormalDistance then
                closestNormalZoneName = zoneName
                closestNormalDistance = dist
                closestNormalBearing  = magBrg
            end
        end
    end

    if closestNormalZoneName then
        local distanceInNM   = closestNormalDistance * 0.000539957
        local displayName    = closestNormalZoneName .. (WaypointList[closestNormalZoneName] or "")
        local windMessage,windDirection = getAirbaseWind(atisZones[closestNormalZoneName] and atisZones[closestNormalZoneName].airbaseName or "", T)
        local altimeterMessage,runwayInfo = "",""
        if windMessage ~= T:Get("WELCOME_WIND_UNAVAILABLE") and windMessage ~= T:Get("WELCOME_AIRBASE_NOT_FOUND") then
            altimeterMessage = getAltimeter(T)
            runwayInfo       = fetchActiveRunway(closestNormalZoneName, T) or T:Get("WELCOME_RUNWAY_INFO_UNAVAILABLE")
        end
        local airfieldLine = T:Format("WELCOME_CLOSEST_AIRFIELD",
        displayName,distanceInNM,closestNormalBearing,windMessage,altimeterMessage~=""and(", " .. altimeterMessage)or"", runwayInfo~= ""and("\n\n" .. runwayInfo)or"")
        table.insert(lines,airfieldLine)
    end

    if #lines > 0 then
        MESSAGE:New(table.concat(lines,"\n------------------------------------------------\n"),25,""):ToUnit(client)
    end
end



function SetupATISMenu(client)
    local group = client:GetGroup()
    if not group then return end
    local T = getMooseGroupTranslator(group)

    local groupID = group:GetName()

    if MainMenu[groupID] then
        MainMenu[groupID]:Remove()
    end

    local mainMenu = MENU_GROUP:New(group, T:Get("WELCOME_MENU_ATIS_CLOSEST"))
    MainMenu[groupID] = mainMenu

    local atisMenu = MENU_GROUP:New(group, T:Get("WELCOME_MENU_ATIS_INFO"), mainMenu)
    MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_CLOSEST_FRIENDLY"), mainMenu, getClosestFriendlyAirbaseInfo, client)
    local hasMother = IsThereACarrier()
    if hasMother then
    MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_ATIS_MOTHER"), atisMenu, sendATISInformation, client, group, "Carrier")
    end
    local currentMenu = atisMenu
    local menuItemCount = hasMother and 2 or 0

    local entries = {}
    for zoneName, details in pairs(atisZones) do
        if not isCarrierZoneName(zoneName) then
            local airbase = GetAirbaseByNameCached(details.airbaseName)
            if airbase and airbase:GetCoalitionName() == 'Blue' then
                local wpSuffix = (type(WaypointList) == "table" and WaypointList[zoneName]) or ""
                local wpNum = tonumber(tostring(wpSuffix):match("%d+"))
                entries[#entries + 1] = {
                    zoneName = zoneName,
                    wpSuffix = wpSuffix,
                    wpNum = wpNum
                }
            end
        end
    end

    table.sort(entries, function(a, b)
        if a.wpNum and b.wpNum then
            if a.wpNum ~= b.wpNum then return a.wpNum > b.wpNum end
            return a.zoneName < b.zoneName
        end
        if a.wpNum then return true end
        if b.wpNum then return false end
        return a.zoneName < b.zoneName
    end)

    for _, entry in ipairs(entries) do
        if menuItemCount >= 9 then
            currentMenu = MENU_GROUP:New(group, T:Get("MENU_MORE"), currentMenu)
            menuItemCount = 0
        end
        local zoneDisplayName = entry.zoneName .. entry.wpSuffix
        MENU_GROUP_COMMAND:New(group, T:Format("WELCOME_MENU_ATIS_ZONE", zoneDisplayName), currentMenu, sendATISInformation, client, group, entry.zoneName)
        menuItemCount = menuItemCount + 1
    end
end

function static:onBaseCapture(_event)
    local event = _event -- Core.Event#EVENTDATA
    if event.id == EVENTS.BaseCaptured and event.Place then
        local capturedBaseName = event.Place:GetName()  
        local coalitionSide = event.Place:GetCoalition()

        if event.Place:GetCoalition() == coalition.side.BLUE then  
                local zname = atisZoneByAirbaseName[capturedBaseName]
                if zname then
                local clientSet = SET_CLIENT:New():FilterCategories("plane"):FilterCoalitions("blue"):FilterAlive():FilterOnce()
                clientSet:ForEachClient(function(client)
                    SetupATISMenu(client)  
                    SCHEDULER:New(nil, function()
                    local group=client:GetGroup()
                    sendATISInformation(client,group,zname)
                    end, {}, 10)
                end)
            end
        end  
    end
end

local function IsEscortEligibleType(playerType)
    local escortConfig = EscortTypeByPlayerType and EscortTypeByPlayerType[playerType]
    return type(escortConfig) == "table" and escortConfig[1] == true
end

local function EnsureEscortSpawnState(groupName, playerName)
    spawnedGroups[groupName] = spawnedGroups[groupName] or {
        playerName = playerName,
        escortGroups = {},
        menuEscortRequest = nil,
        escortSpawnCount = 1
    }
    if playerName then
        spawnedGroups[groupName].playerName = playerName
    end
    return spawnedGroups[groupName]
end

activeCSMenus = {}
function static:processPlayerSpawn(player, zoneNameOverride)
	local playerName = player:GetPlayerName()
	local UnitName = player:GetName()
	local rankDisplay = playerName
	if RankingSystem  then
		local rr = bc:getPlayerRank(playerName)
		local rn = bc:getRankName(rr)
		if rn and rn ~= '' then
			rankDisplay = rn .. ' ' .. playerName
		end
	end
	if player:GetUnitCategory() == Unit.Category.AIRPLANE then
		SetupATISMenu(player)
	end
	local group = player:GetGroup()
	local T = getMooseGroupTranslator(group)
	local groupName = group:GetName()
	local playerType = player:GetTypeName()

	if EscortTakeoffFromGround == true and IsEscortEligibleType(playerType) then
		EnsureEscortSpawnState(groupName, playerName)
		if not escortGroups[groupName] and not escortRequestMenus[groupName] then
			SCHEDULER:New(nil, function(unitName, expectedGroupName, fallbackPlayerName)
				local delayedPlayer = UNIT:FindByName(unitName)
				if not (delayedPlayer and delayedPlayer:IsAlive()) then
					return
				end

				local delayedGroup = delayedPlayer:GetGroup()
				if not delayedGroup or delayedGroup:GetName() ~= expectedGroupName then
					return
				end

				if escortGroups[expectedGroupName] or escortRequestMenus[expectedGroupName] then
					return
				end

				local delayedPlayerName = delayedPlayer:GetPlayerName() or fallbackPlayerName
				local TDelayed = getMooseGroupTranslator(delayedGroup)
				MESSAGE:New(TDelayed:Format("WELCOME_ESCORT_AVAILABLE_PLAYER", delayedPlayerName), 10, ""):ToGroup(delayedGroup)
				trigger.action.outSoundForGroup(delayedGroup:GetID(), "ding.ogg")
				AddEscortRequestMenu(delayedGroup)
			end, {UnitName, groupName, playerName}, 10)
		end
	end
	
		local foundZone = false
		local playerCoord = player:GetCoordinate()
		
		for _, zoneName in ipairs(allZones) do
			if not zoneNameOverride or zoneName == zoneNameOverride then
				local zone = allZoneObjects[zoneName]
				if zone and playerCoord and zone:IsCoordinateInZone(playerCoord) then
	                foundZone = true
	                
	                local playerUnitID = player:GetID()
                local playerGroupID = player:GetGroup():GetID()
                
                local isNewVisit = not playerZoneVisits[playerName] or not playerZoneVisits[playerName][zoneName]
                playerZoneVisits[playerName] = playerZoneVisits[playerName] or {}
                playerZoneVisits[playerName][zoneName] = true

                local assignedCallsign, assignedIFF = findOrAssignSlot(playerName, groupName, zoneName)

	                local altimeterMessage = getAltimeter(T)
		                local temperatureMessage = getPlayerTemperature(playerCoord, T)
		                local greetingMessage, detailedMessage
		                local windMessage, displayWindDirection
		                if atisZones[zoneName] then
		                    windMessage, displayWindDirection = getAirbaseWind(atisZones[zoneName].airbaseName, T)
		                else
		                    windMessage, displayWindDirection = getPlayerWind(playerCoord, T)
		                end
		                local activeRunwayMessage = atisZones[zoneName] and fetchActiveRunway(zoneName, T) or "N/A"

	                    local carrierHull=getNearestCarrierName(playerCoord)
                    local carrierName,tacanCode,brcMessage,carrierWindMessage
                    if carrierHull then
                        brcMessage=getBRC(carrierHull, T)
                        carrierWindMessage=getCarrierWind(carrierHull, T)
                        carrierName,tacanCode=hullPrettyAndTCN(carrierHull)
                    end
                    if isCarrierZoneName(zoneName) and carrierHull then

                    if assignedCallsign and assignedIFF then
                        greetingMessage = T:Format("WELCOME_GREETING_CARRIER_ASSIGNED", carrierName, rankDisplay, assignedCallsign, assignedIFF)
                        detailedMessage = T:Format("WELCOME_DETAIL_CARRIER_ASSIGNED_TCN", carrierName, assignedCallsign, carrierWindMessage, temperatureMessage, altimeterMessage, tacanCode, brcMessage)
                    else
                        greetingMessage = T:Format("WELCOME_GREETING_CARRIER_STANDBY", carrierName, rankDisplay)
                        detailedMessage = T:Format("WELCOME_DETAIL_CARRIER_ASSIGNED_TCN", carrierName, playerName, carrierWindMessage, temperatureMessage, altimeterMessage, tacanCode, brcMessage)
                    end
	                else
	                    if atisZones[zoneName] then

	                        if isNewVisit then
	                            if assignedCallsign and assignedIFF then
                                greetingMessage = T:Format("WELCOME_GREETING_ZONE_ASSIGNED_ATIS", zoneName, rankDisplay, assignedCallsign, assignedIFF)
                                detailedMessage = T:Format("WELCOME_DETAIL_ZONE_ATIS", zoneName, assignedCallsign, windMessage, temperatureMessage, altimeterMessage, activeRunwayMessage)
                            else
                                greetingMessage = T:Format("WELCOME_GREETING_ZONE_STANDBY", zoneName, rankDisplay)
                                detailedMessage = T:Format("WELCOME_DETAIL_ZONE_ATIS", zoneName, playerName, windMessage, temperatureMessage, altimeterMessage, activeRunwayMessage)
                            end

                        else
                            if assignedCallsign and assignedIFF then
                                greetingMessage = T:Format("WELCOME_GREETING_BACK_ZONE_ASSIGNED_ATIS", zoneName, rankDisplay, assignedCallsign, assignedIFF)
                                detailedMessage = T:Format("WELCOME_DETAIL_BACK_ZONE_ATIS", zoneName, assignedCallsign, windMessage, temperatureMessage, altimeterMessage, activeRunwayMessage)
                            else
                                greetingMessage = T:Format("WELCOME_GREETING_BACK_ZONE_STANDBY", zoneName, rankDisplay)
                                detailedMessage = T:Format("WELCOME_DETAIL_BACK_ZONE_ATIS", zoneName, playerName, windMessage, temperatureMessage, altimeterMessage, activeRunwayMessage)
                            end
                        end
	                    else

	                        if isNewVisit then
	                            if assignedCallsign and assignedIFF then
                                greetingMessage = T:Format("WELCOME_GREETING_ZONE_ASSIGNED", zoneName, rankDisplay, assignedCallsign, assignedIFF)
                                detailedMessage = T:Format("WELCOME_DETAIL_ZONE", zoneName, assignedCallsign, windMessage, temperatureMessage, altimeterMessage)
                            else
                                greetingMessage = T:Format("WELCOME_GREETING_ZONE_STANDBY", zoneName, rankDisplay)
                                detailedMessage = T:Format("WELCOME_DETAIL_ZONE", zoneName, playerName, windMessage, temperatureMessage, altimeterMessage)
                            end

                        else
                            if assignedCallsign and assignedIFF then
                                greetingMessage = T:Format("WELCOME_GREETING_BACK_ZONE_ASSIGNED", zoneName, rankDisplay, assignedCallsign, assignedIFF)
                                detailedMessage = T:Format("WELCOME_DETAIL_BACK_ZONE", zoneName, assignedCallsign, windMessage, temperatureMessage, altimeterMessage)
                            else
                                greetingMessage = T:Format("WELCOME_GREETING_BACK_ZONE_STANDBY", zoneName, rankDisplay)
                                detailedMessage = T:Format("WELCOME_DETAIL_BACK_ZONE", zoneName, playerName, windMessage, temperatureMessage, altimeterMessage)
                            end
                        end
                    end
                end

               sendGreetingToPlayer(UnitName, greetingMessage)
                if followID[playerName] then followID[playerName]:Stop()
                followID[playerName] = nil
                end
                followID[playerName] = SCHEDULER:New(nil, sendDetailedMessageToPlayer, {playerUnitID, detailedMessage, playerGroupID, UnitName}, 60)
                local subs = {}
                local function buildCallSignMenu()
                        local csMenu = MENU_GROUP:New(group, T:Get("WELCOME_MENU_CHANGE_CALLSIGN"))
                        activeCSMenus[groupName] = csMenu
                        local prefix, preferredOrder = getPreferredOrder(groupName)
                        local function refreshSubmenus()
                            if preferredOrder and type(preferredOrder) == "table" then
                                for _, base in ipairs(preferredOrder) do
                                    if subs[base] then
                                        subs[base]:Remove()
                                    end
                                end
                            end
                            for _, base in ipairs(preferredOrder) do
                                subs[base] = MENU_GROUP:New(group, base, csMenu)
                                for i, iff in ipairs(aircraftAssignments[prefix][base].IFFs) do
                                    local fullCS = base..i
                                    if not zoneAssignments[zoneName][fullCS] then
                                        MENU_GROUP_COMMAND:New(group, fullCS, subs[base], function()
                                        local prev = globalCallsignAssignments[playerName]
                                        if prev and zoneAssignments[prev.zoneName] and zoneAssignments[prev.zoneName][prev.callsign] == playerName then
                                            zoneAssignments[prev.zoneName][prev.callsign] = nil
                                        end
                                        zoneAssignments[zoneName][fullCS] = playerName
                                        globalCallsignAssignments[playerName] = {callsign = fullCS, zoneName = zoneName,groupName=groupName}
                                        if followID[playerName] then followID[playerName]:Stop() followID[playerName]=nil end
                                        if isCarrierZoneName(zoneName) and carrierHull then
                                            sendGreetingToPlayer(UnitName, T:Format("WELCOME_GREETING_CARRIER_ASSIGNED", carrierName, playerName, fullCS, iff))
                                            followID[playerName] = SCHEDULER:New(nil, sendDetailedMessageToPlayer, {playerUnitID, T:Format("WELCOME_DETAIL_CARRIER_ASSIGNED_TCN", carrierName, fullCS, carrierWindMessage, temperatureMessage, altimeterMessage, tacanCode, brcMessage), playerGroupID, UnitName}, 60)
                                        else
                                            sendGreetingToPlayer(UnitName, T:Format("WELCOME_GREETING_ZONE_ASSIGNED_ATIS", zoneName, playerName, fullCS, iff))
                                            followID[playerName] = SCHEDULER:New(nil, sendDetailedMessageToPlayer, {playerUnitID, T:Format("WELCOME_DETAIL_ZONE_ATIS", zoneName, fullCS, windMessage, temperatureMessage, altimeterMessage, activeRunwayMessage), playerGroupID, UnitName}, 60)
                                        end
                                        refreshSubmenus()
                                    end)
                                end
                            end
                        end
                        SCHEDULER:New(nil, function()
                            if activeCSMenus and activeCSMenus[groupName] then
                                activeCSMenus[groupName]:Remove()
                                activeCSMenus[groupName] = nil
                            end
                        end, {}, 60)
                    end
                     refreshSubmenus()
                end
	                if assignedCallsign and assignedIFF then
	                --buildCallSignMenu()
	                end
	                break
	            end
	        end
	    end
        if not foundZone then
            local carrierHull = getNearestCarrierName(player:GetCoordinate())
            if carrierHull then
                local carrierUnit   = UNIT:FindByName(carrierHull)
                local carrierPos    = carrierUnit:GetCoordinate()
                local playerPos     = player:GetCoordinate()
                local distanceToCar = playerPos:Get2DDistance(carrierPos)

                if distanceToCar < 200 then
                    local prettyName,tacanCode      = hullPrettyAndTCN(carrierHull)
                    local assignedCallsign,assignedIFF = findOrAssignSlot(playerName,groupName,carrierHull)
                    local playerUnitID              = player:GetID()
                    local altimeterMessage          = getAltimeter(T)
                    local temperatureMsg            = getPlayerTemperature(carrierPos, T)
                    local brcMessage                = getBRC(carrierHull, T)
                    local windMessage               = getCarrierWind(carrierHull, T)

                    if assignedCallsign and assignedIFF then
                        greetingMessage = T:Format("WELCOME_GREETING_CARRIER_ASSIGNED",prettyName,rankDisplay,assignedCallsign,assignedIFF)
                        detailedMessage = T:Format("WELCOME_DETAIL_CARRIER_ASSIGNED",prettyName,assignedCallsign,windMessage,temperatureMsg,altimeterMessage,brcMessage)
                    else
                        greetingMessage = T:Format("WELCOME_GREETING_CARRIER_STANDBY",prettyName,rankDisplay)
                        detailedMessage = T:Format("WELCOME_DETAIL_CARRIER_ASSIGNED",prettyName,playerName,windMessage,temperatureMsg,altimeterMessage,brcMessage)
                    end
                    sendGreetingToPlayer(UnitName,greetingMessage)
                    if followID[playerName] then followID[playerName]:Stop() followID[playerName]=nil end
                        followID[playerName]=SCHEDULER:New(nil, sendDetailedMessageToPlayer,{playerUnitID,detailedMessage,player:GetGroup():GetID(),UnitName},60)
                    else
                    return
                end
            else
                MESSAGE:New(T:Get("WELCOME_CARRIER_NOT_AVAILABLE"),15,""):ToUnit(player)
            end
        end
    end


function WeaponImpact(Weapon)
    local impactPos = Weapon:GetImpactVec3()
    if impactPos then
        trigger.action.explosion(impactPos, 150)
    end
	Weapon:StopTrack()
end
function WeaponTrack(Weapon)
    local target = Weapon:GetTarget()
    if target and target.GetUnitCategory and target:GetUnitCategory() == Unit.Category.HELICOPTER and target:GetCoalition() == coalition.side.RED then
        return
    end
end

function static:OnEventShot(EventData)
    local eventdata = EventData
    if eventdata and eventdata.weapon and eventdata.IniUnit and eventdata.IniPlayerName then
        local initiator = eventdata.IniUnit
        local playerName = eventdata.IniPlayerName

        if initiator and (initiator:GetUnitCategory() == Unit.Category.AIRPLANE or initiator:GetUnitCategory() == Unit.Category.HELICOPTER) then
            local weapon = WEAPON:New(eventdata.weapon)
            if weapon:IsMissile() then
                local target = eventdata.TgtUnit
                if target and target.GetUnitCategory and target:GetUnitCategory() == Unit.Category.HELICOPTER and target:GetCoalition() == coalition.side.RED then
                    weapon:SetFuncTrack(WeaponTrack)
                    weapon:SetFuncImpact(WeaponImpact)
                    weapon:StartTrack()
                end
            end
        end
    end
end

function AddEscortRequestMenu(group)
    if not group then
        return
    end
    local T = getMooseGroupTranslator(group)
    local groupName = group:GetName()
    if escortRequestMenus[groupName] then
        escortRequestMenus[groupName]:Remove()
    end
    escortRequestMenus[groupName] = MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_REQUEST_ESCORT"), nil, EscortClientGroup, group)
    menuEscortRequest[groupName] = escortRequestMenus[groupName]
end
function EnableEscortRequestMenu(group)
    if not group then
        return
    end
    local groupName = group:GetName()
    if escortRequestMenus[groupName] then
        escortRequestMenus[groupName]:Remove()
    end
end
function RequestEscort(group)
    EscortClientGroup(group)
    RemoveRequestEscortMenu(group)
end
function RemoveRequestEscortMenu(group)
    local groupName = group:GetName()
    if escortRequestMenus[groupName] then
        escortRequestMenus[groupName]:Remove()
        escortRequestMenus[groupName] = nil
    end
    if menuEscortRequest[groupName] then
        menuEscortRequest[groupName] = nil
    end
end


local function IsPlayerGroupInAir(group)
    if not group then
        return false
    end

    local playerUnit = group:GetUnit(1)
    if not playerUnit then
        return false
    end

    return playerUnit:InAir()
end

function HandleEscortLandingForGroupName(groupName, orbitCenter)
    if not groupName then
        return
    end

    local escortGroup = escortGroups[groupName]
    if escortGroup then
        if EscortTakeoffFromGround == true then
            local clientGroup = GROUP:FindByName(groupName)
            local currentMission = escortGroup:GetMissionCurrent()
            if currentMission and currentMission:GetType() ~= AUFTRAG.Type.ESCORT then
                return
            end
            if orbitCenter then
                local orbitAuftrag = AUFTRAG:NewORBIT_CIRCLE(orbitCenter, 10000, 250)
                orbitAuftrag.missionTask=ENUMS.MissionTask.CAP
                orbitAuftrag.missionAltitude = orbitAuftrag.TrackAltitude
                orbitAuftrag:SetEngageDetected(40, {"Air"})
                orbitAuftrag:SetMissionAltitude(10000)  
                orbitAuftrag:SetROE(2)
                orbitAuftrag:SetROT(2)
                escortGroup:AddMission(orbitAuftrag)
                if currentMission then
                    currentMission:__Cancel(5)
                end
                escortPendingJoin[groupName] = true
                if clientGroup then
                    AddEscortMenu(clientGroup)
                    if clientGroup:IsAlive() then
                        local T = getMooseGroupTranslator(clientGroup)
                        MESSAGE:New(T:Get("WELCOME_ESCORT_ORBITING_OVERHEAD"), 20):ToGroup(clientGroup)
                    end
                end
            end
        else
            escortGroup:Destroy()
            escortGroups[groupName] = nil
            escortPendingJoin[groupName] = nil
        end
        return
    end

    if EscortTakeoffFromGround ~= true and escortRequestMenus[groupName] then
        escortRequestMenus[groupName]:Remove()
        escortRequestMenus[groupName] = nil
        menuEscortRequest[groupName] = nil
    end
end

function FindEscortTemplateWithAlias(clientGroup, alias)
    local aircraftType = clientGroup:GetUnit(1):GetTypeName()
    local isColdwar = (Era == "Coldwar")
    local templateName
    local escortConfig = EscortTypeByPlayerType and EscortTypeByPlayerType[aircraftType]
    local escortType = (type(escortConfig) == "table" and escortConfig[2]) or 1
    if escortType == 2 then
        templateName = isColdwar and "Escort2_Viper_Coldwar" or "Escort2_Viper"
    elseif escortType == 3 then
        templateName = isColdwar and "Escort3_Mig29A_Coldwar" or "Escort3_Mig29S"
    else
        templateName = isColdwar and "Escort1_Hornet_Coldwar" or "Escort1_Hornet"
    end
    return templateName
end

function GetClosestEscortAirdromeZone(clientGroup)
    if not clientGroup then
        return nil, nil
    end
    local zoneList = (bc and bc.zones) or zones
    if type(zoneList) ~= "table" then
        return nil, nil
    end

    local clientUnit = clientGroup:GetUnit(1)
    if not clientUnit then
        return nil, nil
    end

    local clientCoord = clientUnit:GetCoordinate()
    if not clientCoord then
        return nil, nil
    end

    local seenAirbases = {}
    local closestZoneName = nil
    local closestAirbase = nil
    local closestDistance = math.huge

    for _, zone in pairs(zoneList) do
        if zone and zone.side == 2 and zone.active then
            local airbaseName = zone.airbaseName
            if type(airbaseName) == "string" and airbaseName ~= "" and not seenAirbases[airbaseName] then
                local airbase = GetAirbaseByNameCached(airbaseName)
                local sideOk = airbase:GetCoalition() == coalition.side.BLUE
                if sideOk and airbase:IsAirdrome() then
                    local airbaseCoord = airbase:GetCoordinate()
                    if airbaseCoord then
                        local distance = clientCoord:Get2DDistance(airbaseCoord)
                        if distance and distance < closestDistance then
                            closestDistance = distance
                            closestZoneName = zone.zone
                            closestAirbase = airbase
                        end
                    end
                end
                seenAirbases[airbaseName] = true
            end
        end
    end

    return closestZoneName, closestAirbase
end

function SpawnEscortInAirBehindClient(clientGroup, templateName, alias, onSpawn)
    if not clientGroup or not templateName or not alias then
        return nil
    end

    local clientPos = clientGroup:GetPointVec3()
    local clientHeading = clientGroup:GetHeading()
    local distanceBehindMeters = 1500

    local offsetX = math.cos(math.rad(clientHeading)) * distanceBehindMeters
    local offsetZ = math.sin(math.rad(clientHeading)) * distanceBehindMeters

    local desiredAlt = IsPlayerGroupInAir(clientGroup) and (UTILS.MetersToFeet(clientPos.y) + 10000) or 27000
    local spawnPos = { x = clientPos.x - offsetX, y = UTILS.FeetToMeters(desiredAlt), z = clientPos.z - offsetZ }
    local coord = COORDINATE:NewFromVec3(spawnPos)

    local spawnHeading = tonumber(clientHeading) or 0
    spawnHeading = ((spawnHeading % 360) + 360) % 360

    local sp = SPAWN:NewWithAlias(templateName, alias)
    sp:InitHeading(spawnHeading, spawnHeading)
    if onSpawn then
        sp:OnSpawnGroup(onSpawn)
    end

    return sp:SpawnFromCoordinate(coord)
end

function SpawnEscortFromGround(clientGroup, templateName, alias, onSpawn)
    if not clientGroup or not templateName or not alias then
        return nil
    end

    local _, homebase = GetClosestEscortAirdromeZone(clientGroup)
    if not homebase then
        return nil
    end

    local function GetEscortTemplateUnitCount(name)
        local tpl = _DATABASE.Templates.Groups[name]
        if tpl and type(tpl.UnitCount) == "number" and tpl.UnitCount > 0 then
            return tpl.UnitCount
        end
        local units = tpl and (tpl.Units or (tpl.Template and tpl.Template.units))
        if (not units or #units == 0) and FetchMETemplate then
            tpl = FetchMETemplate(name)
            units = tpl and tpl.units
        end
        if type(units) == "table" and #units > 0 then
            return #units
        end
        return 1
    end

    local sp = SPAWN:NewWithAlias(templateName, alias)
    sp:OnSpawnGroup(function(spawnedGroup)
        --spawnedGroup:OptionAIRunwayLineUp()

        if onSpawn then
            onSpawn(spawnedGroup)
        end
    end)

    local need = math.max(GetEscortTemplateUnitCount(templateName), 1)
    local terminalType = AIRBASE.TerminalType.OpenMedOrBig
    local freeSpots = homebase:GetFreeParkingSpotsTable(terminalType, false) or {}
    if #freeSpots < need then
        local freeSpotsWithTakeoff = homebase:GetFreeParkingSpotsTable(terminalType, true)
        if type(freeSpotsWithTakeoff) == "table" and #freeSpotsWithTakeoff > #freeSpots then
            freeSpots = freeSpotsWithTakeoff
        end
    end

    local parkingIds = PickCachedParkingIdsForAirbase(homebase, terminalType, freeSpots, need)
    local spawned = nil
    if parkingIds then
        spawned = sp:SpawnAtParkingSpot(homebase, parkingIds, SPAWN.Takeoff.Hot)
    end

    return spawned
end

function EscortClientGroup(clientGroup)
    local T = getMooseGroupTranslator(clientGroup)
    local groupName = clientGroup:GetName()
    local playerName = clientGroup:GetUnit(1):GetPlayerName() or groupName
    EnsureEscortSpawnState(groupName, playerName)
    local spawnCount = spawnedGroups[groupName] and spawnedGroups[groupName].escortSpawnCount or 1
    local safePlayerName = playerName:gsub("%s+", "_"):gsub("[^%w_%-]", "_")
    local alias = groupName .. "_" .. safePlayerName .. "_Escort_" .. string.format("%03d", spawnCount)
    local templateName = FindEscortTemplateWithAlias(clientGroup, alias)
    local escortSpawnedFromGround = false
    local _, escortHomeBase = GetClosestEscortAirdromeZone(clientGroup)
    local escortHomeCoord = escortHomeBase and escortHomeBase:GetCoordinate()

    local function OnEscortSpawn(g)
        local escortGroup = FLIGHTGROUP:New(g)
        local playerInAir = IsPlayerGroupInAir(clientGroup)
        escortGroup:GetGroup():CommandSetUnlimitedFuel(true):SetOptionRadarUsingForContinousSearch(true):SetOptionWaypointPassReport(false)
        escortGroups[groupName] = escortGroup
        if playerInAir then
            local escortAuftrag = AUFTRAG:NewESCORT(clientGroup, { x = -100, y = 3048, z = 100 }, 40, { "Air" })
            escortGroup:AddMission(escortAuftrag)
        else
            local orbitCenter = escortSpawnedFromGround and escortHomeCoord or clientGroup:GetPointVec2()
            if orbitCenter then
                local orbitAuftrag = AUFTRAG:NewORBIT_CIRCLE(orbitCenter, 10000, 350)
                orbitAuftrag.missionTask=ENUMS.MissionTask.CAP
                orbitAuftrag.missionAltitude = orbitAuftrag.TrackAltitude
                orbitAuftrag:SetEngageDetected(40, {"Air"})
                orbitAuftrag:SetMissionAltitude(10000)
                escortGroup:AddMission(orbitAuftrag)
                escortPendingJoin[groupName] = true
            else
                local escortAuftrag = AUFTRAG:NewESCORT(clientGroup, { x = -100, y = 3048, z = 100 }, 40, { "Air" })
                escortGroup:AddMission(escortAuftrag)
            end
        end
        RemoveRequestEscortMenu(clientGroup)
        if escortSpawnedFromGround then
            MESSAGE:New(T:Get("WELCOME_ESCORT_SCRAMBLING_TAXI"), 20):ToGroup(clientGroup)
            function escortGroup:OnAfterTakeoff(From, Event, To)
                if clientGroup and clientGroup:IsAlive() then
                    if IsPlayerGroupInAir(clientGroup) then
                        local escortAuftrag = AUFTRAG:NewESCORT(clientGroup, {x=-100, y=3048, z=300}, 40, {"Air"})
                        escortAuftrag:SetMissionAltitude(25000)
                        escortAuftrag:SetEngageDetected(40, {"Air"})
                        escortAuftrag:SetMissionSpeed(600)
                        escortAuftrag:SetROE(2)
                        escortAuftrag:SetROT(3)
                        local currentMission = self:GetMissionCurrent()
                        self:AddMission(escortAuftrag)
                        if currentMission then
                            currentMission:__Cancel(5)
                        end
                        escortPendingJoin[groupName] = nil
                        AddEscortMenu(clientGroup)
                        SCHEDULER:New(nil, function()
                            if clientGroup and clientGroup:IsAlive() then
                                MESSAGE:New(T:Get("WELCOME_ESCORT_AIRBORNE_HEADING"), 20):ToGroup(clientGroup)
                            end
                        end, {}, 30)
                    elseif escortHomeCoord then
                        local orbitAuftrag = AUFTRAG:NewORBIT_CIRCLE(escortHomeCoord, 10000, 350)
                        orbitAuftrag.missionTask=ENUMS.MissionTask.CAP
                        orbitAuftrag.missionAltitude = orbitAuftrag.TrackAltitude
                        orbitAuftrag:SetEngageDetected(40, {"Air"})
                        orbitAuftrag:SetMissionAltitude(10000)
                        local currentMission = self:GetMissionCurrent()
                        self:AddMission(orbitAuftrag)
                        if currentMission then
                            currentMission:__Cancel(5)
                        end
                        escortPendingJoin[groupName] = true
                        AddEscortMenu(clientGroup)
                        MESSAGE:New(T:Get("WELCOME_ESCORT_AIRBORNE_HOLDING"), 20):ToGroup(clientGroup)
                    end
                end
            end
        else
            if playerInAir then
                MESSAGE:New(T:Get("WELCOME_ESCORT_ON_ROUTE"), 20):ToGroup(clientGroup)
                AddEscortMenu(clientGroup)
            else
                AddEscortMenu(clientGroup)
                MESSAGE:New(T:Get("WELCOME_ESCORT_HOLDING_OVERHEAD"), 20):ToGroup(clientGroup)
            end
        end
        function escortGroup:OnAfterDead(From, Event, To)
            self:__Stop(1)
            escortGroups[groupName] = nil
            escortPendingJoin[groupName] = nil
            RemoveEscortMenu(clientGroup)
            if clientGroup and clientGroup:IsAlive() then
                MESSAGE:New(T:Get("WELCOME_ESCORT_DESTROYED"), 10):ToGroup(clientGroup)
            end
        end
    end

    local spawned = nil
    if EscortTakeoffFromGround == true then
        escortSpawnedFromGround = true
        spawned = SpawnEscortFromGround(clientGroup, templateName, alias, OnEscortSpawn)
        if not spawned then
            escortSpawnedFromGround = false
        end
    end
    if not spawned then
        escortSpawnedFromGround = false
        spawned = SpawnEscortInAirBehindClient(clientGroup, templateName, alias, OnEscortSpawn)
    end

    spawnedGroups[groupName].escortSpawnCount = spawnCount + 1
end
function AddEscortMenu(group)
    if not group then
        return
    end
    local T = getMooseGroupTranslator(group)
    local groupName = group:GetName()
    if escortMenus[groupName] then
        escortMenus[groupName]:Remove()
    end

    escortMenus[groupName] = MENU_GROUP:New(group, T:Get("WELCOME_MENU_ESCORT"))
    MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_ESCORT_FLIGHTSWEEP"), escortMenus[groupName], function()
        local esc = escortGroups[groupName]
        if esc then
        esc:SwitchROE(1)
        MESSAGE:New(T:Get("WELCOME_ESCORT_SET_ENGAGE_ALL"), 15):ToGroup(group)
    end
    end)
        MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_ESCORT_ENGAGE_IF_ENGAGED"), escortMenus[groupName], function()
        local esc = escortGroups[groupName]
        if esc then
        esc:SwitchROE(2)
        MESSAGE:New(T:Get("WELCOME_ESCORT_SET_ENGAGE_IF_ENGAGED"), 15):ToGroup(group)
    end
    end)
    
    MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_PATROL_AHEAD"), escortMenus[groupName], PatrolAhead, group)
    MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_RACETRACK_NOSE"), escortMenus[groupName], RaceTrackOnNose, group)
    MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_RACETRACK_LEFT_RIGHT"), escortMenus[groupName], RaceTrackLeftToRight, group)
    MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_RACETRACK_RIGHT_LEFT"), escortMenus[groupName], RaceTrackRightToLeft, group)
    MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_START_ORBIT"), escortMenus[groupName], EscortOrbit, group)
    MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_REJOIN"), escortMenus[groupName], EscortRejoin, group)
    MENU_GROUP_COMMAND:New(group, T:Get("WELCOME_MENU_ESCORT_RTB"), escortMenus[groupName], EscortAbort, group)
end
function RemoveEscortMenu(group)
    local groupName = group:GetName()
    if escortMenus[groupName] then
        escortMenus[groupName]:Remove()
        escortMenus[groupName] = nil
    end
end
function EscortOrbit(group)
    local T = getMooseGroupTranslator(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        escortPendingJoin[group:GetName()] = nil
        local clientCoord = group:GetPointVec2()
        local escortHeading = group:GetHeading()
        local orbitAuftrag = AUFTRAG:NewORBIT_CIRCLE(clientCoord, 25000, 350)
        orbitAuftrag.missionTask=ENUMS.MissionTask.CAP
        orbitAuftrag.missionAltitude = orbitAuftrag.TrackAltitude
        orbitAuftrag:SetEngageDetected(40, {"Air"})
        orbitAuftrag:SetMissionAltitude(25000)
        local currentMission = escortGroup:GetMissionCurrent()
        escortGroup:AddMission(orbitAuftrag)
        if currentMission then
            currentMission:__Cancel(5)
        end
        function orbitAuftrag:OnAfterStarted(From, Event, To)
            MESSAGE:New(T:Get("WELCOME_ESCORT_COPY"), 20):ToGroup(group)
        end
        function orbitAuftrag:OnAfterExecuting(From, Event, To)
            MESSAGE:New(T:Get("WELCOME_ESCORT_ORBIT_ESTABLISHED"), 20):ToGroup(group)
        end
    else
        MESSAGE:New(T:Get("WELCOME_ESCORT_NOT_FOUND"), 10):ToGroup(group)
        
    end
end
function PatrolAhead(group)
    if not group or not group:IsAlive() then
        MESSAGE:New(L10N:Get("WELCOME_ESCORT_PATROL_INVALID"), 20):ToAll()
        return
    end
    local T = getMooseGroupTranslator(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        escortPendingJoin[group:GetName()] = nil
        local currentMission = escortGroup:GetMissionCurrent()
        if currentMission then
            currentMission:__Cancel(5)
        end
        local PatrolAheadAuftrag = AUFTRAG:NewCAPGROUP(group, 25000, 550, 0, 15, 15, 0, 3, {"Air"}, 40)
        escortGroup:AddMission(PatrolAheadAuftrag)

        function PatrolAheadAuftrag:OnAfterStarted(From, Event, To)
         MESSAGE:New(T:Get("WELCOME_ESCORT_COPY"), 20):ToGroup(group)
         escortGroup:SetSpeed(650)
        end
        function PatrolAheadAuftrag:OnAfterExecuting(From, Event, To)
         MESSAGE:New(T:Get("WELCOME_ESCORT_PATROLLING_NOSE"), 20):ToGroup(group)
         escortGroup:SetSpeed(450)
        end
    else
        MESSAGE:New(T:Get("WELCOME_ESCORT_NOT_FOUND"), 20):ToGroup(group)
    end
end
function RaceTrackOnNose(group)
    local T = getMooseGroupTranslator(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        escortPendingJoin[group:GetName()] = nil
        local clientCoord = group:GetPointVec3()
        local clientHeading = group:GetHeading()
		
        local RaceTrackOnNoseAuftrag = AUFTRAG:NewPATROL_RACETRACK(clientCoord, 25000, 370, clientHeading, 20)
        RaceTrackOnNoseAuftrag:SetMissionAltitude(25000)
        RaceTrackOnNoseAuftrag:SetEngageDetected(40, {"Air"})
        RaceTrackOnNoseAuftrag:SetMissionSpeed(450)
        RaceTrackOnNoseAuftrag:SetROT(2)
		RaceTrackOnNoseAuftrag:SetROE(3)
        local currentMission = escortGroup:GetMissionCurrent()
        escortGroup:AddMission(RaceTrackOnNoseAuftrag)
        if currentMission then
		currentMission:__Cancel(5)
        end
        
       MESSAGE:New(T:Format("WELCOME_ESCORT_RACETRACK_HEADING", clientHeading), 20):ToGroup(group)
    else
        MESSAGE:New(T:Get("WELCOME_ESCORT_NOT_FOUND"), 10):ToGroup(group)
    end
end
function RaceTrackLeftToRight(group)
    local T = getMooseGroupTranslator(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        escortPendingJoin[group:GetName()] = nil
        local clientCoord = group:GetPointVec3()
        local clientHeading = group:GetHeading()
        local headingLeftToRight = (clientHeading - 90) % 360
		
        local RaceTrackLeftToRightAuftrag = AUFTRAG:NewPATROL_RACETRACK(clientCoord, 25000, 370, headingLeftToRight, 20)
        
        RaceTrackLeftToRightAuftrag:SetMissionAltitude(25000)
        RaceTrackLeftToRightAuftrag:SetEngageDetected(40, {"Air"})
        RaceTrackLeftToRightAuftrag:SetMissionSpeed(500)
        RaceTrackLeftToRightAuftrag:SetROT(2)
		RaceTrackLeftToRightAuftrag:SetROE(3)
        local currentMission = escortGroup:GetMissionCurrent()
        escortGroup:AddMission(RaceTrackLeftToRightAuftrag)
        if currentMission then
		currentMission:__Cancel(3)
        end
        MESSAGE:New(T:Format("WELCOME_ESCORT_RACETRACK_HEADING", headingLeftToRight), 20):ToGroup(group)
    else
        MESSAGE:New(T:Get("WELCOME_ESCORT_NOT_FOUND"), 20):ToGroup(group)
    end
end
function RaceTrackRightToLeft(group)
    local T = getMooseGroupTranslator(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        escortPendingJoin[group:GetName()] = nil
        local clientCoord = group:GetPointVec3()
        local clientHeading = group:GetHeading()
        local headingRightToLeft = (clientHeading + 90) % 360
        local RaceTrackRightToLeftAuftrag = AUFTRAG:NewPATROL_RACETRACK(clientCoord, 25000, 370, headingRightToLeft, 20)
        RaceTrackRightToLeftAuftrag:SetMissionAltitude(25000)
        RaceTrackRightToLeftAuftrag:SetEngageDetected(40, {"Air"})
        RaceTrackRightToLeftAuftrag:SetMissionSpeed(600)
        RaceTrackRightToLeftAuftrag:SetROT(2)
		RaceTrackRightToLeftAuftrag:SetROE(3)
        local currentMission = escortGroup:GetMissionCurrent()
        escortGroup:AddMission(RaceTrackRightToLeftAuftrag)
        if currentMission then
		currentMission:__Cancel(5)
        end
        MESSAGE:New(T:Format("WELCOME_ESCORT_RACETRACK_HEADING", headingRightToLeft), 20):ToGroup(group)
    else
        MESSAGE:New(T:Get("WELCOME_ESCORT_NOT_FOUND"), 20):ToGroup(group)
    end
end
function EscortRejoin(group)
    local T = getMooseGroupTranslator(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        local currentMission = escortGroup:GetMissionCurrent()

        if IsPlayerGroupInAir(group) then
            local escortAuftrag = AUFTRAG:NewESCORT(group, {x=-100, y=3048, z=300}, 40, {"Air"})
            escortAuftrag:SetMissionAltitude(25000)
            escortAuftrag:SetEngageDetected(40, {"Air"})
            escortAuftrag:SetMissionSpeed(600)
            escortAuftrag:SetROE(2)
            escortAuftrag:SetROT(3)
            escortGroup:AddMission(escortAuftrag)
            if currentMission then
                currentMission:__Cancel(5)
            end
            escortPendingJoin[group:GetName()] = nil
            MESSAGE:New(T:Get("WELCOME_ESCORT_REJOINING"), 20):ToGroup(group)
        else
            local clientCoord = group:GetPointVec2()
            local orbitAuftrag = AUFTRAG:NewORBIT_CIRCLE(clientCoord, 10000, 350)
            orbitAuftrag.missionTask=ENUMS.MissionTask.CAP
            orbitAuftrag.missionAltitude = orbitAuftrag.TrackAltitude
            orbitAuftrag:SetEngageDetected(40, {"Air"})
            orbitAuftrag:SetMissionAltitude(10000)
            orbitAuftrag:SetROE(2)
            orbitAuftrag:SetROT(2)
            escortGroup:AddMission(orbitAuftrag)
            if currentMission then
                currentMission:__Cancel(5)
            end
            escortPendingJoin[group:GetName()] = true
            MESSAGE:New(T:Get("WELCOME_ESCORT_CANT_JOIN_GROUND"), 20):ToGroup(group)
        end
    else
        MESSAGE:New(T:Get("WELCOME_ESCORT_NOT_FOUND"), 10):ToGroup(group)
    end
end
function EscortAbort(group)
    local T = getMooseGroupTranslator(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        escortPendingJoin[group:GetName()] = nil
        escortGroup:CancelAllMissions()
        MESSAGE:New(T:Get("WELCOME_ESCORT_RTB"), 20):ToGroup(group)
    else
        MESSAGE:New(T:Get("WELCOME_ESCORT_NOT_FOUND"), 10):ToGroup(group)
    end
end
function static:OnEventTakeoff(EventData)
    if not EventData.IniUnit or not EventData.IniPlayerName then
        return
    end

    local playerUnit = EventData.IniUnit
    local playerGroup = playerUnit:GetGroup()
    if not playerGroup then return end
    local T = getMooseGroupTranslator(playerGroup)
    local PGName = playerGroup:GetName()
    if not PGName then return end
    local playerType = playerUnit:GetTypeName()

    if IsEscortEligibleType(playerType) then
        EnsureEscortSpawnState(PGName, EventData.IniPlayerName)

        local escortGroup = escortGroups[PGName]
        if escortGroup and not escortGroup:IsAlive() then
            escortGroups[PGName] = nil
            escortPendingJoin[PGName] = nil
            escortGroup = nil
        end

        if escortPendingJoin[PGName] and escortGroup and IsPlayerGroupInAir(playerGroup) then
            local escortAuftrag = AUFTRAG:NewESCORT(playerGroup, {x=-100, y=3048, z=300}, 40, {"Air"})
            -- escortAuftrag:SetMissionAltitude(25000)
            -- escortAuftrag:SetEngageDetected(40, {"Air"})
            -- escortAuftrag:SetMissionSpeed(600)
            escortAuftrag:SetROE(2)
            escortAuftrag:SetROT(3)
            local currentMission = escortGroup:GetMissionCurrent()
            escortGroup:AddMission(escortAuftrag)
            if currentMission then
                currentMission:__Cancel(5)
            end
            escortPendingJoin[PGName] = nil
            AddEscortMenu(playerGroup)
            MESSAGE:New(T:Get("WELCOME_ESCORT_HEADING_TO_POSITION"), 20):ToGroup(playerGroup)
        end

        if EscortTakeoffFromGround ~= true and not escortGroup then
            MESSAGE:New(T:Format("WELCOME_ESCORT_AVAILABLE_PLAYER", EventData.IniPlayerName), 10, ""):ToUnit(playerUnit)
            AddEscortRequestMenu(playerGroup)
        elseif EscortTakeoffFromGround == true and not escortGroup and not escortRequestMenus[PGName] then
            AddEscortRequestMenu(playerGroup)
        end
    end
end

function static:OnEventPlayerLeaveUnit(EventData)
    local playerGroup = nil

    local function cleanupEscortForGroupName(groupName)
        if not groupName then return end



        local escortGroup = escortGroups[groupName]
        if escortGroup then
            escortGroup:Destroy()
            escortGroups[groupName] = nil
        end
        escortPendingJoin[groupName] = nil

        if escortMenus and escortMenus[groupName] then
            escortMenus[groupName]:Remove()
            escortMenus[groupName] = nil
        end

        if escortRequestMenus and escortRequestMenus[groupName] then
            escortRequestMenus[groupName]:Remove()
            escortRequestMenus[groupName] = nil
        end

        if menuEscortRequest and menuEscortRequest[groupName] then
            menuEscortRequest[groupName]:Remove()
            menuEscortRequest[groupName] = nil
        end

        if spawnedGroups and spawnedGroups[groupName] then
            spawnedGroups[groupName] = nil
        end
    end

    if EventData.id == EVENTS.PlayerLeaveUnit or EventData.id == EVENTS.PilotDead or EventData.id == EVENTS.Ejection then
        if EventData.IniUnit and EventData.IniPlayerName then
            local playerName = EventData.IniPlayerName
            local playerUnit = EventData.IniUnit
            playerGroup = playerUnit:GetGroup()
            local groupName = playerGroup and playerGroup:GetName()
            if (not groupName) and globalCallsignAssignments[playerName] then
                groupName = globalCallsignAssignments[playerName].groupName
            end

            local groupId = playerGroup and playerGroup:GetID() or (bc.groupByPlayer and bc.groupByPlayer[playerName])

            cleanupEscortForGroupName(groupName)
            if groupId then
                lc:pruneGroupMenus(groupId, groupName)
            end

            if followID[playerName] then
                followID[playerName]:Stop()
                followID[playerName] = nil
            end
            if groupName then
                if activeCSMenus[groupName] then
                    activeCSMenus[groupName]:Remove()
                    activeCSMenus[groupName] = nil
                end
            end

            if globalCallsignAssignments[playerName] then
                local callsignInfo = globalCallsignAssignments[playerName]
                local zoneName = callsignInfo.zoneName

                releaseSlot(playerName, zoneName)
                globalCallsignAssignments[playerName] = nil
            end
            if groupId then
                if bc.groupSupportMenus[groupId] then
                    local supportState = bc.groupSupportMenus[groupId]
                    for _, handle in ipairs(supportState.items or {}) do
                        missionCommands.removeItemForGroup(groupId, handle)
                    end
                    if supportState.menu then
                        missionCommands.removeItemForGroup(groupId, supportState.menu)
                    end
                    bc.groupSupportMenus[groupId] = nil
                end
                if bc.playerNames then
                    bc.playerNames[groupId] = nil
                end
            end
            if bc.groupByPlayer then
                bc.groupByPlayer[playerName] = nil
            end
            if bc.groupNameByPlayer then
                bc.groupNameByPlayer[playerName] = nil
            end
        else
            local clientSet = SET_CLIENT:New():FilterCategories("plane"):FilterCategories("helicopter"):FilterCoalitions("blue"):FilterAlive():FilterOnce()
            local alivePlayers = {}
            clientSet:ForEachClient(function(client)
                local pname = client:GetPlayerName()
                if pname then
                    alivePlayers[pname] = true
                end
            end)

            for playerName, callsignInfo in pairs(globalCallsignAssignments) do
                if not alivePlayers[playerName] then
                    local zoneName=callsignInfo.zoneName
                    local gname=callsignInfo.groupName
                    local groupId = bc.groupByPlayer and bc.groupByPlayer[playerName]
                    cleanupEscortForGroupName(gname)
                    if groupId then
                        lc:pruneGroupMenus(groupId, gname)
                    end
                    releaseSlot(playerName,zoneName)
                    if followID[playerName] then followID[playerName]:Stop() followID[playerName]=nil end
                    if gname then
                        if activeCSMenus[gname] then activeCSMenus[gname]:Remove() activeCSMenus[gname]=nil end
                    end
                    if groupId then
                        if bc.groupSupportMenus[groupId] then
                            local supportState = bc.groupSupportMenus[groupId]
                            for _, handle in ipairs(supportState.items or {}) do
                                missionCommands.removeItemForGroup(groupId, handle)
                            end
                            if supportState.menu then
                                missionCommands.removeItemForGroup(groupId, supportState.menu)
                            end
                            bc.groupSupportMenus[groupId] = nil
                        end
                        if bc.playerNames then
                            bc.playerNames[groupId] = nil
                        end
                    end
                    if bc.groupByPlayer then
                        bc.groupByPlayer[playerName] = nil
                    end
                    if bc.groupNameByPlayer then
                        bc.groupNameByPlayer[playerName] = nil
                    end
                    globalCallsignAssignments[playerName]=nil
                end
            end
        end
    end
    if playerGroup then
    activeCSMenus[playerGroup:GetName()] = nil
    end
end

static:HandleEvent(EVENTS.Shot, static.OnEventShot)
static:HandleEvent(EVENTS.BaseCaptured, static.onBaseCapture)
static:HandleEvent(EVENTS.PlayerLeaveUnit, static.OnEventPlayerLeaveUnit)
static:HandleEvent(EVENTS.PilotDead, static.OnEventPlayerLeaveUnit)
static:HandleEvent(EVENTS.Ejection, static.OnEventPlayerLeaveUnit)
static:HandleEvent(EVENTS.Takeoff, static.OnEventTakeoff)
_SETTINGS:SetPlayerMenuOff()
_SETTINGS:SetA2G_BR()
_SETTINGS:SetA2A_BULLS()
_SETTINGS:SetImperial()

BASE:I('Welcome Message has been loaded.')
