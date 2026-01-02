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
	ships = {
		blue = {'blueShip', 'blueShip', 'blueShip'},
		red = {'Molniya','Molniya','Rezky','Rezky','Neustrashimy','Neustrashimy'}
	},
	ships2 = {
		blue = {'blueShip'},
		red = {'Molniya','Molniya','Rezky','Rezky','Moskva'}
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
		red = {'redInfantry', 'Red SAM Dog Ear SA-8', 'Red SAM SHORAD SA-8 2' , 'Red SAM AAA', 'Red Armor Group3', 'Red SAM Dog Ear SA-15', 'Red SAM Dog Ear SA-15','Red Armor Group5','Red Arty 2'}
	},
	airfield2palmyra = {
		blue = {'blueInfantry','bluePD2', 'bluePD1'},
		red = {'redInfantry','Red SAM Dog Ear SA-8', 'Red SAM SHORAD SA-8 2' , 'Red SAM AAA','Red Armor Group3', 'Red SAM Dog Ear AAA 2', 'Red SAM Dog Ear SA-19', 'Red SAM SHORAD SA-19 2' , 'Red SAM SA-11'}
	},  
	
	airfield2 = {
		blue = {'blueInfantry','bluePD2', 'bluePD1'},
		red = {'redInfantry','Red Armor Group', 'Red SAM Dog Ear SA-8', 'Red SAM Dog Ear Tor M2' ,'Red SAM AAA', 'Red SAM Dog Ear AAA 2', 'Red SAM Dog Ear SA-19', 'Red SAM SHORAD SA-19 2','Red Armor Group3', 'Red Arty 2'}
	},  

	Incirlik = {
		blue = {'blueInfantry','bluePD2', 'bluePD1'},
		red = {'redInfantry','Red Armor Group', 'Red SAM Dog Ear SA-8', 'Red SAM Dog Ear Tor M2' ,'Red SAM AAA', 'Red SAM Dog Ear AAA 2', 'Red SAM Dog Ear SA-19', 'Red SAM SHORAD Pantsir S1','Red Armor Group3', 'Red Arty 2'}
	}, 

	airfield3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'bluePD1'},
		red = {'redInfantry','Red SAM AAA', 'Red SAM Dog Ear AAA 2', 'Red SAM SHORAD Pantsir S1', 'Red SAM Dog Ear Tor M2' , 'Red SAM Dog Ear SA-19', 'Red SAM SHORAD SA-19 2' , 'Red SAM SA-6 Fixed Duhur','Red Armor Group5','Red Armor Group4', 'Red Arty 2'}
	},							 
   	generic = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'redInfantry','Red Armor Group2','Red Armor Group3', 'Red SAM Dog Ear SA-8', 'Red SAM SHORAD SA-8 2','Red SAM Dog Ear AAA 2' }
	},
	deltafixed = {
		blue = {'bluePD2', 'blueHAWK'},
		red = { 'Red Armor Group2', 'Red SAM SA-6 Fixed Delta','Red Armor Group3', 'Red SAM SHORAD SA-19 Fixed delta', 'Red SAM SHORAD SA-8 Fixed delta','Red SAM SHORAD Pantsir S1 Fixed delta'}
	},
	bravofixed = {
		blue = {'bluePD2', 'blueHAWK'},
		red = { 'Red Armor Group2','Red SAM SHORAD Tor M2 Fixed Bravo','Red Armor Group3', 'Red SAM SHORAD SA-19 Fixed Bravo-3','Red SAM SHORAD SA-8 Fixed Bravo','Red SAM SA-3 Fixed Bravo'}
	},
	juliettFixed = {
		blue = {'bluePD2', 'blueHAWK', 'bluePD1', 'blueArmor'},
		red = {'Red SAM AAA Fixed juliett-1', 'Red SAM SHORAD SA-15 Fixed juliett-2', 'Red SAM AAA Fixed juliett-2', 'Red SAM SA-2 Fixed juliett', 'Red SAM SHORAD SA-8 Fixed-juliett'}
	},
	indiaFixed = {
		blue = {'bluePD2', 'blueHAWK', 'bluePD1'},
		red = {'Red SAM AAA Fixed india-1','Red SAM AAA Fixed india-3','Red SAM SHORAD SA-15 Fixed india-2','Red SAM SHORAD Tor M2 Fixed india-3','Red SAM SA-2 Fixed India'}
	},
	HotelFixed = {
		blue = {'bluePD2', 'blueHAWK', 'bluePD1'},
		red = {'Red SAM SHORAD SA-19 Fixed Hotel', 'Red SAM SA-2 Fixed Hotel', 'Red SAM SHORAD SA-15 Fixed Hotel', 'Red SAM AAA Fixed Hotel'}
	},
	sa5 = {
		blue = {'bluePD2', 'bluePD1'},
		red = {'Red Armor Group2','Red SAM AAA Fixed SAITE','Red SAM SHORAD SA-15 SAITE Fixed','Red Armor Group3','Red SAM SHORAD Tor M2 Fixed SAITE','Red SAM SA-5 Fixed'}
	},
	insAirfield = {
		blue = {'blueInfantry','bluePD2', 'bluePD1'},
		red = {'insInfantry','Red Armor Group2','Red SAM AAA', 'Red SAM Dog Ear AAA 2','Red SAM Dog Ear SA-15','Red Armor Group3', 'Red SAM AAA 2', 'Red Arty 2' }
	},
	insGeneric = {
		blue = {'blueInfantry','bluePD2', 'blueArmor'},
		red = {'insInfantry','Red Armor Group2','Red SAM AAA', 'Red SAM Dog Ear AAA 2','Red Armor Group3','Red SAM Dog Ear SA-19', 'Red SAM SHORAD SA-19 2' }
	},
	damupgrade = {
		blue = {'blueInfantry','bluePD2', 'blueArmor'},
		red = {'insInfantry','Red Armor Group4','Red SAM AAA 3', 'Red SAM AAA 4','Red Armor Group5','Red SAM Dog Ear Tor M2', 'Red SAM SHORAD SA-19 2' }
	},
	insGenericFoxtrotFixed = {
		blue = {'blueInfantry','bluePD2', 'blueArmor'},
		red = {'insInfantry','Red Armor Group2','insInfantry','Red SAM Dog Ear AAA 2','Red SAM SHORAD SA-8 Fixed Foxtrot'}
	},
	insMaximum = {
		blue = {'blueInfantry'},
		red = {'insInfantry','Red SAM AAA', 'Red SAM Dog Ear AAA 2', 'insInfantry','Red Armor Group2','Red SAM Dog Ear SA-19', 'Red SAM SHORAD SA-19 2' ,'Red Armor Group3','Red SAM Dog Ear SA-15', 'Red SAM SHORAD SA-15 2'}
	},
	insMinimum = {
		blue = {'blueInfantry','bluePD2'},
		red = {'insInfantry','Red SAM AAA', 'Red SAM Dog Ear AAA 2','Red SAM Dog Ear SA-19', 'Red SAM SHORAD SA-19 2' }
	},
	insSAM = {
		blue = {'bluePD2', 'blueHAWK', 'bluePD1'},
		red = {'Red SAM AAA', 'Red SAM Dog Ear AAA 2', 'Red Armor Group2', 'Red SAM Dog Ear SA-19', 'Red SAM SHORAD SA-19 2' ,'Red SAM Dog Ear SA-15', 'Red SAM SHORAD SA-15 2'}
	},
	ewr = {
		blue = {'blueInfantry'},
		red = {'Red EWR','Red SAM Dog Ear SA-8', 'Red SAM SHORAD SA-8 2' }
	},
	ewrcharlie = {
		blue = {'blueInfantry'},
		red = {'Red EWR','Red SAM SHORAD SA-8 Fixed Charlie','Red SAM SHORAD SA-15 Fixed Charlie'}
	},
	milbase = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'redInfantry','Red Armor Group2', 'Red SAM Dog Ear Tor M2', 'Red SAM SHORAD Pantsir S1' ,'Red SAM AAA','Red Armor Group3'}
	},
	milbase2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'redInfantry', 'Red SAM AAA', 'Red SAM Dog Ear AAA 2', 'Red SAM Dog Ear SA-8','Red Armor Group3', 'Red SAM AAA 3' ,'Red Armor Group3','Red SAM AAA 4'}
	},
	bigSAM = {
		blue = {'blueAmmo', 'blueAmmo', 'blueAmmo', 'bluePATRIOT'},
		red = {'redAmmo','redAmmo', 'Red SAM SA-11'}
	},
	PapaFixed = {
		blue = {'blueAmmo', 'blueAmmo', 'blueAmmo', 'blueAmmo', 'blueAmmo', 'blueAmmo', 'bluePD1', 'blueHAWK'},
		red = {'Red SAM AAA Fixed Papa', 'Red SAM SHORAD SA-15 Fixed Papa-2', 'Red SAM SHORAD SA-15 Fixed Papa-3', 'Red SAM SA-11 Fixed Papa'}
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
		red = {'redInfantry'}
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
		red = {'Red SAM SHORAD SA-15 Fixed ramatdaviddefence','Red SAM SHORAD SA-19 Fixed ramatdaviddefence','Red SAM AAA Fixed ramatdaviddefence','Red SAM SA-11 Fixed ramatdaviddefence'}
	},
	jordanDefence = {
		blue = {},
		red = {'Red SAM SA-2 Fixed Jordandefence', 'Red SAM SA-2 Fixed Jordandefence-1', 'Red SAM SA-2 Fixed Jordandefence-2', 'Red SAM SHORAD SA-19 jordandefence Fixed', 
		'Red SAM AAA jordandefence Fixed', 'Red SAM SHORAD SA-15 jordandefence Fixed'}
	},

	incirlikdefence = {
		blue = {},
		red = {'Red Armor Group5','Red SAM SA-11 Fixed Incirlikdefence','Red SAM SHORAD SA-19 Fixed','Red SAM SHORAD SA-15 Fixed incirlikdefence'}
	},

	hidden1Group = {
		blue = {},
		red = {'Red EWR north Fixed', 'Red EWR Cyprus Fixed', 'Red EWR-southeast Fixed', 'Red EWR-south Fixed', 'HQ Fixed', 
		'Red SAM SHORAD SA-15 Fixed HiddenGroup South', 'Red SAM SHORAD SA-15 EWR Group Fixed'}
	},
	hidden2Group = {
		blue = {},
		red = {'HiddenGroup-Fixed-1', 'HiddenGroup-Fixed-2', 'Red SAM SA-3 HiddenGroup Fixed', 'HiddenGroup-Fixed-3'}
	},
	hidden3Group = {
		blue = {},
		red = {'Red EWR north Fixed Coldwar', 'Red EWR Cyprus Fixed Coldwar', 'Red EWR-southeast Fixed Coldwar', 'Red EWR-south Fixed Coldwar', 'HQ Fixed', 
		'Red SAM SHORAD SA-15 Fixed HiddenGroup South', 'Red SAM SHORAD SA-15 EWR Group Fixed'}
	}

}


local cwSwap = {
	['Red Armor Group2']  = 'Red Armor Group6',
	['Red Armor Group3']  = 'Red Armor Group7',
	['Red Armor Group4']  = 'Red Armor Group8',
	['Red Armor Group5']  = 'Red Armor Group9',
	['Neustrashimy']  = 'Molniya',
	['bluePD2']  = 'bluePD2 Coldwar',
	['bluePD1']  = 'bluePD1 Coldwar',
	['blueArmor']  = 'blueArmor_Cw',
	['blueHAWK']  = 'blueHAWK_CW',
	['Red SAM Dog Ear Tor M2']  = 'Red SAM SHORAD SA-8 2',
	['Red SAM Shorad Pantsir S1']  = 'Red SAM SHORAD SA-8 2',
	['Red SAM SHORAD Pantsir S1 Fixed delta']             = 'Red SAM SHORAD SA-8 Fixed delta-2',
	['Red SAM SHORAD Tor M2 Fixed Bravo']                 = 'Red SAM SHORAD SA-19 Fixed Bravo',
	['Red SAM SHORAD SA-15 Fixed juliett-2']              = 'Red SAM SHORAD SA-8 Fixed juliett-2',
	['Red SAM SHORAD SA-15 Fixed-juliett-3']              = 'Red SAM SHORAD SA-8 Fixed-juliett',
	['Red SAM SHORAD SA-15 Fixed india-2']                = 'Red SAM SHORAD SA-8 Fixed india-2',
	['Red SAM SHORAD Tor M2 Fixed india-3']               = 'Red SAM SHORAD SA-19 Fixed india-3',
	['Red SAM SHORAD SA-15 Fixed Hotel']                  = 'Red SAM SHORAD SA-8 Fixed Hotel',
	['Red SAM SHORAD SA-15 SAITE Fixed']                  = 'Red SAM SHORAD SA-8 SAITE Fixed',
	['Red SAM SHORAD Tor M2 Fixed SAITE']                 = 'Red SAM SHORAD SA-19 Fixed SAITE',
	['Red SAM SHORAD SA-15 Fixed Charlie']                = 'Red SAM SHORAD SA-8 Fixed Charlie 2',
	['Red SAM SHORAD SA-15 Fixed Papa-2']                 = 'Red SAM SHORAD SA-8 Fixed Papa-2',
	['Red SAM SHORAD SA-15 Fixed Papa-3']                 = 'Red SAM SHORAD SA-8 Fixed Papa-3',
	['Red SAM SHORAD SA-15 Fixed']                        	= 'Red SAM SHORAD SA-8 Fixed',
	['Red SAM SHORAD SA-15 Fixed ramatdaviddefence']     	= 'Red SAM SHORAD SA-8 Fixed ramatdaviddefence',
	['Red SAM SHORAD SA-15 jordandefence Fixed']          	= 'Red SAM SHORAD SA-8 jordandefence Fixed',
	['Red SAM SHORAD SA-15 Fixed HiddenGroup South']      	= 'Red SAM SHORAD SA-8 Fixed HiddenGroup South',
	['Red SAM SHORAD SA-15 EWR Group Fixed']              	= 'Red SAM SHORAD SA-8 EWR Group Fixed',
	['Red SAM SHORAD SA-15 Fixed BenGurion']              	= 'Red SAM SHORAD SA-8 Fixed BenGurion',

}

