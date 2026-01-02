env.info("Mission Setup : is loading.")

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
    Banak                   = ' (4)',
    Buolbmat                = ' (5)',
    Kirkenes                = ' (6)',
    Karasjok                = ' (7)',
    Guovdageaidnu           = ' (8)',
    Luspa                   = ' (9)',
    Kiruna                  = ' (10)',
    Kalixfors               = ' (11)',
    Skogsbasen              = ' (12)',
    BergsBasen              = ' (13)',
    Kvikkjokk               = ' (14)',
    Gallivare               = ' (15)',
    Jokkmokk                = ' (16)',
    Vidsel                  = ' (17)',
    Kallax                  = ' (18)',
    Kalix                   = ' (19)',
    KemiTornio              = ' (20)',
    Tervola                 = ' (21)',
    Rovaniemi               = ' (22)',
    Vuojarvi                = ' (23)',
    Savukoski               = ' (24)',
    Kelloselka              = ' (25)',
    Maaninkavaara           = ' (26)',
    Kuusamo                 = ' (27)',
    Kittila                 = ' (28)',
    Ivalo                   = ' (29)',
    Zapolyarnyy             = ' (30)',
    Severomorsk1            = ' (31)',
    Severomorsk3            = ' (32)',
    MurmanskInternational   = ' (33)',
    Prirechnyi              = ' (34)',
    Olenya                  = ' (35)',
    Monchegorsk             = ' (36)',
    Apatity                 = ' (37)',
    Kovdor                  = ' (38)',
    Alakourtti              = ' (39)',
    SkogsFARP1              = '',
    SkogsFARP2              = ''
}

flavor = {
    --redcarrier = 'Enemy carrier zone',
    --bluecarrier = 'WPT \nStart zone',
    
    bodo                  = 'WPT 1\nAirfield was used for military aviation up to 2022.\nNice city in western Norway.',
    andoya                = 'WPT 2\nNearly started WW3 on the 25th of January 1995 with a scientific satellite.\nLuckily that did not happen.',
    bardufoss             = 'WPT 3\nNorways air force aviation school is here.\nWell known among pilots',
    banak                 = 'WPT 4\nAlso knows as Lakselv.\nBeautiful nature.',
    buolbmat              = 'WPT 5\n',
    kirkenes              = 'WPT 6\nNice city on norways most northeastern edge\nRecommended for holidays.',
    karasjok              = 'WPT 7\n',
    guovdageaidnu         = 'WPT 8\n',
    luspa                 = 'WPT 9\n',
    kiruna                = 'WPT 10\nA mining city. Is currently being moved.\nYes. House by house.\nBeautiful nature.\n',
    kalixfors             = 'WPT 11\nMilitary training area.',
    skogsbasen            = 'WPT 12\n',
    bergsbasen            = 'WPT 13\n',
    kvikkjokk             = 'WPT 14\n',
    gallivare             = 'WPT 15\nHome of the band Hooja.',
    jokkmokk              = 'WPT 16\nCenter of the samish population in Lapland.\nAnd a training place for the swedish airforce of course.',
    vidsel                = 'WPT 17\nHome of the Vidsel test range.',
    kallax                = 'WPT 18\nHome of the F21 squadron.',
    kalix                 = 'WPT 19\nSmall city in one of the most\nbeautiful places on earth. Cold though.',
    kemiTornio            = 'WPT 20\n',
    tervola               = 'WPT 21\n',
    rovaniemi             = 'WPT 22\nHome of Santa. Google it.',
    vuojarvi              = 'WPT 23\n',
    savukoski             = 'WPT 24\n',
    kelloselka            = 'WPT 25\n',
    maaninkavaara         = 'WPT 26\n',
    kuusamo               = 'WPT 27\n',
    kittila               = 'WPT 28\n',
    ivalo                 = 'WPT 29\n',
    zapolyarnyy           = 'WPT 30\n',
    severomorsk1          = 'WPT 31\n',
    severomorsk3          = 'WPT 32\n',
    murmanskinternational = 'WPT 33\n',
    prirechnyi            = 'WPT 34\n',
    olenya                = 'WPT 35\n',
    monchegorsk           = 'WPT 36\n',
    apatity               = 'WPT 37\n',
    kovdor                = 'WPT 38\n',
    alakourtti            = 'WPT 39\n',
    samalvik              = 'SAMAlvik\n',
    skogsfarp1            = 'Hidden FARP out in the finnish forest\nRoute to Kuusamo',
    skogsfarp2            = 'Hidden FARP out in the finnish forest\nRoute to Kuusamo',
    skogsfarp3            = 'Hidden FARP out in the finnish forest\nRoute to Kuusamo',
    skogsfarp4            = 'Hidden FARP out in the finnish forest\nRoute to Kuusamo',
    laplandiya            = 'Large storage area. Destroy bunkers, fuel tanks and railway station',
    zelenoborskij         = 'Large storage area. Destroy bunkers, fuel tanks and railway station',
    LovozeroCCC           = 'Command center. Destroy bunker.',
    hidden1               = 'Nobody knows, and you should not eiter',
    storage               = 'Storage area. Destroy buildings to make zone neutral',
    shipyard              = 'Shipyard. Destroy buildings and units to make zone neutral'
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

bc = BattleCommander:new(filepath, 10, 60)
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
    hiddenKemiRoadblock   = ZoneCommander:new({zone='Hidden_KemiRoadblock',  side=0         , level=99             , upgrades=upgrades.hiddenKemiRoadblockGroup, crates={}, flavorText=flavor.hidden1 }),
    hiddenForestguard     = ZoneCommander:new({zone='Hidden_Forestguard',    side=0         , level=99             , upgrades=upgrades.hiddenForestguardGroup, crates={}, flavorText=flavor.hidden1 }),
    hiddenRanuaGuard      = ZoneCommander:new({zone='Hidden_RanuaRB',        side=0         , level=99             , upgrades=upgrades.hiddenRanuaGuardGroup, crates={}, flavorText=flavor.hidden1 }),
    hiddenPosioGuard      = ZoneCommander:new({zone='Hidden_PosioRB',        side=0         , level=99             , upgrades=upgrades.hiddenPosioGuardGroup, crates={}, flavorText=flavor.hidden1 }),
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
    CapPlaneTemplate = CapPlaneTemplate or {
        'RED_MIG29A',
        'RED_SU27_EW',
        'RED_MIG21Bis',
        'RED_MIG23MLD',
        'RED_MIG25PD',
        'BLUE_HORNET_CW',
        'BLUE_F15C',
        'BLUE_F15C_CW',
        'BLUE_F14A',
    }
    HeloSupplyTemplate = HeloSupplyTemplate or {
        'RED_MI-8',
        'BLUE_CH-47',
    }
    CasPlaneTemplate = CasPlaneTemplate or {
        'RED_SU25_OneShip',
        'RED_SU25_TwoShip',
        'RED_SU25T_OneShip',
        'RED_SU25T_TwoShip',
        'RED_CAS_Mirage_F1BQ',
        'BLUE_F4E',
    }
    SeadPlaneTemplate = SeadPlaneTemplate or {
        'RED_SU-24M_TWOSHIP',
        'RED_SU-24M_ONESHIP',
    }
    CasHeloTemplate = CasHeloTemplate or {
        'RED_Mi-24V_ONESHIP',
        'RED_Mi-24V_TWOSHIP',
        'BLUE_UH-1H_CAS',
    }

    HeloSupplyTemplate = HeloSupplyTemplate or {
        'RED_MI-8',
        'BLUE_CH-47',
        'BLUE_UH-1H',
    }
    AttackConvoy = AttackConvoy or {
        "AttackConvoy CW 1",
        "AttackConvoy CW 2",
        "AttackConvoy CW 3",
        "AttackConvoy CW 4",
    }
else
    CapPlaneTemplate = CapPlaneTemplate or {
        'RED_MIG29S',
        'RED_MIG29A',
        'RED_SU27',
        'RED_MIG21Bis',
        'RED_MIG23MLD',
        'RED_MIG25PD',
        'BLUE_HORNET',
        'BLUE_F15C',
        'BLUE_F16C',
        'BLUE_F14B',
        'BLUE_M-2000C',
    }
    HeloSupplyTemplate = HeloSupplyTemplate or {
        'RED_MI-8',
        'BLUE_CH-47',
    }
    CasPlaneTemplate = CasPlaneTemplate or {
        'RED_SU25_OneShip',
        'RED_SU25_TwoShip',
        'RED_Mirage_F1BQ',
        'RED_MIG21_BIS_ONE_SHIP',
        'RED_MIG21_BIS_TWO_SHIP',
        'BLUE_F4E',
    }
    SeadPlaneTemplate = SeadPlaneTemplate or {
        'RED_JF17_ONESHIP',
        'RED_JF17_TWOSHIP',
        'RED_SU25T_ONESHIP',
        'RED_SU25T_TWOSHIP',
        'RED_SU-34_ONESHIP',
        'RED_SU-34_TWOSHIP',
        'RED_SU-24M_TWOSHIP',
        'RED_SU-24M_ONESHIP',
    }
    CasHeloTemplate = CasHeloTemplate or {
        'RED_Mi-24P_ONESHIP',
        'RED_Mi-24P_TWOSHIP',
        'RED_M-28N_ONESHIP',
        'RED_M-28N_TWOSHIP',
        'BLUE_AH-64D_ONESHIP',
        'BLUE_AH-64D_TWOSHIP',
        'BLUE_AH-1W',
        'BLUE_SA342M',
    }
    AttackConvoy = AttackConvoy or {
        "AttackConvoy 1",
        "AttackConvoy 2",
        "AttackConvoy 3",
        "AttackConvoy 4",
    }

	RunwayStrikePlaneTemplate = RunwayStrikePlaneTemplate or {
        "RED_MIG-27K",
        "RED_SU-33",
    }
end

SupplyConvoy = SupplyConvoy or {
    "SupplyConvoy 1",
    "SupplyConvoy 2",
    "SupplyConvoy 3",
    "SupplyConvoy 4",
}

PlaneSupplyTemplate = PlaneSupplyTemplate or {
	"IL-76MD",
	"C-130",
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
    GroupCommander:new({name='Rovaniemi-attack-Kallax-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Kallax', Altitude = CapAltitude()}),
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
        menuTitle = "Mission: Ground Escort",
        missionTitle = "Mission: Ground Escort",
        TargetZone = "SkogsFARP2",
        MissionType = "Escort",
		radius = 2500,
		flag = 101,
        ActivateZone = "Hidden_Forestguard"
    },
    SkogsFARP2 = {	
        zone = "SkogsFARP2",
        missionGroup = "SkogsFarp2Group",
        menuTitle = "Mission: Ground Escort",
        missionTitle = "Mission: Ground Escort",
        TargetZone = "SkogsFARP3",
        MissionType = "Escort",
		radius = 2500,
		flag = 111,
        ActivateZone = "Hidden_RanuaRB"
    },
    SkogsFARP3 = {	
        zone = "SkogsFARP3",
        missionGroup = "SkogsFarp3Group",
        menuTitle = "Mission: Ground Escort",
        missionTitle = "Mission: Ground Escort",
        TargetZone = "SkogsFARP4",
        MissionType = "Escort",
		radius = 2500,
		flag = 121,
        ActivateZone = "Hidden_PosioRB"
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
bc:addConnection("Andoya","Banak")
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
--bc:addConnection("Kuusamo","Olenya")
--bc:addConnection("LaplandiyaStorage","Olenya")
--bc:addConnection("LovozeroCCC","Olenya")

--[[
bc:addConnectionSupply("Bodo","BergsBasen")
bc:addConnectionSupply("Bodo","Andoya")
bc:addConnectionSupply("Bodo","Vidsel")
bc:addConnectionSupply("Bodo","Kiruna")
bc:addConnectionSupply("Andoya","Banak")
--bc:addConnectionSupply("Andoya","Ivalo")
bc:addConnectionSupply("Banak","Buolbmat")
bc:addConnectionSupply("Andoya","Kirkenes")
bc:addConnectionSupply("Andoya","Bardufoss")
bc:addConnectionSupply("Kiruna","Kittila")
bc:addConnectionSupply("Kittila","Vuojarvi")
bc:addConnectionSupply("BergsBasen","Kvikkjokk")
bc:addConnectionSupply("Kvikkjokk","Skogsbasen")
bc:addConnectionSupply("Kvikkjokk","Jokkmokk")
bc:addConnectionSupply("Skogsbasen","Kiruna")
bc:addConnectionSupply("Skogsbasen","Gallivare")
bc:addConnectionSupply("Gallivare","Kiruna")
bc:addConnectionSupply("Gallivare","Jokkmokk")
bc:addConnectionSupply("Jokkmokk","Vidsel")
bc:addConnectionSupply("Vidsel","Kallax")
bc:addConnectionSupply("Kallax","Kalix")
bc:addConnectionSupply("Kalix","KemiTornio")
bc:addConnectionSupply("Kallax","SAMAlvik")
bc:addConnectionSupply("Kuusamo","KemiTornio")
bc:addConnectionSupply("KemiTornio","Tervola")
bc:addConnectionSupply("Rovaniemi","Tervola")
bc:addConnectionSupply("Rovaniemi","Vuojarvi")
bc:addConnectionSupply("Vuojarvi","Savukoski")
bc:addConnectionSupply("Kelloselka","Savukoski")
bc:addConnectionSupply("Savukoski","Kovdor")
bc:addConnectionSupply("Apatity","Monchegorsk")
bc:addConnectionSupply("MurmanskInternational","Severomorsk3")
bc:addConnectionSupply("Severomorsk3","Severomorsk1")
bc:addConnectionSupply("Zapolyarnyy","Severomorsk1")
bc:addConnectionSupply("Kirkenes","Zapolyarnyy")
bc:addConnectionSupply("Kirkenes","Buolbmat")
bc:addConnectionSupply("Kiruna","Luspa")
bc:addConnectionSupply("Kiruna","Kalixfors")
bc:addConnectionSupply("Luspa","Guovdageaidnu")
bc:addConnectionSupply("Karasjok","Guovdageaidnu")
bc:addConnectionSupply("Karasjok","Banak")
bc:addConnectionSupply("Karasjok","Ivalo")
bc:addConnectionSupply("Prirechnyi","Severomorsk1")
bc:addConnectionSupply("Ivalo","Vuojarvi")
bc:addConnectionSupply("Ivalo","Guovdageaidnu")
bc:addConnectionSupply("Luspa","Ivalo")
bc:addConnectionSupply("Kelloselka","Alakourtti")
bc:addConnectionSupply("Kuusamo","Alakourtti")
bc:addConnectionSupply("Maaninkavaara","Kuusamo")
bc:addConnectionSupply("Kelloselka","Maaninkavaara")
bc:addConnectionSupply("Zapolyarnyy","Prirechnyi")
bc:addConnectionSupply("Prirechnyi","Severomorsk1")
bc:addConnectionSupply("Monchegorsk","ZelenoborskijStorage")
bc:addConnectionSupply("Monchegorsk","Olenya")
--bc:addConnectionSupply("Kiruna","Olenya")
--bc:addConnectionSupply("Kirkenes","Olenya")
--bc:addConnectionSupply("Banak","Olenya")
--bc:addConnectionSupply("Olenya","MurmanskInternational")
--bc:addConnectionSupply("Severomorsk1","Olenya")
bc:addConnectionSupply("Severomorsk3","Olenya")
--bc:addConnectionSupply("Alakourtti","Olenya")
--bc:addConnectionSupply("Vuojarvi","Olenya")
--bc:addConnectionSupply("Rovaniemi","Olenya")
bc:addConnectionSupply("Ivalo","Olenya")
--bc:addConnectionSupply("Kuusamo","Olenya")
--bc:addConnectionSupply("LaplandiyaStorage","Olenya")
--bc:addConnectionSupply("LovozeroCCC","Olenya")
]]

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


lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

bc:loadFromDisk() --will load and overwrite default zone levels, sides, funds and available shop items
bc:init()
bc:startRewardPlayerContribution(15,{infantry = 10, ground = 10, sam = 30, airplane = 30, ship = 250, helicopter=30, crate=200, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, ['CAP mission'] = true, ['CAS mission'] = true})
HercCargoDropSupply.init(bc)
buildTemplateCache()
bc:buildZoneDistanceCache()
buildSubZoneRoadCache()
bc:buildConnectionMap()
DynamicConvoy.InitTargetTails(5)
DynamicConvoy.InitRoadPathCacheFromCommanders(GroupCommanders)
PrecomputeLandingSpots()
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



GlobalSettings.landedDespawnTime = 3*60 --to allow for parking of fixed wing supply


mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})

