env.info("Mission Setup : is loading.")

local L10N = FH_L10N
local function LT(T) return T or L10N end
local function LTGet(key) return L10N:Get(key) end
local function LTFormat(key, ...) return L10N:DeferredFormat(key, ...) end

if Era =='Coldwar' then
    env.info("Mission Setup : Cold War Era selected.")
else
    env.info("Mission Setup : Modern Era selected.")
end

local function random(min,max) return min + math.random()*(max - min) end

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

WaypointList = {
	BigginHill = ' (1)',
	Odiham = ' (2)',
	Farnborough = ' (3)',
	Manston = ' (4)',
	Hawkinge = ' (5)',
	Lympne = ' (6)',
	Chailey = ' (7)',
	Ford = ' (8)',
	Tangmere = ' (9)',
	Funtington = ' (10)',
	['Needs Oar Point'] = ' (11)',
	Friston = ' (12)',
	Dunkirk = ' (13)',
	['Dunkirk-Port'] = ' (14)',
	['Saint-Omer'] = ' (15)',
	Merville = ' (16)',
	Abbeville = ' (17)',
	Amiens = ' (18)',
	Cherbourg = ' (19)',
	Calais = ' (20)',
	['Saint-Aubain'] = ' (21)',
	Fecamp = ' (22)',
	['Le Havre'] = ' (23)',
	Rouen = ' (24)',
	Carpiquet = ' (25)',
	Caen = ' (26)',
	['Sainte-Croix'] = ' (27)',
	['Saint-Pierre'] = ' (28)',
	['Longues-Sur-Mer'] = ' (29)',
	Cricqueville = ' (30)',
	['Le Molay'] = ' (31)',
	Brucheville = ' (32)',
	Valognes = ' (33)',
	Maupertus = ' (34)',
	Bernay = ' (35)',
	['Saint-Andre'] = ' (36)',
	CarrierGroup = ' (37)',
	AxeCarrierGroup = ' (38)',
	Paris = ' (39)',
	Orly = ' (40)',
	London = ' (41)',
	['Pointe des Groins'] = ' (42)',
	['Pointe du Hoc'] = ' (43)',
	['Cap Gris-Nez'] = ' (44)',
	['Le Touquet'] = ' (45)',
	Dover = ' (46)',
}

flavor = {

	BigginHill = L10N:Format("NORMANDY_FLAVOR_WPT", 1),
	Odiham = L10N:Format("NORMANDY_FLAVOR_WPT", 2),
	Farnborough = L10N:Format("NORMANDY_FLAVOR_WPT", 3),
	Manston = L10N:Format("NORMANDY_FLAVOR_WPT", 4),
	Hawkinge = L10N:Format("NORMANDY_FLAVOR_WPT", 5),
	Lympne = L10N:Format("NORMANDY_FLAVOR_WPT", 6),
	Chailey = L10N:Format("NORMANDY_FLAVOR_WPT", 7),
	Ford = L10N:Format("NORMANDY_FLAVOR_WPT", 8),
	Tangmere = L10N:Format("NORMANDY_FLAVOR_WPT", 9),
	Funtington = L10N:Format("NORMANDY_FLAVOR_WPT", 10),
	['Needs Oar Point'] = L10N:Format("NORMANDY_FLAVOR_WPT", 11),
	Friston = L10N:Format("NORMANDY_FLAVOR_WPT", 12),
	Dunkirk = L10N:Format("NORMANDY_FLAVOR_WPT", 13),
	['Dunkirk-Port'] = L10N:Format("NORMANDY_FLAVOR_WPT", 14),
	['Saint-Omer'] = L10N:Format("NORMANDY_FLAVOR_WPT", 15),
	Merville = L10N:Format("NORMANDY_FLAVOR_WPT", 16),
	Abbeville = L10N:Format("NORMANDY_FLAVOR_WPT", 17),
	Amiens = L10N:Format("NORMANDY_FLAVOR_WPT", 18),
	Cherbourg = L10N:Format("NORMANDY_FLAVOR_WPT", 19),
	Calais = L10N:Format("NORMANDY_FLAVOR_WPT", 20),
	['Saint-Aubain'] = L10N:Format("NORMANDY_FLAVOR_WPT", 21),
	Fecamp = L10N:Format("NORMANDY_FLAVOR_WPT", 22),
	['Le Havre'] = L10N:Format("NORMANDY_FLAVOR_WPT", 23),
	Rouen = L10N:Format("NORMANDY_FLAVOR_WPT", 24),
	Carpiquet = L10N:Format("NORMANDY_FLAVOR_WPT", 25),
	Caen = L10N:Format("NORMANDY_FLAVOR_WPT", 26),
	['Sainte-Croix'] = L10N:Format("NORMANDY_FLAVOR_WPT", 27),
	['Saint-Pierre'] = L10N:Format("NORMANDY_FLAVOR_WPT", 28),
	['Longues-Sur-Mer'] = L10N:Format("NORMANDY_FLAVOR_WPT", 29),
	Cricqueville = L10N:Format("NORMANDY_FLAVOR_WPT", 30),
	['Le Molay'] = L10N:Format("NORMANDY_FLAVOR_WPT", 31),
	Brucheville = L10N:Format("NORMANDY_FLAVOR_WPT", 32),
	Valognes = L10N:Format("NORMANDY_FLAVOR_WPT", 33),
	Maupertus = L10N:Format("NORMANDY_FLAVOR_WPT", 34),
	Bernay = L10N:Format("NORMANDY_FLAVOR_WPT", 35),
	['Saint-Andre'] = L10N:Format("NORMANDY_FLAVOR_WPT", 36),
	CarrierGroup = L10N:Format("NORMANDY_FLAVOR_WPT", 37),
	AxeCarrierGroup = L10N:Format("NORMANDY_FLAVOR_WPT", 38),
	Paris = L10N:Format("NORMANDY_FLAVOR_WPT", 39),
	Orly = L10N:Format("NORMANDY_FLAVOR_WPT", 40),
	London = L10N:Format("NORMANDY_FLAVOR_WPT", 41),
	['Pointe des Groins'] = L10N:Format("NORMANDY_FLAVOR_WPT", 42),
	['Pointe du Hoc'] = L10N:Format("NORMANDY_FLAVOR_WPT", 43),
	['Cap Gris-Nez'] = L10N:Format("NORMANDY_FLAVOR_WPT", 44),
	['Le Touquet'] = L10N:Format("NORMANDY_FLAVOR_WPT", 45),
	Dover = L10N:Format("NORMANDY_FLAVOR_WPT", 46)

}

FootholdSaveBaseName = 'foothold_normandy_nomods_1.0'

local filepath = FootholdSaveBaseName .. '.lua'
if lfs then
  FootholdSavePath = FootholdSavePath or (lfs.writedir()..'Missions/Saves')
  lfs.mkdir(FootholdSavePath)
  filepath = FootholdSavePath .. '/' .. (FootholdSaveBaseName .. '.lua')
  env.info('Foothold - Save file path: '..filepath)
end

upgrades = {
	-- CarrierEssexUpgrades = {
	-- 	blue = {"CarrierEssexSeaman"},
	-- 	red = {}
	-- },
    CarrierUpgrades = {
        blue = {"CarrierGroup-Chase", "CarrierGroup-LST",},
        red = {}
    },
    AxeCarrierUpgrades = {
        blue = {"CarrierGroup-LST", "CarrierGroup-LST"},
        red = {'AxeCarrierGroup-Chase','AxeCarrierGroup-LST','AxeCarrierGroup-subs', 'AxeCarrierGroup-schnell'}
    },
    airfieldUK1 = {
        blue = {"UK-INF-MK1", "UK-ARMOR", "UK-AAA-OPTFLAK", "UK-TRUCK", "UK-AAA-bofors", "UK-AAA-M1"},
        red = {}
    },
	airfieldUK2 = {
        blue = {"UK-INF-MK1", "UK-ARMOR", "UK-AAA-OPTFLAK", "UK-TRUCK", "UK-AAA-QF", "UK-AAA-M45"},
        red = {}
    },
	airfieldFR1 = {
        blue = {"UK-INF-MK1", "UK-ARMOR", "UK-AAA-OPTFLAK", "UK-TRUCK", "UK-AAA-bofors", "UK-ARTY-FHM2A1"},
        red = {"AXE-ARTY-FH", "AXE-ARMOR-LIGHT", "AXE-AAA-OPTFLAK", "AXE-TRUCK", "AXE-AAA-18-36"}
    },
	airfieldFR2 = {
        blue = {"UK-INF-MK1", "UK-ARMOR", "UK-AAA-OPTFLAK", "UK-TRUCK", "UK-AAA-bofors", "UK-ARTY-L118"},
        red = {"AXE-ARTY-SPH", "AXE-ARMOR-LIGHT", "AXE-AAA-OPTFLAK", "AXE-TRUCK", "AXE-AAA-37-41"}
    },

	DunkirkPort = {
		blue = {},
		red = {}
	},
	Cherbourg = {
		blue = {},
		red = {}
	},
	Calais = {
		blue = {},
		red = {}
	},
	LeHavre = {
		blue = {},
		red = {}
	},
	Caen = {
		blue = {},
		red = {}
	},
	Valognes = {
		blue = {},
		red = {}
	},
	Paris = {
		blue = {},
		red = {"Paris-AAA-37-41", "Paris-AAA-37-41-1", "Paris-AAA-37-41-2"}
	},
	Orly = {
		blue = {},
		red = {"AXE-ARTY-SPH", "AXE-ARMOR-TIG-PAN", "AXE-AAA-OPTFLAK", "AXE-TRUCK", "AXE-AAA-37-41"}
	},
	London = {
		blue = {"London-AAA-bofors", "London-AAA-bofors-1", "London-AAA-bofors-2"},
		red = {}
	},
	empty = {
		blue = {},
		red = {}
	},
	V1 = {
		blue = {},
		red = {"AXE-INF-MAUSER98"}
	},
	V1_Brecourt = {
		blue = {},
		red = {"AXE-INF-MAUSER98", "V1 Launch Site - Brecourt", "Fueltank-Brecourt"}
	},
	V1_Wallon_Cappel = {
		blue = {},
		red = {"AXE-INF-MAUSER98", "V1 Launch Site - Wallon-Cappel", "Fueltank-WallonCappel"}
	},
	V1_Crecy_Forest = {
		blue = {},
		red = {"AXE-INF-MAUSER98", "V1 Launch Site - Crecy Forest", "Fueltank-CrecyForest"}
	},
	V1_Flixecourt = {
		blue = {},
		red = {"AXE-INF-MAUSER98", "V1 Launch Site - Flixecourt", "Fueltank-Flixecourt"}
	},
	V1_Val_Ygot = {
		blue = {},
		red = {"AXE-INF-MAUSER98", "V1 Launch Site - Val Ygot", "Fueltank-ValYgot"}
	},
	V1_Herbouville = {
		blue = {},
		red = {"AXE-INF-MAUSER98", "V1 Launch Site - Herbouville", "Fueltank-Herbouville"}
	},
	V1_Neuville = {
		blue = {},
		red = {"AXE-INF-MAUSER98", "V1 Launch Site - Neuville", "Fueltank-Neuville"}
	},
	Hidden_UK_supply = {
		blue = {"UK_Tug"},
		red = {}
	},
	Hidden_AXE_supply = {
		blue = {},
		red = {"AXE_Tug"}
	},


	----------------Radar Upgrades----------------
	
	EWRPointeDesGroins = {
		blue = {},
		red = {"AXE-AAA-37-Pointe-des-Groins", "AXE-AAA-OPTFLAK-Pointe-des-Groins", "EWR-Pointe-des-Groins",}
	},
	EWRPointeDuHoc = {
		blue = {},
		red = {"EWR-PointeDuHoc",}
	},
	EWRCapGrisNez = {
		blue = {},
		red = {"EWR-CapGrisNez"}
	},
}


-- Randomized upgrade pools/templates (fresh start only)
-- Keep these explicit so V1, EWR, carrier/naval, and hidden supply groups are never picked.
RandomRedPool = {
	"AXE-TRUCK",
	"AXE-ARMOR-LIGHT",
	"AXE-ARMOR-TIG-PAN",
	"AXE-AAA-OPTFLAK",
	"AXE-AAA-18-36",
	"AXE-AAA-37-41",
	"AXE-ARTY-FH",
	"AXE-ARTY-SPH",
}

RandomBluePool = {
	"UK-INF-MK1",
	"UK-TRUCK",
	"UK-ARMOR",
	"UK-AAA-OPTFLAK",
	"UK-AAA-bofors",
	"UK-AAA-M1",
	"UK-AAA-QF",
	"UK-AAA-M45",
	"UK-ARTY-FHM2A1",
	"UK-ARTY-L118",
}

ZoneSizeExclusions = {}

RandomUpgradeTemplates = {
	small = { ground = {0,1}, aaa = {1,2}, armor = {0,1}, arty = {0,1}, total = {4,5} },
	medium = { ground = {1,1}, aaa = {1,2}, armor = {1,1}, arty = {0,1}, total = {5,6} },
	big = { ground = {0,1}, aaa = {2,3}, armor = {0,1}, arty = {0,1}, total = {3,5} },
}

RandomUpgradeTemplatesBlue = {
	small = { ground = {1,1}, aaa = {2,3}, armor = {0,1}, arty = {0,1}, total = {5,6} },
	medium = { ground = {1,1}, aaa = {2,3}, armor = {1,1}, arty = {0,1}, total = {5,6} },
	big = { ground = {0,1}, aaa = {2,3}, armor = {0,1}, arty = {0,1}, total = {3,5} },
}


RandomGroundGroups = true
RandomBlueGroups = true
AllowScriptedSupplies = AllowScriptedSupplies ~= false

bc = BattleCommander:new(filepath, 10, 60)
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
env.info('Foothold - Rank file path: '..bc.rankFile)
end
Hunt = true

