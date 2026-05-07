env.info("ZoneSetup: is loading.")

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

-----------------------------begin upgrade (this is what determines what spawns at each target location)---------------------------
upgrades = {
	airfieldStart = {
		blue = {'blueArmor', 'bluePD1', 'bluePATRIOT'},
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
	EWRMantisNet = {
		blue = {},
		red = {'Red EWR Camp Bastion Fixed', 'Red EWR Nimroz Fixed', 'Red EWR Jamsheed Fixed', 'Red EWR Chaghcharan Fixed', 'Red EWR Bagram Fixed','Red EWR Sharana Fixed','Red EWR Farah Fixed'}
	},
    convoy = {
        blue = { "blueInfantry" },
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group 2", "Red SAM SHORAD SA-19", "Red SAM SHORAD SA-19","Red Armour Group", "Red SAM SHORAD SA-8" }
    },
	samfixedalpha = {
		blue = {},
		red = { 'Red Armour Group', 'Red SAM SA-6', 'Red Armour Group 2', 'Red SAM SHORAD SA-19', 'Red SAM SHORAD Pantsir S1',  'Red SAM SHORAD SA-15', 'Red SAM SA-10'}
	},
	samfixedbravo = {
		blue = {},
		red = { 'Red Armour Group', 'Red SAM SA-6', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD SA-15', 'Red SAM SA-10' }
	},
	samfixedcharlie = {
		blue = {},
		red = { 'Red Armour Group', 'Red SAM SA-6', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD SA-15', 'Red SAM SHORAD SA-15', 'Red SAM SA-10' }
	},
	samfixeddelta = {
		blue = {},
		red = { 'Red Armour Group', 'Red SAM SA-6', 'Red Armour Group 2',  'Red SAM SHORAD SA-15', 'Red SAM SHORAD Pantsir S1',  'Red SAM SHORAD SA-15',  'Red SAM SA-10' }
	},	
	samjamsheed = {
		blue = {},
		red = { 'Red SAM SA15-Jamsheed IsNotShown-1', 'Red SAM SA-6 Jamsheed IsNotKnown', 'Red SAM SA-6 Jamsheed IsNotShown-2',  'Red SAM SA-2 Jamsheed IsNotShown', 'Red SAM SA-10 Fixed Jamsheed IsNotShown-1',  'Red SAM SA-18 Jamsheed IsNotShown-1',  'Red SAM SA-18 Jamsheed IsNotShown-2', 'Red SAM SA-18 Jamsheed IsNotShown-3', 'Red SAM SA-18 Jamsheed IsNotShown-4', 'Red SAM SA-18 Jamsheed IsNotShown-5','Red SAM SA-18 Jamsheed IsNotShown-6', 'Red SAM AAA Jamsheed IsNotShown', 'Red SAM AAA Jamsheed IsNotKnown-2' }
	},	
}

------------------------------------end upgrades section------------------------------------------
--------------------------------begin flavor section (this is what gives a hint or description of the zone to the player)-----------------------------------
flavor = {
    kandahar           	  = L10N:Format("AF_FLAVOR_KANDAHAR", 1),
    alpha              	  = L10N:Format("AF_FLAVOR_ALPHA", 2),
    bost               	  = L10N:Format("AF_FLAVOR_BOST", 3),
    campbastion        	  = L10N:Format("AF_FLAVOR_CAMP_BASTION", 4),
    dwyer              	  = L10N:Format("AF_FLAVOR_DWYER", 5),
    nimroz             	  = L10N:Format("AF_FLAVOR_NIMROZ", 6),
    farah              	  = L10N:Format("AF_FLAVOR_FARAH", 7),
    shindand           	  = L10N:Format("AF_FLAVOR_SHINDAND", 8),
    herat              	  = L10N:Format("AF_FLAVOR_HERAT", 9),
    qalainaw           	  = L10N:Format("AF_FLAVOR_QALA_I_NAW", 10),
    maymanazahiraddin  	  = L10N:Format("AF_FLAVOR_MAYMANA_ZAHIRADDIN", 11),
    chaghcharan        	  = L10N:Format("AF_FLAVOR_CHAGHCHARAN", 12),
    bamyan             	  = L10N:Format("AF_FLAVOR_BAMYAN", 13),
    bagram             	  = L10N:Format("AF_FLAVOR_BAGRAM", 14),
    kabul              	  = L10N:Format("AF_FLAVOR_KABUL", 15),
    checkpointkabulw   	  = L10N:Format("AF_FLAVOR_CHECKPOINT_KABUL_W", 16),
    kabulsouth         	  = L10N:Format("AF_FLAVOR_CHECKPOINT_KABUL_S", 17),
    checkpointkabule   	  = L10N:Format("AF_FLAVOR_CHECKPOINT_KABUL_E", 18),
    fobkunar           	  = L10N:Format("AF_FLAVOR_FOB_KUNAR", 19),
    jalalabad          	  = L10N:Format("AF_FLAVOR_JALALABAD", 20),
    gardez             	  = L10N:Format("AF_FLAVOR_GARDEZ", 21),
    delta              	  = L10N:Format("AF_FLAVOR_CHECKPOINT_DELTA", 22),
    ghazniheliport     	  = L10N:Format("AF_FLAVOR_GHAZNI_HELIPORT", 23),
    sharana            	  = L10N:Format("AF_FLAVOR_SHARANA", 24),
    charlie            	  = L10N:Format("AF_FLAVOR_CHECKPOINT_CHARLIE", 25),
    bravo              	  = L10N:Format("AF_FLAVOR_CHECKPOINT_BRAVO", 26),
    tarinkot           	  = L10N:Format("AF_FLAVOR_TARINKOT", 27),
    insurgentqalat        = L10N:Get("AF_FLAVOR_INSURGENT_QALAT"),
    insurgentdelaram      = L10N:Get("AF_FLAVOR_INSURGENT_DELARAM"),
    insurgentchimozay     = L10N:Get("AF_FLAVOR_INSURGENT_CHIMOZAY"),
    insurgentnili         = L10N:Get("AF_FLAVOR_INSURGENT_NILI"),
    insurgentalpha        = L10N:Get("AF_FLAVOR_INSURGENT_ALPHA"),
    insurgentqarabagh     = L10N:Get("AF_FLAVOR_INSURGENT_QARABAGH"),
    insurgentasadabad     = L10N:Get("AF_FLAVOR_INSURGENT_ASADABAD"),
    insurgentkunar        = L10N:Get("AF_FLAVOR_INSURGENT_KUNAR"),
    insurgentsarobi       = L10N:Get("AF_FLAVOR_INSURGENT_SAROBI"),
    insurgentmountain     = L10N:Get("AF_FLAVOR_INSURGENT_MOUNTAIN"),
	faridbasharat   	  = L10N:Get("AF_FLAVOR_FOB_FARID_BASHARAT"),
	ahmadshahmassoud 	  = L10N:Get("AF_FLAVOR_FOB_AHMAD_SHAH_MASSOUD"),
	ismailkhan    		  = L10N:Get("AF_FLAVOR_FOB_ISMAIL_KHAN"),
	hamidkarzai   		  = L10N:Get("AF_FLAVOR_FOB_HAMID_KARZAI"),
	javidbasharat 		  = L10N:Get("AF_FLAVOR_FOB_JAVID_BASHARAT"),
	shank         		  = L10N:Get("AF_FLAVOR_FOB_SHANK"),
	lagman        		  = L10N:Get("AF_FLAVOR_FOB_LAGMAN"),
	bostick       		  = L10N:Get("AF_FLAVOR_FOB_BOSTICK"),
	delaram        		  = L10N:Get("AF_FLAVOR_FOB_DELARAM"),
	jamsheed       		  = L10N:Get("AF_FLAVOR_FOB_JAMSHEED"),
	fenty        		  = L10N:Get("AF_FLAVOR_FOB_FENTY"),
	samalpha			  = L10N:Get("AF_FLAVOR_SAM_ALPHA"),
	sambravo			  = L10N:Get("AF_FLAVOR_SAM_BRAVO"),
	samcharlie			  = L10N:Get("AF_FLAVOR_SAM_CHARLIE"),
	--samdelta			  = L10N:Get("AF_FLAVOR_SAM_DELTA"),
	samjamsheed			  = L10N:Get("AF_FLAVOR_SAM_JAMSHEED"),
	urgoon				  = L10N:Get("AF_FLAVOR_URGOON"),
	khost				  = L10N:Get("AF_FLAVOR_KHOST"),
	hidden				  = L10N:Get("AF_FLAVOR_HIDDEN"),

}
-----------------------------------end flavor section------------------------------------------
---------------------------begin waypoint list (this is what gives each waypoint a number on the map)-------------------------
WaypointList = {
    Kandahar                   		   = ' (1)',
    ["Checkpoint Alpha"]       		   = ' (2)',
    Bost                       		   = ' (3)',
    ["Camp Bastion"]           		   = ' (4)',
    Dwyer                      		   = ' (5)',
    Nimroz                     		   = ' (6)',
    Farah                      		   = ' (7)',
    Shindand                   		   = ' (8)',
    Herat                      		   = ' (9)',
    ["Qala i Naw"]                     = ' (10)',
    ["Maymana Zahiraddin Faryabi"]     = ' (11)',
    Chaghcharan                 	   = ' (12)',
    Bamyan                      	   = ' (13)',
    Bagram                      	   = ' (14)',
    Kabul                       	   = ' (15)',
    ["Checkpoint Kabul W"]      	   = ' (16)',
    ["Checkpoint Kabul S"]  	       = ' (17)',
    ["Checkpoint Kabul E"]      	   = ' (18)',
    ["FOB Kunar"]               	   = ' (19)',
    Jalalabad                   	   = ' (20)',
    Gardez                      	   = ' (21)',
    ["Checkpoint Delta"]        	   = ' (22)',
    ["Ghazni Heliport"]         	   = ' (23)',
    Sharana                     	   = ' (24)',
    ["Checkpoint Charlie"]      	   = ' (25)',
    ["Checkpoint Bravo"]        	   = ' (26)',
    Tarinkot                    	   = ' (27)',
}
-----------------end waypoint number section------------------------------------------

---------------------------begin coldwar swap section---------------------------------
FootholdSaveBaseName = (Era == 'Coldwar') and 'foothold_afghanistan_Coldwar' or 'foothold_afghanistan'

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
	['Red SAM SHORAD Tor M2'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
	['Red SAM SHORAD Pantsir S1'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9', 'Red SAM SHORAD SA-15'} },
}
----------------------end coldwar swap section-----------------------


supplyZones = {
	'Bamyan',
    'Bagram',
    'Kabul',
    'Kandahar',
    'Herat',
    'Shindand',
    'Farah',
    'Nimroz',
    'Bost',
    'Camp Bastion',
    'Dwyer',
    'Gardez',
    'Jalalabad',
    'Ghazni Heliport',
    'Sharana',
    'Tarinkot',
    'Qala i Naw',
    'Maymana Zahiraddin Faryabi',
    'Chaghcharan',
    'FOB Kunar',
    'Checkpoint Alpha',
    'Checkpoint Bravo',
    'Checkpoint Charlie',
    'Checkpoint Delta',
    'Checkpoint Kabul W',
    'Checkpoint Kabul S',
    'Checkpoint Kabul E',
    'FOB-Jamsheed',  
    'FOB-Bostick',  
    'FOB-Lagman',  
    'FOB-Shank',  
    'FOB-Javid Basharat',  
    'FOB-Hamid Karzai',  
    'FOB-Ismail Khan',  
	'FOB-Ahmad Shah Massoud',  
    'FOB-Farid Basharat',  
	'FOB-Delaram',  
	'FOB-Fenty',
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
------------------------begin coldwar swaps (this section swaps fixed assets for coldwar)-----------------------------
if Era == 'Coldwar' then
	deepSwap(upgrades,cwSwap)
end

local SamSwap = {
	['Red SAM SA-10'] = { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },
	['Red SAM SA-11'] = { mode='random', list={'Red SAM SA-2', 'Red SAM SA-3', 'Red SAM SA-6'} },
	['Red SAM SA-10 Fixed Jamsheed IsNotShown-1'] = 'Red SAM SA-2 Fixed Jamsheed IsNotShown-1',
	
}

local SamSwapNoTorM2AndPantsir = {
	['Red SAM SHORAD Pantsir S1'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
	['Red SAM SHORAD Tor M2'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
}

local SamSwapNoSA15 = {
	['Red SAM SHORAD SA-15'] = { mode='random', list={'Red SAM SHORAD SA-19', 'Red SAM SHORAD SA-8', 'Red SAM SHORAD SA-13', 'Red SAM SHORAD SA-9'} },
}
----------------------------end coldwar fixed swaps -----------------------------------------
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
	samspecial = { sam = 2, shorad = {1,3}, aaa = {1,2}, ground = 0, armor = 0, arty = 0, total = {6,7} },
	insurgent = { sam = 0, shorad = {1,3}, aaa = {1,2}, ground = {1,2}, armor = 0, arty = 0, total = {6,7} },
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
    insurgent = { sam = 0, shorad = {1,3}, aaa = {1,2}, ground = {1,2}, armor = 0, arty = 0, total = {6,7} },
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
-----------------------------begin zone definitions(this is where a side is chosen and what flavor and upgrades each zone will have etc etc)-------------------------
zones = {
    kandahar            = ZoneCommander:new({zone='Kandahar',                    side=StartNormal and 2 or 1, size='big', level=25, upgrades=upgrades.airfieldStart,    	crates={},flavorText=flavor.kandahar,income = 0.75, redIncomeOnly=true}),
    alpha               = ZoneCommander:new({zone='Checkpoint Alpha',            side=StartNormal and 2 or 1, size='small', level=25, upgrades=upgrades.farp,             	crates={},flavorText=flavor.alpha}),
    bost                = ZoneCommander:new({zone='Bost',                        side=1, size='mediumbig', level=25, upgrades=upgrades.airfield2,          crates={},flavorText=flavor.bost}),
    campbastion         = ZoneCommander:new({zone='Camp Bastion',                side=1, size='big', level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.campbastion,income = 0.75, redIncomeOnly=true}),
    dwyer               = ZoneCommander:new({zone='Dwyer',                       side=1, size='big', level=25, upgrades=upgrades.airfield3,        	crates={},flavorText=flavor.dwyer}),
    bravo               = ZoneCommander:new({zone='Checkpoint Bravo',            side=1, size='small', level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.bravo}),
    tarinkot            = ZoneCommander:new({zone='Tarinkot',                    side=1, size='big', level=25, upgrades=upgrades.airfield3,        	crates={},flavorText=flavor.tarinkot,income = 0.2}),
    insurgentqalat      = ZoneCommander:new({zone='Insurgent Base Qalat',        side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints6, 	    crates={},flavorText=flavor.insurgentqalat}),
    insurgentdelaram    = ZoneCommander:new({zone='Insurgent Base Delaram',      side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints1,     	crates={},flavorText=flavor.insurgentdelaram}),
    farah               = ZoneCommander:new({zone='Farah',                       side=1, size='mediumbig', level=25, upgrades=upgrades.airfield2,        	crates={},flavorText=flavor.farah}),
    insurgentchimozay   = ZoneCommander:new({zone='Insurgent Base Chimozay',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints5,     	crates={},flavorText=flavor.insurgentchimozay}),
    insurgentnili       = ZoneCommander:new({zone='Insurgent Base Nili',         side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints2,     	crates={},flavorText=flavor.insurgentnili}),
    insurgentalpha      = ZoneCommander:new({zone='Insurgent Base Alpha',        side=1, size='insurgent', level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.insurgentalpha}),
    jamsheed            = ZoneCommander:new({zone='FOB-Jamsheed',                side=0, size='bignosam', level=25, upgrades=upgrades.farp2,            	crates={},flavorText=flavor.jamsheed,NeutralAtStart=true}),
    faridbasharat       = ZoneCommander:new({zone='FOB-Farid Basharat',          side=0, size='small', level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.faridbasharat,NeutralAtStart=true}),      
    ahmadshahmassoud    = ZoneCommander:new({zone='FOB-Ahmad Shah Massoud',      side=0, size='bignosam', level=25, upgrades=upgrades.farp2,            	crates={},flavorText=flavor.ahmadshahmassoud,NeutralAtStart=true}),
    ismailkhan          = ZoneCommander:new({zone='FOB-Ismail Khan',             side=0, size='bignosam', level=25, upgrades=upgrades.farp3,            	crates={},flavorText=flavor.ismailkhan,NeutralAtStart=true}),	
    hamidkarzai         = ZoneCommander:new({zone='FOB-Hamid Karzai',            side=0, size='bignosam', level=25, upgrades=upgrades.farp2,            	crates={},flavorText=flavor.hamidkarzai,NeutralAtStart=true}),	
    javidbasharat       = ZoneCommander:new({zone='FOB-Javid Basharat',          side=0, size='bignosam', level=25, upgrades=upgrades.farp3,             crates={},flavorText=flavor.javidbasharat,NeutralAtStart=true}),
    shank               = ZoneCommander:new({zone='FOB-Shank',                   side=0, size='small', level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.shank,NeutralAtStart=true}),
    lagman              = ZoneCommander:new({zone='FOB-Lagman',                  side=0, size='small', level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.lagman,NeutralAtStart=true}),
    bostick             = ZoneCommander:new({zone='FOB-Bostick',                 side=0, size='bignosam', level=25, upgrades=upgrades.farp2,            	crates={},flavorText=flavor.bostick,NeutralAtStart=true}),
    delaram             = ZoneCommander:new({zone='FOB-Delaram',                 side=0, size='bignosam', level=25, upgrades=upgrades.farp3,            	crates={},flavorText=flavor.delaram,NeutralAtStart=true}),	
    fenty               = ZoneCommander:new({zone='FOB-Fenty',                   side=0, size='bignosam', level=25, upgrades=upgrades.farp2,            	crates={},flavorText=flavor.fenty,NeutralAtStart=true}),		
	khost               = ZoneCommander:new({zone='Khost',                       side=0, size='small', level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.khost,NeutralAtStart=true, income = 0.2}),	
	urgoon              = ZoneCommander:new({zone='Urgoon Heliport',             side=0, size='small', level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.urgoon,NeutralAtStart=true}),		
    charlie             = ZoneCommander:new({zone='Checkpoint Charlie',          side=1, size='bignosam', level=25, upgrades=upgrades.farp2,            	crates={},flavorText=flavor.charlie}),
    insurgentqarabagh   = ZoneCommander:new({zone='Insurgent Qarabagh',          side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints2,     	crates={},flavorText=flavor.insurgentqarabagh}),
    ghazniheliport      = ZoneCommander:new({zone='Ghazni Heliport',             side=1, size='big', level=25, upgrades=upgrades.airfield,          crates={},flavorText=flavor.ghazniheliport}),
    sharana             = ZoneCommander:new({zone='Sharana',                     side=1, size='big', level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.sharana}),
    gardez              = ZoneCommander:new({zone='Gardez',                      side=1, size='mediumbig', level=25, upgrades=upgrades.airfield2,        	crates={},flavorText=flavor.gardez}),
    delta               = ZoneCommander:new({zone='Checkpoint Delta',            side=1, size='small', level=25, upgrades=upgrades.checkpoints4,      crates={},flavorText=flavor.delta}),
    kabulsouth          = ZoneCommander:new({zone='Checkpoint Kabul S',          side=1, size='small', level=25, upgrades=upgrades.checkpoints3,      crates={},flavorText=flavor.kabulsouth}),
    insurgentasadabad   = ZoneCommander:new({zone='Insurgent Base Asadabad',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints5,      crates={},flavorText=flavor.insurgentasadabad}),
    insurgentkunar      = ZoneCommander:new({zone='Insurgent Base Kunar',        side=1, size='insurgent', level=25, upgrades=upgrades.farp,        		crates={},flavorText=flavor.insurgentkunar}),
    fobkunar            = ZoneCommander:new({zone='FOB Kunar',                   side=1, size='bignosam', level=25, upgrades=upgrades.farp2,        		crates={},flavorText=flavor.fobkunar}),
    jalalabad           = ZoneCommander:new({zone='Jalalabad',                   side=1, size='big', level=25, upgrades=upgrades.airfield3,        	crates={},flavorText=flavor.jalalabad, income = 0.75, redIncomeOnly=true}),
    insurgentsarobi     = ZoneCommander:new({zone='Insurgent Base Sarobi',       side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints6,     	crates={},flavorText=flavor.insurgentsarobi}),
    insurgentmountain   = ZoneCommander:new({zone='Insurgent Base Mountain',     side=1, size='insurgent', level=25, upgrades=upgrades.checkpoints2,      crates={},flavorText=flavor.insurgentmountain}),
    checkpointkabule    = ZoneCommander:new({zone='Checkpoint Kabul E',          side=1, size='small', level=25, upgrades=upgrades.checkpoints2,      crates={},flavorText=flavor.checkpointkabule}),
    kabul               = ZoneCommander:new({zone='Kabul',                       side=1, size='big', level=25, upgrades=upgrades.airfield3,        	crates={},flavorText=flavor.kabul}),
    checkpointkabulw    = ZoneCommander:new({zone='Checkpoint Kabul W',          side=1, size='small', level=25, upgrades=upgrades.checkpoints1,      crates={},flavorText=flavor.checkpointkabulw}),
	nimroz              = ZoneCommander:new({zone='Nimroz',                      side=1, size='mediumbig', level=25, upgrades=upgrades.airfield2,         crates={},flavorText=flavor.nimroz}),
    shindand            = ZoneCommander:new({zone='Shindand',                    side=1, size='big', level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.shindand}),
    herat               = ZoneCommander:new({zone='Herat',                       side=1, size='mediumbig', level=25, upgrades=upgrades.airfield2,        	crates={},flavorText=flavor.herat}),
    bamyan              = ZoneCommander:new({zone='Bamyan',                      side=1, size='big', level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.bamyan}),
    chaghcharan         = ZoneCommander:new({zone='Chaghcharan',                 side=1, size='big', level=25, upgrades=upgrades.airfield3,        	crates={},flavorText=flavor.chaghcharan}),
    qalainaw            = ZoneCommander:new({zone='Qala i Naw',                  side=1, size='mediumbig', level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.qalainaw}),
    maymanazahiraddin   = ZoneCommander:new({zone='Maymana Zahiraddin Faryabi',  side=1, size='mediumbig', level=25, upgrades=upgrades.airfield2,        	crates={},flavorText=flavor.maymanazahiraddin}),
	bagram				= ZoneCommander:new({zone='Bagram',  					 side=StartNormal and 1 or 2, size='mediumbig', level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.bagram}),
 	hidden1				= ZoneCommander:new({zone='Hidden',        			     side=1, level=25, upgrades=upgrades.HiddenSam1,        crates={},flavorText=flavor.hidden}),
	hidden2				= ZoneCommander:new({zone='Hidden2',        			 side=1, level=25, upgrades=upgrades.HiddenSam2,        crates={},flavorText=flavor.hidden}),
	hidden3				= ZoneCommander:new({zone='Hidden3',        			 side=1, level=25, upgrades=upgrades.HiddenSam3,        crates={},flavorText=flavor.hidden}),
	hidden4				= ZoneCommander:new({zone='Hidden4',        			 side=1, level=25, upgrades=upgrades.HiddenSam4,        crates={},flavorText=flavor.hidden}),
	hiddenewr			= ZoneCommander:new({zone='HiddenEWR',        			 side=1, level=25, upgrades=upgrades.EWRMantisNet,      crates={},flavorText=flavor.hidden}),
	samalpha			= ZoneCommander:new({zone='SAM Site Alpha',        		 side=1, size='sam2', level=25, upgrades=upgrades.samfixedalpha,     crates={},flavorText=flavor.samalpha}),
	sambravo			= ZoneCommander:new({zone='SAM Site Bravo',        		 side=1, size='sam2', level=25, upgrades=upgrades.samfixedbravo,     crates={},flavorText=flavor.sambravo}),
	samcharlie			= ZoneCommander:new({zone='SAM Site Charlie',        	 side=1, size='sam2', level=25, upgrades=upgrades.samfixedcharlie,   crates={},flavorText=flavor.samcharlie}),
	--samdelta			= ZoneCommander:new({zone='SAM Site Delta',        		 side=1, level=25, upgrades=upgrades.samfixeddelta,     crates={},flavorText=flavor.samdelta}),
	samjamsheed			= ZoneCommander:new({zone='Jamsheed SAM Site',        	 side=1, size='samspecial', level=25, upgrades=upgrades.samjamsheed,     	crates={},flavorText=flavor.samjamsheed}),
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

zones.insurgentkunar:addGroups({
    GroupCommander:new({name='insurgentkunar-attack-FOBKunar', mission='attack', template='InsurgentConvoy', targetzone='FOB Kunar',type='surface'}),
})

zones.insurgentchimozay:addGroups({
    GroupCommander:new({name='insurgentchimozay-attack-Farah', mission='attack', template='InsurgentConvoy', targetzone='Farah',type='surface'}),
})

-- Insurgent Base Nili (insurgent) -> connects to: Tarinkot
zones.insurgentnili:addGroups({
    GroupCommander:new({name='insurgentnili-attack-Tarinkot', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Tarinkot'}),
})

-- Insurgent Base Alpha (insurgent) -> connects to: Tarinkot
zones.insurgentalpha:addGroups({
    GroupCommander:new({name='insurgentalpha-attack-Tarinkot', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Tarinkot'}),
})

-- FOB Kunar (FOB) -> connects to: Jalalabad
zones.fobkunar:addGroups({
    GroupCommander:new({name='fobkunar-attack-Jalalabad', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Jalalabad'}),
    GroupCommander:new({name='fobkunar-supply-Jalalabad-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Jalalabad'}),
})

-- Checkpoint Kabul E (Checkpoint) -> connects to: Kabul, Checkpoint Kabul S
zones.checkpointkabule:addGroups({
    GroupCommander:new({name='checkpointkabule-attack-Kabul-Cas', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Kabul'}),
    GroupCommander:new({name='checkpointkabule-supply-CheckpointKabulSouth-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Kabul S'}),

    -- Surface attack routes
    GroupCommander:new({name='CheckpointKabulE-attack-Kabul', mission='attack', targetzone='Kabul', type='surface', SetActiveMission = true}),
})

-- Checkpoint Kabul W (Checkpoint) -> connects to: Kabul, Checkpoint Delta
zones.checkpointkabulw:addGroups({
    GroupCommander:new({name='checkpointkabulw-attack-CheckpointDelta', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Checkpoint Delta'}),
    GroupCommander:new({name='checkpointkabulw-supply-Kabul-helo',      mission='supply', template='HeloSupplyTemplate', targetzone='Kabul'}),
    GroupCommander:new({name='checkpointkabulw-supply-CheckpointDelta-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Delta'}),

    -- Surface attack routes
    GroupCommander:new({name='CheckpointKabulW-attack-Kabul', mission='attack',template='AttackConvoy', targetzone='Kabul', type='surface'}),
})

-- Checkpoint Kabul S (Checkpoint) -> connects to: Kabul, Checkpoint Kabul E, Checkpoint Delta
zones.kabulsouth:addGroups({
    GroupCommander:new({name='kabulsouth-attack-Kabul',            mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Kabul'}),
    GroupCommander:new({name='kabulsouth-attack-CheckpointKabulE', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Checkpoint Kabul E'}),
    GroupCommander:new({name='kabulsouth-attack-CheckpointDelta',  mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Checkpoint Delta'}),

    GroupCommander:new({name='kabulsouth-supply-Kabul-helo',            mission='supply', template='HeloSupplyTemplate', targetzone='Kabul'}),
    GroupCommander:new({name='kabulsouth-supply-CheckpointKabulE-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Kabul E'}),
    GroupCommander:new({name='kabulsouth-supply-CheckpointDelta-helo',  mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Delta'}),

    -- Surface attack routes
    GroupCommander:new({name='CheckpointKabulS-attack-Kabul',  mission='attack',template='AttackConvoy', targetzone='Kabul',  type='surface'}),
})

-- Checkpoint Delta (Checkpoint) -> connects to: Ghazni Heliport, Checkpoint Kabul S, Checkpoint Kabul W, Kabul
zones.delta:addGroups({
    GroupCommander:new({name='delta-attack-Ghazni Heliport',       mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Ghazni Heliport'}),
    GroupCommander:new({name='delta-attack-CheckpointKabulSouth',  mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Checkpoint Kabul S'}),
    GroupCommander:new({name='delta-attack-CheckpointKabulW',      mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Checkpoint Kabul W'}),
    GroupCommander:new({name='delta-attack-Kabul',                 mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Kabul'}),

    GroupCommander:new({name='delta-supply-GhazniHeliport-helo',         mission='supply', template='HeloSupplyTemplate', targetzone='Ghazni Heliport'}),
    GroupCommander:new({name='delta-supply-CheckpointKabulSouth-helo',   mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Kabul S'}),
    GroupCommander:new({name='delta-supply-CheckpointKabulW-helo',       mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Kabul W'}),
    GroupCommander:new({name='delta-supply-Kabul-helo',                  mission='supply', template='HeloSupplyTemplate', targetzone='Kabul'}),

    -- Surface attack routes
    GroupCommander:new({name='CheckpointDelta-attack-GhazniHeliport', mission='attack', targetzone='Ghazni Heliport', type='surface', SetActiveMission = true}),
})

-- Checkpoint Charlie (Checkpoint) -> connects to: Tarinkot, Checkpoint Bravo, Sharana, Ghazni Heliport
zones.charlie:addGroups({

    GroupCommander:new({name='charlie-supply-Tarinkot-helo',        mission='supply', template='HeloSupplyTemplate', targetzone='Tarinkot'}),
    GroupCommander:new({name='charlie-supply-CheckpointBravo-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Bravo'}),
    GroupCommander:new({name='charlie-supply-Sharana-helo',         mission='supply', template='HeloSupplyTemplate', targetzone='Sharana'}),
    GroupCommander:new({name='charlie-supply-GhazniHeliport-helo',  mission='supply', template='HeloSupplyTemplate', targetzone='Ghazni Heliport'}),

    -- Surface attack routes
    GroupCommander:new({name='CheckpointCharlie-attack-FOB-Bostick', mission='attack', targetzone='FOB-Bostick', type='surface', SetActiveMission = true}),
})

-- Checkpoint Bravo (Checkpoint) -> connects to: Tarinkot, Kandahar, Checkpoint Charlie, Insurgent Base Qalat
zones.bravo:addGroups({
    GroupCommander:new({name='bravo-attack-Tarinkot',           mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Tarinkot'}),
    GroupCommander:new({name='bravo-attack-Kandahar',           mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Kandahar'}),
    GroupCommander:new({name='bravo-attack-CheckpointCharlie',  mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Checkpoint Charlie'}),
    GroupCommander:new({name='bravo-attack-InsurgentBaseQalat', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Insurgent Base Qalat'}),

    GroupCommander:new({name='bravo-supply-Tarinkot-helo',          mission='supply', template='HeloSupplyTemplate', targetzone='Tarinkot'}),
    GroupCommander:new({name='bravo-supply-Kandahar-helo',          mission='supply', template='HeloSupplyTemplate', targetzone='Kandahar'}),
    GroupCommander:new({name='bravo-supply-CheckpointCharlie-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Charlie'}),
    GroupCommander:new({name='bravo-supply-InsurgentBaseQalat-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Insurgent Base Qalat'}),

    -- Surface attack routes
    GroupCommander:new({name='CheckpointBravo-attack-Tarinkot', mission='attack', targetzone='Tarinkot', type='surface', SetActiveMission = true}),
})

-- Checkpoint Alpha (Checkpoint) -> connects to: Camp Bastion, Bost, Tarinkot, Kandahar
zones.alpha:addGroups({
    GroupCommander:new({name='alpha-attack-CampBastion', mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Camp Bastion'}),
    GroupCommander:new({name='alpha-attack-Bost',        mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Bost'}),
    GroupCommander:new({name='alpha-attack-Tarinkot',    mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Tarinkot'}),
    GroupCommander:new({name='alpha-attack-Kandahar',    mission='attack', template='CasHeloTemplate', MissionType='CAS', targetzone='Kandahar'}),

    GroupCommander:new({name='alpha-supply-CampBastion-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Camp Bastion'}),
    GroupCommander:new({name='alpha-supply-Bost-helo',        mission='supply', template='HeloSupplyTemplate', targetzone='Bost'}),
    GroupCommander:new({name='alpha-supply-Tarinkot-helo',    mission='supply', template='HeloSupplyTemplate', targetzone='Tarinkot'}),
    GroupCommander:new({name='alpha-supply-Kandahar-helo',    mission='supply', template='HeloSupplyTemplate', targetzone='Kandahar'}),
})

-- JALALABAD (airport) -> connects to: Checkpoint Kabul E, FOB Kunar, Gardez
zones.jalalabad:addGroups({
    GroupCommander:new({name='jalalabad-supply-CheckpointKabulE-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Kabul E'}),
    GroupCommander:new({name='jalalabad-supply-FOBKunar-helo',         mission='supply', template='HeloSupplyTemplate', targetzone='FOB Kunar'}),
    GroupCommander:new({name='jalalabad-supply-Gardez-helo',           mission='supply', template='HeloSupplyTemplate', targetzone='Gardez'}),

    GroupCommander:new({name='jalalabad-supply-Bagram-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Bagram'}),
    GroupCommander:new({name='jalalabad-supply-Kabul-plane',mission='supply', template='PlaneSupplyTemplate', targetzone='Kabul'}),
    GroupCommander:new({name='jalalabad-supply-Tarinkot-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Tarinkot'}),
    GroupCommander:new({name='jalalabad-supply-Maymana Zahiraddin Faryabi-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Maymana Zahiraddin Faryabi'}),

    GroupCommander:new({name='jalalabad-attack-CheckpointKabulE-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Kabul E', Altitude = CapAltitude()}),
    GroupCommander:new({name='jalalabad-attack-CheckpointKabulE-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Kabul E', Altitude = CasAltitude()}),
    GroupCommander:new({name='jalalabad-attack-CheckpointKabulE-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Kabul E', Altitude = SeadAltitude()}),
    GroupCommander:new({name='jalalabad-patrol-CheckpointKabulE-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Kabul E', Altitude = CapAltitude()}),

    GroupCommander:new({name='jalalabad-attack-FOBKunar-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='FOB Kunar', Altitude = CapAltitude()}),
    GroupCommander:new({name='jalalabad-attack-FOBKunar-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='FOB Kunar', Altitude = CasAltitude()}),
    GroupCommander:new({name='jalalabad-attack-FOBKunar-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='FOB Kunar', Altitude = SeadAltitude()}),
    GroupCommander:new({name='jalalabad-patrol-FOBKunar-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='FOB Kunar', Altitude = CapAltitude()}),

    GroupCommander:new({name='jalalabad-attack-Gardez-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Gardez', Altitude = CapAltitude()}),
    GroupCommander:new({name='jalalabad-attack-Gardez-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Gardez', Altitude = CasAltitude()}),
    GroupCommander:new({name='jalalabad-attack-Gardez-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Gardez', Altitude = SeadAltitude()}),
    GroupCommander:new({name='jalalabad-patrol-Gardez-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Gardez', Altitude = CapAltitude()}),
})

-- KABUL (airport) -> connects to: Checkpoint Kabul E, Checkpoint Kabul S, Checkpoint Kabul W, Checkpoint Delta, Bamyan, Bagram
zones.kabul:addGroups({
    GroupCommander:new({name='kabul-supply-CheckpointKabulE-helo',     mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Kabul E'}),
    GroupCommander:new({name='kabul-supply-CheckpointKabulSouth-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Kabul S'}),
    GroupCommander:new({name='kabul-supply-CheckpointKabulW-helo',     mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Kabul W'}),
    GroupCommander:new({name='kabul-supply-CheckpointDelta-helo',      mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Delta'}),

    GroupCommander:new({name='kabul-supply-Jalalabad-plane',                mission='supply', template='PlaneSupplyTemplate', targetzone='Jalalabad'}),
    GroupCommander:new({name='kabul-supply-Bamyan',                   mission='supply', template='HeloSupplyTemplate', targetzone='Bamyan'}),
    GroupCommander:new({name='kabul-supply-Gardez-plane',                   mission='supply', template='PlaneSupplyTemplate', targetzone='Gardez'}),
    GroupCommander:new({name='kabul-supply-Dwyer-plane',                    mission='supply', template='PlaneSupplyTemplate', targetzone='Dwyer'}),

    GroupCommander:new({name='kabul-attack-CheckpointKabulE-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Kabul E', Altitude = CapAltitude()}),
    GroupCommander:new({name='kabul-attack-CheckpointKabulE-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Kabul E', Altitude = CasAltitude()}),
    GroupCommander:new({name='kabul-attack-CheckpointKabulE-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Kabul E', Altitude = SeadAltitude()}),
    GroupCommander:new({name='kabul-patrol-CheckpointKabulE-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Kabul E', Altitude = CapAltitude()}),

    GroupCommander:new({name='kabul-attack-CheckpointKabulSouth-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Kabul S', Altitude = CapAltitude()}),
    GroupCommander:new({name='kabul-attack-CheckpointKabulSouth-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Kabul S', Altitude = CasAltitude()}),
    GroupCommander:new({name='kabul-attack-CheckpointKabulSouth-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Kabul S', Altitude = SeadAltitude()}),
    GroupCommander:new({name='kabul-patrol-CheckpointKabulSouth-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Kabul S', Altitude = CapAltitude()}),

    GroupCommander:new({name='kabul-attack-CheckpointKabulW-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Kabul W', Altitude = CapAltitude()}),
    GroupCommander:new({name='kabul-attack-CheckpointKabulW-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Kabul W', Altitude = CasAltitude()}),
    GroupCommander:new({name='kabul-attack-CheckpointKabulW-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Kabul W', Altitude = SeadAltitude()}),
    GroupCommander:new({name='kabul-patrol-CheckpointKabulW-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Kabul W', Altitude = CapAltitude()}),

    GroupCommander:new({name='kabul-attack-CheckpointDelta-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Delta', Altitude = CapAltitude()}),
    GroupCommander:new({name='kabul-attack-CheckpointDelta-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Delta', Altitude = CasAltitude()}),
    GroupCommander:new({name='kabul-attack-CheckpointDelta-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Delta', Altitude = SeadAltitude()}),
    GroupCommander:new({name='kabul-patrol-CheckpointDelta-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Delta', Altitude = CapAltitude()}),

    GroupCommander:new({name='kabul-attack-Bamyan-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bamyan', Altitude = CapAltitude()}),
    GroupCommander:new({name='kabul-attack-Bamyan-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Bamyan', Altitude = CasAltitude()}),
    GroupCommander:new({name='kabul-attack-Bamyan-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Bamyan', Altitude = SeadAltitude()}),
    GroupCommander:new({name='kabul-patrol-Bamyan-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bamyan', Altitude = CapAltitude()}),

    GroupCommander:new({name='kabul-attack-Bagram-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bagram', Altitude = CapAltitude()}),
    GroupCommander:new({name='kabul-attack-Bagram-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Bagram', Altitude = CasAltitude()}),
    GroupCommander:new({name='kabul-attack-Bagram-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Bagram', Altitude = SeadAltitude()}),
    GroupCommander:new({name='kabul-patrol-Bagram-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bagram', Altitude = CapAltitude()}),

    -- Surface attack routes
    GroupCommander:new({name='Kabul-attack-CheckpointKabulW', mission='attack',template='AttackConvoy', targetzone='Checkpoint Kabul W', type='surface'}),
    GroupCommander:new({name='Kabul-attack-CheckpointKabulS', mission='attack',template='AttackConvoy', targetzone='Checkpoint Kabul S', type='surface'}),
    GroupCommander:new({name='Kabul-attack-CheckpointKabulE', mission='attack',template='AttackConvoy', targetzone='Checkpoint Kabul E', type='surface'}),
})

-- GARDEZ (airport) -> connects to: Jalalabad, Checkpoint Kabul S, Sharana, Ghazni Heliport
zones.gardez:addGroups({
    GroupCommander:new({name='gardez-supply-CheckpointKabulSouth-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Kabul S'}),

   -- Surface attack routes
    GroupCommander:new({name='Gardez-Trapsetup-CheckPointDelta', mission='attack', targetzone='Checkpoint Delta', type='surface'}),
})

-- GHAZNI HELIPORT (airport) -> connects to: Checkpoint Charlie, Gardez, Checkpoint Delta, Sharana
zones.ghazniheliport:addGroups({
    GroupCommander:new({name='ghazniheliport-supply-CheckpointCharlie-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Charlie'}),
    GroupCommander:new({name='ghazniheliport-supply-Gardez-helo',            mission='supply', template='HeloSupplyTemplate', targetzone='Gardez'}),
    GroupCommander:new({name='ghazniheliport-supply-CheckpointDelta-helo',   mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Delta'}),
    GroupCommander:new({name='ghazniheliport-supply-Sharana-helo',           mission='supply', template='HeloSupplyTemplate', targetzone='Sharana'}),

    -- GroupCommander:new({name='ghazniheliport-attack-CheckpointCharlie-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Charlie', Altitude = CapAltitude()}),
    -- GroupCommander:new({name='ghazniheliport-attack-CheckpointCharlie-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Charlie', Altitude = CasAltitude()}),
    -- GroupCommander:new({name='ghazniheliport-attack-CheckpointCharlie-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Charlie', Altitude = SeadAltitude()}),
    -- GroupCommander:new({name='ghazniheliport-patrol-CheckpointCharlie-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Charlie', Altitude = CapAltitude()}),

    -- GroupCommander:new({name='ghazniheliport-attack-Gardez-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Gardez', Altitude = CapAltitude()}),
    -- GroupCommander:new({name='ghazniheliport-attack-Gardez-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Gardez', Altitude = CasAltitude()}),
    -- GroupCommander:new({name='ghazniheliport-attack-Gardez-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Gardez', Altitude = SeadAltitude()}),
    -- GroupCommander:new({name='ghazniheliport-patrol-Gardez-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Gardez', Altitude = CapAltitude()}),

    -- GroupCommander:new({name='ghazniheliport-attack-CheckpointDelta-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Delta', Altitude = CapAltitude()}),
    -- GroupCommander:new({name='ghazniheliport-attack-CheckpointDelta-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Delta', Altitude = CasAltitude()}),
    -- GroupCommander:new({name='ghazniheliport-attack-CheckpointDelta-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Delta', Altitude = SeadAltitude()}),
    -- GroupCommander:new({name='ghazniheliport-patrol-CheckpointDelta-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Delta', Altitude = CapAltitude()}),

    -- Surface attack routes
    GroupCommander:new({name='GhazniHeliport-attack-CheckpointDelta', mission='attack', targetzone='Checkpoint Delta', type='surface'}),
})

-- SHARANA (airport) -> connects to: Ghazni Heliport, Gardez, Checkpoint Charlie
zones.sharana:addGroups({
    GroupCommander:new({name='sharana-supply-GhazniHeliport-helo',    mission='supply', template='HeloSupplyTemplate', targetzone='Ghazni Heliport'}),
    GroupCommander:new({name='sharana-supply-Gardez-helo',            mission='supply', template='HeloSupplyTemplate', targetzone='Gardez'}),
    GroupCommander:new({name='sharana-supply-CheckpointCharlie-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Charlie'}),

    GroupCommander:new({name='sharana-attack-GhazniHeliport-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Ghazni Heliport', Altitude = CapAltitude()}),
    GroupCommander:new({name='sharana-attack-GhazniHeliport-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Ghazni Heliport', Altitude = CasAltitude()}),
    GroupCommander:new({name='sharana-attack-GhazniHeliport-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Ghazni Heliport', Altitude = SeadAltitude()}),
    GroupCommander:new({name='sharana-patrol-GhazniHeliport-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Ghazni Heliport', Altitude = CapAltitude()}),

    GroupCommander:new({name='sharana-attack-Gardez-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Gardez', Altitude = CapAltitude()}),
    GroupCommander:new({name='sharana-attack-Gardez-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Gardez', Altitude = CasAltitude()}),
    GroupCommander:new({name='sharana-attack-Gardez-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Gardez', Altitude = SeadAltitude()}),
    GroupCommander:new({name='sharana-patrol-Gardez-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Gardez', Altitude = CapAltitude()}),

    GroupCommander:new({name='sharana-attack-CheckpointCharlie-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Charlie', Altitude = CapAltitude()}),
    GroupCommander:new({name='sharana-attack-CheckpointCharlie-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Charlie', Altitude = CasAltitude()}),
    GroupCommander:new({name='sharana-attack-CheckpointCharlie-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Charlie', Altitude = SeadAltitude()}),
    GroupCommander:new({name='sharana-patrol-CheckpointCharlie-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Charlie', Altitude = CapAltitude()}),

    -- Surface attack routes
    GroupCommander:new({name='Sharana-attack-FOB-Bostick',     mission='attack', targetzone='FOB-Bostick',     type='surface'}),
    GroupCommander:new({name='Sharana-attack-Ghazni Heliport', mission='attack',template='AttackConvoy', targetzone='Ghazni Heliport', type='surface'}),
})

-- TARINKOT (airport) -> connects to: Checkpoint Charlie, Checkpoint Bravo, Kandahar, Checkpoint Alpha
zones.tarinkot:addGroups({
    GroupCommander:new({name='tarinkot-supply-CheckpointCharlie-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Charlie'}),
    GroupCommander:new({name='tarinkot-supply-CheckpointBravo-helo',   mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Bravo'}),
    GroupCommander:new({name='tarinkot-supply-CheckpointAlpha-helo',   mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Alpha'}),

    -- Plane supply routes (allowed plane-source)
    GroupCommander:new({name='tarinkot-supply-Kandahar-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Kandahar'}),
    GroupCommander:new({name='tarinkot-supply-Camp Bastion-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Camp Bastion'}),

    GroupCommander:new({name='tarinkot-attack-CheckpointCharlie-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Charlie', Altitude = CapAltitude()}),
    GroupCommander:new({name='tarinkot-attack-CheckpointCharlie-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Charlie', Altitude = CasAltitude()}),
    GroupCommander:new({name='tarinkot-attack-CheckpointCharlie-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Charlie', Altitude = SeadAltitude()}),
    GroupCommander:new({name='tarinkot-patrol-CheckpointCharlie-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Charlie', Altitude = CapAltitude()}),

    GroupCommander:new({name='tarinkot-attack-CheckpointBravo-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Bravo', Altitude = CapAltitude()}),
    GroupCommander:new({name='tarinkot-attack-CheckpointBravo-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Bravo', Altitude = CasAltitude()}),
    GroupCommander:new({name='tarinkot-attack-CheckpointBravo-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Bravo', Altitude = SeadAltitude()}),
    GroupCommander:new({name='tarinkot-patrol-CheckpointBravo-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Bravo', Altitude = CapAltitude()}),

    GroupCommander:new({name='tarinkot-attack-Kandahar-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Kandahar', Altitude = CapAltitude()}),
    GroupCommander:new({name='tarinkot-attack-Kandahar-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Kandahar', Altitude = CasAltitude()}),
    GroupCommander:new({name='tarinkot-attack-Kandahar-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Kandahar', Altitude = SeadAltitude()}),
    GroupCommander:new({name='tarinkot-patrol-Kandahar-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Kandahar', Altitude = CapAltitude()}),

    GroupCommander:new({name='tarinkot-attack-CheckpointAlpha-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Alpha', Altitude = CapAltitude()}),
    GroupCommander:new({name='tarinkot-attack-CheckpointAlpha-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Alpha', Altitude = CasAltitude()}),
    GroupCommander:new({name='tarinkot-attack-CheckpointAlpha-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Alpha', Altitude = SeadAltitude()}),
})

-- BOST (airport) -> connects to: Dwyer, Camp Bastion, Checkpoint Alpha
zones.bost:addGroups({
    GroupCommander:new({name='bost-supply-Dwyer-helo',           mission='supply', template='HeloSupplyTemplate', targetzone='Dwyer'}),
    GroupCommander:new({name='bost-supply-Camp Bastion-helo',    mission='supply', template='HeloSupplyTemplate', targetzone='Camp Bastion'}),
    GroupCommander:new({name='bost-supply-CheckpointAlpha-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Alpha'}),

    GroupCommander:new({name='bost-attack-Dwyer-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Dwyer', Altitude = CapAltitude()}),
    GroupCommander:new({name='bost-attack-Dwyer-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Dwyer', Altitude = CasAltitude()}),
    GroupCommander:new({name='bost-attack-Dwyer-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Dwyer', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bost-patrol-Dwyer-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Dwyer', Altitude = CapAltitude()}),

    GroupCommander:new({name='bost-attack-CampBastion-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Camp Bastion', Altitude = CapAltitude()}),
    GroupCommander:new({name='bost-attack-CampBastion-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Camp Bastion', Altitude = CasAltitude()}),
    GroupCommander:new({name='bost-attack-CampBastion-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Camp Bastion', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bost-patrol-CampBastion-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Camp Bastion', Altitude = CapAltitude()}),

    GroupCommander:new({name='bost-attack-CheckpointAlpha-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Alpha', Altitude = CapAltitude()}),
    GroupCommander:new({name='bost-attack-CheckpointAlpha-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Alpha', Altitude = CasAltitude()}),
    GroupCommander:new({name='bost-attack-CheckpointAlpha-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Alpha', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bost-patrol-CheckpointAlpha-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Alpha', Altitude = CapAltitude()}),

    -- Surface attack routes
    GroupCommander:new({name='Bost-attack-CampBastion',     mission='attack',template='AttackConvoy', targetzone='Camp Bastion', type='surface'}),
    GroupCommander:new({name='Bost-attack-CheckpointAlpha', mission='attack', targetzone='Checkpoint Alpha',template='AttackConvoy', type='surface'}),
    GroupCommander:new({name='Bost-attack-Dwyer',           mission='attack',template='AttackConvoy', targetzone='Dwyer', type='surface'}),
})

-- CAMP BASTION (airport) -> connects to: Checkpoint Alpha, Bost, Nimroz, Dwyer
zones.campbastion:addGroups({
    GroupCommander:new({name='campbastion-supply-Checkpoint Alpha-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Alpha'}),
    GroupCommander:new({name='campbastion-supply-Bost-helo',             mission='supply', template='HeloSupplyTemplate', targetzone='Bost'}),

    -- Plane supply routes (allowed plane-source)
    GroupCommander:new({name='campbastion-supply-Dwyer-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Dwyer'}),

    GroupCommander:new({name='campbastion-attack-CheckpointAlpha-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Alpha', Altitude = CapAltitude()}),
    GroupCommander:new({name='campbastion-attack-CheckpointAlpha-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Alpha', Altitude = CasAltitude()}),
    GroupCommander:new({name='campbastion-attack-CheckpointAlpha-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Alpha', Altitude = SeadAltitude()}),
    GroupCommander:new({name='campbastion-patrol-CheckpointAlpha-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Alpha', Altitude = CapAltitude()}),

    GroupCommander:new({name='campbastion-attack-Bost-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bost', Altitude = CapAltitude()}),
    GroupCommander:new({name='campbastion-attack-Bost-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Bost', Altitude = CasAltitude()}),
    GroupCommander:new({name='campbastion-attack-Bost-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Bost', Altitude = SeadAltitude()}),
    GroupCommander:new({name='campbastion-patrol-Bost-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bost', Altitude = CapAltitude()}),

    GroupCommander:new({name='campbastion-attack-Nimroz-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Nimroz', Altitude = CapAltitude()}),
    GroupCommander:new({name='campbastion-attack-Nimroz-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Nimroz', Altitude = CasAltitude()}),
    GroupCommander:new({name='campbastion-attack-Nimroz-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Nimroz', Altitude = SeadAltitude()}),
    GroupCommander:new({name='campbastion-patrol-Nimroz-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Nimroz', Altitude = CapAltitude()}),

    GroupCommander:new({name='campbastion-attack-Dwyer-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Dwyer', Altitude = CapAltitude()}),
    GroupCommander:new({name='campbastion-attack-Dwyer-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Dwyer', Altitude = CasAltitude()}),
    GroupCommander:new({name='campbastion-attack-Dwyer-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Dwyer', Altitude = SeadAltitude()}),
    GroupCommander:new({name='campbastion-patrol-Dwyer-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Dwyer', Altitude = CapAltitude()}),

    -- Surface attack routes
    GroupCommander:new({name='CampBastion-attack-Bost',  mission='attack',template='AttackConvoy', targetzone='Bost', type='surface'}),
})

-- DWYER (airport) -> connects to: Bost, Camp Bastion, Nimroz
zones.dwyer:addGroups({
    GroupCommander:new({name='dwyer-supply-Bost-helo',         mission='supply', template='HeloSupplyTemplate', targetzone='Bost'}),

    GroupCommander:new({name='dwyer-supply-Nimroz-helo',      mission='supply', template='HeloSupplyTemplate', targetzone='Nimroz'}),

    GroupCommander:new({name='dwyer-attack-Bost-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bost', Altitude = CapAltitude()}),
    GroupCommander:new({name='dwyer-attack-Bost-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Bost', Altitude = CasAltitude()}),
    GroupCommander:new({name='dwyer-attack-Bost-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Bost', Altitude = SeadAltitude()}),
    GroupCommander:new({name='dwyer-patrol-Bost-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bost', Altitude = CapAltitude()}),

    GroupCommander:new({name='dwyer-attack-CampBastion-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Camp Bastion', Altitude = CapAltitude()}),
    GroupCommander:new({name='dwyer-attack-CampBastion-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Camp Bastion', Altitude = CasAltitude()}),
    GroupCommander:new({name='dwyer-attack-CampBastion-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Camp Bastion', Altitude = SeadAltitude()}),
    GroupCommander:new({name='dwyer-patrol-CampBastion-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Camp Bastion', Altitude = CapAltitude()}),

    GroupCommander:new({name='dwyer-attack-Nimroz-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Nimroz', Altitude = CapAltitude()}),
    GroupCommander:new({name='dwyer-attack-Nimroz-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Nimroz', Altitude = CasAltitude()}),
    GroupCommander:new({name='dwyer-attack-Nimroz-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Nimroz', Altitude = SeadAltitude()}),
    GroupCommander:new({name='dwyer-patrol-Nimroz-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Nimroz', Altitude = CapAltitude()}),
})

-- NIMROZ (airport) -> connects to: Dwyer, Farah, Camp Bastion
zones.nimroz:addGroups({
    GroupCommander:new({name='nimroz-supply-Farah-helo',        mission='supply', template='HeloSupplyTemplate', targetzone='Farah'}),

    GroupCommander:new({name='nimroz-attack-Dwyer-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Dwyer', Altitude = CapAltitude()}),
    GroupCommander:new({name='nimroz-attack-Dwyer-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Dwyer', Altitude = CasAltitude()}),
    GroupCommander:new({name='nimroz-attack-Dwyer-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Dwyer', Altitude = SeadAltitude()}),
    GroupCommander:new({name='nimroz-patrol-Dwyer-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Dwyer', Altitude = CapAltitude()}),

    GroupCommander:new({name='nimroz-attack-Farah-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Farah', Altitude = CapAltitude()}),
    GroupCommander:new({name='nimroz-attack-Farah-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Farah', Altitude = CasAltitude()}),
    GroupCommander:new({name='nimroz-attack-Farah-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Farah', Altitude = SeadAltitude()}),
    GroupCommander:new({name='nimroz-patrol-Farah-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Farah', Altitude = CapAltitude()}),

    GroupCommander:new({name='nimroz-attack-CampBastion-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Camp Bastion', Altitude = CapAltitude()}),
    GroupCommander:new({name='nimroz-attack-CampBastion-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Camp Bastion', Altitude = CasAltitude()}),
    GroupCommander:new({name='nimroz-attack-CampBastion-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Camp Bastion', Altitude = SeadAltitude()}),
    GroupCommander:new({name='nimroz-patrol-CampBastion-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Camp Bastion', Altitude = CapAltitude()}),

    -- Surface attack routes
})

-- FARAH (airport) -> connects to: Nimroz, Shindand
zones.farah:addGroups({
    GroupCommander:new({name='farah-supply-Nimroz-helo',   mission='supply', template='HeloSupplyTemplate', targetzone='Nimroz'}),
    GroupCommander:new({name='farah-supply-Shindand-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Shindand'}),

    GroupCommander:new({name='farah-attack-Nimroz-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Nimroz', Altitude = CapAltitude()}),
    GroupCommander:new({name='farah-attack-Nimroz-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Nimroz', Altitude = CasAltitude()}),
    GroupCommander:new({name='farah-attack-Nimroz-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Nimroz', Altitude = SeadAltitude()}),
    GroupCommander:new({name='farah-patrol-Nimroz-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Nimroz', Altitude = CapAltitude()}),

    GroupCommander:new({name='farah-attack-Shindand-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Shindand', Altitude = CapAltitude()}),
    GroupCommander:new({name='farah-attack-Shindand-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Shindand', Altitude = CasAltitude()}),
    GroupCommander:new({name='farah-attack-Shindand-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Shindand', Altitude = SeadAltitude()}),
    GroupCommander:new({name='farah-patrol-Shindand-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Shindand', Altitude = CapAltitude()}),

    -- Surface attack routes
})

-- SHINDAND (airport) -> connects to: Farah, Herat
zones.shindand:addGroups({
    GroupCommander:new({name='shindand-supply-Farah-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Farah'}),
    GroupCommander:new({name='shindand-supply-Herat-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Herat'}),

    GroupCommander:new({name='shindand-attack-Farah-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Farah', Altitude = CapAltitude()}),
    GroupCommander:new({name='shindand-attack-Farah-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Farah', Altitude = CasAltitude()}),
    GroupCommander:new({name='shindand-attack-Farah-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Farah', Altitude = SeadAltitude()}),
    GroupCommander:new({name='shindand-patrol-Farah-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Farah', Altitude = CapAltitude()}),

    GroupCommander:new({name='shindand-attack-Herat-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Herat', Altitude = CapAltitude()}),
    GroupCommander:new({name='shindand-attack-Herat-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Herat', Altitude = CasAltitude()}),
    GroupCommander:new({name='shindand-attack-Herat-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Herat', Altitude = SeadAltitude()}),
    GroupCommander:new({name='shindand-patrol-Herat-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Herat', Altitude = CapAltitude()}),

    -- Surface attack routes
    GroupCommander:new({name='Shindand-attack-Herat', mission='attack', targetzone='Herat', type='surface', SetActiveMission = true}),
    GroupCommander:new({name='Shindand-attack-FOB-AhmadShahMassoud', mission='attack', targetzone='FOB-Ahmad Shah Massoud', type='surface', SetActiveMission = true}),
})

-- HERAT (airport) -> connects to: Shindand, Qala i Naw
zones.herat:addGroups({
    GroupCommander:new({name='herat-supply-QalaiNaw-helo',  mission='supply', template='HeloSupplyTemplate', targetzone='Qala i Naw'}),

    GroupCommander:new({name='herat-attack-Shindand-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Shindand', Altitude = CapAltitude()}),
    GroupCommander:new({name='herat-attack-Shindand-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Shindand', Altitude = CasAltitude()}),
    GroupCommander:new({name='herat-attack-Shindand-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Shindand', Altitude = SeadAltitude()}),
    GroupCommander:new({name='herat-patrol-Shindand-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Shindand', Altitude = CapAltitude()}),

    GroupCommander:new({name='herat-attack-QalaiNaw-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Qala i Naw', Altitude = CapAltitude()}),
    GroupCommander:new({name='herat-attack-QalaiNaw-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Qala i Naw', Altitude = CasAltitude()}),
    GroupCommander:new({name='herat-attack-QalaiNaw-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Qala i Naw', Altitude = SeadAltitude()}),
    GroupCommander:new({name='herat-patrol-QalaiNaw-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Qala i Naw', Altitude = CapAltitude()}),

    -- Surface attack routes
    GroupCommander:new({name='Herat-attack-Shindand', mission='attack', targetzone='Shindand', type='surface', SetActiveMission = true}),
})

-- QALA I NAW (airport) -> connects to: Herat, Maymana Zahiraddin Faryabi
zones.qalainaw:addGroups({
    GroupCommander:new({name='qalainaw-supply-Herat-helo',   mission='supply', template='HeloSupplyTemplate', targetzone='Herat',ForceFromGround = true}),
    GroupCommander:new({name='qalainaw-supply-Maymana-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Maymana Zahiraddin Faryabi',ForceFromGround = true}),
    GroupCommander:new({name='qalainaw-supply-Herat-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Herat',ForceFromGround = true}),

    GroupCommander:new({name='qalainaw-attack-Herat-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Herat', Altitude = CapAltitude()}),
    GroupCommander:new({name='qalainaw-attack-Herat-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Herat', Altitude = CasAltitude()}),
    GroupCommander:new({name='qalainaw-attack-Herat-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Herat', Altitude = SeadAltitude()}),
    GroupCommander:new({name='qalainaw-patrol-Herat-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Herat', Altitude = CapAltitude()}),

    GroupCommander:new({name='qalainaw-attack-Maymana-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Maymana Zahiraddin Faryabi', Altitude = CapAltitude()}),
    GroupCommander:new({name='qalainaw-attack-Maymana-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Maymana Zahiraddin Faryabi', Altitude = CasAltitude()}),
    GroupCommander:new({name='qalainaw-attack-Maymana-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Maymana Zahiraddin Faryabi', Altitude = SeadAltitude()}),
    GroupCommander:new({name='qalainaw-patrol-Maymana-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Maymana Zahiraddin Faryabi', Altitude = CapAltitude()}),
})

-- MAYMANA ZAHIRADDIN FARYABI (airport) -> connects to: QalaiNaw, Chaghcharan
zones.maymanazahiraddin:addGroups({
    GroupCommander:new({name='maymana-supply-QalaiNaw-helo',    mission='supply', template='HeloSupplyTemplate', targetzone='Qala i Naw'}),
    GroupCommander:new({name='maymana-supply-Chaghcharan-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Chaghcharan'}),


    GroupCommander:new({name='maymana-attack-QalaINaw-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Qala i Naw', Altitude = CapAltitude()}),
    GroupCommander:new({name='maymana-attack-QalaINaw-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Qala i Naw', Altitude = CasAltitude()}),
    GroupCommander:new({name='maymana-attack-QalaINaw-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Qala i Naw', Altitude = SeadAltitude()}),
    GroupCommander:new({name='maymana-patrol-QalaINaw-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Qala i Naw', Altitude = CapAltitude()}),

    GroupCommander:new({name='maymana-attack-Chaghcharan-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Chaghcharan', Altitude = CapAltitude()}),
    GroupCommander:new({name='maymana-attack-Chaghcharan-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Chaghcharan', Altitude = CasAltitude()}),
    GroupCommander:new({name='maymana-attack-Chaghcharan-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Chaghcharan', Altitude = SeadAltitude()}),
    GroupCommander:new({name='maymana-patrol-Chaghcharan-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Chaghcharan', Altitude = CapAltitude()}),

    -- Surface attack routes
    GroupCommander:new({name='Maymana-attack-FOBHamidKarzai', mission='attack', targetzone='FOB-Hamid Karzai', type='surface', SetActiveMission = true}),
	GroupCommander:new({name='Maymana-attack-FOB-Delaram-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='FOB-Delaram', type='surface',artilleryRangeNm= 7,SetActiveMission = true}),

})
zones.hamidkarzai:addGroups({
	GroupCommander:new({name='FOBHamidKarzai-supply-Maymana', mission='supply', template='HeloSupplyTemplate', targetzone='Maymana Zahiraddin Faryabi', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
	GroupCommander:new({name='FOBHamidKarzai-supply-QalaiNaw', mission='supply', template='HeloSupplyTemplate', targetzone='Qala i Naw', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
})

zones.delaram:addGroups({
	GroupCommander:new({name='delaram-supply-Maymana', mission='supply', template='HeloSupplyTemplate', targetzone='Maymana Zahiraddin Faryabi', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
	GroupCommander:new({name='delaram-supply-chaghcharan', mission='supply', template='HeloSupplyTemplate', targetzone='Chaghcharan', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
})

zones.javidbasharat:addGroups({
	GroupCommander:new({name='javidbasharat-supply-chaghcharan', mission='supply', template='HeloSupplyTemplate', targetzone='Chaghcharan', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
	GroupCommander:new({name='javidbasharat-supply-bamyan', mission='supply', template='HeloSupplyTemplate', targetzone='Bamyan', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
})

zones.bostick:addGroups({
	GroupCommander:new({name='bostick-supply-Sharana', mission='supply', template='HeloSupplyTemplate', targetzone='Sharana', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
	GroupCommander:new({name='bostick-supply-charlie', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Charlie', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
})

zones.faridbasharat:addGroups({
	GroupCommander:new({name='faridbasharat-supply-Jalalabad', mission='supply', template='HeloSupplyTemplate', targetzone='Jalalabad', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
	GroupCommander:new({name='faridbasharat-supply-Gardez', mission='supply', template='HeloSupplyTemplate', targetzone='Gardez', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
})

zones.shank:addGroups({
	GroupCommander:new({name='Shank-supply-Bravo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Bravo', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
	GroupCommander:new({name='Shank-supply-Charlie', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Charlie', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
})

zones.fenty:addGroups({
	GroupCommander:new({name='Fenty-supply-Bravo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Bravo', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
	GroupCommander:new({name='Fenty-supply-Tarinkot', mission='supply', template='HeloSupplyTemplate', targetzone='Tarinkot', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
	GroupCommander:new({name='Fenty-supply-Kandahar', mission='supply', template='HeloSupplyTemplate', targetzone='Kandahar', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
})

zones.jamsheed:addGroups({
	GroupCommander:new({name='Jamsheed-supply-Farah', mission='supply', template='HeloSupplyTemplate', targetzone='Farah', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
	GroupCommander:new({name='Jamsheed-supply-Nimroz', mission='supply', template='HeloSupplyTemplate', targetzone='Nimroz', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
	GroupCommander:new({name='Jamsheed-supply-Dwyer', mission='supply', template='HeloSupplyTemplate', targetzone='Dwyer', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
	GroupCommander:new({name='Jamsheed-supply-Camp Bastion', mission='supply', template='HeloSupplyTemplate', targetzone='Camp Bastion', Bluecondition = function(self) return self.side == 2 end, ShopLaunchOnly=true }),
})

-- CHAGHCHARAN (airport) -> connects to: Maymana Zahiraddin Faryabi, Bamyan
zones.chaghcharan:addGroups({
    GroupCommander:new({name='chaghcharan-supply-Maymana-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Maymana Zahiraddin Faryabi'}),
    GroupCommander:new({name='chaghcharan-supply-Bamyan-helo',  mission='supply', template='HeloSupplyTemplate', targetzone='Bamyan'}),

    GroupCommander:new({name='chaghcharan-attack-Maymana-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Maymana Zahiraddin Faryabi', Altitude = CapAltitude()}),
    GroupCommander:new({name='chaghcharan-attack-Maymana-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Maymana Zahiraddin Faryabi', Altitude = CasAltitude()}),
    GroupCommander:new({name='chaghcharan-attack-Maymana-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Maymana Zahiraddin Faryabi', Altitude = SeadAltitude()}),
    GroupCommander:new({name='chaghcharan-patrol-Maymana-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Maymana Zahiraddin Faryabi', Altitude = CapAltitude()}),

    GroupCommander:new({name='chaghcharan-attack-Bamyan-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bamyan', Altitude = CapAltitude()}),
    GroupCommander:new({name='chaghcharan-attack-Bamyan-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Bamyan', Altitude = CasAltitude()}),
    GroupCommander:new({name='chaghcharan-attack-Bamyan-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Bamyan', Altitude = SeadAltitude()}),
    GroupCommander:new({name='chaghcharan-patrol-Bamyan-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bamyan', Altitude = CapAltitude()}),

    -- Surface attack routes
    GroupCommander:new({name='Chaghcharan-attack-FOBDelaram',  mission='attack', targetzone='FOB-Delaram', type='surface',SetActiveMission = true}),
	GroupCommander:new({name='Chaghcharan-attack-FOB-Javid-Arty', mission='attack',template='ArtilleryConvoyLong',MissionType='ARTY',Reward=250, targetzone='FOB-Javid Basharat', type='surface',artilleryRangeNm= 7,SetActiveMission = true}),

})

-- BAMYAN (airport) -> connects to: Chaghcharan, Kabul, Bagram
zones.bamyan:addGroups({
    GroupCommander:new({name='bamyan-supply-Kabul-helo',mission='supply', template='HeloSupplyTemplate', targetzone='Kabul'}),

    GroupCommander:new({name='bamyan-supply-Bagram', mission='supply', template='HeloSupplyTemplate', targetzone='Bagram'}),

    GroupCommander:new({name='bamyan-attack-Chaghcharan-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Chaghcharan', Altitude = CapAltitude()}),
    GroupCommander:new({name='bamyan-attack-Chaghcharan-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Chaghcharan', Altitude = CasAltitude()}),
    GroupCommander:new({name='bamyan-attack-Chaghcharan-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Chaghcharan', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bamyan-patrol-Chaghcharan-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Chaghcharan', Altitude = CapAltitude()}),

    GroupCommander:new({name='bamyan-attack-Kabul-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Kabul', Altitude = CapAltitude()}),
    GroupCommander:new({name='bamyan-attack-Kabul-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Kabul', Altitude = CasAltitude()}),
    GroupCommander:new({name='bamyan-attack-Kabul-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Kabul', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bamyan-patrol-Kabul-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Kabul', Altitude = CapAltitude()}),

    GroupCommander:new({name='bamyan-attack-Bagram-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bagram', Altitude = CapAltitude()}),
    GroupCommander:new({name='bamyan-attack-Bagram-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Bagram', Altitude = CasAltitude()}),
    GroupCommander:new({name='bamyan-attack-Bagram-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Bagram', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bamyan-patrol-Bagram-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bagram', Altitude = CapAltitude()}),

    -- Surface attack routes
    GroupCommander:new({name='Bamyan-attack-FOB-JavidBasharat',  mission='attack', targetzone='FOB-Javid Basharat',  type='surface', SetActiveMission = true}),
})

-- BAGRAM (airport) -> connects to: Kabul, Bamyan, Kandahar
zones.bagram:addGroups({
    GroupCommander:new({name='bagram-supply-Kabul-plane',      mission='supply', template='SupplyConvoy', targetzone='Kabul',type='surface'}),
    GroupCommander:new({name='bagram-supply-Jalalabad-plane',  mission='supply', template='PlaneSupplyTemplate', targetzone='Jalalabad'}),
    GroupCommander:new({name='bagram-supply-Bamyan-plane',     mission='supply', template='PlaneSupplyTemplate', targetzone='Bamyan'}),

    GroupCommander:new({name='bagram-attack-Kabul-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Kabul', Altitude = CapAltitude()}),
    GroupCommander:new({name='bagram-attack-Kabul-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Kabul', Altitude = CasAltitude()}),
    GroupCommander:new({name='bagram-attack-Kabul-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Kabul', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bagram-patrol-Kabul-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Kabul', Altitude = CapAltitude()}),

    GroupCommander:new({name='bagram-attack-Bamyan-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bamyan', Altitude = CapAltitude()}),
    GroupCommander:new({name='bagram-attack-Bamyan-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Bamyan', Altitude = CasAltitude()}),
    GroupCommander:new({name='bagram-attack-Bamyan-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Bamyan', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bagram-patrol-Bamyan-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Bamyan', Altitude = CapAltitude()}),

    GroupCommander:new({name='bagram-attack-Kandahar-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Kandahar', Altitude = CapAltitude()}),
    GroupCommander:new({name='bagram-attack-Kandahar-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Kandahar', Altitude = CasAltitude()}),
    GroupCommander:new({name='bagram-attack-Kandahar-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Kandahar', Altitude = SeadAltitude()}),
    GroupCommander:new({name='bagram-patrol-Kandahar-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Kandahar', Altitude = CapAltitude()}),

    -- Surface attack routes
    GroupCommander:new({name='Bagram-attack-Kabul',  mission='attack', targetzone='Kabul',  type='surface', SetActiveMission = true}),
})

-- KANDAHAR (airport) -> connects to: Tarinkot, Checkpoint Bravo, Checkpoint Alpha
zones.kandahar:addGroups({
    GroupCommander:new({name='kandahar-supply-CheckpointBravo-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Bravo'}),
    GroupCommander:new({name='kandahar-supply-CheckpointAlpha-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Alpha'}),

    GroupCommander:new({name='kandahar-supply-Tarinkot-plane',   mission='supply', template='PlaneSupplyTemplate', targetzone='Tarinkot'}),
    GroupCommander:new({name='kandahar-supply-Dwyer-plane',      mission='supply', template='PlaneSupplyTemplate', targetzone='Dwyer'}),
    GroupCommander:new({name='kandahar-supply-Shindand-plane',   mission='supply', template='PlaneSupplyTemplate', targetzone='Shindand'}),
    GroupCommander:new({name='kandahar-supply-Kabul-plane',      mission='supply', template='PlaneSupplyTemplate', targetzone='Kabul'}),

    GroupCommander:new({name='kandahar-attack-Tarinkot-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Tarinkot', Altitude = CapAltitude()}),
    GroupCommander:new({name='kandahar-attack-Tarinkot-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Tarinkot', Altitude = CasAltitude()}),
    GroupCommander:new({name='kandahar-attack-Tarinkot-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Tarinkot', Altitude = SeadAltitude()}),
    GroupCommander:new({name='kandahar-patrol-Tarinkot-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Tarinkot', Altitude = CapAltitude()}),

    GroupCommander:new({name='kandahar-attack-CheckpointBravo-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Bravo', Altitude = CapAltitude()}),
    GroupCommander:new({name='kandahar-attack-CheckpointBravo-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Bravo', Altitude = CasAltitude()}),
    GroupCommander:new({name='kandahar-attack-CheckpointBravo-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Bravo', Altitude = SeadAltitude()}),
    GroupCommander:new({name='kandahar-patrol-CheckpointBravo-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Bravo', Altitude = CapAltitude()}),

    GroupCommander:new({name='kandahar-attack-CheckpointAlpha-cap',  mission='attack', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Alpha', Altitude = CapAltitude()}),
    GroupCommander:new({name='kandahar-attack-CheckpointAlpha-cas',  mission='attack', template='CasPlaneTemplate',  MissionType='CAS',  targetzone='Checkpoint Alpha', Altitude = CasAltitude()}),
    GroupCommander:new({name='kandahar-attack-CheckpointAlpha-sead', mission='attack', template='SeadPlaneTemplate', MissionType='SEAD', targetzone='Checkpoint Alpha', Altitude = SeadAltitude()}),
    GroupCommander:new({name='kandahar-patrol-CheckpointAlpha-cap',  mission='patrol', template='CapPlaneTemplate',  MissionType='CAP',  targetzone='Checkpoint Alpha', Altitude = CapAltitude()}),
})
-------------------------------end of GroupCommander Routes-------------------------------

---------------Start of airbase definitions(this is what allows you to spawn at the airbase and allows helos------------------------

zones.kandahar.isHeloSpawn = true
zones.kandahar.airbaseName = 'Kandahar'
zones.kandahar.LogisticCenter = true

zones.fobkunar.isHeloSpawn = true
zones.fobkunar.airbaseName = 'FOB Kunar'

zones.jalalabad.isHeloSpawn = true
zones.jalalabad.airbaseName = 'Jalalabad'

zones.checkpointkabule.isHeloSpawn = true
zones.checkpointkabule.airbaseName = 'Checkpoint Kabul E'

zones.kabul.isHeloSpawn = true
zones.kabul.airbaseName = 'Kabul'

zones.checkpointkabulw.isHeloSpawn = true
zones.checkpointkabulw.airbaseName = 'Checkpoint Kabul W'

zones.kabulsouth.isHeloSpawn = true
zones.kabulsouth.airbaseName = 'Checkpoint Kabul S'

zones.delta.isHeloSpawn = true
zones.delta.airbaseName = 'Checkpoint Delta'

zones.gardez.isHeloSpawn = true
zones.gardez.airbaseName = 'Gardez'

zones.ghazniheliport.isHeloSpawn = true
zones.ghazniheliport.airbaseName = 'Ghazni Heliport'

zones.sharana.isHeloSpawn = true
zones.sharana.airbaseName = 'Sharana'

zones.charlie.isHeloSpawn = true
zones.charlie.airbaseName = 'Checkpoint Charlie'

zones.tarinkot.isHeloSpawn = true
zones.tarinkot.airbaseName = 'Tarinkot'

zones.alpha.isHeloSpawn = true
zones.alpha.airbaseName = 'Checkpoint Alpha'
zones.alpha.LogisticCenter = true

zones.bost.isHeloSpawn = true
zones.bost.airbaseName = 'Bost'

zones.campbastion.isHeloSpawn = true
zones.campbastion.airbaseName = 'Camp Bastion'

zones.dwyer.isHeloSpawn = true
zones.dwyer.airbaseName = 'Dwyer'

zones.nimroz.isHeloSpawn = true
zones.nimroz.airbaseName = 'Nimroz'

zones.farah.isHeloSpawn = true
zones.farah.airbaseName = 'Farah'

zones.shindand.isHeloSpawn = true
zones.shindand.airbaseName = 'Shindand'

zones.herat.isHeloSpawn = true
zones.herat.airbaseName = 'Herat'

zones.bamyan.isHeloSpawn = true
zones.bamyan.airbaseName = 'Bamyan'

zones.chaghcharan.isHeloSpawn = true
zones.chaghcharan.airbaseName = 'Chaghcharan'

zones.qalainaw.isHeloSpawn = true
zones.qalainaw.airbaseName = 'Qala i Naw'

zones.maymanazahiraddin.isHeloSpawn = true
zones.maymanazahiraddin.airbaseName = 'Maymana Zahiraddin Faryabi'

zones.bravo.isHeloSpawn = true
zones.bravo.airbaseName = 'Checkpoint Bravo'

zones.bagram.isHeloSpawn = true
zones.bagram.airbaseName = 'Bagram'

zones.jamsheed.isHeloSpawn = true
zones.jamsheed.airbaseName = 'FOB-Jamsheed'

zones.bostick.isHeloSpawn = true
zones.bostick.airbaseName = 'FOB-Bostick'

zones.lagman.isHeloSpawn = true
zones.lagman.airbaseName = 'FOB-Lagman'

zones.shank.isHeloSpawn = true
zones.shank.airbaseName = 'FOB-Shank'

zones.javidbasharat.isHeloSpawn = true
zones.javidbasharat.airbaseName = 'FOB-Javid Basharat'

zones.hamidkarzai.isHeloSpawn = true
zones.hamidkarzai.airbaseName = 'FOB-Hamid Karzai'

zones.ismailkhan.isHeloSpawn = true
zones.ismailkhan.airbaseName = 'FOB-Ismail Khan'

zones.ahmadshahmassoud.isHeloSpawn = true
zones.ahmadshahmassoud.airbaseName = 'FOB-Ahmad Shah Massoud'

zones.faridbasharat.isHeloSpawn = true
zones.faridbasharat.airbaseName = 'FOB-Farid Basharat'

zones.delaram.isHeloSpawn = true
zones.delaram.airbaseName = 'FOB-Delaram'

zones.fenty.isHeloSpawn = true
zones.fenty.airbaseName = 'FOB-Fenty'

zones.khost.airbaseName = 'Khost'
zones.khost.isHeloSpawn = true

zones.urgoon.airbaseName = 'Urgoon Heliport'
zones.urgoon.isHeloSpawn = true


--
--------------------------------------------end Airbase definitions------------------------
for i,v in pairs(zones) do
	bc:addZone(v)
end

---------------------------Begin connections (this is what draws lines between each point--------------------------
bc:addConnection("Kandahar","Checkpoint Alpha",true)

bc:addConnection("Checkpoint Alpha","Bost",true)

bc:addConnection("Checkpoint Alpha","Camp Bastion",true)

bc:addConnection("Checkpoint Alpha","Tarinkot",true)

bc:addConnection("Camp Bastion","Nimroz",true)

bc:addConnection("Camp Bastion","Dwyer",true)

bc:addConnection("Bost","Dwyer",true)

bc:addConnection("Bost","Camp Bastion",true)

bc:addConnection("Kandahar","Checkpoint Bravo",true)

bc:addConnection("Kandahar","Tarinkot",true)

bc:addConnection("Checkpoint Bravo","Tarinkot",true)

bc:addConnection("Checkpoint Bravo","Checkpoint Charlie",true)

bc:addConnection("Tarinkot","Checkpoint Charlie",true)

bc:addConnection("Checkpoint Charlie","Sharana",true)

bc:addConnection("Checkpoint Charlie","Ghazni Heliport",true)

bc:addConnection("Sharana","Ghazni Heliport",true)

bc:addConnection("Sharana","Gardez",true)

bc:addConnection("Ghazni Heliport","Gardez",true)

bc:addConnection("Ghazni Heliport","Checkpoint Delta",true)

bc:addConnection("Checkpoint Delta","Checkpoint Kabul S",true)

bc:addConnection("Checkpoint Delta","Checkpoint Kabul W",true)

bc:addConnection("Checkpoint Delta","Kabul",true)

bc:addConnection("Checkpoint Delta","Bamyan",true)

bc:addConnection("Farah","Shindand",true)

bc:addConnection("Shindand","Herat",true)

bc:addConnection("Herat","Chaghcharan",true)

bc:addConnection("Herat","Qala i Naw",true)

bc:addConnection("Qala i Naw","Maymana Zahiraddin Faryabi",true)

bc:addConnection("Qala i Naw","Chaghcharan",true)

bc:addConnection("Chaghcharan","Maymana Zahiraddin Faryabi",true)

bc:addConnection("Chaghcharan","Bamyan",true)

bc:addConnection("Bamyan","Kabul",true)

bc:addConnection("Bamyan","Bagram",true)

bc:addConnection("Kabul","Bagram",true)

bc:addConnection("Kabul","Checkpoint Kabul E",true)

bc:addConnection("Bagram","Checkpoint Kabul E",true)

bc:addConnection("Checkpoint Kabul E","Jalalabad",true)

bc:addConnection("Kabul","Checkpoint Kabul W",true)

bc:addConnection("Bagram","Checkpoint Kabul W",true)

bc:addConnection("Kabul","Checkpoint Kabul S",true)

bc:addConnection("Checkpoint Kabul S","Checkpoint Kabul E",true)

bc:addConnection("Dwyer","Nimroz",true)

bc:addConnection("Nimroz","Farah",true)

bc:addConnection("Gardez","Jalalabad",true)

bc:addConnection("Gardez","Checkpoint Kabul S",true)

bc:addConnection("Jalalabad","FOB Kunar",true)

bc:addConnection("Camp Bastion","Insurgent Base Delaram")
bc:addConnection("Farah","Insurgent Base Chimozay")
bc:addConnection("Checkpoint Bravo","Insurgent Base Qalat")
bc:addConnection("Tarinkot","Insurgent Base Nili")
bc:addConnection("Tarinkot","Insurgent Base Alpha")
bc:addConnection("Checkpoint Charlie","Insurgent Qarabagh")
bc:addConnection("Checkpoint Kabul E","Insurgent Base Mountain")
bc:addConnection("Checkpoint Kabul E","Insurgent Base Sarobi")
bc:addConnection("FOB Kunar","Insurgent Base Asadabad")
bc:addConnection("FOB Kunar","Insurgent Base Kunar")


----------------------------end connections --------------------------------

missions = {
}

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
					if WarehouseLogistics == true and WarehousePersistence.ClearFile then
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
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-19 #",
		"Red SAM SHORAD Tor M2 #",
		"Red SAM SHORAD SA-9 #",
}, 50, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
else
	bc:roamGroupsToLocalSubZone({
		"Red Armour Group #",
        "Red Armour Group 2 #",
        "Red Armour Group 3 #",
		"Red SAM AAA #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-8 #",
		"Red SAM SHORAD SA-19 #",
		"Red SAM SHORAD SA-13 #",
		"Red SAM SHORAD SA-9 #",
}, 50, nil, { zoneMin = 210, zoneMax = 600, cycleMin = 600, cycleMax = 1200 })
end
end,{},5,0)

-- SHOP --
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
local samLabel = (Era == 'Coldwar') and LTGet("SYRIA_SHOP_ITEM_UPGRADE_HAWK")
                                   or  LTGet("SYRIA_SHOP_ITEM_UPGRADE_NASAMS")
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
-----------------------------------------------


-----------------------------------------------


supplyZones = {
    'Kandahar',
    'Kabul',
    'Jalalabad',
    'Tarinkot',
    'Herat',
    'Shindand',
    'Farah',
    'Camp Bastion',
    'Bost',
    'Dwyer',
    'Nimroz',
    'Gardez',
    'Sharana',
    'Ghazni Heliport',
    'Bamyan',
    'Bagram',
    'Chaghcharan',
    'QalaiNaw',
    'Maymana Zahiraddin Faryabi',
    'FOB Kunar',
    'Checkpoint Alpha',
    'Checkpoint Bravo',
    'Checkpoint Charlie',
    'Checkpoint Delta',
    'Checkpoint Kabul E',
    'Checkpoint Kabul S',
    'Checkpoint Kabul W',
}

zones.insurgentqalat:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "Insurgent Qalat"),20)
end, 'disablesinsurgentqalat')


zones.insurgentdelaram:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "Insurgent Delaram"),20)
end, 'disablesinsurgentdelaram')


zones.insurgentchimozay:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "Insurgent Chimozay"),20)
end, 'disableinsurgentchimozay')


zones.insurgentnili:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "Insurgent Nili"),20)
end, 'disableinsurgentnili')


zones.insurgentalpha:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "Insurgent Alpha"),20)
end, 'disableinsurgentalpha')


zones.insurgentqarabagh:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "Insurgent Qarabagh"),20)
end, 'disableinsurgentqarabagh')


zones.insurgentasadabad:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "Insurgent Asadabad"),20)
end, 'disableinsurgentasadabad')


zones.insurgentkunar:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "Insurgent Kunar"),20)
end, 'disableinsurgentkunar')


zones.insurgentsarobi:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "Insurgent Sarobi"),20)
end, 'disableinsurgentsarobi')


zones.insurgentmountain:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "Insurgent Mountain"),20)
end, 'disableinsurgentmountain')
zones.samalpha:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "SAM Alpha"),20)
end, 'disablesamalpha')
zones.sambravo:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "SAM Bravo"),20)
end, 'disablesambravo')
zones.samcharlie:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "SAM Charlie Mountain"),20)
end, 'disablesamcharlie')
zones.samjamsheed:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,L10N:Format("AF_SETUP_ENEMIES_DEFEATED_500", "SAM Jamsheed"),20)
end, 'disablesamjamsheed')

lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

TerritoryOverlayOuterDrawPushMeters = 500000

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
		zones.bagram.LogisticCenter = true
		DestroyOnce=true
    else
	zones.kandahar.LogisticCenter = true
	zones.alpha.LogisticCenter = true
    end
else
    applyRandomUpgradesForNewZonesOnly()
end

bc:init()

if DestroyOnce then
	destroyGroupIfActive('Red EWR Bagram Fixed')
	CustomFlags["Red EWR Bagram Fixed"] = true
end
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
local HuntNumber = SplashDamage and math.random(15,22) or math.random(10,20)
bc:initHunter(HuntNumber)
SCHEDULER:New(nil, function() bc:_buildHunterBaseList() end, {}, 1)

SCHEDULER:New(nil, function() spawnAwacs(1,nil,10) end, {}, 3)
SCHEDULER:New(nil, function() spawnAwacs(2,nil,10) end, {}, 4)

AWACS_CFG = {
    [1] = { alt=30000, speed=350, hdg=270, leg=15, sep=150 }, -- red
    [2] = { alt=30000, speed=350, hdg=270, leg=15, sep=70 }   -- blue
}

GlobalSettings.autoSuspendNmBlue = 80   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 100   		-- suspend red zones deeper than this nm

evc = EventCommander:new({ decissionFrequency=10*60, decissionVariance=10*60, skipChance = 10})
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
    runwayCooldown = timer.getTime() + 600
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
				bc.playerContributions[2][jp] = (bc.playerContributions[2][jp] or 0) + reward
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


-------------------------------- Destroy artillery --------------------------------

mc:trackMission({
    title = LTGet("MISSION_ARTY_TITLE"),
    description = LTFormat("MISSION_ARTY_DESCRIPTION", "south of FOB-Delaram", "FOB-Delaram"),
    messageStart = LTFormat("MISSION_ARTY_START", "FOB-Delaram"),
    messageEnd = LTGet("MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Chaghcharan-attack-FOBDelaram',250,L10N:Get("MISSION_ARTY_TITLE"),'Chaghcharan-attack-FOBDelaram')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Chaghcharan-attack-FOBDelaram'] then return false end
        if Group.getByName('Chaghcharan-attack-FOBDelaram') then return true end
        ActiveMission['Chaghcharan-attack-FOBDelaram'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("MISSION_ARTY_TITLE"),
    description = LTFormat("MISSION_ARTY_DESCRIPTION", "Maymana", "FOB-Hamid Karzai"),
    messageStart = LTFormat("MISSION_ARTY_START", "FOB-Hamid Karzai"),
    messageEnd = LTGet("MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Maymana-attack-FOBHamidKarzai',250,L10N:Get("MISSION_ARTY_TITLE"),'Maymana-attack-FOBHamidKarzai')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Maymana-attack-FOBHamidKarzai'] then return false end
        if Group.getByName('Maymana-attack-FOBHamidKarzai') then return true end
        ActiveMission['Maymana-attack-FOBHamidKarzai'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("MISSION_ARTY_TITLE"),
    description = LTFormat("MISSION_ARTY_DESCRIPTION", "Shindand", "Herat"),
    messageStart = LTFormat("MISSION_ARTY_START", "Herat"),
    messageEnd = LTGet("MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Shindand-attack-Herat',250,L10N:Get("MISSION_ARTY_TITLE"),'Shindand-attack-Herat')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Shindand-attack-Herat'] then return false end
        if Group.getByName('Shindand-attack-Herat') then return true end
        ActiveMission['Shindand-attack-Herat'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("MISSION_ARTY_TITLE"),
    description = LTFormat("MISSION_ARTY_DESCRIPTION", "Herat", "Shindand"),
    messageStart = LTFormat("MISSION_ARTY_START", "Shindand"),
    messageEnd = LTGet("MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Herat-attack-Shindand',250,L10N:Get("MISSION_ARTY_TITLE"),'Herat-attack-Shindand')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Herat-attack-Shindand'] then return false end
        if Group.getByName('Herat-attack-Shindand') then return true end
        ActiveMission['Herat-attack-Shindand'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("MISSION_ARTY_TITLE"),
    description = LTFormat("MISSION_ARTY_DESCRIPTION", "Shindand", "FOB-Ahmad Shah Massoud"),
    messageStart = LTFormat("MISSION_ARTY_START", "FOB-Ahmad Shah Massoud"),
    messageEnd = LTGet("MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Shindand-attack-FOB-AhmadShahMassoud',100,L10N:Get("MISSION_ARTY_TITLE"),'Shindand-attack-FOB-AhmadShahMassoud')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Shindand-attack-FOB-AhmadShahMassoud'] then return false end
        if Group.getByName('Shindand-attack-FOB-AhmadShahMassoud') then return true end
        ActiveMission['Shindand-attack-FOB-AhmadShahMassoud'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("MISSION_ARTY_TITLE"),
    description = LTFormat("MISSION_ARTY_DESCRIPTION", "Shindand", "FOB-Javid"),
    messageStart = LTFormat("MISSION_ARTY_START", "FOB-Javid"),
    messageEnd = LTGet("MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Bamyan-attack-FOB-JavidBasharat',100,L10N:Get("MISSION_ARTY_TITLE"),'Bamyan-attack-FOB-JavidBasharat')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Bamyan-attack-FOB-JavidBasharat'] then return false end
        if Group.getByName('Bamyan-attack-FOB-JavidBasharat') then return true end
        ActiveMission['Bamyan-attack-FOB-JavidBasharat'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("MISSION_ARTY_TITLE"),
    description = LTFormat("MISSION_ARTY_DESCRIPTION", "Bagram", "Kabul"),
    messageStart = LTFormat("MISSION_ARTY_START", "Kabul"),
    messageEnd = LTGet("MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Bagram-attack-Kabul',250,L10N:Get("MISSION_ARTY_TITLE"),'Bagram-attack-Kabul')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['Bagram-attack-Kabul'] then return false end
        if Group.getByName('Bagram-attack-Kabul') then return true end
        ActiveMission['Bagram-attack-Kabul'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("MISSION_ARTY_TITLE"),
    description = LTFormat("MISSION_ARTY_DESCRIPTION", "Checkpoint Delta", "Ghazni Heliport"),
    messageStart = LTFormat("MISSION_ARTY_START", "Ghazni Heliport"),
    messageEnd = LTGet("MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('CheckpointDelta-attack-GhazniHeliport',250,L10N:Get("MISSION_ARTY_TITLE"),'CheckpointDelta-attack-GhazniHeliport')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['CheckpointDelta-attack-GhazniHeliport'] then return false end
        if Group.getByName('CheckpointDelta-attack-GhazniHeliport') then return true end
        ActiveMission['CheckpointDelta-attack-GhazniHeliport'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("MISSION_ARTY_TITLE"),
    description = LTFormat("MISSION_ARTY_DESCRIPTION", "Checkpoint Charlie", "FOB-Bostick"),
    messageStart = LTFormat("MISSION_ARTY_START", "FOB-Bostick"),
    messageEnd = LTGet("MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('CheckpointCharlie-attack-FOB-Bostick',250,L10N:Get("MISSION_ARTY_TITLE"),'CheckpointCharlie-attack-FOB-Bostick')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['CheckpointCharlie-attack-FOB-Bostick'] then return false end
        if Group.getByName('CheckpointCharlie-attack-FOB-Bostick') then return true end
        ActiveMission['CheckpointCharlie-attack-FOB-Bostick'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("MISSION_ARTY_TITLE"),
    description = LTFormat("MISSION_ARTY_DESCRIPTION", "Checkpoint Bravo", "Tarinkot"),
    messageStart = LTFormat("MISSION_ARTY_START", "Tarinkot"),
    messageEnd = LTGet("MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('CheckpointBravo-attack-Tarinkot',250,L10N:Get("MISSION_ARTY_TITLE"),'CheckpointBravo-attack-Tarinkot')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['CheckpointBravo-attack-Tarinkot'] then return false end
        if Group.getByName('CheckpointBravo-attack-Tarinkot') then return true end
        ActiveMission['CheckpointBravo-attack-Tarinkot'] = nil
        return false
    end
})

mc:trackMission({
    title = LTGet("MISSION_ARTY_TITLE"),
    description = LTFormat("MISSION_ARTY_DESCRIPTION", "Checkpoint Kabul East", "Kabul"),
    messageStart = LTFormat("MISSION_ARTY_START", "Kabul"),
    messageEnd = LTGet("MISSION_ARTY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('CheckpointKabulE-attack-Kabul',250,L10N:Get("MISSION_ARTY_TITLE"),'CheckpointKabulE-attack-Kabul')
    end,
    endAction = function()
    end,
    isActive = function()
        if not ActiveMission['CheckpointKabulE-attack-Kabul'] then return false end
        if Group.getByName('CheckpointKabulE-attack-Kabul') then return true end
        ActiveMission['CheckpointKabulE-attack-Kabul'] = nil
        return false
    end
})

--CheckpointKabulE-attack-Kabul
---------------------------------------- Scenery Check ---------------------------------------

local sceneryList = {
    ["BostBuilding"] = {SCENERY:FindByZoneName("BostBuilding")},

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

----------------------------------------------- BostBuilding-----------------------------------------------
evc:addEvent({
	id = 'BostBuilding',
	action = function()
		local tgt = sceneryList['BostBuilding'][1] or SCENERY:FindByZoneName('BostBuilding')
		if not tgt then
			trigger.action.outText(L10N:Format("SYRIA_SETUP_OBJECT_MISSING", "BostBuilding"),30)
			return
		end
        RegisterScoreTarget('BostBuilding',tgt,500,L10N:Get("AF_MISSION_STRIKE_BIN_LADEN_LOCATION_TARGET"),true)
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,L10N:Get("AF_MISSION_STRIKE_BIN_LADEN_LOCATION_TARGET"),p,2,false,false)
			MissionMarks['BostBuilding'] = missionMarkId
		end
	end,
	canExecute = function()
    if CustomFlags["BostBuilding"] then return false end
    if ActiveMission['BostBuilding'] then return false end
	--if bc:getZoneByName('Bost').side == 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = LTGet("AF_MISSION_STRIKE_BIN_LADEN_LOCATION_TITLE"),
	description = LTGet("AF_MISSION_STRIKE_BIN_LADEN_LOCATION_DESC"),
	messageStart = LTGet("AF_MISSION_STRIKE_BIN_LADEN_LOCATION_START"),
	messageEnd = LTGet("AF_MISSION_STRIKE_BIN_LADEN_LOCATION_END"),
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
	if CustomFlags["BostBuilding"] then return false end
	if ActiveMission['BostBuilding'] then return true end
	return false
	end
})

--------------------------------------------- End of BostBuilding ---------------------------------------------



---------------------------------------------- Capture Khost------------------------------------------------------
mc:trackMission({
	title = LTGet("AF_MISSION_CAPTURE_KHOST_TITLE"),
	description = LTGet("AF_MISSION_CAPTURE_KHOST_DESC"),
	messageStart = LTGet("AF_MISSION_CAPTURE_KHOST_START"),
	messageEnd = LTGet("AF_MISSION_CAPTURE_KHOST_END"),
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
    if bc:getZoneByName('Urgoon Heliport').side == 0 then return false end
    if bc:getZoneByName('Gardez').side == 2 and bc:getZoneByName('Khost').side == 0 then return true end
	return false
	end
})

---------------------------------------------- End of Capture Khost ------------------------------------------------------
---------------------------------------------- Capture Urgoon Heliport------------------------------------------------------
mc:trackMission({
	title = LTGet("AF_MISSION_CAPTURE_URGOON_HELIPORT_TITLE"),
	description = LTGet("AF_MISSION_CAPTURE_URGOON_HELIPORT_DESC"),
	messageStart = LTGet("AF_MISSION_CAPTURE_URGOON_HELIPORT_START"),
	messageEnd = LTGet("AF_MISSION_CAPTURE_URGOON_HELIPORT_END"),
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
    if bc:getZoneByName('Sharana').side == 2 and bc:getZoneByName('Urgoon Heliport').side == 0 then return true end
	return false
	end
})

---------------------------------------------- End of Capture Urgoon ------------------------------------------------------
----------------------------------------------- Associates -----------------------------------------------------------
Group.getByName('Associates'):destroy()
Group.getByName('AssociatesConvoy'):destroy()
evc:addEvent({
	id='Associates',
	action = function()
	RespawnGroup('Associates')
    RegisterGroupTarget('Associates',500,L10N:Get("AF_MISSION_ASSOCIATES_TARGET"),'Associates',true)
	end,
	canExecute = function()
		--if math.random(1,100) < 70 then return false end
        if CustomFlags["Associates"] then return false end
        if ActiveMission['Associates'] then return false end
        if Group.getByName('Associates') then return false end
		local Shindand =  bc:getZoneByName('Shindand')
		if Shindand.side ~= 2 then return false end
	return true
end
})
mc:trackMission({
	title = LTGet("AF_MISSION_ASSOCIATES_TITLE"),
	description = LTGet("AF_MISSION_ASSOCIATES_DESC"),
	messageStart = LTGet("AF_MISSION_ASSOCIATES_START"),
	messageEnd = LTGet("AF_MISSION_ASSOCIATES_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
        RespawnGroup('AssociatesConvoy')
        trigger.action.outTextForCoalition(2,L10N:Get("AF_MISSION_ASSOCIATE_FLEEING"),30)
	end,
	isActive = function()
    if CustomFlags["Associates"] then return false end
    if not ActiveMission['Associates'] then return false end
    if Group.getByName('Associates') then return true end
    ActiveMission['Associates'] = nil
    return false
	end,
})



evc:addEvent({
	id='AssociatesConvoy',
	action = function()
    RegisterGroupTarget('AssociatesConvoy',500,L10N:Get("AF_MISSION_ASSOCIATES_CONVOY_TARGET"),'AssociatesConvoy',true)
	end,
	canExecute = function()
		--if math.random(1,100) < 70 then return false end
        if CustomFlags["AssociatesConvoy"] then return false end
        if ActiveMission['AssociatesConvoy'] then return false end
        if not CustomFlags["Associates"] then return false end
        if Group.getByName('AssociatesConvoy') then return false end
	return true
end
})
mc:trackMission({
	title = LTGet("AF_MISSION_ASSOCIATES_CONVOY_TITLE"),
	description = LTGet("AF_MISSION_ASSOCIATES_CONVOY_DESC"),
	messageStart = LTGet("AF_MISSION_ASSOCIATES_CONVOY_START"),
	messageEnd = LTGet("AF_MISSION_ASSOCIATES_CONVOY_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
    if CustomFlags["AssociatesConvoy"] then return false end
    if not ActiveMission['AssociatesConvoy'] then return false end
    if Group.getByName('AssociatesConvoy') then return true end
    ActiveMission['AssociatesConvoy'] = nil
    return false
	end,
})
--------------------------------end of associates---------------------------------
----------------------------------------------- Bodyguards -----------------------------------------------------------
Group.getByName('Bodyguards'):destroy()
Group.getByName('BinLadenEscape'):destroy()
evc:addEvent({
	id='Bodyguards',
	action = function()
	RespawnGroup('Bodyguards')
    RegisterGroupTarget('Bodyguards',500,L10N:Get("AF_MISSION_BODYGUARDS_TARGET"),'Bodyguards',true)
	end,
	canExecute = function()
		--if math.random(1,100) < 70 then return false end
        if CustomFlags["Bodyguards"] then return false end
        if ActiveMission['Bodyguards'] then return false end
        if Group.getByName('Bodyguards') then return false end
		local Kabul =  bc:getZoneByName('Kabul')
		if Kabul.side ~= 2 then return false end
	return true
end
})
mc:trackMission({
	title = LTGet("AF_MISSION_BODYGUARDS_TITLE"),
	description = LTGet("AF_MISSION_BODYGUARDS_DESC"),
	messageStart = LTGet("AF_MISSION_BODYGUARDS_START"),
	messageEnd = LTGet("AF_MISSION_BODYGUARDS_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
        RespawnGroup('BinLadenEscape')
        trigger.action.outTextForCoalition(2,L10N:Get("AF_MISSION_BIN_LADEN_FLEEING"),30)
	end,
	isActive = function()
	if CustomFlags["Bodyguards"] then return false end
    if not ActiveMission['Bodyguards'] then return false end
    if Group.getByName('Bodyguards') then return true end
    ActiveMission['Bodyguards'] = nil
    return false
	end,
})



evc:addEvent({
	id='BinLadenEscape',
	action = function()
    RegisterGroupTarget('BinLadenEscape',500,L10N:Get("AF_MISSION_BIN_LADEN_ESCAPE_TARGET"),'BinLadenEscape',true)
	end,
	canExecute = function()
		--if math.random(1,100) < 70 then return false end
        if CustomFlags["BinLadenEscape"] then return false end
        if ActiveMission['BinLadenEscape'] then return false end
        if not CustomFlags["Bodyguards"] then return false end
        if Group.getByName('BinLadenEscape') then return false end
	return true
end
})
mc:trackMission({
	title = LTGet("AF_MISSION_BIN_LADEN_ESCAPE_TITLE"),
	description = LTGet("AF_MISSION_BIN_LADEN_ESCAPE_DESC"),
	messageStart = LTGet("AF_MISSION_BIN_LADEN_ESCAPE_START"),
	messageEnd = LTGet("AF_MISSION_BIN_LADEN_ESCAPE_END"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
    if CustomFlags["BinLadenEscape"] then return false end
    if not ActiveMission['BinLadenEscape'] then return false end
    if Group.getByName('BinLadenEscape') then return true end
    ActiveMission['BinLadenEscape'] = nil
    return false
	end,
})
-------------------------end Bodyguards-------------------------------
----------------------------------------------- EWRS - Camp Bastion -----------------------------------------------------------
evc:addEvent({
	id='Red EWR Camp Bastion Fixed',
	action = function()
    RegisterGroupTarget('Red EWR Camp Bastion Fixed',300,L10N:Format("AF_MISSION_EWR_TITLE", "Camp Bastion"),'Red EWR Camp Bastion Fixed',true)
	end,
	canExecute = function()
        if CustomFlags["Red EWR Camp Bastion Fixed"] then return false end
		if ActiveMission['Red EWR Camp Bastion Fixed'] then return false end
		if not Group.getByName('Red EWR Camp Bastion Fixed') then return false end
		if bc:getZoneByName('Bost').side ~= 2 then return false end
	return true
end
})
mc:trackMission({
	title = LTFormat("AF_MISSION_EWR_TITLE", "Camp Bastion"),
	description = LTFormat("AF_MISSION_EWR_DESC", "Camp Bastion", "41 R PR 26499 32795", "N 31°55'26\" E 64°20'17\"", "N 31°55.441' E 64°20.285'", "2916"),
	messageStart = LTFormat("AF_MISSION_EWR_START", "Camp Bastion"),
	messageEnd = LTFormat("AF_MISSION_EWR_END", "Camp Bastion"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["Red EWR Camp Bastion Fixed"] then return false end
    if ActiveMission['Red EWR Camp Bastion Fixed'] then return true end
	return false
	end,
})

-----------------------------------------------END EWRS - Camp Bastion -----------------------------------------------------------
----------------------------------------------- EWRS - Nimroz -----------------------------------------------------------
evc:addEvent({
	id='Red EWR Nimroz Fixed',
	action = function()
    RegisterGroupTarget('Red EWR Nimroz Fixed',300,L10N:Format("AF_MISSION_EWR_TITLE", "Nimroz"),'Red EWR Nimroz Fixed',true)
	end,
	canExecute = function()
        if CustomFlags["Red EWR Nimroz Fixed"] then return false end
        if ActiveMission['Red EWR Nimroz Fixed'] then return false end
		if not Group.getByName('Red EWR Nimroz Fixed') then return false end
		if bc:getZoneByName('Dwyer').side ~= 2 then return false end
	return true
end
})
mc:trackMission({
	title = LTFormat("AF_MISSION_EWR_TITLE", "Nimroz"),
	description = LTFormat("AF_MISSION_EWR_DESC", "Nimroz", "41 R MQ 52934 19038", "N 30°54'13\" E 62°30'26\"", "N 30°54.224' E 62°30.449'", "2381"),
	messageStart = LTFormat("AF_MISSION_EWR_START", "Nimroz"),
	messageEnd = LTFormat("AF_MISSION_EWR_END", "Nimroz"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
    end,
    isActive = function()
    if CustomFlags["Red EWR Nimroz Fixed"] then return false end
    if ActiveMission['Red EWR Nimroz Fixed'] then return true end
    return false
	end,
	
})

-----------------------------------------------END EWRS - Nimroz -----------------------------------------------------------
----------------------------------------------- EWRS - Herat -----------------------------------------------------------
evc:addEvent({
	id='Red EWR Herat Fixed',
	action = function()
    RegisterGroupTarget('Red EWR Herat Fixed',300,L10N:Format("AF_MISSION_EWR_TITLE", "Herat"),'Red EWR Herat Fixed',true)
	end,
	canExecute = function()
        if CustomFlags["Red EWR Herat Fixed"] then return false end
        if ActiveMission['Red EWR Herat Fixed'] then return false end
		--if math.random(1,100) < 70 then return false end
		if not Group.getByName('Red EWR Nimroz Fixed') then return false end
		if CustomFlags["Red EWR Nimroz Fixed"] then return false end
		 if bc:getZoneByName('Shindand').side ~= 2 then return false end
	return true
end
})
mc:trackMission({
	title = LTFormat("AF_MISSION_EWR_TITLE", "Herat"),
	description = LTFormat("AF_MISSION_EWR_DESC", "Herat", "41 S MU 35387 32028", "N 34°37'41\" E 62°17'42\"", "N 34°37.686' E 62°17.706'", "7676"),
	messageStart = LTFormat("AF_MISSION_EWR_START", "Herat"),
	messageEnd = LTFormat("AF_MISSION_EWR_END", "Herat"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["Red EWR Herat Fixed"] then return false end
	if ActiveMission['Red EWR Herat Fixed'] then return true end
	return false
	end,
})

-----------------------------------------------END EWRS - Herat -----------------------------------------------------------
----------------------------------------------- EWRS - Chaghcharan -----------------------------------------------------------
evc:addEvent({
	id='Red EWR Chaghcharan Fixed',
	action = function()
    RegisterGroupTarget('Red EWR Chaghcharan Fixed',300,L10N:Format("AF_MISSION_EWR_TITLE", "Chaghcharan"),'Red EWR Chaghcharan Fixed',true)
	end,
	canExecute = function()
        if CustomFlags["Red EWR Chaghcharan Fixed"] then return false end
		if ActiveMission['Red EWR Chaghcharan Fixed'] then return false end
		if not Group.getByName('Red EWR Chaghcharan Fixed') then return false end
		if bc:getZoneByName('Maymana Zahiraddin Faryabi').side ~= 2 then return false end
	return true
end
})
mc:trackMission({
	title = LTFormat("AF_MISSION_EWR_TITLE", "Chaghcharan"),
	description = LTFormat("AF_MISSION_EWR_DESC", "Chaghcharan", "41 S QU 64492 81853", "N 35°02'41\" E 65°53'58\"", "N 35°02.686' E 65°53.978'", "11051"),
	messageStart = LTFormat("AF_MISSION_EWR_START", "Chaghcharan"),
	messageEnd = LTFormat("AF_MISSION_EWR_END", "Chaghcharan"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["Red EWR Chaghcharan Fixed"] then return false end
    if ActiveMission['Red EWR Chaghcharan Fixed'] then return true end
	return false
	end,
})

-----------------------------------------------END EWRS - Chaghcharan -----------------------------------------------------------
----------------------------------------------- EWRS - Jamsheed -----------------------------------------------------------
evc:addEvent({
	id='Red EWR Jamsheed Fixed',
	action = function()
    RegisterGroupTarget('Red EWR Jamsheed Fixed',300,L10N:Format("AF_MISSION_EWR_TITLE", "Jamsheed SAM site"),'Red EWR Jamsheed Fixed',true)
	end,                                                                          
	canExecute = function()
        if CustomFlags["Red EWR Jamsheed Fixed"] then return false end
        if ActiveMission['Red EWR Jamsheed Fixed'] then return false end
		if not Group.getByName('Red EWR Jamsheed Fixed') then return false end
		if bc:getZoneByName('Chaghcharan').side ~= 2 then return false end
	return true
end
})
mc:trackMission({
	title = LTFormat("AF_MISSION_EWR_TITLE", "SAM Jamsheed"),
	description = LTFormat("AF_MISSION_EWR_DESC", "Jamsheed SAM Site", "41 S PT 75189 12172", "N 33°32'05\" E 64°53'12\"", "N 33°32.088' E 64°53.202'", "12668"),
	messageStart = LTFormat("AF_MISSION_EWR_START", "Jamsheed SAM site"),
	messageEnd = LTFormat("AF_MISSION_EWR_END", "Jamsheed SAM site"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["Red EWR Jamsheed Fixed"] then return false end
    if ActiveMission['Red EWR Jamsheed Fixed'] then return true end
	return false
	end,
})

-----------------------------------------------END EWRS - SAM Jamsheed -----------------------------------------------------------
----------------------------------------------- EWRS - Bagram -----------------------------------------------------------
evc:addEvent({
	id='Red EWR Bagram Fixed',
	action = function()
    RegisterGroupTarget('Red EWR Bagram Fixed',300,L10N:Format("AF_MISSION_EWR_TITLE", "Bagram"),'Red EWR Bagram Fixed',true)
	end,
	canExecute = function()
        if CustomFlags["Red EWR Bagram Fixed"] then return false end
        if ActiveMission['Red EWR Bagram Fixed'] then return false end
		if not Group.getByName('Red EWR Bagram Fixed') then return false end
		if bc:getZoneByName('Bamyan').side ~= 2 then return false end
	return true
end
})
mc:trackMission({
	title = LTFormat("AF_MISSION_EWR_TITLE", "Bagram"),
	description = LTFormat("AF_MISSION_EWR_DESC", "Bagram", "42 S WD 28839 64152", "N 34°55'09\" E 69°18'56\"", "N 34°55.165' E 69°18.944'", "4814"),
	messageStart = LTFormat("AF_MISSION_EWR_START", "Bagram"),
	messageEnd = LTFormat("AF_MISSION_EWR_END", "Bagram"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["Red EWR Bagram Fixed"] then return false end
    if ActiveMission['Red EWR Bagram Fixed'] then return true end
	return false
	end,
})

-----------------------------------------------END EWRS - Bagram-----------------------------------------------------------
----------------------------------------------- EWRS - Sharana -----------------------------------------------------------
evc:addEvent({
	id='Red EWR Sharana Fixed',
	action = function()
    RegisterGroupTarget('Red EWR Sharana Fixed',300,L10N:Format("AF_MISSION_EWR_TITLE", "Sharana"),'Red EWR Sharana Fixed',true)
	end,
	canExecute = function()
        if CustomFlags["Red EWR Sharana Fixed"] then return false end
        if ActiveMission['Red EWR Sharana Fixed'] then return false end
        if not Group.getByName('Red EWR Sharana Fixed') then return false end
		if bc:getZoneByName('Ghazni Heliport').side ~= 2 then return false end
	return true
end
})
mc:trackMission({
	title = LTFormat("AF_MISSION_EWR_TITLE", "Sharana"),
	description = LTFormat("AF_MISSION_EWR_DESC", "Sharana", "42 S WB 01484 67453", "N 33°08'44\" E 69°00'57\"", "N 33°08.749' E 69°00.955'", "9829"),
	messageStart = LTFormat("AF_MISSION_EWR_START", "Sharana"),
	messageEnd = LTFormat("AF_MISSION_EWR_END", "Sharana"),
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if CustomFlags["Red EWR Sharana Fixed"] then return false end
    if ActiveMission['Red EWR Sharana Fixed'] then return true end
	return false
	end,
})

-----------------------------------------------END EWRS - Sharana-----------------------------------------------------------
---------------------------------------------------- general missions -------------------------------------------------------

local EscortCooldown = 3600
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
		
			if bc:getZoneByName('Kandahar').side == 2 and not bc:getZoneByName('Kandahar').suspended then
				return true
			end

		
		return false
	end
})
mc:trackMission({
    title = LTGet("SYRIA_MISSION_ESCORT_CARGO_TITLE"),
    description = LTGet("AF_MISSION_ESCORT_CARGO_KANDAHAR_DESC"),
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
					'Sharana','FOB-Bostick','Checkpoint Charlie','FOB-Shank','Checkpoint Bravo','Tarinkot'}
					if Group.getByName('evt-bomber') then
						local bomber, bomberMission = StartBomberAuftrag('bomb', 'evt-bomber', tgts, escGrp)
				end
		end,{},timer.getTime()+1)
	end,
	canExecute=function()
        if ActiveMission['bomb'] then return false end
		if timer.getTime()-lastbomb_COOLDOWN<bomb_COOLDOWN then return false end
		if Group.getByName('evt-bomber') then return false end
        if bc:getZoneByName('Ghazni Heliport').side == 2 then return false end
		--if math.random(1,100)<70 then return false end
        local trg={'Tarinkot','Checkpoint Bravo','FOB-Shank'}
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
					'Herat','Shindand','Farah','FOB-Ahmad Shah Massoud', 'FOB-Ismail Khan', 'Qala i Naw', 'FOB-Hamid Karzai', 'Maymana Zahiraddin Faryabi', 'FOB-Delaram'}
					if Group.getByName('evt-bomber2') then
						local bomber2, bomber2mission = StartBomberAuftrag('bomb2', 'evt-bomber2', tgts, escGrp2)
					end
		end,{},timer.getTime()+1)
	end,
	canExecute=function()
        if ActiveMission['bomb2'] then return false end
		if timer.getTime()-lastbomb2_COOLDOWN<bomb2_COOLDOWN then return false end
		if Group.getByName('evt-bomber') then return false end
		if Group.getByName('evt-bomber2') then return false end
        if bc:getZoneByName('Qala i Naw').side == 2  then return false end

		--if math.random(1,100)<70 then return false end
			if bc:getZoneByName('Farah').side==2 and not bc:getZoneByName('Farah').suspended then return true end
		return false
	end
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_TITLE"),
	description = LTGet("AF_MISSION_INTERCEPT_BOMBERS_DESC_QALA"),
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

------------------------------------------------ Bomber 3 event ---------------------------------------------
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
					'Bayman','Chaghcharan','FOB-Javid Basharat','Kabul','Checkpoint Kabul E','Checkpoint Kabul W','Checkpoint Kabul S'}

				if Group.getByName('evt-bomber3') then
					local bomber3, bomber3mission = StartBomberAuftrag('bomb3', 'evt-bomber3', tgts, escGrp3)

				end
		end,{},timer.getTime()+1)
	end,
	canExecute=function()
        if ActiveMission['bomb3'] then return false end
		if timer.getTime()-lastbomb3_COOLDOWN<bomb3_COOLDOWN then return false end
		if Group.getByName('evt-bomber') then return false end
		if Group.getByName('evt-bomber2') then return false end
		if Group.getByName('evt-bomber3') then return false end
		--if math.random(1,100)<70 then return false end
        if bc:getZoneByName('FOB-Javid Basharat').side == 2 or bc:getZoneByName('Bagram').side == 2 then return false end
		return true
	end
})

mc:trackMission({
	title = LTGet("SYRIA_MISSION_INTERCEPT_BOMBERS_TITLE"),
	description = LTGet("AF_MISSION_INTERCEPT_BOMBERS_DESC_BAGRAM"),
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
			local tgts={'Tarinkot','Checkpoint Bravo','Tarinkot','FOB-Bostick','Sharana','Ghazni Heliport','FOB-Javid Basharat','Chaghcharan','FOB-Delaram','Gardez','Jalalabad','Bagram','Kabul',
						'Bamyan'}
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
		local triggers={'Tarinkot','Chaghcharan','Checkpoint Delta','Sharana'}
		if math.random(1,100)<70 then return false end
		for _,v in ipairs(triggers) do
			if bc:getZoneByName(v).side==2 and not bc:getZoneByName(v).suspended then return true end
		end
		return false
	end
})
mc:trackMission({
	title = LTGet("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"),
	description = LTGet("AF_MISSION_INTERCEPT_AIRSTRIKE_DESC_NE"),
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
--[[ local airstrike2_COOLDOWN = 1800
local lastairstrike2_COOLDOWN  = -airstrike2_COOLDOWN
local casGrp = Era=='Coldwar' and 'evt-CAScw2' or 'evt-CAS2'
Group.getByName('evt-CAS2'):destroy()
Group.getByName('evt-CAScw2'):destroy()
evc:addEvent({
	id='cas2',
	action=function()
		RespawnGroup(casGrp)
		RegisterGroupTarget(casGrp,500,L10N:Get("SYRIA_MISSION_INTERCEPT_AIRSTRIKE_TITLE"))
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
		local g1 = Group.getByName('evt-CAS2')
		local g2 = Group.getByName('evt-CAScw2')
		if g1 or g2 then
			return true
		else
			return false
		end
	end
})  ]]
-------------------------------------------- End of CAS 2 -----------------------------------------

----------------------------------------------- End of Associates -----------------------------------------------------------
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


-------------------------- WelcomeMessage statics ---------------------------------

airbaseStatics = {
["Checkpoint Alpha"] = {"Checkpoint Alphaammo", "Checkpoint Alphafuel", "Checkpoint Alphatent1", "Checkpoint Alphatent2", "Checkpoint Alphatent3", "Checkpoint Alphatent4", "Checkpoint Alphacommand", "Checkpoint Alphawind"},
["Checkpoint Bravo"] = {"Checkpoint Bravoammo", "Checkpoint Bravofuel", "Checkpoint Bravotent1", "Checkpoint Bravotent2", "Checkpoint Bravotent3", "Checkpoint Bravotent4", "Checkpoint Bravocommand", "Checkpoint Bravowind"},
["Checkpoint Charlie"] = {"Checkpoint Charlieammo", "Checkpoint Charliefuel", "Checkpoint Charlietent1", "Checkpoint Charlietent2", "Checkpoint Charlietent3", "Checkpoint Charlietent4", "Checkpoint Charliecommand", "Checkpoint Charliewind"},
["Checkpoint Delta"] = {"Checkpoint Deltaammo", "Checkpoint Deltafuel", "Checkpoint Deltatent1", "Checkpoint Deltatent2", "Checkpoint Deltatent3", "Checkpoint Deltatent4", "Checkpoint Deltacommand", "Checkpoint Deltawind"},
["Checkpoint Kabul W"] = {"Checkpoint Kabul Wammo", "Checkpoint Kabul Wfuel", "Checkpoint Kabul Wtent1", "Checkpoint Kabul Wtent2", "Checkpoint Kabul Wtent3", "Checkpoint Kabul Wtent4", "Checkpoint Kabul Wcommand", "Checkpoint Kabul Wwind"},
["Checkpoint Kabul S"] = {"Checkpoint Kabul Sammo", "Checkpoint Kabul Sfuel", "Checkpoint Kabul Stent1", "Checkpoint Kabul Stent2", "Checkpoint Kabul Stent3", "Checkpoint Kabul Stent4", "Checkpoint Kabul Scommand", "Checkpoint Kabul Swind"},
["Checkpoint Kabul E"] = {"Checkpoint Kabul Eammo", "Checkpoint Kabul Efuel", "Checkpoint Kabul Etent1", "Checkpoint Kabul Etent2", "Checkpoint Kabul Etent3", "Checkpoint Kabul Etent4", "Checkpoint Kabul Ecommand", "Checkpoint Kabul Ewind"},
["FOB Kunar"] = {"FOB Kunarammo", "FOB Kunarfuel", "FOB Kunartent1", "FOB Kunartent2", "FOB Kunartent3", "FOB Kunartent4", "FOB Kunarcommand", "FOB Kunarwind"},
["FOB-Jamsheed"] = {"FOB-Jamsheedammo", "FOB-Jamsheedfuel", "FOB-Jamsheedtent1", "FOB-Jamsheedtent2", "FOB-Jamsheedtent3", "FOB-Jamsheedtent4", "FOB-Jamsheedcommand", "FOB-Jamsheedwind"},
["FOB-Bostick"] = {"FOB-Bostickammo", "FOB-Bostickfuel", "FOB-Bosticktent1", "FOB-Bosticktent2", "FOB-Bosticktent3", "FOB-Bosticktent4", "FOB-Bostickcommand", "FOB-Bostickwind"},
["FOB-Lagman"] = {"FOB-Lagmanammo", "FOB-Lagmanfuel", "FOB-Lagmantent1", "FOB-Lagmantent2", "FOB-Lagmantent3", "FOB-Lagmantent4", "FOB-Lagmancommand", "FOB-Lagmanwind"},
["FOB-Shank"] = {"FOB-Shankammo", "FOB-Shankfuel", "FOB-Shanktent1", "FOB-Shanktent2", "FOB-Shanktent3", "FOB-Shanktent4", "FOB-Shankcommand", "FOB-Shankwind"},
["FOB-Javid Basharat"] = {"FOB-Javid Basharatammo", "FOB-Javid Basharatfuel", "FOB-Javid Basharattent1", "FOB-Javid Basharattent2", "FOB-Javid Basharattent3", "FOB-Javid Basharattent4", "FOB-Javid Basharatcommand", "FOB-Javid Basharatwind"},
["FOB-Hamid Karzai"] = {"FOB-Hamid Karzaiammo", "FOB-Hamid Karzaifuel", "FOB-Hamid Karzaitent1", "FOB-Hamid Karzaitent2", "FOB-Hamid Karzaitent3", "FOB-Hamid Karzaitent4", "FOB-Hamid Karzaicommand", "FOB-Hamid Karzaiwind"},
["FOB-Ismail Khan"] = {"FOB-Ismail Khanammo", "FOB-Ismail Khanfuel", "FOB-Ismail Khantent1", "FOB-Ismail Khantent2", "FOB-Ismail Khantent3", "FOB-Ismail Khantent4", "FOB-Ismail Khancommand", "FOB-Ismail Khanwind"},
["FOB-Ahmad Shah Massoud"] = {"FOB-Ahmad Shah Massoudammo", "FOB-Ahmad Shah Massoudfuel", "FOB-Ahmad Shah Massoudtent1", "FOB-Ahmad Shah Massoudtent2", "FOB-Ahmad Shah Massoudtent3", "FOB-Ahmad Shah Massoudtent4", "FOB-Ahmad Shah Massoudcommand", "FOB-Ahmad Shah Massoudwind"},
["FOB-Farid Basharat"] = {"FOB-Farid Basharatammo", "FOB-Farid Basharatfuel", "FOB-Farid Basharattent1", "FOB-Farid Basharattent2", "FOB-Farid Basharattent3", "FOB-Farid Basharattent4", "FOB-Farid Basharatcommand", "FOB-Farid Basharatwind"},
["FOB-Delaram"] = {"FOB-Delaramammo", "FOB-Delaramfuel", "FOB-Delaramtent1", "FOB-Delaramtent2", "FOB-Delaramtent3", "FOB-Delaramtent4", "FOB-Delaramcommand", "FOB-Delaramwind"},
["FOB-Fenty"] = {"FOB-Fentyammo", "FOB-Fentyfuel", "FOB-Fentytent1", "FOB-Fentytent2", "FOB-Fentytent3", "FOB-Fentytent4", "FOB-Fentycommand", "FOB-Fentywind"},
}


env.info("Mission Setup : is completed!")


