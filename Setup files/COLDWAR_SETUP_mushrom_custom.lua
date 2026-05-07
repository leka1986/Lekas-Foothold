env.info("Mission Setup : is loading.")

if Era =='Coldwar' then
    env.info("Mission Setup : Cold War Era selected.")
else
    env.info("Mission Setup : Modern Era selected.")
end

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
    Bitburg = ' (1)',
    Spangdahlem = ' (2)',
    Hahn = ' (3)',
    Mendig = ' (4)',
    ['Mendig North FARP'] = ' (5)',
    ['Mendig East FARP'] = ' (6)',
    ['Baumholder FARP'] = ' (7)',
    Ramstein = ' (8)',
    ['Bad Durkheim'] = ' (9)',
    ['Walldorf FARP'] = ' (10)',
    ['Walldurn FARP'] = ' (11)',
    ['Giebelstadt'] = ' (12)',
    ['Airracing Frankfurt'] = ' (13)',
    Frankfurt = ' (14)',
    Fritzlar = ' (15)',
    Gelnhausen = ' (16)',
    ['Laubach FARP'] = ' (17)',
    Fulda = ' (18)',
    ['Salzungen FARP'] = ' (19)',
    Bindersleben = ' (20)',
    ['Naumburg FARP'] = ' (21)',
    Schkeuditz = ' (22)',
    Zerbst = ' (23)',
    Mahlwinkel = ' (24)',
    Braunschweig = ' (25)',
    Hannover = ' (26)',
    Fassberg = ' (27)',
    Scheessel = ' (28)',
    Bremen = ' (29)',
    Hamburg = ' (30)',
    Lubeck = ' (31)',
    Briest = ' (32)',
    ['Altes Lager'] = ' (33)',
    ['Wundsdorf FARP'] = ' (34)',
    Tegel = ' (35)',
    Werneuchen = ' (36)',
    Neuruppin = ' (37)',
    Templin = ' (38)',
    Larz = ' (39)',
    Parchim = ' (40)',
    Neubrandenburg = ' (41)',
    Tutow = ' (42)',
    Laage = ' (43)',
    Wismar = ' (44)',
    Garz = ' (45)',
    Peenemunde = ' (46)',
    Bornholm = ' (47)',
    Sturup = ' (48)',
    ['Kastrup City'] = ' (49)',
}

flavor = {

    bitburg = L10N:Format("COLDWAR_FLAVOR_WPT", 1),
    spangdahlem = L10N:Format("COLDWAR_FLAVOR_WPT", 2),
    hahn = L10N:Format("COLDWAR_FLAVOR_WPT", 3),
    mendig = L10N:Format("COLDWAR_FLAVOR_WPT", 4),
    mendignorth = L10N:Format("COLDWAR_FLAVOR_WPT", 5),
    mendigeast = L10N:Format("COLDWAR_FLAVOR_WPT", 6),
    baumholderfarp = L10N:Format("COLDWAR_FLAVOR_WPT", 7),
    ramstein = L10N:Format("COLDWAR_FLAVOR_WPT", 8),
    baddurkheim = L10N:Format("COLDWAR_FLAVOR_WPT", 9),
    walldorffarp = L10N:Format("COLDWAR_FLAVOR_WPT", 10),
    walldurnfarp = L10N:Format("COLDWAR_FLAVOR_WPT", 11),
    giebelstadt = L10N:Format("COLDWAR_FLAVOR_WPT", 12),
    airrcing = L10N:Format("COLDWAR_FLAVOR_WPT", 13),
    frankfurt = L10N:Format("COLDWAR_FLAVOR_WPT", 14),
    fritzlar = L10N:Format("COLDWAR_FLAVOR_WPT", 15),
    gelnhausen = L10N:Format("COLDWAR_FLAVOR_WPT", 16),
    laubachfarp = L10N:Format("COLDWAR_FLAVOR_WPT", 17),
    fulda = L10N:Format("COLDWAR_FLAVOR_WPT", 18),
    salzungenfarp = L10N:Format("COLDWAR_FLAVOR_WPT", 19),
    bindersleben = L10N:Format("COLDWAR_FLAVOR_WPT", 20),
    naumburgfarp = L10N:Format("COLDWAR_FLAVOR_WPT", 21),
    schkeuditz = L10N:Format("COLDWAR_FLAVOR_WPT", 22),
    zerbst = L10N:Format("COLDWAR_FLAVOR_WPT", 23),
    mahlwinkel = L10N:Format("COLDWAR_FLAVOR_WPT", 24),
    braunschweig = L10N:Format("COLDWAR_FLAVOR_WPT", 25),
    hannover = L10N:Format("COLDWAR_FLAVOR_WPT", 26),
    fassberg = L10N:Format("COLDWAR_FLAVOR_WPT", 27),
    scheessel = L10N:Format("COLDWAR_FLAVOR_WPT", 28),
    bremen = L10N:Format("COLDWAR_FLAVOR_WPT", 29),
    hamburg = L10N:Format("COLDWAR_FLAVOR_WPT", 30),
    lubeck = L10N:Format("COLDWAR_FLAVOR_WPT", 31),
    briest = L10N:Format("COLDWAR_FLAVOR_WPT", 32),
    alteslager = L10N:Format("COLDWAR_FLAVOR_WPT", 33),
    wundsdorffarp = L10N:Format("COLDWAR_FLAVOR_WPT", 34),
    tegel = L10N:Format("COLDWAR_FLAVOR_WPT", 35),
    werneuchen = L10N:Format("COLDWAR_FLAVOR_WPT", 36),
    neuruppin = L10N:Format("COLDWAR_FLAVOR_WPT", 37),
    templin = L10N:Format("COLDWAR_FLAVOR_WPT", 38),
    larz = L10N:Format("COLDWAR_FLAVOR_WPT", 39),
    parchim = L10N:Format("COLDWAR_FLAVOR_WPT", 40),
    neubrandenburg = L10N:Format("COLDWAR_FLAVOR_WPT", 41),
    tutow = L10N:Format("COLDWAR_FLAVOR_WPT", 42),
    laage = L10N:Format("COLDWAR_FLAVOR_WPT", 43),
    garz = L10N:Format("COLDWAR_FLAVOR_WPT", 44),
    peenemunde = L10N:Format("COLDWAR_FLAVOR_WPT", 45),
    sheizefactory = L10N:Get("COLDWAR_FLAVOR_SCHEISSE_FACTORY"),
    chemicalfactory = L10N:Get("COLDWAR_FLAVOR_CHEMICAL_FACTORY"),

}

FootholdSaveBaseName = (Era == 'Coldwar') and 'FootHold_Germany_ColdWar_V0.1' or 'FootHold_Germany_Modern_V0.1'

local filepath = FootholdSaveBaseName .. '.lua'
if lfs then
  FootholdSavePath = FootholdSavePath or (lfs.writedir()..'Missions/Saves')
  lfs.mkdir(FootholdSavePath)
  filepath = FootholdSavePath .. '/' .. (FootholdSaveBaseName .. '.lua')
  env.info('Foothold - Save file path: '..filepath)
end

upgrades = {
	airfieldStart = {
		blue = {'blueArmor', 'bluePD1'},
		red = {}
	},

	airfield1 = {
		blue = {'bluePD2', 'blueArmor', 'bluePD1'},
		red = {'Enemy Task forces', 'Red Armour Group', 'Red Armour Group 3', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8','Red SAM SHORAD SA-8', 'Red SAM SA-3'}
	},
	airfield2 = {
		blue = {'blueInfantry', 'blueArmor','bluePD1','blueArmor'},
		red = {'Enemy ground forces','Red SAM AAA 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD Tor M2', 'Red Arty', 'Red SAM SHORAD SA-19'}
	},
	airfield3 = {
		blue = {'bluePD2', 'blueArmor', 'bluePD1'},
		red = {'Enemy Task forces', 'Red Armour Group 2','Red Armour Group 3', 'Red SAM AAA 2', 'Red SAM SHORAD Pantsir S1', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD SA-15','Red Arty'}
	},
	airfield4 = {
		blue = {'blueInfantry','bluePD1','blueArmor'},
		red = {'Enemy Task forces', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD SA-15', 'Red SAM AAA 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD Pantsir S1'}
	},
    Scheize = {
		blue = {'blueInfantry','blueArmor','blueHAWK'},
		red = {'Enemy Task forces', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Tor M2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-8', 'Red SAM AAA 3','Red SAM AAA 4','Scheize Factory building 1','Scheize Factory building 2'}
	},
	airfield6 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1',},
		red = {'Enemy Task forces', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD Pantsir S1', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Tor M2', 'Red SAM SA-10'}
	},--airfieldKastrup
	airfieldKastrup = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1',},
		red = {'Enemy Task forces', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD Pantsir S1', 'Red SAM SHORAD Tor M2', 'Grisha Kastrup Fixed', 'Red SAM SA-6'}
	},
	airfield6Cold = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy Task forces', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15', 'Red SAM SA-2'}
	},
	farp = {
		blue = {'bluePD2', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red Armour Group', 'Red Armour Group 2','Red SAM SHORAD SA-8', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8','Red Arty'}
	},
	farp1 = {
		blue = {'blueInfantry', 'blueArmor', 'blueHAWK'},
		red = {'Red SAM AAA 2', 'Red Armour Group','Red Arty','Red SAM SHORAD SA-15', 'Red SAM SHORAD Pantsir S1', 'Red SAM AAA 4','Red SAM AAA 3'}
	},
	farp2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red Arty','Red SAM AAA 4','Red SAM AAA 3'}
	},
	SamAlpha = {
		blue = {},
		red = {'Red SAM SA-3 Fixed SamAlpha'}
	},
	SamBravo = {
		blue = {},
		red = {'Red SAM SA-3 Fixed-SamBravo'}
	},
	samCharlie = {
		blue = {},
		red = {'Red SAM SA-2 Fixed SamCharlie','Red SAM SHORAD SA-13 Fixed SAMCharlie', 'Red SAM SHORAD SA-13 Fixed SAMCharlie 2'}
	},
	samDelta = {
		blue = {},
		red = {'Red SAM SA-11 Fixed SamDelta','Red SAM Dog Ear SA-15 Fixed SamDelta', 'Red SAM SHORAD SA-15 Fixed SamDelta 2'}
	},
	samEcho = {
		blue = {},
		red = {'Red SAM SA-2 Fixed SamEcho','Red SAM SHORAD SA-19 Fixed SamEcho', 'Red SAM SHORAD SA-15 Fixed SamEcho'}
	},
	samFoxtrot = {
		blue = {},
		red = {'Red SAM SA-2 Fixed SamFoxtrot','Red SAM SHORAD SA-15 Fixed SamFoxtrot 2', 'Red SAM SHORAD SA-15 Fixed SamFoxtrot'}
	},
	samGolf = {
		blue = {},
		red = {'Red SAM SA-2 Fixed SamGolf','Red SAM SHORAD SA-15 Fixed SamGolf 2', 'Red SAM SHORAD SA-15 Fixed SamGolf'}
	},
	samHotel = {
		blue = {},
		red = {'Red SAM SA-11 Fixed SamHotel','Red SAM SHORAD SA-15 Fixed SamHotel 2', 'Red SAM SHORAD SA-15 Fixed SamHotel'}
	},
	samIndia = {
		blue = {},
		red = {'Red SAM SA-2 Fixed SamIndia','SamIndia AAA Group 1 Fixed','Red SAM SHORAD SA-8 Fixed SamIndia','Red SAM SHORAD SA-15 Fixed SamIndia'}
	},
	samJuliett = {
		blue = {},
		red = {'Red SAM SA-2 Fixed SamJuliett','Red SAM SHORAD SA-15 Fixed SamJuliett','Red SAM SHORAD SA-8 Fixed SamJuliett','SamJuliett AAA Group 1 Fixed'}
	},
	samKilo = {
		blue = {},
		red = {'Red SAM SA-11 Fixed SamKilo','Red SAM SHORAD SA-15 Fixed SamKilo','Red SAM SHORAD SA-15 Fixed SamKilo 2'}
	},
	samLima = {
		blue = {},
		red = {'Red SAM SA-10 Fixed SamLima','Red SAM Dog Ear SA-15 Fixed SamLima','Red SAM Dog Ear SA-15 Fixed SamLima 2', 'Red SAM AAA Fixed SamLima 2', 'Red SAM AAA Fixed SamLima'}
	},
	samMike = {
		blue = {},
		red = {'Red SAM SA-11 Fixed SamMike','Red SAM SHORAD SA-15 Fixed SamMike', 'Red SAM SHORAD SA-15 Fixed SamMike 2'}
	},
	Wismar = {
		blue = {'blueInfantry', 'blueArmor','bluePD1','blueArmor'},
		red = {'Grisha Fixed-1','Enemy ground forces','Red SAM AAA 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD Tor M2', 'Red Arty', 'Red SAM SHORAD SA-19'}
	},
	EWRMantisNet = {
		blue = {},
		red = {'Red EWR Fixed 1', 'Red EWR Fixed 2', 'Red EWR Fixed 3', 'Red EWR Fixed 4', 'Red EWR Fixed 5','Red EWR Fixed 6'}
	},
	hidden2 = {
		blue = {},
		red = {'Grisha Fixed'}
	},
	ship = {
		blue = {'Perry'},
		red = {'Grisha', 'Molniya', 'Rezky', 'Rezky','Molniya', 'Molniya', 'Molniya','Grisha','Grisha','Grisha'}
	},
	hiddensweden = {
		blue = {},
		red = {'Red SAM SA-11 South Sweden Fixed','Red SAM SA-11 South East Sweden Fixed','Red SAM SHORAD SA-15 Fixed South sweden-2','Red SAM SHORAD SA-15 Fixed South sweden'}
	},
    --hiddensweden
    Chemical = {
		blue = {},
		red = {'Chemical building', 'Chemical building 2', 'Chemical building 3','Red SAM SHORAD SA-15', 'Chemical Factory building','Chemical Guairds infantry Fixed','Red SAM SHORAD SA-15', 'Chemical Factory building 2','Red SAM AAA Chemical Fixed',
    		'Chemical Factoy tank', 'Chemical Factoy tank 2', 'Chemical Factoy tank 3', 'Chemical Factoy tank 4','Red SAM AAA CHemical Fixed Mixed','Red Armour Group 2','Red SAM SA-6','Red SAM SA-3'}
	},
	hiddenground1 = {
		blue = {},
		red = {'hiddenground1-Fixed-1', 'hiddenground1-Fixed-2', 'hiddenground1-Fixed-3','hiddenground1-Fixed-4','hiddenground1-Fixed-5',
                'hiddenground1-Fixed-7','hiddenground1-Fixed-8','hiddenground1-Fixed-9', 'hiddenground1-Fixed-10','hiddenground1-Fixed-11','hiddenground1-Fixed-12',
                'hiddenground1-Fixed-13','hiddenground1-Fixed-14','hiddenground1-Fixed-15','hiddenground1-Fixed-16','hiddenground1-Fixed-17'}
	},
	hiddenground2 = {
		blue = {},
		red = {'hiddenground2-Fixed-1', 'hiddenground2-Fixed-2', 'hiddenground2-Fixed-3','hiddenground2-Fixed-4','hiddenground2-Fixed-5','hiddenground2-Fixed-6',
                'hiddenground2-Fixed-7','hiddenground2-Fixed-8','hiddenground2-Fixed-9','hiddenground2-Fixed-10','hiddenground2-Fixed-11'}
	},
	hiddenground6 = {
		blue = {},
		red = {'hiddenground6-Fixed-1', 'hiddenground6-Fixed-2', 'hiddenground6-Fixed-3', 'hiddenground6-Fixed-4' ,'hiddenground6-Fixed-5'}
	},	
	hiddenground7 = {
		blue = {},
		red = {'hiddenground7-Fixed-1', 'hiddenground7-Fixed-2', 'hiddenground7-Fixed-3'}
	},
	hiddenground8 = {
		blue = {},
		red = {'hiddenground8-Fixed-1', 'hiddenground8-Fixed-2', 'hiddenground8-Fixed-3','hiddenground8-Fixed-4','hiddenground8-Fixed-5', 'hiddenground8-Fixed-6', 'hiddenground8-Fixed-7'}
	},
	hiddenground9 = {
		blue = {},
		red = {'hiddenground9-Fixed-1', 'hiddenground9-Fixed-2', 'hiddenground9-Fixed-3', 'hiddenground9-Fixed-4'}
	},
	hiddenground10 = {
		blue = {},
		red = {'hiddenground10-Fixed-1', 'hiddenground10-Fixed-2', 'hiddenground10-Fixed-3', 'hiddenground10-Fixed-4'}
	},
	hiddenground11 = {
		blue = {},
		red = {'hiddenground11-Fixed-1', 'hiddenground11-Fixed-2', 'hiddenground11-Fixed-3', 'hiddenground11-Fixed-4'}
	},
	hiddenground12 = {
		blue = {},
		red = {'hiddenground12-Fixed-1', 'hiddenground12-Fixed-2', 'hiddenground12-Fixed-3'}
	},
	hiddenground13 = {
		blue = {},
		red = {'hiddenground13-Fixed-1', 'hiddenground13-Fixed-2', 'hiddenground13-Fixed-3'}
	},
	hiddenground14 = {
		blue = {},
		red = {'hiddenground14-Fixed-1', 'hiddenground14-Fixed-2', 'hiddenground14-Fixed-3', 'hiddenground14-Fixed-4', 'hiddenground14-Fixed-5', 'hiddenground14-Fixed-6','hiddenground14-Fixed-7'}
	},	
	hiddenground15 = {
		blue = {},
		red = {'hiddenground15-Fixed-1', 'hiddenground15-Fixed-2', 'hiddenground15-Fixed-3', 'hiddenground15-Fixed-4', 'hiddenground15-Fixed-5', 'hiddenground15-Fixed-6'}
	},	
	hiddenground3 = {
		blue = {},
		red = {'hiddenground3-Fixed-1', 'hiddenground3-Fixed-2', 'hiddenground3-Fixed-3','hiddenground3-Fixed-4','hiddenground3-Fixed-5','hiddenground3-Fixed-6',
		           'hiddenground3-Fixed-7','hiddenground3-Fixed-8','hiddenground3-Fixed-9','hiddenground3-Fixed-10','hiddenground3-Fixed-11'}
	},
	hiddenground4 = {
		blue = {},
		red = {'hiddenground4-Fixed-1', 'hiddenground4-Fixed-2', 'hiddenground4-Fixed-3','hiddenground4-Fixed-4','hiddenground4-Fixed-5','hiddenground4-Fixed-6',
                'hiddenground4-Fixed-7','hiddenground4-Fixed-8','hiddenground4-Fixed-9','hiddenground4-Fixed-10','hiddenground4-Fixed-11','hiddenground4-Fixed-12',
                'hiddenground4-Fixed-13','hiddenground4-Fixed-14','hiddenground4-Fixed-15','hiddenground4-Fixed-16','hiddenground4-Fixed-17'}
	},
	hiddenground5 = {
		blue = {},
		red = {'hiddenground5-Fixed-1', 'hiddenground5-Fixed-2', 'hiddenground5-Fixed-3','hiddenground5-Fixed-4','hiddenground5-Fixed-5','hiddenground5-Fixed-6',
			'hiddenground5-Fixed-7','hiddenground5-Fixed-8','hiddenground5-Fixed-9','hiddenground5-Fixed-10','hiddenground5-Fixed-11','hiddenground5-Fixed-12',
			'hiddenground5-Fixed-13','hiddenground5-Fixed-14','hiddenground5-Fixed-15','hiddenground5-Fixed-16','hiddenground5-Fixed-17','hiddenground5-Fixed-18',
			'hiddenground5-Fixed-19','hiddenground5-Fixed-20','hiddenground5-Fixed-21','hiddenground5-Fixed-22','hiddenground5-Fixed-23','hiddenground5-Fixed-24',
			'hiddenground5-Fixed-25','hiddenground5-Fixed-26','hiddenground5-Fixed-27','hiddenground5-Fixed-28','hiddenground5-Fixed-29','hiddenground5-Fixed-30',
			'hiddenground5-Fixed-31','hiddenground5-Fixed-32'}
	},
}

