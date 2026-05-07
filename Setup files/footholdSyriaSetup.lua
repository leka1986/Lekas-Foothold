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


upgrades = {
	ships = {
		blue = {'blueShip'},
		red = {'Molniya','Molniya','Rezky','Rezky','Neustrashimy','Neustrashimy'}
	},
	carrier = {
		blue = {'blueShip', 'blueShip', 'blueShip'},
		red = {'Molniya'}
	},
	carrierFixed = {
		blue = {'blueShip-Fixed-1', 'blueShip-Fixed-2', 'blueShip-Fixed-3'},
		red = {'Molniya'}
	},
	airfield = {
		blue = {'blueInfantry','bluePD2', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8' , 'Red SAM AAA', 'Red Armour Group 2', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15','Red Armour Group 4','Red Arty 2'}
	},
	airfield2palmyra = {
		blue = {'blueInfantry','bluePD2', 'bluePD1'},
		red = {'Enemy ground forces','Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8' , 'Red SAM AAA','Red Armour Group 2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19' , 'Red SAM SA-11'}
	},  
	
	airfield2 = {
		blue = {'blueInfantry','bluePD2', 'bluePD1'},
		red = {'Enemy ground forces','Red Armor Group', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD Tor M2' ,'Red SAM AAA', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19','Red Armour Group 2', 'Red Arty 2'}
	},  

	Incirlik = {
		blue = {'blueInfantry','bluePD2', 'bluePD1'},
		red = {'Enemy ground forces','Red Armor Group', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD Tor M2' ,'Red SAM AAA', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD Pantsir S1','Red Armour Group 2', 'Red Arty 2'}
	}, 

	airfield3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'bluePD1'},
		red = {'Enemy ground forces','Red SAM AAA', 'Red SAM AAA 2', 'Red SAM SHORAD Pantsir S1', 'Red SAM SHORAD Tor M2' , 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19' , 'Red SAM SA-6','Red Armour Group 4','Red Armour Group 3', 'Red Arty 2'}
	},							 
   	generic = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy ground forces','Red Armour Group','Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8','Red SAM AAA 2' }
	},
	deltafixed = {
		blue = {'bluePD2', 'blueHAWK'},
		red = { 'Red Armour Group', 'Red SAM SA-6','Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8','Red SAM SHORAD Pantsir S1'}
	},
	bravofixed = {
		blue = {'bluePD2', 'blueHAWK'},
		red = { 'Red Armour Group','Red SAM SHORAD Tor M2','Red Armour Group 2', 'Red SAM SHORAD SA-19','Red SAM SHORAD SA-8','Red SAM SA-3'}
	},
	juliettFixed = {
		blue = {'bluePD2', 'blueHAWK', 'bluePD1', 'blueArmor'},
		red = {'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM AAA', 'Red SAM SA-2', 'Red SAM SHORAD SA-8'}
	},
	indiaFixed = {
		blue = {'bluePD2', 'blueHAWK', 'bluePD1'},
		red = {'Red SAM AAA', 'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD Tor M2', 'Red SAM SA-2'}
	},
	HotelFixed = {
		blue = {'bluePD2', 'blueHAWK', 'bluePD1'},
		red = {'Red SAM SHORAD SA-19', 'Red SAM SA-2', 'Red SAM SHORAD SA-15', 'Red SAM AAA Fixed Hotel'}
	},
	sa5 = {
		blue = {'bluePD2', 'bluePD1'},
		red = {'Red Armour Group','Red SAM AAA','Red SAM SHORAD SA-15','Red Armour Group 2','Red SAM SHORAD Tor M2','Red SAM SA-5 Fixed'}
	},
	insAirfield = {
		blue = {'blueInfantry','bluePD2', 'bluePD1'},
		red = {'Enemy ground forces','Red Armour Group','Red SAM AAA', 'Red SAM AAA 2','Red SAM SHORAD SA-15','Red Armour Group 2', 'Red SAM AAA 2', 'Red Arty 2' }
	},
	insGeneric = {
		blue = {'blueInfantry','bluePD2', 'blueArmor'},
		red = {'Enemy ground forces','Red Armour Group','Red SAM AAA', 'Red SAM AAA 2','Red Armour Group 2','Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19' }
	},
	damupgrade = {
		blue = {'blueInfantry','bluePD2', 'blueArmor'},
		red = {'Enemy ground forces','Red Armour Group 3','Red SAM AAA 3', 'Red SAM AAA 4','Red Armour Group 4','Red SAM SHORAD Tor M2', 'Red SAM SHORAD SA-19' }
	},
	insGenericFoxtrotFixed = {
		blue = {'blueInfantry','bluePD2', 'blueArmor'},
		red = {'Enemy ground forces','Red Armour Group','Enemy ground forces','Red SAM AAA 2','Red SAM SHORAD SA-8 Fixed Foxtrot'}
	},
	insMaximum = {
		blue = {'blueInfantry'},
		red = {'Enemy ground forces','Red SAM AAA', 'Red SAM AAA 2', 'Enemy ground forces','Red Armour Group','Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19' ,'Red Armour Group 2','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15'}
	},
	insMinimum = {
		blue = {'blueInfantry','bluePD2'},
		red = {'Enemy ground forces','Red SAM AAA', 'Red SAM AAA 2','Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19' }
	},
	insSAM = {
		blue = {'bluePD2', 'blueHAWK', 'bluePD1'},
		red = {'Red SAM AAA', 'Red SAM AAA 2', 'Red Armour Group', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19' ,'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15'}
	},
	ewr = {
		blue = {'blueInfantry'},
		red = {'Red EWR(p)','Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8' }
	},
	ewrcharlie = {
		blue = {'blueInfantry'},
		red = { 'Red EWR(p)', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-15' }
	},
	milbase = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces','Red Armour Group', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Pantsir S1' ,'Red SAM AAA','Red Armour Group 2'}
	},
	milbase2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM AAA 2', 'Red SAM SHORAD SA-8','Red Armour Group 2', 'Red SAM AAA 3' ,'Red Armour Group 2','Red SAM AAA 4'}
	},
	bigSAM = {
		blue = {'blueAmmo', 'blueAmmo', 'blueAmmo', 'bluePATRIOT'},
		red = {'redAmmo','redAmmo', 'Red SAM SA-11'}
	},
	PapaFixed = {
		blue = {'blueAmmo', 'blueAmmo', 'blueAmmo', 'blueAmmo', 'blueAmmo', 'blueAmmo', 'bluePD1', 'blueHAWK'},
		red = {'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15', 'Red SAM SA-11'}
	},
	radarstrike = {
		blue = {'blueInfantry'},
		red = {'redRadar'}
	},
	insOutpost = {
		blue = {'blueInfantry'},
		red = {'insOutpost'}
	},
	insAmbush = {
		blue = {'blueInfantry'},
		red = {'insAmbush'}
	},
	minimal = {
		blue = {'blueInfantry'},
		red = {'Enemy ground forces'}
	},
	bengurionDefence = {
		blue = {},
		red = {'Red SAM SHORAD SA-15 Fixed BenGurion','Red SAM SA-10 Fixed Benguriondefence', 'Red SAM SHORAD SA-19 Fixed Benguriondefence'}
	},
	SilkDefence = {
		blue = {},
		red = {'Silmworm Fixed 1','Red SAM AAA Silk Fixed','Red SAM SHORAD SA-15 Fixed'}
	},
	ramatdavidDefence = {
		blue = {},
		red = {'Red SAM SHORAD SA-15','Red SAM SHORAD SA-19','Red SAM AAA','Red SAM SA-11'}
	},
	jordanDefence = {
		blue = {},
		red = {'Red SAM SA-2', 'Red SAM SA-2', 'Red SAM SA-2', 'Red SAM SHORAD SA-19', 'Red SAM AAA', 'Red SAM SHORAD SA-15'}
	},

	incirlikdefence = {
		blue = {},
		red = {'Red Armour Group 4','Red SAM SA-11','Red SAM SHORAD SA-19','Red SAM SHORAD SA-15'}
	},

	hidden1Group = {
		blue = {},
		red = {'Red EWR north Fixed', 'Red EWR Cyprus Fixed', 'Red EWR-southeast Fixed', 'Red EWR-south Fixed', 'HQ Fixed', 
		'Red SAM SHORAD SA-15 Fixed HiddenGroup South', 'Red SAM SHORAD SA-15 EWR Group Fixed'}
	},
	hidden2Group = {
		blue = {},
		red = {'hiddenground-Map-Template1', 'hiddenground-Map-Template1', 'hiddenground-Map-Template1', 'hiddenground-Map-Template1', 'hiddenground-Map-Template1', 'hiddenground-Map-Template1', 'hiddenground-Map-Template1', 'hiddenground-Map-Template1',
				'hiddenground-Map-Template1', 'hiddenground-Map-Template1','hiddenground-Map-Template1','hiddenground-Map-Template1','hiddenground-Map-Template1','hiddenground-Map-Template1','hiddenground-Map-Template1','hiddenground-Map-Template1','hiddenground-Map-Template1'
			,'hiddenground-Map-Template1','hiddenground-Map-Template1','hiddenground-Map-Template1'}
	},
	hidden3Group = {
		blue = {},
		red = {'Red EWR north Fixed Coldwar', 'Red EWR Cyprus Fixed Coldwar', 'Red EWR-southeast Fixed Coldwar', 'Red EWR-south Fixed Coldwar', 'HQ Fixed', 
		'Red SAM SHORAD SA-15 Fixed HiddenGroup South', 'Red SAM SHORAD SA-15 EWR Group Fixed'}
	}

}


