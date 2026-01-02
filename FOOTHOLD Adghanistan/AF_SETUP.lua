env.info("ZoneSetup: is loading.")

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
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group", "Red Armour Group 2", "Red SAM SA-3", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2", 
		}
    },
    airfield2 = {
        blue = { "blueInfantry", "blueInfantry", "bluePD 2", "blueArmor"},
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group", "Red Armour Group 2", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2", "Red SAM SHORAD Tor M2", 
		}
    },
    airfield3 = {
        blue = { "blueInfantry", "bSamIR", "bluePD 2", "blueArmor"},
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group", "Red Armour Group 2",  "Red SAM SA-6", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2",  "Red SAM SHORAD Pantsir S1"
		}
    },
    farp = {
        blue = { "blueInfantry", "blueArmor", "bSamIR"},
        red = { "Enemy ground forces", "Red SAM AAA", "Red SAM Dog Ear SA-19", "Red Armour Group 2", "Red Armour Group", "Red SAM AAA 3" }
    },
    checkpoints1 = {
        blue = { "blueArmor", "bSamIR"},
        red = { "Enemy ground forces", "Red SAM AAA 4", "Red SAM Dog Ear SA-19", "Red Armour Group", "Red SAM AAA 3" }
    },
    checkpoints2 = {
        blue = { "blueArmor", "bSamIR"},
        red = { "Enemy ground forces", "Enemy ground forces", "Red SAM SHORAD SA-13", "Red SAM AAA 3", "Red SAM AAA 4" }
    },
    checkpoints3 = {
        blue = { "blueArmor", "bSamIR"},
        red = { "Enemy ground forces", "Red SAM AAA", "Red SAM Dog Ear SA-8", "Red SAM Dog Ear SA-19", "Red SAM AAA 2" }
    },
    checkpoints4 = {
        blue = { "blueArmor", "bSamIR"},
        red = { "Enemy ground forces", "Red SAM AAA", "Red SAM Dog Ear SA-15", "Red SAM AAA 2", "Enemy ground forces"}
    },
    checkpoints5 = {
        blue = { "blueArmor", "blueInfantry"},
        red = { "Enemy ground forces", "Red SAM AAA", "Enemy ground forces", "Red SAM AAA 2" }
    },
    checkpoints6 = {
        blue = { "blueArmor", "blueInfantry"},
        red = { "Enemy ground forces", "Red SAM SHORAD SA-13", "Red SAM AAA 2", "Red SAM AAA" }
    },
    farp2 = {
        blue = { "blueInfantry", "blueArmor", "bSamIR"},
        red = { "Red SAM Dog Ear SA-8","Red SAM AAA", "Red Armour Group", "Red SAM Dog Ear SA-19", "Red Armour Group 2", "Red SAM SHORAD SA-19 2","Red SAM Dog Ear SA-15"}
    },
    farp3 = {
        blue = { "blueInfantry","blueInfantry", "blueArmor", "bluePD 2"},
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group","Red SAM Dog Ear SA-19", "Red SAM SHORAD SA-19 2","Red SAM AAA 3", "Red SAM AAA 4", "Red Armour Group 2", "Red SAM Dog Ear SA-15", "Red SAM SHORAD SA-15 2"}
    },
	HiddenSam1 = {
		blue = {},
		red = {'Red SAM SA-6', "Red SAM AAA", "Red SAM AAA",}
	},
	HiddenSam2 = {
		blue = {},
		red = {"Red SAM SHORAD SA-19 2", "Red SAM Dog Ear SA-8",}
	},
	HiddenSam3 = {
		blue = {},
		red = {'Red SAM SA-3', 'Red SAM Dog Ear SA-8', "Red SAM AAA", }
	},
	HiddenSam4 = {
		blue = {},
		red = {"Red SAM AAA", "Red SAM AAA 3", "Enemy ground forces",}
	},
	EWRMantisNet = {
		blue = {},
		red = {'Red EWR Camp Bastion Fixed', 'Red EWR Nimroz Fixed', 'Red EWR Jamsheed Fixed', 'Red EWR Chaghcharan Fixed', 'Red EWR Bagram Fixed','Red EWR Sharana Fixed','Red EWR Herat Fixed'}
	},
    convoy = {
        blue = { "blueInfantry" },
        red = { "Enemy ground forces","Red SAM AAA", "Red Armour Group 2", "Red SAM Dog Ear SA-19", "Red SAM SHORAD SA-19 2","Red Armour Group", "Red SAM Dog Ear SA-8" }
    },
	samfixedalpha = {
		blue = {},
		red = { 'Red Armour Group', 'Red SAM SA-6', 'Red Armour Group 2', 'Red SAM SHORAD SA-19 2', 'Red SAM SHORAD Pantsir S1',  'Red SAM SHORAD SA-15 2', 'Red SAM SA-10 Fixed Alpha'}
	},
	samfixedbravo = {
		blue = {},
		red = { 'Red Armour Group', 'Red SAM SA-6', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD SA-15 2', 'Red SAM SA-10 Fixed Bravo' }
	},
	samfixedcharlie = {
		blue = {},
		red = { 'Red Armour Group', 'Red SAM SA-6', 'Red Armour Group 2', 'Red SAM SHORAD Tor M2', 'Red SAM SHORAD SA-15 2', 'Red SAM SHORAD SA-15 2',  'Red SAM SA-10 Fixed Charlie' }
	},
	samfixeddelta = {
		blue = {},
		red = { 'Red Armour Group', 'Red SAM SA-6', 'Red Armour Group 2',  'Red SAM SHORAD SA-15 2', 'Red SAM SHORAD Pantsir S1',  'Red SAM SHORAD SA-15 2',  'Red SAM SA-10 Fixed Delta' }
	},	
	samjamsheed = {
		blue = {},
		red = { 'Red SAM SA15-Jamsheed IsNotShown-1', 'Red SAM SA-6 Jamsheed IsNotKnown', 'Red SAM SA-6 Jamsheed IsNotShown-2',  'Red SAM SA-2 Jamsheed IsNotShown', 'Red SAM SA-10 Fixed Jamsheed IsNotShown-1',  'Red SAM SA-18 Jamsheed IsNotShown-1',  'Red SAM SA-18 Jamsheed IsNotShown-2', 'Red SAM SA-18 Jamsheed IsNotShown-3', 'Red SAM SA-18 Jamsheed IsNotShown-4', 'Red SAM SA-18 Jamsheed IsNotShown-5','Red SAM SA-18 Jamsheed IsNotShown-6', 'Red SAM AAA Jamsheed IsNotShown', 'Red SAM AAA Jamsheed IsNotKnown-2' }
	},	
}

