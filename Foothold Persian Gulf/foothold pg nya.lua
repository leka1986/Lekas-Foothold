env.info("ZoneSetup: is loading.")

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
        red = {"Red Carrier Group Fixed", "Red Carrier Group Fixed 2", "Red Carrier Group Fixed 3"}
    },
    airfield = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor", "bluePATRIOT" },
        red = { "Enemy ground forces","Red SAM Dog Ear AAA", "Red Armour Group", "Red Armour Group 2", "Red SAM SA-3", "Red SAM SA-6", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2"}
    },
    Lengeh = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor", "bluePATRIOT" },
        red = { "Enemy ground forces","Red SAM Dog Ear AAA", "Red Armour Group", "Red Armour Group 2", "Red SAM SA-3", "Red SAM SA-6", "Red SAM Dog Ear SA-15", "Red SAM SHORAD Pantsir S1"}
    },
    Sharjah = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor"},
        red = { "Enemy ground forces","Red SAM Dog Ear AAA", "Red Armour Group", "Sharjah HQ", "Red SAM SA-3","Red SAM AAA 2", "Red SAM SA-6", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2"}
    },
	Bandarabbas = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor", "bluePD1" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Red Armour Group", "Red SAM SHORAD Tor M2 Fixed Bandar","Red SAM SHORAD Pantsir S1 Fixed Bandar", "Red Armour Group 2","MLRS M142 Himars Fixed", "Red SAM SA-6 Fixed Bandar", "Red SAM SA-11 Fixed Bandar" }
    },
    Minhad = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Red Armour Group", "Al Minhad Command Center", "Red Armour Group 2", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2","Red SAM SA-6" }
    },
    farp = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Red SAM Dog Ear SA-19", "Red Armour Group 2", "Red SAM SHORAD Tor M2", "Red SAM SHORAD Pantsir S1","Red Armour Group", "Red SAM SA-3"}
    },
	Khasab = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Red SAM Dog Ear AAA", "Red Armour Group 2", "Red SAM SHORAD Tor M2", "Red SAM SHORAD Pantsir S1", "Red Armour Group", "Red SAM SA-3 Khasab Fixed"}
    },
    Golf = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA","Golf Gaurdhouse", "Red Armour Group 2", "Red SAM SHORAD Pantsir S1", "Red SAM SHORAD SA-19 2","Golf Command Center", "Red SAM SHORAD Tor M2","Golf Troops acamady", "Red Armour Group", "Red SAM SA-3", "Golf Warehouse", "Golf Warehouse 2" }
    },
	farpOilFields = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Red SAM Dog Ear SA-19", "Red Armour Group 2", "Red SAM SHORAD SA-19 2","Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2","Red Armour Group", "Red SAM SA-3","Oil Refinery Factory", "Oil Refinery Factory-2", 
			"Oil Tank", "Oil Tank-2", "Oil Tank-3", "Oil Tank-4" }
    },
	kishFixed = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2", "bluePD1" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Red Armour Group 2", "Red SAM SHORAD Fixed Kish", "Red Armour Group", "Red SAM SA-6 Fixed Kish" }
    },	
	farpkongo = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = {"Red Armour Group", "Red SAM Dog Ear AAA", "Ramp Kongo Solider house","Red SAM AAA 2", "Red SAM Dog Ear SA-8", "Red SAM SHORAD SA-8 2","Ramp Kongo Warehouse", "Red SAM SHORAD Fixed Kongo", "Ramp Kongo Warehouse 2", "Red SAM SA-3 Fixed Kongo", "Ramp Kongo Troops academy"}
    },
    farp2 = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Red SAM Dog Ear SA-8","Red SAM Dog Ear AAA", "Red Armour Group", "Red SAM Dog Ear SA-19", "Red Armour Group 2", "Red SAM SHORAD SA-19 2","Red SAM Dog Ear SA-15"}
    },
    farp3 = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Enemy ground forces","Red SAM Dog Ear AAA", "Red Armour Group","Red SAM Dog Ear SA-19", "Red SAM SHORAD SA-19 2","Red SAM AAA 3", "Red SAM AAA 4", "Red Armour Group 2", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2"}
    },
    Khatim = {
        blue = { "blueInfantry", "blueArmor", "bluePD 2" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Khatim Fuel tanks", "Red Armour Group", "Khatim Fuel tanks 2", "Red SAM Dog Ear SA-19", "Red SAM AAA 3","Khatim Fuel tanks 3", "Red SAM AAA 4", "Red SAM SHORAD SA-15 2"}
    },
    regularzoneLavan = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Red Armour Group", "Red SAM Dog Ear SA-8", "Red SAM SHORAD SA-8 2","Red SAM Dog Ear SA-15", "Red Armour Group 2", "Red SAM SHORAD SA-15 2"}
    },
	regularzone = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Red Armour Group", "Red SAM AAA 3","Red Armour Group 3", "Red SAM SHORAD SA-8 2", "Red Armour Group 2", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2"}
    },
	Charlie = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Red SAM Dog Ear AAA","Charlie Tent 1", "Red Armour Group", "Charlie Command Center","Charlie Tent 2","Charlie Tent 3", "Red SAM SHORAD SA-8 2", "Red Armour Group 2", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2"}
    },
	RadioTower = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red Armour Group", "Radio Tower Command Center", "Red SAM AAA 2", "Red SAM Dog Ear SA-8", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2"}
    },
	AlAin = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Al Ain Command Center", "Red Armour Group", "Al Ain Command building", "Red SAM Dog Ear SA-8", "Red SAM SHORAD SA-8 2","Al Ain Command building 2", "Red Armour Group 2", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2"}
    },
	regularzoneFactory = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Red Armour Group", "Red SAM Dog Ear SA-8", "Red SAM SHORAD SA-8 2","Red SAM Dog Ear SA-15", "Red Armour Group 2", "Red SAM SHORAD SA-15 2","Factory Compound",
	"Factory Compound-2", "Factory Hanger", "Factory Hanger-2", "Factory Hanger-3", "Factory Shipping Containers", "Factory Shipping Containers-2",
	"Factory Shipping Containers-3", "Factory Shipping Containers-4"}
    },
	regularzoneAFB = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = {"Red SAM Dog Ear AAA", "Red Armour Group", "Red SAM Dog Ear SA-8", "Red SAM SHORAD SA-8 2","Red SAM Dog Ear SA-15", "Red Armour Group 2", "Red SAM SHORAD SA-15 2","Tunb island SilkWorm Fixed","Tunb Island Communication Tower" }
    },
	Foxtrot = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Red SAM Dog Ear SA-8", "Red Armour Group 2", "Red SAM SHORAD SA-8 2","Foxtrot OutPost", "Red Armour Group", "Red SAM SHORAD Pantsir S1", "Foxtrot Command Center"}
    },
	regularzoneParegaan = {
        blue = { "blueInfantry", "blueArmor", "bSamIR" },
        red = { "Red Armour Group", "Red SAM Dog Ear AAA", "Red SAM SHORAD Pantsir S1 Fixed Paregaan", "Red Armour Group 2", "Red SAM SA-11 Fixed Paregaan","Red SAM SHORAD Tor M2 Fixed Paregaan" }
    },
    specialSAMSamathe = {
        blue = { "blueInfantry", "bSamIR", "blueInfantry", "blueInfantry", "bSamBig" },
        red = { "Red SAM Dog Ear AAA", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2","Red SAM AAA 2", "Samathe Fuel Depo" ,"Samathe Fuel Depo-2", "Enemy ground forces","Samathe HQ Building", "Samathe Factory", "Red SAM SA-3", "Red SAM SA-6" }
    },
    specialSAM2 = {
        blue = { "blueInfantry", "bSamIR", "blueInfantry", "blueInfantry", "bSamBig" },
        red = { "Red SAM AAA Fixed samsite", "Red Armour Group 2", "Red SAM SHORAD Tor M2 Fixed samsite", "Red Armour Group", "Red SAM SA-3 Fixed Samsite", "Red SAM SA-2 Fixed Samsite" }
    },
	specialSAM2fixed = {
        blue = {},
        red = { "Red SAM SA-11 Fixed","Red SAM SHORAD SA-19 Fixed", "Red SAM SHORAD SA-15 Fixed", "Red SAM AAA Fixed 2" }
    },
	specialTunb = {
        blue = {},
        red = { "Red SAM AAA Fixed Tunb Defence", "Red SAM SHORAD SA-19 Fixed Tunb Defence", "Red SAM SA-6 Fixed Tunb Defence"}
    },
    mission2 = {
        blue = { "blueInfantry", "blueArmor" },
        red = { "Enemy ground forces", "Red SAM Dog Ear AAA", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2","Red Armour Group 2", "Red SAM Dog Ear SA-19" ,"Fuel Depo", "Fuel Depo-1", "Fuel Depo-2", "Fuel Depo-3", 
		"Fuel Depo-4", "Fuel Depo-5", "Fuel Depo-6", "Fuel Depo-7", "Fuel Depo Factory", "Fuel Depo Factory-2"}
    },
	InsurgentCampmission = {
        blue = {},
        red = { "InsurgentCamp Fixed Group", "InsurgentCamp Fixed Group2", "InsurgentCamp Fixed Group3Convoy", "Red SAM SHORAD Fixed Group4" }
    },
    mission3 = {
        blue = {},
        red = { "Enemy Task forces", "Red SAM Dog Ear AAA", "Red Armour Group", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2","Red SAM Dog Ear SA-19", "Red Armour Group 2", "Red SAM SHORAD SA-19 2","ChemSite FactoryBuilding", "ChemSite Tank", "ChemSite Tank 2", "ChemSite FactoryBuilding 2" }
    },
    mission4 = {
        blue = {},
        red = { "Enemy Task forces", "Red Armour Group", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2","Red SAM SA-10", "Secrect Tech Waste", "Red Armour Group 2", "Secrect Tech Building", "Secrect Tech Building 2"}
    },
    mission5Fixed = {
        blue = { "blueInfantry", "blueArmor" },
        red = { "TankFactory Fixed Group 1", "TankFactory Fixed Group 2", "Red SAM AAA Fixed Group 3", "Red SAM SHORAD SA-19 Fixed TankFacotory", "redInfantry Fixed TankFacotory", "Tank Factory main",
		 "Tank Factory secondary", "Red SAM AAA 3 Fixed TankFactory", "Red SAM AAA 4 Fixed TankFactory" }
    },
	KhasabDefencefixed = {
        blue = { "blueInfantry", "blueArmor" },
        red = { "Red SAM SHORAD SA-15 Fixed Khasab", "Red SAM SA-6 Khasab Fixed" }
    },
	 
	SharjahDefencefixed = {
        blue = { "blueInfantry", "blueArmor" },
        red = { "Red SAM AAA Fixed Sharjah Defence", "Red SAM Dog Ear SA-15", "Red SAM Dog Ear SA-19", "Red SAM Dog Ear SA-8","Red SAM SA-6 Fixed Sharjah" }
    },
    specialLar = {
        blue = { "blueInfantry", "bSamIR", "bluePD", "bluePD1", "bSamBig", "bSamFinal" },
        red = { "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2","Red SAM Dog Ear AAA", "Red Armour Group 2", "Red SAM SA-6", "Red Armour Group", "Red SAM SA-6" }
    },
	
	specialLarSAM = {
		blue = {},
        red = {"Red SAM SA-11 LAR Fixed", "Red SAM Dog Ear Tor M2 LAR Fixed 2", "Red SAM SHORAD SA-15 LAR Fixed", "Red SAM Dog Ear AAA LAR Fixed", "Red SAM SHORAD Pantsir S1 LAR Fixed"}
    },
    convoy = {
        blue = { "blueInfantry" },
        red = { "Enemy ground forces","Red SAM Dog Ear AAA", "Red Armour Group 2", "Red SAM Dog Ear SA-19", "Red SAM SHORAD SA-19 2","Red Armour Group", "Red SAM Dog Ear SA-8" }
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
        red = { "Hiddengroup-Fixed1", "Hiddengroup-Fixed2", "Hiddengroup-Fixed3", "Hiddengroup-Fixed4",
				"Hiddengroup-Fixed5", "Hiddengroup-Fixed6"}
    },
	Hidden4Group = {
        blue = {},
        red = { "HiddenGroup4-Fixed-1", "HiddenGroup4-Fixed-2", "HiddenGroup4-Fixed-3", "HiddenGroup4-Fixed-4",
				"HiddenGroup4-Fixed-5", "HiddenGroup4-Fixed-6" , "HiddenGroup4-Fixed-7", "HiddenGroup4-Fixed-8",
				"HiddenGroup4-Fixed-9", "HiddenGroup4-Fixed-10", "HiddenGroup4-Fixed-11","HiddenGroup4-Fixed-12",
				"HiddenGroup4-Fixed-13","HiddenGroup4-Fixed-14"}
    }, 
	Hidden1GroupEWR = {
        blue = {},
        red = { "Red EWR LAR Fixed", "Red EWR BandarEast Fixed", "Red EWR Larak Fixed", "Red EWR Larak Fixed 2", "Red EWR Island Fixed", "Red EWR Larak Fixed -1", 
		"Red EWR BandarEast Fixed-1"}
    }
}

flavor = {
	aldhafra = 'WPT 1\nAl Dhafra',
	carrier = 'Carrier group',
	alain = 'WPT 3\nAin means eyes Al Ain is THE eyes', 
	alhuti = 'WPT 4\n Its a city name close by',
	minhad = 'WPT 5\nHere can we Land',
	sharjah = 'WPT 6\nCloser to the AO',
	fujairah = 'WPT 8\nNice view',
	khaimah = 'WPT 9\nKhaimah means Tent',
	alpha = 'WPT 11\nDefensive position next to the village of Al Ima',
	khasab = 'WPT 13\nAirport of Khasab.\nWill let us launch helicopter attacks from a bit closer to the action.',
	redcarrier = 'WPT 14\n Naval Patrol area for the Iraniens and the Russians.\nTake them out. Our Naval group will be there after.',
	charlie = 'WPT 10\nDefensive position next to an old command bunker.\nWill provide allied air patrol to help capture Bravo',
	convoy = 'WPT 12\nSupply convoy detained southwest of Bravo.\nKeep damage to the trucks to a minimum while liberating this area.\nWe could really use the supplies.',
	bandarabbas = 'WPT 15\nAirbase next to the city of Bandar Abbas.\nCapturing it will provide us with valuable aircraft to use for our cause.',
	radio = 'WPT 16\nCommand bunker on the outskirts of Minab.\nIf we capture it, we can launch CAS from the nearby airport\nto get some much needed intel on the enemy.',
	oilfields = 'WPT 18\nOil extraction and Refinery west of BandarAbbas.\nCapture it to get a steady stream of income, or just destroy it to put a hole in the enemy wallet.',
	dehbarez = 'WPT 17\nDefensive position NorthEast of Minab',
	paregaan = 'WPT 19\nDefensive position NorthEast of Factory',
	khamets = 'WPT 21\nDefensive position NorthWest of Factory',
	bandarlengeh = 'WPT 28\nDefensive arifield with quick respons for sea intercepts',
	samathe = 'WPT 20\nDefensive position in good cover by the mountains',
	echo =  'WPT 24\nFARP next to the city of Krasnodar.\nCapturing it will let us operate our helicopters in the area.',
	sunny = 'WPT 25\nSunny is here somewhere building the never ending pit.',
	rampkongo = 'WPT 26\nLegend says its a place where poeple pretend they fly.',
	delta = 'WPT 23\nDefensive position out in the middle of nowhere',
	factory = 'WPT 22\nWeapon factory northwest of Bandar Abbas.\nWe can use it to resupply nearby bases.\nIt will also provide a steady stream of income.',
	qeshmisland = 'WPT 14\nHome to an old SA-2 site.\nIf we capture it, we might be able to get some use out of it.',
	foxtrot = 'WPT 30\nDefensive position with a nice view of the camel races',
	lar = 'WPT 31\nAirbase next to the city of Lar.\nThe home base of our enemy. Capture it to deprive them of their most valuable asset.',
	kish = 'WPT 29\nThere is a moving Red SAM SHORAD convoy around the island.\nThis island is guarded by SA-6 and SA-3',
	alkhatim = 'WPT 2\nit was not meant to be.',
	dahid = 'WPT 7\nit was not meant to be.',
	golf = 'WPT 27\nAnother fucking FARP.',
	chemsite = 'WPT \nThanks to the locals who have identified the smell and called us. We also need to destroy the factory',
	insurgentcamp = 'WPT \nInsurgent have taken over this smal city. Help them!.',
	secrettechfacility = 'WPT \nThey are making missiles to destroy our democracy! WATCH OUT, THE SITE IS HEAVILY GUARDED.',
	fueldepo = 'WPT \nYou got Fuel? we got democracy.',
	tankfactory = 'WPT \nIts where they build them.',
	tunbisland = 'WPT \nA little Island.',
	abumusa = 'WPT \nGood location to have.',
	sirri = 'WPT \nNothing to do with Siri!',
	lavan = 'WPT \nThis Island will be a good place to have from a strategic point of view.',
	khasabdefence = 'WPT \n This offsite location is a defence site defending Bravo / Khassab.',
	sharjadefence = 'WPT \n This offsite location is a defence site defending Sharjah.',
	qeshmislanddefence = 'WPT \n This offsite location is a defence site defending Qeshm Island.',
	
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
	['Red Carrier'] = ' (14)',
    ["Qeshm Island"] = ' (15)',
    BandarAbbas = ' (16)',
    ["Radio Tower"] = ' (17)',
    Dehbarez = ' (18)',
    ["Oil Fields"] = ' (19)',
    Paregaan = ' (20)',
    Samathe = ' (21)',
    Khamets = ' (22)',
    Factory = ' (23)',
    Delta = ' (24)',
    Echo = ' (25)',
    Sunny = ' (26)',
    ["Ramp-Kongo"] = ' (27)',
    Golf = ' (28)',
    ["Bandar Lengeh"] = ' (29)',
	Moradi = ' (30)',
    ["Tunb Island AFB"] = ' (31)',
    ["Abu Musa Island"] = ' (32)',
    ["Sirri Island"] = ' (33)',
    ["Kish intl"] = ' (34)',
    ["Lavan Island"] = ' (35)',
    Foxtrot = ' (36)',
    Lar = ' (37)'
}
local filepath = (Era == 'Coldwar') and 'foothold_persiangulf_Coldwar.lua' or 'foothold_persiangulf.lua'
if lfs then 
	local dir = lfs.writedir()..'Missions/Saves/'
	lfs.mkdir(dir)
	filepath = dir..filepath
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
}

local function deepSwap(t,s)
	for k, v in pairs(t) do
		if type(v) == 'table' then
			deepSwap(v, s)
		elseif s[v] ~= nil then
			if s[v] == '' then
				t[k] = nil
			else
				t[k] = s[v]
			end
		end
	end
end

if Era == 'Coldwar' then
	deepSwap(upgrades,cwSwap)
end

local SamSwap = {

	['Red SAM SA-10'] = 'Red SAM SA-2',
	['Red SAM SA-11 Fixed Paregaan'] = 'Red SAM SA-2 Fixed Paregaan',
	['Red SAM SA-11 Fixed'] = 'Red SAM SA-2 Fixed',
	['Red SAM SA-11 Fixed Bandar'] = 'Red SAM SA-2 Fixed Bandar',
	['Red SAM Dog Ear SA-15'] = 'Red SAM Dog Ear SA-8',
	['Red SAM SHORAD SA-15 2'] = 'Red SAM SHORAD SA-8 2',
	['Red SAM SHORAD Pantsir S1 Fixed Paregaan'] = 'Red SAM SHORAD SA-8 Fixed Paregaan',
	['Red SAM SHORAD SA-15 Fixed samsite'] = 'Red SAM SHORAD SA-8 Fixed samsite',
	['Red SAM SHORAD SA-15 Fixed'] = 'Red SAM SHORAD SA-8 Fixed',
	['Red SAM SA-11 LAR Fixed'] = 'Red SAM SA-2 LAR Fixed',
	['Red SAM SHORAD Pantsir S1 LAR Fixed 2'] = 'Red SAM SHORAD SA-8 LAR Fixed 2',
	['Red SAM SHORAD SA-15 LAR Fixed'] = 'Red SAM SHORAD SA-8 LAR Fixed',
	['Red SAM Dog Ear SA-8']  = {'Red SAM AAA 4','Red SAM AAA 3'},
	['Red SAM SHORAD Tor M2']  = {'Red SAM Dog Ear SA-8'},
	['Red SAM SHORAD Pantsir S1']  = {'Red SAM Dog Ear SA-19'},
	['Red SAM SHORAD SA-15 Fixed Khasab']  = {'Red SAM SHORAD SA-8 Fixed Khasab'},
	
}

local function deepSwapAgain(t,s)
	for k,v in pairs(t) do
		if type(v)=='table' then
			deepSwapAgain(v,s)
		elseif s[v] then
			if type(s[v])=='table' then
				t[k]=s[v][1]
				for i=2,#s[v] do
					table.insert(t,s[v][i])
				end
			else
				t[k]=s[v]
			end
		end
	end
end

if NoSA10AndSA11 == true then
	deepSwapAgain(upgrades,SamSwap)
end

bc = BattleCommander:new(filepath, 10, 60)
Hunt = true

zones = {
	redcarrier = ZoneCommander:new({zone='Red Carrier', side=1, level=25, upgrades=upgrades.reDcarrier, crates={}, flavorText=flavor.redcarrier}),
    aldhafra = ZoneCommander:new({zone='Al Dhafra', side=2, level=8, upgrades=upgrades.airfield, crates={}, flavorText=flavor.aldhafra}),
    alhuti = ZoneCommander:new({zone='Al Huti', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.alhuti}),
    alain = ZoneCommander:new({zone='Al Ain', side=1, level=25, upgrades=upgrades.AlAin, crates={}, flavorText=flavor.alain}),
    fujairah = ZoneCommander:new({zone='Fujairah Intl', side=1, level=25, upgrades=upgrades.farp, crates={}, flavorText=flavor.fujairah}),
    minhad = ZoneCommander:new({zone='Al Minhad AFB', side=1, level=25, upgrades=upgrades.Minhad, crates={}, flavorText=flavor.minhad}),
    sharjah = ZoneCommander:new({zone='Sharjah', side=1, level=25, upgrades=upgrades.Sharjah, crates={}, flavorText=flavor.sharjah}),
    khaimah = ZoneCommander:new({zone='Ras Al Khaimah', side=1, level=25, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.khaimah}),
    carrier = ZoneCommander:new({zone='Carrier Group', side=2, level=25, upgrades=upgrades.carrier, crates={}, flavorText=flavor.carrier}),
    alpha = ZoneCommander:new({zone='Alpha', side=1, level=25, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.alpha}),
    khasab = ZoneCommander:new({zone='Khasab', side=1, level=25, upgrades=upgrades.Khasab, crates={}, flavorText=flavor.khasab}),
    charlie = ZoneCommander:new({zone='Charlie', side=1, level=25, upgrades=upgrades.Charlie, crates={}, flavorText=flavor.charlie}),
    convoy = ZoneCommander:new({zone='Convoy', side=1, level=25, upgrades=upgrades.convoy, crates={}, flavorText=flavor.convoy}),
    bandarabbas = ZoneCommander:new({zone='BandarAbbas', side=1, level=25, upgrades=upgrades.Bandarabbas, crates={}, flavorText=flavor.bandarabbas}),
    radio = ZoneCommander:new({zone='Radio Tower', side=1, level=25, upgrades=upgrades.RadioTower, crates={}, flavorText=flavor.radio}),
    dehbarez = ZoneCommander:new({zone='Dehbarez', side=1, level=25, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.dehbarez}),
    abumusa = ZoneCommander:new({zone='Abu Musa Island', side=1, level=25, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.abumusa}),
    sirri = ZoneCommander:new({zone='Sirri Island', side=1, level=25, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.sirri}),
    tunbisland = ZoneCommander:new({zone='Tunb Island AFB', side=1, level=25, upgrades=upgrades.regularzoneAFB, crates={}, flavorText=flavor.tunbisland}),
    moradi = ZoneCommander:new({zone='Moradi', side=1, level=25, upgrades=upgrades.farp, crates={}, flavorText=flavor.moradi}),
    lavan = ZoneCommander:new({zone='Lavan Island', side=1, level=25, upgrades=upgrades.regularzoneLavan, crates={}, flavorText=flavor.lavan}),
   
    bandarlengeh = ZoneCommander:new({zone='Bandar Lengeh', side=1, level=25, upgrades=upgrades.Lengeh, crates={}, flavorText=flavor.bandarlengeh}),
    delta = ZoneCommander:new({zone='Delta', side=1, level=25, upgrades=upgrades.farp, crates={}, flavorText=flavor.delta}),

	factory = ZoneCommander:new({zone='Factory', side=1, level=20, upgrades=upgrades.regularzoneFactory, crates={}, flavorText=flavor.factory, income=2}),
	golf = ZoneCommander:new({zone='Golf', side=1, level=20, upgrades=upgrades.Golf, crates={}, flavorText=flavor.golf}),
	oilfields = ZoneCommander:new({zone='Oil Fields', side=1, level=20, upgrades=upgrades.farpOilFields, crates={}, flavorText=flavor.oilfields, income=2}),
	foxtrot = ZoneCommander:new({zone='Foxtrot', side=1, level=20, upgrades=upgrades.Foxtrot, crates={}, flavorText=flavor.foxtrot}),
	samathe = ZoneCommander:new({zone='Samathe', side=1, level=20, upgrades=upgrades.specialSAMSamathe, crates={}, flavorText=flavor.samathe}),
	paregaan = ZoneCommander:new({zone='Paregaan', side=1, level=20, upgrades=upgrades.regularzoneParegaan, crates={}, flavorText=flavor.paregaan}),
	sunny = ZoneCommander:new({zone='Sunny', side=1, level=20, upgrades=upgrades.farp, crates={}, flavorText=flavor.sunny}),
	khamets = ZoneCommander:new({zone='Khamets', side=1, level=20, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.khamets}),
	rampkongo = ZoneCommander:new({zone='Ramp-Kongo', side=1, level=20, upgrades=upgrades.farpkongo, crates={}, flavorText=flavor.rampkongo}),
    lar = ZoneCommander:new({zone='Lar', side=1, level=20, upgrades=upgrades.specialLar, crates={}, flavorText=flavor.lar, income=2}),
	
	    
    qeshmisland = ZoneCommander:new({zone='Qeshm Island', side=1, level=15, upgrades=upgrades.specialSAM2, crates={}, flavorText=flavor.qeshmisland}),
    echo = ZoneCommander:new({zone='Echo', side=1, level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.echo}),

	
    kish = ZoneCommander:new({zone='Kish intl', side=1, level=25, upgrades=upgrades.kishFixed, crates={}, flavorText=flavor.kish}),
    alkhatim = ZoneCommander:new({zone='Al Khatim', side=1, level=20, upgrades=upgrades.Khatim, crates={}, flavorText=flavor.alkhatim}),
    dahid = ZoneCommander:new({zone='Al Dahid', side=1, level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.dahid}),
    insurgentcamp = ZoneCommander:new({zone='InsurgentCamp', side=1, level=25, upgrades=upgrades.InsurgentCampmission, crates={}, flavorText=flavor.insurgentcamp}),
    chemsite = ZoneCommander:new({zone='ChemSite', side=1, level=25, upgrades=upgrades.mission3, crates={}, flavorText=flavor.ChemSite}),
    secrettechfacility = ZoneCommander:new({zone='SecretTechFacility', side=1, level=15, upgrades=upgrades.mission4, crates={}, flavorText=flavor.secrettechfacility}),
    fueldepo = ZoneCommander:new({zone='Fuel Depo', side=1, level=25, upgrades=upgrades.mission2, crates={}, flavorText=flavor.fueldepo}),
    tankfactory = ZoneCommander:new({zone='TankFactory', side=1, level=25, upgrades=upgrades.mission5Fixed, crates={}, flavorText=flavor.tankfactory}),
	
	khasabdefence = ZoneCommander:new({zone='Khasab-Defence', side=1, level=25, upgrades=upgrades.KhasabDefencefixed, crates={}, flavorText=flavor.khasabdefence}),
	sharjadefence = ZoneCommander:new({zone='Sharjah-Defence', side=1, level=25, upgrades=upgrades.SharjahDefencefixed, crates={}, flavorText=flavor.sharjadefence}),
	lardefence = ZoneCommander:new({zone='Lar-Defence', side=1, level=25, upgrades=upgrades.specialLarSAM, crates={}, flavorText=flavor.lardefence}),
	qeshmislanddefence = ZoneCommander:new({zone='Qeshm-Island-Defence', side=1, level=25, upgrades=upgrades.specialSAM2fixed, crates={}, flavorText=flavor.qeshmislanddefence}),
	tunbdefence = ZoneCommander:new({zone='Tunb Defence', side=1, level=25, upgrades=upgrades.specialTunb, crates={}, flavorText=flavor.tunbdefence}),

	hidden = ZoneCommander:new({zone='Hidden', side=1, level=8, upgrades=upgrades.HiddenGroup, crates={}, flavorText=flavor.hidden}),
	hiddenewrnetwork = ZoneCommander:new({zone='Hidden1', side=1, level=8, upgrades=upgrades.Hidden1GroupEWR, crates={}, flavorText=flavor.hiddenewrnetwork}),
	hiddenminhadmission = ZoneCommander:new({zone='HiddenMinhadMission', side=0, level=20, upgrades=upgrades.HiddenMinhadMission, crates={}, flavorText=flavor.hiddenminhadmission}),
	hiddensharjahmission = ZoneCommander:new({zone='HiddenSharjahMission', side=0, level=20, upgrades=upgrades.HiddenSharjahMission, crates={}, flavorText=flavor.hiddensharjahmission}),
	hiddenkhaimahmission = ZoneCommander:new({zone='HiddenKhaimahMission', side=0, level=20, upgrades=upgrades.HiddenKhaimahMission, crates={}, flavorText=flavor.hiddenkhaimahmission}),
	hidden2 = ZoneCommander:new({zone='Hidden2', side=1, level=20, upgrades=upgrades.Hidden2Group, crates={}, flavorText=flavor.hidden2,NeutralAtStart=true}),
	Hiddenmoradiqeshmmission = ZoneCommander:new({zone='HiddenMoradiQeshmMission', side=0, level=20, upgrades=upgrades.HiddenMoradiQeshmMission, crates={}, flavorText=flavor.Hiddenmoradiqeshmmission,NeutralAtStart=true}),
	hidden4 = ZoneCommander:new({zone='Hidden4', side=0, level=20, upgrades=upgrades.Hidden4Group, crates={}, flavorText=flavor.hidden4,NeutralAtStart=true}),

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
    CasPlaneTemplate = CasPlaneTemplate or {
        'RED_SU25_OneShip',
        'RED_SU25_TwoShip',
        'RED_SU25T_OneShip',
        'RED_SU25T_TwoShip',
        'RED_Mirage_F1BQ',
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
        'BLUE_UH-60A',
        'BLUE_UH-1H',
    }
    AttackConvoy = AttackConvoy or {
        "AttackConvoy CW 1",
        "AttackConvoy CW 2",
        "AttackConvoy CW 3",
        "AttackConvoy CW 4",
    }

	RunwayStrikePlaneTemplate = RunwayStrikePlaneTemplate or {
        "RED_MIG-27K",
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
        'BLUE_UH-60A',
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
}


zones.bandarabbas:addGroups({
	-- Attack missions
	GroupCommander:new({name='bandar-attack-Qeshm-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Qeshm Island', Altitude = 27000}),
	GroupCommander:new({name='bandar-attack-khasab-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Khasab', Altitude = 20000}),
	GroupCommander:new({name='bandar-attack-Qeshm-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Qeshm Island', Altitude = 18000}),
	GroupCommander:new({name='bandar-attack-factory-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Factory'}),
	GroupCommander:new({name='bandar-attack-khasab-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Khasab'}),
	GroupCommander:new({name='bandar-attack-oil-fields-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Oil Fields'}),
	GroupCommander:new({name='Bandar-attack-radio-tower-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Radio Tower'}),
	GroupCommander:new({name='Bandar-attack-Khasab', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Khasab', Altitude = 27000}),
	-- Patrol missions
	GroupCommander:new({name='bandar-patrol-Bandar-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='BandarAbbas', Altitude = 25000}),
	GroupCommander:new({name='bandar-patrol-Qeshm-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Qeshm Island', Altitude = 23000}),
	GroupCommander:new({name='bandar-patrol-khasab-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Khasab', Altitude = 15000}),
	GroupCommander:new({name='bandar-patrol-radio-tower', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Radio Tower', Altitude = 20000}),
	GroupCommander:new({name='bandar-patrol-Delta-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Delta', Altitude = 24000}),
	-- Supply missions
	GroupCommander:new({name='bandar-supply-Delta', mission='supply', template='HeloSupplyTemplate', targetzone='Delta'}),
	GroupCommander:new({name='bandar-supply-factory', mission='supply', template='HeloSupplyTemplate', targetzone='Factory'}),
	GroupCommander:new({name='bandar-supply-qeshm', mission='supply', template='HeloSupplyTemplate', targetzone='Qeshm Island'}),
	GroupCommander:new({name='bandar-supply-khasab', mission='supply', template='HeloSupplyTemplate', targetzone='Khasab'}),
	GroupCommander:new({name='bandar-supply-oilfields', mission='supply', template='HeloSupplyTemplate', targetzone='Oil Fields'}),
	GroupCommander:new({name='bandar-supply-radio-tower', mission='supply', template='HeloSupplyTemplate', targetzone='Radio Tower'}),
	-- Surface missions
	GroupCommander:new({name='bandar-attack-Delta', template='AttackConvoy', mission='attack', targetzone='Delta', type='surface'}),
	GroupCommander:new({name='bandar-attack-Oil Fields', template='AttackConvoy', mission='attack', targetzone='Oil Fields', type='surface'}),
})
zones.delta:addGroups({
	-- Supply missions
	GroupCommander:new({name='delta-supply-qeshm-island', mission='supply', template='HeloSupplyTemplate', targetzone='Qeshm Island'}),
	GroupCommander:new({name='Delta-supply-Bandar', mission='supply', template='HeloSupplyTemplate', targetzone='BandarAbbas'}),
	GroupCommander:new({name='delta-supply-sunny', mission='supply', template='HeloSupplyTemplate', targetzone='Sunny'}),
	GroupCommander:new({name='delta-supply-echo', mission='supply', template='HeloSupplyTemplate', targetzone='Echo'}),
	GroupCommander:new({name='Delta-supply-Factory', mission='supply', template='HeloSupplyTemplate', targetzone='Factory'}),
	
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
	GroupCommander:new({name='Echo-Attack-Delta-Cas', mission='attack', template='CasHeloTemplate', targetzone='Delta'}),
	-- Supply missions
	GroupCommander:new({name='Echo-Supply-qeshm-island', mission='supply', template='HeloSupplyTemplate', targetzone='Qeshm Island'}),
	GroupCommander:new({name='Echo-supply-Sunny', mission='supply', template='HeloSupplyTemplate', targetzone='Sunny'}),
	GroupCommander:new({name='Echo-Supply-Delta', mission='supply', template='HeloSupplyTemplate', targetzone='Delta'}),
	GroupCommander:new({name='Echo-Supply-Factory', mission='supply', template='HeloSupplyTemplate', targetzone='Factory'}),
	GroupCommander:new({name='Echo-Supply-golf', mission='supply', template='HeloSupplyTemplate', targetzone='Golf'}),
	-- Surface missions
	GroupCommander:new({name='Echo-attack-delta-art', mission='attack', targetzone='Delta', type='surface'}), -- Me template
	GroupCommander:new({name='Echo-attack-Delta', mission='attack', template='AttackConvoy', targetzone='Delta', type='surface'}),
})

zones.khasab:addGroups({
	-- Attack missions
	GroupCommander:new({name='khasab-attack-alpha-Cas', mission='attack', MissionType='CAS', template='CasHeloTemplate', targetzone='Alpha'}),
	GroupCommander:new({name='khasab-attack-charlie-Cas', mission='attack', MissionType='CAS', template='CasHeloTemplate', targetzone='Charlie'}),
	GroupCommander:new({name='khasab-attack-Khaima-Cap', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Ras Al Khaimah', Altitude = 26000}),
	GroupCommander:new({name='khasab-attack-Khaima-Sead', mission='attack', MissionType='SEAD', template='SeadPlaneTemplate', targetzone='Ras Al Khaimah', Altitude = 22000}),
	GroupCommander:new({name='Khasab-attack-Sharjah-Cap', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Sharjah', Altitude = 27000}),
	-- Patrol missions
	GroupCommander:new({name='khasab-patrol-khasab-Cap', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Khasab', Altitude = 26000}),
	GroupCommander:new({name='khasab-Patrol-Convoy-Cap', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Convoy', Altitude = 23000}),
	GroupCommander:new({name='khasab-Patrol-Alpha-Cap', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Alpha'}),
	GroupCommander:new({name='Khasab-Patrol-Khaimah-Cap', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Ras Al Khaimah', Altitude = 24000}),
	-- Supply missions
	GroupCommander:new({name='khasab-supply-charlie', mission='supply', template='HeloSupplyTemplate', targetzone='Charlie'}),
	GroupCommander:new({name='khasab-supply-bandar', mission='supply', template='HeloSupplyTemplate', targetzone='BandarAbbas'}),
	GroupCommander:new({name='khasab-supply-alpha', mission='supply', template='HeloSupplyTemplate', targetzone='Alpha'}),
	GroupCommander:new({name='khasab-supply-convoy', mission='supply', template='HeloSupplyTemplate', targetzone='Convoy'}),
	GroupCommander:new({name='khasab-supply-qeshm-island-blue', mission='supply', template='HeloSupplyTemplate', targetzone='Qeshm Island'}),
	GroupCommander:new({name='khasab-supply-qeshm-island', mission='supply', template='HeloSupplyTemplate', targetzone='Qeshm Island'}),
	GroupCommander:new({name='khasab-supply-Khasab-Defence', mission='supply', template='SupplyConvoy', targetzone='Khasab-Defence', type='surface'}),
	GroupCommander:new({name='Khasab-supply-Red-Carrier-Boat', mission='supply', targetzone='Red Carrier', type='surface'}),
})


zones.khaimah:addGroups({
	-- Attack missions
	GroupCommander:new({name='Khaimah-attack-Sharjah', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Sharjah', Altitude = 27000}),
	GroupCommander:new({name='Khaimah-attack-Sharjah-Cas', mission='attack', MissionType='CAS', template='CasPlaneTemplate', targetzone='Sharjah', Altitude = 18000}),
	GroupCommander:new({name='Khaimah-attack-Al Huti-Cas', mission='attack', MissionType='CAS', template='CasPlaneTemplate', targetzone='Al Huti', Altitude = 22000}),
	GroupCommander:new({name='Khaimah-attack-Al Huti-Sead', mission='attack', MissionType='SEAD', template='SeadPlaneTemplate', targetzone='Al Huti', Altitude = 25000}),
	-- Patrol missions
	GroupCommander:new({name='Khaimah-Patrol-Sharjah', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Sharjah', Altitude = 28000}),
	GroupCommander:new({name='Khaimah-Patrol-Al Minhad', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Al Minhad AFB', Altitude = 28000}),
	-- Supply missions
	GroupCommander:new({name='khaimah-Supply-Alpha', mission='supply', template='HeloSupplyTemplate', targetzone='Alpha'}),
	GroupCommander:new({name='khaimah-Supply-Charlie', mission='supply', template='HeloSupplyTemplate', targetzone='Charlie'}),
	GroupCommander:new({name='khaimah-Supply-khasab', mission='supply', template='HeloSupplyTemplate', targetzone='Khasab'}),
	GroupCommander:new({name='Khaimah-supply-Sharja', mission='supply', template='HeloSupplyTemplate', targetzone='Sharjah'}),
	GroupCommander:new({name='Khaimah-supply-fujairah', mission='supply', template='HeloSupplyTemplate', targetzone='Fujairah Intl'}),

	-- Surface missions
	GroupCommander:new({name='Khaimah-attack-Al Dahid', mission='attack', template='AttackConvoy', targetzone='Al Dahid', type='surface'}),
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

})
zones.carrier:addGroups({
	-- Attack missions
	GroupCommander:new({name='F18-CAP-carrier', mission='attack', MissioinType='CAP', targetzone='Red Carrier'}),
})
zones.factory:addGroups({
	-- Attack missions
	GroupCommander:new({name='factory-attack-lengeh',template='CasHeloTemplate', mission='attack',MissionType='CAS', targetzone='Bandar Lengeh'}),
	GroupCommander:new({name='factory-attack-sunny', template='CasHeloTemplate', mission='attack',MissionType='CAS', targetzone='Kish intl'}),
	-- Supply missions
	GroupCommander:new({name='factory-supply-delta', mission='supply',template='HeloSupplyTemplate', targetzone='Delta', spawnDelayFactor = 2}),
	GroupCommander:new({name='factory-supply-golf-blue', mission='supply', template='HeloSupplyTemplate', targetzone='Golf'}),
	GroupCommander:new({name='factory-supply-Golf', mission='supply', template='HeloSupplyTemplate', targetzone='Golf'}),
	GroupCommander:new({name='factory-supply-paregaan', mission='supply', template='HeloSupplyTemplate', targetzone='Paregaan'}),
	GroupCommander:new({name='factory-Supply-paragaan-blue', mission='supply', template='HeloSupplyTemplate', targetzone='Paregaan'}),
	GroupCommander:new({name='factory-supply-khamets-blue', mission='supply', template='HeloSupplyTemplate', targetzone='Khamets'}),
	GroupCommander:new({name='factory-supply-khamets', mission='supply', template='HeloSupplyTemplate', targetzone='Khamets'}),
	GroupCommander:new({name='factory-supply-sunny-blue', mission='supply', template='HeloSupplyTemplate', targetzone='Sunny'}),
	GroupCommander:new({name='factory-supply-sunny', mission='supply', template='HeloSupplyTemplate', targetzone='Sunny'}),
	-- Surface missions
	GroupCommander:new({name='factory-supply-BandarAbbas', mission='supply',template='SupplyConvoy', targetzone='BandarAbbas', type='surface'}),
	GroupCommander:new({name='factory-delta-supply', mission='supply', template='SupplyConvoy', targetzone='Delta', type='surface'}),
})

zones.golf:addGroups({
	-- Attack missions
	GroupCommander:new({name='Golf-Attack-Echo', mission='attack', template='CasHeloTemplate', targetzone='Echo'}),
	GroupCommander:new({name='Golf-Attack-Sunny', mission='attack', template='CasHeloTemplate', targetzone='Sunny'}),
	GroupCommander:new({name='golf-attack-foxtrot-Cas', mission='attack', template='CasHeloTemplate', targetzone='Foxtrot'}),
	GroupCommander:new({name='golf-attack-lar-Cas', mission='attack', template='CasHeloTemplate', targetzone='Lar'}),
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
	GroupCommander:new({name='lar-attack-sam-site-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Qeshm Island', Altitude = 24000}),
	GroupCommander:new({name='lar-attack-bandar-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='BandarAbbas', Altitude = 17000}),
	GroupCommander:new({name='lar-attack-radio-tower-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Radio Tower', Altitude = 18000}),
	GroupCommander:new({name='lar-attack-factory-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Factory', Altitude = 19000}),
	GroupCommander:new({name='Lar-attack-Foxtrot-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Foxtrot', Altitude = 27000}),
	GroupCommander:new({name='Lar-attack-BandarAbbas-Runway-strike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='BandarAbbas', Altitude = 27000}),
	-- Patrol missions
	GroupCommander:new({name='lar-patrol-golf-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Golf', Altitude = 28000}),
	GroupCommander:new({name='lar-patrol-delta-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Delta', Altitude = 26000}),
	GroupCommander:new({name='lar-patrol-factory-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Factory', Altitude = 29000}),
	GroupCommander:new({name='Shiraz-patrol-Lar-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Lar', Altitude = 25000}),
	GroupCommander:new({name='Shiraz-patrol-Lavan-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Lavan Island', Altitude = 23000}),
	GroupCommander:new({name='Shiraz-patrol-Sunny-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Sunny', Altitude = 26000}),
	GroupCommander:new({name='Lar-patrol-Foxtrot-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Foxtrot', Altitude = 22000}),
	GroupCommander:new({name='lar-patrol-ramp-kongo-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramp-Kongo', Altitude = 24000}),
	-- Supply missions
	GroupCommander:new({name='lar-supply-golf', mission='supply', template='HeloSupplyTemplate', targetzone='Golf'}),
	GroupCommander:new({name='lar-supply-foxtrot', mission='supply', template='HeloSupplyTemplate', targetzone='Foxtrot'}),
	GroupCommander:new({name='lar-supply-sunny', mission='supply', template='HeloSupplyTemplate', targetzone='Sunny'}),
	GroupCommander:new({name='lar-supply-ramp-kongo', mission='supply', template='HeloSupplyTemplate', targetzone='Ramp-Kongo'}),
	-- Surface missions
	GroupCommander:new({name='Lar-supply-lar-defence', mission='supply', template='AttackConvoy', targetzone='Lar-Defence', type='surface'}),
})
zones.rampkongo:addGroups({
	GroupCommander:new({name='ramp-kongo-supply-khamets', mission='supply',template='HeloSupplyTemplate', targetzone='Khamets'}),
})
zones.foxtrot:addGroups({
	-- Supply missions
	GroupCommander:new({name='Foxtrot-supply-kishi', mission='supply',template='HeloSupplyTemplate', targetzone='Kish intl'}),
	GroupCommander:new({name='Foxtrot-supply-Lar', mission='supply',template='HeloSupplyTemplate', targetzone='Lar'}),
	GroupCommander:new({name='Foxtrot-supply-lavan', mission='supply', targetzone='Lavan Island', spawnDelayFactor = 2}),
	-- Surface missions
	GroupCommander:new({name='foxtrot-golf-attack', mission='attack',template='AttackConvoy', targetzone='Golf', type='surface'}),
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
	GroupCommander:new({name='qeshm-island-attack-Khasab-Cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Khasab'}),
	GroupCommander:new({name='qeshm-island-attack-Khaima-Cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Ras Al Khaimah'}),
	GroupCommander:new({name='qeshm-island-attack-Khaima-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Ras Al Khaimah'}),
	-- Patrol missions
	GroupCommander:new({name='qeshm-island-Patrol-Khasab-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Khasab'}),
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
	GroupCommander:new({name='HiddenGroup-attack-Lar', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Lar', Redcondition = function() return end}),
	GroupCommander:new({name='HiddenGroup-attack-Ramp-Kongo', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Ramp-Kongo', Redcondition = function() return end}),
	GroupCommander:new({name='HiddenGroup-attack-Samathe', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Samathe', Redcondition = function() return end}),
	GroupCommander:new({name='Samathe-attack-Paregaan', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Paregaan', Redcondition = function() return end}),
	-- Patrol missions
	GroupCommander:new({name='HiddenGroup-patrol-Ramp-Kongo', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Ramp-Kongo', Redcondition = function() return zones.lar.wasBlue end}),
	GroupCommander:new({name='Samathe-patrol-Samathe', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Samathe'}),
	GroupCommander:new({name='Samathe-patrol-OilFields', mission='patrol', MissionType='CAP', template='CapPlaneTemplate', targetzone='Oil Fields'}),
	-- Supply missions
	GroupCommander:new({name='Samathe-supply-Paegaan', mission='supply', template='HeloSupplyTemplate', targetzone='Paregaan'}),
	-- Surface missions
	GroupCommander:new({name='Samathe-attack-Paegaan', mission='attack', template='AttackConvoy', targetzone='Khamets', type='surface'}),

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
	GroupCommander:new({name='lengeh-patrol-qeshm-island', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Qeshm Island'}),
	-- Supply missions
	GroupCommander:new({name='lengeh-supply-kish', mission='supply', template='HeloSupplyTemplate', targetzone='Kish intl'}),
	-- Surface missions
	GroupCommander:new({name='lengeh-supply-tunb-sea', mission='supply', targetzone='Tunb Island AFB', type='surface', condition = function() return not CustomFlags["StrikePort"] end}),
	GroupCommander:new({name='lengeh-supply-Musa-Sea', mission='supply', targetzone='Abu Musa Island', type='surface', condition = function() return not CustomFlags["StrikePort"] end}),
	GroupCommander:new({name='lengeh-supply-Sirri-sea', mission='supply', targetzone='Sirri Island', type='surface', condition = function() return not CustomFlags["StrikePort"] end}),
})

zones.aldhafra:addGroups({
	-- Supply missions
	GroupCommander:new({name='al-dhafra-support-huti', mission='supply', template='HeloSupplyTemplate', targetzone='Al Huti'}),
	GroupCommander:new({name='al-dhafra-support-al-ain', mission='supply', template='HeloSupplyTemplate', targetzone='Al Ain'}),
	GroupCommander:new({name='al-dhafra-support-al-khatim', mission='supply', template='HeloSupplyTemplate', targetzone='Al Khatim'}),
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
})

zones.alain:addGroups({
	-- Attack missions
	GroupCommander:new({name='Al-Ain-Attack-Al-Dhafra', mission='attack', template='AttackConvoy', targetzone='Al Dhafra', type='surface', spawnDelayFactor = 3, diceChance = 30}),
	-- Supply missions
	GroupCommander:new({name='Al-Ain-Supply-Al-Huti', mission='supply', template='HeloSupplyTemplate', targetzone='Al Huti'}),
	GroupCommander:new({name='Al-Ain-Supply-Al-Khatim', mission='supply', template='HeloSupplyTemplate', targetzone='Al Khatim'}),
})

zones.moradi:addGroups({
	-- Attack missions
	GroupCommander:new({name='Moradi-attack-Qeshm', mission='attack', template='AttackConvoy', targetzone='Qeshm Island',type='surface'}),
	-- Patrol missions
	GroupCommander:new({name='Moradi-patrol-tunb-island', mission='patrol', targetzone='Abu Musa Island', spawnDelayFactor = 3}),
})

zones.kish:addGroups({
	-- Attack missions
	GroupCommander:new({name='Kishi-attack-Abu-Musa', mission='attack', MissionType='CAP', template='CapPlaneTemplate', targetzone='Abu Musa Island'}),
	GroupCommander:new({name='Kishi-attack-qeshm-island-Sead', mission='attack',template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Qeshm Island'}),
	-- Patrol missions
	GroupCommander:new({name='Kishi-patrol-kishi', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Foxtrot'}),
	GroupCommander:new({name='Kishi-patrol-Abu-Musa', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abu Musa Island'}),
	GroupCommander:new({name='Kishi-patrol-bandarlengeh', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bandar Lengeh'}),
	-- Supply missions
	GroupCommander:new({name='Kish-supply-Foxtrot', mission='supply', template='HeloSupplyTemplate', targetzone='Foxtrot'}),
	GroupCommander:new({name='Kish-supply-Lavan', mission='supply', template='HeloSupplyTemplate', targetzone='Lavan Island'}),
})

zones.minhad:addGroups({
	-- Supply missions
	GroupCommander:new({name='Minhad-supply-sharjah', mission='supply', template='HeloSupplyTemplate', targetzone='Sharjah'}),
	GroupCommander:new({name='Minhad-supply-Fujairan', mission='supply', template='HeloSupplyTemplate', targetzone='Fujairah Intl'}),
	GroupCommander:new({name='Minhad-attack-Al Huti', mission='attack', template='AttackConvoy', targetzone='Al Huti', type='surface'}),
})

zones.sharjah:addGroups({
	-- Attack missions
	GroupCommander:new({name='Sharjah-attack-Al Dahid', mission='attack', template='AttackConvoy', targetzone='Al Dahid', type='surface'}),
	GroupCommander:new({name='Sharjah-attack-Al Minhad AFB', mission='attack', template='AttackConvoy', targetzone='Al Minhad AFB', type='surface'}),
	GroupCommander:new({name='Sharjah-attack-Al Minhad AFB-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Al Minhad AFB'}),
	-- Patrol missions
	GroupCommander:new({name='Sharjah-patrol-al-minhad', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Al Minhad AFB'}),
	-- Supply missions
	GroupCommander:new({name='Sharjah-Supply-Khaimah', mission='supply', template='HeloSupplyTemplate', targetzone='Ras Al Khaimah'}),
	GroupCommander:new({name='Sharjah-Supply-abu-musa-blue', mission='supply', template='HeloSupplyTemplate', targetzone='Abu Musa Island'}),
	GroupCommander:new({name='Sharjah-Supply-dahid', mission='supply', template='HeloSupplyTemplate', targetzone='Al Dahid'}),
	GroupCommander:new({name='Sharjah-supply-Minhad', mission='supply', template='HeloSupplyTemplate', targetzone='Al Minhad AFB'}),
	-- Surface missions
	GroupCommander:new({name='Sharjah-supply-sharjah-Defence', mission='supply', targetzone='Sharjah-Defence', type='surface'}),
})

zones.abumusa:addGroups({
	-- Supply missions
	GroupCommander:new({name='abu-musa-supply-tumb-island-blue', mission='supply', targetzone='Tunb Island AFB'}),
	GroupCommander:new({name='abu-musa-supply-sirri-island-blue', mission='supply', targetzone='Sirri Island'})
})

zones.tunbisland:addGroups({
	-- Supply missions
	GroupCommander:new({name='Tunb-Island-supply-moradi-blue', mission='supply', targetzone='Moradi'})
})

zones.hidden4:addGroups({

})

function SpawnFriendlyAssets()

	if zones.redcarrier.wasBlue and not IsGroupActive('CVN-73') then
		activateGroupIfNotActive('CVN-73')
		activateGroupIfNotActive('CVN-59')
		activateGroupIfNotActive('Khasab Tarawa')
		destroyGroupIfActive('CVN-72')
		destroyGroupIfActive('CVN-74')
		timer.scheduleFunction(function()
			checkWeaponsList('CVN-73')
			checkWeaponsList('Khasab Tarawa')
			checkWeaponsList('CVN-59')
		end, {}, timer.getTime() + 3)
	end
	
	-- if zones.bandarabbas.wasBlue then
	-- 	activateGroupIfNotActive('BandarAwacs')
	-- 	destroyGroupIfActive('Blue AWACS')
	-- end
	if zones.delta.wasBlue and zones.bandarabbas.wasBlue then
		--activateGroupIfNotActive('Blue Tanker 1')
		--activateGroupIfNotActive('Blue Tanker 2')
		--destroyGroupIfActive('Blue Tanker-Sirri-2')
		--destroyGroupIfActive('Blue Tanker-Sirri')
		trigger.action.setUserFlag(135, false)
	end
	if zones.abumusa.wasBlue and zones.sirri.wasBlue and not zones.bandarabbas.wasBlue then
		activateGroupIfNotActive('Blue AWACS')
		--activateGroupIfNotActive('Blue Tanker-Sirri-2')
		--activateGroupIfNotActive('Blue Tanker-Sirri')
	end
	if zones.khasab.wasBlue then
		activateGroupIfNotActive('Blue Silkworm')
		destroyGroupIfActive('Tarawa')
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
end
timer.scheduleFunction(SpawnFriendlyAssets,{},timer.getTime()+10)

function checkAndDisableFriendlyZones()
	if zones.alkhatim.wasBlue and zones.alain.wasBlue and zones.alhuti.wasBlue
		and zones.hidden.side == 1 then
		zones.hidden:DestroyHiddenZone()
	end
	if zones.khasab.wasBlue and (zones.qeshmisland.wasBlue or zones.bandarabbas.wasBlue) and zones.hidden2.side == 1 then
		zones.hidden2:DestroyHiddenZone()
		zones.hidden4:MakeZoneRedAndUpgrade()
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

AirbaseBelonging = AirbaseBelonging or {}
AirbaseBelonging["Lar"]     = AirbaseBelonging["Lar"]     or {"Shiraz Intl"}
AirbaseBelonging["Samathe"] = AirbaseBelonging["Samathe"] or {"Jiroft","Kerman"}

for i,v in pairs(zones) do
	bc:addZone(v)
end

bc:addConnection("Al Dhafra","Al Huti")
bc:addConnection("Al Dhafra","Al Khatim")
bc:addConnection("Al Khatim","Al Ain")
bc:addConnection("Al Huti","Al Ain")
bc:addConnection("Al Minhad AFB","Al Huti")
bc:addConnection("Fujairah Intl","Al Minhad AFB")
bc:addConnection("Al Minhad AFB","Sharjah")
bc:addConnection("Al Dahid","Sharjah")
bc:addConnection("Al Dahid","Fujairah Intl")
bc:addConnection("Ras Al Khaimah","Fujairah Intl")
bc:addConnection("Charlie","Ras Al Khaimah")
bc:addConnection("Ras Al Khaimah","Alpha")
bc:addConnection("Alpha","Khasab")
bc:addConnection("Khasab-Defence","Khasab")
bc:addConnection("Khasab","Charlie")
bc:addConnection("Khasab","Convoy")
bc:addConnection("Khasab","Red Carrier")
bc:addConnection("Khasab","Tunb Island AFB")
bc:addConnection("Red Carrier","Qeshm Island")
bc:addConnection("Red Carrier","BandarAbbas")
bc:addConnection("Sharjah","Ras Al Khaimah")
bc:addConnection("Sharjah","Sharjah-Defence")
bc:addConnection("Sharjah","Abu Musa Island")
bc:addConnection("Abu Musa Island","Sirri Island")
bc:addConnection("Abu Musa Island","Tunb Island AFB")
bc:addConnection("Tunb Island AFB","Tunb Defence")
bc:addConnection("BandarAbbas","Oil Fields")
bc:addConnection("BandarAbbas","Radio Tower")
bc:addConnection("BandarAbbas","Dehbarez")
bc:addConnection("Dehbarez","Oil Fields")
bc:addConnection("Paregaan","Factory")
bc:addConnection("Paregaan","Oil Fields")
bc:addConnection("Factory","Khamets")
bc:addConnection("Golf","Bandar Lengeh")
bc:addConnection("BandarAbbas","Factory")
bc:addConnection("BandarAbbas","Delta")
bc:addConnection("Samathe","Khamets")
bc:addConnection("Samathe","Paregaan")
bc:addConnection("Factory","Delta")
bc:addConnection("Delta","Echo")
bc:addConnection("Echo","Golf")
bc:addConnection("Foxtrot","Lar")
bc:addConnection("Golf","Lar")
bc:addConnection("Delta","Qeshm Island")
bc:addConnection("Echo","Qeshm Island")
bc:addConnection("Qeshm-Island-Defence","Qeshm Island")
bc:addConnection("Qeshm-Island-Defence","Moradi")
bc:addConnection("Moradi","Bandar Lengeh")
bc:addConnection("Bandar Lengeh","Sirri Island")
bc:addConnection("Bandar Lengeh","Abu Musa Island")
bc:addConnection("Bandar Lengeh","Tunb Island AFB")
bc:addConnection("Tunb Island AFB","Abu Musa Island")
bc:addConnection("BandarAbbas","Qeshm-Island-Defence")
bc:addConnection("Kish intl","Bandar Lengeh")
bc:addConnection("Kish intl","Foxtrot")
bc:addConnection("Kish intl","Lavan Island")
bc:addConnection("Lavan Island","Foxtrot")
bc:addConnection("Golf","Foxtrot")
bc:addConnection("Golf","Sunny")
bc:addConnection("Sunny","Khamets")
bc:addConnection("Factory","Sunny")
bc:addConnection("Lar","Sunny")
bc:addConnection("Lar","Lar-Defence")
bc:addConnection("Sunny","Echo")
bc:addConnection("Ramp-Kongo","Sunny")
bc:addConnection("Lar","Ramp-Kongo")
bc:addConnection("Khamets","Ramp-Kongo")
bc:addConnection("Dehbarez","SecretTechFacility")
bc:addConnection("Radio Tower","TankFactory")
bc:addConnection("ChemSite","Ras Al Khaimah")
bc:addConnection("Al Ain","Fuel Depo")
bc:addConnection("Fujairah Intl","Fuel Depo")
bc:addConnection("InsurgentCamp","Ras Al Khaimah")
bc:addConnection("InsurgentCamp","Al Dahid")

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
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Khasab Defence is no more\n+500 credits',20)
end, 'disablekhasabdefence')

zones.qeshmislanddefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Qeshm island Defence is no more\n+500 credits',20)
end, 'disableqeshmislanddefence')

zones.tunbdefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Tunb Defence is no more\n+500 credits',20)
end, 'disabletunbdefence')

zones.sharjadefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Sharjah Defence is no more\n+500 credits',20)
end, 'disablesharjadefence')

zones.lardefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Lar Defence is no more\n+500 credits',20)
end, 'disablelardefence')


zones.insurgentcamp:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Insurgent camp is no more\n+500 credits',20)
end, 'disableinsurgentcamp')

zones.chemsite:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'chemsite is no more\n+500 credits',20)
end, 'disablechemsite')

zones.fueldepo:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Fueldepo is no more\n+500 credits',20)
end, 'disablefueldepo')

zones.secrettechfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Secret tech facility is destroyed\n+500 credits',20)
end, 'disablesecrettechfacility')

zones.tankfactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Great work! Tank factory is now destroyed\n+500 credits',20)
end, 'disabletankfactory')

Group.getByName('qeshm-arty-Attack-Group'):destroy()
zones.qeshmisland:registerTrigger('captured', function(event,sender)
	local kr = bc:getZoneByName('Qeshm Island')
	if kr.side == 2 and not CustomFlags['qeshmcaptured'] then
		if not IsGroupActive('Qeshm-arty-Attack-Group') then
			Respawn.Group('Qeshm-arty-Attack-Group')
            CustomFlags['qeshmcaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, "Qeshm Island is under attack by enemy Artillery!\n\nBrace!", 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 180)
		end
	
    timer.scheduleFunction(function()
    trigger.action.outTextForCoalition(2, [[We found the enemy Artillery!

Take it out before they fire again!   

Coordinates:
MGRS: 40 R DQ 04694 96858
Lat long: N 27°05'26" E 56°02'19"
Lat long Decimal Minutes: N 27°05.448' E 56°02.319'

Elevation: 12 feet]], 30)
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
            trigger.action.outTextForCoalition(2, "Brace!!\n\nEnemy have fired scuds toward Khasab!!", 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 150)
		end
	end
end, 'khasabcaptured')

missions = {
    ["Ras Al Khaimah"] = {	
        zone = "Ras Al Khaimah",
        missionGroup = "KhaimahEscortGroup",
        menuTitle = "Khaimah: Ground Escort",
        missionTitle = "Khaimah: Ground Escort",
        TargetZone = "Charlie",
		radius = 2500,
        MissionType = "Escort",
		flag = 101,
		ActivateZone = "HiddenKhaimahMission"
    },
    ["Al Minhad AFB"] = {	
        zone = "Al Minhad AFB",
        missionGroup = "MinhadEscortGroup",
        menuTitle = "Minhad: Ground Escort",
        missionTitle = "Minhad: Ground Escort",
        TargetZone = "Sharjah",
        radius = 2500,
        MissionType = "Escort",
		flag = 111,
		ActivateZone = "HiddenMinhadMission"
    },
	
    Sharjah = {	
        zone = "Sharjah",
        missionGroup = "SharjahEscortGroup",
        menuTitle = "Sharjah: Ground Escort",
        missionTitle = "Sharjah: Ground Escort",
        TargetZone = "Al Dahid",
        radius = 2500,
        MissionType = "Escort",
		flag = 121,
		ActivateZone = "HiddenSharjahMission"
    },
    ["Qeshm Island"] = {	
        zone = "Qeshm Island",
        missionGroup = "QeshmIslandEscortGroup",
        menuTitle = "Qeshm Island: Ground Escort",
        missionTitle = "Qeshm Island: Ground Escort",
        TargetZone = "Moradi",
        radius = 2500,
        MissionType = "Escort",
		flag = 131,
		ActivateZone = "HiddenMoradiQeshmMission"
    },
    ["Moradi"] = {	
        zone = "Moradi",
        missionGroup = "MoradiEscortGroup",
        menuTitle = "Moradi: Ground Escort",
        missionTitle = "Moradi: Ground Escort",
        TargetZone = "Qeshm Island",
        radius = 2500,
        MissionType = "Escort",
		flag = 141,
		ActivateZone = "HiddenMoradiQeshmMission"
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
	bc:roamGroupsToLocalSubZone({
		"Red Armour Group #",
		"Red SAM AAA #",
		"Red SAM AAA 2 #",
		"Red Armor Group 2 #",
		"Red Armour Group 3 #",
		"Red SAM SHORAD SA-8 2 #",
		"Red SAM SHORAD SA-15 2 #",
		"Red SAM SHORAD SA-19 2 #",
		'Red Armor Group7 #',
		'Red Armor Group9 #',
		'Red Armor Group6 #',
	}, 30)
end,{},timer.getTime()+30)

zones.convoy:registerTrigger('lost', function (event, sender)
	local convoyItems = {'convoy1', 'convoy2', 'convoy3', 'convoy4'}
	
	local message = "Convoy liberated"
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
		message = message .. ' but we lost ' .. percentLost .. '% of the trucks.'
	else
		message = message .. '. We recovered all of the supplies.'
	end
	
	local creditsEarned = (#convoyItems - totalLost) * 250
	message = message .. '\n\n+' .. creditsEarned .. ' credits'
	
	bc:addFunds(2, creditsEarned)
	
	trigger.action.outTextForCoalition(2, message, 15)
end, 'convoyLost', 1)

local showCredIncrease = function(event, sender)
	trigger.action.outTextForCoalition(sender.side, '+' .. math.floor(sender.income * 360) .. ' Credits/Hour', 5)
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



local smoketargets = function(tz)
	if not tz or not tz.built then return end
	local units = {}
	for i,v in pairs(tz.built) do
		local g = Group.getByName(v)
		if g and g:isExist() then
			local gUnits = g:getUnits()
			if gUnits then
				for i2,v2 in ipairs(gUnits) do
					table.insert(units,v2)
				end
			end
		end
	end
	local tgts = {}
	for i=1,3,1 do
		if #units > 0 then
			local selected = math.random(1,#units)
			table.insert(tgts,units[selected])
			table.remove(units,selected)
		end
	end
	for i,v in ipairs(tgts) do
		if v and v:isExist() then
			local pos = v:getPosition().p
			trigger.action.smoke(pos,1)
		end
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
	if params.zone and params.zone.side == 1 then
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
	trigger.action.outTextForCoalition(2, 'CAP is requested. Select spawn zone.', 20)
    return
end,
function (sender, params)
    if capActive then
        return 'CAP mission still in progress'
    end
    buildCapMenu()

	trigger.action.outTextForCoalition(2, 'CAP is requested. Select spawn zone.', 20)
    return
end)
---
bc:registerShopItem('dynamicarco', 'Dynamic Tanker (Drogue)', 100, function(sender)
    if ArcoActive then
        return 'Arco is still airborne'
    end
		if ArcoParentMenu then
		return 'Choose spawn zone from F10 menu'
	end
    buildArcoMenu()
	trigger.action.outTextForCoalition(2, 'Tanker (Drogue) is requested. Select spawn zone.', 20)
    return
end,
function (sender, params)
    if ArcoActive then
        return 'Arco is still airborne'
    end
    buildArcoMenu()

	trigger.action.outTextForCoalition(2, 'Tanker (Drogue) is requested. Select spawn zone.', 20)
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
	trigger.action.outTextForCoalition(2, 'Tanker (Boom) is requested. Select spawn zone.', 20)
    return
end,
function (sender, params)
    if TexacoActive then
        return 'Texaco is still airborne'
    end
    buildTexacoMenu()

	trigger.action.outTextForCoalition(2, 'Tanker (Boom) is requested. Select spawn zone.', 20)
    return
end)
---
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
        trigger.action.outTextForCoalition(2, 'No enemy zone is far enough (>'..minNM..' NM) from the front line.', 20)
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
    trigger.action.outTextForCoalition(2, 'Select CAS target zone from F10', 20)
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
        trigger.action.outTextForCoalition(2, 'No enemy zone is far enough (>'..minNM..' NM) from the front line.', 20)
        return
    end

    DECOYTargetMenu = bc:showTargetZoneMenu(2, 'Select Decoy Target', function(targetZoneName, menu)
        if decoyActive then return end
        local spawnZone, dist = findClosestBlueZoneOutside(targetZoneName, minNM)
        if not spawnZone then
            trigger.action.outTextForCoalition(2, 'No friendly zone available for Decoy spawn '..minNM..'+ NM away.', 20)
            return
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnDecoyAt(spawnZone, targetZoneName, offset)
        DECOYTargetMenu = nil
    end, 1, nil, allow)

    trigger.action.outTextForCoalition(2, 'Select Decoy target zone from F10', 20)
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
        trigger.action.outTextForCoalition(2, 'No enemy zone is far enough (>'..minNM..' NM) from the front line.', 20)
        return
    end

    SEADTargetMenu = bc:showTargetZoneMenu(2, 'Select SEAD Target', function(targetZoneName, menu)
        if seadActive then return end
        local spawnZone, dist = findClosestBlueZoneOutside(targetZoneName, minNM)
        if not spawnZone then
            trigger.action.outTextForCoalition(2, 'No friendly zone available for SEAD spawn '..minNM..'+ NM away.', 20)
            return
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnSeadAt(spawnZone, targetZoneName, offset)
        SEADTargetMenu = nil
    end, 1, nil, allow)

    trigger.action.outTextForCoalition(2, 'Select SEAD target zone from F10', 20)
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
        trigger.action.outTextForCoalition(2, 'No enemy zone is far enough (>'..minNM..' NM) from the front line.', 20)
        return
    end

    BomberTargetMenu = bc:showTargetZoneMenu(2, 'Select bomb run target', function(targetZoneName, menu)
        if bomberActive then return end
        local spawnZone, dist = findClosestBlueZoneOutside(targetZoneName, minNM)
        if not spawnZone then
            trigger.action.outTextForCoalition(2, 'No friendly zone available for Bomb spawn '..minNM..'+ NM away.', 20)
            return
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnBomberAt(spawnZone, targetZoneName, offset)
        BomberTargetMenu = nil
    end, 1, nil, allow)

    trigger.action.outTextForCoalition(2, 'Select bomb run target zone from F10', 20)
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


if UseStatics == true then
bc:registerShopItem('Dynamicstatic', 'Dynamic building Strike', 500,
function(sender)
    if StructureActive then
        return 'building strike mission still in progress'
    end
	if StructureTargetMenu then
		return 'Choose target zone from F10 menu'
	end
    local minNM = 25
    local allow = {}
    for _, z in ipairs(bc:getZones()) do
        if z.side == 1 and z.newStatics and next(z.newStatics) and findClosestBlueZoneOutside(z.zone, minNM) then
            allow[z.zone] = true
        end
    end
    if not next(allow) then
        trigger.action.outTextForCoalition(2, 'No enemy zone with building targets far enough (>'..minNM..' NM) from the front line.', 20)
        return
    end

    StructureTargetMenu = bc:showTargetZoneMenu(2, 'Select building strike target zone', function(targetZoneName, menu)
        if bomberActive then return end
        local spawnZone, dist = findClosestBlueZoneOutside(targetZoneName, minNM)
        if not spawnZone then
            trigger.action.outTextForCoalition(2, 'No friendly zone available for strike spawn '..minNM..'+ NM away.', 20)
            return
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnStructureAt(spawnZone, targetZoneName, offset)
        StructureTargetMenu = nil
    end, 1, nil, allow)

    trigger.action.outTextForCoalition(2, 'Select building strike target zone from F10', 20)
    return
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and params.zone.newStatics and next(params.zone.newStatics) then
        if StructureActive then
            return 'building strike mission still in progress'
        end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return 'No friendly zone available for strike spawn.'
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnStructureAt(closestBlue, params.zone.zone, offset)
        return
    else
        return 'Can only target enemy zone with building targets'
    end
end)
end
---------------------------------------------END DYNAMIC SHOP ------------------------------------------
bc:addMonitoredROE('cruise1')
local cruiseMissileTargetMenu = nil
bc:registerShopItem('cruisemsl', 'Cruise Missile Strike', 800, function(sender)
    if cruiseMissileTargetMenu then
        return 'Choose target zone from F10 menu'
    end
    
    local launchAttack = function(target)
        if cruiseMissileTargetMenu then
            local err = bc:fireAtZone(target, 'cruise1', true, 8)
            if err then
                return err
            end
            
            cruiseMissileTargetMenu = nil
            trigger.action.outTextForCoalition(2, 'Launching cruise missiles at ' .. target, 15)
        end
    end
    
    cruiseMissileTargetMenu = bc:showTargetZoneMenu(2, 'Cruise Missile Target', launchAttack, 1)
    
    trigger.action.outTextForCoalition(2, 'Cruise missiles ready. Choose target zone from F10 menu', 15)
end,
function(sender, params)
    if params.zone and params.zone.side == 1 then
        local err = bc:fireAtZone(params.zone.zone, 'cruise1', true, 8)
        if err then
            return err
        end
        
        trigger.action.outTextForCoalition(2, 'Launching cruise missiles at ' .. params.zone.zone, 15)
    else
        return 'Can only target enemy zone'
    end
end)


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
            if zn and zn.side==2 and not zn.suspended then
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
                            timer.scheduleFunction(loop,{},timer.getTime()+2)
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
    if params.zone and params.zone.side==2 and not params.zone.suspended then
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
                timer.scheduleFunction(loop,{},timer.getTime()+2)
			else
				trigger.action.outTextForCoalition(2,params.zone.zone..' is now fully upgraded!',15)
			end
        end
        loop()
    else
        return'Can only target friendly zone'
    end
end)


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
bc:registerShopItem('jtac','MQ-9 Reaper JTAC mission',200,function(sender)
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
			if Era == 'Coldwar' then
				trigger.action.outTextForCoalition(2,'Friendly Tomcat deployed over '..target..' - JTACs active '..#jtacQueue..' / 2',15)
			else
				trigger.action.outTextForCoalition(2,'Reaper drone deployed over '..target..' - JTACs active '..#jtacQueue..' / 2',15)
			end
			jtacTargetMenu = nil
		end
	end
	jtacTargetMenu = bc:showTargetZoneMenu(2,'Deploy JTAC',spawnAndOrbit,1)
	trigger.action.outTextForCoalition(2,'Choose which zone to deploy JTAC at from F10 menu',15)
end,function(sender,params)
	if params.zone and params.zone.side == 1 then
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
		if Era == 'Coldwar' then
			trigger.action.outTextForCoalition(2,'Friendly Tomcat deployed over '..params.zone.zone..' - JTACs active '..#jtacQueue..' / 2',15)
		else
			trigger.action.outTextForCoalition(2,'Reaper drone deployed over '..params.zone.zone..' - JTACs active '..#jtacQueue..' / 2',15)
		end
	else
		return 'Can only target enemy zone'
	end
end)

------------------------------------ START own 9 line jtac AM START ----------------------------------
local jtacZones = {}
local jtacTargetMenu2 = nil
local droneAM
Group.getByName('JTAC9lineamColdwar'):destroy()
Group.getByName('JTAC9lineam'):destroy()
if Era == 'Coldwar' then
droneAM = JTAC9line:new({name = 'JTAC9lineamColdwar'})
else
droneAM = JTAC9line:new({name = 'JTAC9lineam'})
end
bc:registerShopItem('9lineam', 'Jtac 9line AM', 0, function(sender)
    if jtacTargetMenu2 then
        return 'Choose target zone from F10 menu'
    end
    
    local spawnAndOrbit2 = function(target)
        if jtacTargetMenu2 then
            local zn = bc:getZoneByName(target)
            droneAM:deployAtZone(zn)
			jtacZones[target] = {drone = Era == 'Coldwar' and 'JTAC9lineamColdwar' or 'JTAC9lineam'}
			
		trigger.action.outTextForCoalition(2, 'Reaper drone deployed over ' .. target .. '. Contact Springfield on 241.00 AM ', 30)
        jtacTargetMenu2 = nil
		end
    end
    
    jtacTargetMenu2 = bc:showTargetZoneMenu(2, 'Deploy JTAC to Zone', spawnAndOrbit2, 1)
    trigger.action.outTextForCoalition(2, 'Choose which zone to deploy JTAC at from F10 menu', 15)
end,
function(sender, params)
    if params.zone and params.zone.side == 1 then
        droneAM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = Era == 'Coldwar' and 'JTAC9lineamColdwar' or 'JTAC9lineam'}
		if Era == 'Coldwar' then
			trigger.action.outTextForCoalition(2, 'Friendly Tomcat deployed over ' .. params.zone.zone .. '. Contact Springfield on 241.00 AM ', 30)
        
    	else
			trigger.action.outTextForCoalition(2, 'Reaper drone deployed over ' .. params.zone.zone .. '. Contact Springfield on 241.00 AM ', 30)
		end
    else
        return 'Can only target enemy zone'
    end
end)

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
bc:registerShopItem('9linefm', 'Jtac 9line FM', 0, function(sender)
    if jtacTargetMenu3 then
        return 'Choose target zone from F10 menu'
    end
    
    local spawnAndOrbit3 = function(target)
        if jtacTargetMenu3 then
            local zn = bc:getZoneByName(target)
            droneFM:deployAtZone(zn)
			
			jtacZones[target] = {drone = Era == 'Coldwar' and 'JTAC9linefmColdwar' or 'JTAC9linefm'}
			
		
		if Era == 'Coldwar' then
			trigger.action.outTextForCoalition(2, 'Friendly Tomcat deployed over ' .. target .. '. Contact Uzi on 31.00 FM ', 30)
		else
			trigger.action.outTextForCoalition(2, 'Reaper drone deployed over ' .. target .. '. Contact Uzi on 31.00 FM ', 30)  
		end            
            jtacTargetMenu3 = nil
        end
    end
    
    jtacTargetMenu3 = bc:showTargetZoneMenu(2, 'Deploy JTAC to Zone', spawnAndOrbit3, 1)
    trigger.action.outTextForCoalition(2, 'Choose which zone to deploy JTAC at from F10 menu', 15)
end,
function(sender, params)
    if params.zone and params.zone.side == 1 then
        droneFM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = Era == 'Coldwar' and 'JTAC9linefmColdwar' or 'JTAC9linefm'}

		if Era == 'Coldwar' then
			trigger.action.outTextForCoalition(2, 'Friendly Tomcat deployed over ' .. params.zone.zone .. '. Contact Uzi on 31.00 FM ', 30)
        
    	else
			trigger.action.outTextForCoalition(2, 'Reaper drone deployed over ' .. params.zone.zone .. '. Contact Uzi on 31.00 FM ', 30)
		end
    else
        return 'Can only target enemy zone'
    end
end)

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
            if zone and zone.side == 0 or not zone.active then
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

bc:registerShopItem('jam', 'Jam radars at zone', 500, function(sender)
    local gr = Group.getByName('ewAircraft')
    if Utils.isGroupActive(gr) then 
        return 'Jamming mission still in progress'
    end
    RespawnGroup('ewAircraft')

    if jamMenu then
        return 'Choose target zone from F10 menu'
    end
    
    local startJam = function(target)
        if jamMenu then
            bc:jamRadarsAtZone('ewAircraft', target)
            jamMenu = nil
            trigger.action.outTextForCoalition(2, 'Growler jamming radars at ' .. target, 15)
        end
    end
    
    jamMenu = bc:showTargetZoneMenu(2, 'Jamming target', startJam, 1)
    trigger.action.outTextForCoalition(2, 'Choose target zone from F10 menu', 15)
end,
function(sender, params)
    if params.zone and params.zone.side == 1 then
        local gr = Group.getByName('ewAircraft')
        if Utils.isGroupActive(gr) then 
            return 'Jamming mission still in progress'
        end
        RespawnGroup('ewAircraft')
        
        timer.scheduleFunction(function(target)
            local ew = Group.getByName('ewAircraft')
            if ew then
                local err = bc:jamRadarsAtZone('ewAircraft', target)
                if err then
                    return err
                end
                
                trigger.action.outTextForCoalition(2, 'Growler jamming radars at ' .. target, 15)
            end
        end,{params.zone.zone},timer.getTime() + 2)
        
    else
        return 'Can only target enemy zone'
    end
end)
Group.getByName('ca-tanks-Coldwar'):destroy()
Group.getByName('ca-tanks'):destroy()
tanksMenu = nil
bc:registerShopItem('armor', 'Deploy armor (for combined arms)', 100, function(sender)
	if tanksMenu then
		return 'Choose deploy zone from F10 menu'
	end
	
	local deployTanks = function(target)
		if tanksMenu then
			local zn = CustomZone:getByName(target)
			zn:spawnGroup((Era == 'Coldwar') and 'ca-tanks-Coldwar' or 'ca-tanks')
			tanksMenu = nil
			trigger.action.outTextForCoalition(2, 'Friendly armor deployed at ' .. target, 15)
		end
	end
	
	tanksMenu = bc:showTargetZoneMenu(2, 'Deploy armor (Choose friendly zone)', deployTanks, 2)
	trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 2 then
		local zn = CustomZone:getByName(params.zone.zone)
		zn:spawnGroup((Era == 'Coldwar') and 'ca-tanks-Coldwar' or 'ca-tanks')
		trigger.action.outTextForCoalition(2, 'Friendly armor deployed at ' .. params.zone.zone, 15)
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
			trigger.action.outTextForCoalition(2, 'Friendly artillery deployed at ' .. target, 15)
		end
	end
	
	artyMenu = bc:showTargetZoneMenu(2, 'Deploy artillery (Choose friendly zone)', deployArty, 2)
	trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 2 then
		local zn = CustomZone:getByName(params.zone.zone)
		zn:spawnGroup('ca-arty')
		trigger.action.outTextForCoalition(2, 'Friendly artillery deployed at ' .. params.zone.zone, 15)
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
			trigger.action.outTextForCoalition(2, 'Friendly recon group deployed at ' .. target, 15)
		end
	end
	
	reconMenu = bc:showTargetZoneMenu(2, 'Deploy recon group (Choose friendly zone)', deployRecon, 2)
	trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 2 then
		local zn = CustomZone:getByName(params.zone.zone)
		zn:spawnGroup('ca-recon')
		trigger.action.outTextForCoalition(2, 'Friendly recon group deployed at ' .. params.zone.zone, 15)
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

-- new menu
local supplyMenu=nil
bc:registerShopItem('capture','Emergency capture zone',500,
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
--end of menu

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
				if not zn or zn.side ~= 1 or zn.suspended then return end
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
	if params.zone and params.zone.side == 1 then
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

local infMenu=nil
bc:registerShopItem('zinf','Add infantry squad to zone',500,function(sender)
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
			z:addExtraSlot('blueInfantry')
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
		params.zone:addExtraSlot('blueInfantry')
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
            local slot = (Era == 'Coldwar') and 'bluePD Coldwar' or 'bluePD1'
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
		params.zone:addExtraSlot((Era == 'Coldwar') and 'bluePD Coldwar' or 'bluePD1')
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
			local slotID = (Era == 'Coldwar') and 'blueArmor_cw' or 'blueArmor'
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
		local slotID = (Era == 'Coldwar') and 'blueArmor_cw' or 'blueArmor'
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

bc:registerShopItem('gslot','Unlock extra upgrade slot',3000,function(sender)
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
------------------------------------------- End of Zone upgrades ----------------------------------------

bc:addShopItem(2, 'jtac', -1,1)
bc:addShopItem(2, 'dynamiccap', -1,2)
bc:addShopItem(2, 'dynamiccas', -1,3)
bc:addShopItem(2, 'dynamicbomb', -1,4)
bc:addShopItem(2, 'dynamicsead', -1,5)
bc:addShopItem(2, 'dynamicdecoy', -1,6)
bc:addShopItem(2, 'dynamicarco', -1,7)
bc:addShopItem(2, 'dynamictexaco', -1,8)


if UseStatics == true then
    bc:addShopItem(2, 'Dynamicstatic', -1,9)
end
bc:addShopItem(2, 'capture', -1,10)
bc:addShopItem(2, 'smoke', -1,11)
bc:addShopItem(2, 'intel', -1,12)
bc:addShopItem(2, 'supplies2', -1,13)
bc:addShopItem(2, 'supplies', -1,14)
bc:addShopItem(2,'zinf',-1,15)
bc:addShopItem(2,'zarm',-1,16)
bc:addShopItem(2,'zsam',-1,17)
bc:addShopItem(2,'zpat',-1,18)
bc:addShopItem(2,'gslot',1,19)
bc:addShopItem(2, 'armor', -1,20)
bc:addShopItem(2, 'artillery', -1,21)
bc:addShopItem(2, 'recon', -1,22)
bc:addShopItem(2, 'airdef', -1,23)
bc:addShopItem(2, 'cruisemsl', 12, 24)
bc:addShopItem(2, 'jam', -1,25)
bc:addShopItem(2, '9lineam', -1,26)
bc:addShopItem(2, '9linefm', -1,27)


supplyZones = {
    'Sharjah',
    'BandarAbbas',
    'Factory',
    'Khasab',
    'Delta',
    'Echo',
    'Golf',
    'Carrier Group',
    'Factory',
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
lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

bc:loadFromDisk() -- will load and overwrite default zone levels, sides, funds, and available shop items
bc:init()
bc:startRewardPlayerContribution(15,{infantry = 10, ground = 10, sam = 30, airplane = 30, ship = 200, helicopter=30, crate=100, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, ['CAP mission'] = true, ['CAS mission'] = true})
HercCargoDropSupply.init(bc)
bc:buildZoneDistanceCache()
buildSubZoneRoadCache()
bc:buildConnectionMap()
DynamicConvoy.InitTargetTails(5)
DynamicConvoy.InitRoadPathCacheFromCommanders(GroupCommanders)
PrecomputeLandingSpots()
SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 4, 0)
SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 6, 0)


GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 120   		-- suspend red zones deeper than this nm

evc = EventCommander:new({ decissionFrequency=30*60, decissionVariance=30*60, skipChance = 10})
mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})
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
		RegisterGroupTarget('oscar-scud-1',100,'Destroy Scuds')
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
				trigger.action.outTextForCoalition(2, 'SCUDS near Foxtrot (30), are launching at '..choice, 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
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
	title = "Destroy SCUDS, (30)",
	description = "SCUDS have been spotted at Foxtrot, 30).\nDestroy them before they can launch their missiles",
	messageStart = "New mission: Destroy SCUDS",
	messageEnd = "Mission ended: Destroy SCUDS",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
	isActive = function()
		local gr = Group.getByName('oscar-scud-1')
		if gr then return true else return false end
	end
})
-------------------------------------End of Oscar Scuds ----------------------------------
---------------------------------------- Helo Hunt ---------------------------------------
local HeloHunt_COOLDOWN = 6800
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
        for _,e in ipairs(groupsAndTargets) do RespawnGroup(e.group) 
			timer.scheduleFunction(function()
			RegisterGroupTarget(e.group,500,'Helo hunt')
			end,{},timer.getTime()+1)
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
    title = "Helo Hunt LAR",
    description = "Large number of KA-50 taking off from LAR heading to our closest friendly bases\nDestroy them before they get in range.",
    messageStart = "New mission: Helo hunt\nLarge number of KA-50 takingoff from LAR heading to our closest friendly bases\n\nDestroy them before they get in range.",
    messageEnd = function() lastHeloHunt_COOLDOWN=timer.getTime() return "Mission ended: Helo hunt" end,
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
local airstrike_COOLDOWN = 2700
local lastairstrike_COOLDOWN  = -airstrike_COOLDOWN
local attackGrp = Era=='Coldwar' and 'evt-attackcw' or 'evt-attack'
Group.getByName('evt-attack'):destroy()
Group.getByName('evt-attackcw'):destroy()
Group.getByName(attackGrp):destroy()
evc:addEvent({
	id='cas',
	action=function()
		RespawnGroup(attackGrp)
		RegisterGroupTarget(attackGrp,500,'Intercept enemy airstrike')
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
	title = "Intercept enemy airstrike",
	description = "Enemy aircraft conducting an airstrike from the west to south east\nDestroy them before they get in range.",
	messageStart = "New mission: Intercept enemy airstrike",
	messageEnd =function() lastairstrike_COOLDOWN=timer.getTime() return "Mission ended: Intercept enemy airstrike" end,
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
		local g1 = Group.getByName('evt-attack')
		local g2 = Group.getByName('evt-attackcw')
		if g1 or g2 then
			return true
		else
			return false
		end
	end
})
-------------------------------------End of Airstrike ----------------------------------
---------------------------------------- Scenery Check ---------------------------------------

local sceneryList = {
    ["StrikePort"] = {SCENERY:FindByZoneName("StrikePort1"), SCENERY:FindByZoneName("StrikePort2")},
    ["GeneralsHouse"] = {SCENERY:FindByZoneName("Generals house")},
    ["Terroristcell"] = {SCENERY:FindByZoneName("TerroristCell")},
    ["TerrorCell2"] = {SCENERY:FindByZoneName("TerrorCell2")},
    ["TerrorCell3"] = {SCENERY:FindByZoneName("TerrorCell3")},
    ["TerrorCell4"] = {SCENERY:FindByZoneName("TerrorCell4")},
    ["TerrorCell5"] = {SCENERY:FindByZoneName("TerrorCell5")},
}
-----------------------------------------End scenery Check -------------------------------------
---------------------------------------- Cargo Intercept ---------------------------------------

local CargoIntercept_COOLDOWN = 2700
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
		local u = Group.getByName(planes[choice]):getUnit(1)
		if u then RegisterUnitTarget(u:getName(),500,'Intercept cargo plane') end
	end,
	canExecute = function()
		if timer.getTime() - lastCargoIntercept_COOLDOWN < CargoIntercept_COOLDOWN then return false end
		if math.random(1,100) < 70 then return false end
		if bc:getZoneByName('Lar').side ~= 1 or bc:getZoneByName('Lar').suspended then return false end
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
			return "Find and destroy the cargo plane headed to LAR\nCurrently spotted east of BandarAbbas."
		elseif Group.getByName('evt-cargointercept2') then
			return "Find and destroy the cargo plane headed to LAR\nCurrently spotted east of Khasab."
		elseif Group.getByName('evt-cargointercept3') then
			return "Find and destroy the cargo plane headed to LAR\nCurrently spotted east of Al Ain."
		else
			return "Cargo plane is no longer active."
		end
	end,
    messageStart = "New mission: Intercept cargo plane",
    messageEnd =function() lastCargoIntercept_COOLDOWN=timer.getTime() return "Mission ended: Intercept cargo plane" end,
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
        if Group.getByName('evt-cargointercept1') then return true end
        if Group.getByName('evt-cargointercept2') then return true end
        if Group.getByName('evt-cargointercept3') then return true end
        
        return false
    end
})
-------------------------------------End of Cargo Intercept ----------------------------------
---------------------------------------- Bomber Attack ---------------------------------------
local bomb_COOLDOWN = 2700
local lastbomb_COOLDOWN  = -bomb_COOLDOWN
local escGrp = Era=='Coldwar' and 'EscortBomberCW' or 'EscortBomber'
Group.getByName('evt-bomb'):destroy()
Group.getByName('EscortBomberCW'):destroy()
Group.getByName('EscortBomber'):destroy()
evc:addEvent({
	id='bomb',
	action=function()
		RespawnGroup('evt-bomb')
		timer.scheduleFunction(function()
			startBomberAttack()
			RespawnGroup(escGrp)
			RegisterGroupTarget('evt-bomb',500,'Intercept enemy bombers')
			timer.scheduleFunction(function()
				local bomber=Group.getByName('evt-bomb')
				local escort=Group.getByName(escGrp)
				if bomber and escort then
					local cnt=escort:getController()
					cnt:popTask()
					local escortTask={
						id='Escort',
						params={
							groupId=bomber:getID(),
							pos={x=-20,y=2000,z=50},
							lastWptIndexFlag=false,
							lastWptIndex=-1,
							engagementDistMax=12000,
							targetTypes={'Air'}
						}
					}
					cnt:pushTask(escortTask)
				end
			end,{},timer.getTime()+5)
		end,{},timer.getTime()+10)
	end,
	canExecute = function()
		if timer.getTime()-lastbomb_COOLDOWN<bomb_COOLDOWN then return false end
		local gr = Group.getByName('evt-bomb')
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

function startBomberAttack()
	local tgts = {
		'Sharjah',
		'Ras Al Khaimah',
		'Moradi',
		'Bandar Lengeh',
		'Al Dahid',
		'BandarAbbas',
		'Delta',
		'Echo',
		'Foxtrot',
		'Paregaan',
		'Radio Tower',
		'Kish intl',
		'Tunb Island AFB',
		'Sirri Island',
		'Abu Musa Island'
		
	}
	
	local validtgts = {}
	for _,v in ipairs(tgts) do
		if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
			table.insert(validtgts, v)
		end
	end
	
    if #validtgts > 0 then
        local choice = validtgts[math.random(#validtgts)]
        BASE:I("Chosen target: "..choice)
        if Group.getByName('evt-bomb') then
            bc:carpetBombRandomUnitInZone(choice, 'evt-bomb')
        end
    else
        BASE:I("No valid targets found for bomber attack.")
    end
end
mc:trackMission({
	title = "Intercept Bombers",
	description = "Enemy bombers spotted to the north\nDestroy them before they get in range.",
	messageStart = "New mission: Intercept Bombers",
	messageEnd = function() lastbomb_COOLDOWN=timer.getTime() return "Mission ended: Intercept Bombers" end,
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
-------------------------------------End of Bomber Attack ----------------------------------
----------------------------------------- Escort -------------------------------------------
local EscortCooldown = 2700
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
    title = "Escort cargo plane",
    description = "Friendly cargo plane is taking off from Al Dhafra. Protect it until it leaves the airspace.",
    messageStart = "New mission: Escort cargo plane",
    messageEnd = function() lastEscortCooldown = timer.getTime() return "Mission ended: Escort cargo plane" end,
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
		RegisterGroupTarget('AlAinInfantryStandbyGroup',500,'terrorist cell','FindHimInAlAin')
	end,
	canExecute = function()
		if Group.getByName('AlAinConvoy') then return false end
		if bc:getZoneByName('Al Khatim').side ~= 2 or bc:getZoneByName('Al Khatim').suspended then return false end
		if CustomFlags["FindHimInAlAin"] then return false end
		return true
end
})

mc:trackMission({
	title = "Strike on a terrorist cell",
	description = 

[[We have intel on a cell located somewhere 
in the city of Al Ain

Reward: 500

MGRS: 40 R CM 74285 77694
Lat long: N 24°12'24" E 55°45'43"
Lat long Decimal Minutes: N 24°12.416' E 55°45.724'
Elevation: 922 feet

Don't destroy the convoy until they reach the house!]],

	messageStart = "New mission: Strike on a terrorist cell",
	messageEnd = "Strike mission ended: Strike a terrorist cell",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	missionFail = function()
		if not IsGroupActive('AlAinConvoy') and IsGroupActive('AlAinInfantryStandbyGroup') then
			trigger.action.outTextForCoalition(2, "The convoy is destroyed and the cell is still unknown\nMission failed", 10)
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
			return true
		end
		return false
	end,
	isActive = function()
		if CustomFlags["FindHimInAlAin"] then return false end
		if Group.getByName('AlAinInfantryStandbyGroup') then return true end
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
		RegisterGroupTarget('TerrorCell2Group',500,'Terrorist cell','TerrorCell2')
	end,
	canExecute = function()
		if math.random(1,100) < 70 then return false end
		if Group.getByName('TerrorCell2Group') then return false end
		if CustomFlags["TerrorCell2"] == true then return false end
		if bc:getZoneByName('Delta').side ~= 2 or bc:getZoneByName('Delta').suspended then return false end
		return true
	end
})
mc:trackMission({
	title = "Strike a terrorist cell",
	description = 

[[A new terrorist cell have been found, 
north west of Delta.
Take it out!

Reward: 500

MGRS: 40 R CR 44167 38964
Lat long: N 27°27'55" E 55°25'22"
Lat long Decimal Minutes: N 27°27.919' E 55°25.375'
Elevation 1207 feet]],
	messageStart = "New strike mission: Strike a terrorist cell",
	messageEnd = "Strike mission ended: Strike a terrorist cell",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if IsGroupActive('TerrorCell2Group') then return true end
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
		RegisterGroupTarget('TerrorMan',750,'Strike the general','TerrorCell4')
	end,
	canExecute = function()
		if bc:getZoneByName('BandarAbbas').side ~= 2 or bc:getZoneByName('BandarAbbas').suspended then return false end
		if Group.getByName('TerrorMan') then return false end
		if CustomFlags["TerrorCell4"] then return false end
		return true
	end
})

mc:trackMission({
	title = "Strike the general",
description = 
[[We have the location on one of the generals. 
West of Paregaan, Take him out!

Coordinates:
MGRS: 40 R CS 89440 02522
Lat Long: N 28°02'36" E 55°52'30"
Lat long Decimal Minutes: N 28°02.605' E 55°52.507'
Elevation: 2272 feet

Reward: 750

Destroy the house and whoever is nearby.]],

	messageStart = "New mission: Strike the general",
	messageEnd = "Mission ended: Strike the general",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
		if CustomFlags["TerrorCell4"] then return false end
		if Group.getByName('TerrorMan') then return true end
		return false
	end
})
------------------------------------------- End strike the general ------------------------------------
---------------------------------------- Strike on enemy safehouse ------------------------------------
evc:addEvent({
	id = 'TerrorCell5',
	action = function()
		ActiveMission['TerrorCell5'] = true
		local tgt = sceneryList['TerrorCell5'][1] or SCENERY:FindByZoneName('TerrorCell5')
		if not tgt then
			trigger.action.outText('TerrorCell5 is missing',30)
			return
		end
		RegisterScoreTarget('TerrorCell5',tgt,1000,'enemy safehouse')
	end,
	canExecute = function()
	if ActiveMission['TerrorCell5'] then return false end
	if CustomFlags["TerrorCell5"] then return false end
	if bc:getZoneByName('Golf').side ~= 2 or bc:getZoneByName('Golf').suspended then return false end
	return true
	end,
})

mc:trackMission({
	title = "Strike on enemy safehouse",
	description = 
[[Enemey safehouse have been found,
South of Lar Defence.
Take it out!

Reward: 1000

MGRS: 40 R BR 37453 60786
Lat long: N 27°38'44" E 54°20'20"
Lat long Decimal Minutes: N 27°38.742' E 54°20.336'
Elevation 2651 feet]],
	messageStart = "New strike mission: Strike on enemy safehouse",
	messageEnd = "Strike mission ended: Strike on enemy safehouse\n+1000 credits",
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
		ActiveMission['TerrorCell3'] = true
		local tgt = sceneryList['TerrorCell3'][1] or SCENERY:FindByZoneName('TerrorCell3')
		if not tgt then
			trigger.action.outText('TerrorCell3 is missing',30)
			return
		end
		RegisterScoreTarget('TerrorCell3',tgt,500,'enemy safehouse')
	end,
	canExecute = function()
	if ActiveMission['TerrorCell3'] then return false end
	if CustomFlags["TerrorCell3"] then return false end
	if bc:getZoneByName('Sharjah').side ~= 2 or bc:getZoneByName('Sharjah').suspended then return false end
	  return true
	end,

})
mc:trackMission({
	title = "Strike a terrorist cell",
	description = 

[[A new terrorist cell have been found,
north west of Ras al khaimah Airport.
Take it out!

Reward: 500

MGRS: 40 R CP 80487 44056
Lat long: N 25°42'34" E 55°48'31"
Lat long Decimal Minutes: N 25°42.572' E 55°48.526'
Elevation 11 feet]],
	messageStart = "New strike mission: Strike a terrorist cell",
	messageEnd = "Strike mission ended: Strike a terrorist cell\n+500 credits",
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
		ActiveMission['StrikePort'] = true
		local tgts = sceneryList['StrikePort']
		local found = false
		for _,t in ipairs(tgts) do
			if t then
				RegisterScoreTarget('StrikePort',t,1000,'Bandar Lengeh Port')
				found = true
			end
		end
		if not found then
			trigger.action.outText('StrikePort is missing',30)
		end
	end,
	canExecute = function()
		if ActiveMission['StrikePort'] then return false end
		if CustomFlags["StrikePort"] then return false end
		if bc:getZoneByName('Bandar Lengeh').side ~= 1 or bc:getZoneByName('Bandar Lengeh').suspended then return false end
		if bc:getZoneByName('Abu Musa Island').side == 2 and bc:getZoneByName('Abu Musa Island').suspended and bc:getZoneByName('Tunb Island AFB').side == 2 and 
		   bc:getZoneByName('Tunb Island AFB').suspended and bc:getZoneByName('Sirri Island').side == 2 and bc:getZoneByName('Sirri Island').suspended then return false end
		if (bc:getZoneByName('Khasab').side == 2 and not bc:getZoneByName('Khasab').suspended)
		or (bc:getZoneByName('Abu Musa Island').side == 2 and not bc:getZoneByName('Abu Musa Island').suspended) then
			return true
		else
			return false
		end
		return false
	end,
})

mc:trackMission({
	title = "Strike Bandar Lengeh Port",
	description = 

[[Strike the port of Bandar Lengeh to cripple the supplies to the islands.

Reward 1000

2 buildings at these Coordinates:

MGRS: 40 R BQ 89571 38484
Lat long: N 26°33'05" E 54°53'15"
Lat long Decimal Minutes: N 26°33.084' E 54°53.260'
Elevation 7 feet

2000 Pounds required

And

MGRS: 40 R BQ 89307 38400
Lat long: N 26°33'02" E 54°53'06"
Lat long Decimal Minutes: N 26°33.035' E 54°53.102'
Elevation 6 feet

2000 Pounds required]],
	messageStart = "New strike mission: Strike the port of Bandar Lengeh",
	messageEnd = "Strike mission ended: Strike the port of Bandar Lengeh\n\nThe port is now out of order\nNo more ship supplies coming out of here.",
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
			trigger.action.outTextForCoalition(2, "Mission Aborted!\n\nThe port is mission is no longer needed", 10)
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
			return true
		end
		return false
	end,
	isActive = function()
	if CustomFlags["StrikePort"] then return false end
	if ActiveMission['StrikePort'] then return true end
	  return false
	end
})


---------------------------------------- Strike the Generals hideout ------------------------------------

evc:addEvent({
	id = 'GeneralsHouse',
	action = function()
		ActiveMission['GeneralsHouse'] = true
		local tgt = sceneryList['GeneralsHouse'][1] or SCENERY:FindByZoneName('GeneralsHouse')
		if not tgt then
			trigger.action.outText('GeneralsHouse is missing',30)
			return
		end
		RegisterScoreTarget('GeneralsHouse',tgt,500,'Strike the general')
	end,
	canExecute = function()
	if ActiveMission['GeneralsHouse'] then return false end
	if bc:getZoneByName('Lavan Island').side ~= 1 or bc:getZoneByName('Lavan Island').suspended then return false end
	if bc:getZoneByName('Sirri Island').side ~= 2 or bc:getZoneByName('Sirri Island').suspended then return false end
	if CustomFlags["GeneralsHouse"] then return false end
	return true
	end,
})
mc:trackMission({
	title = "Strike the general",
	description = 

[[Strike the Generals hideout. He's at Lavan Island.

Take him out before he runs away!

Reward: 500

MGRS: 39 R YK 31880 66716
Lat long: N 26°48'09" E 53°19'57"
Lat long Decimal Minutes: N 26°48.164' E 53°19.962'
Elevation 7 feet

2000 Pounds required]],
	messageStart = "New strike mission: Strike the Generals hideout",
	messageEnd = "Strike mission ended: Strike the Generals hideout",
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
			trigger.action.outTextForCoalition(2, "Strike mission failed!\n\nThe general fled the hideout", 10)
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
	RegisterGroupTarget('OnTheRun',1500,'target on the run','OnTheRun')
    end,
    canExecute = function()
		if bc:getZoneByName('Echo').side ~= 2 or bc:getZoneByName('Echo').suspended then return false end
        if bc:getZoneByName('Golf').side ~= 1 or bc:getZoneByName('Golf').suspended then return false end
        if Group.getByName('OnTheRun') then return false end
        if CustomFlags['OnTheRun'] then return false end
        return true
    end
})

mc:trackMission({
	title = "High value target on the run",
	description = 

[[High value target is on the run and moving westbound (High speed) from Golf!

Roumers say's he's going to Lar.

Take him out before he runs away! You have only ONE chance!

Reward: 1500

]],
	messageStart = "New strike mission: High value target on the run",
	messageEnd = "Strike mission ended: High value target on the run",
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
		if Group.getByName('OnTheRun') then return true end
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
							bc.playerContributions[2][pl] = bc.playerContributions[2][pl] + share
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
				return 'Mission ended: Bomb runway at '..runwayTargetZone..' completed'..(bomberName and (' by '..bomberName..'\ncredit 100 - land to redeem') or '')
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
        return targetzn and targetzn.side == 1 and not targetzn.suspended
    end
})

---------------------------------------------------------------------
--                 END OF RUNWAY STRIKE MISSION                   --

mc:trackMission({
	title = "Destroy artillery",
	description = "Artillery has been spotted heading towards Delta from the direction of Echo.\nDestroy them before they get in range.",
	messageStart = "New mission: Destroy artillery",
	messageEnd = "Mission ended: Destroy artillery\n+50 credits",
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
	reward = 50,
	isActive = function()
		local gr = Group.getByName('Echo-attack-delta-art')
		if gr then return true else return false end
	end
})
mc:trackMission({
	title = "Destroy artillery",
	description = "The enemy has deployed artillery near Foxtrot. Destroy it before it has a chance to fire.",
	messageStart = "New mission: Destroy artillery",
	messageEnd = "Mission ended: Destroy artillery\n+50 credits",
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
	reward = 50,
	isActive = function()
		local gr = Group.getByName('foxtrot-artillery-fire-at-golf')
		if gr then return true else return false end
	end
})

mc:trackMission({
	title = "Defend BandarAbbas",
	description = "The enemy is preparing an all out attack on BandarAbbas.\nDefend the airfield at all cost.",
	messageStart = "New mission: Defend BandarAbbas",
	messageEnd = "Mission ended: Defend BandarAbbas",
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
        return targetzn and targetzn.side == 2 and not targetzn.suspended and targetzn:canRecieveSupply()
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
		local t = ActiveCurrentMission[attackTarget]
		if t then
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
        return targetzn.side == 1
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
            local reward = capTargetPlanes * 30
            local pname  = capWinner
            bc.playerContributions[2][pname] = (bc.playerContributions[2][pname] or 0) + reward
            bc:addTempStat(pname,'CAP mission',1)
            trigger.action.outTextForCoalition(2,"["..pname.."] completed the CAP mission!\nReward pending: "..reward.." credits (land to redeem).",20)
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
            local reward = casTargetKills*20
            local pname  = casWinner
            bc.playerContributions[2][pname] = (bc.playerContributions[2][pname] or 0) + reward
            bc:addTempStat(pname,'CAS mission',1)

            trigger.action.outTextForCoalition(2,'['..pname..'] completed the CAS mission!\nReward pending: '..reward..' credits (land to redeem).',20)
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
    if seadTarget then return end
    if not attackTarget then return end


    local function isSEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and not zone.suspended and (lname:find('sam') or lname:find('defence'))
    end

	local validSEADZones = {}
	local attackZone = bc:getZoneByName(attackTarget)

	if attackZone and attackZone.zone then
		local znA = attackZone.zone
		for _, zone in ipairs(bc.zones) do
			local znB = zone.zone
			local dist = ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB]
			if isSEADZone(zone) and dist and dist <= 24000 then
				table.insert(validSEADZones, zone.zone)
			end
		end
	end

    if #validSEADZones == 0 then
        for _, connection in ipairs(bc.connections) do
			local from, to = bc:getConnectionZones(connection)

            if from and to and from.side ~= to.side and from.side ~= 0 and to.side ~= 0 and
			((not to.suspended) or from.suspended) then
                if isSEADZone(from) then
                    table.insert(validSEADZones, from.zone)
                end
                if isSEADZone(to) then
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
        return zn and zn.side == 1
    end
})


function generateAttackMission()
	if missionCompleted then return end
	if attackTarget ~= nil then return end

        local validzones = {}
        for _, v in ipairs(bc.connections) do
			local from, to = bc:getConnectionZones(v)

		local function checkValid(zone)
			local lname = zone.zone:lower()
			return zone.side == 1 and zone.active and not zone.suspended and not isZoneUnderSEADMission(zone.zone)
			and not lname:find('sam') and not lname:find('defence')
		end

	if from and to and from.side ~= to.side and from.side ~= 0 and to.side ~= 0 then
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
    if missionCompleted then return end
    if resupplyTarget ~= nil then return end

    local validzones = {}
    for _, v in ipairs(bc.zones) do
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

	if zones.khasab.wasBlue then
        trigger.action.setUserFlag(5, true)	
    end

	if zones.alhuti.wasBlue and zones.alain.wasBlue and not zones.khaimah.wasBlue then
        trigger.action.setUserFlag(2, true)	
    end
	if zones.sharjah.wasBlue and zones.dahid.wasBlue and not zones.khasab.wasBlue then
        trigger.action.setUserFlag(5, true)	
    end
	if zones.khasab.wasBlue and not zones.bandarabbas.wasBlue then
        trigger.action.setUserFlag(6, true)
		trigger.action.setUserFlag(5, false)	
    end
	if zones.khaimah.wasBlue then
        trigger.action.setUserFlag(1, true)
		trigger.action.setUserFlag(2, false)
	end

	if zones.echo.wasBlue then
        trigger.action.setUserFlag(132, true)	
    end

	if IsGroupActive('Blue Tanker-Sirri') and zones.kish.wasBlue and zones.lavan.wasBlue then
        trigger.action.setUserFlag(135, true)	
    end

	if zones.golf.wasBlue then
        trigger.action.setUserFlag(133, true)	
    end
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
	if zones.insurgentcamp.side == 1 then
		local g=Group.getByName("InsurgentCamp Fixed Group2")
		if g and g:isExist() then
			if g:getSize() < (g:getInitialSize() * 0.25) then
				trigger.action.setUserFlag(20, true)
			end
		end
	end
end
timer.scheduleFunction(function()
    checkZoneFlags()
    return timer.getTime() + 30
end, {}, timer.getTime() + 3)


buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end

----------------------- END OF FLAGS --------------------------

env.info("ZoneSetup: is completed!")

