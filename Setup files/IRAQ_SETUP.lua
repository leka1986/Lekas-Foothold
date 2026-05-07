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
		blue = {'blueShip', 'blueShip', 'blueShip'},
		red = {'redShipS', 'redShipS-2', 'redShipS-1', 'redShipM', 'redShipM-1', 'redShipM-2', 'redShipL-1', 'redShipL', 'redShipL-2', 'redShipXL'}
	},
	blueships = {
		blue = {'blueShip'},
		red = {'redShipXL'}
	},
	airfield1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Enemy Task forces', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8'}
	},
	
	airfieldStart = {
		blue = {'blueArmor', 'bluePD1'},
		red = {}
	},
	airfield2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces','Red SAM AAA 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19'}
	},
	airfield3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Enemy Task forces', 'Red Armour Group 2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD Pantsir S1'}
	},
	airfield3Sahra = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Enemy Task forces', 'Red SAM AAA', 'Red SAM SHORAD SA-19 Fixed Sahra', 'Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15'}
	},
	airfield6 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1', 'bluePATRIOT'},
		red = {'Enemy Task forces', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD Tor M2'}
	},
	airfield4 = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Pantsir S1', 'Red SAM AAA', 'Red SAM SHORAD SA-8'}
	},
	Ramadi = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Enemy Task forces', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD Pantsir S1', 'Red SAM AAA', 'Red SAM AAA 3', 'Red SAM AAA 4'}
	},
	farp1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM AAA', 'Red SAM SHORAD SA-8','Red SAM SHORAD SA-8'}
	},
	farp1Koya = {
		blue = {'bluePD1'},
		red = {'Red Armour Group', 'Red Armour Group 2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15'}
	},
	farp1Dukan = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8'}
	},
	farp1San = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8'}
	},
	farp2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8'}
	},
	mission2InsurgentCamp = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Fixed-redInfantry', 'Fixed-redInfantry-2', 'Fixed-Red SAM AAA 2', 'Red SAM SHORAD SA-19 Fixed'}	
	},
	mission3 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Red SAM SA-6 Fixed Secret tech', 'Red SAM SHORAD SA-15 Fixed Secret tech', 'Fixed-redArmor2', 'Fixed-redArmor1', 'Fixed-redInfantry2'}
	},
	mission3Uranium = {
		blue = {},
		red = {'Red SAM SA-6 Fixed Uranium', 'Red SAM AAA Fixed Urainium','Red SAM SHORAD SA-19 Fixed Uranium', 'Red SAM AAA-Fixed Uranium', 'Red SAM SHORAD SA-15 Fixed Uranium', 'Uranium Factroy'
				, 'Uranium Factroy 2', 'Uranium Factroy 3', 'Red SAM SHORAD SA-8 Fixed Uranium', 'Red SAM SA-2 Fixed Uranium'}
	},
	mission4 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy Task forces', 'Red SAM AAA 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM AAA', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8'}
	},	
	BarzanGroup = {
	    blue = {'blueInfantry'},
		red = {}
	},
	SamEastGroup = {
	    blue = {},
		red = {'Red SAM SA-11','Red SAM AAA', 'Red SAM SHORAD Tor M2'}
	},
	SamWestGroup = {
	    blue = {},
		red = {'Red SAM SHORAD SA-19', 'Red SAM SA-3', 'Red SAM SHORAD Tor M2'}
	},
	SamSouthGroup = {
		blue = {},
		red = {'Red SAM SA-11','Red SAM SHORAD Tor M2','Red SAM AAA', 'Red SAM SHORAD SA-8'}
	},
	RamadiSamGroup = {
	    blue = {},
		red = {'Red SAM SHORAD SA-8', 'Red SAM SA-2', 'Red SAM SHORAD AAA'}
	},
	KirkukCity = {
	    blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Red SAM SA-3 Fixed KirkukCity', 'Red SAM SHORAD SA-8 Kirkuk City Fixed', 'Red SAM AAA Group Fixed', 'Kirkuk City Group Fixed2', 'Red Armour Group 2','Red SAM AAA 3', 'Red SAM AAA'}
	},
	hidden1Group = {
		blue = {},
		red = {'Hiddengroup1-Fixed', 'Hiddengroup1-Fixed3', 'Hiddengroup1-Fixed4', 'Hiddengroup1-Fixed5', 'Hiddengroup1-Fixed6', 
		'Hiddengroup1-Fixed7', 'Hiddengroup1-Fixed8', 'Hiddengroup1-Fixed9', 'Hiddengroup1-Fixed10', 'Hiddengroup1-Fixed11', 'Hiddengroup1-Fixed12', 
		'Hiddengroup1-Fixed13', 'Hiddengroup1-Fixed14', 'Hiddengroup1-Fixed15', 'Hiddengroup1-Fixed16', 'Hiddengroup1-Fixed1', 'Hiddengroup1-Fixed17',
		'Hiddengroup1-Fixed18', 'Hiddengroup1-Fixed19'}
	},
	hidden2Group = {
		blue = {},
		red = {'Hiddengroup2-Fixed1', 'Hiddengroup2-Fixed2', 'Hiddengroup2-Fixed3', 'Hiddengroup2-Fixed4', 'Hiddengroup2-Fixed5', 
		'Hiddengroup2-Fixed6', 'Hiddengroup2-Fixed7', 'Hiddengroup2-Fixed8', 'Hiddengroup2-Fixed9', 'Hiddengroup2-Fixed10', 'Hiddengroup2-Fixed11', 
		'Hiddengroup2-Fixed13', 'Red SAM SA-6 Fixed hidden2'}
	},
	OutPostMission = {
		blue = {},
		red = {'OutPost-Mission-Fixed-1','OutPost-Mission-Fixed-2','OutPost-Mission-Fixed-3','Red SAM SHORAD SA-8-OutPost-Mission-Fixed-4'}
	},
	ChamankiMission = {
		blue = {},
		red = {'Chamanki-Mission-Fixed-1','Red SAM SHORAD SA-19 Chamanki-Mission-Fixed-2','Chamanki-Mission-Fixed-3'}
	},
	KoyaMission = {
		blue = {},
		red = {'Koya-Mission-Fixed-1','Koya-Mission-Fixed-2','Koya-Mission-Fixed-3', 'Koya-Mission-Fixed-4'}
	},
	DukanMission = {
		blue = {},
		red = {'Dukan-Mission-Fixed-1','Dukan-Mission-Fixed-2','Dukan-Mission-Fixed-3', 'Dukan-Mission-Fixed-4', 'Dukan-Mission-Fixed-5', 'Dukan-Mission-Fixed-6', 
			'Red SAM AAA Fixed Dukhan-Mission Fixed-7', 'Red SAM SA-3 Dukhan-Mission Fixed-8'}
	},
	BarzanMission = {
		blue = {},
		red = {'Barzan-Mission-Fixed-1','Barzan-Mission-Fixed-2','Barzan-Mission-Fixed-3', 'Barzan-Mission-Fixed-4', 'Barzan-Mission-Fixed-5'}
	},
	RamadiMission = {
		blue = {},
		red = {'Ramadi-Mission-Fixed-1','Ramadi-Mission-Fixed-2','Ramadi-Mission-Fixed-3', 'Ramadi-Mission-Fixed-4', 'Ramadi-Mission-Fixed-5'}
	},
	hidden3Group = {
		blue = {},
		red = {'Red SAM SHORAD SA-8 Hiddengroup3-Fixed1', 'Red SAM SHORAD SA-15 Hiddengroup3-Fixed2', 'Red SAM SHORAD SA-8 Hiddengroup3-Fixed3', 'Red SAM SHORAD SA-8 Hiddengroup3-Fixed4', 
		'Hiddengroup3-Fixed5', 'Hiddengroup3-Fixed6', 'Hiddengroup3-Fixed3', 'Hiddengroup3-Fixed7'}
	},
	EWRMantisNetwork = {
		blue = {},
		red = {'Red EWR Fixed 1', 'Red EWR Fixed 2', 'Red EWR Fixed 3'}
	},	
	MiningMission = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Red SAM SA-3 Fixed Mining', 'Fixed Mining', 'Fixed Tripple A Mining', 'Red SAM SHORAD SA-19 Fixed MiningFacility'}
	},
	ChemSiteMission = {
		blue = {},
		red = {'Fixed-redArmor2-1', 'Fixed-redInfantry2-1', 'Armour Group Chemsite Fixed', 'Red SAM SHORAD SA-15 Fixed Checksite','chemsite1', 'chemsite2', 'chemsite3', 'chemsite4', 'chemsite5', 'chemsite6',
		'chemsite7', 'chemsite8'}
	},
	DuhukCityGroup = {
		blue = {'blueInfantry'},
		red = {'Duhuk-Group-Fixed', 'Duhuk Group Fixed 1', 'Duhuk Group Fixed 2', 'Duhuk Group Fixed 3'}
	},
	MosulCityGroup = {
		blue = {'bluePD1', 'bluePD2'},
		red = {'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-19 Fixed MosulCity', 'Red SAM SHORAD SA-8 Fixed MosulCity', 'ManPadGroup Fixed MosulCity', 'Red SAM AAA Fixed Mosul', 
		'AAA-Closed Fixed MosulCity-1', 'Red SAM AAA Mosul2 Fixed','Red SAM AAA 3 Mosul Fixed','Red SAM AAA 4 Mosul Fixed'}
	},
	erbildefence = {
		blue = {},
		red = {'Red SAM SA-3 Erbil Fixed-1', 'Red SAM SA-6', 'Red SAM AAA Erbil Fixed'}
	},
	FaljuaCity = {
		blue = {'bluePD1'},
		red = {'Red SAM AAA Fallujah', 'Faluja-Fixed-Group3', 'Faluja-Fixed-Group2', 'Red SAM SHORAD SA-15 Fixed Faljua','Red SAM SHORAD SA-15 Fixed Faljua-2','Armour patrol Fixed'}
    },
	BaladGroup = {
		blue = {'blueArmor', 'bluePD1'},
		red = {'Red SAM SA-3', 'Red SAM SA-2','Red Armour Group', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-19'}
    },
	SahraDefence = {
		blue = {},
		red = {'Red SAM SHORAD SA-15', 'Red SAM SA-11', 'Sahra Defence Fixed Group','Red SAM AAA 3 Sahra Fixed','Red SAM AAA 4 Sahra Fixed'}
    },
	BaladDefence = {
		blue = {},
		red = {'Red SAM SHORAD SA-15', 'Red SAM SA-11', 'Red SAM AAA'}
    },
	borjoilFixed = {
		blue = {},
		red = {'Red SAM SA-6', 'Red SAM SHORAD SA-15','Red SAM SHORAD Tor M2', 'Enemy Task forces','Enemy ground forces', 'Borj Oil production_4', 'Borj Oil production_3', 
		'Borj Oil production_5', 'Borj Oil production_6', 'Borj Oil production_2', 'Borj Oil production_1'}
	},
	ScudsCityGroup = {
		blue = {},
		red = {'ScudCity-Fixed', 'ScudCity-Fixed-2','Red SAM AAA 4 Scud City Fixed','Red SAM AAA 3 Scud City Fixed'}
	},
	hidden5Group = {
	    blue = {},
		red = {'Hiddengroup5-Fixed-1', 'Hiddengroup5-Fixed-2', 'Hiddengroup5-Fixed-3', 'Red SAM SA-15 Fixed Hiddengroup5', 'Red SAM SHORAD SA-8 Hiddengroup5-Fixed5'
		, 'Red SAM SHORAD SA-8 Hiddengroup5-Fixed6','Hiddengroup5-Fixed7', 'Hiddengroup5-Fixed8'}
	}
}   