------------------------------------end upgrades section------------------------------------------
--------------------------------begin flavor section (this is what gives a hint or description of the zone to the player)-----------------------------------
flavor = {
    kandahar           	  = 'WPT 1\nKandahar\nMain hub for logistics and fixed-wing ops. Hold this and you hold the south.',
    alpha              	  = 'WPT 2\nCheckpoint Alpha\nFrontline staging area linking Kandahar to the central routes.',
    bost               	  = 'WPT 3\nBost\nHardpoint near Bastion. Shortens heli legs and protects the Dwyer route.',
    campbastion        	  = 'WPT 4\nCamp Bastion\nMajor coalition airfield. Your safest logistics chain starts here.',
    dwyer              	  = 'WPT 5\nDwyer\nForward strip linking Bost to Nimroz. If this falls, Nimroz gets isolated fast.',
    nimroz             	  = 'WPT 6\nNimroz\nDesert runway and logistics node. Keeps Farah supplied and the west alive.',
    farah              	  = 'WPT 7\nFarah\nForward runway on the west approach. Supplies here keep Shindand pressure constant.',
    shindand           	  = 'WPT 8\nShindand\nStrategic airbase between Farah and Herat. Perfect staging point for pushing west.',
    herat              	  = 'WPT 9\nHerat\nWestern anchor. Once captured, it opens the entire west corridor.',
    qalainaw           	  = 'WPT 10\nQala i Naw\nWestern connector. If this falls, the north-west becomes exposed.',
    maymanazahiraddin  	  = 'WPT 11\nMaymana Zahiraddin Faryabi\nNorthern outpost. Hold it to lock down the north-west corridor.',
    chaghcharan        	  = 'WPT 12\nChaghcharan\nMountain connector bridging Herat/QalaiNaw with Bamyan and the north-west.',
    bamyan             	  = 'WPT 13\nBamyan\nHigh-altitude route control linking the Kabul pocket to the western chain.',
    bagram             	  = 'WPT 14\nBagram\nStrategic military airbase north of Kabul.\nControls air dominance over the capital and central corridor.',
    kabul              	  = 'WPT 15\nKabul\nHigh-value capital node. Expect heavy resistance and constant pressure.',
    checkpointkabulw   	  = 'WPT 16\nCheckpoint Kabul W\nWestern checkpoint. Defensive choke on the capital approach.',
    kabulsouth         	  = 'WPT 17\nCheckpoint Kabul S\nSouthern approach into Kabul. Best place to stop pressure from Delta and Gardez.',
    checkpointkabule   	  = 'WPT 18\nCheckpoint Kabul E\nEastern checkpoint into Kabul. Main friction point for attacks from the hills.',
    fobkunar           	  = 'WPT 19\nFOB Kunar\nForward operating base in the east. Short-hop launches toward nearby hideouts.',
    jalalabad          	  = 'WPT 20\nJalalabad\nGateway to the east. Supplies here push the FOB Kunar line forward.',
    gardez             	  = 'WPT 21\nGardez\nSouthern Kabul approach. Great for supplies and patrols toward Jalalabad.',
    delta              	  = 'WPT 22\nCheckpoint Delta\nKabul ring gate. Control Delta to control access to Kabul and Bamyan.',
    ghazniheliport     	  = 'WPT 23\nGhazni Heliport\nRotary-wing hub controlling the midline between Charlie and Delta.',
    sharana            	  = 'WPT 24\nSharana\nMountain-side runway. Strong stepping stone between Charlie, Gardez, and Ghazni.',
    charlie            	  = 'WPT 25\nCheckpoint Charlie\nCentral crossroad. Pressure Tarinkot, Sharana, and Ghazni from here.',
    bravo              	  = 'WPT 26\nCheckpoint Bravo\nTraffic control point protecting the Kandahar ↔ Tarinkot corridor.',
    tarinkot           	  = 'WPT 27\nTarinkot\nKey runway in the central-south. Controls routes to Bravo/Charlie and the insurgent belt.',
    insurgentqalat        = 'Insurgent Base Qalat\nFortified stronghold. Clearing it reduces raids along the Bravo corridor.',
    insurgentdelaram      = 'Insurgent Base Delaram\nRoadside ambush hub. Leaving it alive threatens Bastion supply lines.',
    insurgentchimozay     = 'Insurgent Base Chimozay\nRural camp network used to harass Farah and the west route.',
    insurgentnili         = 'Insurgent Base Nili\nHidden valley base. Expect MANPADS/technicals in the high ground.',
    insurgentalpha        = 'Insurgent Base Alpha\nTraining compound. If ignored, Tarinkot stays contested.',
    insurgentqarabagh     = 'Insurgent Qarabagh\nUrban pocket and supply cache. Clearing it stabilizes the Charlie sector.',
    insurgentasadabad     = 'Insurgent Base Asadabad\nKunar foothills hideout. Hit it to stop pressure on FOB Kunar.',
    insurgentkunar        = 'Insurgent Base Kunar\nRiver valley camp. Frequent raids and reinforcements move through here.',
    insurgentsarobi       = 'Insurgent Base Sarobi\nStrongpoint east of Kabul. Clearing it reduces attacks on Kabul E.',
    insurgentmountain     = 'Insurgent Base Mountain\nMountain hideout network. Expect AAA/MANPADS and hard-to-find units.',
	faridbasharat   	  = 'FOB-Farid Basharat\nAbandoned forward operating base. Light fortifications remain. Capture to establish a new foothold.',
	ahmadshahmassoud 	  = 'FOB-Ahmad Shah Massoud\nFormer coalition FOB now abandoned. Minimal resistance expected. Capture to enable forward operations.',
	ismailkhan    		  = 'FOB-Ismail Khan\nDeserted FOB with aging infrastructure. Strategic location for regional control. Captureable.',
	hamidkarzai   		  = 'FOB-Hamid Karzai\nOnce a key logistics FOB, now abandoned. Securing it restores supply and helicopter access.',
	javidbasharat 		  = 'FOB-Javid Basharat\nRemote and abandoned FOB. Limited defenses remain. Capture to deny enemy staging ground.',
	shank         		  = 'FOB-Shank\nFormer major FOB now in disuse. Expect scattered enemy presence. Capture to reopen air and ground operations.',
	lagman        		  = 'FOB-Lagman\nAbandoned FOB in rugged terrain. Strategic overlook of surrounding routes. Captureable.',
	bostick       		  = 'FOB-Bostick\nOld border-region FOB left unmanned. Control of this site improves regional security.',
	delaram        		  = 'FOB-Delaram\nAbandoned FOB near key transit routes. Capture to reestablish forward presence and logistics.',
	jamsheed       		  = 'FOB-Jamsheed\nAbandoned FOB near key position and transit routes. Capture to reestablish forward presence and logistics.',
	samalpha			  = 'SAM Site Alpha\nSAM site outside of Farah. Take caution.',
	sambravo			  = 'SAM Site Bravo\nSAM site en route to Sharana. Take caution.',
	samcharlie			  = 'SAM Site Charlie\nSAM site west of Fob Hamid Karzai. Take caution.',
	--samdelta			  = 'SAM Site Delta\nSAM site to the west of Checkpoint Kabul W. Take caution.',
	samjamsheed			  = 'Jamsheed SAM Site\nThe legend of Jamsheed SAM site has been identified. Take extreme caution in this area.',
	urgoon				  = 'Urgoon Heliport\nAbandoned heliport that can be captured to advance warehouse logistics.',
	khost				  = 'Khost\nAbandoned airport that can be captured to advance warehouse logistics.',
	hidden				  = 'Hidden\nThis is hidden.',

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
	['Red SAM SA-10 Fixed Bravo']   = 'Red SAM SHORAD SA-8 2',
	['Red SAM SA-10 Fixed Alpha']   = 'Red SAM SHORAD SA-8 2',
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
------------------------begin coldwar swaps (this section swaps fixed assets for coldwar)-----------------------------
if Era == 'Coldwar' then
	deepSwap(upgrades,cwSwap)
end

local SamSwap = {
	['Red SAM SA-10 Fixed Bravo'] = 'Red SAM SA-2',
	['Red SAM SA-10 Fixed Alpha'] = 'Red SAM SA-2',
	['Red SAM SA-10'] = 'Red SAM SA-2',
	['Red SAM SA-11 Fixed Paregaan'] = 'Red SAM SA-2 Fixed Paregaan',
	['Red SAM SA-11 Fixed'] = 'Red SAM SA-2 Fixed',
	['Red SAM SA-11 Fixed Bandar'] = 'Red SAM SA-2 Fixed Bandar',
	['Red SAM SA-11 LAR Fixed'] = 'Red SAM SA-2 LAR Fixed',

	
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
----------------------------end coldwar fixed swaps -----------------------------------------
if NoSA10AndSA11 == true then
	deepSwapAgain(upgrades,SamSwap)
end

bc = BattleCommander:new(filepath, 10, 60)
if RankingSystem then
bc.rankFile = (lfs and (lfs.writedir()..'Missions/Saves/Foothold_Ranks.lua')) or 'Foothold_Ranks.lua'
env.info('Foothold - Rank file path: '..bc.rankFile)
end
Hunt = true
-----------------------------begin zone definitions(this is where a side is chosen and what flavor and upgrades each zone will have etc etc)-------------------------
zones = {
    kandahar            = ZoneCommander:new({zone='Kandahar',                    side=2, level=25, upgrades=upgrades.airfieldStart,    	crates={},flavorText=flavor.kandahar}),
    alpha               = ZoneCommander:new({zone='Checkpoint Alpha',            side=2, level=25, upgrades=upgrades.farp,             	crates={},flavorText=flavor.alpha}),
    bost                = ZoneCommander:new({zone='Bost',                        side=1, level=25, upgrades=upgrades.airfield2,          crates={},flavorText=flavor.bost}),
    campbastion         = ZoneCommander:new({zone='Camp Bastion',                side=1, level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.campbastion}),
    dwyer               = ZoneCommander:new({zone='Dwyer',                       side=1, level=25, upgrades=upgrades.airfield3,        	crates={},flavorText=flavor.dwyer}),
    bravo               = ZoneCommander:new({zone='Checkpoint Bravo',            side=1, level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.bravo}),
    tarinkot            = ZoneCommander:new({zone='Tarinkot',                    side=1, level=25, upgrades=upgrades.airfield3,        	crates={},flavorText=flavor.tarinkot}),
    insurgentqalat      = ZoneCommander:new({zone='Insurgent Base Qalat',        side=1, level=25, upgrades=upgrades.checkpoints6, 	    crates={},flavorText=flavor.insurgentqalat}),
    insurgentdelaram    = ZoneCommander:new({zone='Insurgent Base Delaram',      side=1, level=25, upgrades=upgrades.checkpoints1,     	crates={},flavorText=flavor.insurgentdelaram}),
    farah               = ZoneCommander:new({zone='Farah',                       side=1, level=25, upgrades=upgrades.airfield2,        	crates={},flavorText=flavor.farah}),
    insurgentchimozay   = ZoneCommander:new({zone='Insurgent Base Chimozay',     side=1, level=25, upgrades=upgrades.checkpoints5,     	crates={},flavorText=flavor.insurgentchimozay}),
    insurgentnili       = ZoneCommander:new({zone='Insurgent Base Nili',         side=1, level=25, upgrades=upgrades.checkpoints2,     	crates={},flavorText=flavor.insurgentnili}),
    insurgentalpha      = ZoneCommander:new({zone='Insurgent Base Alpha',        side=1, level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.insurgentalpha}),
    jamsheed            = ZoneCommander:new({zone='FOB-Jamsheed',                side=0, level=25, upgrades=upgrades.farp2,            	crates={},flavorText=flavor.jamsheed,ForceNeutral=true}),
    faridbasharat       = ZoneCommander:new({zone='FOB-Farid Basharat',          side=0, level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.faridbasharat,ForceNeutral=true}),      
    ahmadshahmassoud    = ZoneCommander:new({zone='FOB-Ahmad Shah Massoud',      side=0, level=25, upgrades=upgrades.farp2,            	crates={},flavorText=flavor.ahmadshahmassoud,ForceNeutral=true}),
    ismailkhan          = ZoneCommander:new({zone='FOB-Ismail Khan',             side=0, level=25, upgrades=upgrades.farp3,            	crates={},flavorText=flavor.ismailkhan,ForceNeutral=true}),	
    hamidkarzai         = ZoneCommander:new({zone='FOB-Hamid Karzai',            side=0, level=25, upgrades=upgrades.farp2,            	crates={},flavorText=flavor.hamidkarzai,ForceNeutral=true}),	
    javidbasharat       = ZoneCommander:new({zone='FOB-Javid Basharat',          side=0, level=25, upgrades=upgrades.farp3,             crates={},flavorText=flavor.javidbasharat,ForceNeutral=true}),
    shank               = ZoneCommander:new({zone='FOB-Shank',                   side=0, level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.shank,ForceNeutral=true}),
    lagman              = ZoneCommander:new({zone='FOB-Lagman',                  side=0, level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.lagman,ForceNeutral=true}),
    bostick             = ZoneCommander:new({zone='FOB-Bostick',                 side=0, level=25, upgrades=upgrades.farp2,            	crates={},flavorText=flavor.bostick,ForceNeutral=true}),
    delaram             = ZoneCommander:new({zone='FOB-Delaram',                 side=0, level=25, upgrades=upgrades.farp3,            	crates={},flavorText=flavor.delaram,ForceNeutral=true}),	
	khost               = ZoneCommander:new({zone='Khost',                       side=0, level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.khost,ForceNeutral=true}),	
	urgoon              = ZoneCommander:new({zone='Urgoon Heliport',             side=0, level=25, upgrades=upgrades.farp,            	crates={},flavorText=flavor.urgoon,ForceNeutral=true}),		
    charlie             = ZoneCommander:new({zone='Checkpoint Charlie',          side=1, level=25, upgrades=upgrades.farp2,            	crates={},flavorText=flavor.charlie}),
    insurgentqarabagh   = ZoneCommander:new({zone='Insurgent Qarabagh',          side=1, level=25, upgrades=upgrades.checkpoints2,     	crates={},flavorText=flavor.insurgentqarabagh}),
    ghazniheliport      = ZoneCommander:new({zone='Ghazni Heliport',             side=1, level=25, upgrades=upgrades.airfield,          crates={},flavorText=flavor.ghazniheliport}),
    sharana             = ZoneCommander:new({zone='Sharana',                     side=1, level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.sharana}),
    gardez              = ZoneCommander:new({zone='Gardez',                      side=1, level=25, upgrades=upgrades.airfield2,        	crates={},flavorText=flavor.gardez}),
    delta               = ZoneCommander:new({zone='Checkpoint Delta',            side=1, level=25, upgrades=upgrades.checkpoints4,      crates={},flavorText=flavor.delta}),
    kabulsouth          = ZoneCommander:new({zone='Checkpoint Kabul S',          side=1, level=25, upgrades=upgrades.checkpoints3,      crates={},flavorText=flavor.kabulsouth}),
    insurgentasadabad   = ZoneCommander:new({zone='Insurgent Base Asadabad',     side=1, level=25, upgrades=upgrades.checkpoints5,      crates={},flavorText=flavor.insurgentasadabad}),
    insurgentkunar      = ZoneCommander:new({zone='Insurgent Base Kunar',        side=1, level=25, upgrades=upgrades.farp,        		crates={},flavorText=flavor.insurgentkunar}),
    fobkunar            = ZoneCommander:new({zone='FOB Kunar',                   side=1, level=25, upgrades=upgrades.farp2,        		crates={},flavorText=flavor.fobkunar}),
    jalalabad           = ZoneCommander:new({zone='Jalalabad',                   side=1, level=25, upgrades=upgrades.airfield3,        	crates={},flavorText=flavor.jalalabad}),
    insurgentsarobi     = ZoneCommander:new({zone='Insurgent Base Sarobi',       side=1, level=25, upgrades=upgrades.checkpoints6,     	crates={},flavorText=flavor.insurgentsarobi}),
    insurgentmountain   = ZoneCommander:new({zone='Insurgent Base Mountain',     side=1, level=25, upgrades=upgrades.checkpoints2,      crates={},flavorText=flavor.insurgentmountain}),
    checkpointkabule    = ZoneCommander:new({zone='Checkpoint Kabul E',          side=1, level=25, upgrades=upgrades.checkpoints2,      crates={},flavorText=flavor.checkpointkabule}),
    kabul               = ZoneCommander:new({zone='Kabul',                       side=1, level=25, upgrades=upgrades.airfield3,        	crates={},flavorText=flavor.kabul}),
    checkpointkabulw    = ZoneCommander:new({zone='Checkpoint Kabul W',          side=1, level=25, upgrades=upgrades.checkpoints1,      crates={},flavorText=flavor.checkpointkabulw}),
	nimroz              = ZoneCommander:new({zone='Nimroz',                      side=1, level=25, upgrades=upgrades.airfield2,         crates={},flavorText=flavor.nimroz}),
    shindand            = ZoneCommander:new({zone='Shindand',                    side=1, level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.shindand}),
    herat               = ZoneCommander:new({zone='Herat',                       side=1, level=25, upgrades=upgrades.airfield2,        	crates={},flavorText=flavor.herat}),
    bamyan              = ZoneCommander:new({zone='Bamyan',                      side=1, level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.bamyan}),
    chaghcharan         = ZoneCommander:new({zone='Chaghcharan',                 side=1, level=25, upgrades=upgrades.airfield3,        	crates={},flavorText=flavor.chaghcharan}),
    qalainaw            = ZoneCommander:new({zone='Qala i Naw',                  side=1, level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.qalainaw}),
    maymanazahiraddin   = ZoneCommander:new({zone='Maymana Zahiraddin Faryabi',  side=1, level=25, upgrades=upgrades.airfield2,        	crates={},flavorText=flavor.maymanazahiraddin}),
	bagram				= ZoneCommander:new({zone='Bagram',  					 side=1, level=25, upgrades=upgrades.airfield,        	crates={},flavorText=flavor.bagram}),
 	hidden1				= ZoneCommander:new({zone='Hidden',        			     side=1, level=25, upgrades=upgrades.HiddenSam1,        crates={},flavorText=flavor.hidden}),
	hidden2				= ZoneCommander:new({zone='Hidden2',        			 side=1, level=25, upgrades=upgrades.HiddenSam2,        crates={},flavorText=flavor.hidden}),
	hidden3				= ZoneCommander:new({zone='Hidden3',        			 side=1, level=25, upgrades=upgrades.HiddenSam3,        crates={},flavorText=flavor.hidden}),
	hidden4				= ZoneCommander:new({zone='Hidden4',        			 side=1, level=25, upgrades=upgrades.HiddenSam4,        crates={},flavorText=flavor.hidden}),
	hiddenewr			= ZoneCommander:new({zone='HiddenEWR',        			 side=1, level=25, upgrades=upgrades.EWRMantisNet,      crates={},flavorText=flavor.hidden}),
	samalpha			= ZoneCommander:new({zone='SAM Site Alpha',        		 side=1, level=25, upgrades=upgrades.samfixedalpha,     crates={},flavorText=flavor.samalpha}),
	sambravo			= ZoneCommander:new({zone='SAM Site Bravo',        		 side=1, level=25, upgrades=upgrades.samfixedbravo,     crates={},flavorText=flavor.sambravo}),
	samcharlie			= ZoneCommander:new({zone='SAM Site Charlie',        	 side=1, level=25, upgrades=upgrades.samfixedcharlie,   crates={},flavorText=flavor.samcharlie}),
	--samdelta			= ZoneCommander:new({zone='SAM Site Delta',        		 side=1, level=25, upgrades=upgrades.samfixeddelta,     crates={},flavorText=flavor.samdelta}),
	samjamsheed			= ZoneCommander:new({zone='Jamsheed SAM Site',        	 side=1, level=25, upgrades=upgrades.samjamsheed,     	crates={},flavorText=flavor.samjamsheed}),
}
----------------------end zone definitions-----------------------------
---------------------------------begin template definitions (this defines templates for coldwar and modern)-----------------------
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
        'RED_JF17_TWOSHIP_CAP',
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
		"C-130J-30",
}
SupplyConvoy = SupplyConvoy or {
    "SupplyConvoy 1",
    "SupplyConvoy 2",
    "SupplyConvoy 3",
}

InsurgentConvoy = InsurgentConvoy or {
    
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
    GroupCommander:new({name='CheckpointKabulE-attack-Kabul', mission='attack', targetzone='Kabul', type='surface'}),
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
    GroupCommander:new({name='CheckpointDelta-attack-GhazniHeliport', mission='attack', targetzone='Ghazni Heliport', type='surface'}),
})

