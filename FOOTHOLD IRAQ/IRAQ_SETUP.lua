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
		blue = {'blueShip', 'blueShip', 'blueShip'},
		red = {'redShipS', 'redShipS-2', 'redShipS-1', 'redShipM', 'redShipM-1', 'redShipM-2', 'redShipL-1', 'redShipL', 'redShipL-2', 'redShipXL'}
	},
	blueships = {
		blue = {'blueShip'},
		red = {'redShipXL'}
	},
	airfield1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Enemy ground forces 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8 2'}
	},
	
	airfieldStart = {
		blue = {'blueArmor', 'bluePD1'},
		red = {}
	},
	airfield2 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces','Red SAM AAA 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19 2'}
	},
	airfield3 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Enemy ground forces 2', 'Red Armour Group 2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19 2', 'Red SAM SHORAD Pantsir S1'}
	},
	airfield3Sahra = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Enemy ground forces 2', 'Red SAM AAA', 'Red SAM SHORAD SA-19 Fixed Sahra', 'Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19 2', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}
	},
	airfield6 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1', 'bluePATRIOT'},
		red = {'Enemy ground forces 2', 'Red SAM AAA 2', 'Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19 2', 'Red SAM SHORAD Tor M2'}
	},
	airfield4 = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Enemy ground forces 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD Pantsir S1', 'Red SAM AAA', 'Red SAM SHORAD SA-8'}
	},
	Ramadi = {
		blue = {'blueInfantry','blueArmor', 'bluePD2'},
		red = {'Enemy ground forces 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD Pantsir S1', 'Red SAM AAA', 'Red SAM AAA 3 Ramadi Fixed', 'Red SAM AAA 4 Ramadi Fixed'}
	},
	farp1 = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Enemy ground forces', 'Red SAM AAA 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM AAA', 'Red SAM SHORAD SA-8 2','Red SAM SHORAD SA-8'}
	},
	farp1Koya = {
		blue = {'bluePD1'},
		red = {'Red Armour Group', 'Red Armour Group 2', 'Red SAM AAA 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8 2', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15 2'}
	},
	farp1Dukan = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8 2'}
	},
	farp1San = {
		blue = {'blueInfantry', 'blueArmor', 'bluePD1'},
		red = {'Red SAM AAA 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-19 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8 2'}
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
		red = {'Enemy ground forces 2', 'Red SAM AAA 2', 'Red Armour Group', 'Red Armour Group 2', 'Red SAM AAA', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-8 2'}
	},	
	BarzanGroup = {
	    blue = {'blueInfantry'},
		red = {}
	},
	SamEastGroup = {
	    blue = {},
		red = {'Red SAM SA-11 Fixed SAMEAST','Red SAM AAA Fixed SAMEAST 2', 'Red SAM SHORAD Tor M2 Fixed SAMEAST 2'}
	},
	SamWestGroup = {
	    blue = {},
		red = {'Red SAM SHORAD SA-19 Fixed SAMWEST', 'Red SAM SA-3 Fixed SAMWEST', 'Red SAM SHORAD Tor M2 Fixed SAMWEST'}
	},
	SamSouthGroup = {
		blue = {},
		red = {'Red SAM SA-11 Fixed SAMSOUTH','Red SAM SHORAD Tor M2','Red SAM AAA Fixed SAMSOUTH', 'Red SAM SHORAD SA-8'}
	},
	RamadiSamGroup = {
	    blue = {},
		red = {'Red SAM SHORAD SA-8 Fixed ramadi', 'Red SAM SA-2 Fixed Ramadi', 'Red SAM SHORAD AAA Fixed ramadi'}
	},
	KirkukCity = {
	    blue = {'blueInfantry', 'blueArmor', 'bluePD2', 'blueHAWK'},
		red = {'Red SAM SA-3 Fixed KirkukCity', 'Red SAM SHORAD SA-8 Kirkuk City Fixed', 'Red SAM AAA Group Fixed', 'Kirkuk City Group Fixed2', 'Red Armour Group 2','Red SAM AAA 3 Kirkuk Fixed', 'Red SAM AAA 4 Kirkuk Fixed'}
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
		red = {'Red SAM SA-3 Erbil Fixed-1', 'Red SAM SA-6 Erbil Fixed', 'Red SAM AAA Erbil Fixed'}
	},
	FaljuaCity = {
		blue = {'bluePD1'},
		red = {'Red SAM AAA Fallujah', 'Faluja-Fixed-Group3', 'Faluja-Fixed-Group2', 'Red SAM SHORAD SA-15 Fixed Faljua','Red SAM SHORAD SA-15 Fixed Faljua-2','Armour patrol Fixed'}
    },
	BaladGroup = {
		blue = {'blueArmor', 'bluePD1'},
		red = {'Red SAM SA-3 Balad Fixed', 'Red SAM SA-2 Balad Fixed','Red Armour Group', 'Red SAM SHORAD SA-15 Fixed Balad', 'Red SAM SHORAD SA-19 Fixed Balad'}
    },
	SahraDefence = {
		blue = {},
		red = {'Red SAM SHORAD SA-15 Fixed Sahra Defence', 'Red SAM Fixed Al Sahra', 'Sahra Defence Fixed Group','Red SAM AAA 3 Sahra Fixed','Red SAM AAA 4 Sahra Fixed'}
    },
	BaladDefence = {
		blue = {},
		red = {'Red SAM SHORAD SA-15 FIxed Balad Defence', 'Red SAM SA-11 Fixed Balad Defence', 'Red SAM AAA Balad Fixed'}
    },
	borjoilFixed = {
		blue = {},
		red = {'Red SAM SA-6 Fixed Borj Oil production', 'Red SAM SHORAD SA-15 Oil Production','Red SAM SHORAD SA-15 Oil Production 2', 
		'Fixed-redInfantry Borj Oil production', 'Borj Oil production_4', 'Borj Oil production_3', 'Borj Oil production_2', 'Borj Oil production_1', 
		'Borj Oil production_5', 'Borj Oil production_6'}
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
	miningfacility = 'Check kneeboard for coordinates.\n',
	insurgentcamp = 'Check kneeboard for coordinates.\nDestroy the Insurgents and we will add to your bank 500 credits',
	secrettechfacility = 'Check kneeboard for coordinates.\nDestroy the buildings and area completly',
	uranium = 'Check kneeboard for coordinates.\nDestroy the buildings and area completly',
	--------------
	bashurairport = 'WPT 1\n',
	erbilairport = 'WPT 2\n',
	erbildefence = 'WPT \n',
	barzan = 'WPT 3\n',
	chamanki = 'WPT 4\n',
	outpost = 'WPT 5\n',
	duhokcity = 'WPT 6\n',
	mosulcity = 'WPT 7\n',
	hammam = 'WPT 8\n',
	talafar = 'WPT 9\n',
	altall = 'WPT 10\n',
	qayyarah = 'WPT 11\n',
	alabbasi = 'WPT 12\n',
	kirkuk = 'WPT 13\n',
	sulaimaniyah = 'WPT 14\n',
	saidsadiq = 'WPT 15\n',
	maydan = 'WPT 16\n',
	sarqala = 'WPT 17\n',
	khormato = 'WPT 18\n',
	alsahra = 'WPT 19\n',
	fobtherethar = 'WPT 20\n',
	alasadairbase = 'WPT 21\n',
	ramadi = 'WPT 22\n',
	fallujah = 'WPT 23\n',
	fobsamarra = 'WPT 24\n',
	baladairbase = 'WPT 25\n',
	alsalamairbase = 'WPT 26\n',
	baladdefence = 'WPT N/A\n',
	
	
	scudcity = 'WPT N/A\nFind the scuds in the city and destroy them, there is also Tripple A installations. Destroy everything.',

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
	['Armour Group Chemsite Fixed']  = 'Armour Group Chemsite Fixed-Coldwar',
	['blueHAWK']  = 'blueHAWK-Coldwar',
	['bluePATRIOT']  = 'bluePATRIOT-Coldwar',
	['bluePD2']  = 'bluePD2-Coldwar',
	['blueArmor']  = 'blueArmor-Coldwar',
	['Red SAM SHORAD SA-15']   						= 'Red SAM SHORAD SA-8',
	['Red SAM SHORAD SA-15 2']   					= 'Red SAM SHORAD SA-8 2',
	['Red SAM SHORAD SA-15 Fixed Faljua']   		= 'Red SAM SHORAD SA-8 Fixed Faljua-Coldwar',
	['Red SAM SHORAD SA-15 Fixed Faljua-2']   		= 'Red SAM SHORAD SA-8 Fixed Faljua-Coldwar-2',
	['Red SAM SHORAD Tor M2 Fixed SAMEAST 2']  		= 'Red SAM SHORAD SA-8 Fixed SAMEAST 2',
	['Red SAM SHORAD Tor M2 Fixed SAMWEST']   		= 'Red SAM SHORAD SA-8 Fixed SAMWEST',
	['Red SAM SHORAD SA-15 Fixed Balad']   			= 'Red SAM SHORAD SA-8 Fixed Balad',
	['Red SAM SHORAD SA-15 FIxed Balad Defence']   	= 'Red SAM SHORAD SA-8 FIxed Balad Defence',
	['Red SAM SHORAD SA-15 Fixed Uranium']   		= 'Red SAM SHORAD SA-8 Fixed Uranium 2',
	['Red SAM SHORAD SA-15 Oil Production 2']   	= 'Red SAM SHORAD SA-8 Oil Production 2',
	['Red SAM SHORAD SA-15 Oil Production']   		= 'Red SAM SHORAD SA-8 Oil Production',
	['Red SAM SA-15 Fixed Hiddengroup5']   			= 'Red SAM SA-8 Fixed Hiddengroup5',
	['Red SAM SHORAD SA-15 Fixed Checksite']   		= 'Red SAM SHORAD SA-8 Fixed Checksite',
	['Red SAM SHORAD SA-15 Hiddengroup3-Fixed2']    = 'Red SAM SHORAD SA-8 Hiddengroup3-Fixed2',
	['Red SAM SHORAD SA-8']    						= {'Red SAM AAA 3','Red SAM AAA 4'},
	['Red SAM SHORAD Tor M2']    					= 'Red SAM SHORAD SA-8',
	['Red SAM SHORAD Pantsir S1']    				= 'Red SAM SHORAD SA-8',
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
	deepSwap(upgrades,cwSwap)
end

local SamSwap = {

	['Red SAM SA-11 Fixed SAMSOUTH']   				= 'Red SAM SA-2 Fixed SAMSOUTH',
	['Red SAM SA-11 Fixed SAMEAST']  			  	= 'Red SAM SA-2 Fixed SAMEAST',
	['Red SAM SA-11 Fixed Balad Defence']   		= 'Red SAM SA-2 Fixed Balad Defence',

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

	bashurairport = ZoneCommander:new({zone='Bashur Airport', side=2, level=20, upgrades=upgrades.airfieldStart, crates={},flavorText=flavor.bashurairport}),
	erbilairport = ZoneCommander:new({zone='Erbil Airport', side=1, level=20, upgrades=upgrades.airfield2, crates={},flavorText=flavor.erbilairport}),
	mosulcity = ZoneCommander:new({zone='Mosul City', side=1, level=20, upgrades=upgrades.MosulCityGroup, crates={},flavorText=flavor.mosulcity}),
	hammam = ZoneCommander:new({zone='Hammam Al Alil', side=1, level=20, upgrades=upgrades.mission4, crates={},flavorText=flavor.hammam}),
	duhokcity = ZoneCommander:new({zone='Duhok City', side=1, level=20, upgrades=upgrades.DuhukCityGroup, crates={},flavorText=flavor.duhokcity}),
	talafar = ZoneCommander:new({zone='Tal Afar', side=1, level=20, upgrades=upgrades.mission4, crates={},flavorText=flavor.talafar}),
	altall = ZoneCommander:new({zone='Al Tall', side=1, level=20, upgrades=upgrades.mission4, crates={},flavorText=flavor.altall}),	
	qayyarah = ZoneCommander:new({zone='Qayyarah Airfield', side=1, level=20, upgrades=upgrades.mission4, crates={},flavorText=flavor.qayyarah}),
	alabbasi = ZoneCommander:new({zone='Al Abbasi', side=1, level=20, upgrades=upgrades.mission4, crates={},flavorText=flavor.alabbasi}),
	kirkuk = ZoneCommander:new({zone='Kirkuk City', side=1, level=20, upgrades=upgrades.KirkukCity, crates={},flavorText=flavor.kirkuk}),
	sulaimaniyah = ZoneCommander:new({zone='Sulaimaniyah Airport', side=1, level=20, upgrades=upgrades.airfield3, crates={},flavorText=flavor.Sulaimaniyah}),
	saidsadiq = ZoneCommander:new({zone='Said Sadiq', side=1, level=20, upgrades=upgrades.airfield3, crates={},flavorText=flavor.saidsadiq}),
	alsahra = ZoneCommander:new({zone='Al-Sahra Airport', side=1, level=20, upgrades=upgrades.airfield3Sahra, crates={},flavorText=flavor.alsahra}),
	barzan = ZoneCommander:new({zone='Barzan', side=2, level=4, upgrades=upgrades.BarzanGroup, crates={},flavorText=flavor.barzan}),
	chamanki = ZoneCommander:new({zone='Chamanki', side=1, level=20, upgrades=upgrades.farp2, crates={},flavorText=flavor.chamanki}),
	outpost = ZoneCommander:new({zone='OutPost', side=1, level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.outpost}),
	maydan = ZoneCommander:new({zone='Maydan', side=1, level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.maydan}),
	sarqala = ZoneCommander:new({zone='Sarqala', side=1, level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.sarqala}),
	khormato = ZoneCommander:new({zone='Khormato', side=1, level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.Khormato}),
	baladairbase = ZoneCommander:new({zone='Balad Airbase', side=1, level=20, upgrades=upgrades.BaladGroup, crates={},flavorText=flavor.baladairbase}),
	alsalamairbase = ZoneCommander:new({zone='Al-Salam Airbase', side=1, level=20, upgrades=upgrades.airfield3, crates={},flavorText=flavor.alsalamairbase}),
	fallujah = ZoneCommander:new({zone='Fallujah', side=1, level=20, upgrades=upgrades.FaljuaCity, crates={},flavorText=flavor.fallujah}),
	ramadi = ZoneCommander:new({zone='Ramadi', side=1, level=20, upgrades=upgrades.Ramadi, crates={},flavorText=flavor.ramadi}),
	alasadairbase = ZoneCommander:new({zone='Al-Asad Airbase', side=1, level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.alasadairbase}),
	koya = ZoneCommander:new({zone='Koya', side=1, level=20, upgrades=upgrades.farp1Koya, crates={},flavorText=flavor.Koya}),
	dukan = ZoneCommander:new({zone='Dukan', side=1, level=20, upgrades=upgrades.farp1Dukan, crates={},flavorText=flavor.dukan}),
	sangasar = ZoneCommander:new({zone='Sangasar', side=1, level=20, upgrades=upgrades.farp1San, crates={},flavorText=flavor.sangasar}),

	fobsamarra = ZoneCommander:new({zone='FOB Samarra', side=0, level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.fobsamarra, ForceNeutral=true}),
	fobtherethar = ZoneCommander:new({zone='FOB Therethar', side=0, level=20, upgrades=upgrades.farp1, crates={},flavorText=flavor.fobtherethar, ForceNeutral=true}),


	erbildefence = ZoneCommander:new({zone='Erbil Defence', side=1, level=20, upgrades=upgrades.erbildefence, crates={},flavorText=flavor.erbildefence}),
	sameast = ZoneCommander:new({zone='SAM East', side=1, level=20, upgrades=upgrades.SamEastGroup, crates={},flavorText=flavor.sameast}),
	samwest = ZoneCommander:new({zone='SAM West', side=1, level=20, upgrades=upgrades.SamWestGroup, crates={},flavorText=flavor.samwest}),
	samsouth = ZoneCommander:new({zone='SAM South', side=1, level=20, upgrades=upgrades.SamSouthGroup, crates={},flavorText=flavor.samsouth}),
	sahradefence = ZoneCommander:new({zone='Sahra Defence', side=1, level=20, upgrades=upgrades.SahraDefence, crates={},flavorText=flavor.sahradefence}),
	baladdefence = ZoneCommander:new({zone='Balad Defence', side=1, level=20, upgrades=upgrades.BaladDefence, crates={},flavorText=flavor.baladdefence}),
	ramadisam = ZoneCommander:new({zone='Ramadi SAM', side=1, level=20, upgrades=upgrades.RamadiSamGroup, crates={},flavorText=flavor.ramadisam}),


	oilsite = ZoneCommander:new({zone='Oil production Site', side=1, level=10, upgrades=upgrades.borjoilFixed, crates={}, flavorText=flavor.oilsite}),
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
    CapPlaneTemplate = CapPlaneTemplate or {
        'RED_MIG29A',
        'RED_SU27_EW',
        'RED_MIG21Bis',
        'RED_MIG23MLD',
        'RED_MIG25PD',
        'BLUE_HORNET_CW',
        'BLUE_F15C_CW',
        'BLUE_F14A',
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

	RunwayStrikePlaneTemplate = RunwayStrikePlaneTemplate or {
        "RED_MIG-27K",
        "RED_SU-33",
    }
end

PlaneSupplyTemplate = PlaneSupplyTemplate or {
	"IL-76MD",
	"C-130",
}

SupplyConvoy = SupplyConvoy or {
    "SupplyConvoy 1",
    "SupplyConvoy 2",
    "SupplyConvoy 3",
}

function CasAltitude() return math.random(15,25)*1000 end
function CapAltitude() return math.random(22,32)*1000 end
function SeadAltitude() return math.random(25,33)*1000 end
function RunwayStrikeAltitude() return math.random(23,28)*1000 end

zones.bashurairport:addGroups({
    GroupCommander:new({name='Bashur-Airport-supply-Erbil', mission='supply',template='HeloSupplyTemplate', targetzone='Erbil Airport'})
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
	GroupCommander:new({name='Tal Afar-patrol-mosul', mission='attack',template='CasHeloTemplate',MissionType='CAS', targetzone='Mosul City', spawnDelayFactor = 1.5})
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
	GroupCommander:new({name='sahra-attack-erbil-cas', mission='attack',template='CasPlaneTemplate',MissionType='CAS', targetzone='Erbil Airport', spawnDelayFactor = 3}),
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


zones.secrettechfacility:addCriticalObject('SecretTechFacility1')
zones.secrettechfacility:addCriticalObject('SecretTechFacility2')
zones.secrettechfacility:addCriticalObject('SecretTechFacility3')
zones.secrettechfacility:addCriticalObject('SecretTechFacility4')
zones.secrettechfacility:addCriticalObject('SecretTechFacility5')

missions = {
    Barzan = {	
        zone = "Barzan",
        missionGroup = "MissionGroupBarzan",
        menuTitle = "Mission: Ground Escort",
        missionTitle = "Mission: Ground Escort",
        TargetZone = "Chamanki",
        MissionType = "Escort",
		radius = 2000,
		flag = 101,
		ActivateZone = "barzanhidden"
    },
    Chamanki = {
        zone = "Chamanki",
        missionGroup = "MissionGroupChamanki",
        menuTitle = "Chamanki: Ground Escort",
        missionTitle = "Chamanki: Ground Escort",
        TargetZone = "OutPost",
        MissionType = "Escort",
		radius = 2000,
		flag = 111,
		ActivateZone = "chamankihidden"
    },
    OutPost = {	
        zone = "OutPost",
        missionGroup = "MissionGroupOutpost",
        menuTitle = "Outpost: Ground Escort",
        missionTitle = "Outpost: Ground Escort",
        TargetZone = "Duhok City",
        MissionType = "Escort",
		radius = 2500,
		flag = 121,
		ActivateZone = "outposthidden"
    },
	Ramadi = {	
        zone = "Ramadi",
        missionGroup = "MissionGroupRamadi",
        menuTitle = "Ramadi: Ground Escort",
        missionTitle = "Ramadi: Ground Escort",
        TargetZone = "Fallujah",
        MissionType = "Escort",
		radius = 3000,
		flag = 131,
		ActivateZone = "ramadihidden"
    },
	Koya = {
        zone = "Koya",
        missionGroup = "MissionGroupKoya",
        menuTitle = "Koya: Ground Escort",
        missionTitle = "Koya: Ground Escort",
        TargetZone = "Dukan",
        MissionType = "Escort",
		radius = 3000,
		flag = 141,
		ActivateZone = "koyahidden"
    },
	Dukan = {
        zone = "Dukan",
        missionGroup = "MissionGroupDukan",
        menuTitle = "Dukan: Ground Escort",
        missionTitle = "Dukan: Ground Escort",
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
	trigger.action.outTextForCoalition(2,'chemical site destroyed, Good job\n+500 credits',20)
end, 'disablechemsite2')

zones.miningfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Mining Facility cleared\n+500 credits',20)
end, 'disableminingfacility')


zones.secrettechfacility:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
end, 'disablesecrettechfacility1')

zones.secrettechfacility:registerTrigger('destroyed', function(event, sender) 
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'secret tech facility disabled\n+500 credits',20)
end, 'disablesecrettechfacility2')

zones.insurgentcamp:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Insurgent Camp destroyed, Good job\n+500 credits',20)
end, 'disableinsurgentcamp')

zones.erbildefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemey SAM destroyed\n+200 credits',20)
end, 'erbildefencesambravo')

zones.sameast:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemey SAM destroyed\n+200 credits',20)
end, 'sameastsamcharlie')

zones.samwest:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemey SAM destroyed\n+200 credits',20)
end, 'samwestsamdelta')

