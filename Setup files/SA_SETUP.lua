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
local ColdWarTechEra = (Era == 'Coldwar' or Era == 'Vietnam')

BlueUpgradeTemplateMigration = {
	['bluePD'] = 'Blue SAM HAWK',
	['BluePD'] = 'Blue SAM HAWK',
	['bluePD_CW'] = 'Blue SAM HAWK',
	['bluePD Coldwar'] = 'Blue SAM HAWK',
	['bluePD Coldwar-1'] = 'Blue SAM HAWK',
	['bluePD 2'] = 'Blue SAM HAWK',
	['bluePD 2 Coldwar'] = 'Blue SAM HAWK',
	['blueHAWK'] = 'Blue SAM HAWK',
	['blueHAWK_CW'] = 'Blue SAM HAWK',
	['blueHAWK Coldwar'] = 'Blue SAM HAWK',
	['blueHAWK-Coldwar'] = 'Blue SAM HAWK',
	['bluePD1'] = ColdWarTechEra and 'Blue SAM HAWK' or 'Blue SAM NASAMS',
	['bluePATRIOT'] = 'Blue SAM PATRIOT',
	['bluePATRIOT-Coldwar'] = 'Blue SAM PATRIOT',
	['bSamIR'] = 'Blue SAM SHORAD Avenger',
	['bluePD2'] = 'Blue SAM AAA Gepard',
	['bluePD2 Coldwar'] = 'Blue SAM AAA Gepard',
	['bluePD2-Coldwar'] = 'Blue SAM AAA Gepard',
	['blueArmor'] = 'Blue Armor Modern',
	['blueArmor_Cw'] = 'Blue Armor Coldwar',
	['blueArmor_cw'] = 'Blue Armor Coldwar',
	['blueArmor_CW'] = 'Blue Armor Coldwar',
	['blueArmor-Coldwar'] = 'Blue Armor Coldwar',
	['blueArmor Coldwar'] = 'Blue Armor Coldwar',
	['blueArmor-VT'] = 'Blue Armor Vietnam',
}
if ColdWarTechEra then
	BlueUpgradeTemplateMigration['Blue SAM NASAMS'] = 'Blue SAM HAWK'
	BlueUpgradeTemplateMigration['Blue SAM AAA C-RAM'] = 'Blue SAM AAA Vulcan'
end

airbaseStatics = airbaseStatics or {}

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

-----------------------------begin upgrade (this is what determines what spawns at each target location)---------------------------
local function BuildEnabledTemplateList(masterList, ...)
	local result = {}
	local enabledMaps = {...}

	for _, template in ipairs(masterList) do
		for _, enabled in ipairs(enabledMaps) do
			if enabled[template] == true then
				table.insert(result, template)
				break
			end
		end
	end

	return result
end
upgrades = {
    redcarrier = {
        blue = {},
        red = {"Molniya", "Grisha", "Rezky", "Molniya", "SpeedBoats", "SpeedBoats", "SpeedBoats"}
    },
    redcarrier2 = {
        blue = {},
        red = {"Molniya", "Grisha", "Rezky", "Molniya", "SpeedBoats", "SpeedBoats", "SpeedBoats"}
    },	
	airfieldStart = {
		blue = {"blueArmor", "bluePD1", "bluePATRIOT"},
		red = {}
	},
    airfield = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor"},
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group", "Red Armour Group 2", "Red SAM SA-3", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15", "Red Arty 2"}
    },
    airfield2 = {
        blue = { "blueInfantry", "blueInfantry", "bluePD 2", "blueArmor"},
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group", "Red Armour Group 2", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15", "Red SAM SHORAD Tor M2"}
    },
    airfield3 = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor"},
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group", "Red Armour Group 2",  "Red SAM SA-6", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15",  "Red SAM SHORAD Pantsir S1"}
    },
    farp = {
        blue = { "blueInfantry", "blueArmor", "bSamIR"},
        red = { "Enemy ground forces", "Red SAM AAA", "Red SAM SHORAD SA-19", "Red Armour Group 2", "Red Armour Group", "Red SAM AAA 3" , "Red Arty 1"}
    },
    farp2 = {
        blue = { "blueInfantry", "blueArmor", "bSamIR"},
        red = { "Red SAM SHORAD SA-8","Red SAM AAA", "Red Armour Group", "Red SAM SHORAD SA-19", "Red Armour Group 2", "Red SAM SHORAD SA-19","Red SAM SHORAD SA-15", "Red Arty 2"}
    },
    farp3 = {
        blue = { "blueInfantry","blueInfantry", "blueArmor", "bluePD 2"},
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group","Red SAM SHORAD SA-19", "Red SAM SHORAD SA-19","Red SAM AAA 3", "Red SAM AAA 4", "Red Armour Group 2", "Red SAM SHORAD SA-15", "Red SAM SHORAD SA-15"}
    },
	HiddenSam1 = {
		blue = {},
		red = {'Red SAM SA-6', "Red SAM AAA", "Red SAM AAA",}
	},
	HiddenSam2 = {
		blue = {},
		red = {"Red SAM SHORAD SA-19", "Red SAM SHORAD SA-8",}
	},
	HiddenSam3 = {
		blue = {},
		red = {'Red SAM SA-3', 'Red SAM SHORAD SA-8', "Red SAM AAA", }
	},
	HiddenSam4 = {
		blue = {},
		red = {"Red SAM AAA", "Red SAM AAA 3", "Enemy ground forces",}
	},
	HiddenSamEWRMantisNet = {
		blue = {},
		red = {'Red EWR Ushuaia Fixed', 'Red EWR El Calafate Fixed', 'Red EWR Puenta Arenas Fixed', 'Red EWR Ohiggins Fixed', 'Red EWR Puerto Santa Cruz Fixed', 'Red EWR Island Fixed', 'Red EWR Goose Green Fixed', 'Red EWR Puenta Williams Fixed'}
	},
    convoy = {
        blue = { "blueInfantry" },
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group 2", "Red SAM SHORAD SA-19", "Red SAM SHORAD SA-19","Red Armour Group", "Red SAM SHORAD SA-8" }
    },
	samalpha = {
		blue = {},
		red = { "Red Armour Group", "Red SAM SA-6", "Red Armour Group 2", 'Red SAM SHORAD SA-19', 'Red SAM SHORAD Pantsir S1',  'Red SAM SHORAD SA-15', 'Red SAM SA-10'}
	},
	sambravo = {
		blue = {},
		red = { 'Red Armour Group', 'Red SAM SA-6', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD SA-15', 'Red SAM SA-10' }
	},
	islandsamsite = {
		blue = {},
		red = { 'Red Armour Group', 'Red SAM SA-6', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD SA-15', 'Red SAM SA-10' }
	},
    checkpoints1 = {
        blue = { "blueArmor", "bSamIR"},
        red = { "Enemy ground forces", "Red SAM AAA 4", "Red SAM SHORAD SA-19", "Red Armour Group", "Red SAM AAA 3" , "Red Arty 2"}
    },
    checkpoints2 = {
        blue = { "blueArmor", "bSamIR"},
        red = { "Enemy ground forces", "Enemy ground forces", "Red SAM SHORAD SA-13", "Red SAM AAA 3", "Red SAM AAA 4" , "Red Arty 3"}
    },
    checkpoints3 = {
        blue = { "blueArmor", "bSamIR"},
        red = { "Enemy ground forces", "Red SAM AAA", "Red SAM SHORAD SA-8", "Red SAM SHORAD SA-19", "Red SAM AAA 2", "Red Arty 1"}
    },
    checkpoints4 = {
        blue = { "blueArmor", "bSamIR"},
        red = { "Enemy ground forces", "Red SAM AAA", "Red SAM SHORAD SA-15", "Red SAM AAA 2", "Enemy ground forces"}
    },
    checkpoints5 = {
        blue = { "blueArmor", "blueInfantry"},
        red = { "Enemy ground forces", "Red SAM AAA", "Enemy ground forces", "Red SAM AAA 2" , "Red Arty 3"}
    },
    checkpoints6 = {
        blue = { "blueArmor", "blueInfantry"},
        red = { "Enemy ground forces", "Red SAM SHORAD SA-13", "Red SAM AAA 2", "Red SAM AAA" , "Red Arty 2"}
    },
}

------------------------------------end upgrades section------------------------------------------
--------------------------------begin flavor section (this is what gives a hint or description of the zone to the player)-----------------------------------
flavor = {

	portstanley = L10N:Get("SA_FLAVOR_PORT_STANLEY"),
	mountpleasant = L10N:Get("SA_FLAVOR_MOUNT_PLEASANT"),
	goosegreen = L10N:Get("SA_FLAVOR_GOOSE_GREEN"),
	sancarlosfob = L10N:Get("SA_FLAVOR_SAN_CARLOS_FOB"),
	redcarrier2 = L10N:Get("SA_FLAVOR_RED_CARRIER_SOUTH"),
	tolhuin = L10N:Get("SA_FLAVOR_TOLHUIN"),
	puertowilliams = L10N:Get("SA_FLAVOR_PUERTO_WILLIAMS"),
	ushuaia = L10N:Get("SA_FLAVOR_USHUAIA"),
	riogrande = L10N:Get("SA_FLAVOR_RIO_GRANDE"),
	pampaguanaco = L10N:Get("SA_FLAVOR_PAMPA_GUANACO"),
	almiranteschroeders = L10N:Get("SA_FLAVOR_ALMIRANTE_SCHROEDERS"),
   farpcaupolican = L10N:Get("SA_FLAVOR_FARP_CAUPOLICAN"),
	porvenir = L10N:Get("SA_FLAVOR_PORVENIR"),
	puntaarenas = L10N:Get("SA_FLAVOR_PUNTA_ARENAS"),
	francobianco = L10N:Get("SA_FLAVOR_FRANCO_BIANCO"),
	farpsayhueque = L10N:Get("SA_FLAVOR_FARP_SAYHUEQUE"),
	farplautaro = L10N:Get("SA_FLAVOR_FARP_LAUTARO"),
	riochico = L10N:Get("SA_FLAVOR_RIO_CHICO"),
	riogallegos = L10N:Get("SA_FLAVOR_RIO_GALLEGOS"),
	redcarrier = L10N:Get("SA_FLAVOR_RED_CARRIER_NORTH"),
	farpdrake = L10N:Get("SA_FLAVOR_FARP_DRAKE"),
	rioturbio = L10N:Get("SA_FLAVOR_RIO_TURBIO"),
	puertonatales = L10N:Get("SA_FLAVOR_PUERTO_NATALES"),
	farpcalfucura = L10N:Get("SA_FLAVOR_FARP_CALFUCURA"),
	elcalafate = L10N:Get("SA_FLAVOR_EL_CALAFATE"),
	farpinacayal = L10N:Get("SA_FLAVOR_FARP_INACAYAL"),
	comandanteluispiedrabuena = L10N:Get("SA_FLAVOR_COMANDANTE_LUIS_PIEDRABUENA"),
	puertosantacruz = L10N:Get("SA_FLAVOR_PUERTO_SANTA_CRUZ"),
	farpgalvarino = L10N:Get("SA_FLAVOR_FARP_GALVARINO"),
	sanjulian = L10N:Get("SA_FLAVOR_SAN_JULIAN"),
	farpmagellan = L10N:Get("SA_FLAVOR_FARP_MAGELLAN"),
	gobernadorgregores = L10N:Get("SA_FLAVOR_GOBERNADOR_GREGORES"),
	hipicoflyingclub = L10N:Get("SA_FLAVOR_HIPICO_FLYING_CLUB"),
	farpguemes = L10N:Get("SA_FLAVOR_FARP_GUEMES"),
	farproca = L10N:Get("SA_FLAVOR_FARP_ROCA"),
	ohiggins = L10N:Get("SA_FLAVOR_OHIGGINS"),
	estanciadarwin = '',
	gullpoint = '',
	islandsamsite = '',
	rebelbase = '',
	samalpha = '',
	sambravo = '',
	rebelbarracks = '',
	rebelairport = '',
	rebelcocainefarm = '',
	rebelhq = '',

	hidden1 = '',
}
-----------------------------------end flavor section------------------------------------------
--------------------------------begin waypoint list-----------------------------------
WaypointList = {
["Port Stanley"] = ' (2)',
["Mount Pleasant"] = ' (3)',
["Goose Green"] = ' (4)',
["San Carlos FOB"] = ' (5)',
["Red Carrier South"] = ' (6)',
Tolhuin = ' (7)',
["Puerto Williams"] = ' (8)',
Ushuaia = ' (9)',
["Rio Grande"] = ' (10)',
["Pampa Guanaco"] = ' (11)',
["Almirante Schroeders"] = ' (12)',
["FARP Caupolican"] = ' (13)',
Porvenir = ' (14)',
["Punta Arenas"] = ' (15)',
["Franco Bianco"] = ' (16)',
["FARP Sayhueque"] = ' (17)',
["FARP Lautaro"] = ' (18)',
["Rio Chico"] = ' (19)',
["Rio Gallegos"] = ' (20)',
["Red Carrier North"] = ' (21)',
["FARP Drake"] = ' (22)', -- FIXED
["Rio Turbio"] = ' (23)',
["Puerto Natales"] = ' (24)',
["FARP Calfucura"] = ' (25)', -- FIXED
["El Calafate"] = ' (26)',
["FARP Inacayal"] = ' (27)',
["Comandante Luis Piedrabuena"] = ' (28)',
["Puerto Santa Cruz"] = ' (29)',
["FARP Galvarino"] = ' (30)',
["San Julian"] = ' (31)',
["FARP Magellan"] = ' (32)',
["Gobernador Gregores"] = ' (33)',
["Hipico Flying Club"] = ' (34)',
["FARP Guemes"] = ' (35)',
["FARP Roca"] = ' (36)',
["O'Higgins"] = ' (37)',
}
-----------------end waypoint number section------------------------------------------

---------------------------begin coldwar swap section---------------------------------
if Era == 'Vietnam' then
	FootholdSaveBaseName = 'Foothold_SA_v0.2_Vietnam'
elseif Era == 'Coldwar' then
	FootholdSaveBaseName = 'Foothold_SA_v0.2_Coldwar'
else
	FootholdSaveBaseName = 'Foothold_SA_v0.2'
end

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
	['Blue SAM NASAMS'] = 'Blue SAM HAWK',
	['Blue SAM AAA C-RAM'] = 'Blue SAM AAA Vulcan',
	['Blue Armor Modern'] = 'Blue Armor Coldwar',
	['blueArmor']  					= 'blueArmor_cw',
	['bluePD'] 						= 'bluePD Coldwar',
	['bluePD 2'] 					= 'bluePD 2 Coldwar',
	['bluePD1'] 					= 'bluePD 2 Coldwar',
	['Red SAM SA-10 Fixed Bravo']   = 'Red SAM SHORAD SA-8 2',
	['Red SAM SA-10 Fixed Alpha']   = 'Red SAM SHORAD SA-8 2',
}
local vnSwap = {
	['Blue Armor Coldwar'] = 'Blue Armor Vietnam',
	['Enemy Task forces'] = 'Enemy task forces Vietnam',
	['Enemy ground forces'] = 'Enemy ground forces Vietnam',
	['Molniya'] = 'MissileBoat',
	['Rezky'] = 'MissileBoat',
	['Grisha'] = 'FacLa',
	['SpeedBoats'] = 'MissileBoat',
	['Red Armour Group'] = 'Red Armor Group Vietnam 1',
	['Red Armour Group 2'] = 'Red Armor Group Vietnam 2',
	['Red Armour Group 3'] = 'Red Armor Group Vietnam 3',
	['Red Armour Group 4'] = 'Red Armor Group Vietnam 4',
	['Red Armor Group'] = 'Red Armor Group Vietnam 1',
	['Red Armor Group6'] = 'Red Armor Group Vietnam 1',
	['Red Armor Group7'] = 'Red Armor Group Vietnam 3',
	['Red Armor Group8'] = 'Red Armor Group Vietnam 2',
	['Red Armor Group9'] = 'Red Armor Group Vietnam 4',
	['Red Mech group 1'] = 'Red Mech group Vietnam 1',
	['Red Mech group 2'] = 'Red Mech group Vietnam 2',
	['Red Mech group 3'] = 'Red Mech group Vietnam 3',
	['Red Mech group 4'] = 'Red Mech group Vietnam 4',
	['Red Mech group 5'] = 'Red Mech group Vietnam 1',
	['Red Mech group 6'] = 'Red Mech group Vietnam 2',
	['Red Special 1'] = 'Red Special Vietnam 1',
	['Red Special 2'] = 'Red Special Vietnam 2',
	['Red Special 3'] = 'Red Special Vietnam 1',
	['Red Arty'] = 'Red Arty Vietnam 1',
	['Red Arty 1'] = 'Red Arty Vietnam 1',
	['Red Arty 2'] = 'Red Arty Vietnam 2',
	['Red Arty 3'] = 'Red Arty Vietnam 3',
	['Red Arty 4'] = 'Red Arty Vietnam 4',
	['Red Arty 5'] = 'Red Arty Vietnam 1',
	['Red Arty 6'] = 'Red Arty Vietnam 2',
	['Red Arty 7'] = 'Red Arty Vietnam 3',
	['Red Arty 8'] = 'Red Arty Vietnam 4',
	['Red Arty 9'] = 'Red Arty Vietnam 1',
	['Red SAM AAA'] = 'Red SAM AAA Vietnam 1',
	['Red SAM AAA 2'] = 'Red SAM AAA Vietnam 1',
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
					t[k]=sub
				end
			end
		end
	end
end

------------------------begin coldwar swaps (this section swaps fixed assets for coldwar)-----------------------------
deepSwap(upgrades, BlueUpgradeTemplateMigration)
if ColdWarTechEra then
	deepSwap(upgrades,cwSwap)
end
if Era == 'Vietnam' then
	deepSwap(upgrades,vnSwap)
end

local SamSwap = {
	['Red SAM SA-10'] = 'Red SAM SA-2',
	['Red SAM SA-11'] = 'Red SAM SA-2',
}

local SamSwapNoTorM2AndPantsir = {
	['Red SAM SHORAD Tor M2']  								= { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
	['Red SAM SHORAD Pantsir S1']  							= { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
}

local SamSwapNoSA15 = {
	['Red SAM SHORAD SA-15']  							    = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
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
----------------------------end coldwar fixed swaps -----------------------------------------

----------------------end coldwar swap section-----------------------
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
	"Red SAM AAA",
	"Red SAM AAA 2",
	"Red SAM AAA 3",
	"Red SAM AAA 4",
	"Red SAM AAA 5",
	"Red SAM AAA 6",
	"Red SAM AAA 7",
	"Red SAM AAA 8",
	"Red SAM AAA 9",
	"Red SAM AAA 10",

	-- Ground
	"Enemy Task forces",
	"Enemy ground forces",
	-- Armor
	"Red Armour Group",
	"Red Armour Group 2",
	"Red Armour Group 3",
	"Red Armour Group 4",

	-- Mech
	"Red Mech group 1",
	"Red Mech group 2",
	"Red Mech group 3",
	"Red Mech group 4",
	"Red Mech group 5",
	"Red Mech group 6",

	-- Special
	"Red Special 1",
	"Red Special 2",
	"Red Special 3",

	-- Arty
	"Red Arty",
	"Red Arty 1",
	"Red Arty 2",
	"Red Arty 3",
	"Red Arty 4",
	"Red Arty 5",
	"Red Arty 6",
	"Red Arty 7",
	"Red Arty 8",

}


RandomBluePool = {
	"blueInfantry",
	"Blue Armor Modern",
	"Blue SAM SHORAD Avenger",
	"Blue SAM HAWK",
	"Blue SAM NASAMS",
	"Blue SAM SHORAD Roland",
	"Blue SAM AAA Gepard",
	"Blue SAM AAA Vulcan",
	"Blue SAM AAA C-RAM",
}

if ColdWarTechEra then
	deepSwap(RandomRedPool, cwSwap)
	deepSwap(RandomBluePool, cwSwap)
end
if Era == 'Vietnam' then
	deepSwap(RandomRedPool, vnSwap)
	deepSwap(RandomBluePool, vnSwap)
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
}

RandomUpgradeTemplates = {
	small = { sam = 0, shorad = {0,2}, aaa = {0,2}, ground = {0,3}, armor = {0,2}, arty = {0,2}, total = {4,6}, flakChance = 10, flakSecondChance = 0, flakMax = 1 },
	smallmedium = { sam = 0, shorad = {0,3}, aaa = {0,2}, ground = {0,3}, armor = {0,3}, arty = {0,2}, total = {4,7}, flakChance = 12, flakSecondChance = 0, flakMax = 1 },
	medium = { sam = {0,1}, shorad = {0,3}, aaa = {0,3}, ground = {0,3}, armor = {0,3}, arty = {0,3}, total = {4,9}, flakChance = 15, flakSecondChance = 0, flakMax = 1 },
	mediumbig = { sam = {0,1}, shorad = {0,4}, aaa = {0,3}, ground = {0,3}, armor = {0,4}, arty = {0,3}, total = {5,10}, flakChance = 20, flakSecondChance = 5, flakMax = 2 },
	big = { sam = {0,1}, shorad = {0,4}, aaa = {0,3}, ground = {0,3}, armor = {0,4}, arty = {0,3}, total = {5,10}, flakChance = 25, flakSecondChance = 8, flakMax = 2 },
	bignosam = { sam = 0, shorad = {0,4}, aaa = {0,3}, ground = {0,3}, armor = {0,4}, arty = {0,3}, total = {5,10}, flakChance = 25, flakSecondChance = 8, flakMax = 2 },
	extrabig = { sam = {1,2}, shorad = {0,5}, aaa = {0,4}, ground = {0,4}, armor = {0,4}, arty = {0,4}, total = {7,12}, flakChance = 40, flakSecondChance = 20, flakMax = 2 },
	sam = { sam = 1, shorad = {1,2}, aaa = {1,2}, ground = 0, armor = 0, arty = 0, total = {3,5}, flakChance = 10, flakSecondChance = 0, flakMax = 1 },
	sam2 = { sam = 1, shorad = {1,2}, aaa = {1,2}, ground = 0, armor = {0,1}, arty = 0, total = {3,6}, flakChance = 10, flakSecondChance = 0, flakMax = 1 },
	samspecial = { sam = {2,3}, shorad = {0,4}, aaa = {0,3}, ground = 0, armor = 0, arty = 0, total = {5,9}, flakChance = 25, flakSecondChance = 8, flakMax = 2 },
}

RandomUpgradeTemplatesBlue = {
	small = { sam = 0, ground = {0,1}, armor = 1, aaa = {0,1}, shorad = {0,1}, total = 2 },
	smallmedium = { sam = 0, ground = {0,1}, armor = 1, aaa = {0,1}, shorad = {0,1}, total = 2 },
	medium = { sam = 0, ground = {0,1}, armor = 1, aaa = {0,1}, shorad = {0,1}, total = {2,3} },
	mediumbig = { sam = 0, ground = {0,1}, armor = 1, aaa = {0,1}, shorad = {0,1}, total = {2,3} },
	big = { sam = {0,1}, ground = {0,1}, armor = 1, aaa = {0,1}, shorad = {0,1}, total = {3,4} },
	extrabig = { sam = {0,1}, ground = {0,1}, armor = 1, aaa = {0,1}, shorad = {0,1}, total = {3,4} },
	bignosam = { sam = 0, ground = {0,1}, armor = 1, aaa = {0,1}, shorad = {0,1}, total = {3,4} },
	sam = { sam = {0,1}, ground = {0,1}, armor = 1, aaa = {0,1}, shorad = {0,1}, total = {4,4} },
	sam2 = { sam = {0,1}, ground = {0,1}, armor = 1, aaa = {0,1}, shorad = {0,1}, total = {4,4} },
	samspecial = { sam = {0,1}, ground = {0,1}, armor = 1, aaa = {0,1}, shorad = {0,1}, total = {4,4} },
}

RandomGroundGroups = true
RandomBlueGroups = true
AllowScriptedSupplies = AllowScriptedSupplies ~= false
----------------End Randomized upgrade pools/templates ---------------
bc = BattleCommander:new(filepath, 8, 60)
if RankingSystem then
    bc.rankFile = (lfs and (lfs.writedir() .. 'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
end
Hunt = true
---------------------------begin zone definitions(this is where a side is chosen and what flavor and upgrades each zone will have etc etc)-------------------------
zones = { 
	redcarrier = ZoneCommander:new({facility='none', zone='Red Carrier North', side=1, level=25, upgrades=upgrades.redcarrier, crates={}, flavorText=flavor.redcarrier}),
	redcarrier2 = ZoneCommander:new({facility='none', zone='Red Carrier South', side=1, level=25, upgrades=upgrades.redcarrier2, crates={}, flavorText=flavor.redcarrier2}),
	
	mountpleasant = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Mount Pleasant', size='mediumbig',side=1,  level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.mountpleasant}),
	portstanley = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Port Stanley', size='bignosam', side=2, level=25, upgrades=upgrades.airfieldStart, crates={}, flavorText=flavor.portstanley}),
	sancarlosfob = ZoneCommander:new({facility='farp', isPlaneSpawn=false, isHeloSpawn=true, zone='San Carlos FOB', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.sancarlosfob}),
	goosegreen = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Goose Green', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.goosegreen}),
	riogrande = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Rio Grande', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.riogrande}),
	ushuaia = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Ushuaia', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.ushuaia}),
	puertowilliams = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Puerto Williams', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.puertowilliams}),
	tolhuin = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Tolhuin', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.tolhuin}),
	pampaguanaco = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Pampa Guanaco', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.pampaguanaco}),
	almiranteschroeders = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Almirante Schroeders', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.almiranteschroeders}),
	porvenir = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Porvenir', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.porvenir}),
	puntaarenas = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Punta Arenas', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.puntaarenas}),
	francobianco = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Franco Bianco', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.francobianco}),
	riogallegos = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Rio Gallegos', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.riogallegos}),
	riochico = ZoneCommander:new({facility='airbase', isPlaneSpawn=false, isHeloSpawn=true, zone='Rio Chico', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.riochico}),
	rioturbio = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Rio Turbio', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.rioturbio}),
	elcalafate = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='El Calafate', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.elcalafate}),
	ohiggins = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone="O'Higgins", size='bignosam', side=1, level=25, upgrades=upgrades.airfieldStart, crates={}, flavorText=flavor.ohiggins}),
	gobernadorgregores = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Gobernador Gregores', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.gobernadorgregores}),
	puertonatales = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Puerto Natales', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.puertonatales}),
	puertosantacruz = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Puerto Santa Cruz', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.puertosantacruz}),
	comandanteluispiedrabuena = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='Comandante Luis Piedrabuena', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.comandanteluispiedrabuena}),
	sanjulian = ZoneCommander:new({facility='airbase', isPlaneSpawn=true, isHeloSpawn=true, zone='San Julian', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.sanjulian}),
	hipicoflyingclub = ZoneCommander:new({facility='airbase', isPlaneSpawn=false, zone='Hipico Flying Club', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.hipicoflyingclub}),
	farpcaupolican = ZoneCommander:new({facility='farp', isHeloSpawn=true, zone='FARP Caupolican', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farpcaupolican}),
	farpsayhueque = ZoneCommander:new({facility='farp', isHeloSpawn=true, zone='FARP Sayhueque', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farpsayhueque}),	
	farplautaro = ZoneCommander:new({facility='farp', isHeloSpawn=true, zone='FARP Lautaro', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farplautaro}),
	farpdrake = ZoneCommander:new({facility='farp', isHeloSpawn=true, zone='FARP Drake', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farpdrake}),
	farpcalfucura = ZoneCommander:new({facility='farp', isHeloSpawn=true, zone='FARP Calfucura', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farpcalfucura}),	
	farpinacayal = ZoneCommander:new({facility='farp', isHeloSpawn=true, zone='FARP Inacayal', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farpinacayal}),	
	farpgalvarino = ZoneCommander:new({facility='farp', isHeloSpawn=true, zone='FARP Galvarino', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farpgalvarino}),	
	farpmagellan = ZoneCommander:new({facility='farp', isHeloSpawn=true, zone='FARP Magellan', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farpmagellan}),	
	farpguemes = ZoneCommander:new({facility='farp', isHeloSpawn=true, zone='FARP Guemes', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farpguemes}),	
	farproca = ZoneCommander:new({facility='farp', isHeloSpawn=true, zone='FARP Roca', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farproca}),	
	samalpha			= ZoneCommander:new({facility='none', zone='SAM Alpha',        		 side=1, size='sam2', level=25, upgrades=upgrades.samalpha,     crates={},flavorText=flavor.samalpha}),
	sambravo			= ZoneCommander:new({facility='none', zone='SAM Bravo',        		 side=1, size='sam', level=25, upgrades=upgrades.sambravo,     crates={},flavorText=flavor.sambravo}),
	islandsamsite			= ZoneCommander:new({facility='none', zone='Island SAM Site',        		 side=1, size='sam', level=25, upgrades=upgrades.islandsamsite,     crates={},flavorText=flavor.islandsamsite}),
    rebelbase   = ZoneCommander:new({facility='none', zone='Rebel Base',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints2,      crates={},flavorText=flavor.rebelbase}),
    rebelbarracks   = ZoneCommander:new({facility='none', zone='Rebel Barracks',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints3,      crates={},flavorText=flavor.rebelbarracks}),
    rebelairport   = ZoneCommander:new({facility='none', zone='Rebel Airport',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints4,      crates={},flavorText=flavor.rebelairport}),
	rebelcocainefarm   = ZoneCommander:new({facility='none', zone='Rebel Cocaine Farm',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints5,      crates={},flavorText=flavor.rebelcocainefarm}),
	rebelhq   = ZoneCommander:new({facility='none', zone='Rebel HQ',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints5,      crates={},flavorText=flavor.rebelhq}),
	gullpoint = ZoneCommander:new({facility='farp', isPlaneSpawn=false, isHeloSpawn=true, zone='Gull Point', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.gullpoint}),
	estanciadarwin   = ZoneCommander:new({facility='none', zone='Estancia Darwin',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints1,      crates={},flavorText=flavor.estanciadarwin}),
	
	hidden1 = ZoneCommander:new({facility='none', zone='HiddenSamEWRMantisNet', side=1, level=25, upgrades=upgrades.HiddenSamEWRMantisNet, crates={}, flavorText=flavor.hidden1,ForceNeutral=true}),

}

