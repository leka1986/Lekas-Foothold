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

upgrades = {
	redships = {
		blue = {'blueShip Fixed'},
		red = {'Molniya', 'Molniya', 'Rezky', 'Rezky', 'Neustrashimy', 'Moskva'}
	},
	blueships = {
		blue = {'blueShip'},
		red = {'Moskva'}
	},
	airfield1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM AAA group 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-8 2', 'Red SAM SHORAD SA-8', 'Red SAM AAA 3', 'Red SAM AAA 4'}
	},
	Soganlug = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Red SAM AAA Fixed', 'Red SAM SHORAD SA-15 Fixed Soganlug', 'Red SAM SHORAD SA-8 Fixed'}
	},
	Mineralnye = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM AAA group 2', 'Mineralnye HQ', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Pantsir S1'}
	},
	Novorossiysk = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM AAA group 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-19 2','Communication Tower', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-15'}
	},
	airfield2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM AAA group 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD Pantsir S1', 'Red SAM SHORAD SA-8'}
	},
	Kobuleti = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM AAA group 2', 'Red Armour Group 2', 'Red Armour Group 3','Kobuleti Fuel Tank 2', 'Red SAM SHORAD SA-15','Kobuleti Fuel Tank', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15 2'}
	},
	airfield3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red Armour Group', 'Red armoured group 1', 'Red SAM AAA', 'Red SAM SHORAD Tor M2', 'Red SAM AAA 3','Red SAM AAA 4'}
	},
	Pashkovsky = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red Armour Group', 'Red armoured group 1','Pashkovsky HQ', 'Red SAM AAA','Pashkovsky HQ 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19 2', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}
	},
	Sochi = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Red Armour Group', 'Red armoured group 1','Sochi Communication Tower','Sochi Fuel Tank 3','Red SAM AAA','Red SAM SHORAD SA-19 2', 'Sochi Fuel Tank 2', 'Red SAM SHORAD SA-19','Sochi Fuel Tank', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD Pantsir S1'}
	},
	airfield3Maykop = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red Armour Group', 'Red armoured group 1','Maykop fuel storage', 'Red SAM SHORAD SA-19','Maykop HQ bulding','Red SAM AAA 4', 'Red SAM AAA 3'}
	},
	
	airfield4 = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red SAM AAA', 'Red SAM AAA group 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Pantsir S1'}
	},
	Anapa = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Red SAM AAA group 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Anapa Command Center','Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Pantsir S1'}
	},
	airfield4Kutaisi = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Red SAM AAA', 'Red SAM AAA group 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-15 Fixed','Kutaisi Fuel tank', 'Red SAM SHORAD SA-8 2', 'Kutaisi Fuel tank 2', 'Red SAM SA-6 Fixed Kutaisi', 'Kutaisi Fuel tank 3', 'Kutaisi Fuel tank 4','Red SAM SHORAD Pantsir S1'}
	},
	
	samalphaFixed = {
		blue = {'blueArmor', 'bluePD1'},
		red = {'Red SAM SHORAD SA-15 Fixed alpha', 'Red SAM SA-2 Fixed Alpha', 'Red SAM SA-3 Fixed Alpha'}
	},
	samFoxtrotFixed = {
		blue = {},
		red = {'Red SAM SHORAD SA-19', 'Red SAM SHORAD Fixed', 'Red SAM Fixed SA-2 Foxtrot'}
	},
	sambravoFixed = {
		blue = {'blueHAWK'},
		red = {'Red SAM AAA','Red SAM SHORAD SA-15 Fixed Bravo','Red SAM SA-2 Fixed bravo'}
	},
	
	samgolf = {
		blue = {'blueArmor', 'bluePD1'},
		red = {'Red SAM SA-6 Fixed Golf', 'Red SAM SHORAD SA-19 Fixed Golf-1', 'Red SAM SHORAD SA-19 Fixed Golf-2', 'Red SAM SHORAD SA-19 Fixed Golf-3', 'Red SAM SHORAD SA-19 Fixed Golf-4', 'Red SAM SHORAD SA-15 Fixed Golf-5', 
		'Red SAM SHORAD SA-15 Fixed Golf-6', 'Red SAM SA-10 Fixed Golf'}
	},
	
	sam3 = {
		blue = {'blueArmor', 'bluePD2'},
		red = {'Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2', 'Red SAM SA-6', 'Red SAM SHORAD SA-8'}
	},
	samcharliefixed = {
		blue = {'blueHAWK'},
		red = {'Red SAM AAA', 'Red SAM AAA group 2', 'Red SAM SHORAD SA-15 Fixed Charlie', 'Red SAM SHORAD SA-19 Fixed Charlie-2', 'Red SAM SA-6 Fixed Charlie'}
	},
	sam4indiafixed = {
		blue = {'blueArmor', 'bluePD2'},
		red = {'Red SAM AAA','Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8','Red SAM SHORAD SA-15','Red SAM SA-10 India Fixed', 'Red SAM SHORAD SA-15 2'}
	},
	sam4kilofixed = {
		blue = {'blueArmor', 'bluePD2'},
		red = {'Red SAM AAA','Red SAM SHORAD SA-15','Red SAM SA-10 kilo Fixed', 'Red SAM SHORAD SA-15 2', 'Red SAM AAA group 2'}
	},
	
	samdeltaFixed = {
		blue = {'blueHAWK'},
		red = {'Red SAM AAA','Red SAM SHORAD SA-19 Fixed Delta','Red SAM SA-10 Fixed Delta'}
	},
	sam5 = {
		blue = {'blueArmor', 'blueHAWK'},
		red = {'Red SAM SHORAD SA-15','Red SAM AAA','Red SAM SHORAD SA-8', 'Red SAM AAA group 2', 'Red SAM SA-11', 'Red SAM SHORAD SA-15 2'}
	},
	
	SamLimaFixedSA11 = {
		blue = {},
		red = {'Red SAM SHORAD SA-15 Fixed SAM-Lima', 'Red SAM SA-6 Fixed SAM-Lima', 'Red SAM SA-11 Fixed SAM-Lima'}
	},
	
	sam6 = {
		blue = {},
		red = {'Red SAM SHORAD SA-19 Fixed SAM-Mike', 'Red SAM SHORAD SA-19 Fixed SAM-Mike 2', 'Red SAM SA-5 Fixed SAM-Mike'}
	},
	farp1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces','Red Armour Group', 'Red armoured group 1','Red SAM AAA','Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM AAA group 2'}
	},
	Echo = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces','Echo Troops Tent 2','Red Armour Group', 'Red armoured group 1','Red SAM AAA','Echo Troops Tent','Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8'}
	},
	Alpha = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces','Red Armour Group', 'Red armoured group 1','Alpha Troops Tent','Red SAM AAA','Alpha Troops Tent 2','Red SAM AAA group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19 2'}
	},
	farp2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red Armour Group', 'Red armoured group 1', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8 2', 'Red SAM SHORAD SA-15'}
	},
	farp3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Red Armour Group', 'Red armoured group 1', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}
	},
	Golf = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Red Armour Group 2', 'Red Armour Group 3','Golf Troops Tent 2','Red SAM SHORAD SA-15 2', 'Red SAM SHORAD SA-8','Golf Troops Tent', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8 2'}
	},
	farp4 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8 2'}
	},
	mission1 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy ground forces', 'Red Armour Group', 'Red armoured group 1', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Pantsir S1'}
	},
	MiningFacilityFixed = {
		blue = {},
		red = {'MiningFacility Fixed Group 1','MiningFacility Cargo', 'MiningFacility Factory', 'MiningFacility Fixed Group 2', 'MiningFacility HQ', 'MiningFacility Fixed Group 3', 'MiningFacility Fixed Group 4'}
	},
	TankFactory = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy Task forces', 'Red Armour Group 2', 'Red Armour Group 3','Tank Factory', 'Red SAM SHORAD SA-19','Tank Factory 2', 'Red SAM SHORAD SA-15'}
	},
	insurgentcamp = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy Task forces', 'Red Armour Group 2', 'Red Armour Group 3', 'InsurgentCamp', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19 2', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}
	}, 
	ChemSite = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy Task forces', 'Red SAM AAA','Chemical tank 3','Chemsite Factory','Chemical tank 2', 'Red Armour Group 2', 'Red Armour Group 3','Chemsite Factory 2','Chemical tank', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}
	},
	SecretTechFacility = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy Task forces', 'Red SAM AAA','SecretTechFacility Factory', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-8','SecretTechFacility Factory 2', 'Red SAM SHORAD SA-15', 'SecretTechFacility HQ'}
	}, 
	ArtilleryFactory = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy Task forces', 'Red SAM AAA','Artillery Factory','Artillery Storage', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-8','Artillery Storage 2', 'Red SAM SHORAD SA-15', 'Artillery Storage 3'}
	},
	fueldepo = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy Task forces','FuelDepo Refinery', 'Fuel Depo tank','Red SAM SHORAD SA-8 2', 'Red SAM AAA', 'Fuel Depo tank 2', 'Red Armour Group 2', 'Red Armour Group 3','Fuel Depo tank 3', 'Red SAM SHORAD SA-8', 'Fuel Depo tank 4'}
	},
	SAMEcho = {
		blue = {'blueHAWK'},
		red = {'Red SAM AAA Fixed Echo', 'Red SAM SHORAD SA-15 Fixed Echo', 'Red SAM SA-11 Fixed Echo','Red SAM SHORAD Pantsir S1 Fixed Echo'}
	},
	ammunitiondepounits = {
		blue = {},
		red = {'Red SAM SHORAD SA-15 Fixed ammunitiondepo','Ammunition Storage','Ammunition Storage 2', 'ManPad Fixed AmmonitionDepo','Ammunition Storage 3', 'Fixed Ammunitiondepo Armor', 'Ammunition Storage 4'}
	},
	HiddenGroup = {
		blue = {},
		red = {'hiddenground-Fixed-1', 'hiddenground-Fixed-2', 'hiddenground-Fixed-3','hiddenground-Fixed-4','hiddenground-Fixed-5', 'hiddenground-Fixed-6','hiddenground-Fixed-7'}
	},
	Hidden1Group = {
		blue = {},
		red = {'HQ Fixed', 'Red EWR Fixed 1', 'Red EWR Fixed 3', 'Red EWR Fixed 2', 'Red EWR 4 Fixed'}
	},
	Hidden2Group = {
		blue = {},
		red = {'hiddenground2-Fixed-1', 'hiddenground2-Fixed-2', 'hiddenground2-Fixed-3','hiddenground2-Fixed-4'}
	},
	Hidden3Group = {
		blue = {},
		red = {'hiddenground3-Fixed-1', 'hiddenground3-Fixed-2', 'hiddenground3-Fixed-3','hiddenground3-Fixed-4',
			'hiddenground3-Fixed-5', 'hiddenground3-Fixed-6', 'hiddenground3-Fixed-7'}
	}
}

flavor = {
	redcarrier = 'Enemy carrier zone',
	bluecarrier = 'WPT \nStart zone',
	
	batumi = 'WPT 2\n',
	kobuleti = 'WPT 3\n',
	senaki = 'WPT 4\n',
	kutaisi = 'WPT 5\n',
	alpha = 'WPT 6\n',
	sukhumi = 'WPT 7\n',
	gudauta = 'WPT 8\n',
	sochi = 'WPT 9\n',
	bravo = 'WPT 10\n',
	charlie = 'WPT 11\n',
	delta = 'WPT 12\n',
	gelendzhik = 'WPT 13\n',
	novorossiysk = 'WPT 14\n',
	anapa = 'WPT 15\n',
	krymsk = 'WPT 16\n',
	echo = 'WPT 17\n',
	krasnodarc = 'WPT 18\n',
	krasnodarp = 'WPT 19\n',
	foxtrot = 'WPT 20\n',
	maykop = 'WPT 21\n',
	golf = 'WPT 22\n',
	hotel = 'WPT 23\n',
	india = 'WPT 24\n',
	mineralnye = 'WPT 25\n',
	nalchik = 'WPT 26\n',
	moxdok = 'WPT 27\n',
	beslan = 'WPT 28\n',
	juliett = 'WPT 29\n',
	kilo = 'WPT 30\n', 
	lima = 'WPT 31\n', 
	soganlug= 'WPT 32\n', 
	tbilisi = 'WPT 33\n',
	vaziani = 'WPT 34\n',
	
	miningfacility = 'WPT \n',
	insurgentcamp = 'WPT \n',
	secrettechfacility = 'WPT \n',
	fueldepo = 'WPT \n',
	ammonitiondepo = 'WPT \n',
	tankfactory = 'WPT \n',
	samsite = 'WPT \n',
	chemsite = 'WPT \n',
	artilleryfactory = 'WPT \n',
	
	samalpha = 'WPT \n',
	sambravo = 'WPT \n',
	samcharlie = 'WPT \n',
	samdelta = 'WPT \n',
	samecho = 'WPT \n',
	samfoxtrot = 'WPT \n',
	samgolf = 'WPT \n',
	samhotel = 'WPT \n',
	samindia = 'WPT \n',
	samjuliett = 'WPT \n',
	samkilo = 'WPT \n',
	samlima = 'WPT \n',
	sammike = 'WPT \n'
}
WaypointList = {
    Batumi = ' (2)',
    Kobuleti = ' (3)',
    Senaki = ' (4)',
    Kutaisi = ' (5)',
    Alpha = ' (6)',
    Sukhumi = ' (7)',
    Gudauta = ' (8)',
    Sochi = ' (9)',
    Bravo = ' (10)',
    Charlie = ' (11)',
    Delta = ' (12)',
    Gelendzhik = ' (13)',
    Novorossiysk = ' (14)',
    Anapa = ' (15)',
    Krymsk = ' (16)',
    Echo = ' (17)',
    ["Krasnodar-Center"] = ' (18)',
    ["Krasnodar-Pashkovsky"] = ' (19)',
    Foxtrot = ' (20)',
    Maykop = ' (21)',
    Golf = ' (22)',
    Hotel = ' (23)',
    India = ' (24)',
    Mineralnye = ' (25)',
    Nalchik = ' (26)',
    Mozdok = ' (27)',
    Beslan = ' (28)',
    Juliett = ' (29)',
    Kilo = ' (30)',
    Lima = ' (31)',
    Soganlug = ' (32)',
    Tbilisi = ' (33)',
    Vaziani = ' (34)'
}

