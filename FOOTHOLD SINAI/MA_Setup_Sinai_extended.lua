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
		red = {'Molniya', 'Molniya', 'Molniya', 'Rezky', 'Rezky', 'Rezky', 'Neustrashimy', 'Neustrashimy', 'Moskva'}
	},
	blueships = {
		blue = {'Hazzard Perry'},
		red = {'Moskva'}
	},
	startbase = {
		blue = {'blueInfantry'},
		red = {'Ground Forces 2', 'Ground Armour', 'Ground Armour 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2', 'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2'}
	},
	startbase2 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Ground Forces 2', 'Ground Armour', 'Ground Armour 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2', 'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2'}
	},
	airfield1Fayed = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Fayed HQ bulding', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour 2','Fayed Fuel Tank', 'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2'}
	},
	airfield1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Red SAM AAA' , 'Red SAM AAA 2', 'Red SAM SHORAD SA-19 Group' , 'Red SAM SHORAD SA-19 Group 2', 'Ground Armour 2', 'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2'}
	},
	ElGoraUpgrade = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Ground Forces 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour 2', 'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2', 'El Gora Command Center'}
	},
	airfield2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour', 'Ground Armour 2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2', 'Red SAM SHORAD SA-19 Group' , 'Red SAM SHORAD SA-19 Group 2'}
	},
	airfield2Ismailiyah = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Red SAM AAA', 'Ground Armour', 'Ground Armour 2', 'Red SAM AAA 2','Al Ismailiyah Fuel Tank', 'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2','Al Ismailiyah HQ bulding', 'Red SAM SHORAD SA-19 Group' , 'Red SAM SHORAD SA-19 Group 2'}
	},
	airfieldBen = {
		blue = {'bluePD1'},
		red = {}
	},
	airfield2hat = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'FixedredInfantry1-1', 'Ground Armour', 'Ground Armour 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2', 'Red SAM SHORAD SA-19 Group' , 'Red SAM SHORAD SA-19 Group 2', 'Kedem Fuel tanks', 'Kedem Fuel tanks-2','Kedem Fuel tanks-3','Kedem Fuel tanks-4'}
	},
	airfield3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Ground Forces 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour 2', 'Red SAM SHORAD SA-19 Group' , 'Red SAM SHORAD SA-19 Group 2', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2'}
	},
	airfield3Suwayr = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Ground Forces 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour 2', 'Abu Suwayr HQ bulding', 'Red SAM SHORAD SA-19 Group' , 'Red SAM SHORAD SA-19 Group 2', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2'}
	},
	airfield3nevatim = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Ground Forces 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour 2', 'Red SAM SHORAD SA-19 Group' , 'Red SAM SHORAD SA-19 Group 2', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2', 'Nevatim Command Center'}
	},
	airfield6Melez = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1', 'blueHAWK'},
		red = {'Ground Forces 2', 'Melez Ammo Depo', 'Ground Armour', 'Ground Armour 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Melez HQ bulding', 'Red SAM SHORAD SA-19 Group' , 'Red SAM SHORAD SA-19 Group 2', 'Melez Fuel Tank', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2'}
	},
	airfield4 = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Ground Forces 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour 2', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2', 'Red SAM SHORAD SA-8 Group'}
	},
	airfield4Dif = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour 2', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2', 'Red SAM SHORAD SA-8 Group'}
	},
	airfield4AzZaqaziq = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Ground Forces 2','Ground Armour', 'Ground Armour 2', 'AzZaqaziq Fuel Tank', 'AzZaqaziq Fuel Tank 2', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2', 'Red SAM SHORAD SA-8 Group'}
	},
	airfield4Catherine = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Ground Forces 2','Ground Armour', 'Ground Armour 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'St Catherine Command Center', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2', 'Red SAM SHORAD SA-8 Group'}
	},
	airfield4Baluza = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Ground Forces 2','Ground Armour', 'Ground Armour 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Baluza Command Center', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2', 'Red SAM SHORAD SA-8 Group'}
	},
	airfield4Ramon = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Ground Forces 2','Ramon Airbase Training Center', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour 2', 'Ramon Airbase HQ bulding', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2', 'Red SAM SHORAD SA-8 Group'}
	},
	airfield4hurghada = {
		blue = {'blueInfantry','blueArmor', 'bluePD2', 'BLUE SAM Fixed Hurghada'},
		red = {'Red SAM SA-11 Fixed Hurghada', 'Red SAM SHORAD SA-15 Fixed Hurghada', 'Ground Forces 2', 'Ground Armour', 'Ground Armour 2'}
	},
	sam1 = {
        blue = {'bluePD1', 'bluePD1'},
        red = {'Red SAM AAA' , 'Red SAM AAA 2', 'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2', 'Red SAM SA-2'}
    },
	sam1bravo = {
        blue = {'BLUE SAM Fixed NASAMS Bravo'},
        red = {'Red SAM AAA Fixed Bravo', 'Red SAM SHORAD SA-8 Fixed Bravo', 'Red SAM SA-2 Fixed Bravo'}
    },
	sam1golf = {
        blue = {'bluePD1', 'BLUE SAM Fixed NASAMS Golf'},
        red = {'Red SAM SHORAD Fixed Golf', 'Red SAM SA-2 Fixed Golf'}
    },
	  sam2charlie = {
        blue = {'bluePD2', 'BLUE SAM FIXED NASAMS Charlie'},
        red = {'Red SAM AAA Fixed Charlie', 'Red SAM SHORAD SA-19 Fixed Charlie', 'Red SAM SA-3 Fixed Charlie'}
    },
	  sam2hotel = {
        blue = {'bluePD2', 'BLUE SAM Fixed NASAMS Hotel'},
        red = {'Red SAM SHORAD SA-19 Fixed Hotel', 'Red SAM AAA Fixed Hotel', 'Red SAM SA-3 Fixed Hotel'}
    },

	  sam3alpha = {
        blue = {'bluePD1', 'BLUE SAM Fixed Hawk Alpha'},
        red = {'Red SAM SHORAD Fixed Alpha', 'Red SAM Fixed SA-6 Alpha'}
    },
	 sam3delta = {
        blue = {'bluePD1', 'BLUE SAM Fixed HAWK Delta'},
        red = {'Red SAM AAA Fixed Delta', 'Red SAM SHORAD SA-15 Fixed Delta', 'Red SAM SA-6 Fixed Delta'}
    },
	 sam3india = {
        blue = {'bluePD1', 'BLUE SAM Fixed HAWK India'},
        red = {'Red SAM AAA Fixed India', 'Red SAM SHORAD Fixed India', 'Red SAM SA-6 Fixed India'}
    },
    sam4juliett = {
        blue = {'bluePD2', 'BLUE SAM Fixed HAWK Juliett'},
        red = {'Red SAM AAA Fixed Juliett', 'Red SAM SHORAD SA-15 Fixed Juliett', 'Red SAM SA-10 Fixed Juliett'}
    },
    sam4lima = {
        blue = {'bluePD2', 'BLUE SAM Fixed HAWK Lima'},
        red = {'Red SAM AAA Fixed Lima', 'Red SAM SHORAD Fixed Lima', 'Red SAM SA-10 Fixed Lima'}
    },
    sam4echo = {
        blue = {'bluePD2', 'BLUE SAM Fixed HAWK Echo'},
        red = {'Red SAM AAA Fixed Echo', 'Red SAM SHORAD SA-15 Fixed Echo', 'Red SAM SA-10 Fixed Echo'}
    },
    sam5kilo = {
        blue = {'bluePD1', 'BLUE SAM Fixed Patriot KILO'},
        red = {'Red SAM SHORAD SA-19 Fixed Kilo', 'Red SAM SHORAD SA-15 Fixed Kilo', 'Red SAM SA-11 Fixed Kilo'}
    },
	 sam5missileFactory = {
        blue = {},
        red = {'Red SAM SHORAD SA-8 Fixed Missile Factory', 'Red SAM SA-11 Fixed Missile Factory', 'Fixed-Scuds'}
    },
    sam5foxtrot = {
        blue = {'bluePD1', 'BLUE SAM Fixed PATRIOT Foxtrot'},
        red = {'Red SAM AAA Fixed Foxtrot', 'Red SAM SHORAD SA-15 Fixed Foxtrot', 'Red SAM SA-11 Fixed Foxtrot'}
    },
    sam6mike = {
        blue = {'bluePD2', 'FixedPatriot'},
        red = {'Red SAM SHORAD SA-8 Fixed Mike', 'Red SAM Fixed SA-5 Mike'}
	},
	farp1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour', 'Ground Armour 2', 'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2'}
	},
	farp1Alpha = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Alpha Container', 'Alpha Fuel Tank', 'Alpha Fuel Tank-2', 'Ground Forces 1', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour', 'Ground Armour 2', 'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2'}
	},
	farp2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour', 'Ground Armour 2', 'Red SAM SHORAD SA-19 Group' , 'Red SAM SHORAD SA-19 Group 2'}
	},
	farp3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Ground Forces 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour 2', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2'}
	},
	farp4 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Red SAM SHORAD SA-8 Group' , 'Red SAM SHORAD SA-8 Group 2', 'Red SAM AAA' , 'Red SAM AAA 2', 'Ground Armour 2', 'Red SAM SHORAD SA-15 Group 2'}
	},
	mission1 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Red SAM SA-3 Fixed Mining', 'Ground Armour Fixed Mining', 'Red SAM AAA Fixed Mining', 'Red SAM SHORAD SA-19 Fixed MiningFacility', 
	'Mining Facility Command Center'}
	},
	
	mission1Ammo = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Fixed-ammo1', 'Fixed-ammo4-1', 'Fixed-ammo3', 'Fixed-ammo4', 'Fixed-ammo2', 'Fixed-ammo4-2'}
	},
	mission2 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Fixed-Tanks', 'Fixed-SA6tankfactroy2', 'Fixed-SA6tankfactroy', 'Fixed-Tanks-3'}
	},
	mission2InsurgentCamp = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Fixed-InfantryGroup', 'Fixed-InfantryGroup-2', 'Fixed-Zu23', 'Fixed-Art'}
	
	},
	mission3 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Red SAM SA-6 Fixed Secret tech', 'Red SAM SHORAD SA-15 Fixed Secret tech', 'Fixed-redArmor2', 'Fixed-redArmor1', 'Fixed-redInfantry2', 'Secret Tech building HQ'}
			  
	},
	mission3chemsite = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Special Task Force of Chemsite Fixed','Red SAM AAA Fixed CheckSite', 'Special Tank units Second batalion Fixed', 'Special Tank units Fixed', 'Red SAM SHORAD SA-15 Fixed CheckSite', 'Chemical Tank 1', 'Chemical Tank 2', 'Chemical Tank 3',
		'Chemical Tank 4', 'Chemical Factory 1', 'Chemical Factory 2', 'Chemical Factory 3', 'Chemical Factory 4'}
	},
	mission4 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Ground Forces 2', 'Ground Armour','Ground Armour 2', 'Red SAM SHORAD SA-8 Group', 'Red SAM SHORAD SA-15 Group' , 'Red SAM SHORAD SA-15 Group 2'}
	},
	
	mission4fueldepo = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Fixed-Fuel2', 'Fixed-Fuel5', 'Fixed-Fuel4', 'Fixed-Fuel'}
	},
	
	hidden1Group = {
		blue = {},
		red = {'Red EWR 1 Fixed', 'Red EWR 2 Fixed', 'Red EWR 3 Fixed', 'Red EWR 4 Fixed', 'Red EWR 5 Fixed'}
	}
}

