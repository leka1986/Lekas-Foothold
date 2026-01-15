BASE:I("Loading Leka's special all in one script handler")

-- This script handles statics, Welcome messages, Callsign assigement, Escort, Missle tracking, Radio menu for ATIS and getting closest Airbase.

-- This script needs cuople of things, Static unit called EventMan and the carrier named CVN-72 or change those names bellow,
-- most importantly it needs Moose.

static = STATIC:FindByName("EventMan", true)

atisZones = {}

allZones = {}

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
end


local function BuildAtisZonesFromFootholdZones()
    local built = {}
    if type(zones) ~= "table" then
        return built
    end

    for _, zone in pairs(zones) do
        local airbaseName = zone and zone.airbaseName
        if type(airbaseName) == "string" and airbaseName ~= "" then
            local airbase = AIRBASE:FindByName(airbaseName)
            if airbase and airbase:IsAirdrome() then
                built[airbaseName] = { airbaseName = airbaseName }
            end
        end
    end

    return built
end

local function InitAtisZones()
    atisZones = BuildAtisZonesFromFootholdZones()
end

-- Build once at script load (this file is executed after Foothold `zones` is created).
InitAtisZones()
InitAllZones()


followID={}
staticDetails = {}
spawnedGroups = {}
escortGroups = {}
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
                env.info("Static not found or not alive: " .. staticName)
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
    BASE:I("Zone Assignments:")
    for zone, assignments in pairs(zoneAssignments) do
        BASE:I("Zone: " .. zone)
        for fullCallsign, assignedPlayer in pairs(assignments) do
            BASE:I("    Callsign: " .. fullCallsign .. " -> Player: " .. assignedPlayer)
        end
    end
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
        BASE:I(string.format("Player '%s' has callsign '%s' in zone '%s'", playerName, callsignInfo.callsign, callsignInfo.zoneName))
        return callsignInfo.callsign, callsignInfo.zoneName
    end
    BASE:I(string.format("Player '%s' has no callsign assignment.", playerName))
    return nil, nil
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
                                BASE:I(string.format("Reusing existing callsign %s for player %s in zone %s", existingCallsign, playerName, zoneName))
                                return existingCallsign, IFF
                            end
                        end
                    end
                end
            end
        else
            releaseSlot(playerName, assignedZone)
            globalCallsignAssignments[playerName] = nil
            BASE:I("Removed old callsign " .. existingCallsign .. " for player: " .. playerName)
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
        BASE:I(string.format("Assigned %s to player %s in zone %s", newCallsign, playerName, zoneName))
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
                BASE:I(string.format("Assigned %s to player %s in zone %s", fullCallsign, playerName, zoneName))
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
                BASE:I(string.format("Assigned %s to player %s in zone %s (cycled back, first available)", fullCallsign, playerName, zoneName))
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
                BASE:I(string.format("Assigned %s to player %s in zone %s (cycled back, fallback)", fullCallsign, playerName, zoneName))
                logZoneAssignments()
                return fullCallsign, IFF
            end
        end
    end

    return nil, nil
end

function getPreferredOrder(groupName)
    for prefix, typeAssignments in pairs(aircraftAssignments) do
        if string.find(groupName, prefix) then
            local order
            if prefix == "F.A.18"               then preferredOrder = {"Arctic1","Bender2","Crimson3","Dusty4","Lion3"}
            elseif prefix == "F.16CM"           then preferredOrder = {"Indy9","Jester1","Venom4"}
            elseif prefix == "A.10C"            then preferredOrder = {"Hawg8","Tusk2","Pig7"}
            elseif prefix == "AH.64D"           then preferredOrder = {"Rage9","Salty1"}
            elseif prefix == "AJS37"            then preferredOrder = {"Fenris6","Grim7"}
            elseif prefix == "UH.1H"            then preferredOrder = {"Nitro5"}
            elseif prefix == "CH.47F"           then preferredOrder = {"Greyhound3"}
            elseif prefix == "F.15E.S4"         then preferredOrder = {"Hitman3"}
            elseif prefix == "F.14B"           then preferredOrder = {"Elvis5","Mustang4"}
            elseif prefix == ".OH.58D"          then preferredOrder = {"Blackjack4"}
            elseif prefix == "Ka.50.III"        then preferredOrder = {"Orca6"}
            elseif prefix == "AV.8B"            then preferredOrder = {"Quarterback1"}
            elseif prefix == "M.2000"           then preferredOrder = {"Quebec8"}
            elseif prefix == "F.4E.45MC"        then preferredOrder = {"Savage1","Scary2"}
            elseif prefix == "MiG.29A.Fulcrum"  then preferredOrder = {"Wedge7"}
            elseif prefix == "Mi.24P"           then preferredOrder = {"Scorpion3"}
            elseif prefix == "C.130J.30"        then preferredOrder = {"Mighty1"}
            end
            return prefix, preferredOrder
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

function releaseSlot(playerName, zoneName)
    if zoneAssignments[zoneName] then
        for callsign, assignedPlayer in pairs(zoneAssignments[zoneName]) do
            if assignedPlayer == playerName then
                zoneAssignments[zoneName][callsign] = nil

                globalCallsignAssignments[playerName] = nil

                BASE:I(string.format("Released %s from player %s in zone %s", callsign, playerName, zoneName))
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
    BASE:I(string.format("sendDetailedMessageToPlayer: Short message used for %s, altitude %.1f", unitName, u:GetAltitude(true)))
    dur = 10 end
    MESSAGE:New(message, dur):ToUnit(u)
    if playerGroupID and trigger.misc.getUserFlag(180) == 0 then
        trigger.action.outSoundForGroup(playerGroupID, "admin.wav")
    end
end
local function getAltimeter()
    local coord = COORDINATE:NewFromVec3({x = 0, y = 0, z = 0})
    local pressure_hPa = coord:GetPressure(0)  
    local pressureInHg = pressure_hPa * 0.0295300
    return string.format("Altimeter %.2f", pressureInHg)
