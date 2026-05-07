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
		red = {'Ground Forces 1', 'Red SAM SHORAD SA-19', 'Red SAM AAA','Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8'}
	},
	ElGoraUpgrade = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Red Armour Group', 'Red SAM AAA', 'Red Armour Group 2','Red SAM AAA 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8', 'El Gora Command Center'}
	},
	airfield2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Red Armour Group', 'Red Armour Group 3','Red SAM SHORAD SA-19','Red SAM AAA', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-19', 'Red SAM AAA 2', 'Red SAM AAA 3', 'Red SAM AAA 4'}
	},
	airfield2Ismailiyah = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Red SAM AAA', 'Red Armour Group', 'Red Armour Group 3', 'Red SAM AAA 2','Al Ismailiyah Fuel Tank', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8','Al Ismailiyah HQ bulding', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-19'}
	},
	airfieldBen = {
		blue = {'bluePD1'},
		red = {'Ground Forces 1', 'Red Armour Group', 'Red Armour Group 3', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-19'}
	},
	airfield2hat = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'FixedredInfantry1-1', 'Red SAM SHORAD SA-8', 'Red Armour Group', 'Red Armour Group 3', 'Red SAM AAA', 'Red SAM SHORAD SA-8', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Kedem Fuel tanks', 'Kedem Fuel tanks 2','Kedem Fuel tanks 3','Kedem Fuel tanks 4'}
	},
	airfield3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red Armour Group 2', 'Red Armour Group 3','Red SAM SHORAD SA-19','Red SAM SHORAD SA-15', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15'}
	},
	airfield3nevatim = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red Armour Group 2', 'Red Armour Group 3','Red SAM SHORAD SA-15','Red SAM SHORAD SA-19', 'Red SAM AAA 2', 'Nevatim Command Center', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-15'}
	},
	Melez = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1', 'bluePATRIOT'},
		red = {'Enemy ground forces', 'Melez Ammo Depo', 'Red Armour Group', 'Red Armour Group 3', 'Red SAM SHORAD SA-19', 'Red SAM AAA','Red SAM SHORAD SA-15', 'Melez HQ bulding','Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Melez Fuel Tank', 'Red SAM SHORAD SA-15'}
	},
	airfield4 = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Enemy ground forces', 'Red Armour Group', 'Red Armour Group 3','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8'}
	},
	Wadi = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Enemy ground forces', 'Red Armour Group', 'Red Armour Group 3', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8','Red SAM SHORAD SA-15', 'Wadi Al Jandali main building', 'Red SAM SHORAD SA-8', 'Wadi Al Jandali Com tower'}
	},
	RamonAirbase = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Enemy ground forces','Ramon Airbase Training Center','Red SAM SHORAD SA-15', 'Red SAM AAA', 'Red Armour Group 2', 'Red Armour Group 3', 'Ramon Airbase HQ bulding','Red SAM SHORAD SA-8', 'Red SAM AAA 2', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8'}
	},
	Baluza = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Enemy ground forces','Red Armour Group', 'Red Armour Group 3', 'Red SAM AAA','Red SAM SHORAD SA-15','Red SAM SHORAD SA-8', 'Red SAM AAA 2', 'Baluza HQ', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8'}
	},
	startbase = {
		blue = {'blueInfantry'},
		red = {'Enemy ground forces', 'Red SAM AAA','Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8','Red SAM AAA 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8'}
	},
	startbase2 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy ground forces', 'Red Armour Group', 'Red Armour Group 3', 'Red SAM AAA 2','Red SAM SHORAD SA-15', 'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-8'}
	},

	sam1bravo = {
        blue = {'bluePD1', 'blueInfantry'},
        red = {'Red SAM AAA', 'Red SAM AAA', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8', 'Red SAM SA-2'}
    },
	sam1delta = {
        blue = {'bluePD1', 'blueInfantry'},
        red = {'Red SAM AAA', 'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15', 'Red SAM SA-2'}
    },

	  sam2echo = {
        blue = {'bluePD2', 'BLUE SAM Fixed NASAMS Echo'},
        red = {'Red SAM AAA', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19' ,'Red SAM SHORAD SA-19', 'Red SAM SA-3 Fixed Echo'}
    },

	  sam3alpha = {
        blue = {'bluePD1', 'blueHAWK'},
        red = {'Red SAM SHORAD SA-19', 'Red SAM SA-6'}
    },
	 sam3foxtrot = {
        blue = {'blueInfantry', 'BLUE SAM Fixed HAWK Foxtrot'},
        red = {'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15', 'Red SAM SA-6 Fixed Foxtrot'}
    },
    sam4hotel = {
        blue = {'bluePD2', 'BLUE SAM Fixed HAWK Hotel'},
        red = {'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15', 'Red SAM SA-10 Fixed Hotel'}
    },
    sam4golf = {
        blue = {'bluePD2', 'BLUE SAM Fixed HAWK Golf'},
        red = {'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15', 'Red SAM SA-10 Fixed Golf'}
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
        blue = {'bluePD1', 'bluePD2'},
        red = {'Red SAM SHORAD Fixed Missile Factory', 'Red SAM SA-11 Fixed Missile Factory', 'Fixed-Scuds'}
    },
    sam5Charlie = {
        blue = {'bluePD1', 'BLUE SAM Fixed PATRIOT Charlie'},
        red = {'Red SAM AAA Fixed Charlie', 'Red SAM SHORAD SA-8 Fixed Charlie - 1', 'Red SAM SHORAD SA-8 Fixed Charlie - 2', 'Red SAM SA-11 Fixed Charlie'}
    },
    sam6india = {
        blue = {},
        red = {'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-15', 'Red SAM Fixed SA-5 India'}
	},
	farp1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Red SAM SHORAD SA-8', 'Red Armour Group', 'Red Armour Group 3', 'Red SAM SHORAD SA-8'}
	},
	Alpha = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Alpha Container', 'Alpha Fuel Tank', 'Alpha Fuel Tank 2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-8', 'Ground Forces 1', 'Red SAM AAA', 'Red Armour Group', 'Red Armour Group 3', 'Red SAM SHORAD SA-8'}
	},
	farp2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Ground Forces 1', 'Red SAM AAA', 'Red Armour Group', 'Red Armour Group 3', 'Red SAM SHORAD SA-19', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19'}
	},
	farp3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM AAA 2', 'Red SAM AAA 3','Red SAM AAA 4'}
	},
	farp32 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy ground forces', 'Red SAM AAA', 'Red SAM SHORAD SA-15', 'Red Armour Group 2', 'Red Armour Group 3', 'Red SAM AAA 2', 'Red SAM SHORAD SA-15'}
	},
	Charlie = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2'},
		red = {'Enemy ground forces','Red SAM AAA', 'Charlie supplies 2', 'Red SAM SHORAD SA-8', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red Armour Group 3', 'Charlie supplies', 'Red SAM SHORAD SA-8'}
	},
	mission1 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Red SAM SA-3 Fixed Mining', 'Ground Armour Fixed Mining', 'Mining Facility outpost', 'Red SAM AAA Fixed Mining', 'Red SAM SHORAD SA-19 Fixed MiningFacility', 
	'Mining Facility Command Center'}
	},
	
	mission1Ammo = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Red SAM SA-11','Scuds Ammunition Depo Fixed', 'Ammunition Depo','Ammunition Depo 2', 'Red SAM SHORAD SA-15','Ammunition Depo 3', 'Ammunition Depo Storage', 'T-62M Ammunition Depo Fixed', 'Ammo Trucks Ammunition Depo', 'Red SAM AAA Ammunition Depo Fixed'}
	},
	
	TankFactory = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Tank Factory-T62M', 'Red SAM SA-6', 'Red SAM AAA Fixed TankFactory', 'Tank factory HQ', 'Tank Factory', 'Tank Factory outpost', 
		'Tank Factory Troops garage', 'Tank Factory Command Center', }
	},
	mission2InsurgentCamp = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Fixed-InfantryGroup', 'Insurgent camp tent', 'Insurgent camp storage', 'Fixed-InfantryGroup-2', 'Insurgent camp tent 2', 'Insurgent camp outpost', 'Fixed-Zu23', 'Fixed-Art'}
	
	},
	mission3 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Red SAM SA-6', 'Red SAM SHORAD SA-15', 'Russian Tanks T-72B Fixed', 'Russian T62-M Fixed', 'Fixed-redInfantry2', 'Secret Tech Bulding', 'Secret Tech Bulding 2', 'Secret Tech Command Center', 'Secret Tech building HQ', 'Secret Tech Factory'}
			  
	},

	mission3chemsite = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Chemsite Infantry Group Fixed', 'Chemsite Armoured group Fixed', 'Chemsite Armoured group Fixed 2', 'Red SAM SHORAD SA-15 Fixed ChemSite', 'Chemical Tank 1', 'Chemical Tank 2', 'Chemical Tank 3',
		'Chemical Tank 4', 'Chemical Factory 1', 'Chemical Factory 2', 'Chemical Factory 3', 'Chemical Factory 4'}
	},
	mission4 = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'Enemy ground forces', 'Artilliary MRL FDDM Fixed', 'Artillery Factory building', 'Red Armour Group 2','Artilliary 9K57 Uragan Fixed', 'Red SAM SHORAD SA-8', 'Artilliary MLRS 9A52 Smerch Fixed'}
	},
	
	mission4fueldepo = {
		blue = {'blueInfantry', 'blueArmor'},
		red = {'FuelDepo fuel tank','Fixed-Fuel5-T55', 'FuelDepo fuel tank 2', 'Red SAM AAA Fuel', 'FuelDepo fuel tank 3', 'FuelDepo fuel tank 4', 'FuelDepo fuel tank 5', 'Red SAM SHORAD SA-19 Fixed-Fuel3', 'Red SAM SHORAD SA-15 Fixed-Fuel4', 'FuelDepo fuel tank 6', 'Pump station', 'Pump station 2', 'Pump station 3'}
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
	bluecarrier = L10N:Get("SINAI_FLAVOR_START_ZONE"),
	redcarrier = L10N:Format("SINAI_FLAVOR_ENEMY_CARRIER", 15),
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
	
	miningfacility = L10N:Get("SINAI_FLAVOR_KNEEBOARD_COORDS"),
	insurgentcamp = L10N:Get("SINAI_FLAVOR_INSURGENT_CAMP"),
	secrettechfacility = L10N:Get("SINAI_FLAVOR_SECRET_TECH_FACILITY"),
	fueldepo = L10N:Get("SINAI_FLAVOR_FUEL_DEPOT"),
	ammonitiondepo = L10N:Get("SINAI_FLAVOR_AMMUNITION_DEPOT"),
	tankfactory = L10N:Get("SINAI_FLAVOR_TANK_FACTORY"),
	chemsite = L10N:Get("SINAI_FLAVOR_CHEMICAL_SITE"),
	artilleryfactory = L10N:Get("SINAI_FLAVOR_KNEEBOARD_COORDS"),
	missilefactory = L10N:Get("SINAI_FLAVOR_MISSILE_FACTORY"),
	portsaid = L10N:Get("SINAI_FLAVOR_PORT_SAID"),
	borjoil = L10N:Get("SINAI_FLAVOR_BORJ_OIL"),
	
	
	
	samalpha = L10N:Get("SINAI_FLAVOR_FRIENDLY_SAM"),
	sambravo = L10N:Format("SINAI_FLAVOR_RED_SAM_SHORAD", "SA-2"),
	samcharlie = L10N:Format("SINAI_FLAVOR_RED_SAM_SHORAD", "SA-11"),
	samdelta = L10N:Format("SINAI_FLAVOR_RED_SAM_SHORAD", "SA-2"),
	samecho = L10N:Format("SINAI_FLAVOR_RED_SAM_SHORAD", "SA-3"),
	samfoxtrot = L10N:Format("SINAI_FLAVOR_RED_SAM_SHORAD", "SA-6"),
	samgolf = L10N:Format("SINAI_FLAVOR_RED_SAM_SHORAD", "SA-10"),
	samhotel = L10N:Format("SINAI_FLAVOR_RED_SAM_SHORAD", "SA-10"),
	samindia = L10N:Format("SINAI_FLAVOR_RED_SAM_SHORAD", "SA-5"),
	Juliett = L10N:Format("SINAI_FLAVOR_RED_SAM_SHORAD", "SA-10")

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
	['Neustrashimy']   	= 'Molniya',
	['Moskva']   		= 'Grisha',
	['Rezky']   		= 'Grisha',
	['Red Armour Group']   = 'Red Armor Group6',
	['Red Armour Group 2']   = 'Red Armor Group7',
	['Red Armour Group 3']  = 'Red Armor Group8',
	['blueHAWK']  = 'blueHAWK Coldwar',
	['blueArmor Coldwar']  = 'blueArmor Coldwar',
	['Red SAM SHORAD SA-15 Fixed-Fuel4']  = 'Red SAM SHORAD SA-8 Fixed-Fuel4',
	['Chemsite Armoured group Fixed']  = 'Chemsite Armoured group Fixed-T55',
	['Chemsite Armoured group Fixed 2']  = 'Chemsite Armoured group Fixed 2-T55',


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
	['Red SAM SA-10 Fixed Golf'] = 'Red SAM SA-2 Fixed Golf',
	['Red SAM SA-10 Fixed Hotel'] = 'Red SAM SA-2 Fixed Hotel',
	['Red SAM SA-11 Fixed Juliett'] = 'Red SAM SA-2 Fixed Juliett',
	

}

