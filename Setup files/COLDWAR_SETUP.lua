env.info("Mission Setup : is loading.")

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
    Garz = ' (44)',
    Peenemunde = ' (45)',
    Bornholm = ' (46)',
    Sturup = ' (47)',
    ['Kastrup City'] = ' (48)',
}

flavor = {

    bitburg = 'WPT 1\n',
    spangdahlem = 'WPT 2\n',
    hahn = 'WPT 3\n',
    mendig = 'WPT 4\n',
    mendignorth = 'WPT 5\n',
    mendigeast = 'WPT 6\n',
    baumholderfarp = 'WPT 7\n',
    ramstein = 'WPT 8\n',
    baddurkheim = 'WPT 9\n',
    walldorffarp = 'WPT 10\n',
    walldurnfarp = 'WPT 11\n',
    giebelstadt = 'WPT 12\n',
    airrcing = 'WPT 13\n',
    frankfurt = 'WPT 14\n',
    fritzlar = 'WPT 15\n',
    gelnhausen = 'WPT 16\n',
    laubachfarp = 'WPT 17\n',
    fulda = 'WPT 18\n',
    salzungenfarp = 'WPT 19\n',
    bindersleben = 'WPT 20\n',
    naumburgfarp = 'WPT 21\n',
    schkeuditz = 'WPT 22\n',
    zerbst = 'WPT 23\n',
    mahlwinkel = 'WPT 24\n',
    braunschweig = 'WPT 25\n',
    hannover = 'WPT 26\n',
    fassberg = 'WPT 27\n',
    scheessel = 'WPT 28\n',
    bremen = 'WPT 29\n',
    hamburg = 'WPT 30\n',
    lubeck = 'WPT 31\n',
    briest = 'WPT 32\n',
    alteslager = 'WPT 33\n',
    wundsdorffarp = 'WPT 34\n',
    tegel = 'WPT 35\n',
    werneuchen = 'WPT 36\n',
    neuruppin = 'WPT 37\n',
    templin = 'WPT 38\n',
    larz = 'WPT 39\n',
    parchim = 'WPT 40\n',
    neubrandenburg = 'WPT 41\n',
    tutow = 'WPT 42\n',
    laage = 'WPT 43\n',
    garz = 'WPT 44\n',
    peenemunde = 'WPT 45\n',
    sheizefactory = 'If shit could be made, it would be one of the best shit in the world.',
    chemicalfactory = 'Chemicals are made here, not a good one.',

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
		red = {'Enemy ground forces 2', 'Red Armour Group', 'Red Armour Group 3', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8','Red SAM SHORAD SA-8', 'Red SAM SA-3'}
	},
	airfield2 = {
		blue = {'blueInfantry', 'blueArmor','bluePD1','blueArmor'},
		red = {'Enemy ground forces','Red SAM AAA 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD Tor M2', 'Red Arty', 'Red SAM SHORAD SA-19'}
	},
	airfield3 = {
		blue = {'bluePD2', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces 2', 'Red Armour Group 2','Red Armour Group 3', 'Red SAM AAA 2', 'Red SAM SHORAD Pantsir S1', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD SA-15','Red Arty'}
	},
	airfield4 = {
		blue = {'blueInfantry','bluePD1','blueArmor'},
		red = {'Enemy ground forces 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD SA-15', 'Red SAM AAA 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD Pantsir S1'}
	},
    Scheize = {
		blue = {'blueInfantry','blueArmor','blueHAWK'},
		red = {'Enemy ground forces 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Tor M2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-8', 'Red SAM AAA 3','Red SAM AAA 4','Scheize Factory building 1','Scheize Factory building 2'}
	},
	airfield6 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1',},
		red = {'Enemy ground forces 2', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD Pantsir S1', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Tor M2', 'Red SAM SA-10'}
	},--airfieldKastrup
	airfieldKastrup = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1',},
		red = {'Enemy ground forces 2', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD Pantsir S1', 'Red SAM SHORAD Tor M2', 'Grisha Kastrup Fixed', 'Red SAM SA-6'}
	},
	airfield6Cold = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces 2', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15', 'Red SAM SA-2'}
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
	EWRMantisNet = {
		blue = {},
		red = {'Red EWR Fixed 1', 'Red EWR Fixed 2', 'Red EWR Fixed 3', 'Red EWR Fixed 4', 'Red EWR Fixed 5','Red EWR Fixed 6'}
	},
	hidden2 = {
		blue = {},
		red = {'Grisha Fixed','Moskova fleet Fixed'}
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
		red = {'hiddenground1-Fixed-1', 'hiddenground1-Fixed-2', 'hiddenground1-Fixed-3','hiddenground1-Fixed-4','hiddenground1-Fixed-5','hiddenground1-Fixed-6',
                'hiddenground1-Fixed-7','hiddenground1-Fixed-8','hiddenground1-Fixed-9', 'hiddenground1-Fixed-10','hiddenground1-Fixed-11','hiddenground1-Fixed-12',
                'hiddenground1-Fixed-13','hiddenground1-Fixed-14','hiddenground1-Fixed-15','hiddenground1-Fixed-16','hiddenground1-Fixed-17'}
	},
	hiddenground2 = {
		blue = {},
		red = {'hiddenground2-Fixed-1', 'hiddenground2-Fixed-2', 'hiddenground2-Fixed-3','hiddenground2-Fixed-4','hiddenground2-Fixed-5','hiddenground2-Fixed-6',
                'hiddenground2-Fixed-7','hiddenground2-Fixed-8','hiddenground2-Fixed-9','hiddenground2-Fixed-10','hiddenground2-Fixed-11'}
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
	['Red SAM SHORAD Pantsir S1']  = 'Red SAM SHORAD SA-8',
	['Red SAM SHORAD Tor M2']  = 'Red SAM SHORAD SA-13',

    
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
					t[k] = sub[1]
					for i=2,#sub do
						table.insert(t,sub[i])
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
	['Red SAM SA-10']   = {'Red SAM SA-2', 'Red SAM SA-3'},
	['Red SAM SA-11']   = 'Red SAM SA-2',
	['Red SAM SA-11 Fixed SamKilo']   = 'Red SAM SA-2 Fixed SamKilo',
	['Red SAM SA-11 Fixed SamHotel']   = 'Red SAM SA-2 Fixed SamHotel',
	['Red SAM SA-11 Fixed SamDelta']  = 'Red SAM SA-2 Fixed SamDelta',
	['Red SAM SA-10 Fixed SamLima']  = 'Red SAM SA-2 Fixed SamLima',
	['Red SAM SA-11 South Sweden Fixed']  = 'Red SAM SA-2 South Sweden Fixed',
	['Red SAM SA-11 South East Sweden Fixed']  = 'Red SAM SA-2 South East Sweden Fixed',
    --['Red SAM SHORAD SA-8']  = {'Red SAM AAA 4','Red SAM AAA 3'},
	['Red SAM SHORAD SA-15']  = 'Red SAM SHORAD SA-8',
	['Red SAM SHORAD Pantsir S1']  = 'Red SAM SHORAD SA-9',
	['Red SAM SHORAD Tor M2']  = 'Red SAM SHORAD SA-13',
	['Red SAM Dog Ear SA-15 Fixed SamDelta']  = 'Red SAM SHORAD SA-19 Fixed SamDelta',
	['Red SAM SHORAD SA-15 Fixed SamDelta 2']  = 'Red SAM SHORAD SA-8 Fixed SamDelta 2',
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
	deepSwapAgain(RandomRedPool, SamSwap)
end

ZoneSizeExclusions = {
	small = { "sa-10", "sa-11","sa-2","pantsir","tor m2" },
	medium = { "sa-10", "sa-11","pantsir"},
}

RandomUpgradeTemplates = {
	small = { sam = 0, shorad = {1,2}, aaa = 2, ground = 1, armor = 1, arty = {0,1}, total = {5,7} },
	medium = { sam = {0,1}, shorad = {1,2}, aaa = {1,2}, ground = 1, armor = 2, arty = 1, total = {7,9} },
	big = { sam = 1, shorad = {2,3}, aaa = {1,2}, ground = 1, armor = 2, arty = 1, total = {8,10} },
	extrabig = { sam = 2, shorad = {3,4}, aaa = 2, ground = 1, armor = {1,2}, arty = 1, total = {10,12} },
	sam = { sam = 1, shorad = {1,2}, aaa = {1,2}, ground = 0, armor = 0, arty = 0, total = {5,5} },
}

RandomUpgradeTemplatesBlue = {
	small = { sam = {0,1}, ground = 1, armor = 1, total = {2,3} },
	medium = { sam = {0,1}, ground = 1, armor = 1, total = {2,3} },
	big = { sam = {0,1}, ground = 1, armor = 1, total = {2,4} },
	extrabig = { sam = 1, ground = 1, armor = 1, total = {3,4} },
}

RandomGroundGroups = RandomGroundGroups or false
RandomBlueGroups = RandomBlueGroups or true

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
    tutow           = ZoneCommander:new({zone='Tutow',              size='medium',      side=1, level=25, upgrades=upgrades.airfield3,       crates={},flavorText=flavor.tutow}),
    peenemunde      = ZoneCommander:new({zone='Peenemunde',         size='medium',      side=1, level=25, upgrades=upgrades.airfield3,       crates={},flavorText=flavor.peenemunde}),
    garz            = ZoneCommander:new({zone='Garz',               size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.garz}),
    neubrandenburg  = ZoneCommander:new({zone='Neubrandenburg',     size='medium',      side=1, level=25, upgrades=upgrades.airfield3,       crates={},flavorText=flavor.neubrandenburg}),
    parchim         = ZoneCommander:new({zone='Parchim',            size='medium',      side=1, level=25, upgrades=upgrades.airfield4,       crates={},flavorText=flavor.parchim}),
    larz            = ZoneCommander:new({zone='Larz',               size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.larz}),
    bornholm        = ZoneCommander:new({zone='Bornholm',           size='medium',      side=1, level=25, upgrades=upgrades.airfield3,       crates={},flavorText=flavor.bornholm}),
    sturup          = ZoneCommander:new({zone='Sturup',             size='medium',      side=1, level=25, upgrades=upgrades.airfield2,       crates={},flavorText=flavor.sturup}),
    kastrup         = ZoneCommander:new({zone='Kastrup City',       size='extrabig',    side=1, level=25, upgrades=upgrades.airfieldKastrup, crates={},flavorText=flavor.kastrup,income=2}),

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
    
    hidden1         = ZoneCommander:new({zone='Hidden1',            side=1, level=20, upgrades=upgrades.EWRMantisNet,    crates={}, flavorText=flavor.hidden1}),
    hidden2         = ZoneCommander:new({zone='Hidden2',            side=1, level=20, upgrades=upgrades.hidden2,         crates={}, flavorText=flavor.hidden2}),
    hiddenground1   = ZoneCommander:new({zone='HiddenGround1',      side=1, level=20, upgrades=upgrades.hiddenground1,  crates={}, flavorText=flavor.hiddenground1}),
    hiddenground2   = ZoneCommander:new({zone='HiddenGround2',      side=0, level=20, upgrades=upgrades.hiddenground2,  crates={}, flavorText=flavor.hiddenground2, NeutralAtStart=true}),
    hiddenground3   = ZoneCommander:new({zone='HiddenGround3',      side=0, level=20, upgrades=upgrades.hiddenground3,  crates={}, flavorText=flavor.hiddenground3, NeutralAtStart=true}),
    hiddenground4   = ZoneCommander:new({zone='HiddenGround4',      side=0, level=20, upgrades=upgrades.hiddenground4,  crates={}, flavorText=flavor.hiddenground4, NeutralAtStart=true}),
    hiddenground5   = ZoneCommander:new({zone='HiddenGround5',      side=0, level=35, upgrades=upgrades.hiddenground5,  crates={}, flavorText=flavor.hiddenground5, NeutralAtStart=true}),
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
        'RED_SU17M_TwoShip_Sead',
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
	GroupCommander:new({name='Hahn-attack-Spangdahlem-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Spangdahlem',altitude = CasAltitude()}),
	GroupCommander:new({name='Hahn-attack-Spangdahlem-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Spangdahlem',altitude = SeadAltitude()}),
	GroupCommander:new({name='Hahn-attack-Baumholder FARP-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Baumholder FARP'}),
	GroupCommander:new({name='Hahn-attack-Mendig-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Mendig'}),
})