-- Checkpoint Charlie (Checkpoint) -> connects to: Tarinkot, Checkpoint Bravo, Sharana, Ghazni Heliport
zones.charlie:addGroups({

    GroupCommander:new({name='charlie-supply-Tarinkot-helo',        mission='supply', template='HeloSupplyTemplate', targetzone='Tarinkot'}),
    GroupCommander:new({name='charlie-supply-CheckpointBravo-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Checkpoint Bravo'}),
    GroupCommander:new({name='charlie-supply-Sharana-helo',         mission='supply', template='HeloSupplyTemplate', targetzone='Sharana'}),
    GroupCommander:new({name='charlie-supply-GhazniHeliport-helo',  mission='supply', template='HeloSupplyTemplate', targetzone='Ghazni Heliport'}),

    -- Surface attack routes
    GroupCommander:new({name='CheckpointCharlie-attack-FOB-Bostick', mission='attack', targetzone='FOB-Bostick', type='surface'}),
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
    GroupCommander:new({name='CheckpointBravo-attack-Tarinkot', mission='attack', targetzone='Tarinkot', type='surface'}),
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
    GroupCommander:new({name='kabul-supply-Bamyan-plane',                   mission='supply', template='PlaneSupplyTemplate', targetzone='Bamyan'}),
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

    GroupCommander:new({name='dwyer-supply-Nimroz-plane',      mission='supply', template='PlaneSupplyTemplate', targetzone='Nimroz'}),

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
    GroupCommander:new({name='Shindand-attack-Herat', mission='attack', targetzone='Herat', type='surface'}),
    GroupCommander:new({name='Shindand-attack-FOB-AhmadShahMassoud', mission='attack', targetzone='FOB-Ahmad Shah Massoud', type='surface'}),
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
    GroupCommander:new({name='Herat-attack-Shindand', mission='attack', targetzone='Shindand', type='surface'}),
})