local cwSwap = {
	['Red Armour Group 3']   = 'Red Armor Group6',
	['Red Armour Group 2']   = 'Red Armor Group7',
	['Red Armour Group']  = 'Red Armor Group8',
	['bluePD1']  = 'blueHAWK Coldwar',
	['blueHAWK']  = 'blueHAWK Coldwar',
	['blueArmor']  = 'blueArmor_cw',
	['Red SAM SHORAD Pantsir S1']  = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
	['Red SAM SHORAD Tor M2']  = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },

    
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
	upgrades.airfield6 = upgrades.airfield6Cold
	deepSwap(upgrades,cwSwap)
end

local SamSwap = {
	['Red SAM SA-10']   = { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },
	['Red SAM SA-11']   = { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },
	['Red SAM SA-11 Fixed SamKilo']   = 'Red SAM SA-2 Fixed SamKilo',
	['Red SAM SA-11 Fixed SamHotel']   = 'Red SAM SA-2 Fixed SamHotel',
	['Red SAM SA-11 Fixed SamDelta']  = 'Red SAM SA-2 Fixed SamDelta',
	['Red SAM SA-11 Fixed SamMike']  = 'Red SAM SA-2 Fixed SamMike',
	['Red SAM SA-10 Fixed SamLima']  = 'Red SAM SA-2 Fixed SamLima',
	['Red SAM SA-11 South Sweden Fixed']  = 'Red SAM SA-2 South Sweden Fixed',
	['Red SAM SA-11 South East Sweden Fixed']  = 'Red SAM SA-2 South East Sweden Fixed',
}

local SamSwapNoTorM2AndPantsir = {
	['Red SAM SHORAD Pantsir S1']  = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
	['Red SAM SHORAD Tor M2']  = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
}

local SamSwapNoSA15 = {
	--['Red SAM SHORAD SA-8']  = {'Red SAM AAA 4','Red SAM AAA 3'},
	['Red SAM SHORAD SA-15']  = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
	['Red SAM Dog Ear SA-15 Fixed SamDelta']  = 'Red SAM SHORAD SA-19 Fixed SamDelta',
	['Red SAM SHORAD SA-15 Fixed SamDelta 2']  = 'Red SAM SHORAD SA-8 Fixed SamDelta 2',
	['Red SAM Dog Ear SA-15 Fixed SamMike']  = 'Red SAM SHORAD SA-19 Fixed SamMike',
	['Red SAM SHORAD SA-15 Fixed SamMike 2']  = 'Red SAM SHORAD SA-8 Fixed SamMike',
	['Red SAM SHORAD SA-15 Fixed SamEcho']  = 'Red SAM SHORAD SA-8 Fixed SamEcho',
	['Red SAM SHORAD SA-15 Fixed SamIndia']  = 'Red SAM SHORAD SA-13 Fixed SamIndia',
	['Red SAM SHORAD SA-15 Fixed SamJuliett']  = 'Red SAM SHORAD SA-8 Fixed SamJuliett 2',
	['Red SAM SHORAD SA-15 Fixed SamGolf']  = 'Red SAM SHORAD SA-8 Fixed SamGolf',
	['Red SAM SHORAD SA-15 Fixed SamGolf 2']  = 'Red SAM SHORAD SA-19 Fixed SamGolf 2',
	['Red SAM SHORAD SA-15 Fixed SamFoxtrot 2']  = 'Red SAM SHORAD SA-8 Fixed SamFoxtrot 2',
	['Red SAM SHORAD SA-15 Fixed SamFoxtrot']  = 'Red SAM SHORAD SA-8 Fixed SamFoxtrot',
	['Red SAM SHORAD SA-15 Fixed SamHotel']  = 'Red SAM SHORAD SA-8 Fixed SamHotel',
	['Red SAM SHORAD SA-15 Fixed SamHotel 2']  = 'Red SAM SHORAD SA-9 Fixed SamHotel 2',
	['Red SAM Dog Ear SA-15 Fixed SamLima']  = 'Red SAM SHORAD SA-8 Fixed SamLima',
	['Red SAM Dog Ear SA-15 Fixed SamLima 2']  = 'Red SAM SHORAD SA-8 Fixed SamLima 2',
	['Red SAM SHORAD SA-15 Fixed SamKilo']  = 'Red SAM SHORAD SA-8 Fixed SamKilo',
	['Red SAM SHORAD SA-15 Fixed SamKilo 2']  = 'Red SAM SHORAD SA-8 Fixed SamKilo 2',
	['Red SAM SHORAD SA-15 Fixed South East sweden']  = 'Red SAM SHORAD SA-8 Fixed South East sweden',
	['Red SAM SHORAD SA-15 Fixed South East sweden 2']  = 'Red SAM SHORAD SA-8 Fixed South East sweden 2',
	['Red SAM SHORAD SA-15 Fixed South sweden-2']  = 'Red SAM SHORAD SA-8 Fixed South sweden 2',
	['Red SAM SHORAD SA-15 Fixed South sweden']  = 'Red SAM SHORAD SA-8 Fixed South sweden',
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
	redarmycamp = { "sa-10", "sa-11","sa-2","pantsir","tor m2", "sa-15" ,"red sam aaa 3","red sam aaa 4"},
	medium = { "sa-10", "sa-11","pantsir"},
}