-- Keep the authored starting SAM in Port Stanley's randomized Blue garrison.
zones.portstanley.upgrades.blue[2] = { n = zones.portstanley.upgrades.blue[2], p = true }

----------------------end zone definitions-----------------------------
---------------------------------begin template definitions (this defines templates for coldwar and modern)-----------------------

if ColdWarTechEra then

    
    
    
    
    
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
	
	if Era == 'Vietnam' then
		AttackConvoy = {
			"AttackConvoy CW 2",
			"AttackConvoy CW 3",
		}
		GroundAttackConvoy = {
			"GroundAttackConvoy VT 1",
		}
	end

	
else

    
    
    
    
    
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
	
end
if Era == 'Coldwar' then
	CapCarrierGroup = {
        'BLUE_F14A',
        'BLUE_HORNET_CW',
	}
else
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
	if Era == 'Vietnam' then
		ArtilleryConvoyShort = {
			"ArtilleryConvoyShort VT 1",
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
AllCapPlaneTemplates = {
	'RED_MIG15BIS_CAP_GUNS_TANKS',
	'RED_MIG19P_CAP_K13A',
	'RED_MIRAGE_F1CE_CAP_S530Fx2_MAGIC2x2',
	'RED_MIRAGE_F1CE_CAP_R530F_EMx2_MAGIC2x2',
	'RED_MIG29S_CAP_R77x3_R27ET_R73x2',
	'RED_MIG29S_CAP_R77x2_R73x2_TANKSx3',
	'RED_MIG29A_CAP_R73x4_R27R2x',
	'RED_MIG29A_CAP_R73x4_R27ER2X',
	'RED_SU27_CAP_R27Rx4_R27ER_R73x3_ECM',
	'RED_SU27_CAP_R27ERx6_R73x2_ECM',
	'RED_MIG21BIS_CAP_R3Rx4',
	'RED_MIG21BIS_CAP_R3Rx2_R3Sx2',
	'RED_MIG21BIS_CAP_R3Rx2_R35x2',
	'RED_MIG23MLD_CAP_R24Rx2_R60Mx2',
	'RED_MIG31_CAP_R33x4_R40Tx2',
	'RED_SU27_CAP_R27ERx5_R73x3_ECM',
	'RED_MIG25PD_CAP_R40Rx2_R60Mx2',
	'RED_L39C_CAP_R3S2X',
	'BLUE_F86F_CAP_GAR8x2',
	'BLUE_F100D_CAP_AIM9Ex2',
	'BLUE_F5E3_CAP_AIM9Bx2',
	'BLUE_FA18C_CAP_AIM120Cx6_AIM9Xx2',
	'BLUE_F15C_CAP_AIM120Bx3_AIM120Cx5',
	'BLUE_F16C_CAP_AIM120Bx4_AIM120C_AIM9M',
	'BLUE_F16_CAP_AIM120Cx5_AIM9Xx1',
	'BLUE_F14B_CAP_AIM54A_MK47x4_AIM7Mx2_AIM9Mx2_TANKSx2',
	'BLUE_F14B_CAP_AIM54C_MK47x4_AIM7Mx2_AIM9Mx2_TANKSx2',
	'BLUE_F14B_CAP_AIM54C_MK60x4_AIM7Mx2_AIM9Mx2_TANKSx2',
	'BLUE_M2000C_CAP_S530Dx2_MAGIC2x2',
	'BLUE_F4E_CAP_AIM7E2x4_AIM9Jx4_TANKSx3_ALE40',
	'BLUE_FA18C_CAP_AIM7Mx6_AIM9Mx2',
	'BLUE_F15C_CAP_AIM7Mx4_AIM9Mx4',
	'BLUE_F14A_CAP_AIM54A_MK47x6_AIM9Mx2_TANKSx2',
	'BLUE_F14A_CAP_AIM54A_MK47x2_AIM7Fx3_AIM9Lx2_TANKSx2',
}

CapPlaneTemplate = BuildEnabledTemplateList(AllCapPlaneTemplates, RedCapPlaneEnabled, BlueCapPlaneEnabled)

AllCasPlaneTemplates = {
	'RED_SU25_CAS_KH25ML_S25Lx2_FAB500M62x2_B8x2_SPPU_1SHIP',
	'RED_SU25_CAS_FAB250x2_FAB500M62x2_B8x2_S24Bx2_1SHIP',
	'RED_SU25_CAS_KH25MLx2_S25Lx2_FAB500M62x2_B13x2_1SHIP',
	'RED_SU25_CAS_KH25ML_S25Lx2_FAB500M62x2_B8x2_SPPU_2SHIP',
	'RED_SU25_CAS_FAB250x2_FAB500M62x2_B8x2_S24Bx2_2SHIP',
	'RED_SU25_CAS_KH25MLx2_S25Lx2_FAB500M62x2_B13x2_2SHIP',
	'RED_SU25T_CAS_KH25MPx2_VIKHRx2_KH29Tx2_1SHIP',
	'RED_SU25T_CAS_KH25MLx4_KH29Tx2_1SHIP',
	'RED_SU25T_CAS_VIKHRx2_FAB500M62x2_KH29Tx2_1SHIP',
	'RED_SU25T_CAS_KH25MPx2_VIKHRx2_KH29Tx2_2SHIP',
	'RED_SU25T_CAS_KH25MLx4_KH29Tx2_2SHIP',
	'RED_SU25T_CAS_VIKHRx2_FAB500M62x2_KH29Tx2_2SHIP',
	'RED_MIRAGE_F1BQ_CAS_SAMP400x2_SAMP250x2_2SHIP',
	'RED_MIRAGE_F1BQ_CAS_MIXED_SNEB_SAMP_2SHIP',
	'RED_MIG21BIS_CAS_RBK250x2_UB32x2_1SHIP',
	'RED_MIG21BIS_CAS_RBK250x2_UB32x2_2SHIP',
	'RED_MIG21BIS_CAS_S24Bx4_1SHIP',
	'RED_MIG21BIS_CAS_S24Bx4_2SHIP',
	'RED_MIG21BIS_CAS_KH66x2_FAB250x2_1SHIP',
	'RED_MIG21BIS_CAS_KH66x2_FAB250x2_2SHIP',
	'RED_MIG15BIS_CAS_FAB100Mx2_1SHIP',
	'RED_MIG15BIS_CAS_FAB100Mx2_2SHIP',
	'RED_MIG19P_CAS_K13Ax2_ORO57Kx2_PTB760x2_1SHIP',
	'RED_MIG19P_CAS_K13Ax2_ORO57Kx2_PTB760x2_2SHIP',
	'RED_MIG19P_CAS_K13Ax2_FAB250x2_ORO57Kx2_1SHIP',
	'RED_MIG19P_CAS_K13Ax2_FAB250x2_ORO57Kx2_2SHIP',
	'RED_L39C_CAS_S5M2XHE_1SHIP',
	'RED_L39C_CAS_S5M2XHE_2SHIP',
	'RED_L39C_CAS_FAB100Mx2_1SHIP',
	'RED_L39C_CAS_FAB100Mx2_2SHIP',
	'BLUE_F4E_CAS_WALLEYEIIx2_GBU12x2_PAVESPIKE_2SHIP',
	'BLUE_F4E_CAS_AGM65Dx6_GBU12x2_PAVESPIKE_2SHIP',
	'BLUE_F16_CAS_AGM65Dx4_GBU12x2_PAVESPIKE_2SHIP',
	'BLUE_F4E_CAS_M117x12_AIM7E2x3_TANKSx2_ALQ131',
	'BLUE_F4E_CAS_AGM12Bx2_AIM7E2x3_TANK600_ALQ131',
	'BLUE_F4E_CAS_WALLEYEIx4_TANK600_ALQ131',
	'BLUE_F4E_CAS_WALLEYEIx2_AGM65Ax4_TANK600_ALQ131',
	'BLUE_F100D_CAS_MK82x8_TANKSx2_2SHIP',
	'BLUE_F100D_CAS_M117x6_TANKSx2_2SHIP',
	'BLUE_F5E3_CAS_MK82LDx4_AIM9Bx2_TANK275_2SHIP',
	'BLUE_F5E3_CAS_MK82SEx4_AIM9Bx2_TANK275_2SHIP',
	'BLUE_F86F_CAS_AIM9Bx2_HVARx8_TANKSx2_2SHIP',
	'BLUE_F86F_CAS_AIM9Bx2_M117x2_2SHIP',
}

CasPlaneTemplate = BuildEnabledTemplateList(AllCasPlaneTemplates, RedCasPlaneEnabled, BlueCasPlaneEnabled)

AllSeadPlaneTemplates = {
	'RED_JF17_SEAD_LD10x2_PL5EIIx2_SPJ_TANKSx2_1SHIP',
	'RED_JF17_SEAD_LD10x2_PL5EIIx2_SPJ_TANKSx2_2SHIP',
	'RED_SU25T_SEAD_KH58Ux2_KH25MPU_S24B_B13x2_R73x2_1SHIP',
	'RED_SU25T_SEAD_KH58Ux2_KH25MPU_S24B_B13x2_R73x2_2SHIP',
	'RED_SU34_SEAD_KH31Px4_R77x2_R27Rx2_R73x2_1SHIP',
	'RED_SU34_SEAD_KH31Px2_KH58Ux2_BETAB500SHP_R27ERx2_R27R_R73x2_1SHIP',
	'RED_SU34_SEAD_KH31Px4_R77x2_R27Rx2_R73x2_2SHIP',
	'RED_SU34_SEAD_KH31Px2_KH58Ux2_BETAB500SHP_R27ERx2_R27R_R73x2_2SHIP',
	'RED_SU24M_SEAD_KH58x2_FAB1500M54_L081_R60Mx4_2SHIP',
	'RED_SU24M_SEAD_KH31Px2_KH25MLx2_FAB1500M54_L081_1SHIP',
	'RED_SU17M4_SEAD_KH25MRx4_R60x2_TANKSx2_1SHIP',
	'RED_SU17M4_SEAD_KH25MRx4_R60x2_TANKSx2_2SHIP',
	'BLUE_F100D_SEAD_AGM45Ax2_CBU7x2_TANKSx2_2SHIP',
	'BLUE_F4E_SEAD_AGM45Ax4_AIM7E2x3_TANK600_ALQ131',
	'BLUE_F16_SEAD_AGM88Cx4_AIM120Cx2_AIM9Xx2',
	'BLUE_F18_SEAD_AGM88Cx2_ADM141Ax6_AIM120Cx1_AIM9Xx2',
	'BLUE_F18_SEAD_AGM88Cx2_AGM154CAx4_AIM120Cx1_AIM9Xx2',
}

SeadPlaneTemplate = BuildEnabledTemplateList(AllSeadPlaneTemplates, RedSeadPlaneEnabled, BlueSeadPlaneEnabled)

AllRunwayStrikePlaneTemplates = {
	'RED_MIG27K_RUNWAY_BETAB500x2_FAB250x2_R60Mx4_3SHIP',
	'RED_SU33_RUNWAY_BETAB500x4_R27ERx4_R73x2_3SHIP',
	'RED_MIRAGE_F1EE_RUNWAY_DURANDALx6_S530Fx2_AIM9JULIx2_3SHIP',
	'RED_MIG21BIS_RUNWAY_BETAB500x2_R3Rx2_TANK490_3SHIP',
}

RunwayStrikePlaneTemplate = BuildEnabledTemplateList(AllRunwayStrikePlaneTemplates, RedRunwayStrikePlaneEnabled)

AllCasHeloTemplates = {
	'RED_MI8_CAS_FAB100x4_UPK23x2_KORD_PKT_1SHIP',
	'RED_MI8_CAS_FAB100x4_UPK23x2_KORD_PKT_2SHIP',
	'RED_MI8_CAS_GUV_YAKB_GSHPx2_KORD_PKT_1SHIP',
	'RED_MI8_CAS_GUV_YAKB_GSHPx2_KORD_PKT_2SHIP',
	'RED_MI24P_CAS_9M114x8_B8x2_1SHIP',
	'RED_MI24P_CAS_9M114x8_B8x2_2SHIP',
	'RED_MI24P_CAS_B13Lx2_B8x2_1SHIP',
	'RED_MI24P_CAS_B13Lx2_B8x2_2SHIP',
	'RED_MI28N_CAS_9M120x8_9M120Fx8_B13x2_1SHIP',
	'RED_MI28N_CAS_9M114x8_B8x2_1SHIP',
	'RED_MI28N_CAS_9M114x8_B8x2_2SHIP',
	'RED_MI28N_CAS_9M120x8_9M120Fx8_B13x2_2SHIP',
	'RED_MI24V_CAS_B8x2_B13x2_1SHIP',
	'RED_MI24V_CAS_B8x2_B13x2_2SHIP',
	'BLUE_AH64D_CAS_AGM114Kx4_AGM114Lx4_M261x2_FCR_1SHIP',
	'BLUE_AH64D_CAS_AGM114Kx4_AGM114Lx4_M261x2_FCR_2SHIP',
	'BLUE_AH64D_CAS_AGM114Kx8_M261x2_1SHIP',
	'BLUE_AH64D_CAS_AGM114Kx8_M261x2_2SHIP',
	'BLUE_AH1W_CAS_AGM114Kx8_M260x2_1SHIP',
	'BLUE_SA342M_CAS_HOT3x4_1SHIP',
	'BLUE_SA342M_CAS_HOT3x4_2SHIP',
	'BLUE_OH58D_CAS_AGM114x2_APKWS_1SHIP',
	'BLUE_OH58D_CAS_AGM114x2_APKWS_2SHIP',
	'BLUE_UH1H_CAS_XM158x2_M134x3_M60_1SHIP',
	'BLUE_UH1H_CAS_XM158x2_M134x3_M60_2SHIP',
}

CasHeloTemplate = BuildEnabledTemplateList(AllCasHeloTemplates, RedCasHeloEnabled, BlueCasHeloEnabled)

AllSupplyHeloTemplates = {
	'RED_MI8_SUPPLY_KORD',
	'RED_MI8_SUPPLY_KORD_PKT',
	'BLUE_CH47_SUPPLY_M240Hx2',
	'BLUE_CH47_SUPPLY_M60Dx3',
	'BLUE_UH60A_SUPPLY_UNARMED',
	'BLUE_UH1H_SUPPLY_UNARMED',
}

HeloSupplyTemplate = BuildEnabledTemplateList(AllSupplyHeloTemplates, RedSupplyHeloEnabled, BlueSupplyHeloEnabled)

--------------------------end template swaps---------------------------
--------------------begin altitude definitions (math to define altitudes for various calls)---------------------
function CasAltitude() return math.random(15,25)*1000 end
function CapAltitude() return math.random(22,32)*1000 end
function SeadAltitude() return math.random(25,33)*1000 end
function RunwayStrikeAltitude() return math.random(23,28)*1000 end
-------------------------end altitude definitions----------------------
---------------Zones + GroupCommander routes --------------------
    -- Surface attack routes
  --  GroupCommander:new({name='mountpleasant-attack-Bost',  mission='attack',template='AttackConvoy', targetzone='Bost', type='surface'}),
zones.portstanley:addGroups({
    DirectorCapability:new({name='portstanley-supply-SanCarlosFOB-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Carlos FOB'}),
    DirectorCapability:new({name='portstanley-supply-MountPleasant-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Mount Pleasant'}),
    DirectorCapability:new({name='portstanley-supply-MountPleasant-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Mount Pleasant'}),

    DirectorCapability:new({name='portstanley-attack-SanCarlosFOB-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),
    DirectorCapability:new({name='portstanley-attack-SanCarlosFOB-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='San Carlos FOB', Altitude = CasAltitude()}),
    DirectorCapability:new({name='portstanley-attack-SanCarlosFOB-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='San Carlos FOB', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='portstanley-patrol-SanCarlosFOB-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),

    DirectorCapability:new({name='portstanley-attack-MountPleasant-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mount Pleasant', Altitude = CapAltitude()}),
    DirectorCapability:new({name='portstanley-attack-MountPleasant-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Mount Pleasant', Altitude = CasAltitude()}),
    DirectorCapability:new({name='portstanley-attack-MountPleasant-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Mount Pleasant', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='portstanley-patrol-MountPleasant-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mount Pleasant', Altitude = CapAltitude()}),
})

zones.mountpleasant:addGroups({
    DirectorCapability:new({name='mountpleasant-supply-PortStanley-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Port Stanley'}),
    DirectorCapability:new({name='mountpleasant-supply-PortStanley-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Port Stanley'}),
    DirectorCapability:new({name='mountpleasant-supply-GooseGreen-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Goose Green'}),
    DirectorCapability:new({name='mountpleasant-supply-GooseGreen-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Goose Green'}),
    DirectorCapability:new({name='mountpleasant-supply-SanCarlosFOB-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Carlos FOB'}),

    DirectorCapability:new({name='mountpleasant-attack-PortStanley-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Port Stanley', Altitude = CapAltitude()}),
    DirectorCapability:new({name='mountpleasant-attack-PortStanley-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Port Stanley', Altitude = CasAltitude()}),
    DirectorCapability:new({name='mountpleasant-attack-PortStanley-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Port Stanley', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='mountpleasant-patrol-PortStanley-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Port Stanley', Altitude = CapAltitude()}),

    DirectorCapability:new({name='mountpleasant-attack-GooseGreen-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Goose Green', Altitude = CapAltitude()}),
    DirectorCapability:new({name='mountpleasant-attack-GooseGreen-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Goose Green', Altitude = CasAltitude()}),
    DirectorCapability:new({name='mountpleasant-attack-GooseGreen-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Goose Green', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='mountpleasant-patrol-GooseGreen-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Goose Green', Altitude = CapAltitude()}),

    DirectorCapability:new({name='mountpleasant-attack-SanCarlosFOB-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),
    DirectorCapability:new({name='mountpleasant-attack-SanCarlosFOB-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='San Carlos FOB', Altitude = CasAltitude()}),
    DirectorCapability:new({name='mountpleasant-attack-SanCarlosFOB-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='San Carlos FOB', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='mountpleasant-patrol-SanCarlosFOB-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),
})

zones.goosegreen:addGroups({
    DirectorCapability:new({name='goosegreen-supply-GullPoint-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Gull Point'}),
    DirectorCapability:new({name='goosegreen-supply-MountPleasant-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Mount Pleasant'}),
    DirectorCapability:new({name='goosegreen-supply-MountPleasant-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Mount Pleasant'}),
    DirectorCapability:new({name='goosegreen-supply-SanCarlosFOB-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Carlos FOB'}),

    DirectorCapability:new({name='goosegreen-attack-MountPleasant-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mount Pleasant', Altitude = CapAltitude()}),
    DirectorCapability:new({name='goosegreen-attack-MountPleasant-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Mount Pleasant', Altitude = CasAltitude()}),
    DirectorCapability:new({name='goosegreen-attack-MountPleasant-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Mount Pleasant', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='goosegreen-patrol-MountPleasant-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mount Pleasant', Altitude = CapAltitude()}),

    DirectorCapability:new({name='goosegreen-attack-SanCarlosFOB-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),
    DirectorCapability:new({name='goosegreen-attack-SanCarlosFOB-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='San Carlos FOB', Altitude = CasAltitude()}),
    DirectorCapability:new({name='goosegreen-attack-SanCarlosFOB-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='San Carlos FOB', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='goosegreen-patrol-SanCarlosFOB-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),
	DirectorCapability:new({name='goosegreen-attack-MountPleasant-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Mount Pleasant', type='surface',SetActiveMission = true}), -- ME zone: Arty-Koya-Erbil Airport

})

zones.gullpoint:addGroups({
    DirectorCapability:new({name='gullpoint-supply-GooseGreen-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Goose Green'}),
})

zones.sancarlosfob:addGroups({
    DirectorCapability:new({name='sancarlosfob-supply-PortStanley-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Port Stanley'}),
    DirectorCapability:new({name='sancarlosfob-supply-GooseGreen-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Goose Green'}),
    DirectorCapability:new({name='sancarlosfob-supply-MountPleasant-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Mount Pleasant'}),
})

zones.redcarrier2:addGroups({
})

zones.tolhuin:addGroups({
    DirectorCapability:new({name='tolhuin-supply-PuertoWilliams-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Williams'}),
    DirectorCapability:new({name='tolhuin-supply-PuertoWilliams-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Williams'}),
    DirectorCapability:new({name='tolhuin-supply-Ushuaia-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Ushuaia'}),
    DirectorCapability:new({name='tolhuin-supply-Ushuaia-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Ushuaia'}),
    DirectorCapability:new({name='tolhuin-supply-PampaGuanaco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Pampa Guanaco'}),
    DirectorCapability:new({name='tolhuin-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),
    DirectorCapability:new({name='tolhuin-supply-RioGrande-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Grande'}),
    DirectorCapability:new({name='tolhuin-supply-RioGrande-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Grande'}),

    DirectorCapability:new({name='tolhuin-attack-PuertoWilliams-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),
    DirectorCapability:new({name='tolhuin-attack-PuertoWilliams-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Williams', Altitude = CasAltitude()}),
    DirectorCapability:new({name='tolhuin-attack-PuertoWilliams-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Williams', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='tolhuin-patrol-PuertoWilliams-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),

    DirectorCapability:new({name='tolhuin-attack-Ushuaia-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),
    DirectorCapability:new({name='tolhuin-attack-Ushuaia-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Ushuaia', Altitude = CasAltitude()}),
    DirectorCapability:new({name='tolhuin-attack-Ushuaia-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Ushuaia', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='tolhuin-patrol-Ushuaia-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),

    DirectorCapability:new({name='tolhuin-attack-PampaGuanaco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
    DirectorCapability:new({name='tolhuin-attack-PampaGuanaco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Pampa Guanaco', Altitude = CasAltitude()}),
    DirectorCapability:new({name='tolhuin-attack-PampaGuanaco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Pampa Guanaco', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='tolhuin-patrol-PampaGuanaco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),

    DirectorCapability:new({name='tolhuin-attack-RioGrande-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Grande', Altitude = CapAltitude()}),
    DirectorCapability:new({name='tolhuin-attack-RioGrande-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Grande', Altitude = CasAltitude()}),
    DirectorCapability:new({name='tolhuin-attack-RioGrande-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Grande', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='tolhuin-patrol-RioGrande-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Grande', Altitude = CapAltitude()}),
})

zones.puertowilliams:addGroups({
    DirectorCapability:new({name='puertowilliams-supply-Tolhuin-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Tolhuin'}),
    DirectorCapability:new({name='puertowilliams-supply-Tolhuin-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Tolhuin'}),
    DirectorCapability:new({name='puertowilliams-supply-Ushuaia-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Ushuaia'}),
    DirectorCapability:new({name='puertowilliams-supply-Ushuaia-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Ushuaia'}),
    DirectorCapability:new({name='puertowilliams-supply-PampaGuanaco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Pampa Guanaco'}),
    DirectorCapability:new({name='puertowilliams-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),

    DirectorCapability:new({name='puertowilliams-attack-Tolhuin-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puertowilliams-attack-Tolhuin-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tolhuin', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puertowilliams-attack-Tolhuin-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Tolhuin', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puertowilliams-patrol-Tolhuin-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),

    DirectorCapability:new({name='puertowilliams-attack-Ushuaia-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puertowilliams-attack-Ushuaia-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Ushuaia', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puertowilliams-attack-Ushuaia-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Ushuaia', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puertowilliams-patrol-Ushuaia-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),

    DirectorCapability:new({name='puertowilliams-attack-PampaGuanaco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puertowilliams-attack-PampaGuanaco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Pampa Guanaco', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puertowilliams-attack-PampaGuanaco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Pampa Guanaco', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puertowilliams-patrol-PampaGuanaco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
})

zones.ushuaia:addGroups({
    DirectorCapability:new({name='ushuaia-supply-Tolhuin-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Tolhuin'}),
    DirectorCapability:new({name='ushuaia-supply-Tolhuin-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Tolhuin'}),
    DirectorCapability:new({name='ushuaia-supply-PuertoWilliams-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Williams'}),
    DirectorCapability:new({name='ushuaia-supply-PuertoWilliams-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Williams'}),
    DirectorCapability:new({name='ushuaia-supply-PampaGuanaco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Pampa Guanaco'}),
    DirectorCapability:new({name='ushuaia-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),

    DirectorCapability:new({name='ushuaia-attack-Tolhuin-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),
    DirectorCapability:new({name='ushuaia-attack-Tolhuin-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tolhuin', Altitude = CasAltitude()}),
    DirectorCapability:new({name='ushuaia-attack-Tolhuin-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Tolhuin', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='ushuaia-patrol-Tolhuin-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),

    DirectorCapability:new({name='ushuaia-attack-PuertoWilliams-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),
    DirectorCapability:new({name='ushuaia-attack-PuertoWilliams-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Williams', Altitude = CasAltitude()}),
    DirectorCapability:new({name='ushuaia-attack-PuertoWilliams-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Williams', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='ushuaia-patrol-PuertoWilliams-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),

    DirectorCapability:new({name='ushuaia-attack-PampaGuanaco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
    DirectorCapability:new({name='ushuaia-attack-PampaGuanaco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Pampa Guanaco', Altitude = CasAltitude()}),
    DirectorCapability:new({name='ushuaia-attack-PampaGuanaco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Pampa Guanaco', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='ushuaia-patrol-PampaGuanaco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
})

zones.riogrande:addGroups({
    DirectorCapability:new({name='riogrande-supply-Tolhuin-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Tolhuin'}),
    DirectorCapability:new({name='riogrande-supply-Tolhuin-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Tolhuin'}),
    DirectorCapability:new({name='riogrande-supply-PampaGuanaco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Pampa Guanaco'}),
    DirectorCapability:new({name='riogrande-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),
    DirectorCapability:new({name='riogrande-supply-FARPCaupolican-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Caupolican'}),

    DirectorCapability:new({name='riogrande-attack-Tolhuin-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),
    DirectorCapability:new({name='riogrande-attack-Tolhuin-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tolhuin', Altitude = CasAltitude()}),
    DirectorCapability:new({name='riogrande-attack-Tolhuin-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Tolhuin', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='riogrande-patrol-Tolhuin-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),

    DirectorCapability:new({name='riogrande-attack-PampaGuanaco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
    DirectorCapability:new({name='riogrande-attack-PampaGuanaco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Pampa Guanaco', Altitude = CasAltitude()}),
    DirectorCapability:new({name='riogrande-attack-PampaGuanaco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Pampa Guanaco', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='riogrande-patrol-PampaGuanaco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),

    DirectorCapability:new({name='riogrande-attack-FARPCaupolican-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),
    DirectorCapability:new({name='riogrande-attack-FARPCaupolican-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Caupolican', Altitude = CasAltitude()}),
    DirectorCapability:new({name='riogrande-attack-FARPCaupolican-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Caupolican', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='riogrande-patrol-FARPCaupolican-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),
})

zones.pampaguanaco:addGroups({
    DirectorCapability:new({name='pampaguanaco-supply-Tolhuin-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Tolhuin'}),
    DirectorCapability:new({name='pampaguanaco-supply-Tolhuin-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Tolhuin'}),
    DirectorCapability:new({name='pampaguanaco-supply-Ushuaia-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Ushuaia'}),
    DirectorCapability:new({name='pampaguanaco-supply-Ushuaia-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Ushuaia'}),
    DirectorCapability:new({name='pampaguanaco-supply-PuertoWilliams-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Williams'}),
    DirectorCapability:new({name='pampaguanaco-supply-PuertoWilliams-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Williams'}),
    DirectorCapability:new({name='pampaguanaco-supply-RioGrande-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Grande'}),
    DirectorCapability:new({name='pampaguanaco-supply-RioGrande-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Grande'}),
    DirectorCapability:new({name='pampaguanaco-supply-AlmiranteSchroeders-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Almirante Schroeders'}),
    DirectorCapability:new({name='pampaguanaco-supply-AlmiranteSchroeders-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Almirante Schroeders'}),
    DirectorCapability:new({name='pampaguanaco-supply-FARPCaupolican-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Caupolican'}),

    DirectorCapability:new({name='pampaguanaco-attack-Tolhuin-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-Tolhuin-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tolhuin', Altitude = CasAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-Tolhuin-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Tolhuin', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='pampaguanaco-patrol-Tolhuin-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),

    DirectorCapability:new({name='pampaguanaco-attack-Ushuaia-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-Ushuaia-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Ushuaia', Altitude = CasAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-Ushuaia-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Ushuaia', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='pampaguanaco-patrol-Ushuaia-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),

    DirectorCapability:new({name='pampaguanaco-attack-PuertoWilliams-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-PuertoWilliams-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Williams', Altitude = CasAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-PuertoWilliams-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Williams', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='pampaguanaco-patrol-PuertoWilliams-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),

    DirectorCapability:new({name='pampaguanaco-attack-RioGrande-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Grande', Altitude = CapAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-RioGrande-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Grande', Altitude = CasAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-RioGrande-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Grande', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='pampaguanaco-patrol-RioGrande-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Grande', Altitude = CapAltitude()}),

    DirectorCapability:new({name='pampaguanaco-attack-AlmiranteSchroeders-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Almirante Schroeders', Altitude = CapAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-AlmiranteSchroeders-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Almirante Schroeders', Altitude = CasAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-AlmiranteSchroeders-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Almirante Schroeders', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='pampaguanaco-patrol-AlmiranteSchroeders-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Almirante Schroeders', Altitude = CapAltitude()}),

    DirectorCapability:new({name='pampaguanaco-attack-FARPCaupolican-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-FARPCaupolican-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Caupolican', Altitude = CasAltitude()}),
    DirectorCapability:new({name='pampaguanaco-attack-FARPCaupolican-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Caupolican', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='pampaguanaco-patrol-FARPCaupolican-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),
})

zones.almiranteschroeders:addGroups({
    DirectorCapability:new({name='almiranteschroeders-supply-PampaGuanaco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Pampa Guanaco'}),
    DirectorCapability:new({name='almiranteschroeders-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),
    DirectorCapability:new({name='almiranteschroeders-supply-Porvenir-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Porvenir'}),
    DirectorCapability:new({name='almiranteschroeders-supply-Porvenir-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Porvenir'}),

    DirectorCapability:new({name='almiranteschroeders-attack-PampaGuanaco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
    DirectorCapability:new({name='almiranteschroeders-attack-PampaGuanaco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Pampa Guanaco', Altitude = CasAltitude()}),
    DirectorCapability:new({name='almiranteschroeders-attack-PampaGuanaco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Pampa Guanaco', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='almiranteschroeders-patrol-PampaGuanaco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),

    DirectorCapability:new({name='almiranteschroeders-attack-Porvenir-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Porvenir', Altitude = CapAltitude()}),
    DirectorCapability:new({name='almiranteschroeders-attack-Porvenir-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Porvenir', Altitude = CasAltitude()}),
    DirectorCapability:new({name='almiranteschroeders-attack-Porvenir-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Porvenir', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='almiranteschroeders-patrol-Porvenir-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Porvenir', Altitude = CapAltitude()}),
})

zones.farpcaupolican:addGroups({
    DirectorCapability:new({name='farpcaupolican-supply-RioGrande-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Grande'}),
    DirectorCapability:new({name='farpcaupolican-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),
    DirectorCapability:new({name='farpcaupolican-supply-PuntaArenas-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Punta Arenas'}),
    DirectorCapability:new({name='farpcaupolican-supply-FARPSayhueque-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Sayhueque'}),
})

zones.porvenir:addGroups({
    DirectorCapability:new({name='porvenir-supply-AlmiranteSchroeders-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Almirante Schroeders'}),
    DirectorCapability:new({name='porvenir-supply-AlmiranteSchroeders-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Almirante Schroeders'}),
    DirectorCapability:new({name='porvenir-supply-PuntaArenas-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Punta Arenas'}),
    DirectorCapability:new({name='porvenir-supply-PuntaArenas-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Punta Arenas'}),

    DirectorCapability:new({name='porvenir-attack-AlmiranteSchroeders-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Almirante Schroeders', Altitude = CapAltitude()}),
    DirectorCapability:new({name='porvenir-attack-AlmiranteSchroeders-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Almirante Schroeders', Altitude = CasAltitude()}),
    DirectorCapability:new({name='porvenir-attack-AlmiranteSchroeders-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Almirante Schroeders', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='porvenir-patrol-AlmiranteSchroeders-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Almirante Schroeders', Altitude = CapAltitude()}),

    DirectorCapability:new({name='porvenir-attack-PuntaArenas-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),
    DirectorCapability:new({name='porvenir-attack-PuntaArenas-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Punta Arenas', Altitude = CasAltitude()}),
    DirectorCapability:new({name='porvenir-attack-PuntaArenas-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Punta Arenas', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='porvenir-patrol-PuntaArenas-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),
})

zones.puntaarenas:addGroups({
    DirectorCapability:new({name='puntaarenas-supply-FARPCaupolican-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Caupolican'}),
    DirectorCapability:new({name='puntaarenas-supply-Porvenir-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Porvenir'}),
    DirectorCapability:new({name='puntaarenas-supply-Porvenir-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Porvenir'}),
    DirectorCapability:new({name='puntaarenas-supply-FrancoBianco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Franco Bianco'}),
    DirectorCapability:new({name='puntaarenas-supply-FrancoBianco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Franco Bianco'}),
    DirectorCapability:new({name='puntaarenas-supply-PuertoNatales-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Natales'}),
    DirectorCapability:new({name='puntaarenas-supply-PuertoNatales-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Natales'}),

    DirectorCapability:new({name='puntaarenas-attack-FARPCaupolican-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puntaarenas-attack-FARPCaupolican-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Caupolican', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puntaarenas-attack-FARPCaupolican-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Caupolican', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puntaarenas-patrol-FARPCaupolican-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),

    DirectorCapability:new({name='puntaarenas-attack-Porvenir-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Porvenir', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puntaarenas-attack-Porvenir-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Porvenir', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puntaarenas-attack-Porvenir-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Porvenir', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puntaarenas-patrol-Porvenir-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Porvenir', Altitude = CapAltitude()}),

    DirectorCapability:new({name='puntaarenas-attack-FrancoBianco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Franco Bianco', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puntaarenas-attack-FrancoBianco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Franco Bianco', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puntaarenas-attack-FrancoBianco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Franco Bianco', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puntaarenas-patrol-FrancoBianco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Franco Bianco', Altitude = CapAltitude()}),

    DirectorCapability:new({name='puntaarenas-attack-PuertoNatales-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puntaarenas-attack-PuertoNatales-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Natales', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puntaarenas-attack-PuertoNatales-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Natales', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puntaarenas-patrol-PuertoNatales-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),
})

zones.francobianco:addGroups({
    DirectorCapability:new({name='francobianco-supply-PuntaArenas-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Punta Arenas'}),
    DirectorCapability:new({name='francobianco-supply-PuntaArenas-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Punta Arenas'}),
    DirectorCapability:new({name='francobianco-supply-FARPSayhueque-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Sayhueque'}),
    DirectorCapability:new({name='francobianco-supply-RioGallegos-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Gallegos'}),
    DirectorCapability:new({name='francobianco-supply-RioGallegos-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Gallegos'}),

    DirectorCapability:new({name='francobianco-attack-PuntaArenas-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),
    DirectorCapability:new({name='francobianco-attack-PuntaArenas-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Punta Arenas', Altitude = CasAltitude()}),
    DirectorCapability:new({name='francobianco-attack-PuntaArenas-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Punta Arenas', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='francobianco-patrol-PuntaArenas-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),

    DirectorCapability:new({name='francobianco-attack-FARPSayhueque-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Sayhueque', Altitude = CapAltitude()}),
    DirectorCapability:new({name='francobianco-attack-FARPSayhueque-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Sayhueque', Altitude = CasAltitude()}),
    DirectorCapability:new({name='francobianco-attack-FARPSayhueque-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Sayhueque', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='francobianco-patrol-FARPSayhueque-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Sayhueque', Altitude = CapAltitude()}),

    DirectorCapability:new({name='francobianco-attack-RioGallegos-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Gallegos', Altitude = CapAltitude()}),
    DirectorCapability:new({name='francobianco-attack-RioGallegos-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Gallegos', Altitude = CasAltitude()}),
    DirectorCapability:new({name='francobianco-attack-RioGallegos-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Gallegos', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='francobianco-patrol-RioGallegos-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Gallegos', Altitude = CapAltitude()}),
})

zones.farpsayhueque:addGroups({
    DirectorCapability:new({name='farpsayhueque-supply-FARPCaupolican-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Caupolican'}),
    DirectorCapability:new({name='farpsayhueque-supply-FrancoBianco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Franco Bianco'}),
    DirectorCapability:new({name='farpsayhueque-supply-FARPLautaro-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Lautaro'}),
})

zones.farplautaro:addGroups({
    DirectorCapability:new({name='farplautaro-supply-FARPSayhueque-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Sayhueque'}),
    DirectorCapability:new({name='farplautaro-supply-RioChico-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Chico'}),
    DirectorCapability:new({name='farplautaro-supply-FARPDrake-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Drake'}),
})

zones.riochico:addGroups({
    DirectorCapability:new({name='riochico-supply-FARPLautaro-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Lautaro'}),
    DirectorCapability:new({name='riochico-supply-RioGallegos-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Gallegos'}),
    DirectorCapability:new({name='riochico-supply-FARPDrake-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Drake'}),
})

zones.riogallegos:addGroups({
    DirectorCapability:new({name='riogallegos-supply-FrancoBianco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Franco Bianco'}),
    DirectorCapability:new({name='riogallegos-supply-FrancoBianco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Franco Bianco'}),
    DirectorCapability:new({name='riogallegos-supply-RioChico-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Chico'}),
    DirectorCapability:new({name='riogallegos-supply-SanJulian-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='San Julian'}),
    DirectorCapability:new({name='riogallegos-supply-SanJulian-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Julian'}),

    DirectorCapability:new({name='riogallegos-attack-FrancoBianco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Franco Bianco', Altitude = CapAltitude()}),
    DirectorCapability:new({name='riogallegos-attack-FrancoBianco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Franco Bianco', Altitude = CasAltitude()}),
    DirectorCapability:new({name='riogallegos-attack-FrancoBianco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Franco Bianco', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='riogallegos-patrol-FrancoBianco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Franco Bianco', Altitude = CapAltitude()}),

    DirectorCapability:new({name='riogallegos-attack-RioChico-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Chico', Altitude = CapAltitude()}),
    DirectorCapability:new({name='riogallegos-attack-RioChico-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Chico', Altitude = CasAltitude()}),
    DirectorCapability:new({name='riogallegos-attack-RioChico-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Chico', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='riogallegos-patrol-RioChico-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Chico', Altitude = CapAltitude()}),

    DirectorCapability:new({name='riogallegos-attack-SanJulian-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Julian', Altitude = CapAltitude()}),
    DirectorCapability:new({name='riogallegos-attack-SanJulian-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='San Julian', Altitude = CasAltitude()}),
    DirectorCapability:new({name='riogallegos-attack-SanJulian-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='San Julian', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='riogallegos-patrol-SanJulian-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Julian', Altitude = CapAltitude()}),
})

zones.farpdrake:addGroups({
    DirectorCapability:new({name='farpdrake-supply-FARPLautaro-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Lautaro'}),
    DirectorCapability:new({name='farpdrake-supply-RioChico-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Chico'}),
    DirectorCapability:new({name='farpdrake-supply-FARPCalfucura-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Calfucura'}),
    DirectorCapability:new({name='farpdrake-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),
})

zones.rioturbio:addGroups({
    DirectorCapability:new({name='rioturbio-supply-PuertoNatales-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Natales'}),
    DirectorCapability:new({name='rioturbio-supply-PuertoNatales-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Natales'}),
    DirectorCapability:new({name='rioturbio-supply-ElCalafate-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='El Calafate'}),
    DirectorCapability:new({name='rioturbio-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),

    DirectorCapability:new({name='rioturbio-attack-PuertoNatales-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),
    DirectorCapability:new({name='rioturbio-attack-PuertoNatales-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Natales', Altitude = CasAltitude()}),
    DirectorCapability:new({name='rioturbio-attack-PuertoNatales-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Natales', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='rioturbio-patrol-PuertoNatales-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),

    DirectorCapability:new({name='rioturbio-attack-ElCalafate-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),
    DirectorCapability:new({name='rioturbio-attack-ElCalafate-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='El Calafate', Altitude = CasAltitude()}),
    DirectorCapability:new({name='rioturbio-attack-ElCalafate-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='El Calafate', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='rioturbio-patrol-ElCalafate-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),
})

zones.puertonatales:addGroups({
    DirectorCapability:new({name='puertonatales-supply-PuntaArenas-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Punta Arenas'}),
    DirectorCapability:new({name='puertonatales-supply-PuntaArenas-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Punta Arenas'}),
    DirectorCapability:new({name='puertonatales-supply-RioTurbio-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Turbio'}),
    DirectorCapability:new({name='puertonatales-supply-RioTurbio-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Turbio'}),
    DirectorCapability:new({name='puertonatales-supply-ElCalafate-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='El Calafate'}),
    DirectorCapability:new({name='puertonatales-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),

    DirectorCapability:new({name='puertonatales-attack-PuntaArenas-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puertonatales-attack-PuntaArenas-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Punta Arenas', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puertonatales-attack-PuntaArenas-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Punta Arenas', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puertonatales-patrol-PuntaArenas-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),

    DirectorCapability:new({name='puertonatales-attack-RioTurbio-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Turbio', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puertonatales-attack-RioTurbio-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Turbio', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puertonatales-attack-RioTurbio-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Turbio', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puertonatales-patrol-RioTurbio-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Turbio', Altitude = CapAltitude()}),

    DirectorCapability:new({name='puertonatales-attack-ElCalafate-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puertonatales-attack-ElCalafate-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='El Calafate', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puertonatales-attack-ElCalafate-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='El Calafate', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puertonatales-patrol-ElCalafate-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),
})

zones.farpcalfucura:addGroups({
    DirectorCapability:new({name='farpcalfucura-supply-FARPDrake-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Drake'}),
    DirectorCapability:new({name='farpcalfucura-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),
    DirectorCapability:new({name='farpcalfucura-supply-FARPInacayal-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Inacayal'}),
})

zones.elcalafate:addGroups({
    DirectorCapability:new({name='elcalafate-supply-FARPDrake-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Drake'}),
    DirectorCapability:new({name='elcalafate-supply-RioTurbio-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Turbio'}),
    DirectorCapability:new({name='elcalafate-supply-RioTurbio-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Turbio'}),
    DirectorCapability:new({name='elcalafate-supply-PuertoNatales-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Natales'}),
    DirectorCapability:new({name='elcalafate-supply-PuertoNatales-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Natales'}),
    DirectorCapability:new({name='elcalafate-supply-FARPCalfucura-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Calfucura'}),
    DirectorCapability:new({name='elcalafate-supply-FARPInacayal-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Inacayal'}),
    DirectorCapability:new({name='elcalafate-supply-GobernadorGregores-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Gobernador Gregores'}),
    DirectorCapability:new({name='elcalafate-supply-GobernadorGregores-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Gobernador Gregores'}),

    DirectorCapability:new({name='elcalafate-attack-FARPDrake-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Drake', Altitude = CapAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-FARPDrake-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Drake', Altitude = CasAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-FARPDrake-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Drake', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='elcalafate-patrol-FARPDrake-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Drake', Altitude = CapAltitude()}),

    DirectorCapability:new({name='elcalafate-attack-RioTurbio-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Turbio', Altitude = CapAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-RioTurbio-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Turbio', Altitude = CasAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-RioTurbio-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Turbio', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='elcalafate-patrol-RioTurbio-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Turbio', Altitude = CapAltitude()}),

    DirectorCapability:new({name='elcalafate-attack-PuertoNatales-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-PuertoNatales-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Natales', Altitude = CasAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-PuertoNatales-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Natales', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='elcalafate-patrol-PuertoNatales-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),

    DirectorCapability:new({name='elcalafate-attack-FARPCalfucura-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Calfucura', Altitude = CapAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-FARPCalfucura-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Calfucura', Altitude = CasAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-FARPCalfucura-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Calfucura', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='elcalafate-patrol-FARPCalfucura-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Calfucura', Altitude = CapAltitude()}),

    DirectorCapability:new({name='elcalafate-attack-FARPInacayal-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Inacayal', Altitude = CapAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-FARPInacayal-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Inacayal', Altitude = CasAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-FARPInacayal-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Inacayal', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='elcalafate-patrol-FARPInacayal-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Inacayal', Altitude = CapAltitude()}),

    DirectorCapability:new({name='elcalafate-attack-GobernadorGregores-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gobernador Gregores', Altitude = CapAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-GobernadorGregores-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Gobernador Gregores', Altitude = CasAltitude()}),
    DirectorCapability:new({name='elcalafate-attack-GobernadorGregores-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Gobernador Gregores', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='elcalafate-patrol-GobernadorGregores-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gobernador Gregores', Altitude = CapAltitude()}),
})

zones.farpinacayal:addGroups({
    DirectorCapability:new({name='farpinacayal-supply-FARPCalfucura-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Calfucura'}),
    DirectorCapability:new({name='farpinacayal-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),
    DirectorCapability:new({name='farpinacayal-supply-FARPGalvarino-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Galvarino'}),
})

zones.comandanteluispiedrabuena:addGroups({
    DirectorCapability:new({name='comandanteluispiedrabuena-supply-PuertoSantaCruz-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Santa Cruz'}),
    DirectorCapability:new({name='comandanteluispiedrabuena-supply-PuertoSantaCruz-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Santa Cruz'}),
    DirectorCapability:new({name='comandanteluispiedrabuena-supply-SanJulian-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='San Julian'}),
    DirectorCapability:new({name='comandanteluispiedrabuena-supply-SanJulian-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Julian'}),

    DirectorCapability:new({name='comandanteluispiedrabuena-attack-PuertoSantaCruz-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Santa Cruz', Altitude = CapAltitude()}),
    DirectorCapability:new({name='comandanteluispiedrabuena-attack-PuertoSantaCruz-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Santa Cruz', Altitude = CasAltitude()}),
    DirectorCapability:new({name='comandanteluispiedrabuena-attack-PuertoSantaCruz-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Santa Cruz', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='comandanteluispiedrabuena-patrol-PuertoSantaCruz-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Santa Cruz', Altitude = CapAltitude()}),

    DirectorCapability:new({name='comandanteluispiedrabuena-attack-SanJulian-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Julian', Altitude = CapAltitude()}),
    DirectorCapability:new({name='comandanteluispiedrabuena-attack-SanJulian-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='San Julian', Altitude = CasAltitude()}),
    DirectorCapability:new({name='comandanteluispiedrabuena-attack-SanJulian-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='San Julian', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='comandanteluispiedrabuena-patrol-SanJulian-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Julian', Altitude = CapAltitude()}),
})

zones.puertosantacruz:addGroups({
    DirectorCapability:new({name='puertosantacruz-supply-ComandanteLuisPiedrabuena-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Comandante Luis Piedrabuena'}),
    DirectorCapability:new({name='puertosantacruz-supply-ComandanteLuisPiedrabuena-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Comandante Luis Piedrabuena'}),
    DirectorCapability:new({name='puertosantacruz-supply-FARPGalvarino-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Galvarino'}),
    DirectorCapability:new({name='puertosantacruz-supply-GobernadorGregores-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Gobernador Gregores'}),
    DirectorCapability:new({name='puertosantacruz-supply-GobernadorGregores-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Gobernador Gregores'}),

    DirectorCapability:new({name='puertosantacruz-attack-ComandanteLuisPiedrabuena-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Comandante Luis Piedrabuena', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puertosantacruz-attack-ComandanteLuisPiedrabuena-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Comandante Luis Piedrabuena', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puertosantacruz-attack-ComandanteLuisPiedrabuena-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Comandante Luis Piedrabuena', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puertosantacruz-patrol-ComandanteLuisPiedrabuena-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Comandante Luis Piedrabuena', Altitude = CapAltitude()}),

    DirectorCapability:new({name='puertosantacruz-attack-FARPGalvarino-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Galvarino', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puertosantacruz-attack-FARPGalvarino-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Galvarino', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puertosantacruz-attack-FARPGalvarino-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Galvarino', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puertosantacruz-patrol-FARPGalvarino-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Galvarino', Altitude = CapAltitude()}),

    DirectorCapability:new({name='puertosantacruz-attack-GobernadorGregores-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gobernador Gregores', Altitude = CapAltitude()}),
    DirectorCapability:new({name='puertosantacruz-attack-GobernadorGregores-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Gobernador Gregores', Altitude = CasAltitude()}),
    DirectorCapability:new({name='puertosantacruz-attack-GobernadorGregores-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Gobernador Gregores', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='puertosantacruz-patrol-GobernadorGregores-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gobernador Gregores', Altitude = CapAltitude()}),
})

zones.farpgalvarino:addGroups({
    DirectorCapability:new({name='farpgalvarino-supply-FARPInacayal-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Inacayal'}),
    DirectorCapability:new({name='farpgalvarino-supply-PuertoSantaCruz-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Santa Cruz'}),
    DirectorCapability:new({name='farpgalvarino-supply-FARPMagellan-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Magellan'}),
})

zones.sanjulian:addGroups({
    DirectorCapability:new({name='sanjulian-supply-RioGallegos-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Gallegos'}),
    DirectorCapability:new({name='sanjulian-supply-RioGallegos-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Gallegos'}),
    DirectorCapability:new({name='sanjulian-supply-ComandanteLuisPiedrabuena-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Comandante Luis Piedrabuena'}),
    DirectorCapability:new({name='sanjulian-supply-ComandanteLuisPiedrabuena-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Comandante Luis Piedrabuena'}),
    DirectorCapability:new({name='sanjulian-supply-FARPMagellan-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Magellan'}),
    DirectorCapability:new({name='sanjulian-supply-FARPGuemes-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Guemes'}),

    DirectorCapability:new({name='sanjulian-attack-RioGallegos-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Gallegos', Altitude = CapAltitude()}),
    DirectorCapability:new({name='sanjulian-attack-RioGallegos-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Gallegos', Altitude = CasAltitude()}),
    DirectorCapability:new({name='sanjulian-attack-RioGallegos-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Gallegos', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='sanjulian-patrol-RioGallegos-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Gallegos', Altitude = CapAltitude()}),

    DirectorCapability:new({name='sanjulian-attack-ComandanteLuisPiedrabuena-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Comandante Luis Piedrabuena', Altitude = CapAltitude()}),
    DirectorCapability:new({name='sanjulian-attack-ComandanteLuisPiedrabuena-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Comandante Luis Piedrabuena', Altitude = CasAltitude()}),
    DirectorCapability:new({name='sanjulian-attack-ComandanteLuisPiedrabuena-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Comandante Luis Piedrabuena', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='sanjulian-patrol-ComandanteLuisPiedrabuena-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Comandante Luis Piedrabuena', Altitude = CapAltitude()}),

    DirectorCapability:new({name='sanjulian-attack-FARPMagellan-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Magellan', Altitude = CapAltitude()}),
    DirectorCapability:new({name='sanjulian-attack-FARPMagellan-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Magellan', Altitude = CasAltitude()}),
    DirectorCapability:new({name='sanjulian-attack-FARPMagellan-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Magellan', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='sanjulian-patrol-FARPMagellan-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Magellan', Altitude = CapAltitude()}),

    DirectorCapability:new({name='sanjulian-attack-FARPGuemes-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Guemes', Altitude = CapAltitude()}),
    DirectorCapability:new({name='sanjulian-attack-FARPGuemes-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Guemes', Altitude = CasAltitude()}),
    DirectorCapability:new({name='sanjulian-attack-FARPGuemes-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Guemes', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='sanjulian-patrol-FARPGuemes-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Guemes', Altitude = CapAltitude()}),
})

zones.farpmagellan:addGroups({
    DirectorCapability:new({name='farpmagellan-supply-FARPGalvarino-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Galvarino'}),
    DirectorCapability:new({name='farpmagellan-supply-SanJulian-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Julian'}),
    DirectorCapability:new({name='farpmagellan-supply-FARPGuemes-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Guemes'}),
})

zones.gobernadorgregores:addGroups({
    DirectorCapability:new({name='gobernadorgregores-supply-ElCalafate-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='El Calafate'}),
    DirectorCapability:new({name='gobernadorgregores-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),
    DirectorCapability:new({name='gobernadorgregores-supply-PuertoSantaCruz-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Santa Cruz'}),
    DirectorCapability:new({name='gobernadorgregores-supply-PuertoSantaCruz-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Santa Cruz'}),

    DirectorCapability:new({name='gobernadorgregores-attack-ElCalafate-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),
    DirectorCapability:new({name='gobernadorgregores-attack-ElCalafate-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='El Calafate', Altitude = CasAltitude()}),
    DirectorCapability:new({name='gobernadorgregores-attack-ElCalafate-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='El Calafate', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='gobernadorgregores-patrol-ElCalafate-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),

    DirectorCapability:new({name='gobernadorgregores-attack-PuertoSantaCruz-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Santa Cruz', Altitude = CapAltitude()}),
    DirectorCapability:new({name='gobernadorgregores-attack-PuertoSantaCruz-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Santa Cruz', Altitude = CasAltitude()}),
    DirectorCapability:new({name='gobernadorgregores-attack-PuertoSantaCruz-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Santa Cruz', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='gobernadorgregores-patrol-PuertoSantaCruz-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Santa Cruz', Altitude = CapAltitude()}),
})

zones.farpguemes:addGroups({
    DirectorCapability:new({name='farpguemes-supply-SanJulian-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Julian'}),
    DirectorCapability:new({name='farpguemes-supply-FARPMagellan-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Magellan'}),
    DirectorCapability:new({name='farpguemes-supply-FARPRoca-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Roca'}),
})

zones.farproca:addGroups({
    DirectorCapability:new({name='farproca-supply-FARPGuemes-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Guemes'}),
})

zones.ohiggins:addGroups({
    DirectorCapability:new({name='ohiggins-supply-FARPRoca-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Roca'}),

    DirectorCapability:new({name='ohiggins-attack-FARPRoca-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Roca', Altitude = CapAltitude()}),
    DirectorCapability:new({name='ohiggins-attack-FARPRoca-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Roca', Altitude = CasAltitude()}),
    DirectorCapability:new({name='ohiggins-attack-FARPRoca-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Roca', Altitude = SeadAltitude()}),
    DirectorCapability:new({name='ohiggins-patrol-FARPRoca-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Roca', Altitude = CapAltitude()}),
})
-------------------------------end of GroupCommander Routes-------------------------------

---------------Start of airbase definitions(this is what allows you to spawn at the airbase and allows helos------------------------

zones.mountpleasant.airbaseName = 'Mount Pleasant'

zones.portstanley.airbaseName = 'Port Stanley'
zones.portstanley.LogisticCenter = true

zones.sancarlosfob.airbaseName = 'San Carlos FOB'

zones.goosegreen.airbaseName = 'Goose Green'

zones.riogrande.airbaseName = 'Rio Grande'

zones.ushuaia.airbaseName = 'Ushuaia'

zones.puertonatales.airbaseName = 'Puerto Natales'
zones.hipicoflyingclub.airbaseName = 'Hipico Flying Club'
zones.gullpoint.airbaseName = 'Gull Point'

zones.puertowilliams.airbaseName = 'Puerto Williams'

zones.tolhuin.airbaseName = 'Tolhuin'

zones.pampaguanaco.airbaseName = 'Pampa Guanaco'

zones.almiranteschroeders.airbaseName = 'Almirante Schroeders'

zones.porvenir.airbaseName = 'Porvenir'

zones.puntaarenas.airbaseName = 'Punta Arenas'

zones.francobianco.airbaseName = 'Franco Bianco'

zones.riogallegos.airbaseName = 'Rio Gallegos'

zones.riochico.airbaseName = 'Rio Chico'

zones.rioturbio.airbaseName = 'Rio Turbio'

zones.elcalafate.airbaseName = 'El Calafate'

zones.ohiggins.airbaseName = "O'Higgins"
zones.ohiggins.LogisticCenter = true


zones.gobernadorgregores.airbaseName = 'Gobernador Gregores'

zones.puertosantacruz.airbaseName = 'Puerto Santa Cruz'

zones.comandanteluispiedrabuena.airbaseName = 'Comandante Luis Piedrabuena'

zones.sanjulian.airbaseName = 'San Julian'

zones.farpcaupolican.airbaseName = 'FARP Caupolican'

zones.farpsayhueque.airbaseName = 'FARP Sayhueque'

zones.farplautaro.airbaseName = 'FARP Lautaro'

zones.farpdrake.airbaseName = 'FARP Drake'

zones.farpcalfucura.airbaseName = 'FARP Calfucura'

zones.farpinacayal.airbaseName = 'FARP Inacayal'

zones.farpgalvarino.airbaseName = 'FARP Galvarino'

zones.farpmagellan.airbaseName = 'FARP Magellan'

zones.farpguemes.airbaseName = 'FARP Guemes'

zones.farproca.airbaseName = 'FARP Roca'

--------------------------------------------end Airbase definitions------------------------
for i,v in pairs(zones) do
	bc:addZone(v)
end

---------------------------Begin connections (this is what draws lines between each point--------------------------
-- AIRFIELD NETWORK (BIDIRECTIONAL)
bc:addConnection("Goose Green","Mount Pleasant",true)
bc:addConnection("Goose Green","Gull Point",true)
bc:addConnection("Goose Green","San Carlos FOB",true)
bc:addConnection("Mount Pleasant","Port Stanley",true)
bc:addConnection("Mount Pleasant","San Carlos FOB",true)
bc:addConnection("Port Stanley","San Carlos FOB",true)

bc:addConnection("Tolhuin","Puerto Williams",true)
bc:addConnection("Tolhuin","Ushuaia",true)
bc:addConnection("Tolhuin","Rio Grande",true)
bc:addConnection("Tolhuin","Pampa Guanaco",true)
bc:addConnection("Puerto Williams","Ushuaia",true)
bc:addConnection("Puerto Williams","Pampa Guanaco",true)
bc:addConnection("Ushuaia","Pampa Guanaco",true)
bc:addConnection("Rio Grande","Pampa Guanaco",true)
bc:addConnection("Rio Grande","FARP Caupolican",true)
bc:addConnection("Pampa Guanaco","Almirante Schroeders",true)
bc:addConnection("Pampa Guanaco","FARP Caupolican",true)
bc:addConnection("Almirante Schroeders","Porvenir",true)
bc:addConnection("FARP Caupolican","Punta Arenas",true)
bc:addConnection("FARP Caupolican","FARP Sayhueque",true)
bc:addConnection("Porvenir","Punta Arenas",true)
bc:addConnection("Punta Arenas","Franco Bianco",true)
bc:addConnection("Punta Arenas","Puerto Natales",true)
bc:addConnection("Franco Bianco","FARP Sayhueque",true)
bc:addConnection("Franco Bianco","Rio Gallegos",true)
bc:addConnection("FARP Sayhueque","FARP Lautaro",true)
bc:addConnection("FARP Lautaro","Rio Chico",true)
bc:addConnection("FARP Lautaro","FARP Drake",true)
bc:addConnection("Rio Chico","Rio Gallegos",true)
bc:addConnection("Rio Chico","FARP Drake",true)
bc:addConnection("Rio Gallegos","San Julian",true)
bc:addConnection("FARP Drake","FARP Calfucura",true)
bc:addConnection("FARP Drake","El Calafate",true)
bc:addConnection("Rio Turbio","Puerto Natales",true)
bc:addConnection("Rio Turbio","El Calafate",true)
bc:addConnection("Puerto Natales","El Calafate",true)
bc:addConnection("FARP Calfucura","El Calafate",true)
bc:addConnection("FARP Calfucura","FARP Inacayal",true)
bc:addConnection("El Calafate","FARP Inacayal",true)
bc:addConnection("El Calafate","Gobernador Gregores",true)
bc:addConnection("FARP Inacayal","FARP Galvarino",true)
bc:addConnection("Comandante Luis Piedrabuena","Puerto Santa Cruz",true)
bc:addConnection("Comandante Luis Piedrabuena","San Julian",true)
bc:addConnection("Puerto Santa Cruz","FARP Galvarino",true)
bc:addConnection("Puerto Santa Cruz","Gobernador Gregores",true)
bc:addConnection("FARP Galvarino","FARP Magellan",true)
bc:addConnection("San Julian","FARP Magellan",true)
bc:addConnection("San Julian","FARP Guemes",true)
bc:addConnection("FARP Magellan","FARP Guemes",true)
bc:addConnection("FARP Guemes","FARP Roca",true)
bc:addConnection("FARP Roca","O'Higgins",true)

bc:BlockGroundConvoy("Porvenir","Punta Arenas")
bc:BlockGroundConvoy("Porvenir","Almirante Schroeders")


TheaterInfrastructure = {}
TheaterRegions = {
	{
		id = "falklands_air_network", kind = "island", name = "Falklands Air Network",
		zones = {
			{ name = "Mount Pleasant", role = "core" },
			{ name = "Port Stanley", role = "foothold" },
			{ name = "Goose Green", role = "member" },
			{ name = "San Carlos FOB", role = "member" },
			{ name = "Gull Point", role = "member" },
			{ name = "Island SAM Site", role = "defence" },
		},
	},
	{
		id = "tierra_del_fuego_air_network", kind = "air_network", name = "Tierra del Fuego Air Network",
		zones = {
			{ name = "Rio Grande", role = "core" },
			{ name = "Tolhuin", role = "member" },
			{ name = "Ushuaia", role = "member" },
			{ name = "Puerto Williams", role = "member" },
			{ name = "Pampa Guanaco", role = "member" },
			{ name = "Almirante Schroeders", role = "member" },
			{ name = "FARP Caupolican", role = "member" },
		},
	},
	{
		id = "magellan_corridor", kind = "strategic_corridor", name = "Magellan Corridor",
		zones = {
			{ name = "Rio Gallegos", role = "core" },
			{ name = "Punta Arenas", role = "member" },
			{ name = "Franco Bianco", role = "member" },
			{ name = "Porvenir", role = "member" },
			{ name = "Puerto Natales", role = "member" },
			{ name = "Rio Turbio", role = "member" },
			{ name = "Rio Chico", role = "member" },
			{ name = "FARP Sayhueque", role = "member" },
			{ name = "FARP Lautaro", role = "member" },
			{ name = "FARP Drake", role = "member" },
			{ name = "Rebel Base", role = "member" },
			{ name = "Rebel HQ", role = "member" },
			{ name = "SAM Alpha", role = "defence" },
		},
	},
	{
		id = "western_patagonia_network", kind = "air_network", name = "Western Patagonia Network",
		zones = {
			{ name = "El Calafate", role = "core" },
			{ name = "Gobernador Gregores", role = "member" },
			{ name = "FARP Calfucura", role = "member" },
			{ name = "FARP Inacayal", role = "member" },
			{ name = "Rebel Barracks", role = "member" },
			{ name = "Hipico Flying Club", role = "member" },
			{ name = "SAM Bravo", role = "defence" },
		},
	},
	{
		id = "northern_patagonia_corridor", kind = "strategic_corridor", name = "Northern Patagonia Corridor",
		zones = {
			{ name = "San Julian", role = "core" },
			{ name = "Comandante Luis Piedrabuena", role = "member" },
			{ name = "Puerto Santa Cruz", role = "member" },
			{ name = "O'Higgins", role = "member" },
			{ name = "FARP Galvarino", role = "member" },
			{ name = "FARP Magellan", role = "member" },
			{ name = "FARP Guemes", role = "member" },
			{ name = "FARP Roca", role = "member" },
			{ name = "Rebel Airport", role = "member" },
			{ name = "Rebel Cocaine Farm", role = "member" },
			{ name = "Estancia Darwin", role = "member" },
		},
	},
}

TheaterAreas = {
	{
		id = "falklands",
		kind = "island_network",
		name = "Falklands",
		regions = { "falklands_air_network" },
		zones = {
			{ name = "Mount Pleasant", role = "hub" },
			{ name = "Port Stanley", role = "approach" },
			{ name = "San Carlos FOB", role = "approach" },
			{ name = "Goose Green", role = "support" },
			{ name = "Gull Point", role = "support" },
			{ name = "Island SAM Site", role = "defence" },
		},
	},
	{
		id = "tierra_del_fuego",
		kind = "air_network",
		name = "Tierra del Fuego",
		regions = { "tierra_del_fuego_air_network" },
		zones = {
			{ name = "Rio Grande", role = "hub" },
			{ name = "Ushuaia", role = "hub" },
			{ name = "Tolhuin", role = "hub" },
			{ name = "Pampa Guanaco", role = "hub" },
			{ name = "Puerto Williams", role = "hub" },
			{ name = "Almirante Schroeders", role = "gateway" },
			{ name = "FARP Caupolican", role = "gateway" },
		},
	},
	{
		id = "magellan",
		kind = "strategic_corridor",
		name = "Magellan Corridor",
		regions = { "magellan_corridor" },
		zones = {
			{ name = "Rio Gallegos", role = "hub" },
			{ name = "Punta Arenas", role = "hub" },
			{ name = "Franco Bianco", role = "hub" },
			{ name = "Puerto Natales", role = "gateway" },
			{ name = "Rio Turbio", role = "hub" },
			{ name = "Rio Chico", role = "support" },
			{ name = "Porvenir", role = "gateway" },
			{ name = "FARP Drake", role = "gateway" },
			{ name = "FARP Sayhueque", role = "gateway" },
			{ name = "FARP Lautaro", role = "support" },
			{ name = "Rebel Base", role = "support" },
			{ name = "Rebel HQ", role = "support" },
			{ name = "SAM Alpha", role = "defence" },
		},
	},
	{
		id = "western_patagonia",
		kind = "air_network",
		name = "Western Patagonia",
		regions = { "western_patagonia_network" },
		zones = {
			{ name = "El Calafate", role = "hub" },
			{ name = "Gobernador Gregores", role = "gateway" },
			{ name = "Hipico Flying Club", role = "support" },
			{ name = "FARP Calfucura", role = "support" },
			{ name = "FARP Inacayal", role = "gateway" },
			{ name = "Rebel Barracks", role = "support" },
			{ name = "SAM Bravo", role = "defence" },
		},
	},
	{
		id = "northern_patagonia",
		kind = "strategic_corridor",
		name = "Northern Patagonia",
		regions = { "northern_patagonia_corridor" },
		zones = {
			{ name = "San Julian", role = "hub" },
			{ name = "Comandante Luis Piedrabuena", role = "hub" },
			{ name = "Puerto Santa Cruz", role = "gateway" },
			{ name = "O'Higgins", role = "hub" },
			{ name = "FARP Galvarino", role = "gateway" },
			{ name = "FARP Magellan", role = "support" },
			{ name = "FARP Guemes", role = "support" },
			{ name = "FARP Roca", role = "support" },
			{ name = "Rebel Airport", role = "support" },
			{ name = "Rebel Cocaine Farm", role = "support" },
			{ name = "Estancia Darwin", role = "support" },
		},
	},
}

zones.estanciadarwin:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Estancia Darwin"),20)
end, 'disableestanciadarwin', nil, {disablesZone = true})



zones.rebelhq:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Rebel HQ"),20)
end, 'disablerebelhq', nil, {disablesZone = true})

zones.rebelbase:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Rebel Base"),20)
end, 'disablerebelbase', nil, {disablesZone = true})

zones.islandsamsite:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "the Island SAM Site"),20)
end, 'disableislandsamsite', nil, {disablesZone = true})

zones.samalpha:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "SAM Alpha"),20)
end, 'disablesamalpha', nil, {disablesZone = true})

zones.sambravo:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "SAM Bravo"),20)
end, 'disablesambravo', nil, {disablesZone = true})

zones.rebelbarracks:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Rebel Barracks"),20)
end, 'disablerebelbarracks', nil, {disablesZone = true})

zones.rebelairport:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Rebel Airport"),20)
end, 'disablerebelairport', nil, {disablesZone = true})

zones.rebelcocainefarm:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Rebel Cocaine Farm"),20)
end, 'disablerebelcocainefarm', nil, {disablesZone = true})


local CarrierNavRefreshZones = {
	["Red Carrier North"] = true,
	["Red Carrier South"] = true,
}

local CarrierNavAutoRoute = {
	"CVN72_AREA_FALKLAND",
	"CVN72_AREA_TRANSITION_1",
	"CVN72_AREA_TRANSITION_2",
	"CVN72_AREA_RED_SOUTH",
	"CVN72_AREA_TRANSITION_3",
	"CVN72_AREA_RED_NORTH",
}

local CarrierNavAutoRouteIndex = {}
for i, areaName in ipairs(CarrierNavAutoRoute) do
	CarrierNavAutoRouteIndex[areaName] = i
end

local function getCarrierNavigationAreaAtPoint(point)
	if point then
		local areaName = bc:_carrierNavigationResolveAreaForPoint({ x = point.x, y = 0, z = point.z })
		if areaName and CarrierNavAutoRouteIndex[areaName] then return areaName end
	end

	local state = bc.carrierNavigation and bc.carrierNavigation["CVN-72"] or nil
	if type(state) == "table" and state.currentArea and CarrierNavAutoRouteIndex[state.currentArea] then
		return state.currentArea
	end

	local areaName = bc:_getCarrierNavigationAutoCurrentAreaName()
	if areaName and CarrierNavAutoRouteIndex[areaName] then return areaName end

	return "CVN72_AREA_FALKLAND"
end

local function buildCarrierNavigationVia(targetAreaName, startPoint)
	local targetIndex = CarrierNavAutoRouteIndex[targetAreaName]
	if not targetIndex then return nil end

	local currentAreaName = getCarrierNavigationAreaAtPoint(startPoint)
	local currentIndex = CarrierNavAutoRouteIndex[currentAreaName] or 1
	local via = {}

	if currentIndex < targetIndex then
		for i = currentIndex + 1, targetIndex - 1 do
			via[#via + 1] = CarrierNavAutoRoute[i]
		end
	elseif currentIndex > targetIndex then
		for i = currentIndex - 1, targetIndex + 1, -1 do
			via[#via + 1] = CarrierNavAutoRoute[i]
		end
	end

	if #via == 0 then return nil end
	return via
end

local BaseCarrierNavigationGetViaStation = bc._carrierNavigationGetViaStation
function bc:_carrierNavigationGetViaStation(area, lane, startPoint)
	if area and CarrierNavAutoRouteIndex[area.name] then
		if area.zone and startPoint and area.zone:isInside({ x = startPoint.x, y = 0, z = startPoint.z }) then
			return nil
		end

		local viaNames = buildCarrierNavigationVia(area.name, startPoint)
		if not viaNames then return nil end

		local stations = {}
		for _, name in ipairs(viaNames) do
			local viaArea = self:_findCarrierNavigationAreaByName(name)
			if not viaArea or not self:_isCarrierNavigationAreaAllowed(viaArea) then return nil end
			if viaArea[lane] then
				stations[#stations + 1] = viaArea[lane]
			end
		end
		if #stations == 0 then return nil end
		return stations
	end

	return BaseCarrierNavigationGetViaStation(self, area, lane, startPoint)
end

local function updateCarrierNavigationAreas(changedZone)
	if changedZone and not CarrierNavRefreshZones[changedZone] then return end

	local redCarrierSouthClear = not bc:getZoneByName("Red Carrier South").active
	local redCarrierNorthClear = not bc:getZoneByName("Red Carrier North").active
	local redNorthUnlocked = redCarrierSouthClear and redCarrierNorthClear

	bc:setCarrierNavigationAutoRoute(CarrierNavAutoRoute)

	bc:setCarrierNavigationAreaAvailability({
		CVN72_AREA_FALKLAND = true,
		CVN72_AREA_TRANSITION_1 = {
			available = redCarrierSouthClear,
			transit = true,
		},
		CVN72_AREA_TRANSITION_2 = {
			available = redCarrierSouthClear,
			transit = true,
		},
		CVN72_AREA_RED_SOUTH = {
			available = redCarrierSouthClear,
			via = buildCarrierNavigationVia("CVN72_AREA_RED_SOUTH"),
			entry = 2,
			autoMove = redCarrierSouthClear,
		},
		CVN72_AREA_TRANSITION_3 = {
			available = redNorthUnlocked,
			transit = true,
		},
		CVN72_AREA_RED_NORTH = {
			available = redNorthUnlocked,
			via = buildCarrierNavigationVia("CVN72_AREA_RED_NORTH"),
			entry = 2,
			autoMove = redNorthUnlocked,
		},
	}, false)
end

function SpawnFriendlyAssets(changedZone)

	if zones.redcarrier.side == 2 then zones.redcarrier:disableZone(true) end
	if zones.redcarrier2.side == 2 then zones.redcarrier2:disableZone(true) end
	if zones.redcarrier.side == 0 then zones.redcarrier:disableZone(true) end
	if zones.redcarrier2.side == 0 then zones.redcarrier2:disableZone(true) end


	updateCarrierNavigationAreas(changedZone)
end

----------------------------end connections --------------------------------

local missionCompleted = false
local missionCheckReady = false
local checkMissionComplete = function(event, sender)
	if missionCompleted then return end
	-- The scheduled startup check runs after saved ownership is restored.
	if event == nil then missionCheckReady = true end
	local missionFailed = missionCheckReady and GlobalSettings.pvpEnabled ~= true
	local done = true
	for _, v in ipairs(bc:getZones()) do
		local side = v.side
		if (done and side == 1 or missionFailed and side == 2) and not v.zone:lower():find("hidden") then
			if side == 1 then done = false else missionFailed = false end
			if not done and not missionFailed then return end
		end
	end
	if missionFailed and trigger.misc.getUserFlag(180) ~= 0 then return end
	if missionFailed then
		missionCompleted = true
		trigger.action.setUserFlag(180, true)
		trigger.action.outText("Mission failed, Server restarting...", 120)
		bc._persistenceResetPending = true
		Utils.saveTable(bc.saveFile, 'zonePersistance', {})
		if resetSaveFileAndFarp then resetSaveFileAndFarp() end
		timer.scheduleFunction(function()
			trigger.action.setUserFlag(181, true)
		end, {}, timer.getTime() + 5)
		return
	end
	if done then
		missionCompleted = true
		trigger.action.setUserFlag(180, true)
		trigger.action.outText(L10N:Get("SA_SETUP_MISSION_COMPLETE_MENU"), 120)

		timer.scheduleFunction(function()
			trigger.action.outSoundForCoalition(2, "BH.ogg")
		end, {}, timer.getTime() + 5)

			local subMenu = missionCommands.addSubMenuForCoalition(2, L10N:Get("SA_SETUP_RESTART_MENU"), nil)
			missionCommands.addCommandForCoalition(2, L10N:Get("COMMON_YES"), subMenu, function()
					Utils.saveTable(bc.saveFile, 'zonePersistance', {})
					if resetSaveFileAndFarp then
					resetSaveFileAndFarp()
					end
				trigger.action.outText(L10N:Get("SA_SETUP_RESTARTING_NOW"), 120)
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
	v:registerTrigger('destroyed', checkMissionComplete, 'missioncompleted')
end

timer.scheduleFunction(function()
	checkMissionComplete(nil, nil)

	local roamPrefixes = {
		"Red Armour Group",
		"Red SAM AAA #",
		"Red SAM AAA 2 #",
		"Red SAM AAA 3 #",
		"Red SAM AAA 4 #",
		"Red SAM AAA 5 #",
		"Red SAM AAA 6 #",
		"Red SAM AAA 7 #",
		"Red SAM AAA 8 #",
		"Red SAM AAA 9 #",
		"Red SAM AAA 10 #",
		"Red SAM AAA Vietnam",
		"Red SAM SHORAD",
		"Red Armor Group",
		"Red Mech group",
		"Red Special",
	}
	if not DisableZonePatrol then bc:roamGroupsToLocalSubZone(roamPrefixes, 50, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 }) end
	bc:roamGroupsToLocalSubZone({
		'Molniya #',
		'Rezky #',
		'SpeedBoats #',
		'Grisha #',
		'MissileBoat #',
		'FacLa #',
	}, 30, nil, { groupMin = 60, groupMax = 180, zoneMin = 120, zoneMax = 360, cycleMin = 3600, cycleMax = 3600, carrierRangeNm = 120 })
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
  advancecapture = 500,
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
  strategicbomber = 1500,
  zhawk         = 2000, -- HAWK zone upgrade
  zavenger      = 1000, -- Avenger zone upgrade
  zroland       = 1000, -- Roland zone upgrade
  zgepard       = 750, -- Gepard zone upgrade
  zvulcan       = 500, -- Vulcan zone upgrade
  zcram         = 1500, -- C-RAM zone upgrade
  zwhrepair     = 2000,
  zsup3         = 750,
  zgci          = 500,
  dynamicstatic = 500,
  calav         = 100,
  camgs         = 100,
  cadragoon     = 100,
}

local SHOP_RANK_DEFAULTS = {
  jtac           = 2,
  dynamiccap     = 2,
  dynamiccas     = 5,
  dynamicbomb    = 4,
  dynamicsead    = 4,
  groundattack   = 5,
  dynamicdecoy   = 1,
  dynamicarco    = 3,
  dynamictexaco  = 3,
  farphere       = 4,
  capture        = 1,
  advancecapture = 1,
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
  strategicbomber = 6,
  zhawk         = 6, -- HAWK zone upgrade
  zavenger      = 5, -- Avenger zone upgrade
  zroland       = 5, -- Roland zone upgrade
  zgepard       = 4, -- Gepard zone upgrade
  zvulcan       = 3, -- Vulcan zone upgrade
  zcram         = 6, -- C-RAM zone upgrade
  zsup3          = 2,
  zgci           = 8,
  dynamicstatic  = 4,
  calav          = 3,
  camgs          = 3,
  cadragoon      = 3,
}

local function mergeDefaults(defaults, overrides)
  local out = {}
  for k, v in pairs(defaults) do out[k] = v end
  for k, v in pairs(overrides or {}) do out[k] = v end
  return out
end

ShopPrices = mergeDefaults(SHOP_PRICE_DEFAULTS, ShopPrices)
ShopRankRequirements = mergeDefaults(SHOP_RANK_DEFAULTS, ShopRankRequirements)

bc:addMonitoredROE('cruise1')
bc:registerShopItem('cruisemsl', LTGet("SA_SHOP_ITEM_CRUISE_MISSILE"), ShopPrices.cruisemsl, function(sender)
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function (sender, params)
	if params.zone and params.zone.side == 1 then
		local err = bc:fireAtZone(params.zone.zone, 'cruise1', true, 8)
		if err then
			return err
		end

		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_LAUNCHING_CRUISE", params.zone.zone), 15)
	else
		return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
end)
bc.shopItems['cruisemsl'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
}


bc:registerShopItem('dynamiccap', LTGet("SA_SHOP_ITEM_CAP_FLIGHT"), ShopPrices.dynamiccap, function(sender)
    if capActive then
        return LTFormat("SA_SHOP_MISSION_STILL_PROGRESS", "CAP")
    end
		if capParentMenu then
		return LTGet("SA_SHOP_CHOOSE_SPAWN_ZONE")
	end
    buildCapMenu()
	trigger.action.outTextForCoalition(2, L10N:Get("SA_SHOP_CAP_REQUESTED"), 20)
    return
end,
function (sender, params)
    if capActive then
        return LTFormat("SA_SHOP_MISSION_STILL_PROGRESS", "CAP")
    end
    if params and params.zone then
        if params.zone.side ~= 2 or params.zone.suspended then
            return LTGet("SA_SHOP_CAN_ONLY_SPAWN_FRIENDLY")
        end
        spawnCapAt(params.zone.zone, tonumber(params.heading) or 45, tonumber(params.leg) or 0)
        return
    end
    buildCapMenu()

	trigger.action.outTextForCoalition(2, L10N:Get("SA_SHOP_CAP_REQUESTED"), 20)
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
	emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

bc:registerShopItem('dynamicarco', LTGet("SA_SHOP_ITEM_TANKER_DROGUE"), ShopPrices.dynamicarco, function(sender)
    if ArcoActive then
        return LTFormat("SA_SHOP_AIRCRAFT_STILL_AIRBORNE", "Arco")
    end
		if ArcoParentMenu then
		return LTGet("SA_SHOP_CHOOSE_SPAWN_ZONE")
	end
    buildArcoMenu()
	trigger.action.outTextForCoalition(2, L10N:Get("SA_SHOP_TANKER_DROGUE_UNLOCKED"), 20)
    return
end,
function (sender, params)
    if ArcoActive then
        return LTFormat("SA_SHOP_AIRCRAFT_STILL_AIRBORNE", "Arco")
    end
    if params and params.zone then
        if params.zone.side ~= 2 then
            return LTGet("SA_SHOP_CAN_ONLY_SPAWN_FRIENDLY")
        end
        spawnArcoAt(params.zone.zone, tonumber(params.heading) or 45, tonumber(params.leg) or 0)
        return
    end
    buildArcoMenu()

	trigger.action.outTextForCoalition(2, L10N:Get("SA_SHOP_TANKER_DROGUE_UNLOCKED"), 20)
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
	emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

bc:registerShopItem('dynamictexaco', LTGet("SA_SHOP_ITEM_TANKER_BOOM"), ShopPrices.dynamictexaco, function(sender)
    if TexacoActive then
        return LTFormat("SA_SHOP_AIRCRAFT_STILL_AIRBORNE", "Texaco")
    end
		if TexacoParentMenu then
		return LTGet("SA_SHOP_CHOOSE_SPAWN_ZONE")
	end
    buildTexacoMenu()
	trigger.action.outTextForCoalition(2, L10N:Get("SA_SHOP_TANKER_BOOM_UNLOCKED"), 20)
    return
end,
function (sender, params)
    if TexacoActive then
        return LTFormat("SA_SHOP_AIRCRAFT_STILL_AIRBORNE", "Texaco")
    end
    if params and params.zone then
        if params.zone.side ~= 2 then
            return LTGet("SA_SHOP_CAN_ONLY_SPAWN_FRIENDLY")
        end
        spawnTexacoAt(params.zone.zone, tonumber(params.heading) or 45, tonumber(params.leg) or 0)
        return
    end
    buildTexacoMenu()

	trigger.action.outTextForCoalition(2, L10N:Get("SA_SHOP_TANKER_BOOM_UNLOCKED"), 20)
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
	emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}
---

bc:registerShopItem('dynamiccas', LTGet("SA_SHOP_ITEM_CAS_FLIGHT"), ShopPrices.dynamiccas,
function(sender)
    if casActive then
        return LTFormat("SA_SHOP_MISSION_STILL_PROGRESS", "CAS")
    end
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if casActive then return LTFormat("SA_SHOP_MISSION_STILL_PROGRESS", "CAS") end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return LTFormat("SA_SHOP_NO_FRIENDLY_SPAWN", "CAS")
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnCasAt(closestBlue, params.zone.zone, offset)
        return
    else
        return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['dynamiccas'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
	end,
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
}

bc:registerShopItem('dynamicdecoy', LTGet("SA_SHOP_ITEM_TALD_DECOY"), ShopPrices.dynamicdecoy,
function(sender)
    if decoyActive then
        return function(T)
			local Tr = LT(T)
			return Tr:Format("SA_SHOP_MISSION_STILL_PROGRESS", Tr:Get("SA_SHOP_LABEL_DECOY"))
		end
    end
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if decoyActive then
            return function(T)
				local Tr = LT(T)
				return Tr:Format("SA_SHOP_MISSION_STILL_PROGRESS", Tr:Get("SA_SHOP_LABEL_DECOY"))
			end
        end
        local minNM = 40
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return function(T)
				local Tr = LT(T)
				return Tr:Format("SA_SHOP_NO_FRIENDLY_SPAWN", Tr:Get("SA_SHOP_LABEL_DECOY"))
			end
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnDecoyAt(closestBlue, params.zone.zone, offset)
        return
    else
        return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['dynamicdecoy'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
	end,
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
}


bc:registerShopItem('dynamicsead', LTGet("SA_SHOP_ITEM_SEAD_FLIGHT"), ShopPrices.dynamicsead,
function(sender)
    if seadActive then
        return LTFormat("SA_SHOP_MISSION_STILL_PROGRESS", "SEAD")
    end
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if seadActive then
            return LTFormat("SA_SHOP_MISSION_STILL_PROGRESS", "SEAD")
        end
        local minNM = 40
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return LTFormat("SA_SHOP_NO_FRIENDLY_SPAWN", "SEAD")
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnSeadAt(closestBlue, params.zone.zone, offset)
        return
    else
        return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['dynamicsead'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
	end,
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
}

bc:registerShopItem('dynamicbomb', LTGet("SA_SHOP_ITEM_BOMBER_FLIGHT"), ShopPrices.dynamicbomb,
function(sender)
    if bomberActive then
        return function(T)
			local Tr = LT(T)
			return Tr:Format("SA_SHOP_MISSION_STILL_PROGRESS", Tr:Get("SA_SHOP_LABEL_BOMB"))
		end
    end
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        if bomberActive then
            return function(T)
				local Tr = LT(T)
				return Tr:Format("SA_SHOP_MISSION_STILL_PROGRESS", Tr:Get("SA_SHOP_LABEL_BOMB_RUN"))
			end
        end
        local minNM = 25
        local closestBlue, dist = findClosestBlueZoneOutside(params.zone.zone, minNM)
        if not closestBlue then
            return function(T)
				local Tr = LT(T)
				return Tr:Format("SA_SHOP_NO_FRIENDLY_SPAWN", Tr:Get("SA_SHOP_LABEL_BOMB_RUN_LOWER"))
			end
        end
        local offset = (dist and dist < minNM) and (minNM - dist) or 0
        spawnBomberAt(closestBlue, params.zone.zone, offset)
        return
    else
        return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['dynamicbomb'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	allow = function(zoneObj)
		return zoneObj.side == 1
	end,
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
}

bc:registerShopItem('dynamicstatic', LTGet("CA_SHOP_ITEM_STATIC_STRUCTURE"), ShopPrices.dynamicstatic,
function(sender)
    if StructureActive then
        return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "building strike")
    end
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and bc.shopItems['dynamicstatic'].groupZoneSelector.allow(params.zone) then
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
			and ((zoneObj.warehouseFacility and zoneObj:_getWarehouseTarget() ~= nil)
				or (UseStatics == true and zoneObj.newStatics and next(zoneObj.newStatics) ~= nil))
	end,
	emptyLabel = LTGet("CA_SHOP_NO_VALID_BUILDING_TARGET_ZONES"),
}
---------------------------------------------END DYNAMIC SHOP ------------------------------------------

local upgradeMenu = nil
local function clearFriendlySupplyMenu()
    if upgradeMenu then
        missionCommands.removeItemForCoalition(2, upgradeMenu)
        upgradeMenu = nil
    end
end

bc:registerShopItem('supplies2', LTGet("SA_SHOP_ITEM_RESUPPLY_ZONE"), ShopPrices.supplies2, function(sender)
    if not AllowScriptedSupplies and NoAIBlueSupplies == true then
        return LTGet("SA_SHOP_BLUE_AI_SUPPLIES_DISABLED")
    end
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender, params)
    if not AllowScriptedSupplies then
        if NoAIBlueSupplies == true then
            return LTGet("SA_SHOP_BLUE_AI_SUPPLIES_DISABLED")
        end
        if params.zone then
            return bc:requestFriendlySupplyMission(params.zone, params)
        end
        return LTGet("SA_SHOP_CAN_ONLY_TARGET_FRIENDLY")
    elseif params.zone and params.zone.side == 2 and not params.zone.suspended then
        if not params.zone:upgrade() then
            return LTGet("SA_SHOP_ZONE_NO_RESUPPLY")
        end
    else
        return LTGet("SA_SHOP_CAN_ONLY_TARGET_FRIENDLY")
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
            local hasFallbackHeloFarp = (not bestCommander) and hasNearbyFriendlyDynamicFarp and (findNearestAvailableSupplyHeliCommander(zoneObj) ~= nil)
            if (canUseFarp and hasFriendlyDynamicFarp) or hasFallbackHeloFarp then
				local T = L10N:ForGroup(groupId)
                local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
                remember(missionCommands.addCommandForGroup(groupId, T:Get("SA_SHOP_DEPLOY_FROM_FARP"), zoneMenu, function() end))
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
    emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

if AllowScriptedSupplies then
local fullyUpgradeMenu=nil
bc:registerShopItem('supplies',LTGet("SA_SHOP_ITEM_FULLY_UPGRADE_ZONE"),ShopPrices.supplies,
function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE_FULLY_UPGRADE")
end,
function(sender,params)
    if params.zone and params.zone.side==2 and not params.zone.suspended then
        local zn=params.zone
        if not zn:UpgradeUntilComplete(function()
            trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_ZONE_FULLY_UPGRADED", params.zone.zone),15)
        end) then
            return L10N:Format("ZONE_ALREADY_FULLY_UPGRADED", params.zone.zone)
        end
    else
        return LTGet("SA_SHOP_CAN_ONLY_TARGET_FRIENDLY")
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
    emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}
end

Group.getByName('ca-tanks-Coldwar'):destroy()
Group.getByName('ca-tanks'):destroy()
tanksMenu = nil
bc:registerShopItem('armor', LTGet("SA_SHOP_ITEM_DEPLOY_ARMOR"), ShopPrices.armor, function(sender)
	return LTGet("SA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		
		local zn = CustomZone:getByName(params.zone.zone)
		if not zn:spawnGroup(ColdWarTechEra and 'ca-tanks-Coldwar' or 'ca-tanks') then return false end
		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_FRIENDLY_ARMOR_DEPLOYED", params.zone.zone), 15)
	else
		return LTGet("SA_SHOP_CAN_ONLY_DEPLOY_FRIENDLY")
	end
end)
bc.shopItems['armor'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}
Group.getByName('ca-arty'):destroy()
artyMenu = nil
bc:registerShopItem('artillery', LTGet("SA_SHOP_ITEM_DEPLOY_ARTILLERY"), ShopPrices.artillery, function(sender)
	return LTGet("SA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		
		local zn = CustomZone:getByName(params.zone.zone)
		if not zn:spawnGroup('ca-arty') then return false end
		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_FRIENDLY_ARTY_DEPLOYED", params.zone.zone), 15)
	else
		return LTGet("SA_SHOP_CAN_ONLY_DEPLOY_FRIENDLY")
	end
end)
bc.shopItems['artillery'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}
Group.getByName('ca-recon'):destroy()
reconMenu = nil
bc:registerShopItem('recon', LTGet("SA_SHOP_ITEM_DEPLOY_RECON"), ShopPrices.recon, function(sender)
	return LTGet("SA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		
		local zn = CustomZone:getByName(params.zone.zone)
		if not zn:spawnGroup('ca-recon') then return false end
		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_FRIENDLY_RECON_DEPLOYED", params.zone.zone), 15)
	else
		return LTGet("SA_SHOP_CAN_ONLY_DEPLOY_FRIENDLY")
	end
end)
bc.shopItems['recon'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}
Group.getByName('ca-airdef'):destroy()
airdefMenu = nil
bc:registerShopItem('airdef', LTGet("SA_SHOP_ITEM_DEPLOY_AIRDEF"), ShopPrices.airdef, function(sender)
	return LTGet("SA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		
		local zn = CustomZone:getByName(params.zone.zone)
		if not zn:spawnGroup('ca-airdef') then return false end
		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_FRIENDLY_AIRDEF_DEPLOYED", params.zone.zone), 15)
	else
		return LTGet("SA_SHOP_CAN_ONLY_DEPLOY_FRIENDLY")
	end
end)
bc.shopItems['airdef'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

local jtacDrones
local jtacTargetMenu = nil
for _,n in ipairs({'jtacDroneColdwar1','jtacDroneColdwar2','jtacDrone1','jtacDrone2'}) do
    local g = Group.getByName(n)
    if g then g:destroy() end
end
Group.getByName('CA-CW-Hunter_Killer_LAV'):destroy()
bc:registerShopItem('calav', LTGet("SA_SHOP_ITEM_DEPLOY_LAV"), ShopPrices.calav, function(sender)
	return LTGet("SA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		local zn = CustomZone:getByName(params.zone.zone)
		if not zn:spawnGroup('CA-CW-Hunter_Killer_LAV') then return false end
		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_FRIENDLY_LAV_DEPLOYED", params.zone.zone), 15)
	else
		return LTGet("SA_SHOP_CAN_ONLY_DEPLOY_FRIENDLY")
	end
end)
bc.shopItems['calav'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

bc.shopItems['calav'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['calav'].groupZoneSelector.refreshTags = { 'friendly_targets' }

Group.getByName('CA-Modern-Hunter_Killer_MGS'):destroy()
bc:registerShopItem('camgs', LTGet("SA_SHOP_ITEM_DEPLOY_MGS"), ShopPrices.camgs, function(sender)
	return LTGet("SA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		local zn = CustomZone:getByName(params.zone.zone)
		if not zn:spawnGroup('CA-Modern-Hunter_Killer_MGS') then return false end
		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_FRIENDLY_MGS_DEPLOYED", params.zone.zone), 15)
	else
		return LTGet("SA_SHOP_CAN_ONLY_DEPLOY_FRIENDLY")
	end
end)
bc.shopItems['camgs'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}

bc.shopItems['camgs'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['camgs'].groupZoneSelector.refreshTags = { 'friendly_targets' }

Group.getByName('CA-Modern-Hunter_Killer_Dragoon'):destroy()
bc:registerShopItem('cadragoon', LTGet("SA_SHOP_ITEM_DEPLOY_DRAGOON"), ShopPrices.cadragoon, function(sender)
	return LTGet("SA_SHOP_CHOOSE_DEPLOY_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		local zn = CustomZone:getByName(params.zone.zone)
		if not zn:spawnGroup('CA-Modern-Hunter_Killer_Dragoon') then return false end
		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_FRIENDLY_DRAGOON_DEPLOYED", params.zone.zone), 15)
	else
		return LTGet("SA_SHOP_CAN_ONLY_DEPLOY_FRIENDLY")
	end
end)
bc.shopItems['cadragoon'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}


bc.shopItems['cadragoon'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['cadragoon'].groupZoneSelector.refreshTags = { 'friendly_targets' }

if Era == 'Coldwar' then
jtacDrones = {JTAC:new({name = 'jtacDroneColdwar1'}),JTAC:new({name = 'jtacDroneColdwar2'})}
else
jtacDrones = {JTAC:new({name = 'jtacDrone1'}),JTAC:new({name = 'jtacDrone2'})}
end
bc:registerShopItem('jtac',LTGet("SA_SHOP_ITEM_JTAC_MQ9"),ShopPrices.jtac,function(sender)
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,function(sender,params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		for _,v in ipairs(jtacQueue) do
			if v.tgtzone and v.tgtzone.zone == params.zone.zone then
				return LTFormat("SA_SHOP_JTAC_ALREADY_ACTIVE", params.zone.zone)
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
			trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_JTAC_TOMCAT_ACTIVE", params.zone.zone, #jtacQueue),15)
		else
			trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_JTAC_REAPER_ACTIVE", params.zone.zone, #jtacQueue),15)
		end
	else
		return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
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
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
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
bc:registerShopItem('9lineam', LTGet("SA_SHOP_ITEM_JTAC_9LINE_AM"), ShopPrices["9lineam"], function(sender)
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        droneAM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = Era == 'Coldwar' and 'JTAC9lineamColdwar' or 'JTAC9lineam'}
		if Era == 'Coldwar' then
			trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_JTAC_TOMCAT_AM", params.zone.zone), 30)
        
    	else
			trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_JTAC_REAPER_AM", params.zone.zone), 30)
		end
    else
        return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['9lineam'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
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
bc:registerShopItem('9linefm', LTGet("SA_SHOP_ITEM_JTAC_9LINE_FM"), ShopPrices["9linefm"], function(sender)
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        droneFM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = Era == 'Coldwar' and 'JTAC9linefmColdwar' or 'JTAC9linefm'}

		if Era == 'Coldwar' then
			trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_JTAC_TOMCAT_FM", params.zone.zone), 30)
        
    	else
			trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_JTAC_REAPER_FM", params.zone.zone), 30)
		end
    else
        return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
    end
end)
bc.shopItems['9linefm'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
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
Group.getByName('RedBomberEvent'):destroy()
Group.getByName('RedBomberEvent_CW'):destroy()
Group.getByName('BlueBomberEvent'):destroy()
Group.getByName('BlueBomberEvent_CW'):destroy()

StrategicBomber.Configure({
	[1] = {
		template = ColdWarTechEra and 'RedBomberEvent_CW' or 'RedBomberEvent',
		escortTemplates = BuildEnabledTemplateList(AllCapPlaneTemplates, RedCapPlaneEnabled),
		displayNameKey = "STRATEGIC_BOMBER_NAME_RED",
		missionId = "bomb",
		targetSide = 2,
		routeAltitudeFt = 25000,
		attackAltitudeFt = 25000,
		weaponExpend = AI.Task.WeaponExpend.HALF,
		holdSpeedKt = 300,
		toIngressSpeedKt = 380,
		afterIngressSpeedKt = 350,
		escortAltitudeFt = 27000,
		pickOptions = {
			weaponExpend = AI.Task.WeaponExpend.HALF,
			attackAltitudeFt = 25000,
			minTargetSpawnNm = 80,
			minPlayerSpawnNm = 80,
			avoidPlayerCoalition = "blue",
			allowSuspendedSpawn = true,
			preferNonSuspendedSpawn = true,
			randomCandidateLimit = 5
		},
		ingressDistanceNm = 25,
		rtbApproachDistanceNm = 30
	},
	[2] = {
		template = ColdWarTechEra and 'BlueBomberEvent_CW' or 'BlueBomberEvent',
		escortTemplates = BuildEnabledTemplateList(AllCapPlaneTemplates, BlueCapPlaneEnabled),
		displayNameKey = ColdWarTechEra and "STRATEGIC_BOMBER_NAME_BLUE_CW" or "STRATEGIC_BOMBER_NAME_BLUE",
		missionId = "bombBlue",
		targetSide = 1,
		routeAltitudeFt = 25000,
		attackAltitudeFt = ColdWarTechEra and 12000 or 25000,
		weaponExpend = AI.Task.WeaponExpend.TWO,
		holdSpeedKt = 300,
		toIngressSpeedKt = 380,
		ingressSpeedKt = 550,
		afterIngressSpeedKt = 350,
		escortAltitudeFt = 27000,
		interceptorTemplates = BuildEnabledTemplateList(AllCapPlaneTemplates, RedCapPlaneEnabled),
		interceptorAltitudeFt = 25000,
		minTargetSpawnNm = 60,
		ingressDistanceNm = 25,
		rtbApproachDistanceNm = 30,
		recoveryZones = {
			"Almirante Schroeders",
			"Comandante Luis Piedrabuena",
			"El Calafate",
			"Franco Bianco",
			"Gobernador Gregores",
			"Goose Green",
			"Mount Pleasant",
			"O'Higgins",
			"Pampa Guanaco",
			"Port Stanley",
			"Porvenir",
			"Puerto Natales",
			"Puerto Santa Cruz",
			"Puerto Williams",
			"Punta Arenas",
			"Rio Chico",
			"Rio Gallegos",
			"Rio Grande",
			"Rio Turbio",
			"San Carlos FOB",
			"San Julian",
			"Tolhuin",
			"Ushuaia",
		},
		recoveryMinRunwayLengthMeters = 2195,
		playerEscortReward = 1000,
		lossPenaltyCredits = 500
	}
})

local strategicBomberShopName = function(T)
	return LT(T):Get("STRATEGIC_BOMBER_SHOP_NAME")
end

bc:registerShopItem('strategicbomber', strategicBomberShopName, ShopPrices.strategicbomber,
function(sender)
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params and params.targetZone and params.originZone then
		return StrategicBomber.LaunchBlue(params)
	end

	local targetZone = params and params.zone
	if type(targetZone) == "string" then
		targetZone = bc:getZoneByName(targetZone)
	end
	if not StrategicBomber.BlueTargetAllowed(targetZone) then
		return LTGet("STRATEGIC_BOMBER_INVALID_TARGET")
	end

	local bestOrigin = nil
	local bestDist = math.huge
	for _, originZone in ipairs(bc:getZones()) do
		if StrategicBomber.BlueOriginAllowed(originZone, targetZone) then
			local dist = DynamicBomber.ZoneDistanceMeters(originZone.zone, targetZone.zone)
			if dist < bestDist then
				bestDist = dist
				bestOrigin = originZone
			end
		end
	end

	if not bestOrigin then
		return LTGet("STRATEGIC_BOMBER_NO_VALID_ORIGIN")
	end

	return StrategicBomber.LaunchBlue({
		targetZone = targetZone,
		originZone = bestOrigin,
		escortMode = "ai"
	})
end)
bc.shopItems['strategicbomber'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	extraPredicate = function(zoneObj)
		if not StrategicBomber.BlueTargetAllowed(zoneObj) then return false end
		for _, originZone in ipairs(bc:getZones()) do
			if StrategicBomber.BlueOriginAllowed(originZone, zoneObj) then
				return true
			end
		end
		return false
	end,
	zoneMenuBuilder = function(bcRef, parentMenu, label, zoneObj, groupId, groupObj, itemInfo, track, rememberHandle)
		return StrategicBomber.BuildBlueShopMenu(bcRef, parentMenu, label, zoneObj, groupId, groupObj, itemInfo, track, rememberHandle)
	end,
	emptyLabel = LTGet("STRATEGIC_BOMBER_NO_VALID_TARGETS"),
}

bc:registerShopItem('groundattack', LTGet("SA_SHOP_ITEM_GROUND_ATTACK"), ShopPrices.groundattack, function(sender)
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended and not isCarrierZoneName(params.zone.zone) then
		return bc:launchPlayerGroundAttack(params.zone, params.allowFarp)
	end
	return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
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
			remember(missionCommands.addCommandForGroup(groupId, T:Get("SA_SHOP_DEPLOY_FROM_FARP"), zoneMenu, function() end))
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
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
}

local smokeTargetMenu = nil
bc:registerShopItem('smoke', LTGet("SA_SHOP_ITEM_SMOKE_MARKERS"), ShopPrices.smoke, function(sender)
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		bc:smokeTargets(params.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_TARGETS_RED_SMOKE", params.zone.zone), 15)
	else
		return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
end)
bc.shopItems['smoke'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
}

local flareTargetMenu = nil
bc:registerShopItem('flare', LTGet("SA_SHOP_ITEM_FLARE_MARKERS"), ShopPrices.flare, function(sender)
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		bc:flareTargets(params.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_TARGETS_RED_FLARE", params.zone.zone), 15)
	else
		return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
end)
bc.shopItems['flare'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
}

local illumTargetMenu = nil
bc:registerShopItem('illum', LTGet("SA_SHOP_ITEM_ILLUMINATION"), ShopPrices.illum, function(sender)
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		bc:illumTargets(params.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_TARGETS_ILLUMINATED", params.zone.zone), 15)
	else
		return LTGet("SA_SHOP_CAN_ONLY_TARGET_ENEMY")
	end
end)
bc.shopItems['illum'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
}

-- new menu
local supplyMenu=nil
bc:registerShopItem('capture',LTGet("SA_SHOP_ITEM_CAPTURE_NEUTRAL"),ShopPrices.capture,
function(sender)
	if NoAIBlueSupplies == true then 
		return LTGet("SA_SHOP_BLUE_AI_SUPPLIES_DISABLED")
	end
	return LTGet("SA_SHOP_CHOOSE_NEUTRAL_ZONE")
end,
function(sender,params)
    if not params.zone or params.zone.side~=0 then
        return LTGet("SA_SHOP_ZONE_NOT_NEUTRAL")
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

		local advanceCaptureMenu = itemInfo and itemInfo.id == 'advancecapture'
		local bestCommander = select(1, findNearestAvailableSupplyCommander(zoneObj, advanceCaptureMenu and { heloOnly = true } or nil))
		local canUseFarp = bestCommander and ((not advanceCaptureMenu and bestCommander.type == 'surface') or bestCommander.unitCategory == Unit.Category.HELICOPTER)
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
			remember(missionCommands.addCommandForGroup(groupId, T:Get("SA_SHOP_DEPLOY_FROM_FARP"), zoneMenu, function() end))
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
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_NEUTRAL_ZONES"),
}

bc:registerShopItem('advancecapture',LTGet("SA_SHOP_ITEM_ADVANCE_CAPTURE"),ShopPrices.advancecapture,
function(sender)
	return LTGet("SA_SHOP_CHOOSE_ADVANCE_CAPTURE_ZONE")
end,
function(sender,params)
    if not params.zone then
        return LTGet("SA_SHOP_ADVANCE_CAPTURE_NOT_ELIGIBLE")
    end
    if not params.zone:canAdvanceCapture() then
        return LTGet("SA_SHOP_ADVANCE_CAPTURE_NOT_ELIGIBLE")
    end
    params.advanceCapture = true
    local chosenZone=bc:getZoneByName(params.zone.zone)
    return bc:requestCaptureMission(chosenZone, params)
end)
bc.shopItems['advancecapture'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	extraPredicate = function(zoneObj)
		return zoneObj:canAdvanceCapture()
	end,
	zoneMenuBuilder = bc.shopItems['capture'].groupZoneSelector.zoneMenuBuilder,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_ADVANCE_CAPTURE_ZONES"),
}
--end of menu

local intelMenu=nil
bc:registerShopItem('intel',LTGet("SA_SHOP_ITEM_INTEL_ENEMY"),ShopPrices.intel,function(sender)
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		intelActiveZones[params.zone.zone] = true
		startZoneIntel(params.zone.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SA_SHOP_GATHERING_INTEL", params.zone.zone), 10)
	else
		return LTGet("SA_SHOP_MUST_PICK_ENEMY_ZONE")
	end
end)
bc.shopItems['intel'].groupZoneSelector = {
	targetzoneside = 1,
	includeSuspended = false,
	sortPolicy = 'enemy_frontline',
	emptyLabel = LTGet("SA_SHOP_NO_VALID_ENEMY_ZONES"),
}

------------------------------------------- Zone upgrades --------------------------------------------
-- red Shop
local RED_ZONE_UPGRADE_ID = "redzoneupgrade"
local RED_ZONE_UPGRADE_COST = 5000

bc:registerShopItem(RED_ZONE_UPGRADE_ID, LTGet("SA_SHOP_ITEM_RED_ZONE_UPGRADE"), RED_ZONE_UPGRADE_COST, function(sender)
	return bc:redZoneUpgradeAction()
end)

local RED_MASS_ATTACK_ID = "redmassattack"
local RED_MASS_ATTACK_COST = 6000

local function redMassAttackAction()
	if not bc.triggerRedMassAttack then
		return LTGet("SA_SHOP_MASS_ATTACK_UNAVAILABLE")
	end
	return bc:triggerRedMassAttack()
end

bc:registerShopItem(RED_MASS_ATTACK_ID, LTGet("SA_SHOP_ITEM_RED_MASS_ATTACK"), RED_MASS_ATTACK_COST, redMassAttackAction)
local RED_STRATEGIC_BOMBER_ID = "strategicbomberRed"

bc:registerShopItem(RED_STRATEGIC_BOMBER_ID, strategicBomberShopName, ShopPrices.strategicbomber, function(sender)
	return StrategicBomber.LaunchRed()
end, nil, 50)
-- end red shop

local redWarehouseMenu = nil
bc:registerShopItem('redwarehouse', LTGet("WAREHOUSE_SHOP_RED_CREATE"), 3000, function(sender)
	if redWarehouseMenu then
		missionCommands.removeItemForCoalition(1, redWarehouseMenu)
		redWarehouseMenu = nil
	end
	local zoneChoices = {}
	for _, zoneObj in ipairs(bc:getZones()) do
		if zoneObj.side == 1 and zoneObj.active and not zoneObj.suspended and not zoneObj.isHidden
			and zoneObj.airbaseName and zoneObj.airbaseName ~= '' and not zoneObj.warehouseFacility
			and not isCarrierZoneName(zoneObj.zone) then
			zoneChoices[zoneObj.zone] = zoneObj
		end
	end
	if not next(zoneChoices) then return LTGet("SA_SHOP_NO_ELIGIBLE_AIRBASE_ZONES") end
	redWarehouseMenu = bc:showTargetZoneMenu(1, LTGet("WAREHOUSE_SHOP_RED_CREATE"), function(zoneName, menu)
		local zoneObj = zoneChoices[zoneName]
		bc:buyShopItem(1, 'redwarehouse', {zone = zoneObj})
		if zoneObj.warehouseFacility then
			missionCommands.removeItemForCoalition(1, menu)
			redWarehouseMenu = nil
		end
		return true -- Keep the selector on failure; successful purchases close it above.
	end, 1, false, zoneChoices)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end, function(sender, params)
	return bc:applyRedWarehouseUpgrade(params.zone, params.placement, params.now)
end)
bc:registerShopItem('redwhrepair', LTGet("WAREHOUSE_SHOP_REPAIR"), 2000, function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end, function(sender, params)
	return bc:applyWarehouseRepair(params.zone, 1, params.now)
end)

local infMenu=nil
bc:registerShopItem('zinf',LTGet("SA_SHOP_ITEM_UPGRADE_INFANTRY"),ShopPrices.zinf,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		local max = 2 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('blueInfantry') -- checked
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock or params.zone.upgradesUsed < max then
		trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED", L10N:Get("SA_SHOP_LABEL_INFANTRY"), params.zone.zone, tostring(ShopPrices.zinf)),10)
		else
		trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED_EXTRA", L10N:Get("SA_SHOP_LABEL_INFANTRY"), params.zone.zone, tostring(ShopPrices.zinf)),30)
		end
	else
		return LTGet("SA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zinf'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_ZONE"),
}
local samLabel = LTGet("SA_SHOP_ITEM_UPGRADE_NASAMS")
bc:registerShopItem('zsam',samLabel,ShopPrices.zsam,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 2 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot(sender.upgradeTemplate)
		bc:refreshZoneLabel(params.zone.zone)
		local sys = sender.upgradeLabel
        if bc.globalExtraUnlock or params.zone.upgradesUsed < max then
            trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED", sys, params.zone.zone, tostring(sender.cost)),10)
        else
            trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED_EXTRA", sys, params.zone.zone, tostring(sender.cost)),30)
        end
	else
		return LTGet("SA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zsam'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_ZONE"),
}
local samItem = bc.shopItems['zsam']
samItem.upgradeTemplate = 'Blue SAM NASAMS'
samItem.upgradeLabel = 'NASAMS'

-- Each defense choice reuses the same purchase action and zone selector.
for _, defense in ipairs({
	{ id = 'zhawk', labelKey = 'SA_SHOP_ITEM_UPGRADE_HAWK', template = 'Blue SAM HAWK', label = 'HAWK' },
	{ id = 'zavenger', labelKey = 'SA_SHOP_ITEM_UPGRADE_AVENGER', template = 'Blue SAM SHORAD Avenger', label = 'Avenger' },
	{ id = 'zroland', labelKey = 'SA_SHOP_ITEM_UPGRADE_ROLAND', template = 'Blue SAM SHORAD Roland', label = 'Roland' },
	{ id = 'zgepard', labelKey = 'SA_SHOP_ITEM_UPGRADE_GEPARD', template = 'Blue SAM AAA Gepard', label = 'Gepard' },
	{ id = 'zvulcan', labelKey = 'SA_SHOP_ITEM_UPGRADE_VULCAN', template = 'Blue SAM AAA Vulcan', label = 'Vulcan' },
	{ id = 'zcram', labelKey = 'SA_SHOP_ITEM_UPGRADE_CRAM', template = 'Blue SAM AAA C-RAM', label = 'C-RAM' },
}) do
	bc:registerShopItem(defense.id, LTGet(defense.labelKey), ShopPrices[defense.id], samItem.action, samItem.altAction)
	local item = bc.shopItems[defense.id]
	item.upgradeTemplate = defense.template
	item.upgradeLabel = defense.label
	item.groupZoneSelector = samItem.groupZoneSelector
end

bc:registerShopItem('zhimars',LTGet("SA_SHOP_ITEM_UPGRADE_HIMARS"),ShopPrices.zhimars,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 2 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('HiMars')
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock or params.zone.upgradesUsed < max then
			trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED", "HIMARS", params.zone.zone, tostring(ShopPrices.zhimars)),10)
		else
			trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED_EXTRA", "HIMARS", params.zone.zone, tostring(ShopPrices.zhimars)),30)
		end
	else
		return LTGet("SA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zhimars'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_ZONE"),
}

local logiMenu=nil
bc:registerShopItem('zlogc',LTGet("SA_SHOP_ITEM_LOGISTIC_CENTER"),ShopPrices.zlogc,function(sender)
	if logiMenu then
		return LTGet("SA_SHOP_ALREADY_CHOOSING_ZONE")
	end
	local allow = bc:buildLogisticAllowTable()
	if not next(allow) then
		return LTGet("SA_SHOP_NO_ELIGIBLE_AIRBASE_ZONES")
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
	logiMenu = bc:showTargetZoneMenu(2,L10N:Get("SA_SHOP_SELECT_LOGISTIC_CENTER"),pickZone,2,nil,allow)
	trigger.action.outTextForCoalition(2,L10N:Get("SA_SHOP_SELECT_FULLY_UPGRADED_AIRBASE"),15)
end,
function(sender,params)
	if params.zone then
		return bc:applyLogisticCenterUpgrade(params.zone)
	end
	return LTGet("SA_SHOP_MUST_PICK_FRIENDLY_ZONE")
end)

bc:registerShopItem('zwhrepair', LTGet("WAREHOUSE_SHOP_REPAIR"), ShopPrices.zwhrepair, function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end, function(sender, params)
	return bc:applyWarehouseRepair(params.zone, 2, timer.getAbsTime())
end)
bc.shopItems['zwhrepair'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = true,
	sortPolicy = 'friendly_frontline',
	candidateBucket = 'blue_visible',
	refreshTags = { 'warehouse_targets' },
	extraPredicate = function(zoneObj)
		return zoneObj.warehouseFacility ~= nil and zoneObj.warehouseFacility.state == 'destroyed'
	end,
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_AIRBASE_ZONES"),
}

bc:registerShopItem('zsup3',LTGet("SA_SHOP_ITEM_ADD_THREE_SUPPLIES"),ShopPrices.zsup3,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone then
		return bc:applyZoneSupplyStockAdd(params.zone, 3)
	end
	return LTGet("SA_SHOP_MUST_PICK_FRIENDLY_ZONE")
end)
bc.shopItems['zsup3'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	candidateBucket = 'zone_supply_targets',
	extraPredicate = function(zoneObj) return bc:canAddZoneSupplyStock(zoneObj) end,
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_SUPPLY_ZONES"),
	refreshTags = { 'friendly_targets', 'warehouse_targets', 'zsup3' },
}

local warehouseMenu=nil
bc:registerShopItem('zwh50',LTGet("SA_SHOP_ITEM_WAREHOUSE_50"),ShopPrices.zwh50,function(sender)
	if not WarehouseLogistics then
		return LTGet("SA_SHOP_WAREHOUSE_LOGISTICS_DISABLED")
	end
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone then
		return bc:applyWarehouseResupply(params.zone)
	end
	return LTGet("SA_SHOP_MUST_PICK_FRIENDLY_ZONE")
end)
bc.shopItems['zwh50'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	candidatesBuilder = function()
		return bc:buildWarehouseResupplyCandidates()
	end,
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_AIRBASE_ZONES"),
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
bc.shopItems['dynamicstatic'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['dynamicstatic'].groupZoneSelector.refreshTags = { 'enemy_targets' }
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
bc.shopItems['advancecapture'].groupZoneSelector.candidateBucket = 'advance_capture_targets'
bc.shopItems['advancecapture'].groupZoneSelector.refreshTags = { 'advance_capture_targets' }
bc.shopItems['intel'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['intel'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['intel'].groupZoneSelector.refreshTagsByCoalition = {
	[2] = { 'enemy_targets' },
	[1] = { 'friendly_targets' },
}
bc.shopItems['zwh50'].groupZoneSelector.candidateBucket = 'warehouse_targets'
bc.shopItems['zwh50'].groupZoneSelector.refreshTags = { 'warehouse_targets' }

local armMenu=nil
bc:registerShopItem('zarm',LTGet("SA_SHOP_ITEM_UPGRADE_ARMOR"),ShopPrices.zarm,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 2 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		local slotID = Era == 'Vietnam' and 'Blue Armor Vietnam' or (Era == 'Coldwar' and 'Blue Armor Coldwar' or 'Blue Armor Modern') -- checked
		params.zone:addExtraSlot(slotID)
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock or params.zone.upgradesUsed < max then
			trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED", L10N:Get("SA_SHOP_LABEL_ARMOR"), params.zone.zone, tostring(ShopPrices.zarm)),10)
		else
			trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED_EXTRA_LINE", L10N:Get("SA_SHOP_LABEL_ARMOR"), params.zone.zone, tostring(ShopPrices.zarm)),30)
		end
	else
		return LTGet("SA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zarm'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_ZONE"),
}
bc.shopItems['zarm'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zarm'].groupZoneSelector.refreshTags = { 'friendly_targets' }

bc:registerShopItem('gslot',LTGet("SA_SHOP_ITEM_EXTRA_SLOT"),ShopPrices.gslot,function(sender)
    if bc.globalExtraUnlock then
        return LTGet("SA_SHOP_ALREADY_UNLOCKED")
    end
    bc.globalExtraUnlock = true
    for _,z in pairs(bc:getZones()) do

    end
    trigger.action.outTextForCoalition(2,L10N:Get("SA_SHOP_ALL_ZONES_SECOND_UPGRADE"),15)
	bc:removeShopItem(2, 'gslot')
	return nil
end)

Group.getByName('Blue SAM PATRIOT'):destroy()
bc:registerShopItem('zpat', LTGet("SA_SHOP_ITEM_UPGRADE_PATRIOT"), ShopPrices.zpat, samItem.action, samItem.altAction)
local patItem = bc.shopItems['zpat']
patItem.upgradeTemplate = 'Blue SAM PATRIOT'
patItem.upgradeLabel = 'PATRIOT'
patItem.groupZoneSelector = samItem.groupZoneSelector
bc.shopItems['zpat'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zpat'].groupZoneSelector.refreshTags = { 'friendly_targets' }

Group.getByName('BlueGCI'):destroy()
bc:registerShopItem('zgci',LTGet("SA_SHOP_ITEM_UPGRADE_GCI"),ShopPrices.zgci,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 2 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('BlueGCI')
		bc:refreshZoneLabel(params.zone.zone)
		bc:requestShopSelectorRefreshForCoalition(2, { 'zgci' })
		if bc.globalExtraUnlock or params.zone.upgradesUsed < max then
			trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED", L10N:Get("SA_SHOP_LABEL_GCI"), params.zone.zone, tostring(ShopPrices.zgci)),10)
		else
			trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED_EXTRA", L10N:Get("SA_SHOP_LABEL_GCI"), params.zone.zone, tostring(ShopPrices.zgci)),30)
		end
	else
		return LTGet("SA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zgci'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_ZONE"),
}
bc.shopItems['zgci'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zgci'].groupZoneSelector.refreshTags = { 'friendly_targets' }

bc:registerShopItem('farphere',LTGet("SA_SHOP_ITEM_DEPLOY_FARP"),ShopPrices.farphere,function(sender)
        return LTGet("SA_SHOP_FARP_MARKER_HELP")
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
	advancecapture = 500, -- Advance capture pressured enemy zone
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
	dynamicarco    = 3,  -- Dynamic Tanker (Drogue)
	dynamictexaco  = 3,  -- Dynamic Tanker (Boom)
	farphere       = 4,  -- Deploy FARP
	capture        = 1,  -- Emergency capture zone
	advancecapture = 1,  -- Advance capture pressured enemy zone
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
bc:addShopItem(1, 'redmassattack', -1, 2) -- red AI mass airbase attack
bc:addShopItem(1, 'redwarehouse', -1, 3) -- red AI rear supply depot
bc:addShopItem(1, 'redwhrepair', -1, 4) -- red AI warehouse repair
bc:addShopItem(1, 'strategicbomberRed', -1, 5)

ShopCategoryLabels = ShopCategoryLabels or {}
local ShopCats = ShopCategoryLabels

ShopCats.AIAttack = LTGet("SA_SHOP_CAT_AI_ATTACK")
ShopCats.ZoneUpgrades = LTGet("SA_SHOP_CAT_ZONE_UPGRADES")
ShopCats.JTACIntel = LTGet("SA_SHOP_CAT_JTAC_INTEL")
ShopCats.MarkingTools = LTGet("SA_SHOP_CAT_MARKING_TOOLS")
ShopCats.CombinedArms = LTGet("SA_SHOP_CAT_COMBINED_ARMS")
ShopCats.LogisticsStrategic = LTGet("SA_SHOP_CAT_LOGISTICS")
ShopCats.OtherSupport = LTGet("SA_SHOP_CAT_OTHER_SUPPORT")

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
bc:addShopItem(2, 'groundattack', -1, 6, ShopRankRequirements.groundattack, ShopCats.AIAttack) -- Ground attack convoy
bc:addShopItem(2, 'dynamicstatic', -1, 6, ShopRankRequirements.dynamicstatic, ShopCats.AIAttack) -- Static structure Flight
if StartNormal or not CustomFlags['StartNormalFalse'] then 
bc:addShopItem(2, 'cruisemsl', 12, 7, ShopRankRequirements.cruisemsl, ShopCats.AIAttack) -- Cruise missiles
end

bc:addShopItem(2, 'strategicbomber', -1, 4.5, ShopRankRequirements.strategicbomber, ShopCats.AIAttack)

-- Zone Upgrades
bc:addShopItem(2, 'zinf', -1, 1, ShopRankRequirements.zinf, ShopCats.ZoneUpgrades) -- add infantry to a zone
bc:addShopItem(2, 'zarm', -1, 2, ShopRankRequirements.zarm, ShopCats.ZoneUpgrades) -- add armour group to a zone
bc:addShopItem(2, 'zhawk', -1, 3, ShopRankRequirements.zhawk, ShopCats.ZoneUpgrades) -- HAWK system
if Era == 'Modern' then
	bc:addShopItem(2, 'zsam', -1, 4, ShopRankRequirements.zsam, ShopCats.ZoneUpgrades) -- NASAMS system
	bc:addShopItem(2, 'zcram', -1, 10, ShopRankRequirements.zcram, ShopCats.ZoneUpgrades) -- C-RAM
end
bc:addShopItem(2, 'zavenger', -1, 6, ShopRankRequirements.zavenger, ShopCats.ZoneUpgrades) -- Avenger
bc:addShopItem(2, 'zroland', -1, 7, ShopRankRequirements.zroland, ShopCats.ZoneUpgrades) -- Roland
bc:addShopItem(2, 'zgepard', -1, 8, ShopRankRequirements.zgepard, ShopCats.ZoneUpgrades) -- Gepard
bc:addShopItem(2, 'zvulcan', -1, 9, ShopRankRequirements.zvulcan, ShopCats.ZoneUpgrades) -- Vulcan
bc:addShopItem(2, 'gslot', 1, 14, ShopRankRequirements.gslot, ShopCats.ZoneUpgrades) -- add another slot for upgrade
if Era == 'Modern' then
    bc:addShopItem(2, 'zhimars', -1, 11, ShopRankRequirements.zhimars, ShopCats.ZoneUpgrades) -- add HIMARS to a zone
end
if Era ~= 'Vietnam' then
    bc:addShopItem(2, 'zpat', -1, 5, ShopRankRequirements.zpat, ShopCats.ZoneUpgrades) -- Patriot system.
end
if Era == 'Modern' then
    bc:addShopItem(2, 'zgci', -1, 12, ShopRankRequirements.zgci, ShopCats.ZoneUpgrades) -- GCI station.
end

-- JTAC & Intel
if Era ~= 'Vietnam' then
	bc:addShopItem(2, 'jtac', -1, 1, ShopRankRequirements.jtac, ShopCats.JTACIntel) -- MQ-9 Reaper JTAC mission
end
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

if Era ~= 'Vietnam' then
	bc:addShopItem(2, 'calav', -1, 5, ShopRankRequirements.calav, ShopCats.CombinedArms)
end

if Era == 'Modern' then
	bc:addShopItem(2, 'camgs', -1, 6, ShopRankRequirements.camgs, ShopCats.CombinedArms)
end

if Era == 'Modern' then
	bc:addShopItem(2, 'cadragoon', -1, 7, ShopRankRequirements.cadragoon, ShopCats.CombinedArms)
end

-- Logistics & Strategic
bc:addShopItem(2, 'capture', -1, 1, ShopRankRequirements.capture, ShopCats.LogisticsStrategic) -- emergency capture
bc:addShopItem(2, 'advancecapture', -1, 2, ShopRankRequirements.advancecapture, ShopCats.LogisticsStrategic) -- advance capture
bc:addShopItem(2, 'supplies2', -1, 3, ShopRankRequirements.supplies2, ShopCats.LogisticsStrategic) -- upgrade friendly zone
if AllowScriptedSupplies then
    bc:addShopItem(2, 'supplies', -1, 4, ShopRankRequirements.supplies, ShopCats.LogisticsStrategic) -- fully upgrade friendly zone
end
if WarehouseLogistics then
    bc:addShopItem(2, 'zlogc', -1, 5, ShopRankRequirements.zlogc, ShopCats.LogisticsStrategic) -- upgrade zone to logistic center
    bc:addShopItem(2, 'zwh50', -1, 6, ShopRankRequirements.zwh50, ShopCats.LogisticsStrategic) -- resupply warehouse with 50
end

bc:addShopItem(2, 'zwhrepair', -1, 5.5, ShopRankRequirements.zlogc, ShopCats.LogisticsStrategic)
bc:addShopItem(2, 'zsup3', -1, 6, ShopRankRequirements.zsup3, ShopCats.LogisticsStrategic)

-- Other Support
bc:addShopItem(2, 'dynamicarco', 1, 1, ShopRankRequirements.dynamicarco, ShopCats.OtherSupport) -- Navy tanker
bc:addShopItem(2, 'dynamictexaco', 1, 2, ShopRankRequirements.dynamictexaco, ShopCats.OtherSupport) -- Airforce tanker
bc:addShopItem(2, 'farphere', -1, 3, ShopRankRequirements.farphere, ShopCats.OtherSupport) -- deploy FARP
supplyZones = {
"Almirante Schroeders",
"Comandante Luis Piedrabuena",
"El Calafate",
"Franco Bianco",
"Gobernador Gregores",
"Goose Green",
"Gull Point",
"Hipico Flying Club",
"Mount Pleasant",
"O'Higgins",
"Pampa Guanaco",
"Port Stanley",
"Porvenir",
"Puerto Natales",
"Puerto Santa Cruz",
"Puerto Williams",
"Punta Arenas",
"Rio Chico",
"Rio Gallegos",
"Rio Grande",
"Rio Turbio",
"San Carlos FOB",
"San Julian",
"Tolhuin",
"Ushuaia",
"FARP Caupolican",
"FARP Sayhueque",
"FARP Lautaro",
"FARP Drake",
"FARP Calfucura",
"FARP Inacayal",
"FARP Galvarino",
"FARP Magellan",
"FARP Guemes",
"FARP Roca",
}
lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
bc:initRunwayMissions()
bc:initCasMissions()
bc:initDeadMissions()
bc:initSeadMissions()
bc:initReconMissions()
bc.seadMissionRegularSlots = bc.seadMissionMaxSlots
bc.seadMissionDefenceReserveSlot = bc.seadMissionRegularSlots + 1
bc.seadMissionMaxSlots = bc.seadMissionDefenceReserveSlot
bc:resetSeadMissionSlot(bc.seadMissionDefenceReserveSlot)
lc:init()

TerritoryOverlayOuterDrawPushMeters = 500000

local saFleetProfiles = {
	{ zone = zones.redcarrier, red = zones.redcarrier.upgrades.red },
	{ zone = zones.redcarrier2, red = zones.redcarrier2.upgrades.red },
}

bc:loadFromDisk() -- will load and overwrite default zone levels, sides, funds, and available shop items
-- Gull Point is now a capturable FOB, including saves from its former one-shot objective.
do
	local saved = zonePersistance and zonePersistance.zones and zonePersistance.zones[zones.gullpoint.zone]
	if saved and saved.active == false and saved.side == coalition.side.NEUTRAL
		and zones.gullpoint.side == coalition.side.NEUTRAL then
		zones.gullpoint.active = true
		saved.active = true
	end
end

-- Retain the original fleet slots and their losses when loading the old roster.
do
	local legacyFleet = { 'Molniya', 'Grisha', 'Rezky', 'Molniya', 'Grisha', 'Molniya', 'Grisha', 'Molniya', 'SpeedBoats', 'SpeedBoats', 'Rezky', 'SpeedBoats' }
	local retainedSlots = { 1, 2, 3, 4, 9, 10, 12 }
	for _, fleet in ipairs(saFleetProfiles) do
		local zone = fleet.zone
		local saved = zonePersistance and zonePersistance.zones and zonePersistance.zones[zone.zone]
		local previous = saved and saved.randomUpgradesRed
		if previous and (#previous == 12 or #previous == 7) then
			local knownRoster, changedNames = true, false
			for index, entry in ipairs(previous) do
				local oldName = legacyFleet[#previous == 12 and index or retainedSlots[index]]
				local targetName = Era == 'Vietnam' and vnSwap[oldName] or oldName
				local name = getUpgradeEntryName(entry)
				if name ~= oldName and name ~= targetName then knownRoster = false break end
				if name ~= targetName then changedNames = true end
			end
			if knownRoster and (#previous == 12 or changedNames) then
				local remap = {}
				for index, oldIndex in ipairs(retainedSlots) do
					remap[#previous == 12 and oldIndex or index] = index
				end
				zone.upgrades.red = fleet.red
				zone.randomUpgradesRed = { unpack(fleet.red) }
				if zone.side == coalition.side.RED then
					zone.spawnSubZones = _remapIndexedSlots(zone.spawnSubZones, remap)
					local survivors, survivorNames
					if zone.suspended then
						zone.remainingUnitsSnapshot = _remapIndexedSlots(zone.remainingUnitsSnapshot, remap)
						zone.remainingUnitNamesSnapshot = _remapIndexedSlots(zone.remainingUnitNamesSnapshot, remap)
						survivors, survivorNames = zone.remainingUnitsSnapshot, zone.remainingUnitNamesSnapshot
					else
						zone.remainingUnits = _remapIndexedSlots(saved.remainingUnits, remap)
						zone.remainingUnitNames = _remapIndexedSlots(saved.remainingUnitNames, remap)
						survivors, survivorNames = zone.remainingUnits, zone.remainingUnitNames
					end
					for oldIndex, index in pairs(remap) do
						local targetName = fleet.red[index]
						if getUpgradeEntryName(previous[oldIndex]) ~= targetName then
							local slot = survivors and survivors[index]
							if slot and next(slot) then
								local count, units = zone:_getUpgradeTemplateUnitCount(targetName)
								assert(count == 1, 'SA fleet replacement must contain one ship: '..targetName)
								survivors[index] = { units[1].type }
							end
							if survivorNames then survivorNames[index] = nil end
							zone.spawnSubZones[index] = nil
						end
					end
					if zone.suspended then zone._preserveSuspendedLosses = true end
					saved.remainingUnits = survivors
					saved.remainingUnitNames = survivorNames
					saved.spawnSubZones = zone.spawnSubZones
					zone._refreshRandomUpgrades = nil
				end
				saved.randomUpgradesRed = zone.randomUpgradesRed
			end
		end
	end
end

-- Defense shop era availability also applies to restored shop entries.
if Era ~= 'Modern' then
	bc:removeShopItem(2, 'zsam')
	bc:removeShopItem(2, 'zcram')
end
if Era == 'Vietnam' then
	bc:removeShopItem(2, 'zpat')
end

if Era == 'Vietnam' then
	bc:removeShopItem(2, 'jtac')
	bc:removeShopItem(2, '9lineam')
	bc:removeShopItem(2, '9linefm')
end

if zonePersistance and zonePersistance.zones and next(zonePersistance.zones) == nil then
    bc.saveLoaded = false
end
if not bc.saveLoaded then
	applyRandomRedUpgrades()
	applyRandomBlueUpgrades()
else
	applyRandomUpgradesForNewZonesOnly()
end

bc:init()
RewardContribution = RewardContribution or {infantry = 10, ground = 10, sam = 30, airplane = 50, ship = 200, helicopter=50, crate=100, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, ['Warehouse delivery'] = 150, structure = 100}
RewardContribution.ctldGround = RewardContribution.ctldGround or 10
RewardContribution.ctldAir = RewardContribution.ctldAir or 20
RewardContribution.enemyPilotCapture = RewardContribution.enemyPilotCapture or 200
bc:startRewardPlayerContribution(15,RewardContribution)
HercCargoDropSupply.init(bc)
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
bc:enableCarrierNavigation()
if not bc.carrierNavigation or not next(bc.carrierNavigation) then
	bc:deployCarrierNavigationArea("CVN72_AREA_FALKLAND")
end
bc:addCarrierNavigationSuspendConnection("CVN72_AREA_RED_SOUTH", "Rebel HQ", "occupied")
bc:addCarrierNavigationSuspendConnection("CVN72_AREA_RED_SOUTH", "Rio Grande", "occupied")
bc:addCarrierNavigationSuspendConnection("CVN72_AREA_RED_SOUTH", "Rio Gallegos", "occupied")
bc:addCarrierNavigationSuspendConnection("CVN72_AREA_RED_NORTH", "San Julian", "occupied")
bc:addCarrierNavigationSuspendConnection("CVN72_AREA_RED_NORTH", "Estancia Darwin", "occupied")
bc:addCarrierNavigationSuspendConnection("CVN72_AREA_RED_NORTH", "Puerto Santa Cruz", "occupied")
timer.scheduleFunction(function()
	checkWeaponsList('Shell')
end, {}, timer.getTime() + 10)
local HuntNumber = SplashDamage and math.random(8,15) or math.random(6,15)
local AirHuntNumber = math.random(4,8)
bc:initHunter(HuntNumber, AirHuntNumber)
SCHEDULER:New(nil, function() bc:_buildHunterBaseList() end, {}, 1)

SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 3)
SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 4)

AWACS_CFG = {
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=150 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=70 }   -- blue
}


GlobalSettings.autoSuspendNmBlue = 100   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 125  		-- suspend red zones deeper than this nm


evc = EventCommander:new({ decissionFrequency=15*60, decissionVariance=10*60, skipChance = 15})
evc:init()
mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})

DynamicHybridConfig = DynamicHybridConfig or {
	enabled = true,
	runOnce = true,
	enablePatrol = false,
	airMaxNm = 120,
	heloCasMaxNm = 40,
	minGroundAttackNm = 10,
	surfaceMaxNm = 30,
	minTargetNm = 10,
	filterDelaySec = 5,
	minCapAttackNm = 35,
	minPlaneAttackNm = 25,
	minHeloAttackNm = 15,
	minSeadAttackNm = 40,
	minLongRangeSeadAttackNm = 60,
	log = true,
}
bc:startDynamicHybridFiller(DynamicHybridConfig)

redDirector = Director:new({ battleCommander = bc, side = coalition.side.RED })
redDirector:init()
blueDirector = Director:new({ battleCommander = bc, side = coalition.side.BLUE })
blueDirector:init()

if RedReactiveConfig.enabled then
	bc:startRedReactiveCounterpressure(RedReactiveConfig)
end

SpawnFriendlyAssets()

mc:trackMission({
	title = LTGet("SA_MISSION_INTERCEPT_BOMBERS_TITLE"),
	description = function(T)
		local desc = LT(T):Get("SA_MISSION_INTERCEPT_BOMBERS_DESC")
		local st = StrategicBomber.GetState(1)
		if st and st.spawnZone and st.targetZone then
			desc = desc .. "\n\n" .. LT(T):Format("SA_MISSION_INTERCEPT_BOMBERS_DESC_DETAIL", st.spawnZone, st.targetZone)
		end
		return desc
	end,
	messageStart = function(T)
		local msg = LT(T):Get("SA_MISSION_INTERCEPT_BOMBERS_START")
		local st = StrategicBomber.GetState(1)
		if st and st.spawnZone and st.targetZone then
			msg = msg .. "\n\n" .. LT(T):Format("SA_MISSION_INTERCEPT_BOMBERS_START_DETAIL", st.spawnZone, st.targetZone)
		end
		return msg
	end,
	messageEnd=function(T)
		StrategicBomber.Clear(1)
		return LT(T):Get("SA_MISSION_INTERCEPT_BOMBERS_END")
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
		bc:cancelGroupTargetMission('bomb', 2)
	end,
	isActive = function()
		return StrategicBomber.IsMissionActive(1)
	end
})

local airstrike_COOLDOWN = 1800
local enemyStrikeGroups = BuildEnabledTemplateList(
	ColdWarTechEra and {'evt-attackcw'} or {'evt-attack', 'evt-attackcw'},
	RedEnemyStrikePlaneEnabled
)
local attackGrp = enemyStrikeGroups[1] or 'evt-attack'
local airstrikeAltitudeFt = 20000
local airstrikePickOptions = {
	minTargetSpawnNm = 80,
	preferredTargetSpawnNm = 100,
	minPlayerSpawnNm = 80,
	avoidPlayerCoalition = 'blue',
	allowSuspendedSpawn = true,
	preferNonSuspendedSpawn = true,
	randomCandidateLimit = 3,
	attackAltitudeFt = airstrikeAltitudeFt,
}

Group.getByName('evt-attack'):destroy()
Group.getByName('evt-attackcw'):destroy()
Group.getByName(attackGrp):destroy()
local tacticalAirstrikeEvent = {
	id='cas',
	StrikeMission = true,
	action = function(event)
		if #enemyStrikeGroups == 0 then return end
		local director = Director:getForSide(coalition.side.RED)
		local selection = director:consumeTacticalAirstrikePlan(airstrikePickOptions)
		if not selection then return end
		local spawnPoint = selection.spawnCoord:GetVec3()
		local owner = {side=1, zoneCommander=selection.spawnZone}
		local acceptedAt = timer.getTime()
		return mc:launchIdleAttack(event, owner, selection.targetZone, function()
			if timer.getTime() ~= acceptedAt then
				local source = selection.spawnZone
				if not director.ready or not director.config.enabled
					or director:_tacticalAirstrikeOperationSignature() ~= selection.operationSignature
					or source.side ~= 1 or not source.active or source.isHidden
					or (source.suspended and airstrikePickOptions.allowSuspendedSpawn ~= true)
					or selection.airbase:GetCoalition() ~= 1 then return false end
				local nearestPlayer = DynamicBomber.NearestPlayerDistanceNm(selection.spawnCoord, airstrikePickOptions.avoidPlayerCoalition)
				if nearestPlayer and nearestPlayer < (airstrikePickOptions.minPlayerSpawnNm or 80) then return false end
			end
		attackGrp = enemyStrikeGroups[math.random(1, #enemyStrikeGroups)]
		local spawned = Respawn.SpawnAtPoint(
			attackGrp,
			spawnPoint,
			selection.heading,
			5,
			airstrikeAltitudeFt,
			nil,
			true
		)
		if not spawned then return false end
		director:commitTacticalAirstrikeLaunch(selection, airstrike_COOLDOWN)
		RegisterGroupTarget(attackGrp,250,L10N:Get("SA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),'cas')
		timer.scheduleFunction(function(param)
			local group = Group.getByName(param.groupName)
			if group and group:getID() == param.groupId then
				bc:_engageResolvedZone(param.targetZone, group)
			end
		end, {targetZone=selection.targetZone, groupName=attackGrp, groupId=spawned:getID()}, timer.getTime()+3)
		return true
		end, {spawnPoint, selection.targetZone._cz.point})
	end,
	canExecute = function(event)
		if event._idleAttackPendingLaunch then return false end
        if Era == 'Vietnam' then return false end
		if #enemyStrikeGroups == 0 then return false end
        if ActiveMission['cas'] then return false end
		local gr = Group.getByName(attackGrp)
		if gr then return false end
		return Director:getForSide(coalition.side.RED)
			:getTacticalAirstrikePlan(airstrikePickOptions) ~= nil
	end
}
evc:addEvent(tacticalAirstrikeEvent)
mc:trackMission({
	title = LTGet("SA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),
	idleAttackEvent = tacticalAirstrikeEvent,
	description = function(T)
		local desc = LT(T):Get("SA_MISSION_INTERCEPT_AIRSTRIKE_DESC")
		local director = Director:getForSide(coalition.side.RED)
		if Group.getByName(attackGrp)
			and director.tacticalAirstrikeLastSpawnZone
			and director.tacticalAirstrikeLastTarget
		then
			desc = desc .. "\n\n" .. LT(T):Format(
				"SA_MISSION_INTERCEPT_AIRSTRIKE_DETAIL",
				director.tacticalAirstrikeLastSpawnZone,
				director.tacticalAirstrikeLastTarget
			)
		end
		return desc
	end,
	messageStart = function(T)
		local msg = LT(T):Get("SA_MISSION_INTERCEPT_AIRSTRIKE_START")
		local director = Director:getForSide(coalition.side.RED)
		if Group.getByName(attackGrp)
			and director.tacticalAirstrikeLastSpawnZone
			and director.tacticalAirstrikeLastTarget
		then
			msg = msg .. "\n\n" .. LT(T):Format(
				"SA_MISSION_INTERCEPT_AIRSTRIKE_DETAIL",
				director.tacticalAirstrikeLastSpawnZone,
				director.tacticalAirstrikeLastTarget
			)
		end
		return msg
	end,
	messageEnd = function(T)
		Director:getForSide(coalition.side.RED):onTacticalAirstrikeEnded(airstrike_COOLDOWN)
		return LT(T):Get("SA_MISSION_INTERCEPT_AIRSTRIKE_END")
	end,
	startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            -- trigger.action.outSoundForCoalition(2, "ding.ogg")
            trigger.action.outSoundForCoalition(2, "Enemy airstrike detected intercept them before they reach their target..ogg")
        end
    end,
    endAction = function()
        if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
		bc:cancelGroupTargetMission('cas', 2)
    end,
    isActive = function()
		if not ActiveMission['cas'] then return false end
		local gr = Group.getByName(attackGrp)
		if gr then return true end
		ActiveMission['cas'] = nil
		return false
    end
})

--[=[ Cargo interception disabled pending SA event templates.
local CargoIntercept_COOLDOWN = 1800
local lastCargoIntercept_COOLDOWN  = -CargoIntercept_COOLDOWN
Group.getByName('evt-cargointercept1'):destroy()
Group.getByName('evt-cargointercept2'):destroy()
Group.getByName('evt-cargointercept3'):destroy()
local cargoDieEvent = nil
evc:addEvent({
	id = 'cargointercept',
	action = function()
		local planes
		local balad = bc.indexedZones['Ushuaia']
		local qayyarah = bc.indexedZones['El Calafate']
		local alSahra = bc.indexedZones['San Julian']
		if balad.side == 1 and (not balad.suspended or balad._idleSuspended) then
			planes = { 'evt-cargointercept1' }
		elseif qayyarah.side == 1 and (not qayyarah.suspended or qayyarah._idleSuspended) then
			planes = { 'evt-cargointercept2' }
		elseif alSahra.side == 1 and (not alSahra.suspended or alSahra._idleSuspended) then
			planes = { 'evt-cargointercept3' }
		else
			return
		end
		RespawnGroup(planes[1])
		local u = Group.getByName(planes[1]):getUnit(1)
		if u then RegisterUnitTarget(u:getName(),250,L10N:Get("SA_MISSION_INTERCEPT_CARGO_TITLE"),'cargointercept') end
	end,
	canExecute = function()
		if ActiveMission['cargointercept'] then return false end
		if timer.getTime() - lastCargoIntercept_COOLDOWN < CargoIntercept_COOLDOWN then return false end
		if math.random(1,100) < 70 then return false end
		local balad = bc.indexedZones['Ushuaia']
		local qayyarah = bc.indexedZones['El Calafate']
		local alSahra = bc.indexedZones['San Julian']
		if (balad.side == 2 and qayyarah.side == 2 and alSahra.side == 2)
		or (balad.suspended and not balad._idleSuspended
		and qayyarah.suspended and not qayyarah._idleSuspended
		and alSahra.suspended and not alSahra._idleSuspended) then return false end
		if Group.getByName('evt-cargointercept1') then return false end
		if Group.getByName('evt-cargointercept2') then return false end
		if Group.getByName('evt-cargointercept3') then return false end
		return true
	end
})

mc:trackMission({
    title = LTGet("SA_MISSION_INTERCEPT_CARGO_TITLE"),
    description = LTGet("SA_MISSION_INTERCEPT_CARGO_DESC"),
    messageStart = L10N:Get("SA_MISSION_INTERCEPT_CARGO_START"),
    messageEnd =function() lastCargoIntercept_COOLDOWN=timer.getTime() return L10N:Get("SA_MISSION_INTERCEPT_CARGO_END") end,
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "radio1.ogg")
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


]=]

--[=[ Ship interception disabled pending SA event templates.
local Ship_COOLDOWN = 1800
local lastShip_COOLDOWN   = -Ship_COOLDOWN
Group.getByName('evt-shiptercept1'):destroy()
Group.getByName('evt-shiptercept2'):destroy()
Group.getByName('evt-shiptercept3'):destroy()
local shipDieEvent = nil

if GlobalSettings.pvpEnabled ~= true then
evc:addEvent({
  id = 'shiptercept',
  action = function()
    local ships = {'evt-shiptercept1','evt-shiptercept2','evt-shiptercept3'}
    local choice = math.random(1,#ships)
    RespawnGroup(ships[choice])
		RegisterGroupTarget(ships[choice],500,L10N:Get("SA_MISSION_TARGET_DESTROY_CARGO_SHIP"),'shiptercept')
  end,
  canExecute = function()
	if ActiveMission['shiptercept'] then return false end
	if timer.getTime() - lastShip_COOLDOWN < Ship_COOLDOWN then return false end
    if math.random(1, 100) < 70 then return false end
    if not zones.redcarrier.active and not zones.redcarrier2.active then return false end
    if Group.getByName('evt-shiptercept1') then return false end
    if Group.getByName('evt-shiptercept2') then return false end
    if Group.getByName('evt-shiptercept3') then return false end
    return true
  end
})
mc:trackMission({
    title = LTGet("SA_MISSION_DESTROY_CARGO_SHIP_TITLE"),
    description = LTGet("SA_MISSION_DESTROY_CARGO_SHIP_DESC"),
    messageStart = LTGet("SA_MISSION_DESTROY_CARGO_SHIP_START"),
    messageEnd =function(T) lastShip_COOLDOWN=timer.getTime() return LT(T):Get("SA_MISSION_DESTROY_CARGO_SHIP_END") end,
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "radio2.ogg")
        end
    end,
    endAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
		bc:cancelGroupTargetMission('shiptercept')
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


end
]=]

attackTarget1 = nil
attackTarget2 = nil
attackTarget3 = nil
attackTarget3Started = nil
resupplyTarget1 = nil
resupplyTarget2 = nil
attackCombinedStart1 = nil
attackCombinedStart2 = nil
attackSuppressStart2 = nil
resupplyCombinedStart1 = nil
resupplyCombinedStart2 = nil
resupplySuppressStart2 = nil







mc:trackMission({
	title = function(T)
		local wp = WaypointList[resupplyTarget1] or ""
		return LT(T):Format("SA_DYNAMIC_RESUPPLY_TITLE", resupplyTarget1, wp)
	end,
	description = function(T)
		return LT(T):Format("SA_DYNAMIC_RESUPPLY_DESC", resupplyTarget1)
	end,
	messageStart = nil,
	messageEnd = function(T)
		return LT(T):Format("SA_DYNAMIC_RESUPPLY_END", resupplyTarget1)
	end,
	startAction = function()
		local MissionType = "Resupply"
		bc:addMissionTag(resupplyTarget1, MissionType)
		bc:refreshZoneLabel(resupplyTarget1)
		local wp = WaypointList[resupplyTarget1] or ""
		if resupplyCombinedStart1 == resupplyTarget1 and resupplyCombinedStart2 == resupplyTarget2 and resupplyTarget2 then
			local wp2 = WaypointList[resupplyTarget2] or ""
			trigger.action.outTextForCoalition(2, L10N:Format("SA_DYNAMIC_RESUPPLY_START_TWO", resupplyTarget1, wp, resupplyTarget2, wp2), 30)
			resupplySuppressStart2 = resupplyTarget2
			resupplyCombinedStart1 = nil
			resupplyCombinedStart2 = nil
		else
			trigger.action.outTextForCoalition(2, L10N:Format("SA_DYNAMIC_RESUPPLY_START_ONE", resupplyTarget1, wp), 30)
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
	isActive = function(mission)
		if not resupplyTarget1 then return false end
		local targetzn = bc:getZoneByName(resupplyTarget1)
		local active = targetzn and bc:_playerSupplyTargetNeedsSupply(targetzn, {})
		if not active and not mission.isRunning then
			resupplyTarget1 = nil
			resupplyCombinedStart1 = nil
		end
		return active
	end
})

mc:trackMission({
	title = function(T)
		local wp = WaypointList[resupplyTarget2] or ""
		return LT(T):Format("SA_DYNAMIC_RESUPPLY_TITLE", resupplyTarget2, wp)
	end,
	description = function(T)
		return LT(T):Format("SA_DYNAMIC_RESUPPLY_DESC", resupplyTarget2)
	end,
	messageStart = nil,
	messageEnd = function(T)
		return LT(T):Format("SA_DYNAMIC_RESUPPLY_END", resupplyTarget2)
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
			trigger.action.outTextForCoalition(2, L10N:Format("SA_DYNAMIC_RESUPPLY_START_ONE", resupplyTarget2, wp), 30)
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
	isActive = function(mission)
		if not resupplyTarget2 then return false end
		local targetzn = bc:getZoneByName(resupplyTarget2)
		local active = targetzn and bc:_playerSupplyTargetNeedsSupply(targetzn, {})
		if not active and not mission.isRunning then
			if resupplySuppressStart2 == resupplyTarget2 then resupplySuppressStart2 = nil end
			resupplyTarget2 = nil
			resupplyCombinedStart2 = nil
		end
		return active
	end
})

mc:trackMission({
	title = function(T)
		local wp = WaypointList[attackTarget1] or ""
		return LT(T):Format("SA_DYNAMIC_ATTACK_TITLE", attackTarget1, wp)
	end,
	description = function(T)
		return LT(T):Format("SA_DYNAMIC_ATTACK_DESC", attackTarget1)
	end,
	messageStart = nil,
	messageEnd = function(T)
		return LT(T):Format("SA_DYNAMIC_ATTACK_END", attackTarget1)
	end,
	startAction = function()
		bc:addMissionTag(attackTarget1, "Attack")
		bc:refreshZoneLabel(attackTarget1)
		local wp = WaypointList[attackTarget1] or ""
		if attackCombinedStart1 == attackTarget1 and attackCombinedStart2 == attackTarget2 and attackTarget2 then
			local wp2 = WaypointList[attackTarget2] or ""
			trigger.action.outTextForCoalition(2, L10N:Format("SA_DYNAMIC_ATTACK_START_TWO", attackTarget1, wp, attackTarget2, wp2), 30)
			attackSuppressStart2 = attackTarget2
			attackCombinedStart1 = nil
			attackCombinedStart2 = nil
		else
			trigger.action.outTextForCoalition(2, L10N:Format("SA_DYNAMIC_ATTACK_START_ONE", attackTarget1, wp), 30)
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
	isActive = function(mission)
		if not attackTarget1 then return false end
		local targetzn = bc:getZoneByName(attackTarget1)
		local active = targetzn and targetzn.zone and targetzn.side == 1 and not targetzn.suspended or false
		if not active and not mission.isRunning then
			if attackCombinedStart1 == attackTarget1 then
				attackCombinedStart1 = nil
				attackCombinedStart2 = nil
			end
			attackTarget1 = nil
		end
		return active
	end
})

mc:trackMission({
	title = function(T)
		local wp = WaypointList[attackTarget2] or ""
		return LT(T):Format("SA_DYNAMIC_ATTACK_TITLE", attackTarget2, wp)
	end,
	description = function(T)
		return LT(T):Format("SA_DYNAMIC_ATTACK_DESC", attackTarget2)
	end,
	messageStart = nil,
	messageEnd = function(T)
		return LT(T):Format("SA_DYNAMIC_ATTACK_END", attackTarget2)
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
			trigger.action.outTextForCoalition(2, L10N:Format("SA_DYNAMIC_ATTACK_START_ONE", attackTarget2, wp), 30)
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
	isActive = function(mission)
		if not attackTarget2 then return false end
		local targetzn = bc:getZoneByName(attackTarget2)
		local active = targetzn and targetzn.zone and targetzn.side == 1 and not targetzn.suspended or false
		if not active and not mission.isRunning then
			if attackCombinedStart2 == attackTarget2 then
				attackCombinedStart1 = nil
				attackCombinedStart2 = nil
			end
			if attackSuppressStart2 == attackTarget2 then attackSuppressStart2 = nil end
			attackTarget2 = nil
		end
		return active
	end
})

mc:trackMission({
	title = function(T)
		local wp = WaypointList[attackTarget3] or ""
		return LT(T):Format("SA_DYNAMIC_ATTACK_TITLE", attackTarget3, wp)
	end,
	description = function(T)
		return LT(T):Format("SA_DYNAMIC_ATTACK_DESC", attackTarget3)
	end,
	messageStart = nil,
	messageEnd = function() return L10N:Format("SA_DYNAMIC_ATTACK_END", attackTarget3Started or attackTarget3) end,
	startAction = function()
		attackTarget3Started = attackTarget3
		bc:addMissionTag(attackTarget3, "Attack")
		bc:refreshZoneLabel(attackTarget3)
		local wp = WaypointList[attackTarget3] or ""
		trigger.action.outTextForCoalition(2, L10N:Format("SA_DYNAMIC_ATTACK_START_ONE", attackTarget3, wp), 30)
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cas.ogg")
		end
	end,
	endAction = function()
		local endedTarget = attackTarget3Started or attackTarget3
		bc:removeMissionTag(endedTarget, "Attack")
		bc:refreshZoneLabel(endedTarget)
		attackTarget3Started = nil
		attackTarget3 = nil
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
	isActive = function(mission)
		if not attackTarget3 then return false end
		local targetzn = bc:getZoneByName(attackTarget3)
		local active = targetzn and targetzn.zone and targetzn.side == 1 and not targetzn.suspended or false
		if not active and not mission.isRunning then
			attackTarget3Started = nil
			attackTarget3 = nil
		end
		return active
	end
})
captureTarget = nil
mc:trackMission({
    title = function(T)
        local wp = WaypointList[captureTarget] or ""
        return LT(T):Format("SA_DYNAMIC_CAPTURE_TITLE", captureTarget, wp)
    end,
    description = function(T)
        return LT(T):Format("SA_DYNAMIC_CAPTURE_DESC", captureTarget) end,
    messageStart = function(T)
        local wp = WaypointList[captureTarget] or ""
        return LT(T):Format("SA_DYNAMIC_CAPTURE_START", captureTarget, wp)
    end,
    messageEnd = function(T)
        local targetzn = captureTarget and bc:getZoneByName(captureTarget) or nil
        if targetzn and (targetzn.pendingCapture or targetzn._pendingCaptureRestore) then
            return nil
        end
        return LT(T):Format("SA_DYNAMIC_CAPTURE_END", captureTarget) end,
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
        local targetzn = captureTarget and bc:getZoneByName(captureTarget) or nil
        local capturePending = targetzn and (targetzn.pendingCapture ~= nil or targetzn._pendingCaptureRestore ~= nil)
        bc:removeMissionTag(captureTarget, MissionType)
        bc:refreshZoneLabel(captureTarget)
        captureTarget = nil
        if not missionCompleted and not capturePending then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
    end,
    isActive = function(mission)
        if not captureTarget then return false end
        local targetzn = bc:getZoneByName(captureTarget)
        local active = targetzn.side == 0 and targetzn.active
            and not targetzn.pendingCapture and not targetzn._pendingCaptureRestore
        if not active and not mission.isRunning then captureTarget = nil end
        return active
    end
})




seadTargets = {}

function RegisterDirectorSeadMission(slotIndex)
    local mission
    mission = {
        missionType = "SEAD",
        zone = nil,
        title = function(T)
            local slot = bc.seadMissions.slots[slotIndex]
            return LT(T):Format("MISSION_SEAD_TITLE", slot.targetZone)
        end,
        description = function(T)
            local slot = bc.seadMissions.slots[slotIndex]
            return LT(T):Format("MISSION_SEAD_DESCRIPTION", slot.targetZone)
        end,
        messageStart = function(T)
            local slot = bc.seadMissions.slots[slotIndex]
            return LT(T):Format("MISSION_SEAD_START", slot.targetZone)
        end,
        messageEnd = function(T) return LT(T):Get("MISSION_SEAD_END") end,
        startAction = function()
            local slot = bc.seadMissions.slots[slotIndex]
            slot.started = true
            mission.zone = slot.targetZone
            bc:addMissionTag(slot.targetZone, "SEAD")
            bc:refreshZoneLabel(slot.targetZone)
            if not missionCompleted then trigger.action.outSoundForCoalition(2,"ding.ogg") end
        end,
        endAction = function()
            local slot = bc.seadMissions.slots[slotIndex]
            local targetZone = slot.targetZone
            if targetZone then
                bc:removeMissionTag(targetZone, "SEAD")
                bc:refreshZoneLabel(targetZone)
            end
            if slot.completed then
                local participantNames, rewards = bc:buildSeadMissionRewards(slotIndex)
                for _, playerName in ipairs(participantNames) do
                    bc:addContribution(playerName, coalition.side.BLUE, rewards[playerName], {playerName})
                    bc:addTempStat(playerName, 'SEAD mission', 1)
                    bc:scheduleRewardClaimIfLanded(playerName)
                end
                if #participantNames == 1 then
                    local playerName = participantNames[1]
                    trigger.action.outTextForCoalition(2,L10N:Format("MISSION_REWARD_COMPLETED_SOLO", "SEAD", playerName, rewards[playerName]),20)
                elseif #participantNames > 1 then
                    local rewardLines = {}
                    for _, playerName in ipairs(participantNames) do
                        rewardLines[#rewardLines + 1] = L10N:Format("MISSION_CAS_REWARD_LINE", playerName, rewards[playerName])
                    end
                    trigger.action.outTextForCoalition(2,L10N:Format("MISSION_REWARD_COMPLETED_GROUP_VARIABLE", "SEAD", table.concat(rewardLines, '\n')),20)
                end
            end
            seadTargets[slotIndex] = nil
            bc:resetSeadMissionSlot(slotIndex)
            mission.zone = nil
            if not missionCompleted then trigger.action.outSoundForCoalition(2,"cancel.ogg") end
        end,
        isActive = function()
            local slot = bc.seadMissions.slots[slotIndex]
            if slot.completed and not slot.started then return true end
            if not slot.active then return false end
            if not slot.started then
                local targetZone = bc:getZoneByName(slot.targetZone)
                if targetZone.side ~= coalition.side.RED or not targetZone.active or targetZone.suspended then
                    seadTargets[slotIndex] = nil
                    bc:resetSeadMissionSlot(slotIndex)
                    return false
                end
                return true
            end
            return bc:isSeadMissionSlotContinuing(slotIndex)
        end
    }
    mc:trackMission(mission)
end

for slotIndex = 1, bc.seadMissionMaxSlots do
    RegisterDirectorSeadMission(slotIndex)
end



mc:registerDeadMissions()


---------------------------------------------------------------------
--                         RECON MISSION                           --
function RegisterDirectorReconMission(slotIndex)
	mc:trackMission({
	title = function(T)
		local target = bc.reconMissions.slots[slotIndex].targetZone
		if not target then return LT(T):Get("SA_DYNAMIC_RECON_TITLE_EMPTY") end
		local wp = WaypointList[target] or ""
		return LT(T):Format("SA_DYNAMIC_RECON_TITLE", target, wp)
	end,
	description = function(T)
		local target = bc.reconMissions.slots[slotIndex].targetZone
		if not target then return LT(T):Get("SA_DYNAMIC_RECON_DESC_EMPTY") end
		return LT(T):Format("SA_DYNAMIC_RECON_DESC", target)
	end,
	messageStart = function(T)
		local target = bc.reconMissions.slots[slotIndex].targetZone
		if not target then return LT(T):Get("SA_DYNAMIC_RECON_START_EMPTY") end
		local wp = WaypointList[target] or ""
		return LT(T):Format("SA_DYNAMIC_RECON_START", target, wp)
	end,
	messageEnd = function(T)
		local slot = bc.reconMissions.slots[slotIndex]
		if slot.completed and slot.targetZone and slot.winner then
			return LT(T):Format("SA_DYNAMIC_RECON_END_BY", slot.targetZone, slot.winner)
		end
		if slot.targetZone then
			return LT(T):Format("SA_DYNAMIC_RECON_END_TARGET", slot.targetZone)
		end
		return LT(T):Get("SA_DYNAMIC_RECON_END")
	end,
	startAction = function()
		local slot = bc.reconMissions.slots[slotIndex]
		slot.completed = false
		slot.winner = nil
		slot.started = true

		bc:addMissionTag(slot.targetZone, "Recon")
		bc:refreshZoneLabel(slot.targetZone)

		startReconMissionZoneTracker(slot.targetZone)
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "ding.ogg")
		end
	end,
	endAction = function()
		local slot = bc.reconMissions.slots[slotIndex]
		local target = slot.targetZone
		local winner = slot.winner
		local completed = slot.completed
		if target then
			stopReconMissionZoneTracker(target)
			bc:removeMissionTag(target, "Recon")
			bc:refreshZoneLabel(target)
		end

		if completed and target and winner then
			local reward = 100
			local jp = bc:awardJointMissionReward(winner, 2, reward, "Recon mission")
			if jp then
				trigger.action.outTextForCoalition(2, L10N:Format("SA_DYNAMIC_RECON_COMPLETED_JOINT", winner, jp, target, reward), 20)
			else
				trigger.action.outTextForCoalition(2, L10N:Format("SA_DYNAMIC_RECON_COMPLETED_SOLO", winner, target, reward), 20)
			end
			startZoneIntel(target, 10 * 60, 2)
			bc.reconMissions.cooldownByTarget[target] = timer.getTime() + 900
		end

		bc:resetReconMissionSlot(slotIndex)
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
		end
	end,
	isActive = function()
		local slot = bc.reconMissions.slots[slotIndex]
		if slot.completed or not slot.active or not slot.targetZone then return false end
		local targetzn = bc:getZoneByName(slot.targetZone)
		if not targetzn or targetzn.side ~= 1 or not targetzn.active or targetzn.suspended then
			if not slot.started then bc:resetReconMissionSlot(slotIndex) end
			return false
		end
		return true
	end
	})
end

for slotIndex = 1, bc.reconMissionMaxSlots do
	RegisterDirectorReconMission(slotIndex)
end
--                    End of RECON MISSION                         --
---------------------------------------------------------------------





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
    messageEnd = function(T) return LT(T):Get("MISSION_CAP_END") end,
    startAction = function()
        if not missionCompleted then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
	endAction = function()
        if capWinner then
            local reward = capTargetPlanes * 100
            local pname  = capWinner
            local jp = bc:awardJointMissionReward(pname, 2, reward, 'CAP mission')
            if jp then
                trigger.action.outTextForCoalition(2,L10N:Format("MISSION_CAP_COMPLETED_JOINT", pname, jp, reward),20)
            else
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
function RegisterDirectorCasMission(slotIndex)
	mc:trackMission({
		title = function(T)
			local slot = bc.casMissions.slots[slotIndex]
			return LT(T):Format("MISSION_CAS_TITLE", slot.targetZone)
		end,
		description = function(T)
			T = LT(T)
			local slot = bc.casMissions.slots[slotIndex]
			if not next(slot.killsByPlayer) then
				return T:Format("MISSION_CAS_DESCRIPTION_EMPTY", slot.targetZone, slot.totalKills, slot.targetKills)
			else
				local scoreboard = T:Get("MISSION_CAP_SCOREBOARD_HEADER")
				for playerName, kills in pairs(slot.killsByPlayer) do
					scoreboard = scoreboard..string.format('%s: %d\n', playerName, kills)
				end
				return T:Format("MISSION_CAS_DESCRIPTION_WITH_SCORE", slot.targetZone, slot.totalKills, slot.targetKills, scoreboard)
			end
		end,
		messageStart = function(T)
			local slot = bc.casMissions.slots[slotIndex]
			return LT(T):Format("MISSION_CAS_START", slot.targetZone, slot.targetKills)
		end,
		messageEnd = function(T) return LT(T):Get("MISSION_CAS_END") end,
		startAction = function()
			local slot = bc.casMissions.slots[slotIndex]
			slot.started = true
			if not slot.completed and not missionCompleted then trigger.action.outSoundForCoalition(2,'ding.ogg') end
		end,
		endAction = function()
			local slot = bc.casMissions.slots[slotIndex]
			if slot.completed then
				local participantNames, rewards = bc:buildCasMissionRewards(slotIndex)
				for _, playerName in ipairs(participantNames) do
					local reward = rewards[playerName]
					bc:addContribution(playerName, 2, reward, {playerName})
					bc:addTempStat(playerName,'CAS mission',1)
					bc:scheduleRewardClaimIfLanded(playerName)
				end
				if #participantNames == 0 then
				elseif #participantNames == 1 then
					local playerName = participantNames[1]
					trigger.action.outTextForCoalition(2,L10N:Format("MISSION_CAS_COMPLETED_SOLO", playerName, rewards[playerName]),20)
				else
					local rewardLines = {}
					for _, playerName in ipairs(participantNames) do
						rewardLines[#rewardLines + 1] = L10N:Format("MISSION_CAS_REWARD_LINE", playerName, rewards[playerName])
					end
					trigger.action.outTextForCoalition(2,L10N:Format("MISSION_CAS_COMPLETED_GROUP", table.concat(rewardLines, '\n')),20)
				end
				slot.cooldownUntil = timer.getTime()+900
			end
			bc:resetCasMissionSlot(slotIndex)
			if not missionCompleted then trigger.action.outSoundForCoalition(2,'cancel.ogg') end
		end,
		isActive = function()
			local slot = bc.casMissions.slots[slotIndex]
			if slot.completed and not slot.started then return true end
			if not slot.active then return false end
			if not slot.started then
				local targetZone = bc:getZoneByName(slot.targetZone)
				if targetZone.side ~= 1 or not targetZone.active or targetZone.suspended then
					bc:resetCasMissionSlot(slotIndex)
					return false
				end
				return true
			end
			return bc:isCasMissionSlotContinuing(slotIndex)
		end
	})
end

for slotIndex = 1, bc.casMissionMaxSlots do
	RegisterDirectorCasMission(slotIndex)
end
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
		trigger.action.outTextForGroup(groupID, L10N:FormatForGroup(groupID, "SA_ESCORT_ACTIVE_PENDING", mission.zone, mission.TargetZone), 30)
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
		if not IsGroupActive(mission.missionGroup) then
			self.accept = false
			mc.missionFlags[zoneName] = nil
			if missionGroupIDs[zoneName] and next(missionGroupIDs[zoneName]) then
				for _, data in pairs(missionGroupIDs[zoneName]) do
					local groupID = data.groupID
					local groupName = data.groupName
					local group = data.group
					trigger.action.outSoundForGroup(groupID, "cancel.ogg")
					trigger.action.outTextForGroup(groupID, L10N:GetForGroup(groupID, "SA_ESCORT_FAILED_RETRY"), 30)
					removeMissionMenuForAll(mission.zone, groupID)
					if trackedGroups[groupName] then
						trackedGroups[groupName] = nil
						--handleMission(zoneName, groupName, groupID, group)
					end
				end
			else
				trigger.action.outSoundForCoalition(2, "cancel.ogg")
				trigger.action.outTextForCoalition(2, L10N:Get("SA_ESCORT_FAILED"), 30)
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
					msg = L10N:Format("SA_ESCORT_COMPLETED_MULTI", table.concat(names, ", "), share)
				elseif cnt == 1 then
					msg = L10N:Format("SA_ESCORT_COMPLETED_SOLO", names[1], reward)
				else
					msg = L10N:Format("SA_ESCORT_COMPLETED_NONE", reward)
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

function RegisterDirectorRunwayMission(slotIndex)
	mc:trackMission({
		title = function(T)
			local slot = bc.runwayMissions.slots[slotIndex]
			local title = LT(T):Get("MISSION_BOMB_RUNWAY_TITLE")
			return slot.targetZone and title .. ': ' .. slot.targetZone or title
		end,
		description = function(T)
			T = LT(T)
			local slot = bc.runwayMissions.slots[slotIndex]
			local wp = WaypointList[slot.targetZone] or ""
			if #slot.runwayNames > 1 then
				return T:Format("MISSION_BOMB_RUNWAY_DESC_ALL", slot.targetZone, wp)
			else
				return T:Format("MISSION_BOMB_RUNWAY_DESC_ONE", slot.targetZone, wp)
			end
		end,
		messageStart = function(T)
			T = LT(T)
			local slot = bc.runwayMissions.slots[slotIndex]
			local wp = WaypointList[slot.targetZone] or ""
			if #slot.runwayNames > 1 then
				return T:Format("MISSION_BOMB_RUNWAY_START_ALL", slot.targetZone, wp)
			else
				return T:Format("MISSION_BOMB_RUNWAY_START_ONE", slot.targetZone, wp)
			end
		end,
		messageEnd = function(T)
			T = LT(T)
			local slot = bc.runwayMissions.slots[slotIndex]
			trigger.action.outSoundForCoalition(2, 'cancel.ogg')
			if slot.targetZone then
				if slot.completed then
					local cred = slot.need > 1 and 200 or 100
					if slot.bomberName and slot.partnerName then
						return T:Format("SA_BOMB_RUNWAY_END_JOINT", slot.targetZone, slot.bomberName, slot.partnerName, cred)
					elseif slot.bomberName then
						return T:Format("SA_BOMB_RUNWAY_END_SOLO", slot.targetZone, slot.bomberName, cred)
					else
						return T:Format("SA_BOMB_RUNWAY_END_COMPLETED", slot.targetZone)
					end
				else
					return T:Format("SA_BOMB_RUNWAY_END_CANCELED_ZONE", slot.targetZone)
				end
			else
				return T:Get("SA_BOMB_RUNWAY_CANCELED")
			end
		end,
		startAction = function()
			local slot = bc.runwayMissions.slots[slotIndex]
			slot.started = true
			bc:addMissionTag(slot.targetZone, "Bomb runway")
			bc:refreshZoneLabel(slot.targetZone)
			if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
				trigger.action.outSoundForCoalition(2, "ding.ogg")
			end
		end,
		endAction = function()
			local slot = bc.runwayMissions.slots[slotIndex]
			if slot.targetZone then
				RUNWAY_ZONE_COOLDOWN[slot.targetZone] = timer.getTime() + 3000
				bc:removeMissionTag(slot.targetZone, "Bomb runway")
				bc:refreshZoneLabel(slot.targetZone)
			end
			bc:resetRunwayMissionSlot(slotIndex)
		end,
		isActive = function()
			local slot = bc.runwayMissions.slots[slotIndex]
			if slot.completed and not slot.started then return true end
			if not slot.active then return false end
			local targetZone = bc:getZoneByName(slot.targetZone)
			if not slot.started and (not targetZone or targetZone.side ~= 1 or not targetZone.active or targetZone.suspended) then
				bc:resetRunwayMissionSlot(slotIndex)
				return false
			end
			return targetZone and targetZone.side == 1
		end,
	})
end

for slotIndex = 1, bc.runwayMissionMaxSlots do
	RegisterDirectorRunwayMission(slotIndex)
end
---------------------------------------------------------------------
--                      END OF RUN WAY STRIKE MISSION              --





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
	local hadThirdAttack = attackTarget3 ~= nil
	if not hadThirdAttack and blueDirector:hasBlueThirdAttackDemand(timer.getAbsTime()) then
		generateAttackMission(true)
	end
	if not hadThirdAttack and attackTarget3 then
		checkAndGenerateCASMission()
		generateSEADMission()
		checkAndGenerateRunwayMissions()
	end
	return time+30
end, {}, timer.getTime() + 45)

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
    if checkAndGenerateRunwayMissions() then
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
["FARP Caupolican"] = {"FARP Caupolicanammo", "FARP Caupolicanfuel", "FARP Caupolicantent1", "FARP Caupolicantent2", "FARP Caupolicantent3", "FARP Caupolicantent4", "FARP Caupolicancenter", "FARP Caupolicanwind"},
["FARP Sayhueque"] = {"FARP Sayhuequeammo", "FARP Sayhuequefuel", "FARP Sayhuequetent1", "FARP Sayhuequetent2", "FARP Sayhuequetent3", "FARP Sayhuequetent4", "FARP Sayhuequecenter", "FARP Sayhuequewind"},	  
["FARP Lautaro"] = {"FARP Lautaroammo", "FARP Lautarofuel", "FARP Lautarotent1", "FARP Lautarotent2", "FARP Lautarotent3", "FARP Lautarotent4", "FARP Lautarocenter", "FARP Lautarowind"},	
["FARP Drake"] = {"FARP Drakeammo", "FARP Drakefuel", "FARP Draketent1", "FARP Draketent2", "FARP Draketent3", "FARP Draketent4", "FARP Drakecenter", "FARP Drakewind"},	
["FARP Calfucura"] = {"FARP Calfucuraammo", "FARP Calfucurafuel", "FARP Calfucuratent1", "FARP Calfucuratent2", "FARP Calfucuratent3", "FARP Calfucuratent4", "FARP Calfucuracenter", "FARP Calfucurawind"},	
["FARP Inacayal"] = {"FARP Inacayalammo", "FARP Inacayalfuel", "FARP Inacayaltent1", "FARP Inacayaltent2", "FARP Inacayaltent3", "FARP Inacayaltent4", "FARP Inacayalcenter", "FARP Inacayalwind"},	
["FARP Galvarino"] = {"FARP Galvarinoammo", "FARP Galvarinofuel", "FARP Galvarinotent1", "FARP Galvarinotent2", "FARP Galvarinotent3", "FARP Galvarinotent4", "FARP Galvarinocenter", "FARP Galvarinowind"},	
["FARP Magellan"] = {"FARP Magellanammo", "FARP Magellanfuel", "FARP Magellantent1", "FARP Magellantent2", "FARP Magellantent3", "FARP Magellantent4", "FARP Magellancenter", "FARP Magellanwind"},	
["FARP Guemes"] = {"FARP Guemesammo", "FARP Guemesfuel", "FARP Guemestent1", "FARP Guemestent2", "FARP Guemestent3", "FARP Guemestent4", "FARP Guemescenter", "FARP Guemeswind"},	
["FARP Roca"] = {"FARP Rocaammo", "FARP Rocafuel", "FARP Rocatent1", "FARP Rocatent2", "FARP Rocatent3", "FARP Rocatent4", "FARP Rocacenter", "FARP Rocawind"},	



}

env.info("Mission Setup : is completed!")


