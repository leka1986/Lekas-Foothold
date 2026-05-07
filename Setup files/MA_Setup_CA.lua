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
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8', 'Red SAM AAA 3', 'Red SAM AAA 4'}
	},
	Soganlug = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Red SAM AAA', 'Red SAM SHORAD SA-15'}
	},
	Mineralnye = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM AAA 2', 'Mineralnye HQ', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Pantsir S1'}
	},
	Novorossiysk = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-19','Communication Tower', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-15'}
	},
	airfield2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD Pantsir S1', 'Red SAM SHORAD SA-8'}
	},
	Kobuleti = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red Armour Group 3','Kobuleti Fuel Tank 2', 'Red SAM SHORAD SA-15','Kobuleti Fuel Tank', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15'}
	},
	airfield3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red Armour Group', 'Red Armour Group 4', 'Red SAM AAA', 'Red SAM SHORAD Tor M2', 'Red SAM AAA 3','Red SAM AAA 4'}
	},
	Pashkovsky = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red Armour Group', 'Red Armour Group 4','Pashkovsky HQ', 'Red SAM AAA','Pashkovsky HQ 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15'}
	},
	Sochi = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Red Armour Group', 'Red Armour Group 4','Sochi Communication Tower','Sochi Fuel Tank 3','Red SAM AAA','Red SAM SHORAD SA-19', 'Sochi Fuel Tank 2', 'Red SAM SHORAD SA-19','Sochi Fuel Tank', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD Pantsir S1'}
	},
	airfield3Maykop = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red Armour Group', 'Red Armour Group 4','Maykop fuel storage', 'Red SAM SHORAD SA-19','Maykop HQ bulding','Red SAM AAA 4', 'Red SAM AAA 3'}
	},
	
	airfield4 = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red SAM AAA', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Pantsir S1'}
	},
	Anapa = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Red SAM AAA 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Anapa Command Center','Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Pantsir S1'}
	},
	airfield4Kutaisi = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Red SAM AAA', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Kutaisi Fuel tank', 'Red SAM SHORAD SA-8', 'Kutaisi Fuel tank 2', 'Red SAM SA-6', 'Kutaisi Fuel tank 3', 'Kutaisi Fuel tank 4','Red SAM SHORAD Pantsir S1'}
	},
	
	samalphaFixed = {
		blue = {'blueArmor', 'bluePD1'},
		red = {'Red SAM SHORAD SA-15', 'Red SAM SA-2', 'Red SAM SA-3'}
	},
	samFoxtrotFixed = {
		blue = {},
		red = {'Red SAM SHORAD SA-19', 'Red SAM AAA', 'Red SAM SA-2'}
	},
	sambravoFixed = {
		blue = {'blueHAWK'},
		red = {'Red SAM AAA','Red SAM SHORAD SA-15','Red SAM SA-2'}
	},
	
	samgolf = {
		blue = {'blueArmor', 'bluePD1'},
		red = {'Red SAM SA-6', 'Red SAM SHORAD SA-19','Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15'}
	},
	
	sam3 = {
		blue = {'blueArmor', 'bluePD2'},
		red = {'Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15', 'Red SAM SA-6', 'Red SAM SHORAD SA-8'}
	},
	samcharliefixed = {
		blue = {'blueHAWK'},
		red = {'Red SAM AAA', 'Red SAM AAA 2', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-19', 'Red SAM SA-6'}
	},
	sam4indiafixed = {
		blue = {'blueArmor', 'bluePD2'},
		red = {'Red SAM AAA','Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8','Red SAM SHORAD SA-15','Red SAM SA-10', 'Red SAM SHORAD SA-15'}
	},
	sam4kilofixed = {
		blue = {'blueArmor', 'bluePD2'},
		red = {'Red SAM AAA','Red SAM SHORAD SA-15','Red SAM SA-10', 'Red SAM SHORAD SA-15', 'Red SAM AAA 2'}
	},
	
	samdeltaFixed = {
		blue = {'blueHAWK'},
		red = {'Red SAM AAA','Red SAM SHORAD SA-19','Red SAM SA-10'}
	},
	sam5 = {
		blue = {'blueArmor', 'blueHAWK'},
		red = {'Red SAM SHORAD SA-15','Red SAM AAA','Red SAM SHORAD SA-8', 'Red SAM AAA 2', 'Red SAM SA-11', 'Red SAM SHORAD SA-15'}
	},
	
	SamLimaFixedSA11 = {
		blue = {},
		red = {'Red SAM SHORAD SA-15', 'Red SAM SA-6', 'Red SAM SA-11'}
	},
	
	sam6 = {
		blue = {},
		red = {'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19', 'Red SAM SA-5 Fixed SAM-Mike'}
	},
	farp1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces','Red Armour Group', 'Red Armour Group 4','Red SAM AAA','Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM AAA 2'}
	},
	Echo = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces','Echo Troops Tent 2','Red Armour Group', 'Red Armour Group 4','Red SAM AAA','Echo Troops Tent','Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8'}
	},
	Alpha = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces','Red Armour Group', 'Red Armour Group 4','Alpha Troops Tent','Red SAM AAA','Alpha Troops Tent 2','Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19'}
	},
	farp2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red Armour Group', 'Red Armour Group 4', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-15'}
	},
	farp3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Red Armour Group', 'Red Armour Group 4', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15'}
	},
	Golf = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Red Armour Group 2', 'Red Armour Group 3','Golf Troops Tent 2','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8','Golf Troops Tent', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8'}
	},
	farp4 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8'}
	},
	mission1 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy ground forces', 'Red Armour Group', 'Red Armour Group 4', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Pantsir S1'}
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
		red = {'Enemy Task forces', 'Red Armour Group 2', 'Red Armour Group 3', 'InsurgentCamp', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15'}
	}, 
	ChemSite = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy Task forces', 'Red SAM AAA','Chemical tank 3','Chemsite Factory','Chemical tank 2', 'Red Armour Group 2', 'Red Armour Group 3','Chemsite Factory 2','Chemical tank', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15'}
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
		red = {'Enemy Task forces','FuelDepo Refinery', 'Fuel Depo tank','Red SAM SHORAD SA-8', 'Red SAM AAA', 'Fuel Depo tank 2', 'Red Armour Group 2', 'Red Armour Group 3','Fuel Depo tank 3', 'Red SAM SHORAD SA-8', 'Fuel Depo tank 4'}
	},
	SAMEcho = {
		blue = {'blueHAWK'},
		red = {'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM SA-11','Red SAM SHORAD Pantsir S1'}
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
	},
	Hidden8Group = {
		blue = {},
		red = {'hiddenground8-Fixed-1', 'hiddenground8-Fixed-2', 'hiddenground8-Fixed-3'}
	},
	Hidden4Group = {
		blue = {},
		red = {'hiddenground-Map-Template1','hiddenground-Map-Template2','hiddenground-Map-Template1','hiddenground-Map-Template2','hiddenground-Map-Template1','hiddenground-Map-Template2','hiddenground-Map-Template1','hiddenground-Map-Template2'}
	},
	Hidden5Group = {
		blue = {},
		red = {'hiddenground-Map-Template1','hiddenground-Map-Template2','hiddenground-Map-Template1','hiddenground-Map-Template2','hiddenground-Map-Template1','hiddenground-Map-Template2','hiddenground-Map-Template1','hiddenground-Map-Template2'}
	},
	Hidden6Group = {
		blue = {},
		red = {'hiddenground-Map-Template1','hiddenground-Map-Template2','hiddenground-Map-Template1','hiddenground-Map-Template3','hiddenground-Map-Template1','hiddenground-Map-Template3','hiddenground-Map-Template1','hiddenground-Map-Template3'}
	},
	Hidden7Group = {
		blue = {},
		red = {'hiddenground-Map-Template1','hiddenground-Map-Template2','hiddenground-Map-Template1','hiddenground-Map-Template3','hiddenground-Map-Template1','hiddenground-Map-Template3','hiddenground-Map-Template1','hiddenground-Map-Template3'}
	},
}