local function deepSwap(t,s)
	for k,v in pairs(t) do
		if type(v)=='table' then
			deepSwap(v,s)
		elseif s[v] then
			t[k]=s[v]
		end
	end
end

if Era == 'Coldwar' then
	deepSwap(upgrades,cwSwap)
end


local SamSwap = {
	['Red SAM SHORAD Pantsir S1 Fixed delta']             = 'Red SAM SHORAD SA-8 Fixed delta-2',
	['Red SAM SHORAD Tor M2 Fixed Bravo']                 = 'Red SAM SHORAD SA-19 Fixed Bravo',
	['Red SAM SHORAD SA-15 Fixed juliett-2']              = 'Red SAM SHORAD SA-8 Fixed juliett-2',
	['Red SAM SHORAD SA-15 Fixed-juliett-3']              = 'Red SAM SHORAD SA-8 Fixed-juliett',
	['Red SAM SHORAD SA-15 Fixed india-2']                = 'Red SAM SHORAD SA-8 Fixed india-2',
	['Red SAM SHORAD Tor M2 Fixed india-3']               = 'Red SAM SHORAD SA-19 Fixed india-3',
	['Red SAM SHORAD SA-15 Fixed Hotel']                  = 'Red SAM SHORAD SA-8 Fixed Hotel',
	['Red SAM SHORAD SA-15 SAITE Fixed']                  = 'Red SAM SHORAD SA-8 SAITE Fixed',
	['Red SAM SHORAD Tor M2 Fixed SAITE']                 = 'Red SAM SHORAD SA-19 Fixed SAITE',
	['Red SAM SHORAD SA-15 Fixed Charlie']                = 'Red SAM SHORAD SA-8 Fixed Charlie 2',
	['Red SAM SHORAD SA-15 Fixed Papa-2']                 = 'Red SAM SHORAD SA-8 Fixed Papa-2',
	['Red SAM SHORAD SA-15 Fixed Papa-3']                 = 'Red SAM SHORAD SA-8 Fixed Papa-3',
	['Red SAM SHORAD SA-15 Fixed']                        	= 'Red SAM SHORAD SA-8 Fixed',
	['Red SAM SHORAD SA-15 Fixed ramatdaviddefence']     	= 'Red SAM SHORAD SA-8 Fixed ramatdaviddefence',
	['Red SAM SHORAD SA-15 jordandefence Fixed']          	= 'Red SAM SHORAD SA-8 jordandefence Fixed',
	['Red SAM SHORAD SA-15 Fixed HiddenGroup South']      	= 'Red SAM SHORAD SA-8 Fixed HiddenGroup South',
	['Red SAM SHORAD SA-15 EWR Group Fixed']              	= 'Red SAM SHORAD SA-8 EWR Group Fixed',
	['Red SAM SHORAD SA-15 Fixed BenGurion']              	= 'Red SAM SHORAD SA-8 Fixed BenGurion',
	['Red SAM Dog Ear Tor M2']  							= 'Red SAM SHORAD SA-8 2',
	['Red SAM Shorad Pantsir S1']  							= 'Red SAM SHORAD SA-8 2',
    ['Red SAM SA-11 Fixed Papa']              				= 'Red SAM SA-3 Papa Fixed','Red SAM SA-6 Papa Fixed',
    ['Red SAM SA-11 Fixed ramatdaviddefence'] 				= 'Red SAM SA-6 Fixed ramatdaviddefence',
    ['Red SAM SA-11 Fixed Incirlikdefence']   				= 'Red SAM SA-3 Fixed Incirlikdefence',
    ['Red SAM SA-10 Fixed Benguriondefence']  				= 'Red SAM SA-2 Fixed Benguriondefence',

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



-- redInfantry, Red Armor Group, Red SAM SHORAD SA-8, Red SAM SA-3, Red SAM SHORAD SA-15, redSA5, Red EWR
-- insInfantry, Red Armor Group2, Red SAM SHORAD SA-19
-- blueInfantry, blueArmor, blueRed SAM SHORAD, blueHAWK, bluePATRIOT, bluePD
-- blueShip

flavor = {
    akrotiri = 'WPT 1\nStart zone',
    paphos = 'WPT 2\n',
    polis = 'WPT 3\n',
    karavostasi = 'WPT 4\n',
    pinarbashi = 'WPT 5\n',
    gecitkale = 'WPT 6\n',
    ercan = 'WPT 7\n',
    larnaca = 'WPT 8\n',
    redcarrier = 'WPT 9\n Take out the ship and the silkworm Site and we shall have CVN crusing here.',
    incirlik = 'WPT 10\n',
    alpha = 'WPT 11\n',
    hatay = 'WPT 12\n',
    bravo = 'WPT 13\n',
    charlie = 'WPT 14\nEWR Site, can not be captured, destroy for 500 credits and reduced enemy patrols',
    minakh = 'WPT 15\n',
    gaziantep = 'WPT 16\n',
    manbij = 'WPT 17\n',
    aleppo = 'WPT 18\n',
    delta = 'WPT 19\n',
    taftanaz = 'WPT 20\nProvides Helicopter spawns for players if captured',
    powerplant = 'WPT 21\n+180 credits/hour',
    hotel = 'WPT 22\nSAM site',
    alassad = 'WPT 23\n',
    substationwest = 'WPT 24\nStrike target, can not be captured, destroy for 500 credits',
    victor = 'WPT 25\nCrashed Blackhawk, ambushed by local insurgents, clear for 500 credits',
    alduhur = 'WPT 26\nProvides Plane and Helicopter spawns for players if captured',
    tango = 'WPT 27\nInsurgent outpost, can not be captured, clear for 1000 credits',
    substationnorth = 'WPT 28\nStrike target, can not be captured, destroy for 500 credits',
    jirah = 'WPT 29\nProvides Helicopter spawns for players if captured',
    foxtrot = 'WPT 30\n',
    durayhim = 'WPT 31\n',
    papa = 'WPT 32\nSpawns SA-11 or Patriot at max level',
    factory = 'WPT 33\n+180 credits/hour',
    india = 'WPT 34\nSAM site',
    romeo = 'WPT 35\n',
    hama = 'WPT 36\n',
    foblima = 'WPT 37\nProvides Helicopter spawns for players if captured',
    sierra = 'WPT 38\nStrike target, can not be captured, destroy for 500 credits',
    golf = 'WPT 39\n',
    dam = 'WPT 40\n+180 credits/hour',
    raqqa = 'WPT 41\n',
    tabqa = 'WPT 42\n',
    tv = 'WPT 43\nStrike target, can not be captured, destroy for 500 credits',
    juliett = 'WPT 44\nSAM site',
    november = 'WPT 45\n',
    radio = 'WPT 46\nStrike target, can not be captured, destroy for 500 credits',
    kilo = 'WPT 47\nEWR Site, can not be captured, destroy for 500 credits and reduced enemy patrols',
    refinery = 'WPT 48\n+180 credits/hour',
    uniform = 'WPT 49\nInsurgent outpost, can not be captured, clear for 1000 credits',
    fobmike = 'WPT 50\nProvides Helicopter spawns for players if captured',
    milbase = 'WPT 51\n',
    oscar = 'WPT 52\n',
    sa5 = 'WPT 53\n',
    palmyra = 'WPT 54\n',
    tiyas = 'WPT 55\n',
    shayrat = 'WPT 56\nStrike target, can not be captured, destroy for 500 credits',
    alqusayr = 'WPT 57\n',
    renemouawad = 'WPT 58\n',
    wujah = 'WPT 59\n',
    beirut = 'WPT 60\n',
    rayak = 'WPT 61\n',
    annasiriyah = 'WPT 62\n',
    damascus = 'WPT 63\n',
    roshpina = 'WPT 64\n',
    ramatdavid = 'WPT 65\n',
    thalah = 'WPT 66\n',
    kinghussein = 'WPT 67\n',
    princehassan = 'WPT 68\n',
    muwaffaq = 'WPT 69\n',
    marka = 'WPT 70\n',
    bengurion = 'WPT 71\n',

    benguriondefence = 'WPT \nBen Gurion Defence Zone',
    incirlikdefence = 'WPT \nIncirlik Defence Zone',
    jordandefence = 'WPT \nJordan Defence Zone',
    ramatdaviddefence = 'WPT \nRamat David Defence Zone',
    silkworm = 'WPT \nSilkworm Site'
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
    Gaziantep = ' (16)',
    Manbij = ' (17)',
    Aleppo = ' (18)',
    Delta = ' (19)',
    Taftanaz = ' (20)',
    ["Power Plant"] = ' (21)',
    Hotel = ' (22)',
    ["Bassel Al-Assad"] = ' (23)',
    ["Substation West"] = ' (24)',
    Victor = ' (25)',
    ["Abu al-Duhur"] = ' (26)',
    Tango = ' (27)',
    ["Substation North"] = ' (28)',
    Jirah = ' (29)',
    Foxtrot = ' (30)',
    Durayhim = ' (31)',
    Papa = ' (32)',
    Factory = ' (33)',
	India = ' (34)',
    Romeo = ' (35)',
    Hama = ' (36)',
    ["FOB Lima"] = ' (37)',
    Sierra = ' (38)',
    Golf = ' (39)',
	Dam = ' (40)',
    Raqqa = ' (41)',
    Tabqa = ' (42)',
	["TV Tower"] = ' (43)',
    Juliett = ' (44)',
    November = ' (45)',
    ["Radio Tower"] = ' (46)',
    Kilo = ' (47)',
	Refinery = ' (48)',
	Uniform = ' (49)',
	["FOB Mike"] = ' (50)',
	["Military Base"] = ' (51)',
    Oscar = ' (52)',
    ["SA-5"] = ' (53)',
    Palmyra = ' (54)',
    Tiyas = ' (55)',
    Shayrat = ' (56)',
    ["Al Qusayr"] = ' (57)',
    ["Rene Mouawad"] = ' (58)',
    Wujah = ' (59)',
    Beirut = ' (60)',
    Rayak = ' (61)',
    ["An Nasiriyah"] = ' (62)',
    Damascus = ' (63)',
    ["Rosh Pina"] = ' (64)',
    ["Ramat David"] = ' (65)',
    Thalah = ' (66)',
    ["King Hussein Air College"] = ' (67)',
    ["Prince Hassan"] = ' (68)',
    ["Muwaffaq Salti"] = ' (69)',
    Marka = ' (70)',
    ["Ben Gurion"] = ' (71)',
}

FootholdSaveBaseName = (Era == 'Coldwar') and 'footholdSyria_Extended_0.1_coldwar' or 'footholdSyria_Extended_0.1'

local filepath = FootholdSaveBaseName .. '.lua'
if lfs then
  FootholdSavePath = FootholdSavePath or (lfs.writedir()..'Missions/Saves')
  lfs.mkdir(FootholdSavePath)
  filepath = FootholdSavePath .. '/' .. (FootholdSaveBaseName .. '.lua')
  env.info('Foothold - Save file path: '..filepath)
end

bc = BattleCommander:new(filepath, 10, 60)
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
env.info('Foothold - Rank file path: '..bc.rankFile)
end
Hunt = true

zones = {
	akrotiri = ZoneCommander:new({zone='Akrotiri', side=2, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.akrotiri}),
    paphos = ZoneCommander:new({zone='Paphos', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.paphos}),
    polis = ZoneCommander:new({zone='Polis', side=1, level=20, upgrades=upgrades.insSAM, crates={}, flavorText=flavor.polis}),
	karavostasi = ZoneCommander:new({zone='Karavostasi', side=1, level=20, upgrades=upgrades.milbase2, crates={}, flavorText=flavor.karavostasi}),	
    larnaca = ZoneCommander:new({zone='Larnaca', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.larnaca}),	
    ercan = ZoneCommander:new({zone='Ercan', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.ercan}),
    pinarbashi = ZoneCommander:new({zone='Pinarbashi', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.pinarbashi}),
	gecitkale = ZoneCommander:new({zone='Gecitkale', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.gecitkale}),
	incirlik = ZoneCommander:new({zone='Incirlik', side=1, level=20, upgrades=upgrades.Incirlik, crates={}, flavorText=flavor.incirlik}),
	hatay = ZoneCommander:new({zone='Hatay', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.hatay}),
	minakh = ZoneCommander:new({zone='Minakh', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.minakh}),
	aleppo = ZoneCommander:new({zone='Aleppo', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.aleppo}),
	taftanaz = ZoneCommander:new({zone='Taftanaz', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.taftanaz}),
	jirah = ZoneCommander:new({zone='Jirah', side=1, level=20, upgrades=upgrades.insAirfield, crates={}, flavorText=flavor.jirah}),
	tabqa = ZoneCommander:new({zone='Tabqa', side=1, level=20, upgrades=upgrades.insAirfield, crates={}, flavorText=flavor.tabqa}),
	alduhur = ZoneCommander:new({zone='Abu al-Duhur', side=1, level=20, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.alduhur}),
	alassad = ZoneCommander:new({zone='Bassel Al-Assad', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.alassad}),
	hama = ZoneCommander:new({zone='Hama', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.hama}),
	palmyra = ZoneCommander:new({zone='Palmyra', side=1, level=20, upgrades=upgrades.airfield2palmyra, crates={}, flavorText=flavor.palmyra}),
	powerplant = ZoneCommander:new({zone='Power Plant', side=1, level=20, upgrades=upgrades.generic, crates={}, flavorText=flavor.powerplant, income=0.5}),
	alpha = ZoneCommander:new({zone='FOB Alpha', side=1, level=20, upgrades=upgrades.minimal, crates={}, flavorText=flavor.alpha}),
	bravo = ZoneCommander:new({zone='Bravo', side=1, level=20, upgrades=upgrades.bravofixed, crates={}, flavorText=flavor.bravo}),
	charlie = ZoneCommander:new({zone='Charlie', side=1, level=20, upgrades=upgrades.ewrcharlie, crates={}, flavorText=flavor.charlie}),
	delta = ZoneCommander:new({zone='Delta', side=1, level=20, upgrades=upgrades.deltafixed, crates={}, flavorText=flavor.delta}),
	redcarrier = ZoneCommander:new({zone='Red Carrier', side=1, level=20, upgrades=upgrades.ships, crates={}, flavorText=flavor.redcarrier}),
	foxtrot = ZoneCommander:new({zone='Foxtrot', side=1, level=20, upgrades=upgrades.insGenericFoxtrotFixed, crates={}, flavorText=flavor.foxtrot}),
	golf = ZoneCommander:new({zone='Golf', side=1, level=20, upgrades=upgrades.insSAM, crates={}, flavorText=flavor.golf}),
	hotel = ZoneCommander:new({zone='Hotel', side=1, level=20, upgrades=upgrades.HotelFixed, crates={}, flavorText=flavor.hotel}),
	india = ZoneCommander:new({zone='India', side=1, level=20, upgrades=upgrades.indiaFixed, crates={}, flavorText=flavor.india}),
	juliett = ZoneCommander:new({zone='Juliett', side=1, level=20, upgrades=upgrades.juliettFixed, crates={}, flavorText=flavor.juliett}),
	kilo = ZoneCommander:new({zone='Kilo', side=1, level=20, upgrades=upgrades.ewr, crates={}, flavorText=flavor.kilo}),
	foblima = ZoneCommander:new({zone='FOB Lima', side=0, level=20, upgrades=upgrades.minimal, crates={}, flavorText=flavor.foblima, ForceNeutral=true}),
	fobmike = ZoneCommander:new({zone='FOB Mike', side=0, level=20, upgrades=upgrades.minimal, crates={}, flavorText=flavor.fobmike, ForceNeutral=true}),
	november = ZoneCommander:new({zone='November', side=1, level=20, upgrades=upgrades.generic, crates={}, flavorText=flavor.november}),
	oscar = ZoneCommander:new({zone='Oscar', side=1, level=20, upgrades=upgrades.insMinimum, crates={}, flavorText=flavor.oscar}),
	papa = ZoneCommander:new({zone='Papa', side=1, level=20, upgrades=upgrades.PapaFixed, crates={}, flavorText=flavor.papa}),
	romeo = ZoneCommander:new({zone='Romeo', side=1, level=20, upgrades=upgrades.generic, crates={}, flavorText=flavor.romeo}),
	sierra = ZoneCommander:new({zone='Sierra', side=1, level=20, upgrades=upgrades.radarstrike, crates={}, flavorText=flavor.sierra}),
	tango = ZoneCommander:new({zone='Tango', side=1, level=20, upgrades=upgrades.insOutpost, crates={}, flavorText=flavor.tango}),
	uniform = ZoneCommander:new({zone='Uniform', side=1, level=20, upgrades=upgrades.insOutpost, crates={}, flavorText=flavor.uniform}),
	victor = ZoneCommander:new({zone='Victor', side=1, level=20, upgrades=upgrades.insAmbush, crates={}, flavorText=flavor.victor}),
	substationnorth = ZoneCommander:new({zone='Substation North', side=1, level=20, upgrades=upgrades.insMinimum, crates={}, flavorText=flavor.substationnorth}),
	durayhim = ZoneCommander:new({zone='Durayhim', side=1, level=20, upgrades=upgrades.insGeneric, crates={}, flavorText=flavor.durayhim}),
	raqqa = ZoneCommander:new({zone='Raqqa', side=1, level=20, upgrades=upgrades.insMaximum, crates={}, flavorText=flavor.raqqa}),
	dam = ZoneCommander:new({zone='Dam', side=1, level=20, upgrades=upgrades.damupgrade, crates={}, flavorText=flavor.dam, income=0.5}),
	tv = ZoneCommander:new({zone='TV Tower', side=1, level=20, upgrades=upgrades.insMinimum, crates={}, flavorText=flavor.tv}),
	sa5 = ZoneCommander:new({zone='SA-5', side=1, level=20, upgrades=upgrades.sa5, crates={}, flavorText=flavor.sa5}),
	milbase = ZoneCommander:new({zone='Military Base', side=1, level=20, upgrades=upgrades.milbase, crates={}, flavorText=flavor.milbase}),
	carrier = ZoneCommander:new({zone='Carrier Group', side=2, level=20, upgrades=upgrades.carrierFixed, crates={}, flavorText=flavor.carrier}),
	refinery = ZoneCommander:new({zone='Refinery', side=1, level=20, upgrades=upgrades.generic, crates={}, flavorText=flavor.refinery, income=0.5}),
	factory = ZoneCommander:new({zone='Factory', side=1, level=20, upgrades=upgrades.generic, crates={}, flavorText=flavor.factory, income=0.5}),
	substationwest = ZoneCommander:new({zone='Substation West', side=1, level=20, upgrades=upgrades.generic, crates={}, flavorText=flavor.substationwest}),
	radio = ZoneCommander:new({zone='Radio Tower', side=1, level=20, upgrades=upgrades.generic, crates={}, flavorText=flavor.radio}),
	renemouawad = ZoneCommander:new({zone='Rene Mouawad', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.renemouawad}),
	wujah = ZoneCommander:new({zone='Wujah', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.wujah}),
	beirut = ZoneCommander:new({zone='Beirut', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.beirut}),
	rayak = ZoneCommander:new({zone='Rayak', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.rayak}),
	alqusayr = ZoneCommander:new({zone='Al Qusayr', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.alqusayr}),
	tiyas = ZoneCommander:new({zone='Tiyas', side=1, level=20, upgrades=upgrades.generic, crates={}, flavorText=flavor.tiyas}),
	damascus = ZoneCommander:new({zone='Damascus', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.damascus}),
	annasiriyah = ZoneCommander:new({zone='An Nasiriyah', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.annasiriyah}),
	thalah = ZoneCommander:new({zone='Thalah', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.thalah}),

	kinghussein = ZoneCommander:new({zone='King Hussein Air College', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.kinghussein}),
	muwaffaq = ZoneCommander:new({zone='Muwaffaq Salti', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.muwaffaq}),
	princehassan = ZoneCommander:new({zone='Prince Hassan', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.princehassan}),
	bengurion = ZoneCommander:new({zone='Ben Gurion', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.bengurion}),
	ramatdavid = ZoneCommander:new({zone='Ramat David', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.ramatdavid}),
	roshpina = ZoneCommander:new({zone='Rosh Pina', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.roshpina}),
	marka = ZoneCommander:new({zone='Marka', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.marka}),
	gaziantep = ZoneCommander:new({zone='Gaziantep', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.gaziantep}),
	manbij = ZoneCommander:new({zone='Manbij', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.manbij}),
	shayrat = ZoneCommander:new({zone='Shayrat', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.shayrat}),


	benguriondefence = ZoneCommander:new({zone='Ben Gurion Defence', side=1, level=20, upgrades=upgrades.bengurionDefence, crates={}, flavorText=flavor.benguriondefence}),
	ramatdaviddefence = ZoneCommander:new({zone='Ramat David Defence', side=1, level=20, upgrades=upgrades.ramatdavidDefence, crates={}, flavorText=flavor.ramatdaviddefence}),
	jordandefence = ZoneCommander:new({zone='Jordan Defence', side=1, level=20, upgrades=upgrades.jordanDefence, crates={}, flavorText=flavor.jordandefence}),
	incirlikdefence = ZoneCommander:new({zone='Incirlik Defence', side=1, level=20, upgrades=upgrades.incirlikdefence, crates={}, flavorText=flavor.incirlikdefence}),
	
	silkworm = ZoneCommander:new({zone='Silkworm Site', side=1, level=3, upgrades=upgrades.SilkDefence, crates={}, flavorText=flavor.silkworm}),
	hidden1 = ZoneCommander:new({zone='Hidden1', side=1, level=15, upgrades=upgrades.hidden1Group, crates={}, flavorText=flavor.hidden1}),
	hidden2 = ZoneCommander:new({zone='Hidden2', side=0, level=15, upgrades=upgrades.hidden2Group, crates={}, flavorText=flavor.hidden2, NeutralAtStart=true})
}

if Era == "Coldwar" then
	
    CapPlaneTemplate = CapPlaneTemplate or {
        'RED_MIG29A',
        'RED_MIG29A2',
        'RED_SU27_EW',
        'RED_MIG21Bis',
        'RED_MIG23MLD',
        'RED_MIG23MLD-2',
        'RED_MIG25PD',
        'BLUE_HORNET_CW',
        'BLUE_F15C',
        'BLUE_F15C_CW',
        'BLUE_F14A',
    }

	CapCarrierGroup = CapCarrierGroup or {
        'BLUE_HORNET_CW',
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

	RunwayStrikePlaneTemplate = RunwayStrikePlaneTemplate or {
	"RED_MIG-27K",
	}

	SeadCarrierGroup = SeadCarrierGroup or {
        'BLUE_F14_SEAD',
	}

else
    CapPlaneTemplate = CapPlaneTemplate or {
        'RED_MIG29S',
        'RED_MIG29A',
        'RED_JF17_ONESHIP_CAP',
        'RED_JF17_TWOSHIP_CAP',
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
		'BLUE_HORNET_SEAD',
		
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
	SeadCarrierGroup = SeadCarrierGroup or {
        'BLUE_HORNET_SEAD',
	}

	RunwayStrikePlaneTemplate = RunwayStrikePlaneTemplate or {
	"RED_MIG-27K",
	"RED_SU-33",
	'BLUE_B1'
	}

end

SupplyConvoy = SupplyConvoy or {
    "SupplyConvoy 1",
    "SupplyConvoy 2",
    "SupplyConvoy 3",
}

PlaneSupplyTemplate = PlaneSupplyTemplate or {
	"IL-76MD",
	"C-17A",
}
AntiShipPlaneTemplate = AntiShipPlaneTemplate or {
	--"Viggen_Blue",
	"Hornet_Anti_Ship"
}

function CasAltitude() return math.random(15,25)*1000 end
function CapAltitude() return math.random(22,32)*1000 end
function SeadAltitude() return math.random(25,33)*1000 end
function RunwayStrikeAltitude() return math.random(23,28)*1000 end

zones.akrotiri:addGroups({
	GroupCommander:new({name='Akrotiri-supply-Paphos', mission='supply', template='HeloSupplyTemplate', targetzone='Paphos'}),
	--GroupCommander:new({name='Akrotiri-supply-Larnaca', mission='supply', template='HeloSupplyTemplate', targetzone='Larnaca'}),
	GroupCommander:new({name='Akrotiri-supply-Ercan', mission='supply', template='PlaneSupplyTemplate', targetzone='Ercan'}),
	GroupCommander:new({name='Akrotiri-supply-Larnaca', mission='supply', template='PlaneSupplyTemplate', targetzone='Larnaca'}),
	GroupCommander:new({name='Akrotiri-patrol-Larnaca', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Larnaca', Altitude = CapAltitude()}),
})

zones.paphos:addGroups({
	GroupCommander:new({name='Paphos-supply-Polis', mission='supply', template='HeloSupplyTemplate', targetzone='Polis'})
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
})

zones.pinarbashi:addGroups({
	GroupCommander:new({name='Pinarbashi-supply-Karavostasi', mission='supply', template='HeloSupplyTemplate', targetzone='Karavostasi'}),
	GroupCommander:new({name='Pinarbashi-supply-Ercan', mission='supply', template='HeloSupplyTemplate', targetzone='Ercan'}),
	GroupCommander:new({name='Pinarbashi-attack-Karavostasi-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Karavostasi', diceChance = 50})
})

zones.ercan:addGroups({
	GroupCommander:new({name='Ercan-supply-Larnaca', mission='supply', template='HeloSupplyTemplate', targetzone='Larnaca'}),
	GroupCommander:new({name='Ercan-supply-Gecitkale', mission='supply', template='HeloSupplyTemplate', targetzone='Gecitkale'}),
	GroupCommander:new({name='Ercan-attack-Incirlik', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='Incirlik', Altitude = CapAltitude(), Bluecondition = function() return zones.redcarrier.wasBlue end}),
	GroupCommander:new({name='Ercan-patrol-Ercan-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Ercan', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ercan-attack-Paphos-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Paphos', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ercan-patrol-Karavostasi-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Karavostasi', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ercan-attack-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Paphos', Altitude = CasAltitude()}),
	GroupCommander:new({name='Ercan-attack-Polis', mission='attack', template='AttackConvoy', targetzone='Polis', type='surface', diceChance = 30}),
	GroupCommander:new({name='Ercan-attack-Pinarbashi', mission='attack', template='AttackConvoy', targetzone='Pinarbashi', type='surface', spawnDelayFactor = 4})
})

zones.gecitkale:addGroups({
	GroupCommander:new({name='Gecitkale-supply-Ercan', mission='supply', template='HeloSupplyTemplate', targetzone='Ercan'}),
	GroupCommander:new({name='Gecitkale-supply-Pinarbashi', mission='supply', template='HeloSupplyTemplate', targetzone='Pinarbashi'}),
	GroupCommander:new({name='Gecitkale-supply-Larnaca', mission='supply', template='HeloSupplyTemplate', targetzone='Larnaca'}),
	GroupCommander:new({name='Gecitkale-supply-Incirlik', mission='supply', template='PlaneSupplyTemplate', targetzone='Incirlik'}),
	GroupCommander:new({name='Gecitkale-patrol-Red carrier', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Red Carrier', Altitude = CapAltitude()}),
	--GroupCommander:new({name='Gecitkale-supply-Carrier', mission='supply', template='HeloSupplyTemplate', targetzone='Red Carrier'}),
	GroupCommander:new({name='Gecitkale-attack-Pinarbashi-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Pinarbashi', spawnDelayFactor = 3})
})

zones.redcarrier:addGroups({
	GroupCommander:new({name='CVN-73-supply-Incirlik', mission='supply', template='HeloSupplyTemplate', targetzone='Incirlik', Airbase='Tarawa', Bluecondition = function() return true end}),
	GroupCommander:new({name='CVN-73-attack-Incirlik-Defence-Cas', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Incirlik Defence', Airbase ='Tarawa', type='carrier_air', Bluecondition = function() return true end}),
	GroupCommander:new({name='CVN-73-attack-Incirlik-Defence-Sead', mission='attack', template='SeadCarrierGroup',MissionType='SEAD', targetzone='Incirlik Defence',type='carrier_air', Altitude = SeadAltitude(), Bluecondition = function() return true end}),
	GroupCommander:new({name='CVN-73-patrol-Red Carrier-Cap', mission='patrol', template='CapCarrierGroup',MissionType='CAP', targetzone='Red Carrier',type='carrier_air', Altitude = CapAltitude(), Bluecondition = function() return true end}),
	GroupCommander:new({name='CVN-73-attack-Hotel-Sead', mission='attack', template='SeadCarrierGroup',MissionType='SEAD', targetzone='Hotel',type='carrier_air', Altitude = SeadAltitude(), Bluecondition = function() return true end}),
	GroupCommander:new({name='CVN-73-attack-Incirlik-Sead', mission='attack', template='SeadCarrierGroup',MissionType='SEAD', targetzone='Incirlik', type='carrier_air', Altitude = SeadAltitude(), Bluecondition = function() return not zones.incirlikdefence.active end}),
})

zones.larnaca:addGroups({
	GroupCommander:new({name='Larnaca-supply-Carrier-Boat', mission='supply', targetzone='Red Carrier', type='surface'}),
	GroupCommander:new({name='Larnaca-supply-Bassel Al-Assad', mission='supply', template='PlaneSupplyTemplate', targetzone='Bassel Al-Assad'}),
	GroupCommander:new({name='Larnaca-patrol-Larnaca-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Larnaca', Altitude = CapAltitude()}),
	GroupCommander:new({name='Larnaca-attack-Paphos-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Paphos', diceChance = 50, Altitude = CasAltitude()}),
	GroupCommander:new({name='Larnaca-attack-Polis-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Polis', diceChance = 50, Altitude = CasAltitude()}),
	GroupCommander:new({name='Larnaca-attack-Red Carrier-AntiShip', mission='attack', template='AntiShipPlaneTemplate', MissionType='ANTISHIP', targetzone='Red Carrier', Altitude = 15000})
})

zones.incirlik:addGroups({
	GroupCommander:new({name='Incirlik-supply-Hatay', mission='supply', template='PlaneSupplyTemplate', targetzone='Hatay'}),
	GroupCommander:new({name='Incirlik-supply-Gaziantep', mission='supply', template='PlaneSupplyTemplate', targetzone='Gaziantep'}),
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
	GroupCommander:new({name='Hatay-attack-Jirah-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', Airbase='Incirlik', targetzone='Jirah', Altitude = 32000, Bluecondition = function() return zones.aleppo.side == 2 end}),
	GroupCommander:new({name='Hatay-attack-al-Duhur-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abu al-Duhur', Altitude = CapAltitude()}),
})

zones.durayhim:addGroups({
	GroupCommander:new({name='Durayhim-attack-Duhur-1', mission='attack', template='AttackConvoy', targetzone='Abu al-Duhur', type='surface', spawnDelayFactor = 2}),
	GroupCommander:new({name='Durayhim-attack-Duhur-2', mission='attack', template='AttackConvoy', targetzone='Abu al-Duhur', type='surface'}),
	GroupCommander:new({name='Durayhim-attack-Duhur-3', mission='attack', template='AttackConvoy', targetzone='Abu al-Duhur', type='surface', spawnDelayFactor = 1.5})
})

zones.gaziantep:addGroups({
	GroupCommander:new({name='Gaziantep-patrol-Gaziantep-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Gaziantep', Altitude = CapAltitude()})
})

zones.minakh:addGroups({
	GroupCommander:new({name='Minakh-supply-Hatay', mission='supply', template='HeloSupplyTemplate', targetzone='Hatay'}),
	GroupCommander:new({name='Minakh-supply-Aleppo', mission='supply', template='HeloSupplyTemplate', targetzone='Aleppo'}),
	GroupCommander:new({name='Minakh-supply-Charlie', mission='supply', template='HeloSupplyTemplate', targetzone='Charlie'}),
	GroupCommander:new({name='Minakh-supply-Gaziantep', mission='supply', template='HeloSupplyTemplate', targetzone='Gaziantep'}),
	GroupCommander:new({name='Minakh-supply-Manbij', mission='supply', template='HeloSupplyTemplate', targetzone='Manbij'}),
	GroupCommander:new({name='Minakh-attack-Taftanaz-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Taftanaz'}),
	GroupCommander:new({name='Minakh-attack-Aleppo-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Aleppo'})
})

zones.aleppo:addGroups({
	GroupCommander:new({name='Aleppo-supply-Minakh', mission='supply', template='HeloSupplyTemplate', targetzone='Minakh'}),
	GroupCommander:new({name='Aleppo-supply-Hatay', mission='supply', template='PlaneSupplyTemplate', targetzone='Hatay'}),
	GroupCommander:new({name='Aleppo-supply-Gaziantep', mission='supply', template='PlaneSupplyTemplate', targetzone='Gaziantep'}),
	GroupCommander:new({name='Aleppo-supply-Bassel Al-Assad', mission='supply', template='PlaneSupplyTemplate', targetzone='Bassel Al-Assad'}),
	GroupCommander:new({name='Aleppo-supply-Hama', mission='supply', template='PlaneSupplyTemplate', targetzone='Hama'}),
	GroupCommander:new({name='Aleppo-supply-Tabqa', mission='supply', template='PlaneSupplyTemplate', targetzone='Tabqa'}),
	GroupCommander:new({name='Aleppo-supply-Taftanaz', mission='supply', template='HeloSupplyTemplate', targetzone='Taftanaz'}),
	GroupCommander:new({name='Aleppo-supply-Jirah', mission='supply', template='HeloSupplyTemplate', targetzone='Jirah'}),
	GroupCommander:new({name='Aleppo-supply-Duhur', mission='supply', template='HeloSupplyTemplate', targetzone='Abu al-Duhur'}),
	GroupCommander:new({name='Aleppo-supply-Delta', mission='supply', template='HeloSupplyTemplate', targetzone='Delta'}),
	GroupCommander:new({name='Aleppo-supply-Manbij', mission='supply', template='HeloSupplyTemplate', targetzone='Manbij'}),
	GroupCommander:new({name='Aleppo-patrol-Taftanaz-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Taftanaz', Altitude = CapAltitude()}),
	GroupCommander:new({name='Aleppo-patrol-Duhur-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Abu al-Duhur', Altitude = CapAltitude()}),
	GroupCommander:new({name='Aleppo-attack-Bravo-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Bravo', Altitude = CasAltitude()}),
	GroupCommander:new({name='Aleppo-attack-Duhur', mission='attack', template='AttackConvoy', targetzone='Abu al-Duhur', type='surface'}),
	GroupCommander:new({name='Aleppo-attack-Duhur-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Abu al-Duhur'}),
	GroupCommander:new({name='Aleppo-attack-papa-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Papa', Altitude = SeadAltitude()}),
})

zones.taftanaz:addGroups({
	GroupCommander:new({name='Taftanaz-supply-Hatay', mission='supply', template='HeloSupplyTemplate', targetzone='Hatay', Redcondition = function() return not CustomFlags["TaftanazWarehouse"] end}),
	GroupCommander:new({name='Taftanaz-supply-Aleppo', mission='supply', template='HeloSupplyTemplate', targetzone='Aleppo', Redcondition = function() return not CustomFlags["TaftanazWarehouse"] end}),
	GroupCommander:new({name='Taftanaz-supply-Duhur', mission='supply', template='HeloSupplyTemplate', targetzone='Abu al-Duhur', Redcondition = function() return not CustomFlags["TaftanazWarehouse"] end}),
	GroupCommander:new({name='Taftanaz-supply-Delta', mission='supply', template='HeloSupplyTemplate', targetzone='Delta', Redcondition = function() return not CustomFlags["TaftanazWarehouse"] end}),
	GroupCommander:new({name='Taftanaz-supply-Power Plant', mission='supply', template='HeloSupplyTemplate', targetzone='Power Plant', Redcondition = function() return not CustomFlags["TaftanazWarehouse"] end}),
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
	GroupCommander:new({name='Jirah-attack-Aleppo-surface', mission='attack', targetzone='Aleppo', type='surface'}),
	GroupCommander:new({name='Jirah-attack-Durayhim', mission='attack', template='AttackConvoy', targetzone='Durayhim', type='surface'})
})

zones.tabqa:addGroups({
	GroupCommander:new({name='Tabqa-supply-Jirah', mission='supply', template='HeloSupplyTemplate', targetzone='Jirah'}),
	GroupCommander:new({name='Tabqa-supply-Foxtrot', mission='supply', template='HeloSupplyTemplate', targetzone='Foxtrot'}),
	GroupCommander:new({name='Tabqa-supply-Raqqa', mission='supply', template='HeloSupplyTemplate', targetzone='Raqqa'}),
	GroupCommander:new({name='Tabqa-supply-Golf', mission='supply', template='HeloSupplyTemplate', targetzone='Golf'}),
	GroupCommander:new({name='Tabqa-supply-Dam', mission='supply', template='HeloSupplyTemplate', targetzone='Dam'}),
	GroupCommander:new({name='Tabqa-supply-Millbase', mission='supply', template='HeloSupplyTemplate', targetzone='Military Base'}),
	GroupCommander:new({name='Tabqa-supply-Juliett', mission='supply', template='HeloSupplyTemplate', targetzone='Juliett'}),
	GroupCommander:new({name='Tabqa-supply-Oscar', mission='supply', template='HeloSupplyTemplate', targetzone='Oscar'}),
	GroupCommander:new({name='Tabqa-patrol-Tabqa-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Tabqa', Altitude = CapAltitude()}),
	GroupCommander:new({name='Tabqa-patrol-Palmyra-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', Altitude = CapAltitude()}),
	GroupCommander:new({name='Tabqa-attack-Foxtrot-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Foxtrot', spawnDelayFactor = 1.5, diceChance = 50, Altitude = CasAltitude()}),
	GroupCommander:new({name='Tabqa-attack-Golf-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Golf'}),
	GroupCommander:new({name='Tabqa-attack-Raqqa-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Raqqa'}),
	GroupCommander:new({name='Tabqa-attack-Dam-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Dam'}),
	GroupCommander:new({name='Tabqa-attack-Millbase-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Military Base', Altitude = CasAltitude()}),
	GroupCommander:new({name='Tabqa-attack-Taftanaz-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Taftanaz', spawnDelayFactor = 1.5, Altitude = CapAltitude()})
})

zones.milbase:addGroups({
	GroupCommander:new({name='Milbase-supply-Oscar', mission='supply', template='SupplyConvoy', targetzone='Oscar', type='surface'}),
	GroupCommander:new({name='Milbase-supply-Palmyra', mission='supply', template='HeloSupplyTemplate', targetzone='Palmyra'}),
	GroupCommander:new({name='Milbase-attack-Juliett', mission='attack', template='AttackConvoy', targetzone='Juliett', type='surface', spawnDelayFactor = 4}),
	GroupCommander:new({name='Milbase-attack-Juliett-2', mission='attack', template='AttackConvoy', targetzone='Juliett', type='surface'})
})

zones.alduhur:addGroups({
	GroupCommander:new({name='Alduhur-supply-Aleppo', mission='supply', template='HeloSupplyTemplate', targetzone='Aleppo', Redcondition=function()if CustomFlags["SA11WareHouse"] then spawnDelayFactor=2 end return true end}),
	GroupCommander:new({name='Alduhur-supply-Taftanaz', mission='supply', template='HeloSupplyTemplate', targetzone='Taftanaz', Redcondition=function()if CustomFlags["SA11WareHouse"] then spawnDelayFactor=2 end return true end}),
	GroupCommander:new({name='Alduhur-supply-Jirah', mission='supply', template='HeloSupplyTemplate', targetzone='Jirah', Redcondition=function()if CustomFlags["SA11WareHouse"] then spawnDelayFactor=2 end return true end}),
	GroupCommander:new({name='Alduhur-supply-Hama', mission='supply', template='HeloSupplyTemplate', targetzone='Hama', Redcondition=function()if CustomFlags["SA11WareHouse"] then spawnDelayFactor=2 end return true end}),
	GroupCommander:new({name='Alduhur-supply-Al-Assad', mission='supply', template='HeloSupplyTemplate', targetzone='Bassel Al-Assad', Redcondition=function()if CustomFlags["SA11WareHouse"] then spawnDelayFactor=2 end return true end}),
	GroupCommander:new({name='Alduhur-supply-India', mission='supply', template='HeloSupplyTemplate', targetzone='India', Redcondition=function()if CustomFlags["SA11WareHouse"] then spawnDelayFactor=2 end return true end}),
	GroupCommander:new({name='Alduhur-supply-Factory', mission='supply', template='HeloSupplyTemplate', targetzone='Factory', Redcondition=function()if CustomFlags["SA11WareHouse"] then spawnDelayFactor=2 end return true end}),
	GroupCommander:new({name='Alduhur-supply-November', mission='supply', template='HeloSupplyTemplate', targetzone='November', Redcondition=function()if CustomFlags["SA11WareHouse"] then spawnDelayFactor=2 end return true end}),
	GroupCommander:new({name='Alduhur-supply-Papa', mission='supply', template='SupplyConvoy', targetzone='Papa', type='surface', Redcondition=function()if CustomFlags["SA11WareHouse"] then spawnDelayFactor=2 end return true end}),
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
	GroupCommander:new({name='Alassad-supply-Hotel', mission='supply', template='HeloSupplyTemplate', targetzone='Hotel'}),
	GroupCommander:new({name='Alassad-supply-Incirlik', mission='supply', template='PlaneSupplyTemplate', targetzone='Incirlik'}),
	GroupCommander:new({name='Alassad-supply-Romeo', mission='supply', template='HeloSupplyTemplate', targetzone='Romeo'}),
	GroupCommander:new({name='Alassad-patrol-Carrier-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Red Carrier', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-patrol-Hotel-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hotel', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-patrol-Al-Assad-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Bassel Al-Assad', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-patrol-Al-Assad-Sead', mission='patrol', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Bassel Al-Assad', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Alassad-patrol-India-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='India', Altitude = CapAltitude()}),
	GroupCommander:new({name='Alassad-attack-Larnaca-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Larnaca', Altitude = CasAltitude()}),
	GroupCommander:new({name='Alassad-attack-Ercan-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Ercan', Altitude = CasAltitude()}),
	GroupCommander:new({name='Alassad-attack-Ercan-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Ercan', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Alassad-attack-Ercan-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Ercan', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='Alassad-attack-Hatay-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hatay', Altitude = CapAltitude()}),
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
	GroupCommander:new({name='November-attack-Duhur', mission='attack', targetzone='Abu al-Duhur', type='surface'}),
	GroupCommander:new({name='November-attack-Hama', mission='attack', targetzone='Hama', type='surface'}),
	GroupCommander:new({name='November-attack-India', mission='attack', targetzone='India', type='surface'})
})

zones.palmyra:addGroups({
	GroupCommander:new({name='Palmyra-supply-Hama', mission='supply', template='HeloSupplyTemplate', targetzone='Hama'}),
	GroupCommander:new({name='Palmyra-supply-SA5', mission='supply', template='HeloSupplyTemplate', targetzone='SA-5', spawnDelayFactor = 2, Redcondition = function() return not CustomFlags["SA5Warehouse"] end}),
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
	GroupCommander:new({name='Palmyra-attack-Tiyas-Cap', mission='patrol', template='CapPlaneTemplate',MissionType='CAP', targetzone='Tiyas', Altitude = CapAltitude(), Bluecondition = function() return end}),
	GroupCommander:new({name='Palmyra-attack-Tiyas-Cas', mission='attack', template='CasHeloTemplate',MissionType='CAS', targetzone='Tiyas', Bluecondition = function() return end}),

})

zones.tiyas:addGroups({
	GroupCommander:new({name='Tiyas-supply-Shayrat', mission='supply', template='HeloSupplyTemplate', targetzone='Shayrat'}),
	GroupCommander:new({name='Tiyas-attack-Palmyra', mission='attack', template='AttackConvoy', targetzone='Palmyra', type='surface'}),
	GroupCommander:new({name='Tiyas-attack-An Nasiriyah-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='An Nasiriyah', Altitude = CapAltitude(), Bluecondition = function() return end}),
})

zones.refinery:addGroups({
	GroupCommander:new({name='Refinery-supply-Palmyra', mission='supply', template='SupplyConvoy', targetzone='Palmyra', type='surface'}),
	GroupCommander:new({name='Refinery-supply-Juliett', mission='supply', template='SupplyConvoy', targetzone='Juliett', type='surface'})
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

zones.raqqa:addGroups({
	GroupCommander:new({name='Raqqa-supply-Foxtrot', mission='supply', template='SupplyConvoy', targetzone='Foxtrot', type='surface'}),
	GroupCommander:new({name='Raqqa-supply-Dam', mission='supply', template='SupplyConvoy', targetzone='Dam', type='surface'}),
	GroupCommander:new({name='Raqqa-supply-Tabqa', mission='supply', template='SupplyConvoy', targetzone='Tabqa', type='surface'})
})

zones.dam:addGroups({
	GroupCommander:new({name='Dam-attack-Jirah', mission='attack', template='AttackConvoy', targetzone='Jirah', type='surface', spawnDelayFactor = 2}),
	GroupCommander:new({name='Dam-attack-Foxtrot', mission='attack', template='AttackConvoy', targetzone='Foxtrot', type='surface', spawnDelayFactor = 1.5})
})

zones.beirut:addGroups({
	GroupCommander:new({name='Beirut-patrol-beirut-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Beirut', Altitude = CapAltitude()}),
	GroupCommander:new({name='Beirut-attack-Rosh Pina-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rosh Pina', Altitude = CapAltitude()}),
	GroupCommander:new({name='Beirut-attack-Rayak-Cap', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Rayak'}),
	GroupCommander:new({name='Beirut-supply-Rayak', mission='supply', template='HeloSupplyTemplate', targetzone='Rayak'}),
	GroupCommander:new({name='Beirut-supply-Tiyas', mission='supply', template='PlaneSupplyTemplate', targetzone='Tiyas'}),
	GroupCommander:new({name='Beirut-supply-Shayrat', mission='supply', template='PlaneSupplyTemplate', targetzone='Shayrat'}),
	GroupCommander:new({name='beirut-attack-Wujah', mission='attack', template='AttackConvoy', targetzone='Wujah', type='surface'}),
})

zones.renemouawad:addGroups({
	GroupCommander:new({name='Renemouawad-patrol-Renemouawad-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Rene Mouawad', Altitude = CapAltitude()}),
	GroupCommander:new({name='Renemouawad-attack-Al Qusayr-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Al Qusayr', Altitude = CasAltitude()}),
	GroupCommander:new({name='Renemouawad-attack-An Nasiriyah-Cap', mission='attack', template='CapPlaneTemplate',MissionType='CAP', targetzone='An Nasiriyah', Altitude = CapAltitude()}),
	GroupCommander:new({name='Renemouawad-attack-Nasiriyah-Sead', mission='patrol', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='An Nasiriyah', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Renemouawad-supply-Wujah', mission='supply', template='HeloSupplyTemplate', targetzone='Wujah'}),

})
zones.wujah:addGroups({
	GroupCommander:new({name='wujah-attack-Mouawad', mission='attack', template='AttackConvoy', targetzone='Rene Mouawad', type='surface'}),
	GroupCommander:new({name='wujah-supply-Mouawad', mission='supply', template='SupplyConvoy', targetzone='Rene Mouawad', type='surface'}),


})
zones.shayrat:addGroups({
	GroupCommander:new({name='Shayrat-supply-Al-Qusayr', mission='supply', template='HeloSupplyTemplate', targetzone='Al Qusayr'}),
	GroupCommander:new({name='Shayrat-supply-An-Nasiriyah', mission='supply', template='HeloSupplyTemplate', targetzone='An Nasiriyah'}),
	GroupCommander:new({name='Shayrat-supply-Tiyas', mission='supply', template='HeloSupplyTemplate', targetzone='Tiyas'}),
	GroupCommander:new({name='Shayrat-attack-Palmyra-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', spawnDelayFactor = 2.0, Altitude = CapAltitude()}),
	GroupCommander:new({name='Shayrat-attack-Hama-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Hama', spawnDelayFactor = 2.0, Altitude = CapAltitude()})
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
	GroupCommander:new({name='King-hussein-air-college-attack-Damascus-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Damascus', Altitude = CasAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-An Nasiriyah-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='An Nasiriyah', Altitude = CasAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Ramat David-Cas', mission='attack', template='CasPlaneTemplate',MissionType='CAS', targetzone='Ramat David', Altitude = CasAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Ramat David-Sead', mission='attack', template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Ramat David', Altitude = SeadAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Damascus-Sead', mission='attack', template='SeadPlaneTemplate',MissionType='SEAD', targetzone='Damascus', Altitude = SeadAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Damascus-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Damascus', Altitude = RunwayStrikeAltitude()}),
	GroupCommander:new({name='King-hussein-air-college-attack-Ramat David-RunwayStrike', mission='attack', template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone='Ramat David', Altitude = RunwayStrikeAltitude()}),

})
zones.princehassan:addGroups({
	GroupCommander:new({name='Hassan-supply-Muwaffaq', mission='supply', template='HeloSupplyTemplate', targetzone='Muwaffaq Salti'}),
	GroupCommander:new({name='Hassan-supply-Marka', mission='supply', template='HeloSupplyTemplate', targetzone='Marka'}),
	GroupCommander:new({name='Hassan-supply-King-hussein-air-college', mission='supply', template='HeloSupplyTemplate', targetzone='King Hussein Air College'})
})

zones.alqusayr:addGroups({
	GroupCommander:new({name='Qusayr-supply-Shayrat', mission='supply', template='SupplyConvoy', targetzone='Shayrat', type='surface', spawnDelayFactor = 1.7}),
	GroupCommander:new({name='Qusayr-attack-Shayrat', mission='attack', template='AttackConvoy', targetzone='Shayrat', type='surface'}),
	GroupCommander:new({name='Qusayr-supply-Shayrat', mission='supply', template='HeloSupplyTemplate', targetzone='Shayrat'}),
	GroupCommander:new({name='Qusayr-supply-Mouawad', mission='supply', template='HeloSupplyTemplate', targetzone='Rene Mouawad'}),
	GroupCommander:new({name='Qusayr-attack-Palmyra-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', spawnDelayFactor = 1.6, Altitude = CapAltitude()}),
	GroupCommander:new({name='Qusayr-attack-Palmyra-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Palmyra', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Qusayr-attack-Tiyas-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tiyas', Altitude = CasAltitude()}),
})

zones.rayak:addGroups({
	GroupCommander:new({name='Rayak-supply-Nasiriyah', mission='supply', template='HeloSupplyTemplate', targetzone='An Nasiriyah'}),
	GroupCommander:new({name='Rayak-supply-Beirut', mission='supply', template='HeloSupplyTemplate', targetzone='Beirut'}),
	GroupCommander:new({name='Rayak-attack-Beirut', mission='attack', template='AttackConvoy', targetzone='Beirut', type='surface'}),
})

zones.annasiriyah:addGroups({
	GroupCommander:new({name='Nasiriyah-supply-Damascus', mission='supply', template='HeloSupplyTemplate', targetzone='Damascus'}),
	GroupCommander:new({name='Nasiriyah-supply-Shayrat', mission='supply', template='HeloSupplyTemplate', targetzone='Shayrat'}),
	GroupCommander:new({name='Nasiriyah-attack-Tiyas-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Tiyas', Altitude = CasAltitude()}),
	GroupCommander:new({name='Nasiriyah-attack-Al Qusayr-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Al Qusayr', Altitude = CasAltitude()}),
	GroupCommander:new({name='Nasiriyah-attack-Rayak-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Rayak'}),
	GroupCommander:new({name='Nasiriyah-attack-Beirut-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Beirut', Altitude = SeadAltitude(), Redcondition = function () return zones.rayak.side == 1 end}),
	GroupCommander:new({name='Nasiriyah-attack-Wujah-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Wujah', Altitude = CasAltitude()}),
	GroupCommander:new({name='Nasiriyah-attack-Palmyra-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Palmyra', Altitude = CapAltitude()}),
	GroupCommander:new({name='Nasiriyah-attack-Beirut', mission='attack', template='AttackConvoy', targetzone='Beirut', type ='surface'}),
})

zones.damascus:addGroups({
	GroupCommander:new({name='Damascus-supply-Roshpina', mission='supply', template='HeloSupplyTemplate', targetzone='Rosh Pina'}),
	GroupCommander:new({name='Damascus-patrol-Nasiriyah-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='An Nasiriyah', Altitude = CapAltitude()}),
	GroupCommander:new({name='Damascus-attack-King Hussein-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='King Hussein Air College', Altitude = CasAltitude()})
})

zones.thalah:addGroups({
	GroupCommander:new({name='Thalah-supply-king-Hussein', mission='supply', template='HeloSupplyTemplate', targetzone='King Hussein Air College'}),
	GroupCommander:new({name='Thalah-attack-Damascus', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Damascus'})
})

zones.roshpina:addGroups({
	GroupCommander:new({name='Roshpina-supply-Ramat-David', mission='supply', template='HeloSupplyTemplate', targetzone='Ramat David'}),
	GroupCommander:new({name='Roshpina-supply-Damascus', mission='supply', template='HeloSupplyTemplate', targetzone='Damascus'}),

})

zones.ramatdavid:addGroups({
	GroupCommander:new({name='Ramatdavid-supply-Thalah', mission='supply', template='HeloSupplyTemplate', targetzone='Thalah'}),
	GroupCommander:new({name='Ramatdavid-attack-Thalah', mission='attack', template='AttackConvoy', targetzone='Rosh Pina', type='surface'}),
	GroupCommander:new({name='Ramatdavid-attack-Damascus-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Damascus', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ramatdavid-attack-King Hussein-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='King Hussein Air College', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ramatdavid-attack-Marka-Cap', mission='attack', template='CapPlaneTemplate', MissionType='CAP', targetzone='Marka', Altitude = CapAltitude()}),
	GroupCommander:new({name='Ramatdavid-attack-Wujah-Sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Wujah', Altitude = SeadAltitude()}),
	GroupCommander:new({name='Ramatdavid-attack-Wujah-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='Wujah', Altitude = CasAltitude()}),
})

zones.muwaffaq:addGroups({
	GroupCommander:new({name='Muwaffaq-patrol-king-Hussein-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='King Hussein Air College', Altitude = CapAltitude()}),
	GroupCommander:new({name='Muwaffaq-attack-king-Hussein-Cas', mission='attack', template='CasPlaneTemplate', MissionType='CAS', targetzone='King Hussein Air College', Altitude = CasAltitude()}),
	GroupCommander:new({name='Muwaffaq-attack-Prince Hassan-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='King Hussein Air College'}),
	GroupCommander:new({name='Muwaffaq-patrol-king-Marka-Cap', mission='patrol', template='CapPlaneTemplate', MissionType='CAP', targetzone='Marka', spawnDelayFactor = 1.5, Altitude = CapAltitude()}),
	
})

zones.bengurion:addGroups({
	GroupCommander:new({name='Ben-Gurion-supply-Ramat-David', mission='supply', template='HeloSupplyTemplate', targetzone='Ramat David'}),
	GroupCommander:new({name='Ben-Gurion-supply-Marka', mission='supply', template='HeloSupplyTemplate', targetzone='Marka'}),
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
	if zones.silkworm.active and zones.redcarrier.side == 0 then
		trigger.action.outText("Our ships are standing to capture red carrier zone but the Silkworm is still active", 15)
		trigger.action.outSoundForCoalition(2, "admin.ogg")
	end
	

	if not zones.hidden2.firstCaptureByRed and zones.incirlik.wasBlue then
		zones.hidden2:MakeZoneRedAndUpgrade()
	end
	
	if zones.hidden2.firstCaptureByRed and zones.hatay.wasBlue and zones.palmyra.wasBlue then
		zones.hidden2:DestroyHiddenZone()
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
zones.gaziantep.isHeloSpawn = true
zones.kinghussein.isHeloSpawn = true
zones.princehassan.isHeloSpawn = true
zones.muwaffaq.isHeloSpawn = true
zones.roshpina.isHeloSpawn = true
zones.redcarrier.isHeloSpawn = true

zones.damascus.isHeloSpawn = true
zones.annasiriyah.isHeloSpawn = true
zones.rayak.isHeloSpawn = true
zones.beirut.isHeloSpawn = true
zones.wujah.isHeloSpawn = true
zones.renemouawad.isHeloSpawn = true
zones.alqusayr.isHeloSpawn = true
zones.shayrat.isHeloSpawn = true
zones.tiyas.isHeloSpawn = true
zones.paphos.isHeloSpawn = true
zones.pinarbashi.isHeloSpawn = true
zones.ercan.isHeloSpawn = true
zones.gecitkale.isHeloSpawn = true
zones.larnaca.isHeloSpawn = true
zones.karavostasi.isHeloSpawn = true
zones.polis.isHeloSpawn = true


zones.akrotiri.LogisticCenter = true


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
zones.gaziantep.airbaseName = 'Gaziantep'
zones.kinghussein.airbaseName = 'King Hussein Air College'
zones.princehassan.airbaseName = 'Prince Hassan'
zones.muwaffaq.airbaseName = 'Muwaffaq Salti'
zones.roshpina.airbaseName = 'Rosh Pina'

zones.damascus.airbaseName = 'Damascus'
zones.annasiriyah.airbaseName = 'An Nasiriyah'
zones.rayak.airbaseName = 'Rayak'
zones.beirut.airbaseName = "Beirut-Rafic Hariri"
zones.wujah.airbaseName = 'Wujah Al Hajar'
zones.renemouawad.airbaseName = 'Rene Mouawad'
zones.alqusayr.airbaseName = 'Al Qusayr'
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

bc:addConnection("Minakh","Gaziantep")
bc:addConnection("Gaziantep","Manbij")
bc:addConnection("Aleppo","Manbij")
bc:addConnection("Manbij","Jirah")

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
bc:addConnection("Tabqa","Raqqa")
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
bc:addConnection("Romeo", "Bassel Al-Assad")
bc:addConnection("Foxtrot","Raqqa")
bc:addConnection("Dam","Raqqa")
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
bc:addConnection("Shayrat","Al Qusayr")

bc:addConnection("Al Qusayr","Rene Mouawad")
bc:addConnection("Rene Mouawad","Wujah")
bc:addConnection("Wujah","Beirut")
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
	bc:roamGroupsToLocalSubZone({
		"Red Armor Group2 #",
		"Red Armor Group5 #",
		"Red Armor Group6 #",
		"Red Armor Group7 #",
		"Red Armor Group8 #",
		"Red Armor Group9 #",
		"Red SAM AAA #",
		"Red SAM Dog Ear SA-15 #",
		"Red Armor Group3 #",
		"Red SAM Dog Ear SA-8 #",
		"Red SAM Dog Ear SA-19 #",
		"Molniya #",
		"Rezky #",
		"Neustrashimy #",
		"Red SAM Dog Ear Tor M2 #",
		"Red SAM Shorad Pantsir S1 #"
	}, 30, { "Dam" })
end,{},5,0)

zones.charlie:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Early warning radar destroyed.\nEnemy patrols in the area reduced.\n+500 credits',20)
end, 'disableCharlie')

zones.kilo:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Early warning radar destroyed.\nEnemy patrols in the area reduced.\n+500 credits',20)
end, 'disableKilo')

zones.substationnorth:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disablesubn1')

zones.substationnorth:registerTrigger('destroyed', function(event, sender) 
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Substation disabled\n+500 credits',20)
end, 'disablesubn2')

zones.tv:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disabletv1')

zones.tv:registerTrigger('destroyed', function(event, sender) 
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'TV Tower disabled\n+500 credits',20)
end, 'disabletv2')

zones.substationwest:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disablesubw1')

zones.substationwest:registerTrigger('destroyed', function(event, sender) 
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Substation disabled\n+500 credits',20)
end, 'disablesubw2')

zones.radio:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableradio1')

zones.radio:registerTrigger('destroyed', function(event, sender) 
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Radio Tower disabled\n+500 credits',20)
end, 'disableradio2')

zones.sierra:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableradar1')

zones.sierra:registerTrigger('destroyed', function(event, sender) 
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Radar disabled\n+500 credits',20)
end, 'disableradar2')

zones.tango:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableins1')

zones.tango:registerTrigger('destroyed', function(event, sender) 
	bc:addFunds(2,1000)
	trigger.action.outTextForCoalition(2,'Insurgents cleared\n+1000 credits',20)
end, 'disableins2')

zones.uniform:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableins3')

zones.uniform:registerTrigger('destroyed', function(event, sender) 
	bc:addFunds(2,1000)
	trigger.action.outTextForCoalition(2,'Insurgents cleared\n+1000 credits',20)
end, 'disableins4')

zones.victor:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableins5')

zones.victor:registerTrigger('destroyed', function(event, sender) 
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Blackhawk crew rescued\n+500 credits',20)
end, 'disableins6')

--------------------------------------- cutsom disable ''''''''''''''''''''''''''''''''''''''''''

zones.benguriondefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Ben Gurion defences is destroyed\n+200 credits',20)
end, 'disablebenguriondefence')

zones.ramatdaviddefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Ramat David defences is destroyed\n+200 credits',20)
end, 'disableramatdaviddefence')

zones.jordandefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Jordan defences is destroyed\n+200 credits',20)
end, 'disablejordandefence')

zones.incirlikdefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Incirlik defences is destroyed\n+200 credits',20)
end, 'disableincirlikdefence')

zones.silkworm:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Silkworm defences is destroyed\n+200 credits',20)
end, 'disablesilkworm')


--------------------------------------- cutsom disable ''''''''''''''''''''''''''''''''''''''''''


bc:addMonitoredROE('cruise1')
local cruiseMissileTargetMenu = nil
bc:registerShopItem('cruisemsl', 'Cruise Missile Strike', 500, function(sender)
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
			trigger.action.outTextForCoalition(2, 'Launching cruise missiles at '..target, 15)
		end
	end
	
	cruiseMissileTargetMenu = bc:showTargetZoneMenu(2, 'Cruise Missile Target', launchAttack, 1)
	
	trigger.action.outTextForCoalition(2, 'Cruise missiles ready. Choose target zone from F10 menu', 15)
end,
function (sender, params)
	if params.zone and params.zone.side == 1 then
		local err = bc:fireAtZone(params.zone.zone, 'cruise1', true, 8)
		if err then
			return err
		end
		
		trigger.action.outTextForCoalition(2, 'Launching cruise missiles at '..params.zone.zone, 15)
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
            if zn and zn.side==2 then
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
                            SCHEDULER:New(nil,loop,{},2,0)
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
    if params.zone and params.zone.side==2 then
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
                SCHEDULER:New(nil,loop,{},2,0)
			else
				trigger.action.outTextForCoalition(2,params.zone.zone..' is now fully upgraded!',15)
			end
        end
        loop()
    else
        return'Can only target friendly zone'
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
bc:registerShopItem('jtac','MQ-9 Reaper JTAC mission',500,function(sender)
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
		--trigger.action.outTextForCoalition(2, "(BUG) "..tz.zone.." error has unresolved entries: "..table.concat(dangling,", ")..". Please report to Leka.", 30)
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
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		smoketargets(params.zone)
		trigger.action.outTextForCoalition(2, 'Targets marked with RED smoke at '..params.zone.zone, 15)
	else
		return 'Can only target enemy zone'
	end
end)
if not Era == 'Coldwar' then
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
			trigger.action.outTextForCoalition(2, 'Growler jamming radars at '..target, 15)
		end
	end
	
	jamMenu = bc:showTargetZoneMenu(2, 'Jamming target', startJam, 1)
	trigger.action.outTextForCoalition(2, 'Choose target zone from F10 menu', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
		local gr = Group.getByName('ewAircraft')
		if Utils.isGroupActive(gr) then 
			return 'Jamming mission still in progress'
		end
		
		RespawnGroup('ewAircraft')
		
		SCHEDULER:New(nil,function(target)
			local ew = Group.getByName('ewAircraft')
			if ew then
				local err = bc:jamRadarsAtZone('ewAircraft', target)
				if err then
					return err
				end
				
				trigger.action.outTextForCoalition(2, 'Growler jamming radars at '..target, 15)
			end
		end,{params.zone.zone},2,0)
		
	else
		return 'Can only target enemy zone'
	end
end)
end
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
	if params.zone and params.zone.side == 2 then
		
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
-- new menu
local supplyMenu=nil
bc:registerShopItem('capture','Capture neutral zone',500,
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
bc:registerShopItem('zinf','Add infantry squad to zone',500,function(sender)
	if infMenu then
		return 'Already choosing a zone'
	end
	local pickZone=function(zName)
		if infMenu then
			local z=bc:getZoneByName(zName)
			if not z or z.side~=2 or z.supsended then
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
bc:registerShopItem('farphere','Deploy FARP',1000,function(sender)
        return 'Deploy a FARP via map marker.\nUse marker text: buy:farphere.\nMust be outside all zones and at least 10 NM from enemy zones.'
end,function(_, params)
        return bc:processMapFarpPurchase(params)
end)
------------------------------------------- End of Zone upgrades ----------------------------------------

-- first value below is how much in stock, the second number value is the ranking in the shop menu list, the third is the new ranking system.
bc:addShopItem(2, 'jtac', -1, 1, 2) -- MQ-9 Reaper JTAC mission
bc:addShopItem(2, 'dynamiccap', -1, 2, 2) -- CAP
bc:addShopItem(2, 'dynamiccas', -1, 3, 5) -- CAS
bc:addShopItem(2, 'dynamicbomb', -1, 4, 4) -- Bomber
bc:addShopItem(2, 'dynamicsead', -1, 5, 4) -- SEAD
bc:addShopItem(2, 'dynamicdecoy', -1, 6, 1) -- Decoy flight
--[[ if UseStatics == true then
    bc:addShopItem(2, 'dynamicstatic', -1,7,4) -- Static buildings
end ]]
bc:addShopItem(2, 'dynamicarco', -1, 8, 3) -- Navy tanker
bc:addShopItem(2, 'dynamictexaco', -1, 9, 3) -- Airforce tanker
bc:addShopItem(2, 'farphere', -1, 10, 2) -- deploy FARP
bc:addShopItem(2, 'capture', -1, 11, 1) -- emergency capture
bc:addShopItem(2, 'smoke', -1, 12, 1) -- smoke on target
bc:addShopItem(2, 'intel', -1, 13, 5) -- Intel
bc:addShopItem(2, 'supplies2', -1, 14, 1) -- upgrade friendly zone
bc:addShopItem(2, 'supplies', -1, 15, 6) -- fully upgrade friendly zone
bc:addShopItem(2, 'zinf', -1, 16, 2) -- add infantry to a zone
bc:addShopItem(2, 'zarm', -1, 17, 3) -- add armour group to a zone
bc:addShopItem(2, 'zsam', -1, 18, 7) -- add Nasams to a zone
bc:addShopItem(2, 'zlogc', -1, 19, 1) -- upgrade zone to logistic center
bc:addShopItem(2, 'zwh50', -1, 20, 2) -- resupply warehouse with 50
bc:addShopItem(2, 'gslot', 1, 21, 9) -- add another slot for upgrade
if Era == 'Modern' then
    bc:addShopItem(2, 'zpat', -1, 22, 8) -- Patriot system.
end
bc:addShopItem(2, 'armor', -1, 23, 3) -- combined arms
bc:addShopItem(2, 'artillery', -1, 24, 3) -- combined arms
bc:addShopItem(2, 'recon', -1, 25, 3) -- combined arms
bc:addShopItem(2, 'airdef', -1, 26, 3) -- combined arms
bc:addShopItem(2, '9lineam', -1, 27, 1) -- free jtac
bc:addShopItem(2, '9linefm', -1, 28, 1) -- free jtac
bc:addShopItem(2, 'cruisemsl', 12, 29, 10) -- Cruise missiles

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
    'Raqqa',
    'Dam',
    'TV Tower',
    'SA-5',
    'Rene Mouawad',
    'Wujah',
    'Beirut',
    'Rayak',
    'Al Qusayr',
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
    'Gaziantep',
    'Manbij',
    'Shayrat'
}


lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

bc:loadFromDisk() --will load and overwrite default zone levels, sides, funds and available shop items
bc:init()
bc:startRewardPlayerContribution(15,{infantry = 10, ground = 10, sam = 30, airplane = 30, ship = 250, helicopter=30, crate=200, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, ['CAP mission'] = true, ['CAS mission'] = true})
HercCargoDropSupply.init(bc)
buildTemplateCache()
bc:buildZoneDistanceCache()
buildSubZoneRoadCache()
bc:buildConnectionMap()
DynamicConvoy.InitTargetTails(5)
DynamicConvoy.InitRoadPathCacheFromCommanders(GroupCommanders)
PrecomputeLandingSpots()
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
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=75 }   -- blue
}

GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 90   		-- suspend red zones deeper than this nm
evc = EventCommander:new({ decissionFrequency=15*60, decissionVariance=10*60, skipChance = 15})
evc:init()
mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})
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
				trigger.action.outTextForCoalition(2, 'SCUDS near Oscar are launching at '..choice, 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
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
    title = "Destroy SCUDS (52)",
    description = "SCUDS have been spotted at Oscar (52).\nDestroy them before they can launch their missiles",
    messageStart = "New mission: Destroy SCUDS",
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
        local gr = Group.getByName('oscar-scud-1')
        if gr then return true else return false end
    end
})

--------------------------------------- End of Oscar Scuds ---------------------------------------
---------------------------------------- Escort me mission ---------------------------------------
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
    title = "Escort cargo plane",
    description = "Friendly cargo plane is taking off from Incirlik. Protect it until it leaves the airspace.",
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
		RegisterGroupTarget(casGrp,500,'Intercept enemy airstrike')
		timer.scheduleFunction(function()
			local tgts={'Hatay','Abu al-Duhur','Hama','Jirah','Aleppo','Taftanaz','Palmyra','Bassel Al-Assad','Hotel','Juliett','Factory','India','Military Base',
						'An Nasiriyah','Al Qusayr','Rayak','Palmyra'}
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
	title = "Intercept enemy airstrike",
	description = "Enemy aircraft conducting an airstrike from the south-east\nDestroy them before they get in range.",
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
		local g1 = Group.getByName('evt-CAS')
		local g2 = Group.getByName('evt-CAScw')
		if g1 or g2 then
			return true
		else
			return false
		end
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
		RegisterGroupTarget(casGrp,500,'Intercept enemy airstrike')
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
	title = "Intercept enemy airstrike",
	description = "Enemy aircraft conducting an airstrike from the North-South\nDestroy them before they get in range.",
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
		local g1 = Group.getByName('evt-CAS2')
		local g2 = Group.getByName('evt-CAScw2')
		if g1 or g2 then
			return true
		else
			return false
		end
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
		RegisterGroupTarget('evt-bomber',500,'Intercept enemy bombers')
		timer.scheduleFunction(function()
			RespawnGroup(escGrp)
				local tgts = {
					'Hatay','Abu al-Duhur','Hama','Jirah','Aleppo','Taftanaz','Palmyra',
					'Bassel Al-Assad','Hotel','Juliett','Factory','India','Military Base','Palmyra'}
					if Group.getByName('evt-bomber') then
						local bomber, bomberMission = StartBomberAuftrag('bomb', 'evt-bomber', tgts, escGrp)
				end
		end,{},timer.getTime()+1)
	end,
	canExecute=function()
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
	title = "Intercept Bombers",
	description = "Enemy bombers spotted to the north-east\nDestroy them before they get in range.",
	messageStart = "New mission: Intercept Bombers",
	messageEnd=function() lastbomb_COOLDOWN=timer.getTime() return "Mission ended: Intercept Bombers" end,
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
		local gr = Group.getByName('evt-bomber')
		if gr then return true else return false end
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
		RegisterGroupTarget('evt-bomber2',500,'Intercept enemy bombers')
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
		if timer.getTime()-lastbomb2_COOLDOWN<bomb2_COOLDOWN then return false end
		if Group.getByName('evt-bomber') then return false end
		if Group.getByName('evt-bomber2') then return false end
		--if math.random(1,100)<70 then return false end
		local trg={'Paphos','Incirlik'}
		for _,v in ipairs(trg) do
			if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end
		end
		return false
	end
})

mc:trackMission({
	title = "Intercept Bombers",
	description = "Enemy bombers spotted north of Cyprus\nDestroy them before they get in range.",
	messageStart = "New mission: Intercept Bombers",
	messageEnd=function() lastbomb2_COOLDOWN=timer.getTime() return "Mission ended: Intercept Bombers" end,
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
		local gr = Group.getByName('evt-bomber2')
		if gr then return true else return false end
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
		RegisterGroupTarget('evt-bomber3',500,'Intercept enemy bombers')
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
		if timer.getTime()-lastbomb3_COOLDOWN<bomb3_COOLDOWN then return false end
		if Group.getByName('evt-bomber') then return false end
		if Group.getByName('evt-bomber2') then return false end
		if Group.getByName('evt-bomber3') then return false end
		--if math.random(1,100)<70 then return false end
		local trg={'An Nasiriyah','Beirut'}
		for _,v in ipairs(trg) do
			if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end
		end
		return false
	end
})

mc:trackMission({
	title = "Intercept Bombers",
	description = "Enemy bombers spotted north of Cyprus\nDestroy them before they get in range.",
	messageStart = "New mission: Intercept Bombers",
	messageEnd=function() lastbomb2_COOLDOWN=timer.getTime() return "Mission ended: Intercept Bombers" end,
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
		local gr = Group.getByName('evt-bomber3')
		if gr then return true else return false end
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
	local u = Group.getByName(ships[choice]):getUnit(1)
	if u then RegisterUnitTarget(u:getName(),500,'Cargo ship') end
  end,
  canExecute = function()
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
    title = "Destroy cargo ship at Red Carrier",
    description = "Find and destroy the enemy cargo ship at Red Carrier, heading towards Bassel Al-Assad",
    messageStart = "New mission: Destroy cargo ship",
    messageEnd =function() lastShip_COOLDOWN=timer.getTime() return "Mission ended: Destroy cargo ship" end,
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
        if Group.getByName('evt-shiptercept1') then return true end
        if Group.getByName('evt-shiptercept2') then return true end
        if Group.getByName('evt-shiptercept3') then return true end

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
		local u = Group.getByName(planes[choice]):getUnit(1)
		if u then RegisterUnitTarget(u:getName(),500,'Cargo plane mission') end
	end,
	canExecute = function()
		if timer.getTime() - lastCargo_COOLDOWN < Cargo_COOLDOWN then return false end
		if math.random(1,100) < 70 then return false end
		local redCarrier = bc:getZoneByName('Red Carrier')
		if redCarrier.side ~= 1 or redCarrier.suspended then return false end
		local basselAlAssad = bc:getZoneByName('Bassel Al-Assad')
		if basselAlAssad.side ~= 1 or basselAlAssad.suspended then return false end
		if Group.getByName('evt-cargointercept1') then return false end
		if Group.getByName('evt-cargointercept2') then return false end
		if Group.getByName('evt-cargointercept3') then return false end
		return true
	end
})
mc:trackMission({
    title = "Intercept cargo plane",
    description = "Find and destroy the enemy cargo plane near Red Carrier, heading for Bassel Al-Assad.",
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
        if Group.getByName('evt-cargointercept1') then return true end
        if Group.getByName('evt-cargointercept2') then return true end
        if Group.getByName('evt-cargointercept3') then return true end
        
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
    title = "Defend Abu al-Duhur",
    description = "The enemy is preparing an all out attack on Abu al-Duhur.\nDefend the airfield at all cost.",
    messageStart = "New mission: Defend Abu al-Duhur",
    messageEnd = "Mission ended: Defend Abu al-Duhur",
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
		RegisterGroupTarget(target[name], 2500, 'Russian general')
	end,
	canExecute = function()
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
    title = "Find the generals convoy",
    description =
[[Find the generals convoy!
he just left Pinarbashi in a convoy protected by SA-19,

find where he live and drop a bomb on the building]],
    messageStart = "New mission: Find the generals convoy.\nHe just left Pinarbashi headed north",
    messageEnd = "Mission ended: Find the generals convoy",
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
        if Group.getByName('GroundConvoy1') then return true end
        if Group.getByName('GroundConvoy2') then return true end
        if Group.getByName('GroundConvoy3') then return true end
        
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
    trigger.action.outText(name .. ' is missing', 30)
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
			trigger.action.outText('EnemyHideout is missing',30)
			return
		end
		RegisterScoreTarget('EnemyHideout',tgt,500,'Enemy hideout')
		ActiveMission['EnemyHideout'] = true
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"Strike on enemy hideout",p,2,false,false)
			MissionMarks['EnemyHideout'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['EnemyHideout'] then return false end
	if CustomFlags["EnemyHideout"] then return false end
	if bc:getZoneByName('Hatay').side ~= 2 or bc:getZoneByName('Hatay').suspended then return false end
	if bc:getZoneByName('Aleppo').side == 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = "Strike on enemy hideout",
	description =
[[Enemy hideout have been found,
North west of Aleppo airport, in the city of Aleppo.
Take it out!

Reward: 500

MGRS: 37 S CA 34720 07791
Lat long: N 36°12'03" E 37°09'41"
Lat long Precise: N 36°12'03.04" E 37°09'41.70"
Lat long Decimal Minutes: N 36°12.050' E 37°09.695'
Elevation 1287 feet]],
	messageStart = "New strike mission: Strike on enemy hideout",
	messageEnd = "Strike mission ended: Strike on enemy hideout",
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
			trigger.action.outText('TaftanazWarehouse is missing',30)
			return
		end
		RegisterScoreTarget('TaftanazWarehouse',tgt,500,'Taftanaz Warehouse')
		ActiveMission['TaftanazWarehouse'] = true
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,'Strike on Taftanaz supply warehouse',p,2,false,false)
			MissionMarks['TaftanazWarehouse'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['TaftanazWarehouse'] then return false end
	if CustomFlags["TaftanazWarehouse"] then return false end
	if bc:getZoneByName('Taftanaz').side ~= 1 or bc:getZoneByName('Taftanaz').suspended then return false end
	if bc:getZoneByName('Hatay').side ~= 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = "Strike on Taftanaz supply warehouse",
	description =
[[Taftanaz supply warehouse has been found,
Take it out to halt the supplies going from there.

Reward: 250

MGRS: 37 S CV 00527 82799
Lat long: N 35°58'09" E 36°47'16"
Lat long Precise: N 35°58'09.20" E 36°47'16.11"
Lat long Decimal Minutes: N 35°58.154' E 36°47.268'
Elevation 1020 feet]],
	messageStart = "New strike mission: Strike on Taftanaz supply warehouse",
	messageEnd = "Strike mission ended: Strike on Taftanaz supply warehouse",
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
			trigger.action.outText('SA11WareHouse is missing',30)
			return
		end
		RegisterScoreTarget('SA11WareHouse',tgt,500,'SA11 WareHouse')
		ActiveMission['SA11WareHouse'] = true
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,'Strike on Abu al-Duhur SA-11 supply warehouse',p,2,false,false)
			MissionMarks['SA11WareHouse'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['SA11WareHouse'] then return false end
	if CustomFlags["SA11WareHouse"] then return false end
	if bc:getZoneByName('Abu al-Duhur').side ~= 1 or bc:getZoneByName('Abu al-Duhur').suspended then return false end
	if bc:getZoneByName('Hatay').side ~= 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = "Strike on Abu al-Duhur SA-11 supply warehouse",
	description =
[[Abu al-Duhur supply for the SA-11 at papa has been found,
Take it out to halt the supplies going there.

Reward: 250

MGRS: 37 S CV 29530 56517
Lat long: N 35°44'16" E 37°06'53"
Lat long Precise: N 35°44'16.48" E 37°06'53.64"
Lat long Decimal Minutes: N 35°44.274' E 37°06.894'
Elevation 1020 feet]],
	messageStart = "New strike mission: Strike on Abu al-Duhur supply warehouse",
	messageEnd = "Strike mission ended: Strike on Abu al-Duhur supply warehouse",
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
			trigger.action.outText('IncirlikWarehouse is missing',30)
			return
		end
		RegisterScoreTarget('IncirlikWarehouse',tgt,500,'Incirlik Warehouse')
		ActiveMission['IncirlikWarehouse'] = true
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,'Strike on Incirlik Defence supply warehouse',p,2,false,false)
			MissionMarks['IncirlikWarehouse'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['IncirlikWarehouse'] then return false end
	if CustomFlags["IncirlikWarehouse"] then return false end
	if bc:getZoneByName('Incirlik').side ~= 1 or bc:getZoneByName('Incirlik').suspended then return false end
	if not bc:getZoneByName('Incirlik Defence').active then return false end
	if bc:getZoneByName('Red Carrier').side ~= 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = "Strike on Incirlik Defence supply warehouse",
	description =
[[Incirlik supplies for the SA-11 at Incirlik Defence has been found
at Incirlik airport. Strike the warehouse to halt the supplies going 
there.

Reward: 250

MGRS: 36 S YF 16959 97729
Lat long: N 37°00'02" E 35°26'17"
Lat long Precise: N 37°00'02.52" E 35°26'17.60"
Lat long Decimal Minutes: N 37°00.042' E 35°26.293'
Elevation 204 feet]],
	messageStart = "New strike mission: Incirlik Defence supply warehouse",
	messageEnd = "Strike mission ended: Incirlik Defence supply warehouse",
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
		RegisterStaticGroup('DamFactories', z, 250, 'Dam Factories', 'DamFactories')
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
	title = "Strike on Dam Factories",
	description =
[[2 Dam factories have been identified.
Destroy them to get rid of this enemy base and
all of the activity in it.

Reward: 250

2000 LBS Penetrator bomb is required.

MGRS: 37 S DV 60107 68418
Lat long: N 35°51'32" E 38°33'29"
Lat long Precise: N 35°51'32.99" E 38°33'29.39"
Lat long Decimal Minutes: N 35°51.549' E 38°33.489'
Elevation 980 feet

MGRS: 37 S DV 60141 68067
Lat long: N 35°51'21" E 38°33'30"
Lat long Precise: N 35°51'21.61" E 38°33'30.80"
Lat long Decimal Minutes: N 35°51.360' E 38°33.513'
Elevation 973 feet]],
	messageStart = "New strike mission: Strike on Dam Factories",
	messageEnd = "Strike mission ended: Strike on Dam Factories",
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
		RegisterStaticGroup('RefineryFactories', z, 500, 'Refinery Factories', 'RefineryFactories')
	end,
	canExecute = function()
		if ActiveMission['RefineryFactories'] then return false end
		if CustomFlags['RefineryFactories'] then return false end
		if bc:getZoneByName('Refinery').side ~= 1 or bc:getZoneByName('Refinery').suspended then return false end
		local abu = bc:getZoneByName('Abu al-Duhur')
		if abu.side ~= 2 or abu.suspended then return false end
		return true
	end,
})


mc:trackMission({
	title = "Strike on Dam Factories",
	description =
[[4 factories in Refinery have been identified.
Destroy them to get rid of this enemy base and
all of the activity in it.

Reward: 500

2000 LBS Penetrator bomb is required.
4 Targets near the center if the waypoint.

MGRS: 37 S CU 85209 66109
Lat long: N 34°55'51" E 37°44'35"
Lat long Precise: N 34°55'51.52" E 37°44'35.29"
Lat long Decimal Minutes: N 34°55.858' E 37°44.588'
Elevation 2512 feet]],
	messageStart = "New strike mission: Strike on Refinery factories",
	messageEnd = "Strike mission ended: Strike on Refinery factories",
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
			trigger.action.outText('SA5Warehouse is missing',30)
			return
		end
		RegisterScoreTarget('SA5Warehouse',tgt,500,'SA5 Warehouse')
		ActiveMission['SA5Warehouse'] = true
	local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"Strike on Palmyra's SA-5 storage parts",p,2,false,false)
			MissionMarks['SA5Warehouse'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['SA5Warehouse'] then return false end
	if CustomFlags["SA5Warehouse"] then return false end
	if bc:getZoneByName('Palmyra').side ~= 1 or bc:getZoneByName('Palmyra').suspended then return false end
	if bc:getZoneByName('SA-5').side ~= 1 or bc:getZoneByName('SA-5').suspended then return false end
	if bc:getZoneByName('Abu al-Duhur').side ~= 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = "Strike on Palmyra's SA-5 storage parts",
	description =
[[Palmyra's SA-5 storage parts have been found,
Take it out to halt the repairs going from there.

Reward: 250

MGRS: 37 S DU 36481 24765
Lat long: N 34°33'45" E 38°18'27"
Lat long Precise: N 34°33'45.65" E 38°18'27.31"
Lat long Decimal Minutes: N 34°33.760' E 38°18.455'
Elevation 1300 feet]],
	messageStart = "New strike mission: Strike on Palmyra's SA-5 storage parts",
	messageEnd = "Strike mission ended: Strike on Palmyra's SA-5 storage parts",
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
		if ActiveMission['SA5Warehouse'] then return true end
		return false
	end
})
-------------------------------- Strike the rebels --------------------------------

Group.getByName('StrikeTargetGroup'):destroy()
evc:addEvent({
	id='StrikeTarget',
	action = function()
	RespawnGroup('StrikeTargetGroup')
	RegisterGroupTarget('StrikeTargetGroup',250,'Strike the rebeles','StrikeTarget')
	end,
	canExecute = function()
		if math.random(1,100) < 70 then return false end
		if Group.getByName('StrikeTargetGroup') then return false end
		if CustomFlags["StrikeTarget"] then return false end
		local carrier =  bc:getZoneByName('Red Carrier')
		if carrier.side ~= 1 then return false end
	return true
end
})
mc:trackMission({
	title = "Strike the rebeles",
	description =
[[Rebels hideout have been found, 
East of Incirlik in the city of Adana.

Drop a bomb on the building!

Reward: 250

MGRS: 36 S YF 01234 99114
Lat long: N N 37°01'00" E 35°15'43"
Lat long Decimal Minutes: N 37°01.000' E 35°15.720'

Elevation 83 feet]],
	messageStart = "New strike mission: Strike the rebeles",
	messageEnd = "Strike mission ended: Strike the rebeles\n+250 credits",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["StrikeTarget"] then return false end
	if IsGroupActive('StrikeTargetGroup') then return true end
	return false
	end,
})

Group.getByName('StrikeTargetGroup1'):destroy()
evc:addEvent({
	id='StrikeTarget1',
	action = function()
	RespawnGroup('StrikeTargetGroup1')
	RegisterGroupTarget('StrikeTargetGroup1',250,'Strike the rebeles','StrikeTarget1')
	end,
	canExecute = function()
		if math.random(1,100) < 70 then return false end
		if Group.getByName('StrikeTargetGroup1') then return false end
		if CustomFlags["StrikeTarget1"] then return false end
		if bc:getZoneByName('Hatay').side ~= 2 then return false end	
		return true
	end
})
mc:trackMission({
	title = "Strike the rebeles",
	description =
[[Another rebel hideout have been found, 
West of Aleppo airport, in the city of Aleppo.

Drop a bomb on the building!

Reward: 250

MGRS: 37 S CA 45592 05682
Lat long: N N N 36°11'01" E 37°16'58"
Lat long Decimal Minutes: N 36°11.017' E 37°16.972'

Elevation 1261 feet]],
	messageStart = "New strike mission: Strike the rebeles",
	messageEnd = "Strike mission ended: Strike the rebeles",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["StrikeTarget1"] then return false end
	if IsGroupActive('StrikeTargetGroup1') then return true end
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
		RegisterGroupTarget('StrikeTargetGroup2',750,'Strike the general','StrikeTarget2')
	end,
	canExecute = function()
		if bc:getZoneByName('Abu al-Duhur').side ~= 2 then return false end
		if bc:getZoneByName('Shayrat').side ~= 1 then return false end
		if Group.getByName('StrikeTargetGroup2') then return false end
		if CustomFlags["StrikeTarget2"] then return false end
		return true
	end
})

mc:trackMission({
	title = "Strike the general",
description = 
[[We have the location on one of the generals. 
South of Hama, Take him out!

Coordinates:
MGRS: 37 S BU 92159 66783
Lat Long: N 34°55'20" E 36°43'28"
Lat long Decimal Minutes: N 34°55.334' E 36°43.481'
Elevation: 1333 feet

Reward: 750

Destroy the house and whoever is nearby.]],

	messageStart = "New strike mission: Strike the general",
	messageEnd = "Strike mission ended: Strike the general",
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
		if Group.getByName('StrikeTargetGroup2') then return true end
		return false
	end
})

-------------------------------- Destroy EWR --------------------------------
evc:addEvent({
	id='EWRSouth',
	action = function()
		ActiveMission['EWRSouth'] = true
		RegisterGroupTarget('Red EWR-south Fixed',1000,'Destroy enemy EWR\nBehind enemy lines','EWRSouth')
	end,
	canExecute = function()
		if not Group.getByName('Red EWR-south Fixed') then return false end 
		if bc:getZoneByName('Beirut').side ~= 2 then return false end
		if bc:getZoneByName('Ben Gurion').side ~= 1 then return false end
		if CustomFlags["EWRSouth"] then return false end
		if ActiveMission['EWRSouth'] then return false end
		return true
	end
})

mc:trackMission({
	title = "Deep strike mission on enemy EWR",
description = 
[[We have the location of the enemy EWR, it's important that
we destroy it before we continue our advance. 

Location is south of Ben Gurion airport.

Coordinates:
MGRS: 36 R XA 77724 23705
Lat Long: N 31°50'06" E 34°52'41"
Lat long Decimal Minutes: N 31°50.111' E 34°52.684'
Elevation: 321 feet

Reward: 1000]],

	messageStart = "New strike mission: Behind enemy lines.",
	messageEnd = "Strike mission ended: Behind enemy lines.",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
		if CustomFlags["EWRSouth"] then return false end
		if ActiveMission['EWRSouth'] then return true end
		return false
	end
})

-------------------------------- Destroy EWR 2 --------------------------------
evc:addEvent({
	id='EWRSA5',
	action = function()
		ActiveMission['EWRSA5'] = true
		RegisterGroupTarget('Red EWR-southeast Fixed',1000,'Destroy enemy EWR\nBehind enemy lines','EWRSA5')
	end,
	canExecute = function()
		if not Group.getByName('Red EWR-southeast Fixed') then return false end 
		if bc:getZoneByName('Abu al-Duhur').side ~= 2 and bc:getZoneByName('Hama').side ~= 2 then return false end
		if bc:getZoneByName('SA-5').side ~= 1 then return false end
		if CustomFlags["EWRSA5"] then return false end
		if ActiveMission['EWRSA5'] then return false end
		return true
	end
})

mc:trackMission({
	title = "Deep strike mission on enemy EWR",
description = 
[[We have the location of the enemy EWR, it's important that
we destroy it before we continue our advance. 

Location is 30NM south east of the SA-5.

Coordinates:
MGRS: 37 S EU 31088 22294
Lat Long: N 34°32'30" E 39°20'19"
Lat long Decimal Minutes: N 34°32.513' E 39°20.328'
Elevation: 1251 feet

Reward: 1000]],

	messageStart = "New strike mission: Behind enemy lines.",
	messageEnd = "Strike mission ended: Behind enemy lines.",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
		if CustomFlags["EWRSA5"] then return false end
		if ActiveMission['EWRSA5'] then return true end
		return false
	end
})
-------------------------------- Destroy artillery --------------------------------

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards Aleppo from the direction of Jirah.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('jirah-attack-Aleppo-surface',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('jirah-attack-Aleppo-surface')
        if gr then return true else return false end
    end
})

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards Durayhim from the direction of Jirah.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('jirah-attack-Durayhim',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('jirah-attack-Durayhim')
        if gr then return true else return false end
    end
})

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards Abu al-Duhur from the direction of November.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('november-attack-Duhur',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('november-attack-Duhur')
        if gr then return true else return false end
    end
})

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards India from the direction of November.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('november-attack-india',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('november-attack-india')
        if gr then return true else return false end
    end
})

mc:trackMission({
	title = "Destroy artillery",
	description = "Artillery has been spotted heading towards Hama from the direction of November.\nDestroy them before they get in range.",
	messageStart = "New mission: Destroy artillery",
	messageEnd = "Mission ended: Destroy artillery",
	startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('november-attack-hama',100,'Destroy artillery')
    end,
    endAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "cancel.ogg")
        end
    end,
	isActive = function()
		local gr = Group.getByName('november-attack-hama')
		if gr then return true else return false end
	end
})

------------------------------------ End of custom missions --------------------------------
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
		ActiveCurrentMission[attackTarget] = ActiveCurrentMission[attackTarget] or {}
		ActiveCurrentMission[attackTarget]["Attack"] = true
		local z = bc:getZoneByName(attackTarget) if z then z:updateLabel() end
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cas.ogg")
		end
	end,
	endAction = function()
		local t = (type(ActiveCurrentMission) == 'table') and ActiveCurrentMission[attackTarget] or nil
		if type(t) == 'table' then
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


seadTarget = nil
function generateSEADMission()
    if seadTarget then return end
    if not attackTarget then return end

    local function isSEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and not zone.suspended and (lname:find('sam') or lname:find('defence')
		or lname:find('papa') or lname:find('juliett') or lname:find('india') or lname:find('delta')
		or lname:find('bravo') or lname:find('hotel')) and (not isZoneUnderSEADMission or not isZoneUnderSEADMission(zone.zone))
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
        return zone.side == 1 and zone.active and not zone.suspended and (lname:find('sam') or lname:find('defence')
		or lname:find('papa') or lname:find('juliett') or lname:find('india') or lname:find('delta')
		or lname:find('bravo') or lname:find('hotel'))
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
           not v.ForceNeutral and not string.find(v.zone, "Hidden") and (not v.zone:find("Red Carrier")) then
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


function generateAttackMission()
    if missionCompleted then return end
    if attackTarget ~= nil then return end

	local validzones = {}
	for _, v in ipairs(bc.connections) do
		local from, to = bc:getConnectionZones(v)

        local function checkValid(zone)
			local lname = zone.zone:lower()
            return zone.side == 1 and zone.active and not isZoneUnderSEADMission(zone.zone)
			and not lname:find('sam') and not lname:find('defence') and not lname:find('papa') and
			not lname:find('juliett') and not lname:find('india') and not lname:find('delta') and
			not lname:find('bravo') and not lname:find('hotel')
        end

	if from and to and from.side ~= to.side and from.side ~= 0 and to.side ~= 0 and 
		((not to.suspended) or from.suspended) then
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
	if resupplyTarget ~= nil then return end
		
	local validzones = {}
	for _,v in ipairs(bc.zones) do
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


buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end

--configure zone messages 


env.info("Mission Setup : is completed!")