---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- ## CTLD ## --

---------------------------------------------------------------------------
-- CTLD: Core Setup & Options
---------------------------------------------------------------------------

BASE:I("CTLD : is loading.")

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

local function getCtldGroupTranslator(group)
    return L10N:ForMooseGroup(group)
end

local function formatCtldForGroup(group, key, ...)
    return getCtldGroupTranslator(group):Format(key, ...)
end

local function messageCtldToGroup(group, key, duration, ...)
    MESSAGE:New(formatCtldForGroup(group, key, ...), duration or 15):ToGroup(group)
end

local function sendCtldToGroupOrCoalition(group, key, duration, ...)
    if group and group.IsAlive and group:IsAlive() then
        messageCtldToGroup(group, key, duration, ...)
    else
        trigger.action.outTextForCoalition(2, L10N:Format(key, ...), duration or 15)
    end
end

local function sendCtldToDeployer(deployer, key, duration, ...)
    Foothold_ctld:_SendMessage(formatCtldForGroup(deployer, key, ...), duration or 15, false, deployer)
end

local CTLD_MENU_LABEL_KEYS = {
    ["Zone supplies"] = "CTLD_MENU_ZONE_SUPPLIES",
    ["Warehouse"] = "CTLD_MENU_WAREHOUSE",
    ["Supplies"] = "CTLD_MENU_SUPPLIES",
    ["Ammo Truck"] = "CTLD_MENU_AMMO_TRUCK",
    ["Squad 8"] = "CTLD_MENU_SQUAD_8",
    ["Platoon 16"] = "CTLD_MENU_PLATOON_16",
    ["Platoon 32"] = "CTLD_MENU_PLATOON_32",
    ["Anti-Air Soldiers"] = "CTLD_MENU_ANTI_AIR_SOLDIERS",
    ["Mortar Squad"] = "CTLD_MENU_MORTAR_SQUAD",
    ["Engineer soldier"] = "CTLD_MENU_ENGINEER_SOLDIER",
    ["ANTI TANK"] = "CTLD_MENU_ANTI_TANK",
    ["Support"] = "CTLD_MENU_SUPPORT",
    ["SAM/AAA"] = "CTLD_MENU_SAM_AAA",
    ["SAM Addon"] = "CTLD_MENU_SAM_ADDON",
    ["FARP"] = "CTLD_MENU_FARP",
    ["Humvee scout"] = "CTLD_MENU_HUMVEE_SCOUT",
    ["10 of everything"] = "CTLD_MENU_10_EVERYTHING",
    ["25 of everything"] = "CTLD_MENU_25_EVERYTHING",
    ["50 of everything"] = "CTLD_MENU_50_EVERYTHING",
    ["10 A/A Missiles"] = "CTLD_MENU_10_AA_MISSILES",
    ["25 A/A Missiles"] = "CTLD_MENU_25_AA_MISSILES",
    ["50 A/A Missiles"] = "CTLD_MENU_50_AA_MISSILES",
    ["10 A/G Missiles"] = "CTLD_MENU_10_AG_MISSILES",
    ["25 A/G Missiles"] = "CTLD_MENU_25_AG_MISSILES",
    ["50 A/G Missiles"] = "CTLD_MENU_50_AG_MISSILES",
    ["10 A/G Rockets"] = "CTLD_MENU_10_AG_ROCKETS",
    ["25 A/G Rockets"] = "CTLD_MENU_25_AG_ROCKETS",
    ["50 A/G Rockets"] = "CTLD_MENU_50_AG_ROCKETS",
    ["10 A/G Bombs"] = "CTLD_MENU_10_AG_BOMBS",
    ["25 A/G Bombs"] = "CTLD_MENU_25_AG_BOMBS",
    ["50 A/G Bombs"] = "CTLD_MENU_50_AG_BOMBS",
    ["10 (Plane fuel tanks) and pylons"] = "CTLD_MENU_10_FUEL_TANKS_PYLONS",
    ["25 Plane fuel-tanks and pylons"] = "CTLD_MENU_25_FUEL_TANKS_PYLONS",
    ["50 Plane fuel-tanks and pylons"] = "CTLD_MENU_50_FUEL_TANKS_PYLONS",
    ["10 Modded weapons"] = "CTLD_MENU_10_MODDED_WEAPONS",
    ["25 Modded weapons"] = "CTLD_MENU_25_MODDED_WEAPONS",
    ["50 Modded weapons"] = "CTLD_MENU_50_MODDED_WEAPONS",
    ["10 Mods"] = "CTLD_MENU_10_MODDED_WEAPONS",
    ["25 Mods"] = "CTLD_MENU_25_MODDED_WEAPONS",
    ["50 Mods"] = "CTLD_MENU_50_MODDED_WEAPONS",
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

Foothold_ctld = CTLD:New(coalition.side.BLUE,{"CH.47","Ka.50.3","SA342L", "UH.1H", "Hercules", "Mi.8MT","Ми.8МТВ2","Ми.24П", "Bronco.OV", "UH.60L", "Mi.24P", "OH58D", "KA.50", "AH.64D", "UH.60.DAP","C.130J.30","MH.60R"},"Lufttransportbrigade I")
Foothold_ctld:SetGroupLocaleResolver(function(_, Group)
    return getFootholdLocalization():GetMooseGroupLocale(Group)
end)
function Foothold_ctld:GetFootholdLocalizedCargoLabel(translator, label)
    if type(translator) == "string" then
        translator = L10N:ForLocale(translator)
    end
    return ctldLocalizedCargoLabel(translator or L10N, label)
end
Foothold_ctld.dropcratesanywhere = true
Foothold_ctld.forcehoverload = false
Foothold_ctld.CrateDistance = 65
Foothold_ctld.PackDistance = 120
Foothold_ctld.maximumHoverHeight = 20
Foothold_ctld.minimumHoverHeight = 3
Foothold_ctld.smokedistance = 8000
Foothold_ctld.enableFixedWing = true
Foothold_ctld.FixedMinAngels = 100 -- for troop/cargo drop via chute in meters, ca 470 ft
Foothold_ctld.FixedMaxSpeed = 200 -- 77mps or 270kph or 150kn
Foothold_ctld.dropAsCargoCrate = true
Foothold_ctld.nobuildinloadzones = true
Foothold_ctld.movecratesbeforebuild = false
Foothold_ctld.hoverautoloading = false
Foothold_ctld.enableslingload = true
Foothold_ctld.usesubcats = true
Foothold_ctld.pilotmustopendoors = true
Foothold_ctld.buildtime = 30
Foothold_ctld.TroopUnloadDistGroundHook = 35
Foothold_ctld.onestepmenu = true
Foothold_ctld.basetype = "uh1h_cargo"
Foothold_ctld.RadioSoundFC3 = "beaconsilent.ogg"
Foothold_ctld.VehicleMoveFormation= {AI.Task.VehicleFormation.VEE, AI.Task.VehicleFormation.ECHELON_LEFT, AI.Task.VehicleFormation.ECHELON_RIGHT, AI.Task.VehicleFormation.RANK, AI.Task.VehicleFormation.CONE}

if UseC130LoadAndUnload then
Foothold_ctld.UseC130LoadAndUnload = true
end
Foothold_ctld.returntroopstobase = false

-- Config flag (default in Foothold Config.lua): false = engineers cannot capture/upgrade zones.
CaptureZoneWithEngineer = CaptureZoneWithEngineer or false

Foothold_ctld:__Start(2)

---------------------------------------------------------------------------
-- CTLD: Pricing
---------------------------------------------------------------------------

function priceOf(name)
    local v = CTLDPrices and CTLDPrices[name]
    if type(v) == "table" then
        return v.price or v.cost or CTLD_DEFAULT_PRICE or 0
    end
    return v or CTLD_DEFAULT_PRICE or 0
end

function reqRankOf(name)
    local v = CTLDPrices and CTLDPrices[name]
    if type(v) == "table" then
        return v.reqRank or 0
    end
    return 0
end


CTLDPrices = CTLDPrices or {
  ["Engineer soldier"]       = { price = 50, reqRank = 1 },
  ["Squad 8"]                = { price = 50, reqRank = 1 },
  ["Platoon 16"]             = { price = 100, reqRank = 1 },
  ["Platoon 32"]             = { price = 200, reqRank = 1 },
  ["Anti-Air Soldiers"]      = { price = 100, reqRank = 1 },
  ["Mortar Squad"]           = { price = 100, reqRank = 1 },
  ["Mephisto"]               = { price = 250, reqRank = 2 },
  ["Humvee"]                 = { price = 250, reqRank = 1 },
  ["Bradly"]                 = { price = 250, reqRank = 1 },
  ["L118"]                   = { price = 150, reqRank = 1 },
  ["Ammo Truck"]             = { price = 100, reqRank = 1 },
  ["Humvee scout"]           = { price = 100, reqRank = 1 },
  ["Linebacker"]             = { price = 300, reqRank = 2 },
  ["Vulcan"]                 = { price = 300, reqRank = 2 },
  ["HAWK System"]            = { price = 750, reqRank = 3 },
  ["Hawk TR Add-on"]         = { price = 250, reqRank = 3 },
  ["Hawk SR Add-on"]         = { price = 250, reqRank = 3 },
  ["Hawk LN Add-on"]         = { price = 250, reqRank = 3 },
  ["NASAMS System"]          = { price = 750, reqRank = 3 },
  ["NASAMS C2 Add-on"]       = { price = 250, reqRank = 3 },
  ["NASAMS SR Add-on"]       = { price = 250, reqRank = 3 },
  ["NASAMS LN Add-on"]       = { price = 250, reqRank = 3 },
  ["FARP"]                   = { price = 500, reqRank = 1 },
  ["IRIS T STR Add-on"]      = { price = 750, reqRank = 3 },
  ["IRIS T LN Add-on"]       = { price = 500, reqRank = 3 },
  ["IRIS T C2 Add-on"]       = { price = 500, reqRank = 3 },
  ["IRIS T System"]          = { price = 1800, reqRank = 3 },
  ["C-RAM"]                  = { price = 500, reqRank = 2 },
  ["HIMARS GMLRRS HE GUIDED"]= { price = 1000, reqRank = 3 },
  ["FV-107 Scimitar"]        = { price = 250, reqRank = 2 },
  ["FV-101 Scorpion"]        = { price = 250, reqRank = 2 },
  ["Avenger"]                = { price = 250, reqRank = 2 },
}
CTLD_DEFAULT_PRICE = 0

---------------------------------------------------------------------------
-- CTLD: Cargo Definitions
---------------------------------------------------------------------------

-- troops
Foothold_ctld:AddTroopsCargo("Squad 8",{"CTLD_TROOPS_ATS"},CTLD_CARGO.Enum.TROOPS,8,80,10)
Foothold_ctld:AddTroopsCargo("Platoon 16",{"CTLD_TROOPS_Platon16"},CTLD_CARGO.Enum.TROOPS,16,80,10)
Foothold_ctld:AddTroopsCargo("Platoon 32",{"CTLD_TROOPS_Platon1"},CTLD_CARGO.Enum.TROOPS,32,80,10)
Foothold_ctld:AddTroopsCargo("Anti-Air Soldiers",{"CTLD_TROOPS_AA"},CTLD_CARGO.Enum.TROOPS,5,80,10)
Foothold_ctld:AddTroopsCargo("Mortar Squad",{"CTLD_TROOPS_MRS"},CTLD_CARGO.Enum.TROOPS,6,80,10)
-- vehicles and fobs
Foothold_ctld:AddTroopsCargo("Engineer soldier",{"CTLD_TROOPS_Engineers"},CTLD_CARGO.Enum.ENGINEERS,1,80,10)
Foothold_ctld:AddCratesCargo("Mephisto",{"CTLD_CARGO_Mephisto"}, CTLD_CARGO.Enum.VEHICLE, 2, 1500,10, "ANTI TANK")
Foothold_ctld:AddCratesCargo("Humvee",{"CTLD_CARGO_HMMWV"},CTLD_CARGO.Enum.VEHICLE,2,1000,10, "ANTI TANK")
Foothold_ctld:AddCratesCargo("Bradly",{"CTLD_CARGO_Bradly"},CTLD_CARGO.Enum.VEHICLE,2,1500,10, "ANTI TANK")
Foothold_ctld:AddCratesCargoNoMove("L118",{"CTLD_CARGO_L118"},CTLD_CARGO.Enum.VEHICLE,1,700,12, "Support",nil,nil,nil,"Cargos",nil,nil, "iso_container_small")
Foothold_ctld:AddCratesCargoNoMove("Ammo Truck",{"CTLD_CARGO_AmmoTruck"},CTLD_CARGO.Enum.VEHICLE,2,800,10, "Support")
Foothold_ctld:AddCratesCargo("Humvee scout",{"CTLD_CARGO_Scout"},CTLD_CARGO.Enum.VEHICLE,2,1000,10, "Support")
Foothold_ctld:AddCratesCargoNoMove("HAWK System",{"CTLD_CARGO_HAWKSite"},CTLD_CARGO.Enum.FOB,4,1900,10, "SAM/AAA",nil,nil,nil,"Cargos",nil,nil, "iso_container_small")

Foothold_ctld:AddCratesCargoNoMove("Hawk TR Add-on", {"CTLD_CARGO_HAWKSite_TR"},CTLD_CARGO.Enum.FOB, 1, 1500, 10, "SAM Addon",nil,nil,nil,"Cargos","cds_crate",nil, "iso_container_small")
Foothold_ctld:AddCratesCargoNoMove("Hawk SR Add-on", {"CTLD_CARGO_HAWKSite_SR"},CTLD_CARGO.Enum.FOB, 1, 1500, 15, "SAM Addon",nil,nil,nil,"Cargos","cds_crate",nil, "iso_container_small")
Foothold_ctld:AddCratesCargoNoMove("Hawk LN Add-on", {"CTLD_CARGO_HAWKSite_LN"},CTLD_CARGO.Enum.FOB, 1, 1500, 10, "SAM Addon",nil,nil,nil,"Cargos","cds_crate",nil, "iso_container_small")

if Era=='Modern' then
Foothold_ctld:AddCratesCargoNoMove("NASAMS System",{"CTLD_CARGO_NasamsSite"},CTLD_CARGO.Enum.FOB,4,1900,10, "SAM/AAA",nil,nil,nil,"Cargos",nil,nil, "iso_container_small")

Foothold_ctld:AddCratesCargoNoMove("NASAMS C2 Add-on",{"CTLD_CARGO_NasamsSite_C2"},CTLD_CARGO.Enum.FOB, 1, 1500, 10, "SAM Addon",nil,nil,nil,"Cargos","cds_crate",nil, "iso_container_small")
Foothold_ctld:AddCratesCargoNoMove("NASAMS SR Add-on",{"CTLD_CARGO_NasamsSite_SR"},CTLD_CARGO.Enum.FOB, 1, 1500, 15, "SAM Addon",nil,nil,nil,"Cargos","cds_crate",nil, "iso_container_small")
Foothold_ctld:AddCratesCargoNoMove("NASAMS LN Add-on",{"CTLD_CARGO_NasamsSite_LN"},CTLD_CARGO.Enum.FOB, 1, 1500, 10, "SAM Addon",nil,nil,nil,"Cargos","cds_crate",nil, "iso_container_small")


Foothold_ctld:AddCratesCargoNoMove("IRIS T STR Add-on", {"CTLD_CARGO_IRISTSLM_STR"},CTLD_CARGO.Enum.FOB, 1, 2500, 10, "SAM Addon",nil,nil,nil,"Cargos","cds_crate",nil, "iso_container_small")
Foothold_ctld:AddCratesCargoNoMove("IRIS T LN Add-on", {"CTLD_CARGO_IRISTSLM-LN"},CTLD_CARGO.Enum.FOB, 1, 3500, 15, "SAM Addon",nil,nil,nil,"Cargos","cds_crate",nil, "iso_container_small")
Foothold_ctld:AddCratesCargoNoMove("IRIS T C2 Add-on", {"CTLD_CARGO_IRISTSLM_C2"},CTLD_CARGO.Enum.FOB, 1, 1900, 10, "SAM Addon",nil,nil,nil,"Cargos","cds_crate",nil, "iso_container_small")
Foothold_ctld:AddCratesCargoNoMove("IRIS T System", {"CTLD_CARGO_IRISTSLM_System"}, CTLD_CARGO.Enum.FOB, 3, 2800, 10, "SAM/AAA", nil,nil,nil,"Cargos","cds_crate",nil, "iso_container_small")
Foothold_ctld:AddCratesCargoNoMove("C-RAM", {"CTLD_CARGO_CRAM"}, CTLD_CARGO.Enum.FOB, 2, 1000, 10, "SAM/AAA")
Foothold_ctld:AddCratesCargoNoMove("HIMARS GMLRRS HE GUIDED",{"CTLD_CARGO_GMLRS_HE"},CTLD_CARGO.Enum.VEHICLE,2,3500,12, "Support", nil,nil,nil,"Cargos",nil,nil, "iso_container_small")
end
Foothold_ctld:AddCratesCargo("Linebacker",{"CTLD_CARGO_Linebacker"},CTLD_CARGO.Enum.VEHICLE,2,1500,10, "SAM/AAA")
Foothold_ctld:AddCratesCargo("Vulcan",{"CTLD_CARGO_Vulcan"}, CTLD_CARGO.Enum.VEHICLE, 2, 1500,10, "SAM/AAA")

Foothold_ctld:AddUnits("Humvee",{"CTLD_CARGO_HMMWV"},CTLD_CARGO.Enum.VEHICLE,10, "ANTI TANK")
Foothold_ctld:AddUnits("Mephisto",{"CTLD_CARGO_Mephisto"},CTLD_CARGO.Enum.VEHICLE,10, "ANTI TANK")
Foothold_ctld:AddUnits("Vulcan",{"CTLD_CARGO_Vulcan"}, CTLD_CARGO.Enum.VEHICLE, 10, "SAM/AAA")
Foothold_ctld:AddUnits("Avenger",{"CTLD_CARGO_Avenger"}, CTLD_CARGO.Enum.VEHICLE, 10, "SAM/AAA")
Foothold_ctld:AddUnits("Humvee scout",{"CTLD_CARGO_Scout"}, CTLD_CARGO.Enum.VEHICLE, 10, "Support")
Foothold_ctld:AddUnits("FV-107 Scimitar",{"CTLD_CARGO_Scimitar"}, CTLD_CARGO.Enum.VEHICLE, 10, "Support")
Foothold_ctld:AddUnits("FV-101 Scorpion",{"CTLD_CARGO_Scorpion"}, CTLD_CARGO.Enum.VEHICLE, 10, "Support")
Foothold_ctld:AddCratesCargo("FARP",{"CTLD_TROOP_FOB"},CTLD_CARGO.Enum.FOB,3,1200,10, "FARP",nil,nil,nil,"Cargos","ammo_cargo",nil, "cds_crate")

local function addStaticFromType(name, typeName, mass, subCategory, unitTypes, displayName) return Foothold_ctld:AddStaticsCargoFromType(name, typeName, mass, nil, subCategory, true, nil, unitTypes, nil, nil, nil, displayName) end

addStaticFromType("Zone supplies C-130J", "iso_container_small", 4000, "Zone supplies", {"C-130J-30"}, "Zone supplies")
addStaticFromType("Zone supplies CH-47", "cds_crate", 3500, "Zone supplies", {"CH-47Fbl1"}, "Zone supplies")
addStaticFromType("Zone supplies UH-1H", "ammo_cargo", 500, "Zone supplies", {"UH-1H"}, "Zone supplies")
addStaticFromType("Zone supplies SA342L", "ammo_cargo", 350, "Zone supplies", {"SA342L"}, "Zone supplies")
addStaticFromType("Zone supplies MI-8", "ammo_cargo", 2300, "Zone supplies", {"Mi-8MT"}, "Zone supplies")
addStaticFromType("Zone supplies Blackhawk", "ammo_cargo", 2000, "Zone supplies", {"UH-60L_DAP","UH-60L"}, "Zone supplies")
addStaticFromType("Zone supplies Mi-24P", "ammo_cargo", 500, "Zone supplies", {"Mi-24P"}, "Zone supplies")

addStaticFromType("10 of everything CH-47", "cds_crate", 3500, "Warehouse", {"CH-47Fbl1"}, "10 of everything")
addStaticFromType("10 of everything MI-8", "cds_crate", 3500, "Warehouse", {"Mi-8MT"}, "10 of everything")
addStaticFromType("10 of everything Blackhawk", "cds_crate", 2000, "Warehouse", {"UH-60L_DAP","UH-60L"}, "10 of everything")

addStaticFromType("10 A/A Missiles", "ammo_cargo", 1000, "Warehouse", {"CH-47Fbl1","UH-1H","Mi-8MT","Mi-24P","UH-60L_DAP","UH-60L"}, "10 A/A Missiles")
addStaticFromType("10 A/G Missiles", "ammo_cargo", 1000, "Warehouse", {"CH-47Fbl1","UH-1H","Mi-8MT","Mi-24P","UH-60L_DAP","UH-60L"}, "10 A/G Missiles")
addStaticFromType("10 A/G Rockets", "ammo_cargo", 500, "Warehouse", {"CH-47Fbl1","UH-1H","Mi-8MT","Mi-24P","UH-60L_DAP","UH-60L"}, "10 A/G Rockets")
addStaticFromType("10 A/G Bombs", "ammo_cargo", 1000, "Warehouse", {"CH-47Fbl1","UH-1H","Mi-8MT","Mi-24P","UH-60L_DAP","UH-60L"}, "10 A/G Bombs")
addStaticFromType("10 (Plane fuel tanks) and pylons", "ammo_cargo", 500, "Warehouse", {"CH-47Fbl1","UH-1H","Mi-8MT","Mi-24P","UH-60L_DAP","UH-60L"}, "10 (Plane fuel tanks) and pylons")

addStaticFromType("50 of everything", "iso_container", 8000, "Warehouse", {"C-130J-30"}, "50 of everything")
addStaticFromType("50 A/A Missiles", "iso_container_small", 2000, "Warehouse", {"C-130J-30"}, "50 A/A Missiles")
addStaticFromType("50 A/G Missiles", "iso_container_small", 2000, "Warehouse", {"C-130J-30"}, "50 A/G Missiles")
addStaticFromType("50 A/G Rockets", "iso_container_small", 2000, "Warehouse", {"C-130J-30"}, "50 A/G Rockets")
addStaticFromType("50 A/G Bombs", "iso_container_small", 2000, "Warehouse", {"C-130J-30"}, "50 A/G Bombs")
addStaticFromType("50 Plane fuel-tanks and pylons", "iso_container_small", 2000, "Warehouse", {"C-130J-30"}, "50 Plane fuel-tanks and pylons")
addStaticFromType("25 of everything", "iso_container_small", 4000, "Warehouse", {"C-130J-30"}, "25 of everything")
addStaticFromType("25 A/A Missiles", "cds_crate", 1000, "Warehouse", {"C-130J-30"}, "25 A/A Missiles")
addStaticFromType("25 A/G Missiles", "cds_crate", 1000, "Warehouse", {"C-130J-30"}, "25 A/G Missiles")
addStaticFromType("25 A/G Rockets", "cds_crate", 1000, "Warehouse", {"C-130J-30"}, "25 A/G Rockets")
addStaticFromType("25 A/G Bombs", "cds_crate", 1000, "Warehouse", {"C-130J-30"}, "25 A/G Bombs")
addStaticFromType("25 Plane fuel-tanks and pylons", "cds_crate", 1000, "Warehouse", {"C-130J-30"}, "25 Plane fuel-tanks and pylons")

if AllowMods and not Era=="Coldwar" then
addStaticFromType("25 Modded weapons", "cds_crate", 1000, "Warehouse", {"C-130J-30"}, "25 Modded weapons")
addStaticFromType("50 Modded weapons", "iso_container_small", 2000, "Warehouse", {"C-130J-30"}, "50 Modded weapons")
addStaticFromType("10 Modded weapons", "ammo_cargo", 500, "Warehouse", {"CH-47Fbl1","UH-1H","Mi-8MT","Mi-24P","UH-60L_DAP","UH-60L"}, "10 Modded weapons")
end
---------------------------------------------------------------------------
-- Zone Supply: Cargo Types
---------------------------------------------------------------------------


local ZONE_SUPPLY_TYPES = {
  ["Zone supplies C-130J"] = true,
  ["Zone supplies UH-1H"] = true,
  ["Zone supplies MI-8"] = true,
  ["Zone supplies Mi-24P"] = true,
  ["Zone supplies CH-47"] = true,
  ["Zone supplies Blackhawk"] = true,
  ["Zone supplies SA342L"] = true,
}

---------------------------------------------------------------------------
-- CTLD Persistence: Limits
---------------------------------------------------------------------------


-- How many of the units loaded from the save file should be spawned next time?
-- Oldest will be deleted first.

MAX_AT_SPAWN = MAX_AT_SPAWN or {
    ["Engineer soldier"]        = 0,
    ["Mephisto"]                = 2,
    ["Humvee"]                  = 2,
    ["Bradly"]                  = 2,
    ["L118"]                    = 3,
    ["Ammo Truck"]              = 3,
    ["Humvee scout"]            = 1,
    ["Squad 8"]                 = 0,
    ["Platoon 16"]              = 0,
    ["Platoon 32"]              = 0,
    ["Anti-Air Soldiers"]       = 2,
    ["Mortar Squad"]            = 2,
    ["Linebacker"]              = 2,
    ["Vulcan"]                  = 2,
    ["HAWK System"]             = 3,
    ["Hawk TR Add-on"]          = 3,
    ["Hawk SR Add-on"]          = 3,
    ["Hawk LN Add-on"]          = 8,
    ["NASAMS System"]           = 3,
    ["NASAMS C2 Add-on"]        = 3,
    ["NASAMS SR Add-on"]        = 3,
    ["NASAMS LN Add-on"]        = 8,
    ["Tank Abrahams"]           = 0,
    ["FARP"]                    = 3,
    ["IRIS T STR Add-on"]       = 3,
    ["IRIS T LN Add-on"]        = 8,
    ["IRIS T C2 Add-on"]        = 3,
    ["IRIS T System"]           = 2,
    ["C-RAM"]                   = 4,
    ["HIMARS GMLRRS HE GUIDED"] = 4,
    ["FV-107 Scimitar"]         = 2,
    ["FV-101 Scorpion"]         = 2,
    ["Avenger"]                 = 2,
}
-- How many farps do you want to load? 
-- Oldest will not be spawned if the number is exceded.
MAX_SAVED_FARPS      = MAX_SAVED_FARPS or 3


CTLDUnitCapabilities = CTLDUnitCapabilities or {
    ["SA342Mistral"] = { false, true, 0, 2, 10, 400 },
    ["SA342L"] = { false, true, 1, 2, 10, 400 },
    ["SA342M"] = { false, true, 0, 2, 10, 400 },
    ["SA342Minigun"] = { false, true, 0, 2, 10, 400 },
    ["UH-1H"] = { true, true, 1, 8, 15, 800 },
    ["Mi-8MT"] = { true, true, 3, 16, 15, 6000 },
    ["Mi-8MTV2"] = { true, true, 3, 18, 15, 6000 },
    ["Ka-50"] = { false, false, 0, 0, 15, 400 },
    ["Mi-24P"] = { true, true, 2, 8, 15, 1000 },
    ["Mi-24V"] = { true, true, 2, 8, 15, 1000 },
    ["Hercules"] = { true, true, 8, 20, 25, 20000 },
    ["C-130J-30"] = { true, true, 7, 64, 35, 21500 },
    ["UH-60L"] = { true, true, 2, 20, 16, 3500 },
    ["UH-60L_DAP"] = { true, true, 2, 20, 16, 3500 },
    ["AH-64D_BLK_II"] = { false, false, 0, 0, 15, 400 },
    ["CH-47Fbl1"] = { true, true, 5, 32, 20, 10800 },
    ["OH58D"] = { false, false, 0, 0, 14, 400 },
}

for unitType, v in pairs(CTLDUnitCapabilities) do
    Foothold_ctld:SetUnitCapabilities(unitType, v[1], v[2], v[3], v[4], v[5], v[6])
end

---------------------------------------------------------------------------
-- CTLD: Zones
---------------------------------------------------------------------------

-- ZONES

Foothold_ctld:AddCTLDZone("Tarawa",CTLD.CargoZoneType.SHIP,SMOKECOLOR.Blue,true,false,250,25)
Foothold_ctld:AddCTLDZone("Khasab Tarawa",CTLD.CargoZoneType.SHIP,SMOKECOLOR.Blue,true,false,250,25)
Foothold_ctld:AddCTLDZone("HMS Invincible",CTLD.CargoZoneType.SHIP,SMOKECOLOR.Blue,true,false,210,24)
Foothold_ctld:AddCTLDZone("CVN-72",CTLD.CargoZoneType.SHIP,SMOKECOLOR.Blue,true,false,330,35)
Foothold_ctld:AddCTLDZone("CVN-73",CTLD.CargoZoneType.SHIP,SMOKECOLOR.Blue,true,false,330,35)
Foothold_ctld:AddCTLDZone("CVN-74",CTLD.CargoZoneType.SHIP,SMOKECOLOR.Blue,true,false,330,35)
Foothold_ctld:AddCTLDZone("CVN-59",CTLD.CargoZoneType.SHIP,SMOKECOLOR.Blue,true,false,325,35)
Foothold_ctld:AddCTLDZone("FOB ALPHA",CTLD.CargoZoneType.SHIP,SMOKECOLOR.Blue,true,false,250,25)

for _, zoneObj in ipairs(bc:getZones()) do
    local zoneName = zoneObj.zone
    if not zoneName:lower():find("hidden") and not zoneName:lower():find("carrier") and not zoneName:lower():find("fob alpha") then
        Foothold_ctld:AddCTLDZone(zoneName, CTLD.CargoZoneType.LOAD, SMOKECOLOR.Green, false, false)
        Foothold_ctld:AddCTLDZone(zoneName, CTLD.CargoZoneType.MOVE, SMOKECOLOR.Green, true, false)
    end
end

function addCTLDZonesForBlueControlled(zoneName)
    if zoneName then
        local zoneObj = bc:getZoneByName(zoneName)
        if zoneObj and not zoneName:lower():find("hidden") and not zoneName:lower():find("dropzone") and not 
            zoneName:lower():find("carrier") and not zoneName:lower():find("fob alpha") then
            if zoneObj.wasBlue then
                --env.info("Activating LOAD for zone: " .. tostring(zoneName))
                Foothold_ctld:ActivateZone(zoneName, CTLD.CargoZoneType.LOAD)
                Foothold_ctld:DeactivateZone(zoneName, CTLD.CargoZoneType.MOVE)
            else
                --env.info("Activating MOVE for zone: " .. tostring(zoneName))
                Foothold_ctld:DeactivateZone(zoneName, CTLD.CargoZoneType.LOAD)
                Foothold_ctld:ActivateZone(zoneName, CTLD.CargoZoneType.MOVE)
            end
        end
    else
        for _, zoneObj in ipairs(bc:getZones()) do
            local zName = zoneObj.zone
            if not zName:lower():find("hidden") and not zName:lower():find("carrier") and not zName:lower():find("fob alpha") then
                if zoneObj.wasBlue then
                    --BASE:I("Activating LOAD for zone: " .. tostring(zName))
                    Foothold_ctld:ActivateZone(zName, CTLD.CargoZoneType.LOAD)
                    Foothold_ctld:DeactivateZone(zName, CTLD.CargoZoneType.MOVE)
                else
                    --BASE:I("Activating MOVE for zone: " .. tostring(zName))
                    Foothold_ctld:DeactivateZone(zName, CTLD.CargoZoneType.LOAD)
                    Foothold_ctld:ActivateZone(zName, CTLD.CargoZoneType.MOVE)
                end
            end
        end
    end
end

local scheduler = SCHEDULER:New(nil, function()
    addCTLDZonesForBlueControlled()
end, {}, 5)

---------------------------------------------------------------------------
-- Warehouse + Zone Supply System
---------------------------------------------------------------------------

local TroopUnits = {}
local GroundUnits = {}
deployedTroopsSet = SET_GROUP:New()
zoneCaptureInfo = {}
deployedTroops = {}
local zoneSupplyCrates = {}

local IRIS_SYSTEM_CARGO_NAME = "IRIS T SLM System"
local IRIS_SYSTEM_TEMPLATE = "CTLD_CARGO_IRISTSLM_System"
local IRIS_ROLE_BY_CARGO_NAME = {
  ["IRIS T SLM LN"] = "LN",
  ["IRIS T SLM STR"] = "STR",
  ["IRIS T SLM C2"] = "C2",
  ["IRIS T LN Add-on"] = "LN",
  ["IRIS T STR Add-on"] = "STR",
  ["IRIS T C2 Add-on"] = "C2",
}
local IRIS_ROLE_BY_TEMPLATE_ID = {
  ["CTLD_CARGO_IRISTSLM-LN"] = "LN",
  ["CTLD_CARGO_IRISTSLM_STR"] = "STR",
  ["CTLD_CARGO_IRISTSLM_C2"] = "C2",
}
local IRIS_ROLE_TO_UNITTYPE = {
  LN = "CHAP_IRISTSLM_LN",
  STR = "CHAP_IRISTSLM_STR",
  C2 = "CHAP_IRISTSLM_CP",
}
local IRIS_BASELINE_COUNTS = { LN = 1, STR = 1, C2 = 1 }
local IRIS_MERGE_DISTANCE = 400
local IRIS_MERGE_SLOT_COUNT = 6
local IRIS_MERGE_BASE_RADIUS = 90
local IRIS_MERGE_RING_STEP = 35
IRIS_RESTORE_UNIT_HEALTH_ON_MERGE = IRIS_RESTORE_UNIT_HEALTH_ON_MERGE or false

local LoadIRISAugments = function() return {} end
local ApplyIRISAugments = function() return false end
local RunIrisOnePassStandaloneMerge = function() return false end

local function getIrisSlotPosition(ax, ay, slotIndex)
  local index = slotIndex or 1
  local ring = math.floor((index - 1) / IRIS_MERGE_SLOT_COUNT)
  local spoke = (index - 1) % IRIS_MERGE_SLOT_COUNT
  local angle = math.rad(spoke * (360 / IRIS_MERGE_SLOT_COUNT))
  local radius = IRIS_MERGE_BASE_RADIUS + (ring * IRIS_MERGE_RING_STEP)
  return ax + math.cos(angle) * radius, ay + math.sin(angle) * radius
end

local function samMergeSpreadLnHeadings(profile, units, baseHeading)
  if not profile or type(units) ~= "table" then return end
  local lnType = profile.role_to_unittype and profile.role_to_unittype.LN or nil
  if not lnType then return end

  local lnUnits = {}
  for _, unit in ipairs(units) do
    if unit and unit.type == lnType then
      lnUnits[#lnUnits + 1] = unit
    end
  end

  local count = #lnUnits
  if count == 0 then return end
  local step = (2 * math.pi) / count
  local base = tonumber(baseHeading) or 0
  for idx, unit in ipairs(lnUnits) do
    local heading = math.fmod(base + ((idx - 1) * step), 2 * math.pi)
    unit.heading = heading
    unit.psi = heading
  end
end

local function reflowIrisTemplateLayout(profile, systemTemplate, anchorUnit)
  if not systemTemplate or type(systemTemplate.units) ~= "table" or #systemTemplate.units == 0 then
    return false
  end

  local units = systemTemplate.units
  local anchor = anchorUnit or units[1]
  local ax = (anchor and anchor.x) or systemTemplate.x or 0
  local ay = (anchor and anchor.y) or systemTemplate.y or 0
  local ah = (anchor and (anchor.heading or anchor.psi)) or 0

  if units[1] then
    units[1].x = ax
    units[1].y = ay
    units[1].heading = units[1].heading or ah
    units[1].psi = units[1].psi or units[1].heading or ah
    units[1].unitId = nil
    units[1].groupId = nil
  end

  for i = 2, #units do
    local unit = units[i]
    if unit then
      local px, py = getIrisSlotPosition(ax, ay, i - 1)
      unit.x = px
      unit.y = py
      unit.heading = unit.heading or ah
      unit.psi = unit.psi or unit.heading or ah
      unit.unitId = nil
      unit.groupId = nil
    end
  end

  samMergeSpreadLnHeadings(profile, units, ah)

  return true
end

local function removeGroundUnitEntryByName(groupName)
  if not groupName then return end
  for i = #GroundUnits, 1, -1 do
    local entry = GroundUnits[i]
    if entry and entry.groupName == groupName then
      table.remove(GroundUnits, i)
    end
  end
end

local function findCrateCargoNameByTemplate(self, templateId, fallbackName)
  if not self or type(self.Cargo_Crates) ~= "table" then
    return fallbackName
  end

  for _, cargoData in pairs(self.Cargo_Crates) do
    local templates = cargoData and cargoData.Templates or nil
    if type(templates) == "string" then
      templates = { templates }
    end
    if type(templates) == "table" then
      for _, tplName in pairs(templates) do
        if tplName == templateId then
          if cargoData.GetName then
            return cargoData:GetName()
          end
          return cargoData.Name or fallbackName
        end
      end
    end
  end

  return fallbackName
end

local function samMergeResolveRefundCargo(self, profile, role)
  if not self or not profile or not role then
    return nil, nil, nil
  end

  local templateIds = {}
  for templateId, mappedRole in pairs(profile.role_by_template_id or {}) do
    if mappedRole == role then
      templateIds[#templateIds + 1] = templateId
    end
  end

  table.sort(templateIds)

  for _, templateId in ipairs(templateIds) do
    local cargoName = findCrateCargoNameByTemplate(self, templateId, nil)
    if cargoName then
      local cargoObj = self:_FindCratesCargoObject(cargoName)
      if cargoObj then
        return cargoObj, cargoName, templateId
      end
    end
  end

  return nil, nil, templateIds[1]
end

local function removeDroppedTroopGroupByName(self, groupName)
  if not self or not groupName or type(self.DroppedTroops) ~= "table" then return end
  for idx, grp in pairs(self.DroppedTroops) do
    if grp and grp.GetName and grp:GetName() == groupName then
      self.DroppedTroops[idx] = nil
    end
  end
end

local function trackDroppedTroopGroup(self, grp)
  if not self or not grp then return end
  self.DroppedTroops = self.DroppedTroops or {}
  self.TroopCounter = (self.TroopCounter or 0) + 1
  self.DroppedTroops[self.TroopCounter] = grp
end

local SAM_MERGE_PROFILE_ORDER = { "IRIS", "HAWK", "NASAMS" }
local SAM_MERGE_PROFILES = {
  IRIS = {
    key = "IRIS",
    display_name = "IRIS",
    log_prefix = "[IRIS-MERGE]",
    system_template = IRIS_SYSTEM_TEMPLATE,
    system_cargo_names = { "IRIS T System", IRIS_SYSTEM_CARGO_NAME },
    role_order = { "STR", "LN", "C2" },
    role_by_cargo_name = IRIS_ROLE_BY_CARGO_NAME,
    role_by_template_id = IRIS_ROLE_BY_TEMPLATE_ID,
    role_to_unittype = IRIS_ROLE_TO_UNITTYPE,
    baseline_counts = IRIS_BASELINE_COUNTS,
  },
  HAWK = {
    key = "HAWK",
    display_name = "HAWK",
    log_prefix = "[HAWK-MERGE]",
    system_template = "CTLD_CARGO_HAWKSite",
    system_cargo_names = { "HAWK System", "HAWK Site" },
    role_order = { "TR", "SR", "LN", "PCP", "CWAR" },
    role_by_cargo_name = {
      ["Hawk TR Add-on"] = "TR",
      ["Hawk SR Add-on"] = "SR",
      ["Hawk LN Add-on"] = "LN",
    },
    role_by_template_id = {
      ["CTLD_CARGO_HAWKSite_TR"] = "TR",
      ["CTLD_CARGO_HAWKSite_SR"] = "SR",
      ["CTLD_CARGO_HAWKSite_LN"] = "LN",
    },
    role_to_unittype = {
      TR = "Hawk tr",
      SR = "Hawk sr",
      LN = "Hawk ln",
      PCP = "Hawk pcp",
      CWAR = "Hawk cwar",
    },
    baseline_counts = { TR = 1, SR = 1, LN = 2, PCP = 1, CWAR = 1 },
  },
  NASAMS = {
    key = "NASAMS",
    display_name = "NASAMS",
    log_prefix = "[NASAMS-MERGE]",
    system_template = "CTLD_CARGO_NasamsSite",
    system_cargo_names = { "NASAMS System", "Nasam Site" },
    role_order = { "SR", "C2", "LN" },
    role_by_cargo_name = {
      ["NASAMS C2 Add-on"] = "C2",
      ["NASAMS SR Add-on"] = "SR",
      ["NASAMS LN Add-on"] = "LN",
    },
    role_by_template_id = {
      ["CTLD_CARGO_NasamsSite_C2"] = "C2",
      ["CTLD_CARGO_NasamsSite_SR"] = "SR",
      ["CTLD_CARGO_NasamsSite_LN"] = "LN",
    },
    role_to_unittype = {
      C2 = "NASAMS_Command_Post",
      SR = "NASAMS_Radar_MPQ64F1",
      LN = "NASAMS_LN_C",
    },
    baseline_counts = { C2 = 1, SR = 1, LN = 2 },
  },
}

local function samMergeRoleCountTable(profile)
  local counts = {}
  for _, role in ipairs(profile.role_order or {}) do
    counts[role] = 0
  end
  return counts
end

local function samMergeSystemCargoMatches(profile, cargoName)
  local name = tostring(cargoName or "")
  for _, candidate in ipairs(profile.system_cargo_names or {}) do
    if name == tostring(candidate or "") then
      return true
    end
  end
  return false
end

local function samMergeRoleFromTemplateId(profile, text)
  local haystack = tostring(text or "")
  for templateId, role in pairs(profile.role_by_template_id or {}) do
    if string.find(haystack, templateId, 1, true) then
      return role
    end
  end
  return nil
end

local function samMergeRoleFromUnitType(profile, typeName)
  for role, unitType in pairs(profile.role_to_unittype or {}) do
    if typeName == unitType then
      return role
    end
  end
  return nil
end

local function samMergeIsSystemTemplateText(profile, text)
  local value = tostring(text or "")
  local base = tostring(profile.system_template or "")
  if base == "" then return false end
  if value == base then return true end
  if string.sub(value, 1, #base) ~= base then return false end
  local suffix = string.sub(value, #base + 1, #base + 1)
  return suffix == "-" or suffix == "#" or suffix == ""
end

local function samMergeProfileByKey(profileKey)
  if type(profileKey) ~= "string" then return nil end
  return SAM_MERGE_PROFILES[profileKey]
end

local function samMergeLog(self, profile, message)
  local prefix = (profile and profile.log_prefix) or "[SAM-MERGE]"
  local text = string.format("%s %s", prefix, tostring(message))
  if self and self.I then
    self:I(text)
  else
    env.info(text)
  end
end

local function samMergeIsSystemGroupName(profile, groupName)
  if type(groupName) ~= "string" then return false end
  return samMergeIsSystemTemplateText(profile, groupName)
end

local function samMergeResolveComponentProfileRole(vehicleGroup, cargoName)
  local role = nil

  if vehicleGroup and vehicleGroup.GetName then
    local groupName = vehicleGroup:GetName()
    for _, profileKey in ipairs(SAM_MERGE_PROFILE_ORDER) do
      local profile = SAM_MERGE_PROFILES[profileKey]
      if samMergeIsSystemGroupName(profile, groupName) then
        return nil, nil
      end
    end
    for _, profileKey in ipairs(SAM_MERGE_PROFILE_ORDER) do
      local profile = SAM_MERGE_PROFILES[profileKey]
      role = samMergeRoleFromTemplateId(profile, groupName)
      if role then
        return profile, role
      end
    end
  end

  if vehicleGroup and vehicleGroup.GetTemplate then
    local template = vehicleGroup:GetTemplate()
    if template then
      for _, profileKey in ipairs(SAM_MERGE_PROFILE_ORDER) do
        local profile = SAM_MERGE_PROFILES[profileKey]
        role = samMergeRoleFromTemplateId(profile, template.name)
        if role then
          return profile, role
        end
      end

      if type(template.units) == "table" then
        for _, unit in ipairs(template.units) do
          local unitType = unit and unit.type or nil
          for _, profileKey in ipairs(SAM_MERGE_PROFILE_ORDER) do
            local profile = SAM_MERGE_PROFILES[profileKey]
            role = samMergeRoleFromUnitType(profile, unitType)
            if role then
              return profile, role
            end
          end
        end
      end
    end
  end

  for _, profileKey in ipairs(SAM_MERGE_PROFILE_ORDER) do
    local profile = SAM_MERGE_PROFILES[profileKey]
    if samMergeSystemCargoMatches(profile, cargoName) then
      return nil, nil
    end
  end

  for _, profileKey in ipairs(SAM_MERGE_PROFILE_ORDER) do
    local profile = SAM_MERGE_PROFILES[profileKey]
    role = profile.role_by_cargo_name and profile.role_by_cargo_name[tostring(cargoName or "")] or nil
    if role then
      return profile, role
    end
  end

  return nil, nil
end

local function samMergeCountRolesInTemplate(profile, template)
  local counts = samMergeRoleCountTable(profile)
  if not template or type(template.units) ~= "table" then return counts end
  for _, unit in ipairs(template.units) do
    local role = samMergeRoleFromUnitType(profile, unit and unit.type or nil)
    if role then
      counts[role] = (counts[role] or 0) + 1
    end
  end
  return counts
end

local function samMergeCountRolesInGroup(profile, group)
  local counts = samMergeRoleCountTable(profile)
  if not group or not group.IsAlive or not group:IsAlive() then return counts end
  local units = group:GetUnits() or {}
  for _, unit in ipairs(units) do
    local role = samMergeRoleFromUnitType(profile, unit and unit.GetTypeName and unit:GetTypeName() or nil)
    if role then
      counts[role] = (counts[role] or 0) + 1
    end
  end
  return counts
end

local function samMergeGetBaseTemplate(profile, systemGroup)
  if not systemGroup then
    return nil, nil, "system group missing"
  end

  local template = systemGroup:GetTemplate()
  if not template or type(template.units) ~= "table" then
    return nil, nil, "system template missing units"
  end

  if IRIS_RESTORE_UNIT_HEALTH_ON_MERGE then
    return template, "restore-health", nil
  end

  local aliveCounts = samMergeCountRolesInGroup(profile, systemGroup)
  local aliveTotal = 0
  for _, role in ipairs(profile.role_order or {}) do
    aliveTotal = aliveTotal + (aliveCounts[role] or 0)
  end
  if aliveTotal <= 0 then
    return nil, "preserve-alive-composition", "no alive units in system to merge onto"
  end

  local keptCounts = samMergeRoleCountTable(profile)
  local trimmedUnits = {}

  for _, unit in ipairs(template.units) do
    local role = samMergeRoleFromUnitType(profile, unit and unit.type or nil)
    if not role then
      trimmedUnits[#trimmedUnits + 1] = unit
    else
      local keepMax = aliveCounts[role] or 0
      if (keptCounts[role] or 0) < keepMax then
        keptCounts[role] = (keptCounts[role] or 0) + 1
        trimmedUnits[#trimmedUnits + 1] = unit
      end
    end
  end

  if #trimmedUnits == 0 then
    return nil, "preserve-alive-composition", "no alive units in system to merge onto"
  end

  template.units = trimmedUnits
  return template, "preserve-alive-composition", nil
end

local function samMergeExtractUnitTemplateForRole(profile, groupTemplate, role)
  if not groupTemplate or type(groupTemplate.units) ~= "table" then return nil end
  local wantedType = profile.role_to_unittype and profile.role_to_unittype[role] or nil
  local fallback = nil
  for _, unit in ipairs(groupTemplate.units) do
    if not fallback and unit then
      fallback = UTILS.DeepCopy(unit)
    end
    if wantedType and unit and unit.type == wantedType then
      return UTILS.DeepCopy(unit)
    end
  end
  return fallback
end

local function samMergeAppendUnitTemplateWithOffset(profile, systemTemplate, unitTemplate, anchorUnit, idx)
  if not systemTemplate or not unitTemplate then return nil end
  systemTemplate.units = systemTemplate.units or {}
  if type(systemTemplate.units) ~= "table" then return nil end

  local clone = UTILS.DeepCopy(unitTemplate)
  local index = idx or 1
  local ax = (anchorUnit and anchorUnit.x) or systemTemplate.x or 0
  local ay = (anchorUnit and anchorUnit.y) or systemTemplate.y or 0

  clone.x, clone.y = getIrisSlotPosition(ax, ay, index)
  clone.heading = (anchorUnit and anchorUnit.heading) or clone.heading or 0
  clone.psi = (anchorUnit and anchorUnit.psi) or clone.psi
  clone.name = string.format("%s-%d", tostring(profile.system_template or "CTLD_CARGO_SAM"), math.random(100000, 999999))
  clone.unitId = nil
  clone.groupId = nil

  table.insert(systemTemplate.units, clone)
  return clone
end

local function samMergeSpawnMergedSystemTemplate(profile, template, preferredName)
  if not template or type(template) ~= "table" then
    return nil, "template missing"
  end
  if type(template.units) ~= "table" or #template.units == 0 then
    return nil, "template has no units"
  end

  local spawnName = preferredName or string.format("%s-%d", tostring(profile.system_template or "CTLD_CARGO_SAM"), math.random(100000, 999999))
  local tpl = UTILS.DeepCopy(template)
  tpl.name = spawnName
  tpl.groupId = nil

  local spawner = SPAWN:NewFromTemplate(tpl, spawnName, nil, true)
  if not spawner then
    return nil, "SPAWN:NewFromTemplate failed"
  end
  local grp = spawner:Spawn()
  if not grp then
    return nil, "spawn returned nil"
  end
  return grp
end

local function samMergeSyncGroundUnits(self, profile, oldSystemName, oldComponentName, newSystemName)
  if type(newSystemName) ~= "string" or newSystemName == "" then return end

  removeGroundUnitEntryByName(oldSystemName)
  removeGroundUnitEntryByName(oldComponentName)
  removeGroundUnitEntryByName(newSystemName)

  local fallbackCargoName = profile.system_cargo_names and profile.system_cargo_names[1] or nil
  local systemCargoName = findCrateCargoNameByTemplate(self, profile.system_template, fallbackCargoName)
  local cargoObject = self and self._FindCratesCargoObject and self:_FindCratesCargoObject(systemCargoName) or nil
  local currentStock = cargoObject and cargoObject:GetStock() or 0
  table.insert(GroundUnits, {
    groupName = newSystemName,
    Timestamp = timer.getTime(),
    CargoName = systemCargoName,
    Stock = currentStock,
  })
end

local function samMergeFindNearestSystemGroup(profile, coord, maxDist)
  if not coord then return nil, nil end
  local searchRadius = maxDist or IRIS_MERGE_DISTANCE
  if searchRadius <= 0 then searchRadius = IRIS_MERGE_DISTANCE end

  local nearestGroup = nil
  local nearestDist = nil
  local seen = {}

  for _, entry in ipairs(GroundUnits) do
    local gname = entry and entry.groupName or nil
    if gname and not seen[gname] and (samMergeSystemCargoMatches(profile, entry and entry.CargoName or nil) or samMergeIsSystemGroupName(profile, gname)) then
      seen[gname] = true
      local grp = GROUP:FindByName(gname)
      if grp and grp:IsAlive() then
        local gCoord = grp:GetCoordinate()
        if gCoord then
          local dist = coord:Get2DDistance(gCoord)
          if dist <= searchRadius and (not nearestDist or dist < nearestDist) then
            nearestGroup = grp
            nearestDist = dist
          end
        end
      end
    end
  end

  if nearestGroup then
    return nearestGroup, nearestDist
  end

  local tmpZoneName = string.format("%s_MERGE_SCAN_%d", tostring(profile.key or "SAM"), math.random(1, 1000000))
  local nearby = SET_GROUP:New()
    :FilterCoalitions("blue")
    :FilterZones({ ZONE_RADIUS:New(tmpZoneName, coord:GetVec2(), searchRadius, false) })
    :FilterOnce()
  for _, grp in pairs(nearby.Set or {}) do
    if grp and grp:IsAlive() and samMergeIsSystemGroupName(profile, grp:GetName()) then
      local gCoord = grp:GetCoordinate()
      if gCoord then
        local dist = coord:Get2DDistance(gCoord)
        if dist <= searchRadius and (not nearestDist or dist < nearestDist) then
          nearestGroup = grp
          nearestDist = dist
        end
      end
    end
  end

  return nearestGroup, nearestDist
end

local function samMergeTryMergeComponentIntoNearbySystem(self, Group, Vehicle, cargoName, roleHint, profileHint, mergeDistanceOverride)
  local profile = profileHint
  local role = roleHint
  if not profile or not role then
    local resolvedProfile, resolvedRole = samMergeResolveComponentProfileRole(Vehicle, cargoName)
    profile = profile or resolvedProfile
    role = role or resolvedRole
  end
  if not profile or not role then
    return false
  end

  if not Vehicle or not Vehicle.IsAlive or not Vehicle:IsAlive() then
    samMergeLog(self, profile, "Build vehicle is not alive, merge skipped.")
    return false
  end

  local buildCoord = Vehicle:GetCoordinate()
  if not buildCoord then
    samMergeLog(self, profile, "Build vehicle has no coordinate, merge skipped.")
    return false
  end

  local mergeDist = mergeDistanceOverride or IRIS_MERGE_DISTANCE
  if mergeDist <= 0 then mergeDist = IRIS_MERGE_DISTANCE end
  local systemGroup, systemDist = samMergeFindNearestSystemGroup(profile, buildCoord, mergeDist)
  if not systemGroup then
    samMergeLog(self, profile, string.format("No nearby system anchor for %s (role=%s).", tostring(cargoName), tostring(role)))
    return false
  end

  local systemName = systemGroup:GetName()
  local componentName = Vehicle:GetName() or "unknown"
  if componentName == systemName then
    samMergeLog(self, profile, "Component group equals system group name, merge skipped.")
    return false
  end

  local systemTemplate, mergeMode, baseErr = samMergeGetBaseTemplate(profile, systemGroup)
  local componentTemplate = Vehicle:GetTemplate()
  if not systemTemplate or not componentTemplate then
    samMergeLog(self, profile, string.format("Missing template for system/component, merge skipped. mode=%s err=%s", tostring(mergeMode), tostring(baseErr)))
    if Group then messageCtldToGroup(Group, "CTLD_SAM_MERGE_FAILED_MISSING_TEMPLATE", 10, tostring(profile.display_name or "SAM")) end
    return false
  end

  local sourceUnit = samMergeExtractUnitTemplateForRole(profile, componentTemplate, role)
  if not sourceUnit then
    samMergeLog(self, profile, "No component unit template found for role " .. tostring(role))
    if Group then messageCtldToGroup(Group, "CTLD_SAM_MERGE_FAILED_NO_COMPONENT", 10, tostring(profile.display_name or "SAM")) end
    return false
  end

  local nextIndex = (systemTemplate.units and #systemTemplate.units or 0) + 1
  local anchorUnit = systemTemplate.units and systemTemplate.units[1] or nil
  if not samMergeAppendUnitTemplateWithOffset(profile, systemTemplate, sourceUnit, anchorUnit, nextIndex) then
    samMergeLog(self, profile, "Failed to append merged unit template.")
    if Group then messageCtldToGroup(Group, "CTLD_SAM_MERGE_FAILED_APPEND", 10, tostring(profile.display_name or "SAM")) end
    return false
  end
  reflowIrisTemplateLayout(profile, systemTemplate, anchorUnit)

  local newSystemName = string.format("%s-%d", tostring(profile.system_template or "CTLD_CARGO_SAM"), math.random(100000, 999999))
  local mergedGroup, err = samMergeSpawnMergedSystemTemplate(profile, systemTemplate, newSystemName)
  if not mergedGroup then
    samMergeLog(self, profile, string.format("Spawn merged system failed: %s", tostring(err)))
    if Group then messageCtldToGroup(Group, "CTLD_SAM_MERGE_FAILED_SPAWN", 10, tostring(profile.display_name or "SAM")) end
    return false
  end

  if systemGroup and systemGroup:IsAlive() then systemGroup:Destroy() end
  if Vehicle and Vehicle:IsAlive() then Vehicle:Destroy() end

  removeDroppedTroopGroupByName(self, systemName)
  removeDroppedTroopGroupByName(self, componentName)
  trackDroppedTroopGroup(self, mergedGroup)

  local mergedName = mergedGroup:GetName() or newSystemName
  samMergeSyncGroundUnits(self, profile, systemName, componentName, mergedName)

  samMergeLog(self, profile, string.format("Merged role=%s from %s into %s (dist=%.1f). New group=%s mode=%s",
    tostring(role), tostring(componentName), tostring(systemName), systemDist or -1, tostring(mergedName), tostring(mergeMode)))
  if Group then
    messageCtldToGroup(Group, "CTLD_SAM_MERGE_COMPLETE", 10, tostring(profile.display_name or "SAM"), tostring(role))
  end
  return true
end

local function cargoTypeCanCaptureZone(cargoType)
    if cargoType == CTLD_CARGO.Enum.TROOPS then return true end
    if CaptureZoneWithEngineer and cargoType == CTLD_CARGO.Enum.ENGINEERS then return true end
    return false
end

local function getCargoTypeByName(cargoName)
    if type(cargoName) ~= "string" then return nil end
    for _, cargoData in pairs(Foothold_ctld.Cargo_Troops or {}) do
        if cargoData and cargoData.GetName and cargoData:GetName() == cargoName then
            return cargoData.CargoType
        end
    end
    return nil
end


---------------------------------------------------------------------------
-- Warehouse: Supply Bundles
---------------------------------------------------------------------------


local WAREHOUSE_SUPPLY_TYPES = {
  ["10 of everything CH-47"]              = { categories = { "AG_MISSILES","AG_ROCKETS","AG_BOMBS","AG_GUIDED_BOMBS","AA_MISSILES","MISC","FUEL_TANKS"}, amount = 10, reward = 150, label = "10 of everything" },
  ["10 of everything MI-8"]               = { categories = { "AG_MISSILES","AG_ROCKETS","AG_BOMBS","AG_GUIDED_BOMBS","AA_MISSILES","MISC","FUEL_TANKS"}, amount = 10, reward = 150, label = "10 of everything" },
  ["10 of everything Blackhawk"]          = { categories = { "AG_MISSILES","AG_ROCKETS","AG_BOMBS","AG_GUIDED_BOMBS","AA_MISSILES","MISC","FUEL_TANKS"}, amount = 10, reward = 150, label = "10 of everything" },
  ["10 A/A Missiles"]                     = { categories = { "AA_MISSILES" },                 amount = 10, reward = 30, label = "10 A/A Missiles" },
  ["10 A/G Missiles"]                     = { categories = { "AG_MISSILES" },                 amount = 10, reward = 30, label = "10 A/G Missiles" },
  ["10 A/G Rockets"]                      = { categories = { "AG_ROCKETS" },                  amount = 10, reward = 30, label = "10 A/G Rockets" },
  ["10 A/G Bombs"]                        = { categories = { "AG_GUIDED_BOMBS" ,"AG_BOMBS"},  amount = 10, reward = 30, label = "10 A/G Bombs" },
  ["10 (Plane fuel tanks) and pylons"]    = { categories = { "FUEL_TANKS","MISC"},            amount = 10, reward = 30, label = "10 (Plane fuel tanks) and pylons" },
  
  ["50 of everything"]                    = { categories = { "AG_MISSILES","AG_ROCKETS","AG_BOMBS","AG_GUIDED_BOMBS","AA_MISSILES","MISC","FUEL_TANKS" }, amount = 50, reward = 150, label = "50 of everything" },
  ["50 A/A Missiles"]                     = { categories = { "AA_MISSILES" },        amount = 50, reward = 50, label = "50 A/A Missiles" },
  ["50 A/G Missiles"]                     = { categories = { "AG_MISSILES" },        amount = 50, reward = 30, label = "50 A/G Missiles" },
  ["50 A/G Rockets"]                      = { categories = { "AG_ROCKETS" },         amount = 50, reward = 30, label = "50 A/G Rockets" },
  ["50 A/G Bombs"]                        = { categories = { "AG_GUIDED_BOMBS", "AG_BOMBS" },    amount = 50, reward = 30, label = "50 A/G Bombs" },
  ["50 Plane fuel-tanks and pylons"]      = { categories = {"FUEL_TANKS", "MISC" },  amount = 50, reward = 30, label = "50 Plane fuel-tanks and pylons" },

  ["25 of everything"]                    = { categories = { "AG_MISSILES","AG_ROCKETS","AG_BOMBS","AG_GUIDED_BOMBS","AA_MISSILES","MISC","FUEL_TANKS" }, amount = 25, reward = 75, label = "25 of everything" },
  ["25 A/A Missiles"]                     = { categories = { "AA_MISSILES" },        amount = 25, reward = 25, label = "25 A/A Missiles" },
  ["25 A/G Missiles"]                     = { categories = { "AG_MISSILES" },        amount = 25, reward = 15, label = "25 A/G Missiles" },
  ["25 A/G Rockets"]                      = { categories = { "AG_ROCKETS" },         amount = 25, reward = 15, label = "25 A/G Rockets" },
  ["25 A/G Bombs"]                        = { categories = { "AG_GUIDED_BOMBS", "AG_BOMBS" },    amount = 25, reward = 15, label = "25 A/G Bombs" },
  ["25 Plane fuel-tanks and pylons"]      = { categories = {"FUEL_TANKS", "MISC" },  amount = 25, reward = 15, label = "25 Plane fuel-tanks and pylons" },
  ["10 Modded weapons"]                   = { categories = { "MODS" }, amount = 10, reward = 30, label = "10 Modded weapons" },
  ["25 Modded weapons"]                   = { categories = { "MODS" }, amount = 25, reward = 15, label = "25 Modded weapons" },
  ["50 Modded weapons"]                   = { categories = { "MODS" }, amount = 50, reward = 30, label = "50 Modded weapons" },
}

if AllowMods then
  WAREHOUSE_SUPPLY_TYPES["10 Mods"] = { categories = { "MODS" }, amount = 10, reward = 30, label = "10 Mods" }
  WAREHOUSE_SUPPLY_TYPES["25 Mods"] = { categories = { "MODS" }, amount = 25, reward = 15, label = "25 Mods" }
  WAREHOUSE_SUPPLY_TYPES["50 Mods"] = { categories = { "MODS" }, amount = 50, reward = 30, label = "50 Mods" }

  table.insert(WAREHOUSE_SUPPLY_TYPES["10 of everything CH-47"].categories, "MODS")
  table.insert(WAREHOUSE_SUPPLY_TYPES["10 of everything MI-8"].categories, "MODS")
  table.insert(WAREHOUSE_SUPPLY_TYPES["10 of everything Blackhawk"].categories, "MODS")
  table.insert(WAREHOUSE_SUPPLY_TYPES["25 of everything"].categories, "MODS")
  table.insert(WAREHOUSE_SUPPLY_TYPES["50 of everything"].categories, "MODS")
end




---------------------------------------------------------------------------
-- Zone Supply: Settings
---------------------------------------------------------------------------


local ZONE_SUPPLY_AGL_THRESHOLD = 0.5
local ZONE_SUPPLY_CAPTURE_REWARD  = bc.rewards['Zone capture'] or 200
local ZONE_SUPPLY_UPGRADE_REWARD = bc.rewards['Zone upgrade'] or 100
local ZONE_SUPPLY_NOZONE_TTL = 600
local ZONE_SUPPLY_INACTIVE_TTL = 600
local ZONE_SUPPLY_DESTROY_DELAY = 60
local ZONE_SUPPLY_C130_LANDED_AGL = 10
local ZONE_SUPPLY_C130_ONESHOT_DELAY = 1
local ZONE_SUPPLY_C130_ONESHOT_MOVE_EPS2 = 0.25

local ZONE_SUPPLY_AIRCRAFT_DIMENSIONS = {
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

---------------------------------------------------------------------------
-- Zone Supply: Runtime State + Helpers
---------------------------------------------------------------------------

local zoneSupplyPendingRemoval = {}
local zoneSupplyCleanupScheduled = false
local warehouseSupplyItemCache = {}
local zoneStorageHandleCache = {}
local supplyZoneWrapperCache = {}
supplyZonesSet = {}

local WAREHOUSE_CATEGORY_MULTIPLIER = {
  ["AG_ROCKETS"] = 3,
}

local adjustWarehouseStockAtZone
local zoneSupplyDebug
local c130SupplyLogOnce
local getZoneSupplyStaticKey

local function isCtldSupplyZoneName(zoneName)
  if not zoneName then return false end
  if supplyZonesSet[zoneName] == true then return true end
  if supplyZones then
    for i = 1, #supplyZones do
      local n = supplyZones[i]
      supplyZonesSet[n] = true
    end
  end
  return supplyZonesSet[zoneName] == true
end

local function getSupplyZoneWrapper(name)
  local z = supplyZoneWrapperCache[name]
  if z == false then return nil end
  if z ~= nil then return z end
  z = ZONE:FindByName(name)
  supplyZoneWrapperCache[name] = z or false
  return z
end

---------------------------------------------------------------------------
-- C-130 Auto Build (Load/Unload)
---------------------------------------------------------------------------

local c130AutoBuildSets = {}
local c130AutoBuildCrates = {}
local C130_AUTO_AIRBORNE_AGL = 8
local C130_OWNER_RESOLVE_MAX3D = 250
local C130_OWNER_RESOLVE_MOVE2D = 10
local C130_OWNER_RESOLVE_NEAR2D = 4

local c130AutoBuildClientSet = SET_CLIENT:New():FilterAlive():FilterFunction(function(client)
  local t = client:GetTypeName()
  return t == "C-130J-30"
end):FilterStart()

local function resolveC130AutoBuildOwner(setId, vec3)
  local set = c130AutoBuildSets[setId]
  if not set then return end

  local pos = COORDINATE:NewFromVec3(vec3)
  local bestNearClient = nil
  local bestNear2D = math.huge
  local bestClient = nil
  local bestD = math.huge
  for _, cl in pairs(c130AutoBuildClientSet:GetAliveSet() or {}) do
    local clCoord = cl:GetCoordinate()
    local d2 = clCoord:Get2DDistance(pos)
    if d2 <= C130_OWNER_RESOLVE_NEAR2D and d2 < bestNear2D then
      bestNear2D = d2
      bestNearClient = cl
    end
    local d = clCoord:Get3DDistance(pos)
    if d < bestD then
      bestD = d
      bestClient = cl
    end
  end

  if bestNearClient then
    bestClient = bestNearClient
  else
    if not bestClient or bestD > C130_OWNER_RESOLVE_MAX3D then return end
  end

  local playerName = bestClient:GetPlayerName() or _DATABASE:_FindPlayerNameByUnitName(bestClient:GetName()) or "None"
  local groupName = bestClient:GetGroup():GetName()
  local unitName = bestClient:GetName()

  set.playerName = playerName
  set.groupName = groupName
  set.unitName = unitName
  for _, key in ipairs(set.crates) do
    local entry = c130AutoBuildCrates[key]
    if entry then
      entry.playerName = playerName
      entry.groupName = groupName
      entry.unitName = unitName
      entry._unitObj = nil
      entry._unitDim = nil
    end
  end
end



local function notifyC130Auto(set, key, ...)
  if set.groupName then
    local grp = GROUP:FindByName(set.groupName)
    if grp then
      local text = formatCtldForGroup(grp, key, ...)
      MESSAGE:New(text, 12):ToGroup(grp)
      return
    end
  end
  local text = L10N:Format(key, ...)
  MESSAGE:New(text, 12):ToBlue()
end

local function registerC130AutoBuildSet(groupName, playerName, unitName, pickupZone, cargoItems)
  local setId = string.format("C130AUTO-%s-%d", groupName or "GROUP", math.random(1, 1e9))
  local setData = {
    id = setId,
    groupName = groupName,
    playerName = playerName,
    unitName = unitName,
    pickupZone = pickupZone,
    crates = {},
    required = 0,
    completed = false,
  }

  for _, cargoItem in ipairs(cargoItems) do
    local cargoId = (cargoItem.GetID and cargoItem:GetID()) or cargoItem.ID
    local staticObj = (cargoItem.GetPositionable and cargoItem:GetPositionable()) or nil
    if cargoId and staticObj then
      c130AutoBuildCrates[cargoId] = {
        cargo = cargoItem,
        static = staticObj,
        pickupZone = pickupZone,
        setId = setId,
        cargoName = cargoItem.GetName and cargoItem:GetName() or "cargo",
        groupName = groupName,
        playerName = playerName,
        unitName = unitName,
        _unitObj = nil,
        _unitDim = nil,
        warnedPickup = false,
        wasAirborne = false,
        landed = false,
        detached = false,
        attached = false,
      }
      setData.required = setData.required + 1
      setData.crates[#setData.crates + 1] = cargoId
    end
  end

  if setData.required > 0 then
    c130AutoBuildSets[setId] = setData
  end
end

local function destroyC130AutoBuildCrate(entry, key, setId)
  if not entry then return false end
  local primary = (entry.cargo and entry.cargo.GetPositionable and entry.cargo:GetPositionable()) or entry.static
  local secondary = entry.static
  local destroyCallIssued = false
  local staticName = nil
  local function nameOf(obj)
    if not obj then return nil end
    if obj.GetName then return obj:GetName() end
    if obj.getName then return obj:getName() end
    return nil
  end
  local function tryDestroy(obj)
    if not obj then return false end
    if not staticName then staticName = nameOf(obj) end
    if obj.IsAlive and obj:IsAlive() then
      obj:Destroy(false)
      return true
    end
    return false
  end

  if tryDestroy(primary) then
    destroyCallIssued = true
  elseif tryDestroy(secondary) then
    destroyCallIssued = true
  else
    if not staticName then staticName = nameOf(primary) or nameOf(secondary) end
    if staticName and StaticObject and StaticObject.getByName then
      local dcsStatic = StaticObject.getByName(staticName)
      if dcsStatic and dcsStatic.destroy then
        dcsStatic:destroy()
        destroyCallIssued = true
      end
    end
  end

  local liveObj = (entry.cargo and entry.cargo.GetPositionable and entry.cargo:GetPositionable()) or entry.static
  local cargoIsAlive = liveObj and liveObj.IsAlive and liveObj:IsAlive() or false
  if (not cargoIsAlive) and staticName and StaticObject and StaticObject.getByName then
    local dcsStatic = StaticObject.getByName(staticName)
    if dcsStatic and dcsStatic.isExist and dcsStatic:isExist() then
      cargoIsAlive = true
    end
  end

  local outcome = "destroyed-now"
  if destroyCallIssued and cargoIsAlive then
    outcome = "destroy-requested-still-alive"
  elseif (not destroyCallIssued) and (not cargoIsAlive) then
    outcome = "already-removed"
  elseif (not destroyCallIssued) and cargoIsAlive then
    outcome = "still-alive"
  end

  env.info(string.format(
    "[FH-AUTOBUILD] cleanup set=%s key=%s outcome=%s destroyCallIssued=%s finalCargoAlive=%s name=%s",
    tostring(setId),
    tostring(key),
    tostring(outcome),
    tostring(destroyCallIssued),
    tostring(cargoIsAlive),
    tostring(staticName)
  ))
  return outcome
end

local function UpdateTrackedEntryMovement(Entry, CoordinatesVec3)
  local Moved = false
  if Entry._lastVec3 then
    local DeltaX = CoordinatesVec3.x - Entry._lastVec3.x
    local DeltaY = CoordinatesVec3.y - Entry._lastVec3.y
    local DeltaZ = CoordinatesVec3.z - Entry._lastVec3.z
    Moved = (DeltaX * DeltaX + DeltaY * DeltaY + DeltaZ * DeltaZ) > 0.25
    Entry._lastVec3.x = CoordinatesVec3.x
    Entry._lastVec3.y = CoordinatesVec3.y
    Entry._lastVec3.z = CoordinatesVec3.z
  else
    Entry._lastVec3 = { x = CoordinatesVec3.x, y = CoordinatesVec3.y, z = CoordinatesVec3.z }
  end
  return Moved
end

local function ResolveTrackedCarrierUnit(Entry, UseGroupFallback)
  local UnitObject = Entry._unitObj
  if (not UnitObject) and Entry.unitName then
    UnitObject = Unit.getByName(Entry.unitName)
    Entry._unitObj = UnitObject
    Entry._unitDim = nil
  elseif UnitObject and Entry.unitName and (UnitObject.isExist and not UnitObject:isExist()) then
    UnitObject = Unit.getByName(Entry.unitName)
    Entry._unitObj = UnitObject
    Entry._unitDim = nil
  end

  if UseGroupFallback and (not UnitObject) and Entry.groupName then
    local DcsGroup = Group.getByName(Entry.groupName)
    UnitObject = DcsGroup and DcsGroup:getUnit(1) or nil
    Entry._unitObj = UnitObject
    Entry._unitDim = nil
  end

  return UnitObject
end

local function ResolveTrackedCarrierDimensions(Entry, UnitObject)
  local UnitDimensions = Entry._unitDim
  if UnitObject and UnitObject.isExist and UnitObject:isExist() then
    if not UnitDimensions then
      UnitDimensions = ZONE_SUPPLY_AIRCRAFT_DIMENSIONS[UnitObject:getTypeName()]
      Entry._unitDim = UnitDimensions
    end
  end
  return UnitDimensions
end

local function UpdateC130AttachDetachState(Entry, Key, CoordinatesVec3, UnitObject, UnitDimensions)
  if not (UnitObject and UnitObject.isExist and UnitObject:isExist()) then return end
  if not UnitDimensions then return end

  local UnitPoint = UnitObject:getPoint()
  if not (UnitPoint and UnitPoint.x and UnitPoint.y and UnitPoint.z) then return end

  local DeltaX = UnitPoint.x - CoordinatesVec3.x
  local DeltaY = UnitPoint.y - CoordinatesVec3.y
  local DeltaZ = UnitPoint.z - CoordinatesVec3.z
  local Delta2D = DeltaX * DeltaX + DeltaZ * DeltaZ
  local Delta3D = math.sqrt(Delta2D + DeltaY * DeltaY)
  local InAir = UnitObject:inAir()
  local AttachDistance = UnitDimensions.attach or 8

  if Entry.detached and (not InAir) and Delta3D <= AttachDistance then
    Entry.detached = false
    Entry._loggedC130Detached = false
    Entry._loggedC130Unloaded = false
    Entry._c130Stable = 0
    Entry._c130OneShotScheduled = false
  elseif (not Entry.detached) and Delta3D > (UnitDimensions.detach or UnitDimensions.width) then
    Entry.detached = true
  end

  if Entry.detached and (InAir or CTLD_Logging) then
    c130SupplyLogOnce(Entry, Key, "_fhLogDetach", "DETACHED")
  end
end

local function ClearZoneSupplyLandingState(Entry, StaticObject)
  local RemovalKey = getZoneSupplyStaticKey(StaticObject)
  if RemovalKey then
    zoneSupplyPendingRemoval[RemovalKey] = nil
  end
  Entry.landedAt = nil
  Entry._noZoneRemovalScheduled = nil
  Entry._inactiveRemovalScheduled = nil
  Entry._lastNoZoneLog = nil
  Entry._lastInactiveLog = nil
end

local function BuildTrackedZoneSupplyEntry(CargoItem, StaticObject, PickupZoneName, GroupName, PlayerName, UnitName, CargoName, DeliveryType, WarehouseMeta, CarrierUnitObject)
  local InitialVec3 = nil
  if StaticObject then
    local InitialCoordinate = StaticObject:GetCoordinate()
    InitialVec3 = InitialCoordinate and InitialCoordinate:GetVec3() or nil
  end

  local UnitDimensions = nil
  if CarrierUnitObject and CarrierUnitObject.isExist and CarrierUnitObject:isExist() then
    UnitDimensions = ZONE_SUPPLY_AIRCRAFT_DIMENSIONS[CarrierUnitObject:getTypeName()]
  end
  local IsC130 = CarrierUnitObject and CarrierUnitObject.isExist and CarrierUnitObject:isExist() and CarrierUnitObject:getTypeName() == "C-130J-30"

  local EntryData = {
    cargo = CargoItem,
    static = StaticObject,
    pickupZone = PickupZoneName,
    groupName = GroupName,
    playerName = PlayerName,
    unitName = UnitName,
    _unitObj = CarrierUnitObject,
    _unitDim = UnitDimensions,
    _isC130 = IsC130,
    attached = false,
    detached = false,
    _c130Stable = 0,
    _loggedC130Attached = false,
    _loggedC130Detached = false,
    _loggedC130Unloaded = false,
    warnedSameZone = false,
    warnedNoNeed = false,
    deliveryType = DeliveryType,
    warehouseMeta = WarehouseMeta,
    cargoName = CargoName,
    wasAirborne = false,
    _wasUnloaded = false,
    _lastVec3 = InitialVec3 and { x = InitialVec3.x, y = InitialVec3.y, z = InitialVec3.z } or nil,
  }

  if DeliveryType == "warehouse" then
    EntryData.warnedWarehouseSide = false
  end

  return EntryData
end

local function RegisterTrackedSupplyCargo(CargoItem, PickupZoneName, GroupName, PlayerName, UnitName, CargoName, DeliveryType, WarehouseMeta, CarrierUnitObject)
  CargoItem._zoneSupplyPickupZone = PickupZoneName
  CargoItem._zoneSupplyGroupName = GroupName
  CargoItem._zoneSupplyPlayer = PlayerName

  local CargoIdentifier = (CargoItem.GetID and CargoItem:GetID()) or CargoItem.ID
  local StaticObject = (CargoItem.GetPositionable and CargoItem:GetPositionable()) or nil
  local TrackingKey = CargoIdentifier
  if not TrackingKey and StaticObject then
    TrackingKey = getZoneSupplyStaticKey(StaticObject)
  end

  if TrackingKey then
    if not zoneSupplyCrates[TrackingKey] then
      zoneSupplyCrates[TrackingKey] = BuildTrackedZoneSupplyEntry(
        CargoItem,
        StaticObject,
        PickupZoneName,
        GroupName,
        PlayerName,
        UnitName,
        CargoName,
        DeliveryType,
        WarehouseMeta,
        CarrierUnitObject
      )

      local StaticName = StaticObject and StaticObject.GetName and StaticObject:GetName() or "nil"
      if DeliveryType == "warehouse" then
        zoneSupplyDebug(string.format(
          "Tracking warehouse cargo key=%s cargoId=%s static=%s pickup=%s group=%s player=%s type=%s",
          tostring(TrackingKey), tostring(CargoIdentifier), tostring(StaticName), tostring(PickupZoneName), tostring(GroupName), tostring(PlayerName), tostring(CargoName)))
      else
        zoneSupplyDebug(string.format(
          "Tracking zone-supply key=%s cargoId=%s static=%s pickup=%s group=%s player=%s",
          tostring(TrackingKey), tostring(CargoIdentifier), tostring(StaticName), tostring(PickupZoneName), tostring(GroupName), tostring(PlayerName)))
      end
    end
  else
    if DeliveryType == "warehouse" then
      zoneSupplyDebug("OnAfterGetCrates: warehouse cargo without cargoId/static key")
    else
      zoneSupplyDebug("OnAfterGetCrates: zone supply without cargoId/static key")
    end
  end
end

local function EnforceMaxAtSpawnForTrackedUnits(TrackedUnits, MaxAtSpawnMap, RestockCallback)
  local UnitsByName = {}
  for _, TrackedEntry in ipairs(TrackedUnits) do
    local CargoName = TrackedEntry.CargoName
    UnitsByName[CargoName] = UnitsByName[CargoName] or {}
    table.insert(UnitsByName[CargoName], TrackedEntry)
  end

  for NormalizedName, GroupedEntries in pairs(UnitsByName) do
    table.sort(GroupedEntries, function(EntryA, EntryB) return EntryA.Timestamp > EntryB.Timestamp end)
    local MaxAllowed = MaxAtSpawnMap[NormalizedName] or MAX_AT_SPAWN[NormalizedName] or 0
    local TotalEntries = #GroupedEntries
    local ExcessEntries = TotalEntries - MaxAllowed
    for EntryIndex, EntryData in ipairs(GroupedEntries) do
      local Action = EntryIndex <= MaxAllowed and "KEEP" or "DELETE"
    end
    for ListIndex = TotalEntries, MaxAllowed + 1, -1 do
      local OldEntry = GroupedEntries[ListIndex]
      local ExistingGroup = GROUP:FindByName(OldEntry.groupName)
      if ExistingGroup and ExistingGroup:IsAlive() then ExistingGroup:Destroy() end
      RestockCallback(OldEntry.CargoName)
      for TrackedIndex, TrackedData in ipairs(TrackedUnits) do
        if TrackedData.groupName == OldEntry.groupName then
          table.remove(TrackedUnits, TrackedIndex)
          break
        end
      end
    end
  end
end

local function processC130AutoBuild()
  if not next(c130AutoBuildSets) then return end

for key, entry in pairs(c130AutoBuildCrates) do
  local staticObj = (entry.cargo and entry.cargo.GetPositionable and entry.cargo:GetPositionable()) or entry.static
  if staticObj then
    entry.static = staticObj
    entry._missingCount = 0
  end
  if not staticObj or not staticObj:IsAlive() then
    entry._missingCount = (entry._missingCount or 0) + 1
    if entry._missingCount >= 2 then
      c130AutoBuildCrates[key] = nil
      local set = c130AutoBuildSets[entry.setId]
      if set and not set.completed and not set.handoffStarted then
        set.failed = true
      end
    end
  else
      local coord = staticObj:GetCoordinate()
      local vec3 = coord and coord:GetVec3() or nil
      if vec3 then
        local set = c130AutoBuildSets[entry.setId]
        if set and not set.ownerResolved then
          if not entry.spawnVec3 then
            entry.spawnVec3 = vec3
          else
            local dx = vec3.x - entry.spawnVec3.x
            local dz = vec3.z - entry.spawnVec3.z
            if (dx * dx + dz * dz) >= (C130_OWNER_RESOLVE_MOVE2D * C130_OWNER_RESOLVE_MOVE2D) then
              set.ownerResolved = true
              resolveC130AutoBuildOwner(entry.setId, vec3)
            end
          end
        end
        local moved = UpdateTrackedEntryMovement(entry, vec3)
        local agl = vec3.y - land.getHeight({ x = vec3.x, y = vec3.z })

        if (entry.unitName or entry.groupName) and (not entry.detached or not entry.attached) then
          local unitObj = ResolveTrackedCarrierUnit(entry, true)
          local dim = ResolveTrackedCarrierDimensions(entry, unitObj)
          if unitObj and unitObj.isExist and unitObj:isExist() then
            local up = unitObj:getPoint()
            if dim and up and up.x and up.y and up.z then
              local dx = up.x - vec3.x
              local dy = up.y - vec3.y
              local dz = up.z - vec3.z
              local d2 = dx * dx + dz * dz
              local delta3D = math.sqrt(d2 + dy * dy)

              if not entry.attached and not unitObj:inAir() then
                local attach = dim.attach or 8
                if delta3D <= attach then
                  entry.attached = true
                  if CTLD_Logging then
                    trigger.action.outText(string.format("[C130AutoBuild] Attached crate %s d3=%.2f attach=%.2f unit=%s", tostring(key), delta3D, attach, tostring(entry.unitName or entry.groupName)), 30)
                    env.info(string.format("[C130AutoBuild] Attached crate %s d3=%.2f attach=%.2f unit=%s", tostring(key), delta3D, attach, tostring(entry.unitName or entry.groupName)))
                  end
                end
              end

              if entry.attached and not entry.detached and unitObj:inAir() and (entry.wasAirborne or agl >= C130_AUTO_AIRBORNE_AGL) then
                local detach = dim.detach or 14
                if delta3D > detach then
                  entry.detached = true
                  if CTLD_Logging then
                    trigger.action.outText(string.format("[C130AutoBuild] Detached crate %s d3=%.2f detach=%.2f unit=%s", tostring(key), delta3D, detach, tostring(entry.unitName or entry.groupName)), 30)
                    env.info(string.format("[C130AutoBuild] Detached crate %s d3=%.2f detach=%.2f unit=%s", tostring(key), delta3D, detach, tostring(entry.unitName or entry.groupName)))
                  end
                end
              end
            end
          end
        end

        if entry.attached and agl >= C130_AUTO_AIRBORNE_AGL then
          entry.wasAirborne = true
        end
        if entry.attached and agl <= ZONE_SUPPLY_AGL_THRESHOLD and entry.wasAirborne and not moved then
          if entry._landAglConfirm then
            if math.abs(agl - entry._landAglConfirm) <= 0.05 then
              entry._landAglConfirm = nil
              local zoneContainer = bc and bc:getZoneOfPoint(vec3) or nil
              local zoneName = zoneContainer and zoneContainer.zone or nil
              if entry.pickupZone and zoneName == entry.pickupZone then
                if not entry.warnedPickup and entry.playerName then
                  entry.warnedPickup = true
                  local set = entry.setId and c130AutoBuildSets[entry.setId] or nil
                  if set then
                    notifyC130Auto(set, "CTLD_MOVE_CARGO_BEFORE_HERCULES_AUTOBUILD", entry.cargoName or "cargo", entry.pickupZone)
                  else
                    MESSAGE:New(L10N:Format("CTLD_MOVE_CARGO_BEFORE_HERCULES_AUTOBUILD", entry.cargoName or "cargo", entry.pickupZone), 10):ToBlue()
                  end
                end
              else
                entry.landed = true
                entry.vec3 = vec3
              end
            else
              entry._landAglConfirm = agl
            end
          else
            entry._landAglConfirm = agl
          end
        else
          entry._landAglConfirm = nil
        end
      end
    end
  end

  for setId, set in pairs(c130AutoBuildSets) do
  if set.failed then
    if set.handoffStarted then
      env.info(string.format("[FH-AUTOBUILD] set retired after handoff set=%s required=%s", tostring(setId), tostring(set.required)))
    else
      if not set.failedNotified then
        set.failedNotified = true
        notifyC130Auto(set, "CTLD_AUTO_BUILD_FAILED_DESTROYED")
      end
      env.info(string.format("[FH-AUTOBUILD] set failed set=%s required=%s", tostring(setId), tostring(set.required)))
    end
    for _, key in ipairs(set.crates) do
      c130AutoBuildCrates[key] = nil
    end
    c130AutoBuildSets[setId] = nil
    elseif not set.completed then
      local landedCount = 0
      local vecs = {}
      for _, key in ipairs(set.crates) do
        local entry = c130AutoBuildCrates[key]
        if entry and entry.landed and entry.vec3 then
          landedCount = landedCount + 1
          vecs[#vecs + 1] = entry.vec3
        end
      end
      if landedCount == set.required and landedCount > 0 then
        local dcsGroup = set.groupName and Group.getByName(set.groupName) or nil
        if not dcsGroup or not Utils.someOfGroupInAir(dcsGroup) then
          notifyC130Auto(set, "CTLD_AUTO_BUILD_SKIPPED_AIRBORNE")
          set.completed = true
          for _, key in ipairs(set.crates) do
            c130AutoBuildCrates[key] = nil
          end
          c130AutoBuildSets[setId] = nil
        else
          local avg = { x = 0, z = 0 }
          for _, v in ipairs(vecs) do
            avg.x = avg.x + v.x
            avg.z = avg.z + v.z
          end
          avg.x = avg.x / landedCount
          avg.z = avg.z / landedCount

          local helperName = string.format("CTLD_C130_HELPER_%d", math.random(1, 1e6))
          local helperData = {
            visible = false,
            lateActivation = false,
            tasks = {},
            x = avg.x,
            y = avg.z,
            name = helperName,
            task = "Ground Nothing",
            route = { points = { { x = avg.x, y = avg.z, speed = 0, task = { id = "ComboTask", params = { tasks = {} } } } } },
            units = {
              [1] = {
                type = "Soldier M4",
                name = helperName .. "_1",
                x = avg.x,
                y = avg.z,
                heading = 0,
                skill = "Excellent",
              }
            }
          }

          local countryId = (Foothold_ctld.coalition == coalition.side.BLUE) and country.id.USA or country.id.RUSSIA
          coalition.addGroup(countryId, Group.Category.GROUND, helperData)

          timer.scheduleFunction(function()
            local helperGroup = GROUP:FindByName(helperName)
            if helperGroup and helperGroup:IsAlive() then
              local helperUnit = helperGroup:GetUnits()[1]
              if helperUnit then
                Foothold_ctld:_BuildCrates(helperGroup, helperUnit, true, true, GROUP:FindByName(set.groupName))
              end
              timer.scheduleFunction(function()
                if helperGroup and helperGroup:IsAlive() then helperGroup:Destroy() end
              end, {}, timer.getTime() + Foothold_ctld.buildtime +5)
            end
          end, {}, timer.getTime() + 2)

          set.handoffStarted = true
          set.completed = true
          env.info(string.format("[FH-AUTOBUILD] set handoff set=%s required=%s", tostring(setId), tostring(set.required)))
          timer.scheduleFunction(function()
            local total = 0
            local destroyedNow = 0
            local alreadyRemoved = 0
            local destroyRequestedStillAlive = 0
            local stillAlive = 0
            for _, key in ipairs(set.crates) do
              local entry = c130AutoBuildCrates[key]
              total = total + 1
              if entry then
                local outcome = destroyC130AutoBuildCrate(entry, key, setId)
                if outcome == "destroyed-now" then
                  destroyedNow = destroyedNow + 1
                elseif outcome == "already-removed" then
                  alreadyRemoved = alreadyRemoved + 1
                elseif outcome == "destroy-requested-still-alive" then
                  destroyRequestedStillAlive = destroyRequestedStillAlive + 1
                elseif outcome == "still-alive" then
                  stillAlive = stillAlive + 1
                end
              else
                alreadyRemoved = alreadyRemoved + 1
              end
              c130AutoBuildCrates[key] = nil
            end
            local status = ((destroyRequestedStillAlive + stillAlive) == 0) and "OK" or "CHECK"
            env.info(string.format(
              "[FH-AUTOBUILD] cleanup-summary set=%s total=%d destroyedNow=%d alreadyRemoved=%d destroyRequestedStillAlive=%d stillAlive=%d status=%s",
              tostring(setId),
              total,
              destroyedNow,
              alreadyRemoved,
              destroyRequestedStillAlive,
              stillAlive,
              status
            ))
            c130AutoBuildSets[setId] = nil
          end, {}, timer.getTime() + Foothold_ctld.buildtime + 5)
        end
      end
    end
  end
end

local function updateLastPickupZone(Group, ReferenceUnit)
  if not Group or not Group:IsAlive() then return nil end

    local function safeCoordinate(source)
        if not source or not source.GetCoordinate then return nil end
        local ok, coord = pcall(function() return source:GetCoordinate() end)
        if ok then return coord end
        return nil
    end

    local coord = safeCoordinate(ReferenceUnit)
    if not coord then
        coord = safeCoordinate(Group)
    end
    if not coord then
        local units = Group.GetUnits and Group:GetUnits() or nil
        if units and units[1] then
            coord = safeCoordinate(units[1])
        end
    end

    local pickupZone = nil
    if coord and coord.GetVec3 then
        local vec = coord:GetVec3()
        if vec then
            local zoneContainer = bc:getZoneOfPoint(vec)
            pickupZone = zoneContainer and zoneContainer.zone or nil
            if not pickupZone and supplyZones and ZONE and COORDINATE then
                local coordObj = COORDINATE:NewFromVec3(vec)
                for i = 1, #supplyZones do
                    local zoneName = supplyZones[i]
                    local mooseZone = getSupplyZoneWrapper(zoneName)
                    if mooseZone and mooseZone:IsCoordinateInZone(coordObj) then
                        pickupZone = zoneName
                        break
                    end
                end
            end
        end
    end

    Group._lastPickupZone = pickupZone
    return pickupZone
end

local function resolveZoneSupplyUnit(entry)
  if entry and entry.unitName and Unit and Unit.getByName then
    local u = entry._unitObj
    if (not u) or (u and u.isExist and not u:isExist()) then
      u = Unit.getByName(entry.unitName)
      entry._unitObj = u
      entry._unitDim = nil
    end
    if u and u.isExist and u:isExist() then
      local pn = (u.getPlayerName and u:getPlayerName()) or nil
      if not entry.playerName or entry.playerName == "nil" or pn == entry.playerName then
        return u
      end
    end
  end

  if entry and entry.playerName and entry.playerName ~= "nil" then
    local players = coalition.getPlayers(2) or {}
    for _, u in ipairs(players) do
      if u and u.getPlayerName and u:getPlayerName() == entry.playerName then
        return u
      end
    end
  end

  return nil
end


zoneSupplyLandingOnce = zoneSupplyLandingOnce or { pending = nil, scheduled = false, delay = 5 }

local function simulateLandingForEntryIfOnGround(entry, zoneName)
  if not (entry and zoneName) then return end

  if zoneSupplyLandingOnce.pending then return end

  local unitCap = resolveZoneSupplyUnit(entry)
  if not (unitCap and unitCap.isExist and unitCap:isExist()) then return end

  if Utils and Utils.isInAir and Utils.isInAir(unitCap) then return end
  if Utils and Utils.isInZone and (not Utils.isInZone(unitCap, zoneName)) then return end

  zoneSupplyLandingOnce.pending = {
    unit = unitCap,
    playerName = entry.playerName,
    zoneName = zoneName
  }
end

local function getZoneStorageHandle(zoneName)
  if not WarehouseLogistics then return nil, nil end
  if not zoneName then return nil, nil end
  local cached = zoneStorageHandleCache[zoneName]
  if cached and cached.storage then
    return cached.storage, cached.abName
  end
  local zoneObj = bc:getZoneByName(zoneName)
  local abName = zoneObj and (zoneObj.airbaseName or zoneObj.baseName) or zoneName
  local storage = STORAGE:FindByName(abName)
  if not storage then
    if abName ~= zoneName then
      local storage2 = STORAGE:FindByName(zoneName)
      if storage2 then
        zoneStorageHandleCache[zoneName] = { storage = storage2, abName = zoneName }
        return storage2, zoneName
      end
    end
    return nil, nil
  end
  zoneStorageHandleCache[zoneName] = { storage = storage, abName = abName }
  return storage, abName
end


local function getWarehouseItemsForCategory(categoryKey)
  if warehouseSupplyItemCache[categoryKey] then
    return warehouseSupplyItemCache[categoryKey]
  end

  local list = {}
  if WEAPONSLIST and WEAPONSLIST.GetItems then
    local items = WEAPONSLIST.GetItems(categoryKey) or {}
    for i = 1, #items do
      local itemName = items[i]
      if itemName then
        list[#list + 1] = itemName
      end
    end
  end

  warehouseSupplyItemCache[categoryKey] = list
  return list
end

local function isStrictSmartWarehouseWeapon(itemName)
  if type(itemName) ~= "string" or type(WarehouseWeaponCaps) ~= "table" then
    return false
  end
  for i = 1, #WarehouseWeaponCaps do
    if WarehouseWeaponCaps[i] == itemName then
      return true
    end
  end
  return false
end

local function getStrictSmartWarehouseDelta(itemName, baseDelta)
  local delta = math.max(0, math.floor(tonumber(baseDelta) or 0))
  if delta <= 0 then return 0 end
  if StrictSmartWeaponsInventory == true and isStrictSmartWarehouseWeapon(itemName) then
    delta = math.floor(delta / 2)
  end
  return delta
end

local function grantZoneBundle(zoneName)
  local bundle = WAREHOUSE_SUPPLY_TYPES["10 of everything CH-47"] or WAREHOUSE_SUPPLY_TYPES["10 of everything MI-8"] or WAREHOUSE_SUPPLY_TYPES["10 of everything Blackhawk"]
  if not bundle then return end
  adjustWarehouseStockAtZone(zoneName, bundle.amount or 10, bundle.categories)
end


zoneSupplyDebug = function(msg)
  if not CTLD_Logging_DEEP then return end
  env.info("[ZoneSupply] " .. tostring(msg))
  trigger.action.outTextForCoalition(2, "[ZoneSupply] " .. tostring(msg), 10)
end

-- Always-on minimal C-130 logging for zone/warehouse supplies (independent of CTLD_Logging flags).
local function c130SupplyLog(entry, key, event, extra)
  if not entry or not entry._isC130 then return end
  local dtype = entry.deliveryType
  if dtype ~= "zone" and dtype ~= "warehouse" then return end
  local msg = string.format(
    "[ZoneSupply][C130][%s] key=%s type=%s group=%s unit=%s player=%s%s",
    tostring(event),
    tostring(key),
    tostring(dtype),
    tostring(entry.groupName or "nil"),
    tostring(entry.unitName or "nil"),
    tostring(entry.playerName or "nil"),
    extra and (" "..extra) or ""
  )
  env.info(msg)
end

c130SupplyLogOnce = function(entry, key, flagField, event, extra)
  if not entry or not entry._isC130 then return end
  if entry[flagField] then return end
  entry[flagField] = true
  c130SupplyLog(entry, key, event, extra)
end

local function isZoneSupplyCargoItem(cargoItem)
  local cargoName = cargoItem and cargoItem.GetName and cargoItem:GetName() or nil
  return cargoName and ZONE_SUPPLY_TYPES[cargoName] == true
end

getZoneSupplyStaticKey = function(staticObj)
  if not staticObj then return nil end
  local key = nil
  if staticObj.GetID then
    key = staticObj:GetID()
  elseif staticObj.getID then
    key = staticObj:getID()
  end
  if not key then
    if staticObj.GetName then
      key = staticObj:GetName()
    elseif staticObj.getName then
      key = staticObj:getName()
    end
  end
  return key
end

local function getZoneSupplyStaticName(staticObj)
  if not staticObj then return nil end
  if staticObj.GetName then
    return staticObj:GetName()
  end
  if staticObj.getName then
    return staticObj:getName()
  end
  return nil
end

local function zoneSupplyDestroyStaticByName(staticName)
  if not staticName or not StaticObject or not StaticObject.getByName then
    return false
  end
  local dcsStatic = StaticObject.getByName(staticName)
  if dcsStatic and dcsStatic.destroy then
    dcsStatic:destroy()
    return true
  end
  return false
end
local processZoneSupplyDeliveries
local zoneSupplyApplyOne
local zoneSupplyProcessReadyQueue
local zoneSupplyProcessRunning = false
local zoneSupplyProcessQueued = false

local function zoneSupplyC130OneShotConfirm(arg, time)
  local key = arg and arg.key
  local entry = key and zoneSupplyCrates[key] or nil
  if not (entry and entry._isC130 and entry.detached) then return end
  entry._c130OneShotScheduled = false
  if entry._wasUnloaded then return end

  local cargo = entry.cargo
  local staticObj = (cargo and cargo.GetPositionable and cargo:GetPositionable()) or entry.static
  if not (staticObj and staticObj:IsAlive()) then
    zoneSupplyCrates[key] = nil
    return
  end

  local coord = staticObj:GetCoordinate()
  local vec3 = coord and coord:GetVec3() or nil
  if not vec3 then return end

  local ground = land.getHeight({ x = vec3.x, y = vec3.z })
  local agl = vec3.y - ground
  if agl > ZONE_SUPPLY_C130_LANDED_AGL then return end

  local prev = arg.prev
  if prev then
    local dx = vec3.x - prev.x
    local dy = vec3.y - prev.y
    local dz = vec3.z - prev.z
    if (dx * dx + dy * dy + dz * dz) > ZONE_SUPPLY_C130_ONESHOT_MOVE_EPS2 then
      return
    end
  end

  entry._wasUnloaded = true
  entry._c130AglConfirm = nil
  c130SupplyLogOnce(entry, key, "_fhLogUnloaded", "UNLOADED", string.format("agl=%.2f", agl))
  if not entry._loggedC130Unloaded then
    if CTLD_Logging then
      trigger.action.outText(string.format("[ZoneSupply][C130] Unloaded key=%s unit=%s", tostring(key), tostring(entry.unitName)), 10)
      env.info(string.format("[ZoneSupply][C130] Unloaded key=%s unit=%s", tostring(key), tostring(entry.unitName)))
    end
    entry._loggedC130Unloaded = true
  end

  zoneSupplyApplyOne(key)
end

local function tickZoneSupply()
  if next(c130AutoBuildSets) then
    processC130AutoBuild()
  end
  if not next(zoneSupplyCrates) then
    return
  end
  local ready = processZoneSupplyDeliveries()
  if ready and ready > 0 then
    zoneSupplyProcessReadyQueue()
  end
end

local function resolveZoneSupplyGroup(groupName)
  if not groupName then return nil end
  local grp = GROUP:FindByName(groupName)
  if grp and grp:IsAlive() then
    return grp
  end
  return nil
end

local function resolveZoneSupplyPlayer(entry)
  if entry.playerName and entry.playerName ~= "" then
    return entry.playerName
  end
  local grp = resolveZoneSupplyGroup(entry.groupName)
  if not grp then return nil end
  local units = grp:GetUnits()
  if units and units[1] then
    local pname = units[1]:GetPlayerName()
    if pname and pname ~= "" then
      entry.playerName = pname
      return pname
    end
  end
  return nil
end

local CTLD_REASON_KEYS = {
  ["enemy zone"] = "CTLD_REASON_ENEMY_ZONE",
  ["neutral zone timeout"] = "CTLD_REASON_NEUTRAL_ZONE_TIMEOUT",
  ["warehouse logistics disabled"] = "CTLD_REASON_WAREHOUSE_LOGISTICS_DISABLED",
  ["no storage"] = "CTLD_REASON_NO_STORAGE",
  ["no applicable inventory"] = "CTLD_REASON_NO_APPLICABLE_INVENTORY",
  ["not available"] = "CTLD_REASON_NOT_AVAILABLE",
  ["debit failed"] = "CTLD_REASON_DEBIT_FAILED",
}

local CTLD_ZONE_SUPPLY_ACTION_KEYS = {
  captured = "CTLD_ZONE_SUPPLY_ACTION_CAPTURED",
  upgraded = "CTLD_ZONE_SUPPLY_ACTION_UPGRADED",
}

local CTLD_TROOP_ZONE_ACTION_KEYS = {
  captured = "CTLD_TROOP_ZONE_CAPTURED",
  upgraded = "CTLD_TROOP_ZONE_UPGRADED",
  ["captured and upgraded"] = "CTLD_TROOP_ZONE_CAPTURED_AND_UPGRADED",
}

local function ctldReasonToken(key, ...)
  return { key = key, args = { ... } }
end

local function ctldReasonText(T, reason)
  if type(reason) == "table" and reason.key then
    return T:Format(reason.key, unpack(reason.args or {}))
  end
  local skippedLow, abName = tostring(reason):match("^no items adjusted %(skippedLow=(%d+)%) at (.+)$")
  if skippedLow then
    return T:Format("CTLD_ADJUST_NO_ITEMS", tonumber(skippedLow), abName)
  end
  local reasonKey = CTLD_REASON_KEYS[tostring(reason)]
  if reasonKey then
    return T:Get(reasonKey)
  end
  return tostring(reason)
end

local function ctldReasonListText(T, reasons)
  if type(reasons) ~= "table" or reasons.key then
    return ctldReasonText(T, reasons)
  end
  local parts = {}
  for i = 1, #reasons do
    parts[#parts + 1] = ctldReasonText(T, reasons[i])
  end
  return table.concat(parts, ", ")
end

local function ctldZoneSupplyActionText(T, action)
  local actionKey = CTLD_ZONE_SUPPLY_ACTION_KEYS[tostring(action)]
  if actionKey then
    return T:Get(actionKey)
  end
  return tostring(action)
end

local function ctldTroopZoneActionText(T, action)
  local actionKey = CTLD_TROOP_ZONE_ACTION_KEYS[tostring(action)]
  if actionKey then
    return T:Get(actionKey)
  end
  return tostring(action)
end

local function sendZoneSupplyMessage(entry, text, duration)
  local grp = resolveZoneSupplyGroup(entry.groupName)
  if grp then
    MESSAGE:New(text, duration or 15):ToGroup(grp)
  else
    MESSAGE:New(text, duration or 15):ToBlue()
  end
end

local function sendZoneSupplyLocalizedMessage(entry, key, duration, ...)
  local grp = resolveZoneSupplyGroup(entry.groupName)
  if grp then
    MESSAGE:New(formatCtldForGroup(grp, key, ...), duration or 15):ToGroup(grp)
  else
    MESSAGE:New(L10N:Format(key, ...), duration or 15):ToBlue()
  end
end

local function zoneSupplyHasReadyCrates()
  for _, e in pairs(zoneSupplyCrates) do
    if e and e._ready then
      return true
    end
  end
  return false
end

local function zoneSupplyTryCleanup()
  zoneSupplyCleanupScheduled = false

  if zoneSupplyProcessRunning then
    timer.scheduleFunction(zoneSupplyTryCleanup, {}, timer.getTime() + 5)
    zoneSupplyCleanupScheduled = true
    return
  end

  if zoneSupplyHasReadyCrates() then
    timer.scheduleFunction(zoneSupplyTryCleanup, {}, timer.getTime() + 5)
    zoneSupplyCleanupScheduled = true
    return
  end

  local now = timer.getTime()
  local nextDue = nil
  for rkey, r in pairs(zoneSupplyPendingRemoval) do
    if r and r.due and r.due <= now then
      local staticObj = r.static
      if not (r.name and zoneSupplyDestroyStaticByName(r.name)) then
        if staticObj and staticObj.IsAlive and staticObj:IsAlive() then
          staticObj:Destroy(false)
        end
      end
      zoneSupplyPendingRemoval[rkey] = nil
    elseif r and r.due then
      if not nextDue or r.due < nextDue then
        nextDue = r.due
      end
    end
  end

  if nextDue then
    local delay = math.max(1, nextDue - now)
    timer.scheduleFunction(zoneSupplyTryCleanup, {}, now + delay)
    zoneSupplyCleanupScheduled = true
  end
end

local function zoneSupplyScheduleCleanup()
  if zoneSupplyCleanupScheduled then return end
  if not next(zoneSupplyPendingRemoval) then return end
  zoneSupplyCleanupScheduled = true
  timer.scheduleFunction(zoneSupplyTryCleanup, {}, timer.getTime() + 1)
end

local function zoneSupplyEnqueueRemoval(staticObj, delaySeconds)
  if not staticObj then return end

  local delay = tonumber(delaySeconds)
  local sname = getZoneSupplyStaticName(staticObj)

  if delay ~= nil and delay <= 0 then
    local rkey = getZoneSupplyStaticKey(staticObj)
    if rkey then
      zoneSupplyPendingRemoval[rkey] = nil
    end
    if not (sname and zoneSupplyDestroyStaticByName(sname)) then
      if staticObj.IsAlive and staticObj:IsAlive() then
        staticObj:Destroy(false)
      end
    end
    return
  end

  local rkey = getZoneSupplyStaticKey(staticObj)
  if not rkey then return end

  zoneSupplyPendingRemoval[rkey] = {
    static = staticObj,
    name = sname,
    due = timer.getTime() + (delay or ZONE_SUPPLY_DESTROY_DELAY),
  }
  zoneSupplyScheduleCleanup()
end



local function zoneSupplyDestroyNow(key, entry, zoneName, reason)
  local current = entry or zoneSupplyCrates[key]
  if not current then return end
  c130SupplyLogOnce(current, key, "_fhLogDestroy", "DESTROY", string.format("zone=%s reason=%s", tostring(zoneName), tostring(reason)))

  local staticObj = (current.cargo and current.cargo.GetPositionable and current.cargo:GetPositionable()) or current.static
  local deleteName = current._deleteName
  if not deleteName and staticObj then
    deleteName = getZoneSupplyStaticName(staticObj)
    current._deleteName = deleteName
  end

  local destroyed = false
  if deleteName and zoneSupplyDestroyStaticByName(deleteName) then
    destroyed = true
  elseif staticObj and staticObj.IsAlive and staticObj:IsAlive() then
    staticObj:Destroy(false)
    destroyed = true
  end

  if not destroyed and staticObj then
    zoneSupplyEnqueueRemoval(staticObj, 0)
  end

  zoneSupplyCrates[key] = nil
  if staticObj then
    local rkey = getZoneSupplyStaticKey(staticObj)
    if rkey then
      zoneSupplyPendingRemoval[rkey] = nil
    end
  end
  if current._deleteKey then
    zoneSupplyPendingRemoval[current._deleteKey] = nil
  end
  if reason then
    local grp = resolveZoneSupplyGroup(current.groupName)
    local T = grp and getCtldGroupTranslator(grp) or getFootholdLocalization():ForLocale()
    local reasonText = ctldReasonText(T, reason)
    local text = T:Format("CTLD_ZONE_SUPPLIES_DESTROYED", tostring(zoneName), reasonText)
    sendZoneSupplyMessage(current, text)
  end
end



local function finalizeZoneSupplyDelivery(key, entry, zoneName, verb, statLabel, reward)
  c130SupplyLogOnce(entry, key, "_fhLogDeliver", "DELIVER", string.format("zone=%s verb=%s", tostring(zoneName), tostring(verb)))
  local grp = resolveZoneSupplyGroup(entry.groupName)
  local T = grp and getCtldGroupTranslator(grp) or getFootholdLocalization():ForLocale()
  local verbText = ctldZoneSupplyActionText(T, verb)
  local text = T:Format("CTLD_ZONE_SUPPLIES_DELIVERED", verbText, zoneName)
  sendZoneSupplyMessage(entry, text)
  local pname = resolveZoneSupplyPlayer(entry)
  if pname and bc.playerContributions[2][pname] ~= nil then
    bc:addContribution(pname, 2, reward)
    bc:addTempStat(pname, statLabel, 1)
  end
  simulateLandingForEntryIfOnGround(entry, zoneName)

  local staticObj = (entry.cargo and entry.cargo.GetPositionable and entry.cargo:GetPositionable()) or entry.static
  if entry and entry._deleteKey then
    zoneSupplyPendingRemoval[entry._deleteKey] = nil
  end
  local deleteName = entry and entry._deleteName
  if not (deleteName and zoneSupplyDestroyStaticByName(deleteName)) then
    zoneSupplyEnqueueRemoval(staticObj, 0)
  end
  zoneSupplyCrates[key] = nil
end

processZoneSupplyDeliveries = function()
  if not next(zoneSupplyCrates) then return 0 end
  local now = timer.getTime()
  local readyCount = 0
  for key, entry in pairs(zoneSupplyCrates) do
    entry._ready = false
    local cargo = entry.cargo
    local staticObj = (cargo and cargo.GetPositionable and cargo:GetPositionable()) or entry.static
    if not cargo and not staticObj then
      zoneSupplyDebug(string.format("Drop tracking for %s cleared: no cargo ref", tostring(key)))
      c130SupplyLogOnce(entry, key, "_fhLogClear", "CLEAR", "reason=no cargo ref")
      zoneSupplyCrates[key] = nil
    elseif not staticObj or not staticObj:IsAlive() then
      zoneSupplyDebug(string.format("Drop tracking for %s cleared: static dead/missing", tostring(key)))
      c130SupplyLogOnce(entry, key, "_fhLogClear", "CLEAR", "reason=static dead/missing")
      zoneSupplyCrates[key] = nil
    else
      local coord = staticObj:GetCoordinate()
      if coord then
        local vec3 = coord:GetVec3()
        if vec3 then
          local moved = UpdateTrackedEntryMovement(entry, vec3)

          if moved then
            if not entry.wasAirborne and not entry._gcLoadedMsg and not entry._isC130 then
              local staticName = staticObj and staticObj.GetName and staticObj:GetName() or (entry.cargoName or tostring(key))
              sendZoneSupplyLocalizedMessage(entry, "CTLD_CRATE_LOADED_GROUND_CREW", 10, tostring(staticName))
              entry._gcLoadedMsg = true
            end
            entry.wasAirborne = true
            entry._wasUnloaded = false
            entry._c130AglConfirm = nil
            if entry._isC130 then
              entry.attached = true
              c130SupplyLogOnce(entry, key, "_fhLogAttach", "ATTACHED", "pickup="..tostring(entry.pickupZone))
              if not entry._loggedC130Attached then
                if CTLD_Logging then
                  trigger.action.outText(string.format("[ZoneSupply][C130] Attached key=%s unit=%s", tostring(key), tostring(entry.unitName)), 10)
                  env.info(string.format("[ZoneSupply][C130] Attached key=%s unit=%s", tostring(key), tostring(entry.unitName)))
                end
                entry._loggedC130Attached = true
              end
              entry._c130Stable = 0
              local unitObj = ResolveTrackedCarrierUnit(entry, false)
              local dim = ResolveTrackedCarrierDimensions(entry, unitObj)
              UpdateC130AttachDetachState(entry, key, vec3, unitObj, dim)
              if entry.detached and not entry._loggedC130Detached then
                if CTLD_Logging then
                trigger.action.outText(string.format("[ZoneSupply][C130] Detached key=%s unit=%s", tostring(key), tostring(entry.unitName)), 10)
                end
                entry._loggedC130Detached = true
              end
            end

            if entry.landedAt then
              ClearZoneSupplyLandingState(entry, staticObj)
            end
          else
            if entry.wasAirborne and not entry._wasUnloaded then
              if entry._isC130 then
                entry.attached = true
                c130SupplyLogOnce(entry, key, "_fhLogAttach", "ATTACHED", "pickup="..tostring(entry.pickupZone))
                if not entry._loggedC130Attached then
                  if CTLD_Logging then
                    trigger.action.outText(string.format("[ZoneSupply][C130] Attached key=%s unit=%s", tostring(key), tostring(entry.unitName)), 10)
                    env.info(string.format("[ZoneSupply][C130] Attached key=%s unit=%s", tostring(key), tostring(entry.unitName)))
                  end
                  entry._loggedC130Attached = true
                end
                local unitObj = ResolveTrackedCarrierUnit(entry, false)
                local dim = ResolveTrackedCarrierDimensions(entry, unitObj)
                UpdateC130AttachDetachState(entry, key, vec3, unitObj, dim)
                if entry.detached then
                  if not entry._loggedC130Detached then
                    if CTLD_Logging then
                    trigger.action.outText(string.format("[ZoneSupply][C130] Detached key=%s unit=%s", tostring(key), tostring(entry.unitName)), 10)
                    env.info(string.format("[ZoneSupply][C130] Detached key=%s unit=%s", tostring(key), tostring(entry.unitName)))
                    end
                    entry._loggedC130Detached = true
                  end
                  local inAir = unitObj and unitObj.isExist and unitObj:isExist() and unitObj:inAir()
                  local ground = land.getHeight({ x = vec3.x, y = vec3.z })
                  local agl = vec3.y - ground

                  if not inAir then
                    if agl <= ZONE_SUPPLY_C130_LANDED_AGL then
                      entry._wasUnloaded = true
                      entry._c130AglConfirm = nil
                      c130SupplyLogOnce(entry, key, "_fhLogUnloaded", "UNLOADED", string.format("agl=%.2f", agl))
                      if not entry._loggedC130Unloaded then
                        if CTLD_Logging then
                          trigger.action.outText(string.format("[ZoneSupply][C130] Unloaded key=%s unit=%s", tostring(key), tostring(entry.unitName)), 10)
                          env.info(string.format("[ZoneSupply][C130] Unloaded key=%s unit=%s", tostring(key), tostring(entry.unitName)))
                        end
                        entry._loggedC130Unloaded = true
                      end
                    end
                  else
                    if agl <= ZONE_SUPPLY_C130_LANDED_AGL and not entry._c130OneShotScheduled then
                      entry._c130OneShotScheduled = true
                      timer.scheduleFunction(zoneSupplyC130OneShotConfirm, { key = key, prev = { x = vec3.x, y = vec3.y, z = vec3.z } }, timer.getTime() + ZONE_SUPPLY_C130_ONESHOT_DELAY)
                    end
                  end
                end
              else
                local ok = false
                local unitObj = ResolveTrackedCarrierUnit(entry, false)
                if (not unitObj) or (unitObj and unitObj.isExist and not unitObj:isExist()) then
                  local ground = land.getHeight({ x = vec3.x, y = vec3.z })
                  local agl = vec3.y - ground
                  if agl <= ZONE_SUPPLY_AGL_THRESHOLD then
                    entry._wasUnloaded = true
                    entry._c130AglConfirm = nil
                  end
                end
                local dim = ResolveTrackedCarrierDimensions(entry, unitObj)

                local inAir = nil
                local speed2 = nil
                if unitObj and unitObj.isExist and unitObj:isExist() then
                  if not dim then
                    dim = ZONE_SUPPLY_AIRCRAFT_DIMENSIONS[unitObj:getTypeName()]
                    entry._unitDim = dim
                  end
                  if dim then
                    local up = unitObj:getPoint()
                    if up and up.x and up.y and up.z then
                      local dx = up.x - vec3.x
                      local dy = up.y - vec3.y
                      local dz = up.z - vec3.z
                      local d2 = dx * dx + dz * dz
                      local delta2D = math.sqrt(d2)
                      local delta3D = math.sqrt(d2 + dy * dy)
                      inAir = unitObj:inAir()
                      ok = false
                      if not inAir then
                        if dim.ropelength == 0 then
                          if delta2D > (dim.detach or dim.width) then
                            ok = true
                          end
                        else
                          if delta2D > dim.width then ok = true end
                          if math.abs(dy) > dim.height then ok = true end
                        end
                      else
                        if dim.ropelength == 0 then
                          if delta3D > (dim.detach or dim.width) then ok = true end
                        end
                        if not ok and dim.ropelength and dim.ropelength > 0 then
                          if math.abs(dx) > dim.width then ok = true end
                          if math.abs(dy) > dim.ropelength then ok = true end
                          if math.abs(dz) > dim.width then ok = true end
                        end
                        if ok and dim.ropelength == 0 then
                          local v = unitObj:getVelocity()
                          if v then
                            local vx = v.x or 0
                            local vz = v.z or 0
                            speed2 = vx * vx + vz * vz
                          end
                        end
                      end
                    end
                  end
                end
                if ok then
                  local settleOk = true
                  if dim and dim.ropelength == 0 and inAir and speed2 and speed2 > 9 then
                    local ground = land.getHeight({ x = vec3.x, y = vec3.z })
                    local aglNow = vec3.y - ground
                    if not entry._c130AglConfirm then
                      entry._c130AglConfirm = aglNow
                      settleOk = false
                    else
                      settleOk = math.abs(aglNow - entry._c130AglConfirm) < 0.5
                      if settleOk then
                        entry._c130AglConfirm = nil
                      else
                        entry._c130AglConfirm = aglNow
                      end
                    end
                  end
                  if settleOk then
                    if not entry._gcUnloadedMsg and dim and dim.ropelength > 0 and not inAir then
                      local staticName = staticObj and staticObj.GetName and staticObj:GetName() or (entry.cargoName or tostring(key))
                      if staticName then
                        sendZoneSupplyLocalizedMessage(entry, "CTLD_CRATE_UNLOADED_GROUND_CREW", 10, tostring(staticName))
                      end
                      entry._gcUnloadedMsg = true
                    end
                    entry._wasUnloaded = true
                  end
                end
              end
            end
          end

          local ground = land.getHeight({ x = vec3.x, y = vec3.z })
          local agl = vec3.y - ground
          zoneSupplyDebug(string.format("Check crate %s agl=%.2f pickup=%s", tostring(key), agl, tostring(entry.pickupZone)))
          local onGround = (agl <= ZONE_SUPPLY_AGL_THRESHOLD) or (entry._wasUnloaded and not moved)
          if entry._isC130 and not entry._wasUnloaded then onGround = false end
          if onGround then

            if not entry.wasAirborne then
              if not entry._loggedAwaitingAirborne then
                entry._loggedAwaitingAirborne = true
                zoneSupplyDebug(string.format("Crate %s on ground (awaiting pickup/airborne)", tostring(key)))
              end
            else
              if entry._wasUnloaded then

              local zoneContainer = bc and bc:getZoneOfPoint(vec3) or nil

              if (not (zoneContainer and zoneContainer.zone)) and supplyZones and ZONE then
                for i = 1, #supplyZones do
                  local zName = supplyZones[i]
                  local mooseZone = getSupplyZoneWrapper(zName)
                  if mooseZone and mooseZone:IsCoordinateInZone(coord) then
                    zoneContainer = { zone = zName }
                    break
                  end
                end
              end

              local zoneName = zoneContainer and zoneContainer.zone or nil
              if entry._isC130 then
                c130SupplyLogOnce(entry, key, "_fhLogGround", "GROUND", string.format("agl=%.2f zone=%s", agl, tostring(zoneName or "NONE")))
              end
              if zoneName then
                local bcZone = bc:getZoneByName(zoneName)
                local zoneObj = bcZone or zoneContainer
                local zoneSide = zoneObj and zoneObj.side or "?"
                local zoneActive = zoneObj and zoneObj.active or false
                zoneSupplyDebug(string.format("Crate %s landed in %s side=%s active=%s", tostring(key), tostring(zoneName), tostring(zoneSide), tostring(zoneActive)))
                if entry.pickupZone and zoneName == entry.pickupZone then
                  if entry.deliveryType == "warehouse" and entry.warehouseMeta and WarehouseLogistics == true then
                    ClearZoneSupplyLandingState(entry, staticObj)
                    entry._ready = true
                    entry._zoneName = zoneName
                    entry._deleteName = entry._deleteName or getZoneSupplyStaticName(staticObj)
                    entry._deleteKey = entry._deleteKey or getZoneSupplyStaticKey(staticObj) or entry._deleteName
                    zoneSupplyDebug(string.format("[ZoneSupply] Ready key=%s zone=%s type=%s pickup=%s", tostring(key), tostring(zoneName), tostring(entry.deliveryType), tostring(entry.pickupZone)))
                    readyCount = readyCount + 1
                  else
                    if not entry.warnedSameZone then
                      --sendZoneSupplyMessage(entry, string.format("[CTLD] Deliver zone supplies to a zone other than %s.", zoneName))
                      entry.warnedSameZone = true
                    end
                  end
                else
                  if bcZone and bcZone.active then
                    ClearZoneSupplyLandingState(entry, staticObj)
                    entry._ready = true
                    entry._zoneName = zoneName
                    entry._deleteName = entry._deleteName or getZoneSupplyStaticName(staticObj)
                    entry._deleteKey = entry._deleteKey or getZoneSupplyStaticKey(staticObj) or entry._deleteName
                    zoneSupplyDebug(string.format("[ZoneSupply] Ready key=%s zone=%s type=%s pickup=%s", tostring(key), tostring(zoneName), tostring(entry.deliveryType), tostring(entry.pickupZone))) -- custom
                    readyCount = readyCount + 1
                  else
                    if (not bcZone) and entry.deliveryType == "warehouse" and entry.warehouseMeta and WarehouseLogistics == true and isCtldSupplyZoneName(zoneName) then
                      local storage = getZoneStorageHandle(zoneName)
                      if storage then
                        ClearZoneSupplyLandingState(entry, staticObj)
                        entry._ready = true
                        entry._zoneName = zoneName
                        entry._deleteName = entry._deleteName or getZoneSupplyStaticName(staticObj)
                        entry._deleteKey = entry._deleteKey or getZoneSupplyStaticKey(staticObj) or entry._deleteName
                        zoneSupplyDebug(string.format("[ZoneSupply] Ready key=%s zone=%s type=%s pickup=%s", tostring(key), tostring(zoneName), tostring(entry.deliveryType), tostring(entry.pickupZone)))
                        readyCount = readyCount + 1
                      else
                        zoneSupplyDebug(string.format("Crate %s in zone %s but zone inactive; clearing", tostring(key), tostring(zoneName)))
                        entry.landedAt = entry.landedAt or now
                        if not entry._inactiveRemovalScheduled then
                          zoneSupplyEnqueueRemoval(staticObj, ZONE_SUPPLY_INACTIVE_TTL)
                          entry._inactiveRemovalScheduled = true
                        end
                        local age = now - entry.landedAt
                        if age <= ZONE_SUPPLY_INACTIVE_TTL then
                          local last = entry._lastInactiveLog or 0
                          if (now - last) >= 30 then
                            zoneSupplyDebug(string.format("Crate %s in zone %s but inactive; keep tracking (%.0fs left)", tostring(key), tostring(zoneName), ZONE_SUPPLY_INACTIVE_TTL - age))
                            entry._lastInactiveLog = now
                          end
                        else
                          zoneSupplyDebug(string.format("Crate %s in zone %s inactive for %.0fs; clearing", tostring(key), tostring(zoneName), age))
                          zoneSupplyCrates[key] = nil
                        end
                      end
                    else
                      zoneSupplyDebug(string.format("Crate %s in zone %s but zone inactive; clearing", tostring(key), tostring(zoneName)))
                      entry.landedAt = entry.landedAt or now
                      if not entry._inactiveRemovalScheduled then
                        zoneSupplyEnqueueRemoval(staticObj, ZONE_SUPPLY_INACTIVE_TTL)
                        entry._inactiveRemovalScheduled = true
                      end
                      local age = now - entry.landedAt
                      if age <= ZONE_SUPPLY_INACTIVE_TTL then
                        local last = entry._lastInactiveLog or 0
                        if (now - last) >= 30 then
                          zoneSupplyDebug(string.format("Crate %s in zone %s but inactive; keep tracking (%.0fs left)", tostring(key), tostring(zoneName), ZONE_SUPPLY_INACTIVE_TTL - age))
                          entry._lastInactiveLog = now
                        end
                      else
                        zoneSupplyDebug(string.format("Crate %s in zone %s inactive for %.0fs; clearing", tostring(key), tostring(zoneName), age))
                        zoneSupplyCrates[key] = nil
                      end
                    end
                  end
                end
              else
                entry.landedAt = entry.landedAt or now
                if not entry._noZoneRemovalScheduled then
                  zoneSupplyEnqueueRemoval(staticObj, ZONE_SUPPLY_NOZONE_TTL)
                  entry._noZoneRemovalScheduled = true
                end
                local age = now - entry.landedAt
                if age <= ZONE_SUPPLY_NOZONE_TTL then
                  local last = entry._lastNoZoneLog or 0
                  if (now - last) >= 30 then
                    zoneSupplyDebug(string.format("Crate %s landed but no zone found; keep tracking (%.0fs left)", tostring(key), ZONE_SUPPLY_NOZONE_TTL - age))
                    entry._lastNoZoneLog = now
                  end
                else
                  zoneSupplyDebug(string.format("Crate %s landed but no zone for %.0fs; clearing", tostring(key), age))
                  zoneSupplyCrates[key] = nil
                end
              end
            end
              end
          else
            local dtype = entry.deliveryType or (entry.warehouseMeta and "warehouse") or "zone"
            if entry.wasAirborne then
              zoneSupplyDebug(string.format("Crate %s still airborne agl=%.2f type=%s", tostring(key), agl, tostring(dtype)))
            end
          end
        end
      end
    end
  end
  return readyCount
end

zoneSupplyApplyOne = function(key)
  local entry = zoneSupplyCrates[key]
  if not entry then return end

  local cargo = entry.cargo
  local staticObj = (cargo and cargo.GetPositionable and cargo:GetPositionable()) or entry.static
  if not staticObj or not staticObj:IsAlive() then
    zoneSupplyCrates[key] = nil
    return
  end

  local coord = staticObj:GetCoordinate()
  if not coord then return end
  local vec3 = coord:GetVec3()
  if not vec3 then return end

  local ground = land.getHeight({ x = vec3.x, y = vec3.z })
  local agl = vec3.y - ground
  if entry._isC130 and (not entry.detached or not entry._wasUnloaded) then
    return
  end
  if agl > ZONE_SUPPLY_AGL_THRESHOLD and not entry._wasUnloaded then
    return
  end

  local zoneName = entry._zoneName
  local zoneContainer = nil
  if not zoneName then
    zoneContainer = bc and bc:getZoneOfPoint(vec3) or nil
    zoneName = zoneContainer and zoneContainer.zone or nil
  end
  if not zoneName and supplyZones and ZONE then
    for i = 1, #supplyZones do
      local zName = supplyZones[i]
      local mooseZone = getSupplyZoneWrapper(zName)
      if mooseZone and mooseZone:IsCoordinateInZone(coord) then
        zoneName = zName
        break
      end
    end
  end
  if not zoneName then
    return
  end
  if entry.pickupZone and zoneName == entry.pickupZone then
    if entry.deliveryType == "warehouse" and entry.warehouseMeta and WarehouseLogistics == true then
      local meta = entry.warehouseMeta
      local baseAmount = meta.amount
      if type(baseAmount) == "number" and baseAmount > 0 then
        local okAdj, adjMsg = adjustWarehouseStockAtZone(zoneName, baseAmount, meta.categories)
        if CTLD_Logging then
          trigger.action.outText(string.format("[ZoneSupply][Return][Warehouse] %s %s %s %s", tostring(okAdj), tostring(adjMsg), tostring(zoneName), tostring(baseAmount)), 15)
          env.info("[ZoneSupply][Return][Warehouse] " .. tostring(okAdj) .. " " .. tostring(adjMsg) .. " " .. tostring(zoneName) .. " " .. tostring(baseAmount))
        end
      end
      local sObj = (entry.cargo and entry.cargo.GetPositionable and entry.cargo:GetPositionable()) or entry.static
      if sObj and sObj.IsAlive and sObj:IsAlive() then
        zoneSupplyEnqueueRemoval(sObj,0)
      end
      local grp = resolveZoneSupplyGroup(entry.groupName)
      local T = grp and getCtldGroupTranslator(grp) or getFootholdLocalization():ForLocale()
      sendZoneSupplyMessage(entry, T:Format("CTLD_SUPPLIES_RETURNED_TO_ZONE", ctldLocalizedCargoLabel(T, meta.label or "Supplies"), zoneName))
      zoneSupplyCrates[key] = nil
    end
    return
  end

  local isCtldZone = false
  local zoneObj = bc and bc:getZoneByName(zoneName) or nil
  if zoneObj then
    if not zoneObj.active then
      return
    end
  else
    if not (entry.deliveryType == "warehouse" and entry.warehouseMeta) then
      return
    end
    if not isCtldSupplyZoneName(zoneName) then
      return
    end
    if WarehouseLogistics ~= true then
      return
    end
    local storage = getZoneStorageHandle(zoneName)
    if not storage then
      return
    end
    isCtldZone = true
  end

  if not isCtldZone then
    if zoneObj.side == 1 then
      zoneSupplyDestroyNow(key, entry, zoneName, "enemy zone")
      return
    end
  end

  if entry.deliveryType == "warehouse" and entry.warehouseMeta then
    if not isCtldZone then
      if zoneObj.side == 1 then
        zoneSupplyDestroyNow(key, entry, zoneName, "enemy zone")
        return
      end

      if zoneObj.side == 0 then
        if not entry.neutralTimeoutScheduled then
          entry.neutralTimeoutScheduled = true
          timer.scheduleFunction(function()
            if zoneSupplyCrates[key] then
              local z = bc and bc:getZoneByName(zoneName) or nil
              if z and z.side == 2 then
                return -- became friendly; let normal processing deliver
              end
              zoneSupplyDestroyNow(key, nil, zoneName, "neutral zone timeout")
            end
          end, {}, timer.getTime() + ZONE_SUPPLY_DESTROY_DELAY)
        end
        return
      end

      if zoneObj.side ~= 2 then
        return
      end
    end
    if WarehouseLogistics ~= true then
      zoneSupplyDestroyNow(key, entry, zoneName, "warehouse logistics disabled")
      return
    end
    local storage, abName = getZoneStorageHandle(zoneName)
    if not storage then
      zoneSupplyDestroyNow(key, entry, zoneName, "no storage")
      return
    end
    local meta = entry.warehouseMeta
    local okAdj, adjMsg = adjustWarehouseStockAtZone(zoneName, meta.amount, meta.categories)
    if not okAdj then
      zoneSupplyDestroyNow(key, entry, zoneName, "no applicable inventory")
      return
    end
    local staticObj = (entry.cargo and entry.cargo.GetPositionable and entry.cargo:GetPositionable()) or entry.static
    if staticObj and staticObj.IsAlive and staticObj:IsAlive() then
      zoneSupplyEnqueueRemoval(staticObj,0)
    end
    c130SupplyLogOnce(entry, key, "_fhLogDeliver", "DELIVER", string.format("zone=%s verb=warehouse", tostring(zoneName)))
    if not (entry.pickupZone and zoneName == entry.pickupZone) then
      local pname = resolveZoneSupplyPlayer(entry)
      local reward = meta.reward or ((meta.categories and #meta.categories > 1) and 100 or 50)
      if pname then
        trigger.action.outTextForCoalition(2, L10N:Format("CTLD_SUPPLIES_DELIVERED_BY", ctldLocalizedCargoLabel(L10N, meta.label or "Supplies"), zoneName, tostring(pname)), 15)
        if warehouseSupplyMissionTargetZone == zoneName and not warehouseSupplyMissionWinner then
          warehouseSupplyMissionWinner = pname
        end
        if bc.playerContributions[2][pname] ~= nil then
          bc:addContribution(pname, 2, reward)
          bc:addTempStat(pname, "Warehouse delivery", 1)
        end
      end
    end
    simulateLandingForEntryIfOnGround(entry, zoneName)
    zoneSupplyCrates[key] = nil
    return
  end

  -- IMPORTANT: re-evaluate side NOW (may have changed after a previous crate captured).
  if zoneObj.side == 0 then
    zoneObj:capture(2)
    grantZoneBundle(zoneName)
    finalizeZoneSupplyDelivery(key, entry, zoneName, "captured", "Zone capture", ZONE_SUPPLY_CAPTURE_REWARD)
    return
  end

  local needSupply = zoneObj.canRecieveSupply and zoneObj:canRecieveSupply() or false
  if needSupply then
    zoneObj:upgrade()
    grantZoneBundle(zoneName)
    finalizeZoneSupplyDelivery(key, entry, zoneName, "upgraded", "Zone upgrade", ZONE_SUPPLY_UPGRADE_REWARD)
  else
    grantZoneBundle(zoneName)

    local pname = resolveZoneSupplyPlayer(entry)
    local meta = entry.warehouseMeta or (entry.cargoName and WAREHOUSE_SUPPLY_TYPES[entry.cargoName]) or nil
    local reward = (meta and meta.reward) or 150
    local label = (meta and meta.label) or "10 of everything"

    if pname and bc.playerContributions[2][pname] ~= nil then
      bc:addContribution(pname, 2, reward)
      bc:addTempStat(pname, "Warehouse delivery", 1)
      trigger.action.outTextForCoalition(2, L10N:Format("CTLD_SUPPLIES_DELIVERED_BY", ctldLocalizedCargoLabel(L10N, label), zoneName, tostring(pname)), 15)
    end

    if not entry.warnedNoNeed then
      sendZoneSupplyLocalizedMessage(entry, "CTLD_ZONE_SUPPLY_NOT_NEEDED_WAREHOUSE_APPLIED", nil, zoneName)
      entry.warnedNoNeed = true
    end

    local sObj = (entry.cargo and entry.cargo.GetPositionable and entry.cargo:GetPositionable()) or entry.static
    if sObj and sObj.IsAlive and sObj:IsAlive() then
      zoneSupplyEnqueueRemoval(sObj,0) -- destroyed after ZONE_SUPPLY_DESTROY_DELAY
    end
    zoneSupplyCrates[key] = nil
  end
end


zoneSupplyProcessReadyQueue = function()
  if zoneSupplyProcessRunning then
    zoneSupplyProcessQueued = true
    return
  end

  zoneSupplyProcessRunning = true
  zoneSupplyProcessQueued = false

  local function isNeutralZoneForWarehouse(entry)
    if not entry or entry.deliveryType ~= "warehouse" then return false end
    local zn = entry._zoneName
    if not (zn and bc and bc.getZoneByName) then return false end
    local z = bc:getZoneByName(zn)
    return z and z.side == 0
  end

  local function pickNextKey()
    local bestKey, bestPrio = nil, nil
    local hadAnyReady = false

    for key, entry in pairs(zoneSupplyCrates) do
      if entry and entry._ready then
        hadAnyReady = true

        local isWh = (entry.deliveryType == "warehouse")
        if not isWh then
          local prio = 1
          if (not bestPrio) or prio < bestPrio or (prio == bestPrio and tostring(key) < tostring(bestKey)) then
            bestKey, bestPrio = key, prio
          end
        else
          if not isNeutralZoneForWarehouse(entry) then
            local prio = 2
            if (not bestPrio) or prio < bestPrio or (prio == bestPrio and tostring(key) < tostring(bestKey)) then
              bestKey, bestPrio = key, prio
            end
          end
        end
      end
    end

    return bestKey, hadAnyReady
  end

  local function tryFireLandingOnce()
    if not (zoneSupplyLandingOnce and zoneSupplyLandingOnce.pending) then return end
    if zoneSupplyLandingOnce.scheduled then return end
    zoneSupplyLandingOnce.scheduled = true

    local pending = zoneSupplyLandingOnce.pending
    local delay = zoneSupplyLandingOnce.delay or 5

    SCHEDULER:New(nil, function()
      zoneSupplyLandingOnce.scheduled = false
      zoneSupplyLandingOnce.pending = nil

      local unitCap = pending.unit
      if not (unitCap and unitCap.isExist and unitCap:isExist()) then return end
      if Utils and Utils.isInAir and Utils.isInAir(unitCap) then return end

      local landingEvent = {
        id = world.event.S_EVENT_LAND,
        time = timer.getAbsTime(),
        initiator = unitCap,
        initiatorPilotName = pending.playerName,
        initiator_unit_type = unitCap:getTypeName(),
        initiator_coalition = 2,
        skipRewardMsg = true,
      }
      world.onEvent(landingEvent)
    end, {}, delay, 0)
  end

  local function step()
    local key, hadAnyReady = pickNextKey()

    if not key then
      zoneSupplyProcessRunning = false

      if zoneSupplyProcessQueued then
        zoneSupplyProcessQueued = false
        zoneSupplyProcessReadyQueue()
        return
      end

      if hadAnyReady then
        timer.scheduleFunction(function() zoneSupplyProcessReadyQueue() end, {}, timer.getTime() + 3)
        return
      end

      tryFireLandingOnce()
      zoneSupplyScheduleCleanup()
      return
    end

    zoneSupplyApplyOne(key)
    timer.scheduleFunction(function() step() end, {}, timer.getTime() + 3)
  end

  step()
end

local function selectOldestUnit(unitTable, cargoName, predicate)
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

local function destroyTrackedGroup(entry)
  if not entry or not entry.groupName then return end
  local dcsGroup = GROUP:FindByName(entry.groupName)
  if dcsGroup and dcsGroup:IsAlive() then
    dcsGroup:Destroy()
  end
end

local function extractCargoItems(Cargo)
  local items = {}
    local function push(item)
        if item and item.GetName then
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

  ---------------------------------------------------------------------------
  -- FARPs: Build + Tracking
  ---------------------------------------------------------------------------

     local FARPFreq = 129
     local FARPName = 1

     local FARPClearnames = {
       [1]="London",
       [2]="Dallas",
       [3]="Paris",
       [4]="Moscow",
       [5]="Berlin",
       [6]="Rome",
       [7]="Madrid",
       [8]="Warsaw",
       [9]="Dublin",
       [10]="Perth",
       [11]="Stockholm",
       }
local BuiltFARPCoordinates = {}
local SpawnedFARPsFromSave = 0
local NextFarpSaveSeq = 0


function BuildAFARP(Coordinate, stamp)
  if bc:getZoneOfPoint(Coordinate:GetVec3()) then return end
  local saveName = nil
  local saveSeq = nil
  if type(stamp) == "table" then
    saveName = stamp.name
    saveSeq = stamp.seq or stamp.timestamp
  else
    saveSeq = stamp
  end
  local isFromSave = (saveSeq ~= nil)
  if isFromSave then
    if SpawnedFARPsFromSave >= MAX_SAVED_FARPS then
      return
    else
      SpawnedFARPsFromSave = SpawnedFARPsFromSave + 1
    end
  end

  if isFromSave then
    saveSeq = tonumber(saveSeq) or 0
    if saveSeq > NextFarpSaveSeq then
      NextFarpSaveSeq = saveSeq
    end
  else
    NextFarpSaveSeq = (NextFarpSaveSeq or 0) + 1
    saveSeq = NextFarpSaveSeq
  end

  local coord          = Coordinate
  local FarpNameNumber = ((FARPName - 1) % 11) + 1
  local FName          = saveName or FARPClearnames[FarpNameNumber]
  if not isFromSave and not saveName then
    local totalNames = #FARPClearnames
    local tryIndex = FarpNameNumber
    for i = 1, totalNames do
      local tryName = FARPClearnames[tryIndex]
      if type(tryName) ~= "string" then
        tryName = tostring(tryName)
      end
      if not tryName:find("^CTLD FARP ") then
        tryName = "CTLD FARP " .. tryName
      end
      if not AIRBASE:FindByName(tryName) then
        FarpNameNumber = tryIndex
        FName = FARPClearnames[tryIndex]
        break
      end
      tryIndex = tryIndex + 1
      if tryIndex > totalNames then
        tryIndex = 1
      end
    end
  end

  FARPFreq = FARPFreq + 1
  FARPName = FARPName + 1
  if type(FName) ~= "string" then
    FName = tostring(FName)
  end
  if not FName:find("^CTLD FARP ") then
    FName = "CTLD FARP " .. FName
  end

  ZONE_RADIUS:New(FName, coord:GetVec2(), 150, false)


  if Era=="Coldwar" then
      UTILS.SpawnFARPAndFunctionalStatics(FName, coord, ENUMS.FARPType.INVISIBLE, Foothold_ctld.coalition, country.id.USA, FarpNameNumber, FARPFreq, radio.modulation.AM, nil, nil, nil, 10000, 0,0,nil, true, true, 3, 80, 80)
  else
      UTILS.SpawnFARPAndFunctionalStatics(FName, coord, ENUMS.FARPType.INVISIBLE, Foothold_ctld.coalition, country.id.USA, FarpNameNumber, FARPFreq, radio.modulation.AM, nil, nil, nil, 10000, 0,1073741823,nil, true, true, 3, 80, 80)
  end
  Foothold_ctld:AddCTLDZone(FName, CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, false)
  MESSAGE:New(L10N:Format("DYNAMIC_FARP_IN_OPERATION", FName), 15):ToBlue()
  Foothold_ctld:RemoveStockCrates("CTLD_TROOP_FOB", 1)

  table.insert(BuiltFARPCoordinates, {
    name = FName,
    coord = Coordinate,
    seq = saveSeq,
    timestamp = saveSeq, -- kept for backward compatibility with older code
  })

  bc:registerDynamicFarp(FName, coord, Foothold_ctld.coalition)

if WarehouseLogistics == true and WarehousePersistence and WarehousePersistence.RegisterExtraAirbase then
  WarehousePersistence.RegisterExtraAirbase(FName)
end

  SCHEDULER:New(nil, function() bc:CopyWarehouse(FName, isFromSave) end, {}, 1)

  if not NextMarkupId then NextMarkupId = 120000 end
  local markId = NextMarkupId; NextMarkupId = NextMarkupId + 1
  trigger.action.circleToAll(-1, markId, coord:GetVec3(), 150,{0,0,1,1},{0,0,1,0.25},1)
  trigger.action.setMarkupTypeLine(markId, 2)
  trigger.action.setMarkupColor(markId, {0,1,0,1})

  local textId = NextMarkupId; NextMarkupId = NextMarkupId + 1
  local textPoint = {x = coord.x, y = coord.y, z = coord.z + 150}
  trigger.action.textToAll(-1, textId, textPoint,{0,0,0.7,0.8},{0.7,0.7,0.7,0.8},18,true,FName)
  trigger.action.setMarkupText(textId, FName)

end



Foothold_ctld.buildRunning = 0

function Foothold_ctld:OnAfterCratesBuildStarted(From, Event, To, Group, Unit, CargoName)

    self.buildRunning = self.buildRunning + 1
    self:I(string.format(
        "[BUILD] start running=%d  group=%s  unit=%s  cargo=%s",
        self.buildRunning,
        Group and Group:GetName() or "nil",
        Unit  and Unit:GetName()  or "nil",
        CargoName or "nil"))

    if not CargoName then return end

    local obj          = self:_FindCratesCargoObject(CargoName)
    if not obj then return end

    if obj:GetStock() >= 5 then
        self:I(string.format("[RESERVE] stock already >=5 for %s (no action)", CargoName))
        return
    end
    local oldestIdx, victim, oldestTs = selectOldestUnit(GroundUnits, CargoName)
    if oldestIdx and victim then
        self:I(string.format("[RESERVE] DELETE oldest %s ts=%f (group=%s)", CargoName, oldestTs, victim.groupName))
        destroyTrackedGroup(victim)
        if Group then messageCtldToGroup(Group, "CTLD_LIMIT_REACHED_REMOVED_OLDEST", 12, CargoName, CargoName, victim.groupName) end
        table.remove(GroundUnits, oldestIdx)
        self:AddStockCrates(CargoName, 1)
        self:I(string.format("[RESERVE] stock was 0 → +1 refunded for %s", CargoName))
    else
        self:I(string.format("[RESERVE] no existing %s groups to delete", CargoName))
    end
end

function Foothold_ctld:OnAfterCratesBuild(From, Event, To, Group, Unit, Vehicle)

    if self.buildRunning > 0 then
    self.buildRunning = self.buildRunning - 1
  end
    local currentTime = timer.getTime()
    local groupName   = Vehicle:GetName() or "unknown"

    if string.find(groupName,"CTLD_TROOP_FOB",1,true) then
        local Coord = Vehicle:GetCoordinate()
        Vehicle:Destroy(false)
        BuildAFARP(Coord)
        return
    end

    if not Group then return end

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
            local tLen = #templateText
            if tLen > bestTemplateLen then
              bestTemplateLen = tLen
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

    local mergeProfile, mergeRole = samMergeResolveComponentProfileRole(Vehicle, cargoName)
    if mergeProfile and mergeRole then
      local mergeDistanceOverride = nil
      if Group and Group.GetName then
        local helperName = Group:GetName() or ""
        if string.find(helperName, "^CTLD_C130_HELPER_") then
          local engineerRange = tonumber(self.EngineerSearch)
          if engineerRange and engineerRange > 0 then
            mergeDistanceOverride = engineerRange
          end
        end
      end
      local merged = samMergeTryMergeComponentIntoNearbySystem(self, Group, Vehicle, cargoName, mergeRole, mergeProfile, mergeDistanceOverride)
      if merged then
        return
      end
    end

    local maxTimestamp = 0
    for _, group in ipairs(GroundUnits) do
        if group.CargoName == cargoName and group.Timestamp > maxTimestamp then
            maxTimestamp = group.Timestamp
        end
    end

    local cargoObject      = self:_FindCratesCargoObject(cargoName)
    local currentStock     = cargoObject and cargoObject:GetStock() or 0
    local newTimestamp     = (maxTimestamp > 0) and (maxTimestamp + 1) or currentTime
    local configuredMax    = cargoObject and cargoObject:GetStock0() or 999
    self:I(string.format("OnAfterCratesBuild: cargoName=%s, stock0=%d, currentStock=%d", cargoName, configuredMax, currentStock))

    local groupExists = false
    for _, group in ipairs(GroundUnits) do
        if group.groupName == groupName then
            group.Timestamp = newTimestamp
            group.Stock     = currentStock
            groupExists     = true
            break
        end
    end

    if not groupExists then
        table.insert(GroundUnits, {
            groupName  = groupName,
            Timestamp  = newTimestamp,
            CargoName  = cargoName,
            Stock      = currentStock
        })
    end

    for _, g in ipairs(GroundUnits) do
        if g.CargoName == cargoName then
            g.Stock = currentStock
        end
    end
end

adjustWarehouseStockAtZone = function(zoneName, deltaPerItem, categories)
  if WarehouseLogistics ~= true then return false, "WarehouseLogistics disabled" end
  if not zoneName then return false, "zoneName nil" end
  if type(deltaPerItem) ~= "number" or deltaPerItem == 0 then return false, "invalid deltaPerItem" end
  if not (STORAGE and STORAGE.FindByName) then return false, "STORAGE missing" end
  if not (WEAPONSLIST and WEAPONSLIST.GetItems) then return false, "WEAPONSLIST missing" end

  local storage, abName = getZoneStorageHandle(zoneName)
  if not storage then return false, "storage not found for " .. tostring(zoneName) end

  local cats = categories
  if type(cats) ~= "table" or #cats == 0 then
    cats = WEAPONSLIST.CategoryOrder or {}
  end

  local adjusted = 0
  local skippedLow = 0
  local forbiddenWeaponsInAllEraSet = {}
  for _, forbiddenWeapon in ipairs(ForbiddWeaponsInAllEra or {}) do
    forbiddenWeaponsInAllEraSet[forbiddenWeapon] = true
  end

  for i = 1, #cats do
    local catKey = cats[i]
    local delta = deltaPerItem * (WAREHOUSE_CATEGORY_MULTIPLIER[catKey] or 1)
    local need = -delta
    local items = getWarehouseItemsForCategory(catKey) or {}


    for j = 1, #items do
      local itemName = items[j]
      if itemName then
        if not forbiddenWeaponsInAllEraSet[itemName] then
          local current = storage:GetItemAmount(itemName) or 0

          if delta < 0 then
            if current >= need then
              storage:SetItem(itemName, current + delta)
              adjusted = adjusted + 1
            else
              skippedLow = skippedLow + 1
            end
          else
            if not (Era == "Coldwar" and WEAPONSLIST.IsRestricted(itemName)) then
              local addDelta = getStrictSmartWarehouseDelta(itemName, delta)
              if addDelta > 0 then
                storage:SetItem(itemName, current + addDelta)
                adjusted = adjusted + 1
              end
            end
          end
        end
      end
    end
  end

  for _, forbiddenWeapon in ipairs(ForbiddWeaponsInAllEra or {}) do
    storage:SetItem(forbiddenWeapon, 0)
  end

  if CTLD_Logging then
    trigger.action.outText(string.format(
      "[WarehouseAdjust] zone=%s ab=%s delta=%+d adjusted=%d skippedLow=%d",
      tostring(zoneName), tostring(abName), deltaPerItem, adjusted, skippedLow
    ), 15)
    env.info(string.format(
      "[WarehouseAdjust] zone=%s ab=%s delta=%+d adjusted=%d skippedLow=%d",
      tostring(zoneName), tostring(abName), deltaPerItem, adjusted, skippedLow
    ))
  end

  if adjusted == 0 then
    return false, string.format("no items adjusted (skippedLow=%d) at %s", skippedLow, tostring(abName))
  end

  return true, string.format("adjusted=%d skippedLow=%d at %s", adjusted, skippedLow, tostring(abName))
end


function Foothold_ctld:CanGetUnits(Group, Unit, Config, quantity, quiet)
  if CTLDCost ~= true then return true end
  local uname = Config and Config.Name or "none"
  local price = (priceOf and priceOf(uname)) or CTLD_DEFAULT_PRICE or 0
  local reqRank = (reqRankOf and reqRankOf(uname)) or 0
  local charge = price * (quantity or 1)
  if charge <= 0 or not bc then return true end
  local coal = Group:GetCoalition()
  local dcs = Group:GetDCSObject()
  local gid = dcs:getID()
  if type(bc.debit) == "function" then
    return bc:debit(coal, charge, gid, dcs, uname,reqRank) == true
  end
  bc.accounts[coal] = (bc.accounts[coal] or 0) - charge
  return true
end


function Foothold_ctld:CanGetTroops(Group, Unit, Cargo, quantity, Inject)
    if Inject then return true end
    if self.suppressmessages and tonumber(quantity)==1 then return true end
    if CTLDCost~=true then return true end
    local name=Cargo and Cargo.GetName and Cargo:GetName() or nil
    if type(name)~="string" then return true end
    local price=(priceOf and priceOf(name)) or CTLD_DEFAULT_PRICE or 0
    local reqRank=(reqRankOf and reqRankOf(name)) or 0
    local n=math.max(1,tonumber(quantity)or 1)
    local charge=price*n
    if charge<=0 or not bc then return true end
    local coal=Group:GetCoalition()
    local dcs=Group:GetDCSObject()
    local gid=dcs:getID()
    local reason=(n>1) and string.format("%dx %s",n,name) or name
    if type(bc.debit)=="function" then
    return bc:debit(coal,charge,gid,dcs,reason,reqRank)==true
    end
    bc.accounts[coal]=(bc.accounts[coal] or 0)-charge
  return true
end


function Foothold_ctld:CanGetCrates(Group, Unit, Cargo, number, drop, pack, quiet, suppressGetEvent)
  if drop or pack then return true end
  if WarehouseLogistics ~= true then return true end
  if not (Cargo and Cargo.GetName) then return true end

  local cname = Cargo:GetName()
  local meta = WAREHOUSE_SUPPLY_TYPES[cname]
  if not meta then return true end

  local baseAmount = meta.amount
  if type(baseAmount) ~= "number" or baseAmount <= 0 then
    local T = (Group and Group.IsAlive and Group:IsAlive()) and getCtldGroupTranslator(Group) or getFootholdLocalization():ForLocale()
    local label = ctldLocalizedCargoLabel(T, meta.label or cname or "cargo")
    sendCtldToGroupOrCoalition(Group, "CTLD_WAREHOUSE_MISCONFIGURED_INVALID_AMOUNT", 12, label)
    return false
end
  
  local perSet = Cargo:GetCratesNeeded() or 1
  if perSet < 1 then perSet = 1 end
  local requestNumber = tonumber(number) or perSet
  requestNumber = math.floor(requestNumber)
  if requestNumber < 1 then requestNumber = perSet end
  local requestedSets = math.floor((requestNumber + perSet - 1) / perSet)
  if requestedSets < 1 then requestedSets = 1 end
  local requiredAmount = baseAmount * requestedSets
  local pickupZone = updateLastPickupZone(Group, Unit)
  if not pickupZone then return false end

  local storage, abName = getZoneStorageHandle(pickupZone)
  local okStock = true
  local failReason = nil

  if not storage then
    okStock = false
    failReason = "no storage"
  else
    local categories = meta.categories or {}
    local missing = {}
    for i = 1, #categories do
      local cat = categories[i]
      local items = getWarehouseItemsForCategory(cat) or {}
      if #items == 0 then
        missing[#missing + 1] = ctldReasonToken("CTLD_REASON_NO_ITEMS", cat)
      else
        local sum = 0
        for j = 1, #items do
          local itemName = items[j]
          local amt = storage:GetItemAmount(itemName) or 0
          if amt > 0 then
            sum = sum + amt
          end
        end
        if sum < requiredAmount then
          missing[#missing + 1] = ctldReasonToken("CTLD_REASON_INSUFFICIENT_STOCK", cat)
        end
      end
    end
    if #missing > 0 then
      okStock = false
      failReason = missing
    end
  end

  if not okStock then
    local where = tostring(abName or pickupZone or "warehouse")
    local T = (Group and Group.IsAlive and Group:IsAlive()) and getCtldGroupTranslator(Group) or getFootholdLocalization():ForLocale()
    local label = ctldLocalizedCargoLabel(T, meta.label or cname or "cargo")
    local reasonText = ctldReasonListText(T, failReason or "not available")
    sendCtldToGroupOrCoalition(Group, "CTLD_WAREHOUSE_NOT_AVAILABLE", 12, label, where, reasonText)
    return false
  end

  if CTLDCost then
    local price = (priceOf and priceOf(cname)) or CTLD_DEFAULT_PRICE or 0
    local reqRank=(reqRankOf and reqRankOf(cname)) or 0
    local charge = price * requestedSets
    if charge > 0 and bc then
      local coal = Group:GetCoalition()
      local dcs = Group:GetDCSObject()
      local gid = dcs:getID()
      local reason = string.format("%dx %s", requestedSets, cname)
      if type(bc.debit) == "function" then
        local ok = bc:debit(coal, charge, gid, dcs, reason, reqRank)
        if not ok then return false end
      else
        bc.accounts[coal] = (bc.accounts[coal] or 0) - charge
      end
    end
  end

  local okAdj, adjMsg = adjustWarehouseStockAtZone(pickupZone, -requiredAmount, meta.categories)
  if CTLD_Logging then
    trigger.action.outText(string.format("[ZoneSupply][Debit][CTLD] %s %s", tostring(okAdj), tostring(adjMsg)), 15)
    env.info("[ZoneSupply][Debit][CTLD] " .. tostring(okAdj) .. " " .. tostring(adjMsg))
  end

  if not okAdj then
    local where = tostring(abName or pickupZone or "warehouse")
    local T = (Group and Group.IsAlive and Group:IsAlive()) and getCtldGroupTranslator(Group) or getFootholdLocalization():ForLocale()
    local label = ctldLocalizedCargoLabel(T, meta.label or cname or "cargo")
    local reasonText = ctldReasonText(T, adjMsg or "debit failed")
    sendCtldToGroupOrCoalition(Group, "CTLD_WAREHOUSE_REMOVE_FAILED", 12, label, where, reasonText)
    return false
  end

  return true
end

function Foothold_ctld:OnAfterRemoveCratesNearby(From, Event, To, Group, Unit, Cargotable)
  local inzone = self:IsUnitInZone(Unit,CTLD.CargoZoneType.LOAD)
  if not inzone then return end

 local zoneName = updateLastPickupZone(Group, Unit)

  local byName = {}
  for _,_cargo in pairs(Cargotable or {}) do
    local cargo = _cargo
    local name = cargo:GetName() or "none"
    byName[name] = (byName[name] or 0) + 1
  end

  local coal = Group:GetCoalition()
  local dcs = Group:GetDCSObject()
  local gid = dcs:getID()

  for name,count in pairs(byName) do
    local object = self:_FindCratesCargoObject(name)
    local perSet = (object and object:GetCratesNeeded()) or 1
    if perSet < 1 then perSet = 1 end
    local removedSets = math.floor((count + perSet - 1) / perSet)
    if removedSets < 1 then removedSets = 1 end

    if CTLDCost and bc and priceOf then
      local price = priceOf(name) or 0
      local refund = price * removedSets
      if refund > 0 then
        if bc.credit then
          bc:credit(coal, refund, gid, dcs, "remove: "..tostring(removedSets).."x "..name)
        else
          bc.accounts[coal] = (bc.accounts[coal] or 0) + refund
        end
      end
    end

    if WarehouseLogistics == true and zoneName and WAREHOUSE_SUPPLY_TYPES[name] then
      local meta = WAREHOUSE_SUPPLY_TYPES[name]
      local baseAmount = meta.amount
      if type(baseAmount) == "number" and baseAmount > 0 then
        local amount = baseAmount * removedSets
        local okAdj, adjMsg = adjustWarehouseStockAtZone(zoneName, amount, meta.categories)
        if CTLD_Logging then
          trigger.action.outText(string.format("[ZoneSupply][Refund][Warehouse] %s %s %s %d %s", tostring(okAdj), tostring(adjMsg), tostring(zoneName), amount, tostring(name)), 15)
          env.info("[ZoneSupply][Refund][Warehouse] " .. tostring(okAdj) .. " " .. tostring(adjMsg) .. " " .. tostring(zoneName) .. " " .. tostring(amount) .. " " .. tostring(name))
        end
      end
    end
  end
end

function Foothold_ctld:OnAfterGetCrates(From, Event, To, Group, Unit, Cargo)
  if CTLD_Logging then
    env.info("OnAfterGetCrates Event fired")
  end

  local unitName = nil
  if Unit and Unit.GetName then
    unitName = Unit:GetName()
  end

  local cargoItems = extractCargoItems(Cargo)
  if #cargoItems == 0 then
    if CTLD_Logging then
      trigger.action.outText("[ZoneSupply][Debug] OnAfterGetCrates: no cargo items", 15)
      env.info("OnAfterGetCrates: no cargo items")
    end
    return
  end

  local pickupZone = updateLastPickupZone(Group, Unit)
  if not pickupZone and supplyZones and ZONE and COORDINATE then
    local coordSource = nil
    if Unit and Unit.GetCoordinate then
      coordSource = Unit:GetCoordinate()
    elseif Group and Group.GetCoordinate then
      coordSource = Group:GetCoordinate()
    end
    if coordSource and coordSource.GetVec3 then
      local vec = coordSource:GetVec3()
      if vec then
        local coordObj = COORDINATE:NewFromVec3(vec)
        for i = 1, #supplyZones do
          local zoneName = supplyZones[i]
          local mooseZone = getSupplyZoneWrapper(zoneName)
          if mooseZone and mooseZone:IsCoordinateInZone(coordObj) then
            pickupZone = zoneName
            break
          end
        end
      end
    end
  end

  local groupName = Group and Group:GetName() or "nil"
  local playerName = Unit and Unit.GetPlayerName and Unit:GetPlayerName() or "nil"
  local names = {}
  local sawZoneSupplies = false
  local sawWarehouse = false

  for _, cargoItem in ipairs(cargoItems) do
    local cname = cargoItem.GetName and cargoItem:GetName() or "unknown"
    names[#names + 1] = cname

    if isZoneSupplyCargoItem(cargoItem) then
      sawZoneSupplies = true
      local carrierUnitObject = Unit and Unit:GetDCSObject() or nil
      RegisterTrackedSupplyCargo(cargoItem, pickupZone, groupName, playerName, unitName, cname, "zone", nil, carrierUnitObject)

    elseif WAREHOUSE_SUPPLY_TYPES[cname] then
      sawWarehouse = true
      local meta = WAREHOUSE_SUPPLY_TYPES[cname]
      local carrierUnitObject = Unit and Unit:GetDCSObject() or nil
      RegisterTrackedSupplyCargo(cargoItem, pickupZone, groupName, playerName, unitName, cname, "warehouse", meta, carrierUnitObject)
    end
  end

  local kind = (sawZoneSupplies and sawWarehouse) and "mixed" or (sawWarehouse and "warehouse") or (sawZoneSupplies and "zone-supply") or "other"
  local msg = string.format(
    "[CTLD] GetCrates by %s (player=%s) pickupZone=%s kind=%s cargo=%s",
    groupName,
    playerName,
    tostring(pickupZone),
    tostring(kind),
    table.concat(names, ", ")
  )
  if CTLD_Logging then
    env.info(msg)
    trigger.action.outText(msg, 10)
  end

  local shouldAutoBuild = self.UseC130LoadAndUnload and Unit and self:IsC130J(Unit)
  if shouldAutoBuild then
    local c130Items = {}
    for _, cargoItem in ipairs(cargoItems) do
      local cname = cargoItem.GetName and cargoItem:GetName() or nil
      if (not isZoneSupplyCargoItem(cargoItem)) and (not (cname and WAREHOUSE_SUPPLY_TYPES[cname])) then
        local crateObj = cname and self:_FindCratesCargoObject(cname) or nil
        if crateObj then
          c130Items[#c130Items + 1] = cargoItem
        end
      end
    end
    if #c130Items > 0 then
      registerC130AutoBuildSet(groupName, playerName, unitName, pickupZone, c130Items)
    end
  end
end

function Foothold_ctld:OnBeforeCratesPacked(From, Event, To, Group, Unit, Cargo, PackedGroup)
  if not (PackedGroup and PackedGroup.IsAlive and PackedGroup:IsAlive()) then
    return
  end

  local cargoName = Cargo and Cargo.GetName and Cargo:GetName() or nil
  local packedGroupName = PackedGroup.GetName and PackedGroup:GetName() or nil
  local profile = nil

  for _, candidate in pairs(SAM_MERGE_PROFILES) do
    if samMergeSystemCargoMatches(candidate, cargoName) or samMergeIsSystemGroupName(candidate, packedGroupName) then
      profile = candidate
      break
    end
  end

  if not profile then
    return
  end

  local counts = samMergeCountRolesInGroup(profile, PackedGroup)
  local spawnedBefore = #(self.Spawned_Cargo or {})
  local refunded = {}
  local refundedMessages = {}

  for _, role in ipairs(profile.role_order or {}) do
    local baseline = tonumber(profile.baseline_counts and profile.baseline_counts[role]) or 0
    local current = tonumber(counts[role]) or 0
    local extra = current - baseline

    if extra > 0 then
      local addonCargo, addonCargoName, addonTemplateId = samMergeResolveRefundCargo(self, profile, role)
      if addonCargo then
        local perSet = addonCargo:GetCratesNeeded() or 1
        local requestNumber = extra * perSet
        self:_GetCrates(Group, Unit, addonCargo, requestNumber, false, true, true, true)
        refunded[#refunded + 1] = string.format("%s x%d", addonCargoName, extra)
        local T = getCtldGroupTranslator(Group)
        refundedMessages[#refundedMessages + 1] = T:Format("CTLD_CRATES_POSITIONED", requestNumber, ctldLocalizedCargoLabel(T, addonCargoName))
      else
        samMergeLog(self, profile, string.format(
          "Pack refund skipped: no CTLD cargo mapping for role=%s template=%s.",
          tostring(role),
          tostring(addonTemplateId)
        ))
      end
    end
  end

  if #refunded <= 0 then
    return
  end

  local spawnedAddonCargo = {}
  for idx = spawnedBefore + 1, #(self.Spawned_Cargo or {}) do
    local cargoItem = self.Spawned_Cargo[idx]
    if cargoItem then
      spawnedAddonCargo[#spawnedAddonCargo + 1] = cargoItem
    end
  end

  if #spawnedAddonCargo > 0 and self.UseC130LoadAndUnload and Unit and self:IsC130J(Unit) then
    self:OnAfterGetCrates(From, Event, To, Group, Unit, spawnedAddonCargo)
  end

  for _, refundedMessage in ipairs(refundedMessages) do
    self:_SendMessage(refundedMessage, 10, false, Group)
  end

  samMergeLog(self, profile, string.format(
    "Pack refund prepared for %s: %s.",
    tostring(packedGroupName or cargoName or "unknown"),
    table.concat(refunded, ", ")
  ))
end

function Foothold_ctld:OnAfterCratesPacked(From, Event, To, Group, Unit, Cargo)
  if not (self.UseC130LoadAndUnload and Unit and self:IsC130J(Unit)) then
    return
  end

  self:OnAfterGetCrates(From, Event, To, Group, Unit, Cargo)
end

if lfs then
  ---------------------------------------------------------------------------
  -- FARPs: Persistence (File I/O)
  ---------------------------------------------------------------------------

	local _ctldBaseName = (FootholdSaveBaseName and tostring(FootholdSaveBaseName) ~= "") and tostring(FootholdSaveBaseName) or nil
	-- FootholdSaveBaseName is a mission invariant (set in the setup file).
	FarpFileName = _ctldBaseName .. "_CTLD_FARPS.csv"

function SaveFARPS()
  local path = Foothold_ctld.filepath
  local filename = FarpFileName
  local data = "FARP COORDINATES\n"

  -- 1) Filter to FARPs that still exist as airbases.
  local candidates = {}
  for i = 1, #BuiltFARPCoordinates do
    local e = BuiltFARPCoordinates[i]
    local name = e and e.name
    if name and AIRBASE and AIRBASE.FindByName then
      local AFB = AIRBASE:FindByName(name)
      if AFB then
        candidates[#candidates + 1] = e
      end
    end
  end

  -- 2) Sort newest-first by existing sequence.
  table.sort(candidates, function(a, b)
    local sa = tonumber(a and (a.seq or a.timestamp)) or 0
    local sb = tonumber(b and (b.seq or b.timestamp)) or 0
    return sa > sb
  end)

  -- 3) Keep only up to FARPStock (or all if not set).
  local keepMax = tonumber(FARPStock) or #candidates
  if keepMax < 0 then keepMax = 0 end
  local kept = {}
  for i = 1, math.min(#candidates, keepMax) do
    kept[#kept + 1] = candidates[i]
  end

  -- 4) Rebase sequence numbers to 1..N (oldest->newest) to avoid unbounded growth.
  local rebased = {}
  for i = 1, #kept do rebased[i] = kept[i] end
  table.sort(rebased, function(a, b)
    local sa = tonumber(a and (a.seq or a.timestamp)) or 0
    local sb = tonumber(b and (b.seq or b.timestamp)) or 0
    return sa < sb
  end)

  for i = 1, #rebased do
    local e = rebased[i]
    e.seq = i
    e.timestamp = i
  end
  NextFarpSaveSeq = #rebased

  -- 5) Write file newest-first (highest seq first).
  table.sort(rebased, function(a, b)
    return (tonumber(a and a.seq) or 0) > (tonumber(b and b.seq) or 0)
  end)

  for _, e in ipairs(rebased) do
    local FName = e.name
    local coord = e.coord
    if FName and coord and coord.GetVec2 then
      local vec2 = coord:GetVec2()
      data = data .. string.format("%d;%s;%f;%f;\n", tonumber(e.seq) or 0, tostring(FName), vec2.x, vec2.y)
    end
  end

  -- Keep the in-memory list aligned with what we persist.
  BuiltFARPCoordinates = rebased
  
  if UTILS.SaveToFile(path,filename,data) then
    --BASE:I("***** FARP Positions saved successfully!")
  else
    BASE:E("***** ERROR Saving FARP Positions!")
  end
end

 
function LoadFARPS()
  local path = Foothold_ctld.filepath
  local filename = FarpFileName
  local okay,data = UTILS.LoadFromFile(path,filename)
  if okay then
    BASE:I("***** FARP Positions loaded successfully!")
    -- remove header
    table.remove(data, 1)

    local entries = {}
    for _, _entry in ipairs(data) do
      if _entry and tostring(_entry):gsub("%s+", "") ~= "" then
        local dataset = UTILS.Split(_entry, ";")
        local a = tonumber(dataset[1])
        local b = dataset[2]
        local c = dataset[3]
        local d = dataset[4]

        local bx = tonumber(b)
        local cy = tonumber(c)
        local cx = tonumber(c)
        local dy = tonumber(d)

        if a and b and cx and dy then
          -- New format: seq;name;x;y;
          entries[#entries + 1] = { seq = a, name = tostring(b), x = cx, y = dy }
        elseif a and bx and cy then
          -- Previous format: seq;x;y;
          entries[#entries + 1] = { seq = a, name = nil, x = bx, y = cy }
        else
          local x = tonumber(dataset[1])
          local y = tonumber(dataset[2])
          if x and y then
            -- Old format: x;y;
            entries[#entries + 1] = { seq = nil, name = nil, x = x, y = y }
          end
        end
      end
    end

    local hasSeq = false
    for i = 1, #entries do
      if tonumber(entries[i].seq) then
        hasSeq = true
        break
      end
    end

    if hasSeq then
      table.sort(entries, function(e1, e2)
        return (tonumber(e1.seq) or 0) > (tonumber(e2.seq) or 0)
      end)
    else
      -- Backward compatibility: older files were written oldest->newest;
      -- make a deterministic sequence so newest entries win.
      for i = 1, #entries do
        entries[i].seq = i
      end
      table.sort(entries, function(e1, e2)
        return (tonumber(e1.seq) or 0) > (tonumber(e2.seq) or 0)
      end)
    end

    local maxToSpawn = MAX_SAVED_FARPS or 0
    if type(maxToSpawn) ~= "number" or maxToSpawn <= 0 then
      maxToSpawn = #entries
    end

    for i = 1, math.min(#entries, maxToSpawn) do
      local e = entries[i]
      local coord = COORDINATE:NewFromVec2({ x = e.x, y = e.y })
      BuildAFARP(coord, { seq = e.seq, name = e.name })
    end
  else
    BASE:E("***** ERROR Loading FARP Positions!")
  end
end

LoadIRISAugments = function()
  local path = Foothold_ctld.filepath
  local filename = Foothold_ctld.filename
  local ok, lines = UTILS.LoadFromFile(path, filename)
  if not ok or type(lines) ~= "table" then
    samMergeLog(Foothold_ctld, nil, string.format("SAM restore skipped: failed reading %s.", tostring(filename)))
    return {}
  end

  local function isSystemSaveRow(profile, parts)
    local groupName = parts[1]
    local cargoName = parts[5]
    local cargoTemplates = parts[6]
    return samMergeIsSystemTemplateText(profile, cargoTemplates)
      or samMergeIsSystemTemplateText(profile, groupName)
      or samMergeSystemCargoMatches(profile, cargoName)
  end

  local function parseStructureCounts(profile, structureText)
    local counts = samMergeRoleCountTable(profile)
    for unitType, countText in string.gmatch(tostring(structureText or ""), "([^=;]+)==(%d+)") do
      local cleanUnitType = tostring(unitType or ""):gsub("^%s+", ""):gsub("%s+$", "")
      local role = samMergeRoleFromUnitType(profile, cleanUnitType)
      if role then
        counts[role] = tonumber(countText) or 0
      end
    end
    return counts
  end

  local rows = {}
  local profileCounts = {}
  for i = 2, #lines do
    local line = lines[i]
    if line and tostring(line):gsub("%s+", "") ~= "" then
      local parts = UTILS.Split(line, ",")
      for _, profileKey in ipairs(SAM_MERGE_PROFILE_ORDER) do
        local profile = SAM_MERGE_PROFILES[profileKey]
        if isSystemSaveRow(profile, parts) then
          local x = tonumber(parts[2])
          local y = tonumber(parts[4])
          local counts = parseStructureCounts(profile, parts[10])
          local extras = {}
          local hasExtra = false

          for _, role in ipairs(profile.role_order or {}) do
            local baseline = (profile.baseline_counts and profile.baseline_counts[role]) or 0
            local extra = math.max(0, (counts[role] or 0) - baseline)
            extras[role] = extra
            if extra > 0 then
              hasExtra = true
            end
          end

          if x and y and hasExtra then
            rows[#rows + 1] = {
              profile_key = profileKey,
              x = x,
              y = y,
              extras = extras,
            }
            profileCounts[profileKey] = (profileCounts[profileKey] or 0) + 1
          end
          break
        end
      end
    end
  end

  for _, profileKey in ipairs(SAM_MERGE_PROFILE_ORDER) do
    local count = profileCounts[profileKey] or 0
    if count > 0 then
      samMergeLog(Foothold_ctld, SAM_MERGE_PROFILES[profileKey], string.format("Loaded %d augment rows from %s", count, tostring(filename)))
    end
  end
  samMergeLog(Foothold_ctld, nil, string.format("Loaded %d SAM augment rows from CTLD save %s", #rows, tostring(filename)))
  return rows
end

ApplyIRISAugments = function(rows)
  if type(rows) ~= "table" or #rows == 0 then
    return false
  end

  local candidatesByProfile = {}
  for _, profileKey in ipairs(SAM_MERGE_PROFILE_ORDER) do
    candidatesByProfile[profileKey] = {}
  end

  local seen = {}
  for _, entry in ipairs(GroundUnits) do
    local gName = entry and entry.groupName or nil
    if gName and not seen[gName] then
      seen[gName] = true
      local grp = GROUP:FindByName(gName)
      if grp and grp:IsAlive() then
        local coord = grp:GetCoordinate()
        if coord then
          for _, profileKey in ipairs(SAM_MERGE_PROFILE_ORDER) do
            local profile = SAM_MERGE_PROFILES[profileKey]
            if samMergeSystemCargoMatches(profile, entry and entry.CargoName or nil) or samMergeIsSystemGroupName(profile, gName) then
              candidatesByProfile[profileKey][#candidatesByProfile[profileKey] + 1] = {
                group = grp,
                groupName = gName,
                coord = coord,
                matched = false,
              }
              break
            end
          end
        end
      end
    end
  end

  local applied = 0
  local missingCandidatesLogged = {}

  for _, row in ipairs(rows) do
    local profile = samMergeProfileByKey(row.profile_key)
    if profile then
      local candidates = candidatesByProfile[row.profile_key] or {}
      if #candidates == 0 then
        if not missingCandidatesLogged[row.profile_key] then
          samMergeLog(Foothold_ctld, profile, "No system candidates available while applying augments.")
          missingCandidatesLogged[row.profile_key] = true
        end
      else
        local rowCoord = COORDINATE:NewFromVec2({ x = row.x, y = row.y })
        local best = nil
        local bestDist = nil

        for _, candidate in ipairs(candidates) do
          if not candidate.matched then
            local dist = rowCoord:Get2DDistance(candidate.coord)
            if dist <= IRIS_MERGE_DISTANCE and (not bestDist or dist < bestDist) then
              best = candidate
              bestDist = dist
            end
          end
        end

        if best then
          best.matched = true
          local oldGroup = best.group
          local oldGroupName = best.groupName
          local template, mergeMode, baseErr = samMergeGetBaseTemplate(profile, oldGroup)
          if template and type(template.units) == "table" and #template.units > 0 then
            local counts = samMergeCountRolesInTemplate(profile, template)
            local anchorUnit = template.units[1]
            local changed = false

            for _, role in ipairs(profile.role_order or {}) do
              local baseline = (profile.baseline_counts and profile.baseline_counts[role]) or 0
              local targetCount = baseline + ((row.extras and row.extras[role]) or 0)
              local currentCount = counts[role] or 0
              if targetCount > currentCount then
                local sourceTemplate = samMergeExtractUnitTemplateForRole(profile, template, role)
                if sourceTemplate then
                  for _ = 1, (targetCount - currentCount) do
                    local nextIndex = (template.units and #template.units or 0) + 1
                    if samMergeAppendUnitTemplateWithOffset(profile, template, sourceTemplate, anchorUnit, nextIndex) then
                      counts[role] = (counts[role] or 0) + 1
                      changed = true
                    end
                  end
                end
              end
            end

            if changed then
              reflowIrisTemplateLayout(profile, template, anchorUnit)
              local spawnName = string.format("%s-%d", tostring(profile.system_template or "CTLD_CARGO_SAM"), math.random(100000, 999999))
              local mergedGroup, err = samMergeSpawnMergedSystemTemplate(profile, template, spawnName)
              if mergedGroup then
                if oldGroup and oldGroup:IsAlive() then oldGroup:Destroy() end
                removeDroppedTroopGroupByName(Foothold_ctld, oldGroupName)
                trackDroppedTroopGroup(Foothold_ctld, mergedGroup)
                samMergeSyncGroundUnits(Foothold_ctld, profile, oldGroupName, nil, mergedGroup:GetName() or spawnName)
                applied = applied + 1
                best.group = mergedGroup
                best.groupName = mergedGroup:GetName() or spawnName
                best.coord = mergedGroup:GetCoordinate() or best.coord
                samMergeLog(Foothold_ctld, profile, string.format("Applied augments at %.0f/%.0f (dist=%.1f) mode=%s.", row.x, row.y, bestDist or -1, tostring(mergeMode)))
              else
                samMergeLog(Foothold_ctld, profile, string.format("Failed augment spawn for row %.0f/%.0f: %s", row.x, row.y, tostring(err)))
              end
            end
          else
            samMergeLog(Foothold_ctld, profile, string.format("Skipped augment row %.0f/%.0f: no merge base template (mode=%s err=%s).", row.x, row.y, tostring(mergeMode), tostring(baseErr)))
          end
        end
      end
    end
  end

  if applied > 0 then
    samMergeLog(Foothold_ctld, nil, string.format("Applied %d SAM augment rows.", applied))
  end
  return applied > 0
end

RunIrisOnePassStandaloneMerge = function(self)
  local context = self or Foothold_ctld
  local candidates = {}
  local seen = {}

  for _, entry in ipairs(GroundUnits) do
    local groupName = entry and entry.groupName or nil
    if groupName and not seen[groupName] then
      seen[groupName] = true
      local grp = GROUP:FindByName(groupName)
      if grp and grp:IsAlive() then
        local profile, role = samMergeResolveComponentProfileRole(grp, entry and entry.CargoName or nil)
        if profile and role then
          candidates[#candidates + 1] = {
            group = grp,
            cargoName = entry and entry.CargoName or nil,
            role = role,
            profile = profile,
          }
        end
      end
    end
  end

  local merged = 0
  for _, candidate in ipairs(candidates) do
    local didMerge = samMergeTryMergeComponentIntoNearbySystem(context, nil, candidate.group, candidate.cargoName, candidate.role, candidate.profile)
    if didMerge then
      merged = merged + 1
    end
  end

  samMergeLog(context, nil, string.format("One-pass SAM standalone merge checked=%d merged=%d.", #candidates, merged))
  return merged > 0
end

local LoadFARPTimer = TIMER:New(LoadFARPS)
LoadFARPTimer:Start(5)

local SaveFARPTimer = TIMER:New(SaveFARPS)
SaveFARPTimer:Start(30,300)

Foothold_ctld.enableLoadSave = true -- allow auto-saving and loading of files
Foothold_ctld.saveinterval = 300 -- save every 5 minutes
Foothold_ctld.filename = _ctldBaseName .. "_CTLD_Save.csv"
Foothold_ctld.filepath = FootholdSavePath or (lfs.writedir() .. "Missions\\Saves") -- example path
Foothold_ctld.eventoninject = true -- fire OnAfterCratesBuild and OnAfterTroopsDeployed events when loading (uses Inject functions)
Foothold_ctld.useprecisecoordloads = true -- Instead if slightly varyiing the group position, try to maintain it as is


function resetSaveFileAndFarp()
  -- 1) Overwrite the CTLD save file with empty data:
  local path     = Foothold_ctld.filepath
  local fileName = Foothold_ctld.filename
  if lfs and path then
    fileName = path .. "\\" .. fileName
  end
  local f = assert(io.open(fileName, "wb"))
  f:write("")
  f:close()
  
  -- 2) Overwrite the FARPs file with empty data too:
  local farpFile = FarpFileName
  if lfs and path then
    farpFile = path .. "\\" .. farpFile
  end
  local f2 = assert(io.open(farpFile, "wb"))
  f2:write("")
  f2:close()

  BuiltFARPCoordinates = {}
end

else
    MESSAGE:New(L10N:Get("CTLD_SAVE_LOAD_DISABLED_DESANITIZE"), 300):ToAll()
end

---------------------------------------------------------------------------
-- CTLD: Persistence Load Hook
---------------------------------------------------------------------------

Foothold_ctld:__Load(10)

function Foothold_ctld:OnAfterLoaded(From, Event, To, LoadedGroups)
  self:I("***** Groups Loaded! *****")

  local MaxAtSpawn = {}
  for rawName, limit in pairs(MAX_AT_SPAWN) do
    local k=tostring(rawName)
    if k~="" then
      if MaxAtSpawn[k] then
        if limit>MaxAtSpawn[k] then
          MaxAtSpawn[k]=limit
        end
      else
        MaxAtSpawn[k]=limit
      end
    end
  end

for i,_t in ipairs(LoadedGroups) do
  local gName=_t.Group:GetName() or "unknown"
  local ts=_t.TimeStamp or timer.getTime()
  local cName=tostring(_t.CargoName)
  local groupCoord=_t.Group:GetCoordinate()
  local groupPoint=groupCoord and groupCoord:GetVec3() or nil
  local skipRestore, nearestEnemyName, nearestEnemyNm = bc:_restorePointTooFarFromEnemy(groupPoint, 120)
  local cr=self:_FindCratesCargoObject(cName)
  local tr=self:_FindTroopsCargoObject(cName)
  if skipRestore then
    self:I(string.format("[RESTORE] skip loaded group=%s cargo=%s nearestEnemy=%s dist=%.1fNm limit=120.0Nm", gName, cName, tostring(nearestEnemyName), nearestEnemyNm or -1))
    if cr then
      self:AddStockCrates(cName, 1)
    end
    if tr then
      self:AddStockTroops(cName, 1)
    end
    if _t.Group:IsAlive() then
      _t.Group:Destroy()
    end
  else
    if cr then
      table.insert(GroundUnits,{groupName=gName,Timestamp=ts,Group=_t.Group,CargoName=cName,Stock=cr:GetStock() or 0})
    end
    if tr then
      table.insert(TroopUnits,{groupName=gName,Timestamp=ts,Group=_t.Group,CargoName=cName,Stock=tr:GetStock() or 0})
    end
  end
end

  EnforceMaxAtSpawnForTrackedUnits(GroundUnits, MaxAtSpawn, function(CargoName)
    Foothold_ctld:AddStockCrates(CargoName, 1)
  end)

  EnforceMaxAtSpawnForTrackedUnits(TroopUnits, MaxAtSpawn, function(CargoName)
    Foothold_ctld:AddStockTroops(CargoName, 1)
  end)
-- below a code that deletes the cargo that is left on the ground from last session.
  if self.Spawned_Cargo then
    for i=#self.Spawned_Cargo,1,-1 do
      local c=self.Spawned_Cargo[i]
      local s=c:GetPositionable()
      if s and s:IsAlive() then s:Destroy(false) end
      table.remove(self.Spawned_Cargo,i)
    end
  end
-- end of that.
  for uName,ld in pairs(self.Loaded_Cargo) do
    if ld and ld.Cargo then
      local newC={}
      local cNum=0
      for _,cg in ipairs(ld.Cargo) do
        local tp=cg:GetType()
        if tp==CTLD_CARGO.Enum.TROOPS or tp==CTLD_CARGO.Enum.ENGINEERS then
          table.insert(newC,cg)
        end
      end
      ld.Cargo=newC
      ld.Cratesloaded=cNum
      self.Loaded_Cargo[uName]=ld
    end
  end

  timer.scheduleFunction(function()
    local rows = LoadIRISAugments()
    if rows and #rows > 0 then
      ApplyIRISAugments(rows)
    end
    RunIrisOnePassStandaloneMerge(self)
  end, {}, timer.getTime() + 5)
end

zoneSet = SET_ZONE:New()
for _, zoneObj in ipairs(bc:getZones()) do
  local mooseZone = ZONE:New(zoneObj.zone)
  zoneSet:AddZone(mooseZone)
end

function playRandomSound(Group, soundCategory)
    local sounds = {
        unload = {
            "troops_unload_everybody_off.ogg",
            "troops_unload_get_off.ogg",
            "troops_unload_here_we_go.ogg",
            "troops_unload_moving_out.ogg",
            "troops_unload_thanks.ogg"
        },
        loading = {
            "troops_load_to_action.ogg",
            "troops_load_ready.ogg",
            "troops_load_ao.ogg",
        }
    }
    local selectedSounds = sounds[soundCategory]
    if selectedSounds then
        local randomIndex = math.random(1, #selectedSounds)
        local selectedSound = selectedSounds[randomIndex]
        local sound = USERSOUND:New(selectedSound)
        sound:ToGroup(Group)
    end
end



function Foothold_ctld:OnAfterTroopsPickedUp(From, Event, To, Group, Unit, Cargo)
    if Group and Group:IsAlive() then
        updateLastPickupZone(Group, Unit)
        if Cargo and Cargo.GetName then
            local cargoName = Cargo:GetName()
            local cargoObject = self:_FindTroopsCargoObject(cargoName)
            if cargoObject and cargoObject:GetStock() < 5 then
                local predicate = function(entry)
                    return entry.Stock < 5
                end
                local oldestIdx, victim, oldestTs = selectOldestUnit(TroopUnits, cargoName, predicate)
                if oldestIdx and victim then
                    Foothold_ctld:AddStockTroops(cargoName, 1)
                    self:I(string.format("[RESERVE] DELETE oldest troop %s ts=%f (group=%s) after load",
                        cargoName, oldestTs, victim.groupName))
                    destroyTrackedGroup(victim)
                    if Group then messageCtldToGroup(Group, "CTLD_TROOP_LIMIT_REACHED_REMOVED_OLDEST", 12, cargoName, cargoName, victim.groupName) end
                    table.remove(TroopUnits, oldestIdx)
                    local newStock = cargoObject:GetStock()
                    for _, entry in ipairs(TroopUnits) do
                        if entry.CargoName == cargoName then
                            entry.Stock = newStock
                        end
                    end
                else
                    self:I(string.format("[RESERVE] no existing troop %s groups to delete on load", cargoName))
                end
            end
        end
        playRandomSound(Group, "loading")
    else
        return
    end
end


local refundPendingSumByKey = {}
local refundPendingGidByKey = {}
local refundPendingDcsByKey = {}
local refundFlushScheduled = false

local function scheduleRefundFlush()
    if refundFlushScheduled then return end
    refundFlushScheduled = true
    timer.scheduleFunction(function()
        refundFlushScheduled = false
        for key, amount in pairs(refundPendingSumByKey) do
            if amount and amount > 0 then
                bc:credit(2, amount, refundPendingGidByKey[key], refundPendingDcsByKey[key], "Troops returned")
            end
            refundPendingSumByKey[key] = nil
            refundPendingGidByKey[key] = nil
            refundPendingDcsByKey[key] = nil
        end
    end, {}, timer.getTime() + 2)
end

local function refundOrReturnRejectedTroops(deployer, cargoName, canCaptureZone)
    local cname = cargoName or "unknown"
    if CTLDCost and priceOf then
        local dcs = deployer and deployer.GetDCSObject and deployer:GetDCSObject() or nil
        local gid = dcs and dcs:getID() or nil
        local refund = priceOf(cname) or 0
        local key = deployer and deployer.GetName and deployer:GetName() or "unknown"
        if refund > 0 then
            refundPendingSumByKey[key] = (refundPendingSumByKey[key] or 0) + refund
            if gid and not refundPendingGidByKey[key] then refundPendingGidByKey[key] = gid end
            if dcs and not refundPendingDcsByKey[key] then refundPendingDcsByKey[key] = dcs end
            scheduleRefundFlush()
        end
    end
    if canCaptureZone ~= true and cargoName and cargoName ~= "unknown" then
        local cargoObj = Foothold_ctld:_FindTroopsCargoObject(cargoName)
        if cargoObj then
            Foothold_ctld:AddStockTroops(cargoName, 1)
            sendCtldToDeployer(deployer, "CTLD_ENGINEERS_RETURNED_TO_BASE", 10)
        end
    end
end

function Foothold_ctld:OnAfterTroopsDeployed(From, Event, To, Group, Unit, Troops)
    if not Group then return end

    local troopGroup = Troops
    if troopGroup and troopGroup:IsAlive() then
        local troopGroupName = troopGroup:GetName()
        local currentTime = timer.getTime()
        
        deployedTroops[troopGroupName] = troopGroup
        deployedTroopsSet:AddGroup(troopGroup)
        zoneSet:Trigger(deployedTroopsSet)

        if Group and Group:IsAlive() then
            playRandomSound(Group, "unload")
        else
            return
        end

        local cargoName, stock = "unknown", 0
        local cargoType = nil
        local canCaptureZone = false

        for _, cargoData in pairs(self.Cargo_Troops) do
            if cargoData.Templates then
                local templateName = type(cargoData.Templates) == "table" 
                                     and cargoData.Templates[1] 
                                     or cargoData.Templates
                if string.find(troopGroupName, templateName, 1, true) then
                    cargoName = cargoData:GetName()
                    stock = cargoData:GetStock()
                    cargoType = cargoData.CargoType
                    canCaptureZone = cargoTypeCanCaptureZone(cargoType)
                    break
                end
            end
        end
        local maxTimestamp = 0
        for _, group in ipairs(TroopUnits) do
            if group.CargoName == cargoName then
                if group.Timestamp > maxTimestamp then
                    maxTimestamp = group.Timestamp
                end
            end
        end
        local newTimestamp = maxTimestamp > 0 and (maxTimestamp + 1) or currentTime

        local groupExists = false
        for _, group in ipairs(TroopUnits) do
            if group.groupName == troopGroupName then
                group.Timestamp = newTimestamp
                group.Stock = stock
                groupExists = true
                break
            end
        end
        if not groupExists then
            table.insert(TroopUnits, {
                groupName = troopGroupName,
                Timestamp = newTimestamp,
                CargoName = cargoName,
                Stock = stock
            })
        end
        for _, g in ipairs(TroopUnits) do
            if g.CargoName == cargoName then
                g.Stock = stock
            end
        end

        local oldestUnit = nil
        local oldestTimestamp = math.huge
        for _, group in ipairs(TroopUnits) do
            if group.CargoName == cargoName
               and group.Timestamp < newTimestamp
               and group.Stock < 5
            then
                if group.Timestamp < oldestTimestamp then
                    oldestTimestamp = group.Timestamp
                    oldestUnit = group
                end
            end
        end
        if oldestUnit then
            Foothold_ctld:AddStockTroops(oldestUnit.CargoName, 1)
            local dcsGroup = GROUP:FindByName(oldestUnit.groupName)
            if dcsGroup and dcsGroup:IsAlive() then
                dcsGroup:Destroy()
            end
            for i, group in ipairs(TroopUnits) do
                if group.groupName == oldestUnit.groupName then
                    table.remove(TroopUnits, i)
                    break
                end
            end
        end
        local currentZones = {}
        for _, zC in ipairs(bc:getZones()) do
            local missionZoneName = zC.zone
            local zone = getSupplyZoneWrapper(missionZoneName)
            if zone and troopGroup:IsPartlyOrCompletelyInZone(zone) then
                local zoneName = zone:GetName()
                table.insert(currentZones, {zoneName = zoneName, zoneObject = zC})
            end
        end

        if #currentZones > 0 then
            for _, zoneData in ipairs(currentZones) do
                local currentZone = zoneData.zoneObject
                local zoneName    = zoneData.zoneName

                if not currentZone then
                    zoneCaptureInfo[troopGroupName] = { troopGroup = troopGroup, zoneName = zoneName, deployer = Group, cargoName = cargoName, cargoType = cargoType, canCaptureZone = canCaptureZone, pickupZoneName = Group and Group._lastPickupZone or nil }
                    return
                end
                if currentZone.side == 2 then
                    local pickupZoneName = Group and Group._lastPickupZone or nil
                    local sameZone = pickupZoneName and zoneName and pickupZoneName == zoneName
                    local need = currentZone:canRecieveSupply() or false
                    if sameZone or not need then
                        refundOrReturnRejectedTroops(Group, cargoName, canCaptureZone)
                        troopGroup:Destroy()
                        deployedTroops[troopGroupName] = nil
                        deployedTroopsSet:RemoveGroupsByName(troopGroupName)
                        zoneCaptureInfo[troopGroupName] = nil
                        return
                    end
                    zoneCaptureInfo[troopGroupName] = { troopGroup = troopGroup, zoneName = zoneName, deployer = Group, cargoName = cargoName, cargoType = cargoType, canCaptureZone = canCaptureZone, pickupZoneName = pickupZoneName }
                    CaptureZoneIfNeutral()
                    return
                end
                if currentZone.side == 1 then
                    zoneCaptureInfo[troopGroupName] = { troopGroup = troopGroup, zoneName = zoneName, deployer = Group, cargoName = cargoName, cargoType = cargoType, canCaptureZone = canCaptureZone, pickupZoneName = Group and Group._lastPickupZone or nil }
                    return
                end
                if currentZone.side == 0 then
                    zoneCaptureInfo[troopGroupName] = { troopGroup = troopGroup, zoneName = zoneName, deployer = Group, cargoName = cargoName, cargoType = cargoType, canCaptureZone = canCaptureZone, pickupZoneName = Group and Group._lastPickupZone or nil }
                    CaptureZoneIfNeutral()
                end
            end
        else
            zoneCaptureInfo[troopGroupName] = { troopGroup = troopGroup, zoneName = nil, deployer = Group, cargoName = cargoName, cargoType = cargoType, canCaptureZone = canCaptureZone, pickupZoneName = Group and Group._lastPickupZone or nil }
        end
    end
end
function zoneSet:OnAfterEnteredZone(From, Event, To, EnteredGroup, Zone)
  trigger.action.outText(L10N:Format("CTLD_TROOP_GROUP_ENTERED_ZONE", Zone:GetName()), 10)
    local troopGroup = EnteredGroup
    if troopGroup and troopGroup:IsAlive() then
        local troopGroupName = troopGroup:GetName()
        local zoneName       = Zone:GetName()
        local currentZone    = bc:getZoneByName(zoneName)

        if not zoneCaptureInfo[troopGroupName] then
            zoneCaptureInfo[troopGroupName] = { troopGroup = troopGroup, zoneName = zoneName, cargoType = nil, canCaptureZone = nil }
        else
            zoneCaptureInfo[troopGroupName].zoneName   = zoneName
            zoneCaptureInfo[troopGroupName].troopGroup = troopGroup
        end
        if not zoneCaptureInfo[troopGroupName].cargoName then
            local cname = "unknown"
            for _, g in ipairs(TroopUnits) do
                if g.groupName == troopGroupName then cname = g.CargoName break end
            end
            zoneCaptureInfo[troopGroupName].cargoName = cname
        end
        if zoneCaptureInfo[troopGroupName].cargoType == nil then
            zoneCaptureInfo[troopGroupName].cargoType = getCargoTypeByName(zoneCaptureInfo[troopGroupName].cargoName)
        end
        if zoneCaptureInfo[troopGroupName].canCaptureZone == nil then
            zoneCaptureInfo[troopGroupName].canCaptureZone = cargoTypeCanCaptureZone(zoneCaptureInfo[troopGroupName].cargoType)
        end
        if zoneCaptureInfo[troopGroupName].pickupZoneName == nil then
            local dep = zoneCaptureInfo[troopGroupName].deployer
            if dep and dep._lastPickupZone then
                zoneCaptureInfo[troopGroupName].pickupZoneName = dep._lastPickupZone
            end
        end

        if zoneCaptureInfo[troopGroupName].canCaptureZone and currentZone and (currentZone.side == 2 or currentZone.side == 0) then
            timer.scheduleFunction(function() CaptureZoneIfNeutral() end, {}, timer.getTime() + 10)
        end
    end
end

local captureRunning = false
local captureQueued  = false


function CaptureZoneIfNeutral()
    if captureRunning then
        captureQueued = true
        return
    end
    if next(zoneCaptureInfo) == nil then return end
    captureRunning = true
    captureQueued = false

    local troopGroupNames = {}
    for name in pairs(zoneCaptureInfo) do
        troopGroupNames[#troopGroupNames + 1] = name
    end

    local zoneEvents   = {}
    local totalReward  = 0
    local retrigger    = false
    local landedThisRun= {}

    local function cleanupDeployment(name)
        deployedTroops[name] = nil
        deployedTroopsSet:RemoveGroupsByName(name)
        zoneCaptureInfo[name] = nil
        retrigger = true
    end

    local function noteEvent(zoneName, pname, field, reward)
        if not zoneName or not pname then return end
        zoneEvents[zoneName] = zoneEvents[zoneName] or { player = pname }
        zoneEvents[zoneName][field] = true
        totalReward = totalReward + reward
    end

    local function processNextGroup(index)
        local verb
         if index > #troopGroupNames then
            if next(zoneEvents) then
                local lines = {}
                local T = getFootholdLocalization():ForLocale()
                for z,ev in pairs(zoneEvents) do
                    
                    if ev.captured and ev.upgraded then
                        verb = 'captured and upgraded'
                    elseif ev.captured then
                        verb = 'captured'
                    else
                        verb = 'upgraded'
                    end
                    lines[#lines + 1] = T:Format("CTLD_TROOP_ZONE_EVENT_LINE", ev.player, ctldTroopZoneActionText(T, verb), z)
                end
                                
                local players = coalition.getPlayers(2)
                local zones = bc:getZones()
                local anyLanded = false
                local playersToCheck = {}
                for _, ev in pairs(zoneEvents) do
                    if ev.player and bc.playerContributions[2][ev.player] ~= nil then playersToCheck[ev.player] = true end
                end
                for pname, _ in pairs(playersToCheck) do
                    for _, playerUnit in ipairs(players) do
                        if playerUnit:getPlayerName() == pname then
                            if not Utils.isInAir(playerUnit) then
                                local didLand = false
                                for _, zoneData in ipairs(zones) do
                                    if ((2 == zoneData.side) or (zoneData.wasBlue)) and Utils.isInZone(playerUnit, zoneData.zone) then
                                        if not landedThisRun[pname] then
                                            local pnameCap = pname
                                            local unitCap = playerUnit
                                            SCHEDULER:New(nil,function()
                                                if not unitCap or not unitCap:isExist() then return end
                                                local landingEvent = {
                                                    id = world.event.S_EVENT_LAND,
                                                    time = timer.getAbsTime(),
                                                    initiator = unitCap,
                                                    initiatorPilotName = pnameCap,
                                                    initiator_unit_type = unitCap:getTypeName(),
                                                    initiator_coalition = 2,
                                                    skipRewardMsg = true
                                                }
                                                world.onEvent(landingEvent)
                                            end,{},5,0)
                                            landedThisRun[pname] = true
                                        end
                                        didLand = true
                                        anyLanded = true
                                        break
                                    end
                                end
									 
                            end
                            break
                        end
                    end
                end
                if not anyLanded then
                    trigger.action.outTextForCoalition(2, table.concat(lines, '\n')..'\n'..T:Format("CTLD_TROOP_ZONE_EVENT_TOTAL", totalReward), 20)
                end
            end

            captureRunning = false
            local hasPending = next(zoneCaptureInfo) ~= nil
            if hasPending and (captureQueued or retrigger) then
                captureQueued = false
                CaptureZoneIfNeutral()
            end
            return
        end


        local troopGroupName = troopGroupNames[index]
        local data = zoneCaptureInfo[troopGroupName]

        local function scheduleNext(delay)
            local wait = delay
            if wait == nil then
                wait = 5
            elseif wait < 0 then
                wait = 0
            end
            timer.scheduleFunction(function() processNextGroup(index + 1) end, {}, timer.getTime() + wait)
        end

        if not data then
            scheduleNext(0)
            return
        end

        local troopGroup = data.troopGroup
        if not troopGroup or not troopGroup:IsAlive() then
            cleanupDeployment(troopGroupName)
            scheduleNext(5)
            return
        end

        local zoneName = data.zoneName
        if not zoneName then
            scheduleNext(5)
            return
        end

        local currentZone = bc:getZoneByName(zoneName)
        if not currentZone then
            scheduleNext(5)
            return
        end
        if data.canCaptureZone == nil then
            data.cargoType = data.cargoType or getCargoTypeByName(data.cargoName)
            data.canCaptureZone = cargoTypeCanCaptureZone(data.cargoType)
        end
        if data.canCaptureZone ~= true then
            if currentZone.side == 2 then
                local cargoName = data.cargoName
                if cargoName and cargoName ~= "unknown" then
                    local cargoObj = Foothold_ctld:_FindTroopsCargoObject(cargoName)
                    if cargoObj then
                        Foothold_ctld:AddStockTroops(cargoName, 1)
                        sendCtldToDeployer(data.deployer, "CTLD_TROOPS_RETURNED_TO_BASE", 10)
                    end
                end
                troopGroup:Destroy()
                cleanupDeployment(troopGroupName)
                scheduleNext(1)
                return
            end
            scheduleNext(5)
            return
        end

        local sameZone = data.pickupZoneName and zoneName and data.pickupZoneName == zoneName
        if sameZone then
            refundOrReturnRejectedTroops(data.deployer, data.cargoName, data.canCaptureZone)
            troopGroup:Destroy()
            cleanupDeployment(troopGroupName)
            scheduleNext(1)
            return
        end

        local pname
        if data.deployer and data.deployer:IsAlive() then
            local pilot = data.deployer:GetUnits()[1]
            if pilot and pilot:GetPlayerName() then pname = pilot:GetPlayerName() end
        end

        if currentZone.side == 0 and currentZone.active then
            currentZone:capture(2)
            troopGroup:Destroy()
            if pname and bc.playerContributions[2][pname] ~= nil then
              local reward = bc.rewards['Zone capture'] or 200
                bc:addContribution(pname, 2, reward)
                bc:addTempStat(pname, 'Zone capture', 1)
                noteEvent(zoneName, pname, 'captured', reward)
            end
            cleanupDeployment(troopGroupName)
            scheduleNext(5)
            return
        elseif currentZone.side == 2 then
            local need = currentZone:canRecieveSupply() or false
            if need then
                currentZone:upgrade()
                troopGroup:Destroy()
                if pname and bc.playerContributions[2][pname] ~= nil then
                  local reward = bc.rewards['Zone upgrade'] or 100
                    bc:addContribution(pname, 2, reward)
                    bc:addTempStat(pname, 'Zone upgrade', 1)
                    noteEvent(zoneName, pname, 'upgraded', reward)
                end
                cleanupDeployment(troopGroupName)
                scheduleNext(5)
                return
            end
            troopGroup:Destroy()
            cleanupDeployment(troopGroupName)
            scheduleNext(1)
            return
        elseif not currentZone.active then
            troopGroup:Destroy()
            cleanupDeployment(troopGroupName)
            scheduleNext(5)
            return
        end

        scheduleNext(5)
    end

    processNextGroup(1)

end

local function RefillMissingWithCountTable()
    if Foothold_ctld.buildRunning > 0 then
        return
    end
  local countTable = Foothold_ctld:_CountStockPlusInHeloPlusAliveGroups()
  local unitsByName = {}
  for _, cfg in pairs(Foothold_ctld.C130GetUnits or {}) do
    if cfg and cfg.Name then
      unitsByName[cfg.Name] = true
    end
  end

  for cargoName, info in pairs(countTable) do
    local stock0 = info.Stock0 or 0
    local sum    = info.Sum or 0
    local needed = stock0 - sum
    local crateObj = nil

    if needed > 0 then
      local isTroop  = Foothold_ctld:_FindTroopsCargoObject(cargoName)  ~= nil
      crateObj = Foothold_ctld:_FindCratesCargoObject(cargoName)
      local isCrates = crateObj ~= nil
      local isUnits  = unitsByName[cargoName] == true

      if isTroop then
        Foothold_ctld:AddStockTroops(cargoName, needed)
        --env.info(string.format("[Refill] TROOPS '%s': sum=%d < stock0=%d => +%d stock added.",
          --cargoName, sum, stock0, needed))
      end
      if isCrates then
        Foothold_ctld:AddStockCrates(cargoName, needed)
        --env.info(string.format("[Refill] CRATES '%s': sum=%d < stock0=%d => +%d stock added.",
          --cargoName, sum, stock0, needed))
      end
      if isUnits then
        Foothold_ctld:AddStockUnits(cargoName, needed)
        --env.info(string.format("[Refill] UNITS '%s': sum=%d < stock0=%d => +%d stock added.",
          --cargoName, sum, stock0, needed))
      end
    end

    if sum > stock0 then
      local cargoObj = crateObj or Foothold_ctld:_FindCratesCargoObject(cargoName)
      if cargoObj then
        local oldStock = cargoObj.Stock or 0
        if oldStock > 0 then
          local difference = sum - stock0
          local newStock   = oldStock - difference
          if newStock < 5 then
            newStock = 5
          end
          cargoObj.Stock = newStock
        end
      end
    end
  end
end

TIMER:New(RefillMissingWithCountTable):Start(60, 60)


TIMER:New(tickZoneSupply):Start(15, 5)


BASE:I("CTLD script initialized")