local SamSwapNoTorM2AndPantsir = {
	['Red SAM SHORAD Pantsir S1'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
	['Red SAM SHORAD Tor M2'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
}

local SamSwapNoSA15 = {
	['Red SAM SHORAD SA-15'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
	['Red SAM SHORAD SA-15 Fixed Borj Oil production'] = 'Red SAM SHORAD SA-8 Fixed Borj Oil production',
	['Red SAM SHORAD SA-15 Fixed ChemSite']  = 'Red SAM SHORAD SA-8 Fixed ChemSite',
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
	"Red SAM AAA 6",

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
	"bluePD1",
	"bluePD2",
	"blueHAWK",
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

bc = BattleCommander:new(filepath, 10, 60)
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
env.info('Foothold - Rank file path: '..bc.rankFile)
end
Hunt = true

zones = {
	redcarrier = ZoneCommander:new		({zone='Red Carrier', side=1, level=10, upgrades=upgrades.redships, crates={}, flavorText=flavor.redcarrier}),
	bluecarrier = ZoneCommander:new		({zone='Blue Carrier', side=2, level=20, upgrades=upgrades.blueships, crates={}, flavorText=flavor.bluecarrier}),
	
	sdedov = ZoneCommander:new			({zone='Sde Dov', side=2, size='smallmedium', level=2, upgrades=upgrades.startbase2, crates={}, flavorText=flavor.sdedov}),
	bengurion = ZoneCommander:new		({zone='Ben-Gurion', side=2, size='small', level=20, upgrades=upgrades.airfieldBen, crates={}, flavorText=flavor.bengurion}),
	palmahim = ZoneCommander:new		({zone='Palmahim', side=2, size='small', level=20, upgrades=upgrades.startbase, crates={}, flavorText=flavor.palmahim}),
	telnof = ZoneCommander:new			({zone='Tel Nof', side=2, size='small', level=20, upgrades=upgrades.startbase, crates={}, flavorText=flavor.telnof}),
	hatzor = ZoneCommander:new			({zone='Hatzor', side=2, size='small', level=20, upgrades=upgrades.startbase, crates={}, flavorText=flavor.hatzor}),
	kedemhatzerim = ZoneCommander:new	({zone='Kedem-Hatzerim', side=1, size='bignosam', level=20, upgrades=upgrades.airfield2hat, crates={}, flavorText=flavor.kedemhatzerim}),
	nevatim = ZoneCommander:new			({zone='Nevatim', side=1, size='bignosam', level=20, upgrades=upgrades.airfield3nevatim, crates={}, flavorText=flavor.nevatim}),
	ramonairbase = ZoneCommander:new	({zone='Ramon Airbase', side=1, size='mediumbig', level=20, upgrades=upgrades.RamonAirbase, crates={}, flavorText=flavor.ramonairbase}),
	elgora = ZoneCommander:new			({zone='El Gora', side=1, size='mediumbig', level=20, upgrades=upgrades.ElGoraUpgrade, crates={}, flavorText=flavor.elgora}),
	elarish = ZoneCommander:new			({zone='El Arish', side=1, size='mediumbig', level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.elarish}),
	ovda = ZoneCommander:new			({zone='Ovda', side=1, size='big', level=20, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.ovda}),
	birhasanah = ZoneCommander:new		({zone='Bir Hasanah', side=1, size='mediumbig', level=2, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.birhasanah}),
	melez = ZoneCommander:new			({zone='Melez', side=1, size='big', level=20, upgrades=upgrades.Melez, crates={}, flavorText=flavor.melez}),
	baluza = ZoneCommander:new			({zone='Baluza', side=1, size='mediumbig', level=20, upgrades=upgrades.Baluza, crates={}, flavorText=flavor.baluza}),
	assalihiyah = ZoneCommander:new		({zone='As Salihiyah', side=1, size='medium', level=20, upgrades=upgrades.airfield1, crates={}, flavorText=flavor.assalihiyah}),
	alismailiyah = ZoneCommander:new	({zone='Al Ismailiyah', side=1, size='mediumbig', level=10, upgrades=upgrades.airfield2Ismailiyah, crates={}, flavorText=flavor.alismailiyah}),
	kibritairbase = ZoneCommander:new	({zone='Kibrit Air Base', side=1, size='mediumbig', level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.kibritairbase}),
	almansurah = ZoneCommander:new		({zone='Al Mansurah', side=1, size='bignosam', level=20, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.almansurah}),
	azzaqaziq = ZoneCommander:new		({zone='AzZaqaziq', side=1, size='mediumbig', level=20, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.azzaqaziq}),
	inshasairbase = ZoneCommander:new	({zone='Inshas Airbase', side=1, size='mediumbig', level=20, upgrades=upgrades.airfield2, crates={}, flavorText=flavor.inshasairbase}),
	cairointernationalairport = ZoneCommander:new	({zone='Cairo International Airport', side=1, size='medium', level=20, upgrades=upgrades.airfield3, crates={}, flavorText=flavor.cairointernationalairport}),
	wadialjandali = ZoneCommander:new	({zone='Wadi al Jandali', side=1, size='medium', level=20, upgrades=upgrades.Wadi, crates={}, flavorText=flavor.wadialjandali}),
	cairowest = ZoneCommander:new		({zone='Cairo West', side=1, size='medium', level=20, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.cairowest}),
	benisuef = ZoneCommander:new		({zone='Beni Suef', side=1, size='medium', level=20, upgrades=upgrades.airfield4, crates={}, flavorText=flavor.benisuef}),
	komawshim = ZoneCommander:new		({zone='Kom Awshim', side=1, size='smallmedium', level=20, upgrades=upgrades.farp2, crates={}, flavorText=flavor.komawshim}),
	gebelelbasur = ZoneCommander:new	({zone='Gebel El Basur Air Base', side=1, level=20, upgrades=upgrades.farp32, crates={}, flavorText=flavor.gebelelbasur}),
	birmaairbase = ZoneCommander:new	({zone='Birma Air Base', side=1, size='small', level=20, upgrades=upgrades.farp3, crates={}, flavorText=flavor.birmaairbase}),
	jiyanklisairbase = ZoneCommander:new	({zone='Jiyanklis Air Base', side=1, level=20, upgrades=upgrades.farp3, crates={}, flavorText=flavor.jiyanklisairbase}),
	borgelarab = ZoneCommander:new		({zone='Borg El Arab International Airport', side=1, level=20, upgrades=upgrades.farp3, crates={}, flavorText=flavor.borgelarab}),

	farpalpha = ZoneCommander:new	({zone='FARP-Alpha', side=1, size='smallmedium', level=20, upgrades=upgrades.Alpha, crates={}, flavorText=flavor.farpalpha}),
	farpbravo = ZoneCommander:new	({zone='FARP-Bravo', side=1, size='smallmedium', level=10, upgrades=upgrades.farp3, crates={}, flavorText=flavor.farpbravo}),
	farpcharlie = ZoneCommander:new	({zone='FARP-Charlie', side=1, size='small', level=20, upgrades=upgrades.Charlie, crates={}, flavorText=flavor.farpcharlie}),
	
	
	miningfacility = ZoneCommander:new({zone='MiningFacility', side=1,size='sam2', level=20, upgrades=upgrades.mission1, crates={}, flavorText=flavor.miningfacility}),
	insurgentcamp = ZoneCommander:new({zone='InsurgentCamp', side=1,size='smallmedium', level=25, upgrades=upgrades.mission2InsurgentCamp, crates={}, flavorText=flavor.insurgentcamp}),
	secrettechfacility = ZoneCommander:new({zone='SecretTechFacility', side=1,size='sam2', level=25, upgrades=upgrades.mission3, crates={}, flavorText=flavor.secrettechfacility}),
	fueldepo = ZoneCommander:new({zone='FuelDepo', side=1, level=25, upgrades=upgrades.mission4fueldepo, crates={}, flavorText=flavor.fueldepo}),
	ammonitiondepo = ZoneCommander:new({zone='AmmonitionDepo', side=1,size='sam2', level=20, upgrades=upgrades.mission1Ammo, crates={}, flavorText=flavor.ammonitiondepo}),
	tankfactory = ZoneCommander:new({zone='TankFactory',size='sam', side=1, level=20, upgrades=upgrades.TankFactory, crates={}, flavorText=flavor.tankfactory}),
	chemsite = ZoneCommander:new({zone='ChemSite', side=1, level=25, upgrades=upgrades.mission3chemsite, crates={}, flavorText=flavor.chemsite}),
	artilleryfactory = ZoneCommander:new({zone='ArtilleryFactory', side=1, level=20, upgrades=upgrades.mission4, crates={}, flavorText=flavor.artilleryfactory}),
	missilefactory = ZoneCommander:new({zone='MissileFactory', side=1, level=20, upgrades=upgrades.sam5missileFactory, crates={}, flavorText=flavor.missilefactory}),
	portsaid = ZoneCommander:new({zone='Port Said', side=1, level=20, upgrades=upgrades.portsaidFixed, crates={}, flavorText=flavor.portsaid}),
	borjoil = ZoneCommander:new({zone='Borj Oil production Site', side=1, level=20, upgrades=upgrades.borjoilFixed, crates={}, flavorText=flavor.borjoil}),
	
	hidden1 = ZoneCommander:new({zone='Hidden1', side=1, level=15, upgrades=upgrades.HiddenFixed, crates={}, flavorText=flavor.hidden1}),

	
	
	samalpha = ZoneCommander:new	({zone='SAM-Alpha', side=2, size='sam', level=20, upgrades=upgrades.sam3alpha, crates={}, flavorText=flavor.samalpha}),
	sambravo = ZoneCommander:new	({zone='SAM-Bravo', side=1, size='sam', level=20, upgrades=upgrades.sam1bravo, crates={}, flavorText=flavor.sambravo}),
	samcharlie = ZoneCommander:new	({zone='SAM-Charlie', side=1, size='sam', level=20, upgrades=upgrades.sam5Charlie, crates={}, flavorText=flavor.samcharlie}),
	samdelta = ZoneCommander:new	({zone='SAM-Delta', side=1, size='sam', level=20, upgrades=upgrades.sam1delta, crates={}, flavorText=flavor.samdelta}),
	samecho = ZoneCommander:new		({zone='SAM-Echo', side=1, size='sam', level=20, upgrades=upgrades.sam2echo, crates={}, flavorText=flavor.samecho}),
	samfoxtrot = ZoneCommander:new	({zone='SAM-Foxtrot', side=1, size='sam', level=20, upgrades=upgrades.sam3foxtrot, crates={}, flavorText=flavor.samfoxtrot}),
	samhotel = ZoneCommander:new	({zone='SAM-Hotel', side=1, size='sam', level=20, upgrades=upgrades.sam4hotel, crates={}, flavorText=flavor.samhotel}),
	samgolf = ZoneCommander:new		({zone='SAM-Golf', side=1, size='sam', level=20, upgrades=upgrades.sam4golf, crates={}, flavorText=flavor.samgolf}),
	samindia = ZoneCommander:new	({zone='SAM-India', side=1, size='sam', level=20, upgrades=upgrades.sam6india, crates={}, flavorText=flavor.samindia}),
	samjuliett = ZoneCommander:new	({zone='SAM-Juliett', side=1, size='sam', level=20, upgrades=upgrades.sam5juliett, crates={}, flavorText=flavor.samjuliett}),

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
    }
	CapCarrierGroup = {
        'BLUE_HORNET',
        'BLUE_F14B',
	}
	SeadCarrierGroup = {
        'BLUE_HORNET_SEAD',
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
		local t0 = timer.getTime()
		timer.scheduleFunction(function()
			activateGroupIfNotActive('CVN-73')
		end, {}, t0 + 5)
		timer.scheduleFunction(function()
			activateGroupIfNotActive('CVN-59')
		end, {}, t0 + 10)
		timer.scheduleFunction(function()
			activateGroupIfNotActive('HMS Invincible')
		end, {}, t0 + 15)
		timer.scheduleFunction(function()
			destroyGroupIfActive('CVN-72')
		end, {}, t0 + 20)
		timer.scheduleFunction(function()
			destroyGroupIfActive('CVN-74')
		end, {}, t0 + 25)
		timer.scheduleFunction(function()
			checkWeaponsList('CVN-73')
			checkWeaponsList('CVN-59')
			checkWeaponsList('HMS Invincible')
		end, {}, t0 + 30)
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
zones.telnof.isHeloSpawn = true


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

bc:addHiddenConnection("Melez","Ramon Airbase")

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
            trigger.action.outTextForCoalition(2, L10N:Get("SINAI_EVENT_RAMON_SCUDS"), 30)
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
            trigger.action.outTextForCoalition(2, L10N:Get("SINAI_EVENT_MELEZ_ARTILLERY"), 30)
            trigger.action.outSoundForCoalition(2, 'WarningSound.ogg')
            end, {}, timer.getTime() + 180)
		end
	
	    timer.scheduleFunction(function()
    trigger.action.outTextForCoalition(2, L10N:Get("SINAI_EVENT_MELEZ_ARTILLERY_INTEL"), 30)
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
	trigger.action.outTextForCoalition(2,L10N:Get("SINAI_SETUP_ARTILLERY_FACTORY_DISABLED"),20)
end, 'disableartilleryfactory')

zones.miningfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SINAI_SETUP_MINING_FACILITY_CLEARED"),20)
end, 'disableminingfacility')


zones.ammonitiondepo:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disableammonitiondepo2')

zones.insurgentcamp:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SINAI_SETUP_INSURGENT_CAMP_DESTROYED"),20)
end, 'disableinsurgentcamp')


zones.chemsite:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disablechemsite1')

zones.missilefactory:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SINAI_SETUP_MISSILE_FACTORY_DESTROYED"),20)
end, 'disablemissilefactory')

------------------------------------------ SAM DISABLE --------------------------------------------

zones.samhotel:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SINAI_SETUP_SAM_HOTEL_DESTROYED"),20)
end, 'disablesamhotel')