-- QALA I NAW (airport) -> connects to: Herat, Maymana Zahiraddin Faryabi
zones.qalainaw:addGroups({
    GroupCommander:new({name='qalainaw-supply-Herat-helo',   mission='supply', template='HeloSupplyTemplate', targetzone='Herat'}),
    GroupCommander:new({name='qalainaw-supply-Maymana-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Maymana Zahiraddin Faryabi'}),
    GroupCommander:new({name='qalainaw-supply-Herat-helo', mission='supply', template='HeloSupplyTemplate', targetzone='Herat'}),

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
	GroupCommander:new({name='Maymana-attack-FOBHamidKarzai', mission='attack', targetzone='FOB-Hamid Karzai', type='surface'}),
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
    GroupCommander:new({name='Chaghcharan-attack-FOBDelaram',  mission='attack', targetzone='FOB-Delaram', type='surface'}),
})

-- BAMYAN (airport) -> connects to: Chaghcharan, Kabul, Bagram
zones.bamyan:addGroups({
    GroupCommander:new({name='bamyan-supply-Kabul-helo',mission='supply', template='HeloSupplyTemplate', targetzone='Kabul'}),

    GroupCommander:new({name='bamyan-supply-Bagram-plane', mission='supply', template='PlaneSupplyTemplate', targetzone='Bagram'}),

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
    GroupCommander:new({name='Bamyan-attack-FOB-JavidBasharat',  mission='attack', targetzone='FOB-Javid Basharat',  type='surface'}),
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
    GroupCommander:new({name='Bagram-attack-Kabul',  mission='attack', targetzone='Kabul',  type='surface'}),
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

zones.khost.airbaseName = 'Khost'

zones.urgoon.airbaseName = 'Urgoon Heliport'

--
--------------------------------------------end Airbase definitions------------------------
for i,v in pairs(zones) do
	bc:addZone(v)
end

---------------------------Begin connections (this is what draws lines between each point--------------------------
bc:addConnection("Kandahar","Checkpoint Alpha")
bc:addConnection("Checkpoint Alpha","Kandahar")

bc:addConnection("Checkpoint Alpha","Bost")
bc:addConnection("Bost","Checkpoint Alpha")

bc:addConnection("Checkpoint Alpha","Camp Bastion")
bc:addConnection("Camp Bastion","Checkpoint Alpha")

bc:addConnection("Checkpoint Alpha","Tarinkot")
bc:addConnection("Tarinkot","Checkpoint Alpha")

bc:addConnection("Camp Bastion","Nimroz")
bc:addConnection("Nimroz","Camp Bastion")

bc:addConnection("Camp Bastion","Dwyer")
bc:addConnection("Dwyer","Camp Bastion")

bc:addConnection("Bost","Dwyer")
bc:addConnection("Dwyer","Bost")

bc:addConnection("Bost","Camp Bastion")
bc:addConnection("Camp Bastion","Bost")

bc:addConnection("Kandahar","Checkpoint Bravo")
bc:addConnection("Checkpoint Bravo","Kandahar")

bc:addConnection("Kandahar","Tarinkot")
bc:addConnection("Tarinkot","Kandahar")

bc:addConnection("Checkpoint Bravo","Tarinkot")
bc:addConnection("Tarinkot","Checkpoint Bravo")

bc:addConnection("Checkpoint Bravo","Checkpoint Charlie")
bc:addConnection("Checkpoint Charlie","Checkpoint Bravo")

bc:addConnection("Tarinkot","Checkpoint Charlie")
bc:addConnection("Checkpoint Charlie","Tarinkot")

bc:addConnection("Checkpoint Charlie","Sharana")
bc:addConnection("Sharana","Checkpoint Charlie")

bc:addConnection("Checkpoint Charlie","Ghazni Heliport")
bc:addConnection("Ghazni Heliport","Checkpoint Charlie")

bc:addConnection("Sharana","Ghazni Heliport")
bc:addConnection("Ghazni Heliport","Sharana")

bc:addConnection("Sharana","Gardez")
bc:addConnection("Gardez","Sharana")

bc:addConnection("Ghazni Heliport","Gardez")
bc:addConnection("Gardez","Ghazni Heliport")

bc:addConnection("Ghazni Heliport","Checkpoint Delta")
bc:addConnection("Checkpoint Delta","Ghazni Heliport")

bc:addConnection("Checkpoint Delta","Checkpoint Kabul S")
bc:addConnection("Checkpoint Kabul S","Checkpoint Delta")

bc:addConnection("Checkpoint Delta","Checkpoint Kabul W")
bc:addConnection("Checkpoint Kabul W","Checkpoint Delta")

bc:addConnection("Checkpoint Delta","Kabul")
bc:addConnection("Kabul","Checkpoint Delta")

bc:addConnection("Checkpoint Delta","Bamyan")
bc:addConnection("Bamyan","Checkpoint Delta")

bc:addConnection("Farah","Shindand")
bc:addConnection("Shindand","Farah")

bc:addConnection("Shindand","Herat")
bc:addConnection("Herat","Shindand")

bc:addConnection("Herat","Chaghcharan")
bc:addConnection("Chaghcharan","Herat")

bc:addConnection("Herat","Qala i Naw")
bc:addConnection("Qala i Naw","Herat")

bc:addConnection("Qala i Naw","Maymana Zahiraddin Faryabi")
bc:addConnection("Maymana Zahiraddin Faryabi","Qala i Naw")

bc:addConnection("Qala i Naw","Chaghcharan")
bc:addConnection("Chaghcharan","Qala i Naw")

bc:addConnection("Chaghcharan","Maymana Zahiraddin Faryabi")
bc:addConnection("Maymana Zahiraddin Faryabi","Chaghcharan")

bc:addConnection("Chaghcharan","Bamyan")
bc:addConnection("Bamyan","Chaghcharan")

bc:addConnection("Bamyan","Kabul")
bc:addConnection("Kabul","Bamyan")

bc:addConnection("Bamyan","Bagram")
bc:addConnection("Bagram","Bamyan")

bc:addConnection("Kabul","Bagram")
bc:addConnection("Bagram","Kabul")

bc:addConnection("Kabul","Checkpoint Kabul E")
bc:addConnection("Checkpoint Kabul E","Kabul")

bc:addConnection("Bagram","Checkpoint Kabul E")
bc:addConnection("Checkpoint Kabul E","Bagram")

bc:addConnection("Checkpoint Kabul E","Jalalabad")
bc:addConnection("Jalalabad","Checkpoint Kabul E")

bc:addConnection("Kabul","Checkpoint Kabul W")
bc:addConnection("Checkpoint Kabul W","Kabul")

bc:addConnection("Bagram","Checkpoint Kabul W")
bc:addConnection("Checkpoint Kabul W","Bagram")

bc:addConnection("Kabul","Checkpoint Kabul S")
bc:addConnection("Checkpoint Kabul S","Kabul")

bc:addConnection("Checkpoint Kabul S","Checkpoint Kabul E")
bc:addConnection("Checkpoint Kabul E","Checkpoint Kabul S")

bc:addConnection("Dwyer","Nimroz")
bc:addConnection("Nimroz","Dwyer")

bc:addConnection("Nimroz","Farah")
bc:addConnection("Farah","Nimroz")

bc:addConnection("Gardez","Jalalabad")
bc:addConnection("Jalalabad","Gardez")

bc:addConnection("Gardez","Checkpoint Kabul S")
bc:addConnection("Checkpoint Kabul S","Gardez")

bc:addConnection("Jalalabad","FOB Kunar")
bc:addConnection("FOB Kunar","Jalalabad")

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
		"Red SAM Dog Ear SA-15 2 #",
		"Red SAM SHORAD SA-8 2 #",
		"Red SAM SHORAD SA-19 2 #",
		"Red SAM SHORAD Tor M2 #",
	}, 30)
else
	bc:roamGroupsToLocalSubZone({
		"Red Armour Group #",
        "Red Armour Group 2 #",
		"Red SAM AAA #",
		"Red SAM SHORAD SA-15 2 #",
		"Red SAM SHORAD SA-8 2 #",
		"Red SAM Dog Ear SA-19",
	}, 30)
end
end,{},5,0)

