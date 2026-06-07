---------------------------------------------------------------------------
-- ## Red CTLD ##
---------------------------------------------------------------------------
if Allow_Red_CTLD == true then
    
BASE:I("Red CTLD : is loading.")

local function getFootholdLocalization()
    local localization = FH_L10N or FootholdLocalization
    if not localization then
        error("Foothold_Localization.lua must be loaded before using localized CTLD text.", 2)
    end
    return localization
end

local L10N = {
    Get = function(_, ...) return getFootholdLocalization():Get(...) end,
    Format = function(_, ...) return getFootholdLocalization():Format(...) end,
    ForLocale = function(_, ...) return getFootholdLocalization():ForLocale(...) end,
    ForMooseGroup = function(_, ...) return getFootholdLocalization():ForMooseGroup(...) end,
}

local CTLD_MENU_LABEL_KEYS = {
    ["Zone supplies"] = "CTLD_MENU_ZONE_SUPPLIES",
}

local function ctldLocalizedCargoLabel(T, label)
    local key = CTLD_MENU_LABEL_KEYS[tostring(label)]
    if key then
        return T:Get(key)
    end
    return tostring(label)
end

CTLD_Logging = false
CTLD_Logging_DEEP = false

Foothold_redCtld = CTLD:New(coalition.side.RED, {--[[ "CH.47", "C.130J.30",]] "Mi.8MT", "Hercules", "Ми.8МТВ2", "Ми.24П", "Mi.24P"}, "Red Logistics")
Foothold_redCtld:SetGroupLocaleResolver(function(_, Group)
    return getFootholdLocalization():GetMooseGroupLocale(Group)
end)
function Foothold_redCtld:GetFootholdLocalizedCargoLabel(translator, label)
    if type(translator) == "string" then
        translator = L10N:ForLocale(translator)
    end
    return ctldLocalizedCargoLabel(translator or L10N, label)
end

Foothold_redCtld.dropcratesanywhere = true
Foothold_redCtld.forcehoverload = false
Foothold_redCtld.CrateDistance = 65
Foothold_redCtld.PackDistance = 120
Foothold_redCtld.maximumHoverHeight = 20
Foothold_redCtld.minimumHoverHeight = 3
Foothold_redCtld.smokedistance = 8000
Foothold_redCtld.enableFixedWing = true
Foothold_redCtld.FixedMinAngels = 100
Foothold_redCtld.FixedMaxSpeed = 200
Foothold_redCtld.dropAsCargoCrate = true
Foothold_redCtld.nobuildinloadzones = true
Foothold_redCtld.movecratesbeforebuild = false
Foothold_redCtld.hoverautoloading = false
Foothold_redCtld.enableslingload = true
Foothold_redCtld.usesubcats = true
Foothold_redCtld.pilotmustopendoors = true
Foothold_redCtld.buildtime = 30
Foothold_redCtld.TroopUnloadDistGroundHook = 35
Foothold_redCtld.onestepmenu = true
Foothold_redCtld.basetype = "uh1h_cargo"
Foothold_redCtld.RadioSoundFC3 = "beaconsilent.ogg"
Foothold_redCtld.VehicleMoveFormation = { AI.Task.VehicleFormation.VEE, AI.Task.VehicleFormation.ECHELON_LEFT, AI.Task.VehicleFormation.ECHELON_RIGHT, AI.Task.VehicleFormation.RANK, AI.Task.VehicleFormation.CONE }

Foothold_redCtld.UseC130LoadAndUnload = true
Foothold_redCtld.returntroopstobase = false

Foothold_redCtld:__Start(4)

---------------------------------------------------------------------------
-- Red CTLD: Pricing
---------------------------------------------------------------------------

local RED_CTLD_DEFAULT_PRICE = 0

RedCTLDPrices = RedCTLDPrices or {
    ["Scout BRDM 2"] = { price = 150, reqRank = 2 },
    ["ATGM AT-3 SAGGER"] = { price = 300, reqRank = 2 },
    ["MRAP M-ATV"] = { price = 600, reqRank = 2 },
    ["MLRS LC 80 MM 2.2 NM"] = { price = 500, reqRank = 1 },
    ["Arty SPM 259 Nona 3 NM"] = { price = 1000, reqRank = 2 },
    ["Arty SPH 253 Akatsia 8 NM"] = { price = 1500, reqRank = 2 },
    ["SA-8"] = { price = 2000, reqRank = 5 },
    ["Truck with ZU-23"] = { price = 1000, reqRank = 1 },
    ["SA-3 SAM system"] = { price = 5000, reqRank = 8 },
    ["Kord 12.7 MM"] = { price = 100, reqRank = 1 },
    ["Ammo Truck"] = { price = 100, reqRank = 1 },
    ["Squad 4 AK47"] = { price = 100, reqRank = 1 },
    ["Squad 8 AK47"] = { price = 150, reqRank = 1 },
}

local function redCtldPriceOf(name)
    local v = RedCTLDPrices and RedCTLDPrices[name]
    if type(v) == "table" then
        return v.price or v.cost or RED_CTLD_DEFAULT_PRICE
    end
    return v or RED_CTLD_DEFAULT_PRICE
end

local function redCtldReqRankOf(name)
    local v = RedCTLDPrices and RedCTLDPrices[name]
    if type(v) == "table" then
        return v.reqRank or 0
    end
    return 0
end

function Foothold_redCtld:GetCargoPrice(name, cargo)
    return redCtldPriceOf(name)
end

function Foothold_redCtld:GetCargoReqRank(name, cargo)
    return redCtldReqRankOf(name)
end

local function redCtldDebit(Group, amount, reason, reqRank)
    if amount <= 0 then return true end
    local coal = Group:GetCoalition()
    local dcs = Group:GetDCSObject()
    local gid = dcs:getID()
    return bc:debit(coal, amount, gid, dcs, reason, reqRank) == true
end

local function redCtldCredit(Group, amount, reason)
    if amount <= 0 then return true end
    local coal = Group:GetCoalition()
    local dcs = Group:GetDCSObject()
    local gid = dcs:getID()
    return bc:credit(coal, amount, gid, dcs, reason) == true
end

local function redCtldRequestedSets(Cargo, number)
    local perSet = (Cargo and Cargo.GetCratesNeeded and Cargo:GetCratesNeeded()) or 1
    if perSet < 1 then perSet = 1 end
    local requestNumber = tonumber(number) or perSet
    requestNumber = math.floor(requestNumber)
    if requestNumber < 1 then requestNumber = perSet end
    local requestedSets = math.floor((requestNumber + perSet - 1) / perSet)
    if requestedSets < 1 then requestedSets = 1 end
    return requestedSets
end

function Foothold_redCtld:CanGetUnits(Group, Unit, Config, quantity, quiet)
    if CTLDCost ~= true then return true end
    local name = Config and Config.Name or "none"
    local n = math.max(1, tonumber(quantity) or 1)
    local price = redCtldPriceOf(name)
    local reqRank = redCtldReqRankOf(name)
    local charge = price * n
    return redCtldDebit(Group, charge, name, reqRank)
end

function Foothold_redCtld:CanGetTroops(Group, Unit, Cargo, quantity, Inject)
    if Inject then return true end
    if self.suppressmessages and tonumber(quantity) == 1 then return true end
    if CTLDCost ~= true then return true end
    local name = Cargo and Cargo.GetName and Cargo:GetName() or nil
    if type(name) ~= "string" then return true end
    local n = math.max(1, tonumber(quantity) or 1)
    local price = redCtldPriceOf(name)
    local reqRank = redCtldReqRankOf(name)
    local charge = price * n
    local reason = (n > 1) and string.format("%dx %s", n, name) or name
    return redCtldDebit(Group, charge, reason, reqRank)
end

