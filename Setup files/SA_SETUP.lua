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
upgrades = {
    redcarrier = {
        blue = {},
        red = {"Molniya", "Grisha", "Rezky","Molniya","Grisha", "Molniya","Grisha", "Molniya","SpeedBoats", "SpeedBoats","Rezky","SpeedBoats"}
    },
    redcarrier2 = {
        blue = {},
        red = {"Molniya", "Grisha", "Rezky","Molniya","Grisha", "Molniya","Grisha", "Molniya","SpeedBoats", "SpeedBoats","Rezky","SpeedBoats"}
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
	ElCalafate = L10N:Get("SA_FLAVOR_EL_CALAFATE"),
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
FootholdSaveBaseName = (Era == 'Coldwar') and 'Foothold_SA_v0.2_Coldwar' or 'Foothold_SA_v0.2'

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
	['Red SAM SA-10 Fixed Bravo']   = 'Red SAM SHORAD SA-8 2',
	['Red SAM SA-10 Fixed Alpha']   = 'Red SAM SHORAD SA-8 2',
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
if Era == 'Coldwar' then
	deepSwap(upgrades,cwSwap)
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
	"blueArmor",
	-- "bSamIR",
	"bluePD",
	"bluePD 2",
	"bluePD1",
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

RandomRedPickKeepChance = {
	["Red SAM SHORAD Pantsir S1"] = 50,
	["Red SAM SHORAD Tor M2"] = 50,
}

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
----------------End Randomized upgrade pools/templates ---------------
bc = BattleCommander:new(filepath, 8, 60)
if RankingSystem then
    bc.rankFile = (lfs and (lfs.writedir() .. 'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
end
Hunt = true
---------------------------begin zone definitions(this is where a side is chosen and what flavor and upgrades each zone will have etc etc)-------------------------
zones = { 
	redcarrier = ZoneCommander:new({zone='Red Carrier North', side=1, level=25, upgrades=upgrades.redcarrier, crates={}, flavorText=flavor.redcarrier}),
	redcarrier2 = ZoneCommander:new({zone='Red Carrier South', side=1, level=25, upgrades=upgrades.redcarrier2, crates={}, flavorText=flavor.redcarrier2}),
	
	mountpleasant = ZoneCommander:new({zone='Mount Pleasant', size='mediumbig',side=1,  level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.mountpleasant}),
	portstanley = ZoneCommander:new({zone='Port Stanley', size='bignosam', side=2, level=25, upgrades=upgrades.airfieldStart, crates={}, flavorText=flavor.portstanley}),
	sancarlosfob = ZoneCommander:new({zone='San Carlos FOB', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.sancarlosfob}),
	goosegreen = ZoneCommander:new({zone='Goose Green', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.goosegreen}),
	riogrande = ZoneCommander:new({zone='Rio Grande', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.riogrande}),
	ushuaia = ZoneCommander:new({zone='Ushuaia', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.ushuaia}),
	puertowilliams = ZoneCommander:new({zone='Puerto Williams', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.puertowilliams}),
	tolhuin = ZoneCommander:new({zone='Tolhuin', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.tolhuin}),
	pampaguanaco = ZoneCommander:new({zone='Pampa Guanaco', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.pampaguanaco}),
	almiranteschroeders = ZoneCommander:new({zone='Almirante Schroeders', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.almiranteschroeders}),
	porvenir = ZoneCommander:new({zone='Porvenir', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.porvenir}),
	puntaarenas = ZoneCommander:new({zone='Punta Arenas', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.puntaarenas}),
	francobianco = ZoneCommander:new({zone='Franco Bianco', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.francobianco}),
	riogallegos = ZoneCommander:new({zone='Rio Gallegos', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.riogallegos}),
	riochico = ZoneCommander:new({zone='Rio Chico', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.riochico}),
	rioturbio = ZoneCommander:new({zone='Rio Turbio', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.rioturbio}),
	elcalafate = ZoneCommander:new({zone='El Calafate', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.elcalafate}),
	ohiggins = ZoneCommander:new({zone="O'Higgins", size='bignosam', side=1, level=25, upgrades=upgrades.airfieldStart, crates={}, flavorText=flavor.ohiggins}),
	gobernadorgregores = ZoneCommander:new({zone='Gobernador Gregores', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.gobernadorgregores}),
	puertonatales = ZoneCommander:new({zone='Puerto Natales', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.puertonatales}),
	puertosantacruz = ZoneCommander:new({zone='Puerto Santa Cruz', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.puertosantacruz}),
	comandanteluispiedrabuena = ZoneCommander:new({zone='Comandante Luis Piedrabuena', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield, crates={}, flavorText=flavor.comandanteluispiedrabuena}),
	sanjulian = ZoneCommander:new({zone='San Julian', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.sanjulian}),
	hipicoflyingclub = ZoneCommander:new({zone='Hipico Flying Club', size='mediumbig', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.sanjulian}),
	farpcaupolican = ZoneCommander:new({zone='FARP Caupolican', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.sanjulian}),
	farpsayhueque = ZoneCommander:new({zone='FARP Sayhueque', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.sanjulian}),	
	farplautaro = ZoneCommander:new({zone='FARP Lautaro', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.sanjulian}),
	farpdrake = ZoneCommander:new({zone='FARP Drake', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.sanjulian}),
	farpcalfucura = ZoneCommander:new({zone='FARP Calfucura', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.sanjulian}),	
	farpinacayal = ZoneCommander:new({zone='FARP Inacayal', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.sanjulian}),	
	farpgalvarino = ZoneCommander:new({zone='FARP Galvarino', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.sanjulian}),	
	farpmagellan = ZoneCommander:new({zone='FARP Magellan', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.sanjulian}),	
	farpguemes = ZoneCommander:new({zone='FARP Guemes', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.sanjulian}),	
	farproca = ZoneCommander:new({zone='FARP Roca', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.sanjulian}),	
	samalpha			= ZoneCommander:new({zone='SAM Alpha',        		 side=1, size='sam2', level=25, upgrades=upgrades.samalpha,     crates={},flavorText=flavor.samalpha}),
	sambravo			= ZoneCommander:new({zone='SAM Bravo',        		 side=1, size='sam', level=25, upgrades=upgrades.sambravo,     crates={},flavorText=flavor.sambravo}),
	islandsamsite			= ZoneCommander:new({zone='Island SAM Site',        		 side=1, size='sam', level=25, upgrades=upgrades.islandsamsite,     crates={},flavorText=flavor.islandsamsite}),
    rebelbase   = ZoneCommander:new({zone='Rebel Base',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints2,      crates={},flavorText=flavor.rebelbase}),
    rebelbarracks   = ZoneCommander:new({zone='Rebel Barracks',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints3,      crates={},flavorText=flavor.rebelbarracks}),
    rebelairport   = ZoneCommander:new({zone='Rebel Airport',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints4,      crates={},flavorText=flavor.rebelairport}),
	rebelcocainefarm   = ZoneCommander:new({zone='Rebel Cocaine Farm',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints5,      crates={},flavorText=flavor.rebelcocainefarm}),
	rebelhq   = ZoneCommander:new({zone='Rebel HQ',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints5,      crates={},flavorText=flavor.rebelhq}),
	gullpoint = ZoneCommander:new({zone='Gull Point', size='mediumbig', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.gullpoint}),
	estanciadarwin   = ZoneCommander:new({zone='Estancia Darwin',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints1,      crates={},flavorText=flavor.estanciadarwin}),
	
	hidden1 = ZoneCommander:new({zone='HiddenSamEWRMantisNet', side=1, level=25, upgrades=upgrades.HiddenSamEWRMantisNet, crates={}, flavorText=flavor.hidden1,ForceNeutral=true}),

}

----------------------end zone definitions-----------------------------
---------------------------------begin template definitions (this defines templates for coldwar and modern)-----------------------

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
    GroupCommander:new({name='portstanley-supply-SanCarlosFOB-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='San Carlos FOB'}),
    GroupCommander:new({name='portstanley-supply-SanCarlosFOB-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Carlos FOB'}),
    GroupCommander:new({name='portstanley-supply-MountPleasant-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Mount Pleasant'}),
    GroupCommander:new({name='portstanley-supply-MountPleasant-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Mount Pleasant'}),

    GroupCommander:new({name='portstanley-attack-SanCarlosFOB-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),
    GroupCommander:new({name='portstanley-attack-SanCarlosFOB-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='San Carlos FOB', Altitude = CasAltitude()}),
    GroupCommander:new({name='portstanley-attack-SanCarlosFOB-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='San Carlos FOB', Altitude = SeadAltitude()}),
    GroupCommander:new({name='portstanley-patrol-SanCarlosFOB-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),

    GroupCommander:new({name='portstanley-attack-MountPleasant-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mount Pleasant', Altitude = CapAltitude()}),
    GroupCommander:new({name='portstanley-attack-MountPleasant-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Mount Pleasant', Altitude = CasAltitude()}),
    GroupCommander:new({name='portstanley-attack-MountPleasant-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Mount Pleasant', Altitude = SeadAltitude()}),
    GroupCommander:new({name='portstanley-patrol-MountPleasant-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mount Pleasant', Altitude = CapAltitude()}),
})

zones.mountpleasant:addGroups({
    GroupCommander:new({name='mountpleasant-supply-PortStanley-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Port Stanley'}),
    GroupCommander:new({name='mountpleasant-supply-PortStanley-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Port Stanley'}),
    GroupCommander:new({name='mountpleasant-supply-GooseGreen-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Goose Green'}),
    GroupCommander:new({name='mountpleasant-supply-GooseGreen-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Goose Green'}),
    GroupCommander:new({name='mountpleasant-supply-SanCarlosFOB-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='San Carlos FOB'}),
    GroupCommander:new({name='mountpleasant-supply-SanCarlosFOB-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Carlos FOB'}),

    GroupCommander:new({name='mountpleasant-attack-PortStanley-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Port Stanley', Altitude = CapAltitude()}),
    GroupCommander:new({name='mountpleasant-attack-PortStanley-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Port Stanley', Altitude = CasAltitude()}),
    GroupCommander:new({name='mountpleasant-attack-PortStanley-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Port Stanley', Altitude = SeadAltitude()}),
    GroupCommander:new({name='mountpleasant-patrol-PortStanley-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Port Stanley', Altitude = CapAltitude()}),

    GroupCommander:new({name='mountpleasant-attack-GooseGreen-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Goose Green', Altitude = CapAltitude()}),
    GroupCommander:new({name='mountpleasant-attack-GooseGreen-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Goose Green', Altitude = CasAltitude()}),
    GroupCommander:new({name='mountpleasant-attack-GooseGreen-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Goose Green', Altitude = SeadAltitude()}),
    GroupCommander:new({name='mountpleasant-patrol-GooseGreen-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Goose Green', Altitude = CapAltitude()}),

    GroupCommander:new({name='mountpleasant-attack-SanCarlosFOB-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),
    GroupCommander:new({name='mountpleasant-attack-SanCarlosFOB-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='San Carlos FOB', Altitude = CasAltitude()}),
    GroupCommander:new({name='mountpleasant-attack-SanCarlosFOB-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='San Carlos FOB', Altitude = SeadAltitude()}),
    GroupCommander:new({name='mountpleasant-patrol-SanCarlosFOB-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),
})

zones.goosegreen:addGroups({
    GroupCommander:new({name='goosegreen-supply-MountPleasant-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Mount Pleasant'}),
    GroupCommander:new({name='goosegreen-supply-MountPleasant-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Mount Pleasant'}),
    GroupCommander:new({name='goosegreen-supply-SanCarlosFOB-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='San Carlos FOB'}),
    GroupCommander:new({name='goosegreen-supply-SanCarlosFOB-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Carlos FOB'}),

    GroupCommander:new({name='goosegreen-attack-MountPleasant-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mount Pleasant', Altitude = CapAltitude()}),
    GroupCommander:new({name='goosegreen-attack-MountPleasant-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Mount Pleasant', Altitude = CasAltitude()}),
    GroupCommander:new({name='goosegreen-attack-MountPleasant-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Mount Pleasant', Altitude = SeadAltitude()}),
    GroupCommander:new({name='goosegreen-patrol-MountPleasant-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mount Pleasant', Altitude = CapAltitude()}),

    GroupCommander:new({name='goosegreen-attack-SanCarlosFOB-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),
    GroupCommander:new({name='goosegreen-attack-SanCarlosFOB-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='San Carlos FOB', Altitude = CasAltitude()}),
    GroupCommander:new({name='goosegreen-attack-SanCarlosFOB-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='San Carlos FOB', Altitude = SeadAltitude()}),
    GroupCommander:new({name='goosegreen-patrol-SanCarlosFOB-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Carlos FOB', Altitude = CapAltitude()}),
	GroupCommander:new({name='goosegreen-attack-MountPleasant-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Mount Pleasant', type='surface',SetActiveMission = true}), -- ME zone: Arty-Koya-Erbil Airport

})

zones.sancarlosfob:addGroups({
    GroupCommander:new({name='sancarlosfob-supply-PortStanley-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Port Stanley'}),
    GroupCommander:new({name='sancarlosfob-supply-PortStanley-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Port Stanley'}),
    GroupCommander:new({name='sancarlosfob-supply-GooseGreen-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Goose Green'}),
    GroupCommander:new({name='sancarlosfob-supply-GooseGreen-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Goose Green'}),
    GroupCommander:new({name='sancarlosfob-supply-MountPleasant-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Mount Pleasant'}),
    GroupCommander:new({name='sancarlosfob-supply-MountPleasant-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Mount Pleasant'}),

    GroupCommander:new({name='sancarlosfob-attack-PortStanley-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Port Stanley', Altitude = CapAltitude()}),
    GroupCommander:new({name='sancarlosfob-attack-PortStanley-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Port Stanley', Altitude = CasAltitude()}),
    GroupCommander:new({name='sancarlosfob-attack-PortStanley-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Port Stanley', Altitude = SeadAltitude()}),
    GroupCommander:new({name='sancarlosfob-patrol-PortStanley-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Port Stanley', Altitude = CapAltitude()}),

    GroupCommander:new({name='sancarlosfob-attack-GooseGreen-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Goose Green', Altitude = CapAltitude()}),
    GroupCommander:new({name='sancarlosfob-attack-GooseGreen-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Goose Green', Altitude = CasAltitude()}),
    GroupCommander:new({name='sancarlosfob-attack-GooseGreen-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Goose Green', Altitude = SeadAltitude()}),
    GroupCommander:new({name='sancarlosfob-patrol-GooseGreen-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Goose Green', Altitude = CapAltitude()}),

    GroupCommander:new({name='sancarlosfob-attack-MountPleasant-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mount Pleasant', Altitude = CapAltitude()}),
    GroupCommander:new({name='sancarlosfob-attack-MountPleasant-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Mount Pleasant', Altitude = CasAltitude()}),
    GroupCommander:new({name='sancarlosfob-attack-MountPleasant-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Mount Pleasant', Altitude = SeadAltitude()}),
    GroupCommander:new({name='sancarlosfob-patrol-MountPleasant-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mount Pleasant', Altitude = CapAltitude()}),
})

zones.redcarrier2:addGroups({
})

zones.tolhuin:addGroups({
    GroupCommander:new({name='tolhuin-supply-PuertoWilliams-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Williams'}),
    GroupCommander:new({name='tolhuin-supply-PuertoWilliams-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Williams'}),
    GroupCommander:new({name='tolhuin-supply-Ushuaia-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Ushuaia'}),
    GroupCommander:new({name='tolhuin-supply-Ushuaia-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Ushuaia'}),
    GroupCommander:new({name='tolhuin-supply-PampaGuanaco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Pampa Guanaco'}),
    GroupCommander:new({name='tolhuin-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),
    GroupCommander:new({name='tolhuin-supply-RioGrande-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Grande'}),
    GroupCommander:new({name='tolhuin-supply-RioGrande-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Grande'}),

    GroupCommander:new({name='tolhuin-attack-PuertoWilliams-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),
    GroupCommander:new({name='tolhuin-attack-PuertoWilliams-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Williams', Altitude = CasAltitude()}),
    GroupCommander:new({name='tolhuin-attack-PuertoWilliams-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Williams', Altitude = SeadAltitude()}),
    GroupCommander:new({name='tolhuin-patrol-PuertoWilliams-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),

    GroupCommander:new({name='tolhuin-attack-Ushuaia-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),
    GroupCommander:new({name='tolhuin-attack-Ushuaia-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Ushuaia', Altitude = CasAltitude()}),
    GroupCommander:new({name='tolhuin-attack-Ushuaia-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Ushuaia', Altitude = SeadAltitude()}),
    GroupCommander:new({name='tolhuin-patrol-Ushuaia-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),

    GroupCommander:new({name='tolhuin-attack-PampaGuanaco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
    GroupCommander:new({name='tolhuin-attack-PampaGuanaco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Pampa Guanaco', Altitude = CasAltitude()}),
    GroupCommander:new({name='tolhuin-attack-PampaGuanaco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Pampa Guanaco', Altitude = SeadAltitude()}),
    GroupCommander:new({name='tolhuin-patrol-PampaGuanaco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),

    GroupCommander:new({name='tolhuin-attack-RioGrande-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Grande', Altitude = CapAltitude()}),
    GroupCommander:new({name='tolhuin-attack-RioGrande-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Grande', Altitude = CasAltitude()}),
    GroupCommander:new({name='tolhuin-attack-RioGrande-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Grande', Altitude = SeadAltitude()}),
    GroupCommander:new({name='tolhuin-patrol-RioGrande-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Grande', Altitude = CapAltitude()}),
})

zones.puertowilliams:addGroups({
    GroupCommander:new({name='puertowilliams-supply-Tolhuin-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Tolhuin'}),
    GroupCommander:new({name='puertowilliams-supply-Tolhuin-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Tolhuin'}),
    GroupCommander:new({name='puertowilliams-supply-Ushuaia-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Ushuaia'}),
    GroupCommander:new({name='puertowilliams-supply-Ushuaia-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Ushuaia'}),
    GroupCommander:new({name='puertowilliams-supply-PampaGuanaco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Pampa Guanaco'}),
    GroupCommander:new({name='puertowilliams-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),

    GroupCommander:new({name='puertowilliams-attack-Tolhuin-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),
    GroupCommander:new({name='puertowilliams-attack-Tolhuin-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tolhuin', Altitude = CasAltitude()}),
    GroupCommander:new({name='puertowilliams-attack-Tolhuin-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Tolhuin', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puertowilliams-patrol-Tolhuin-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),

    GroupCommander:new({name='puertowilliams-attack-Ushuaia-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),
    GroupCommander:new({name='puertowilliams-attack-Ushuaia-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Ushuaia', Altitude = CasAltitude()}),
    GroupCommander:new({name='puertowilliams-attack-Ushuaia-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Ushuaia', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puertowilliams-patrol-Ushuaia-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),

    GroupCommander:new({name='puertowilliams-attack-PampaGuanaco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
    GroupCommander:new({name='puertowilliams-attack-PampaGuanaco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Pampa Guanaco', Altitude = CasAltitude()}),
    GroupCommander:new({name='puertowilliams-attack-PampaGuanaco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Pampa Guanaco', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puertowilliams-patrol-PampaGuanaco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
})

zones.ushuaia:addGroups({
    GroupCommander:new({name='ushuaia-supply-Tolhuin-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Tolhuin'}),
    GroupCommander:new({name='ushuaia-supply-Tolhuin-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Tolhuin'}),
    GroupCommander:new({name='ushuaia-supply-PuertoWilliams-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Williams'}),
    GroupCommander:new({name='ushuaia-supply-PuertoWilliams-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Williams'}),
    GroupCommander:new({name='ushuaia-supply-PampaGuanaco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Pampa Guanaco'}),
    GroupCommander:new({name='ushuaia-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),

    GroupCommander:new({name='ushuaia-attack-Tolhuin-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),
    GroupCommander:new({name='ushuaia-attack-Tolhuin-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tolhuin', Altitude = CasAltitude()}),
    GroupCommander:new({name='ushuaia-attack-Tolhuin-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Tolhuin', Altitude = SeadAltitude()}),
    GroupCommander:new({name='ushuaia-patrol-Tolhuin-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),

    GroupCommander:new({name='ushuaia-attack-PuertoWilliams-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),
    GroupCommander:new({name='ushuaia-attack-PuertoWilliams-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Williams', Altitude = CasAltitude()}),
    GroupCommander:new({name='ushuaia-attack-PuertoWilliams-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Williams', Altitude = SeadAltitude()}),
    GroupCommander:new({name='ushuaia-patrol-PuertoWilliams-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),

    GroupCommander:new({name='ushuaia-attack-PampaGuanaco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
    GroupCommander:new({name='ushuaia-attack-PampaGuanaco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Pampa Guanaco', Altitude = CasAltitude()}),
    GroupCommander:new({name='ushuaia-attack-PampaGuanaco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Pampa Guanaco', Altitude = SeadAltitude()}),
    GroupCommander:new({name='ushuaia-patrol-PampaGuanaco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
})

zones.riogrande:addGroups({
    GroupCommander:new({name='riogrande-supply-Tolhuin-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Tolhuin'}),
    GroupCommander:new({name='riogrande-supply-Tolhuin-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Tolhuin'}),
    GroupCommander:new({name='riogrande-supply-PampaGuanaco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Pampa Guanaco'}),
    GroupCommander:new({name='riogrande-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),
    GroupCommander:new({name='riogrande-supply-FARPCaupolican-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Caupolican'}),
    GroupCommander:new({name='riogrande-supply-FARPCaupolican-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Caupolican'}),

    GroupCommander:new({name='riogrande-attack-Tolhuin-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),
    GroupCommander:new({name='riogrande-attack-Tolhuin-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tolhuin', Altitude = CasAltitude()}),
    GroupCommander:new({name='riogrande-attack-Tolhuin-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Tolhuin', Altitude = SeadAltitude()}),
    GroupCommander:new({name='riogrande-patrol-Tolhuin-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),

    GroupCommander:new({name='riogrande-attack-PampaGuanaco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
    GroupCommander:new({name='riogrande-attack-PampaGuanaco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Pampa Guanaco', Altitude = CasAltitude()}),
    GroupCommander:new({name='riogrande-attack-PampaGuanaco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Pampa Guanaco', Altitude = SeadAltitude()}),
    GroupCommander:new({name='riogrande-patrol-PampaGuanaco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),

    GroupCommander:new({name='riogrande-attack-FARPCaupolican-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),
    GroupCommander:new({name='riogrande-attack-FARPCaupolican-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Caupolican', Altitude = CasAltitude()}),
    GroupCommander:new({name='riogrande-attack-FARPCaupolican-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Caupolican', Altitude = SeadAltitude()}),
    GroupCommander:new({name='riogrande-patrol-FARPCaupolican-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),
})

zones.pampaguanaco:addGroups({
    GroupCommander:new({name='pampaguanaco-supply-Tolhuin-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Tolhuin'}),
    GroupCommander:new({name='pampaguanaco-supply-Tolhuin-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Tolhuin'}),
    GroupCommander:new({name='pampaguanaco-supply-Ushuaia-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Ushuaia'}),
    GroupCommander:new({name='pampaguanaco-supply-Ushuaia-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Ushuaia'}),
    GroupCommander:new({name='pampaguanaco-supply-PuertoWilliams-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Williams'}),
    GroupCommander:new({name='pampaguanaco-supply-PuertoWilliams-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Williams'}),
    GroupCommander:new({name='pampaguanaco-supply-RioGrande-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Grande'}),
    GroupCommander:new({name='pampaguanaco-supply-RioGrande-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Grande'}),
    GroupCommander:new({name='pampaguanaco-supply-AlmiranteSchroeders-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Almirante Schroeders'}),
    GroupCommander:new({name='pampaguanaco-supply-AlmiranteSchroeders-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Almirante Schroeders'}),
    GroupCommander:new({name='pampaguanaco-supply-FARPCaupolican-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Caupolican'}),
    GroupCommander:new({name='pampaguanaco-supply-FARPCaupolican-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Caupolican'}),

    GroupCommander:new({name='pampaguanaco-attack-Tolhuin-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-Tolhuin-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tolhuin', Altitude = CasAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-Tolhuin-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Tolhuin', Altitude = SeadAltitude()}),
    GroupCommander:new({name='pampaguanaco-patrol-Tolhuin-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tolhuin', Altitude = CapAltitude()}),

    GroupCommander:new({name='pampaguanaco-attack-Ushuaia-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-Ushuaia-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Ushuaia', Altitude = CasAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-Ushuaia-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Ushuaia', Altitude = SeadAltitude()}),
    GroupCommander:new({name='pampaguanaco-patrol-Ushuaia-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ushuaia', Altitude = CapAltitude()}),

    GroupCommander:new({name='pampaguanaco-attack-PuertoWilliams-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-PuertoWilliams-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Williams', Altitude = CasAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-PuertoWilliams-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Williams', Altitude = SeadAltitude()}),
    GroupCommander:new({name='pampaguanaco-patrol-PuertoWilliams-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Williams', Altitude = CapAltitude()}),

    GroupCommander:new({name='pampaguanaco-attack-RioGrande-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Grande', Altitude = CapAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-RioGrande-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Grande', Altitude = CasAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-RioGrande-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Grande', Altitude = SeadAltitude()}),
    GroupCommander:new({name='pampaguanaco-patrol-RioGrande-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Grande', Altitude = CapAltitude()}),

    GroupCommander:new({name='pampaguanaco-attack-AlmiranteSchroeders-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Almirante Schroeders', Altitude = CapAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-AlmiranteSchroeders-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Almirante Schroeders', Altitude = CasAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-AlmiranteSchroeders-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Almirante Schroeders', Altitude = SeadAltitude()}),
    GroupCommander:new({name='pampaguanaco-patrol-AlmiranteSchroeders-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Almirante Schroeders', Altitude = CapAltitude()}),

    GroupCommander:new({name='pampaguanaco-attack-FARPCaupolican-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-FARPCaupolican-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Caupolican', Altitude = CasAltitude()}),
    GroupCommander:new({name='pampaguanaco-attack-FARPCaupolican-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Caupolican', Altitude = SeadAltitude()}),
    GroupCommander:new({name='pampaguanaco-patrol-FARPCaupolican-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),
})

zones.almiranteschroeders:addGroups({
    GroupCommander:new({name='almiranteschroeders-supply-PampaGuanaco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Pampa Guanaco'}),
    GroupCommander:new({name='almiranteschroeders-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),
    GroupCommander:new({name='almiranteschroeders-supply-Porvenir-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Porvenir'}),
    GroupCommander:new({name='almiranteschroeders-supply-Porvenir-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Porvenir'}),

    GroupCommander:new({name='almiranteschroeders-attack-PampaGuanaco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),
    GroupCommander:new({name='almiranteschroeders-attack-PampaGuanaco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Pampa Guanaco', Altitude = CasAltitude()}),
    GroupCommander:new({name='almiranteschroeders-attack-PampaGuanaco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Pampa Guanaco', Altitude = SeadAltitude()}),
    GroupCommander:new({name='almiranteschroeders-patrol-PampaGuanaco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Pampa Guanaco', Altitude = CapAltitude()}),

    GroupCommander:new({name='almiranteschroeders-attack-Porvenir-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Porvenir', Altitude = CapAltitude()}),
    GroupCommander:new({name='almiranteschroeders-attack-Porvenir-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Porvenir', Altitude = CasAltitude()}),
    GroupCommander:new({name='almiranteschroeders-attack-Porvenir-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Porvenir', Altitude = SeadAltitude()}),
    GroupCommander:new({name='almiranteschroeders-patrol-Porvenir-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Porvenir', Altitude = CapAltitude()}),
})

zones.farpcaupolican:addGroups({
    GroupCommander:new({name='farpcaupolican-supply-RioGrande-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Grande'}),
    GroupCommander:new({name='farpcaupolican-supply-PampaGuanaco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Pampa Guanaco'}),
    GroupCommander:new({name='farpcaupolican-supply-PuntaArenas-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Punta Arenas'}),
    GroupCommander:new({name='farpcaupolican-supply-FARPSayhueque-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Sayhueque'}),
})

zones.porvenir:addGroups({
    GroupCommander:new({name='porvenir-supply-AlmiranteSchroeders-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Almirante Schroeders'}),
    GroupCommander:new({name='porvenir-supply-AlmiranteSchroeders-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Almirante Schroeders'}),
    GroupCommander:new({name='porvenir-supply-PuntaArenas-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Punta Arenas'}),
    GroupCommander:new({name='porvenir-supply-PuntaArenas-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Punta Arenas'}),

    GroupCommander:new({name='porvenir-attack-AlmiranteSchroeders-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Almirante Schroeders', Altitude = CapAltitude()}),
    GroupCommander:new({name='porvenir-attack-AlmiranteSchroeders-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Almirante Schroeders', Altitude = CasAltitude()}),
    GroupCommander:new({name='porvenir-attack-AlmiranteSchroeders-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Almirante Schroeders', Altitude = SeadAltitude()}),
    GroupCommander:new({name='porvenir-patrol-AlmiranteSchroeders-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Almirante Schroeders', Altitude = CapAltitude()}),

    GroupCommander:new({name='porvenir-attack-PuntaArenas-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),
    GroupCommander:new({name='porvenir-attack-PuntaArenas-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Punta Arenas', Altitude = CasAltitude()}),
    GroupCommander:new({name='porvenir-attack-PuntaArenas-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Punta Arenas', Altitude = SeadAltitude()}),
    GroupCommander:new({name='porvenir-patrol-PuntaArenas-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),
})

zones.puntaarenas:addGroups({
    GroupCommander:new({name='puntaarenas-supply-FARPCaupolican-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Caupolican'}),
    GroupCommander:new({name='puntaarenas-supply-FARPCaupolican-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Caupolican'}),
    GroupCommander:new({name='puntaarenas-supply-Porvenir-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Porvenir'}),
    GroupCommander:new({name='puntaarenas-supply-Porvenir-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Porvenir'}),
    GroupCommander:new({name='puntaarenas-supply-FrancoBianco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Franco Bianco'}),
    GroupCommander:new({name='puntaarenas-supply-FrancoBianco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Franco Bianco'}),
    GroupCommander:new({name='puntaarenas-supply-PuertoNatales-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Natales'}),
    GroupCommander:new({name='puntaarenas-supply-PuertoNatales-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Natales'}),

    GroupCommander:new({name='puntaarenas-attack-FARPCaupolican-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),
    GroupCommander:new({name='puntaarenas-attack-FARPCaupolican-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Caupolican', Altitude = CasAltitude()}),
    GroupCommander:new({name='puntaarenas-attack-FARPCaupolican-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Caupolican', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puntaarenas-patrol-FARPCaupolican-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Caupolican', Altitude = CapAltitude()}),

    GroupCommander:new({name='puntaarenas-attack-Porvenir-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Porvenir', Altitude = CapAltitude()}),
    GroupCommander:new({name='puntaarenas-attack-Porvenir-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Porvenir', Altitude = CasAltitude()}),
    GroupCommander:new({name='puntaarenas-attack-Porvenir-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Porvenir', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puntaarenas-patrol-Porvenir-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Porvenir', Altitude = CapAltitude()}),

    GroupCommander:new({name='puntaarenas-attack-FrancoBianco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Franco Bianco', Altitude = CapAltitude()}),
    GroupCommander:new({name='puntaarenas-attack-FrancoBianco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Franco Bianco', Altitude = CasAltitude()}),
    GroupCommander:new({name='puntaarenas-attack-FrancoBianco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Franco Bianco', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puntaarenas-patrol-FrancoBianco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Franco Bianco', Altitude = CapAltitude()}),

    GroupCommander:new({name='puntaarenas-attack-PuertoNatales-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),
    GroupCommander:new({name='puntaarenas-attack-PuertoNatales-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Natales', Altitude = CasAltitude()}),
    GroupCommander:new({name='puntaarenas-attack-PuertoNatales-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Natales', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puntaarenas-patrol-PuertoNatales-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),
})

zones.francobianco:addGroups({
    GroupCommander:new({name='francobianco-supply-PuntaArenas-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Punta Arenas'}),
    GroupCommander:new({name='francobianco-supply-PuntaArenas-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Punta Arenas'}),
    GroupCommander:new({name='francobianco-supply-FARPSayhueque-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Sayhueque'}),
    GroupCommander:new({name='francobianco-supply-FARPSayhueque-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Sayhueque'}),
    GroupCommander:new({name='francobianco-supply-RioGallegos-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Gallegos'}),
    GroupCommander:new({name='francobianco-supply-RioGallegos-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Gallegos'}),

    GroupCommander:new({name='francobianco-attack-PuntaArenas-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),
    GroupCommander:new({name='francobianco-attack-PuntaArenas-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Punta Arenas', Altitude = CasAltitude()}),
    GroupCommander:new({name='francobianco-attack-PuntaArenas-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Punta Arenas', Altitude = SeadAltitude()}),
    GroupCommander:new({name='francobianco-patrol-PuntaArenas-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),

    GroupCommander:new({name='francobianco-attack-FARPSayhueque-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Sayhueque', Altitude = CapAltitude()}),
    GroupCommander:new({name='francobianco-attack-FARPSayhueque-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Sayhueque', Altitude = CasAltitude()}),
    GroupCommander:new({name='francobianco-attack-FARPSayhueque-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Sayhueque', Altitude = SeadAltitude()}),
    GroupCommander:new({name='francobianco-patrol-FARPSayhueque-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Sayhueque', Altitude = CapAltitude()}),

    GroupCommander:new({name='francobianco-attack-RioGallegos-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Gallegos', Altitude = CapAltitude()}),
    GroupCommander:new({name='francobianco-attack-RioGallegos-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Gallegos', Altitude = CasAltitude()}),
    GroupCommander:new({name='francobianco-attack-RioGallegos-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Gallegos', Altitude = SeadAltitude()}),
    GroupCommander:new({name='francobianco-patrol-RioGallegos-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Gallegos', Altitude = CapAltitude()}),
})

zones.farpsayhueque:addGroups({
    GroupCommander:new({name='farpsayhueque-supply-FARPCaupolican-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Caupolican'}),
    GroupCommander:new({name='farpsayhueque-supply-FrancoBianco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Franco Bianco'}),
    GroupCommander:new({name='farpsayhueque-supply-FARPLautaro-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Lautaro'}),
})

zones.farplautaro:addGroups({
    GroupCommander:new({name='farplautaro-supply-FARPSayhueque-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Sayhueque'}),
    GroupCommander:new({name='farplautaro-supply-RioChico-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Chico'}),
    GroupCommander:new({name='farplautaro-supply-FARPDrake-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Drake'}),
})

zones.riochico:addGroups({
    GroupCommander:new({name='riochico-supply-FARPLautaro-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Lautaro'}),
    GroupCommander:new({name='riochico-supply-FARPLautaro-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Lautaro'}),
    GroupCommander:new({name='riochico-supply-RioGallegos-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Gallegos'}),
    GroupCommander:new({name='riochico-supply-RioGallegos-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Gallegos'}),
    GroupCommander:new({name='riochico-supply-FARPDrake-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Drake'}),
    GroupCommander:new({name='riochico-supply-FARPDrake-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Drake'}),

    GroupCommander:new({name='riochico-attack-FARPLautaro-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Lautaro', Altitude = CapAltitude()}),
    GroupCommander:new({name='riochico-attack-FARPLautaro-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Lautaro', Altitude = CasAltitude()}),
    GroupCommander:new({name='riochico-attack-FARPLautaro-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Lautaro', Altitude = SeadAltitude()}),
    GroupCommander:new({name='riochico-patrol-FARPLautaro-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Lautaro', Altitude = CapAltitude()}),

    GroupCommander:new({name='riochico-attack-RioGallegos-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Gallegos', Altitude = CapAltitude()}),
    GroupCommander:new({name='riochico-attack-RioGallegos-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Gallegos', Altitude = CasAltitude()}),
    GroupCommander:new({name='riochico-attack-RioGallegos-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Gallegos', Altitude = SeadAltitude()}),
    GroupCommander:new({name='riochico-patrol-RioGallegos-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Gallegos', Altitude = CapAltitude()}),

    GroupCommander:new({name='riochico-attack-FARPDrake-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Drake', Altitude = CapAltitude()}),
    GroupCommander:new({name='riochico-attack-FARPDrake-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Drake', Altitude = CasAltitude()}),
    GroupCommander:new({name='riochico-attack-FARPDrake-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Drake', Altitude = SeadAltitude()}),
    GroupCommander:new({name='riochico-patrol-FARPDrake-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Drake', Altitude = CapAltitude()}),
})

zones.riogallegos:addGroups({
    GroupCommander:new({name='riogallegos-supply-FrancoBianco-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Franco Bianco'}),
    GroupCommander:new({name='riogallegos-supply-FrancoBianco-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Franco Bianco'}),
    GroupCommander:new({name='riogallegos-supply-RioChico-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Chico'}),
    GroupCommander:new({name='riogallegos-supply-RioChico-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Chico'}),
    GroupCommander:new({name='riogallegos-supply-SanJulian-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='San Julian'}),
    GroupCommander:new({name='riogallegos-supply-SanJulian-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Julian'}),

    GroupCommander:new({name='riogallegos-attack-FrancoBianco-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Franco Bianco', Altitude = CapAltitude()}),
    GroupCommander:new({name='riogallegos-attack-FrancoBianco-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Franco Bianco', Altitude = CasAltitude()}),
    GroupCommander:new({name='riogallegos-attack-FrancoBianco-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Franco Bianco', Altitude = SeadAltitude()}),
    GroupCommander:new({name='riogallegos-patrol-FrancoBianco-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Franco Bianco', Altitude = CapAltitude()}),

    GroupCommander:new({name='riogallegos-attack-RioChico-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Chico', Altitude = CapAltitude()}),
    GroupCommander:new({name='riogallegos-attack-RioChico-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Chico', Altitude = CasAltitude()}),
    GroupCommander:new({name='riogallegos-attack-RioChico-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Chico', Altitude = SeadAltitude()}),
    GroupCommander:new({name='riogallegos-patrol-RioChico-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Chico', Altitude = CapAltitude()}),

    GroupCommander:new({name='riogallegos-attack-SanJulian-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Julian', Altitude = CapAltitude()}),
    GroupCommander:new({name='riogallegos-attack-SanJulian-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='San Julian', Altitude = CasAltitude()}),
    GroupCommander:new({name='riogallegos-attack-SanJulian-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='San Julian', Altitude = SeadAltitude()}),
    GroupCommander:new({name='riogallegos-patrol-SanJulian-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Julian', Altitude = CapAltitude()}),
})

zones.farpdrake:addGroups({
    GroupCommander:new({name='farpdrake-supply-FARPLautaro-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Lautaro'}),
    GroupCommander:new({name='farpdrake-supply-RioChico-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Chico'}),
    GroupCommander:new({name='farpdrake-supply-FARPCalfucura-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Calfucura'}),
    GroupCommander:new({name='farpdrake-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),
})

zones.rioturbio:addGroups({
    GroupCommander:new({name='rioturbio-supply-PuertoNatales-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Natales'}),
    GroupCommander:new({name='rioturbio-supply-PuertoNatales-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Natales'}),
    GroupCommander:new({name='rioturbio-supply-ElCalafate-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='El Calafate'}),
    GroupCommander:new({name='rioturbio-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),

    GroupCommander:new({name='rioturbio-attack-PuertoNatales-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),
    GroupCommander:new({name='rioturbio-attack-PuertoNatales-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Natales', Altitude = CasAltitude()}),
    GroupCommander:new({name='rioturbio-attack-PuertoNatales-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Natales', Altitude = SeadAltitude()}),
    GroupCommander:new({name='rioturbio-patrol-PuertoNatales-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),

    GroupCommander:new({name='rioturbio-attack-ElCalafate-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),
    GroupCommander:new({name='rioturbio-attack-ElCalafate-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='El Calafate', Altitude = CasAltitude()}),
    GroupCommander:new({name='rioturbio-attack-ElCalafate-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='El Calafate', Altitude = SeadAltitude()}),
    GroupCommander:new({name='rioturbio-patrol-ElCalafate-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),
})

zones.puertonatales:addGroups({
    GroupCommander:new({name='puertonatales-supply-PuntaArenas-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Punta Arenas'}),
    GroupCommander:new({name='puertonatales-supply-PuntaArenas-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Punta Arenas'}),
    GroupCommander:new({name='puertonatales-supply-RioTurbio-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Turbio'}),
    GroupCommander:new({name='puertonatales-supply-RioTurbio-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Turbio'}),
    GroupCommander:new({name='puertonatales-supply-ElCalafate-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='El Calafate'}),
    GroupCommander:new({name='puertonatales-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),

    GroupCommander:new({name='puertonatales-attack-PuntaArenas-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),
    GroupCommander:new({name='puertonatales-attack-PuntaArenas-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Punta Arenas', Altitude = CasAltitude()}),
    GroupCommander:new({name='puertonatales-attack-PuntaArenas-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Punta Arenas', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puertonatales-patrol-PuntaArenas-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Punta Arenas', Altitude = CapAltitude()}),

    GroupCommander:new({name='puertonatales-attack-RioTurbio-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Turbio', Altitude = CapAltitude()}),
    GroupCommander:new({name='puertonatales-attack-RioTurbio-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Turbio', Altitude = CasAltitude()}),
    GroupCommander:new({name='puertonatales-attack-RioTurbio-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Turbio', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puertonatales-patrol-RioTurbio-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Turbio', Altitude = CapAltitude()}),

    GroupCommander:new({name='puertonatales-attack-ElCalafate-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),
    GroupCommander:new({name='puertonatales-attack-ElCalafate-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='El Calafate', Altitude = CasAltitude()}),
    GroupCommander:new({name='puertonatales-attack-ElCalafate-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='El Calafate', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puertonatales-patrol-ElCalafate-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),
})

zones.farpcalfucura:addGroups({
    GroupCommander:new({name='farpcalfucura-supply-FARPDrake-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Drake'}),
    GroupCommander:new({name='farpcalfucura-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),
    GroupCommander:new({name='farpcalfucura-supply-FARPInacayal-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Inacayal'}),
})

zones.elcalafate:addGroups({
    GroupCommander:new({name='elcalafate-supply-FARPDrake-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Drake'}),
    GroupCommander:new({name='elcalafate-supply-FARPDrake-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Drake'}),
    GroupCommander:new({name='elcalafate-supply-RioTurbio-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Turbio'}),
    GroupCommander:new({name='elcalafate-supply-RioTurbio-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Turbio'}),
    GroupCommander:new({name='elcalafate-supply-PuertoNatales-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Natales'}),
    GroupCommander:new({name='elcalafate-supply-PuertoNatales-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Natales'}),
    GroupCommander:new({name='elcalafate-supply-FARPCalfucura-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Calfucura'}),
    GroupCommander:new({name='elcalafate-supply-FARPCalfucura-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Calfucura'}),
    GroupCommander:new({name='elcalafate-supply-FARPInacayal-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Inacayal'}),
    GroupCommander:new({name='elcalafate-supply-FARPInacayal-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Inacayal'}),
    GroupCommander:new({name='elcalafate-supply-GobernadorGregores-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Gobernador Gregores'}),
    GroupCommander:new({name='elcalafate-supply-GobernadorGregores-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Gobernador Gregores'}),

    GroupCommander:new({name='elcalafate-attack-FARPDrake-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Drake', Altitude = CapAltitude()}),
    GroupCommander:new({name='elcalafate-attack-FARPDrake-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Drake', Altitude = CasAltitude()}),
    GroupCommander:new({name='elcalafate-attack-FARPDrake-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Drake', Altitude = SeadAltitude()}),
    GroupCommander:new({name='elcalafate-patrol-FARPDrake-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Drake', Altitude = CapAltitude()}),

    GroupCommander:new({name='elcalafate-attack-RioTurbio-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Turbio', Altitude = CapAltitude()}),
    GroupCommander:new({name='elcalafate-attack-RioTurbio-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Turbio', Altitude = CasAltitude()}),
    GroupCommander:new({name='elcalafate-attack-RioTurbio-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Turbio', Altitude = SeadAltitude()}),
    GroupCommander:new({name='elcalafate-patrol-RioTurbio-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Turbio', Altitude = CapAltitude()}),

    GroupCommander:new({name='elcalafate-attack-PuertoNatales-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),
    GroupCommander:new({name='elcalafate-attack-PuertoNatales-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Natales', Altitude = CasAltitude()}),
    GroupCommander:new({name='elcalafate-attack-PuertoNatales-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Natales', Altitude = SeadAltitude()}),
    GroupCommander:new({name='elcalafate-patrol-PuertoNatales-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Natales', Altitude = CapAltitude()}),

    GroupCommander:new({name='elcalafate-attack-FARPCalfucura-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Calfucura', Altitude = CapAltitude()}),
    GroupCommander:new({name='elcalafate-attack-FARPCalfucura-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Calfucura', Altitude = CasAltitude()}),
    GroupCommander:new({name='elcalafate-attack-FARPCalfucura-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Calfucura', Altitude = SeadAltitude()}),
    GroupCommander:new({name='elcalafate-patrol-FARPCalfucura-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Calfucura', Altitude = CapAltitude()}),

    GroupCommander:new({name='elcalafate-attack-FARPInacayal-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Inacayal', Altitude = CapAltitude()}),
    GroupCommander:new({name='elcalafate-attack-FARPInacayal-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Inacayal', Altitude = CasAltitude()}),
    GroupCommander:new({name='elcalafate-attack-FARPInacayal-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Inacayal', Altitude = SeadAltitude()}),
    GroupCommander:new({name='elcalafate-patrol-FARPInacayal-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Inacayal', Altitude = CapAltitude()}),

    GroupCommander:new({name='elcalafate-attack-GobernadorGregores-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gobernador Gregores', Altitude = CapAltitude()}),
    GroupCommander:new({name='elcalafate-attack-GobernadorGregores-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Gobernador Gregores', Altitude = CasAltitude()}),
    GroupCommander:new({name='elcalafate-attack-GobernadorGregores-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Gobernador Gregores', Altitude = SeadAltitude()}),
    GroupCommander:new({name='elcalafate-patrol-GobernadorGregores-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gobernador Gregores', Altitude = CapAltitude()}),
})

zones.farpinacayal:addGroups({
    GroupCommander:new({name='farpinacayal-supply-FARPCalfucura-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Calfucura'}),
    GroupCommander:new({name='farpinacayal-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),
    GroupCommander:new({name='farpinacayal-supply-FARPGalvarino-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Galvarino'}),
})

zones.comandanteluispiedrabuena:addGroups({
    GroupCommander:new({name='comandanteluispiedrabuena-supply-PuertoSantaCruz-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Santa Cruz'}),
    GroupCommander:new({name='comandanteluispiedrabuena-supply-PuertoSantaCruz-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Santa Cruz'}),
    GroupCommander:new({name='comandanteluispiedrabuena-supply-SanJulian-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='San Julian'}),
    GroupCommander:new({name='comandanteluispiedrabuena-supply-SanJulian-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Julian'}),

    GroupCommander:new({name='comandanteluispiedrabuena-attack-PuertoSantaCruz-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Santa Cruz', Altitude = CapAltitude()}),
    GroupCommander:new({name='comandanteluispiedrabuena-attack-PuertoSantaCruz-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Santa Cruz', Altitude = CasAltitude()}),
    GroupCommander:new({name='comandanteluispiedrabuena-attack-PuertoSantaCruz-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Santa Cruz', Altitude = SeadAltitude()}),
    GroupCommander:new({name='comandanteluispiedrabuena-patrol-PuertoSantaCruz-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Santa Cruz', Altitude = CapAltitude()}),

    GroupCommander:new({name='comandanteluispiedrabuena-attack-SanJulian-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Julian', Altitude = CapAltitude()}),
    GroupCommander:new({name='comandanteluispiedrabuena-attack-SanJulian-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='San Julian', Altitude = CasAltitude()}),
    GroupCommander:new({name='comandanteluispiedrabuena-attack-SanJulian-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='San Julian', Altitude = SeadAltitude()}),
    GroupCommander:new({name='comandanteluispiedrabuena-patrol-SanJulian-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='San Julian', Altitude = CapAltitude()}),
})

zones.puertosantacruz:addGroups({
    GroupCommander:new({name='puertosantacruz-supply-ComandanteLuisPiedrabuena-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Comandante Luis Piedrabuena'}),
    GroupCommander:new({name='puertosantacruz-supply-ComandanteLuisPiedrabuena-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Comandante Luis Piedrabuena'}),
    GroupCommander:new({name='puertosantacruz-supply-FARPGalvarino-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Galvarino'}),
    GroupCommander:new({name='puertosantacruz-supply-FARPGalvarino-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Galvarino'}),
    GroupCommander:new({name='puertosantacruz-supply-GobernadorGregores-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Gobernador Gregores'}),
    GroupCommander:new({name='puertosantacruz-supply-GobernadorGregores-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Gobernador Gregores'}),

    GroupCommander:new({name='puertosantacruz-attack-ComandanteLuisPiedrabuena-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Comandante Luis Piedrabuena', Altitude = CapAltitude()}),
    GroupCommander:new({name='puertosantacruz-attack-ComandanteLuisPiedrabuena-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Comandante Luis Piedrabuena', Altitude = CasAltitude()}),
    GroupCommander:new({name='puertosantacruz-attack-ComandanteLuisPiedrabuena-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Comandante Luis Piedrabuena', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puertosantacruz-patrol-ComandanteLuisPiedrabuena-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Comandante Luis Piedrabuena', Altitude = CapAltitude()}),

    GroupCommander:new({name='puertosantacruz-attack-FARPGalvarino-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Galvarino', Altitude = CapAltitude()}),
    GroupCommander:new({name='puertosantacruz-attack-FARPGalvarino-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Galvarino', Altitude = CasAltitude()}),
    GroupCommander:new({name='puertosantacruz-attack-FARPGalvarino-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Galvarino', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puertosantacruz-patrol-FARPGalvarino-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Galvarino', Altitude = CapAltitude()}),

    GroupCommander:new({name='puertosantacruz-attack-GobernadorGregores-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gobernador Gregores', Altitude = CapAltitude()}),
    GroupCommander:new({name='puertosantacruz-attack-GobernadorGregores-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Gobernador Gregores', Altitude = CasAltitude()}),
    GroupCommander:new({name='puertosantacruz-attack-GobernadorGregores-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Gobernador Gregores', Altitude = SeadAltitude()}),
    GroupCommander:new({name='puertosantacruz-patrol-GobernadorGregores-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gobernador Gregores', Altitude = CapAltitude()}),
})

zones.farpgalvarino:addGroups({
    GroupCommander:new({name='farpgalvarino-supply-FARPInacayal-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Inacayal'}),
    GroupCommander:new({name='farpgalvarino-supply-PuertoSantaCruz-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Santa Cruz'}),
    GroupCommander:new({name='farpgalvarino-supply-FARPMagellan-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Magellan'}),
})

zones.sanjulian:addGroups({
    GroupCommander:new({name='sanjulian-supply-RioGallegos-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Rio Gallegos'}),
    GroupCommander:new({name='sanjulian-supply-RioGallegos-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Rio Gallegos'}),
    GroupCommander:new({name='sanjulian-supply-ComandanteLuisPiedrabuena-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Comandante Luis Piedrabuena'}),
    GroupCommander:new({name='sanjulian-supply-ComandanteLuisPiedrabuena-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Comandante Luis Piedrabuena'}),
    GroupCommander:new({name='sanjulian-supply-FARPMagellan-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Magellan'}),
    GroupCommander:new({name='sanjulian-supply-FARPMagellan-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Magellan'}),
    GroupCommander:new({name='sanjulian-supply-FARPGuemes-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Guemes'}),
    GroupCommander:new({name='sanjulian-supply-FARPGuemes-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Guemes'}),

    GroupCommander:new({name='sanjulian-attack-RioGallegos-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Gallegos', Altitude = CapAltitude()}),
    GroupCommander:new({name='sanjulian-attack-RioGallegos-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rio Gallegos', Altitude = CasAltitude()}),
    GroupCommander:new({name='sanjulian-attack-RioGallegos-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rio Gallegos', Altitude = SeadAltitude()}),
    GroupCommander:new({name='sanjulian-patrol-RioGallegos-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rio Gallegos', Altitude = CapAltitude()}),

    GroupCommander:new({name='sanjulian-attack-ComandanteLuisPiedrabuena-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Comandante Luis Piedrabuena', Altitude = CapAltitude()}),
    GroupCommander:new({name='sanjulian-attack-ComandanteLuisPiedrabuena-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Comandante Luis Piedrabuena', Altitude = CasAltitude()}),
    GroupCommander:new({name='sanjulian-attack-ComandanteLuisPiedrabuena-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Comandante Luis Piedrabuena', Altitude = SeadAltitude()}),
    GroupCommander:new({name='sanjulian-patrol-ComandanteLuisPiedrabuena-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Comandante Luis Piedrabuena', Altitude = CapAltitude()}),

    GroupCommander:new({name='sanjulian-attack-FARPMagellan-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Magellan', Altitude = CapAltitude()}),
    GroupCommander:new({name='sanjulian-attack-FARPMagellan-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Magellan', Altitude = CasAltitude()}),
    GroupCommander:new({name='sanjulian-attack-FARPMagellan-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Magellan', Altitude = SeadAltitude()}),
    GroupCommander:new({name='sanjulian-patrol-FARPMagellan-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Magellan', Altitude = CapAltitude()}),

    GroupCommander:new({name='sanjulian-attack-FARPGuemes-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Guemes', Altitude = CapAltitude()}),
    GroupCommander:new({name='sanjulian-attack-FARPGuemes-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Guemes', Altitude = CasAltitude()}),
    GroupCommander:new({name='sanjulian-attack-FARPGuemes-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Guemes', Altitude = SeadAltitude()}),
    GroupCommander:new({name='sanjulian-patrol-FARPGuemes-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Guemes', Altitude = CapAltitude()}),
})

zones.farpmagellan:addGroups({
    GroupCommander:new({name='farpmagellan-supply-FARPGalvarino-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Galvarino'}),
    GroupCommander:new({name='farpmagellan-supply-SanJulian-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Julian'}),
    GroupCommander:new({name='farpmagellan-supply-FARPGuemes-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Guemes'}),
})

zones.gobernadorgregores:addGroups({
    GroupCommander:new({name='gobernadorgregores-supply-ElCalafate-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='El Calafate'}),
    GroupCommander:new({name='gobernadorgregores-supply-ElCalafate-helo', mission='supply', template='HeloSupplyTemplate', targetzone='El Calafate'}),
    GroupCommander:new({name='gobernadorgregores-supply-PuertoSantaCruz-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Puerto Santa Cruz'}),
    GroupCommander:new({name='gobernadorgregores-supply-PuertoSantaCruz-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Puerto Santa Cruz'}),

    GroupCommander:new({name='gobernadorgregores-attack-ElCalafate-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),
    GroupCommander:new({name='gobernadorgregores-attack-ElCalafate-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='El Calafate', Altitude = CasAltitude()}),
    GroupCommander:new({name='gobernadorgregores-attack-ElCalafate-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='El Calafate', Altitude = SeadAltitude()}),
    GroupCommander:new({name='gobernadorgregores-patrol-ElCalafate-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='El Calafate', Altitude = CapAltitude()}),

    GroupCommander:new({name='gobernadorgregores-attack-PuertoSantaCruz-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Santa Cruz', Altitude = CapAltitude()}),
    GroupCommander:new({name='gobernadorgregores-attack-PuertoSantaCruz-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Puerto Santa Cruz', Altitude = CasAltitude()}),
    GroupCommander:new({name='gobernadorgregores-attack-PuertoSantaCruz-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Puerto Santa Cruz', Altitude = SeadAltitude()}),
    GroupCommander:new({name='gobernadorgregores-patrol-PuertoSantaCruz-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Puerto Santa Cruz', Altitude = CapAltitude()}),
})

zones.farpguemes:addGroups({
    GroupCommander:new({name='farpguemes-supply-SanJulian-helo', mission='supply', template='HeloSupplyTemplate', targetzone='San Julian'}),
    GroupCommander:new({name='farpguemes-supply-FARPMagellan-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Magellan'}),
    GroupCommander:new({name='farpguemes-supply-FARPRoca-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Roca'}),
})

zones.farproca:addGroups({
    GroupCommander:new({name='farproca-supply-FARPGuemes-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Guemes'}),
})

zones.ohiggins:addGroups({
    GroupCommander:new({name='ohiggins-supply-FARPRoca-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='FARP Roca'}),
    GroupCommander:new({name='ohiggins-supply-FARPRoca-helo', mission='supply', template='HeloSupplyTemplate', targetzone='FARP Roca'}),

    GroupCommander:new({name='ohiggins-attack-FARPRoca-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Roca', Altitude = CapAltitude()}),
    GroupCommander:new({name='ohiggins-attack-FARPRoca-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='FARP Roca', Altitude = CasAltitude()}),
    GroupCommander:new({name='ohiggins-attack-FARPRoca-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FARP Roca', Altitude = SeadAltitude()}),
    GroupCommander:new({name='ohiggins-patrol-FARPRoca-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='FARP Roca', Altitude = CapAltitude()}),
})
-------------------------------end of GroupCommander Routes-------------------------------

---------------Start of airbase definitions(this is what allows you to spawn at the airbase and allows helos------------------------

zones.mountpleasant.isHeloSpawn = true
zones.mountpleasant.airbaseName = 'Mount Pleasant'

zones.portstanley.isHeloSpawn = true
zones.portstanley.airbaseName = 'Port Stanley'
zones.portstanley.LogisticCenter = true

zones.sancarlosfob.isHeloSpawn = true
zones.sancarlosfob.airbaseName = 'San Carlos FOB'

zones.goosegreen.isHeloSpawn = true
zones.goosegreen.airbaseName = 'Goose Green'

zones.riogrande.isHeloSpawn = true
zones.riogrande.airbaseName = 'Rio Grande'

zones.ushuaia.isHeloSpawn = true
zones.ushuaia.airbaseName = 'Ushuaia'

zones.puertowilliams.isHeloSpawn = true
zones.puertowilliams.airbaseName = 'Puerto Williams'

zones.tolhuin.isHeloSpawn = true
zones.tolhuin.airbaseName = 'Tolhuin'

zones.pampaguanaco.isHeloSpawn = true
zones.pampaguanaco.airbaseName = 'Pampa Guanaco'

zones.almiranteschroeders.isHeloSpawn = true
zones.almiranteschroeders.airbaseName = 'Almirante Schroeders'

zones.porvenir.isHeloSpawn = true
zones.porvenir.airbaseName = 'Porvenir'

zones.puntaarenas.isHeloSpawn = true
zones.puntaarenas.airbaseName = 'Punta Arenas'

zones.francobianco.isHeloSpawn = true
zones.francobianco.airbaseName = 'Franco Bianco'

zones.riogallegos.isHeloSpawn = true
zones.riogallegos.airbaseName = 'Rio Gallegos'

zones.riochico.isHeloSpawn = true
zones.riochico.airbaseName = 'Rio Chico'

zones.rioturbio.isHeloSpawn = true
zones.rioturbio.airbaseName = 'Rio Turbio'

zones.elcalafate.isHeloSpawn = true
zones.elcalafate.airbaseName = 'El Calafate'

zones.ohiggins.isHeloSpawn = true
zones.ohiggins.airbaseName = "O'Higgins"
zones.ohiggins.LogisticCenter = true


zones.gobernadorgregores.isHeloSpawn = true
zones.gobernadorgregores.airbaseName = 'Gobernador Gregores'

zones.puertosantacruz.isHeloSpawn = true
zones.puertosantacruz.airbaseName = 'Puerto Santa Cruz'

zones.comandanteluispiedrabuena.isHeloSpawn = true
zones.comandanteluispiedrabuena.airbaseName = 'Comandante Luis Piedrabuena'

zones.sanjulian.isHeloSpawn = true
zones.sanjulian.airbaseName = 'San Julian'

zones.farpcaupolican.isHeloSpawn = true
zones.farpcaupolican.airbaseName = 'FARP Caupolican'

zones.farpsayhueque.isHeloSpawn = true
zones.farpsayhueque.airbaseName = 'FARP Sayhueque'

zones.farplautaro.isHeloSpawn = true
zones.farplautaro.airbaseName = 'FARP Lautaro'

zones.farpdrake.isHeloSpawn = true
zones.farpdrake.airbaseName = 'FARP Drake'

zones.farpcalfucura.isHeloSpawn = true
zones.farpcalfucura.airbaseName = 'FARP Calfucura'

zones.farpinacayal.isHeloSpawn = true
zones.farpinacayal.airbaseName = 'FARP Inacayal'

zones.farpgalvarino.isHeloSpawn = true
zones.farpgalvarino.airbaseName = 'FARP Galvarino'

zones.farpmagellan.isHeloSpawn = true
zones.farpmagellan.airbaseName = 'FARP Magellan'

zones.farpguemes.isHeloSpawn = true
zones.farpguemes.airbaseName = 'FARP Guemes'

zones.farproca.isHeloSpawn = true
zones.farproca.airbaseName = 'FARP Roca'

--------------------------------------------end Airbase definitions------------------------
for i,v in pairs(zones) do
	bc:addZone(v)
end

---------------------------Begin connections (this is what draws lines between each point--------------------------
-- AIRFIELD NETWORK (BIDIRECTIONAL)
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


zones.estanciadarwin:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Estancia Darwin"),20)
end, 'disableestanciadarwin')

zones.gullpoint:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Gull Point"),20)
end, 'disablegullpoint')

zones.rebelhq:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Rebel HQ"),20)
end, 'disablerebelhq')

zones.rebelbase:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Rebel Base"),20)
end, 'disablerebelbase')

zones.islandsamsite:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "the Island SAM Site"),20)
end, 'disableislandsamsite')

zones.samalpha:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "SAM Alpha"),20)
end, 'disablesamalpha')

zones.sambravo:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "SAM Bravo"),20)
end, 'disablesambravo')

zones.rebelbarracks:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Rebel Barracks"),20)
end, 'disablerebelbarracks')

zones.rebelairport:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Rebel Airport"),20)
end, 'disablerebelairport')

zones.rebelcocainefarm:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("SA_SETUP_ENEMIES_DEFEATED", "Rebel Cocaine Farm"),20)
end, 'disablerebelcocainefarm')


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

	if zones.redcarrier.wasBlue and not IsGroupActive('CVN-73') then
		activateGroupIfNotActive('CVN-73')
		activateGroupIfNotActive('Tarawa North')
		destroyGroupIfActive('CVN-72')
		destroyGroupIfActive('CVN-74')
		checkWeaponsList('Tarawa')
		timer.scheduleFunction(function()
			checkWeaponsList('CVN-73')
			checkWeaponsList('Tarawa North')
		end, {}, timer.getTime() + 10)
	end
	

	if zones.redcarrier2.wasBlue and not IsGroupActive('CVN-75') then
		activateGroupIfNotActive('CVN-75')
		activateGroupIfNotActive('CVN-59')
		activateGroupIfNotActive('Tarawa South')
		destroyGroupIfActive('CVN-72')
		destroyGroupIfActive('CVN-74')
		timer.scheduleFunction(function()
			checkWeaponsList('CVN-75')
			checkWeaponsList('Tarawa South')
			checkWeaponsList('CVN-59')
		end, {}, timer.getTime() + 10)
	end

	updateCarrierNavigationAreas(changedZone)
end

----------------------------end connections --------------------------------

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
            trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_ZONE_FULLY_UPGRADED", params.zone.zone),15)
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
		zn:spawnGroup((Era == 'Coldwar') and 'ca-tanks-Coldwar' or 'ca-tanks')
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
		zn:spawnGroup('ca-arty')
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
		zn:spawnGroup('ca-recon')
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
		zn:spawnGroup('ca-airdef')
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
bc:registerShopItem('intel',LTGet("SYRIA_SHOP_ITEM_INTEL_ENEMY"),ShopPrices.intel,function(sender)
	return LTGet("SA_SHOP_CHOOSE_TARGET_ZONE")
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		intelActiveZones[params.zone.zone] = true
		startZoneIntel(params.zone.zone)
		trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_SHOP_GATHERING_INTEL", params.zone.zone), 10)
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
-- end red shop

local infMenu=nil
bc:registerShopItem('zinf',LTGet("SA_SHOP_ITEM_UPGRADE_INFANTRY"),ShopPrices.zinf,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side == 2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('blueInfantry') -- checked
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock then
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
local samLabel = function(T)
	return (Era == 'Coldwar') and LT(T):Get("SA_SHOP_ITEM_UPGRADE_HAWK")
	                           or  LT(T):Get("SA_SHOP_ITEM_UPGRADE_NASAMS")
end
local samMenu=nil
bc:registerShopItem('zsam',samLabel,ShopPrices.zsam,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot((Era == 'Coldwar') and 'blueHAWK-Coldwar' or 'bluePD1') --checked
		bc:refreshZoneLabel(params.zone.zone)
		local sys = (Era == 'Coldwar') and 'Hawk' or 'Nasams'
        if bc.globalExtraUnlock then
            trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED", sys, params.zone.zone, tostring(ShopPrices.zsam)),10)
        else
            trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED_EXTRA", sys, params.zone.zone, tostring(ShopPrices.zsam)),30)
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

local himarsMenu=nil
bc:registerShopItem('zhimars',LTGet("SA_SHOP_ITEM_UPGRADE_HIMARS"),ShopPrices.zhimars,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('HiMars')
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock then
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

bc:registerShopItem('zlogc',LTGet("SA_SHOP_ITEM_LOGISTIC_CENTER"),ShopPrices.zlogc,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone then
		return bc:applyLogisticCenterUpgrade(params.zone)
	end
	return LTGet("SA_SHOP_MUST_PICK_FRIENDLY_ZONE")
end)
bc.shopItems['zlogc'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not zoneObj.LogisticCenter
	end,
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_AIRBASE_ZONES"),
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
bc.shopItems['zlogc'].groupZoneSelector.candidateBucket = 'blue_airbase_unsuspended'
bc.shopItems['zlogc'].groupZoneSelector.refreshTags = { 'warehouse_targets' }
bc.shopItems['zwh50'].groupZoneSelector.candidateBucket = 'warehouse_targets'
bc.shopItems['zwh50'].groupZoneSelector.refreshTags = { 'warehouse_targets' }

local armMenu=nil
bc:registerShopItem('zarm',LTGet("SA_SHOP_ITEM_UPGRADE_ARMOR"),ShopPrices.zarm,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		local slotID = (Era == 'Coldwar') and 'blueArmor-Coldwar' or 'blueArmor' -- checked
		params.zone:addExtraSlot(slotID)
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock then
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

Group.getByName('bluePATRIOT'):destroy()
local patMenu=nil
bc:registerShopItem('zpat',LTGet("SA_SHOP_ITEM_UPGRADE_PATRIOT"),ShopPrices.zpat,function(sender)
	return LTGet("SA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED_EXTRA")
			end
			return LTGet("SA_SHOP_ZONE_ALREADY_UPGRADED")
		end
		params.zone:addExtraSlot('bluePATRIOT')
		bc:refreshZoneLabel(params.zone.zone)
		if bc.globalExtraUnlock then
		trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED", "Patriot", params.zone.zone, tostring(ShopPrices.zpat)),10)
		else
		trigger.action.outTextForCoalition(2,L10N:Format("SA_SHOP_UPGRADE_ADDED_EXTRA", "Patriot", params.zone.zone, tostring(ShopPrices.zpat)),30)
		end
	else
		return LTGet("SA_SHOP_MUST_PICK_FRIENDLY_ZONE")
	end
end)
bc.shopItems['zpat'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj) return bc:isEligibleBlueZoneUpgradeTarget(zoneObj) end,
	emptyLabel = LTGet("SA_SHOP_NO_ELIGIBLE_ZONE"),
}
bc.shopItems['zpat'].groupZoneSelector.candidateBucket = 'blue_unsuspended'
bc.shopItems['zpat'].groupZoneSelector.refreshTags = { 'friendly_targets' }
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
if StartNormal or not CustomFlags['StartNormalFalse'] then 
bc:addShopItem(2, 'cruisemsl', 12, 7, ShopRankRequirements.cruisemsl, ShopCats.AIAttack) -- Cruise missiles
end

-- Zone Upgrades
bc:addShopItem(2, 'zinf', -1, 1, ShopRankRequirements.zinf, ShopCats.ZoneUpgrades) -- add infantry to a zone
bc:addShopItem(2, 'zarm', -1, 2, ShopRankRequirements.zarm, ShopCats.ZoneUpgrades) -- add armour group to a zone
bc:addShopItem(2, 'zsam', -1, 3, ShopRankRequirements.zsam, ShopCats.ZoneUpgrades) -- add Nasams to a zone
bc:addShopItem(2, 'gslot', 1, 5, ShopRankRequirements.gslot, ShopCats.ZoneUpgrades) -- add another slot for upgrade
if Era == 'Modern' then
    bc:addShopItem(2, 'zhimars', -1, 4, ShopRankRequirements.zhimars, ShopCats.ZoneUpgrades) -- add HIMARS to a zone
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
bc:addShopItem(2, 'advancecapture', -1, 2, ShopRankRequirements.advancecapture, ShopCats.LogisticsStrategic) -- advance capture
bc:addShopItem(2, 'supplies2', -1, 3, ShopRankRequirements.supplies2, ShopCats.LogisticsStrategic) -- upgrade friendly zone
if AllowScriptedSupplies then
    bc:addShopItem(2, 'supplies', -1, 4, ShopRankRequirements.supplies, ShopCats.LogisticsStrategic) -- fully upgrade friendly zone
end
if WarehouseLogistics then
    bc:addShopItem(2, 'zlogc', -1, 5, ShopRankRequirements.zlogc, ShopCats.LogisticsStrategic) -- upgrade zone to logistic center
    bc:addShopItem(2, 'zwh50', -1, 6, ShopRankRequirements.zwh50, ShopCats.LogisticsStrategic) -- resupply warehouse with 50
end

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
lc:init()

TerritoryOverlayOuterDrawPushMeters = 500000

bc:loadFromDisk() -- will load and overwrite default zone levels, sides, funds, and available shop items
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
budgetAI = BudgetCommander:new({ battleCommander = bc, side=1, decissionFrequency=20*60, decissionVariance=10*60, skipChance = 10})
budgetAI:init()
RewardContribution = RewardContribution or {infantry = 10, ground = 10, sam = 30, airplane = 50, ship = 200, helicopter=50, crate=100, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, ['Warehouse delivery'] = 150, structure = 100}
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

SpawnFriendlyAssets()

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
		ActiveCurrentMission[resupplyTarget1] = MissionType
		local z = bc:getZoneByName(resupplyTarget1) ; if z then z:updateLabel() end
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
		if ActiveCurrentMission[resupplyTarget1] == MissionType then
			ActiveCurrentMission[resupplyTarget1] = nil
		end
		local z = bc:getZoneByName(resupplyTarget1) ; if z then z:updateLabel() end
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
		ActiveCurrentMission[resupplyTarget2] = MissionType
		local z = bc:getZoneByName(resupplyTarget2) ; if z then z:updateLabel() end
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
		if ActiveCurrentMission[resupplyTarget2] == MissionType then
			ActiveCurrentMission[resupplyTarget2] = nil
		end
		local z = bc:getZoneByName(resupplyTarget2) ; if z then z:updateLabel() end
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
		return LT(T):Format("SA_DYNAMIC_ATTACK_TITLE", attackTarget1, wp)
	end,
	description = function(T)
		local wp = WaypointList[attackTarget1] or ""
		return LT(T):Format("SA_DYNAMIC_ATTACK_DESC", attackTarget1)
	end,
	messageStart = nil,
	messageEnd = function(T)
		return LT(T):Format("SA_DYNAMIC_ATTACK_END", attackTarget1)
	end,
	startAction = function()
		ActiveCurrentMission[attackTarget1] = ActiveCurrentMission[attackTarget1] or {}
		ActiveCurrentMission[attackTarget1]["Attack"] = true
		local z = bc:getZoneByName(attackTarget1) if z then z:updateLabel() end
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
		local t = (type(ActiveCurrentMission) == 'table') and ActiveCurrentMission[attackTarget1] or nil
		if type(t) == 'table' then
			t["Attack"] = nil
			if not next(t) then ActiveCurrentMission[attackTarget1] = nil end
		end
		local z = bc:getZoneByName(attackTarget1) if z then z:updateLabel() end
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
		return LT(T):Format("SA_DYNAMIC_ATTACK_TITLE", attackTarget2, wp)
	end,
	description = function(T)
		local wp = WaypointList[attackTarget2] or ""
		return LT(T):Format("SA_DYNAMIC_ATTACK_DESC", attackTarget2)
	end,
	messageStart = nil,
	messageEnd = function(T)
		return LT(T):Format("SA_DYNAMIC_ATTACK_END", attackTarget2)
	end,
	startAction = function()
		ActiveCurrentMission[attackTarget2] = ActiveCurrentMission[attackTarget2] or {}
		ActiveCurrentMission[attackTarget2]["Attack"] = true
		local z = bc:getZoneByName(attackTarget2) if z then z:updateLabel() end
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
		local t = (type(ActiveCurrentMission) == 'table') and ActiveCurrentMission[attackTarget2] or nil
		if type(t) == 'table' then
			t["Attack"] = nil
			if not next(t) then ActiveCurrentMission[attackTarget2] = nil end
		end
		local z = bc:getZoneByName(attackTarget2) if z then z:updateLabel() end
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
        return LT(T):Format("SA_DYNAMIC_CAPTURE_TITLE", captureTarget, wp)
    end,
    description = function(T)
        return LT(T):Format("SA_DYNAMIC_CAPTURE_DESC", captureTarget) end,
    messageStart = function(T)
        local wp = WaypointList[captureTarget] or ""
        return LT(T):Format("SA_DYNAMIC_CAPTURE_START", captureTarget, wp)
    end,
    messageEnd = function(T)
        return LT(T):Format("SA_DYNAMIC_CAPTURE_END", captureTarget) end,
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


---------------------------------------------------------------------
--                         RECON MISSION                           --
reconMissionTarget = nil
reconMissionWinner = nil
reconMissionCooldownUntil = 0
reconMissionCompleted = false
reconMissionCompletedTarget = nil

mc:trackMission({
	title = function(T)
		local wp = WaypointList[reconMissionTarget] or ""
		return LT(T):Format("SA_DYNAMIC_RECON_TITLE", reconMissionTarget, wp)
	end,
	description = function(T)
		return LT(T):Format("SA_DYNAMIC_RECON_DESC", reconMissionTarget)
	end,
	messageStart = function(T)
		local wp = WaypointList[reconMissionTarget] or ""
		return LT(T):Format("SA_DYNAMIC_RECON_START", reconMissionTarget, wp)
	end,
	messageEnd = function(T)
		if reconMissionCompleted and reconMissionCompletedTarget and reconMissionWinner then
			return LT(T):Format("SA_DYNAMIC_RECON_END_BY", reconMissionCompletedTarget, reconMissionWinner)
		end
		if reconMissionCompletedTarget then
			return LT(T):Format("SA_DYNAMIC_RECON_END_TARGET", reconMissionCompletedTarget)
		end
		return LT(T):Get("SA_DYNAMIC_RECON_END")
	end,
	startAction = function()
		reconMissionCompleted = false
		reconMissionWinner = nil
		reconMissionCompletedTarget = nil

		ActiveCurrentMission[reconMissionTarget] = ActiveCurrentMission[reconMissionTarget] or {}
		ActiveCurrentMission[reconMissionTarget]["Recon"] = true
		local z = bc:getZoneByName(reconMissionTarget)
		if z then z:updateLabel() end

		startReconMissionZoneTracker(reconMissionTarget)
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "ding.ogg")
		end
	end,
	endAction = function()
		local target = reconMissionCompletedTarget or reconMissionTarget
		if target then
			stopReconMissionZoneTracker(target)
			local t = (type(ActiveCurrentMission) == "table") and ActiveCurrentMission[target] or nil
			if type(t) == "table" then
				t["Recon"] = nil
				if not next(t) then ActiveCurrentMission[target] = nil end
			end
			local z = bc:getZoneByName(target)
			if z then z:updateLabel() end
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
    if missionCompleted then return true end

	local validzones = {}
	local validSeen = {}
	local redByBlue = {}
	local created1 = false
	local created2 = false

	for _, v in ipairs(bc.connections) do
		local from, to = bc:getConnectionZones(v)

		local function checkValid(zone)
			local lname = zone.zone:lower()
			return zone.side == 1 and zone.active and not zone.suspended and not zone.isHidden and
				not isZoneUnderSEADMission(zone.zone) and
				not lname:find('hidden') and not lname:find('sam') and not lname:find('defence') 
		end

		if from and to and from.side ~= to.side and from.side ~= 0 and to.side ~= 0 and
			((not to.suspended) or from.suspended) then

			if checkValid(from) and not validSeen[from.zone] then
				validSeen[from.zone] = true
				table.insert(validzones, from.zone)
			end
			if checkValid(to) and not validSeen[to.zone] then
				validSeen[to.zone] = true
				table.insert(validzones, to.zone)
			end

			if checkValid(from) and to and to.side == 2 then
				redByBlue[to.zone] = redByBlue[to.zone] or {}
				local found = false
				for _, zoneName in ipairs(redByBlue[to.zone]) do
					if zoneName == from.zone then found = true break end
				end
				if not found then table.insert(redByBlue[to.zone], from.zone) end
			end
			if checkValid(to) and from and from.side == 2 then
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
---------------------------------------------------------------------
--                     		ESCORT MISSION                         --

function generateEscortMission(zoneName, groupName, groupID, group, mission)
    local mission = mission or missions[zoneName]
    if not mission then return false end
	local T = L10N:ForGroup(groupID)

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
		trigger.action.outTextForGroup(groupID, T:Format("MISSION_ESCORT_ACTIVE_PENDING", mission.zone, mission.TargetZone), 30)
        return
    end
	if mc.missionFlags[zoneName] then
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, T:Format("MISSION_ESCORT_SPECIAL_AVAILABLE", mission.zone, mission.TargetZone), 30)
		return 
	end

    mc:trackMission({
        MainTitle = function(T) return LT(T):Get("MISSION_ESCORT_TITLE") end,
        title = function(T) return LT(T):Get("MISSION_ESCORT_TITLE") end,
		titleBefore = function(self)
			self.notified = true
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, T:Format("MISSION_ESCORT_SPECIAL_AVAILABLE", mission.zone, mission.TargetZone), 30)
		 end,
        description = function(T) return LT(T):Format("MISSION_ESCORT_DESCRIPTION", mission.TargetZone) end,
        isEscortMission = true,
        accept = false,
        missionGroup = mission.missionGroup,
        zoneName = zoneName,
        messageStart = function(T) return LT(T):Format("MISSION_ESCORT_START", mission.TargetZone) end,
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

mc:trackMission({
    title=function(T) return LT(T):Get("MISSION_BOMB_RUNWAY_TITLE") end,
    description=function(T)
      local Tr=LT(T)
      local wp=WaypointList[runwayTargetZone] or ""
      if #runwayNames>1 then
        return Tr:Format("MISSION_BOMB_RUNWAY_DESC_ALL", runwayTargetZone, wp)
      else
        return Tr:Format("MISSION_BOMB_RUNWAY_DESC_ONE", runwayTargetZone, wp)
      end
    end,
    messageStart=function(T)
    local Tr=LT(T)
    local wp=WaypointList[runwayTargetZone] or ""
      if #runwayNames>1 then
        return Tr:Format("MISSION_BOMB_RUNWAY_START_ALL", runwayTargetZone, wp)
      else
        return Tr:Format("MISSION_BOMB_RUNWAY_START_ONE", runwayTargetZone, wp)
      end
    end,
	messageEnd = function(T)
		local Tr=LT(T)
		trigger.action.outSoundForCoalition(2,'cancel.ogg')
		if runwayTargetZone then
			if runwayCompleted then
				local cred = (need and need>1) and 200 or 100
				if bomberName and runwayPartnerName then
					return Tr:Format("SA_BOMB_RUNWAY_END_JOINT", runwayTargetZone, bomberName, runwayPartnerName, cred)
				elseif bomberName then
					return Tr:Format("SA_BOMB_RUNWAY_END_SOLO", runwayTargetZone, bomberName, cred)
				else
					return Tr:Format("SA_BOMB_RUNWAY_END_COMPLETED", runwayTargetZone)
				end
			else
				return Tr:Format("SA_BOMB_RUNWAY_END_CANCELED_ZONE", runwayTargetZone)
			end
		else
			return Tr:Get("SA_BOMB_RUNWAY_CANCELED")
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
local function _zoneIntelIsActiveForRecon(zoneName, now)
	local zoneIntelActive = (intelActiveZones and intelActiveZones[zoneName] == true)
	if not zoneIntelActive then return false end
	local zoneIntelExpire = tonumber((intelExpireTimes and intelExpireTimes[zoneName]) or 0) or 0
	return zoneIntelExpire <= 0 or zoneIntelExpire > now
end
function checkAndGenerateReconMissionV2()
	local now = timer.getTime()
	if reconMissionTarget ~= nil or now < reconMissionCooldownUntil then
		return true
	end

	local validzones = {}
	local seen = {}
	for _, connection in ipairs(bc.connections or {}) do
		local from, to = bc:getConnectionZones(connection)
		if _isFrontlineConnectionEligible(from, to) then
			if _isValidAttackMissionZone(from) and not _zoneIntelIsActiveForRecon(from.zone, now) and not seen[from.zone] then
				seen[from.zone] = true
				validzones[#validzones + 1] = from.zone
			end
			if _isValidAttackMissionZone(to) and not _zoneIntelIsActiveForRecon(to.zone, now) and not seen[to.zone] then
				seen[to.zone] = true
				validzones[#validzones + 1] = to.zone
			end
		end
	end

	if #validzones == 0 then return false end

	reconMissionTarget = validzones[math.random(1, #validzones)]
	reconMissionWinner = nil
	reconMissionCompleted = false
	reconMissionCompletedTarget = nil
	return true
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