zones.mendig:addGroups({
	GroupCommander:new({name='Mendig-supply-Mendig North FARP-Convoy', mission='supply',template='SupplyConvoy', targetzone='Mendig North FARP', type='surface'}),
	GroupCommander:new({name='Mendig-supply-Mendig East FARP-Convoy', mission='supply',template='SupplyConvoy', targetzone='Mendig East FARP', type='surface'}),
	GroupCommander:new({name='Mendig-attack-Hahn-Arty', mission='supply', targetzone='Hahn', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='Mendig-supply-Spangdahlem', mission='supply',template='CasHeloTemplate',MissionType='CAS', targetzone='Spangdahlem'}),
	GroupCommander:new({name='Mendig-attack-Hahn-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Hahn'}),
})

zones.mendigeast:addGroups({
	GroupCommander:new({name='Mendig East FARP-supply-Mendig-Convoy', mission='supply',template='SupplyConvoy', targetzone='Mendig', type='surface'}),
	GroupCommander:new({name='Mendig East FARP-supply-Mendig North FARP-Convoy', mission='supply',template='SupplyConvoy', targetzone='Mendig North FARP', type='surface'}),
	GroupCommander:new({name='Mendig East FARP-supply-Mendig', mission='attack',template='AttackConvoy', targetzone='Mendig', type='surface'}),
	GroupCommander:new({name='Mendig East FARP-supply-Mendig North FARP', mission='attack',template='AttackConvoy', targetzone='Mendig North FARP', type='surface'}),
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
	GroupCommander:new({name='Bad-Durkheim-supply-ramstein', mission='supply', template='HeloSupplyTemplate', targetzone='Ramstein'}),
	GroupCommander:new({name='Bad-Durkheim-supply-Walldorf', mission='supply', template='HeloSupplyTemplate', targetzone='Walldorf FARP'}),
	GroupCommander:new({name='Bad Durkheim-attack-Ramstein-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Ramstein'}),
	GroupCommander:new({name='Bad Durkheim-attack-Walldorf FARP-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Walldorf FARP'}),
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
	GroupCommander:new({name='Giebelstadt-attack-Frankfurt-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Frankfurt',Altitude = CasAltitude()}),
	GroupCommander:new({name='Giebelstadt-patrol-Frankfurt-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Frankfurt',Altitude = CasAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Frankfurt-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Frankfurt',Altitude = CasAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Gelnhausen-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Gelnhausen',Altitude = CasAltitude()}),
	GroupCommander:new({name='Giebelstadt-patrol-Gelnhausen-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Gelnhausen',Altitude = CasAltitude()}),

	GroupCommander:new({name='Giebelstadt-patrol-Bad Durkheim-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Bad Durkheim',Altitude = CasAltitude()}),
	GroupCommander:new({name='Giebelstadt-patrol-Ramstein-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramstein',Altitude = CasAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Ramstein-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramstein',Altitude = CasAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Hahn-Cas', mission='attack',template='CasPlaneTemplate', MissionType='CAS', targetzone='Hahn',Altitude = CasAltitude()}),
	GroupCommander:new({name='Giebelstadt-attack-Hahn-Sead', mission='attack',template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Hahn',Altitude = CasAltitude()}),
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
	GroupCommander:new({name='Frankfurt-attack-Fulda-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Fulda', Altitude = CapAltitude()}),
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
	GroupCommander:new({name='Frankfurt-Attack-Hahn-Sead', mission='attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Hahn', Altitude = CasAltitude()}),
	GroupCommander:new({name='Frankfurt-Attack-Hahn-rwy', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Hahn', Altitude = CasAltitude()}),

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
    GroupCommander:new({name='Laubach FARP-attack-frankfurt', mission='attack', targetzone='Frankfurt', type='surface', diceChance = 30, SetActiveMission = true}),
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
	GroupCommander:new({name='Zerbst-attack-Mahlwinkel-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Mahlwinkel', Altitude = CasAltitude()}),

	GroupCommander:new({name='Zerbst-attack-Schkeuditz-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Schkeuditz', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Zerbst-attack-Schkeuditz-rwy', mission='attack', template='SeadPlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Schkeuditz', Altitude = SeadAltitude()}),

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
	GroupCommander:new({name='Mahlwinkel-supply-SAM-Echo', mission='supply', template='SupplyConvoy', targetzone='SAM-Echo', type='surface', spawnDelayFactor = 3}),
	GroupCommander:new({name='Mahlwinkel-patrol-Bindersleben-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bindersleben', Altitude = CapAltitude()}),
	GroupCommander:new({name='Mahlwinkel-patrol-Schkeuditz', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Schkeuditz', Altitude = CapAltitude()}),
	GroupCommander:new({name='Mahlwinkel-patrol-Zerbst', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Zerbst', Altitude = CapAltitude()}),
	GroupCommander:new({name='Mahlwinkel-attack-Briest-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Briest'}),
	GroupCommander:new({name='Mahlwinkel-attack-Zerbst-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Zerbst'}),
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
	GroupCommander:new({name='Hannover-supply-SAM-Foxtrot', mission='supply', template='SupplyConvoy', targetzone='SAM-Foxtrot', type='surface', spawnDelayFactor = 4, Redcondition=function() return CustomFlags["HannoverSupply"] ~= true end})
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
	GroupCommander:new({name='Bremen-supply-SAM-Hotel', mission='supply',template='SupplyConvoy', targetzone='SAM-Hotel', type='surface', spawnDelayFactor = random(2,4)})
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
    GroupCommander:new({name='Wundsdorf FARP-supply-Tegel', mission='supply', template='HeloSupplyTemplate', targetzone='Tegel'}),
	GroupCommander:new({name='Wundsdorf FARP-attack-Altes Lager-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Altes Lager'}),
	GroupCommander:new({name='Wundsdorf FARP-attack-Tegel-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Tegel'}), -- new
})

zones.tegel:addGroups({
    GroupCommander:new({name='Tegel-supply-Neuruppin', mission='supply', template='HeloSupplyTemplate', targetzone='Neuruppin'}),
    GroupCommander:new({name='Tegel-supply-Werneuchen', mission='supply', template='HeloSupplyTemplate', targetzone='Werneuchen'}),
    GroupCommander:new({name='Tegel-supply-SAM-India', mission='supply', template='SupplyConvoy', targetzone='SAM-India', type='surface', spawnDelayFactor = 3}),
    GroupCommander:new({name='Tegel-attack-Mahlwinkel-Cap', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Mahlwinkel', Altitude = CapAltitude()}),
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
    GroupCommander:new({name='Parchim-supply-SAM-Kilo', mission='supply', template='SupplyConvoy', targetzone='SAM-Kilo',type='surface', spawnDelayFactor = 2}),
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
    GroupCommander:new({name='Laage-attack-Lubeck',template='CasPlaneTemplate',MissionType='CAS', mission='attack', targetzone='Lubeck', Altitude = CasAltitude()}),
    GroupCommander:new({name='Laage-attack-Larz', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Larz', Altitude = CasAltitude()}),
    GroupCommander:new({name='Laage-supply-SAM-Lima', mission='supply', template='SupplyConvoy', targetzone='SAM-Lima', type='surface', spawnDelayFactor = 3}),
    GroupCommander:new({name='Laage-patrol-Lubeck-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Lubeck', Altitude = CapAltitude()}),
    GroupCommander:new({name='Laage-patrol-Larz-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Larz', Altitude = CapAltitude()}),
    GroupCommander:new({name='Laage-patrol-Parchim-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Parchim', Altitude = CapAltitude()})
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
    GroupCommander:new({name='bornholm-attack-Bornholm', mission='supply',template='PlaneSupplyTemplate', targetzone='Bornholm'}),
    GroupCommander:new({name='bornholm-attack-Peenemunde', mission='supply',template='PlaneSupplyTemplate', targetzone='Peenemunde'}),
    GroupCommander:new({name='bornholm-attack-Laage-Cap', mission='attack',template='CapPlaneTemplate',MissionType='CAP', targetzone='Laage', Altitude = CapAltitude()}),
    GroupCommander:new({name='bornholm-attack-Neubrandenburg-Sead', mission='attack',template='CapPlaneTemplate',MissionType='SEAD', targetzone='Neubrandenburg', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bornholm-attack-Neubrandenburg-Cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Neubrandenburg', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bornholm-patrol-Peenemunde-CAP', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='Peenemunde', Altitude = CapAltitude()}),
    GroupCommander:new({name='bornholm-attack-Peenemunde-rwn', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Peenemunde', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bornholm-attack-Tutow-rwn', mission='attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone='Tutow', Altitude = SeadAltitude()}),
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
    GroupCommander:new({name='Kastrup-attack-Lubeck-Sead', mission='attack',template='CasPlaneTemplate',MissionType='SEAD', targetzone='Lubeck', Altitude = SeadAltitude()}),
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
bc:addConnection("Neuruppin","Larz")
bc:addConnection("Larz","Parchim")
bc:addConnection("Parchim","SAM-Kilo")
bc:addConnection("Larz","Neubrandenburg")
bc:addConnection("Neubrandenburg","Tutow")
bc:addConnection("Tutow","Laage")
bc:addConnection("Laage","SAM-Lima")
bc:addConnection("Tutow","Peenemunde")
bc:addConnection("Tutow","Garz")
bc:addConnection("Peenemunde","Bornholm")
bc:addConnection("Bornholm","Sturup")
bc:addConnection("Sturup","Kastrup City")

bc:addConnection("Baumholder FARP","Ramstein")
bc:addConnection("Ramstein","Bad Durkheim")
bc:addConnection("Bad Durkheim","Walldorf FARP")
bc:addConnection("Walldorf FARP","Walldurn FARP")
bc:addConnection("Walldurn FARP","Giebelstadt")



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

zones.sheizefactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Scheiße Factory is now only Scheiße\n+500 credits',20)
end, 'disablesheizefactory')

zones.chemicalfactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'chemicalfactory Factory destroyed.\n+500 credits',20)
end, 'disableschemicalfactory')

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
            trigger.action.outTextForCoalition(2, "Hahn is under attack by enemy Artillery!\n\nBrace!", 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 180)
		end
	
    timer.scheduleFunction(function()
    trigger.action.outTextForCoalition(2, [[We found the enemy Artillery!

Take it out before they fire again!   

Coordinates:
MGRS: 32 U MA 15621 72886
Lat long: N 50°18'07" E 07°48'54"
Lat long Decimal Minutes: N 50°18.123' E 07°48.910'

Elevation: 234 feet]], 30)
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
            trigger.action.outTextForCoalition(2, "3 enemy attack helicopters are inbound Fulda from Salzungen FARP!\n\nTake them out before they start firing!", 30)
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
            trigger.action.outTextForCoalition(2, "The enemy have launched an assault on Schkeuditz\n\n2 bombers escorted by 2 unknown jets!", 30)
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
            trigger.action.outTextForCoalition(2, "The enemy have launched an assault on Mahlwinkel!!\n\nThey have deployed long range Artillery and unknown bandits inbound!", 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 60)
		end
	
    timer.scheduleFunction(function()
    trigger.action.outTextForCoalition(2, [[We found the enemy Artillery!

Take it out before they fire again!   

Coordinates:
MGRS: 32 U PD 64017 06031
Lat long: N 52°22'47" E 11°24'35"
Lat long Decimal Minutes: N 52°22.796' E 11°24.587'

Elevation: 234 feet]], 30)
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
            trigger.action.outTextForCoalition(2, "AMBUSH!!!!!\n\nEnemy insurgents are emerging from Bremen!", 30)
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
            trigger.action.outTextForCoalition(2, "Brace!!\n\nWe have detected artillery shells inbound for Neuruppin!!", 30)
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
            trigger.action.outTextForCoalition(2, "Brace!!\n\nEnemy have launched ground assault!\nThey are on route toward Neuruppin", 30)
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
            trigger.action.outTextForCoalition(2, "Brace!!\n\nEnemy have fired scuds toward Larz!!", 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 60)
		end
	end
end, 'larzcaptured')

missions = {
        ["Baumholder FARP"] = {	
        zone = "Baumholder FARP",
        missionGroup = "BaumholderFARPEscortGroup",
        menuTitle = "Baumholder FARP: Ground Escort",
        missionTitle = "Baumholder FARP: Ground Escort",
        TargetZone = "Ramstein",
        radius = 2500,
        MissionType = "Escort",
        flag = 101
    },
    ["Bad Durkheim"] = {	
        zone = "Bad Durkheim",
        missionGroup = "BadDurkheimEscortGroup",
        menuTitle = "Bad Durkheim: Ground Escort",
        missionTitle = "Bad Durkheim: Ground Escort",
        TargetZone = "Walldorf FARP",
		radius = 2500,
        MissionType = "Escort",
		flag = 101
    },
    ["Gelnhausen"] = {	
        zone = "Gelnhausen",
        missionGroup = "GelnhausenEscortGroup",
        menuTitle = "Gelnhausen: Ground Escort",
        missionTitle = "Gelnhausen: Ground Escort",
        TargetZone = "Walldorf FARP",
		radius = 2500,
        MissionType = "Escort",
		flag = 111
    },
    ["Walldurn FARP"] = {	
        zone = "Walldurn FARP",
        missionGroup = "WalldurnFarpEscortGroup",
        menuTitle = "WalldurnFarp: Ground Escort",
        missionTitle = "WalldurnFarp: Ground Escort",
        TargetZone = "Giebelstadt",
        radius = 2500,
        MissionType = "Escort",
		flag = 121
    },
    ["Laubach FARP"] = {	
        zone = "Laubach FARP",
        missionGroup = "LaubachFARPEscortGroup",
        menuTitle = "Laubach FARP: Ground Escort",
        missionTitle = "Laubach FARP: Ground Escort",
        TargetZone = "Fulda",
        radius = 2500,
        MissionType = "Escort",
		flag = 131
    },
    ["Altes Lager"] = {	
        zone = "Altes Lager",
        missionGroup = "AltesLagerEscortGroup",
        menuTitle = "Altes Lager: Ground Escort",
        missionTitle = "Altes Lager: Ground Escort",
        TargetZone = "Fulda",
        radius = 2500,
        MissionType = "Escort",
		flag = 141
    },
    ["Wundsdorf FARP"] = {	
        zone = "Wundsdorf FARP",
        missionGroup = "WundsdorfFARPEscortGroup",
        menuTitle = "Wundsdorf FARP: Ground Escort",
        missionTitle = "Wundsdorf FARP: Ground Escort",
        TargetZone = "Tegel",
        radius = 2500,
        MissionType = "Escort",
		flag = 151
    },
    ["Tegel"] = {	
        zone = "Tegel",
        missionGroup = "TegelEscortGroup",
        menuTitle = "Tegel: Ground Escort",
        missionTitle = "Tegel: Ground Escort",
        TargetZone = "Werneuchen",
        radius = 2500,
        MissionType = "Escort",
        flag = 161
    },
    ["Scheessel"] = {	
        zone = "Scheessel",
        missionGroup = "ScheesselEscortGroup",
        menuTitle = "Scheessel: Ground Escort",
        missionTitle = "Scheessel: Ground Escort",
        TargetZone = "Bremen",
        radius = 2500,
        MissionType = "Escort",
        flag = 171
    },
    ["Naumburg FARP"] = {	
        zone = "Naumburg FARP",
        missionGroup = "NaumburgFARPEscortGroup",
        menuTitle = "Naumburg FARP: Ground Escort",
        missionTitle = "Naumburg FARP: Ground Escort",
        TargetZone = "Schkeuditz",
        radius = 2500,
        MissionType = "Escort",
        flag = 181
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
    if zones.lubeck.side == 2 and zones.laage.side == 2 and not zones.samlima.active then
        if not IsGroupActive('CVN-72') then
            activateGroupIfNotActive('CVN-72')
            zones.hiddensweden:MakeZoneRedAndUpgrade()
            timer.scheduleFunction(function()
            checkWeaponsList('CVN-72')
        end, {}, timer.getTime() + 5)
        end
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
		"Red SAM SHORAD Tor M2 #",
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
	}, 30, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
end
end,{},5,0)

-- SHOP --
local upgradeMenu = nil
bc:registerShopItem('supplies2', 'Resupply friendly Zone', ShopPrices.supplies2, function(sender)
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
bc:registerShopItem('supplies','Fully Upgrade Friendly Zone',ShopPrices.supplies,
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
bc:registerShopItem('armor', 'Deploy armor (for combined arms) ', ShopPrices.armor, function(sender)
	
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
	
	tanksMenu = bc:showTargetZoneMenu(2, 'Deploy armor (Choose friendly zone) ', deployTanks, 2)
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
bc:registerShopItem('artillery', 'Deploy artillery (for combined arms) ', ShopPrices.artillery, function(sender)
	
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
	
	artyMenu = bc:showTargetZoneMenu(2, 'Deploy artillery (Choose friendly zone) ', deployArty, 2)
	trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu ', 15)
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
bc:registerShopItem('recon', 'Deploy recon group (for combined arms)', ShopPrices.recon, function(sender)
	
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
bc:registerShopItem('airdef', 'Deploy air defence (for combined arms)', ShopPrices.airdef, function(sender)
	
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
bc:registerShopItem('jtac','MQ-9 Reaper JTAC mission',ShopPrices.jtac,function(sender)
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

local flaretargets = function(tz)
	if not tz or not tz.built then
		env.info("flaretargets: no tz/built for zone "..tostring(tz and tz.zone or "nil"))
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
		local az = math.random(0,359)
		trigger.action.signalFlare(points[idx], trigger.flareColor.Red, az)
		table.remove(points,idx)
	end
end

local illumtargets = function(tz)
	if not tz or not tz.built then
		env.info("illumtargets: no tz/built for zone "..tostring(tz and tz.zone or "nil"))
		return
	end
	local groups, units, statics, dangling, toRemove = {}, {}, {}, {}, {}
	for i,v in pairs(tz.built) do
		local g = Group.getByName(v)
		if g and g:isExist() then
			table.insert(groups, g)
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
	local illumAltitude = 600
	local illumPower = 400000

	local targets = {}
	local function addPos(p)
		if p then table.insert(targets, p) end
	end
	local function addGroupLeaderPos(g)
		if not g then return end
		local u = g:getUnit(1)
		if u and u:isExist() then
			local p = u:getPosition().p
			addPos(p)
		end
	end
	local function addRandomUnitPos(pool)
		if not pool or #pool == 0 then return end
		local idx = math.random(1, #pool)
		local u = pool[idx]
		if u and u:isExist() then
			local p = u:getPosition().p
			addPos(p)
		end
		table.remove(pool, idx)
	end

	if #groups >= 3 then
		local gpool = {}
		for _,g in ipairs(groups) do table.insert(gpool, g) end
		for i=1,3 do
			local idx = math.random(1, #gpool)
			addGroupLeaderPos(gpool[idx])
			table.remove(gpool, idx)
		end
	elseif #groups == 2 then
		addGroupLeaderPos(groups[1])
		addGroupLeaderPos(groups[2])
		local upool = {}
		for _,u in ipairs(units) do table.insert(upool, u) end
		if #upool > 0 then
			addRandomUnitPos(upool)
		elseif #statics > 0 then
			local s = statics[math.random(1, #statics)]
			addPos(s:getPoint())
		end
	elseif #groups == 1 then
		local gUnits = groups[1]:getUnits() or {}
		local upool = {}
		for _,u in ipairs(gUnits) do table.insert(upool, u) end
		if #upool == 0 then
			for _,u in ipairs(units) do table.insert(upool, u) end
		end
		for i=1,3 do
			if #upool == 0 then break end
			addRandomUnitPos(upool)
		end
	else
		local spoints = {}
		for _,s in ipairs(statics) do
			local p = s:getPoint()
			if p then table.insert(spoints, p) end
		end
		for i=1,3 do
			if #spoints == 0 then break end
			local idx = math.random(1, #spoints)
			addPos(spoints[idx])
			table.remove(spoints, idx)
		end
	end

	for _,p in ipairs(targets) do
		local bombPoint = { x = p.x, y = p.y + illumAltitude, z = p.z }
		trigger.action.illuminationBomb(bombPoint, illumPower)
	end
end

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
bc:registerShopItem('smoke', 'Smoke markers ', ShopPrices.smoke, function(sender)
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
	
	trigger.action.outTextForCoalition(2, 'Choose target zone from F10 menu ', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		smoketargets(params.zone)
		trigger.action.outTextForCoalition(2, 'Targets marked with RED smoke at '..params.zone.zone, 15)
	else
		return 'Can only target enemy zone'
	end
end)

local flareTargetMenu = nil
bc:registerShopItem('flare', 'Flare markers', ShopPrices.flare, function(sender)
	if flareTargetMenu then
		return 'Choose target zone from F10 menu'
	end

	local launchAttack = function(target)
		if flareTargetMenu then
			local tz = bc:getZoneByName(target)
			flaretargets(tz)
			flareTargetMenu = nil
			trigger.action.outTextForCoalition(2, 'Targets marked with RED flare at '..target, 15)
		end
	end

	flareTargetMenu = bc:showTargetZoneMenu(2, 'Flare marker target', launchAttack, 1)

	trigger.action.outTextForCoalition(2, 'Choose target zone from F10 menu', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		flaretargets(params.zone)
		trigger.action.outTextForCoalition(2, 'Targets marked with RED flare at '..params.zone.zone, 15)
	else
		return 'Can only target enemy zone'
	end
end)

local illumTargetMenu = nil
bc:registerShopItem('illum', 'Illumination bomb', ShopPrices.illum, function(sender)
	if illumTargetMenu then
		return 'Choose target zone from F10 menu'
	end

	local launchAttack = function(target)
		if illumTargetMenu then
			local tz = bc:getZoneByName(target)
			illumtargets(tz)
			illumTargetMenu = nil
			trigger.action.outTextForCoalition(2, 'Targets illuminated at '..target, 15)
		end
	end

	illumTargetMenu = bc:showTargetZoneMenu(2, 'Illumination target', launchAttack, 1)

	trigger.action.outTextForCoalition(2, 'Choose target zone from F10 menu', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 1 then
		illumtargets(params.zone)
		trigger.action.outTextForCoalition(2, 'Targets illuminated at '..params.zone.zone, 15)
	else
		return 'Can only target enemy zone'
	end
end)

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
bc:registerShopItem('9lineam', 'Jtac 9line AM', ShopPrices["9lineam"], function(sender)
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
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        droneAM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = Era == 'Coldwar' and 'JTAC9lineamColdwar' or 'JTAC9lineam'}
        trigger.action.outTextForCoalition(2, 'Reaper drone deployed over ' .. params.zone.zone .. '. Contact Springfield on 241.00 AM ', 30)
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
bc:registerShopItem('9linefm', 'Jtac 9line FM', ShopPrices["9linefm"], function(sender)
    if jtacTargetMenu3 then
        return 'Choose target zone from F10 menu'
    end
    
    local spawnAndOrbit3 = function(target)
        if jtacTargetMenu3 then
            local zn = bc:getZoneByName(target)
            droneFM:deployAtZone(zn)
			
			jtacZones[target] = {drone = Era == 'Coldwar' and 'JTAC9linefmColdwar' or 'JTAC9linefm'}
			
		trigger.action.outTextForCoalition(2, 'Reaper drone deployed over ' .. target .. '. Contact Uzi on 31.00 FM ', 30)            
            jtacTargetMenu3 = nil
        end
    end
    
    jtacTargetMenu3 = bc:showTargetZoneMenu(2, 'Deploy JTAC to Zone', spawnAndOrbit3, 1)
    trigger.action.outTextForCoalition(2, 'Choose which zone to deploy JTAC at from F10 menu', 15)
end,
function(sender, params)
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
        droneFM:deployAtZone(params.zone)
        jtacZones[params.zone.zone] = {drone = Era == 'Coldwar' and 'JTAC9linefmColdwar' or 'JTAC9linefm'}
        trigger.action.outTextForCoalition(2, 'Reaper drone deployed over ' .. params.zone.zone .. '. Contact Uzi on 31.00 FM ', 30)
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
local supplyMenu=nil
bc:registerShopItem('capture','Emergency capture neutral zone',ShopPrices.capture,
function(sender)
	if NoAIBlueSupplies == true then 
		return 'Blue AI supplies are disabled' 
	end
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

-----------------------------------------------DYNAMIC SHOP ------------------------------------------


bc:registerShopItem('dynamiccap', 'Dynamic CAP', ShopPrices.dynamiccap, function(sender)
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
---
bc:registerShopItem('dynamicarco', 'Unlock Tanker (Drogue)', ShopPrices.dynamicarco, function(sender)
    if ArcoActive then
        return 'Arco is still airborne'
    end
		if ArcoParentMenu then
		return 'Choose spawn zone from F10 menu'
	end
    buildArcoMenu()
	trigger.action.outTextForCoalition(2, '(Drogue) Tanker is unlocked. Select spawn zone.', 20)
    return
end,
function (sender, params)
    if ArcoActive then
        return 'Arco is still airborne'
    end
    buildArcoMenu()

	trigger.action.outTextForCoalition(2, '(Drogue) Tanker is unlocked. Select spawn zone.', 20)
    return
end)

bc:registerShopItem('dynamictexaco', 'Unlock Tanker (Boom)', ShopPrices.dynamictexaco, function(sender)
    if TexacoActive then
        return 'Texaco is still airborne'
    end
		if TexacoParentMenu then
		return 'Choose spawn zone from F10 menu'
	end
    buildTexacoMenu()
	trigger.action.outTextForCoalition(2, '(Boom) Tanker is unlocked. Select spawn zone.', 20)
    return
end,
function (sender, params)
    if TexacoActive then
        return 'Texaco is still airborne'
    end
    buildTexacoMenu()

	trigger.action.outTextForCoalition(2, '(Boom) Tanker is unlocked. Select spawn zone.', 20)
    return
end)
---
bc:registerShopItem('dynamiccas', 'Dynamic CAS', ShopPrices.dynamiccas,
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
        if params.zone and params.zone.side == 1 and not params.zone.suspended then
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

bc:registerShopItem('dynamicdecoy', 'Dynamic Decoy', ShopPrices.dynamicdecoy,
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
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
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


bc:registerShopItem('dynamicsead', 'Dynamic SEAD', ShopPrices.dynamicsead,
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
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
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

bc:registerShopItem('dynamicbomb', 'Dynamic Bomb run', ShopPrices.dynamicbomb,
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
    if params.zone and params.zone.side == 1 and not params.zone.suspended then
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
bc:registerShopItem('Dynamicstatic', 'Dynamic building Strike', ShopPrices.dynamicstatic,
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

local intelMenu=nil
bc:registerShopItem('intel','Intel on enemy zone',ShopPrices.intel,function(sender)
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
				if intelActiveZones[zName] then intelActiveZones[zName] = false end
				local zn = bc:getZoneByName(zName)
				if zn and zn.updateLabel then zn:updateLabel() end
				trigger.action.outTextForCoalition(2, 'Intel on '..zName..' has expired.', 10)
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
			if intelActiveZones[zName] then intelActiveZones[zName] = false end
			local zn = bc:getZoneByName(zName)
			if zn and zn.updateLabel then zn:updateLabel() end
			trigger.action.outTextForCoalition(2, 'Intel on '..zName..' has expired.', 10)
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
           and not z.zone:lower():find("carrier") then
			t[z.zone] = true
		end
	end
	return t
end

local function buildLogisticAllowTable()
    local allowed = {}
    for _, z in pairs(bc:getZones()) do
        if z.side == 2 and z.airbaseName and not z.LogisticCenter and not z.isHidden then
            allowed[z.zone] = true
        end
    end
    return allowed
end

-- Red AI zone upgrade helpers
local function buildRedAllowTable()
	local t = {}
	for _, z in pairs(bc:getZones()) do
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		local used = (type(z.getUpgradesUsed) == "function") and z:getUpgradesUsed(1) or (z.upgradesUsed or 0)
		if z.side == 1 and z.active and not z.suspended and not z.isHidden
		   and not z.zone:lower():find("carrier")
		   and used < max then
			t[z.zone] = true
		end
	end
	return t
end

local function normalizeBuiltName(name)
	return name and name:gsub("#%d+$", "") or name
end

local function buildStaticNameSet(zoneObj)
	local statics = {}
	for _, data in ipairs(zoneObj.newStatics or {}) do
		if data and data.name then
			statics[data.name] = true
			local base = normalizeBuiltName(data.name)
			if base then
				statics[base] = true
			end
		end
	end
	return statics
end

local function buildBuiltNameSet(zoneObj)
	local built = {}
	for _, name in pairs(zoneObj.built or {}) do
		local base = normalizeBuiltName(name)
		if base then
			built[base] = true
		end
	end
	return built
end

local function buildUpgradeNameSet(zoneObj)
	local names = {}
	for _, name in ipairs(zoneObj.upgrades and zoneObj.upgrades.red or {}) do
		local base = normalizeBuiltName(name)
		if base then
			names[base] = true
		end
	end
	return names
end

local function resolveMinMax(val)
	if type(val) == "table" then
		local minv = val[1] or 0
		local maxv = val[2] or minv
		return minv, maxv
	end
	if type(val) == "number" then
		return val, val
	end
	return 0, 0
end

local function countZoneRedCategories(zoneObj)
	local counts = { sam = 0, shorad = 0, aaa = 0, ground = 0, armor = 0, arty = 0 }
	for _, name in ipairs(zoneObj.upgrades and zoneObj.upgrades.red or {}) do
		if name and not isStaticUpgrade(name) then
			local cat = classifyUpgradeName(name)
			if counts[cat] ~= nil then
				counts[cat] = counts[cat] + 1
			end
		end
	end
	return counts
end

local function buildRedPoolsForZone(zoneObj)
	local zoneSize = getZoneSize(zoneObj)
	local pools = { sam = {}, shorad = {}, aaa = {}, ground = {}, armor = {}, arty = {}, other = {} }
	fillPoolsFrom(getGlobalRedPool(), pools, zoneSize)
	local existing = buildUpgradeNameSet(zoneObj)

	local function filterPool(src)
		local out = {}
		for _, name in ipairs(src or {}) do
			local base = normalizeBuiltName(name)
			if base and not existing[base] then
				out[#out+1] = name
			end
		end
		return out
	end

	for k, v in pairs(pools) do
		pools[k] = filterPool(v)
	end
	return pools
end

local function chooseRedUpgradeCategory(counts, template)
	local order = { "sam", "shorad", "aaa", "ground", "armor", "arty" }
	local deficits = {}
	for _, cat in ipairs(order) do
		local minv = resolveMinMax(template and template[cat])
		local have = counts[cat] or 0
		deficits[cat] = math.max(0, minv - have)
	end
	if deficits.sam and deficits.sam > 0 then
		return "sam"
	end
	for i = 2, #order do
		local cat = order[i]
		if deficits[cat] and deficits[cat] > 0 then
			return cat
		end
	end
	local bestCat, bestCount = nil, nil
	for _, cat in ipairs(order) do
		local have = counts[cat] or 0
		if bestCount == nil or have < bestCount then
			bestCount = have
			bestCat = cat
		end
	end
	return bestCat
end

local function pickRedUpgradeForZone(zoneObj)
	local zoneSize = getZoneSize(zoneObj)
	local template = RandomUpgradeTemplates and RandomUpgradeTemplates[zoneSize]
	if not template then
		return nil
	end
	local counts = countZoneRedCategories(zoneObj)
	local pools = buildRedPoolsForZone(zoneObj)
	local order = { "sam", "shorad", "aaa", "ground", "armor", "arty" }

	local cat = chooseRedUpgradeCategory(counts, template)
	if cat and pools[cat] and #pools[cat] > 0 then
		return pools[cat][math.random(1, #pools[cat])]
	end

	for _, alt in ipairs(order) do
		if pools[alt] and #pools[alt] > 0 then
			return pools[alt][math.random(1, #pools[alt])]
		end
	end

	if pools.other and #pools.other > 0 then
		return pools.other[math.random(1, #pools.other)]
	end
	return nil
end

local function getRedUpgradeCandidates(zoneObj)
	local candidates = {}
	if not (zoneObj and zoneObj.upgrades and zoneObj.upgrades.red) then
		return candidates
	end
	local built = buildBuiltNameSet(zoneObj)
	local statics = buildStaticNameSet(zoneObj)
	for _, name in ipairs(zoneObj.upgrades.red) do
		if name then
			local base = normalizeBuiltName(name)
			local lname = name:lower()
			if not statics[name] and not statics[base] and not lname:find("fixed") then
				if not built[base] then
					candidates[#candidates+1] = name
				end
			end
		end
	end
	return candidates
end

local RED_ZONE_UPGRADE_ID = "redzoneupgrade"
local RED_ZONE_UPGRADE_COST = 5000

local function redZoneUpgradeAction()
	local allow = buildRedAllowTable()
	if not next(allow) then
		return "No eligible red zones"
	end

	local zoneChoices = {}
	for zName,_ in pairs(allow) do
		local z = bc:getZoneByName(zName)
		if z then
			local slot = pickRedUpgradeForZone(z)
			if slot then
				zoneChoices[#zoneChoices+1] = { zone = z, slot = slot }
			end
		end
	end
	if #zoneChoices == 0 then
		return "No valid upgrades"
	end

	local pick = zoneChoices[math.random(1,#zoneChoices)]
	local zoneObj = pick.zone
	local slot = pick.slot

	local ok = zoneObj:addExtraSlot(slot)
	if not ok then
		return "Zone already upgraded"
	end
	if type(zoneObj.updateLabel) == "function" then
		zoneObj:updateLabel()
	end
	zoneObj:upgrade(true)
	trigger.action.outText("Red forces reinforced at "..zoneObj.zone, 10)
	return true
end

bc:registerShopItem(RED_ZONE_UPGRADE_ID, "Red zone upgrade", RED_ZONE_UPGRADE_COST, redZoneUpgradeAction)

local RED_MASS_ATTACK_ID = "redmassattack"
local RED_MASS_ATTACK_COST = 6000

local function redMassAttackAction()
	if not bc.triggerRedMassAttack then
		return "Mass attack unavailable"
	end
	return bc:triggerRedMassAttack()
end

bc:registerShopItem(RED_MASS_ATTACK_ID, "Red mass airbase attack", RED_MASS_ATTACK_COST, redMassAttackAction)


local function buildWarehouseResupplyAllowTable()
    local allowed = {}
    if not WarehouseLogistics then
        return allowed
    end
    for _, z in pairs(bc:getZones()) do
        if z.side == 2 and z.airbaseName and not z.LogisticCenter and not z.isHidden then
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
bc:registerShopItem('zinf','Add infantry squad to zone',ShopPrices.zinf,function(sender)
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
	if params.zone and params.zone.side==2 and not params.zone.suspended then
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
bc:registerShopItem('zsam',samLabel,ShopPrices.zsam,function(sender)
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
            local slot = (Era == 'Coldwar') and 'blueHAWK Coldwar' or 'bluePD1'
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
	if params.zone and params.zone.side==2 and not params.zone.suspended then
		local max = 1 + (bc.globalExtraUnlock and 1 or 0)
		if params.zone.upgradesUsed >= max then
			if not bc.globalExtraUnlock then
				return 'Zone already upgraded - purchase Global extra slot to add another'
			end
			return 'Zone already upgraded'
		end
		params.zone:addExtraSlot((Era == 'Coldwar') and 'blueHAWK Coldwar' or 'bluePD1')
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

local himarsMenu=nil
bc:registerShopItem('zhimars','Add HIMARS to a zone',ShopPrices.zhimars,function(sender)
	if himarsMenu then
		return 'Already choosing a zone'
	end
	local pickZone=function(zName)
		if himarsMenu then
			local z=bc:getZoneByName(zName)
			if not z or z.side~=2 or z.suspended then
				return 'Must pick friendly zone'
			end
			if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
				return 'Zone already upgraded'
			end
			z:addExtraSlot('HiMars')
			z:updateLabel()
			if bc.globalExtraUnlock then
				trigger.action.outTextForCoalition(2,'HIMARS added to '..zName..' for '..tostring(ShopPrices.zhimars),10)
			else
				trigger.action.outTextForCoalition(2,'HIMARS added to '..zName..' for '..tostring(ShopPrices.zhimars)..' - buy the Global extra slot to upgrade this zone again',30)
			end
			missionCommands.removeItemForCoalition(2,himarsMenu)
			himarsMenu=nil
		end
	end
	local allow = buildAllowTable()
	if not next(allow) then
		if not bc.globalExtraUnlock then
			return 'All zones already upgraded - purchase Global extra slot to add another'
		end
		return 'No eligible zone'
	end
	himarsMenu = bc:showTargetZoneMenu(2,'Choose Zone for HIMARS',pickZone,2,nil,allow)
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
		params.zone:addExtraSlot('HiMars')
		params.zone:updateLabel()
		if bc.globalExtraUnlock then
			trigger.action.outTextForCoalition(2,'HIMARS added to '..params.zone.zone..' for '..tostring(ShopPrices.zhimars),10)
		else
			trigger.action.outTextForCoalition(2,'HIMARS added to '..params.zone.zone..' for '..tostring(ShopPrices.zhimars)..' - buy the Global extra slot to upgrade this zone again',30)
		end
	else
		return 'Must pick friendly zone'
	end
end)

local logiMenu=nil
bc:registerShopItem('zlogc','Upgrade zone to logistic center',ShopPrices.zlogc,function(sender)
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
bc:registerShopItem('zwh50','Resupply warehouse with 50',ShopPrices.zwh50,function(sender)
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
bc:registerShopItem('zarm','Add armor group to a zone',ShopPrices.zarm,function(sender)
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
	if params.zone and params.zone.side==2 and not params.zone.suspended then
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
Group.getByName('bluePATRIOT'):destroy()
local patMenu=nil
bc:registerShopItem('zpat','Add Patriot system to zone',ShopPrices.zpat,function(sender)
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
	if params.zone and params.zone.side==2 and not params.zone.suspended then
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

bc:registerShopItem('gslot','Unlock extra upgrade slot',ShopPrices.gslot,function(sender)
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

bc:registerShopItem('farphere','Deploy FARP',ShopPrices.farphere,function(sender)
        return 'Deploy a FARP via map marker.\nUse marker text: buy:farphere.\nMust be outside all zones and at least 10 NM from enemy zones.'
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
	zinf          = 500,  -- Add infantry squad to zone
	zsam          = 2000, -- Add Hawk/Nasams system to a zone
	zhimars       = 2500, -- Add HIMARS to a zone
	zlogc         = 2000, -- Upgrade zone to logistic center
	zwh50         = 500,  -- Resupply warehouse with 50
	zarm          = 1000, -- Add armor group to a zone
	zpat          = 5000, -- Add Patriot system to zone
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
	zinf           = 5,  -- Add infantry squad to zone
	zarm           = 7,  -- Add armor group to a zone
	zsam           = 6,  -- Add Hawk/Nasams system to a zone
	zhimars        = 8,  -- Add HIMARS to a zone
	zlogc          = 1,  -- Upgrade zone to logistic center
	zwh50          = 2,  -- Resupply warehouse with 50
	gslot          = 9,  -- Unlock extra upgrade slot
	zpat           = 8,  -- Add Patriot system to zone
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
bc:addShopItem(2, 'jtac', -1, 1, ShopRankRequirements.jtac) -- MQ-9 Reaper JTAC mission
bc:addShopItem(2, 'dynamiccap', -1, 2, ShopRankRequirements.dynamiccap) -- CAP

bc:addShopItem(2, 'dynamiccas', -1, 3, ShopRankRequirements.dynamiccas) -- CAS
bc:addShopItem(2, 'dynamicbomb', -1, 4, ShopRankRequirements.dynamicbomb) -- Bomber
bc:addShopItem(2, 'dynamicsead', -1, 5, ShopRankRequirements.dynamicsead) -- SEAD
bc:addShopItem(2, 'dynamicdecoy', -1, 6, ShopRankRequirements.dynamicdecoy) -- Decoy flight
if UseStatics == true then
	bc:addShopItem(2, 'dynamicstatic', -1,7, ShopRankRequirements.dynamicstatic) -- Static buildings
end
bc:addShopItem(2, 'dynamicarco', 1, 8, ShopRankRequirements.dynamicarco) -- Navy tanker
bc:addShopItem(2, 'dynamictexaco', 1, 9, ShopRankRequirements.dynamictexaco) -- Airforce tanker
bc:addShopItem(2, 'farphere', -1, 10, ShopRankRequirements.farphere)
bc:addShopItem(2, 'capture', -1, 11, ShopRankRequirements.capture) -- emergency capture
bc:addShopItem(2, 'smoke', -1, 12, ShopRankRequirements.smoke) -- smoke on target
bc:addShopItem(2, 'flare', -1, 13, ShopRankRequirements.flare) -- flare on target
bc:addShopItem(2, 'illum', -1, 14, ShopRankRequirements.illum) -- illumination bomb
bc:addShopItem(2, 'intel', -1, 15, ShopRankRequirements.intel) -- Intel
bc:addShopItem(2, 'supplies2', -1, 16, ShopRankRequirements.supplies2) -- upgrade friendly zone
bc:addShopItem(2, 'supplies', -1, 17, ShopRankRequirements.supplies) -- fully upgrade friendly zone
bc:addShopItem(2, 'zinf', -1, 18, ShopRankRequirements.zinf) -- add infantry to a zone
bc:addShopItem(2, 'zarm', -1, 19, ShopRankRequirements.zarm) -- add armour group to a zone
bc:addShopItem(2, 'zsam', -1, 20, ShopRankRequirements.zsam) -- add Nasams to a zone
bc:addShopItem(2, 'zhimars', -1, 21, ShopRankRequirements.zhimars) -- add HIMARS to a zone
bc:addShopItem(2, 'zlogc', -1, 21, ShopRankRequirements.zlogc) -- upgrade zone to logistic center
bc:addShopItem(2, 'zwh50', -1, 22, ShopRankRequirements.zwh50) -- resupply warehouse with 50
bc:addShopItem(2, 'gslot', 1, 23, ShopRankRequirements.gslot) -- add another slot for upgrade
if Era == 'Modern' then
	bc:addShopItem(2, 'zpat', -1, 24, ShopRankRequirements.zpat) -- Patriot system.
end
bc:addShopItem(2, 'armor', -1, 25, ShopRankRequirements.armor) -- combined arms
bc:addShopItem(2, 'artillery', -1, 26, ShopRankRequirements.artillery) -- combined arms
bc:addShopItem(2, 'recon', -1, 27, ShopRankRequirements.recon) -- combined arms
bc:addShopItem(2, 'airdef', -1, 28, ShopRankRequirements.airdef) -- combined arms
bc:addShopItem(2, '9lineam', -1, 29, ShopRankRequirements["9lineam"]) -- free jtac
bc:addShopItem(2, '9linefm', -1, 30, ShopRankRequirements["9linefm"]) -- free jtac
bc:addShopItem(2, 'cruisemsl', 12, 31, ShopRankRequirements.cruisemsl) -- Cruise missiles

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
    'Kastrup City'
}

lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

bc:loadFromDisk()
if not bc.saveLoaded then
	applyRandomRedUpgrades()
	applyRandomBlueUpgrades()
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

GlobalSettings.autoSuspendNmBlue = 90   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 100   		-- suspend red zones deeper than this nm


evc = EventCommander:new({ decissionFrequency=10*60, decissionVariance=10*60, skipChance = 10})
mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})
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
        RegisterGroupTarget(bomberGrp,250,'Intercept enemy bombers','bomb')
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
	title="Intercept Bombers",
	description=function() return "Enemy bombers spotted inbound from the "..currentOrigin.."\nDestroy them before they get in range." end,
	messageStart=function() return "New mission: Intercept Bombers inbound from the "..currentOrigin end,
	messageEnd=function() lastbomb_COOLDOWN=timer.getTime() return "Mission ended: Intercept Bombers" end,
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
        RegisterGroupTarget(attackGrp,250,'Intercept enemy bombers','cas')
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
	title = "Defend Frankfurt",
	description = "The enemy is preparing an all out attack on Frankfurt.\nDefend the airfield at all cost.",
	messageStart = "New mission: Defend Frankfurt",
	messageEnd = function() lastFrankfurtEnd = timer.getTime() return "Mission ended: Defend Frankfurt" end,
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


mc:trackMission({
    title = "Destroy artillery headed toward Frankfurt",
    description = "Artillery has been spotted heading towards Frankfurt from the direction of Laubach FARP.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
        RegisterGroupTarget('Laubach FARP-attack-frankfurt',100,'Destroy artillery','Laubach FARP-attack-frankfurt')
    end,
    endAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
    end,
    isActive = function()
        if not ActiveMission['Laubach FARP-attack-frankfurt'] then return false end
        if Group.getByName('Laubach FARP-attack-frankfurt') then return true end
        ActiveMission['Laubach FARP-attack-frankfurt'] = nil
        return false
    end
})

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted south of Mendig headed to Hahn.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery headed to Hahn",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Mendig-attack-Hahn-Arty',250,'Destroy artillery','Mendig-attack-Hahn-Arty')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Mendig-attack-Hahn-Arty'] then return false end
        if Group.getByName('Mendig-attack-Hahn-Arty') then return true end
        ActiveMission['Mendig-attack-Hahn-Arty'] = nil
        return false
    end
})


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
		RegisterGroupTarget(planes[1],250,'Intercept cargo plane','cargointercept')
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
    title = "Intercept cargo plane",
    description = function()
		if Group.getByName('evt-cargointercept1') then
			return "Find and destroy the cargo plane headed to Mahlwinkel\ninbound from the west."
		elseif Group.getByName('evt-cargointercept2') then
			return "Find and destroy the cargo plane headed to Hannover\ninbound from the southeast."
		elseif Group.getByName('evt-cargointercept3') then
			return "Find and destroy the cargo plane headed to Peenemunde\ninbound from the southwest."
		else
			return "Cargo plane is no longer active."
		end
	end,
    messageStart = "New mission: Intercept cargo plane",
    messageEnd =function() lastCargo_COOLDOWN=timer.getTime() return "Mission ended: Intercept cargo plane" end,
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
		RegisterScoreTarget('HannoverSupply',tgt,100,'Hannover supply warehouse',true)
        local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
        if p then
            missionMarkId = missionMarkId + 1
            trigger.action.markToCoalition(missionMarkId,"Hannover supply warehouse",p,2,false,false)
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
	title = "Strike Hannover supply warehouse",
	description = 
[[Strike Hannover supply warehouse to cripple the supplies to
the 2 SAM sites in the area.

Coordinates:
MGRS: 32 U ND 47006 12542
Lat long: N 52°27'39" E 09°41'30"
Lat long Decimal Minutes: N 52°27.661' E 09°41.511'
Elevation: 168 feet

reward = 100]],
	messageStart = "New strike mission: Strike Hannover supply warehouse\nCoords are in the mission description",
	messageEnd = "Mission ended: Strike Hannover supply warehouse",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["HannoverSupply"] then return false end
    if ActiveMission['HannoverSupply'] then return true end
	  return false
	end,
})
-------------------------------------------------- End of Hannover Supply ----------------------------------------------------

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
		RegisterScoreTarget('NaziGroup',tgt,500,'Strike the Nazis')
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"Strike the Nazis",p,2,false,false)
			MissionMarks['NaziReunion'] = missionMarkId
		end
	end,
	canExecute = function()
		if CustomFlags['NaziReunion'] then return false end
		if ActiveMission['NaziReunion'] then return false end
		if bc:getZoneByName('Bremen').side ~= 2 or bc:getZoneByName('Bremen').suspended then return false end
		return true
	end
})
mc:trackMission({
	title = "Strike the Nazi reunion",
	description = 
[[We have intel on a bunch of Nazis holding a reunion at theese coordinates:

MK84 ?

MGRS: 32 U ME 73392 36057
Lat long: N 53°34'21" E 8°35'53"
Lat long Decimal Minutes: N 53°34.362' E 08°35.891'
Lat Long Precise: N 53°34'21.72" E 08°35'53.46"
Elevation: 10 feet

reward = 500]],
	messageStart = "New strike mission: Strike the Nazi reunion\nCoords are in the mission description",
	messageEnd = "Mission ended: Strike the Nazi reunion",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["NaziReunion"] then return false end
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
		RegisterScoreTarget('Striketarget2',tgt,500,'Kill the commander',true)
        local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
        if p then
            missionMarkId = missionMarkId + 1
            trigger.action.markToCoalition(missionMarkId,"Kill the commander",p,2,false,false)
            MissionMarks['Striketarget2'] = missionMarkId
        end
	end,
	canExecute = function()
		if CustomFlags['Striketarget2'] then return false end
		if ActiveMission['Striketarget2'] then return false end
		if bc:getZoneByName('Hahn').side ~= 2 or bc:getZoneByName('Hahn').suspended then return false end
		return true
	end
})
mc:trackMission({
	title = "Kill the commander",
	description = 
[[We have intel on a bunch of Nazi commanders at theese coordinates:

MGRS: 32 U MV 39796 91529
Lat long: N 49°34'24" E 08°10'02"
Lat long Decimal Minutes: N 49°34.401' E 08°10.037'
Lat Long Precise: N 49°34'24.08" E 08°10'02.27"
Elevation: 577 feet

reward = 500]],
	messageStart = "New strike mission: Kill the commander\nCoords are in the mission description",
	messageEnd = "Mission ended: Kill the commander",
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
--------------------------------------------- End Nazi reunion ---------------------------------------------------

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
        RegisterScoreTarget('KommandantGunter',tgt,500,'Kill Kommandant Günter',true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"Kill Kommandant Günter",p,2,false,false)
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
	title = "Kill Kommandant Günter",
description = 
[[We have the Kommandant Günter location, He is
south of Hildesheim Airport, Take him out!.

Coordinates:
MGRS: 32 U NC 66314 77828
Lat Long: N 52°08'49" E  09°58'08"
Lat long Decimal Minutes: N 52°08.818' E 09°58.149'

Elevation: 394 feet

Reward: 500

Destroy the house and whoever is nearby.]],

	messageStart = "New strike mission: Kill Kommandant Günter",
	messageEnd = "Strike mission ended: Kill Kommandant Günter\nCoords are in the mission description",
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
		RegisterScoreTarget('StrikeTarget1',tgt,500,'Strike enemy communication tower',true)
        local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
        if p then
            missionMarkId = missionMarkId + 1
            trigger.action.markToCoalition(missionMarkId,"Strike enemy communication tower",p,2,false,false)
            MissionMarks['StrikeTarget1'] = missionMarkId
        end
	end,
	canExecute = function()
		if CustomFlags['StrikeTarget1'] then return false end
		if ActiveMission['StrikeTarget1'] then return false end
		if bc:getZoneByName('Fritzlar').side ~= 2 or bc:getZoneByName('Fritzlar').suspended then return false end
		return true
	end
})
mc:trackMission({
	title = "Strike enemy communication tower",
	description = 
[[Strike enemy communication tower at these coordinates:

MGRS: 32 U NC 51769 29542
Lat long: N 51°42'51" E 09°44'57"
Lat long Decimal Minutes: N 51°42.865' E 09°44.960'
Elevation: 1378 feet

reward = 500]],
	messageStart = "New strike mission: Strike enemy communication tower",
	messageEnd = "Mission ended: Strike enemy communication tower",
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
    title = "Escort cargo plane from Frankfurt",
    description = "Friendly cargo plane is taking off from Frankfurt. Protect it until it leaves the airspace.",
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

Group.getByName('EnemScuds'):destroy()
evc:addEvent({
	id='scuds',
	action=function()
		RespawnGroup('EnemScuds')
        RegisterGroupTarget('EnemScuds',250,'Destroy enemy Scuds','ScudsIsDestroyed',true)


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
				trigger.action.outTextForCoalition(2,'Enemy SCUDs launching at '..choice,15)
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
    title = "Destroy enemy SCUDS",
	description = 
[[Strike enemy scuds before they fire.

Coordinates:
MGRS: 32 U PC 28469 06081
Lat long: N 51°29'28" E 10°51'01"
Lat long Decimal Minutes: N 51°29.476' E 10°51.031'

Elevation: 623 feet

reward = 500]],
    messageStart = "New mission: Destroy enemy Scuds\nCoords are in the mission description",
    messageEnd = "Mission ended: Destroy SCUDS",
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
--                      RUN WAY STRIKE MISSION                     --

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
--                      END OF RUN WAY STRIKE MISSION              --

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


function generateSEADMission()
    if seadTarget then return true end
    if not attackTarget then return false end

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

    if #validSEADZones == 0 then return false end
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
    if deadTarget then return true end
    if seadTarget then return true end
    if not attackTarget then return false end

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

    if #validDEADZones == 0 then return false end

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
    if attackTarget ~= nil then return true end

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

    if #validzones == 0 then return false end

    local choice = math.random(1, #validzones)
    if validzones[choice] then
        attackTarget = validzones[choice]
        return true
    end
end

function generateSupplyMission()
	if resupplyTarget ~= nil then return true end
		
	local validzones = {}
	for _,v in ipairs(bc.zones) do
		if v.side == 2 and not v.suspended and v:canRecieveSupply() then
			table.insert(validzones, v.zone)
		end
	end
	
	if #validzones == 0 then return false end
	
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
evc:init()
----------------------- FLAGS --------------------------
--[[ function checkZoneFlags()

    if trigger.misc.getUserFlag("3") == 0 and zones.frankfurt.active and zones.frankfurt.wasBlue then
        trigger.action.setUserFlag("3", true)
    end
    if trigger.misc.getUserFlag("4") == 0 and zones.bindersleben.active and zones.bindersleben.wasBlue then
        trigger.action.setUserFlag("4", true)
        trigger.action.setUserFlag("3", false)
    end
    if trigger.misc.getUserFlag("5") == 0 and zones.braunschweig.wasBlue and not zones.fassberg.wasBlue then
        trigger.action.setUserFlag("5", true)
        trigger.action.setUserFlag("21", true)
    end
    if trigger.misc.getUserFlag("6") == 0 and zones.fassberg.wasBlue and not zones.werneuchen.wasBlue then
        trigger.action.setUserFlag("6", true)
        trigger.action.setUserFlag("5", false)
    end
    if trigger.misc.getUserFlag("7") == 0 and zones.werneuchen.wasBlue and zones.fassberg.wasBlue and (not zones.parchim.wasBlue) then
        trigger.action.setUserFlag("7", true)
        trigger.action.setUserFlag("6", false)
        trigger.action.setUserFlag("5", false)
    end
    if trigger.misc.getUserFlag("20") == 0 and zones.mahlwinkel.wasBlue then
        trigger.action.setUserFlag("20", true)
    end
        if trigger.misc.getUserFlag("8") == 0 and zones.neuruppin.wasBlue and (not zones.parchim.wasBlue) and zones.templin.wasBlue then
        trigger.action.setUserFlag("8", true)
    end
    if trigger.misc.getUserFlag("8") == 0 and IsGroupActive('awacs') and zones.fulda.active and zones.fulda.wasBlue then -- only tanker to move them down east of fulda.
        trigger.action.setUserFlag("8", true)
    end
    if trigger.misc.getUserFlag("9") == 0 and not zones.fassberg.active and not zones.parchim.wasBlue and zones.werneuchen.wasBlue then -- only tanker to move them down east of fulda.
        trigger.action.setUserFlag("9", true)
        trigger.action.setUserFlag("8", false)
        trigger.action.setUserFlag("7", false)
        trigger.action.setUserFlag("6", false)
        trigger.action.setUserFlag("5", false)
    end
        if trigger.misc.getUserFlag("10") == 0 and zones.larz.active and zones.parchim.wasBlue then -- only tanker to move them down east of fulda.
        trigger.action.setUserFlag("10", true)
        trigger.action.setUserFlag("9", false)
        trigger.action.setUserFlag("8", false)
        trigger.action.setUserFlag("7", false)
        trigger.action.setUserFlag("6", false)
        trigger.action.setUserFlag("5", false)
    end

end 
timer.scheduleFunction(function()
    checkZoneFlags()
    return timer.getTime() + 30
end, {}, timer.getTime() + 3) ]]


buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end

airbaseStatics = {
}

-------------------------- END OF FLAGS --------------------------

env.info("Mission Setup : is completed!")