flavor = {
	bluecarrier = 'WPT \nStart zone',
	redcarrier = 'WPT 27 \nEnemy carrier zone',
	sdedov = 'WPT \n',
	bengurion = 'WPT 1\n',
	palmahim = 'WPT \n',
	telnof = 'WPT \n',
	hatzor = 'WPT 2\n',
	kedemhatzerim = 'WPT 3\n',
	nevatim = 'WPT 4\n',
	ramonairbase = 'WPT 5\n',
	elgora = 'WPT 6\n',
	elarish = 'WPT 7\n',
	ovda = 'WPT 10\n',
	stcatherine = 'WPT 14\n',
	sharmelsheikh = 'WPT 15\n',
	hurghada = 'WPT 16\n',
	aburudeis = 'WPT 21\n',
	birhasanah = 'WPT 25\n',
	melez = 'WPT 26\n',
	baluza = 'WPT 28\n',
	assalihiyah = 'WPT 31\n',
	alismailiyah = 'WPT 33\n',
	abusuwayr = 'WPT 32\n',
	difarsuwarairfield = 'WPT 34\n',
	fayed = 'WPT 35\n',
	kibritairbase = 'WPT 36\n',
	almansurah = 'WPT 30\n',
	azzaqaziq = 'WPT 44\n',
	bilbeisairbase = 'WPT 43\n',
	inshasairbase = 'WPT 42\n',
	cairointernationalairport = 'WPT 40\n',
	wadialjandali = 'WPT 37\n',
	cairowest = 'WPT 41\n',
	benisuef = 'WPT 38\n',
	Quwaysina = 'WPT 45\n',
	komawshim = 'WPT 39\n',
	birmaairbase = 'WPT 46\n',

	farpalpha = 'WPT 9\n',
	farpbravo = 'WPT 11\n',
	farpcharlie = 'WPT 12\n',
	farpdelta = 'WPT 13\n',
	farpecho = 'WPT 17\n',
	farpfoxtrot = 'WPT 18\n',
	farpgolf = 'WPT 19\n',
	farphotel = 'WPT 20\n',
	farpindia = 'WPT 22\n',
	farpjuliett = 'WPT 23\n',
	farpkilo = 'WPT 8\n',
	farplima = 'WPT 27\n',
	farpmike = 'WPT 24\n',
	
	
	miningfacility = 'Check kneeboard for coordinates.\n',
	insurgentcamp = 'Check kneeboard for coordinates.\nDestroy the Insurgents and we will add to your bank 500 credits',
	secrettechfacility = 'Check kneeboard for coordinates.\nDestroy the buildings and area completly',
	fueldepo = 'Check kneeboard for coordinates.\nTake out their Fuel Depo including the fuel tanks',
	ammonitiondepo = 'Check kneeboard for coordinates.\nTake out their ammunition Depo including the storage',
	tankfactory = 'Check kneeboard for coordinates.\nDestroy the factorys and the tank storage',
	chemsite = 'Check kneeboard for coordinates.\nHere they are building chemical weapons. Destroy the buildings',
	artilleryfactory = 'Check kneeboard for coordinates.\n',
	missilefactory = 'Check kneeboard for coordinates.\nRumors say they have Scuds here',
	
	samalpha = 'Check kneeboard for coordinates.\nFriendly SAM',
	sambravo = 'Check kneeboard for coordinates.\nSA-2 and Red SAM SHORAD',
	samcharlie = 'Check kneeboard for coordinates.\nSA-3 and Red SAM SHORAD',
	samdelta = 'Check kneeboard for coordinates.\nSA-6 and Red SAM SHORAD',
	samecho = 'Check kneeboard for coordinates.\nSA-10 and Red SAM SHORAD',
	samfoxtrot = 'Check kneeboard for coordinates.\nSA-11 and Red SAM SHORAD',
	samgolf = 'Check kneeboard for coordinates.\nSA-2 and Red SAM SHORAD',
	samhotel = 'Check kneeboard for coordinates.\nSA-3 and Red SAM SHORAD',
	samindia = 'Check kneeboard for coordinates.\nSA-6 and Red SAM SHORAD',
	samjuliett = 'Check kneeboard for coordinates.\nSA-10 and Red SAM SHORAD',
	samkilo = 'Check kneeboard for coordinates.\nSA-10 and Red SAM SHORAD',
	samlima = 'Check kneeboard for coordinates.\nSA-10 and Red SAM SHORAD',
	sammike = 'Check kneeboard for coordinates.\nSA-5 and Red SAM SHORAD'
}

WaypointList = {
    ["Ben-Gurion"] = ' (1)',
    Hatzor = ' (2)',
    ["Kedem-Hatzerim"] = ' (3)',
    Nevatim = ' (4)',
    ["Ramon Airbase"] = ' (5)',
    ["El Gora"] = ' (6)',
    ["El Arish"] = ' (7)',
    Ovda = ' (10)',
    ["St Catherine"] = ' (14)',
    ["Sharm El Sheikh International Airport"] = ' (15)',
    ["Hurghada International Airport"] = ' (16)',
    ["Abu Rudeis"] = ' (21)',
    ["Bir Hasanah"] = ' (25)',
    Melez = ' (26)',
    Baluza = ' (28)',
    ["As Salihiyah"] = ' (30)',
    ["Al Ismailiyah"] = ' (31)',
    ["Abu Suwayr"] = ' (32)',
    ["Difarsuwar Airfield"] = ' (33)',
    Fayed = ' (34)',
    ["Kibrit Air Base"] = ' (35)',
    ["Red Carrier"] = ' (29)',
    ["Al Mansurah"] = ' (41)',
    ["AzZaqaziq"] = ' (40)',
    ["Bilbeis Air Base"] = ' (39)',
    ["Inshas Airbase"] = ' (38)',
    ["Cairo International Airport"] = ' (37)',
    ["Wadi al Jandali"] = ' (36)',
    ["Cairo West"] = ' (44)',
    ["Beni Suef"] = ' (46)',
    Quwaysina = ' (43)',
    ["Kom Awshim"] = ' (45)',
    ["Birma Air Base"] = ' (42)',

    -- Adding the FARP waypoints
    ["FARP-Alpha"] = ' (9)',
    ["FARP-Bravo"] = ' (11)',
    ["FARP-Charlie"] = ' (12)',
    ["FARP-Delta"] = ' (13)',
    ["FARP-Echo"] = ' (17)',
    ["FARP-Foxtrot"] = ' (18)',
    ["FARP-Golf"] = ' (19)',
    ["FARP-Hotel"] = ' (20)',
    ["FARP-India"] = ' (22)',
    ["FARP-Juliett"] = ' (23)',
    ["FARP-Kilo"] = ' (8)',
    ["FARP-Lima"] = ' (27)',
    ["FARP-Mike"] = ' (24)'
}

FootholdSaveBaseName = (Era == 'Coldwar') and 'FootHold_SI_v0.3_coldwar' or 'FootHold_SI_v0.3'

local filepath = FootholdSaveBaseName .. '.lua'
if lfs then
  FootholdSavePath = FootholdSavePath or (lfs.writedir()..'Missions/Saves')
  lfs.mkdir(FootholdSavePath)
  filepath = FootholdSavePath .. '/' .. (FootholdSaveBaseName .. '.lua')
  env.info('Foothold - Save file path: '..filepath)
end

local cwSwap = {
	['Ground Armour 2']   	= 'Red Armor Group7',
	['Ground Armour']  		= 'Red Armor Group8',
	['Neustrashimy']  		= 'Molniya',
	['blueArmor']  			= 'blueArmor_Cw',
	['bluePATRIOT']  		= 'blueHAWK_CW',
	['bluePD1']  			= 'blueHAWK_CW',
	['blueHAWK']  			= 'blueHAWK_CW',
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
	['Red SAM SA-10 Fixed Juliett']   			= 'Red SAM SA-2 Fixed Juliett',
	['Red SAM SA-11 Fixed Foxtrot']   			= 'Red SAM SA-2 Fixed Foxtrot',
	['Red SAM SA-10 Fixed Lima']  				= 'Red SAM SA-2 Fixed SAMJuliett',
	['Red SAM SA-11 Fixed Kilo']  				= 'Red SAM SA-2 Fixed Kilo',
	['Red SAM SA-11 Fixed Missile Factory']  	= 'Red SAM SA-2 Fixed Missile Factory',
	['Red SAM SHORAD SA-15 Fixed Secret tech']  = 'Red SAM SHORAD SA-8 Fixed Secret tech',
	['Red SAM SHORAD SA-15 Fixed Kilo']  		= 'Red SAM SHORAD SA-8 Fixed Kilo',
	['Red SAM SHORAD SA-15 Fixed Foxtrot']  	= 'Red SAM SHORAD SA-8 Fixed Foxtrot',
	['Red SAM SHORAD SA-15']  					= 'Red SAM SHORAD SA-8',
	['Red SAM SHORAD SA-15 2']  				= 'Red SAM SHORAD SA-8 2',
	['Red SAM SHORAD SA-15 Fixed Juliett']  	= 'Red SAM SHORAD SA-8 Fixed Juliett',
	['Red SAM SHORAD SA-15 Fixed Delta']  		= 'Red SAM SHORAD SA-8 Fixed Delta',
	['Red SAM SHORAD SA-15 Fixed Hurghada']  	= 'Red SAM SHORAD SA-8 Fixed Hurghada',
	['Red SAM SHORAD SA-15 Fixed Echo']  		= 'Red SAM SHORAD SA-8 Fixed Echo',
	['Red SAM SHORAD SA-15 Fixed CheckSite']  	= 'Red SAM SHORAD SA-8 Fixed CheckSite',
}

local function deepSwapAgain(t,s)
	for k,v in pairs(t) do
		if type(v)=='table' then
			deepSwapAgain(v,s)
		elseif s[v] then
			t[k]=s[v]
		end
	end
end

if NoSA10AndSA11 == true then
	deepSwapAgain(upgrades,SamSwap)
end

bc = BattleCommander:new(filepath, 10, 60)
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
end
Hunt = true