function Foothold_redCtld:CanGetCrates(Group, Unit, Cargo, number, drop, pack, quiet, suppressGetEvent)
    return true
end

function Foothold_redCtld:OnAfterRemoveCratesNearby(From, Event, To, Group, Unit, Cargotable)
    local inzone = self:IsUnitInZone(Unit, CTLD.CargoZoneType.LOAD)
    if not inzone then return end
    if CTLDCost ~= true then return end

    local byName = {}
    for _, cargo in pairs(Cargotable or {}) do
        local name = cargo:GetName() or "none"
        byName[name] = (byName[name] or 0) + 1
    end

    for name, count in pairs(byName) do
        local object = self:_FindCratesCargoObject(name)
        local removedSets = redCtldRequestedSets(object, count)
        local refund = redCtldPriceOf(name) * removedSets
        local reason = "remove: " .. tostring(removedSets) .. "x " .. name
        redCtldCredit(Group, refund, reason)
    end
end

---------------------------------------------------------------------------
-- Red CTLD: Restore Tracking
---------------------------------------------------------------------------

local RedGroundUnits = {}

RED_MAX_AT_SPAWN = RED_MAX_AT_SPAWN or {
    ["Scout BRDM 2"] = 5,
    ["Ammo Truck"] = 5,
    ["Arty SPM 259 Nona 3 NM"] = 2,
    ["Arty SPH 253 Akatsia 8 NM"] = 2,
    ["MLRS LC 80 MM 2.2 NM"] = 2,
    ["Kord 12.7 MM"] = 3,
    ["MRAP M-ATV"] = 3,
    ["ATGM AT-3 SAGGER"] = 3,
    ["Truck with ZU-23"] = 5,
    ["SA-8"] = 5,
    ["SA-3 SAM system"] = 2,
    ["Squad 8 AK47"] = 1,
    ["Squad 4 AK47"] = 1,
}

local function redSelectOldestUnit(unitTable, cargoName, predicate)
    local oldestIdx, oldestEntry, oldestTimestamp = nil, nil, math.huge
    for idx, entry in ipairs(unitTable) do
        if entry.CargoName == cargoName then
            if (not predicate or predicate(entry)) and entry.Timestamp < oldestTimestamp then
                oldestIdx = idx
                oldestEntry = entry
                oldestTimestamp = entry.Timestamp
            end
        end
    end
    return oldestIdx, oldestEntry, oldestTimestamp
end

local function redDestroyTrackedGroup(entry)
    if not entry or not entry.groupName then return end
    local dcsGroup = GROUP:FindByName(entry.groupName)
    if dcsGroup and dcsGroup:IsAlive() then
        dcsGroup:Destroy()
    end
end

local function redEnforceMaxAtSpawnForTrackedUnits(trackedUnits, maxAtSpawnMap, restockCallback)
    local unitsByName = {}
    for _, trackedEntry in ipairs(trackedUnits) do
        local cargoName = trackedEntry.CargoName
        unitsByName[cargoName] = unitsByName[cargoName] or {}
        table.insert(unitsByName[cargoName], trackedEntry)
    end

    for normalizedName, groupedEntries in pairs(unitsByName) do
        table.sort(groupedEntries, function(entryA, entryB) return entryA.Timestamp > entryB.Timestamp end)
        local maxAllowed = maxAtSpawnMap[normalizedName] or RED_MAX_AT_SPAWN[normalizedName] or 0
        local totalEntries = #groupedEntries
        for listIndex = totalEntries, maxAllowed + 1, -1 do
            local oldEntry = groupedEntries[listIndex]
            redDestroyTrackedGroup(oldEntry)
            restockCallback(oldEntry.CargoName)
            for trackedIndex, trackedData in ipairs(trackedUnits) do
                if trackedData.groupName == oldEntry.groupName then
                    table.remove(trackedUnits, trackedIndex)
                    break
                end
            end
        end
    end
end

local function redRestorePointTooFarFromBlue(point, maxDistanceNm)
    if not point then
        return false, nil, nil
    end

    if not bc._blueActiveZones then
        bc:updateBlueZoneCount()
    end

    local bestClearanceNm = nil
    local bestZoneName = nil
    for _, z in ipairs(bc._blueActiveZones or {}) do
        local cz = CustomZone:getByName(z.zone)
        if cz and cz.point then
            local clearanceM = UTILS.VecDist2D({ x = point.x, y = point.z }, { x = cz.point.x, y = cz.point.z }) - (cz.radius or 0)
            local clearanceNm = clearanceM / 1852
            if (not bestClearanceNm) or clearanceNm < bestClearanceNm then
                bestClearanceNm = clearanceNm
                bestZoneName = z.zone
            end
        end
    end

    if not bestClearanceNm then
        return false, nil, nil
    end

    local limitNm = tonumber(maxDistanceNm) or 120
    return bestClearanceNm > limitNm, bestZoneName, bestClearanceNm
end

local function redTrackedGroupAlive(entry)
    local group = entry and entry.groupName and GROUP:FindByName(entry.groupName) or nil
    return group and group:IsAlive()
end

local function redPruneDeadTrackedUnits(unitTable)
    for index = #unitTable, 1, -1 do
        if not redTrackedGroupAlive(unitTable[index]) then
            table.remove(unitTable, index)
        end
    end
end

local function redCountTrackedCargo(unitTable, cargoName)
    local count = 0
    for _, entry in ipairs(unitTable) do
        if entry.CargoName == cargoName and redTrackedGroupAlive(entry) then
            count = count + 1
        end
    end
    return count
end

local function redResolveBuiltCargoName(self, groupName)
    local cargoName, stock = "unknown", 0
    local bestCargoData = nil
    local bestTemplateLen = -1

    for _, cargoData in pairs(self.Cargo_Crates) do
        local templates = cargoData and cargoData.Templates or nil
        if type(templates) == "string" then
            templates = { templates }
        end
        if type(templates) == "table" then
            for _, templateName in pairs(templates) do
                local templateText = tostring(templateName or "")
                if templateText ~= "" and string.find(groupName, templateText, 1, true) then
                    local templateLen = #templateText
                    if templateLen > bestTemplateLen then
                        bestTemplateLen = templateLen
                        bestCargoData = cargoData
                    end
                end
            end
        end
    end

    if bestCargoData then
        cargoName = bestCargoData:GetName()
        stock = bestCargoData:GetStock()
    end

    return cargoName, stock
end

Foothold_redCtld.buildRunning = 0

function Foothold_redCtld:OnAfterCratesBuildStarted(From, Event, To, Group, Unit, CargoName)
    self.buildRunning = self.buildRunning + 1
    self:I(string.format(
        "[RED BUILD] start running=%d  group=%s  unit=%s  cargo=%s",
        self.buildRunning,
        Group and Group:GetName() or "nil",
        Unit and Unit:GetName() or "nil",
        CargoName or "nil"))

    if not CargoName then return end

    local cargoObject = self:_FindCratesCargoObject(CargoName)
    if not cargoObject then return end

    redPruneDeadTrackedUnits(RedGroundUnits)

    local currentStock = cargoObject:GetStock() or 0
    local totalStock = cargoObject:GetStock0() or 0
    if totalStock <= 0 or currentStock < 0 then return end

    local reserveThreshold = totalStock * 0.5
    if currentStock >= reserveThreshold then
        self:I(string.format("[RED RESERVE] stock %d/%d >= 50%% for %s (no action)", currentStock, totalStock, CargoName))
        return
    end

    local oldestIdx, victim, oldestTs = redSelectOldestUnit(RedGroundUnits, CargoName, redTrackedGroupAlive)
    if oldestIdx and victim then
        self:I(string.format("[RED RESERVE] DELETE oldest %s ts=%f (group=%s)", CargoName, oldestTs, victim.groupName))
        redDestroyTrackedGroup(victim)
        table.remove(RedGroundUnits, oldestIdx)
        self:AddStockCrates(CargoName, 1)
        self:I(string.format("[RED RESERVE] stock %d/%d below 50%%, +1 stock refunded for %s", currentStock, totalStock, CargoName))
    else
        self:I(string.format("[RED RESERVE] no existing %s groups to delete", CargoName))
    end