-- SHOP --
local upgradeMenu = nil
bc:registerShopItem('supplies2', 'Resupply friendly Zone', 200, function(sender)
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


local smokeTargetMenu = nil
bc:registerShopItem('smoke', 'Smoke markers ', 20, function(sender)
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
---
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
bc:registerShopItem('zinf','Add infantry squad to zone',500,function(sender)
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
	if params.zone and params.zone.side==2 then
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
            local slot = (Era == 'Coldwar') and 'bluePD Coldwar' or 'bluePD1'
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
		params.zone:addExtraSlot((Era == 'Coldwar') and 'bluePD Coldwar' or 'bluePD1')
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
	if params.zone and params.zone.side==2 then
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
bc:addShopItem(2, 'zinf', -1, 16, 5) -- add infantry to a zone
bc:addShopItem(2, 'zarm', -1, 17, 7) -- add armour group to a zone
bc:addShopItem(2, 'zlogc', -1, 18, 1) -- upgrade zone to logistic center
bc:addShopItem(2, 'zwh50', -1, 18, 2) -- resupply warehouse with 50
bc:addShopItem(2, 'zsam', -1, 18, 6) -- add Nasams to a zone
bc:addShopItem(2, 'gslot', 1, 19, 9) -- add another slot for upgrade
if Era == 'Modern' then
    bc:addShopItem(2, 'zpat', -1, 20, 8) -- Patriot system.
end
bc:addShopItem(2, 'armor', -1, 21, 3) -- combined arms
bc:addShopItem(2, 'artillery', -1, 22, 3) -- combined arms
bc:addShopItem(2, 'recon', -1, 23, 3) -- combined arms
bc:addShopItem(2, 'airdef', -1, 24, 3) -- combined arms
bc:addShopItem(2, '9lineam', -1, 25, 1) -- free jtac
bc:addShopItem(2, '9linefm', -1, 26, 1) -- free jtac


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
	trigger.action.outTextForCoalition(2,'Enemies at Insurgent Qalat have been defeated.\n+500 credits',20)
end, 'disablesinsurgentqalat')


zones.insurgentdelaram:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at Insurgent Delaram have been defeated.\n+500 credits',20)
end, 'disablesinsurgentdelaram')


zones.insurgentchimozay:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at Insurgent Chimozay have been defeated.\n+500 credits',20)
end, 'disableinsurgentchimozay')