zones = {
	redcarrier = ZoneCommander:new({zone='Red Carrier', side=1, level=10, upgrades=upgrades.redships, crates={}, flavorText=flavor.redcarrier}),
	bluecarrier = ZoneCommander:new({zone='Blue Carrier', side=2, level=1, upgrades=upgrades.blueships, crates={}, flavorText=flavor.bluecarrier}),
	
	sdedov = ZoneCommander:new({zone='Sde Dov', side=2, level=2, upgrades=upgrades.startbase2, crates={}, flavorText=flavor.sdedov}),
	bengurion = ZoneCommander:new({zone='Ben-Gurion', side=2, level=25, upgrades=upgrades.airfieldBen, crates={}, flavorText=flavor.bengurion}),
	palmahim = ZoneCommander:new({zone='Palmahim', side=2, level=25, upgrades=upgrades.startbase, crates={}, flavorText=flavor.palmahim}),
	telnof = ZoneCommander:new({zone='Tel Nof', side=2, level=25, upgrades=upgrades.startbase, crates={}, flavorText=flavor.telnof}),
	hatzor = ZoneCommander:new({zone='Hatzor', side=2, level=25, upgrades=upgrades.startbase, crates={}, flavorText=flavor.hatzor}),
	kedemhatzerim = ZoneCommander:new({zone='Kedem-Hatzerim', side=1, level=25, upgrades=upgrades.airfield2hat, crates={}, flavorText=flavor.kedemhatzerim}),
	nevatim = ZoneCommander:new({zone='Nevatim', side=1, level=25, upgrades=upgrades.airfield3nevatim, crates={}, flavorText=flavor.nevatim}),
	ramonairbase = ZoneCommander:new({zone='Ramon Airbase', side=1, level=25, upgrades=upgrades.airfield4Ramon, crates={}, flavorText=flavor.ramonairbase}),
	elgora = ZoneCommander:new({zone='El Gora', side=1, level=25, upgrades=upgrades.ElGoraUpgrade, crates={}, flavorText=flavor.elgora}),
	elarish = ZoneCommander:new({zone='El Arish', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.elarish}),
	ovda = ZoneCommander:new({zone='Ovda', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.ovda}),
	stcatherine = ZoneCommander:new({zone='St Catherine', side=1, level=25, upgrades=upgrades.airfield4Catherine, crates={}, flavorText=flavor.stcatherine}),
	sharmelsheikh = ZoneCommander:new({zone='Sharm El Sheikh International Airport', side=1, level=25, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.sharmelsheikh}),
	hurghada = ZoneCommander:new({zone='Hurghada International Airport', side=1, level=25, upgrades=upgrades.airfield4hurghada, crates={}, flavorText=flavor.hurghada}),
	aburudeis = ZoneCommander:new({zone='Abu Rudeis', side=1, level=25, upgrades=upgrades.airfield1, crates={}, flavorText=flavor.aburudeis}),
	birhasanah = ZoneCommander:new({zone='Bir Hasanah', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.birhasanah}),
	melez = ZoneCommander:new({zone='Melez', side=1, level=25, upgrades=upgrades.airfield6Melez, crates={}, flavorText=flavor.melez}),
	baluza = ZoneCommander:new({zone='Baluza', side=1, level=25, upgrades=upgrades.airfield4Baluza, crates={}, flavorText=flavor.baluza}),
	assalihiyah = ZoneCommander:new({zone='As Salihiyah', side=1, level=25, upgrades=upgrades.airfield1, crates={}, flavorText=flavor.assalihiyah}),
	alismailiyah = ZoneCommander:new({zone='Al Ismailiyah', side=1, level=25, upgrades=upgrades.airfield2Ismailiyah, crates={}, flavorText=flavor.alismailiyah}),
	abusuwayr = ZoneCommander:new({zone='Abu Suwayr', side=1, level=25, upgrades=upgrades.airfield3Suwayr, crates={}, flavorText=flavor.abusuwayr}),
	difarsuwarairfield = ZoneCommander:new({zone='Difarsuwar Airfield', side=1, level=25, upgrades=upgrades.airfield4Dif, crates={}, flavorText=flavor.difarsuwarairfield}),
	fayed = ZoneCommander:new({zone='Fayed', side=1, level=25, upgrades=upgrades.airfield1Fayed, crates={}, flavorText=flavor.fayed}),
	kibritairbase = ZoneCommander:new({zone='Kibrit Air Base', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.kibritairbase}),
	almansurah = ZoneCommander:new({zone='Al Mansurah', side=1, level=25, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.almansurah}),
	azzaqaziq = ZoneCommander:new({zone='AzZaqaziq', side=1, level=25, upgrades=upgrades.airfield4AzZaqaziq, crates={}, flavorText=flavor.azzaqaziq}),
	bilbeisairbase = ZoneCommander:new({zone='Bilbeis Air Base', side=1, level=25, upgrades=upgrades.airfield1, crates={}, flavorText=flavor.bilbeisairbase}),
	inshasairbase = ZoneCommander:new({zone='Inshas Airbase', side=1, level=25, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.inshasairbase}),
	cairointernationalairport = ZoneCommander:new({zone='Cairo International Airport', side=1, level=1, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.cairointernationalairport}),
	wadialjandali = ZoneCommander:new({zone='Wadi al Jandali', side=1, level=25, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.wadialjandali}),
	cairowest = ZoneCommander:new({zone='Cairo West', side=1, level=25, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.cairowest}),
	benisuef = ZoneCommander:new({zone='Beni Suef', side=1, level=25, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.benisuef}),
	komawshim = ZoneCommander:new({zone='Kom Awshim', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.komawshim}),
	quwaysina = ZoneCommander:new({zone='Quwaysina', side=1, level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.quwaysina}),
	birmaairbase = ZoneCommander:new({zone='Birma Air Base', side=1, level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.birmaairbase}),
	
	farpalpha = ZoneCommander:new({zone='FARP-Alpha', side=1, level=25, upgrades=upgrades.farp1Alpha, crates={}, flavorText=flavor.farpalpha}),
	farpbravo = ZoneCommander:new({zone='FARP-Bravo', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farpbravo}),
	farpcharlie = ZoneCommander:new({zone='FARP-Charlie', side=1, level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.farpcharlie}),
	farpdelta = ZoneCommander:new({zone='FARP-Delta', side=1, level=25, upgrades=upgrades.farp4, crates={}, flavorText=flavor.farpdelta}),
	farpecho = ZoneCommander:new({zone='FARP-Echo', side=1, level=25, upgrades=upgrades.farp1, crates={}, flavorText=flavor.farpecho}),
	farpfoxtrot = ZoneCommander:new({zone='FARP-Foxtrot', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farpfoxtrot}),
	farpgolf = ZoneCommander:new({zone='FARP-Golf', side=1, level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.farpgolf}),
	farphotel = ZoneCommander:new({zone='FARP-Hotel', side=1, level=25, upgrades=upgrades.farp4, crates={}, flavorText=flavor.farphotel}),
	farpindia = ZoneCommander:new({zone='FARP-India', side=1, level=25, upgrades=upgrades.farp1, crates={}, flavorText=flavor.farpindia}),
	farpjuliett = ZoneCommander:new({zone='FARP-Juliett', side=1, level=25, upgrades=upgrades.farp2, crates={}, flavorText=flavor.farpjuliett}),
	farpkilo = ZoneCommander:new({zone='FARP-Kilo', side=1, level=25, upgrades=upgrades.farp3, crates={}, flavorText=flavor.farpkilo}),
	farplima = ZoneCommander:new({zone='FARP-Lima', side=1, level=25, upgrades=upgrades.farp4, crates={}, flavorText=flavor.farplima}),
	farpmike = ZoneCommander:new({zone='FARP-Mike', side=1, level=25, upgrades=upgrades.farp1, crates={}, flavorText=flavor.farpmike}),
	
	
	miningfacility = ZoneCommander:new({zone='MiningFacility', side=1, level=20, upgrades=upgrades.mission1, crates={}, flavorText=flavor.miningfacility}),
	insurgentcamp = ZoneCommander:new({zone='InsurgentCamp', side=1, level=20, upgrades=upgrades.mission2InsurgentCamp, crates={}, flavorText=flavor.insurgentcamp}),
	secrettechfacility = ZoneCommander:new({zone='SecretTechFacility', side=1, level=20, upgrades=upgrades.mission3, crates={}, flavorText=flavor.secrettechfacility}),
	fueldepo = ZoneCommander:new({zone='FuelDepo', side=1, level=20, upgrades=upgrades.mission4fueldepo, crates={}, flavorText=flavor.fueldepo}),
	ammonitiondepo = ZoneCommander:new({zone='AmmonitionDepo', side=1, level=20, upgrades=upgrades.mission1Ammo, crates={}, flavorText=flavor.ammonitiondepo}),
	tankfactory = ZoneCommander:new({zone='TankFactory', side=1, level=20, upgrades=upgrades.mission2, crates={}, flavorText=flavor.tankfactory}),
	chemsite = ZoneCommander:new({zone='ChemSite', side=1, level=20, upgrades=upgrades.mission3chemsite, crates={}, flavorText=flavor.chemsite}),
	artilleryfactory = ZoneCommander:new({zone='ArtilleryFactory', side=1, level=20, upgrades=upgrades.mission4, crates={}, flavorText=flavor.artilleryfactory}),
	missilefactory = ZoneCommander:new({zone='MissileFactory', side=1, level=20, upgrades=upgrades.sam5missileFactory, crates={}, flavorText=flavor.missilefactory}),
	
	samalpha = ZoneCommander:new({zone='SAM-Alpha', side=2, level=20, upgrades=upgrades.sam3alpha, crates={}, flavorText=flavor.samalpha}),
	sambravo = ZoneCommander:new({zone='SAM-Bravo', side=1, level=20, upgrades=upgrades.sam1bravo, crates={}, flavorText=flavor.sambravo}),
	samcharlie = ZoneCommander:new({zone='SAM-Charlie', side=1, level=20, upgrades=upgrades.sam2charlie, crates={}, flavorText=flavor.samcharlie}),
	samdelta = ZoneCommander:new({zone='SAM-Delta', side=1, level=20, upgrades=upgrades.sam3delta, crates={}, flavorText=flavor.samdelta}),
	samecho = ZoneCommander:new({zone='SAM-Echo', side=1, level=20, upgrades=upgrades.sam4echo, crates={}, flavorText=flavor.samecho}),
	samfoxtrot = ZoneCommander:new({zone='SAM-Foxtrot', side=1, level=20, upgrades=upgrades.sam5foxtrot, crates={}, flavorText=flavor.samfoxtrot}),
	samgolf = ZoneCommander:new({zone='SAM-Golf', side=1, level=20, upgrades=upgrades.sam1golf, crates={}, flavorText=flavor.samgolf}),
	samhotel = ZoneCommander:new({zone='SAM-Hotel', side=1, level=20, upgrades=upgrades.sam2hotel, crates={}, flavorText=flavor.samhotel}),
	samindia = ZoneCommander:new({zone='SAM-India', side=1, level=20, upgrades=upgrades.sam3india, crates={}, flavorText=flavor.samindia}),
	samjuliett = ZoneCommander:new({zone='SAM-Juliett', side=1, level=20, upgrades=upgrades.sam4juliett, crates={}, flavorText=flavor.samjuliett}),
	samkilo = ZoneCommander:new({zone='SAM-Kilo', side=1, level=20, upgrades=upgrades.sam5kilo, crates={}, flavorText=flavor.samkilo}),
	samlima = ZoneCommander:new({zone='SAM-Lima', side=1, level=20, upgrades=upgrades.sam4lima, crates={}, flavorText=flavor.samlima}),
	sammike = ZoneCommander:new({zone='SAM-Mike', side=1, level=20, upgrades=upgrades.sam6mike, crates={}, flavorText=flavor.sammike}),

	hidden1 = ZoneCommander:new({zone='Hidden1', side=1, level=20, upgrades=upgrades.hidden1Group, crates={}, flavorText=flavor.hidden1})
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
        "RED_MIRAGE_F1",
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
		"RED_MIRAGE_F1",
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
    GroupCommander:new({name = 'Hatzor-Attack-Kedem', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'Kedem-Hatzerim'})
})