WaypointList = {
	['Bashur Airport'] = ' (1)',
	['Erbil Airport'] = ' (2)',
	Koya = ' (3)',
	Dukan = ' (4)',
	Sangasar = ' (5)',
	Barzan = ' (6)',
	Chamanki = ' (7)',
	OutPost = ' (8)',
	['Duhok City'] = ' (9)',
	['Mosul City'] = ' (10)',
	['Hammam Al Alil'] = ' (11)',
	['Tal Afar'] = ' (12)',
	['Al Tall'] = ' (13)',
	['Qayyarah Airfield'] = ' (14)',
	['Al Abbasi'] = ' (15)',
	['Kirkuk City'] = ' (16)',
	['Sulaimaniyah Airport'] = ' (17)',
	['Said Sadiq'] = ' ( 18)',
	Maydan = ' (19)',
	Sarqala = ' (20)',
	Khormato = ' (21)',
	['Al-Sahra Airport'] = ' (22)',
	['FOB Therethar'] = ' (23)',
	['Al-Asad Airbase'] = ' (24)',
	Ramadi = ' (25)',
	Fallujah = ' (26)',
	['FOB Samarra'] = ' (27)',
	['Balad Airbase'] = ' (28)',
	['Al-Salam Airbase'] = ' (29)',
}	

flavor = {
	miningfacility = L10N:Get("IRAQ_FLAVOR_MINING_FACILITY"),
	insurgentcamp = L10N:Get("IRAQ_FLAVOR_INSURGENT_CAMP"),
	secrettechfacility = L10N:Get("IRAQ_FLAVOR_SECRET_TECH_FACILITY"),
	uranium = L10N:Get("IRAQ_FLAVOR_URANIUM"),
	--------------
	bashurairport = L10N:Format("IRAQ_FLAVOR_WPT", 1),
	erbilairport = L10N:Format("IRAQ_FLAVOR_WPT", 2),
	erbildefence = 'WPT \n',
	barzan = L10N:Format("IRAQ_FLAVOR_WPT", 3),
	chamanki = L10N:Format("IRAQ_FLAVOR_WPT", 4),
	outpost = L10N:Format("IRAQ_FLAVOR_WPT", 5),
	duhokcity = L10N:Format("IRAQ_FLAVOR_WPT", 6),
	mosulcity = L10N:Format("IRAQ_FLAVOR_WPT", 7),
	hammam = L10N:Format("IRAQ_FLAVOR_WPT", 8),
	talafar = L10N:Format("IRAQ_FLAVOR_WPT", 9),
	altall = L10N:Format("IRAQ_FLAVOR_WPT", 10),
	qayyarah = L10N:Format("IRAQ_FLAVOR_WPT", 11),
	alabbasi = L10N:Format("IRAQ_FLAVOR_WPT", 12),
	kirkuk = L10N:Format("IRAQ_FLAVOR_WPT", 13),
	sulaimaniyah = L10N:Format("IRAQ_FLAVOR_WPT", 14),
	saidsadiq = L10N:Format("IRAQ_FLAVOR_WPT", 15),
	maydan = L10N:Format("IRAQ_FLAVOR_WPT", 16),
	sarqala = L10N:Format("IRAQ_FLAVOR_WPT", 17),
	khormato = L10N:Format("IRAQ_FLAVOR_WPT", 18),
	alsahra = L10N:Format("IRAQ_FLAVOR_WPT", 19),
	fobtherethar = L10N:Format("IRAQ_FLAVOR_WPT", 20),
	alasadairbase = L10N:Format("IRAQ_FLAVOR_WPT", 21),
	ramadi = L10N:Format("IRAQ_FLAVOR_WPT", 22),
	fallujah = L10N:Format("IRAQ_FLAVOR_WPT", 23),
	fobsamarra = L10N:Format("IRAQ_FLAVOR_WPT", 24),
	baladairbase = L10N:Format("IRAQ_FLAVOR_WPT", 25),
	alsalamairbase = L10N:Format("IRAQ_FLAVOR_WPT", 26),
	baladdefence = L10N:Get("IRAQ_FLAVOR_WPT_NA"),
	
	
	scudcity = L10N:Get("IRAQ_FLAVOR_SCUD_CITY"),

}

FootholdSaveBaseName = ((Era == 'Coldwar') and 'FootHold_IRAQ_v0.1_Gulfwar' or 'FootHold_IRAQ_v0.1')

local filepath = FootholdSaveBaseName .. '.lua'
if lfs then 
	FootholdSavePath = FootholdSavePath or (lfs.writedir()..'Missions/Saves')
	lfs.mkdir(FootholdSavePath)
	filepath = FootholdSavePath .. '/' .. (FootholdSaveBaseName .. '.lua')
	env.info('Foothold - Save file path: '..filepath)
end

