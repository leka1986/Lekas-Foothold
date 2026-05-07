env.info("Mission Setup : is loading.")

local L10N = FH_L10N
local function LT(T) return T or L10N end
local function LTGet(key) return L10N:DeferredGet(key) end
local function LTFormat(key, ...) return L10N:DeferredFormat(key, ...) end

local function localizedHeadingLabel(headingName, T)
	return L10N:DynamicHeadingLabel(headingName, T)
end

local function localizedLegLabel(legName, T)
	return L10N:DynamicLegLabel(legName, T)
end

function merge(tbls)
    local res = {}
    for i,v in ipairs(tbls) do
        for i2,v2 in ipairs(v) do
            table.insert(res,v2)
        end
    end
    
    return res
end

function allExcept(tbls, except)
    local tomerge = {}
    for i,v in pairs(tbls) do
        if i~=except then
            table.insert(tomerge, v)
        end
    end
    return merge(tomerge)
end

--supplypenalty will be calculated when evaluating the zone flags
supplypenalty = 0
--spawnfactor will decide how good the supply is- if you get rid of supplies then the spawn will be delayed
spawnfactor = 0
spawnfactor_patrol = 0

upgrades = {
    redships = {
        blue = {'blueShip', 'blueShip', 'blueShip'},
        red = {'redShipS', 'redShipS-2', 'redShipS-1', 'redShipM', 'redShipM-1', 'redShipM-2', 'redShipL-1', 'redShipL', 'redShipL-2', 'redShipXL'}
    },
    blueships = {
        blue = {'blueShip'},
        red = {'redShipXL'}
    },
    farp1 = {
        blue = {'blueArmor', 'bluePD1'},
        red = {'redInfantry1', 'Red Armour Group', 'Red SAM Dog Ear SA-8', 'Red Armour Group 5'}
    },
    farp2 = {
        blue = {'blueArmor', 'bluePD1'},
        red = {'redInfantry1', 'Red Armour Group', 'Red SAM SHORAD SA-19','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}
    },
    farp3 = {
        blue = {'blueArmor', 'bluePD2'},
        red = {'redInfantry2', 'Red Armour Group 4', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2', 'Red SAM SHORAD SA-19','Enemy ground forces'}
    },
    farp4 = {
        blue = {'blueArmor', 'bluePD2'},
        red = {'redInfantry2', 'Red Armour Group 6', 'Red SAM Dog Ear SA-8','Enemy ground forces'}
    },
    skogsfarp = {
        blue = {'bluePD2'},
        red = {'redInfantry2', 'Red Armour Group 3', 'Red SAM Dog Ear SA-8'}
    },
    
    JokkmokkFixed = {
        blue = {'blueInfantry', 'blueArmor'},
        red = {}
    },
    
    kola = {
        blue = {'blueInfantry'},
        red = {'redInfantry2'}
    },
    
    andoyaspawn = {
        blue = {'Blue SAM Fixed Andoya Patriot'},
        red = {'redInfantry2'}
    },
    
    bodospawn = {
        blue = {'Blue SAM Fixed Bodo Patriot'},
        red = {'redInfantry2'}
    },
    
    kallaxspawn = {
        blue = {'Blue SAM Fixed Kallax NASAMS', 'blueArmor'},
        red = {'redInfantry2', 'Red SAM SHORAD SA-15 Fixed Kallax', 'Red SAM SA-11 Fixed Kallax'}
    },
    
    vidselspawn = {
        blue = {'Blue SAM Fixed Vidsel NASAMS'},
        red = {'redInfantry2', 'Red SAM Fixed Vidsel SA-6'}
    },
    
    jokkmokkspawn = {
        blue = {'Blue SAM Fixed Jokkmokk NASAMS','blueArmor'},
        red = {'redInfantry2', 'Red SAM SHORAD SA-15 Fixed Jokkmokk', 'Red SAM SA-11 Fixed Jokkmokk'}
    },
    
    kemitorniospawn = {
        blue = {'Blue SAM Fixed Kemi Tornio NASAMS', 'bluePD2'},
        red = {'redInfantry2', 'Red SAM SHORAD SA-15 Fixed Kemi Tornio', 'Red SAM SA-11 Fixed Kemi Tornio'}
    },
    
    rovaniemispawn = {
        blue = {'Blue SAM Fixed Rovaniemi Patriot', 'bluePD2'},
        red = {'redInfantry2', 'Red SAM Fixed Rovaniemi SA-10', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2', 'Red SAM SHORAD Pantsir S1'}
    },
    kittilaspawn = {
        blue = {'Blue SAM Fixed Kittila Patriot', 'bluePD2'},
        red = {'redInfantry2', 'Red SAM Fixed Kittila SA-10', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2','Red SAM Dog Ear SA-8','Red Armour Group 4'}
    },
    
    kirunaspawn = {
        blue = {'Blue SAM Fixed Kiruna NASAMS','blueArmor'},
        red = {'redInfantry2', 'Red SAM SHORAD SA-15 Fixed Kiruna', 'Red SAM SA-11 Fixed Kiruna','Red EWR Fixed Kiruna CCC EWR group','Red Armour Group 3'}
    },  
    
    kalixforsspawn = {
        blue = {'blueInfantry','bluePD2'},
        red = {'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2','Red Armour Group 2','Enemy ground forces'}
    },

    kirkenesspawn = {
        blue = {'Blue SAM Fixed Kirkenes NASAMS', 'bluePD2'},
        red = {'redInfantry2', 'Red SAM SHORAD SA-15 Fixed Kirkenes', 'Red SAM SA-11 Fixed Kirkenes','Red Armour Group 6','Enemy ground forces'}
    },  
    
    banakspawn = {
        blue = {'Blue SAM Fixed Banak NASAMS','blueArmor'},
        red = {'redInfantry2', 'Red SAM SHORAD SA-15 Fixed Banak', 'Red SAM SA-11 Fixed Banak','Red SAM SHORAD Pantsir S1','Red Armour Group 5'}
    },
    altaspawn = {
        blue = {'Blue SAM Fixed Alta NASAMS','blueArmor'},
        red = {}
    },  
    
    bardufossspawn = {
        blue = {'Blue SAM Fixed Bardufoss NASAMS','blueArmor'},
        red = {'redInfantry2', 'Red SAM Fixed Bardufoss SA-6','Enemy ground forces'}
    },
    
    vuojarvispawn = {
        blue = {'Blue SAM Fixed Voujarvi NASAMS'},
        red = {'Red SAM SHORAD SA-15 Fixed Voujarvi', 'Red SAM SA-11 Fixed Voujarvi','redInfantry2'}
    },
    
    samalvikspawn = {
        blue = {'Blue SAM Fixed Alvik Patriot'},
        red = {'redInfantry2', 'Red SAM Fixed Alvik SA-10'}
    },
    
    monchegorskspawn = {
        blue = {'Blue SAM Fixed Monchegorsk Patriot'},
        red = {'Red SAM Fixed Monchegorsk SA-10','Red SAM AAA', 'Red SAM Dog Ear SA-8','redInfantry2'}
    },
    
    murmanskinternationalspawn = {
        blue = {'Blue SAM Fixed Murmansk Patriot'},
        red = {'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2','Red SAM Fixed Murmansk SA-10','redInfantry2'}
    },
    
    olenyaspawn = {
        blue = {'Blue SAM Fixed Olenya NASAMS'},
        red = {'Red SAM SHORAD SA-15 Fixed Olenya', 'Red SAM SA-11 Fixed Olenya', 'Red Armour Group', 'redInfantry2', }
    },
    
    severomorsk1spawn = {
        blue = {'Blue SAM Fixed Severomorsk-1 NASAMS'},
        red = {'Red SAM SHORAD SA-15 Fixed Severomorsk1', 'Red SAM SA-11 Fixed Severomorsk1', 'redInfantry2'}
    },
    
    severomorsk3spawn = {
        blue = {'Blue SAM Fixed Severomorsk-3 NASAMS'},
        red = {'Red SAM SHORAD SA-15 Fixed Severomorsk3', 'Red SAM SA-11 Fixed Severomorsk3', 'redInfantry2'}
    },
    
    kuusamospawn = {
        blue = {'Blue SAM Fixed Kuusamo NASAMS'},
        red = {'redInfantry2','Red SAM Fixed Kuusamo SA-6','Red SAM AAA','Red SAM SHORAD SA-19'}
    },
    
    ivalospawn = {
        blue = {'Blue SAM Fixed Ivalo Patriot'},
        red = {'redInfantry2', 'Red SAM Fixed Ivalo SA-10', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2','Red Armour Group 5'}
    },

    alakourttispawn = {
        blue = {'Blue SAM Fixed Alakourtti Patriot'},
        red = {'Red SAM Fixed Alakourtti SA-10','redInfantry1','Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2', 'Red Armour Group 6'}
    },
    
    prirechnyispawn = {
        blue = {'blueInfantry', 'bluePD2'},
        red = {'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2','Red SAM AAA','Red Armour Group 3'}
    },
    
    kelloselkacenterspawn = {
        blue = {'blueInfantry', 'bluePD2'},
        red = {'Red Armour Group','Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}--,'Red Armour Group 3'}
    },
    
    buolbmatcenterspawn = {
        blue = {'blueInfantry', 'bluePD2'},
        red = {'Red Armour Group','Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2','Red Armour Group 4'}--,'Red Armour Group 3'}
    },
    
    maaninkavaaracenterspawn = {
        blue = {'blueInfantry', 'bluePD2'},
        red = {'Red Armour Group','Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}--,'Red Armour Group 3'}
    },
    
    savukoskispawn = {
        blue = {'blueInfantry', 'bluePD2'},
        red = {'Red Armour Group','Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}--,'Red Armour Group 3'}
    },
    
    laplandiyaspawn = {
        blue = {'blueInfantry'},
        red = {'Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}
    },
    
    zelenoborskijyaspawn = {
        blue = {'blueInfantry'},
        red = {'Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}
    },
    
    gadzhiyevospawn = {
        blue = {'blueInfantry'},
        red = {'Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2','Gadzhiyevo workshop','Gadzhiyevo ammo depot'}
    },
    
    lovozerocccspawn = {
        blue = {'blueInfantry'},
        red = {'Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}
    },
    
    koashvaspawn = {
        blue = {'blueInfantry'},
        red = {'KoashvaAmmo1','KoashvaAmmo2','KoashvaTank1','KoashvaTank2','KoashvaRailwayStation'}
    },
    
    afrikandaspawn = {
        blue = {'blueInfantry'},
        red = {'Afrikanda ammo depot 1','Afrikanda ammo depot 2'}
    },
    
    kilpyavrspawn = {
        blue = {'blueInfantry'},
        red = {'Kilp yavr ammo depot 1'}
    },
    
    pyaozerskspawn = {
        blue = {'blueInfantry'},
        red = {'Pyaozersky RailwayStation','Pyaozersky ammo depot 1','Pyaozersky ammo depot 2'}
    },
    
    hidden1Group = {
        blue = {},
        red = {'Hidden1-Group1-Fixed'}
    },
    
    HiddenHQEWRGroup = {
        blue = {},
        red = {'Red EWR Fixed Alakourtti CCC EWR group-1', 'HQ Fixed', 'Red EWR Fixed Prirechnyi CCC EWR group', 'Red EWR Fixed Tikhtozero CCC EWR group'}
    },
    
    hiddenOlenyaEWRspawn = {
        blue = {},
        red = {'Red EWR Fixed Olenogorsk CCC EWR group'}
    },
    
    HiddenKittilaHQEWRGroup = {
        blue = {},
        red = {'Red EWR Fixed Kittila CCC EWR group'}
    },
    
    hiddenKemiRoadblockGroup = {
        blue = {},
        red = {'Hidden_KemiRoadblock_Group1-Fixed','Hidden_KemiRoadblock_Group2-Fixed'}
    },
    
    hiddenForestguardGroup = {
        blue = {},
        red = {'Hidden_Forestguard_Group1-Fixed'}
    },
    
    hiddenRanuaGuardGroup = {
        blue = {},
        red = {'Hidden_RanuaGuard_Group1-Fixed', 'Hidden_LakeSupplyPoint_Group-Fixed'}
    },

    hiddenPosioGuardGroup = {
        blue = {},
        red = {'Hidden_Posio_Group-Fixed', 'Hidden_PosioSouth_Group-Fixed'}
    },
    
   
    hiddenVesivoimalaGroup = {
        blue = {},
        red = {'Hidden_Vesivoimala_group_Fixed'}
    },
    
    hiddenKandalakshaGroup = {
        blue = {},
        red = {'Red SAM SHORAD SA-15 Fixed Kandalaksha', 'Red SAM SA-11 Fixed SKandalaksha'}
    },
    
    hiddenLoukhiGroup = {
        blue = {},
        red = {'Red SAM SHORAD SA-15 Fixed Loukhi', 'Red SAM SA-11 Fixed Loukhi'}
    },
    
    hiddenTungozeroGroup = {
        blue = {},
        red = {'Red SAM SHORAD SA-15 Fixed Tungozero', 'Red SAM SA-11 Fixed Tungozero'}
    },
    
    hiddenMurmanskNavalGroup = {
        blue = {},
        red = {'Murmansk-naval-group-Fixed-red','Severomorsk-naval-group-Fixed-red'}
    },
    
    hiddenSAMmike = {
        blue = {},
        red = {'Red SAM Fixed SAM Site Mike SA-10'}
    },
    HiddenScatteredEWR = {
        blue = {},
        red = {'Red EWR Scattered Fixed 1','Red EWR Scattered Fixed 2','Red EWR Scattered Fixed 3'}
    }
}

WaypointList = {
    Bodo                    = ' (1)',
    Andoya                  = ' (2)',
    Bardufoss               = ' (3)',
    Alta                    = ' (4)',
    Banak                   = ' (5)',
    Buolbmat                = ' (6)',
    Kirkenes                = ' (7)',
    Karasjok                = ' (8)',
    Guovdageaidnu           = ' (9)',
    Luspa                   = ' (10)',
    Kiruna                  = ' (11)',
    Kalixfors               = ' (12)',
    Skogsbasen              = ' (13)',
    BergsBasen              = ' (14)',
    Kvikkjokk               = ' (15)',
    Gallivare               = ' (16)',
    Jokkmokk                = ' (17)',
    Vidsel                  = ' (18)',
    Kallax                  = ' (19)',
    Kalix                   = ' (20)',
    KemiTornio              = ' (21)',
    Tervola                 = ' (22)',
    Rovaniemi               = ' (23)',
    Vuojarvi                = ' (24)',
    Savukoski               = ' (25)',
    Kelloselka              = ' (26)',
    Maaninkavaara           = ' (27)',
    Kuusamo                 = ' (28)',
    Kittila                 = ' (29)',
    Ivalo                   = ' (30)',
    Zapolyarnyy             = ' (31)',
    Severomorsk1            = ' (32)',
    Severomorsk3            = ' (33)',
    MurmanskInternational   = ' (34)',
    Prirechnyi              = ' (35)',
    Olenya                  = ' (36)',
    Monchegorsk             = ' (37)',
    Apatity                 = ' (38)',
    Kovdor                  = ' (39)',
    Alakourtti              = ' (40)',
    SkogsFARP1              = '',
    SkogsFARP2              = ''
}

flavor = {
    --redcarrier = 'Enemy carrier zone',
    --bluecarrier = 'WPT \nStart zone',
    
    bodo                  = L10N:Get("KOLA_FLAVOR_BODO"),
    andoya                = L10N:Get("KOLA_FLAVOR_ANDOYA"),
    bardufoss             = L10N:Get("KOLA_FLAVOR_BARDUFOSS"),
    alta                  = L10N:Get("KOLA_FLAVOR_ALTA"),
    banak                 = L10N:Get("KOLA_FLAVOR_BANAK"),
    buolbmat              = L10N:Get("KOLA_FLAVOR_BUOLBMAT"),
    kirkenes              = L10N:Get("KOLA_FLAVOR_KIRKENES"),
    karasjok              = L10N:Get("KOLA_FLAVOR_KARASJOK"),
    guovdageaidnu         = L10N:Get("KOLA_FLAVOR_GUOVDAGEAIDNU"),
    luspa                 = L10N:Get("KOLA_FLAVOR_LUSPA"),
    kiruna                = L10N:Get("KOLA_FLAVOR_KIRUNA"),
    kalixfors             = L10N:Get("KOLA_FLAVOR_KALIXFORS"),
    skogsbasen            = L10N:Get("KOLA_FLAVOR_SKOGSBASEN"),
    bergsbasen            = L10N:Get("KOLA_FLAVOR_BERGSBASEN"),
    kvikkjokk             = L10N:Get("KOLA_FLAVOR_KVIKKJOKK"),
    gallivare             = L10N:Get("KOLA_FLAVOR_GALLIVARE"),
    jokkmokk              = L10N:Get("KOLA_FLAVOR_JOKKMOKK"),
    vidsel                = L10N:Get("KOLA_FLAVOR_VIDSEL"),
    kallax                = L10N:Get("KOLA_FLAVOR_KALLAX"),
    kalix                 = L10N:Get("KOLA_FLAVOR_KALIX"),
    kemiTornio            = L10N:Get("KOLA_FLAVOR_KEMI_TORNIO"),
    tervola               = L10N:Get("KOLA_FLAVOR_TERVOLA"),
    rovaniemi             = L10N:Get("KOLA_FLAVOR_ROVANIEMI"),
    vuojarvi              = L10N:Get("KOLA_FLAVOR_VUOJARVI"),
    savukoski             = L10N:Get("KOLA_FLAVOR_SAVUKOSKI"),
    kelloselka            = L10N:Get("KOLA_FLAVOR_KELLOSELKA"),
    maaninkavaara         = L10N:Get("KOLA_FLAVOR_MAANINKAVAARA"),
    kuusamo               = L10N:Get("KOLA_FLAVOR_KUUSAMO"),
    kittila               = L10N:Get("KOLA_FLAVOR_KITTILA"),
    ivalo                 = L10N:Get("KOLA_FLAVOR_IVALO"),
    zapolyarnyy           = L10N:Get("KOLA_FLAVOR_ZAPOLYARNYY"),
    severomorsk1          = L10N:Get("KOLA_FLAVOR_SEVEROMORSK1"),
    severomorsk3          = L10N:Get("KOLA_FLAVOR_SEVEROMORSK3"),
    murmanskinternational = L10N:Get("KOLA_FLAVOR_MURMANSK_INTERNATIONAL"),
    prirechnyi            = L10N:Get("KOLA_FLAVOR_PRIRECHNYI"),
    olenya                = L10N:Get("KOLA_FLAVOR_OLENYA"),
    monchegorsk           = L10N:Get("KOLA_FLAVOR_MONCHEGORSK"),
    apatity               = L10N:Get("KOLA_FLAVOR_APATITY"),
    kovdor                = L10N:Get("KOLA_FLAVOR_KOVDOR"),
    alakourtti            = L10N:Get("KOLA_FLAVOR_ALAKOURTTI"),
    samalvik              = L10N:Get("KOLA_FLAVOR_SAMALVIK"),
    skogsfarp1            = L10N:Get("KOLA_FLAVOR_SKOGSFARP_ROUTE_KUUSAMO"),
    skogsfarp2            = L10N:Get("KOLA_FLAVOR_SKOGSFARP_ROUTE_KUUSAMO"),
    skogsfarp3            = L10N:Get("KOLA_FLAVOR_SKOGSFARP_ROUTE_KUUSAMO"),
    skogsfarp4            = L10N:Get("KOLA_FLAVOR_SKOGSFARP_ROUTE_KUUSAMO"),
    laplandiya            = L10N:Get("KOLA_FLAVOR_LAPLANDIYA"),
    zelenoborskij         = L10N:Get("KOLA_FLAVOR_ZELENOBORSKIJ"),
    LovozeroCCC           = L10N:Get("KOLA_FLAVOR_LOVOZERO_CCC"),
    hidden1               = L10N:Get("KOLA_FLAVOR_HIDDEN1"),
    storage               = L10N:Get("KOLA_FLAVOR_STORAGE"),
    shipyard              = L10N:Get("KOLA_FLAVOR_SHIPYARD")
}   

FootholdSaveBaseName = ((CustomFlags['DynCampaign'] == true) and 'FootHold_KO_v0.3_mission' or 'FootHold_KO_v0.3')

local filepath = FootholdSaveBaseName .. '.lua'
if lfs then 
	FootholdSavePath = FootholdSavePath or (lfs.writedir()..'Missions/Saves')
	lfs.mkdir(FootholdSavePath)
	filepath = FootholdSavePath .. '/' .. (FootholdSaveBaseName .. '.lua')
	env.info('Foothold - Save file path: '..filepath)
end


local sideSE      = 2
local sideNO      = 2
local sideFIN     = 2
local sideFIN_SE  = 2
local scenarioNORMAL      = 1
local scenarioFINLAND_SE  = 2
local scenarioFINLAND     = 3
local scenarioALLOUT      = 4

--scenario will be one of the following:
--1: Russia red, Finland, Sweden and Norway are blue
--2: Invasion in Finland, Russia occupies the southeastern part of the finnish part of the map
--3: Finland occupied, Sweden and Norway are blue
--4: Finland, Sweden and Norway occupied, only small parts of Sweden and Norway remaining

if not CustomFlags["StartScenario"] then
  CustomFlags["StartScenario"] = 1
end
--if not CustomFlags['DynCampaign'] then
--CustomFlags['DynCampaign'] = true
--end

scenario = CustomFlags["StartScenario"]  --save this in the startfile for diagnosistics, will also be used later for deactivating

neutralFARP_SE = true
neutralFARP_NO = true
neutralFARP_RU = false
startlevel_SE  = 3
startlevel_NO  = 2
startlevel_FIN = 2
startlevel_RU  = 4

if (scenario == scenarioFINLAND) then
  sideFIN    = 1
  sideFIN_SE = 1
  sideSE     = 2
  sideNO     = 2
  --startlevel_SE = 1
  --startlevel_NO = 1
  --startlevel_FIN = 1
  --startlevel_RU = 0
  neutralFARP_SE = false
  neutralFARP_NO = false
  neutralFARP_RU = true
end

if (scenario == scenarioFINLAND_SE) then
  sideFIN    = 2
  sideFIN_SE = 1
  sideSE     = 2
  sideNO     = 2
  --startlevel_SE = 1
  --startlevel_NO = 1
  --startlevel_FIN = 1
  --startlevel_RU = 0
  neutralFARP_SE = false
  neutralFARP_NO = false
  neutralFARP_RU = true
end

if (scenario == scenarioALLOUT) then
  sideFIN    = 1
  sideFIN_SE = 1
  sideSE     = 1
  sideNO     = 1
  --startlevel_SE = 1
  --startlevel_NO = 1
  --startlevel_FIN = 1
  --startlevel_RU = 0
  neutralFARP_SE = false
  neutralFARP_NO = false
  neutralFARP_RU = true
end

neutralFARP_NO = false
neutralFARP_RU = false
neutralFARP_SE = false
AllowScriptedSupplies = AllowScriptedSupplies ~= false

bc = BattleCommander:new(filepath, 13, 60)
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
env.info('Foothold - Rank file path: '..bc.rankFile)
end
Hunt = true

zones = {
    --redcarrier = ZoneCommander:new({zone='Red Carrier', side=1, level=10, upgrades=upgrades.redships, crates={}, flavorText=flavor.redcarrier}),
    --bluecarrier = ZoneCommander:new({zone='Blue Carrier', side=2, level=1, upgrades=upgrades.blueships, crates={}, flavorText=flavor.bluecarrier}),
    
    ---Sweden
    kiruna                = ZoneCommander:new({zone='Kiruna',                side=sideSE    , level=99             , upgrades=upgrades.kirunaspawn, crates={}, flavorText=flavor.kiruna}),
    jokkmokk              = ZoneCommander:new({zone='Jokkmokk',              side=sideSE    , level=99             , upgrades=upgrades.jokkmokkspawn, crates={}, flavorText=flavor.jokkmokk}),
    luspa                 = ZoneCommander:new({zone='Luspa',                 side=sideSE    , level=99             , upgrades=upgrades.farp2, crates={}, flavorText=flavor.luspa}),
    vidsel                = ZoneCommander:new({zone='Vidsel',                side=sideSE    , level=99             , upgrades=upgrades.vidselspawn, crates={}, flavorText=flavor.vidsel}),
    kallax                = ZoneCommander:new({zone='Kallax',                side=sideSE    , level=99             , upgrades=upgrades.kallaxspawn, crates={}, flavorText=flavor.kallax}),
    samalvik              = ZoneCommander:new({zone='SAMAlvik',              side=sideSE    , level=99             , upgrades=upgrades.samalvikspawn, crates={}, flavorText=flavor.samalvik}),
    kvikkjokk             = ZoneCommander:new({zone='Kvikkjokk',             side=sideSE    , level=99             , upgrades=upgrades.farp4, crates={}, flavorText=flavor.kvikkjokk}),
    skogsbasen            = ZoneCommander:new({zone='Skogsbasen',            side=sideSE    , level=99             , upgrades=upgrades.farp1, crates={}, flavorText=flavor.skogsbasen}),
    gallivare             = ZoneCommander:new({zone='Gallivare',             side=sideSE    , level=99             , upgrades=upgrades.farp4, crates={}, flavorText=flavor.gallivare}), ---NOTE! This will be a city in one of the next patches!
    kalixfors             = ZoneCommander:new({zone='Kalixfors',             side=sideSE    , level=99             , upgrades=upgrades.kalixforsspawn, crates={}, flavorText=flavor.kalixfors}),
    kalix                 = ZoneCommander:new({zone='Kalix',                 side=sideSE    , level=99             , upgrades=upgrades.farp4, crates={}, flavorText=flavor.kalix}),
                                                                                           
    ---Norway                                                                              
    andoya                = ZoneCommander:new({zone='Andoya',                side=2         , level=99             , upgrades=upgrades.andoyaspawn, crates={}, flavorText=flavor.andoya}),
    bodo                  = ZoneCommander:new({zone='Bodo',                  side=2         , level=99             , upgrades=upgrades.bodospawn, crates={}, flavorText=flavor.bodo}),
    kirkenes              = ZoneCommander:new({zone='Kirkenes',              side=sideNO    , level=99             , upgrades=upgrades.kirkenesspawn, crates={}, flavorText=flavor.Kirkenes}),
    banak                 = ZoneCommander:new({zone='Banak',                 side=sideNO    , level=99             , upgrades=upgrades.banakspawn, crates={}, flavorText=flavor.banak}),
    alta                  = ZoneCommander:new({zone='Alta',                  side=0    , level=99                  , upgrades=upgrades.altaspawn, crates={}, flavorText=flavor.alta}),
    karasjok              = ZoneCommander:new({zone='Karasjok',              side=sideNO    , level=99             , upgrades=upgrades.farp3, crates={}, flavorText=flavor.karasjok}),
    guovdageaidnu         = ZoneCommander:new({zone='Guovdageaidnu',         side=sideNO    , level=99             , upgrades=upgrades.farp4, crates={}, flavorText=flavor.guovdageaidnu}),
    bergsbasen            = ZoneCommander:new({zone='BergsBasen',            side=sideNO    , level=99             , upgrades=upgrades.farp1, crates={}, flavorText=flavor.farpalpha}),
    bardufoss             = ZoneCommander:new({zone='Bardufoss',             side=sideNO    , level=99             , upgrades=upgrades.bardufossspawn, crates={}, flavorText=flavor.bardufoss}),
                                                                                           
    ---Finland                                                                             
    kemitornio            = ZoneCommander:new({zone='KemiTornio',            side=sideFIN   , level=99             , upgrades=upgrades.kemitorniospawn, crates={}, flavorText=flavor.kemitornio}),
    rovaniemi             = ZoneCommander:new({zone='Rovaniemi',             side=sideFIN   , level=99             , upgrades=upgrades.rovaniemispawn, crates={}, flavorText=flavor.rovaniemi}),
    vuojarvi              = ZoneCommander:new({zone='Vuojarvi',              side=sideFIN   , level=99             , upgrades=upgrades.vuojarvispawn, crates={}, flavorText=flavor.vuojarvi}),
    kuusamo               = ZoneCommander:new({zone='Kuusamo',               side=sideFIN_SE, level=99             , upgrades=upgrades.kuusamospawn, crates={}, flavorText=flavor.kuusamo}),
    savukoski             = ZoneCommander:new({zone='Savukoski',             side=1         , level=99             , upgrades=upgrades.farp3, crates={}, flavorText=flavor.savukoski}),
    ivalo                 = ZoneCommander:new({zone='Ivalo',                 side=sideFIN   , level=99             , upgrades=upgrades.ivalospawn, crates={}, flavorText=flavor.ivalo}),
    kittila               = ZoneCommander:new({zone='Kittila',               side=sideFIN   , level=99             , upgrades=upgrades.kittilaspawn, crates={}, flavorText=flavor.kittila}),
    tervola               = ZoneCommander:new({zone='Tervola',               side=1         , level=99             , upgrades=upgrades.farp1, crates={}, flavorText=flavor.tervola}),
    kelloselka            = ZoneCommander:new({zone='Kelloselka',            side=1         , level=99             , upgrades=upgrades.kelloselkacenterspawn, crates={}, flavorText=flavor.kelloselka}),
    buolbmat              = ZoneCommander:new({zone='Buolbmat',              side=sideFIN   , level=99             , upgrades=upgrades.buolbmatcenterspawn, crates={}, flavorText=flavor.buolbmat}),
    maaninkavaara         = ZoneCommander:new({zone='Maaninkavaara',         side=1         , level=99             , upgrades=upgrades.maaninkavaaracenterspawn, crates={}, flavorText=flavor.maaninkavaara}),
    skogsfarp1            = ZoneCommander:new({zone='SkogsFARP1',            side=1         , level=99             , upgrades=upgrades.skogsfarp, crates={}, flavorText=flavor.skogsfarp1}),
    skogsfarp2            = ZoneCommander:new({zone='SkogsFARP2',            side=1         , level=99             , upgrades=upgrades.skogsfarp, crates={}, flavorText=flavor.skogsfarp2}),
    skogsfarp3            = ZoneCommander:new({zone='SkogsFARP3',            side=1         , level=99             , upgrades=upgrades.skogsfarp, crates={}, flavorText=flavor.skogsfarp3}),
    skogsfarp4            = ZoneCommander:new({zone='SkogsFARP4',            side=1         , level=99             , upgrades=upgrades.skogsfarp, crates={}, flavorText=flavor.skogsfarp4}),
                                                                                           
    ---russia                                                                    
    apatity               = ZoneCommander:new({zone='Apatity',               side=1         , level=99             , upgrades=upgrades.farp2, crates={}, flavorText=flavor.apatity}),
    zapolyarnyy           = ZoneCommander:new({zone='Zapolyarnyy',           side=1         , level=99             , upgrades=upgrades.farp4, crates={}, flavorText=flavor.zapolyarnyy}),
    alakourtti            = ZoneCommander:new({zone='Alakourtti',            side=1         , level=99             , upgrades=upgrades.alakourttispawn, crates={}, flavorText=flavor.alakourtti}),
    prirechnyi            = ZoneCommander:new({zone='Prirechnyi',            side=1         , level=99             , upgrades=upgrades.prirechnyispawn, crates={}, flavorText=flavor.prirechnyi}),
    olenya                = ZoneCommander:new({zone='Olenya',                side=1         , level=99             , upgrades=upgrades.olenyaspawn, crates={}, flavorText=flavor.olenya}),
    murmanskinternational = ZoneCommander:new({zone='MurmanskInternational', side=1         , level=99             , upgrades=upgrades.murmanskinternationalspawn, crates={}, flavorText=flavor.murmanskinternational}),
    severomorsk3          = ZoneCommander:new({zone='Severomorsk3',          side=1         , level=99             , upgrades=upgrades.severomorsk3spawn, crates={}, flavorText=flavor.severomorsk3}),
    severomorsk1          = ZoneCommander:new({zone='Severomorsk1',          side=1         , level=99             , upgrades=upgrades.severomorsk1spawn, crates={}, flavorText=flavor.severomorsk1}),
    kovdor                = ZoneCommander:new({zone='Kovdor',                side=1         , level=99             , upgrades=upgrades.farp1, crates={}, flavorText=flavor.kovdor}),
    monchegorsk           = ZoneCommander:new({zone='Monchegorsk',           side=1         , level=99             , upgrades=upgrades.monchegorskspawn, crates={}, flavorText=flavor.monchegorsk}),
    laplandiya            = ZoneCommander:new({zone='LaplandiyaStorage',     side=1         , level=99             , upgrades=upgrades.laplandiyaspawn, crates={}, flavorText=flavor.laplandiya}), --always active, strike target, never supplied
    zelenoborskij         = ZoneCommander:new({zone='ZelenoborskijStorage',  side=1         , level=99             , upgrades=upgrades.zelenoborskijyaspawn, crates={}, flavorText=flavor.zelenoborskij}), --always active, strike target, never supplied
    lovozeroCCC           = ZoneCommander:new({zone='LovozeroCCC',           side=1         , level=99             , upgrades=upgrades.lovozerocccspawn, crates={}, flavorText=flavor.LovozeroCCC}), --always active, strike target, never supplied
    gadzhiyevoshipyard    = ZoneCommander:new({zone='GadzhiyevoShipYard',    side=1         , level=99             , upgrades=upgrades.gadzhiyevospawn, crates={}, flavorText=flavor.shipyard}),  --always active, strike target, never supplied
    
    --special strike target zones
    koashvastorage        = ZoneCommander:new({zone='KoashvaStorage',        side=1         , level=99             , upgrades=upgrades.koashvaspawn, crates={}, flavorText=flavor.storage}),  --always active, strike target, never supplied
    afrikandastorage      = ZoneCommander:new({zone='AfrikandaStorage',      side=1         , level=99             , upgrades=upgrades.afrikandaspawn, crates={}, flavorText=flavor.storage}),  --always active, strike target, never supplied
    kilpyavrstorage       = ZoneCommander:new({zone='KilpYavrStorage',       side=1         , level=99             , upgrades=upgrades.kilpyavrspawn, crates={}, flavorText=flavor.storage}),  --always active, strike target, never supplied
    pyaozerskystorage     = ZoneCommander:new({zone='PyaozerskyStorage',     side=1         , level=99             , upgrades=upgrades.pyaozerskspawn, crates={}, flavorText=flavor.storage}),  --always active, strike target, never supplied

    --hidden
    --SE
    hidden1               = ZoneCommander:new({zone='Hidden1',               side=sideSE    , level=99             , upgrades=upgrades.hidden1Group, crates={}, flavorText=flavor.hidden1}),
    --FN
    hiddenKemiRoadblock   = ZoneCommander:new({zone='Hidden_KemiRoadblock',  side=0         , level=99             , upgrades=upgrades.hiddenKemiRoadblockGroup, crates={}, flavorText=flavor.hidden1,NeutralAtStart=true}),
    hiddenForestguard     = ZoneCommander:new({zone='Hidden_Forestguard',    side=0         , level=99             , upgrades=upgrades.hiddenForestguardGroup, crates={}, flavorText=flavor.hidden1,NeutralAtStart=true}),
    hiddenRanuaGuard      = ZoneCommander:new({zone='Hidden_RanuaRB',        side=0         , level=99             , upgrades=upgrades.hiddenRanuaGuardGroup, crates={}, flavorText=flavor.hidden1,NeutralAtStart=true}),
    hiddenPosioGuard      = ZoneCommander:new({zone='Hidden_PosioRB',        side=0         , level=99             , upgrades=upgrades.hiddenPosioGuardGroup, crates={}, flavorText=flavor.hidden1,NeutralAtStart=true}),
    hiddenVesivoimala     = ZoneCommander:new({zone='Hidden_Vesivoimala',    side=1         , level=99             , upgrades=upgrades.hiddenVesivoimalaGroup, crates={}, flavorText=flavor.hidden1 }),
    hiddenkittilaEWR      = ZoneCommander:new({zone='Hidden_RedKittilaEWR',  side=sideFIN   , level=99             , upgrades=upgrades.HiddenKittilaHQEWRGroup, crates={}, flavorText=flavor.hidden1}),
    --RU
    --those will always be active (until the units are destroyed, they will never get supplies)
    hiddenKandalaksha     = ZoneCommander:new({zone='HiddenKandalaksha',     side=1         , level=99            , upgrades=upgrades.hiddenKandalakshaGroup, crates={}, flavorText=flavor.hidden1}),  --always active, strike target
    hiddenLoukhi          = ZoneCommander:new({zone='HiddenLoukhi',          side=1         , level=99            , upgrades=upgrades.hiddenLoukhiGroup, crates={}, flavorText=flavor.hidden1}),  --always active, strike target
    hiddenTungozero       = ZoneCommander:new({zone='HiddenTungozero',       side=1         , level=99            , upgrades=upgrades.hiddenTungozeroGroup, crates={}, flavorText=flavor.hidden1}),  --always active, strike target
    hiddenSAMmike         = ZoneCommander:new({zone='HiddenSAM_Mike',        side=1         , level=99            , upgrades=upgrades.hiddenSAMmike, crates={}, flavorText=flavor.hidden1}),  --always active, main SAM
    hiddenHQEWR           = ZoneCommander:new({zone='HiddenHQ',              side=1         , level=99            , upgrades=upgrades.HiddenHQEWRGroup, crates={}, flavorText=flavor.hidden1}),  --always active, HQ for Mantis
    hiddenMurmanskSea     = ZoneCommander:new({zone='HiddenMurmanskSea',     side=1         , level=99            , upgrades=upgrades.hiddenMurmanskNavalGroup, crates={}, flavorText=flavor.hidden1}),  --always active, ships
    hiddenOlenyaEWR       = ZoneCommander:new({zone='HiddenOlenyaEWR',       side=1         , level=99            , upgrades=upgrades.hiddenOlenyaEWRspawn, crates={}, flavorText=flavor.hidden1}),  --always active, EWR
    hiddenewr             = ZoneCommander:new({zone='HiddenEWRScattered',    side=1         , level=99            , upgrades=upgrades.HiddenScatteredEWR, crates={}, flavorText=flavor.hiddenewr}),  --EWR Scattered
    
}

if Era == "Coldwar" then

    CapPlaneTemplate = {
        'RED_MIG29A_Load1',
        'RED_MIG29A_Load2',
        'RED_SU27_EW',
        'RED_MIG21Bis_Load1',
        'RED_MIG21Bis_Load2',
        'RED_MIG23MLD',
        'RED_MIG25PD',
        'BLUE_HORNET_CW',
        'BLUE_F15C_CW',
        'BLUE_F14A',
    }
    CasPlaneTemplate = {
		'RED_SU25_OneShip_Load1',
		'RED_SU25_OneShip_Load2',
		'RED_SU25_OneShip_Load3',
        'RED_SU25_TwoShip_Load1',
		'RED_SU25_TwoShip_Load2',
		'RED_SU25_TwoShip_Load3',
        'RED_Mirage_F1BQ_Load1',
        'RED_Mirage_F1BQ_Load2',
        'BLUE_F4E_Load1',
        'BLUE_F4E_Load2',
    }
    SeadPlaneTemplate = {
        'RED_SU-24M_TWOSHIP',
        'RED_SU-24M_ONESHIP',
    }
    CasHeloTemplate = {
        'RED_Mi-24V_ONESHIP',
        'RED_Mi-24V_TWOSHIP',
        'BLUE_UH-1H_CAS',
        'BLUE_UH-1H_CAS_TwoShip',
    }
    HeloSupplyTemplate = {
        'RED_MI-8',
        'RED_MI-8_2',
        'BLUE_CH-47',
        'BLUE_CH-47_2',
        'BLUE_UH-60A',
        'BLUE_UH-1H',    
    }
    AttackConvoy = {
        "AttackConvoy CW 1",
        "AttackConvoy CW 2",
        "AttackConvoy CW 3",
        "AttackConvoy CW 4",
    }
    GroundAttackConvoy = {
        "GroundAttackConvoy CW 1",
        "GroundAttackConvoy CW 2",
    }
	RunwayStrikePlaneTemplate = {
        "RED_MIG-27K_RUNWAY",
        "RED_MIRAGE_F1_RUNWAY",
    }
	CapCarrierGroup = {
        'BLUE_F14A',
        'BLUE_HORNET_CW',
	}
	
else

    CapPlaneTemplate = {
        'RED_MIG29S_Load1',
		'RED_MIG29S_Load2',
        'RED_MIG29A_Load1',
        'RED_MIG29A_Load2',
        'RED_SU27_Load1',
        'RED_SU27_Load2',
        'RED_MIG21Bis_Load1',
        'RED_MIG21Bis_Load2',
        'RED_MIG23MLD',
        'RED_MIG25PD',
        'BLUE_HORNET',
        'BLUE_F15C',
        'BLUE_F16C',
        'BLUE_F14B',
        'BLUE_M-2000C',
    }
    HeloSupplyTemplate = {
        'RED_MI-8',
        'RED_MI-8_2',
        'BLUE_CH-47',
        'BLUE_CH-47_2',
        'BLUE_UH-60A',
    }
    CasPlaneTemplate = {
		'RED_SU25_OneShip_Load1',
		'RED_SU25_OneShip_Load2',
		'RED_SU25_OneShip_Load3',
        'RED_SU25_TwoShip_Load1',
		'RED_SU25_TwoShip_Load2',
		'RED_SU25_TwoShip_Load3',
		'RED_SU25T_OneShip_Load1',
		'RED_SU25T_OneShip_Load2',
		'RED_SU25T_OneShip_Load3',
		'RED_SU25T_TwoShip_Load1',
		'RED_SU25T_TwoShip_Load2',
		'RED_SU25T_TwoShip_Load3',
        'RED_Mirage_F1BQ_Load1',
        'RED_Mirage_F1BQ_Load2',
        'RED_MIG21_BIS_ONE_SHIP',
        'RED_MIG21_BIS_TWO_SHIP',
        'BLUE_F4E_Load1',
        'BLUE_F4E_Load2',
    }
    SeadPlaneTemplate = {
        'RED_JF17_ONESHIP_SEAD',
        'RED_JF17_TWOSHIP_SEAD',
        'RED_SU25T_ONESHIP_SEAD',
        'RED_SU25T_TWOSHIP_SEAD',
        'RED_SU-34_ONESHIP_Load1',
        'RED_SU-34_ONESHIP_Load2',
        'RED_SU-34_TWOSHIP_Load1',
        'RED_SU-34_TWOSHIP_Load2',
        'RED_SU-24M_TWOSHIP',
        'RED_SU-24M_ONESHIP',
    }
    CasHeloTemplate ={
        'RED_Mi-24P_ONESHIP',
        'RED_Mi-24P_TWOSHIP',
        'RED_M-28N_ONESHIP_Load1',
        'RED_M-28N_ONESHIP_Load2',
        'RED_M-28N_TWOSHIP_Load1',
        'RED_M-28N_TWOSHIP_Load2',
        'BLUE_AH-64D_ONESHIP',
        'BLUE_AH-64D_TWOSHIP',
        'BLUE_AH-64D_TwoShip_Load2',
        'BLUE_AH-1W',
        'BLUE_SA342M',
        'BLUE_SA342M_TwoShip',
        'OH_58D',
        'OH_58D_TwoShip',
    }
    AttackConvoy = {
        "AttackConvoy 1",
        "AttackConvoy 2",
        "AttackConvoy 3",
        "AttackConvoy 4",
    }
    GroundAttackConvoy = {
        "GroundAttackConvoy 1",
        "GroundAttackConvoy 2",
        "GroundAttackConvoy 3",
    }
	RunwayStrikePlaneTemplate = {
        "RED_MIG-27K_RUNWAY",
        "RED_SU-33_RUNWAY",
        "RED_MIRAGE_F1_RUNWAY",
    }
	CapCarrierGroup = {
        'BLUE_HORNET',
        'BLUE_F14B',
	}
end
	SupplyConvoy = {
		"SupplyConvoy 1",
		"SupplyConvoy 2",
		"SupplyConvoy 3",
		"SupplyConvoy_Blue 1",
	}
	PlaneSupplyTemplate = {
		"IL-76MD",
		"C-130J-30",
		"AN-30M",
	}
	InsurgentConvoy = {
    
    "InsurgentConvoy 1",
    "InsurgentConvoy 2",
	}

function CasAltitude() return math.random(15,25)*1000 end
function CapAltitude() return math.random(22,32)*1000 end
function SeadAltitude() return math.random(25,33)*1000 end
function RunwayStrikeAltitude() return math.random(23,28)*1000 end

zones.bodo:addGroups({
    GroupCommander:new({name='Bodo-supply-Kvikkjokk', mission='supply',template='HeloSupplyTemplate', targetzone='Kvikkjokk'}),
    GroupCommander:new({name='Bodo-supply-Bergsbasen', mission='supply',template='HeloSupplyTemplate', targetzone='BergsBasen'}),
    GroupCommander:new({name='Bodo-supply-Skogsbasen', mission='supply',template='HeloSupplyTemplate', targetzone='Skogsbasen'}),
    GroupCommander:new({name='Bodo-supply-Andoya', mission='supply',template='PlaneSupplyTemplate', targetzone='Andoya'}),
    GroupCommander:new({name='Bodo-supply-Kiruna', mission='supply',template='PlaneSupplyTemplate', targetzone='Kiruna'}),
    GroupCommander:new({name='Bodo-supply-Vidsel', mission='supply',template='PlaneSupplyTemplate', targetzone='Vidsel'}),
    GroupCommander:new({name='Bodo-supply-Kallax', mission='supply',template='PlaneSupplyTemplate', targetzone='Kallax'}),
    GroupCommander:new({name='Bodo-patrol-Kiruna-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kiruna', Altitude = CapAltitude()}),
    GroupCommander:new({name='Bodo-patrol-BergsBasen-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='BergsBasen', Altitude = CapAltitude()}),
    GroupCommander:new({name='Bodo-attack-BergsBasen-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Skogsbasen', Altitude = CapAltitude()}),
    GroupCommander:new({name='Bodo-patrol-Kittila-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kittila', Altitude = CapAltitude()}),
    GroupCommander:new({name='Bodo-attack-BergsBasen-Cas', mission='attack',template='CasHeloTemplate', MissionType='CAS', targetzone='BergsBasen'}),
})

zones.andoya:addGroups({
    GroupCommander:new({name='Andoya-supply-Bardufoss', mission='supply',template='PlaneSupplyTemplate', targetzone='Bardufoss'}),
    GroupCommander:new({name='Andoya-supply-Bodo', mission='supply',template='PlaneSupplyTemplate', targetzone='Bodo'}),
    GroupCommander:new({name='Andoya-supply-Banak', mission='supply',template='PlaneSupplyTemplate', targetzone='Banak'}),
    GroupCommander:new({name='Andoya-supply-Ivalo', mission='supply',template='PlaneSupplyTemplate', targetzone='Ivalo'}),
    GroupCommander:new({name='Andoya-supply-Kirkenes', mission='supply',template='PlaneSupplyTemplate', targetzone='Kirkenes'}),
    GroupCommander:new({name='Andoya-patrol-Banak-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Banak', Altitude = CapAltitude()}),
    GroupCommander:new({name='Andoya-patrol-Ivalo-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Ivalo', Altitude = CapAltitude()})
})

zones.bergsbasen:addGroups({
    GroupCommander:new({name='Bergsbasen-supply-Kvikkjokk', mission='supply',template='HeloSupplyTemplate', targetzone='Kvikkjokk'}),
    GroupCommander:new({name='Bergsbasen-supply-Skogsbasen', mission='supply',template='HeloSupplyTemplate', targetzone='Skogsbasen'})
})

zones.bardufoss:addGroups({
    GroupCommander:new({name='Bardufoss-patrol-Bardufoss-Cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Bardufoss', Altitude = CapAltitude()}),
    GroupCommander:new({name='Bardufoss-patrol-Kiruna-Cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Kiruna', Altitude = CapAltitude()}),

})

zones.vidsel:addGroups({
    GroupCommander:new({name='Vidsel-supply-Gallivare', mission='supply',template='HeloSupplyTemplate', targetzone='Gallivare'}),
    GroupCommander:new({name='Vidsel-supply-Jokkmokk', mission='supply',template='HeloSupplyTemplate', targetzone='Jokkmokk'}),
    GroupCommander:new({name='Vidsel-supply-Kallax', mission='supply',template='HeloSupplyTemplate', targetzone='Kallax'}),
    GroupCommander:new({name='Vidsel-patrol-Rovaniemi-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Rovaniemi', Altitude = CapAltitude()})
})

zones.kallax:addGroups({
    GroupCommander:new({name='Kallax-supply-Kalix', mission='supply',template='HeloSupplyTemplate', targetzone='Kalix'}),
    GroupCommander:new({name='Kallax-supply-SAMAlvik', mission='supply',template='SupplyConvoy', targetzone='SAMAlvik', type ='surface'}),
    GroupCommander:new({name='Kallax-supply-KemiTornio', mission='supply',template='PlaneSupplyTemplate', targetzone='KemiTornio'}),
    GroupCommander:new({name='Kallax-patrol-Jokkmokk-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Jokkmokk', Altitude = CapAltitude()}),
    GroupCommander:new({name='Kallax-attack-Jokkmokk-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Jokkmokk', Altitude = CapAltitude()}),
    GroupCommander:new({name='Kallax-attack-Jokkmokk-Sead', mission='attack',template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Jokkmokk', Altitude = SeadAltitude()}),
    GroupCommander:new({name='Kallax-attack-Vidsel', mission='attack',template='CasHeloTemplate', MissionType='CAS', targetzone='Vidsel'}),
    GroupCommander:new({name='Kallax-patrol-kvikkjokk', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kvikkjokk', Altitude = CapAltitude()}),
    GroupCommander:new({name='Kallax-AWACS', mission='patrol',targetzone='Vidsel'})
})

zones.banak:addGroups({
    GroupCommander:new({name='Banak-supply-Guovdageaidnu', mission='supply',template='HeloSupplyTemplate', targetzone='Guovdageaidnu'}),
    GroupCommander:new({name='Banak-supply-Buolbmat', mission='supply',template='HeloSupplyTemplate', targetzone='Buolbmat'}),
    GroupCommander:new({name='Banak-supply-Karasjok', mission='supply',template='HeloSupplyTemplate', targetzone='Karasjok'}),
    GroupCommander:new({name='Banak-supply-Ivalo', mission='supply',template='PlaneSupplyTemplate', targetzone='Ivalo'}),
    GroupCommander:new({name='Banak-supply-Kirkenes', mission='supply',template='PlaneSupplyTemplate', targetzone='Kirkenes'}),
    GroupCommander:new({name='Banak-attack-Bardufoss-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Kirkenes', Altitude = SeadAltitude()}),
    GroupCommander:new({name='Banak-attack-Bardufoss-Cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Kirkenes', Altitude = CapAltitude()}),
})

zones.alta:addGroups({
    GroupCommander:new({name='Alta-supply-Banak', mission='supply',template='HeloSupplyTemplate', targetzone='Banak'}),
})

zones.kirkenes:addGroups({
    GroupCommander:new({name='Kirkenes-supply-Murmansk', mission='supply',template='PlaneSupplyTemplate', targetzone='MurmanskInternational'}),
    GroupCommander:new({name='Kirkenes-supply-Prirechnyi', mission='supply',template='HeloSupplyTemplate', targetzone='Prirechnyi'}),
    GroupCommander:new({name='Kirkenes-supply-Zapolyaryy', mission='supply',template='HeloSupplyTemplate', targetzone='Zapolyarnyy'}),
    GroupCommander:new({name='Kirkenes-supply-Buolbmat', mission='supply',template='HeloSupplyTemplate', targetzone='Buolbmat'}),
    GroupCommander:new({name='Kirkenes-supply-Severosmorsk1', mission='supply',template='PlaneSupplyTemplate', targetzone='Severomorsk1'}),
    GroupCommander:new({name='Kirkenes-supply-Ivalo', mission='supply',template='PlaneSupplyTemplate', targetzone='Ivalo'}),
    GroupCommander:new({name='Kirkenes-AWACS', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Ivalo', Altitude = CapAltitude()})
})

zones.kittila:addGroups({
    GroupCommander:new({name='Kittila-supply-Vuojarvi', mission='supply',template='HeloSupplyTemplate', targetzone='Vuojarvi'}),
    GroupCommander:new({name='Kittila-attack-Kiruna-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Kiruna', Altitude = CasAltitude()}),
    GroupCommander:new({name='Kittila-attack-Kiruna-Cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Kiruna', Altitude = CapAltitude()}),
    GroupCommander:new({name='Kittila-attack-Kiruna-Runway', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Kiruna', Altitude = RunwayStrikeAltitude()}),
})

zones.ivalo:addGroups({
    GroupCommander:new({name='Ivalo-supply-Karasjok', mission='supply',template='HeloSupplyTemplate', targetzone='Karasjok'}),
    GroupCommander:new({name='Ivalo-supply-Luspa', mission='supply',template='HeloSupplyTemplate', targetzone='Luspa'}),
    GroupCommander:new({name='Ivalo-supply-Guovdageaidnu', mission='supply',template='HeloSupplyTemplate', targetzone='Guovdageaidnu'}),
    GroupCommander:new({name='Ivalo-Patrol-Karasjok-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Karasjok', Altitude = CapAltitude()}),
    GroupCommander:new({name='Ivalo-Patrol-Gallivare-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Gallivare', Altitude = CapAltitude()})
})

zones.severomorsk1:addGroups({
    GroupCommander:new({name='Severomorsk1-supply-Murmansk', mission='supply',template='PlaneSupplyTemplate', targetzone='MurmanskInternational'}),
    GroupCommander:new({name='Severomorsk1-supply-Severomorsk3', mission='supply',template='PlaneSupplyTemplate', targetzone='Severomorsk3'}),
    GroupCommander:new({name='Severomorsk1-supply-Prirechnyi', mission='supply',template='HeloSupplyTemplate', targetzone='Prirechnyi'}),
    GroupCommander:new({name='Severomorsk1-supply-Zapolyarnyy', mission='supply',template='HeloSupplyTemplate', targetzone='Zapolyarnyy'}),
    GroupCommander:new({name='Severosmorsk1-supply-Monchegorsk', mission='supply',template='PlaneSupplyTemplate', targetzone='Monchegorsk'}),
    GroupCommander:new({name='Severosmorsk1-supply-Olenya', mission='supply',template='PlaneSupplyTemplate', targetzone='Olenya'}),
    GroupCommander:new({name='Severomorsk-1-Patrol-Alakourtti-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Alakourtti', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-1-Patrol-Rovaniemi-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Rovaniemi', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-1-Patrol-Zapolyarnyy-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Zapolyarnyy', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-1-Patrol-Kiruna-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kiruna', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-1-Patrol-Ivalo-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Ivalo', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-1-Patrol-Kittila-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kittila', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-1-Patrol-Banak-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Banak', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk1-attack-Kiruna-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kiruna', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk1-attack-Kirkenes-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kirkenes', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk1-attack-Banak-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Banak', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk1-attack-Ivalo-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Ivalo', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk1-attack-Kittila-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kittila', Altitude = CapAltitude()})
})


zones.severomorsk3:addGroups({
    GroupCommander:new({name='Severomorsk-3-Sweep-Sweden', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kiruna', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-3-Sweep-Sweden2', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kiruna', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-3-Sweep-Sweden3', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kiruna', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-3-Sweep-Finland', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Rovaniemi', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-3-Sweep-Finland2', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Rovaniemi', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-3-Sweep-Russia', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Olenya', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk-3-Sweep2-Russia', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Olenya', Altitude = CapAltitude()}),
    GroupCommander:new({name='Severomorsk3-Intercept', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Severomorsk1', Altitude = CapAltitude()})
})

zones.olenya:addGroups({
    GroupCommander:new({name='Olenya-supply-Monchegorsk', mission='supply',template='PlaneSupplyTemplate', targetzone='Monchegorsk'}),
    GroupCommander:new({name='Olenya-supply-LaplandiaStorage', mission='supply',template='HeloSupplyTemplate', targetzone='LaplandiyaStorage'}),
    GroupCommander:new({name='Olenya-supply-Lovozero', mission='supply',template='HeloSupplyTemplate', targetzone='LovozeroCCC'}),
    GroupCommander:new({name='Olenya-supply-Banak', mission='supply',template='PlaneSupplyTemplate', targetzone='Banak'}),
    GroupCommander:new({name='Olenya-supply-Murmansk', mission='supply',template='PlaneSupplyTemplate', targetzone='MurmanskInternational'}),
    GroupCommander:new({name='Olenya-supply-Severomorsk1', mission='supply',template='PlaneSupplyTemplate', targetzone='Severomorsk1'}),
    GroupCommander:new({name='Olenya-supply-Severomorsk3', mission='supply',template='PlaneSupplyTemplate', targetzone='Severomorsk3'}),
    GroupCommander:new({name='Olenya-supply-Alakourtti', mission='supply',template='PlaneSupplyTemplate', targetzone='Alakourtti'}),
    GroupCommander:new({name='Olenya-supply-Ivalo', mission='supply',template='PlaneSupplyTemplate', targetzone='Ivalo'}),
    GroupCommander:new({name='Olenya-supply-Rovaniemi', mission='supply',template='PlaneSupplyTemplate', targetzone='Rovaniemi'}),
    GroupCommander:new({name='Olenya-supply-Kuusamo', mission='supply',template='HeloSupplyTemplate', targetzone='Kuusamo'}),
    GroupCommander:new({name='Olenya-supply-Kirkenes', mission='supply',template='PlaneSupplyTemplate', targetzone='Kirkenes'}),
    GroupCommander:new({name='Olenya-supply-KemiTornio', mission='supply',template='PlaneSupplyTemplate', targetzone='KemiTornio'}),
    GroupCommander:new({name='Olenya-supply-Kiruna', mission='supply',template='PlaneSupplyTemplate', targetzone='Kiruna'}),
    GroupCommander:new({name='Olenya-supply-OlenyaEWR', mission='supply',template='HeloSupplyTemplate', targetzone='HiddenOlenyaEWR'}),
    GroupCommander:new({name='Olenya-CAP-Severomorsk-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Severomorsk3', Altitude = CapAltitude()}),
    GroupCommander:new({name='Red EWR Awacs', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='MurmanskInternational', Altitude = CapAltitude()})
})

zones.monchegorsk:addGroups({
    GroupCommander:new({name='Monchegorsk-supply-Apatity', mission='supply',template='HeloSupplyTemplate', targetzone='Apatity'}),
    GroupCommander:new({name='Monchegorsk-supply-Kovdor', mission='supply',template='HeloSupplyTemplate', targetzone='Kovdor'}),
    GroupCommander:new({name='Monchegorsk-supply-Zelenoborskij', mission='supply',template='HeloSupplyTemplate', targetzone='ZelenoborskijStorage'}),
    GroupCommander:new({name='Monchegorsk-supply-Olenya', mission='supply',template='HeloSupplyTemplate', targetzone='Olenya'}),
    GroupCommander:new({name='Monchegorsk-supply-Tungozero', mission='supply',template='HeloSupplyTemplate', targetzone='HiddenTungozero'}),
    GroupCommander:new({name='Monchegorsk-Patrol-Kovdor-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kovdor', Altitude = CapAltitude()}),
    GroupCommander:new({name='Monchegorsk-Patrol-Rovaniemi-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Rovaniemi', Altitude = CapAltitude()}),
    GroupCommander:new({name='Monchegorsk-attack-Rovaniemi-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Rovaniemi', Altitude = CasAltitude()}),
    GroupCommander:new({name='Monchegorsk-attack-Kittila-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Kittila', Altitude = CasAltitude()}),
    GroupCommander:new({name='Monchegorsk-attack-Kiruna-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Kiruna', Altitude = CasAltitude()}),
    GroupCommander:new({name='Monchegorsk-attack-Kallax-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Kallax', Altitude = CasAltitude()}),
    GroupCommander:new({name='Monchegorsk-attack-Kallax-runway', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Kallax', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name='Monchegorsk-attack-Ivalo-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Ivalo', Altitude = CasAltitude()})
})

zones.alakourtti:addGroups({
    GroupCommander:new({name='Alakourtti-supply-Kovdor', mission='supply',template='HeloSupplyTemplate', targetzone='Kovdor'}),
    GroupCommander:new({name='Alarkourtti-supply-Kelloselka', mission='supply',template='HeloSupplyTemplate', targetzone='Kelloselka'}),
    GroupCommander:new({name='Alarkourtti-supply-Savukoski', mission='supply',template='HeloSupplyTemplate', targetzone='Savukoski'})
})

zones.kelloselka:addGroups({
    GroupCommander:new({name='Kelloselka-supply-Alakourtti', mission='supply',template='HeloSupplyTemplate', targetzone='Alakourtti'}),
    GroupCommander:new({name='Kelloselka-supply-Maaninkavaara', mission='supply',template='HeloSupplyTemplate', targetzone='Maaninkavaara'})
})

zones.kuusamo:addGroups({
    GroupCommander:new({name='Kuusamo-supply-Maaninkavaara', mission='supply',template='HeloSupplyTemplate', targetzone='Maaninkavaara'})
})

zones.maaninkavaara:addGroups({
    GroupCommander:new({name='Maaninkavaara-supply-Kuusamo', mission='supply',template='HeloSupplyTemplate', targetzone='Kuusamo'})
})

zones.savukoski:addGroups({
    GroupCommander:new({name='Savukoski-supply-Kovdor', mission='supply',template='HeloSupplyTemplate', targetzone='Kovdor'}),
    GroupCommander:new({name='Savukoski-supply-Kelloselka', mission='supply',template='HeloSupplyTemplate', targetzone='Kelloselka'}),
    GroupCommander:new({name='Savukoski-supply-Voujarvi', mission='supply',template='HeloSupplyTemplate', targetzone='Vuojarvi'})
})

zones.rovaniemi:addGroups({
    GroupCommander:new({name='Rovaniemi-supply-Tervola', mission='supply',template='HeloSupplyTemplate', targetzone='Tervola'}),
    GroupCommander:new({name='Rovaniemi-supply-Voujarvi', mission='supply',template='PlaneSupplyTemplate', targetzone='Vuojarvi'}),
    GroupCommander:new({name='Rovaniemi-patrol-KemiTornio-Cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='KemiTornio', Altitude = CapAltitude()}),
    GroupCommander:new({name='Rovaniemi-attack-Kallax-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Kallax', Altitude = CasAltitude()}),
    GroupCommander:new({name='Rovaniemi-attack-Kallax-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='SAMAlvik', Altitude = SeadAltitude()}),
})

zones.vuojarvi:addGroups({
    GroupCommander:new({name='Voujarvi-supply-Kelloselka', mission='supply',template='HeloSupplyTemplate', targetzone='Kelloselka'}),
    GroupCommander:new({name='Voujarvi-supply-Savukoski', mission='supply',template='HeloSupplyTemplate', targetzone='Savukoski'}),
    GroupCommander:new({name='Voujarvi-supply-Kittila', mission='supply',template='PlaneSupplyTemplate', targetzone='Kittila'})
})

zones.tervola:addGroups({
    GroupCommander:new({name='tervola-attack-kemitornio-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='KemiTornio'}),
})

zones.kemitornio:addGroups({
    GroupCommander:new({name='KemiTornio-supply-Tervola', mission='supply',template='HeloSupplyTemplate', targetzone='Tervola'}),
    GroupCommander:new({name='KemiTornio-supply-Kalix', mission='supply',template='HeloSupplyTemplate', targetzone='Kalix'}),
    GroupCommander:new({name='KemiTornio-supply-Rovaniemi', mission='supply',template='PlaneSupplyTemplate', targetzone='Rovaniemi'}),
    GroupCommander:new({name='KemiTornio-supply-Kuusamo', mission='supply',template='HeloSupplyTemplate', targetzone='Kuusamo'}),
    GroupCommander:new({name='KemiTornio-attack-Jokkmokk', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Jokkmokk', Altitude = SeadAltitude()}),
    GroupCommander:new({name='KemiTornio-attack-Kalix-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Kalix'}),
    GroupCommander:new({name='KemiTornio-patrol-KemiTornio', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='KemiTornio', Altitude = CapAltitude()}),
})

zones.kiruna:addGroups({
    GroupCommander:new({name='Kiruna-supply-Guovdageaidnu', mission='supply',template='HeloSupplyTemplate', targetzone='Guovdageaidnu'}),
    GroupCommander:new({name='Kiruna-supply-Kalixfors', mission='supply',template='SupplyConvoy', targetzone='Kalixfors', type='surface'}),
    GroupCommander:new({name='Kiruna-supply-Gallivare', mission='supply',template='HeloSupplyTemplate', targetzone='Gallivare'}),
    GroupCommander:new({name='Kiruna-supply-Luspa', mission='supply',template='HeloSupplyTemplate', targetzone='Luspa', ForceFromGround = true}),
    GroupCommander:new({name='Kiruna-supply-Kittila', mission='supply',template='HeloSupplyTemplate', targetzone='Kittila'}),
    GroupCommander:new({name='Kiruna-supply-Jokkmokk', mission='supply',template='HeloSupplyTemplate', targetzone='Jokkmokk'}),
    GroupCommander:new({name='Kiruna-supply-Kvikkjokk', mission='supply',template='HeloSupplyTemplate', targetzone='Kvikkjokk'}),
    GroupCommander:new({name='Kiruna-supply-Bergsbasen', mission='supply',template='HeloSupplyTemplate', targetzone='BergsBasen'}),
    GroupCommander:new({name='Kiruna-supply-Skogsbasen', mission='supply',template='HeloSupplyTemplate', targetzone='Skogsbasen'}),
    --GroupCommander:new({name='Kiruna-supply-Bardufoss', mission='supply',template='HeloSupplyTemplate', targetzone='Bardufoss'}),
    GroupCommander:new({name='Kiruna-attack-Kittila-cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Kittila', Altitude = CapAltitude()}),
    GroupCommander:new({name='Kiruna-attack-Ivalo-cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Ivalo', Altitude = CapAltitude()}),
    GroupCommander:new({name='Kiruna-patrol-Kvikkjokk-cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Kvikkjokk', Altitude = CapAltitude()}),
    GroupCommander:new({name='Kiruna-AWACS-blue', mission='patrol', targetzone='Kittila'})
})
zones.jokkmokk:addGroups({
    GroupCommander:new({name='Jokkmokk-attack-Gallivare', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Gallivare'}),
    GroupCommander:new({name='Jokkmokk-attack-Vidsel', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Vidsel'}),
    GroupCommander:new({name='Jokkmokk-patrol-Kvikkjokk', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Kvikkjokk', Altitude = CapAltitude()})
})
zones.kalix:addGroups({
    GroupCommander:new({name='Kalix-attack-Kallax', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Kallax'}),
    GroupCommander:new({name='Kalix-attack-KemiTornio', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='KemiTornio'})
})

for i,v in pairs(zones) do
    bc:addZone(v)
end

missions = {
    SkogsFARP1 = {	
        zone = "SkogsFARP1",
        missionGroup = "SkogsFarpGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Mission"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Mission"),
        TargetZone = "SkogsFARP2",
        MissionType = "Escort",
		radius = 2500,
		flag = 101,
        ActivateZone = "hiddenForestguard"
    },
    SkogsFARP2 = {	
        zone = "SkogsFARP2",
        missionGroup = "SkogsFarp2Group",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Mission"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Mission"),
        TargetZone = "SkogsFARP3",
        MissionType = "Escort",
		radius = 2500,
		flag = 111,
        ActivateZone = "hiddenRanuaGuard"
    },
    SkogsFARP3 = {	
        zone = "SkogsFARP3",
        missionGroup = "SkogsFarp3Group",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Mission"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Mission"),
        TargetZone = "SkogsFARP4",
        MissionType = "Escort",
		radius = 2500,
		flag = 121,
        ActivateZone = "hiddenPosioGuard"
    }
}


--------------- HELO SPAWN ---------------------


zones.bodo.isHeloSpawn = true
zones.bodo.LogisticCenter = true

zones.andoya.isHeloSpawn = true
zones.andoya.LogisticCenter = true

zones.luspa.isHeloSpawn = true
zones.kvikkjokk.isHeloSpawn = true
zones.bergsbasen.isHeloSpawn = true
zones.skogsbasen.isHeloSpawn = true
zones.guovdageaidnu.isHeloSpawn = true
zones.kalix.isHeloSpawn = true
zones.tervola.isHeloSpawn = true
zones.kelloselka.isHeloSpawn = true
zones.buolbmat.isHeloSpawn = true
zones.savukoski.isHeloSpawn = true
zones.skogsfarp1.isHeloSpawn = true
zones.skogsfarp2.isHeloSpawn = true
zones.skogsfarp3.isHeloSpawn = true
zones.skogsfarp4.isHeloSpawn = true
zones.maaninkavaara.isHeloSpawn = true
zones.gallivare.isHeloSpawn = true
--zones.kandalaksha.airbaseName = 'Kandalaksha'
zones.apatity.isHeloSpawn = true
--zones.loukhi.airbaseName = 'Loukhi'
zones.kovdor.isHeloSpawn = true
zones.zapolyarnyy.isHeloSpawn = true
zones.karasjok.isHeloSpawn = true
zones.kalixfors.isHeloSpawn = true
zones.kiruna.isHeloSpawn = true
zones.banak.isHeloSpawn = true
zones.alta.isHeloSpawn = true
zones.ivalo.isHeloSpawn = true
zones.bardufoss.isHeloSpawn = true
zones.kemitornio.isHeloSpawn = true
zones.kirkenes.isHeloSpawn = true
zones.vuojarvi.isHeloSpawn = true
zones.murmanskinternational.isHeloSpawn = true
zones.jokkmokk.isHeloSpawn = true
zones.kallax.isHeloSpawn = true
zones.vidsel.isHeloSpawn = true
zones.rovaniemi.isHeloSpawn = true
zones.kuusamo.isHeloSpawn = true
zones.kittila.isHeloSpawn = true
zones.severomorsk1.isHeloSpawn = true
zones.severomorsk3.isHeloSpawn = true
zones.monchegorsk.isHeloSpawn = true
zones.olenya.isHeloSpawn = true
zones.alakourtti.isHeloSpawn = true
zones.prirechnyi.isHeloSpawn = true


---------------- AIRBASE NAMES ----------------
-- alla flygplatser måste fyllas här också. då tar man namnet som finns i editorn. Case sensitive
-- utkommenterande är inte inlagda ännu som zoner, men farps är klara. Måste även läggas in som Zones I WelcomeMessage 
--Leka--
zones.bodo.airbaseName = 'Bodo'
zones.andoya.airbaseName = 'Andoya'
zones.luspa.airbaseName = 'Luspa'
zones.kvikkjokk.airbaseName = 'Kvikkjokk'
zones.bergsbasen.airbaseName = 'BergsBasen'
zones.skogsbasen.airbaseName = 'Skogsbasen'
zones.guovdageaidnu.airbaseName = 'Guovdageaidnu'
zones.kalix.airbaseName = 'Kalix'
zones.tervola.airbaseName = 'Tervola'
zones.kelloselka.airbaseName = 'Kelloselka'
zones.buolbmat.airbaseName = 'Buolbmat'
zones.savukoski.airbaseName = 'Savukoski'
zones.skogsfarp1.airbaseName = 'SkogsFARP1'
zones.skogsfarp2.airbaseName = 'SkogsFARP2'
zones.skogsfarp3.airbaseName = 'SkogsFARP3'
zones.skogsfarp4.airbaseName = 'SkogsFARP4'
zones.maaninkavaara.airbaseName = 'Maaninkavaara'
zones.gallivare.airbaseName = 'Gallivare'
--zones.kandalaksha.airbaseName = 'Kandalaksha'
zones.apatity.airbaseName = 'Apatity'
--zones.loukhi.airbaseName = 'Loukhi'
zones.kovdor.airbaseName = 'Kovdor'
zones.zapolyarnyy.airbaseName = 'Zapolyarnyy'
zones.karasjok.airbaseName = 'Karasjok'
zones.kalixfors.airbaseName = 'Kalixfors'
zones.kiruna.airbaseName = 'Kiruna'
zones.banak.airbaseName = 'Banak'
zones.alta.airbaseName = 'Alta'
zones.ivalo.airbaseName = 'Ivalo'
zones.bardufoss.airbaseName = 'Bardufoss'
zones.kemitornio.airbaseName = 'Kemi Tornio'
zones.kirkenes.airbaseName = 'Kirkenes'
zones.vuojarvi.airbaseName = 'Vuojarvi'
zones.murmanskinternational.airbaseName ='Murmansk International'
zones.jokkmokk.airbaseName ='Jokkmokk'
zones.vidsel.airbaseName ='Vidsel'
zones.kallax.airbaseName ='Kallax'
zones.rovaniemi.airbaseName ='Rovaniemi'
zones.kuusamo.airbaseName ='Kuusamo'
zones.kittila.airbaseName ='Kittila'
zones.severomorsk1.airbaseName ='Severomorsk-1'
zones.severomorsk3.airbaseName ='Severomorsk-3'
zones.monchegorsk.airbaseName ='Monchegorsk'
zones.olenya.airbaseName ='Olenya'
zones.alakourtti.airbaseName ='Alakurtti'


--[[ AirbaseBelonging = AirbaseBelonging or {}
AirbaseBelonging["Lar"]     = AirbaseBelonging["Lar"]     or {"Shiraz Intl"}
AirbaseBelonging["Samathe"] = AirbaseBelonging["Samathe"] or {"Jiroft","Kerman"}
 ]]

 
--zones.ivalofarp.airbaseName = 'Ivalo FARP'

bc:addConnection("Bodo","BergsBasen")
bc:addConnection("Bodo","Andoya")
bc:addConnection("Bodo","Vidsel")
bc:addConnection("Bodo","Kiruna")
bc:addConnection("Andoya","Alta")
bc:addConnection("Alta","Banak")
--bc:addConnection("Andoya","Ivalo")
bc:addConnection("Banak","Buolbmat")
--bc:addConnection("Andoya","Kirkenes")
bc:addConnection("Andoya","Bardufoss")
bc:addConnection("Kiruna","Kittila")
bc:addConnection("Kittila","Vuojarvi")
bc:addConnection("BergsBasen","Kvikkjokk")
bc:addConnection("Kvikkjokk","Skogsbasen")
bc:addConnection("Kvikkjokk","Jokkmokk")
bc:addConnection("Skogsbasen","Kiruna")
bc:addConnection("Skogsbasen","Gallivare")
bc:addConnection("Gallivare","Kiruna")
bc:addConnection("Gallivare","Jokkmokk")
bc:addConnection("Jokkmokk","Vidsel")
bc:addConnection("Vidsel","Kallax")
bc:addConnection("Kallax","Kalix")
bc:addConnection("Kalix","KemiTornio")
bc:addConnection("Kallax","SAMAlvik")
bc:addConnection("Kuusamo","KemiTornio")
bc:addConnection("KemiTornio","Tervola")
bc:addConnection("Rovaniemi","Tervola")
bc:addConnection("Rovaniemi","Vuojarvi")
bc:addConnection("Vuojarvi","Savukoski")
bc:addConnection("Kelloselka","Savukoski")
bc:addConnection("Savukoski","Kovdor")
bc:addConnection("Apatity","Monchegorsk")
bc:addConnection("MurmanskInternational","Severomorsk3")
bc:addConnection("Severomorsk3","Severomorsk1")
bc:addConnection("Zapolyarnyy","Severomorsk1")
bc:addConnection("Kirkenes","Zapolyarnyy")
bc:addConnection("Kirkenes","Buolbmat")
bc:addConnection("Kiruna","Luspa")
bc:addConnection("Kiruna","Kalixfors")
bc:addConnection("Luspa","Guovdageaidnu")
bc:addConnection("Karasjok","Guovdageaidnu")
bc:addConnection("Karasjok","Banak")
bc:addConnection("Karasjok","Ivalo")
bc:addConnection("Prirechnyi","Severomorsk1")
bc:addConnection("Ivalo","Vuojarvi")
bc:addConnection("Ivalo","Guovdageaidnu")
bc:addConnection("Luspa","Ivalo")
bc:addConnection("Kelloselka","Alakourtti")
bc:addConnection("Kuusamo","Alakourtti")
bc:addConnection("Maaninkavaara","Kuusamo")
bc:addConnection("Kelloselka","Maaninkavaara")
bc:addConnection("Zapolyarnyy","Prirechnyi")
bc:addConnection("Prirechnyi","Severomorsk1")
bc:addConnection("Monchegorsk","ZelenoborskijStorage")
--Olenya logistics hub
bc:addConnection("Monchegorsk","Olenya")
--bc:addConnection("Kiruna","Olenya")
--bc:addConnection("Kirkenes","Olenya")
--bc:addConnection("Banak","Olenya")
--bc:addConnection("Olenya","MurmanskInternational")
--bc:addConnection("Severomorsk1","Olenya")
bc:addConnection("Severomorsk3","Olenya")
--bc:addConnection("Alakourtti","Olenya")
--bc:addConnection("Vuojarvi","Olenya")
--bc:addConnection("Rovaniemi","Olenya")
bc:addConnection("Ivalo","Olenya")
bc:addHiddenConnection("Banak","Kiruna")
bc:addHiddenConnection("Andoya","Banak")
--bc:addConnection("Kuusamo","Olenya")
--bc:addConnection("LaplandiyaStorage","Olenya")
--bc:addConnection("LovozeroCCC","Olenya")


supplyZones = {
    'Kiruna',   
    'Jokkmokk', 
    'Luspa',    
    'Vidsel',   
    'Kallax',   
    'SAMAlvik', 
    'Kvikkjokk',
    'Skogsbasen',
    'Gallivare',
    'Kalixfors',
    'Kiruna', 
    'Andoya',
    'Kittila',
    'Bardufoss',
    'Bodo',                 
    'Kirkenes',             
    'Banak',                
    'Alta',                
    'Karasjok',             
    'Guovdageaidnu',        
    'BergsBasen', 
    'KemiTornio',           
    'Rovaniemi',            
    'Vuojarvi',             
    'Kuusamo',              
    'Savukoski',            
    'Ivalo',                
    'Kalix',                
    'Tervola',              
    'Kelloselka',           
    'Buolbmat',             
    'Maaninkavaara',
    'Apatity',              
    'Zapolyarnyy',          
    'Alakourtti',           
    'Prirechnyi',       
    'Olenya',               
    'MurmanskInternational',
    'Severomorsk3',         
    'Severomorsk1',         
    'Kovdor',               
    'Monchegorsk',
    'SkogsFARP1',
    'SkogsFARP2',
    'SkogsFARP3',
    'SkogsFARP4',
    'LovozeroCCC',
    'ZelenoborskijStorage',
    'LaplandiyaStorage'
}
----------------------end of asset spawn---------------------------------




env.info("Mission Setup : is completed!")


--bc:addFunds(2,5000)

function checkAndDisableFriendlyZones()
  if zones.gallivare.wasBlue and zones.jokkmokk.wasBlue then
    zones.hidden1:MakeZoneBlue()
  end
end

timer.scheduleFunction(checkAndDisableFriendlyZones, {}, timer.getTime() + 5)


local missionCompleted = false
local checkMissionComplete = function(event, sender)
	if missionCompleted then return end
	local done = true
	for i, v in ipairs(bc:getZones()) do
		if not v.zone:lower():find("hidden") and v.side == 1 then
			done = false
			break
		end
	end

	if done then
		missionCompleted = true
		trigger.action.setUserFlag(180, true)
		trigger.action.outText(L10N:Get("MISSION_COMPLETE_MANUAL_RESTART"), 120)

		timer.scheduleFunction(function()
			trigger.action.outSoundForCoalition(2, "BH.ogg")
		end, {}, timer.getTime() + 5)

			local subMenu = missionCommands.addSubMenuForCoalition(2, L10N:Get("MENU_RESTART_AND_RESET"), nil)
			missionCommands.addCommandForCoalition(2, L10N:Get("COMMON_YES"), subMenu, function()
					Utils.saveTable(bc.saveFile, 'zonePersistance', {})
					if resetSaveFileAndFarp then
					resetSaveFileAndFarp()
					end
				trigger.action.outText(L10N:Get("MISSION_RESTARTING_NOW"), 120)
				timer.scheduleFunction(function()
					trigger.action.setUserFlag(181, true)
				end, {}, timer.getTime() + 5)
			end)
			missionCommands.addCommandForCoalition(2, L10N:Get("COMMON_NO"), subMenu, function()
		end)
	end
end

for i,v in ipairs(bc:getZones()) do
	v:registerTrigger('lost', checkMissionComplete, 'missioncompleted')
end

timer.scheduleFunction(function()
	checkMissionComplete(nil, nil)
end, {}, timer.getTime() +10)

local SHOP_PRICE_DEFAULTS = {
  smoke         = 20,
  flare         = 20,
  illum         = 100,
  dynamiccap    = 500,
  dynamicarco   = 1000,
  dynamictexaco = 1000,
  dynamiccas    = 1000,
  dynamicdecoy  = 300,
  dynamicsead   = 500,
  dynamicbomb   = 500,
  groundattack  = 1000,
  dynamicstatic = 500,
  cruisemsl     = 800,
  supplies2     = 200,
  supplies      = 1000,
  jtac          = 500,
  ["9lineam"]   = 0,
  ["9linefm"]   = 0,
  jam           = 500,
  armor         = 100,
  artillery     = 100,
  recon         = 50,
  airdef        = 150,
  capture       = 500,
  intel         = 150,
  zinf          = 500,
  zsam          = 2000,
  zhimars       = 2500,
  zlogc         = 2000,
  zwh50         = 500,
  zarm          = 1000,
  zpat          = 5000,
  gslot         = 3000,
  farphere      = 1000,
}

local SHOP_RANK_DEFAULTS = {
  jtac           = 2,
  dynamiccap     = 2,
  dynamiccas     = 5,
  dynamicbomb    = 4,
  dynamicsead    = 4,
  dynamicdecoy   = 1,
  dynamicstatic  = 4,
  groundattack   = 5,
  dynamicarco    = 3,
  dynamictexaco  = 3,
  farphere       = 4,
  capture        = 1,
  smoke          = 1,
  flare          = 1,
  illum          = 1,
  intel          = 5,
  supplies2      = 1,
  supplies       = 6,
  zinf           = 5,
  zarm           = 7,
  zsam           = 6,
  zhimars        = 8,
  zlogc          = 1,
  zwh50          = 2,
  gslot          = 9,
  zpat           = 8,
  armor          = 3,
  artillery      = 3,
  recon          = 3,
  airdef         = 3,
  ["9lineam"]    = 1,
  ["9linefm"]    = 1,
  cruisemsl      = 10,
  jam            = 4,
}

local function mergeDefaults(defaults, overrides)
  local out = {}
  for k, v in pairs(defaults) do out[k] = v end
  for k, v in pairs(overrides or {}) do out[k] = v end
  return out
end

ShopPrices = mergeDefaults(SHOP_PRICE_DEFAULTS, ShopPrices)
ShopRankRequirements = mergeDefaults(SHOP_RANK_DEFAULTS, ShopRankRequirements)

Group.getByName('jtacDrone1'):destroy()
Group.getByName('jtacDrone2'):destroy()
local jtacTargetMenu = nil
local jtacDrones = {JTAC:new({name = 'jtacDrone1'}),JTAC:new({name = 'jtacDrone2'})}
bc:registerShopItem('jtac',LTGet("SYRIA_SHOP_ITEM_JTAC_MQ9"),ShopPrices.jtac,function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,function(sender,params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		for _,v in ipairs(jtacQueue) do
			if v.tgtzone and v.tgtzone.zone == params.zone.zone then
				return LTFormat("SYRIA_SHOP_JTAC_ALREADY_ACTIVE", params.zone.zone)
			end
		end
		if #jtacQueue == 2 then
			local old = table.remove(jtacQueue,1)
			local gr  = Group.getByName(old.name)
			if gr then gr:destroy() end
		end
		local dr = jtacDrones[1]
		for i,v in ipairs(jtacDrones) do
			if not Utils.isGroupActive(Group.getByName(v.name)) then dr = v break end
		end
		dr:deployAtZone(params.zone)
		dr:showMenu()
		table.insert(jtacQueue,dr)
		trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_JTAC_REAPER_ACTIVE", params.zone.zone, #jtacQueue),15)
	else
		return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
end)
bc.shopItems['jtac'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	extraPredicate = function(zoneObj)
		for _, v in ipairs(jtacQueue) do
			if v.tgtzone and v.tgtzone.zone == zoneObj.zone then
				return false
			end
		end
		return true
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}


------------------------------------ START own 9 line jtac AM START ----------------------------------
jtacZones = {}
Group.getByName('JTAC9lineam'):destroy()
local jtacTargetMenu2 = nil
local droneAM = JTAC9line:new({name = 'JTAC9lineam'})
bc:registerShopItem('9lineam', LTGet("SYRIA_SHOP_ITEM_JTAC_9LINE_AM"), ShopPrices["9lineam"], function(sender)
    return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        droneAM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = 'JTAC9lineam'}
        trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_JTAC_REAPER_AM", params.zone.zone), 30)
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['9lineam'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}

  ------------------------------ END 9 line jtac AM END ----------------------------------
  ----------------------------- START 9 line jtac fm START ---------------------------

Group.getByName('JTAC9linefm'):destroy()
local jtacTargetMenu3 = nil
local droneFM = JTAC9linefmr:new({name = 'JTAC9linefm'})
bc:registerShopItem('9linefm', LTGet("SYRIA_SHOP_ITEM_JTAC_9LINE_FM"), ShopPrices["9linefm"], function(sender)
    return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        droneFM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = 'JTAC9linefm'}
        trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_JTAC_REAPER_FM", params.zone.zone), 30)
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['9linefm'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}


function CheckJtacStatus()
     if jtacZones == nil then
            return false
        end

    local jtacFound = false
    
    for zoneName, jtacInfo in pairs(jtacZones) do
        local jtacGroup = Group.getByName(jtacInfo.drone)
        if jtacGroup and Utils.isGroupActive(jtacGroup) then
            local zone = bc:getZoneByName(zoneName)
            if zone and (zone.side ~= 1 or not zone.active) then
                jtacGroup:destroy()
                jtacZones[zoneName] = nil
                jtacFound = true
            end
        else
            jtacZones[zoneName] = nil
        end
    end

    return jtacFound
end
  -------------------------- END 9 line jtac FM END ----------------------------------

local smokeTargetMenu = nil
bc:registerShopItem('smoke', LTGet("SYRIA_SHOP_ITEM_SMOKE_MARKERS"), ShopPrices.smoke, function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		bc:smokeTargets(params.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_TARGETS_RED_SMOKE", params.zone.zone), 15)
	else
		return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
end)
bc.shopItems['smoke'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}

local flareTargetMenu = nil
bc:registerShopItem('flare', LTGet("SYRIA_SHOP_ITEM_FLARE_MARKERS"), ShopPrices.flare, function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		bc:flareTargets(params.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_TARGETS_RED_FLARE", params.zone.zone), 15)
	else
		return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
end)
bc.shopItems['flare'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}

local illumTargetMenu = nil
bc:registerShopItem('illum', LTGet("SYRIA_SHOP_ITEM_ILLUMINATION"), ShopPrices.illum, function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		bc:illumTargets(params.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_TARGETS_ILLUMINATED", params.zone.zone), 15)
	else
		return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
end)
bc.shopItems['illum'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}

-----------------------------------------------DYNAMIC SHOP ------------------------------------------


bc:registerShopItem('dynamiccap', LTGet("SYRIA_SHOP_ITEM_CAP_FLIGHT"), ShopPrices.dynamiccap, function(sender)
    if capActive then
        return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "CAP")
    end
		if capParentMenu then
		return LTGet("SYRIA_SHOP_CHOOSE_SPAWN_ZONE")
	end
    buildCapMenu()
	trigger.action.outTextForCoalition(2, L10N:Get("SYRIA_SHOP_CAP_REQUESTED"), 10)
    return
end,
function (sender, params)
    if capActive then
        return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "CAP")
    end
    if params and params.zone then
        if params.zone.side ~= 2 or params.zone.suspended then
            return LTGet("SYRIA_SHOP_CAN_ONLY_SPAWN_FRIENDLY")
        end
        spawnCapAt(params.zone.zone, tonumber(params.heading) or 45, tonumber(params.leg) or 0)
        return
    end
    buildCapMenu()

	trigger.action.outTextForCoalition(2, L10N:Get("SYRIA_SHOP_CAP_REQUESTED"), 10)
    return
end)
bc.shopItems['dynamiccap'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	zoneMenuBuilder = function(bcRef, parentMenu, label, zoneObj, groupId, groupObj, itemInfo, track, rememberHandle)
		local function remember(handle)
			if rememberHandle then
				return rememberHandle(handle)
			end
			if handle then
				track[#track + 1] = handle
			end
			return handle
		end

		local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
		local T = L10N:ForGroup(groupId)
		for _, headingName in ipairs({ "Orbit", "Hot 360", "Hot 045", "Hot 090", "Hot 135", "Hot 180", "Hot 225", "Hot 270", "Hot 315" }) do
			if headingName == "Orbit" then
				remember(missionCommands.addCommandForGroup(groupId, localizedHeadingLabel(headingName, T), zoneMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
					zone = zoneObj,
					heading = 45,
					leg = 0,
				}, groupId, groupObj))
			else
				local headingVal = capHeadings[headingName]
				local headingMenu = remember(missionCommands.addSubMenuForGroup(groupId, localizedHeadingLabel(headingName, T), zoneMenu))
				for _, legName in ipairs({ "10 NM Leg", "20 NM Leg", "30 NM Leg", "40 NM Leg", "50 NM Leg" }) do
					local legVal = capLegs[legName]
					remember(missionCommands.addCommandForGroup(groupId, localizedLegLabel(legName, T), headingMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
						zone = zoneObj,
						heading = headingVal,
						leg = legVal,
					}, groupId, groupObj))
				end
			end
		end
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

bc:registerShopItem('dynamicarco', LTGet("SYRIA_SHOP_ITEM_TANKER_DROGUE"), ShopPrices.dynamicarco, function(sender)
    if ArcoActive then
        return LTFormat("SYRIA_SHOP_AIRCRAFT_STILL_AIRBORNE", "Arco")
    end
		if ArcoParentMenu then
		return LTGet("SYRIA_SHOP_CHOOSE_SPAWN_ZONE")
	end
    buildArcoMenu()
	trigger.action.outTextForCoalition(2, L10N:Get("SYRIA_SHOP_TANKER_DROGUE_UNLOCKED"), 20)
    return
end,
function (sender, params)
    if ArcoActive then
        return LTFormat("SYRIA_SHOP_AIRCRAFT_STILL_AIRBORNE", "Arco")
    end
    if params and params.zone then
        if params.zone.side ~= 2 then
            return LTGet("SYRIA_SHOP_CAN_ONLY_SPAWN_FRIENDLY")
        end
        spawnArcoAt(params.zone.zone, tonumber(params.heading) or 45, tonumber(params.leg) or 0)
        return
    end
    buildArcoMenu()

	trigger.action.outTextForCoalition(2, L10N:Get("SYRIA_SHOP_TANKER_DROGUE_UNLOCKED"), 20)
    return
end)
bc.shopItems['dynamicarco'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = true,
	sortPolicy = 'friendly_frontline',
	zoneMenuBuilder = function(bcRef, parentMenu, label, zoneObj, groupId, groupObj, itemInfo, track, rememberHandle)
		local function remember(handle)
			if rememberHandle then
				return rememberHandle(handle)
			end
			if handle then
				track[#track + 1] = handle
			end
			return handle
		end

		local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
		local T = L10N:ForGroup(groupId)
		for _, headingName in ipairs({ "Orbit", "Hot 360", "Hot 045", "Hot 090", "Hot 135", "Hot 180", "Hot 225", "Hot 270", "Hot 315" }) do
			if headingName == "Orbit" then
				remember(missionCommands.addCommandForGroup(groupId, localizedHeadingLabel(headingName, T), zoneMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
					zone = zoneObj,
					heading = 45,
					leg = 0,
				}, groupId, groupObj))
			else
				local headingVal = capHeadings[headingName]
				local headingMenu = remember(missionCommands.addSubMenuForGroup(groupId, localizedHeadingLabel(headingName, T), zoneMenu))
				for _, legName in ipairs({ "10 NM Leg", "20 NM Leg", "30 NM Leg", "40 NM Leg", "50 NM Leg" }) do
					local legVal = capLegs[legName]
					remember(missionCommands.addCommandForGroup(groupId, localizedLegLabel(legName, T), headingMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
						zone = zoneObj,
						heading = headingVal,
						leg = legVal,
					}, groupId, groupObj))
				end
			end
		end
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

bc:registerShopItem('dynamictexaco', LTGet("SYRIA_SHOP_ITEM_TANKER_BOOM"), ShopPrices.dynamictexaco, function(sender)
    if TexacoActive then
        return LTFormat("SYRIA_SHOP_AIRCRAFT_STILL_AIRBORNE", "Texaco")
    end
		if TexacoParentMenu then
		return LTGet("SYRIA_SHOP_CHOOSE_SPAWN_ZONE")
	end
    buildTexacoMenu()
	trigger.action.outTextForCoalition(2, L10N:Get("SYRIA_SHOP_TANKER_BOOM_UNLOCKED"), 20)
    return
end,
function (sender, params)
    if TexacoActive then
        return LTFormat("SYRIA_SHOP_AIRCRAFT_STILL_AIRBORNE", "Texaco")
    end
    if params and params.zone then
        if params.zone.side ~= 2 then
            return LTGet("SYRIA_SHOP_CAN_ONLY_SPAWN_FRIENDLY")
        end
        spawnTexacoAt(params.zone.zone, tonumber(params.heading) or 45, tonumber(params.leg) or 0)
        return
    end
    buildTexacoMenu()

	trigger.action.outTextForCoalition(2, L10N:Get("SYRIA_SHOP_TANKER_BOOM_UNLOCKED"), 20)
    return
end)
bc.shopItems['dynamictexaco'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = true,
	sortPolicy = 'friendly_frontline',
	zoneMenuBuilder = function(bcRef, parentMenu, label, zoneObj, groupId, groupObj, itemInfo, track, rememberHandle)
		local function remember(handle)
			if rememberHandle then
				return rememberHandle(handle)
			end
			if handle then
				track[#track + 1] = handle
			end
			return handle
		end

		local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
		local T = L10N:ForGroup(groupId)
		for _, headingName in ipairs({ "Orbit", "Hot 360", "Hot 045", "Hot 090", "Hot 135", "Hot 180", "Hot 225", "Hot 270", "Hot 315" }) do
			if headingName == "Orbit" then
				remember(missionCommands.addCommandForGroup(groupId, localizedHeadingLabel(headingName, T), zoneMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
					zone = zoneObj,
					heading = 45,
					leg = 0,
				}, groupId, groupObj))
			else
				local headingVal = capHeadings[headingName]
				local headingMenu = remember(missionCommands.addSubMenuForGroup(groupId, localizedHeadingLabel(headingName, T), zoneMenu))
				for _, legName in ipairs({ "10 NM Leg", "20 NM Leg", "30 NM Leg", "40 NM Leg", "50 NM Leg" }) do
					local legVal = capLegs[legName]
					remember(missionCommands.addCommandForGroup(groupId, localizedLegLabel(legName, T), headingMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
						zone = zoneObj,
						heading = headingVal,
						leg = legVal,
					}, groupId, groupObj))
				end
			end
		end
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

bc:registerShopItem('dynamiccas', LTGet("SYRIA_SHOP_ITEM_CAS_FLIGHT"), ShopPrices.dynamiccas,
function(sender)
    if casActive then return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "CAS") end
    return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if casActive then return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "CAS") end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return LTFormat("SYRIA_SHOP_NO_FRIENDLY_SPAWN", "CAS")
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnCasAt(closestBlue, params.zone.zone, offset)
        return
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['dynamiccas'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}

bc:registerShopItem('dynamicdecoy', LTGet("SYRIA_SHOP_ITEM_TALD_DECOY"), ShopPrices.dynamicdecoy,
function(sender)
    if decoyActive then
        return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "Decoy")
    end
    return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if decoyActive then
            return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "Decoy")
        end
        local minNM = 40
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return LTFormat("SYRIA_SHOP_NO_FRIENDLY_SPAWN", "Decoy")
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnDecoyAt(closestBlue, params.zone.zone, offset)
        return
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['dynamicdecoy'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}


bc:registerShopItem('dynamicsead', LTGet("SYRIA_SHOP_ITEM_SEAD_FLIGHT"), ShopPrices.dynamicsead,
function(sender)
    if seadActive then
        return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "SEAD")
    end
    return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if seadActive then
            return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "SEAD")
        end
        local minNM = 40
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return LTFormat("SYRIA_SHOP_NO_FRIENDLY_SPAWN", "SEAD")
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnSeadAt(closestBlue, params.zone.zone, offset)
        return
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['dynamicsead'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}

bc:registerShopItem('dynamicbomb', LTGet("SYRIA_SHOP_ITEM_BOMBER_FLIGHT"), ShopPrices.dynamicbomb,
function(sender)
    if bomberActive then
        return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "Bomb")
    end
    return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if bomberActive then
            return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "Bomb run")
        end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return LTFormat("SYRIA_SHOP_NO_FRIENDLY_SPAWN", "bomb run")
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnBomberAt(closestBlue, params.zone.zone, offset)
        return
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['dynamicbomb'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}

bc:registerShopItem('groundattack', LTGet("SYRIA_SHOP_ITEM_GROUND_ATTACK"), ShopPrices.groundattack,
function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended and not isCarrierZoneName(params.zone.zone) then
		return bc:launchPlayerGroundAttack(params.zone, params.allowFarp)
	end
	return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
end)
bc.shopItems['groundattack'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
	end,
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	zoneMenuBuilder = function(bcRef, parentMenu, label, zoneObj, groupId, groupObj, itemInfo, track, rememberHandle)
		local function remember(handle)
			if rememberHandle then
				return rememberHandle(handle)
			end
			if handle then
				track[#track + 1] = handle
			end
			return handle
		end

		local hasFriendlyDynamicFarp = false
		local farps = bcRef.dynamicFarpsBySide and bcRef.dynamicFarpsBySide[2] or nil
		if farps then
			for i = 1, #farps do
				local farpAb = AIRBASE:FindByName(farps[i].name)
				if farpAb and farpAb:GetCoalition() == 2 then
					hasFriendlyDynamicFarp = true
					break
				end
			end
		end
		if hasFriendlyDynamicFarp then
			local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
			local T = L10N:ForGroup(groupId)
			remember(missionCommands.addCommandForGroup(groupId, T:Get("SYRIA_SHOP_DEPLOY_FROM_FARP"), zoneMenu, function() end))
			remember(missionCommands.addCommandForGroup(groupId, T:Get("COMMON_YES"), zoneMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
				zone = zoneObj,
				allowFarp = true,
			}, groupId, groupObj))
			remember(missionCommands.addCommandForGroup(groupId, T:Get("COMMON_NO"), zoneMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
				zone = zoneObj,
				allowFarp = false,
			}, groupId, groupObj))
			return
		end

		remember(missionCommands.addCommandForGroup(groupId, label, parentMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
			zone = zoneObj,
		}, groupId, groupObj))
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}

---------------------------------------------END DYNAMIC SHOP ------------------------------------------
tanksMenu = nil
bc:registerShopItem('armor', LTGet("SYRIA_SHOP_ITEM_DEPLOY_ARMOR"), ShopPrices.armor, function(sender)
    return LTGet("SYRIA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 2 and not params.zone.suspended then
        
        local zn = CustomZone:getByName(params.zone.zone)
        zn:spawnGroup('ca-tanks')
        trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_FRIENDLY_ARMOR_DEPLOYED", params.zone.zone), 15)
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_DEPLOY_FRIENDLY")
    end
end)
bc.shopItems['armor'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}
Group.getByName('ca-arty'):destroy()
artyMenu = nil
bc:registerShopItem('artillery', LTGet("SYRIA_SHOP_ITEM_DEPLOY_ARTILLERY"), ShopPrices.artillery, function(sender)
    return LTGet("SYRIA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 2 and not params.zone.suspended then
        
        local zn = CustomZone:getByName(params.zone.zone)
        zn:spawnGroup('ca-arty')
        trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_FRIENDLY_ARTY_DEPLOYED", params.zone.zone), 15)
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_DEPLOY_FRIENDLY")
    end
end)
bc.shopItems['artillery'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}
Group.getByName('ca-recon'):destroy()
reconMenu = nil
bc:registerShopItem('recon', LTGet("SYRIA_SHOP_ITEM_DEPLOY_RECON"), ShopPrices.recon, function(sender)
    return LTGet("SYRIA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 2 then
        
        local zn = CustomZone:getByName(params.zone.zone)
        zn:spawnGroup('ca-recon')
        trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_FRIENDLY_RECON_DEPLOYED", params.zone.zone), 15)
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_DEPLOY_FRIENDLY")
    end
end)
bc.shopItems['recon'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}
Group.getByName('ca-airdef'):destroy()
airdefMenu = nil
bc:registerShopItem('airdef', LTGet("SYRIA_SHOP_ITEM_DEPLOY_AIRDEF"), ShopPrices.airdef, function(sender)
    return LTGet("SYRIA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 2 then
        
        local zn = CustomZone:getByName(params.zone.zone)
        zn:spawnGroup('ca-airdef')
        trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_FRIENDLY_AIRDEF_DEPLOYED", params.zone.zone), 15)
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_DEPLOY_FRIENDLY")
    end
end)
bc.shopItems['airdef'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

----------------------- end of decoy menu -----------------------

local upgradeMenu = nil
local function clearFriendlySupplyMenu()
    if upgradeMenu then
        missionCommands.removeItemForCoalition(2, upgradeMenu)
        upgradeMenu = nil
    end
end

bc:registerShopItem('supplies2', LTGet("SYRIA_SHOP_ITEM_RESUPPLY_ZONE"), ShopPrices.supplies2, function(sender)
    if not AllowScriptedSupplies and NoAIBlueSupplies == true then
        return LTGet("SYRIA_SHOP_BLUE_AI_SUPPLIES_DISABLED")
    end
    return LTGet("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender, params)
    if not AllowScriptedSupplies then
        if NoAIBlueSupplies == true then
            return LTGet("SYRIA_SHOP_BLUE_AI_SUPPLIES_DISABLED")
        end
        if params.zone then
            return bc:requestFriendlySupplyMission(params.zone, params)
        end
        return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_FRIENDLY")
    elseif params.zone and params.zone.side == 2 and not params.zone.suspended then
        if not params.zone:upgrade() then
            return LTGet("SYRIA_SHOP_ZONE_NO_RESUPPLY")
        end
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_FRIENDLY")
    end
end)
bc.shopItems['supplies2'].groupZoneSelector = {
	targetzoneside = 2,
	showUpgradeStatus = true,
	includeSuspended = false,
	extraPredicate = function(zoneObj)
		return zoneObj.active and zoneObj.side == 2 and not zoneObj.suspended and zoneObj._needsSupplyForMenu == true
	end,
	zoneMenuBuilder = function(bcRef, parentMenu, label, zoneObj, groupId, groupObj, itemInfo, track, rememberHandle)
		local function remember(handle)
			if rememberHandle then
				return rememberHandle(handle)
			end
			if handle then
				track[#track + 1] = handle
			end
			return handle
		end

		if not AllowScriptedSupplies then
			local bestCommander = select(1, findNearestAvailableSupplyCommander(zoneObj))
			local canUseFarp = bestCommander and (bestCommander.type == 'surface' or bestCommander.unitCategory == Unit.Category.HELICOPTER)
			local hasFriendlyDynamicFarp = false
			local hasNearbyFriendlyDynamicFarp = false
			local farps = bcRef.dynamicFarpsBySide and bcRef.dynamicFarpsBySide[2] or nil
			if farps then
				for i = 1, #farps do
					local farpAb = AIRBASE:FindByName(farps[i].name)
					if farpAb and farpAb:GetCoalition() == 2 then
						hasFriendlyDynamicFarp = true
						local distMeters = bcRef:_getDynamicFarpZoneDistance(farps[i], zoneObj.zone)
						if distMeters and distMeters <= (30 * 1852) then
							hasNearbyFriendlyDynamicFarp = true
						end
					end
				end
			end
			local hasDynamicShopSupplyFarp = bcRef:_hasDynamicShopSupplyFarpOption(zoneObj)
			local hasFallbackHeloFarp = (not bestCommander) and hasNearbyFriendlyDynamicFarp and (findNearestAvailableSupplyHeliCommander(zoneObj) ~= nil)
			if (canUseFarp and hasFriendlyDynamicFarp) or hasFallbackHeloFarp or hasDynamicShopSupplyFarp then
				local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
				local T = L10N:ForGroup(groupId)
				remember(missionCommands.addCommandForGroup(groupId, T:Get("SYRIA_SHOP_DEPLOY_FROM_FARP"), zoneMenu, function() end))
				remember(missionCommands.addCommandForGroup(groupId, T:Get("COMMON_YES"), zoneMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
					zone = zoneObj,
					allowFarp = true,
				}, groupId, groupObj))
				remember(missionCommands.addCommandForGroup(groupId, T:Get("COMMON_NO"), zoneMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
					zone = zoneObj,
					allowFarp = false,
				}, groupId, groupObj))
				return
			end
		end

		remember(missionCommands.addCommandForGroup(groupId, label, parentMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
			zone = zoneObj,
		}, groupId, groupObj))
	end,
	sortPolicy = 'friendly_frontline',
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

if AllowScriptedSupplies then
local fullyUpgradeMenu=nil
bc:registerShopItem('supplies',LTGet("SYRIA_SHOP_ITEM_FULLY_UPGRADE_ZONE"),ShopPrices.supplies,
function(sender)
    return LTGet("SYRIA_SHOP_CHOOSE_ZONE_FULLY_UPGRADE")
end,
function(sender,params)
    if params.zone and params.zone.side==2 and not params.zone.suspended then
        local zn=params.zone
        if not zn:UpgradeUntilComplete(function()
            trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_ZONE_FULLY_UPGRADED", params.zone.zone),15)
        end) then
            trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_ZONE_FULLY_UPGRADED", params.zone.zone),15)
        end
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_FRIENDLY")
    end
end)
bc.shopItems['supplies'].groupZoneSelector = {
	targetzoneside = 2,
	showUpgradeStatus = true,
	includeSuspended = false,
	extraPredicate = function(zoneObj)
		return zoneObj.active and zoneObj.side == 2 and not zoneObj.suspended and zoneObj._needsSupplyForMenu == true
	end,
	sortPolicy = 'friendly_frontline',
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}
end
-- new menu
local supplyMenu=nil
bc:registerShopItem('capture',LTGet("SYRIA_SHOP_ITEM_CAPTURE_NEUTRAL"),ShopPrices.capture,
function(sender)
	if NoAIBlueSupplies == true then 
		return LTGet("SYRIA_SHOP_BLUE_AI_SUPPLIES_DISABLED")
	end
	return LTGet("SYRIA_SHOP_CHOOSE_NEUTRAL_ZONE")
end,
function(sender,params)
    if not params.zone or params.zone.side~=0 then
        return LTGet("SYRIA_SHOP_ZONE_NOT_NEUTRAL")
    end
    local chosenZone=bc:getZoneByName(params.zone.zone)
    return bc:requestCaptureMission(chosenZone, params)
end)
bc.shopItems['capture'].groupZoneSelector = {
	targetzoneside = 0,
	includeSuspended = true,
	extraPredicate = function(zoneObj)
		return zoneObj.active and (not zoneObj.NeutralAtStart or zoneObj.firstCaptureByRed)
	end,
	zoneMenuBuilder = function(bcRef, parentMenu, label, zoneObj, groupId, groupObj, itemInfo, track, rememberHandle)
		local function remember(handle)
			if rememberHandle then
				return rememberHandle(handle)
			end
			if handle then
				track[#track + 1] = handle
			end
			return handle
		end

		local bestCommander = select(1, findNearestAvailableSupplyCommander(zoneObj))
		local canUseFarp = bestCommander and (bestCommander.type == 'surface' or bestCommander.unitCategory == Unit.Category.HELICOPTER)
		local hasFriendlyDynamicFarp = false
		local hasNearbyFriendlyDynamicFarp = false
		local farps = bcRef.dynamicFarpsBySide and bcRef.dynamicFarpsBySide[2] or nil
		if farps then
			for i = 1, #farps do
				local farpAb = AIRBASE:FindByName(farps[i].name)
				if farpAb and farpAb:GetCoalition() == 2 then
					hasFriendlyDynamicFarp = true
					local distMeters = bcRef:_getDynamicFarpZoneDistance(farps[i], zoneObj.zone)
					if distMeters and distMeters <= (30 * 1852) then
						hasNearbyFriendlyDynamicFarp = true
					end
				end
			end
		end
		local hasDynamicShopSupplyFarp = bcRef:_hasDynamicShopSupplyFarpOption(zoneObj)
		local hasFallbackHeloFarp = (not bestCommander) and hasNearbyFriendlyDynamicFarp and (findNearestAvailableSupplyHeliCommander(zoneObj) ~= nil)
		if (canUseFarp and hasFriendlyDynamicFarp) or hasFallbackHeloFarp or hasDynamicShopSupplyFarp then
			local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
			local T = L10N:ForGroup(groupId)
			remember(missionCommands.addCommandForGroup(groupId, T:Get("SYRIA_SHOP_DEPLOY_FROM_FARP"), zoneMenu, function() end))
			remember(missionCommands.addCommandForGroup(groupId, T:Get("COMMON_YES"), zoneMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
				zone = zoneObj,
				allowFarp = true,
			}, groupId, groupObj))
			remember(missionCommands.addCommandForGroup(groupId, T:Get("COMMON_NO"), zoneMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
				zone = zoneObj,
				allowFarp = false,
			}, groupId, groupObj))
			return
		end

		remember(missionCommands.addCommandForGroup(groupId, label, parentMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
			zone = zoneObj,
		}, groupId, groupObj))
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_ELIGIBLE_NEUTRAL_ZONES"),
}

local intelMenu=nil
bc:registerShopItem('intel',LTGet("SYRIA_SHOP_ITEM_INTEL_ENEMY"),ShopPrices.intel,function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		intelActiveZones[params.zone.zone] = true
		startZoneIntel(params.zone.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_GATHERING_INTEL", params.zone.zone), 10)
	else
		return LTGet("SYRIA_SHOP_MUST_PICK_ENEMY_ZONE")
	end
end)
bc.shopItems['intel'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}

------------------------------------------- Zone upgrades --------------------------------------------
-- red Shop
local RED_ZONE_UPGRADE_ID = "redzoneupgrade"
local RED_ZONE_UPGRADE_COST = 5000

bc:registerShopItem(RED_ZONE_UPGRADE_ID, LTGet("SYRIA_SHOP_ITEM_RED_ZONE_UPGRADE"), RED_ZONE_UPGRADE_COST, function(sender)
	return bc:redZoneUpgradeAction()
end)

local RED_MASS_ATTACK_ID = "redmassattack"
local RED_MASS_ATTACK_COST = 6000

local function redMassAttackAction()
	if not bc.triggerRedMassAttack then
		return LTGet("SYRIA_SHOP_MASS_ATTACK_UNAVAILABLE")
	end
	return bc:triggerRedMassAttack()
end

bc:registerShopItem(RED_MASS_ATTACK_ID, LTGet("SYRIA_SHOP_ITEM_RED_MASS_ATTACK"), RED_MASS_ATTACK_COST, redMassAttackAction)
-- end red shop

local infMenu=nil
bc:registerShopItem('zinf',LTGet("SYRIA_SHOP_ITEM_UPGRADE_INFANTRY"),ShopPrices.zinf,function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('blueInfantry')
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock then
		trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED", L10N:Get("SYRIA_SHOP_LABEL_INFANTRY"), params.zone.zone, tostring(ShopPrices.zinf)),10)
		else
		trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED_EXTRA", L10N:Get("SYRIA_SHOP_LABEL_INFANTRY"), params.zone.zone, tostring(ShopPrices.zinf)),30)
		end
	else
		return LTGet("SYRIA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zinf'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_ELIGIBLE_ZONE"),
}
local samLabel = (Era == 'Coldwar') and LTGet("SYRIA_SHOP_ITEM_UPGRADE_HAWK")
                                   or  LTGet("SYRIA_SHOP_ITEM_UPGRADE_NASAMS")
local samMenu=nil
bc:registerShopItem('zsam',samLabel,ShopPrices.zsam,function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot((Era == 'Coldwar') and 'blueHAWK-Coldwar' or 'bluePD1')
		bc:refreshZoneLabel(params.zone.zone)
		local sys = (Era == 'Coldwar') and 'Hawk' or 'Nasams'
        if bc.globalExtraUnlock then
            trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED", sys, params.zone.zone, tostring(ShopPrices.zsam)),10)
        else
            trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED_EXTRA", sys, params.zone.zone, tostring(ShopPrices.zsam)),30)
        end
	else
		return LTGet("SYRIA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zsam'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_ELIGIBLE_ZONE"),
}

local himarsMenu=nil
bc:registerShopItem('zhimars',LTGet("SYRIA_SHOP_ITEM_UPGRADE_HIMARS"),ShopPrices.zhimars,function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('HiMars')
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock then
			trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED", "HIMARS", params.zone.zone, tostring(ShopPrices.zhimars)),10)
		else
			trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED_EXTRA", "HIMARS", params.zone.zone, tostring(ShopPrices.zhimars)),30)
		end
	else
		return LTGet("SYRIA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zhimars'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_ELIGIBLE_ZONE"),
}

local logiMenu=nil
bc:registerShopItem('zlogc',LTGet("SYRIA_SHOP_ITEM_LOGISTIC_CENTER"),ShopPrices.zlogc,function(sender)
	if logiMenu then
		return LTGet("SYRIA_SHOP_ALREADY_CHOOSING_ZONE")
	end
	local allow = bc:buildLogisticAllowTable()
	if not next(allow) then
		return LTGet("SYRIA_SHOP_NO_ELIGIBLE_AIRBASE_ZONES")
	end
	local pickZone=function(zName)
		if not logiMenu then return end
		local zoneObj = bc:getZoneByName(zName)
		local result = bc:applyLogisticCenterUpgrade(zoneObj)
		if result == true then
			missionCommands.removeItemForCoalition(2,logiMenu)
			logiMenu=nil
		else
			if type(result) == 'string' then
				trigger.action.outTextForCoalition(2,result,10)
			end
			return result
		end
	end
	logiMenu = bc:showTargetZoneMenu(2,L10N:Get("SYRIA_SHOP_SELECT_LOGISTIC_CENTER"),pickZone,2,nil,allow)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SHOP_SELECT_FULLY_UPGRADED_AIRBASE"),15)
end,
function(sender,params)
	if params.zone then
		return bc:applyLogisticCenterUpgrade(params.zone)
	end
	return LTGet("SYRIA_SHOP_MUST_PICK_FRIENDLY_ZONE")
end)

local warehouseMenu=nil
bc:registerShopItem('zwh50',LTGet("SYRIA_SHOP_ITEM_WAREHOUSE_50"),ShopPrices.zwh50,function(sender)
	if not WarehouseLogistics then
		return LTGet("WAREHOUSE_LOGISTICS_DISABLED")
	end
	return LTGet("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone then
		return bc:applyWarehouseResupply(params.zone)
	end
	return LTGet("SYRIA_SHOP_MUST_PICK_FRIENDLY_ZONE")
end)
bc.shopItems['zwh50'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	candidatesBuilder = function()
		return bc:buildWarehouseResupplyCandidates()
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_ELIGIBLE_AIRBASE_ZONES"),
}

bc.shopItems['smoke'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['smoke'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['flare'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['flare'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['illum'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['illum'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['dynamiccap'].groupZoneSelector.candidateBucket = 'blue_visible'
bc.shopItems['dynamiccap'].groupZoneSelector.includeSuspended = true
bc.shopItems['dynamiccap'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc.shopItems['dynamicarco'].groupZoneSelector.candidateBucket = 'blue_visible'
bc.shopItems['dynamicarco'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc.shopItems['dynamictexaco'].groupZoneSelector.candidateBucket = 'blue_visible'
bc.shopItems['dynamictexaco'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc.shopItems['dynamiccas'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['dynamiccas'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['dynamicdecoy'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['dynamicdecoy'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['dynamicsead'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['dynamicsead'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['dynamicbomb'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['dynamicbomb'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['groundattack'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['groundattack'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['supplies2'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['supplies2'].groupZoneSelector.refreshTags = { 'friendly_targets' }
if bc.shopItems['supplies'] and bc.shopItems['supplies'].groupZoneSelector then
	bc.shopItems['supplies'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
	bc.shopItems['supplies'].groupZoneSelector.refreshTags = { 'friendly_targets' }
end
bc.shopItems['jtac'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['jtac'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['9lineam'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['9lineam'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['9linefm'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['9linefm'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['armor'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['armor'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc.shopItems['artillery'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['artillery'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc.shopItems['recon'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['recon'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc.shopItems['airdef'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['airdef'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc.shopItems['zinf'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zinf'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc.shopItems['zsam'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zsam'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc.shopItems['zhimars'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zhimars'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc.shopItems['capture'].groupZoneSelector.candidateBucket = 'neutral_capture_targets'
bc.shopItems['capture'].groupZoneSelector.refreshTags = { 'neutral_capture_targets' }
bc.shopItems['intel'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['intel'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['zwh50'].groupZoneSelector.candidateBucket = 'warehouse_targets'
bc.shopItems['zwh50'].groupZoneSelector.refreshTags = { 'warehouse_targets' }

local armMenu=nil
bc:registerShopItem('zarm',LTGet("SYRIA_SHOP_ITEM_UPGRADE_ARMOR"),ShopPrices.zarm,function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		local slotID = (Era == 'Coldwar') and 'blueArmor-Coldwar' or 'blueArmor'
		params.zone:addExtraSlot(slotID)
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock then
			trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED", L10N:Get("SYRIA_SHOP_LABEL_ARMOR"), params.zone.zone, tostring(ShopPrices.zarm)),10)
		else
			trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED_EXTRA_LINE", L10N:Get("SYRIA_SHOP_LABEL_ARMOR"), params.zone.zone, tostring(ShopPrices.zarm)),30)
		end
	else
		return LTGet("SYRIA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zarm'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_ELIGIBLE_ZONE"),
}
bc.shopItems['zarm'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zarm'].groupZoneSelector.refreshTags = { 'friendly_targets' }

bc:registerShopItem('gslot',LTGet("SYRIA_SHOP_ITEM_EXTRA_SLOT"),ShopPrices.gslot,function(sender)
    if bc.globalExtraUnlock then
        return LTGet("SYRIA_SHOP_ALREADY_UNLOCKED")
    end
    bc.globalExtraUnlock = true
    for _,z in pairs(bc:getZones()) do

    end
    trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SHOP_ALL_ZONES_SECOND_UPGRADE"),15)
	bc:removeShopItem(2, 'gslot')
	return nil
end)

Group.getByName('bluePATRIOT'):destroy()
local patMenu=nil
bc:registerShopItem('zpat',LTGet("SYRIA_SHOP_ITEM_UPGRADE_PATRIOT"),ShopPrices.zpat,function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('bluePATRIOT')
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock then
		trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED", "Patriot", params.zone.zone, tostring(ShopPrices.zpat)),10)
		else
		trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED_EXTRA", "Patriot", params.zone.zone, tostring(ShopPrices.zpat)),30)
		end
	else
		return LTGet("SYRIA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zpat'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_ELIGIBLE_ZONE"),
}
bc.shopItems['zpat'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zpat'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc:registerShopItem('farphere',LTGet("SYRIA_SHOP_ITEM_DEPLOY_FARP"),ShopPrices.farphere,function(sender)
        return LTGet("SYRIA_SHOP_FARP_MARKER_HELP")
end,function(_, params)
        return bc:processMapFarpPurchase(params)
end)
------------------------------------------- End of Zone upgrades ----------------------------------------

ShopPrices = ShopPrices or {
	smoke         = 20,   -- Smoke markers
	flare         = 20,   -- Flare markers
	illum         = 100,  -- Illumination bomb
	dynamiccap    = 500,  -- Dynamic CAP
	dynamicarco   = 1000,  -- Dynamic Tanker (Drogue)
	dynamictexaco = 1000,  -- Dynamic Tanker (Boom)
	dynamiccas    = 1000, -- Dynamic CAS
	dynamicdecoy  = 300,  -- Dynamic Decoy
	dynamicsead   = 500,  -- Dynamic SEAD
	dynamicbomb   = 500,  -- Dynamic Bomb run
	dynamicstatic = 500,  -- Dynamic building Strike
	cruisemsl     = 800,  -- Cruise Missile Strike
	supplies2     = 200,  -- Resupply friendly Zone
	supplies      = 1000, -- Fully Upgrade Friendly Zone
	jtac          = 500,  -- MQ-9 Reaper JTAC mission
	["9lineam"]   = 0,    -- Jtac 9line AM
	["9linefm"]   = 0,    -- Jtac 9line FM
	jam           = 500,  -- Jam radars at zone
	armor         = 100,  -- Deploy armor (for combined arms)
	artillery     = 100,  -- Deploy artillery (for combined arms)
	recon         = 50,   -- Deploy recon group (for combined arms)
	airdef        = 150,  -- Deploy air defence (for combined arms)
	capture       = 500,  -- Emergency capture zone
	intel         = 150,  -- Intel on enemy zone
	zinf          = 500,  -- Upgrade zone with infantry
	zsam          = 2000, -- Upgrade zone with Hawk/Nasams
	zhimars       = 2500, -- Upgrade zone with HIMARS
	zlogc         = 2000, -- Upgrade zone to logistic center
	zwh50         = 500,  -- Resupply warehouse with 50
	zarm          = 1000, -- Upgrade zone with armor
	zpat          = 5000, -- Upgrade zone with Patriot
	gslot         = 3000, -- Unlock extra upgrade slot
	farphere      = 1000, -- Deploy FARP
}

ShopRankRequirements = ShopRankRequirements or {
	jtac           = 2,  -- MQ-9 Reaper JTAC mission
	dynamiccap     = 2,  -- Dynamic CAP
	dynamiccas     = 5,  -- Dynamic CAS
	dynamicbomb    = 4,  -- Dynamic Bomb run
	dynamicsead    = 4,  -- Dynamic SEAD
	dynamicdecoy   = 1,  -- Dynamic Decoy
	dynamicstatic  = 4,  -- Dynamic building Strike
	dynamicarco    = 3,  -- Dynamic Tanker (Drogue)
	dynamictexaco  = 3,  -- Dynamic Tanker (Boom)
	farphere       = 4,  -- Deploy FARP
	capture        = 1,  -- Emergency capture zone
	smoke          = 1,  -- Smoke markers
	flare          = 1,  -- Flare markers
	illum          = 1,  -- Illumination bomb
	intel          = 5,  -- Intel on enemy zone
	supplies2      = 1,  -- Resupply friendly Zone
	supplies       = 6,  -- Fully Upgrade Friendly Zone
	zinf           = 5,  -- Upgrade zone with infantry
	zarm           = 7,  -- Upgrade zone with armor
	zsam           = 6,  -- Upgrade zone with Hawk/Nasams
	zhimars        = 8,  -- Upgrade zone with HIMARS
	zlogc          = 1,  -- Upgrade zone to logistic center
	zwh50          = 2,  -- Resupply warehouse with 50
	gslot          = 9,  -- Unlock extra upgrade slot
	zpat           = 8,  -- Upgrade zone with Patriot
	armor          = 3,  -- Deploy armor (for combined arms)
	artillery      = 3,  -- Deploy artillery (for combined arms)
	recon          = 3,  -- Deploy recon group (for combined arms)
	airdef         = 3,  -- Deploy air defence (for combined arms)
	["9lineam"]    = 1,  -- Jtac 9line AM
	["9linefm"]    = 1,  -- Jtac 9line FM
	cruisemsl      = 10, -- Cruise Missile Strike
	jam            = 4,  -- Jam radars at zone
}

-- first value below is how much in stock, the second number value is the ranking in the shop menu list, the third is the new ranking system.

bc:addShopItem(1, 'redzoneupgrade', -1, 1) -- red AI zone upgrade
bc:addShopItem(1, 'redmassattack', -1, 1) -- red AI mass airbase attack

ShopCategoryLabels = ShopCategoryLabels or {}
local ShopCats = ShopCategoryLabels

ShopCats.AIAttack = ShopCats.AIAttack or LTGet("SYRIA_SHOP_CAT_AI_ATTACK")
ShopCats.ZoneUpgrades = ShopCats.ZoneUpgrades or LTGet("SYRIA_SHOP_CAT_ZONE_UPGRADES")
ShopCats.JTACIntel = ShopCats.JTACIntel or LTGet("SYRIA_SHOP_CAT_JTAC_INTEL")
ShopCats.MarkingTools = ShopCats.MarkingTools or LTGet("SYRIA_SHOP_CAT_MARKING_TOOLS")
ShopCats.CombinedArms = ShopCats.CombinedArms or LTGet("SYRIA_SHOP_CAT_COMBINED_ARMS")
ShopCats.LogisticsStrategic = ShopCats.LogisticsStrategic or LTGet("SYRIA_SHOP_CAT_LOGISTICS")
ShopCats.OtherSupport = ShopCats.OtherSupport or LTGet("SYRIA_SHOP_CAT_OTHER_SUPPORT")

ShopCats.Order = ShopCats.Order or {
    ShopCats.AIAttack,
    ShopCats.ZoneUpgrades,
    ShopCats.JTACIntel,
    ShopCats.MarkingTools,
    ShopCats.CombinedArms,
    ShopCats.LogisticsStrategic,
    ShopCats.OtherSupport,
}

-- AI Attack
bc:addShopItem(2, 'dynamiccap', -1, 1, ShopRankRequirements.dynamiccap, ShopCats.AIAttack) -- CAP Flight
bc:addShopItem(2, 'dynamiccas', -1, 2, ShopRankRequirements.dynamiccas, ShopCats.AIAttack) -- CAS Flight
bc:addShopItem(2, 'dynamicbomb', -1, 3, ShopRankRequirements.dynamicbomb, ShopCats.AIAttack) -- Bomber Flight
bc:addShopItem(2, 'dynamicsead', -1, 4, ShopRankRequirements.dynamicsead, ShopCats.AIAttack) -- SEAD Flight
bc:addShopItem(2, 'dynamicdecoy', -1, 5, ShopRankRequirements.dynamicdecoy, ShopCats.AIAttack) -- TALD DECOY Flight
if UseStatics == true then
    bc:addShopItem(2, 'dynamicstatic', -1, 6, ShopRankRequirements.dynamicstatic, ShopCats.AIAttack) -- Static structure Flight
end
bc:addShopItem(2, 'cruisemsl', 12, 7, ShopRankRequirements.cruisemsl, ShopCats.AIAttack) -- Cruise missiles
bc:addShopItem(2, 'groundattack', -1, 8, ShopRankRequirements.groundattack, ShopCats.AIAttack) -- Ground attack convoy

-- Zone Upgrades
bc:addShopItem(2, 'zinf', -1, 1, ShopRankRequirements.zinf, ShopCats.ZoneUpgrades) -- add infantry to a zone
bc:addShopItem(2, 'zarm', -1, 2, ShopRankRequirements.zarm, ShopCats.ZoneUpgrades) -- add armour group to a zone
bc:addShopItem(2, 'zsam', -1, 3, ShopRankRequirements.zsam, ShopCats.ZoneUpgrades) -- add Nasams to a zone
bc:addShopItem(2, 'zhimars', -1, 4, ShopRankRequirements.zhimars, ShopCats.ZoneUpgrades) -- add HIMARS to a zone
bc:addShopItem(2, 'gslot', 1, 5, ShopRankRequirements.gslot, ShopCats.ZoneUpgrades) -- add another slot for upgrade
if Era == 'Modern' then
    bc:addShopItem(2, 'zpat', -1, 6, ShopRankRequirements.zpat, ShopCats.ZoneUpgrades) -- Patriot system.
end

-- JTAC & Intel
bc:addShopItem(2, 'jtac', -1, 1, ShopRankRequirements.jtac, ShopCats.JTACIntel) -- MQ-9 Reaper JTAC mission
bc:addShopItem(2, 'smoke', -1, 2, ShopRankRequirements.smoke, ShopCats.JTACIntel) -- smoke on target
bc:addShopItem(2, 'flare', -1, 3, ShopRankRequirements.flare, ShopCats.JTACIntel) -- flare on target
bc:addShopItem(2, 'illum', -1, 4, ShopRankRequirements.illum, ShopCats.JTACIntel) -- illumination bomb
bc:addShopItem(2, 'intel', -1, 5, ShopRankRequirements.intel, ShopCats.JTACIntel) -- Intel
bc:addShopItem(2, '9lineam', -1, 6, ShopRankRequirements['9lineam'], ShopCats.JTACIntel) -- free jtac
bc:addShopItem(2, '9linefm', -1, 7, ShopRankRequirements['9linefm'], ShopCats.JTACIntel) -- free jtac

-- Combined Arms
bc:addShopItem(2, 'armor', -1, 1, ShopRankRequirements.armor, ShopCats.CombinedArms) -- combined arms
bc:addShopItem(2, 'artillery', -1, 2, ShopRankRequirements.artillery, ShopCats.CombinedArms) -- combined arms
bc:addShopItem(2, 'recon', -1, 3, ShopRankRequirements.recon, ShopCats.CombinedArms) -- combined arms
bc:addShopItem(2, 'airdef', -1, 4, ShopRankRequirements.airdef, ShopCats.CombinedArms) -- combined arms

-- Logistics & Strategic
bc:addShopItem(2, 'capture', -1, 1, ShopRankRequirements.capture, ShopCats.LogisticsStrategic) -- emergency capture
bc:addShopItem(2, 'supplies2', -1, 2, ShopRankRequirements.supplies2, ShopCats.LogisticsStrategic) -- upgrade friendly zone
if AllowScriptedSupplies then
    bc:addShopItem(2, 'supplies', -1, 3, ShopRankRequirements.supplies, ShopCats.LogisticsStrategic) -- fully upgrade friendly zone
end
if WarehouseLogistics then
    bc:addShopItem(2, 'zlogc', -1, 4, ShopRankRequirements.zlogc, ShopCats.LogisticsStrategic) -- upgrade zone to logistic center
    bc:addShopItem(2, 'zwh50', -1, 5, ShopRankRequirements.zwh50, ShopCats.LogisticsStrategic) -- resupply warehouse with 50
end

-- Other Support
bc:addShopItem(2, 'dynamicarco', 1, 1, ShopRankRequirements.dynamicarco, ShopCats.OtherSupport) -- Navy tanker
bc:addShopItem(2, 'dynamictexaco', 1, 2, ShopRankRequirements.dynamictexaco, ShopCats.OtherSupport) -- Airforce tanker
bc:addShopItem(2, 'farphere', -1, 3, ShopRankRequirements.farphere, ShopCats.OtherSupport) -- deploy FARP
-----------------------------------------------
EnemyTerritoryOverlayColor = {2, 0, 0}
TerritoryOverlayOuterDrawPushMeters = 500000
EnemyTerritoryOverlayFillAlpha = 0.14

lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

bc:loadFromDisk() --will load and overwrite default zone levels, sides, funds and available shop items


bc:init()
budgetAI = BudgetCommander:new({ battleCommander = bc, side=1, decissionFrequency=20*60, decissionVariance=10*60, skipChance = 10})
budgetAI:init()
RewardContribution = RewardContribution or {infantry = 10, ground = 10, sam = 30, airplane = 50, ship = 200, helicopter=50, crate=100, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, structure = 100}
bc:startRewardPlayerContribution(15,RewardContribution)
buildTemplateCache()
bc:buildZoneDistanceCache()
buildSubZoneRoadCache()
bc:buildConnectionMap()
DynamicConvoy.InitTargetTails(15)
DynamicConvoy.InitRoadPathCacheFromCommanders(GroupCommanders)
PrecomputeLandingSpots()
BuildAirbaseParkingClusterCache()
Frontline.BuildFromZones(bc.indexedZones)
Frontline.ReindexZoneCalcs()
bc:buildCapSpawnBuckets()
local HuntNumber = SplashDamage and math.random(8,15) or math.random(6,15)
bc:initHunter(HuntNumber)
startWarehousePersistence()
SCHEDULER:New(nil, function() bc:_buildHunterBaseList() end, {}, 1)

SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 5)
SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 6)

AWACS_CFG = {
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=200 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=60 }   -- blue
}

GlobalSettings.autoSuspendNmBlue = 100   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 140   		-- suspend red zones deeper than this nm
evc = EventCommander:new({ decissionFrequency=15*60, decissionVariance=10*60, skipChance = 15})
evc:init()
mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})

DynamicHybridConfig = DynamicHybridConfig or {
	enabled = true,
	runOnce = true,
	airMaxNm = 120,
	heloCasMaxNm = 40,
	minGroundAttackNm = 10,
	surfaceMaxNm = 30,
	minTargetNm = 10,
	filterDelaySec = 5,
	minCapAttackNm = 35,
	minPlaneAttackNm = 25,
	minHeloAttackNm = 15,
	log = true,
}
bc:startDynamicHybridFiller(DynamicHybridConfig)

if RedReactiveConfig.enabled then
	bc:startRedReactiveCounterpressure(RedReactiveConfig)
end

zones.laplandiya:addCriticalObject('LaplandiyaAmmo1')
zones.laplandiya:addCriticalObject('LaplandiyaAmmo2')
zones.laplandiya:addCriticalObject('LaplandiyaTank1')
zones.laplandiya:addCriticalObject('LaplandiyaTank2')
zones.laplandiya:addCriticalObject('LaplandiyaRailwayStation')


zones.zelenoborskij:addCriticalObject('ZelenoborskijAmmo1')
zones.zelenoborskij:addCriticalObject('ZelenoborskijAmmo2')
zones.zelenoborskij:addCriticalObject('ZelenoborskijTank1')
zones.zelenoborskij:addCriticalObject('ZelenoborskijTank2')
zones.zelenoborskij:addCriticalObject('ZelenoborskijRailwayStation')


zones.pyaozerskystorage:addCriticalObject('Pyaozersky ammo depot 1')
zones.pyaozerskystorage:addCriticalObject('Pyaozersky ammo depot 2')
zones.pyaozerskystorage:addCriticalObject('Pyaozersky RailwayStation')


zones.lovozeroCCC:addCriticalObject('LovozeroCCCbunker')


local bomb_COOLDOWN = 1800
local lastbomb_COOLDOWN  = -bomb_COOLDOWN
Group.getByName('evt-bomb'):destroy()
Group.getByName('EscortBomber'):destroy()
evc:addEvent({
	id='bomb',
	action=function()
		RespawnGroup('evt-bomb')
		RegisterGroupTarget('evt-bomb',500,L10N:Get("SYRIA_MISSION_INTERCEPT_BOMBERS_TITLE"),'bomb')
		timer.scheduleFunction(function()
			RespawnGroup('EscortBomber')
				local tgts = {
					'Kiruna','Bardufoss','Alta','Banak','Kallax','Ivalo','KemiTornio','Rovaniemi',
					'Kirkenes','Ivalo','Kittila','Vuojarvi','Monchegorsk','Olenya'}
					if Group.getByName('evt-bomb') then
						local bomber, bomberMission = StartBomberAuftrag('bomb', 'evt-bomb', tgts, 'EscortBomber')
				end
		end,{},timer.getTime()+1)
	end,
	canExecute = function()
        if ActiveMission['bomb'] then return false end
        if timer.getTime()-lastbomb_COOLDOWN<bomb_COOLDOWN then return false end
		local gr = Group.getByName('evt-bomb')
		if gr then return false end
        if CustomFlags['DynCampaign'] then return false end
		if math.random(1,100)<70 then return false end
		local triggers = {'Kiruna', 'Kallax', 'Banak', 'Ivalo', 'KemiTornio'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		
		return false
	end
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_TITLE"),
	description = LTGet("CA_MISSION_INTERCEPT_BOMBERS_MINERALNYE_DESC"),
	messageStart = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_START"),
	messageEnd=function(T) lastbomb_COOLDOWN=timer.getTime() return LT(T):Get("SYRIA_MISSION_INTERCEPT_BOMBERS_END") end,
	startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
    end,
    isActive = function()
        if not ActiveMission['bomb'] then return false end
        if Group.getByName('evt-bomb') then return true end
        ActiveMission['bomb'] = nil
        return false
    end
})
local airstrike_COOLDOWN = 1800
local lastairstrike_COOLDOWN  = -airstrike_COOLDOWN
Group.getByName('evt-attack'):destroy()
evc:addEvent({
	id='cas',
	action = function()
        Respawn.Group('evt-attack')
		RegisterGroupTarget('evt-attack',250,L10N:Get("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),'cas')
		timer.scheduleFunction(function(param, time)
			local tgts = {
			'Kiruna',
			'Bardufoss',
			'Banak',
			'Alta',
			'Kallax',
			'Ivalo',
			'KemiTornio',
			'Rovaniemi',
			'Kirkenes',
			'Ivalo',
			'Kittila',
			'Vuojarvi',
			'Monchegorsk',
			'Olenya'
			}		
			local validtgts = {}
			for _,v in ipairs(tgts) do
				if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
					table.insert(validtgts, v)
				end
			end
			
			if #validtgts ~= 0 then
				local die = math.random(1,#validtgts)
				local choice = validtgts[die]
				
				if Group.getByName('evt-attack') then
					bc:engageZone(choice, 'evt-attack')
				end
			end
		end, {}, timer.getTime()+3)
	end,
	canExecute = function()
        if ActiveMission['cas'] then return false end
        if timer.getTime()-lastairstrike_COOLDOWN<airstrike_COOLDOWN then return false end
		local gr = Group.getByName('evt-attack')
		if gr then return false end
		if math.random(1,100) < 50 then return false end
		if CustomFlags['DynCampaign'] then return false end
		local triggers = {'Kiruna', 'Kallax', 'Banak', 'Ivalo', 'KemiTornio'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		
		return false
	end
})
mc:trackMission({
	title = LTGet("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),
	description = LTGet("CA_MISSION_INTERCEPT_AIRSTRIKE_WEST_EAST_DESC"),
	messageStart = LTGet("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_START"),
    messageEnd =function(T) lastairstrike_COOLDOWN=timer.getTime() return LT(T):Get("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_END") end,
	startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
        if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
    end,
    isActive = function()
        if not ActiveMission['cas'] then return false end
        if Group.getByName('evt-attack') then return true end
        ActiveMission['cas'] = nil
        return false
    end
})
local Escort_COOLDOWN = 2400
local lastEscort_COOLDOWN  = -Escort_COOLDOWN
Group.getByName('escort-me'):destroy()
Group.getByName('interceptor-1'):destroy()
Group.getByName('interceptor-2'):destroy()
evc:addEvent({
	id='escort',
	action = function()
        RespawnGroup('escort-me')
        ActiveMission['escort'] = true
		
	local function spawnIntercept(args)
		local groupname = args[1]
		--env.info('spawnIntercept called for '..tostring(groupname))
		if Group.getByName('escort-me') then
				local g = GROUP:FindByName(groupname,false)
				if not g then
					if math.random(1,100) > 30 then
						if math.random(1,100) > 50 then
							trigger.action.outTextForCoalition(2,L10N:Get("KOLA_EVENT_CARGO_INTERCEPTOR_SPOTTED"),15)
						else
							trigger.action.outTextForCoalition(2,L10N:Get("KOLA_EVENT_CARGO_INTERCEPT_LAUNCHED"),15)
						end
						RespawnGroup(groupname)
					end
				end
			end
		end
		local timers = {math.random(10*60,20*60), math.random(15*60,25*60)}
		timer.scheduleFunction(spawnIntercept, {'interceptor-1'}, timer.getTime() + timers[1])
		timer.scheduleFunction(spawnIntercept, {'interceptor-2'}, timer.getTime() + timers[2])
	end,
	canExecute = function()
        if ActiveMission['escort'] then return false end
        if timer.getTime()-lastEscort_COOLDOWN<Escort_COOLDOWN then return false end
		local gr = Group.getByName('escort-me')
		if gr then return false end
        if CustomFlags['DynCampaign'] then return false end
		local triggers = {'Kiruna', 'Kallax', 'Banak', 'Ivalo', 'KemiTornio'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		
		return false
	end
})
mc:trackMission({
    title = LTGet("SYRIA_MISSION_ESCORT_CARGO_TITLE"),
    description = LTGet("KOLA_MISSION_ESCORT_CARGO_BODO_DESC"),
    messageStart = LTGet("SYRIA_MISSION_ESCORT_CARGO_START"),
   messageEnd =function(T) lastEscort_COOLDOWN=timer.getTime() return LT(T):Get("SYRIA_MISSION_ESCORT_CARGO_END") end,
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
    end,
    isActive = function()
        if not ActiveMission['escort'] then return false end
        if Group.getByName('escort-me') then return true end
        ActiveMission['escort'] = nil
        return false
    end
})
local CargoIntercept_COOLDOWN = 3600
local lastCargoIntercept_COOLDOWN  = -CargoIntercept_COOLDOWN
Group.getByName('evt-cargointercept1'):destroy()
Group.getByName('evt-cargointercept2'):destroy()
Group.getByName('evt-cargointercept3'):destroy()
evc:addEvent({
	id='cargointercept',
	action = function()
		local planes
		if bc:getZoneByName('Olenya').side == 1 and not bc:getZoneByName('Olenya').suspended then
		  planes = {'evt-cargointercept1'}
		elseif bc:getZoneByName('Ivalo').side == 1 and not bc:getZoneByName('Ivalo').suspended then
		  planes = {'evt-cargointercept2'}
		elseif bc:getZoneByName('Kuusamo').side == 1 and not bc:getZoneByName('Kuusamo').suspended then
		  planes = {'evt-cargointercept3'}
		else
			return
		end
        RespawnGroup(planes[1])
        local g = Group.getByName(planes[1])
        if g then
        local u = g:getUnit(1)
        if u then RegisterUnitTarget(u:getName(),250,L10N:Get("SYRIA_MISSION_INTERCEPT_CARGO_TITLE"),'cargointercept') end
        end
	end,
	canExecute = function()
        if ActiveMission['cargointercept'] then return false end
        if timer.getTime() - lastCargoIntercept_COOLDOWN < CargoIntercept_COOLDOWN then return false end
		if math.random(1,100) < 70 then return false end
        if CustomFlags['DynCampaign'] then return false end
        local olenya = bc:getZoneByName('Olenya')
        local ivalo = bc:getZoneByName('Ivalo')
        local kuusamo = bc:getZoneByName('Kuusamo')
		if olenya.side == 2 and ivalo.side == 2 and
		kuusamo.side == 2 and not (kuusamo.suspended and olenya.suspended and ivalo.suspended) 
        then return false end
		if Group.getByName('evt-cargointercept1') then return false end
		if Group.getByName('evt-cargointercept2') then return false end
		if Group.getByName('evt-cargointercept3') then return false end
		return true
	end
})
mc:trackMission({
    title = LTGet("SYRIA_MISSION_INTERCEPT_CARGO_TITLE"),
    description = function(T)
		if Group.getByName('evt-cargointercept1') then
			return LT(T):Get("KOLA_MISSION_INTERCEPT_CARGO_DESC_OLENYA")
		elseif Group.getByName('evt-cargointercept2') then
			return LT(T):Get("KOLA_MISSION_INTERCEPT_CARGO_DESC_IVALO")
		elseif Group.getByName('evt-cargointercept3') then
			return LT(T):Get("KOLA_MISSION_INTERCEPT_CARGO_DESC_KUUSAMO")
		else
			return LT(T):Get("PG_MISSION_INTERCEPT_CARGO_INACTIVE")
		end
	end,
    messageStart = LTGet("SYRIA_MISSION_INTERCEPT_CARGO_START"),
    messageEnd =function(T) lastCargoIntercept_COOLDOWN=timer.getTime() return LT(T):Get("SYRIA_MISSION_INTERCEPT_CARGO_END") end,
    startAction = function() 
        if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['cargointercept'] then return false end
        if Group.getByName('evt-cargointercept1') then return true end
        if Group.getByName('evt-cargointercept2') then return true end
        if Group.getByName('evt-cargointercept3') then return true end
        ActiveMission['cargointercept'] = nil
        return false
    end
})

Group.getByName('Zapolyarnyy-Scuds'):destroy()
evc:addEvent({
	id='scuds2',
	action = function()
        RespawnGroup('Zapolyarnyy-Scuds')
		RegisterGroupTarget('Zapolyarnyy-Scuds',100,L10N:Get("KOLA_TARGET_DESTROY_SCUDS"),'scuds2')
		timer.scheduleFunction(function(param, time)
			if Group.getByName('Zapolyarnyy-Scuds') then
				local tgts = {
					'Banak',
					'Ivalo',
					'Kirkenes',
					'Buolbmat',
					'Karasjok'
				}
				
				local validtgts = {}
				for _,v in ipairs(tgts) do
					if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
						table.insert(validtgts, v)
					end
				end
				
				if #validtgts == 0 then return time+(10*60) end
				
				local die = math.random(1,#validtgts)
				local choice = validtgts[die]
				bc:fireAtZone(choice, 'Zapolyarnyy-Scuds', false, 8)
				trigger.action.outTextForCoalition(2, L10N:Format("KOLA_EVENT_SCUDS_ZAPOLYARNYY_LAUNCHING", choice), 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
        if ActiveMission['scuds2'] then return false end
		local gr = Group.getByName('Zapolyarnyy-Scuds')
		if gr then return false end
        if CustomFlags['DynCampaign'] then return false end
		if math.random(100) > 20 then return false end
		if bc:getZoneByName('Zapolyarnyy').side ~= 1 or bc:getZoneByName('Zapolyarnyy').suspended then return false end
		
		local triggers = {'Banak', 'Ivalo', 'Kirkenes', 'Karasjok', 'Buolbmat'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		
		return false
	end
})
mc:trackMission({
	title = LTGet("KOLA_MISSION_SCUDS_ZAPOLYARNYY_TITLE"),
	description = LTGet("KOLA_MISSION_SCUDS_ZAPOLYARNYY_DESC"),
	messageStart = LTGet("KOLA_MISSION_SCUDS_ZAPOLYARNYY_START"),
	messageEnd = LTGet("KOLA_MISSION_SCUDS_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
	isActive = function()
        if not ActiveMission['scuds2'] then return false end
		if Group.getByName('Zapolyarnyy-Scuds') then return true end
        ActiveMission['scuds2'] = nil
		return false
	end
})
Group.getByName('Kittila-Scuds'):destroy()
evc:addEvent({
	id='scuds1',
	action = function()

    RespawnGroup('Kittila-Scuds')  
		RegisterGroupTarget('Kittila-Scuds',100,L10N:Get("KOLA_TARGET_DESTROY_SCUDS"),'scuds1')
		timer.scheduleFunction(function(param, time)
			if Group.getByName('Kittila-Scuds') then
				local tgts = {
					'Kiruna',
					'Gallivare',
					'Jokkmokk',
					'Vidsel',
					'Kalixfors',
                    'Kallax',   
                    'KemiTornio'
				}
				
				local validtgts = {}
				for _,v in ipairs(tgts) do
					if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
						table.insert(validtgts, v)
					end
				end
				
				if #validtgts == 0 then return time+(10*60) end
				
				local die = math.random(1,#validtgts)
				local choice = validtgts[die]
				bc:fireAtZone(choice, 'Kittila-Scuds', false, 8)
				trigger.action.outTextForCoalition(2, L10N:Format("KOLA_EVENT_SCUDS_KITTILA_LAUNCHING", choice), 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
        if ActiveMission['scuds1'] then return false end
		local gr = Group.getByName('Kittila-Scuds')
		if gr then return false end
        if CustomFlags['DynCampaign'] then return false end
		if math.random(100) > 20 then return false end
		if bc:getZoneByName('Kittila').side ~= 1 or bc:getZoneByName('Kittila').suspended then return false end
		
		local triggers = {'Kiruna', 'Kalixfors', 'Gallivare', 'Kallax', 'KemiTornio'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		
		return false
	end
})
mc:trackMission({
	title = LTGet("KOLA_MISSION_SCUDS_KITTILA_TITLE"),
	description = LTGet("KOLA_MISSION_SCUDS_KITTILA_DESC"),
	messageStart = LTGet("KOLA_MISSION_SCUDS_KITTILA_START"),
	messageEnd = LTGet("KOLA_MISSION_SCUDS_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
	isActive = function()
        if not ActiveMission['scuds1'] then return false end
		if Group.getByName('Kittila-Scuds') then return true end
        ActiveMission['scuds1'] = nil
		return false
	end
})

attackTarget1 = nil
attackTarget2 = nil
resupplyTarget1 = nil
resupplyTarget2 = nil
attackCombinedStart1 = nil
attackCombinedStart2 = nil
attackSuppressStart2 = nil
resupplyCombinedStart1 = nil
resupplyCombinedStart2 = nil
resupplySuppressStart2 = nil
local function _isFrontlineConnectionEligible(from, to)
	return from and to and from.side ~= to.side and from.side ~= 0 and to.side ~= 0 and
		((not to.suspended) or from.suspended)
end

local function _isValidAttackMissionZone(zone)
	if not zone or not zone.zone then return false end
	local lname = zone.zone:lower()
	return zone.side == 1 and zone.active and not zone.suspended and not zone.isHidden and
		not isZoneUnderSEADMission(zone.zone) and
		not lname:find('hidden') and not lname:find('sam') and not lname:find('defence') and
		not lname:find('papa') and not lname:find('juliett') and not lname:find('india') and
		not lname:find('delta') and not lname:find('bravo') and not lname:find('hotel') and
		not lname:find('ivalo') and not lname:find('banak')
end

local function _getAttackAnchorZones()
	local anchors = {}
	local seen = {}
	for _, zoneName in ipairs({ attackTarget1, attackTarget2 }) do
		if zoneName and not seen[zoneName] then
			local targetzn = bc:getZoneByName(zoneName)
			if targetzn and targetzn.zone and targetzn.side == 1 then
				seen[zoneName] = true
				anchors[#anchors + 1] = targetzn.zone
			end
		end
	end
	return anchors
end
local function _minDistanceToAttackAnchors(anchors, zoneName)
	local minDist = nil
	for _, anchorZone in ipairs(anchors or {}) do
		local dist = ZONE_DISTANCES[anchorZone] and ZONE_DISTANCES[anchorZone][zoneName]
		if dist and (not minDist or dist < minDist) then
			minDist = dist
		end
	end
	return minDist
end

mc:trackMission({
	title = function(T)
		local wp = WaypointList[resupplyTarget1] or ""
		return LT(T):Format("SYRIA_DYNAMIC_RESUPPLY_TITLE", resupplyTarget1, wp)
	end,
	description = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_RESUPPLY_DESC", resupplyTarget1)
	end,
	messageStart = nil,
	messageEnd = function()
		return L10N:Format("SYRIA_DYNAMIC_RESUPPLY_END", resupplyTarget1)
	end,
	startAction = function()
		local MissionType = "Resupply"
		bc:addMissionTag(resupplyTarget1, MissionType)
		bc:refreshZoneLabel(resupplyTarget1)
		local wp = WaypointList[resupplyTarget1] or ""
		if resupplyCombinedStart1 == resupplyTarget1 and resupplyCombinedStart2 == resupplyTarget2 and resupplyTarget2 then
			local wp2 = WaypointList[resupplyTarget2] or ""
			trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_DYNAMIC_RESUPPLY_START_TWO", resupplyTarget1, wp, resupplyTarget2, wp2), 30)
			resupplySuppressStart2 = resupplyTarget2
			resupplyCombinedStart1 = nil
			resupplyCombinedStart2 = nil
		else
			trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_DYNAMIC_RESUPPLY_START_ONE", resupplyTarget1, wp), 30)
		end
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "ding.ogg")
		end
	end,
	endAction = function()
		local MissionType = "Resupply"
		bc:removeMissionTag(resupplyTarget1, MissionType)
		bc:refreshZoneLabel(resupplyTarget1)
		resupplyTarget1 = nil
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
	isActive = function()
		if not resupplyTarget1 then return false end
		local targetzn = bc:getZoneByName(resupplyTarget1)
		return targetzn and targetzn.side == 2 and targetzn:canRecieveSupply()
	end
})

mc:trackMission({
	title = function(T)
		local wp = WaypointList[resupplyTarget2] or ""
		return LT(T):Format("SYRIA_DYNAMIC_RESUPPLY_TITLE", resupplyTarget2, wp)
	end,
	description = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_RESUPPLY_DESC", resupplyTarget2)
	end,
	messageStart = nil,
	messageEnd = function()
		return L10N:Format("SYRIA_DYNAMIC_RESUPPLY_END", resupplyTarget2)
	end,
	startAction = function()
		local MissionType = "Resupply"
		bc:addMissionTag(resupplyTarget2, MissionType)
		bc:refreshZoneLabel(resupplyTarget2)
		resupplyCombinedStart1 = nil
		resupplyCombinedStart2 = nil
		if resupplySuppressStart2 == resupplyTarget2 then
			resupplySuppressStart2 = nil
		else
			local wp = WaypointList[resupplyTarget2] or ""
			trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_DYNAMIC_RESUPPLY_START_ONE", resupplyTarget2, wp), 30)
			if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
				trigger.action.outSoundForCoalition(2, "ding.ogg")
			end
		end
	end,
	endAction = function()
		local MissionType = "Resupply"
		bc:removeMissionTag(resupplyTarget2, MissionType)
		bc:refreshZoneLabel(resupplyTarget2)
		resupplyTarget2 = nil
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
	isActive = function()
		if not resupplyTarget2 then return false end
		local targetzn = bc:getZoneByName(resupplyTarget2)
		return targetzn and targetzn.side == 2 and targetzn:canRecieveSupply()
	end
})

mc:trackMission({
	title = function(T)
		local wp = WaypointList[attackTarget1] or ""
		return LT(T):Format("SYRIA_DYNAMIC_ATTACK_TITLE", attackTarget1, wp)
	end,
	description = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_ATTACK_DESC", attackTarget1)
	end,
	messageStart = nil,
	messageEnd = function()
		return L10N:Format("SYRIA_DYNAMIC_ATTACK_END", attackTarget1)
	end,
	startAction = function()
		bc:addMissionTag(attackTarget1, "Attack")
		bc:refreshZoneLabel(attackTarget1)
		local wp = WaypointList[attackTarget1] or ""
		if attackCombinedStart1 == attackTarget1 and attackCombinedStart2 == attackTarget2 and attackTarget2 then
			local wp2 = WaypointList[attackTarget2] or ""
			trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_DYNAMIC_ATTACK_START_TWO", attackTarget1, wp, attackTarget2, wp2), 30)
			attackSuppressStart2 = attackTarget2
			attackCombinedStart1 = nil
			attackCombinedStart2 = nil
		else
			trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_DYNAMIC_ATTACK_START_ONE", attackTarget1, wp), 30)
		end
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cas.ogg")
		end
	end,
	endAction = function()
		bc:removeMissionTag(attackTarget1, "Attack")
		bc:refreshZoneLabel(attackTarget1)
		attackTarget1 = nil
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
	isActive = function()
		if not attackTarget1 then return false end
		local targetzn = bc:getZoneByName(attackTarget1)
		if targetzn and targetzn.zone and targetzn.side == 1 then
			return not targetzn.suspended
		end
		return false
	end
})

mc:trackMission({
	title = function(T)
		local wp = WaypointList[attackTarget2] or ""
		return LT(T):Format("SYRIA_DYNAMIC_ATTACK_TITLE", attackTarget2, wp)
	end,
	description = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_ATTACK_DESC", attackTarget2)
	end,
	messageStart = nil,
	messageEnd = function()
		return L10N:Format("SYRIA_DYNAMIC_ATTACK_END", attackTarget2)
	end,
	startAction = function()
		bc:addMissionTag(attackTarget2, "Attack")
		bc:refreshZoneLabel(attackTarget2)
		attackCombinedStart1 = nil
		attackCombinedStart2 = nil
		if attackSuppressStart2 == attackTarget2 then
			attackSuppressStart2 = nil
		else
			local wp = WaypointList[attackTarget2] or ""
			trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_DYNAMIC_ATTACK_START_ONE", attackTarget2, wp), 30)
			if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
				trigger.action.outSoundForCoalition(2, "cas.ogg")
			end
		end
	end,
	endAction = function()
		bc:removeMissionTag(attackTarget2, "Attack")
		bc:refreshZoneLabel(attackTarget2)
		attackTarget2 = nil
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
	isActive = function()
		if not attackTarget2 then return false end
		local targetzn = bc:getZoneByName(attackTarget2)
		if targetzn and targetzn.zone and targetzn.side == 1 then
			return not targetzn.suspended
		end
		return false
	end
})
captureTarget = nil
mc:trackMission({
    title = function(T)
        local wp = WaypointList[captureTarget] or ""
        return LT(T):Format("SYRIA_DYNAMIC_CAPTURE_TITLE", captureTarget, wp)
    end,
    description = function(T)
        return LT(T):Format("SYRIA_DYNAMIC_CAPTURE_DESC", captureTarget) end,
    messageStart = function()
        local wp = WaypointList[captureTarget] or ""
        return L10N:Format("SYRIA_DYNAMIC_CAPTURE_START", captureTarget, wp)
    end,
    messageEnd = function()
        return L10N:Format("SYRIA_DYNAMIC_CAPTURE_END", captureTarget) end,
    startAction = function()
        local MissionType = "Capture"
        bc:addMissionTag(captureTarget, MissionType)
        bc:refreshZoneLabel(captureTarget)
        if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
        local MissionType = "Capture"
        bc:removeMissionTag(captureTarget, MissionType)
        bc:refreshZoneLabel(captureTarget)
        captureTarget = nil
        if not missionCompleted then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
    end,
    isActive = function()
        if not captureTarget then return false end
        local targetzn = bc:getZoneByName(captureTarget)
        return targetzn.side == 0 and targetzn.active
    end
})
---------------------------------- GeneralsHouse -----------------------------------------------
-- klar
local sceneryList = {
  ["KandalakshaAluminium"] = {SCENERY:FindByZoneName("KandalakshaAluminium")},
  ["RussiansHideOut"] = {SCENERY:FindByZoneName("RussiansHideOut")},
  ["GeneralsHouse"] = {SCENERY:FindByZoneName("GeneralsHouse")},
  ["Kandalaksha_car_bridge1"] = {SCENERY:FindByZoneName("Kandalaksha_car_bridge1")}, -- not used
  ["Kandalaksha_car_bridge2"] = {SCENERY:FindByZoneName("Kandalaksha_car_bridge2")}, -- not used
  ["Kandalaksha_rw_bridge_2line"] = {SCENERY:FindByZoneName("Kandalaksha_rw_bridge_2line")}, -- not used
  ["BeloyeMorePumpingStation"] = {SCENERY:FindByZoneName("BeloyeMorePumpingStation")}, -- not used
 
}

timer.scheduleFunction(function()
do
  local missing = {}
  for name, arr in pairs(sceneryList) do
    local sc = arr and arr[1]
    if not sc then
      sc = SCENERY:FindByZoneName(name)
      if sc then
        sceneryList[name][1] = sc
      else
        missing[#missing + 1] = name
      end
    end
  end
  for _, name in ipairs(missing) do
    trigger.action.outText(L10N:Format("KOLA_SETUP_OBJECT_MISSING", name), 30)
  end
end
end, {}, timer.getTime() + 1)

evc:addEvent({
	id='RussiansHideOut',
	action = function()
	ActiveMission['RussiansHideOut'] = true
	local tgt = SCENERY:FindByZoneName('RussiansHideOut')
	if not tgt then
		trigger.action.outText(L10N:Format("KOLA_SETUP_OBJECT_MISSING", "RussiansHideOut"),30)
		return
	end
		RegisterScoreTarget('RussiansHideOut',tgt,500,L10N:Get("KOLA_TARGET_RUSSIAN_HIDEOUT"),true)
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("KOLA_MARK_RUSSIAN_HIDEOUT"),p,2,false,false)
			MissionMarks['RussiansHideOut'] = missionMarkId
		end
	end,
	canExecute = function()
		if CustomFlags['DynCampaign'] then return false end
		if ActiveMission['RussiansHideOut'] then return false end
        if CustomFlags["RussiansHideOut"] then return false end
        if bc:getZoneByName('Jokkmokk').side ~= 1 or bc:getZoneByName('Jokkmokk').suspended then return false end
		return true
	end
})
mc:trackMission({
	title = LTGet("KOLA_MISSION_RUSSIAN_HIDEOUT_TITLE"),
	description = LTGet("KOLA_MISSION_RUSSIAN_HIDEOUT_DESC"),
	messageStart = LTGet("KOLA_MISSION_RUSSIAN_HIDEOUT_START"),
	messageEnd = LTGet("KOLA_MISSION_RUSSIAN_HIDEOUT_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["RussiansHideOut"] then return false end
    if ActiveMission['RussiansHideOut'] then return true end
	  return false
	end,
})

evc:addEvent({
	id='GeneralsHouse',
	action = function()
	ActiveMission['GeneralsHouse'] = true
	local tgt = SCENERY:FindByZoneName('GeneralsHouse')
	if not tgt then
		trigger.action.outText(L10N:Format("KOLA_SETUP_OBJECT_MISSING", "GeneralsHouse"),30)
		return
	end
		RegisterScoreTarget('GeneralsHouse',tgt,500,L10N:Get("KOLA_TARGET_HIGH_VALUE"),true)
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("KOLA_MARK_HIGH_VALUE"),p,2,false,false)
			MissionMarks['GeneralsHouse'] = missionMarkId
		end
	end,
	canExecute = function()
		if CustomFlags['DynCampaign'] then return false end
		if ActiveMission['GeneralsHouse'] then return false end
        if CustomFlags["GeneralsHouse"] then return false end
        if bc:getZoneByName('Kovdor').side ~= 1 or bc:getZoneByName('Kovdor').suspended then return false end
        if bc:getZoneByName('Ivalo').side ~= 2 or bc:getZoneByName('Kittila').side ~= 2 then return false end
		return true
	end
})
mc:trackMission({
	title = LTGet("KOLA_MISSION_HIGH_VALUE_TITLE"),
	description = LTGet("KOLA_MISSION_HIGH_VALUE_DESC"),
	messageStart = LTGet("KOLA_MISSION_HIGH_VALUE_START"),
	messageEnd = LTGet("KOLA_MISSION_HIGH_VALUE_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["GeneralsHouse"] then return false end
    if ActiveMission['GeneralsHouse'] then return true end
	  return false
	end,
})
---------------------------------- END GeneralsHouse -----------------------------------------------
-- klar
-- PapasSon Strike Target 0
Group.getByName('PapasSon'):destroy()
Group.getByName('Red SAM SA-3 Fixed PapasSon'):destroy()
evc:addEvent({
	id='PapasSon',
	action = function()
        RespawnGroup('PapasSon')
		RegisterGroupTarget('PapasSon',500,L10N:Get("KOLA_TARGET_RIGHT_HAND_MAN"),'PapasSon',true)
	end,
	canExecute = function()
        if ActiveMission['PapasSon'] then return false end
        if CustomFlags['DynCampaign'] then return false end
		if bc:getZoneByName('Banak').side ~= 2 or bc:getZoneByName('Karasjok').side ~= 2 then return false end
        if bc:getZoneByName('Banak').suspended or bc:getZoneByName('Karasjok').suspended then return false end
		if CustomFlags["PapasSon"] then return false end
		if Group.getByName('PapasSon') then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("KOLA_MISSION_RIGHT_HAND_MAN_TITLE"),
description = LTGet("KOLA_MISSION_RIGHT_HAND_MAN_DESC"),

	messageStart = LTGet("KOLA_MISSION_RIGHT_HAND_MAN_START"),
	messageEnd = LTGet("KOLA_MISSION_RIGHT_HAND_MAN_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
        RespawnGroup('Red SAM SA-3 Fixed PapasSon')
	end,
	isActive = function()
		if CustomFlags["PapasSon"] then return false end
		if Group.getByName('PapasSon') then return true end
		return false
	end
})
------------------------end of PapasSon mission----------------------------------
----------------------- laplandiya statics mission --------------------------------
evc:addEvent({
	id = 'laplandiyaStorage',
		action = function()
		local z = zones.laplandiya
		if not z then return end
		RegisterStaticGroup('laplandiyaStorage', z, 1250, L10N:Get("KOLA_TARGET_LAPLANDIYA_STORAGE"), 'laplandiyaStorage', true)
		ActiveMission['laplandiyaStorage'] = true
	end,
	canExecute = function()
		if ActiveMission['laplandiyaStorage'] then return false end
		if CustomFlags['laplandiyaStorage'] then return false end
		if bc:getZoneByName('LaplandiyaStorage').side ~= 1 or bc:getZoneByName('LaplandiyaStorage').suspended then return false end
        local Ivalo = bc:getZoneByName('Ivalo')
        local Kittila = bc:getZoneByName('Kittila')
        if (Ivalo.side == 2 and not Ivalo.suspended) or (Kittila.side == 2 and not Kittila.suspended) then return true end
        return false
	end,
})

mc:trackMission({
	title = LTGet("KOLA_MISSION_LAPLANDIYA_STORAGE_TITLE"),
	description = LTGet("KOLA_MISSION_LAPLANDIYA_STORAGE_DESC"),
	messageStart = LTGet("KOLA_MISSION_LAPLANDIYA_STORAGE_START"),
	messageEnd = LTGet("KOLA_MISSION_LAPLANDIYA_STORAGE_END"),
	startAction = function()
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "ding.ogg")
		end
	end,
	endAction = function()
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
	isActive = function()
		if CustomFlags['laplandiyaStorage'] then return false end
		if ActiveMission['laplandiyaStorage'] then return true end
		return false
	end
})
------------------------ end of laplandiya statics mission ------------------------

------------------------ zelenoborskij statics mission ------------------------

evc:addEvent({
	id = 'ZelenoborskijStorage',
		action = function()
		local z = zones.zelenoborskij
		if not z then return end
		RegisterStaticGroup('ZelenoborskijStorage', z, 1250, L10N:Get("KOLA_TARGET_ZELENOBORSKIJ_STORAGE"), 'ZelenoborskijStorage', true)
		ActiveMission['ZelenoborskijStorage'] = true
	end,
	canExecute = function()
		if ActiveMission['ZelenoborskijStorage'] then return false end
		if CustomFlags['ZelenoborskijStorage'] then return false end
		if bc:getZoneByName('ZelenoborskijStorage').side ~= 1 or bc:getZoneByName('ZelenoborskijStorage').suspended then return false end
        local Alakourtti = bc:getZoneByName('Alakourtti')
        local Kuusamo = bc:getZoneByName('Kuusamo')
        if (Alakourtti.side == 2 and not Alakourtti.suspended) or (Kuusamo.side == 2 and not Kuusamo.suspended) then return true end
        return false
	end,
})

mc:trackMission({
	title = LTGet("KOLA_MISSION_ZELENOBORSKIJ_STORAGE_TITLE"),
	description = LTGet("KOLA_MISSION_ZELENOBORSKIJ_STORAGE_DESC"),
	messageStart = LTGet("KOLA_MISSION_ZELENOBORSKIJ_STORAGE_START"),
	messageEnd = LTGet("KOLA_MISSION_ZELENOBORSKIJ_STORAGE_END"),
	startAction = function()
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "ding.ogg")
		end
	end,
	endAction = function()
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
	isActive = function()
		if CustomFlags['ZelenoborskijStorage'] then return false end
		if ActiveMission['ZelenoborskijStorage'] then return true end
		return false
	end
})
------------------------ end of zelenoborskij statics mission ------------------------
------------------------ Pyaozersky statics mission ------------------------
--PyaozerskyStorage
evc:addEvent({
	id = 'PyaozerskyStorage',
		action = function()
		local z = zones.PyaozerskyStorage
		if not z then return end
		RegisterStaticGroup('PyaozerskyStorage', z, 1000, L10N:Get("KOLA_TARGET_PYAOZERSKY_STORAGE"), 'PyaozerskyStorage', true)
		ActiveMission['PyaozerskyStorage'] = true
	end,
	canExecute = function()
		if ActiveMission['PyaozerskyStorage'] then return false end
		if CustomFlags['PyaozerskyStorage'] then return false end
		if bc:getZoneByName('PyaozerskyStorage').side ~= 1 or bc:getZoneByName('PyaozerskyStorage').suspended then return false end
        local Alakourtti = bc:getZoneByName('Alakourtti')
        local Kuusamo = bc:getZoneByName('Kuusamo')
        if (Alakourtti.side == 2 and not Alakourtti.suspended) or (Kuusamo.side == 2 and not Kuusamo.suspended) then return true end
        return false
	end,
})

mc:trackMission({
	title = LTGet("KOLA_MISSION_PYAOZERSKY_STORAGE_TITLE"),
	description = LTGet("KOLA_MISSION_PYAOZERSKY_STORAGE_DESC"),
	messageStart = LTGet("KOLA_MISSION_PYAOZERSKY_STORAGE_START"),
	messageEnd = LTGet("KOLA_MISSION_PYAOZERSKY_STORAGE_END"),
	startAction = function()
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "ding.ogg")
		end
	end,
	endAction = function()
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
	isActive = function()
		if CustomFlags['PyaozerskyStorage'] then return false end
		if ActiveMission['PyaozerskyStorage'] then return true end
		return false
	end
})
------------------------ end of PyaozerskyStorage mission ------------------------

------------------------ lovozeroCCC statics mission ------------------------

evc:addEvent({
	id = 'lovozeroCCCBunker',
		action = function()
		local z = zones.LovozeroCCC
		if not z then return end
		RegisterStaticGroup('lovozeroCCCBunker', z, 1000, L10N:Get("KOLA_TARGET_LOVOZERO_CCC"), 'lovozeroCCCBunker', true)
		ActiveMission['lovozeroCCCBunker'] = true
	end,
	canExecute = function()
		if ActiveMission['lovozeroCCCBunker'] then return false end
		if CustomFlags['lovozeroCCCBunker'] then return false end
		if bc:getZoneByName('LovozeroCCC').side ~= 1 or bc:getZoneByName('LovozeroCCC').suspended then return false end
        local Olenya = bc:getZoneByName('Olenya')
        if (Olenya.side == 2 and not Olenya.suspended) then return true end
        return false
	end,
})

mc:trackMission({
	title = LTGet("KOLA_MISSION_LOVOZERO_CCC_TITLE"),
	description = LTGet("KOLA_MISSION_LOVOZERO_CCC_DESC"),
	messageStart = LTGet("KOLA_MISSION_LOVOZERO_CCC_START"),
	messageEnd = LTGet("KOLA_MISSION_LOVOZERO_CCC_END"),
	startAction = function()
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "ding.ogg")
		end
	end,
	endAction = function()
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
	isActive = function()
		if CustomFlags['lovozeroCCCBunker'] then return false end
		if ActiveMission['lovozeroCCCBunker'] then return true end
		return false
	end
})
------------------------ end of lovozeroCCC statics mission ------------------------


function generateCaptureMission()
    if captureTarget ~= nil then return true end
    
    local validzones = {}
    for _, v in ipairs(bc.zones) do
        if v.active and v.side == 0 and (not v.NeutralAtStart or v.firstCaptureByRed) and 
           not v.zone:lower():find("hidden", 1, true) then
            table.insert(validzones, v.zone)
        end
    end
    
    if #validzones == 0 then return false end
    
    local choice = math.random(1, #validzones)
    if validzones[choice] then
        captureTarget = validzones[choice]
        return true
    end
end

function generateAttackMission()
    if missionCompleted then return true end

	local validzones = {}
	local validSeen = {}
	local redByBlue = {}
	local created1 = false
	local created2 = false

	for _, v in ipairs(bc.connections) do
		local from, to = bc:getConnectionZones(v)

		if _isFrontlineConnectionEligible(from, to) then
			if _isValidAttackMissionZone(from) and not validSeen[from.zone] then
				validSeen[from.zone] = true
				table.insert(validzones, from.zone)
			end
			if _isValidAttackMissionZone(to) and not validSeen[to.zone] then
				validSeen[to.zone] = true
				table.insert(validzones, to.zone)
			end

			if _isValidAttackMissionZone(from) and to and to.side == 2 then
				redByBlue[to.zone] = redByBlue[to.zone] or {}
				local found = false
				for _, zoneName in ipairs(redByBlue[to.zone]) do
					if zoneName == from.zone then found = true break end
				end
				if not found then table.insert(redByBlue[to.zone], from.zone) end
			end
			if _isValidAttackMissionZone(to) and from and from.side == 2 then
				redByBlue[from.zone] = redByBlue[from.zone] or {}
				local found = false
				for _, zoneName in ipairs(redByBlue[from.zone]) do
					if zoneName == to.zone then found = true break end
				end
				if not found then table.insert(redByBlue[from.zone], to.zone) end
			end
		end
	end

    if #validzones == 0 then return false end

	if not attackTarget1 then
		local pool = {}
		for _, zoneName in ipairs(validzones) do
			if zoneName ~= attackTarget2 then
				table.insert(pool, zoneName)
			end
		end
		if #pool > 0 then
			attackTarget1 = pool[math.random(1, #pool)]
			created1 = true
		end
	end

	if not attackTarget2 then
		local pool = {}
		local seenPool = {}
		local anchor = attackTarget1 or attackTarget2
		if anchor then
			for _, redList in pairs(redByBlue) do
				local hasAnchor = false
				for _, zoneName in ipairs(redList) do
					if zoneName == anchor then
						hasAnchor = true
						break
					end
				end
				if hasAnchor then
					for _, zoneName in ipairs(redList) do
						if zoneName ~= attackTarget1 and zoneName ~= attackTarget2 and not seenPool[zoneName] then
							seenPool[zoneName] = true
							table.insert(pool, zoneName)
						end
					end
				end
			end
		end
		if #pool == 0 then
			for _, zoneName in ipairs(validzones) do
				if zoneName ~= attackTarget1 and zoneName ~= attackTarget2 then
					table.insert(pool, zoneName)
				end
			end
		end
		if #pool > 0 then
			attackTarget2 = pool[math.random(1, #pool)]
			created2 = true
		end
	end

	attackCombinedStart1 = nil
	attackCombinedStart2 = nil
	if created1 and created2 and attackTarget1 and attackTarget2 then
		attackCombinedStart1 = attackTarget1
		attackCombinedStart2 = attackTarget2
	end

	return attackTarget1 ~= nil or attackTarget2 ~= nil
end
function generateSupplyMission()
	local preferred = {}
	local validzones = {}
	local attackFrontSet = {}
	local created1 = false
	local created2 = false
	if attackTarget1 then attackFrontSet[attackTarget1] = true end
	if attackTarget2 then attackFrontSet[attackTarget2] = true end

	for _, connection in ipairs(bc.connections or {}) do
		local from, to = bc:getConnectionZones(connection)
		if from and to and from.side ~= to.side and from.side ~= 0 and to.side ~= 0 and
			((not to.suspended) or from.suspended) then
			if from and to and attackFrontSet[from.zone] and to.side == 2 and to:canRecieveSupply() then
				local found = false
				for _, zoneName in ipairs(preferred) do
					if zoneName == to.zone then found = true break end
				end
				if not found then table.insert(preferred, to.zone) end
			end
			if from and to and attackFrontSet[to.zone] and from.side == 2 and from:canRecieveSupply() then
				local found = false
				for _, zoneName in ipairs(preferred) do
					if zoneName == from.zone then found = true break end
				end
				if not found then table.insert(preferred, from.zone) end
			end
		end
	end

	for _, v in ipairs(bc.zones) do
		if v.side == 2 and v:canRecieveSupply() then
			local found = false
			for _, zoneName in ipairs(validzones) do
				if zoneName == v.zone then found = true break end
			end
			if not found then table.insert(validzones, v.zone) end
		end
	end

	if #validzones == 0 then return false end

	if not resupplyTarget1 then
		local pool = {}
		for _, zoneName in ipairs(preferred) do
			if zoneName ~= resupplyTarget2 then
				table.insert(pool, zoneName)
			end
		end
		if #pool == 0 then
			for _, zoneName in ipairs(validzones) do
				if zoneName ~= resupplyTarget2 then
					table.insert(pool, zoneName)
				end
			end
		end
		if #pool > 0 then
			resupplyTarget1 = pool[math.random(1, #pool)]
			created1 = true
		end
	end

	if not resupplyTarget2 then
		local pool = {}
		for _, zoneName in ipairs(preferred) do
			if zoneName ~= resupplyTarget1 then
				table.insert(pool, zoneName)
			end
		end
		if #pool == 0 then
			for _, zoneName in ipairs(validzones) do
				if zoneName ~= resupplyTarget1 then
					table.insert(pool, zoneName)
				end
			end
		end
		if #pool > 0 then
			resupplyTarget2 = pool[math.random(1, #pool)]
			created2 = true
		end
	end

	resupplyCombinedStart1 = nil
	resupplyCombinedStart2 = nil
	if created1 and created2 and resupplyTarget1 and resupplyTarget2 then
		resupplyCombinedStart1 = resupplyTarget1
		resupplyCombinedStart2 = resupplyTarget2
	end

	return resupplyTarget1 ~= nil or resupplyTarget2 ~= nil
end
---------------------------------------------------------------------
--                          CAP MISSION                            --

capMissionTarget = nil
capKillsByPlayer = {}
capTargetPlanes = 0
capWinner = nil
capMissionCooldownUntil = 0

mc:trackMission({
    title = function(T) return LT(T):Get("MISSION_CAP_TITLE") end,
    description = function(T)
        if not next(capKillsByPlayer) then
            return LT(T):Format("MISSION_CAP_DESCRIPTION_EMPTY", capTargetPlanes)
        else
            local scoreboard = LT(T):Get("MISSION_CAP_SCOREBOARD_HEADER")
            for playerName, kills in pairs(capKillsByPlayer) do
                scoreboard = scoreboard .. string.format("%s: %d\n", playerName, kills)
            end
            return LT(T):Format("MISSION_CAP_DESCRIPTION_WITH_SCORE", capTargetPlanes, scoreboard)
        end
    end,
    messageStart = function()
        return L10N:Format("MISSION_CAP_START", capTargetPlanes) end,
    messageEnd = function() return L10N:Get("MISSION_CAP_END") end,
    startAction = function()
        if not missionCompleted then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
	endAction = function()
        if capWinner then
            local reward = capTargetPlanes * 100
            local pname  = capWinner
            bc:addContribution(pname, 2, reward)
            local jp = bc.jointPairs and bc.jointPairs[pname]
            if jp and bc:_jointPartnerAlive(pname) and bc:_jointPartnerAlive(jp) and bc.playerContributions[2][jp] ~= nil then
                bc:addContribution(jp, 2, reward)
                bc:addTempStat(jp,'CAP mission (Joint mission)',1)
                bc:addTempStat(pname,'CAP mission (Joint mission)',1)
                trigger.action.outTextForCoalition(2,L10N:Format("MISSION_CAP_COMPLETED_JOINT", pname, jp, reward),20)
                local jgn = bc.groupNameByPlayer[jp]
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
                bc:addTempStat(pname,'CAP mission',1)
                trigger.action.outTextForCoalition(2,L10N:Format("MISSION_CAP_COMPLETED_SOLO", pname, reward),20)
            end
            capMissionCooldownUntil = timer.getTime() + 900
        end
        capMissionTarget = nil
        capKillsByPlayer = {}
        capWinner        = nil
        capTargetPlanes  = 0
        if not missionCompleted then
            trigger.action.outSoundForCoalition(2,"cancel.ogg")
        end
	end,
    isActive = function()
        if not capMissionTarget then return false end
        return true
    end
})



--                    End of CAP MISSION                           --
---------------------------------------------------------------------

---------------------------------------------------------------------
--                          CAS MISSION                            --
casMissionTarget = nil
casKillsByPlayer = {}
casTargetKills = 0
casWinner = nil
casMissionCooldownUntil = 0

mc:trackMission({
	title = function(T) return LT(T):Get("MISSION_CAS_TITLE") end,
	description = function(T)
		if not next(casKillsByPlayer) then
			return LT(T):Format("MISSION_CAS_DESCRIPTION_EMPTY", casTargetKills)
		else
			local scoreboard = LT(T):Get("MISSION_CAP_SCOREBOARD_HEADER")
			for playerName, kills in pairs(casKillsByPlayer) do
				scoreboard = scoreboard..string.format('%s: %d\n', playerName, kills)
			end
			return LT(T):Format("MISSION_CAS_DESCRIPTION_WITH_SCORE", casTargetKills, scoreboard)
		end
	end,
	messageStart = function()
		return L10N:Format("MISSION_CAS_START", casTargetKills)
	end,
	messageEnd = '',
	startAction = function()
		if not missionCompleted then trigger.action.outSoundForCoalition(2,'ding.ogg') end
	end,
   endAction = function()
        if casWinner then
            local reward = casTargetKills*30
            local pname  = casWinner
            bc:addContribution(pname, 2, reward)
            local jp = bc.jointPairs and bc.jointPairs[pname]
            if jp and bc:_jointPartnerAlive(pname) and bc:_jointPartnerAlive(jp) and bc.playerContributions[2][jp] ~= nil then
                bc:addContribution(jp, 2, reward)
            	bc:addTempStat(jp,'CAS mission (Joint mission)',1)
				bc:addTempStat(pname,'CAS mission (Joint mission)',1)
				trigger.action.outTextForCoalition(2,L10N:Format("MISSION_CAS_COMPLETED_JOINT", pname, jp, reward),20)
                local jgn = bc.groupNameByPlayer[jp]
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
            	bc:addTempStat(pname,'CAS mission',1)
				trigger.action.outTextForCoalition(2,L10N:Format("MISSION_CAS_COMPLETED_SOLO", pname, reward),20)
			end
            
            casMissionCooldownUntil = timer.getTime()+900
        end
        casMissionTarget  = nil
        casKillsByPlayer  = {}
        casWinner         = nil
        casTargetKills    = 0
        if not missionCompleted then trigger.action.outSoundForCoalition(2,'cancel.ogg') end
    end,
	isActive = function()
		if not casMissionTarget then return false end
		return true
	end
})
--                    End of CAS MISSION                           --
---------------------------------------------------------------------

---------------------------------------------------------------------
--                     		ESCORT MISSION                         --

function generateEscortMission(zoneName, groupName, groupID, group, mission)
    local mission = mission or missions[zoneName]
    if not mission then return false end

    missionGroupIDs[zoneName] = missionGroupIDs[zoneName] or {}
    missionGroupIDs[zoneName][groupID] = {
        groupID = groupID,
        group = group
    }
	if IsGroupActive(mission.missionGroup) then
		trigger.action.outSoundForGroup(groupID, "ding.ogg")
		trigger.action.outTextForGroup(groupID, L10N:FormatForGroup(groupID, "SYRIA_ESCORT_ACTIVE_PENDING", mission.zone, mission.TargetZone), 30)
        return
    end
	if mc.missionFlags[zoneName] then
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, L10N:FormatForGroup(groupID, "MISSION_ESCORT_SPECIAL_AVAILABLE", mission.zone, mission.TargetZone), 30)
		return 
	end

    mc:trackMission({
        MainTitle = function(T) return LT(T):Get("MISSION_ESCORT_TITLE") end,
        title = function(T) return LT(T):Get("MISSION_ESCORT_TITLE") end,
		titleBefore = function(self)
			self.notified = true
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, L10N:FormatForGroup(groupID, "MISSION_ESCORT_SPECIAL_AVAILABLE", mission.zone, mission.TargetZone), 30)
		 end,
        description = function(T) return LT(T):Format("MISSION_ESCORT_DESCRIPTION", mission.TargetZone) end,
        isEscortMission = true,
        accept = false,
        missionGroup = mission.missionGroup,
        zoneName = zoneName,
        messageStart = function() return L10N:Format("MISSION_ESCORT_START", mission.TargetZone) end,
		missionFail = function(self)
		self.accept = false
		if not IsGroupActive(mission.missionGroup) then
			mc.missionFlags[zoneName] = nil
			if missionGroupIDs[zoneName] and next(missionGroupIDs[zoneName]) then
				for groupName, data in pairs(missionGroupIDs[zoneName]) do
					local groupID = data.groupID
					local group = data.group
					trigger.action.outSoundForGroup(groupID, "cancel.ogg")
					trigger.action.outTextForGroup(groupID, L10N:GetForGroup(groupID, "SYRIA_ESCORT_FAILED_RETRY"), 30)
					removeMissionMenuForAll(mission.zone, groupID)
					if trackedGroups[groupName] then
						trackedGroups[groupName] = nil
						--handleMission(zoneName, groupName, groupID, group)
					end
				end
			else
				trigger.action.outSoundForCoalition(2, "cancel.ogg")
				trigger.action.outTextForCoalition(2, L10N:Get("SYRIA_ESCORT_FAILED"), 30)
				removeMissionMenuForAll(mission.zone, nil, true)
				destroyGroupIfActive(mission.missionGroup)
			end
			return true
		end
		return false
		end,
		startOver = function(self)
			timer.scheduleFunction(function()
		if missionGroupIDs[zoneName] then
			for groupName, data in pairs(missionGroupIDs[zoneName]) do
				local groupID = data.groupID
				local group = data.group
				handleMission(zoneName, groupName, groupID, group)
				return nil
			end
		end	
			end, nil, timer.getTime() + 10)
		end,
        startAction = function() return IsGroupActive(mission.missionGroup) end,
		endAction = function()
			local targetZone = bc:getZoneByName(mission.TargetZone)
			if targetZone.side == 2 and targetZone.active then
				local reward   = 1000
				local playlist = {}
				if missionGroupIDs[zoneName] then
					for _, data in pairs(missionGroupIDs[zoneName]) do
						local grp = data.group
						if grp and grp:isExist() then
							for _, u in pairs(grp:getUnits()) do
								local pl = u:getPlayerName()
								if pl and pl ~= "" then
									playlist[pl] = true
								end
							end
						end
					end
				end
				local cnt   = 0
				local names = {}
				for pl in pairs(playlist) do
					cnt = cnt + 1
					names[#names + 1] = pl
				end
				local share = cnt > 0 and math.floor(reward / cnt) or reward
				if cnt > 0 then
					for pl in pairs(playlist) do
						if bc.playerContributions[2][pl] ~= nil then
							bc:addContribution(pl, 2, share)
							bc:addTempStat(pl,'Escort Mission',1)
						end
					end
				else
					bc:addFunds(2, reward)
				end
				if missionGroupIDs[zoneName] then
					for groupName, data in pairs(missionGroupIDs[zoneName]) do
						local groupID = data.groupID
						local grp     = data.group
						if grp and grp:isExist() then
							removeMissionMenuForAll(mission.zone, groupID)
						end
						if trackedGroups[groupName] then
							trackedGroups[groupName] = nil
						end
						destroyGroupIfActive(mission.missionGroup)
						timer.scheduleFunction(function()
							handleMission(mission.TargetZone, groupName, groupID, grp)
						end, nil, timer.getTime() + 30)
					end
				else
					removeMissionMenuForAll(mission.zone, nil, true)
					destroyGroupIfActive(mission.missionGroup)
				end
				mc.missionFlags[zoneName] = nil
				local msg
				if cnt > 1 then
					msg = L10N:Format("SYRIA_ESCORT_COMPLETED_MULTI", table.concat(names, ", "), share)
				elseif cnt == 1 then
					msg = L10N:Format("SYRIA_ESCORT_COMPLETED_SOLO", names[1], reward)
				else
					msg = L10N:Format("SYRIA_ESCORT_COMPLETED_NONE", reward)
				end
				trigger.action.outSoundForCoalition(2, "ding.ogg")
				trigger.action.outTextForCoalition(2, msg, 20)
				return true
			end
			return false
		end,
        isActive = function()
            local targetZone = bc:getZoneByName(mission.TargetZone)
            if targetZone.side ~= 2 and targetZone.active and not targetZone.suspended then
                return true
            end
            return false
        end,
        returnAccepted = function(self)
            if not self.accept then return false end
            return IsGroupActive(mission.missionGroup)
        end,
    })

    mc.missionFlags[zoneName] = true
	mc.escortMissionGenerated = true
end

---------------------------------------------------------------------
--                     END OF ESCORT MISSION                       --

---------------------------------------------------------------------
--                      RUNWAY STRIKE MISSION                     --

mc:trackMission({
    title=function(T) return LT(T):Get("MISSION_BOMB_RUNWAY_TITLE") end,
    description=function(T)
      local wp=WaypointList[runwayTargetZone] or ""
      if #runwayNames>1 then
        return LT(T):Format("MISSION_BOMB_RUNWAY_DESC_ALL", runwayTargetZone, wp)
      else
        return LT(T):Format("MISSION_BOMB_RUNWAY_DESC_ONE", runwayTargetZone, wp)
      end
    end,
    messageStart=function()
    local wp=WaypointList[runwayTargetZone] or ""
      if #runwayNames>1 then
        return L10N:Format("MISSION_BOMB_RUNWAY_START_ALL", runwayTargetZone, wp)
      else
        return L10N:Format("MISSION_BOMB_RUNWAY_START_ONE", runwayTargetZone, wp)
      end
    end,
	messageEnd = function()
		trigger.action.outSoundForCoalition(2,'cancel.ogg')
		if runwayTargetZone then
			if runwayCompleted then
				local cred = (need and need>1) and 200 or 100
				if bomberName and runwayPartnerName then
					return L10N:Format("SYRIA_BOMB_RUNWAY_END_JOINT", runwayTargetZone, bomberName, runwayPartnerName, cred)
				elseif bomberName then
					return L10N:Format("SYRIA_BOMB_RUNWAY_END_SOLO", runwayTargetZone, bomberName, cred)
				else
					return L10N:Format("SYRIA_BOMB_RUNWAY_END_COMPLETED", runwayTargetZone)
				end
			else
				return L10N:Format("SYRIA_BOMB_RUNWAY_END_CANCELED_ZONE", runwayTargetZone)
			end
		else
			return L10N:Get("SYRIA_BOMB_RUNWAY_CANCELED")
		end
	end,
	startAction = function()
	bc:addMissionTag(runwayTargetZone, "Bomb runway")
	bc:refreshZoneLabel(runwayTargetZone)
	if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
		trigger.action.outSoundForCoalition(2, "ding.ogg")
	end
	end,
endAction = function()
    if RunwayHandler then
        RunwayHandler:UnHandleEvent(EVENTS.Shot)
        RunwayHandler = nil
        runwayMission = nil
    end
    if runwayTargetZone then
        RUNWAY_ZONE_COOLDOWN[runwayTargetZone] = timer.getTime() + 2700
        bc:removeMissionTag(runwayTargetZone, "Bomb runway")
        bc:refreshZoneLabel(runwayTargetZone)
    end
    runwayCooldown = timer.getTime() + 600
    runwayTargetZone, bomberName, runwayTarget = nil, nil, nil
end,
	isActive = function()
        if not runwayMission then return false end
        local targetzn = bc:getZoneByName(runwayTargetZone)
        return targetzn and targetzn.side == 1
    end
})
---------------------------------------------------------------------
--                 END OF RUNWAY STRIKE MISSION                   --

seadTarget = nil
function generateSEADMission()
    if seadTarget then return true end
    local attackAnchors = _getAttackAnchorZones()
    if #attackAnchors == 0 then return false end

    local function isSEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and (lname:find('ivalo') or lname:find('banak'))
    end

	local validSEADZones = {}
	for _, zone in ipairs(bc.zones) do
		local znB = zone.zone
		local minDist = znB and _minDistanceToAttackAnchors(attackAnchors, znB) or nil
		if isSEADZone(zone) and bc:HasSeadTargets(zone.zone) and minDist and minDist <= 24000 then
			table.insert(validSEADZones, zone.zone)
		end
	end

    if #validSEADZones == 0 then
        for _, connection in ipairs(bc.connections) do
			local from, to = bc:getConnectionZones(connection)

            if from and to and from.side ~= to.side and from.side ~= 0 and to.side ~= 0 and
			((not to.suspended) or from.suspended) then
                if isSEADZone(from) and bc:HasSeadTargets(from.zone) then
                    table.insert(validSEADZones, from.zone)
                end
                if isSEADZone(to) and bc:HasSeadTargets(to.zone) then
                    table.insert(validSEADZones, to.zone)
                end
            end
        end
    end

    if #validSEADZones == 0 then return false end

    seadTarget = validSEADZones[math.random(#validSEADZones)]
    return true
end

mc:trackMission({
    title = function(T) return LT(T):Format("MISSION_SEAD_TITLE", seadTarget) end,
    description = function(T) return LT(T):Format("MISSION_SEAD_DESCRIPTION", seadTarget) end,
    messageStart = function() return L10N:Format("MISSION_SEAD_START", seadTarget) end,
    messageEnd = function() return L10N:Get("MISSION_SEAD_END") end,
    startAction = function()
        local MissionType = "SEAD"
        bc:addMissionTag(seadTarget, MissionType)
        bc:refreshZoneLabel(seadTarget)
        if not missionCompleted then trigger.action.outSoundForCoalition(2,"ding.ogg") end
    end,
    endAction = function()
        local MissionType = "SEAD"
        bc:removeMissionTag(seadTarget, MissionType)
        bc:refreshZoneLabel(seadTarget)
        seadTarget = nil
        if not missionCompleted then trigger.action.outSoundForCoalition(2,"cancel.ogg") end
    end,
    isActive = function()
        if not seadTarget then return false end
        local zn = bc:getZoneByName(seadTarget)
        return zn and zn.side == 1 and not zn.suspended and bc:HasSeadTargets(seadTarget)
    end
})

deadTarget = nil
function generateDEADMission()
    if deadTarget then return true end
    if seadTarget then return true end
    local attackAnchors = _getAttackAnchorZones()
    if #attackAnchors == 0 then return false end

    local function isDEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and (lname:find('ivalo') or lname:find('banak'))
    end

    local validDEADZones = {}
    for _, zone in ipairs(bc.zones) do
        local znB = zone.zone
        local minDist = znB and _minDistanceToAttackAnchors(attackAnchors, znB) or nil
        if isDEADZone(zone) and not bc:HasSeadTargets(zone.zone) and minDist and minDist <= 24000 then
            table.insert(validDEADZones, zone.zone)
        end
    end

    if #validDEADZones == 0 then
        for _, connection in ipairs(bc.connections) do
            local from, to = bc:getConnectionZones(connection)
            if from and to and from.side ~= to.side and from.side ~= 0 and to.side ~= 0 and
               ((not to.suspended) or from.suspended) then
                if isDEADZone(from) and not bc:HasSeadTargets(from.zone) then
                    table.insert(validDEADZones, from.zone)
                end
                if isDEADZone(to) and not bc:HasSeadTargets(to.zone) then
                    table.insert(validDEADZones, to.zone)
                end
            end
        end
    end

    if #validDEADZones == 0 then return false end

    deadTarget = validDEADZones[math.random(#validDEADZones)]
    return true
end

mc:trackMission({
    title = function(T) return LT(T):Format("MISSION_DEAD_TITLE", deadTarget) end,
    description = function(T) return LT(T):Format("MISSION_DEAD_DESCRIPTION", deadTarget) end,
    messageStart = function() return L10N:Format("MISSION_DEAD_START", deadTarget) end,
    messageEnd = function() return L10N:Get("MISSION_DEAD_END") end,
    startAction = function()
        local MissionType = "DEAD"
        bc:addMissionTag(deadTarget, MissionType)
        bc:refreshZoneLabel(deadTarget)
        if not missionCompleted then trigger.action.outSoundForCoalition(2,"ding.ogg") end
    end,
    endAction = function()
        local MissionType = "DEAD"
        bc:removeMissionTag(deadTarget, MissionType)
        bc:refreshZoneLabel(deadTarget)
        deadTarget = nil
        if not missionCompleted then trigger.action.outSoundForCoalition(2,"cancel.ogg") end
    end,
    isActive = function()
        if not deadTarget then return false end
        local zn = bc:getZoneByName(deadTarget)
        return zn and zn.side == 1 and not zn.suspended and not bc:HasSeadTargets(deadTarget)
    end
})

---------------------------------------------------------------------
--                         RECON MISSION                           --
reconMissionTarget = nil
reconMissionWinner = nil
reconMissionCooldownUntil = 0
reconMissionCompleted = false
reconMissionCompletedTarget = nil

mc:trackMission({
	title = function(T)
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return LT(T):Get("SYRIA_DYNAMIC_RECON_TITLE_EMPTY") end
		local wp = WaypointList[target] or ""
		return LT(T):Format("SYRIA_DYNAMIC_RECON_TITLE", target, wp)
	end,
	description = function(T)
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return LT(T):Get("SYRIA_DYNAMIC_RECON_DESC_EMPTY") end
		return LT(T):Format("SYRIA_DYNAMIC_RECON_DESC", target)
	end,
	messageStart = function()
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return L10N:Get("SYRIA_DYNAMIC_RECON_START_EMPTY") end
		local wp = WaypointList[target] or ""
		return L10N:Format("SYRIA_DYNAMIC_RECON_START", target, wp)
	end,
	messageEnd = function()
		if reconMissionCompleted and reconMissionCompletedTarget and reconMissionWinner then
			return L10N:Format("SYRIA_DYNAMIC_RECON_END_BY", reconMissionCompletedTarget, reconMissionWinner)
		end
		if reconMissionCompletedTarget then
			return L10N:Format("SYRIA_DYNAMIC_RECON_END_TARGET", reconMissionCompletedTarget)
		end
		return L10N:Get("SYRIA_DYNAMIC_RECON_END")
	end,
	startAction = function()
		reconMissionCompleted = false
		reconMissionWinner = nil
		reconMissionCompletedTarget = nil

		bc:addMissionTag(reconMissionTarget, "Recon")
		bc:refreshZoneLabel(reconMissionTarget)

		startReconMissionZoneTracker(reconMissionTarget)
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "ding.ogg")
		end
	end,
	endAction = function()
		local target = reconMissionCompletedTarget or reconMissionTarget
		if target then
			stopReconMissionZoneTracker(target)
			bc:removeMissionTag(target, "Recon")
			bc:refreshZoneLabel(target)
		end

		if reconMissionCompleted and target and reconMissionWinner then
			local reward = 100
			bc:addContribution(reconMissionWinner, 2, reward)
			local jp = bc.jointPairs and bc.jointPairs[reconMissionWinner]
			if jp and bc:_jointPartnerAlive(reconMissionWinner) and bc:_jointPartnerAlive(jp) and bc.playerContributions[2][jp] ~= nil then
				bc:addContribution(jp, 2, reward)
				bc:addTempStat(jp, "Recon mission (Joint mission)", 1)
				bc:addTempStat(reconMissionWinner, "Recon mission (Joint mission)", 1)
				trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_DYNAMIC_RECON_COMPLETED_JOINT", reconMissionWinner, jp, target, reward), 20)
				local jgn = bc.groupNameByPlayer[jp]
				local jgr = Group.getByName(jgn)
				if jgr then
					local ju = jgr:getUnit(1)
					if ju and not Utils.isInAir(ju) then
						SCHEDULER:New(nil, function()
							if ju and ju:isExist() then
								world.onEvent({id=world.event.S_EVENT_LAND,time=timer.getAbsTime(),initiator=ju,initiatorPilotName=jp,initiator_unit_type=ju:getTypeName(),initiator_coalition=ju:getCoalition(),skipRewardMsg=true})
							end
						end, {}, 5, 0)
					end
				end
			else
				bc:addTempStat(reconMissionWinner, "Recon mission", 1)
				trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_DYNAMIC_RECON_COMPLETED_SOLO", reconMissionWinner, target, reward), 20)
			end
			startZoneIntel(target, 10 * 60)
			reconMissionCooldownUntil = timer.getTime() + 900
		end

		reconMissionTarget = nil
		reconMissionWinner = nil
		reconMissionCompleted = false
		reconMissionCompletedTarget = nil

		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
	isActive = function()
		if reconMissionCompleted then return false end
		if not reconMissionTarget then return false end
		local targetzn = bc:getZoneByName(reconMissionTarget)
		return targetzn and targetzn.side == 1 and targetzn.active and not targetzn.suspended
	end
})
--                    End of RECON MISSION                         --
---------------------------------------------------------------------

timer.scheduleFunction(function(_, time)
	if generateCaptureMission() then
		return time+300
	else
		return time+120
	end
end, {}, timer.getTime() + 20)

timer.scheduleFunction(function(_, time)
	if generateAttackMission() then
		return time+300
	else
		return time+120
	end
end, {}, timer.getTime() + 35)

timer.scheduleFunction(function(_, time)
	if generateSEADMission() then
		return time+300
	else
		return time+120
	end
end, {}, timer.getTime() + 120)
timer.scheduleFunction(function(_, time)
	if generateDEADMission() then
		return time+300
	else
		return time+120
	end
end, {}, timer.getTime() + 140)
timer.scheduleFunction(function(_, time)
	if checkAndGenerateCASMission() then
		return time+300
	else
		return time+120
	end
end, {}, timer.getTime() + 180)
timer.scheduleFunction(function(_, time)
	if checkAndGenerateReconMissionV2() then
		return time+300
	else
		return time+120
	end
end, {}, timer.getTime() + 200)
timer.scheduleFunction(function(_, time)
	if generateSupplyMission() then
		return time+300
	else
		return time+120
	end
end, {}, timer.getTime() + 60)
timer.scheduleFunction(function(_,time)
   if checkAndGenerateCAPMission() then
		return time+300
	else
		return time+120
	end
end, {}, timer.getTime() + 480)
timer.scheduleFunction(function(_,time)
    if generateRunwayStrikeMission() then
        return time+300
    else
        return time+120
    end
end,{},timer.getTime()+210)
mc:init()
----------------------- FLAGS --------------------------
function checkZoneFlags()
    --Kandalaksha bridge
    if trigger.misc.getUserFlag('120') == 1 and not CustomFlags[20] then
        CustomFlags[20] = true
    end
    if trigger.misc.getUserFlag('121') == 1 and not CustomFlags[21] then
        CustomFlags[21] = true
    end
    --Olenya supply point
    if trigger.misc.getUserFlag('141') == 1 and not CustomFlags[41] then
        CustomFlags[41] = true
    end
    if trigger.misc.getUserFlag('142') == 1 and not CustomFlags[42] then
        CustomFlags[42] = true
    end
    if trigger.misc.getUserFlag('143') == 1 and not CustomFlags[43] then
        CustomFlags[43] = true
    end
    if trigger.misc.getUserFlag('144') == 1 and not CustomFlags[44] then
        CustomFlags[44] = true
    end
    if trigger.misc.getUserFlag('145') == 1 and not CustomFlags[45] then
        CustomFlags[45] = true
    end
    if trigger.misc.getUserFlag('146') == 1 and not CustomFlags[46] then
        CustomFlags[46] = true
    end
    if (trigger.misc.getUserFlag('147') == 1) and not CustomFlags[47] then
        CustomFlags[47] = true
    end
    if (trigger.misc.getUserFlag('148') == 1) and not CustomFlags[48] then
        CustomFlags[48] = true
    end
     --calculate supply level
    supplypenalty = 0
    if (not zones.apatity.wasBlue) or (not zones.kovdor.wasBlue) then
      if CustomFlags[20] == true then --road bridge
        supplypenalty = supplypenalty + 0.1
      end
      if CustomFlags[21] == true then --railroad bridge
        supplypenalty = supplypenalty + 0.1
      end
      if (CustomFlags[20] == true) and (CustomFlags[21] == true) then --both bridges will get an additional penalty as there is no other connection
        supplypenalty = supplypenalty + 0.2
      end
    else --supply axis is dead because kovdor and apatity got captured
      supplypenalty = supplypenalty + 0.5
    end
    --Reserver
    if CustomFlags[44] == true then
      supplypenalty = supplypenalty + 0.05
    end
    --Loukhi
    if CustomFlags[45] == true then
      supplypenalty = supplypenalty + 0.1
    end
    --Beloye More Pumping Station
    if CustomFlags[46] == true then
      supplypenalty = supplypenalty + 0.1
    end
    --Reserve
    if CustomFlags[47] == true then
      supplypenalty = supplypenalty + 0.05
    end
    if CustomFlags[48] == true then
      supplypenalty = supplypenalty + 0.05
    end
    --special zones
    if zones.zelenoborskij.side ~= 1 then
      supplypenalty = supplypenalty + 0.1
    end
    if zones.laplandiya.side ~= 1 then
      supplypenalty = supplypenalty + 0.1
    end
    if (zones.hiddenMurmanskSea.side ~= 1) then
        supplypenalty = supplypenalty + 0.2
    end
    if zones.kilpyavrstorage.side ~= 1 then
      supplypenalty = supplypenalty + 0.1
    end
    if zones.afrikandastorage.side ~= 1 then
      supplypenalty = supplypenalty + 0.1
    end
    if zones.koashvastorage.side ~= 1 then
      supplypenalty = supplypenalty + 0.2
    end
    if zones.pyaozerskystorage.side ~= 1 then
      supplypenalty = supplypenalty + 0.1
    end
    if zones.gadzhiyevoshipyard.side ~= 1 then
      supplypenalty = supplypenalty + 0.1
    end
    if CustomFlags['KandalakshaAluminium'] then
        supplypenalty = supplypenalty + 0.2
    end
    --calculate penalty
    spawnfactor        = 1 + supplypenalty -- 100 % supply: No delay, penalty gets added up on top
    spawnfactor_patrol = 1 + (supplypenalty / 2) -- 100 % supply: No delay, penalty gets added up on top. For patrol, the effect is halved
    
    GlobalSettings.defaultRespawns[1]['supply'] = { dead=60*60*spawnfactor       , hangar=30*60*spawnfactor,        preparing=5*60*spawnfactor,      }
    GlobalSettings.defaultRespawns[1]['attack'] = { dead=40*60*spawnfactor       , hangar=10*60*spawnfactor,        preparing=5*60*spawnfactor,      }
    GlobalSettings.defaultRespawns[1]['patrol'] = { dead=30*60*spawnfactor_patrol, hangar=10*60*spawnfactor_patrol, preparing=5*60*spawnfactor_patrol}
    --trigger.action.setUserFlag('100',supplypenalty) --this flag contains the current supply level if necessary   
    --local supplymessage = string.format("current supply strength: %s", supplypenalty)
    --trigger.action.outText(supplymessage , 15 , false)
    if CustomFlags['LogisticPenalty'] ~= supplypenalty then
       CustomFlags['LogisticPenalty'] = supplypenalty
       CustomFlags['Spawnfactor']     = spawnfactor
    end
       
    -----------------------check if player is in zone------------------------------
    --this is done here to save performance as there are only few players but we don't have have to go through all of the AI units
    local bluePlayers = coalition.getPlayers(2)
    --local interceptzone = trigger.misc.getZone('LogisticsInterceptZone')
    local isInZone = false
    local zone = ZONE:New('LogisticsInterceptZone')
    for i = 1, #bluePlayers do
        --local playerunit = Unit.getByName(bluePlayers[i])
		if zone and zone:IsVec3InZone(bluePlayers[i]:getPosition().p) then
          isInZone = true
          --env.info('Attack on logistics detected')
          break
        end
    end
    trigger.action.setUserFlag('LogisticsInterceptFlag', isInZone)
    if not isInZone then
      trigger.action.setUserFlag('LogisticsInterceptWasActive', false) --if no one is in the zone, it will be possible to spawn the intercept (since it is not inside the normal foothold groups, to avoid it re-spawns instantly)
    end
    zone = ZONE:New('SeveromorskInterceptZone')
    for i = 1, #bluePlayers do
        --local playerunit = Unit.getByName(bluePlayers[i])
		if zone and zone:IsVec3InZone(bluePlayers[i]:getPosition().p) then
          isInZone = true
          --env.info('Attack on logistics detected')
          break
        end
    end
    trigger.action.setUserFlag('SeveromorskInterceptFlag', isInZone)
end
timer.scheduleFunction(function()
    --local supplymessage = string.format("current supply factor: %s", spawnfactor)
    --trigger.action.outText(supplymessage , 15 , false)
    checkZoneFlags()
    return timer.getTime() + 30
end, {}, timer.getTime() + 7)


-------------------------- END OF FLAGS --------------------------

--------------------------Asset spawn-----------------------------
function spawnIntercepts()
    --Monchegorsk intercept for Loukhi / Kandalaksha
    if (trigger.misc.getUserFlag('LogisticsInterceptFlag') == 1) and (trigger.misc.getUserFlag('LogisticsInterceptWasActive') == 0) and (zones.monchegorsk.side == 1) then
      local grname = "Monchegorsk-InterceptLogistics-red"
      local dice = math.random(1, 100)
      if dice > 50 then
        grname = "Monchegorsk-InterceptLogistics2-red"
      end
      local gr = Group.getByName(grname)
      env.info(grname)
      if not Utils.isGroupActive(gr) then
        RespawnGroup(grname)
        trigger.action.setUserFlag('LogisticsInterceptWasActive', true)
        env.info("Logistics intercept flight spawned")
      end
    end
end

timer.scheduleFunction(function()
    spawnIntercepts()
    return timer.getTime() + 30
end, {}, timer.getTime() + 9)

function SpawnFriendlyAssets()
if not zones.hiddenKemiRoadblock.firstCaptureByRed and zones.kemitornio.wasBlue then
		zones.hiddenKemiRoadblock:MakeZoneRedAndUpgrade()
	end
end
timer.scheduleFunction(SpawnFriendlyAssets, {}, timer.getTime() + 5)

buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end

airbaseStatics = {

	["Luspa"] = {"Luspacenterammo", "Luspacenterfuel", "Luspacentertent1", "Luspacentertent2", "Luspacentertent3", "Luspacentertent4", "Luspacenter", "Luspacenterwind"},
    ["Kvikkjokk"] = {"Kvikkjokkammo", "Kvikkjokkfuel", "Kvikkjokktent1", "Kvikkjokktent2", "Kvikkjokktent3", "Kvikkjokktent4", "Kvikkjokkcenter", "Kvikkjokkwind"},
    ["BergsBasen"] = {"BergsBasenammo", "BergsBasenfuel", "BergsBasentent1", "BergsBasentent2", "BergsBasentent3", "BergsBasentent4", "BergsBasencenter", "BergsBasenwind"},
	["Skogsbasen"] = {"Skogsbasenammo", "Skogsbasenfuel", "Skogsbasentent1", "Skogsbasentent2", "Skogsbasentent3", "Skogsbasentent4", "Skogsbasencenter", "Skogsbasenwind"},
	["Guovdageaidnu"] = {"Guovdageaidnuammo", "Guovdageaidnufuel", "Guovdageaidnutent1", "Guovdageaidnutent2", "Guovdageaidnutent3", "Guovdageaidnutent4", "Guovdageaidnucenter", "Guovdageaidnuwind"},
	["Kalix"] = {"Kalixammo", "Kalixfuel", "Kalixtent1", "Kalixtent2", "Kalixtent3", "Kalixtent4", "Kalixcenter", "KalixWind"},
	["Gallivare"] = {"Gallivareammo", "Gallivarefuel", "Gallivaretent1", "Gallivaretent2", "Gallivaretent3", "Gallivaretent4", "Gallivarecenter", "GallivareWind"},
	["Kandalaksha"] = {"Kandalakshaammo", "Kandalakshafuel", "Kandalakshatent1", "Kandalakshatent2", "Kandalakshatent3", "Kandalakshatent4", "Kandalakshacenter", "Kandalakshawind"},
	["Apatity"] = {"Apatityammo", "Apatityfuel", "Apatitytent1", "Apatitytent2", "Apatitytent3", "Apatitytent4", "Apatitycenter", "Apatitywind"},
	["Loukhi"] = {"Loukhiammo", "Loukhifuel", "Loukhitent1", "Loukhitent2", "Loukhitent3", "Loukhitent4", "Loukhicenter", "Loukhiwind"},
	["Kovdor"] = {"Kovdorammo", "Kovdorfuel", "Kovdortent1", "Kovdortent2", "Kovdortent3", "Kovdortent4", "Kovdorcenter", "Kovdorcwind"},
	["Zapolyarnyy"] = {"Zapolyarnyyammo", "Zapolyarnyyfuel", "Zapolyarnyytent1", "Zapolyarnyytent2", "Zapolyarnyytent3", "Zapolyarnyytent4", "Zapolyarnyycenter", "Zapolyarnyywind"},
	["Karasjok"] = {"Karasjokammo", "Karasjokfuel", "Karasjoktent1", "Karasjoktent2", "Karasjoktent3", "Karasjoktent4", "Karasjokwind", "Karasjokcenter"},
	--["Ivalo FARP"] = {"Ivaloammo", "Ivalofuel", "Ivalotent1", "Ivalotent2", "Ivalotent3", "Ivalotent4", "Ivalowind", "Ivalocenter"},
	["Kelloselka"] = {"Kelloselkaammo", "Kelloselkafuel", "Kelloselkatent1", "Kelloselkatent2", "Kelloselkatent3", "Kelloselkatent4", "Kelloselkawind", "Kelloselkacenter"},
	["Buolbmat"] = {"Buolbmatammo", "Buolbmatfuel", "Buolbmattent1", "Buolbmattent2", "Buolbmattent3", "Buolbmattent4", "Buolbmatwind", "Buolbmatcenter"},
	["Tervola"] = {"Tervolaammo", "Tervolafuel", "Tervolatent1", "Tervolatent2", "Tervolatent3", "Tervolatent4", "Tervolawind", "Tervolacenter"},
	["Maaninkavaara"] = {"Maaninkavaaraammo", "Maaninkavaarafuel", "Maaninkavaaratent1", "Maaninkavaaratent2", "Maaninkavaaratent3", "Maaninkavaaratent4", "Maaninkavaarawind", "Maaninkavaaracenter"},
	["Savukoski"] = {"Savukoskiammo", "Savukoskifuel", "Savukoskitent1", "Savukoskitent2", "Savukoskitent3", "Savukoskitent4", "Savukoskiwind", "Savukoskicenter"},
	["SkogsFARP1"] = {"SkogsFARP_1ammo", "SkogsFARP_1fuel", "SkogsFARP_1tent1", "SkogsFARP_1tent2", "SkogsFARP_1tent3", "SkogsFARP_1tent4", "SkogsFARP_1wind"},
	["SkogsFARP2"] = {"SkogsFARP_2ammo", "SkogsFARP_2fuel", "SkogsFARP_2tent1", "SkogsFARP_2tent2", "SkogsFARP_2tent3", "SkogsFARP_2tent4", "SkogsFARP_2wind"},
	["SkogsFARP3"] = {"SkogsFARP_3ammo", "SkogsFARP_3fuel", "SkogsFARP_3tent1", "SkogsFARP_3tent2", "SkogsFARP_3tent3", "SkogsFARP_3tent4", "SkogsFARP_3wind"},
	["SkogsFARP4"] = {"SkogsFARP_4ammo", "SkogsFARP_4fuel", "SkogsFARP_4tent1", "SkogsFARP_4tent2", "SkogsFARP_4tent3", "SkogsFARP_4tent4", "SkogsFARP_4wind"},
    ["Alakourtti"] = {"Alakourtticenter-5", "Alakourtticenter-6", "ThouShaltNotDie"}
    --["Prirechnyi"] = {"Prirechnyi-1", "Prirechnyi-2", "Prirechnyi-3"}

}
