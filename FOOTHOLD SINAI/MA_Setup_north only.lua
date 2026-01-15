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
		blue = {'Hazzard Perry', 'Hazzard Perry', 'Hazzard Perry'},
		red = {'Molniya', 'Molniya', 'Molniya', 'Rezky', 'Rezky', 'Neustrashimy', 'Neustrashimy', 'Moskva'}
	},
	blueships = {
		blue = {'Hazzard Perry'},
		red = {'Moskva'}
	},
	airfield1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Red SAM SHORAD SA-19', 'Red SAM AAA','Red SAM AAA 2', 'Red SAM SHORAD SA-19 2', 'Ground Armour 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8 2'}
	},
	ElGoraUpgrade = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Ground Armour', 'Red SAM AAA', 'Ground Armour 2','Red SAM AAA 2', 'Red SAM SHORAD SA-8 2', 'Red SAM SHORAD SA-8', 'El Gora Command Center'}
	},
	airfield2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Ground Armour', 'Ground Armour 3','Red SAM SHORAD SA-19 2','Red SAM AAA', 'Red SAM SHORAD SA-8 2', 'Red SAM SHORAD SA-19', 'Red SAM AAA 2', 'Red SAM AAA 3', 'Red SAM AAA 4'}
	},
	airfield2Ismailiyah = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Red SAM AAA', 'Ground Armour', 'Ground Armour 3', 'Red SAM AAA 2','Al Ismailiyah Fuel Tank', 'Red SAM SHORAD SA-19 2', 'Red SAM SHORAD SA-8','Al Ismailiyah HQ bulding', 'Red SAM SHORAD SA-8 2', 'Red SAM SHORAD SA-19'}
	},
	airfieldBen = {
		blue = {'bluePD1'},
		red = {'Ground Forces 1', 'Ground Armour', 'Ground Armour 3', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-19 2', 'Red SAM SHORAD SA-8 2', 'Red SAM SHORAD SA-19'}
	},
	airfield2hat = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'FixedredInfantry1-1', 'Red SAM SHORAD SA-8 2', 'Ground Armour', 'Ground Armour 3', 'Red SAM AAA', 'Red SAM SHORAD SA-8', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Kedem Fuel tanks', 'Kedem Fuel tanks 2','Kedem Fuel tanks 3','Kedem Fuel tanks 4'}
	},
	airfield3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Ground Forces 2', 'Red SAM AAA', 'Ground Armour 2', 'Ground Armour 3','Red SAM SHORAD SA-19 2','Red SAM SHORAD SA-15 2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15'}
	},
	airfield3nevatim = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Ground Forces 2', 'Red SAM AAA', 'Ground Armour 2', 'Ground Armour 3','Red SAM SHORAD SA-15 2','Red SAM SHORAD SA-19 2', 'Red SAM AAA 2', 'Nevatim Command Center', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15'}
	},
	Melez = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1', 'bluePATRIOT'},
		red = {'Ground Forces 2', 'Melez Ammo Depo', 'Ground Armour', 'Ground Armour 3', 'Red SAM SHORAD SA-19 2', 'Red SAM AAA','Red SAM SHORAD SA-15 2', 'Melez HQ bulding','Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Melez Fuel Tank', 'Red SAM SHORAD SA-15'}
	},
	airfield4 = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Ground Forces 2', 'Ground Armour', 'Ground Armour 3','Red SAM SHORAD SA-15 2', 'Red SAM SHORAD SA-8 2', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8'}
	},
	Wadi = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Ground Forces 2', 'Ground Armour', 'Ground Armour 3', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8 2','Red SAM SHORAD SA-15 2', 'Wadi Al Jandali main building', 'Red SAM SHORAD SA-8', 'Wadi Al Jandali Com tower'}
	},
	RamonAirbase = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Ground Forces 2','Ramon Airbase Training Center','Red SAM SHORAD SA-15 2', 'Red SAM AAA', 'Ground Armour 2', 'Ground Armour 3', 'Ramon Airbase HQ bulding','Red SAM SHORAD SA-8', 'Red SAM AAA 2', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8 2'}
	},
	Baluza = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Ground Forces 2','Ground Armour', 'Ground Armour 3', 'Red SAM AAA','Red SAM SHORAD SA-15 2','Red SAM SHORAD SA-8', 'Red SAM AAA 2', 'Baluza HQ', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8 2'}
	},
	startbase = {
		blue = {'blueInfantry'},
		red = {'Ground Forces 2', 'Red SAM AAA','Red SAM SHORAD SA-15 2', 'Red SAM SHORAD SA-8 2','Red SAM AAA 2', 'Ground Armour 2', 'Ground Armour 3', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8'}
	},
	startbase2 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Ground Forces 2', 'Ground Armour', 'Ground Armour 3', 'Red SAM AAA 2','Red SAM SHORAD SA-15 2', 'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8'}
	},

	sam1bravo = {
        blue = {'bluePD1', 'BLUE SAM Fixed NASAMS Bravo'},
        red = {'Red SAM AAA Fixed Bravo - 1', 'Red SAM AAA Fixed Bravo - 2', 'Red SAM SHORAD SA-8 Fixed Bravo - 1', 'Red SAM SHORAD SA-8 Fixed Bravo - 2', 'Red SAM SA-2 Fixed Bravo'}
    },
	sam1delta = {
        blue = {'bluePD1', 'BLUE SAM Fixed NASAMS Delta'},
        red = {'Red SAM AAA Fixed Delta - 1', 'Red SAM AAA Fixed Delta - 2', 'Red SAM SHORAD SA-15 Fixed Delta - 1', 'Red SAM SHORAD SA-15 Fixed Delta - 2', 'Red SAM Fixed SA-2 Delta'}
    },

	  sam2echo = {
        blue = {'bluePD2', 'BLUE SAM Fixed NASAMS Echo'},
        red = {'Red SAM AAA Fixed Echo', 'Red SAM SHORAD SA-19 Fixed Echo - 1', 'Red SAM SHORAD SA-19 Fixed Echo - 2' ,'Red SAM SHORAD SA-19 Fixed Echo - 3', 'Red SAM SA-3 Fixed Echo'}
    },

	  sam3alpha = {
        blue = {'bluePD1', 'BLUE SAM Fixed Hawk Alpha'},
        red = {'Red SAM SHORAD Fixed Alpha', 'Red SAM SA-6 Fixed Alpha'}
    },
	 sam3foxtrot = {
        blue = {'bluePD1', 'BLUE SAM Fixed HAWK Foxtrot'},
        red = {'Red SAM AAA Fixed Foxtrot', 'Red SAM SHORAD SA-15 Fixed Foxtrot - 1', 'Red SAM SHORAD SA-15 Fixed Foxtrot - 2', 'Red SAM SA-6 Fixed Foxtrot'}
    },
    sam4hotel = {
        blue = {'bluePD2', 'BLUE SAM Fixed HAWK Hotel'},
        red = {'Red SAM AAA Fixed Hotel', 'Red SAM SHORAD SA-15 Fixed Hotel - 1', 'Red SAM SHORAD SA-15 Fixed Hotel - 2', 'Red SAM SA-10 Fixed Hotel'}
    },
    sam4golf = {
        blue = {'bluePD2', 'BLUE SAM Fixed HAWK Golf'},
        red = {'Red SAM AAA Fixed', 'Red SAM SHORAD SA-15 Fixed Golf - 1', 'Red SAM SHORAD SA-15 Fixed Golf - 2', 'Red SAM SA-10 Fixed Golf'}
    },
    sam4echo = {
        blue = {'bluePD2', 'BLUE SAM Fixed HAWK Echo'},
        red = {'Red SAM AAA Fixed Echo', 'Red SAM SHORAD SA-19 Fixed Echo', 'Red SAM Fixed SA-10 Echo'}
    },
    sam5juliett = {
        blue = {},
        red = {'Red SAM SHORAD Fixed Juliett', 'Red SAM SA-11 Fixed Juliett'}
    },
	 sam5missileFactory = {
        blue = {'bluePD1', 'bluePATRIOT'},
        red = {'Red SAM SHORAD Fixed Missile Factory', 'Red SAM SA-11 Fixed Missile Factory', 'Fixed-Scuds'}
    },
    sam5Charlie = {
        blue = {'bluePD1', 'BLUE SAM Fixed PATRIOT Charlie'},
        red = {'Red SAM AAA Fixed Charlie', 'Red SAM SHORAD SA-8 Fixed Charlie - 1', 'Red SAM SHORAD SA-8 Fixed Charlie - 2', 'Red SAM SA-11 Fixed Charlie'}
    },
    sam6india = {
        blue = {},
        red = {'Red SAM SHORAD SA-8 Fixed India', 'Red SAM SHORAD SA-15 Fixed India', 'Red SAM Fixed SA-5 India'}
	},
	farp1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Red SAM SHORAD SA-8 2', 'Ground Armour', 'Ground Armour 3', 'Red SAM SHORAD SA-8'}
	},
	Alpha = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Alpha Container', 'Alpha Fuel Tank', 'Alpha Fuel Tank 2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-8 2', 'Ground Forces 1', 'Red SAM AAA', 'Ground Armour', 'Ground Armour 3', 'Red SAM SHORAD SA-8'}
	},
	farp2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Red SAM AAA', 'Ground Armour', 'Ground Armour 3', 'Red SAM SHORAD SA-19', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19 2'}
	},
	farp3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Ground Forces 2', 'Red SAM AAA', 'Red SAM SHORAD SA-15 2', 'Ground Armour 2', 'Ground Armour 3', 'Red SAM AAA 2', 'Red SAM AAA 3','Red SAM AAA 4'}
	},
	farp32 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Ground Forces 2', 'Red SAM AAA', 'Red SAM SHORAD SA-15 2', 'Ground Armour 2', 'Ground Armour 3', 'Red SAM AAA 2', 'Red SAM SHORAD SA-15'}
	},
	Charlie = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Ground Forces 2','Red SAM AAA', 'Charlie supplies 2', 'Red SAM SHORAD SA-8 2', 'Red SAM AAA 2', 'Ground Armour 2', 'Ground Armour 3', 'Charlie supplies', 'Red SAM SHORAD SA-8'}
	},
	mission1 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Red SAM SA-3 Fixed Mining', 'Ground Armour Fixed Mining', 'Mining Facility outpost', 'Red SAM AAA Fixed Mining', 'Red SAM SHORAD SA-19 Fixed MiningFacility', 
	'Mining Facility Command Center'}
	},
	
	mission1Ammo = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Scuds Ammunition Depo Fixed', 'Ammunition Depo','Ammunition Depo 2', 'Red SAM SHORAD SA-15 Fixed Ammunition Depo','Ammunition Depo 3', 'Ammunition Depo Storage', 'T-80 Ammunition Depo Fixed', 'Ammo Trucks Ammunition Depo', 'Red SAM AAA Ammunition Depo Fixed'}
	},
	
	TankFactory = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Tank Factory T-90', 'Red SAM SA-6 TankFactory 2 Fixed', 'Red SAM SA-6 TankFactory Fixed', 'Red SAM AAA Fixed TankFactory', 'Tank factory HQ', 'Tank Factory', 'Tank Factory outpost', 
		'Tank Factory Troops garage', 'Tank Factory Command Center', }
	},
	mission2InsurgentCamp = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Fixed-InfantryGroup', 'Insurgent camp tent', 'Insurgent camp storage', 'Fixed-InfantryGroup-2', 'Insurgent camp tent 2', 'Insurgent camp outpost', 'Fixed-Zu23', 'Fixed-Art'}
	
	},
	mission3 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Red SAM SA-6 Fixed Secret tech', 'Red SAM SHORAD SA-15 Fixed Secret tech', 'Fixed-redArmor2', 'Fixed-redArmor1', 'Fixed-redInfantry2', 'Secret Tech Bulding', 'Secret Tech Bulding 2', 'Secret Tech Command Center', 'Secret Tech building HQ', 'Secret Tech Factory'}
			  
	},

	mission3chemsite = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Chemsite Infantry Group Fixed', 'Chemsite Armoured group Fixed', 'Chemsite Armoured group Fixed 2', 'Red SAM SHORAD SA-15 Fixed ChemSite', 'Chemical Tank 1', 'Chemical Tank 2', 'Chemical Tank 3',
		'Chemical Tank 4', 'Chemical Factory 1', 'Chemical Factory 2', 'Chemical Factory 3', 'Chemical Factory 4'}
	},
	mission4 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Ground Forces 2', 'Artilliary MRL FDDM Fixed', 'Artillery Factory building', 'Ground Armour 2','Artilliary 9K57 Uragan Fixed', 'Red SAM SHORAD SA-8', 'Artilliary MLRS 9A52 Smerch Fixed'}
	},
	
	mission4fueldepo = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'FuelDepo fuel tank', 'FuelDepo fuel tank 2', 'Red SAM AAA Fuel', 'FuelDepo fuel tank 3', 'FuelDepo fuel tank 4', 'FuelDepo fuel tank 5', 'Red SAM SHORAD SA-19 Fixed-Fuel3', 'Red SAM SHORAD SA-15 Fixed-Fuel4', 'FuelDepo fuel tank 6', 'Pump station', 'Pump station 2', 'Pump station 3'}
	},
	portsaidFixed = {
		blue = {},
		red = {'Fixed-redInfantry Port Said', 'Fixed-redArmor Port Said_1', 'Red SAM SHORAD SA-15 Fixed Port Said', 'Red SAM SA-6 Fixed Port Said', 'Fixed-redArmor Port Said', 'Naval-Group-Fixed-PortSaid'}
	},
	borjoilFixed = {
		blue = {},
		red = {'Red SAM SA-6 Fixed Borj Oil production', 'Red SAM SHORAD SA-15 Fixed Borj Oil production', 'Fixed-redInfantry Borj Oil production-1', 
		'Fixed-redInfantry Borj Oil production', 'Borj Oil production 4', 'Borj Oil production 3', 'Borj Oil production 2', 'Borj Oil production 1', 
		'Borj Oil production 5', 'Borj Oil production 6'}
	
	},
	HiddenFixed_Disabled = {
		blue = {},
		red = {'Red EWR Ramon Airbase Fixed', 'Red EWR Tech Fixed', 'Red EWR Bir Hasnah Fixed', 'Red EWR Cairo Fixed', 
		'Red EWR FARP Hotel Fixed', 'Red EWR Juliett-Mike Fixed', 'Red SAM SA-3 Fixed Hidden1', 'Red SAM SA-3 Fixed Hidden2', 
		'Red SAM SA-3 Fixed Hidden3', 'Red SAM SA-3 Fixed Hidden4', 'Red SAM SA-6 Fixed Hidden5', 'Red SAM SA-6 Fixed Hidden6', 
		'Red SAM SA-6 Fixed Hidden7', 'Red SAM SA-6 Fixed Hidden8', 'Red SAM SA-6 Fixed Hidden9'}
	},
	HiddenFixed = {
		blue = {},
		red = {'Red EWR Ramon Airbase Fixed', 'Red EWR Tech Fixed', 'Red EWR Bir Hasnah Fixed', 'Red EWR Cairo Fixed', 
				'Red EWR FARP Hotel Fixed', 'Red EWR Juliett-Mike Fixed', 'HQ Fixed'}
	}
}