zones.elgora:addGroups({
    GroupCommander:new({name = 'El-Gora-Support-El-Arish', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'El Arish'})
})
zones.farpalpha:addGroups({
    GroupCommander:new({name = 'Farp-Alpha-Supply-Farp-Kilo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Kilo'}),
    GroupCommander:new({name = 'Farp-Alpha-Supply-Ovda', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Ovda'})
})
zones.farpbravo:addGroups({
    GroupCommander:new({name = 'evt-FARP-Bravo-attack-ovda', mission = 'attack',template='AttackConvoy', targetzone = 'Ovda', type = 'surface'})
})
zones.farpdelta:addGroups({
    GroupCommander:new({name = 'FARP-Delta-supply-St-Catherine', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'St Catherine'}),
    GroupCommander:new({name = 'FARP-Delta-supply-Sharm-el-sheikh', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Sharm El Sheikh International Airport'})
})
zones.farpcharlie:addGroups({
    GroupCommander:new({name = 'FARP-Charlie-supply-St-Catherine', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'St Catherine'}),
    GroupCommander:new({name = 'FARP-Charlie-supply-FARP-Delta', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Delta'})
})
zones.farplima:addGroups({
    GroupCommander:new({name = 'Farp-Lima-Supply-Baluza', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Baluza'}),
    GroupCommander:new({name = 'Farp-Lima-Supply-Melez', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Melez'})
})
zones.kedemhatzerim:addGroups({
    GroupCommander:new({name = 'Kedem-Support-Nevatim', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Nevatim'}),
    GroupCommander:new({name = 'Kedem-Support-El Gora', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'El Gora'}),
    GroupCommander:new({name = 'Kedem-Support-Ramon', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Ramon Airbase'}),
    GroupCommander:new({name = 'Hatzerim-Support-Hatzor', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Hatzor'}),
    GroupCommander:new({name = 'Hatzerim-Attack-Hatzor', mission = 'attack',template='CasHeloTemplate', MissionType='CAS', targetzone = 'Hatzor'})
})
zones.birhasanah:addGroups({
    GroupCommander:new({name = 'Bir-Hasanah-Support-SAM-Foxtrot', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Foxtrot'})
})

zones.nevatim:addGroups({
    GroupCommander:new({name = 'nevatim-Support-El Arish', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'El Arish'}),
    GroupCommander:new({name = 'nevatim-Support-OVda', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Ovda'}),
    GroupCommander:new({name = 'nevatim-Support-Melez', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Melez'}),
})

zones.ramonairbase:addGroups({
    GroupCommander:new({name = 'Ramon-Patrol-Hatzerim', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Kedem-Hatzerim', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Ramon-Patrol-Kedem', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Nevatim', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Ramon-Supply-Kedem', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Kedem-Hatzerim'}),
    GroupCommander:new({name = 'Ramon-Supply-Nevatim', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Nevatim'}),
    GroupCommander:new({name = 'Ramon-Supply-El Gora', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'El Gora'}),
    GroupCommander:new({name = 'Ramon-Supply-SAM-Bravo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Bravo'}),
    GroupCommander:new({name = 'Ramon-Supply-Farp-Alpha', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Alpha'}),
    GroupCommander:new({name = 'Ramon-Supply-El-Gora', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'El Gora'}),
    GroupCommander:new({name = 'Ramon-Attack-Hatzor', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Hatzor'}),
    GroupCommander:new({name = 'Ramon-Attack-Kedem', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'Kedem-Hatzerim'}),
    GroupCommander:new({name = 'Ramon-Attack-Melez-Cas', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Melez', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'Ramon-attack-Ovda-Cas', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Ovda', Altitude = CasAltitude()})
})
zones.ovda:addGroups({
    GroupCommander:new({name = 'Ovda-Patrol-Catherine', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'St Catherine', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Ovda-Patrol-Ramon-Airbase', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Ramon Airbase', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Ovda-Support-Ramon', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Ramon Airbase'}),
    GroupCommander:new({name = 'Ovda-Support-FARP-Alpha', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Alpha'}),
    GroupCommander:new({name = 'Ovda-Supply-Farp-Bravo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Bravo'}),
    GroupCommander:new({name = 'Ovda-Attack-Kedem-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Kedem-Hatzerim', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Ovda-Attack-Kedem-Cas', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Kedem-Hatzerim', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'Ovda-attack-Ramon-Airbase', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Ramon Airbase', Altitude = CapAltitude()})
})
zones.melez:addGroups({
    GroupCommander:new({name = 'Melez-Patrol-Bir Hasanah-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Bir Hasanah', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Melez-patrol-El Arish-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'El Arish', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Melez-patrol-Melez-Cap', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude()}),

    GroupCommander:new({name = 'Melez-Support-Nevatim', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Nevatim'}),
    GroupCommander:new({name = 'Melez-Support-FARP-Kilo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Kilo'}),
    GroupCommander:new({name = 'Melez-Support-FARP-Lima', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Lima'}),
    GroupCommander:new({name = 'Melez-Support-Difarsuwar Airfield', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Difarsuwar Airfield'}),
    GroupCommander:new({name = 'Melez-Support-Al Ismailiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Al Ismailiyah'}),
    GroupCommander:new({name = 'Melez-support-FARP-kibrit-air-base', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Kibrit Air Base'}),
    GroupCommander:new({name = 'Melez-Support-Bir Hasanah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Bir Hasanah'}),
    GroupCommander:new({name = 'Melez-support-Bir-Hasanah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Bir Hasanah'}),
    GroupCommander:new({name = 'Melez-Support-Bir-Hasanah', mission = 'supply',template='SupplyConvoy', targetzone = 'Bir Hasanah', type = 'surface'}),
    GroupCommander:new({name = 'Melez-Support-Sam-Golf', mission = 'supply',template='SupplyConvoy', targetzone = 'SAM-Golf', type = 'surface'}),
    GroupCommander:new({name = 'Melez-Support-Ramon Airbase', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Ramon Airbase'}),
    GroupCommander:new({name = 'Melez-Support-Ovda', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Ovda'}),
    GroupCommander:new({name = 'Melez-Support-El Arish', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'El Arish'}),

    GroupCommander:new({name = 'Melez-attack-RedCarrier-AntiShip', mission = 'attack',template='AntiShipPlaneTemplate', MissionType='ANTISHIP', targetzone = 'Red Carrier', Altitude = 25000}),
    GroupCommander:new({name = 'Melez-attack-SAM-India-Cap', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'SAM-India', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Melez-Attack-Ramon-Airbase-Cap', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Ramon Airbase', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Melez-attack-El Gora-Cap', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'El Gora', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Melez-attack-Kibrit Air Base-Cas', mission = 'attack',template='CasHeloTemplate', MissionType='CAS', targetzone = 'Kibrit Air Base'}),
    GroupCommander:new({name = 'Melez-attack-Al Ismailiyah-Cas', mission = 'attack',template='CasHeloTemplate', MissionType='CAS', targetzone = 'Al Ismailiyah'}),
    GroupCommander:new({name = 'Melez-attack-Ramon Airbase-Cas', mission = 'attack',template='CasPlaneTemplate', MissionType='CAS', targetzone = 'Ramon Airbase', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'Melez-Attack-Bir Hasanah-Cas', mission = 'attack',template='CasHeloTemplate', MissionType='CAS', targetzone = 'Bir Hasanah'}),
    GroupCommander:new({name = 'Melez-Attack-FARP-Kilo-Cas', mission = 'attack',template='CasHeloTemplate', MissionType='CAS', targetzone = 'FARP-Kilo'}),
    GroupCommander:new({name = 'Melez-Attack-FARP-Lima-Cas', mission = 'attack',template='CasHeloTemplate', MissionType='CAS', targetzone = 'FARP-Lima'}),
    GroupCommander:new({name = 'Melez-attack-Ramon Airbase-Sead', mission = 'attack',template='SeadPlaneTemplate', MissionType='SEAD', targetzone = 'Ramon Airbase', Altitude = SeadAltitude()}),
    GroupCommander:new({name = 'Melez-attack-Ramon Airbase-Runway', mission = 'attack',template='RunwayStrikePlaneTemplate', MissionType='RUNWAYSTRIKE', targetzone = 'Ramon Airbase', Altitude = RunwayStrikeAltitude()})
})

zones.baluza:addGroups({
    GroupCommander:new({name = 'Baluza-Support-SAM-Hotel', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Hotel'}),
    GroupCommander:new({name = 'Baluza-Support-Melez', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Melez'}),
    GroupCommander:new({name = 'Baluza-Support-FARP-Lima', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Lima'}),
    GroupCommander:new({name = 'Baluza-Support-As-Salihiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'As Salihiyah'}),
    GroupCommander:new({name = 'Baluza-Attack-El Arish', mission = 'attack',template='CasPlaneTemplate', MissionType='CAS', targetzone = 'El Arish', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'Baluza-Attack-Melez', mission = 'attack',template='CasHeloTemplate', MissionType='CAS', targetzone = 'Melez'})
})
zones.stcatherine:addGroups({
    GroupCommander:new({name = 'Catherine-Patrol-Ovda', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Ovda', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Catherine-Supply-SAM-Charlie', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Charlie'}),
    GroupCommander:new({name = 'Catherine-Supply-FARP-Bravo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Bravo'}),
    GroupCommander:new({name = 'Catherine-Supply-FARP-Charlie', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Charlie'}),
    GroupCommander:new({name = 'Catherine-Supply-FARP-Delta', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Delta'}),
    GroupCommander:new({name = 'Catherine-Supply-FARP-Echo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Echo'}),
    GroupCommander:new({name = 'Catherine-Supply-FARP-Golf', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Golf'}),
    GroupCommander:new({name = 'Catherine-Supply-FARP-Foxtrot', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Foxtrot'}),
    GroupCommander:new({name = 'Catherine-Supply-FARP-Hotel', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Hotel'}),
    GroupCommander:new({name = 'Catherine-Supply-Abu-Rudeis', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Abu Rudeis'}),
    GroupCommander:new({name = 'Catherine-Supply-Sharm-El-Sheikh', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Sharm El Sheikh International Airport'}),
    GroupCommander:new({name = 'Catherine-Attack-Ovda', mission = 'attack',template='CasPlaneTemplate', MissionType='CAS', targetzone = 'Ovda', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'Catherine-Patrol-Catherine', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Ovda', Altitude = CapAltitude()})
})

zones.sharmelsheikh:addGroups({
    GroupCommander:new({name = 'Sharm-el-sheikh-Supply-Hurghada', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Hurghada International Airport'}),
    GroupCommander:new({name = 'Sharm-el-sheikh-Supply-FARP-Echo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Echo'}),
    GroupCommander:new({name = 'Sharm-el-sheikh-Supply-chathrine', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'St Catherine'}),
    GroupCommander:new({name = 'Sharm-el-sheikh-Supply-Ovda', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Ovda'})
})
zones.aburudeis:addGroups({
    GroupCommander:new({name = 'AbuRudis-Patrol-Catherine', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'St Catherine', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'AbuRudeis-Supply-FARP-India', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-India'}),
    GroupCommander:new({name = 'AbuRudeis-Supply-SAM-Echo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Echo'}),
    GroupCommander:new({name = 'AbuRudeis-Supply-FARP-Juliett', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Juliett'}),
    GroupCommander:new({name = 'AbuRudis-Support-Catherine', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'St Catherine'}),
    GroupCommander:new({name = 'AbuRudis-Support-FARP-Golf', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Golf'}),
    GroupCommander:new({name = 'AbuRudis-Support-FARP-Hotel', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Hotel'}),
    GroupCommander:new({name = 'AbuRudis-Support-SAM-Delta', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Delta'}),
    GroupCommander:new({name = 'AbuRudis-Support-FARP-Juliett', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Juliett'}),
    GroupCommander:new({name = 'AbuRudis-Attack-Catherine', mission = 'attack',template='CasHeloTemplate', MissionType='CAS', targetzone='St Catherine'}),
    GroupCommander:new({name = 'AbuRudis-Attack-FARP-Golf', mission = 'attack',template='CasHeloTemplate', MissionType='CAS', targetzone='FARP-Golf'}),
    GroupCommander:new({name = 'AbuRudis-Attack-FARP-Hotel', mission = 'attack',template='CasHeloTemplate', MissionType='CAS', targetzone='FARP-Hotel'}),
    GroupCommander:new({name = 'AbuRudis-Attack-FARP-Foxtrot', mission = 'attack',template='CasHeloTemplate', MissionType='CAS', targetzone = 'FARP-Foxtrot'})
})

zones.hurghada:addGroups({
    GroupCommander:new({name = 'Hurghada-patrol-farp-foxtrot', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'FARP-Foxtrot', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Hurghada-patrol-St-Catherine', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'St Catherine', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Hurghada-Support-Farp-Foxtrot', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Foxtrot'})
})

zones.farphotel:addGroups({
    GroupCommander:new({name = 'FARP-hotel-support-sam-delta', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Delta'}),
    GroupCommander:new({name = 'FARP-hotel-attack-sam-delta', mission = 'attack',template='AttackConvoy', targetzone = 'SAM-Delta', type = 'surface'})
})
zones.farpindia:addGroups({
    GroupCommander:new({name = 'FARP-India-attack-Abu Rudeis', mission = 'attack',template='AttackConvoy', targetzone = 'Abu Rudeis', type = 'surface'})
})
zones.farpgolf:addGroups({
    GroupCommander:new({name = 'FARP-Golf-attack-FARP-Echo', mission = 'attack',template='AttackConvoy', targetzone = 'FARP-Echo', type = 'surface'})
})
zones.farpmike:addGroups({
    GroupCommander:new({name = 'Farp-Mike-Support-FARP-Juliett', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Juliett'}),
    GroupCommander:new({name = 'Farp-Mike-Support-FARP-India', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-India'}),
    GroupCommander:new({name = 'Farp-Mike-Support-Wadi-al-Jandali', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Wadi al Jandali'}),
    GroupCommander:new({name = 'Farp-Mike-Support-SAM-Echo', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Echo'}),
    GroupCommander:new({name = 'Farp-Mike-Support-Kibrit-Air-Base', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Kibrit Air Base'}),
    GroupCommander:new({name = 'Farp-Mike-Attack-FARP-Juliett', mission = 'attack', template='CasHeloTemplate', MissionType='CAS', targetzone = 'FARP-Juliett'}),
    GroupCommander:new({name = 'Farp-Mike-Attack-FARP-India', mission = 'attack', template='CasHeloTemplate', MissionType='CAS', targetzone = 'FARP-India'})
})

zones.farpjuliett:addGroups({
    GroupCommander:new({name = 'FARP-Juliett-Supply-FARP-Mike', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Mike'})
})
zones.farpfoxtrot:addGroups({
    GroupCommander:new({name = 'Farp-Foxtrot-Supply-Hurhgada', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Hurghada International Airport'})
})
zones.elarish:addGroups({
    GroupCommander:new({name = 'El-Arish-support-Farp-Lima', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Lima'}),
    GroupCommander:new({name = 'El-Arish-Supply-El-Gorah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'El Gora'}),
    GroupCommander:new({name = 'El-Arish-attack-El-Gorah', mission = 'attack',template='AttackConvoy', targetzone = 'El Gora',type='surface'}),
})
zones.almansurah:addGroups({
    GroupCommander:new({name = 'Al Mansurah-Support-Al Salihiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'As Salihiyah'}),
    GroupCommander:new({name = 'Al Mansurah-Support-SAM-Juliett', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Juliett'}),
    GroupCommander:new({name = 'Al Mansurah-Support-AzZaqaziq', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'AzZaqaziq'}),
    GroupCommander:new({name = 'Al Mansurah-attack-Abu Suwayr-RunwayStrike', mission = 'attack',template='RunwayStrikePlaneTemplate',MissionType='RUNWAYSTRIKE', targetzone = 'Abu Suwayr', Altitude = RunwayStrikeAltitude()}),
    GroupCommander:new({name = 'Al Mansurah-attack-Abu Suwayr-Cas', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Abu Suwayr', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'Al Mansurah-attack-As Salihiyah-Cas', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'As Salihiyah'}),
    GroupCommander:new({name = 'Al Mansurah-Support-Birma-Air-Base', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Birma Air Base'}),
})
zones.azzaqaziq:addGroups({
    GroupCommander:new({name = 'AzZaqaziq-Patrol-Red Carrier', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Red Carrier', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'AzZaqaziq-Support-As Salihiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'As Salihiyah'}),
    GroupCommander:new({name = 'AzZaqaziq-Support-Abu Suwayr', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Abu Suwayr'}),
    GroupCommander:new({name = 'AzZaqaziq-Support-Al Ismailiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Al Ismailiyah'}),
    GroupCommander:new({name = 'AzZaqaziq-Support-Difarsuwar', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Difarsuwar Airfield'}),
    GroupCommander:new({name = 'AzZaqaziq-Support-Fayed', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Fayed'}),
    GroupCommander:new({name = 'AzZaqaziq-Support-Kibrit', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Kibrit Air Base'}),
    GroupCommander:new({name = 'azzaqaziq-Supply-Al-Mansurah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Al Mansurah'}),
    GroupCommander:new({name = 'AzZaqaziq-Supply-Al-Mansurah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Al Mansurah'}),
    GroupCommander:new({name = 'AzZaqaziq-Supply-Bilbeis-air-base', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Bilbeis Air Base'}),
    GroupCommander:new({name = 'AzZaqaziq-Supply-Quwaysina', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Quwaysina'}),
    GroupCommander:new({name = 'AzZaqaziq-Attack-As Salihiyah', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'As Salihiyah'}),
    GroupCommander:new({name = 'AzZaqaziq-Attack-Abu Suwayr', mission = 'attack',template='CasHeloTemplate',MissionType='CAS', targetzone = 'Abu Suwayr'}),
    GroupCommander:new({name = 'AzZaqaziq-Attack-Fayed', mission = 'attack', template='CasHeloTemplate',MissionType='CAS', targetzone = 'Fayed'})
})


zones.wadialjandali:addGroups({
    GroupCommander:new({name = 'Wadi-Support-Beni-Suef', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Beni Suef'}),
    GroupCommander:new({name = 'Wadi-Support-Bilbeis-Kom-Awshim', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Kom Awshim'}),
    GroupCommander:new({name = 'Wadi-Support-Bilbeis-Air-Base', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Bilbeis Air Base'}),
    GroupCommander:new({name = 'Wadi-Support-Cairo-International-Airport', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Cairo International Airport'}),
    GroupCommander:new({name = 'Wadi-Support-Kom-Awshim', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Kom Awshim'}),
    GroupCommander:new({name = 'Wadi-Support-cairo-international-airport', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Cairo International Airport'}),
    GroupCommander:new({name = 'Wadi-Attack-Baluza-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'Baluza', Altitude = SeadAltitude()}),
    GroupCommander:new({name = 'Wadi-Attack-FARP-Mike', mission = 'attack',template='AttackConvoy', targetzone = 'FARP-Mike', type = 'surface'}),
    GroupCommander:new({name = 'Wadi-Attack-kibrit-air-base', mission = 'attack',template='AttackConvoy', targetzone = 'Kibrit Air Base', type = 'surface'}),
    GroupCommander:new({name = 'Wadi-Support-FARP-Mike', mission = 'supply',template='SupplyConvoy', targetzone = 'FARP-Mike', type = 'surface'}),
    GroupCommander:new({name = 'Wadi-al-jandali-support-Sam-Lima', mission = 'supply',template='SupplyConvoy', targetzone = 'SAM-Lima', type = 'surface'})
})

zones.fayed:addGroups({
    GroupCommander:new({name = 'Fayed-Patrol-Melez', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Fayed-Support-Difarsuwar-Airfield', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Difarsuwar Airfield'}),
    GroupCommander:new({name = 'Fayed-Support-abu-Suwayr', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Abu Suwayr'}),
    GroupCommander:new({name = 'Fayed-Support-Melez', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Melez'}),
    GroupCommander:new({name = 'Fayed-Support-Wadi-Al-Jandali', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Wadi al Jandali'}),
    GroupCommander:new({name = 'Fayed-Supply-difarsuwar-airfiled', mission = 'supply',template='SupplyConvoy', targetzone = 'Difarsuwar Airfield', type = 'surface'})
})
zones.alismailiyah:addGroups({
    GroupCommander:new({name = 'ismailiyah-Patrol-Melez', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'ismailiyah-support-difarsuwar', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Difarsuwar Airfield'}),
    GroupCommander:new({name = 'ismailiyah-support-assalihiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'As Salihiyah'})
})
zones.bilbeisairbase:addGroups({
    GroupCommander:new({name = 'bilbeis-air-base-Supply-insha-air-base', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Inshas Airbase'}),

})
zones.abusuwayr:addGroups({
    GroupCommander:new({name = 'Abu-Suway-Support-Azzaqaziq', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'AzZaqaziq'}),
    GroupCommander:new({name = 'Abu-Suwayr-attack-Melez', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Abu-Suwayr-Attack-Al-Salihiyah', mission = 'attack',template='AttackConvoy', targetzone = 'As Salihiyah', type = 'surface'})

})
zones.assalihiyah:addGroups({
    GroupCommander:new({name = 'As-Salihiyah-Patrol-Melez', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'As-Salihiyah-Supply-Baluza', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Baluza'}),
    GroupCommander:new({name = 'As-Salihiyah-supply-al-ismailiyah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Al Ismailiyah'}),
    GroupCommander:new({name = 'As-Salihiyah-Supply-AzZaqaziq', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'AzZaqaziq'}),
    GroupCommander:new({name = 'As-Salihiyah-Supply-almansurah', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Al Mansurah'}),
    GroupCommander:new({name = 'As-Salihiyah-attack-Melez-Cap', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Melez', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'As-Salihiyah-attack-Melez-Cas', mission = 'attack',template='CasPlaneTemplate', MissionType='CAS', targetzone = 'Melez', Altitude = CasAltitude()}),
    GroupCommander:new({name = 'As-Salihiyah-Support-Sam-India', mission = 'supply',template='SupplyConvoy', targetzone = 'SAM-India', type = 'surface'}),
    GroupCommander:new({name = 'As-Salihiyah-attack-Melez', mission = 'attack',template='AttackConvoy', targetzone = 'Melez', type = 'surface'})
})

zones.kibritairbase:addGroups({
    GroupCommander:new({name = 'Kibrit-Air-Base-support-fayed', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Fayed'}),
    GroupCommander:new({name = 'Kibrit-Air-Base-Support-Fayed', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Fayed'}),
    GroupCommander:new({name = 'Kibrit Air Base-supply-Farp-Mike', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'FARP-Mike'}),
    GroupCommander:new({name = 'Kibrit-Air-Base-support-sam-foxtrot', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Foxtrot'}),
    GroupCommander:new({name = 'Kibrit-Air-Base-patrol-Patrol-Abu-Rudeis', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'St Catherine', Altitude = CapAltitude()})
})
zones.inshasairbase:addGroups({
    GroupCommander:new({name = 'Inshas-Airbase-patrol-al-ismailiyah', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Al Ismailiyah', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Inshas-Airbase-patrol-SAM-Juliett', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'SAM-Juliett', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'Inshas-AirBase-Support-Cairo-International', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Cairo International Airport'}),
    GroupCommander:new({name = 'Inshas-AirBase-Support-As Salihiyah', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'As Salihiyah'}),
    GroupCommander:new({name = 'Inshas-AirBase-Support-Fayed', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Fayed'}),
    GroupCommander:new({name = 'Inshas-AirBase-Support-Cairo-West', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Cairo West'})
})
zones.komawshim:addGroups({
    GroupCommander:new({name = 'Kom-Awshim-Support-Beni-Suef', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Beni Suef'}),
    GroupCommander:new({name = 'Kom-Awshim-Support-Cairo West', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'Cairo West'})
})
zones.birmaairbase:addGroups({
    GroupCommander:new({name = 'Birma-Air-Base-attack-Abu-swayr', mission = 'attack',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Abu Suwayr', Altitude = CapAltitude()}),
})
zones.quwaysina:addGroups({
    GroupCommander:new({name = 'Quwaysina-supply-Birma-Air-Base', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Birma Air Base'}),
	GroupCommander:new({name = 'Quwaysina-attack-As Salihiyah-Cas', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'As Salihiyah', Altitude = CasAltitude()}),
	GroupCommander:new({name = 'Quwaysina-attack-Kibrit Air Base-Cas', mission = 'attack',template='CasPlaneTemplate',MissionType='CAS', targetzone = 'Kibrit Air Base', Altitude = CasAltitude()}),
	GroupCommander:new({name = 'Quwaysina-attack-Kibrit Air Base-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'Kibrit Air Base', Altitude = SeadAltitude()}),
	GroupCommander:new({name = 'Quwaysina-attack-As Salihiyah-Sead', mission = 'attack',template='SeadPlaneTemplate',MissionType='SEAD', targetzone = 'As Salihiyah', Altitude = SeadAltitude()}),
	GroupCommander:new({name = 'Quwaysina-patrol-AzZaqaziq-Cap', mission = 'patrol',template='CapPlaneTemplate',MissionType='CAP', targetzone = 'AzZaqaziq', Altitude = CapAltitude()}),
})
zones.cairowest:addGroups({
    GroupCommander:new({name = 'CairoWest-Patrol-Wadi', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Wadi al Jandali', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'CairoWest-Patrol-AzZaqaziq', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'AzZaqaziq', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'CairoWest-Patrol-Cario-West', mission = 'patrol',template='CapPlaneTemplate', MissionType='CAP', targetzone = 'Cairo West', Altitude = CapAltitude()}),
    GroupCommander:new({name = 'CairoWest-Support-Melez', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Melez'}),
    GroupCommander:new({name = 'CairoWest-Support-SAM-Mike', mission = 'supply',template='HeloSupplyTemplate', targetzone = 'SAM-Mike'}),
    GroupCommander:new({name = 'CairoWest-Support-Wadi', mission = 'supply',template='PlaneSupplyTemplate', targetzone = 'Wadi al Jandali'})
})

function SpawnFriendlyAssets()
	
	if zones.redcarrier.wasBlue then
		trigger.action.setMarkupTypeLine(zones.bluecarrier.index, 0)
	end
end

if zones.secrettechfacility.side == 0 then
	zones.secrettechfacility:disableZone()

end
	
timer.scheduleFunction(SpawnFriendlyAssets, {}, timer.getTime() + 8)


zones.secrettechfacility:addCriticalObject('Secret Tech Factory')
zones.secrettechfacility:addCriticalObject('Secret Tech Command Center')
zones.secrettechfacility:addCriticalObject('Secret Tech Bulding')

zones.bluecarrier.isHeloSpawn = true
zones.bengurion.isHeloSpawn = true

zones.redcarrier.isHeloSpawn = true
zones.hatzor.isHeloSpawn = true

zones.kedemhatzerim.isHeloSpawn = true
zones.nevatim.isHeloSpawn = true
zones.ramonairbase.isHeloSpawn = true
zones.elgora.isHeloSpawn = true
zones.elarish.isHeloSpawn = true
zones.ovda.isHeloSpawn = true
zones.stcatherine.isHeloSpawn = true
zones.sharmelsheikh.isHeloSpawn = true
zones.hurghada.isHeloSpawn = true
zones.aburudeis.isHeloSpawn = true
zones.birhasanah.isHeloSpawn = true
zones.melez.isHeloSpawn = true
zones.baluza.isHeloSpawn = true
zones.assalihiyah.isHeloSpawn = true
zones.alismailiyah.isHeloSpawn = true
zones.abusuwayr.isHeloSpawn = true
zones.difarsuwarairfield.isHeloSpawn = true
zones.fayed.isHeloSpawn = true
zones.kibritairbase.isHeloSpawn = true
zones.almansurah.isHeloSpawn = true
zones.azzaqaziq.isHeloSpawn = true
zones.bilbeisairbase.isHeloSpawn = true
zones.inshasairbase.isHeloSpawn = true
zones.cairointernationalairport.isHeloSpawn = true
zones.wadialjandali.isHeloSpawn = true
zones.cairowest.isHeloSpawn = true
zones.benisuef.isHeloSpawn = true
zones.quwaysina.isHeloSpawn = true
zones.komawshim.isHeloSpawn = true
zones.birmaairbase.isHeloSpawn = true
zones.farpalpha.isHeloSpawn = true
zones.farpbravo.isHeloSpawn = true
zones.farpcharlie.isHeloSpawn = true
zones.farpdelta.isHeloSpawn = true
zones.farpecho.isHeloSpawn = true
zones.farpfoxtrot.isHeloSpawn = true
zones.farpgolf.isHeloSpawn = true
zones.farphotel.isHeloSpawn = true
zones.farpindia.isHeloSpawn = true
zones.farpjuliett.isHeloSpawn = true
zones.farpkilo.isHeloSpawn = true
zones.farplima.isHeloSpawn = true
zones.farpmike.isHeloSpawn = true



zones.bengurion.airbaseName = "Ben-Gurion"
zones.telnof.airbaseName = "Tel Nof"
zones.hatzor.airbaseName = "Hatzor"
zones.kedemhatzerim.airbaseName = "Hatzerim"
zones.nevatim.airbaseName = "Nevatim"
zones.ramonairbase.airbaseName = "Ramon Airbase"
zones.elgora.airbaseName = "El Gora"
zones.elarish.airbaseName = "El Arish"
zones.ovda.airbaseName = "Ovda"
zones.stcatherine.airbaseName = "St Catherine"
zones.sharmelsheikh.airbaseName = "Sharm El Sheikh International Airport"
zones.hurghada.airbaseName = "Hurghada International Airport"
zones.aburudeis.airbaseName = "Abu Rudeis"
zones.birhasanah.airbaseName = "Bir Hasanah"
zones.melez.airbaseName = "Melez"
zones.baluza.airbaseName = "Baluza"
zones.assalihiyah.airbaseName = "As Salihiyah"
zones.alismailiyah.airbaseName = "Al Ismailiyah"
zones.abusuwayr.airbaseName = "Abu Suwayr"
zones.difarsuwarairfield.airbaseName = "Difarsuwar Airfield"
zones.fayed.airbaseName = "Fayed"
zones.kibritairbase.airbaseName = "Kibrit Air Base"
zones.almansurah.airbaseName = "Al Mansurah"
zones.azzaqaziq.airbaseName = "AzZaqaziq"
zones.bilbeisairbase.airbaseName = "Bilbeis Air Base"
zones.inshasairbase.airbaseName = "Inshas Airbase"
zones.cairointernationalairport.airbaseName = "Cairo International Airport"
zones.wadialjandali.airbaseName = "Wadi al Jandali"
zones.cairowest.airbaseName = "Cairo West"
zones.benisuef.airbaseName = "Beni Suef"
zones.quwaysina.airbaseName = "Quwaysina"
zones.komawshim.airbaseName = "Kom Awshim"
zones.birmaairbase.airbaseName = "Birma Air Base"
zones.farpalpha.airbaseName = "FARP Alpha"
zones.farpbravo.airbaseName = "FARP Bravo"
zones.farpcharlie.airbaseName = "FARP Charlie"
zones.farpdelta.airbaseName = "FARP Delta"
zones.farpecho.airbaseName = "FARP Echo"
zones.farpfoxtrot.airbaseName = "FARP Foxtrot"
zones.farpgolf.airbaseName = "FARP Golf"
zones.farphotel.airbaseName = "FARP Hotel"
zones.farpindia.airbaseName = "FARP India"
zones.farpjuliett.airbaseName = "FARP Juliett"
zones.farpkilo.airbaseName = "FARP Kilo"
zones.farplima.airbaseName = "FARP Lima"
zones.farpmike.airbaseName = "FARP Mike"

zones.hatzor.LogisticCenter = true
zones.telnof.LogisticCenter = true
zones.bengurion.LogisticCenter = true

function checkAndDisableFriendlyZones()

    
	if zones.redcarrier.wasBlue then
		trigger.action.setMarkupTypeLine(zones.bluecarrier.index, 0)
		activateGroupIfNotActive('CVN-73')
		activateGroupIfNotActive('CVN-59')
		activateGroupIfNotActive('HMS Invincible')
		timer.scheduleFunction(function()
		checkWeaponsList('CVN-73')
		checkWeaponsList('CVN-59')
		checkWeaponsList('HMS Invincible')
		end, {}, timer.getTime() + 3)
		destroyGroupIfActive('CVN-72')
		destroyGroupIfActive('CVN-74')
	end
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
bc:addConnection("Kedem-Hatzerim","Nevatim")
bc:addConnection("Kedem-Hatzerim","Ramon Airbase")
bc:addConnection("Kedem-Hatzerim","El Gora")
bc:addConnection("El Gora","El Arish")
bc:addConnection("Ramon Airbase","FARP-Alpha")
bc:addConnection("Ramon Airbase","Nevatim")
bc:addConnection("Ramon Airbase","El Gora")
bc:addConnection("FARP-Alpha","Ovda")
bc:addConnection("Ovda","FARP-Bravo")
bc:addConnection("FARP-Bravo","FARP-Charlie")
bc:addConnection("FARP-Charlie","FARP-Delta")
bc:addConnection("FARP-Charlie","St Catherine")
bc:addConnection("St Catherine","FARP-Delta")
bc:addConnection("St Catherine","FARP-Echo")
bc:addConnection("St Catherine","Sharm El Sheikh International Airport")
bc:addConnection("Sharm El Sheikh International Airport","Hurghada International Airport")
bc:addConnection("Hurghada International Airport","FARP-Echo")
bc:addConnection("St Catherine","FARP-Golf")
bc:addConnection("FARP-Foxtrot","SAM-Delta")
bc:addConnection("FARP-Echo","FARP-Foxtrot")
bc:addConnection("FARP-Golf","FARP-Foxtrot")
bc:addConnection("FARP-Mike","Bir Hasanah")
bc:addConnection("FARP-Golf","FARP-Hotel")
bc:addConnection("FARP-Hotel","Abu Rudeis")
bc:addConnection("Abu Rudeis","FARP-India")
bc:addConnection("FARP-India","FARP-Juliett")
bc:addConnection("FARP-Juliett","FARP-Mike")

bc:addConnection("FARP-Alpha","FARP-Kilo")
bc:addConnection("Bir Hasanah","Melez")
bc:addConnection("Melez","FARP-Lima")
bc:addConnection("FARP-Lima","Baluza")
bc:addConnection("As Salihiyah","Al Ismailiyah")
bc:addConnection("As Salihiyah","Abu Suwayr")
bc:addConnection("AzZaqaziq","Al Mansurah")
bc:addConnection("Abu Suwayr", "Difarsuwar Airfield")
bc:addConnection("Al Ismailiyah", "Difarsuwar Airfield")
bc:addConnection("Difarsuwar Airfield", "Fayed")
bc:addConnection("Fayed", "Kibrit Air Base")
bc:addConnection("Kibrit Air Base", "Wadi al Jandali")
bc:addConnection("Bilbeis Air Base", "AzZaqaziq")
bc:addConnection("Bilbeis Air Base", "Inshas Airbase")
bc:addConnection("Inshas Airbase", "Cairo International Airport")
bc:addConnection("Cairo International Airport", "Wadi al Jandali")
bc:addConnection("Cairo West", "Quwaysina")
bc:addConnection("Cairo West", "Quwaysina")
bc:addConnection("Birma Air Base", "Quwaysina")
bc:addConnection("Cairo West", "Kom Awshim")
bc:addConnection("Beni Suef", "Kom Awshim")

bc:addConnection("Hatzor","SAM-Alpha")
bc:addConnection("Ramon Airbase","SAM-Bravo")
bc:addConnection("St Catherine","SAM-Charlie")
bc:addConnection("FARP-Golf","SAM-Delta")
bc:addConnection("FARP-India","SAM-Echo")
bc:addConnection("Bir Hasanah","SAM-Foxtrot")
bc:addConnection("Melez","SAM-Golf")
bc:addConnection("Baluza","SAM-Hotel")
bc:addConnection("Baluza","Red Carrier")
bc:addConnection("As Salihiyah","Red Carrier")
bc:addConnection("As Salihiyah","SAM-India")
bc:addConnection("Al Mansurah","SAM-Juliett")
bc:addConnection("Birma Air Base","SAM-Juliett")
bc:addConnection("Beni Suef","SAM-Kilo")
bc:addConnection("Wadi al Jandali","SAM-Lima")
bc:addConnection("Birma Air Base","SAM-Mike")

bc:addConnection("Sharm El Sheikh International Airport","SecretTechFacility")
bc:addConnection("Ovda","SecretTechFacility")
bc:addConnection("Ovda","InsurgentCamp")
bc:addConnection("Sharm El Sheikh International Airport","FuelDepo")
bc:addConnection("Bir Hasanah","ChemSite")
bc:addConnection("Ramon Airbase","MiningFacility")
bc:addConnection("Cairo West","MissileFactory")
bc:addConnection("Beni Suef","TankFactory")
bc:addConnection("AmmonitionDepo","Hurghada International Airport")
bc:addConnection("Al Mansurah","ArtilleryFactory")



Group.getByName('Ramon-Forces-attack'):destroy()
zones.ramonairbase:registerTrigger('captured', function(event,sender)
	local kr = bc:getZoneByName('Ramon Airbase')
	local kr2 = bc:getZoneByName('Melez')
	if kr.side == 2 and not CustomFlags['ramonairbasecaptured'] and kr2.side == 1 then
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
MGRS: 36 R VU 66855 52517
Lat long: N 30°18'14" E 32°39'19"
Lat long Decimal Minutes: N 30°18.237' E 32°39.317'

Elevation: 526 feet]], 30)
    end, {}, timer.getTime() + math.random(360, 480))
end
end, 'melezcaptured')


zones.tankfactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Tank Factroy cleared\n+500 credits',20)
end, 'disabletankfactory')

zones.fueldepo:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Fuel Depo disabled, Great job!\n+500 credits',20)
end, 'disablefueldepo')


zones.miningfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Mining Facility cleared\n+500 credits',20)
end, 'disableminingfacility')


zones.ammonitiondepo:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Ammunition Depo cleared\n+500 credits',20)
end, 'disableammonitiondepo')

zones.insurgentcamp:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Insurgent Camp destroyed, Good job\n+500 credits',20)
end, 'disableinsurgentcamp')


zones.chemsite:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'chemical site destroyed, Good job\n+500 credits',20)
end, 'disablechemsite')


zones.missilefactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Missile Factroy destroyed, Good job\n+500 credits',20)
end, 'disablemissilefactory')


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
		'Red Armor Group7',
		'Red Armor Group8',
		"Red SAM AAA 2 #",
		"Red SAM SHORAD SA-8 2 #",
		"Red SAM SHORAD SA-15 2 #",
		"Red SAM SHORAD SA-19 2 #",
		"Molniya #",
		"Moskva #",
	}, 30)
	else
	bc:roamGroupsToLocalSubZone({
		"Red Armour Group #",
		"Red SAM AAA 2 #",
		"Red Armor Group 2 #",
		"Red SAM SHORAD SA-8 2 #",
		"Red SAM SHORAD SA-15 2 #",
		"Red SAM SHORAD SA-19 2 #",
		"Molniya #",
		"Neustrashimy #",
		"Moskva #",
	}, 30)
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

bc:registerShopItem('dynamiccas', 'Dynamic CAS', 500,
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
bc:registerShopItem('Dynamicstatic', 'Dynamic building Strike', 500,
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
bc:registerShopItem('supplies', 'Resupply friendly Zone', 149, function(sender)
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

Group.getByName('ca-tanks-Coldwar'):destroy()
Group.getByName('ca-tanks'):destroy()
tanksMenu = nil
bc:registerShopItem('armor', 'Deploy armor (for combined arms) ', 300, function(sender)
	
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
	if params.zone and params.zone.side == 2 then
		
		local zn = CustomZone:getByName(params.zone.zone)
		zn:spawnGroup((Era == 'Coldwar') and 'ca-tanks-Coldwar' or 'ca-tanks')
		trigger.action.outTextForCoalition(2, 'Friendly armor deployed at '..params.zone.zone, 15)
	else
		return 'Can only deploy at friendly zone'
	end
end)

artyMenu = nil
bc:registerShopItem('artillery', 'Deploy artillery (for combined arms) ', 200, function(sender)
	
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
	if params.zone and params.zone.side == 2 then
		
		local zn = CustomZone:getByName(params.zone.zone)
		zn:spawnGroup('ca-arty')
		trigger.action.outTextForCoalition(2, 'Friendly artillery deployed at '..params.zone.zone, 15)
	else
		return 'Can only deploy at friendly zone'
	end
end)

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
	if params.zone and params.zone.side == 2 then
		
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
    if params.zone and params.zone.side == 1 then
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
bc:registerShopItem('capture','Emergency capture neutral zone',500,
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
bc:registerShopItem('farphere','Deploy FARP',1000,function(sender)
        return 'Deploy a FARP via map marker.\nUse marker text: buy:farphere.\nMust be outside all zones and at least 10 NM from enemy zones.'
end,function(_, params)
        return bc:processMapFarpPurchase(params)
end)
------------------------------------------- End of Zone upgrades ----------------------------------------

-- first value below is how much in stock, the other number value is the ranking in the shop menu list, the third is the ranking system number.
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
	'St Catherine',
	'Abu Rudeis',
	'Bir Hasanah',
	'Melez',
	'Baluza',
	'Al Mansurah',
	'As Salihiyah',
	'Al Ismailiyah',
	'Abu Suwayr',
	'AzZaqaziq',
	'Difarsuwar Airfield',
	'Fayed',
	'Kibrit Air Base',
	'Bilbeis Air Base',
	'Inshas Airbase',
	'Cairo International Airport',
	'Wadi al Jandali',
	'Cairo West',
	'Sharm El Sheikh International Airport',
	'Hurghada International Airport',
	'Beni Suef',
	'Birma Air Base',
	
	'FARP-Alpha',
	'FARP-Bravo',
	'FARP-Charlie',
	'FARP-Delta',
	'FARP-Echo',
	'FARP-Foxtrot',
	'FARP-Golf',
	'FARP-Hotel',
	'FARP-India',
	'FARP-Juliett',
	'FARP-Kilo',
	'FARP-Lima',
	'FARP-Mike',
	'Quwaysina',
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

--------------------------------- Secret Tech Facility --------------------------------
evc:addEvent({
	id = 'secrettechFactory',
		action = function()
		local z = zones.secrettechfacility
		if not z then return end
		RegisterStaticGroup('SecretTechFactories', z, 750, 'Secret Tech Factories', 'SecretTechFactories')
	end,
	canExecute = function()
		if ActiveMission['SecretTechFactories'] then return false end
		if CustomFlags['SecretTechFactories'] then return false end
		if not bc:getZoneByName('SecretTechFacility').active or bc:getZoneByName('SecretTechFacility').suspended then return false end
		local abu = bc:getZoneByName('Sharm El Sheikh International Airport')
		if abu.side ~= 2 or abu.suspended then return false end
		return true
	end,
})

mc:trackMission({
	title = "Strike on SecretTechFacility factories",
	description =
[[3 Secret Tech Facility targets has been identified.
Destroy them to get rid of this enemy base and
all of the activity in it.

2000 LBS Penetrator bomb is required.
Reward: 750

Target 1: Command center
MGRS: 37 R BM 60888 37285
Lat long: N 28°20'24" E 36°33'38"
Lat long Precise: N 28°20'24.05" E 36°33'38.86"
Lat long Decimal Minutes: N 28°20.400' E 36°33.647'
Elevation 2499 feet

Targets 2: Factory
MGRS: 37 R BM 60836 37586
Lat long: N 28°20'33" E 36°33'36"
Lat long Precise: N 28°20'33.78" E 36°33'36.74"
Lat long Decimal Minutes: N 28°20.563' E 36°33.612'
Elevation 2493 feet

Targets 3: Building
MGRS: 37 R BM 60832 37389
Lat long: N 28°20'27" E 36°33'36"
Lat long Precise: N 28°20'27.40" E 36°33'36.75"
Lat long Decimal Minutes: N 28°20.456' E 36°33.612'
Elevation 2494 feet]],
	messageStart = "New strike mission: Strike on SecretTechFacility factories",
	messageEnd = "Strike mission ended: On SecretTechFacility factories",
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
		if CustomFlags['SecretTechFactories'] then return false end
		if ActiveMission['SecretTechFactories'] then return true end
		return false
	end
})

---------------------------- Cargo plane intercept mission -----------------------------
Group.getByName('evt-cargointercept1'):destroy()
Group.getByName('evt-cargointercept2'):destroy()
Group.getByName('evt-cargointercept3'):destroy()
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
		local quwaysina = bc:getZoneByName('Quwaysina')
		local cairowest = bc:getZoneByName('Cairo West')
		if quwaysina.side ~= 1 or quwaysina.suspended then return false end
		if cairowest.side ~= 1 or cairowest.suspended then return false end
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
------------------------- End of Cargo plane intercept mission ----------------------
--------------------------------- Escort cargo plane --------------------------------
Group.getByName('escort-me'):destroy()
Group.getByName('interceptor-1'):destroy()
Group.getByName('interceptor-2'):destroy()
evc:addEvent({
	id='escort',
	action = function()
		RespawnGroup('escort-me')
		local spawnIntercept = function(groupname)
		local function spawnIntercept(args)
			local groupname = args[1]
				local g = Group.getByName(groupname)
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
        SCHEDULER:New(nil, spawnIntercept, {'interceptor-1'}, timers[1])
        SCHEDULER:New(nil, spawnIntercept, {'interceptor-2'}, timers[2])
	end,
	canExecute = function()
		local gr = Group.getByName('escort-me')
		if gr then return false end
		local triggers = {'Ramon Airbase', 'Melez', 'Kedem-Hatzerim', 'El Gora', 'El Arish'}
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
    description = "Friendly cargo plane is taking off from Ben Gurion going south. Protect it until it leaves the airspace.",
    messageStart = "New mission: Escort cargo plane from Ben Gurion",
    messageEnd = "Mission ended: Escort cargo plane",
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
------------------------------- End Escort cargo plane ----------------------------------
-------------------------------- Intercept enemy bombers --------------------------------
local bomb_COOLDOWN = 7200
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
			'Ramon Airbase','Melez','St Catherine','Ovda','Wadi al Jandali','Al Ismailiyah',
			'AzZaqaziq','Birma Air Base','Bilbeis Air Base','Cairo International Airport',
			'Al Mansurah','As Salihiyah','Cairo West','Quwaysina'}
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
    end,
	isActive = function()
		local gr = Group.getByName('evt-bomb')
		if gr then return true else return false end
	end
})

----------------------- End of Intercept enemy bombers ----------------------------
------------------------- Intercept enemy airstrike --------------------------------
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
				'St Catherine',
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
		if g1 or g2 then
			return true
		else
			return false
		end
	end
})

------------------------- End of Intercept enemy airstrike -------------------------
-- scenery and missions

local sceneryList = {
  ["FactoryStrike"] = {SCENERY:FindByZoneName("FactoryStrike")},
  ["factoryBulding3"] = {SCENERY:FindByZoneName("factoryBulding3")},
  ["factoryBulding2"] = {SCENERY:FindByZoneName("factoryBulding2")},
  ["factoryBulding"] = {SCENERY:FindByZoneName("factoryBulding")},
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
------------------------------ FactoryStrike mission -----------------------------
Group.getByName('FactoryStrike'):destroy()
Group.getByName('Red SAM SA-3 Fixed SAM'):destroy()
SecondManEvent = nil
evc:addEvent({
	id = 'FactoryStrike',
	action = function()
		RespawnGroup('FactoryStrike')
		RegisterGroupTarget('FactoryStrike',500,'Factory Strike','FactoryStrike')
	end,
	canExecute = function()
		if CustomFlags['FactoryStrike'] then return false end
		if bc:getZoneByName('Wadi al Jandali').side ~= 2 or not bc:getZoneByName('Wadi al Jandali').suspended then return false end
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
----------------------------End of FactoryStrike mission --------------------------
----------------------------- factoryBulding3 mission -----------------------------
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
		if bc:getZoneByName('Ramon Airbase').side ~= 2 or not bc:getZoneByName('Ramon Airbase').suspended then return false end
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
	messageEnd = "Strike mission ended: Strike High value factory",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function() end,
	isActive = function()
	if CustomFlags["factoryBulding3"] then return false end
	if ActiveMission['factoryBulding3'] then return true end
	  return false
	end,
})
---------------------------------- End factoryBulding3 mission ---------------------------
------------------------------------ factoryBulding2 mission -----------------------------
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
		if bc:getZoneByName('As Salihiyah').side ~= 2 or not bc:getZoneByName('As Salihiyah').suspended then return false end
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
------------------------- end of factoryBulding2 mission --------------------------
------------------------------ factoryBulding mission -----------------------------
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
		if bc:getZoneByName('Melez').side ~= 2 or not bc:getZoneByName('Melez').suspended then return false end
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
-----------------------------End of factoryBulding mission --------------------------
---------------------------------- SCUDS mission ------------------------------------
Group.getByName('Quwaysina-Scuds'):destroy()
evc:addEvent({
	id='Quwaysinascuds',
	action = function()
		RespawnGroup('Quwaysina-Scuds')
		RegisterGroupTarget('Quwaysina-Scuds',250,'Destroy SCUDS mission')
		timer.scheduleFunction(function(param, time)
			if Group.getByName('Quwaysina-Scuds') then
				local tgts = {
					'Melez',
					'As Salihiyah',
					'Al Ismailiyah',
					'Kibrit Air Base',
					'Difarsuwar Airfield',
					'Abu Suwayr',
					'Baluza',
					'St Catherine'
				}
				local validtgts = {}
				for _,v in ipairs(tgts) do
					if bc:getZoneByName(v).side == 2 then
						table.insert(validtgts, v)
					end
				end
				if #validtgts == 0 then return time+(10*60) end
				
				local die = math.random(1,#validtgts)
				local choice = validtgts[die]
				bc:fireAtZone(choice, 'Quwaysina-Scuds', false, 8)
				trigger.action.outTextForCoalition(2, 'SCUDS near Quwaysina are launching at '..choice, 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
		if math.random(1, 100) > 50 then return false end
		local gr = Group.getByName('Quwaysina-Scuds')
		if gr then return false end
		if bc:getZoneByName('Quwaysina').side ~= 1 or not bc:getZoneByName('Quwaysina').suspended then return false end
		local triggers = {'Melez', 'St Catherine', 'Baluza', 'Kibrit Air Base'}
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
				return true
			end
		end
		
		return false
	end
})
mc:trackMission({
	title = "Destroy SCUDS",
	description = "SCUDS have been spotted at Quwaysina.\nDestroy them before they can launch their missiles",
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
----------------------------------- End of SCUDS mission -----------------------------
----------------------------------- Baluza SCUDS mission -----------------------------

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
                    'St Catherine',
                    'FARP-Bravo',
                    'FARP-Charlie',
                    'FARP-Delta'
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
                trigger.action.outTextForCoalition(2, 'SCUDS near Baluza are launching at '..choice, 15)
            end
        end, {}, timer.getTime()+(20*60))
    end,
    
    canExecute = function()
        if math.random(1, 100) > 50 then return false end
        local gr = Group.getByName('Baluza-Scuds')
        if gr then return false end
		local Baluza = bc:getZoneByName('Baluza')
		local Melez = bc:getZoneByName('Melez')
        if Baluza.side ~= 1 or Baluza.suspended then return false end
        if Melez.side ~= 2 or Melez.suspended then return false end
        local triggers = {'Ramon Airbase', 'El Gora', 'St Catherine', 'Ovda'}
        for _,v in ipairs(triggers) do
            if bc:getZoneByName(v).side == 2 and not bc:getZoneByName(v).suspended then
                return true
            end
        end
        return false
    end
})
mc:trackMission({
	title = "Destroy SCUDS",
	description = "SCUDS have been spotted at Baluza.\nDestroy them before they can launch their missiles",
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
---------------------------------End Baluza SCUDS mission -----------------------------------
---------------------------- Destroy cargo & battle ships mission ---------------------------
Group.getByName('evt-shiptercept1'):destroy()
Group.getByName('evt-shiptercept2'):destroy()
Group.getByName('evt-shiptercept3'):destroy()
local shipDieEvent = nil
evc:addEvent({
	id = 'shiptercept',
	action = function()
		local ships = {}
		local mike = bc:getZoneByName('FARP-Mike')
		local bravo = bc:getZoneByName('FARP-Bravo')
		if not Group.getByName('evt-shiptercept1') and mike.side == 1 and not mike.suspended and bravo.side == 2 and not bravo.suspended then table.insert(ships, 'evt-shiptercept1') end
		if not Group.getByName('evt-shiptercept2') then table.insert(ships, 'evt-shiptercept2') end
		if not Group.getByName('evt-shiptercept3') then table.insert(ships, 'evt-shiptercept3') end
		if #ships == 0 then return end
		local choice = math.random(1, #ships)
		RespawnGroup(ships[choice])
		RegisterGroupTarget(ships[choice],500,'Cargo ship','Destroy Ships mission')
	end,
	canExecute = function()
		if math.random(1,100) < 70 then return false end
		if Group.getByName('evt-shiptercept1') then return false end
		if Group.getByName('evt-shiptercept2') then return false end
		if Group.getByName('evt-shiptercept3') then return false end
		return true
	end
})

mc:trackMission({
	title = "Destroy cargo & battle ships",
	description = function()
		if Group.getByName('evt-shiptercept1') then
			return "Intercept and destroy the enemy supply ship near FARP-Mike headed to FARP-Bravo."
		else
			return "Find and destroy the enemy cargo & battle ships sailing.\n\nDestroy the ships!"
		end
	end,
	messageStart = "New mission: Destroy cargo & battle ships",
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
		if Group.getByName('evt-shiptercept1') then return true end
		if Group.getByName('evt-shiptercept2') then return true end
		if Group.getByName('evt-shiptercept3') then return true end
		
		return false
	end
})
------------------------- End of Destroy cargo & battle ships mission ---------------------------
----------------------------- Salihiyah artillery attack mission --------------------------------
Group.getByName('evt-Salihiyah-attack-melez-art'):destroy()
evc:addEvent({
    id = 'artilleryattack',
    action = function()
		RespawnGroup('evt-Salihiyah-attack-melez-art')
		RegisterGroupTarget('evt-Salihiyah-attack-melez-art',250,'Destroy artillery')
    end,
    canExecute = function()
        if math.random(1, 100) < 60 then return false end
		if bc:getZoneByName('As Salihiyah').side ~= 1 then return false end
        if bc:getZoneByName('Melez').side ~= 2 then return false end
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
--                 END OF RUNWAY STRIKE MISSION                   --

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
        reward = 1000,
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
					trigger.action.outTextForGroup(groupID, "Mission failed:\n\nConvoy was destroyed\n\nRestart the mission from the radio menu", 30)
					removeMissionMenuForAll(mission.zone, groupID)
					if trackedGroups[groupName] then
						trackedGroups[groupName] = nil
						handleMission(zoneName, groupName, groupID, group)
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
						if grp then
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
				end
				if missionGroupIDs[zoneName] then
					for groupName, data in pairs(missionGroupIDs[zoneName]) do
						local groupID = data.groupID
						local group   = data.group
						removeMissionMenuForAll(mission.zone, groupID)
						if trackedGroups[groupName] then
							trackedGroups[groupName] = nil
						end
						destroyGroupIfActive(mission.missionGroup)
						timer.scheduleFunction(function()
							handleMission(mission.TargetZone, groupName, groupID, group)
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
					msg = "Escort mission completed\ncredit " .. reward .. " - land to redeem"
				end
				trigger.action.outSoundForCoalition(2, "ding.ogg")
				trigger.action.outTextForCoalition(2, msg, 20)
				return true
			end
			return false
		end,
        isActive = function()
            local targetZone = bc:getZoneByName(mission.TargetZone)
            if targetZone.side ~= 2 and targetZone.active then
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
end
---------------------------------------------------------------------
--                     END OF ESCORT MISSION                       --


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

local function checkZoneFlags()
		
	if zones.ramonairbase.wasBlue and zones.sambravo.wasBlue and not zones.melez.wasBlue then
		trigger.action.setUserFlag(2, true)
	end
	
	if zones.ramonairbase.wasBlue and zones.ovda.wasBlue and not zones.melez.wasBlue then
		trigger.action.setUserFlag(2, false)
		trigger.action.setUserFlag(127, true)
	end
	
	if zones.ramonairbase.wasBlue and zones.ovda.wasBlue and zones.stcatherine.wasBlue and not zones.melez.wasBlue then
		trigger.action.setUserFlag(2, false)
		trigger.action.setUserFlag(127, false)
		trigger.action.setUserFlag(128, true)
	end
	
	if zones.nevatim.wasBlue then
		trigger.action.setUserFlag(15, true)
	end
	
	if zones.alismailiyah.wasBlue and zones.difarsuwarairfield.wasBlue and zones.bilbeisairbase.wasBlue and zones.abusuwayr.wasBlue then
		trigger.action.setUserFlag(7, true)
	end
	
	if zones.alismailiyah.wasBlue and zones.difarsuwarairfield.wasBlue and zones.bilbeisairbase.wasBlue and zones.abusuwayr.wasBlue and
		zones.wadialjandali.wasBlue and zones.samlima.wasBlue then
		trigger.action.setUserFlag(75, true)
		trigger.action.setUserFlag(7, false)
	end
end
timer.scheduleFunction(function()
    checkZoneFlags()
    return timer.getTime() + 30
end, {}, timer.getTime() + 2)

----------------------- END OF FLAGS --------------------------

buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end


env.info("Mission Setup : is completed!")