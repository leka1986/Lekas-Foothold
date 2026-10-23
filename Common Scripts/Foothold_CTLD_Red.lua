---------------------------------------------------------------------------
-- ## Red CTLD ##
---------------------------------------------------------------------------

if Allow_Red_CTLD == true or GlobalSettings.pvpEnabled == true then
local pvpEnabled = GlobalSettings.pvpEnabled == true
    
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

Foothold_redCtld = CTLD:New(coalition.side.RED, pvpEnabled
    and {"Mi.8MT", "Hercules", "Ми.8МТВ2", "Ми.24П", "Mi.24P", "C.130J.30"}
    or {--[[ "CH.47", "C.130J.30",]] "Mi.8MT", "Hercules", "Ми.8МТВ2", "Ми.24П", "Mi.24P"}, "Red Logistics")
if pvpEnabled then
    local injectTroops = Foothold_redCtld.InjectTroops
    function Foothold_redCtld:InjectTroops(Zone, Cargo, ...)
        local cargoName = Cargo:GetName()
        if cargoName == "Zone Spy" or cargoName == "Demolition Team" then return end
        return injectTroops(self, Zone, Cargo, ...)
    end
end
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
Foothold_redCtld.nobuildinloadzones = not pvpEnabled
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

if pvpEnabled then
    local defaults = {
        ["Squad 4 AK47"] = { price = 25, reqRank = 1 },
        ["Squad 8 AK47"] = { price = 50, reqRank = 1 },
        ["Scout BRDM 2"] = { price = 100, reqRank = 1 },
        ["Ammo Truck"] = { price = 100, reqRank = 1 },
        ["Arty SPH 253 Akatsia 8 NM"] = { price = 150, reqRank = 1 },
        ["Arty SPM 259 Nona 3 NM"] = { price = 150, reqRank = 1 },
        ["MLRS LC 80 MM 2.2 NM"] = { price = 150, reqRank = 1 },
        ["ATGM AT-3 SAGGER"] = { price = 250, reqRank = 2 },
        ["Kord 12.7 MM"] = { price = 100, reqRank = 1 },
        ["MRAP M-ATV"] = { price = 100, reqRank = 1 },
        ["Truck with ZU-23"] = { price = 300, reqRank = 2 },
        ["SA-8"] = { price = 300, reqRank = 2 },
        ["SA-3 SAM system"] = { price = 750, reqRank = 3 },
        ["Pantsir S1"] = CTLDPrices["Pantsir S1"],
        ["Tor M2"] = { price = 500, reqRank = 2 },
        ["FARP"] = CTLDPrices["FARP"],
        ["FARP with ZELL"] = CTLDPrices["FARP with ZELL"],
    }
    for name, value in pairs(defaults) do
        if CTLDPrices[name] == nil then CTLDPrices[name] = value end
    end
    RedCTLDPrices = CTLDPrices
end

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

local function readRedCtldPolicy(name)
    local v = CTLDPrices and CTLDPrices[name]
    if v == nil then v = RedCTLDPrices and RedCTLDPrices[name] end
    if type(v) == "table" then
        return v.available ~= false, v.price or v.cost or RED_CTLD_DEFAULT_PRICE, v.reqRank or 0
    end
    return true, v or RED_CTLD_DEFAULT_PRICE, 0
end

local function redCtldPriceOf(name)
    local _, price = readRedCtldPolicy(name)
    return price
end

local function redCtldReqRankOf(name)
    local _, _, reqRank = readRedCtldPolicy(name)
    return reqRank
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

Foothold_redCtld.ZoneSupplyPickupDebits = Foothold_redCtld.ZoneSupplyPickupDebits or {}

local function redCtldZoneSupplyPickupDebitKey(Group, Unit)
    if Unit and Unit.GetName then return Unit:GetName() end
    if Group and Group.GetName then return Group:GetName() end
    return nil
end