flavor = {
	bluecarrier = 'WPT \nStart zone',
	redcarrier = 'WPT 15\nEnemy carrier zone',
	sdedov = 'WPT \n',
	bengurion = 'WPT 1\n',
	palmahim = 'WPT \n',
	telnof = 'WPT \n',
	hatzor = 'WPT 2\n',
	kedemhatzerim = 'WPT 3\n',
	nevatim = 'WPT 4\n',
	ramonairbase = 'WPT 5\n',
	elgora = 'WPT 9\n',
	elarish = 'WPT 10\n',
	ovda = 'WPT 7\n',
	birhasanah = 'WPT 13\n',
	melez = 'WPT 12\n',
	baluza = 'WPT 14\n',
	assalihiyah = 'WPT 16\n',
	alismailiyah = 'WPT 17\n',
	kibritairbase = 'WPT 18\n',
	almansurah = 'WPT 23\n',
	azzaqaziq = 'WPT 22\n',
	inshasairbase = 'WPT 21\n',
	cairointernationalairport = 'WPT 20\n',
	wadialjandali = 'WPT 19\n',
	cairowest = 'WPT 28\n',
	benisuef = 'WPT 30\n',
	gebelelbasur = 'WPT 27\n',
	komawshim = 'WPT 29\n',
	birmaairbase = 'WPT 24\n',
	farpalpha = 'WPT 6\n',
	farpbravo = 'WPT 8\n',
	farpcharlie = 'WPT 11\n',
	
	miningfacility = 'Check kneeboard for coordinates.\n',
	insurgentcamp = 'Check kneeboard for coordinates.\nDestroy the Insurgents and we will add to your bank 500 credits',
	secrettechfacility = 'Check kneeboard for coordinates.\nDestroy the buildings and area completly',
	fueldepo = 'Check kneeboard for coordinates.\nTake out their Fuel Depo including the fuel tanks',
	ammonitiondepo = 'Check kneeboard for coordinates.\nTake out their ammunition Depo including the storage',
	tankfactory = 'Check kneeboard for coordinates.\nDestroy the factorys and the tank storage',
	chemsite = 'Check kneeboard for coordinates.\nHere they are building chemical weapons. Destroy the buildings',
	artilleryfactory = 'Check kneeboard for coordinates.\n',
	missilefactory = 'Check kneeboard for coordinates.\nRumors say they have Scuds here',
	portsaid = 'Check kneeboard for coordinates.\nDestroy the port',
	borjoil = 'Check kneeboard for coordinates.\nDestroy the militant target in that area.',
	
	
	
	samalpha = 'Check kneeboard for coordinates.\nFriendly SAM',
	sambravo = 'Check kneeboard for coordinates.\nSA-2 and Red SAM SHORAD',
	samcharlie = 'Check kneeboard for coordinates.\nSA-11 and Red SAM SHORAD',
	samdelta = 'Check kneeboard for coordinates.\nSA-2 and Red SAM SHORAD',
	samecho = 'Check kneeboard for coordinates.\nSA-3 and Red SAM SHORAD',
	samfoxtrot = 'Check kneeboard for coordinates.\nSA-6 and Red SAM SHORAD',
	samgolf = 'Check kneeboard for coordinates.\nSA-10 and Red SAM SHORAD',
	samhotel = 'Check kneeboard for coordinates.\nSA-10 and Red SAM SHORAD',
	samindia = 'Check kneeboard for coordinates.\nSA-5 and Red SAM SHORAD',
	Juliett = 'Check kneeboard for coordinates.\nSA-10 and Red SAM SHORAD'

}

WaypointList = {
    ["Ben-Gurion"] = ' (1)',
    Hatzor = ' (2)',
    ["Kedem-Hatzerim"] = ' (3)',
    Nevatim = ' (4)',
    ["Ramon Airbase"] = ' (5)',
    ["FARP-Alpha"] = ' (6)',
    Ovda = ' (7)',
    ["FARP-Bravo"] = ' (8)',
    ["El Gora"] = ' (9)',
    ["El Arish"] = ' (10)',
    ["FARP-Charlie"] = ' (11)',
    Melez = ' (12)',
    ["Bir Hasanah"] = ' (13)',
    Baluza = ' (14)',
    ["Red Carrier"] = ' (15)',
    ["As Salihiyah"] = ' (16)',
    ["Al Ismailiyah"] = ' (17)',
    ["Kibrit Air Base"] = ' (18)',
    ["Wadi al Jandali"] = ' (19)',
    ["Cairo International Airport"] = ' (20)',
    ["Inshas Airbase"] = ' (21)',
    ["AzZaqaziq"] = ' (22)',
    ["Al Mansurah"] = ' (23)',
    ["Birma Air Base"] = ' (24)',
    ["Jiyanklis Air Base"] = ' (25)',
    ["Borg El Arab International Airport"] = ' (26)',
    ["Gebel El Basur Air Base"] = ' (27)',
    ["Cairo West"] = ' (28)',
    ["Kom Awshim"] = ' (29)',
    ["Beni Suef"] = ' (30)',
}

FootholdSaveBaseName = (Era == 'Coldwar') and 'FootHold_SI_North_v0.1_Coldwar' or 'FootHold_SI_North_v0.1_Modern'

local filepath = FootholdSaveBaseName .. '.lua'
if lfs then
  FootholdSavePath = FootholdSavePath or (lfs.writedir()..'Missions/Saves')
  lfs.mkdir(FootholdSavePath)
  filepath = FootholdSavePath .. '/' .. (FootholdSaveBaseName .. '.lua')
  env.info('Foothold - Save file path: '..filepath)
end