end

function Foothold_redCtld:OnAfterCratesBuild(From, Event, To, Group, Unit, Vehicle)
    if self.buildRunning > 0 then
        self.buildRunning = self.buildRunning - 1
    end

    local currentTime = timer.getTime()
    local groupName = Vehicle:GetName() or "unknown"

    if not Group then return end

    local cargoName, stock = redResolveBuiltCargoName(self, groupName)
    if cargoName == "unknown" then
        self:I(string.format("[RED BUILD] unable to resolve cargo for group=%s", groupName))
        return
    end

    local maxTimestamp = 0
    for _, group in ipairs(RedGroundUnits) do
        if group.CargoName == cargoName and group.Timestamp > maxTimestamp then
            maxTimestamp = group.Timestamp
        end
    end

    local cargoObject = self:_FindCratesCargoObject(cargoName)
    local currentStock = cargoObject and cargoObject:GetStock() or stock
    local configuredMax = RED_MAX_AT_SPAWN[cargoName] or cargoObject and cargoObject:GetStock0() or 0
    local newTimestamp = (maxTimestamp > 0) and (maxTimestamp + 1) or currentTime
    self:I(string.format("[RED BUILD] complete cargoName=%s, max=%d, currentStock=%d", cargoName, configuredMax, currentStock))

    local groupExists = false
    for _, group in ipairs(RedGroundUnits) do
        if group.groupName == groupName then
            group.Timestamp = newTimestamp
            group.Stock = currentStock
            groupExists = true
            break
        end
    end

    if not groupExists then
        table.insert(RedGroundUnits, {
            groupName = groupName,
            Timestamp = newTimestamp,
            CargoName = cargoName,
            Stock = currentStock
        })
    end

    for _, trackedGroup in ipairs(RedGroundUnits) do
        if trackedGroup.CargoName == cargoName then
            trackedGroup.Stock = currentStock
        end
    end
end

RedCTLDUnitCapabilities = RedCTLDUnitCapabilities or {
    ["Mi-8MT"] = { true, true, 3, 16, 15, 6000 },
    ["Mi-8MTV2"] = { true, true, 3, 18, 15, 6000 },
    ["Mi-24P"] = { true, true, 2, 8, 15, 1000 },
    ["Mi-24V"] = { true, true, 2, 8, 15, 1000 },
    ["CH-47Fbl1"] = { true, true, 5, 32, 20, 10800 },
    ["Hercules"] = { true, true, 8, 20, 25, 20000 },
    ["C-130J-30"] = { true, true, 7, 64, 35, 21500 },
}

for unitType, v in pairs(RedCTLDUnitCapabilities) do
    Foothold_redCtld:SetUnitCapabilities(unitType, v[1], v[2], v[3], v[4], v[5], v[6])
end

local function addRedStaticFromType(name, typeName, mass, subCategory, unitTypes, displayName)
    return Foothold_redCtld:AddStaticsCargoFromType(name, typeName, mass, nil, subCategory, true, nil, unitTypes, nil, nil, nil, displayName)
end


Foothold_redCtld:AddTroopsCargo("Squad 4 AK47",{"CTLD_TROOPS_RED_Squad_4"},CTLD_CARGO.Enum.TROOPS,4,80,6)
Foothold_redCtld:AddTroopsCargo("Squad 8 AK47",{"CTLD_TROOPS_RED_Squad_8"},CTLD_CARGO.Enum.TROOPS,8,80,6)

Foothold_redCtld:AddCratesCargo("Scout BRDM 2",{"CTLD_CARGO_RED_Scout"},CTLD_CARGO.Enum.VEHICLE,2,500,6, "Support")
Foothold_redCtld:AddCratesCargo("Ammo Truck",{"CTLD_CARGO_RED_AmmoTruck"},CTLD_CARGO.Enum.VEHICLE,2,500,6, "Support")
Foothold_redCtld:AddCratesCargo("Arty SPM 259 Nona 3 NM",{"CTLD_CARGO_RED_ARTY_Nona"},CTLD_CARGO.Enum.VEHICLE,2,2000,6, "ARTY")
Foothold_redCtld:AddCratesCargo("Arty SPH 253 Akatsia 8 NM",{"CTLD_CARGO_RED_ARTY_Akatsia"},CTLD_CARGO.Enum.VEHICLE,2,2500,6, "ARTY")
Foothold_redCtld:AddCratesCargo("MLRS LC 80 MM 2.2 NM",{"CTLD_CARGO_RED_ARTY_BBM1"},CTLD_CARGO.Enum.VEHICLE,2,2500,6, "ARTY")
Foothold_redCtld:AddCratesCargo("Kord 12.7 MM",{"CTLD_CARGO_RED_Kord"},CTLD_CARGO.Enum.VEHICLE,2,500,6, "LIGHT ARMOR")
Foothold_redCtld:AddCratesCargo("MRAP M-ATV",{"CTLD_CARGO_RED_MRAP"},CTLD_CARGO.Enum.VEHICLE,2,1000,6, "LIGHT ARMOR")
Foothold_redCtld:AddCratesCargo("ATGM AT-3 SAGGER",{"CTLD_CARGO_RED_AT_3"},CTLD_CARGO.Enum.VEHICLE,2,500,6, "ANTI TANK")

Foothold_redCtld:AddCratesCargo("Truck with ZU-23",{"CTLD_CARGO_RED_ZU_23"},CTLD_CARGO.Enum.VEHICLE,2,1000,5, "SAM/AAA")
Foothold_redCtld:AddCratesCargoNoMove("SA-8",{"CTLD_CARGO_RED_SA_8"},CTLD_CARGO.Enum.VEHICLE,2,3000,5, "SAM/AAA")

Foothold_redCtld:AddCratesCargoNoMove("SA-3 SAM system",{"CTLD_CARGO_RED_SA_3"},CTLD_CARGO.Enum.VEHICLE,5,2500,4, "SAM/AAA")



--addRedStaticFromType("Red zone supplies CH-47", "cds_crate", 3500, "Zone supplies", {"CH-47Fbl1"}, "Zone supplies")
addRedStaticFromType("Red zone supplies C-130J", "iso_container_small", 4000, "Zone supplies", {"C-130J-30"}, "Zone supplies")
addRedStaticFromType("Red zone supplies MI-8", "ammo_cargo", 2000, "Zone supplies", {"Mi-8MT"}, "Zone supplies")
addRedStaticFromType("Red zone supplies Mi-24P", "ammo_cargo", 500, "Zone supplies", {"Mi-24P"}, "Zone supplies")

local RED_ZONE_SUPPLY_TYPES = {
    ["Red zone supplies CH-47"] = true,
    ["Red zone supplies MI-8"] = true,
    ["Red zone supplies Mi-24P"] = true,
    ["Red zone supplies C-130J"] = true,
}