end

local _AIRBOSS = {}

local function AirBoss(name)
    if not _AIRBOSS[name] then
        _AIRBOSS[name] = AIRBOSS:New(name)
    end
    return _AIRBOSS[name]
end

local function refreshBeacons()
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
end

SCHEDULER:New(nil, refreshBeacons, {}, 30, 1200)

local function IsThereACarrier()
    if IsGroupActive("CVN-73") or IsGroupActive("CVN-72") or IsGroupActive("CVN-59") 
        or IsGroupActive("CVN-74") then return true
    end
    return false
end

local function getBRC(cvnName)
    if cvnName and IsGroupActive(cvnName) then
        return string.format("BRC %d°", AirBoss(cvnName):GetBRC())
    elseif IsGroupActive("CVN-73") then
        return string.format("BRC %d°", AirBoss("CVN-73"):GetBRC())
    elseif IsGroupActive("CVN-72") then
        return string.format("BRC %d°", AirBoss("CVN-72"):GetBRC())
    elseif IsGroupActive("CVN-59") then
        return string.format("BRC %d°", AirBoss("CVN-59"):GetBRC())
    elseif IsGroupActive("CVN-74") then
        return string.format("BRC %d°", AirBoss("CVN-74"):GetBRC())
    end
    return "BRC data unavailable"
end

function hullPrettyAndTCN(name)
    if name=="CVN-73" then return "George Washington","73X" end
    if name=="CVN-72" then return "Abraham Lincoln","72X" end
    if name=="CVN-59" then return "Forrestal","59X" end
    if name=="CVN-74" then return "John C. Stennis","74X" end
end

local function getCarrierWind(cvnName)
    local cvn

    if cvnName then
        cvn = UNIT:FindByName(cvnName)
    elseif IsGroupActive("CVN-73") then
        cvn = UNIT:FindByName("CVN-73")
    elseif IsGroupActive("CVN-72") then
        cvn = UNIT:FindByName("CVN-72")
    elseif IsGroupActive("CVN-59") then
        cvn = UNIT:FindByName("CVN-59")
    elseif IsGroupActive("CVN-74") then
        cvn = UNIT:FindByName("CVN-74")
    end
    if not cvn then
        return "Carrier not found"
    end
    local dir, spd = cvn:GetCoordinate():GetWind(18)
    if not dir or not spd then
        return "Wind data unavailable"
    end
    return string.format("Wind is %03d° at %d knots", (dir + 360) % 360, spd * 1.94384)
end

function getCarrierInfo()
    if IsGroupActive("CVN-73") then
        return "George Washington", "73X"
    end
    if IsGroupActive("CVN-72") then
        return "Abraham Lincoln", "72X"
    end
    if IsGroupActive("CVN-59") then
        return "Forrestal", "59X"
    end
    if IsGroupActive("CVN-74") then
        return "John C. Stennis", "74X"
    end
end

local function getAirbaseWind(airbaseName)
    local airbase = AIRBASE:FindByName(airbaseName)
    if airbase then
        local airbaseCoord = airbase:GetCoordinate()  
        local windDirection, windSpeed = airbaseCoord:GetWind(10)
        if windDirection and windSpeed then
            local windSpeedKnots = math.floor(windSpeed * 1.94384)
            windDirection = (windDirection + 360) % 360
            return string.format("Wind is %03d° at %d", windDirection, windSpeedKnots), windDirection
        else
            return "Wind data unavailable", nil
        end
    else
        return "Airbase not found", nil
    end
end

local function fetchActiveRunway(zoneName)
    local airbase = AIRBASE:FindByName(atisZones[zoneName].airbaseName)
    if not airbase then
        trigger.action.outText("Airbase/FARP conflict detected or airbase not found: " .. atisZones[zoneName].airbaseName, 10)
        return "Airbase data unavailable."
    end
    local landingRunway, takeoffRunway = airbase:GetActiveRunway()
    if not landingRunway and not takeoffRunway then
        return "No active runway data available."
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
            return string.format("Active runway is %s", landingRunwayName)
        else
            return string.format("Active runway for landing is %s, for takeoff is %s", landingRunwayName, takeoffRunwayName)
        end
    elseif landingRunwayName then
        return string.format("Active runway (landing) is %s", landingRunwayName)
    elseif takeoffRunwayName then
        return string.format("Active runway (takeoff) is %s", takeoffRunwayName)
    else
        return "No active runway data available."
    end
end

local function getPlayerWind(playerCoord)
    local playerPosition = playerCoord:GetVec3()
    local windVector = atmosphere.getWind(playerPosition)
    if windVector then
        local windSpeedMps = math.sqrt(windVector.x^2 + windVector.z^2)
        local windSpeedKnots = math.floor(windSpeedMps * 1.94384)
        local originalWindDirection = math.deg(math.atan2(windVector.z, windVector.x))
        originalWindDirection = (originalWindDirection + 360) % 360
        local originatingWindDirection = (originalWindDirection + 180) % 360
        return string.format("Wind is %03d° at %d", originatingWindDirection, windSpeedKnots), originatingWindDirection
    else
        return "Wind data unavailable", nil
    end
end
local function getPlayerTemperature(playerCoord)
    local playerPosition = playerCoord:GetVec3()
    local temperatureCelsius = playerCoord:GetTemperature(playerPosition.y)
    
    if temperatureCelsius then
        return string.format("Temperature is %d°C", temperatureCelsius)
    else
        return "Temperature data unavailable"
    end
end

-- ATIS MENU --