zones.samsouth:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemey SAM destroyed\n+200 credits',20)
end, 'samsouthsamecho')

zones.ramadisam:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemey SAM destroyed\n+200 credits',20)
end, 'disableramadisam')

zones.sahradefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemey SAM destroyed\n+200 credits',20)
end, 'disablesahradefence')

zones.baladdefence:registerTrigger('lost', function(event, sender) 
	sender:disableZone()
	bc:addFunds(2,200)
	trigger.action.outTextForCoalition(2,'Enemey SAM destroyed\n+200 credits',20)
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


SCHEDULER:New(nil,function()
	checkMissionComplete(nil, nil)
  if Era == 'Coldwar' then
	bc:roamGroupsToLocalSubZone({
		"Red SAM AAA #",
		"Red SAM AAA 2 #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-19 2 #",
		"Red SAM SHORAD Tor M2 #",
		"Red SAM SHORAD Pantsir S1 #",
		'Red Armor Group6',
		'Red Armor Group8',
	}, 30)
  else
	bc:roamGroupsToLocalSubZone({
	"Red Armor Group 2 #",
	"Red SAM AAA #",
	"Red SAM AAA 2 #",
	"Red SAM SHORAD SA-15 #",
	"Red SAM SHORAD SA-8 #",
	"Red SAM SHORAD SA-19 2 #",
	"Red Armor Group #",
  
	}, 30)
  end
end,{},30,0)

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

---------------------------------------------END DYNAMIC SHOP ------------------------------------------

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
Group.getByName('ca-arty'):destroy()
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
	if params.zone and params.zone.side == 1 then
		local gr = Group.getByName('ewAircraft')
		if Utils.isGroupActive(gr) then 
			return 'Jamming mission still in progress'
		end
		
		RespawnGroup('ewAircraft')
		
		local ew = Group.getByName('ewAircraft')
		if ew then
			local err = bc:jamRadarsAtZone('ewAircraft', target)
			if err then
				return err
			end
			
			trigger.action.outTextForCoalition(2, 'Growler jamming radars at '..target, 15)
		end
	else
		return 'Can only target enemy zone'
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
				local zn = bc:getZoneByName(zName)
				if not zn or zn.side ~= 1 or not zn.suspended then return end
				if intelActiveZones[zName] then
					intelActiveZones[zName] = false
					trigger.action.outTextForCoalition(2, 'Intel on '..zName..' has expired.', 10)
				end
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
			if intelActiveZones[zName] then
				intelActiveZones[zName] = false
				trigger.action.outTextForCoalition(2, 'Intel on '..zName..' has expired.', 10)
			end
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
	if params.zone and params.zone.side==2 and not params.zone.suspended then
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
			z:addExtraSlot('bluePATRIOT') -- checked
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
		params.zone:addExtraSlot('bluePATRIOT') -- checked
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


lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

bc:loadFromDisk()
bc:init()
bc:startRewardPlayerContribution(15,{infantry = 10, ground = 10, sam = 30, airplane = 30, ship = 200, helicopter=30, crate=100, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, ['CAP mission'] = true, ['CAS mission'] = true})


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
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=100 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=75 }   -- blue
}

GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 90   		-- suspend red zones deeper than this nm
evc = EventCommander:new({ decissionFrequency=30*60, decissionVariance=30*60, skipChance = 15})
mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})
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
				trigger.action.outTextForCoalition(2, 'SCUDS at Scud city are launching at '..choice, 15)
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
		if u then RegisterUnitTarget(u:getName(),250,'Intercept cargo plane') end
	end,
	canExecute = function()
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
    title = "Intercept cargo plane",
    description = "Find and destroy the enemy cargo plane near coming from Syria, supplying unknown location.",
    messageStart = "New mission: Intercept cargo plane",
    messageEnd =function() lastCargoIntercept_COOLDOWN=timer.getTime() return "Mission ended: Intercept cargo plane" end,
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
		RegisterGroupTarget(attackGrp,250,'Intercept enemy airstrike')
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
	title = "Intercept enemy airstrike",
	description = "Enemy aircraft conducting an airstrike from the south to North\nDestroy them before they get in range.",
	messageStart = "New mission: Intercept enemy airstrike",
	messageEnd =function() lastairstrike_COOLDOWN=timer.getTime() return "Mission ended: Intercept enemy airstrike" end,
	startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
	isActive = function()
		local gr = Group.getByName('evt-attack')
		if gr then return true else return false end
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
    trigger.action.outText(name .. ' is missing', 30)
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
		RegisterGroupTarget('evt-bomb',500,'Intercept enemy bombers')
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
	title = "Intercept Bombers",
	description = "Enemy bombers spotted to inbound from Iran. They are escorted by 2 MIG29\nDestroy them before they get in range.",
	messageStart = "New mission: Intercept Bombers",
	messageEnd=function() lastbomb_COOLDOWN=timer.getTime() return "Mission ended: Intercept Bombers" end,
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
    title = "Escort cargo plane",
    description = "Friendly cargo plane is taking off from Erbil Airport. Protect it until it leaves the airspace.",
    messageStart = "New strike mission: Escort cargo plane\n\nFriendly cargo plane is taking off from Erbil airport and headed south. Protect it until it leaves the airspace.",
    messageEnd =function() lastEscort_COOLDOWN=timer.getTime() return "Strike mission ended: Escort cargo plane" end,
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
		RegisterGroupTarget("KanaqinConvoy-2",500,"Al-Baghdadi's associate","FindHimInKanaqin")
	end,
	canExecute = function()
		if Group.getByName('KanaqinConvoy') then return false end
		if bc:getZoneByName('Al-Sahra Airport').side ~= 2 or bc:getZoneByName('Al-Sahra Airport').suspended then return false end
		if CustomFlags["FindHimInKanaqin"] then return false end
		return true