local filepath = (Era == 'Coldwar') and 'FootHold_CA_v0.2_Coldwar.lua' or 'FootHold_CA_v0.2.lua'
env.info('[DEBUG] Era='..tostring(Era)..'  ->  '..filepath)
if lfs then 
	local dir = lfs.writedir()..'Missions/Saves/'
	lfs.mkdir(dir)
	filepath = dir..filepath
	env.info('Foothold - Save file path: '..filepath)
end

local cwSwap = {
	['Red armoured group 1']   			= 'Red Armor Group8',
	['Red Armour Group 2']   			= 'Red Armor Group9',
	['Red Armour Group 3']  			= 'Red Armor Group6',
	['Red Armour Group']  				= 'Red Armor Group7',
	['Neustrashimy']  					= 'Molniya',
	['blueArmor']  						= 'blueArmor-Coldwar',
	['bluePD1']  						= 'bluePD1-Coldwar',
	['blueHAWK']  						= 'blueHAWK-Coldwar',
	['Fixed Ammunitiondepo Armor']  	= 'Fixed Ammunitiondepo Armor Coldwar',
	['MiningFacility Fixed Group 1']  	= 'MiningFacility Fixed Group Coldwar',
	['MiningFacility Fixed Group 2']  	= 'MiningFacility Fixed Group 2 Coldwar',
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
	['Red SAM SHORAD SA-15 2']   					= 'Red SAM SHORAD SA-8 2',
	['Red SAM SHORAD SA-15']   						= 'Red SAM SHORAD SA-8',
	['Red SAM SHORAD SA-15 Fixed Soganlug']  		= 'Red SAM SHORAD SA-8 Fixed Soganlug',
	['Red SAM SHORAD SA-15 Fixed SAM-Lima']     	= 'Red SAM SHORAD SA-8 Fixed SAM-Lima',
	['Red SAM SA-11 Fixed SAM-Lima']  				= 'Red SAM SA-3 Fixed SAM-Lima',
	['Red SAM SA-11']  								= 'Red SAM SA-2',
	['Red SAM SA-10 Fixed Golf']  					= 'Red SAM SA-2 Fixed Golf',
	['Red SAM SHORAD SA-15 Fixed Golf-6']  			= 'Red SAM SHORAD SA-8 Fixed Golf-6',
	['Red SAM SHORAD SA-15 Fixed Golf-5']  			= 'Red SAM SHORAD SA-8 Fixed Golf-5',
	['Red SAM SHORAD SA-15 Fixed Charlie']  		= 'Red SAM SHORAD SA-8 Fixed Charlie',
	['Red SAM SHORAD SA-15 Fixed ammunitiondepo']  	= 'Red SAM SHORAD SA-8 Fixed ammunitiondepo',
	['Red SAM SHORAD SA-15 Fixed alpha']  			= 'Red SAM SHORAD SA-8 Fixed alpha',
	['Red SAM SHORAD SA-15 Fixed']  				= 'Red SAM SHORAD SA-8 Fixed 2',
	['Red SAM SA-10 kilo Fixed']  					= 'Red SAM SA-2 kilo Fixed',
	['Red SAM SA-10 India Fixed']  					= 'Red SAM SA-2 India Fixed',
	['Red SAM SA-10 Fixed Delta']  					= 'Red SAM SA-2 Fixed Delta',
	['Red SAM SA-11 Fixed Echo']  					= 'Red SAM SA-6 Fixed Echo',
	['Red SAM SHORAD Pantsir S1']  					= 'Red SAM SHORAD SA-8',
	['Red SAM SHORAD Tor M2']  						= 'Red SAM SHORAD SA-8',
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
	redcarrier = ZoneCommander:new({zone='Red Carrier', side=1, level=25, upgrades=upgrades.redships, crates={}, flavorText=flavor.redcarrier}),
	bluecarrier = ZoneCommander:new({zone='Blue Carrier', side=2, level=25, upgrades=upgrades.blueships, crates={}, flavorText=flavor.bluecarrier}),
	
	batumi = ZoneCommander:new({zone='Batumi', side=2, level=25, upgrades=upgrades.airfield1, crates={}, flavorText=flavor.batumi}),
	kobuleti = ZoneCommander:new({zone='Kobuleti', side=1, level=25, upgrades=upgrades.Kobuleti, crates={}, flavorText=flavor.kobuleti}),
	senaki = ZoneCommander:new({zone='Senaki', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.senaki}),
	kutaisi = ZoneCommander:new({zone='Kutaisi', side=1, level=25, upgrades=upgrades.airfield4Kutaisi, crates={}, flavorText=flavor.kutaisi}),
	sukhumi = ZoneCommander:new({zone='Sukhumi', side=1, level=25, upgrades=upgrades.airfield1, crates={}, flavorText=flavor.sukhumi}),
	gudauta = ZoneCommander:new({zone='Gudauta', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.gudauta}),
	sochi = ZoneCommander:new({zone='Sochi', side=1, level=25, upgrades=upgrades.Sochi, crates={}, flavorText=flavor.sochi}),
	gelendzhik = ZoneCommander:new({zone='Gelendzhik', side=1, level=25, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.gelendzhik}),
	novorossiysk = ZoneCommander:new({zone='Novorossiysk', side=1, level=25, upgrades=upgrades.Novorossiysk, crates={}, flavorText=flavor.novorossiysk}),
	anapa = ZoneCommander:new({zone='Anapa', side=1, level=25, upgrades=upgrades.Anapa, crates={}, flavorText=flavor.anapa}),
	krymsk = ZoneCommander:new({zone='Krymsk', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.krymsk}),
	krasnodarc = ZoneCommander:new({zone='Krasnodar-Center', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.krasnodarc}),
	krasnodarp = ZoneCommander:new({zone='Krasnodar-Pashkovsky', side=1, level=25, upgrades=upgrades.Pashkovsky, crates={}, flavorText=flavor.krasnodarp}),
	maykop = ZoneCommander:new({zone='Maykop', side=1, level=25, upgrades=upgrades.airfield3Maykop, crates={}, flavorText=flavor.maykop}),
	mineralnye = ZoneCommander:new({zone='Mineralnye', side=1, level=25, upgrades=upgrades.Mineralnye, crates={}, flavorText=flavor.mineralnye}),
	nalchik = ZoneCommander:new({zone='Nalchik', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.nalchik}),
	mozdok = ZoneCommander:new({zone='Mozdok', side=1, level=25, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.mozdok}),
	beslan = ZoneCommander:new({zone='Beslan', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.beslan}),
	soganlug = ZoneCommander:new({zone='Soganlug', side=1, level=25, upgrades=upgrades.Soganlug, crates={}, flavorText=flavor.soganlug}),
	tbilisi = ZoneCommander:new({zone='Tbilisi', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.tbilisi}),
	vaziani = ZoneCommander:new({zone='Vaziani', side=1, level=25, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.vaziani}),
	
	alpha = ZoneCommander:new({zone='Alpha', side=1, level=25, upgrades=upgrades.Alpha, crates={}, flavorText=flavor.alpha}),
	bravo = ZoneCommander:new({zone='Bravo', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.bravo}),
	charlie = ZoneCommander:new({zone='Charlie', side=1, level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.charlie}),
	delta = ZoneCommander:new({zone='Delta', side=1, level=25, upgrades=upgrades.farp4, crates={}, flavorText=flavor.delta}),
	echo = ZoneCommander:new({zone='Echo', side=1, level=25, upgrades=upgrades.Echo, crates={}, flavorText=flavor.echo}),
	foxtrot = ZoneCommander:new({zone='Foxtrot', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.foxtrot}),
	golf = ZoneCommander:new({zone='Golf', side=1, level=25, upgrades=upgrades.Golf, crates={}, flavorText=flavor.golf}),
	hotel = ZoneCommander:new({zone='Hotel', side=1, level=25, upgrades=upgrades.farp4, crates={}, flavorText=flavor.hotel}),
	india = ZoneCommander:new({zone='India', side=1, level=25, upgrades=upgrades.farp1, crates={}, flavorText=flavor.india}),
	juliett = ZoneCommander:new({zone='Juliett', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.juliett}),
	kilo = ZoneCommander:new({zone='Kilo', side=1, level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.kilo}),
	lima = ZoneCommander:new({zone='Lima', side=1, level=25, upgrades=upgrades.farp4, crates={}, flavorText=flavor.lima}),
	
	miningfacility = ZoneCommander:new({zone='MiningFacility', side=1, level=25, upgrades=upgrades.MiningFacilityFixed, crates={}, flavorText=flavor.miningfacility}),
	insurgentcamp = ZoneCommander:new({zone='InsurgentCamp', side=1, level=25, upgrades=upgrades.insurgentcamp, crates={}, flavorText=flavor.insurgentcamp}),
	secrettechfacility = ZoneCommander:new({zone='SecretTechFacility', side=1, level=25, upgrades=upgrades.SecretTechFacility, crates={}, flavorText=flavor.secrettechfacility}),
	fueldepo = ZoneCommander:new({zone='FuelDepo', side=1, level=20, upgrades=upgrades.fueldepo, crates={}, flavorText=flavor.fueldepo}),
	ammonitiondepo = ZoneCommander:new({zone='AmmonitionDepo', side=1, level=25, upgrades=upgrades.ammunitiondepounits, crates={}, flavorText=flavor.ammonitiondepo}),
	tankfactory = ZoneCommander:new({zone='TankFactory', side=1, level=25, upgrades=upgrades.TankFactory, crates={}, flavorText=flavor.tankfactory}),
	chemsite = ZoneCommander:new({zone='ChemSite', side=1, level=25, upgrades=upgrades.ChemSite, crates={}, flavorText=flavor.chemsite}),
	artilleryfactory = ZoneCommander:new({zone='ArtilleryFactory', side=1, level=25, upgrades=upgrades.ArtilleryFactory, crates={}, flavorText=flavor.artilleryfactory}),
	samsite = ZoneCommander:new({zone='SAMSite', side=1, level=25, upgrades=upgrades.sam5, crates={}, flavorText=flavor.samsite}),

	samalpha = ZoneCommander:new({zone='SAM-Alpha', side=1, level=25, upgrades=upgrades.samalphaFixed, crates={}, flavorText=flavor.samalpha}),
	sambravo = ZoneCommander:new({zone='SAM-Bravo', side=1, level=25, upgrades=upgrades.sambravoFixed, crates={}, flavorText=flavor.sambravo}),
	samcharlie = ZoneCommander:new({zone='SAM-Charlie', side=1, level=25, upgrades=upgrades.samcharliefixed, crates={}, flavorText=flavor.samcharlie}),
	samdelta = ZoneCommander:new({zone='SAM-Delta', side=1, level=25, upgrades=upgrades.samdeltaFixed, crates={}, flavorText=flavor.samdelta}),
	samecho = ZoneCommander:new({zone='SAM-Echo', side=1, level=25, upgrades=upgrades.SAMEcho, crates={}, flavorText=flavor.samecho}),
	samfoxtrot = ZoneCommander:new({zone='SAM-Foxtrot', side=1, level=25, upgrades=upgrades.samFoxtrotFixed, crates={}, flavorText=flavor.samfoxtrot}),
	samgolf = ZoneCommander:new({zone='SAM-Golf', side=1, level=25, upgrades=upgrades.samgolf, crates={}, flavorText=flavor.samgolf}),
	samhotel = ZoneCommander:new({zone='SAM-Hotel', side=1, level=25, upgrades=upgrades.sam3, crates={}, flavorText=flavor.samhotel}),
	samindia = ZoneCommander:new({zone='SAM-India', side=1, level=25, upgrades=upgrades.sam4indiafixed, crates={}, flavorText=flavor.samindia}),
	samjuliett = ZoneCommander:new({zone='SAM-Juliett', side=1, level=25, upgrades=upgrades.sam5, crates={}, flavorText=flavor.samjuliett}),
	samkilo = ZoneCommander:new({zone='SAM-Kilo', side=1, level=25, upgrades=upgrades.sam4kilofixed, crates={}, flavorText=flavor.samkilo}),
	samlima = ZoneCommander:new({zone='SAM-Lima', side=1, level=25, upgrades=upgrades.SamLimaFixedSA11, crates={}, flavorText=flavor.samlima}),
	sammike = ZoneCommander:new({zone='SAM-Mike', side=1, level=25, upgrades=upgrades.sam6, crates={}, flavorText=flavor.sammike}),
	hidden = ZoneCommander:new({zone='Hidden', side=0, level=25, upgrades=upgrades.HiddenGroup, crates={}, flavorText=flavor.hidden0,NeutralAtStart=true}),
	hidden1 = ZoneCommander:new({zone='Hidden1', side=1, level=25, upgrades=upgrades.Hidden1Group, crates={}, flavorText=flavor.hidden1}),
	hidden2 = ZoneCommander:new({zone='Hidden2', side=0, level=25, upgrades=upgrades.Hidden2Group, crates={}, flavorText=flavor.hidden2,NeutralAtStart=true}),
	hidden3 = ZoneCommander:new({zone='Hidden3', side=0, level=25, upgrades=upgrades.Hidden3Group, crates={}, flavorText=flavor.hidden3,NeutralAtStart=true}),
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
        'BLUE_UH-60A',
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

	CapCarrierGroup = CapCarrierGroup or {
        'BLUE_F14A',
        'BLUE_HORNET_CW',
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

	CapCarrierGroup = CapCarrierGroup or {
        'BLUE_HORNET',
        'BLUE_F14B',
	}

	-- Strike planes for runway attacks

	RunwayStrikePlaneTemplate = RunwayStrikePlaneTemplate or {
        "RED_MIG-27K",
        "RED_SU-33",
    }

end

SupplyConvoy = SupplyConvoy or {
    "SupplyConvoy 1",
    "SupplyConvoy 2",
    "SupplyConvoy 3",
    "SupplyConvoy_Blue 1",
}

SupplyPlaneTemplate = SupplyPlaneTemplate or {
	"IL-76MD",
	"C-17A",
}

function CasAltitude() return math.random(15,25)*1000 end
function CapAltitude() return math.random(22,32)*1000 end
function SeadAltitude() return math.random(25,33)*1000 end
function RunwayStrikeAltitude() return math.random(23,28)*1000 end

-- Spawn bases
zones.batumi.isHeloSpawn = true
zones.kobuleti.isHeloSpawn = true
zones.senaki.isHeloSpawn = true
zones.kutaisi.isHeloSpawn = true
zones.alpha.isHeloSpawn = true
zones.sukhumi.isHeloSpawn = true
zones.gudauta.isHeloSpawn = true
zones.sochi.isHeloSpawn = true
zones.bravo.isHeloSpawn = true
zones.charlie.isHeloSpawn = true
zones.delta.isHeloSpawn = true
zones.gelendzhik.isHeloSpawn = true
zones.novorossiysk.isHeloSpawn = true
zones.anapa.isHeloSpawn = true
zones.krymsk.isHeloSpawn = true
zones.echo.isHeloSpawn = true
zones.krasnodarc.isHeloSpawn = true
zones.krasnodarp.isHeloSpawn = true
zones.foxtrot.isHeloSpawn = true
zones.maykop.isHeloSpawn = true
zones.golf.isHeloSpawn = true
zones.hotel.isHeloSpawn = true
zones.india.isHeloSpawn = true
zones.mineralnye.isHeloSpawn = true
zones.nalchik.isHeloSpawn = true
zones.mozdok.isHeloSpawn = true
zones.beslan.isHeloSpawn = true
zones.juliett.isHeloSpawn = true
zones.kilo.isHeloSpawn = true
zones.lima.isHeloSpawn = true
zones.soganlug.isHeloSpawn = true
zones.tbilisi.isHeloSpawn = true
zones.vaziani.isHeloSpawn = true
zones.redcarrier.isHeloSpawn = true
zones.bluecarrier.isHeloSpawn = true

-- AirBase names
zones.batumi.airbaseName = 'Batumi'
zones.kobuleti.airbaseName = 'Kobuleti'
zones.kutaisi.airbaseName = 'Kutaisi'
zones.maykop.airbaseName = 'Maykop-Khanskaya'
zones.anapa.airbaseName = 'Anapa-Vityazevo'
zones.senaki.airbaseName = 'Senaki-Kolkhi'
zones.sukhumi.airbaseName = 'Sukhumi-Babushara'
zones.gudauta.airbaseName = 'Gudauta'
zones.sochi.airbaseName = 'Sochi-Adler'
zones.mineralnye.airbaseName = 'Mineralnye Vody'
zones.nalchik.airbaseName = 'Nalchik'
zones.mozdok.airbaseName = 'Mozdok'
zones.beslan.airbaseName = 'Beslan'
zones.krasnodarp.airbaseName = 'Krasnodar-Pashkovsky'
zones.krasnodarc.airbaseName = 'Krasnodar-Center'
zones.krymsk.airbaseName = 'Krymsk'
zones.gelendzhik.airbaseName = 'Gelendzhik'
zones.novorossiysk.airbaseName = 'Novorossiysk'
zones.tbilisi.airbaseName = 'Tbilisi-Lochini'
zones.vaziani.airbaseName = 'Vaziani'
zones.soganlug.airbaseName = 'Soganlug'

zones.bluecarrier.airbaseName = 'CVN-72'
zones.redcarrier.airbaseName = 'CVN-73'

-- FARP Zones
zones.lima.airbaseName = 'Lima'
zones.kilo.airbaseName = 'Kilo'
zones.juliett.airbaseName = 'Juliett'
zones.india.airbaseName = 'India'
zones.hotel.airbaseName = 'Hotel'
zones.golf.airbaseName = 'Golf'
zones.foxtrot.airbaseName = 'Foxtrot'
zones.echo.airbaseName = 'Echo'
zones.delta.airbaseName = 'Delta'
zones.charlie.airbaseName = 'Charlie'
zones.bravo.airbaseName = 'Bravo'
zones.alpha.airbaseName = 'Alpha'

zones.bluecarrier:addGroups({
	GroupCommander:new({name='carrier-attack-Senaki', mission='attack',template='CapCarrierGroup',MissionType='CAP', targetzone='Senaki', Altitude = CapAltitude()}),
	GroupCommander:new({name='carrier-patrol-Kobuleti', mission='patrol',template='CapCarrierGroup',MissionType='CAP', targetzone='Kobuleti', Altitude = CapAltitude()}),
	GroupCommander:new({name='Blue-carrier-capture-Red-carrier-blue', mission='supply', targetzone='Red Carrier', type='surface', urgent = function() return zones.redcarrier.side == 0 and (not zones.gudauta.side == 2) end, ForceUrgent = true})
})

zones.redcarrier:addGroups({
	GroupCommander:new({name='Red-carrier-capture-Blue-carrier-blue', mission='supply', targetzone='Blue Carrier', type='surface', urgent = function() return zones.bluecarrier.side == 0 end, ForceUrgent = true}),
	
})
zones.kobuleti:addGroups({
	GroupCommander:new({name='Support-SAM-Alpha', mission='supply', targetzone='SAM-Alpha',template='SupplyConvoy', type='surface'}),
	GroupCommander:new({name='Kobuleti-supply-Senaki', mission='supply',template='HeloSupplyTemplate', targetzone='Senaki'})
})
zones.batumi:addGroups({
	GroupCommander:new({name='Batumi-supply-carrier-blue', mission='supply', targetzone='Blue Carrier', type='surface', urgent = function() return zones.bluecarrier.side == 0 end, ForceUrgent = true}),
	GroupCommander:new({name='Batumi-supply-Kobuleti', mission='supply',template='HeloSupplyTemplate', targetzone='Kobuleti'})
})
zones.senaki:addGroups({
	GroupCommander:new({name='Support-SAM-Bravo', mission='supply',template='SupplyConvoy', targetzone='SAM-Bravo', type='surface'}),
	GroupCommander:new({name='senaki-supply-kutaisi', mission='supply',template='HeloSupplyTemplate', targetzone='Kutaisi'}),
	GroupCommander:new({name='senaki-supply-alpha', mission='supply',template='HeloSupplyTemplate', targetzone='Alpha'}),

})
zones.kutaisi:addGroups({
	GroupCommander:new({name='kutaisi-supply-senaki', mission='supply',template='HeloSupplyTemplate', targetzone='Senaki'}),
	GroupCommander:new({name='kutaisi-supply-kobuleti', mission='supply', template='HeloSupplyTemplate', targetzone='Kobuleti'}),
	GroupCommander:new({name='Support-SAM-Charlie', mission='supply',template='SupplyConvoy', targetzone='SAM-Charlie', type='surface'}),
	GroupCommander:new({name='kutaisi-attack-kobuleti-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Kobuleti'}),
	GroupCommander:new({name='kutaisi-attack-senaki-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Senaki'}),
	GroupCommander:new({name='Kutaisi-patrol-Senaki-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Senaki', Altitude = CapAltitude()}),
	GroupCommander:new({name='Kutaisi-patrol-Kobuleti-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kobuleti', Altitude = CapAltitude()}),
	GroupCommander:new({name='Kutaisi-Patrol-Kutaisi-Cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Kutaisi', Altitude = CapAltitude()}),
	GroupCommander:new({name='Kutaisi-attack-Senaki', mission='attack',template='AttackConvoy', targetzone='Senaki', type='surface'}),
	GroupCommander:new({name='Kutaisi-attack-Sukhumi', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Sukhumi', Altitude = CapAltitude()}),

})
zones.sukhumi:addGroups({
	GroupCommander:new({name='Support-SAM-Delta', mission='supply',template='SupplyConvoy', targetzone='SAM-Delta', type='surface'}),
	GroupCommander:new({name='sukhumi-attack-Sochi', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Sochi', Bluecondition = function() return not zones.samdelta.active end, Altitude = CapAltitude()}),
	GroupCommander:new({name='Sukhumi-supply-gudauta', mission='supply',template='HeloSupplyTemplate', targetzone='Gudauta'}),
	GroupCommander:new({name='Sukhumi-supply-alpha', mission='supply',template='HeloSupplyTemplate', targetzone='Alpha'}),
	GroupCommander:new({name='Sukhumi-attack-Kutaisi-RunwayStrike', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Kutaisi'}),
	GroupCommander:new({name='Sukhumi-patrol-Alpha', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Alpha', Altitude = CapAltitude()}),
	GroupCommander:new({name='Sukhumi-attack-Alpha', mission='attack',template='AttackConvoy', targetzone='Alpha', type='surface'}),
})
zones.gudauta:addGroups({
	GroupCommander:new({name='Gudauta-supply-sochi', mission='supply',template='HeloSupplyTemplate', targetzone='Sochi'}),
	GroupCommander:new({name='Gudauta-supply-sukhumi', mission='supply',template='HeloSupplyTemplate', targetzone='Sukhumi'}),
	GroupCommander:new({name='Gudauta-attack-Sukhumi', mission='attack',template='AttackConvoy', targetzone='Sukhumi', type='surface'}),
})

zones.sochi:addGroups({
	
	GroupCommander:new({name='Support-SAM-Echo', mission='supply',template='SupplyConvoy', targetzone='SAM-Echo', type='surface'}),
	GroupCommander:new({name='sochi-attack-gudauta-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Gudauta'}),
	GroupCommander:new({name='sochi-attack-sukhumi-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Sukhumi'}),
	GroupCommander:new({name='Sochi-attack-kutaisi-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Kutaisi', Altitude = CapAltitude()}),
	GroupCommander:new({name='sochi-attack-Senaki-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Senaki'}),
	GroupCommander:new({name='sochi-attack-Kutaisi-Cas', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kutaisi', Altitude = CapAltitude()}),
	GroupCommander:new({name='sochi-patrol-Sukhumi-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Sukhumi', Altitude = CapAltitude()}),
	GroupCommander:new({name='sochi-patrol-Red-Carrier-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Red Carrier', Altitude = CapAltitude()}),
	GroupCommander:new({name='sochi-supply-bravo', mission='supply',template='HeloSupplyTemplate', targetzone='Bravo'}),
	GroupCommander:new({name='sochi-supply-gudauta', mission='supply',template='HeloSupplyTemplate', targetzone='Gudauta'}),
	GroupCommander:new({name='Sochi-supply-anapa-by-air', mission='supply',template='SupplyPlaneTemplate', targetzone='Anapa'}),
	GroupCommander:new({name='Sochi-supply-mykop-by-air', mission='supply',template='SupplyPlaneTemplate', targetzone='Maykop'})
})
zones.bravo:addGroups({
	GroupCommander:new({name='Bravo-supply-Sochi', mission='supply',template='HeloSupplyTemplate', targetzone='Sochi'}),
	GroupCommander:new({name='Bravo-supply-Charlie', mission='supply',template='HeloSupplyTemplate', targetzone='Charlie'}),
	GroupCommander:new({name='Bravo-attack-Sochi', mission='attack',template='AttackConvoy', targetzone='Sochi', type='surface'}),
})
zones.alpha:addGroups({
	GroupCommander:new({name='alpha-supply-sukhumi',template='HeloSupplyTemplate', mission='supply', targetzone='Sukhumi'}),
	GroupCommander:new({name='Alpha-attack-kutaisi-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Kutaisi',diceChance = 30}),
	
})
zones.charlie:addGroups({
	GroupCommander:new({name='Charlie-supply-Delta', mission='supply',template='HeloSupplyTemplate', targetzone='Delta'}),
	GroupCommander:new({name='Charlie-attack-bravo', mission='attack',template='AttackConvoy', targetzone='Bravo', type='surface'}),
	GroupCommander:new({name='Charlie-supply-bravo-Convoy', mission='supply',template='SupplyConvoy', targetzone='Bravo', type='surface'}),
})
zones.delta:addGroups({
	GroupCommander:new({name='Delta-supply-Gelendzhik', mission='supply',template='HeloSupplyTemplate', targetzone='Gelendzhik'})
})
zones.novorossiysk:addGroups({
	GroupCommander:new({name='Support-SAM-Foxtrot', mission='supply',template='SupplyConvoy', targetzone='SAM-Foxtrot', type='surface'}),
	GroupCommander:new({name='novorossiysk-supply-Anapa', mission='supply',template='HeloSupplyTemplate', targetzone='Anapa'}),
	GroupCommander:new({name='novorossiysk-supply-Krymsk', mission='supply',template='HeloSupplyTemplate', targetzone='Novorossiysk'})
})
zones.gelendzhik:addGroups({
	GroupCommander:new({name='Gelendzhik-supply-delta', mission='supply',template='HeloSupplyTemplate', targetzone='Delta'}),
	GroupCommander:new({name='Gelendzhik-supply-Novorossiysk', mission='supply',template='HeloSupplyTemplate', targetzone='Novorossiysk'}),
	GroupCommander:new({name='Gelendzhik-patrol-Charlie', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Charlie', Altitude = CapAltitude()}),
	GroupCommander:new({name='Gelendzhik-attack-Charlie', mission='attack',template='AttackConvoy', targetzone='Charlie',type='surface'}),
})
zones.anapa:addGroups({
	GroupCommander:new({name='Anapa-attack-Krymsk-Cas', mission='attack',template='CasHeloTemplate', MissionType='CAS', targetzone='Krymsk'}),
	GroupCommander:new({name='Anapa-attack-Sochi-Cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Sochi', Altitude = CasAltitude()}),
	GroupCommander:new({name='Anapa-attack-Novorossiysk-Cas', mission='attack',template='CasHeloTemplate', MissionType='CAS', targetzone='Novorossiysk'}),
	GroupCommander:new({name='Anapa-attack-Gelendzhik-Cas', mission='attack',template='CasHeloTemplate', MissionType='CAS', targetzone='Gelendzhik'}),
	GroupCommander:new({name='Anapa-patrol-Novorossiysk-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Novorossiysk', Altitude = CapAltitude()}),
	GroupCommander:new({name='Anapa-patrol-Red-carrier-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Red Carrier', Altitude = CapAltitude()}),
	GroupCommander:new({name='Anapa-patrol-Sochi-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Sochi', Altitude = CapAltitude()}),
	GroupCommander:new({name='Anapa-supply-Krymsk', mission='supply',template='HeloSupplyTemplate', targetzone='Krymsk'}),
	GroupCommander:new({name='Anapa-supply-Novorossiysk', mission='supply',template='HeloSupplyTemplate', targetzone='Novorossiysk'}),
	GroupCommander:new({name='Anapa-supply-Gelendzhik', mission='supply',template='HeloSupplyTemplate', targetzone='Gelendzhik'}),
	GroupCommander:new({name='Anapa-supply-Sochi-by-air', mission='supply', template='SupplyPlaneTemplate', targetzone='Sochi'}),
	GroupCommander:new({name='Anapa-supply-SAM-Golf', mission='supply',template='SupplyConvoy', targetzone='SAM-Golf', type='surface'})
})
zones.krymsk:addGroups({
	GroupCommander:new({name='Krymsk-Patrol-Anapa-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Anapa', Altitude = CapAltitude()}),
	GroupCommander:new({name='krymsk-supply-Anapa', mission='supply',template='HeloSupplyTemplate', targetzone='Anapa'}),
	GroupCommander:new({name='Krymsk-supply-Echo', mission='supply', template='HeloSupplyTemplate', targetzone='Echo'})
})

zones.echo:addGroups({
	GroupCommander:new({name='Echo-attack-Krymsk-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Krymsk'}),
	GroupCommander:new({name='Echo-supply-krymsk', mission='supply', template='HeloSupplyTemplate', targetzone='Krymsk'}),
	GroupCommander:new({name='Echo-supply-krasnodar-center', mission='supply', template='HeloSupplyTemplate', targetzone='Krasnodar-Center'})
})

zones.krasnodarc:addGroups({
	GroupCommander:new({name='krasnodarc-attack-Anapa-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Anapa', Altitude = CapAltitude()}),
	GroupCommander:new({name='krasnodarc-attack-Anapa-Sead', mission='attack',template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Anapa', Altitude = SeadAltitude()}),
	GroupCommander:new({name='krasnodarc-supply-Echo', mission='supply', template='HeloSupplyTemplate', targetzone='Echo'}),
	GroupCommander:new({name='krasnodarc-supply-krasnodarp', mission='supply', template='SupplyConvoy', targetzone='Krasnodar-Pashkovsky', type='surface'}),
	GroupCommander:new({name='krasnodarc-attack-krasnodarp', mission='attack', template='AttackConvoy', targetzone='Krasnodar-Pashkovsky', type='surface'})
})

zones.krasnodarp:addGroups({
	GroupCommander:new({name='krasnodarp-attack-sochi-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Sochi', Altitude = CapAltitude(), Redcondition = function() return not zones.krasnodarc.side == 1 end}),
	GroupCommander:new({name='krasnodarp-attack-sochi-RwyStr', mission='attack',template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Krymsk', Altitude = RunwayStrikeAltitude(), Redcondition = function() return not zones.krasnodarc.side == 1 end}),
	GroupCommander:new({name='krasnodarp-patrol-Krymsk-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Krymsk', Altitude = CapAltitude(), Redcondition = function() return not zones.krasnodarc.side == 1 end}),
	GroupCommander:new({name='krasnodarp-attack-Krymsk-Cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Krymsk', Altitude = CasAltitude(), Redcondition = function() return not zones.krasnodarc.side == 1 end}),
	GroupCommander:new({name='krasnodarp-supply-Maykop', mission='supply',template='SupplyConvoy', targetzone='Maykop', type='surface'}),
	GroupCommander:new({name='krasnodarp-supply-SAM-Hotel', mission='supply',template='SupplyConvoy', targetzone='SAM-Hotel', type='surface'}),
	GroupCommander:new({name='Support-supply-Krasnodar-Center', mission='supply',template='SupplyConvoy', targetzone='Krasnodar-Center', type='surface'}),
	GroupCommander:new({name='krasnodarp-supply-Foxtrot', mission='supply',template='HeloSupplyTemplate', targetzone='Foxtrot'})
})

zones.foxtrot:addGroups({
	GroupCommander:new({name='Foxtrot-supply-Maykop', mission='supply', targetzone='Maykop'})
	
})
zones.maykop:addGroups({
	GroupCommander:new({name='Maykop-attack-Krasnodar-P', mission='attack',template='CasHeloTemplate', MissionType='CAS', targetzone='Krasnodar-Pashkovsky'}),
	GroupCommander:new({name='Maykop-attack-Charlie', mission='attack',template='CasHeloTemplate', MissionType='CAS', targetzone='Charlie'}),
	GroupCommander:new({name='Maykop-attack-Krasnodar-P', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Krasnodar-Pashkovsky', Altitude = CasAltitude()}),
	GroupCommander:new({name='Maykop-attack-krymsk-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Krymsk', Altitude = CapAltitude()}),
	GroupCommander:new({name='Maykop-patrol-sochi-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Sochi', Altitude = CapAltitude()}),
	GroupCommander:new({name='Maykop-Patrol-Krymsk-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Krymsk', Altitude = CapAltitude()}),
	GroupCommander:new({name='Maykop-Patrol-Krymsk-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Anapa', Altitude = CapAltitude()}),
	GroupCommander:new({name='Maykop-supply-Krasnodar-P', mission='supply',template='HeloSupplyTemplate', targetzone='Krasnodar-Pashkovsky'}),
	GroupCommander:new({name='Maykop-supply-Krasnodar-C', mission='supply',template='HeloSupplyTemplate', targetzone='Krasnodar-Center'}),
	GroupCommander:new({name='Maykop-supply-Foxtrot', mission='supply',template='HeloSupplyTemplate', targetzone='Foxtrot'}),
	GroupCommander:new({name='Maykop-supply-Charlie', mission='supply',template='HeloSupplyTemplate', targetzone='Charlie'}),
	GroupCommander:new({name='Maykop-supply-Bravo', mission='supply',template='HeloSupplyTemplate', targetzone='Bravo'}),
	GroupCommander:new({name='Maykop-supply-Golf', mission='supply',template='HeloSupplyTemplate', targetzone='Golf'}),
	GroupCommander:new({name='Maykop-supply-Delta', mission='supply',template='HeloSupplyTemplate', targetzone='Delta'}),
	GroupCommander:new({name='Maykop-supply-SAMSite', mission='supply',template='HeloSupplyTemplate', targetzone='SAMSite'}),
	GroupCommander:new({name='Maykop-supply-Sochi', mission='supply',template='SupplyPlaneTemplate', targetzone='Sochi'}),
	GroupCommander:new({name='Maykop-supply-mineralnye', mission='supply',template='SupplyPlaneTemplate', targetzone='Mineralnye'}),
	GroupCommander:new({name='Maykop-supply-SAM-India', mission='supply',template='SupplyConvoy', targetzone='SAM-India', type='surface'})
})


zones.golf:addGroups({
	GroupCommander:new({name='Golf-supply-Maykop', mission='supply',template='HeloSupplyTemplate', targetzone='Maykop'}),
	GroupCommander:new({name='Golf-supply-hotel', mission='supply',template='HeloSupplyTemplate', targetzone='Hotel'}),
	GroupCommander:new({name='Golf-attack-hotel', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Maykop'})
})
zones.hotel:addGroups({
	GroupCommander:new({name='Hotel-supply-Golf', mission='supply',template='HeloSupplyTemplate', targetzone='Golf'}),
	GroupCommander:new({name='hotel-supply-india', mission='supply',template='HeloSupplyTemplate', targetzone='India'})
})
zones.india:addGroups({
	GroupCommander:new({name='India-supply-Hotel', mission='supply',template='HeloSupplyTemplate', targetzone='Hotel'}),
	GroupCommander:new({name='India-supply-Mineralnye', mission='supply', template='HeloSupplyTemplate', targetzone='Mineralnye'})
})
zones.mozdok:addGroups({
	GroupCommander:new({name='mozdok-attack-mineralnye-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Mineralnye'}),
	GroupCommander:new({name='mozdok-attack-mineralnye-Runwaystrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Mineralnye', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='mozdok-attack-nalchik-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Nalchik'}),
	GroupCommander:new({name='Mozdok-attack-beslan-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Beslan', Altitude = CapAltitude()}),
	GroupCommander:new({name='Mozdok-patrol-Mineralnye-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Mineralnye', Altitude = CapAltitude()}),
	GroupCommander:new({name='Mozdok-Attack-Maykop-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Mineralnye', Altitude = CapAltitude()}),
	GroupCommander:new({name='mozdok-supply-nalchik', mission='supply', template='SupplyPlaneTemplate', targetzone='Nalchik'}),
	GroupCommander:new({name='Mozdok-supply-Beslan', mission='supply', template='SupplyPlaneTemplate', targetzone='Beslan'}),
	GroupCommander:new({name='Mozdok-supply-Mineralnye', mission='supply',template='SupplyPlaneTemplate', targetzone='Mineralnye'}),
	GroupCommander:new({name='Mozdok-Support-SAM-Kilo', mission='supply', template='SupplyConvoy', targetzone='SAM-Kilo', type='surface'})
})

zones.nalchik:addGroups({
	GroupCommander:new({name='nalchik-supply-mozdok', mission='supply', template='HeloSupplyTemplate', targetzone='Mozdok'}),
	GroupCommander:new({name='Nalchik-Attack-Kutaisi-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Kutaisi', Altitude = CapAltitude()}),
	GroupCommander:new({name='Nalshik-attack-minieralnye-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mineralnye', Altitude = CapAltitude()}),
	GroupCommander:new({name='Nalchik-supply-Beslan', mission='supply', template='HeloSupplyTemplate', targetzone='Beslan'}),
	GroupCommander:new({name='nalchik-supply-Mineralnye', mission='supply', template='HeloSupplyTemplate', targetzone='Mineralnye'})
})
zones.beslan:addGroups({
	GroupCommander:new({name='Beslan-patrol-beslan', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Beslan', Altitude = CapAltitude()}),
	GroupCommander:new({name='Beslan-attack-mozdok', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Mozdok', Altitude = CasAltitude()}),
	GroupCommander:new({name='Beslan-attack-Mineralnye', mission='attack', template='CapPlaneTemplate', MissionType='CAS', targetzone='Mineralnye', Altitude = CasAltitude()}),
	GroupCommander:new({name='Beslan-attack-Nalchik', mission='attack', template='CapPlaneTemplate', MissionType='CAS', targetzone='Nalchik', Altitude = CasAltitude()}),
	GroupCommander:new({name='Beslan-supply-juliett', mission='supply', template='HeloSupplyTemplate', targetzone='Juliett'}),
	GroupCommander:new({name='Beslan-supply-Mozdok', mission='supply', template='HeloSupplyTemplate', targetzone='Mozdok'}),
})
zones.juliett:addGroups({
	GroupCommander:new({name='Juliet-supply-Kilo', mission='supply', template='HeloSupplyTemplate', targetzone='Kilo'}),
	GroupCommander:new({name='Juliet-supply-Beslan', mission='supply', template='HeloSupplyTemplate', targetzone='Beslan'}),
	GroupCommander:new({name='Juliet-attack-Beslan', mission='attack', template='AttackConvoy', targetzone='Beslan', type='surface'}),
})
zones.kilo:addGroups({
	GroupCommander:new({name='Kilo-supply-Lima', mission='supply', template='HeloSupplyTemplate', targetzone='Lima'}),
	GroupCommander:new({name='Kilo-attack-Juliet-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Juliett'}),
	GroupCommander:new({name='Kilo-supply-Juliet', mission='supply', template='HeloSupplyTemplate', targetzone='Juliett'})
})
zones.lima:addGroups({
	GroupCommander:new({name='Lima-supply-Tbilisi', mission='supply', template='HeloSupplyTemplate', targetzone='Tbilisi'}),
})
zones.mineralnye:addGroups({
	GroupCommander:new({name='Mineralnye-supply-SAM-Juliett', mission='supply',template='SupplyConvoy', targetzone='SAM-Juliett', type='surface'}),
	GroupCommander:new({name='Mineralnye-patrol-Maykop-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Maykop', Altitude = CapAltitude()}),
	GroupCommander:new({name='Mineralnye-Attack-Maykop-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Maykop', Altitude = CapAltitude()}),
	GroupCommander:new({name='Mineralnye-Attack-Maykop-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Maykop', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Mineralnye-Attack-Maykop-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Maykop', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Mineralnye-supply-Nalchik', mission='supply', template='HeloSupplyTemplate', targetzone='Nalchik'}),
	GroupCommander:new({name='Mineralnye-supply-India', mission='supply', template='HeloSupplyTemplate', targetzone='India'}),
	GroupCommander:new({name='Mineralnye-supply-Mozdok', mission='supply', template='SupplyPlaneTemplate', targetzone='Mozdok'}),
	GroupCommander:new({name='Mineralnye-supply-Maykop', mission='supply', template='SupplyPlaneTemplate', targetzone='Maykop'}),
})
zones.tbilisi:addGroups({
	GroupCommander:new({name='tbilisi-supply-Soganlug', mission='supply', template='HeloSupplyTemplate', targetzone='Soganlug', Redcondition = function() return not CustomFlags["StrikeVaziani"] end}),
	GroupCommander:new({name='tbilisi-supply-Vaziani', mission='supply', template='HeloSupplyTemplate', targetzone='Vaziani', Redcondition = function() return not CustomFlags["StrikeVaziani"] end}),
	GroupCommander:new({name='Tbilisi-Patrol-Nalchik', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Nalchik', Altitude = CapAltitude()}),
})
zones.vaziani:addGroups({
	GroupCommander:new({name='vaziani-supply-Kilo', mission='supply',template='HeloSupplyTemplate', targetzone='Kilo', Redcondition = function() return not CustomFlags["StrikeVaziani"] end}),
	GroupCommander:new({name='vaziani-supply-Lima', mission='supply', template='HeloSupplyTemplate', targetzone='Lima', Redcondition = function() return not CustomFlags["StrikeVaziani"] end}),
	GroupCommander:new({name='vaziani-supply-Soganlug', mission='supply',template='HeloSupplyTemplate', targetzone='Soganlug', Redcondition = function() return not CustomFlags["StrikeVaziani"] end}),
	GroupCommander:new({name='vaziani-supply-Tbilisi', mission='supply',template='HeloSupplyTemplate', targetzone='Tbilisi', Redcondition = function() return not CustomFlags["StrikeVaziani"] end}),
	GroupCommander:new({name='vaziani-supply-SAM-Lima', mission='supply', template='HeloSupplyTemplate', targetzone='SAM-Lima', type='surface', Redcondition = function() return not CustomFlags["StrikeVaziani"] end}),
	GroupCommander:new({name='vaziani-supply-SAM-Mike', mission='supply', template='HeloSupplyTemplate', targetzone='SAM-Mike', type='surface', Redcondition = function() return not CustomFlags["StrikeVaziani"] end}),
	GroupCommander:new({name='vaziani-attack-Kilo', mission='attack', template='CasHeloTemplate', targetzone='Kilo'}),
	GroupCommander:new({name='vaziani-attack-Lima', mission='attack', template='CasHeloTemplate', targetzone='Lima'}),
	GroupCommander:new({name='vaziani-attack-Soganlug', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Soganlug'}),
	GroupCommander:new({name='vaziani-attack-Tbilisi', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Tbilisi'}),
	GroupCommander:new({name='vaziani-attack-Kilo', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Kilo', Altitude = CapAltitude()}),
	GroupCommander:new({name='vaziani-patrol-Beslan', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Beslan', Altitude = CapAltitude()}),
	GroupCommander:new({name='vaziani-patrol-Tbilisi', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tbilisi', Altitude = CapAltitude()}),
	GroupCommander:new({name='vaziani-attack-Beslan', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Beslan', Altitude = CasAltitude()}),
	GroupCommander:new({name='vaziani-attack-Juliett', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Juliett', Altitude = CasAltitude()}),
	GroupCommander:new({name='vaziani-attack-Tbilisi', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Tbilisi'}),


})
function SpawnFriendlyAssets()

	if zones.redcarrier.wasBlue then
		timer.scheduleFunction(function()
		activateGroupIfNotActive('CVN-73')
		activateGroupIfNotActive('CVN-59')
		end, {}, timer.getTime() + 5)
		timer.scheduleFunction(function()
		destroyGroupIfActive('CVN-72')
		destroyGroupIfActive('CVN-74')
		end, {}, timer.getTime() + 2)
		timer.scheduleFunction(function()
			checkWeaponsList('CVN-73')
			checkWeaponsList('CVN-59')
		end, {}, timer.getTime() + 7)
	end
--[[ 	

	if zones.beslan.wasBlue then
		destroyGroupIfActive('Red AWACS')
	end
--Destroy Awacs RED anapa
	if zones.tbilisi.wasBlue then
		destroyGroupIfActive('Red AWACS 3')
	end
--awacs anapa
	if zones.anapa.wasBlue and not zones.maykop.wasBlue and zones.samkilo.active and not zones.samgolf.active then
		activateGroupIfNotActive('Blue AWACS 1')

		destroyGroupIfActive('Blue AWACS 0')
		destroyGroupIfActive('Red AWACS')
	end
--tankers anapa	
	if zones.anapa.wasBlue and not zones.samgolf.active and zones.samkilo.active then
		-- activateGroupIfNotActive('Kutaisi-airforce-tanker-maykop')
		-- activateGroupIfNotActive('Kutaisi-navy-tanker-maykop')

		-- destroyGroupIfActive('Kutaisi-airforce-tanker')
		-- destroyGroupIfActive('Kutaisi-navy-tanker')
		destroyGroupIfActive('Blue AWACS 0')
		destroyGroupIfActive('Red AWACS')
	end
--maykop awacs	
	if zones.anapa.wasBlue and zones.maykop.wasBlue and zones.samkilo.active then
		SpawnGroupIfNotActive('Blue AWACS 3')
		destroyGroupIfActive('Blue AWACS 1')
		destroyGroupIfActive('Blue AWACS 0')
	end
	--kutaisi tankers
	if zones.kutaisi.wasBlue and zones.samgolf.active and not zones.samcharlie.active then
		-- SpawnGroupIfNotActive('Kutaisi-airforce-tanker')
		-- SpawnGroupIfNotActive('Kutaisi-navy-tanker')

	end
--mozdok tanker and awacs
	if zones.maykop.wasBlue and zones.mozdok.wasBlue and not zones.samkilo.active then
		SpawnGroupIfNotActive('Blue AWACS 2')
		-- SpawnGroupIfNotActive('Mozdok-navy-tanker')
		-- SpawnGroupIfNotActive('Mozdok-airforce-tanker')

		destroyGroupIfActive('Blue AWACS 3')
		-- destroyGroupIfActive('Kutaisi-airforce-tanker-maykop')
		-- destroyGroupIfActive('Kutaisi-navy-tanker-maykop')
		destroyGroupIfActive('Blue AWACS 0')
		destroyGroupIfActive('Red AWACS 2')
	end
	if zones.sochi.wasBlue and not zones.tankfactory.firstCaptureByRed then
	zones.tankfactory:MakeZoneRedAndUpgrade()
	zones.samsite:MakeZoneRedAndUpgrade()
	end
	if zones.sukhumi.wasBlue and not zones.ammonitiondepo.firstCaptureByRed then
	zones.ammonitiondepo:MakeZoneRedAndUpgrade()
	end
	 ]]
	if zones.redcarrier.wasBlue then
		trigger.action.setMarkupTypeLine(zones.bluecarrier.index, 0)
	end
	if not CustomFlags[1] then
		zones.hidden1:MakeRedZoneUpgraded()
		CustomFlags[1] = true
	end
end
timer.scheduleFunction(SpawnFriendlyAssets, {}, timer.getTime() + 8)

function checkAndDisableFriendlyZones()
end
timer.scheduleFunction(checkAndDisableFriendlyZones, {}, timer.getTime() + 5)

for i,v in pairs(zones) do
	bc:addZone(v)
end


missions = {
        ["Sochi"] = {	
        zone = "Sochi",
        missionGroup = "SochiEscortGroup",
        menuTitle = "Sochi: Ground Escort",
        missionTitle = "Sochi: Ground Escort",
        TargetZone = "Bravo",
        radius = 2500,
        MissionType = "Escort",
        flag = 001,
		ActivateZone = "hidden"
    },
        ["Bravo"] = {	
        zone = "Bravo",
        missionGroup = "BravoEscortGroup",
        menuTitle = "Bravo: Ground Escort",
        missionTitle = "Bravo: Ground Escort",
        TargetZone = "Charlie",
        radius = 2500,
        MissionType = "Escort",
        flag = 101,
		ActivateZone = "hidden2"
    },
        ["Charlie"] = {	
        zone = "Charlie",
        missionGroup = "CharlieEscortGroup",
        menuTitle = "Charlie: Ground Escort",
        missionTitle = "Charlie: Ground Escort",
        TargetZone = "Delta",
        radius = 2500,
        MissionType = "Escort",
        flag = 111,
		ActivateZone = "hidden3"
    },
}

bc:addConnection("Blue Carrier","Batumi")
bc:addConnection("Batumi","Kobuleti")
bc:addConnection("Kobuleti","SAM-Alpha")
bc:addConnection("Kobuleti","Senaki")

bc:addConnection("Senaki","Kutaisi")
bc:addConnection("Kutaisi","Alpha")
bc:addConnection("Kutaisi","FuelDepo")
bc:addConnection("Alpha","Sukhumi")
bc:addConnection("Alpha","InsurgentCamp")
bc:addConnection("Sukhumi","SAM-Delta")
bc:addConnection("Sukhumi","SecretTechFacility")
bc:addConnection("Sukhumi","Gudauta")
bc:addConnection("Sochi","Gudauta")
bc:addConnection("Sochi","Bravo")
bc:addConnection("Sochi","Red Carrier")
bc:addConnection("Sochi","AmmonitionDepo")
bc:addConnection("Bravo","Charlie")
bc:addConnection("Charlie","Delta")
bc:addConnection("Delta","Gelendzhik")
bc:addConnection("Gelendzhik","SAM-Foxtrot")
bc:addConnection("Gelendzhik","Novorossiysk")
bc:addConnection("Novorossiysk","Anapa")
bc:addConnection("Anapa","SAM-Golf")
bc:addConnection("Anapa","Krymsk")
bc:addConnection("Krymsk","Echo")
bc:addConnection("Echo","Krasnodar-Center")
bc:addConnection("Krasnodar-Center","SAM-Hotel")
bc:addConnection("Krasnodar-Center","Krasnodar-Pashkovsky")
bc:addConnection("Krasnodar-Pashkovsky","TankFactory")
bc:addConnection("Krasnodar-Pashkovsky","Foxtrot")
bc:addConnection("Krasnodar-Pashkovsky","Maykop")
bc:addConnection("Foxtrot","Maykop")
bc:addConnection("Maykop","Golf")
bc:addConnection("Maykop","SAMSite")
bc:addConnection("Maykop","SAM-India")
bc:addConnection("Golf","Hotel")
bc:addConnection("Hotel","India")
bc:addConnection("India","Mineralnye")
bc:addConnection("Mineralnye","Nalchik")
bc:addConnection("Mineralnye","Mozdok")
bc:addConnection("Mineralnye","SAM-Juliett")
bc:addConnection("Mozdok","Nalchik")
bc:addConnection("Mozdok","Beslan")
bc:addConnection("Nalchik","ChemSite")
bc:addConnection("Nalchik","ArtilleryFactory")
bc:addConnection("Beslan","ArtilleryFactory")

bc:addConnection("Beslan","Juliett")
bc:addConnection("Juliett","Kilo")
bc:addConnection("Kilo","Lima")
bc:addConnection("Lima","Tbilisi")
bc:addConnection("Tbilisi","Soganlug")
bc:addConnection("Tbilisi","Vaziani")
bc:addConnection("Vaziani","SAM-Lima")
bc:addConnection("Vaziani","SAM-Mike")


bc:addConnection("Batumi","MiningFacility")

bc:addConnection("SAMSite", "Mineralnye")

bc:addConnection("Senaki","SAM-Bravo")
bc:addConnection("Kutaisi","SAM-Charlie")

bc:addConnection("Sochi","SAM-Echo")
bc:addConnection("Novorossiysk","SAM-Foxtrot")

bc:addConnection("Mozdok","SAM-Kilo")


--zones.fueldepo:addCriticalObject('FuelDepo1')
--zones.fueldepo:addCriticalObject('FuelDepo2')
--zones.fueldepo:addCriticalObject('FuelDepo3')
--zones.fueldepo:addCriticalObject('FuelDepo4')
--zones.fueldepo:addCriticalObject('FuelDepo5')
--zones.fueldepo:addCriticalObject('FuelDepo6')

Group.getByName('Kutaisi-Sead-Attack'):destroy()
Group.getByName('Kutaisi-Sead-Attack-Coldwar'):destroy()
Group.getByName('Kutaisi-bomb-Attack'):destroy()
Group.getByName('Kutaisi-bomb-Attack 2'):destroy()
zones.kutaisi:registerTrigger('captured', function(_, zone)
    if zone ~= zones.kutaisi then return end
	local kr = bc:getZoneByName('Kutaisi')
	if kr.side == 2 and not CustomFlags['kutaisicaptured'] then
		if not IsGroupActive('Kutaisi-Sead-Attack') then
			Respawn.Group('Kutaisi-bomb-Attack')
			Respawn.Group('Kutaisi-bomb-Attack 2')
            local seadGrp = (Era=='Coldwar') and 'Kutaisi-Sead-Attack-Coldwar' or 'Kutaisi-Sead-Attack'
            Respawn.Group(seadGrp)
            CustomFlags['kutaisicaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, "The enemy have launched an assault on Kutaisi\n\n2 bombers escorted by 2 unknown jets!", 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 10)
		end
	end
end, 'kutaisicaptured')

Group.getByName('Sochi-arty-Attack-Group'):destroy()
zones.sochi:registerTrigger('captured', function(_, zone)
    if zone ~= zones.sochi then return end
	local kr = bc:getZoneByName('Sochi')
	if kr.side == 2 and not CustomFlags['sochicaptured'] then
		if not IsGroupActive('Sochi-arty-Attack-Group') then
			Respawn.Group('Sochi-arty-Attack-Group')
            CustomFlags['sochicaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, "Sochi is under attack by enemy Artillery!\n\nBrace!", 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 180)
		end
	
    timer.scheduleFunction(function()
    trigger.action.outTextForCoalition(2, [[We found the enemy Artillery!

Take them out before they fire again!   

They have fired from Bravo!!]], 30)
    end, {}, timer.getTime() + math.random(360, 480))
end
end, 'sochicaptured')

Group.getByName('Anapa-Attack-Group'):destroy()
zones.anapa:registerTrigger('captured', function(_, zone)
    if zone ~= zones.anapa then return end
	local kr = bc:getZoneByName('Anapa')
	if kr.side == 2 and not CustomFlags['anapacaptured'] then
		if not IsGroupActive('Anapa-Attack-Group') then
			Respawn.Group('Anapa-Attack-Group')
            CustomFlags['anapacaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, "Brace!!\n\nEnemy have fired scuds toward Anapa!!", 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 60)
		end
	end
end, 'anapacaptured')

zones.samalpha:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesamalpha')


zones.sambravo:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesambravo')

zones.samcharlie:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesamcharlie')

zones.samdelta:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesamdelta')

zones.samecho:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesamecho')

zones.samfoxtrot:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesamfoxtrot')

zones.samgolf:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesamgolf')

zones.samhotel:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesamhotel')

zones.samindia:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesamindia')

zones.samjuliett:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesamjuliett')

zones.samkilo:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesamkilo')

zones.samlima:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesamlima')

zones.sammike:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+200 credits',20)
end, 'disablesammike')

zones.samsite:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemy SAM destroyed\n+500 credits',20)
end, 'disablesamsite')

zones.miningfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Mining facility is no more\n+500 credits',20)
end, 'disableminingfacility')

zones.insurgentcamp:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Insurgent camp is no more\n+500 credits',20)
end, 'disableinsurgentcamp')

zones.ammonitiondepo:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Ammunition depo is no more\n+500 credits',20)
end, 'disableammonitiondepo')

zones.artilleryfactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Artillery factory is no more\n+500 credits',20)
end, 'disableartilleryfactory')


zones.chemsite:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'chemsite is no more\n+500 credits',20)
end, 'disablechemsite')

zones.fueldepo:registerTrigger('lost', function(event, sender) 
	bc:addFunds(2,500)
	sender:disableZone()
	trigger.action.outTextForCoalition(2,'fueldepo disabled\n+500 credits',20)
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
					if WarehouseLogistics == true and WarehousePersistence.ClearFile then
						local opts = {}
						if FootholdSavePath then opts.path = FootholdSavePath end
						if FootholdSaveBaseName and tostring(FootholdSaveBaseName) ~= "" then
						opts.filename = tostring(FootholdSaveBaseName) .. "_storage.csv"
						end
						WarehousePersistence.ClearFile(opts)
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

if Era == 'Coldwar' then
    bc:roamGroupsToLocalSubZone({
		"Red SAM AAA group 2 #",
		"Red Armour Group #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-15 2 #",
		"Red SAM SHORAD SA-19 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-8 2 #",
		'Red Armor Group8 #',
		'Red Armor Group9 #',
		'Red Armor Group6 #',
		'Red Armor Group7 #',
	}, 50)
else
	bc:roamGroupsToLocalSubZone({
		"Red armoured group 1 #",
		"Red Armour Group 2 #",
		"Red SAM AAA group 2 #",
		"Red Armour Group 3 #",
		"Red Armour Group #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-15 2 #",
		"Red SAM SHORAD SA-19 #",
		"Red SAM SHORAD SA-19 2 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-8 2 #",
	}, 50)
end
end, {}, timer.getTime() + 30)


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


if UseStatics == true then
bc:registerShopItem('dynamicstatic', 'Dynamic building Strike', 500,
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
        trigger.action.outTextForCoalition(2, 'No enemy zone with building targets far enough (>'..minNM..' NM) from the front line.', 10)
        return
    end

    StructureTargetMenu = bc:showTargetZoneMenu(2, 'Select building strike target zone', function(targetZoneName, menu)
        if bomberActive then return end
        local spawnZone, dist = findClosestBlueZoneOutside(targetZoneName, minNM)
        if not spawnZone then
            trigger.action.outTextForCoalition(2, 'No friendly zone available for strike spawn '..minNM..'+ NM away.', 15)
            return
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnStructureAt(spawnZone, targetZoneName, offset)
        StructureTargetMenu = nil
    end, 1, nil, allow)

    trigger.action.outTextForCoalition(2, 'Select building strike target zone from F10', 10)
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

local upgradeMenu = nil
bc:registerShopItem('supplies2', 'Resupply friendly Zone', 200, function(sender)
    if upgradeMenu then
        return 'Choose zone from F10 menu'
    end

    local upgradeZone = function(target)
        if upgradeMenu then
            local zn = bc:getZoneByName(target)
            if zn and zn.side == 2 and not zn.suspended then
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
if params.zone and params.zone.side == 2 and not params.zone.suspended then
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
			trigger.action.outTextForCoalition(2, 'Friendly armor deployed at '..target, 15)
		end
	end
	
	tanksMenu = bc:showTargetZoneMenu(2, 'Deploy armor (Choose friendly zone)', deployTanks, 2)
	trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		
		local zn = CustomZone:getByName(params.zone.zone)
		zn:spawnGroup((Era == 'Coldwar') and 'ca-tanks-Coldwar' or 'ca-tanks')
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
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		
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
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		
		local zn = CustomZone:getByName(params.zone.zone)
		zn:spawnGroup('ca-airdef')
		trigger.action.outTextForCoalition(2, 'Friendly air defence deployed at '..params.zone.zone, 15)
	else
		return 'Can only deploy at friendly zone'
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
bc:registerShopItem('jtac','MQ-9 Reaper JTAC mission',150,function(sender)
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

  ------------------------------ END 9 line jtac AM END ----------------------------------
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




-- new menu
local supplyMenu=nil
bc:registerShopItem('capture','Emergency capture neutral',500,
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

------------------------------------------- End of Zone upgrades ----------------------------------------
bc:addShopItem(2, 'jtac', -1,1)
bc:addShopItem(2, 'dynamiccap', -1,2)
bc:addShopItem(2, 'dynamiccas', -1,3)
bc:addShopItem(2, 'dynamicbomb', -1,4)
bc:addShopItem(2, 'dynamicsead', -1,5)
bc:addShopItem(2, 'dynamicdecoy', -1,6)
bc:addShopItem(2, 'dynamicarco', -1,7)
bc:addShopItem(2, 'dynamictexaco', -1,8)
bc:addShopItem(2, 'capture', -1,9)

if UseStatics == true then
    bc:addShopItem(2, 'dynamicstatic', -1,10)
end
bc:addShopItem(2, 'smoke', -1,11)
bc:addShopItem(2, 'intel', -1,12)
bc:addShopItem(2, 'supplies2', -1,13)
bc:addShopItem(2, 'supplies', -1,14)
bc:addShopItem(2,'zinf',-1,15)
bc:addShopItem(2,'zarm',-1,16)
bc:addShopItem(2,'zsam',-1,17)
bc:addShopItem(2,'zlogc',-1,18)
bc:addShopItem(2,'zwh50',-1,19)
bc:addShopItem(2,'zpat',-1,20)
bc:addShopItem(2,'gslot',1,21)
bc:addShopItem(2, 'armor', -1,22)
bc:addShopItem(2, 'artillery', -1,23)
bc:addShopItem(2, 'recon', -1,24)
bc:addShopItem(2, 'airdef', -1,25)
bc:addShopItem(2, '9lineam', -1,26)
bc:addShopItem(2, '9linefm', -1,27)

supplyZones = {
	'Blue Carrier',
	'Red Carrier',
	'Batumi',	
	'Kobuleti', 
	'Senaki', 
	'Kutaisi', 
	'Alpha', 
	'Sukhumi', 
	'Gudauta', 
	'Sochi',
	'Bravo',
	'Charlie',
	'Delta',
	'Gelendzhik',
	'Novorossiysk',
	'Anapa',
	'Krymsk',
	'Echo',
	'Krasnodar-Center',
	'Krasnodar-Pashkovsky',
	'Foxtrot',
	'Maykop',
	'Golf',
	'Hotel',
	'India',
	'Mineralnye',
	'Nalchik',
	'Mozdok',
	'Beslan',
	'Juliett',
	'Kilo',
	'Lima',
	'Soganlug',
	'Tbilisi',
	'Vaziani'
}

lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

bc:loadFromDisk() --will load and overwrite default zone levels, sides, funds and available shop items
bc:init()
bc:startRewardPlayerContribution(15,{infantry = 10, ground = 10, sam = 30, airplane = 30, ship = 200, helicopter=30, crate=100, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, ['CAP mission'] = true, ['CAS mission'] = true})
HercCargoDropSupply.init(bc)

bc:buildZoneDistanceCache()
buildSubZoneRoadCache()
bc:buildConnectionMap()
DynamicConvoy.InitTargetTails(5)
DynamicConvoy.InitRoadPathCacheFromCommanders(GroupCommanders)
PrecomputeLandingSpots()
Frontline.ReindexZoneCalcs()
local HuntNumber = SplashDamage and math.random(8,15) or math.random(6,15)
bc:initHunter(HuntNumber)
SCHEDULER:New(nil, function() bc:_buildHunterBaseList() end, {}, 1)

SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 3)
SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 4)

AWACS_CFG = {
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=150 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=70 }   -- blue
}


GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 95   		-- suspend red zones deeper than this nm


evc = EventCommander:new({ decissionFrequency=30*60, decissionVariance=30*60, skipChance = 10})
evc:init()

mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})

----------------------------------------- Destroy SCUDS ---------------------------------------
local Scuds_COOLDOWN = 2700
local lastScuds_COOLDOWN  = -Scuds_COOLDOWN
Group.getByName('Maykop-Scuds'):destroy()
evc:addEvent({
	id='scuds',
	action = function()
	RespawnGroup('Maykop-Scuds')
		RegisterGroupTarget('Maykop-Scuds',100,'Destroy Scuds')
		timer.scheduleFunction(function(param, time)
			if IsGroupActive('Maykop-Scuds') then
				local scudGrp = GROUP:FindByName('Maykop-Scuds')
				local _,_,_,_,missilesLeft = scudGrp:GetAmmunition()
				if missilesLeft == 0 then return time + (45*60) end
				local tgts = {'Gudauta','Sochi','Sukhumi'}
				local validtgts = {}
				for _,v in ipairs(tgts) do
					if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
						table.insert(validtgts, v)
					end
				end
				if #validtgts == 0 then return time+(10*60) end
				
				local die = math.random(1,#validtgts)
				local choice = validtgts[die]
				bc:fireAtZone(choice, 'Maykop-Scuds', false, 8)
				trigger.action.outTextForCoalition(2, 'SCUDS at Maykop are launching at '..choice, 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
		if timer.getTime()-lastScuds_COOLDOWN<Scuds_COOLDOWN then return false end
		if math.random(1,100) < 50 then return false end
		local gr = Group.getByName('Maykop-Scuds')
		if gr then return false end

		if bc:getZoneByName('Maykop').side ~= 1 or bc:getZoneByName('Maykop').suspended then return false end

		local triggers = {'Sukhumi', 'Sochi'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		
		return false
	end
})
mc:trackMission({
	title = "Destroy SCUDS (21)",
	description = "SCUDS have been spotted at Maykop.\nDestroy them before they can launch their missiles",
	messageStart = "New mission: Destroy SCUDS at Maykop",
	messageEnd=function() lastScuds_COOLDOWN=timer.getTime() return "Mission ended: Destroy SCUDS" end,
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
		local gr = Group.getByName('Maykop-Scuds')
		if gr then return true else return false end
	end
})
------------------------------------- End of Destroy SCUDS ----------------------------------------
---------------------------------------- Intercept Cargo Plane ---------------------------------------
local Cargo_COOLDOWN = 2700
local lastCargo_COOLDOWN   = -Cargo_COOLDOWN
Group.getByName('evt-cargointercept1'):destroy()
Group.getByName('evt-cargointercept2'):destroy()
Group.getByName('evt-cargointercept3'):destroy()
Group.getByName('evt-cargointercept4'):destroy()
local cargoDieEvent=nil
evc:addEvent({
	id='cargointercept',
	action=function()
		local planes
		if bc:getZoneByName('Maykop').side==1 and not bc:getZoneByName('Maykop').suspended then
			planes={'evt-cargointercept1'}
		elseif bc:getZoneByName('Sochi').side==1 and not bc:getZoneByName('Sochi').suspended then
			planes={'evt-cargointercept2'}
		elseif bc:getZoneByName('Anapa').side==1 and not bc:getZoneByName('Anapa').suspended then
			planes={'evt-cargointercept3'}
		elseif bc:getZoneByName('Mineralnye').side==1 and not bc:getZoneByName('Mineralnye').suspended then
			planes={'evt-cargointercept4'}
		else
			return
		end
		RespawnGroup(planes[1])
		local u = Group.getByName(planes[1]):getUnit(1)
		if u then RegisterUnitTarget(u:getName(),500,'Intercept cargo plane') end
	end,
	canExecute=function()
		if timer.getTime() - lastCargo_COOLDOWN < Cargo_COOLDOWN then return false end
		if math.random(1,100)<70 then return false end
		if bc:getZoneByName('Maykop').wasBlue and bc:getZoneByName('Sochi').wasBlue and bc:getZoneByName('Anapa').wasBlue then return false end
		if Group.getByName('evt-cargointercept1') then return false end
		if Group.getByName('evt-cargointercept2') then return false end
		if Group.getByName('evt-cargointercept3') then return false end
		if Group.getByName('evt-cargointercept4') then return false end
		return true
	end
})
mc:trackMission({
    title = "Intercept cargo plane",
    description = "Find and destroy the enemy cargo plane taking off from Vaziani heading for Anapa or Kutaisi or Mineralnye.",
    messageStart = "New mission: Intercept cargo plane",
    messageEnd =function() lastCargo_COOLDOWN=timer.getTime() return "Mission ended: Intercept cargo plane" end,
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
        if Group.getByName('evt-cargointercept1') then return true end
        if Group.getByName('evt-cargointercept2') then return true end
        if Group.getByName('evt-cargointercept3') then return true end
        
        return false
    end
})
------------------------------------ End of Intercept Cargo Plane ------------------------------------
---------------------------------------- Intercept Enemy Ships ---------------------------------------
local Ship_COOLDOWN = 2700
local lastShip_COOLDOWN   = -Ship_COOLDOWN
Group.getByName('evt-shiptercept1'):destroy()
Group.getByName('evt-shiptercept2'):destroy()
Group.getByName('evt-shiptercept3'):destroy()
local shipDieEvent = nil
evc:addEvent({
	id='shiptercept',
	action=function()
		local ships={'evt-shiptercept1','evt-shiptercept2','evt-shiptercept3'}
		local choice=math.random(1,#ships)
		RespawnGroup(ships[choice])
		RegisterGroupTarget(ships[choice],500,'cargo ship')
	end,
	canExecute=function()
		if timer.getTime() - lastShip_COOLDOWN < Ship_COOLDOWN then return false end
		if math.random(1,100)<70 then return false end
		if bc:getZoneByName('Red Carrier').side~=2 or bc:getZoneByName('Red Carrier').suspended then return false end
		if bc:getZoneByName('Novorossiysk').side~=1 or bc:getZoneByName('Novorossiysk').suspended then return false end
		if bc:getZoneByName('Sochi').side~=2 or bc:getZoneByName('Sochi').suspended then return false end
		if Group.getByName('evt-shiptercept1') then return false end
		if Group.getByName('evt-shiptercept2') then return false end
		if Group.getByName('evt-shiptercept3') then return false end
		return true
	end
})
mc:trackMission({
    title = "Destroy cargo & battle ships",
    description = "Find and destroy the enemy battle ships sailing off from Novorossiysk, heading towards Sochi or Gudauta or Sukhumi!",
    messageStart = "New mission: Destroy battle ships",
	messageEnd =function() lastShip_COOLDOWN=timer.getTime() return "Mission ended: Destroy battle ships" end,
    startAction = function()
        if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
    isActive = function()
        if Group.getByName('evt-shiptercept1') then return true end
        if Group.getByName('evt-shiptercept2') then return true end
        if Group.getByName('evt-shiptercept3') then return true end

        return false
    end
})
----------------------------------- End of Intercept Enemy Ships ---------------------------------
---------------------------------------- Intercept Bombers ---------------------------------------
local bomb_COOLDOWN = 2700
local lastbomb_COOLDOWN  = -bomb_COOLDOWN
local escGrp = Era=='Coldwar' and 'EscortBomberCW' or 'EscortBomber'
Group.getByName('evt-bomb'):destroy()
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
		local triggers = {'Kutaisi','Sochi','Sukhumi','Maykop','Mineralnye'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		return false
	end
})
function startBomberAttack()
	local tgts = {'Kutaisi','Sochi','Senaki','Batumi','Kobuleti',
		'Sukhumi','Gudauta','Gelendzhik','Novorossiysk','Krymsk',
		'Krasnodar-Center','Krasnodar-Pashkovsky','Maykop','Mineralnye',
		'Mozdok'}
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
	description = "Enemy bombers spotted north of Mineralnye\nDestroy them before they get in range.",
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
------------------------------------ End of Intercept Bombers --------------------------------------
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
		RegisterGroupTarget(attackGrp,250,'Intercept enemy airstrike')
		timer.scheduleFunction(function(param, time)
			local tgts = {'Kutaisi','Sochi','Senaki','Batumi','Kobuleti','Sukhumi','Gudauta',
			'Gelendzhik','Novorossiysk','Krymsk','Krasnodar-Center','Krasnodar-Pashkovsky',
			'Maykop','Mineralnye','Mozdok'}		
			local validtgts = {}
			for _,v in ipairs(tgts) do
				local zn = bc:getZoneByName(v)
				if zn and zn.side == 2 and not zn.suspended then
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
		local triggers = {'Kutaisi', 'Sochi', 'Sukhumi', 'Maykop', 'Mineralnye'}
		for _,v in ipairs(triggers) do
			local zn = bc:getZoneByName(v)
			if zn and zn.side == 2 and not zn.suspended then
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
---------------------------------------- End of airstrike --------------------------------------
----------------------------------------- Escort mission ---------------------------------------
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
			local g = GROUP:FindByName(groupname)
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
		
		local timers = {math.random(10*60,20*60), math.random(15*60,25*60)}
		local timers = {math.random(10*60,20*60), math.random(15*60,25*60)}
		timer.scheduleFunction(spawnIntercept, {'interceptor-1'}, timer.getTime() + timers[1])
		timer.scheduleFunction(spawnIntercept, {'interceptor-2'}, timer.getTime() + timers[2])
	end,
	canExecute = function()
		if timer.getTime() - lastEscortCooldown < EscortCooldown then return false end
		local gr = Group.getByName('escort-me')
		if gr then return false end
		local zn = bc:getZoneByName('Kutaisi')
		if zn.side ~= 2 or zn.suspended then return false end
		local triggers = {'Kutaisi', 'Sochi', 'Sukhumi', 'Maykop', 'Mineralnye'}
		for _,v in ipairs(triggers) do
			local tg = bc:getZoneByName(v)
			if tg and tg.side == 2 and not tg.suspended then
				return true
			end
		end
		
		return false
	end
})
mc:trackMission({
    title = "Escort cargo plane",
    description = "Friendly cargo plane is taking off from Kutaisi. Protect it until it leaves the airspace.",
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

---------------------------------------- End of Escort mission --------------------------------------
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
		ActiveCurrentMission = ActiveCurrentMission or {}
		ActiveCurrentMission.Attack = ActiveCurrentMission.Attack or {}
		ActiveCurrentMission.Attack[attackTarget] = true

		local z = bc:getZoneByName(attackTarget) if z then z:updateLabel() end
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cas.ogg")
		end
	end,
	endAction = function()
		if ActiveCurrentMission and ActiveCurrentMission.Attack then
			ActiveCurrentMission.Attack[attackTarget] = nil
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


function generateSEADMission()
    if seadTarget then return end
    if not attackTarget then return end

    local function isSEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and (not zone.suspended)
           and (lname:find('sam') or lname:find('defence'))
           and (not isZoneUnderSEADMission or not isZoneUnderSEADMission(zone.zone))
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

    if #validSEADZones == 0 then return end
    local pick = validSEADZones[math.random(#validSEADZones)]
    if pick then
        seadTarget = pick
        return true
    end
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
        return zone.side == 1 and zone.active and (lname:find('sam') or lname:find('defence'))
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
            return zone.side == 1 and zone.active and (not zone.suspended) and not isZoneUnderSEADMission(zone.zone)
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

local sceneryList = {
  ["StrikeTarget"] = {SCENERY:FindByZoneName("StrikeTarget")},
  ["StrikeTarget1"] = {SCENERY:FindByZoneName("StrikeTarget1")},
  ["StrikeTarget2"] = {SCENERY:FindByZoneName("StrikeTarget2")},
  ["RightHandMan"] = {SCENERY:FindByZoneName("RightHandMan")},
  ["LefttHandMan"] = {SCENERY:FindByZoneName("LefttHandMan")},
  ["StrikeVaziani"] = {SCENERY:FindByZoneName("StrikeVaziani")},
  
}
--------------------------- Strike High value target ---------------------------
evc:addEvent({
	id = 'StrikeTarget',
	action = function()
		ActiveMission['StrikeTarget'] = true
		local tgt = sceneryList['StrikeTarget'][1] or SCENERY:FindByZoneName('StrikeTarget')
		if not tgt then
			trigger.action.outText('StrikeTarget is missing',30)
			return
		end
		RegisterScoreTarget('StrikeTarget',tgt,1000,'High value target')
	end,
	canExecute = function()
	if ActiveMission['StrikeTarget'] then return false end
	if CustomFlags["StrikeTarget"] then return false end
	if bc:getZoneByName('Sochi').side ~= 2 or bc:getZoneByName('Sochi').suspended then return false end
	return true
	end,
})
mc:trackMission({
	title = "Strike High value target",
	description = 
[[Strike a high-value building at these coordinates:

MGRS: 37 T EK 58654 22580
Lat long: N 44°27'14" E 39°44'14"
Lat long Decimal Minutes: N 44°27.248' E 39°44.234'

Elevation: 677 feet

reward = 500]],
	messageStart = "New strike mission: Strike High value target building",
	messageEnd = "Strike mission ended: Strike High value target building",
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
	if CustomFlags["StrikeTarget"] then return false end
	if ActiveMission["StrikeTarget"] then return true end
	  return false
	end,
})
--------------------------end of strike high value target -----------------------------
--------------------------- Strike High value target 1 ---------------------------

evc:addEvent({
	id = 'StrikeTarget1',
	action = function()
		ActiveMission['StrikeTarget1'] = true
		local tgt = sceneryList['StrikeTarget1'][1] or SCENERY:FindByZoneName('StrikeTarget1')
		if not tgt then
			trigger.action.outText('StrikeTarget1 is missing',30)
			return
		end
		RegisterScoreTarget('StrikeTarget1',tgt,1000,'High value target')
	end,
	canExecute = function()
	if ActiveMission['StrikeTarget1'] then return false end
	if CustomFlags["StrikeTarget1"] then return false end
	local zn = bc:getZoneByName('Kutaisi')
	if not zn or zn.side ~= 2 or zn.suspended then return false end
	return true
	end,
})
mc:trackMission({
	title = "Strike High value target",
	description = 
[[Strike a high-value building at these coordinates:

MGRS: 37 T FH 84000 46225
Lat long: N 42°50'47" E 41°15'06"
Lat long Decimal Minutes: N 42°50.788' E 41°15.108'

Elevation: 193 feet

reward = 500]],
	messageStart = "New strike mission: Strike High value target building",
	messageEnd = "Strike mission ended: Strike High value target building",
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
	if CustomFlags["StrikeTarget1"] then return false end
	if ActiveMission['StrikeTarget1'] then return true end
	  return false
	end,
})
--------------------------end of strike high value target 1 -----------------------------
--------------------------- Strike High value target 2 ---------------------------
Group.getByName('Red SAM SHORAD SA-15 StrikeTarget2 Fixed'):destroy()
Group.getByName('Red SAM SHORAD SA-8 StrikeTarget2 Fixed'):destroy()
evc:addEvent({
	id='StrikeTarget2',
	action = function()
		ActiveMission['StrikeTarget2'] = true
		local groupname = (Era == 'Coldwar') and 'Red SAM SHORAD SA-8 StrikeTarget2 Fixed' or 'Red SAM SHORAD SA-15 StrikeTarget2 Fixed'

		RespawnGroup(groupname)
		RegisterGroupTarget(groupname,500,'High value target','StrikeTarget2')
	end,
	canExecute = function()
		if math.random(1,100) < 50 then return false end
		if ActiveMission['StrikeTarget2'] then return false end
		local zn = bc:getZoneByName('Senaki')
		if zn.side ~= 2 or zn.suspended then return false end
		if CustomFlags["StrikeTarget2"] == true then return false end
		return true
end
})
mc:trackMission({
	title = "Strike High value target",
description = 
[[Strike a high value building at these coordinates:

MGRS: 38 T LM 09247 78805
Lat long: N 42°14'17" E 42°41'17"
Lat long Decimal Minutes: N 42°14.288' E 42°41.287'

Elevation: 435 feet

reward = 500]],
	messageStart = "New strike mission: Strike High value target",
	messageEnd = "Strike mission ended: Strike High value target",
    startAction = function()
    end,
    endAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
	end,
	isActive = function()
		if CustomFlags["StrikeTarget2"] then return false end
		if ActiveMission['StrikeTarget2'] then return true end
		if Era == 'Coldwar' then
			if Group.getByName('Red SAM SHORAD SA-8 StrikeTarget2 Fixed') then return true end
		else
			if Group.getByName('Red SAM SHORAD SA-15 StrikeTarget2 Fixed') then return true end
		end
		return false
	end,
})

-----------------------------end of strike high value target 2 -----------------------------
--------------------------- Strike Right Hand Man ---------------------------
Group.getByName('RightHandMan'):destroy()

local SecondManEvent = nil
evc:addEvent({
    id = 'RightHandMan',
    action = function()
        RespawnGroup('RightHandMan')
		RegisterGroupTarget('RightHandMan',500,'High value general','RightHandMan')
    end,
    canExecute = function()
		local zn = bc:getZoneByName('Krymsk')
		if zn.side ~= 2 or zn.suspended then return false end
		if Group.getByName('RightHandMan') then return false end
        if CustomFlags["RightHandMan"] == true then return false end
        return true
    end
})

mc:trackMission({
	title = "Kill a high value general",
description = 
[[We have the located a high value target
in the city of Belorechensk, Take him out!.

Coordinates:
MGRS: 37 T EK 68850 58279
Lat Long: N 44°46'28" E 39°52'12"
Lat long Decimal Minutes: N 44°46.475' E 39°52.210'

Elevation: 381 feet

Reward: 500

Destroy the house and whoever is nearby.]],

	messageStart = "New strike mission: Kill a high value general",
	messageEnd = "Strike mission ended: Kill a high value general",
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
		if CustomFlags["RightHandMan"] then return false end
		if Group.getByName('RightHandMan') then return true end
		return false
	end
})
----------------------------end of strike right hand man ---------------------------
--------------------------- Strike Left Hand Man ---------------------------
Group.getByName('LefttHandMan'):destroy()
evc:addEvent({
	id = 'LefttHandMan',
	action = function()
		RespawnGroup('LefttHandMan')
		RegisterGroupTarget('LefttHandMan',500,'High value general','LefttHandMan')
	end,
	canExecute = function()
		if bc:getZoneByName('Maykop').side ~= 2 or bc:getZoneByName('Maykop').suspended then return false end
		if CustomFlags["LefttHandMan"] == true then return false end
		return true
	end
})

mc:trackMission({
	title = "Kill a high value general",
description = 
[[We have the located another high value target
in the city of cherkessk, hes probably inside
the building. Take him out!.

Coordinates:
MGRS: 38 T KQ 64147 02594
Lat Long: N 44°14'18" E 42°02'47"
Lat long Decimal Minutes: N 44°14.303' E 42°02.786'

Elevation: 1705 feet

Reward: 500

Destroy the house and whoever is nearby.]],

	messageStart = "New strike mission: Kill a high value general",
	messageEnd = "Strike mission ended: Kill a high value general",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
		if CustomFlags["LefttHandMan"] then return false end
		if Group.getByName('LefttHandMan') then return true end
		return false
	end
})
------------------------------end of strike left hand man ---------------------------
--------------------------- Strike Vaziani ---------------------------
Group.getByName('StrikeVaziani'):destroy()
evc:addEvent({
	id = 'StrikeVaziani',
	action = function()
	RespawnGroup('StrikeVaziani')
	RegisterGroupTarget('StrikeVaziani',1000,'Vaziani supply warehouse','StrikeVaziani')
	end,
	canExecute = function()
		if bc:getZoneByName('Lima').side ~= 2 then return false end
		if CustomFlags["StrikeVaziani"] then return false end
		return true
	end})

mc:trackMission({
	title = "Strike Vaziani's supply warehouse",
	description = 

[[Strike Vaziani's supply warehouse to cripple the supplies
to their surrounding.

Coordinates:
MGRS: 38 T NM 04080 09769
Lat long: N 41°38'22" E 45°02'56"
Lat long Decimal Minutes: N 41°38.378' E 45°02.939'

Elevation 1465 feet

Reward 1000

2000 Pounds required]],
	messageStart = "New strike mission: Strike Vaziani's supply warehouse\n\nStrike this building to cripple the supplis to the surrounding enemy zones",
	messageEnd = "Strike mission ended: Strike Vaziani's supply warehouse\n\nsupply warehouse is now out of order",
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
	if CustomFlags["StrikeVaziani"] then return false end
	if Group.getByName('StrikeVaziani') then return true end
	  return false
	end,
})
--------------------------- end of Strike Vaziani ---------------------------
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
--[[ 
local function checkZoneFlags()

	if zones.kutaisi.side == 1 and not zones.samalpha.active then
        trigger.action.setUserFlag(21, true)	
    end

	if zones.kutaisi.wasBlue then
        trigger.action.setUserFlag(20, true)	
		trigger.action.setUserFlag(21, false)
    end
    if zones.sukhumi.wasBlue and not zones.sochi.wasBlue and not zones.redcarrier.wasBlue and
	not zones.samdelta.active then
        trigger.action.setUserFlag(91, true)
		trigger.action.setUserFlag(21, false)
    end
	if zones.sukhumi.wasBlue and zones.sochi.wasBlue and not zones.redcarrier.wasBlue and 
	not zones.samecho.active then
        trigger.action.setUserFlag(93, true)
		trigger.action.setUserFlag(91, false)
    end
	if zones.sukhumi.wasBlue and zones.redcarrier.wasBlue and not zones.charlie.wasBlue then
		trigger.action.setUserFlag(20, false)
		trigger.action.setUserFlag(91, false)
		trigger.action.setUserFlag(93, false)
        trigger.action.setUserFlag(92, true)
    end
	if zones.sochi.wasBlue and zones.redcarrier.wasBlue and zones.charlie.wasBlue then
		trigger.action.setUserFlag(20, false)
		trigger.action.setUserFlag(91, false)
		trigger.action.setUserFlag(93, false)
        trigger.action.setUserFlag(92, false)
		trigger.action.setUserFlag(94, true)
    end
	if zones.mozdok.wasBlue and zones.beslan.wasBlue and not zones.samkilo.active then
		trigger.action.setUserFlag(94, false)
		trigger.action.setUserFlag(219, true)
    end
	if zones.anapa.wasBlue and zones.krasnodarp.wasBlue and not zones.maykop.wasBlue then
		trigger.action.setUserFlag(3, true)
	end
	if zones.anapa.wasBlue and zones.maykop.wasBlue and not zones.mineralnye.wasBlue then
		trigger.action.setUserFlag(4, true)
		trigger.action.setUserFlag(3, false)
	end
	if zones.mineralnye.wasBlue and not zones.mozdok.wasBlue then
		trigger.action.setUserFlag(7, true)
		trigger.action.setUserFlag(4, false)
	end
	if zones.mineralnye.wasBlue and zones.mozdok.wasBlue then
		trigger.action.setUserFlag(465, true)
	end
end
timer.scheduleFunction(function()
    checkZoneFlags()
    return timer.getTime() + 30
end, {}, timer.getTime() + 2)
 ]]

buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end
----------------------- END OF FLAGS --------------------------

env.info("Mission Setup : is completed!")