local function sendATISInformation(client, group, zoneName)
    if not client then return end
    if string.find(zoneName,"Carrier") then
        local mother = IsGroupActive("CVN-73") and "CVN-73"
                    or IsGroupActive("CVN-72") and "CVN-72"
                    or IsGroupActive("CVN-59") and "CVN-59"
                    or IsGroupActive("CVN-74") and "CVN-74"

        local prettyMother = hullPrettyAndTCN(mother)
        local lines = {}
        table.insert(lines,
            string.format("ATIS for %s:\n\n%s, %s\n\n%s",
                          prettyMother,getCarrierWind(mother),getAltimeter(),getBRC(mother)))

        if mother ~= "CVN-59" and IsGroupActive("CVN-59") then
            table.insert(lines,
                string.format("ATIS for Forrestal:\n\n%s, %s\n\n%s",
                              getCarrierWind("CVN-59"),getAltimeter(),getBRC("CVN-59")))
        end
        if mother ~= "CVN-74" and IsGroupActive("CVN-74") then
            table.insert(lines,
                string.format("ATIS for Forrestal:\n\n%s, %s\n\n%s",
                              getCarrierWind("CVN-74"),getAltimeter(),getBRC("CVN-74")))
        end

        MESSAGE:New(table.concat(lines,"\n------------------------------------------------\n"),15,""):ToUnit(client)
    else
        local wind,dir = getAirbaseWind(atisZones[zoneName].airbaseName)
        if wind=="Wind data unavailable" or wind=="Airbase not found" then
            MESSAGE:New(string.format("ATIS for %s:\n\n%s",zoneName,wind),15,""):ToUnit(client)
        else
            local run = fetchActiveRunway(zoneName,dir) or "Runway information not available"
            local msg = string.format("ATIS for %s:\n\n%s, %s\n\n%s.",zoneName,wind,getAltimeter(),run)
            MESSAGE:New(msg,20,""):ToUnit(client)
        end
    end
end



local MainMenu = {}

local function getNearestCarrierName(coord)
    local nearest=nil local math=math.huge
    for _,name in ipairs({"CVN-73","CVN-72","CVN-59","CVN-74"}) do
        if IsGroupActive(name) then
            local unit=UNIT:FindByName(name)
            if unit then
                local distance=coord:Get2DDistance(unit:GetCoordinate())
                if distance<math then math=distance nearest=name end
            end
        end
    end
    if math<200 then return nearest end
end