flavor = {
	redcarrier = L10N:Get("CA_FLAVOR_ENEMY_CARRIER_ZONE"),
	bluecarrier = L10N:Format("SYRIA_FLAVOR_START_ZONE", ""),
	
	batumi = L10N:Format("SYRIA_FLAVOR_WPT", 2),
	kobuleti = L10N:Format("SYRIA_FLAVOR_WPT", 3),
	senaki = L10N:Format("SYRIA_FLAVOR_WPT", 4),
	kutaisi = L10N:Format("SYRIA_FLAVOR_WPT", 5),
	alpha = L10N:Format("SYRIA_FLAVOR_WPT", 6),
	sukhumi = L10N:Format("SYRIA_FLAVOR_WPT", 7),
	gudauta = L10N:Format("SYRIA_FLAVOR_WPT", 8),
	sochi = L10N:Format("SYRIA_FLAVOR_WPT", 9),
	bravo = L10N:Format("SYRIA_FLAVOR_WPT", 10),
	charlie = L10N:Format("SYRIA_FLAVOR_WPT", 11),
	delta = L10N:Format("SYRIA_FLAVOR_WPT", 12),
	gelendzhik = L10N:Format("SYRIA_FLAVOR_WPT", 13),
	novorossiysk = L10N:Format("SYRIA_FLAVOR_WPT", 14),
	anapa = L10N:Format("SYRIA_FLAVOR_WPT", 15),
	krymsk = L10N:Format("SYRIA_FLAVOR_WPT", 16),
	echo = L10N:Format("SYRIA_FLAVOR_WPT", 17),
	krasnodarc = L10N:Format("SYRIA_FLAVOR_WPT", 18),
	krasnodarp = L10N:Format("SYRIA_FLAVOR_WPT", 19),
	foxtrot = L10N:Format("SYRIA_FLAVOR_WPT", 20),
	maykop = L10N:Format("SYRIA_FLAVOR_WPT", 21),
	golf = L10N:Format("SYRIA_FLAVOR_WPT", 22),
	hotel = L10N:Format("SYRIA_FLAVOR_WPT", 23),
	india = L10N:Format("SYRIA_FLAVOR_WPT", 24),
	mineralnye = L10N:Format("SYRIA_FLAVOR_WPT", 25),
	nalchik = L10N:Format("SYRIA_FLAVOR_WPT", 26),
	moxdok = L10N:Format("SYRIA_FLAVOR_WPT", 27),
	beslan = L10N:Format("SYRIA_FLAVOR_WPT", 28),
	juliett = L10N:Format("SYRIA_FLAVOR_WPT", 29),
	kilo = L10N:Format("SYRIA_FLAVOR_WPT", 30),
	lima = L10N:Format("SYRIA_FLAVOR_WPT", 31),
	soganlug= L10N:Format("SYRIA_FLAVOR_WPT", 32),
	tbilisi = L10N:Format("SYRIA_FLAVOR_WPT", 33),
	vaziani = L10N:Format("SYRIA_FLAVOR_WPT", 34),
	
	miningfacility = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	insurgentcamp = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	secrettechfacility = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	fueldepo = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	ammonitiondepo = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	tankfactory = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	samsite = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	chemsite = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	artilleryfactory = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	
	samalpha = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	sambravo = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	samcharlie = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	samdelta = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	samecho = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	samfoxtrot = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	samgolf = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	samhotel = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	samindia = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	samjuliett = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	samkilo = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	samlima = L10N:Format("SYRIA_FLAVOR_WPT", ""),
	sammike = L10N:Format("SYRIA_FLAVOR_WPT", "")
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

FootholdSaveBaseName = (Era == 'Coldwar') and 'FootHold_CA_v0.2_Coldwar' or 'FootHold_CA_v0.2'

local filepath = FootholdSaveBaseName .. '.lua'
if lfs then
  FootholdSavePath = FootholdSavePath or (lfs.writedir()..'Missions/Saves')
  lfs.mkdir(FootholdSavePath)
  filepath = FootholdSavePath .. '/' .. (FootholdSaveBaseName .. '.lua')
  env.info('Foothold - Save file path: '..filepath)
end

local cwSwap = {
	['Red Armour Group 4']   						= 'Red Armor Group8',
	['Red Armour Group 2']   						= 'Red Armor Group9',
	['Red Armour Group 3']  						= 'Red Armor Group6',
	['Red Armour Group']  							= 'Red Armor Group7',
	['Red SAM SHORAD Pantsir S1']  					= { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
	['Red SAM SHORAD Tor M2']  						= { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
	['Neustrashimy']  								= 'Molniya',
	['blueArmor']  									= 'blueArmor-Coldwar',
	['bluePD1']  									= 'blueHAWK-Coldwar',
	['blueHAWK']  									= 'blueHAWK-Coldwar',
	['Red Arty 4']  								= 'Red Arty 3',
	['Red Arty 2']  								= 'Red Arty 3',
	['Red Arty']  									= 'Red Arty 3',
	['Fixed Ammunitiondepo Armor']  				= 'Fixed Ammunitiondepo Armor Coldwar',
	['MiningFacility Fixed Group 1']  				= 'MiningFacility Fixed Group Coldwar',
	['MiningFacility Fixed Group 2']  				= 'MiningFacility Fixed Group 2 Coldwar',

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

	['Red SAM SA-11 Fixed SAM-Lima']  				= 'Red SAM SA-3 Fixed SAM-Lima',
	['Red SAM SA-11']  								= { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },
	['Red SAM SA-10']  								= { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },

}

local SamSwapNoTorM2AndPantsir = {
	['Red SAM SHORAD Pantsir S1'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
	['Red SAM SHORAD Tor M2'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
}

local SamSwapNoSA15 = {
	['Red SAM SHORAD SA-15'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
	['Red SAM SHORAD SA-15 Fixed ammunitiondepo'] = 'Red SAM SHORAD SA-8 Fixed ammunitiondepo',

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
	"bSamBig",
	"bSamFinal",
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

ZoneSizeExclusions = {
	small = { "sa-10", "sa-11","sa-2","pantsir","tor m2" },
	medium = { "sa-10", "sa-11","pantsir"},
	redarmycamp = { "sa-10", "sa-11","sa-2","pantsir","tor m2", "sa-15" ,"red sam aaa 3","red sam aaa 4"},
	redarmycamp2 = { "sa-10", "sa-11","sa-2","pantsir","tor m2", "sa-15" ,"red sam aaa 3","red sam aaa 4"},
	redarmycamp3 = { "sa-10", "sa-2","pantsir","tor m2"},

}

RandomUpgradeTemplates = {
	small = { sam = 0, shorad = {1,2}, aaa = 2, ground = 1, armor = {1,2}, arty = {0,1}, total = {5,7} },
	smallmedium = { sam = 0, shorad = {1,3}, aaa = 2, ground = 1, armor = {1,2}, arty = {0,1}, total = {6,8} },
	medium = { sam = {0,1}, shorad = {1,3}, aaa = {1,3}, ground = 1, armor = {1,2}, arty = 1, total = {7,9} },
	mediumbig = { sam = {0,1}, shorad = {2,3}, aaa = {1,2}, ground = 1, armor = 2, arty = 1, total = {7,10} },
	big = { sam = 1, shorad = {2,3}, aaa = {1,2}, ground = 1, armor = 2, arty = 1, total = {8,10} },
	bignosam = { sam = 0, shorad = {3,4}, aaa = {1,2}, ground = 1, armor = 2, arty = 1, total = {7,10} },
	extrabig = { sam = 2, shorad = {3,4}, aaa = 2, ground = 1, armor = {1,2}, arty = 1, total = {10,12} },
	sam = { sam = 1, shorad = {1,2}, aaa = {1,2}, ground = 0, armor = 0, arty = 0, total = {5,5} },
	sam2 = { sam = 1, shorad = {1,2}, aaa = {1,2}, ground = 0, armor = {0,1}, arty = 0, total = {5,6} },
	samspecial = { sam = 2, shorad = {1,3}, aaa = {1,2}, ground = 0, armor = 0, arty = 0, total = {6,7} },
	redarmycamp = { sam = 0, shorad = 0, aaa = 0, ground = {3,5}, armor = 0, arty = {0,5}, total = {6,8} },
	redarmycamp2 = { sam = 0, shorad = 0, aaa = {1,2}, ground = {3,5}, armor = 0, arty = {0,4}, total = {6,8} },
	redarmycamp3 = { sam = {0,2}, shorad = {0,3}, aaa = {1,3}, ground = 0, armor = 0, arty = 0, total = {6,8} },

}

RandomUpgradeTemplatesBlue = {
	small = { sam = {0,1}, ground = 1, armor = 1, total = {2,3} },
	smallmedium = { sam = {0,1}, ground = 1, armor = 1, total = {2,3} },
	medium = { sam = {0,1}, ground = 1, armor = 1, total = {2,3} },
	big = { sam = 1, ground = 1, armor = 1, total = {3,4} },
	extrabig = { sam = {0,1}, ground = 1, armor = 1, total = {3,4} },
	bignosam = { sam = {0,1}, ground = 1, armor = 1, total = {3,4} },
	sam = { sam = {0,1}, ground = 1, armor = 1, total = {3,4} },
	sam2 = { sam = {0,1}, ground = 1, armor = 1, total = {3,4} },
	samspecial = { sam = {0,1}, ground = 1, armor = 1, total = {3,4} },
}

RandomGroundGroups = true
RandomBlueGroups = true
AllowScriptedSupplies = AllowScriptedSupplies ~= false


bc = BattleCommander:new(filepath, 10, 60)
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
end
Hunt = true


zones = {
	redcarrier = ZoneCommander:new({zone='Red Carrier', side=1, level=25, upgrades=upgrades.redships, crates={}, flavorText=flavor.redcarrier}),
	bluecarrier = ZoneCommander:new({zone='Blue Carrier', side=StartNormal and 2 or 0, level=25, upgrades=upgrades.blueships, crates={}, flavorText=flavor.bluecarrier}),
	
	batumi = ZoneCommander:new({zone='Batumi', side = StartNormal and 2 or 1, size= StartNormal and 'bignosam' or 'big', level=25, upgrades=upgrades.airfield1, crates={}, flavorText=flavor.batumi}),
	kobuleti = ZoneCommander:new({zone='Kobuleti', side=1, size='mediumbig', level=25, upgrades=upgrades.Kobuleti, crates={}, flavorText=flavor.kobuleti}),
	senaki = ZoneCommander:new({zone='Senaki', side=1, size='mediumbig', level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.senaki}),
	kutaisi = ZoneCommander:new({zone='Kutaisi', side=1, size='medium', level=25, upgrades=upgrades.airfield4Kutaisi, crates={}, flavorText=flavor.kutaisi}),
	sukhumi = ZoneCommander:new({zone='Sukhumi', side=1, size='bignosam', level=25, upgrades=upgrades.airfield1, crates={}, flavorText=flavor.sukhumi}),
	gudauta = ZoneCommander:new({zone='Gudauta', side=1, size='mediumbig', level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.gudauta}),
	sochi = ZoneCommander:new({zone='Sochi', side=1, size='mediumbig', level=25, upgrades=upgrades.Sochi, crates={}, flavorText=flavor.sochi}),
	gelendzhik = ZoneCommander:new({zone='Gelendzhik', side=1, size='mediumbig', level=25, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.gelendzhik}),
	novorossiysk = ZoneCommander:new({zone='Novorossiysk', side=1, size='bignosam', level=25, upgrades=upgrades.Novorossiysk, crates={}, flavorText=flavor.novorossiysk}),
	anapa = ZoneCommander:new({zone='Anapa', side=1, size='mediumbig', level=25, upgrades=upgrades.Anapa, crates={}, flavorText=flavor.anapa}),
	krymsk = ZoneCommander:new({zone='Krymsk', side=1, size='mediumbig', level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.krymsk}),
	krasnodarc = ZoneCommander:new({zone='Krasnodar-Center', side=1, size='mediumbig', level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.krasnodarc}),
	krasnodarp = ZoneCommander:new({zone='Krasnodar-Pashkovsky', side=1, size='mediumbig', level=25, upgrades=upgrades.Pashkovsky, crates={}, flavorText=flavor.krasnodarp}),
	maykop = ZoneCommander:new({zone='Maykop', side=1, size='mediumbig', level=25, upgrades=upgrades.airfield3Maykop, crates={}, flavorText=flavor.maykop}),
	mineralnye = ZoneCommander:new({zone='Mineralnye', side=1, size='bignosam', level=25, upgrades=upgrades.Mineralnye, crates={}, flavorText=flavor.mineralnye}),
	nalchik = ZoneCommander:new({zone='Nalchik', side=1, size='mediumbig', level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.nalchik}),
	mozdok = ZoneCommander:new({zone='Mozdok', side=1, size='mediumbig', level=25, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.mozdok}),
	beslan = ZoneCommander:new({zone='Beslan', side=1, size='mediumbig', level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.beslan}),
	soganlug = ZoneCommander:new({zone='Soganlug', side = StartNormal and 1 or 2, size='smallmedium', level=25, upgrades=upgrades.Soganlug, crates={}, flavorText=flavor.soganlug}),
	tbilisi = ZoneCommander:new({zone='Tbilisi', side = StartNormal and 1 or 2, size='mediumbig', level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.tbilisi}),
	vaziani = ZoneCommander:new({zone='Vaziani', side = StartNormal and 1 or 2, size='mediumbig', level=25, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.vaziani}),
	
	alpha = ZoneCommander:new({zone='Alpha', side=1, size='smallmedium', level=25, upgrades=upgrades.Alpha, crates={}, flavorText=flavor.alpha}),
	bravo = ZoneCommander:new({zone='Bravo', side=1, size='smallmedium', level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.bravo}),
	charlie = ZoneCommander:new({zone='Charlie', side=1, size='smallmedium', level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.charlie}),
	delta = ZoneCommander:new({zone='Delta', side=1, size='small', level=25, upgrades=upgrades.farp4, crates={}, flavorText=flavor.delta}),
	echo = ZoneCommander:new({zone='Echo', side=1, size='smallmedium', level=25, upgrades=upgrades.Echo, crates={}, flavorText=flavor.echo}),
	foxtrot = ZoneCommander:new({zone='Foxtrot', side=1, size='smallmedium', level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.foxtrot}),
	golf = ZoneCommander:new({zone='Golf', side=1, size='smallmedium', level=25, upgrades=upgrades.Golf, crates={}, flavorText=flavor.golf}),
	hotel = ZoneCommander:new({zone='Hotel', side=1, size='small', level=25, upgrades=upgrades.farp4, crates={}, flavorText=flavor.hotel}),
	india = ZoneCommander:new({zone='India', side=1, size='smallmedium', level=25, upgrades=upgrades.farp1, crates={}, flavorText=flavor.india}),
	juliett = ZoneCommander:new({zone='Juliett', side=1, size='small', level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.juliett}),
	kilo = ZoneCommander:new({zone='Kilo', side=1, size='small', level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.kilo}),
	lima = ZoneCommander:new({zone='Lima', side=1, size='small', level=25, upgrades=upgrades.farp4, crates={}, flavorText=flavor.lima}),
	
	miningfacility = ZoneCommander:new({zone='MiningFacility', side=1, size='small', level=25, upgrades=upgrades.MiningFacilityFixed, crates={}, flavorText=flavor.miningfacility}),
	insurgentcamp = ZoneCommander:new({zone='InsurgentCamp', side=1, size='mediumbig', level=25, upgrades=upgrades.insurgentcamp, crates={}, flavorText=flavor.insurgentcamp}),
	secrettechfacility = ZoneCommander:new({zone='SecretTechFacility', side=1, size='smallmedium', level=25, upgrades=upgrades.SecretTechFacility, crates={}, flavorText=flavor.secrettechfacility}),
	fueldepo = ZoneCommander:new({zone='FuelDepo', side=1, size='smallmedium', level=20, upgrades=upgrades.fueldepo, crates={}, flavorText=flavor.fueldepo}),
	ammonitiondepo = ZoneCommander:new({zone='AmmonitionDepo', side=1, size='small', level=25, upgrades=upgrades.ammunitiondepounits, crates={}, flavorText=flavor.ammonitiondepo}),
	tankfactory = ZoneCommander:new({zone='TankFactory', side=1, size='smallmedium', level=25, upgrades=upgrades.TankFactory, crates={}, flavorText=flavor.tankfactory}),
	chemsite = ZoneCommander:new({zone='ChemSite', side=1, size='smallmedium', level=25, upgrades=upgrades.ChemSite, crates={}, flavorText=flavor.chemsite}),
	artilleryfactory = ZoneCommander:new({zone='ArtilleryFactory', side=1, size='smallmedium', level=25, upgrades=upgrades.ArtilleryFactory, crates={}, flavorText=flavor.artilleryfactory}),
	samsite = ZoneCommander:new({zone='SAMSite', side=1, size='sam', level=25, upgrades=upgrades.sam5, crates={}, flavorText=flavor.samsite}),
    insurgencygriddl22 = ZoneCommander:new({zone='Insurgency Grid DL22', size=(math.random(1,2) == 1 and 'redarmycamp' or 'redarmycamp2'), side=1, level=20, upgrades=upgrades.farp2, crates={}, flavorText=flavor.insurgencygriddl22,NeutralAtStart=true,Popup=true}),
    insurgencygridmn47 = ZoneCommander:new({zone='Insurgency Grid MN47', size=(math.random(1,2) == 1 and 'redarmycamp' or 'redarmycamp2'), side=1, level=20, upgrades=upgrades.farp2, crates={}, flavorText=flavor.insurgencygridmn47,NeutralAtStart=true,Popup=true}),
    insurgencygridfj98 = ZoneCommander:new({zone='Insurgency Grid FJ98', size=(math.random(1,2) == 1 and 'redarmycamp' or 'redarmycamp2'), side=1, level=20, upgrades=upgrades.farp2, crates={}, flavorText=flavor.insurgencygridfj98,NeutralAtStart=true,Popup=true}),
    insurgencygridel70 = ZoneCommander:new({zone='Insurgency Grid EL70', size='redarmycamp3', side=1, level=20, upgrades=upgrades.farp2, crates={}, flavorText=flavor.insurgencygridel70,NeutralAtStart=true,Popup=true}),

-- Insurgency Grid DL22

	samalpha = ZoneCommander:new({zone='SAM-Alpha', side=1, size='sam', level=25, upgrades=upgrades.samalphaFixed, crates={}, flavorText=flavor.samalpha,noLongRangeSam=true}),
	sambravo = ZoneCommander:new({zone='SAM-Bravo', side=1, size='sam', level=25, upgrades=upgrades.sambravoFixed, crates={}, flavorText=flavor.sambravo, noLongRangeSam=true}),
	samcharlie = ZoneCommander:new({zone='SAM-Charlie', side=1, size='sam', level=25, upgrades=upgrades.samcharliefixed, crates={}, flavorText=flavor.samcharlie}),
	samdelta = ZoneCommander:new({zone='SAM-Delta', side=1, size='sam', level=25, upgrades=upgrades.samdeltaFixed, crates={}, flavorText=flavor.samdelta}),
	samecho = ZoneCommander:new({zone='SAM-Echo', side=1, size='sam', level=25, upgrades=upgrades.SAMEcho, crates={}, flavorText=flavor.samecho}),
	samfoxtrot = ZoneCommander:new({zone='SAM-Foxtrot', side=1, size='sam', level=25, upgrades=upgrades.samFoxtrotFixed, crates={}, flavorText=flavor.samfoxtrot}),
	samgolf = ZoneCommander:new({zone='SAM-Golf', side=1, size='samspecial', level=25, upgrades=upgrades.samgolf, crates={}, flavorText=flavor.samgolf}),
	samhotel = ZoneCommander:new({zone='SAM-Hotel', side=1, size='sam', level=25, upgrades=upgrades.sam3, crates={}, flavorText=flavor.samhotel}),
	samindia = ZoneCommander:new({zone='SAM-India', side=1, size='sam', level=25, upgrades=upgrades.sam4indiafixed, crates={}, flavorText=flavor.samindia}),
	samjuliett = ZoneCommander:new({zone='SAM-Juliett', side=1, size='sam', level=25, upgrades=upgrades.sam5, crates={}, flavorText=flavor.samjuliett}),
	samkilo = ZoneCommander:new({zone='SAM-Kilo', side=1, size='sam', level=25, upgrades=upgrades.sam4kilofixed, crates={}, flavorText=flavor.samkilo}),
	samlima = ZoneCommander:new({zone='SAM-Lima', side=1, size='sam', level=25, upgrades=upgrades.SamLimaFixedSA11, crates={}, flavorText=flavor.samlima}),
	sammike = ZoneCommander:new({zone='SAM-Mike', side=1, size='sam', level=25, upgrades=upgrades.sam6, crates={}, flavorText=flavor.sammike}),
	hidden = ZoneCommander:new({zone='Hidden', side=0, level=25, upgrades=upgrades.HiddenGroup, crates={}, flavorText=flavor.hidden0,NeutralAtStart=true}),
	hidden1 = ZoneCommander:new({zone='Hidden1', side=1, level=25, upgrades=upgrades.Hidden1Group, crates={}, flavorText=flavor.hidden1,NeutralAtStart=true}),
	hidden2 = ZoneCommander:new({zone='Hidden2', side=0, level=25, upgrades=upgrades.Hidden2Group, crates={}, flavorText=flavor.hidden2,NeutralAtStart=true}),
	hidden3 = ZoneCommander:new({zone='Hidden3', side=0, level=25, upgrades=upgrades.Hidden3Group, crates={}, flavorText=flavor.hidden3,NeutralAtStart=true}),
	hidden4 = ZoneCommander:new({zone='Hidden4', side=0, level=25, upgrades=upgrades.Hidden4Group, crates={}, flavorText=flavor.hidden4,NeutralAtStart=true}),
	hidden5 = ZoneCommander:new({zone='Hidden5', side=0, level=25, upgrades=upgrades.Hidden5Group, crates={}, flavorText=flavor.hidden5,NeutralAtStart=true}),
	hidden6 = ZoneCommander:new({zone='Hidden6', side=0, level=25, upgrades=upgrades.Hidden6Group, crates={}, flavorText=flavor.hidden6,NeutralAtStart=true}),
	hidden7 = ZoneCommander:new({zone='Hidden7', side=0, level=25, upgrades=upgrades.Hidden7Group, crates={}, flavorText=flavor.hidden7,NeutralAtStart=true}),
	hidden8 = ZoneCommander:new({zone='Hidden8', side=0, level=25, upgrades=upgrades.Hidden8Group, crates={}, flavorText=flavor.hidden8,NeutralAtStart=true}),
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
zones.bluecarrier.airbaseName = 'CVN-72'
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

--
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
})

zones.redcarrier:addGroups({
	GroupCommander:new({name='Red-carrier-capture-Blue-carrier-blue', mission='supply', targetzone='Blue Carrier', type='surface', urgent = function() return zones.bluecarrier.side == 0 end, ForceUrgent = true}),
	
})
zones.kobuleti:addGroups({
	GroupCommander:new({name='Support-SAM-Alpha', mission='supply', targetzone='SAM-Alpha',template='SupplyConvoy', type='surface'}),
	GroupCommander:new({name='Kobuleti-supply-Senaki', mission='supply',template='HeloSupplyTemplate', targetzone='Senaki'}),
	GroupCommander:new({name='Kobuleti-attack-patrol-Cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Batumi', Altitude = CapAltitude()}),
	GroupCommander:new({name='Kobuleti-attack-Kutaisi-Cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Kutaisi', Altitude = CapAltitude()}),
	GroupCommander:new({name='Kobuleti-patrol-Kutaisi-Cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Kutaisi', Altitude = CapAltitude()}),

})
zones.batumi:addGroups({
	GroupCommander:new({name='Batumi-supply-carrier-blue', mission='supply', targetzone='Blue Carrier', type='surface', urgent = function() return zones.bluecarrier.side == 0 end, ForceUrgent = true}),
	GroupCommander:new({name='Batumi-supply-Kobuleti', mission='supply',template='HeloSupplyTemplate', targetzone='Kobuleti'}),
	GroupCommander:new({name='Batumi-supply-Kutaisi', mission='supply',template='PlaneSupplyTemplate', targetzone='Kutaisi'}),
	GroupCommander:new({name='Batumi-supply-Sochi', mission='supply',template='PlaneSupplyTemplate', targetzone='Sochi'}),
	GroupCommander:new({name='Batumi-attack-Kobuleti-Cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Kobuleti', Altitude = CapAltitude()}),
})
zones.senaki:addGroups({
	GroupCommander:new({name='Support-SAM-Bravo', mission='supply',template='SupplyConvoy', targetzone='SAM-Bravo', type='surface'}),
	GroupCommander:new({name='senaki-supply-kutaisi', mission='supply',template='HeloSupplyTemplate', targetzone='Kutaisi'}),
	GroupCommander:new({name='senaki-supply-alpha', mission='supply',template='HeloSupplyTemplate', targetzone='Alpha'}),
	GroupCommander:new({name='senaki-patrol-senaki-Cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Senaki', Altitude = CapAltitude()}),
	GroupCommander:new({name='senaki-attack-Alpha-Cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Alpha', Altitude = CapAltitude()}),
	GroupCommander:new({name='senaki-attack-Alpha-Cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Alpha', Altitude = CapAltitude()}),


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
	GroupCommander:new({name='Kutaisi-attack-Senaki-Arty', mission='attack',template='ArtilleryConvoyShort', targetzone='Senaki',MissionType='ARTY', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='Kutaisi-attack-Sukhumi', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Sukhumi', Altitude = CapAltitude()}),
	GroupCommander:new({name='Kutaisi-supply-Sochi', mission='supply',template='PlaneSupplyTemplate', targetzone='Sochi'}),

})
zones.sukhumi:addGroups({
	GroupCommander:new({name='Support-SAM-Delta', mission='supply',template='SupplyConvoy', targetzone='SAM-Delta', type='surface'}),
	GroupCommander:new({name='sukhumi-attack-Sochi', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Sochi', Bluecondition = function() return not zones.samdelta.active end, Altitude = CapAltitude()}),
	GroupCommander:new({name='Sukhumi-supply-gudauta', mission='supply',template='HeloSupplyTemplate', targetzone='Gudauta'}),
	GroupCommander:new({name='Sukhumi-supply-alpha', mission='supply',template='HeloSupplyTemplate', targetzone='Alpha'}),
	GroupCommander:new({name='Sukhumi-attack-Kutaisi-RunwayStrike', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Kutaisi'}),
	GroupCommander:new({name='Sukhumi-patrol-Alpha', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Alpha', Altitude = CapAltitude()}),
	GroupCommander:new({name='Sukhumi-attack-Alpha', mission='attack',template='AttackConvoy', targetzone='Alpha', type='surface'}),
	GroupCommander:new({name='Sukhumi-supply-Sochi', mission='supply',template='PlaneSupplyTemplate', targetzone='Sochi'}),
})
zones.gudauta:addGroups({
	GroupCommander:new({name='Gudauta-supply-sochi', mission='supply',template='HeloSupplyTemplate', targetzone='Sochi', Redcondition = function() return end}),
	GroupCommander:new({name='Gudauta-supply-sukhumi', mission='supply',template='HeloSupplyTemplate', targetzone='Sukhumi'}),
	GroupCommander:new({name='Gudauta-attack-Sukhumi', mission='attack',template='AttackConvoy', targetzone='Sukhumi', type='surface'}),
	GroupCommander:new({name='gudauta-capture-Red-carrier-blue', mission='supply', targetzone='Red Carrier', type='surface', urgent = function() return zones.redcarrier.side == 0 end, ForceUrgent = true, Bluecondition = function() return not zones.sochi.side == 2 end}),
	GroupCommander:new({name='Gudauta-attack-Sukhumi-Arty', mission='attack', targetzone='Sukhumi', type='surface', SetActiveMission = true}),

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
	GroupCommander:new({name='Sochi-supply-mykop-by-air', mission='supply',template='PlaneSupplyTemplate', targetzone='Maykop'}),
	GroupCommander:new({name='Sochi-supply-Maykop', mission='supply',template='PlaneSupplyTemplate', targetzone='Maykop'}),
	GroupCommander:new({name='Sochi-supply-Anapa', mission='supply',template='PlaneSupplyTemplate', targetzone='Anapa'}),
	GroupCommander:new({name='Sochi-capture-Red-carrier-blue', mission='supply', targetzone='Red Carrier', type='surface', urgent = function() return zones.redcarrier.side == 0 end, ForceUrgent = true, Bluecondition = function() return true end}),

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
	GroupCommander:new({name='Delta-supply-Gelendzhik', mission='supply',template='HeloSupplyTemplate', targetzone='Gelendzhik'}),
	GroupCommander:new({name='Delta-supply-Charlie', mission='supply',template='HeloSupplyTemplate', targetzone='Charlie'}),
})
zones.novorossiysk:addGroups({
	GroupCommander:new({name='Support-SAM-Foxtrot', mission='supply',template='SupplyConvoy', targetzone='SAM-Foxtrot', type='surface'}),
	GroupCommander:new({name='novorossiysk-supply-Anapa', mission='supply',template='HeloSupplyTemplate', targetzone='Anapa'}),
	GroupCommander:new({name='novorossiysk-supply-Gelendzhik', mission='supply',template='HeloSupplyTemplate', targetzone='Gelendzhik'}),
	GroupCommander:new({name='novorossiysk-supply-Krymsk', mission='supply',template='HeloSupplyTemplate', targetzone='Krymsk'}),
	GroupCommander:new({name='Novorossiysk-attack-Gelendzhik-Arty', mission='attack', targetzone='Gelendzhik', type='surface', SetActiveMission = true}),
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
	GroupCommander:new({name='Anapa-patrol-Novorossiysk-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Novorossiysk', Altitude = CapAltitude()}),
	GroupCommander:new({name='Anapa-patrol-Charlie-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Charlie', Altitude = CapAltitude()}),
	GroupCommander:new({name='Anapa-supply-Krymsk', mission='supply',template='HeloSupplyTemplate', targetzone='Krymsk'}),
	GroupCommander:new({name='Anapa-supply-Novorossiysk', mission='supply',template='HeloSupplyTemplate', targetzone='Novorossiysk'}),
	GroupCommander:new({name='Anapa-supply-Gelendzhik', mission='supply',template='HeloSupplyTemplate', targetzone='Gelendzhik'}),
	GroupCommander:new({name='Anapa-supply-Sochi-by-air', mission='supply', template='PlaneSupplyTemplate', targetzone='Sochi'}),
	GroupCommander:new({name='Anapa-supply-SAM-Golf', mission='supply',template='SupplyConvoy', targetzone='SAM-Golf', type='surface'}),
	GroupCommander:new({name='Anapa-supply-Krymsk-plane', mission='supply',template='PlaneSupplyTemplate', targetzone='Krymsk'}),
	GroupCommander:new({name='Anapa-supply-KrasnodarC-plane', mission='supply',template='PlaneSupplyTemplate', targetzone='Krasnodar-Center'}),
	GroupCommander:new({name='Anapa-supply-KrasnodarP-plane', mission='supply',template='PlaneSupplyTemplate', targetzone='Krasnodar-Pashkovsky'}),
})
zones.krymsk:addGroups({
	GroupCommander:new({name='Krymsk-Patrol-Anapa-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Anapa', Altitude = CapAltitude()}),
	GroupCommander:new({name='krymsk-supply-Anapa', mission='supply',template='HeloSupplyTemplate', targetzone='Anapa'}),
	GroupCommander:new({name='Krymsk-supply-Echo', mission='supply', template='HeloSupplyTemplate', targetzone='Echo'}),
	GroupCommander:new({name='Krymsk-attack-Anapa-Arty', mission='attack', targetzone='Anapa',type ='surface', SetActiveMission = true}),
	GroupCommander:new({name='Krymsk-attack-Echo-Arty', mission='attack',template='ArtilleryConvoyShort',MissionType='ARTY',Reward=250, targetzone='Echo', type='surface', SetActiveMission = true}),

})

zones.echo:addGroups({
	GroupCommander:new({name='Echo-attack-Krymsk-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Krymsk'}),
	GroupCommander:new({name='Echo-supply-krymsk', mission='supply', template='HeloSupplyTemplate', targetzone='Krymsk'}),
	GroupCommander:new({name='Echo-attack-Krymsk-Arty', mission='attack', targetzone='Krymsk',type ='surface', SetActiveMission = true}),
	GroupCommander:new({name='Echo-supply-krasnodar-center', mission='supply', template='HeloSupplyTemplate', targetzone='Krasnodar-Center'}),
	GroupCommander:new({name='Echo-attack-krasnodar-Center-Arty', mission='attack',template='ArtilleryConvoyShort',MissionType='ARTY',Reward=250, targetzone='Krasnodar-Center', type='surface', SetActiveMission = true}),

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
	GroupCommander:new({name='krasnodarp-supply-Maykop', mission='supply',template='HeloSupplyTemplate', targetzone='Maykop'}),
	GroupCommander:new({name='krasnodarp-supply-SAM-Hotel', mission='supply',template='SupplyConvoy', targetzone='SAM-Hotel', type='surface'}),
	GroupCommander:new({name='Support-supply-Krasnodar-Center', mission='supply',template='SupplyConvoy', targetzone='Krasnodar-Center', type='surface'}),
	GroupCommander:new({name='krasnodarp-supply-Foxtrot', mission='supply',template='HeloSupplyTemplate', targetzone='Foxtrot'})
})

zones.foxtrot:addGroups({
	GroupCommander:new({name='Foxtrot-supply-Maykop', mission='supply',template='HeloSupplyTemplate', targetzone='Maykop'})
	
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
	GroupCommander:new({name='Maykop-supply-Sochi', mission='supply',template='PlaneSupplyTemplate', targetzone='Sochi'}),
	GroupCommander:new({name='Maykop-supply-mineralnye', mission='supply',template='PlaneSupplyTemplate', targetzone='Mineralnye'}),
	GroupCommander:new({name='Maykop-supply-SAM-India', mission='supply',template='SupplyConvoy', targetzone='SAM-India', type='surface'}),
	GroupCommander:new({name='Maykop-supply-Maykop', mission='supply',template='PlaneSupplyTemplate', targetzone='Mineralnye'}),
})


zones.golf:addGroups({
	GroupCommander:new({name='Golf-supply-Maykop', mission='supply',template='HeloSupplyTemplate', targetzone='Maykop'}),
	GroupCommander:new({name='Golf-supply-hotel', mission='supply',template='HeloSupplyTemplate', targetzone='Hotel'}),
	GroupCommander:new({name='Golf-attack-hotel', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Maykop'}),
	GroupCommander:new({name='Golf-attack-Maykop-Arty', mission='attack',MissionType='CAS', targetzone='Maykop', type='surface', SetActiveMission = true}),
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
	GroupCommander:new({name='mozdok-supply-nalchik', mission='supply', template='PlaneSupplyTemplate', targetzone='Nalchik'}),
	GroupCommander:new({name='Mozdok-supply-Beslan', mission='supply', template='PlaneSupplyTemplate', targetzone='Beslan'}),
	GroupCommander:new({name='Mozdok-supply-Mineralnye', mission='supply',template='PlaneSupplyTemplate', targetzone='Mineralnye'}),
	GroupCommander:new({name='Mozdok-Support-SAM-Kilo', mission='supply', template='SupplyConvoy', targetzone='SAM-Kilo', type='surface'})
})

zones.nalchik:addGroups({
	GroupCommander:new({name='nalchik-supply-mozdok', mission='supply', template='HeloSupplyTemplate', targetzone='Mozdok'}),
	GroupCommander:new({name='Nalchik-Attack-Kutaisi-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Kutaisi', Altitude = CapAltitude()}),
	GroupCommander:new({name='Nalshik-attack-minieralnye-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mineralnye', Altitude = CapAltitude()}),
	GroupCommander:new({name='Nalchik-supply-Beslan', mission='supply', template='HeloSupplyTemplate', targetzone='Beslan'}),
	GroupCommander:new({name='nalchik-supply-Mineralnye', mission='supply', template='HeloSupplyTemplate', targetzone='Mineralnye'}),
	GroupCommander:new({name='Nalchik-attack-Mineralnye-Arty', mission='attack', targetzone='Mineralnye', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='Nalchik-attack-Mozdok-Arty', mission='attack', targetzone='Mozdok', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='Nalchik-attack-Beslan-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Beslan', type='surface', SetActiveMission = true}),

})
zones.beslan:addGroups({
	GroupCommander:new({name='Beslan-patrol-beslan', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Beslan', Altitude = CapAltitude()}),
	GroupCommander:new({name='Beslan-attack-mozdok', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Mozdok', Altitude = CasAltitude()}),
	GroupCommander:new({name='Beslan-attack-Mineralnye', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mineralnye', Altitude = CapAltitude()}),
	GroupCommander:new({name='Beslan-attack-Nalchik', mission='attack', template='CapPlaneTemplate', MissionType='CAS', targetzone='Nalchik', Altitude = CasAltitude()}),
	GroupCommander:new({name='Beslan-supply-juliett', mission='supply', template='HeloSupplyTemplate', targetzone='Juliett'}),
	GroupCommander:new({name='Beslan-supply-Mozdok', mission='supply', template='HeloSupplyTemplate', targetzone='Mozdok'}),
	GroupCommander:new({name='Beslan-attack-Tbilisi', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tbilisi', Altitude = CapAltitude()}),
	GroupCommander:new({name='Beslan-patrol-Kilo', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Kilo', Altitude = CapAltitude()}),
	GroupCommander:new({name='Beslan-patrol-Juliett', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Juliett', Altitude = CapAltitude()}),

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
	GroupCommander:new({name='Mineralnye-supply-Nalchik', mission='supply', template='HeloSupplyTemplate', targetzone='Nalchik', Redcondition = function() return end}),
	GroupCommander:new({name='Mineralnye-supply-India', mission='supply', template='HeloSupplyTemplate', targetzone='India'}),
	GroupCommander:new({name='Mineralnye-supply-Mozdok', mission='supply', template='PlaneSupplyTemplate', targetzone='Mozdok', Redcondition = function() return end}),
	GroupCommander:new({name='Mineralnye-supply-Maykop', mission='supply', template='PlaneSupplyTemplate', targetzone='Maykop'}),
	GroupCommander:new({name='Mineralnye-supply-Mozdok', mission='supply',template='PlaneSupplyTemplate', targetzone='Mozdok'}),
	GroupCommander:new({name='Mineralnye-supply-Nalchik', mission='supply',template='PlaneSupplyTemplate', targetzone='Nalchik'}),
})
zones.tbilisi:addGroups({
	GroupCommander:new({name='tbilisi-supply-Soganlug', mission='supply', template='HeloSupplyTemplate', targetzone='Soganlug', Redcondition = function() return not CustomFlags["StrikeVaziani"] end}),
	GroupCommander:new({name='tbilisi-supply-Vaziani', mission='supply', template='HeloSupplyTemplate', targetzone='Vaziani', Redcondition = function() return not CustomFlags["StrikeVaziani"] end}),
	GroupCommander:new({name='Tbilisi-Patrol-Nalchik', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Nalchik', Altitude = CapAltitude()}),
	GroupCommander:new({name='Tbilisi-supply-Kutaisi', mission='supply',template='PlaneSupplyTemplate', targetzone='Kutaisi', Altitude = CapAltitude()}),

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

	if zones.redcarrier.wasBlue then
		trigger.action.setMarkupTypeLine(zones.bluecarrier.index, 0)
	end
	if not CustomFlags[1] then
		zones.hidden1:MakeRedZoneUpgraded()
		CustomFlags[1] = true
	end

	if zones.hidden4.side == 1 and zones.hidden4.active then
		if zones.batumi.side == 2 and zones.alpha.side == 2 then
			zones.hidden4:DestroyHiddenZone()
		end
	elseif zones.hidden4.side == 0 and (
	(zones.batumi.side == 2 and zones.alpha.side ~= 2) or
	(zones.batumi.side ~= 2 and zones.alpha.side == 2) ) then
		zones.hidden4:MakeZoneRedAndUpgrade()
	end

	if zones.hidden5.side == 1 and zones.hidden5.active then
		if zones.sochi.side == 2 and zones.alpha.side == 2 then
			zones.hidden5:DestroyHiddenZone()
		end
	elseif zones.hidden5.side == 0 and (
	(zones.sochi.side == 2 and zones.alpha.side ~= 2) or
	(zones.sochi.side ~= 2 and zones.alpha.side == 2) ) then
		zones.hidden5:MakeZoneRedAndUpgrade()
	end
	if zones.hidden6.side == 1 and zones.hidden6.active then
		if zones.novorossiysk.side == 2 and zones.krasnodarp.side == 2 then
			zones.hidden6:DestroyHiddenZone()
		end
	elseif zones.hidden6.side == 0 and (
	(zones.novorossiysk.side == 2 and zones.krasnodarp.side ~= 2) or
	(zones.novorossiysk.side ~= 2 and zones.krasnodarp.side == 2) ) then
		zones.hidden6:MakeZoneRedAndUpgrade()
	end
	if zones.hidden7.side == 1 and zones.hidden7.active then
		if zones.krasnodarp.side == 2 and zones.india.side == 2 then
			zones.hidden7:DestroyHiddenZone()
		end
	elseif zones.hidden7.side == 0 and (
	(zones.krasnodarp.side == 2 and zones.india.side ~= 2) or
	(zones.krasnodarp.side ~= 2 and zones.india.side == 2) ) then
		zones.hidden7:MakeZoneRedAndUpgrade()
	end
	if not zones.insurgencygriddl22.isAwaken and zones.krymsk.side == 2 and not insurgencydl22campStarted then
		insurgencydl22campStarted = true
		timer.scheduleFunction(function()
		zones.insurgencygriddl22:AwakenZoneAndUpgrade()
		trigger.action.outTextForCoalition(2, L10N:Get("CA_SETUP_INSURGENTS_DL22_INTEL"), 30)
		trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
		bc:addConnection("Krymsk", "Insurgency Grid DL22")
		bc:buildConnectionMap()
		bc:RefreshConnectionsLines("Krymsk")
		end, {}, timer.getTime() + math.random(5,30))
	end
	if not zones.insurgencygridmn47.isAwaken and zones.beslan.side == 2 and not insurgencymn47campStarted then
		insurgencymn47campStarted = true
		timer.scheduleFunction(function()
		zones.insurgencygridmn47:AwakenZoneAndUpgrade()
		trigger.action.outTextForCoalition(2, L10N:Get("CA_SETUP_INSURGENTS_MN47_INTEL"), 30)
		trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
		bc:addConnection("Beslan", "Insurgency Grid MN47")
		bc:buildConnectionMap()
		bc:RefreshConnectionsLines("Beslan")
		end, {}, timer.getTime() + math.random(5,30))
	end
	if not zones.insurgencygridfj98.isAwaken and zones.hotel.side == 2 and not insurgencyfj98campStarted then
		insurgencyfj98campStarted = true
		timer.scheduleFunction(function()
		zones.insurgencygridfj98:AwakenZoneAndUpgrade()
		trigger.action.outTextForCoalition(2, L10N:Get("CA_SETUP_INSURGENTS_FJ98_INTEL"), 30)
		trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
		bc:addConnection("Hotel", "Insurgency Grid FJ98")
		bc:buildConnectionMap()
		bc:RefreshConnectionsLines("Hotel")
		end, {}, timer.getTime() + math.random(5,30))
	end
	if not zones.insurgencygridel70.isAwaken and zones.maykop.side == 2 and not insurgencyel70campStarted and not zones.samindia.active then
		insurgencyel70campStarted = true
		timer.scheduleFunction(function()
		zones.insurgencygridel70:AwakenZoneAndUpgrade()
		trigger.action.outTextForCoalition(2, L10N:Get("CA_SETUP_INSURGENTS_EL70_INTEL"), 30)
		trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
		bc:addConnection("Maykop", "Insurgency Grid EL70")
		bc:buildConnectionMap()
		bc:RefreshConnectionsLines("Maykop")
		end, {}, timer.getTime() + math.random(5,30))
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
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Sochi"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Sochi"),
        TargetZone = "Bravo",
        radius = 2500,
        MissionType = "Escort",
        flag = 001,
		ActivateZone = "hidden"
    },
        ["Bravo"] = {	
        zone = "Bravo",
        missionGroup = "BravoEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Bravo"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Bravo"),
        TargetZone = "Charlie",
        radius = 2500,
        MissionType = "Escort",
        flag = 101,
		ActivateZone = "hidden2"
    },
        ["Charlie"] = {	
        zone = "Charlie",
        missionGroup = "CharlieEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Charlie"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Charlie"),
        TargetZone = "Delta",
        radius = 2500,
        MissionType = "Escort",
        flag = 111,
		ActivateZone = "hidden3"
    },
        ["Delta"] = {	
        zone = "Delta",
        missionGroup = "DeltaEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Delta"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Delta"),
        TargetZone = "Gelendzhik",
        radius = 2500,
        MissionType = "Escort",
        flag = 111,
		ActivateZone = "hidden8"
    },
}

bc:addConnection("Blue Carrier", "Batumi")
bc:addConnection("Batumi","Kobuleti")
bc:addConnection("Kobuleti","SAM-Alpha")
bc:addConnection("Kobuleti","Senaki")

bc:addConnection("Senaki","Kutaisi")
bc:addConnection("Kutaisi","Alpha")
bc:addConnection("Alpha","Sukhumi")
bc:addConnection("Alpha","InsurgentCamp",nil,true)
bc:addConnection("Sukhumi","SAM-Delta",nil,true)
bc:addConnection("Sukhumi","SecretTechFacility",nil,true)
bc:addConnection("Sukhumi","Gudauta")
bc:addConnection("Sochi","Gudauta")
bc:addConnection("Sochi","Bravo")
bc:addConnection("Sochi","Red Carrier")
bc:addConnection("Sochi","AmmonitionDepo",nil,true)
bc:addConnection("Bravo","Charlie")
bc:addConnection("Charlie","Delta")
bc:addConnection("Delta","Gelendzhik")

bc:addConnection("Gelendzhik","Novorossiysk")
bc:addConnection("Novorossiysk","Anapa")
bc:addConnection("Anapa","SAM-Golf",nil,true)
bc:addConnection("Anapa","Krymsk")
bc:addConnection("Krymsk","Echo")
bc:addConnection("Echo","Krasnodar-Center")
bc:addConnection("Krasnodar-Center","SAM-Hotel",nil,true)
bc:addConnection("Krasnodar-Center","Krasnodar-Pashkovsky")
bc:addConnection("Krasnodar-Pashkovsky","TankFactory",nil, true)
bc:addConnection("Krasnodar-Pashkovsky","Foxtrot")
bc:addConnection("Krasnodar-Pashkovsky","Maykop")
bc:addConnection("Foxtrot","Maykop")
bc:addConnection("Maykop","Golf")
bc:addConnection("Maykop","SAMSite")
--bc:addConnection("SAMSite","Maykop")
bc:addConnection("Maykop","SAM-India",nil,true)
bc:addConnection("Golf","Hotel")
bc:addConnection("Hotel","India")
bc:addConnection("India","Mineralnye")
bc:addConnection("Mineralnye","Nalchik")
bc:addConnection("Mineralnye","Mozdok")
bc:addConnection("Mineralnye","SAM-Juliett",nil,true)
bc:addConnection("Mozdok","Nalchik")
bc:addConnection("Mozdok","Beslan")
bc:addConnection("Nalchik","ChemSite",nil,true)
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

bc:addConnection("Mineralnye", "SAMSite")

bc:addConnection("Senaki","SAM-Bravo",nil,true)
bc:addConnection("Kutaisi","SAM-Charlie")

bc:addConnection("Sochi","SAM-Echo",nil,true)

bc:addConnection("Mozdok","SAM-Kilo",nil,true)

bc:addHiddenConnection("Nalchik","Beslan")
bc:addHiddenConnection("Mineralnye","Maykop")


bc:addHiddenConnection("Sochi","Maykop")
bc:addHiddenConnection("Sochi","Anapa")

local kutaisiSuffix   = (StartNormal == false) and '-OtherWay' or ''
local kutaisiSeadBase = (Era == 'Coldwar') and 'Kutaisi-Sead-Attack-Coldwar' or 'Kutaisi-Sead-Attack'
local kutaisiSeadGrp  = kutaisiSeadBase .. kutaisiSuffix
local kutaisiBombGrp  = 'Kutaisi-bomb-Attack' .. kutaisiSuffix

Group.getByName('Kutaisi-Sead-Attack'):destroy()
Group.getByName('Kutaisi-Sead-Attack-Coldwar'):destroy()
Group.getByName('Kutaisi-Sead-Attack-OtherWay'):destroy()
Group.getByName('Kutaisi-Sead-Attack-Coldwar-OtherWay'):destroy()
Group.getByName('Kutaisi-bomb-Attack'):destroy()
Group.getByName('Kutaisi-bomb-Attack-OtherWay'):destroy()

zones.kutaisi:registerTrigger('captured', function(_, zone)
    if zone ~= zones.kutaisi then return end
    local kr = bc:getZoneByName('Kutaisi')
    if kr.side == 2 and not CustomFlags['kutaisicaptured'] then
        if not IsGroupActive(kutaisiSeadGrp) then
			Respawn.Group(kutaisiBombGrp)
			Respawn.Group(kutaisiSeadGrp)
            CustomFlags['kutaisicaptured'] = true
            timer.scheduleFunction(function()
                trigger.action.outTextForCoalition(2, L10N:Get("CA_EVENT_KUTAISI_ASSAULT"), 30)
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
            trigger.action.outTextForCoalition(2, L10N:Get("CA_EVENT_SOCHI_ARTY_ATTACK"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 180)
		end
	
    timer.scheduleFunction(function()
    trigger.action.outTextForCoalition(2, L10N:Get("CA_EVENT_SOCHI_ARTY_INTEL"), 30)
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
            trigger.action.outTextForCoalition(2, L10N:Get("CA_EVENT_ANAPA_SCUDS"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 60)
		end
	end
end, 'anapacaptured')

zones.samalpha:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesamalpha')


zones.sambravo:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesambravo')

zones.samcharlie:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesamcharlie')

zones.samdelta:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesamdelta')

zones.samecho:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesamecho')

zones.samfoxtrot:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesamfoxtrot')

zones.samgolf:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesamgolf')

zones.samhotel:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesamhotel')

zones.samindia:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesamindia')

zones.samjuliett:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesamjuliett')

zones.samkilo:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesamkilo')

zones.samlima:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesamlima')

zones.sammike:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 200),20)
end, 'disablesammike')

zones.samsite:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_ENEMY_SAM_DESTROYED", 500),20)
end, 'disablesamsite')

zones.miningfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("CA_SETUP_MINING_FACILITY_DESTROYED"),20)
end, 'disableminingfacility')

zones.insurgentcamp:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("CA_SETUP_INSURGENT_CAMP_DESTROYED"),20)
end, 'disableinsurgentcamp')

zones.ammonitiondepo:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("CA_SETUP_AMMUNITION_DEPO_DESTROYED"),20)
end, 'disableammonitiondepo')

zones.artilleryfactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("CA_SETUP_ARTILLERY_FACTORY_DESTROYED"),20)
end, 'disableartilleryfactory')


zones.chemsite:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("CA_SETUP_CHEMSITE_DESTROYED"),20)
end, 'disablechemsite')

zones.fueldepo:registerTrigger('lost', function(event, sender) 
	bc:addFunds(2,500)
	sender:disableZone(true)
	trigger.action.outTextForCoalition(2,L10N:Get("CA_SETUP_FUELDEPO_DISABLED"),20)
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

zones.insurgencygriddl22:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_INSURGENCY_GRID_DESTROYED", "DL22"),20)
end, 'disableinsurgencygriddl22')

zones.insurgencygridmn47:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_INSURGENCY_GRID_DESTROYED", "MN47"),20)
end, 'disableinsurgencygridmn47')

zones.insurgencygridfj98:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_INSURGENCY_GRID_DESTROYED", "FJ98"),20)
end, 'disableinsurgencygridfj98')
zones.insurgencygridel70:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("CA_SETUP_INSURGENCY_GRID_DESTROYED", "EL70"),20)
end, 'disableinsurgencygridel70')


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

		timer.scheduleFunction(function()
			trigger.action.outSoundForCoalition(2, "BH.ogg")
		end, {}, timer.getTime() + 2)
		if AutoRestart then
			trigger.action.outText(L10N:Get("MISSION_COMPLETE_AUTORESTART"), 120)
			Utils.saveTable(bc.saveFile, 'zonePersistance', {})
			if resetSaveFileAndFarp then
			resetSaveFileAndFarp()
			end
			timer.scheduleFunction(function()
				trigger.action.setUserFlag(181, true)
			end, {}, timer.getTime() + 5)
		else
				trigger.action.outText(L10N:Get("MISSION_COMPLETE_MANUAL_RESTART"), 120)
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
end


for i,v in ipairs(bc:getZones()) do
	v:registerTrigger('lost', checkMissionComplete, 'missioncompleted')
end

timer.scheduleFunction(function()
	checkMissionComplete(nil, nil)

if Era == 'Coldwar' then
    bc:roamGroupsToLocalSubZone({
		"Red SAM AAA 2 #",
		"Red Armour Group #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-19 #",
		"Red SAM SHORAD SA-8 #",
		'Red Armor Group8 #',
		'Red Armor Group9 #',
		'Red Armor Group6 #',
		'Red Armor Group7 #',
	}, 50, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
else
	bc:roamGroupsToLocalSubZone({
		"Red Armour Group 4 #",
		"Red Armour Group 2 #",
		"Red SAM AAA 2 #",
		"Red Armour Group 3 #",
		"Red Armour Group #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-19 #",
		"Red SAM SHORAD SA-8 #",
	}, 50, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
end
end, {}, timer.getTime() + 30)


-----------------------------------------------DYNAMIC SHOP ------------------------------------------

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
        return function(T)
			local Tr = LT(T)
			return Tr:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", Tr:Get("SYRIA_SHOP_LABEL_DECOY"))
		end
    end
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if decoyActive then
            return function(T)
				local Tr = LT(T)
				return Tr:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", Tr:Get("SYRIA_SHOP_LABEL_DECOY"))
			end
        end
        local minNM = 40
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return function(T)
				local Tr = LT(T)
				return Tr:Format("SYRIA_SHOP_NO_FRIENDLY_SPAWN", Tr:Get("SYRIA_SHOP_LABEL_DECOY"))
			end
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
        return function(T)
			local Tr = LT(T)
			return Tr:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", Tr:Get("SYRIA_SHOP_LABEL_BOMB"))
		end
    end
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if bomberActive then
            return function(T)
				local Tr = LT(T)
				return Tr:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", Tr:Get("SYRIA_SHOP_LABEL_BOMB_RUN"))
			end
        end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return function(T)
				local Tr = LT(T)
				return Tr:Format("SYRIA_SHOP_NO_FRIENDLY_SPAWN", Tr:Get("SYRIA_SHOP_LABEL_BOMB_RUN_LOWER"))
			end
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
        return function(T)
			local Tr = LT(T)
			return Tr:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", Tr:Get("CA_SHOP_LABEL_BUILDING_STRIKE"))
		end
    end
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and params.zone.newStatics and next(params.zone.newStatics) then
        if StructureActive then
            return function(T)
				local Tr = LT(T)
				return Tr:Format("SYRIA_SHOP_MISSION_STILL_PROGRESS", Tr:Get("CA_SHOP_LABEL_BUILDING_STRIKE"))
			end
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
				local T = L10N:ForGroup(groupId)
                local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
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
            if zone and zone.side ~= 1 or not zone.active then
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
bc:registerShopItem('groundattack', LTGet("SYRIA_SHOP_ITEM_GROUND_ATTACK"), ShopPrices.groundattack, function(sender)
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
			local T = L10N:ForGroup(groupId)
			local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
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
			local T = L10N:ForGroup(groupId)
			local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
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
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('blueInfantry') -- checked
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
local samLabel = function(T)
	return (Era == 'Coldwar') and LT(T):Get("SYRIA_SHOP_ITEM_UPGRADE_HAWK")
	                           or  LT(T):Get("SYRIA_SHOP_ITEM_UPGRADE_NASAMS")
end
local samMenu=nil
bc:registerShopItem('zsam',samLabel,ShopPrices.zsam,function(sender)
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
		params.zone:addExtraSlot((Era == 'Coldwar') and 'blueHAWK-Coldwar' or 'bluePD1') --checked
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
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SYRIA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		local slotID = (Era == 'Coldwar') and 'blueArmor-Coldwar' or 'blueArmor' -- checked
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
}



-- first value below is how much in stock, the second number value is the ranking in the shop menu list, the third is the new ranking system.

bc:addShopItem(1, 'redzoneupgrade', -1, 1) -- red AI zone upgrade
bc:addShopItem(1, 'redmassattack', -1, 2) -- red AI mass airbase attack

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
bc:addShopItem(2, 'groundattack', -1, 7, ShopRankRequirements.groundattack, ShopCats.AIAttack) -- Ground attack convoy

if UseStatics == true then
    bc:addShopItem(2, 'dynamicstatic', -1, 6, ShopRankRequirements.dynamicstatic, ShopCats.AIAttack) -- Static structure Flight
end
if StartNormal or not CustomFlags['StartNormalFalse'] then 
bc:addShopItem(2, 'cruisemsl', 12, 7, ShopRankRequirements.cruisemsl, ShopCats.AIAttack) -- Cruise missiles
end

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
supplyZones = {
	--'Blue Carrier',
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
        if zones.bluecarrier.active then
            zones.soganlug.LogisticCenter = true
            zones.vaziani.LogisticCenter = true
            zones.tbilisi.LogisticCenter = true
        end
		DestroyOnce = true
    else
        zones.batumi.LogisticCenter = true
        bc:addConnection("Kutaisi","FuelDepo")
		bc:addConnection("Gelendzhik","SAM-Foxtrot")
    end
else
    applyRandomUpgradesForNewZonesOnly()
    if StartNormal then
        bc:addConnection("Kutaisi","FuelDepo")
		bc:addConnection("Gelendzhik","SAM-Foxtrot")
    end
end

if zones.insurgencygriddl22.side == 1 then
bc:addConnection("Krymsk", "Insurgency Grid DL22")
end
if zones.insurgencygridmn47.side == 1 then
bc:addConnection("Beslan", "Insurgency Grid MN47")
end
if zones.insurgencygridfj98.side == 1 then
bc:addConnection("Hotel", "Insurgency Grid FJ98")
end
if zones.insurgencygridel70.side == 1 then
bc:addConnection("Maykop", "Insurgency Grid EL70")
end
bc:init()

if disableBlueCarrierAfterInit then
	bc:addConnection("Novorossiysk","SAM-Foxtrot")
	bc:addHiddenConnection("Soganlug", "Kutaisi")
	bc:addConnection("Soganlug", "FuelDepo")
	bc:RefreshConnectionsLines("FuelDepo")
	bc:RefreshConnectionsLines("Kutaisi")
	destroyGroupIfActive('CVN-74')
	destroyGroupIfActive('CVN-72')	
	destroyGroupIfActive('Tarawa')
end
if DestroyOnce then
	zones.bluecarrier:disableZone(true)
	zones.samlima:disableZone(true)
	zones.sammike:disableZone(true)
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
local HuntNumber = SplashDamage and math.random(8,15) or math.random(6,15)
bc:initHunter(HuntNumber)
SCHEDULER:New(nil, function() bc:_buildHunterBaseList() end, {}, 1)

SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 10)
SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 10)

AWACS_CFG = {
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=150 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=70 }   -- blue
}


GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 95   		-- suspend red zones deeper than this nm


evc = EventCommander:new({ decissionFrequency=15*60, decissionVariance=10*60, skipChance = 15})
evc:init()
mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})

DynamicHybridConfig = DynamicHybridConfig or {
	enabled = true,
	runOnce = true,
	airMaxNm = 150,
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
----------------------------------------- Destroy SCUDS ---------------------------------------
local Scuds_COOLDOWN = 2700
local lastScuds_COOLDOWN  = -Scuds_COOLDOWN
Group.getByName('Maykop-Scuds'):destroy()
evc:addEvent({
	id='scuds',
	action = function()
	RespawnGroup('Maykop-Scuds')
		RegisterGroupTarget('Maykop-Scuds',100,L10N:Get("SYRIA_MISSION_TARGET_DESTROY_SCUDS"),'scuds')
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
				trigger.action.outTextForCoalition(2, L10N:Format("CA_EVENT_SCUDS_MAYKOP_LAUNCHING", choice), 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
		if ActiveMission['scuds'] then return false end
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
	title = LTGet("CA_MISSION_SCUDS_21_TITLE"),
	description = LTGet("CA_MISSION_SCUDS_MAYKOP_DESC"),
	messageStart = L10N:Get("CA_MISSION_SCUDS_MAYKOP_START"),
	messageEnd=function() lastScuds_COOLDOWN=timer.getTime() return L10N:Get("SYRIA_MISSION_SCUDS_END") end,
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
		if not ActiveMission['scuds'] then return false end
		if Group.getByName('Maykop-Scuds') then return true end
		ActiveMission['scuds'] = nil
		return false
	end
})
------------------------------------- End of Destroy SCUDS ----------------------------------------
---------------------------------------- Intercept Cargo Plane ---------------------------------------
local Cargo_COOLDOWN = 2700
local lastCargo_COOLDOWN   = -Cargo_COOLDOWN
local cargoInterceptSuffix = (StartNormal == false) and '-OtherWay' or ''
Group.getByName('evt-cargointercept1'):destroy()
Group.getByName('evt-cargointercept2'):destroy()
Group.getByName('evt-cargointercept3'):destroy()
Group.getByName('evt-cargointercept4'):destroy()
Group.getByName('evt-cargointercept1-OtherWay'):destroy()
Group.getByName('evt-cargointercept2-OtherWay'):destroy()
Group.getByName('evt-cargointercept3-OtherWay'):destroy()
Group.getByName('evt-cargointercept4-OtherWay'):destroy()
evc:addEvent({
	id='cargointercept',
	action=function()
		local planes
		if bc:getZoneByName('Maykop').side==1 and not bc:getZoneByName('Maykop').suspended then
			planes={'evt-cargointercept1' .. cargoInterceptSuffix}
		elseif bc:getZoneByName('Sochi').side==1 and not bc:getZoneByName('Sochi').suspended then
			planes={'evt-cargointercept2' .. cargoInterceptSuffix}
		elseif bc:getZoneByName('Anapa').side==1 and not bc:getZoneByName('Anapa').suspended then
			planes={'evt-cargointercept3' .. cargoInterceptSuffix}
		elseif bc:getZoneByName('Mineralnye').side==1 and not bc:getZoneByName('Mineralnye').suspended then
			planes={'evt-cargointercept4' .. cargoInterceptSuffix}
		else
			return
		end
		RespawnGroup(planes[1])
		RegisterGroupTarget(planes[1],500,L10N:Get("SYRIA_MISSION_INTERCEPT_CARGO_TITLE"),'cargointercept')

	end,
	canExecute=function()
		if ActiveMission['cargointercept'] then return false end
		if timer.getTime() - lastCargo_COOLDOWN < Cargo_COOLDOWN then return false end
		if math.random(1,100)<70 then return false end
		if bc:getZoneByName('Maykop').wasBlue and bc:getZoneByName('Sochi').wasBlue and bc:getZoneByName('Anapa').wasBlue and bc:getZoneByName('Mineralnye').wasBlue then return false end
		return true
	end
})
mc:trackMission({
    title = LTGet("SYRIA_MISSION_INTERCEPT_CARGO_TITLE"),
    description = LTGet("CA_MISSION_INTERCEPT_CARGO_DESC"),
    messageStart = L10N:Get("SYRIA_MISSION_INTERCEPT_CARGO_START"),
    messageEnd =function() lastCargo_COOLDOWN=timer.getTime() return L10N:Get("SYRIA_MISSION_INTERCEPT_CARGO_END") end,
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
		if not ActiveMission['cargointercept'] then return false end
        if Group.getByName('evt-cargointercept1') then return true end
        if Group.getByName('evt-cargointercept2') then return true end
        if Group.getByName('evt-cargointercept3') then return true end
        if Group.getByName('evt-cargointercept4') then return true end
        if Group.getByName('evt-cargointercept1-OtherWay') then return true end
        if Group.getByName('evt-cargointercept2-OtherWay') then return true end
        if Group.getByName('evt-cargointercept3-OtherWay') then return true end
        if Group.getByName('evt-cargointercept4-OtherWay') then return true end
		ActiveMission['cargointercept'] = nil
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
		RegisterGroupTarget(ships[choice],500,L10N:Get("SYRIA_MISSION_TARGET_DESTROY_CARGO_SHIP"),'shiptercept')
	end,
	canExecute=function()
		if ActiveMission['shiptercept'] then return false end
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
    title = LTGet("CA_MISSION_DESTROY_BATTLE_SHIPS_TITLE"),
    description = LTGet("CA_MISSION_DESTROY_BATTLE_SHIPS_DESC"),
    messageStart = L10N:Get("CA_MISSION_DESTROY_BATTLE_SHIPS_START"),
	messageEnd =function() lastShip_COOLDOWN=timer.getTime() return L10N:Get("CA_MISSION_DESTROY_BATTLE_SHIPS_END") end,
    startAction = function()
        if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
    isActive = function()
		if not ActiveMission['shiptercept'] then return false end
		if Group.getByName('evt-shiptercept1') then return true end
		if Group.getByName('evt-shiptercept2') then return true end
		if Group.getByName('evt-shiptercept3') then return true end
		ActiveMission['shiptercept'] = nil
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
		RegisterGroupTarget('evt-bomb',500,L10N:Get("SYRIA_MISSION_TARGET_INTERCEPT_BOMBERS"),'bomb')
		timer.scheduleFunction(function()
			RespawnGroup(escGrp)
			local tgts = {'Kutaisi','Sochi','Senaki','Batumi','Kobuleti',
				'Sukhumi','Gudauta','Gelendzhik','Novorossiysk','Krymsk',
				'Krasnodar-Center','Krasnodar-Pashkovsky','Maykop','Mineralnye',
				'Mozdok'}
					if Group.getByName('evt-bomb') then
						local bomber, bomberMission = StartBomberAuftrag('bomb', 'evt-bomb', tgts, escGrp)
				end
		end,{},timer.getTime()+1)
	end,
	canExecute = function()
		if ActiveMission['bomb'] then return false end
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
mc:trackMission({
	title = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_TITLE"),
	description = LTGet("CA_MISSION_INTERCEPT_BOMBERS_MINERALNYE_DESC"),
	messageStart = L10N:Get("SYRIA_MISSION_INTERCEPT_BOMBERS_START"),
	messageEnd = function() lastbomb_COOLDOWN=timer.getTime() return L10N:Get("SYRIA_MISSION_INTERCEPT_BOMBERS_END") end,
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
		RegisterGroupTarget(attackGrp,250,L10N:Get("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),'cas')
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
		if ActiveMission['cas'] then return false end
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
	title = LTGet("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),
	description = LTGet("CA_MISSION_INTERCEPT_AIRSTRIKE_WEST_EAST_DESC"),
	messageStart = L10N:Get("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_START"),
	messageEnd =function() lastairstrike_COOLDOWN=timer.getTime() return L10N:Get("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_END") end,
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
		if Group.getByName('evt-attackcw') then return true end
		ActiveMission['cas'] = nil
		return false
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
						trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_EVENT_INTERCEPTOR_SPOTTED"),15)
					else
						trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_EVENT_INTERCEPT_MISSION"),15)
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
    title = LTGet("SYRIA_MISSION_ESCORT_CARGO_TITLE"),
    description = LTGet("CA_MISSION_ESCORT_CARGO_KUTAISI_DESC"),
    messageStart = L10N:Get("SYRIA_MISSION_ESCORT_CARGO_START"),
    messageEnd = function() lastEscortCooldown = timer.getTime() return L10N:Get("SYRIA_MISSION_ESCORT_CARGO_END") end,
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
		local wp = WaypointList[attackTarget1] or ""
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
		local wp = WaypointList[attackTarget2] or ""
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
--------------------- Artillery STRIKE MISSION ----------------------
mc:trackMission({
    title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
    description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Krymsk", "Echo"),
    messageStart = L10N:Get("SYRIA_MISSION_ARTY_START"),
    messageEnd = L10N:Get("SYRIA_MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Echo-attack-Krymsk-Arty',250,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'Echo-attack-Krymsk-Arty')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Echo-attack-Krymsk-Arty'] then return false end
        if Group.getByName('Echo-attack-Krymsk-Arty') then return true end
        ActiveMission['Echo-attack-Krymsk-Arty'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
    description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Anapa", "Krymsk"),
    messageStart = L10N:Get("SYRIA_MISSION_ARTY_START"),
    messageEnd = L10N:Get("SYRIA_MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Krymsk-Attack-Anapa-Arty',250,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'Krymsk-Attack-Anapa-Arty')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Krymsk-Attack-Anapa-Arty'] then return false end
        if Group.getByName('Krymsk-Attack-Anapa-Arty') then return true end
        ActiveMission['Krymsk-Attack-Anapa-Arty'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
    description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Gelendzhik", "Novorossiysk"),
    messageStart = L10N:Get("SYRIA_MISSION_ARTY_START"),
    messageEnd = L10N:Get("SYRIA_MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Novorossiysk-attack-Gelendzhik-Arty',250,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'Novorossiysk-attack-Gelendzhik-Arty')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Novorossiysk-attack-Gelendzhik-Arty'] then return false end
        if Group.getByName('Novorossiysk-attack-Gelendzhik-Arty') then return true end
        ActiveMission['Novorossiysk-attack-Gelendzhik-Arty'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
    description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Sukhumi", "Gudauta"),
    messageStart = L10N:Get("SYRIA_MISSION_ARTY_START"),
    messageEnd = L10N:Get("SYRIA_MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Gudauta-attack-Sukhumi-Arty',250,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'Gudauta-attack-Sukhumi-Arty')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Gudauta-attack-Sukhumi-Arty'] then return false end
        if Group.getByName('Gudauta-attack-Sukhumi-Arty') then return true end
        ActiveMission['Gudauta-attack-Sukhumi-Arty'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
    description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Maykop", "Golf"),
    messageStart = L10N:Get("SYRIA_MISSION_ARTY_START"),
    messageEnd = L10N:Get("SYRIA_MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Golf-attack-Maykop-Arty',250,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'Golf-attack-Maykop-Arty')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Golf-attack-Maykop-Arty'] then return false end
        if Group.getByName('Golf-attack-Maykop-Arty') then return true end
        ActiveMission['Golf-attack-Maykop-Arty'] = nil
        return false
    end
})

--[[ mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards Senaki from the direction of Kutaisi.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery headed toward Senaki",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Kutaisi-attack-Senaki-Arty',250,'Destroy artillery','Kutaisi-attack-Senaki-Arty')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Kutaisi-attack-Senaki-Arty'] then return false end
        if Group.getByName('Kutaisi-attack-Senaki-Arty') then return true end
        ActiveMission['Kutaisi-attack-Senaki-Arty'] = nil
        return false
    end
}) ]]

mc:trackMission({
    title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
    description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Mineralnye", "Nalchik"),
    messageStart = L10N:Get("SYRIA_MISSION_ARTY_START"),
    messageEnd = L10N:Get("SYRIA_MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Nalchik-attack-Mineralnye-Arty',250,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'Nalchik-attack-Mineralnye-Arty')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Nalchik-attack-Mineralnye-Arty'] then return false end
        if Group.getByName('Nalchik-attack-Mineralnye-Arty') then return true end
        ActiveMission['Nalchik-attack-Mineralnye-Arty'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
    description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Mozdok", "Nalchik"),
    messageStart = L10N:Get("SYRIA_MISSION_ARTY_START"),
    messageEnd = L10N:Get("SYRIA_MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Nalchik-attack-Mozdok-Arty',250,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'Nalchik-attack-Mozdok-Arty')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Nalchik-attack-Mozdok-Arty'] then return false end
        if Group.getByName('Nalchik-attack-Mozdok-Arty') then return true end
        ActiveMission['Nalchik-attack-Mozdok-Arty'] = nil
        return false
    end
})

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

local sceneryList = {
  ["StrikeTarget"] = {SCENERY:FindByZoneName("StrikeTarget")},
  ["StrikeTarget1"] = {SCENERY:FindByZoneName("StrikeTarget1")},
  ["StrikeTarget2"] = {SCENERY:FindByZoneName("StrikeTarget2")},
  ["RightHandMan"] = {SCENERY:FindByZoneName("RightHandMan")},
  ["LefttHandMan"] = {SCENERY:FindByZoneName("LefttHandMan")},
  ["StrikeVaziani"] = {SCENERY:FindByZoneName("StrikeVaziani")},

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
--------------------------- Strike High value target ---------------------------
evc:addEvent({
	id = 'StrikeTarget',
	action = function()
		local tgt = sceneryList['StrikeTarget'][1] or SCENERY:FindByZoneName('StrikeTarget')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "StrikeTarget"),30)
			return
		end
		RegisterScoreTarget('StrikeTarget',tgt,1000,L10N:Get("CA_TARGET_HIGH_VALUE_TARGET"),true)
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("CA_MISSION_STRIKE_HIGH_VALUE_MARKER"),p,2,false,false)
			MissionMarks['StrikeTarget'] = missionMarkId
		end
	end,
	canExecute = function()
	if CustomFlags["StrikeTarget"] then return false end
	if ActiveMission['StrikeTarget'] then return false end
	if bc:getZoneByName('Sochi').side ~= 2 and bc:getZoneByName('Gelendzhik').side ~= 2 then return false end
	return true
	end,
})
mc:trackMission({
	title = LTGet("CA_MISSION_STRIKE_HIGH_VALUE_TITLE"),
	description = LTGet("CA_MISSION_STRIKE_HIGH_VALUE_DESC"),
	messageStart = L10N:Get("CA_MISSION_STRIKE_HIGH_VALUE_START"),
	messageEnd = L10N:Get("CA_MISSION_STRIKE_HIGH_VALUE_END"),
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
		local tgt = sceneryList['StrikeTarget1'][1] or SCENERY:FindByZoneName('StrikeTarget1')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "StrikeTarget1"),30)
			return
		end
		RegisterScoreTarget('StrikeTarget1',tgt,1000,L10N:Get("CA_TARGET_HIGH_VALUE_TARGET"),true)
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("CA_MISSION_STRIKE_ANOTHER_HIGH_VALUE_MARKER"),p,2,false,false)
			MissionMarks['StrikeTarget1'] = missionMarkId
		end
	end,
	canExecute = function()
	if CustomFlags["StrikeTarget1"] then return false end
	if ActiveMission['StrikeTarget1'] then return false end
	local zn = bc:getZoneByName('Kutaisi')
	local zn2 = bc:getZoneByName('Sochi')
	if zn.side ~= 2 and zn2.side ~= 2 then return false end
	return true
	end,
})
mc:trackMission({
	title = LTGet("CA_MISSION_STRIKE_ANOTHER_HIGH_VALUE_TITLE"),
	description = LTGet("CA_MISSION_STRIKE_ANOTHER_HIGH_VALUE_DESC"),
	messageStart = L10N:Get("CA_MISSION_STRIKE_ANOTHER_HIGH_VALUE_START"),
	messageEnd = L10N:Get("CA_MISSION_STRIKE_ANOTHER_HIGH_VALUE_END"),
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
		local groupname = (Era == 'Coldwar') and 'Red SAM SHORAD SA-8 StrikeTarget2 Fixed' or 'Red SAM SHORAD SA-15 StrikeTarget2 Fixed'

		RespawnGroup(groupname)
		RegisterGroupTarget(groupname,500,L10N:Get("CA_TARGET_HIGH_VALUE_TARGET"),'StrikeTarget2',true)
	end,
	canExecute = function()
		if CustomFlags["StrikeTarget2"] == true then return false end
		if ActiveMission['StrikeTarget2'] then return false end
		local zn = bc:getZoneByName('Senaki')
		local zn2 = bc:getZoneByName('Tbilisi')
		if zn.side ~= 2 and zn2.side ~= 2 then return false end
		return true
end
})
mc:trackMission({
	title = LTGet("CA_MISSION_STRIKE_HIGH_VALUE_TITLE"),
	description = LTGet("CA_MISSION_STRIKE_HIGH_VALUE_GROUP_DESC"),
	messageStart = L10N:Get("CA_MISSION_STRIKE_HIGH_VALUE_GROUP_START"),
	messageEnd = L10N:Get("CA_MISSION_STRIKE_HIGH_VALUE_GROUP_END"),
    startAction = function()
    end,
    endAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
	end,
	isActive = function()
		if CustomFlags["StrikeTarget2"] then return false end
		if not ActiveMission['StrikeTarget2'] then return false end
		if Era == 'Coldwar' then
			if Group.getByName('Red SAM SHORAD SA-8 StrikeTarget2 Fixed') then return true end
		else
			if Group.getByName('Red SAM SHORAD SA-15 StrikeTarget2 Fixed') then return true end
		end
		ActiveMission['StrikeTarget2'] = nil
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
		RegisterGroupTarget('RightHandMan',500,L10N:Get("CA_TARGET_HIGH_VALUE_GENERAL"),'RightHandMan',true)
    end,
    canExecute = function()
		if CustomFlags["RightHandMan"] == true then return false end
		if ActiveMission['RightHandMan'] then return false end
		local zn = bc:getZoneByName('Krymsk')
		local zn2 = bc:getZoneByName('Mineralnye')
		if zn.side ~= 2 and zn2.side ~= 2 then return false end
		if Group.getByName('RightHandMan') then return false end
        return true
    end
})

mc:trackMission({
	title = LTGet("CA_MISSION_KILL_HIGH_VALUE_GENERAL_TITLE"),
	description = LTGet("CA_MISSION_RIGHT_HAND_MAN_DESC"),

	messageStart = L10N:Get("CA_MISSION_KILL_HIGH_VALUE_GENERAL_START"),
	messageEnd = L10N:Get("CA_MISSION_KILL_HIGH_VALUE_GENERAL_END"),
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
		if not ActiveMission['RightHandMan'] then return false end
		if Group.getByName('RightHandMan') then return true end
		ActiveMission['RightHandMan'] = nil
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
		RegisterGroupTarget('LefttHandMan',500,L10N:Get("CA_TARGET_HIGH_VALUE_GENERAL"),'LefttHandMan',true)
	end,
	canExecute = function()
		if CustomFlags["LefttHandMan"] == true then return false end
		if ActiveMission['LefttHandMan'] then return false end
		local zn = bc:getZoneByName('Maykop')
		local zn2 = bc:getZoneByName('Nalchik')
		if zn.side ~= 2 and zn2.side ~= 2 then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("CA_MISSION_KILL_HIGH_VALUE_GENERAL_TITLE"),
	description = LTGet("CA_MISSION_LEFT_HAND_MAN_DESC"),

	messageStart = L10N:Get("CA_MISSION_KILL_HIGH_VALUE_GENERAL_START"),
	messageEnd = L10N:Get("CA_MISSION_KILL_HIGH_VALUE_GENERAL_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
		if CustomFlags["LefttHandMan"] then return false end
		if not ActiveMission['LefttHandMan'] then return false end
		if Group.getByName('LefttHandMan') then return true end
		ActiveMission['LefttHandMan'] = nil
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
	RegisterGroupTarget('StrikeVaziani',1000,L10N:Get("CA_TARGET_VAZIANI_SUPPLY_WAREHOUSE"),'StrikeVaziani',true)
	end,
	canExecute = function()
		if CustomFlags["StartNormalFalse"] then return false end
		if CustomFlags["StrikeVaziani"] then return false end
		if ActiveMission['StrikeVaziani'] then return false end
		if bc:getZoneByName('Lima').side ~= 2 and bc:getZoneByName('Vaziani').side ~= 1 then return false end
		return true
	end})

mc:trackMission({
	title = LTGet("CA_MISSION_STRIKE_VAZIANI_TITLE"),
	description = LTGet("CA_MISSION_STRIKE_VAZIANI_DESC"),
	messageStart = L10N:Get("CA_MISSION_STRIKE_VAZIANI_START"),
	messageEnd = L10N:Get("CA_MISSION_STRIKE_VAZIANI_END"),
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
	if bc:getZoneByName('Vaziani').side ~= 1 then ActiveMission['StrikeVaziani'] = nil return false end
	if not ActiveMission['StrikeVaziani'] then return false end
	if Group.getByName('StrikeVaziani') then return true end
	ActiveMission['StrikeVaziani'] = nil
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

buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end
----------------------- END OF FLAGS --------------------------

airbaseStatics = {
	["Alpha"] = {"Farpalphaammo", "Farpalphafuel", "Farpalphatent1", "Farpalphatent2", "Farpalphatent3", "Farpalphatent4", "Farpalphacommand", "Farpalphawind"},
    ["Bravo"] = {"Farbravoammo", "Farpbravofuel", "Farpbravotent1", "Farpbravotent2", "Farpbravotent3", "Farpbravotent4", "Farpbravocommand", "Farpbravowind"},
    ["Charlie"] = {"Farpcharliammo", "Farpcharliefuel", "Farpcharlietent1", "Farpcharlietent2", "Farpcharlietent3", "Farpcharlietent4", "Farpcharlicenter", "Farpcharliewind"},
    ["Delta"] = {"Farpdeltaammo", "Farpdeltafuel", "Farpdeltatent1", "Farpdeltatent2", "Farpdeltatent3", "Farpdeltatent4", "Farpdeltacenter", "Farpdeltawind"},
    ["Echo"] = {"Farpechoammo", "Farpechofuel", "Farpechotent1", "Farpechotent2", "Farpechotent3", "Farpechotent4", "Farpechocommand", "Farpechowind"},
    ["Foxtrot"] = {"Farpfoxtrotammo", "Farpfoxtrotfuel", "Farpfoxtrottent1", "Farpfoxtrottent2", "Farpfoxtrottent3", "Farpfoxtrottent4", "Farpfoxtrotcommand", "Farpfoxtrotwind"},
    ["Golf"] = {"Farpgolfammo", "Farpgolffuel", "Farpgolftent1", "Farpgolftent2", "Farpgolftent3", "Farpgolftent4", "Farpgolfcommand", "Farpgolfwind"},
    ["Hotel"] = {"Farphotelammo", "Farphotelfuel", "Farphoteltent1", "Farphoteltent2", "Farphoteltent3", "Farphoteltent4", "Farphotelcommand", "Farphotelwind"},
    ["India"] = {"Farpindiaammo", "Farpindiafuel", "Farpindiatent1", "Farpindiatent2", "Farpindiatent3", "Farpindiatent4", "Farpindiacommand", "Farpindiawind"},
    ["Juliett"] = {"Farpjuliettammo", "Farpjuliettfuel", "Farpjulietttent1", "Farpjulietttent2", "Farpjulietttent3", "Farpjulietttent4", "Farpjulietttent1command", "Farpjuliettwind"},
    ["Kilo"] = {"Farpkiloammo", "Farpkilofuel", "Farpkilotent1", "Farpkilotent2", "Farpkilotent3", "Farpkilotent4", "Farpkilocommand", "Farpkilowind"},
    ["Lima"] = {"Farplimaammo", "Farplimafuel", "Farplimatent1", "Farplimatent2", "Farplimatent3", "Farplimatent4", "Farplimacommand", "Farplimawind"},
	    
}

env.info("Mission Setup : is completed!")