end
})

mc:trackMission({
	title = "Al-Baghdadi's associate",
	description = 
[[We have intel on one of Al-Baghdadi's associates located somewhere in the city of Kanaqin.

MGRS: 38 S ND 36035 00754
Lat long: N 34°20'50" E 45°23'30"
Lat long Decimal Minutes: N 34°20.833' E 45°23.500'

Elevation: 609 feet

Reward: 500

Follow the convoy until they reach the house.
Once the location is confirmed, kill him.

Don't destroy the convoy until they reach the house!]],
	messageStart = "New strike mission: Kill Al-Baghdadi associate",
	messageEnd = "Strike mission ended: Al-Baghdadi associate",
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
			trigger.action.outTextForCoalition(2, "The convoy is destroyed before reaching the target.\nMission failed", 10)
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
			destroyGroupIfActive('KanaqinConvoy-2')
			destroyGroupIfActive('KanaqinConvoy-1')
			return true
		end
		return false
	end,
	isActive = function()
		if CustomFlags["FindHimInKanaqin"] then return false end
		if Group.getByName('KanaqinConvoy') then return true end
		if Group.getByName('KanaqinConvoy-1') then return true end
		if Group.getByName('KanaqinConvoy-2') then return true end
	return false
	end
})
-- end of Al-Baghdadi associate

-- strike target 2

Group.getByName('Red SAM SHORAD SA-8 StrikeTarget2'):destroy()
evc:addEvent({
	id='StrikeTarget2',
	action = function()
	ActiveMission['StrikeTarget2'] = true
	local tgt = sceneryList['StrikeTarget2'][1] or SCENERY:FindByZoneName('StrikeTarget2')
	if not tgt then
		trigger.action.outText('StrikeTarget2 is missing',30)
		return
	end
		RespawnGroup('Red SAM SHORAD SA-8 StrikeTarget2')
		RegisterScoreTarget('StrikeTarget2',tgt,500,'High value target 2')
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"High value target 2",p,2,false,false)
			MissionMarks['StrikeTarget2'] = missionMarkId
		end
	end,
	canExecute = function()
		if CustomFlags["StrikeTarget2"] then return false end
		if bc:getZoneByName('Al-Sahra Airport').side ~= 2 or bc:getZoneByName('Al-Sahra Airport').suspended then return false end
		if ActiveMission['StrikeTarget2'] then return false end
		return true
	end
})

mc:trackMission({
	title = "Strike High value target 2",
	description = 
	[[Strike a high value building at these coordinates:

	MGRS: 38 S MC 13902 71190  
	Lat long: N 34°04'40" E 44°04'00"  
	Lat long Decimal Minutes: N 34°04.676' E 44°04.010'

	Elevation: 158 feet

	reward = 500]],
	messageStart = "New strike mission: Strike High value target",
	messageEnd = "Strike mission ended: Strike High value target",
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
	id='StikeTarget3',
	action = function()
		RespawnGroup('StrikeTarget3Group')
		RegisterGroupTarget('StrikeTarget3Group',250,'Sadam Hussiens assosisets','StrikeTarget3')
	end,
	canExecute = function()
		if bc:getZoneByName('Al-Asad Airbase').side ~= 2 or bc:getZoneByName('Al-Asad Airbase').suspended then return false end
		if CustomFlags["StrikeTarget3"] then return false end
		if Group.getByName('StrikeTarget3Group') then return false end
		return true
	end
})

mc:trackMission({
	title = "Strike on one of Sadam Hussiens assosisets",
description = 
[[We have the location on one of Sadams assosisets
near the Syrian border, Take him out!.

Coordinates:
MGRS: 37 S FU 82033 06131
Lat Long: N 34°22'50" E 40°58'47"
Lat long Decimal Minutes: N 34°22.834' E 40°58.794'
Elevation: 631 feet

Reward: 500

Destroy the house and whoever is nearby.]],

	messageStart = "New strike mission: Kill Sadam Hussiens assosisets",
	messageEnd = "Strike mission ended: Kill Sadam Hussiens assosisets\n+500 credits",
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
		if Group.getByName('StrikeTarget3Group') then return true end
		return false
	end
})
-- end of strike target 3
---------------------------------- strike target 1 -----------------------------------------------

evc:addEvent({
	id = 'StrikeTarget1',
	action = function()
		ActiveMission['StrikeTarget1'] = true
		local tgt = sceneryList['StrikeTarget1'][1] or SCENERY:FindByZoneName('StrikeTarget1')
		if not tgt then
			trigger.action.outText('StrikeTarget1 scenery missing',30)
			return
		end
		RegisterScoreTarget('StrikeTarget1',tgt,500,'High value target')
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"High value target",p,2,false,false)
			MissionMarks['StrikeTarget1'] = missionMarkId
		end
	end,
	canExecute = function()
		if CustomFlags['StrikeTarget1'] then return false end
		if ActiveMission['StrikeTarget1'] then return false end
		if bc:getZoneByName('Qayyarah Airfield').side ~= 2 or bc:getZoneByName('Qayyarah Airfield').suspended then return false end
		if bc:getZoneByName('Al-Sahra Airport').side ~= 1 or bc:getZoneByName('Al-Sahra Airport').suspended then return false end
		return true
	end
})