local RED_ZONE_SUPPLY_AGL_THRESHOLD = 0.5
local RED_ZONE_SUPPLY_NOZONE_TTL = 600
local RED_ZONE_SUPPLY_MOVE_EPS2 = 0.25
local RED_ZONE_SUPPLY_NONEED_TTL = 60
local ZONE_SUPPLY_CAPTURE_REWARD = bc.rewards["Zone capture"] or 200
local ZONE_SUPPLY_UPGRADE_REWARD = bc.rewards["Zone upgrade"] or 100
local RED_ZONE_SUPPLY_AIRCRAFT_DIMENSIONS = {
  ["CH-47Fbl1"] = { width = 4, height = 6, length = 11, ropelength = 30 },
  ["Mi-8MTV2"] = { width = 6, height = 6, length = 15, ropelength = 30 },
  ["Mi-8MT"] = { width = 6, height = 6, length = 15, ropelength = 30 },
  ["UH-1H"] = { width = 4, height = 4, length = 9, ropelength = 25 },
  ["SA342L"] = { width = 4, height = 4, length = 12, ropelength = 25 },
  ["Mi-24P"] = { width = 4, height = 5, length = 11, ropelength = 25 },
  ["UH-60L"] = { width = 4, height = 5, length = 10, ropelength = 25 },
  ["UH-60L_DAP"] = { width = 4, height = 5, length = 10, ropelength = 25 },
  ["C-130J-30"] = { width = 4, height = 12, length = 35, ropelength = 0, detach = 14, attach = 10 },
}
local redZoneSupplyCrates = {}
local redZoneSupplyLandingOnce = { pending = nil, scheduled = false, delay = 5 }
Foothold_redCtld.ZoneSupplyOnboardByGroup = Foothold_redCtld.ZoneSupplyOnboardByGroup or {}

local function redCtldCargoName(cargoItem)
    if not cargoItem then return nil end
    if cargoItem.GetName then return cargoItem:GetName() end
    if cargoItem.StaticName then return cargoItem.StaticName end
    if cargoItem.GetCargoDisplayName then return cargoItem:GetCargoDisplayName() end
    return cargoItem.Name
end