zones.samindia:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Get("SINAI_SETUP_SAM_INDIA_DESTROYED"),20)
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
		trigger.action.outText(L10N:Get("MISSION_COMPLETE_MANUAL_RESTART"), 120)

		timer.scheduleFunction(function()
			trigger.action.outSoundForCoalition(2, "BH.ogg")
		end, {}, timer.getTime() + 5)

			local subMenu = missionCommands.addSubMenuForCoalition(2, L10N:Get("MENU_RESTART_AND_RESET"), nil)
			missionCommands.addCommandForCoalition(2, L10N:Get("COMMON_YES"), subMenu, function()
				if bc and bc.saveFile then
					Utils.saveTable(bc.saveFile, 'zonePersistance', {})
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
        "Red Armor Group6 #",
        "Red Armor Group7 #",
        "Red Armor Group8 #",
		"Red SAM AAA 2 #",
		"Red SAM AAA 3 #",
		"Red SAM AAA 4 #",
		"Red SAM SHORAD SA-19 #",
		"Red SAM SHORAD SA-9 #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-13 #",
		"Molniya #",
		"Rezky #",
		"Neustrashimy #",
	}, 30, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
else
	bc:roamGroupsToLocalSubZone({
		"Ground Armour 2 #",
		"Ground Armour 3 #",
		"Ground Armour #",
		"Red SAM AAA 2 #",
		"Red SAM AAA 3 #",
		"Red SAM AAA 4 #",
		"Red SAM SHORAD SA-19 #",
		"Red SAM SHORAD SA-9 #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-13 #",
		"Neustrashimy #",
		"Molniya #",
		"Rezky #",
		"Grisha #"
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
		local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
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
		local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
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
		local zoneMenu = remember(missionCommands.addSubMenuForGroup(groupId, label, parentMenu))
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
            return LTFormat("SYRIA_SHOP_MISSION_STILL_PROGRESS", "bomb run")
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
            return LTFormat("SYRIA_SHOP_NO_FRIENDLY_SPAWN", "building strike")
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
	if params.zone and params.zone.side == 1 then
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
local RED_ZONE_UPGRADE_ID = "redzoneupgrade"
local RED_ZONE_UPGRADE_COST = 5000

bc:registerShopItem(RED_ZONE_UPGRADE_ID, LTGet("SYRIA_SHOP_ITEM_RED_ZONE_UPGRADE"), RED_ZONE_UPGRADE_COST, function(sender)
	return bc:redZoneUpgradeAction()
end)

local RED_MASS_ATTACK_ID = "redmassattack"
local RED_MASS_ATTACK_COST = 6000

local function redMassAttackAction()
	if not bc.triggerRedMassAttack then
		return L10N:Get("SYRIA_SHOP_MASS_ATTACK_UNAVAILABLE")
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
	if params.zone and params.zone.side == 1 and not params.zone.suspended then
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
local samLabel = (Era == 'Coldwar') and LTGet("SYRIA_SHOP_ITEM_UPGRADE_HAWK")
                                   or  LTGet("SYRIA_SHOP_ITEM_UPGRADE_NASAMS")
local samMenu=nil
bc:registerShopItem('zsam',samLabel,ShopPrices.zsam,function(sender)
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
		local slotID = (Era == 'Coldwar') and 'blueArmor Coldwar' or 'blueArmor' -- checked
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

    trigger.action.outTextForCoalition(2,L10N:Get("SYRIA_SHOP_ALL_ZONES_SECOND_UPGRADE"),15)
	bc:removeShopItem(2, 'gslot')
	return nil
end)
bc:registerShopItem('farphere',LTGet("SYRIA_SHOP_ITEM_DEPLOY_FARP"),ShopPrices.farphere,function(sender)
        return LTGet("SYRIA_SHOP_FARP_MARKER_HELP")
end,function(_, params)
        return bc:processMapFarpPurchase(params)
end)


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
	jam            = 4,  -- Jam radars at zone
}


-- first value below is how much in stock, the second number value is the ranking in the shop menu list, the third is the new ranking system.

bc:addShopItem(1, 'redzoneupgrade', -1, 1) -- red AI zone upgrade
bc:addShopItem(1, 'redmassattack', -1, 1) -- red AI mass airbase attack

ShopCategoryLabels = ShopCategoryLabels or {}
local ShopCats = ShopCategoryLabels

ShopCats.AIAttack = ShopCats.AIAttack or LTGet("SYRIA_SHOP_CAT_AI_ATTACK")
ShopCats.ZoneUpgrades = ShopCats.ZoneUpgrades or LTGet("SYRIA_SHOP_CAT_ZONE_UPGRADES")
ShopCats.JTACIntel = ShopCats.JTACIntel or LTGet("SYRIA_SHOP_CAT_JTAC_INTEL")
ShopCats.MarkingTools = ShopCats.MarkingTools or LTGet("SYRIA_SHOP_CAT_MARKING_TOOLS")
ShopCats.CombinedArms = ShopCats.CombinedArms or LTGet("SYRIA_SHOP_CAT_COMBINED_ARMS")
ShopCats.LogisticsStrategic = ShopCats.LogisticsStrategic or LTGet("SYRIA_SHOP_CAT_LOGISTICS")
ShopCats.OtherSupport = ShopCats.OtherSupport or LTGet("SYRIA_SHOP_CAT_OTHER_SUPPORT")

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
bc:addShopItem(2, 'groundattack', -1, 7, ShopRankRequirements.groundattack, ShopCats.AIAttack) -- Ground attack convoy
if UseStatics == true then
    bc:addShopItem(2, 'dynamicstatic', -1, 6, ShopRankRequirements.dynamicstatic, ShopCats.AIAttack) -- Static structure Flight
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

bc:loadFromDisk() -- will load and overwrite default zone levels, sides, funds, and available shop items
if zonePersistance and zonePersistance.zones and next(zonePersistance.zones) == nil then
    bc.saveLoaded = false
end
if not bc.saveLoaded then
	applyRandomRedUpgrades()
	applyRandomBlueUpgrades()
end

bc:init()
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
---------------------- Destroy SCUDS at Gebel El Basur Air Base (31) ------------------
Group.getByName('Quwaysina-Scuds'):destroy()
evc:addEvent({
	id='Quwaysinascuds',
	action = function()
	RespawnGroup('Quwaysina-Scuds')
		RegisterGroupTarget('Quwaysina-Scuds',250,L10N:Get("SINAI_TARGET_DESTROY_SCUDS"),'Quwaysinascuds')
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
				trigger.action.outTextForCoalition(2, L10N:Format("SINAI_EVENT_GEBEL_SCUDS_LAUNCHING", choice), 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
		if ActiveMission['Quwaysinascuds'] then return false end
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
	title = LTGet("SINAI_MISSION_SCUDS_GEBEL_TITLE"),
	description = LTGet("SINAI_MISSION_SCUDS_GEBEL_DESC"),
	messageStart = L10N:Get("SINAI_MISSION_SCUDS_START"),
	messageEnd = L10N:Get("SINAI_MISSION_SCUDS_END"),
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
		if not ActiveMission['Quwaysinascuds'] then return false end
		if Group.getByName('Quwaysina-Scuds') then return true end
		ActiveMission['Quwaysinascuds'] = nil
		return false
	end
})
----------------------- End Destroy SCUDS at Gebel El Basur Air Base (31) ---------------------

------------------------------- Destroy SCUDS at Baluza (14) ----------------------------------
Group.getByName('Baluza-Scuds'):destroy()
evc:addEvent({
    id='Baluza-scuds',
    action = function()
		RespawnGroup('Baluza-Scuds')
		RegisterGroupTarget('Baluza-Scuds',250,L10N:Get("SINAI_TARGET_DESTROY_SCUDS"),'Baluza-scuds')
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
				trigger.action.outTextForCoalition(2, L10N:Format("SINAI_EVENT_BALUZA_SCUDS_LAUNCHING", choice), 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,  
    canExecute = function()
		if ActiveMission['Baluza-scuds'] then return false end
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
	title = LTGet("SINAI_MISSION_SCUDS_BALUZA_TITLE"),
	description = LTGet("SINAI_MISSION_SCUDS_BALUZA_DESC"),
	messageStart = L10N:Get("SINAI_MISSION_SCUDS_START"),
	messageEnd = L10N:Get("SINAI_MISSION_SCUDS_END"),
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
		if not ActiveMission['Baluza-scuds'] then return false end
		if Group.getByName('Baluza-Scuds') then return true end
		ActiveMission['Baluza-scuds'] = nil
		return false
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
		RegisterGroupTarget('evt-bomb',500,L10N:Get("SINAI_TARGET_INTERCEPT_BOMBERS"),'bomb')
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
		if ActiveMission['bomb'] then return false end
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
	title = LTGet("SINAI_MISSION_INTERCEPT_BOMBERS_TITLE"),
	description = LTGet("SINAI_MISSION_INTERCEPT_BOMBERS_DESC"),
	messageStart =  L10N:Get("SINAI_MISSION_INTERCEPT_BOMBERS_START"),
	messageEnd = function() lastbomb_COOLDOWN = timer.getTime() return L10N:Get("SINAI_MISSION_INTERCEPT_BOMBERS_END") end,
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
------------------------------------------End Intercept Bombers ---------------------------------------
--------------------------------------- Intercept enemy airstrike -------------------------------------
local attackGrp = Era=='Coldwar' and 'evt-attackcw' or 'evt-attack'
Group.getByName('evt-attack'):destroy()
Group.getByName('evt-attackcw'):destroy()
evc:addEvent({
	id='cas',
	action=function()
		RespawnGroup(attackGrp)
		RegisterGroupTarget(attackGrp,500,L10N:Get("SINAI_TARGET_INTERCEPT_AIRSTRIKE"),'cas')
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
		if ActiveMission['cas'] then return false end
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
	title = LTGet("SINAI_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),
	description = LTGet("SINAI_MISSION_INTERCEPT_AIRSTRIKE_DESC"),
	messageStart = L10N:Get("SINAI_MISSION_INTERCEPT_AIRSTRIKE_START"),
	messageEnd = L10N:Get("SINAI_MISSION_INTERCEPT_AIRSTRIKE_END"),
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
		if u then RegisterUnitTarget(u:getName(),500,L10N:Get("SINAI_TARGET_CARGO_PLANE_MISSION"),'cargointercept') end
	end,
	canExecute = function()
		if ActiveMission['cargointercept'] then return false end
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
	title = LTGet("SINAI_MISSION_INTERCEPT_CARGO_TITLE"),
	description = LTGet("SINAI_MISSION_INTERCEPT_CARGO_DESC"),
	messageStart = L10N:Get("SINAI_MISSION_INTERCEPT_CARGO_START"),
	messageEnd = L10N:Get("SINAI_MISSION_INTERCEPT_CARGO_END"),
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
		RegisterGroupTarget(ships[choice],500,L10N:Get("SINAI_TARGET_CARGO_SHIP"),'shiptercept')
	end,
	canExecute = function()
		if ActiveMission['shiptercept'] then return false end
		if math.random(1, 100) < 70 then return false end
		if Group.getByName('evt-shiptercept2') then return false end
		if Group.getByName('evt-shiptercept3') then return false end
		return true
	end
})

mc:trackMission({
    title = LTGet("SINAI_MISSION_DESTROY_SHIPS_TITLE"),
    description = LTGet("SINAI_MISSION_DESTROY_SHIPS_GENERAL_DESC"),
    messageStart = L10N:Get("SINAI_MISSION_DESTROY_SHIPS_START"),
    messageEnd = L10N:Get("SINAI_MISSION_DESTROY_SHIPS_END"),
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
		if Group.getByName('evt-shiptercept2') then return true end
		if Group.getByName('evt-shiptercept3') then return true end
		ActiveMission['shiptercept'] = nil
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
		RegisterGroupTarget('evt-Salihiyah-attack-melez-art',250,L10N:Get("SINAI_TARGET_DESTROY_ARTILLERY"),'artilleryattack')
    end,
    canExecute = function()
		if ActiveMission['artilleryattack'] then return false end
        if math.random(1, 100) < 60 then return false end
		if bc:getZoneByName('As Salihiyah').side ~= 1 or bc:getZoneByName('As Salihiyah').suspended then return false end
        if bc:getZoneByName('Melez').side ~= 2 or bc:getZoneByName('Melez').suspended then return false end
        if Group.getByName('evt-Salihiyah-attack-melez-art') then return false end
        return true
    end
})

mc:trackMission({
	title = LTGet("SINAI_MISSION_DESTROY_ARTILLERY_TITLE"),
	description = LTGet("SINAI_MISSION_DESTROY_ARTILLERY_DESC"),
	messageStart = L10N:Get("SINAI_MISSION_DESTROY_ARTILLERY_START"),
	messageEnd = L10N:Get("SINAI_MISSION_DESTROY_ARTILLERY_END"),
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
		if not ActiveMission['artilleryattack'] then return false end
		if Group.getByName('evt-Salihiyah-attack-melez-art') then return true end
		ActiveMission['artilleryattack'] = nil
		return false
	end
})
-------------------------------------- End of destroy artillery -------------------------------------
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
		return LT(T):Format("SYRIA_DYNAMIC_RECON_TITLE", reconMissionTarget, wp)
	end,
	description = function(T)
		return LT(T):Format("SYRIA_DYNAMIC_RECON_DESC", reconMissionTarget)
	end,
	messageStart = function()
		local wp = WaypointList[reconMissionTarget] or ""
		return L10N:Format("SYRIA_DYNAMIC_RECON_START", reconMissionTarget, wp)
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

function generateCaptureMission()
    if captureTarget ~= nil then return true end
    
    local validzones = {}
    for _,v in ipairs(bc.zones) do
        
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
---------------------------------------------------------------------
--                      ESCORT MISSION                             --

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
			local T = L10N:ForGroup(groupID)
			trigger.action.outSoundForGroup(groupID, "ding.ogg")
			trigger.action.outTextForGroup(groupID, T:Format("MISSION_ESCORT_SPECIAL_AVAILABLE", mission.zone, mission.TargetZone), 30)
		 end,
        description = function(T) return LT(T):Format("MISSION_ESCORT_DESCRIPTION", mission.TargetZone) end,
        isEscortMission = true,
        accept = false,
        missionGroup = mission.missionGroup,
        zoneName = zoneName,
        messageStart = function() return L10N:Format("MISSION_ESCORT_START", mission.TargetZone) end,
		missionFail = function(self)
		self.accept = false
		if not IsGroupActive(mission.missionGroup) then
			mc.missionFlags[zoneName] = nil
			if missionGroupIDs[zoneName] and next(missionGroupIDs[zoneName]) then
				for groupName, data in pairs(missionGroupIDs[zoneName]) do
					local groupID = data.groupID
					local group = data.group
					local T = L10N:ForGroup(groupID)
					trigger.action.outSoundForGroup(groupID, "cancel.ogg")
					trigger.action.outTextForGroup(groupID, T:Get("SYRIA_ESCORT_FAILED_RETRY"), 30)
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
		RegisterGroupTarget('FactoryStrike',500,L10N:Get("SINAI_TARGET_FACTORY_STRIKE"),'FactoryStrike',true)
	end,
	canExecute = function()
		if CustomFlags['FactoryStrike'] then return false end
		if ActiveMission['FactoryStrike'] then return false end
		if bc:getZoneByName('Wadi al Jandali').side ~= 2 or bc:getZoneByName('Wadi al Jandali').suspended then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("SINAI_MISSION_HIGH_VALUE_TITLE"),
	description = LTGet("SINAI_MISSION_HIGH_VALUE_DESC"),

	messageStart = L10N:Get("SINAI_MISSION_HIGH_VALUE_START"),
	messageEnd = L10N:Get("SINAI_MISSION_HIGH_VALUE_END"),
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
		if not ActiveMission['FactoryStrike'] then return false end
		if Group.getByName('FactoryStrike') then return true end
		ActiveMission['FactoryStrike'] = nil
		return false
	end
})


evc:addEvent({
	id = 'factoryBulding',
	action = function()
		local tgt = sceneryList['factoryBulding'][1] or SCENERY:FindByZoneName('factoryBulding')
		if not tgt then
			trigger.action.outText('factoryBulding is missing',30)
			return
		end
		RegisterScoreTarget('factoryBulding',tgt,500,L10N:Get("SINAI_TARGET_HIGH_VALUE_FACTORY"),true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("SINAI_TARGET_HIGH_VALUE_FACTORY"),p,2,false,false)
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
	title = LTGet("SINAI_MISSION_HIGH_VALUE_FACTORY_TITLE"),
	description = LTGet("SINAI_MISSION_FACTORY_ISMAILIYAH_DESC"),
	messageStart = L10N:Get("SINAI_MISSION_HIGH_VALUE_FACTORY_START"),
	messageEnd = L10N:Get("SINAI_MISSION_HIGH_VALUE_FACTORY_END"),
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
		local tgt = sceneryList['factoryBulding2'][1] or SCENERY:FindByZoneName('factoryBulding2')
		if not tgt then
			trigger.action.outText('factoryBulding2 is missing',30)
			return
		end
		RegisterScoreTarget('factoryBulding2',tgt,500,L10N:Get("SINAI_TARGET_HIGH_VALUE_FACTORY"),true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("SINAI_TARGET_HIGH_VALUE_FACTORY"),p,2,false,false)
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
	title = LTGet("SINAI_MISSION_HIGH_VALUE_FACTORY_TITLE"),
	description = LTGet("SINAI_MISSION_FACTORY_MANSURAH_DESC"),
	messageStart = L10N:Get("SINAI_MISSION_HIGH_VALUE_FACTORY_START"),
	messageEnd = L10N:Get("SINAI_MISSION_HIGH_VALUE_FACTORY_END"),
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
		local tgt = sceneryList['factoryBulding3'][1] or SCENERY:FindByZoneName('factoryBulding3')
		if not tgt then
			trigger.action.outText('factoryBulding3 is missing',30)
			return
		end
		RegisterScoreTarget('factoryBulding3',tgt,500,L10N:Get("SINAI_TARGET_HIGH_VALUE_FACTORY"),true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("SINAI_TARGET_HIGH_VALUE_FACTORY"),p,2,false,false)
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
	title = LTGet("SINAI_MISSION_HIGH_VALUE_FACTORY_TITLE"),
	description = LTGet("SINAI_MISSION_FACTORY_BALUZA_DESC"),
	messageStart = L10N:Get("SINAI_MISSION_HIGH_VALUE_FACTORY_START"),
	messageEnd = L10N:Get("SINAI_MISSION_HIGH_VALUE_FACTORY_STRIKE_END"),
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
----------------------- FLAGS --------------------------


buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end
-------------------------- END OF FLAGS --------------------------

airbaseStatics = {
	["FARP Alpha"] = {"Farpalphaammo", "Farpalphafuel", "Farpalphatent1", "Farpalphatent2", "Farpalphatent3", "Farpalphatent4", "Farpalphacommand", "Farpalphawind"},
    ["FARP Bravo"] = {"Farpkiloammo", "Farpkilofuel", "Farpkilotent1", "Farpkilotent2", "Farpkilotent3", "Farpkilotent4", "Farpkilocommand", "Farpkilowind"},
    ["FARP Charlie"] = {"Farplimaammo", "Farplimafuel", "Farplimatent1", "Farplimatent2", "Farplimatent3", "Farplimatent4", "Farplimacommand", "Farplimawind"},
	
}

env.info("Mission Setup : is completed!")