zones.insurgentnili:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at Insurgent Nili have been defeated.\n+500 credits',20)
end, 'disableinsurgentnili')


zones.insurgentalpha:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at Insurgent Alpha have been defeated.\n+500 credits',20)
end, 'disableinsurgentalpha')


zones.insurgentqarabagh:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at Insurgent Qarabagh have been defeated.\n+500 credits',20)
end, 'disableinsurgentqarabagh')


zones.insurgentasadabad:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at Insurgent Asadabad have been defeated.\n+500 credits',20)
end, 'disableinsurgentasadabad')


zones.insurgentkunar:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at Insurgent Kunar have been defeated.\n+500 credits',20)
end, 'disableinsurgentkunar')


zones.insurgentsarobi:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at Insurgent Sarobi have been defeated.\n+500 credits',20)
end, 'disableinsurgentsarobi')


zones.insurgentmountain:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at Insurgent Mountain have been defeated.\n+500 credits',20)
end, 'disableinsurgentmountain')
zones.samalpha:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at SAM Alpha have been defeated.\n+500 credits',20)
end, 'disablesamalpha')
zones.sambravo:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at SAM Bravo have been defeated.\n+500 credits',20)
end, 'disablesambravo')
zones.samcharlie:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at SAM Charlie Mountain have been defeated.\n+500 credits',20)
end, 'disablesamcharlie')
zones.samjamsheed:registerTrigger('lost', function(event, sender)
	sender:disableZone()
	bc:addFunds(2,500)
	trigger.action.outTextForCoalition(2,'Enemies at SAM Jamsheed have been defeated.\n+500 credits',20)
end, 'disablesamjamsheed')

lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()

bc:loadFromDisk()
bc:init()
bc:startRewardPlayerContribution(15,{infantry = 10, ground = 10, sam = 30, airplane = 30, ship = 200, helicopter=30, crate=100, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, ['CAP mission'] = true, ['CAS mission'] = true})
HercCargoDropSupply.init(bc)
bc:buildZoneDistanceCache()
buildTemplateCache()
buildSubZoneRoadCache()
bc:buildConnectionMap()
DynamicConvoy.InitTargetTails(5)
DynamicConvoy.InitRoadPathCacheFromCommanders(GroupCommanders)
PrecomputeLandingSpots()
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

GlobalSettings.autoSuspendNmBlue = 100   		-- suspend blue zones deeper than this nm
GlobalSettings.autoSuspendNmRed = 120   		-- suspend red zones deeper than this nm

evc = EventCommander:new({ decissionFrequency=10*60, decissionVariance=10*60, skipChance = 10})
evc:init()

mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})
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


-------------------------------- Destroy artillery --------------------------------

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted south of FOB-Delaram headed to FOB-Delaram.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Chaghcharan-attack-FOBDelaram',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('Chaghcharan-attack-FOBDelaram')
        if gr then return true else return false end
    end
})

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards FOB-Hamid Karzai from the direction of Maymana.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Maymana-attack-FOBHamidKarzai',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('Maymana-attack-FOBHamidKarzai')
        if gr then return true else return false end
    end
})

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards Herat from the direction of Shindand.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Shindand-attack-Herat',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('Shindand-attack-Herat')
        if gr then return true else return false end
    end
})

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards Shindand from the direction of Herat.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Herat-attack-Shindand',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('Herat-attack-Shindand')
        if gr then return true else return false end
    end
})

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards FOB-Ahmad from the direction of Shindand.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Shindand-attack-FOB-AhmadShahMassoud',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('Shindand-attack-FOB-AhmadShahMassoud')
        if gr then return true else return false end
    end
})

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards FOB-Ahmad from the direction of Shindand.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Bamyan-attack-FOB-JavidBasharat',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('Bamyan-attack-FOB-JavidBasharat')
        if gr then return true else return false end
    end
})

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards Kabul from the direction of Bagram.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('Bagram-attack-Kabul',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('Bagram-attack-Kabul')
        if gr then return true else return false end
    end
})

mc:trackMission({
    title = "Destroy artillery",
    description = "Artillery has been spotted heading towards Ghazni Heliport from the direction of Checkpoint Delta.\nDestroy them before they get in range.",
    messageStart = "New mission: Destroy artillery",
    messageEnd = "Mission ended: Destroy artillery",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
		RegisterGroupTarget('CheckpointDelta-attack-GhazniHeliport',100,'Destroy artillery')
    end,
    endAction = function()
    end,
    isActive = function()
        local gr = Group.getByName('CheckpointDelta-attack-GhazniHeliport')
        if gr then return true else return false end
    end
})
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
    trigger.action.outText(name .. ' is missing', 30)
  end
end
end, {}, timer.getTime() + 1)

-----------------------------------------------------------------------------------------------------------




----------------------------------------------- BostBuilding-----------------------------------------------
evc:addEvent({
	id = 'BostBuilding',
	action = function()
		local tgt = sceneryList['BostBuilding'][1] or SCENERY:FindByZoneName('BostBuilding')
		if not tgt then
			trigger.action.outText('BostBuilding is missing',30)
			return
		end
		RegisterScoreTarget('BostBuilding',tgt,500,'Strike known Bin Laden location')
		ActiveMission['BostBuilding'] = true
		local p = tgt:GetDCSObject() and tgt:GetDCSObject():getPoint()
		if p then
			missionMarkId = missionMarkId + 1
			trigger.action.markToCoalition(missionMarkId,"Strike known Bin Laden location",p,2,false,false)
			MissionMarks['BostBuilding'] = missionMarkId
		end
	end,
	canExecute = function()
	if ActiveMission['BostBuilding'] then return false end
	if CustomFlags["BostBuilding"] then return false end
	--if bc:getZoneByName('Bost').side == 2 then return false end
	return true
	end,
})