local cwSwap = {
	['Red Armour Group']   	= 'Red Armor Group6',
	['Red Armour Group 2']  = 'Red Armor Group8',
	['Red Armour Group 3']  = 'Red Armor Group7',
	['Armour Group Chemsite Fixed']  = 'Armour Group Chemsite Fixed-Coldwar',
	['blueHAWK']  = 'blueHAWK-Coldwar',
	['bluePATRIOT']  = 'bluePATRIOT-Coldwar',
	['bluePD2']  = 'bluePD2-Coldwar',
	['blueArmor']  = 'blueArmor-Coldwar',
	['Red SAM SHORAD SA-15']   						= 'Red SAM SHORAD SA-8',
	['Red SAM SHORAD SA-15 Fixed Faljua']   		= 'Red SAM SHORAD SA-8 Fixed Faljua-Coldwar',
	['Red SAM SHORAD SA-15 Fixed Faljua-2']   		= 'Red SAM SHORAD SA-8 Fixed Faljua-Coldwar-2',
	['Red SAM SHORAD SA-15 Fixed Uranium']   		= 'Red SAM SHORAD SA-8 Fixed Uranium 2',
	['Red SAM SA-15 Fixed Hiddengroup5']   			= 'Red SAM SA-8 Fixed Hiddengroup5',
	['Red SAM SHORAD SA-15 Fixed Checksite']   		= 'Red SAM SHORAD SA-8 Fixed Checksite',
	['Red SAM SHORAD SA-15 Hiddengroup3-Fixed2']    = 'Red SAM SHORAD SA-8 Hiddengroup3-Fixed2',
	['Red SAM AAA']    								= 'Red SAM AAA 5',
	--['Red SAM SHORAD SA-8']    						= {'Red SAM AAA 3','Red SAM AAA 4'},
	['Red SAM SHORAD Tor M2']    					= { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
	['Red SAM SHORAD Pantsir S1']    				= { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
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

	['Red SAM SA-11']   							= { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },
	['Red SAM SA-10']  			  					= { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },
	['Red SAM SA-11 Fixed Balad Defence']   		= 'Red SAM SA-2 Fixed Balad Defence',

}

local SamSwapNoTorM2AndPantsir = {
	['Red SAM SHORAD Pantsir S1'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
	['Red SAM SHORAD Tor M2'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
}

local SamSwapNoSA15 = {
	['Red SAM SHORAD SA-15'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
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
	samspecial = { sam = 3, shorad = {1,4}, aaa = {1,3}, ground = 0, armor = 0, arty = 0, total = {5,9} },
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

bc = BattleCommander:new(filepath, 13, 60)
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
env.info('Foothold - Rank file path: '..bc.rankFile)
end
Hunt = true


zones = {

	bashurairport = ZoneCommander:new({zone='Bashur Airport', side=2, size='big', level=20, upgrades=upgrades.airfieldStart, crates={},flavorText=flavor.bashurairport}),
	erbilairport = ZoneCommander:new({zone='Erbil Airport', side=1, size='mediumbig', level=20, upgrades=upgrades.airfield2, crates={},flavorText=flavor.erbilairport}),
	mosulcity = ZoneCommander:new({zone='Mosul City', side=1, size='big', level=20, upgrades=upgrades.MosulCityGroup, crates={},flavorText=flavor.mosulcity}),
	hammam = ZoneCommander:new({zone='Hammam Al Alil', side=1, size='medium', level=20, upgrades=upgrades.mission4, crates={},flavorText=flavor.hammam}),
	duhokcity = ZoneCommander:new({zone='Duhok City', side=1, level=20, upgrades=upgrades.DuhukCityGroup, crates={},flavorText=flavor.duhokcity}),
	talafar = ZoneCommander:new({zone='Tal Afar', side=1, size='medium', level=20, upgrades=upgrades.mission4, crates={},flavorText=flavor.talafar}),
	altall = ZoneCommander:new({zone='Al Tall', side=1, size='medium', level=20, upgrades=upgrades.mission4, crates={},flavorText=flavor.altall}),	
	qayyarah = ZoneCommander:new({zone='Qayyarah Airfield', side=1, size='medium', level=20, upgrades=upgrades.mission4, crates={},flavorText=flavor.qayyarah}),
	alabbasi = ZoneCommander:new({zone='Al Abbasi', side=1, size='medium', level=20, upgrades=upgrades.mission4, crates={},flavorText=flavor.alabbasi}),
	kirkuk = ZoneCommander:new({zone='Kirkuk City', side=1, size='medium', level=20, upgrades=upgrades.KirkukCity, crates={},flavorText=flavor.kirkuk}),
	sulaimaniyah = ZoneCommander:new({zone='Sulaimaniyah Airport', side=1, size='big', level=20, upgrades=upgrades.airfield3, crates={},flavorText=flavor.Sulaimaniyah}),
	saidsadiq = ZoneCommander:new({zone='Said Sadiq', side=1, size='big', level=20, upgrades=upgrades.airfield3, crates={},flavorText=flavor.saidsadiq}),
	alsahra = ZoneCommander:new({zone='Al-Sahra Airport', side=1, size='big', level=20, upgrades=upgrades.airfield3Sahra, crates={},flavorText=flavor.alsahra}),
	barzan = ZoneCommander:new({zone='Barzan', side=2, size='small', level=4, upgrades=upgrades.BarzanGroup, crates={},flavorText=flavor.barzan}),
	chamanki = ZoneCommander:new({zone='Chamanki', side=1, size='smallmedium', level=20, upgrades=upgrades.farp2, crates={},flavorText=flavor.chamanki}),
	outpost = ZoneCommander:new({zone='OutPost', side=1, size='smallmedium', level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.outpost}),
	maydan = ZoneCommander:new({zone='Maydan', side=1, size='smallmedium', level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.maydan}),
	sarqala = ZoneCommander:new({zone='Sarqala', side=1, size='smallmedium', level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.sarqala}),
	khormato = ZoneCommander:new({zone='Khormato', side=1, size='smallmedium', level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.Khormato}),
	baladairbase = ZoneCommander:new({zone='Balad Airbase', side=1, size='big', level=20, upgrades=upgrades.BaladGroup, crates={},flavorText=flavor.baladairbase}),
	alsalamairbase = ZoneCommander:new({zone='Al-Salam Airbase', side=1, size='big', level=20, upgrades=upgrades.airfield3, crates={},flavorText=flavor.alsalamairbase}),
	fallujah = ZoneCommander:new({zone='Fallujah', side=1, size='medium', level=20, upgrades=upgrades.FaljuaCity, crates={},flavorText=flavor.fallujah}),
	ramadi = ZoneCommander:new({zone='Ramadi', side=1, size='medium', level=20, upgrades=upgrades.Ramadi, crates={},flavorText=flavor.ramadi}),
	alasadairbase = ZoneCommander:new({zone='Al-Asad Airbase', side=1, size='smallmedium', level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.alasadairbase}),
	koya = ZoneCommander:new({zone='Koya', side=1, size='smallmedium', level=20, upgrades=upgrades.farp1Koya, crates={},flavorText=flavor.Koya}),
	dukan = ZoneCommander:new({zone='Dukan', side=1, size='smallmedium', level=20, upgrades=upgrades.farp1Dukan, crates={},flavorText=flavor.dukan}),
	sangasar = ZoneCommander:new({zone='Sangasar', side=1, size='smallmedium', level=20, upgrades=upgrades.farp1San, crates={},flavorText=flavor.sangasar}),

	fobsamarra = ZoneCommander:new({zone='FOB Samarra', side=0, size='small', level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.fobsamarra, NeutralAtStart=true}),
	fobtherethar = ZoneCommander:new({zone='FOB Therethar', side=0, size='small', level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.fobtherethar, NeutralAtStart=true}),


	erbildefence = ZoneCommander:new({zone='Erbil Defence', side=1, size='sam2', level=20, upgrades=upgrades.erbildefence, crates={},flavorText=flavor.erbildefence}),
	sameast = ZoneCommander:new({zone='SAM East', side=1, size='sam2', level=20, upgrades=upgrades.SamEastGroup, crates={},flavorText=flavor.sameast}),
	samwest = ZoneCommander:new({zone='SAM West', side=1, size='sam2', level=20, upgrades=upgrades.SamWestGroup, crates={},flavorText=flavor.samwest}),
	samsouth = ZoneCommander:new({zone='SAM South', side=1, size='sam2', level=20, upgrades=upgrades.SamSouthGroup, crates={},flavorText=flavor.samsouth}),
	sahradefence = ZoneCommander:new({zone='Sahra Defence', side=1, size='sam2', level=20, upgrades=upgrades.SahraDefence, crates={},flavorText=flavor.sahradefence}),
	baladdefence = ZoneCommander:new({zone='Balad Defence', side=1, size='sam2', level=20, upgrades=upgrades.BaladDefence, crates={},flavorText=flavor.baladdefence}),
	ramadisam = ZoneCommander:new({zone='Ramadi SAM', side=1, size='sam2', level=20, upgrades=upgrades.RamadiSamGroup, crates={},flavorText=flavor.ramadisam}),


	oilsite = ZoneCommander:new({zone='Oil production Site', side=1, size='big', level=10, upgrades=upgrades.borjoilFixed, crates={}, flavorText=flavor.oilsite}),
	miningfacility = ZoneCommander:new({zone='MiningFacility', side=1, level=20, upgrades=upgrades.MiningMission, crates={}, flavorText=flavor.miningfacility}),
	insurgentcamp = ZoneCommander:new({zone='InsurgentCamp', side=1, level=20, upgrades=upgrades.mission2InsurgentCamp, crates={}, flavorText=flavor.insurgentcamp}),
	secrettechfacility = ZoneCommander:new({zone='SecretTechFacility', side=1, level=20, upgrades=upgrades.mission3, crates={}, flavorText=flavor.secrettechfacility}),
	uranium = ZoneCommander:new({zone='Uranium enrichment Site', side=1, level=20, upgrades=upgrades.mission3Uranium, crates={}, flavorText=flavor.uranium}),
	chemsite = ZoneCommander:new({zone='Chemsite', side=1, level=20, upgrades=upgrades.ChemSiteMission, crates={}, flavorText=flavor.Chemsite}),
	hidden1 = ZoneCommander:new({zone='Hidden1', side=1, level=25, upgrades=upgrades.hidden1Group, crates={}, flavorText=flavor.hidden1}),
	hidden2 = ZoneCommander:new({zone='Hidden2', side=0, level=20, upgrades=upgrades.hidden3Group, crates={}, flavorText=flavor.hidden2, NeutralAtStart=true}),
	hidden3 = ZoneCommander:new({zone='Hidden3', side=1, level=25, upgrades=upgrades.hidden2Group, crates={}, flavorText=flavor.hidden3}),
	scudcity = ZoneCommander:new({zone='Scud City', side=1, level=20, upgrades=upgrades.ScudsCityGroup, crates={},flavorText=flavor.scudcity}),
	hidden4 = ZoneCommander:new({zone='Hidden4', side=1, level=20, upgrades=upgrades.EWRMantisNetwork, crates={},flavorText=flavor.hidden4}),
	hidden5 = ZoneCommander:new({zone='Hidden5', side=0, level=20, upgrades=upgrades.hidden5Group, crates={},flavorText=flavor.hidden5, NeutralAtStart=true}),
	koyahidden = ZoneCommander:new({zone='KoyaHidden', side=0, level=20, upgrades=upgrades.KoyaMission, crates={},flavorText=flavor.koyahidden, NeutralAtStart=true}),
	dukanhidden = ZoneCommander:new({zone='DukanHidden', side=0, level=20, upgrades=upgrades.DukanMission, crates={},flavorText=flavor.dukanhidden, NeutralAtStart=true}),
	barzanhidden = ZoneCommander:new({zone='BarzanHidden', side=0, level=20, upgrades=upgrades.BarzanMission, crates={},flavorText=flavor.barzanhidden, NeutralAtStart=true}),
	chamankihidden = ZoneCommander:new({zone='ChamankiHidden', side=0, level=20, upgrades=upgrades.ChamankiMission, crates={},flavorText=flavor.chamankihidden, NeutralAtStart=true}),
	outposthidden = ZoneCommander:new({zone='OutPostHidden', side=0, level=20, upgrades=upgrades.OutPostMission, crates={},flavorText=flavor.outposthidden, NeutralAtStart=true}),
	ramadihidden = ZoneCommander:new({zone='RamadiHidden', side=0, level=20, upgrades=upgrades.RamadiMission, crates={},flavorText=flavor.ramadihidden, NeutralAtStart=true}),
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

zones.bashurairport:addGroups({
    GroupCommander:new({name='Bashur-Airport-supply-Erbil', mission='supply',template='HeloSupplyTemplate', targetzone='Erbil Airport'}),
    GroupCommander:new({name='Bashur-Airport-supply-Barzan', mission='supply',template='HeloSupplyTemplate', targetzone='Barzan'}),
})
zones.barzan:addGroups({
    GroupCommander:new({name='Barzan-supply-Chamanki', mission='supply', targetzone='Chamanki'}) -- special case, non dynamic template
})
zones.chamanki:addGroups({
    GroupCommander:new({name='Chamanki-supply-OutPost', mission='supply', targetzone='OutPost'}) -- special case, non dynamic template
})
zones.outpost:addGroups({
    GroupCommander:new({name='OutPost-attack-Chamanki-convoy', mission='attack',template='AttackConvoy', targetzone='Chamanki', type='surface'}),
    GroupCommander:new({name='OutPost-supply-Chamanki-convoy', mission='supply',template='SupplyConvoy', targetzone='Chamanki', type='surface'}),
    GroupCommander:new({name='OutPost-supply-Duhok-City', mission='supply', targetzone='Duhok City'}) -- special case, non dynamic template
})
zones.erbilairport:addGroups({
    GroupCommander:new({name='Erbil-supply-Mosul', mission='supply',template='HeloSupplyTemplate', targetzone='Mosul City'}),
    GroupCommander:new({name='Erbil-supply-Kirkuk', mission='supply',template='HeloSupplyTemplate', targetzone='Kirkuk City'}),
    GroupCommander:new({name='Erbil-supply-Koya', mission='supply',template='HeloSupplyTemplate', targetzone='Koya'}),
    GroupCommander:new({name='Erbil-supply-Qayyarah', mission='supply',template='PlaneSupplyTemplate', targetzone='Qayyarah Airfield'}),
    GroupCommander:new({name='Erbil-supply-Kirkuk', mission='supply',template='PlaneSupplyTemplate', targetzone='Kirkuk City'}),
    GroupCommander:new({name='Erbil-supply-Sulaimaniyah', mission='supply',template='PlaneSupplyTemplate', targetzone='Sulaimaniyah Airport'}),
    GroupCommander:new({name='Erbil-patrol-sulaimaniyah-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Sulaimaniyah Airport', Altitude = CapAltitude(), spawnDelayFactor = 1.5}),
    GroupCommander:new({name='Erbil-supply-erbil-defence-convoy', mission='supply',template='SupplyConvoy', targetzone='Erbil Defence', spawnDelayFactor = 1.5, type='surface'})
})
zones.koya:addGroups({
    GroupCommander:new({name='Koya-attack-Erbil', mission='attack',template='AttackConvoy', targetzone='Erbil Airport', type='surface'}),
    GroupCommander:new({name='Koya-supply-Dukan', mission='supply',template='HeloSupplyTemplate', targetzone='Dukan'})
})
zones.sangasar:addGroups({
    GroupCommander:new({name='Sangasar-supply-Dukan', mission='supply',template='HeloSupplyTemplate', targetzone='Dukan'})
})
zones.dukan:addGroups({
    GroupCommander:new({name='Dukan-supply-Sangasar', mission='supply',template='HeloSupplyTemplate', targetzone='Sangasar'}),
    GroupCommander:new({name='Dukan-supply-Koya', mission='supply',template='SupplyConvoy', targetzone='Koya', type='surface'})
})
zones.mosulcity:addGroups({
    GroupCommander:new({name='Mosul-supply-Tal-Afar', mission='supply',template='HeloSupplyTemplate', targetzone='Tal Afar'}),
    --GroupCommander:new({name='Mosul-supply-Qayyarah', mission='supply',template='HeloSupplyTemplate', targetzone='Qayyarah Airfield'}),
    GroupCommander:new({name='Mosul-supply-Duhok-City', mission='supply',template='HeloSupplyTemplate', targetzone='Duhok City'}),
    GroupCommander:new({name='Mosul-supply-Al-Tall', mission='supply',template='HeloSupplyTemplate', targetzone='Al Tall'}),
    GroupCommander:new({name='Mosul-supply-Erbil', mission='supply',template='HeloSupplyTemplate', targetzone='Erbil Airport'}),
    GroupCommander:new({name='Mosul-supply-hamam', mission='supply',template='HeloSupplyTemplate', targetzone='Hammam Al Alil'}),
    GroupCommander:new({name='Mosul-attack-Erbil-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Erbil Airport', spawnDelayFactor = 3})
})
zones.duhokcity:addGroups({
    GroupCommander:new({name='Duhuk-supply-MosulCity', mission='supply',template='SupplyConvoy', targetzone='Mosul City', type='surface'}),
    GroupCommander:new({name='Duhuk-supply-Outpost', mission='supply',template='SupplyConvoy', targetzone='OutPost', type='surface'})
})
zones.talafar:addGroups({
	GroupCommander:new({name='Tal-Afar-supply-MoslulCity-Convoy', mission='supply',template='SupplyConvoy', targetzone='Mosul City', type='surface'}),
	GroupCommander:new({name='Tal Afar-attack-mosul', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Mosul City', spawnDelayFactor = 1.5})
})
zones.kirkuk:addGroups({
	GroupCommander:new({name='Kirkuk-supply-Khormato', mission='supply',template='HeloSupplyTemplate', targetzone='Khormato'}),
	GroupCommander:new({name='Kirkuk-supply-Sarqala', mission='supply',template='HeloSupplyTemplate', targetzone='Sarqala'}),
	GroupCommander:new({name='Kirkuk-supply-Maydan', mission='supply',template='HeloSupplyTemplate', targetzone='Maydan'}),
	GroupCommander:new({name='Kirkuk-supply-Said-Sadiq', mission='supply',template='HeloSupplyTemplate', targetzone='Said Sadiq'}),
	GroupCommander:new({name='Kirkuk-supply-Sulaimaniyah', mission='supply',template='HeloSupplyTemplate', targetzone='Sulaimaniyah Airport'}),
	GroupCommander:new({name='Kirkuk-supply-Al-Abbasi', mission='supply',template='HeloSupplyTemplate', targetzone='Al Abbasi'}),
	GroupCommander:new({name='Kirkuk-supply-Al-Sahra-Airport', mission='supply',template='HeloSupplyTemplate', targetzone='Al-Sahra Airport'}),
	GroupCommander:new({name='Kirkuk-supply-Balad Airbase', mission='supply',template='PlaneSupplyTemplate', targetzone='Balad Airbase'}),
	GroupCommander:new({name='Kirkuk-patrol-erbil-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Erbil Airport', Altitude = CapAltitude()})
})
zones.alsahra:addGroups({
	GroupCommander:new({name='Sahra-supply-Balad Airbase', mission='supply',template='HeloSupplyTemplate', targetzone='Balad Airbase'}),
	GroupCommander:new({name='Sahra-supply-Al-Asad Airbase', mission='supply',template='HeloSupplyTemplate', targetzone='Al-Asad Airbase'}),
	GroupCommander:new({name='Sahra-supply-Kirkuk', mission='supply',template='HeloSupplyTemplate', targetzone='Kirkuk City'}),
	GroupCommander:new({name='Sahra-supply-Al-Abbasi', mission='supply',template='HeloSupplyTemplate', targetzone='Al Abbasi'}),
	GroupCommander:new({name='Sahra-supply-Khormato', mission='supply',template='HeloSupplyTemplate', targetzone='Khormato'}),
	GroupCommander:new({name='Sahra-patrol-kirkuk-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kirkuk City', Altitude = CapAltitude()}),
	GroupCommander:new({name='Sahra-attack-Erbil', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Erbil Airport', Altitude = CapAltitude(), spawnDelayFactor = 3}),
	GroupCommander:new({name='Sahra-attack-Erbil-2', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Erbil Airport', Altitude = CapAltitude(), spawnDelayFactor = 5}),
	GroupCommander:new({name='Sahra-attack-Erbil2', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Erbil Airport', Altitude = CapAltitude(), spawnDelayFactor = 1.5}),
	GroupCommander:new({name='sahra-attack-erbil-cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Erbil Airport',Altitude = CasAltitude(), spawnDelayFactor = 3}),
	GroupCommander:new({name='Sahra-supply-sahra-defence', mission='supply',template='SupplyConvoy', targetzone='Sahra Defence', spawnDelayFactor = 1.5, type='surface'})
})
zones.maydan:addGroups({
	GroupCommander:new({name='Maydan-supply-Kirkuk', mission='supply',template='HeloSupplyTemplate', targetzone='Kirkuk City'}),
	GroupCommander:new({name='Maydan-supply-Sarqala', mission='supply',template='HeloSupplyTemplate', targetzone='Sarqala'}),
	GroupCommander:new({name='Maydan-supply-Said-Sadiq', mission='supply',template='HeloSupplyTemplate', targetzone='Said Sadiq'})
})
zones.saidsadiq:addGroups({
	GroupCommander:new({name='Said-Sadiq-supply-Sulaimaniyah-Convoy', mission='supply',template='SupplyConvoy', targetzone='Sulaimaniyah Airport', type='surface'}),
	GroupCommander:new({name='Said-Sadiq-supply-Sulaimaniyah', mission='supply',template='HeloSupplyTemplate', targetzone='Sulaimaniyah Airport', spawnDelayFactor = 2}),
	GroupCommander:new({name='Said-Sadiq-supply-maydan', mission='supply',template='HeloSupplyTemplate', targetzone='Maydan'})
})
zones.khormato:addGroups({
	GroupCommander:new({name='Khormato-supply-Kirkuk', mission='supply',template='SupplyConvoy', targetzone='Kirkuk City', type='surface'}),
	GroupCommander:new({name='Khormato-supply-Sarqala', mission='supply',template='SupplyConvoy', targetzone='Sarqala', type='surface'}),
	GroupCommander:new({name='Khormato-patrol-said', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Said Sadiq', Altitude = CapAltitude(), spawnDelayFactor = 2})
})
zones.fallujah:addGroups({
	GroupCommander:new({name='Faljuta-supply-ramadi', mission='supply',template='SupplyConvoy', targetzone='Ramadi', type='surface'})
})
zones.alabbasi:addGroups({
	GroupCommander:new({name='alabbasi-supply-Qayyarah-Airfield', mission='supply',template='HeloSupplyTemplate', targetzone='Qayyarah Airfield'})
})
zones.sulaimaniyah:addGroups({
	GroupCommander:new({name='Sulaimaniyah-supply-Saidsadiq-convoy', mission='supply',template='SupplyConvoy', targetzone='Said Sadiq', type='surface'}),
	GroupCommander:new({name='Sulaimaniyah-attack-erbil', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Erbil Airport', Altitude = CapAltitude(), spawnDelayFactor = 3}),
	GroupCommander:new({name='Sulaimaniyah-attack-erbil2', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Erbil Airport', Altitude = CapAltitude(), spawnDelayFactor = 1.5}),
	GroupCommander:new({name='Sulaimaniyah-attack-sahra-cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Al-Sahra Airport', Altitude = CasAltitude(), spawnDelayFactor = 2}),
	GroupCommander:new({name='Sulaimaniyah-supply-maydan', mission='supply',template='HeloSupplyTemplate', targetzone='Maydan'}),
	GroupCommander:new({name='Sulaimaniyah-supply-Erbil', mission='supply',template='PlaneSupplyTemplate', targetzone='Erbil Airport'}),
	GroupCommander:new({name='Sulaimaniyah-supply-Mosul', mission='supply',template='PlaneSupplyTemplate', targetzone='Mosul City'}),
	GroupCommander:new({name='Sulaimaniyah-supply-Sahra', mission='supply',template='PlaneSupplyTemplate', targetzone='Al-Sahra Airport'}),
})
zones.qayyarah:addGroups({
	GroupCommander:new({name='Qayyarah-patrol-mosulCity-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Mosul City', Altitude = CapAltitude()}),
	GroupCommander:new({name='Qayyarah-attack-erbilAirport-Cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Erbil Airport', Altitude = CasAltitude()}),
	GroupCommander:new({name='Qayyarah-supply-al-tall', mission='supply',template='HeloSupplyTemplate', targetzone='Al Tall'}),
	GroupCommander:new({name='Qayyarah-supply-Hammam', mission='supply',template='HeloSupplyTemplate', targetzone='Hammam Al Alil'}),
	GroupCommander:new({name='Qayyarah-supply-Al-Abbasi', mission='supply',template='HeloSupplyTemplate', targetzone='Al Abbasi'})
})
zones.baladairbase:addGroups({
	GroupCommander:new({name='Balad Airbase-supply-Sahra', mission='supply',template='HeloSupplyTemplate', targetzone='Al-Salam Airbase'}),
	GroupCommander:new({name='Balad-Airbase-patrol-Sahra-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Al-Sahra Airport', Altitude = CapAltitude()}),
	GroupCommander:new({name='Balad-Airbase-patrol-kirkuk', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Kirkuk City', Altitude = CapAltitude()}),
	GroupCommander:new({name='Balad Airbase-supply-Fallujah', mission='supply',template='HeloSupplyTemplate', targetzone='Fallujah'}),
	GroupCommander:new({name='Balad Airbase-attack-Sahra-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Al-Sahra Airport', Altitude = CasAltitude()}),
	GroupCommander:new({name='Balad Airbase-attack-Sarqala-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Sarqala', Altitude = CasAltitude()}),
	GroupCommander:new({name='Balad Airbase-Khormato-Sarqala-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Khormato', Altitude = CasAltitude()}),
	GroupCommander:new({name='Balad Airbase-supply-Al-Sahra', mission='supply',template='PlaneSupplyTemplate', targetzone='Al-Sahra Airport'}),
	GroupCommander:new({name='Balad Airbase-supply-al-asad', mission='supply',template='PlaneSupplyTemplate', targetzone='Al-Asad Airbase'})
})

zones.alasadairbase:addGroups({
	GroupCommander:new({name='Al-Asad Airbase-supply-Ramadi', mission='supply',template='HeloSupplyTemplate', targetzone='Ramadi'}),
	GroupCommander:new({name='asad-patrol-sahra-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Al-Sahra Airport', Altitude = CapAltitude()}),
	GroupCommander:new({name='asad-attack-sahra-RunwayStrike', mission='attack',template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Al-Sahra Airport', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='asad-attack-sahra-Sead', mission='attack',template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Al-Sahra Airport', Altitude = SeadAltitude()})
})

zones.ramadi:addGroups({
	GroupCommander:new({name='Ramadi-supply-Fallujah', mission='supply',template='SupplyConvoy', targetzone='Fallujah', type='surface'}),
	GroupCommander:new({name='Ramadi-supply-ramadi-sam', mission='supply',template='SupplyConvoy', targetzone='Ramadi SAM', spawnDelayFactor = 1.5, type='surface'})
})
zones.saidsadiq:addGroups({
	GroupCommander:new({name='Said-Sadiq-supply-Sulaimaniyah-Convoy', mission='supply',template='SupplyConvoy', targetzone='Sulaimaniyah Airport', type='surface'})
})
zones.alsalamairbase:addGroups({
	GroupCommander:new({name='Salam-Airbase-supply-samwest', mission='supply',template='SupplyConvoy', targetzone='SAM West', spawnDelayFactor = 1.5, type='surface'}),
	GroupCommander:new({name='Salam-Airbase-supply-sameast', mission='supply',template='SupplyConvoy', targetzone='SAM East', spawnDelayFactor = 2, type='surface'}),
	GroupCommander:new({name='Salam-Airbase-supply-SAM South', mission='supply',template='SupplyConvoy', targetzone='SAM South', spawnDelayFactor = 2.5, type='surface'}),
	GroupCommander:new({name='Al-Salam Airbase-supply-Fallujah', mission='supply',template='SupplyConvoy', targetzone='Fallujah', type='surface'}),
	GroupCommander:new({name='Salam-Airbase-supply-Balad Airbase', mission='supply',template='PlaneSupplyTemplate', targetzone='Balad Airbase'}),
	GroupCommander:new({name='Salam-patrol-sahra-cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Al-Sahra Airport', Altitude = CapAltitude()}),
	GroupCommander:new({name='Salam-patrol-Balad-cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Balad Airbase', Altitude = CapAltitude()}),
	GroupCommander:new({name='Salam-attack-balad-cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Balad Airbase', Altitude = CapAltitude()}),
	GroupCommander:new({name='Salam-attack-balad-cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Balad Airbase', Altitude = CasAltitude()}),
	GroupCommander:new({name='Salam-attack-sahra-cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Al-Sahra Airport', Altitude = CapAltitude()}),
	GroupCommander:new({name='Salam-attack-sahra-cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Al-Sahra Airport', Altitude = CasAltitude()}),
	GroupCommander:new({name='Salam-attack-sahra-cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Al-Sahra Airport', Altitude = CasAltitude()}),
})


for i,v in pairs(zones) do
	bc:addZone(v)
end

zones.bashurairport.isHeloSpawn = true
zones.bashurairport.LogisticCenter = true

zones.barzan.isHeloSpawn = true
zones.barzan.LogisticCenter = true

zones.erbilairport.isHeloSpawn = true
zones.qayyarah.isHeloSpawn = true
zones.sulaimaniyah.isHeloSpawn = true

zones.chamanki.isHeloSpawn = true
zones.outpost.isHeloSpawn = true
zones.fobsamarra.isHeloSpawn = true
zones.fobtherethar.isHeloSpawn = true
zones.saidsadiq.isHeloSpawn = true
zones.maydan.isHeloSpawn = true
zones.sarqala.isHeloSpawn = true
zones.alabbasi.isHeloSpawn = true
zones.talafar.isHeloSpawn = true
zones.duhokcity.isHeloSpawn = true
zones.khormato.isHeloSpawn = true
zones.mosulcity.isHeloSpawn = true
zones.ramadi.isHeloSpawn = true
zones.baladairbase.isHeloSpawn = true
zones.alsalamairbase.isHeloSpawn = true
zones.alasadairbase.isHeloSpawn = true
zones.kirkuk.isHeloSpawn = true
zones.dukan.isHeloSpawn = true
zones.koya.isHeloSpawn = true


zones.bashurairport.airbaseName = 'Bashur Airport'
zones.erbilairport.airbaseName = 'Erbil International Airport'
zones.qayyarah.airbaseName = 'Qayyarah Airfield West'
zones.sulaimaniyah.airbaseName = 'Sulaimaniyah International Airport'
zones.alsahra.airbaseName = 'Al-Sahra Airport'
zones.barzan.airbaseName = 'Barzan'
zones.chamanki.airbaseName = 'Chamanki'
zones.outpost.airbaseName = 'OutPost'
zones.fobsamarra.airbaseName = 'FOB Samarra'
zones.fobtherethar.airbaseName = 'FOB Therethar'
zones.saidsadiq.airbaseName = 'Said Sadiq'
zones.maydan.airbaseName = 'Maydan'
zones.sarqala.airbaseName = 'Sarqala'
zones.alabbasi.airbaseName = 'Al Abbasi'
zones.talafar.airbaseName = 'Tal Afar'
zones.duhokcity.airbaseName = 'Duhok City'
zones.khormato.airbaseName = 'Khormato'
zones.mosulcity.airbaseName = 'Mosul International Airport'
zones.alsalamairbase.airbaseName = 'Al-Salam Airbase'
zones.ramadi.airbaseName = 'Ramadi'
zones.baladairbase.airbaseName = 'Balad Airbase'
zones.alasadairbase.airbaseName = 'Al-Asad Airbase'
zones.kirkuk.airbaseName = 'Kirkuk International Airport'
zones.dukan.airbaseName = 'Dukan'
zones.koya.airbaseName = 'Koya'


bc:addConnection("Bashur Airport","Erbil Airport")
bc:addConnection("Barzan","Chamanki")
bc:addConnection("Chamanki","OutPost")
bc:addConnection("OutPost","Duhok City")
bc:addConnection("Erbil Airport","Erbil Defence")
bc:addConnection("Duhok City","Mosul City")
bc:addConnection("Erbil Airport","Barzan")
bc:addConnection("Erbil Airport","Koya")
bc:addConnection("Koya","Dukan")
bc:addConnection("Dukan","Sangasar")
bc:addConnection("Mosul City","Hammam Al Alil")
bc:addConnection("Mosul City","Tal Afar")
bc:addConnection("Tal Afar","Al Tall")
bc:addConnection("Al Tall","Qayyarah Airfield")
bc:addConnection("Qayyarah Airfield","Chemsite")
bc:addConnection("Qayyarah Airfield","Al Abbasi")
bc:addConnection("Al Abbasi","Kirkuk City")
bc:addConnection("Kirkuk City","Sulaimaniyah Airport")
bc:addConnection("Sulaimaniyah Airport","Said Sadiq")
bc:addConnection("Said Sadiq","Maydan")
bc:addConnection("Maydan","Sarqala")
bc:addConnection("Sarqala","Khormato")
bc:addConnection("Khormato","Al-Sahra Airport")
bc:addConnection("Al-Sahra Airport","FOB Therethar")
bc:addConnection("Al-Sahra Airport","Sahra Defence")
bc:addConnection("FOB Therethar","Al-Asad Airbase")
bc:addConnection("Al-Asad Airbase","Ramadi")


bc:addConnection("FOB Samarra","Balad Airbase")
bc:addConnection("Balad Airbase","Al-Salam Airbase")
bc:addConnection("Balad Airbase","Balad Defence")
bc:addConnection("Balad Airbase","SecretTechFacility")
bc:addConnection("Al-Salam Airbase","SAM East")
bc:addConnection("Al-Salam Airbase","SAM West")
bc:addConnection("Al-Salam Airbase","SAM South")
bc:addConnection("Al-Salam Airbase","Oil production Site")
bc:addConnection("Al-Salam Airbase","Uranium enrichment Site")
bc:addConnection("Oil production Site","Scud City")
bc:addConnection("Ramadi","Fallujah")
bc:addConnection("Ramadi","FOB Samarra")

bc:addConnection("Ramadi","Ramadi SAM")
bc:addConnection("Al-Asad Airbase","InsurgentCamp")
bc:addConnection("Qayyarah Airfield","MiningFacility")
bc:addHiddenConnection("Balad Airbase","Kirkuk City")
bc:addHiddenConnection("Balad Airbase","Sulaimaniyah Airport")
bc:addHiddenConnection("Balad Airbase","Al Abbasi")
bc:addHiddenConnection("Balad Airbase","Al Abbasi")
bc:addHiddenConnection("Balad Airbase","Al Sahra Airport")
bc:addHiddenConnection("Balad Airbase","Al-Asad Airbase")
bc:addHiddenConnection("Balad Airbase","Maydan")
bc:addHiddenConnection("Balad Airbase","Khormato")
bc:addHiddenConnection("Al Sahra Airport","Al Abbasi")
bc:addHiddenConnection("Al Sahra Airport","Kirkuk City")
bc:addHiddenConnection("Al Sahra Airport","Sulaimaniyah Airport")
bc:addHiddenConnection("Al Sahra Airport","Qayyarah Airfield")
bc:addHiddenConnection("Al Sahra Airport","Erbil Airport")
bc:addHiddenConnection("Kirkuk City","Erbil Airport")
bc:addHiddenConnection("Kirkuk City","Mosul City")
bc:addHiddenConnection("Kirkuk City","Qayyarah Airfield")
bc:addHiddenConnection("Mosul City","Erbil Airport")
bc:addHiddenConnection("Al-Salam Airbase","Ramadi")
bc:addHiddenConnection("Al-Salam Airbase","Fallujah")
bc:addHiddenConnection("Al-Salam Airbase","Al Sahra Airport")
bc:addHiddenConnection("Al-Salam Airbase","Khormato")
bc:addHiddenConnection("Al-Salam Airbase","Sarqala")
bc:addHiddenConnection("Al-Salam Airbase","Al-Asad Airbase")
bc:addHiddenConnection("Sulaimaniyah Airport","Erbil Airport")


zones.secrettechfacility:addCriticalObject('SecretTechFacility1')
zones.secrettechfacility:addCriticalObject('SecretTechFacility2')
zones.secrettechfacility:addCriticalObject('SecretTechFacility3')
zones.secrettechfacility:addCriticalObject('SecretTechFacility4')
zones.secrettechfacility:addCriticalObject('SecretTechFacility5')

missions = {
    Barzan = {	
        zone = "Barzan",
        missionGroup = "MissionGroupBarzan",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Barzan"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Barzan"),
        TargetZone = "Chamanki",
        MissionType = "Escort",
		radius = 2000,
		flag = 101,
		ActivateZone = "barzanhidden"
    },
    Chamanki = {
        zone = "Chamanki",
        missionGroup = "MissionGroupChamanki",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Chamanki"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Chamanki"),
        TargetZone = "OutPost",
        MissionType = "Escort",
		radius = 2000,
		flag = 111,
		ActivateZone = "chamankihidden"
    },
    OutPost = {	
        zone = "OutPost",
        missionGroup = "MissionGroupOutpost",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Outpost"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Outpost"),
        TargetZone = "Duhok City",
        MissionType = "Escort",
		radius = 2500,
		flag = 121,
		ActivateZone = "outposthidden"
    },
	Ramadi = {	
        zone = "Ramadi",
        missionGroup = "MissionGroupRamadi",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Ramadi"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Ramadi"),
        TargetZone = "Fallujah",
        MissionType = "Escort",
		radius = 3000,
		flag = 131,
		ActivateZone = "ramadihidden"
    },
	Koya = {
        zone = "Koya",
        missionGroup = "MissionGroupKoya",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Koya"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Koya"),
        TargetZone = "Dukan",
        MissionType = "Escort",
		radius = 3000,
		flag = 141,
		ActivateZone = "koyahidden"
    },
	Dukan = {
        zone = "Dukan",
        missionGroup = "MissionGroupDukan",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Dukan"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Dukan"),
        TargetZone = "Sangasar",
        MissionType = "Escort",
		radius = 3000,
		flag = 151,
		ActivateZone = "dukanhidden"
    }
}

function SpawnFriendlyAssets()

end
SCHEDULER:New(nil,SpawnFriendlyAssets,{},5,0)


function checkAndDisableFriendlyZones()


	if zones.kirkuk.wasBlue or zones.sulaimaniyah.wasBlue and not zones.hidden2.firstCaptureByRed then
		zones.hidden2:MakeZoneRedAndUpgrade()
		zones.hidden1:DestroyHiddenZone()
	end
	if zones.alsahra.wasBlue and not zones.hidden5.firstCaptureByRed then
		zones.hidden5:MakeZoneRedAndUpgrade()
		zones.hidden3:DestroyHiddenZone()
	end	
end

SCHEDULER:New(nil,checkAndDisableFriendlyZones,{},3,0)

zones.chemsite:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disablechemsite1')


zones.chemsite:registerTrigger('destroyed', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_CHEMICAL_SITE_DESTROYED"),20)
end, 'disablechemsite2')

zones.miningfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_MINING_FACILITY_CLEARED"),20)
end, 'disableminingfacility')


zones.secrettechfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disablesecrettechfacility1')

zones.secrettechfacility:registerTrigger('destroyed', function(event, sender) 
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_SECRET_TECH_DISABLED"),20)
end, 'disablesecrettechfacility2')

zones.insurgentcamp:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_INSURGENT_CAMP_DESTROYED"),20)
end, 'disableinsurgentcamp')

zones.erbildefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_ENEMY_SAM_DESTROYED"),20)
end, 'erbildefencesambravo')

zones.sameast:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_ENEMY_SAM_DESTROYED"),20)
end, 'sameastsamcharlie')

zones.samwest:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_ENEMY_SAM_DESTROYED"),20)
end, 'samwestsamdelta')

zones.samsouth:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_ENEMY_SAM_DESTROYED"),20)
end, 'samsouthsamecho')

zones.ramadisam:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_ENEMY_SAM_DESTROYED"),20)
end, 'disableramadisam')

zones.sahradefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_ENEMY_SAM_DESTROYED"),20)
end, 'disablesahradefence')

zones.baladdefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_ENEMY_SAM_DESTROYED"),20)
end, 'disablebaladdefence')


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


SCHEDULER:New(nil,function()
	checkMissionComplete(nil, nil)
  if Era == 'Coldwar' then
	bc:roamGroupsToLocalSubZone({
		"Red SAM AAA #",
		"Red SAM AAA 2 #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-19 #",
		'Red Armor Group6',
		'Red Armor Group8',
	}, 30)
  else
	bc:roamGroupsToLocalSubZone({
	"Red Armour Group 2 #",
	"Red SAM AAA #",
	"Red SAM AAA 2 #",
	"Red SAM SHORAD SA-15 #",
	"Red SAM SHORAD SA-8 #",
	"Red SAM SHORAD SA-19 #",
	"Red SAM SHORAD Tor M2 #",
	"Red SAM SHORAD Pantsir S1 #",
	"Red Armour Group #",
  
	}, 30)
  end
end,{},30,0)

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
		local T = L10N:ForGroup(groupId)
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
end
if bc.shopItems['supplies'] then
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

bc:registerShopItem('zinf',LTGet("SYRIA_SHOP_ITEM_UPGRADE_INFANTRY"),ShopPrices.zinf,function(sender)
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
	if params.zone and not params.zone.suspended then
		return bc:applyLogisticCenterUpgrade(params.zone)
	end
	return LTGet("SYRIA_SHOP_MUST_PICK_FRIENDLY_ZONE")
end)

bc:registerShopItem('zwh50',LTGet("SYRIA_SHOP_ITEM_WAREHOUSE_50"),ShopPrices.zwh50,function(sender)
	if not WarehouseLogistics then
		return LTGet("WAREHOUSE_LOGISTICS_DISABLED")
	end
	return LTGet("SYRIA_SHOP_CHOOSE_ZONE")
end,
function(sender,params)
	if params.zone and params.zone.side == 2 then
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
		params.zone:addExtraSlot('bluePATRIOT') -- checked
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
	jam            = 4,  -- Jam radars at zone
}

-----------------------------------------------

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
    "Bashur Airport",
    "Erbil Airport",
    "Mosul City",
    "Hammam Al Alil",
    "Duhok City",
    "Tal Afar",
    "Al Tall",
    "Qayyarah Airfield",
    "Al Abbasi",
    "Kirkuk City",
    "Sulaimaniyah Airport",
    "Said Sadiq",
    "Al-Sahra Airport",
    "Barzan",
    "Chamanki",
    "OutPost",
    "Maydan",
    "Sarqala",
    "Khormato",
    "Balad Airbase",
    "Al-Salam Airbase",
    "Fallujah",
    "Ramadi",
    "Al-Asad Airbase",
    "FOB Samarra",
    "FOB Therethar",
    "Erbil Defence",
    "SAM East",
    "SAM West",
    "SAM South",
    "Ramadi SAM",
	"Koya",
	"Dukan",
	"Sangasar"
}

TerritoryOverlayOuterDrawPushMeters = 500000	

lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

bc:loadFromDisk() -- will load and overwrite default zone levels, sides, funds, and available shop items
if zonePersistance and zonePersistance.zones and next(zonePersistance.zones) == nil then
    bc.saveLoaded = false
end
if not bc.saveLoaded then
	applyRandomRedUpgrades()
	applyRandomBlueUpgrades()
end



budgetAI = BudgetCommander:new({ battleCommander = bc, side=1, decissionFrequency=20*60, decissionVariance=10*60, skipChance = 10})
budgetAI:init()
bc:init()
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

SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 5)
SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 6)

AWACS_CFG = {
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=100 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=75 }   -- blue
}

GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 90   		-- suspend red zones deeper than this nm
evc = EventCommander:new({ decissionFrequency=30*60, decissionVariance=30*60, skipChance = 15})
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


evc:addEvent({
	id='scuds',
	action = function()
		timer.scheduleFunction(function(param, time)
			if Group.getByName('ScudCity-Fixed') then
				local tgts = {'Al-Salam Airbase', 'Fallujah', 'Ramadi', 'Al-Asad Airbase', 'Al-Sahra Airport',
					'Khormato', 'Sarqala', 'Maydan'}
				local validtgts = {}
				for _,v in ipairs(tgts) do
					if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
						table.insert(validtgts, v)
					end
				end
				if #validtgts == 0 then return time+(10*60) end
				
				local die = math.random(1,#validtgts)
				local choice = validtgts[die]
				bc:fireAtZone(choice, 'ScudCity-Fixed', true, 8)
				fired = true
				trigger.action.outTextForCoalition(2, L10N:Format("IRAQ_EVENT_SCUDS_LAUNCHING", choice), 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
		if fired then return false end
		local ScudGroup = GROUP:FindByName('ScudCity-Fixed')
		if not ScudGroup then return false end
		if bc:getZoneByName('Scud City').side ~= 1 or bc:getZoneByName('Scud City').suspended then return false end
		local triggers = {'Balad Airbase', 'Al-Sahra Airport', 'Khormato', 'Sarqala'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		return false
	end
})



  local setBlueUnits = SET_GROUP:New():FilterCoalitions("blue"):FilterStart()
  local convoyZones = {
    {zone = ZONE:New("ConvoyZone"), flag = "ConvoyMove"},
    {zone = ZONE:New("ConvoyZone2"), flag = "ConvoyMove2"}
  }

  for _, entry in ipairs(convoyZones) do
    entry.zone:Trigger(setBlueUnits)

    function entry.zone:OnAfterEnteredZone(From, Event, To, Controllable)
      if not Controllable or not Controllable:IsAlive() then return end
      trigger.action.setUserFlag(entry.flag, 1)
    end
  end

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
		if bc:getZoneByName('Balad Airbase').side == 1 and not bc:getZoneByName('Balad Airbase').suspended then
			planes = { 'evt-cargointercept1' }
		elseif bc:getZoneByName('Qayyarah Airfield').side == 1 and not bc:getZoneByName('Qayyarah Airfield').suspended then
			planes = { 'evt-cargointercept2' }
		elseif bc:getZoneByName('Al-Sahra Airport').side == 1 and not bc:getZoneByName('Al-Sahra Airport').suspended then
			planes = { 'evt-cargointercept3' }
		else
			return
		end
		RespawnGroup(planes[1])
		local u = Group.getByName(planes[1]):getUnit(1)
		if u then RegisterUnitTarget(u:getName(),250,L10N:Get("SYRIA_MISSION_INTERCEPT_CARGO_TITLE"),'cargointercept') end
	end,
	canExecute = function()
		if ActiveMission['cargointercept'] then return false end
		if timer.getTime() - lastCargoIntercept_COOLDOWN < CargoIntercept_COOLDOWN then return false end
		if math.random(1,100) < 70 then return false end
		if (bc:getZoneByName('Balad Airbase').side == 2
		and bc:getZoneByName('Qayyarah Airfield').side == 2
		and bc:getZoneByName('Al-Sahra Airport').side == 2)
		or (bc:getZoneByName('Balad Airbase').suspended
		and bc:getZoneByName('Qayyarah Airfield').suspended
		and bc:getZoneByName('Al-Sahra Airport').suspended) then return false end
		if Group.getByName('evt-cargointercept1') then return false end
		if Group.getByName('evt-cargointercept2') then return false end
		if Group.getByName('evt-cargointercept3') then return false end
		return true
	end
})

mc:trackMission({
    title = LTGet("SYRIA_MISSION_INTERCEPT_CARGO_TITLE"),
    description = LTGet("IRAQ_MISSION_INTERCEPT_CARGO_DESC"),
    messageStart = L10N:Get("SYRIA_MISSION_INTERCEPT_CARGO_START"),
    messageEnd =function() lastCargoIntercept_COOLDOWN=timer.getTime() return L10N:Get("SYRIA_MISSION_INTERCEPT_CARGO_END") end,
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

local airstrike_COOLDOWN = 1800
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
			local tgts = {
			'Kirkuk City',
			'Sulaimaniyah Airport',
			'Tal Afar',
			'Al Tall',
			'Qayyarah Airfield',
			'Al Abbasi',
			'Balad Airbase',
			'FOB Samarra',
			'Al-Asad Airbase',
			'Maydan',
			'Bashur Airport',
			'Sarqala',
			'Al-Sahra Airport',
			'Fallujah'
			}
			
			local validtgts = {}
			for _,v in ipairs(tgts) do
				if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then
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
		if bc:getZoneByName('Al-Salam Airbase').side == 2 and not bc:getZoneByName('Al-Salam Airbase').suspended then return false end
		
		local triggers = {'Erbil Airport', 'Kirkuk City', 'Sulaimaniyah Airport', 'Balad Airbase'}
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
	description = LTGet("IRAQ_MISSION_INTERCEPT_AIRSTRIKE_DESC"),
	messageStart = L10N:Get("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_START"),
	messageEnd =function() lastairstrike_COOLDOWN=timer.getTime() return L10N:Get("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_END") end,
	startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
	isActive = function()
		if not ActiveMission['cas'] then return false end
		if Group.getByName(attackGrp) then return true end
		ActiveMission['cas'] = nil
		return false
	end
})
local sceneryList = {
  ["RightHandMan"] = {SCENERY:FindByZoneName("RightHandMan")},
  ["StrikeTarget"] = {SCENERY:FindByZoneName("StrikeTarget")},
  ["StrikeTarget1"] = {SCENERY:FindByZoneName("StrikeTarget1")},
  ["StrikeTarget2"] = {SCENERY:FindByZoneName("StrikeTarget2")},
  ["StrikeTarget3"] = {SCENERY:FindByZoneName("StrikeTarget3")},
  
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

local bomb_COOLDOWN = 1800
local lastbomb_COOLDOWN  = -bomb_COOLDOWN
local escGrp = Era=='Coldwar' and 'EscortBomberCW' or 'EscortBomber'
Group.getByName('evt-bomb'):destroy()
Group.getByName('EscortBomberCW'):destroy()
Group.getByName('EscortBomber'):destroy()
evc:addEvent({
	id='bomb',
	action=function()
		RespawnGroup('evt-bomb')
		RegisterGroupTarget('evt-bomb',500,L10N:Get("SYRIA_MISSION_TARGET_INTERCEPT_BOMBERS"),'bomb')
		timer.scheduleFunction(function()
			RespawnGroup(escGrp)
	local tgts = {
		'Kirkuk City','Sulaimaniyah Airport','Tal Afar','Al Tall','Qayyarah Airfield','Al Abbasi','Balad Airbase',
		'FOB Samarra','Al-Asad Airbase','Maydan','Bashur Airport','Sarqala','Al-Sahra Airport','Fallujah'}
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
		local triggers = {'Erbil Airport', 'Kirkuk City', 'Sulaimaniyah Airport', 'Balad Airbase'}
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
	description = LTGet("IRAQ_MISSION_INTERCEPT_BOMBERS_DESC"),
	messageStart = L10N:Get("SYRIA_MISSION_INTERCEPT_BOMBERS_START"),
	messageEnd=function() lastbomb_COOLDOWN=timer.getTime() return L10N:Get("SYRIA_MISSION_INTERCEPT_BOMBERS_END") end,
	startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
	isActive = function()
		if not ActiveMission['bomb'] then return false end
		if Group.getByName('evt-bomb') then return true end
		ActiveMission['bomb'] = nil
		return false
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
							trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_ENEMY_INTERCEPTOR_SPOTTED"),15)
						else
							trigger.action.outTextForCoalition(2,L10N:Get("IRAQ_EVENT_ENEMY_INTERCEPT_MISSION"),15)
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
		if bc:getZoneByName('Erbil Airport').side ~= 2 or bc:getZoneByName('Erbil Airport').suspended then return false end
		if bc:getZoneByName('Al Tall').side ~= 2 or bc:getZoneByName('Al Tall').suspended then return false end
		local triggers = {'Kirkuk City', 'Qayyarah Airfield', 'Al-Sahra Airport', 'Al-Asad Airbase'}
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
    description = LTGet("IRAQ_MISSION_ESCORT_CARGO_DESC"),
    messageStart = L10N:Get("IRAQ_MISSION_ESCORT_CARGO_START"),
    messageEnd =function() lastEscort_COOLDOWN=timer.getTime() return L10N:Get("IRAQ_MISSION_ESCORT_CARGO_END") end,
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


-- mission Al-Baghdadi associate
Group.getByName('KanaqinConvoy'):destroy()
Group.getByName('KanaqinConvoy-1'):destroy()
Group.getByName('KanaqinConvoy-2'):destroy()
evc:addEvent({
	id='FindHimInKanaqin',
	action = function()
		RespawnGroup('KanaqinConvoy')
		RespawnGroup('KanaqinConvoy-1')
		RegisterGroupTarget("KanaqinConvoy-2",500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),"FindHimInKanaqin",true)
	end,
	canExecute = function()
		if CustomFlags["FindHimInKanaqin"] then return false end
		if ActiveMission['FindHimInKanaqin'] then return false end
		if Group.getByName('KanaqinConvoy') then return false end
		if bc:getZoneByName('Kirkuk City').side ~= 2 and bc:getZoneByName('Balad Airbase').side ~= 2 then return false end
		return true
end
})

mc:trackMission({
	title = LTGet("IRAQ_MISSION_BAGHDADI_ASSOCIATE_TITLE"),
	description = LTGet("IRAQ_MISSION_BAGHDADI_ASSOCIATE_DESC"),
	messageStart = L10N:Get("IRAQ_MISSION_BAGHDADI_ASSOCIATE_START"),
	messageEnd = L10N:Get("IRAQ_MISSION_BAGHDADI_ASSOCIATE_END"),
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
		if not IsGroupActive('KanaqinConvoy') and IsGroupActive('KanaqinConvoy-1') then
			trigger.action.outTextForCoalition(2, L10N:Get("IRAQ_MISSION_CONVOY_DESTROYED_FAILED"), 10)
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
			destroyGroupIfActive('KanaqinConvoy-2')
			destroyGroupIfActive('KanaqinConvoy-1')
			return true
		end
		return false
	end,
	isActive = function()
		if CustomFlags["FindHimInKanaqin"] then return false end
		if bc:getZoneByName('Al-Sahra Airport').side ~= 2 and bc:getZoneByName('Balad Airbase').side ~= 2 then return false end
		if not ActiveMission['FindHimInKanaqin'] then return false end
		if Group.getByName('KanaqinConvoy') then return true end
		if Group.getByName('KanaqinConvoy-1') then return true end
		if Group.getByName('KanaqinConvoy-2') then return true end
		ActiveMission['FindHimInKanaqin'] = nil
		return false
	end
})
-- end of Al-Baghdadi associate

-- strike target 2

Group.getByName('Red SAM SHORAD SA-8 StrikeTarget2'):destroy()
evc:addEvent({
	id='StrikeTarget2',
	action = function()
	local tgt = sceneryList['StrikeTarget2'][1] or SCENERY:FindByZoneName('StrikeTarget2')
	if not tgt then
		trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "StrikeTarget2"),30)
		return
	end
		RespawnGroup('Red SAM SHORAD SA-8 StrikeTarget2')
		RegisterScoreTarget('StrikeTarget2',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("IRAQ_MISSION_HIGH_VALUE_2_MARKER"),p,2,false,false)
			MissionMarks['StrikeTarget2'] = missionMarkId
		end
	end,
	canExecute = function()
		if CustomFlags["StrikeTarget2"] then return false end
		if ActiveMission['StrikeTarget2'] then return false end
		if bc:getZoneByName('Al-Sahra Airport').side ~= 2 then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("IRAQ_MISSION_HIGH_VALUE_2_TITLE"),
	description = LTGet("IRAQ_MISSION_HIGH_VALUE_2_DESC"),
	messageStart = L10N:Get("IRAQ_MISSION_HIGH_VALUE_2_START"),
	messageEnd = L10N:Get("IRAQ_MISSION_HIGH_VALUE_2_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
		if CustomFlags["StrikeTarget2"] then return false end
		if ActiveMission['StrikeTarget2'] then return true end
		return false
	end,
})

-- end of strike target 2
---------------------------------- strike target 3 -----------------------------------------------
-- RightHandMan Strike Target 0
Group.getByName('StrikeTarget3Group'):destroy()
Group.getByName('Red SAM SA-6 Fixed StrikeTarget3'):destroy()
Group.getByName('Red SAM SHORAD SA-8 Fixed StrikeTarget3'):destroy()
local Alqam = nil
evc:addEvent({
	id='StrikeTarget3',
	action = function()
		RespawnGroup('StrikeTarget3Group')
		RegisterGroupTarget('StrikeTarget3Group',250,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),'StrikeTarget3',true)
	end,
	canExecute = function()
		if CustomFlags["StrikeTarget3"] then return false end
		if ActiveMission['StrikeTarget3'] then return false end
		if bc:getZoneByName('Al-Asad Airbase').side ~= 2 then return false end
		if Group.getByName('StrikeTarget3Group') then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("IRAQ_MISSION_SADDAM_ASSOCIATE_TITLE"),
	description = LTGet("IRAQ_MISSION_SADDAM_ASSOCIATE_DESC"),
	messageStart = L10N:Get("IRAQ_MISSION_SADDAM_ASSOCIATE_START"),
	messageEnd = L10N:Get("IRAQ_MISSION_SADDAM_ASSOCIATE_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
		RespawnGroup('Red SAM SA-6 Fixed StrikeTarget3')
		RespawnGroup('Red SAM SHORAD SA-8 Fixed StrikeTarget3')
	end,
	isActive = function()
		if CustomFlags["StrikeTarget3"] then return false end
		if bc:getZoneByName('Al-Asad Airbase').side ~= 2 then return false end
		if not ActiveMission['StrikeTarget3'] then return false end
		if Group.getByName('StrikeTarget3Group') then return true end
		ActiveMission['StrikeTarget3'] = nil
		return false
	end
})
-- end of strike target 3
---------------------------------- strike target 1 -----------------------------------------------

evc:addEvent({
	id = 'StrikeTarget1',
	action = function()
		local tgt = sceneryList['StrikeTarget1'][1] or SCENERY:FindByZoneName('StrikeTarget1')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "StrikeTarget1 scenery"),30)
			return
		end
		RegisterScoreTarget('StrikeTarget1',tgt,500,L10N:Get("CA_TARGET_HIGH_VALUE_TARGET"),true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),p,2,false,false)
			MissionMarks['StrikeTarget1'] = missionMarkId
		end
	end,
	canExecute = function()
		if CustomFlags['StrikeTarget1'] then return false end
		if ActiveMission['StrikeTarget1'] then return false end
		if bc:getZoneByName('Qayyarah Airfield').side ~= 2 then return false end
		if bc:getZoneByName('Al-Sahra Airport').side ~= 1 or bc:getZoneByName('Al-Sahra Airport').suspended then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("CA_MISSION_STRIKE_HIGH_VALUE_TITLE"),
	description = LTGet("IRAQ_MISSION_HIGH_VALUE_1_DESC"),
	messageStart = L10N:Get("CA_MISSION_STRIKE_HIGH_VALUE_GROUP_START"),
	messageEnd = L10N:Get("CA_MISSION_STRIKE_HIGH_VALUE_GROUP_END"),
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
	if ActiveMission['StrikeTarget1'] then return true end
	if CustomFlags["StrikeTarget1"] then return false end
	  return false
	end,
})
---------------------------------- END strike target 1 -----------------------------------------------
-- mission find the general
Group.getByName('GeneralKillConvoy'):destroy()
Group.getByName('StrikeTargetInfantry'):destroy()
evc:addEvent({
	id='StrikeTarget',
	action = function()
		RespawnGroup('GeneralKillConvoy')
		RegisterGroupTarget('StrikeTargetInfantry',500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),'StrikeTarget',true)
	end,
	canExecute = function()
		if CustomFlags["StrikeTarget"] then return false end
		if ActiveMission['StrikeTarget'] then return false end
		if math.random(1,100) < 50 then return false end
		if bc:getZoneByName('Sulaimaniyah Airport').side ~= 2 or bc:getZoneByName('Sulaimaniyah Airport').suspended then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("IRAQ_MISSION_BAGHDADI_KALAR_TITLE"),
	description = LTGet("IRAQ_MISSION_BAGHDADI_KALAR_DESC"),
	messageStart = L10N:Get("IRAQ_MISSION_BAGHDADI_KALAR_START"),
	messageEnd = L10N:Get("IRAQ_MISSION_BAGHDADI_KALAR_END"),
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
		if not IsGroupActive('GeneralKillConvoy') and IsGroupActive('StrikeTargetInfantry') then
			trigger.action.outTextForCoalition(2, L10N:Get("IRAQ_MISSION_TARGET_LOCATION_UNKNOWN_FAILED"), 15)
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
			return true
		end
		return false
	end,
	isActive = function()
		if CustomFlags["StrikeTarget"] then return false end
		if not ActiveMission['StrikeTarget'] then return false end
		if Group.getByName('GeneralKillConvoy') then return true end
		ActiveMission['StrikeTarget'] = nil
		return false
	end
})

-- end of the find the general

-- RightHandMan Strike Target 0
Group.getByName('RightHandMan'):destroy()
Group.getByName('Red SAM SA-3 Fixed Righthand'):destroy()
evc:addEvent({
	id='RightHandMan',
	action = function()
		RespawnGroup('RightHandMan')
		RegisterGroupTarget('RightHandMan',250,L10N:Get("IRAQ_TARGET_RIGHT_HAND_MAN"),'RightHandMan',true)
	end,
	canExecute = function()
		if CustomFlags["RightHandMan"] then return false end
		if ActiveMission['RightHandMan'] then return false end
		if bc:getZoneByName('Erbil Airport').side ~= 2 or bc:getZoneByName('Erbil Airport').suspended then return false end
		if Group.getByName('RightHandMan') then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("IRAQ_MISSION_RIGHT_HAND_MAN_TITLE"),
	description = LTGet("IRAQ_MISSION_RIGHT_HAND_MAN_DESC"),
	messageStart = L10N:Get("IRAQ_MISSION_RIGHT_HAND_MAN_START"),
	messageEnd = L10N:Get("IRAQ_MISSION_RIGHT_HAND_MAN_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
		RespawnGroup('Red SAM SA-3 Fixed Righthand')
	end,
	isActive = function()
		if CustomFlags["RightHandMan"] then return false end
		if not ActiveMission['RightHandMan'] then return false end
		if Group.getByName('RightHandMan') then return true end
		ActiveMission['RightHandMan'] = nil
		return false
	end
})
------------------------end of Second man mission----------------------------------

Group.getByName('All-Tall-Artillery'):destroy()
evc:addEvent({
	id='Artillery',
	action = function()
		RespawnGroup('All-Tall-Artillery')
		timer.scheduleFunction(function(param, time)
			if Group.getByName('All-Tall-Artillery') then
				local tgts = {'Tal Afar', 'Mosul City', 'Hammam Al Alil'}
				local validtgts = {}
				for _,v in ipairs(tgts) do
					if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
						table.insert(validtgts, v)
					end
				end
				if #validtgts == 0 then return time+(10*60) end
				local die = math.random(1,#validtgts)
				local choice = validtgts[die]
				bc:fireAtZone(choice, 'All-Tall-Artillery', true, 48)
				trigger.action.outTextForCoalition(2, L10N:Format("IRAQ_EVENT_ARTILLERY_LAUNCHING", "Al-Tall", choice), 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
		if math.random(1,100) < 70 then return false end
		local gr = Group.getByName('All-Tall-Artillery')
		if gr then return false end
		
		if bc:getZoneByName('Al Tall').side ~= 1 then return false end
		
		local triggers = {'Mosul City', 'Tal Afar', 'Hammam Al Alil'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		
		return false
	end
})
mc:trackMission({
	title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
	description = function(T) return LT(T):Format("IRAQ_MISSION_ARTY_FROM_DESC", "Al-Tall") end,
	messageStart = L10N:Format("IRAQ_MISSION_ARTY_CONVOY_START", "Al-Tall"),
	messageEnd = L10N:Get("SYRIA_MISSION_ARTY_END"),
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
		local gr = Group.getByName('All-Tall-Artillery')
		if gr then return true end
		return false
	end
})


Group.getByName('Khormato-Artillery'):destroy()
evc:addEvent({
	id='Artillery2',
	action = function()
		RespawnGroup('Khormato-Artillery')
		RegisterGroupTarget('Khormato-Artillery',250,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'Artillery2')
		timer.scheduleFunction(function(param, time)
			if Group.getByName('Khormato-Artillery') then
				local tgts = {'Kirkuk City', 'Sulaimaniyah Airport'}
				
				local validtgts = {}
				for _,v in ipairs(tgts) do
					if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
						table.insert(validtgts, v)
					end
				end
				
				if #validtgts == 0 then return time+(10*60) end
				
				local die = math.random(1,#validtgts)
				local choice = validtgts[die]
				bc:fireAtZone(choice, 'Khormato-Artillery', true, 48)
				trigger.action.outTextForCoalition(2, L10N:Format("IRAQ_EVENT_ARTILLERY_LAUNCHING", "Khormato", choice), 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
		if ActiveMission['Artillery2'] then return false end
		if math.random(1,100) < 70 then return false end
		local gr = Group.getByName('Khormato-Artillery')
		if gr then return false end
		if bc:getZoneByName('Khormato').side ~= 1 or bc:getZoneByName('Khormato').suspended then return false end
		local triggers = {'Kirkuk City', 'Sulaimaniyah Airport'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		return false
	end
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
	description = function(T) return LT(T):Format("IRAQ_MISSION_ARTY_FROM_DESC", "Khormato") end,
	messageStart = L10N:Format("IRAQ_MISSION_ARTY_CONVOY_START", "Khormato"),
	messageEnd = L10N:Get("SYRIA_MISSION_ARTY_END"),
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
		if not ActiveMission['Artillery2'] then return false end
		if Group.getByName('Khormato-Artillery') then return true end
		ActiveMission['Artillery2'] = nil
		return false
	end
})


Group.getByName('Balad-attack-Al-Sahra Airport-event'):destroy()
Group.getByName('Balad-attack-Khormato-event'):destroy()
Group.getByName('Balad-attack-Sarqala-event'):destroy()
Group.getByName('Balad-attack-Maydan-event'):destroy()

evc:addEvent({
    id = 'helohunt',
    action = function()
        local groupsAndTargets = {
            {group = 'Balad-attack-Al-Sahra Airport-event', target = 'Al-Sahra Airport'},
            {group = 'Balad-attack-Khormato-event', target = 'Khormato'},
            {group = 'Balad-attack-Sarqala-event', target = 'Sarqala'},
            {group = 'Balad-attack-Maydan-event', target = 'Maydan'}}

        for _, entry in ipairs(groupsAndTargets) do
			RespawnGroup(entry.group)
			RegisterGroupTarget(entry.group,250,L10N:Get("IRAQ_MISSION_HELO_HUNT_TITLE"),'helohunt')
        end
    end,
    canExecute = function()
		if ActiveMission['helohunt'] then return false end
        if math.random(1, 100) < 70 then return false end
        if bc:getZoneByName('Balad Airbase').side ~= 1 or bc:getZoneByName('Balad Airbase').suspended then return false end
        local triggers = {'Al-Sahra Airport', 'Khormato', 'Sarqala', 'Maydan'}
        for _, v in ipairs(triggers) do
            if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
                return true
            end
        end
        return false
    end
})
mc:trackMission({
    title = LTGet("IRAQ_MISSION_HELO_HUNT_TITLE"),
    description = LTGet("IRAQ_MISSION_HELO_HUNT_DESC"),
    messageStart = L10N:Get("IRAQ_MISSION_HELO_HUNT_START"),
    messageEnd = L10N:Get("IRAQ_MISSION_HELO_HUNT_END"),
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
		if not ActiveMission['helohunt'] then return false end
        local groups = {'Balad-attack-Al-Sahra Airport-event',
            'Balad-attack-Khormato-event','Balad-attack-Sarqala-event',
            'Balad-attack-Maydan-event'}
        for _, groupName in ipairs(groups) do
            if Group.getByName(groupName) then
                return true
            end
        end
		ActiveMission['helohunt'] = nil
        return false
    end
})


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
		local wp = WaypointList[resupplyTarget2] or ""
		return LT(T):Format("SYRIA_DYNAMIC_RESUPPLY_TITLE", resupplyTarget2, wp)
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
		local wp = WaypointList[attackTarget1] or ""
		return LT(T):Format("SYRIA_DYNAMIC_ATTACK_TITLE", attackTarget1, wp)
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
		local wp = WaypointList[attackTarget2] or ""
		return LT(T):Format("SYRIA_DYNAMIC_ATTACK_TITLE", attackTarget2, wp)
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
	messageStart = function(T)
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return LT(T):Get("SYRIA_DYNAMIC_RECON_START_EMPTY") end
		local wp = WaypointList[target] or ""
		return LT(T):Format("SYRIA_DYNAMIC_RECON_START", target, wp)
	end,
	messageEnd = function(T)
		if reconMissionCompleted and reconMissionCompletedTarget and reconMissionWinner then
			return LT(T):Format("SYRIA_DYNAMIC_RECON_END_BY", reconMissionCompletedTarget, reconMissionWinner)
		end
		if reconMissionCompletedTarget then
			return LT(T):Format("SYRIA_DYNAMIC_RECON_END_TARGET", reconMissionCompletedTarget)
		end
		return LT(T):Get("SYRIA_DYNAMIC_RECON_END")
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


airbaseStatics = {
    ["Duhok City"] = {"DuhikTruck", "DuhikTruck2", "DuhikTruck3", "Duhikstatic1", "Duhikstatic2", "Duhikstatic3", "Duhikstatic4", "Duhikstatic5", 
	"Duhikstatic6", "Duhikstatic7", "Duhikstatic8", "Duhikstatic9", "Duhikstatic10", "Duhikstatic11", "Duhikstatic12", "Duhikstatic13", "Duhikstatic14", "DuhukAmmo", 
    "DuhukFuel", "DuhikJeep", "DuhukWind"},
	["Chamanki"] = {"ChamankiAmmo", "ChamankiFuel", "ChamankiTent1", "ChamankiTent2", "ChamankiTent3", "ChamankiTent4", "ChamankiTent5", "ChamankiTent6", 
	"ChamankiTent7", "ChamankiTent8", "ChamankiTent9", "ChamankiWind"},
	["OutPost"] = {"OutPostAmmo", "OutPostfuel", "OutPosttent1", "OutPosttent2", "OutPostWind"},
	["FOB Samarra"] = {"FOBSamaraammo", "FOBSamarafuel", "FOBSamaratent1", "FOBSamaratent2", "FOBSamaratent3", "FOBSamaratent4", "FOBSamaratent5", "FOBSamaratent6", "FOBSamaratent7", 
	"FOBSamaratent8", "FOBSamaratent9", "FOBSamaraTower1", "FOBSamaraTower2", "FOBSamaraTower3", "FOBSamaraTower4", "FOBSamaraHelo1", "FOBSamaraHelo2", "FOBSamaraHelo3", "FOBSamaraHelo4", 
	"FOBSamaraWind", "FOBSamaraGenerator"},
	["FOB Therethar"] = {"FOBTheretharammo", "FOBTheretharfuel", "FOBTherethartent1", "FOBTherethartent2", "FOBTherethartent3", "FOBTherethartent4", "FOBTherethartent5", "FOBTherethartent6", "FOBTherethartent7", 
	"FOBTherethartent8", "FOBTherethartent9", "FOBTheretharTower1", "FOBTheretharTower2", "FOBTheretharTower3", "FOBTheretharTower4", "FOBTheretharHelo1", "FOBTheretharHelo2", "FOBTheretharHelo3", "FOBTheretharHelo4", 
	"FOBTheretharWind", "FOBTheretharGenerator"},
	["Said Sadiq"] = {"SaidSadiqammo", "SaidSadiqFuel", "SaidSadiqtent1", "SaidSadiqtent2", "SaidSadiqtent3", "SaidSadiqtent4", "SaidSadiqcommand", "SaidSadiqwind"},
	["Maydan"] = {"Maydanammo", "MaydanFuel", "Maydantent1", "Maydantent2", "Maydantent3", "Maydantent4", "Maydancommand", "Maydanwind"},
	["Sarqala"] = {"Sarqalaammo", "SarqalaFuel", "Sarqalatent1", "Sarqalatent2", "Sarqalatent3", "Sarqalatent4", "Sarqalacommand", "Sarqalawind"},
	["Khormato"] = {"Khormatoammo", "KhormatoFuel", "Khormatotent1", "Khormatotent2", "Khormatotent3", "Khormatotent4", "Khormatocommand", "Khormatowind"},
	["Al Abbasi"] = {"Abbasiammo", "AbbasiFuel", "Abbasitent1", "Abbasient2", "Abbasiwind"},
	["Tal Afar"] = {"Talafarammo", "TalafarFuel", "Talafartent1", "Talafartent2", "Talafartent3", "Talafartent4", "Talafarcommand", "Talafarwind"},
    ["Ramadi"] = {"Ramadiammo", "Ramadifuel", "Ramaditent1", "Ramaditent2", "Ramaditent3", "Ramaditent4", "Ramaditent5", "Ramaditent6", "Ramaditent7", 
	"Ramaditent8", "Ramaditent9", "RamadiTower1", "RamadiTower2", "RamadiTower3", "RamadiTower4", "RamadiHelo1", "RamadiHelo2", "RamadiHelo3", "RamadiHelo4", 
	"RamadiWind", "RamadiGenerator"},
    ["Koya"] = {"KoyaTruck", "KoyaTruck2", "KoyaTruck3", "Koyatent", "Koyatent2", "Koyatent3", "Koyasandbag1", "Koyasandbag2", "Koyasandbag3", 
	"Koyasandbag4", "Koyasandbag5", "Koyasandbag6", "Koyasandbag7", "Koyasandbag8", "Koyasandbag9", "Koyasandbag10", "Koyasandbag11", "KoyaAmmo", "Koyafuel", 
	"KoyaJeep", "KoyaWind"},
    ["Dukan"] = {"Dukantent", "Dukantent2", "DukanFuel", "DukanAmmo", "DukanWind"},
}

env.info("Mission Setup : is completed!")
