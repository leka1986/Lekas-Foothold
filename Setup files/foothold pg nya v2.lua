env.info("ZoneSetup: is loading.")

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

upgrades = {
    carrier = {
        blue = { "bShip Fixed" },
        red = {}
    },
    reDcarrier = {
        blue = {"Red Carrier Blue Group Fixed"},
        red = {"Molniya", "Grisha", "Rezky","Molniya","Grisha", "Molniya","Grisha", "Molniya","SpeedBoats", "SpeedBoats","Rezky","SpeedBoats"}
    },
    reDcarrierhidden = {
        blue = {},
        red = {"Red Carrier Group Fixed 2", "Red Carrier Group Fixed 3"}
    },
    airfield = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor", "bluePATRIOT" },
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group", "Red Armour Group 2", "Red SAM SA-3", "Red SAM SA-6", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15"}
    },
    Lengeh = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor", "bluePATRIOT" },
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group", "Red Armour Group 2", "Red SAM SA-3", "Red SAM SA-6", "Red SAM SHORAD SA-15", "Red SAM SHORAD Pantsir S1"}
    },
    Sharjah = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor"},
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group", "Sharjah HQ", "Red SAM SA-3","Red SAM AAA 2", "Red SAM SA-6", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15"}
    },
	Bandarabbas = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor", "bluePD1" },
        red = { "Enemy ground forces", "Red SAM AAA", "Red Armour Group", "Red SAM SHORAD Tor M2","Red SAM SHORAD Pantsir S1", "Red Armour Group 2", "Red Arty", "Red SAM SA-6", "Red SAM SA-11" }
    },
    Minhad = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor" },
        red = {"Red SAM SA-6", "Enemy ground forces", "Red SAM AAA", "Red Armour Group", "Red Armour Group 2", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15" }
    },
    farp = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Enemy ground forces", "Red SAM AAA", "Red SAM SHORAD SA-19", "Red Armour Group 2", "Red SAM SHORAD Tor M2", "Red SAM SHORAD Pantsir S1","Red Armour Group", "Red SAM SA-3", "Red Arty"}
    },
	Khasab = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Red SAM AAA", "Red Armour Group 2", "Red SAM SHORAD Tor M2", "Red SAM SHORAD Pantsir S1", "Red Armour Group", "Red SAM SA-3"}
    },
    Golf = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Enemy ground forces", "Red SAM AAA","Golf Gaurdhouse", "Red Armour Group 2", "Red SAM SHORAD Pantsir S1", "Red SAM SHORAD SA-19", "Red SAM SHORAD Tor M2","Golf Troops acamady", "Red Armour Group", "Red SAM SA-3", "Golf Warehouse", "Golf Warehouse 2" }
    },
	farpOilFields = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Enemy ground forces", "Red SAM AAA", "Red SAM SHORAD SA-19", "Red Armour Group 2", "Red SAM SHORAD SA-19","Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15","Red Armour Group", "Red SAM SA-3","Oil Refinery Factory", "Oil Refinery Factory-2", 
			"Oil Tank", "Oil Tank-2", "Oil Tank-3", "Oil Tank-4" }
    },
	kishFixed = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2", "bluePD1" },
        red = { "Enemy ground forces", "Red SAM AAA", "Red Armour Group 2", "Red SAM SHORAD SA-8 Fixed Kish", "Red Armour Group", "Red SAM SA-6" }
    },	
	farpkongo = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = {"Red Armour Group", "Red SAM AAA", "Ramp Kongo Solider house","Red SAM AAA 2", "Red SAM SHORAD SA-8", "Red SAM SHORAD SA-8","Ramp Kongo Warehouse", "Ramp Kongo Warehouse 2", "Red SAM SA-3", "Ramp Kongo Troops academy"}
    },
    farp2 = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Red SAM SHORAD SA-8","Red SAM AAA", "Red Armour Group", "Red SAM SHORAD SA-19", "Red Armour Group 2", "Red SAM SHORAD SA-19","Red SAM SHORAD SA-15","Red Arty"}
    },
    farp3 = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group","Red SAM SHORAD SA-19", "Red SAM SHORAD SA-19","Red SAM AAA 3", "Red SAM AAA 4", "Red Armour Group 2", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15", "Red Arty"}
    },
    Khatim = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Enemy ground forces", "Red SAM AAA", "Khatim Fuel tanks", "Red Armour Group", "Khatim Fuel tanks 2", "Red SAM SHORAD SA-19", "Red SAM AAA 3","Khatim Fuel tanks 3", "Red SAM AAA 4", "Red SAM SHORAD SA-15"}
    },
    regularzoneLavan = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red SAM AAA", "Red Armour Group", "Red SAM SHORAD SA-8", "Red SAM SHORAD SA-8","Red SAM SHORAD SA-15", "Red Armour Group 2", "Red SAM SHORAD SA-15"}
    },
	regularzone = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red SAM AAA", "Red Armour Group", "Red SAM AAA 3","Red Armour Group 3", "Red SAM SHORAD SA-8", "Red Armour Group 2", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15"}
    },
	Charlie = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Red SAM AAA","Charlie Tent 1", "Red Armour Group", "Charlie Tent 2","Charlie Tent 3", "Red SAM SHORAD SA-8", "Red Armour Group 2", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15"}
    },
	RadioTower = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red Armour Group", "Red SAM AAA 2", "Red SAM SHORAD SA-8", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15"}
    },
	AlAin = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red SAM AAA", "Red Armour Group", "Al Ain Command building", "Red SAM SHORAD SA-8", "Red SAM SHORAD SA-8","Al Ain Command building 2", "Red Armour Group 2", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15"}
    },
	regularzoneFactory = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red SAM AAA", "Red Armour Group", "Red SAM SHORAD SA-8", "Red SAM SHORAD SA-8","Red SAM SHORAD SA-15", "Red Armour Group 2", "Red SAM SHORAD SA-15","Factory Compound",
	"Factory Compound-2", "Factory Hanger", "Factory Hanger-2", "Factory Hanger-3", "Factory Shipping Containers", "Factory Shipping Containers-2",
	"Factory Shipping Containers-3", "Factory Shipping Containers-4"}
    },
	regularzoneAFB = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = {"Red SAM AAA", "Red Armour Group", "Red SAM SHORAD SA-8", "Red SAM SHORAD SA-8","Red SAM SHORAD SA-15", "Red Armour Group 2", "Red SAM SHORAD SA-15","Tunb island SilkWorm Fixed","Tunb Island Communication Tower" }
    },
	Foxtrot = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red SAM AAA", "Red SAM SHORAD SA-8", "Red Armour Group 2", "Red SAM SHORAD SA-8","Foxtrot OutPost", "Red Armour Group", "Red SAM SHORAD Pantsir S1"}
    },
	regularzoneParegaan = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Red Armour Group", "Red SAM AAA", "Red SAM SHORAD Pantsir S1", "Red Armour Group 2", "Red SAM SA-11","Red SAM SHORAD Tor M2" }
    },
    specialSAMSamathe = {
        blue = { "blueInfantry", "bSamIR", "blueInfantry", "blueInfantry" },
        red = { "Red SAM AAA", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15","Red SAM AAA 2", "Samathe Fuel Depo" ,"Samathe Fuel Depo-2", "Enemy ground forces","Samathe HQ Building", "Samathe Factory", "Red SAM SA-3", "Red SAM SA-6" }
    },
    specialSAM2 = {
        blue = { "blueInfantry", "bSamIR", "blueInfantry", "blueInfantry" },
        red = { "Red SAM AAA", "Red Armour Group 2", "Red SAM SHORAD Tor M2", "Red Armour Group", "Red SAM SA-3", "Red SAM SA-2" }
    },
	specialSAM2fixed = {
        blue = {},
        red = { "Red SAM SA-11","Red SAM SHORAD SA-19 Fixed", "Red SAM SHORAD SA-15 Fixed", "Red SAM AAA" }
    },
	specialTunb = {
        blue = {},
        red = { "Red SAM AAA Fixed Tunb Defence", "Red SAM SHORAD SA-19 Fixed Tunb Defence", "Red SAM SA-6 Fixed Tunb Defence"}
    },
    mission2 = {
        blue = { "blueInfantry", "blueArmor" },
        red = { "Enemy ground forces", "Red SAM AAA", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15","Red Armour Group 2", "Red SAM SHORAD SA-19" ,"Fuel Depo", "Fuel Depo-1", "Fuel Depo-2", "Fuel Depo-3", 
		"Fuel Depo-4", "Fuel Depo-5", "Fuel Depo-6", "Fuel Depo-7", "Fuel Depo Factory", "Fuel Depo Factory-2"}
    },
	InsurgentCampmission = {
        blue = {},
        red = { "InsurgentCamp Fixed Group", "InsurgentCamp Fixed Group2", "InsurgentCamp Fixed Group3Convoy", "Red SAM SHORAD Fixed Group4" }
    },
    mission3 = {
        blue = {},
        red = { "Enemy Task forces", "Red SAM AAA", "Red Armour Group", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15","Red SAM SHORAD SA-19", "Red Armour Group 2", "Red SAM SHORAD SA-19","ChemSite FactoryBuilding", "ChemSite Tank", "ChemSite Tank 2", "ChemSite FactoryBuilding 2" }
    },
    mission4 = {
        blue = {},
        red = { "Enemy Task forces", "Red Armour Group", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15","Red SAM SA-10", "Secrect Tech Waste", "Red Armour Group 2", "Secrect Tech Building", "Secrect Tech Building 2"}
    },
    mission5Fixed = {
        blue = { "blueInfantry", "blueArmor" },
        red = { "TankFactory Fixed Group 1", "TankFactory Fixed Group 2", "Red SAM AAA Fixed Group 3", "Red SAM SHORAD SA-19 Fixed TankFacotory", "redInfantry Fixed TankFacotory", "Tank Factory main",
		 "Tank Factory secondary", "Red SAM AAA 3 Fixed TankFactory", "Red SAM AAA 4 Fixed TankFactory" }
    },
    scudcity = {
        blue = {},
        red = { "Scuds", "Scuds", "Scuds", "Scuds","Scuds", "Scuds", "Scuds", "Scuds", "Scuds","Scuds"}
    },
	KhasabDefencefixed = {
        blue = { "blueInfantry", "blueArmor" },
        red = { "Red SAM SHORAD SA-15 Fixed Khasab", "Red SAM SA-6 Khasab Fixed" }
    },
	 
	SharjahDefencefixed = {
        blue = { "blueInfantry", "blueArmor" },
        red = { "Red SAM AAA", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-19", "Red SAM SHORAD SA-8","Red SAM SA-6" }
    },
    specialLar = {
        blue = { "blueInfantry", "bSamIR", "bluePD", "bluePD1", "bSamBig" },
        red = { "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15","Red SAM AAA", "Red Armour Group 2", "Red SAM SA-6", "Red Armour Group", "Red SAM SA-6" }
    },
	
	specialLarSAM = {
		blue = {},
        red = {"Red SAM SA-11", "Red SAM SHORAD Tor M2", "Red SAM SHORAD SA-15", "Red SAM AAA", "Red SAM SHORAD Pantsir S1"}
    },
    convoy = {
        blue = { "blueInfantry" },
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group 2", "Red SAM SHORAD SA-19", "Red SAM SHORAD SA-19","Red Armour Group", "Red SAM SHORAD SA-8" }
    },
	Hidden2Group = {
        blue = {},
        red = { "Red SAM SHORAD SA-8 Hiddengroup2-Fixed", "Hiddengroup2-Fixed7"}
    },
	HiddenMinhadMission = {
        blue = {},
        red = { "HiddenMinhadMission-Fixed1", "HiddenMinhadMission-Fixed2", "HiddenMinhadMission-Fixed3"}
    },
	HiddenKhaimahMission = {
        blue = {},
        red = { "HiddenKhaimahMission Fixed 1", "HiddenKhaimahMission Fixed 2", "HiddenKhaimahMission Fixed 3", "HiddenKhaimahMission Fixed 4",
				"HiddenKhaimahMission Fixed 5", "HiddenKhaimahMission Fixed 6"}
    },
	HiddenSharjahMission = {
        blue = {},
        red = { "HiddenSharjahMission Fixed"}
    },
	HiddenMoradiQeshmMission = {
        blue = {},
        red = { "HiddenMoradiQeshmMission Fixed 1", "HiddenMoradiQeshmMission Fixed 2", "HiddenMoradiQeshmMission Fixed 3", "HiddenMoradiQeshmMission Fixed 4",
				"HiddenMoradiQeshmMission Fixed 5", "HiddenMoradiQeshmMission Fixed 6" }
    },
	HiddenGroup = {
        blue = {},
        red = {"HiddenGroup","HiddenGroup","HiddenGroup","HiddenGroup","HiddenGroup","HiddenGroup","HiddenGroup","HiddenGroup","HiddenGroup","HiddenGroup"}
    },
	Hidden4Group = {
        blue = {},
        red = { "HiddenGroup4-Fixed-1", "HiddenGroup4-Fixed-2", "HiddenGroup4-Fixed-3", "HiddenGroup4-Fixed-4",
				"HiddenGroup4-Fixed-5", "HiddenGroup4-Fixed-6" , "HiddenGroup4-Fixed-7", "HiddenGroup4-Fixed-8",
				"HiddenGroup4-Fixed-9", "HiddenGroup4-Fixed-10", "HiddenGroup4-Fixed-11","HiddenGroup4-Fixed-12",
				"HiddenGroup4-Fixed-13","HiddenGroup4-Fixed-14","HiddenGroup4-Fixed-15"}
    }, 
	Hidden1GroupEWR = {
        blue = {},
        red = { "Red EWR LAR Fixed", "Red EWR BandarEast Fixed", "Red EWR Larak Fixed", "Red EWR Larak Fixed 2", "Red EWR Island Fixed", "Red EWR Larak Fixed -1", 
		"Red EWR BandarEast Fixed-1"}
    }
}

flavor = {
	aldhafra = L10N:Format("PG_FLAVOR_AL_DHAFRA", 1),
	carrier = L10N:Get("PG_FLAVOR_CARRIER"),
	alain = L10N:Format("PG_FLAVOR_AL_AIN", 3),
	alhuti = L10N:Format("PG_FLAVOR_AL_HUTI", 4),
	minhad = L10N:Format("PG_FLAVOR_AL_MINHAD", 5),
	sharjah = L10N:Format("PG_FLAVOR_SHARJAH", 6),
	fujairah = L10N:Format("PG_FLAVOR_FUJAIRAH", 8),
	khaimah = L10N:Format("PG_FLAVOR_RAS_AL_KHAIMAH", 9),
	alpha = L10N:Format("PG_FLAVOR_ALPHA", 11),
	khasab = L10N:Format("PG_FLAVOR_KHASAB", 13),
	redcarrier = L10N:Format("PG_FLAVOR_RED_CARRIER", 14),
	charlie = L10N:Format("PG_FLAVOR_CHARLIE", 10),
	convoy = L10N:Format("PG_FLAVOR_CONVOY", 12),
	bandarabbas = L10N:Format("PG_FLAVOR_BANDAR_ABBAS", 15),
	radio = L10N:Format("PG_FLAVOR_RADIO", 16),
	oilfields = L10N:Format("PG_FLAVOR_OIL_FIELDS", 18),
	dehbarez = L10N:Format("PG_FLAVOR_DEHBAREZ", 17),
	paregaan = L10N:Format("PG_FLAVOR_PAREGAAN", 19),
	khamets = L10N:Format("PG_FLAVOR_KHAMETS", 21),
	bandarlengeh = L10N:Format("PG_FLAVOR_BANDAR_LENGEH", 28),
	samathe = L10N:Format("PG_FLAVOR_SAMATHE", 20),
	echo = L10N:Format("PG_FLAVOR_ECHO", 24),
	sunny = L10N:Format("PG_FLAVOR_SUNNY", 25),
	rampkongo = L10N:Format("PG_FLAVOR_RAMP_KONGO", 26),
	delta = L10N:Format("PG_FLAVOR_DELTA", 23),
	factory = L10N:Format("PG_FLAVOR_FACTORY", 22),
	qeshmisland = L10N:Format("PG_FLAVOR_QESHM_ISLAND", 14),
	foxtrot = L10N:Format("PG_FLAVOR_FOXTROT", 30),
	lar = L10N:Format("PG_FLAVOR_LAR", 31),
	kish = L10N:Format("PG_FLAVOR_KISH", 29),
	alkhatim = L10N:Format("PG_FLAVOR_AL_KHATIM", 2),
	dahid = L10N:Format("PG_FLAVOR_AL_DAHID", 7),
	golf = L10N:Format("PG_FLAVOR_GOLF", 27),
	chemsite = L10N:Get("PG_FLAVOR_CHEMSITE"),
	insurgentcamp = L10N:Get("PG_FLAVOR_INSURGENT_CAMP"),
	secrettechfacility = L10N:Get("PG_FLAVOR_SECRET_TECH_FACILITY"),
	fueldepo = L10N:Get("PG_FLAVOR_FUEL_DEPOT"),
	tankfactory = L10N:Get("PG_FLAVOR_TANK_FACTORY"),
	tunbisland = L10N:Get("PG_FLAVOR_TUNB_ISLAND"),
	abumusa = L10N:Get("PG_FLAVOR_ABU_MUSA"),
	sirri = L10N:Get("PG_FLAVOR_SIRRI"),
	lavan = L10N:Get("PG_FLAVOR_LAVAN"),
	khasabdefence = L10N:Get("PG_FLAVOR_KHASAB_DEFENCE"),
	sharjadefence = L10N:Get("PG_FLAVOR_SHARJAH_DEFENCE"),
	qeshmislanddefence = L10N:Get("PG_FLAVOR_QESHM_ISLAND_DEFENCE"),
	
}	
WaypointList = {
    ["Al Dhafra"] = ' (1)',
    ["Al Khatim"] = ' (2)',
    ["Al Ain"] = ' (3)',
    ["Al Huti"] = ' (4)',
    ["Al Minhad AFB"] = ' (5)',
    Sharjah = ' (6)',
    ["Al Dahid"] = ' (7)',
    ["Fujairah Intl"] = ' (8)',
    ["Ras Al Khaimah"] = ' (9)',
    Charlie = ' (10)',
    Alpha = ' (11)',
    Convoy = ' (12)',
    Khasab = ' (13)',
    ["Qeshm Island"] = ' (14)',
    BandarAbbas = ' (15)',
    ["Radio Tower"] = ' (16)',
    Dehbarez = ' (17)',
    ["Oil Fields"] = ' (18)',
    Paregaan = ' (19)',
    Samathe = ' (20)',
    Khamets = ' (21)',
    Factory = ' (22)',
    Delta = ' (23)',
    Echo = ' (24)',
    Sunny = ' (25)',
    ["Ramp-Kongo"] = ' (26)',
    Golf = ' (27)',
    ["Bandar Lengeh"] = ' (28)',
	Moradi = ' (29)',
    ["Tunb Island AFB"] = ' (30)',
    ["Abu Musa Island"] = ' (31)',
    ["Sirri Island"] = ' (32)',
	['Red Carrier'] = ' (33)',
    ["Kish intl"] = ' (34)',
    ["Lavan Island"] = ' (35)',
    Foxtrot = ' (36)',
    Lar = ' (37)'
}
FootholdSaveBaseName = ((Era == 'Coldwar') and 'foothold_persiangulf_Coldwar' or 'foothold_persiangulf')

local filepath = FootholdSaveBaseName .. '.lua'
if lfs then 
	FootholdSavePath = FootholdSavePath or (lfs.writedir()..'Missions/Saves')
	lfs.mkdir(FootholdSavePath)
	filepath = FootholdSavePath .. '/' .. (FootholdSaveBaseName .. '.lua')
	env.info('Foothold - Save file path: '..filepath)
end

local cwSwap = {
	['Red Armour Group']   			= 'Red Armor Group7',
	['Red Armour Group 2']   		= 'Red Armor Group9',
	['Red Armour Group 3']  		= 'Red Armor Group6',
	['blueArmor']  					= 'blueArmor_cw',
	['bluePD'] 						= 'bluePD Coldwar',
	['bluePD 2'] 					= 'bluePD 2 Coldwar',
	['bluePD1'] 					= 'bluePD 2 Coldwar',
	['Red Carrier Group Fixed 2'] 	= '',
	['Red Carrier Group Fixed 3'] 	= '',
	['Red SAM SHORAD Tor M2']  = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
	['Red SAM SHORAD Pantsir S1']  = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },

}

local function deepSwap(t,s)
	for k,v in pairs(t) do
		if type(v)=='table' then
			deepSwap(v,s)
		else
			local sub = s[v]
			if sub ~= nil then
				if sub == '' then
					t[k] = nil
				elseif type(sub)=='table' then
					local mode = sub.mode
					local list = sub.list
					if type(list)=='table' then
						if mode == 'random' then
							if #list > 0 then
								t[k] = list[math.random(1,#list)]
							else
								t[k] = nil
							end
						else
							t[k] = list[1]
							for i=2,#list do
								table.insert(t,list[i])
							end
						end
					else
						t[k] = sub[1]
						for i=2,#sub do
							table.insert(t,sub[i])
						end
					end
				else
					t[k] = sub
				end
			end
		end
	end
end

if Era == 'Coldwar' then
	deepSwap(upgrades,cwSwap)
end

local SamSwap = {

	['Red SAM SA-10'] = { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },
	['Red SAM SA-11'] = { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },
	
}

local SamSwapNoTorM2AndPantsir = {
	['Red SAM SHORAD Pantsir S1'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
	['Red SAM SHORAD Tor M2'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
}

local SamSwapNoSA15 = {
	['Red SAM SHORAD SA-15'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
	['Red SAM SHORAD SA-15 Fixed Khasab']  = 'Red SAM SHORAD SA-8 Fixed Khasab',
	['Red SAM SHORAD SA-15 Fixed'] = 'Red SAM SHORAD SA-8 Fixed',
}

if NoSA10AndSA11 == true then
	deepSwap(upgrades,SamSwap)
end
if NoTorM2AndPantsir == true then
	deepSwap(upgrades,SamSwapNoTorM2AndPantsir)
end
if NoSA15 == true then
	deepSwap(upgrades,SamSwapNoSA15)
end

-- Randomized upgrade pools/templates (fresh start only)
RandomRedPool = {
	-- SAM
	"Red SAM SA-10",
	"Red SAM SA-11",
	"Red SAM SA-6",
	"Red SAM SA-2",
	"Red SAM SA-3",
	-- SHORAD
	"Red SAM SHORAD Pantsir S1",
	"Red SAM SHORAD SA-15",
	"Red SAM SHORAD SA-19",
	"Red SAM SHORAD SA-8",
	"Red SAM SHORAD SA-13",
	"Red SAM SHORAD SA-9",
	"Red SAM SHORAD Tor M2",
	-- AAA
	"Red SAM AAA 2",
	"Red SAM AAA 3",
	"Red SAM AAA 4",
	"Red SAM AAA 5",
	"Red SAM AAA",
	-- Ground
	"Enemy Task forces",
	"Enemy ground forces",
	-- Armor
	"Red Armour Group",
	"Red Armour Group 2",
	"Red Armour Group 3",
	-- Arty
	"Red Arty",
	"Red Arty 2",
	"Red Arty 3",
	"Red Arty 4",
}

RandomBluePool = {
	"blueInfantry",
	"blueArmor",
	"bSamIR",
	"bluePD",
	"bluePD 2",
	"bluePD1",
}

ZoneSizeExclusions = {
	small = { "sa-10", "sa-11","sa-2","pantsir","tor m2" },
	medium = { "sa-10", "sa-11","pantsir"},
	redarmycamp = { "sa-10", "sa-11","sa-2","pantsir","tor m2", "sa-15" ,"red sam aaa 3","red sam aaa 4"},
	redarmycamp2 = { "sa-10", "sa-11","sa-2","pantsir","tor m2", "sa-15" ,"red sam aaa 3","red sam aaa 4"},
	redarmycamp3 = { "sa-10", "sa-2","pantsir","tor m2"},

}

if Era == 'Coldwar' then
	deepSwap(RandomRedPool, cwSwap)
	deepSwap(RandomBluePool, cwSwap)
end

if NoSA10AndSA11 == true then
	deepSwap(RandomRedPool, SamSwap)
end
if NoTorM2AndPantsir == true then
	deepSwap(RandomRedPool, SamSwapNoTorM2AndPantsir)
end
if NoSA15 == true then
	deepSwap(RandomRedPool, SamSwapNoSA15)
end

RandomUpgradeTemplates = {
	small = { sam = 0, shorad = {1,2}, aaa = {1,2}, ground = 1, armor = 1, arty = {0,1}, total = {4,7} },
	medium = { sam = {0,1}, shorad = {1,2}, aaa = {1,2}, ground = 1, armor = {1,2}, arty = 1, total = {6,9} },
	big = { sam = 1, shorad = {2,3}, aaa = {1,2}, ground = 1, armor = {1,2}, arty = {1,2}, total = {8,10} },
	extrabig = { sam = 2, shorad = {3,4}, aaa = 2, ground = 1, armor = {1,2}, arty = {1,2}, total = {10,12} },	
	sam = { sam = 1, shorad = {1,2}, aaa = {1,2}, ground = 0, armor = 0, arty = 0, total = {3,5} },
	redarmycamp = { sam = 0, shorad = 0, aaa = 0, ground = {3,5}, armor = 0, arty = {0,5}, total = {6,8} },
	redarmycamp2 = { sam = 0, shorad = 0, aaa = {1,2}, ground = {3,5}, armor = 0, arty = {0,4}, total = {6,8} },
	redarmycamp3 = { sam = {0,2}, shorad = {0,3}, aaa = {1,3}, ground = 0, armor = 0, arty = 0, total = {6,8} },

}

RandomUpgradeTemplatesBlue = {
	small = { sam = {0,1}, ground = 1, armor = 1, total = {2,3} },
	medium = { sam = {0,1}, ground = 1, armor = 1, total = {2,3} },
	big = { sam = {0,1}, ground = 1, armor = 1, total = {2,4} },
	extrabig = { sam = 1, ground = 1, armor = 1, total = {3,4} },
}

RandomGroundGroups = true
RandomBlueGroups = true
AllowScriptedSupplies = AllowScriptedSupplies ~= false

bc = BattleCommander:new(filepath, 13, 60)
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
env.info('Foothold - Rank file path: '..bc.rankFile)
end
Hunt = true

zones = {
	redcarrier = ZoneCommander:new({zone='Red Carrier', side=1, level=25, upgrades=upgrades.reDcarrier, crates={}, flavorText=flavor.redcarrier}),
    aldhafra = ZoneCommander:new({zone='Al Dhafra', size='big', side= StartNormal and 2 or 1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.aldhafra}),
    alhuti = ZoneCommander:new({zone='Al Huti', size='small', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.alhuti}),
    alain = ZoneCommander:new({zone='Al Ain', size='big', side=1, level=25, upgrades=upgrades.AlAin, crates={}, flavorText=flavor.alain}),
    fujairah = ZoneCommander:new({zone='Fujairah Intl', size='big', side=1, level=25, upgrades=upgrades.farp, crates={}, flavorText=flavor.fujairah}),
    minhad = ZoneCommander:new({zone='Al Minhad AFB', size='big', side=1, level=25, upgrades=upgrades.Minhad, crates={}, flavorText=flavor.minhad}),
    sharjah = ZoneCommander:new({zone='Sharjah', size='big', side=1, level=25, upgrades=upgrades.Sharjah, crates={}, flavorText=flavor.sharjah}),
    khaimah = ZoneCommander:new({zone='Ras Al Khaimah', size='big', side=1, level=25, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.khaimah}),
    carrier = ZoneCommander:new({zone='Carrier Group', side=StartNormal and 2 or 0, level=25, upgrades=upgrades.carrier, crates={}, flavorText=flavor.carrier}),
    alpha = ZoneCommander:new({zone='Alpha', size='small', side=1, level=25, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.alpha}),
    khasab = ZoneCommander:new({zone='Khasab', size='big', side=1, level=25, upgrades=upgrades.Khasab, crates={}, flavorText=flavor.khasab}),
    charlie = ZoneCommander:new({zone='Charlie', size='small', side=1, level=25, upgrades=upgrades.Charlie, crates={}, flavorText=flavor.charlie}),
    convoy = ZoneCommander:new({zone='Convoy', size='small', side=1, level=25, upgrades=upgrades.convoy, crates={}, flavorText=flavor.convoy}),
    bandarabbas = ZoneCommander:new({zone='BandarAbbas', size='extrabig', side=1, level=25, upgrades=upgrades.Bandarabbas, crates={}, flavorText=flavor.bandarabbas}),
    radio = ZoneCommander:new({zone='Radio Tower', size='medium', side=1, level=25, upgrades=upgrades.RadioTower, crates={}, flavorText=flavor.radio}),
    dehbarez = ZoneCommander:new({zone='Dehbarez', size='medium', side=1, level=25, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.dehbarez}),
    abumusa = ZoneCommander:new({zone='Abu Musa Island', size='big', side=1, level=25, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.abumusa}),
    sirri = ZoneCommander:new({zone='Sirri Island', size='medium', side=1, level=25, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.sirri}),
    tunbisland = ZoneCommander:new({zone='Tunb Island AFB', size='small', side=1, level=25, upgrades=upgrades.regularzoneAFB, crates={}, flavorText=flavor.tunbisland}),
    moradi = ZoneCommander:new({zone='Moradi', size='big', side=1, level=25, upgrades=upgrades.farp, crates={}, flavorText=flavor.moradi}),
    lavan = ZoneCommander:new({zone='Lavan Island', size='big', side=1, level=25, upgrades=upgrades.regularzoneLavan, crates={}, flavorText=flavor.lavan}),
   
    bandarlengeh = ZoneCommander:new({zone='Bandar Lengeh', size='big', side=1, level=25, upgrades=upgrades.Lengeh, crates={}, flavorText=flavor.bandarlengeh}),
    delta = ZoneCommander:new({zone='Delta', size='medium', side=1, level=25, upgrades=upgrades.farp, crates={}, flavorText=flavor.delta}),

	factory = ZoneCommander:new({zone='Factory', side=1, level=20, upgrades=upgrades.regularzoneFactory, crates={}, flavorText=flavor.factory, income=2}),
	golf = ZoneCommander:new({zone='Golf', size='medium', side=1, level=20, upgrades=upgrades.Golf, crates={}, flavorText=flavor.golf}),
	oilfields = ZoneCommander:new({zone='Oil Fields', side=1, level=20, upgrades=upgrades.farpOilFields, crates={}, flavorText=flavor.oilfields, income=2}),
	foxtrot = ZoneCommander:new({zone='Foxtrot', size='medium', side=1, level=20, upgrades=upgrades.Foxtrot, crates={}, flavorText=flavor.foxtrot}),
	samathe = ZoneCommander:new({zone='Samathe', size='big', side=1, level=20, upgrades=upgrades.specialSAMSamathe, crates={}, flavorText=flavor.samathe}),
	paregaan = ZoneCommander:new({zone='Paregaan', size='big', side=1, level=20, upgrades=upgrades.regularzoneParegaan, crates={}, flavorText=flavor.paregaan}),
	sunny = ZoneCommander:new({zone='Sunny', size='small', side=1, level=20, upgrades=upgrades.farp, crates={}, flavorText=flavor.sunny}),
	khamets = ZoneCommander:new({zone='Khamets', size='small', side=1, level=20, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.khamets}),
	rampkongo = ZoneCommander:new({zone='Ramp-Kongo', size='big', side=1, level=20, upgrades=upgrades.farpkongo, crates={}, flavorText=flavor.rampkongo}),
    lar = ZoneCommander:new({zone='Lar', size='extrabig', side= StartNormal and 1 or 2, level=20, upgrades=upgrades.specialLar, crates={}, flavorText=flavor.lar, income=2}),
	
	    
    qeshmisland = ZoneCommander:new({zone='Qeshm Island', size='extrabig', side=1, level=20, upgrades=upgrades.specialSAM2, crates={}, flavorText=flavor.qeshmisland}),
    echo = ZoneCommander:new({zone='Echo', size='medium', side=1, level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.echo}),

	
    kish = ZoneCommander:new({zone='Kish intl', size='big', side=1, level=25, upgrades=upgrades.kishFixed, crates={}, flavorText=flavor.kish}),
    alkhatim = ZoneCommander:new({zone='Al Khatim', size='small', side=1, level=25, upgrades=upgrades.Khatim, crates={}, flavorText=flavor.alkhatim}),
    dahid = ZoneCommander:new({zone='Al Dahid', size='small', side=1, level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.dahid}),
    insurgentcamp = ZoneCommander:new({zone='InsurgentCamp', side=1, level=25, upgrades=upgrades.InsurgentCampmission, crates={}, flavorText=flavor.insurgentcamp}),
    chemsite = ZoneCommander:new({zone='ChemSite', side=1, level=25, upgrades=upgrades.mission3, crates={}, flavorText=flavor.ChemSite}),
    secrettechfacility = ZoneCommander:new({zone='SecretTechFacility', side=1, level=25, upgrades=upgrades.mission4, crates={}, flavorText=flavor.secrettechfacility}),
    fueldepo = ZoneCommander:new({zone='Fuel Depo', side=1, level=25, upgrades=upgrades.mission2, crates={}, flavorText=flavor.fueldepo}),
	tankfactory = ZoneCommander:new({zone='TankFactory', side=1, level=25, upgrades=upgrades.mission5Fixed, crates={}, flavorText=flavor.tankfactory}),
	scudcity = ZoneCommander:new({zone='Scud City', side=1, level=25, upgrades=upgrades.scudcity, crates={}, flavorText=flavor.scudcity,NeutralAtStart=true,Popup=true}),
	
	dhafradefence = ZoneCommander:new({zone='Al Dhafra-Defence',size='sam', side=1, level=25, upgrades=upgrades.specialLarSAM, crates={}, flavorText=flavor.dhafradefence,NeutralAtStart=true,Popup=true}),
	khasabdefence = ZoneCommander:new({zone='Khasab-Defence', side=1, level=25, upgrades=upgrades.KhasabDefencefixed, crates={}, flavorText=flavor.khasabdefence}),
	sharjadefence = ZoneCommander:new({zone='Sharjah-Defence', size='sam', side=1, level=25, upgrades=upgrades.SharjahDefencefixed, crates={}, flavorText=flavor.sharjadefence}),
	lardefence = ZoneCommander:new({zone='Lar-Defence', side=1, level=25, upgrades=upgrades.specialLarSAM, crates={}, flavorText=flavor.lardefence}),
	qeshmislanddefence = ZoneCommander:new({zone='Qeshm-Island-Defence', size='sam', side=1, level=25, upgrades=upgrades.specialSAM2fixed, crates={}, flavorText=flavor.qeshmislanddefence}),
	tunbdefence = ZoneCommander:new({zone='Tunb Defence', side=1, level=25, upgrades=upgrades.specialTunb, crates={}, flavorText=flavor.tunbdefence}),

	hidden = ZoneCommander:new({zone='Hidden', side=0, level=20, upgrades=upgrades.HiddenGroup, crates={}, flavorText=flavor.hidden, NeutralAtStart=true}),
	hiddenewrnetwork = ZoneCommander:new({zone='Hidden1', side=1, level=25, upgrades=upgrades.Hidden1GroupEWR, crates={}, flavorText=flavor.hiddenewrnetwork}),
	hiddenminhadmission = ZoneCommander:new({zone='HiddenMinhadMission', side=0, level=20, upgrades=upgrades.HiddenMinhadMission, crates={}, flavorText=flavor.hiddenminhadmission,NeutralAtStart=true}),
	hiddensharjahmission = ZoneCommander:new({zone='HiddenSharjahMission', side=0, level=20, upgrades=upgrades.HiddenSharjahMission, crates={}, flavorText=flavor.hiddensharjahmission,NeutralAtStart=true}),
	hiddenkhaimahmission = ZoneCommander:new({zone='HiddenKhaimahMission', side=0, level=20, upgrades=upgrades.HiddenKhaimahMission, crates={}, flavorText=flavor.hiddenkhaimahmission,NeutralAtStart=true}),
	hidden2 = ZoneCommander:new({zone='Hidden2', side=1, level=20, upgrades=upgrades.Hidden2Group, crates={}, flavorText=flavor.hidden2,NeutralAtStart=true}),
	Hiddenmoradiqeshmmission = ZoneCommander:new({zone='HiddenMoradiQeshmMission', side=0, level=20, upgrades=upgrades.HiddenMoradiQeshmMission, crates={}, flavorText=flavor.Hiddenmoradiqeshmmission,NeutralAtStart=true}),
	hidden4 = ZoneCommander:new({zone='Hidden4', side=0, level=20, upgrades=upgrades.Hidden4Group, crates={}, flavorText=flavor.hidden4,NeutralAtStart=true}),
	hiddenwaters = ZoneCommander:new({zone='HiddenWaters', side=1, level=20, upgrades=upgrades.reDcarrierhidden, crates={}, flavorText=flavor.hiddenwaters,NeutralAtStart=true,Popup=true}),

    insurgencygridcn76 = ZoneCommander:new({zone='Insurgency Grid CN76', size=(math.random(1,2) == 1 and 'redarmycamp' or 'redarmycamp2'), side=1, level=20, upgrades=upgrades.farp, crates={}, flavorText=flavor.insurgencygridcn76,NeutralAtStart=true,Popup=true}),
    insurgencygridcq37 = ZoneCommander:new({zone='Insurgency Grid CQ37', size=(math.random(1,2) == 1 and 'redarmycamp' or 'redarmycamp2'), side=1, level=20, upgrades=upgrades.farp, crates={}, flavorText=flavor.insurgencygridcq37,NeutralAtStart=true,Popup=true}),

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
        'BLUE_AH-64D_OneShip_Load2',
        'BLUE_AH-64D_TwoShip_Load2',
		'OH_58D',
        'OH_58D_TwoShip',
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
        'BLUE_AH-64D_OneShip_Load2',
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
	ArtilleryConvoyLong = {
			"ArtilleryConvoyLong 1",
	}
	ArtilleryConvoyShort = {
			"ArtilleryConvoyShort 1",
	}
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

zones.bandarabbas:addGroups({
	-- Attack missions
	GroupCommander:new({name='bandar-attack-Qeshm-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Qeshm Island', Altitude = CapAltitude()}),
	GroupCommander:new({name='bandar-attack-khasab-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Khasab', Altitude = CapAltitude()}),
	GroupCommander:new({name='bandar-attack-Qeshm-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Qeshm Island', Altitude = CasAltitude()}),
	GroupCommander:new({name='bandar-attack-factory-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Factory', Altitude = CasAltitude()}),
	GroupCommander:new({name='bandar-attack-khasab-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Khasab', Altitude = CasAltitude()}),
	GroupCommander:new({name='bandar-attack-oil-fields-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Oil Fields'}),
	GroupCommander:new({name='Bandar-attack-radio-tower-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Radio Tower'}),
	GroupCommander:new({name='Bandar-attack-Khasab', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Khasab', Altitude = RunwayStrikeAltitude()}),
	-- Patrol missions
	GroupCommander:new({name='bandar-patrol-Bandar-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='BandarAbbas', Altitude = CapAltitude()}),
	GroupCommander:new({name='bandar-patrol-Qeshm-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Qeshm Island', Altitude = CapAltitude()}),
	GroupCommander:new({name='bandar-patrol-khasab-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Khasab', Altitude = CapAltitude()}),
	GroupCommander:new({name='bandar-patrol-radio-tower', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Radio Tower', Altitude = CapAltitude()}),
	GroupCommander:new({name='bandar-patrol-Delta-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Delta', Altitude = CapAltitude()}),
	-- Supply missions
	GroupCommander:new({name='bandar-supply-Delta', mission='supply', template='HeloSupplyTemplate', targetzone='Delta'}),
	GroupCommander:new({name='bandar-supply-factory', mission='supply', template='HeloSupplyTemplate', targetzone='Factory'}),
	GroupCommander:new({name='bandar-supply-qeshm', mission='supply', template='HeloSupplyTemplate', targetzone='Qeshm Island'}),
	GroupCommander:new({name='bandar-supply-khasab', mission='supply', template='HeloSupplyTemplate', targetzone='Khasab'}),
	GroupCommander:new({name='bandar-supply-oilfields', mission='supply', template='HeloSupplyTemplate', targetzone='Oil Fields'}),
	GroupCommander:new({name='bandar-supply-radio-tower', mission='supply', template='HeloSupplyTemplate', targetzone='Radio Tower'}),
	GroupCommander:new({name='bandar-supply-Dehbarez', mission='supply', template='HeloSupplyTemplate', targetzone='Dehbarez'}),
	-- Surface missions
	GroupCommander:new({name='bandar-attack-Delta', template='AttackConvoy', mission='attack', targetzone='Delta', type='surface'}),
	GroupCommander:new({name='bandar-attack-Oil Fields', template='AttackConvoy', mission='attack', targetzone='Oil Fields', type='surface'}),
	GroupCommander:new({name='bandar-attack-Delta-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Delta', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='bandar-attack-factory-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Factory', type='surface', SetActiveMission = true}),

})

zones.delta:addGroups({
	-- Supply missions
	GroupCommander:new({name='delta-supply-qeshm-island', mission='supply', template='HeloSupplyTemplate', targetzone='Qeshm Island'}),
	GroupCommander:new({name='Delta-supply-Bandar', mission='supply', template='HeloSupplyTemplate', targetzone='BandarAbbas'}),
	GroupCommander:new({name='delta-supply-sunny', mission='supply', template='HeloSupplyTemplate', targetzone='Sunny'}),
	GroupCommander:new({name='delta-supply-echo', mission='supply', template='HeloSupplyTemplate', targetzone='Echo'}),
	GroupCommander:new({name='Delta-supply-Factory', mission='supply', template='HeloSupplyTemplate', targetzone='Factory'}),
	GroupCommander:new({name='Delta-attack-Qeshm Island',template='CasHeloTemplate', mission='attack',MissionType='CAS', targetzone='Qeshm Island'}),

	-- Attack missions
	GroupCommander:new({name='Delta-attack-BandarAbbas-Cas', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='BandarAbbas'}),
	-- Surface missions
	GroupCommander:new({name='Delta-attack-BandarAbbas', mission='attack', template='AttackConvoy', targetzone='BandarAbbas',type='surface'}),
})
zones.paregaan:addGroups({
	-- Supply missions
	GroupCommander:new({name='Paregaan-supply-oil-fields', mission='supply', template='HeloSupplyTemplate', targetzone='Oil Fields'}),
	GroupCommander:new({name='Paregaan-supply-samathe', mission='supply', template='HeloSupplyTemplate', targetzone='Samathe'}),
})

zones.echo:addGroups({
	-- Attack missions
	GroupCommander:new({name='Echo-Attack-Delta-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Delta'}),
	-- Supply missions
	GroupCommander:new({name='Echo-Supply-qeshm-island', mission='supply', template='HeloSupplyTemplate', targetzone='Qeshm Island'}),
	GroupCommander:new({name='Echo-supply-Sunny', mission='supply', template='HeloSupplyTemplate', targetzone='Sunny'}),
	GroupCommander:new({name='Echo-Supply-Delta', mission='supply', template='HeloSupplyTemplate', targetzone='Delta'}),
	GroupCommander:new({name='Echo-Supply-Factory', mission='supply', template='HeloSupplyTemplate', targetzone='Factory'}),
	GroupCommander:new({name='Echo-Supply-golf', mission='supply', template='HeloSupplyTemplate', targetzone='Golf'}),
	-- Surface missions
	GroupCommander:new({name='Echo-attack-delta-art', mission='attack', targetzone='Delta', type='surface'}), -- Me template
	GroupCommander:new({name='Echo-attack-Delta', mission='attack', template='AttackConvoy', targetzone='Delta', type='surface'}),
	GroupCommander:new({name='Echo-attack-Delta-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Delta', type='surface', SetActiveMission = true}),

})

zones.khasab:addGroups({
	-- Attack missions
	GroupCommander:new({name='khasab-attack-alpha-Cas', mission='attack', MissionType='CAS', template='CasHeloTemplate', targetzone='Alpha'}),
	GroupCommander:new({name='khasab-attack-charlie-Cas', mission='attack', MissionType='CAS', template='CasHeloTemplate', targetzone='Charlie'}),
	GroupCommander:new({name='khasab-attack-Khaima-Cap', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Ras Al Khaimah', Altitude = CapAltitude()}),
	GroupCommander:new({name='khasab-attack-Khaima-Sead', mission='attack', MissionType='SEAD', template='SeadPlaneTemplate', targetzone='Ras Al Khaimah', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Khasab-attack-Sharjah-Cap', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Sharjah', Altitude = CapAltitude()}),
	-- Patrol missions
	GroupCommander:new({name='khasab-patrol-khasab-Cap', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Khasab', Altitude = CapAltitude()}),
	GroupCommander:new({name='khasab-Patrol-Convoy-Cap', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Convoy', Altitude = CapAltitude()}),
	GroupCommander:new({name='khasab-Patrol-Alpha-Cap', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Alpha', Altitude = CapAltitude()}),
	GroupCommander:new({name='Khasab-Patrol-Khaimah-Cap', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Ras Al Khaimah', Altitude = CapAltitude()}),
	-- Supply missions
	GroupCommander:new({name='khasab-supply-charlie', mission='supply', template='HeloSupplyTemplate', targetzone='Charlie'}),
	GroupCommander:new({name='khasab-supply-bandar', mission='supply', template='HeloSupplyTemplate', targetzone='BandarAbbas'}),
	GroupCommander:new({name='khasab-supply-alpha', mission='supply', template='HeloSupplyTemplate', targetzone='Alpha'}),
	GroupCommander:new({name='khasab-supply-convoy', mission='supply', template='HeloSupplyTemplate', targetzone='Convoy'}),
	GroupCommander:new({name='khasab-supply-qeshm-island', mission='supply', template='HeloSupplyTemplate', targetzone='Qeshm Island'}),
	GroupCommander:new({name='khasab-supply-Khasab-Defence', mission='supply', template='SupplyConvoy', targetzone='Khasab-Defence', type='surface'}),
})


zones.khaimah:addGroups({
	-- Attack missions
	GroupCommander:new({name='Khaimah-attack-Sharjah-cap', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Sharjah', Altitude = CapAltitude()}),
	GroupCommander:new({name='Khaimah-attack-Sharjah-Cas', mission='attack', MissionType='CAS', template='CasPlaneTemplate', targetzone='Sharjah', Altitude = CasAltitude()}),
	GroupCommander:new({name='Khaimah-attack-Al Huti-Cas', mission='attack', MissionType='CAS', template='CasPlaneTemplate', targetzone='Al Huti', Altitude = CasAltitude()}),
	GroupCommander:new({name='Khaimah-attack-Al Huti-Sead', mission='attack', MissionType='SEAD', template='SeadPlaneTemplate', targetzone='Al Huti', Altitude = SeadAltitude()}),
	-- Patrol missions
	GroupCommander:new({name='Khaimah-Patrol-Sharjah', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Sharjah', Altitude = CapAltitude()}),
	GroupCommander:new({name='Khaimah-Patrol-Al Minhad', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Al Minhad AFB', Altitude = CapAltitude()}),
	-- Supply missions
	GroupCommander:new({name='khaimah-Supply-Alpha', mission='supply', template='HeloSupplyTemplate', targetzone='Alpha'}),
	GroupCommander:new({name='khaimah-Supply-Charlie', mission='supply', template='HeloSupplyTemplate', targetzone='Charlie'}),
	GroupCommander:new({name='Khaimah-supply-Sharja', mission='supply', template='HeloSupplyTemplate', targetzone='Sharjah'}),
	GroupCommander:new({name='Khaimah-supply-fujairah', mission='supply', template='HeloSupplyTemplate', targetzone='Fujairah Intl'}),
	--GroupCommander:new({name='Khaimah-supply-Khasab', mission='supply', template='PlaneSupplyTemplate', targetzone='Khasab'}),
	-- Surface missions
	GroupCommander:new({name='Khaimah-attack-Al Dahid', mission='attack', template='AttackConvoy', targetzone='Al Dahid', type='surface'}),
	GroupCommander:new({name='Khaimah-Supply-BandarAbbas', mission='supply', template='PlaneSupplyTemplate', targetzone='BandarAbbas'}),
	GroupCommander:new({name='Khaimah-Supply-Qeshm', mission='supply', template='PlaneSupplyTemplate', targetzone='Qeshm Island'}),
	GroupCommander:new({name='Khaimah-Supply-Kish Intl', mission='supply', template='PlaneSupplyTemplate', targetzone='Kish intl'}),
})
zones.fujairah:addGroups({
	-- Supply missions
	GroupCommander:new({name='Fujaira-Supply-Dahid', mission='supply', template='HeloSupplyTemplate', targetzone='Al Dahid'}),
	GroupCommander:new({name='Fujaira-Supply-Khaimah', mission='supply', template='HeloSupplyTemplate', targetzone='Ras Al Khaimah'}),
})	
zones.dahid:addGroups({
	-- Attack missions
	GroupCommander:new({name='Dahid-attack-Fujairah', mission='attack',template='AttackConvoy', targetzone='Fujairah Intl', type='surface'}),
	-- Supply missions
	GroupCommander:new({name='Dahid-Supply-Sharjah', mission='supply', template='HeloSupplyTemplate', targetzone='Sharjah'}),
	GroupCommander:new({name='Dahid-Supply-Fujairah', mission='supply', template='HeloSupplyTemplate', targetzone='Fujairah Intl'}),
	GroupCommander:new({name='Dahid-attack-Sharjah-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Sharjah', type='surface', SetActiveMission = true}),


})
zones.factory:addGroups({
	-- Attack missions
	GroupCommander:new({name='factory-attack-sunny', template='CasHeloTemplate', mission='attack',MissionType='CAS', targetzone='Sunny'}),
	-- Supply missions
	GroupCommander:new({name='factory-supply-delta', mission='supply',template='HeloSupplyTemplate', targetzone='Delta'}),
	GroupCommander:new({name='factory-supply-Golf', mission='supply', template='HeloSupplyTemplate', targetzone='Golf'}),
	GroupCommander:new({name='factory-supply-paregaan', mission='supply', template='HeloSupplyTemplate', targetzone='Paregaan'}),
	GroupCommander:new({name='factory-supply-khamets', mission='supply', template='HeloSupplyTemplate', targetzone='Khamets'}),
	GroupCommander:new({name='factory-supply-sunny', mission='supply', template='HeloSupplyTemplate', targetzone='Sunny'}),
	-- Surface missions
	GroupCommander:new({name='factory-supply-BandarAbbas', mission='supply',template='SupplyConvoy', targetzone='BandarAbbas', type='surface'}),
	GroupCommander:new({name='factory-delta-supply', mission='supply', template='SupplyConvoy', targetzone='Delta', type='surface'}),
	GroupCommander:new({name='factory-attack-BandarAbbas-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='BandarAbbas', type='surface', SetActiveMission = true}),

})

zones.golf:addGroups({
	-- Attack missions
	GroupCommander:new({name='Golf-Attack-Echo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Echo'}),
	GroupCommander:new({name='Golf-Attack-Sunny', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Sunny'}),
	GroupCommander:new({name='golf-attack-foxtrot-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Foxtrot'}),
	GroupCommander:new({name='golf-attack-lar-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Lar'}),
	GroupCommander:new({name='golf-attack-Lengeh-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Bandar Lengeh'}),
	-- Supply missions
	GroupCommander:new({name='golf-supply-foxtrot', mission='supply', template='HeloSupplyTemplate', targetzone='Foxtrot'}),
	GroupCommander:new({name='golf-supply-lar', mission='supply', template='HeloSupplyTemplate', targetzone='Lar'}),
	GroupCommander:new({name='golf-supply-bandar-lengeh', mission='supply', template='HeloSupplyTemplate', targetzone='Bandar Lengeh'}),
	GroupCommander:new({name='golf-supply-sunny', mission='supply', template='HeloSupplyTemplate', targetzone='Sunny'}),
	GroupCommander:new({name='golf-supply-echo', mission='supply', template='HeloSupplyTemplate', targetzone='Echo'}),
	-- Surface missions
	GroupCommander:new({name='golf-supply-Foxtrot', mission='supply', template='SupplyConvoy', targetzone='Foxtrot', type = 'surface'}),
})

zones.lar:addGroups({
	-- Attack missions
	GroupCommander:new({name='lar-attack-sam-site-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Qeshm Island', Altitude = SeadAltitude()}),
	GroupCommander:new({name='lar-attack-bandar-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='BandarAbbas', Altitude = CasAltitude()}),
	GroupCommander:new({name='lar-attack-radio-tower-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Radio Tower', Altitude = CasAltitude()}),
	GroupCommander:new({name='lar-attack-factory-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Factory', Altitude = CasAltitude()}),
	GroupCommander:new({name='lar-attack-Ramp-Kongo-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Ramp-Kongo', Altitude = CasAltitude()}),
	GroupCommander:new({name='Lar-attack-Foxtrot-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Foxtrot', Altitude = CapAltitude()}),
	GroupCommander:new({name='Lar-attack-BandarAbbas-Runway-strike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='BandarAbbas', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Lar-attack-Kish-Runway-strike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Kish intl', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Lar-attack-Kish-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Kish intl', Altitude = CasAltitude()}),
	GroupCommander:new({name='Lar-attack-Lavan-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Lavan Island', Altitude = CasAltitude()}),
	GroupCommander:new({name='Lar-attack-Lavan-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Lavan Island', Altitude = CasAltitude()}),
	GroupCommander:new({name='Lar-attack-Lengeh-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Bandar Lengeh', Altitude = CasAltitude()}),
	GroupCommander:new({name='Lar-attack-Qeshm-Runway-strike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Qeshm Island', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Lar-attack-Qeshm-Lavan-strike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Lavan Island', Altitude = RunwayStrikeAltitude()}),
	-- Patrol missions
	GroupCommander:new({name='lar-patrol-golf-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Golf', Altitude = CapAltitude()}),
	GroupCommander:new({name='lar-attack-golf-surface', mission='attack', template='AttackConvoy', targetzone='Golf', type='surface'}),
	GroupCommander:new({name='lar-patrol-delta-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Delta', Altitude = CapAltitude()}),
	GroupCommander:new({name='lar-patrol-factory-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Factory', Altitude = CapAltitude()}),
	GroupCommander:new({name='Shiraz-patrol-Lar-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Lar', Altitude = CapAltitude()}),
	GroupCommander:new({name='Shiraz-patrol-Lar-Cap-2', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Lar', Altitude = CapAltitude()}),
	GroupCommander:new({name='Shiraz-patrol-Lavan-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Lavan Island', Altitude = CapAltitude()}),
	GroupCommander:new({name='Shiraz-patrol-Sunny-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Sunny', Altitude = CapAltitude()}),
	GroupCommander:new({name='Lar-patrol-Foxtrot-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Foxtrot', Altitude = CapAltitude()}),
	GroupCommander:new({name='Lar-patrol-Foxtrot-Cap-2', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Foxtrot', Altitude = CapAltitude()}),
	GroupCommander:new({name='lar-patrol-ramp-kongo-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramp-Kongo', Altitude = CapAltitude()}),
	GroupCommander:new({name='lar-attack-ramp-kongo-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramp-Kongo', Altitude = CapAltitude()}),
	-- Supply missions
	GroupCommander:new({name='lar-supply-golf', mission='supply', template='HeloSupplyTemplate', targetzone='Golf'}),
	GroupCommander:new({name='lar-supply-foxtrot', mission='supply', template='HeloSupplyTemplate', targetzone='Foxtrot'}),
	GroupCommander:new({name='lar-supply-sunny', mission='supply', template='HeloSupplyTemplate', targetzone='Sunny'}),
	GroupCommander:new({name='lar-supply-ramp-kongo', mission='supply', template='HeloSupplyTemplate', targetzone='Ramp-Kongo'}),
	-- Surface missions
	GroupCommander:new({name='Lar-supply-lar-defence', mission='supply', template='AttackConvoy', targetzone='Lar-Defence', type='surface'}),
	GroupCommander:new({name='Lar-attack-Golf-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Golf', type='surface', SetActiveMission = true}),

})

zones.rampkongo:addGroups({
	GroupCommander:new({name='ramp-kongo-supply-khamets', mission='supply',template='HeloSupplyTemplate', targetzone='Khamets'}),
})
zones.foxtrot:addGroups({
	-- Supply missions
	GroupCommander:new({name='Foxtrot-supply-kishi', mission='supply',template='HeloSupplyTemplate', targetzone='Kish intl'}),
	GroupCommander:new({name='Foxtrot-supply-Lar', mission='supply',template='HeloSupplyTemplate', targetzone='Lar'}),
	GroupCommander:new({name='Foxtrot-supply-lavan', mission='supply',template='HeloSupplyTemplate', targetzone='Lavan Island', spawnDelayFactor = 2}),
	-- Surface missions
	GroupCommander:new({name='foxtrot-attack-golf', mission='attack',template='AttackConvoy', targetzone='Golf', type='surface'}),
	GroupCommander:new({name='foxtrot-attack-Kish intl-cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Kish intl'}),
	GroupCommander:new({name='foxtrot-artillery-fire-at-golf', mission='attack', targetzone='Golf', type='surface'}),
})
zones.oilfields:addGroups({
	-- Supply missions
	GroupCommander:new({name='oilfields-supply-dehbarez', mission='supply',template='HeloSupplyTemplate', targetzone='Dehbarez'}),
	GroupCommander:new({name='oilfields-Supply-paragaan', mission='supply',template='HeloSupplyTemplate', targetzone='Paregaan'}),
	-- Surface missions
	GroupCommander:new({name='oilfields-supply-bandar', mission='supply',template='SupplyConvoy', targetzone='BandarAbbas', type='surface', spawnDelayFactor = 3}),
})
zones.qeshmisland:addGroups({
	-- Attack missions
	GroupCommander:new({name='qeshm-island-attack-Khasab-Cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Khasab', Altitude = CasAltitude()}),
	GroupCommander:new({name='qeshm-island-attack-Khaima-Cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Ras Al Khaimah', Altitude = CasAltitude()}),
	GroupCommander:new({name='qeshm-island-attack-Khaima-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Ras Al Khaimah', Altitude = CapAltitude()}),
	-- Patrol missions
	GroupCommander:new({name='qeshm-island-Patrol-Khasab-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Khasab', Altitude = CapAltitude()}),
	GroupCommander:new({name='qeshm-island-Supply-Khasab', mission='supply',template='HeloSupplyTemplate', targetzone='Khasab'}),
	-- Supply missions
	GroupCommander:new({name='qeshm-island-Supply-Bandar-Lengeh', mission='supply',template='HeloSupplyTemplate', targetzone='Bandar Lengeh'}),
	--GroupCommander:new({name='qeshm-island-Supply-Moradi', mission='supply',template='HeloSupplyTemplate', targetzone='Moradi'}),
	-- Surface missions
	GroupCommander:new({name='qeshm-island-supply-Moradi-Convoy', mission='supply', targetzone='Moradi',template='SupplyConvoy', type='surface', spawnDelayFactor = 3}),
	GroupCommander:new({name='qeshm-island-supply-qeshm-island-defence', mission='supply', targetzone='Qeshm-Island-Defence', type='surface'}),
})

zones.khamets:addGroups({
	GroupCommander:new({name='Khamets-supply-samathe', mission='supply',template='HeloSupplyTemplate', targetzone='Samathe'}),
	GroupCommander:new({name='Khamets-supply-Factory', mission='supply',template='HeloSupplyTemplate', targetzone='Factory'}),
	GroupCommander:new({name='Khamets-supply-Paregaan', mission='supply',template='HeloSupplyTemplate', targetzone='Paregaan'})
})
zones.samathe:addGroups({
	-- Attack missions
	GroupCommander:new({name='HiddenGroup-attack-Lar', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Lar', Altitude = CapAltitude(), Redcondition = function() return end}),
	GroupCommander:new({name='HiddenGroup-attack-Ramp-Kongo', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramp-Kongo', Altitude = CapAltitude(), Redcondition = function() return end}),
	GroupCommander:new({name='HiddenGroup-attack-Samathe', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Samathe', Altitude = CapAltitude(), Redcondition = function() return end}),
	GroupCommander:new({name='Samathe-attack-Paregaan', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Paregaan', Altitude = CapAltitude(), Redcondition = function() return end}),
	-- Patrol missions
	GroupCommander:new({name='HiddenGroup-patrol-Ramp-Kongo', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramp-Kongo', Altitude = CapAltitude(), Redcondition = function() return zones.lar.wasBlue end}),
	GroupCommander:new({name='Samathe-patrol-Samathe', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Samathe', Altitude = CapAltitude()}),
	GroupCommander:new({name='Samathe-patrol-OilFields', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Oil Fields', Altitude = CapAltitude()}),
	-- Supply missions
	GroupCommander:new({name='Samathe-supply-Paegaan', mission='supply', template='HeloSupplyTemplate', targetzone='Paregaan'}),
	-- Surface missions
	GroupCommander:new({name='Samathe-attack-Paegaan', mission='attack', template='AttackConvoy', targetzone='Khamets', type='surface'}),
	GroupCommander:new({name='Samathe-attack-Khamets-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Khamets', type='surface', SetActiveMission = true}),

})


zones.sunny:addGroups({
	-- Supply missions
	GroupCommander:new({name='Sunny-Supply-Lar', mission='supply',template='HeloSupplyTemplate', targetzone='Lar'}),
	GroupCommander:new({name='Sunny-Supply-Golf', mission='supply', template='HeloSupplyTemplate', targetzone='Golf'}),
	GroupCommander:new({name='Sunny-Supply-Factory', mission='supply', template='HeloSupplyTemplate', targetzone='Factory'}),
	GroupCommander:new({name='Sunny-Supply-kongo', mission='supply', template='HeloSupplyTemplate', targetzone='Ramp-Kongo'}),
	-- Surface missions
	GroupCommander:new({name='Sunny-attack-Echo', mission='attack', template='AttackConvoy', targetzone='Echo', type='surface'}),
})

zones.bandarlengeh:addGroups({
	-- Patrol missions
	GroupCommander:new({name='lengeh-patrol-qeshm-island', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Qeshm Island', Altitude = CapAltitude()}),
	GroupCommander:new({name='lengeh-patrol-Musa-island', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abu Musa Island', Altitude = CapAltitude()}),
	GroupCommander:new({name='lengeh-attack-Musa-island', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abu Musa Island', Altitude = CapAltitude()}),
	-- Supply missions
	GroupCommander:new({name='lengeh-supply-kish', mission='supply', template='HeloSupplyTemplate', targetzone='Kish intl'}),
	-- Surface missions
	GroupCommander:new({name='lengeh-supply-tunb-sea', mission='supply', targetzone='Tunb Island AFB', type='surface', condition = function() return not CustomFlags["StrikePort"] end}),
	GroupCommander:new({name='lengeh-supply-Musa-Sea', mission='supply', targetzone='Abu Musa Island', type='surface', condition = function() return not CustomFlags["StrikePort"] end}),
	GroupCommander:new({name='lengeh-supply-Sirri-sea', mission='supply', targetzone='Sirri Island', type='surface', condition = function() return not CustomFlags["StrikePort"] end}),
	GroupCommander:new({name='lengeh-supply-Tunb Island', mission='supply', template='HeloSupplyTemplate', targetzone='Tunb Island AFB', Bluecondition = function() return true end}),
	GroupCommander:new({name='lengeh-supply-Abu Musa', mission='supply', template='HeloSupplyTemplate', targetzone='Abu Musa Island', Bluecondition = function() return true end}),
	GroupCommander:new({name='lengeh-supply-Sirri', mission='supply', template='HeloSupplyTemplate', targetzone='Sirri Island', Bluecondition = function() return true end}),
})

zones.aldhafra:addGroups({
	-- Supply missions
	GroupCommander:new({name='al-dhafra-support-huti', mission='supply', template='HeloSupplyTemplate', targetzone='Al Huti'}),
	GroupCommander:new({name='al-dhafra-patrol-al-huti', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Huti', Altitude = CapAltitude()}),
	GroupCommander:new({name='al-dhafra-patrol-al-minhad', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Minhad AFB', Altitude = CapAltitude()}),
	GroupCommander:new({name='al-dhafra-attack-al-minhad', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Minhad AFB', Altitude = CapAltitude()}),
	GroupCommander:new({name='al-dhafra-patrol-al-Ain', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Ain', Altitude = CapAltitude()}),
	GroupCommander:new({name='al-dhafra-attack-al-Ain', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Ain', Altitude = CapAltitude()}),
	GroupCommander:new({name='al-dhafra-support-al-khatim', mission='supply', template='HeloSupplyTemplate', targetzone='Al Khatim'}),
	GroupCommander:new({name='al-dhafra-support-Sharjah', mission='supply', template='PlaneSupplyTemplate', targetzone='Sharjah'}),
	GroupCommander:new({name='al-dhafra-patrol-Sharjah', mission='supply', template='PlaneSupplyTemplate', targetzone='Sharjah'}),
	GroupCommander:new({name='al-dhafra-support-Al Dhafra-Defence', mission='supply', template='SupplyConvoy', targetzone='Al Dhafra-Defence', type='surface'}),

})

zones.alhuti:addGroups({
	-- Supply missions
	GroupCommander:new({name='Huti-supply-Minhad', mission='supply', template='HeloSupplyTemplate', targetzone='Al Minhad AFB'}),
	GroupCommander:new({name='Huti-supply-ain', mission='supply', template='HeloSupplyTemplate', targetzone='Al Ain'}),
})

zones.charlie:addGroups({
	-- Supply missions
	GroupCommander:new({name='Charlie-attack-Khaimah', mission='attack', template='AttackConvoy', targetzone='Ras Al Khaimah', type='surface'}),
	GroupCommander:new({name='Huti-supply-ain', mission='supply', template='HeloSupplyTemplate', targetzone='Al Ain'}),
	GroupCommander:new({name='Khaimah-supply-Khasab', mission='supply', template='HeloSupplyTemplate', targetzone='Khasab'})
})

zones.alain:addGroups({
	-- Attack missions
	GroupCommander:new({name='Al-Ain-Attack-Al-Dhafra', mission='attack', template='AttackConvoy', targetzone='Al Dhafra', type='surface', spawnDelayFactor = 3, diceChance = 30}),
	-- Supply missions
	GroupCommander:new({name='Al-Ain-Supply-Al-Huti', mission='supply', template='HeloSupplyTemplate', targetzone='Al Huti'}),
	GroupCommander:new({name='Al-Ain-Supply-Al-Khatim', mission='supply', template='HeloSupplyTemplate', targetzone='Al Khatim'}),
	GroupCommander:new({name='Al-Ain-patrol-al-huti', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Huti', Altitude = CapAltitude()}),
	GroupCommander:new({name='Al-Ain-patrol-al-minhad', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Minhad AFB', Altitude = CapAltitude()}),
	GroupCommander:new({name='Al-Ain-attack-al-minhad', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Minhad AFB', Altitude = CapAltitude()}),
	GroupCommander:new({name='Al-Ain-patrol-al-Ain', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Ain', Altitude = CapAltitude()}),
	GroupCommander:new({name='Al-Ain-attack-al-Dhafra', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Dhafra', Altitude = CapAltitude()}),
	GroupCommander:new({name='Al-Ain-patrol-Fujairah Intl', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Fujairah Intl', Altitude = CapAltitude()}),

})

zones.moradi:addGroups({
	-- Attack missions
	GroupCommander:new({name='Moradi-attack-Qeshm', mission='attack', template='AttackConvoy', targetzone='Qeshm Island',type='surface'}),
	-- Patrol missions
	GroupCommander:new({name='Moradi-patrol-tunb-island', mission='patrol', targetzone='Abu Musa Island', spawnDelayFactor = 3}),
})

zones.kish:addGroups({
	-- Attack missions
	GroupCommander:new({name='Kishi-attack-Abu-Musa', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Abu Musa Island', Altitude = CapAltitude()}),
	GroupCommander:new({name='Kishi-attack-qeshm-island-Sead', mission='attack',template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Qeshm Island', Altitude = SeadAltitude()}),
	-- Patrol missions
	GroupCommander:new({name='Kishi-patrol-kishi', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Foxtrot', Altitude = CapAltitude()}),
	GroupCommander:new({name='Kishi-patrol-Abu-Musa', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abu Musa Island', Altitude = CapAltitude()}),
	GroupCommander:new({name='Kishi-patrol-bandarlengeh', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bandar Lengeh', Altitude = CapAltitude()}),
	-- Supply missions
	GroupCommander:new({name='Kish-supply-Foxtrot', mission='supply', template='HeloSupplyTemplate', targetzone='Foxtrot'}),
	GroupCommander:new({name='Kish-supply-Lavan', mission='supply', template='HeloSupplyTemplate', targetzone='Lavan Island'}),
})


zones.minhad:addGroups({
	GroupCommander:new({name='Minhad-supply-sharjah', mission='supply', template='HeloSupplyTemplate', targetzone='Sharjah'}),
	GroupCommander:new({name='Minhad-supply-Fujairan', mission='supply', template='HeloSupplyTemplate', targetzone='Fujairah Intl'}),
	GroupCommander:new({name='Minhad-supply-Al Huti', mission='supply', template='HeloSupplyTemplate', targetzone='Al Huti'}),
	GroupCommander:new({name='Minhad-attack-Al Huti', mission='attack', template='AttackConvoy', targetzone='Al Huti', type='surface'}),
	GroupCommander:new({name='Minhad-patrol-Minhad', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Al Minhad AFB', Altitude = CapAltitude()}),
	GroupCommander:new({name='Minhad-attack-Sharjah-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Sharjah', type='surface', SetActiveMission = true}),

})

zones.sharjah:addGroups({
	-- Attack missions
	GroupCommander:new({name='Sharjah-attack-Al Dahid', mission='attack', template='AttackConvoy', targetzone='Al Dahid', type='surface'}),
	GroupCommander:new({name='Sharjah-attack-Al Minhad AFB', mission='attack', template='AttackConvoy', targetzone='Al Minhad AFB', type='surface'}),
	GroupCommander:new({name='Sharjah-attack-Al Minhad AFB-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Minhad AFB', Altitude = CapAltitude()}),
	-- Patrol missions
	GroupCommander:new({name='Sharjah-patrol-al-minhad', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Al Minhad AFB', Altitude = CapAltitude()}),
	-- Supply missions
	GroupCommander:new({name='Sharjah-Supply-Khaimah', mission='supply', template='HeloSupplyTemplate', targetzone='Ras Al Khaimah'}),
	GroupCommander:new({name='Sharjah-Supply-abu-musa', mission='supply', template='HeloSupplyTemplate', targetzone='Abu Musa Island'}),
	GroupCommander:new({name='Sharjah-Supply-dahid', mission='supply', template='HeloSupplyTemplate', targetzone='Al Dahid'}),
	--GroupCommander:new({name='Sharjah-supply-Minhad', mission='supply', template='HeloSupplyTemplate', targetzone='Al Minhad AFB'}),

	GroupCommander:new({name='Sharjah-supply-Minhad', mission='supply', template='PlaneSupplyTemplate', targetzone='Al Minhad AFB'}),
	-- Surface missions
	GroupCommander:new({name='Sharjah-supply-sharjah-Defence', mission='supply', targetzone='Sharjah-Defence', type='surface'}),
	GroupCommander:new({name='Sharjah-attack-Ras Al Khaimah-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Ras Al Khaimah', type='surface', SetActiveMission = true}),

})

zones.abumusa:addGroups({
	-- Supply missions
	GroupCommander:new({name='abu-musa-supply-tumb-island', mission='supply', template='HeloSupplyTemplate', targetzone='Tunb Island AFB', BlueCondition = function() return end}),
	GroupCommander:new({name='abu-musa-supply-sirri-island', mission='supply',template='HeloSupplyTemplate', targetzone='Sirri Island', BlueCondition = function() return end}),
	GroupCommander:new({name='abu-musa-supply-Sharjah', mission='supply',template='HeloSupplyTemplate', targetzone='Sharjah'}),
})

zones.tunbisland:addGroups({
	-- Supply missions
	GroupCommander:new({name='Tunb-Island-supply-moradi',template='HeloSupplyTemplate', mission='supply', targetzone='Moradi'})
})

zones.hidden4:addGroups({

})

function SpawnFriendlyAssets()

	if zones.redcarrier.side == 2 and not IsGroupActive('CVN-73') then
		activateGroupIfNotActive('CVN-73')
		activateGroupIfNotActive('CVN-59')
		activateGroupIfNotActive('Khasab Tarawa')
		destroyGroupIfActive('CVN-72')
		destroyGroupIfActive('CVN-74')
		timer.scheduleFunction(function()
			checkWeaponsList('CVN-73')
			checkWeaponsList('Khasab Tarawa')
			checkWeaponsList('CVN-59')
		end, {}, timer.getTime() + 5)
	end

	if not CustomFlags['StartNormalFalse'] and (zones.lavan.side == 1 or zones.kish.side == 1 or zones.bandarabbas.side == 1 or zones.sirri.side == 1
		or zones.abumusa.side == 1 or zones.tunbisland.side == 1 or zones.qeshmisland.side == 1 or zones.moradi.side == 1) 
	and zones.redcarrier.side == 0 and not MessageSent then
		MessageSent = true
		trigger.action.outText(L10N:Get("PG_SETUP_NAVY_BLOCKING"), 30)
		trigger.action.outSoundForCoalition(2, "admin.ogg")
	end
	

	if zones.khasab.side == 2 then
		activateGroupIfNotActive('Blue Silkworm')
		--destroyGroupIfActive('Tarawa')
	end
	for _, airbName in ipairs{
		{ zone = zones.bandarlengeh, name = "Bandar Lengeh FARP" },
		{ zone = zones.tunbisland,   name = "Tunb island FARP" },
	} do
		local ab = Airbase.getByName(airbName.name)
		if ab then
			if ab:autoCaptureIsOn() then ab:autoCapture(false) end
			local side = airbName.zone.wasBlue and 2 or 1
			if ab:getCoalition() ~= side then
				ab:setCoalition(side)
				checkWeaponsList(airbName.name)
			end
		end
	end
	
	if zones.redcarrier.wasBlue then
		trigger.action.setMarkupTypeLine(zones.carrier.index, 0)
	end

	if not zones.insurgencygridcn76.isAwaken and zones.minhad.side == 2 and not insurgencycn76campStarted then
		insurgencycn76campStarted = true
		timer.scheduleFunction(function()
		zones.insurgencygridcn76:AwakenZoneAndUpgrade()
		trigger.action.outTextForCoalition(2, L10N:Get("PG_SETUP_INSURGENTS_CN76_INTEL"), 30)
		trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
		bc:addConnection("Al Minhad AFB", "Insurgency Grid CN76")
		bc:buildConnectionMap()
		bc:RefreshConnectionsLines("Al Minhad AFB")
		end, {}, timer.getTime() + math.random(5,30))
	end

	if not zones.insurgencygridcq37.isAwaken and zones.moradi.side == 2 and not insurgencycq37campStarted then
		insurgencycq37campStarted = true
		timer.scheduleFunction(function()
		zones.insurgencygridcq37:AwakenZoneAndUpgrade()
		trigger.action.outTextForCoalition(2, L10N:Get("PG_SETUP_INSURGENTS_CQ37_INTEL"), 30)
		trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
		bc:addConnection("Moradi", "Insurgency Grid CQ37")
		bc:buildConnectionMap()
		bc:RefreshConnectionsLines("Moradi")
		end, {}, timer.getTime() + math.random(5,30))
	end
	if not zones.scudcity.isAwaken and zones.khaimah.side == 2 and not scudcityStarted then
		scudcityStarted = true
		timer.scheduleFunction(function()
		zones.scudcity:AwakenZoneAndUpgrade()
		trigger.action.outTextForCoalition(2, L10N:Get("PG_SETUP_SCUD_CITY_INTEL"), 30)
		trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
		bc:addConnection("Ras Al Khaimah", "Scud City")
		bc:buildConnectionMap()
		bc:RefreshConnectionsLines("Ras Al Khaimah")
		end, {}, timer.getTime() + math.random(5,30))
	end
end
timer.scheduleFunction(SpawnFriendlyAssets,{},timer.getTime()+10)

function checkAndDisableFriendlyZones()
	if not StartNormal and zones.alhuti.side == 2 then
		zones.hidden:MakeZoneRedAndUpgrade()
	end
	if not CustomFlags['StartNormalFalse'] and zones.alkhatim.wasBlue and zones.alain.wasBlue and zones.alhuti.wasBlue
		and zones.hidden.side == 1 then
		zones.hidden:DestroyHiddenZone()
	end

	if not CustomFlags['StartNormalFalse'] and zones.khasab.wasBlue and (zones.qeshmisland.wasBlue or zones.bandarabbas.wasBlue) and zones.hidden2.side == 1 then
		zones.hidden2:DestroyHiddenZone()
		zones.hidden4:MakeZoneRedAndUpgrade()
	end
	if CustomFlags['StartNormalFalse'] == true and (zones.qeshmisland.wasBlue or zones.bandarabbas.wasBlue) and zones.khasab.wasBlue and zones.hidden4.side == 1 then
		zones.hidden4:DestroyHiddenZone()
		zones.hidden2:MakeZoneRedAndUpgrade()
	end
end
timer.scheduleFunction(checkAndDisableFriendlyZones,{},timer.getTime()+5)

zones.sharjah.isHeloSpawn = true
zones.bandarlengeh.isHeloSpawn = true
zones.kish.isHeloSpawn = true
zones.khaimah.isHeloSpawn = true
zones.minhad.isHeloSpawn = true
zones.fujairah.isHeloSpawn = true
zones.alain.isHeloSpawn = true
zones.bandarabbas.isHeloSpawn = true
zones.khasab.isHeloSpawn = true
zones.echo.isHeloSpawn = true
zones.foxtrot.isHeloSpawn = true
zones.sunny.isHeloSpawn = true
zones.dahid.isHeloSpawn = true
zones.radio.isHeloSpawn = true
zones.alhuti.isHeloSpawn = true
zones.alkhatim.isHeloSpawn = true
zones.qeshmisland.isHeloSpawn = true
zones.factory.isHeloSpawn = true
zones.aldhafra.isHeloSpawn = true
zones.delta.isHeloSpawn = true
zones.golf.isHeloSpawn = true
zones.rampkongo.isHeloSpawn = true
zones.khamets.isHeloSpawn = true
zones.samathe.isHeloSpawn = true
zones.paregaan.isHeloSpawn = true
zones.carrier.isHeloSpawn = true
zones.abumusa.isHeloSpawn = true
zones.sirri.isHeloSpawn = true
zones.tunbisland.isHeloSpawn = true
zones.lavan.isHeloSpawn = true
zones.moradi.isHeloSpawn = true
zones.redcarrier.isHeloSpawn = true
zones.charlie.isHeloSpawn = true
zones.alpha.isHeloSpawn = true
zones.lar.isHeloSpawn = true




zones.sharjah.airbaseName = "Sharjah Intl"
zones.bandarlengeh.airbaseName = "Bandar Lengeh"
zones.kish.airbaseName = "Kish Intl"
zones.khaimah.airbaseName = "Ras Al Khaimah Intl"
zones.minhad.airbaseName = "Al Minhad AFB"
zones.fujairah.airbaseName = "Fujairah Intl"
zones.alain.airbaseName = "Al Ain Intl"
zones.bandarabbas.airbaseName = "Bandar Abbas Intl"
zones.khasab.airbaseName = "Khasab"
zones.echo.airbaseName = "FARP Echo"
zones.foxtrot.airbaseName = "Foxtrot"
zones.sunny.airbaseName = "FARP Sunny"
zones.dahid.airbaseName = "Al Dahid"
zones.radio.airbaseName = "Radio Tower"
zones.alhuti.airbaseName = "Al Huti"
zones.alkhatim.airbaseName = "Al Khatim"
zones.qeshmisland.airbaseName = "Qeshm Island"
zones.factory.airbaseName = "Factory"
zones.aldhafra.airbaseName = "Al Dhafra AFB"
zones.delta.airbaseName = "FARP Delta"
zones.golf.airbaseName = "FARP Golf"
zones.rampkongo.airbaseName = "Ramp-Kongo"
zones.khamets.airbaseName = "FARP Khamets"
zones.samathe.airbaseName = "Samathe"
zones.paregaan.airbaseName = "Paregaan"
zones.lavan.airbaseName = "Lavan Island"
zones.tunbisland.airbaseName = "Tunb Island AFB"
zones.abumusa.airbaseName = "Abu Musa Island"
zones.sirri.airbaseName = "Sirri Island"
zones.moradi.airbaseName = "Moradi"
zones.charlie.airbaseName = "Charlie"
zones.alpha.airbaseName = "Alpha"
zones.lar.airbaseName = "Lar"
zones.redcarrier.airbaseName = "CVN-73"
zones.carrier.airbaseName = "CVN-72"



AirbaseBelonging = {}
AirbaseBelonging["Lar"]     = AirbaseBelonging["Lar"]     or {"Shiraz Intl"}
AirbaseBelonging["Samathe"] = AirbaseBelonging["Samathe"] or {"Jiroft","Kerman"}
AirbaseBelonging["Bandar Lengeh"] = AirbaseBelonging["Bandar Lengeh"] or {"Kish Intl","Qeshm Island"}

for i,v in pairs(zones) do
	bc:addZone(v)
end

bc:addConnection("Al Dhafra","Al Huti")
bc:addConnection("Al Dhafra","Al Khatim")
bc:addConnection("Al Khatim","Al Ain")
bc:addConnection("Al Huti","Al Ain",false,true)
bc:addConnection("Al Huti","Al Minhad AFB")
bc:addConnection("Fujairah Intl","Al Minhad AFB")
bc:addConnection("Al Minhad AFB","Sharjah")
bc:addConnection("Al Dahid","Sharjah")
bc:addConnection("Al Dahid","Fujairah Intl")
bc:addConnection("Fujairah Intl","Ras Al Khaimah")
bc:addConnection("Ras Al Khaimah","Charlie")
bc:addConnection("Ras Al Khaimah","Alpha")
bc:addConnection("Alpha","Khasab")
bc:addConnection("Khasab","Khasab-Defence",true)
bc:addConnection("Charlie","Khasab")
bc:addConnection("Charlie","Convoy")
bc:addConnection("Convoy","Khasab")
bc:addConnection("Lavan Island","Red Carrier")
bc:addConnection("Khasab","Tunb Island AFB")
bc:addConnection("Sharjah","Ras Al Khaimah")
bc:addConnection("Sharjah","Sharjah-Defence",true)
bc:addConnection("Sharjah","Abu Musa Island")
bc:addConnection("Abu Musa Island","Sirri Island")
bc:addConnection("Abu Musa Island","Tunb Island AFB")
bc:addConnection("Tunb Island AFB","Tunb Defence",true)
bc:addConnection("BandarAbbas","Oil Fields",nil,true)
bc:addConnection("BandarAbbas","Radio Tower",nil,true)
bc:addConnection("BandarAbbas","Dehbarez",nil,true)
bc:addConnection("Dehbarez","Oil Fields")
bc:addConnection("Paregaan","Factory")
bc:addConnection("Oil Fields","Paregaan")
bc:addConnection("Factory","Khamets")
bc:addConnection("Bandar Lengeh","Golf")
bc:addConnection("BandarAbbas","Factory")
bc:addConnection("BandarAbbas","Delta")
bc:addConnection("Samathe","Khamets")
bc:addConnection("Paregaan","Samathe")
bc:addConnection("Delta","Factory")
bc:addConnection("Delta","Echo")
bc:addConnection("Echo","Golf")
bc:addConnection("Foxtrot","Lar")
bc:addConnection("Golf","Lar")
bc:addConnection("Delta","Qeshm Island")
bc:addConnection("Qeshm Island","Echo")
bc:addConnection("Qeshm-Island-Defence","Qeshm Island",true)
bc:addConnection("Moradi","Qeshm Island")
bc:addConnection("Moradi","Bandar Lengeh")
bc:addConnection("Sirri Island","Bandar Lengeh")
bc:addConnection("Abu Musa Island","Bandar Lengeh")
bc:addConnection("Tunb Island AFB","Bandar Lengeh")
bc:addConnection("BandarAbbas","Qeshm-Island-Defence",true)
bc:addConnection("Bandar Lengeh","Kish intl")
bc:addConnection("Kish intl","Foxtrot")
bc:addConnection("Kish intl","Lavan Island")
bc:addConnection("Lavan Island","Foxtrot")
bc:addConnection("Golf","Foxtrot")
bc:addConnection("Golf","Sunny")
bc:addConnection("Khamets","Sunny")
bc:addConnection("Factory","Sunny")
bc:addConnection("Sunny","Lar")
bc:addConnection("Lar","Lar-Defence",true)
bc:addConnection("Echo","Sunny")
bc:addConnection("Sunny","Ramp-Kongo")
bc:addConnection("Ramp-Kongo","Lar")
bc:addConnection("Khamets","Ramp-Kongo")
bc:addConnection("Dehbarez","SecretTechFacility",nil,true)
bc:addConnection("Radio Tower","TankFactory",nil,true)
bc:addConnection("Ras Al Khaimah","ChemSite",nil,true)
bc:addConnection("Al Ain","Fuel Depo",false,true)
bc:addConnection("Fujairah Intl","Fuel Depo",false,true)
bc:addConnection("InsurgentCamp","Ras Al Khaimah")
bc:addConnection("Al Dahid","InsurgentCamp")
bc:addHiddenConnection("Al Minhad AFB","Al Ain")
bc:addHiddenConnection("Lar","Lavan Island")
bc:addHiddenConnection("Lar","Kish intl")
bc:addHiddenConnection("Lar","Qeshm Island")
bc:addHiddenConnection("BandarAbbas","Lar")
bc:addHiddenConnection("Khasab","BandarAbbas")

--zones.radio:addCriticalObject('CommandCenter1')
--zones.qeshmisland:addCriticalObject('CommandCenter2')
--zones.factory:addCriticalObject('FactoryBuilding1')
--zones.factory:addCriticalObject('FactoryBuilding2')
--zones.tankfactory:addCriticalObject('Factory2')
--zones.tankfactory:addCriticalObject('Factorybuildning')

zones.convoy:addCriticalObject('convoy1')
zones.convoy:addCriticalObject('convoy2')
zones.convoy:addCriticalObject('convoy3')
zones.convoy:addCriticalObject('convoy4')

zones.khasabdefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("PG_SETUP_ZONE_DESTROYED_500", "Khasab Defence"),20)
end, 'disablekhasabdefence')
zones.dhafradefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("PG_SETUP_ZONE_DESTROYED_500", "Dhafra Defence"),20)
end, 'disabledhafradefence')
zones.qeshmislanddefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("PG_SETUP_ZONE_DESTROYED_500", "Qeshm island Defence"),20)
end, 'disableqeshmislanddefence')

zones.tunbdefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("PG_SETUP_ZONE_DESTROYED_500", "Tunb Defence"),20)
end, 'disabletunbdefence')

zones.sharjadefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("PG_SETUP_ZONE_DESTROYED_500", "Sharjah Defence"),20)
end, 'disablesharjadefence')

zones.lardefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("PG_SETUP_ZONE_DESTROYED_500", "Lar Defence"),20)
end, 'disablelardefence')


zones.insurgentcamp:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("PG_SETUP_ZONE_DESTROYED_500", "Insurgent camp"),20)
end, 'disableinsurgentcamp')

zones.chemsite:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("PG_SETUP_ZONE_DESTROYED_500", "chemsite"),20)
end, 'disablechemsite')

zones.fueldepo:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("PG_SETUP_ZONE_DESTROYED_500", "Fueldepo"),20)
end, 'disablefueldepo')

zones.secrettechfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("CA_SETUP_SECRET_TECH_FACILITY_DESTROYED"),20)
end, 'disablesecrettechfacility')

zones.tankfactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("CA_SETUP_TANK_FACTORY_DESTROYED"),20)
end, 'disabletankfactory')
zones.insurgencygridcn76:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_INSURGENCY_GRID_DESTROYED", "CN76"),20)
end, 'disableinsurgencygridcn76')
zones.insurgencygridcq37:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_INSURGENCY_GRID_DESTROYED", "CQ37"),20)
end, 'disableinsurgencygridcq37')
zones.scudcity:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("PG_SETUP_SCUDS_DESTROYED"),20)
end, 'disablescudcity')

Group.getByName('qeshm-arty-Attack-Group'):destroy()
zones.qeshmisland:registerTrigger('captured', function(event,sender)
	local kr = bc:getZoneByName('Qeshm Island')
	if kr.side == 2 and not CustomFlags['qeshmcaptured'] then
		if not IsGroupActive('Qeshm-arty-Attack-Group') then
			Respawn.Group('Qeshm-arty-Attack-Group')
            CustomFlags['qeshmcaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, L10N:Get("PG_EVENT_QESHM_ARTY_ATTACK"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 180)
		end
	
    timer.scheduleFunction(function()
    trigger.action.outTextForCoalition(2, L10N:Get("PG_EVENT_QESHM_ARTY_INTEL"), 30)
    end, {}, timer.getTime() + math.random(360, 480))
end
end, 'qeshmislandcaptured')

Group.getByName('Khasab-Forces-attack'):destroy()
Group.getByName('Khasab-Forces-attack-2'):destroy()
zones.khasab:registerTrigger('captured', function(event,sender)
	local kr = bc:getZoneByName('Khasab')
	if kr.side == 2 and not CustomFlags['khasabcaptured'] then
		if not IsGroupActive('Khasab-Forces-attack') then
			Respawn.Group('Khasab-Forces-attack')
			Respawn.Group('Khasab-Forces-attack-2')
            CustomFlags['khasabcaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, L10N:Get("PG_EVENT_KHASAB_SCUDS"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 150)
		end
	end
end, 'khasabcaptured')

missions = {
    ["Ras Al Khaimah"] = {	
        zone = "Ras Al Khaimah",
        missionGroup = "KhaimahEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Khaimah"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Khaimah"),
        TargetZone = "Charlie",
		radius = 2500,
        MissionType = "Escort",
		flag = 101,
		ActivateZone = "hiddenkhaimahmission"
    },
    ["Al Minhad AFB"] = {	
        zone = "Al Minhad AFB",
        missionGroup = "MinhadEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Minhad"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Minhad"),
        TargetZone = "Sharjah",
        radius = 2500,
        MissionType = "Escort",
		flag = 111,
		ActivateZone = "hiddenminhadmission"
    },
	
    Sharjah = {	
        zone = "Sharjah",
        missionGroup = "SharjahEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Sharjah"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Sharjah"),
        TargetZone = "Al Dahid",
        radius = 2500,
        MissionType = "Escort",
		order = 1,
		flag = 121,
		ActivateZone = "hiddensharjahmission"
    },
    ["Qeshm Island"] = {	
        zone = "Qeshm Island",
        missionGroup = "QeshmIslandEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Qeshm Island"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Qeshm Island"),
        TargetZone = "Moradi",
        radius = 2500,
        MissionType = "Escort",
		flag = 131,
		ActivateZone = "hiddenmoradiqeshmmission"
    },
    ["Moradi"] = {	
        zone = "Moradi",
        missionGroup = "MoradiEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Moradi"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Moradi"),
        TargetZone = "Qeshm Island",
        radius = 2500,
        MissionType = "Escort",
		flag = 141,
		ActivateZone = "hiddenmoradiqeshmmission"
    },
    ["Charlie"] = {	
        zone = "Charlie",
        missionGroup = "CharlieEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Charlie"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Charlie"),
        TargetZone = "Ras Al Khaimah",
		radius = 2500,
        MissionType = "Escort",
		flag = 151,
		ActivateZone = "hiddenkhaimahmission"
    },
    Sharjah2 = {	
        zone = "Sharjah",
        missionGroup = "SharjahEscortGroupMinhad",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Sharjah"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Sharjah"),
        TargetZone = "Al Minhad AFB",
        radius = 2500,
        MissionType = "Escort",
		order = 2,
		flag = 121,
		ActivateZone = "hiddenminhadmission"
    },
}

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
		trigger.action.outText(L10N:Get("SYRIA_SETUP_MISSION_COMPLETE_MENU"), 120)

		timer.scheduleFunction(function()
			trigger.action.outSoundForCoalition(2, "BH.ogg")
		end, {}, timer.getTime() + 5)

			local subMenu = missionCommands.addSubMenuForCoalition(2, L10N:Get("SYRIA_SETUP_RESTART_MENU"), nil)
			missionCommands.addCommandForCoalition(2, L10N:Get("COMMON_YES"), subMenu, function()
					Utils.saveTable(bc.saveFile, 'zonePersistance', {})
					if resetSaveFileAndFarp then
					resetSaveFileAndFarp()
					end
					if WarehouseLogistics == true and WarehousePersistence.ClearFile then
						local opts = {}
						if FootholdSavePath then opts.path = FootholdSavePath end
						if FootholdSaveBaseName and tostring(FootholdSaveBaseName) ~= "" then
						opts.filename = tostring(FootholdSaveBaseName) .. "_storage.csv"
						end
						WarehousePersistence.ClearFile(opts)
					end
				trigger.action.outText(L10N:Get("SYRIA_SETUP_RESTARTING_NOW"), 120)
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
	bc:roamGroupsToLocalSubZone({
		"Red Armour Group #",
		"Red Armour Group 2 #",
		"Red Armour Group 3 #",
		"Red Armour Group 4 #",
		"Red SAM AAA #",
		"Red SAM AAA 2 #",
		"Red SAM AAA 5 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD Tor M2 #",
		"Red SAM SHORAD Pantsir S1 #",
		"Red SAM SHORAD SA-19 #",
		'Red Armor Group7 #',
		'Red Armor Group9 #',
		'Red Armor Group6 #',
		'Molniya #',
		'Rezky #',
		'SpeedBoats #',
		'Grisha #',
	},  30, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
end,{},timer.getTime()+30)

zones.convoy:registerTrigger('lost', function (event, sender)
	local convoyItems = {'convoy1', 'convoy2', 'convoy3', 'convoy4'}
	
	local message = L10N:Get("PG_SETUP_CONVOY_LIBERATED")
	local totalLost = 0
	for i,v in ipairs(convoyItems) do
		if not StaticObject.getByName(v) then
			totalLost = totalLost + 1
		end
	end
	
	if totalLost > 0 then
		local percentLost = math.ceil((totalLost / #convoyItems) * 100)
		percentLost = math.min(percentLost, 100)
		percentLost = math.max(percentLost, 1)
		message = L10N:Format("PG_SETUP_CONVOY_LOST_TRUCKS", message, percentLost)
	else
		message = L10N:Format("PG_SETUP_CONVOY_RECOVERED_ALL", message)
	end
	
	local creditsEarned = (#convoyItems - totalLost) * 250
	message = L10N:Format("PG_SETUP_REWARD_CREDITS", message, creditsEarned)
	
	bc:addFunds(2, creditsEarned)
	
	trigger.action.outTextForCoalition(2, message, 15)
end, 'convoyLost', 1)

local showCredIncrease = function(event, sender)
	trigger.action.outTextForCoalition(sender.side, L10N:Format("PG_SETUP_CREDITS_PER_HOUR", math.floor(sender.income * 360)), 5)
end

zones.oilfields:registerTrigger('captured', showCredIncrease, 'oilfieldcaptured')
zones.factory:registerTrigger('captured', showCredIncrease, 'factorycaptured')


zones.bandarabbas:registerTrigger('captured', function(event, sender)
	local kr = bc:getZoneByName('BandarAbbas')
	if kr.side == 1 then
		local krforces = { 'Bandar-gforce-1', 'Bandar-gforce-2', 'Bandar-gforce-3', 'Bandar-tforce-1' }
		for _, v in ipairs(krforces) do
			local g = Group.getByName(v)
			if g then
				g:destroy()
			end
		end
	end
end, 'bandarabbascaptured')

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
  groundattack  = 1000,
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
  groundattack   = 5,
  dynamicdecoy   = 1,
  dynamicstatic  = 4,
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

local smokeTargetMenu = nil
bc:registerShopItem('smoke', LTGet("SYRIA_SHOP_ITEM_SMOKE_MARKERS"), ShopPrices.smoke, function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 then
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
	trigger.action.outTextForCoalition(2, L10N:Get("SYRIA_SHOP_CAP_REQUESTED"), 20)
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

	trigger.action.outTextForCoalition(2, L10N:Get("SYRIA_SHOP_CAP_REQUESTED"), 20)
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
---

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
---
bc:registerShopItem('dynamiccas', LTGet("SYRIA_SHOP_ITEM_CAS_FLIGHT"), ShopPrices.dynamiccas,
function(sender)
    if casActive then
        return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "CAS")
    end
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

bc:registerShopItem('groundattack', LTGet("SYRIA_SHOP_ITEM_GROUND_ATTACK"), ShopPrices.groundattack,
function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended and not isCarrierZoneName(params.zone.zone) then
		return bc:launchPlayerGroundAttack(params.zone, params.allowFarp)
	else
		return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
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


if UseStatics == true then
bc:registerShopItem('dynamicstatic', LTGet("CA_SHOP_ITEM_STATIC_STRUCTURE"), ShopPrices.dynamicstatic,
function(sender)
    if StructureActive then
        return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "building strike")
    end
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and params.zone.newStatics and next(params.zone.newStatics) then
        if StructureActive then
            return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "building strike")
        end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return LTGet("CA_SHOP_NO_FRIENDLY_STRIKE_SPAWN")
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnStructureAt(closestBlue, params.zone.zone, offset)
        return
	else
		return LTGet("CA_SHOP_CAN_ONLY_TARGET_BUILDINGS")
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
	emptyLabel = LTGet("CA_SHOP_NO_VALID_BUILDING_TARGET_ZONES"),
}
end
---------------------------------------------END DYNAMIC SHOP ------------------------------------------
bc:addMonitoredROE('cruise1')
local cruiseMissileTargetMenu = nil
bc:registerShopItem('cruisemsl', LTGet("SYRIA_SHOP_ITEM_CRUISE_MISSILE"), ShopPrices.cruisemsl, function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 then
        local err = bc:fireAtZone(params.zone.zone, 'cruise1', true, 8)
        if err then
            return err
        end
        
        trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_LAUNCHING_CRUISE", params.zone.zone), 15)
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['cruisemsl'].groupZoneSelector = {
    targetzoneside = 1,
    includeSuspended = false,
    sortPolicy = 'enemy_frontline',
    emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}


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
local jtacDrones
local jtacTargetMenu = nil
for _,n in ipairs({'jtacDroneColdwar1','jtacDroneColdwar2','jtacDrone1','jtacDrone2'}) do
    local g = Group.getByName(n)
    if g then g:destroy() end
end
if Era == 'Coldwar' then
jtacDrones = {JTAC:new({name = 'jtacDroneColdwar1'}),JTAC:new({name = 'jtacDroneColdwar2'})}
else
jtacDrones = {JTAC:new({name = 'jtacDrone1'}),JTAC:new({name = 'jtacDrone2'})}
end
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
		if Era == 'Coldwar' then
			trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_JTAC_TOMCAT_ACTIVE", params.zone.zone, #jtacQueue),15)
		else
			trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SHOP_JTAC_REAPER_ACTIVE", params.zone.zone, #jtacQueue),15)
		end
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
local jtacTargetMenu2 = nil
local droneAM
Group.getByName('JTAC9lineamColdwar'):destroy()
Group.getByName('JTAC9lineam'):destroy()
if Era == 'Coldwar' then
droneAM = JTAC9line:new({name = 'JTAC9lineamColdwar'})
else
droneAM = JTAC9line:new({name = 'JTAC9lineam'})
end
bc:registerShopItem('9lineam', LTGet("SYRIA_SHOP_ITEM_JTAC_9LINE_AM"), ShopPrices["9lineam"], function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        droneAM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = Era == 'Coldwar' and 'JTAC9lineamColdwar' or 'JTAC9lineam'}
		if Era == 'Coldwar' then
			trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_JTAC_TOMCAT_AM", params.zone.zone), 30)
        
    	else
			trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_JTAC_REAPER_AM", params.zone.zone), 30)
		end
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

  ------------------------------ END 9 line jtac AM END ------------------------------
  ----------------------------- START 9 line jtac fm START ---------------------------
Group.getByName('JTAC9linefmColdwar'):destroy()
Group.getByName('JTAC9linefm'):destroy()
local jtacTargetMenu3 = nil
local droneFM
if Era == 'Coldwar' then
droneFM = JTAC9line:new({name = 'JTAC9linefmColdwar'})
else
droneFM = JTAC9line:new({name = 'JTAC9linefm'})
end
bc:registerShopItem('9linefm', LTGet("SYRIA_SHOP_ITEM_JTAC_9LINE_FM"), ShopPrices["9linefm"], function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        droneFM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = Era == 'Coldwar' and 'JTAC9linefmColdwar' or 'JTAC9linefm'}

		if Era == 'Coldwar' then
			trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_JTAC_TOMCAT_FM", params.zone.zone), 30)
        
    	else
			trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_JTAC_REAPER_FM", params.zone.zone), 30)
		end
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

  -------------------------- END 9 line jtac FM END ----------------------------------

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

Group.getByName('ewAircraft'):destroy()
local jamMenu = nil

bc:registerShopItem('jam', LTGet("SYRIA_SHOP_ITEM_JAM_RADARS"), ShopPrices.jam, function(sender)
    local gr = Group.getByName('ewAircraft')
    if Utils.isGroupActive(gr) then 
        return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "Jamming")
    end
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 then
        local gr = Group.getByName('ewAircraft')
        if Utils.isGroupActive(gr) then 
            return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "Jamming")
        end
        RespawnGroup('ewAircraft')
        
        timer.scheduleFunction(function(target)
            local ew = Group.getByName('ewAircraft')
            if ew then
                local err = bc:jamRadarsAtZone('ewAircraft', target)
                if err then
                    return err
                end
                
                trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_GROWLER_JAMMING", target), 15)
            end
        end,{params.zone.zone},timer.getTime() + 2)
        
    else
        return LTGet("SYRIA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['jam'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_ENEMY_ZONES"),
}
Group.getByName('ca-tanks-Coldwar'):destroy()
Group.getByName('ca-tanks'):destroy()
tanksMenu = nil
bc:registerShopItem('armor', LTGet("SYRIA_SHOP_ITEM_DEPLOY_ARMOR"), ShopPrices.armor, function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		local zn = CustomZone:getByName(params.zone.zone)
		zn:spawnGroup((Era == 'Coldwar') and 'ca-tanks-Coldwar' or 'ca-tanks')
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
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
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
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
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
--end of menu

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
		params.zone:addExtraSlot((Era == 'Coldwar') and 'bluePD Coldwar' or 'bluePD1')
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
	if params.zone and params.zone.side==2 and not params.zone.suspended then
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
bc.shopItems['groundattack'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['groundattack'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['dynamicbomb'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['dynamicbomb'].groupZoneSelector.refreshTags = { 'enemy_targets' }
if bc.shopItems['dynamicstatic'] and bc.shopItems['dynamicstatic'].groupZoneSelector then
	bc.shopItems['dynamicstatic'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
	bc.shopItems['dynamicstatic'].groupZoneSelector.refreshTags = { 'enemy_targets' }
end
bc.shopItems['cruisemsl'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['cruisemsl'].groupZoneSelector.refreshTags = { 'enemy_targets' }
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
bc.shopItems['jam'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['jam'].groupZoneSelector.refreshTags = { 'enemy_targets' }
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
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		local slotID = (Era == 'Coldwar') and 'blueArmor_cw' or 'blueArmor'
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

local patMenu=nil
bc:registerShopItem('zpat',LTGet("SYRIA_SHOP_ITEM_UPGRADE_PATRIOT"),ShopPrices.zpat,function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
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
	groundattack  = 1000, -- Ground attack convoy
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
	groundattack   = 5,  -- Ground attack convoy
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

ShopCats.AIAttack = LTGet("SYRIA_SHOP_CAT_AI_ATTACK")
ShopCats.ZoneUpgrades = LTGet("SYRIA_SHOP_CAT_ZONE_UPGRADES")
ShopCats.JTACIntel = LTGet("SYRIA_SHOP_CAT_JTAC_INTEL")
ShopCats.MarkingTools = LTGet("SYRIA_SHOP_CAT_MARKING_TOOLS")
ShopCats.CombinedArms = LTGet("SYRIA_SHOP_CAT_COMBINED_ARMS")
ShopCats.LogisticsStrategic = LTGet("SYRIA_SHOP_CAT_LOGISTICS")
ShopCats.OtherSupport = LTGet("SYRIA_SHOP_CAT_OTHER_SUPPORT")

ShopCats.Order = {
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
bc:addShopItem(2, 'groundattack', -1, 7, ShopRankRequirements.groundattack, ShopCats.AIAttack) -- Ground attack convoy
bc:addShopItem(2, 'cruisemsl', 12, 7, ShopRankRequirements.cruisemsl, ShopCats.AIAttack) -- Cruise missiles

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


supplyZones = {
    'Sharjah',
    'BandarAbbas',
    'Factory',
    'Khasab',
    'Delta',
    'Echo',
    'Golf',
    'Carrier Group',
    'Khamets',
    'Kish intl',
    'Bandar Lengeh',
    'Sunny',
    'Ramp-Kongo',
    'Al Dhafra',
    'Al Huti',
    'Al Ain',
    'Fujairah Intl',
    'Al Minhad AFB',
    'Ras Al Khaimah',
    'Al Khatim',
    'Al Dahid',
    'Radio Tower',
    'Qeshm Island',
	'Paregaan',
	'Samathe',
	'Lar',
	'Abu Musa Island',
	'Sirri Island',
	'Tunb Island AFB',
	'Moradi',
	'Red Carrier',
	'Charlie',
	'Alpha'


}

TerritoryOverlayOuterDrawPushMeters = 500000

lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

bc:loadFromDisk()
if zonePersistance and zonePersistance.zones and next(zonePersistance.zones) == nil then
    bc.saveLoaded = false
end

if bc.saveLoaded and CustomFlags['StartNormalFalse'] ~= nil then
    StartNormal = not CustomFlags['StartNormalFalse']
else
    CustomFlags['StartNormalFalse'] = not StartNormal
    StartNormal = not CustomFlags['StartNormalFalse']
end

local disableBlueCarrierAfterInit = not StartNormal

if not bc.saveLoaded then
    applyRandomRedUpgrades()
    applyRandomBlueUpgrades()

    if not StartNormal then
        if zones.carrier.active then
            zones.lar.LogisticCenter = true
        end
		DestroyOnce = true
    else
		DoItOnce = true
        zones.aldhafra.LogisticCenter = true
    end
else
    applyRandomUpgradesForNewZonesOnly()
end

if zones.insurgencygridcn76.side == 1 then
    bc:addConnection("Al Minhad AFB", "Insurgency Grid CN76")
end

if zones.insurgencygridcq37.side == 1 then
    bc:addConnection("Moradi", "Insurgency Grid CQ37")
end

if zones.scudcity.side == 1 then
    bc:addConnection("Ras Al Khaimah", "Scud City")
end

if zones.dhafradefence.side == 1 then
    bc:addConnection("Al Dhafra-Defence", "Al Dhafra",true)
    bc:addHiddenConnection("Al Dhafra", "Al Minhad AFB")
    bc:addHiddenConnection("Al Ain", "Al Minhad AFB")
    bc:addHiddenConnection("Al Ain", "Fujairah Intl")
end

bc:init()

if disableBlueCarrierAfterInit then
	destroyGroupIfActive('CVN-74')
	destroyGroupIfActive('CVN-72')
	destroyGroupIfActive('Tarawa')
end
if DestroyOnce then
	if not NoTorM2AndPantsir or Era == 'Coldwar' then
		zones.hiddenwaters:MakeZoneRedAndUpgrade()
	end
    zones.carrier:disableZone(true)
    zones.lardefence:disableZone(true)
	zones.dhafradefence:AwakenZoneAndUpgrade()
	bc:addConnection("Al Dhafra-Defence", "Al Dhafra",true)
	bc:addHiddenConnection("Al Dhafra", "Al Minhad AFB")
	zones.hidden4:MakeZoneRedAndUpgrade()
end


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
startWarehousePersistence()
SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 4, 0)
SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 6, 0)
if DoItOnce then
	if not NoTorM2AndPantsir or Era == 'Coldwar' then
		timer.scheduleFunction(function()
		zones.hiddenwaters:MakeZoneRedAndUpgrade()
		end, {}, timer.getTime() + 1)
	end
end

AWACS_CFG = {
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=150 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=70 }   -- blue
}

GlobalSettings.autoSuspendNmBlue = 70   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 100   		-- suspend red zones deeper than this nm

evc = EventCommander:new({ decissionFrequency=30*60, decissionVariance=30*60, skipChance = 10})
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

evc:init()
local HuntNumber = SplashDamage and math.random(15,25) or math.random(8,15)
bc:initHunter(HuntNumber)
bandarforce = {
	['Echo'] = { 'Bandar-force-1' , 'Bandar-force-2', 'Bandar-force-3'},
	['Delta'] = { 'Bandar-tforce-1' },
	['Kish intl'] = { 'evt-kish-sead-attack-bandar' },
	['Lar'] = {
    'Bandar-aforce-1',Era=='Coldwar' and 'Bandar-aforce-3 ColdWar' or 'Bandar-aforce-3'}}

	for i,v in pairs(bandarforce) do
	for _,v2 in ipairs(v) do
		Group.getByName(v2):destroy()
	end
end
evc:addEvent({
	id='bandarattack',
	action = function()
		for i,v in pairs(bandarforce) do
			if bc:getZoneByName(i).side == 1 then
				for _,v2 in ipairs(v) do
					RespawnGroup(v2)
				end
			end
		end
	end,
	canExecute = function()
		if math.random(1,100) < 70 then return false end
		
		if bc:getZoneByName('BandarAbbas').side ~= 2 then return false end
		
		local canAttack = false
		for i,v in pairs(bandarforce) do
			if bc:getZoneByName(i).side == 1 then canAttack = true end
			
			for _,v2 in ipairs(v) do
				if Group.getByName(v2) then return false end
			end
		end
		
		return canAttack
	end
})

--------------------------------------- Oscar Scuds ---------------------------------------
Group.getByName('oscar-scud-1'):destroy()
evc:addEvent({
	id='scuds',
	action = function()
		RespawnGroup('oscar-scud-1')
		RegisterGroupTarget('oscar-scud-1',100,L10N:Get("SYRIA_MISSION_TARGET_DESTROY_SCUDS"),'scuds')
		timer.scheduleFunction(function(param, time)
			if IsGroupActive('oscar-scud-1') then
				local scudGrp = GROUP:FindByName('oscar-scud-1')
				local _,_,_,_,missilesLeft = scudGrp:GetAmmunition()
				if missilesLeft == 0 then return time + (45*60) end			
				local tgts = {
					'Qeshm Island',
					'BandarAbbas',
					'Khasab',
					'Delta',
					'Echo',
					'Oil Fields',
					'Ras Al Khaimah',
					'Sharjah'
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
				bc:fireAtZone(choice, 'oscar-scud-1', true, 16)
				trigger.action.outTextForCoalition(2, L10N:Format("PG_EVENT_SCUDS_FOXTROT_LAUNCHING", choice), 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
		if ActiveMission['scuds'] then return false end
		if math.random(1, 100) < 60 then return false end
		local gr = Group.getByName('oscar-scud-1')
		if gr then return false end

		if bc:getZoneByName('Foxtrot').side ~= 1 or bc:getZoneByName('Foxtrot').suspended then return false end

		local triggers = {'BandarAbbas', 'Qeshm Island', 'Ramp-Kongo', 'Lar'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		return false
	end
})
mc:trackMission({
	title = LTGet("PG_MISSION_SCUDS_30_TITLE"),
	description = LTGet("PG_MISSION_SCUDS_30_DESC"),
	messageStart = LTGet("PG_MISSION_SCUDS_START"),
	messageEnd = LTGet("PG_MISSION_SCUDS_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
	isActive = function()
		if not ActiveMission['scuds']  then return false end
		if Group.getByName('oscar-scud-1') then return true end
		ActiveMission['scuds'] = nil
		return false
	end
})
-------------------------------------End of Oscar Scuds ----------------------------------
---------------------------------------- Helo Hunt ---------------------------------------
local HeloHunt_COOLDOWN = 2700
local lastHeloHunt_COOLDOWN  = -HeloHunt_COOLDOWN
Group.getByName('lar-attack-ramp-kongo-event'):destroy()
Group.getByName('lar-attack-sunny-event'):destroy()
Group.getByName('lar-attack-echo-event'):destroy()
Group.getByName('lar-attack-golf-event'):destroy()
Group.getByName('lar-attack-foxtrot-event'):destroy()
Group.getByName('lar-attack-ramp-kongo-event-cw'):destroy()
Group.getByName('lar-attack-sunny-event-cw'):destroy()
Group.getByName('lar-attack-echo-event-cw'):destroy()
Group.getByName('lar-attack-golf-event-cw'):destroy()
Group.getByName('lar-attack-foxtrot-event-cw'):destroy()
evc:addEvent({
    id='helohunt',
    action=function()
        local function cw(n)return Era=='Coldwar' and (n..'-cw') or n end
        local groupsAndTargets={
            {group=cw('lar-attack-ramp-kongo-event'), target='Ramp-Kongo'},
            {group=cw('lar-attack-sunny-event'),      target='Sunny'},
            {group=cw('lar-attack-echo-event'),       target='Echo'},
            {group=cw('lar-attack-golf-event'),       target='Golf'},
            {group=cw('lar-attack-foxtrot-event'),    target='Foxtrot'}
        }
        for _,e in ipairs(groupsAndTargets) do
            local z = bc:getZoneByName(e.target)
            if z and z.side == 2 and not z.suspended then
                RespawnGroup(e.group)
                timer.scheduleFunction(function()
                    RegisterGroupTarget(e.group,500,L10N:Get("PG_MISSION_HELO_HUNT_TARGET"))
                end,{},timer.getTime()+1)
            end
        end
    end,
    canExecute=function()
		if timer.getAbsTime() - lastHeloHunt_COOLDOWN < HeloHunt_COOLDOWN then return false end
        if math.random(1,100)<30 then return false end
        if bc:getZoneByName('Lar').side~=1 or bc:getZoneByName('Lar').suspended then return false end
        local trg={'Foxtrot','Golf','Ramp-Kongo','Sunny','Echo'}
        for _,v in ipairs(trg) do if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end end
        return false
    end
})

mc:trackMission({
    title = LTGet("PG_MISSION_HELO_HUNT_TITLE"),
    description = LTGet("PG_MISSION_HELO_HUNT_DESC"),
    messageStart = LTGet("PG_MISSION_HELO_HUNT_START"),
    messageEnd = function(T) lastHeloHunt_COOLDOWN=timer.getTime() return LT(T):Get("PG_MISSION_HELO_HUNT_END") end,
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
    isActive = function()
        local function cw(n)return Era=='Coldwar' and (n..'-cw') or n end
        local groups = {
            cw('lar-attack-ramp-kongo-event'),
            cw('lar-attack-sunny-event'),
            cw('lar-attack-echo-event'),
            cw('lar-attack-golf-event'),
            cw('lar-attack-foxtrot-event'),
        }
        for _, groupName in ipairs(groups) do
            if Group.getByName(groupName) then
                return true
            end
        end
        return false
    end
})
-------------------------------------End of Helo Hunt ----------------------------------
---------------------------------------- Convoy Zones ---------------------------------------
  local setBlueUnits = SET_GROUP:New():FilterCoalitions("blue"):FilterStart()
    local convoyZones = {{zone = ZONE:New("ConvoyZone"), flag = "ConvoyMove"}}

  for _, entry in ipairs(convoyZones) do
    entry.zone:Trigger(setBlueUnits)

    function entry.zone:OnAfterEnteredZone(From, Event, To, Controllable)
      if not Controllable or not Controllable:IsAlive() then return end
      trigger.action.setUserFlag(entry.flag, 1)
    end
  end
-------------------------------------End of Convoy Zones ----------------------------------
---------------------------------------- Airstrike ---------------------------------------
local airstrike_COOLDOWN = 1800
local lastairstrike_COOLDOWN  = -airstrike_COOLDOWN
local attackGrp =
    (StartNormal == false)
    and (Era == 'Coldwar' and 'evt-attackcw-Otherway' or 'evt-attack-OtherWay')
    or  (Era == 'Coldwar' and 'evt-attackcw'          or 'evt-attack')

Group.getByName('evt-attack'):destroy()
Group.getByName('evt-attackcw'):destroy()
Group.getByName('evt-attack-OtherWay'):destroy()
Group.getByName('evt-attackcw-Otherway'):destroy()
evc:addEvent({
	id='cas',
	action=function()
		RespawnGroup(attackGrp)
		RegisterGroupTarget(attackGrp,500,L10N:Get("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),'cas')
		timer.scheduleFunction(function(param, time)
			local tgts = {
				'BandarAbbas',
				'Khasab',
				'Qeshm Island',
				'Delta',
				'Echo',
				'Sharjah'
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
				
				if Group.getByName(attackGrp) then 
					bc:engageZone(choice,attackGrp)
				end
			end
		end, {}, timer.getTime()+3)
	end,
	canExecute = function()
		if timer.getTime()-lastairstrike_COOLDOWN<airstrike_COOLDOWN then return false end
		if ActiveMission['cas'] then return false end
		local gr = Group.getByName(attackGrp)
		if gr then return false end
		if math.random(1,100) < 50 then return false end
		if bc:getZoneByName('Lar').side ~= 1 or bc:getZoneByName('Lar').suspended then return false end
		
		local triggers = {'BandarAbbas', 'Khasab', 'Qeshm Island', 'Sharjah'}
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
	description = LTGet("PG_MISSION_INTERCEPT_AIRSTRIKE_WEST_SE_DESC"),
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
		local gr = Group.getByName(attackGrp)
		if gr then return true end
		ActiveMission['cas'] = nil
		return false
	end
})
-------------------------------------End of Airstrike ----------------------------------
---------------------------------------- Scenery Check ---------------------------------------

local sceneryList = {
    ["StrikePort"] = {SCENERY:FindByZoneName("StrikePort1"), SCENERY:FindByZoneName("StrikePort2")},
    ["GeneralsHouse"] = {SCENERY:FindByZoneName("Generals house")},

    ["TerrorCell2"] = {SCENERY:FindByZoneName("TerrorCell2")},
    ["TerrorCell3"] = {SCENERY:FindByZoneName("TerrorCell3")},
    ["TerrorCell4"] = {SCENERY:FindByZoneName("TerrorCell4")},
    ["TerrorCell5"] = {SCENERY:FindByZoneName("TerrorCell5")},
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
    trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", name), 30)
  end
end
end, {}, timer.getTime() + 1)
-----------------------------------------End scenery Check -------------------------------------
---------------------------------------- Cargo Intercept ---------------------------------------

local CargoIntercept_COOLDOWN = 1800
local lastCargoIntercept_COOLDOWN  = -CargoIntercept_COOLDOWN
Group.getByName('evt-cargointercept1'):destroy()
Group.getByName('evt-cargointercept2'):destroy()
Group.getByName('evt-cargointercept3'):destroy()
evc:addEvent({
	id='cargointercept',
	action = function()
	
	local planes
	if bc:getZoneByName('BandarAbbas').side == 1 then
	  planes = { 'evt-cargointercept2', 'evt-cargointercept3' }
	else
	  planes = { 'evt-cargointercept2', 'evt-cargointercept3', 'evt-cargointercept1' }
	end
	local choice = math.random(1, #planes)
	RespawnGroup(planes[choice])
		RegisterGroupTarget(planes[choice],500,L10N:Get("SYRIA_MISSION_INTERCEPT_CARGO_TITLE"),'cargointercept')
	end,
	canExecute = function()
		if ActiveMission['cargointercept'] then return false end
		if timer.getTime() - lastCargoIntercept_COOLDOWN < CargoIntercept_COOLDOWN then return false end
		if math.random(1,100) < 70 then return false end
		if bc:getZoneByName('Lar').side ~= 1 or bc:getZoneByName('Lar').suspended then return false end	
		return true
	end
})
mc:trackMission({
    title = LTGet("SYRIA_MISSION_INTERCEPT_CARGO_TITLE"),
    description = function(T)
		if Group.getByName('evt-cargointercept1') then
			return LT(T):Get("PG_MISSION_INTERCEPT_CARGO_DESC_BANDAR")
		elseif Group.getByName('evt-cargointercept2') then
			return LT(T):Get("PG_MISSION_INTERCEPT_CARGO_DESC_KHASAB")
		elseif Group.getByName('evt-cargointercept3') then
			return LT(T):Get("PG_MISSION_INTERCEPT_CARGO_DESC_AL_AIN")
		else
			return LT(T):Get("PG_MISSION_INTERCEPT_CARGO_INACTIVE")
		end
	end,
    messageStart = LTGet("SYRIA_MISSION_INTERCEPT_CARGO_START"),
    messageEnd =function(T) lastCargoIntercept_COOLDOWN=timer.getTime() return LT(T):Get("SYRIA_MISSION_INTERCEPT_CARGO_END") end,
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "radio1.ogg")
        end
    end,
    endAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
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
-------------------------------------End of Cargo Intercept ----------------------------------
---------------------------------------- Bomber Attack ---------------------------------------
local bomb_COOLDOWN = 1800
local lastbomb_COOLDOWN = -bomb_COOLDOWN
local bombGrp = (StartNormal == false) and 'evt-bomb-Otherway' or 'evt-bomb'
local escGrp =
    (StartNormal == false)
    and (Era == 'Coldwar' and 'EscortBomberCW-Otherway' or 'EscortBomber-Otherway')
    or  (Era == 'Coldwar' and 'EscortBomberCW'          or 'EscortBomber')
Group.getByName('evt-bomb'):destroy()
Group.getByName('evt-bomb-Otherway'):destroy()
Group.getByName('EscortBomberCW'):destroy()
Group.getByName('EscortBomber'):destroy()
Group.getByName('EscortBomberCW-Otherway'):destroy()
Group.getByName('EscortBomber-Otherway'):destroy()

evc:addEvent({
	id='bomb',
	action=function()
		RespawnGroup(bombGrp)
		RegisterGroupTarget(bombGrp, 500, L10N:Get("SYRIA_MISSION_TARGET_INTERCEPT_BOMBERS"), 'bomb')
		timer.scheduleFunction(function()
			RespawnGroup(escGrp)
	local tgts = {
		'Sharjah','Ras Al Khaimah','Moradi','Bandar Lengeh','Al Dahid','BandarAbbas','Delta',
		'Echo','Foxtrot','Paregaan','Radio Tower','Kish intl','Tunb Island AFB','Sirri Island',
		'Abu Musa Island'}
				if Group.getByName(bombGrp) then
					local bomber, bomberMission = StartBomberAuftrag('bomb', bombGrp, tgts, escGrp)
				end
		end,{},timer.getTime()+1)
	end,
	canExecute = function()
		if ActiveMission['bomb'] then return false end
		if timer.getTime()-lastbomb_COOLDOWN<bomb_COOLDOWN then return false end
		local gr = Group.getByName(bombGrp)
		if gr then return false end
		if math.random(1,100)<70 then return false end
		local triggers = {'Sharjah', 'Khasab', 'Qeshm Island', 'BandarAbbas', 'Abu Musa Island'}
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
	description = LTGet("PG_MISSION_INTERCEPT_BOMBERS_NORTH_DESC"),
	messageStart = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_START"),
	messageEnd = function(T) lastbomb_COOLDOWN=timer.getTime() return LT(T):Get("SYRIA_MISSION_INTERCEPT_BOMBERS_END") end,
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
		if Group.getByName(bombGrp) then return true end
		ActiveMission['bomb'] = nil
		return false
		
	end
})
-------------------------------------End of Bomber Attack ----------------------------------
----------------------------------------- Escort -------------------------------------------
local EscortCooldown = 2400
local lastEscortCooldown   = -EscortCooldown
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
							trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_EVENT_INTERCEPTOR_SPOTTED"),15)
						else
							trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_EVENT_INTERCEPT_MISSION"),15)
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
		if timer.getTime() - lastEscortCooldown < EscortCooldown then return false end
		local gr = Group.getByName('escort-me')
		if gr then return false end
		
		local triggers = {'Sharjah', 'BandarAbbas', 'Khasab', 'Qeshm Island', 'Kish intl'}
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
    description = LTGet("PG_MISSION_ESCORT_CARGO_AL_DHAFRA_DESC"),
    messageStart = LTGet("SYRIA_MISSION_ESCORT_CARGO_START"),
    messageEnd = function(T) lastEscortCooldown = timer.getTime() return LT(T):Get("SYRIA_MISSION_ESCORT_CARGO_END") end,
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
-------------------------------------End of Escort ----------------------------------		
------------------------------------ FindHimInAlAin ---------------------------------
Group.getByName('AlAinConvoy'):destroy()
Group.getByName('AlAinInfantryStandbyGroup'):destroy()
evc:addEvent({
	id='FindHimInAlAin',
	action = function()
		RespawnGroup('AlAinConvoy')
		RespawnGroup('AlAinInfantryStandbyGroup')
		RegisterGroupTarget('AlAinInfantryStandbyGroup',500,L10N:Get("PG_MISSION_TERROR_CELL_TARGET"),'FindHimInAlAin',true)
	end,
	canExecute = function()
	if CustomFlags["FindHimInAlAin"] then return false end
	if ActiveMission["FindHimInAlAin"] then return false end
	if Group.getByName('AlAinConvoy') then return false end
	if bc:getZoneByName('Al Ain').side ~= 2 then return false end
	return true
end
})

mc:trackMission({
	title = LTGet("PG_MISSION_STRIKE_TERROR_CELL_AL_AIN_TITLE"),
	description = LTGet("PG_MISSION_STRIKE_TERROR_CELL_AL_AIN_DESC"),
	messageStart = LTGet("PG_MISSION_STRIKE_TERROR_CELL_AL_AIN_START"),
	messageEnd = LTGet("PG_MISSION_STRIKE_TERROR_CELL_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	missionFail = function()
		if not IsGroupActive('AlAinConvoy') and IsGroupActive('AlAinInfantryStandbyGroup') then
			trigger.action.outTextForCoalition(2, L10N:Get("PG_MISSION_CELL_CONVOY_FAILED"), 10)
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
			return true
		end
		return false
	end,
	isActive = function()
		if CustomFlags["FindHimInAlAin"] then return false end
		if not ActiveMission["FindHimInAlAin"] then return false end
		if Group.getByName('AlAinInfantryStandbyGroup') then return true end
		ActiveMission["FindHimInAlAin"] = nil
		return false
		end
})
--------------------------------------- End FindHimInAlAin ------------------------------------
----------------------------------------- Terror Cell 2 ---------------------------------------


Group.getByName('TerrorCell2Group'):destroy()
evc:addEvent({
	id='TerrorCell2',
	action = function()
	RespawnGroup('TerrorCell2Group')
		RegisterGroupTarget('TerrorCell2Group',500,L10N:Get("PG_MISSION_TERROR_CELL_TARGET"),'TerrorCell2',true)
	end,
	canExecute = function()
		if CustomFlags["TerrorCell2"] then return false end
		if ActiveMission["TerrorCell2"] then return false end
		if math.random(1,100) < 70 then return false end
		if Group.getByName('TerrorCell2Group') then return false end
		
		if bc:getZoneByName('Delta').side ~= 2 and bc:getZoneByName('Lar').side ~= 2 then return false end
		return true
	end
})
mc:trackMission({
	title = LTGet("PG_MISSION_STRIKE_TERROR_CELL_TITLE"),
	description = LTGet("PG_MISSION_STRIKE_TERROR_CELL_DELTA_DESC"),
	messageStart = LTGet("PG_MISSION_STRIKE_TERROR_CELL_START"),
	messageEnd = LTGet("PG_MISSION_STRIKE_TERROR_CELL_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["TerrorCell2"] then return false end
	if not ActiveMission['TerrorCell2'] then return false end
	if Group.getByName('TerrorCell2Group') then return true end
	ActiveMission["TerrorCell2"] = nil
	return false
	end,
})
---------------------------------------- Strike the general ------------------------------------
Group.getByName('TerrorMan'):destroy()
Group.getByName('Red SAM SA-3 Fixed Event'):destroy()
evc:addEvent({
	id='TerrorMan',
	action = function()
		RespawnGroup('TerrorMan')
		RegisterGroupTarget('TerrorMan',750,L10N:Get("PG_MISSION_STRIKE_GENERAL_TARGET"),'TerrorCell4',true)
	end,
	canExecute = function()
		if CustomFlags["TerrorCell4"] then return false end
		if ActiveMission["TerrorCell4"] then return false end
		if bc:getZoneByName('BandarAbbas').side ~= 2 or bc:getZoneByName('Lar').side ~= 2 then return false end
		if Group.getByName('TerrorMan') then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("PG_MISSION_STRIKE_GENERAL_TITLE"),
	description = LTGet("PG_MISSION_STRIKE_GENERAL_PAREGAAN_DESC"),
	messageStart = LTGet("PG_MISSION_STRIKE_GENERAL_START"),
	messageEnd = LTGet("PG_MISSION_STRIKE_GENERAL_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
		if CustomFlags["TerrorCell4"] then return false end
		if not ActiveMission['TerrorCell4'] then return false end
		if Group.getByName('TerrorMan') then return true end
		ActiveMission["TerrorCell4"] = nil
		return false
	end
})
------------------------------------------- End strike the general ------------------------------------
---------------------------------------- Strike on enemy safehouse ------------------------------------
evc:addEvent({
	id = 'TerrorCell5',
	action = function()
		local tgt = sceneryList['TerrorCell5'][1] or SCENERY:FindByZoneName('TerrorCell5')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "TerrorCell5"),30)
			return
		end
		RegisterScoreTarget('TerrorCell5',tgt,1000,L10N:Get("PG_MISSION_SAFEHOUSE_TARGET"), true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("PG_MISSION_SAFEHOUSE_MARK"),p,2,false,false)
			MissionMarks['TerrorCell5'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['TerrorCell5'] then return false end
	if CustomFlags["TerrorCell5"] then return false end
	if bc:getZoneByName('Golf').side ~= 2 then return false end
	if bc:getZoneByName('Lar').side ~= 1 then return false end
	return true
	end,
})

mc:trackMission({
	title = LTGet("PG_MISSION_SAFEHOUSE_TITLE"),
	description = LTGet("PG_MISSION_SAFEHOUSE_DESC"),
	messageStart = LTGet("PG_MISSION_SAFEHOUSE_START"),
	messageEnd = LTGet("PG_MISSION_SAFEHOUSE_END"),
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
	if CustomFlags["TerrorCell5"] then return false end
	if ActiveMission['TerrorCell5'] then return true end
	return false
	end
})
--------------------------------------- End Strike on enemy safehouse ------------------------------------
---------------------------------------------- Terror Cell 3 ---------------------------------------------
evc:addEvent({
	id = 'TerrorCell3',
	action = function()
		local tgt = sceneryList['TerrorCell3'][1] or SCENERY:FindByZoneName('TerrorCell3')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "TerrorCell3"),30)
			return
		end
		RegisterScoreTarget('TerrorCell3',tgt,500,L10N:Get("PG_MISSION_STRIKE_MISSION_TARGET"), true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("PG_MISSION_TERROR_CELL_MARK"),p,2,false,false)
			MissionMarks['TerrorCell3'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['TerrorCell3'] then return false end
	if CustomFlags["TerrorCell3"] then return false end
	if bc:getZoneByName('Sharjah').side ~= 2 or bc:getZoneByName('Khasab').side ~= 2 then return false end
	  return true
	end,

})
mc:trackMission({
	title = LTGet("PG_MISSION_STRIKE_TERROR_CELL_TITLE"),
	description = LTGet("PG_MISSION_STRIKE_TERROR_CELL_RAK_DESC"),
	messageStart = LTGet("PG_MISSION_STRIKE_TERROR_CELL_START"),
	messageEnd = LTGet("PG_MISSION_STRIKE_TERROR_CELL_END_REWARD_500"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["TerrorCell3"] then return false end
	if ActiveMission['TerrorCell3'] then return true end
	return false
	end
})
--------------------------------------- End of terror cell 3 ---------------------------------------

evc:addEvent({
	id = 'StrikePort',
	action = function()
		local tgts = sceneryList['StrikePort']
		local found = false
		for _,t in ipairs(tgts) do
			if t then
				RegisterScoreTarget('StrikePort',t,1000,L10N:Get("PG_MISSION_STRIKE_PORT_TARGET"),true)
				found = true
				local p = t:GetDCSObject() and t:GetDCSObject():getPoint()
				if p then
					missionMarkId = missionMarkId + 1
					trigger.action.markToCoalition(missionMarkId,L10N:Get("PG_MISSION_STRIKE_PORT_MARK"),p,2,false,false)
					MissionMarks['StrikePort'] = missionMarkId
				end
			end
		end
		if not found then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "StrikePort"),30)
		end

	end,
	canExecute = function()
		if CustomFlags['StartNormalFalse'] then return false end
		if ActiveMission['StrikePort'] then return false end
		if CustomFlags["StrikePort"] then return false end
		if bc:getZoneByName('Bandar Lengeh').side ~= 1 or bc:getZoneByName('Bandar Lengeh').suspended then return false end
		if bc:getZoneByName('Abu Musa Island').side == 2 and bc:getZoneByName('Abu Musa Island').suspended and bc:getZoneByName('Tunb Island AFB').side == 2 and 
		   bc:getZoneByName('Tunb Island AFB').suspended and bc:getZoneByName('Sirri Island').side == 2 and bc:getZoneByName('Sirri Island').suspended then return false end
		if (bc:getZoneByName('Khasab').side == 2 and not bc:getZoneByName('Khasab').suspended)
		or (bc:getZoneByName('Abu Musa Island').side == 2 and not bc:getZoneByName('Abu Musa Island').suspended)
		or (bc:getZoneByName('Lar').side == 2 and not bc:getZoneByName('Lar').suspended) then
			return true
		else
			return false
		end
		return false
	end,
})

mc:trackMission({
	title = LTGet("PG_MISSION_STRIKE_PORT_TITLE"),
	description = LTGet("PG_MISSION_STRIKE_PORT_DESC"),
	messageStart = LTGet("PG_MISSION_STRIKE_PORT_START"),
	messageEnd = LTGet("PG_MISSION_STRIKE_PORT_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	missionFail = function()
		if bc:getZoneByName('Abu Musa Island').side ~= 1 and bc:getZoneByName('Tunb Island AFB').side ~= 1 and
		   bc:getZoneByName('Sirri Island').side ~= 1 and not CustomFlags["StrikePort"] then
			trigger.action.outTextForCoalition(2, L10N:Get("PG_MISSION_PORT_ABORTED"), 10)
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
			return true
		end
		return false
	end,
	isActive = function()
	if CustomFlags["StrikePort"] then return false end
	if bc:getZoneByName('Bandar Lengeh').side ~= 1 then return false end
	if ActiveMission['StrikePort'] then return true end
	  return false
	end
})


---------------------------------------- Strike the Generals hideout ------------------------------------

evc:addEvent({
	id = 'GeneralsHouse',
	action = function()
		local tgt = sceneryList['GeneralsHouse'][1] or SCENERY:FindByZoneName('GeneralsHouse')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "GeneralsHouse"),30)
			return
		end
		RegisterScoreTarget('GeneralsHouse',tgt,1000,L10N:Get("PG_MISSION_STRIKE_GENERAL_TARGET"),true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("PG_MISSION_STRIKE_GENERAL_MARK"),p,2,false,false)
			MissionMarks['GeneralsHouse'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['GeneralsHouse'] then return false end
	--if bc:getZoneByName('Lavan Island').side ~= 1 or bc:getZoneByName('Lavan Island').suspended then return false end
	if bc:getZoneByName('Sirri Island').side ~= 2 or bc:getZoneByName('Lavan Island').side ~= 1 then return false end
	if CustomFlags["GeneralsHouse"] then return false end
	return true
	end,
})
mc:trackMission({
	title = LTGet("PG_MISSION_STRIKE_GENERAL_TITLE"),
	description = LTGet("PG_MISSION_GENERALS_HIDEOUT_DESC"),
	messageStart = LTGet("PG_MISSION_GENERALS_HIDEOUT_START"),
	messageEnd = LTGet("PG_MISSION_GENERALS_HIDEOUT_END"),
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
	missionFail = function()
		if bc:getZoneByName('Lavan Island').side ~= 1 or bc:getZoneByName('Lavan Island').suspended and not CustomFlags["GeneralsHouse"] then
			trigger.action.outTextForCoalition(2, L10N:Get("PG_MISSION_GENERAL_FLED"), 10)
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
			CustomFlags["GeneralsHouse"] = true
			return true
		end
		return false
	end,
	isActive = function()
	if CustomFlags["GeneralsHouse"] then return false end
	if ActiveMission['GeneralsHouse'] then return true end
	  return false
	end
})

Group.getByName('OnTheRun'):destroy()
local OnTheRunHandler=nil
evc:addEvent({
    id = 'KilltheRunner',
    action = function()
	RespawnGroup('OnTheRun')
		RegisterGroupTarget('OnTheRun',1500,L10N:Get("PG_MISSION_ON_THE_RUN_TARGET"),'OnTheRun',true)
    end,
    canExecute = function()
		if CustomFlags['OnTheRun'] then return false end
		if ActiveMission['OnTheRun'] then return false end
		if bc:getZoneByName('Echo').side ~= 2 or bc:getZoneByName('Bandar Lengeh').side ~= 2 or bc:getZoneByName('Foxtrot').side ~= 2 then return false end
        if bc:getZoneByName('Golf').side ~= 1 or bc:getZoneByName('Lar').side ~= 1 then return false end
        if Group.getByName('OnTheRun') then return false end
        return true
    end
})

mc:trackMission({
	title = LTGet("PG_MISSION_ON_THE_RUN_TITLE"),
	description = LTGet("PG_MISSION_ON_THE_RUN_DESC"),
	messageStart = LTGet("PG_MISSION_ON_THE_RUN_START"),
	messageEnd = LTGet("PG_MISSION_ON_THE_RUN_END"),
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
		if CustomFlags['OnTheRun'] then return false end
		if bc:getZoneByName('Lar').side ~= 1 then ActiveMission["OnTheRun"] = nil return false end
		if not ActiveMission['OnTheRun'] then return false end
		if Group.getByName('OnTheRun') then return true end
		ActiveMission["OnTheRun"] = nil
		return false
	end,
})

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
        MainTitle = LTGet("MISSION_ESCORT_TITLE"),
        title = LTGet("MISSION_ESCORT_TITLE"),
		titleBefore = function(self)
			self.notified = true
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, L10N:FormatForGroup(groupID, "MISSION_ESCORT_SPECIAL_AVAILABLE", mission.zone, mission.TargetZone), 30)
		 end,
        description = LTFormat("MISSION_ESCORT_DESCRIPTION", mission.TargetZone),
        isEscortMission = true,
        accept = false,
        missionGroup = mission.missionGroup,
        zoneName = zoneName,
        messageStart = LTFormat("MISSION_ESCORT_START", mission.TargetZone),
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
--                      RUN WAY STRIKE MISSION                     --

mc:trackMission({
    title=LTGet("MISSION_BOMB_RUNWAY_TITLE"),
    description=function(T)
	  T = LT(T)
      local wp=WaypointList[runwayTargetZone] or ""
      if #runwayNames>1 then
        return T:Format("MISSION_BOMB_RUNWAY_DESC_ALL", runwayTargetZone, wp)
      else
        return T:Format("MISSION_BOMB_RUNWAY_DESC_ONE", runwayTargetZone, wp)
      end
    end,
    messageStart=function(T)
	T = LT(T)
    local wp=WaypointList[runwayTargetZone] or ""
      if #runwayNames>1 then
        return T:Format("MISSION_BOMB_RUNWAY_START_ALL", runwayTargetZone, wp)
      else
        return T:Format("MISSION_BOMB_RUNWAY_START_ONE", runwayTargetZone, wp)
      end
    end,
	messageEnd = function(T)
		T = LT(T)
		trigger.action.outSoundForCoalition(2,'cancel.ogg')
		if runwayTargetZone then
			if runwayCompleted then
				local cred = (need and need>1) and 200 or 100
				if bomberName and runwayPartnerName then
					return T:Format("SYRIA_BOMB_RUNWAY_END_JOINT", runwayTargetZone, bomberName, runwayPartnerName, cred)
				elseif bomberName then
					return T:Format("SYRIA_BOMB_RUNWAY_END_SOLO", runwayTargetZone, bomberName, cred)
				else
					return T:Format("SYRIA_BOMB_RUNWAY_END_COMPLETED", runwayTargetZone)
				end
			else
				return T:Format("SYRIA_BOMB_RUNWAY_END_CANCELED_ZONE", runwayTargetZone)
			end
		else
			return T:Get("SYRIA_BOMB_RUNWAY_CANCELED")
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

mc:trackMission({
	title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
	description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Delta", "Echo"),
	messageStart = LTGet("SYRIA_MISSION_ARTY_START"),
	messageEnd = LTGet("SYRIA_MISSION_ARTY_END"),
    startAction = function()
		RegisterGroupTarget('Echo-attack-delta-art',100,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'Echo-attack-delta-art')
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
		if not ActiveMission['Echo-attack-delta-art'] then return false end
		local gr = Group.getByName('Echo-attack-delta-art')
		if gr then return true end
		ActiveMission['Echo-attack-delta-art'] = nil
		return false
	end
})
mc:trackMission({
	title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
	description = LTGet("PG_MISSION_ARTY_FOXTROT_DESC"),
	messageStart = LTGet("SYRIA_MISSION_ARTY_START"),
	messageEnd = LTGet("SYRIA_MISSION_ARTY_END"),
    startAction = function()
		RegisterGroupTarget('foxtrot-artillery-fire-at-golf',100,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'foxtrot-artillery-fire-at-golf')
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
		if not ActiveMission['foxtrot-artillery-fire-at-golf'] then return false end
		local gr = Group.getByName('foxtrot-artillery-fire-at-golf')
		if gr then return true end
		ActiveMission['foxtrot-artillery-fire-at-golf'] = nil
		return false
	end
})

mc:trackMission({
	title = LTGet("PG_MISSION_DEFEND_BANDAR_ABBAS_TITLE"),
	description = LTGet("PG_MISSION_DEFEND_BANDAR_ABBAS_DESC"),
	messageStart = LTGet("PG_MISSION_DEFEND_BANDAR_ABBAS_START"),
	messageEnd = LTGet("PG_MISSION_DEFEND_BANDAR_ABBAS_END"),
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
		for i,v in pairs(bandarforce) do
			for _,v2 in ipairs(v) do
				if Group.getByName(v2) then return true end
			end
		end
		
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
		not lname:find('delta') and not lname:find('bravo') and not lname:find('hotel')
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
		T = LT(T)
		local wp = WaypointList[resupplyTarget1] or ""
		return T:Format("SYRIA_DYNAMIC_RESUPPLY_TITLE", resupplyTarget1, wp)
	end,
	description = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_RESUPPLY_DESC", resupplyTarget1)
	end,
	messageStart = nil,
	messageEnd = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_RESUPPLY_END", resupplyTarget1)
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
		T = LT(T)
		local wp = WaypointList[resupplyTarget2] or ""
		return T:Format("SYRIA_DYNAMIC_RESUPPLY_TITLE", resupplyTarget2, wp)
	end,
	description = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_RESUPPLY_DESC", resupplyTarget2)
	end,
	messageStart = nil,
	messageEnd = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_RESUPPLY_END", resupplyTarget2)
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
		T = LT(T)
		local wp = WaypointList[attackTarget1] or ""
		return T:Format("SYRIA_DYNAMIC_ATTACK_TITLE", attackTarget1, wp)
	end,
	description = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_ATTACK_DESC", attackTarget1)
	end,
	messageStart = nil,
	messageEnd = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_ATTACK_END", attackTarget1)
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
		T = LT(T)
		local wp = WaypointList[attackTarget2] or ""
		return T:Format("SYRIA_DYNAMIC_ATTACK_TITLE", attackTarget2, wp)
	end,
	description = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_ATTACK_DESC", attackTarget2)
	end,
	messageStart = nil,
	messageEnd = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_ATTACK_END", attackTarget2)
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
    messageStart = function(T)
        local wp = WaypointList[captureTarget] or ""
        return LT(T):Format("SYRIA_DYNAMIC_CAPTURE_START", captureTarget, wp)
    end,
    messageEnd = function(T)
        return LT(T):Format("SYRIA_DYNAMIC_CAPTURE_END", captureTarget) end,
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

---------------------------------------------------------------------
--                         RECON MISSION                           --
reconMissionTarget = nil
reconMissionWinner = nil
reconMissionCooldownUntil = 0
reconMissionCompleted = false
reconMissionCompletedTarget = nil

mc:trackMission({
	title = function(T)
		T = LT(T)
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return T:Get("SYRIA_DYNAMIC_RECON_TITLE_EMPTY") end
		local wp = WaypointList[target] or ""
		return T:Format("SYRIA_DYNAMIC_RECON_TITLE", target, wp)
	end,
	description = function(T)
		T = LT(T)
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return T:Get("SYRIA_DYNAMIC_RECON_DESC_EMPTY") end
		return T:Format("SYRIA_DYNAMIC_RECON_DESC", target)
	end,
	messageStart = function(T)
		T = LT(T)
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return T:Get("SYRIA_DYNAMIC_RECON_START_EMPTY") end
		local wp = WaypointList[target] or ""
		return T:Format("SYRIA_DYNAMIC_RECON_START", target, wp)
	end,
	messageEnd = function(T)
		T = LT(T)
		if reconMissionCompleted and reconMissionCompletedTarget and reconMissionWinner then
			return T:Format("SYRIA_DYNAMIC_RECON_END_BY", reconMissionCompletedTarget, reconMissionWinner)
		end
		if reconMissionCompletedTarget then
			return T:Format("SYRIA_DYNAMIC_RECON_END_TARGET", reconMissionCompletedTarget)
		end
		return T:Get("SYRIA_DYNAMIC_RECON_END")
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

function generateCaptureMission()
    if captureTarget ~= nil then return true end
    
    local validzones = {}
    for _, v in ipairs(bc.zones) do
        if v.active and v.side == 0 and (not v.NeutralAtStart or v.firstCaptureByRed) and
           not v.zone:lower():find("hidden", 1, true) and  not v.zone:lower():find("carrier", 1, true) then
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

---------------------------------------------------------------------
--                          CAP MISSION                            --

capMissionTarget = nil
capKillsByPlayer = {}
capTargetPlanes = 0
capWinner = nil
capMissionCooldownUntil = 0

mc:trackMission({
    title = LTGet("MISSION_CAP_TITLE"),
    description = function(T)
        T = LT(T)
        if not next(capKillsByPlayer) then
            return T:Format("MISSION_CAP_DESCRIPTION_EMPTY", capTargetPlanes)
        else
            local scoreboard = T:Get("MISSION_CAP_SCOREBOARD_HEADER")
            for playerName, kills in pairs(capKillsByPlayer) do
                scoreboard = scoreboard .. string.format("%s: %d\n", playerName, kills)
            end
            return T:Format("MISSION_CAP_DESCRIPTION_WITH_SCORE", capTargetPlanes, scoreboard)
        end
    end,
    messageStart = function(T)
        return LT(T):Format("MISSION_CAP_START", capTargetPlanes) end,
    messageEnd = LTGet("MISSION_CAP_END"),
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
	title = LTGet("MISSION_CAS_TITLE"),
	description = function(T)
		T = LT(T)
		if not next(casKillsByPlayer) then
			return T:Format("MISSION_CAS_DESCRIPTION_EMPTY", casTargetKills)
		else
			local scoreboard = T:Get("MISSION_CAP_SCOREBOARD_HEADER")
			for playerName, kills in pairs(casKillsByPlayer) do
				scoreboard = scoreboard..string.format('%s: %d\n', playerName, kills)
			end
			return T:Format("MISSION_CAS_DESCRIPTION_WITH_SCORE", casTargetKills, scoreboard)
		end
	end,
	messageStart = function(T)
		return LT(T):Format("MISSION_CAS_START", casTargetKills)
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
seadTarget = nil
function generateSEADMission()
    if seadTarget then return true end
    local attackAnchors = _getAttackAnchorZones()
    if #attackAnchors == 0 then return false end

    local function isSEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and (not zone.suspended)
           and (lname:find('sam') or lname:find('defence'))
           and (not isZoneUnderSEADMission or not isZoneUnderSEADMission(zone.zone))
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
    title = function(T) return LT(T):Format("MISSION_SEAD_TITLE", seadTarget) end,
    description = function(T) return LT(T):Format("MISSION_SEAD_DESCRIPTION", seadTarget) end,
    messageStart = function(T) return LT(T):Format("MISSION_SEAD_START", seadTarget) end,
    messageEnd = function(T) return LT(T):Get("MISSION_SEAD_END") end,
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
        return zone.side == 1 and zone.active and (lname:find('sam') or lname:find('defence'))
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
    messageStart = function(T) return LT(T):Format("MISSION_DEAD_START", deadTarget) end,
    messageEnd = function(T) return LT(T):Get("MISSION_DEAD_END") end,
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
----------------------- FLAGS --------------------------


buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end

----------------------- END OF FLAGS --------------------------

airbaseStatics = {
	["Al Khatim"] = {"Khatimammo", "Khatimfuel", "Khatimtent1", "Khatimtent2", "Khatimtent3", "Khatimtent4", "Khatimcommand", "Khatimwind"},
    ["Al Huti"] = {"Hutiammo", "FHutifuel", "Hutitent1", "Hutitent2", "Hutitent3", "Hutitent4", "Huticommand", "Hutiwind"},
    ["Al Dahid"] = {"Dahidammo", "Dahidfuel", "Dahidtent1", "Dahidtent2", "Dahidtent3", "Dahidtent4", "Dahidcenter", "Dahidwind"},
    ["Radio Tower"] = {"Radioammo", "Radiofuel", "Radiotent1", "Radiotent2", "Radiotent3", "Radiotent4", "Radiocenter", "Radiowind"},
    ["FARP Delta"] = {"Deltaoammo", "Deltaofuel", "Deltatent1", "Deltatent2", "Deltatent3", "Deltatent4", "Deltaommand", "Deltawind"},
    ["Factory"] = {"Factoryammo", "Factoryfuel", "Factorytent1", "Factorytent2", "Factorytent3", "Factorytent4", "Factorycomand", "Factorywind"},
    ["FARP Golf"] = {"Farpgolfammo", "Farpgolffuel", "Farpgolftent1", "Farpgolftent2", "Farpgolftent3", "Farpgolftent4", "Farpgolfcommand", "Farpgolfwind"},
    ["FARP Echo"] = {"FarpEchoammo", "FarpEchofuel", "FarpEchotent1", "FarpEchotent2", "FarpEchotent3", "FarpEchotent4", "FarpEchocommand", "FarpEchowind"},
    ["FARP Sunny"] = {"Sunnyammo", "Sunnyfuel", "Sunnytent1", "Sunnytent2", "Sunnytent3", "Sunnytent4", "Sunnycommand", "Sunnywind"},
    ["Ramp-Kongo"] = {"Kongoammo", "Kongofuel", "Kongotent1", "Kongotent2", "Kongotent3", "Kongotent4", "Kongocommand", "Kongowind"},
    ["Foxtrot"] = {"Foxtrotammo", "Foxtrotfuel", "Foxtrottent1", "Foxtrottent2", "Foxtrottent3", "Foxtrottent4", "Foxtrotcommand", "Foxtrotwind"},
    ["FARP Khamets"] = {"Khametsammo", "Khametsfuel", "Khametstent1", "Khametstent2", "Khametstent3", "Khametstent4", "Khametscommand", "Khametswind"},
    ["Samathe"] = {"Samatheammo", "Samathefuel", "Samathetent1", "Samathetent2", "Samathetent3", "Samathetent4", "Samathecommand", "Samathewind"},
	["Paregaan"] = {"Paregaanammo", "Paregaanfuel", "Paregaantent1", "Paregaantent2", "Paregaantent3", "Paregaantent4", "Paregaancommand", "Paregaanwind"},
	["Moradi"] = {"Moradiammo", "Moradifuel", "Moraditent1", "Moraditent2", "Moraditent3", "Moraditent4", "Moradicommand", "Moradiwind"},
	["Charlie"] = {"Charlieammo", "Charliefuel", "Charlietent1", "Charlietent2", "Charlietent3", "Charlietent4", "Charliecommand", "Charliewind"},
	["Alpha"] = {"Alphaammo", "Alphafuel", "Alphatent1", "Alphatent2", "Alphatent3", "Alphatent4", "Alphacommand", "Alphawind"},

}

env.info("ZoneSetup: is completed!")