RandomUpgradeTemplates = {
	small = { sam = 0, shorad = {1,2}, aaa = 2, ground = 1, armor = 1, arty = {0,1}, total = {5,7} },
	redarmycamp = { sam = 0, shorad = 0, aaa = 0, ground = {3,5}, armor = 0, arty = {0,5}, total = {6,8} },
	medium = { sam = {0,1}, shorad = {1,2}, aaa = {1,2}, ground = 1, armor = 2, arty = 1, total = {6,9} },
	big = { sam = 1, shorad = {2,3}, aaa = {1,2}, ground = 1, armor = 2, arty = 1, total = {7,10} },
	extrabig = { sam = 2, shorad = {3,4}, aaa = 2, ground = 1, armor = {1,2}, arty = 1, total = {9,12} },
	sam = { sam = 1, shorad = {1,2}, aaa = {1,2}, ground = 0, armor = 0, arty = 0, total = {5,5} },
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

bc = BattleCommander:new(filepath, 10, 60)
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
env.info('Foothold - Rank file path: '..bc.rankFile)
end
Hunt = true

zones = {
	
    bitburg         = ZoneCommander:new({zone='Bitburg',            size='big',         side=2, level=25, upgrades=upgrades.airfieldStart,   crates={},flavorText=flavor.bitburg}),
    spangdahlem     = ZoneCommander:new({zone='Spangdahlem',        size='big',         side=2, level=25, upgrades=upgrades.airfieldStart,   crates={},flavorText=flavor.spangdahlem}),
    hahn            = ZoneCommander:new({zone='Hahn',               size='big',         side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.hahn, noLongRangeSam=true}),
    airrcing        = ZoneCommander:new({zone='Airracing Frankfurt',size='small',       side=1, level=25, upgrades=upgrades.farp,            crates={},flavorText=flavor.airrcing}),
    mendig          = ZoneCommander:new({zone='Mendig',             size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.mendig}),
    mendignorth     = ZoneCommander:new({zone='Mendig North FARP',  size='small',       side=1, level=25, upgrades=upgrades.farp,            crates={},flavorText=flavor.mendignorth}),
    mendigeast      = ZoneCommander:new({zone='Mendig East FARP',   size='small',       side=1, level=25, upgrades=upgrades.farp,            crates={},flavorText=flavor.mendigeast}),
    baumholderfarp  = ZoneCommander:new({zone='Baumholder FARP',    size='small',       side=1, level=25, upgrades=upgrades.farp,            crates={},flavorText=flavor.baumholderfarp}),
    ramstein        = ZoneCommander:new({zone='Ramstein',           size='big',         side=1, level=25, upgrades=upgrades.airfield1,       crates={},flavorText=flavor.ramstein}),
    baddurkheim     = ZoneCommander:new({zone='Bad Durkheim',       size='medium',      side=1, level=25, upgrades=upgrades.airfield1,       crates={},flavorText=flavor.baddurkheim}),
    walldorffarp    = ZoneCommander:new({zone='Walldorf FARP',      size='small',       side=1, level=25, upgrades=upgrades.farp,            crates={},flavorText=flavor.walldorffarp}),
    walldurnfarp    = ZoneCommander:new({zone='Walldurn FARP',      size='small',       side=1, level=25, upgrades=upgrades.farp2,           crates={},flavorText=flavor.walldurnfarp}),
	giebelstadt     = ZoneCommander:new({zone='Giebelstadt',        size='medium',      side=1, level=25, upgrades=upgrades.airfield1,       crates={},flavorText=flavor.giebelstadt}),
    frankfurt       = ZoneCommander:new({zone='Frankfurt',          size='extrabig',    side=1, level=25, upgrades=upgrades.airfield1,       crates={},flavorText=flavor.frankfurt}),                                          
    gelnhausen      = ZoneCommander:new({zone='Gelnhausen',         size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.gelnhausen}),
    laubachfarp     = ZoneCommander:new({zone='Laubach FARP',       size='small',       side=1, level=25, upgrades=upgrades.airfield4,       crates={},flavorText=flavor.laubachfarp}), --Gütersloh
    fulda           = ZoneCommander:new({zone='Fulda',              size='medium',      side=1, level=25, upgrades=upgrades.farp2,           crates={},flavorText=flavor.fulda}),
    fritzlar        = ZoneCommander:new({zone='Fritzlar',           size='medium',      side=1, level=25, upgrades=upgrades.farp2,           crates={},flavorText=flavor.fritzlar}),
    salzungenfarp   = ZoneCommander:new({zone='Salzungen FARP',     size='small',       side=1, level=25, upgrades=upgrades.farp2,           crates={},flavorText=flavor.salzungenfarp}),
    bindersleben    = ZoneCommander:new({zone='Bindersleben',       size='big',         side=1, level=25, upgrades=upgrades.airfield1,       crates={},flavorText=flavor.bindersleben}), 
    naumburgfarp    = ZoneCommander:new({zone='Naumburg FARP',      size='small',       side=1, level=25, upgrades=upgrades.farp2,           crates={},flavorText=flavor.naumburgfarp}), 
    schkeuditz      = ZoneCommander:new({zone='Schkeuditz',         size='big',         side=1, level=25, upgrades=upgrades.airfield3,       crates={},flavorText=flavor.schkeuditz}), 
    zerbst          = ZoneCommander:new({zone='Zerbst',             size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.zerbst}), -- kommit hit
    mahlwinkel      = ZoneCommander:new({zone='Mahlwinkel',         size='big',         side=1, level=25, upgrades=upgrades.airfield1,       crates={},flavorText=flavor.mahlwinkel}), 
    briest          = ZoneCommander:new({zone='Briest',             size='small',       side=1, level=25, upgrades=upgrades.farp1,           crates={},flavorText=flavor.briest}), 
    alteslager      = ZoneCommander:new({zone='Altes Lager',        size='medium',      side=1, level=25, upgrades=upgrades.farp2,           crates={},flavorText=flavor.alteslager}), 
    wundsdorffarp   = ZoneCommander:new({zone='Wundsdorf FARP',     size='small',       side=1, level=25, upgrades=upgrades.farp2,           crates={},flavorText=flavor.wundsdorffarp}), 
    tegel           = ZoneCommander:new({zone='Tegel',              size='big',         side=1, level=25, upgrades=upgrades.airfield1,       crates={},flavorText=flavor.tegel}),
    werneuchen      = ZoneCommander:new({zone='Werneuchen',         size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.werneuchen}),
    templin         = ZoneCommander:new({zone='Templin',            size='medium',      side=1, level=25, upgrades=upgrades.airfield4,       crates={},flavorText=flavor.templin}),
    neuruppin       = ZoneCommander:new({zone='Neuruppin',          size='medium',      side=1, level=25, upgrades=upgrades.airfield1,       crates={},flavorText=flavor.neuruppin}),
    hannover        = ZoneCommander:new({zone='Hannover',           size='extrabig',    side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.hannover,income=2}),
    scheessel       = ZoneCommander:new({zone='Scheessel',          size='medium',      side=1, level=25, upgrades=upgrades.airfield3,       crates={},flavorText=flavor.scheessel}),
    bremen          = ZoneCommander:new({zone='Bremen',             size='big',         side=1, level=25, upgrades=upgrades.airfield1,       crates={},flavorText=flavor.bremen}),
    hamburg         = ZoneCommander:new({zone='Hamburg',            size='extrabig',    side=1, level=25, upgrades=upgrades.airfield4,       crates={},flavorText=flavor.hamburg}),
    braunschweig    = ZoneCommander:new({zone='Braunschweig',       size='medium',      side=1, level=25, upgrades=upgrades.airfield3,       crates={},flavorText=flavor.braunschweig}),
    fassberg        = ZoneCommander:new({zone='Fassberg',           size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.fassberg}),
    lubeck          = ZoneCommander:new({zone='Lubeck',             size='big',         side=1, level=25, upgrades=upgrades.airfield6,       crates={},flavorText=flavor.lubeck}),
    laage           = ZoneCommander:new({zone='Laage',              size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.laage}),
    wismar          = ZoneCommander:new({zone='Wismar',             size='medium',      side=1, level=25, upgrades=upgrades.Wismar,       	 crates={},flavorText=flavor.wismar}),
    tutow           = ZoneCommander:new({zone='Tutow',              size='medium',      side=1, level=25, upgrades=upgrades.airfield3,       crates={},flavorText=flavor.tutow}),
    peenemunde      = ZoneCommander:new({zone='Peenemunde',         size='medium',      side=1, level=25, upgrades=upgrades.airfield3,       crates={},flavorText=flavor.peenemunde}),
    garz            = ZoneCommander:new({zone='Garz',               size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.garz}),
    neubrandenburg  = ZoneCommander:new({zone='Neubrandenburg',     size='medium',      side=1, level=25, upgrades=upgrades.airfield3,       crates={},flavorText=flavor.neubrandenburg}),
    parchim         = ZoneCommander:new({zone='Parchim',            size='medium',      side=1, level=25, upgrades=upgrades.airfield4,       crates={},flavorText=flavor.parchim}),
    larz            = ZoneCommander:new({zone='Larz',               size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.larz}),
    bornholm        = ZoneCommander:new({zone='Bornholm',           size='medium',      side=1, level=25, upgrades=upgrades.airfield3,       crates={},flavorText=flavor.bornholm}),
    sturup          = ZoneCommander:new({zone='Sturup',             size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.sturup}),
    kastrup         = ZoneCommander:new({zone='Kastrup City',       size='extrabig',    side=1, level=25, upgrades=upgrades.airfieldKastrup, crates={},flavorText=flavor.kastrup,income=2}),
    ostersjon       = ZoneCommander:new({zone='Östersjön',         	      				side=1, level=25, upgrades=upgrades.ship, 			 crates={},flavorText=flavor.ostersjon,income=2}),
    redarmycamp     = ZoneCommander:new({zone='Red Army Camp',   	size='redarmycamp', side=1, level=20, upgrades=upgrades.farp,       	 crates={}, flavorText=flavor.redarmycamp,NeutralAtStart=true,Popup=true}),
    insurgencycamp  = ZoneCommander:new({zone='Insurgency Camp',   	size='redarmycamp', side=1, level=20, upgrades=upgrades.farp,       	 crates={}, flavorText=flavor.insurgencycamp,NeutralAtStart=true,Popup=true}),


    samalpha        = ZoneCommander:new({zone='SAM-Alpha',          side=1, level=20, upgrades=upgrades.SamAlpha,        crates={}, flavorText=flavor.samalpha}),
    sambravo        = ZoneCommander:new({zone='SAM-Bravo',          side=1, level=20, upgrades=upgrades.SamBravo,        crates={}, flavorText=flavor.SamBravo}),
    samcharlie      = ZoneCommander:new({zone='SAM-Charlie',        side=1, level=20, upgrades=upgrades.samCharlie,      crates={}, flavorText=flavor.samcharlie}),
	samdelta        = ZoneCommander:new({zone='SAM-Delta',          side=1, level=20, upgrades=upgrades.samDelta,        crates={}, flavorText=flavor.samdelta}),
	samecho         = ZoneCommander:new({zone='SAM-Echo',           side=1, level=20, upgrades=upgrades.samEcho,         crates={}, flavorText=flavor.samecho}),
	samfoxtrot      = ZoneCommander:new({zone='SAM-Foxtrot',        side=1, level=20, upgrades=upgrades.samFoxtrot,      crates={}, flavorText=flavor.samfoxtrot}),
	samgolf         = ZoneCommander:new({zone='SAM-Golf',           side=1, level=20, upgrades=upgrades.samGolf,         crates={}, flavorText=flavor.samgolf}),
	samhotel        = ZoneCommander:new({zone='SAM-Hotel',          side=1, level=20, upgrades=upgrades.samHotel,        crates={}, flavorText=flavor.samhotel}),
    samindia        = ZoneCommander:new({zone='SAM-India',          side=1, level=20, upgrades=upgrades.samIndia,        crates={}, flavorText=flavor.samindia}),
	samjuliett      = ZoneCommander:new({zone='SAM-Juliett',        side=1, level=20, upgrades=upgrades.samJuliett,      crates={}, flavorText=flavor.samjuliett}),
	samkilo         = ZoneCommander:new({zone='SAM-Kilo',           side=1, level=20, upgrades=upgrades.samKilo,         crates={}, flavorText=flavor.samkilo,}),
	samlima         = ZoneCommander:new({zone='SAM-Lima',           side=1, level=20, upgrades=upgrades.samLima,         crates={}, flavorText=flavor.samlima,}),
	sammike         = ZoneCommander:new({zone='SAM-Mike',           side=1, level=20, upgrades=upgrades.samMike,         crates={}, flavorText=flavor.sammike,NeutralAtStart=true, Popup=true}),
    
    hidden1         = ZoneCommander:new({zone='Hidden1',            side=1, level=20, upgrades=upgrades.EWRMantisNet,    crates={}, flavorText=flavor.hidden1}),
    hidden2         = ZoneCommander:new({zone='Hidden2',            side=1, level=20, upgrades=upgrades.hidden2,         crates={}, flavorText=flavor.hidden2}),
    hiddenground1   = ZoneCommander:new({zone='HiddenGround1',      side=1, level=20, upgrades=upgrades.hiddenground1,  crates={}, flavorText=flavor.hiddenground1}),
    hiddenground2   = ZoneCommander:new({zone='HiddenGround2',      side=0, level=20, upgrades=upgrades.hiddenground2,  crates={}, flavorText=flavor.hiddenground2, NeutralAtStart=true}),
    hiddenground3   = ZoneCommander:new({zone='HiddenGround3',      side=0, level=20, upgrades=upgrades.hiddenground3,  crates={}, flavorText=flavor.hiddenground3, NeutralAtStart=true}),
    hiddenground4   = ZoneCommander:new({zone='HiddenGround4',      side=0, level=20, upgrades=upgrades.hiddenground4,  crates={}, flavorText=flavor.hiddenground4, NeutralAtStart=true}),
    hiddenground5   = ZoneCommander:new({zone='HiddenGround5',      side=0, level=35, upgrades=upgrades.hiddenground5,  crates={}, flavorText=flavor.hiddenground5, NeutralAtStart=true}),
    hiddenground6   = ZoneCommander:new({zone='HiddenGround6',      side=0, level=35, upgrades=upgrades.hiddenground6,  crates={}, flavorText=flavor.hiddenground6, NeutralAtStart=true}),
    hiddenground7   = ZoneCommander:new({zone='HiddenGround7',      side=0, level=35, upgrades=upgrades.hiddenground7,  crates={}, flavorText=flavor.hiddenground7, NeutralAtStart=true}),
    hiddenground8   = ZoneCommander:new({zone='HiddenGround8',      side=0, level=35, upgrades=upgrades.hiddenground8,  crates={}, flavorText=flavor.hiddenground8, NeutralAtStart=true}),
    hiddenground9   = ZoneCommander:new({zone='HiddenGround9',      side=0, level=35, upgrades=upgrades.hiddenground9,  crates={}, flavorText=flavor.hiddenground9, NeutralAtStart=true}),
    hiddenground10   = ZoneCommander:new({zone='HiddenGround10',      side=0, level=35, upgrades=upgrades.hiddenground10,  crates={}, flavorText=flavor.hiddenground10, NeutralAtStart=true}),
    hiddenground11   = ZoneCommander:new({zone='HiddenGround11',      side=0, level=35, upgrades=upgrades.hiddenground11,  crates={}, flavorText=flavor.hiddenground11, NeutralAtStart=true}),
    hiddenground12   = ZoneCommander:new({zone='HiddenGround12',      side=0, level=35, upgrades=upgrades.hiddenground12,  crates={}, flavorText=flavor.hiddenground12, NeutralAtStart=true}),
    hiddenground13   = ZoneCommander:new({zone='HiddenGround13',      side=0, level=35, upgrades=upgrades.hiddenground13,  crates={}, flavorText=flavor.hiddenground13, NeutralAtStart=true}),
    hiddenground14   = ZoneCommander:new({zone='HiddenGround14',      side=0, level=35, upgrades=upgrades.hiddenground14,  crates={}, flavorText=flavor.hiddenground14, NeutralAtStart=true}),
    hiddenground15   = ZoneCommander:new({zone='HiddenGround15',      side=0, level=35, upgrades=upgrades.hiddenground15,  crates={}, flavorText=flavor.hiddenground15, NeutralAtStart=true}),																																														  
    hiddensweden    = ZoneCommander:new({zone='HiddenSweden',       side=0, level=35, upgrades=upgrades.hiddensweden,   crates={}, flavorText=flavor.hiddensweden, NeutralAtStart=true}),

    sheizefactory   = ZoneCommander:new({zone='Scheiße Factory',     side=1, level=20, upgrades=upgrades.Scheize,        crates={}, flavorText=flavor.sheizefactory}),
    chemicalfactory = ZoneCommander:new({zone='Chemical Factory',    side=1, level=20, upgrades=upgrades.Chemical,       crates={}, flavorText=flavor.chemicalfactory}),
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
	SeadCarrierGroup = {
        'BLUE_F14_SEAD',
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
        'BLUE_AH-64D_OneShip_Load2',
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


zones.bitburg:addGroups({
	--GroupCommander:new({name='Bitburg-supply-Hahn', mission='supply', template='HeloSupplyTemplate', targetzone='Hahn'}),
	GroupCommander:new({name='Bitburg-supply-Hahn', mission='supply', template='PlaneSupplyTemplate', targetzone='Hahn'}),
    GroupCommander:new({name='Bitburg-supply-Hahn-Warehouse', mission='supply', template='PlaneSupplyTemplate',MissionType ='Warehouse', targetzone='Hahn'}),
	GroupCommander:new({name='Bitburg-supply-Frankfurt', mission='supply', template='PlaneSupplyTemplate', targetzone='Frankfurt'}),
	GroupCommander:new({name='Bitburg-supply-Ramstein', mission='supply', template='PlaneSupplyTemplate', targetzone='Ramstein'}),
	GroupCommander:new({name='Bitburg-supply-Ramstein-Warehouse', mission='supply', template='PlaneSupplyTemplate',MissionType ='Warehouse', targetzone='Ramstein'}),
	GroupCommander:new({name='Bitburg-attack-Hahn-Cas', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Hahn'}),
	GroupCommander:new({name='Bitburg-attack-Mendig-East-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Mendig East FARP', Altitude = CapAltitude()}),
	GroupCommander:new({name='Bitburg-attack-SAM-Alpha-SEAD', mission='attack', template='SeadPlaneTemplate',MissionType='SEAD', targetzone='SAM-Alpha', Altitude = SeadAltitude()}),
    GroupCommander:new({name='Bitburg-supply-Spangdahlem', mission='supply', template='HeloSupplyTemplate', targetzone='Spangdahlem'}),
})

zones.hahn:addGroups({
    GroupCommander:new({name='Hahn-supply-Frankfurt-Warehouse', mission='supply', template='PlaneSupplyTemplate',MissionType ='Warehouse', targetzone='Frankfurt'}),
	GroupCommander:new({name='Hahn-supply-Mendig', mission='supply', template='HeloSupplyTemplate', targetzone='Mendig'}),
	GroupCommander:new({name='Hahn-supply-Baumholder FARP', mission='supply', template='HeloSupplyTemplate', targetzone='Baumholder FARP'}),
	GroupCommander:new({name='Hahn-supply-Airracing Frankfurt', mission='supply', template='HeloSupplyTemplate', targetzone='Airracing Frankfurt'}),
	GroupCommander:new({name='Hahn-patrol-Airracing-Frankfurt-Cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Airracing Frankfurt', Altitude = CapAltitude()}),
	GroupCommander:new({name='Hahn-attack-Baumholder FARP-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Baumholder FARP', Altitude = CasAltitude(), Bluecondition = function() return not zones.samalpha.active end}),
	GroupCommander:new({name='Hahn-attack-Ramstein-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Ramstein', Altitude = CasAltitude(), Bluecondition = function() return not zones.samalpha.active end}),
	GroupCommander:new({name='Hahn-attack-Mendig North-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Mendig North FARP'}),
	GroupCommander:new({name='Hahn-attack-Spangdahlem-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Spangdahlem',Altitude = CasAltitude()}),
	GroupCommander:new({name='Hahn-attack-Spangdahlem-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Spangdahlem',Altitude = SeadAltitude()}),
	GroupCommander:new({name='Hahn-attack-Baumholder FARP-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Baumholder FARP'}),
	GroupCommander:new({name='Hahn-attack-Mendig-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Mendig'}),
})

zones.mendig:addGroups({
	GroupCommander:new({name='Mendig-supply-Mendig North FARP-Convoy', mission='supply',template='SupplyConvoy', targetzone='Mendig North FARP', type='surface'}),
	GroupCommander:new({name='Mendig-supply-Mendig East FARP-Convoy', mission='supply',template='SupplyConvoy', targetzone='Mendig East FARP', type='surface'}),
	GroupCommander:new({name='Mendig-attack-Hahn-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Hahn', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='Mendig-supply-Spangdahlem', mission='supply',template='CasHeloTemplate',MissionType='CAS', targetzone='Spangdahlem'}),
	GroupCommander:new({name='Mendig-attack-Hahn-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Hahn'}),
})

zones.mendigeast:addGroups({
	GroupCommander:new({name='Mendig East FARP-supply-Mendig-Convoy', mission='supply',template='SupplyConvoy', targetzone='Mendig', type='surface'}),
	GroupCommander:new({name='Mendig East FARP-supply-Mendig North FARP-Convoy', mission='supply',template='SupplyConvoy', targetzone='Mendig North FARP', type='surface'}),
	GroupCommander:new({name='Mendig East FARP-attack-Mendig', mission='attack',template='AttackConvoy', targetzone='Mendig', type='surface'}),
	GroupCommander:new({name='Mendig East FARP-attack-Mendig North FARP', mission='attack',template='AttackConvoy', targetzone='Mendig North FARP', type='surface'}),
	GroupCommander:new({name='Mendig East FARP-attack-Hahn', mission='attack',template='CasHeloTemplate', MissionType='CAS', targetzone='Hahn'})
})

zones.baumholderfarp:addGroups({
	GroupCommander:new({name='Baumholder-supply-Ramstein', mission='supply', template='HeloSupplyTemplate', targetzone='Ramstein'}),
	GroupCommander:new({name='Baumholder-supply-Ramstein-SAM-Alpha', mission='supply', template='SupplyConvoy', targetzone='Ramstein', type='surface'}),
	GroupCommander:new({name='Baumholder FARP-attack-Hahn-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Hahn'}),
})

zones.ramstein:addGroups({
    GroupCommander:new({name='Ramstein-patrol-Hahn-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hahn', Altitude = CapAltitude()}),
    GroupCommander:new({name='Ramstein-patrol-Frankfurt-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Frankfurt', Altitude = CapAltitude()}),
    GroupCommander:new({name='Ramstein-patrol-Ramstein-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramstein', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ramstein-patrol-Baumholder-FARP-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Baumholder FARP', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ramstein-patrol-Gelnhausen-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gelnhausen', Altitude = CapAltitude()}),
	
    GroupCommander:new({name='Ramstein-attack-Hahn-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hahn', Altitude = CapAltitude()}),
    GroupCommander:new({name='Ramstein-attack-Hahn-2-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hahn', Altitude = CapAltitude()}),

	
    GroupCommander:new({name='Ramstein-CAS-attack-Frankfurt',template='CasPlaneTemplate',MissionType='CAS', mission='attack', targetzone='Frankfurt', Altitude = CasAltitude()}),
    GroupCommander:new({name='Ramstein-CAS-attack-Frankfurt',template='SeadPlaneTemplate',MissionType='SEAD', mission='attack', targetzone='Frankfurt', Altitude = SeadAltitude()}),
    GroupCommander:new({name='Ramstein-CAS-attack-Hahn',template='CasPlaneTemplate',MissionType='CAS', mission='attack', targetzone='Hahn', Altitude = CasAltitude()}),
	GroupCommander:new({name='Ramstein-CAS-attack-Walldurn FARP',template='CasPlaneTemplate',MissionType='CAS', mission='attack', targetzone='Walldurn FARP', Altitude = CasAltitude(), Bluecondition = function() return not zones.baddurkheim.side == 1 end}),
	GroupCommander:new({name='Ramstein-CAS-attack-Giebelstadt',template='CasPlaneTemplate',MissionType='CAS', mission='attack', targetzone='Giebelstadt', Altitude = CasAltitude(), Bluecondition = function() return not zones.walldurnfarp.side == 1 end}),
	GroupCommander:new({name='Ramstein-CAS-attack-Bad Durkheim',template='CasHeloTemplate',MissionType='CAS', mission='attack', targetzone='Bad Durkheim'}),
	
    GroupCommander:new({name='Ramstein-supply-Baumholder', mission='supply', template='HeloSupplyTemplate', targetzone='Baumholder FARP'}),
	GroupCommander:new({name='Ramstein-supply-Bad Durkheim', mission='supply', template='HeloSupplyTemplate', targetzone='Bad Durkheim'})
})

zones.baddurkheim:addGroups({
	GroupCommander:new({name='Bad-Durkheim-supply-ramstein', mission='supply', template='HeloSupplyTemplate', targetzone='Ramstein', ForceFromGround=true}),
	GroupCommander:new({name='Bad-Durkheim-supply-Walldorf', mission='supply', template='HeloSupplyTemplate', targetzone='Walldorf FARP', ForceFromGround=true}),
	GroupCommander:new({name='Bad Durkheim-attack-Ramstein-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Ramstein',ForceFromGround=true}),
	GroupCommander:new({name='Bad Durkheim-attack-Walldorf FARP-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Walldorf FARP',ForceFromGround=true}),
})

zones.walldorffarp:addGroups({
	GroupCommander:new({name='Walldorf FARP-supply-Bad Durkheim', mission='supply', template='HeloSupplyTemplate', targetzone='Bad Durkheim'}),
	GroupCommander:new({name='Walldorf FARP-supply-Walldurn', mission='supply', template='HeloSupplyTemplate', targetzone='Walldurn FARP'}),
	GroupCommander:new({name='Walldorf FARP-attack-Bad Durkheim-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Bad Durkheim'}),
})

zones.walldurnfarp:addGroups({
	GroupCommander:new({name='Walldurn FARP-supply-Walldorf', mission='supply', template='HeloSupplyTemplate', targetzone='Walldorf FARP'}),
	GroupCommander:new({name='Walldurn FARP-supply-Giebelstadt', mission='supply', template='HeloSupplyTemplate', targetzone='Giebelstadt'}),
	GroupCommander:new({name='Walldurn FARP-attack-Giebelstadt-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Giebelstadt'}),
})

zones.giebelstadt:addGroups({
	GroupCommander:new({name='Giebelstadt-attack-Frankfurt-Cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Frankfurt',Altitude = CasAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Frankfurt-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Frankfurt',Altitude = CapAltitude()}),
	GroupCommander:new({name='Giebelstadt-patrol-Frankfurt-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Frankfurt',Altitude = CapAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Gelnhausen-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Gelnhausen',Altitude = CapAltitude()}),
	GroupCommander:new({name='Giebelstadt-patrol-Gelnhausen-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Gelnhausen',Altitude = CapAltitude()}),

	GroupCommander:new({name='Giebelstadt-patrol-Bad Durkheim-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Bad Durkheim',Altitude = CapAltitude()}),
	GroupCommander:new({name='Giebelstadt-patrol-Ramstein-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramstein',Altitude = CapAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Ramstein-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramstein',Altitude = CapAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Hahn-Cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Hahn',Altitude = CasAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Hahn-Sead', mission='attack',template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Hahn',Altitude = SeadAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Hahn-rwy', mission='attack',template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Hahn',Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Frankfurt-Sead', mission='attack',template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Frankfurt', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Walldorf FARP', mission='attack',template='CasHeloTemplate', MissionType='CAS', targetzone='Walldorf FARP', spawnDelayFactor = 2}),
	GroupCommander:new({name='Giebelstadt-supply-Walldurn FARP', mission='supply', template='HeloSupplyTemplate', targetzone='Walldurn FARP'}),
	GroupCommander:new({name='Giebelstadt-attack-Walldurn FARP-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Walldurn FARP'}),
})

zones.airrcing:addGroups({
	GroupCommander:new({name='Airracing Frankfurt-attack-Mendig-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Mendig'}),
	GroupCommander:new({name='Airracing Frankfurt-attack-Frankfurt-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Frankfurt'}),
	GroupCommander:new({name='Airracing Frankfurt-supply-Frankfurt', mission='supply', template='HeloSupplyTemplate', targetzone='Frankfurt'})
})

zones.frankfurt:addGroups({
	GroupCommander:new({name='Frankfurt-attack-Fulda-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Fulda', Altitude = CapAltitude()}),
	GroupCommander:new({name='Frankfurt-attack-Fulda-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Fulda', Altitude = CasAltitude()}),
	GroupCommander:new({name='Frankfurt-attack-SAM-Charlie-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='SAM-Charlie', Altitude = SeadAltitude(), Bluecondition = function() return not zones.fulda.side == 1 end}),

	GroupCommander:new({name='Frankfurt-patrol-Fulda-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Fulda', Altitude = CapAltitude()}),
	GroupCommander:new({name='Frankfurt-patrol-Hahn-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hahn', Altitude = CapAltitude()}),
    GroupCommander:new({name='Frankfurt-patrol-Frankfurt-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Frankfurt', Altitude = CapAltitude()}),
	GroupCommander:new({name='Frankfurt-patrol-Mendig-East-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mendig East FARP', Altitude = CapAltitude()}),
	GroupCommander:new({name='Frankfurt-patrol-Ramstein-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramstein', Altitude = CapAltitude()}),
	GroupCommander:new({name='Frankfurt-patrol-Bindersleben-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gelnhausen', Altitude = CapAltitude()}),
	
    GroupCommander:new({name='Frankfurt-Attack-Hahn-CAS', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Hahn', Altitude = CasAltitude()}),
    GroupCommander:new({name='Frankfurt-Attack-Hahn-Mendig-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Mendig', Altitude = CasAltitude()}),
    GroupCommander:new({name='Frankfurt-Attack-Hahn-Mendig East-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Mendig East FARP', Altitude = CasAltitude()}),
	GroupCommander:new({name='Frankfurt-Attack-Hahn-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Hahn', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Frankfurt-Attack-Hahn-rwy', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Hahn', Altitude = RunwayStrikeAltitude()}),

    GroupCommander:new({name='Frankfurt-supply-Hahn', mission='supply', template='HeloSupplyTemplate', targetzone='Hahn'}),
	GroupCommander:new({name='Frankfurt-supply-Airracing-frankfurt-Convoy', mission='supply', template='SupplyConvoy', targetzone='Airracing Frankfurt', type='surface'}),
    GroupCommander:new({name='Frankfurt-supply-Gelnhausen', mission='supply', template='HeloSupplyTemplate', targetzone='Gelnhausen'}),
	GroupCommander:new({name='Frankfurt-supply-Bindersleben', mission='supply', template='PlaneSupplyTemplate', targetzone='Bindersleben'}),
	GroupCommander:new({name='Frankfurt-supply-Schkeuditz', mission='supply', template='PlaneSupplyTemplate', targetzone='Schkeuditz'}),
	GroupCommander:new({name='Frankfurt-attack-Gelnhausen-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Gelnhausen'}),
})

zones.fritzlar:addGroups({
	GroupCommander:new({name='Fritzlar-supply-Frankfurt', mission='supply', template='HeloSupplyTemplate', targetzone='Frankfurt'})
})

zones.gelnhausen:addGroups({
	GroupCommander:new({name='Gelnhausen-supply-Frankfurt', mission='supply', template='SupplyConvoy', targetzone='Frankfurt', type='surface'}),
	GroupCommander:new({name='Gelnhausen-attack-Frankfurt', mission='attack', template='AttackConvoy', targetzone='Frankfurt', type='surface'}),
	GroupCommander:new({name='Gelnhausen-supply-Laubach FARP', mission='supply', template='HeloSupplyTemplate', targetzone='Laubach FARP'}),
	GroupCommander:new({name='Gelnhausen-supply-SAM-Bravo', mission='supply', template='SupplyConvoy', targetzone='SAM-Bravo', type='surface', spawnDelayFactor = 3}),
	GroupCommander:new({name='Gelnhausen-attack-Frankfurt-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Frankfurt'}),
})

zones.laubachfarp:addGroups({
    GroupCommander:new({name='Laubach FARP-attack-frankfurt-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Frankfurt', type='surface', diceChance = 30, SetActiveMission = true}),
	GroupCommander:new({name='Laubach FARP-supply-Gelnhausen', mission='supply', template='HeloSupplyTemplate', targetzone='Gelnhausen'}),
	GroupCommander:new({name='Laubach FARP-supply-Fulda', mission='supply', template='HeloSupplyTemplate', targetzone='Fulda'})
})

zones.fulda:addGroups({
	GroupCommander:new({name='Fulda-supply-Laubach FARP', mission='supply', template='HeloSupplyTemplate', targetzone='Laubach FARP'}),
	GroupCommander:new({name='Fulda-supply-Salzungen FARP', mission='supply', template='HeloSupplyTemplate', targetzone='Salzungen FARP'}),
	GroupCommander:new({name='Fulda-attack-Gelnhausen', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Gelnhausen'}),
	GroupCommander:new({name='Fulda-attack-Salzungen FARP', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Salzungen FARP'}),
	GroupCommander:new({name='Fulda-attack-Gelnhausen', mission='attack', template='AttackConvoy', targetzone='Gelnhausen', type='surface'})
})

zones.salzungenfarp:addGroups({
	GroupCommander:new({name='Salzungen FARP-supply-Fulda', mission='supply', template='HeloSupplyTemplate', targetzone='Fulda'}),
	GroupCommander:new({name='Salzungen FARP-supply-Bindersleben', mission='supply', template='HeloSupplyTemplate', targetzone='Bindersleben'}),
	GroupCommander:new({name='Salzungen FARP-supply-SAM-Charlie', mission='supply', template='SupplyConvoy', targetzone='SAM-Charlie', type='surface', spawnDelayFactor = 3}),
	GroupCommander:new({name='Salzungen FARP-Attack-Fulda', mission='attack', template='AttackConvoy', targetzone='Fulda', type='surface'}),
	GroupCommander:new({name='Salzungen FARP-attack-Laubach FARP', mission='attack', template='AttackConvoy', targetzone='Laubach FARP', type='surface'}),
	GroupCommander:new({name='Salzungen FARP-attack-Fulda-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Fulda'}),
})

zones.bindersleben:addGroups({
	GroupCommander:new({name='Bindersleben-patrol-Salzungen FARP-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Salzungen FARP', Altitude = CapAltitude()}),
	GroupCommander:new({name='Bindersleben-patrol-Bindersleben-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bindersleben', Altitude = CapAltitude()}),
	GroupCommander:new({name='Bindersleben-patrol-Gelnhausen-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gelnhausen', Altitude = CapAltitude()}),
	GroupCommander:new({name='Bindersleben-attack-frankfurt-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Frankfurt', Altitude = CapAltitude()}),
	GroupCommander:new({name='Bindersleben-patrol-frankfurt-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Frankfurt', Altitude = CapAltitude()}),
	GroupCommander:new({name='Bindersleben-attack-Gelnhausen-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gelnhausen', Altitude = CapAltitude()}),

	GroupCommander:new({name='Bindersleben-patrol-Fulda-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Fulda', Altitude = CapAltitude()}),
	GroupCommander:new({name='Bindersleben-patrol-schkeuditz-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Naumburg FARP', Altitude = CapAltitude()}),
	GroupCommander:new({name='Bindersleben-attack-Schkeuditz-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Schkeuditz', Altitude = CasAltitude()}),
	GroupCommander:new({name='Bindersleben-attack-Frankfurt-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Frankfurt', Altitude = CasAltitude()}),
	GroupCommander:new({name='Bindersleben-attack-Frankfurt-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Frankfurt', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Bindersleben-attack-Frankfurt-rwy', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Frankfurt', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Bindersleben-patrol-Fritzlar-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Fritzlar', Altitude = CapAltitude()}),
	GroupCommander:new({name='Bindersleben-attack-Fulda-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Fulda', spawnDelayFactor = 3}),
	GroupCommander:new({name='Bindersleben-attack-Fulda-CasPlane', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Fulda', Altitude = CasAltitude()}),
	GroupCommander:new({name='Bindersleben-attack-Fulda-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Fulda', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Bindersleben-attack-Fulda-rwy', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Fulda', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Bindersleben-supply-Salzungen FARP', mission='supply', template='HeloSupplyTemplate', targetzone='Salzungen FARP'}),
	GroupCommander:new({name='Bindersleben-supply-Naumburg FARP', mission='supply', template='HeloSupplyTemplate', targetzone='Naumburg FARP'})
})

zones.naumburgfarp:addGroups({
	GroupCommander:new({name='Naumburg FARP-supply-Bindersleben', mission='supply', template='HeloSupplyTemplate', targetzone='Bindersleben'}),
	GroupCommander:new({name='Naumburg FARP-supply-Schkeuditz', mission='supply', template='HeloSupplyTemplate', targetzone='Schkeuditz'}),
	GroupCommander:new({name='Naumburg FARP-attack-Bindersleben', mission='attack', template='AttackConvoy', targetzone='Bindersleben',type='surface'}),
	GroupCommander:new({name='Naumburg FARP-attack-Schkeuditz-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Schkeuditz'}),
})

zones.schkeuditz:addGroups({
	GroupCommander:new({name='Schkeuditz-patrol-Naumburg FARP-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Naumburg FARP', Altitude = CapAltitude()}),
	GroupCommander:new({name='Schkeuditz-attack-Naumburg FARP-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Naumburg FARP', Altitude = CapAltitude()}),
	GroupCommander:new({name='Schkeuditz-patrol-Schkeuditz-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Schkeuditz', Altitude = CapAltitude()}),
	GroupCommander:new({name='Schkeuditz-patrol-Bindersleben-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bindersleben', Altitude = CapAltitude()}),
	GroupCommander:new({name='Schkeuditz-attack-Bindersleben-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bindersleben', Altitude = CapAltitude()}),
	GroupCommander:new({name='Schkeuditz-attack-Bindersleben-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Bindersleben', Altitude = CasAltitude()}),
	GroupCommander:new({name='Schkeuditz-attack-Bindersleben-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Bindersleben', Altitude = SeadAltitude()}),
	
    
    GroupCommander:new({name='Schkeuditz-attack-Bindersleben-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Salzungen FARP', Altitude = CasAltitude()}),
    GroupCommander:new({name='Schkeuditz-attack-Fulda-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Salzungen FARP', Altitude = CasAltitude()}),

	GroupCommander:new({name='Schkeuditz-attack-Naumburg FARP-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Naumburg FARP'}),
	
    GroupCommander:new({name='Schkeuditz-attack-Naumburg FARP', mission='attack', template='AttackConvoy', targetzone='Naumburg FARP', type='surface'}),

    
    GroupCommander:new({name='Schkeuditz-supply-Zerbst', mission='supply', template='HeloSupplyTemplate', targetzone='Zerbst'}),
	GroupCommander:new({name='Schkeuditz-supply-Tegel', mission='supply', template='PlaneSupplyTemplate', targetzone='Tegel'}),
	GroupCommander:new({name='Schkeuditz-supply-Braunschweig', mission='supply', template='PlaneSupplyTemplate', targetzone='Braunschweig'}),
	GroupCommander:new({name='Schkeuditz-supply-Hannover', mission='supply', template='PlaneSupplyTemplate', targetzone='Hannover'}),
	GroupCommander:new({name='Schkeuditz-supply-SAM-Delta', mission='supply', template='SupplyConvoy', targetzone='SAM-Delta', type='surface', spawnDelayFactor = 3}),
})

zones.zerbst:addGroups({
	GroupCommander:new({name='Zerbst-patrol-Schkeuditz-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Schkeuditz', Altitude = CapAltitude()}),
	GroupCommander:new({name='Zerbst-attack-Schkeuditz-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Schkeuditz', Altitude = CapAltitude()}),
	GroupCommander:new({name='Zerbst-attack-Frankfurt-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Frankfurt', Altitude = CapAltitude()}),
	GroupCommander:new({name='Zerbst-patrol-Mahlwinkel-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mahlwinkel', Altitude = CapAltitude()}),
	GroupCommander:new({name='Zerbst-attack-Mahlwinkel-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mahlwinkel', Altitude = CapAltitude()}),

	GroupCommander:new({name='Zerbst-attack-Schkeuditz-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Schkeuditz', Altitude = CasAltitude()}),
	GroupCommander:new({name='Zerbst-attack-Mahlwinkel-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Mahlwinkel'}),

	GroupCommander:new({name='Zerbst-attack-Schkeuditz-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Schkeuditz', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Zerbst-attack-Schkeuditz-rwy', mission='attack', template='SeadPlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Schkeuditz', Altitude = RunwayStrikeAltitude()}),

	GroupCommander:new({name='Zerbst-attack-Bindersleben-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bindersleben', Altitude = CapAltitude()}),
	GroupCommander:new({name='Zerbst-attack-Bindersleben-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Bindersleben', Altitude = CasAltitude()}),
	GroupCommander:new({name='Zerbst-attack-Bindersleben-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Bindersleben', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Zerbst-attack-Bindersleben-rwy', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Bindersleben', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Zerbst-patrol-Bindersleben-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bindersleben', Altitude = CapAltitude()}),

	GroupCommander:new({name='Zerbst-attack-Naumburg FARP-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Naumburg FARP', Altitude = CapAltitude()}),
	GroupCommander:new({name='Zerbst-attack-Naumburg FARP-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Naumburg FARP', Altitude = CasAltitude()}),
	GroupCommander:new({name='Zerbst-patrol-Naumburg FARP-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Naumburg FARP', Altitude = CapAltitude()}),

	GroupCommander:new({name='Zerbst-supply-Schkeuditz', mission='supply', template='HeloSupplyTemplate', targetzone='Schkeuditz'}),
	GroupCommander:new({name='Zerbst-supply-Mahlwinkel', mission='supply', template='HeloSupplyTemplate', targetzone='Mahlwinkel'})
})

zones.mahlwinkel:addGroups({
	GroupCommander:new({name='Mahlwinkel-attack-Naumburg FARP-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Naumburg FARP', Altitude = CapAltitude()}),
	GroupCommander:new({name='Mahlwinkel-attack-Zerbst-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Zerbst', Altitude = CasAltitude()}),
	GroupCommander:new({name='Mahlwinkel-attack-Zerbst-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Schkeuditz', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Mahlwinkel-attack-Fritzlar-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Fritzlar', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Mahlwinkel-attack-Zerbst-Convoy', mission='attack',template='AttackConvoy', targetzone='Zerbst', type='surface', spawnDelayFactor = 3, diceChance = 50}),
	GroupCommander:new({name='Mahlwinkel-supply-Zerbst', mission='supply', template='HeloSupplyTemplate', targetzone='Zerbst'}),
	GroupCommander:new({name='Mahlwinkel-supply-Briest', mission='supply', template='HeloSupplyTemplate', targetzone='Briest'}),
	GroupCommander:new({name='Mahlwinkel-supply-Braunschweig', mission='supply', template='HeloSupplyTemplate', targetzone='Braunschweig'}),
	GroupCommander:new({name='Mahlwinkel-attack-Zerbst', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Zerbst', Altitude = CasAltitude()}),
	GroupCommander:new({name='Mahlwinkel-supply-SAM-Echo', mission='supply', template='SupplyConvoy', targetzone='SAM-Echo', type='surface', condition = function(self) if self.side == 1 then self.spawnDelayFactor = 2 return not CustomFlags["MahlwinkelWarehouse"] end end}),
	GroupCommander:new({name='Mahlwinkel-patrol-Bindersleben-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bindersleben', Altitude = CapAltitude()}),
	GroupCommander:new({name='Mahlwinkel-patrol-Schkeuditz', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Schkeuditz', Altitude = CapAltitude()}),
	GroupCommander:new({name='Mahlwinkel-patrol-Zerbst', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Zerbst', Altitude = CapAltitude()}),
	GroupCommander:new({name='Mahlwinkel-attack-Briest-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Briest'}),
	GroupCommander:new({name='Mahlwinkel-attack-Zerbst-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Zerbst'}),
	GroupCommander:new({name='Mahlwinkel-attack-Zerbst-Arty',mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250,targetzone='Zerbst',type='surface',SetActiveMission=true,artilleryRangeNm=8}),

})

zones.braunschweig:addGroups({
	GroupCommander:new({name='Braunschweig-supply-Mahlwinkel', mission='supply', template='HeloSupplyTemplate', targetzone='Mahlwinkel'}),
	GroupCommander:new({name='Braunschweig-supply-Hannover', mission='supply', template='HeloSupplyTemplate', targetzone='Hannover'}),
	GroupCommander:new({name='Braunschweig-attack-Hannover-Cas', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Hannover'}),
	GroupCommander:new({name='Braunschweig-attack-Mahlwinkel-Cas', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Mahlwinkel'}),
})

zones.hannover:addGroups({
	GroupCommander:new({name='Hannover-patrol-Braunschweig-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Braunschweig', Altitude = CapAltitude()}),
	GroupCommander:new({name='Hannover-supply-Braunschweig', mission='supply', template='HeloSupplyTemplate', targetzone='Braunschweig'}),
	GroupCommander:new({name='Hannover-supply-Fassberg', mission='supply', template='HeloSupplyTemplate', targetzone='Fassberg'}),
	GroupCommander:new({name='Hannover-attack-Mahlwinkel-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Mahlwinkel', Altitude = CasAltitude()}),
	GroupCommander:new({name='Hannover-attack-Zerbst-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Zerbst', Altitude = CasAltitude()}),
	GroupCommander:new({name='Hannover-attack-Zerbst-Sead', mission='attack', template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Zerbst', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Hannover-supply-SAM-Golf', mission='supply', template='SupplyConvoy', targetzone='SAM-Golf', type='surface', spawnDelayFactor = 2, Redcondition=function() return CustomFlags["HannoverSupply"] ~= true end}),
	GroupCommander:new({name='Hannover-supply-SAM-Foxtrot', mission='supply', template='SupplyConvoy', targetzone='SAM-Foxtrot', type='surface', spawnDelayFactor = 4, Redcondition=function() return CustomFlags["HannoverSupply"] ~= true end}),
	GroupCommander:new({name='Hannover-attack-Braunschweig-Arty', mission='attack', template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Braunschweig', type='surface', SetActiveMission = true}),
})

zones.fassberg:addGroups({
	GroupCommander:new({name='Fassberg-patrol-Fassberg-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Braunschweig', Altitude = CapAltitude()}),
	GroupCommander:new({name='Fassberg-patrol-Mahlwinkel-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mahlwinkel', Altitude = CapAltitude()}),
	GroupCommander:new({name='Fassberg-attack-Mahlwinkel-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mahlwinkel', Altitude = CapAltitude()}),
	GroupCommander:new({name='Fassberg-attack-Mahlwinkel-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Mahlwinkel', Altitude = CasAltitude()}),
	GroupCommander:new({name='Fassberg-attack-Mahlwinkel-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Mahlwinkel', Altitude = SeadAltitude()}),

	GroupCommander:new({name='Fassberg-patrol-Neuruppin-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Neuruppin', Altitude = CapAltitude()}),
	GroupCommander:new({name='Fassberg-attack-Neuruppin-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Neuruppin', Altitude = CapAltitude()}),
	GroupCommander:new({name='Fassberg-attack-Neuruppin-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Neuruppin', Altitude = CasAltitude()}),
	GroupCommander:new({name='Fassberg-attack-Neuruppin-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Neuruppin', Altitude = SeadAltitude()}),

	GroupCommander:new({name='Fassberg-supply-Hannover', mission='supply', template='HeloSupplyTemplate', targetzone='Hannover'}),
	GroupCommander:new({name='Fassberg-supply-Scheessel', mission='supply', template='HeloSupplyTemplate', targetzone='Scheessel'}),
	GroupCommander:new({name='Fassberg-supply-Bremen', mission='supply', template='PlaneSupplyTemplate', targetzone='Bremen'}),
	GroupCommander:new({name='Fassberg-attack-Scheessel-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Scheessel'}),
})

zones.scheessel:addGroups({
	GroupCommander:new({name='Scheessel-supply-Fassberg', mission='supply', template='HeloSupplyTemplate', targetzone='Fassberg'}),
	GroupCommander:new({name='Scheessel-supply-Bremen', mission='supply', template='HeloSupplyTemplate', targetzone='Bremen'}),
	GroupCommander:new({name='Scheessel-supply-Hamburg', mission='supply', template='HeloSupplyTemplate', targetzone='Hamburg'}),
    GroupCommander:new({name='Scheessel-attack-Bremen', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Bremen'}),
	GroupCommander:new({name='Scheessel-attack-Fassberg-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Fassberg'}),
})

zones.bremen:addGroups({
	GroupCommander:new({name='Bremen-supply-Scheessel', mission='supply', template='HeloSupplyTemplate', targetzone='Scheessel'}),
	GroupCommander:new({name='Bremen-attack-Scheessel', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Scheessel'}),
	GroupCommander:new({name='Bremen-supply-SAM-Hotel', mission='supply',template='SupplyConvoy', targetzone='SAM-Hotel', type='surface', spawnDelayFactor = random(2,4)}),
	GroupCommander:new({name='Bremen-attack-Scheessel-Arty', mission='attack', template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Scheessel', type='surface', SetActiveMission = true}),

})

zones.hamburg:addGroups({
	GroupCommander:new({name='Hamburg-patrol-Hannover-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hannover', Altitude = CapAltitude()}),
	GroupCommander:new({name='Hamburg-patrol-Fassberg-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Fassberg', Altitude = CapAltitude()}),
	GroupCommander:new({name='Hamburg-patrol-Parchim-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Parchim', Altitude = CapAltitude()}),
	GroupCommander:new({name='Hamburg-attack-Bremen', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Bremen', Altitude = CasAltitude()}),
	GroupCommander:new({name='Hamburg-attack-Fassberg', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Fassberg', Altitude = CasAltitude()}),
	GroupCommander:new({name='Hamburg-attack-Hannover', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Hannover', Altitude = CasAltitude()}),
	GroupCommander:new({name='Hamburg-attack-Parchim', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Parchim', Altitude = CasAltitude(), diceChance=50}),
	GroupCommander:new({name='Hamburg-attack-Braunschweig', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Braunschweig', Altitude = CasAltitude()}),
	GroupCommander:new({name='Hamburg-supply-Scheessel', mission='supply', template='HeloSupplyTemplate', targetzone='Scheessel'}),
	GroupCommander:new({name='Hamburg-supply-Lubeck', mission='supply', template='HeloSupplyTemplate', targetzone='Lubeck'}),
	GroupCommander:new({name='Hamburg-supply-Bornholm', mission='supply', template='PlaneSupplyTemplate', targetzone='Bornholm'}),
	GroupCommander:new({name='Hamburg-attack-Lubeck-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Lubeck'}),
})

zones.lubeck:addGroups({
	GroupCommander:new({name='Lubeck-patrol-Templin-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Templin', Altitude = CapAltitude()}),
	GroupCommander:new({name='Lubeck-patrol-Fassberg-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Fassberg', Altitude = CapAltitude()}),
	GroupCommander:new({name='Lubeck-patrol-Scheessel-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Scheessel', Altitude = CapAltitude()}),
	GroupCommander:new({name='Lubeck-attack-Hannover-Cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Hannover', Altitude = CasAltitude()}),
	GroupCommander:new({name='Lubeck-supply-Hamburg', mission='supply', template='HeloSupplyTemplate', targetzone='Hamburg'}),
	GroupCommander:new({name='Lubeck-supply-Laage', mission='supply', template='HeloSupplyTemplate', targetzone='Laage'}),
	GroupCommander:new({name='Lubeck-attack-Hamburg-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Hamburg'}),
	GroupCommander:new({name='Lubeck-attack-Wismar-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Wismar', type='surface', SetActiveMission = true}),

})

zones.briest:addGroups({
	GroupCommander:new({name='Briest-supply-Mahlwinkel', mission='supply', template='HeloSupplyTemplate', targetzone='Mahlwinkel'}),
	GroupCommander:new({name='Briest-supply-Altes Lager', mission='supply', template='HeloSupplyTemplate', targetzone='Altes Lager'}),
	GroupCommander:new({name='Briest-attack-Mahlwinkel', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Mahlwinkel'})
})

zones.alteslager:addGroups({
    GroupCommander:new({name='Altes Lager-supply-Briest', mission='supply', template='HeloSupplyTemplate', targetzone='Briest'}),
    GroupCommander:new({name='Altes Lager-supply-Wundsdorf FARP', mission='supply', template='HeloSupplyTemplate', targetzone='Wundsdorf FARP'}),
    GroupCommander:new({name='Altes Lager-patrol-Schkeuditz-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Schkeuditz', Altitude = CapAltitude()}),
    GroupCommander:new({name='Altes Lager-attack-Schkeuditz-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Schkeuditz', Altitude = CapAltitude()}),
    GroupCommander:new({name='Altes Lager-attack-Schkeuditz-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Schkeuditz', Altitude = CasAltitude()}),
    GroupCommander:new({name='Altes-Lager-attack-Schkeuditz', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Schkeuditz'}),
	GroupCommander:new({name='Altes Lager-attack-Wundsdorf FARP-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Wundsdorf FARP'}),
})

zones.wundsdorffarp:addGroups({
GroupCommander:new({name='Wundsdorf FARP-supply-Altes Lager', mission='supply', template='SupplyConvoy', targetzone='Altes Lager', type='surface'}),
    GroupCommander:new({name='Wundsdorf FARP-attack-Tegel', mission='attack', template='AttackConvoy', targetzone='Tegel', type='surface'}),
    GroupCommander:new({name='Wundsdorf FARP-attack-Tegel-Arty', mission='attack', template='ArtilleryConvoyShort',MissionType='ARTY',Reward=250, targetzone='Tegel', type='surface'}),
    GroupCommander:new({name='Wundsdorf FARP-supply-Tegel', mission='supply', template='HeloSupplyTemplate', targetzone='Tegel'}),
	GroupCommander:new({name='Wundsdorf FARP-attack-Altes Lager-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Altes Lager'}),
	GroupCommander:new({name='Wundsdorf FARP-attack-Tegel-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Tegel'}), -- new
})

zones.tegel:addGroups({
    GroupCommander:new({name='Tegel-supply-Neuruppin', mission='supply', template='HeloSupplyTemplate', targetzone='Neuruppin'}),
    GroupCommander:new({name='Tegel-supply-Werneuchen', mission='supply', template='HeloSupplyTemplate', targetzone='Werneuchen'}),
    GroupCommander:new({name='Tegel-supply-SAM-India', mission='supply', template='SupplyConvoy', targetzone='SAM-India', type='surface', spawnDelayFactor = 3}),
    GroupCommander:new({name='Tegel-patrol-Mahlwinkel-Cap', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Mahlwinkel', Altitude = CapAltitude()}),
    GroupCommander:new({name='Tegel-patrol-Zerbst-Cap', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Zerbst', Altitude = CapAltitude()}),
    GroupCommander:new({name='Tegel-attack-Altes Lager-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Altes Lager', Altitude = CasAltitude()}),
    GroupCommander:new({name='Tegel-attack-Altes Lager-Sead', mission='attack', template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Altes Lager', Altitude = SeadAltitude()}),
    GroupCommander:new({name='Tegel-attack-Neuruppin-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Neuruppin'}),	-- new
    GroupCommander:new({name='Tegel-attack-Wundsdorf FARP-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Wundsdorf FARP'}), -- new
})


zones.werneuchen:addGroups({
    GroupCommander:new({name='Werneuchen-supply-Tegel', mission='supply', template='HeloSupplyTemplate', targetzone='Tegel'}),
    GroupCommander:new({name='Werneuchen-attack-Tegel', mission='attack', template='AttackConvoy', targetzone='Tegel', type='surface', diceChance = 50}),
	GroupCommander:new({name='werneuchen-attack-Zerbst-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Zerbst', Altitude = CasAltitude()}),
	GroupCommander:new({name='werneuchen-attack-Zerbst-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Zerbst', Altitude = SeadAltitude()}),
	GroupCommander:new({name='werneuchen-attack-Zerbst-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Zerbst', Altitude = CapAltitude()}),
	GroupCommander:new({name='werneuchen-attack-Zerbst-helocas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Wundsdorf FARP'}),

})


zones.neuruppin:addGroups({
    GroupCommander:new({name='Neuruppin-supply-Templin', mission='supply', template='HeloSupplyTemplate', targetzone='Templin'}),
    GroupCommander:new({name='Neuruppin-supply-Larz', mission='supply', template='HeloSupplyTemplate', targetzone='Larz'}),
    GroupCommander:new({name='Neuruppin-attack-Mahlwinkel-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Mahlwinkel', Altitude = CasAltitude()}),
    GroupCommander:new({name='Neuruppin-attack-Tegel-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Tegel', Altitude = CasAltitude()}),
    GroupCommander:new({name='Neuruppin-supply-SAM-Juliett', mission='supply', template='SupplyConvoy', targetzone='SAM-Juliett', type='surface', spawnDelayFactor = 3}),
	GroupCommander:new({name='Neuruppin-attack-Larz-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Larz'}),
	GroupCommander:new({name='Neuruppin-attack-Tegel-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Tegel'}),
	GroupCommander:new({name='Neuruppin-attack-Templin-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Templin'}),
	GroupCommander:new({name='Neuruppin-attack-Templin-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Templin', Altitude = CapAltitude()}), -- new
	GroupCommander:new({name='Neuruppin-patrol-Templin-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Templin', Altitude = CapAltitude()}),
	GroupCommander:new({name='Neuruppin-patrol-Neuruppin-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Neuruppin', Altitude = CapAltitude()}),
})

zones.templin:addGroups({
    GroupCommander:new({name='Templin-supply-Neuruppin', mission='supply', template='HeloSupplyTemplate', targetzone='Neuruppin'}),
	GroupCommander:new({name='Templin-attack-Neuruppin-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Neuruppin'}),
	GroupCommander:new({name='Templin-attack-Altes-Lager-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Altes Lager', Altitude = CasAltitude()}),
	GroupCommander:new({name='Templin-attack-Tegel-cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tegel', Altitude = CasAltitude()}),
	GroupCommander:new({name='Templin-attack-Altes-Lager-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Altes Lager', Altitude = CapAltitude()}),
	GroupCommander:new({name='Templin-patrol-Altes-Lager-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Altes Lager', Altitude = CapAltitude()}),
	GroupCommander:new({name='Templin-patrol-Mahlwinkel-cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mahlwinkel', Altitude = CapAltitude()}),
	GroupCommander:new({name='Templin-attack-Mahlwinkel-cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mahlwinkel', Altitude = CapAltitude()}),

	GroupCommander:new({name='Templin-patrol-Briest-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Briest', Altitude = CapAltitude()}),
	GroupCommander:new({name='Templin-attack-Briest-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Briest', Altitude = CapAltitude()}),
	GroupCommander:new({name='Templin-attack-Briest-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Briest', Altitude = CasAltitude()}),
	GroupCommander:new({name='Templin-attack-Briest-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Briest', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Templin-attack-Neuruppin-Arty',mission='attack',template='ArtilleryConvoyShort',MissionType='ARTY',Reward=250,targetzone='Neuruppin',type='surface',SetActiveMission=true,artilleryRangeNm=2}),


})

zones.larz:addGroups({
    GroupCommander:new({name='Larz-supply-Parchim', mission='supply', template='HeloSupplyTemplate', targetzone='Parchim'}),
    GroupCommander:new({name='Larz-supply-Neuruppin', mission='supply', template='HeloSupplyTemplate', targetzone='Neuruppin'}),
    GroupCommander:new({name='Larz-supply-Neubrandenburg', mission='supply', template='HeloSupplyTemplate', targetzone='Neubrandenburg'}),
    GroupCommander:new({name='Larz-patrol-Mahlwinkel-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Mahlwinkel', Altitude = CapAltitude()}),
    GroupCommander:new({name='Larz-patrol-Templin-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Templin', Altitude = CapAltitude()}),
    GroupCommander:new({name='Larz-attack-Templin-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Templin'}),
	GroupCommander:new({name='Larz-attack-Neubrandenburg-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Neubrandenburg'}),
	GroupCommander:new({name='Larz-attack-Neuruppin-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Neuruppin'}),
    
	GroupCommander:new({name='Larz-attack-Mahlwinkel-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Mahlwinkel', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Larz-attack-Werneuchen-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Werneuchen', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Larz-attack-Zerbst-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Zerbst', Altitude = SeadAltitude()}),

})

zones.parchim:addGroups({
    GroupCommander:new({name='Parchim-supply-Larz', mission='supply', template='HeloSupplyTemplate', targetzone='Larz'}),
    GroupCommander:new({name='Parchim-patrol-Parchim', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Parchim', Altitude = CapAltitude()}),
    GroupCommander:new({name='Parchim-attack-Larz-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Larz', diceChance = 50, Altitude = CasAltitude()}),
    GroupCommander:new({name='Parchim-supply-SAM-Kilo', mission='supply', template='SupplyConvoy', targetzone='SAM-Kilo',type='surface', spawnDelayFactor = 2, Redcondition=function() return CustomFlags["ParchimSupply"] ~= true end}),
    GroupCommander:new({name='Parchim-attack-Mahlwinkel', mission='attack', template='CasPlaneTemplate', targetzone='Mahlwinkel', Altitude = CasAltitude()}),
    GroupCommander:new({name='Parchim-patrol-Mahlwinkel', mission='patrol', template='CapPlaneTemplate', targetzone='Mahlwinkel', Altitude = CapAltitude()}),
    GroupCommander:new({name='Parchim-patrol-Briest', mission='patrol', template='CapPlaneTemplate', targetzone='Briest', Altitude = CapAltitude()}),
    GroupCommander:new({name='Parchim-attack-Briest', mission='attack', template='CapPlaneTemplate', targetzone='Briest', Altitude = CapAltitude()}),
})

zones.neubrandenburg:addGroups({
    GroupCommander:new({name='Neubrandenburg-supply-Larz', mission='supply', template='HeloSupplyTemplate', targetzone='Larz'}),
    GroupCommander:new({name='Neubrandenburg-supply-Tutow', mission='supply', template='HeloSupplyTemplate', targetzone='Tutow'}),
    GroupCommander:new({name='Neubrandenburg-attack-Neuruppin-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Neuruppin', Altitude = CasAltitude()}),
    GroupCommander:new({name='Neubrandenburg-attack-Templin-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Templin', Altitude = CasAltitude()}),
    GroupCommander:new({name='Neubrandenburg-attack-Larz-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Larz'}),
    GroupCommander:new({name='Neubrandenburg-patrol-Neubrandenburg-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Neubrandenburg', Altitude = CapAltitude()}),

})

zones.tutow:addGroups({
    GroupCommander:new({name='Tutow-supply-Garz', mission='supply', template='HeloSupplyTemplate', targetzone='Garz'}),
    GroupCommander:new({name='Tutow-supply-Laage', mission='supply', template='HeloSupplyTemplate', targetzone='Laage'}),
    GroupCommander:new({name='Tutow-supply-Peenemunde', mission='supply', template='HeloSupplyTemplate', targetzone='Peenemunde'}),
    GroupCommander:new({name='Tutow-supply-Neubrandenburg', mission='supply', template='HeloSupplyTemplate', targetzone='Neubrandenburg'}),
    GroupCommander:new({name='Tutow-patrol-Larz-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Larz', Altitude = CapAltitude()}),
    GroupCommander:new({name='Tutow-patrol-Laage-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Laage', Altitude = CapAltitude()}),
	GroupCommander:new({name='Tutow-attack-Peenemunde-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Peenemunde'}),
})

zones.laage:addGroups({
    GroupCommander:new({name='Laage-supply-Tutow', mission='supply', template='HeloSupplyTemplate', targetzone='Tutow'}),
    GroupCommander:new({name='Laage-attack-Parchim', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Parchim', Altitude = CasAltitude()}),
    GroupCommander:new({name='Laage-attack-Lubeck-Cas',template='CasPlaneTemplate',MissionType='CAS', mission='attack', targetzone='Lubeck', Altitude = CasAltitude(), condition=function() return zones.laage.side == zones.wismar.side end }), 
    GroupCommander:new({name='Laage-attack-Larz', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Larz', Altitude = CasAltitude()}),
    GroupCommander:new({name='Laage-supply-SAM-Lima', mission='supply', template='SupplyConvoy', targetzone='SAM-Lima', type='surface', spawnDelayFactor = 3}),
	GroupCommander:new({name='Laage-patrol-Lubeck-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Lubeck', Altitude=CapAltitude(), condition=function() return zones.laage.side == zones.wismar.side end }),    
	GroupCommander:new({name='Laage-patrol-Larz-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Larz', Altitude = CapAltitude()}),
    GroupCommander:new({name='Laage-patrol-Parchim-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Parchim', Altitude = CapAltitude()})
})

zones.wismar:addGroups({
    GroupCommander:new({name='Wismar-supply-Laage-Convoy', mission='supply',template='SupplyConvoy', targetzone='Laage',type='surface', Redcondition=function() return true end}),
    GroupCommander:new({name='Wismar-supply-Laage', mission='supply',template='HeloSupplyTemplate', targetzone='Laage', Bluecondition=function() return true end}),
    GroupCommander:new({name='Wismar-attack-Laage-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Laage', Altitude = CasAltitude()}),
	GroupCommander:new({name='Wismar-attack-Lubeck-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Lubeck', type='surface', SetActiveMission = true}),

})

zones.garz:addGroups({
    GroupCommander:new({name='Garz-attack-Neubrandenburg', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Neubrandenburg', Altitude = CasAltitude()}),
    GroupCommander:new({name='Garz-attack-Templin', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Templin', Altitude = CasAltitude()}),
    GroupCommander:new({name='Garz-patrol-Neuruppin-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Neuruppin', Altitude = CapAltitude()})
})

zones.peenemunde:addGroups({
	GroupCommander:new({name='Peenemunde-supply-Tutow', mission='supply', template='HeloSupplyTemplate', targetzone='Tutow'}),
    GroupCommander:new({name='Peenemunde-attack-Larz-RunwayStrike', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Larz', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name='Peenemunde-attack-Larz-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Larz', Altitude = SeadAltitude()}),
    GroupCommander:new({name='Peenemunde-attack-Templin-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Templin', Altitude = SeadAltitude()}),
    GroupCommander:new({name='Peenemunde-attack-Tutow-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Tutow'}),
})

zones.sturup:addGroups({
    GroupCommander:new({name='Sturup-supply-Bornholm', mission='supply',template='PlaneSupplyTemplate', targetzone='Bornholm'}),
    GroupCommander:new({name='Sturup-supply-Peenemunde', mission='supply',template='PlaneSupplyTemplate', targetzone='Peenemunde'}),
    GroupCommander:new({name='Sturup-attack-Garz-Cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Garz', Altitude = CapAltitude()}),
    GroupCommander:new({name='Sturup-attack-Kastrup City-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Kastrup City'}),
})

zones.bornholm:addGroups({
    GroupCommander:new({name='bornholm-supply-Peenemunde', mission='supply',template='HeloSupplyTemplate', targetzone='Peenemunde'}),
    GroupCommander:new({name='bornholm-attack-Laage-Cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Laage', Altitude = CapAltitude()}),
    GroupCommander:new({name='bornholm-attack-Neubrandenburg-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Neubrandenburg', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bornholm-attack-Neubrandenburg-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Neubrandenburg', Altitude = CasAltitude()}),
    GroupCommander:new({name='bornholm-patrol-Peenemunde-CAP', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Peenemunde', Altitude = CapAltitude()}),
    GroupCommander:new({name='bornholm-attack-Peenemunde-rwn', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Peenemunde', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name='bornholm-attack-Tutow-rwn', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Tutow', Altitude = RunwayStrikeAltitude()}),
})

zones.kastrup:addGroups({
    GroupCommander:new({name='Kastrup-supply-Bornholm', mission='supply',template='HeloSupplyTemplate', targetzone='Sturup'}),
    GroupCommander:new({name='Kastrup-attack-Bornholm-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Bornholm', Altitude = SeadAltitude()}),
    GroupCommander:new({name='Kastrup-attack-Bornholm-Cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Bornholm', Altitude = CapAltitude()}),
    GroupCommander:new({name='Kastrup-patrol-Bornholm-Cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Bornholm', Altitude = CapAltitude()}),
    GroupCommander:new({name='Kastrup-patrol-Bornholm-Cap-2', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Bornholm', Altitude = CapAltitude()}),
    GroupCommander:new({name='Kastrup-patrol-Sturup-Cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Sturup', Altitude = CapAltitude()}),
    GroupCommander:new({name='Kastrup-attack-Hamburg-rwn', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Hamburg', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name='Kastrup-attack-Lubeck-rwn', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Lubeck', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name='Kastrup-attack-Lubeck-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Lubeck', Altitude = CasAltitude()}),
    GroupCommander:new({name='Kastrup-attack-Lubeck-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Lubeck', Altitude = SeadAltitude()}),
    GroupCommander:new({name='Kastrup City-attack-Sturup-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Sturup'}),
})


for i,v in pairs(zones) do
	bc:addZone(v)
end

zones.bitburg.isHeloSpawn = true
zones.mendignorth.isHeloSpawn = true
zones.mendig.isHeloSpawn = true
zones.mendigeast.isHeloSpawn = true
zones.hahn.isHeloSpawn = true
zones.baddurkheim.isHeloSpawn = true
zones.walldorffarp.isHeloSpawn = true
zones.walldurnfarp.isHeloSpawn = true
zones.giebelstadt.isHeloSpawn = true
zones.laubachfarp.isHeloSpawn = true
zones.salzungenfarp.isHeloSpawn = true
zones.naumburgfarp.isHeloSpawn = true
zones.schkeuditz.isHeloSpawn = true
zones.wundsdorffarp.isHeloSpawn = true
zones.tegel.isHeloSpawn = true
zones.alteslager.isHeloSpawn = true
zones.scheessel.isHeloSpawn = true
zones.gelnhausen.isHeloSpawn = true
zones.airrcing.isHeloSpawn = true
zones.ramstein.isHeloSpawn = true
zones.spangdahlem.isHeloSpawn = true
zones.frankfurt.isHeloSpawn = true
zones.fulda.isHeloSpawn = true
zones.fritzlar.isHeloSpawn = true
zones.baumholderfarp.isHeloSpawn = true
zones.hannover.isHeloSpawn = true
zones.braunschweig.isHeloSpawn = true
zones.fassberg.isHeloSpawn = true
zones.bremen.isHeloSpawn = true
zones.hamburg.isHeloSpawn = true
zones.lubeck.isHeloSpawn = true
zones.laage.isHeloSpawn = true
zones.wismar.isHeloSpawn = true
zones.tutow.isHeloSpawn = true
zones.peenemunde.isHeloSpawn = true
zones.garz.isHeloSpawn = true
zones.neubrandenburg.isHeloSpawn = true
zones.parchim.isHeloSpawn = true
zones.mahlwinkel.isHeloSpawn = true
zones.bindersleben.isHeloSpawn = true
zones.zerbst.isHeloSpawn = true
zones.briest.isHeloSpawn = true
zones.neuruppin.isHeloSpawn = true
zones.larz.isHeloSpawn = true
zones.templin.isHeloSpawn = true
zones.werneuchen.isHeloSpawn = true

zones.spangdahlem.LogisticCenter = true
zones.bitburg.LogisticCenter = true
zones.bornholm.isHeloSpawn = true



zones.bitburg.airbaseName = 'Bitburg'
zones.spangdahlem.airbaseName = 'Spangdahlem'
zones.hahn.airbaseName = 'Hahn'
zones.mendig.airbaseName = 'Mendig'
zones.mendignorth.airbaseName = 'H FRG 34'
zones.mendigeast.airbaseName = 'H FRG 40'
zones.frankfurt.airbaseName = 'Frankfurt'	
zones.fritzlar.airbaseName = 'Fritzlar'	
zones.baumholderfarp.airbaseName = 'H FRG 51'
zones.airrcing.airbaseName = 'Airracing Frankfurt'
zones.ramstein.airbaseName = 'Ramstein'
zones.baddurkheim.airbaseName = 'Bad Durkheim'
zones.walldorffarp.airbaseName = 'Walldorf'
zones.walldurnfarp.airbaseName = 'H FRG 47'
zones.giebelstadt.airbaseName = 'Giebelstadt'
zones.gelnhausen.airbaseName = 'Gelnhausen'
zones.laubachfarp.airbaseName = 'H FRG 38'
zones.fulda.airbaseName = 'Fulda'
zones.salzungenfarp.airbaseName = 'H Med GDR 14'
zones.bindersleben.airbaseName = 'Bindersleben'
zones.naumburgfarp.airbaseName = 'H GDR 25'
zones.schkeuditz.airbaseName = 'Schkeuditz'
zones.zerbst.airbaseName = 'Zerbst'
zones.mahlwinkel.airbaseName = 'Mahlwinkel'	
zones.alteslager.airbaseName = 'Altes Lager'
zones.wundsdorffarp.airbaseName = 'H GDR 24'
zones.tegel.airbaseName = 'Tegel'
zones.werneuchen.airbaseName = 'Werneuchen'
zones.neuruppin.airbaseName = 'Neuruppin'
zones.templin.airbaseName = 'Templin'
zones.larz.airbaseName = 'Larz'
zones.parchim.airbaseName = 'Parchim'
zones.neubrandenburg.airbaseName = 'Neubrandenburg'
zones.tutow.airbaseName = 'Tutow'
zones.laage.airbaseName = 'Laage'
zones.peenemunde.airbaseName = 'Peenemunde'
zones.garz.airbaseName = 'Garz'
zones.braunschweig.airbaseName = 'Braunschweig'	
zones.hannover.airbaseName = 'Hannover'	
zones.fassberg.airbaseName = 'Fassberg'	
zones.scheessel.airbaseName = 'H FRG 17'
zones.bremen.airbaseName = 'Bremen'	
zones.hamburg.airbaseName = 'Hamburg'	
zones.bornholm.airbaseName = 'Bornholm'
zones.sturup.airbaseName = 'Sturup'
zones.kastrup.airbaseName = 'Kastrup'
zones.briest.airbaseName = 'Briest'
zones.wismar.airbaseName = 'Wismar'
zones.lubeck.airbaseName = 'Lubeck'


bc:addConnection("Bitburg","Spangdahlem")
bc:addConnection("Spangdahlem","Hahn")
bc:addConnection("Hahn","Airracing Frankfurt")
bc:addConnection("Hahn","Mendig")
bc:addConnection("Mendig","Mendig North FARP")
bc:addConnection("Mendig North FARP","Mendig East FARP")
bc:addConnection("Hahn","Baumholder FARP")
bc:addConnection("Baumholder FARP","SAM-Alpha")
bc:addConnection("Hahn","Airracing Frankfurt")
bc:addConnection("Airracing Frankfurt","Frankfurt")
bc:addConnection("Frankfurt","Fritzlar")
bc:addConnection("Fritzlar","Scheiße Factory")
bc:addConnection("Frankfurt","Gelnhausen")
bc:addConnection("Gelnhausen","SAM-Bravo")
bc:addConnection("Gelnhausen","Laubach FARP")
bc:addConnection("Laubach FARP","Fulda")
bc:addConnection("Fulda","Salzungen FARP")
bc:addConnection("Salzungen FARP","SAM-Charlie")
bc:addConnection("Salzungen FARP","Bindersleben")
bc:addConnection("Bindersleben","Naumburg FARP")
bc:addConnection("Naumburg FARP","Schkeuditz")
bc:addConnection("Schkeuditz","Zerbst")
bc:addConnection("Schkeuditz","SAM-Delta")
bc:addConnection("Schkeuditz","Chemical Factory")
bc:addConnection("Zerbst","Mahlwinkel")
bc:addConnection("Mahlwinkel","Braunschweig")
bc:addConnection("Mahlwinkel","SAM-Echo")
bc:addConnection("Braunschweig","Hannover")
bc:addConnection("Hannover","Fassberg")
bc:addConnection("Hannover","SAM-Golf")
bc:addConnection("Hannover","SAM-Foxtrot")
bc:addConnection("Fassberg","Scheessel")
bc:addConnection("Scheessel","Bremen")
bc:addConnection("Scheessel","Hamburg")
bc:addConnection("Scheessel","SAM-Hotel")
bc:addConnection("Bremen","SAM-Hotel")
bc:addConnection("Hamburg","Lubeck")
bc:addConnection("Mahlwinkel","Briest")
bc:addConnection("Briest","Altes Lager")
bc:addConnection("Briest","SAM-India")
bc:addConnection("Altes Lager","Wundsdorf FARP")
bc:addConnection("Wundsdorf FARP","Tegel")
bc:addConnection("Tegel","Werneuchen")
bc:addConnection("Tegel","Neuruppin")
bc:addConnection("Neuruppin","Templin")
bc:addConnection("Neuruppin","SAM-Juliett")
bc:addConnection("Neuruppin","Larz")
bc:addConnection("Larz","Parchim")
bc:addConnection("Parchim","SAM-Kilo")
bc:addConnection("Larz","Neubrandenburg")
bc:addConnection("Neubrandenburg","Tutow")
bc:addConnection("Tutow","Laage")
bc:addConnection("Laage","SAM-Lima")
bc:addConnection("Laage","Wismar")
bc:addConnection("Lubeck","Wismar")
bc:addConnection("Tutow","Peenemunde")
bc:addConnection("Tutow","Garz")

bc:addConnection("Peenemunde","Östersjön")
bc:addConnection("Östersjön","Bornholm")
bc:addConnection("Östersjön","Sturup")
bc:addConnection("Bornholm","Sturup")
bc:addConnection("Sturup","Kastrup City")

bc:addConnection("Baumholder FARP","Ramstein")
bc:addConnection("Ramstein","Bad Durkheim")
bc:addConnection("Bad Durkheim","Walldorf FARP")
bc:addConnection("Walldorf FARP","Walldurn FARP")
bc:addConnection("Walldurn FARP","Giebelstadt")
bc:addHiddenConnection("Peenemunde","Bornholm")



zones.samalpha:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesamalpha')


zones.sambravo:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesambravo')

zones.samcharlie:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesamcharlie')

zones.samdelta:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesamdelta')

zones.samecho:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesamecho')

zones.samfoxtrot:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesamfoxtrot')

zones.samgolf:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesamgolf')

zones.samhotel:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesamhotel')

zones.samindia:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesamindia')

zones.samjuliett:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesamjuliett')

zones.samkilo:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesamkilo')

zones.samlima:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesamlima')

zones.sammike:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SAM_DESTROYED"),20)
end, 'disablesammike')

zones.sheizefactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_SCHEISSE_FACTORY_DESTROYED"),20)
end, 'disablesheizefactory')

zones.chemicalfactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_CHEMICAL_FACTORY_DESTROYED"),20)
end, 'disableschemicalfactory')

zones.redarmycamp:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_RED_ARMY_CAMP_DESTROYED"),20)
end, 'disablesredarmycamp')

zones.insurgencycamp:registerTrigger('lost', function(event, sender) 
	sender:disableZone(true)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_RED_ARMY_CAMP_DESTROYED"),20)
end, 'disablesredarmycamp')

------------------------------ capture attack events ------------------------------


Group.getByName('Hahn-arty-Attack-Group'):destroy()
zones.hahn:registerTrigger('captured', function(_, zone)
    if zone ~= zones.hahn then return end
	local kr = bc:getZoneByName('Hahn')
	if kr.side == 2 and not CustomFlags['hahncaptured'] then
		if not IsGroupActive('Hahn-arty-Attack-Group') then
			Respawn.Group('Hahn-arty-Attack-Group')
            CustomFlags['hahncaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, L10N:Get("COLDWAR_EVENT_HAHN_ARTY_ATTACK"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 180)
		end
	
    timer.scheduleFunction(function()
    trigger.action.outTextForCoalition(2, L10N:Get("COLDWAR_EVENT_HAHN_ARTY_FOUND"), 30)
    end, {}, timer.getTime() + math.random(360, 480))
end
end, 'hahncaptured')


Group.getByName('Salzungen FARP-attack-Fulda'):destroy()
zones.fulda:registerTrigger('captured', function(_, zone)
    if zone ~= zones.fulda then return end
	local kr = bc:getZoneByName('Fulda')
	if kr.side == 2 and not CustomFlags['fuldacaptured'] then
		if not IsGroupActive('Salzungen FARP-attack-Fulda') then
			Respawn.Group('Salzungen FARP-attack-Fulda')
            CustomFlags['fuldacaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, L10N:Get("COLDWAR_EVENT_FULDA_HELO_ATTACK"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 60)
		end
	end
end, 'fuldacaptured')

Group.getByName('Schkeuditz-Sead-Attack'):destroy()
Group.getByName('Schkeuditz-Sead-Attack-Coldwar'):destroy()
Group.getByName('Schkeuditz-bomb-Attack'):destroy()
zones.schkeuditz:registerTrigger('captured', function(_, zone)
    if zone ~= zones.schkeuditz then return end
	local kr = bc:getZoneByName('Schkeuditz')
	if kr.side == 2 and not CustomFlags['schkeuditzcaptured'] then
		if not IsGroupActive('Schkeuditz-Sead-Attack') then
			Respawn.Group('Schkeuditz-bomb-Attack')
            local seadGrp = (Era=='Coldwar') and 'Schkeuditz-Sead-Attack-Coldwar' or 'Schkeuditz-Sead-Attack'
            Respawn.Group(seadGrp)
            CustomFlags['schkeuditzcaptured'] = true
            timer.scheduleFunction(function()
            local bomber = StartBomberAuftrag('SchkeuditzBomber', 'Schkeuditz-bomb-Attack', "Schkeuditz", nil)
            trigger.action.outTextForCoalition(2, L10N:Get("COLDWAR_EVENT_SCHKEUDITZ_ASSAULT"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 10)
		end
	end
end, 'schkeuditzcaptured')

Group.getByName('Mahlwinkel-arty-Attack-Group'):destroy()
Group.getByName('Mahlwinkel-CAS-Attack-Group'):destroy()
Group.getByName('Mahlwinkel-CAS-Attack-Group 2'):destroy()
zones.mahlwinkel:registerTrigger('captured', function(_, zone)
    if zone ~= zones.mahlwinkel then return end
	local kr = bc:getZoneByName('Mahlwinkel')
	if kr.side == 2 and not CustomFlags['mahlwinkelcaptured'] then
		if not IsGroupActive('Mahlwinkel-arty-Attack-Group') then
			Respawn.Group('Mahlwinkel-arty-Attack-Group')
			Respawn.Group('Mahlwinkel-CAS-Attack-Group')
			Respawn.Group('Mahlwinkel-CAS-Attack-Group 2')
            CustomFlags['mahlwinkelcaptured'] = true
            timer.scheduleFunction(function()
            --trigger.action.outTextForCoalition(2, "The enemy have launched an assault on Mahlwinkel!!\n\nThey have deployed long range Artillery and unknown bandits inbound!", 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
			RegisterGroupTarget('Mahlwinkel-arty-Attack-Group',250,L10N:Get("COLDWAR_TARGET_MAHLWINKEL_ARTILLERY"),'Mahlwinkel-arty-Attack-Group',true)
            end, {}, timer.getTime() + 60)
		end
	
    timer.scheduleFunction(function()
    trigger.action.outTextForCoalition(2, L10N:Get("COLDWAR_EVENT_MAHLWINKEL_ARTY_FOUND"), 30)
        end, {}, timer.getTime() + math.random(360, 480))
    end
end, 'mahlwinkelcaptured')

Group.getByName('Breman-Forces-attack 2'):destroy()
Group.getByName('Breman-Forces-attack'):destroy()
zones.bremen:registerTrigger('captured', function(_, zone)
    if zone ~= zones.bremen then return end
	local kr = bc:getZoneByName('Bremen')
	if kr.side == 2 and not CustomFlags['bremencaptured'] then
		if not IsGroupActive('Breman-Forces-attack') then
			Respawn.Group('Breman-Forces-attack')
			Respawn.Group('Breman-Forces-attack 2')
            CustomFlags['bremencaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, L10N:Get("COLDWAR_EVENT_BREMEN_AMBUSH"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 10)
		end
	end
end, 'bremencaptured')

Group.getByName('Tegel-Attack-Group'):destroy()
zones.larz:registerTrigger('captured', function(_, zone)
    if zone ~= zones.tegel then return end
	local kr = bc:getZoneByName('Tegel')
	if kr.side == 2 and not CustomFlags['tegelcaptured'] then
		if not IsGroupActive('Tegel-Forces-attack') and zones.neuruppin.wasBlue then
			Respawn.Group('Tegel-Forces-attack')
            CustomFlags['tegelcaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, L10N:Get("COLDWAR_EVENT_NEURUPPIN_ARTY_BRACE"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 60)
		end
	end
end, 'tegelcaptured')

Group.getByName('Neuruppin-Attack-Group'):destroy()
zones.larz:registerTrigger('captured', function(_, zone)
    if zone ~= zones.neuruppin then return end
	local kr = bc:getZoneByName('Neuruppin')
	if kr.side == 2 and not CustomFlags['neuruppincaptured'] then
		if not IsGroupActive('Neuruppin-Forces-attack') then
            if zones.larz.side == 1 then
			Respawn.Group('Neuruppin-Forces-attack')
            end
            if zones.templin.side == 1 then
            Respawn.Group('Neuruppin-Attack-Group-2')
            end
            CustomFlags['neuruppincaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, L10N:Get("COLDWAR_EVENT_NEURUPPIN_GROUND_ASSAULT"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 60)
		end
	end
end, 'neuruppincaptured')

Group.getByName('Larz-Forces-attack'):destroy()
zones.larz:registerTrigger('captured', function(_, zone)
    if zone ~= zones.larz then return end
	local kr = bc:getZoneByName('Larz')
	if kr.side == 2 and not CustomFlags['larzcaptured'] then
		if not IsGroupActive('Larz-Forces-attack') then
			Respawn.Group('Larz-Forces-attack')
            CustomFlags['larzcaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, L10N:Get("COLDWAR_EVENT_LARZ_SCUD_BRACE"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 60)
		end
	end
end, 'larzcaptured')



missions = {
        ["Baumholder FARP"] = {	
        zone = "Baumholder FARP",
        missionGroup = "BaumholderFARPEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Baumholder FARP"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Baumholder FARP"),
        TargetZone = "Ramstein",
        radius = 1000,
        MissionType = "Escort",
        flag = 101,
		ActivateZone = "hiddenground6"
    },
    ["Bad Durkheim"] = {	
        zone = "Bad Durkheim",
        missionGroup = "BadDurkheimEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Bad Durkheim"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Bad Durkheim"),
        TargetZone = "Walldorf FARP",
		radius = 2000,
        MissionType = "Escort",
		flag = 101,
		ActivateZone = "hiddenground7"
    },
    ["Gelnhausen"] = {	
        zone = "Gelnhausen",
        missionGroup = "GelnhausenEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Gelnhausen"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Gelnhausen"),
        TargetZone = "Walldorf FARP",
		radius = 5,
        MissionType = "Escort",
		flag = 111,
		ActivateZone = "hiddenground12"
    },
    ["Walldurn FARP"] = {	
        zone = "Walldurn FARP",
        missionGroup = "WalldurnFarpEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "WalldurnFarp"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "WalldurnFarp"),
        TargetZone = "Giebelstadt",
        radius = 5,
        MissionType = "Escort",
		flag = 121,
		ActivateZone = "hiddenground8"
    },
    ["Laubach FARP"] = {	
        zone = "Laubach FARP",
        missionGroup = "LaubachFARPEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Laubach FARP"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Laubach FARP"),
        TargetZone = "Fulda",
        radius = 2000,
        MissionType = "Escort",
		flag = 131,
		ActivateZone = "hiddenground13"
    },
    ["Altes Lager"] = {	
        zone = "Altes Lager",
        missionGroup = "AltesLagerEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Altes Lager"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Altes Lager"),
        TargetZone = "Wundsdorf FARP",
        radius = 5,
        MissionType = "Escort",
		flag = 141,
		ActivateZone = "hiddenground9"
    },
    ["Wundsdorf FARP"] = {	
        zone = "Wundsdorf FARP",
        missionGroup = "WundsdorfFARPEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Wundsdorf FARP"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Wundsdorf FARP"),
        TargetZone = "Tegel",
        radius = 5,
        MissionType = "Escort",
		flag = 151,
		ActivateZone = "hiddenground10"
    },
    ["Tegel"] = {	
        zone = "Tegel",
        missionGroup = "TegelEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Tegel"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Tegel"),
        TargetZone = "Werneuchen",
        radius = 5,
        MissionType = "Escort",
        flag = 161,
		ActivateZone = "hiddenground11"
    },
    ["Scheessel"] = {	
        zone = "Scheessel",
        missionGroup = "ScheesselEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Scheessel"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Scheessel"),
        TargetZone = "Bremen",
        radius = 5,
        MissionType = "Escort",
        flag = 171,
		ActivateZone = "hiddenground15"
    },
    ["Naumburg FARP"] = {	
        zone = "Naumburg FARP",
        missionGroup = "NaumburgFARPEscortGroup",
        menuTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Naumburg FARP"),
        missionTitle = LTFormat("CA_MISSION_GROUND_ESCORT_TITLE", "Naumburg FARP"),
        TargetZone = "Schkeuditz",
        radius = 5,
        MissionType = "Escort",
        flag = 181,
		ActivateZone = "hiddenground14"
    },
}
for _, data in pairs(missions) do
    if data.missionGroup and Group.getByName(data.missionGroup) then
        Group.getByName(data.missionGroup):destroy()
    else
        env.info("Mission group not found: " .. data.missionGroup)
        trigger.action.outText("Mission group not found: " .. data.missionGroup, 15)
    end
end
function SpawnFriendlyAssets()

    if zones.hannover.wasBlue and IsGroupActive('Grisha Fixed') then
        destroyGroupIfActive('Grisha Fixed')
    end
    if zones.ostersjon.side == 2 then
        if not IsGroupActive('CVN-72') then
            activateGroupIfNotActive('CVN-72')
            timer.scheduleFunction(function()
            checkWeaponsList('CVN-72')
			refreshBeacons()
        end, {}, timer.getTime() + 5)
        end
    end

	if zones.peenemunde.side == 2 or zones.ostersjon.side == 0 then
		zones.hiddensweden:MakeZoneRedAndUpgrade()
	end

 	if not zones.sammike.isAwaken and zones.peenemunde.side == 2 and not peenemundeStarted then
		peenemundeStarted = true
		timer.scheduleFunction(function()
		zones.sammike:AwakenZoneAndUpgrade()
		trigger.action.outTextForCoalition(2, L10N:Get("COLDWAR_EVENT_SAM_MIKE_INTEL"), 30)
		trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
		bc:addConnection("Peenemunde", "SAM-Mike")
		bc:buildConnectionMap()
		bc:RefreshConnectionsLines("Peenemunde")
		end, {}, timer.getTime() + 30)
	end

	if not zones.insurgencycamp.isAwaken and zones.parchim.side == 2 and not zones.samkilo.active and not insurgencycampStarted then
		insurgencycampStarted = true
		timer.scheduleFunction(function()
		zones.insurgencycamp:AwakenZoneAndUpgrade()
		trigger.action.outTextForCoalition(2, L10N:Get("COLDWAR_EVENT_INSURGENCY_CAMP_INTEL"), 30)
		trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
		bc:addConnection("Parchim", "Insurgency Camp")
		bc:buildConnectionMap()
		bc:RefreshConnectionsLines("Parchim")
		end, {}, timer.getTime() + 30)
	end

end


timer.scheduleFunction(SpawnFriendlyAssets, {}, timer.getTime() + 5)


function checkAndDisableFriendlyZones()

  if zones.frankfurt.wasBlue and not CustomFlags['hiddenground2'] then
            zones.hiddenground2:MakeZoneRedAndUpgrade()
            CustomFlags['hiddenground2'] = true
    end
    if zones.bindersleben.wasBlue and not CustomFlags['hiddenground3'] then
            zones.hiddenground3:MakeZoneRedAndUpgrade()
            CustomFlags['hiddenground3'] = true
    end
    if zones.zerbst.wasBlue and not CustomFlags['hiddenground4'] then
            zones.hiddenground4:MakeZoneRedAndUpgrade()
            CustomFlags['hiddenground4'] = true
    end
    if zones.tegel.wasBlue and not CustomFlags['hiddenground5'] then
            zones.hiddenground5:MakeZoneRedAndUpgrade()
            CustomFlags['hiddenground5'] = true
    end
    if zones.baddurkheim.wasBlue and zones.ramstein.wasBlue and zones.giebelstadt.wasBlue and zones.hiddenground1.side == 1 then
        zones.hiddenground1:DestroyHiddenZone()
    end
    if zones.bindersleben.wasBlue and zones.hiddenground2.side == 1 then
        zones.hiddenground2:DestroyHiddenZone()
    end
    if zones.zerbst.wasBlue and zones.hiddenground3.side == 1 then
        zones.hiddenground3:DestroyHiddenZone()
    end
    if zones.werneuchen.wasBlue and zones.hiddenground4.side == 1 then
        zones.hiddenground4:DestroyHiddenZone()
    end
end
timer.scheduleFunction(checkAndDisableFriendlyZones, {}, timer.getTime() + 10)



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
					if WarehouseLogistics == true then
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


SCHEDULER:New(nil,function()
	checkMissionComplete(nil, nil)
    if Era == 'Coldwar' then
    bc:roamGroupsToLocalSubZone({
        "Red Armor Group6 #",
        "Red Armor Group7 #",
        "Red Armor Group8 #",
		"Red SAM AAA #",
		"Red SAM AAA 2 #",
		"Red SAM AAA 5 #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-19 #",
		"Red SAM SHORAD SA-13 #",
		"Red SAM SHORAD SA-9 #",
		"Grisha #",
		"Molniya #",
		"Rezky #",
	}, 30, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
else
	bc:roamGroupsToLocalSubZone({
		"Red Armour Group #",
        "Red Armour Group 2 #",
        "Red Armour Group 3 #",
		"Red SAM AAA #",
		"Red SAM AAA 2 #",
		"Red SAM AAA 5 #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-19 #",
		"Red SAM SHORAD SA-13 #",
		"Red SAM SHORAD SA-9 #",
		"Red SAM SHORAD Tor M2 #",
		"Grisha #",
		"Molniya #",
		"Rezky #",
	}, 30, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
end
end,{},5,0)

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
Group.getByName('ca-tanks-Coldwar'):destroy()
Group.getByName('ca-tanks'):destroy()
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

local jtacDrones
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
bc.shopItems['airdef'].groupZoneSelector = {
	targetzoneside = 2,
	includeSuspended = false,
	sortPolicy = 'friendly_frontline',
	extraPredicate = function(zoneObj)
		return not isCarrierZoneName(zoneObj.zone)
	end,
	emptyLabel = LTGet("SYRIA_SHOP_NO_VALID_FRIENDLY_ZONES"),
}
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

------------------------------------ START own 9 line jtac AM START ----------------------------------
jtacZones = {}
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

-- new menu
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
local RED_ZONE_UPGRADE_ID = "redzoneupgrade"
local RED_ZONE_UPGRADE_COST = 3000

bc:registerShopItem(RED_ZONE_UPGRADE_ID, LTGet("SYRIA_SHOP_ITEM_RED_ZONE_UPGRADE"), RED_ZONE_UPGRADE_COST, function(sender)
	return bc:redZoneUpgradeAction()
end)

local RED_MASS_ATTACK_ID = "redmassattack"
local RED_MASS_ATTACK_COST = 4000

local function redMassAttackAction()
	if not bc.triggerRedMassAttack then
		return LTGet("SYRIA_SHOP_MASS_ATTACK_UNAVAILABLE")
	end
	return bc:triggerRedMassAttack()
end

bc:registerShopItem(RED_MASS_ATTACK_ID, LTGet("SYRIA_SHOP_ITEM_RED_MASS_ATTACK"), RED_MASS_ATTACK_COST, redMassAttackAction)

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
		params.zone:addExtraSlot((Era == 'Coldwar') and 'blueHAWK Coldwar' or 'bluePD1')
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
supplyZones = {
    'Bitburg',
    'Spangdahlem',
    'Hahn',
    'Airracing Frankfurt',
    'Mendig',
    'Mendig North FARP',
    'Mendig East FARP',
    'Baumholder FARP',
    'Ramstein',
    'Bad Durkheim',
    'Walldorf FARP',
    'Walldurn FARP',
    'Giebelstadt',
    'Frankfurt',
    'Gelnhausen',
    'Laubach FARP',
    'Fulda',
    'Fritzlar',
    'Salzungen FARP',
    'Bindersleben',
    'Naumburg FARP',
    'Schkeuditz',
    'Zerbst',
    'Mahlwinkel',
    'Briest',
    'Altes Lager',
    'Wundsdorf FARP',
    'Tegel',
    'Werneuchen',
    'Templin',
    'Neuruppin',
    'Hannover',
    'Scheessel',
    'Bremen',
    'Hamburg',
    'Braunschweig',
    'Fassberg',
    'Lubeck',
    'Laage',
    'Tutow',
    'Peenemunde',
    'Garz',
    'Neubrandenburg',
    'Parchim',
    'Larz',
    'Bornholm',
    'Sturup',
    'Kastrup City',
	'Wismar',
	'Östersjön',
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

if zones.redarmycamp.side == 1 then
bc:addConnection("Mahlwinkel", "Red Army Camp")
end
if zones.sammike.side == 1 then
bc:addConnection("Peenemunde", "SAM-Mike")
end
if zones.insurgencycamp.side == 1 then
bc:addConnection("Parchim", "Insurgency Camp")
end

bc:init()
budgetAI = BudgetCommander:new({ battleCommander = bc, side=1, decissionFrequency=20*60, decissionVariance=10*60, skipChance = 10})
budgetAI:init()
RewardContribution = RewardContribution or {infantry = 10, ground = 10, sam = 30, airplane = 50, ship = 200, helicopter=50, crate=100, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, structure = 100}
bc:startRewardPlayerContribution(15,RewardContribution)
bc:buildZoneDistanceCache()
buildTemplateCache()
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
local HuntNumber = SplashDamage and math.random(10,20) or math.random(8,16)
bc:initHunter(HuntNumber)
SCHEDULER:New(nil, function() bc:_buildHunterBaseList() end, {}, 1)

SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 3)
SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 4)

AWACS_CFG = {
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=100 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=60 }   -- blue
}

GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 110   		-- suspend red zones deeper than this nm

evc = EventCommander:new({ decissionFrequency=10*60, decissionVariance=10*60, skipChance = 10})
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


--------------------------------------------------- EVENT Intercept Bombers --------------------------------------------------------
local bomb_COOLDOWN = 1800
local lastbomb_COOLDOWN  = -bomb_COOLDOWN
local currentOrigin = "west"
local bomberChoices = {
	{bomber='evt-bomb',escort=Era=='Coldwar' and 'EscortBomberCW' or 'EscortBomber',origin='west'},
	{bomber='evt-bomb-east',escort=Era=='Coldwar' and 'EscortBomberEastCW' or 'EscortBomberEast',origin='east'}
}
for _,v in ipairs(bomberChoices) do
	local g=Group.getByName(v.bomber)
	if g then g:destroy() end
end
evc:addEvent({
	id='bomb',
	action=function()
		local choice=bomberChoices[math.random(#bomberChoices)]
		local bomberGrp=choice.bomber
		local escortGrp=choice.escort
		currentOrigin=choice.origin
		RespawnGroup(bomberGrp)
        RegisterGroupTarget(bomberGrp,250,L10N:Get("COLDWAR_TARGET_INTERCEPT_BOMBERS"),'bomb')
		timer.scheduleFunction(function()
            RespawnGroup(escortGrp)
        local tgts = {
        'Bitburg','Spangdahlem','Hahn','Mendig','Mendig North FARP',
        'Mendig East FARP','Baumholder FARP','Ramstein','Bad Durkheim',
        'Walldorf FARP','Walldurn FARP','Giebelstadt','Airracing Frankfurt',
        'Frankfurt','Fritzlar','Gelnhausen','Laubach FARP','Fulda',
        'Salzungen FARP','Bindersleben','Naumburg FARP','Schkeuditz','Zerbst',
        'Mahlwinkel','Braunschweig','Hannover','Fassberg','Scheessel','Bremen','Hamburg','Lubeck','Briest',
        'Altes Lager','Wundsdorf FARP','Tegel','Werneuchen','Neuruppin','Templin','Larz','Parchim','Neubrandenburg',
        'Tutow','Laage','Garz','Peenemunde'}
					if Group.getByName('evt-bomber') then
						local bomber, bomberMission = StartBomberAuftrag('bomb', bomberGrp, tgts, escortGrp)
				end
		end,{},timer.getTime()+1)
	end,
    canExecute=function()
        if ActiveMission['bomb'] then return false end
		if timer.getTime()-lastbomb_COOLDOWN<bomb_COOLDOWN then return false end
		if Group.getByName('evt-bomb') or Group.getByName('evt-bomb-east') then return false end
		if math.random(1,100)<20 then return false end
		local triggers={'Frankfurt','Schkeuditz','Larz','Tutow','Hamburg','Braunschweig','Mahlwinkel','Fassberg'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end
		end
		return false
	end
})

function startBomberAttack(bomberGrp)
local tgts = {
  'Bitburg','Spangdahlem','Hahn','Mendig','Mendig North FARP',
  'Mendig East FARP','Baumholder FARP','Ramstein','Bad Durkheim',
  'Walldorf FARP','Walldurn FARP','Giebelstadt','Airracing Frankfurt',
  'Frankfurt','Fritzlar','Gelnhausen','Laubach FARP','Fulda',
  'Salzungen FARP','Bindersleben','Naumburg FARP','Schkeuditz','Zerbst',
  'Mahlwinkel','Braunschweig','Hannover','Fassberg','Scheessel',
  'Bremen','Hamburg','Lubeck','Briest','Altes Lager',
  'Wundsdorf FARP','Tegel','Werneuchen','Neuruppin','Templin',
  'Larz','Parchim','Neubrandenburg','Tutow','Laage','Garz',
  'Peenemunde'
}
	local validtgts={}
	for _,v in ipairs(tgts) do
		if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then
			table.insert(validtgts,v)
		end
	end
	if #validtgts>0 then
		local choice=validtgts[math.random(#validtgts)]
		BASE:I("Chosen target: "..choice)
		if Group.getByName(bomberGrp) then
			bc:carpetBombRandomUnitInZone(choice,bomberGrp)
		end
	else
		BASE:I("No valid targets found for bomber attack.")
	end
end

mc:trackMission({
	title=LTGet("COLDWAR_MISSION_INTERCEPT_BOMBERS_TITLE"),
	description=function(T) return LT(T):Format("COLDWAR_MISSION_INTERCEPT_BOMBERS_DESC", currentOrigin) end,
	messageStart=function(T) return LT(T):Format("COLDWAR_MISSION_INTERCEPT_BOMBERS_START", currentOrigin) end,
	messageEnd=function(T) lastbomb_COOLDOWN=timer.getTime() return LT(T):Get("COLDWAR_MISSION_INTERCEPT_BOMBERS_END") end,
	startAction=function()
		if not missionCompleted and trigger.misc.getUserFlag(180)==0 then
			trigger.action.outSoundForCoalition(2,"ding.ogg")
		end
	end,
	endAction=function()
		if not missionCompleted and trigger.misc.getUserFlag(180)==0 then
			trigger.action.outSoundForCoalition(2,"cancel.ogg")
		end
	end,
    isActive=function()
        if not ActiveMission['bomb'] then return false end
        if Group.getByName('evt-bomb') then return true end
        if Group.getByName('evt-bomb-east') then return true end
        ActiveMission['bomb'] = nil
        return false
    end
})
--------------------------------------------------- END OF EVENT Intercept Bombers --------------------------------------------------------

------------------------------------------------------ EVENT Intercept enemy airstrike --------------------------------------------------------
local airstrike_COOLDOWN = 1800
local lastairstrike_COOLDOWN  = -airstrike_COOLDOWN
local attackGrp = Era=='Coldwar' and 'evt-attackcw' or 'evt-attack'
Group.getByName('evt-attack'):destroy()
Group.getByName('evt-attackcw'):destroy()
evc:addEvent({
	id='cas',
	action=function()
		RespawnGroup(attackGrp)
        RegisterGroupTarget(attackGrp,250,L10N:Get("COLDWAR_TARGET_INTERCEPT_BOMBERS"),'cas')
		timer.scheduleFunction(function()
			local tgts={'Frankfurt','Bindersleben','Schkeuditz','Zerbst','Mahlwinkel','Ramstein','Neubrandenburg','Laage','Hamburg','Larz','Fassberg'}
			local valid={}
			for _,v in ipairs(tgts) do
				if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then valid[#valid+1]=v end
			end
			if #valid~=0 then
				local choice=valid[math.random(1,#valid)]
				if Group.getByName(attackGrp) then bc:engageZone(choice,attackGrp) end
			end
		end,{},timer.getTime()+3)
	end,
    canExecute=function()
        if ActiveMission['cas'] then return false end
        if timer.getTime()-lastairstrike_COOLDOWN<airstrike_COOLDOWN then return false end
		if Group.getByName(attackGrp) then return false end
		if math.random(1,100)<50 then return false end
		if bc:getZoneByName('Peenemunde').side~=1 or bc:getZoneByName('Peenemunde').suspended then return false end
		local triggers={'Frankfurt','Bindersleben','Mahlwinkel','Larz','Fassberg'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end
		end
		return false
	end
})

mc:trackMission({
	title = LTGet("COLDWAR_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),
	description = LTGet("COLDWAR_MISSION_INTERCEPT_AIRSTRIKE_DESC"),
	messageStart = LTGet("COLDWAR_MISSION_INTERCEPT_AIRSTRIKE_START"),
	messageEnd =function(T) lastairstrike_COOLDOWN=timer.getTime() return LT(T):Get("COLDWAR_MISSION_INTERCEPT_AIRSTRIKE_END") end,
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

------------------------------------------------------ Defend Missions --------------------------------------------------------
local FRANKFURT_COOLDOWN = 1800
local lastFrankfurtEnd   = -FRANKFURT_COOLDOWN
FrankfurtForce = {
    ['Bindersleben'] = {
        Era=='Coldwar' and 'Bindersleben-Attack-Frankfurt-Event ColdWar'
                       or 'Bindersleben-Attack-Frankfurt-Event'
    },
    ['Schkeuditz'] = {
        Era=='Coldwar' and 'Schkeuditz-Frankfurt-Bomber ColdWar'
                       or 'Schkeuditz-Frankfurt-Bomber'
    },
	['Fulda'] = { 'Fulda-attack-frankfurt-event' },
    
}
for i,v in pairs(FrankfurtForce) do
	for _,v2 in ipairs(v) do
		Group.getByName(v2):destroy()
	end
end
evc:addEvent({
	id='FrankfurtAttack',
	action = function()
		for i,v in pairs(FrankfurtForce) do
			if bc:getZoneByName(i).side == 1 then
				for _,v2 in ipairs(v) do
					RespawnGroup(v2)
				end
			end
		end
	end,
	canExecute = function()
        if timer.getTime() - lastFrankfurtEnd < FRANKFURT_COOLDOWN then return false end
		if math.random(1,100) < 30 then return false end
		
		if bc:getZoneByName('Frankfurt').side ~= 2 or bc:getZoneByName('Frankfurt').suspended then return false end
		
		local canAttack = false
		for i,v in pairs(FrankfurtForce) do
			if bc:getZoneByName(i).side == 1 and not bc:getZoneByName(i).suspended then canAttack = true end
			
			for _,v2 in ipairs(v) do
				if Group.getByName(v2) then return false end
			end
		end
		
		return canAttack
	end
})

mc:trackMission({
	title = LTGet("COLDWAR_MISSION_DEFEND_FRANKFURT_TITLE"),
	description = LTGet("COLDWAR_MISSION_DEFEND_FRANKFURT_DESC"),
	messageStart = LTGet("COLDWAR_MISSION_DEFEND_FRANKFURT_START"),
	messageEnd = function(T) lastFrankfurtEnd = timer.getTime() return LT(T):Get("COLDWAR_MISSION_DEFEND_FRANKFURT_END") end,
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
		for i,v in pairs(FrankfurtForce) do
			for _,v2 in ipairs(v) do
				if Group.getByName(v2) then return true end
			end
		end
		
		return false
	end
})

-----------------------------------------------------------------------------------------------



-- Templin-attack-Neuruppin-Arty
--------------------------------   EVENT Cargo intercept -------------------------------------------
local Cargo_COOLDOWN = 1800
local lastCargo_COOLDOWN   = -Cargo_COOLDOWN
Group.getByName('evt-cargointercept1'):destroy()
Group.getByName('evt-cargointercept2'):destroy()
Group.getByName('evt-cargointercept3'):destroy()
local cargoDieEvent=nil
evc:addEvent({
	id='cargointercept',
	action=function()
		local planes
		if bc:getZoneByName('Mahlwinkel').side==1 and not bc:getZoneByName('Mahlwinkel').suspended then
			planes={'evt-cargointercept1'}
		elseif bc:getZoneByName('Hannover').side==1 and not bc:getZoneByName('Hannover').suspended then
			planes={'evt-cargointercept2'}
		elseif bc:getZoneByName('Peenemunde').side==1 and not bc:getZoneByName('Peenemunde').suspended then
			planes={'evt-cargointercept3'}
		else
			return
		end

		RespawnGroup(planes[1])
		RegisterGroupTarget(planes[1],250,L10N:Get("COLDWAR_TARGET_INTERCEPT_CARGO_PLANE"),'cargointercept')
	end,
	canExecute=function()
        if ActiveMission['cargointercept'] then return false end
        if timer.getTime() - lastCargo_COOLDOWN < Cargo_COOLDOWN then return false end
		if math.random(1,100)<50 then return false end
		if Group.getByName('evt-cargointercept1') then return false end
		if Group.getByName('evt-cargointercept2') then return false end
		if Group.getByName('evt-cargointercept3') then return false end
		return true
	end
})
mc:trackMission({
    title = LTGet("COLDWAR_MISSION_INTERCEPT_CARGO_TITLE"),
    description = function(T)
		if Group.getByName('evt-cargointercept1') then
			return LT(T):Get("COLDWAR_MISSION_INTERCEPT_CARGO_DESC_MAHLWINKEL")
		elseif Group.getByName('evt-cargointercept2') then
			return LT(T):Get("COLDWAR_MISSION_INTERCEPT_CARGO_DESC_HANNOVER")
		elseif Group.getByName('evt-cargointercept3') then
			return LT(T):Get("COLDWAR_MISSION_INTERCEPT_CARGO_DESC_PEENEMUNDE")
		else
			return LT(T):Get("COLDWAR_MISSION_INTERCEPT_CARGO_DESC_INACTIVE")
		end
	end,
    messageStart = LTGet("COLDWAR_MISSION_INTERCEPT_CARGO_START"),
    messageEnd =function(T) lastCargo_COOLDOWN=timer.getTime() return LT(T):Get("COLDWAR_MISSION_INTERCEPT_CARGO_END") end,
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

----------------------------------------------------- End of EVENT Cargo intercept --------------------------------------------------------
local sceneryList = {
  ["KommandantGunter"] = {SCENERY:FindByZoneName("KommandantGunter")},
  ["StrikeTarget1"] = {SCENERY:FindByZoneName("StrikeTarget1")},
  ["NaziReunion"] = {SCENERY:FindByZoneName("NaziReunion")},
  ["HannoverSupply"] = {SCENERY:FindByZoneName("HannoverSupply")},
  ["Striketarget2"] = {SCENERY:FindByZoneName("Striketarget2")},
  ["Striketarget3"] = {SCENERY:FindByZoneName("Striketarget3")},
  ["MahlwinkelWarehouse"] = {SCENERY:FindByZoneName("MahlwinkelWarehouse")},
  ["Propaganda"] = {SCENERY:FindByZoneName("Propaganda")},
  
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
-------------------------------------------------------- Hannover Supply --------------------------------------------------------
evc:addEvent({
	id = 'HannoverSupply',
	action = function()
		local tgt = sceneryList['HannoverSupply'][1] or SCENERY:FindByZoneName('HannoverSupply')
		if not tgt then
			trigger.action.outText('HannoverSupply scenery missing',30)
			return
		end
		RegisterScoreTarget('HannoverSupply',tgt,300,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
        local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
        if p then
            missionMarkId = missionMarkId + 1
            trigger.action.markToCoalition(missionMarkId,L10N:Get("COLDWAR_MISSION_HANNOVER_SUPPLY_MARK"),p,2,false,false)
            MissionMarks['HannoverSupply'] = missionMarkId
        end
	end,
	canExecute = function()
		if CustomFlags['HannoverSupply'] then return false end
		if ActiveMission['HannoverSupply'] then return false end
		if bc:getZoneByName('Hannover').side ~= 1 or bc:getZoneByName('Hannover').suspended then return false end
		if bc:getZoneByName('Braunschweig').side ~= 2 or bc:getZoneByName('Braunschweig').suspended then return false end
		return true
	end

})
mc:trackMission({
	title = LTGet("COLDWAR_MISSION_HANNOVER_SUPPLY_TITLE"),
	description = function(T) return LT(T):Format("COLDWAR_MISSION_STRIKE_SUPPLY_STORAGE_DESC", LT(T):Get("COLDWAR_MISSION_HANNOVER_SUPPLY_MARK"), "32 U ND 47006 12542", "N 52°27'39\" E 09°41'30\"", "N 52°27.661' E 09°41.511'", "168 feet", "300") end,
	messageStart = LTGet("COLDWAR_MISSION_HANNOVER_SUPPLY_START"),
	messageEnd = LTGet("COLDWAR_MISSION_HANNOVER_SUPPLY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["HannoverSupply"] then return false end
	if bc:getZoneByName('Hannover').side ~= 1 or (not bc:getZoneByName('SAM-Golf').active and not bc:getZoneByName('SAM-Foxtrot').active) then return false end
    if ActiveMission['HannoverSupply'] then return true end
	  return false
	end,
})

evc:addEvent({
	id = 'ParchimSupply',
	action = function()
		local tgt = sceneryList['ParchimSupply'][1] or SCENERY:FindByZoneName('ParchimSupply')
		if not tgt then
			trigger.action.outText('ParchimSupply scenery missing',30)
			return
		end
		RegisterScoreTarget('ParchimSupply',tgt,300,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
        local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
        if p then
            missionMarkId = missionMarkId + 1
            trigger.action.markToCoalition(missionMarkId,L10N:Get("COLDWAR_MISSION_PARCHIM_SUPPLY_MARK"),p,2,false,false)
            MissionMarks['ParchimSupply'] = missionMarkId
        end
	end,
	canExecute = function()
		if CustomFlags['ParchimSupply'] then return false end
		if ActiveMission['ParchimSupply'] then return false end
		if bc:getZoneByName('Parchim').side ~= 1 or (not bc:getZoneByName('Parchim').active) then return false end
		if bc:getZoneByName('Neuruppin').side ~= 2 or bc:getZoneByName('Tutow').side ~= 2  or bc:getZoneByName('Mahlwinkel').side ~= 2 then return false end
		return true
	end

})
mc:trackMission({
	title = LTGet("COLDWAR_MISSION_PARCHIM_SUPPLY_TITLE"),
	description = function(T) return LT(T):Format("COLDWAR_MISSION_STRIKE_SUPPLY_STORAGE_DESC", LT(T):Get("COLDWAR_MISSION_PARCHIM_SUPPLY_MARK"), "32 U PD 91979 06710", "N 52°22'37\" E 11°49'13\"", "N 52°22.617' E 11°49.231'", "165 feet", "300") end,
	messageStart = LTGet("COLDWAR_MISSION_PARCHIM_SUPPLY_START"),
	messageEnd = LTGet("COLDWAR_MISSION_PARCHIM_SUPPLY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["ParchimSupply"] then return false end
	if bc:getZoneByName('Parchim').side ~= 1 or (not bc:getZoneByName('Parchim').active) then return false end
    if ActiveMission['ParchimSupply'] then return true end
	  return false
	end,
})


mc:trackMission({
	title = LTGet("COLDWAR_MISSION_MAHLWINKEL_ASSAULT_TITLE"),
	description = LTGet("COLDWAR_MISSION_MAHLWINKEL_ASSAULT_DESC"),
	messageStart = LTGet("COLDWAR_MISSION_MAHLWINKEL_ASSAULT_START"),
	messageEnd = LTGet("COLDWAR_MISSION_MAHLWINKEL_ASSAULT_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "WarningSound.ogg")
        end
    end,
	endAction = function()
	trigger.action.outSoundForCoalition(2, "ding.ogg")
	trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_RED_ARMY_CAMP_INTEL"),30)
	zones.redarmycamp:AwakenZoneAndUpgrade()
	bc:addConnection("Mahlwinkel", "Red Army Camp")
	bc:buildConnectionMap()
	bc:RefreshConnectionsLines("Mahlwinkel")
	end,
	isActive = function()
		if CustomFlags["Mahlwinkel-arty-Attack-Group"] then return false end
		if not ActiveMission["Mahlwinkel-arty-Attack-Group"] then return false end
		if Group.getByName("Mahlwinkel-arty-Attack-Group") then return true end
		ActiveMission["Mahlwinkel-arty-Attack-Group"] = nil
		return false
	end,
})

--         
--Mahlwinkel-arty-Attack-Group
-------------------------------------------------- End of Hannover Supply ----------------------------------------------------
--------------------------------------------------  MahlWinkel Warehouse ----------------------------------------------------
evc:addEvent({
	id = 'MahlwinkelWarehouse',
	action = function()
		local tgt = sceneryList['MahlwinkelWarehouse'][1] or SCENERY:FindByZoneName('MahlwinkelWarehouse')
		if not tgt then
			trigger.action.outText('MahlwinkelWarehouse scenery missing',30)
			return
		end
		RegisterScoreTarget('MahlwinkelWarehouse',tgt,300,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
        local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
        if p then
            missionMarkId = missionMarkId + 1
            trigger.action.markToCoalition(missionMarkId,L10N:Get("COLDWAR_MISSION_MAHLWINKEL_WAREHOUSE_MARK"),p,2,false,false)
            MissionMarks['MahlwinkelWarehouse'] = missionMarkId
        end
	end,
	canExecute = function()
		if CustomFlags['MahlwinkelWarehouse'] then return false end
		if ActiveMission['MahlwinkelWarehouse'] then return false end
		if bc:getZoneByName('Zerbst').side ~= 2 then return false end
		if bc:getZoneByName('Mahlwinkel').side ~= 1 then return false end
		if not bc:getZoneByName('SAM-Echo').active then return false end
		return true
	end

})
mc:trackMission({
	title = LTGet("COLDWAR_MISSION_MAHLWINKEL_WAREHOUSE_TITLE"),
	description = function(T) return LT(T):Format("COLDWAR_MISSION_STRIKE_SUPPLY_STORAGE_DESC", LT(T):Get("COLDWAR_MISSION_MAHLWINKEL_WAREHOUSE_MARK"), "32 U PD 91653 07258", "N 52°22'55\" E 11°48'57\"", "N 52°22.919' E 11°48.962'", "159 feet", "300") end,
	messageStart = LTGet("COLDWAR_MISSION_MAHLWINKEL_WAREHOUSE_START"),
	messageEnd = LTGet("COLDWAR_MISSION_MAHLWINKEL_WAREHOUSE_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["MahlwinkelWarehouse"] then return false end
	if bc:getZoneByName('Mahlwinkel').side ~= 1 or (not bc:getZoneByName('SAM-Echo').active) then return false end
    if ActiveMission['MahlwinkelWarehouse'] then return true end
	  return false
	end,
})
------------------------------------------------------ End of Mahlwinkel Warehouse ----------------------------------------------------
------------------------------------------------------- Nazi reunion --------------------------------------------------------
evc:addEvent({
	id = 'NaziReunion',
	action = function()
		ActiveMission['NaziReunion'] = true
		RespawnGroup('NaziGroup')
		local tgt = sceneryList['NaziReunion'][1] or SCENERY:FindByZoneName('NaziReunion')
		if not tgt then
			trigger.action.outText('NaziReunion scenery missing',30)
			return
		end
		RegisterScoreTarget('NaziGroup',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("COLDWAR_MISSION_NAZI_REUNION_MARK"),p,2,false,false)
			MissionMarks['NaziReunion'] = missionMarkId
		end
	end,
	canExecute = function()
		if CustomFlags['NaziReunion'] then return false end
		if ActiveMission['NaziReunion'] then return false end
		if bc:getZoneByName('Bremen').side ~= 2 then return false end
		return true
	end
})
mc:trackMission({
	title = LTGet("COLDWAR_MISSION_NAZI_REUNION_TITLE"),
	description = LTGet("COLDWAR_MISSION_NAZI_REUNION_DESC"),
	messageStart = LTGet("COLDWAR_MISSION_NAZI_REUNION_START"),
	messageEnd = LTGet("COLDWAR_MISSION_NAZI_REUNION_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["NaziReunion"] then return false end
	if bc:getZoneByName('Bremen').side ~= 2 then return false end
    if ActiveMission['NaziReunion'] then return true end
	  return false
	end,
})
--------------------------------------------- End Nazi reunion ---------------------------------------------------

------------------------------------------------------- Striketarget2 --------------------------------------------------------
evc:addEvent({
	id = 'Striketarget2',
	action = function()
		local tgt = sceneryList['Striketarget2'][1] or SCENERY:FindByZoneName('Striketarget2')
		if not tgt then
			trigger.action.outText('Striketarget2 scenery missing',30)
			return
		end
		RegisterScoreTarget('Striketarget2',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
        local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
        if p then
            missionMarkId = missionMarkId + 1
            trigger.action.markToCoalition(missionMarkId,L10N:Get("COLDWAR_MISSION_KILL_COMMANDER_MARK"),p,2,false,false)
            MissionMarks['Striketarget2'] = missionMarkId
        end
	end,
	canExecute = function()
		if CustomFlags['Striketarget2'] then return false end
		if ActiveMission['Striketarget2'] then return false end
		if bc:getZoneByName('Hahn').side ~= 2 then return false end
		return true
	end
})
mc:trackMission({
	title = LTGet("COLDWAR_MISSION_KILL_COMMANDER_TITLE"),
	description = LTGet("COLDWAR_MISSION_KILL_COMMANDER_DESC"),
	messageStart = LTGet("COLDWAR_MISSION_KILL_COMMANDER_START"),
	messageEnd = LTGet("COLDWAR_MISSION_KILL_COMMANDER_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["Striketarget2"] then return false end
    if ActiveMission['Striketarget2'] then return true end
	  return false
	end,
})
--------------------------------------------- End striketarget2 ---------------------------------------------------
--------------------------------------------- striketarget3 ---------------------------------------------------
evc:addEvent({
	id = 'Striketarget3',
	action = function()
		local tgt = sceneryList['Striketarget3'][1] or SCENERY:FindByZoneName('Striketarget3')
		if not tgt then
			trigger.action.outText('Striketarget3 scenery missing',30)
			return
		end
		RegisterScoreTarget('Striketarget3',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
        local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
        if p then
            missionMarkId = missionMarkId + 1
            trigger.action.markToCoalition(missionMarkId,L10N:Get("COLDWAR_MISSION_KILL_GENERAL_MARK"),p,2,false,false)
            MissionMarks['Striketarget3'] = missionMarkId
        end
		RespawnGroup('Red SAM AAA 7 Fixed')
	end,
	canExecute = function()
		if CustomFlags['Striketarget3'] then return false end
		if ActiveMission['Striketarget3'] then return false end
		if bc:getZoneByName('Altes Lager').side ~= 2 or bc:getZoneByName('Schkeuditz').side ~= 2 then return false end
		return true
	end
})
mc:trackMission({
	title = LTGet("COLDWAR_MISSION_KILL_GENERAL_TITLE"),
	description = LTGet("COLDWAR_MISSION_KILL_GENERAL_DESC"),
	messageStart = LTGet("COLDWAR_MISSION_KILL_GENERAL_START"),
	messageEnd = LTGet("COLDWAR_MISSION_KILL_GENERAL_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["Striketarget3"] then return false end
    if ActiveMission['Striketarget3'] then return true end
	  return false
	end,
})


------------------------------------------ Kill Kommandant Günter ------------------------------------------------
Group.getByName('KommandantGunter'):destroy()
evc:addEvent({
	id = 'kommandantgunter',
	action = function()
		local tgt = sceneryList['KommandantGunter'][1] or SCENERY:FindByZoneName('KommandantGunter')
		if not tgt then
			trigger.action.outText('KommandantGunter scenery missing',30)
			return
		end
		RespawnGroup('KommandantGunter')
        RegisterScoreTarget('KommandantGunter',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("COLDWAR_MISSION_KILL_GUNTER_MARK"),p,2,false,false)
			MissionMarks['KommandantGunter'] = missionMarkId
		end
	end,
	canExecute = function()
		if CustomFlags['KommandantGunter'] then return false end
		if ActiveMission['KommandantGunter'] then return false end
		if bc:getZoneByName('Mahlwinkel').side ~= 2 or bc:getZoneByName('Mahlwinkel').suspended then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("COLDWAR_MISSION_KILL_GUNTER_TITLE"),
	description = LTGet("COLDWAR_MISSION_KILL_GUNTER_DESC"),
	messageStart = LTGet("COLDWAR_MISSION_KILL_GUNTER_START"),
	messageEnd = LTGet("COLDWAR_MISSION_KILL_GUNTER_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
		if CustomFlags["KommandantGunter"] then return false end
        if not ActiveMission['KommandantGunter'] then return false end
        if Group.getByName('KommandantGunter') then return true end
        ActiveMission['KommandantGunter'] = nil
		return false
	end
})
------------------------------------- End Kill Kommandant Günter -----------------------------------------
----------------------------------- Strike enemy communication tower -------------------------------------
evc:addEvent({
	id = 'StrikeTarget1',
	action = function()
		local tgt = sceneryList['StrikeTarget1'][1] or SCENERY:FindByZoneName('StrikeTarget1')
		if not tgt then
			trigger.action.outText('StrikeTarget1 scenery missing',30)
			return
		end
		RegisterScoreTarget('StrikeTarget1',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
        local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
        if p then
            missionMarkId = missionMarkId + 1
            trigger.action.markToCoalition(missionMarkId,L10N:Get("COLDWAR_MISSION_COMMS_TOWER_MARK"),p,2,false,false)
            MissionMarks['StrikeTarget1'] = missionMarkId
        end
	end,
	canExecute = function()
		if CustomFlags['StrikeTarget1'] then return false end
		if ActiveMission['StrikeTarget1'] then return false end
		if bc:getZoneByName('Fritzlar').side ~= 2 or bc:getZoneByName('Hannover').side ~= 2 then return false end
		return true
	end
})
mc:trackMission({
	title = LTGet("COLDWAR_MISSION_COMMS_TOWER_TITLE"),
	description = LTGet("COLDWAR_MISSION_COMMS_TOWER_DESC"),
	messageStart = LTGet("COLDWAR_MISSION_COMMS_TOWER_START"),
	messageEnd = LTGet("COLDWAR_MISSION_COMMS_TOWER_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["StrikeTarget1"] then return false end
    if ActiveMission['StrikeTarget1'] then return true end
	  return false
	end,
})

------------------------------------- End Strike enemy communication tower -----------------------------------------
-------------------------------------  Propaganda Broadcast Center -----------------------------------------
evc:addEvent({
	id = 'Propaganda',
	action = function()
		local tgt = sceneryList['Propaganda'][1] or SCENERY:FindByZoneName('Propaganda')
		if not tgt then
			trigger.action.outText('Propaganda scenery missing',30)
			return
		end
		RegisterScoreTarget('Propaganda',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
        local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
        if p then
            missionMarkId = missionMarkId + 1
            trigger.action.markToCoalition(missionMarkId,L10N:Get("COLDWAR_MISSION_PROPAGANDA_MARK"),p,2,false,false)
            MissionMarks['Propaganda'] = missionMarkId
        end
	end,
	canExecute = function()
		if CustomFlags['Propaganda'] then return false end
		if ActiveMission['Propaganda'] then return false end
		if bc:getZoneByName('Zerbst').side ~= 2 or bc:getZoneByName('Neuruppin').side ~= 2 then return false end
		return true
	end
})
mc:trackMission({
	title = LTGet("COLDWAR_MISSION_PROPAGANDA_TITLE"),
	description = LTGet("COLDWAR_MISSION_PROPAGANDA_DESC"),
	messageStart = LTGet("COLDWAR_MISSION_PROPAGANDA_START"),
	messageEnd = LTGet("COLDWAR_MISSION_PROPAGANDA_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["Propaganda"] then return false end
    if ActiveMission['Propaganda'] then return true end
	  return false
	end,
})
------------------------------------- End Propaganda Broadcast Center -----------------------------------------
local EscortCooldown = 1800
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
						trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_ESCORT_INTERCEPTOR_SPOTTED"),15)
					else
						trigger.action.outTextForCoalition(2,L10N:Get("COLDWAR_EVENT_ESCORT_INTERCEPT_MISSION"),15)
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
		if bc:getZoneByName('Frankfurt').side ~= 2 or bc:getZoneByName('Frankfurt').suspended then return false end
		local triggers = {'Frankfurt', 'Schkeuditz', 'Mahlwinkel'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		
		return false
	end
})
mc:trackMission({
    title = LTGet("COLDWAR_MISSION_ESCORT_CARGO_FRANKFURT_TITLE"),
    description = LTGet("COLDWAR_MISSION_ESCORT_CARGO_FRANKFURT_DESC"),
    messageStart = LTGet("COLDWAR_MISSION_ESCORT_CARGO_FRANKFURT_START"),
    messageEnd = function(T) lastEscortCooldown = timer.getTime() return LT(T):Get("COLDWAR_MISSION_ESCORT_CARGO_FRANKFURT_END") end,
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

Group.getByName('EnemScuds'):destroy()
evc:addEvent({
	id='scuds',
	action=function()
		RespawnGroup('EnemScuds')
        RegisterGroupTarget('EnemScuds',250,L10N:Get("COLDWAR_TARGET_DESTROY_SCUDS"),'ScudsIsDestroyed',true)

		timer.scheduleFunction(function()
			if IsGroupActive('EnemScuds') then
                local scudGrp = GROUP:FindByName('EnemScuds')
                local _,_,_,_,missilesLeft = scudGrp:GetAmmunition()
                 if missilesLeft == 0 then return timer.getTime() + (45*60) end
				local tgts={'Frankfurt','Giebelstadt','Walldurn FARP','Walldorf FARP','Bad Durkheim','Ramstein','Hahn','Gelnhausen'}
				local valid={}
				for _,v in ipairs(tgts) do
					if bc:getZoneByName(v).side==2 then valid[#valid+1]=v end
				end
				if #valid==0 then return timer.getTime()+(10*60) end

				local choice=valid[math.random(1,#valid)]
				bc:fireAtZone(choice,'EnemScuds',false,8)
				trigger.action.outTextForCoalition(2,L10N:Format("COLDWAR_EVENT_SCUDS_LAUNCHING", choice),15)
			end
			return timer.getTime()+(45*60)
		end,{},timer.getTime()+(20*60))
	end,
	canExecute=function()
		if CustomFlags["ScudsIsDestroyed"] then return false end
        if ActiveMission['ScudsIsDestroyed'] then return false end
        if IsGroupActive('EnemScuds') then return false end
		local triggers={'Frankfurt','Walldorf FARP','Giebelstadt','Gelnhausen'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end
		end
		return false
	end
})

mc:trackMission({
    title = LTGet("COLDWAR_MISSION_DESTROY_SCUDS_TITLE"),
	description = LTGet("COLDWAR_MISSION_DESTROY_SCUDS_DESC"),
    messageStart = LTGet("COLDWAR_MISSION_DESTROY_SCUDS_START"),
    messageEnd = LTGet("COLDWAR_MISSION_DESTROY_SCUDS_END"),
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
        if CustomFlags["ScudsIsDestroyed"] then return false end
        if not ActiveMission['ScudsIsDestroyed'] then return false end
        if Group.getByName('EnemScuds') then return true end
        ActiveMission['ScudsIsDestroyed'] = nil
        CustomFlags["ScudsIsDestroyed"] = true
        return false
    end
})

Group.getByName('ConstructionGroup'):destroy()
Group.getByName('ConstructionGroupManPad'):destroy()
evc:addEvent({
	id='ConstructionGroup',
	action = function()
		RespawnGroup('ConstructionGroup')
		RespawnGroup('ConstructionGroupManPad')
		RegisterGroupTarget('ConstructionGroup',500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),'ConstructionGroup',true)
	end,
	canExecute = function()
	if CustomFlags["ConstructionGroup"] then return false end
	if ActiveMission["ConstructionGroup"] then return false end
	if Group.getByName('ConstructionGroup') then return false end
	if bc:getZoneByName('Frankfurt').side ~= 2 or bc:getZoneByName('Mendig').side ~= 2 then return false end
	return true
end
})

mc:trackMission({
	title = LTGet("COLDWAR_MISSION_CONSTRUCTION_SITE_TITLE"),
	description = LTGet("COLDWAR_MISSION_CONSTRUCTION_SITE_DESC"),
	messageStart = LTGet("COLDWAR_MISSION_CONSTRUCTION_SITE_START"),
	messageEnd = LTGet("COLDWAR_MISSION_CONSTRUCTION_SITE_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
		if CustomFlags["ConstructionGroup"] then return false end
		if not ActiveMission["ConstructionGroup"] then return false end
		if Group.getByName('ConstructionGroup') then return true end
		ActiveMission["ConstructionGroup"] = nil
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
		trigger.action.outTextForGroup(groupID, L10N:FormatForGroup(groupID, "COLDWAR_MISSION_ESCORT_ACTIVE_PENDING", mission.zone, mission.TargetZone), 30)
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
        messageStart = function(T) return LT(T):Format("MISSION_ESCORT_START", mission.TargetZone) end,
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
		local wp = WaypointList[attackTarget1] or ""
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
		local wp = WaypointList[attackTarget2] or ""
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



buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end

airbaseStatics = {
}

-------------------------- END OF FLAGS --------------------------

env.info("Mission Setup : is completed!")