local function redCtldAddCargoName(names, name)
    if type(name) == "string" and name ~= "" then
        names[#names + 1] = name
    end
end

local function redCtldGetCargoNames(cargoItem)
    local names = {}
    if not cargoItem then return names end

    if cargoItem.GetName then redCtldAddCargoName(names, cargoItem:GetName()) end
    redCtldAddCargoName(names, cargoItem.StaticName)
    if cargoItem.GetCargoDisplayName then redCtldAddCargoName(names, cargoItem:GetCargoDisplayName()) end
    redCtldAddCargoName(names, cargoItem.Name)
    if cargoItem.GetDisplayName then redCtldAddCargoName(names, cargoItem:GetDisplayName()) end
    redCtldAddCargoName(names, cargoItem.DisplayName)

    return names
end

local function redCtldExtractCargoItems(Cargo)
    local items = {}
    local function push(item)
        if item and (item.GetName or item.StaticName or item.GetCargoDisplayName) then
            items[#items + 1] = item
        end
    end
    if type(Cargo) ~= "table" then
        return items
    end
    if Cargo.GetName then
        push(Cargo)
        return items
    end
    for _, value in ipairs(Cargo) do
        push(value)
    end
    if #items == 0 then
        for _, value in pairs(Cargo) do
            push(value)
        end
    end
    return items
end

local function redCtldIsZoneSupplyCargo(cargoItem)
    local names = redCtldGetCargoNames(cargoItem)
    for _, name in ipairs(names) do
        if type(name) == "string" then
            if name == "Zone supplies" then return true end
            if RED_ZONE_SUPPLY_TYPES[name] == true then return true end
            for baseName in pairs(RED_ZONE_SUPPLY_TYPES) do
                if name:sub(1, #baseName + 1) == baseName .. "-" then
                    return true
                end
            end
        end
    end

    local name = redCtldCargoName(cargoItem)
    if type(name) ~= "string" then return false end
    if RED_ZONE_SUPPLY_TYPES[name] == true then return true end
    for baseName in pairs(RED_ZONE_SUPPLY_TYPES) do
        if name:sub(1, #baseName + 1) == baseName .. "-" then
            return true
        end
    end
    return false
end

local function redCtldStaticKey(staticObj)
    if not staticObj then return nil end
    if staticObj.GetID then return staticObj:GetID() end
    if staticObj.getID then return staticObj:getID() end
    if staticObj.GetName then return staticObj:GetName() end
    if staticObj.getName then return staticObj:getName() end
    return nil
end

local function redCtldStaticName(staticObj)
    if not staticObj then return nil end
    if staticObj.GetName then return staticObj:GetName() end
    if staticObj.getName then return staticObj:getName() end
    return nil
end

local function redCtldCargoStatic(cargoItem, entry)
    return (cargoItem and cargoItem.GetPositionable and cargoItem:GetPositionable())
        or (cargoItem and cargoItem.GetCoordinate and cargoItem)
        or (entry and entry.static)
        or nil
end

local function redCtldCargoKey(cargoItem)
    local key = (cargoItem.GetID and cargoItem:GetID()) or cargoItem.ID
    if key then return key end
    if cargoItem.StaticName then return cargoItem.StaticName end
    return redCtldStaticKey(redCtldCargoStatic(cargoItem))
end

local function redCtldCargoOnboard(cargoItem)
    if not cargoItem then return false end
    if cargoItem.IsLoaded and cargoItem:IsLoaded() then return true end
    if cargoItem.Isloaded and cargoItem:Isloaded() then return true end
    if cargoItem.IsAttached and cargoItem:IsAttached() then return true end
    if cargoItem.HasMoved and cargoItem:HasMoved() and cargoItem.WasDropped and not cargoItem:WasDropped() then return true end
    return false
end

local function redCtldTrackedSupplyOnboard(entry)
    if not entry or entry._wasUnloaded or entry.detached then return false end
    if redCtldCargoOnboard(entry.cargo) then return true end
    return entry.attached == true or entry.wasLoaded == true or entry.wasAirborne == true
end

local function redCtldStaticAlive(staticObj)
    if not staticObj then return false end
    if staticObj.IsAlive then return staticObj:IsAlive() end
    if staticObj.isExist then return staticObj:isExist() end
    return true
end

local function redCtldResolveGroup(entry)
    if entry and entry.cargo and entry.cargo.GetCarrierGroupName then
        local carrierName = entry.cargo:GetCarrierGroupName()
        if carrierName and carrierName ~= "" and carrierName ~= "None" and carrierName ~= "nil" then
            entry.groupName = carrierName
        end
    end
    if not (entry and entry.groupName) then return nil end
    local grp = GROUP:FindByName(entry.groupName)
    if grp and grp:IsAlive() then return grp end
    return nil
end

local function redCtldResolveGroupId(entry)
    if entry.groupId then return entry.groupId end
    local groupName = entry.groupName
    if entry.cargo and entry.cargo.GetCarrierGroupName then
        local carrierName = entry.cargo:GetCarrierGroupName()
        if carrierName and carrierName ~= "" and carrierName ~= "None" and carrierName ~= "nil" then
            groupName = carrierName
            entry.groupName = carrierName
        end
    end
    if not groupName then return nil end
    local dcsGroup = Group.getByName(groupName)
    if dcsGroup then
        entry.groupId = dcsGroup:getID()
    end
    return entry.groupId
end

local function redCtldResolvePlayer(entry)
    if entry.playerName and entry.playerName ~= "" and entry.playerName ~= "nil" then
        return entry.playerName
    end
    local grp = redCtldResolveGroup(entry)
    if not grp then return nil end
    local units = grp:GetUnits()
    if units and units[1] then
        local playerName = units[1]:GetPlayerName()
        if playerName and playerName ~= "" then
            entry.playerName = playerName
            return playerName
        end
    end
    return nil
end

local function redCtldSendToEntry(entry, text, duration)
    local grp = redCtldResolveGroup(entry)
    if grp then
        MESSAGE:New(text, duration or 15):ToGroup(grp)
    else
        trigger.action.outTextForCoalition(1, text, duration or 15)
    end
end

local function redCtldSendLocalized(entry, key, duration, ...)
    local grp = redCtldResolveGroup(entry)
    local text
    if grp then
        text = L10N:ForMooseGroup(grp):Format(key, ...)
    else
        text = L10N:Format(key, ...)
    end
    redCtldSendToEntry(entry, text, duration)
end

local function redCtldFormatForEntry(entry, key, ...)
    local grp = redCtldResolveGroup(entry)
    if grp then
        return L10N:ForMooseGroup(grp):Format(key, ...)
    end
    return L10N:Format(key, ...)
end

local function redCtldResolveCarrierUnit(entry, allowPlayerFallback)
    if not entry then return nil end
    local unitObj = entry._unitObj
    if unitObj and unitObj.isExist and unitObj:isExist() then
        return unitObj
    end
    if entry.unitName and Unit and Unit.getByName then
        unitObj = Unit.getByName(entry.unitName)
        if unitObj and unitObj.isExist and unitObj:isExist() then
            entry._unitObj = unitObj
            entry._unitDim = nil
            return unitObj
        end
    end
    if allowPlayerFallback ~= false and entry.playerName and entry.playerName ~= "" and entry.playerName ~= "nil" then
        local players = coalition.getPlayers(coalition.side.RED) or {}
        for _, playerUnit in ipairs(players) do
            if playerUnit and playerUnit.getPlayerName and playerUnit:getPlayerName() == entry.playerName then
                entry._unitObj = playerUnit
                entry.unitName = playerUnit.getName and playerUnit:getName() or entry.unitName
                entry._unitDim = nil
                return playerUnit
            end
        end
    end
    return nil
end

local function redCtldResolveCarrierDimensions(entry, unitObj)
    if entry and entry._unitDim then return entry._unitDim end
    if not (unitObj and unitObj.isExist and unitObj:isExist() and unitObj.getTypeName) then return nil end
    local dim = RED_ZONE_SUPPLY_AIRCRAFT_DIMENSIONS[unitObj:getTypeName()]
    if entry then
        entry._unitDim = dim
    end
    return dim
end

local function redCtldDestroyStatic(staticObj)
    local staticName = redCtldStaticName(staticObj)
    if staticName and StaticObject and StaticObject.getByName then
        local dcsStatic = StaticObject.getByName(staticName)
        if dcsStatic and dcsStatic.destroy then
            dcsStatic:destroy()
            return
        end
    end
    if staticObj and staticObj.Destroy and redCtldStaticAlive(staticObj) then
        staticObj:Destroy(false)
    end
end

local function redCtldRemoveTrackedSupply(key)
    local entry = redZoneSupplyCrates[key]
    local groupId = entry and redCtldResolveGroupId(entry) or nil
    redZoneSupplyCrates[key] = nil
    if groupId then
        Foothold_redCtld:RefreshZoneSupplyOnboardForGroup(groupId)
    end
end

function Foothold_redCtld:RefreshZoneSupplyOnboardForGroup(groupId)
    if not groupId then return false end
    self.ZoneSupplyOnboardByGroup = self.ZoneSupplyOnboardByGroup or {}

    local hasOnboard = false
    for _, entry in pairs(redZoneSupplyCrates) do
        if redCtldResolveGroupId(entry) == groupId and redCtldTrackedSupplyOnboard(entry) then
            hasOnboard = true
            break
        end
    end

    if hasOnboard then
        self.ZoneSupplyOnboardByGroup[groupId] = true
    else
        self.ZoneSupplyOnboardByGroup[groupId] = nil
    end

    return hasOnboard
end

function Foothold_redCtld:ClearZoneSupplyOnboardForGroup(groupId)
    self.ZoneSupplyOnboardByGroup = self.ZoneSupplyOnboardByGroup or {}
    if groupId then
        self.ZoneSupplyOnboardByGroup[groupId] = nil
    end
end

function Foothold_redCtld:BuildZoneSupplyCarrierTypeCache()
    self.ZoneSupplyCarrierTypes = {}
    self.ZoneSupplyCarrierTypesAll = false

    for _, cargoObj in pairs(self.Cargo_Statics or {}) do
        local cargoName = cargoObj and cargoObj.GetName and cargoObj:GetName() or nil
        if cargoObj and cargoObj.Subcategory == "Zone supplies" and RED_ZONE_SUPPLY_TYPES[cargoName] then
            if cargoObj.TypeNames then
                for unitType in pairs(cargoObj.TypeNames) do
                    self.ZoneSupplyCarrierTypes[unitType] = true
                end
            else
                self.ZoneSupplyCarrierTypesAll = true
            end
        end
    end

    self.ZoneSupplyCarrierTypesReady = true
    return self.ZoneSupplyCarrierTypes
end

function Foothold_redCtld:CanUnitTypeCarryZoneSupplies(unitType)
    if type(unitType) ~= "string" then return false end
    if not self.ZoneSupplyCarrierTypesReady then
        self:BuildZoneSupplyCarrierTypeCache()
    end
    return self.ZoneSupplyCarrierTypesAll == true
        or (self.ZoneSupplyCarrierTypes and self.ZoneSupplyCarrierTypes[unitType] == true)
end

function Foothold_redCtld:HasLoadedZoneSupplyCargo(unitName)
    if type(unitName) ~= "string" then return false end
    local loaded = self.Loaded_Cargo and self.Loaded_Cargo[unitName] or nil
    if not (loaded and loaded.Cargo) then return false end
    for _, cargoItem in ipairs(loaded.Cargo) do
        if redCtldIsZoneSupplyCargo(cargoItem) then
            return true
        end
    end
    return false
end

function Foothold_redCtld:HasZoneSupplyCargoOnboard(groupId, unitName)
    if groupId then
        self.ZoneSupplyOnboardByGroup = self.ZoneSupplyOnboardByGroup or {}
        if self.ZoneSupplyOnboardByGroup[groupId] then return true end
        if self:RefreshZoneSupplyOnboardForGroup(groupId) then return true end
    end
    return self:HasLoadedZoneSupplyCargo(unitName)
end

local function redCtldResolveZoneNameFromVec3(vec3)
    if not vec3 then return nil end
    local zoneContainer = bc:getZoneOfPoint(vec3)
    return zoneContainer and zoneContainer.zone or nil
end

local function redCtldResolveZoneNameFromMooseObject(obj)
    local coord = obj and obj.GetCoordinate and obj:GetCoordinate() or nil
    local vec3 = coord and coord.GetVec3 and coord:GetVec3() or nil
    return redCtldResolveZoneNameFromVec3(vec3)
end

local function redCtldTrackMoved(entry, vec3)
    if not entry._lastVec3 then
        entry._lastVec3 = { x = vec3.x, y = vec3.y, z = vec3.z }
        return false
    end
    local dx = vec3.x - entry._lastVec3.x
    local dy = vec3.y - entry._lastVec3.y
    local dz = vec3.z - entry._lastVec3.z
    entry._lastVec3 = { x = vec3.x, y = vec3.y, z = vec3.z }
    return (dx * dx + dy * dy + dz * dz) > RED_ZONE_SUPPLY_MOVE_EPS2
end

local function redCtldResolveCarrierOffset(entry, vec3)
    local unitObj = redCtldResolveCarrierUnit(entry, false)
    local dim = redCtldResolveCarrierDimensions(entry, unitObj)
    if not (unitObj and unitObj.isExist and unitObj:isExist() and dim and vec3) then
        return nil
    end

    local unitPoint = unitObj:getPoint()
    if not (unitPoint and unitPoint.x and unitPoint.y and unitPoint.z) then
        return nil
    end

    local dx = unitPoint.x - vec3.x
    local dy = unitPoint.y - vec3.y
    local dz = unitPoint.z - vec3.z
    local delta2D = math.sqrt((dx * dx) + (dz * dz))
    local delta3D = math.sqrt((dx * dx) + (dy * dy) + (dz * dz))

    return unitObj, dim, dx, dy, dz, delta2D, delta3D, unitObj:inAir()
end

local function redCtldCargoInsideCarrier(entry, vec3)
    local _, dim, dx, dy, dz, delta2D, delta3D, inAir = redCtldResolveCarrierOffset(entry, vec3)
    if not dim then return false end

    if not inAir then
        if dim.ropelength == 0 then
            return delta2D <= (dim.attach or dim.width)
        end
        return delta2D <= dim.width and math.abs(dy) <= dim.height
    end

    if dim.ropelength == 0 then
        return delta3D <= (dim.attach or dim.width)
    end

    return math.abs(dx) <= dim.width
        and math.abs(dy) <= dim.ropelength
        and math.abs(dz) <= dim.width
end

local function redCtldMarkSupplyLoaded(key, entry, staticObj)
    if not entry then return end

    entry.wasLoaded = true
    entry.wasAirborne = true
    entry._wasUnloaded = false
    entry.attached = true
    entry.detached = false
    entry.noZoneAt = nil
    entry.noNeedAt = nil

    if not entry._gcLoadedMsg then
        local staticName = redCtldStaticName(staticObj) or entry.cargoName or tostring(key)
        redCtldSendLocalized(entry, "CTLD_CRATE_LOADED_GROUND_CREW", 10, tostring(staticName))
        entry._gcLoadedMsg = true
    end

    Foothold_redCtld:RefreshZoneSupplyOnboardForGroup(redCtldResolveGroupId(entry))
end

local function redCtldRewardPlayer(entry, statLabel, reward)
    local playerName = redCtldResolvePlayer(entry)
    if playerName and bc.playerContributions[1][playerName] ~= nil then
        bc:addContribution(playerName, 1, reward)
        bc:addTempStat(playerName, statLabel, 1)
    end
end

local function redCtldSimulateLandingForEntryIfOnGround(entry, zoneName)
    if not (entry and zoneName) then return end
    if redZoneSupplyLandingOnce.pending or redZoneSupplyLandingOnce.scheduled then return end

    local unitObj = redCtldResolveCarrierUnit(entry, true)
    if not (unitObj and unitObj.isExist and unitObj:isExist()) then return end
    if Utils and Utils.isInAir and Utils.isInAir(unitObj) then return end
    if Utils and Utils.isInZone and not Utils.isInZone(unitObj, zoneName) then return end

    redZoneSupplyLandingOnce.pending = {
        unit = unitObj,
        playerName = entry.playerName,
    }
    redZoneSupplyLandingOnce.scheduled = true

    SCHEDULER:New(nil, function()
        local pending = redZoneSupplyLandingOnce.pending
        redZoneSupplyLandingOnce.pending = nil
        redZoneSupplyLandingOnce.scheduled = false
        if not pending then return end

        local unitCap = pending.unit
        if not (unitCap and unitCap.isExist and unitCap:isExist()) then return end
        if Utils and Utils.isInAir and Utils.isInAir(unitCap) then return end

        world.onEvent({
            id = world.event.S_EVENT_LAND,
            time = timer.getAbsTime(),
            initiator = unitCap,
            initiatorPilotName = pending.playerName,
            initiator_unit_type = unitCap:getTypeName(),
            initiator_coalition = coalition.side.RED,
            skipRewardMsg = true,
        })
    end, {}, redZoneSupplyLandingOnce.delay, 0)
end

local function redCtldFinalizeDelivery(key, entry, zoneObj, actionKey, statLabel, reward)
    local actionText = redCtldFormatForEntry(entry, actionKey)
    local text = redCtldFormatForEntry(entry, "CTLD_ZONE_SUPPLIES_DELIVERED", actionText, zoneObj.zone)
    redCtldSendToEntry(entry, text, 15)
    redCtldRewardPlayer(entry, statLabel, reward)
    redCtldSimulateLandingForEntryIfOnGround(entry, zoneObj.zone)
    redCtldDestroyStatic(redCtldCargoStatic(entry.cargo, entry))
    redCtldRemoveTrackedSupply(key)
    addCTLDZonesForRedControlled(zoneObj.zone)
end

local function redCtldDestroySupplyInZone(key, entry, zoneObj, reason)
    local text = redCtldFormatForEntry(entry, "CTLD_ZONE_SUPPLIES_DESTROYED", zoneObj.zone, reason)
    redCtldSendToEntry(entry, text, 15)
    redCtldDestroyStatic(redCtldCargoStatic(entry.cargo, entry))
    redCtldRemoveTrackedSupply(key)
end

local function redCtldRegisterSupplyCargo(cargoItem, pickupZone, groupName, groupId, playerName, unitName, carrierUnitObject, flags)
    if not redCtldIsZoneSupplyCargo(cargoItem) then return nil, nil end
    local key = redCtldCargoKey(cargoItem)
    if not key then return nil, nil end

    local staticObj = redCtldCargoStatic(cargoItem)
    local initialVec3 = nil
    if staticObj then
        local coord = staticObj:GetCoordinate()
        initialVec3 = coord and coord:GetVec3() or nil
    end

    local entry = redZoneSupplyCrates[key]
    if not entry then
        entry = {
            cargo = cargoItem,
            static = staticObj,
            pickupZone = pickupZone,
            groupName = groupName,
            groupId = groupId,
            playerName = playerName,
            unitName = unitName,
            cargoName = redCtldCargoName(cargoItem),
            createdAt = timer.getTime(),
            wasLoaded = false,
            wasAirborne = false,
            _wasUnloaded = false,
            attached = false,
            detached = false,
            warnedNoNeed = false,
            warnedSameZone = false,
            _lastVec3 = initialVec3 and { x = initialVec3.x, y = initialVec3.y, z = initialVec3.z } or nil,
        }
        redZoneSupplyCrates[key] = entry
    else
        entry.cargo = cargoItem
        entry.static = staticObj or entry.static
        entry.pickupZone = pickupZone or entry.pickupZone
        entry.groupName = groupName or entry.groupName
        entry.groupId = groupId or entry.groupId
        entry.playerName = playerName or entry.playerName
        entry.unitName = unitName or entry.unitName
        entry.cargoName = redCtldCargoName(cargoItem) or entry.cargoName
    end

    if carrierUnitObject and carrierUnitObject.isExist and carrierUnitObject:isExist() then
        entry._unitObj = carrierUnitObject
        entry._unitDim = RED_ZONE_SUPPLY_AIRCRAFT_DIMENSIONS[carrierUnitObject:getTypeName()]
    end

    flags = flags or {}
    if flags.wasLoaded then
        entry.wasLoaded = true
        entry.wasAirborne = true
        entry._wasUnloaded = false
        entry.attached = true
        entry.detached = false
    end
    if flags.wasUnloaded then
        entry.wasLoaded = true
        entry.wasAirborne = true
        entry._wasUnloaded = true
        entry.attached = true
        entry.detached = true
    end

    if groupId then
        Foothold_redCtld:RefreshZoneSupplyOnboardForGroup(groupId)
    end

    return key, entry
end

local function redCtldFindTrackedSupplyForDrop(groupId, groupName, cargoName)
    for key, entry in pairs(redZoneSupplyCrates) do
        local sameGroup = (groupId and redCtldResolveGroupId(entry) == groupId)
            or (groupName and entry.groupName == groupName)
        local sameCargo = (not cargoName) or entry.cargoName == cargoName
        if sameGroup and sameCargo and (entry.wasLoaded or entry.wasAirborne or redCtldCargoOnboard(entry.cargo)) then
            return key, entry
        end
    end
    return nil, nil
end

function Foothold_redCtld:OnAfterGetCrates(From, Event, To, GroupObj, Unit, Cargo)
    local cargoItems = redCtldExtractCargoItems(Cargo)
    if #cargoItems == 0 then return end

    local pickupZone = redCtldResolveZoneNameFromMooseObject(Unit)
    local groupName = GroupObj and GroupObj.GetName and GroupObj:GetName() or nil
    local groupId = GroupObj and GroupObj.GetID and GroupObj:GetID() or nil
    local playerName = Unit and Unit.GetPlayerName and Unit:GetPlayerName() or nil
    local unitName = Unit and Unit.GetName and Unit:GetName() or nil
    local carrierUnitObject = Unit and Unit.GetDCSObject and Unit:GetDCSObject() or nil

    for _, cargoItem in ipairs(cargoItems) do
        local key, entry = redCtldRegisterSupplyCargo(cargoItem, pickupZone, groupName, groupId, playerName, unitName, carrierUnitObject)
        if entry then
            local staticObj = redCtldCargoStatic(cargoItem, entry)
            local coord = staticObj and staticObj:GetCoordinate() or nil
            local vec3 = coord and coord:GetVec3() or nil
            if vec3 and redCtldCargoInsideCarrier(entry, vec3) then
                redCtldMarkSupplyLoaded(key, entry, staticObj)
            end
        end
    end
end

function Foothold_redCtld:OnAfterCratesPickedUp(From, Event, To, GroupObj, Unit, Cargo)
    local cargoItems = redCtldExtractCargoItems(Cargo)
    if #cargoItems == 0 then return end

    local pickupZone = redCtldResolveZoneNameFromMooseObject(Unit)
    local groupName = GroupObj and GroupObj.GetName and GroupObj:GetName() or nil
    local groupId = GroupObj and GroupObj.GetID and GroupObj:GetID() or nil
    local playerName = Unit and Unit.GetPlayerName and Unit:GetPlayerName() or nil
    local unitName = Unit and Unit.GetName and Unit:GetName() or nil
    local carrierUnitObject = Unit and Unit.GetDCSObject and Unit:GetDCSObject() or nil

    for _, cargoItem in ipairs(cargoItems) do
        local key, entry = redCtldRegisterSupplyCargo(cargoItem, pickupZone, groupName, groupId, playerName, unitName, carrierUnitObject, { wasLoaded = true })
        if entry and not entry._gcLoadedMsg then
            redCtldSendLocalized(entry, "CTLD_CRATE_LOADED_GROUND_CREW", 10, tostring(entry.cargoName or key))
            entry._gcLoadedMsg = true
        end
    end
end

function Foothold_redCtld:OnAfterCratesDropped(From, Event, To, GroupObj, Unit, Cargo)
    local cargoItems = redCtldExtractCargoItems(Cargo)
    if #cargoItems == 0 then return end

    local fallbackZone = redCtldResolveZoneNameFromMooseObject(Unit)
    local groupName = GroupObj and GroupObj.GetName and GroupObj:GetName() or nil
    local groupId = GroupObj and GroupObj.GetID and GroupObj:GetID() or nil
    local playerName = Unit and Unit.GetPlayerName and Unit:GetPlayerName() or nil
    local unitName = Unit and Unit.GetName and Unit:GetName() or nil
    local carrierUnitObject = Unit and Unit.GetDCSObject and Unit:GetDCSObject() or nil

    for _, cargoItem in ipairs(cargoItems) do
        if redCtldIsZoneSupplyCargo(cargoItem) then
            local cargoName = redCtldCargoName(cargoItem)
            local oldKey, oldEntry = redCtldFindTrackedSupplyForDrop(groupId, groupName, cargoName)
            local pickupZone = oldEntry and oldEntry.pickupZone or fallbackZone
            if oldKey then
                redZoneSupplyCrates[oldKey] = nil
            end
            local _, entry = redCtldRegisterSupplyCargo(cargoItem, pickupZone, groupName, groupId, playerName, unitName, carrierUnitObject, { wasUnloaded = true })
            if entry and not entry._gcUnloadedMsg then
                redCtldSendLocalized(entry, "CTLD_CRATE_UNLOADED_GROUND_CREW", 10, tostring(cargoName))
                entry._gcUnloadedMsg = true
            end
        end
    end
end

local function redCtldProcessZoneSupply(key, entry, now)
    local cargo = entry.cargo
    if redCtldCargoOnboard(cargo) then
        redCtldMarkSupplyLoaded(key, entry, redCtldCargoStatic(cargo, entry))
        return
    end

    local staticObj = redCtldCargoStatic(cargo, entry)
    if not redCtldStaticAlive(staticObj) then
        redCtldRemoveTrackedSupply(key)
        return
    end

    entry.static = staticObj
    local coord = staticObj:GetCoordinate()
    local vec3 = coord and coord:GetVec3() or nil
    if not vec3 then return end

    local moved = redCtldTrackMoved(entry, vec3)
    local ground = land.getHeight({ x = vec3.x, y = vec3.z })
    local agl = vec3.y - ground

    if redCtldCargoInsideCarrier(entry, vec3) then
        redCtldMarkSupplyLoaded(key, entry, staticObj)
    end
    if moved then
        entry.noNeedAt = nil
    end

    if moved then
        if not entry.wasAirborne and not entry._gcLoadedMsg then
            local staticName = redCtldStaticName(staticObj) or entry.cargoName or tostring(key)
            redCtldSendLocalized(entry, "CTLD_CRATE_LOADED_GROUND_CREW", 10, tostring(staticName))
            entry._gcLoadedMsg = true
        end
        entry.wasLoaded = true
        entry.wasAirborne = true
        entry._wasUnloaded = false
    elseif entry.wasAirborne and not entry._wasUnloaded then
        local unitObj = redCtldResolveCarrierUnit(entry, false)
        local dim = redCtldResolveCarrierDimensions(entry, unitObj)
        local unloaded = false
        local inAir = nil
        if unitObj and unitObj.isExist and unitObj:isExist() and dim then
            local unitPoint = unitObj:getPoint()
            if unitPoint and unitPoint.x and unitPoint.y and unitPoint.z then
                local dx = unitPoint.x - vec3.x
                local dy = unitPoint.y - vec3.y
                local dz = unitPoint.z - vec3.z
                local delta2D = math.sqrt((dx * dx) + (dz * dz))
                local delta3D = math.sqrt((dx * dx) + (dy * dy) + (dz * dz))
                inAir = unitObj:inAir()
                if not inAir then
                    if dim.ropelength == 0 then
                        unloaded = delta2D > (dim.detach or dim.width)
                    else
                        unloaded = delta2D > dim.width or math.abs(dy) > dim.height
                    end
                else
                    if dim.ropelength == 0 then
                        unloaded = delta3D > (dim.detach or dim.width)
                    end
                    if not unloaded and dim.ropelength and dim.ropelength > 0 then
                        unloaded = math.abs(dx) > dim.width or math.abs(dy) > dim.ropelength or math.abs(dz) > dim.width
                    end
                end
            end
        elseif agl <= RED_ZONE_SUPPLY_AGL_THRESHOLD then
            unloaded = true
        end
        if unloaded then
            entry._wasUnloaded = true
            entry.detached = true
            if not entry._gcUnloadedMsg and dim and dim.ropelength and dim.ropelength > 0 and not inAir then
                local staticName = redCtldStaticName(staticObj) or entry.cargoName or tostring(key)
                redCtldSendLocalized(entry, "CTLD_CRATE_UNLOADED_GROUND_CREW", 10, tostring(staticName))
                entry._gcUnloadedMsg = true
            end
        end
    end
    if not entry.wasAirborne then return end

    local onGround = (agl <= RED_ZONE_SUPPLY_AGL_THRESHOLD) or (entry._wasUnloaded and not moved)
    if entry.attached and not entry.detached and not entry._wasUnloaded then onGround = false end
    if not onGround then return end

    local zoneName = redCtldResolveZoneNameFromVec3(vec3)
    if not zoneName then
        entry.noZoneAt = entry.noZoneAt or now
        if (now - entry.noZoneAt) > RED_ZONE_SUPPLY_NOZONE_TTL then
            redCtldRemoveTrackedSupply(key)
        end
        return
    end
    entry.noZoneAt = nil

    if entry.pickupZone and zoneName == entry.pickupZone then
        return
    end

    local zoneObj = bc:getZoneByName(zoneName)
    if not zoneObj or not zoneObj.active then return end

    if zoneObj.side == 2 then
        redCtldDestroySupplyInZone(key, entry, zoneObj, "enemy zone")
        return
    end

    if zoneObj.side == 0 then
        zoneObj:capture(1)
        redCtldFinalizeDelivery(key, entry, zoneObj, "CTLD_ZONE_SUPPLY_ACTION_CAPTURED", "Zone capture", ZONE_SUPPLY_CAPTURE_REWARD)
        return
    end

    if zoneObj.side == 1 and zoneObj:canRecieveSupply() then
        zoneObj:upgrade()
        redCtldFinalizeDelivery(key, entry, zoneObj, "CTLD_ZONE_SUPPLY_ACTION_UPGRADED", "Zone upgrade", ZONE_SUPPLY_UPGRADE_REWARD)
    elseif zoneObj.side == 1 then
        if not entry.warnedNoNeed then
            redCtldSendToEntry(entry, string.format("[Red CTLD] %s does not currently need zone supplies.", zoneObj.zone), 15)
            entry.warnedNoNeed = true
        end
        entry.noNeedAt = entry.noNeedAt or now
        if (now - entry.noNeedAt) > RED_ZONE_SUPPLY_NONEED_TTL then
            redCtldDestroyStatic(staticObj)
            redCtldRemoveTrackedSupply(key)
        end
    end
end

local function tickRedZoneSupply()
    if not next(redZoneSupplyCrates) then return end
    local now = timer.getTime()
    for key, entry in pairs(redZoneSupplyCrates) do
        redCtldProcessZoneSupply(key, entry, now)
    end
end

TIMER:New(tickRedZoneSupply):Start(15, 5)

local function redCtldZoneEligible(zoneName)
    local lowerName = tostring(zoneName or ""):lower()
    return lowerName ~= ""
        and not lowerName:find("hidden")
        and not lowerName:find("dropzone")
        and not lowerName:find("carrier")
        and not lowerName:find("fob alpha")
end

for _, zoneObj in ipairs(bc:getZones()) do
    local zoneName = zoneObj.zone
    if redCtldZoneEligible(zoneName) then
        Foothold_redCtld:AddCTLDZone(zoneName, CTLD.CargoZoneType.LOAD, SMOKECOLOR.Red, false, false)
        Foothold_redCtld:AddCTLDZone(zoneName, CTLD.CargoZoneType.MOVE, SMOKECOLOR.Red, true, false)
    end
end

function addCTLDZonesForRedControlled(zoneName)
    local function applyZone(zName)
        local zoneObj = bc:getZoneByName(zName)
        if not zoneObj or not redCtldZoneEligible(zName) then return end

        if not zoneObj.active then
            Foothold_redCtld:DeactivateZone(zName, CTLD.CargoZoneType.LOAD)
            Foothold_redCtld:DeactivateZone(zName, CTLD.CargoZoneType.MOVE)
        elseif zoneObj.side == 1 then
            Foothold_redCtld:ActivateZone(zName, CTLD.CargoZoneType.LOAD)
            Foothold_redCtld:DeactivateZone(zName, CTLD.CargoZoneType.MOVE)
        else
            Foothold_redCtld:DeactivateZone(zName, CTLD.CargoZoneType.LOAD)
            Foothold_redCtld:ActivateZone(zName, CTLD.CargoZoneType.MOVE)
        end
    end

    if zoneName then
        applyZone(zoneName)
    else
        for _, zoneObj in ipairs(bc:getZones()) do
            applyZone(zoneObj.zone)
        end
    end
end

addCTLDZonesForRedControlled()
SCHEDULER:New(nil, function()
    addCTLDZonesForRedControlled()
end, {}, 5)

if lfs then
    ---------------------------------------------------------------------------
    -- Red CTLD: Persistence Setup
    ---------------------------------------------------------------------------

    local _redCtldBaseName = (FootholdSaveBaseName and tostring(FootholdSaveBaseName) ~= "") and tostring(FootholdSaveBaseName) or nil

    Foothold_redCtld.enableLoadSave = true
    Foothold_redCtld.saveinterval = 300
    Foothold_redCtld.filename = _redCtldBaseName .. "_CTLD_Red_Save.csv"
    Foothold_redCtld.filepath = FootholdSavePath or (lfs.writedir() .. "Missions\\Saves")
    Foothold_redCtld.eventoninject = true
    Foothold_redCtld.useprecisecoordloads = true
else
    MESSAGE:New(L10N:Get("CTLD_SAVE_LOAD_DISABLED_DESANITIZE"), 300):ToAll()
end

---------------------------------------------------------------------------
-- Red CTLD: Persistence Load Hook
---------------------------------------------------------------------------

Foothold_redCtld:__Load(10)

function Foothold_redCtld:OnAfterLoaded(From, Event, To, LoadedGroups)
    self:I("***** Red CTLD Groups Loaded! *****")

    local MaxAtSpawn = {}
    for rawName, limit in pairs(RED_MAX_AT_SPAWN) do
        local key = tostring(rawName)
        if key ~= "" then
            if MaxAtSpawn[key] then
                if limit > MaxAtSpawn[key] then
                    MaxAtSpawn[key] = limit
                end
            else
                MaxAtSpawn[key] = limit
            end
        end
    end

    for _, loadedGroup in ipairs(LoadedGroups) do
        local groupName = loadedGroup.Group:GetName() or "unknown"
        local timestamp = loadedGroup.TimeStamp or timer.getTime()
        local cargoName = tostring(loadedGroup.CargoName)
        local groupCoord = loadedGroup.Group:GetCoordinate()
        local groupPoint = groupCoord and groupCoord:GetVec3() or nil
        local skipRestore, nearestEnemyName, nearestEnemyNm = redRestorePointTooFarFromBlue(groupPoint, 120)
        local crateCargo = self:_FindCratesCargoObject(cargoName)

        if skipRestore then
            self:I(string.format("[RED RESTORE] skip loaded group=%s cargo=%s nearestEnemy=%s dist=%.1fNm limit=120.0Nm", groupName, cargoName, tostring(nearestEnemyName), nearestEnemyNm or -1))
            if crateCargo then
                self:AddStockCrates(cargoName, 1)
            end
            if loadedGroup.Group:IsAlive() then
                loadedGroup.Group:Destroy()
            end
        elseif crateCargo then
            table.insert(RedGroundUnits, {
                groupName = groupName,
                Timestamp = timestamp,
                Group = loadedGroup.Group,
                CargoName = cargoName,
                Stock = crateCargo:GetStock() or 0
            })
        end
    end

    redEnforceMaxAtSpawnForTrackedUnits(RedGroundUnits, MaxAtSpawn, function(CargoName)
        Foothold_redCtld:AddStockCrates(CargoName, 1)
    end)

    -- below a code that deletes the cargo that is left on the ground from last session.
    if self.Spawned_Cargo then
        for i = #self.Spawned_Cargo, 1, -1 do
            local c = self.Spawned_Cargo[i]
            local s = c:GetPositionable()
            if s and s:IsAlive() then s:Destroy(false) end
            table.remove(self.Spawned_Cargo, i)
        end
    end
    -- end of that.
end

end
BASE:I("Red CTLD script initialized")