function getClosestFriendlyAirbaseInfo(client)
    if not client or not client:IsAlive() then
        BASE:E("Client is nil or not alive.")
        return
    end
    local playerCoord = client:GetCoordinate()
    if not playerCoord then
        MESSAGE:New("Unable to determine player position.",15,""):ToUnit(client)
        return
    end
    local clientType      = client:GetTypeName()
    local considerCarrier = (clientType == "FA-18C_hornet" or clientType == "F-14B")
    local lines           = {}

    if considerCarrier then
        local carriers = {"CVN-73","CVN-72","CVN-59","CVN-74"}
        for _,name in ipairs(carriers) do
            if IsGroupActive(name) then
                local cvn = UNIT:FindByName(name)
                if cvn then
                    local ccoord   = cvn:GetCoordinate()
                    local cdist    = playerCoord:Get2DDistance(ccoord)
                    local cbrg     = (playerCoord:HeadingTo(ccoord,nil) - playerCoord:GetMagneticDeclination() + 360) % 360
                    local pretty,tacan = hullPrettyAndTCN(name)
                    local msg = string.format("Carrier: %s\n\nDistance: %.2f NM, Bearing: %03d°\n\nTACAN: %s, %s",
                                              pretty,cdist*0.000539957,cbrg,tacan,getBRC(name))
                    table.insert(lines,msg)
                end
            end
        end
    end

    local closestNormalZoneName,closestNormalDistance,closestNormalBearing = nil,math.huge,nil
    for zoneName,details in pairs(atisZones) do
        local airbase = AIRBASE:FindByName(details.airbaseName)
        if airbase and airbase:GetCoalition() == coalition.side.BLUE then
            local dist     = playerCoord:Get2DDistance(airbase:GetCoordinate())
            local trueBrg  = playerCoord:HeadingTo(airbase:GetCoordinate(),nil)
            local magDecl  = playerCoord:GetMagneticDeclination()
            local magBrg   = (trueBrg - magDecl + 360) % 360
            if not string.find(zoneName,"Carrier") and dist < closestNormalDistance then
                closestNormalZoneName = zoneName
                closestNormalDistance = dist
                closestNormalBearing  = magBrg
            end
        end
    end

    if closestNormalZoneName then
        local distanceInNM   = closestNormalDistance * 0.000539957
        local displayName    = closestNormalZoneName .. (WaypointList[closestNormalZoneName] or "")
        local windMessage,windDirection = getAirbaseWind(atisZones[closestNormalZoneName] and atisZones[closestNormalZoneName].airbaseName or "")
        local altimeterMessage,runwayInfo = "",""
        if windMessage ~= "Wind data unavailable" and windMessage ~= "Airbase not found" then
            altimeterMessage = getAltimeter()
            runwayInfo       = fetchActiveRunway(closestNormalZoneName,windDirection) or "Runway information not available"
        end
        local airfieldLine = string.format("Closest Friendly Airfield: %s\n\nDistance: %.2f NM, Bearing: %03d°\n\n%s%s%s",
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

    local groupID = group:GetName()

    if MainMenu[groupID] then
        MainMenu[groupID]:Remove()
    end

    local mainMenu = MENU_GROUP:New(group, "ATIS and Closest Airbase")
    MainMenu[groupID] = mainMenu

    local atisMenu = MENU_GROUP:New(group, "ATIS Information", mainMenu)
    MENU_GROUP_COMMAND:New(group, "Get Closest Friendly Airbase", mainMenu, getClosestFriendlyAirbaseInfo, client)
    if IsThereACarrier() then
    MENU_GROUP_COMMAND:New(group, "Get ATIS for Mother", atisMenu, sendATISInformation, client, group, "Carrier")
    end
    local currentMenu = atisMenu
    local menuItemCount = 2

    for zoneName, details in pairs(atisZones) do
        if not zoneName:find("Carrier") then
            local airbase = AIRBASE:FindByName(details.airbaseName)
            if airbase and airbase:GetCoalitionName() == 'Blue' then
                if menuItemCount >= 9 then
                    currentMenu = MENU_GROUP:New(group, "Next Page...", atisMenu)
                    menuItemCount = 0
                end
                MENU_GROUP_COMMAND:New(group, "Get ATIS for " .. zoneName, currentMenu, sendATISInformation, client, group, zoneName)
                menuItemCount = menuItemCount + 1
            end
        end
    end
end

function static:onBaseCapture(_event)
local event = _event -- Core.Event#EVENTDATA
if event.id == EVENTS.BaseCaptured and event.Place then
	local capturedBaseName = event.Place:GetName()  
	local coalitionSide = event.Place:GetCoalition()

	if atisZones[capturedBaseName] and event.Place:GetCoalition() == coalition.side.BLUE then  
		
			local clientSet = SET_CLIENT:New():FilterCategories("plane"):FilterCoalitions("blue"):FilterAlive():FilterOnce()
			clientSet:ForEachClient(function(client)
				SetupATISMenu(client)  
				SCHEDULER:New(nil, function()
                local group=client:GetGroup()
                local zname
                for k,v in pairs(atisZones) do if v.airbaseName==capturedBaseName then zname=k break end end
                if zname then sendATISInformation(client,group,zname) end
                end, {}, 10)
			end)
		end
	end  
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
	local groupName = group:GetName()
	
	local foundZone = false
	
	for _, zoneName in ipairs(allZones) do
		if not zoneNameOverride or zoneName == zoneNameOverride then
			local zone = ZONE:New(zoneName)
			if zone and zone:IsCoordinateInZone(player:GetCoordinate()) then
                foundZone = true
                
                local playerUnitID = player:GetID()
                local playerGroupID = player:GetGroup():GetID()
                
                local isNewVisit = not playerZoneVisits[playerName] or not playerZoneVisits[playerName][zoneName]
                playerZoneVisits[playerName] = playerZoneVisits[playerName] or {}
                playerZoneVisits[playerName][zoneName] = true

                local assignedCallsign, assignedIFF = findOrAssignSlot(playerName, groupName, zoneName)

                local altimeterMessage = getAltimeter()
                local temperatureMessage = getPlayerTemperature(player:GetCoordinate())
                local greetingMessage, detailedMessage
                local windMessage,displayWindDirection=atisZones[zoneName] and getAirbaseWind(atisZones[zoneName].airbaseName) or getPlayerWind(player:GetCoordinate())
                local activeRunwayMessage=atisZones[zoneName] and fetchActiveRunway(zoneName,displayWindDirection) or "N/A"

                    local carrierHull=getNearestCarrierName(player:GetCoordinate())
                    local carrierName,tacanCode,brcMessage,carrierWindMessage
                    if carrierHull then
                        brcMessage=getBRC(carrierHull)
                        carrierWindMessage=getCarrierWind(carrierHull)
                        carrierName,tacanCode=hullPrettyAndTCN(carrierHull)
                    end
                    if string.find(zoneName, "Carrier") and carrierHull then

                    if assignedCallsign and assignedIFF then
                        greetingMessage = string.format("Welcome aboard %s, %s!\n\nYou have been assigned to %s, IFF %04d.\n\nStandby for weather report from Mother.", carrierName, rankDisplay, assignedCallsign, assignedIFF)
                        detailedMessage = string.format("Welcome aboard %s, %s!\n\n%s, %s, %s\n\nTCN: %s, %s\n\nOnce 7 miles out, push Tactical on CH 3.", carrierName, assignedCallsign, carrierWindMessage, temperatureMessage, altimeterMessage, tacanCode, brcMessage)
                    else
                        greetingMessage = string.format("Welcome aboard %s, %s!\n\nStandby for weather and BRC.", carrierName, rankDisplay)
                        detailedMessage = string.format("Welcome aboard %s, %s!\n\n%s, %s, %s\n\nTCN: %s, %s\n\nOnce 7 miles out, push Tactical on CH 3.", carrierName, playerName, carrierWindMessage, temperatureMessage, altimeterMessage, tacanCode, brcMessage)
                    end
                else
                    local windMessage, displayWindDirection

                    if atisZones[zoneName] then
                        windMessage, displayWindDirection = getAirbaseWind(atisZones[zoneName].airbaseName)
                        local activeRunwayMessage = fetchActiveRunway(zoneName, displayWindDirection)

                        if isNewVisit then
                            if assignedCallsign and assignedIFF then
                                greetingMessage = string.format("Welcome to %s, %s!\n\nYou have been assigned to %s, IFF %04d.\n\nStandby for weather and ATIS information.", zoneName, rankDisplay, assignedCallsign, assignedIFF)
                                detailedMessage = string.format("Welcome to %s, %s!\n\n%s, %s, %s.\n\n%s.\n\nOnce airborne push Tactical on CH 3.", zoneName, assignedCallsign, windMessage, temperatureMessage, altimeterMessage, activeRunwayMessage)
                            else
                                greetingMessage = string.format("Welcome to %s, %s!\n\nStandby for weather information.", zoneName, rankDisplay)
                                detailedMessage = string.format("Welcome to %s, %s!\n\n%s, %s, %s.\n\n%s.\n\nOnce airborne push Tactical on CH 3.", zoneName, playerName, windMessage, temperatureMessage, altimeterMessage, activeRunwayMessage)
                            end

                        else
                            if assignedCallsign and assignedIFF then
                                greetingMessage = string.format("Welcome back to %s, %s!\n\nYou have been assigned to %s, IFF %04d.\n\nYou'll receive the latest weather and ATIS info shortly.", zoneName, rankDisplay, assignedCallsign, assignedIFF)
                                detailedMessage = string.format("Welcome back to %s, %s!\n\n%s, %s, %s.\n\n%s.\n\nOnce airborne push Tactical on CH 3.", zoneName, assignedCallsign, windMessage, temperatureMessage, altimeterMessage, activeRunwayMessage)
                            else
                                greetingMessage = string.format("Welcome back to %s, %s!\n\nStandby for updated weather information.", zoneName, rankDisplay)
                                detailedMessage = string.format("Welcome back to %s, %s!\n\n%s, %s, %s.\n\n%s.\n\nOnce airborne push Tactical on CH 3.", zoneName, playerName, windMessage, temperatureMessage, altimeterMessage, activeRunwayMessage)
                            end
                        end
                    else

                        local playerCoord = player:GetCoordinate()
                        windMessage, _ = getPlayerWind(playerCoord)
                        temperatureMessage = getPlayerTemperature(playerCoord)

                        if isNewVisit then
                            if assignedCallsign and assignedIFF then
                                greetingMessage = string.format("Welcome to %s, %s!\n\nYou have been assigned to %s, IFF %04d.\n\nStandby for weather information.", zoneName, rankDisplay, assignedCallsign, assignedIFF)
                                detailedMessage = string.format("Welcome to %s, %s!\n\n%s, %s, %s.\n\nOnce airborne push Tactical on CH 3.", zoneName, assignedCallsign, windMessage, temperatureMessage, altimeterMessage)
                            else
                                greetingMessage = string.format("Welcome to %s, %s!\n\nStandby for weather information.", zoneName, rankDisplay)
                                detailedMessage = string.format("Welcome to %s, %s!\n\n%s, %s, %s.\n\nOnce airborne push Tactical on CH 3.", zoneName, playerName, windMessage, temperatureMessage, altimeterMessage)
                            end

                        else
                            if assignedCallsign and assignedIFF then
                                greetingMessage = string.format("Welcome back to %s, %s!\n\nYou have been assigned to %s, IFF %04d.\n\nYou'll receive updated weather information shortly.", zoneName, rankDisplay, assignedCallsign, assignedIFF)
                                detailedMessage = string.format("Welcome back to %s, %s!\n\n%s, %s, %s.\n\nOnce airborne push Tactical on CH 3.", zoneName, assignedCallsign, windMessage, temperatureMessage, altimeterMessage)
                            else
                                greetingMessage = string.format("Welcome back to %s, %s!\n\nStandby for updated weather information.", zoneName, rankDisplay)
                                detailedMessage = string.format("Welcome back to %s, %s!\n\n%s, %s, %s.\n\nOnce airborne push Tactical on CH 3.", zoneName, playerName, windMessage, temperatureMessage, altimeterMessage)
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
                        local csMenu = MENU_GROUP:New(group, "Change Call Sign")
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
                                        if string.find(zoneName,"Carrier") and carrierHull then
                                            sendGreetingToPlayer(UnitName, string.format("Welcome aboard %s, %s!\n\nYou have been assigned to %s, IFF %04d.\n\nStandby for weather report from Mother.", carrierName, playerName, fullCS, iff))
                                            followID[playerName] = SCHEDULER:New(nil, sendDetailedMessageToPlayer, {playerUnitID, string.format("Welcome aboard %s, %s!\n\n%s, %s, %s\n\nTCN: %s, %s\n\nOnce 7 miles out, push Tactical on CH 3.", carrierName, fullCS, carrierWindMessage, temperatureMessage, altimeterMessage, tacanCode, brcMessage), playerGroupID, UnitName}, 60)
                                        else
                                            sendGreetingToPlayer(UnitName, string.format("Welcome to %s, %s!\n\nYou have been assigned to %s, IFF %04d.\n\nStandby for weather and ATIS information.", zoneName, playerName, fullCS, iff))
                                            followID[playerName] = SCHEDULER:New(nil, sendDetailedMessageToPlayer, {playerUnitID, string.format("Welcome to %s, %s!\n\n%s, %s, %s.\n\n%s.\n\nOnce airborne push Tactical on CH 3.", zoneName, fullCS, windMessage, temperatureMessage, altimeterMessage, activeRunwayMessage), playerGroupID, UnitName}, 60)
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
                buildCallSignMenu()
                end
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
                    local altimeterMessage          = getAltimeter()
                    local temperatureMsg            = getPlayerTemperature(carrierPos)
                    local brcMessage                = getBRC(carrierHull)
                    local windMessage               = getCarrierWind(carrierHull)

                    if assignedCallsign and assignedIFF then
                        greetingMessage = string.format("Welcome aboard %s, %s!\n\nYou have been assigned to %s, IFF %04d.\n\nStandby for weather report from Mother.",prettyName,rankDisplay,assignedCallsign,assignedIFF)
                        detailedMessage = string.format("Welcome aboard %s, %s!\n\n%s, %s, %s\n\n%s\n\nOnce 7 miles out, push Tactical on CH 3.",prettyName,assignedCallsign,windMessage,temperatureMsg,altimeterMessage,brcMessage)
                    else
                        greetingMessage = string.format("Welcome aboard %s, %s!\n\nStandby for weather and BRC.",prettyName,rankDisplay)
                        detailedMessage = string.format("Welcome aboard %s, %s!\n\n%s, %s, %s\n\n%s\n\nOnce 7 miles out, push Tactical on CH 3.",prettyName,playerName,windMessage,temperatureMsg,altimeterMessage,brcMessage)
                    end
                    sendGreetingToPlayer(UnitName,greetingMessage)
                    if followID[playerName] then followID[playerName]:Stop() followID[playerName]=nil end
                        followID[playerName]=SCHEDULER:New(nil, sendDetailedMessageToPlayer,{playerUnitID,detailedMessage,player:GetGroup():GetID(),UnitName},60)
                    else
                    return
                end
            else
                MESSAGE:New("Carrier not available.",15,""):ToUnit(player)
            end
        end
    end


function WeaponImpact(Weapon)
    local impactPos = Weapon:GetImpactVec3()
    if impactPos then
        trigger.action.explosion(impactPos, 150)
        BASE:I("Explosion triggered at impact position.")
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
					BASE:I("Tracking RED coalition helicopter target.")
                end
            end
        end
    end
end

function AddEscortRequestMenu(group)
    if not group then
        return
    end
    local groupName = group:GetName()
    escortRequestMenus[groupName] = MENU_GROUP_COMMAND:New(group, "Request Escort", nil, EscortClientGroup, group)
end
function EnableEscortRequestMenu(group)
    if not group then
        return
    end
    local groupName = group:GetName()
    if menuEscortRequest[groupName] then
        menuEscortRequest[groupName]:Remove()
    end
end
function RequestEscort(group)
    EscortClientGroup(group)
    local groupName = group:GetName()
    if menuEscortRequest[groupName] then
        menuEscortRequest[groupName]:Remove()
        menuEscortRequest[groupName] = nil
    end
end
function RemoveRequestEscortMenu(group)
    local groupName = group:GetName()
    if escortRequestMenus[groupName] then
        escortRequestMenus[groupName]:Remove()
        escortRequestMenus[groupName] = nil
    end
end
function FindEscortTemplateWithAlias(clientGroup, alias)
    local aircraftType = clientGroup:GetUnit(1):GetTypeName()
    local templateName = "EscortA10"
    if string.find(aircraftType, "F-15") then
        templateName = "EscortF15"
    end
    return templateName
end

function EscortClientGroup(clientGroup)
    local groupName = clientGroup:GetName()
    local spawnCount = spawnedGroups[groupName] and spawnedGroups[groupName].escortSpawnCount or 1
    local playerName = clientGroup:GetUnit(1):GetPlayerName() or groupName
    local safePlayerName = playerName:gsub("%s+", "_"):gsub("[^%w_%-]", "_")
    local alias = groupName .. "_" .. safePlayerName .. "_Escort_" .. string.format("%03d", spawnCount)
    local templateName = FindEscortTemplateWithAlias(clientGroup, alias)

    local clientPos = clientGroup:GetPointVec3()
    local clientHeading = clientGroup:GetHeading()
    local distanceBehindMeters = 1500

    local offsetX = math.cos(math.rad(clientHeading)) * distanceBehindMeters
    local offsetZ = math.sin(math.rad(clientHeading)) * distanceBehindMeters

    local desiredAlt = UTILS.MetersToFeet(clientPos.y) + 10000
    local spawnPos = { x = clientPos.x - offsetX, y = UTILS.FeetToMeters(desiredAlt), z = clientPos.z - offsetZ }
    local coord = COORDINATE:NewFromVec3(spawnPos)

    local sp = SPAWN:NewWithAlias(templateName, alias)
    sp:OnSpawnGroup(function(g)
        escortGroup = FLIGHTGROUP:New(g)
        escortGroup:GetGroup():CommandSetUnlimitedFuel(true):SetOptionRadarUsingForContinousSearch(true):SetOptionWaypointPassReport(false)
        escortGroups[groupName] = escortGroup
        local escortAuftrag = AUFTRAG:NewESCORT(clientGroup, { x = -100, y = 3048, z = 100 }, 40, { "Air" })
        escortGroup:AddMission(escortAuftrag)
        MESSAGE:New("ESCORT IS ON ROUTE.\n\nYou can control the escort from the radio menu.", 20):ToGroup(clientGroup)
        RemoveRequestEscortMenu(clientGroup)
        AddEscortMenu(clientGroup)
        function escortGroup:OnAfterDead(From, Event, To)
            escortGroup:__Stop(1)
            escortGroups[groupName] = nil
            RemoveEscortMenu(clientGroup)
            if clientGroup and clientGroup:IsAlive() then
                MESSAGE:New("Your escort group has been destroyed. Takeoff from an airfield to get a new one.", 10):ToGroup(clientGroup)
            end
        end
    end)
    sp:SpawnFromCoordinate(coord)

    spawnedGroups[groupName].escortSpawnCount = spawnCount + 1
end
function AddEscortMenu(group)
    if not group then
        return
    end
    local groupName = group:GetName()

    escortMenus[groupName] = MENU_GROUP:New(group, "Escort")
    MENU_GROUP_COMMAND:New(group, "Escort: Flightsweep", escortMenus[groupName], function()
        local esc = escortGroups[groupName]
        if esc then
        esc:SwitchROE(1)
        MESSAGE:New("Escort is set to Engage All", 15):ToGroup(group)
    end
    end)
        MENU_GROUP_COMMAND:New(group, "Escort: Engage if engaged", escortMenus[groupName], function()
        local esc = escortGroups[groupName]
        if esc then
        esc:SwitchROE(2)
        MESSAGE:New("Escort is set to Engage if Engaged", 15):ToGroup(group)
    end
    end)
    
    MENU_GROUP_COMMAND:New(group, "Patrol Ahead 15 NM", escortMenus[groupName], PatrolAhead, group)
    MENU_GROUP_COMMAND:New(group, "Racetrack, On my nose 20 NM", escortMenus[groupName], RaceTrackOnNose, group)
    MENU_GROUP_COMMAND:New(group, "Racetrack, Left to right 20 NM", escortMenus[groupName], RaceTrackLeftToRight, group)
    MENU_GROUP_COMMAND:New(group, "Racetrack, Right to left 20 NM", escortMenus[groupName], RaceTrackRightToLeft, group)
    MENU_GROUP_COMMAND:New(group, "Start Orbit here", escortMenus[groupName], EscortOrbit, group)
    MENU_GROUP_COMMAND:New(group, "Rejoin", escortMenus[groupName], EscortRejoin, group)
    MENU_GROUP_COMMAND:New(group, "Escort RTB", escortMenus[groupName], EscortAbort, group)
end
function RemoveEscortMenu(group)
    local groupName = group:GetName()
    if escortMenus[groupName] then
        escortMenus[groupName]:Remove()
        escortMenus[groupName] = nil
    else
        env.info("No escort menu found for " .. groupName .. ".")
    end
end
function EscortOrbit(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        local clientCoord = group:GetPointVec2()
        local escortHeading = group:GetHeading()
        local orbitAuftrag = AUFTRAG:NewORBIT_CIRCLE(clientCoord, 25000, 350)
        orbitAuftrag.missionTask=ENUMS.MissionTask.CAP
        orbitAuftrag.missionAltitude = orbitAuftrag.TrackAltitude
        orbitAuftrag:SetEngageDetected(40, {"Air"})
        orbitAuftrag:SetMissionAltitude(25000)
        escortGroup:AddMission(orbitAuftrag)
        local currentMission = escortGroup:GetMissionCurrent()
        if currentMission then
            currentMission:__Cancel(5)
        end
        function orbitAuftrag:OnAfterStarted(From, Event, To)
            MESSAGE:New("Escort: Copy that!", 20):ToGroup(group)
        end
        function orbitAuftrag:OnAfterExecuting(From, Event, To)
            MESSAGE:New("Escort: Orbit established.", 20):ToGroup(group)
        end
    else
        MESSAGE:New("No active escort found.", 10):ToGroup(group)
        
    end
end
function PatrolAhead(group)
    if not group or not group:IsAlive() then
        MESSAGE:New("Unable to set up patrol: escort group is invalid or not alive.", 20):ToAll()
        return
    end
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        local currentMission = escortGroup:GetMissionCurrent()
        if currentMission then
            currentMission:__Cancel(5)
        end
        local PatrolAheadAuftrag = AUFTRAG:NewCAPGROUP(group, 25000, 550, 0, 15, 15, 0, 3, {"Air"}, 40)
        escortGroup:AddMission(PatrolAheadAuftrag)

        function PatrolAheadAuftrag:OnAfterStarted(From, Event, To)
         MESSAGE:New("Escort: Copy that!", 20):ToGroup(group)
         escortGroup:SetSpeed(650)
        end
        function PatrolAheadAuftrag:OnAfterExecuting(From, Event, To)
         MESSAGE:New("Escort: We are now patrolling 15 NM at your nose.", 20):ToGroup(group)
         escortGroup:SetSpeed(450)
        end
    else
        MESSAGE:New("No active escort found.", 20):ToGroup(group)
    end
end
function RaceTrackOnNose(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        local clientCoord = group:GetPointVec3()
        local clientHeading = group:GetHeading()
		
        local RaceTrackOnNoseAuftrag = AUFTRAG:NewPATROL_RACETRACK(clientCoord, 25000, 370, clientHeading, 20)
        RaceTrackOnNoseAuftrag:SetMissionAltitude(25000)
        RaceTrackOnNoseAuftrag:SetEngageDetected(40, {"Air"})
        RaceTrackOnNoseAuftrag:SetMissionSpeed(450)
        RaceTrackOnNoseAuftrag:SetROT(2)
		RaceTrackOnNoseAuftrag:SetROE(3)
        escortGroup:AddMission(RaceTrackOnNoseAuftrag)
        local currentMission = escortGroup:GetMissionCurrent()
        if currentMission then
		currentMission:__Cancel(5)
        end
        
       MESSAGE:New("Escort is setting up a 20 NM racetrack at heading " .. clientHeading, 20):ToGroup(group)
    else
        MESSAGE:New("No active escort found.", 10):ToGroup(group)
    end
end
function RaceTrackLeftToRight(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        local clientCoord = group:GetPointVec3()
        local clientHeading = group:GetHeading()
        local headingLeftToRight = (clientHeading - 90) % 360
		
        local RaceTrackLeftToRightAuftrag = AUFTRAG:NewPATROL_RACETRACK(clientCoord, 25000, 370, headingLeftToRight, 20)
        escortGroup:AddMission(RaceTrackLeftToRightAuftrag)
        RaceTrackLeftToRightAuftrag:SetMissionAltitude(25000)
        RaceTrackLeftToRightAuftrag:SetEngageDetected(40, {"Air"})
        RaceTrackLeftToRightAuftrag:SetMissionSpeed(500)
        RaceTrackLeftToRightAuftrag:SetROT(2)
		RaceTrackLeftToRightAuftrag:SetROE(3)
        local currentMission = escortGroup:GetMissionCurrent()
        if currentMission then
		currentMission:__Cancel(3)
        end
        MESSAGE:New("Escort is setting up a 20 NM racetrack at heading " .. headingLeftToRight, 20):ToGroup(group)
    else
        MESSAGE:New("No active escort found.", 20):ToGroup(group)
    end
end
function RaceTrackRightToLeft(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
        local clientCoord = group:GetPointVec3()
        local clientHeading = group:GetHeading()
        local headingRightToLeft = (clientHeading + 90) % 360
        local RaceTrackRightToLeftAuftrag = AUFTRAG:NewPATROL_RACETRACK(clientCoord, 25000, 370, headingRightToLeft, 20)
        RaceTrackRightToLeftAuftrag:SetMissionAltitude(25000)
        RaceTrackRightToLeftAuftrag:SetEngageDetected(40, {"Air"})
        RaceTrackRightToLeftAuftrag:SetMissionSpeed(600)
        RaceTrackRightToLeftAuftrag:SetROT(2)
		RaceTrackRightToLeftAuftrag:SetROE(3)
        escortGroup:AddMission(RaceTrackRightToLeftAuftrag)
        local currentMission = escortGroup:GetMissionCurrent()
        if currentMission then
		currentMission:__Cancel(5)
        end
        MESSAGE:New("Escort is setting up a 20 NM racetrack at heading " .. headingRightToLeft, 20):ToGroup(group)
    else
        MESSAGE:New("No active escort found.", 20):ToGroup(group)
    end
end
function EscortRejoin(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
    
		local clientCoord = group:GetPointVec3()
        local escortAuftrag = AUFTRAG:NewESCORT(group, {x=-100, y=3048, z=300}, 40, {"Air"})
        escortAuftrag:SetMissionAltitude(25000)
        escortAuftrag:SetEngageDetected(40, {"Air"})
        escortAuftrag:SetMissionSpeed(600)
        escortAuftrag:SetROE(2)
        escortAuftrag:SetROT(3)
        escortGroup:AddMission(escortAuftrag)
        local currentMission = escortGroup:GetMissionCurrent()
        if currentMission then
		currentMission:__Cancel(5)
        end
        MESSAGE:New("Escort is rejoining your formation.", 20):ToGroup(group)
    else
        MESSAGE:New("No active escort found.", 10):ToGroup(group)
    end
end
function EscortAbort(group)
    local escortGroup = escortGroups[group:GetName()]
    if escortGroup then
                
        escortGroup:CancelAllMissions()
        MESSAGE:New("Escort is RTB", 20):ToGroup(group)
    else
        MESSAGE:New("No active escort found.", 10):ToGroup(group)
    end
end
function static:OnEventTakeoff(EventData)
    if not EventData.IniUnit or not EventData.IniPlayerName then
        return
    end

    local playerUnit = EventData.IniUnit
    local playerGroup = playerUnit:GetGroup()
    if not playerGroup then return end
    local PGName = playerGroup:GetName()
    if not PGName then return end
    local playerType = playerUnit:GetTypeName()

    if playerType == "F-15ESE" or playerType == "A-10C_2" or playerType == "Hercules" or playerType == "C-130J-30" then
        spawnedGroups[PGName] = spawnedGroups[PGName] or {
            playerName = EventData.IniPlayerName,
            escortGroups = {},
            menuEscortRequest = nil,
            escortSpawnCount = 1
        }

        MESSAGE:New("Escort is available, " .. EventData.IniPlayerName .. ".", 10, ""):ToUnit(playerUnit)
        AddEscortRequestMenu(playerGroup)
        menuEscortRequest[PGName] = spawnedGroups[PGName].menuEscortRequest

    end
end

function static:OnEventPlayerLeaveUnit(EventData)
    BASE:I("OnEventPlayerLeaveUnit called")

    if EventData.id == EVENTS.PlayerLeaveUnit or EventData.id == EVENTS.PilotDead then
        if EventData.IniUnit and EventData.IniPlayerName then
            local playerUnit = EventData.IniUnit
            playerGroup = playerUnit:GetGroup()
            if playerGroup then
                local groupName = playerGroup:GetName()
                local escortGroup = escortGroups[groupName]
                if escortGroup then
                    escortGroup:Destroy()
                    escortGroups[groupName] = nil
                    BASE:I("Escort group for " .. groupName .. " has been destroyed because the player left the unit.")
                end
            end

            local playerName = EventData.IniPlayerName
            if followID and playerName and followID[playerName] then
                followID[playerName]:Stop()
                followID[playerName] = nil
            end
            if activeCSMenus and playerGroup then
                local groupName = playerGroup:GetName()
                if activeCSMenus[groupName] then
                    activeCSMenus[groupName]:Remove()
                    activeCSMenus[groupName] = nil
                end
            end
            BASE:I("Player leaving unit: " .. playerName)

            if globalCallsignAssignments[playerName] then
                local callsignInfo = globalCallsignAssignments[playerName]
                local zoneName = callsignInfo.zoneName
                BASE:I("Player had assignment: " .. callsignInfo.callsign .. " in zone " .. zoneName)

                releaseSlot(playerName, zoneName)
                globalCallsignAssignments[playerName] = nil
            else
                BASE:I("No global assignment found for player: " .. playerName)
            end
        else
            BASE:I("IniPlayerName is nil. Player might have disconnected without a proper event.")

            local clientSet = SET_CLIENT:New():FilterCategories("plane"):FilterCategories("helicopter"):FilterCoalitions("blue"):FilterAlive():FilterOnce()

            for playerName, callsignInfo in pairs(globalCallsignAssignments) do
                local isPlayerAlive = false

                clientSet:ForEachClient(function(client)
                    if client:GetPlayerName() == playerName then
                        isPlayerAlive = true
                    end
                end)

                if not isPlayerAlive then
                    local zoneName=callsignInfo.zoneName
                    local gname=callsignInfo.groupName
                    releaseSlot(playerName,zoneName)
                    if followID and followID[playerName] then followID[playerName]:Stop() followID[playerName]=nil end
                    if activeCSMenus and gname and activeCSMenus[gname] then activeCSMenus[gname]:Remove() activeCSMenus[gname]=nil end
                    globalCallsignAssignments[playerName]=nil
                end
            end
        end
    else
        BASE:I("Event ID does not match PlayerLeaveUnit or PilotDead")
    end
    if activeCSMenus and playerGroup then
    activeCSMenus[playerGroup:GetName()] = nil
    end
end

static:HandleEvent(EVENTS.Shot, static.OnEventShot)
static:HandleEvent(EVENTS.BaseCaptured, static.onBaseCapture)
static:HandleEvent(EVENTS.PlayerLeaveUnit, static.OnEventPlayerLeaveUnit)
static:HandleEvent(EVENTS.Takeoff, static.OnEventTakeoff)
_SETTINGS:SetPlayerMenuOff()
_SETTINGS:SetA2G_BR()
_SETTINGS:SetA2A_BULLS()
_SETTINGS:SetImperial()

BASE:I("Loading completed for Leka's special all in one script handler")