local cwSwap = {
	['Ground Armour']   = 'Red Armor Group6',
	['Ground Armour 2']   = 'Red Armor Group7',
	['Ground Armour 3']  = 'Red Armor Group8',
	['bluePATRIOT']  = 'bluePATRIOT-Coldwar',
	['blueHAWK']  = 'blueHAWK Coldwar',
	['blueArmor Coldwar']  = 'blueArmor Coldwar',
	['Neustrashimy']  = 'Rezky',
	['Tank Factory T-90']  = 'Tank Factory-T55',
	['T-80 Ammunition Depo Fixed']  = 'T-55 Ammunition Depo Fixed',
	['Red SAM SHORAD SA-15 Fixed Secret tech']  = 'Red SAM SHORAD SA-8 Fixed Secret tech',
	['Fixed-redArmor1']  = 'Fixed-redArmor1-T55',
	['Red SAM SHORAD SA-15 Fixed-Fuel4']  = 'Red SAM SHORAD SA-8 Fixed-Fuel4',
	['Fixed-Fuel5']  = 'Fixed-Fuel5-T55',
	['Chemsite Armoured group Fixed']  = 'Chemsite Armoured group Fixed-T55',
	['Chemsite Armoured group Fixed 2']  = 'Chemsite Armoured group Fixed 2-T55',


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
	['Red SAM SA-11 Fixed Charlie'] = 'Red SAM SA-6 Fixed Charlie',
	['Red SAM SA-10 Fixed Golf'] = 'Red SAM SA-2 Fixed Golf',
	['Red SAM SA-10 Fixed Hotel'] = 'Red SAM SA-2 Fixed Hotel',
	['Red SAM SA-11 Fixed Juliett'] = 'Red SAM SA-2 Fixed Juliett',
	['Red SAM SHORAD SA-8']  = {'Red SAM AAA 4','Red SAM AAA 3'},
	['Red SAM SHORAD SA-15'] = 'Red SAM SHORAD SA-8',
	['Red SAM SHORAD SA-15 2'] = 'Red SAM SHORAD SA-8 2',
	['Red SAM SHORAD SA-15 Fixed Ammunition Depo'] = 'Red SAM SHORAD SA-8 Fixed Ammunition Depo',
	['Red SAM SHORAD SA-15 Fixed Borj Oil production'] = 'Red SAM SHORAD SA-8 Fixed Borj Oil production',
	['Red SAM SHORAD SA-15 Fixed Foxtrot - 2']  = 'Red SAM SHORAD SA-8 Fixed Foxtrot - 2',
	['Red SAM SHORAD SA-15 Fixed Foxtrot - 1']  = 'Red SAM SHORAD SA-19 Fixed Foxtrot - 1',
	['Red SAM SHORAD SA-15 Fixed Hotel - 2']  = 'Red SAM SHORAD SA-8 Fixed Hotel - 2',
	['Red SAM SHORAD SA-15 Fixed Hotel - 1']  = 'Red SAM SHORAD SA-8 Fixed Hotel - 1',
	['Red SAM SHORAD SA-15 Fixed Golf - 1']  = 'Red SAM SHORAD SA-8 Fixed Golf - 1',
	['Red SAM SHORAD SA-15 Fixed Golf - 2']  = 'Red SAM SHORAD SA-8 Fixed Golf - 2',
	['Red SAM SHORAD SA-15 Fixed India']  = 'Red SAM SHORAD SA-8 Fixed India 2',
	['Red SAM SHORAD SA-15 Fixed ChemSite']  = 'Red SAM SHORAD SA-8 Fixed ChemSite',
	

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
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
env.info('Foothold - Rank file path: '..bc.rankFile)
end
Hunt = true

zones = {
	redcarrier = ZoneCommander:new		({zone='Red Carrier', side=1, level=10, upgrades=upgrades.redships, crates={}, flavorText=flavor.redcarrier}),
	bluecarrier = ZoneCommander:new		({zone='Blue Carrier', side=2, level=20, upgrades=upgrades.blueships, crates={}, flavorText=flavor.bluecarrier}),
	
	sdedov = ZoneCommander:new			({zone='Sde Dov', side=2, level=2, upgrades=upgrades.startbase2, crates={}, flavorText=flavor.sdedov}),
	bengurion = ZoneCommander:new		({zone='Ben-Gurion', side=2, level=20, upgrades=upgrades.airfieldBen, crates={}, flavorText=flavor.bengurion}),
	palmahim = ZoneCommander:new		({zone='Palmahim', side=2, level=20, upgrades=upgrades.startbase, crates={}, flavorText=flavor.palmahim}),
	telnof = ZoneCommander:new			({zone='Tel Nof', side=2, level=20, upgrades=upgrades.startbase, crates={}, flavorText=flavor.telnof}),
	hatzor = ZoneCommander:new			({zone='Hatzor', side=2, level=20, upgrades=upgrades.startbase, crates={}, flavorText=flavor.hatzor}),
	kedemhatzerim = ZoneCommander:new	({zone='Kedem-Hatzerim', side=1, level=20, upgrades=upgrades.airfield2hat, crates={}, flavorText=flavor.kedemhatzerim}),
	nevatim = ZoneCommander:new			({zone='Nevatim', side=1, level=20, upgrades=upgrades.airfield3nevatim, crates={}, flavorText=flavor.nevatim}),
	ramonairbase = ZoneCommander:new	({zone='Ramon Airbase', side=1, level=20, upgrades=upgrades.RamonAirbase, crates={}, flavorText=flavor.ramonairbase}),
	elgora = ZoneCommander:new			({zone='El Gora', side=1, level=20, upgrades=upgrades.ElGoraUpgrade, crates={}, flavorText=flavor.elgora}),
	elarish = ZoneCommander:new			({zone='El Arish', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.elarish}),
	ovda = ZoneCommander:new			({zone='Ovda', side=1, level=20, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.ovda}),
	birhasanah = ZoneCommander:new		({zone='Bir Hasanah', side=1, level=2, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.birhasanah}),
	melez = ZoneCommander:new			({zone='Melez', side=1, level=20, upgrades=upgrades.Melez, crates={}, flavorText=flavor.melez}),
	baluza = ZoneCommander:new			({zone='Baluza', side=1, level=20, upgrades=upgrades.Baluza, crates={}, flavorText=flavor.baluza}),
	assalihiyah = ZoneCommander:new		({zone='As Salihiyah', side=1, level=20, upgrades=upgrades.airfield1, crates={}, flavorText=flavor.assalihiyah}),
	alismailiyah = ZoneCommander:new	({zone='Al Ismailiyah', side=1, level=10, upgrades=upgrades.airfield2Ismailiyah, crates={}, flavorText=flavor.alismailiyah}),
	kibritairbase = ZoneCommander:new	({zone='Kibrit Air Base', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.kibritairbase}),
	almansurah = ZoneCommander:new		({zone='Al Mansurah', side=1, level=20, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.almansurah}),
	azzaqaziq = ZoneCommander:new		({zone='AzZaqaziq', side=1, level=20, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.azzaqaziq}),
	inshasairbase = ZoneCommander:new	({zone='Inshas Airbase', side=1, level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.inshasairbase}),
	cairointernationalairport = ZoneCommander:new	({zone='Cairo International Airport', side=1, level=20, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.cairointernationalairport}),
	wadialjandali = ZoneCommander:new	({zone='Wadi al Jandali', side=1, level=20, upgrades=upgrades.Wadi, crates={}, flavorText=flavor.wadialjandali}),
	cairowest = ZoneCommander:new		({zone='Cairo West', side=1, level=20, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.cairowest}),
	benisuef = ZoneCommander:new		({zone='Beni Suef', side=1, level=20, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.benisuef}),
	komawshim = ZoneCommander:new		({zone='Kom Awshim', side=1, level=20, upgrades=upgrades.farp2, crates={}, flavorText=flavor.komawshim}),
	gebelelbasur = ZoneCommander:new	({zone='Gebel El Basur Air Base', side=1, level=20, upgrades=upgrades.farp32, crates={}, flavorText=flavor.gebelelbasur}),
	birmaairbase = ZoneCommander:new	({zone='Birma Air Base', side=1, level=20, upgrades=upgrades.farp3, crates={}, flavorText=flavor.birmaairbase}),
	jiyanklisairbase = ZoneCommander:new	({zone='Jiyanklis Air Base', side=1, level=20, upgrades=upgrades.farp3, crates={}, flavorText=flavor.jiyanklisairbase}),
	borgelarab = ZoneCommander:new		({zone='Borg El Arab International Airport', side=1, level=20, upgrades=upgrades.farp3, crates={}, flavorText=flavor.borgelarab}),

	farpalpha = ZoneCommander:new	({zone='FARP-Alpha', side=1, level=20, upgrades=upgrades.Alpha, crates={}, flavorText=flavor.farpalpha}),
	farpbravo = ZoneCommander:new	({zone='FARP-Bravo', side=1, level=10, upgrades=upgrades.farp3, crates={}, flavorText=flavor.farpbravo}),
	farpcharlie = ZoneCommander:new	({zone='FARP-Charlie', side=1, level=20, upgrades=upgrades.Charlie, crates={}, flavorText=flavor.farpcharlie}),
	
	
	miningfacility = ZoneCommander:new({zone='MiningFacility', side=1, level=20, upgrades=upgrades.mission1, crates={}, flavorText=flavor.miningfacility}),
	insurgentcamp = ZoneCommander:new({zone='InsurgentCamp', side=1, level=25, upgrades=upgrades.mission2InsurgentCamp, crates={}, flavorText=flavor.insurgentcamp}),
	secrettechfacility = ZoneCommander:new({zone='SecretTechFacility', side=1, level=25, upgrades=upgrades.mission3, crates={}, flavorText=flavor.secrettechfacility}),
	fueldepo = ZoneCommander:new({zone='FuelDepo', side=1, level=25, upgrades=upgrades.mission4fueldepo, crates={}, flavorText=flavor.fueldepo}),
	ammonitiondepo = ZoneCommander:new({zone='AmmonitionDepo', side=1, level=20, upgrades=upgrades.mission1Ammo, crates={}, flavorText=flavor.ammonitiondepo}),
	tankfactory = ZoneCommander:new({zone='TankFactory', side=1, level=20, upgrades=upgrades.TankFactory, crates={}, flavorText=flavor.tankfactory}),
	chemsite = ZoneCommander:new({zone='ChemSite', side=1, level=25, upgrades=upgrades.mission3chemsite, crates={}, flavorText=flavor.chemsite}),
	artilleryfactory = ZoneCommander:new({zone='ArtilleryFactory', side=1, level=20, upgrades=upgrades.mission4, crates={}, flavorText=flavor.artilleryfactory}),
	missilefactory = ZoneCommander:new({zone='MissileFactory', side=1, level=20, upgrades=upgrades.sam5missileFactory, crates={}, flavorText=flavor.missilefactory}),
	portsaid = ZoneCommander:new({zone='Port Said', side=1, level=20, upgrades=upgrades.portsaidFixed, crates={}, flavorText=flavor.portsaid}),
	borjoil = ZoneCommander:new({zone='Borj Oil production Site', side=1, level=20, upgrades=upgrades.borjoilFixed, crates={}, flavorText=flavor.borjoil}),
	
	hidden1 = ZoneCommander:new({zone='Hidden1', side=1, level=15, upgrades=upgrades.HiddenFixed, crates={}, flavorText=flavor.hidden1}),

	
	
	samalpha = ZoneCommander:new	({zone='SAM-Alpha', side=2, level=20, upgrades=upgrades.sam3alpha, crates={}, flavorText=flavor.samalpha}),
	sambravo = ZoneCommander:new	({zone='SAM-Bravo', side=1, level=20, upgrades=upgrades.sam1bravo, crates={}, flavorText=flavor.sambravo}),
	samcharlie = ZoneCommander:new	({zone='SAM-Charlie', side=1, level=20, upgrades=upgrades.sam5Charlie, crates={}, flavorText=flavor.samcharlie}),
	samdelta = ZoneCommander:new	({zone='SAM-Delta', side=1, level=20, upgrades=upgrades.sam1delta, crates={}, flavorText=flavor.samdelta}),
	samecho = ZoneCommander:new		({zone='SAM-Echo', side=1, level=20, upgrades=upgrades.sam2echo, crates={}, flavorText=flavor.samecho}),
	samfoxtrot = ZoneCommander:new	({zone='SAM-Foxtrot', side=1, level=20, upgrades=upgrades.sam3foxtrot, crates={}, flavorText=flavor.samfoxtrot}),
	samhotel = ZoneCommander:new	({zone='SAM-Hotel', side=1, level=20, upgrades=upgrades.sam4hotel, crates={}, flavorText=flavor.samhotel}),
	samgolf = ZoneCommander:new		({zone='SAM-Golf', side=1, level=20, upgrades=upgrades.sam4golf, crates={}, flavorText=flavor.samgolf}),
	samindia = ZoneCommander:new	({zone='SAM-India', side=1, level=20, upgrades=upgrades.sam6india, crates={}, flavorText=flavor.samindia}),
	samjuliett = ZoneCommander:new	({zone='SAM-Juliett', side=1, level=20, upgrades=upgrades.sam5juliett, crates={}, flavorText=flavor.samjuliett}),

}

if Era == "Coldwar" then
    CapPlaneTemplate = CapPlaneTemplate or {
        'RED_MIG29A',
        'RED_SU27_EW',
        'RED_MIG21Bis',
        'RED_MIG23MLD',
        'RED_MIG25PD',
		'RED_F4',
        'BLUE_HORNET_CW',
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
		'BLUE-F16-CAS',
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

PlaneSupplyTemplate = PlaneSupplyTemplate or {
	"IL-76MD",
	"IL-78M",
	"C-130",
	"C-130-2",
	"AN-30M",
}

AntiShipPlaneTemplate = AntiShipPlaneTemplate or {
	--"Viggen_Blue",
	"Hornet_Anti_Ship"
}

function CasAltitude() return math.random(15,25)*1000 end
function CapAltitude() return math.random(22,32)*1000 end
function SeadAltitude() return math.random(25,33)*1000 end
function RunwayStrikeAltitude() return math.random(23,28)*1000 end

zones.bengurion:addGroups({
    GroupCommander:new({name = 'bengurion-Support-Kedem', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Kedem-Hatzerim'}),
    GroupCommander:new({name = 'bengurion-Support-Nevatim', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Nevatim'}),
    GroupCommander:new({name = 'bengurion-Support-Ramon Airbase', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Ramon Airbase'}),
})

zones.hatzor:addGroups({
    GroupCommander:new({name = 'Hatzor-Support-Kedem', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Kedem-Hatzerim'}),
    GroupCommander:new({name = 'Hatzor-Support-SAM-Alpha', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Alpha'}),
    GroupCommander:new({name = 'Hatzor-Attack-Kedem', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'Kedem-Hatzerim'}),
    GroupCommander:new({name = 'Hatzor-Attack-Kedem-Hatzerim-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Kedem-Hatzerim', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Hatzor-Attack-SAM-Alpha-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Alpha', Altitude = SeadAltitude()})
})
zones.elgora:addGroups({
    GroupCommander:new({name = 'El-Gora-Support-El-Arish', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'El Arish'}),
    GroupCommander:new({name = 'El-Gora-Attack-El Arish-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'El Arish', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'El-Gora-Attack-Red Carrier-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'Red Carrier', Altitude = SeadAltitude()})
})
zones.farpalpha:addGroups({
    GroupCommander:new({name = 'Farp-Alpha-Supply-FARP-Bravo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Bravo'}),
    GroupCommander:new({name = 'Farp-Alpha-Supply-Ovda', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Ovda'})
})

zones.farpcharlie:addGroups({
    GroupCommander:new({name = 'Farp-Charlie-Supply-Baluza', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Baluza'}),
    GroupCommander:new({name = 'Farp-Charlie-supply-Melez', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Melez'})
})

zones.kedemhatzerim:addGroups({
    GroupCommander:new({name = 'Kedem-Support-Nevatim', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Nevatim'}),
    GroupCommander:new({name = 'Kedem-Support-El Gora', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'El Gora'}),
    GroupCommander:new({name = 'Kedem-Support-Ramon', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Ramon Airbase'}),
    GroupCommander:new({name = 'Hatzerim-Attack-Hatzor', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'Hatzor'}),
    GroupCommander:new({name = 'Hatzerim-Support-Hatzor', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Hatzor'}),
    GroupCommander:new({name = 'Hatzerim-Attack-SAM-Bravo-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Bravo', Altitude = SeadAltitude()})
})
zones.nevatim:addGroups({
    GroupCommander:new({name = 'nevatim-Support-El Arish', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'El Arish'}),
    GroupCommander:new({name = 'nevatim-Support-OVda', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Ovda'}),
    GroupCommander:new({name = 'nevatim-Support-Melez', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Melez'}),
    GroupCommander:new({name = 'nevatim-Support-Ramon Airbase', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Ramon Airbase'}),
})
zones.birhasanah:addGroups({
    GroupCommander:new({name = 'Bir-Hasanah-Support-SAM-Charlie', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Charlie'}),
	GroupCommander:new({name = 'Bir Hasanah-Attack-Melez-CasHelo', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'Melez'})

})
zones.ramonairbase:addGroups({
    GroupCommander:new({name = 'Ramon-Attack-Hatzor', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Hatzor', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'Ramon-Attack-Kedem', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'Kedem-Hatzerim'}),
    GroupCommander:new({name = 'Ramon-Supply-Kedem', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Kedem-Hatzerim'}),
    GroupCommander:new({name = 'Ramon-Supply-Nevatim', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Nevatim'}),
    GroupCommander:new({name = 'Ramon-Supply-El Gora', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'El Gora'}),
    GroupCommander:new({name = 'Ramon-Supply-SAM-Bravo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Bravo'}),
    GroupCommander:new({name = 'Ramon-Patrol-Kedem', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Kedem-Hatzerim', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Ramon-Patrol-Kedem', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Nevatim', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Ramon-Supply-Farp-Alpha', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Alpha'}),
    GroupCommander:new({name = 'Ramon-Attack-Melez', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Melez', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'Ramon-attack-Ovda', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Ovda', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'Ramon-Attack-Melez-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'Melez', Altitude = SeadAltitude()}),
    GroupCommander:new({name = 'Ramon-Attack-Ovda-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Ovda', Altitude = RunwayStrikeAltitude()})
})
zones.ovda:addGroups({
    GroupCommander:new({name = 'Ovda-Attack-Kedem-Cas', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Ramon Airbase', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'Ovda-Support-Ramon', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Ramon Airbase'}),
    GroupCommander:new({name = 'Ovda-Support-FARP-Alpha', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Alpha'}),
    GroupCommander:new({name = 'Ovda-Support-FARP-Bravo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Bravo'}),
    GroupCommander:new({name = 'Ovda-Patrol-Ramon-Airbase-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Ramon Airbase', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Ovda-attack-Ramon-Airbase-Cap', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Ramon Airbase', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Ovda-Attack-El Arish-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'El Arish', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Ovda-Attack-SAM-Bravo-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Bravo', Altitude = SeadAltitude()})
})
zones.melez:addGroups({
    GroupCommander:new({name='Melez-Support-Bir-Hasanah', mission='supply',template='SupplyConvoy', targetzone='Bir Hasanah', type='surface'}),
    GroupCommander:new({name='Melez-Support-Sam-Delta', mission='supply',template='SupplyConvoy', targetzone='SAM-Delta', type='surface'}),
    GroupCommander:new({name='Melez-Support-Nevrim', mission='supply',template='PlaneSupplyTemplate', targetzone='Nevatim'}),
    GroupCommander:new({name='Melez-Support-Ramon Airbase', mission='supply',template='PlaneSupplyTemplate', targetzone='Ramon Airbase'}),
    GroupCommander:new({name='Melez-patrol-El-Arish-Cap', mission='patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone='El Arish', Altitude = CapAltitude()}),
    GroupCommander:new({name='Melez-Attack-Ramon-Airbase-Cas', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Ramon Airbase', Altitude = CasAltitude()}),
    GroupCommander:new({name='Melez-Support-Bir Hasanah', mission='supply',template='HeloSupplyTemplate', targetzone='Bir Hasanah', urgent=zones.birhasanah.side==0}),
    GroupCommander:new({name='Melez-Support-FARP-Charlie', mission='supply',template='HeloSupplyTemplate', targetzone='FARP-Charlie', urgent=zones.farpcharlie.side==0}),
    GroupCommander:new({name='Melez-Attack-Bir Hasanah-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Bir Hasanah',spawnDelayFactor = 1,5}),
    GroupCommander:new({name='Melez-Attack-FARP-Bravo-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='FARP-Bravo',spawnDelayFactor = 3}),
    GroupCommander:new({name='Melez-Attack-FARP-Charlie-Cas', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='FARP-Charlie',spawnDelayFactor = 2}),
    GroupCommander:new({name='Melez-Patrol-Bir Hasanah-Cap', mission='patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone='Bir Hasanah', Altitude = CapAltitude()}),
    GroupCommander:new({name='Melez-Attack-ramon-air-base-Cap', mission='attack',template='CapPlaneTemplate', MissionType='CAP', targetzone='Ramon Airbase', Altitude = CapAltitude()}),
    GroupCommander:new({name='Melez-Support-Al Ismailiyah', mission='supply',template='HeloSupplyTemplate', targetzone='Al Ismailiyah'}),
    GroupCommander:new({name='Melez-support-FARP-kibrit-air-base', mission='supply',template='HeloSupplyTemplate', targetzone='Kibrit Air Base'}),
    GroupCommander:new({name='Melez-patrol-Melez-Cap', mission='patrol',template='CapPlaneTemplate', targetzone='Melez', Altitude = CapAltitude()}),
    GroupCommander:new({name='Melez-Attack-Ramon Airbase-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Ramon Airbase', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name='Melez-Attack-SAM-Charlie-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Charlie', Altitude = SeadAltitude()}),
    GroupCommander:new({name='Melez-Attack-SAM-Delta-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Delta', Altitude = SeadAltitude()})
})

zones.baluza:addGroups({
    GroupCommander:new({name = 'Baluza-Support-SAM-Echo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Echo'}),
    GroupCommander:new({name = 'Baluza-Support-SAM-Echo-Convoy', mission = 'supply',template='SupplyConvoy', targetzone = 'SAM-Echo',type='surface'}),
    GroupCommander:new({name = 'Baluza-Support-Melez', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Melez'}),
    GroupCommander:new({name = 'Baluza-Support-FARP-Charlie', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Charlie'}),
    GroupCommander:new({name = 'Baluza-Attack-El Arish-Cas', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'El Arish', Altitude = CasAltitude(), diceChance = 50}),
    GroupCommander:new({name = 'Baluza-Attack-Melez-Cas', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'Melez'}),
    GroupCommander:new({name = 'Baluza-Support-As-Salihiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'As Salihiyah'}),
})
zones.elarish:addGroups({
    GroupCommander:new({name = 'El-Arish-Patrol-Melez-Cap', mission = 'patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'El-Arish-support-FARP-Charlie', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Charlie'}),
    GroupCommander:new({name = 'El-Arish-Supply-El-Gorah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'El Gora'}),
    GroupCommander:new({name = 'El-Arish-attack-El-Gorah-Convoy', mission = 'attack',template='AttackConvoy', targetzone = 'El Gora',type='surface'}),
    GroupCommander:new({name = 'El-Arish-Attack-Baluza-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Echo', Altitude = SeadAltitude()}),
	GroupCommander:new({name = 'El-Arish-Attack-Baluza-CasHelo', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'Baluza'})
})
zones.almansurah:addGroups({
    GroupCommander:new({name = 'Al Mansurah-Support-Al Salihiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'As Salihiyah'}),
    GroupCommander:new({name = 'Al Mansurah-Support-SAM-Hotel', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Hotel'}),
    GroupCommander:new({name = 'Al Mansurah-Support-AzZaqaziq', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'AzZaqaziq'}),
    GroupCommander:new({name = 'Al Mansurah-attack-Melez-Cas', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Melez', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'Al Mansurah-Support-Birma-Air-Base', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Birma Air Base'}),
    GroupCommander:new({name = 'Al Mansurah-Attack-AzZaqaziq-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'AzZaqaziq', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Al Mansurah-Attack-SAM-Hotel-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Hotel', Altitude = SeadAltitude()}),
	GroupCommander:new({name = 'Al Mansurah-Patrol-AzZaqaziq-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'AzZaqaziq', Altitude = CapAltitude()}),
})

zones.azzaqaziq:addGroups({
    GroupCommander:new({name = 'AzZaqaziq-Patrol-Red Carrier-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Red Carrier', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'AzZaqaziq-Support-As Salihiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'As Salihiyah'}),
    GroupCommander:new({name = 'AzZaqaziq-Support-Al Ismailiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Al Ismailiyah'}),
    GroupCommander:new({name = 'AzZaqaziq-Support-Kibrit', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Kibrit Air Base'}),
    GroupCommander:new({name = 'AzZaqaziq-Attack-As Salihiyah-Cas', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'As Salihiyah'}),
    GroupCommander:new({name = 'AzZaqaziq-Attack-Al Ismailiyah-Cas', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'Al Ismailiyah'}),
    GroupCommander:new({name = 'AzZaqaziq-attack-Melez-Cap', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'AzZaqaziq-Supply-Al-Mansurah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Al Mansurah'}),
    GroupCommander:new({name = 'AzZaqaziq-Supply-gebelelbasur', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Gebel El Basur Air Base'}),
    GroupCommander:new({name = 'AzZaqaziq-Supply-Inshas Airbase', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Inshas Airbase'}),
	GroupCommander:new({name = 'Inshas Airbase-Attack-AzZaqaziq-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'AzZaqaziq', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Inshas Airbase-Attack-Cairo International Airport-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Cairo International Airport', Altitude = RunwayStrikeAltitude()})
})

zones.wadialjandali:addGroups({
    GroupCommander:new({name = 'Wadi-Support-Beni-Suef', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Beni Suef'}),
    GroupCommander:new({name = 'Wadi-Support-Kom-Awshim', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Kom Awshim'}),
    GroupCommander:new({name = 'Wadi-Support-Bilbeis-Inshas Airbase', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Inshas Airbase'}),
    GroupCommander:new({name = 'Wadi-Support-Cairo-International-Airport', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Cairo International Airport'}),
    GroupCommander:new({name = 'Wadi-Attack-kibrit-air-base', mission = 'attack',template='AttackConvoy', targetzone = 'Kibrit Air Base', type = 'surface'}),
    GroupCommander:new({name = 'Wadi-Attack-Melez-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'Melez', Altitude = SeadAltitude()}),
    GroupCommander:new({name = 'Wadi-Attack-Baluza-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'Baluza', Altitude = SeadAltitude()}),
    GroupCommander:new({name = 'Wadi-al-jandali-support-Sam-Golf', mission = 'supply',template='SupplyConvoy', targetzone = 'SAM-Golf', type = 'surface'}),
    GroupCommander:new({name = 'Wadi-Support-Melez', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Melez'}),

})
zones.kibritairbase:addGroups({
    GroupCommander:new({name = 'Kibrit-Air-Base-attack-Melez-Cap', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Kibrit-Air-Base-Support-Wadi-Al-Jandali', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Wadi al Jandali'}),
    GroupCommander:new({name = 'Kibrit-Air-Base-support-Melez', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Melez'}),
    GroupCommander:new({name = 'Kibrit-Air-Base-support-sam-Charlie', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Charlie'}),
    GroupCommander:new({name = 'Kibrit Air Base-Attack-Al Ismailiyah-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Al Ismailiyah', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Kibrit Air Base-Attack-Wadi al Jandali-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Golf', Altitude = SeadAltitude()})
})
zones.alismailiyah:addGroups({
    GroupCommander:new({name = 'ismailiyah-Patrol-Melez-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude(), spawnDelayFactor = 1.5}),
    GroupCommander:new({name = 'ismailiyah-support-assalihiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'As Salihiyah'}),
    GroupCommander:new({name = 'ismailiyah-Attack-Al-Salihiyah', mission = 'attack',template='AttackConvoy', targetzone = 'As Salihiyah', type = 'surface'}),
	GroupCommander:new({name = 'Al Ismailiyah-Attack-Kibrit Air Base-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Kibrit Air Base', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Al Ismailiyah-Attack-SAM-Foxtrot-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Foxtrot', Altitude = SeadAltitude()})
})
zones.assalihiyah:addGroups({
    GroupCommander:new({name = 'AzZaqaziq-Patrol-Red Carrier-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Red Carrier', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'As-Salihiyah-Support-Sam-Foxtrot', mission = 'supply',template='SupplyConvoy', targetzone = 'SAM-Foxtrot', type = 'surface'}),
    GroupCommander:new({name = 'As-Salihiyah-Supply-Baluza', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Baluza'}),
    GroupCommander:new({name = 'As-Salihiyah-supply-al-ismailiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Al Ismailiyah'}),
    GroupCommander:new({name = 'As-Salihiyah-Patrol-Melez-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'As-Salihiyah-attack-Melez-Cap', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'As-Salihiyah-Attack-Ramon-Sead', mission = 'attack',template='SeadPlaneTemplate', MissionType='SEAD', targetzone = 'Ramon Airbase', Altitude = SeadAltitude()}),
    GroupCommander:new({name = 'As-Salihiyah-Supply-AzZaqaziq', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'AzZaqaziq'}),
    GroupCommander:new({name = 'As-Salihiyah-Supply-almansurah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Al Mansurah'})
})


zones.inshasairbase:addGroups({
    GroupCommander:new({name = 'Inshas-Airbase-patrol-al-ismailiyah-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Al Ismailiyah', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Inshas-AirBase-Support-Cairo-International', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Cairo International Airport'}),
    GroupCommander:new({name = 'Inshas-AirBase-Support-Cairo-West', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Cairo West'}),
	GroupCommander:new({name = 'Inshas-Patrol-AzZaqaziq-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'AzZaqaziq', Altitude = CapAltitude()}),
})
zones.komawshim:addGroups({
    GroupCommander:new({name = 'Kom-Awshim-Support-Beni-Suef', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Beni Suef'}),
    GroupCommander:new({name = 'Kom-Awshim-Support-Cairo West', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Cairo West'}),
	GroupCommander:new({name = 'Kom Awshim-Attack-Beni Suef-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Beni Suef', Altitude = RunwayStrikeAltitude()})
})
zones.birmaairbase:addGroups({
    GroupCommander:new({name = 'Birma-Air-Base-attack-Al Ismailiyah-Cap', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Al Ismailiyah', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Birma-Air-Base-Support-jiyanklisairbase', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Jiyanklis Air Base'}),
    GroupCommander:new({name = 'Birma Air Base-Attack-Jiyanklis Air Base-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Jiyanklis Air Base', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Birma Air Base-Attack-SAM-Hotel-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Hotel', Altitude = SeadAltitude()})
})
zones.gebelelbasur:addGroups({
    GroupCommander:new({name = 'gebelelbasur-support-Birma-Air-Base', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Birma Air Base'}),
    GroupCommander:new({name = 'Gebel El Basur Air Base-Attack-Cairo West-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Cairo West', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Gebel El Basur Air Base-Attack-SAM-India-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-India', Altitude = SeadAltitude()})
})
zones.jiyanklisairbase:addGroups({
    GroupCommander:new({name = 'Jiyanklis-Air-Base-patrol-SAM-Hotel-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'SAM-Hotel', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Jiyanklis-Air-Base-Support-borg-el-arab', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Borg El Arab International Airport'}),
    GroupCommander:new({name = 'Jiyanklis Air Base-Attack-Borg El Arab-Airport-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Borg El Arab International Airport', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Jiyanklis Air Base-Attack-Gebel El Basur-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Gebel El Basur Air Base', Altitude = RunwayStrikeAltitude()})
})

zones.cairowest:addGroups({
    GroupCommander:new({name = 'CairoWest-Support-Melez', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Melez'}),
    GroupCommander:new({name = 'CairoWest-Patrol-Wadi-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Wadi al Jandali', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'CairoWest-Patrol-AzZaqaziq-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'AzZaqaziq', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'CairoWest-Support-Wadi', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Wadi al Jandali'}),
    GroupCommander:new({name = 'CairoWest-Patrol-Cario-West-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Cairo West', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Cairo West-Attack-Gebel El Basur Air Base-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Gebel El Basur Air Base', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Cairo West-Attack-Kom Awshim-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Juliett', Altitude = SeadAltitude()})
})

zones.borgelarab:addGroups({
    GroupCommander:new({name = 'borg-el-arab-Support-SAM-India', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-India'}),
    GroupCommander:new({name = 'borg-el-arab-Support-Cairo International Airport', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Cairo International Airport'}),
    GroupCommander:new({name = 'borg-el-arab-Support-Wadi al Jandali', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Wadi al Jandali'}),
    GroupCommander:new({name = 'borg-el-arab-Support-As Salihiyah', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'As Salihiyah'}),
    GroupCommander:new({name = 'borg-el-arab-Support-Al Ismailiyah', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Al Ismailiyah'}),
    GroupCommander:new({name = 'borg-el-arab-patrol-jiyanklis-air-base-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Jiyanklis Air Base', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'borg-el-arab-attack-Gebel El Basur-Cap', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Gebel El Basur Air Base', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Borg El Arab-Attack-Jiyanklis-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Jiyanklis Air Base', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Borg El Arab-Attack-SAM-India-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-India', Altitude = SeadAltitude()})
})

zones.benisuef:addGroups({
    GroupCommander:new({name = 'Beni Suef-Patrol-Kom Awshim-Cap',mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Kom Awshim', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Beni Suef-Attack-Kom Awshim-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Kom Awshim', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Beni Suef-Attack-SAM-Juliett-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'SAM-Juliett', Altitude = SeadAltitude()})
})

function SpawnFriendlyAssets()
	if zones.redcarrier.wasBlue then
		trigger.action.setMarkupTypeLine(zones.bluecarrier.index, 0)
		activateGroupIfNotActive('CVN-73')
		activateGroupIfNotActive('HMS Invincible')
		activateGroupIfNotActive('CVN-59')
		timer.scheduleFunction(function()
		checkWeaponsList('CVN-73')
		checkWeaponsList('HMS Invincible')
		checkWeaponsList('CVN-59')
		end, {}, timer.getTime() + 3)
		destroyGroupIfActive('CVN-72')
		destroyGroupIfActive('CVN-74')
		destroyGroupIfActive('Tarawa')
	end
end
timer.scheduleFunction(SpawnFriendlyAssets, {}, timer.getTime() + 8)


if zones.redcarrier.wasBlue then
zones.bluecarrier.isHeloSpawn = false
else
zones.bluecarrier.isHeloSpawn = true
end
zones.bengurion.isHeloSpawn = true

zones.redcarrier.isHeloSpawn = true

zones.hatzor.isHeloSpawn = true


zones.kedemhatzerim.isHeloSpawn = true
zones.nevatim.isHeloSpawn = true
zones.ramonairbase.isHeloSpawn = true
zones.elgora.isHeloSpawn = true
zones.elarish.isHeloSpawn = true
zones.ovda.isHeloSpawn = true
zones.birhasanah.isHeloSpawn = true
zones.melez.isHeloSpawn = true
zones.baluza.isHeloSpawn = true
zones.assalihiyah.isHeloSpawn = true
zones.alismailiyah.isHeloSpawn = true

zones.kibritairbase.isHeloSpawn = true
zones.almansurah.isHeloSpawn = true
zones.azzaqaziq.isHeloSpawn = true
zones.inshasairbase.isHeloSpawn = true
zones.cairointernationalairport.isHeloSpawn = true
zones.wadialjandali.isHeloSpawn = true
zones.cairowest.isHeloSpawn = true
zones.benisuef.isHeloSpawn = true
zones.gebelelbasur.isHeloSpawn = true
zones.komawshim.isHeloSpawn = true
zones.birmaairbase.isHeloSpawn = true
zones.farpalpha.isHeloSpawn = true
zones.farpbravo.isHeloSpawn = true
zones.farpcharlie.isHeloSpawn = true
zones.jiyanklisairbase.isHeloSpawn = true
zones.borgelarab.isHeloSpawn = true

zones.bengurion.airbaseName = "Ben-Gurion"
zones.telnof.airbaseName = "Tel Nof"
zones.hatzor.airbaseName = "Hatzor"

zones.kedemhatzerim.airbaseName = "Hatzerim"
zones.nevatim.airbaseName = "Nevatim"
zones.ramonairbase.airbaseName = "Ramon Airbase"
zones.elgora.airbaseName = "El Gora"
zones.elarish.airbaseName = "El Arish"
zones.ovda.airbaseName = "Ovda"
zones.birhasanah.airbaseName = "Bir Hasanah"
zones.melez.airbaseName = "Melez"
zones.baluza.airbaseName = "Baluza"
zones.assalihiyah.airbaseName = "As Salihiyah"
zones.alismailiyah.airbaseName = "Al Ismailiyah"
zones.kibritairbase.airbaseName = "Kibrit Air Base"
zones.almansurah.airbaseName = "Al Mansurah"
zones.azzaqaziq.airbaseName = "AzZaqaziq"
zones.inshasairbase.airbaseName = "Inshas Airbase"
zones.cairointernationalairport.airbaseName = "Cairo International Airport"
zones.wadialjandali.airbaseName = "Wadi al Jandali"
zones.cairowest.airbaseName = "Cairo West"
zones.benisuef.airbaseName = "Beni Suef"
zones.gebelelbasur.airbaseName = "Gebel El Basur Air Base"
zones.komawshim.airbaseName = "Kom Awshim"
zones.birmaairbase.airbaseName = "Birma Air Base"
zones.jiyanklisairbase.airbaseName = "Jiyanklis Air Base"
zones.borgelarab.airbaseName = "Borg El Arab International Airport"
zones.farpalpha.airbaseName = "FARP Alpha"
zones.farpbravo.airbaseName = "FARP Bravo"
zones.farpcharlie.airbaseName = "FARP Charlie"

zones.bengurion.LogisticCenter = true
zones.hatzor.LogisticCenter = true

zones.telnof.LogisticCenter = true

function checkAndDisableFriendlyZones()
	
end

timer.scheduleFunction(checkAndDisableFriendlyZones, {}, timer.getTime() + 5)

missions = {

}

for i,v in pairs(zones) do
	bc:addZone(v)
end

bc:addConnection("Blue Carrier","Sde Dov")
bc:addConnection("Sde Dov","Ben-Gurion")
bc:addConnection("Ben-Gurion","Palmahim")
bc:addConnection("Palmahim","Tel Nof")
bc:addConnection("Tel Nof","Hatzor")
bc:addConnection("Hatzor","Kedem-Hatzerim")
bc:addConnection("Hatzor","SAM-Alpha")
bc:addConnection("Kedem-Hatzerim","Nevatim")
bc:addConnection("Kedem-Hatzerim","Ramon Airbase")
bc:addConnection("Nevatim","Ramon Airbase")
bc:addConnection("Ramon Airbase","FARP-Alpha")
bc:addConnection("Ramon Airbase","SAM-Bravo")
bc:addConnection("Ramon Airbase","MiningFacility")
bc:addConnection("FARP-Alpha","Ovda")
bc:addConnection("Ovda","FARP-Bravo")
bc:addConnection("Ovda","SecretTechFacility")
bc:addConnection("Ovda","InsurgentCamp")
bc:addConnection("Ovda","FuelDepo")
bc:addConnection("FARP-Bravo","El Gora")
bc:addConnection("El Gora","El Arish")
bc:addConnection("El Arish","FARP-Charlie")
bc:addConnection("FARP-Charlie","Baluza")
bc:addConnection("FARP-Charlie","Melez")
bc:addConnection("Melez","SAM-Delta")
bc:addConnection("Melez","Bir Hasanah")
bc:addConnection("Bir Hasanah","SAM-Charlie")
bc:addConnection("Bir Hasanah","ChemSite")
bc:addConnection("Baluza","Port Said")
bc:addConnection("Baluza","SAM-Echo")
bc:addConnection("Baluza","Red Carrier")
bc:addConnection("Red Carrier","As Salihiyah")
bc:addConnection("As Salihiyah","Al Ismailiyah")
bc:addConnection("As Salihiyah","SAM-Foxtrot")
bc:addConnection("Al Ismailiyah", "Kibrit Air Base")
bc:addConnection("Kibrit Air Base", "Wadi al Jandali")
bc:addConnection("Wadi al Jandali", "Cairo International Airport")
bc:addConnection("Wadi al Jandali","SAM-Golf")
bc:addConnection("Cairo International Airport", "Inshas Airbase")
bc:addConnection("Inshas Airbase", "AzZaqaziq")
bc:addConnection("AzZaqaziq","Al Mansurah")
bc:addConnection("Al Mansurah","ArtilleryFactory")
bc:addConnection("Al Mansurah","Borj Oil production Site")
bc:addConnection("Al Mansurah","SAM-Hotel")
bc:addConnection("SAM-Hotel","Birma Air Base")
bc:addConnection("Birma Air Base","Jiyanklis Air Base")
bc:addConnection("Jiyanklis Air Base","Borg El Arab International Airport")
bc:addConnection("Borg El Arab International Airport","SAM-India")
bc:addConnection("Borg El Arab International Airport", "Gebel El Basur Air Base")
bc:addConnection("Gebel El Basur Air Base", "Cairo West")
bc:addConnection("Cairo West","MissileFactory")
bc:addConnection("Cairo West", "Kom Awshim")
bc:addConnection("Kom Awshim", "Beni Suef")
bc:addConnection("Beni Suef","SAM-Juliett")
bc:addConnection("Beni Suef","TankFactory")
bc:addConnection("Beni Suef","AmmonitionDepo")

--[[
zones.tankfactory:addCriticalObject('TankFactory1')
zones.tankfactory:addCriticalObject('TankFactory2')
zones.tankfactory:addCriticalObject('TankFactory3')
zones.tankfactory:addCriticalObject('TankFactory4')

zones.fueldepo:addCriticalObject('Fueldepo1')
zones.fueldepo:addCriticalObject('Fueldepo2')
zones.fueldepo:addCriticalObject('Fueldepo3')
zones.fueldepo:addCriticalObject('Fueldepo4')
zones.fueldepo:addCriticalObject('Fueldepo5')
zones.fueldepo:addCriticalObject('Fueldepo6')


zones.chemsite:addCriticalObject('chemsite1')
zones.chemsite:addCriticalObject('chemsite2')
zones.chemsite:addCriticalObject('chemsite3')
zones.chemsite:addCriticalObject('chemsite4')
zones.chemsite:addCriticalObject('chemsite5')
zones.chemsite:addCriticalObject('chemsite6')
zones.chemsite:addCriticalObject('chemsite7')
zones.chemsite:addCriticalObject('chemsite8')

zones.missilefactory:addCriticalObject('missilefactory1')
zones.missilefactory:addCriticalObject('missilefactory2')

zones.secrettechfacility:addCriticalObject('SecretTechFacility1')
zones.secrettechfacility:addCriticalObject('SecretTechFacility2')
zones.secrettechfacility:addCriticalObject('SecretTechFacility3')
zones.secrettechfacility:addCriticalObject('SecretTechFacility4')
zones.secrettechfacility:addCriticalObject('SecretTechFacility5')


zones.ammonitiondepo:addCriticalObject('Ammodepo1')
zones.ammonitiondepo:addCriticalObject('Ammodepo2')
zones.ammonitiondepo:addCriticalObject('Ammodepo3')
zones.ammonitiondepo:addCriticalObject('Ammodepo4')

--]]

Group.getByName('Ramon-Forces-attack'):destroy()
zones.ramonairbase:registerTrigger('captured', function(event,sender)
	local kr = bc:getZoneByName('Ramon Airbase')
	if kr.side == 2 and not CustomFlags['ramonairbasecaptured'] then
		if not IsGroupActive('Ramon-Forces-attack') then
			Respawn.Group('Ramon-Forces-attack')
            CustomFlags['ramonairbasecaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, "Brace!!\n\nEnemy have fired scuds toward Ramon Airbase!!", 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 30)
		end
	end
end, 'ramonairbasecaptured')

Group.getByName('Melez-Forces-attack'):destroy()
zones.melez:registerTrigger('captured', function(event,sender)
	local kr = bc:getZoneByName('Melez')
	if kr.side == 2 and not CustomFlags['melezcaptured'] then
		if not IsGroupActive('Melez-Forces-attack') then
			Respawn.Group('Melez-Forces-attack')
            CustomFlags['melezcaptured'] = true
            timer.scheduleFunction(function()
            trigger.action.outTextForCoalition(2, "Brace!!\n\nEnemy artillery firing toward Melez!", 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 180)
		end
	
	    timer.scheduleFunction(function()
    trigger.action.outTextForCoalition(2, [[We found the enemy Artillery! West of here,

Take them out before they fire again!   

Coordinates:
MGRS: 36 R VU 62964 50158
Lat long: N 30°16'57" E 32°36'53"
Lat long Decimal Minutes: N 30°16.953' E 32°36.894'

Elevation: 444 feet]], 30)
    end, {}, timer.getTime() + math.random(360, 480))
end
end, 'melezcaptured')

zones.tankfactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disabletankfactory2')

zones.fueldepo:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disablefueldepo1')

zones.portsaid:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableportsaid')


zones.secrettechfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disablesecrettechfacility1')

zones.artilleryfactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Artillery Factory disabled\n+500 credits',20)
end, 'disableartilleryfactory')

zones.miningfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Mining Facility cleared\n+500 credits',20)
end, 'disableminingfacility')


zones.ammonitiondepo:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableammonitiondepo2')

zones.insurgentcamp:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Insurgent Camp destroyed, Good job\n+500 credits',20)
end, 'disableinsurgentcamp')


zones.chemsite:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disablechemsite1')

zones.missilefactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Missile Factroy destroyed, Good job\n+500 credits',20)
end, 'disablemissilefactory')

------------------------------------------ SAM DISABLE --------------------------------------------

zones.samhotel:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'SAM Hotel is now destroyed, Good job\n+500 credits',20)
end, 'disablesamhotel')


zones.samindia:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'SAM India is now destroyed, Good job\n+500 credits',20)
end, 'disablesamindia')

------------------------------------------ SAM DISABLE --------------------------------------------

local missionCompleted = false
local checkMissionComplete = function(event, sender)
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
				if bc and bc.saveFile then
					Utils.saveTable(bc.saveFile, 'zonePersistance', {})
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
		"Red SAM AAA 2 #",
		"Red SAM SHORAD SA-15 2 #",
		"Red SAM SHORAD SA-8 2 #",
		"Red SAM SHORAD SA-19 2 #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-19 #",
		"Molniya #",
		"Rezky #"
	}, 30)
else
	bc:roamGroupsToLocalSubZone({
		"Ground Armour 2 #",
		"Ground Armour 3 #",
		"Ground Armour #",
		"Red SAM AAA 2 #",
		"Red SAM SHORAD SA-15 2 #",
		"Red SAM SHORAD SA-8 2 #",
		"Red SAM SHORAD SA-19 2 #",		
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-19 #",
		"Neustrashimy #",
		"Molniya #",
		"Rezky #"
	}, 30)
end
end,{},5,0)

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

Group.getByName('ca-tanks-Coldwar'):destroy()
Group.getByName('ca-tanks'):destroy()
tanksMenu = nil
bc:registerShopItem('armor', 'Deploy armor CA', 300, function(sender)
	
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

artyMenu = nil
bc:registerShopItem('artillery', 'Deploy artillery CA', 200, function(sender)
	
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
		timer.scheduleFunction(function()
			trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu', 15)
		end, {}, timer.getTime() + 3)
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

reconMenu = nil
bc:registerShopItem('recon', 'Deploy recon group CA', 50, function(sender)

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
		timer.scheduleFunction(function()
			trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu', 15)
		end, {}, timer.getTime() + 3)
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

airdefMenu = nil
bc:registerShopItem('airdef', 'Deploy air defence CA', 150, function(sender)
	
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
		timer.scheduleFunction(function()
			trigger.action.outTextForCoalition(2, 'Choose deploy zone from F10 menu', 15)
		end, {}, timer.getTime() + 3)
	
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
bc:registerShopItem('9linefm', 'Jtac 9line FM', 0, function(sender)
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
    if params.zone and params.zone.side == 1 then
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

local infMenu=nil
bc:registerShopItem('zinf','Add infantry squad to zone',500,function(sender)
	if infMenu then
		return 'Already choosing a zone'
	end
	local pickZone=function(zName)
		if infMenu then
			local z=bc:getZoneByName(zName)
			if not z or z.side~=2 then
				return 'Must pick friendly zone'
			end
			if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
				return 'Zone already upgraded'
			end
			z:addExtraSlot('blueInfantry') -- check
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
		params.zone:addExtraSlot('blueInfantry') -- check
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
			if not z or z.side~=2 then
				return 'Must pick friendly zone'
			end
		if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
			return 'Zone already upgraded'
		end
            local slot = (Era == 'Coldwar') and 'blueHAWK Coldwar' or 'bluePD1' -- check
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
		params.zone:addExtraSlot((Era == 'Coldwar') and 'blueHAWK Coldwar' or 'bluePD1') -- check
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
			if not z or z.side~=2 then
				return 'Must pick friendly zone'
			end
			if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
				return 'Zone already upgraded'
			end
			local slotID = (Era == 'Coldwar') and 'blueArmor Coldwar' or 'blueArmor' -- checked
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
		local slotID = (Era == 'Coldwar') and 'blueArmor Coldwar' or 'blueArmor' -- checked
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
			if not z or z.side~=2 then
				return 'Must pick friendly zone'
			end
			if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
				return 'Zone already upgraded'
			end
			z:addExtraSlot('bluePATRIOT') -- check
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

    trigger.action.outTextForCoalition(2,'All zones can now buy a second upgrade',15)
	bc:removeShopItem(2, 'gslot')
	return nil
end)
bc:registerShopItem('farphere','Deploy FARP',1000,function(sender)
        return 'Deploy a FARP via map marker.\nUse marker text: buy:farphere.\nMust be outside all zones and at least 10 NM from enemy zones.'
end,function(_, params)
        return bc:processMapFarpPurchase(params)
end)

-- first value below is how much in stock, the second number value is the ranking in the shop menu list, the third is the new ranking system.
bc:addShopItem(2, 'jtac', -1, 1, 2) -- MQ-9 Reaper JTAC mission
bc:addShopItem(2, 'dynamiccap', -1, 2, 2) -- CAP
bc:addShopItem(2, 'dynamiccas', -1, 3, 5) -- CAS
bc:addShopItem(2, 'dynamicbomb', -1, 4, 4) -- Bomber
bc:addShopItem(2, 'dynamicsead', -1, 5, 4) -- SEAD
bc:addShopItem(2, 'dynamicdecoy', -1, 6, 1) -- Decoy flight
if UseStatics == true then
    bc:addShopItem(2, 'dynamicstatic', -1,7,4) -- Static buildings
end
bc:addShopItem(2, 'dynamicarco', -1, 8, 3) -- Navy tanker
bc:addShopItem(2, 'dynamictexaco', -1, 9, 3) -- Airforce tanker
bc:addShopItem(2, 'farphere', -1, 10, 2) -- deploy FARP
bc:addShopItem(2, 'capture', -1, 11, 1) -- emergency capture
bc:addShopItem(2, 'smoke', -1, 12, 1) -- smoke on target
bc:addShopItem(2, 'intel', -1, 13, 5) -- Intel
bc:addShopItem(2, 'supplies2', -1, 14, 1) -- upgrade friendly zone
bc:addShopItem(2, 'supplies', -1, 15, 6) -- fully upgrade friendly zone
bc:addShopItem(2, 'zinf', -1, 16, 5) -- add infantry to a zone
bc:addShopItem(2, 'zarm', -1, 17, 7) -- add armour group to a zone
bc:addShopItem(2, 'zsam', -1, 18, 6) -- add Nasams to a zone
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


supplyZones = {
	'Blue Carrier',
	
	'Sde Dov',	
	'Ben-Gurion', 
	'Palmahim', 
	'Tel Nof', 
	'Hatzor', 
	'Kedem-Hatzerim', 
	'Nevatim', 
	'Ramon Airbase',
	'El Gora',
	'El Arish',
	'Ovda',
	'Bir Hasanah',
	'Melez',
	'Baluza',
	'Al Mansurah',
	'As Salihiyah',
	'Al Ismailiyah',

	'AzZaqaziq',
	'Kibrit Air Base',
	'Inshas Airbase',
	'Cairo International Airport',
	'Wadi al Jandali',
	'Cairo West',
	'Beni Suef',
	'Birma Air Base',
	
	'FARP-Alpha',
	'FARP-Bravo',
	'FARP-Charlie',
	'Gebel El Basur Air Base',
	'Kom Awshim'
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
local HuntNumber = SplashDamage and math.random(8,15) or math.random(6,15)
bc:initHunter(HuntNumber)
SCHEDULER:New(nil, function() bc:_buildHunterBaseList() end, {}, 1)

SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 5)
SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 6)

AWACS_CFG = {
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=150 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=75 }   -- blue
}

GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 100   		-- suspend red zones deeper than this nm
evc = EventCommander:new({ decissionFrequency=30*60, decissionVariance=30*60, skipChance = 10})
evc:init()
mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})

---------------------- Destroy SCUDS at Gebel El Basur Air Base (31) ------------------
Group.getByName('Quwaysina-Scuds'):destroy()
evc:addEvent({
	id='Quwaysinascuds',
	action = function()
	RespawnGroup('Quwaysina-Scuds')
		RegisterGroupTarget('Quwaysina-Scuds',250,'Destroy SCUDS')
		timer.scheduleFunction(function(param, time)
			if Group.getByName('Quwaysina-Scuds') then
				local tgts = {
					'Melez',
					'As Salihiyah',
					'Al Ismailiyah',
					'Kibrit Air Base',
					'Wadi al Jandali',
					'Baluza'
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
				bc:fireAtZone(choice, 'Quwaysina-Scuds', false, 8)
				trigger.action.outTextForCoalition(2, 'SCUDS near Gebel El Basur Air Base (31) are launching at '..choice, 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
		if math.random(1, 100) > 50 then return false end
		local gr = Group.getByName('Quwaysina-Scuds')
		if gr then return false end
		local gabel = bc:getZoneByName('Gebel El Basur Air Base')
		if not gabel or gabel.side ~= 1 or gabel.suspended then return false end
		local triggers = {'Melez', 'Baluza', 'Kibrit Air Base'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end		
		return false
	end
})
mc:trackMission({
	title = "Destroy SCUDS (31)",
	description = "SCUDS have been spotted at Gebel El Basur Air Base (31).\nDestroy them before they can launch their missiles",
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
		local gr = Group.getByName('Quwaysina-Scuds')
		if gr then return true else return false end
	end
})
----------------------- End Destroy SCUDS at Gebel El Basur Air Base (31) ---------------------

------------------------------- Destroy SCUDS at Baluza (14) ----------------------------------
Group.getByName('Baluza-Scuds'):destroy()
evc:addEvent({
    id='Baluza-scuds',
    action = function()
		RespawnGroup('Baluza-Scuds')
		RegisterGroupTarget('Baluza-Scuds',250,'Destroy SCUDS')
		timer.scheduleFunction(function(param, time)
			if Group.getByName('Baluza-Scuds') then
				local tgts = {
					'Ramon Airbase',
					'El Arish',
					'El Gora',
					'Ovda',
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
				bc:fireAtZone(choice, 'Baluza-Scuds', false, 8)
				trigger.action.outTextForCoalition(2, 'SCUDS near Baluza (14) are launching at '..choice, 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,  
    canExecute = function()
        if math.random(1, 100) > 50 then return false end
        local gr = Group.getByName('Baluza-Scuds')
        if gr then return false end

        if bc:getZoneByName('Baluza').side ~= 1 or bc:getZoneByName('Baluza').suspended then return false end
        if bc:getZoneByName('Melez').side ~= 2 or bc:getZoneByName('Melez').suspended then return false end
        
        local triggers = {'Ramon Airbase', 'El Gora', 'Ovda'}
        for _,v in ipairs(triggers) do
            if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
                return true
            end
        end
        
        return false
    end
})
mc:trackMission({
	title = "Destroy SCUDS (14).",
	description = "SCUDS have been spotted at Baluza (14).\nDestroy them before they can launch their missiles",
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
		local gr = Group.getByName('Baluza-Scuds')
		if gr then return true else return false end
	end
})

------------------------------- End Destroy SCUDS at Baluza (14) --------------------------------
---------------------------------------- Intercept Bombers -------------------------------------
local bomb_COOLDOWN = 1800
local lastbomb_COOLDOWN  = -bomb_COOLDOWN
local escGrp = Era=='Coldwar' and 'EscortBomberCW' or 'EscortBomber'
Group.getByName('evt-bomb'):destroy()
evc:addEvent({
	id='bomb',
	action=function()
		RespawnGroup('evt-bomb')
		RegisterGroupTarget('evt-bomb',500,'Intercept enemy bombers')
		timer.scheduleFunction(function()
			RespawnGroup(escGrp)
		local tgts = {
			'Ramon Airbase','Melez','El Arish','El Gora','Ovda','Wadi al Jandali','Al Ismailiyah',
			'AzZaqaziq','Birma Air Base','Bilbeis Air Base','Cairo International Airport','Al Mansurah',
			'As Salihiyah','Cairo West','Quwaysina',}	
			if Group.getByName('evt-bomb') then
				local bomber, bomberMission = StartBomberAuftrag('bomb', 'evt-bomb', tgts, escGrp)
			end
		end,{},timer.getTime()+1)
	end,
	canExecute = function()
		if timer.getTime() - lastbomb_COOLDOWN < bomb_COOLDOWN then return false end
		local gr = Group.getByName('evt-bomb') if gr then return false end
		if math.random(1,100)<70 then return false end
		local triggers = {'Ramon Airbase','Melez','St Catherine','Ovda','Al Ismailiyah','Wadi al Jandali','AzZaqaziq','Birma Air Base'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		return false
	end
})
mc:trackMission({
	title = "Intercept Bombers",
	description = "Enemy bombers spotted inbound from south of Egypt.\nDestroy them before they get in range.",
	messageStart =  "New mission: Intercept Bombers",
	messageEnd = function() lastbomb_COOLDOWN = timer.getTime() return "Mission ended: Intercept Bombers" end,
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
------------------------------------------End Intercept Bombers ---------------------------------------
--------------------------------------- Intercept enemy airstrike -------------------------------------
local attackGrp = Era=='Coldwar' and 'evt-attackcw' or 'evt-attack'
Group.getByName('evt-attack'):destroy()
Group.getByName('evt-attackcw'):destroy()
evc:addEvent({
	id='cas',
	action=function()
		RespawnGroup(attackGrp)
		RegisterGroupTarget(attackGrp,500,'Intercept enemy airstrike')
		timer.scheduleFunction(function(param, time)
			local tgts = {
				'Ramon Airbase',
				'Melez',
				'El Arish',
				'El Gora',
				'Ovda',
				'Wadi al Jandali',
				'Al Ismailiyah',
				'AzZaqaziq',
				'Birma Air Base',
				'Bilbeis Air Base',
				'Cairo International Airport',
				'Al Mansurah',
				'As Salihiyah',
				'Cairo West',
				'Quwaysina',
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
				
				if Group.getByName(attackGrp) then bc:engageZone(choice,attackGrp) end
			end
		end, {}, timer.getTime()+3)
	end,
	canExecute = function()
		local gr = Group.getByName(attackGrp)
		if gr then return false end
		if math.random(1,100) < 50 then return false end
		
		local triggers = {'Ramon Airbase','Melez','Ovda','Al Ismailiyah','Wadi al Jandali','AzZaqaziq','Birma Air Base'}
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
	messageEnd = "Mission ended: Intercept enemy airstrike",
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
		if g1 or g2 then return true else return false end
	end
})

---------------------------------- End intercept enemy airstrike ---------------------------------
-------------------------------------- Intercept cargo plane -------------------------------------

Group.getByName('evt-cargointercept1'):destroy()
Group.getByName('evt-cargointercept2'):destroy()
Group.getByName('evt-cargointercept3'):destroy()
local cargoDieEvent = nil
evc:addEvent({
	id = 'cargointercept',
	action = function()
		local planes = {'evt-cargointercept1','evt-cargointercept2','evt-cargointercept3'}
		local choice = math.random(1,#planes)
		RespawnGroup(planes[choice])
		local u = Group.getByName(planes[choice]):getUnit(1)
		if u then RegisterUnitTarget(u:getName(),500,'Cargo plane mission') end
	end,
	canExecute = function()
		if math.random(1,100) < 70 then return false end
		if bc:getZoneByName('Gebel El Basur Air Base').side ~= 1 or bc:getZoneByName('Gebel El Basur Air Base').suspended then return false end
		if bc:getZoneByName('Cairo West').side ~= 1 or bc:getZoneByName('Cairo West').suspended then return false end
		if Group.getByName('evt-cargointercept1') then return false end
		if Group.getByName('evt-cargointercept2') then return false end
		if Group.getByName('evt-cargointercept3') then return false end
		return true
	end
})
mc:trackMission({
	title = "Intercept cargo plane",
	description = "Find and destroy the enemy cargo plane taking and destroy it.",
	messageStart = "New mission: Intercept cargo plane",
	messageEnd = "Mission ended: Intercept cargo plane",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "radio1.ogg")
        end
    end,
    endAction = function()
    end,
	isActive = function()
		if Group.getByName('evt-cargointercept1') then return true end
		if Group.getByName('evt-cargointercept2') then return true end
		if Group.getByName('evt-cargointercept3') then return true end
		
		return false
	end
})
-------------------------------------- End intercept cargo plane -------------------------------------

------------------------------------- Destroy cargo & battle ships -----------------------------------
Group.getByName('evt-shiptercept2'):destroy()
Group.getByName('evt-shiptercept3'):destroy()
local shipDieEvent = nil
evc:addEvent({
	id = 'shiptercept',
	action = function()
		local ships = {'evt-shiptercept2','evt-shiptercept3'}
		local choice = math.random(1, #ships)
		RespawnGroup(ships[choice])
		RegisterGroupTarget(ships[choice],500,'cargo ship')
	end,
	canExecute = function()
		if math.random(1, 100) < 70 then return false end
		if Group.getByName('evt-shiptercept2') then return false end
		if Group.getByName('evt-shiptercept3') then return false end
		return true
	end
})

mc:trackMission({
    title = "Destroy cargo & battle ships",
    description = function()
        return "New mission: Destroy cargo & battle ships"
    end,
    messageStart = "Mission started: Destroy cargo & battle ships",
    messageEnd = "Mission ended: Destroy cargo & battle ships",
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
        if Group.getByName('evt-shiptercept2') then return true end
        if Group.getByName('evt-shiptercept3') then return true end
        return false
    end
})

------------------------------- End destroy cargo & battle ships ----------------------------
------------------------------------- Destroy artillery -------------------------------------

Group.getByName('evt-Salihiyah-attack-melez-art'):destroy()
evc:addEvent({
    id = 'artilleryattack',
    action = function()
		RespawnGroup('evt-Salihiyah-attack-melez-art')
		RegisterGroupTarget('evt-Salihiyah-attack-melez-art',250,'Destroy artillery')
    end,
    canExecute = function()
        if math.random(1, 100) < 60 then return false end
		if bc:getZoneByName('As Salihiyah').side ~= 1 or bc:getZoneByName('As Salihiyah').suspended then return false end
        if bc:getZoneByName('Melez').side ~= 2 or bc:getZoneByName('Melez').suspended then return false end
        if Group.getByName('evt-Salihiyah-attack-melez-art') then return false end
        return true
    end
})

mc:trackMission({
	title = "Destroy artillery",
	description = "Artillery has been spotted heading towards Melez from the direction of As Salihiyah.\nDestroy them before they get in range.",
	messageStart = "New mission: Destroy artillery",
	messageEnd = "Mission ended: Destroy artillery heading to Melez",
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
		if Group.getByName('evt-salihiyah-attack-melez-art') then return true end
		return false
	end
})
-------------------------------------- End of destroy artillery -------------------------------------
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

function generateCaptureMission()
    if captureTarget ~= nil then return end
    
    local validzones = {}
    for _,v in ipairs(bc.zones) do
        
        if v.active and v.side == 0 and (not v.NeutralAtStart or v.firstCaptureByRed) then
            
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
            bc.playerContributions[2][pname] = (bc.playerContributions[2][pname] or 0) + reward
            local jp = bc.jointPairs and bc.jointPairs[pname]
            if jp and bc:_jointPartnerAlive(pname) and bc:_jointPartnerAlive(jp) and bc.playerContributions[2][jp] ~= nil then
                bc.playerContributions[2][jp] = (bc.playerContributions[2][jp] or 0) + reward
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
            bc.playerContributions[2][pname] = (bc.playerContributions[2][pname] or 0) + reward
            local jp = bc.jointPairs and bc.jointPairs[pname]
            if jp and bc:_jointPartnerAlive(pname) and bc:_jointPartnerAlive(jp) and bc.playerContributions[2][jp] ~= nil then
                bc.playerContributions[2][jp] = (bc.playerContributions[2][jp] or 0) + reward
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
--                      END OF RUN WAY STRIKE MISSION              -----------------------------------------------------------------------
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
---------------------------------------------------------------------
--                      ESCORT MISSION                             --

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


-- scenery and missions

local sceneryList = {
  ["factoryBulding"] = {SCENERY:FindByZoneName("factoryBulding")},
  ["factoryBulding2"] = {SCENERY:FindByZoneName("factoryBulding2")},
  ["factoryBulding3"] = {SCENERY:FindByZoneName("factoryBulding3")},
  ["FactoryStrike"] = {SCENERY:FindByZoneName("FactoryStrike")},
 
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

Group.getByName('FactoryStrike'):destroy()
Group.getByName('Red SAM SA-3 Fixed SAM'):destroy()
evc:addEvent({
	id = 'FactoryStrike',
	action = function()
		RespawnGroup('FactoryStrike')
		RegisterGroupTarget('FactoryStrike',500,'Strike Target','FactoryStrike')
	end,
	canExecute = function()
		if CustomFlags['FactoryStrike'] then return false end
		if bc:getZoneByName('Wadi al Jandali').side ~= 2 or bc:getZoneByName('Wadi al Jandali').suspended then return false end
		return true
	end
})

mc:trackMission({
	title = "Strike High value target",
description = 
[[We have the location on a High value target.
South west of Wadi al Jandali, Take him out!.

Coordinates:
MGRS: 36 R UU 39157 01394
Lat Long: N 29°49'57" E 31°20'06"
Lat long Decimal Minutes: N 29°49.953' E 31°20.114'

Elevation: 86 feet

Reward: 500

Destroy the house and whoever is nearby.]],

	messageStart = "New strike mission: Strike High value target",
	messageEnd = "Strike mission ended: Strike High value target",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
		RespawnGroup('Red SAM SA-3 Fixed SAM')
	end,
	isActive = function()
		if CustomFlags["FactoryStrike"] then return false end
		if Group.getByName('FactoryStrike') then return true end
		return false
	end
})


evc:addEvent({
	id = 'factoryBulding',
	action = function()
		ActiveMission['factoryBulding'] = true
		local tgt = sceneryList['factoryBulding'][1] or SCENERY:FindByZoneName('factoryBulding')
		if not tgt then
			trigger.action.outText('factoryBulding is missing',30)
			return
		end
		RegisterScoreTarget('factoryBulding',tgt,500,'High value factory')
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"High value factory",p,2,false,false)
			MissionMarks['factoryBulding'] = missionMarkId
		end
	end,
	canExecute = function()
		if CustomFlags['factoryBulding'] then return false end
		if ActiveMission['factoryBulding'] then return false end
		if bc:getZoneByName('Melez').side ~= 2 or bc:getZoneByName('Melez').suspended then return false end
		if math.random(100) > 20 then return false end
		return true
	end
})

mc:trackMission({
	title = "Strike a High value factory",
	description = 
[[Strike a high-value factory just outside of Al Ismailiyah

Coordinates:
MGRS: 36 R VU 29372 86680
Lat long: N 30°36'38" E 32°15'47" 
Lat long Decimal Minutes: N 30°36.636' E 32°15.790'

Elevation: 16 feet

reward = 500]],
	messageStart = "New strike mission: Strike High value factory",
	messageEnd = "Mission ended: Strike High value factory",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["factoryBulding"] then return false end
	if ActiveMission['factoryBulding'] then return true end
	  return false
	end,
})

evc:addEvent({
	id = 'factoryBulding2',
	action = function()
		ActiveMission['factoryBulding2'] = true
		local tgt = sceneryList['factoryBulding2'][1] or SCENERY:FindByZoneName('factoryBulding2')
		if not tgt then
			trigger.action.outText('factoryBulding2 is missing',30)
			return
		end
		RegisterScoreTarget('factoryBulding2',tgt,500,'High value factory')
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"High value factory",p,2,false,false)
			MissionMarks['factoryBulding2'] = missionMarkId
		end
	end,
	canExecute = function()
		if bc:getZoneByName('As Salihiyah').side ~= 2 or bc:getZoneByName('As Salihiyah').suspended then return false end
		if CustomFlags['factoryBulding2'] then return false end
		if ActiveMission['factoryBulding2'] then return false end
		if math.random(100) > 20 then return false end
		return true
	end
})
mc:trackMission({
	title = "Strike a High value factory",
	description = 
[[Strike a high-value factory just north of Al Mansurah

Coordinates:
MGRS: 36 R UV 48338 35521
Lat long: N 31°02'37" E 31°24'38"
Lat long Decimal Minutes: N 31°02.617' E 31°24.643'

Elevation: 7 feet

reward = 500]],
	messageStart = "New strike mission: Strike High value factory",
	messageEnd = "Mission ended: Strike High value factory",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["factoryBulding2"] then return false end
	if ActiveMission['factoryBulding2'] then return true end
	  return false
	end,
})

evc:addEvent({
	id = 'factoryBulding3',
	action = function()
		ActiveMission['factoryBulding3'] = true
		local tgt = sceneryList['factoryBulding3'][1] or SCENERY:FindByZoneName('factoryBulding3')
		if not tgt then
			trigger.action.outText('factoryBulding3 is missing',30)
			return
		end
		RegisterScoreTarget('factoryBulding3',tgt,500,'High value factory')
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"High value factory",p,2,false,false)
			MissionMarks['factoryBulding3'] = missionMarkId
		end
	end,
	canExecute = function()
		if bc:getZoneByName('Ramon Airbase').side ~= 2 or bc:getZoneByName('Ramon Airbase').suspended then return false end
		if CustomFlags['factoryBulding3'] then return false end
		if ActiveMission['factoryBulding3'] then return false end
		if math.random(100) > 20 then return false end
		return true
	end
})

mc:trackMission({
	title = "Strike a High value factory",
	description = 
[[Strike a high-value factory just east of Baluza

Coordinates:
MGRS: 36 R WV 01224 31711
Lat long: N 31°01'08" E 33°00'46"
Lat long Decimal Minutes: N 31°01.141' E 33°00.769'

Elevation: 110 feet

reward = 500]],
	messageStart = "New strike mission: Strike High value factory",
	messageEnd = "Mission ended: Strike High value factory",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["factoryBulding3"] then return false end
	if ActiveMission['factoryBulding3'] then return true end
	  return false
	end,
})


seadTarget = nil
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
           not string.find(v.zone, "Hidden") and (not v.zone:find("Red Carrier")) then
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
----------------------- FLAGS --------------------------


buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end
-------------------------- END OF FLAGS --------------------------

env.info("Mission Setup : is completed!")