local function redCtldQueueZoneSupplyPickupDebit(Group, Unit, cargoName, sourceZoneName, quantity, kind, sourceSide, items, knownRequest, sourceNativeId)
    local key = redCtldZoneSupplyPickupDebitKey(Group, Unit)
    if not key then return end
    local queue = Foothold_redCtld.ZoneSupplyPickupDebits[key]
    if not queue then
        queue = {}
        Foothold_redCtld.ZoneSupplyPickupDebits[key] = queue
    end
    local debit = knownRequest or {
        cargoName = cargoName,
        sourceZone = sourceZoneName,
        remaining = quantity,
    }
    if kind == "warehouse" then
        debit.cargoName = cargoName
        debit.sourceZone = sourceZoneName
        debit.remaining = quantity
        debit.kind = kind
        debit.sourceSide = sourceSide
        debit.items = items
        debit.sourceNativeId = sourceNativeId
        debit._warehousePickupKey = key
    end
    if pvpEnabled then
      debit._pickupUnit, debit._pickupRecord, debit._pickupNative = nil, nil, nil
      debit._pickupZone, debit._pickupRequestNumber = nil, nil
      if kind == "farp" then
        debit.kind, debit.sourceSide, debit.sourceNativeId = kind, sourceSide, sourceNativeId
      end
    end
    queue[#queue + 1] = debit
end

local function redCtldClaimZoneSupplyPickupDebit(unitName, groupName, cargoName, knownRequest)
    local key = unitName or groupName
    local queue = key and Foothold_redCtld.ZoneSupplyPickupDebits[key] or nil
    if not queue then return nil end

    for index, debit in ipairs(queue) do
        if debit.cargoName == cargoName and (debit.remaining or 0) > 0 and (knownRequest == nil or debit == knownRequest) then
            debit.remaining = debit.remaining - 1
            local sourceZone = debit.sourceZone
            if debit.remaining <= 0 then table.remove(queue, index) end
            if #queue == 0 then Foothold_redCtld.ZoneSupplyPickupDebits[key] = nil end
            if debit.kind == "warehouse" then return sourceZone, debit end
            if pvpEnabled then return sourceZone, debit end
            return sourceZone
        end
    end
    return nil
end

local redCtldRefundPlayerZoneSupplyStock

function Foothold_redCtld:CanGetUnits(Group, Unit, Config, quantity, quiet)
    local name = Config and Config.Name or "none"
    local available, price, reqRank = readRedCtldPolicy(name)
    if not available then return false end
    if CTLDCost ~= true then return true end
    local n = math.max(1, tonumber(quantity) or 1)
    local charge = price * n
    return redCtldDebit(Group, charge, name, reqRank)
end

function Foothold_redCtld:CanGetTroops(Group, Unit, Cargo, quantity, Inject)
    if Inject then return true end
    local name = Cargo and Cargo.GetName and Cargo:GetName() or nil
    if type(name) ~= "string" then return true end
    local available, price, reqRank = readRedCtldPolicy(name)
    if not available then return false end
    if self.suppressmessages and tonumber(quantity) == 1 then return true end
    if CTLDCost ~= true then return true end
    local n = math.max(1, tonumber(quantity) or 1)
    local charge = price * n
    local reason = (n > 1) and string.format("%dx %s", n, name) or name
    return redCtldDebit(Group, charge, reason, reqRank)
end

function Foothold_redCtld:CanGetCrates(Group, Unit, Cargo, number, drop, pack, quiet, suppressGetEvent)
    if drop or pack then return true end
    local pickupZone
    if pvpEnabled and Cargo and Cargo.GetName and Cargo.Subcategory ~= "Warehouse" then
        local request = Foothold_ctld._warehousePickupRequest
        if request and (request._warehouseOwner ~= self or request._warehouseOriginalCargo ~= Cargo
            or request._pickupUnit ~= Unit or request._pickupRequestNumber ~= number) then request = nil end
        local record
        if request then pickupZone, record = request._pickupZone, request._pickupRecord
        else
            local inLoad, name = self:IsUnitInZone(Unit, CTLD.CargoZoneType.LOAD)
            pickupZone = inLoad and name or false
            record = inLoad and bc.dynamicFarpsByName and bc.dynamicFarpsByName[name] or nil
        end
        if record then
            local cargoName = Cargo:GetName()
            local accepted, sourceZoneName, physicalCount, sourceSide, sourceNativeId = Foothold_ctld.CanGetCrates(self, Group, Unit, Cargo, number,
                drop, pack, quiet, suppressGetEvent, cargoName, false,
                request == nil and pickupZone or nil, request == nil and record or nil)
            if accepted and sourceZoneName then
                redCtldQueueZoneSupplyPickupDebit(Group, Unit, cargoName, sourceZoneName, physicalCount, "farp", sourceSide, nil, nil, sourceNativeId)
            end
            return accepted
        end
    end
    if pvpEnabled and Cargo and Cargo.Subcategory == "Warehouse" then
        local request = Foothold_ctld._warehousePickupRequest
        if request and (request._warehouseOwner ~= self or request._warehouseOriginalCargo ~= Cargo) then request = nil end
        local cargoName = request and request.cargoName or Cargo:GetName()
        local meta = request and request._warehouseMeta or Foothold_ctld.WarehouseSupplyTypes[cargoName]
        if meta then
            local accepted, sourceZoneName, physicalCount, items, sourceNativeId = Foothold_ctld.CanGetCrates(self, Group, Unit, Cargo, number,
                drop, pack, quiet, suppressGetEvent, cargoName, meta)
            if accepted and sourceZoneName then
                if sourceNativeId ~= nil then
                redCtldQueueZoneSupplyPickupDebit(Group, Unit, cargoName, sourceZoneName, physicalCount,
                    "warehouse", self.coalition, items, request, sourceNativeId)
                else
                redCtldQueueZoneSupplyPickupDebit(Group, Unit, cargoName, sourceZoneName, physicalCount,
                    "warehouse", self.coalition, items, request)
                end
            end
            return accepted
        end
    end
    if not (Cargo and Cargo.GetName) or Cargo.Subcategory ~= "Zone supplies" then return true end
    if PlayerZoneSuppliesConsumeStock ~= true then return true end

    local cargoName = Cargo:GetName()
    local requestedSets = redCtldRequestedSets(Cargo, number)
    if pickupZone == nil then
        local _
        _, pickupZone = self:IsUnitInZone(Unit, CTLD.CargoZoneType.LOAD)
    end
    local sourceZone = pickupZone and bc:getZoneByName(pickupZone) or nil

    -- Non-campaign load zones do not own regular campaign supply stock.
    if not sourceZone then return true end

    local now = timer.getAbsTime()
    sourceZone:_updateRegularSupplyStock(now)
    local ready = math.max(0, math.floor(tonumber(sourceZone._regularSupplyReady) or 0))
    local reserved = math.max(0, math.floor(tonumber(sourceZone._regularSupplyPendingStock) or 0))
    local available = math.max(0, ready - reserved)
    if not sourceZone.active or sourceZone.side ~= coalition.side.RED
        or sourceZone._regularSupplyStockSide ~= coalition.side.RED or available < requestedSets
    then
        local T = Group and Group.IsAlive and Group:IsAlive() and L10N:ForMooseGroup(Group) or L10N
        local label = ctldLocalizedCargoLabel(T, "Zone supplies")
        local reason = T:Format("CTLD_REASON_INSUFFICIENT_STOCK", label)
        local text = T:Format("CTLD_WAREHOUSE_NOT_AVAILABLE", label, tostring(pickupZone), reason)
        if Group and Group.IsAlive and Group:IsAlive() then
            MESSAGE:New(text, 12):ToGroup(Group)
        else
            trigger.action.outTextForCoalition(coalition.side.RED, text, 12)
        end
        return false
    end

    sourceZone._regularSupplyReady = ready - requestedSets
    sourceZone._regularSupplyLastUpdateAt = now
    sourceZone:updateLabel(coalition.side.RED)
    redCtldQueueZoneSupplyPickupDebit(Group, Unit, cargoName, pickupZone, requestedSets)
    return true
end

function Foothold_redCtld:OnAfterRemoveCratesNearby(From, Event, To, Group, Unit, Cargotable)
    local inzone, zoneName = self:IsUnitInZone(Unit, CTLD.CargoZoneType.LOAD)
    if not inzone then return end

    local byName = {}
    local warehouseChecked, warehouseStorage, warehouseFarp, warehouseNativeId
    local warehouseGroupId, warehouseGroupObject
    for _, cargo in pairs(Cargotable or {}) do
        local warehouse = pvpEnabled and cargo.Subcategory == "Warehouse"
        if not warehouse and cargo._zoneSupplySourceZone == zoneName then
            redCtldRefundPlayerZoneSupplyStock(cargo)
        end
        local name = cargo.GetName and cargo:GetName() or cargo.name or "none"
        warehouse = warehouse or (pvpEnabled and Foothold_ctld.WarehouseSupplyTypes[name] ~= nil)
        if warehouse then
            if cargo._warehouseDebitItems and not cargo._warehouseSettlementStatus
                and cargo._warehouseSourceZone == zoneName and cargo._warehouseSourceSide == self.coalition
                and WarehouseLogistics == true
            then
                if not warehouseChecked then
                    warehouseChecked = true
                    warehouseFarp = bc.dynamicFarpsByName and bc.dynamicFarpsByName[zoneName]
                    if warehouseFarp then
                      if warehouseFarp.side == self.coalition then
                        local native = bc:getDynamicFarpAirbase(warehouseFarp)
                        if native then
                          warehouseNativeId = warehouseFarp.nativeId
                          local storage = STORAGE:FindByName(zoneName)
                          if storage and storage.airbase == native and storage.warehouse then warehouseStorage = storage end
                        end
                      end
                    else
                    local sourceZone = bc:getZoneByName(zoneName)
                    if sourceZone and sourceZone.active and sourceZone.side == cargo._warehouseSourceSide then
                        local abName = sourceZone.airbaseName or sourceZone.baseName or zoneName
                        warehouseStorage = STORAGE:FindByName(abName)
                        if not warehouseStorage and abName ~= zoneName then warehouseStorage = STORAGE:FindByName(zoneName) end
                    end
                    end
                end
                if warehouseStorage and (warehouseFarp and cargo._warehouseSourceNativeId ~= nil
                      and cargo._warehouseSourceNativeId == warehouseNativeId
                      or not warehouseFarp and cargo._warehouseSourceNativeId == nil)
                    and Foothold_ctld.ApplyWarehouseDebitItems(warehouseStorage, cargo, zoneName, "return") then
                    if cargo._warehousePaidAmount and cargo._warehousePaidAmount > 0 then
                        if not warehouseGroupObject then
                            warehouseGroupObject = Group:GetDCSObject()
                            warehouseGroupId = warehouseGroupObject:getID()
                        end
                        if bc:credit(cargo._warehousePaidSide, cargo._warehousePaidAmount, warehouseGroupId, warehouseGroupObject,
                            "remove: 1x " .. name, cargo._warehousePaidBuyerName) == true then
                            cargo._warehousePaidAmount = 0
                        end
                    end
                end
            end
            cargo._warehouseSettlementStatus = cargo._warehouseSettlementStatus or "discarded"
        else
            byName[name] = (byName[name] or 0) + 1
        end
    end

    if CTLDCost ~= true then return end

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

if pvpEnabled then
    local defaults = {
        ["Squad 4 AK47"] = 0,
        ["Squad 8 AK47"] = 0,
        ["Scout BRDM 2"] = 1,
        ["Ammo Truck"] = 3,
        ["Arty SPH 253 Akatsia 8 NM"] = 3,
        ["Arty SPM 259 Nona 3 NM"] = 3,
        ["MLRS LC 80 MM 2.2 NM"] = 3,
        ["ATGM AT-3 SAGGER"] = 2,
        ["Kord 12.7 MM"] = 1,
        ["MRAP M-ATV"] = 1,
        ["Truck with ZU-23"] = 2,
        ["SA-8"] = 2,
        ["SA-3 SAM system"] = 3,
        ["Pantsir S1"] = MAX_AT_SPAWN["Pantsir S1"],
        ["Tor M2"] = 4,
    }
    for name, value in pairs(defaults) do
        if MAX_AT_SPAWN[name] == nil then MAX_AT_SPAWN[name] = value end
    end
    RED_MAX_AT_SPAWN = MAX_AT_SPAWN
end

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

local function redEnforceMaxAtSpawnForTrackedUnits(trackedUnits, maxAtSpawnMap, restockCallback, knownLoadedRows)
    local unitsByName = {}
    for _, trackedEntry in ipairs(trackedUnits) do
        local cargoName = trackedEntry.CargoName
        unitsByName[cargoName] = unitsByName[cargoName] or {}
        table.insert(unitsByName[cargoName], trackedEntry)
    end

    for normalizedName, groupedEntries in pairs(unitsByName) do
        table.sort(groupedEntries, function(entryA, entryB)
            if knownLoadedRows then return entryA.TimeStamp > entryB.TimeStamp end
            return entryA.Timestamp > entryB.Timestamp
        end)
        local maxAllowed = maxAtSpawnMap[normalizedName] or RED_MAX_AT_SPAWN[normalizedName] or 0
        local totalEntries = #groupedEntries
        for listIndex = totalEntries, maxAllowed + 1, -1 do
            local oldEntry = groupedEntries[listIndex]
            if knownLoadedRows then
                if oldEntry.Group:IsAlive() then oldEntry.Group:Destroy() end
            else
                redDestroyTrackedGroup(oldEntry)
            end
            restockCallback(oldEntry.CargoName)
            for trackedIndex, trackedData in ipairs(trackedUnits) do
                if (knownLoadedRows and trackedData == oldEntry)
                  or (not knownLoadedRows and trackedData.groupName == oldEntry.groupName) then
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

    if pvpEnabled then return cargoName, stock, bestCargoData end
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
    if pvpEnabled and string.find(Vehicle.GroupName, "CTLD_TROOP_FOB", 1, true) then
        return Foothold_ctld.OnAfterCratesBuild(self, From, Event, To, Group, Unit, Vehicle)
    end
    if self.buildRunning > 0 then
        self.buildRunning = self.buildRunning - 1
    end

    local currentTime = timer.getTime()
    local groupName = Vehicle:GetName() or "unknown"

    if not Group then return end

    local cargoName, stock, resolvedCargo
    if pvpEnabled then cargoName, stock, resolvedCargo = redResolveBuiltCargoName(self, groupName)
    else cargoName, stock = redResolveBuiltCargoName(self, groupName) end
    if cargoName == "unknown" then
        self:I(string.format("[RED BUILD] unable to resolve cargo for group=%s", groupName))
        return
    end

    local buildPlayerName
    if pvpEnabled then
        local rewardDef = self._buildRewardByCargo[cargoName]
        buildPlayerName = self:_recordBuildCareer(Group, Unit, bc.CAREER_STAT.CtldBuilds, bc.CAREER_AIRCRAFT_METRIC.CtldBuilds)
        self:_recordAirdroppedBuildCareer(Group, Unit, rewardDef ~= nil)
        if rewardDef and buildPlayerName then bc:recordCareerStat(buildPlayerName, bc.CAREER_STAT.AirDefenseBuilt, 1) end
        self._awardCtldBuildReward(Group, Unit, rewardDef, self.coalition, buildPlayerName or false)
    end

    local maxTimestamp = 0
    for _, group in ipairs(RedGroundUnits) do
        if group.CargoName == cargoName and group.Timestamp > maxTimestamp then
            maxTimestamp = group.Timestamp
        end
    end

    local cargoObject, currentStock
    if pvpEnabled then cargoObject, currentStock = resolvedCargo, stock
    else
        cargoObject = self:_FindCratesCargoObject(cargoName)
        currentStock = cargoObject and cargoObject:GetStock() or stock
    end
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
    if pvpEnabled then self:RegisterPlayerCtldRewardGroup(Vehicle, cargoName, buildPlayerName) end
end

if pvpEnabled then
    for unitType, v in pairs(Foothold_ctld.UnitTypeCapabilities) do
        Foothold_redCtld:SetUnitCapabilities(unitType, v.crates, v.troops, v.cratelimit, v.trooplimit, v.length, v.cargoweightlimit)
    end
else
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
end

local function addRedStaticFromType(name, typeName, mass, subCategory, unitTypes, displayName)
    return Foothold_redCtld:AddStaticsCargoFromType(name, typeName, mass, nil, subCategory, true, nil, unitTypes, nil, nil, nil, displayName)
end


if pvpEnabled then
    for _, spec in ipairs({
        { "CTLD_TROOP_FOB", "CTLD_TROOP_FOB_RED", "FARP", 1200 },
        { "CTLD_TROOP_FOB_ZELL", "CTLD_TROOP_FOB_ZELL_RED", "FARP with ZELL", 750 },
    }) do
        local sourceTemplate = _DATABASE.Templates.Groups[spec[1]]
        if spec[1] == "CTLD_TROOP_FOB" or sourceTemplate then
            local template = UTILS.DeepCopy(sourceTemplate.Template)
            template.name, template.groupId = spec[2], nil
            for i, unit in ipairs(template.units) do
                unit.name, unit.unitId = spec[2] .. "-" .. i, nil
            end
            _DATABASE:_RegisterGroupTemplate(template, coalition.side.RED, Group.Category.GROUND, country.id.RUSSIA, spec[2])
            _DATABASE:AddGroup(spec[2])
            Foothold_redCtld:AddCratesCargo(spec[3], { spec[2] }, CTLD_CARGO.Enum.FOB, 3, spec[4], 10, "FARP", nil, nil, nil, "Cargos", "ammo_cargo", nil, "cds_crate")
        end
    end
end

local standardCargoStock = pvpEnabled and 10 or 6
local artilleryCargoStock = pvpEnabled and 12 or 6
local airDefenseCargoStock = pvpEnabled and standardCargoStock or 5

Foothold_redCtld:AddTroopsCargo("Squad 4 AK47",{"CTLD_TROOPS_RED_Squad_4"},CTLD_CARGO.Enum.TROOPS,4,80,standardCargoStock)
Foothold_redCtld:AddTroopsCargo("Squad 8 AK47",{"CTLD_TROOPS_RED_Squad_8"},CTLD_CARGO.Enum.TROOPS,8,80,standardCargoStock)

Foothold_redCtld:AddCratesCargo("Scout BRDM 2",{"CTLD_CARGO_RED_Scout"},CTLD_CARGO.Enum.VEHICLE,2,500,standardCargoStock, "Support")
Foothold_redCtld:AddCratesCargo("Ammo Truck",{"CTLD_CARGO_RED_AmmoTruck"},CTLD_CARGO.Enum.VEHICLE,2,500,standardCargoStock, "Support")
Foothold_redCtld:AddCratesCargo("Arty SPH 253 Akatsia 8 NM",{"CTLD_CARGO_RED_ARTY_Akatsia"},CTLD_CARGO.Enum.VEHICLE,2,2500,artilleryCargoStock, "ARTY")
Foothold_redCtld:AddCratesCargo("Truck with ZU-23",{"CTLD_CARGO_RED_ZU_23"},CTLD_CARGO.Enum.VEHICLE,2,1000,airDefenseCargoStock, "SAM/AAA")

if Era ~= "Vietnam" then
Foothold_redCtld:AddCratesCargo("Arty SPM 259 Nona 3 NM",{"CTLD_CARGO_RED_ARTY_Nona"},CTLD_CARGO.Enum.VEHICLE,2,2000,artilleryCargoStock, "ARTY")
Foothold_redCtld:AddCratesCargo("ATGM AT-3 SAGGER",{"CTLD_CARGO_RED_AT_3"},CTLD_CARGO.Enum.VEHICLE,2,500,standardCargoStock, "ANTI TANK")
Foothold_redCtld:AddCratesCargo("Kord 12.7 MM",{"CTLD_CARGO_RED_Kord"},CTLD_CARGO.Enum.VEHICLE,2,500,standardCargoStock, "LIGHT ARMOR")
Foothold_redCtld:AddCratesCargo("MLRS LC 80 MM 2.2 NM",{"CTLD_CARGO_RED_ARTY_BBM1"},CTLD_CARGO.Enum.VEHICLE,2,2500,artilleryCargoStock, "ARTY")
Foothold_redCtld:AddCratesCargo("MRAP M-ATV",{"CTLD_CARGO_RED_MRAP"},CTLD_CARGO.Enum.VEHICLE,2,1000,standardCargoStock, "LIGHT ARMOR")
end

if pvpEnabled and Era == "Modern"
    and hasGroupTemplate("Red SAM SHORAD Tor M2") then
Foothold_redCtld:AddCratesCargoNoMove("Tor M2", {"Red SAM SHORAD Tor M2"}, CTLD_CARGO.Enum.FOB, 2, 3000, standardCargoStock, "SAM/AAA",nil,nil,nil,nil,nil,nil,"iso_container")
end

if isRedTemplateEnabled("SA-8") then
Foothold_redCtld:AddCratesCargoNoMove("SA-8",{"CTLD_CARGO_RED_SA_8"},CTLD_CARGO.Enum.VEHICLE,2,2000,airDefenseCargoStock, "SAM/AAA",nil,nil,nil,nil,nil,nil,"iso_container")
end

if isRedTemplateEnabled("SA-3") then
Foothold_redCtld:AddCratesCargoNoMove("SA-3 SAM system",{"CTLD_CARGO_RED_SA_3"},CTLD_CARGO.Enum.VEHICLE,4,4000,pvpEnabled and standardCargoStock or 4, "SAM/AAA",nil,nil,nil,nil,nil,nil,"iso_container_small")
end

--addRedStaticFromType("Red zone supplies CH-47", "cds_crate", 3500, "Zone supplies", {"CH-47Fbl1"}, "Zone supplies")
addRedStaticFromType("Red zone supplies C-130J", "iso_container_small", 4000, "Zone supplies", {"C-130J-30"}, "Zone supplies")
addRedStaticFromType("Red zone supplies MI-8", "ammo_cargo", 2000, "Zone supplies", {"Mi-8MT"}, "Zone supplies")
addRedStaticFromType("Red zone supplies Mi-24P", "ammo_cargo", 500, "Zone supplies", {"Mi-24P"}, "Zone supplies")

if pvpEnabled then
    for _, cargo in ipairs(Foothold_ctld.Cargo_Statics) do
        if cargo.Subcategory == "Warehouse" then
            local name = cargo:GetName()
            Foothold_redCtld:AddStaticsCargoFromType(name, cargo.StaticType, cargo:GetMass(), cargo.Stock0,
                cargo.Subcategory, cargo.DontShowInMenu, cargo.Location, cargo.TypeNames,
                cargo.StaticCategory, cargo.StaticShape, cargo.ResourceMap, cargo:GetDisplayName())
            if RedCTLDPrices[name] == nil then
                local price, rank = priceOf(name), reqRankOf(name)
                if price ~= 0 or rank ~= 0 then
                    RedCTLDPrices[name] = { price = price, reqRank = rank }
                end
            end
        end
    end
end

do
    for _, catalog in ipairs({Foothold_redCtld.Cargo_Troops, Foothold_redCtld.Cargo_Crates, Foothold_redCtld.Cargo_Statics}) do
        for _, cargo in ipairs(catalog) do
            local available = readRedCtldPolicy(cargo.Name)
            cargo.DontShowInMenu = cargo.DontShowInMenu or not available
        end
    end
    local unavailableUnitTypes
    for _, entry in ipairs(Foothold_redCtld.C130GetUnits or {}) do
        local available = readRedCtldPolicy(entry.Name)
        if not available then
            unavailableUnitTypes = unavailableUnitTypes or {}
            entry.UnitTypes = unavailableUnitTypes
        end
    end
end

local RED_ZONE_SUPPLY_TYPES = {
    ["Red zone supplies CH-47"] = true,
    ["Red zone supplies MI-8"] = true,
    ["Red zone supplies Mi-24P"] = true,
    ["Red zone supplies C-130J"] = true,
}

local RED_ZONE_SUPPLY_AGL_THRESHOLD = 0.5
local RED_ZONE_SUPPLY_NOZONE_TTL = 600
local RED_ZONE_SUPPLY_NOZONE_RECHECK = 60
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

redCtldRefundPlayerZoneSupplyStock = function(entryOrCargo)
    if not entryOrCargo or entryOrCargo._zoneSupplySourceConsumed ~= true then return false end
    local sourceZoneName = entryOrCargo._zoneSupplySourceZone
    local farpReturned = false
    if pvpEnabled then
        local stock, record, native = Foothold_ctld:GetFarpSupplyStock(sourceZoneName, coalition.side.RED)
        if record then
            if entryOrCargo._zoneSupplySourceSide ~= record.side
                or entryOrCargo._zoneSupplySourceNativeId ~= record.nativeId then return false end
            if Foothold_ctld:AddFarpSupplyStock(sourceZoneName, 1, coalition.side.RED, record, native) == nil then return false end
            farpReturned = true
        elseif entryOrCargo._zoneSupplySourceNativeId ~= nil
            or (sourceZoneName and bc.dynamicFarpsByName and bc.dynamicFarpsByName[sourceZoneName]) then return false end
    end
    if not farpReturned then
    local sourceZone = sourceZoneName and bc:getZoneByName(sourceZoneName) or nil
    if not sourceZone or not sourceZone.active or sourceZone.side ~= coalition.side.RED
        or sourceZone._regularSupplyStockSide ~= coalition.side.RED
        or not sourceZone:_regularSupplyHasRouteForSide(coalition.side.RED)
    then
        return false
    end

    sourceZone:_addImportedRegularSupplyStock(1, timer.getAbsTime())
    end
    entryOrCargo._zoneSupplySourceConsumed = false
    entryOrCargo._zoneSupplySourceRefunded = true
    if entryOrCargo.cargo then
        entryOrCargo.cargo._zoneSupplySourceConsumed = false
        entryOrCargo.cargo._zoneSupplySourceRefunded = true
    end
    for _, trackedEntry in pairs(redZoneSupplyCrates) do
        if trackedEntry == entryOrCargo or trackedEntry.cargo == entryOrCargo then
            trackedEntry._zoneSupplySourceConsumed = false
            trackedEntry._zoneSupplySourceRefunded = true
        end
    end
    return true
end

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
    if type(name) ~= "string" then
        if pvpEnabled then return false, name end
        return false
    end
    if RED_ZONE_SUPPLY_TYPES[name] == true then return true end
    for baseName in pairs(RED_ZONE_SUPPLY_TYPES) do
        if name:sub(1, #baseName + 1) == baseName .. "-" then
            return true
        end
    end
    if pvpEnabled then return false, name end
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

local function redCtldRebuildZoneSupplyOnboardCache()
    local onboardByGroup = {}
    for _, entry in pairs(redZoneSupplyCrates) do
        local groupId = redCtldResolveGroupId(entry)
        if groupId and redCtldTrackedSupplyOnboard(entry) then
            onboardByGroup[groupId] = true
        end
    end
    Foothold_redCtld.ZoneSupplyOnboardByGroup = onboardByGroup
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
    local vec3 = obj and obj.GetVec3 and obj:GetVec3() or nil
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
    entry._lastVec3.x = vec3.x
    entry._lastVec3.y = vec3.y
    entry._lastVec3.z = vec3.z
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

local function redCtldMarkSupplyLoaded(key, entry, staticObj, deferCacheRefresh)
    if not entry then return end

    entry.wasLoaded = true
    entry.wasAirborne = true
    entry._wasUnloaded = false
    entry.attached = true
    entry.detached = false
    entry.noZoneAt = nil
    entry.noZoneNextCheckAt = nil
    entry.noNeedAt = nil

    if not entry._gcLoadedMsg then
        local staticName = redCtldStaticName(staticObj) or entry.cargoName or tostring(key)
        redCtldSendLocalized(entry, "CTLD_CRATE_LOADED_GROUND_CREW", 10, tostring(staticName))
        entry._gcLoadedMsg = true
    end

    if deferCacheRefresh ~= true then
        Foothold_redCtld:RefreshZoneSupplyOnboardForGroup(redCtldResolveGroupId(entry))
    end
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

local function redCtldFinalizeDelivery(key, entry, zoneObj, actionKey, statLabel, reward, actionArgs)
    local actionText = actionArgs
        and redCtldFormatForEntry(entry, actionKey, unpack(actionArgs))
        or redCtldFormatForEntry(entry, actionKey)
    local text = redCtldFormatForEntry(entry, "CTLD_ZONE_SUPPLIES_DELIVERED", actionText, zoneObj.zone)
    redCtldSendToEntry(entry, text, 15)
    redCtldRewardPlayer(entry, statLabel, reward)
    redCtldSimulateLandingForEntryIfOnGround(entry, zoneObj.zone)
    redCtldDestroyStatic(redCtldCargoStatic(entry.cargo, entry))
    redCtldRemoveTrackedSupply(key)
    if pvpEnabled then
        addCTLDZonesForRedControlled(zoneObj.zone, zoneObj)
    else
        addCTLDZonesForRedControlled(zoneObj.zone)
    end
end

function completePendingRedCtldSupply(zoneObj, payload, succeeded)
    if not succeeded then return end
    local entry = {
        groupName = payload.groupName,
        groupId = payload.groupId,
        playerName = payload.playerName,
        unitName = payload.unitName,
    }
    local joinedCapture = payload.joinedCapture == true
    local actionKey = joinedCapture and "CTLD_ZONE_SUPPLY_ACTION_STOCKED" or "CTLD_ZONE_SUPPLY_ACTION_CAPTURED"
    local actionText = joinedCapture
        and redCtldFormatForEntry(entry, actionKey,
            math.max(0, math.floor(tonumber(zoneObj._regularSupplyReady) or 0)),
            zoneObj:_regularSupplyMaxStock())
        or redCtldFormatForEntry(entry, actionKey)
    local text = redCtldFormatForEntry(entry, "CTLD_ZONE_SUPPLIES_DELIVERED", actionText, zoneObj.zone)
    redCtldSendToEntry(entry, text, 15)
    redCtldRewardPlayer(entry, joinedCapture and "Zone supply delivery" or "Zone capture", joinedCapture and 150 or ZONE_SUPPLY_CAPTURE_REWARD)
    if pvpEnabled then
        addCTLDZonesForRedControlled(zoneObj.zone, zoneObj)
    else
        addCTLDZonesForRedControlled(zoneObj.zone)
    end
end

bc:registerPendingCaptureHandler("red_ctld_capture_delivery", completePendingRedCtldSupply)

local function redCtldDestroySupplyInZone(key, entry, zoneObj, reason)
    local text = redCtldFormatForEntry(entry, "CTLD_ZONE_SUPPLIES_DESTROYED", zoneObj.zone, reason)
    redCtldSendToEntry(entry, text, 15)
    redCtldDestroyStatic(redCtldCargoStatic(entry.cargo, entry))
    redCtldRemoveTrackedSupply(key)
end

local function redCtldRegisterSupplyCargo(cargoItem, pickupZone, groupName, groupId, playerName, unitName, carrierUnitObject, flags)
    local warehouseMeta, cargoName
    if pvpEnabled and cargoItem.Subcategory == "Warehouse" then
        cargoName = redCtldCargoName(cargoItem)
        warehouseMeta = Foothold_ctld.WarehouseSupplyTypes[cargoName]
        if not warehouseMeta or not cargoItem._warehouseDebitItems or cargoItem._warehouseSettlementStatus
            or cargoItem._warehouseSourceSide ~= Foothold_redCtld.coalition then return nil, nil end
        pickupZone = cargoItem._warehouseSourceZone
    else
        local isZoneSupply, knownName = redCtldIsZoneSupplyCargo(cargoItem)
        if not isZoneSupply then
            if pvpEnabled then return nil, nil, false, knownName end
            return nil, nil
        end
    end
    local key = redCtldCargoKey(cargoItem)
    if not key then return nil, nil end

    if not warehouseMeta and cargoItem._zoneSupplySourceConsumed ~= true then
        local sourceZoneName, debit
        if pvpEnabled then
            sourceZoneName, debit = redCtldClaimZoneSupplyPickupDebit(unitName, groupName, redCtldCargoName(cargoItem))
        else
        sourceZoneName = redCtldClaimZoneSupplyPickupDebit(unitName, groupName, redCtldCargoName(cargoItem))
        end
        if sourceZoneName then
            cargoItem._zoneSupplySourceConsumed = true
            cargoItem._zoneSupplySourceZone = sourceZoneName
            if pvpEnabled and debit and debit.kind == "farp" then
                cargoItem._zoneSupplySourceSide, cargoItem._zoneSupplySourceNativeId = debit.sourceSide, debit.sourceNativeId
                pickupZone, cargoItem._zoneSupplyPickupZone = sourceZoneName, sourceZoneName
            end
        end
    end

    local staticObj = redCtldCargoStatic(cargoItem)
    local initialVec3 = nil
    if staticObj then
        initialVec3 = staticObj:GetVec3()
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
            cargoName = cargoName or redCtldCargoName(cargoItem),
            createdAt = timer.getTime(),
            wasLoaded = false,
            wasAirborne = false,
            _wasUnloaded = false,
            attached = false,
            detached = false,
            warnedNoNeed = false,
            warnedSameZone = false,
            _zoneSupplySourceConsumed = cargoItem._zoneSupplySourceConsumed == true,
            _zoneSupplySourceZone = cargoItem._zoneSupplySourceZone,
            _lastVec3 = initialVec3 and { x = initialVec3.x, y = initialVec3.y, z = initialVec3.z } or nil,
        }
        if pvpEnabled then
            entry._zoneSupplySourceSide, entry._zoneSupplySourceNativeId = cargoItem._zoneSupplySourceSide, cargoItem._zoneSupplySourceNativeId
        end
        redZoneSupplyCrates[key] = entry
    else
        entry.cargo = cargoItem
        entry.static = staticObj or entry.static
        entry.pickupZone = pickupZone or entry.pickupZone
        entry.groupName = groupName or entry.groupName
        entry.groupId = groupId or entry.groupId
        entry.playerName = playerName or entry.playerName
        entry.unitName = unitName or entry.unitName
        entry.cargoName = cargoName or redCtldCargoName(cargoItem) or entry.cargoName
        if cargoItem._zoneSupplySourceConsumed == true then
            entry._zoneSupplySourceConsumed = true
            entry._zoneSupplySourceZone = cargoItem._zoneSupplySourceZone
            if pvpEnabled then
                entry._zoneSupplySourceSide, entry._zoneSupplySourceNativeId = cargoItem._zoneSupplySourceSide, cargoItem._zoneSupplySourceNativeId
            end
        end
    end

    if warehouseMeta then
        entry.deliveryType = "warehouse"
        entry.warehouseMeta = warehouseMeta
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

    local c130Items = pvpEnabled and self.UseC130LoadAndUnload and Unit and self:IsC130J(Unit) and {} or nil
    for _, cargoItem in ipairs(cargoItems) do
        local key, entry, isZoneSupply, cargoName = redCtldRegisterSupplyCargo(cargoItem, pickupZone, groupName, groupId, playerName, unitName, carrierUnitObject)
        if c130Items and isZoneSupply == false and type(cargoName) == "string"
            and not Foothold_ctld.WarehouseSupplyTypes[cargoName]
            and self:_FindCratesCargoObject(cargoName)
            and not Foothold_ctld.C130AutoBuildCrates[cargoItem] then
            c130Items[#c130Items + 1] = cargoItem
        end
        if entry then
            local staticObj = redCtldCargoStatic(cargoItem, entry)
            local vec3 = staticObj and staticObj:GetVec3() or nil
            if vec3 and redCtldCargoInsideCarrier(entry, vec3) then
                redCtldMarkSupplyLoaded(key, entry, staticObj)
            end
        end
    end
    if c130Items and #c130Items > 0 then
        Foothold_ctld._registerC130AutoBuildSet(groupName, playerName, unitName, pickupZone, c130Items, self, carrierUnitObject or false)
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

    local c130CountryId, c130AircraftId
    local loaded = pvpEnabled and self.Loaded_Cargo[unitName] or nil
    if loaded and loaded.Cargo ~= Cargo then loaded = nil end
    for _, cargoItem in ipairs(cargoItems) do
      if pvpEnabled and loaded then
        local entry = Foothold_ctld.C130AutoBuildCrates[cargoItem]
        local set = entry and Foothold_ctld.C130AutoBuildSets[entry.setId] or nil
        if set and set.ctld == self then
          if c130CountryId == nil then
            c130CountryId = false
            if GroupObj and self.UseC130LoadAndUnload and self.C130JUnits[unitName] == true
              and carrierUnitObject and carrierUnitObject:getCoalition() == self.coalition then
              local carrierType = carrierUnitObject:getTypeName()
              if carrierType == "C-130J-30" or (self.C130JTypes and self.C130JTypes[carrierType]) then
                c130CountryId = carrierUnitObject:getCountry()
                c130AircraftId = bc:getCareerAircraftId(carrierType)
              end
            end
          end
          if c130CountryId ~= false then
            entry.onboard = loaded
            entry.static = nil
            entry._missingCount = nil
            entry.groupName, entry.playerName, entry.unitName = groupName, playerName, unitName
            entry._unitObj, entry._unitDim = carrierUnitObject, nil
            set.groupName, set.playerName, set.unitName = groupName, playerName, unitName
            set.aircraftId, set.countryId = c130AircraftId, c130CountryId
          end
        end
      end
        local key, entry = redCtldRegisterSupplyCargo(cargoItem, pickupZone, groupName, groupId, playerName, unitName, carrierUnitObject, { wasLoaded = true })
        if entry and not entry._gcLoadedMsg then
            redCtldSendLocalized(entry, "CTLD_CRATE_LOADED_GROUND_CREW", 10, tostring(entry.cargoName or key))
            entry._gcLoadedMsg = true
        end
    end
end

local FootholdRedOriginalGetCrates = Foothold_redCtld._GetCrates
if pvpEnabled then
    local originalCargoPrice = Foothold_redCtld.GetCargoPrice
    if originalCargoPrice then
        Foothold_redCtld.GetCargoPrice = function(self, ...)
            local request = Foothold_ctld._warehousePickupRequest
            if request and request._warehouseQuotePhase == "awaiting" and request._warehouseOwner == self
                and select(2, ...) == request._warehouseOriginalCargo then
                request._warehouseQuotePhase = "method"
                return Foothold_ctld._observeWarehousePrice(request, "method", originalCargoPrice(self, ...))
            end
            return originalCargoPrice(self, ...)
        end
    end
end
function Foothold_redCtld:_GetCrates(Group, Unit, Cargo, number, drop, pack, quiet, suppressGetEvent)
    if not drop and not pack then
        if Cargo.Name == "Pantsir S1" or (Cargo.Name == "Tor M2"
          and (not pvpEnabled or Era ~= "Modern")) then
          return false
        end
        local available = readRedCtldPolicy(Cargo.Name)
        if not available then return false end
    end
    local beforeCount = #(self.Spawned_Cargo or {})
    local c130Entry = pvpEnabled and drop and Foothold_ctld.C130AutoBuildCrates[Cargo] or nil
    local c130Set = c130Entry and Foothold_ctld.C130AutoBuildSets[c130Entry.setId] or nil
    if c130Set and (c130Set.ctld ~= self or not c130Entry.onboard
      or c130Entry.unitName ~= Unit:GetName()
      or self.Loaded_Cargo[c130Entry.unitName] ~= c130Entry.onboard) then
      c130Entry, c130Set = nil, nil
    end
    local request, previousRequest
    if pvpEnabled and not drop and not pack then
      local inLoad, pickupZone = self:IsUnitInZone(Unit, CTLD.CargoZoneType.LOAD)
      local record = inLoad and bc.dynamicFarpsByName and bc.dynamicFarpsByName[pickupZone] or nil
      local native
      if record then
        if record.side ~= self.coalition or record.side ~= Unit:GetCoalition() then return false end
        native = bc:getDynamicFarpAirbase(record)
        if not native then return false end
      end
      local perSet = Cargo:GetCratesNeeded() or 1
      if perSet < 1 then perSet = 1 end
      local requestNumber = tonumber(number)
      if requestNumber then requestNumber = math.floor(requestNumber); if requestNumber < 1 then requestNumber = perSet end
      else requestNumber = perSet end
      request = { _warehouseOwner = self, _warehouseOriginalCargo = Cargo,
        _pickupUnit = Unit, _pickupRequestNumber = requestNumber, _pickupZone = inLoad and pickupZone or false,
        _pickupRecord = record or false, _pickupNative = native or false }
      previousRequest = Foothold_ctld._warehousePickupRequest
      Foothold_ctld._warehousePickupRequest = request
    end
    if pvpEnabled and not drop and not pack and WarehouseLogistics == true
        and Cargo and Cargo.Subcategory == "Warehouse"
    then
        local cargoName = Cargo:GetName()
        local meta = Foothold_ctld.WarehouseSupplyTypes[cargoName]
        if meta then
            request.cargoName = cargoName
            request._warehouseMeta = meta
            request._warehouseQuotePhase = CTLDCost == true and "awaiting" or "free"
        end
    end
    local result = FootholdRedOriginalGetCrates(self, Group, Unit, Cargo, number, drop, pack, quiet, suppressGetEvent)
    if request then
      request._pickupUnit, request._pickupRecord, request._pickupNative = nil, nil, nil
      request._pickupZone, request._pickupRequestNumber = nil, nil
      Foothold_ctld._warehousePickupRequest = previousRequest
    end
    if pvpEnabled and drop and result == true and Cargo._warehouseDebitItems
        and #self.Spawned_Cargo == beforeCount + 1 then
        local replacement = self.Spawned_Cargo[beforeCount + 1]
        replacement._warehouseSourceZone = Cargo._warehouseSourceZone
        replacement._warehouseSourceSide = Cargo._warehouseSourceSide
        replacement._warehouseSourceNativeId = Cargo._warehouseSourceNativeId
        replacement._warehouseDebitItems = Cargo._warehouseDebitItems
        replacement._warehouseSettlementZone = Cargo._warehouseSettlementZone
        replacement._warehouseSettlementKind = Cargo._warehouseSettlementKind
        replacement._warehouseSettlementKey = Cargo._warehouseSettlementKey
        replacement._warehouseSettlementWritten = Cargo._warehouseSettlementWritten
        replacement._warehouseSettlementStatus = Cargo._warehouseSettlementStatus
        replacement._warehousePaidAmount = Cargo._warehousePaidAmount
        replacement._warehousePaidSide = Cargo._warehousePaidSide
        replacement._warehousePaidBuyerName = Cargo._warehousePaidBuyerName
        Cargo._warehouseSourceZone = nil
        Cargo._warehouseSourceSide = nil
        Cargo._warehouseSourceNativeId = nil
        Cargo._warehouseDebitItems = nil
        Cargo._warehouseSettlementZone = nil
        Cargo._warehouseSettlementKind = nil
        Cargo._warehouseSettlementKey = nil
        Cargo._warehouseSettlementWritten = nil
        Cargo._warehouseSettlementStatus = nil
        Cargo._warehousePaidAmount = nil
        Cargo._warehousePaidSide = nil
        Cargo._warehousePaidBuyerName = nil
        local oldKey = redCtldCargoKey(Cargo)
        local entry = redZoneSupplyCrates[oldKey]
        local needsRegistration = entry == nil
        if needsRegistration then
            local _, registeredEntry = redCtldRegisterSupplyCargo(replacement, replacement._warehouseSourceZone,
                Group:GetName(), Group:GetID(), Unit:GetPlayerName(), Unit:GetName(), Unit:GetDCSObject())
            entry = registeredEntry
        end
        if entry then
            if not needsRegistration then redZoneSupplyCrates[oldKey] = nil end
            entry.cargo = replacement
            entry.static = replacement:GetPositionable()
            entry.wasAirborne = true
            entry._wasUnloaded = true
            entry.attached = false
            entry.detached = true
            entry._lastVec3 = nil
            entry.noZoneAt = nil
            entry.noZoneNextCheckAt = nil
            entry.noNeedAt = nil
            if not needsRegistration then redZoneSupplyCrates[redCtldCargoKey(replacement)] = entry end
            self:RefreshZoneSupplyOnboardForGroup(entry.groupId)
        end
    end
    if c130Entry and result == true and Foothold_ctld.C130AutoBuildCrates[Cargo] == c130Entry
      and Foothold_ctld.C130AutoBuildSets[c130Entry.setId] == c130Set and not c130Set.completed
      and c130Set.crates[c130Entry.setIndex] == Cargo
      and #self.Spawned_Cargo == beforeCount + 1 then
      local replacement = self.Spawned_Cargo[beforeCount + 1]
      Foothold_ctld.C130AutoBuildCrates[Cargo] = nil
      c130Entry.cargo = replacement
      c130Entry.static = replacement:GetPositionable()
      c130Entry.onboard = nil
      c130Entry.attached = true
      c130Entry.detached = true
      c130Entry.landed = false
      c130Entry._missingCount = nil
      c130Entry._lastVec3 = nil
      c130Entry._landAglConfirm = nil
      c130Set.crates[c130Entry.setIndex] = replacement
      Foothold_ctld.C130AutoBuildCrates[replacement] = c130Entry
    end
    local bindRequest = request and result == true and request._warehouseStockAdmitted
    if (suppressGetEvent == true or bindRequest) and #(self.Spawned_Cargo or {}) > beforeCount then
        local obtainedCargo = suppressGetEvent == true and {} or nil
        for index = beforeCount + 1, #self.Spawned_Cargo do
            local cargoItem = self.Spawned_Cargo[index]
            if bindRequest and cargoItem._warehouseSourceZone == nil then
                local sourceZoneName, debit = redCtldClaimZoneSupplyPickupDebit(request._warehousePickupKey, nil, request.cargoName, request)
                if sourceZoneName then
                    cargoItem._warehouseSourceZone = sourceZoneName
                    cargoItem._warehouseSourceSide = debit.sourceSide
                    cargoItem._warehouseSourceNativeId = debit.sourceNativeId
                    cargoItem._warehouseDebitItems = debit.items
                    cargoItem._warehousePaidAmount = debit._warehouseQuotePhase == "quoted" and debit._warehouseQuotedPrice or 0
                    cargoItem._warehousePaidSide = debit._warehousePaidSide
                    cargoItem._warehousePaidBuyerName = debit._warehousePaidBuyerName
                end
            end
            if obtainedCargo then obtainedCargo[#obtainedCargo + 1] = cargoItem end
        end
        if obtainedCargo then self:OnAfterGetCrates(nil, nil, nil, Group, Unit, obtainedCargo) end
    end
    return result
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
            if oldEntry and oldEntry._zoneSupplySourceConsumed == true
                and cargoItem._zoneSupplySourceConsumed ~= true
            then
                cargoItem._zoneSupplySourceConsumed = true
                cargoItem._zoneSupplySourceZone = oldEntry._zoneSupplySourceZone
                if pvpEnabled then
                    cargoItem._zoneSupplySourceSide, cargoItem._zoneSupplySourceNativeId = oldEntry._zoneSupplySourceSide, oldEntry._zoneSupplySourceNativeId
                end
            end
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
        redCtldMarkSupplyLoaded(key, entry, redCtldCargoStatic(cargo, entry), true)
        return
    end

    local staticObj = redCtldCargoStatic(cargo, entry)
    if not redCtldStaticAlive(staticObj) then
        local carrierUnit = redCtldTrackedSupplyOnboard(entry) and redCtldResolveCarrierUnit(entry, false) or nil
        if carrierUnit and carrierUnit.isExist and carrierUnit:isExist() then
            entry.attached = true
            entry.wasAirborne = true
        else
            redCtldRemoveTrackedSupply(key)
        end
        return
    end

    entry.static = staticObj
    local vec3 = staticObj:GetVec3()
    if not vec3 then return end

    local moved = redCtldTrackMoved(entry, vec3)
    local ground = land.getHeight({ x = vec3.x, y = vec3.z })
    local agl = vec3.y - ground

    if redCtldCargoInsideCarrier(entry, vec3) then
        redCtldMarkSupplyLoaded(key, entry, staticObj, true)
    end
    if moved then
        entry.noNeedAt = nil
        entry.noZoneAt = nil
        entry.noZoneNextCheckAt = nil
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

    if entry.noZoneNextCheckAt and now < entry.noZoneNextCheckAt then return end
    local zoneName = redCtldResolveZoneNameFromVec3(vec3)
    local farpWarehouseStorage
    if pvpEnabled and not zoneName and (entry.deliveryType ~= "warehouse"
        or (WarehouseLogistics == true and cargo and cargo._warehouseDebitItems and not cargo._warehouseSettlementStatus
            and cargo._warehouseSourceSide == Foothold_redCtld.coalition)) then
        local inLoad, farpName = Foothold_redCtld:IsUnitInZone(staticObj, CTLD.CargoZoneType.LOAD)
        local farp = inLoad and bc.dynamicFarpsByName and bc.dynamicFarpsByName[farpName]
        if farp then
          if entry.deliveryType == "warehouse" then
            if farp.side == Foothold_redCtld.coalition
                and ((farpName ~= cargo._warehouseSourceZone and farpName ~= entry.pickupZone)
                    or (farpName == cargo._warehouseSourceZone and cargo._warehouseSourceNativeId ~= nil
                        and cargo._warehouseSourceNativeId == farp.nativeId)) then
                local native = bc:getDynamicFarpAirbase(farp)
                if native then
                    local storage = STORAGE:FindByName(farpName)
                    if storage and storage.airbase == native and storage.warehouse then
                        farpWarehouseStorage, zoneName = storage, farpName
                    end
                end
            end
          else
            local accepted
            if entry._zoneSupplySourceConsumed == true and entry._zoneSupplySourceZone == farpName then
                accepted = redCtldRefundPlayerZoneSupplyStock(entry)
                if accepted then
                    redCtldSendLocalized(entry, "CTLD_SUPPLIES_RETURNED_TO_ZONE", 15,
                        ctldLocalizedCargoLabel(L10N, "Zone supplies"), farpName)
                end
            elseif entry.pickupZone ~= farpName then
                local stock, record, native = Foothold_ctld:GetFarpSupplyStock(farpName, coalition.side.RED)
                if record then
                    accepted = Foothold_ctld:AddFarpSupplyStock(farpName, 1, coalition.side.RED, record, native) ~= nil
                end
                if accepted then
                    Foothold_ctld:_recordCareerSupply(entry, bc.CAREER_STAT.FarpSupplyUnits, false)
                    local playerName = redCtldResolvePlayer(entry)
                    if playerName then
                        trigger.action.outTextForCoalition(Foothold_redCtld.coalition, L10N:Format("CTLD_SUPPLIES_DELIVERED_BY",
                            ctldLocalizedCargoLabel(L10N, entry.cargoName or "Zone supplies"), farpName, tostring(playerName)), 15)
                        redCtldRewardPlayer(entry, "Zone supply delivery", 150)
                    end
                    redCtldSimulateLandingForEntryIfOnGround(entry, farpName)
                end
            end
            if accepted then
                redCtldDestroyStatic(staticObj)
                redCtldRemoveTrackedSupply(key)
                return
            end
          end
        end
    end
    if not zoneName then
        entry.noZoneAt = entry.noZoneAt or now
        entry.noZoneNextCheckAt = now + RED_ZONE_SUPPLY_NOZONE_RECHECK
        if (now - entry.noZoneAt) > RED_ZONE_SUPPLY_NOZONE_TTL then
            redCtldRemoveTrackedSupply(key)
        end
        return
    end
    entry.noZoneAt = nil
    entry.noZoneNextCheckAt = nil

    if pvpEnabled and entry.deliveryType == "warehouse" then
        local zoneObj
        if not farpWarehouseStorage then zoneObj = bc:getZoneByName(zoneName) end
        if not farpWarehouseStorage and (not zoneObj or not zoneObj.active) then return end
        if not cargo or not cargo._warehouseDebitItems or cargo._warehouseSettlementStatus
            or cargo._warehouseSourceSide ~= Foothold_redCtld.coalition then
            if cargo then cargo._warehouseSettlementStatus = cargo._warehouseSettlementStatus or "discarded" end
            redCtldDestroySupplyInZone(key, entry, zoneObj, "not available")
            return
        end
        local returning = zoneName == cargo._warehouseSourceZone
        if not farpWarehouseStorage and zoneObj.side ~= Foothold_redCtld.coalition then
            if zoneObj.side == coalition.side.NEUTRAL and not returning then return end
            cargo._warehouseSettlementStatus = "discarded"
            redCtldDestroySupplyInZone(key, entry, zoneObj,
                zoneObj.side == coalition.side.NEUTRAL and "neutral zone timeout" or "enemy zone")
            return
        end
        if WarehouseLogistics ~= true then
            cargo._warehouseSettlementStatus = "discarded"
            redCtldDestroySupplyInZone(key, entry, zoneObj, "warehouse logistics disabled")
            return
        end
        local storage = farpWarehouseStorage
        if not storage then
            local abName = zoneObj.airbaseName or zoneObj.baseName or zoneName
            storage = STORAGE:FindByName(abName)
            if not storage and abName ~= zoneName then storage = STORAGE:FindByName(zoneName) end
        end
        if not storage then
            cargo._warehouseSettlementStatus = "discarded"
            redCtldDestroySupplyInZone(key, entry, zoneObj, "no storage")
            return
        end
        if not Foothold_ctld.ApplyWarehouseDebitItems(storage, cargo, zoneName, returning and "return" or "delivery") then
            cargo._warehouseSettlementStatus = cargo._warehouseSettlementStatus or "discarded"
            if farpWarehouseStorage then
                redCtldSendLocalized(entry, "CTLD_ZONE_SUPPLIES_DESTROYED", 15, zoneName, "no applicable inventory")
                redCtldDestroyStatic(staticObj)
                redCtldRemoveTrackedSupply(key)
            else
                redCtldDestroySupplyInZone(key, entry, zoneObj, "no applicable inventory")
            end
            return
        end
        local meta = entry.warehouseMeta
        if returning then
            local grp = redCtldResolveGroup(entry)
            local T = grp and L10N:ForMooseGroup(grp) or L10N
            redCtldSendToEntry(entry, T:Format("CTLD_SUPPLIES_RETURNED_TO_ZONE",
                ctldLocalizedCargoLabel(T, meta.label or "Supplies"), zoneName), 15)
        else
            Foothold_ctld:_recordCareerSupply(entry, nil, true)
            local playerName = redCtldResolvePlayer(entry)
            if playerName then
                trigger.action.outTextForCoalition(Foothold_redCtld.coalition, L10N:Format("CTLD_SUPPLIES_DELIVERED_BY",
                    ctldLocalizedCargoLabel(L10N, meta.label or "Supplies"), zoneName, tostring(playerName)), 15)
                local reward = meta.reward or ((meta.categories and #meta.categories > 1) and 100 or 50)
                redCtldRewardPlayer(entry, "Warehouse delivery", reward)
            end
            redCtldSimulateLandingForEntryIfOnGround(entry, zoneName)
        end
        redCtldDestroyStatic(staticObj)
        redCtldRemoveTrackedSupply(key)
        return
    end

    if entry.pickupZone and zoneName == entry.pickupZone
        and entry._zoneSupplySourceConsumed == true
        and entry._zoneSupplySourceZone == zoneName
    then
        if redCtldRefundPlayerZoneSupplyStock(entry) then
            local grp = redCtldResolveGroup(entry)
            local T = grp and L10N:ForMooseGroup(grp) or L10N
            local label = ctldLocalizedCargoLabel(T, "Zone supplies")
            redCtldSendToEntry(entry, T:Format("CTLD_SUPPLIES_RETURNED_TO_ZONE", label, zoneName), 15)
            redCtldDestroyStatic(staticObj)
            redCtldRemoveTrackedSupply(key)
        else
            local sourceZone = bc:getZoneByName(zoneName)
            local reason = sourceZone.side == coalition.side.NEUTRAL and "neutral zone timeout" or "enemy zone"
            redCtldDestroySupplyInZone(key, entry, sourceZone, reason)
        end
        return
    end

    if entry.pickupZone and zoneName == entry.pickupZone then
        return
    end

    local zoneObj = bc:getZoneByName(zoneName)
    if not zoneObj or not zoneObj.active then return end

    if zoneObj.side == 2 then
        redCtldDestroySupplyInZone(key, entry, zoneObj, "enemy zone")
        return
    end

    if zoneObj._pendingCaptureRestore then return end
    if zoneObj.side == 0 then
        local staticName = redCtldStaticName(staticObj)
        local dcsStatic = staticName and StaticObject.getByName(staticName) or nil
        if not dcsStatic or not dcsStatic:isExist() then
            redCtldDestroySupplyInZone(key, entry, zoneObj, "not available")
            return
        end
        local joinedCapture = zoneObj.pendingCapture ~= nil
        local accepted, captureStatus = zoneObj:startPendingCapture(coalition.side.RED, {
            kind = "static",
            name = staticName,
            position = dcsStatic:getPoint(),
            staticType = dcsStatic:getTypeName(),
            country = dcsStatic:getCountry(),
            destroyOnFinish = true,
            tombstone = true,
            delivery = {
                handler = "red_ctld_capture_delivery",
                payload = {
                    groupName = entry.groupName,
                    groupId = entry.groupId,
                    playerName = redCtldResolvePlayer(entry),
                    unitName = entry.unitName,
                    joinedCapture = joinedCapture,
                },
            },
        })
        if accepted then
            if captureStatus ~= "completed" then
                local actionKey = captureStatus == "started" and "CTLD_ZONE_SUPPLY_ACTION_CAPTURING" or "CTLD_ZONE_SUPPLY_ACTION_QUEUED"
                local actionText = redCtldFormatForEntry(entry, actionKey)
                redCtldSendToEntry(entry, redCtldFormatForEntry(entry, "CTLD_ZONE_SUPPLIES_DELIVERED", actionText, zoneObj.zone), 15)
            end
            redCtldSimulateLandingForEntryIfOnGround(entry, zoneObj.zone)
            redCtldRemoveTrackedSupply(key)
        else
            redCtldDestroySupplyInZone(key, entry, zoneObj, "not available")
        end
        return
    end

    if zoneObj.side == coalition.side.RED then
        zoneObj:_addImportedRegularSupplyStock(1, timer.getAbsTime())
        local ready = math.max(0, math.floor(tonumber(zoneObj._regularSupplyReady) or 0))
        local maximum = zoneObj:_regularSupplyMaxStock()
        redCtldFinalizeDelivery(
            key,
            entry,
            zoneObj,
            "CTLD_ZONE_SUPPLY_ACTION_STOCKED",
            "Zone supply delivery",
            150,
            { ready, maximum }
        )
    end
end

local function tickRedZoneSupply()
    if not next(redZoneSupplyCrates) then return end
    local now = timer.getTime()
    for key, entry in pairs(redZoneSupplyCrates) do
        redCtldProcessZoneSupply(key, entry, now)
    end
    redCtldRebuildZoneSupplyOnboardCache()
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

function addCTLDZonesForRedControlled(zoneName, knownZone)
    local function applyZone(zName, knownZone)
        local zoneObj = (GlobalSettings.pvpEnabled == true and knownZone) or bc:getZoneByName(zName)
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
        if GlobalSettings.pvpEnabled == true then
            applyZone(zoneName, knownZone)
        else
            applyZone(zoneName)
        end
    else
        for _, zoneObj in ipairs(bc:getZones()) do
            if GlobalSettings.pvpEnabled == true then
                applyZone(zoneObj.zone, zoneObj)
            else
                applyZone(zoneObj.zone)
            end
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

    Foothold_redCtld.enableLoadSave = GlobalSettings.pvpEnabled ~= true or not bc._persistenceResetPending
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

if pvpEnabled then
    Foothold_redCtld._resolveCareerAircraftId = Foothold_ctld._resolveCareerAircraftId
    Foothold_redCtld._pvpProtectedBuilds = {}
    Foothold_redCtld.CanBuildCrates = Foothold_ctld.CanBuildCrates
    Foothold_redCtld._CleanUpCrates = Foothold_ctld._CleanUpCrates
    Foothold_redCtld._BuildObjectFromCrates = Foothold_ctld._BuildObjectFromCrates
    Foothold_redCtld._recordCareerAction = Foothold_ctld._recordCareerAction
    Foothold_redCtld._recordBuildCareer = Foothold_ctld._recordBuildCareer
    Foothold_redCtld._recordAirdroppedBuildCareer = Foothold_ctld._recordAirdroppedBuildCareer
    Foothold_redCtld._buildRewardByCargo = Foothold_ctld._buildRewardByCargo
    Foothold_redCtld._awardCtldBuildReward = Foothold_ctld._awardCtldBuildReward
    Foothold_redCtld.GetTroopPickupZone = Foothold_ctld.GetTroopPickupZone
    Foothold_redCtld.OnAfterTroopsPickedUp = Foothold_ctld.OnAfterTroopsPickedUp
    Foothold_redCtld.OnAfterTroopsDeployed = Foothold_ctld.OnAfterTroopsDeployed
    Foothold_redCtld.RegisterPlayerCtldRewardGroup = Foothold_ctld.RegisterPlayerCtldRewardGroup
    Foothold_redCtld.RemovePlayerCtldRewardGroup = Foothold_ctld.RemovePlayerCtldRewardGroup
    Foothold_redCtld.RemovePlayerCtldRewardUnit = Foothold_ctld.RemovePlayerCtldRewardUnit
    Foothold_redCtld.PlayerCtldRewards = Foothold_ctld.PlayerCtldRewards
    Foothold_redCtld.PlayerCtldStatOverrides = Foothold_ctld.PlayerCtldStatOverrides
end

Foothold_redCtld:__Load(10)

function Foothold_redCtld:OnAfterLoaded(From, Event, To, LoadedGroups)
    self:I("***** Red CTLD Groups Loaded! *****")

    local acceptedTroopRows = pvpEnabled and {} or nil
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
        local skipRestore, nearestEnemyName, nearestEnemyNm
        if pvpEnabled then
            skipRestore, nearestEnemyName, nearestEnemyNm = bc:_restorePointTooFarFromEnemy(groupPoint, 80, self.coalition)
        else
            skipRestore, nearestEnemyName, nearestEnemyNm = redRestorePointTooFarFromBlue(groupPoint, 120)
        end
        local crateCargo = self:_FindCratesCargoObject(cargoName)
        local troopCargo, captureObjectState
        if pvpEnabled then
            troopCargo = self:_FindTroopsCargoObject(cargoName)
            captureObjectState = bc:isPendingCaptureObject(groupName)
        end

        if captureObjectState == "active" then
            self:I(string.format("[RED RESTORE] pending capture group retained=%s cargo=%s", groupName, cargoName))
        elseif captureObjectState == "consumed" then
            if loadedGroup.Group:IsAlive() then loadedGroup.Group:Destroy() end
        elseif pvpEnabled and deployedTroops[groupName] == loadedGroup.Group then
            -- Already enrolled by this restore completion.
        elseif skipRestore then
            self:I(string.format(pvpEnabled and "[RED RESTORE] skip loaded group=%s cargo=%s nearestEnemy=%s dist=%.1fNm limit=80.0Nm" or "[RED RESTORE] skip loaded group=%s cargo=%s nearestEnemy=%s dist=%.1fNm limit=120.0Nm", groupName, cargoName, tostring(nearestEnemyName), nearestEnemyNm or -1))
            if crateCargo then
                self:AddStockCrates(cargoName, 1)
            end
            if troopCargo then self:AddStockTroops(cargoName, 1) end
            if loadedGroup.Group:IsAlive() then
                loadedGroup.Group:Destroy()
            end
        elseif crateCargo then
            local trackedGroup = {
                groupName = groupName,
                Timestamp = timestamp,
                Group = loadedGroup.Group,
                CargoName = cargoName,
                Stock = crateCargo:GetStock() or 0
            }
            if pvpEnabled then trackedGroup.PlayerName = loadedGroup.PlayerName end
            table.insert(RedGroundUnits, trackedGroup)
        elseif troopCargo then
            acceptedTroopRows[#acceptedTroopRows + 1] = loadedGroup
        end
    end

    redEnforceMaxAtSpawnForTrackedUnits(RedGroundUnits, MaxAtSpawn, function(CargoName)
        Foothold_redCtld:AddStockCrates(CargoName, 1)
    end)

    if pvpEnabled then
        for _, entry in ipairs(RedGroundUnits) do
            if entry.Group then self:RegisterPlayerCtldRewardGroup(entry.Group, entry.CargoName, entry.PlayerName) end
        end
        redEnforceMaxAtSpawnForTrackedUnits(acceptedTroopRows, MaxAtSpawn, function(CargoName)
            self:AddStockTroops(CargoName, 1)
        end, true)
        for _, loadedRow in ipairs(acceptedTroopRows) do
            local cargo = self._troopsByName[loadedRow.CargoName]
            self:OnAfterTroopsDeployed(From, Event, To, nil, nil, loadedRow.Group, cargo.CargoType, loadedRow, cargo)
        end
    end

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