local bomb_COOLDOWN = 1800
local lastbomb_COOLDOWN  = -bomb_COOLDOWN
Group.getByName('evt-bomb'):destroy()
Group.getByName('EscortBomber'):destroy()
evc:addEvent({
	id='bomb',
	action=function()
		RespawnGroup('evt-bomb')
		RegisterGroupTarget('evt-bomber',500,'Intercept enemy bombers')
		timer.scheduleFunction(function()
			RespawnGroup('EscortBomber')
				local tgts = {
					'Kiruna','Bardufoss','Banak','Kallax','Ivalo','KemiTornio','Rovaniemi',
					'Kirkenes','Ivalo','Kittila','Vuojarvi','Monchegorsk','Olenya'}
					if Group.getByName('evt-bomb') then
						local bomber, bomberMission = StartBomberAuftrag('bomb', 'evt-bomb', tgts, 'EscortBomber')
				end
		end,{},timer.getTime()+1)
	end,
	canExecute = function()
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
	title = "Intercept Bombers",
	description = "Enemy bombers spotted north of Mineralnye\nDestroy them before they get in range.",
	messageStart = "New mission: Intercept Bombers",
	messageEnd=function() lastbomb_COOLDOWN=timer.getTime() return "Mission ended: Intercept Bombers" end,
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
		local gr = Group.getByName('evt-bomb')
		if gr then return true else return false end
	end
})
local airstrike_COOLDOWN = 1800
local lastairstrike_COOLDOWN  = -airstrike_COOLDOWN
Group.getByName('evt-attack'):destroy()
evc:addEvent({
	id='cas',
	action = function()
        Respawn.Group('evt-attack')
		RegisterGroupTarget('evt-attack',250,'Intercept enemy airstrike')
		timer.scheduleFunction(function(param, time)
			local tgts = {
			'Kiruna',
			'Bardufoss',
			'Banak',
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
	title = "Intercept enemy airstrike",
	description = "Enemy aircraft conducting an airstrike from the west to east\nDestroy them before they get in range.",
	messageStart = "New mission: Intercept enemy airstrike",
    messageEnd =function() lastairstrike_COOLDOWN=timer.getTime() return "Mission ended: Intercept enemy airstrike" end,
	startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
	isActive = function()
		local gr = Group.getByName('evt-attack')
		if gr then return true else return false end
	end
})
local Escort_COOLDOWN = 1800
local lastEscort_COOLDOWN  = -Escort_COOLDOWN
Group.getByName('escort-me'):destroy()
Group.getByName('interceptor-1'):destroy()
Group.getByName('interceptor-2'):destroy()
evc:addEvent({
	id='escort',
	action = function()
        RespawnGroup('escort-me')
		
	local function spawnIntercept(args)
		local groupname = args[1]
		--env.info('spawnIntercept called for '..tostring(groupname))
		if Group.getByName('escort-me') then
				local g = GROUP:FindByName(groupname,false)
				if not g then
					if math.random(1,100) > 30 then
						if math.random(1,100) > 50 then
							trigger.action.outTextForCoalition(2,'Enemy interceptor spotted heading for our cargo transport.',15)
						else
							trigger.action.outTextForCoalition(2,'The enemy has launched an intercept mission against our cargo transport',15)
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
    title = "Escort cargo plane",
    description = "Friendly cargo plane is taking off from Bodo. Protect it until it leaves the airspace.",
    messageStart = "New mission: Escort cargo plane",
   messageEnd =function() lastEscort_COOLDOWN=timer.getTime() return "Strike mission ended: Escort cargo plane" end,
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
        if Group.getByName('escort-me') then return true end
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
        local u = Group.getByName(planes[1]):getUnit(1)
		if u then RegisterUnitTarget(u:getName(),250,'Intercept cargo plane') end
	end,
	canExecute = function()
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
    title = "Intercept cargo plane",
    description = function()
		if Group.getByName('evt-cargointercept1') then
			return "Find and destroy the cargo plane headed to Olenya\nCurrently spotted north of Banak."
		elseif Group.getByName('evt-cargointercept2') then
			return "Find and destroy the cargo plane headed to Ivalo\nCurrently spotted south east of Kuusamo."
		elseif Group.getByName('evt-cargointercept3') then
			return "Find and destroy the cargo plane headed to Kuusamo\nCurrently spotted north west of Severomorsk1."
		else
			return "Cargo plane is no longer active."
		end
	end,
    messageStart = "New mission: Intercept cargo plane",
    messageEnd =function() lastCargoIntercept_COOLDOWN=timer.getTime() return "Mission ended: Intercept cargo plane" end,
    startAction = function() 
        if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
    isActive = function()
        if Group.getByName('evt-cargointercept1') then return true end
        if Group.getByName('evt-cargointercept2') then return true end
        if Group.getByName('evt-cargointercept3') then return true end
        
        return false
    end
})

Group.getByName('Zapolyarnyy-Scuds'):destroy()
evc:addEvent({
	id='scuds2',
	action = function()
        RespawnGroup('Zapolyarnyy-Scuds')
		RegisterGroupTarget('Zapolyarnyy-Scuds',100,'Destroy Scuds')
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
				trigger.action.outTextForCoalition(2, 'SCUDS near Zapolyarnyy (30), are launching at '..choice, 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
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
	title = "Destroy SCUDS (30)",
	description = "SCUDS have been spotted at Zapolyarnyy(30).\nDestroy them before they can launch their missiles",
	messageStart = "New mission: Destroy SCUDS at Zapolyarnyy(30)",
	messageEnd = "Mission ended: Destroy SCUDS",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
	isActive = function()
		local gr = Group.getByName('Zapolyarnyy-Scuds')
		if gr then return true else return false end
	end
})
Group.getByName('Kittila-Scuds'):destroy()
evc:addEvent({
	id='scuds1',
	action = function()

    RespawnGroup('Kittila-Scuds')  
		RegisterGroupTarget('Kittila-Scuds',100,'Destroy Scuds')
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
				trigger.action.outTextForCoalition(2, 'SCUDS near Kittila (28), are launching at '..choice, 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
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
	title = "Destroy SCUDS (28)",
	description = "SCUDS have been spotted at Kittila(28).\nDestroy them before they can launch their missiles",
	messageStart = "New mission: Destroy SCUDS at Kittila(28)",
	messageEnd = "Mission ended: Destroy SCUDS",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
	isActive = function()
		local gr = Group.getByName('Kittila-Scuds')
		if gr then return true else return false end
	end
})

resupplyTarget = nil
mc:trackMission({
    title = function()
        local wp = WaypointList[resupplyTarget] or ""
        return "Resupply " .. resupplyTarget .. wp
    end,
    description = function()
        return "Deliver supplies to " .. resupplyTarget end,
    messageStart = function()
        local wp = WaypointList[resupplyTarget] or ""
        return "New mission: Resupply " .. resupplyTarget .. wp
    end,
    messageEnd = function()
        return "Mission ended: Resupply " .. resupplyTarget end,
    startAction = function()
        local MissionType = "Resupply"
        ActiveCurrentMission[resupplyTarget] = MissionType
        local z = bc:getZoneByName(resupplyTarget) ; if z then z:updateLabel() end
        if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()       
        local MissionType = "Resupply"
        if ActiveCurrentMission[resupplyTarget] == MissionType then
            ActiveCurrentMission[resupplyTarget] = nil
        end
        local z = bc:getZoneByName(resupplyTarget) ; if z then z:updateLabel() end
        resupplyTarget = nil
        if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
    end,
    isActive = function()
        if not resupplyTarget then return false end

        local targetzn = bc:getZoneByName(resupplyTarget)
        return targetzn and targetzn.side == 2 and targetzn:canRecieveSupply()
    end
})
attackTarget = nil
mc:trackMission({
    title = function()
        local wp = WaypointList[attackTarget] or ""
        return "Attack " .. attackTarget .. wp
    end,
    description = function()
        local wp = WaypointList[attackTarget] or ""
        return "Destroy enemy forces at " .. attackTarget end,
    messageStart = function()
        local wp = WaypointList[attackTarget] or ""
        return "New mission: Attack " .. attackTarget .. wp
    end,
    messageEnd = function()
        return "Mission ended: Attack " .. attackTarget end,
	startAction = function()
		ActiveCurrentMission[attackTarget] = ActiveCurrentMission[attackTarget] or {}
		ActiveCurrentMission[attackTarget]["Attack"] = true
		local z = bc:getZoneByName(attackTarget) if z then z:updateLabel() end
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cas.ogg")
		end
	end,
	endAction = function()
		local t = (type(ActiveCurrentMission) == 'table') and ActiveCurrentMission[attackTarget] or nil
		if type(t) == 'table' then
			t["Attack"] = nil
			if not next(t) then ActiveCurrentMission[attackTarget] = nil end
		end
		local z = bc:getZoneByName(attackTarget) if z then z:updateLabel() end
		attackTarget = nil
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
    isActive = function()
        if not attackTarget then return false end
        local targetzn = bc:getZoneByName(attackTarget)
        return targetzn.side == 1 and not targetzn.suspended
    end
})
captureTarget = nil
mc:trackMission({
    title = function()
        local wp = WaypointList[captureTarget] or ""
        return "Capture " .. captureTarget .. wp
    end,
    description = function()
        return captureTarget .. " is neutral. Capture it by delivering supplies" end,
    messageStart = function()
        local wp = WaypointList[captureTarget] or ""
        return "New mission: Capture " .. captureTarget .. wp
    end,
    messageEnd = function()
        return "Mission ended: Capture " .. captureTarget end,
    startAction = function()
        local MissionType = "Capture"
        ActiveCurrentMission[captureTarget] = MissionType
        local z = bc:getZoneByName(captureTarget) ; if z then z:updateLabel() end
        if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
        local MissionType = "Capture"
        if ActiveCurrentMission[captureTarget] == MissionType then
            ActiveCurrentMission[captureTarget] = nil
        end
        local z = bc:getZoneByName(captureTarget) ; if z then z:updateLabel() end
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
    trigger.action.outText(name .. ' is missing', 30)
  end
end
end, {}, timer.getTime() + 1)

evc:addEvent({
	id='RussiansHideOut',
	action = function()
	ActiveMission['RussiansHideOut'] = true
	local tgt = SCENERY:FindByZoneName('RussiansHideOut')
	if not tgt then
		trigger.action.outText('RussiansHideOut is missing',30)
		return
	end
		RegisterScoreTarget('RussiansHideOut',tgt,500,'Russian hideout')
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"Strike on russian hideout",p,2,false,false)
			MissionMarks['EnemyHideout'] = missionMarkId
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
	title = "Strike russian hideout",
	description = 
[[Strike on a russian hideout near Jokkmokk at 
these coordinates:

MGRS: 34 W DU 47433 88501
Lat long: N 66°36'39" E 19°48'47"
Lat long Decimal Minutes: N 66°36.652' E 19°48.797'

Elevation: 869 feet

reward = 500]],
	messageStart = "New mission: Strike on russian hideout",
	messageEnd = "Mission ended: Strike russian hideout",
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
		trigger.action.outText('GeneralsHouse is missing',30)
		return
	end
		RegisterScoreTarget('GeneralsHouse',tgt,500,'High value target')
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"Strike High value target",p,2,false,false)
			MissionMarks['EnemyHideout'] = missionMarkId
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
	title = "Strike High value target",
	description = 
[[Strike a high-value building at these coordinates:

MGRS: 36 W VV 21510 97955
Lat long: N 67°35'12" E 31°09'18" 
Lat long Decimal Minutes: N 67°35.202' E 31°09.305'

Elevation: 539 feet

reward = 500]],
	messageStart = "New mission: Strike High value target",
	messageEnd = "Mission ended: Strike High value target",
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
		RegisterGroupTarget('PapasSon',500,'Right hand man','PapasSon')
	end,
	canExecute = function()
        if CustomFlags['DynCampaign'] then return false end
		if bc:getZoneByName('Banak').side ~= 2 or bc:getZoneByName('Karasjok').side ~= 2 then return false end
        if bc:getZoneByName('Banak').suspended or bc:getZoneByName('Karasjok').suspended then return false end
		if CustomFlags["PapasSon"] then return false end
		if Group.getByName('PapasSon') then return false end
		return true
	end
})

mc:trackMission({
	title = "Kill the generals right hand man",
description = 
[[
We have the location on one of generals Righthand
man in the city of Leirpollskogen, Take him out!.

Coordinates:
MGRS: 35 W NU 56829 15425
Lat Long: N 70°26'16" E 28°31'15"
Lat long Decimal Minutes: N 70°26.277' E 28°31.254'
Elevation: 108 feet

Reward: 500

Destroy the house and whoever is nearby.]],

	messageStart = "New mission: Kill the generals right hand man",
	messageEnd = "Mission ended: Kill the generals right hand man",
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
		RegisterStaticGroup('laplandiyaStorage', z, 1250, 'laplandiya Storage', 'laplandiyaStorage')
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
	title = "Strike on laplandiya Storage warehouses",
	description =
[[5 storage warehouses have been identified.
Destroy them to get rid of the enemy activity in it.

Reward: 1250

2000 LBS Penetrator bomb is required.

Location coordinates:

MGRS: 36 W WA 12643 73122
Lat long: N 68°16'15" E 33°18'21"
Lat long Precise: N 68°16'15.98" E 33°18'21.72"
Lat long Decimal Minutes: N 68°16.266' E 33°18.362'
Elevation 623 feet]],
	messageStart = "New strike mission: Strike on laplandiya warehouses",
	messageEnd = "Strike mission ended: Strike on laplandiya warehouses",
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
		RegisterStaticGroup('ZelenoborskijStorage', z, 1250, 'laplandiya Storage', 'ZelenoborskijStorage')
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
	title = "Strike on zelenoborskij Storage warehouses",
	description =
[[5 storage warehouses have been identified.
Destroy them to get rid of the enemy activity in it.

Reward: 1250

2000 LBS Penetrator bomb is required.

Location coordinates:

MGRS: 36 W VV 69946 10495
Lat long: N 66°48'40" E 32°18'57"
Lat long Precise: N 66°48'40.21" E 32°18'57.66"
Lat long Decimal Minutes: N 66°48.670' E 32°18.961'
Elevation 183 feet]],
	messageStart = "New strike mission: Strike on zelenoborskij warehouses",
	messageEnd = "Strike mission ended: Strike on zelenoborskij warehouses",
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
		RegisterStaticGroup('PyaozerskyStorage', z, 1000, 'Pyaozersky Storage', 'PyaozerskyStorage')
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
	title = "Strike on PyaozerskyStorage warehouses",
	description =
[[3 storage warehouses have been identified.
Destroy them to get rid of the enemy activity in it.

Reward: 1000

2000 LBS Penetrator bomb is required.

Location coordinates:

MGRS: 36 W VT 14140 95420
Lat long: N 65°46'07" E 31°07'30"
Lat long Precise: N 65°46'07.63" E 31°07'30.01"
Lat long Decimal Minutes: N 65°46.127' E 31°07.500'
Elevation 480 feet]],
	messageStart = "New strike mission: Strike on PyaozerskyStorage warehouses",
	messageEnd = "Strike mission ended: Strike on PyaozerskyStorage warehouses",
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
		RegisterStaticGroup('lovozeroCCCBunker', z, 1000, 'lovozeroCCC Command Center', 'lovozeroCCCBunker')
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
	title = "Strike on LovozeroCCC Command Center",
	description =
[[Enemy command center have been identified.
Destroy them to get rid of the enemy activity in it.

Reward: 500

2000 LBS Penetrator bomb is required.

Location coordinates:

MGRS: 36 W WA 87863 45232
Lat long: N 68°00'28" E 35°06'10"
Lat long Precise: N 68°00'28.19" E 35°06'10.09"
Lat long Decimal Minutes: N 68°00.469' E 35°06.168'
Elevation 480 feet]],
	messageStart = "New strike mission: Strike on LovozeroCCC Command Center",
	messageEnd = "Strike mission ended: Strike on LovozeroCCC Command Center",
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
    if captureTarget ~= nil then return end
    
    local validzones = {}
    for _, v in ipairs(bc.zones) do
        if v.active and v.side == 0 and (not v.NeutralAtStart or v.firstCaptureByRed) and 
           not string.find(v.zone, "Hidden") then
            table.insert(validzones, v.zone)
        end
    end
    
    if #validzones == 0 then return end
    
    local choice = math.random(1, #validzones)
    if validzones[choice] then
        captureTarget = validzones[choice]
        return true
    end
end

function generateAttackMission()
    if missionCompleted then return end
    if attackTarget ~= nil then return end

	local validzones = {}
	for _, v in ipairs(bc.connections) do
		local from, to = bc:getConnectionZones(v)

        local function checkValid(zone)
			local lname = zone.zone:lower()
            return zone.side == 1 and zone.active and not isZoneUnderSEADMission(zone.zone)
			and not lname:find('ivalo') and not lname:find('banak')
        end

	if from and to and from.side ~= to.side and from.side ~= 0 and to.side ~= 0 and 
		((not to.suspended) or from.suspended) then
			if checkValid(from) then table.insert(validzones, from.zone) end
			if checkValid(to)   then table.insert(validzones, to.zone)   end
		end
	end

   if #validzones == 0 then return end

    local choice = math.random(1, #validzones)
    attackTarget = validzones[choice]
    return true
end

function generateSupplyMission()
    if resupplyTarget ~= nil then return end
        
    local validzones = {}
    for _,v in ipairs(bc.zones) do
        if v.side == 2 and v:canRecieveSupply() then
            table.insert(validzones, v.zone)
        end
    end
    
    if #validzones == 0 then return end
    
    local choice = math.random(1, #validzones)
    if validzones[choice] then
        resupplyTarget = validzones[choice]
        return true
    end
end

---------------------------------------------------------------------
--                          CAP MISSION                            --

capMissionTarget = nil
capKillsByPlayer = {}
capTargetPlanes = 0
capWinner = nil
capMissionCooldownUntil = 0

mc:trackMission({
    title = function() return "CAP mission" end,
    description = function()
        if not next(capKillsByPlayer) then
            return "Kill "..capTargetPlanes.." A/A targets without getting shot down, who wins?"
        else
            local scoreboard = "Current Kill Count:\n"
            for playerName, kills in pairs(capKillsByPlayer) do
                scoreboard = scoreboard .. string.format("%s: %d\n", playerName, kills)
            end
            return string.format("Kill %d A/A targets, who wins?\n\n%s", capTargetPlanes, scoreboard)
        end
    end,
    messageStart = function()
        return "New CAP mission: Kill "..capTargetPlanes.." A/A targets." end,
    messageEnd = function() return "Mission ended: CAP" end,
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
                trigger.action.outTextForCoalition(2,"["..pname.."] and ["..jp.."] completed the CAP mission!\nReward pending: "..reward.." credits each (land to redeem).",20)
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
                trigger.action.outTextForCoalition(2,"["..pname.."] completed the CAP mission!\nReward pending: "..reward.." credits (land to redeem).",20)
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
	title = function() return 'CAS mission' end,
	description = function()
		if not next(casKillsByPlayer) then
			return 'Destroy '..casTargetKills..' ground targets without getting shot down, who wins?'
		else
			local scoreboard = 'Current Kill Count:\n'
			for playerName, kills in pairs(casKillsByPlayer) do
				scoreboard = scoreboard..string.format('%s: %d\n', playerName, kills)
			end
			return string.format('Destroy %d ground targets, who wins?\n\n%s', casTargetKills, scoreboard)
		end
	end,
	messageStart = function()
		return 'New CAS mission: Destroy '..casTargetKills..' ground targets.'
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
				trigger.action.outTextForCoalition(2,'['..pname..'] and ['..jp..'] completed the CAS mission!\nReward pending: '..reward..' credits each (land to redeem).',20)
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
				trigger.action.outTextForCoalition(2,'['..pname..'] completed the CAS mission!\nReward pending: '..reward..' credits (land to redeem).',20)
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
		trigger.action.outTextForGroup(groupID, "Active mission is pending:\n\nEscort convoy from " .. mission.zone .. " to " .. mission.TargetZone, 30)
        return
    end
	if mc.missionFlags[zoneName] then
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, "Special mission available:\n\nEscort convoy from " .. mission.zone .. " to " .. mission.TargetZone, 30)
		return 
	end

    mc:trackMission({
        MainTitle = function() return "Escort mission" end,
        title = function() return "Escort mission" end,
		titleBefore = function(self)
			self.notified = true
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, "Special mission available:\n\nEscort convoy from " .. mission.zone .. " to " .. mission.TargetZone, 30)
		 end,
        description = function() return "\nEscort a convoy to " .. mission.TargetZone .. "\nThe roads are filled with hostile enemies." end,
        isEscortMission = true,
        accept = false,
        missionGroup = mission.missionGroup,
        zoneName = zoneName,
        messageStart = function() return "Escort convoy to " .. mission.TargetZone end,
		missionFail = function(self)
		self.accept = false
		if not IsGroupActive(mission.missionGroup) then
			mc.missionFlags[zoneName] = nil
			if missionGroupIDs[zoneName] and next(missionGroupIDs[zoneName]) then
				for groupName, data in pairs(missionGroupIDs[zoneName]) do
					local groupID = data.groupID
					local group = data.group
					trigger.action.outSoundForGroup(groupID, "cancel.ogg")
					trigger.action.outTextForGroup(groupID, "Mission failed:\n\nConvoy was destroyed\n\nStandby, looking for a new group...", 30)
					removeMissionMenuForAll(mission.zone, groupID)
					if trackedGroups[groupName] then
						trackedGroups[groupName] = nil
						--handleMission(zoneName, groupName, groupID, group)
					end
				end
			else
				trigger.action.outSoundForCoalition(2, "cancel.ogg")
				trigger.action.outTextForCoalition(2, "Mission failed:\n\nConvoy was destroyed", 30)
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
					msg = "Escort mission completed by " .. table.concat(names, ", ") .. "\ncredit " .. share .. " each - land to redeem"
				elseif cnt == 1 then
					msg = "Escort mission completed by " .. names[1] .. "\ncredit " .. reward .. " - land to redeem"
				else
					msg = "Escort mission completed — no players alive.\nReward + " .. reward
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
    title=function() return 'Bomb runway' end,
    description=function()
      local wp=WaypointList[runwayTargetZone] or ""
      if #runwayNames>1 then
        return 'Drop 1 bomb on each runway at '..runwayTargetZone..wp
      else
        return 'Drop 1 bomb on the runway at '..runwayTargetZone..wp
      end
    end,
    messageStart=function()
    local wp=WaypointList[runwayTargetZone] or ""
      if #runwayNames>1 then
        return 'New mission: Bomb all runways at '..runwayTargetZone..wp
      else
        return 'New mission: Bomb runway at '..runwayTargetZone..wp
      end
    end,
	messageEnd = function()
		trigger.action.outSoundForCoalition(2,'cancel.ogg')
		if runwayTargetZone then
			if runwayCompleted then
				local cred = (need and need>1) and 200 or 100
				if bomberName and runwayPartnerName then
					return 'Mission ended: Bomb runway at '..runwayTargetZone..' completed by '..bomberName..' and '..runwayPartnerName..'\ncredit '..cred..' each - land to redeem'
				elseif bomberName then
					return 'Mission ended: Bomb runway at '..runwayTargetZone..' completed by '..bomberName..'\ncredit '..cred..' - land to redeem'
				else
					return 'Mission ended: Bomb runway at '..runwayTargetZone..' completed'
				end
			else
				return 'Mission ended: Bomb runway at '..runwayTargetZone..' canceled'
			end
		else
			return 'Mission canceled: Bomb runway'
		end
	end,
	startAction = function()
    ActiveCurrentMission[runwayTargetZone] = type(ActiveCurrentMission[runwayTargetZone]) == 'table' and ActiveCurrentMission[runwayTargetZone] or {}
    ActiveCurrentMission[runwayTargetZone]["Bomb runway"] = true

	local z = bc:getZoneByName(runwayTargetZone) if z then z:updateLabel() end
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
        RUNWAY_ZONE_COOLDOWN[runwayTargetZone] = timer.getTime() + 1800
        local t = (type(ActiveCurrentMission) == 'table') and ActiveCurrentMission[runwayTargetZone] or nil
        if type(t) == 'table' then
            t["Bomb runway"] = nil
            if not next(t) then ActiveCurrentMission[runwayTargetZone] = nil end
        end
        local z = bc:getZoneByName(runwayTargetZone) if z then z:updateLabel() end
    end
    runwayCooldown = timer.getTime() + 900
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
    if seadTarget then return end
    if not attackTarget then return end

    local function isSEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and (lname:find('ivalo') or lname:find('banak'))
    end

	local validSEADZones = {}
	local attackZone = bc:getZoneByName(attackTarget)

	if attackZone and attackZone.zone then
		local znA = attackZone.zone
		for _, zone in ipairs(bc.zones) do
			local znB = zone.zone
			local dist = ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB]
			if isSEADZone(zone) and bc:HasSeadTargets(zone.zone) and dist and dist <= 24000 then
				table.insert(validSEADZones, zone.zone)
			end
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

    if #validSEADZones == 0 then return end

    seadTarget = validSEADZones[math.random(#validSEADZones)]
    return true
end

mc:trackMission({
    title = function() return "SEAD mission at " .. seadTarget end,
    description = function() return "Neutralize enemy SAM/defences at " .. seadTarget end,
    messageStart = function() return "New SEAD mission: Engage SAM at " .. seadTarget end,
    messageEnd = function() return "SEAD mission ended" end,
    startAction = function()
        local MissionType = "SEAD"
        ActiveCurrentMission[seadTarget] = MissionType
        local z = bc:getZoneByName(seadTarget) ; if z then z:updateLabel() end
        if not missionCompleted then trigger.action.outSoundForCoalition(2,"ding.ogg") end
    end,
    endAction = function()
        local MissionType = "SEAD"
        if ActiveCurrentMission[seadTarget] == MissionType then
            ActiveCurrentMission[seadTarget] = nil
        end
        local z = bc:getZoneByName(seadTarget) ; if z then z:updateLabel() end
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
    if deadTarget then return end
    if seadTarget then return end
    if not attackTarget then return end

    local function isDEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and (lname:find('ivalo') or lname:find('banak'))
    end

    local validDEADZones = {}
    local attackZone = bc:getZoneByName(attackTarget)

    if attackZone and attackZone.zone then
        local znA = attackZone.zone
        for _, zone in ipairs(bc.zones) do
            local znB = zone.zone
            local dist = ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB]
            if isDEADZone(zone) and not bc:HasSeadTargets(zone.zone) and dist and dist <= 24000 then
                table.insert(validDEADZones, zone.zone)
            end
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

    if #validDEADZones == 0 then return end

    deadTarget = validDEADZones[math.random(#validDEADZones)]
    return true
end

mc:trackMission({
    title = function() return "DEAD mission at " .. deadTarget end,
    description = function() return "Destroy remaining enemy air defences at " .. deadTarget end,
    messageStart = function() return "New DEAD mission: Destroy remaining air defences at " .. deadTarget end,
    messageEnd = function() return "DEAD mission ended" end,
    startAction = function()
        local MissionType = "DEAD"
        ActiveCurrentMission[deadTarget] = MissionType
        local z = bc:getZoneByName(deadTarget) ; if z then z:updateLabel() end
        if not missionCompleted then trigger.action.outSoundForCoalition(2,"ding.ogg") end
    end,
    endAction = function()
        local MissionType = "DEAD"
        if ActiveCurrentMission[deadTarget] == MissionType then
            ActiveCurrentMission[deadTarget] = nil
        end
        local z = bc:getZoneByName(deadTarget) ; if z then z:updateLabel() end
        deadTarget = nil
        if not missionCompleted then trigger.action.outSoundForCoalition(2,"cancel.ogg") end
    end,
    isActive = function()
        if not deadTarget then return false end
        local zn = bc:getZoneByName(deadTarget)
        return zn and zn.side == 1 and not zn.suspended and not bc:HasSeadTargets(deadTarget)
    end
})

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
		trigger.action.outText("Enemy has been defeated.\n\nMission Complete.\n\nYou can restart the mission from the radio menu.", 120)

		timer.scheduleFunction(function()
			trigger.action.outSoundForCoalition(2, "BH.ogg")
		end, {}, timer.getTime() + 5)

			local subMenu = missionCommands.addSubMenuForCoalition(2, "Restart and Reset?", nil)
			missionCommands.addCommandForCoalition(2, "Yes", subMenu, function()
					Utils.saveTable(bc.saveFile, 'zonePersistance', {})
					if resetSaveFileAndFarp then
					resetSaveFileAndFarp()
					end
				trigger.action.outText("Restarting now..", 120)
				timer.scheduleFunction(function()
					trigger.action.setUserFlag(181, true)
				end, {}, timer.getTime() + 5)
			end)
			missionCommands.addCommandForCoalition(2, "No", subMenu, function()
		end)
	end
end

for i,v in ipairs(bc:getZones()) do
	v:registerTrigger('lost', checkMissionComplete, 'missioncompleted')
end

timer.scheduleFunction(function()
	checkMissionComplete(nil, nil)
end, {}, timer.getTime() +10)

Group.getByName('jtacDrone1'):destroy()
Group.getByName('jtacDrone2'):destroy()
local jtacTargetMenu = nil
local jtacDrones = {JTAC:new({name = 'jtacDrone1'}),JTAC:new({name = 'jtacDrone2'})}
bc:registerShopItem('jtac','MQ-9 Reaper JTAC mission',500,function(sender)
	if jtacTargetMenu then return 'Choose target zone from F10 menu' end
	local spawnAndOrbit = function(target)
		if jtacTargetMenu then
			local zn = bc:getZoneByName(target)
			for _,v in ipairs(jtacQueue) do
				if v.tgtzone and v.tgtzone.zone == zn.zone then
					trigger.action.outTextForCoalition(2,'JTAC already active over '..zn.zone..' Select another zone',10)
					return 'duplicate zone'
				end
			end
			if #jtacQueue == 2 then
				local old = table.remove(jtacQueue,1)
				local gr = Group.getByName(old.name)
				if gr then gr:destroy() end
			end
			local dr = jtacDrones[1]
			for i,v in ipairs(jtacDrones) do
				if not Utils.isGroupActive(Group.getByName(v.name)) then dr = v break end
			end
			dr:deployAtZone(zn)
			dr:showMenu()
			table.insert(jtacQueue,dr)
			trigger.action.outTextForCoalition(2,'Reaper drone deployed over '..target..' - JTACs active '..#jtacQueue..' / 2',15)
			jtacTargetMenu = nil
		end
	end
	jtacTargetMenu = bc:showTargetZoneMenu(2,'Deploy JTAC',spawnAndOrbit,1)
	trigger.action.outTextForCoalition(2,'Choose which zone to deploy JTAC at from F10 menu',15)
end,function(sender,params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		for _,v in ipairs(jtacQueue) do
			if v.tgtzone and v.tgtzone.zone == params.zone.zone then
				return 'JTAC already active over '..params.zone.zone..' Choose another zone'
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
		trigger.action.outTextForCoalition(2,'Reaper drone deployed over '..params.zone.zone..' - JTACs active '..#jtacQueue..' / 2',15)
	else
		return 'Can only target enemy zone'
	end
end)


------------------------------------ START own 9 line jtac AM START ----------------------------------
jtacZones = {}
Group.getByName('JTAC9lineam'):destroy()
local jtacTargetMenu2 = nil
local droneAM = JTAC9line:new({name = 'JTAC9lineam'})
bc:registerShopItem('9lineam', 'Jtac 9line AM', 0, function(sender)
    if jtacTargetMenu2 then
        return 'Choose target zone from F10 menu'
    end
    
    local spawnAndOrbit2 = function(target)
        if jtacTargetMenu2 then
            local zn = bc:getZoneByName(target)
            droneAM:deployAtZone(zn)
            
            jtacZones[target] = {drone = 'JTAC9lineam'}
            
        trigger.action.outTextForCoalition(2, 'Reaper drone deployed over ' .. target .. '. Contact Springfield on 241.00 AM ', 30)
        jtacTargetMenu2 = nil
        end
    end
    
    jtacTargetMenu2 = bc:showTargetZoneMenu(2, 'Deploy JTAC to Zone', spawnAndOrbit2, 1)
		timer.scheduleFunction(function()
			trigger.action.outTextForCoalition(2, 'Choose which zone to deploy JTAC at from F10 menu', 15)
		end, {}, timer.getTime() + 3)
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        droneAM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = 'JTAC9lineam'}
        trigger.action.outTextForCoalition(2, 'Reaper drone deployed over ' .. params.zone.zone .. '. Contact Springfield on 241.00 AM ', 30)
    else
        return 'Can only target enemy zone'
    end
end)

  ------------------------------ END 9 line jtac AM END ----------------------------------
  ----------------------------- START 9 line jtac fm START ---------------------------

Group.getByName('JTAC9linefm'):destroy()
local jtacTargetMenu3 = nil
local droneFM = JTAC9linefmr:new({name = 'JTAC9linefm'})
bc:registerShopItem('9linefm', 'Jtac 9line FM', 0, function(sender)
    if jtacTargetMenu3 then
        return 'Choose target zone from F10 menu'
    end
    
    local spawnAndOrbit3 = function(target)
        if jtacTargetMenu3 then
            local zn = bc:getZoneByName(target)
            droneFM:deployAtZone(zn)
            
            jtacZones[target] = {drone = 'JTAC9linefm'}
            
        trigger.action.outTextForCoalition(2, 'Reaper drone deployed over ' .. target .. '. Contact Uzi on 31.00 FM ', 30)            
            jtacTargetMenu3 = nil
        end
    end
    
    jtacTargetMenu3 = bc:showTargetZoneMenu(2, 'Deploy JTAC to Zone', spawnAndOrbit3, 1)
		timer.scheduleFunction(function()
			trigger.action.outTextForCoalition(2, 'Choose which zone to deploy JTAC at from F10 menu', 15)
		end, {}, timer.getTime() + 3)
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        droneFM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = 'JTAC9linefm'}
        trigger.action.outTextForCoalition(2, 'Reaper drone deployed over ' .. params.zone.zone .. '. Contact Uzi on 31.00 FM ', 30)
    else
        return 'Can only target enemy zone'
    end
end)


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

local smoketargets = function(tz)
	if not tz or not tz.built then
		env.info("smoketargets: no tz/built for zone "..tostring(tz and tz.zone or "nil"))
		return
	end
	local units, statics, dangling, toRemove = {}, {}, {}, {}
	for i,v in pairs(tz.built) do
		local g = Group.getByName(v)
		if g and g:isExist() then
			local gUnits = g:getUnits()
			if gUnits then
				for i2,v2 in ipairs(gUnits) do
					table.insert(units, v2)
				end
			end
        else
            local st = StaticObject.getByName(v)
            if st and st:isExist() then
                table.insert(statics, st)
            else
                table.insert(dangling, tostring(v))
                table.insert(toRemove, i)
            end
        end
	end
	if #dangling > 0 then
		trigger.action.outTextForCoalition(2, "(BUG) "..tz.zone.." error has unresolved entries: "..table.concat(dangling,", ")..". Please report to Leka.", 30)
		for _,k in ipairs(toRemove) do tz.built[k] = nil end
	end
	local points = {}
	for _,u in ipairs(units) do if u and u:isExist() then local p=u:getPosition().p; if p then table.insert(points,p) end end end
	for _,s in ipairs(statics) do local p=s:getPoint(); if p then table.insert(points,p) end end
	for i=1,3 do
		if #points == 0 then break end
		local idx = math.random(1,#points)
		trigger.action.smoke(points[idx],1)
		table.remove(points,idx)
	end
end

local smokeTargetMenu = nil
bc:registerShopItem('smoke', 'Smoke markers', 20, function(sender)
	if smokeTargetMenu then
		return 'Choose target zone from F10 menu'
	end
	
	local launchAttack = function(target)
		if smokeTargetMenu then
			local tz = bc:getZoneByName(target)
			smoketargets(tz)
			smokeTargetMenu = nil
			trigger.action.outTextForCoalition(2, 'Targets marked with RED smoke at '..target, 15)
		end
	end
	
	smokeTargetMenu = bc:showTargetZoneMenu(2, 'Smoke marker target', launchAttack, 1)
	
	trigger.action.outTextForCoalition(2, 'Choose target zone from F10 menu', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		smoketargets(params.zone)
		trigger.action.outTextForCoalition(2, 'Targets marked with RED smoke at '..params.zone.zone, 15)
	else
		return 'Can only target enemy zone'
	end
end)

-----------------------------------------------DYNAMIC SHOP ------------------------------------------


bc:registerShopItem('dynamiccap', 'Dynamic CAP', 500, function(sender)
    if capActive then
        return 'CAP mission still in progress'
    end
		if capParentMenu then
		return 'Choose spawn zone from F10 menu'
	end
    buildCapMenu()
	trigger.action.outTextForCoalition(2, 'CAP is requested. Select spawn zone.', 10)
    return
end,
function (sender, params)
    if capActive then
        return 'CAP mission still in progress'
    end
    buildCapMenu()

	trigger.action.outTextForCoalition(2, 'CAP is requested. Select spawn zone.', 10)
    return
end)

bc:registerShopItem('dynamicarco', 'Dynamic Tanker (Drogue)', 100, function(sender)
    if ArcoActive then
        return 'Arco is still airborne'
    end
		if ArcoParentMenu then
		return 'Choose spawn zone from F10 menu'
	end
    buildArcoMenu()
	trigger.action.outTextForCoalition(2, 'Tanker (Drogue) is requested. Select spawn zone.', 10)
    return
end,
function (sender, params)
    if ArcoActive then
        return 'Arco is still airborne'
    end
    buildArcoMenu()

	trigger.action.outTextForCoalition(2, 'Tanker (Drogue) is requested. Select spawn zone.', 10)
    return
end)

bc:registerShopItem('dynamictexaco', 'Dynamic Tanker (Boom)', 100, function(sender)
    if TexacoActive then
        return 'Texaco is still airborne'
    end
		if TexacoParentMenu then
		return 'Choose spawn zone from F10 menu'
	end
    buildTexacoMenu()
	trigger.action.outTextForCoalition(2, 'Tanker (Boom) is requested. Select spawn zone.', 10)
    return
end,
function (sender, params)
    if TexacoActive then
        return 'Texaco is still airborne'
    end
    buildTexacoMenu()

	trigger.action.outTextForCoalition(2, 'Tanker (Boom) is requested. Select spawn zone.', 10)
    return
end)

bc:registerShopItem('dynamiccas', 'Dynamic CAS', 1000,
function(sender)
    if casActive then
        return 'CAS mission still in progress'
    end
	if CASTargetMenu then
		return 'Choose target zone from F10 menu'
	end
    local minNM = 25
    local allow = {}
    for _, z in ipairs(bc:getZones()) do
        if z.side == 1 and findClosestBlueZoneOutside(z.zone, minNM) then
            allow[z.zone] = true
        end
    end
    if not next(allow) then
        trigger.action.outTextForCoalition(2, 'No enemy zone is far enough (>'..minNM..' NM) from the front line.', 10)
        return
    end
    CASTargetMenu = bc:showTargetZoneMenu(2, 'Select CAS Target', function(targetZoneName, menu)
        if casActive then return end
        local spawnZone, dist = findClosestBlueZoneOutside(targetZoneName, minNM)
        if not spawnZone then
            return 'No friendly zone available for CAS spawn '..minNM..'+ NM away'
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnCasAt(spawnZone, targetZoneName, offset)
        CASTargetMenu = nil
    end, 1, nil, allow)
    trigger.action.outTextForCoalition(2, 'Select CAS target zone from F10', 10)
    return
end,
function(sender, params)
    if params.zone and params.zone.side == 1 then
        if casActive then return 'CAS mission still in progress' end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return 'No friendly zone available for CAS spawn.'
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnCasAt(closestBlue, params.zone.zone, offset)
        return
    else
        return 'Can only target enemy zone'
    end
end)

bc:registerShopItem('dynamicdecoy', 'Dynamic Decoy', 300,
function(sender)
    if decoyActive then
        return 'Decoy mission still in progress'
    end
	if DECOYTargetMenu then
		return 'Choose target zone from F10 menu'
	end

    local minNM = 40
    local allow = {}
    for _, z in ipairs(bc:getZones()) do
        if z.side == 1 and findClosestBlueZoneOutside(z.zone, minNM) then
            allow[z.zone] = true
        end
    end
    if not next(allow) then
        trigger.action.outTextForCoalition(2, 'No enemy zone is far enough (>'..minNM..' NM) from the front line.', 10)
        return
    end

    DECOYTargetMenu = bc:showTargetZoneMenu(2, 'Select Decoy Target', function(targetZoneName, menu)
        if decoyActive then return end
        local spawnZone, dist = findClosestBlueZoneOutside(targetZoneName, minNM)
        if not spawnZone then
            trigger.action.outTextForCoalition(2, 'No friendly zone available for Decoy spawn '..minNM..'+ NM away.', 15)
            return
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnDecoyAt(spawnZone, targetZoneName, offset)
        DECOYTargetMenu = nil
    end, 1, nil, allow)

    trigger.action.outTextForCoalition(2, 'Select Decoy target zone from F10', 10)
    return
end,
function(sender, params)
    if params.zone and params.zone.side == 1 then
        if decoyActive then
            return 'Decoy mission still in progress'
        end
        local minNM = 40
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return 'No friendly zone available for Decoy spawn.'
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnDecoyAt(closestBlue, params.zone.zone, offset)
        return
    else
        return 'Can only target enemy zone'
    end
end)


bc:registerShopItem('dynamicsead', 'Dynamic SEAD', 500,
function(sender)
    if seadActive then
        return 'SEAD mission still in progress'
    end
	if SEADTargetMenu then
		return 'Choose target zone from F10 menu'
	end

    local minNM = 40
    local allow = {}
    for _, z in ipairs(bc:getZones()) do
        if z.side == 1 and findClosestBlueZoneOutside(z.zone, minNM) then
            allow[z.zone] = true
        end
    end
    if not next(allow) then
        trigger.action.outTextForCoalition(2, 'No enemy zone is far enough (>'..minNM..' NM) from the front line.', 10)
        return
    end

    SEADTargetMenu = bc:showTargetZoneMenu(2, 'Select SEAD Target', function(targetZoneName, menu)
        if seadActive then return end
        local spawnZone, dist = findClosestBlueZoneOutside(targetZoneName, minNM)
        if not spawnZone then
            trigger.action.outTextForCoalition(2, 'No friendly zone available for SEAD spawn '..minNM..'+ NM away.', 15)
            return
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnSeadAt(spawnZone, targetZoneName, offset)
        SEADTargetMenu = nil
    end, 1, nil, allow)

    trigger.action.outTextForCoalition(2, 'Select SEAD target zone from F10', 10)
    return
end,
function(sender, params)
    if params.zone and params.zone.side == 1 then
        if seadActive then
            return 'SEAD mission still in progress'
        end
        local minNM = 40
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return 'No friendly zone available for SEAD spawn.'
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnSeadAt(closestBlue, params.zone.zone, offset)
        return
    else
        return 'Can only target enemy zone'
    end
end)

bc:registerShopItem('dynamicbomb', 'Dynamic Bomb run', 500,
function(sender)
    if bomberActive then
        return 'Bomb mission still in progress'
    end
	if BomberTargetMenu then
        return 'Choose target zone from F10 menu'
    end

    local minNM = 25
    local allow = {}
    for _, z in ipairs(bc:getZones()) do
        if z.side == 1 and findClosestBlueZoneOutside(z.zone, minNM) then
            allow[z.zone] = true
        end
    end
    if not next(allow) then
        trigger.action.outTextForCoalition(2, 'No enemy zone is far enough (>'..minNM..' NM) from the front line.', 10)
        return
    end

    BomberTargetMenu = bc:showTargetZoneMenu(2, 'Select bomb run target', function(targetZoneName, menu)
        if bomberActive then return end
        local spawnZone, dist = findClosestBlueZoneOutside(targetZoneName, minNM)
        if not spawnZone then
            trigger.action.outTextForCoalition(2, 'No friendly zone available for Bomb spawn '..minNM..'+ NM away.', 15)
            return
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnBomberAt(spawnZone, targetZoneName, offset)
        BomberTargetMenu = nil
    end, 1, nil, allow)

    trigger.action.outTextForCoalition(2, 'Select bomb run target zone from F10', 10)
    return
end,
function(sender, params)
    if params.zone and params.zone.side == 1 then
        if bomberActive then
            return 'Bomb run mission still in progress'
        end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return 'No friendly zone available for bomb run spawn.'
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnBomberAt(closestBlue, params.zone.zone, offset)
        return
    else
        return 'Can only target enemy zone'
    end
end)

---------------------------------------------END DYNAMIC SHOP ------------------------------------------
tanksMenu = nil
bc:registerShopItem('armor', 'Deploy armor (for combined arms)', 100, function(sender)
    
    if tanksMenu then
        return 'Choose deploy zone from F10 menu'
    end
    
    local deployTanks = function(target)
        if tanksMenu then
        
            local zn = CustomZone:getByName(target)
            zn:spawnGroup('ca-tanks')
            
            tanksMenu = nil
            trigger.action.outTextForCoalition(2, 'Friendly armor deployed at '..target, 15)
        end
    end
    
    tanksMenu = bc:showTargetZoneMenu(2, 'Deploy armor (Choose friendly zone)', deployTanks, 2)
    trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu', 15)
end,
function(sender, params)
    if params.zone and params.zone.side == 2 and not params.zone.suspended then
        
        local zn = CustomZone:getByName(params.zone.zone)
        zn:spawnGroup('ca-tanks')
        trigger.action.outTextForCoalition(2, 'Friendly armor deployed at '..params.zone.zone, 15)
    else
        return 'Can only deploy at friendly zone'
    end
end)
Group.getByName('ca-arty'):destroy()
artyMenu = nil
bc:registerShopItem('artillery', 'Deploy artillery (for combined arms)', 100, function(sender)
    
    if artyMenu then
        return 'Choose deploy zone from F10 menu'
    end
    
    local deployArty = function(target)
        if artyMenu then
        
            local zn = CustomZone:getByName(target)
            zn:spawnGroup('ca-arty')
            
            artyMenu = nil
            trigger.action.outTextForCoalition(2, 'Friendly artillery deployed at '..target, 15)
        end
    end
    
    artyMenu = bc:showTargetZoneMenu(2, 'Deploy artillery (Choose friendly zone)', deployArty, 2)
    trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu', 15)
end,
function(sender, params)
    if params.zone and params.zone.side == 2 and not params.zone.suspended then
        
        local zn = CustomZone:getByName(params.zone.zone)
        zn:spawnGroup('ca-arty')
        trigger.action.outTextForCoalition(2, 'Friendly artillery deployed at '..params.zone.zone, 15)
    else
        return 'Can only deploy at friendly zone'
    end
end)
Group.getByName('ca-recon'):destroy()
reconMenu = nil
bc:registerShopItem('recon', 'Deploy recon group (for combined arms)', 50, function(sender)
    
    if reconMenu then
        return 'Choose deploy zone from F10 menu'
    end
    
    local deployRecon = function(target)
        if reconMenu then
        
            local zn = CustomZone:getByName(target)
            zn:spawnGroup('ca-recon')
            
            reconMenu = nil
            trigger.action.outTextForCoalition(2, 'Friendly recon group deployed at '..target, 15)
        end
    end
    
    reconMenu = bc:showTargetZoneMenu(2, 'Deploy recon group (Choose friendly zone)', deployRecon, 2)
    trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu', 15)
end,
function(sender, params)
    if params.zone and params.zone.side == 2 then
        
        local zn = CustomZone:getByName(params.zone.zone)
        zn:spawnGroup('ca-recon')
        trigger.action.outTextForCoalition(2, 'Friendly recon group deployed at '..params.zone.zone, 15)
    else
        return 'Can only deploy at friendly zone'
    end
end)
Group.getByName('ca-airdef'):destroy()
airdefMenu = nil
bc:registerShopItem('airdef', 'Deploy air defence (for combined arms)', 150, function(sender)
    
    if airdefMenu then
        return 'Choose deploy zone from F10 menu'
    end
    
    local deployAirDef = function(target)
        if airdefMenu then
        
            local zn = CustomZone:getByName(target)
            zn:spawnGroup('ca-airdef')
            
            airdefMenu = nil
            trigger.action.outTextForCoalition(2, 'Friendly air defence deployed at '..target, 15)
        end
    end
    
    airdefMenu = bc:showTargetZoneMenu(2, 'Deploy air defence (Choose friendly zone)', deployAirDef, 2)
    trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu', 15)
end,
function(sender, params)
    if params.zone and params.zone.side == 2 then
        
        local zn = CustomZone:getByName(params.zone.zone)
        zn:spawnGroup('ca-airdef')
        trigger.action.outTextForCoalition(2, 'Friendly air defence deployed at '..params.zone.zone, 15)
    else
        return 'Can only deploy at friendly zone'
    end
end)

----------------------- end of decoy menu -----------------------

local upgradeMenu = nil
bc:registerShopItem('supplies2', 'Resupply friendly Zone', 200, function(sender)
    if upgradeMenu then
        return 'Choose zone from F10 menu'
    end

    local upgradeZone = function(target)
        if upgradeMenu then
            local zn = bc:getZoneByName(target)
            if zn and zn.side == 2 then
                zn:upgrade()
            else
                return 'Zone not friendly'
            end
            
            upgradeMenu = nil
        end
    end


    upgradeMenu = bc:showTargetZoneMenu(2, 'Select Zone to resupply', upgradeZone, 2, true)
    
    trigger.action.outTextForCoalition(2, 'Supplies prepared. Choose zone from F10 menu', 15)
end,
function(sender, params)
    if params.zone and params.zone.side == 2 then
        params.zone:upgrade()
    else
        return 'Can only target friendly zone'
    end
end)

local fullyUpgradeMenu=nil
bc:registerShopItem('supplies','Fully Upgrade Friendly Zone',1000,
function(sender)
    if fullyUpgradeMenu then
        return'Choose zone from F10 menu to fully upgrade'
    end
    local fullyUpgradeZone
    fullyUpgradeZone=function(target)
        if fullyUpgradeMenu then
            local zn=bc:getZoneByName(target)
            if zn and zn.side==2 then
                local function repairs()
                    local n=0
                    for _,v in pairs(zn.built)do
                        local g=Group.getByName(v)
                        if g then
                            if g:getSize()<g:getInitialSize() then n=n+1
                            else
                                for _,u in ipairs(g:getUnits())do
                                    if u and u:isExist() and u:getLife()<u:getLife0() then n=n+1 break end
                                end
                            end
                        end
                    end
                    return n
                end
                local upgs=zn.upgrades.blue or{}
                local todo=repairs()+(#upgs-Utils.getTableSize(zn.built))
                if todo>0 then
                    local function loop()
                        local before=Utils.getTableSize(zn.built)
                        zn:upgrade()
                        local now=Utils.getTableSize(zn.built)
                        if repairs()>0 or now<#upgs then
                            SCHEDULER:New(nil,loop,{},2,0)
                        else
                            trigger.action.outTextForCoalition(2,target..' is now fully upgraded!',15)
                        end
                    end
                    loop()
                else
                    trigger.action.outTextForCoalition(2,target..' is already fully upgraded',15)
                end
            else
                return'Zone not friendly'
            end
            fullyUpgradeMenu=nil
        end
    end
    fullyUpgradeMenu=bc:showTargetZoneMenu(2,'Select Zone to Fully Upgrade',fullyUpgradeZone,2,true)
    trigger.action.outTextForCoalition(2,'Preparing to full upgrade and repair. Choose zone from F10 menu',15)
end,
function(sender,params)
    if params.zone and params.zone.side==2 then
        local zn=params.zone
        local upgs=zn.upgrades.blue or{}
        local function repairs()
            local n=0
            for _,v in pairs(zn.built)do
                local g=Group.getByName(v)
                if g then
                    if g:getSize()<g:getInitialSize() then n=n+1
                    else
                        for _,u in ipairs(g:getUnits())do
                            if u and u:isExist() and u:getLife()<u:getLife0() then n=n+1 break end
                        end
                    end
                end
            end
            return n
        end
        local function loop()
            local before=Utils.getTableSize(zn.built)
            zn:upgrade()
            local now=Utils.getTableSize(zn.built)
            if repairs()>0 or now<#upgs then
                SCHEDULER:New(nil,loop,{},2,0)
			else
				trigger.action.outTextForCoalition(2,params.zone.zone..' is now fully upgraded!',15)
			end
        end
        loop()
    else
        return'Can only target friendly zone'
    end
end)



-- new menu
local supplyMenu=nil
bc:registerShopItem('capture','Capture neutral zone',500,
function(sender)
	if supplyMenu then
		return 'Choose a zone from F10 menu'
	end
    local cost=500
    trigger.action.outTextForCoalition(2,'Select zone from F10 menu',15)
    supplyMenu=bc:showEmergencyNeutralZoneMenu(2,'Select Zone for Emergency capture',
    function(zonename)
        if not zonename then
            bc:addFunds(2,cost)
            if supplyMenu then missionCommands.removeItemForCoalition(2,supplyMenu) end
            supplyMenu=nil
            trigger.action.outTextForCoalition(2,'No zone name selected, purchase refunded',10)
            return 'No zone name'
        end
        local chosenZone=bc:getZoneByName(zonename)
        if not chosenZone then
            bc:addFunds(2,cost)
            if supplyMenu then missionCommands.removeItemForCoalition(2,supplyMenu) end
            supplyMenu=nil
            trigger.action.outTextForCoalition(2,'Zone not found, purchase refunded',10)
            return 'Zone not found'
        end
        if chosenZone.side~=0 then
            bc:addFunds(2,cost)
            if supplyMenu then missionCommands.removeItemForCoalition(2,supplyMenu) end
            supplyMenu=nil
            trigger.action.outTextForCoalition(2,'Zone is not neutral anymore, purchase refunded',10)
            return 'Zone is no longer neutral!'
        end
        local bestCommander,status=findNearestAvailableSupplyCommander(chosenZone)
        if not bestCommander then
            bc:addFunds(2,cost)
            if supplyMenu then missionCommands.removeItemForCoalition(2,supplyMenu) end
            supplyMenu=nil
            if status=='inprogress' then
                trigger.action.outTextForCoalition(2,'Supply to '..chosenZone.zone..' already in progress, purchase refunded',10)
                return 'Supply mission in progress for this zone'
            else
                trigger.action.outTextForCoalition(2,'No suitable supply group found for '..chosenZone.zone..', purchase refunded',10)
                return 'No available supply convoys'
            end
        end
        bestCommander.targetzone=zonename
        bestCommander.state='preparing'
        bestCommander.urgent=true
        bestCommander.lastStateTime=timer.getAbsTime()-999999
        trigger.action.outTextForCoalition(2,'Emergency Capture from '..bestCommander.name..' heading to '..zonename,10)
        if supplyMenu then
            missionCommands.removeItemForCoalition(2,supplyMenu)
            supplyMenu=nil
        end
        return nil
    end)
    return nil
end,
function(sender,params)
    if not params.zone or params.zone.side~=0 then
        return 'Zone is not neutral'
    end
    local chosenZone=bc:getZoneByName(params.zone.zone)
    local bestCommander,status=findNearestAvailableSupplyCommander(chosenZone)
    if not bestCommander then
        if status=='inprogress' then
            return 'Supply mission in progress for this zone'
        else
            return 'No available supply convoys'
        end
    end
    bestCommander.targetzone=params.zone.zone
    bestCommander.state='preparing'
    bestCommander.urgent=true
    bestCommander.lastStateTime=timer.getAbsTime()-999999
    trigger.action.outTextForCoalition(2,'Emergency Capture from '..bestCommander.name..' heading to '..params.zone.zone,10)
    return nil
end)

local intelMenu=nil
bc:registerShopItem('intel','Intel on enemy zone',150,function(sender)
	if intelMenu then
		return 'Already choosing a zone'
	end
	local pickZone = function(targetZoneName)
        if intelMenu then
            local zoneObj = bc:getZoneByName(targetZoneName)
            if not zoneObj or zoneObj.side ~= 1 or zoneObj.suspended then
				return 'Must pick an enemy zone'
			end
			intelActiveZones[targetZoneName] = true
			startZoneIntel(targetZoneName)
			trigger.action.outTextForCoalition(2, 'Intel available for '..targetZoneName..'. Check Zone status. Valid for 1 hour', 15)
			timer.scheduleFunction(function(args)
				local zName = args[1]
				local zn = bc:getZoneByName(zName)
				if not zn or zn.side ~= 1 or not zn.suspended then return end
				if intelActiveZones[zName] then
					intelActiveZones[zName] = false
					trigger.action.outTextForCoalition(2, 'Intel on '..zName..' has expired.', 10)
				end
			end, {targetZoneName}, timer.getTime()+60*60)
			intelMenu = nil
		end
	end
	intelMenu = bc:showTargetZoneMenu(2, 'Choose Enemy Zone for Intel', pickZone, 1)
	trigger.action.outTextForCoalition(2, 'Intel purchase started. Select enemy zone from F10 menu.', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		intelActiveZones[params.zone.zone] = true
		startZoneIntel(params.zone.zone)
		trigger.action.outTextForCoalition(2, 'Intel available for '..params.zone.zone..'. Check Zone status. Valid for 1 hour', 15)
		SCHEDULER:New(nil,function(zName)
			if intelActiveZones[zName] then
				intelActiveZones[zName] = false
				trigger.action.outTextForCoalition(2, 'Intel on '..zName..' has expired.', 10)
			end
		end,{params.zone.zone},3600)
	else
		return 'Must pick an enemy zone'
	end
end)

------------------------------------------- Zone upgrades --------------------------------------------
local function buildAllowTable()
	local t = {}
	for _, z in pairs(bc:getZones()) do
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
        if z.side == 2 and (z.upgradesUsed or 0) < max
           and not z.zone:lower():find("carrier") and not z.suspended then
			t[z.zone] = true
		end
	end
	return t
end

local function buildLogisticAllowTable()
	local allowed = {}
	for _, z in pairs(bc:getZones()) do
		if z.side == 2 and z.airbaseName and not z.LogisticCenter and not z.isHidden and not z.suspended then
			allowed[z.zone] = true
		end
	end
	return allowed
end

local function buildWarehouseResupplyAllowTable()
	local allowed = {}
	if not WarehouseLogistics then
		return allowed
	end
	for _, z in pairs(bc:getZones()) do
		if z.side == 2 and z.airbaseName and not z.LogisticCenter and not z.isHidden and not z.suspended then
			allowed[z.zone] = true
		end
	end
	return allowed
end

local function applyLogisticCenterUpgrade(zoneObj)
	if not zoneObj or zoneObj.side ~= 2 or zoneObj.suspended then
		return 'Must pick friendly zone'
	end
	if not zoneObj.airbaseName then
		return 'Zone must have an airbase'
	end
	if zoneObj.LogisticCenter then
		return 'Zone already upgraded'
	end
	if type(zoneObj.canRecieveSupply) == 'function' and zoneObj:canRecieveSupply() then
		return 'The zone must be fully upgraded first!'
	end

	local ok, err = bc:addWarehouseItemsAtZone(zoneObj, 2, 500000)
	if not ok then
		return err or 'Unable to restock warehouse'
	end

	zoneObj.LogisticCenter = true
	if type(zoneObj.updateLabel) == 'function' then
		zoneObj:updateLabel()
	end

	trigger.action.outTextForCoalition(2, zoneObj.zone..' is now a Logistic Center. Warehouse restocked.', 15)
	return true
end

local function applyWarehouseResupply(zoneObj)
	if not WarehouseLogistics then
		return 'Warehouse logistics is disabled'
	end
	if not zoneObj or zoneObj.side ~= 2 or zoneObj.suspended then
		return 'Must pick friendly zone'
	end
	if not zoneObj.airbaseName then
		return 'Zone must have an airbase'
	end
	if zoneObj.LogisticCenter then
		return 'Zone already upgraded'
	end
	local ok, err = bc:addWarehouseItemsAtZone(zoneObj, 2, 50)
	if not ok then
		return err or 'Unable to restock warehouse'
	end

	trigger.action.outTextForCoalition(2, zoneObj.zone..' warehouse resupplied with 50 items.', 15)
	return true
end

local infMenu=nil
bc:registerShopItem('zinf','Add infantry group to zone',500,function(sender)
	if infMenu then
		return 'Already choosing a zone'
	end
	local pickZone=function(zName)
		if infMenu then
			local z=bc:getZoneByName(zName)
			if not z or z.side~=2 or z.suspended then
				return 'Must pick friendly zone'
			end
			if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
				return 'Zone already upgraded'
			end
			z:addExtraSlot('blueInfantry') -- checked
			z:updateLabel()
			if bc.globalExtraUnlock then
                trigger.action.outTextForCoalition(2,'Infantry added to '..zName..' for 500',10)
            else
                trigger.action.outTextForCoalition(2,'Infantry added to '..zName..' for 500 - buy the Global extra slot to upgrade this zone again',30)
            end
			missionCommands.removeItemForCoalition(2,infMenu)
			infMenu=nil
		end
	end
	local allow = buildAllowTable()
	if not next(allow) then
		if not bc.globalExtraUnlock then
			return 'All zones already upgraded - purchase Global extra slot to add another'
		end
		return 'No eligible zone'
	end
	infMenu = bc:showTargetZoneMenu(2,'Choose Zone for Infantry',pickZone,2,nil,allow)
	trigger.action.outTextForCoalition(2,'Select friendly zone from F10 menu.',15)
end,
function(sender,params)
	if params.zone and params.zone.side==2 then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return 'Zone already upgraded - purchase Global extra slot to add another'
			end
			return 'Zone already upgraded'
		end
		params.zone:addExtraSlot('blueInfantry') -- checked
		params.zone:updateLabel()
		if bc.globalExtraUnlock then
		trigger.action.outTextForCoalition(2,'Infantry added to '..params.zone.zone..' for 500',10)
		else
		trigger.action.outTextForCoalition(2,'Infantry added to '..params.zone.zone..' for 500 - buy the Global extra slot to upgrade this zone again',30)
		end
	else
		return 'Must pick friendly zone'
	end
end)
local samLabel = (Era == 'Coldwar') and 'Add Hawk system to a zone'
                                   or  'Add Nasams system to a zone'
local samMenu=nil
bc:registerShopItem('zsam',samLabel,2000,function(sender)
	if samMenu then
		return 'Already choosing a zone'
	end
	local pickZone=function(zName)
		if samMenu then
			local z=bc:getZoneByName(zName)
			if not z or z.side~=2 or z.suspended then
				return 'Must pick friendly zone'
			end
		if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
			return 'Zone already upgraded'
		end
            local slot = (Era == 'Coldwar') and 'blueHAWK-Coldwar' or 'bluePD1' -- checked
            z:addExtraSlot(slot)
			z:updateLabel()
			local sys = (Era == 'Coldwar') and 'Hawk' or 'Nasams'
            if bc.globalExtraUnlock then	
                trigger.action.outTextForCoalition(2,sys..' added to '..zName..' for 2000',10)
            else
                trigger.action.outTextForCoalition(2,sys..' added to '..zName..' for 2000 - buy the Global extra slot to upgrade this zone again',30)
            end
			missionCommands.removeItemForCoalition(2,samMenu)
			samMenu=nil
		end
	end

	local allow = buildAllowTable()
	if not next(allow) then
		if not bc.globalExtraUnlock then
			return 'All zones already upgraded - purchase Global extra slot to add another'
		end
		return 'No eligible zone'
	end
	samMenu = bc:showTargetZoneMenu(2,'Choose Zone for SAM',     pickZone,2,nil,allow)
	trigger.action.outTextForCoalition(2,'Select friendly zone from F10 menu.',15)
end,
function(sender,params)
	if params.zone and params.zone.side==2 then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return 'Zone already upgraded - purchase Global extra slot to add another'
			end
			return 'Zone already upgraded'
		end
		params.zone:addExtraSlot((Era == 'Coldwar') and 'blueHAWK-Coldwar' or 'bluePD1') --checked
		params.zone:updateLabel()
		local sys = (Era == 'Coldwar') and 'Hawk' or 'Nasams'
        if bc.globalExtraUnlock then
            trigger.action.outTextForCoalition(2,sys..' added to '..params.zone.zone..' for 2000',10)
        else
            trigger.action.outTextForCoalition(2,sys..' added to '..params.zone.zone..' for 2000 - buy the Global extra slot to upgrade this zone again',30)
        end
	else
		return 'Must pick friendly zone'
	end
end)

local logiMenu=nil
bc:registerShopItem('zlogc','Upgrade zone to logistic center',2000,function(sender)
	if logiMenu then
		return 'Already choosing a zone'
	end
	local allow = buildLogisticAllowTable()
	if not next(allow) then
		return 'No eligible airbase zones'
	end
	local pickZone=function(zName)
		if not logiMenu then return end
		local zoneObj = bc:getZoneByName(zName)
		local result = applyLogisticCenterUpgrade(zoneObj)
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
	logiMenu = bc:showTargetZoneMenu(2,'Choose zone for Logistic Center',pickZone,2,nil,allow)
	trigger.action.outTextForCoalition(2,'Select friendly fully-upgraded airbase zone from F10 menu.',15)
end,
function(sender,params)
	if params.zone then
		return applyLogisticCenterUpgrade(params.zone)
	end
	return 'Must pick friendly zone'
end)

local warehouseMenu=nil
bc:registerShopItem('zwh50','Resupply warehouse with 50',500,function(sender)
	if warehouseMenu then
		return 'Already choosing a zone'
	end
	if not WarehouseLogistics then
		return 'Warehouse logistics is disabled'
	end
	local allow = buildWarehouseResupplyAllowTable()
	if not next(allow) then
		return 'No eligible airbase zones'
	end
	local pickZone=function(zName)
		if not warehouseMenu then return end
		local zoneObj = bc:getZoneByName(zName)
		local result = applyWarehouseResupply(zoneObj)
		if result == true then
			missionCommands.removeItemForCoalition(2,warehouseMenu)
			warehouseMenu=nil
		else
			if type(result) == 'string' then
				trigger.action.outTextForCoalition(2,result,10)
			end
			return result
		end
	end
	warehouseMenu = bc:showTargetZoneMenu(2,'Choose zone to resupply warehouse',pickZone,2,nil,allow)
	trigger.action.outTextForCoalition(2,'Select friendly airbase zone from F10 menu.',15)
end,
function(sender,params)
	if params.zone then
		return applyWarehouseResupply(params.zone)
	end
	return 'Must pick friendly zone'
end)

local armMenu=nil
bc:registerShopItem('zarm','Add armor group to a zone',1000,function(sender)
	if armMenu then
		return 'Already choosing a zone'
	end
	local pickZone=function(zName)
		if armMenu then
			local z=bc:getZoneByName(zName)
			if not z or z.side~=2 or z.suspended then
				return 'Must pick friendly zone'
			end
			if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
				return 'Zone already upgraded'
			end
			local slotID = (Era == 'Coldwar') and 'blueArmor-Coldwar' or 'blueArmor' -- checked
			z:addExtraSlot(slotID)
			z:updateLabel()
			if bc.globalExtraUnlock then
				trigger.action.outTextForCoalition(2,'Armor added to '..zName..' for 1000',10)
			else
				trigger.action.outTextForCoalition(2,'Armor added to '..zName..' for 1000 - buy the Global extra slot to upgrade this zone again',30)
			end
			missionCommands.removeItemForCoalition(2,armMenu)
			armMenu=nil
		end
	end
	local allow = buildAllowTable()
	if not next(allow) then
		if not bc.globalExtraUnlock then
			return 'All zones already upgraded - purchase Global extra slot to add another'
		end
		return 'No eligible zone'
	end
	armMenu = bc:showTargetZoneMenu(2,'Choose Zone for Armor',   pickZone,2,nil,allow)
	trigger.action.outTextForCoalition(2,'Select friendly zone from F10 menu.',15)
end,
function(sender,params)
	if params.zone and params.zone.side==2 then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return 'Zone already upgraded - purchase Global extra slot to add another'
			end
			return 'Zone already upgraded'
		end
		local slotID = (Era == 'Coldwar') and 'blueArmor-Coldwar' or 'blueArmor' -- checked
		params.zone:addExtraSlot(slotID)
		params.zone:updateLabel()
		if bc.globalExtraUnlock then
			trigger.action.outTextForCoalition(2,'Armor added to '..params.zone.zone..' for 1000',10)
		else
			trigger.action.outTextForCoalition(2,'Armor added to '..params.zone.zone..' for 1000\nBuy the Global extra slot to upgrade this zone again',30)
		end
	else
		return 'Must pick friendly zone'
	end
end)

bc:registerShopItem('gslot','Add extra upgrade slot',3000,function(sender)
    if bc.globalExtraUnlock then
        return 'Already unlocked'
    end
    bc.globalExtraUnlock = true
    for _,z in pairs(bc:getZones()) do

    end
    trigger.action.outTextForCoalition(2,'All zones can now buy a second upgrade',15)
	bc:removeShopItem(2, 'gslot')
	return nil
end)

Group.getByName('bluePATRIOT'):destroy()
local patMenu=nil
bc:registerShopItem('zpat','Add Patriot system to zone',5000,function(sender)
	if patMenu then
		return 'Already choosing a zone'
	end
	local pickZone=function(zName)
		if patMenu then
			local z=bc:getZoneByName(zName)
			if not z or z.side~=2 or z.suspended then
				return 'Must pick friendly zone'
			end
			if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
				return 'Zone already upgraded'
			end
			z:addExtraSlot('bluePATRIOT')
			z:updateLabel()
			if bc.globalExtraUnlock then
                trigger.action.outTextForCoalition(2,'Patriot added to '..zName..' for 5000',10)
            else
                trigger.action.outTextForCoalition(2,'Patriot added to '..zName..' for 5000 - buy the Global extra slot to upgrade this zone again',30)
            end
			missionCommands.removeItemForCoalition(2,patMenu)
			patMenu=nil
		end
	end
	local allow = buildAllowTable()
	if not next(allow) then
		if not bc.globalExtraUnlock then
			return 'All zones already upgraded - purchase Global extra slot to add another'
		end
		return 'No eligible zone'
	end
	patMenu = bc:showTargetZoneMenu(2,'Choose Zone for Patriot SAM system',pickZone,2,nil,allow)
	trigger.action.outTextForCoalition(2,'Select friendly zone from F10 menu.',15)
end,
function(sender,params)
	if params.zone and params.zone.side==2 then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return 'Zone already upgraded - purchase Global extra slot to add another'
			end
			return 'Zone already upgraded'
		end
		params.zone:addExtraSlot('bluePATRIOT')
		params.zone:updateLabel()
		if bc.globalExtraUnlock then
		trigger.action.outTextForCoalition(2,'Patriot added to '..params.zone.zone..' for 5000',10)
		else
		trigger.action.outTextForCoalition(2,'Patriot added to '..params.zone.zone..' for 5000 - buy the Global extra slot to upgrade this zone again',30)
		end
	else
		return 'Must pick friendly zone'
	end
end)
bc:registerShopItem('farphere','Deploy FARP',1000,function(sender)
        return 'Deploy a FARP via map marker.\nUse marker text: buy:farphere.\nMust be outside all zones and at least 10 NM from enemy zones.'
end,function(_, params)
        return bc:processMapFarpPurchase(params)
end)
------------------------------------------- End of Zone upgrades ----------------------------------------

-- first value below is how much in stock, the second number value is the ranking in the shop menu list, the third is the new ranking system.
bc:addShopItem(2, 'jtac', -1, 1, 2) -- MQ-9 Reaper JTAC mission
bc:addShopItem(2, 'dynamiccap', -1, 2, 2) -- CAP

bc:addShopItem(2, 'dynamiccas', -1, 3, 5) -- CAS
bc:addShopItem(2, 'dynamicbomb', -1, 4, 4) -- Bomber
bc:addShopItem(2, 'dynamicsead', -1, 5, 4) -- SEAD
bc:addShopItem(2, 'dynamicdecoy', -1, 6, 1) -- Decoy flight
--[[ if UseStatics == true then
    bc:addShopItem(2, 'dynamicstatic', -1,7,4) -- Static buildings
end ]]
bc:addShopItem(2, 'dynamicarco', -1, 8, 3) -- Navy tanker
bc:addShopItem(2, 'dynamictexaco', -1, 9, 3) -- Airforce tanker
bc:addShopItem(2, 'farphere', -1, 10, 2)
bc:addShopItem(2, 'capture', -1, 11, 1) -- emergency capture
bc:addShopItem(2, 'smoke', -1, 12, 1) -- smoke on target
bc:addShopItem(2, 'intel', -1, 13, 5) -- Intel
bc:addShopItem(2, 'supplies2', -1, 14, 1) -- upgrade friendly zone
bc:addShopItem(2, 'supplies', -1, 15, 6) -- fully upgrade friendly zone
bc:addShopItem(2, 'zlogc', -1, 16, 3) -- upgrade zone to logistic center
bc:addShopItem(2, 'zwh50', -1, 17, 1) -- resupply warehouse with 50
bc:addShopItem(2, 'zinf', -1, 18, 5) -- add infantry to a zone
bc:addShopItem(2, 'zarm', -1, 19, 7) -- add armour group to a zone
bc:addShopItem(2, 'zsam', -1, 20, 6) -- add Nasams to a zone
bc:addShopItem(2, 'gslot', 1, 21, 9) -- add another slot for upgrade
if Era == 'Modern' then
    bc:addShopItem(2, 'zpat', -1, 22, 8) -- Patriot system.
end
bc:addShopItem(2, 'armor', -1, 23, 3) -- combined arms
bc:addShopItem(2, 'artillery', -1, 24, 3) -- combined arms
bc:addShopItem(2, 'recon', -1, 25, 3) -- combined arms
bc:addShopItem(2, 'airdef', -1, 26, 3) -- combined arms
bc:addShopItem(2, '9lineam', -1, 27, 1) -- free jtac
bc:addShopItem(2, '9linefm', -1, 28, 1) -- free jtac
-----------------------------------------------

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


buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end