mc:trackMission({
	title = "Strike High value target",
	description = 
[[Strike a high-value building at these coordinates:

MGRS: 38 S LD 64653 55710  
Lat long: N 34°50'04" E 43°31'11"  
Lat long Decimal Minutes: N 34°50.081' E 43°31.188'

Elevation: 463 feet

reward = 500]],
	messageStart = "New strike mission: Strike High value target",
	messageEnd = "Strike mission ended: Strike High value target",
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
		RegisterGroupTarget('StrikeTargetInfantry',500,'High value target','StrikeTarget')
	end,
	canExecute = function()
		if math.random(1,100) < 50 then return false end
		if bc:getZoneByName('Sulaimaniyah Airport').side ~= 2 or bc:getZoneByName('Sulaimaniyah Airport').suspended then return false end
		if CustomFlags["StrikeTarget"] then return false end
		return true
	end
})

mc:trackMission({
	title = "Kill Al-Baghdadi assosiset",
	description = 
[[One of Al-Baghdadi's associates is located somewhere in the city of Kalar

Coordinates:
MGRS: 38 S ND 29164 32253
Lat long: N 34°37'54" E 45°19'05"
Lat long Decimal Minutes: N 34°37.905' E 45°19.090'
Elevation: 722 feet.

Wait until they reach their hideout and take them out including the building.

2000 pounds bomb required

Don't kill the convoy until they reach the house!]],

	messageStart = "New strike mission: Kill Al-Baghdadi assosiset",
	messageEnd = "Strike mission ended: Kill Al-Baghdadi assosiset",
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
			trigger.action.outTextForCoalition(2, "The convoy is destroyed and the generals location is still unknown\nMission failed", 15)
			trigger.action.outSoundForCoalition(2, "cancel.ogg")
			return true
		end
		return false
	end,
	isActive = function()
	if CustomFlags["StrikeTarget"] then return false end
	if Group.getByName('GeneralKillConvoy') then return true end
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
		RegisterGroupTarget('RightHandMan',250,'Right hand man','RightHandMan')
	end,
	canExecute = function()
		if bc:getZoneByName('Erbil Airport').side ~= 2 or bc:getZoneByName('Erbil Airport').suspended then return false end
		if CustomFlags["RightHandMan"] then return false end
		if Group.getByName('RightHandMan') then return false end
		return true
	end
})

mc:trackMission({
	title = "Kill Al-Baghdadis right hand man",
description = 
[[We have the location on one of Al-Baghdadi's Righthand
man in the city of Al-Qairawan, Take him out!.

Coordinates:
MGRS: 38 S KF 32817 05697
Lat Long: N 36°09'33" E 42°01'47"
Lat long Decimal Minutes: N 36°09.562' E 42°01.887'
Elevation: 1055 feet

Reward: 500

Destroy the house and whoever is nearby.]],

	messageStart = "New strike mission: Kill the Al-Baghdadis right hand man",
	messageEnd = "Strike mission ended: Kill the Al-Baghdadis right hand man",
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
		if Group.getByName('RightHandMan') then return true end
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
				trigger.action.outTextForCoalition(2, 'Artillery near Al-Tall are launching at '..choice, 15)
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
	title = "Destroy artillery",
	description = "Artillery has been spotted heading North east from the direction of Al-Tall.\nDestroy them before they get in range.",
	messageStart = "New mission: Destroy artillery convoy from Al-Tall",
	messageEnd = "Mission ended: Destroy artillery",
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
		RegisterGroupTarget('Khormato-Artillery',250,'Destroy artillery')
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
				trigger.action.outTextForCoalition(2, 'Artillery near Khormato are launching at '..choice, 15)
			end
		end, {}, timer.getTime()+(20*60))
	end,
	canExecute = function()
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
	title = "Destroy artillery",
	description = "Artillery has been spotted heading north from the direction of Khormato.\nDestroy them before they get in range.",
	messageStart = "New mission: Destroy artillery convoy from Khormato",
	messageEnd = "Mission ended: Destroy artillery",
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
		local gr = Group.getByName('Khormato-Artillery')
		if gr then return true else return false end
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
			RegisterGroupTarget(entry.group,250,'Destroy artillery')
        end
    end,
    canExecute = function()
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
    title = "Helo Hunt Balad Airbase",
    description = "Large number of KA-50 taking off from Balad Airbase heading to our closest friendly bases\nDestroy them before they get in range.",
    messageStart = "New mission: Helo hunt\nLarge number of KA-50 takingoff from Balad Airbase heading to our closest friendly bases\n\nDestroy them before they get in range.",
    messageEnd = "Mission ended: Helo hunt",
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
        local groups = {'Balad-attack-Al-Sahra Airport-event',
            'Balad-attack-Khormato-event','Balad-attack-Sarqala-event',
            'Balad-attack-Maydan-event'}
        for _, groupName in ipairs(groups) do
            if Group.getByName(groupName) then
                return true
            end
        end
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
            bc:addContribution(pname,2,reward)
            local jp = bc.jointPairs and bc.jointPairs[pname]
            if jp and bc:_jointPartnerAlive(pname) and bc:_jointPartnerAlive(jp) and bc.playerContributions[2][jp] ~= nil then
                bc:addContribution(jp,2,reward)
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
            bc:addContribution(pname,2,reward)
            local jp = bc.jointPairs and bc.jointPairs[pname]
            if jp and bc:_jointPartnerAlive(pname) and bc:_jointPartnerAlive(jp) and bc.playerContributions[2][jp] ~= nil then
                bc:addContribution(jp,2,reward)
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
		ActiveCurrentMission[attackTarget] = ActiveCurrentMission[attackTarget] or {}
		ActiveCurrentMission[attackTarget]["Attack"] = true
		local z = bc:getZoneByName(attackTarget) if z then z:updateLabel() end
		if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
			trigger.action.outSoundForCoalition(2, "cas.ogg")
		end
	end,
	endAction = function()
		local t = ActiveCurrentMission[attackTarget]
		if t then
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

function generateCaptureMission()
    if captureTarget ~= nil then return end
    
    local validzones = {}
    for _, v in ipairs(bc.zones) do
        if v.active and v.side == 0 and (not v.NeutralAtStart or v.firstCaptureByRed) and
           not v.ForceNeutral and not string.find(v.zone, "Hidden") then
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
    if validzones[choice] then
        attackTarget = validzones[choice]
        return true
    end
end

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



buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end


env.info("Mission Setup : is completed!")

-- last working durrning test mission

-- the one with Flagcheck.