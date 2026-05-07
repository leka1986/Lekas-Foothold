env.info("ZEUS START: is loading.")

SupportHandler = EVENTHANDLER:New()

function randomnumberZEUS()
    return math.random(1,1000)
end

function spv(groupName, coord)
    local rngz = randomnumberZEUS()
    local group = SPAWN:NewWithAlias(groupName, groupName .. rngz)
    group:SpawnFromVec2(coord:GetVec2())
end

function handleSpawnRequest(text, coord)
    local unitList = {
        "SA-8","SA-9","SA-13","SA-15","SA-19","Soldier","Truck","Shilka","Igla","Igla-S",
        "RPG","BMP2","Tank","BTR80", "CTLD_CARGO_HMMWV",
        "JTAC9lineam","JTAC9linefm","Tankm1","CTLD_CARGO_L118","CTLD_CARGO_Scout","CTLD_CARGO_AmmoTruck", "CTLD_CARGO_GMLRS_HE"
    }
    for i = 1, #unitList do
        if text == "-create " .. unitList[i]:lower() then
            spv(unitList[i], coord)
            break
        end
    end
end

function handleStaticRequest(text, coord) end
function handleDebugRequest(text, coord)  end

destroyZoneCount          = 0
destroyVehicleZoneCount   = 0

function handleDestroyRequest(text, coord)
    local name = string.format("destroy %d", destroyZoneCount)
    local zone = ZONE_RADIUS:New(name, coord:GetVec2(), 500)
    destroyZoneCount = destroyZoneCount + 1
    zone:SearchZone(function(u) u:Destroy() return true end, Object.Category.UNIT)
end

function handleDestroyVehicleRequest(text, coord)
    local name = string.format("destroy %d", destroyVehicleZoneCount)
    local zone = ZONE_RADIUS:New(name, coord:GetVec2(), 1000)
    destroyVehicleZoneCount = destroyVehicleZoneCount + 1
    zone:SearchZone(function(u) u:Destroy() return true end, Object.Category.UNIT)
end

function handleClearRequest(text, coord)
    local name = string.format("destroy %d", destroyZoneCount)
    local zone = ZONE_RADIUS:New(name, coord:GetVec2(), 10000)
    destroyZoneCount = destroyZoneCount + 1
    zone:SearchZone(function(u) u:Destroy() return true end, Object.Category.UNIT)
end

function handleExplodeRequest(text, coord)
    local power, delay = 100, 0
    local p1, p2 = string.match(text, "-explode (%d+) ?(%d*)")
    if p1 then power = tonumber(p1) end
    if p2 and p2 ~= "" then delay = tonumber(p2) end
    coord:Explosion(power, delay)
end

function handleSmokeRequest(text, coord)
    local c = (string.match(text, "-smoke (%a+)") or "red"):lower()
    if     c == "red"    then coord:SmokeRed()
    elseif c == "blue"   then coord:SmokeBlue()
    elseif c == "green"  then coord:SmokeGreen()
    elseif c == "orange" then coord:SmokeOrange()
    elseif c == "white"  then coord:SmokeWhite()
    else  coord:SmokeRed() end
end

function dispatchCommand(Event)
    if not (Event.text and Event.text:sub(1,1) == "-") then return end
    local text = Event.text:lower()
    local vec3 = {x = Event.pos.x, y = Event.pos.y, z = Event.pos.z}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()
    if     text:find("-create")   then handleSpawnRequest(text, coord)
    elseif text:find("-static")   then handleStaticRequest(text, coord)
    elseif text:find("-debug")    then handleDebugRequest(text, coord)
    elseif text:find("-destroy1") then handleDestroyRequest(text, coord)
    elseif text:find("-destroy2") then handleDestroyVehicleRequest(text, coord)
    elseif text:find("-destroy3") then handleDestroyVehicleRequest(text, coord)
    elseif text:find("-destroy4") then handleClearRequest(text, coord)
    elseif text:find("-explode")  then handleExplodeRequest(text, coord)
    elseif text:find("-smoke")    then handleSmokeRequest(text, coord)
    else return end
    trigger.action.removeMark(Event.idx)
end

function SupportHandler:onEvent(Event)
    if Event.id == world.event.S_EVENT_MARK_ADDED
        or Event.id == world.event.S_EVENT_MARK_CHANGE then
        dispatchCommand(Event)
    end
end

world.addEventHandler(SupportHandler)

env.info("ZEUS START: is completed!")