mc:trackMission({
	title = "Strike on enemy hideout",
	description =
[[We have intel on a building where Bin Laden might be held up at. 
Intel states that he might be in the city of Bost, just near the airport.
We shouldn't take any chances and we need to act fast, blow that building up!

Reward: 500

MGRS: 41 R PQ 31519 95368
Lat long: N 31°35'09" E 64°23'10"
Lat long Precise: N 31°35'09.18" E 64°23'10.11"
Lat long Decimal Minutes: N 31°35.153' E 64°23.168'
Elevation 2550 feet]],
	messageStart = "New strike mission: Strike known Bin Laden location",
	messageEnd = "Strike mission ended: Strike known Bin Laden location",
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
---------------------------------------------- Capture 1 ------------------------------------------------------
mc:trackMission({
	title = "Capture this zone",
	description =
[[Capture this zone]],
	messageStart = "New Capture mission: Special forces need to capture this zone",
	messageEnd = "Strike mission ended: Capture this zone",
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
    if bc:getZoneByName('Gardez').side == 2 and bc:getZoneByName('Khost').side == 0 then return true end
	return false
	end
})

---------------------------------------------- End of Capture 1 ------------------------------------------------------
----------------------------------------------- Associates -----------------------------------------------------------
Group.getByName('Associates'):destroy()
Group.getByName('AssociatesConvoy'):destroy()
evc:addEvent({
	id='Associates',
	action = function()
	RespawnGroup('Associates')
	RegisterGroupTarget('Associates',500,'Kill the Associates','Associates')
	end,
	canExecute = function()
		--if math.random(1,100) < 70 then return false end
		if Group.getByName('Associates') then return false end
		if CustomFlags["Associates"] then return false end
		local Shindand =  bc:getZoneByName('Shindand')
		if Shindand.side ~= 2 then return false end
	return true
end
})
mc:trackMission({
	title = "Strike the Associates",
	description =
[[A known Associate has been found 70 NM east of Shindand.

Eliminate them before they can cause more trouble.

Reward: 500

MGRS: 41 S NS 65579 97245
Lat long: N 33°24'45" E 63°42'19"
Lat long Decimal Minutes: N 33°24.752' E 63°42.318'

Elevation 6973 feet]],
	messageStart = "New strike mission: Strike the Associates",
	messageEnd = "Strike mission ended: Strike the Associates",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
        RespawnGroup('AssociatesConvoy')
        trigger.action.outTextForCoalition(2,'One of the Associates is fleeing!! Kill them before they run away',30)
	end,
	isActive = function()
	if CustomFlags["Associates"] then return false end
	if IsGroupActive('Associates') then return true end
	return false
	end,
})



evc:addEvent({
	id='Associates',
	action = function()
	RegisterGroupTarget('AssociatesConvoy',500,'Hunt the associates Convoy','AssociatesConvoy')
	end,
	canExecute = function()
		--if math.random(1,100) < 70 then return false end
		if Group.getByName('AssociatesConvoy') then return false end
		if not CustomFlags["Associates"] then return false end
        if CustomFlags["AssociatesConvoy"] then return false end
	return true
end
})
mc:trackMission({
	title = "Hunt the associates Convoy",
	description =
[[]],
	messageStart = "New strike mission: hunt the Associates convoy!!!!",
	messageEnd = "Strike mission ended: hunt the Associates convoy",
    startAction = function()
         if not missionCompleted and trigger.misc.getUserFlag(180) == 0 then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
    endAction = function()
	end,
	isActive = function()
	if IsGroupActive('AssociatesConvoy') then return true end
	return false
	end,
})

---------------------------------------------------- general missions -------------------------------------------------------

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
		
			if bc:getZoneByName('Kandahar').side == 2 and not bc:getZoneByName('Kandahar').suspended then
				return true
			end

		
		return false
	end
})
mc:trackMission({
    title = "Escort cargo plane",
    description = "Friendly cargo plane is taking off from Kandahar. Protect it until it leaves the airspace.",
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
					'Sharana','FOB-Bostick','Checkpoint Charlie','FOB-Shank','Checkpoint Bravo','Tarinkot'}
					if Group.getByName('evt-bomber') then
						local bomber, bomberMission = StartBomberAuftrag('bomb', 'evt-bomber', tgts, escGrp)
				end
		end,{},timer.getTime()+1)
	end,
	canExecute=function()
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
					'Herat','Shindand','Farah','FOB-Ahmad Shah Massoud', 'FOB-Ismail Khan', 'Qala i Naw', 'FOB-Hamid Karzai', 'Maymana Zahiraddin Faryabi', 'FOB-Delaram'}
					if Group.getByName('evt-bomber2') then
						local bomber2, bomber2mission = StartBomberAuftrag('bomb2', 'evt-bomber2', tgts, escGrp2)
					end
		end,{},timer.getTime()+1)
	end,
	canExecute=function()
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
	title = "Intercept Bombers",
	description = "Enemy bombers spotted north of Qala\nDestroy them before they get in range.",
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

------------------------------------------------ Bomber 3 event ---------------------------------------------
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
					'Bayman','Chaghcharan','FOB-Javid Basharat','Kabul','Checkpoint Kabul E','Checkpoint Kabul W','Checkpoint Kabul S'}

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
        if bc:getZoneByName('FOB-Javid Basharat').side == 2 or bc:getZoneByName('Bagram').side == 2 then return false end

		return false
	end
})

mc:trackMission({
	title = "Intercept Bombers",
	description = "Enemy bombers spotted north of Bagram\nDestroy them before they get in range.",
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
	title = "Intercept enemy airstrike",
	description = "Enemy aircraft conducting an airstrike from the North-east\nDestroy them before they get in range.",
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
--[[ local airstrike2_COOLDOWN = 1800
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
})  ]]
-------------------------------------------- End of CAS 2 -----------------------------------------

----------------------------------------------- End of Associates -----------------------------------------------------------
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
	if resupplyTarget ~= nil then return end
		
	local validzones = {}
	for _,v in ipairs(bc.zones) do
		if v.side == 2 and not v.suspended and v:canRecieveSupply() then
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
-------------------------- END OF FLAGS --------------------------

env.info("Mission Setup : is completed!")