zones = {
    BigginHill = ZoneCommander:new({zone='BigginHill', side=2, size='medium', level=20, upgrades=upgrades.airfieldUK1, crates={}, flavorText=flavor.BigginHill, customSuspendNmBlue = 62}),
	Odiham = ZoneCommander:new({zone='Odiham', side=2, size='medium', level=20, upgrades=upgrades.airfieldUK2, crates={}, flavorText=flavor.Odiham}),
	Farnborough = ZoneCommander:new({zone='Farnborough', side=2, size='medium', level=20, upgrades=upgrades.airfieldUK1, crates={}, flavorText=flavor.Farnborough}),
	Manston = ZoneCommander:new({zone='Manston', side=2, size='medium', level=20, upgrades=upgrades.airfieldUK1, crates={}, flavorText=flavor.Manston}),
	Dover = ZoneCommander:new({zone='Dover', side=2, size='big', level=20, upgrades=upgrades.airfieldUK1, crates={}, flavorText=flavor.Dover, income=1}),
	Hawkinge = ZoneCommander:new({zone='Hawkinge', side=2, size='small', level=20, upgrades=upgrades.airfieldUK1, crates={}, flavorText=flavor.Hawkinge}),
	Lympne = ZoneCommander:new({zone='Lympne', side=2, size='small', level=20, upgrades=upgrades.airfieldUK2, crates={}, flavorText=flavor.Lympne}),
	Chailey = ZoneCommander:new({zone='Chailey', side=2, size='small', level=20, upgrades=upgrades.airfieldUK2, crates={}, flavorText=flavor.Chailey}),
	Ford = ZoneCommander:new({zone='Ford', side=2, size='small', level=20, upgrades=upgrades.airfieldUK1, crates={}, flavorText=flavor.Ford}),
	Tangmere = ZoneCommander:new({zone='Tangmere', side=2, size='small', level=20, upgrades=upgrades.airfieldUK1, crates={}, flavorText=flavor.Tangmere}),
	Funtington = ZoneCommander:new({zone='Funtington', side=2, size='small', level=20, upgrades=upgrades.airfieldUK2, crates={}, flavorText=flavor.Funtington}),
	NeedsOarPoint = ZoneCommander:new({zone='Needs Oar Point', side=2, size='small', level=20, upgrades=upgrades.airfieldUK1, crates={}, flavorText=flavor.NeedsOarPoint}),
	Friston = ZoneCommander:new({zone='Friston', side=2, size='small', level=20, upgrades=upgrades.airfieldUK1, crates={}, flavorText=flavor.Friston}),
	Dunkirk = ZoneCommander:new({zone='Dunkirk', side=1, size='medium', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.Dunkirk}),
	DunkirkPort = ZoneCommander:new({zone='Dunkirk-Port', side=1, size='medium', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.DunkirkPort, income=1}),
	SaintOmer = ZoneCommander:new({zone='Saint-Omer', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.SaintOmer}),
	Merville = ZoneCommander:new({zone='Merville', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.Merville}),
	Abbeville = ZoneCommander:new({zone='Abbeville', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.Abbeville}),
	Amiens = ZoneCommander:new({zone='Amiens', side=1, size='medium', level=20, upgrades=upgrades.airfieldFR2, crates={}, flavorText=flavor.Amiens}),
	Cherbourg = ZoneCommander:new({zone='Cherbourg', side=1, size='medium', level=20, upgrades=upgrades.airfieldFR2, crates={}, flavorText=flavor.Cherbourg, income=1}),
	Calais = ZoneCommander:new({zone='Calais', side=1, size='medium', level=20, upgrades=upgrades.airfieldFR2, crates={}, flavorText=flavor.Calais, income=1}),
	SaintAubain = ZoneCommander:new({zone='Saint-Aubain', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.SaintAubain}),
	Fecamp = ZoneCommander:new({zone='Fecamp', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.Fecamp}),
	LeHavre = ZoneCommander:new({zone='Le Havre', side=1, size='medium', level=20, upgrades=upgrades.airfieldFR2, crates={}, flavorText=flavor.LeHavre, income=1}),
	Rouen = ZoneCommander:new({zone='Rouen', side=1, size='medium', level=20, upgrades=upgrades.airfieldFR2, crates={}, flavorText=flavor.Rouen}),
	Carpiquet = ZoneCommander:new({zone='Carpiquet', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.Carpiquet}),
	Caen = ZoneCommander:new({zone='Caen', side=1, size='medium', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.Caen, income=1}),
	SainteCroix = ZoneCommander:new({zone='Sainte-Croix', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.SainteCroix}),
	SaintPierre = ZoneCommander:new({zone='Saint-Pierre', side=1, size='small', level=20, upgrades=upgrades.airfieldFR2, crates={}, flavorText=flavor.SaintPierre}),
	LonguesSurMer = ZoneCommander:new({zone='Longues-Sur-Mer', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.LonguesSurMer}),
	Cricqueville = ZoneCommander:new({zone='Cricqueville', side=1, size='small', level=20, upgrades=upgrades.airfieldFR2, crates={}, flavorText=flavor.Cricqueville}),
	LeMolay = ZoneCommander:new({zone='Le Molay', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.LeMolay}),
	Brucheville = ZoneCommander:new({zone='Brucheville', side=1, size='small', level=20, upgrades=upgrades.airfieldFR2, crates={}, flavorText=flavor.Brucheville}),
	Valognes = ZoneCommander:new({zone='Valognes', side=1, size='medium', level=20, upgrades=upgrades.airfieldFR2, crates={}, flavorText=flavor.Valognes}),
	Maupertus = ZoneCommander:new({zone='Maupertus', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.Maupertus}),
	Bernay = ZoneCommander:new({zone='Bernay', side=1, size='small', level=20, upgrades=upgrades.airfieldFR2, crates={}, flavorText=flavor.Bernay}),
	SaintAndre = ZoneCommander:new({zone='Saint-Andre', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor.SaintAndre}),
	CarrierGroup = ZoneCommander:new({zone='CarrierGroup', side=2, level=20, upgrades=upgrades.CarrierUpgrades, crates={}, flavorText=flavor.CarrierGroup}),
	--hiddenCarrierEssex = ZoneCommander:new({zone='HiddenCarrierEssex', side=2, level=20, upgrades=upgrades.CarrierEssexUpgrades}),
	AxeCarrierGroup = ZoneCommander:new({zone='AxeCarrierGroup', side=1, level=20, upgrades=upgrades.AxeCarrierUpgrades, crates={}, flavorText=flavor.AxeCarrierGroup}),
	Paris = ZoneCommander:new({zone='Paris', side=1, size='big', level=20, upgrades=upgrades.Paris, crates={}, flavorText=flavor.Paris, income=1}),
	Orly = ZoneCommander:new({zone='Orly', side=1, size='big', level=20, upgrades=upgrades.Orly, crates={}, flavorText=flavor.Orly, income=1}),
	London = ZoneCommander:new({zone='London', side=2, size='big', level=20, upgrades=upgrades.London, crates={}, flavorText=flavor.London, income=1,customSuspendNmBlue = 70}),
	PointeDesGroins = ZoneCommander:new({zone='Pointe des Groins', side=1, level=20, upgrades=upgrades.EWRPointeDesGroins, crates={}, flavorText=flavor.PointeDesGroins}),
	PointeDuHoc = ZoneCommander:new({zone='Pointe du Hoc', side=1, level=20, upgrades=upgrades.EWRPointeDuHoc, crates={}, flavorText=flavor.PointeDuHoc}),
	CapGrisNez = ZoneCommander:new({zone='Cap Gris-Nez', side=1, level=20, upgrades=upgrades.EWRCapGrisNez, crates={}, flavorText=flavor.CapGrisNez}),
	LeTouquet = ZoneCommander:new({zone='Le Touquet', side=1, size='small', level=20, upgrades=upgrades.airfieldFR1, crates={}, flavorText=flavor['Le Touquet'], income=1}),
	V1_Wallon_Cappel = ZoneCommander:new({zone='V1 Launch Site - Wallon-Cappel', side=1, level=20, upgrades=upgrades.V1_Wallon_Cappel, crates={}, flavorText=flavor['V1 Launch Site - Wallon-Cappel']}),
	V1_Crecy_Forest = ZoneCommander:new({zone='V1 Launch Site - Crecy Forest', side=1, level=20, upgrades=upgrades.V1_Crecy_Forest, crates={}, flavorText=flavor['V1 Launch Site - Crecy Forest']}),
	V1_Flixecourt = ZoneCommander:new({zone='V1 Launch Site - Flixecourt', side=1, level=20, upgrades=upgrades.V1_Flixecourt, crates={}, flavorText=flavor['V1 Launch Site - Flixecourt']}),
	V1_Val_Ygot = ZoneCommander:new({zone='V1 Launch Site - Val Ygot', side=1, level=20, upgrades=upgrades.V1_Val_Ygot, crates={}, flavorText=flavor['V1 Launch Site - Val Ygot']}),
	V1_Herbouville = ZoneCommander:new({zone='V1 Launch Site - Herbouville', side=1, level=20, upgrades=upgrades.V1_Herbouville, crates={}, flavorText=flavor['V1 Launch Site - Herbouville']}),
	V1_Brecourt = ZoneCommander:new({zone='V1 Launch Site - Brecourt', side=1, level=20, upgrades=upgrades.V1_Brecourt, crates={}, flavorText=flavor['V1 Launch Site - Brecourt']}),
	V1_Neuville = ZoneCommander:new({zone='V1 Launch Site - Neuville', side=1, level=20, upgrades=upgrades.V1_Neuville, crates={}, flavorText=flavor['V1 Launch Site - Neuville']}),

	hiddenUKNavalbasePortsmouth = ZoneCommander:new({zone='HiddenUKNavalbasePortsmouth', side=2, level=20, upgrades=upgrades.Hidden_UK_supply}),
	hiddenUKNavalbaseDover = ZoneCommander:new({zone='HiddenUKNavalbaseDover', side=2, level=20, upgrades=upgrades.Hidden_UK_supply}),
	hiddenAXENavalbaseCherbourg = ZoneCommander:new({zone='HiddenAXENavalbaseCherbourg', side=1, level=20, upgrades=upgrades.Hidden_AXE_supply}),
	hiddenAXENavalbaseDieppe = ZoneCommander:new({zone='HiddenAXENavalbaseDieppe', side=1, level=20, upgrades=upgrades.Hidden_AXE_supply}),
	hiddenAXENavalbaseLeHavre = ZoneCommander:new({zone='HiddenAXENavalbaseLeHavre', side=1, level=20, upgrades=upgrades.Hidden_AXE_supply}),
	hiddenAXENavalbaseDunkirk = ZoneCommander:new({zone='HiddenAXENavalbaseDunkirk', side=1, level=20, upgrades=upgrades.Hidden_AXE_supply}),
	-- hiddenRailwayLondonVictoriaStation = ZoneCommander:new({zone='HiddenRailwayLondonVictoriaStation', side=2, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayWaterlooStation = ZoneCommander:new({zone='HiddenRailwayWaterlooStation', side=2, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayLondonBridgeStation = ZoneCommander:new({zone='HiddenRailwayLondonBridgeStation', side=2, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayDover = ZoneCommander:new({zone='HiddenRailwayDover', side=0, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayFord = ZoneCommander:new({zone='HiddenRailwayFord', side=2, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayHawkinge = ZoneCommander:new({zone='HiddenRailwayHawkinge', side=2, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayCherbourg = ZoneCommander:new({zone='HiddenRailwayCherbourg', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayValognes = ZoneCommander:new({zone='HiddenRailwayValognes', side=0, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayCaen = ZoneCommander:new({zone='HiddenRailwayCaen', side=0, level=20, upgrades=upgrades.empty}),
	-- hiddenTrainDepotValognes = ZoneCommander:new({zone='HiddenTrainDepotValognes', side=0, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayLeHavre = ZoneCommander:new({zone='HiddenRailwayLeHavre', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayBernay = ZoneCommander:new({zone='HiddenRailwayBernay', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwaySaintAndre = ZoneCommander:new({zone='HiddenRailwaySaintAndre', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayOrly = ZoneCommander:new({zone='HiddenRailwayOrly', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayParisSaintLazare = ZoneCommander:new({zone='HiddenRailwayParisSaintLazare', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayParisGareDuNord = ZoneCommander:new({zone='HiddenRailwayParisGareDuNord', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayParisGareDeLest = ZoneCommander:new({zone='HiddenRailwayParisGareDeLest', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayFecamp = ZoneCommander:new({zone='HiddenRailwayFecamp', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayPowerplantFecamp = ZoneCommander:new({zone='HiddenRailwayPowerplantFecamp', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayDepotRouen = ZoneCommander:new({zone='HiddenRailwayDepotRouen', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayRouen = ZoneCommander:new({zone='HiddenRailwayRouen', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayDepotSaintAubain = ZoneCommander:new({zone='HiddenRailwayDepotSaintAubain', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayTrainDepotAmiens = ZoneCommander:new({zone='HiddenRailwayTrainDepotAmiens', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayAbbeville = ZoneCommander:new({zone='HiddenRailwayAbbeville', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayDunkirkPort = ZoneCommander:new({zone='HiddenRailwayDunkirkPort', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayLeTouquet = ZoneCommander:new({zone='HiddenRailwayLeTouquet', side=1, level=20, upgrades=upgrades.empty}),
	-- hiddenRailwayCalais = ZoneCommander:new({zone='HiddenRailwayCalais', side=1, level=20, upgrades=upgrades.empty}),
}

-- Railway subzone to parent zone mapping
-- This defines which railway subzones are contained within which parent zones
-- RAILWAY_SUBZONE_MAPPING = {
--     ["hiddenRailwayFord"] = "Ford",           -- hiddenRailwayFord subzone is inside Ford zone
--     ["hiddenRailwayCherbourg"] = "Cherbourg", -- hiddenRailwayCherbourg subzone is inside Cherbourg zone
-- 	["hiddenRailwayValognes"] = "Valognes",   -- hiddenRailwayValognes subzone is inside Valognes zone
-- 	["hiddenTrainDepotValognes"] = "Valognes", -- hiddenTrainDepotValognes subzone is inside Valognes zone
-- 	["hiddenRailwayCaen"] = "Caen",           -- hiddenRailwayCaen subzone is inside Caen zone
-- 	["hiddenRailwayLeHavre"] = "LeHavre",     -- hiddenRailwayLeHavre subzone is inside LeHavre zone
-- 	["hiddenRailwayBernay"] = "Bernay",       -- hiddenRailwayBernay subzone is inside Bernay zone
-- 	["hiddenRailwaySaintAndre"] = "SaintAndre", -- hiddenRailwaySaintAndre subzone is inside SaintAndre zone
-- 	["hiddenRailwayOrly"] = "Orly",           -- hiddenRailwayOrly subzone is inside Orly zone
-- 	["hiddenRailwayParisSaintLazare"] = "Paris", -- hiddenRailwayParisSaintLazare subzone is inside Paris zone
-- 	["hiddenRailwayParisGareDuNord"] = "Paris",  -- hiddenRailwayParisGareDuNord subzone is inside Paris zone
-- 	["hiddenRailwayParisGareDeLest"] = "Paris",  -- hiddenRailwayParisGareDeLest subzone is inside Paris zone
-- 	["hiddenRailwayFecamp"] = "Fecamp",           -- hiddenRailwayFecamp subzone is inside Fecamp zone
-- 	["hiddenRailwayPowerplantFecamp"] = "Fecamp", -- hiddenRailwayPowerplantFecamp subzone is inside Fecamp zone
-- 	["hiddenRailwayDepotRouen"] = "Rouen",             -- hiddenRailwayDepotRouen subzone is inside Rouen zone
-- 	["hiddenRailwayDepotSaintAubain"] = "SaintAubain", -- hiddenRailwayDepotSaintAubain subzone is inside SaintAubain zone
-- 	["hiddenRailwayTrainDepotAmiens"] = "Amiens",     -- hiddenRailwayTrainDepotAmiens subzone is inside Amiens zone
-- 	["hiddenRailwayAbbeville"] = "Abbeville",         -- hiddenRailwayAbbeville subzone is inside Abbeville zone
-- 	["hiddenRailwayDunkirkPort"] = "DunkirkPort",   -- hiddenRailwayDunkirkPort subzone is inside DunkirkPort zone
-- 	["hiddenRailwayLeTouquet"] = "LeTouquet",       -- hiddenRailwayLeTouquet subzone is inside LeTouquet zone
-- 	["hiddenRailwayCalais"] = "Calais",             -- hiddenRailwayCalais subzone is inside Calais zone


-- }


--- Napalm Funtion for V1 site------------------
--- 
napalmCounter = 1

local options = {
  ["napalm"] = true, 
  ["phosphor"] = true,
  ["bigsmoke"] = true,
}


-- Napalm explosion functions (copied from napalm_unit.lua)


local function explodeNapalm(vec3)
    trigger.action.explosion(vec3, 10)
end

local function bigSmoke(vec3)
    trigger.action.effectSmokeBig(vec3, 2, 0.5)
end
local function removeNapalm(staticName) 
StaticObject.getByName(staticName):destroy()
end

local function phosphor(vec3) 
	for i =	1,math.random(3, 10) do 
        azimuth = 30 * i
		--angle = mist.utils.toRadian((math.random(1, 360)))
		--local randVec = mist.utils.makeVec3GL((mist.getRandPointInCircle(vec3, 5, 1, 0, 360)))
		trigger.action.signalFlare(vec3, 2, azimuth)
	end
end

local function napalmOnImpact(impactPoint)
	--env.info("Napalm Impact at: x=" .. tostring(impactPoint.x) .. ", y=" .. tostring(impactPoint.y) .. ", z=" .. tostring(impactPoint.z))
	local napalmName = "napalmImpact" .. napalmCounter
	napalmCounter = napalmCounter + 1
    local owngroupID = math.random(9999,99999)
    local cvnunitID = math.random(9999,99999)
_dataFuel =   
    {
        ["groupId"] = owngroupID,
        ["category"] = "Fortifications",
        ["shape_name"] = "toplivo-bak",
        ["type"] = "Fuel tank",
        ["unitId"] = cvnunitID,
        ["rate"] = 100,
        ["y"] = impactPoint.z,
        ["x"] = impactPoint.x,
        ["name"] = napalmName,
        ["heading"] = 0,
        ["dead"] = false,
        ["hidden"] = true,

    } -- end of function
    

    
    if options.napalm == true then
        coalition.addStaticObject(country.id.CJTF_BLUE, _dataFuel )
        timer.scheduleFunction(explodeNapalm, impactPoint, timer.getTime() + 0.1)
        timer.scheduleFunction(removeNapalm, napalmName, timer.getTime() + 0.12)
    end
  
    if options.phosphor == true then
        timer.scheduleFunction(phosphor, impactPoint, timer.getTime() + 0.12)
    end
	if options.bigsmoke == true then
    	timer.scheduleFunction(bigSmoke, impactPoint, timer.getTime() + 5)
	end


end
function searchTargets(pType, pzone)
	local foundUnits = {}
    local sphere = trigger.misc.getZone(pzone)
	local volS = {
	   id = world.VolumeType.SPHERE,
	   params = {
		 point = sphere.point,
		 radius = sphere.radius
	   }
	 }
	 local ifFound = function(foundItem, val)
				foundUnits[#foundUnits + 1] = foundItem
				return true
			end
	world.searchObjects(pType, volS, ifFound)
	return foundUnits
end

function fUnitCoord(pzone)
    local FoundUnits = nil
	local targetCoord = nil
	local TGT = nil
    
	--local FoundUnits = searchTargets({Object.Category.UNIT, Object.Category.STATIC, Object.Category.SCENERY})
    local FoundUnits = searchTargets(Object.Category.UNIT, pzone)
	if 	FoundUnits ~= nil and #FoundUnits > 0 then
		for i, targetUnit in ipairs(FoundUnits) do
            local delay = math.random(10,20)
			targetCoord = targetUnit:getPoint()
			TYP = targetUnit:getTypeName()
			TGT = targetUnit:getName()
            CAT = targetUnit:getCategory()
            OBJCAT = Object.getCategory(targetUnit)
			
            --trigger.action.outText(TGT.. ': X: '.. targetCoord.x .. ' Y: ' .. targetCoord.y .. ' Z: ' .. targetCoord.z, 10)
            --trigger.action.outText(TGT.. ':: '.. TYP , 10)
            env.info(TGT.. ':: '.. TYP)
            if TYP == "V1x10" or TYP == "v1_launcher" or TYP == "fire_control" then  -- only target units and statics
                timer.scheduleFunction(napalmOnImpact, targetCoord, timer.getTime() + delay)
                if TYP == "V1x10" or TYP == "v1_launcher" then
                    CustomFlags[TGT] = true
                end
            end
        end
	else
		zeusMessages.setMessageDelayed("No Target found in the zone" , 30, 8, true)
		return false
	end
end;



CapPlaneTemplate = CapPlaneTemplate or {
	'AXECapFw190D9Template',
	'AXECapBf109Template',
	'UKCapP51Template',
	'UKCapSpitFireTemplate',
}
CasPlaneTemplate = CasPlaneTemplate or {
	'AXECasJU88Template',
	'UKCasP47Template',
	'UKCasMosquitoTemplate',
	'UKCasA20Template',
	'UKCasF4UDTemplate',
}

CapCarrierGroup = CapCarrierGroup or {
	'UKCapF4UDTemplate',
}

RunwayStrikePlaneTemplate = RunwayStrikePlaneTemplate or {
	"UKCasMosquitoTemplate",
	"AXERunwayJU88Template",
}
RunwayStrikePlaneTemplate2 = RunwayStrikePlaneTemplate2 or {
	"DynamicStructure_Template",
}

SupplyConvoy = SupplyConvoy or {
    "AxeConvoySupplyTemplate",
    "UKConvoySupplyTemplate",
}

SupplyAirTemplate = SupplyAirTemplate or {
	"AxeC47SupplyTemplate",
	"UKC47SupplyTemplate",
}

SupplyNavalTemplate = SupplyNavalTemplate or {
	"AxeNavalSupplyTemplate",
	"UKNavalSupplyTemplate",
}
AntiShipPlaneTemplate = AntiShipPlaneTemplate or {
	"UKAntiShipF4UDTemplate",
	"UKAntishipP47Template",
	"AXEAntiShipFw190D9Template",
	"AXEAntishipJU88Template",
}

BattleshipTemplate = BattleshipTemplate or {
	"AXEBattleshipTemplate",
	"UKBattleshipTemplate",
}
ArtilleryConvoy = ArtilleryConvoy or {
	"AXEArtilleryConvoy",
	"UKArtilleryConvoy",
}
function CasAltitude() return math.random(5,15)*1000 end
function CapAltitude() return math.random(15,20)*1000 end
--function SeadAltitude() return math.random(25,33)*1000 end
function RunwayStrikeAltitude() return math.random(23,28)*1000 end



zones.Amiens:addGroups({
    --GroupCommander:new({name='AXE_Amiens-resupply-Abbeville', mission='supply', targetzone='Abbeville', type = 'surface'}),
    --GroupCommander:new({name='AXE_Amiens-resupply-Fecamp', mission='supply', targetzone='Fecamp', type = 'surface'}),
	GroupCommander:new({name='AXE_Amiens-attack-Chailey', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Chailey', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='AXE_Amiens-attack-Lympne', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Lympne', Altitude = CasAltitude()}),
	GroupCommander:new({name='AXE_Amiens-attack-Friston', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Friston', Altitude = CapAltitude()}),
    -- UK missions (active when Amiens is blue-captured)
    GroupCommander:new({name='UK_Amiens-resupply-Abbeville', mission='supply', template='SupplyConvoy', targetzone='Abbeville', type='surface', urgent=function() return zones.Abbeville.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Amiens-resupply-Rouen', mission='supply', template='SupplyConvoy', targetzone='Rouen', type='surface', urgent=function() return zones.Rouen.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Amiens-resupply-Paris', mission='supply', template='SupplyConvoy', targetzone='Paris', type='surface', urgent=function() return zones.Paris.side == 0 end, ForceUrgent=true}),
})
zones.Abbeville:addGroups({
    --GroupCommander:new({name='AXE_Abbeville-resupply-Amiens', mission='supply', targetzone='Amiens', type = 'surface'}),
	GroupCommander:new({name='AXE_Abbeville-patrol-LeTouquet', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Le Touquet', Altitude = CapAltitude()}),
	--GroupCommander:new({name='AXE_Abbeville-resupply-SaintAubain', mission='supply', targetzone='Saint-Aubain', type = 'surface'}),
	GroupCommander:new({name='AXE_Abbeville-attack-BigginHill', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='BigginHill', Altitude = CapAltitude()}),
	GroupCommander:new({name='AXE_Abbeville-attack-Manston', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Manston', Altitude = RunwayStrikeAltitude()}),
    -- UK missions (active when Abbeville is blue-captured)
    GroupCommander:new({name='UK_Abbeville-resupply-Amiens', mission='supply', template='SupplyConvoy', targetzone='Amiens', type='surface', urgent=function() return zones.Amiens.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Abbeville-resupply-LeTouquet', mission='supply', template='SupplyConvoy', targetzone='Le Touquet', type='surface', urgent=function() return zones.LeTouquet.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Abbeville-resupply-Fecamp', mission='supply', template='SupplyConvoy', targetzone='Fecamp', type='surface', urgent=function() return zones.Fecamp.side == 0 end, ForceUrgent=true}),
})
zones.Bernay:addGroups({
    --GroupCommander:new({name='AXE_Bernay-resupply-SaintAndre', mission='supply', targetzone='SaintAndre', type = 'surface'}),
	GroupCommander:new({name='AXE_Bernay-resupply-Caen', mission='supply', template='SupplyAirTemplate', targetzone='Caen', type = 'surface'}),
    -- UK missions (active when Bernay is blue-captured)
    GroupCommander:new({name='UK_Bernay-resupply-SaintAndre', mission='supply', template='SupplyConvoy', targetzone='Saint-Andre', type='surface', urgent=function() return zones.SaintAndre.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Bernay-resupply-SaintAubain', mission='supply', template='SupplyConvoy', targetzone='Saint-Aubain', type='surface', urgent=function() return zones.SaintAubain.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Bernay-resupply-Rouen', mission='supply', template='SupplyConvoy', targetzone='Rouen', type='surface', urgent=function() return zones.Rouen.side == 0 end, ForceUrgent=true}),
})
zones.Caen:addGroups({
    GroupCommander:new({name='AXE_Caen-resupply-SainteCroix', mission='supply', template='SupplyConvoy', targetzone='Sainte-Croix', type = 'surface'}),
    GroupCommander:new({name='AXE_Caen-resupply-Carpiquet', mission='supply', template='SupplyConvoy', targetzone='Carpiquet', type = 'surface'}),
    --GroupCommander:new({name='AXE_Caen-resupply-LeMolay', mission='supply', targetzone='LeMolay', type = 'surface'}),
	GroupCommander:new({name='AXE_Caen-attack-Ford', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Ford', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='AXE_Caen-attack-NeedsOarPoint', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Needs Oar Point', Altitude = CapAltitude()}),
	GroupCommander:new({name='AXE_Caen-attack-SainteCroix-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Sainte-Croix', type='surface', SetActiveMission = true}),
    -- UK missions (active when Caen is blue-captured)
    GroupCommander:new({name='UK_Caen-resupply-Carpiquet', mission='supply', template='SupplyConvoy', targetzone='Carpiquet', type='surface', urgent=function() return zones.Carpiquet.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Caen-resupply-SainteCroix', mission='supply', template='SupplyConvoy', targetzone='Sainte-Croix', type='surface', urgent=function() return zones.SainteCroix.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Caen-resupply-LeMolay', mission='supply', template='SupplyConvoy', targetzone='Le Molay', type='surface', urgent=function() return zones.LeMolay.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Caen-resupply-LonguesSurMer', mission='supply', template='SupplyConvoy', targetzone='Longues-Sur-Mer', type='surface', urgent=function() return zones.LonguesSurMer.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Caen-resupply-SaintPierre', mission='supply', template='SupplyConvoy', targetzone='Saint-Pierre', type='surface', urgent=function() return zones.SaintPierre.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Caen-resupply-Bernay', mission='supply', template='SupplyConvoy', targetzone='Bernay', type='surface', urgent=function() return zones.Bernay.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Caen-resupply-SaintAubain', mission='supply', template='SupplyConvoy', targetzone='Saint-Aubain', type='surface', urgent=function() return zones.SaintAubain.side == 0 end, ForceUrgent=true}),
})
zones.Calais:addGroups({
    --GroupCommander:new({name='AXE_Calais-resupply-DunkirkPort', mission='supply', targetzone='DunkirkPort', type = 'surface'}),
    -- UK missions (active when Calais is blue-captured)
    GroupCommander:new({name='UK_Calais-resupply-Dunkirk', mission='supply', template='SupplyConvoy', targetzone='Dunkirk', type='surface', urgent=function() return zones.Dunkirk.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Calais-resupply-SaintOmer', mission='supply', template='SupplyConvoy', targetzone='Saint-Omer', type='surface', urgent=function() return zones.SaintOmer.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Calais-resupply-LeTouquet', mission='supply', template='SupplyConvoy', targetzone='Le Touquet', type='surface', urgent=function() return zones.LeTouquet.side == 0 end, ForceUrgent=true}),
})
zones.Carpiquet:addGroups({
	GroupCommander:new({name='AXE_Carpiquet-attack-Ford', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Ford', Altitude = CasAltitude()}),
	GroupCommander:new({name='AXE_Carpiquet-attack-Funtington', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Funtington', Altitude = CapAltitude()}),
    -- UK missions (active when Carpiquet is blue-captured)
    GroupCommander:new({name='UK_Carpiquet-resupply-Bernay', mission='supply', template='SupplyConvoy', targetzone='Bernay', type='surface', urgent=function() return zones.Bernay.side == 0 end, ForceUrgent=true}),
})
zones.Cherbourg:addGroups({
    GroupCommander:new({name='AXE_Cherbourg-resupply-Maupertus', mission='supply', template='SupplyConvoy', targetzone='Maupertus', type = 'surface'}),
    -- UK missions (active when Cherbourg is blue-captured)
    GroupCommander:new({name='UK_Cherbourg-resupply-Valognes', mission='supply', template='SupplyConvoy', targetzone='Valognes', type='surface', urgent=function() return zones.Valognes.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Cherbourg-resupply-Maupertus', mission='supply', template='SupplyConvoy', targetzone='Maupertus', type='surface', urgent=function() return zones.Maupertus.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Cherbourg-resupply-Brucheville', mission='supply', template='SupplyConvoy', targetzone='Brucheville', type='surface', urgent=function() return zones.Brucheville.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_Cherbourg-attack-Valognes-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Valognes', type='surface', SetActiveMission = true}),
})

zones.Dunkirk:addGroups({
	GroupCommander:new({name='AXE_Dunkirk-resupply-Calais', mission='supply', template='SupplyConvoy', targetzone='Calais', type = 'surface'}),
    GroupCommander:new({name='AXE_Dunkirk-patrol-Calais', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Calais'}),
	GroupCommander:new({name='AXE_Dunkirk-attack-Manston', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Manston', Altitude = CapAltitude()}),
	GroupCommander:new({name='AXE_Dunkirk-attack-Hawkinge', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Hawkinge', Altitude = CasAltitude()}),
    -- UK missions (active when Dunkirk is blue-captured)
    GroupCommander:new({name='UK_Dunkirk-resupply-SaintOmer', mission='supply', template='SupplyConvoy', targetzone='Saint-Omer', type='surface', urgent=function() return zones.SaintOmer.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Dunkirk-resupply-Merville', mission='supply', template='SupplyConvoy', targetzone='Merville', type='surface', urgent=function() return zones.Merville.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_Dunkirk-resupply-Calais', mission='supply', template='SupplyConvoy', targetzone='Calais', type = 'surface'}),
})
zones.DunkirkPort:addGroups({
	GroupCommander:new({name='AXE_DunkirkPort-resupply-LeHavre', mission='supply', template='SupplyNavalTemplate', targetzone='Le Havre', type = 'surface'}),
    GroupCommander:new({name='AXE_DunkirkPort-resupply-Dunkirk', mission='supply', template='SupplyConvoy', targetzone='Dunkirk', type = 'surface'}),
    GroupCommander:new({name='AXE_DunkirkPort-resupply-SaintOmer', mission='supply', template='SupplyConvoy', targetzone='Saint-Omer', type = 'surface'}),
    -- UK missions (active when DunkirkPort is blue-captured)
    GroupCommander:new({name='UK_DunkirkPort-resupply-Dunkirk', mission='supply', template='SupplyConvoy', targetzone='Dunkirk', type='surface', urgent=function() return zones.Dunkirk.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_DunkirkPort-resupply-SaintOmer', mission='supply', template='SupplyConvoy', targetzone='Saint-Omer', type='surface', urgent=function() return zones.SaintOmer.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_DunkirkPort-resupply-Merville', mission='supply', template='SupplyConvoy', targetzone='Merville', type='surface', urgent=function() return zones.Merville.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_DunkirkPort-attack-Dunkirk-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Dunkirk', type='surface', SetActiveMission = true}),
})
zones.Fecamp:addGroups({
    --GroupCommander:new({name='AXE_Fecamp-resupply-LeHavre', mission='supply', targetzone='Le Havre', type = 'surface'}),
	GroupCommander:new({name='AXE_Fecamp-patrol-LeHavre', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Le Havre', Altitude = CapAltitude()}),
	GroupCommander:new({name='UK_Manston-attack-CarrierGroup', mission='attack', template='AntiShipPlaneTemplate', MissionType='ANTISHIP', targetzone='CarrierGroup', Altitude = CasAltitude()}),
	GroupCommander:new({name='AXE_Fecamp-attack-Chailey', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Chailey', Altitude = CapAltitude()}),
	GroupCommander:new({name='AXE_Fecamp-attack-Ford', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Ford', Altitude = CasAltitude()}),
    -- UK missions (active when Fecamp is blue-captured)
    GroupCommander:new({name='UK_Fecamp-resupply-LeHavre', mission='supply', template='SupplyConvoy', targetzone='Le Havre', type='surface', urgent=function() return zones.LeHavre.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Fecamp-resupply-Rouen', mission='supply', template='SupplyConvoy', targetzone='Rouen', type='surface', urgent=function() return zones.Rouen.side == 0 end, ForceUrgent=true}),
})
zones.Maupertus:addGroups({
	GroupCommander:new({name='AXE_Maupertus-patrol-Cherbourg', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Cherbourg', Altitude = CapAltitude()}),
	GroupCommander:new({name='AXE_Maupertus-attack-NeedsOarPoint', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Needs Oar Point', Altitude = CasAltitude()}),
	GroupCommander:new({name='AXE_Maupertus-attack-CarrierGroup', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='CarrierGroup', Altitude = CasAltitude()}),
	GroupCommander:new({name='AXE_Maupertus-attack-Odiham', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Odiham', Altitude = CasAltitude()}),
	GroupCommander:new({name='AXE_Maupertus-attack-Farnborough', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Farnborough', Altitude = RunwayStrikeAltitude()}),
    -- UK missions (active when Maupertus is blue-captured)
    GroupCommander:new({name='UK_Maupertus-resupply-Valognes', mission='supply', template='SupplyConvoy', targetzone='Valognes', type='surface', urgent=function() return zones.Valognes.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Maupertus-resupply-Brucheville', mission='supply', template='SupplyConvoy', targetzone='Brucheville', type='surface', urgent=function() return zones.Brucheville.side == 0 end, ForceUrgent=true}),
})

zones.Merville:addGroups({
    GroupCommander:new({name='AXE_Merville-resupply-SaintOmer', mission='supply', template='SupplyConvoy', targetzone='Saint-Omer', type = 'surface'}),
	GroupCommander:new({name='AXE_Merville-attack-BigginHill', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='BigginHill', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='AXE_Merville-attack-Chailey', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Chailey', Altitude = CasAltitude()}),
	GroupCommander:new({name='AXE_Merville-attack-Lympne', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Lympne', Altitude = CapAltitude()}),
    -- UK missions (active when Merville is blue-captured)
    GroupCommander:new({name='UK_Merville-resupply-Abbeville', mission='supply', template='SupplyConvoy', targetzone='Abbeville', type='surface', urgent=function() return zones.Abbeville.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Merville-resupply-LeHavre', mission='supply', template='SupplyConvoy', targetzone='Le Havre', type='surface', urgent=function() return zones.LeHavre.side == 0 end, ForceUrgent=true}),
})

zones.LeHavre:addGroups({
    --GroupCommander:new({name='AXE_LeHavre-resupply-Fecamp', mission='supply', targetzone='Fecamp', type = 'surface'}),
    --GroupCommander:new({name='AXE_LeHavre-resupply-Rouen', mission='supply', targetzone='Rouen', type = 'surface'}),
	GroupCommander:new({name='AXE_LeHavre-attack-Tangmere', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tangmere', Altitude = CasAltitude()}),
	GroupCommander:new({name='AXE_LeHavre-attack-Funtington', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Funtington', Altitude = RunwayStrikeAltitude()}),
    -- UK missions (active when Le Havre is blue-captured)
    GroupCommander:new({name='UK_LeHavre-resupply-Fecamp', mission='supply', template='SupplyConvoy', targetzone='Fecamp', type='surface', urgent=function() return zones.Fecamp.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_LeHavre-resupply-Rouen', mission='supply', template='SupplyConvoy', targetzone='Rouen', type='surface', urgent=function() return zones.Rouen.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_LeHavre-resupply-Bernay', mission='supply', template='SupplyConvoy', targetzone='Bernay', type='surface', urgent=function() return zones.Bernay.side == 0 end, ForceUrgent=true}),
})
zones.LeMolay:addGroups({
    GroupCommander:new({name='AXE_LeMolay-resupply-Cricqueville', mission='supply', template='SupplyConvoy', targetzone='Cricqueville', type = 'surface'}),
	GroupCommander:new({name='AXE_LeMolay-resupply-LonguesSurMer', mission='supply', template='SupplyConvoy', targetzone='Longues-Sur-Mer', type = 'surface'}),
	GroupCommander:new({name='AXE_LeMolay-resupply-SaintPierreDuMont', mission='supply', template='SupplyConvoy', targetzone='Saint-Pierre', type = 'surface'}),
	--GroupCommander:new({name='AXE_LeMolay-patrol-SainteCroix', mission='patrol', targetzone='Sainte-Croix'}),
	--GroupCommander:new({name='AXE_LeMolay-patrol-SaintPierre', mission='patrol', targetzone='Saint-Pierre'}),
	GroupCommander:new({name='AXE_LeMolay-patrol-Caen', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Caen', Altitude = CapAltitude()}),
	GroupCommander:new({name='AXE_LeMolay-attack-Funtington', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Funtington', Altitude = CasAltitude()}),
	GroupCommander:new({name='AXE_LeMolay-attack-NeedsOarPoint', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Needs Oar Point', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='AXE_LeMolay-attack-SaintPierreDuMont-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Saint-Pierre', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='AXE_LeMolay-attack-LonguesSurMer-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Longues-Sur-Mer', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='AXE_LeMolay-attack-Cricqueville-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Cricqueville', type='surface', SetActiveMission = true}),
    -- UK missions (active when Le Molay is blue-captured)
    GroupCommander:new({name='UK_LeMolay-resupply-Cricqueville', mission='supply', template='SupplyConvoy', targetzone='Cricqueville', type='surface', urgent=function() return zones.Cricqueville.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_LeMolay-resupply-LonguesSurMer', mission='supply', template='SupplyConvoy', targetzone='Longues-Sur-Mer', type='surface', urgent=function() return zones.LonguesSurMer.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_LeMolay-resupply-SaintPierre', mission='supply', template='SupplyConvoy', targetzone='Saint-Pierre', type='surface', urgent=function() return zones.SaintPierre.side == 0 end, ForceUrgent=true}),
})

zones.Orly:addGroups({
    GroupCommander:new({name='AXE_Orly-resupply-LeHavre', mission='supply', template='SupplyAirTemplate', targetzone='Le Havre', type = 'surface'}),
	GroupCommander:new({name='AXE_Orly-resupply-Caen', mission='supply', template='SupplyAirTemplate', targetzone='Caen', type = 'surface'}),
	GroupCommander:new({name='AXE_Orly-resupply-SaintAndre', mission='supply', template='SupplyAirTemplate', targetzone='Saint-Andre', type = 'surface'}),
	GroupCommander:new({name='AXE_Orly-resupply-Amiens', mission='supply', template='SupplyAirTemplate', targetzone='Amiens', type = 'surface'}),
	GroupCommander:new({name='AXE_Orly-resupply-Merville', mission='supply', template='SupplyAirTemplate', targetzone='Merville', type = 'surface'}),
	GroupCommander:new({name='AXE_Orly-resupply-DunkirkPort', mission='supply', template='SupplyAirTemplate', targetzone='Dunkirk-Port', type = 'surface'}),
	GroupCommander:new({name='AXE_Orly-resupply-Cherbourg', mission='supply', template='SupplyAirTemplate', targetzone='Cherbourg', type = 'surface'}),	
})

zones.Paris:addGroups({
    --GroupCommander:new({name='AXE_Paris-resupply-Fecamp', mission='supply', targetzone='Fecamp', type = 'surface'}),
    --GroupCommander:new({name='AXE_Paris-resupply-SaintAubain', mission='supply', targetzone='Saint-Aubain', type = 'surface'}),
    -- UK missions (active when Paris is blue-captured)
    GroupCommander:new({name='UK_Paris-resupply-Orly', mission='supply', template='SupplyConvoy', targetzone='Orly', type='surface', urgent=function() return zones.Orly.side == 0 end, ForceUrgent=true}),
})
zones.SaintAubain:addGroups({
    GroupCommander:new({name='AXE_SaintAubain-patrol-Rouen', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rouen', Altitude = CapAltitude()}),
	-- GroupCommander:new({name='AXE_SaintAubain-resupply-AxeCarrierGroup', mission='supply', template='SupplyNavalTemplate', targetzone='AxeCarrierGroup', type = 'surface'}),
	GroupCommander:new({name='AXE_SaintAubain-attack-Friston', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Friston', Altitude = CasAltitude()}),
	GroupCommander:new({name='AXE_SaintAubain-attack-Tangmere', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Tangmere', Altitude = RunwayStrikeAltitude()}),
    -- UK missions (active when Saint-Aubain is blue-captured)
    GroupCommander:new({name='UK_SaintAubain-resupply-Rouen', mission='supply', template='SupplyConvoy', targetzone='Rouen', type='surface', urgent=function() return zones.Rouen.side == 0 end, ForceUrgent=true}),
})

zones.SainteCroix:addGroups({
    --GroupCommander:new({name='AXE_SainteCroix-resupply-Caen', mission='supply', targetzone='Caen', type = 'surface'}),
    -- UK missions (active when Sainte-Croix is blue-captured)
    GroupCommander:new({name='UK_SainteCroix-resupply-LeMolay', mission='supply', template='SupplyConvoy', targetzone='Le Molay', type='surface', urgent=function() return zones.LeMolay.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_SainteCroix-resupply-SaintPierre', mission='supply', template='SupplyConvoy', targetzone='Saint-Pierre', type='surface', urgent=function() return zones.SaintPierre.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_SainteCroix-attack-Caen-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Caen', type='surface', SetActiveMission = true}),	
	GroupCommander:new({name='UK_SainteCroix-attack-Carpiquet-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Carpiquet', type='surface', SetActiveMission = true}),	
})
zones.SaintOmer:addGroups({
    --GroupCommander:new({name='AXE_SaintOmer-resupply-Merville', mission='supply', targetzone='Merville', type = 'surface'}),
	GroupCommander:new({name='AXE_SaintOmer-attack-Hawkinge', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Hawkinge', Altitude = CasAltitude()}),
	GroupCommander:new({name='AXE_SaintOmer-attack-Lympne', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Lympne', Altitude = RunwayStrikeAltitude()}),
    -- UK missions (active when Saint-Omer is blue-captured)
    GroupCommander:new({name='UK_SaintOmer-resupply-Merville', mission='supply', template='SupplyConvoy', targetzone='Merville', type='surface', urgent=function() return zones.Merville.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_SaintOmer-resupply-Abbeville', mission='supply', template='SupplyConvoy', targetzone='Abbeville', type='surface', urgent=function() return zones.Abbeville.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_SaintOmer-resupply-LeTouquet', mission='supply', template='SupplyConvoy', targetzone='Le Touquet', type='surface', urgent=function() return zones.LeTouquet.side == 0 end, ForceUrgent=true}),
})
zones.Valognes:addGroups({
    GroupCommander:new({name='AXE_Valognes-resupply-Brucheville', mission='supply', template='SupplyConvoy', targetzone='Brucheville', type = 'surface'}),
    --GroupCommander:new({name='AXE_Valognes-resupply-LeMolay', mission='supply', targetzone='Le Molay', type = 'surface'}),
	GroupCommander:new({name='AXE_Valognes-attack-Cherbourg-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Cherbourg', type='surface', SetActiveMission = true}),
    -- UK missions (active when Valognes is blue-captured)
    GroupCommander:new({name='UK_Valognes-resupply-LeMolay', mission='supply', template='SupplyConvoy', targetzone='Le Molay', type='surface', urgent=function() return zones.LeMolay.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Valognes-resupply-Brucheville', mission='supply', template='SupplyConvoy', targetzone='Brucheville', type='surface', urgent=function() return zones.Brucheville.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_Valognes-attack-Brucheville-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Brucheville', type='surface', SetActiveMission = true}),
})
-- New blocks for zones with no previous groupcommander entries
zones.Rouen:addGroups({
    -- UK missions (active when Rouen is blue-captured)
    GroupCommander:new({name='UK_Rouen-resupply-Amiens', mission='supply', template='SupplyConvoy', targetzone='Amiens', type='surface', urgent=function() return zones.Amiens.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Rouen-resupply-Fecamp', mission='supply', template='SupplyConvoy', targetzone='Fecamp', type='surface', urgent=function() return zones.Fecamp.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Rouen-resupply-SaintAndre', mission='supply', template='SupplyConvoy', targetzone='Saint-Andre', type='surface', urgent=function() return zones.SaintAndre.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Rouen-resupply-SaintAubain', mission='supply', template='SupplyConvoy', targetzone='Saint-Aubain', type='surface', urgent=function() return zones.SaintAubain.side == 0 end, ForceUrgent=true}),
})
zones.LeTouquet:addGroups({
    -- UK missions (active when Le Touquet is blue-captured)
    GroupCommander:new({name='UK_LeTouquet-resupply-Abbeville', mission='supply', template='SupplyConvoy', targetzone='Abbeville', type='surface', urgent=function() return zones.Abbeville.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_LeTouquet-resupply-Merville', mission='supply', template='SupplyConvoy', targetzone='Merville', type='surface', urgent=function() return zones.Merville.side == 0 end, ForceUrgent=true}),
})
zones.SaintAndre:addGroups({
    -- UK missions (active when Saint-Andre is blue-captured)
    GroupCommander:new({name='UK_SaintAndre-resupply-Rouen', mission='supply', template='SupplyConvoy', targetzone='Rouen', type='surface', urgent=function() return zones.Rouen.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_SaintAndre-resupply-Orly', mission='supply', template='SupplyConvoy', targetzone='Orly', type='surface', urgent=function() return zones.Orly.side == 0 end, ForceUrgent=true}),
})
zones.SaintPierre:addGroups({
    -- UK missions (active when Saint-Pierre is blue-captured)
    GroupCommander:new({name='UK_SaintPierre-resupply-LeMolay', mission='supply', template='SupplyConvoy', targetzone='Le Molay', type='surface', urgent=function() return zones.LeMolay.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_SaintPierre-resupply-SainteCroix', mission='supply', template='SupplyConvoy', targetzone='Sainte-Croix', type='surface', urgent=function() return zones.SainteCroix.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_SaintPierre-attack-LeMolay-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Le Molay', type='surface', SetActiveMission = true}),	
})
zones.LonguesSurMer:addGroups({
    -- UK missions (active when Longues-Sur-Mer is blue-captured)
    GroupCommander:new({name='UK_LonguesSurMer-resupply-LeMolay', mission='supply', template='SupplyConvoy', targetzone='Le Molay', type='surface', urgent=function() return zones.LeMolay.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_LonguesSurMer-resupply-SaintPierre', mission='supply', template='SupplyConvoy', targetzone='Saint-Pierre', type='surface', urgent=function() return zones.SaintPierre.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_LonguesSurMer-attack-LeMolay-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Le Molay', type='surface', SetActiveMission = true}),
})
zones.Cricqueville:addGroups({
    -- UK missions (active when Cricqueville is blue-captured)
    GroupCommander:new({name='UK_Cricqueville-resupply-LeMolay', mission='supply', template='SupplyConvoy', targetzone='Le Molay', type='surface', urgent=function() return zones.LeMolay.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Cricqueville-resupply-LonguesSurMer', mission='supply', template='SupplyConvoy', targetzone='Longues-Sur-Mer', type='surface', urgent=function() return zones.LonguesSurMer.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_Cricqueville-attack-LeMolay-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Le Molay', type='surface', SetActiveMission = true}),
})
zones.Brucheville:addGroups({
    -- UK missions (active when Brucheville is blue-captured)
    GroupCommander:new({name='UK_Brucheville-resupply-Cricqueville', mission='supply', template='SupplyConvoy', targetzone='Cricqueville', type='surface', urgent=function() return zones.Cricqueville.side == 0 end, ForceUrgent=true}),
    GroupCommander:new({name='UK_Brucheville-resupply-LeMolay', mission='supply', template='SupplyConvoy', targetzone='Le Molay', type='surface', urgent=function() return zones.LeMolay.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_Brucheville-attack-Cricqueville-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Cricqueville', type='surface', SetActiveMission = true}),
	--GroupCommander:new({name='UK_Brucheville-attack-LeMolay-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Le Molay', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='UK_Brucheville-attack-SaintPierre-Arty', mission='attack',template='ArtilleryConvoy',MissionType='ARTY',Reward=250, targetzone='Saint-Pierre', type='surface', SetActiveMission = true}),
})

zones.BigginHill:addGroups({
	GroupCommander:new({name='UK_BigginHill-resupply-London', mission='supply', template='SupplyAirTemplate', targetzone='London', type = 'surface'}),
    GroupCommander:new({name='UK_BigginHill-resupply-Manston', mission='supply', template='SupplyAirTemplate', targetzone='Manston', type = 'surface'}),
    GroupCommander:new({name='UK_BigginHill-resupply-Dover', mission='supply', template='SupplyAirTemplate', targetzone='Dover', type = 'surface'}),
	GroupCommander:new({name='UK_BigginHill-resupply-Friston', mission='supply', template='SupplyAirTemplate', targetzone='Friston', type = 'surface'}),
	GroupCommander:new({name='UK_BigginHill-resupply-Chailey', mission='supply', template='SupplyAirTemplate', targetzone='Chailey', type = 'surface'}),
	GroupCommander:new({name='UK_BigginHill-resupply-Calais', mission='supply', template='SupplyAirTemplate', targetzone='Calais', type = 'surface', urgent = function() return zones.Calais.side == 0 end, ForceUrgent = true}),
	GroupCommander:new({name='UK_BigginHill-attack-LeHavre', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Le Havre', Altitude = CasAltitude()}),
	--GroupCommander:new({name='UK_BigginHill-attack-LeHavre-escort', mission='escort', targetzone='Le Havre', type = 'air'}),
	GroupCommander:new({name='UK_BigginHill-attack-DunkirkPort', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Dunkirk-Port', Altitude = CasAltitude()}),
	--GroupCommander:new({name='UK_BigginHill-attack-DunkirkPort-escort', mission='escort', targetzone='Dunkirk-Port', type = 'air'}),
	GroupCommander:new({name='UK_BigginHill-attack-Merville', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Merville', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_BigginHill-attack-Abbeville', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abbeville', Altitude = CapAltitude()}),
	GroupCommander:new({name='UK_BigginHill-patrol-Friston', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Friston', Altitude = CapAltitude()}),

})
zones.Farnborough:addGroups({
    GroupCommander:new({name='UK_Farnborough-resupply-BigginHill', mission='supply', template='SupplyAirTemplate', targetzone='BigginHill', type = 'surface'}),
    GroupCommander:new({name='UK_Farnborough-resupply-Odiham', mission='supply', template='SupplyConvoy', targetzone='Odiham', type = 'surface'}),
	GroupCommander:new({name='UK_Farnborough-resupply-Ford', mission='supply', template='SupplyAirTemplate', targetzone='Ford', type = 'surface', urgent = function() return zones.Ford.side == 0 end, ForceUrgent = true}),
    GroupCommander:new({name='UK_Farnborough-resupply-NeedsOarPoint', mission='supply', template='SupplyAirTemplate', targetzone='Needs Oar Point', type = 'surface'}),
	GroupCommander:new({name='UK_Farnborough-attack-Caen', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Caen', Altitude = CasAltitude()}),
	--GroupCommander:new({name='UK_Farnborough-attack-Caen-escort', mission='escort', targetzone='Caen', type = 'air'}),
	GroupCommander:new({name='UK_Farnborough-attack-LeMolay', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Le Molay', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_Farnborough-attack-Carpiquet', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Carpiquet', Altitude = CapAltitude()}),
})

zones.Dover:addGroups({
	GroupCommander:new({name='UK_Dover-resupply-Hawkinge', mission='supply', template='SupplyConvoy', targetzone='Hawkinge', type = 'surface'}),
	-- GroupCommander:new({name='UK_Dover-capture-AxeCarrierGroup', mission='supply', template='SupplyNavalTemplate', targetzone='AxeCarrierGroup', type='surface', condition = function() return zones.Dover.active end, urgent = function() return zones.AxeCarrierGroup.side == 0 end, ForceUrgent = true}),
	-- GroupCommander:new({name='UK_Dover-capture-DunkirkPort', mission='supply', template='SupplyNavalTemplate', targetzone='Dunkirk-Port', type='surface', condition = function() return zones.Dover.active end, urgent = function() return zones.DunkirkPort.side == 0 end, ForceUrgent = true}),
    -- GroupCommander:new({name='UK_Dover-capture-Calais', mission='supply', template='SupplyNavalTemplate', targetzone='Calais', type = 'surface', condition = function() return zones.Dover.active end, urgent = function() return zones.Calais.side == 0 end, ForceUrgent = true}),
	-- GroupCommander:new({name='UK_Dover-supply-CarrierGroup', mission='supply', template='SupplyNavalTemplate', targetzone='CarrierGroup', type='surface'}),

})

zones.Hawkinge:addGroups({
	GroupCommander:new({name='UK_Hawkinge-resupply-Lympne', mission='supply', template='SupplyConvoy', targetzone='Lympne', type = 'surface'}),
	--GroupCommander:new({name='UK_Hawkinge-resupply-Manston', mission='supply', targetzone='Manston', type = 'surface'}),
	GroupCommander:new({name='UK_Hawkinge-attack-SaintOmer', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Saint-Omer', Altitude = CasAltitude()}),
	GroupCommander:new({name='UK_Hawkinge-attack-Merville', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Merville', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_Hawkinge-attack-Dunkirk', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Dunkirk', Altitude = CapAltitude()}),
})

zones.Ford:addGroups({
	GroupCommander:new({name='UK_Ford-resupply-Tangmere', mission='supply', template='SupplyConvoy', targetzone='Tangmere', type = 'surface'}),
	--GroupCommander:new({name='UK_Ford-resupply-Manston', mission='supply', targetzone='Manston', type = 'surface'}),
	GroupCommander:new({name='UK_Ford-attack-Caen', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Caen', Altitude = CasAltitude()}),
	GroupCommander:new({name='UK_Ford-attack-LeHavre', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Le Havre', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_Ford-attack-Fecamp', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Fecamp', Altitude = CapAltitude()}),
})
zones.Funtington:addGroups({
	GroupCommander:new({name='UK_Funtington-attack-Cherbourg', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Cherbourg', Altitude = CasAltitude()}),
	--GroupCommander:new({name='UK_Funtington-attack-Cherbourg-escort', mission='escort', targetzone='Cherbourg'}),
	--GroupCommander:new({name='UK_Ford-resupply-Manston', mission='supply', targetzone='Manston', type = 'surface'}),
	GroupCommander:new({name='UK_Funtington-attack-Carpiquet', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Carpiquet', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_Funtington-attack-Caen', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Caen', Altitude = CapAltitude()}),
})
zones.Tangmere:addGroups({
	GroupCommander:new({name='UK_Tangmere-resupply-Funtington', mission='supply', template='SupplyConvoy', targetzone='Funtington', type = 'surface'}),
	--GroupCommander:new({name='UK_Ford-resupply-Manston', mission='supply', targetzone='Manston', type = 'surface'}),
	GroupCommander:new({name='UK_Tangmere-attack-Caen', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Caen', Altitude = CasAltitude()}),
	GroupCommander:new({name='UK_Tangmere-attack-Carpiquet', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Carpiquet', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_Tangmere-attack-LeMolay', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Le Molay', Altitude = CapAltitude()}),
})
zones.Chailey:addGroups({
	GroupCommander:new({name='UK_Chailey-resupply-Friston', mission='supply', template='SupplyConvoy', targetzone='Friston', type = 'surface'}),
	GroupCommander:new({name='UK_Chailey-patrol-Friston', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Friston', Altitude = CapAltitude()}),
	GroupCommander:new({name='UK_Chailey-attack-Fecamp', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Fecamp', Altitude = CasAltitude()}),
	GroupCommander:new({name='UK_Chailey-attack-Abbeville', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Abbeville', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_Chailey-attack-Merville', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Merville', Altitude = CapAltitude()}),
})
zones.London:addGroups({
    GroupCommander:new({name='UK_London-resupply-BigginHill', mission='supply', template='SupplyConvoy', targetzone='BigginHill', type = 'surface'}),
    --GroupCommander:new({name='UK_London-resupply-Farnborough', mission='supply', targetzone='Farnborough', type = 'surface'}),
    --GroupCommander:new({name='UK_London-resupply-Ford', mission='supply', targetzone='Ford', type = 'surface'}),
    --GroupCommander:new({name='UK_London-resupply-Manston', mission='supply', targetzone='Manston', type = 'surface'}),
})
zones.Manston:addGroups({
	GroupCommander:new({name='UK_Manston-patrol-Dover', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Dover', Altitude = CapAltitude()}),
    GroupCommander:new({name='UK_Manston-resupply-DunkirkPort', mission='supply', template='SupplyAirTemplate', targetzone='Dunkirk-Port', type = 'surface', urgent = function() return zones.DunkirkPort.side == 0 end, ForceUrgent = true}),
	GroupCommander:new({name='UK_Manston-attack-AxeCarrierGroup', mission='attack', template='AntiShipPlaneTemplate', MissionType='ANTISHIP', targetzone='AxeCarrierGroup', Altitude = CasAltitude()}),
	--GroupCommander:new({name='UK_Manston-resupply-Hawkinge', mission='supply', targetzone='Hawkinge', type = 'surface'}),
	--GroupCommander:new({name='UK_Manston-resupply-Lympne', mission='supply', targetzone='Lympne', type = 'surface'}),
	GroupCommander:new({name='UK_Manston-attack-SaintOmer', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Saint-Omer', Altitude = CasAltitude()}),
	GroupCommander:new({name='UK_Manston-attack-Dunkirk', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Dunkirk', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_Manston-attack-Merville', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Merville', Altitude = CapAltitude()}),
})	
zones.NeedsOarPoint:addGroups({
	--GroupCommander:new({name='UK_NeedsOarPoint-resupply-Farnborough', mission='supply', targetzone='Farnborough', type = 'surface'}),
	GroupCommander:new({name='UK_NeedsOarPoint-patrol-Ford', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ford', Altitude = CapAltitude()}),
	GroupCommander:new({name='UK_NeedsOarPoint-resupply-Cherbourg', mission='supply', template='SupplyAirTemplate', targetzone='Cherbourg', type = 'surface', urgent = function() return zones.Cherbourg.side == 0 end, ForceUrgent = true}),
	GroupCommander:new({name='UK_NeedsOarPoint-resupply-Maupertus', mission='supply', template='SupplyAirTemplate', targetzone='Maupertus', type = 'surface', urgent = function() return zones.Maupertus.side == 0 end, ForceUrgent = true}),
	GroupCommander:new({name='UK_NeedsOarPoint-attack-Cherbourg', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Cherbourg', Altitude = CasAltitude()}),
	GroupCommander:new({name='UK_NeedsOarPoint-attack-Maupertus', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Maupertus', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_NeedsOarPoint-attack-LeMolay', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Le Molay', Altitude = CapAltitude()}),
	
})
zones.Odiham:addGroups({
	GroupCommander:new({name='UK_Odiham-resupply-Cherbourg', mission='supply', template='SupplyAirTemplate', targetzone='Cherbourg', type = 'surface', urgent = function() return zones.Cherbourg.side == 0 end, ForceUrgent = true}),
	GroupCommander:new({name='UK_Odiham-resupply-Caen', mission='supply', template='SupplyAirTemplate', targetzone='Caen', type = 'surface', urgent = function() return zones.Caen.side == 0 end, ForceUrgent = true}),
	--GroupCommander:new({name='UK_Odiham-resupply-BigginHill', mission='supply', targetzone='BigginHill', type = 'surface'}),
	GroupCommander:new({name='UK_Odiham-attack-Caen', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Caen', Altitude = CasAltitude()}),
	GroupCommander:new({name='UK_Odiham-attack-Carpiquet', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Carpiquet', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_Odiham-attack-Cherbourg', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Cherbourg', Altitude = CapAltitude()}),
})
zones.Lympne:addGroups({
	GroupCommander:new({name='UK_Lympne-attack-SaintOmer', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Saint-Omer', Altitude = CasAltitude()}),
	GroupCommander:new({name='UK_Lympne-attack-Abbeville', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Abbeville', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_Lympne-attack-Merville', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Merville', Altitude = CapAltitude()}),
})
zones.Friston:addGroups({
	GroupCommander:new({name='UK_Friston-attack-Fecamp', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Fecamp', Altitude = CasAltitude()}),
	GroupCommander:new({name='UK_Friston-attack-Merville', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Merville', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='UK_Friston-attack-Abbeville', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abbeville', Altitude = CapAltitude()}),
})


zones.hiddenAXENavalbaseCherbourg:addGroups({
	GroupCommander:new({name='AXE_hiddenAXENavalbaseCherbourg-resupply-LeHavre', mission='supply', template='SupplyNavalTemplate', targetzone='Le Havre', type = 'surface', condition = function() return zones.Cherbourg.active and zones.Cherbourg.side == 1 end}),
})
zones.hiddenAXENavalbaseLeHavre:addGroups({
	GroupCommander:new({name='AXE_hiddenAXENavalbaseLeHavre-resupply-DunkirkPort', mission='supply', template='SupplyNavalTemplate', targetzone='Dunkirk-Port', type = 'surface', condition = function() return zones.LeHavre.active and zones.LeHavre.side == 1 end}),
	GroupCommander:new({name='AXE_hiddenAXENavalbaseLeHavre-attack-CarrierGroup', mission='attack', template='BattleshipTemplate', MissionType='BATTLESHIP', targetzone='CarrierGroup', type = 'surface', condition = function() return zones.LeHavre.active and zones.LeHavre.side == 1 end}),
})
zones.hiddenAXENavalbaseDieppe:addGroups({
	GroupCommander:new({name='AXE_hiddenAXENavalbaseDieppe-resupply-AxeCarrierGroup', mission='supply', template='SupplyNavalTemplate', targetzone='AxeCarrierGroup', type = 'surface', condition = function() return zones.SaintAubain.active and zones.SaintAubain.side == 1 end}),
})

zones.hiddenUKNavalbasePortsmouth:addGroups({
	GroupCommander:new({name='UK_hiddenUKNavalbasePortsmouth-resupply-CarrierGroup', mission='supply', template='SupplyNavalTemplate', targetzone='CarrierGroup', type = 'surface', urgent = function() return zones.CarrierGroup.side == 0 end, ForceUrgent = true}),
	-- Normandy amphibious capture routes
	GroupCommander:new({name='UK_hiddenUKNavalbasePortsmouth-capture-Cherbourg', mission='supply', template='SupplyNavalTemplate', targetzone='Cherbourg', type='surface', urgent=function() return zones.Cherbourg.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_hiddenUKNavalbasePortsmouth-capture-Cricqueville', mission='supply', template='SupplyNavalTemplate', targetzone='Cricqueville', type='surface', urgent=function() return zones.Cricqueville.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_hiddenUKNavalbasePortsmouth-capture-LonguesSurMer', mission='supply', template='SupplyNavalTemplate', targetzone='Longues-Sur-Mer', type='surface', urgent=function() return zones.LonguesSurMer.side == 0 end, ForceUrgent=true}),
	GroupCommander:new({name='UK_hiddenUKNavalbasePortsmouth-capture-SaintPierre', mission='supply', template='SupplyNavalTemplate', targetzone='Saint-Pierre', type='surface', urgent=function() return zones.SaintPierre.side == 0 end, ForceUrgent=true}),
})

zones.hiddenUKNavalbaseDover:addGroups({
	GroupCommander:new({name='UK_hiddenUKNavalbaseDover-capture-AxeCarrierGroup', mission='supply', template='SupplyNavalTemplate', targetzone='AxeCarrierGroup', type='surface', condition = function() return zones.Dover.active and zones.Dover.side == 2 end, urgent = function() return zones.AxeCarrierGroup.side == 0 end, ForceUrgent = true}),
	GroupCommander:new({name='UK_hiddenUKNavalbaseDover-capture-DunkirkPort', mission='supply', template='SupplyNavalTemplate', targetzone='Dunkirk-Port', type='surface', condition = function() return zones.Dover.active and zones.Dover.side == 2 end, urgent = function() return zones.DunkirkPort.side == 0 end, ForceUrgent = true}),
    GroupCommander:new({name='UK_hiddenUKNavalbaseDover-capture-Calais', mission='supply', template='SupplyNavalTemplate', targetzone='Calais', type = 'surface', condition = function() return zones.Dover.active and zones.Dover.side == 2 end, urgent = function() return zones.Calais.side == 0 end, ForceUrgent = true}),
	--GroupCommander:new({name='UK_hiddenUKNavalbaseDover-capture-Merville', mission='supply', template='SupplyNavalTemplate', targetzone='Merville', type='surface', condition = function() return zones.Dover.active and zones.Dover.side == 2 end, urgent = function() return zones.Merville.side == 0 end, ForceUrgent = true}),
	GroupCommander:new({name='UK_hiddenUKNavalbaseDover-capture-Dunkirk', mission='supply', template='SupplyNavalTemplate', targetzone='Dunkirk', type='surface', condition = function() return zones.Dover.active and zones.Dover.side == 2 end, urgent = function() return zones.Dunkirk.side == 0 end, ForceUrgent = true}),
	GroupCommander:new({name='UK_hiddenUKNavalbaseDover-supply-CarrierGroup', mission='supply', template='SupplyNavalTemplate', targetzone='CarrierGroup', type='surface', condition = function() return zones.Dover.active and zones.Dover.side == 2 end}),
	GroupCommander:new({name='UK_hiddenUKNavalbaseDover-attack-DunkirkPort', mission='attack', template='BattleshipTemplate', MissionType='BATTLESHIP', targetzone='Dunkirk-Port', type='surface', condition = function() return zones.Dover.active and zones.Dover.side == 2 end}),
	
})

zones.hiddenAXENavalbaseDunkirk:addGroups({
	GroupCommander:new({name='AXE_hiddenAXENavalbaseDunkirk-resupply-Cherbourg', mission='supply', template='SupplyNavalTemplate', targetzone='Cherbourg', type = 'surface', condition = function() return zones.DunkirkPort.active and zones.DunkirkPort.side == 1 end}),
	GroupCommander:new({name='AXE_hiddenAXENavalbaseDunkirk-attack-Dover', mission='attack', template='BattleshipTemplate', MissionType='BATTLESHIP', targetzone='Dover', type = 'surface', condition = function() return zones.DunkirkPort.active and zones.DunkirkPort.side == 1 end}),
})

zones.AxeCarrierGroup:addGroups({
	GroupCommander:new({name='AXE_AxeCarrierGroup-attack-CarrierGroup', mission='attack', template='BattleshipTemplate', MissionType='BATTLESHIP', targetzone='CarrierGroup', type = 'surface'}),
})
zones.CarrierGroup:addGroups({
	GroupCommander:new({name='UK_CarrierGroup-attack-AxeCarrierGroup', mission='attack', template='BattleshipTemplate', MissionType='BATTLESHIP', targetzone='AxeCarrierGroup', type = 'surface'}),
	GroupCommander:new({name='UK_CarrierGroup-attack-LeHavre', mission='attack', template='BattleshipTemplate', MissionType='BATTLESHIP', targetzone='Le Havre', type = 'surface'}),
	GroupCommander:new({name='UK_CarrierGroup-attack-Cherbourg', mission='attack', template='BattleshipTemplate', MissionType='BATTLESHIP', targetzone='Cherbourg', type = 'surface'}),
	GroupCommander:new({name='UK_CarrierGroup-attack-SainteCroix', mission='attack', template='BattleshipTemplate', MissionType='BATTLESHIP', targetzone='Sainte-Croix', type = 'surface'}),
})
-- Add defined Groups in Mission Editor to your Zones in ZoneCommander


zones.V1_Brecourt:addCriticalObject('Fueltank-Brecourt')
zones.V1_Herbouville:addCriticalObject('Fueltank-Herbouville')
zones.V1_Val_Ygot:addCriticalObject('Fueltank-ValYgot')
zones.V1_Crecy_Forest:addCriticalObject('Fueltank-CrecyForest')
zones.V1_Flixecourt:addCriticalObject('Fueltank-Flixecourt')
zones.V1_Wallon_Cappel:addCriticalObject('Fueltank-WallonCappel')
zones.V1_Neuville:addCriticalObject('Fueltank-Neuville')


-- Add all zones to BattleCommander


for i,v in pairs(zones) do
	bc:addZone(v)
end
--zones.BigginHill.LogisticCenter = true
--zones.Orly.customSuspendNm = 999  -- never auto-suspend Orly
--zones.Paris.customSuspendNm = 999
--zones.Farnborough.customSuspendNm = 999
--zones.London.customSuspendNm = 999
--zones.Odiham.customSuspendNm = 999

zones.BigginHill.airbaseName = "Biggin Hill"
zones.Odiham.airbaseName = "Odiham"
zones.Farnborough.airbaseName = "Farnborough"
zones.Manston.airbaseName = "Manston"
zones.Hawkinge.airbaseName = "Hawkinge"
zones.Lympne.airbaseName = "Lympne"
zones.Chailey.airbaseName = "Chailey"
zones.Ford.airbaseName = "Ford"
zones.Tangmere.airbaseName = "Tangmere"
zones.Funtington.airbaseName = "Funtington"
zones.NeedsOarPoint.airbaseName = "Needs Oar Point"
zones.Friston.airbaseName = "Friston"
zones.Dunkirk.airbaseName = "Dunkirk-Mardyck"
--zones.DunkirkPort.airbaseName = nil
zones.SaintOmer.airbaseName = "Saint-Omer Wizernes"
zones.Merville.airbaseName = "Merville Calonne"
zones.Abbeville.airbaseName = "Abbeville Drucat"
zones.Amiens.airbaseName = "Amiens-Glisy"
--zones.Cherbourg.airbaseName = nil
--zones.Calais.airbaseName = nil
zones.SaintAubain.airbaseName = "Saint-Aubin"
zones.Fecamp.airbaseName = "Fecamp-Benouville"
--zones.LeHavre.airbaseName = nil
zones.Rouen.airbaseName = "Rouen-Boos"
zones.Carpiquet.airbaseName = "Carpiquet"
--zones.Caen.airbaseName = nil
zones.SainteCroix.airbaseName = "Sainte-Croix-sur-Mer"
zones.SaintPierre.airbaseName = "Saint Pierre du Mont"
zones.LonguesSurMer.airbaseName = "Longues-sur-Mer"
zones.Cricqueville.airbaseName = "Cricqueville-en-Bessin"
zones.LeMolay.airbaseName = "Le Molay"
zones.Brucheville.airbaseName = "Brucheville"
--zones.Valognes.airbaseName = nil
zones.Maupertus.airbaseName = "Maupertus"
zones.Bernay.airbaseName = "Bernay Saint Martin"
zones.SaintAndre.airbaseName = "Saint-Andre-de-lEure"
zones.Orly.airbaseName = "Orly"
zones.CarrierGroup.airbaseName = "ESSEX"

zones.BigginHill.isHeloSpawn = true
zones.Odiham.isHeloSpawn = true
zones.Farnborough.isHeloSpawn = true
zones.Manston.isHeloSpawn = true
zones.Hawkinge.isHeloSpawn = true
zones.Lympne.isHeloSpawn = true
zones.Chailey.isHeloSpawn = true
zones.Ford.isHeloSpawn = true
zones.Tangmere.isHeloSpawn = true
zones.Funtington.isHeloSpawn = true
zones.NeedsOarPoint.isHeloSpawn = true
zones.Friston.isHeloSpawn = true
zones.Dunkirk.isHeloSpawn = true
zones.SaintOmer.isHeloSpawn = true
zones.Merville.isHeloSpawn = true
zones.Abbeville.isHeloSpawn = true
zones.Amiens.isHeloSpawn = true
zones.SaintAubain.isHeloSpawn = true
zones.Fecamp.isHeloSpawn = true
zones.Rouen.isHeloSpawn = true
zones.Carpiquet.isHeloSpawn = true
zones.SainteCroix.isHeloSpawn = true
zones.SaintPierre.isHeloSpawn = true
zones.LonguesSurMer.isHeloSpawn = true
zones.Cricqueville.isHeloSpawn = true
zones.LeMolay.isHeloSpawn = true
zones.Brucheville.isHeloSpawn = true
zones.Maupertus.isHeloSpawn = true
zones.Bernay.isHeloSpawn = true
zones.SaintAndre.isHeloSpawn = true
zones.Orly.isHeloSpawn = true
zones.CarrierGroup.isHeloSpawn = true



-----------BLUE SUPPLY CHAIN ----------------
bc:addConnectionSupply("BigginHill","Manston")
bc:addConnectionSupply("BigginHill","Friston")
bc:addConnectionSupply("BigginHill","Chailey")
bc:addConnectionSupply("BigginHill","Dover")
bc:addConnectionSupply("Farnborough","Needs Oar Point")
bc:addConnectionSupply("Farnborough","Ford")
bc:addConnectionSupply("Farnborough","BigginHill")
bc:addConnectionSupply("Farnborough","Odiham")
bc:addConnectionSupply("London","Manston","train")
bc:addConnectionSupply("London","Farnborough","train")
bc:addConnectionSupply("London","Chailey","train")
bc:addConnectionSupply("London","Ford","train")
bc:addConnectionSupply("London","Hawkinge","train")
--bc:addConnectionSupply("London","BigginHill","train")
bc:addConnectionSupply("Manston","Dover")
bc:addConnectionSupply("Dover","Hawkinge")
bc:addConnectionSupply("Hawkinge","Lympne")
bc:addConnectionSupply("Ford","Tangmere")
bc:addConnectionSupply("Tangmere","Funtington")
bc:addConnectionSupply("Chailey","Friston")


-----------RED SUPPLY CHAIN ----------------
bc:addConnectionSupply("Orly","Dunkirk-Port")
bc:addConnectionSupply("Orly","Le Havre")
bc:addConnectionSupply("Orly","Cherbourg")
bc:addConnectionSupply("Orly","Amiens")
bc:addConnectionSupply("Orly","Merville")
bc:addConnectionSupply("Orly","Saint-Andre")
bc:addConnectionSupply("Cherbourg","Valognes","train")
bc:addConnectionSupply("Cherbourg","Maupertus")
bc:addConnectionSupply("Valognes","Le Molay","train")
bc:addConnectionSupply("Valognes","Brucheville")
bc:addConnectionSupply("Le Molay","Caen","train")
bc:addConnectionSupply("Le Molay","Cricqueville")
bc:addConnectionSupply("Le Molay","Saint-Pierre")
bc:addConnectionSupply("Le Molay","Longues-Sur-Mer")
bc:addConnectionSupply("Caen","Sainte-Croix")
bc:addConnectionSupply("Bernay","Caen","train")
bc:addConnectionSupply("Caen","Carpiquet")
bc:addConnectionSupply("Dunkirk-Port","Saint-Omer")
bc:addConnectionSupply("Dunkirk-Port","Calais","train")
bc:addConnectionSupply("Dunkirk-Port","Dunkirk")
bc:addConnectionSupply("Dunkirk-Port","Le Havre")
bc:addConnectionSupply("Merville","Saint-Omer")
bc:addConnectionSupply("Amiens","Abbeville","train")
bc:addConnectionSupply("Abbeville","Le Touquet","train")
bc:addConnectionSupply("Le Havre","Rouen","train")
bc:addConnectionSupply("Le Havre","Fecamp","train")
bc:addConnectionSupply("Paris","Orly","train")
bc:addConnectionSupply("Paris","Saint-Aubain","train")
bc:addConnectionSupply("Paris","Fecamp","train")
bc:addConnectionSupply("Paris","Saint-Andre","train")
bc:addConnectionSupply("Saint-Andre","Bernay","train")





zones.PointeDesGroins:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,1000)
	trigger.action.outTextForCoalition(2,L10N:Format("NORMANDY_RADAR_CLEARED", "Pointe Des Groins", 1000),20)
end, 'disablePointeDesGroins')
zones.PointeDuHoc:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,1000)
	trigger.action.outTextForCoalition(2,L10N:Format("NORMANDY_RADAR_CLEARED", "Pointe Du Hoc", 1000),20)
end, 'disablePointeDuHoc')
zones.CapGrisNez:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,1000)
	trigger.action.outTextForCoalition(2,L10N:Format("NORMANDY_RADAR_CLEARED", "Cap Gris Nez", 1000),20)
end, 'disableCapGrisNez')
--[[
zones.AxeCarrierGroup:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(1,5000)
	trigger.action.outTextForCoalition(1,'Enemy Carrier Group Destroyed\n+5000 credits',20)
end, 'disableAxeCarrierGroup')
--]]
zones.V1_Brecourt:registerTrigger('destroyed', function(event, sender) 
    env.info("V1_Brecourt destroyed trigger activated")
	fUnitCoord("V1 Launch Site - Brecourt")
    sender:disableZone()
    bc:addFunds(2, 500)
    trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_V1_SITE_DESTROYED", "Brecourt", 500), 20)
    --env.info("Trigger execution completed")
end, 'disableV1Brecourt')
zones.V1_Herbouville:registerTrigger('destroyed', function(event, sender) 
	env.info("V1_Herbouville destroyed trigger activated")
	fUnitCoord("V1 Launch Site - Herbouville")
	sender:disableZone()
	bc:addFunds(2, 500)
	trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_V1_SITE_DESTROYED", "Herbouville", 500), 20)
	--env.info("Trigger execution completed")
end, 'disableV1Herbouville')
zones.V1_Val_Ygot:registerTrigger('destroyed', function(event, sender) 
	env.info("V1_Val_Ygot destroyed trigger activated")
	fUnitCoord("V1 Launch Site - Val Ygot")
	sender:disableZone()
	bc:addFunds(2, 500)
	trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_V1_SITE_DESTROYED", "Val Ygot", 500), 20)
	--env.info("Trigger execution completed")
end, 'disableV1ValYgot')
zones.V1_Crecy_Forest:registerTrigger('destroyed', function(event, sender) 
	env.info("V1_Crecy_Forest destroyed trigger activated")
	fUnitCoord("V1 Launch Site - Crecy Forest")
	sender:disableZone()
	bc:addFunds(2, 500)
	trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_V1_SITE_DESTROYED", "Crecy Forest", 500), 20)
	--env.info("Trigger execution completed")
end, 'disableV1CrecyForest')
zones.V1_Flixecourt:registerTrigger('destroyed', function(event, sender) 
	env.info("V1_Flixecourt destroyed trigger activated")
	fUnitCoord("V1 Launch Site - Flixecourt")
	sender:disableZone()
	bc:addFunds(2, 500)
	trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_V1_SITE_DESTROYED", "Flixecourt", 500), 20)
	--env.info("Trigger execution completed")
end, 'disableV1Flixecourt')
zones.V1_Wallon_Cappel:registerTrigger('destroyed', function(event, sender) 
	env.info("V1_Wallon_Cappel destroyed trigger activated")
	fUnitCoord("V1 Launch Site - Wallon Cappel")
	sender:disableZone()
	bc:addFunds(2, 500)
	trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_V1_SITE_DESTROYED", "Wallon Cappel", 500), 20)
	--env.info("Trigger execution completed")
end, 'disableV1WallonCappel')
zones.V1_Neuville:registerTrigger('destroyed', function(event, sender) 
	env.info("V1_Neuville destroyed trigger activated")
	fUnitCoord("V1 Launch Site - Neuville")
	sender:disableZone()
	bc:addFunds(2, 500)
	trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_V1_SITE_DESTROYED", "Neuville", 500), 20)
	--env.info("Trigger execution completed")
end, 'disableV1Neuville')



function SpawnFriendlyAssets()
	if zones.Dover.active and zones.AxeCarrierGroup.side == 0 then
		trigger.action.outText(L10N:Format("NORMANDY_SHIPS_STANDING_CAPTURE", L10N:Get("NORMANDY_ZONE_RED_CARRIER")), 15)
		trigger.action.outSoundForCoalition(2, "admin.wav")
	end

	if zones.Dover.active and zones.DunkirkPort.side == 0 then
		trigger.action.outText(L10N:Format("NORMANDY_SHIPS_STANDING_CAPTURE", L10N:Get("NORMANDY_ZONE_DUNKIRK_PORT")), 15)
		trigger.action.outSoundForCoalition(2, "admin.wav")
	end

	if zones.Dover.active and zones.Calais.side == 0 then
		trigger.action.outText(L10N:Format("NORMANDY_SHIPS_STANDING_CAPTURE", L10N:Get("NORMANDY_ZONE_CALAIS")), 15)
		trigger.action.outSoundForCoalition(2, "admin.wav")
	end

end

timer.scheduleFunction(SpawnFriendlyAssets,{},timer.getTime()+10)







-- Start of original script----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

local missionCompleted = false
local resetMissionCompletionSave = function()
	Utils.saveTable(bc.saveFile, 'zonePersistance', {})
	if resetSaveFileAndFarp then
	resetSaveFileAndFarp()
	end
	if WarehouseLogistics == true then
		local opts = {}
		if FootholdSavePath then opts.path = FootholdSavePath end
		if FootholdSaveBaseName and tostring(FootholdSaveBaseName) ~= "" then
		opts.filename = tostring(FootholdSaveBaseName) .. "_storage.csv"
		end
		WarehousePersistence.ClearFile(opts)
	end
end

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

		timer.scheduleFunction(function()
			trigger.action.outSoundForCoalition(2, "BH.ogg")
		end, {}, timer.getTime() + 5)

		if AutoRestart then
			trigger.action.outText(L10N:Get("MISSION_COMPLETE_AUTORESTART"), 120)
			resetMissionCompletionSave()
			timer.scheduleFunction(function()
				trigger.action.setUserFlag(181, true)
			end, {}, timer.getTime() + 5)
		else
			trigger.action.outText(L10N:Get("MISSION_COMPLETE_MANUAL_RESTART"), 120)
			local subMenu = missionCommands.addSubMenuForCoalition(2, L10N:Get("NORMANDY_RESTART_MENU"), nil)
			missionCommands.addCommandForCoalition(2, L10N:Get("NORMANDY_RESTART_YES"), subMenu, function()
				resetMissionCompletionSave()
				trigger.action.outText(L10N:Get("MISSION_RESTARTING_NOW"), 120)
				timer.scheduleFunction(function()
					trigger.action.setUserFlag(181, true)
				end, {}, timer.getTime() + 5)
			end)
			missionCommands.addCommandForCoalition(2, L10N:Get("NORMANDY_RESTART_NO"), subMenu, function()
			end)
		end
	end
end

for i,v in ipairs(bc:getZones()) do
	v:registerTrigger('lost', checkMissionComplete, 'missioncompleted')
end

timer.scheduleFunction(function()
	checkMissionComplete(nil, nil)
end,{},5,0)

-- SCHEDULER:New(nil,function()
-- 	checkMissionComplete(nil, nil)
--     if Era == 'Coldwar' then
--     bc:roamGroupsToLocalSubZone({
--         "Red Armor Group6 #",
--         "Red Armor Group7 #",
--         "Red Armor Group8 #",
-- 		"Red SAM AAA #",
-- 		"Red SAM AAA 2 #",
-- 		"Red SAM AAA 5 #",
-- 		"Red SAM SHORAD SA-15 #",
-- 		"Red SAM SHORAD SA-8 #",
-- 		"Red SAM SHORAD SA-19 #",
-- 		"Red SAM SHORAD SA-13 #",
-- 		"Red SAM SHORAD SA-9 #",
-- 		"Grisha #",
-- 		"Molniya #",
-- 		"Rezky #",
-- 	}, 30, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
-- else
-- 	bc:roamGroupsToLocalSubZone({
-- 		"Red Armour Group #",
--         "Red Armour Group 2 #",
--         "Red Armour Group 3 #",
-- 		"Red SAM AAA #",
-- 		"Red SAM AAA 2 #",
-- 		"Red SAM AAA 5 #",
-- 		"Red SAM SHORAD SA-15 #",
-- 		"Red SAM SHORAD SA-8 #",
-- 		"Red SAM SHORAD SA-19 #",
-- 		"Red SAM SHORAD SA-13 #",
-- 		"Red SAM SHORAD SA-9 #",
-- 		"Red SAM SHORAD Tor M2 #",
-- 		"Grisha #",
-- 		"Molniya #",
-- 		"Rezky #",
-- 	}, 30, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
-- end
-- end,{},5,0)

-- SHOP --
bc:registerShopItem('supplies2', L10N:Get("SYRIA_SHOP_ITEM_RESUPPLY_ZONE"), ShopPrices.supplies2, function(sender)
    if not AllowScriptedSupplies and NoAIBlueSupplies == true then
        return L10N:Get("SYRIA_SHOP_BLUE_AI_SUPPLIES_DISABLED")
    end
    return L10N:Get("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender, params)
    if not AllowScriptedSupplies then
        if NoAIBlueSupplies == true then
            return L10N:Get("SYRIA_SHOP_BLUE_AI_SUPPLIES_DISABLED")
        end
        if params.zone then
            params.disableDynamicSupply = true
            return bc:requestFriendlySupplyMission(params.zone, params)
        end
        return L10N:Get("SYRIA_SHOP_CAN_ONLY_TARGET_FRIENDLY")
    elseif params.zone and params.zone.side == 2 and not params.zone.suspended then
        if not params.zone:upgrade() then
            return L10N:Get("SYRIA_SHOP_ZONE_NO_RESUPPLY")
        end
    else
        return L10N:Get("SYRIA_SHOP_CAN_ONLY_TARGET_FRIENDLY")
    end
end)
bc.shopItems['supplies2'].groupZoneSelector = {
	targetzoneside = 2,
	showUpgradeStatus = true,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

if AllowScriptedSupplies then
    bc:registerShopItem('supplies',L10N:Get("SYRIA_SHOP_ITEM_FULLY_UPGRADE_ZONE"),ShopPrices.supplies,
    function(sender)
        return L10N:Get("SYRIA_SHOP_CHOOSE_ZONE_FULLY_UPGRADE")
    end,
    function(sender,params)
        if params.zone and params.zone.side==2 and not params.zone.suspended then
            local zn=params.zone
            if not zn:UpgradeUntilComplete(function()
                trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_ZONE_FULLY_UPGRADED", params.zone.zone),15)
            end) then
                return L10N:Format("ZONE_ALREADY_FULLY_UPGRADED", params.zone.zone)
            end
        else
            return L10N:Get("SYRIA_SHOP_CAN_ONLY_TARGET_FRIENDLY")
        end
    end)
end
if bc.shopItems['supplies'] then
bc.shopItems['supplies'].groupZoneSelector = {
	targetzoneside = 2,
	showUpgradeStatus = true,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}
end

local SHOP_PRICE_DEFAULTS = {
  smoke         = 20,
  flare         = 20,
  illum         = 100,
  dynamiccap    = 500,
  dynamiccas    = 1000,
  dynamicbomb   = 500,
  dynamicstatic = 500,
  supplies2     = 200,
  supplies      = 1000,
  capture       = 500,
  advancecapture = 500,
  intel         = 150,
  zinf          = 500,
  zsam          = 1000,
  zarm          = 1000,
  gslot         = 3000,
}

local SHOP_RANK_DEFAULTS = {
  dynamiccap     = 2,
  dynamiccas     = 5,
  dynamicbomb    = 4,
  dynamicstatic  = 4,
  capture        = 1,
  advancecapture = 1,
  smoke          = 1,
  flare          = 1,
  illum          = 1,
  intel          = 5,
  supplies2      = 1,
  supplies       = 6,
  zinf           = 5,
  zsam           = 6,
  zarm           = 7,
  gslot          = 9,
}

local function mergeDefaults(defaults, overrides)
  local out = {}
  for k, v in pairs(defaults) do out[k] = v end
  for k, v in pairs(overrides or {}) do out[k] = v end
  return out
end

ShopPrices = mergeDefaults(SHOP_PRICE_DEFAULTS, ShopPrices)
ShopRankRequirements = mergeDefaults(SHOP_RANK_DEFAULTS, ShopRankRequirements)

bc:registerShopItem('smoke', L10N:Get("SYRIA_SHOP_ITEM_SMOKE_MARKERS"), ShopPrices.smoke, function(sender)
	return L10N:Get("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		bc:smokeTargets(params.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_TARGETS_RED_SMOKE", params.zone.zone), 15)
	else
		return L10N:Get("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
end)
bc.shopItems['smoke'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}
bc:registerShopItem('flare', L10N:Get("SYRIA_SHOP_ITEM_FLARE_MARKERS"), ShopPrices.flare, function(sender)
	return L10N:Get("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		bc:flareTargets(params.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_TARGETS_RED_FLARE", params.zone.zone), 15)
	else
		return L10N:Get("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
end)
bc.shopItems['flare'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}
bc:registerShopItem('illum', L10N:Get("SYRIA_SHOP_ITEM_ILLUMINATION"), ShopPrices.illum, function(sender)
	return L10N:Get("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		bc:illumTargets(params.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_TARGETS_ILLUMINATED", params.zone.zone), 15)
	else
		return L10N:Get("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
end)
bc.shopItems['illum'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}


-- new menu
bc:registerShopItem('capture',L10N:Get("SYRIA_SHOP_ITEM_CAPTURE_NEUTRAL"),ShopPrices.capture,
function(sender)
	if NoAIBlueSupplies == true then 
		return L10N:Get("SYRIA_SHOP_BLUE_AI_SUPPLIES_DISABLED") 
	end
	return L10N:Get("SYRIA_SHOP_CHOOSE_NEUTRAL_ZONE")
end,
function(sender,params)
    if not params.zone or params.zone.side~=0 then
        return L10N:Get("SYRIA_SHOP_ZONE_NOT_NEUTRAL")
    end
    local chosenZone=bc:getZoneByName(params.zone.zone)
    params.disableDynamicSupply = true
    return bc:requestCaptureMission(chosenZone, params)
end)
bc.shopItems['capture'].groupZoneSelector = {
	targetzoneside = 0,
	includeSuspended = true,
	extraPredicate = function(zoneObj)
		return zoneObj.active and (not zoneObj.NeutralAtStart or zoneObj.firstCaptureByRed or zoneObj.suspended)
	end,
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_ELIGIBLE_NEUTRAL_ZONES"),
}
--end of menu

bc:registerShopItem('advancecapture',L10N:Get("SYRIA_SHOP_ITEM_ADVANCE_CAPTURE"),ShopPrices.advancecapture,
function(sender)
	return L10N:Get("SYRIA_SHOP_CHOOSE_ADVANCE_CAPTURE_ZONE")
end,
function(sender,params)
    if not params.zone then
        return L10N:Get("SYRIA_SHOP_ADVANCE_CAPTURE_NOT_ELIGIBLE")
    end
    if not params.zone:canAdvanceCapture() then
        return L10N:Get("SYRIA_SHOP_ADVANCE_CAPTURE_NOT_ELIGIBLE")
    end
    params.advanceCapture = true
    params.disableDynamicSupply = true
    local chosenZone=bc:getZoneByName(params.zone.zone)
    return bc:requestCaptureMission(chosenZone, params)
end)
bc.shopItems['advancecapture'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	extraPredicate = function(zoneObj)
		return zoneObj:canAdvanceCapture()
	end,
	sortPolicy = 'enemy_frontline',
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_ELIGIBLE_ADVANCE_CAPTURE_ZONES"),
}
--end of advance capture

-----------------------------------------------DYNAMIC SHOP ------------------------------------------


bc:registerShopItem('dynamiccap', L10N:Get("SYRIA_SHOP_ITEM_CAP_FLIGHT"), ShopPrices.dynamiccap, function(sender)
    if capActive then
        return L10N:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", "CAP")
    end
		if capParentMenu then
		return L10N:Get("SYRIA_SHOP_CHOOSE_SPAWN_ZONE")
	end
    buildCapMenu()
	trigger.action.outTextForCoalition(2, L10N:Get("SYRIA_SHOP_CAP_REQUESTED"), 10)
    return
end,
function (sender, params)
    if capActive then
        return L10N:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", "CAP")
    end
    if params and params.zone then
        if params.zone.side ~= 2 or params.zone.suspended then
            return L10N:Get("SYRIA_SHOP_CAN_ONLY_SPAWN_FRIENDLY")
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
		for _, headingName in ipairs({ "Orbit", "Hot 360", "Hot 045", "Hot 090", "Hot 135", "Hot 180", "Hot 225", "Hot 270", "Hot 315" }) do
			local headingLabel = L10N:DynamicHeadingLabel(headingName)
			if headingName == "Orbit" then
				remember(missionCommands.addCommandForGroup(groupId, headingLabel, zoneMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
					zone = zoneObj,
					heading = 45,
					leg = 0,
				}, groupId, groupObj))
			else
				local headingVal = capHeadings[headingName]
				local headingMenu = remember(missionCommands.addSubMenuForGroup(groupId, headingLabel, zoneMenu))
				for _, legName in ipairs({ "10 NM Leg", "20 NM Leg", "30 NM Leg", "40 NM Leg", "50 NM Leg" }) do
					local legVal = capLegs[legName]
					remember(missionCommands.addCommandForGroup(groupId, L10N:DynamicLegLabel(legName), headingMenu, bcRef.buyShopItem, bcRef, 2, itemInfo.id, {
						zone = zoneObj,
						heading = headingVal,
						leg = legVal,
					}, groupId, groupObj))
				end
			end
		end
	end,
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

bc:registerShopItem('dynamiccas', L10N:Get("SYRIA_SHOP_ITEM_CAS_FLIGHT"), ShopPrices.dynamiccas,
function(sender)
    if casActive then
        return L10N:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", "CAS")
    end
	return L10N:Get("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
        if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if casActive then return L10N:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", "CAS") end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return L10N:Format("SYRIA_SHOP_NO_FRIENDLY_SPAWN", "CAS")
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnCasAt(closestBlue, params.zone.zone, offset)
        return
    else
        return L10N:Get("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['dynamiccas'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
	end,
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}



bc:registerShopItem('dynamicbomb', L10N:Get("SYRIA_SHOP_ITEM_BOMBER_FLIGHT"), ShopPrices.dynamicbomb,
function(sender)
    if bomberActive then
        return L10N:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", L10N:Get("SYRIA_SHOP_ITEM_BOMBER_FLIGHT"))
    end
	return L10N:Get("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if bomberActive then
            return L10N:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", L10N:Get("SYRIA_SHOP_ITEM_BOMBER_FLIGHT"))
        end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return L10N:Format("SYRIA_SHOP_NO_FRIENDLY_SPAWN", L10N:Get("SYRIA_SHOP_ITEM_BOMBER_FLIGHT"))
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnBomberAt(closestBlue, params.zone.zone, offset)
        return
    else
        return L10N:Get("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['dynamicbomb'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
	end,
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}


if UseStatics == true then
bc:registerShopItem('dynamicstatic', L10N:Get("CA_SHOP_ITEM_STATIC_STRUCTURE"), ShopPrices.dynamicstatic,
function(sender)
    if StructureActive then
        return L10N:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", L10N:Get("CA_SHOP_LABEL_BUILDING_STRIKE"))
    end
	return L10N:Get("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and params.zone.newStatics and next(params.zone.newStatics) then
        if StructureActive then
            return L10N:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", L10N:Get("CA_SHOP_LABEL_BUILDING_STRIKE"))
        end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return L10N:Get("CA_SHOP_NO_FRIENDLY_STRIKE_SPAWN")
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnStructureAt(closestBlue, params.zone.zone, offset)
        return
    else
        return L10N:Get("CA_SHOP_CAN_ONLY_TARGET_BUILDINGS")
    end
end)
bc.shopItems['dynamicstatic'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
			and zoneObj.newStatics
			and next(zoneObj.newStatics) ~= nil
	end,
	emptyLabel = L10N:Get("CA_SHOP_NO_VALID_BUILDING_TARGET_ZONES"),
}
end
---------------------------------------------END DYNAMIC SHOP ------------------------------------------

bc:registerShopItem('intel',L10N:Get("SYRIA_SHOP_ITEM_INTEL_ENEMY"),ShopPrices.intel,function(sender)
	return L10N:Get("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		intelActiveZones[params.zone.zone] = true
		startZoneIntel(params.zone.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_GATHERING_INTEL", params.zone.zone), 10)
	else
		return L10N:Get("SYRIA_SHOP_MUST_PICK_ENEMY_ZONE")
	end
end)
bc.shopItems['intel'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}

------------------------------------------- Zone upgrades --------------------------------------------
local RED_ZONE_UPGRADE_ID = "redzoneupgrade"
local RED_ZONE_UPGRADE_COST = 3000

bc:registerShopItem(RED_ZONE_UPGRADE_ID, L10N:Get("SYRIA_SHOP_ITEM_RED_ZONE_UPGRADE"), RED_ZONE_UPGRADE_COST, function(sender)
	return bc:redZoneUpgradeAction()
end)

local RED_MASS_ATTACK_ID = "redmassattack"
local RED_MASS_ATTACK_COST = 4000

local function redMassAttackAction()
	if not bc.triggerRedMassAttack then
		return L10N:Get("SYRIA_SHOP_MASS_ATTACK_UNAVAILABLE")
	end
	return bc:triggerRedMassAttack()
end

bc:registerShopItem(RED_MASS_ATTACK_ID, L10N:Get("SYRIA_SHOP_ITEM_RED_MASS_ATTACK"), RED_MASS_ATTACK_COST, redMassAttackAction)

bc:registerShopItem('zinf',L10N:Get("SYRIA_SHOP_ITEM_UPGRADE_INFANTRY"),ShopPrices.zinf,function(sender)
	return L10N:Get("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return L10N:Get("SYRIA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return L10N:Get("SYRIA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('UK-INF-MK1')
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock then
		trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED", L10N:Get("SYRIA_SHOP_LABEL_INFANTRY"), params.zone.zone, tostring(ShopPrices.zinf)),10)
		else
		trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED_EXTRA", L10N:Get("SYRIA_SHOP_LABEL_INFANTRY"), params.zone.zone, tostring(ShopPrices.zinf)),30)
		end
	else
		return L10N:Get("SYRIA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zinf'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_ELIGIBLE_ZONE"),
}
bc:registerShopItem('zsam',L10N:Get("SYRIA_SHOP_ITEM_UPGRADE_AA_GUNS"),ShopPrices.zsam,function(sender)
	return L10N:Get("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return L10N:Get("SYRIA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return L10N:Get("SYRIA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('UK-AAA-bofors')
		bc:refreshZoneLabel(params.zone.zone)
        if bc.globalExtraUnlock then
            trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED", L10N:Get("SYRIA_SHOP_LABEL_AA_GUNS"), params.zone.zone, tostring(ShopPrices.zsam)),10)
        else
            trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED_EXTRA", L10N:Get("SYRIA_SHOP_LABEL_AA_GUNS"), params.zone.zone, tostring(ShopPrices.zsam)),30)
        end
	else
		return L10N:Get("SYRIA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zsam'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_ELIGIBLE_ZONE"),
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

bc.shopItems['dynamiccas'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['dynamiccas'].groupZoneSelector.refreshTags = { 'enemy_targets' }

bc.shopItems['dynamicbomb'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['dynamicbomb'].groupZoneSelector.refreshTags = { 'enemy_targets' }
if bc.shopItems['dynamicstatic'] and bc.shopItems['dynamicstatic'].groupZoneSelector then
	bc.shopItems['dynamicstatic'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
	bc.shopItems['dynamicstatic'].groupZoneSelector.refreshTags = { 'enemy_targets' }
end
bc.shopItems['supplies2'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['supplies2'].groupZoneSelector.refreshTags = { 'friendly_targets' }
if bc.shopItems['supplies'] and bc.shopItems['supplies'].groupZoneSelector then
	bc.shopItems['supplies'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
	bc.shopItems['supplies'].groupZoneSelector.refreshTags = { 'friendly_targets' }
end

bc.shopItems['zinf'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zinf'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc.shopItems['zsam'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zsam'].groupZoneSelector.refreshTags = { 'friendly_targets' }

bc.shopItems['capture'].groupZoneSelector.candidateBucket = 'neutral_capture_targets'
bc.shopItems['capture'].groupZoneSelector.refreshTags = { 'neutral_capture_targets' }
bc.shopItems['advancecapture'].groupZoneSelector.candidateBucket = 'advance_capture_targets'
bc.shopItems['advancecapture'].groupZoneSelector.refreshTags = { 'advance_capture_targets' }
bc.shopItems['intel'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['intel'].groupZoneSelector.refreshTags = { 'enemy_targets' }

bc:registerShopItem('zarm',L10N:Get("SYRIA_SHOP_ITEM_UPGRADE_ARMOR"),ShopPrices.zarm,function(sender)
	return L10N:Get("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return L10N:Get("SYRIA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return L10N:Get("SYRIA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('UK-ARMOR')
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock then
			trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED", L10N:Get("SYRIA_SHOP_LABEL_ARMOR"), params.zone.zone, tostring(ShopPrices.zarm)),10)
		else
			trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_UPGRADE_ADDED_EXTRA_LINE", L10N:Get("SYRIA_SHOP_LABEL_ARMOR"), params.zone.zone, tostring(ShopPrices.zarm)),30)
		end
	else
		return L10N:Get("SYRIA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zarm'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = L10N:Get("SYRIA_SHOP_NO_ELIGIBLE_ZONE"),
}
bc.shopItems['zarm'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zarm'].groupZoneSelector.refreshTags = { 'friendly_targets' }
bc:registerShopItem('gslot',L10N:Get("SYRIA_SHOP_ITEM_EXTRA_SLOT"),ShopPrices.gslot,function(sender)
    if bc.globalExtraUnlock then
        return L10N:Get("SYRIA_SHOP_ALREADY_UNLOCKED")
    end
    bc.globalExtraUnlock = true
    for _,z in pairs(bc:getZones()) do

    end
    trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SHOP_ALL_ZONES_SECOND_UPGRADE"),15)
	bc:removeShopItem(2, 'gslot')
	return nil
end)

------------------------------------------- End of Zone upgrades ----------------------------------------
ShopPrices = ShopPrices or {
	smoke         = 20,   -- Smoke markers
	flare         = 20,   -- Flare markers
	illum         = 100,  -- Illumination bomb
	dynamiccap    = 500,  -- Dynamic CAP
	dynamiccas    = 1000, -- Dynamic CAS
	dynamicbomb   = 500,  -- Dynamic Bomb run
	dynamicstatic = 500,  -- Dynamic building Strike
	supplies2     = 200,  -- Resupply friendly Zone
	supplies      = 1000, -- Fully Upgrade Friendly Zone
	capture       = 500,  -- Emergency capture zone
	advancecapture = 500, -- Advance capture pressured enemy zone
	intel         = 150,  -- Intel on enemy zone
	zinf          = 500,  -- Upgrade zone with infantry
	zsam          = 1000, -- Upgrade zone with AA guns
	zarm          = 1000, -- Upgrade zone with armor
	gslot         = 3000, -- Unlock extra upgrade slot
}

ShopRankRequirements = ShopRankRequirements or {
	dynamiccap     = 2,  -- Dynamic CAP
	dynamiccas     = 5,  -- Dynamic CAS
	dynamicbomb    = 4,  -- Dynamic Bomb run
	dynamicstatic  = 4,  -- Dynamic building Strike
	capture        = 1,  -- Emergency capture zone
	advancecapture = 1, -- Advance capture pressured enemy zone
	smoke          = 1,  -- Smoke markers
	flare          = 1,  -- Flare markers
	illum          = 1,  -- Illumination bomb
	intel          = 5,  -- Intel on enemy zone
	supplies2      = 1,  -- Resupply friendly Zone
	supplies       = 6,  -- Fully Upgrade Friendly Zone
	zinf           = 5,  -- Upgrade zone with infantry
	zsam           = 6,  -- Upgrade zone with AA guns
	zarm           = 7,  -- Upgrade zone with armor
	gslot          = 9,  -- Unlock extra upgrade slot
}

-- first value below is how much in stock, the second number value is the ranking in the shop menu list, the third is the new ranking system.

bc:addShopItem(1, 'redzoneupgrade', -1, 1) -- red AI zone upgrade
bc:addShopItem(1, 'redmassattack', -1, 2) -- red AI mass airbase attack

ShopCategoryLabels = ShopCategoryLabels or {}
local ShopCats = ShopCategoryLabels

ShopCats.AIAttack = ShopCats.AIAttack or "AI Attack"
ShopCats.ZoneUpgrades = ShopCats.ZoneUpgrades or "Zone Upgrades"
ShopCats.JTACIntel = ShopCats.JTACIntel or "JTAC & Intel"
ShopCats.MarkingTools = ShopCats.MarkingTools or "Marking & Tools"
ShopCats.CombinedArms = ShopCats.CombinedArms or "Combined Arms"
ShopCats.LogisticsStrategic = ShopCats.LogisticsStrategic or "Capture & resources"
ShopCats.OtherSupport = ShopCats.OtherSupport or "Other Support"

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
if UseStatics == true then
    bc:addShopItem(2, 'dynamicstatic', -1, 6, ShopRankRequirements.dynamicstatic, ShopCats.AIAttack) -- Static structure Flight
end

-- Zone Upgrades
bc:addShopItem(2, 'zinf', -1, 1, ShopRankRequirements.zinf, ShopCats.ZoneUpgrades) -- add infantry to a zone
bc:addShopItem(2, 'zarm', -1, 2, ShopRankRequirements.zarm, ShopCats.ZoneUpgrades) -- add armour group to a zone
bc:addShopItem(2, 'zsam', -1, 3, ShopRankRequirements.zsam, ShopCats.ZoneUpgrades) -- add AA guns to a zone
bc:addShopItem(2, 'gslot', 1, 5, ShopRankRequirements.gslot, ShopCats.ZoneUpgrades) -- add another slot for upgrade


-- JTAC & Intel
bc:addShopItem(2, 'smoke', -1, 2, ShopRankRequirements.smoke, ShopCats.JTACIntel) -- smoke on target
bc:addShopItem(2, 'flare', -1, 3, ShopRankRequirements.flare, ShopCats.JTACIntel) -- flare on target
bc:addShopItem(2, 'illum', -1, 4, ShopRankRequirements.illum, ShopCats.JTACIntel) -- illumination bomb
bc:addShopItem(2, 'intel', -1, 5, ShopRankRequirements.intel, ShopCats.JTACIntel) -- Intel

-- Logistics & Strategic
bc:addShopItem(2, 'capture', -1, 1, ShopRankRequirements.capture, ShopCats.LogisticsStrategic) -- emergency capture
bc:addShopItem(2, 'advancecapture', -1, 2, ShopRankRequirements.advancecapture, ShopCats.LogisticsStrategic) -- advance capture pressured enemy zone
bc:addShopItem(2, 'supplies2', -1, 3, ShopRankRequirements.supplies2, ShopCats.LogisticsStrategic) -- upgrade friendly zone
if AllowScriptedSupplies then
    bc:addShopItem(2, 'supplies', -1, 4, ShopRankRequirements.supplies, ShopCats.LogisticsStrategic) -- fully upgrade friendly zone
end

supplyZones = {
    'BigginHill',
	'Odiham',
	'Farnborough',
	'Manston',
	'Hawkinge',
	'Lympne',
	'Chailey',
	'Ford',
	'Tangmere',
	'Funtington',
	'NeedsOarPoint',
	'Friston',
	'Dunkirk',
	'SaintOmer',
	'Merville',
	'Abbeville',
	'Amiens',
	'SaintAubain',
	'Fecamp',
	'Rouen',
	'Carpiquet',
	'SainteCroix',
	'SaintPierre',
	'LonguesSurMer',
	'Cricqueville',
	'LeMolay',
	'Brucheville',
	'Maupertus',
	'Bernay',
	'SaintAndre',
	'CarrierGroup',
	'AxeCarrierGroup',
	'DunkirkPort',
	'Calais',
	'Cherbourg',
	'Caen',
	'Valognes',
	'LeHavre',
	'Paris',
	'Orly',
	'London',
	--'hiddenCarrierEssex',
}

lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

bc:loadFromDisk()
if not bc.saveLoaded then
    applyRandomRedUpgrades()
    applyRandomBlueUpgrades()
else
    applyRandomUpgradesForNewZonesOnly()
end

bc:init()
budgetAI = BudgetCommander:new({ battleCommander = bc, side=1, decissionFrequency=20*60, decissionVariance=10*60, skipChance = 10})
budgetAI:init()
RewardContribution = RewardContribution or {infantry = 10, ground = 10, sam = 30, airplane = 50, ship = 200, helicopter=50, crate=100, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, structure = 100}
bc:startRewardPlayerContribution(15,RewardContribution)
HercCargoDropSupply.init(bc)
bc:buildZoneDistanceCache()
buildTemplateCache()
buildSubZoneRoadCache()
BuildAirbaseParkingClusterCache()
bc:buildConnectionMap()
bc:buildConnectionSupplyMap()
DynamicConvoy.InitTargetTails(15)
DynamicConvoy.InitRoadPathCacheFromCommanders(GroupCommanders)
PrecomputeLandingSpots()
Frontline.BuildFromZones(bc.indexedZones)
Frontline.ReindexZoneCalcs()
bc:buildCapSpawnBuckets()
startWarehousePersistence()
local HuntNumber = SplashDamage and math.random(10,20) or math.random(8,16)
local AirHuntNumber = math.random(4,8)
bc:initHunter(HuntNumber, AirHuntNumber)
SCHEDULER:New(nil, function() bc:_buildHunterBaseList() end, {}, 1)

-- SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 3)
-- SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 4)

-- AWACS_CFG = {
--     [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=100 }, -- red
--     [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=60 }   -- blue
-- }

GlobalSettings.autoSuspendNmBlue = 90   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 90   		-- suspend red zones deeper than this nm

evc = EventCommander:new({ decissionFrequency=10*60, decissionVariance=10*60, skipChance = 10})
mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})

DynamicHybridConfig = DynamicHybridConfig or {
	enabled = true,
	runOnce = true,
	airMaxNm = 120,
	heloCasMaxNm = 40,
	minGroundAttackNm = 10,
	surfaceMaxNm = 0,
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


----------------------------------------------- Bomber Red event ---------------------------------------------
local bomb_COOLDOWN = 3600
local lastbomb_COOLDOWN  = -bomb_COOLDOWN
local WW2_BOMBER_MIN_PLAYER_SPAWN_NM = 40
local WW2_BOMBER_MIN_TARGET_SPAWN_NM = 40

local function getBomberSpawnAirbase(zone, coalitionSide)
  local airbase = zone.airbaseName and AIRBASE:FindByName(zone.airbaseName) or nil
  if airbase and airbase:IsAirdrome() and airbase:GetCoalition() == coalitionSide then
    return airbase
  end
  return nil
end

local function isBomberSpawnAirbaseFarFromCachedPlayers(airbase)
  local zonePoint = airbase:GetCoordinate():GetVec3()
  for _, playerTable in ipairs(bc.playersState or {}) do
    local latitude = tonumber(playerTable.latitude)
    local longitude = tonumber(playerTable.longitude)
    if latitude and longitude then
      local playerPoint = coord.LLtoLO(latitude, longitude, tonumber(playerTable.altitude) or 0)
      local dx = zonePoint.x - playerPoint.x
      local dz = zonePoint.z - playerPoint.z
      local distanceNm = UTILS.MetersToNM(math.sqrt(dx * dx + dz * dz))
      if distanceNm < WW2_BOMBER_MIN_PLAYER_SPAWN_NM then
        return false
      end
    end
  end
  return true
end

local function isRedReactivePressuredZone(zone)
  local pressureByZone = bc._redReactivePressureByZone
  if not pressureByZone then return false end
  local pressureUntil = bc._redReactivePressureUntil
  if pressureUntil and pressureUntil < timer.getTime() then return false end
  return pressureByZone[zone.zone] ~= nil
end

local function isBomberSpawnAirbaseFarFromTarget(airbase, targetZone)
  local spawnCoord = airbase:GetCoordinate()
  local targetCoord = ZONE:FindByName(targetZone.zone):GetCoordinate()
  local distanceNm = UTILS.MetersToNM(spawnCoord:Get2DDistance(targetCoord))
  return distanceNm >= WW2_BOMBER_MIN_TARGET_SPAWN_NM
end


Group.getByName(bomberRedTemplate):destroy()
Group.getByName(bomberRedEscortTemplate):destroy()
Group.getByName(bomberBlueTemplate):destroy()
Group.getByName(bomberBlueEscortTemplate):destroy()

-- Updated bomber event to use spawnBomberStrikerAt with dynamic zone selection
evc:addEvent({
id='bombRed',
action=function()
  -- Spawn bombers from a red zone to attack a blue zone
  -- Select random red spawn zone and random blue target zone
  local redZones = {}
  local blueZones = {}
  
  for _, zone in ipairs(bc:getZones()) do
    local airbase = getBomberSpawnAirbase(zone, 1)
    if zone.side == 1 and zone.active and not zone.suspended and not zone.zone:lower():find("hidden") and airbase and isBomberSpawnAirbaseFarFromCachedPlayers(airbase) and not isRedReactivePressuredZone(zone) then
      table.insert(redZones, zone.zone)
    elseif zone.side == 2 and zone.active and not zone.suspended and not zone.zone:lower():find("hidden") then
      table.insert(blueZones, zone.zone)
    end
  end
  
  if #redZones > 0 and #blueZones > 0 then
    local spawnZone = redZones[math.random(#redZones)]
    local targetZone = blueZones[math.random(#blueZones)]
    
    -- Store zones for mission display
    bomberMissionSpawnZone = spawnZone
    bomberMissionTargetZone = targetZone
    
    if spawnBomberStrikerAt(spawnZone, targetZone) then
      RegisterGroupTarget(bomberRedTemplate,500,L10N:Get("NORMANDY_MISSION_INTERCEPT_BOMBERS_TITLE"),'bombRed')
    else
      bomberMissionSpawnZone = nil
      bomberMissionTargetZone = nil
    end
  end
end,
canExecute=function()
  if ActiveMission['bombRed'] then return false end  -- Defense-in-depth: check ActiveMission first
  if timer.getTime()-lastbomb_COOLDOWN < bomb_COOLDOWN then return false end
  
  local hasRedSpawn = false
  local hasBlueTarget = false
  for _, zone in ipairs(bc:getZones()) do
    local airbase = getBomberSpawnAirbase(zone, 1)
    if zone.side == 1 and zone.active and not zone.suspended and not zone.zone:lower():find("hidden") and airbase and isBomberSpawnAirbaseFarFromCachedPlayers(airbase) and not isRedReactivePressuredZone(zone) then
      hasRedSpawn = true
    elseif zone.side == 2 and zone.active and not zone.suspended and not zone.zone:lower():find("hidden") then
      hasBlueTarget = true
    end
  end
  return hasRedSpawn and hasBlueTarget
end
})

-- Track bomber mission spawn and target zones
bomberMissionSpawnZone = nil
bomberMissionTargetZone = nil

mc:trackMission({
title = L10N:Get("NORMANDY_MISSION_INTERCEPT_BOMBERS_TITLE"),
description = function()
    local desc = L10N:Get("NORMANDY_MISSION_INTERCEPT_BOMBERS_DESC")
    if bomberMissionSpawnZone and bomberMissionTargetZone then
        desc = desc .. "\n\n" .. L10N:Format("NORMANDY_MISSION_INTERCEPT_BOMBERS_DESC_DETAIL", bomberMissionSpawnZone, bomberMissionTargetZone)
    end
    return desc
end,
messageStart = function()
    local msg = L10N:Get("NORMANDY_MISSION_INTERCEPT_BOMBERS_START")
    if bomberMissionSpawnZone and bomberMissionTargetZone then
        msg = msg .. "\n\n" .. L10N:Format("NORMANDY_MISSION_INTERCEPT_BOMBERS_START_DETAIL", bomberMissionSpawnZone, bomberMissionTargetZone)
    end
    return msg
end,
messageEnd=function() 
    lastbomb_COOLDOWN=timer.getTime()
    bomberMissionSpawnZone = nil
    bomberMissionTargetZone = nil
    return L10N:Get("NORMANDY_MISSION_INTERCEPT_BOMBERS_END") 
end,
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
    if not ActiveMission['bombRed'] then return false end
    if Group.getByName(bomberRedTemplate) then return true end
    ActiveMission['bombRed'] = nil  -- Cleanup when mission ends
    return false
end
})

-------------------------------------------- End of Bomber Red event ------------------------------------------

----------------------------------------------- Bomber Blue event ---------------------------------------------
local bombBlue_COOLDOWN = 2400
local lastbombBlue_COOLDOWN = -bombBlue_COOLDOWN

-- Blue bomber event to use spawnBlueBomberStrikerAt with dynamic zone selection
evc:addEvent({
id='bombBlue',
action=function()
  -- Spawn blue bombers from a blue zone to attack a red zone
  -- Select random blue spawn / red target pair at least 40 NM apart
  local validPairs = {}
  
  for _, spawnZone in ipairs(bc:getZones()) do
    local spawnAirbase = getBomberSpawnAirbase(spawnZone, 2)
    if spawnZone.side == 2 and spawnZone.active and not spawnZone.suspended and not spawnZone.zone:lower():find("hidden") and spawnAirbase then
      for _, targetZone in ipairs(bc:getZones()) do
        if targetZone.side == 1 and targetZone.active and not targetZone.suspended and not targetZone.zone:lower():find("hidden") and isBomberSpawnAirbaseFarFromTarget(spawnAirbase, targetZone) then
          validPairs[#validPairs + 1] = { spawn = spawnZone.zone, target = targetZone.zone }
        end
      end
    end
  end
  
  if #validPairs > 0 then
    local selectedPair = validPairs[math.random(#validPairs)]
    local spawnZone = selectedPair.spawn
    local targetZone = selectedPair.target
    
    -- Store zones for mission display
    bomberBlueMissionSpawnZone = spawnZone
    bomberBlueMissionTargetZone = targetZone
    
    if spawnBlueBomberStrikerAt(spawnZone, targetZone) then
      ActiveMission['bombBlue'] = true  -- Mark mission as active
    else
      bomberBlueMissionSpawnZone = nil
      bomberBlueMissionTargetZone = nil
    end
  end
end,
canExecute=function()
  if ActiveMission['bombBlue'] then return false end  -- Defense-in-depth: check ActiveMission first
  if timer.getTime()-lastbombBlue_COOLDOWN < bombBlue_COOLDOWN then return false end
  
  for _, spawnZone in ipairs(bc:getZones()) do
    local spawnAirbase = getBomberSpawnAirbase(spawnZone, 2)
    if spawnZone.side == 2 and spawnZone.active and not spawnZone.suspended and not spawnZone.zone:lower():find("hidden") and spawnAirbase then
      for _, targetZone in ipairs(bc:getZones()) do
        if targetZone.side == 1 and targetZone.active and not targetZone.suspended and not targetZone.zone:lower():find("hidden") and isBomberSpawnAirbaseFarFromTarget(spawnAirbase, targetZone) then
          return true
        end
      end
    end
  end
  return false
end
})

-- Track blue bomber mission spawn and target zones
bomberBlueMissionSpawnZone = nil
bomberBlueMissionTargetZone = nil

mc:trackMission({
title = L10N:Get("NORMANDY_MISSION_BOMBER_STRIKE_TITLE"),
description = function()
    local desc = L10N:Get("NORMANDY_MISSION_BOMBER_STRIKE_DESC")
    if bomberBlueMissionSpawnZone and bomberBlueMissionTargetZone then
        desc = desc .. "\n\n" .. L10N:Format("NORMANDY_MISSION_BOMBER_STRIKE_DESC_DETAIL", bomberBlueMissionSpawnZone, bomberBlueMissionTargetZone)
    end
    if redInterceptorActive then
        desc = desc .. "\n\n" .. L10N:Get("NORMANDY_MISSION_BOMBER_STRIKE_WARNING")
    end
    return desc
end,
messageStart = function()
    local msg = L10N:Get("NORMANDY_MISSION_BOMBER_STRIKE_START")
    if bomberBlueMissionSpawnZone and bomberBlueMissionTargetZone then
        msg = msg .. "\n\n" .. L10N:Format("NORMANDY_MISSION_BOMBER_STRIKE_START_DETAIL", bomberBlueMissionSpawnZone, bomberBlueMissionTargetZone)
        msg = msg .. "\n\n" .. L10N:Get("NORMANDY_MISSION_BOMBER_STRIKE_START_WARNING")
    end
    return msg
end,
messageEnd=function() 
    lastbombBlue_COOLDOWN=timer.getTime()
    bomberBlueMissionSpawnZone = nil
    bomberBlueMissionTargetZone = nil
    return L10N:Get("NORMANDY_MISSION_BOMBER_STRIKE_END") 
end,
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
	if not ActiveMission['bombBlue'] then return false end
	if Group.getByName(bomberBlueTemplate) then return true end
	ActiveMission['bombBlue'] = nil  -- Cleanup when mission ends
	return false
end
})

-------------------------------------------- End of Bomber Blue event ------------------------------------------

----------------------------------------------- Navy Artillery event ---------------------------------------------
local navyArty_COOLDOWN = 2400
local lastNavyArty_COOLDOWN = -navyArty_COOLDOWN
-- Navy Artillery event
evc:addEvent({
id='navyArty',
action=function()
  -- Spawn Navy Artillery at CarrierGroup to target Saint-Pierre
  spawnNavyArtyAt("NavyStrike", "Saint-Pierre", "Carpiquet")
  ActiveMission['navyArty'] = true  -- Mark mission as active
end,
canExecute=function()
  if ActiveMission['navyArty'] then return false end  -- Defense-in-depth: check ActiveMission first
  if timer.getTime()-lastNavyArty_COOLDOWN < navyArty_COOLDOWN then return false end
  if navyArtyActive then return false end
  local trg = {'Saint-Pierre'}
  for _,v in ipairs(trg) do
    if bc:getZoneByName(v).side == 1 then return true end
  end
  return false
end
})

mc:trackMission({
title = L10N:Get("NORMANDY_MISSION_NAVAL_ARTY_TITLE"),
description = L10N:Get("NORMANDY_MISSION_NAVAL_ARTY_DESC"),
messageStart = L10N:Get("NORMANDY_MISSION_NAVAL_ARTY_START"),
messageEnd=function() lastNavyArty_COOLDOWN=timer.getTime() return L10N:Get("NORMANDY_MISSION_NAVAL_ARTY_END") end,
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
    if not ActiveMission['navyArty'] then return false end
    if navyArtyActive then return true end
    ActiveMission['navyArty'] = nil  -- Cleanup when mission ends
    return false
end
})

-------------------------------------------- End of Navy Artillery event ------------------------------------------
---
---------------------------------------------- V1 Artillery event ---------------------------------------------
local v1Arty_COOLDOWN = 1200
local lastV1Arty_COOLDOWN = -v1Arty_COOLDOWN

-- Helper function to check if ANY V1 site is active
local function isAnyV1Active()
    for siteName, isActive in pairs(v1ArtyActive) do
        if isActive then return true end
    end
    return false
end

-- V1 Artillery event - Now uses random site selection
evc:addEvent({
    id='v1Arty',
    action=function()
        -- Use the random V1 launcher function
        launchRandomV1Artillery()
        ActiveMission['v1Arty'] = true  -- Mark mission as active
    end,
    canExecute=function()
        if ActiveMission['v1Arty'] then return false end  -- Defense-in-depth: check ActiveMission first
        if timer.getTime() - lastV1Arty_COOLDOWN < v1Arty_COOLDOWN then return false end
        if isAnyV1Active() then return false end
        
        -- Check if ANY target zones configured in V1_SITE_CONFIG are Blue
        for siteName, targetZones in pairs(V1_SITE_CONFIG) do
            for _, zoneName in ipairs(targetZones) do
                local zone = bc:getZoneByName(zoneName)
                if zone and zone.side == 2 then
                    return true
                end
            end
        end
        return false
    end
})

mc:trackMission({
    title = L10N:Get("NORMANDY_MISSION_V1_TITLE"),
    description = L10N:Get("NORMANDY_MISSION_V1_DESC"),
    messageStart = L10N:Get("NORMANDY_MISSION_V1_START"),
    messageEnd = function() 
        lastV1Arty_COOLDOWN = timer.getTime() 
        return L10N:Get("NORMANDY_MISSION_V1_END") 
    end,
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
        if not ActiveMission['v1Arty'] then return false end
        if isAnyV1Active() then return true end
        ActiveMission['v1Arty'] = nil  -- Cleanup when mission ends
        return false
    end
})
-------------------------------------------- End of V1 Artillery event ------------------------------------------
-- scenery and missions

local sceneryList = {
  ["RailwayLondonVictoriaStation"] = {SCENERY:FindByZoneName("HiddenRailwayLondonVictoriaStation")},
  ["RailwayWaterlooStation"] = {SCENERY:FindByZoneName("HiddenRailwayWaterlooStation")},
  ["RailwayLondonBridgeStation"] = {SCENERY:FindByZoneName("HiddenRailwayLondonBridgeStation")},
  ["RailwayDover"] = {SCENERY:FindByZoneName("HiddenRailwayDover")},
  ["RailwayFarnborough"] = {SCENERY:FindByZoneName("HiddenRailwayFarnborough")},
  ["RailwayFord"] = {SCENERY:FindByZoneName("HiddenRailwayFord")},
  ["RailwayHawkinge"] = {SCENERY:FindByZoneName("HiddenRailwayHawkinge")},
  ["RailwayCherbourg"] = {SCENERY:FindByZoneName("HiddenRailwayCherbourg")},
  ["RailwayValognes"] = {SCENERY:FindByZoneName("HiddenRailwayValognes")},
  ["RailwayTrainDepotValognes"] = {SCENERY:FindByZoneName("HiddenTrainDepotValognes")},
  ["RailwayCaen"] = {SCENERY:FindByZoneName("HiddenRailwayCaen")},
  ["RailwayLeHavre"] = {SCENERY:FindByZoneName("HiddenRailwayLeHavre")},
  ["RailwayBernay"] = {SCENERY:FindByZoneName("HiddenRailwayBernay")},
  ["RailwaySaintAndre"] = {SCENERY:FindByZoneName("HiddenRailwaySaintAndre")},
  ["RailwayOrly"] = {SCENERY:FindByZoneName("HiddenRailwayOrly")},
  ["RailwayParisSaintLazare"] = {SCENERY:FindByZoneName("HiddenRailwayParisSaintLazare")},
  ["RailwayParisGareDeLest"] = {SCENERY:FindByZoneName("HiddenRailwayParisGareDeLest")},
  ["RailwayParisGareDuNord"] = {SCENERY:FindByZoneName("HiddenRailwayParisGareDuNord")},
  ["RailwayFecamp"] = {SCENERY:FindByZoneName("HiddenRailwayFecamp")},
  ["RailwayPowerplantFecamp"] = {SCENERY:FindByZoneName("HiddenRailwayPowerplantFecamp")},
  ["RailwayDepotRouen"] = {SCENERY:FindByZoneName("HiddenRailwayDepotRouen")},
  ["RailwayRouen"] = {SCENERY:FindByZoneName("HiddenRailwayRouen")},
  ["RailwayDepotSaintAubain"] = {SCENERY:FindByZoneName("HiddenRailwayDepotSaintAubain")},
  ["RailwayTrainDepotAmiens"] = {SCENERY:FindByZoneName("HiddenRailwayTrainDepotAmiens")},
  ["RailwayAbbeville"] = {SCENERY:FindByZoneName("HiddenRailwayAbbeville")},
  ["RailwayDunkirkPort"] = {SCENERY:FindByZoneName("HiddenRailwayDunkirkPort")},
  ["RailwayLeTouquet"] = {SCENERY:FindByZoneName("HiddenRailwayLeTouquet")},
  ["RailwayCalais"] = {SCENERY:FindByZoneName("HiddenRailwayCalais")},

  --["SuezBridge"] = {SCENERY:FindByZoneName("SuezBridge")},
 -- ["factoryBulding3"] = {SCENERY:FindByZoneName("factoryBulding3")},
 -- ["factoryBulding2"] = {SCENERY:FindByZoneName("factoryBulding2")},
 -- ["factoryBulding"] = {SCENERY:FindByZoneName("factoryBulding")},
}

-- Railway Station to Group Mapping
-- Maps railway stations to military groups that depend on them for supply
RAILWAY_STATION_GROUPS = {
	["RailwayLondonVictoriaStation"] = {
		"UK_Train_London-resupply-Farnborough"
	},
	["RailwayWaterlooStation"] = {
		"UK_Train_London-resupply-Chailey",
		"UK_Train_London-resupply-Ford"
	},
	["RailwayLondonBridgeStation"] = {
		"UK_Train_London-resupply-Manston",
		"UK_Train_London-resupply-Hawkinge"
		
	},
	["RailwayDover"] = {
		"UK_Train_Manston-resupply-Dover"
	},
	["RailwayFarnborough"] = {
		"UK_Train_London-resupply-Farnborough"
	},
	["RailwayFord"] = {
		"UK_Train_London-resupply-Ford"
	},
	["RailwayHawkinge"] = {
		"UK_Train_London-resupply-Hawkinge"
	},
	["RailwayCherbourg"] = {
		"AXE_Train_Cherbourg-resupply-Valognes"
    },
	["RailwayValognes"] = {
		"AXE_Train_Cherbourg-resupply-Valognes"
	},
	["RailwayTrainDepotValognes"] = {
		"AXE_Train_Valognes-resupply-Le Molay"
	},
	["RailwayCaen"] = {
		"AXE_Train_Le Molay-resupply-Caen",
		"AXE_Train_Bernay-resupply-Caen"
	},
	["RailwayLeHavre"] = {
		"AXE_Train_Le Havre-resupply-Fecamp",
		"AXE_Train_Le Havre-resupply-Rouen"
	},
	["RailwayBernay"] = {
		"AXE_Train_Bernay-resupply-Caen",
		"AXE_Train_Saint-Andre-resupply-Bernay"
	},
	["RailwaySaintAndre"] = {
		"AXE_Train_Saint-Andre-resupply-Bernay",
		"AXE_Train_Paris-resupply-Saint-Andre"
	},
	["RailwayOrly"] = {
		"AXE_Train_Paris-resupply-Orly"
	},
	["RailwayParisSaintLazare"] = {
		"AXE_Train_Paris-resupply-Saint-Andre"
	},
	["RailwayParisGareDeLest"] = {
		"AXE_Train_Paris-resupply-Orly"
	},
	["RailwayParisGareDuNord"] = {
		"AXE_Train_Paris-resupply-Fecamp",
		"AXE_Train_Paris-resupply-Saint-Aubain"
	},
	["RailwayFecamp"] = {
		"AXE_Train_Le Havre-resupply-Fecamp"
	},
	["RailwayPowerplantFecamp"] = {
		"AXE_Train_Paris-resupply-Fecamp",
		"AXE_Train_Le Havre-resupply-Fecamp"
	},
	["RailwayDepotRouen"] = {
		"AXE_Train_Le Havre-resupply-Rouen"
	},
	["RailwayRouen"] = {
		"AXE_Train_Le Havre-resupply-Rouen"
	},
	["RailwayDepotSaintAubain"] = {
		"AXE_Train_Paris-resupply-Saint-Aubain"
	},
	["RailwayTrainDepotAmiens"] = {
		"AXE_Train_Amiens-resupply-Abbeville"
	},
	["RailwayAbbeville"] = {
		"AXE_Train_Amiens-resupply-Abbeville",
		"AXE_Train_Abbeville-resupply-Le Touquet"
	},
	["RailwayDunkirkPort"] = {
		"AXE_Train_Dunkirk-Port-resupply-Calais"
	},
	["RailwayLeTouquet"] = {
		"AXE_Train_Abbeville-resupply-Le Touquet"
	},
	["RailwayCalais"] = {
		"AXE_Train_Dunkirk-Port-resupply-Calais"
	},
}

if bc:isNormandyTheatre() then
	bc:registerRailwayStationGroups(RAILWAY_STATION_GROUPS)
end

-- Track which stations have been destroyed to avoid duplicate processing
local railwayStationsDestroyed = {}

-- Track which train groups have been destroyed to avoid duplicate processing
local trainGroupsDestroyed = {}

DEPENDENT_DEBUG_LOGGING = false
-- Helper functions for debug logging
local function dependLog(message)
    if DEPENDENT_DEBUG_LOGGING then
        env.info(message)
    end
end


-- Kept for comparison while the active path uses BattleCommander's localized implementation.
local function destroyRailwayDependentGroupsLegacy(stationName)
    env.info("destroyRailwayDependentGroups: ===== CALLED FOR STATION: " .. tostring(stationName) .. " =====")
    
    if railwayStationsDestroyed[stationName] then
        env.info("destroyRailwayDependentGroups: Station " .. stationName .. " already processed, returning early")
        return -- Already processed this station
    end
    
    railwayStationsDestroyed[stationName] = true
    dependLog("destroyRailwayDependentGroups: Marked station " .. stationName .. " as destroyed in railwayStationsDestroyed table")
    
    local groupsToDestroy = RAILWAY_STATION_GROUPS[stationName]
    if not groupsToDestroy then
        dependLog("destroyRailwayDependentGroups: ERROR - No groups mapped to station " .. stationName .. " in RAILWAY_STATION_GROUPS table")
        dependLog("destroyRailwayDependentGroups: Available stations in RAILWAY_STATION_GROUPS:")
        for stationKey, _ in pairs(RAILWAY_STATION_GROUPS) do
            env.info("destroyRailwayDependentGroups:   - " .. stationKey)
        end
        return
    end
    
   dependLog("destroyRailwayDependentGroups: Found " .. #groupsToDestroy .. " groups to destroy for station " .. stationName)
    for i, groupName in ipairs(groupsToDestroy) do
        env.info("destroyRailwayDependentGroups:   Group " .. i .. ": '" .. groupName .. "'")
    end
    
    local destroyedCount = 0
    local destroyedNames = {}
    local creditsAwarded = { [1] = 0, [2] = 0 }  -- Track credits awarded to each coalition
    
    for _, groupName in ipairs(groupsToDestroy) do
        dependLog("destroyRailwayDependentGroups: Processing group '" .. groupName .. "'...")
        
        local group = Group.getByName(groupName)
        if group then
            local groupCoalition = group:getCoalition()
            dependLog("destroyRailwayDependentGroups: SUCCESS - Found group '" .. groupName .. "', coalition: " .. groupCoalition)
            
            -- Check if group exists and has units
            local units = group:getUnits()
            if units and #units > 0 then
                dependLog("destroyRailwayDependentGroups: Group '" .. groupName .. "' has " .. #units .. " units")
                for j, unit in ipairs(units) do
                    if unit and unit:isExist() then
                        env.info("destroyRailwayDependentGroups:   Unit " .. j .. ": " .. unit:getName() .. " (life: " .. unit:getLife() .. ")")
                    end
                end
            else
                env.info("destroyRailwayDependentGroups: WARNING - Group '" .. groupName .. "' has no units!")
            end
            
            group:destroy()
            trainGroupsDestroyed[groupName] = true
            CustomFlags[groupName] = true
            destroyedCount = destroyedCount + 1
            table.insert(destroyedNames, groupName)
            env.info("destroyRailwayDependentGroups: DESTROYED group '" .. groupName .. "' and set CustomFlags[" .. groupName .. "] = true")
            
            -- Award credits to the opposing coalition
            if groupCoalition == 1 then
                -- RED group destroyed - award to BLUE
                local bonus = 2000
                bc:addFunds(2, bonus)
                creditsAwarded[2] = creditsAwarded[2] + bonus
                dependLog("destroyRailwayDependentGroups: Awarded " .. bonus .. " credits to BLUE (coalition 2) for destroying RED group '" .. groupName .. "'")
            elseif groupCoalition == 2 then
                -- BLUE group destroyed - award to RED
                local bonus = 2000
                bc:addFunds(1, bonus)
                creditsAwarded[1] = creditsAwarded[1] + bonus
                dependLog("destroyRailwayDependentGroups: Awarded " .. bonus .. " credits to RED (coalition 1) for destroying BLUE group '" .. groupName .. "'")
            else
                env.info("destroyRailwayDependentGroups: Unknown coalition " .. groupCoalition .. " for group '" .. groupName .. "' - no credits awarded")
            end
        else
            env.info("destroyRailwayDependentGroups: ERROR - Group '" .. groupName .. "' NOT FOUND in DCS mission!")
            dependLog("destroyRailwayDependentGroups: This means the group name in RAILWAY_STATION_GROUPS doesn't match actual groups in the mission")
        end
    end
    
   dependLog("destroyRailwayDependentGroups: SUMMARY - Destroyed " .. destroyedCount .. " out of " .. #groupsToDestroy .. " groups for station " .. stationName)
    
    -- Provide feedback to players
    if destroyedCount > 0 then
        local stationDisplayName = stationName:gsub("Railway", "Depot ")
        local message = L10N:Format(
            "NORMANDY_RAILWAY_DEPENDENTS_DESTROYED",
            stationDisplayName,
            destroyedCount,
            table.concat(destroyedNames, ", ")
        )
        
        dependLog("destroyRailwayDependentGroups: Sending player notifications...")
        
        -- Send messages and bonuses based on credits awarded
        if creditsAwarded[2] > 0 then
            trigger.action.outText(message, 20)
            local bonusMessage = L10N:Format("NORMANDY_RAILWAY_BONUS", creditsAwarded[2])
            trigger.action.outTextForCoalition(2, bonusMessage, 10)
            dependLog("destroyRailwayDependentGroups: Sent message to BLUE coalition about " .. creditsAwarded[2] .. " credits")
        end
        
        if creditsAwarded[1] > 0 then
            trigger.action.outText(message, 20)
            local bonusMessage = L10N:Format("NORMANDY_RAILWAY_BONUS", creditsAwarded[1])
            trigger.action.outTextForCoalition(1, bonusMessage, 10)
            dependLog("destroyRailwayDependentGroups: Sent message to RED coalition about " .. creditsAwarded[1] .. " credits")
        end
        
        -- If no credits were awarded (neutral groups), still show the message
        if creditsAwarded[1] == 0 and creditsAwarded[2] == 0 then
            trigger.action.outTextForCoalition(2, message, 15)
            trigger.action.outTextForCoalition(1, message, 15)
            dependLog("destroyRailwayDependentGroups: No credits awarded - neutral/unknown groups destroyed")
        end
        
        dependLog("destroyRailwayDependentGroups: Calling bc:drawSupplyArrowsDebounced()...")
        bc:drawSupplyArrowsDebounced()
        dependLog("destroyRailwayDependentGroups: ===== COMPLETED FOR STATION: " .. stationName .. " =====")
    else
        env.info("destroyRailwayDependentGroups: ===== NO GROUPS DESTROYED FOR STATION: " .. stationName .. " =====")
    end
end

local function destroyRailwayDependentGroups(stationName)
	if bc:isNormandyTheatre() then
		bc:destroyRailwayDependentGroups(stationName)
	end
end

RESTORE_RAILWAY_DEBUG_LOGGING = false
-- Helper functions for debug logging
local function restoreRailwayLog(message)
    if RESTORE_RAILWAY_DEBUG_LOGGING then
        env.info(message)
    end
end
-- Function to restore railway destruction state on mission restart
local function restoreRailwayDestructionState()
    env.info("restoreRailwayDestructionState: ===== STARTING RAILWAY RESTORATION CHECK =====")
    
    local stationsProcessed = 0
    local stationsRestored = 0
    
    for stationName, isDestroyed in pairs(CustomFlags) do
        if isDestroyed == true and stationName:lower():find("railway") then
            stationsProcessed = stationsProcessed + 1
            restoreRailwayLog("restoreRailwayDestructionState: Processing destroyed station: " .. stationName)
            
            -- Find and destroy the scenery objects using explosions
            local sceneries = sceneryList[stationName]
            if sceneries then
                restoreRailwayLog("restoreRailwayDestructionState: Found " .. #sceneries .. " scenery objects for " .. stationName)
                for i, scenery in ipairs(sceneries) do
                    if scenery then
                        -- Use explosion to damage scenery
                        trigger.action.explosion(scenery:GetPointVec3(), 500)
                        restoreRailwayLog("restoreRailwayDestructionState: Used explosion to damage scenery object " .. i .. " for " .. stationName)
                    else
                        env.info("restoreRailwayDestructionState: WARNING - Scenery object " .. i .. " is NULL for " .. stationName)
                    end
                end
            else
                env.info("restoreRailwayDestructionState: WARNING - No scenery objects found for " .. stationName .. " in sceneryList")
            end
            
            -- Destroy dependent groups using existing function
            restoreRailwayLog("restoreRailwayDestructionState: Calling destroyRailwayDependentGroups for " .. stationName)
            destroyRailwayDependentGroups(stationName)
            bc:drawSupplyArrowsDebounced()
            
            stationsRestored = stationsRestored + 1
            
            restoreRailwayLog("restoreRailwayDestructionState: Completed restoration for " .. stationName)
        end
    end
    
    env.info("restoreRailwayDestructionState: ===== RAILWAY RESTORATION COMPLETE =====")
    restoreRailwayLog("restoreRailwayDestructionState: Processed " .. stationsProcessed .. " destroyed stations, restored " .. stationsRestored)
end


RESTORE_TRAIN_DEBUG_LOGGING = false
-- Helper functions for debug logging
local function restoreTrainLog(message)
    if RESTORE_TRAIN_DEBUG_LOGGING then
        env.info(message)
    end
end
-- Function to restore train group destruction state on mission restart
local function restoreTrainGroupDestructionState()
    env.info("restoreTrainGroupDestructionState: ===== STARTING TRAIN RESTORATION CHECK =====")
    
    local trainsProcessed = 0
    local trainsDestroyed = 0
    
    for groupName, isDestroyed in pairs(CustomFlags) do
        if isDestroyed == true and (groupName:find("AXE_Train_") or groupName:find("UK_Train_")) then
            trainsProcessed = trainsProcessed + 1
            restoreTrainLog("restoreTrainGroupDestructionState: Processing destroyed train: " .. groupName)
            
            -- Mark this train group as destroyed in our tracking
            trainGroupsDestroyed[groupName] = true
            restoreTrainLog("restoreTrainGroupDestructionState: Marked " .. groupName .. " as destroyed in trainGroupsDestroyed table")
            
            -- Find and destroy the train group if it exists
            local group = Group.getByName(groupName)
            if group then
                group:destroy()
                trainsDestroyed = trainsDestroyed + 1
                restoreTrainLog("restoreTrainGroupDestructionState: Successfully destroyed train group " .. groupName)
                
                -- Determine coalition for feedback
                local coalition = 2 -- Default to Blue coalition
                if groupName:find("AXE_Train_") then
                    coalition = 2 -- Blue coalition gets notification for Red train destruction
                    restoreTrainLog("restoreTrainGroupDestructionState: " .. groupName .. " is RED train, notifying BLUE coalition")
                elseif groupName:find("UK_Train_") then
                    coalition = 1 -- Red coalition gets notification for Blue train destruction
                    restoreTrainLog("restoreTrainGroupDestructionState: " .. groupName .. " is BLUE train, notifying RED coalition")
                end
                
                -- Provide feedback to players
                trigger.action.outTextForCoalition(coalition, 
                    L10N:Format("NORMANDY_TRAIN_REMAINS_DESTROYED", groupName), 10)
            else
                env.info("restoreTrainGroupDestructionState: Train group " .. groupName .. " not found in DCS mission (already destroyed or doesn't exist)")
            end
        end
    end
    
    env.info("restoreTrainGroupDestructionState: ===== TRAIN RESTORATION COMPLETE =====")
    restoreTrainLog("restoreTrainGroupDestructionState: Processed " .. trainsProcessed .. " train flags, destroyed " .. trainsDestroyed .. " active trains")
end

local function restoreV1GroupDestructionState()
    env.info("V1 Group System: Checking for previously destroyed V1 launchers...")
    
    for unitName, isDestroyed in pairs(CustomFlags) do
        if isDestroyed == true and unitName:find("V1 Launch Site -") then
            --env.info("V1 Group System: Restoring destruction state for " .. unitName)
            
            -- Extract group name from unit name by removing the unit identifier (# 1-01, etc.)
            local groupName = unitName:match("^(.+) # %d+%-%d+$")
            if groupName then
                --env.info("V1 Group System: Extracted group name: " .. groupName)
                
                -- Find and destroy the V1 group if it exists
                local group = Group.getByName(groupName)
                if group then
                    group:destroy()
                    --env.info("V1 Group System: Destroyed V1 group " .. groupName)
                    
                    -- Provide feedback to Blue coalition (V1 is Red, so Blue gets credit)
                    trigger.action.outTextForCoalition(2, 
                        L10N:Format("NORMANDY_V1_REMAINS_DESTROYED", groupName), 10)
                --else
                    --env.info("V1 Group System: V1 group " .. groupName .. " not found (already destroyed)")
                end
            --else
                --env.info("V1 Group System: Could not extract group name from " .. unitName)
            end
        end
    end
	env.info("V1 Group System: Check complete")
end


-- Call restoration functions to restore states from previous sessions
if bc:isNormandyTheatre() then
	restoreRailwayDestructionState()
	bc:startTrainSupplyMonitor({
		stationGroups = RAILWAY_STATION_GROUPS,
		initialDelay = 60,
		interval = 120,
		notifyRestored = true,
	})
end
restoreV1GroupDestructionState()

-- Monitor train groups for destruction
-- Legacy train monitor replaced by bc:startTrainSupplyMonitor above.
if false then
SCHEDULER:New(nil, function()
    env.info("Train Group System: ===== STARTING TRAIN MONITORING CYCLE =====")
    
    -- Check both Red and Blue coalitions for train groups
    -- Red coalition (coalition 1) - check for AXE_Train_ groups
    local redGroundGroups = coalition.getGroups(1, Group.Category.GROUND) or {}
    local redTrainGroups = coalition.getGroups(1, Group.Category.TRAIN) or {}
    
    -- Blue coalition (coalition 2) - check for UK_Train_ groups  
    local blueGroundGroups = coalition.getGroups(2, Group.Category.GROUND) or {}
    local blueTrainGroups = coalition.getGroups(2, Group.Category.TRAIN) or {}
    
    -- env.info("Train Group System: Found " .. #redGroundGroups .. " Red ground groups")
    -- env.info("Train Group System: Found " .. #redTrainGroups .. " Red train groups")
    -- env.info("Train Group System: Found " .. #blueGroundGroups .. " Blue ground groups")
    -- env.info("Train Group System: Found " .. #blueTrainGroups .. " Blue train groups")
    
    -- Combine all group types
    local allGroups = {}
    for _, group in ipairs(redGroundGroups) do
        table.insert(allGroups, group)
    end
    for _, group in ipairs(redTrainGroups) do
        table.insert(allGroups, group)
    end
    for _, group in ipairs(blueGroundGroups) do
        table.insert(allGroups, group)
    end
    for _, group in ipairs(blueTrainGroups) do
        table.insert(allGroups, group)
    end
    
    --env.info("Train Group System: Total groups to check: " .. #allGroups)
    
    local trainGroupCount = 0
    local trainGroupsFound = {}
    
    for _, group in ipairs(allGroups) do
        local groupName = group:getName()
        
        -- Check for both AXE_Train_ (Red) and UK_Train_ (Blue) groups
        if groupName and (groupName:find("AXE_Train_") or groupName:find("UK_Train_")) then
            trainGroupCount = trainGroupCount + 1
            table.insert(trainGroupsFound, groupName)
            --env.info("Train Group System: Found train group '" .. groupName .. "', checking status...")
            
            if not trainGroupsDestroyed[groupName] then
                local units = group:getUnits()
                local isDestroyed = false
                
                if not units or #units == 0 then
                    isDestroyed = true
                    --env.info("Train Group System: '" .. groupName .. "' has no units - DESTROYED")
                else
                    -- For trains, check if the single unit is alive
                    local unit = units[1]
                    if not unit or not unit:isExist() or unit:getLife() <= 1 then
                        isDestroyed = true
                        --env.info("Train Group System: '" .. groupName .. "' unit is destroyed/dead - DESTROYED")
                    --else
                        --env.info("Train Group System: '" .. groupName .. "' is still operational (life: " .. unit:getLife() .. ")")
                    end
                end
                
                if isDestroyed then
                    -- Train group has been destroyed
                    trainGroupsDestroyed[groupName] = true
                    CustomFlags[groupName] = true
                    
                    --env.info("Train Group System: '" .. groupName .. "' destroyed, setting CustomFlag")
                    
                    -- Determine coalition for feedback and credits
                    local rewardCoalition, creditAmount
                    if groupName:find("AXE_Train_") then
                        -- Red train destroyed, reward Blue coalition
                        rewardCoalition = 2
                        creditAmount = 1000
                        trigger.action.outTextForCoalition(2, 
                            "Enemy train " .. groupName .. " destroyed!", 10)
                        --env.info("Train Group System: Rewarding BLUE coalition for destroying RED train '" .. groupName .. "'")
                    elseif groupName:find("UK_Train_") then
                        -- Blue train destroyed, reward Red coalition
                        rewardCoalition = 1
                        creditAmount = 1000
                        trigger.action.outTextForCoalition(1, 
                            "Enemy train " .. groupName .. " destroyed!", 10)
                        --env.info("Train Group System: Rewarding RED coalition for destroying BLUE train '" .. groupName .. "'")
                    end
                    
                    -- Award bonus credits for destroying strategic asset
                    if rewardCoalition and creditAmount then
                        bc:addFunds(rewardCoalition, creditAmount)
                        trigger.action.outTextForCoalition(rewardCoalition, 
                            "Strategic asset destroyed: +" .. creditAmount .. " credits", 10)
                        --env.info("Train Group System: Awarded " .. creditAmount .. " credits to coalition " .. rewardCoalition)
                    end
                    
                    -- Update supply arrow display to reflect broken supply chain
                    --env.info("Train Group System: Refreshing supply arrows due to train destruction")
                    bc:drawSupplyArrowsDebounced()
                    
                    -- Notify about supply chain disruption
                    if rewardCoalition then
                        trigger.action.outTextForCoalition(rewardCoalition, 
                            "Enemy supply chain disrupted! Train routes now cut off.", 15)
                    end
                end
            -- else
            --     env.info("Train Group System: '" .. groupName .. "' already marked as destroyed")
            end
        end
    end
    
    --env.info("Train Group System: Found " .. trainGroupCount .. " train groups total:")
    for i, name in ipairs(trainGroupsFound) do
        env.info("Train Group System:   " .. i .. ". " .. name)
    end
    
    env.info("Train Group System: ===== TRAIN MONITORING CYCLE COMPLETE =====")
end, {}, 60, 120)
end

if bc:isNormandyTheatre() then
SCHEDULER:New(nil, function()
    env.info("Real-time Railway Monitoring: Checking scenery health...")
    
    for name, sceneries in pairs(sceneryList) do
        local allBelow50 = true
        local anyDestroyed = false
        
        for _, scenery in ipairs(sceneries) do
            if scenery then
                local life = scenery:GetRelativeLife()
                if life > 50 then
                    allBelow50 = false
                else
                    anyDestroyed = true
                end
            end
        end
        
        -- Check if this railway station was just destroyed (not already flagged)
        if allBelow50 and not CustomFlags[name] then
            env.info("Real-time Railway Monitoring: " .. name .. " just destroyed! Destroying dependent trains...")
            CustomFlags[name] = true
            
            -- CRITICAL: Call the train destruction function immediately during gameplay
            if name:lower():find("railway") then
                destroyRailwayDependentGroups(name)
                env.info("Real-time Railway Monitoring: Processed train destruction for " .. name)
            end
        elseif not allBelow50 and CustomFlags[name] then
            -- Railway has been repaired/restored
            env.info("Real-time Railway Monitoring: " .. name .. " has been restored")
            CustomFlags[name] = nil
        end
    end
    
    env.info("Real-time Railway Monitoring: Check complete")
end, {}, 30, 60)
end



---------------------------------------------------------------------
--                          CAP MISSION                            --

capMissionTarget = nil
capKillsByPlayer = {}
capTargetPlanes = 0
capWinner = nil
capMissionCooldownUntil = 0

mc:trackMission({
    title = function() return L10N:Get("MISSION_CAP_TITLE") end,
    description = function()
        if not next(capKillsByPlayer) then
            return L10N:Format("MISSION_CAP_DESCRIPTION_EMPTY", capTargetPlanes)
        else
            local scoreboard = L10N:Get("MISSION_CAP_SCOREBOARD_HEADER")
            for playerName, kills in pairs(capKillsByPlayer) do
                scoreboard = scoreboard .. string.format("%s: %d\n", playerName, kills)
            end
            return L10N:Format("MISSION_CAP_DESCRIPTION_WITH_SCORE", capTargetPlanes, scoreboard)
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
	title = function() return L10N:Get("MISSION_CAS_TITLE") end,
	description = function()
		if not next(casKillsByPlayer) then
			return L10N:Format("MISSION_CAS_DESCRIPTION_EMPTY", casTargetKills)
		else
			local scoreboard = L10N:Get("MISSION_CAP_SCOREBOARD_HEADER")
			for playerName, kills in pairs(casKillsByPlayer) do
				scoreboard = scoreboard..string.format('%s: %d\n', playerName, kills)
			end
			return L10N:Format("MISSION_CAS_DESCRIPTION_WITH_SCORE", casTargetKills, scoreboard)
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
        groupName = groupName,
        group = group
    }
	if not mission._escortTargetCaptureCleanupRegistered then
		mission._escortTargetCaptureCleanupRegistered = true
		bc:getZoneByName(mission.TargetZone):registerTrigger('captured', function(_, targetZone)
			if targetZone.side ~= 2 or IsGroupActive(mission.missionGroup) then return end
			if missionGroupIDs[mission.zone] then
				for _, data in pairs(missionGroupIDs[mission.zone]) do
					removeMissionMenuForAll(mission.zone, data.groupID)
					if trackedGroups[data.groupName] then
						trackedGroups[data.groupName] = nil
					end
				end
				missionGroupIDs[mission.zone] = nil
			end
			mc.missionFlags[mission.zone] = nil
		end, mission.missionGroup .. 'targetcaptured')
	end
	if IsGroupActive(mission.missionGroup) then
		trigger.action.outSoundForGroup(groupID, "ding.ogg")
		trigger.action.outTextForGroup(groupID, L10N:Format("MISSION_ESCORT_ACTIVE_PENDING", mission.zone, mission.TargetZone), 30)
        return
    end
	if mc.missionFlags[zoneName] then
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, L10N:Format("MISSION_ESCORT_SPECIAL_AVAILABLE", mission.zone, mission.TargetZone), 30)
		return 
	end

    mc:trackMission({
        MainTitle = function() return L10N:Get("MISSION_ESCORT_TITLE") end,
        title = function() return L10N:Get("MISSION_ESCORT_TITLE") end,
		titleBefore = function(self)
			self.notified = true
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, L10N:Format("MISSION_ESCORT_SPECIAL_AVAILABLE", mission.zone, mission.TargetZone), 30)
		 end,
        description = function() return L10N:Format("MISSION_ESCORT_DESCRIPTION", mission.TargetZone) end,
        isEscortMission = true,
        accept = false,
        missionGroup = mission.missionGroup,
        zoneName = zoneName,
        messageStart = function() return L10N:Format("MISSION_ESCORT_START", mission.TargetZone) end,
		missionFail = function(self)
		if not IsGroupActive(mission.missionGroup) then
			self.accept = false
			mc.missionFlags[zoneName] = nil
			if missionGroupIDs[zoneName] and next(missionGroupIDs[zoneName]) then
				for _, data in pairs(missionGroupIDs[zoneName]) do
					local groupID = data.groupID
					local groupName = data.groupName
					local group = data.group
					trigger.action.outSoundForGroup(groupID, "cancel.ogg")
					trigger.action.outTextForGroup(groupID, L10N:Get("SYRIA_ESCORT_FAILED_RETRY"), 30)
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
			for _, data in pairs(missionGroupIDs[zoneName]) do
				local groupID = data.groupID
				local groupName = data.groupName
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
					for _, data in pairs(missionGroupIDs[zoneName]) do
						local groupID = data.groupID
						local groupName = data.groupName
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
--                      RUN WAY STRIKE MISSION                     --

mc:trackMission({
    title=function() return L10N:Get("MISSION_BOMB_RUNWAY_TITLE") end,
    description=function()
      local wp=WaypointList[runwayTargetZone] or ""
      if #runwayNames>1 then
        return L10N:Format("MISSION_BOMB_RUNWAY_DESC_ALL", runwayTargetZone, wp)
      else
        return L10N:Format("MISSION_BOMB_RUNWAY_DESC_ONE", runwayTargetZone, wp)
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
    bc:addMissionTag(runwayTargetZone, L10N:Get("ZONE_MISSION_TAG_BOMB_RUNWAY"))
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
        RUNWAY_ZONE_COOLDOWN[runwayTargetZone] = timer.getTime() + 1800
        bc:removeMissionTag(runwayTargetZone, L10N:Get("ZONE_MISSION_TAG_BOMB_RUNWAY"))
        bc:refreshZoneLabel(runwayTargetZone)
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
--                      END OF RUN WAY STRIKE MISSION              --

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
		not lname:find('hidden') and not lname:find('sam') and not lname:find('defence')
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
	title = function()
		local wp = WaypointList[resupplyTarget1] or ""
		return L10N:Format("NORMANDY_MISSION_RESUPPLY_TITLE", resupplyTarget1, wp)
	end,
	description = function()
		return L10N:Format("NORMANDY_MISSION_RESUPPLY_DESC", resupplyTarget1)
	end,
	messageStart = nil,
	messageEnd = function()
		return L10N:Format("NORMANDY_MISSION_RESUPPLY_END", resupplyTarget1)
	end,
	startAction = function()
		local MissionType = L10N:Get("ZONE_MISSION_TAG_RESUPPLY")
		bc:addMissionTag(resupplyTarget1, MissionType)
		bc:refreshZoneLabel(resupplyTarget1)
		local wp = WaypointList[resupplyTarget1] or ""
		if resupplyCombinedStart1 == resupplyTarget1 and resupplyCombinedStart2 == resupplyTarget2 and resupplyTarget2 then
			local wp2 = WaypointList[resupplyTarget2] or ""
			trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_MISSION_RESUPPLY_START_TWO", resupplyTarget1, wp, resupplyTarget2, wp2), 30)
			resupplySuppressStart2 = resupplyTarget2
			resupplyCombinedStart1 = nil
			resupplyCombinedStart2 = nil
		else
			trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_MISSION_RESUPPLY_START_ONE", resupplyTarget1, wp), 30)
		end
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "ding.ogg")
		end
	end,
	endAction = function()
		local MissionType = L10N:Get("ZONE_MISSION_TAG_RESUPPLY")
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
	title = function()
		local wp = WaypointList[resupplyTarget2] or ""
		return L10N:Format("NORMANDY_MISSION_RESUPPLY_TITLE", resupplyTarget2, wp)
	end,
	description = function()
		return L10N:Format("NORMANDY_MISSION_RESUPPLY_DESC", resupplyTarget2)
	end,
	messageStart = nil,
	messageEnd = function()
		return L10N:Format("NORMANDY_MISSION_RESUPPLY_END", resupplyTarget2)
	end,
	startAction = function()
		local MissionType = L10N:Get("ZONE_MISSION_TAG_RESUPPLY")
		bc:addMissionTag(resupplyTarget2, MissionType)
		bc:refreshZoneLabel(resupplyTarget2)
		resupplyCombinedStart1 = nil
		resupplyCombinedStart2 = nil
		if resupplySuppressStart2 == resupplyTarget2 then
			resupplySuppressStart2 = nil
		else
			local wp = WaypointList[resupplyTarget2] or ""
			trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_MISSION_RESUPPLY_START_ONE", resupplyTarget2, wp), 30)
			if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
				trigger.action.outSoundForCoalition(2, "ding.ogg")
			end
		end
	end,
	endAction = function()
		local MissionType = L10N:Get("ZONE_MISSION_TAG_RESUPPLY")
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
	title = function()
		local wp = WaypointList[attackTarget1] or ""
		return L10N:Format("NORMANDY_MISSION_ATTACK_TITLE", attackTarget1, wp)
	end,
	description = function()
		local wp = WaypointList[attackTarget1] or ""
		return L10N:Format("NORMANDY_MISSION_ATTACK_DESC", attackTarget1)
	end,
	messageStart = nil,
	messageEnd = function()
		return L10N:Format("NORMANDY_MISSION_ATTACK_END", attackTarget1)
	end,
	startAction = function()
		bc:addMissionTag(attackTarget1, L10N:Get("ZONE_MISSION_TAG_ATTACK"))
		bc:refreshZoneLabel(attackTarget1)
		local wp = WaypointList[attackTarget1] or ""
		if attackCombinedStart1 == attackTarget1 and attackCombinedStart2 == attackTarget2 and attackTarget2 then
			local wp2 = WaypointList[attackTarget2] or ""
			trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_MISSION_ATTACK_START_TWO", attackTarget1, wp, attackTarget2, wp2), 30)
			attackSuppressStart2 = attackTarget2
			attackCombinedStart1 = nil
			attackCombinedStart2 = nil
		else
			trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_MISSION_ATTACK_START_ONE", attackTarget1, wp), 30)
		end
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cas.ogg")
		end
	end,
	endAction = function()
		bc:removeMissionTag(attackTarget1, L10N:Get("ZONE_MISSION_TAG_ATTACK"))
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
	title = function()
		local wp = WaypointList[attackTarget2] or ""
		return L10N:Format("NORMANDY_MISSION_ATTACK_TITLE", attackTarget2, wp)
	end,
	description = function()
		local wp = WaypointList[attackTarget2] or ""
		return L10N:Format("NORMANDY_MISSION_ATTACK_DESC", attackTarget2)
	end,
	messageStart = nil,
	messageEnd = function()
		return L10N:Format("NORMANDY_MISSION_ATTACK_END", attackTarget2)
	end,
	startAction = function()
		bc:addMissionTag(attackTarget2, L10N:Get("ZONE_MISSION_TAG_ATTACK"))
		bc:refreshZoneLabel(attackTarget2)
		attackCombinedStart1 = nil
		attackCombinedStart2 = nil
		if attackSuppressStart2 == attackTarget2 then
			attackSuppressStart2 = nil
		else
			local wp = WaypointList[attackTarget2] or ""
			trigger.action.outTextForCoalition(2, L10N:Format("NORMANDY_MISSION_ATTACK_START_ONE", attackTarget2, wp), 30)
			if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
				trigger.action.outSoundForCoalition(2, "cas.ogg")
			end
		end
	end,
	endAction = function()
		bc:removeMissionTag(attackTarget2, L10N:Get("ZONE_MISSION_TAG_ATTACK"))
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
    title = function()
        local wp = WaypointList[captureTarget] or ""
        return L10N:Format("NORMANDY_MISSION_CAPTURE_TITLE", captureTarget, wp)
    end,
    description = function()
        return L10N:Format("NORMANDY_MISSION_CAPTURE_DESC", captureTarget) end,
    messageStart = function()
        local wp = WaypointList[captureTarget] or ""
        return L10N:Format("NORMANDY_MISSION_CAPTURE_START", captureTarget, wp)
    end,
    messageEnd = function()
        return L10N:Format("NORMANDY_MISSION_CAPTURE_END", captureTarget) end,
    startAction = function()
        local MissionType = L10N:Get("ZONE_MISSION_TAG_CAPTURE")
        bc:addMissionTag(captureTarget, MissionType)
        bc:refreshZoneLabel(captureTarget)
        if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
        local MissionType = L10N:Get("ZONE_MISSION_TAG_CAPTURE")
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


function generateSEADMission()
    if seadTarget then return true end
    local attackAnchors = {}
    local seenAnchors = {}
    for _, zoneName in ipairs({ attackTarget1, attackTarget2 }) do
        if zoneName and not seenAnchors[zoneName] then
            local targetzn = bc:getZoneByName(zoneName)
            if targetzn and targetzn.zone and targetzn.side == 1 then
                seenAnchors[zoneName] = true
                attackAnchors[#attackAnchors + 1] = targetzn.zone
            end
        end
    end
    if #attackAnchors == 0 then return false end

    local function getMinDist(zoneName)
        local minDist = nil
        for _, anchorZone in ipairs(attackAnchors) do
            local dist = ZONE_DISTANCES[anchorZone] and ZONE_DISTANCES[anchorZone][zoneName]
            if dist and (not minDist or dist < minDist) then
                minDist = dist
            end
        end
        return minDist
    end

    local function isSEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and (not zone.suspended)
           and (lname:find('sam') or lname:find('defence'))
           and (not isZoneUnderSEADMission or not isZoneUnderSEADMission(zone.zone))
    end

    local validSEADZones = {}
    for _, zone in ipairs(bc.zones) do
        local znB = zone.zone
        local minDist = znB and getMinDist(znB) or nil
        if isSEADZone(zone) and bc:HasSeadTargets(zone.zone) and minDist and minDist <= 24000 then
            table.insert(validSEADZones, zone.zone)
        end
    end

    if #validSEADZones == 0 then
        for _, connection in ipairs(bc.connections) do
            local from, to = bc:getConnectionZones(connection)
            if from and to and from.side ~= to.side and from.side ~= 0 and to.side ~= 0 then
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
    local pick = validSEADZones[math.random(#validSEADZones)]
    if pick then
        seadTarget = pick
        return true
    end
end

mc:trackMission({
    title = function() return L10N:Format("MISSION_SEAD_TITLE", seadTarget) end,
    description = function() return L10N:Format("MISSION_SEAD_DESCRIPTION", seadTarget) end,
    messageStart = function() return L10N:Format("MISSION_SEAD_START", seadTarget) end,
    messageEnd = function() return LTGet("MISSION_SEAD_END") end,
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
    local attackAnchors = {}
    local seenAnchors = {}
    for _, zoneName in ipairs({ attackTarget1, attackTarget2 }) do
        if zoneName and not seenAnchors[zoneName] then
            local targetzn = bc:getZoneByName(zoneName)
            if targetzn and targetzn.zone and targetzn.side == 1 then
                seenAnchors[zoneName] = true
                attackAnchors[#attackAnchors + 1] = targetzn.zone
            end
        end
    end
    if #attackAnchors == 0 then return false end

    local function getMinDist(zoneName)
        local minDist = nil
        for _, anchorZone in ipairs(attackAnchors) do
            local dist = ZONE_DISTANCES[anchorZone] and ZONE_DISTANCES[anchorZone][zoneName]
            if dist and (not minDist or dist < minDist) then
                minDist = dist
            end
        end
        return minDist
    end

    local function isDEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and (lname:find('sam') or lname:find('defence'))
    end

    local validDEADZones = {}
    for _, zone in ipairs(bc.zones) do
        local znB = zone.zone
        local minDist = znB and getMinDist(znB) or nil
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
    title = function() return L10N:Format("MISSION_DEAD_TITLE", deadTarget) end,
    description = function() return L10N:Format("MISSION_DEAD_DESCRIPTION", deadTarget) end,
    messageStart = function() return L10N:Format("MISSION_DEAD_START", deadTarget) end,
    messageEnd = function() return LTGet("MISSION_DEAD_END") end,
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
	title = function()
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return LTGet("SYRIA_DYNAMIC_RECON_TITLE_EMPTY") end
		local wp = WaypointList[target] or ""
		return L10N:Format("SYRIA_DYNAMIC_RECON_TITLE", target, wp)
	end,
	description = function()
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return LTGet("SYRIA_DYNAMIC_RECON_DESC_EMPTY") end
		return L10N:Format("SYRIA_DYNAMIC_RECON_DESC", target)
	end,
	messageStart = function()
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return LTGet("SYRIA_DYNAMIC_RECON_START_EMPTY") end
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
		return LTGet("SYRIA_DYNAMIC_RECON_END")
	end,
	startAction = function()
		reconMissionCompleted = false
		reconMissionWinner = nil
		reconMissionCompletedTarget = nil

		bc:addMissionTag(reconMissionTarget, L10N:Get("ZONE_MISSION_TAG_RECON"))
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
			bc:removeMissionTag(target, L10N:Get("ZONE_MISSION_TAG_RECON"))
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


function generateCaptureMission()
    if captureTarget ~= nil then return true end
    
    local validzones = {}
    for _, v in ipairs(bc.zones) do
        if v.active and v.side == 0 and (not v.NeutralAtStart or v.firstCaptureByRed) and 
           not string.find(v.zone, "Hidden") then
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
evc:init()


----------------------- FLAGS --------------------------

function checkZoneFlags()

-------------- Capture/Upgrade Trains Blue-------------------
if trigger.misc.getUserFlag(300) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('London')
		local zntgt = bc:getZoneByName('Farnborough')
            if znsrc and znsrc.side == 2 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(2)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 2 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Farnborough", L10N:Get("ZONE_SIDE_RED"))
				end
			else
				--trigger.action.outText("London is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "London", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(300, 0)
	end

	if trigger.misc.getUserFlag(301) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('London')
		local zntgt = bc:getZoneByName('Manston')
            if znsrc and znsrc.side == 2 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(2)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 2 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Manston", L10N:Get("ZONE_SIDE_RED"))
				end
			else
				--trigger.action.outText("London is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "London", L10N:Get("ZONE_SIDE_BLUE"))
            end
		trigger.action.setUserFlag(301, 0)
	end

	if trigger.misc.getUserFlag(302) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('London')
		local zntgt = bc:getZoneByName('Ford')
            if znsrc and znsrc.side == 2 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(2)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 2 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Ford", L10N:Get("ZONE_SIDE_RED"))
				end
			else
				--trigger.action.outText("London is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "London", L10N:Get("ZONE_SIDE_BLUE"))
            end
		trigger.action.setUserFlag(302, 0)
	end

	if trigger.misc.getUserFlag(303) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('London')
		local zntgt = bc:getZoneByName('Chailey')
            if znsrc and znsrc.side == 2 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(2)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 2 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Chailey", L10N:Get("ZONE_SIDE_RED"))
				end
			else
				--trigger.action.outText("London is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "London", L10N:Get("ZONE_SIDE_BLUE"))
            end
		trigger.action.setUserFlag(303, 0)
	end

	if trigger.misc.getUserFlag(304) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Manston')
		local zntgt = bc:getZoneByName('Dover')
            if znsrc and znsrc.side == 2 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(2)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 2 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Dover", L10N:Get("ZONE_SIDE_RED"))
				end
			else
				--trigger.action.outText("London is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Manston", L10N:Get("ZONE_SIDE_BLUE"))
            end
		trigger.action.setUserFlag(304, 0)
	end


-------------- Capture/Upgrade Trains Red-------------------
	if trigger.misc.getUserFlag(200) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		--env.info("Flag 200 triggered")
		local znsrc = bc:getZoneByName('Cherbourg')
		local zntgt = bc:getZoneByName('Valognes')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
					--env.info("Valognes captured")
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
					--env.info("Valognes upgraded")
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Valognes", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				--env.info("Cherbourg is not Red zone")
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Cherbourg", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(200, 0)
	end

	if trigger.misc.getUserFlag(201) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Valognes')
		local zntgt = bc:getZoneByName('Le Molay')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Le Molay", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Valognes", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(201, 0)
	end

	if trigger.misc.getUserFlag(202) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Le Molay')
		local zntgt = bc:getZoneByName('Caen')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Caen", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Le Molay", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(202, 0)
	end

	if trigger.misc.getUserFlag(203) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Bernay')
		local zntgt = bc:getZoneByName('Caen')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Caen", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Bernay", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(203, 0)
	end


	if trigger.misc.getUserFlag(204) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Saint-Andre')
		local zntgt = bc:getZoneByName('Bernay')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Bernay", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Saint-Andre", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(204, 0)
	end


	if trigger.misc.getUserFlag(205) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Le Havre')
		local zntgt = bc:getZoneByName('Fecamp')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Fecamp", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Le Havre", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(205, 0)
	end


	if trigger.misc.getUserFlag(206) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Le Havre')
		local zntgt = bc:getZoneByName('Rouen')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Rouen", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Le Havre", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(206, 0)
	end

	if trigger.misc.getUserFlag(207) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Paris')
		local zntgt = bc:getZoneByName('Fecamp')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Fecamp", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Paris", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(207, 0)
	end

	if trigger.misc.getUserFlag(208) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Paris')
		local zntgt = bc:getZoneByName('Saint-Aubain')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Saint-Aubain", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Paris", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(208, 0)
	end

	if trigger.misc.getUserFlag(209) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Dunkirk-Port')
		local zntgt = bc:getZoneByName('Calais')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Fecamp", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Amiens", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(209, 0)
	end

	if trigger.misc.getUserFlag(210) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Abbeville')
		local zntgt = bc:getZoneByName('Amiens')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Amiens", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Abbeville", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(210, 0)
	end


	if trigger.misc.getUserFlag(211) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Abbeville')
		local zntgt = bc:getZoneByName('Le Touquet')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Le Touquet", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Abbeville", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(211, 0)
	end

	if trigger.misc.getUserFlag(211) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Calais')
		local zntgt = bc:getZoneByName('Dunkirk-Port')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Dunkirk-Port", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Calais", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(211, 0)
	end

	if trigger.misc.getUserFlag(212) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Paris')
		local zntgt = bc:getZoneByName('Orly')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Orly", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Paris", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(212, 0)
	end

	if trigger.misc.getUserFlag(213) == 1 then
		--trigger.action.outText("Falg Valognes = 1 trigg ", 10)
		local znsrc = bc:getZoneByName('Le Havre')
		local zntgt = bc:getZoneByName('Rouen')
            if znsrc and znsrc.side == 1 then 
				if zntgt and zntgt.side == 0 then
					zntgt:capture(1)
					--trigger.action.outText("Valognes captured ", 10)
				elseif zntgt and zntgt.side == 1 then
					zntgt:upgrade()
					--trigger.action.outText("Valognes upgraded ", 10)
				else
					return L10N:Format("NORMANDY_ZONE_IS_SIDE", "Rouen", L10N:Get("ZONE_SIDE_BLUE"))
				end
			else
				--trigger.action.outText("Cherbourg is not Red, cannot capture or upgrade Valognes", 10)
				return L10N:Format("NORMANDY_ZONE_NOT_SIDE", "Le Havre", L10N:Get("ZONE_SIDE_RED"))
            end
		trigger.action.setUserFlag(213, 0)
	end



---------------------------------------------------------------------
	if trigger.misc.getUserFlag("cap") == 1 then
	  if not anyGroupAlive("f16cap") then
		destroyF16capGroups()
	  trigger.action.setUserFlag("cap", false)
	  end
	end

	if trigger.misc.getUserFlag("cas") == 1 then
	  if not anyGroupAlive("cas") then
		destroyCasGroups()
		trigger.action.setUserFlag("cas", false)
	  end
	end

	if trigger.misc.getUserFlag("decoy") == 1 then
	  if not anyGroupAlive("decoy") then
		destroydecoyGroups()
		trigger.action.setUserFlag("decoy", false)
	  end
	end

	if trigger.misc.getUserFlag("sead") == 1 then
	  if not anyGroupAlive("sead") then
		destroySeadGroups()
		trigger.action.setUserFlag("sead", false)
	  end
	end
end
timer.scheduleFunction(function()
    checkZoneFlags()
    return timer.getTime() + 30
end, {}, timer.getTime() + 2)

buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end

airbaseStatics = {
}

-------------------------- END OF FLAGS --------------------------

env.info("Mission Setup : is completed!")