local cwSwap = {
	['Red Armour Group']  									= 'Red Armor Group6',
	['Red Armour Group 2']  								= 'Red Armor Group7',
	['Red Armour Group 3']  								= 'Red Armor Group8',
	['Red Armour Group 4']  								= 'Red Armor Group9',
	['Red Arty 2']  										= 'Red Arty',
	['Neustrashimy']  										= 'Molniya',
	['Rezky']  												= 'Grisha',
	['bluePD2']  											= 'bluePD2 Coldwar',
	['bluePD1']  											= 'bluePD1 Coldwar',
	['bluePD']  											= 'bluePD1 Coldwar',
	['blueArmor']  											= 'blueArmor_Cw',
	['blueHAWK']  											= 'blueHAWK_CW',
	['Red SAM SHORAD Tor M2']  								= { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
	['Red SAM SHORAD Pantsir S1']  							= { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
	['Red SAM SHORAD Tor M2 Fixed Bravo']                	= 'Red SAM SHORAD SA-19 Fixed Bravo',
	['Red SAM SHORAD Tor M2 Fixed SAITE']                 	= 'Red SAM SHORAD SA-19 Fixed SAITE',
	['Red SAM SHORAD SA-15 Fixed']                        	= 'Red SAM SHORAD SA-8 Fixed',
	['Red SAM SHORAD SA-15 Fixed HiddenGroup South']      	= 'Red SAM SHORAD SA-8 Fixed HiddenGroup South',
	['Red SAM SHORAD SA-15 EWR Group Fixed']              	= 'Red SAM SHORAD SA-8 EWR Group Fixed',
	['Red SAM SHORAD SA-15 Fixed BenGurion']              	= 'Red SAM SHORAD SA-8 Fixed BenGurion',

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

if Era == 'Coldwar' then
	deepSwap(upgrades,cwSwap)
end


local SamSwap = {
	['Red SAM SA-10']   = { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },
	['Red SAM SA-11']   = { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },}

local SamSwapNoTorM2AndPantsir = {
	['Red SAM SHORAD Tor M2 Fixed Bravo']                 = 'Red SAM SHORAD SA-19 Fixed Bravo',
	['Red SAM SHORAD Tor M2 Fixed SAITE']                 = 'Red SAM SHORAD SA-19 Fixed SAITE',
	['Red SAM SHORAD Tor M2']  							  = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
	['Red SAM SHORAD Pantsir S1']  						  = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
}

local SamSwapNoSA15 = {
	['Red SAM SHORAD SA-15 SAITE Fixed']                  = 'Red SAM SHORAD SA-8 SAITE Fixed',
	['Red SAM SHORAD SA-15 Fixed Papa-2']                 = 'Red SAM SHORAD SA-8 Fixed Papa-2',
	['Red SAM SHORAD SA-15 Fixed Papa-3']                 = 'Red SAM SHORAD SA-8 Fixed Papa-3',
	['Red SAM SHORAD SA-15 Fixed']                        	= 'Red SAM SHORAD SA-8 Fixed',
	['Red SAM SHORAD SA-15 Fixed HiddenGroup South']      	= 'Red SAM SHORAD SA-8 Fixed HiddenGroup South',
	['Red SAM SHORAD SA-15 EWR Group Fixed']              	= 'Red SAM SHORAD SA-8 EWR Group Fixed',
	['Red SAM SHORAD SA-15 Fixed BenGurion']              	= 'Red SAM SHORAD SA-8 Fixed BenGurion',
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
	"Red SAM AAA",
	"Red SAM AAA 2",
	"Red SAM AAA 3",
	"Red SAM AAA 4",
	"Red SAM AAA 5",

	-- Ground
	"Enemy Task forces",
	"Enemy ground forces",
	-- Armor
	"Red Armour Group",
	"Red Armour Group 2",
	"Red Armour Group 3",
	"Red Armour Group 4",
	-- Arty
	"Red Arty",
	"Red Arty 1",
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
	small = { "pantsir","tor m2" },
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

-- Enemy ground forces, Red Armor Group, Red SAM SHORAD SA-8, Red SAM SA-3, Red SAM SHORAD SA-15, redSA5, Red EWR
-- Enemy ground forces, Red Armour Group, Red SAM SHORAD SA-19
-- blueInfantry, blueArmor, blueRed SAM SHORAD, blueHAWK, bluePATRIOT, bluePD
-- blueShip

flavor = {
    akrotiri = L10N:Format("SYRIA_FLAVOR_START_ZONE", 1),
    paphos = L10N:Format("SYRIA_FLAVOR_WPT", 2),
    polis = L10N:Format("SYRIA_FLAVOR_WPT", 3),
    karavostasi = L10N:Format("SYRIA_FLAVOR_WPT", 4),
    pinarbashi = L10N:Format("SYRIA_FLAVOR_WPT", 5),
    gecitkale = L10N:Format("SYRIA_FLAVOR_WPT", 6),
    ercan = L10N:Format("SYRIA_FLAVOR_WPT", 7),
    larnaca = L10N:Format("SYRIA_FLAVOR_WPT", 8),
    redcarrier = L10N:Format("SYRIA_FLAVOR_RED_CARRIER", 9),
    incirlik = L10N:Format("SYRIA_FLAVOR_WPT", 10),
    alpha = L10N:Format("SYRIA_FLAVOR_WPT", 11),
    hatay = L10N:Format("SYRIA_FLAVOR_WPT", 12),
    bravo = L10N:Format("SYRIA_FLAVOR_WPT", 13),
    charlie = L10N:Format("SYRIA_FLAVOR_EWR_SITE", 14),
    minakh = L10N:Format("SYRIA_FLAVOR_WPT", 15),
    aleppo = L10N:Format("SYRIA_FLAVOR_WPT", 16),
    delta = L10N:Format("SYRIA_FLAVOR_WPT", 17),
    taftanaz = L10N:Format("SYRIA_FLAVOR_HELO_SPAWNS", 18),
    powerplant = L10N:Format("SYRIA_FLAVOR_INCOME_180", 19),
    hotel = L10N:Format("SYRIA_FLAVOR_SAM_SITE", 20),
    alassad = L10N:Format("SYRIA_FLAVOR_WPT", 21),
    substationwest = L10N:Format("SYRIA_FLAVOR_STRIKE_TARGET_500", 22),
    victor = L10N:Format("SYRIA_FLAVOR_CRASHED_BLACKHAWK", 23),
    alduhur = L10N:Format("SYRIA_FLAVOR_PLANE_HELO_SPAWNS", 24),
    tango = L10N:Format("SYRIA_FLAVOR_INSURGENT_OUTPOST", 25),
    substationnorth = L10N:Format("SYRIA_FLAVOR_STRIKE_TARGET_500", 26),
    jirah = L10N:Format("SYRIA_FLAVOR_HELO_SPAWNS", 27),
    foxtrot = L10N:Format("SYRIA_FLAVOR_WPT", 28),
    durayhim = L10N:Format("SYRIA_FLAVOR_WPT", 29),
    papa = L10N:Format("SYRIA_FLAVOR_SA11_OR_PATRIOT", 30),
    factory = L10N:Format("SYRIA_FLAVOR_INCOME_180", 31),
    india = L10N:Format("SYRIA_FLAVOR_SAM_SITE", 32),
    romeo = L10N:Format("SYRIA_FLAVOR_WPT", 33),
    hama = L10N:Format("SYRIA_FLAVOR_WPT", 34),
    foblima = L10N:Format("SYRIA_FLAVOR_HELO_SPAWNS", 35),
    sierra = L10N:Format("SYRIA_FLAVOR_STRIKE_TARGET_500", 36),
    golf = L10N:Format("SYRIA_FLAVOR_WPT", 37),
    dam = L10N:Format("SYRIA_FLAVOR_INCOME_180", 38),
    tabqa = L10N:Format("SYRIA_FLAVOR_WPT", 39),
    tv = L10N:Format("SYRIA_FLAVOR_STRIKE_TARGET_500", 40),
    juliett = L10N:Format("SYRIA_FLAVOR_SAM_SITE", 41),
    november = L10N:Format("SYRIA_FLAVOR_WPT", 42),
    radio = L10N:Format("SYRIA_FLAVOR_STRIKE_TARGET_500", 43),
    kilo = L10N:Format("SYRIA_FLAVOR_EWR_SITE", 44),
    refinery = L10N:Format("SYRIA_FLAVOR_INCOME_180", 45),
    uniform = L10N:Format("SYRIA_FLAVOR_INSURGENT_OUTPOST", 46),
    fobmike = L10N:Format("SYRIA_FLAVOR_HELO_SPAWNS", 47),
    milbase = L10N:Format("SYRIA_FLAVOR_WPT", 48),
    oscar = L10N:Format("SYRIA_FLAVOR_WPT", 49),
    sa5 = L10N:Format("SYRIA_FLAVOR_WPT", 50),
    palmyra = L10N:Format("SYRIA_FLAVOR_WPT", 51),
    tiyas = L10N:Format("SYRIA_FLAVOR_WPT", 52),
    shayrat = L10N:Format("SYRIA_FLAVOR_STRIKE_TARGET_500", 53),
    renemouawad = L10N:Format("SYRIA_FLAVOR_WPT", 54),
    beirut = L10N:Format("SYRIA_FLAVOR_WPT", 55),
    rayak = L10N:Format("SYRIA_FLAVOR_WPT", 56),
    annasiriyah = L10N:Format("SYRIA_FLAVOR_WPT", 57),
    damascus = L10N:Format("SYRIA_FLAVOR_WPT", 58),
    roshpina = L10N:Format("SYRIA_FLAVOR_WPT", 59),
    ramatdavid = L10N:Format("SYRIA_FLAVOR_WPT", 60),
    thalah = L10N:Format("SYRIA_FLAVOR_WPT", 61),
    kinghussein = L10N:Format("SYRIA_FLAVOR_WPT", 62),
    princehassan = L10N:Format("SYRIA_FLAVOR_WPT", 63),
    muwaffaq = L10N:Format("SYRIA_FLAVOR_WPT", 64),
    marka = L10N:Format("SYRIA_FLAVOR_WPT", 65),
    bengurion = L10N:Format("SYRIA_FLAVOR_WPT", 66),

    benguriondefence = L10N:Format("SYRIA_FLAVOR_DEFENCE_ZONE", "Ben Gurion"),
    incirlikdefence = L10N:Format("SYRIA_FLAVOR_DEFENCE_ZONE", "Incirlik"),
    jordandefence = L10N:Format("SYRIA_FLAVOR_DEFENCE_ZONE", "Jordan"),
    ramatdaviddefence = L10N:Format("SYRIA_FLAVOR_DEFENCE_ZONE", "Ramat David"),
    silkworm = L10N:Get("SYRIA_FLAVOR_SILKWORM_SITE")
}


WaypointList = {
    Akrotiri = ' (1)',
    Paphos = ' (2)',
    Polis = ' (3)',
    Karavostasi = ' (4)',
    Pinarbashi = ' (5)',
    Gecitkale = ' (6)',
    Ercan = ' (7)',
    Larnaca = ' (8)',
    ["Red Carrier"] = ' (9)',
    Incirlik = ' (10)',
    ["FOB Alpha"] = ' (11)',
    Hatay = ' (12)',
    Bravo = ' (13)',
    Charlie = ' (14)',
    Minakh = ' (15)',
    Aleppo = ' (16)',
    Delta = ' (17)',
    Taftanaz = ' (18)',
    ["Power Plant"] = ' (19)',
    Hotel = ' (20)',
    ["Bassel Al-Assad"] = ' (21)',
    ["Substation West"] = ' (22)',
    Victor = ' (23)',
    ["Abu al-Duhur"] = ' (24)',
    Tango = ' (25)',
    ["Substation North"] = ' (26)',
    Jirah = ' (27)',
    Foxtrot = ' (28)',
    Durayhim = ' (29)',
    Papa = ' (30)',
    Factory = ' (31)',
	India = ' (32)',
    Romeo = ' (33)',
    Hama = ' (34)',
    ["FOB Lima"] = ' (35)',
    Sierra = ' (36)',
    Golf = ' (37)',
	Dam = ' (38)',
    Tabqa = ' (39)',
	["TV Tower"] = ' (40)',
    Juliett = ' (41)',
    November = ' (42)',
    ["Radio Tower"] = ' (43)',
    Kilo = ' (44)',
	Refinery = ' (45)',
	Uniform = ' (46)',
	["FOB Mike"] = ' (47)',
	["Military Base"] = ' (48)',
    Oscar = ' (49)',
    ["SA-5"] = ' (50)',
    Palmyra = ' (51)',
    Tiyas = ' (52)',
    Shayrat = ' (53)',
    ["Rene Mouawad"] = ' (54)',
    Beirut = ' (55)',
    Rayak = ' (56)',
    ["An Nasiriyah"] = ' (57)',
    Damascus = ' (58)',
    ["Rosh Pina"] = ' (59)',
    ["Ramat David"] = ' (60)',
    Thalah = ' (61)',
    ["King Hussein Air College"] = ' (62)',
    ["Prince Hassan"] = ' (63)',
    ["Muwaffaq Salti"] = ' (64)',
    Marka = ' (65)',
    ["Ben Gurion"] = ' (66)',
}

FootholdSaveBaseName = (Era == 'Coldwar') and 'footholdSyria_Extended_0.1_coldwar' or 'footholdSyria_Extended_0.1'

local filepath = FootholdSaveBaseName .. '.lua'
if lfs then
  FootholdSavePath = FootholdSavePath or (lfs.writedir()..'Missions/Saves')
  lfs.mkdir(FootholdSavePath)
  filepath = FootholdSavePath .. '/' .. (FootholdSaveBaseName .. '.lua')
  env.info('Foothold - Save file path: '..filepath)
end

bc = BattleCommander:new(filepath, 13, 60)
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
env.info('Foothold - Rank file path: '..bc.rankFile)
end
Hunt = true

zones = {
	akrotiri = ZoneCommander:new({zone='Akrotiri', side=StartNormal and 2 or 1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.akrotiri}),
    paphos = ZoneCommander:new({zone='Paphos', side=1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.paphos}),
    polis = ZoneCommander:new({zone='Polis', side=1, level=20,size='small', upgrades=upgrades.insSAM, crates={}, flavorText=flavor.polis}),
	karavostasi = ZoneCommander:new({zone='Karavostasi', side=1, level=20,size='small', upgrades=upgrades.milbase2, crates={}, flavorText=flavor.karavostasi}),	
    larnaca = ZoneCommander:new({zone='Larnaca', side=1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.larnaca}),	
    ercan = ZoneCommander:new({zone='Ercan', side=1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.ercan}),
    pinarbashi = ZoneCommander:new({zone='Pinarbashi', side=1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.pinarbashi}),
	gecitkale = ZoneCommander:new({zone='Gecitkale', side=1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.gecitkale}),
	incirlik = ZoneCommander:new({zone='Incirlik', side=1, level=20,size='big', upgrades=upgrades.Incirlik, crates={}, flavorText=flavor.incirlik}),
	hatay = ZoneCommander:new({zone='Hatay', side=1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.hatay}),
	minakh = ZoneCommander:new({zone='Minakh', side=1, level=20, size='bignosam', upgrades=upgrades.airfield2, crates={}, flavorText=flavor.minakh}),
	aleppo = ZoneCommander:new({zone='Aleppo', side=1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.aleppo}),
	taftanaz = ZoneCommander:new({zone='Taftanaz', side=1, level=20, size='bignosam', upgrades=upgrades.airfield2, crates={}, flavorText=flavor.taftanaz}),
	jirah = ZoneCommander:new({zone='Jirah', side=1, level=20,size='mediumbig', upgrades=upgrades.insAirfield, crates={}, flavorText=flavor.jirah}),
	tabqa = ZoneCommander:new({zone='Tabqa', side=1, level=20, upgrades=upgrades.insAirfield, crates={}, flavorText=flavor.tabqa}),
	alduhur = ZoneCommander:new({zone='Abu al-Duhur', side=1, level=20, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.alduhur}),
	alassad = ZoneCommander:new({zone='Bassel Al-Assad', side=1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.alassad}),
	hama = ZoneCommander:new({zone='Hama', side=1, level=20, size='bignosam', upgrades=upgrades.airfield2, crates={}, flavorText=flavor.hama}),
	palmyra = ZoneCommander:new({zone='Palmyra', side=1, level=20,size='extrabig', upgrades=upgrades.airfield2palmyra, crates={}, flavorText=flavor.palmyra}),
	powerplant = ZoneCommander:new({zone='Power Plant', side=1,size='smallmedium', level=20, upgrades=upgrades.generic, crates={}, flavorText=flavor.powerplant, income=0.5}),
	alpha = ZoneCommander:new({zone='FOB Alpha', side=1, level=20, upgrades=upgrades.minimal, crates={}, flavorText=flavor.alpha}),
	bravo = ZoneCommander:new({zone='Bravo', side=1, level=20, upgrades=upgrades.bravofixed, crates={}, flavorText=flavor.bravo}),
	charlie = ZoneCommander:new({zone='Charlie', side=1,size='small', level=20, upgrades=upgrades.ewrcharlie, crates={}, flavorText=flavor.charlie}),
	delta = ZoneCommander:new({zone='Delta', side=1, level=20,size='sam2', upgrades=upgrades.deltafixed, crates={}, flavorText=flavor.delta}),
	redcarrier = ZoneCommander:new({zone='Red Carrier', side=1, level=20, upgrades=upgrades.ships, crates={}, flavorText=flavor.redcarrier}),
	foxtrot = ZoneCommander:new({zone='Foxtrot', side=1, level=20,size='medium', upgrades=upgrades.insGenericFoxtrotFixed, crates={}, flavorText=flavor.foxtrot}),
	golf = ZoneCommander:new({zone='Golf', side=1, level=20, upgrades=upgrades.insSAM, crates={}, flavorText=flavor.golf}),
	hotel = ZoneCommander:new({zone='Hotel', side=1, level=20,size='sam', upgrades=upgrades.HotelFixed, crates={}, flavorText=flavor.hotel}),
	india = ZoneCommander:new({zone='India', side=1, level=20,size='sam', upgrades=upgrades.indiaFixed, crates={}, flavorText=flavor.india}),
	juliett = ZoneCommander:new({zone='Juliett', side=1, level=20,size='sam', upgrades=upgrades.juliettFixed, crates={}, flavorText=flavor.juliett}),
	kilo = ZoneCommander:new({zone='Kilo', side=1, level=20, upgrades=upgrades.ewr, crates={}, flavorText=flavor.kilo}),
	foblima = ZoneCommander:new({zone='FOB Lima', side=0, level=20, upgrades=upgrades.minimal, crates={}, flavorText=flavor.foblima, NeutralAtStart=true}),
	fobmike = ZoneCommander:new({zone='FOB Mike', side=0, level=20, upgrades=upgrades.minimal, crates={}, flavorText=flavor.fobmike, NeutralAtStart=true}),
	november = ZoneCommander:new({zone='November', side=1, level=20,size='smallmedium', upgrades=upgrades.generic, crates={}, flavorText=flavor.november}),
	oscar = ZoneCommander:new({zone='Oscar', side=1, level=20, upgrades=upgrades.insMinimum, crates={}, flavorText=flavor.oscar}),
	papa = ZoneCommander:new({zone='Papa', side=1, level=20, upgrades=upgrades.PapaFixed, crates={}, flavorText=flavor.papa}),
	romeo = ZoneCommander:new({zone='Romeo', side=1, level=20, upgrades=upgrades.generic, crates={}, flavorText=flavor.romeo}),
	sierra = ZoneCommander:new({zone='Sierra', side=1, level=20, upgrades=upgrades.radarstrike, crates={}, flavorText=flavor.sierra}),
	tango = ZoneCommander:new({zone='Tango', side=1, level=20, upgrades=upgrades.insOutpost, crates={}, flavorText=flavor.tango}),
	uniform = ZoneCommander:new({zone='Uniform', side=1, level=20, upgrades=upgrades.insOutpost, crates={}, flavorText=flavor.uniform}),
	victor = ZoneCommander:new({zone='Victor', side=1, level=20, upgrades=upgrades.insAmbush, crates={}, flavorText=flavor.victor}),
	substationnorth = ZoneCommander:new({zone='Substation North', side=1, level=20, upgrades=upgrades.insMinimum, crates={}, flavorText=flavor.substationnorth}),
	durayhim = ZoneCommander:new({zone='Durayhim', side=1, level=20, upgrades=upgrades.insGeneric, crates={}, flavorText=flavor.durayhim}),
	dam = ZoneCommander:new({zone='Dam', side=1, level=20,size='smallmedium', upgrades=upgrades.damupgrade, crates={}, flavorText=flavor.dam, income=0.5}),
	tv = ZoneCommander:new({zone='TV Tower', side=1, level=20, upgrades=upgrades.insMinimum, crates={}, flavorText=flavor.tv}),
	sa5 = ZoneCommander:new({zone='SA-5', side=1, level=20,size='small', upgrades=upgrades.sa5, crates={}, flavorText=flavor.sa5, customSuspendNm = 100}),
	milbase = ZoneCommander:new({zone='Military Base', side=1, level=20, upgrades=upgrades.milbase, crates={}, flavorText=flavor.milbase}),
	carrier = ZoneCommander:new({zone='Carrier Group', side=StartNormal and 2 or 0, level=20, upgrades=upgrades.carrierFixed, crates={}, flavorText=flavor.carrier}),
	refinery = ZoneCommander:new({zone='Refinery', side=1, level=20,size='smallmedium', upgrades=upgrades.generic, crates={}, flavorText=flavor.refinery, income=0.5}),
	factory = ZoneCommander:new({zone='Factory', side=1, level=20,size='smallmedium', upgrades=upgrades.generic, crates={}, flavorText=flavor.factory, income=0.5}),
	substationwest = ZoneCommander:new({zone='Substation West', side=1, level=20,size='smallmedium', upgrades=upgrades.generic, crates={}, flavorText=flavor.substationwest}),
	radio = ZoneCommander:new({zone='Radio Tower', side=1, level=20,size='smallmedium', upgrades=upgrades.generic, crates={}, flavorText=flavor.radio}),
	renemouawad = ZoneCommander:new({zone='Rene Mouawad', side=1, size='medium', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.renemouawad}),
	beirut = ZoneCommander:new({zone='Beirut', side=1, size='medium', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.beirut}),
	rayak = ZoneCommander:new({zone='Rayak', side=1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.rayak}),
	tiyas = ZoneCommander:new({zone='Tiyas', side=1, level=20,size='medium', upgrades=upgrades.generic, crates={}, flavorText=flavor.tiyas}),
	damascus = ZoneCommander:new({zone='Damascus', side=1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.damascus}),
annasiriyah = ZoneCommander:new({zone='An Nasiriyah', side=1, level=20, size='bignosam', upgrades=upgrades.airfield2, crates={}, flavorText=flavor.annasiriyah, customSuspendNm = 80}),
	thalah = ZoneCommander:new({zone='Thalah', side=1, level=20, size='bignosam', upgrades=upgrades.airfield2, crates={}, flavorText=flavor.thalah}),

	kinghussein = ZoneCommander:new({zone='King Hussein Air College', side=1, size='medium', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.kinghussein}),
	muwaffaq = ZoneCommander:new({zone='Muwaffaq Salti', side=1, level=20, size='bignosam', upgrades=upgrades.airfield2, crates={}, flavorText=flavor.muwaffaq}),
	princehassan = ZoneCommander:new({zone='Prince Hassan', side=1, level=20, size='bignosam', upgrades=upgrades.airfield2, crates={}, flavorText=flavor.princehassan}),
	bengurion = ZoneCommander:new({zone='Ben Gurion', side=StartNormal and 1 or 2, level=20, size=StartNormal and 'medium' or 'bignosam', upgrades=upgrades.airfield2, crates={}, flavorText=flavor.bengurion}),
	ramatdavid = ZoneCommander:new({zone='Ramat David', side=1, level=20, size='medium', upgrades=upgrades.airfield2, crates={}, flavorText=flavor.ramatdavid}),
	roshpina = ZoneCommander:new({zone='Rosh Pina', side=1, level=20, size='bignosam', upgrades=upgrades.airfield2, crates={}, flavorText=flavor.roshpina}),
	marka = ZoneCommander:new({zone='Marka', side=1, level=20, size='bignosam', upgrades=upgrades.airfield2, crates={}, flavorText=flavor.marka}),
	shayrat = ZoneCommander:new({zone='Shayrat', side=1, size='bignosam', level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.shayrat}),


	benguriondefence = ZoneCommander:new({zone='Ben Gurion Defence', side=1, level=20, upgrades=upgrades.bengurionDefence, crates={}, flavorText=flavor.benguriondefence}),
	ramatdaviddefence = ZoneCommander:new({zone='Ramat David Defence', side=1, level=20,size='sam', upgrades=upgrades.ramatdavidDefence, crates={}, flavorText=flavor.ramatdaviddefence}),
	jordandefence = ZoneCommander:new({zone='Jordan Defence',size='samspecial', side=1, level=20, upgrades=upgrades.jordanDefence, crates={}, flavorText=flavor.jordandefence}),
	incirlikdefence = ZoneCommander:new({zone='Incirlik Defence', side=1,size='sam', level=20, upgrades=upgrades.incirlikdefence, crates={}, flavorText=flavor.incirlikdefence}),
	
	silkworm = ZoneCommander:new({zone='Silkworm Site', side=1, level=3, upgrades=upgrades.SilkDefence, crates={}, flavorText=flavor.silkworm}),
	hidden1 = ZoneCommander:new({zone='Hidden1', side=0, level=25, upgrades=upgrades.hidden1Group, crates={}, flavorText=flavor.hidden1, NeutralAtStart=true}),
	hidden2 = ZoneCommander:new({zone='Hidden2', side=0, level=25, upgrades=upgrades.hidden2Group, crates={}, flavorText=flavor.hidden2, NeutralAtStart=true}),
	hidden3 = ZoneCommander:new({zone='Hidden3', side=0, level=25, upgrades=upgrades.hidden2Group, crates={}, flavorText=flavor.hidden3, NeutralAtStart=true}),
	hidden4 = ZoneCommander:new({zone='Hidden4', side=0, level=25, upgrades=upgrades.hidden2Group, crates={}, flavorText=flavor.hidden4, NeutralAtStart=true}),
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
		"BLUE_B1",
    }
	CapCarrierGroup = {
        'BLUE_HORNET',
        'BLUE_F14B',
	}
	SeadCarrierGroup = {
        'BLUE_HORNET_SEAD',
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
	AntiShipPlaneTemplate = {
	--"Viggen_Blue",
	"Hornet_Anti_Ship"
	}

function CasAltitude() return math.random(15,25)*1000 end
function CapAltitude() return math.random(22,32)*1000 end
function SeadAltitude() return math.random(25,33)*1000 end
function RunwayStrikeAltitude() return math.random(23,28)*1000 end

zones.akrotiri:addGroups({
	GroupCommander:new({name='Akrotiri-supply-Paphos', mission='supply', template='HeloSupplyTemplate', targetzone='Paphos'}),
	GroupCommander:new({name='Akrotiri-supply-Ercan', mission='supply', template='PlaneSupplyTemplate', targetzone='Ercan'}),
	GroupCommander:new({name='Akrotiri-supply-Larnaca', mission='supply', template='PlaneSupplyTemplate', targetzone='Larnaca'}),
	
	GroupCommander:new({name='Akrotiri-patrol-Larnaca', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Larnaca', Altitude = CapAltitude()}),
	
	GroupCommander:new({name='Akrotiri-attack-Larnaca', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Larnaca', Altitude = CapAltitude()}),
	GroupCommander:new({name='Akrotiri-patrol-Paphos', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Paphos', Altitude = CapAltitude()}),
	GroupCommander:new({name='Akrotiri-attack-Ercan', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Ercan', Altitude = CapAltitude()}),

	GroupCommander:new({name='Akrotiri-attack-Paphos-Cas', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Paphos'}),
	GroupCommander:new({name='Akrotiri-attack-Ercan-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Ercan', Altitude = CasAltitude()}),
	GroupCommander:new({name='Akrotiri-attack-Polis-Sead', mission='attack', template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Polis', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Akrotiri-attack-Ercan-Sead', mission='attack', template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Ercan', Altitude = SeadAltitude()}),

})

zones.paphos:addGroups({
	GroupCommander:new({name='Paphos-supply-Polis', mission='supply', template='HeloSupplyTemplate', targetzone='Polis'}),
	GroupCommander:new({name='Paphos-attack-Polis', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Polis'}),
	GroupCommander:new({name='Paphos-attack-Pinarbashi-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Pinarbashi', Altitude = CasAltitude()}),
})

zones.carrier:addGroups({
	GroupCommander:new({name='carrier-patrol-Akrotiri', mission='patrol', template='CapCarrierGroup', MissionType='CAP', targetzone='Akrotiri',type='carrier_air', Altitude = CapAltitude(), Bluecondition = function() return true end}),
})

zones.polis:addGroups({
	GroupCommander:new({name='Polis-supply-Paphos', mission='supply', template='HeloSupplyTemplate', targetzone='Paphos'}),
	GroupCommander:new({name='Polis-supply-Karavostasi', mission='supply', template='HeloSupplyTemplate', targetzone='Karavostasi'}),
	GroupCommander:new({name='Polis-attack-Paphos', mission='attack', template='AttackConvoy', targetzone='Paphos', type='surface', spawnDelayFactor = 2}),
})

zones.karavostasi:addGroups({
	GroupCommander:new({name='karavostasi-supply-Polis', mission='supply', template='HeloSupplyTemplate', targetzone='Polis'}),
	GroupCommander:new({name='karavostasi-supply-Pinarbashi', mission='supply', template='HeloSupplyTemplate', targetzone='Pinarbashi'}),

	GroupCommander:new({name='karavostasi-attack-Pinarbashi-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Pinarbashi'}),
	GroupCommander:new({name='karavostasi-attack-Paphos-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Paphos'}),
	GroupCommander:new({name='karavostasi-attack-Polis-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Polis'}),

	GroupCommander:new({name='karavostasi-attack-Polis-convoy', mission='attack', template='AttackConvoy', targetzone='Polis', type='surface'}),
})

zones.pinarbashi:addGroups({
	GroupCommander:new({name='Pinarbashi-supply-Karavostasi', mission='supply', template='HeloSupplyTemplate', targetzone='Karavostasi'}),
	GroupCommander:new({name='Pinarbashi-supply-Gecitkale', mission='supply', template='SupplyConvoy', targetzone='Gecitkale', type='surface'}),
	GroupCommander:new({name='Pinarbashi-supply-Ercan', mission='supply', template='HeloSupplyTemplate', targetzone='Ercan'}),
	GroupCommander:new({name='Pinarbashi-attack-Karavostasi-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Karavostasi', diceChance = 50}),

})

zones.ercan:addGroups({
	GroupCommander:new({name='Ercan-supply-Larnaca', mission='supply', template='HeloSupplyTemplate', targetzone='Larnaca'}),
	GroupCommander:new({name='Ercan-supply-Gecitkale', mission='supply', template='HeloSupplyTemplate', targetzone='Gecitkale'}),
	GroupCommander:new({name='Ercan-attack-Incirlik', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Incirlik', Altitude = CapAltitude(), Bluecondition = function() return zones.redcarrier.wasBlue end}),
	GroupCommander:new({name='Ercan-patrol-Ercan-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ercan', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ercan-attack-Paphos-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Paphos', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ercan-patrol-Paphos-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Paphos', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ercan-patrol-Karavostasi-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Karavostasi', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ercan-attack-Paphos-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Paphos', Altitude = CasAltitude()}),
	GroupCommander:new({name='Ercan-attack-Polis-CAS', mission='attack', template='CasPlaneTemplate', targetzone='Polis',MissionType='CAS', Altitude = CasAltitude()}),
	GroupCommander:new({name='Ercan-attack-Pinarbashi', mission='attack', template='AttackConvoy', targetzone='Pinarbashi', type='surface', spawnDelayFactor = 4}),
	

})

zones.gecitkale:addGroups({
	GroupCommander:new({name='Gecitkale-supply-Ercan', mission='supply', template='HeloSupplyTemplate', targetzone='Ercan'}),
	GroupCommander:new({name='Gecitkale-supply-Pinarbashi', mission='supply', template='HeloSupplyTemplate', targetzone='Pinarbashi'}),
	GroupCommander:new({name='Gecitkale-supply-Larnaca', mission='supply', template='HeloSupplyTemplate', targetzone='Larnaca'}),
	GroupCommander:new({name='Gecitkale-supply-Incirlik', mission='supply', template='PlaneSupplyTemplate', targetzone='Incirlik'}),
	GroupCommander:new({name='Gecitkale-patrol-Red carrier', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Red Carrier', Altitude = CapAltitude()}),
	GroupCommander:new({name='Gecitkale-patrol-Paphos', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Paphos', Altitude = CapAltitude()}),
	--GroupCommander:new({name='Gecitkale-supply-Carrier', mission='supply', template='HeloSupplyTemplate', targetzone='Red Carrier'}),
	GroupCommander:new({name='Gecitkale-attack-Pinarbashi-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Pinarbashi', spawnDelayFactor = 3}),
	GroupCommander:new({name='Gecitkale-attack-Paphos-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Paphos', Altitude = CasAltitude()}),
	GroupCommander:new({name='Gecitkale-attack-Paphos-rwy', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Paphos', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Gecitkale-attack-Akrotiri-rwy', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Akrotiri', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Gecitkale-attack-Akrotiri-SEAD', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Akrotiri', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Gecitkale-attack-Ercan-Convoy', mission='attack', template='AttackConvoy', targetzone='Ercan', type='surface'}),
	GroupCommander:new({name='Gecitkale-supply-Carrier-Boat', mission='supply', targetzone='Red Carrier', type='surface'}),

})

zones.redcarrier:addGroups({
	GroupCommander:new({name='CVN-73-supply-Incirlik', mission='supply', template='HeloSupplyTemplate', targetzone='Incirlik', Airbase='Tarawa',NotCargo=true, Bluecondition = function() return true end}),
	GroupCommander:new({name='CVN-73-attack-Incirlik-Defence-Cas', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Incirlik Defence', Airbase ='Tarawa', type='carrier_air', Bluecondition = function() return true end}),
	GroupCommander:new({name='CVN-73-attack-Incirlik-Defence-Sead', mission='attack', template='SeadCarrierGroup',MissionType='SEAD', targetzone='Incirlik Defence',type='carrier_air', Altitude = SeadAltitude(), Bluecondition = function() return true end}),
	GroupCommander:new({name='CVN-73-patrol-Red Carrier-Cap', mission='patrol', template='CapCarrierGroup',MissionType='CAP', targetzone='Red Carrier',type='carrier_air', Altitude = CapAltitude(), Bluecondition = function() return true end}),
	GroupCommander:new({name='CVN-73-attack-Hotel-Sead', mission='attack', template='SeadCarrierGroup',MissionType='SEAD', targetzone='Hotel',type='carrier_air', Altitude = SeadAltitude(), Bluecondition = function() return true end}),
	GroupCommander:new({name='CVN-73-attack-Incirlik-Sead', mission='attack', template='SeadCarrierGroup',MissionType='SEAD', targetzone='Incirlik', type='carrier_air', Altitude = SeadAltitude(), Bluecondition = function() return not zones.incirlikdefence.active end}),
})

zones.larnaca:addGroups({
	GroupCommander:new({name='Larnaca-supply-Bassel Al-Assad', mission='supply', template='PlaneSupplyTemplate', targetzone='Bassel Al-Assad'}),
	GroupCommander:new({name='Larnaca-patrol-Larnaca-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Larnaca', Altitude = CapAltitude()}),
	GroupCommander:new({name='Larnaca-attack-Paphos-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Paphos', diceChance = 50, Altitude = CasAltitude()}),
	GroupCommander:new({name='Larnaca-attack-Polis-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Polis', diceChance = 50, Altitude = CasAltitude()}),
	GroupCommander:new({name='Larnaca-attack-Red Carrier-AntiShip', mission='attack', template='AntiShipPlaneTemplate', MissionType='ANTISHIP', targetzone='Red Carrier', Altitude = 15000})
})

zones.incirlik:addGroups({
	GroupCommander:new({name='Incirlik-supply-Hatay', mission='supply', template='PlaneSupplyTemplate', targetzone='Hatay'}),
	GroupCommander:new({name='Incirlik-supply-Bassel Al-Assad', mission='supply', template='PlaneSupplyTemplate', targetzone='Bassel Al-Assad'}),
	GroupCommander:new({name='Incirlik-supply-Aleppo', mission='supply', template='PlaneSupplyTemplate', targetzone='Aleppo'}),
	GroupCommander:new({name='Incirlik-supply-FOB Alpha', mission='supply', template='HeloSupplyTemplate', targetzone='FOB Alpha'}),
	GroupCommander:new({name='Incirlik-supply-Incirlik-Defence', mission='supply', template='SupplyConvoy', targetzone='Incirlik Defence', type='surface', Redcondition = function() return not CustomFlags["IncirlikWarehouse"] end}),
	--GroupCommander:new({name='Incirlik-supply-Carrier', mission='supply', template='HeloSupplyTemplate', targetzone='Red Carrier', Bluecondition = function() return true end}),
	GroupCommander:new({name='Incirlik-patrol-Incirlik-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Incirlik', Altitude = CapAltitude()}),
	GroupCommander:new({name='Incirlik-patrol-Carrier-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Red Carrier', Altitude = CapAltitude()}),
	GroupCommander:new({name='Incirlik-attack-Gecitkale-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gecitkale', Altitude = CapAltitude()}),
	GroupCommander:new({name='Incirlik-attack-Hatay-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Hatay', Altitude = CasAltitude()}),
	GroupCommander:new({name='Incirlik-attack-Bravo-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Bravo', Altitude = SeadAltitude()}),
})

zones.hatay:addGroups({
	GroupCommander:new({name='Hatay-supply-Minakh', mission='supply', template='HeloSupplyTemplate', targetzone='Minakh'}),
	GroupCommander:new({name='Hatay-supply-Taftanaz', mission='supply', template='HeloSupplyTemplate', targetzone='Taftanaz'}),
	GroupCommander:new({name='Hatay-supply-Al-Assad', mission='supply', template='HeloSupplyTemplate', targetzone='Bassel Al-Assad'}),
	GroupCommander:new({name='Hatay-supply-Bravo', mission='supply', template='HeloSupplyTemplate', targetzone='Bravo'}),
	GroupCommander:new({name='Hatay-patrol-Hatay-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hatay', Altitude = CapAltitude()}),
	GroupCommander:new({name='Hatay-attack-Incirlik-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Incirlik', Altitude = CapAltitude()}),
	GroupCommander:new({name='Hatay-attack-Incirlik-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Incirlik', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Hatay-attack-Taftanaz-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Taftanaz'}),
	GroupCommander:new({name='Hatay-attack-Minakh-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Minakh', Altitude = CasAltitude()}),
	GroupCommander:new({name='Hatay-attack-Delta-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Delta', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Hatay-attack-Delta-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Delta', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Hatay-attack-Jirah-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', Airbase='Incirlik', targetzone='Jirah', Altitude = RunwayStrikeAltitude(), Bluecondition = function() return zones.aleppo.side == 2 end}),
	GroupCommander:new({name='Hatay-attack-al-Duhur-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abu al-Duhur', Altitude = CapAltitude()}),
	GroupCommander:new({name='Hatay-attack-Minakh-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Minakh', type='surface',SetActiveMission = true}),

})

zones.durayhim:addGroups({
	GroupCommander:new({name='Durayhim-attack-Duhur-1', mission='attack', template='AttackConvoy', targetzone='Abu al-Duhur', type='surface', spawnDelayFactor = 2}),
	GroupCommander:new({name='Durayhim-attack-Duhur-2', mission='attack', template='AttackConvoy', targetzone='Abu al-Duhur', type='surface'}),
	GroupCommander:new({name='Durayhim-attack-Duhur-3', mission='attack', template='AttackConvoy', targetzone='Abu al-Duhur', type='surface', spawnDelayFactor = 1.5})
})

zones.minakh:addGroups({
	GroupCommander:new({name='Minakh-supply-Hatay', mission='supply', template='HeloSupplyTemplate', targetzone='Hatay'}),
	GroupCommander:new({name='Minakh-supply-Aleppo', mission='supply', template='HeloSupplyTemplate', targetzone='Aleppo'}),
	GroupCommander:new({name='Minakh-supply-Charlie', mission='supply', template='HeloSupplyTemplate', targetzone='Charlie'}),
	GroupCommander:new({name='Minakh-attack-Taftanaz-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Taftanaz'}),
	GroupCommander:new({name='Minakh-attack-Aleppo-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Aleppo'})
})

zones.aleppo:addGroups({
	GroupCommander:new({name='Aleppo-supply-Minakh', mission='supply', template='HeloSupplyTemplate', targetzone='Minakh'}),
	GroupCommander:new({name='Aleppo-supply-Hatay', mission='supply', template='PlaneSupplyTemplate', targetzone='Hatay'}),
	GroupCommander:new({name='Aleppo-supply-Bassel Al-Assad', mission='supply', template='PlaneSupplyTemplate', targetzone='Bassel Al-Assad'}),
	GroupCommander:new({name='Aleppo-supply-Hama', mission='supply', template='PlaneSupplyTemplate', targetzone='Hama'}),
	GroupCommander:new({name='Aleppo-supply-Taftanaz', mission='supply', template='HeloSupplyTemplate', targetzone='Taftanaz'}),
	GroupCommander:new({name='Aleppo-supply-Jirah', mission='supply', template='HeloSupplyTemplate', targetzone='Jirah'}),
	GroupCommander:new({name='Aleppo-supply-Duhur', mission='supply', template='HeloSupplyTemplate', targetzone='Abu al-Duhur'}),
	GroupCommander:new({name='Aleppo-supply-Delta', mission='supply', template='HeloSupplyTemplate', targetzone='Delta'}),
	GroupCommander:new({name='Aleppo-patrol-Taftanaz-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Taftanaz', Altitude = CapAltitude()}),
	GroupCommander:new({name='Aleppo-patrol-Duhur-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abu al-Duhur', Altitude = CapAltitude()}),
	GroupCommander:new({name='Aleppo-attack-Bravo-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Bravo', Altitude = CasAltitude()}),
	GroupCommander:new({name='Aleppo-attack-Duhur', mission='attack', template='AttackConvoy', targetzone='Abu al-Duhur', type='surface'}),
	GroupCommander:new({name='Aleppo-attack-Duhur-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Abu al-Duhur'}),
	GroupCommander:new({name='Aleppo-attack-papa-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Papa', Altitude = SeadAltitude()}),
})

zones.taftanaz:addGroups({
	GroupCommander:new({name='Taftanaz-supply-Hatay', mission='supply', template='HeloSupplyTemplate', targetzone='Hatay', condition = function(self) return not (self.side == 1 and CustomFlags["TaftanazWarehouse"])end}),
	GroupCommander:new({name='Taftanaz-supply-Aleppo', mission='supply', template='HeloSupplyTemplate', targetzone='Aleppo', condition = function(self) return not (self.side == 1 and CustomFlags["TaftanazWarehouse"])end}),
	GroupCommander:new({name='Taftanaz-supply-Duhur', mission='supply', template='HeloSupplyTemplate', targetzone='Abu al-Duhur', condition = function(self) return not (self.side == 1 and CustomFlags["TaftanazWarehouse"])end}),
	GroupCommander:new({name='Taftanaz-supply-Delta', mission='supply', template='HeloSupplyTemplate', targetzone='Delta', condition = function(self) return not (self.side == 1 and CustomFlags["TaftanazWarehouse"])end}),
	GroupCommander:new({name='Taftanaz-supply-Power Plant', mission='supply', template='HeloSupplyTemplate', targetzone='Power Plant', condition = function(self) return not (self.side == 1 and CustomFlags["TaftanazWarehouse"])end}),


	GroupCommander:new({name='Taftanaz-attack-Hatay-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Hatay'}),
	GroupCommander:new({name='Taftanaz-attack-Minakh-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Minakh'}),
	GroupCommander:new({name='Taftanaz-attack-Duhur-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Abu al-Duhur'}),
	GroupCommander:new({name='Taftanaz-attack-Power Plant-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Power Plant'})
})

zones.juliett:addGroups({
	GroupCommander:new({name='Juliett-supply-Refinery', mission='supply', template='HeloSupplyTemplate', targetzone='Refinery'})
})

zones.jirah:addGroups({
	GroupCommander:new({name='Jirah-supply-Aleppo', mission='supply', template='HeloSupplyTemplate', targetzone='Aleppo'}),
	GroupCommander:new({name='Jirah-supply-Tabqa', mission='supply', template='HeloSupplyTemplate', targetzone='Tabqa'}),
	GroupCommander:new({name='Jirah-supply-Duhur', mission='supply', template='HeloSupplyTemplate', targetzone='Abu al-Duhur'}),
	GroupCommander:new({name='Jirah-supply-Durayhim', mission='supply', template='HeloSupplyTemplate', targetzone='Durayhim'}),
	GroupCommander:new({name='Jirah-supply-foxtrot', mission='supply', template='HeloSupplyTemplate', targetzone='Foxtrot'}),
	GroupCommander:new({name='Jirah-patrol-Hama-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hama', Altitude = CapAltitude()}),
	GroupCommander:new({name='Jirah-attack-Hatay-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hatay', spawnDelayFactor = 1.5, Altitude = CapAltitude()}),
	GroupCommander:new({name='Jirah-attack-Aleppo-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Aleppo', Altitude = CasAltitude()}),
	GroupCommander:new({name='Jirah-attack-Duhur-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Abu al-Duhur', spawnDelayFactor = 2, Altitude = CasAltitude()}),
	GroupCommander:new({name='Jirah-attack-Tabqa-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Tabqa'}),
	GroupCommander:new({name='Jirah-attack-Juliett-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Juliett', Altitude = CasAltitude()}),
	GroupCommander:new({name='Jirah-attack-Aleppo-surface', mission='attack', targetzone='Aleppo', type='surface', SetActiveMisison = true}),
	GroupCommander:new({name='Jirah-attack-Durayhim', mission='attack', targetzone='Durayhim', type='surface', SetActiveMisison = true}),
	GroupCommander:new({name='Jirah-attack-Tabqa-Surface', mission='attack', targetzone='Tabqa',template='AttackConvoy', type='surface'}),
})

zones.tabqa:addGroups({
	GroupCommander:new({name='Tabqa-supply-Jirah', mission='supply', template='HeloSupplyTemplate', targetzone='Jirah'}),
	GroupCommander:new({name='Tabqa-supply-Foxtrot', mission='supply', template='HeloSupplyTemplate', targetzone='Foxtrot'}),
	GroupCommander:new({name='Tabqa-supply-Golf', mission='supply', template='HeloSupplyTemplate', targetzone='Golf'}),
	GroupCommander:new({name='Tabqa-supply-Dam', mission='supply', template='HeloSupplyTemplate', targetzone='Dam'}),
	GroupCommander:new({name='Tabqa-supply-Millbase', mission='supply', template='HeloSupplyTemplate', targetzone='Military Base'}),
	GroupCommander:new({name='Tabqa-supply-Juliett', mission='supply', template='HeloSupplyTemplate', targetzone='Juliett'}),
	GroupCommander:new({name='Tabqa-supply-Oscar', mission='supply', template='HeloSupplyTemplate', targetzone='Oscar'}),
	GroupCommander:new({name='Tabqa-patrol-Tabqa-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tabqa', Altitude = CapAltitude()}),
	GroupCommander:new({name='Tabqa-patrol-Palmyra-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', Altitude = CapAltitude()}),
	GroupCommander:new({name='Tabqa-attack-Palmyra-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', Altitude = CapAltitude()}),
	GroupCommander:new({name='Tabqa-attack-Foxtrot-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Foxtrot', spawnDelayFactor = 1.5, diceChance = 50, Altitude = CasAltitude()}),
	GroupCommander:new({name='Tabqa-attack-Golf-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Golf'}),
	GroupCommander:new({name='Tabqa-attack-Dam-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Dam'}),
	GroupCommander:new({name='Tabqa-attack-Millbase-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Military Base', Altitude = CasAltitude()}),
	GroupCommander:new({name='Tabqa-attack-Taftanaz-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Taftanaz', spawnDelayFactor = 1.5, Altitude = CapAltitude()}),
	GroupCommander:new({name='Tabqa-attack-Jirah', mission='attack', template='AttackConvoy', targetzone='Jirah', type='surface', Redcondition = function () return not zones.dam.active end}),
})

zones.milbase:addGroups({
	GroupCommander:new({name='Milbase-supply-Oscar', mission='supply', template='SupplyConvoy', targetzone='Oscar', type='surface'}),
	GroupCommander:new({name='Milbase-supply-Palmyra', mission='supply', template='HeloSupplyTemplate', targetzone='Palmyra'}),
	GroupCommander:new({name='Milbase-attack-Juliett', mission='attack', template='AttackConvoy', targetzone='Juliett', type='surface', spawnDelayFactor = 4}),
	GroupCommander:new({name='Milbase-attack-Juliett-2', mission='attack', template='AttackConvoy', targetzone='Juliett', type='surface'}),
	GroupCommander:new({name='Milbase-attack-Palmyra', mission='attack', template='AttackConvoy', targetzone='Palmyra', type='surface'}),
	GroupCommander:new({name='Milbase-attack-Refinery', mission='attack', template='AttackConvoy', targetzone='Refinery', type='surface'}),
})

zones.alduhur:addGroups({
	GroupCommander:new({name='Alduhur-supply-Aleppo', mission='supply', template='HeloSupplyTemplate', targetzone='Aleppo', condition=function(self) if self.side==1 and CustomFlags["SA11WareHouse"] then self.spawnDelayFactor=2 end end}),
	GroupCommander:new({name='Alduhur-supply-Taftanaz', mission='supply', template='HeloSupplyTemplate', targetzone='Taftanaz', condition=function(self) if self.side==1 and CustomFlags["SA11WareHouse"] then self.spawnDelayFactor=2 end end}),
	GroupCommander:new({name='Alduhur-supply-Jirah', mission='supply', template='HeloSupplyTemplate', targetzone='Jirah', condition=function(self) if self.side==1 and CustomFlags["SA11WareHouse"] then self.spawnDelayFactor=2 end end}),
	GroupCommander:new({name='Alduhur-supply-Hama', mission='supply', template='HeloSupplyTemplate', targetzone='Hama', condition=function(self) if self.side==1 and CustomFlags["SA11WareHouse"] then self.spawnDelayFactor=2 end end}),
	GroupCommander:new({name='Alduhur-supply-Al-Assad', mission='supply', template='HeloSupplyTemplate', targetzone='Bassel Al-Assad', condition=function(self) if self.side==1 and CustomFlags["SA11WareHouse"] then self.spawnDelayFactor=2 end end}),
	GroupCommander:new({name='Alduhur-supply-India', mission='supply', template='HeloSupplyTemplate', targetzone='India', condition=function(self) if self.side==1 and CustomFlags["SA11WareHouse"] then self.spawnDelayFactor=2 end end}),
	GroupCommander:new({name='Alduhur-supply-Factory', mission='supply', template='HeloSupplyTemplate', targetzone='Factory', condition=function(self) if self.side==1 and CustomFlags["SA11WareHouse"] then self.spawnDelayFactor=2 end end}),
	GroupCommander:new({name='Alduhur-supply-November', mission='supply', template='HeloSupplyTemplate', targetzone='November', condition=function(self) if self.side==1 and CustomFlags["SA11WareHouse"] then self.spawnDelayFactor=2 end end}),
	GroupCommander:new({name='Alduhur-supply-Papa', mission='supply', template='SupplyConvoy', targetzone='Papa', type='surface', condition=function(self) if self.side==1 and CustomFlags["SA11WareHouse"] then self.spawnDelayFactor=2 end end}),
	GroupCommander:new({name='Alduhur-patrol-Al-Assad-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bassel Al-Assad', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alduhur-patrol-Duhur-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abu al-Duhur', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alduhur-attack-Al-Assad-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Bassel Al-Assad'}),
	GroupCommander:new({name='Alduhur-attack-Factory-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Factory'}),
	GroupCommander:new({name='Alduhur-attack-Hotel-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Hotel', Altitude = SeadAltitude()})
})

zones.alassad:addGroups({
	GroupCommander:new({name='Alassad-supply-Hama', mission='supply', template='HeloSupplyTemplate', targetzone='Hama'}),
	GroupCommander:new({name='Alassad-supply-Duhur', mission='supply', template='HeloSupplyTemplate', targetzone='Abu al-Duhur'}),
	GroupCommander:new({name='Alassad-supply-Hatay', mission='supply', template='PlaneSupplyTemplate', targetzone='Hatay'}),
	GroupCommander:new({name='Alassad-supply-Hotel', mission='supply', template='HeloSupplyTemplate', targetzone='Hotel', condition = function(self) if self.side == 1 then return not CustomFlags["AssadWarehouse"] end end}),
	GroupCommander:new({name='Alassad-supply-Incirlik', mission='supply', template='PlaneSupplyTemplate', targetzone='Incirlik'}),
	GroupCommander:new({name='Alassad-supply-Romeo', mission='supply', template='HeloSupplyTemplate', targetzone='Romeo'}),
	GroupCommander:new({name='Alassad-patrol-Carrier-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Red Carrier', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-patrol-Hotel-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hotel', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-patrol-Al-Assad-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bassel Al-Assad', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-patrol-Al-Assad-Sead', mission='patrol', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Bassel Al-Assad', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Alassad-patrol-India-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='India', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-attack-Larnaca-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Larnaca', Altitude = CasAltitude(), Redcondition = function() return not zones.redcarrier.wasBlue end}),
	GroupCommander:new({name='Alassad-attack-Ercan-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Ercan', Altitude = CasAltitude(), Redcondition = function() return not zones.redcarrier.wasBlue end}),
	GroupCommander:new({name='Alassad-attack-Ercan-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Ercan', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Alassad-attack-Ercan-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Ercan', Altitude = RunwayStrikeAltitude(), Redcondition = function() return not zones.redcarrier.wasBlue end}),
	GroupCommander:new({name='Alassad-attack-Hatay-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hatay', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-attack-Palmyra-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-patrol-Palmyra-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-attack-Hama-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hama', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-patrol-Hama-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hama', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-attack-Rene-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rene Mouawad', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-patrol-Rene-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rene Mouawad', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-attack-al-Duhur-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abu al-Duhur', Altitude = CapAltitude()})
})

zones.hama:addGroups({
	GroupCommander:new({name='Hama-supply-Al-Assad', mission='supply', template='HeloSupplyTemplate', targetzone='Bassel Al-Assad'}),
	GroupCommander:new({name='Hama-supply-Duhur', mission='supply', template='HeloSupplyTemplate', targetzone='Abu al-Duhur'}),
	GroupCommander:new({name='Hama-supply-Palmyra', mission='supply', template='HeloSupplyTemplate', targetzone='Palmyra'}),
	GroupCommander:new({name='Hama-supply-India', mission='supply', template='HeloSupplyTemplate', targetzone='India'}),
	GroupCommander:new({name='Hama-supply-November', mission='supply', template='HeloSupplyTemplate', targetzone='November'}),
	GroupCommander:new({name='Hama-supply-Romeo', mission='supply', template='HeloSupplyTemplate', targetzone='Romeo'}),
	GroupCommander:new({name='Hama-patrol-Kilo-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Kilo', Altitude = CapAltitude()}),
	GroupCommander:new({name='Hama-patrol-India-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='India', Altitude = CapAltitude()}),
	GroupCommander:new({name='Hama-patrol-Hama-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hama', Altitude = CapAltitude()}),
	GroupCommander:new({name='Hama-attack-Factory-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Factory'}),
	GroupCommander:new({name='Hama-attack-Romeo-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Romeo'}),
	GroupCommander:new({name='Hama-attack-Duhur-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Abu al-Duhur', Altitude = CasAltitude()})
})

zones.november:addGroups({
	GroupCommander:new({name='November-attack-Duhur', mission='attack', targetzone='Abu al-Duhur', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='November-attack-Hama', mission='attack', targetzone='Hama', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='November-attack-India', mission='attack', targetzone='India', type='surface', SetActiveMission = true}),
})

zones.palmyra:addGroups({
	GroupCommander:new({name='Palmyra-supply-Hama', mission='supply', template='HeloSupplyTemplate', targetzone='Hama'}),
	GroupCommander:new({name='Palmyra-supply-SA5', mission='supply', template='HeloSupplyTemplate', targetzone='SA-5', condition = function(self) if self.side == 1 then self.spawnDelayFactor = 2 return not CustomFlags["SA5Warehouse"] end end}),
	GroupCommander:new({name='Palmyra-supply-Millbase', mission='supply', template='HeloSupplyTemplate', targetzone='Military Base'}),
	GroupCommander:new({name='Palmyra-supply-Refinery', mission='supply', template='HeloSupplyTemplate', targetzone='Refinery'}),
	GroupCommander:new({name='Palmyra-supply-Tiyas', mission='supply', template='HeloSupplyTemplate', targetzone='Tiyas'}),
	GroupCommander:new({name='Palmyra-patrol-SA5-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='SA-5', spawnDelayFactor = 2, Altitude = CapAltitude()}),
	GroupCommander:new({name='Palmyra-patrol-Refinery-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Refinery', spawnDelayFactor = 1.5, Altitude = CapAltitude()}),
	GroupCommander:new({name='Palmyra-patrol-Palmyra-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', Altitude = CapAltitude()}),
	GroupCommander:new({name='Palmyra-attack-Hama-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Hama', Altitude = CasAltitude()}),
	GroupCommander:new({name='Palmyra-attack-Tabqa-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tabqa', Altitude = CasAltitude()}),
	GroupCommander:new({name='Palmyra-attack-Refinery-surface', mission='attack', template='AttackConvoy', targetzone='Refinery', type='surface'}),
	GroupCommander:new({name='Palmyra-attack-Hama-surface', mission='attack', template='AttackConvoy', targetzone='Hama', type='surface'}),
	GroupCommander:new({name='Palmyra-attack-Tiyas-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Tiyas', Altitude = CapAltitude(), Bluecondition = function() return end}),
	GroupCommander:new({name='Palmyra-attack-Tiyas-Cas', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Tiyas', Bluecondition = function() return end}),

})

zones.tiyas:addGroups({
	GroupCommander:new({name='Tiyas-supply-Palmyra', mission='supply', template='HeloSupplyTemplate', targetzone='Palmyra'}),
	GroupCommander:new({name='Tiyas-attack-Palmyra-cas', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Palmyra'}),
	GroupCommander:new({name='Tiyas-supply-Shayrat', mission='supply', template='HeloSupplyTemplate', targetzone='Shayrat'}),
	GroupCommander:new({name='Tiyas-attack-Palmyra', mission='attack', template='AttackConvoy', targetzone='Palmyra', type='surface'}),
	GroupCommander:new({name='Tiyas-attack-An Nasiriyah-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='An Nasiriyah', Altitude = CapAltitude(), Bluecondition = function() return end}),
	GroupCommander:new({name='Tiyas-patrol-Refinery-Cap', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Refinery', Altitude = CapAltitude()}),
	GroupCommander:new({name='Tiyas-attack-Shayrat-Arty', mission='attack', template='ArtilleryConvoyLong', MissionType='ARTY', targetzone='Shayrat', type='surface',SetActiveMission = true,artilleryRangeNm = 7}),

})

zones.refinery:addGroups({
	GroupCommander:new({name='Refinery-supply-Palmyra', mission='supply', template='SupplyConvoy', targetzone='Palmyra', type='surface'}),
	GroupCommander:new({name='Refinery-supply-Juliett', mission='supply', template='SupplyConvoy', targetzone='Juliett', type='surface'}),
	GroupCommander:new({name='Refinery-attack-Palmyra', mission='attack', template='AttackConvoy', targetzone='Palmyra', type='surface'}),
	GroupCommander:new({name='Refinery-attack-Palmyra-Arty', mission='attack', template='ArtilleryConvoyLong', MissionType='ARTY', targetzone='Palmyra', type='surface',SetActiveMission = true,artilleryRangeNm = 7}),

})

zones.factory:addGroups({
	GroupCommander:new({name='Factory-supply-Hama', mission='supply', template='SupplyConvoy', targetzone='Hama', type='surface'})
})

zones.romeo:addGroups({
	GroupCommander:new({name='Romeo-supply-Factory', mission='supply', template='SupplyConvoy', targetzone='Factory', type='surface'}),
	GroupCommander:new({name='Romeo-supply-Hama', mission='supply', template='SupplyConvoy', targetzone='Hama', type='surface'}),
	GroupCommander:new({name='Romeo-attack-Factory-Attack', mission='attack', template='AttackConvoy', targetzone='Factory', type='surface'}),
	GroupCommander:new({name='Romeo-attack-Hama-Attack', mission='attack', template='AttackConvoy', targetzone='Hama', type='surface'})
})


zones.alpha:addGroups({
	GroupCommander:new({name='Alpha-supply-Hatay', mission='supply', template='HeloSupplyTemplate', targetzone='Hatay'})
})

zones.dam:addGroups({
	GroupCommander:new({name='Dam-attack-Jirah', mission='attack', template='AttackConvoy', targetzone='Jirah', type='surface', spawnDelayFactor = 2}),
	GroupCommander:new({name='Dam-attack-Foxtrot', mission='attack', template='AttackConvoy', targetzone='Foxtrot', type='surface', spawnDelayFactor = 1.5})
})

zones.beirut:addGroups({
	GroupCommander:new({name='Beirut-supply-Rene-Mouawad', mission='supply', template='HeloSupplyTemplate', targetzone='Rene Mouawad'}),
	GroupCommander:new({name='Beirut-patrol-beirut-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Beirut', Altitude = CapAltitude()}),
	GroupCommander:new({name='Beirut-attack-beirut-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Beirut', Altitude = CapAltitude()}),
	GroupCommander:new({name='Beirut-patrol-Rene Mouawad-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rene Mouawad', Altitude = CapAltitude()}),
	GroupCommander:new({name='Beirut-attack-Rosh Pina-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rosh Pina', Altitude = CapAltitude()}),	
	GroupCommander:new({name='Beirut-attack-Rene Mouawad-CAS', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rene Mouawad', Altitude = CasAltitude()}),
	GroupCommander:new({name='Beirut-attack-Rayak-CAS', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Rayak'}),
	GroupCommander:new({name='Beirut-supply-Rayak', mission='supply', template='HeloSupplyTemplate', targetzone='Rayak'}),
	GroupCommander:new({name='Beirut-supply-Tiyas', mission='supply', template='PlaneSupplyTemplate', targetzone='Tiyas'}),
	GroupCommander:new({name='Beirut-supply-Shayrat', mission='supply', template='PlaneSupplyTemplate', targetzone='Shayrat'}),
	GroupCommander:new({name='Beirut-attack-Rayak-Convoy', mission='attack', template='AttackConvoy', targetzone='Rayak', type='surface'}),
	GroupCommander:new({name='Beirut-attack-Rayak-Arty', mission='attack',template='ArtilleryConvoyShort',MissionType='ARTY',Reward=250, targetzone='Rayak', type='surface', SetActiveMission = true}),

})

zones.renemouawad:addGroups({
	GroupCommander:new({name='Renemouawad-supply-Shayrat', mission='supply', template='HeloSupplyTemplate', targetzone='Shayrat'}),
	GroupCommander:new({name='Renemouawad-patrol-Kilo-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Kilo', Altitude = CapAltitude()}),
	GroupCommander:new({name='Renemouawad-patrol-Renemouawad-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rene Mouawad', Altitude = CapAltitude()}),
	GroupCommander:new({name='Renemouawad-patrol-Shayrat-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Shayrat', Altitude = CapAltitude()}),
	GroupCommander:new({name='Renemouawad-attack-An Nasiriyah-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='An Nasiriyah', Altitude = CapAltitude()}),
	GroupCommander:new({name='Renemouawad-attack-Shayrat-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Shayrat', Altitude = CapAltitude()}),
	GroupCommander:new({name='Renemouawad-attack-Nasiriyah-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='An Nasiriyah', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Renemouawad-attack-Shayrat-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Shayrat', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Renemouawad-attack-Shayrat-CAS', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Shayrat', Altitude = CasAltitude()}),
	GroupCommander:new({name='Renemouawad-attack-Shayrat-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Shayrat', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Renemouawad-supply-Beirut', mission='supply', template='HeloSupplyTemplate', targetzone='Beirut'}),

})


zones.shayrat:addGroups({
	GroupCommander:new({name='Shayrat-supply-Rene Mouawad', mission='supply', template='HeloSupplyTemplate', targetzone='Rene Mouawad'}),
	GroupCommander:new({name='Shayrat-supply-An-Nasiriyah', mission='supply', template='HeloSupplyTemplate', targetzone='An Nasiriyah'}),
	GroupCommander:new({name='Shayrat-supply-Tiyas', mission='supply', template='HeloSupplyTemplate', targetzone='Tiyas'}),
	GroupCommander:new({name='Shayrat-attack-Palmyra-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', spawnDelayFactor = 2.0, Altitude = CapAltitude()}),
	GroupCommander:new({name='Shayrat-attack-Hama-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hama', spawnDelayFactor = 2.0, Altitude = CapAltitude()}),
	GroupCommander:new({name='Shayrat-attack-Hama-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Hama', Altitude = CasAltitude()}),
	GroupCommander:new({name='Shayrat-attack-Hama-Sead', mission='attack', template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Hama', Altitude = SeadAltitude()}),

	GroupCommander:new({name='Shayrat-patrol-Shayrat-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Shayrat', Altitude = CapAltitude()}),
	GroupCommander:new({name='Shayrat-patrol-Palmyra-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', Altitude = CapAltitude()}),
	GroupCommander:new({name='Shayrat-attack-Palmyra-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Palmyra', Altitude = CapAltitude()}),
	GroupCommander:new({name='Shayrat-attack-Palmyra-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Palmyra', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Shayrat-attack-Palmyra-CAS', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Palmyra', Altitude = CasAltitude()}),
	GroupCommander:new({name='Shayrat-attack-Palmyra-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Palmyra', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Shayrat-attack-Tiyas-Arty', mission='attack', template='ArtilleryConvoyLong', MissionType='ARTY', targetzone='Tiyas', type='surface',SetActiveMission = true,artilleryRangeNm = 7}),

})

zones.marka:addGroups({
	GroupCommander:new({name='Marka-Supply-King-hussein-air-college', mission='supply', template='HeloSupplyTemplate', targetzone='King Hussein Air College', spawnDelayFactor = 1.5}),
	GroupCommander:new({name='Marka-Supply-Muwaffaq-Salti', mission='supply', template='HeloSupplyTemplate', targetzone='Muwaffaq Salti'}),
	GroupCommander:new({name='Marka-Supply-Prince-Hassan', mission='supply', template='HeloSupplyTemplate', targetzone='Prince Hassan'}),
	GroupCommander:new({name='Marka-Supply-Ben-Gurion', mission='supply', template='HeloSupplyTemplate', targetzone='Ben Gurion'}),
	GroupCommander:new({name='Marka-attack-King-hussein', mission='attack', template='AttackConvoy', targetzone='King Hussein Air College', type='surface'}),
	GroupCommander:new({name='Marka-patrol-king-hussein-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Thalah', spawnDelayFactor = 1.5, Altitude = CapAltitude()}),
	GroupCommander:new({name='Marka-attack-king-hussein-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='King Hussein Air College', spawnDelayFactor = 3, Altitude = CapAltitude()})
})
zones.kinghussein:addGroups({
	GroupCommander:new({name='King-hussein-air-college-supply-Marka', mission='supply', template='HeloSupplyTemplate', targetzone='Marka'}),
	GroupCommander:new({name='King-hussein-air-college-supply-Prince-Hassan', mission='supply', template='HeloSupplyTemplate', targetzone='Prince Hassan'}),
	GroupCommander:new({name='King-hussein-air-college-supply-Muwaffaq-Salti', mission='supply', template='HeloSupplyTemplate', targetzone='Muwaffaq Salti'}),
	GroupCommander:new({name='King-hussein-air-college-supply-Thalah', mission='supply', template='HeloSupplyTemplate', targetzone='Thalah'}),
	GroupCommander:new({name='King-hussein-air-college-supply-Ben-Gurion', mission='supply', template='HeloSupplyTemplate', targetzone='Ben Gurion'}),
	GroupCommander:new({name='King-hussein-air-college-attack-Damascus-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Damascus', Altitude = CasAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Prince Hassan-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Prince Hassan', Altitude = CapAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Ben-Gurion-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Ben Gurion', Altitude = CapAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-patrol-Prince Hassan-Cap', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Prince Hassan', Altitude = CapAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-patrol-Thalah-Cap', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Thalah', Altitude = CapAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-An Nasiriyah-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='An Nasiriyah', Altitude = CasAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Ramat David-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Ramat David', Altitude = CasAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Ramat David-Sead', mission='attack', template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Ramat David', Altitude = SeadAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Damascus-Sead', mission='attack', template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Damascus', Altitude = SeadAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Damascus-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Damascus', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Ramat David-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Ramat David', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Thalah-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='Thalah', type='surface',artilleryRangeNm= 7,SetActiveMission = true}),

})
zones.princehassan:addGroups({
	GroupCommander:new({name='Hassan-supply-Muwaffaq', mission='supply', template='HeloSupplyTemplate', targetzone='Muwaffaq Salti'}),
	GroupCommander:new({name='Hassan-supply-Marka', mission='supply', template='HeloSupplyTemplate', targetzone='Marka'}),
	GroupCommander:new({name='Hassan-supply-King-hussein-air-college', mission='supply', template='HeloSupplyTemplate', targetzone='King Hussein Air College'})
})

zones.rayak:addGroups({
	GroupCommander:new({name='Rayak-supply-Nasiriyah', mission='supply', template='HeloSupplyTemplate', targetzone='An Nasiriyah'}),
	GroupCommander:new({name='Rayak-supply-Beirut', mission='supply', template='HeloSupplyTemplate', targetzone='Beirut'}),
	GroupCommander:new({name='Rayak-attack-Beirut', mission='attack', template='AttackConvoy', targetzone='Beirut', type='surface'}),
	GroupCommander:new({name='Rayak-attack-Beirut-Arty', mission='attack',template='ArtilleryConvoyShort',MissionType='ARTY',Reward=250, targetzone='Beirut', type='surface', SetActiveMission = true}),

})

zones.annasiriyah:addGroups({
	GroupCommander:new({name='Nasiriyah-supply-Damascus', mission='supply', template='HeloSupplyTemplate', targetzone='Damascus', ForceFromGround = true}),
	GroupCommander:new({name='Nasiriyah-supply-Shayrat', mission='supply', template='HeloSupplyTemplate', targetzone='Shayrat',ForceFromGround = true}),
	GroupCommander:new({name='Nasiriyah-supply-Rayak', mission='supply', template='HeloSupplyTemplate', targetzone='Rayak',ForceFromGround = true}),
	GroupCommander:new({name='Nasiriyah-attack-Tiyas-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tiyas', Altitude = CasAltitude()}),
	GroupCommander:new({name='Nasiriyah-attack-Rayak-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Rayak',ForceFromGround = true}),
	GroupCommander:new({name='Nasiriyah-attack-Beirut-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Beirut', Altitude = SeadAltitude(), condition=function(self) if self.side == 1 then return zones.rayak.side == 1 end end}),
	GroupCommander:new({name='Nasiriyah-attack-Palmyra-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', Altitude = CapAltitude()}),
	GroupCommander:new({name='Nasiriyah-attack-Beirut', mission='attack', template='AttackConvoy', targetzone='Beirut', type ='surface'}),
})

zones.damascus:addGroups({
	GroupCommander:new({name='Damascus-supply-Roshpina', mission='supply', template='HeloSupplyTemplate', targetzone='Rosh Pina'}),
	GroupCommander:new({name='Damascus-supply-An Nasiriyah', mission='supply', template='HeloSupplyTemplate', targetzone='An Nasiriyah'}),
	GroupCommander:new({name='Damascus-patrol-Nasiriyah-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='An Nasiriyah', Altitude = CapAltitude()}),
	GroupCommander:new({name='Damascus-patrol-Damascus-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Damascus', Altitude = CapAltitude()}),
	GroupCommander:new({name='Damascus-patrol-Beirut-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Beirut', Altitude = CapAltitude()}),
	GroupCommander:new({name='Damascus-attack-King Hussein-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='King Hussein Air College', Altitude = CasAltitude()}),

	GroupCommander:new({name='Damascus-attack-Nasiriyah-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='An Nasiriyah', Altitude = CapAltitude()}),	
	GroupCommander:new({name='Damascus-attack-Beirut-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Beirut', Altitude = CapAltitude()}),

	GroupCommander:new({name='Damascus-attack-Beirut-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Beirut', Altitude = CasAltitude()}),
	GroupCommander:new({name='Damascus-attack-Rayak-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Rayak', Altitude = CasAltitude()}),

	GroupCommander:new({name='Damascus-attack-Beirut-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Beirut', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Damascus-attack-Rayak-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Rayak', Altitude = SeadAltitude()}),

})

zones.thalah:addGroups({
	GroupCommander:new({name='Thalah-supply-king-Hussein', mission='supply', template='HeloSupplyTemplate', targetzone='King Hussein Air College'}),
	GroupCommander:new({name='Thalah-supply-Ramat-David', mission='supply', template='HeloSupplyTemplate', targetzone='Ramat David'}),
	GroupCommander:new({name='Thalah-supply-Ben-Gurion', mission='supply', template='HeloSupplyTemplate', targetzone='Ben Gurion'}),
	GroupCommander:new({name='Thalah-attack-Damascus-CasHelo', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Damascus'}),
	GroupCommander:new({name='Thalah-attack-king-Hussein-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='King Hussein Air College', type='surface',artilleryRangeNm= 7,SetActiveMission = true}),

})

zones.roshpina:addGroups({
	GroupCommander:new({name='Roshpina-supply-Ramat-David', mission='supply', template='HeloSupplyTemplate', targetzone='Ramat David'}),
	GroupCommander:new({name='Roshpina-supply-Damascus', mission='supply', template='HeloSupplyTemplate', targetzone='Damascus'}),

})

zones.ramatdavid:addGroups({
	GroupCommander:new({name='Ramatdavid-supply-Rosh-Pina', mission='supply', template='HeloSupplyTemplate', targetzone='Rosh Pina'}),
	GroupCommander:new({name='Ramatdavid-supply-Thalah', mission='supply', template='HeloSupplyTemplate', targetzone='Thalah'}),
	GroupCommander:new({name='Ramatdavid-supply-Ben-Gurion', mission='supply', template='HeloSupplyTemplate', targetzone='Ben Gurion'}),
	GroupCommander:new({name='Ramatdavid-attack-Rosh Pina', mission='attack', template='AttackConvoy', targetzone='Rosh Pina', type='surface'}),
	GroupCommander:new({name='Ramatdavid-supply-Ramat David Defence', mission='supply', template='SupplyConvoy', targetzone='Ramat David Defence', type='surface', Redcondition = function() return not CustomFlags["DavidWarehouse"] end}),
	GroupCommander:new({name='Ramatdavid-attack-Damascus-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Damascus', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ramatdavid-attack-King Hussein-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='King Hussein Air College', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ramatdavid-attack-Marka-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Marka', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ramatdavid-patrol-Damascus-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Damascus', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ramatdavid-attack-Damascus-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Damascus', Altitude = CasAltitude()}),
	GroupCommander:new({name='Ramatdavid-attack-Damascus-Rnwy', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='CAS', targetzone='Damascus', Altitude = CasAltitude()}),
	GroupCommander:new({name='Ramatdavid-patrol-Rosh-Pina-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rosh Pina', Altitude = CapAltitude()}),
})

zones.muwaffaq:addGroups({
	GroupCommander:new({name='Muwaffaq-supply-Prince-Hassan', mission='supply', template='HeloSupplyTemplate', targetzone='Prince Hassan'}),
	GroupCommander:new({name='Muwaffaq-supply-Marka', mission='supply', template='HeloSupplyTemplate', targetzone='Marka'}),
	GroupCommander:new({name='Muwaffaq-patrol-king-Hussein-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='King Hussein Air College', Altitude = CapAltitude()}),
	GroupCommander:new({name='Muwaffaq-attack-king-Hussein-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='King Hussein Air College', Altitude = CasAltitude()}),
	GroupCommander:new({name='Muwaffaq-attack-Prince Hassan-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='King Hussein Air College'}),
	GroupCommander:new({name='Muwaffaq-patrol-king-Marka-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Marka', spawnDelayFactor = 1.5, Altitude = CapAltitude()}),
	
})

zones.bengurion:addGroups({
	GroupCommander:new({name='Ben-Gurion-supply-Ramat-David', mission='supply', template='HeloSupplyTemplate', targetzone='Ramat David'}),
	GroupCommander:new({name='Ben-Gurion-supply-Marka', mission='supply', template='HeloSupplyTemplate', targetzone='Marka'}),
	GroupCommander:new({name='Ben-Gurion-supply-Thalah', mission='supply', template='HeloSupplyTemplate', targetzone='Thalah'}),
	GroupCommander:new({name='Ben-Gurion-supply-King-Hussein-Air-College', mission='supply', template='HeloSupplyTemplate', targetzone='King Hussein Air College'}),
	GroupCommander:new({name='Ben-Gurion-patrol-Ben-Gurion-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ben Gurion', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ben-Gurion-supply-Damascus', mission='supply', template='PlaneSupplyTemplate', targetzone='Damascus'}),
	GroupCommander:new({name='Ben-Gurion-supply-Muwaffaq', mission='supply', template='PlaneSupplyTemplate', targetzone='Muwaffaq Salti'}),
	GroupCommander:new({name='Ben-Gurion-supply-Marka', mission='supply', template='PlaneSupplyTemplate', targetzone='Marka'}),
})



function SpawnFriendlyAssets()

	if zones.redcarrier.wasBlue and not IsGroupActive('CVN-73') then
		destroyGroupIfActive('CVN-72')
		destroyGroupIfActive('CVN-74')
		destroyGroupIfActive('HMS Invincible')

		timer.scheduleFunction(function()
		activateGroupIfNotActive('CVN-73')
		activateGroupIfNotActive('Tarawa')
		activateGroupIfNotActive('CVN-59')
		end, {}, timer.getTime() + 3)

		timer.scheduleFunction(function()
		checkWeaponsList('CVN-73')
		checkWeaponsList('CVN-59')
		end, {}, timer.getTime() + 10)
	end
	if zones.alpha.wasBlue then
		activateGroupIfNotActive('FOB ALPHA')
		activateGroupIfNotActive('Naval-2')			
	end
	if zones.silkworm.active and zones.redcarrier.side == 0 and not MessageSent then
		MessageSent = true
		trigger.action.outText(L10N:Get("SYRIA_SETUP_SILKWORM_BLOCKING"), 15)
		trigger.action.outSoundForCoalition(2, "admin.ogg")
	end
	
	if zones.hidden1.side == 1 and zones.hidden1.active then
		if zones.akrotiri.side == 2 and zones.redcarrier.side == 2 then
			zones.hidden1:DestroyHiddenZone()
		end
	elseif zones.hidden1.side == 0 and (
	(zones.akrotiri.side == 2 and zones.redcarrier.side ~= 2) or
	(zones.akrotiri.side ~= 2 and zones.redcarrier.side == 2) ) then
		zones.hidden1:MakeZoneRedAndUpgrade()
	end

	if zones.hidden2.side == 1 and zones.hidden2.active then
		if zones.incirlik.side == 2 and zones.alduhur.side == 2 then
			zones.hidden2:DestroyHiddenZone()
		end
	elseif zones.hidden2.side == 0 and (
	(zones.incirlik.side == 2 and zones.alduhur.side ~= 2) or
	(zones.incirlik.side ~= 2 and zones.alduhur.side == 2) ) then
		zones.hidden2:MakeZoneRedAndUpgrade()
	end
	if zones.hidden3.side == 1 and zones.hidden3.active then
		if zones.alduhur.side == 2 and zones.palmyra.side == 2 then
			zones.hidden3:DestroyHiddenZone()
		end
	elseif zones.hidden3.side == 0 and (
	(zones.alduhur.side == 2 and zones.palmyra.side ~= 2) or
	(zones.alduhur.side ~= 2 and zones.palmyra.side == 2) ) then
		zones.hidden3:MakeZoneRedAndUpgrade()
	end

	if zones.hidden4.side == 1 and zones.hidden4.active then
		if zones.annasiriyah.side == 2 and zones.bengurion.side == 2 then
			zones.hidden4:DestroyHiddenZone()
		end
	elseif zones.hidden4.side == 0 and (
	(zones.annasiriyah.side == 2 and zones.bengurion.side ~= 2) or
	(zones.annasiriyah.side ~= 2 and zones.bengurion.side == 2) ) then
		zones.hidden4:MakeZoneRedAndUpgrade()
	end

	if zones.redcarrier.wasBlue then

		trigger.action.setMarkupTypeLine(zones.carrier.index, 0)
	end
end
SCHEDULER:New(nil,SpawnFriendlyAssets,{},2,0)

function checkAndDisableFriendlyZones()
end

--SCHEDULER:New(nil,checkAndDisableFriendlyZones,{},3,0)

zones.powerplant:addCriticalObject('PowerPlant1')
zones.powerplant:addCriticalObject('PowerPlant2')

zones.substationnorth:addCriticalObject('substation3')
zones.substationnorth:addCriticalObject('substation4')

zones.substationwest:addCriticalObject('substationW1')
zones.substationwest:addCriticalObject('substationW2')

zones.dam:addCriticalObject('dam1')
zones.dam:addCriticalObject('dam2')

zones.refinery:addCriticalObject('ref1')
zones.refinery:addCriticalObject('ref2')
zones.refinery:addCriticalObject('ref3')
zones.refinery:addCriticalObject('ref4')

zones.factory:addCriticalObject('factory1')
zones.factory:addCriticalObject('factory2')
zones.factory:addCriticalObject('factory3')
zones.factory:addCriticalObject('factory4')

zones.tv:addCriticalObject('tv1')

zones.radio:addCriticalObject('radioTower1')

zones.milbase:addCriticalObject('com_center')
zones.milbase:addCriticalObject('ammo_depot')


zones.incirlik.isHeloSpawn = true
zones.akrotiri.isHeloSpawn = true
zones.alpha.isHeloSpawn = true
zones.minakh.isHeloSpawn = true
zones.alduhur.isHeloSpawn = true
zones.hatay.isHeloSpawn = true
zones.alassad.isHeloSpawn = true
zones.hama.isHeloSpawn = true
zones.jirah.isHeloSpawn = true
zones.tabqa.isHeloSpawn = true
zones.aleppo.isHeloSpawn = true
zones.taftanaz.isHeloSpawn = true
zones.palmyra.isHeloSpawn = true
zones.foblima.isHeloSpawn = true
zones.fobmike.isHeloSpawn = true
zones.juliett.isHeloSpawn = true
zones.foxtrot.isHeloSpawn = true
zones.milbase.isHeloSpawn = true
zones.radio.isHeloSpawn = true
zones.india.isHeloSpawn = true
zones.durayhim.isHeloSpawn = true
zones.hotel.isHeloSpawn = true
zones.carrier.isHeloSpawn = true
zones.thalah.isHeloSpawn = true
zones.bengurion.isHeloSpawn = true
zones.ramatdavid.isHeloSpawn = true
zones.marka.isHeloSpawn = true
zones.kinghussein.isHeloSpawn = true
zones.princehassan.isHeloSpawn = true
zones.muwaffaq.isHeloSpawn = true
zones.roshpina.isHeloSpawn = true
zones.redcarrier.isHeloSpawn = true

zones.damascus.isHeloSpawn = true
zones.annasiriyah.isHeloSpawn = true
zones.rayak.isHeloSpawn = true
zones.beirut.isHeloSpawn = true
zones.renemouawad.isHeloSpawn = true
zones.shayrat.isHeloSpawn = true
zones.tiyas.isHeloSpawn = true
zones.paphos.isHeloSpawn = true
zones.pinarbashi.isHeloSpawn = true
zones.ercan.isHeloSpawn = true
zones.gecitkale.isHeloSpawn = true
zones.larnaca.isHeloSpawn = true
zones.karavostasi.isHeloSpawn = true
zones.polis.isHeloSpawn = true





zones.incirlik.airbaseName = 'Incirlik'
zones.minakh.airbaseName = 'Minakh'
zones.alduhur.airbaseName = 'Abu al-Duhur'
zones.hatay.airbaseName = 'Hatay'
zones.alassad.airbaseName = 'Bassel Al-Assad'
zones.hama.airbaseName = 'Hama'
zones.jirah.airbaseName = 'Jirah'
zones.tabqa.airbaseName = 'Tabqa'
zones.aleppo.airbaseName = 'Aleppo'
zones.taftanaz.airbaseName = 'Taftanaz'
zones.palmyra.airbaseName = 'Palmyra'
zones.foblima.airbaseName = 'FOB LIMA'
zones.fobmike.airbaseName = 'FOB MIKE'
zones.foxtrot.airbaseName = 'FOB FOXTROT'
zones.juliett.airbaseName = 'FOB JULIETT'
zones.milbase.airbaseName = 'FOB Military Base'
zones.india.airbaseName = 'FOB INDIA'
zones.polis.airbaseName = 'FOB POLIS'
zones.karavostasi.airbaseName = 'FOB KARAVOSTASI'
zones.durayhim.airbaseName = 'FOB DURAYHIM'
zones.hotel.airbaseName = 'FOB HOTEL'
zones.thalah.airbaseName = "Tha'lah"
zones.bengurion.airbaseName = 'Ben Gurion'
zones.ramatdavid.airbaseName = 'Ramat David'
zones.marka.airbaseName = 'Marka'
zones.kinghussein.airbaseName = 'King Hussein Air College'
zones.princehassan.airbaseName = 'Prince Hassan'
zones.muwaffaq.airbaseName = 'Muwaffaq Salti'
zones.roshpina.airbaseName = 'Rosh Pina'

zones.damascus.airbaseName = 'Damascus'
zones.annasiriyah.airbaseName = 'An Nasiriyah'
zones.rayak.airbaseName = 'Rayak'
zones.beirut.airbaseName = "Beirut-Rafic Hariri"
zones.renemouawad.airbaseName = 'Rene Mouawad'
zones.shayrat.airbaseName = 'Shayrat'
zones.tiyas.airbaseName = "Tiyas"


zones.paphos.airbaseName = 'Paphos'
zones.pinarbashi.airbaseName = 'Pinarbashi'
zones.ercan.airbaseName = 'Ercan'
zones.gecitkale.airbaseName = 'Gecitkale'
zones.larnaca.airbaseName = "Larnaca"
zones.akrotiri.airbaseName = 'Akrotiri'
zones.carrier.airbaseName = 'CVN-72'
zones.redcarrier.airbaseName = 'CVN-73'




for i,v in pairs(zones) do
	bc:addZone(v)
end

missions = {
}

bc:addConnection("Incirlik","Hatay")
bc:addConnection("Incirlik","Incirlik Defence")
bc:addConnection("Incirlik","FOB Alpha")
bc:addConnection("FOB Alpha","Hatay")
bc:addConnection("Hatay","Taftanaz")
bc:addConnection("Hatay","Minakh")
bc:addConnection("Hatay","Bravo")
bc:addConnection("Hatay","Bassel Al-Assad")
bc:addConnection("Minakh","Aleppo")
bc:addConnection("Minakh","Charlie")


bc:addConnection("Aleppo","Delta")
bc:addConnection("Aleppo","Jirah")
bc:addConnection("Aleppo","Abu al-Duhur")
bc:addConnection("Taftanaz","Abu al-Duhur")
bc:addConnection("Taftanaz","Delta")
bc:addConnection("Taftanaz","Power Plant")
bc:addConnection("Jirah","Tabqa")
bc:addConnection("Jirah","Abu al-Duhur")
bc:addConnection("Bassel Al-Assad","Hama")
bc:addConnection("Bassel Al-Assad","Hotel")
bc:addConnection("Abu al-Duhur","Hama")
bc:addConnection("Abu al-Duhur","Bassel Al-Assad")
bc:addConnection("Hama","Palmyra")
bc:addConnection("Hama","India")
bc:addConnection("India","Abu al-Duhur")
bc:addConnection("SA-5","Palmyra")
bc:addConnection("Jirah","Durayhim")
bc:addConnection("Jirah","Foxtrot")
bc:addConnection("Tabqa","Foxtrot")
bc:addConnection("Tabqa","Golf")
bc:addConnection("Tabqa","Dam")
bc:addConnection("Military Base","Palmyra")
bc:addConnection("Military Base","Tabqa")

--bc:addConnection("Carrier Group","Romeo")
bc:addConnection("Juliett","Tabqa")
bc:addConnection("Palmyra", "Refinery")
bc:addConnection("Juliett", "Refinery")
bc:addConnection("Abu al-Duhur", "Factory")
bc:addConnection("Abu al-Duhur", "November")
bc:addConnection("Hama", "November")
bc:addConnection("Oscar", "Tabqa")
bc:addConnection("Oscar", "Military Base")
bc:addConnection("Abu al-Duhur", "Papa")
bc:addConnection("Romeo", "Hama")
bc:addConnection("Bassel Al-Assad", "Romeo")
bc:addConnection("Red Carrier","Incirlik")
bc:addConnection("Red Carrier","Bassel Al-Assad")
bc:addConnection("Bassel Al-Assad","Incirlik")
bc:addConnection("Carrier Group","Akrotiri")
bc:addConnection("Akrotiri","Paphos")
bc:addConnection("Paphos","Polis")
bc:addConnection("Polis","Karavostasi")
bc:addConnection("Karavostasi", "Pinarbashi")

bc:addConnection("Pinarbashi","Gecitkale")
bc:addConnection("Gecitkale","Ercan")
bc:addConnection("Ercan","Larnaca")
bc:addConnection("Larnaca","Red Carrier")
bc:addConnection("Gecitkale","Silkworm Site")

bc:addConnection("Romeo", "Bassel Al-Assad")



bc:addConnection("Palmyra","Tiyas")
bc:addConnection("Tiyas","Shayrat")
bc:addConnection("Shayrat","Rene Mouawad")
bc:addConnection("Rene Mouawad","Beirut")
bc:addConnection("Beirut","Rayak")
bc:addConnection("Rayak","An Nasiriyah")


bc:addConnection("An Nasiriyah","Damascus")
bc:addConnection("Damascus","Rosh Pina")
bc:addConnection("Rosh Pina","Ramat David")
bc:addConnection("Ramat David","Ramat David Defence")
bc:addConnection("Ramat David","Thalah")



bc:addConnection("Thalah","King Hussein Air College")
bc:addConnection("King Hussein Air College","Prince Hassan")
bc:addConnection("Prince Hassan","Muwaffaq Salti")
bc:addConnection("Muwaffaq Salti","Marka")
bc:addConnection("Marka","Ben Gurion")
bc:addConnection("Ben Gurion","Ben Gurion Defence")

bc:addHiddenConnection("King Hussein Air College","Marka")
bc:addHiddenConnection("Ben Gurion","King Hussein Air College")
bc:addHiddenConnection("Ramat David","Ben Gurion")
bc:addHiddenConnection("Gecitkale","Basel Al-Assad")
bc:addHiddenConnection("Gecitkale","Incirlik")
bc:addHiddenConnection("An Nasiriyah","Palmyra")

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
			trigger.action.outText(L10N:Get("SYRIA_SETUP_MISSION_COMPLETE_RESTART"), 120)
			Utils.saveTable(bc.saveFile, 'zonePersistance', {})
			if resetSaveFileAndFarp then
			resetSaveFileAndFarp()
			end
			timer.scheduleFunction(function()
				trigger.action.setUserFlag(181, true)
			end, {}, timer.getTime() + 5)
		else
				trigger.action.outText(L10N:Get("SYRIA_SETUP_MISSION_COMPLETE_MENU"), 120)
				local subMenu = missionCommands.addSubMenuForCoalition(2, L10N:Get("SYRIA_SETUP_RESTART_MENU"), nil)
				missionCommands.addCommandForCoalition(2, L10N:Get("COMMON_YES"), subMenu, function()
						Utils.saveTable(bc.saveFile, 'zonePersistance', {})
						if resetSaveFileAndFarp then
						resetSaveFileAndFarp()
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
end

for i,v in ipairs(bc:getZones()) do
	v:registerTrigger('lost', checkMissionComplete, 'missioncompleted')
end


SCHEDULER:New(nil,function()
	checkMissionComplete(nil, nil)
	bc:roamGroupsToLocalSubZone({
		"Red Armour Group #",
		"Red Armour Group 4 #",
		"Red Armour Group 3 #",
		"Red Armor Group6 #",
		"Red Armor Group7 #",
		"Red Armor Group8 #",
		"Red Armor Group9 #",
		"Red SAM AAA #",
		"Red SAM SHORAD SA-15 #",
		"Red Armour Group 2 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-19 #",
		"Molniya #",
		"Rezky #",
		"Neustrashimy #",
		"Red SAM SHORAD Tor M2 #",
		"Red SAM SHORAD Pantsir S1 #"
	}, 30, { "Dam" }, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
end,{},5,0)

zones.charlie:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SETUP_EWR_DESTROYED"),20)
end, 'disableCharlie')

zones.kilo:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SETUP_EWR_DESTROYED"),20)
end, 'disableKilo')

zones.substationnorth:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disablesubn1')

zones.substationnorth:registerTrigger('destroyed', function(event, sender)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SETUP_SUBSTATION_DISABLED"),20)
end, 'disablesubn2')

zones.tv:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disabletv1')

zones.tv:registerTrigger('destroyed', function(event, sender)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SETUP_TV_TOWER_DISABLED"),20)
end, 'disabletv2')

zones.substationwest:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disablesubw1')

zones.substationwest:registerTrigger('destroyed', function(event, sender)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SETUP_SUBSTATION_DISABLED"),20)
end, 'disablesubw2')

zones.radio:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableradio1')

zones.radio:registerTrigger('destroyed', function(event, sender)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SETUP_RADIO_TOWER_DISABLED"),20)
end, 'disableradio2')

zones.sierra:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableradar1')

zones.sierra:registerTrigger('destroyed', function(event, sender)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SETUP_RADAR_DISABLED"),20)
end, 'disableradar2')

zones.tango:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableins1')

zones.tango:registerTrigger('destroyed', function(event, sender)
	bc:addFunds(2,1000)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SETUP_INSURGENTS_CLEARED"),20)
end, 'disableins2')

zones.uniform:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableins3')

zones.uniform:registerTrigger('destroyed', function(event, sender)
	bc:addFunds(2,1000)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SETUP_INSURGENTS_CLEARED"),20)
end, 'disableins4')

zones.victor:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableins5')

zones.victor:registerTrigger('destroyed', function(event, sender)
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SETUP_BLACKHAWK_RESCUED"),20)
end, 'disableins6')

--------------------------------------- cutsom disable ''''''''''''''''''''''''''''''''''''''''''

zones.benguriondefence:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SETUP_DEFENCES_DESTROYED", "Ben Gurion"),20)
end, 'disablebenguriondefence')

zones.ramatdaviddefence:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SETUP_DEFENCES_DESTROYED", "Ramat David"),20)
end, 'disableramatdaviddefence')

zones.jordandefence:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SETUP_DEFENCES_DESTROYED", "Jordan"),20)
end, 'disablejordandefence')

zones.incirlikdefence:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Format("SYRIA_SETUP_DEFENCES_DESTROYED", "Incirlik"),20)
end, 'disableincirlikdefence')

zones.silkworm:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SETUP_SILKWORM_DESTROYED"),20)
end, 'disablesilkworm')


--------------------------------------- cutsom disable ''''''''''''''''''''''''''''''''''''''''''

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


bc:addMonitoredROE('cruise1')
local cruiseMissileTargetMenu = nil
bc:registerShopItem('cruisemsl', LTGet("SYRIA_SHOP_ITEM_CRUISE_MISSILE"), ShopPrices.cruisemsl, function(sender)
	return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE")
end,
function (sender, params)
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

---------------------------------------------END DYNAMIC SHOP ------------------------------------------

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
----------------------------------- START own 9 line jtac AM START ----------------------------------
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

  -------------------------- END 9 line jtac FM END ----------------------------------
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

Group.getByName('ewAircraft'):destroy()
--[[
local jamMenu = nil
bc:registerShopItem('jam', LTGet("SYRIA_SHOP_ITEM_JAM_RADARS"), ShopPrices.jam, function(sender)
	local gr = Group.getByName('ewAircraft')
	if Utils.isGroupActive(gr) then 
		return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "Jamming")
	end
	
	RespawnGroup('ewAircraft')
	
	if jamMenu then
		return LTGet("SYRIA_SHOP_CHOOSE_TARGET_ZONE_F10")
	end
	
	local startJam = function(target)
		if jamMenu then
			bc:jamRadarsAtZone('ewAircraft', target)
			jamMenu = nil
			trigger.action.outTextForCoalition(2, 'Growler jamming radars at '..target, 15)
		end
	end
	
	jamMenu = bc:showTargetZoneMenu(2, 'Jamming target', startJam, 1)
	trigger.action.outTextForCoalition(2, L10N:Get("SYRIA_SHOP_CHOOSE_TARGET_ZONE_F10"), 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
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
				
				trigger.action.outTextForCoalition(2, 'Growler jamming radars at '..target, 15)
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
]]
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
	if params.zone and params.zone.side == 2 then
		
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

-- end of red

local infMenu=nil
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
bc.shopItems['dynamicbomb'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['dynamicbomb'].groupZoneSelector.refreshTags = { 'enemy_targets' }
bc.shopItems['groundattack'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['groundattack'].groupZoneSelector.refreshTags = { 'enemy_targets' }
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
--[[
bc.shopItems['jam'].groupZoneSelector.candidateBucket = 'enemy_unsuspended'
bc.shopItems['jam'].groupZoneSelector.refreshTags = { 'enemy_targets' }
]]
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
	dynamiccap    = 500,  -- CAP Flight
	dynamicarco   = 1000,  -- Dynamic Tanker (Drogue)
	dynamictexaco = 1000,  -- Dynamic Tanker (Boom)
	dynamiccas    = 1000, -- CAS Flight
	dynamicdecoy  = 300,  -- TALD DECOY Flight
	dynamicsead   = 500,  -- SEAD Flight
	dynamicbomb   = 500,  -- Bomber Flight
	groundattack  = 1000, -- Ground attack convoy
	cruisemsl     = 800,  -- Cruise Missile Strike
	supplies2     = 200,  -- Resupply friendly Zone
	supplies      = 1000, -- Fully Upgrade Friendly Zone
	jtac          = 500,  -- MQ-9 Reaper JTAC mission
	["9lineam"]   = 0,    -- Jtac 9line AM
	["9linefm"]   = 0,    -- Jtac 9line FM
	jam           = 500,  -- Jam radars at zone
	armor         = 100,  -- Deploy armor
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
	dynamiccap     = 2,  -- CAP Flight
	dynamiccas     = 5,  -- CAS Flight
	dynamicbomb    = 4,  -- Bomber Flight
	dynamicsead    = 4,  -- SEAD Flight
	groundattack   = 5,  -- Ground attack convoy
	dynamicdecoy   = 1,  -- TALD DECOY Flight
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


-- first value below is how much in stock, the second number value is the ranking in the shop menu list, the third is the new ranking system.

bc:addShopItem(1, 'redzoneupgrade', -1, 1) -- red AI zone upgrade
bc:addShopItem(1, 'redmassattack', -1, 1) -- red AI mass airbase attack

-- AI Attack
bc:addShopItem(2, 'dynamiccap', -1, 1, ShopRankRequirements.dynamiccap, ShopCats.AIAttack) -- CAP Flight
bc:addShopItem(2, 'dynamiccas', -1, 2, ShopRankRequirements.dynamiccas, ShopCats.AIAttack) -- CAS Flight
bc:addShopItem(2, 'dynamicbomb', -1, 3, ShopRankRequirements.dynamicbomb, ShopCats.AIAttack) -- Bomber Flight
bc:addShopItem(2, 'dynamicsead', -1, 4, ShopRankRequirements.dynamicsead, ShopCats.AIAttack) -- SEAD Flight
bc:addShopItem(2, 'dynamicdecoy', -1, 5, ShopRankRequirements.dynamicdecoy, ShopCats.AIAttack) -- TALD DECOY Flight
bc:addShopItem(2, 'groundattack', -1, 6, ShopRankRequirements.groundattack, ShopCats.AIAttack) -- Ground attack convoy
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
bc:addShopItem(2, '9lineam', -1, 6, ShopRankRequirements["9lineam"], ShopCats.JTACIntel) -- free jtac
bc:addShopItem(2, '9linefm', -1, 7, ShopRankRequirements["9linefm"], ShopCats.JTACIntel) -- free jtac


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
    'FOB Alpha', 
    'Incirlik', 
    'Carrier Group',
    'FOB Lima', 
    'FOB Mike', 
    'Taftanaz', 
    'Abu al-Duhur', 
    'Jirah',
    'Minakh',
    'Aleppo',
    'Tabqa',
    'Bassel Al-Assad',
    'Hama',
    'Palmyra',
    'Hatay',
    'India',
    'Juliett',
    'Military Base',
    'Akrotiri',
    'Paphos',
    'Polis',
    'Karavostasi',
    'Larnaca',
    'Ercan',
    'Pinarbashi',
    'Gecitkale',
    'Bravo',
    'Charlie',
    'Delta',
    'Red Carrier',
    'Foxtrot',
    'Golf',
    'Hotel',
    'Juliett',
    'Kilo',
    'November',
    'Oscar',
    'Papa',
    'Romeo',
    'Sierra',
    'Tango',
    'Uniform',
    'Victor',
    'Durayhim',
    'Dam',
    'TV Tower',
    'SA-5',
    'Rene Mouawad',
    'Beirut',
    'Rayak',
    'Tiyas',
    'Damascus',
    'An Nasiriyah',
    'Thalah',
    'King Hussein Air College',
    'Muwaffaq Salti',
    'Prince Hassan',
    'Ben Gurion',
    'Ramat David',
    'Rosh Pina',
    'Marka',
    'Shayrat'
}

TerritoryOverlayOuterDrawPushMeters = 30000

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
		zones.bengurion.LogisticCenter = true
		DestroyOnce=true
    else
        zones.akrotiri.LogisticCenter = true
    end
else
    applyRandomUpgradesForNewZonesOnly()
end

bc:init()
if disableBlueCarrierAfterInit then
	destroyGroupIfActive('CVN-74')
	destroyGroupIfActive('CVN-72')	
	destroyGroupIfActive('HMS Invincible')
	bc:addConnection("Ramat David", "Ben Gurion")
	bc:addConnection("Thalah", "Ben Gurion")
	bc:addConnection("King Hussein Air College", "Ben Gurion")
	bc:addConnection("Palmyra", "An Nasiriyah")
	bc:addConnection("Hama","Rene Mouawad")
	bc:RefreshConnectionsLines("Ben Gurion")
	bc:RefreshConnectionsLines("An Nasiriyah")
	bc:RefreshConnectionsLines("Rene Mouawad")
end
	if DestroyOnce then
		destroyGroupIfActive('Red SAM SHORAD SA-15 Fixed HiddenGroup South')
		destroyGroupIfActive('Red SAM SHORAD SA-8 Fixed HiddenGroup South')
		destroyGroupIfActive('Red EWR-south Fixed Coldwar')
		destroyGroupIfActive('Red EWR-south Fixed')
		destroyGroupIfActive('HQ Fixed')
		CustomFlags["EWRSouth"] = true
		zones.carrier:disableZone(true)
		zones.benguriondefence:disableZone(true)
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
local HuntNumber = SplashDamage and math.random(10,15) or math.random(8,15)
bc:initHunter(HuntNumber)
SCHEDULER:New(nil, function() bc:_buildHunterBaseList() end, {}, 1)

SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 5)
SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 6)

AWACS_CFG = {
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=150 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=65 }   -- blue
}

GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 90   		-- suspend red zones deeper than this nm
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
					'Hatay',
					'Abu al-Duhur',
					'Hama',
					'Jirah',
					'Aleppo',
					'Taftanaz',
					'Palmyra',
					'Bassel Al-Assad'
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
				bc:fireAtZone(choice, 'oscar-scud-1', false, 8)
				trigger.action.outTextForCoalition(2, L10N:Format("SYRIA_EVENT_SCUDS_LAUNCHING", choice), 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
		if ActiveMission['scuds'] then return false end
		local gr = Group.getByName('oscar-scud-1')
		if gr then return false end
		
		if bc:getZoneByName('Oscar').side ~= 1 then return false end
		
		local triggers = {'Abu al-Duhur', 'Aleppo', 'Palmyra', 'Hama'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		
		return false
	end
})
mc:trackMission({
    title = LTGet("SYRIA_MISSION_SCUDS_TITLE"),
    description = LTGet("SYRIA_MISSION_SCUDS_DESC"),
    messageStart = LTGet("SYRIA_MISSION_SCUDS_START"),
    messageEnd = LTGet("SYRIA_MISSION_SCUDS_END"),
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
		if Group.getByName('oscar-scud-1') then return true end
		ActiveMission['scuds'] = nil
		return false
    end
})

--------------------------------------- End of Oscar Scuds ---------------------------------------
---------------------------------------- Escort me mission ---------------------------------------
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
		
		local triggers = {'Abu al-Duhur', 'Hatay', 'Incirlik', 'Taftanaz', 'Hama'}
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
    description = LTGet("SYRIA_MISSION_ESCORT_CARGO_DESC"),
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
---------------------------------------- End of Escort me mission ---------------------------------------
-------------------------------------------- CAS 1 --------------------------------------------
local airstrike_COOLDOWN = 1800
local lastairstrike_COOLDOWN  = -airstrike_COOLDOWN
local casGrp = Era=='Coldwar' and 'evt-CAScw' or 'evt-CAS'
Group.getByName('evt-CAS'):destroy()
Group.getByName('evt-CAScw'):destroy()
evc:addEvent({
	id='cas',
	action=function()
		RespawnGroup(casGrp)
		RegisterGroupTarget(casGrp,500,L10N:Get("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),'cas')
		timer.scheduleFunction(function()
			local tgts={'Hatay','Abu al-Duhur','Hama','Jirah','Aleppo','Taftanaz','Palmyra','Bassel Al-Assad','Hotel','Juliett','Factory','India','Military Base',
						'An Nasiriyah','Rayak','Palmyra'}
			local valid={}
			for _,v in ipairs(tgts) do
				if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then valid[#valid+1]=v end
			end
			if #valid~=0 then
				local choice=valid[math.random(1,#valid)]
				if Group.getByName(casGrp) then bc:engageZone(choice,casGrp) end
			end
		end,{},timer.getTime()+3)
	end,
	canExecute=function()
		if ActiveMission['cas'] then return false end
		if timer.getTime()-lastairstrike_COOLDOWN<airstrike_COOLDOWN then return false end
		if Group.getByName(casGrp) then return false end
		local triggers={'Abu al-Duhur','Aleppo','Hama','Tabqa','Palmyra'}
		if math.random(1,100)<70 then return false end
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end
		end
		return false
	end
})
mc:trackMission({
	title = LTGet("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),
	description = LTGet("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_DESC_SE"),
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
		if Group.getByName('evt-CAS') then return true end
		if Group.getByName('evt-CAScw') then return true end
		ActiveMission['cas'] = nil
		return false
	end
})
-------------------------------------------- End of CAS 2 -----------------------------------------

-------------------------------------------- CAS 2 --------------------------------------------
local airstrike2_COOLDOWN = 1800
local lastairstrike2_COOLDOWN  = -airstrike2_COOLDOWN
local casGrp = Era=='Coldwar' and 'evt-CAScw2' or 'evt-CAS2'
Group.getByName('evt-CAS2'):destroy()
Group.getByName('evt-CAScw2'):destroy()
evc:addEvent({
	id='cas2',
	action=function()
		RespawnGroup(casGrp)
		RegisterGroupTarget(casGrp,500,L10N:Get("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),'cas2')
		timer.scheduleFunction(function()
			local tgts = {'Paphos','Ercan','Gecitkale','Pinarbashi','Larnaca','Incirlik'}
			local valid={}
			for _,v in ipairs(tgts) do
				if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then valid[#valid+1]=v end
			end
			if #valid~=0 then
				local choice=valid[math.random(1,#valid)]
				if Group.getByName(casGrp) then bc:engageZone(choice,casGrp) end
			end
		end,{},timer.getTime()+3)
	end,
	canExecute=function()
		if ActiveMission['cas2'] then return false end
		if timer.getTime()-lastairstrike2_COOLDOWN<airstrike2_COOLDOWN then return false end
		if Group.getByName(casGrp) then return false end
		local triggers={'Paphos','Incirlik'}
		if math.random(1,100)<70 then return false end
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end
		end
		return false
	end
})
mc:trackMission({
	title = LTGet("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),
	description = LTGet("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_DESC_NS"),
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
		if not ActiveMission['cas2'] then return false end
		if Group.getByName('evt-CAS2') then return true end
		if Group.getByName('evt-CAScw2') then return true end
		ActiveMission['cas2'] = nil
		return false
	end
})
-------------------------------------------- End of CAS 2 -----------------------------------------
------------------------------------------------ Bomber event ---------------------------------------------
local bomb_COOLDOWN = 1800
local lastbomb_COOLDOWN  = -bomb_COOLDOWN
Group.getByName('evt-bomber'):destroy()
local escGrp = Era=='Coldwar' and 'EscortBomberCW' or 'EscortBomber'

evc:addEvent({
	id='bomb',
	action=function()
		RespawnGroup('evt-bomber')
		RegisterGroupTarget('evt-bomber',500,L10N:Get("SYRIA_MISSION_TARGET_INTERCEPT_BOMBERS"),'bomb')
		timer.scheduleFunction(function()
			RespawnGroup(escGrp)
				local tgts = {
					'Hatay','Abu al-Duhur','Hama','Jirah','Aleppo','Taftanaz','Palmyra',
					'Bassel Al-Assad','Hotel','Juliett','Factory','India','Military Base'}
					if Group.getByName('evt-bomber') then
						local bomber, bomberMission = StartBomberAuftrag('bomb', 'evt-bomber', tgts, escGrp)
				end
		end,{},timer.getTime()+1)
	end,
	canExecute=function()
		if ActiveMission['bomb'] then return false end
		if timer.getTime()-lastbomb_COOLDOWN<bomb_COOLDOWN then return false end
		if Group.getByName('evt-bomber') then return false end
		--if math.random(1,100)<70 then return false end
		local trg={'Abu al-Duhur','Aleppo','Hama','Tabqa','Palmyra'}
		for _,v in ipairs(trg) do
			if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end
		end
		return false
	end
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_TITLE"),
	description = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_DESC_NE"),
	messageStart = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_START"),
	messageEnd=function(T) lastbomb_COOLDOWN=timer.getTime() return LT(T):Get("SYRIA_MISSION_INTERCEPT_BOMBERS_END") end,
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
		if Group.getByName('evt-bomber') then return true end
		ActiveMission['bomb'] = nil
		return false
	end
})

-------------------------------------------- End of Bomber event ------------------------------------------

------------------------------------------------ Bomber 2 event ---------------------------------------------
local bomb2_COOLDOWN = 1800
local lastbomb2_COOLDOWN  = -bomb2_COOLDOWN
Group.getByName('evt-bomber2'):destroy()
local escGrp2 = Era=='Coldwar' and 'EscortBomber2CW' or 'EscortBomber2'

evc:addEvent({
	id='bomb2',
	action=function()
		RespawnGroup('evt-bomber2')
		RegisterGroupTarget('evt-bomber2',500,L10N:Get("SYRIA_MISSION_TARGET_INTERCEPT_BOMBERS"),'bomb2')
		timer.scheduleFunction(function()
			RespawnGroup(escGrp2)
			local tgts = {
					'Paphos','Ercan','Gecitkale','Pinarbashi','Larnaca','Incirlik'}
					if Group.getByName('evt-bomber2') then
						local bomber2, bomber2mission = StartBomberAuftrag('bomb2', 'evt-bomber2', tgts, escGrp2)
					end
		end,{},timer.getTime()+1)
	end,
	canExecute=function()
		if ActiveMission['bomb2'] then return false end
		if ActiveMission['bomb'] then return false end
		if timer.getTime()-lastbomb2_COOLDOWN<bomb2_COOLDOWN then return false end
		--if math.random(1,100)<70 then return false end
		local trg={'Paphos','Incirlik'}
		for _,v in ipairs(trg) do
			if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end
		end
		return false
	end
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_TITLE"),
	description = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_DESC_CYPRUS"),
	messageStart = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_START"),
	messageEnd=function(T) lastbomb2_COOLDOWN=timer.getTime() return LT(T):Get("SYRIA_MISSION_INTERCEPT_BOMBERS_END") end,
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
		if not ActiveMission['bomb2'] then return false end
		if Group.getByName('evt-bomber2') then return true end
		ActiveMission['bomb2'] = nil
		return false
	end
})

-------------------------------------------- End of Bomber 2 event ------------------------------------------

------------------------------------------------ Bomber 2 event ---------------------------------------------
local bomb3_COOLDOWN = 1800
local lastbomb3_COOLDOWN  = -bomb3_COOLDOWN
Group.getByName('evt-bomber3'):destroy()
local escGrp3 = Era=='Coldwar' and 'EscortBomber3CW' or 'EscortBomber3'

evc:addEvent({
	id='bomb3',
	action=function()
		RespawnGroup('evt-bomber3')
		RegisterGroupTarget('evt-bomber3',500,L10N:Get("SYRIA_MISSION_TARGET_INTERCEPT_BOMBERS"),'bomb3')
		timer.scheduleFunction(function()
			local bomber3
			RespawnGroup(escGrp3)
				local tgts = {
					'Beirut','An Nasiriyah','Damascus','Thalah','King Hussein Air College','Prince Hassan', 'Ramat David'}

				if Group.getByName('evt-bomber3') then
					local bomber3, bomber3mission = StartBomberAuftrag('bomb3', 'evt-bomber3', tgts, escGrp3)

				end
		end,{},timer.getTime()+1)
	end,
	canExecute=function()
		if ActiveMission['bomb3'] then return false end
		if ActiveMission['bomb2'] then return false end
		if ActiveMission['bomb'] then return false end
		if timer.getTime()-lastbomb3_COOLDOWN<bomb3_COOLDOWN then return false end
		if Group.getByName('evt-bomber') then return false end
		if Group.getByName('evt-bomber2') then return false end
		if Group.getByName('evt-bomber3') then return false end
		--if math.random(1,100)<70 then return false end
		local trg={'An Nasiriyah','Beirut','King Hussein Air College', 'Prince Hassan', 'Ramat David','Muwaffaq Salti','Beirut','Palmyra'}
		for _,v in ipairs(trg) do
			if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end
		end
		return false
	end
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_TITLE"),
	description = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_DESC_CYPRUS"),
	messageStart = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_START"),
	messageEnd=function(T) lastbomb3_COOLDOWN=timer.getTime() return LT(T):Get("SYRIA_MISSION_INTERCEPT_BOMBERS_END") end,
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
		if not ActiveMission['bomb3'] then return false end
		if Group.getByName('evt-bomber3') then return true end
		ActiveMission['bomb3'] = nil
		return false
	end
})

-------------------------------------------- End of Bomber 3 event ------------------------------------------

------------------------------------------------- Ship event ----------------------------------------------
local Ship_COOLDOWN = 1800
local lastShip_COOLDOWN   = -Ship_COOLDOWN
Group.getByName('evt-shiptercept1'):destroy()
Group.getByName('evt-shiptercept2'):destroy()
Group.getByName('evt-shiptercept3'):destroy()
local shipDieEvent = nil

evc:addEvent({
  id = 'shiptercept',
  action = function()
    local ships = {'evt-shiptercept1','evt-shiptercept2','evt-shiptercept3'}
    local choice = math.random(1,#ships)
    RespawnGroup(ships[choice])
		RegisterGroupTarget(ships[choice],500,L10N:Get("SYRIA_MISSION_TARGET_DESTROY_CARGO_SHIP"),'shiptercept')
  end,
  canExecute = function()
	if ActiveMission['shiptercept'] then return false end
	if timer.getTime() - lastShip_COOLDOWN < Ship_COOLDOWN then return false end
    if math.random(1, 100) < 70 then return false end
    if bc:getZoneByName('Red Carrier').side ~= 1 then return false end
    if Group.getByName('evt-shiptercept1') then return false end
    if Group.getByName('evt-shiptercept2') then return false end
    if Group.getByName('evt-shiptercept3') then return false end
    return true
  end
})
mc:trackMission({
    title = LTGet("SYRIA_MISSION_DESTROY_CARGO_SHIP_TITLE"),
    description = LTGet("SYRIA_MISSION_DESTROY_CARGO_SHIP_DESC"),
    messageStart = LTGet("SYRIA_MISSION_DESTROY_CARGO_SHIP_START"),
    messageEnd =function(T) lastShip_COOLDOWN=timer.getTime() return LT(T):Get("SYRIA_MISSION_DESTROY_CARGO_SHIP_END") end,
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "radio2.ogg")
        end
    end,
    endAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
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


-------------------------------------------- End of Ship event ---------------------------------------------
------------------------------------------------- Cargo event ---------------------------------------------
local Cargo_COOLDOWN = 1800
local lastCargo_COOLDOWN   = -Cargo_COOLDOWN
Group.getByName('evt-cargointercept1'):destroy()
Group.getByName('evt-cargointercept2'):destroy()
Group.getByName('evt-cargointercept3'):destroy()
evc:addEvent({
	id='cargointercept',
	action = function()
		local planes = {'evt-cargointercept1','evt-cargointercept2','evt-cargointercept3'}
		local choice = math.random(1,#planes)
		RespawnGroup(planes[choice])
		RegisterGroupTarget(planes[choice],500,L10N:Get("SYRIA_MISSION_INTERCEPT_CARGO_TITLE"),'cargointercept')
	end,
	canExecute = function()
		if ActiveMission['cargointercept'] then return false end
		if timer.getTime() - lastCargo_COOLDOWN < Cargo_COOLDOWN then return false end
		if math.random(1,100) < 70 then return false end
		local redCarrier = bc:getZoneByName('Red Carrier')
		if redCarrier.side ~= 1 or redCarrier.suspended then return false end
		local basselAlAssad = bc:getZoneByName('Bassel Al-Assad')
		if basselAlAssad.side ~= 1 or basselAlAssad.suspended then return false end
		return true
	end
})
mc:trackMission({
    title = LTGet("SYRIA_MISSION_INTERCEPT_CARGO_TITLE"),
    description = LTGet("SYRIA_MISSION_INTERCEPT_CARGO_DESC"),
    messageStart = LTGet("SYRIA_MISSION_INTERCEPT_CARGO_START"),
    messageEnd =function(T) lastCargo_COOLDOWN=timer.getTime() return LT(T):Get("SYRIA_MISSION_INTERCEPT_CARGO_END") end,
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
------------------------------------------ End of Cargo event -----------------------------------------
-------------------------------------------- Duhur attack ---------------------------------------------
duhurForce = {
	['Aleppo'] = { 'evt-aleppo-duhur-attack' , 'evt-aleppo-duhur-deploy-1', 'evt-aleppo-duhur-deploy-2', 'evt-aleppo-duhur-deploy-3'},
	['Tabqa'] = { 'evt-tabqa-duhur-sead' },
	['November'] = { 'evt-november-duhur-arty', 'evt-november-duhur-arty2' },
	['Hama']            = (Era == 'Coldwar') and { 'evt-hama-duhur-cas-coldwar' }     or { 'evt-hama-duhur-cas' },
	['Bassel Al-Assad'] = (Era == 'Coldwar') and { 'evt-bassel-duhur-sead-Coldwar' } or { 'evt-bassel-duhur-sead' },
}
for i,v in pairs(duhurForce) do
	for _,v2 in ipairs(v) do
		Group.getByName(v2):destroy()
	end
end
evc:addEvent({
	id='duhurattack',
	action = function()
		for i,v in pairs(duhurForce) do
			if bc:getZoneByName(i).side == 1 and not bc:getZoneByName(i).suspended then
				for _,v2 in ipairs(v) do
					 RespawnGroup(v2)
				end
			end
		end
	end,
	canExecute = function()
		if math.random(1,100) < 60 then return false end

		if bc:getZoneByName('Abu al-Duhur').side ~= 2 or bc:getZoneByName('Abu al-Duhur').suspended then return false end

		local canAttack = false
		for i,v in pairs(duhurForce) do
			if bc:getZoneByName(i).side == 1 and not bc:getZoneByName(i).suspended then canAttack = true end
			
			for _,v2 in ipairs(v) do
				if Group.getByName(v2) then return false end
			end
		end
		return canAttack
	end
})
mc:trackMission({
    title = LTGet("SYRIA_MISSION_DEFEND_DUHUR_TITLE"),
    description = LTGet("SYRIA_MISSION_DEFEND_DUHUR_DESC"),
    messageStart = LTGet("SYRIA_MISSION_DEFEND_DUHUR_START"),
    messageEnd = LTGet("SYRIA_MISSION_DEFEND_DUHUR_END"),
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
        for i, v in pairs(duhurForce) do
            for _, v2 in ipairs(v) do
                if Group.getByName(v2) then return true end
            end
        end
        return false
    end
})

------------------------------------End of Duhur attack --------------------------------------
------------------------------------ Convoy intercept ----------------------------------------
Group.getByName('GroundConvoy1'):destroy()
Group.getByName('GroundConvoy2'):destroy()
Group.getByName('GroundConvoy3'):destroy()
local Convoyintercept = nil
evc:addEvent({
	id='Convoyintercept',
	action = function()
		local convoy = {'GroundConvoy1','GroundConvoy2','GroundConvoy3'}
		local target = {
			GroundConvoy1 = 'GroundConvoyInfantry',
			GroundConvoy2 = 'GroundConvoyInfantry2',
			GroundConvoy3 = 'GroundConvoyInfantry3'
		}
		local name = convoy[math.random(1, #convoy)]
		RespawnGroup(name)
		RegisterGroupTarget(target[name], 2500, L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),'Convoyintercept',true)
	end,
	canExecute = function()
		if CustomFlags['Convoyintercept'] then return false end
		if ActiveMission['Convoyintercept'] then return false end
		if math.random(1,100) < 50 then return false end
		local pinarbashi = bc:getZoneByName('Pinarbashi')
		if pinarbashi.side ~= 1 or pinarbashi.suspended then return false end
		if Group.getByName('GroundConvoy1') then return false end
		if Group.getByName('GroundConvoy2') then return false end
		if Group.getByName('GroundConvoy3') then return false end
		return true
	end
})


mc:trackMission({
    title = LTGet("SYRIA_MISSION_FIND_GENERAL_TITLE"),
    description = LTGet("SYRIA_MISSION_FIND_GENERAL_DESC"),
    messageStart = LTGet("SYRIA_MISSION_FIND_GENERAL_START"),
    messageEnd = LTGet("SYRIA_MISSION_FIND_GENERAL_END"),
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
		if CustomFlags['Convoyintercept'] then return false end
		if not ActiveMission['Convoyintercept'] then return false end
        if Group.getByName('GroundConvoy1') then return true end
        if Group.getByName('GroundConvoy2') then return true end
        if Group.getByName('GroundConvoy3') then return true end
        ActiveMission['Convoyintercept'] = nil
        return false
    end
})
-------------------------------- End of Convoy intercept -----------------------------

local sceneryList = {
    ["StrikeTarget"] = {SCENERY:FindByZoneName("StrikeTarget")},
    ["StrikeTarget1"] = {SCENERY:FindByZoneName("StrikeTarget1")},
    ["StrikeTarget2"] = {SCENERY:FindByZoneName("StrikeTarget2")},
    ["EnemyHideout"] = {SCENERY:FindByZoneName("EnemyHideout")},
    ["TaftanazWarehouse"] = {SCENERY:FindByZoneName("TaftanazWarehouse")},
    ["SA5Warehouse"] = {SCENERY:FindByZoneName("SA5Warehouse")},
    ["AssadWarehouse"] = {SCENERY:FindByZoneName("AssadWarehouse")},
    ["DavidWarehouse"] = {SCENERY:FindByZoneName("DavidWarehouse")},
    ["SA11WareHouse"] = {SCENERY:FindByZoneName("SA11WareHouse")},
    ["IncirlikWarehouse"] = {SCENERY:FindByZoneName("IncirlikWarehouse")},
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
------------------------------------ custom missions --------------------------------
-------------------------------- Strike the enemy hideout -------------------------

evc:addEvent({
	id = 'EnemyHideout',
	action = function()
		local tgt = sceneryList['EnemyHideout'][1] or SCENERY:FindByZoneName('EnemyHideout')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "EnemyHideout"),30)
			return
		end
		RegisterScoreTarget('EnemyHideout',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("SYRIA_MISSION_STRIKE_ENEMY_HIDEOUT_TITLE"),p,2,false,false)
			MissionMarks['EnemyHideout'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['EnemyHideout'] then return false end
	if CustomFlags["EnemyHideout"] then return false end
	if bc:getZoneByName('Hatay').side ~= 2 or bc:getZoneByName('Abu al-Duhur').side ~= 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_ENEMY_HIDEOUT_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_ENEMY_HIDEOUT_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_ENEMY_HIDEOUT_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_ENEMY_HIDEOUT_END"),
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
	if CustomFlags["EnemyHideout"] then return false end
	if ActiveMission['EnemyHideout'] then return true end
	return false
	end
})


--------------------------------- TaftanazWarehouse --------------------------------

evc:addEvent({
	id = 'TaftanazWarehouse',
	action = function()
		local tgt = sceneryList['TaftanazWarehouse'][1] or SCENERY:FindByZoneName('TaftanazWarehouse')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "TaftanazWarehouse"),30)
			return
		end
		RegisterScoreTarget('TaftanazWarehouse',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"), true)
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("SYRIA_MISSION_STRIKE_TAFTANAZ_WAREHOUSE_TITLE"),p,2,false,false)
			MissionMarks['TaftanazWarehouse'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['TaftanazWarehouse'] then return false end
	if CustomFlags["TaftanazWarehouse"] then return false end
	if bc:getZoneByName('Taftanaz').side ~= 1 or bc:getZoneByName('Taftanaz').suspended then return false end
	if bc:getZoneByName('Hatay').side ~= 2 and bc:getZoneByName('Abu al-Duhur').side ~= 2 and bc:getZoneByName('Bassel Al-Assad').side ~= 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_TAFTANAZ_WAREHOUSE_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_TAFTANAZ_WAREHOUSE_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_TAFTANAZ_WAREHOUSE_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_TAFTANAZ_WAREHOUSE_END"),
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
	if CustomFlags["TaftanazWarehouse"] then return false end
	if bc:getZoneByName("Taftanaz").side ~= 1 then return false end
	if ActiveMission['TaftanazWarehouse'] then return true end
	return false
	end
})
---------------------------------- Al Duhur SA-11 Warehouse ---------------------

evc:addEvent({
	id = 'SA11WareHouse',
	action = function()
		local tgt = sceneryList['SA11WareHouse'][1] or SCENERY:FindByZoneName('SA11WareHouse')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "SA11WareHouse"),30)
			return
		end
		RegisterScoreTarget('SA11WareHouse',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("SYRIA_MISSION_STRIKE_ABU_DUHUR_PAPA_WAREHOUSE_MARK"),p,2,false,false)
			MissionMarks['SA11WareHouse'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['SA11WareHouse'] then return false end
	if CustomFlags["SA11WareHouse"] then return false end
	if bc:getZoneByName('Abu al-Duhur').side ~= 1 or bc:getZoneByName('Papa').side ~= 1 then return false end
	if bc:getZoneByName('Hatay').side ~= 2 and bc:getZoneByName('Tabqa').side ~= 2 and bc:getZoneByName('Bassel Al-Assad').side ~= 2 and bc:getZoneByName('Palmyra').side ~= 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_ABU_DUHUR_PAPA_WAREHOUSE_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_ABU_DUHUR_PAPA_WAREHOUSE_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_ABU_DUHUR_PAPA_WAREHOUSE_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_ABU_DUHUR_PAPA_WAREHOUSE_END"),
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
	if CustomFlags["SA11WareHouse"] then return false end
	if bc:getZoneByName('Abu al-Duhur').side ~= 1 or bc:getZoneByName('Papa').side ~= 1 then return false end
	if ActiveMission['SA11WareHouse'] then return true end
	return false
	end
})
----------------------------------- Incirlik Warehouse -----------------------------
evc:addEvent({
	id = 'IncirlikWarehouse',
	action = function()
		local tgt = sceneryList['IncirlikWarehouse'][1] or SCENERY:FindByZoneName('IncirlikWarehouse')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "IncirlikWarehouse"),30)
			return
		end
		RegisterScoreTarget('IncirlikWarehouse',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("SYRIA_MISSION_STRIKE_INCIRLIK_WAREHOUSE_TITLE"),p,2,false,false)
			MissionMarks['IncirlikWarehouse'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['IncirlikWarehouse'] then return false end
	if CustomFlags["IncirlikWarehouse"] then return false end
	if bc:getZoneByName('Incirlik').side ~= 1 or not bc:getZoneByName('Incirlik Defence').active then return false end
	if bc:getZoneByName('Red Carrier').side ~= 2 and bc:getZoneByName('Hatay').side ~= 2 and bc:getZoneByName('Gecitkale').side ~= 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_INCIRLIK_WAREHOUSE_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_INCIRLIK_WAREHOUSE_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_INCIRLIK_WAREHOUSE_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_INCIRLIK_WAREHOUSE_END"),
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
	if CustomFlags["IncirlikWarehouse"] then return false end
	if bc:getZoneByName('Incirlik').side ~= 1 or not bc:getZoneByName('Incirlik Defence').active then return false end
	if ActiveMission['IncirlikWarehouse'] then return true end
	return false
	end
})

---------------------------------- Destroy DAM ---------------------------------
evc:addEvent({
	id = 'DamFactory',
		action = function()
		local z = zones.dam
		if not z then return end
		RegisterStaticGroup('DamFactories', z, 250, L10N:Get("SYRIA_MISSION_TARGET_DAM_FACTORIES"), 'DamFactories',true)
		ActiveMission['DamFactories'] = true
	end,
	canExecute = function()
		if ActiveMission['DamFactories'] then return false end
		if CustomFlags['DamFactories'] then return false end
		if bc:getZoneByName('Dam').side ~= 1 or bc:getZoneByName('Dam').suspended then return false end
		local abu = bc:getZoneByName('Abu al-Duhur')
		if abu.side ~= 2 or abu.suspended then return false end
		return true
	end,
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_DAM_FACTORIES_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_DAM_FACTORIES_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_DAM_FACTORIES_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_DAM_FACTORIES_END"),
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
		if CustomFlags['DamFactories'] then return false end
		if bc:getZoneByName('Dam').side ~= 1 then return false end
		if ActiveMission['DamFactories'] then return true end
		return false
	end
})

--------------------------------- Refinery --------------------------------
evc:addEvent({
	id = 'RefineryFactory',
		action = function()
		local z = zones.refinery
		if not z then return end
		RegisterStaticGroup('RefineryFactories', z, 500, L10N:Get("SYRIA_MISSION_TARGET_REFINERY_FACTORIES"), 'RefineryFactories')
	end,
	canExecute = function()
		if ActiveMission['RefineryFactories'] then return false end
		if CustomFlags['RefineryFactories'] then return false end
		if bc:getZoneByName('Refinery').side ~= 1 or bc:getZoneByName('Refinery').suspended then return false end
		local abu = bc:getZoneByName('Abu al-Duhur')
		local palmyra = bc:getZoneByName('Palmyra')
		if abu.side ~= 2 and palmyra.side ~= 2  then return false end
		return true
	end,
})


mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_REFINERY_FACTORIES_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_REFINERY_FACTORIES_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_REFINERY_FACTORIES_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_REFINERY_FACTORIES_END"),
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
		if CustomFlags['RefineryFactories'] then return false end
		if bc:getZoneByName('Refinery').side ~= 1 then return false end
		if ActiveMission['RefineryFactories'] then return true end
		return false
	end
})
--------------------------------- SA5Warehouse --------------------------------
evc:addEvent({
	id = 'SA5Warehouse',
	action = function()
		local tgt = sceneryList['SA5Warehouse'][1] or SCENERY:FindByZoneName('SA5Warehouse')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "SA5Warehouse"),30)
			return
		end
		RegisterScoreTarget('SA5Warehouse',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("SYRIA_MISSION_STRIKE_PALMYRA_SA5_TITLE"),p,2,false,false)
			MissionMarks['SA5Warehouse'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['SA5Warehouse'] then return false end
	if CustomFlags["SA5Warehouse"] then return false end
	if bc:getZoneByName('Palmyra').side ~= 1 or bc:getZoneByName('Palmyra').suspended then return false end
	if bc:getZoneByName('SA-5').side ~= 1 or bc:getZoneByName('SA-5').suspended then return false end
	if bc:getZoneByName('Abu al-Duhur').side ~= 2 or bc:getZoneByName('An Nasiriyah').side ~= 2 or bc:getZoneByName('Damascus').side ~= 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_PALMYRA_SA5_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_PALMYRA_SA5_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_PALMYRA_SA5_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_PALMYRA_SA5_END"),
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
		if CustomFlags["SA5Warehouse"] then return false end
		if bc:getZoneByName('Palmyra').side ~= 1 or bc:getZoneByName('SA-5').side ~= 1 then return false end
		if ActiveMission['SA5Warehouse'] then return true end
		return false
	end
})
------------------------------------- David warehouse --------------------------------
evc:addEvent({
	id = 'DavidWarehouse',
	action = function()
		local tgt = sceneryList['DavidWarehouse'][1] or SCENERY:FindByZoneName('DavidWarehouse')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "DavidWarehouse"),30)
			return
		end
		RegisterScoreTarget('DavidWarehouse',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("SYRIA_MISSION_STRIKE_RAMAT_DAVID_WAREHOUSE_TITLE"),p,2,false,false)
			MissionMarks['DavidWarehouse'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['DavidWarehouse'] then return false end
	if CustomFlags["DavidWarehouse"] then return false end
	if bc:getZoneByName('Ramat David').side ~= 1 or bc:getZoneByName('Ramat David').suspended then return false end
	if not bc:getZoneByName('Ramat David Defence').active then return false end
	if bc:getZoneByName('An Nasiriyah').side ~= 2 and bc:getZoneByName('Ben Gurion').side ~= 2 and bc:getZoneByName('Beirut').side ~= 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_RAMAT_DAVID_WAREHOUSE_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_RAMAT_DAVID_WAREHOUSE_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_RAMAT_DAVID_WAREHOUSE_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_RAMAT_DAVID_WAREHOUSE_END"),
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
		if CustomFlags["DavidWarehouse"] then return false end
		if bc:getZoneByName('Ramat David').side ~= 1 or not bc:getZoneByName('Ramat David Defence').active then return false end
		if ActiveMission['DavidWarehouse'] then return true end
		return false
	end
})
------------------------------------- AssadWarehouse warehouse --------------------------------
evc:addEvent({
	id = 'AssadWarehouse',
	action = function()
		local tgt = sceneryList['AssadWarehouse'][1] or SCENERY:FindByZoneName('AssadWarehouse')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "AssadWarehouse"),30)
			return
		end
		RegisterScoreTarget('AssadWarehouse',tgt,500,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),true)
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("SYRIA_MISSION_STRIKE_BASSEL_WAREHOUSE_MARK"),p,2,false,false)
			MissionMarks['AssadWarehouse'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['AssadWarehouse'] then return false end
	if CustomFlags["AssadWarehouse"] then return false end
	if bc:getZoneByName('Bassel Al-Assad').side ~= 1 or bc:getZoneByName('Hotel').side ~= 1 then return false end
	if bc:getZoneByName('Rene Mouawad').side ~= 2 and bc:getZoneByName('Hatay').side ~= 2 and bc:getZoneByName('Gecitkale').side ~= 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_BASSEL_WAREHOUSE_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_BASSEL_WAREHOUSE_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_BASSEL_WAREHOUSE_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_BASSEL_WAREHOUSE_END"),
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
		if CustomFlags["AssadWarehouse"] then return false end
		if bc:getZoneByName('Bassel Al-Assad').side ~= 1 or not bc:getZoneByName('Hotel').active then return false end
		if ActiveMission['AssadWarehouse'] then return true end
		return false
	end
})
-------------------------------- Strike the rebels --------------------------------


Group.getByName('StrikeTargetGroup'):destroy()
evc:addEvent({
	id='StrikeTarget',
	action = function()
	RespawnGroup('StrikeTargetGroup')
	RegisterGroupTarget('StrikeTargetGroup',250,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),'StrikeTarget',true)
	end,
	canExecute = function()
		if ActiveMission['StrikeTarget'] then return false end
		if CustomFlags["StrikeTarget"] then return false end
		if Group.getByName('StrikeTargetGroup') then return false end
		local gecitkale =  bc:getZoneByName('Gecitkale')
		local hatay =  bc:getZoneByName('Hatay')
		local bassel =  bc:getZoneByName('Bassel Al-Assad')
		if gecitkale.side ~= 2 or hatay.side ~= 2 or bassel.side ~= 2 then return false end
	return true
end
})
mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_REBELES_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_REBELES_ADANA_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_REBELES_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_REBELES_END_REWARD"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["StrikeTarget"] then return false end
	if not ActiveMission['StrikeTarget'] then return false end
	if Group.getByName('StrikeTargetGroup') then return true end
	ActiveMission['StrikeTarget'] = nil
	return false
	end,
})

Group.getByName('StrikeTargetGroup1'):destroy()
evc:addEvent({
	id='StrikeTarget1',
	action = function()
	RespawnGroup('StrikeTargetGroup1')
	RegisterGroupTarget('StrikeTargetGroup1',250,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),'StrikeTarget1',true)
	end,
	canExecute = function()
		if ActiveMission['StrikeTarget1'] then return false end
		if math.random(1,100) < 70 then return false end
		if Group.getByName('StrikeTargetGroup1') then return false end
		if CustomFlags["StrikeTarget1"] then return false end
		if bc:getZoneByName('Hatay').side ~= 2 or bc:getZoneByName('Abu al-Duhur').side ~= 2 then return false end	
		return true
	end
})
mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_REBELES_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_REBELES_ALEPPO_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_REBELES_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_REBELES_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["StrikeTarget1"] then return false end
	if not ActiveMission['StrikeTarget1'] then return false end
	if Group.getByName('StrikeTargetGroup1') then return true end
	ActiveMission['StrikeTarget1'] = nil
	return false
	end,
})

Group.getByName('StrikeTargetGroup2'):destroy()
Group.getByName('StrikeTargetGroup3'):destroy()
Group.getByName('Red SAM SA-3 Fixed Event'):destroy()
evc:addEvent({
	id='StrikeTarget2',
	action = function()
		RespawnGroup('StrikeTargetGroup2')
		RespawnGroup('StrikeTargetGroup3')
		RegisterGroupTarget('StrikeTargetGroup2',750,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),'StrikeTarget2',true)
	end,
	canExecute = function()
		if CustomFlags["StrikeTarget2"] then return false end
		if ActiveMission['StrikeTarget2'] then return false end
		if bc:getZoneByName('Abu al-Duhur').side ~= 2 or bc:getZoneByName('Rene Mouawad').side ~= 2 or bc:getZoneByName('Shayrat').side ~= 2 then return false end
		if Group.getByName('StrikeTargetGroup2') then return false end
		
		return true
	end
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_STRIKE_GENERAL_TITLE"),
	description = LTGet("SYRIA_MISSION_STRIKE_GENERAL_DESC"),
	messageStart = LTGet("SYRIA_MISSION_STRIKE_GENERAL_START"),
	messageEnd = LTGet("SYRIA_MISSION_STRIKE_GENERAL_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
		RespawnGroup('Red SAM SA-3 Fixed Event')
	end,
	isActive = function()
		if CustomFlags["StrikeTarget2"] then return false end
		if not ActiveMission['StrikeTarget2'] then return false end
		if Group.getByName('StrikeTargetGroup2') then return true end
		ActiveMission['StrikeTarget2'] = nil
		return false
	end
})

-------------------------------- Destroy EWR --------------------------------
evc:addEvent({
	id='EWRSouth',
	action = function()
		RegisterGroupTarget('Red EWR-south Fixed',1000,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),'EWRSouth',true)
	end,
	canExecute = function()
		if CustomFlags["EWRSouth"] then return false end
		if ActiveMission['EWRSouth'] then return false end
		if not Group.getByName('Red EWR-south Fixed') then return false end 
		if bc:getZoneByName('Beirut').side ~= 2 then return false end
		if bc:getZoneByName('Ben Gurion').side ~= 1 then return false end

		return true
	end
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_DEEP_STRIKE_EWR_TITLE"),
	description = LTGet("SYRIA_MISSION_DEEP_STRIKE_EWR_SOUTH_DESC"),
	messageStart = LTGet("SYRIA_MISSION_BEHIND_LINES_START"),
	messageEnd = LTGet("SYRIA_MISSION_BEHIND_LINES_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
		if CustomFlags["EWRSouth"] then return false end
		if bc:getZoneByName('Beirut').side ~= 2 then return false end
		if ActiveMission['EWRSouth'] then return true end
		return false
	end
})

-------------------------------- Destroy EWR 2 --------------------------------
evc:addEvent({
	id='EWRSA5',
	action = function()
		RegisterGroupTarget('Red EWR-southeast Fixed',1000,L10N:Get("SYRIA_MISSION_TARGET_STRIKE_MISSION"),'EWRSA5',true)
	end,
	canExecute = function()
		if CustomFlags["EWRSA5"] then return false end
		if ActiveMission['EWRSA5'] then return false end
		if not Group.getByName('Red EWR-southeast Fixed') then return false end 
		if bc:getZoneByName('Abu al-Duhur').side ~= 2 and bc:getZoneByName('Hama').side ~= 2 then return false end
		if bc:getZoneByName('SA-5').side ~= 1 then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_DEEP_STRIKE_EWR_TITLE"),
	description = LTGet("SYRIA_MISSION_DEEP_STRIKE_EWR_SA5_DESC"),
	messageStart = LTGet("SYRIA_MISSION_BEHIND_LINES_START"),
	messageEnd = LTGet("SYRIA_MISSION_BEHIND_LINES_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
		if CustomFlags["EWRSA5"] then return false end
		if bc:getZoneByName('Abu al-Duhur').side ~= 2 and bc:getZoneByName('Hama').side ~= 2 then return false end
		if bc:getZoneByName('SA-5').side ~= 1 then return false end
		if ActiveMission['EWRSA5'] then return true end
		return false
	end
})
-------------------------------- Destroy artillery --------------------------------

mc:trackMission({
    title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
    description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Aleppo", "Jirah"),
    messageStart = LTGet("SYRIA_MISSION_ARTY_START"),
    messageEnd = LTGet("SYRIA_MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Jirah-attack-Aleppo-surface',100,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'Jirah-attack-Aleppo-surface')
    end,
    endAction = function()
    end,
    isActive = function()
		if not ActiveMission['Jirah-attack-Aleppo-surface'] then return false end
		if Group.getByName('Jirah-attack-Aleppo-surface') then return true end
		ActiveMission['Jirah-attack-Aleppo-surface'] = nil
		return false
    end
})

mc:trackMission({
    title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
    description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Durayhim", "Jirah"),
    messageStart = LTGet("SYRIA_MISSION_ARTY_START"),
    messageEnd = LTGet("SYRIA_MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Jirah-attack-Durayhim',100,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'Jirah-attack-Durayhim')
    end,
    endAction = function()
    end,
    isActive = function()
		if not ActiveMission['Jirah-attack-Durayhim'] then return false end
		if Group.getByName('Jirah-attack-Durayhim') then return true end
		ActiveMission['Jirah-attack-Durayhim'] = nil
		return false
    end
})

mc:trackMission({
    title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
    description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Abu al-Duhur", "November"),
    messageStart = LTGet("SYRIA_MISSION_ARTY_START"),
    messageEnd = LTGet("SYRIA_MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('November-attack-Duhur',100,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'November-attack-Duhur')
    end,
    endAction = function()
    end,
    isActive = function()
		if not ActiveMission['November-attack-Duhur'] then return false end
		if Group.getByName('November-attack-Duhur') then return true end
		ActiveMission['November-attack-Duhur'] = nil
		return false
    end
})

mc:trackMission({
    title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
    description = LTFormat("SYRIA_MISSION_ARTY_DESC", "India", "November"),
    messageStart = LTGet("SYRIA_MISSION_ARTY_START"),
    messageEnd = LTGet("SYRIA_MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('November-attack-India',100,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'November-attack-India')
    end,
    endAction = function()
    end,
    isActive = function()
		if not ActiveMission['November-attack-India'] then return false end
		if Group.getByName('November-attack-India') then return true end
		ActiveMission['November-attack-India'] = nil
		return false
    end
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_ARTY_TITLE"),
	description = LTFormat("SYRIA_MISSION_ARTY_DESC", "Hama", "November"),
	messageStart = LTGet("SYRIA_MISSION_ARTY_START"),
	messageEnd = LTGet("SYRIA_MISSION_ARTY_END"),
	startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('November-attack-Hama',100,L10N:Get("SYRIA_MISSION_ARTY_TITLE"),'November-attack-Hama')
    end,
    endAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
    end,
	isActive = function()
		if not ActiveMission['November-attack-Hama'] then return false end
		if Group.getByName('November-attack-Hama') then return true end
		ActiveMission['November-attack-Hama'] = nil
		return false
	end
})

------------------------------------ End of custom missions --------------------------------
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


seadTarget = nil
function generateSEADMission()
    if seadTarget then return true end
    local attackAnchors = _getAttackAnchorZones()
    if #attackAnchors == 0 then return false end

    local function isSEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and not zone.suspended and (lname:find('sam') or lname:find('defence')
		or lname:find('papa') or lname:find('juliett') or lname:find('india') or lname:find('delta')
		or lname:find('bravo') or lname:find('hotel')) and (not isZoneUnderSEADMission or not isZoneUnderSEADMission(zone.zone))
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

            if from and to and from.side ~= to.side and from.side ~= 0 and to.side ~= 0 and
			((not to.suspended) or from.suspended) then
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

    seadTarget = validSEADZones[math.random(#validSEADZones)]
    return true
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
        return zone.side == 1 and zone.active and not zone.suspended and (lname:find('sam') or lname:find('defence')
		or lname:find('papa') or lname:find('juliett') or lname:find('india') or lname:find('delta')
		or lname:find('bravo') or lname:find('hotel'))
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

function generateCaptureMission()
    if captureTarget ~= nil then return true end
    
    local validzones = {}
    for _, v in ipairs(bc.zones) do
        local lname = v.zone:lower()
        if v.active and v.side == 0 and not v.NeutralAtStart and
           not lname:find("hidden", 1, true) and not lname:find("red carrier", 1, true) then
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
    title = function(T) return LT(T):Get("MISSION_CAP_TITLE") end,
    description = function(T)
		local Tr = LT(T)
        if not next(capKillsByPlayer) then
            return Tr:Format("MISSION_CAP_DESCRIPTION_EMPTY", capTargetPlanes)
        else
            local scoreboard = Tr:Get("MISSION_CAP_SCOREBOARD_HEADER")
            for playerName, kills in pairs(capKillsByPlayer) do
                scoreboard = scoreboard .. string.format("%s: %d\n", playerName, kills)
            end
            return Tr:Format("MISSION_CAP_DESCRIPTION_WITH_SCORE", capTargetPlanes, scoreboard)
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
		local Tr = LT(T)
		if not next(casKillsByPlayer) then
			return Tr:Format("MISSION_CAS_DESCRIPTION_EMPTY", casTargetKills)
		else
			local scoreboard = Tr:Get("MISSION_CAP_SCOREBOARD_HEADER")
			for playerName, kills in pairs(casKillsByPlayer) do
				scoreboard = scoreboard..string.format('%s: %d\n', playerName, kills)
			end
			return Tr:Format("MISSION_CAS_DESCRIPTION_WITH_SCORE", casTargetKills, scoreboard)
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
--                         RECON MISSION                           --
reconMissionTarget = nil
reconMissionWinner = nil
reconMissionCooldownUntil = 0
reconMissionCompleted = false
reconMissionCompletedTarget = nil

mc:trackMission({
	title = function(T)
		local Tr = LT(T)
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return Tr:Get("SYRIA_DYNAMIC_RECON_TITLE_EMPTY") end
		local wp = WaypointList[target] or ""
		return Tr:Format("SYRIA_DYNAMIC_RECON_TITLE", target, wp)
	end,
	description = function(T)
		local Tr = LT(T)
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return Tr:Get("SYRIA_DYNAMIC_RECON_DESC_EMPTY") end
		return Tr:Format("SYRIA_DYNAMIC_RECON_DESC", target)
	end,
	messageStart = function(T)
		local Tr = LT(T)
		local target = reconMissionCompletedTarget or reconMissionTarget
		if not target then return Tr:Get("SYRIA_DYNAMIC_RECON_START_EMPTY") end
		local wp = WaypointList[target] or ""
		return Tr:Format("SYRIA_DYNAMIC_RECON_START", target, wp)
	end,
	messageEnd = function(T)
		local Tr = LT(T)
		if reconMissionCompleted and reconMissionCompletedTarget and reconMissionWinner then
			return Tr:Format("SYRIA_DYNAMIC_RECON_END_BY", reconMissionCompletedTarget, reconMissionWinner)
		end
		if reconMissionCompletedTarget then
			return Tr:Format("SYRIA_DYNAMIC_RECON_END_TARGET", reconMissionCompletedTarget)
		end
		return Tr:Get("SYRIA_DYNAMIC_RECON_END")
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

---------------------------------------------------------------------
--                     		ESCORT MISSION                         --

function generateEscortMission(zoneName, groupName, groupID, group, mission)
    local mission = mission or missions[zoneName]
    if not mission then return false end
	local T = L10N:ForGroup(groupID)

    missionGroupIDs[zoneName] = missionGroupIDs[zoneName] or {}
    missionGroupIDs[zoneName][groupID] = {
        groupID = groupID,
        group = group
    }
	if IsGroupActive(mission.missionGroup) then
		trigger.action.outSoundForGroup(groupID, "ding.ogg")
		trigger.action.outTextForGroup(groupID, T:Format("SYRIA_ESCORT_ACTIVE_PENDING", mission.zone, mission.TargetZone), 30)
        return
    end
	if mc.missionFlags[zoneName] then
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, T:Format("SYRIA_ESCORT_SPECIAL_AVAILABLE", mission.zone, mission.TargetZone), 30)
		return
	end

    mc:trackMission({
        MainTitle = function(T) return LT(T):Get("MISSION_ESCORT_TITLE") end,
        title = function(T) return LT(T):Get("MISSION_ESCORT_TITLE") end,
		titleBefore = function(self)
			self.notified = true
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, T:Format("SYRIA_ESCORT_SPECIAL_AVAILABLE", mission.zone, mission.TargetZone), 30)
		 end,
        description = function(T) return LT(T):Format("SYRIA_ESCORT_DESC", mission.TargetZone) end,
        isEscortMission = true,
        accept = false,
        missionGroup = mission.missionGroup,
        zoneName = zoneName,
        messageStart = function(T) return LT(T):Format("SYRIA_ESCORT_START", mission.TargetZone) end,
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
					return Tr:Format("SYRIA_BOMB_RUNWAY_END_JOINT", runwayTargetZone, bomberName, runwayPartnerName, cred)
				elseif bomberName then
					return Tr:Format("SYRIA_BOMB_RUNWAY_END_SOLO", runwayTargetZone, bomberName, cred)
				else
					return Tr:Format("SYRIA_BOMB_RUNWAY_END_COMPLETED", runwayTargetZone)
				end
			else
				return Tr:Format("SYRIA_BOMB_RUNWAY_END_CANCELED_ZONE", runwayTargetZone)
			end
		else
			return Tr:Get("SYRIA_BOMB_RUNWAY_CANCELED")
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
				not lname:find('hidden') and not lname:find('sam') and not lname:find('defence') and
				not lname:find('papa') and not lname:find('juliett') and not lname:find('india') and
				not lname:find('delta') and not lname:find('bravo') and not lname:find('hotel')
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

--configure zone messages 


airbaseStatics = {
    ["FOB HOTEL"] = {"FarpHotelammo", "Farphotelfuel", "Farphoteltent1", "Farphoteltent2", "Farphoteltent3", "Farphoteltent4", "Farphotelcommand", "Farphotelwind"},
    ["FOB LIMA"] = {"Farplimaammo", "Farplimafuel", "Farplimatent1", "Farplimatent2", "Farplimatent3", "Farplimatent4", "Farplimatent5", "Farplimatent6", "Farplimatent7", "Farplimacommand", "Farplimawind"},
    ["FOB DURAYHIM"] = {"Durayhimammo", "Durayhimfuel", "Durayhimtent1", "Durayhimtent2", "Durayhimtent3", "Durayhimtent4", "Durayhimcommand", "Durayhimwind"},
    ["FOB INDIA"] = {"Fobindiaammo", "Fobindiafuel", "Fobindiatent1", "Fobindiatent2", "Fobindiatent3", "Fobindiatent4", "Fobindiacommand", "Fobindiawind"},
    ["FOB MIKE"] = {"FobMikeAmmo", "FobMikeFuel", "FobMiketent1", "FobMiketent2", "FobMiketent3", "FobMiketent4", "FobMiketent5", "FobMiketent6", "FobMiketent7", 
	"FobMiketent8", "FobMiketent9", "FobMikeTower1", "FobMikeTower2", "FobMikeTower3", "FobMikeTower4", "FobMikeHelo1", "FobMikeHelo2", "FobMikeHelo3", "FobMikeHelo4", 
	"FobMikeWind", "FobMikeGenerator"},
	["FOB Military Base"] = {"Millbaseammo", "Millbasefuel", "Millbasetent1", "Millbasetent2", "Millbasetent3", "Millbasetent4", "Millbasetentcommand", "Millbasetentwind"},
	["FOB POLIS"] = {"fobtowerammo", "fobtowerfuel", "fobtowertent1", "fobtowertent2", "fobtowertent3", "fobtowertent4", "fobtowercommand", "fobtowerwind"},
	["FOB FOXTROT"] = {"fobfoxtrotammo", "fobfoxtrotfuel", "fobfoxtrottent1", "fobfoxtrottent2", "fobfoxtrottent3", "fobfoxtrottent4", "fobfoxtrotcommand", "fobfoxtrotwind"},
	["FOB JULIETT"] = {"fobjuliettammo", "fobjuliettfuel", "fobjulietttent1", "fobjulietttent2", "fobjulietttent3", "fobjulietttent4", "fobjuliettcommand", "fobjuliettwind"},
	["FOB KARAVOSTASI"] = {"FOBKARAVOSTASIAmmo", "FOBKARAVOSTASIFuel", "FOBKARAVOSTASItent1", "FOBKARAVOSTASItent2", "FOBKARAVOSTASItent3", "FOBKARAVOSTASItent4", "FOBKARAVOSTAScommand", "FOBKARAVOSTASWind"},
	
}


env.info("Mission Setup : is completed!")


