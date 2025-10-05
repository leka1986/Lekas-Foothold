
--## GLOBAL GENERAL AIEN CONTENT TABLE
AIEN                                	= {}

--## USER CUSTOMIZATION VARIABLES ##
AIEN.config = {}
AIEN.config.dontInitialize      = false     -- if true, AIEN will not initialize; instead, you'll have to run it from your own code - it's useful when you want to override some functions/parameters before the initialization takes place

-- coalition affected by the script
AIEN.config.blueAI 		        = true 		-- true/false. If true, the AI enhancement will be applied to the blue coalition ground groups, else, no script effect will take place
AIEN.config.redAI			    = true 		-- true/false. If true, the AI enhancement will be applied to the red  coalition ground groups, else, no script effect will take place

-- Action sets allowed.
AIEN.config.firemissions        = true      -- true/false. If true, each artillery in the coalition will fire automatically at available targets provided by other ground units and drones
AIEN.config.reactions           = true      -- true/false. If true, when a mover group gets an hit, it will react accordingly to its skills and to its situational awareness, not staying there taking hits without doing nothing
AIEN.config.suppression         = true      -- true/false. If true, once a group take fire from arty or air and it's not armoured, it will be suppressed for 15-45 seconds and won't return fire. Require reactions to be set as 'true'
AIEN.config.dismount 		    = true 		-- true/false. //BEWARE: CAN AFFECT PERFORMANCES ON LOW END SYSTEMS // Thanks to MBot's original script, if true AI ground units with infantry transport capabilities (mainly APC/IFV/Trucks) will dismount soldiers with rifle, rpg and sometimes mandpads when appropriate
AIEN.config.initiative 		    = true 		-- true/false. If true, the ground groups will take limited initiative of attack or advance if intel and terrain allow them
--AIEN.config.conquer 		    = true 		-- true/false. If true, the ground groups will look for nearby towns or DCS ground markers and will try to move there if intel and terrain allow them (this is limited in space cause it's designed to work appropriately with DSMC 2)

-- User advanced customization 
AIEN.config.AIEN_xcl_tag		= {"SA-2","SA-3","SA-6","SA-10","SA-5","SA-11","Fixed","blue","Hidden","hidden","supply","support","attack","patrol","bluePD1","blueArmor","bSamFinal","bSampa","bSamBig","EscortGroup","Red SAM AAA 3","Red SAM AAA 4"} 	-- string, global, case sensitive. Can be dynamically changed by other script or triggers, since it's a global variable. used as a text format without spaces or special characters. only letters and numbers allowed. Any ground group with this 'tag' in its group name won't get AI enhancement behaviour, regardless of its coalition 
AIEN.config.AIEN_zoneFilter     = ""    	-- string, global, case sensitive. Can be dynamically changed by other script or triggers, since it's a global variable. used as a text format without spaces or special characters. only letters and numbers allowed, i.e. "AIEN" will fit. If left nil, or void string like "", won't be used. Only groups inside the named trigger zone will be affected by AIEN script behaviors of reaction, dismount and suppression, and vice versa. If no trigger zone with the specific name is in the mission, then all the groups will use AIEN features.
AIEN.config.message_feed        = true 		-- true/false. If true, each relevant AI action starting will also create a trigger message feedback for its coalition
AIEN.config.mark_on_f10_map     = true 	    -- true/false. If true, when an artillery fire mission is ongoing, a markpoint will appear on the map of the allied coalition to show the expected impact point
AIEN.config.skill_action_const  = false     -- true/false. If true, AI available reactions types will be limited by the group average skill. If not, almost 2/3 of all available actions will be always be available regardless of the group skills
AIEN.config.maxGroupInMovement  = 10        -- number, used to limit the maximum number of groups that can be in movement at the same time. If more than this number are in movement, the script will not allow new movements until one of them is finished. This is useful to avoid too many groups moving at the same time and causing performance issues.    

-- User bug report: prior to report a bug, please try reproducing it with this variable set to "true"
AIEN.config.AIEN_debugProcessDetail = false

--## LOCAL HIGH LEVEL VARIABLES ##
-- changing the variable below is for fine customization, but it's not recommended cause it can change the code behaviour. 
-- If you do so, please revert to original value and retry before reporting bugs.

-- movement variables
AIEN.config.outRoadSpeed                      = 8	              -- do *3.6 for km/h, cause DCS thinks in m/s	
AIEN.config.inRoadSpeed                       = 15	              -- do *3.6 for km/h, cause DCS thinks in m/s
AIEN.config.infantrySpeed                     = 2	              -- do *3.6 for km/h, cause DCS thinks in m/s	
AIEN.config.repositionDistance				  = 1000	          -- meters, radius to a specific destination point that will be randomized between 90% and 110% of this value. Used when a group is moved upon another group position: the other group position will be the destination.
AIEN.config.rndFleeDistance		              = 1500 		      -- meters, reposition distance given to a group when a destination is not defined. The direction also will be totally random. Used, i.e., for "panic" reaction
AIEN.config.tacticalRange	                  = 4000 		      -- meters, define maximum distance allowed for each initiative movement
AIEN.config.initiativeRange                   = 4000              -- meters, define maximum distance allowed for each initiative movement when a group is engaged in combat. If the group is not engaged, the distance will be 2000 meters  
AIEN.config.maxSlope                          = 25	              -- degrees, maximum slope allowed for a group to move to a specific destination. If the slope is more than this value, the group will not move there.     


-- dismounted troops variables
AIEN.config.droppedReposition                 = 80                -- if no enemy is identified, this is the distance where dismount group will reposition themselves
AIEN.config.remountTime                       = 900               -- time after which dismounted troops will try to go back to their original vehicle for remount, if commanded
AIEN.config.infantryExtractDist               = 200               -- max distance from vehicle to troops to allow a group extraction
AIEN.config.infantrySearchDist                = 1000              -- max distance from vehicle to troops to allow a dismount group to run toward the enemies

-- informative calls variables
AIEN.config.outAmmoLowLevel                   = 0.5		          -- factor on total amount
AIEN.config.densityRange                      = 5000              -- meters, used for the density calculation of a group. If a group is within this distance from another group, it will be considered "dense" and will not be able to perform some actions

-- reactions and tasking variables
AIEN.config.intelDbTimeout                    = 1200              -- seconds. Used to cancel intelDb entries for units (not static!), when the time of the contact gathering is more than this value
AIEN.config.artyFireLastContactThereshold     = 300               -- seconds, max amount of time since last contact to consider an arty target ok
AIEN.config.taskTimeout                       = 480               -- seconds after which a tasked group is removed from the database
AIEN.config.targetedTimeout                   = 240               -- seconds after which a targeted variable in inteldb is removed from database
AIEN.config.artyTaskTimeout                   = 180 -- 240
AIEN.config.artyTargetedTimeout               = 180 -- 180
AIEN.config.disperseActionTime				  = 120		          -- seconds
AIEN.config.counterBatteryRadarRange          = 50000             -- m, capable distance for a radar to perform counter battery calculations
AIEN.config.counterBatteryPlanDelay           = 160               -- s, will be also randomized on +-35%. Used to define the delay of the planned counter battery fire if available
AIEN.config.smoke_source_num                  = 5                 -- number, between 4 and 9. Generated smokes for each unit when smoke reaction is called in. Any number below 4 or above 9 will be converted in the nearest threshold

-- SA evaluation variables
AIEN.config.proxyBuildingDistance			  = 1500              -- m, if buildings are within this distance value, they are considered "close"
AIEN.config.proxyUnitsDistance                = 4500              -- m, if units are within this distance value, they are considered "close"
AIEN.config.supportDistance					  = 4000			  -- m, maximum distance for evaluating support or cover movements when under attack
AIEN.config.withrawDist                       = 3500             -- m, maximum distance for withdraw manoeuvre nearby a friendly support unit



--####################################################################################################
--###### DO NOT CHANGE CODE BELOW HERE ###############################################################
--####################################################################################################

--###### CONFIG AND VARIABLES ########################################################################

--## MAIN VARIABLES

-- Mark id addition
local markIdStart                       = 12345000000

-- DSMC version of the script check: if already there due to DSMC version, the script won't be loaded.
if AIEN.performPhaseCycle then
    env.info(("AIEN already there in another way, stopping"))
    return
end

--## LOCAL GENERAL INFORMATIONS VARIABLES (mostly used for debug log and info)
local ModuleName  						= "AIEN"
local MainVersion 						= "1"
local SubVersion 						= "2"
local Build 							= "0175"
local Date								= "2025.07.26"

--## LOCAL LOW LEVEL VARIABLES

--Debug 
local AIEN_io 					    	= _G.io  	        -- check if io  is available in mission environment, if so debug will also produce files. NOT-RECOMMENDED to have an unsanitized mission env.
local AIEN_lfs 					    	= _G.lfs		    -- check if lfs is available in mission environment, if so debug will also produce files. NOT-RECOMMENDED to have an unsanitized mission env.

-- FSM and system
local PHASE                             = "Initialization"  -- used by FSM, don't change, it won't affect anything
local phase_index                   	= nil
local phase_keys                        = {}
local phaseCycleTimer                   = 0.2               -- seconds, used by FSM. Define how much time pass between a loop entry calculation and another. You might want to reduce it further or if you feel DCS being "slow" you can raise up to 1.0 second. 
local rndMinRT_xper                     = 2                 -- seconds counted as minimum basic reaction time after an event (beware, reaction time also depends on group averaged skill)
local rndMacRT_xper                     = 4                 -- seconds counted as maximum basic reaction time after an event (beware, reaction time also depends on group averaged skill)
local stupidIndex                       = 1                 -- used to avoid infinite loops

--AI processing timers
local underAttack                       = {}                -- used when a group has been attacked, it keeps "tactical" tasking off for 10 mins leaving room for "reaction" decision making
local movingGroups                      = 0                 -- used to keep track of groups that are currently moving, so that no initiative actions can be taken if the number is more than allowed by AIEN.config.maxGroupInMovement


--Dynamic and_or linked to other code
if not DSMC_baseGcounter then
	DSMC_baseGcounter = 20000000
end
if not DSMC_baseUcounter then
	DSMC_baseUcounter = 19000000
end

--## LOCAL DYNAMIC TABLES (DBs)

local groundgroupsDb    = {} -- used for general purpose on groups command
local droneunitDb       = {} -- used mostly for artillery control
local intelDb           = {} -- used for any enemy assessment evaluation. The getSA function is used for populating the db
local mountedDb         = {} -- used for assign infantry teams to each capable vehicle or trucks
local infcarrierDb      = {} -- used for store infantry carriers informations (i.e. available space)

--## LOCAL STATIC TABLES

-- used for prioritizing arty target by class
local classPriority     = {
    ["MLRS"] = 9.5,
    ["ARTY"] = 9.5,
    ["MBT"] = 9,
    ["ATGM"] = 8,
    ["SAM"] = 9.6,
    ["SAML"]= 5,
    ["SAMC"]= 5,
    ["SHORAD"] = 9.2,
    ["IFV"] = 7,
    ["APC"] = 4,
    ["RECCE"] = 3.5,
    ["AAA"] = 9,
    ["MISSILE"] = 4.5,
    ["MANPADS"] = 7.1,
    ["LOGI"] = 2,
    ["INF"] = 1,
    ["UNKN"] = 0.5,
    ["ARBN"] = 0,    
    ["SHIP"] = 2,  
}

-- used to identify if a group is suitable for supporting others in ground battle
local supportGroundClasses  = {
    ["MLRS"] = 2.1,
    ["ARTY"] = 2.3,
    ["MBT"] = 10,
    ["ATGM"] = 9,
    ["SAM"] = 3,
    ["SAML"]= 1,
    ["SAMC"]= 1,
    ["SHORAD"] = 5,
    ["IFV"] = 7,
    ["APC"] = 5.5,
    ["RECCE"] = 3.5,
    ["AAA"] = 2,
    ["MISSILE"] = 1,
    ["MANPADS"] = 0.8,
    ["LOGI"] = 1.2,
    ["INF"] = 0.5,
    ["UNKN"] = 0.9,
    --["ARBN"] = 0,
    --["SHIP"] = 0,  
}

-- used to identify if a group is suitable for supporting others in ground battle
local supportCounterAirClasses  = {
    ["MLRS"] = 0.5,
    ["ARTY"] = 1,
    ["MBT"] = 4,
    ["ATGM"] = 5,
    ["SAM"] = 10,
    ["SAML"]= 2,
    ["SAMC"]= 2,
    ["SHORAD"] = 9,
    ["IFV"] = 4.5,
    ["APC"] = 3,
    ["RECCE"] = 2.5,
    ["AAA"] = 7,
    ["MISSILE"] = 0.2,
    ["MANPADS"] = 8,
    ["LOGI"] = 1.2,
    ["INF"] = 0.1,
    ["UNKN"] = 2,
    --["ARBN"] = 0,
    --["SHIP"] = 0,  
}

-- used in multiple part of the scripts for defining reactions, speed, and smartness of the groups
local skills = {
    ["Average"] = {aim_delay = 170, skillVal = 4},
    ["High"] = {aim_delay = 130, skillVal = 9},
    ["Good"] = {aim_delay = 150, skillVal = 6},
    ["Excellent"] = {aim_delay = 110, skillVal = 12},   
	["Random"] = {aim_delay = 140, skillVal = 8},  -- skill val is NOT used in this case, it's replaced by a randomness.
}

-- used for define infantry teams carrier capacity by attribute. BEWARE: the table key are not "classes", are actual DCS attributes enum. Don't add "casual" things, stick to them. You can find a list here: https://wiki.hoggitworld.com/view/DCS_enum_attributes 
local dismountCarriers = {
    ["Trucks"] = 9,    -- this should be handled as a 3 teams of 4 each
    ["APC"] = 4,        -- this should be handled as a 2 teams of 4 each
    ["IFV"] = 4,        -- this should be handled as a 1 teams of 4 each
}

-- used for define infantry teams composition. In the table, p is the probability from 1 to 100, c is the composition
local dismountTeamsWest = { 
    ["rifle"] = {id = "rifle", p = 55, c = {
        [1] = "Soldier M4",
        [2] = "Soldier M4",
        [3] = "Soldier M4",
        [4] = "Soldier M249",
    }},
    ["mixed"] = {id = "mixed", p = 20, c = {
        [1] = "Soldier M4",
        [2] = "Paratrooper RPG-16",
        [3] = "Soldier M4",
        [4] = "Soldier M249",
    }},-- mixed is actually 3 rifle and 1 rpg      
    ["RPGs"] = {id = "RPGs", p = 9, c = {
        [1] = "Paratrooper RPG-16",
        [2] = "Paratrooper RPG-16",
        [3] = "Soldier M4",
        [4] = "Soldier M4",
    }},              
    ["manpads"] = {id = "manpads", p = 3, c = {
        [1] = "Stinger manpad",
        [2] = "Stinger manpad",
        [3] = "Soldier M4",
    }},  
}

local dismountTeamsEast = { 
    ["rifle"] = {id = "rifle", p = 55, c = {
        [1] = "Infantry AK ver3",
        [2] = "Infantry AK ver2",
        [3] = "Infantry AK ver2",
        [4] = "Infantry AK ver3",
    }},
    ["mixed"] = {id = "mixed", p = 20, c = {
        [1] = "Infantry AK ver2",
        [2] = "Paratrooper RPG-16",
        [3] = "Infantry AK ver3",
        [4] = "Infantry AK ver3",
    }},-- mixed is actually 3 rifle and 1 rpg      
    ["RPGs"] = {id = "RPGs", p = 9, c = {
        [1] = "Paratrooper RPG-16",
        [2] = "Paratrooper RPG-16",
        [3] = "Infantry AK ver2",
        [4] = "Infantry AK ver3",
    }},               
    ["manpads"] = {id = "manpads", p = 3, c = {
        [1] = "Infantry AK ver3",
        [2] = "Infantry AK ver3",
        [3] = "Infantry AK ver3",
    }},  
}

if env.mission and env.mission.date and env.mission.date.Year then
    local y = tonumber(env.mission.date.Year)

    if AIEN.config.AIEN_debugProcessDetail == true then
        env.info(("AIEN mission date: " .. tostring(y)))
    end

    if y < 1980 then
        dismountTeamsWest["manpads"] = nil
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info(("AIEN removed stinger"))
        end
    elseif y < 1970 then
        dismountTeamsEast["manpads"] = nil
        dismountTeamsWest["manpads"] = nil
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info(("AIEN removed all manpads"))
        end
    end
end



--## LINKED TABLES (or local if not available)
local tblThreatsRange                   = nil  -- this is a foundamental table cause it holds the firing range of any units, but mostly artillery one! Since the required data aren't available in the mission env, it can be either ported by DSMC (if used) or manually prompted. For the latter, obviously, it require to be manually updated. 
if EMBD then -- just for compatibility enhancement
    tblThreatsRange                = EMBD.tblThreatsRange
    if tblThreatsRange then
        for tId, tData in pairs(tblThreatsRange) do
            tData.attr = nil
        end
    end
end


if not tblThreatsRange then
	tblThreatsRange = {
        ["S-60_Type59_Artillery"] = 
        {
            ["detection"] = 5000,
            ["threat"] = 6000,
        }, -- end of ["S-60_Type59_Artillery"]
        ["flak30"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 2500,
        }, -- end of ["flak30"]
        ["Daimler_AC"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 0,
            ["threat"] = 2000,
        }, -- end of ["Daimler_AC"]
        ["MTLB"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 1000,
        }, -- end of ["MTLB"]
        ["L-39ZA"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["L-39ZA"]
        ["Czech hedgehogs 2"] = 
        {
        }, -- end of ["Czech hedgehogs 2"]
        ["Horch_901_typ_40_kfz_21"] = 
        {
            ["irsignature"] = 0.065,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Horch_901_typ_40_kfz_21"]
        ["uh1h_cargo"] = 
        {
        }, -- end of ["uh1h_cargo"]
        ["pipes_small_cargo"] = 
        {
        }, -- end of ["pipes_small_cargo"]
        ["Gepard"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 15000,
            ["threat"] = 4000,
        }, -- end of ["Gepard"]
        ["M 818"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["M 818"]
        ["Soldier RPG"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["Soldier RPG"]
        ["Container_watchtower_lights"] = 
        {
        }, -- end of ["Container_watchtower_lights"]
        ["FarpHide_Med"] = 
        {
        }, -- end of ["FarpHide_Med"]
        ["CV_59_MD3"] = 
        {
        }, -- end of ["CV_59_MD3"]
        ["CastleClass_01"] = 
        {
            ["detection"] = 25000,
            ["threat"] = 3000,
        }, -- end of ["CastleClass_01"]
        ["Merkava_Mk4"] = 
        {
            ["irsignature"] = 0.12,
            ["detection"] = 0,
            ["threat"] = 3500,
        }, -- end of ["Merkava_Mk4"]
        ["Patriot cp"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Patriot cp"]
        ["5p73 s-125 ln"] = 
        {
            ["irsignature"] = 0.02,
            ["detection"] = 0,
            ["threat"] = 18000,
        }, -- end of ["5p73 s-125 ln"]
        ["house2arm"] = 
        {
            ["irsignature"] = 0.007,
            ["detection"] = 0,
            ["threat"] = 800,
        }, -- end of ["house2arm"]
        ["F-15E"] = 
        {
            ["irsignature"] = 0.91,
        }, -- end of ["F-15E"]
        ["M45_Quadmount"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 1500,
        }, -- end of ["M45_Quadmount"]
        ["Churchill_VII"] = 
        {
            ["irsignature"] = 0.105,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["Churchill_VII"]
        ["B-52H"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["B-52H"]
        ["AS32-p25"] = 
        {
        }, -- end of ["AS32-p25"]
        ["SturmPzIV"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 4500,
        }, -- end of ["SturmPzIV"]
        ["T155_Firtina"] = 
        {
            ["irsignature"] = 0.11,
            ["detection"] = 0,
            ["threat"] = 41000,
        }, -- end of ["T155_Firtina"]
        ["oiltank_cargo"] = 
        {
        }, -- end of ["oiltank_cargo"]
        ["Carrier LSO Personell 2"] = 
        {
        }, -- end of ["Carrier LSO Personell 2"]
        ["Freya_Shelter_Brick"] = 
        {
        }, -- end of ["Freya_Shelter_Brick"]
        ["Building04_PBR"] = 
        {
        }, -- end of ["Building04_PBR"]
        ["A-20G"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["A-20G"]
        ["r11_volvo"] = 
        {
        }, -- end of ["r11_volvo"]
        ["Container_40ft"] = 
        {
        }, -- end of ["Container_40ft"]
        ["Predator GCS"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Predator GCS"]
        ["hy_launcher"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 100000,
            ["threat"] = 100000,
        }, -- end of ["hy_launcher"]
        ["Bf-109K-4"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["Bf-109K-4"]
        ["Seawise_Giant"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Seawise_Giant"]
        ["LST_Mk2"] = 
        {
            ["irsignature"] = 0.3,
            ["detection"] = 0,
            ["threat"] = 4000,
        }, -- end of ["LST_Mk2"]
        ["m1_vla"] = 
        {
        }, -- end of ["m1_vla"]
        ["Mirage-F1BQ"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1BQ"]
        ["ZU-23 Closed Insurgent"] = 
        {
            ["irsignature"] = 0.006,
            ["detection"] = 5000,
            ["threat"] = 2500,
        }, -- end of ["ZU-23 Closed Insurgent"]
        ["HQ-7_LN_P"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 8000,
            ["threat"] = 12000,
        }, -- end of ["HQ-7_LN_P"]
        ["snr s-125 tr"] = 
        {
            ["irsignature"] = 0.06,
            ["detection"] = 100000,
            ["threat"] = 0,
        }, -- end of ["snr s-125 tr"]
        ["Siegfried Line"] = 
        {
        }, -- end of ["Siegfried Line"]
        ["SAU Msta"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 23500,
        }, -- end of ["SAU Msta"]
        ["Tent02"] = 
        {
        }, -- end of ["Tent02"]
        ["outpost_road"] = 
        {
            ["irsignature"] = 0.007,
            ["detection"] = 0,
            ["threat"] = 800,
        }, -- end of ["outpost_road"]
        ["Vulcan"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 5000,
            ["threat"] = 2000,
        }, -- end of ["Vulcan"]
        ["Dragonteeth 2"] = 
        {
        }, -- end of ["Dragonteeth 2"]
        ["leopard-2A4_trs"] = 
        {
            ["irsignature"] = 0.12,
            ["detection"] = 0,
            ["threat"] = 3500,
        }, -- end of ["leopard-2A4_trs"]
        ["Sd_Kfz_7"] = 
        {
            ["irsignature"] = 0.075,
            ["detection"] = 0,
        }, -- end of ["Sd_Kfz_7"]
        ["container_40ft"] = 
        {
        }, -- end of ["container_40ft"]
        ["TYPE-59"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 2500,
        }, -- end of ["TYPE-59"]
        ["SpGH_Dana"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 18700,
        }, -- end of ["SpGH_Dana"]
        ["Ski Ramp"] = 
        {
        }, -- end of ["Ski Ramp"]
        ["BMP-2"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["BMP-2"]
        ["santafe"] = 
        {
        }, -- end of ["santafe"]
        ["Allies_Director"] = 
        {
            ["irsignature"] = 0.03,
            ["detection"] = 30000,
            ["threat"] = 0,
        }, -- end of ["Allies_Director"]
        ["F-5E"] = 
        {
            ["irsignature"] = 0.4,
        }, -- end of ["F-5E"]
        ["VAB_Mephisto"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 0,
            ["threat"] = 3800,
        }, -- end of ["VAB_Mephisto"]
        ["Cargo06"] = 
        {
        }, -- end of ["Cargo06"]
        ["Stug_IV"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["Stug_IV"]
        ["F-4E"] = 
        {
            ["irsignature"] = 1,
        }, -- end of ["F-4E"]
        ["M-109"] = 
        {
            ["irsignature"] = 0.11,
            ["detection"] = 1000,
            ["threat"] = 22000,
        }, -- end of ["M-109"]
        ["LAZ Bus"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["LAZ Bus"]
        ["UH-60A"] = 
        {
            ["irsignature"] = 0.22,
        }, -- end of ["UH-60A"]
        ["Beer Bomb"] = 
        {
        }, -- end of ["Beer Bomb"]
        ["ATZ-10"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["ATZ-10"]
        ["P20_01"] = 
        {
        }, -- end of ["P20_01"]
        ["Elefant_SdKfz_184"] = 
        {
            ["irsignature"] = 0.11,
            ["detection"] = 0,
            ["threat"] = 6000,
        }, -- end of ["Elefant_SdKfz_184"]
        ["M978 HEMTT Tanker"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["M978 HEMTT Tanker"]
        ["Mirage-F1CE"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1CE"]
        ["Marder"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 0,
            ["threat"] = 1500,
        }, -- end of ["Marder"]
        ["HarborTug"] = 
        {
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["HarborTug"]
        ["CVN_72"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 50000,
            ["threat"] = 25000,
        }, -- end of ["CVN_72"]
        ["Sandbag_11"] = 
        {
        }, -- end of ["Sandbag_11"]
        ["BRDM-2"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 1600,
        }, -- end of ["BRDM-2"]
        ["ATZ-5"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["ATZ-5"]
        ["Tent01"] = 
        {
        }, -- end of ["Tent01"]
        ["An-26B"] = 
        {
            ["irsignature"] = 0.5,
        }, -- end of ["An-26B"]
        ["LiAZ Bus"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["LiAZ Bus"]
        ["soldier_wwii_us"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["soldier_wwii_us"]
        ["trunks_small_cargo"] = 
        {
        }, -- end of ["trunks_small_cargo"]
        ["Tiger_II_H"] = 
        {
            ["irsignature"] = 0.105,
            ["detection"] = 0,
            ["threat"] = 6000,
        }, -- end of ["Tiger_II_H"]
        ["KC130"] = 
        {
            ["irsignature"] = 1,
        }, -- end of ["KC130"]
        ["LAV-25"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 0,
            ["threat"] = 2500,
        }, -- end of ["LAV-25"]
        ["SK_C_28_naval_gun"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 20000,
        }, -- end of ["SK_C_28_naval_gun"]
        ["Stug_III"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["Stug_III"]
        ["BoomBarrier_open"] = 
        {
        }, -- end of ["BoomBarrier_open"]
        ["tetrapod_cargo"] = 
        {
        }, -- end of ["tetrapod_cargo"]
        ["German_covered_wagon_G10"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["German_covered_wagon_G10"]
        ["TugHarlan_drivable"] = 
        {
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["TugHarlan_drivable"]
        ["UAZ-469"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["UAZ-469"]
        ["CV_59_NS60"] = 
        {
        }, -- end of ["CV_59_NS60"]
        ["FPS-117 Dome"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 400000,
            ["threat"] = 0,
        }, -- end of ["FPS-117 Dome"]
        ["Building03_PBR"] = 
        {
        }, -- end of ["Building03_PBR"]
        ["Mirage-F1DDA"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1DDA"]
        ["CH-53E"] = 
        {
            ["irsignature"] = 1,
        }, -- end of ["CH-53E"]
        ["Mirage-F1CJ"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1CJ"]
        ["FW-190A8"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["FW-190A8"]
        ["FuMG-401"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 160000,
            ["threat"] = 0,
        }, -- end of ["FuMG-401"]
        ["Ural-4320T"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Ural-4320T"]
        ["HandyWind"] = 
        {
            ["irsignature"] = 0.35,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["HandyWind"]
        ["Ka-50"] = 
        {
            ["irsignature"] = 0.3,
        }, -- end of ["Ka-50"]
        ["Tiger_I"] = 
        {
            ["irsignature"] = 0.105,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["Tiger_I"]
        ["FireExtinguisher03"] = 
        {
        }, -- end of ["FireExtinguisher03"]
        ["Shelter01"] = 
        {
        }, -- end of ["Shelter01"]
        ["Kub 1S91 str"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 70000,
            ["threat"] = 0,
        }, -- end of ["Kub 1S91 str"]
        ["ALBATROS"] = 
        {
            ["irsignature"] = 0.35,
            ["detection"] = 30000,
            ["threat"] = 16000,
        }, -- end of ["ALBATROS"]
        ["M1126 Stryker ICV"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 0,
            ["threat"] = 1200,
        }, -- end of ["M1126 Stryker ICV"]
        ["E-3A"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["E-3A"]
        ["Soldier AK"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["Soldier AK"]
        ["SA-18 Igla-S manpad"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 5000,
            ["threat"] = 5200,
        }, -- end of ["SA-18 Igla-S manpad"]
        ["Kub 2P25 ln"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 0,
            ["threat"] = 25000,
        }, -- end of ["Kub 2P25 ln"]
        ["Cobra"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 0,
            ["threat"] = 1200,
        }, -- end of ["Cobra"]
        ["MLRS FDDM"] = 
        {
            ["irsignature"] = 0.075,
            ["detection"] = 0,
            ["threat"] = 1200,
        }, -- end of ["MLRS FDDM"]
        ["Mi-8MT"] = 
        {
            ["irsignature"] = 0.6,
        }, -- end of ["Mi-8MT"]
        ["bofors40"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 4000,
        }, -- end of ["bofors40"]
        ["ZU-23 Insurgent"] = 
        {
            ["irsignature"] = 0.006,
            ["detection"] = 5000,
            ["threat"] = 2500,
        }, -- end of ["ZU-23 Insurgent"]
        ["Ural-4320-31"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Ural-4320-31"]
        ["Hawk tr"] = 
        {
            ["irsignature"] = 0.06,
            ["detection"] = 90000,
            ["threat"] = 0,
        }, -- end of ["Hawk tr"]
        ["TACAN_beacon"] = 
        {
            ["irsignature"] = 0.005,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["TACAN_beacon"]
        ["SNR_75V"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 100000,
            ["threat"] = 0,
        }, -- end of ["SNR_75V"]
        ["Building08_PBR"] = 
        {
        }, -- end of ["Building08_PBR"]
        ["Stinger comm"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 5000,
            ["threat"] = 0,
        }, -- end of ["Stinger comm"]
        ["IL-76MD"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["IL-76MD"]
        ["Su-34"] = 
        {
            ["irsignature"] = 1,
        }, -- end of ["Su-34"]
        ["soldier_mauser98"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["soldier_mauser98"]
        ["AS32-36A"] = 
        {
        }, -- end of ["AS32-36A"]
        ["S-300PS 40B6MD sr_19J6"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 150000,
            ["threat"] = 0,
        }, -- end of ["S-300PS 40B6MD sr_19J6"]
        ["MJ-1_02"] = 
        {
        }, -- end of ["MJ-1_02"]
        ["M1045 HMMWV TOW"] = 
        {
            ["irsignature"] = 0.75,
            ["detection"] = 0,
            ["threat"] = 3800,
        }, -- end of ["M1045 HMMWV TOW"]
        ["Mirage-F1B"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1B"]
        ["LHD_LHA"] = 
        {
        }, -- end of ["LHD_LHA"]
        ["HQ-7_LN_SP"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 8000,
            ["threat"] = 12000,
        }, -- end of ["HQ-7_LN_SP"]
        ["SAU Akatsia"] = 
        {
            ["irsignature"] = 0.095,
            ["detection"] = 0,
            ["threat"] = 17000,
        }, -- end of ["SAU Akatsia"]
        ["NASAMS_Radar_MPQ64F1"] = 
        {
            ["irsignature"] = 0.06,
            ["detection"] = 50000,
            ["threat"] = 0,
        }, -- end of ["NASAMS_Radar_MPQ64F1"]
        ["Haystack 4"] = 
        {
        }, -- end of ["Haystack 4"]
        ["HESCO_wallperimeter_5"] = 
        {
        }, -- end of ["HESCO_wallperimeter_5"]
        ["F/A-18A"] = 
        {
            ["irsignature"] = 0.73,
        }, -- end of ["F/A-18A"]
        ["Revetment_x8"] = 
        {
        }, -- end of ["Revetment_x8"]
        ["Tetrarch"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 0,
            ["threat"] = 2000,
        }, -- end of ["Tetrarch"]
        ["MiG-23MLD"] = 
        {
            ["irsignature"] = 0.69,
        }, -- end of ["MiG-23MLD"]
        ["M32-10C_04"] = 
        {
        }, -- end of ["M32-10C_04"]
        ["Jagdpanther_G1"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 5000,
        }, -- end of ["Jagdpanther_G1"]
        ["Container_10ft"] = 
        {
        }, -- end of ["Container_10ft"]
        ["AV8BNA"] = 
        {
            ["irsignature"] = 0.7,
        }, -- end of ["AV8BNA"]
        ["Infantry AK Ins"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["Infantry AK Ins"]
        ["Coach cargo"] = 
        {
            ["irsignature"] = 0,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Coach cargo"]
        ["M-2000C"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["M-2000C"]
        ["Carrier LSO Personell 5"] = 
        {
        }, -- end of ["Carrier LSO Personell 5"]
        ["ZIL-131 KUNG"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["ZIL-131 KUNG"]
        ["Container_20ft"] = 
        {
        }, -- end of ["Container_20ft"]
        ["ZiL-131 APA-80"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["ZiL-131 APA-80"]
        ["BMP-3"] = 
        {
            ["irsignature"] = 0.095,
            ["detection"] = 0,
            ["threat"] = 4000,
        }, -- end of ["BMP-3"]
        ["P-47D-30bl1"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["P-47D-30bl1"]
        ["CVN_75"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 50000,
            ["threat"] = 25000,
        }, -- end of ["CVN_75"]
        ["UH-1H"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["UH-1H"]
        ["Hummer"] = 
        {
            ["irsignature"] = 0.075,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Hummer"]
        ["Dragonteeth 1"] = 
        {
        }, -- end of ["Dragonteeth 1"]
        ["AH-64D_BLK_II"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["AH-64D_BLK_II"]
        ["leopard-2A4"] = 
        {
            ["irsignature"] = 0.12,
            ["detection"] = 0,
            ["threat"] = 3500,
        }, -- end of ["leopard-2A4"]
        ["RQ-1A Predator"] = 
        {
            ["irsignature"] = 0.01,
        }, -- end of ["RQ-1A Predator"]
        ["USS_Arleigh_Burke_IIa"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 150000,
            ["threat"] = 100000,
        }, -- end of ["USS_Arleigh_Burke_IIa"]
        ["Carrier LSO Personell 1"] = 
        {
        }, -- end of ["Carrier LSO Personell 1"]
        ["SA342L"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["SA342L"]
        ["Sandbag_02"] = 
        {
        }, -- end of ["Sandbag_02"]
        ["Ladder"] = 
        {
        }, -- end of ["Ladder"]
        ["f_bar_cargo"] = 
        {
        }, -- end of ["f_bar_cargo"]
        ["Tornado GR4"] = 
        {
            ["irsignature"] = 0.6,
        }, -- end of ["Tornado GR4"]
        ["Hawk pcp"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Hawk pcp"]
        ["S-300PS 40B6M tr"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 160000,
            ["threat"] = 0,
        }, -- end of ["S-300PS 40B6M tr"]
        ["ZU-23 Emplacement Closed"] = 
        {
            ["irsignature"] = 0.006,
            ["detection"] = 5000,
            ["threat"] = 2500,
        }, -- end of ["ZU-23 Emplacement Closed"]
        ["ZIL-135"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["ZIL-135"]
        ["OH58D"] = 
        {
            ["irsignature"] = 0.07,
        }, -- end of ["OH58D"]
        ["Bunker"] = 
        {
            ["irsignature"] = 0.005,
            ["detection"] = 0,
            ["threat"] = 800,
        }, -- end of ["Bunker"]
        ["Container_office"] = 
        {
        }, -- end of ["Container_office"]
        ["GAZ-3308"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["GAZ-3308"]
        ["flak41"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 5000,
        }, -- end of ["flak41"]
        ["SA-11 Buk LN 9A310M1"] = 
        {
            ["irsignature"] = 0.095,
            ["detection"] = 50000,
            ["threat"] = 35000,
        }, -- end of ["SA-11 Buk LN 9A310M1"]
        ["tt_B8M1"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 5000,
            ["threat"] = 5000,
        }, -- end of ["tt_B8M1"]
        ["SON_9"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 55000,
            ["threat"] = 0,
        }, -- end of ["SON_9"]
        ["ZSU-23-4 Shilka"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 5000,
            ["threat"] = 2500,
        }, -- end of ["ZSU-23-4 Shilka"]
        ["Freya_Shelter_Concrete"] = 
        {
        }, -- end of ["Freya_Shelter_Concrete"]
        ["Chieftain_mk3"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 3500,
        }, -- end of ["Chieftain_mk3"]
        ["BTR-80"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 1600,
        }, -- end of ["BTR-80"]
        ["CV_1143_5"] = 
        {
            ["irsignature"] = 0.45,
            ["detection"] = 25000,
            ["threat"] = 12000,
        }, -- end of ["CV_1143_5"]
        ["r11_volvo_drivable"] = 
        {
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["r11_volvo_drivable"]
        ["AAV7"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 1200,
        }, -- end of ["AAV7"]
        ["Ka-27"] = 
        {
            ["irsignature"] = 0.5,
        }, -- end of ["Ka-27"]
        ["KC135MPRS"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["KC135MPRS"]
        ["FPS-117"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 463000,
            ["threat"] = 0,
        }, -- end of ["FPS-117"]
        ["HEMTT_C-RAM_Phalanx"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 10000,
            ["threat"] = 2000,
        }, -- end of ["HEMTT_C-RAM_Phalanx"]
        ["Patriot ln"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 100000,
        }, -- end of ["Patriot ln"]
        ["H-6J"] = 
        {
            ["irsignature"] = 2.5,
        }, -- end of ["H-6J"]
        ["E-2C"] = 
        {
            ["irsignature"] = 0.5,
        }, -- end of ["E-2C"]
        ["offshore WindTurbine"] = 
        {
        }, -- end of ["offshore WindTurbine"]
        ["NASAMS_LN_B"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 15000,
        }, -- end of ["NASAMS_LN_B"]
        ["ZU-23 Emplacement"] = 
        {
            ["irsignature"] = 0.006,
            ["detection"] = 5000,
            ["threat"] = 2500,
        }, -- end of ["ZU-23 Emplacement"]
        ["tt_ZU-23"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 2500,
        }, -- end of ["tt_ZU-23"]
        ["Ural-4320 APA-5D"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Ural-4320 APA-5D"]
        ["S-300PS 5P85D ln"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 120000,
        }, -- end of ["S-300PS 5P85D ln"]
        ["Coach a passenger"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Coach a passenger"]
        ["Dry-cargo ship-1"] = 
        {
            ["irsignature"] = 0.2,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Dry-cargo ship-1"]
        ["Mirage-F1C"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1C"]
        ["Tu-22M3"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["Tu-22M3"]
        ["Boxcartrinity"] = 
        {
            ["irsignature"] = 0,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Boxcartrinity"]
        ["M8_Greyhound"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 2000,
        }, -- end of ["M8_Greyhound"]
        ["us carrier tech"] = 
        {
        }, -- end of ["us carrier tech"]
        ["Mirage-F1BE"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1BE"]
        ["M2A1_halftrack"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 1200,
        }, -- end of ["M2A1_halftrack"]
        ["DRG_Class_86"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["DRG_Class_86"]
        ["MB-339APAN"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["MB-339APAN"]
        ["S-300PS 5H63C 30H6_tr"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 120000,
            ["threat"] = 0,
        }, -- end of ["S-300PS 5H63C 30H6_tr"]
        ["p-19 s-125 sr"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 160000,
            ["threat"] = 0,
        }, -- end of ["p-19 s-125 sr"]
        ["Carrier LSO Personell 4"] = 
        {
        }, -- end of ["Carrier LSO Personell 4"]
        ["Infantry AK"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["Infantry AK"]
        ["APFC fuel"] = 
        {
        }, -- end of ["APFC fuel"]
        ["T-80UD"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 5000,
        }, -- end of ["T-80UD"]
        ["Type_054A"] = 
        {
            ["detection"] = 160000,
            ["threat"] = 45000,
        }, -- end of ["Type_054A"]
        ["Tu-160"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["Tu-160"]
        ["Dragonteeth 5"] = 
        {
        }, -- end of ["Dragonteeth 5"]
        ["Type_052B"] = 
        {
            ["detection"] = 100000,
            ["threat"] = 30000,
        }, -- end of ["Type_052B"]
        ["A-10C_2"] = 
        {
            ["irsignature"] = 0.53,
        }, -- end of ["A-10C_2"]
        ["CH-47D"] = 
        {
            ["irsignature"] = 0.72,
        }, -- end of ["CH-47D"]
        ["AH-64A"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["AH-64A"]
        ["Challenger2"] = 
        {
            ["irsignature"] = 0.11,
            ["detection"] = 0,
            ["threat"] = 3500,
        }, -- end of ["Challenger2"]
        ["QF_37_AA"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 9000,
        }, -- end of ["QF_37_AA"]
        ["WingLoong-I"] = 
        {
            ["irsignature"] = 0.02,
        }, -- end of ["WingLoong-I"]
        ["Patriot EPP"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Patriot EPP"]
        ["S-3B Tanker"] = 
        {
            ["irsignature"] = 0.53,
        }, -- end of ["S-3B Tanker"]
        ["Su-25T"] = 
        {
            ["irsignature"] = 0.7,
        }, -- end of ["Su-25T"]
        ["HESCO_watchtower_2"] = 
        {
        }, -- end of ["HESCO_watchtower_2"]
        ["ELNYA"] = 
        {
            ["irsignature"] = 0.3,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["ELNYA"]
        ["Mirage-F1C-200"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1C-200"]
        ["Ural-375 PBU"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Ural-375 PBU"]
        ["Smerch_HE"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 70000,
        }, -- end of ["Smerch_HE"]
        ["M6 Linebacker"] = 
        {
            ["irsignature"] = 0.095,
            ["detection"] = 8000,
            ["threat"] = 4500,
        }, -- end of ["M6 Linebacker"]
        ["Mirage-F1CT"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1CT"]
        ["Leopard-2A5"] = 
        {
            ["irsignature"] = 0.12,
            ["detection"] = 0,
            ["threat"] = 3500,
        }, -- end of ["Leopard-2A5"]
        ["P-51D"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["P-51D"]
        ["Mirage-F1EH"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1EH"]
        ["WindTurbine"] = 
        {
        }, -- end of ["WindTurbine"]
        ["F-16C bl.52d"] = 
        {
            ["irsignature"] = 0.6,
        }, -- end of ["F-16C bl.52d"]
        ["PT_76"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 2000,
        }, -- end of ["PT_76"]
        ["ZWEZDNY"] = 
        {
            ["irsignature"] = 0.3,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["ZWEZDNY"]
        ["MLRS"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 32000,
        }, -- end of ["MLRS"]
        ["Mirage-F1CG"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1CG"]
        ["Infantry AK ver2"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["Infantry AK ver2"]
        ["J-11A"] = 
        {
            ["irsignature"] = 1,
        }, -- end of ["J-11A"]
        ["SpitfireLFMkIX"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["SpitfireLFMkIX"]
        ["Dog Ear radar"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 35000,
            ["threat"] = 0,
        }, -- end of ["Dog Ear radar"]
        ["Revetment_x4"] = 
        {
        }, -- end of ["Revetment_x4"]
        ["HESCO_post_1"] = 
        {
        }, -- end of ["HESCO_post_1"]
        ["P-51D-30-NA"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["P-51D-30-NA"]
        ["M1043 HMMWV Armament"] = 
        {
            ["irsignature"] = 0.075,
            ["detection"] = 3000,
            ["threat"] = 1200,
        }, -- end of ["M1043 HMMWV Armament"]
        ["S-300PS 40B6MD sr"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 60000,
            ["threat"] = 0,
        }, -- end of ["S-300PS 40B6MD sr"]
        ["Mirage-F1EE"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1EE"]
        ["Barrier A"] = 
        {
        }, -- end of ["Barrier A"]
        ["Tu-95MS"] = 
        {
            ["irsignature"] = 1.1,
        }, -- end of ["Tu-95MS"]
        ["HL_B8M1"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 5000,
            ["threat"] = 5000,
        }, -- end of ["HL_B8M1"]
        ["KAMAZ Truck"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["KAMAZ Truck"]
        ["Toolbox02"] = 
        {
        }, -- end of ["Toolbox02"]
        ["Mirage-F1CZ"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1CZ"]
        ["Carrier LSO Personell"] = 
        {
        }, -- end of ["Carrier LSO Personell"]
        ["CV_59_Large_Forklift"] = 
        {
        }, -- end of ["CV_59_Large_Forklift"]
        ["Ju-88A4"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["Ju-88A4"]
        ["Silkworm_SR"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 200000,
            ["threat"] = 0,
        }, -- end of ["Silkworm_SR"]
        ["NEUSTRASH"] = 
        {
            ["irsignature"] = 0.35,
            ["detection"] = 27000,
            ["threat"] = 12000,
        }, -- end of ["NEUSTRASH"]
        ["SKP-11"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["SKP-11"]
        ["FarpHide_Dmed"] = 
        {
        }, -- end of ["FarpHide_Dmed"]
        ["JagdPz_IV"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["JagdPz_IV"]
        ["USS_Samuel_Chase"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 0,
            ["threat"] = 7000,
        }, -- end of ["USS_Samuel_Chase"]
        ["BMP-1"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["BMP-1"]
        ["T-55"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 2500,
        }, -- end of ["T-55"]
        ["Su-17M4"] = 
        {
            ["irsignature"] = 0.69,
        }, -- end of ["Su-17M4"]
        ["rapier_fsa_launcher"] = 
        {
            ["irsignature"] = 0.03,
            ["detection"] = 30000,
            ["threat"] = 6800,
        }, -- end of ["rapier_fsa_launcher"]
        ["F-4E-45MC"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["F-4E-45MC"]
        ["Log ramps 3"] = 
        {
        }, -- end of ["Log ramps 3"]
        ["HESCO_wallperimeter_3"] = 
        {
        }, -- end of ["HESCO_wallperimeter_3"]
        ["L118_Unit"] = 
        {
            ["detection"] = 500,
            ["threat"] = 16500,
        }, -- end of ["L118_Unit"]
        ["CHAP_TOS1A"] = 
        {
            ["threat"] = 5900,
        }, -- end of ["CHAP_TOS1A"]
        ["CHAP_M142_GMLRS_M31"] = 
        {   
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 68524,
        }, -- end of ["CHAP_M142_GMLRS_M31"]
        ["DR_50Ton_Flat_Wagon"] = 
        {
            ["irsignature"] = 0,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["DR_50Ton_Flat_Wagon"]
        ["Su-30"] = 
        {
            ["irsignature"] = 1,
        }, -- end of ["Su-30"]
        ["KILO"] = 
        {
            ["irsignature"] = 0.2,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["KILO"]
        ["Leopard1A3"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 2500,
        }, -- end of ["Leopard1A3"]
        ["M2A1-105"] = 
        {
            ["irsignature"] = 0.04,
            ["detection"] = 0,
            ["threat"] = 11500,
        }, -- end of ["M2A1-105"]
        ["Tu-142"] = 
        {
            ["irsignature"] = 1.1,
        }, -- end of ["Tu-142"]
        ["Twall_x6"] = 
        {
        }, -- end of ["Twall_x6"]
        ["Gas platform"] = 
        {
        }, -- end of ["Gas platform"]
        ["B600_drivable"] = 
        {
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["B600_drivable"]
        ["T-72B"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 4000,
        }, -- end of ["T-72B"]
        ["NF-2_LightOff02"] = 
        {
        }, -- end of ["NF-2_LightOff02"]
        ["AJS37"] = 
        {
            ["irsignature"] = 0.62,
        }, -- end of ["AJS37"]
        ["55G6 EWR"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 400000,
            ["threat"] = 0,
        }, -- end of ["55G6 EWR"]
        ["MOLNIYA"] = 
        {
            ["irsignature"] = 0.35,
            ["detection"] = 21000,
            ["threat"] = 2000,
        }, -- end of ["MOLNIYA"]
        ["IL-78M"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["IL-78M"]
        ["MiG-15bis"] = 
        {
            ["irsignature"] = 0.26,
        }, -- end of ["MiG-15bis"]
        ["Log ramps 2"] = 
        {
        }, -- end of ["Log ramps 2"]
        ["MJ-1_01"] = 
        {
        }, -- end of ["MJ-1_01"]
        ["Haystack 1"] = 
        {
        }, -- end of ["Haystack 1"]
        ["ZSU_57_2"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 5000,
            ["threat"] = 7000,
        }, -- end of ["ZSU_57_2"]
        ["Invisible FARP"] = 
        {
        }, -- end of ["Invisible FARP"]
        ["Uragan_BM-27"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 35800,
        }, -- end of ["Uragan_BM-27"]
        ["FarpHide_Dsmall"] = 
        {
        }, -- end of ["FarpHide_Dsmall"]
        ["MosquitoFBMkVI"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["MosquitoFBMkVI"]
        ["houseA_arm"] = 
        {
            ["irsignature"] = 0.007,
            ["detection"] = 0,
            ["threat"] = 800,
        }, -- end of ["houseA_arm"]
        ["F-14A-135-GR"] = 
        {
            ["irsignature"] = 0.9,
        }, -- end of ["F-14A-135-GR"]
        ["SAU Gvozdika"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 15000,
        }, -- end of ["SAU Gvozdika"]
        ["Type_071"] = 
        {
            ["detection"] = 300000,
            ["threat"] = 150000,
        }, -- end of ["Type_071"]
        ["Sandbag_13"] = 
        {
        }, -- end of ["Sandbag_13"]
        ["Mirage-F1BD"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1BD"]
        ["Tankcartrinity"] = 
        {
            ["irsignature"] = 0,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Tankcartrinity"]
        ["2S6 Tunguska"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 18000,
            ["threat"] = 8000,
        }, -- end of ["2S6 Tunguska"]
        ["Hawk"] = 
        {
            ["irsignature"] = 0.62,
        }, -- end of ["Hawk"]
        ["Dry-cargo ship-2"] = 
        {
            ["irsignature"] = 0.3,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Dry-cargo ship-2"]
        ["FuSe-65"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 60000,
            ["threat"] = 0,
        }, -- end of ["FuSe-65"]
        ["tacr2a"] = 
        {
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["tacr2a"]
        ["S_75M_Volhov"] = 
        {
            ["irsignature"] = 0.03,
            ["detection"] = 0,
            ["threat"] = 43000,
        }, -- end of ["S_75M_Volhov"]
        ["Pz_V_Panther_G"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["Pz_V_Panther_G"]
        ["Camouflage03"] = 
        {
        }, -- end of ["Camouflage03"]
        ["FW-190D9"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["FW-190D9"]
        ["Sandbag_16"] = 
        {
        }, -- end of ["Sandbag_16"]
        ["Su-27"] = 
        {
            ["irsignature"] = 1,
        }, -- end of ["Su-27"]
        ["Leopard-2"] = 
        {
            ["irsignature"] = 0.12,
            ["detection"] = 0,
            ["threat"] = 3500,
        }, -- end of ["Leopard-2"]
        ["generator_5i57"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["generator_5i57"]
        ["Sd_Kfz_2"] = 
        {
            ["irsignature"] = 0.065,
            ["detection"] = 0,
        }, -- end of ["Sd_Kfz_2"]
        ["Strela-10M3"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 8000,
            ["threat"] = 5000,
        }, -- end of ["Strela-10M3"]
        ["HESCO_wallperimeter_1"] = 
        {
        }, -- end of ["HESCO_wallperimeter_1"]
        ["S-3B"] = 
        {
            ["irsignature"] = 0.53,
        }, -- end of ["S-3B"]
        ["Camouflage06"] = 
        {
        }, -- end of ["Camouflage06"]
        ["TZ-22_KrAZ"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["TZ-22_KrAZ"]
        ["BTR-82A"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 2000,
        }, -- end of ["BTR-82A"]
        ["Paratrooper RPG-16"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["Paratrooper RPG-16"]
        ["Willys_MB"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Willys_MB"]
        ["AH-1W"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["AH-1W"]
        ["Sd_Kfz_251"] = 
        {
            ["irsignature"] = 0.075,
            ["detection"] = 0,
            ["threat"] = 1100,
        }, -- end of ["Sd_Kfz_251"]
        ["ElevatedPlatform_down"] = 
        {
        }, -- end of ["ElevatedPlatform_down"]
        ["Container_watchtower"] = 
        {
        }, -- end of ["Container_watchtower"]
        ["Carrier Airboss"] = 
        {
        }, -- end of ["Carrier Airboss"]
        ["LeFH_18-40-105"] = 
        {
            ["irsignature"] = 0.04,
            ["detection"] = 0,
            ["threat"] = 10500,
        }, -- end of ["LeFH_18-40-105"]
        ["ammo_cargo"] = 
        {
        }, -- end of ["ammo_cargo"]
        ["Tower Crane"] = 
        {
        }, -- end of ["Tower Crane"]
        ["Oil rig"] = 
        {
        }, -- end of ["Oil rig"]
        ["Tent05"] = 
        {
        }, -- end of ["Tent05"]
        ["Trolley bus"] = 
        {
            ["irsignature"] = 0.06,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Trolley bus"]
        ["Su-25"] = 
        {
            ["irsignature"] = 0.7,
        }, -- end of ["Su-25"]
        ["FARP_SINGLE_01"] = 
        {
        }, -- end of ["FARP_SINGLE_01"]
        ["offshore WindTurbine2"] = 
        {
        }, -- end of ["offshore WindTurbine2"]
        ["Cargo01"] = 
        {
        }, -- end of ["Cargo01"]
        ["tt_KORD"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 5000,
            ["threat"] = 1200,
        }, -- end of ["tt_KORD"]
        ["Orca"] = 
        {
        }, -- end of ["Orca"]
        ["Tigr_233036"] = 
        {
            ["irsignature"] = 0.075,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Tigr_233036"]
        ["MAZ-6303"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["MAZ-6303"]
        ["M48 Chaparral"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 10000,
            ["threat"] = 8500,
        }, -- end of ["M48 Chaparral"]
        ["1L13 EWR"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 300000,
            ["threat"] = 0,
        }, -- end of ["1L13 EWR"]
        ["BDK-775"] = 
        {
            ["irsignature"] = 0.35,
            ["detection"] = 25000,
            ["threat"] = 6000,
        }, -- end of ["BDK-775"]
        ["fueltank_cargo"] = 
        {
        }, -- end of ["fueltank_cargo"]
        ["Haystack 3"] = 
        {
        }, -- end of ["Haystack 3"]
        ["SA-18 Igla manpad"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 5000,
            ["threat"] = 5200,
        }, -- end of ["SA-18 Igla manpad"]
        ["SA342M"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["SA342M"]
        ["S-300PS 5P85C ln"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 120000,
        }, -- end of ["S-300PS 5P85C ln"]
        ["Ka-50_3"] = 
        {
            ["irsignature"] = 0.6,
        }, -- end of ["Ka-50_3"]
        ["Type_052C"] = 
        {
            ["detection"] = 260000,
            ["threat"] = 100000,
        }, -- end of ["Type_052C"]
        ["Czech hedgehogs 1"] = 
        {
        }, -- end of ["Czech hedgehogs 1"]
        ["trunks_long_cargo"] = 
        {
        }, -- end of ["trunks_long_cargo"]
        ["Sandbag_12"] = 
        {
        }, -- end of ["Sandbag_12"]
        ["Cargo02"] = 
        {
        }, -- end of ["Cargo02"]
        ["Hemmkurvenhindernis"] = 
        {
        }, -- end of ["Hemmkurvenhindernis"]
        ["Sandbag_04"] = 
        {
        }, -- end of ["Sandbag_04"]
        ["leander-gun-condell"] = 
        {
            ["detection"] = 150000,
            ["threat"] = 100000,
        }, -- end of ["leander-gun-condell"]
        ["Soldier M4"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["Soldier M4"]
        ["FA-18C_hornet"] = 
        {
            ["irsignature"] = 0.75,
        }, -- end of ["FA-18C_hornet"]
        ["AS32-32A"] = 
        {
        }, -- end of ["AS32-32A"]
        ["GAZ-3307"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["GAZ-3307"]
        ["RD_75"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 100000,
            ["threat"] = 0,
        }, -- end of ["RD_75"]
        ["Yak-52"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["Yak-52"]
        ["container_20ft"] = 
        {
        }, -- end of ["container_20ft"]
        ["billboard_motorized"] = 
        {
        }, -- end of ["billboard_motorized"]
        ["2B11 mortar"] = 
        {
            ["irsignature"] = 0.005,
            ["detection"] = 0,
            ["threat"] = 7000,
        }, -- end of ["2B11 mortar"]
        ["FarpHide_small"] = 
        {
        }, -- end of ["FarpHide_small"]
        ["Soldier stinger"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 5000,
            ["threat"] = 4500,
        }, -- end of ["Soldier stinger"]
        ["Log posts 2"] = 
        {
        }, -- end of ["Log posts 2"]
        ["Cow"] = 
        {
        }, -- end of ["Cow"]
        ["LARC-V"] = 
        {
            ["detection"] = 500,
            ["threat"] = 0,
        }, -- end of ["LARC-V"]
        ["P-47D-30"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["P-47D-30"]
        ["SA-18 Igla-S comm"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 5000,
            ["threat"] = 0,
        }, -- end of ["SA-18 Igla-S comm"]
        ["RPC_5N62V"] = 
        {
            ["detection"] = 400000,
            ["threat"] = 0,
        }, -- end of ["RPC_5N62V"]
        ["Dragonteeth 4"] = 
        {
        }, -- end of ["Dragonteeth 4"]
        ["P-47D-40"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["P-47D-40"]
        ["HL_ZU-23"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 5000,
            ["threat"] = 2500,
        }, -- end of ["HL_ZU-23"]
        ["I-16"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["I-16"]
        ["BMD-1"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["BMD-1"]
        ["Mirage-F1CH"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1CH"]
        ["Camouflage07"] = 
        {
        }, -- end of ["Camouflage07"]
        ["S_75_ZIL"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["S_75_ZIL"]
        ["F-14B"] = 
        {
            ["irsignature"] = 0.9,
        }, -- end of ["F-14B"]
        ["M30_CC"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 1200,
        }, -- end of ["M30_CC"]
        ["Belgian gate"] = 
        {
        }, -- end of ["Belgian gate"]
        ["C-130"] = 
        {
            ["irsignature"] = 1,
        }, -- end of ["C-130"]
        ["Carrier Seaman"] = 
        {
        }, -- end of ["Carrier Seaman"]
        ["Mirage-F1JA"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1JA"]
        ["GAZ-66"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["GAZ-66"]
        ["Locomotive"] = 
        {
            ["irsignature"] = 0.15,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Locomotive"]
        ["F-14A"] = 
        {
            ["irsignature"] = 0.97,
        }, -- end of ["F-14A"]
        ["HL_DSHK"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 5000,
            ["threat"] = 1200,
        }, -- end of ["HL_DSHK"]
        ["CV_59_H60"] = 
        {
        }, -- end of ["CV_59_H60"]
        ["L-39C"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["L-39C"]
        ["S-300PS 64H6E sr"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 160000,
            ["threat"] = 0,
        }, -- end of ["S-300PS 64H6E sr"]
        ["CVN_73"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 50000,
            ["threat"] = 25000,
        }, -- end of ["CVN_73"]
        ["HQ-7_STR_SP"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 30000,
            ["threat"] = 0,
        }, -- end of ["HQ-7_STR_SP"]
        ["Mi-24P"] = 
        {
            ["irsignature"] = 0.5,
        }, -- end of ["Mi-24P"]
        ["SOM"] = 
        {
            ["irsignature"] = 0.2,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["SOM"]
        ["TugHarlan"] = 
        {
        }, -- end of ["TugHarlan"]
        ["Yak-40"] = 
        {
            ["irsignature"] = 0.5,
        }, -- end of ["Yak-40"]
        ["Igla manpad INS"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 5000,
            ["threat"] = 5200,
        }, -- end of ["Igla manpad INS"]
        ["Sandbag_05"] = 
        {
        }, -- end of ["Sandbag_05"]
        ["HESCO_wallperimeter_2"] = 
        {
        }, -- end of ["HESCO_wallperimeter_2"]
        ["soldier_wwii_br_01"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["soldier_wwii_br_01"]
        ["Hawk sr"] = 
        {
            ["irsignature"] = 0.06,
            ["detection"] = 90000,
            ["threat"] = 0,
        }, -- end of ["Hawk sr"]
        ["v1_launcher"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["v1_launcher"]
        ["Paratrooper AKS-74"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["Paratrooper AKS-74"]
        ["MOSCOW"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 160000,
            ["threat"] = 75000,
        }, -- end of ["MOSCOW"]
        ["Carrier LSO Personell 3"] = 
        {
        }, -- end of ["Carrier LSO Personell 3"]
        ["Mi-26"] = 
        {
            ["irsignature"] = 1,
        }, -- end of ["Mi-26"]
        ["Pile of Woods"] = 
        {
        }, -- end of ["Pile of Woods"]
        ["outpost"] = 
        {
            ["irsignature"] = 0.007,
            ["detection"] = 0,
            ["threat"] = 800,
        }, -- end of ["outpost"]
        ["JF-17"] = 
        {
            ["irsignature"] = 0.6,
        }, -- end of ["JF-17"]
        ["KUZNECOW"] = 
        {
            ["irsignature"] = 0.45,
            ["detection"] = 25000,
            ["threat"] = 12000,
        }, -- end of ["KUZNECOW"]
        ["Building07_PBR"] = 
        {
        }, -- end of ["Building07_PBR"]
        ["Ural-375"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Ural-375"]
        ["Osa 9A33 ln"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 30000,
            ["threat"] = 10300,
        }, -- end of ["Osa 9A33 ln"]
        ["REZKY"] = 
        {
            ["irsignature"] = 0.35,
            ["detection"] = 30000,
            ["threat"] = 16000,
        }, -- end of ["REZKY"]
        ["Cargo04"] = 
        {
        }, -- end of ["Cargo04"]
        ["Oil Barrel"] = 
        {
        }, -- end of ["Oil Barrel"]
        ["Bedford_MWD"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Bedford_MWD"]
        ["Sandbag_10"] = 
        {
        }, -- end of ["Sandbag_10"]
        ["OH-58D"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["OH-58D"]
        ["l118"] = 
        {
        }, -- end of ["l118"]
        ["pipes_big_cargo"] = 
        {
        }, -- end of ["pipes_big_cargo"]
        ["B-17G"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["B-17G"]
        ["Land_Rover_109_S3"] = 
        {
            ["irsignature"] = 0.075,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Land_Rover_109_S3"]
        ["M32-10C_02"] = 
        {
        }, -- end of ["M32-10C_02"]
        ["C-101CC"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["C-101CC"]
        ["Smerch"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 70000,
        }, -- end of ["Smerch"]
        ["SAU 2-C9"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 7000,
        }, -- end of ["SAU 2-C9"]
        ["M32-10C_01"] = 
        {
        }, -- end of ["M32-10C_01"]
        ["fire_control"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 1100,
        }, -- end of ["fire_control"]
        ["M32-10C_03"] = 
        {
        }, -- end of ["M32-10C_03"]
        ["container_cargo"] = 
        {
        }, -- end of ["container_cargo"]
        ["Type_093"] = 
        {
            ["irsignature"] = 0.2,
            ["detection"] = 40000,
            ["threat"] = 40000,
        }, -- end of ["Type_093"]
        ["TICONDEROG"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 150000,
            ["threat"] = 100000,
        }, -- end of ["TICONDEROG"]
        ["FireExtinguisher02"] = 
        {
        }, -- end of ["FireExtinguisher02"]
        ["FPS-117 ECS"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["FPS-117 ECS"]
        ["ara_vdm"] = 
        {
            ["detection"] = 18000,
            ["threat"] = 5000,
        }, -- end of ["ara_vdm"]
        ["HESCO_watchtower_1"] = 
        {
        }, -- end of ["HESCO_watchtower_1"]
        ["AA8"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["AA8"]
        ["MCV-80"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 2500,
        }, -- end of ["MCV-80"]
        ["Building06_PBR"] = 
        {
        }, -- end of ["Building06_PBR"]
        ["Log ramps 1"] = 
        {
        }, -- end of ["Log ramps 1"]
        ["KJ-2000"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["KJ-2000"]
        ["HESCO_generator"] = 
        {
        }, -- end of ["HESCO_generator"]
        ["Sandbag_17"] = 
        {
        }, -- end of ["Sandbag_17"]
        ["barrels_cargo"] = 
        {
        }, -- end of ["barrels_cargo"]
        ["M4_Sherman"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["M4_Sherman"]
        ["ES44AH"] = 
        {
            ["irsignature"] = 0.15,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["ES44AH"]
        ["345 Excavator"] = 
        {
        }, -- end of ["345 Excavator"]
        ["Stanley_LightHouse"] = 
        {
        }, -- end of ["Stanley_LightHouse"]
        ["ATZ-60_Maz"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["ATZ-60_Maz"]
        ["Electric locomotive"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Electric locomotive"]
        ["FireExtinguisher01"] = 
        {
        }, -- end of ["FireExtinguisher01"]
        ["SA342Minigun"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["SA342Minigun"]
        ["Camouflage02"] = 
        {
        }, -- end of ["Camouflage02"]
        ["Wespe124"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 0,
            ["threat"] = 10500,
        }, -- end of ["Wespe124"]
        ["M12_GMC"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 18300,
        }, -- end of ["M12_GMC"]
        ["m117_cargo"] = 
        {
        }, -- end of ["m117_cargo"]
        ["VAZ Car"] = 
        {
            ["irsignature"] = 0.065,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["VAZ Car"]
        ["Toolbox01"] = 
        {
        }, -- end of ["Toolbox01"]
        ["ElevatedPlatform_up"] = 
        {
        }, -- end of ["ElevatedPlatform_up"]
        ["Predator TrojanSpirit"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Predator TrojanSpirit"]
        ["Mirage-F1EDA"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1EDA"]
        ["ZIL-4331"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["ZIL-4331"]
        ["AH-64D"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["AH-64D"]
        ["Dragonteeth 3"] = 
        {
        }, -- end of ["Dragonteeth 3"]
        ["P20_drivable"] = 
        {
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["P20_drivable"]
        ["Mirage-F1ED"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1ED"]
        ["F-117A"] = 
        {
            ["irsignature"] = 0.15,
        }, -- end of ["F-117A"]
        ["Cone01"] = 
        {
        }, -- end of ["Cone01"]
        ["M10_GMC"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 6000,
        }, -- end of ["M10_GMC"]
        ["Suidae"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Suidae"]
        ["flak36"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 5000,
        }, -- end of ["flak36"]
        ["RLS_19J6"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 150000,
            ["threat"] = 0,
        }, -- end of ["RLS_19J6"]
        ["Tornado IDS"] = 
        {
            ["irsignature"] = 0.6,
        }, -- end of ["Tornado IDS"]
        ["rapier_fsa_blindfire_radar"] = 
        {
            ["irsignature"] = 0.03,
            ["detection"] = 30000,
            ["threat"] = 0,
        }, -- end of ["rapier_fsa_blindfire_radar"]
        ["SH-60B"] = 
        {
            ["irsignature"] = 0.35,
        }, -- end of ["SH-60B"]
        ["ZBD04A"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 4800,
        }, -- end of ["ZBD04A"]
        ["KS-19"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 20000,
        }, -- end of ["KS-19"]
        ["Strela-1 9P31"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 5000,
            ["threat"] = 4200,
        }, -- end of ["Strela-1 9P31"]
        ["us carrier shooter"] = 
        {
        }, -- end of ["us carrier shooter"]
        ["M1128 Stryker MGS"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 0,
            ["threat"] = 4000,
        }, -- end of ["M1128 Stryker MGS"]
        ["leander-gun-lynch"] = 
        {
            ["detection"] = 180000,
            ["threat"] = 140000,
        }, -- end of ["leander-gun-lynch"]
        ["MiG-25RBT"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["MiG-25RBT"]
        ["F-86F Sabre"] = 
        {
            ["irsignature"] = 0.25,
        }, -- end of ["F-86F Sabre"]
        ["C-17A"] = 
        {
            ["irsignature"] = 3,
        }, -- end of ["C-17A"]
        ["CVN_71"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 50000,
            ["threat"] = 25000,
        }, -- end of ["CVN_71"]
        ["VINSON"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 30000,
            ["threat"] = 15000,
        }, -- end of ["VINSON"]
        ["Tent03"] = 
        {
        }, -- end of ["Tent03"]
        ["BoomBarrier_closed"] = 
        {
        }, -- end of ["BoomBarrier_closed"]
        ["Sandbag_06"] = 
        {
        }, -- end of ["Sandbag_06"]
        ["Mirage-F1EQ"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1EQ"]
        ["Forrestal"] = 
        {
            ["detection"] = 50000,
            ["threat"] = 25000,
        }, -- end of ["Forrestal"]
        ["PERRY"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 150000,
            ["threat"] = 100000,
        }, -- end of ["PERRY"]
        ["MiG-19P"] = 
        {
            ["irsignature"] = 0.34,
        }, -- end of ["MiG-19P"]
        ["MiG-25PD"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["MiG-25PD"]
        ["Building05_PBR"] = 
        {
        }, -- end of ["Building05_PBR"]
        ["TPZ"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 1000,
        }, -- end of ["TPZ"]
        ["C-101EB"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["C-101EB"]
        ["An-30M"] = 
        {
            ["irsignature"] = 0.5,
        }, -- end of ["An-30M"]
        ["S-200_Launcher"] = 
        {
            ["detection"] = 0,
            ["threat"] = 255000,
        }, -- end of ["S-200_Launcher"]
        ["Mirage-F1M-EE"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1M-EE"]
        ["Mirage-F1CR"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1CR"]
        ["Cargo03"] = 
        {
        }, -- end of ["Cargo03"]
        ["Barrier D"] = 
        {
        }, -- end of ["Barrier D"]
        ["Barrier C"] = 
        {
        }, -- end of ["Barrier C"]
        ["Barrier B"] = 
        {
        }, -- end of ["Barrier B"]
        ["Fire Control Bunker"] = 
        {
        }, -- end of ["Fire Control Bunker"]
        ["rapier_fsa_optical_tracker_unit"] = 
        {
            ["irsignature"] = 0.03,
            ["detection"] = 20000,
            ["threat"] = 0,
        }, -- end of ["rapier_fsa_optical_tracker_unit"]
        ["MJ-1_drivable"] = 
        {
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["MJ-1_drivable"]
        ["La_Combattante_II"] = 
        {
            ["irsignature"] = 0.35,
            ["detection"] = 19000,
            ["threat"] = 4000,
        }, -- end of ["La_Combattante_II"]
        ["KC-135"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["KC-135"]
        ["MQ-9 Reaper"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["MQ-9 Reaper"]
        ["Camouflage01"] = 
        {
        }, -- end of ["Camouflage01"]
        ["LHA_Tarawa"] = 
        {
            ["detection"] = 150000,
            ["threat"] = 20000,
        }, -- end of ["LHA_Tarawa"]
        ["Scud_B"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 285000,
        }, -- end of ["Scud_B"]
        ["CHAP_9K720_HE"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 398180,
        }, -- end of ["CHAP_9K720_HE"]
        ["CHAP_9K720_Cluster"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 398180,
        }, -- end of ["CHAP_9K720_Cluster"]
        ["NASAMS_LN_C"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 15000,
        }, -- end of ["NASAMS_LN_C"]
        ["B600"] = 
        {
        }, -- end of ["B600"]
        ["CCKW_353"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["CCKW_353"]
        ["SA-18 Igla comm"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 5000,
            ["threat"] = 0,
        }, -- end of ["SA-18 Igla comm"]
        ["T-90"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 5000,
        }, -- end of ["T-90"]
        ["Patriot ECS"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Patriot ECS"]
        ["A-10A"] = 
        {
            ["irsignature"] = 0.53,
        }, -- end of ["A-10A"]
        ["NF-2_LightOn"] = 
        {
        }, -- end of ["NF-2_LightOn"]
        ["Pak40"] = 
        {
            ["irsignature"] = 0.04,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["Pak40"]
        ["Coach cargo open"] = 
        {
            ["irsignature"] = 0,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Coach cargo open"]
        ["IKARUS Bus"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["IKARUS Bus"]
        ["house1arm"] = 
        {
            ["irsignature"] = 0.007,
            ["detection"] = 0,
            ["threat"] = 800,
        }, -- end of ["house1arm"]
        ["Hawk ln"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 45000,
        }, -- end of ["Hawk ln"]
        ["SA Ski Ramp"] = 
        {
        }, -- end of ["SA Ski Ramp"]
        ["Mi-28N"] = 
        {
            ["irsignature"] = 0.3,
        }, -- end of ["Mi-28N"]
        ["Hawk cwar"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 70000,
            ["threat"] = 0,
        }, -- end of ["Hawk cwar"]
        ["F-16C bl.50"] = 
        {
            ["irsignature"] = 0.6,
        }, -- end of ["F-16C bl.50"]
        ["SA-11 Buk SR 9S18M1"] = 
        {
            ["irsignature"] = 0.095,
            ["detection"] = 100000,
            ["threat"] = 0,
        }, -- end of ["SA-11 Buk SR 9S18M1"]
        ["Sd_Kfz_234_2_Puma"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 2000,
        }, -- end of ["Sd_Kfz_234_2_Puma"]
        ["Schnellboot_type_S130"] = 
        {
            ["irsignature"] = 0.3,
            ["detection"] = 10000,
            ["threat"] = 4000,
        }, -- end of ["Schnellboot_type_S130"]
        ["AS32-31A"] = 
        {
        }, -- end of ["AS32-31A"]
        ["M1097 Avenger"] = 
        {
            ["irsignature"] = 0.075,
            ["detection"] = 5200,
            ["threat"] = 4500,
        }, -- end of ["M1097 Avenger"]
        ["flak38"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 2500,
        }, -- end of ["flak38"]
        ["WindTurbine_11"] = 
        {
        }, -- end of ["WindTurbine_11"]
        ["M4_Tractor"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 1200,
        }, -- end of ["M4_Tractor"]
        ["JTAC"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["JTAC"]
        ["Mirage-F1M-CE"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1M-CE"]
        ["M1_37mm"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 5700,
        }, -- end of ["M1_37mm"]
        ["KrAZ6322"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["KrAZ6322"]
        ["Stinger comm dsr"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 5000,
            ["threat"] = 0,
        }, -- end of ["Stinger comm dsr"]
        ["Higgins_boat"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 3000,
            ["threat"] = 1000,
        }, -- end of ["Higgins_boat"]
        ["Su-24MR"] = 
        {
            ["irsignature"] = 1.5,
        }, -- end of ["Su-24MR"]
        ["Jerrycan"] = 
        {
        }, -- end of ["Jerrycan"]
        ["warning_board_b"] = 
        {
        }, -- end of ["warning_board_b"]
        ["ATMZ-5"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["ATMZ-5"]
        ["leander-gun-andromeda"] = 
        {
            ["detection"] = 180000,
            ["threat"] = 140000,
        }, -- end of ["leander-gun-andromeda"]
        ["SA342Mistral"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["SA342Mistral"]
        ["SA-11 Buk CC 9S470M1"] = 
        {
            ["irsignature"] = 0.095,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["SA-11 Buk CC 9S470M1"]
        ["German_tank_wagon"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["German_tank_wagon"]
        ["Soldier M4 GRG"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["Soldier M4 GRG"]
        ["Mi-24V"] = 
        {
            ["irsignature"] = 0.5,
        }, -- end of ["Mi-24V"]
        ["MiG-31"] = 
        {
            ["irsignature"] = 3,
        }, -- end of ["MiG-31"]
        ["leander-gun-achilles"] = 
        {
            ["detection"] = 180000,
            ["threat"] = 8000,
        }, -- end of ["leander-gun-achilles"]
        ["M-113"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 1200,
        }, -- end of ["M-113"]
        ["MB-339A"] = 
        {
            ["irsignature"] = 0.2,
        }, -- end of ["MB-339A"]
        ["Soldier M249"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 700,
        }, -- end of ["Soldier M249"]
        ["Mirage 2000-5"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage 2000-5"]
        ["Tent04"] = 
        {
        }, -- end of ["Tent04"]
        ["flak18"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 5000,
        }, -- end of ["flak18"]
        ["Building02_PBR"] = 
        {
        }, -- end of ["Building02_PBR"]
        ["MiG-21Bis"] = 
        {
            ["irsignature"] = 0.6,
        }, -- end of ["MiG-21Bis"]
        ["Roland Radar"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 35000,
            ["threat"] = 0,
        }, -- end of ["Roland Radar"]
        ["MiG-29S"] = 
        {
            ["irsignature"] = 0.77,
        }, -- end of ["MiG-29S"]
        ["Ural ATsP-6"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Ural ATsP-6"]
        ["Su-33"] = 
        {
            ["irsignature"] = 1,
        }, -- end of ["Su-33"]
        ["Coach a tank blue"] = 
        {
            ["irsignature"] = 0,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Coach a tank blue"]
        ["Centaur_IV"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 6000,
        }, -- end of ["Centaur_IV"]
        ["M4A4_Sherman_FF"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["M4A4_Sherman_FF"]
        ["Christen Eagle II"] = 
        {
            ["irsignature"] = 0.04,
        }, -- end of ["Christen Eagle II"]
        ["Sandbag_03"] = 
        {
        }, -- end of ["Sandbag_03"]
        ["BTR_D"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["BTR_D"]
        ["Nodding_Donkey_Pump"] = 
        {
        }, -- end of ["Nodding_Donkey_Pump"]
        ["AM32a-60_01"] = 
        {
        }, -- end of ["AM32a-60_01"]
        ["AM32a-60_02"] = 
        {
        }, -- end of ["AM32a-60_02"]
        ["Kubelwagen_82"] = 
        {
            ["irsignature"] = 0.065,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Kubelwagen_82"]
        ["flak37"] = 
        {
            ["irsignature"] = 0.01,
            ["detection"] = 0,
            ["threat"] = 5000,
        }, -- end of ["flak37"]
        ["Twall_x1"] = 
        {
        }, -- end of ["Twall_x1"]
        ["Sandbag_15"] = 
        {
        }, -- end of ["Sandbag_15"]
        ["M-2 Bradley"] = 
        {
            ["irsignature"] = 0.095,
            ["detection"] = 0,
            ["threat"] = 3800,
        }, -- end of ["M-2 Bradley"]
        ["M-1 Abrams"] = 
        {
            ["irsignature"] = 0.15,
            ["detection"] = 0,
            ["threat"] = 3500,
        }, -- end of ["M-1 Abrams"]
        ["Cromwell_IV"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["Cromwell_IV"]
        ["F-16C_50"] = 
        {
            ["irsignature"] = 0.6,
        }, -- end of ["F-16C_50"]
        ["PIOTR"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 250000,
            ["threat"] = 190000,
        }, -- end of ["PIOTR"]
        ["Wellcarnsc"] = 
        {
            ["irsignature"] = 0,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Wellcarnsc"]
        ["Building01_PBR"] = 
        {
        }, -- end of ["Building01_PBR"]
        ["Cargo05"] = 
        {
        }, -- end of ["Cargo05"]
        ["Sandbag_01"] = 
        {
        }, -- end of ["Sandbag_01"]
        ["Camouflage04"] = 
        {
        }, -- end of ["Camouflage04"]
        ["SH-3W"] = 
        {
            ["irsignature"] = 0.72,
        }, -- end of ["SH-3W"]
        ["F-15ESE"] = 
        {
            ["irsignature"] = 0.91,
        }, -- end of ["F-15ESE"]
        ["SpitfireLFMkIXCW"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["SpitfireLFMkIXCW"]
        ["S-300PS 54K6 cp"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["S-300PS 54K6 cp"]
        ["hms_invincible"] = 
        {
            ["detection"] = 100000,
            ["threat"] = 74000,
        }, -- end of ["hms_invincible"]
        ["Tor 9A331"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 25000,
            ["threat"] = 12000,
        }, -- end of ["Tor 9A331"]
        ["Sandbox"] = 
        {
            ["irsignature"] = 0,
            ["detection"] = 0,
            ["threat"] = 800,
        }, -- end of ["Sandbox"]
        ["IMPROVED_KILO"] = 
        {
            ["irsignature"] = 0.2,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["IMPROVED_KILO"]
        ["Flakscheinwerfer_37"] = 
        {
            ["irsignature"] = 0.3,
            ["detection"] = 15000,
            ["threat"] = 15000,
        }, -- end of ["Flakscheinwerfer_37"]
        ["T-72B3"] = 
        {
            ["irsignature"] = 0.105,
            ["detection"] = 0,
            ["threat"] = 4000,
        }, -- end of ["T-72B3"]
        ["Ural-375 ZU-23"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 5000,
            ["threat"] = 2500,
        }, -- end of ["Ural-375 ZU-23"]
        ["KDO_Mod40"] = 
        {
            ["irsignature"] = 0.03,
            ["detection"] = 30000,
            ["threat"] = 0,
        }, -- end of ["KDO_Mod40"]
        ["Patriot str"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 160000,
            ["threat"] = 0,
        }, -- end of ["Patriot str"]
        ["F-5E-3"] = 
        {
            ["irsignature"] = 0.4,
        }, -- end of ["F-5E-3"]
        ["HEMTT TFFT"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["HEMTT TFFT"]
        ["Cone02"] = 
        {
        }, -- end of ["Cone02"]
        ["M-60"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 8000,
        }, -- end of ["M-60"]
        ["Stennis"] = 
        {
            ["irsignature"] = 0.4,
            ["detection"] = 50000,
            ["threat"] = 25000,
        }, -- end of ["Stennis"]
        ["Shelter02"] = 
        {
        }, -- end of ["Shelter02"]
        ["Mirage-F1CK"] = 
        {
            ["irsignature"] = 0.8,
        }, -- end of ["Mirage-F1CK"]
        ["F-15C"] = 
        {
            ["irsignature"] = 0.85,
        }, -- end of ["F-15C"]
        ["Su-25TM"] = 
        {
            ["irsignature"] = 0.7,
        }, -- end of ["Su-25TM"]
        ["iso_container_small"] = 
        {
        }, -- end of ["iso_container_small"]
        ["Container_generator"] = 
        {
        }, -- end of ["Container_generator"]
        ["Maschinensatz_33"] = 
        {
            ["irsignature"] = 0.07,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Maschinensatz_33"]
        ["TF-51D"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["TF-51D"]
        ["Leclerc"] = 
        {
            ["irsignature"] = 0.12,
            ["detection"] = 0,
            ["threat"] = 3500,
        }, -- end of ["Leclerc"]
        ["Blitz_36-6700A"] = 
        {
            ["irsignature"] = 0.75,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Blitz_36-6700A"]
        ["NASAMS_Command_Post"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["NASAMS_Command_Post"]
        ["Infantry AK ver3"] = 
        {
            ["irsignature"] = 0.004,
            ["detection"] = 0,
            ["threat"] = 500,
        }, -- end of ["Infantry AK ver3"]
        ["MiG-27K"] = 
        {
            ["irsignature"] = 0.69,
        }, -- end of ["MiG-27K"]
        ["Camouflage05"] = 
        {
        }, -- end of ["Camouflage05"]
        ["Log posts 3"] = 
        {
        }, -- end of ["Log posts 3"]
        ["Coach a platform"] = 
        {
            ["irsignature"] = 0,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Coach a platform"]
        ["iso_container"] = 
        {
        }, -- end of ["iso_container"]
        ["A-10C"] = 
        {
            ["irsignature"] = 0.53,
        }, -- end of ["A-10C"]
        ["Small_LightHouse"] = 
        {
        }, -- end of ["Small_LightHouse"]
        ["speedboat"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 5000,
            ["threat"] = 1000,
        }, -- end of ["speedboat"]
        ["Su-24M"] = 
        {
            ["irsignature"] = 1.5,
        }, -- end of ["Su-24M"]
        ["HESCO_wallperimeter_4"] = 
        {
        }, -- end of ["HESCO_wallperimeter_4"]
        ["HL_KORD"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 5000,
            ["threat"] = 1200,
        }, -- end of ["HL_KORD"]
        ["MiG-29A"] = 
        {
            ["irsignature"] = 0.77,
        }, -- end of ["MiG-29A"]
        ["NF-2_LightOff01"] = 
        {
        }, -- end of ["NF-2_LightOff01"]
        ["Ural-375 ZU-23 Insurgent"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 5000,
            ["threat"] = 2500,
        }, -- end of ["Ural-375 ZU-23 Insurgent"]
        ["ZTZ96B"] = 
        {
            ["irsignature"] = 0.12,
            ["detection"] = 0,
            ["threat"] = 5000,
        }, -- end of ["ZTZ96B"]
        ["Grad-URAL"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 0,
            ["threat"] = 19000,
        }, -- end of ["Grad-URAL"]
        ["Haystack 2"] = 
        {
        }, -- end of ["Haystack 2"]
        ["HESCO_watchtower_3"] = 
        {
        }, -- end of ["HESCO_watchtower_3"]
        ["Coach a tank yellow"] = 
        {
            ["irsignature"] = 0,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Coach a tank yellow"]
        ["Uboat_VIIC"] = 
        {
            ["irsignature"] = 0.25,
            ["detection"] = 20000,
            ["threat"] = 4000,
        }, -- end of ["Uboat_VIIC"]
        ["Sandbag_09"] = 
        {
        }, -- end of ["Sandbag_09"]
        ["B-1B"] = 
        {
            ["irsignature"] = 3,
        }, -- end of ["B-1B"]
        ["Sandbag_07"] = 
        {
        }, -- end of ["Sandbag_07"]
        ["PLZ05"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 23500,
        }, -- end of ["PLZ05"]
        ["C-47"] = 
        {
            ["irsignature"] = 0.1,
        }, -- end of ["C-47"]
        ["F-16A"] = 
        {
            ["irsignature"] = 0.6,
        }, -- end of ["F-16A"]
        ["leander-gun-ariadne"] = 
        {
            ["detection"] = 150000,
            ["threat"] = 100000,
        }, -- end of ["leander-gun-ariadne"]
        ["F-16A MLU"] = 
        {
            ["irsignature"] = 0.6,
        }, -- end of ["F-16A MLU"]
        ["M1134 Stryker ATGM"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 0,
            ["threat"] = 3800,
        }, -- end of ["M1134 Stryker ATGM"]
        ["FlagPole"] = 
        {
        }, -- end of ["FlagPole"]
        ["Roland ADS"] = 
        {
            ["irsignature"] = 0.085,
            ["detection"] = 12000,
            ["threat"] = 8000,
        }, -- end of ["Roland ADS"]
        ["MiG-29G"] = 
        {
            ["irsignature"] = 0.77,
        }, -- end of ["MiG-29G"]
        ["Twall_x6_3mts"] = 
        {
        }, -- end of ["Twall_x6_3mts"]
        ["F/A-18C"] = 
        {
            ["irsignature"] = 0.73,
        }, -- end of ["F/A-18C"]
        ["warning_board_a"] = 
        {
        }, -- end of ["warning_board_a"]
        ["Ship_Tilde_Supply"] = 
        {
            ["irsignature"] = 0.35,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Ship_Tilde_Supply"]
        ["Sandbag_08"] = 
        {
        }, -- end of ["Sandbag_08"]
        ["Land_Rover_101_FC"] = 
        {
            ["irsignature"] = 0.075,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Land_Rover_101_FC"]
        ["Pz_IV_H"] = 
        {
            ["irsignature"] = 0.1,
            ["detection"] = 0,
            ["threat"] = 3000,
        }, -- end of ["Pz_IV_H"]
        ["Grad_FDDM"] = 
        {
            ["irsignature"] = 0.09,
            ["detection"] = 0,
            ["threat"] = 1000,
        }, -- end of ["Grad_FDDM"]
        ["Concertina wire"] = 
        {
        }, -- end of ["Concertina wire"]
        ["Tetrahydra"] = 
        {
        }, -- end of ["Tetrahydra"]
        ["Log posts 1"] = 
        {
        }, -- end of ["Log posts 1"]
        ["A-50"] = 
        {
            ["irsignature"] = 4,
        }, -- end of ["A-50"]
        ["Patriot AMG"] = 
        {
            ["irsignature"] = 0.05,
            ["detection"] = 0,
            ["threat"] = 0,
        }, -- end of ["Patriot AMG"]
        ["tt_DSHK"] = 
        {
            ["irsignature"] = 0.08,
            ["detection"] = 5000,
            ["threat"] = 1200,
        }, -- end of ["tt_DSHK"]
    }
end

--###### UTIL FUNCTIONS ############################################################################

-- all the below functions are basically elements used in other part of the code. Many of them are basically copy or modified copy of other useful code and script, 
-- the credits list would be quite long but mostly mist, MOOSE, CTLD. When able I kept the original name even if slightly modified.

local function escape_string(str)
    local replacements = {
        ['%'] = '%%',
        ['^'] = '%^',
        ['$'] = '%$',
        ['('] = '%(',
        [')'] = '%)',
        ['%['] = '%[%]',
        ['{'] = '%{',
        ['}'] = '%}',
        ['.'] = '%.',
        ['*'] = '%*',
        ['+'] = '%+',
        ['-'] = '%-',
        ['?'] = '%?',
        ['\0'] = '%z'
    }
    
    return (str:gsub(".", replacements))
end

local function contains(haystack, needle)
    -- Effettua l'escape dei caratteri speciali nella stringa 'needle'
    local function escape_special_characters(str)
        local replacements = {
            ['%'] = '%%',
            ['^'] = '%^',
            ['$'] = '%$',
            ['('] = '%(',
            [')'] = '%)',
            ['%['] = '%[%]',
            ['{'] = '%{',
            ['}'] = '%}',
            ['.'] = '%.',
            ['*'] = '%*',
            ['+'] = '%+',
            ['-'] = '%-',
            ['?'] = '%?',
            ['\0'] = '%z'
        }
        
        return (str:gsub(".", replacements))
    end

    -- Escape della stringa 'needle'
    local escaped_needle = escape_special_characters(needle)
    
    -- Controlla se 'needle' è contenuta in 'haystack'
    return haystack:find(escaped_needle) ~= nil
end

local function vec3Check(vec3)
    if vec3 then
        if type(vec3) == 'table' then -- assuming name
            if vec3.x and vec3.y and vec3.z then			
                return vec3
            elseif vec3.x and vec3.y and vec3.z == nil then
                env.info((tostring(ModuleName) .. ", vec3Check: vector is vec2, converting to vec3"))
                local new_y = land.getHeight({x = vec3.x, y = vec3.y})
                
                if new_y then
                    local new_Vec3 = {x = vec3.x, y = new_y, z = vec3.y}
                    return new_Vec3
                else
                    env.info((tostring(ModuleName) .. ", vec3Check: vector is vec2, but no height found, returning nil"))
                    return nil
                end
            else
                env.info((tostring(ModuleName) .. ", vec3Check: wrong vector format"))
                return nil
            end
        else
            env.info((tostring(ModuleName) .. ", vec3Check: wrong variable"))
            return nil
        end
    else
        env.info((tostring(ModuleName) .. ", vec3Check: missing variable"))
        return nil
    end
end

local function getDist(point1, point2, rounded)
    local xUnit = point1.x
    local yUnit = nil
    local xZone = point2.x
    local yZone = nil	
	if point1.z then
		yUnit = point1.z
	elseif point1.y then
		yUnit = point1.y
	end
	if point2.z then
		yZone = point2.z
	elseif point2.y then
		yZone = point2.y
	end
    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone

    local dist = math.sqrt(xDiff * xDiff + yDiff * yDiff)
    if rounded == true then
        return math.floor(dist)
    else
        return dist
    end

    return math.sqrt(xDiff * xDiff + yDiff * yDiff)
end

local function groupTableCheck(group)
    if group then
        if type(group) == 'string' then -- assuming name
            local groupTable = Group.getByName(group)

            if not groupTable then
                groupTable = StaticObject.getByName(group)
            end

            if groupTable then
                return groupTable
            else
                return nil
            end
        elseif type(group) == 'table' then
            return group
        else
            env.info((tostring(ModuleName) .. ", groupTableCheck: wrong variable"))
            return nil
        end
    else
        env.info((tostring(ModuleName) .. ", groupTableCheck: missing variable"))
        return nil
    end
end

local function aie_random(firstNum, secondNum)
    local lowNum, highNum
    if not secondNum then
        highNum = firstNum
        lowNum = 1
    else
        lowNum = firstNum
        highNum = secondNum
    end
    local total = 1
    if math.abs(highNum - lowNum + 1) < 50 then -- if total values is less than 50
        total = math.modf(50/math.abs(highNum - lowNum + 1)) -- make x copies required to be above 50
    end
    local choices = {}
    for i = 1, total do -- iterate required number of times
        for x = lowNum, highNum do -- iterate between the range
            choices[#choices +1] = x -- add each entry to a table
        end
    end
    local rtnVal = math.random(#choices) -- will now do a math.random of at least 50 choices
    for i = 1, 10 do
        rtnVal = math.random(#choices) -- iterate a few times for giggles
    end
    return choices[rtnVal]
end

local function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end 

local function buildWP(point, overRideForm, overRideSpeed)

    if point then 
        local wp = {}
        wp.x = point.x

        if point.z then
            wp.y = point.z
        else
            wp.y = point.y
        end
        local form, speed

        if point.speed and not overRideSpeed then
            wp.speed = point.speed
        elseif type(overRideSpeed) == 'number' then
            wp.speed = overRideSpeed
        else
            wp.speed = 18/3.6
        end

        if point.form and not overRideForm then
            form = point.form
        else
            form = overRideForm
        end

        if not form then
            wp.action = 'Off Road'
        else
            form = string.lower(form)
            if form == 'off_road' or form == 'off road' then
                wp.action = 'Off Road'
            elseif form == 'on_road' or form == 'on road' then
                wp.action = 'On Road'
            elseif form == 'rank' or form == 'line_abrest' or form == 'line abrest' or form == 'lineabrest'then
                wp.action = 'Rank'
            elseif form == 'cone' then
                wp.action = 'Cone'
            elseif form == 'diamond' then
                wp.action = 'Diamond'
            elseif form == 'vee' then
                wp.action = 'Vee'
            elseif form == 'echelon_left' or form == 'echelon left' or form == 'echelonl' then
                wp.action = 'EchelonL'
            elseif form == 'echelon_right' or form == 'echelon right' or form == 'echelonr' then
                wp.action = 'EchelonR'
            else
                wp.action = 'Off Road' -- if nothing matched
            end
        end

        wp.type = 'Turning Point'

        return wp
    else
        return false
    end
end

local function getRandPointInCircle(point, radius, innerRadius) --
    local theta = 2*math.pi*math.random()
    local rad = math.random() + math.random()
    if rad > 1 then
        rad = 2 - rad
    end

    local radMult
    if innerRadius and innerRadius <= radius then
        radMult = (radius - innerRadius)*rad + innerRadius
    else
        radMult = radius*rad
    end

    if not point.z then --might as well work with vec2/3
        point.z = point.y
    end

    local rndCoord
    if radius > 0 then
        rndCoord = {x = math.cos(theta)*radMult + point.x, y = math.sin(theta)*radMult + point.z}
    else
        rndCoord = {x = point.x, y = point.z}
    end
    return rndCoord
end 
local function getRandTerrainPointInCircleOriginal(var, radius, innerRadius, requestV3)
    local point = vec3Check(var)	
    if point and radius and innerRadius then
        for i = 1, 5 do
            local coordRun = getRandPointInCircle(point, radius, innerRadius)
            local destlandtype = land.getSurfaceType({coordRun.x, coordRun.z})
            if destlandtype == 1 or destlandtype == 4 then
                if requestV3 == true then
                    local c2 = {x = coordRun.x, y = land.getHeight({x = coordRun.x, y = coordRun.y}), z = coordRun.y}
                    return c2
                else
                    return coordRun
                end
            end
        end
        return nil -- this means that no valid result has found
        
    end
end
local function AienPoint(p)
    local z = p.z or p.y
    return { x = p.x, y = land.getHeight({ x = p.x, y = z }), z = z }
end

function rndInZone(z)
  local d = trigger.misc.getZone(z)
  if not d then 
    env.info("[AIEN] rndInZone: trigger.misc.getZone(" .. tostring(z) .. ") returned nil")
    return nil 
  end
  local r = d.radius * math.sqrt(math.random())
  local a = math.random() * 6.28318
  local x = d.point.x + r * math.cos(a)
  local z = d.point.z + r * math.sin(a)
  local y = land.getHeight({ x = x, y = z })
  return { x = x, y = y, z = z }
end

local function getRandTerrainPointInCircle(var, radius, innerRadius, requestV3)
    local point = vec3Check(var)
    if not (point and radius and innerRadius) then
        return nil
    end
    local FORCE_FALLBACK = false
    if not FORCE_FALLBACK then
        local zd    = bc:getZoneOfPoint(point)
        local cz    = zd and zd.zone and CustomZone:getByName(zd.zone)
        if cz then
            local sub = cz:getRandomUnusedSpawnZone(false)
            if not sub then
                sub = cz:getRandomSpawnZone()
            end

            if sub then
                env.info(("[AIEN] Trying subzone: %s"):format(sub))
                for _ = 1, 2 do
                    local p = rndInZone(sub)
                    if p then
                        local surf = land.getSurfaceType({ x = p.x, y = p.z })
                        if surf == 1 or surf == 4 then
                            env.info(("[AIEN]   Accepted subzone: %s"):format(sub))
                            if requestV3 then
                                return AienPoint(p)
                            else
                                return { x = p.x, y = p.z }
                            end
                        else
                            env.info(("[AIEN]   Rejected subzone: %s, bad surface (%s)")
                                :format(sub, tostring(surf)))
                        end
                    else
                        env.info(("[AIEN]   rndInZone returned nil for subzone: %s")
                            :format(sub))
                    end
                end
            end
        end
    end

    -- main-zone fallback
    local zd       = bc:getZoneOfPoint(point)
    local mainZone = zd and zd.zone

    --env.info("[AIEN] All subzones failed, using GetValidCords fallback")
    local coordObj = GetValidCords(
        mainZone or "",
        { [land.SurfaceType.LAND] = true, [land.SurfaceType.ROAD] = true },
        20
    )
    if coordObj then
        --env.info("[AIEN] Fallback accepted from GetValidCords")
        local raw = coordObj:GetVec2()
        if requestV3 then
            env.info("Valid Coords came from the Fallback RequestV3")
            return AienPoint(raw)
        else
            env.info("Valid Coords came from the Fallback else")
            return { x = raw.x, y = raw.y }
        end
    end

    --env.info("[AIEN] Fallback exhausted: no valid coord found")
    return nil
end

local function deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

local getRoadPt = land.getClosestPointOnRoads
local function isRoadClose(pt,limit)
    local rx,rz = getRoadPt('roads',pt.x,pt.z)
    if not rx then return false end
    local dx, dz = pt.x-rx, pt.z-rz
    return dx*dx + dz*dz <= (limit or 1000)^2
end

local function multyTypeMessage(var)
    local mexType       = var[1]
    local mexText       = var[2]
    local mexDuration   = var[3]
    local mexPos        = var[4]
    local unitId        = var[5]
    local groupId       = var[6]
    local countryId     = var[7]
    local coaId         = var[8]
    local mexAuthor     = var[9]
    local voiceGender   = var[10]

    -- text message
    if mexType == "text" or mexType == "both" then
        if mexText and type(mexText) == "string" then

            local t = mexDuration
            if not t then t = 30 end

            if unitId then
                trigger.action.outTextForGroup(unitId, mexText, t)            
            elseif groupId then
                trigger.action.outTextForGroup(groupId, mexText, t)
            elseif countryId then
                trigger.action.outTextForCoalition(countryId, mexText, t)
            elseif coaId then
                trigger.action.outTextForCoalition(coaId, mexText, t)
            else
                trigger.action.outText(mexText, t)
            end

        else
            env.info((tostring(ModuleName) .. " multyTypeMessage, mexText is not a valid input"))
        end
    end

end

local function vecmag(vec)
	return (vec.x^2 + vec.y^2 + vec.z^2)^0.5
end


local function getNorthCorrection(gPoint)
	local point = deepCopy(gPoint)
	if not point.z then --Vec2; convert to Vec3
		point.z = point.y
		point.y = 0
	end
	local lat, lon = coord.LOtoLL(point)
	local north_posit = coord.LLtoLO(lat + 1, lon)
	return math.atan2(north_posit.z - point.z, north_posit.x - point.x)
end

local function kmphToMps(kmph)
	return kmph/3.6
end

local function pointBetween(p1, p2, d)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local dz = p2.z - p1.z

    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

    if d >= dist then
        return {x = p2.x, y = p2.y, z = p2.z}
    end

    local scale = d / dist

    return {
        x = p1.x + dx * scale,
        y = p1.y + dy * scale,
        z = p1.z + dz * scale
    }
end

local function getTerrainSlopeAtPoint(p1, radius)
    radius = radius or 5  -- raggio in metri per campionare il terreno

    -- Punti attorno a p1
    local offsets = {
        {x = radius, z = 0},    -- Est
        {x = -radius, z = 0},   -- Ovest
        {x = 0, z = radius},    -- Nord
        {x = 0, z = -radius},   -- Sud
    }

    local maxSlope = 0

    for _, offset in ipairs(offsets) do
        local p2 = {
            x = p1.x + offset.x,
            y = 0,
            z = p1.z + offset.z
        }

        local alt1 = land.getHeight({x = p1.x, y = 0, z = p1.z})
        local alt2 = land.getHeight(p2)

        local dz = alt2 - alt1
        local dxz = math.sqrt(offset.x^2 + offset.z^2)

        local slopeRad = math.atan(dz / dxz)
        local slopeDeg = math.deg(math.abs(slopeRad))

        if slopeDeg > maxSlope then
            maxSlope = slopeDeg
        end
    end

    return maxSlope  -- Ritorna l'inclinazione massima in gradi
end


-- revTODO the code below is not used; an error? -> Chromium: check this out -> nope will be used
local function getHeading(unit, rawHeading)
	local unitpos = unit:getPosition()
	if unitpos then
		local Heading = math.atan2(unitpos.x.z, unitpos.x.x)
		if not rawHeading then
			Heading = Heading + getNorthCorrection(unitpos.p)
		end
		if Heading < 0 then
			Heading = Heading + 2*math.pi	-- put heading in range of 0 to 2*pi
		end
		return Heading
	end
end

local function makeVec3(vec, y)
	if not vec.z then
		if vec.alt and not y then
			y = vec.alt
		elseif not y then
			y = 0
		end
		return {x = vec.x, y = y, z = vec.y}
	else
		return {x = vec.x, y = vec.y, z = vec.z}	-- it was already Vec3, actually.
	end
end

local function avgVec3(tblPos)
    local avgPoint = {x = 0, y = 0, z = 0}
    local numpoints = #tblPos

    if numpoints == 0 then
        return avgPoint
    end

    for _, punto in ipairs(tblPos) do
        avgPoint.x = avgPoint.x + punto.x
        avgPoint.y = avgPoint.y + punto.y
        avgPoint.z = avgPoint.z + punto.z
    end

    avgPoint.x = avgPoint.x / numpoints
    avgPoint.z = avgPoint.z / numpoints
    if avgPoint.x and avgPoint.z then
        avgPoint.y = land.getHeight({x = avgPoint.x, y = avgPoint.z})
        return avgPoint
    else
        return nil
    end
end

local function getGroupSpeed(group)
    local g = groupTableCheck(group)
    if g then
        local units = g:getUnits()
        if units and #units > 0 then
            local s = 0
            local ms = 1000
            local u = 0
            for u, uData in pairs(units) do
                u = u + 1
                local us = vecmag(uData:getVelocity())
                if us and us >= 0 then
                    s = s + us
                    if us < ms then
                        ms = us
                    end
                end
            end
            return s, ms
        else
            return nil
        end
    else
        return nil
    end
end

local function toDegree(angle)
	return angle*180/math.pi
end

local function tostringLL(lat, lon, acc, DMS)

	local latHemi, lonHemi
	if lat > 0 then
		latHemi = 'N'
	else
		latHemi = 'S'
	end

	if lon > 0 then
		lonHemi = 'E'
	else
		lonHemi = 'W'
	end

	lat = math.abs(lat)
	lon = math.abs(lon)

	local latDeg = math.floor(lat)
	local latMin = (lat - latDeg)*60

	local lonDeg = math.floor(lon)
	local lonMin = (lon - lonDeg)*60

	if DMS then	-- degrees, minutes, and seconds.
		local oldLatMin = latMin
		latMin = math.floor(latMin)
		local latSec = round((oldLatMin - latMin)*60, acc)

		local oldLonMin = lonMin
		lonMin = math.floor(lonMin)
		local lonSec = round((oldLonMin - lonMin)*60, acc)

		if latSec == 60 then
			latSec = 0
			latMin = latMin + 1
		end

		if lonSec == 60 then
			lonSec = 0
			lonMin = lonMin + 1
		end

		local secFrmtStr -- create the formatting string for the seconds place
		if acc <= 0 then	-- no decimal place.
			secFrmtStr = '%02d'
		else
			local width = 3 + acc	-- 01.310 - that's a width of 6, for example.
			secFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
		end

		return string.format('%02d', latDeg) .. ' ' .. string.format('%02d', latMin) .. '\' ' .. string.format(secFrmtStr, latSec) .. '"' .. latHemi .. '	 '
		.. string.format('%02d', lonDeg) .. ' ' .. string.format('%02d', lonMin) .. '\' ' .. string.format(secFrmtStr, lonSec) .. '"' .. lonHemi

	else	-- degrees, decimal minutes.
		latMin = round(latMin, acc)
		lonMin = round(lonMin, acc)

		if latMin == 60 then
			latMin = 0
			latDeg = latDeg + 1
		end

		if lonMin == 60 then
			lonMin = 0
			lonDeg = lonDeg + 1
		end

		local minFrmtStr -- create the formatting string for the minutes place
		if acc <= 0 then	-- no decimal place.
			minFrmtStr = '%02d'
		else
			local width = 3 + acc	-- 01.310 - that's a width of 6, for example.
			minFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
		end

		return string.format('%02d', latDeg) .. ' ' .. string.format(minFrmtStr, latMin) .. '\'' .. latHemi .. '	 '
		.. string.format('%02d', lonDeg) .. ' ' .. string.format(minFrmtStr, lonMin) .. '\'' .. lonHemi

	end
end

local function tostringMGRS(MGRS, acc)
	if acc == 0 then
		return MGRS.UTMZone .. ' ' .. MGRS.MGRSDigraph
	else
		return MGRS.UTMZone .. ' ' .. MGRS.MGRSDigraph .. ' ' .. string.format('%0' .. acc .. 'd', round(MGRS.Easting/(10^(5-acc)), 0))
		.. ' ' .. string.format('%0' .. acc .. 'd', round(MGRS.Northing/(10^(5-acc)), 0))
	end
end

local function getCurveval(x, maxVal, maxDist, curveType)

    if x < 0 then x = 0 end
    if x > maxDist then x = maxDist end

    if not curveType then
        curveType = "lin" -- default to linear if no curve type is specified
    end

    if curveType == "lin" then
        return maxVal * (1 - x / maxDist)
    elseif curveType == "sqr" then
        local ratio = math.sqrt(x / maxDist)
        return maxVal * (1 - ratio)
    end
end

local function getCirclePoints(center, num)
    local points = {}
    
    -- correct num
    if not num then
        num = 8
    elseif num < 4 then
        num = 4
    elseif num > 12 then
        num = 12
    end

    -- define range
    local range = (AIEN.config.densityRange / 2) / math.sin(math.pi / num * 2)

    for i = 1, num do 
        local angle = math.rad(i * 45) -- 360° diviso 8 = 45°
        local px = center.x + range * math.cos(angle)
        local pz = center.z + range * math.sin(angle)
        local py = center.y -- stesso livello in altezza
        
        points[#points + 1] = {p = {x = px, y = py, z = pz}}
        
    end
    return points
end


-- revTODO the code below is not used; an error? -> Chromium: check this out -> nope will be used 
local function zoneToVec3(zone)
    local new = {}
	if type(zone) == 'table' then
		if zone.point then
			new.x = zone.point.x
			new.y = zone.point.y
			new.z = zone.point.z
		elseif zone.x and zone.y and zone.z then
			return zone
		end
		return new
	elseif type(zone) == 'string' then
		zone = trigger.misc.getZone(zone)
		if zone then
			new.x = zone.point.x
			new.y = zone.point.y
			new.z = zone.point.z
			return new
		end
	end
end

local function pointInPolygon(point, poly) -- mist local copy ot f that function

	point = makeVec3(point)
	local px = point.x
	local pz = point.z
	local cn = 0
	local newpoly = deepCopy(poly)

    local polysize = #newpoly
    newpoly[#newpoly + 1] = newpoly[1]

    newpoly[1] = makeVec3(newpoly[1])

    for k = 1, polysize do
        newpoly[k+1] = makeVec3(newpoly[k+1])
        if ((newpoly[k].z <= pz) and (newpoly[k+1].z > pz)) or ((newpoly[k].z > pz) and (newpoly[k+1].z <= pz)) then
            local vt = (pz - newpoly[k].z) / (newpoly[k+1].z - newpoly[k].z)
            if (px < newpoly[k].x + vt*(newpoly[k+1].x - newpoly[k].x)) then
                cn = cn + 1
            end
        end
    end

    return cn%2 == 1
end

local function getPayload(unitName)
    -- refactor to search by groupId and allow groupId and groupName as inputs
	local unitTbl = Unit.getByName(unitName)
	local unitId = unitTbl:getID()
	local gpTbl = unitTbl:getGroup()
	local gpId = gpTbl:getID()

	if gpId and unitId then
		for coa_name, coa_data in pairs(env.mission.coalition) do
			if (coa_name == 'red' or coa_name == 'blue') and type(coa_data) == 'table' then
				if coa_data.country then --there is a country table
					for cntry_id, cntry_data in pairs(coa_data.country) do
						for obj_type_name, obj_type_data in pairs(cntry_data) do
							if obj_type_name == "helicopter" or obj_type_name == "ship" or obj_type_name == "plane" or obj_type_name == "vehicle" then	-- only these types have points
								if ((type(obj_type_data) == 'table') and obj_type_data.group and (type(obj_type_data.group) == 'table') and (#obj_type_data.group > 0)) then	--there's a group!
									for group_num, group_data in pairs(obj_type_data.group) do
										if group_data and group_data.groupId == gpId then
											for unitIndex, unitData in pairs(group_data.units) do --group index
												if unitData.unitId == unitId then
													return unitData.payload
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	else
		if AIEN.config.AIEN_debugProcessDetail then
			env.info(ModuleName .. " getPayload error, no gId or unitId")
		end	
		return false
	end
	return
end

local function ground_buildWP(point, overRideForm, overRideSpeed)

	local wp = {}
	wp.x = point.x

	if point.z then
		wp.y = point.z
	else
		wp.y = point.y
	end

    local form

	if point.speed and not overRideSpeed then
		wp.speed = point.speed
	elseif type(overRideSpeed) == 'number' then
		wp.speed = overRideSpeed
	else
		wp.speed = kmphToMps(20)
	end

	if point.form and not overRideForm then
		form = point.form
	else
		form = overRideForm
	end

	if not form then
		wp.action = 'Cone'
	else
		form = string.lower(form)
		if form == 'off_road' or form == 'off road' then
			wp.action = 'Off Road'
		elseif form == 'on_road' or form == 'on road' then
			wp.action = 'On Road'
		elseif form == 'rank' or form == 'line_abrest' or form == 'line abrest' or form == 'lineabrest'then
			wp.action = 'Rank'
		elseif form == 'cone' then
			wp.action = 'Cone'
		elseif form == 'diamond' then
			wp.action = 'Diamond'
		elseif form == 'vee' then
			wp.action = 'Vee'
		elseif form == 'echelon_left' or form == 'echelon left' or form == 'echelonl' then
			wp.action = 'EchelonL'
		elseif form == 'echelon_right' or form == 'echelon right' or form == 'echelonr' then
			wp.action = 'EchelonR'
		else
			wp.action = 'Cone' -- if nothing matched
		end
	end

	wp.type = 'Turning Point'

	return wp

end

local function dynAdd(ng)

    local newGroup = deepCopy(ng)

    local cntry = newGroup.country
	if newGroup.countryId then
		cntry = newGroup.countryId
	end

	local groupType = newGroup.category
	local newCountry = ''
	-- validate data

	for countryId, countryName in pairs(country.name) do
		if type(cntry) == 'string' then
			cntry = cntry:gsub("%s+", "_")
			if tostring(countryName) == string.upper(cntry) then
				newCountry = countryName
			end
		elseif type(cntry) == 'number' then
			if countryId == cntry then
				newCountry = countryName
			end
		end
	end

	if newCountry == '' then
		if AIEN.config.AIEN_debugProcessDetail then
			env.info(ModuleName .. " dynAdd Country not found")
		end		
		return false
	end

	local newCat = ''
	for catName, catId in pairs(Unit.Category) do
		if type(groupType) == 'string' then
			if tostring(catName) == string.upper(groupType) then
				newCat = catName
			end
		elseif type(groupType) == 'number' then
			if catId == groupType then
				newCat = catName
			end
		end

		if catName == 'GROUND_UNIT' and (string.upper(groupType) == 'VEHICLE' or string.upper(groupType) == 'GROUND') then
			newCat = 'GROUND_UNIT'
		elseif catName == 'AIRPLANE' and string.upper(groupType) == 'PLANE' then
			newCat = 'AIRPLANE'
		end
	end

	local typeName
	if newCat == 'GROUND_UNIT' then
		typeName = ' gnd '
	elseif newCat == 'AIRPLANE' then
		typeName = ' air '
	elseif newCat == 'HELICOPTER' then
		typeName = ' hel '
	elseif newCat == 'SHIP' then
		typeName = ' shp '
	elseif newCat == 'BUILDING' then
		typeName = ' bld '
	end    
	if newGroup.groupName or newGroup.name then
		if newGroup.groupName then
			newGroup.name = newGroup.groupName
		elseif newGroup.name then
			newGroup.name = newGroup.name
		end
	end

	if newGroup.clone or not newGroup.name then
		newGroup.name = tostring(newCountry .. tostring(typeName) .. string.format("%04d", tostring(stupidIndex)))
        stupidIndex = stupidIndex + 1
	end

	if not newGroup.hidden then
		newGroup.hidden = false
	end

	if not newGroup.visible then
		newGroup.visible = false
	end

	if (newGroup.start_time and type(newGroup.start_time) ~= 'number') or not newGroup.start_time then
		if newGroup.startTime then
			newGroup.start_time = round(newGroup.startTime)
		else
			newGroup.start_time = 0
		end
	end

    for unitIndex, unitData in pairs(newGroup.units) do
        local originalName = newGroup.units[unitIndex].unitName or newGroup.units[unitIndex].name
        if newGroup.units[unitIndex].unitName or newGroup.units[unitIndex].name then
            if newGroup.units[unitIndex].unitName then
                newGroup.units[unitIndex].name = newGroup.units[unitIndex].unitName
            elseif newGroup.units[unitIndex].name then
                newGroup.units[unitIndex].name = newGroup.units[unitIndex].name
            end
        end
        if newGroup.clone or not unitData.name then
            newGroup.units[unitIndex].name = tostring(newGroup.name .. ' unit' .. unitIndex)
        end

        if not unitData.skill then
            newGroup.units[unitIndex].skill = 'Random' -- provide something here
        end

        if newCat == 'AIRPLANE' or newCat == 'HELICOPTER' then
            if newGroup.units[unitIndex].alt_type and newGroup.units[unitIndex].alt_type ~= 'BARO' or not newGroup.units[unitIndex].alt_type then
                newGroup.units[unitIndex].alt_type = 'RADIO'
            end
            if not unitData.speed then
                if newCat == 'AIRPLANE' then
                    newGroup.units[unitIndex].speed = 150
                elseif newCat == 'HELICOPTER' then
                    newGroup.units[unitIndex].speed = 60
                end
            end
            if not unitData.payload then
                newGroup.units[unitIndex].payload = getPayload(originalName)
            end
            if not unitData.alt then
                if newCat == 'AIRPLANE' then
                    newGroup.units[unitIndex].alt = 2000
                    newGroup.units[unitIndex].alt_type = 'RADIO'
                    newGroup.units[unitIndex].speed = 150
                elseif newCat == 'HELICOPTER' then
                    newGroup.units[unitIndex].alt = 500
                    newGroup.units[unitIndex].alt_type = 'RADIO'
                    newGroup.units[unitIndex].speed = 60
                end
            end
            
        elseif newCat == 'GROUND_UNIT' then
            if nil == unitData.playerCanDrive then
                unitData.playerCanDrive = true
            end
        
        end
    end
    if newGroup.route then
        if newGroup.route and not newGroup.route.points then
            if newGroup.route[1] then
                local copyRoute = deepCopy(newGroup.route)
                newGroup.route = {}
                newGroup.route.points = copyRoute
            end
        end
    else -- if aircraft and no route assigned. make a quick and stupid route so AI doesnt RTB immediately
        --if newCat == 'AIRPLANE' or newCat == 'HELICOPTER' then
            newGroup.route = {}
            newGroup.route.points = {}
            newGroup.route.points[1] = {}
        --end
    end
	newGroup.country = newCountry

    -- update and verify any self tasks
    if newGroup.route and newGroup.route.points then 
        --log:warn(newGroup.route.points)
        for i, pData in pairs(newGroup.route.points) do
            if pData.task and pData.task.params and pData.task.params.tasks and #pData.task.params.tasks > 0 then
                for tIndex, tData in pairs(pData.task.params.tasks) do
                    if tData.params and tData.params.action then  
                        if tData.params.action.id == "EPLRS" then
                            tData.params.action.params.groupId = newGroup.groupId
                        elseif tData.params.action.id == "ActivateBeacon" or tData.params.action.id == "ActivateICLS" then 
                            tData.params.action.params.unitId = newGroup.units[1].unitId
                        end 
                    end
                end
            end
        
        end
    end

	-- sanitize table
	newGroup.groupName = nil
	newGroup.clone = nil
	newGroup.category = nil
	newGroup.country = nil

	newGroup.tasks = {}

	for unitIndex, unitData in pairs(newGroup.units) do
		newGroup.units[unitIndex].unitName = nil
	end

	coalition.addGroup(country.id[newCountry], Unit.Category[newCat], newGroup) -- QUIIIII, problema con ID?

	return newGroup

end

local function genSmokePoints(pos, dist, n)
    local points = {}
    local angle_step = 360 / n 

    for i = 0, n - 1 do
       
        local rad = (i * angle_step) * math.pi / 180
        local x = pos.x + dist * math.cos(rad)
        local z = pos.z + dist * math.sin(rad)
        table.insert(points, {x = x, y = pos.y-50, z = z})
    end

    return points
end
local function pcallGetCategory(obj) -- done to avoid DCS errors 
    local function effectiveCheck(obj)
        if obj then
           if obj.isExist and obj:isExist() then
                if obj:getPosition() then
                    if Object.getCategory(obj) then
                        return Object.getCategory(obj)
                    else
                        if AIEN.config.AIEN_debugProcessDetail == true then
                            env.info(("AIEN pcallGetCategory, missing category"))
                        end    
                        return nil
                    end
                else
                    if AIEN.config.AIEN_debugProcessDetail == true then
                        env.info(("AIEN pcallGetCategory, missing pos"))
                    end    
                    return nil
                end
            else
                if AIEN.config.AIEN_debugProcessDetail == true then
                    env.info(("AIEN pcallGetCategory, isExist failed"))
                end    
                return nil 
            end
        else
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info(("AIEN pcallGetCategory, missing obj"))
            end    
            return nil 
        end
    end
    local noError, errorOrResult = pcall(effectiveCheck, obj)
    if noError then
        return errorOrResult
    else
        env.info(string.format("AIEN pcallGetCategory, error returned when calling the function: %s", errorOrResult or ""))
    end
end

-- desanitized functions (if available), for logging, table printing and debug purposes

-- You should never run DCS desanitized unless specifically knowing the risks. However, if you already do that, for debug purposes AIEN will take advantages of the available io and lfs
-- to print out tables of the databases created in it.

if AIEN_io and AIEN_lfs then
	env.info(("AIEN loading desanitized additional function"))

    function IntegratedbasicSerialize(s)
        if s == nil then
            return "\"\""
        else
            if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
                return tostring(s)
            elseif type(s) == 'string' then
                return string.format('%q', s)
            end
        end
    end
    
    function Integratedserialize(name, value, level)
        -----Based on ED's serialize_simple2
        local basicSerialize = function (o)
            if type(o) == "number" then
            return tostring(o)
            elseif type(o) == "boolean" then
            return tostring(o)
            else -- assume it is a string
            return IntegratedbasicSerialize(o)
            end
        end
    
        local serialize_to_t = function (name, value, level)
        ----Based on ED's serialize_simple2
    
            local var_str_tbl = {}
            if level == nil then level = "" end
            if level ~= "" then level = level.."  " end
    
            table.insert(var_str_tbl, level .. name .. " = ")
    
            if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
            table.insert(var_str_tbl, basicSerialize(value) ..  ",\n")
            elseif type(value) == "table" then
                table.insert(var_str_tbl, "\n"..level.."{\n")
    
                for k,v in pairs(value) do -- serialize its fields
                local key
                if type(k) == "number" then
                    key = string.format("[%s]", k)
                else
                    key = string.format("[%q]", k)
                end
    
                table.insert(var_str_tbl, Integratedserialize(key, v, level.."  "))
    
                end
                if level == "" then
                table.insert(var_str_tbl, level.."} -- end of "..name.."\n")
    
                else
                table.insert(var_str_tbl, level.."}, -- end of "..name.."\n")
    
                end
            else
            print("Cannot serialize a "..type(value))
            end
            return var_str_tbl
        end
    
        local t_str = serialize_to_t(name, value, level)
    
        return table.concat(t_str)
    end
    
    function IntegratedserializeWithCycles(name, value, saved)
        local basicSerialize = function (o)
            if type(o) == "number" then
                return tostring(o)
            elseif type(o) == "boolean" then
                return tostring(o)
            else -- assume it is a string
                return IntegratedbasicSerialize(o)
            end
        end
    
        local t_str = {}
        saved = saved or {}       -- initial value
        if ((type(value) == 'string') or (type(value) == 'number') or (type(value) == 'table') or (type(value) == 'boolean')) then
            table.insert(t_str, name .. " = ")
            if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
                table.insert(t_str, basicSerialize(value) ..  "\n")
            else
    
                if saved[value] then    -- value already saved?
                    table.insert(t_str, saved[value] .. "\n")
                else
                    saved[value] = name   -- save name for next time
                    table.insert(t_str, "{}\n")
                    for k,v in pairs(value) do      -- save its fields
                        local fieldname = string.format("%s[%s]", name, basicSerialize(k))
                        table.insert(t_str, IntegratedserializeWithCycles(fieldname, v, saved))
                    end
                end
            end
            return table.concat(t_str)
        else
            return ""
        end
    end

	function tableShow(tbl, loc, indent, tableshow_tbls)
		tableshow_tbls = tableshow_tbls or {} --create table of tables
		loc = loc or ""
		indent = indent or ""
		if type(tbl) == 'table' then --function only works for tables!
			tableshow_tbls[tbl] = loc
			
			local tbl_str = {}

			tbl_str[#tbl_str + 1] = indent .. '{\n'
			
			for ind,val in pairs(tbl) do -- serialize its fields
				if type(ind) == "number" then
					tbl_str[#tbl_str + 1] = indent 
					tbl_str[#tbl_str + 1] = loc .. '['
					tbl_str[#tbl_str + 1] = tostring(ind)
					tbl_str[#tbl_str + 1] = '] = '
				else
					tbl_str[#tbl_str + 1] = indent 
					tbl_str[#tbl_str + 1] = loc .. '['
					tbl_str[#tbl_str + 1] = IntegratedbasicSerialize(ind)
					tbl_str[#tbl_str + 1] = '] = '
				end
						
				if ((type(val) == 'number') or (type(val) == 'boolean')) then
					tbl_str[#tbl_str + 1] = tostring(val)
					tbl_str[#tbl_str + 1] = ',\n'		
				elseif type(val) == 'string' then
					tbl_str[#tbl_str + 1] = IntegratedbasicSerialize(val)
					tbl_str[#tbl_str + 1] = ',\n'
				elseif type(val) == 'nil' then -- won't ever happen, right?
					tbl_str[#tbl_str + 1] = 'nil,\n'
				elseif type(val) == 'table' then
					if tableshow_tbls[val] then
						tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
					else
						tableshow_tbls[val] = loc ..  '[' .. IntegratedbasicSerialize(ind) .. ']'
						tbl_str[#tbl_str + 1] = tostring(val) .. ' '
						tbl_str[#tbl_str + 1] = tableShow(val,  loc .. '[' .. IntegratedbasicSerialize(ind).. ']', indent .. '    ', tableshow_tbls)
						tbl_str[#tbl_str + 1] = ',\n'  
					end
				elseif type(val) == 'function' then
					if debug and debug.getinfo then
						local fcnname = tostring(val)
						local info = debug.getinfo(val, "S")
						if info.what == "C" then
							tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', C function') .. ',\n'
						else 
							if (string.sub(info.source, 1, 2) == [[./]]) then
								tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')' .. info.source) ..',\n'
							else
								tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')') ..',\n'
							end
						end
						
					else
						tbl_str[#tbl_str + 1] = 'a function,\n'	
					end
				else
					tbl_str[#tbl_str + 1] = 'unable to serialize value type ' .. IntegratedbasicSerialize(type(val)) .. ' at index ' .. tostring(ind)
				end
			end
			
			tbl_str[#tbl_str + 1] = indent .. '}'
			return table.concat(tbl_str)
		end
	end

	function dumpTableAIEN(fname, tabledata, varInt)
		
        if AIEN_lfs and AIEN_io then
            local fdir = AIEN_lfs.writedir() .. [[Logs\]] .. fname
            local f = AIEN_io.open(fdir, 'w')
            local str = nil
            if varInt then
                if varInt == "basic" then
                    str = IntegratedbasicSerialize(tabledata)
                elseif varInt == "cycles" then
                    str = IntegratedserializeWithCycles(fname, tabledata)
                elseif varInt == "int" then
                    str = Integratedserialize(fname, tabledata)
                else
                    str = IntegratedserializeWithCycles(fname, tabledata)
                end
            else
                str = IntegratedserializeWithCycles(fname, tabledata)
            end
            
            if f then
                f:write(str)
                f:close()
            end
		end
	end		

	env.info(("AIEN desanitized additional function loaded"))
end

local function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end 

local function getReactionTime(avg_skill)
    if avg_skill then -- 
        local multiplier = 10/(avg_skill/10)/4
        local min = math.floor(rndMinRT_xper*multiplier)
        local max = math.floor(rndMacRT_xper*multiplier)
        return aie_random(min, max)
    else
        return aie_random(3, 15)
    end
end

local function groupAllowedForAI(group)
    if group and group:isExist() and group:getUnits() and #group:getUnits() > 0 then
        local groupName = group:getName()
        for _, tag in ipairs(AIEN.config.AIEN_xcl_tag) do
            if string.find(groupName, tag, 1, true) then
                return false
            end
        end
    end
    return true
end

--###### GROUP AI QUERY FUNCTIONS ##################################################################

-- Below functions has been created to query ground groups for informations about them, most of them used in the key getSA functions that
-- try to built the "situational awareness" of a group. When done, each time the FSM cycle goes to that group,  it register bunch of info 
-- so that these would be fastly accessibile during reactions or decision making.


--## CAPABILITY CHECKS -- these exist to identify some key characteristics of the group.
-- revTODO the code below is not used; an error? -> Chromium: check this out -> nope will be used
local function group_hasAttribute(group, attribute) -- group tbl, attribute string (reference on DCS attributes) 
    if group then		
        local units = group:getUnits()
		if units and #units > 0 then
			for _, uData in pairs(units) do
				if uData:hasAttribute(attribute) then
					return true
				end
			end
			return false
		else
		    if AIEN.config.AIEN_debugProcessDetail == true then
				env.info(("AIEN group_hasAttribute, no units retrievable"))
			end	
			return false
		end
	else
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info(("AIEN group_hasAttribute, missing variable"))
        end	
		return false		
    end
end

-- revTODO the code below is not used; an error? -> Chromium: check this out -> nope will be used
local function group_hasSensors(group, sensor) -- group tbl, attribute string (reference on DCS attributes) 
    if group then		
        local units = group:getUnits()
		if units and #units > 0 then
		
			--[[
			Unit.SensorType = {
			  OPTIC     = 0,
			  RADAR     = 1,
			  IRST      = 2,
			  RWR       = 3
			}
			
			Unit.OpticType = {
			  TV     = 0, --TV-sensor
			  LLTV   = 1, --Low-level TV-sensor
			  IR     = 2  --Infra-Red optic sensor
			}		

			Unit.RadarType = {
			  AS    = 0, --air search radar
			  SS    = 1 --surface/land search radar
			}		
			--]]--			
		
			local optic, ir, radar, irst
			for _, uData in pairs(units) do
				if uData:hasSensors(0) then
					optic = true
				end
				if uData:hasSensors(0, 2) then
					ir = true
				end
				if uData:hasSensors(1) then
					radar = true
				end
				if uData:hasSensors(2) then
					irst =  true
				end
			end
			
			return optic, ir, radar, irst
		else
		    if AIEN.config.AIEN_debugProcessDetail == true then
				env.info((tostring(ModuleName) .. ", hasSensors no units retrievable"))
			end	
			return false
		end
	else
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", hasSensors missing variable"))
        end	
		return false		
    end
end


--## INFORMATIVE CHECKS -- these are basic informative "get" functions
local function groupStatus(group)
    if group and group:isExist() == true then
        local units = group:getUnits()
		local curLife 	= 0
		local initLife 	= 0
		if units and #units > 0 then
			for _, uData in pairs(units) do
				if uData:isExist() then
					curLife = curLife + uData:getLife()
					initLife = initLife + uData:getLife0()
				end
			end
		end
	
        if curLife == initLife then
            return false, 1, curLife
        else
			local ratio = math.floor(curLife/initLife*10)/10
            return true, ratio, curLife
        end
    end
end

local function groupLowAmmo(group)
    if group and group:isExist() == true then
        local tblUnits = group:getUnits()
        local groupSize = group:getSize()
        local groupOutAmmo = 0
        
        if tblUnits and groupSize then
            if table.getn(tblUnits) > 0 then
                for uId, uData in pairs(tblUnits) do
                    local uAmmo = uData:getAmmo()
                    if uAmmo then
                        for aId, aData in pairs(uAmmo) do
                            if aData.count == 0 then
                                groupOutAmmo = groupOutAmmo + 1
                            end
                        end
                    else    
                        groupOutAmmo = groupOutAmmo + 1
                    end
                end
            else
                env.info(("AIEN.groupLowAmmo, tblUnits is 0"))
                return false				
            end
        else
            env.info(("AIEN.groupLowAmmo, missing tblUnits or groupSize"))
            return false		
        end

        local fraction = groupOutAmmo/tonumber(groupSize)
        if fraction then
            if fraction > AIEN.config.outAmmoLowLevel then
                return true
            else
                return false
            end
        else
            env.info(("AIEN.groupLowAmmo, error calculating fraction"))
            return false		
        end
    end
end

local function groupHasLosses(group)
    if group and group:isExist() == true then
        local curSize = group:getSize()
        local iniSize = group:getInitialSize()
        if iniSize == curSize then
            return false, 1
        else
			local ratio = math.floor(curSize/iniSize*10)/10
            return true, ratio
        end
    end
end

local function groupHasTargets(group, report)
	if group and group:isExist() == true then
		local tblUnits = Group.getUnits(group)

		if table.getn(tblUnits) > 0 then
			local tbltargets = {}
			for _, uData in pairs(tblUnits) do
				local uController = uData:getController()
				local utblTargets = uController:getDetectedTargets()
				if utblTargets then
					if table.getn(utblTargets) > 0 then
						if report and report == true then
							return true
						else
							for _, utData in pairs(utblTargets) do
                                if utData.object and utData.object:isExist() == true then
								    tbltargets[utData.object.id_] = utData
                                end
							end
						end
					end
				end
			end
			
			if tbltargets and tbltargets ~= {} then
				return true, tbltargets
			end
			
			return false
			
		else
			env.info(("AIEN.groupHasTargets: tblUnits has 0 units"))
			return false			
		end
	else
		env.info(("AIEN.groupHasTargets: group is nil"))
		return false	
	end	
end

local function getGroupClass(group) 

	if group and group:isExist() == true then     
		local units = group:getUnits()
		local coa = group:getCoalition()
		local cls = "none"

		if units and coa then
            local clsCount = {}

			for uId, unit in ipairs(units) do -- first unit define group class
				if unit:hasAttribute("Ground Units") then
					if unit:hasAttribute("Tanks") then
						if clsCount["MBT"] then
                            clsCount["MBT"] = clsCount["MBT"] + 1
                        else
                            clsCount["MBT"] = 1
                        end
                        if uId == 1 then
                            cls = "MBT"
                        end
                    elseif unit:hasAttribute("ATGM") then
						if clsCount["ATGM"] then
                            clsCount["ATGM"] = clsCount["ATGM"] + 1
                        else
                            clsCount["ATGM"] = 1
                        end
                        if uId == 1 then
                            cls = "ATGM"
                        end                        						
					elseif unit:hasAttribute("Indirect fire") and not unit:hasAttribute("SS_missile") then
						if unit:hasAttribute("MLRS") then
                            if clsCount["MLRS"] then
                                clsCount["MLRS"] = clsCount["MLRS"] + 1
                            else
                                clsCount["MLRS"] = 1
                            end
                            if uId == 1 then
                                cls = "MLRS"
                            end   
                        elseif unit:hasAttribute("Artillery") then
                            if clsCount["ARTY"] then
                                clsCount["ARTY"] = clsCount["ARTY"] + 1
                            else
                                clsCount["ARTY"] = 1
                            end
                            if uId == 1 then
                                cls = "ARTY"
                            end   
                        end						
					elseif unit:hasAttribute("SS_missile") then
                        if clsCount["MISSILE"] then
                            clsCount["MISSILE"] = clsCount["MISSILE"] + 1
                        else
                            clsCount["MISSILE"] = 1
                        end
                        if uId == 1 then
                            cls = "MISSILE"
                        end    
					elseif unit:hasAttribute("MANPADS") then
                        if clsCount["MANPADS"] then
                            clsCount["MANPADS"] = clsCount["MANPADS"] + 1
                        else
                            clsCount["MANPADS"] = 1
                        end
                        if uId == 1 then
                            cls = "MANPADS"
                        end                          
					elseif unit:hasAttribute("Air Defence vehicles") then
                        if clsCount["SHORAD"] then
                            clsCount["SHORAD"] = clsCount["SHORAD"] + 1
                        else
                            clsCount["SHORAD"] = 1
                        end
                        if uId == 1 then
                            cls = "SHORAD"
                        end  						
                    elseif unit:hasAttribute("AAA") then    
                        if clsCount["AAA"] then
                            clsCount["AAA"] = clsCount["AAA"] + 1
                        else
                            clsCount["AAA"] = 1
                        end
                        if uId == 1 then
                            cls = "AAA"
                        end                         
                    elseif unit:hasAttribute("SAM SR") or unit:hasAttribute("SAM TR") then    
                        if clsCount["SAM"] then
                            clsCount["SAM"] = clsCount["SAM"] + 1
                        else
                            clsCount["SAM"] = 1
                        end
                        if uId == 1 then
                            cls = "SAM"
                        end
                    elseif unit:hasAttribute("SAM LL") then    
                        if clsCount["SAML"] then
                            clsCount["SAML"] = clsCount["SAML"] + 1
                        else
                            clsCount["SAML"] = 1
                        end
                        if uId == 1 then
                            cls = "SAML"
                        end
                    elseif unit:hasAttribute("SAM CC") then    
                        if clsCount["SAMC"] then
                            clsCount["SAMC"] = clsCount["SAMC"] + 1
                        else
                            clsCount["SAMC"] = 1
                        end
                        if uId == 1 then
                            cls = "SAMC"
                        end
                    elseif unit:hasAttribute("Armored vehicles") then
						if unit:hasAttribute("IFV") then
                            if clsCount["IFV"] then
                                clsCount["IFV"] = clsCount["IFV"] + 1
                            else
                                clsCount["IFV"] = 1
                            end
                            if uId == 1 then
                                cls = "IFV"
                            end   
                        elseif unit:hasAttribute("APC") then
                            if clsCount["APC"] then
                                clsCount["APC"] = clsCount["APC"] + 1
                            else
                                clsCount["APC"] = 1
                            end
                            if uId == 1 then
                                cls = "APC"
                            end   
                        end
					elseif unit:hasAttribute("Armed vehicles") then
                        if clsCount["RECCE"] then
                            clsCount["RECCE"] = clsCount["RECCE"] + 1
                        else
                            clsCount["RECCE"] = 1
                        end
                        if uId == 1 then
                            cls = "RECCE"
                        end   						
					elseif unit:hasAttribute("Unarmed vehicles") and unit:hasAttribute("Trucks") then
                        if clsCount["LOGI"] then
                            clsCount["LOGI"] = clsCount["LOGI"] + 1
                        else
                            clsCount["LOGI"] = 1
                        end
                        if uId == 1 then
                            cls = "LOGI"
                        end                            
                    elseif unit:hasAttribute("Infantry") then
                        if clsCount["INF"] then
                            clsCount["INF"] = clsCount["INF"] + 1
                        else
                            clsCount["INF"] = 1
                        end
                        if uId == 1 then
                            cls = "INF"
                        end 
                    else
                        if clsCount["UNKN"] then
                            clsCount["UNKN"] = clsCount["UNKN"] + 1
                        else
                            clsCount["UNKN"] = 1
                        end
                        if uId == 1 then
                            cls = "UNKN"
                        end                     
					end
                elseif unit:hasAttribute("Air") then
                    cls = "ARBN"
                elseif unit:hasAttribute("Ships") then
                    cls = "SHIP"
				end
			end

            local mClass = nil
            local mVal = 2
            for class, num in pairs(clsCount) do
                if num > mVal then
                    mClass = class
                    mVal = num
                end
            end
            if mClass then
                cls = mClass
            end
            
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", getGroupClass, group " .. tostring(group:getName()) .. " class: " .. tostring(cls)))
            end
			return cls

		else
			env.info((tostring(ModuleName) .. ", getGroupClass, missing units"))
			return false
		end
	else
		env.info((tostring(ModuleName) .. ", getGroupClass, missing group"))
		return false
	end
end

local function getUnitClass(unit) 

	if unit and unit:isExist() == true then     
		local coa = unit:getCoalition()
		local cls = "none"

		if coa then
            if unit:hasAttribute("Air") then
                cls = "ARBN"
            elseif unit:hasAttribute("Ships") then
                cls = "SHIP"
            elseif unit:hasAttribute("Ground Units") then
                if unit:hasAttribute("Tanks") then
                    cls = "MBT"
                elseif unit:hasAttribute("Indirect fire") and not unit:hasAttribute("SS_missile") then
                    if unit:hasAttribute("MLRS") then
                        cls = "MLRS"
                    elseif unit:hasAttribute("Artillery") then
                        cls = "ARTY"
                    end						
                elseif unit:hasAttribute("SS_missile") then
                    cls = "MISSILE"
                elseif unit:hasAttribute("MANPADS") then
                    cls = "MANPADS"                         
                elseif unit:hasAttribute("Air Defence vehicles") then
                    cls = "SHORAD"
                elseif unit:hasAttribute("AAA") then    
                    cls = "AAA"                        
                elseif unit:hasAttribute("SAM SR") then    
                    cls = "SAM" 
                elseif unit:hasAttribute("SAM TR") then    
                    cls = "SAM"
                elseif unit:hasAttribute("SAM LL") then    
                    cls = "SAML"
                elseif unit:hasAttribute("SAM CC") then    
                    cls = "SAMC"
                elseif unit:hasAttribute("ATGM") then
                    cls = "ATGM"                       
                elseif unit:hasAttribute("Armored vehicles") then
                    if unit:hasAttribute("IFV") then
                        cls = "IFV" 
                    elseif unit:hasAttribute("APC") then
                        cls = "APC" 
                    end                    
                elseif unit:hasAttribute("Armed vehicles") then
                    cls = "RECCE"                    
                elseif unit:hasAttribute("Unarmed vehicles") and unit:hasAttribute("Trucks") then
                    cls = "LOGI"                    
                elseif unit:hasAttribute("Infantry") then
                    cls = "INF"
                else
                    cls = "UNKN"
                end
            end
            
			return cls

		else
			env.info((tostring(ModuleName) .. ", getUnitClass, missing coa"))
			return false
		end
	else
		env.info((tostring(ModuleName) .. ", getUnitClass, missing unit"))
		return false
	end
end

local function getGroupSkillNum(g) -- important: this try to create an "average skill scoring number" that will be used a lot elsewhere, i.e. for defining reaction time or even the available reactions. AIEN does not handle well the "Random" skill value (cause DCS skill is not available in real time): for best purpose, you should define the skill value of your ground units in the ME.
    local id = g:getID()
    --env.info((tostring(ModuleName) .. ", getGroupSkillNum: skLevel " .. tostring(g:getName()) ))
	for _,coalition in pairs(env.mission["coalition"]) do
		for _,country in pairs(coalition["country"]) do
			for attrID,attr in pairs(country) do
				if (type(attr)=="table") then
					if attrID == "vehicle" then
						for _,group in pairs(attr["group"]) do
							if (group) then	
                                if group.groupId == id then
                                    --env.info((tostring(ModuleName) .. ", getGroupSkillNum: skLevel " .. tostring(g:getName()).. " group found" ))
                                    local skLevel = 0
                                    local unitsCount = 0
                                
                                    for _, unit in pairs(group["units"]) do
                                        local skTbl = skills[unit.skill]
                                        if skTbl then
                                            local val = skTbl.skillVal
                                            if unit.skill == "Random" then
                                                val = aie_random(4,12)
                                            end
                                            skLevel = skLevel + val
                                            unitsCount = unitsCount + 1
                                            --env.info((tostring(ModuleName) .. ", getGroupSkillNum: skLevel " .. tostring(skLevel) .. ", unit num " .. tostring(unitsCount) ))
                                        end
                                    end

                                    if skLevel > 0 then
                                        local k =  math.floor((skLevel/unitsCount)*10)/10
                                        if AIEN.config.AIEN_debugProcessDetail == true then
                                            env.info((tostring(ModuleName) .. ", getGroupSkillNum: skLevel " .. tostring(k)))
                                        end
                                        return k
                                    else
                                        return 3
                                    end
                                end
							end
						end	
					end
				end
			end
		end
	end	
    --env.info((tostring(ModuleName) .. ", getGroupSkillNum: sklevel not retournable, going random"))
    return aie_random(2,5)
end

local function getRanges(group)
	if group and group:isExist() == true then
		local units = group:getUnits()
        local maxDec = 0
        local maxThr = 0
        for _, uData in pairs(units) do
            local t = uData:getTypeName()
            if t then
                local tData = tblThreatsRange[t]
                if tData then
                    if tData.detection and tData.detection > maxDec then
                        maxDec = tData.detection
                    end
                    if tData.threat and tData.threat > maxThr then
                        maxThr = tData.threat
                    end
                end
            end
        end

        if maxDec == 0 then
            maxDec = nil
        end
        if maxThr == 0 then
            maxThr = nil
        end

        return maxDec, maxThr
		
	else
		if AIEN.config.AIEN_debugProcessDetail then
			env.info((tostring(ModuleName) .. ", getRanges failed, group variable is nil"))
		end
		
	end
end

local function getLeadPos(group)

	if group and group:isExist() == true then
		local units = group:getUnits()

		local leader = units[1]
		if leader then
			if not Unit.isExist(leader) then	-- SHOULD be good, but if there is a bug, this code future-proofs it then.
				local lowestInd = math.huge
				for ind, unit in pairs(units) do
					if Unit.isExist(unit) and ind < lowestInd then
						lowestInd = ind
						return unit:getPosition().p
					end
				end
			end
		end
		if leader and Unit.isExist(leader) then	-- maybe a little too paranoid now...
			return leader:getPosition().p
		end
	else
		if AIEN.config.AIEN_debugProcessDetail then
			env.info((tostring(ModuleName) .. ", getLeadPos failed, group variable is nil"))
		end
		
	end
end

local function getTroops(group)
	if group and group:isExist() then
		if group:getUnits() and #group:getUnits() > 0 then
			local troopsTbl = {}
			for _, uData in pairs(group:getUnits()) do              
				local mount = mountedDb[tostring(uData:getID())]
				if mount and uData then
					troopsTbl[uData:getID()] = {u = uData, t = mount}
				end
			end
			
			if troopsTbl and next(troopsTbl) ~= nil then
                if AIEN.config.AIEN_debugProcessDetail == true then
                    env.info(("AIEN.getTroops, returning troopstbl for: " .. tostring(group:getName()) ))
                end	
				return troopsTbl
			end
		end
	end
	return nil
end

local function getDangerClose(vec3, coa, range)
    if vec3 and type(vec3) == "table" and coa then
        if vec3.x and vec3.y and vec3.z then
            if not range or type(range) ~= "number" then
                if AIEN.config.AIEN_debugProcessDetail == true then
                    env.info((tostring(ModuleName) .. ", getDangerClose: range missing reverted to 500 m "))
                end
                range = 500
            end

            -- check targets   
            local firePoint = vec3
            local friendly = nil
            local _volume = {
                id = world.VolumeType.SPHERE,
                params = {
                    point = firePoint,
                    radius = range,
                },
            }

            local _search = function(_obj)
                pcall(function()
                    if _obj ~= nil and _obj:isExist() and Object.getCategory(_obj) == 1 and _obj:getCoalition() == coa then
                        if _obj:hasAttribute("Air") then return end
                        friendly = true
                        if AIEN.config.AIEN_debugProcessDetail == true then
                            env.info((tostring(ModuleName) .. ", getDangerClose: found friendly unit " .. tostring(_obj:getName())))
                        end
                        return
                    end
                end)
            end
            world.searchObjects(Object.Category.UNIT, _volume, _search)

            if friendly == true then
                return true
            end
            return false

        end
    end
end

local function groupInZone(group)
    local point = getLeadPos(group)
    local zone = nil
    
    if point then
    
        if env.mission and env.mission.triggers and env.mission.triggers.zones and #env.mission.triggers.zones > 0 then
            for _, zData in pairs(env.mission.triggers.zones) do
                if zData.name == AIEN.config.AIEN_zoneFilter then
                    zone = zData
                    zone.center = {x = zone.x, y = land.getHeight({x = zone.x, y = zone.y}), z = zone.y}
                end
            end
        end

        if not zone then
            return true
        else
            if zone.verticies then
                if pointInPolygon(point, zone.verticies) == true then
                    return true
                else
                    return false
                end
            elseif zone.radius then
                if getDist(point, zone.center) < zone.radius then
                    return true
                else
                    return false
                end
            end

        end
    end
end

local function getDensityValueAtPoint(vec3, coa, range) -- coa is optional, range is optional
    -- return "density" value for units strenght at a specific point or each coalition or the specified one.
    -- No intel required, mimic the fact that you should know that the enemies is there even if you don't have
    -- detailed informations about it. Also used for initiative to command decision making.

    -- check coa and accept both number and string
    local c = nil
    if coa and type(coa) ~= "number" then
        c = coa
    elseif coa and type(coa) == "string" then
        if string.lower(coa) == "blue" then
            c = 2
        elseif string.lower(coa) == "red" then
            c = 1
        elseif string.lower(coa) == "neutral" then
            c = 0
        end
    end

    -- check range
    local r = range or AIEN.config.densityRange

    -- calculate density
    local d_neu, d_red, d_blue, d_tot = 0, 0, 0, 0
    local p = vec3Check(vec3)
    if p then
        local _volume = {
            id = world.VolumeType.SPHERE,
            params = {
                point = p,
                radius = r,
            },
        }

        local _search = function(_obj)
            pcall(function()
                if _obj ~= nil and Object.getCategory(_obj) == 1 and _obj:isExist() then

                    if c then
                        if _obj:getCoalition() ~= c then
                            return -- skip this object
                        end
                    end

                    if _obj.getLife and _obj.getPoint then
                        local l = _obj:getLife()
                        local pz = _obj:getPoint()
                        if l and l > 0 then
                            local d = getDist(p, pz)
                            local v = getCurveval(d, l, r, "sqr")

                            d_tot = d_tot + v
                            if not c then
                                if _obj:getCoalition() == 1 then
                                    d_red = d_red + v
                                elseif _obj:getCoalition() == 2 then
                                    d_blue = d_blue + v
                                elseif _obj:getCoalition() == 0 then
                                    d_neu = d_neu + v
                                end
                            end
                        else
                            return -- skip this object, no life value
                        end
                    else
                        return -- skip this object, no life value
                    end
                end
            end)
        end

        world.searchObjects(Object.Category.UNIT, _volume, _search)

        if c then
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", getDensityValueAtPoint: found " .. tostring(d_tot) .. " d_tot"))
            end
            return d_tot
        else
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", getDensityValueAtPoint: found " .. tostring(d_red) .. " red, " .. tostring(d_blue) .. " blue, " .. tostring(d_neu) .. " neutral, " .. tostring(d_tot) .. " d_tot"))
            end

            local result = {}
            result[0] = d_neu
            result[1] = d_red
            result[2] = d_blue     
            result["tot"] = d_tot   
            return result

        end
    else
        env.info((tostring(ModuleName) .. ", getDensityValueAtPoint: vec3 is nil"))
    end    

end


--## AWARENESS CONSTRUCTION FOR FSM USE -- the core of the reaction decision making behaviour: this functions use the upper ones to try to built a virtual situational awareness, and also collect for faster access some key informations.

local function getSA(group) -- built a situational awareness check
	if group and group:isExist() == true then
        local dbEntry = groundgroupsDb[group:getID()] or droneunitDb[group:getID()]
        if dbEntry then
            local cfg = AIEN.config
            local _now = timer.getTime()
            local sa = {}
            sa.enInContact, sa.targets 	= groupHasTargets(group)
            sa.loss 		            = groupHasLosses(group)
            sa.dmg, sa.life, sa.str     = groupStatus(group)
            sa.low_ammo 	            = groupLowAmmo(group)
            sa.pos			            = getLeadPos(group)
            sa.coa                      = group:getCoalition()
            sa.det                      = dbEntry["detection"]
            sa.rng                      = dbEntry["threat"]
            sa.cls                      = dbEntry["class"]
            sa.nearAlly                 = nil
            sa.nearEnemy                = nil
            if sa.pos and sa.coa then
                
                -- fix potential det and range issue
                if not sa.rng then
                    if sa.cls == "ARTY" then
                        sa.rng = 15000
                    elseif sa.cls == "MLRS" then
                        sa.rng = 30000
                    elseif sa.cls == "ATGM" then
                        sa.rng = 4000
                    elseif sa.cls == "UAV" then
                        sa.rng = 8000
                    else
                        sa.rng = 2000
                    end
                end
                if not sa.det then
                    if sa.cls == "ARTY" then
                        sa.det = 2000
                    elseif sa.cls == "MLRS" then
                        sa.det = 2000
                    elseif sa.cls == "ATGM" then
                        sa.det = 4000
                    elseif sa.cls == "UAV" then
                        sa.det = 20000
                    else
                        sa.det = 2000
                    end
                end
                local an,as,near_a = 0,0,nil
                local r = cfg.proxyUnitsDistance
                local _volume = {id = world.VolumeType.SPHERE,params = {point = sa.pos,radius = r}}
                local _search = function(_obj)
                    pcall(function()
                        if _obj and Object.getCategory(_obj) == 1 and _obj:isExist() then
                            local o_coa = _obj:getCoalition()
                            if o_coa ~= 0 then
                                local o_pos = _obj:getPosition().p
                                local o_str = _obj:getLife()
                                if o_coa == sa.coa then
                                    local d = getDist(sa.pos, o_pos)
                                    an = an + 1
                                    as = as + o_str
                                    if d < r then
                                        r = d
                                        near_a = o_pos
                                    end
                                end
                            end
                        end
                    end)
                end
                world.searchObjects(Object.Category.UNIT, _volume, _search)
                if an and near_a and as then sa.nearAlly = {n = an, p = near_a, s = as} end
                if sa.targets and sa.targets ~= {} then
                    for _, tgtData in pairs(sa.targets) do
                        local tgt   = tgtData.object
                        local check = pcallGetCategory(tgt)
                        if check == 1 and tgt and tgt:isExist() then
                            local dd = getDist(sa.pos, tgt:getPosition().p)
                            if not sa.det or dd <= sa.det then
                                local t_id = tgt:getID()
                                intelDb[t_id] = {obj = tgt,pos = tgt:getPosition().p,coa = tgt:getCoalition(),life = tgt:getLife(),record = _now,speed = vecmag(tgt:getVelocity()),type = (tgt.type and tgt:getTypeName() or "unknown"),ucat = (check==1 and tgt:getCategory() or nil),scat = (check==3 and tgt:getCategory() or nil),attr = (tgt:getDesc() and tgt:getDesc().attributes or nil),cls = getUnitClass(tgt),identifier = sa.cls}
                            end
                        end
                    end
                end
                local near_e,es,en,dist = nil,0,0,nil
                for iId,iData in pairs(intelDb) do
                    if iData.obj:isExist() then
                        if iData.coa ~= sa.coa and iData.coa ~= 0 and (_now - iData.record) < cfg.intelDbTimeout then
                            local d = getDist(sa.pos,iData.pos)
                            if d < cfg.proxyUnitsDistance then
                                en = en + 1
                                es = es + iData.life
                                if d < cfg.proxyUnitsDistance then
                                    near_e = iData.pos
                                    dist = d
                                end
                            end
                        end
                    else
                        intelDb[iId] = nil
                    end
                end
                if en and near_e and es then sa.nearEnemy = {n = en, p = near_e, s = es, d = dist} end
                dbEntry.sa = sa
                return sa
            else
                return false
            end
        else
            if cfg.AIEN_debugProcessDetail then env.info((tostring(ModuleName) .. ", group not in db")) end
            return false
        end
	else
		if AIEN.config.AIEN_debugProcessDetail then env.info((tostring(ModuleName) .. ", group doesn't exist")) end
		return false
	end
end


--###### GROUP AI COMMAND FUNCTIONS ################################################################

-- Below functions has been created to give command to ground groups, from the most basic to the more advanced. 
-- These functions are the core of the things that will be done by your units.


--## BASIC STATE ACTION -- these are basic command for the group.
-- revTODO the code below is not used; an error? -> Chromium: check this out -> nope will be used
local function groupGoQuiet(group)
    if group and group:isExist() == true then	
        local gController = group:getController()
        gController:setOption(AI.Option.Ground.id.ALARM_STATE, 1) -- green -- Ground or GROUND?
        gController:setOption(AI.Option.Ground.id.ROE, 3) -- return fire -- Ground or GROUND?
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info(("AIEN.groupGoQuiet status quiet"))
        end			
    end
end

-- revTODO the code below is not used; an error? -> Chromium: check this out -> nope will be used
local function groupGoActive(group)
    if group and group:isExist() == true then
        local gController = group:getController()
        gController:setOption(AI.Option.Ground.id.ALARM_STATE, 2) -- red -- Ground or GROUND?
        gController:setOption(AI.Option.Ground.id.ROE, 3) -- return fire -- Ground or GROUND?
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info(("AIEN.groupGoActive status active and return fire"))
        end				
    end
end

local function groupGoShoot(group)
    if group and group:isExist() == true then		
        local gController = group:getController()
        gController:setOption(AI.Option.Ground.id.ALARM_STATE, 2) -- red -- Ground or GROUND?
        gController:setOption(AI.Option.Ground.id.ROE, 2) -- open fire -- Ground or GROUND?
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info(("AIEN.groupGoShoot status fire at will"))
        end			
    end
end

local function groupAllowDisperse(group)
    if group and group:isExist() == true then
        local gController = group:getController()
        if gController then
            gController:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, AIEN.config.disperseActionTime) -- Ground or GROUND?
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info(("AIEN.groupAllowDisperse will allow dispersal"))
            end		
        else
            env.info(("AIEN.groupAllowDisperse, missing controller for: " .. tostring(group:getName())))
        end	
    else
        env.info(("AIEN.groupAllowDisperse, missing group"))        
    end
end

local function groupPreventDisperse(group)
    if group and group:isExist() == true then
        local gController = group:getController()
        if gController then
            gController:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, false) -- Ground or GROUND?
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info(("AIEN.groupPreventDisperse will prevent dispersal"))
            end		
        else
            env.info(("AIEN.groupPreventDisperse, missing controller for: " ..tostring(group:getName())))
        end
    else
        env.info(("AIEN.groupPreventDisperse, missing group"))    
    end
end

local function groupSuppress(group) -- quite important: provide random "suppression" effect by enabling the ROE "hold fire" for a limited amount of time that will depend from group skill
    if group and group:isExist() == true then
        local c = group:getController()
        if c then
			local s = getGroupSkillNum(group)
			local st = getReactionTime(s)*2
			
            c:setOption(AI.Option.Ground.id.ROE, 4)
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info(("AIEN.groupSuppress group has been suppressed " .. tostring(group:getName()) ))
            end	
            local back = function()
                c:setOption(AI.Option.Ground.id.ROE, 2)
            end
            if back then
                timer.scheduleFunction(back, {}, timer.getTime() + st)
            end
        end
    end
end 


--## MISSION ACTION -- these are more advanced command for groups
local function groupfireAtPoint(var)
    local group = var[1] -- groupTableCheck(var[1])
    if AIEN.config.AIEN_debugProcessDetail == true then
        env.info((tostring(ModuleName) .. ", groupfireAtPoint group check"))
    end	
    if group and group:isExist() then
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", groupfireAtPoint group name: " .. tostring(group:getName())))
        end	
        local gController = group:getController()
        local vec3 = vec3Check(var[2])
        local qty = var[3]
        local desc = var[4]
        local radi = var[5]

        if gController and vec3 then
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", groupfireAtPoint controller and vec3 identified"))
            end	
            local expd = true
            
            if not var[3] then
                expd = false
                qty = nil
            end

            if not radi then
                radi = 50
            end

            local _tgtVec2 =  { x = vec3.x  , y = vec3.z} 
            local _task = { 
                id = 'FireAtPoint', 
                params = { 
                point = _tgtVec2,
                radius = 50,
                expendQty = qty,
                expendQtyEnabled = expd,
                alt_type = 1,
                }
            } 

            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", groupfireAtPoint variables set"))
            end	

            gController:setTask(_task)
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", groupfireAtPoint fire mission planned"))
            end
            
            -- message feedback
            if AIEN.config.message_feed == true then

                local lat, lon = coord.LOtoLL(vec3)
                local MGRS = coord.LLtoMGRS(coord.LOtoLL(vec3))
                if lat and lon then

                    -- local LL_string = tostringLL(lat, lon, 0, true)
                    -- local MGRS_string = tostringMGRS(MGRS ,4)

                    local zTgt     = bc:getZoneOfPoint(vec3)
                    local zoneName = zTgt and zTgt.zone or ""

                    local txt = ""
                    local fullName  = group:getName()
                    local shortName = fullName:sub(1,18) 
                    txt = txt .. "C2, " .. shortName .. ", request fire mission, fire for Effect."
                    --txt = txt .. "\n" .. tostring(MGRS_string) .. "\n" .. tostring(LL_string)
                    if zoneName ~= "" then
                        txt = txt .. "\nZone: " .. zoneName
                    end
                    if desc and type(desc) == "string" then
                        txt = txt .. "\n" .. desc
                    end
                    if expd and qty and type(qty) == "number" then
                        txt = txt .. "\n" .. tostring(qty) .. " rounds"
                    end
                    txt = txt .. "\n" .. "Cleared for fire when ready"

                    local vars = {"text", txt, 20, nil, nil, nil, group:getCoalition()}

                    multyTypeMessage(vars)

                end
            end

            -- mark on map for coalition
            if AIEN.config.mark_on_f10_map == true then

                local lat, lon = coord.LOtoLL(vec3)
                local MGRS = coord.LLtoMGRS(coord.LOtoLL(vec3))
                if lat and lon then

                    local LL_string = tostringLL(lat, lon, 0, true)
                    local MGRS_string = tostringMGRS(MGRS ,4)
                    local txt = ""
                    txt = txt .. tostring(group:getName())
                    txt = txt .. "\n" .. "Fire mission"
                   -- txt = txt .. "\n" .. tostring(MGRS_string) .. "\n" .. tostring(LL_string)

                    markIdStart = markIdStart + 1
                    trigger.action.markToCoalition(markIdStart, txt, vec3, group:getCoalition(), false, false)

                end
            end


        else
            env.info((tostring(ModuleName) .. ", groupfireAtPoint, missing controller or for: " .. tostring(group:getName())))
        end	
    else
        env.info((tostring(ModuleName) .. ", groupfireAtPoint, missing group"))        
    end
end


--## ROUTE AND PATHFINDING

local function checkValidTerrainSurface(vec3)
    if vec3 then
        if type(vec3) == 'table' then -- assuming name
            if vec3.x and vec3.y and vec3.z then
                local l = land.getSurfaceType({x = vec3.x, y = vec3.z})
                if l then
                    if l == 1 or l == 4 or l == 5 then
                        
                        -- check slope
                        local slope = getTerrainSlopeAtPoint(vec3, 20)     
                        if slope and slope < AIEN.config.maxSlope then
                            return true, l
                        else
                            env.info((tostring(ModuleName) .. ", checkValidDestination: terrain slope more than max!"))
                            return false, l
                        end            

                    else
                        return false, l
                    end
                else
                    env.info((tostring(ModuleName) .. ", checkValidDestination: l not identified!"))
                    return false
                end
            else
                env.info((tostring(ModuleName) .. ", checkValidDestination: wrong vector format"))
                return false
            end
        else
            env.info((tostring(ModuleName) .. ", checkValidDestination: wrong variable"))
            return false
        end
    else
        env.info((tostring(ModuleName) .. ", checkValidDestination: missing variable"))
        return false
    end
end

local function getMEroute(group) -- basically a copy of getGroupRoute
    -- refactor to search by groupId and allow groupId and groupName as inputs
	local gpId = nil
    if group and group:isExist() == true then
        gpId = group:getID()
	end
	
	if gpId then
		for coa_name, coa_data in pairs(env.mission.coalition) do
			if (coa_name == 'red' or coa_name == 'blue') and type(coa_data) == 'table' then
				if coa_data.country then --there is a country table
					for _, cntry_data in pairs(coa_data.country) do
						for obj_type_name, obj_type_data in pairs(cntry_data) do
							if obj_type_name == "helicopter" or obj_type_name == "ship" or obj_type_name == "plane" or obj_type_name == "vehicle" then	-- only these types have points
								if ((type(obj_type_data) == 'table') and obj_type_data.group and (type(obj_type_data.group) == 'table') and (#obj_type_data.group > 0)) then	--there's a group!
									for _, group_data in pairs(obj_type_data.group) do
										if group_data and group_data.groupId == gpId	then -- this is the group we are looking for
											if group_data.route and group_data.route.points and #group_data.route.points > 0 then
												local points = {}

												for point_num, point in pairs(group_data.route.points) do
													local routeData = {}
													routeData.name = point.name
													if not point.point then
														routeData.x = point.x
														routeData.y = point.y
													else
														routeData.point = point.point	--it's possible that the ME could move to the point = Vec2 notation.
													end
													routeData.form = point.action
													routeData.speed = point.speed
													routeData.alt = point.alt
													routeData.alt_type = point.alt_type
													routeData.airdromeId = point.airdromeId
													routeData.helipadId = point.helipadId
													routeData.type = point.type
													routeData.action = point.action
													routeData.task = point.task
													points[point_num] = routeData
												end

												return points
											end
											return
										end	--if group_data and group_data.name and group_data.name == 'groupname'
									end --for group_num, group_data in pairs(obj_type_data.group) do
								end --if ((type(obj_type_data) == 'table') and obj_type_data.group and (type(obj_type_data.group) == 'table') and (#obj_type_data.group > 0)) then
							end --if obj_type_name == "helicopter" or obj_type_name == "ship" or obj_type_name == "plane" or obj_type_name == "vehicle" or obj_type_name == "static" then
						end --for obj_type_name, obj_type_data in pairs(cntry_data) do
					end --for cntry_id, cntry_data in pairs(coa_data.country) do
				end --if coa_data.country then --there is a country table
			end --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then
		end --for coa_name, coa_data in pairs(mission.coalition) do
	else
		return nil
	end
end

local function groupRoadOnly(group)
    if group and group:isExist() == true  then
        local units = group:getUnits()
        for _, uData in pairs(units) do
            if uData:hasAttribute("Trucks") or uData:hasAttribute("Cars") or uData:hasAttribute("Unarmed vehicles") then
                if AIEN.config.AIEN_debugProcessDetail then
                    env.info(("AIEN.groupRoadOnly found at least one road only unit!"))
                end
                return true
            end
        end
    end
    if AIEN.config.AIEN_debugProcessDetail then
        env.info(("AIEN.groupRoadOnly no road only unit found, or no group"))
    end
    
    return false
end

local function goRoute(group, path)
    if group and path and group:isExist() == true then
        local misTask = {
            id = 'Mission',
            params = {
                route = {
                    points = deepCopy(path),
                },
            },
        }

        local groupCon = group:getController()
        if groupCon then
            groupCon:setTask(misTask)
            return true
        end
        return false
    end
end

local function moveToPoint(group, Vec3destination, destRadius, destInnerRadius, reqUseRoad, formation, haltContact, issuedByClient, clientCoa, groupSpeed,useZone) -- move the group to a point or, if the point is missing, to a random position at about 2 km
    
    if Vec3destination then
        --env.info((tostring(ModuleName) .. ", moveToPoint Vec3destination x = " .. tostring(Vec3destination.x)))
        --env.info((tostring(ModuleName) .. ", moveToPoint Vec3destination y = " .. tostring(Vec3destination.y)))
        --env.info((tostring(ModuleName) .. ", moveToPoint Vec3destination z = " .. tostring(Vec3destination.z)))
        local vt, vv = checkValidTerrainSurface(Vec3destination) 
        if vt == false then
            local newX, newZ = land.getClosestPointOnRoads('roads', Vec3destination.x, Vec3destination.z)
            local newY = land.getHeight({x = newX, y = newZ})
            Vec3destination = {x = newX, y = newY, z = newZ}
            env.info((tostring(ModuleName) .. ", moveToPoint Vec3destination corrected for land, was type " .. tostring(vv)))
        else
            env.info((tostring(ModuleName) .. ", moveToPoint Vec3destination is identified as land, type " .. tostring(vv)))
        end
    end
    
    if group and group:isExist() == true then

        local unit1 = group:getUnit(1)
        if unit1 then
            local curPoint = unit1:getPosition().p
            local point = Vec3destination --required
            local dist = getDist(point,curPoint)
            
            -- start answer
            local msg = ""
            if clientCoa and issuedByClient then
                msg = msg .. tostring(tostring(group:getName()))
            end

            if clientCoa and issuedByClient then
                local latitude, longitude, elev = coord.LOtoLL(point)
                local LL_string = tostringLL(latitude, longitude, 0, true)
                msg = msg .. " move to " .. tostring(LL_string) .. "\n"
            end

            -- checking and define road routing requests
            local useRoads = false
            if issuedByClient == true then
                if not reqUseRoad or reqUseRoad == false then
                    if env.mission.weather.clouds.iprecptns > 0 then
                        useRoads= true
                        if clientCoa then
                            msg = msg .. "unable to move on open ground due to weather, will use road" .. "\n"
                        end                
                    elseif groupRoadOnly(group) == true then
                        useRoads= true
                        if clientCoa then
                            msg = msg .. "unable to move on open ground due to vehicle spec, will use roads" .. "\n"
                        end
                    elseif dist > 30000 then
                        useRoads = true
                        if clientCoa then
                            msg = msg .. "unable to move in open ground due to distance, will use road instead" .. "\n"
                        end
                    else
                        useRoads = false
                        if clientCoa then
                            msg = msg .. "will move on open ground" .. "\n"
                        end
                    end
                else
                    useRoads = true
                    if clientCoa then
                        msg = msg .. "using roads " .. "\n"
                    end
                    -- check if possible and the relative answer
                end
            else
                if not reqUseRoad or reqUseRoad == false then
                    if env.mission.weather.clouds.iprecptns > 0 then
                        useRoads= true            
                    elseif groupRoadOnly(group) == true then
                        useRoads= true
                    elseif dist > 2000 then
                        useRoads = true
                    else
                        useRoads = false
                    end
                else
                    useRoads = true
                end                
            end        

            local rndCoord = nil
            if point == nil then
                point = getRandTerrainPointInCircle(group:getPosition().p, AIEN.config.rndFleeDistance*0.5, AIEN.config.rndFleeDistance*0.1)
                rndCoord = point
            end
        
            if point then	

                local radius = destRadius or 10
                local innerRadius = destInnerRadius or 1		
                
                -- define formation
                local form = formation or 'Offroad'
                if issuedByClient == true and clientCoa and formation then
                    if useRoads == false then
                        msg = msg .. "will deploin in " .. tostring(form) .. " formation " .. "\n"
                    else
                        msg = msg .. "when in open ground, will deploin in " .. tostring(form) .. " formation " .. "\n"
                    end
                end  

                -- define heading
                local heading = math.random()*2*math.pi
                if heading >= 2*math.pi then
                    heading = heading - 2*math.pi
                end

                -- define speed
                local speed = groupSpeed
                if not speed then
                    if useRoads == false then
                        speed = AIEN.config.outRoadSpeed
                    else
                        speed = AIEN.config.inRoadSpeed
                    end
                end

                if issuedByClient == true and clientCoa then
                    msg = msg .. "moving at " .. tostring(math.floor(speed/3.6*10)/10) .. " kmh \n"
                end                

                local path = {}
                local main     = bc:getZoneOfPoint(point)
                local subz     = nil
                if main then
                    for _, cand in ipairs(ZONE_VALID_SUBZONES[main.zone] or {}) do
                        local cz = CustomZone:getByName(cand)
                        if cz and cz:isInside(point) then
                            subz = cand
                            break
                        end
                    end
                end
                local nearDestRoad  = SUBZONE_NEAR_ROAD[zoneSub] or false
                local nearStartRoad = subz and SUBZONE_NEAR_ROAD[subz]
                or isRoadClose(point, math.min(1000, radius * 1.5))
                local tripLong      = radius > 1000   -- straight-line estimate
                useRoads            = (nearStartRoad or nearDestRoad) and tripLong
                if not rndCoord then
                    if useZone == true then
                        env.info('UseZone is true')
                        rndCoord = getRandTerrainPointInCircle(point, radius, innerRadius)
                    else
                        rndCoord = getRandTerrainPointInCircleOriginal(point, radius, innerRadius)
                        --env.info('AIEN.moveToPoint,:getRandTerrainPointInCircle: using zone for random point')
                    end
                end
                
                if rndCoord then

                    local offset = {}
                    local posStart = getLeadPos(group)
                    if posStart then
                        offset.x = round(math.sin(heading - (math.pi/2)) * 50 + rndCoord.x, 3)
                        offset.z = round(math.cos(heading + (math.pi/2)) * 50 + rndCoord.y, 3)
                        path[#path + 1] = buildWP(posStart, form, speed)


                        if useRoads == true and ((point.x - posStart.x)^2 + (point.z - posStart.z)^2)^0.5 > radius * 1.3 then
                            path[#path + 1] = buildWP({x = posStart.x + 11, z = posStart.z + 11}, 'off_road', AIEN.config.outRoadSpeed)
                            path[#path + 1] = buildWP(posStart, 'on_road', speed)
                            path[#path + 1] = buildWP(offset, 'on_road', speed)
                        else
                            path[#path + 1] = buildWP({x = posStart.x + 25, z = posStart.z + 25}, form, speed)
                        end

                        path[#path + 1] = buildWP(offset, form, speed)
                        path[#path + 1] = buildWP(rndCoord, form, speed)

                        goRoute(group, path)
                        if issuedByClient == true and clientCoa then
                            trigger.action.outTextForCoalition(clientCoa, msg, 30)
                            if AIEN.config.AIEN_debugProcessDetail then
                                env.info(("AIEN.moveToPoint msg " .. tostring(msg)))
                            end                        
                        end                     

                        return
                    end
                else
                    env.info((tostring(ModuleName) .. ", moveToPoint failed, no valid coord available"))
                end
            else
                env.info((tostring(ModuleName) .. ", moveToPoint failed, no valid destination available"))
            end
        else
            env.info((tostring(ModuleName) .. ", moveToPoint failed, unit1 not available"))
        end
    end
end


--###### COUNTER BATTERY FIRE ######################################################################

local function counterBattery(hitPos, tgtPos, coa) -- this function emulates counter battery fire
    -- this function is not about simulating the counter battery fire process, which involves projectiles radar detection,
    -- balistic calculations and then defining a shooter position. Instead, for performance purposes, the process is "hinted" using the following method, and start only if the shooter is an "indirect fire" attributes units
    -- this way:
    -- * first, since we don't want to do calc, we took the shooter current position when the hit event occours, to use it later if allowed, called tgtPos   
    -- * second, same reason, we pre-check if a free arty is available in range for fire on shooter position.
    -- * if arty is ok, and given the hit position, we look for the presence of a suitable radar ("SAM SR", "SAM TR", "EWR" since DCS world doesn't have the right kind of unit) within 50km 
    -- * if it's there, since we don't want to do calc much, we simply apply some random math formula that depends on distance as a probabilty of trajectory calc IRL and, also, the accuracy
    -- * if the random pass, the tgt is the passed for arty fire after a random timing that is counterBatteryPlanDelay+-35%.
    if hitPos and tgtPos and coa then
        if type(hitPos) == "table" and type(tgtPos) == "table" then
            if hitPos.x and hitPos.z and tgtPos.x and tgtPos.z then

                local arty = nil
                local pickedOg = nil
                for _, og in pairs(groundgroupsDb) do
                    if og.coa == coa and og.tasked == false then
                        if og.class == "ARTY" or og.class == "MLRS" then --  or og.class == "MLRS" -- not considering MLRS as they're intended for more area or tactical fire
                            if og.group and og.group:isExist() == true and og.sa and og.sa.pos then
                                local d = getDist(og.sa.pos, tgtPos)
                                if d < og.threat*0.9 then
                                    if AIEN.config.AIEN_debugProcessDetail == true then
                                        env.info((tostring(ModuleName) .. ", counterBattery artillery potentially available"))
                                    end
                                    arty = og.group
                                    pickedOg = og
                                    break
                                end
                            end
                        end
                    end
                end

                if arty then

                    -- check for near radar within 50 km, if there, return closer distance
                    local closestRange = AIEN.config.counterBatteryRadarRange
                    local _volume = {
                        id = world.VolumeType.SPHERE,
                        params = {
                            point = hitPos,
                            radius = AIEN.config.counterBatteryRadarRange,
                        },
                    }

                    local _search = function(_obj)
                        pcall(function()
                            if _obj ~= nil and Object.getCategory(_obj) == 1 and _obj:isExist() and _obj:getCoalition() == coa then
                                if _obj:hasAttribute("SAM SR") or _obj:hasAttribute("SAM TR") or _obj:hasAttribute("EWR") then
                                    local d = getDist(_obj:getPoint(), hitPos)
                                    if d < closestRange then
                                        closestRange = d
                                    end
                                end
                            end
                        end)
                    end
                    world.searchObjects(Object.Category.UNIT, _volume, _search)

                    if closestRange < AIEN.config.counterBatteryRadarRange then
                        local ratio = math.min(closestRange / AIEN.config.counterBatteryRadarRange, 1)
                        local f = math.floor((1 - ratio^2) * 100)
                        local r = aie_random(1,100)
                        if f > r then
                            local a = math.floor( ((closestRange/AIEN.config.counterBatteryRadarRange)^1.5)*300)
                            local fpos = getRandTerrainPointInCircleOriginal(tgtPos, a, 1)
                            if fpos then
                                pickedOg.tasked = true
                                pickedOg.taskTime = timer.getTime()
                                pickedOg.firePoint = tgtPos
                                local t = aie_random(math.floor(AIEN.config.counterBatteryPlanDelay*0.65), math.floor(AIEN.config.counterBatteryPlanDelay*1.35))
                                
                                if AIEN.config.message_feed == true then

                                    local lat, lon = coord.LOtoLL(hitPos)
                                    local MGRS = coord.LLtoMGRS(coord.LOtoLL(hitPos))
                                    if lat and lon then
                    
                                        local LL_string = tostringLL(lat, lon, 0, true)
                                        local MGRS_string = tostringMGRS(MGRS ,4)
                    
                                        local txt = ""
                                        txt = txt .. "C2, " .. tostring(arty:getName()) .. ", identified enemy artillery fire. coordinates:"
                                        txt = txt .. "\n" .. tostring(MGRS_string) .. "\n" .. tostring(LL_string)                  
                                        txt = txt .. "\n" .. "Trying to evaluate enemy position. Please wait"
                                        
                                        local vars = {"text", txt, 20, nil, nil, nil, coa}
                    
                                        multyTypeMessage(vars)
                    
                                    end
                                end

                                local func = function()
                                    groupfireAtPoint({arty, fpos, 20, "Counter battery fire"})
                                end
                                timer.scheduleFunction(func, nil, timer.getTime() + t)

                            else
                                if AIEN.config.AIEN_debugProcessDetail == true then
                                    env.info((tostring(ModuleName) .. ", counterBattery failed fpos calculation"))
                                end
                                return false
                            end

                        else
                            if AIEN.config.AIEN_debugProcessDetail == true then
                                env.info((tostring(ModuleName) .. ", counterBattery f=" .. tostring(f) .. ", r=" .. tostring(r) .. " failed"))
                            end
                            return false
                        end

                    end

                else
                    if AIEN.config.AIEN_debugProcessDetail == true then
                        env.info((tostring(ModuleName) .. ", counterBattery artillery not available"))
                    end
                    return false
                end
            else
                if AIEN.config.AIEN_debugProcessDetail == true then
                    env.info((tostring(ModuleName) .. ", counterBattery variable x and z missing"))
                end
                return false
            end
        else
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", counterBattery variables wrong format"))
            end
            return false
        end

    else
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", ac_fireMissionOnShooter return false due to missing variable"))
        end
        return false
    end        

end




--###### DISMOUNT FUNCTIONS ########################################################################

-- This part of the code, basically modified from CTLD ones, handle the automatic troop dismount-remount behaviour.
-- Those functions are maybe the most "delicate" of the code, so think about them at least three times before touching ;)

local function createUnit(_x, _y, _angle, _n, _t)

    local id = aie_random(1,4) -- had to do this cause random is not defined once in game
    local sk = nil
    if id == 1 then
        sk = "Average"
    elseif id == 2 then
        sk = "Good"
    elseif id == 3 then
        sk = "High"
    elseif id == 4 then
        sk = "Excellent"
    end

    local _newUnit = {
        ["y"] = _y,
        ["type"] = _t,
        ["name"] = _n,
        ["heading"] = _angle,
        ["playerCanDrive"] = true,
        ["skill"] = sk,
        ["x"] = _x,
    }

    return _newUnit
end

local function findNearestEnemy(_side, _point, _searchDistance, _reposition)

    local repoOffset
    if not _reposition then
        repoOffset = 3
    else
        repoOffset = AIEN.config.droppedReposition
    end

    local mindistance = _searchDistance
    local enemyPos = nil
    local volS = {
    id = world.VolumeType.SPHERE,
    params = {
        point = _point,
        radius = _searchDistance
        }
    }
    
    local ifFound = function(foundItem, val)
        local itemPos = foundItem:getPosition().p
        local itemCoa = foundItem:getCoalition()
        if itemPos and itemCoa and itemCoa ~= _side and itemCoa ~= 0 then
            local dist = getDist(itemPos, _point)
            if dist < mindistance then
                mindistance = dist
                enemyPos = foundItem:getPosition().p
            end
        end
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)    

    if enemyPos ~= nil then
        local _x = enemyPos.x + aie_random(1, 20) - aie_random(1, 20)
        local _z = enemyPos.z + aie_random(1, 20) - aie_random(1, 20)
        local _y = enemyPos.y + aie_random(1, 20) - aie_random(1, 20)
        return { x = _x, y =_y, z = _z}

    else
        local _x = _point.x + aie_random(1, repoOffset) - aie_random(1, repoOffset)
        local _z = _point.z + aie_random(1, repoOffset) - aie_random(1, repoOffset)
        local _y = _point.y + aie_random(1, repoOffset) - aie_random(1, repoOffset)
        return { x = _x, y =_y, z = _z}
    end    

end

local function getEnemyStrInrange(_side, _point, _searchDistance)

    local _enemySide = nil
    if _side == 1 then
        _enemySide = 2
    elseif _side == 2 then
        _enemySide = 1
    end

    local volS = {
    id = world.VolumeType.SPHERE,
    params = {
        point = _point,
        radius = _searchDistance
        }
    }
    
    local _count = 0
    local _search = function(_obj)
        pcall(function()
            if _obj then
                if _obj:getLife() > 0 and _obj:getCoalition() == _enemySide then
                    _count = _count + _obj:getLife()
                end
            end
        end)
        return true
    end
    world.searchObjects(Object.Category.UNIT, volS, _search)     

    return _count

end

local function getAliveGroup(_group)
    if _group and _group:isExist() == true and #_group:getUnits() > 0 then
        return _group
    end
    return nil
end

local function orderInfantryToMoveToPoint(_group, _destination)

    local _start = getLeadPos(_group)
    local _path = {}

    local routing = 'Off Road'
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = _start,
            radius = AIEN.config.infantrySearchDist,
        }
    }
    local _count = 0

    local _zc = bc and bc.getZoneOfPoint and bc:getZoneOfPoint(_start)
    if _zc then
        local _cz = CustomZone:getByName(_zc.zone)
        if _cz then
            local _allBld = _cz:getZoneBuildings()
            if _allBld then
                for _, _bp in ipairs(_allBld) do
                    if getDist(_bp, _start) < AIEN.config.infantrySearchDist then
                        _count = _count + 1
                    end
                end
            end
        end
    end

    if _count == 0 then
        local _search = function(_obj)
            pcall(function()
                local _d = _obj:getDesc()
                if _d then
                    if _d.attributes and _d.attributes.Buildings then
                        _count = _count + 1
                    end
                end
            end)
            return true
        end
        world.searchObjects(Object.Category.SCENERY, volS, _search)
    end     
    
    if AIEN.config.AIEN_debugProcessDetail == true then
        env.info(("AIEN.orderInfantryToMoveToPoint buildings _count = " .. tostring(_count)))
    end	

    if _count > 5 then
        routing = 'on_road'
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info(("AIEN.orderInfantryToMoveToPoint buildings identified, moving on road"))
        end	
    end

    local _dTbl
    if _destination then
        local _x = _destination.x + aie_random(1, 5) - aie_random(1, 5)
        local _z = _destination.z + aie_random(1, 5) - aie_random(1, 5)
        local _y = _destination.y + aie_random(1, 5) - aie_random(1, 5)
        _dTbl = { x = _x, y =_y, z = _z}        
    end


    table.insert(_path, ground_buildWP(_start, routing, AIEN.config.infantrySpeed))
    table.insert(_path, ground_buildWP(_dTbl, routing, AIEN.config.infantrySpeed))
    if routing == 'on_road' then
        table.insert(_path, ground_buildWP(_dTbl, 'Off Road', 5))
    end

    local _mission = {
        id = 'Mission',
        params = {
            route = {
                points =_path
            },
        },
    }

    timer.scheduleFunction(function(_arg)
        local _grp = getAliveGroup(_arg[1])

        if _grp ~= nil then
            local _controller = _grp:getController();
            Controller.setOption(_controller, AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
            Controller.setOption(_controller, AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.OPEN_FIRE)
            _controller:setTask(_arg[2])
        end
    end
        , {_group, _mission}, timer.getTime() + 2)
end

local function defineTroopsNumber(unit)
    if unit and unit:isExist() then
        local num = 0
        for dId, dNum in pairs(dismountCarriers) do
            if unit:hasAttribute(dId) then
                if num < dNum then
                    num = dNum
                end
            end
        end
        if num and num > 0 then
            return num
        end
    end
    return 0
end

local function deployTroops(unit, exactPos)
	if not unit then return end
    local _point = unit:getPoint()
    local _onboard = mountedDb[unit:getID()]
    local _coa = unit:getCoalition()
    local zoneCom = BattleCommander:getZoneOfUnit(unit:getName())
        if not zoneCom or zoneCom.side ~= 1 or _coa ~= coalition.side.RED then
        return
    end
    local function deploy(team, num)
        if team then
            local isMortar = false
            local Name = unit:getName()
            local _groupName
            if Name:lower():find("red sam") then
                 _groupName = "_dismounted_" .. tostring(num)
                else
                _groupName = Name .. "_dismounted_" .. tostring(num)
            end
            local _group = {
                ["visible"] = false,
                ["hidden"] = false,
                ["units"] = {},
                ["name"] = _groupName,
                ["task"] = {},
            }

            local _pos = _point
            for _i, _soldier in ipairs(team) do
                if contains(_soldier, "mortar") then
                    isMortar = true
                end            

                local _angle = math.pi * 2 * (_i - 1) / #team
                local _xOffset = math.cos(_angle) * 15 + num
                local _yOffset = math.sin(_angle) * 15 + num
                local _name = _groupName .. "_".. tostring(_i)

                _group.units[_i] = createUnit(_pos.x + _xOffset, _pos.z + _yOffset, _angle, _name, _soldier)
            end


            _group.category = Group.Category.GROUND;
            _group.country = unit:getCountry();

            local _spawnedGroup = Group.getByName(dynAdd(_group).name)

            if _spawnedGroup then
                if zoneCom and zoneCom.side == 1 then
                    table.insert(zoneCom.built, _spawnedGroup:getName())
                end
                if exactPos then
                    if isMortar == false then
                        orderInfantryToMoveToPoint(_spawnedGroup, exactPos)
                    end
                else
                    local _enemyPos = findNearestEnemy(_coa, _point, AIEN.config.infantrySearchDist)

                    if _enemyPos and isMortar == false then
                        orderInfantryToMoveToPoint(_spawnedGroup, _enemyPos)
                    end

                    mountedDb[unit:getID()] = nil
                    if AIEN.config.AIEN_debugProcessDetail == true then
                        env.info(("AIEN.deployTroops units deployed for unit " .. tostring(unit:getName())))
                    end	
                end
                return _spawnedGroup
            end
        end
    end

    if _onboard then
        for _g, _team in ipairs(_onboard) do
            deploy(_team, _g)
        end

        infcarrierDb[unit:getID()] = defineTroopsNumber(unit)
    end
end

local function extractTroops(unit)

    if unit and unit:isExist() then
        if unit:hasAttribute("IFV") or unit:hasAttribute("APC") or unit:hasAttribute("Trucks") then
            local people = infcarrierDb[unit:getID()]
            if not people then
                infcarrierDb[unit:getID()] = defineTroopsNumber(unit)
            end
            local uCoa = unit:getCoalition()
            if people and people > 0 then

                local foundAnything = true    
                local done = {}

                local function loadTeam()
                    
                    local mindistance = AIEN.config.infantryExtractDist

                    local volS = {
                    id = world.VolumeType.SPHERE,
                    params = {
                        point = unit:getPoint(),
                        radius = AIEN.config.infantryExtractDist
                        }
                    }

                    local nearestU = nil
                    local ifFound = function(foundItem, val)
                        if foundItem:getCoalition() == uCoa then
                            local fgId = foundItem:getGroup():getID()
                            if not done[fgId] then
                                if foundItem:hasAttribute("Infantry") then
                                    local posu = foundItem:getPoint()
                                    local dist = getDist(posu, unit:getPoint())
                                    if dist < mindistance then
                                        mindistance = dist
                                        nearestU = foundItem
                                    end
                                end
                            end
                        end
                    end
                    world.searchObjects(Object.Category.UNIT, volS, ifFound)

                    local typ = nil
                    local gtbl = nil
                    if nearestU then
                        local foundg = nearestU:getGroup()
                        if foundg then
                            if not done[foundg:getID()] then
                                local units = foundg:getUnits()
                                if units and #units > 0 then
                                    local tot = 0
                                    local inf = 0
                                    for _, u in pairs(units) do
                                        if u:hasAttribute("Infantry") then
                                            inf = inf + 1
                                            if not typ then
                                                typ = {}
                                            end
                                            typ[#typ+1] = u:getTypeName()
                                        end
                                        tot = tot + 1
                                    end

                                    if inf == tot and inf <= people then
                                        people = people - inf
                                        gtbl = foundg
                                    end
                                end    
                            end
                        end    
                    end

                    if typ and gtbl then
                        infcarrierDb[unit:getID()] = people
                        local loadedGroups = mountedDb[unit:getID()] or {}
                        loadedGroups[#loadedGroups+1] = typ
                        mountedDb[unit:getID()] = loadedGroups
                        if AIEN.config.AIEN_debugProcessDetail == true then
                            env.info(("AIEN.groupExtractTroop unit " .. tostring(unit:getName()) ..  ", extracted " .. tostring(gtbl:getName()) .. ", people: " .. tostring(people) ))
                        end	
                        done[gtbl:getID()] = true
                        gtbl:destroy()
                    else
                        if AIEN.config.AIEN_debugProcessDetail == true then
                            env.info(("AIEN.groupExtractTroop extraction found anything" ))
                        end	
                        foundAnything = false
                    end
                end

                while people >= 4 and foundAnything == true do
                    if AIEN.config.AIEN_debugProcessDetail == true then
                        env.info(("AIEN.groupExtractTroop unit " .. tostring(unit:getName()) ..  ", launching loadTeam, people " .. tostring(people) ))
                    end	
                    loadTeam()
                end

                if AIEN.config.AIEN_debugProcessDetail and AIEN_io and AIEN_lfs then
                    dumpTableAIEN("infcarrierDb.lua", infcarrierDb, "int")
                    dumpTableAIEN("mountedDb.lua", mountedDb, "int")
                end

            end
        end
    end

end

local function groupExtractTroop(group)

    if group and group:isExist() == true and #group:getUnits() > 0 then
        local units = group:getUnits()
        for _, uData in pairs(units) do
            if mountedDb[uData:getID()] == nil then
                if AIEN.config.AIEN_debugProcessDetail == true then
                    env.info(("AIEN.groupExtractTroop units extracting troops " .. tostring(uData:getName())))
                end	
                extractTroops(uData)
            end
        end
    end
    return nil
end

local function groupCarryInfantry(group) -- needed?
    if group and group:isExist() == true and #group:getUnits() > 0 then
        local units = group:getUnits()
        local isCarrying = false
        for _, uData in pairs(units) do
            if mountedDb[uData:getID()] then
                isCarrying = true
                break
            end
        end
        return isCarrying 
    end
end

local function mountTeam(unit)

	local uName = unit:getName()
	local volS = {
		id = world.VolumeType.SPHERE,
		params = {
			point = unit:getPoint(),
			radius = AIEN.config.infantrySearchDist
		}
	}

	local commandIssued = {}
	local groupMoving = 0
	local ifFound = function(foundItem, val)
		if contains(foundItem:getName(), uName) then
			if AIEN.config.AIEN_debugProcessDetail then
				env.info((tostring(ModuleName) .. ", groupMountTeam, " .. tostring(foundItem:getName()) .. " recognized for " .. tostring(uName)))
			end	
			local foundg = foundItem:getGroup()
			if not commandIssued[foundg:getID()] then
				if foundg and foundg:isExist() == true and #foundg:getUnits() > 0 then
					orderInfantryToMoveToPoint(foundg, unit:getPoint())
					commandIssued[foundg:getID()] = true
					groupMoving = groupMoving + 1
				end
			end
		end
	end
	world.searchObjects(Object.Category.UNIT, volS, ifFound)

	if AIEN.config.AIEN_debugProcessDetail then
		env.info((tostring(ModuleName) .. ", groupMountTeam, " .. tostring(groupMoving) .. " groups have been ordered to move nearby " .. tostring(uName)))
	end	

	if groupMoving > 0 then
		timer.scheduleFunction(extractTroops, unit, timer.getTime() + 600)
	end


end

local function groupMountTeam(group) 
    -- this differs substantially from "Extract": basically it's calling the deployed teams to go back to its original vehicle
    -- the original vehicle is defined in a very "stupid" way: by searching unit name in the others groups nearby, which should be there
    -- in the dismounted group name. It's a very "hardcoded" convetion, I know, but still less complicated than many other solutions
    -- and does not require to track troops in another separated db (which already are too many to me)
    -- timing of 7 mins (420 s) seems reasonable to me for the regrouping of the dismounted troops, given the 2 km range.

    if group and group:isExist() == true and #group:getUnits() > 0 then
        for _, uData in pairs(group:getUnits()) do 
			mountTeam(uData)
        end
    end
end

local function groupDeployTroop(group, nocomeback, exactPos)
    if group and group:isExist() == true and group:getUnits() and #group:getUnits() > 0 then
        local units = group:getUnits()
        for _, uData in pairs(units) do

            local id = uData:getID()
            if id then
                if mountedDb[uData:getID()] then
                    deployTroops(uData, exactPos)

                    if not nocomeback then
                        timer.scheduleFunction(groupMountTeam, group, timer.getTime() + AIEN.config.remountTime)
                    end

                    return true
                end
            end
        end
    end
    return nil
end

local function groupCheckForManpad(group)
	if group and group:isExist() then
		local unitsWithTroops = getTroops(group)
		if unitsWithTroops and next(unitsWithTroops) ~= nil then
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info(("AIEN.groupCheckForManpad, unitsWithTroops available" ))
            end	
			local manpadTeams = {}
			for uId, uData in pairs(unitsWithTroops) do 
				for _, teams in pairs(uData.t) do
					for _, soldier in pairs(teams) do
						if contains(soldier, "manpad") then
                            if AIEN.config.AIEN_debugProcessDetail == true then
                                env.info(("AIEN.groupCheckForManpad, has manpads" ))
                            end	
							manpadTeams[uId] = uData.u
						end
					end
				end
			end

            return manpadTeams
			
		end
	end
    return nil
end

local function groupDeployManpad(group) -- this won't trigger the deploy of any kind of troops, but only for the manpad team (if there)
	if group and group:isExist() then
		local manpadTeams = groupCheckForManpad(group)
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info(("AIEN.groupDeployManpad, manpadTeams: " .. tostring(manpadTeams) ))
        end	
		if manpadTeams and next(manpadTeams) ~= nil then 
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info(("AIEN.groupDeployManpad, confirmed deployable manpads team" ))
            end	
			for _, manpads in pairs(manpadTeams) do
				deployTroops(manpads)
                timer.scheduleFunction(groupMountTeam, group, timer.getTime() + AIEN.config.remountTime)			
			end
		end
	end
end

-- ## externally access command, by script

function AIEN_groupDeploy(gName, noremount) -- this one is global, to provide any user to make a group manually dismount via script or trigger action (do script) if remountVar is true, the dismounted group will go back to its vehicle after about 10 mins.
    if gName and type(gName) == "string" then
        local g = Group.getByName(gName)
        if g then
            groupDeployTroop(g, noremount)
        end
    end
end



--###### MISSION REACTIONS #########################################################################

--[[ Reactions is probably the most important behaviour change you will notice using this scripts. Reactions are (currently) triggered only by an hit event on one of the group unit. 
    Obvioulsy optimizable, the code structure basically works this way:
    1. when the hit event happen, some info are gathered in the event function event_hit that will launch executeReactions
    2. the function executeReactions basically will "try" to execute each of the below actions, in a priority order defined in the event_hit
    3. before defining priorities, all these functions are "filtered" by group skills (less skilleg group won't have the most refined solutions) and prioritized by conditions and available informations
    4. the first function that return as a "success" is then executed, and the behaviour take place.

    Side note: suppression, dismount (of all or only manpads) effect are NOT dependand to the scoring model and will take place in parallel.
--]]--


local function ac_accelerate(group, ownPos, tgtPos, resume, sa, skill) -- self-explanatory
    if AIEN.config.AIEN_debugProcessDetail then
        env.info((tostring(ModuleName) .. ", ac_accelerate launched"))
    end

    if group then
        local s, ms = getGroupSpeed(group)
        if not s or s <= 0 then
            if AIEN.config.AIEN_debugProcessDetail then
                env.info((tostring(ModuleName) .. ", ac_accelerate failed to get speed, returning false assuming stationary"))
            end
            return false
        end

        local c = group:getController()
        if c then
            c:setSpeed(30, true) -- 30 m/s = 108 km/h
            return true
        else
            if AIEN.config.AIEN_debugProcessDetail then
                env.info((tostring(ModuleName) .. ", ac_accelerate controller not found"))
            end
            return false
        end
    end
    return false
end

local function ac_disperse(group, ownPos, tgtPos, resume, sa, skill) -- basically simply allow for dispersion
    -- group is the group subject of the action
    -- pos is, when needed, the reference position for the actions, or own position
    -- resume is a boolean. If true, after some time the group will resume it's previous condition, else no.
    -- sa is the SA table passed from the group DB, which hold some useful information for addressing the action 
    if AIEN.config.AIEN_debugProcessDetail then
        env.info((tostring(ModuleName) .. ", ac_disperse launched, move randomly"))
    end    
    
    if group then
        groupAllowDisperse(group)
        return true
    else
        return false
    end
end

local function ac_panic(group, ownPos, tgtPos, resume, sa, skill) -- this will make the group to run away randomly.. that mean sometimes even toward the enemy.
    -- group is the group subject of the action
    -- pos is, when needed, the reference position for the actions, or own position
    -- resume is a boolean. If true, after some time the group will resume it's previous condition, else no.
    -- sa is the SA table passed from the group DB, which hold some useful information for addressing the action 
    if AIEN.config.AIEN_debugProcessDetail then
        env.info((tostring(ModuleName) .. ", ac_panic launched, move randomly"))
    end    
    
    if group and group:isExist() and ownPos then

        if AIEN.config.dismount == true then
            groupDeployTroop(group, false)
        end

        local funcDoAction = function()
            if group:isExist() then
                local np = nil
                local maxTries = 100
                while not np do
                    if AIEN.config.AIEN_debugProcessDetail then
                        env.info((tostring(ModuleName) .. ", ac_panic creating point..."))
                    end
                    maxTries = maxTries - 1
                    if maxTries < 0 then
                        break
                    end
                    env.info('Panic function is calling')
                      np = getRandTerrainPointInCircle(ownPos, 2000, 500, true)
                end
                if np and not np.z then
                    np = { x = np.x, y = land.getHeight({x = np.x, y = np.y}), z = np.y }
                end
                if np then
                    local directD   = ((ownPos.x - np.x)^2 + (ownPos.z - np.z)^2)^0.5
                    local hopMax    = math.min(1000, directD * 0.8)
                    local tripLong  = directD > 700

                    local subz      = nil
                    local main      = bc:getZoneOfPoint(ownPos)
                    if main then
                        for _, cand in ipairs(ZONE_VALID_SUBZONES[main.zone] or {}) do
                            local cz = CustomZone:getByName(cand)
                            if cz and cz:isInside(ownPos) then subz = cand break end
                        end
                    end

                    local nearStart = subz and SUBZONE_NEAR_ROAD[subz] or isRoadClose(ownPos, hopMax * 1.5)
                    local nearDest  = isRoadClose(np, hopMax * 1.5)
                    local useRd     = (nearStart or nearDest) and tripLong
                    local form      = useRd and "On Road" or "Off Road"

                    env.info('Panic function is calling moveToPoint')
                    moveToPoint(group, np, 50, 5, nil, form)
                end
            end 
        end

        local funcSetParameters = function()
            if group:isExist() then
                local c = group:getController()
                if c then
                    c:setSpeed(30, true) -- 30 m/s = 108 km/h
                end
            end
        end

        local delay = getReactionTime(skill)
        timer.scheduleFunction(funcDoAction, nil, timer.getTime() + delay)    
        timer.scheduleFunction(funcSetParameters, nil, timer.getTime() + delay + 5)  

        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", ac_panic group planned reaction"))
        end

        return true
    end
    return false
end

local function ac_dropSmoke(group, ownPos, tgtPos, resume, sa, skill) -- basically spawn smokes around the vehicle and move it for 20-30 meters, trying to hide from enemies
    -- group is the group subject of the action
    -- pos is, when needed, the reference position for the actions, or own position
    -- resume is a boolean. If true, after some time the group will resume it's previous condition, else no.
    -- sa is the SA table passed from the group DB, which hold some useful information for addressing the action 
    if AIEN.config.AIEN_debugProcessDetail then
        env.info((tostring(ModuleName) .. ", ac_dropSmoke launched"))
    end    
    
    if group and group:isExist() and ownPos and sa then

        local units = group:getUnits()
        if units then
            -- check at least 50% units can use smoke
            local numTot = 0
            local numSmk = 0
            for _, iData in pairs(units) do
                numTot = numTot + 1
                if iData:hasAttribute("HeavyArmoredUnits") or iData:hasAttribute("IFV") then
                    numSmk = numSmk +1
                end
            end
            if numTot > 0 then
                if numSmk/numTot < 0.5 then
                    if AIEN.config.AIEN_debugProcessDetail == true then
                        env.info((tostring(ModuleName) .. ", ac_dropSmoke dropped cause less than 50% units can do that"))
                    end
                    return false
                end
            end
        end

        local funcDoAction = function()
            
            if group:isExist() then

                if AIEN.config.smoke_source_num > 9 then
                    AIEN.config.smoke_source_num = 9
                elseif AIEN.config.smoke_source_num < 4 then
                    AIEN.config.smoke_source_num = 4
                end
                
                local units = group:getUnits()
                local smoked = false
                if units then

                    -- plan smoke
                    for _, uData in pairs(units) do

                        if uData:hasAttribute("HeavyArmoredUnits") or uData:hasAttribute("IFV") then

                            local uPos = uData:getPoint()

                            local points = genSmokePoints(uPos, aie_random(15, 30), AIEN.config.smoke_source_num)
                    
                            if points and #points > 0 then
                                
                                if AIEN.config.AIEN_debugProcessDetail == true then
                                    env.info((tostring(ModuleName) .. ", ac_dropSmoke points " .. tostring(#points)))
                                end

                                --phase 1 generate smoke
                                for _, pPos in pairs(points) do
                                    local f = function()
                                        trigger.action.smoke(pPos, 2)
                                    end
                                    timer.scheduleFunction(f, nil, timer.getTime() + aie_random(1, 5)) 
                                end
                    
                                --phase 2 move in a random point very near (20-30 mt)
                                smoked = true
                    
                            else
                                if AIEN.config.AIEN_debugProcessDetail then
                                    env.info((tostring(ModuleName) .. ", ac_dropSmoke unable to define smoke points"))
                                end  
                                --return false
                            end   
                        end
                    end
                end
                
                if smoked == true then
                    moveToPoint(group, ownPos, 5, 14) -- 5,14
                    if AIEN.config.AIEN_debugProcessDetail == true then
                        env.info((tostring(ModuleName) .. ", ac_dropSmoke group planned reaction"))
                    end
                end
            end
        end

        local delay = getReactionTime(skill)
        timer.scheduleFunction(funcDoAction, nil, timer.getTime() + delay)    
        return true  
        
    else
        if AIEN.config.AIEN_debugProcessDetail then
            env.info((tostring(ModuleName) .. ", ac_dropSmoke missing variables"))
        end  
        return false
    end
end

local function ac_withdraw(group, ownPos, tgtPos, resume, sa, skill) -- this will make the group to run away to the nearest allied ground group
    -- group is the group subject of the action
    -- pos is, when needed, the reference position for the actions, or own position
    -- resume is a boolean. If true, after some time the group will resume it's previous condition, else no.
    -- sa is the SA table passed from the group DB, which hold some useful information for addressing the action 
    if AIEN.config.AIEN_debugProcessDetail then
        env.info((tostring(ModuleName) .. ", ac_withdraw launched, withdraw"))
    end    
    
    if group and ownPos then
        
        local zoneCom = BattleCommander:getZoneOfUnit(group:getName())
        local bestPos = nil
        local bestName= nil
        local maxDist = AIEN.config.withrawDist
        local startZone = zoneCom and zoneCom.zone
        if zoneCom then
            for _, gName in ipairs(zoneCom.built or {}) do
                local gObj = Group.getByName(gName)
                if gObj and gObj:isExist() then
                    local og = groundgroupsDb[gObj:getID()]
                    if og and og.sa and og.sa.pos
                       and og.coa == group:getCoalition()
                       and og.n ~= group:getName() then

                        local d = getDist(og.sa.pos, ownPos)
                        if AIEN.config.AIEN_debugProcessDetail then
                            env.info(ModuleName .. ", ac_withdraw d " .. tostring(d))
                        end

                        if d and d < maxDist and d > 2000 then
                            bestPos  = og.sa.pos
                            bestName = og.n
                            maxDist  = d
                        end
                    end
                end
            end
        end


        if bestPos then 
            if AIEN.config.AIEN_debugProcessDetail then
            env.info(ModuleName .. ", ac_withdraw best group " .. tostring(bestName) .. " at " .. tostring(maxDist))
            end
            local funcDoAction = function()
                if group:isExist() then
                    moveToPoint(group, bestPos, AIEN.config.repositionDistance*1.5, AIEN.config.repositionDistance*0.5, nil, nil, nil, nil, nil, nil, true)
                end
            end
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", ac_withdraw group planned reaction"))
            end
            local delay = getReactionTime(skill)
            timer.scheduleFunction(funcDoAction, nil, timer.getTime() + delay)      

            if resume then
                -- check if there's a route to be followed once action end
                if group:isExist() then
                    local destination = nil
                    local points = getMEroute(group)
                    if points and #points > 1 then
                        local last = #points
                        local data = points[last] 
                        if data and type(data) == "table" then
                            destination = { x = data.x, y = land.getHeight({x = data.x, y = data.y}), z = data.y}
                        end
                    end
                    if not destination then
                        destination = ownPos
                    end            
                    local funcresumeRoute = function()
                        if group:isExist() then
                            env.info('ac_withdraw is calling moveToPoint')
                            local dZone = bc and bc.getZoneOfPoint and bc:getZoneOfPoint(destination)
                            if startZone and dZone and startZone == dZone.zone then
                                moveToPoint(group, destination, 200, 10, nil, nil, nil, nil, nil, nil, true)
                            else
                                moveToPoint(group, destination, 200, 10)
                            end
                        end
                    end
                    if AIEN.config.AIEN_debugProcessDetail == true then
                        env.info((tostring(ModuleName) .. ", ac_withdraw group planning coming back"))
                    end
                    timer.scheduleFunction(funcresumeRoute, nil, timer.getTime() + aie_random(600, 900))     
                end
            end

            return true
        else
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", ac_withdraw return false due to missing widraw opportunities"))
            end
            return false
        end
    else
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", ac_withdraw return false due to missing variable"))
        end
        return false
    end
end


local function ac_attack(group, ownPos, tgtPos, resume, sa, skill) -- this will make the group to run toward the shooting enemy and open fire
    -- group is the group subject of the action
    -- pos is, when needed, the reference position for the actions, or own position
    -- resume is a boolean. If true, after some time the group will resume it's previous condition, else no.
    -- sa is the SA table passed from the group DB, which hold some useful information for addressing the action 
    if AIEN.config.AIEN_debugProcessDetail then
        env.info((tostring(ModuleName) .. ", ac_attack launched, move toward enemy"))
    end    
    
    if group and tgtPos then
        if sa and (sa.cls=="SAM" or sa.cls=="SHORAD"
                or sa.cls=="AAA" or sa.cls=="ARTY"
                or sa.cls=="MLRS") then
        return false
        end

        -- check for enemies nearby
        local enemyForce = getEnemyStrInrange(group:getCoalition(), tgtPos, 8000)
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", ac_attack enemyForce " .. tostring(enemyForce)))
        end

        if enemyForce and enemyForce > 20 then
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", ac_attack enemy seems too strong for 1 group, abort action"))
            end
            return false
        end

        local funcDoAction = function()
            if group:isExist() then
                local speed = 10
                if AIEN.config.dismount == true then
                    local deployed = groupDeployTroop(group, false, tgtPos)
                    if deployed == true then
                        speed = 4
                    end
                end
                env.info('ac_attack is calling moveToPoint')
                moveToPoint(group, tgtPos, 300, 500, false, "cone", nil, nil, nil, speed) 
            end
        end
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", ac_attack group planned reaction"))
        end
        local delay = getReactionTime(skill)
        timer.scheduleFunction(funcDoAction, nil, timer.getTime() + delay)      
        groupGoShoot(group)

        if resume then
            -- check if there's a route to be followed once action end
            local destination = nil
            local points = getMEroute(group)
            if points and #points > 1 then
                local last = #points
                local data = points[last] 
                if data and type(data) == "table" then
                    destination = { x = data.x, y = land.getHeight({x = data.x, y = data.y}), z = data.y}
                end
            end
            if not destination then
                destination = ownPos
            end            
            local funcresumeRoute = function()
                if group:isExist() then
                    env.info('ac_withdraw is calling moveToPoint funcresumeRoute')
                    moveToPoint(group, destination, 200, 10, false)
                end
            end
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", ac_attack group planning coming back"))
            end
            timer.scheduleFunction(funcresumeRoute, nil, timer.getTime() + aie_random(900, 1200))     
        end

        return true

    else
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", ac_attack return false due to missing variable"))
        end
        return false
    end
end

local function ac_coverBuildings(group, ownPos, tgtPos, resume, sa, skill)
    if AIEN.config.AIEN_debugProcessDetail then
        env.info((tostring(ModuleName) .. ", ac_coverBuildings launched"))
    end    

    if group and ownPos and sa then
        local z1 = bc:getZoneOfPoint(ownPos)
        if not z1 then
            if AIEN.config.AIEN_debugProcessDetail then
                env.info(ModuleName .. ", ac_coverBuildings: ownPos not in BC zone - abort")
            end
            return false
        end
        local cZone = CustomZone:getByName(z1.zone)
        if not cZone then
            if AIEN.config.AIEN_debugProcessDetail then
                env.info(ModuleName .. ", ac_coverBuildings: CustomZone not found - abort")
            end
            return false
        end

        local pN1 = ownPos
        local pN2 = ownPos
        local pN3 = ownPos
        local pN4 = ownPos
        local pos1, pos2, pos3, pos4
        local gCoa = group:getCoalition()
        local allBld = cZone:getZoneBuildings()

        if pN1 and pN2 and pN3 and pN4 then
            pos1 = {x = pN1.x, y = pN1.y, z = pN1.z + AIEN.config.proxyBuildingDistance}
            pos2 = {x = pN2.x, y = pN2.y, z = pN2.z - AIEN.config.proxyBuildingDistance}
            pos3 = {x = pN3.x + AIEN.config.proxyBuildingDistance, y = pN3.y, z = pN3.z}
            pos4 = {x = pN4.x - AIEN.config.proxyBuildingDistance, y = pN4.y, z = pN4.z}

            local function countBld(p)
                if not cZone:isInside(p) then return end
                local count = 0
                local tblPos = {}
                for _, bp in ipairs(allBld) do
                    if getDist(bp, p) < AIEN.config.proxyBuildingDistance then
                        count = count + 1
                        tblPos[#tblPos+1] = bp
                    end
                end
                if count < 4 then return end
                local enemies = false
                local _volume = {
                    id = world.VolumeType.SPHERE,
                    params = { point = p, radius = AIEN.config.proxyBuildingDistance }
                }
                world.searchObjects(Object.Category.UNIT, _volume, function(_obj)
                    if _obj and _obj:getCoalition() ~= gCoa then enemies = true end
                end)
                if enemies then return end
                return count, avgVec3(tblPos)
            end

            local _, p1 = countBld(pos1)
            local _, p2 = countBld(pos2)
            local _, p3 = countBld(pos3)
            local _, p4 = countBld(pos4)

            local function findNearestPoint(p0, ...)
                local points = {...}
                local nearestPoint = nil
                local minDist = nil
                for _, point in ipairs(points) do
                    if point then
                        local dist = getDist(p0, point)
                        if not minDist or dist < minDist then
                            minDist = dist
                            nearestPoint = point
                        end
                    end
                end
                return nearestPoint
            end

            local dest = findNearestPoint(ownPos, p1, p2, p3, p4)

            if dest then
                local funcDoAction = function()
                    if group:isExist() then
                        moveToPoint(group, dest, AIEN.config.repositionDistance, AIEN.config.repositionDistance*0.2,nil,nil,nil,nil,nil,nil,true)
                    end
                end
                if AIEN.config.AIEN_debugProcessDetail then
                    env.info((tostring(ModuleName) .. ", ac_coverBuildings group planned reaction"))
                end
                local delay = getReactionTime(skill)
                timer.scheduleFunction(funcDoAction, nil, timer.getTime() + delay)    

                if resume then
                    local destination = nil
                    local points = getMEroute(group)
                    if points and #points > 1 then
                        local last = #points
                        local data = points[last] 
                        if data and type(data) == "table" then
                            destination = { x = data.x, y = land.getHeight({x = data.x, y = data.y}), z = data.y}
                        end
                    end
                    if not destination then
                        destination = ownPos
                    end            
                    local funcresumeRoute = function()
                        if group:isExist() then
                            env.info('ac_coverBuildings is calling moveToPoint ac_coverBuildings')
                            moveToPoint(group, destination, 200, 10,nil, nil, nil, nil, nil, nil, false)
                        end
                    end
                    timer.scheduleFunction(funcresumeRoute, nil, timer.getTime() + aie_random(420, 900))     
                end                    
                return true
            else
                return false
            end
        end
    end
    return false
end

local function ac_groundSupport(group, ownPos, tgtPos, resume, sa, skill) -- this will make another ground group to come in support
    -- group is the group subject of the action
    -- pos is, when needed, the reference position for the actions, or own position
    -- resume is a boolean. If true, after some time the group will resume it's previous condition, else no.
    -- sa is the SA table passed from the group DB, which hold some useful information for addressing the action 
    if AIEN.config.AIEN_debugProcessDetail then
        env.info((tostring(ModuleName) .. ", ac_groundSupport launched, move randomly"))
    end    
    
    if group and ownPos and sa then
        local bestVal = 0
        local bestTd  = 1000 
        local AllyGroup = nil
        local bestName = nil
        local z1 = bc:getZoneOfPoint(ownPos)
        if not z1 then return false end
        local builtList = z1.built                                   -- NEW
        if not builtList or #builtList == 0 then                     -- NEW
            if AIEN.config.AIEN_debugProcessDetail then
                env.info(ModuleName .. ", ac_groundSupport: zone built list empty - letting other reactions decide")
            end
            return false
        end   
        for _, gName in ipairs(builtList) do
            local gObj = Group.getByName(gName)
            if gObj and gObj:isExist()
               and gObj:getCoalition() == group:getCoalition()
               and gObj:getName() ~= group:getName() then

                local gData  = groundgroupsDb[gObj:getID()]
                if gData and gData.sa and gData.sa.pos then
                    local cls   = gData.class
                    local score = supportGroundClasses[cls] or 0     -- weighting table
                    if score > bestVal then
                        bestVal  = score
                        bestTd   = gData.threat or bestTd
                        AllyGroup = gObj
                        bestName  = gObj:getName()
                    end
                end
            end
        end

        if AllyGroup and bestTd then 
            local funcDoAction = function()
                if AllyGroup:isExist() then
                    env.info('ac_groundSupport is calling moveToPoint')
                    local aZone = bc and bc.getZoneOfPoint and bc:getZoneOfPoint(getLeadPos(AllyGroup))
                    if aZone then
                        moveToPoint(AllyGroup, ownPos, 150, 40)
                    else
                        moveToPoint(AllyGroup, ownPos, 150, 40, nil, nil, nil, nil, nil, nil, true)
                    end
                end
            end
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info(ModuleName .. ", ac_groundSupport: calling support from " .. tostring(bestName)) -- NEW
            end
            local delay = getReactionTime(skill)
            timer.scheduleFunction(funcDoAction, nil, timer.getTime() + delay)      
 
            return true
        else
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", ac_groundSupport return false due to missing widraw opportunities"))
            end
            return false
        end
    else
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", ac_groundSupport return false due to missing variable"))
        end
        return false
    end
end

local function ac_coverADS(group, ownPos, tgtPos, resume, sa, skill) -- this will make the group to run into the effective range of an allied air defence group
    -- group is the group subject of the action
    -- pos is, when needed, the reference position for the actions, or own position
    -- resume is a boolean. If true, after some time the group will resume it's previous condition, else no.
    -- sa is the SA table passed from the group DB, which hold some useful information for addressing the action 
    if AIEN.config.AIEN_debugProcessDetail then
        env.info((tostring(ModuleName) .. ", ac_coverADS launched"))
    end    
    
    if group and ownPos and sa then
        local bestPos = nil
        local bestVal = 0
        local bestTd  = 3000 
        local bestName = nil                                         -- NEW ➊
        local z1 = bc:getZoneOfPoint(ownPos)
        if not z1 then
            if AIEN.config.AIEN_debugProcessDetail then
                env.info(ModuleName .. ", ac_coverADS: ownPos not in a BC zone - aborting")
            end
            return false
        end

        local builtList = z1.built                                   -- NEW 
        if not builtList or #builtList == 0 then                     -- NEW 
            if AIEN.config.AIEN_debugProcessDetail then
                env.info(ModuleName .. ", ac_coverADS: zone built list empty - letting other reactions decide")
            end
            return false
        end                                                          -- END NEW

        for _, gName in ipairs(builtList) do                         -- CHG ➍
            local gObj = Group.getByName(gName)
            if gObj and gObj:isExist() and gObj:getCoalition() == group:getCoalition() and gObj:getName() ~= group:getName() then
                local gData = groundgroupsDb[gObj:getID()]
                if gData and gData.sa and gData.sa.pos then
                    local cls = gData.class
                    local score = supportCounterAirClasses[cls] or 0
                    if score > bestVal then
                        bestVal = score
                        bestPos = gData.sa.pos
                        bestTd  = gData.threat or bestTd
                        bestName = gObj:getName()                    -- NEW ➎
                    end
                end
            end
        end

        if bestPos and bestTd then 
            if getDist(ownPos, bestPos) < bestTd then
                return false
            end
            local funcDoAction = function()
                if group:isExist() then
                    env.info('ac_coverADS is calling moveToPoint')
                    local destZone = bc and bc.getZoneOfPoint and bc:getZoneOfPoint(bestPos)
                    if destZone and z1 and destZone.zone == z1.zone then
                        moveToPoint(group, bestPos, 100,30)
                    else
                        moveToPoint(group, bestPos, 100,30, nil, nil, nil, nil, nil, nil, true)
                    end
                end
            end
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", ac_coverADS: moving to cover " .. tostring(bestName)))  -- NEW ➏
            end
            local delay = getReactionTime(skill)
            timer.scheduleFunction(funcDoAction, nil, timer.getTime() + delay)      

            if resume then
                local destination = nil
                local points = getMEroute(group)
                if points and #points > 1 then
                    local last = #points
                    local data = points[last] 
                    if data and type(data) == "table" then
                        destination = { x = data.x, y = land.getHeight({x = data.x, y = data.y}), z = data.y}
                    end
                end
                if not destination then
                    destination = ownPos
                end            
                local funcresumeRoute = function()
                    if group:isExist() then
                        env.info('ac_coverADS is calling moveToPoint funcresumeRoute')
                        moveToPoint(group, destination, 200, 10, false, nil, nil, nil, nil, nil, false)
                    end
                end
                if AIEN.config.AIEN_debugProcessDetail == true then
                    env.info((tostring(ModuleName) .. ", ac_coverADS group planning coming back"))
                end
                timer.scheduleFunction(funcresumeRoute, nil, timer.getTime() + aie_random(900, 1200))     
            end
 
            return true
        else
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info((tostring(ModuleName) .. ", ac_coverADS return false due to missing widraw opportunities"))
            end
            return false
        end
    else
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", ac_coverADS return false due to missing variable"))
        end
        return false
    end
end


local function ac_fireMissionOnShooter(group, ownPos, tgtPos, resume, sa, skill) -- this will make an allied artillery in range to fire at enemy shooter position
    -- group is the group subject of the action
    -- pos is, when needed, the reference position for the actions, or own position
    -- resume is a boolean. If true, after some time the group will resume it's previous condition, else no.
    -- sa is the SA table passed from the group DB, which hold some useful information for addressing the action 
    if AIEN.config.AIEN_debugProcessDetail then
        env.info((tostring(ModuleName) .. ", ac_fireMissionOnShooter launched, planning"))
    end    
    
    if tgtPos then
        for _, og in pairs(groundgroupsDb) do
            if og.coa and og.coa == group:getCoalition() and og.tasked == false then
                if og.class and og.class == "ARTY" then --  or og.class == "MLRS" -- not considering MLRS as they're intended for more area or tactical fire
                    if og.group and og.group:isExist() == true then
                        if og.sa and og.sa.pos and og.threat then
                            local d = getDist(og.sa.pos, tgtPos)
                            if d < og.threat*0.8 then
                                og.tasked = true
                                og.taskTime = timer.getTime()
                                og.firePoint = tgtPos
                                groupfireAtPoint({og.group, tgtPos, 20, "Immediate suppression"})
                                if AIEN.config.AIEN_debugProcessDetail == true then
                                    env.info((tostring(ModuleName) .. ", ac_fireMissionOnShooter return true, planning the fire mission"))
                                end

                                return true
                            end
                        end
                    end
                end
            end
        end
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", ac_fireMissionOnShooter return false being unable to plan the fire mission"))
        end
        return false
    else
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info((tostring(ModuleName) .. ", ac_fireMissionOnShooter return false due to missing variable"))
        end
        return false
    end
end
-- summary tablem holds the "scoring model points" for each condition. This can be seen as a decision matrix for evaluate best reaction available.
-- used for fast-filtering actions availability based on group leader skill. 
-- It basically is an array, where the actions are listed in order of complexity. 
-- This way, the skill could be converted into a number, and that number will became the maximum index available.
-- The higher the skill, the higher the index, the higher the actions that could be evaluated
local reactionsDb = {
	[1] 	= { -- ac_accelerate
        ["name"] = "ac_accelerate",
        ["ac_function"] = ac_accelerate,
        ["message"] = "",
        ["resume"] = true,
        ["w_cat"] = { -- weapon category
            [0] = 1, -- shell
            [1] = 1, -- missile
            [2] = 0.8, -- rocket
            [3] = 1, -- bomb
        }, 				
        ["s_cat"] = { -- unit category
            [0] = 1, -- airplane
            [1] = 1, -- helicopter
            [2] = 2, -- ground unit
            [3] = 1, -- ship
            [4] = 0, -- structure
        }, 				
        ["s_indirect"] = { -- unit category
            [0] = 1, -- not an indirect fire unit
            [1] = 0, -- is an indirect fire unit
        }, 			
        ["s_close"] = { -- shooter is within wpn range
            [0] = 1, -- not so close
            [1] = 0, -- close
        }, 	     	      
        ["s_fireMis"] = { -- shooter position and speed
            [0] = 1.5, -- detailed shooter position not known
            [1] = 0, -- detailed shooter position known
        },     
        ["o_cls"] = { 
            ["MBT"] = 2,
            ["ATGM"] = 1,
            ["MLRS"] = 0,
            ["ARTY"] = 0,
            ["MISSILE"] = 0,
            ["MANPADS"] = 0,
            ["SHORAD"] = 3,
            ["AAA"] = 3,
            ["SAM"] = 1,
            ["SAML"]= 1,
            ["SAMC"]= 1,
            ["IFV"] = 0,
            ["APC"] = 0,
            ["RECCE"] = 0,
            ["LOGI"] = 0,
            ["INF"] = 0,
            ["UNKN"] = 0,
        },  
        ["s_cls"] = { 
            ["MBT"] = 0.2,
            ["ATGM"] = 0.4,
            ["MLRS"] = 2.1,
            ["ARTY"] = 1.5,
            ["MISSILE"] = 3.1,
            ["MANPADS"] = 2,
            ["SHORAD"] = 2.2,
            ["AAA"] = 2.8,
            ["SAM"] = 2.3,
            ["SAML"]= 1,
            ["SAMC"]= 1,
            ["IFV"] = 0.4,
            ["APC"] = 0.9,
            ["RECCE"] = 1.2,
            ["LOGI"] = 1.9,
            ["INF"] = 0.8,
            ["UNKN"] = 1,
            ["ARBN"] = 1.4,
        },         
    }, 
	[2] 	= { -- ac_panic
        ["name"] = "ac_panic",
        ["ac_function"] = ac_panic,
        ["message"] = "We're trying to escape fire%!",
        ["resume"] = true,
        ["w_cat"] = { -- weapon category
            [0] = 0.45, -- shell
            [1] = 1.5, -- missile
            [2] = 0.75, -- rocket
            [3] = 1.3, -- bomb
        }, 				
        ["s_cat"] = { -- unit category
            [0] = 1.2, -- airplane
            [1] = 1.2, -- helicopter
            [2] = 1, -- ground unit
            [3] = 1.5, -- ship
            [4] = 0, -- structure
        }, 				
        ["s_indirect"] = { -- unit category
            [0] = 0.5, -- not an indirect fire unit
            [1] = 0.5, -- is an indirect fire unit
        }, 			
        ["s_close"] = { -- shooter is within wpn range
            [0] = 0.8, -- not so close
            [1] = 0, -- close
        }, 	     	      
        ["s_fireMis"] = { -- shooter position and speed
            [0] = 1.2, -- detailed shooter position not known
            [1] = 0, -- detailed shooter position known
        },     
        ["o_cls"] = {
            ["MBT"] = 1.5,
            ["ATGM"] = 1.3,
            ["MLRS"] = 1,
            ["ARTY"] = 1,
            ["MISSILE"] = 2,
            ["MANPADS"] = 2,
            ["SHORAD"] = 0,
            ["AAA"] = 0,
            ["SAML"]= 0,
            ["SAMC"]= 0,
            ["SAM"] = 0,
            ["IFV"] = 0.7,
            ["APC"] = 0.5,
            ["RECCE"] = 0,
            ["LOGI"] = 0.2,
            ["INF"] = 0,
            ["UNKN"] = 0.1,
        },  
        ["s_cls"] = { 
            ["MBT"] = 1.7,
            ["ATGM"] = 1.6,
            ["MLRS"] = 1.3,
            ["ARTY"] = 1,
            ["MISSILE"] = 0.5,
            ["MANPADS"] = 0,
            ["SHORAD"] = 0,
            ["AAA"] = 0,
            ["SAM"] = 0,
            ["SAML"]= 0,
            ["SAMC"]= 0,
            ["IFV"] = 1.4,
            ["APC"] = 0.9,
            ["RECCE"] = 0.3,
            ["LOGI"] = 0.2,
            ["INF"] = 0.1,
            ["UNKN"] = 1,
            ["ARBN"] = 1.8,
        },            
    },     
	[3] 	= { -- ac_disperse
        ["name"] = "ac_disperse",
        ["ac_function"] = ac_disperse,
        ["message"] = "We're stuck here, we ask support if available",
        ["resume"] = true,
        ["w_cat"] = { -- weapon category
            [0] = 1, -- shell
            [1] = 1, -- missile
            [2] = 1, -- rocket
            [3] = 2, -- bomb
        }, 				
        ["s_cat"] = { -- unit category
            [0] = 2, -- airplane
            [1] = 2, -- helicopter
            [2] = 2, -- ground unit
            [3] = 3, -- ship
            [4] = 0, -- structure
        }, 				
        ["s_indirect"] = { -- unit category
            [0] = 0, -- not an indirect fire unit
            [1] = 1.2, -- is an indirect fire unit
        }, 			
        ["s_close"] = { -- shooter is within wpn range
            [0] = 1, -- not so close
            [1] = 0, -- close
        }, 	     	      
        ["s_fireMis"] = { -- shooter position and speed
            [0] = 0, -- detailed shooter position not known
            [1] = 0, -- detailed shooter position known
        },     
        ["o_cls"] = { 
            ["MBT"] = 1.2,
            ["ATGM"] = 1.3,
            ["MLRS"] = 1,
            ["ARTY"] = 1,
            ["MISSILE"] = 2,
            ["MANPADS"] = 2,
            ["SHORAD"] = 1.3,
            ["AAA"] = 1.3,
            ["SAM"] = 1.2,
            ["SAML"]= 0,
            ["SAMC"]= 0,
            ["IFV"] = 0.7,
            ["APC"] = 0.5,
            ["RECCE"] = 0,
            ["LOGI"] = 0.2,
            ["INF"] = 0,
            ["UNKN"] = 0.1,
        }, 
        ["s_cls"] = { 
            ["MBT"] = 1,
            ["ATGM"] = 1.2,
            ["MLRS"] = 1.5,
            ["ARTY"] = 1.5,
            ["MISSILE"] = 2.8,
            ["MANPADS"] = 0.3,
            ["SHORAD"] = 1.5,
            ["AAA"] = 0.6,
            ["SAM"] = 0.6,
            ["SAML"]= 0.3,
            ["SAMC"]= 0.3,
            ["IFV"] = 0.8,
            ["APC"] = 0.7,
            ["RECCE"] = 0.3,
            ["LOGI"] = 0.2,
            ["INF"] = 0.1,
            ["UNKN"] = 1,
            ["ARBN"] = 1.2,
        },          
    },     
	[4] 	= { -- ac_dropSmoke
        ["name"] = "ac_dropSmoke",
        ["ac_function"] = ac_dropSmoke,
        ["message"] = "Dropping smoke cover",
        ["resume"] = true,
        ["w_cat"] = { -- weapon category
            [0] = 0, -- shell
            [1] = 1.4, -- missile
            [2] = 0.9, -- rocket
            [3] = 1.4, -- bomb
        }, 				
        ["s_cat"] = { -- unit category
            [0] = 1.2, -- airplane
            [1] = 1.4, -- helicopter
            [2] = 1, -- ground unit
            [3] = 0, -- ship
            [4] = 0, -- structure
        }, 				
        ["s_indirect"] = { -- unit category
            [0] = 1, -- not an indirect fire unit
            [1] = 0.4, -- is an indirect fire unit
        }, 			
        ["s_close"] = { -- shooter is within wpn range
            [0] = 0, -- not so close
            [1] = 0.8, -- close
        }, 	     	      
        ["s_fireMis"] = { -- shooter position and speed
            [0] = 0.5, -- detailed shooter position not known
            [1] = 0, -- detailed shooter position known
        },     
        ["o_cls"] = { 
            ["MBT"] = 1.5,
            ["ATGM"] = 2,
            ["MLRS"] = 0,
            ["ARTY"] = 0,
            ["MISSILE"] = 0,
            ["MANPADS"] = 0,
            ["SHORAD"] = 0,
            ["AAA"] = 0,
            ["SAM"] = 0,
            ["SAML"]= 0,
            ["SAMC"]= 0,
            ["IFV"] = 2,
            ["APC"] = 1.1,
            ["RECCE"] = 0,
            ["LOGI"] = 0,
            ["INF"] = 0,
            ["UNKN"] = 0,
        }, 
        ["s_cls"] = { 
            ["MBT"] = 2.1,
            ["ATGM"] = 1.8,
            ["MLRS"] = 0,
            ["ARTY"] = 0,
            ["MISSILE"] = 0,
            ["MANPADS"] = 0,
            ["SHORAD"] = 0,
            ["AAA"] = 0,
            ["SAML"]= 0,
            ["SAMC"]= 0,
            ["SAM"] = 0,
            ["IFV"] = 2,
            ["APC"] = 2.3,
            ["RECCE"] = 0,
            ["LOGI"] = 0,
            ["INF"] = 0,
            ["UNKN"] = 0,
            ["ARBN"] = 1.6,
        },          
    },     
	[5] 	= { -- ac_withdraw
        ["name"] = "ac_withdraw",
        ["ac_function"] = ac_withdraw,
        ["message"] = "We're moving in safer area",
        ["resume"] = true,
        ["w_cat"] = { -- weapon category
            [0] = 3, -- shell
            [1] = 1.5, -- missile
            [2] = 0.9, -- rocket
            [3] = 1.4, -- bomb
        }, 				
        ["s_cat"] = { -- unit category
            [0] = 0.9, -- airplane
            [1] = 1, -- helicopter
            [2] = 2, -- ground unit
            [3] = 2, -- ship
            [4] = 1, -- structure
        }, 				
        ["s_indirect"] = { -- unit category
            [0] = 0, -- not an indirect fire unit
            [1] = 1, -- is an indirect fire unit
        }, 			
        ["s_close"] = { -- shooter is within wpn range
            [0] = 2, -- not so close
            [1] = 0, -- close
        }, 	     	      
        ["s_fireMis"] = { -- shooter position and speed
            [0] = 1, -- detailed shooter position not known
            [1] = 3, -- detailed shooter position known
        },     
        ["o_cls"] = { 
            ["MBT"] = 0,
            ["ATGM"] = 0,
            ["MLRS"] = 0,
            ["ARTY"] = 1,
            ["MISSILE"] = 1,
            ["MANPADS"] = 1,
            ["SHORAD"] = 2,
            ["AAA"] = 2,
            ["SAM"] = 0,
            ["SAML"]= 0,
            ["SAMC"]= 0,
            ["IFV"] = 0,
            ["APC"] = 0,
            ["RECCE"] = 0,
            ["LOGI"] = 3,
            ["INF"] = 3,
            ["UNKN"] = 1,
        }, 
        ["s_cls"] = { 
            ["MBT"] = 0,
            ["ATGM"] = 1.8,
            ["MLRS"] = 0.6,
            ["ARTY"] = 0.4,
            ["MISSILE"] = 0.5,
            ["MANPADS"] = 0.1,
            ["SHORAD"] = 0.3,
            ["AAA"] = 0.2,
            ["SAM"] = 0.2,
            ["SAML"]= 0.1,
            ["SAMC"]= 0.1,
            ["IFV"] = 1.5,
            ["APC"] = 0.7,
            ["RECCE"] = 0.3,
            ["LOGI"] = 0.2,
            ["INF"] = 0.1,
            ["UNKN"] = 1,
            ["ARBN"] = 0.7,
        },         
    },     
    [6] 	= { -- ac_attack
        ["name"] = "ac_attack",
        ["ac_function"] = ac_attack,
        ["message"] = "We're going to ambush the enemy",
        ["resume"] = true,
        ["w_cat"] = { -- weapon category
            [0] = 1.5, -- shell
            [1] = 2, -- missile
            [2] = 1, -- rocket
            [3] = 0, -- bomb
        }, 				
        ["s_cat"] = { -- unit category
            [0] = 0, -- airplane
            [1] = 2, -- helicopter
            [2] = 2, -- ground unit
            [3] = 0, -- ship
            [4] = 2, -- structure
        }, 				
        ["s_indirect"] = { -- unit category
            [0] = 2, -- not an indirect fire unit
            [1] = 0, -- is an indirect fire unit
        }, 			
        ["s_close"] = { -- shooter is within wpn range
            [0] = 1, -- not so close
            [1] = 2, -- close
        }, 	     	      
        ["s_fireMis"] = { -- shooter position and speed
            [0] = 2, -- detailed shooter position not known
            [1] = 0, -- detailed shooter position known
        },     
        ["o_cls"] = {
            ["MBT"] = 1,
            ["ATGM"] = 1,
            ["MLRS"] = 0,
            ["ARTY"] = 0,
            ["MISSILE"] = 0,
            ["MANPADS"] = 0,
            ["SHORAD"] = 0,
            ["AAA"] = 1,
            ["SAM"] = 0,
            ["SAML"]= 0,
            ["SAMC"]= 0,
            ["IFV"] = 1,
            ["APC"] = 1,
            ["RECCE"] = 0,
            ["LOGI"] = 0,
            ["INF"] = 0,
            ["UNKN"] = 0,
        },  
        ["s_cls"] = { 
            ["MBT"] = 0,
            ["ATGM"] = 0,
            ["MLRS"] = 2,
            ["ARTY"] = 2,
            ["MISSILE"] = 3,
            ["MANPADS"] = 3,
            ["SHORAD"] = 1.3,
            ["AAA"] = 2.2,
            ["SAM"] = 2.2,
            ["SAML"]= 1,
            ["SAMC"]= 1,
            ["IFV"] = 0.6,
            ["APC"] = 0.9,
            ["RECCE"] = 1.7,
            ["LOGI"] = 4,
            ["INF"] = 2.4,
            ["UNKN"] = 1,
            ["ARBN"] = 0,
        },          
    },    
    [7] 	= { -- ac_coverBuildings
        ["name"] = "ac_coverBuildings",
        ["ac_function"] = ac_coverBuildings,
        ["message"] = "We're moving nearby the closest urbanized area for concealment",
        ["resume"] = true,
        ["w_cat"] = { -- weapon category
            [0] = 2, -- shell
            [1] = 1.6, -- missile
            [2] = 1, -- rocket
            [3] = 1.2, -- bomb
        }, 				
        ["s_cat"] = { -- unit category
            [0] = 1.2, -- airplane
            [1] = 1.4, -- helicopter
            [2] = 1, -- ground unit
            [3] = 2, -- ship
            [4] = 0, -- structure
        }, 				
        ["s_indirect"] = { -- unit category
            [0] = 2, -- not an indirect fire unit
            [1] = 0.4, -- is an indirect fire unit
        }, 			
        ["s_close"] = { -- shooter is within wpn range
            [0] = 1, -- not so close
            [1] = 1, -- close
        }, 	     	      
        ["s_fireMis"] = { -- shooter position and speed
            [0] = 0.5, -- detailed shooter position not known
            [1] = 2, -- detailed shooter position known
        },     
        ["o_cls"] = { 
            ["MBT"] = 0,
            ["ATGM"] = 1,
            ["MLRS"] = 2,
            ["ARTY"] = 1,
            ["MISSILE"] = 0,
            ["MANPADS"] = 3,
            ["SHORAD"] = 3,
            ["AAA"] = 2,
            ["SAM"] = 0,
            ["SAML"]= 0,
            ["SAMC"]= 0,
            ["IFV"] = 2,
            ["APC"] = 3,
            ["RECCE"] = 3,
            ["LOGI"] = 3,
            ["INF"] = 3,
            ["UNKN"] = 3,
        },  
        ["s_cls"] = { 
            ["MBT"] = 1.3,
            ["ATGM"] = 1.8,
            ["MLRS"] = 2,
            ["ARTY"] = 2,
            ["MISSILE"] = 0.5,
            ["MANPADS"] = 0.1,
            ["SHORAD"] = 0.3,
            ["AAA"] = 0.2,
            ["SAM"] = 0.2,
            ["SAML"]= 0.1,
            ["SAMC"]= 0.1,
            ["IFV"] = 1.4,
            ["APC"] = 1,
            ["RECCE"] = 0.3,
            ["LOGI"] = 0.2,
            ["INF"] = 0.1,
            ["UNKN"] = 1,
            ["ARBN"] = 1.6,
        },         
    },
    [8] 	= { -- ac_groundSupport
        ["name"] = "ac_groundSupport",
        ["ac_function"] = ac_groundSupport,
        ["message"] = "We asked for ground support, they're on the way",
        ["resume"] = true,
        ["w_cat"] = { -- weapon category
            [0] = 0, -- shell
            [1] = 0.8, -- missile
            [2] = 0.5, -- rocket
            [3] = 0, -- bomb
        }, 				
        ["s_cat"] = { -- unit category
            [0] = 0, -- airplane
            [1] = 1, -- helicopter
            [2] = 4, -- ground unit
            [3] = 0, -- ship
            [4] = 2, -- structure
        }, 				
        ["s_indirect"] = { -- unit category
            [0] = 1, -- not an indirect fire unit
            [1] = 0.4, -- is an indirect fire unit
        }, 			
        ["s_close"] = { -- shooter is within wpn range
            [0] = 0, -- not so close
            [1] = 1.6, -- close
        }, 	     	      
        ["s_fireMis"] = { -- shooter position and speed
            [0] = 0.3, -- detailed shooter position not known
            [1] = 0, -- detailed shooter position known
        },     
        ["o_cls"] = { 
            ["MBT"] = 1,
            ["ATGM"] = 1,
            ["MLRS"] = 2,
            ["ARTY"] = 2,
            ["MISSILE"] = 3,
            ["MANPADS"] = 2,
            ["SHORAD"] = 2,
            ["AAA"] = 2,
            ["SAM"] = 2,
            ["SAML"]= 1,
            ["SAMC"]= 1,
            ["IFV"] = 1,
            ["APC"] = 2,
            ["RECCE"] = 1,
            ["LOGI"] = 2,
            ["INF"] = 3,
            ["UNKN"] = 1,
        }, 
        ["s_cls"] = { 
            ["MBT"] = 1.8,
            ["ATGM"] = 1.4,
            ["MLRS"] = 3,
            ["ARTY"] = 2.5,
            ["MISSILE"] = 3,
            ["MANPADS"] = 3,
            ["SHORAD"] = 1.3,
            ["AAA"] = 1,
            ["SAML"]= 0.5,
            ["SAMC"]= 0.5,
            ["SAM"] = 0.9,
            ["IFV"] = 2,
            ["APC"] = 2.2,
            ["RECCE"] = 1.7,
            ["LOGI"] = 1.1,
            ["INF"] = 0.4,
            ["UNKN"] = 1,
            ["ARBN"] = 1.2,
        },         
    },
    [9] 	= { -- ac_coverADS
        ["name"] = "ac_coverADS",
        ["ac_function"] = ac_coverADS,
        ["resume"] = false,
        ["message"] = "Attack comes from airborne asset, we are moving within the closest air defence covered area",
        ["w_cat"] = { -- weapon category
            [0] = 0, -- shell
            [1] = 2, -- missile
            [2] = 2, -- rocket
            [3] = 2, -- bomb
        }, 				
        ["s_cat"] = { -- unit category
            [0] = 2, -- airplane
            [1] = 2, -- helicopter
            [2] = 0, -- ground unit
            [3] = 0, -- ship
            [4] = 0, -- structure
        }, 				
        ["s_indirect"] = { -- unit category
            [0] = 0, -- not an indirect fire unit
            [1] = 2, -- is an indirect fire unit
        }, 			
        ["s_close"] = { -- shooter is within wpn range
            [0] = 1, -- not so close
            [1] = 0, -- close
        }, 	     	      
        ["s_fireMis"] = { -- shooter position and speed
            [0] = 0.5, -- detailed shooter position not known
            [1] = 0, -- detailed shooter position known
        },     
        ["o_cls"] = { 
            ["MBT"] = 1,
            ["ATGM"] = 2,
            ["MLRS"] = 0,
            ["ARTY"] = 0,
            ["MISSILE"] = 0,
            ["MANPADS"] = 0,
            ["SHORAD"] = 0,
            ["AAA"] = 2,
            ["SAM"] = 0,
            ["SAML"]= 0,
            ["SAMC"]= 0,
            ["IFV"] = 1,
            ["APC"] = 1,
            ["RECCE"] = 0,
            ["LOGI"] = 2,
            ["INF"] = 0,
            ["UNKN"] = 3,
        },  
        ["s_cls"] = { 
            ["MBT"] = 0,
            ["ATGM"] = 0,
            ["MLRS"] = 0,
            ["ARTY"] = 0,
            ["MISSILE"] = 0,
            ["MANPADS"] = 0,
            ["SHORAD"] = 0,
            ["AAA"] = 0,
            ["SAM"] = 0,
            ["SAML"]= 0,
            ["SAMC"]= 0,
            ["IFV"] = 0,
            ["APC"] = 0,
            ["RECCE"] = 0,
            ["LOGI"] = 0,
            ["INF"] = 0,
            ["UNKN"] = 0,
            ["ARBN"] = 2,
        },         
    },
    [10] 	= { -- ac_fireMissionOnShooter
        ["name"] = "ac_fireMissionOnShooter",
        ["ac_function"] = ac_fireMissionOnShooter,
        ["resume"] = true,
        ["message"] = "We got the enemy position and asked for indirect fire mission.",
        ["w_cat"] = { -- weapon category
            [0] = 3, -- shell
            [1] = 2, -- missile
            [2] = 3, -- rocket
            [3] = 2, -- bomb
        }, 				
        ["s_cat"] = { -- unit category
            [0] = 1, -- airplane
            [1] = 3, -- helicopter
            [2] = 2, -- ground unit
            [3] = 3, -- ship
            [4] = 2, -- structure
        }, 				
        ["s_indirect"] = { -- unit category
            [0] = 1, -- not an indirect fire unit
            [1] = 0, -- is an indirect fire unit
        }, 			
        ["s_close"] = { -- shooter is within wpn range
            [0] = 3, -- not so close
            [1] = 0, -- close
        }, 	     	      
        ["s_fireMis"] = { -- shooter position and speed
            [0] = 0, -- detailed shooter position not known
            [1] = 3, -- detailed shooter position known
        },     
        ["o_cls"] = { 
            ["MBT"] = 0,
            ["ATGM"] = 1,
            ["MLRS"] = 3,
            ["ARTY"] = 3,
            ["MISSILE"] = 1,
            ["MANPADS"] = 2,
            ["SHORAD"] = 1,
            ["AAA"] = 1,
            ["SAM"] = 1,
            ["SAML"]= 0.5,
            ["SAMC"]= 0.5,
            ["IFV"] = 1,
            ["APC"] = 1,
            ["RECCE"] = 1,
            ["LOGI"] = 1,
            ["INF"] = 1,
            ["UNKN"] = 2,
            ["ARBN"] = 1,
        },  
        ["s_cls"] = { 
            ["MBT"] = 1.8,
            ["ATGM"] = 1.4,
            ["MLRS"] = 3,
            ["ARTY"] = 2.5,
            ["MISSILE"] = 3,
            ["MANPADS"] = 3,
            ["SHORAD"] = 1.3,
            ["AAA"] = 1,
            ["SAML"]= 0.3,
            ["SAMC"]= 0.3,
            ["SAM"] = 0.9,
            ["IFV"] = 2,
            ["APC"] = 2.2,
            ["RECCE"] = 1.7,
            ["LOGI"] = 1.1,
            ["INF"] = 0.4,
            ["UNKN"] = 1,
            ["ARBN"] = 3,
        },          
    },
    -- revTODO interesting, does this mean that you planned the "call for air support" feature? -> Chromium: check this out -> yes, it will be added as a client request
    --[[
    [11] 	= {
        ["name"] = "ac_airSupport",
        ["ac_function"] = ac_airSupport,
        ["w_cat"] = { -- weapon category
            [0] = 2, -- shell
            [1] = 2, -- missile
            [2] = 2, -- rocket
            [3] = 2, -- bomb
        }, 				
        ["s_cat"] = { -- unit category
            [0] = 0, -- airplane
            [1] = 2, -- helicopter
            [2] = 4, -- ground unit
            [3] = 0, -- ship
            [4] = 3, -- structure
        }, 				
        ["s_indirect"] = { -- unit category
            [0] = 1, -- not an indirect fire unit
            [1] = 1, -- is an indirect fire unit
        }, 			
        ["s_close"] = { -- shooter is within wpn range
            [0] = 2, -- not so close
            [1] = 3, -- close
        }, 	     	      
        ["s_fireMis"] = { -- shooter position and speed
            [0] = 0, -- detailed shooter position not known
            [1] = 5, -- detailed shooter position known
        },     
        ["o_cls"] = { 
            ["MBT"] = 2,
            ["ATGM"] = 2,
            ["MLRS"] = 2,
            ["ARTY"] = 2,
            ["MISSILE"] = 2,
            ["MANPADS"] = 1,
            ["SHORAD"] = 2,
            ["AAA"] = 2,
            ["SAM"] = 2,
            ["IFV"] = 2,
            ["APC"] = 2,
            ["RECCE"] = 2,
            ["LOGI"] = 1,
            ["INF"] = 1,
            ["UNKN"] = 0,
        },  
        ["o_cls"] = { 
            ["MBT"] = 3,
            ["ATGM"] = 3,
            ["MLRS"] = 3,
            ["ARTY"] = 3,
            ["MISSILE"] = 3,
            ["MANPADS"] = 0.4,
            ["SHORAD"] = 0.2,
            ["AAA"] = 0.4,
            ["SAM"] = 0,
            ["IFV"] = 2.8,
            ["APC"] = 2,
            ["RECCE"] = 2,
            ["LOGI"] = 1,
            ["INF"] = 1,
            ["UNKN"] = 0,
            ["ARBN"] = 1.9,
        },          
    },
    --]]--
}

-- the functions that handles the reactions, using priorities
local function executeReactions(gr, ownPos, tgtPos, actTbl, saTbl, skill)
    if gr and gr:isExist() and ownPos and tgtPos and actTbl and skill then
        if actTbl and #actTbl>0 then
            for _, aData in ipairs(actTbl) do
                local f = aData.ac_function
                if f then
                    local success = f(gr, ownPos, tgtPos, aData.resume, saTbl, skill)
                    if AIEN.config.AIEN_debugProcessDetail == true then
                        env.info(("AIEN.executeReactions, action success = " .. tostring(success)))
                    end
                    if success and success == true then
                        if aData.resume == true then trigger.action.groupContinueMoving(gr) end
                        if AIEN.config.message_feed == true then
                            local threatTxt = nil
                            for _, s in pairs((saTbl and saTbl.targets) or {}) do
                                local cat = s.category or s.cat or s.objCat
                                if type(cat) == "number" then
                                    if cat == 0 then threatTxt = "enemy plane!" break end
                                    if cat == 1 then threatTxt = "enemy helicopter!" break end
                                    if cat == 2 then threatTxt = "enemy ground units!" break end
                                    if cat == 3 then threatTxt = "enemy ship!" break end
                                    if cat == 4 then threatTxt = "enemy structure!" break end
                                end
                            end
                            local z = bc:getZoneOfPoint(ownPos)
                            if z and z.zone then
                                local zoneName = z.zone
                                local txt = ""
                                if threatTxt then
                                    txt = txt .. "C2, " .. tostring(zoneName) .. " is under attack by " .. tostring(threatTxt) .. " " .. tostring(aData.message or "")
                                else
                                    txt = txt .. "C2, " .. tostring(zoneName) .. " is under attack! " .. tostring(aData.message or "")
                                end
                                local vars = {"text", txt, 30, nil, nil, nil, gr:getCoalition()}
                                multyTypeMessage(vars)
                            else
                                local lat, lon = coord.LOtoLL(ownPos)
                                local MGRS = coord.LLtoMGRS(coord.LOtoLL(ownPos))
                                if lat and lon then
                                    local LL_string = tostringLL(lat, lon, 0, true)
                                    local MGRS_string = tostringMGRS(MGRS ,4)
                                    local txt = ""
                                    txt = txt .. "C2, " .. tostring(gr:getName()) .. ", report under attack. Coordinates: " .. tostring(LL_string) .. ", " .. tostring(MGRS_string) .. "." .. tostring(aData.message or "")
                                    local vars = {"text", txt, 30, nil, nil, nil, gr:getCoalition()}
                                    multyTypeMessage(vars)
                                end
                            end
                        end
                        return aData.name
                    end
                end
            end
        else
            if AIEN.config.AIEN_debugProcessDetail == true then
                env.info(("AIEN.executeReactions, actTbl missing or void"))
            end
            return false
        end
    else
        if AIEN.config.AIEN_debugProcessDetail == true then
            env.info(("AIEN.executeReactions error, missing one or more variables:"))
            env.info(("AIEN.executeReactions error: " .. tostring(gr)))
            env.info(("AIEN.executeReactions error: " .. tostring(ownPos)))
            env.info(("AIEN.executeReactions error: " .. tostring(tgtPos)))
            env.info(("AIEN.executeReactions error: " .. tostring(actTbl)))
            env.info(("AIEN.executeReactions error: " .. tostring(saTbl)))
            env.info(("AIEN.executeReactions error: " .. tostring(skill)))
        end
        return false
    end
end


-- this 'global' test function let you test a specific reaction of your choice, using the group name and the reaction name to execute. 
-- for those action where the shooter is required for evaluation, the test function will look for the nearest target within 20 km.
-- if data are not gathered, it will print an advice 

function AIEN_testReactions(groupName, actionName)
    
    if groupName and type(groupName) == "string" and actionName and type(actionName) == "string" then
        --local gr = Group.getByName(groupName)

        -- get group info
        local gr 			= nil
        local saTbl 		= nil
        local ownPos 		= nil
        local skill 		= nil
		local coa 			= nil
        for _, gData in pairs(groundgroupsDb) do
            if groupName == gData.n then
				gr 		= gData.group
				saTbl 	= gData.sa
				ownPos	= gData.sa.pos
				skill	= gData.skill
				coa		= gData.coa
            end
        end

        -- get action info
		local actionFunc	= nil
		local actionResume	= nil
		local actionMess	= nil
        for _, aData in pairs(reactionsDb) do
            if actionName == aData.name then
				actionFunc = aData.ac_function
				actionResume = aData.resume
				actionMess	 = aData.message
            end
        end

		-- filter conditions
		if gr and saTbl and ownPos and skill and coa and actionFunc then

			-- get nearest enemy
			local tgtPos = nil
			local maxDist = 20000
			local _volume = {
				id = world.VolumeType.SPHERE,
				params = {
					point = ownPos,
					radius = 20000,
				},
			}

			local _search = function(_obj)
				pcall(function()
					if _obj ~= nil and Object.getCategory(_obj) == 1 and _obj:isExist() and _obj:getCoalition() ~= coa then
						local _objPos = _obj:getPoint()
						if _objPos then
							local d = getDist(_objPos, ownPos)
							if d and d < maxDist then
								maxDist = d
								tgtPos = _objPos
							end
						end
					end
				end)
			end
			world.searchObjects(Object.Category.UNIT, _volume, _search)		
			
			-- tgtPos might be unnecessary, therefore I don't check it.
			local success = actionFunc(gr, ownPos, tgtPos, actionResume, saTbl, skill)
			if AIEN.config.AIEN_debugProcessDetail == true then
                env.info(("AIEN.AIEN_testReactions, result " .. tostring(success)))
            end
			if success and success == true then
				-- message feedback
				if AIEN.config.message_feed == true then

					local lat, lon = coord.LOtoLL(ownPos)
					if lat and lon then

						local LL_string = tostringLL(lat, lon, 0, true)

						local txt = ""
						local txt = txt .. "C2, " .. tostring(gr:getName()) .. ", report under attack. Coordinates: " .. tostring(LL_string) .. "." .. tostring(actionMess)
						local vars = {"text", txt, 20, nil, nil, nil, gr:getCoalition()}

						multyTypeMessage(vars)

					end
				end

				return actionName
			end
			
		end
		return nil

    end
end


--###### MISSION TACTICAL ACTIONS ##################################################################

--[[ Tactical actions are tasks that are issued by C2, given intel and own forces informations, in real time, to reposition ground units at medium ranges (up to 15 km unless you change AIEN.config.tacticalRange) 
    While initiative is up to the single group with only it's own informations and targets detected, tactical actions are issued by C2 to reposition MBT, IFV, APC and ATGM groups in a more effective way, using the information available to the coalition

    While optimizable, the code structure basically works this way:
    1. For each non-tasked and not under attack group entry, it looks for intel contact within the tactical range, choosing the closest 5 of them. On each, it will evaluate them as units assemblies (not DCS groups) by proximity of 1 km each. For each assembly, it will consider units type total strenght.
    2. After evaluation, different solutions are considered if enemies are within 8 km range:
        - If an enemy units assemblies is significantly stronger than the group, it won't intervene or, if own group is arty, it will consider repositioning away from them (80% threat range or 15 km, the lesser).
        - If an enemy units assemblies is significantly weaker than the group or non-threatening type (i.e. arty, air defences), and the group is a mover, it will plan a route to attack them and exploit the weakness.
        - If an enemy units assemblies is similar in strength and the group is a mover or recce and the enemy is in arty range (but not suitable target), it will reposition to have a direct LOS on enemy.
        These actions are executed by the executeReactions function..
    
    3. if enemies are from 8 to 15 km away: 
        - If an enemy units assemblies is significantly weaker or similar strenght than the group or non-threatening type (i.e. arty, air defences), and the group is a mover, it will get closer up to 6 km.

    4. in any case where enemies are not attacked or engaged, C2 will open a task in the F10 menù for clients with relevant informations: target position, number & type, enemy known air defences within 50 km (bearing and range from tgt)

--]]--

-- QUIIIIIIIIIIII



--###### DB CONSTRUCTION & HANDLING ################################################################

--[[ DB structure
    each db element is added as this: [objectID] = {group = Group Object, class = Result of getGroupClass function, i = index in table}
    They're not array to speed up the object calls when needed, cause you can simply do a referencedDB[objectID] call w/o coding for table loop
    when a db is referred to a unit, to skip units loop in the group (i.e. droneunitDb), the "group" key is replaced by "unit"

    DBs are used mostly for FSM loops, that are needed to keep a low impact on the process (FSM 1st level will loop db's, while FSM 2nd level will loop each entry one every phaseCycleTimer timer (default 0.2 seconds)).
    Not all the DBs are used in loops, some are only event-related like the ones used for dismount options.

]]--

local function populate_Db() -- this one is launched once at mission start and collect everything relevant that is already there.

	-- only ground groups
	groundgroupsDb = {}
	for i = 0, 2 do
		for _, gp in pairs(coalition.getGroups(i,2)) do -- ground only
			if gp:isExist() then
                local c = getGroupClass(gp)
                local gpcoa = gp:getCoalition()
                -- classes reminder from getGroupClass:
                -- MBT
                -- ATGM
                -- IFV
                -- APC
                -- RECCE
                -- LOGI
                -- MLRS
                -- ARTY
                -- MISSILE
                -- MANPADS
                -- SHORAD
                -- AAA
                -- SAM
                -- INF
                -- UNKN
                
                local s = getGroupSkillNum(gp)
                --env.info((tostring(ModuleName) .. ", populate_Db: s " .. tostring(s)))
                local det, thr = getRanges(gp)
                if c then
                    --local r = getMEroute(gp)
                    groundgroupsDb[gp:getID()] = {group = gp, class = c, n = gp:getName(), coa = gpcoa, detection = det, threat = thr, tasked = false, skill = s, sa = {}}  --, route = r
                    --env.info((tostring(ModuleName) .. ", populate_Db: adding to groundgroupsDb " .. tostring(gp:getName() .. ", class " .. tostring(c) )))
                else
                    env.info((tostring(ModuleName) .. ", populate_Db: skipping group due to unable to identify class " .. tostring(gp:getName() )))
                end

                -- dismount dbs
                if AIEN.config.dismount == true then
                    if gp:getUnits() and #gp:getUnits() > 0 then
                        for _, un in pairs(gp:getUnits()) do
                            if un:hasAttribute("IFV") or un:hasAttribute("Trucks") then
                                -- define dismount capacity
                                local people = defineTroopsNumber(un)
                                infcarrierDb[un:getID()] = people

                                -- define pre-loaded groups!
                                local function loadTeam(unit)
                                    local refTbl = dismountTeamsWest
                                    if gpcoa == 1 then
                                        refTbl = dismountTeamsEast
                                    end


                                    local r = aie_random(1,100)
                                    --env.info((tostring(ModuleName) .. ", populate_Db: random for " .. tostring(unit:getName()) .. ": " .. tostring(r) ))
                                    local c = nil
                                    local i = nil
                                    local lim = 0
                                    for _, tData in pairs(refTbl) do
                                        if r > tData.p and tData.p > lim then
                                            c = tData.c
                                            i = tData.id
                                            lim = tData.p
                                            --env.info((tostring(ModuleName) .. ", populate_Db: found " .. tostring(i) ))
                                        end
                                    end

                                    if c then
                                        local curMount = mountedDb[unit:getID()] or {}
                                        --env.info((tostring(ModuleName) .. ", populate_Db: adding " .. tostring(i) .. " to " .. tostring(unit:getName()) ))
                                        curMount[#curMount+1] = c
                                        mountedDb[unit:getID()] = curMount
                                        
                                        local freePlace = infcarrierDb[un:getID()]
                                        freePlace = freePlace - #c
                                        infcarrierDb[un:getID()] = freePlace
                                    end
                                end

                                local loadings = math.floor(people/4)
                                for i = 1, loadings do
                                    if infcarrierDb[un:getID()] >=4 then
                                        loadTeam(un)
                                    end
                                end

                            end
                        end
                    end
                end
            

                -- set prevent disperse
                groupPreventDisperse(gp)
    
			end
		end
	end
	
	-- only drone units
	droneunitDb = {}	
	for i = 0, 2 do
		for _, gp in pairs(coalition.getGroups(i,0)) do -- airplane only
			if gp:isExist() then
                local c = nil
                if gp:getUnits() then
                    for _, un in pairs(gp:getUnits()) do
                        if un:hasAttribute("UAVs") then -- drone only
                            c = "UAV"
                        end
                    end
                end
                if c then
                    --env.info((tostring(ModuleName) .. ", populate_Db: adding to droneunitDb " .. tostring(gp:getName() )))
                    droneunitDb[gp:getID()] = {group = gp, class = c, n = gp:getName(), coa = gp:getCoalition(), sa = {},}
                end				
			end
		end
	end


    if AIEN.config.AIEN_debugProcessDetail and AIEN_io and AIEN_lfs then
        dumpTableAIEN("groundgroupsDb.lua", groundgroupsDb, "int")
        dumpTableAIEN("droneunitDb.lua", droneunitDb, "int")
        dumpTableAIEN("infcarrierDb.lua", infcarrierDb, "int")
        dumpTableAIEN("mountedDb.lua", mountedDb, "int")
    end
	
end


--###### FINITE STATE MACHINE LOOP #################################################################

--[[ FSM is the key element that allow this script to be as lightweight as possibile (for my low skills), cause basically make all the recurring functions to run each every "n" time instead of all-together at once every second. 
    There are 2 levels of FSM:
    - 1st level is the "bigger" one that is divided in phases: each phase update a DB table, plus a fourth one that handle the artillery groups fire missions.
    - 2nd level is the "group cycle", that handle each database entry update.

    Each time a 2nd level cycle is complete, the subsequent 1st level start and at the end it will simply re-start from the first. Check AIEN.performPhaseCycle() for 1st level cycle.

]]--

-- utils
local function createIterator(t)
    local keys = {}
    for key in pairs(t) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function getNextKey(keys, currentKey)
    for i, key in ipairs(keys) do
        if key == currentKey then
            return keys[i + 1]
        end
    end
    return nil
end

-- 2ND LEVEL CYCLE FUNCTIONS

local function update_GROUND()
    if PHASE == "A" then -- confirm correct PHASE of performPhaseCycle
        if groundgroupsDb and next(groundgroupsDb) ~= nil then -- check that table exist and that it's not void
            if not phase_index then -- escape condition from the 2nd loop!
                AIEN.changePhase()
                timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
                -- debug steps
                if AIEN.config.AIEN_debugProcessDetail and AIEN_io and AIEN_lfs then
                    dumpTableAIEN("groundgroupsDb.lua", groundgroupsDb, "int")
                end
                if AIEN.config.AIEN_debugProcessDetail then
                    env.info((tostring(ModuleName) .. ", update_GROUND: phase A completed"))
                end
            else
                local gData = groundgroupsDb[phase_index]
                if not gData or not groupAllowedForAI(gData.group) then
                    phase_index = getNextKey(phase_keys, phase_index)
                    timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
                    return
                end
                local remove = false
                if gData.group then
                    if gData.group and gData.group:isExist() == true and gData.group:getUnits() then
                        -- filter under attack, SA already gained and need to focus on reactions
                        if not underAttack[phase_index] then
                            -- update/create sa
                            gData.sa = getSA(gData.group)
                            -- check tasked
                            if gData.tasked == true and gData.taskTime then
                                local _t=AIEN.config.taskTimeout;if gData.class=="ARTY" or gData.class=="MLRS" then _t=AIEN.config.artyTaskTimeout end;if timer.getTime()-gData.taskTime>=_t then
                                    if AIEN.config.AIEN_debugProcessDetail then
                                        env.info((tostring(ModuleName) .. ", update_GROUND, group name " .. tostring(gData.n) .. " is still tasked. Removing it"))
                                    end
                                    gData.tasked = false
                                    gData.taskTime = nil
                                end
                            end
                        else
                            local t = timer.getTime() - underAttack[phase_index]
                            if t > AIEN.config.taskTimeout*2 then
                                underAttack[phase_index] = nil
                                if AIEN.config.AIEN_debugProcessDetail then
                                    env.info((tostring(ModuleName) .. ", update_GROUND, group name " .. tostring(gData.n) .. " removed from the under attack table"))
                                end
                            else
                                if AIEN.config.AIEN_debugProcessDetail then
                                    env.info((tostring(ModuleName) .. ", update_GROUND, group name " .. tostring(gData.n) .. " is still under attack"))
                                end
                            end
                        end
                    else
                        if AIEN.config.AIEN_debugProcessDetail then
                            env.info((tostring(ModuleName) .. ", update_GROUND, group name " .. tostring(gData.n) .. " other variables does not exist, remove true"))
                        end
                        remove = true
                    end
                else
                    if AIEN.config.AIEN_debugProcessDetail then
                        env.info((tostring(ModuleName) .. ", update_GROUND, group name " .. tostring(gData.n) .. " gData.group does not exist, remove true"))
                    end
                    remove = true
                end
                if remove == true then
                    if AIEN.config.AIEN_debugProcessDetail then
                        env.info((tostring(ModuleName) .. ", update_GROUND, group name " .. tostring(gData.n) .. " missing. Removing it"))
                    end
                    groundgroupsDb[phase_index] = nil
                    phase_keys = createIterator(groundgroupsDb)
                end
                phase_index = getNextKey(phase_keys, phase_index)
                timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
            end
        else
            PHASE = "Initialization"
            if AIEN.config.AIEN_debugProcessDetail then
                env.info((tostring(ModuleName) .. ", update_GROUND, reinizializzazione dei DB, poiché groundgroupsDb sembra vuoto o inesistente!"))
            end
            timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
        end
    end
end
-- ISR update, PHASE "B"
local function update_ISR() -- basically clean old ISR data
    if PHASE == "B" then -- confirm correct PHASE of performPhaseCycle
        if intelDb and next(intelDb) ~= nil then -- check that table exist and that it's not void
            if not phase_index then -- escape condition from the 2nd loop!
                AIEN.changePhase()
                timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
                -- debug steps
                if AIEN.config.AIEN_debugProcessDetail and AIEN_io and AIEN_lfs then
                    dumpTableAIEN("intelDb.lua", intelDb, "int")
                end
                if AIEN.config.AIEN_debugProcessDetail then
                    env.info((tostring(ModuleName) .. ", update_ISR: fase B completed"))
                end

            else
                local tData = intelDb[phase_index]
                if tData then
                    --local remove = false
                    if not tData.obj or tData.obj:isExist() == false then
                        if AIEN.config.AIEN_debugProcessDetail then
                            env.info((tostring(ModuleName) .. ", update_ISR, target id " .. tostring(phase_index) .. " missing. Removing it"))
                        end
                        intelDb[phase_index] = nil
                        phase_keys = createIterator(intelDb) 
                    else
                        if tData.targeted then
                            if type(tData.targeted) == "number" then
                                local ttl = AIEN.config.targetedTimeout             -- default
                                    if tData.targeted_by == "ARTY" then                 -- see note below
                                    ttl = AIEN.config.artyTargetedTimeout           -- shorter for arty
                                    end

                                    if timer.getTime() - tData.targeted >= ttl then
                                    if AIEN.config.AIEN_debugProcessDetail then
                                        env.info((tostring(ModuleName) .. ", update_ISR, target id " .. tostring(phase_index) .. " is still targeted. Removing it"))
                                    end
                                    intelDb[phase_index].targeted = nil
                                end
                            end
                        end
                    end
                end
                phase_index = getNextKey(phase_keys, phase_index)
                timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
            end
        else
            AIEN.changePhase()
            timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
            -- debug steps
            if AIEN.config.AIEN_debugProcessDetail and AIEN_io and AIEN_lfs then
                dumpTableAIEN("intelDb.lua", intelDb, "int")
            end
            if AIEN.config.AIEN_debugProcessDetail then
                env.info((tostring(ModuleName) .. ", update_ISR: fase B skipped"))
            end            
        end
    end
end
-- DRONE update, PHASE "C" 
local function update_DRONE()
    if PHASE == "C" then -- confirm correct PHASE of performPhaseCycle
        if droneunitDb and next(droneunitDb) ~= nil then -- check that table exist and that it's not void
            if not phase_index then -- escape condition from the 2nd loop!
                AIEN.changePhase()
                timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
                -- debug steps
                if AIEN.config.AIEN_debugProcessDetail and AIEN_io and AIEN_lfs then
                    dumpTableAIEN("droneunitDb.lua", droneunitDb, "int")
                end
                if AIEN.config.AIEN_debugProcessDetail then
                    env.info((tostring(ModuleName) .. ", update_DRONE: fase B complete"))
                end
            else
                local dData = droneunitDb[phase_index]
                if not dData or not groupAllowedForAI(dData.group) then
                    phase_index = getNextKey(phase_keys, phase_index)
                    timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
                    return
                end
                local remove = false
                if dData.group then
                    if dData.group and dData.group:isExist() == true then
                        -- update/create sa
                        if AIEN.config.AIEN_debugProcessDetail then
                            env.info((tostring(ModuleName) .. ", update_DRONE, add SA " .. tostring(dData.n)))
                        end
                        dData.sa = getSA(dData.group)
                    else
                        remove = true
                    end
                else
                    remove = true
                end
                if remove == true then
                    if AIEN.config.AIEN_debugProcessDetail then
                        env.info((tostring(ModuleName) .. ", update_DRONE, group name " .. tostring(dData.n) .. " missing. Removing it"))
                    end
                    droneunitDb[phase_index] = nil
                    phase_keys = createIterator(droneunitDb)
                end
                phase_index = getNextKey(phase_keys, phase_index)
                timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
            end
        else
            if AIEN.config.AIEN_debugProcessDetail then
                env.info((tostring(ModuleName) .. ", update_DRONE, no drone available!"))
            end
            AIEN.changePhase()
            timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
            if AIEN.config.AIEN_debugProcessDetail then
                env.info((tostring(ModuleName) .. ", update_DRONE: fase B completata"))
            end
        end
    end
end

-- ARTY update, PHASE "D"
local function update_ARTY()
    if PHASE == "D" then -- confirm correct PHASE of performPhaseCycle
        if groundgroupsDb and next(groundgroupsDb) ~= nil then -- check that table exist and that it's not void
            if not phase_index or AIEN.config.firemissions == false then -- escape condition from the 2nd loop!
                AIEN.changePhase()
                timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
                if AIEN.config.AIEN_debugProcessDetail then
                    env.info((tostring(ModuleName) .. ", update_ARTY: phase D completed or skipped"))
                end
            else
                if not underAttack[phase_index] then
                    local gData = groundgroupsDb[phase_index]
                    if not gData or not groupAllowedForAI(gData.group) then
                        phase_index = getNextKey(phase_keys, phase_index)
                        timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
                        return
                    end

                    local AI_consent = true
                    if gData.coa == 2 and AIEN.config.blueAI == false then
                        AI_consent = false
                    end
                    if gData.coa == 1 and AIEN.config.redAI == false then
                        AI_consent = false
                    end
                    local remove = false

                    if AI_consent == true then
                         if gData.tasked and gData.n:find("^CTLD_") then
                            local timeout = AIEN.config.artyTaskTimeout or 0
                            if timeout > 0 then
                                local age = timer.getTime() - (gData.taskTime or 0)
                                if age >= timeout then
                                    gData.tasked = false
                                    if AIEN.config.AIEN_debugProcessDetail then
                                        env.info("ARTY_RESET "..gData.n)
                                    end
                                end
                            end
                        end
                        if gData.tasked == false and (gData.class == "MLRS" or gData.class == "ARTY") then
                            if AIEN.config.AIEN_debugProcessDetail then
                                env.info("ARTY_ELIG "..gData.n.." cls="..gData.class.." thr="..tostring(gData.threat))
                            end
                            if gData.group and gData.group:isExist() == true and gData.threat and gData.sa and gData.sa.pos then
                                -- check ammo
                                local ammoAvail = 0
                                for _, uData in pairs(gData.group:getUnits()) do
                                    local ammoTbl = uData:getAmmo()
                                    if ammoTbl then
                                        for aId, aData in pairs(ammoTbl) do
                                            if aId == 1 then
                                                ammoAvail = ammoAvail + aData.count
                                            end
                                        end
                                    end
                                end
                                local roundsToFire = ammoAvail > 30 and 30 or ammoAvail

                                if roundsToFire > 0 then
                                    -- check targets
                                    local firePoint = nil
                                    local targetId  = nil
                                    local bestReport = nil
                                    local _volume = {
                                        id = world.VolumeType.SPHERE,
                                        params = {
                                            point = gData.sa.pos,
                                            radius = gData.threat*0.85,
                                        },
                                    }

                                        local curPri = 0
                                        local _search = function(_obj)
                                            pcall(function()
                                            if _obj ~= nil and Object.getCategory(_obj) == 1 and _obj:isExist() and _obj:getCoalition() ~= gData.coa then
                                                    if getDist(gData.sa.pos, _obj:getPoint()) > gData.threat * 0.85 then return end
                                                    local _obj_id = _obj:getID()
                                                    local report = intelDb[_obj_id]
                                                    -- if report then
                                                    --     env.info("DBG CLS = "..tostring(report.cls).." for ".._obj:getName())
                                                    -- end
                                                    local zTgt   = bc:getZoneOfPoint(_obj:getPoint())
                                                    local jtacOK = false
                                                    if report and (report.cls == "ARTY" or report.cls == "SAM") then
                                                    jtacOK = true
                                                else
                                                    if zTgt and jtacQueue then
                                                        for _,d in ipairs(jtacQueue) do
                                                            if d.tgtzone and d.tgtzone.zone == zTgt.zone then
                                                                jtacOK = true
                                                                break
                                                            end
                                                        end
                                                    end
                                                end
                                                if not jtacOK then return end
                                                if report and report.speed < 1 and report.targeted == nil then
                                                    local lastContact = timer.getTime() - report.record
                                                    if lastContact < AIEN.config.artyFireLastContactThereshold then
                                                        local timeFactor = (AIEN.config.artyFireLastContactThereshold-lastContact)/AIEN.config.artyFireLastContactThereshold
                                                        local pri = (classPriority[report.cls] or 0.5) * timeFactor
                                                        if pri > curPri then
                                                            if getDangerClose(report.pos, gData.coa) == false then
                                                                curPri   = pri
                                                                firePoint = report.pos
                                                                targetId  = report.cls
                                                                bestReport = report
                                                            elseif AIEN.config.AIEN_debugProcessDetail then
                                                                env.info((tostring(ModuleName) .. ", update_ARTY, target skipped for danger close"))
                                                            end
                                                        end
                                                    end
                                                    if AIEN.config.AIEN_debugProcessDetail then
                                                        env.info("ARTY_SCAN "..gData.n.." sees ".._obj:getName()..
                                                        " cls="..tostring((rep and rep.cls) or "nil")..
                                                        " pri="..string.format("%.2f",curPri))
                                                    end
                                                end
                                            end
                                        end)
                                    end
                                    world.searchObjects(Object.Category.UNIT, _volume, _search)
                                    if bestReport then
                                        bestReport.targeted = timer.getTime()
                                    end
                                    -- issuing mission
                                    if firePoint then
                                        if AIEN.config.AIEN_debugProcessDetail then
                                            env.info((tostring(ModuleName) .. ", update_ARTY, suitable target found for : " .. tostring(gData.n) .. ": " .. tostring(targetId) .. ", will fire " .. tostring(roundsToFire) .. " rounds"))
                                        end
                                        gData.tasked   = true
                                        gData.taskTime = timer.getTime()
                                        local description = targetId and ("Target is " .. targetId) or nil
                                        local isSAM = (targetId == "SAM" or targetId == "MANPADS" or targetId == "AAA")
                                        local qty    = isSAM and 10 or roundsToFire
                                        local radius = isSAM and 5  or nil
                                        groupfireAtPoint({gData.group, firePoint, qty, description, radius})
                                    end
                                end
                            end
                        end
                    end
                end
                phase_index = getNextKey(phase_keys, phase_index)
                timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
            end
        else
            PHASE = "Initialization"
            if AIEN.config.AIEN_debugProcessDetail then
                env.info((tostring(ModuleName) .. ", update_ARTY, reinizializzazione dei DB, poiché groundgroupsDb sembra vuoto o inesistente!"))
            end
            timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
        end
    end
end

-- INITIATIVE update, PHASE "E"
local function update_TACTICAL()
    if PHASE == "E" then -- confirm correct PHASE of performPhaseCycle
        AIEN.changePhase()
        timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
        if AIEN.config.AIEN_debugProcessDetail then
            env.info((tostring(ModuleName) .. ", update_INITIATIVE: phase E completed or skipped. movingGroups: " .. tostring(movingGroups) .. ", max allowed: " .. tostring(AIEN.config.maxGroupInMovement)))
        end       
    end
end

-- INITIATIVE update, PHASE "F"
local function update_INITIATIVE()
    if PHASE == "F" then -- confirm correct PHASE of performPhaseCycle
        if groundgroupsDb and next(groundgroupsDb) ~= nil then -- check that table exist and that it's not void
            if not phase_index or AIEN.config.initiative == false or movingGroups >= AIEN.config.maxGroupInMovement then -- escape condition from the 2nd loop!
                if AIEN.config.AIEN_debugProcessDetail then
                    env.info((tostring(ModuleName) .. ", update_INITIATIVE: phase F completed or skipped. movingGroups: " .. tostring(movingGroups) .. ", max allowed: " .. tostring(AIEN.config.maxGroupInMovement)))
                end                
                AIEN.changePhase()
                timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
            else
                if not underAttack[phase_index] then -- skip if group is under attack
                    local gData = groundgroupsDb[phase_index]
                    if gData then

                        local otherCoa = nil
                        local AI_consent = true
                        if gData.coa == 2 and AIEN.config.blueAI == false then
                            AI_consent = false
                            otherCoa = 1
                        end
                        if gData.coa == 1 and AIEN.config.redAI == false then
                            AI_consent = false
                            otherCoa = 2
                        end                
                        local remove = false
                        
                        if AI_consent == true and groupAllowedForAI(gData.group) == true then -- both coalition AI should be on and group exclusion tag shouldn't be there
                            if gData.group then
                                if gData.group and gData.group:isExist() == true then
                                    if gData.sa and gData.sa.pos then
                                        if gData.tasked == false then
                                            if gData.class == "MBT" or gData.class == "ATGM" or gData.class == "IFV" or gData.class == "APC" or gData.class == "RECCE" then -- find another way for indirect fire groups?
                                                --if AIEN.config.AIEN_debugProcessDetail then
                                                --    env.info((tostring(ModuleName) .. ", update_INITIATIVE: group " .. tostring(gData.n) .. " is in contact with enemy, evaluating direct threat"))
                                                --end  

                                                if gData.sa and gData.sa.str > 3 then
                                                    if gData.sa.targets and gData.sa.targets ~= {} then

                                                        if gData.n == "Blue_MBT_2" then
                                                            dumpTableAIEN("Blue_MBT_2_targets.lua", gData.sa.targets, "int")
                                                        end

                                                        local nearestDist = AIEN.config.initiativeRange or 10000 -- default value
                                                        local nearest       = nil -- data of the group in groundgroupsDb, not the object

                                                        for tId, tData in pairs(gData.sa.targets) do

                                                            if AIEN.config.AIEN_debugProcessDetail then
                                                                env.info((tostring(ModuleName) .. ", update_INITIATIVE: group " .. tostring(gData.n) .. "  check target: " .. tostring(tData.object:getName())))
                                                            end  

                                                            if tData.object and tData.object:isExist() == true then
                                                                local g = tData.object:getGroup()
                                                                local g_id = g:getID()
                                                                local e = groundgroupsDb[g_id]

                                                                if e and e.sa and e.sa.pos then
                                                                    local d = getDist(gData.sa.pos, e.sa.pos, true)
                                                                    if AIEN.config.AIEN_debugProcessDetail then
                                                                        env.info((tostring(ModuleName) .. ", update_INITIATIVE: tgt distance " .. tostring(d) .. " meters"))
                                                                    end                                                                      

                                                                    local d = getDist(gData.sa.pos, e.sa.pos)
                                                                    if d < nearestDist then
                                                                        nearest         = e
                                                                        nearestDist     = d
                                                                        if AIEN.config.AIEN_debugProcessDetail then
                                                                            env.info((tostring(ModuleName) .. ", update_INITIATIVE: defined as nearest"))
                                                                        end                                                                             
                                                                    end
                                                                end
                                                            end
                                                        end

                                                        if nearest then
                                                            local en_str = nearest.sa.str or 5 -- default value
                                                            local ow_str = gData.sa.str
                                                            
                                                            if AIEN.config.AIEN_debugProcessDetail then
                                                                env.info((tostring(ModuleName) .. ", update_INITIATIVE: group " .. tostring(gData.n) .. ":  nearest enemy group " ..  tostring(nearest.n) .. " strength: " .. tostring(en_str) .. ", own strength: " .. tostring(ow_str)))
                                                            end

                                                            if ow_str > en_str then
                                                                local vec3 = pointBetween(gData.sa.pos, nearest.sa.pos, 5000)
                                                                if AIEN.config.AIEN_debugProcessDetail then
                                                                    env.info((tostring(ModuleName) .. ", update_INITIATIVE: group " .. tostring(gData.n) .. "  found suitable destination for movement"))
                                                                end         
                                                                
                                                                -- message feedback
                                                                if AIEN.config.message_feed == true then

                                                                    local lat, lon = coord.LOtoLL(vec3)
                                                                    local MGRS = coord.LLtoMGRS(coord.LOtoLL(vec3))
                                                                    if lat and lon then

                                                                        local LL_string = tostringLL(lat, lon, 0, true)
                                                                        local MGRS_string = tostringMGRS(MGRS ,4)

                                                                        local txt = ""
                                                                        txt = txt .. tostring(gData.n) .. ", C2, " .. ", we're moving to engage hasty targets, coordinates:"
                                                                        txt = txt .. "\n" .. tostring(MGRS_string) .. "\n" .. tostring(LL_string)
                                                                        txt = txt .. "\n" .. "target is " .. tostring(nearest.class)
                                                                        
                                                                        local vars = {"text", txt, 20, nil, nil, nil, gData.coa}

                                                                        multyTypeMessage(vars)

                                                                    end
                                                                end

                                                                gData.tasked = true
                                                                gData.taskTime = timer.getTime()
                                                                moveToPoint(gData.group, vec3, 300, 100, false, "cone", true, false, false, nil)
                                                            else
                                                                if AIEN.config.AIEN_debugProcessDetail then
                                                                    env.info((tostring(ModuleName) .. ", update_INITIATIVE: group " .. tostring(gData.n) .. " is weaker than the nearest enemy, skip initiative"))
                                                                end                                                            

                                                            end
                                                        else
                                                            --if AIEN.config.AIEN_debugProcessDetail then
                                                                --env.info((tostring(ModuleName) .. ", update_INITIATIVE: group " .. tostring(gData.n) .. " no suitable enemy within " .. tostring(AIEN.config.initiativeRange/1000) .. " km, skip initiative"))
                                                            --end                                                      
                                                        end
                                                    else
                                                        if AIEN.config.AIEN_debugProcessDetail then
                                                            env.info((tostring(ModuleName) .. ", update_INITIATIVE: group " .. tostring(gData.n) .. " no targets identified in targets table, skip initiative"))
                                                        end                                                      
                                                    end
                                                else
                                                    if AIEN.config.AIEN_debugProcessDetail then
                                                        env.info((tostring(ModuleName) .. ", update_INITIATIVE: group " .. tostring(gData.n) .. " gData sa not available or strenght not available, skip initiative"))
                                                    end  
                                                end
                                            end
                                        else
                                            if AIEN.config.AIEN_debugProcessDetail then
                                                env.info((tostring(ModuleName) .. ", update_INITIATIVE: group " .. tostring(gData.n) .. " is already tasked, skip initiative"))
                                            end  
                                        end                                            
                                    else
                                        if AIEN.config.AIEN_debugProcessDetail then
                                            env.info((tostring(ModuleName) .. ", update_INITIATIVE: group " .. tostring(gData.n) .. " SA not available"))
                                        end                                        
                                    end
                                else
                                    if AIEN.config.AIEN_debugProcessDetail then
                                        env.info((tostring(ModuleName) .. ", update_INITIATIVE: group " .. tostring(gData.n) .. " not available"))
                                    end
                                end
                            end
                        end
                    end
                else
                    if AIEN.config.AIEN_debugProcessDetail then
                        env.info((tostring(ModuleName) .. ", update_INITIATIVE: group is under attack, skip initiative"))
                    end                      
                end
                phase_index = getNextKey(phase_keys, phase_index)
                timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
            end
        else
            PHASE = "Initialization"
            if AIEN.config.AIEN_debugProcessDetail then
                env.info((tostring(ModuleName) .. ", update_ARTY, reinizializzazione dei DB, poiché groundgroupsDb sembra vuoto o inesistente!"))
            end
            timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)
        end
    end
end

-- 1ST LEVEL CYCLE FUNCTIONS

function AIEN.changePhase()
    if PHASE == "Initialization" then -- udpate terrain data
        PHASE = "A"
        if AIEN.config.AIEN_debugProcessDetail then
            env.info((tostring(ModuleName) .. ", AIEN.changePhase, new PHASE: " .. tostring(PHASE)))
        end    

    elseif PHASE == "A" then -- udpate terrain data
        PHASE = "B"
        phase_keys = nil
        phase_keys = createIterator(intelDb) -- focus phase_keys on intelDb
        phase_index = phase_keys[1]
        if AIEN.config.AIEN_debugProcessDetail then
            env.info((tostring(ModuleName) .. ", AIEN.changePhase, new PHASE: " .. tostring(PHASE)))
        end

    elseif PHASE == "B" then
        PHASE = "C"
        phase_keys = nil
        phase_keys = createIterator(droneunitDb) -- focus phase_keys on droneunitDb
        phase_index = phase_keys[1]
        if AIEN.config.AIEN_debugProcessDetail then
            env.info((tostring(ModuleName) .. ", AIEN.changePhase, new PHASE: " .. tostring(PHASE)))
        end

    elseif PHASE == "C" then
        PHASE = "D"
        phase_keys = nil
        phase_keys = createIterator(groundgroupsDb) -- focus phase_keys on groundgroupsDb
        phase_index = phase_keys[1]
        if AIEN.config.AIEN_debugProcessDetail then
            env.info((tostring(ModuleName) .. ", AIEN.changePhase, new PHASE: " .. tostring(PHASE)))
        end
        
    elseif PHASE == "D" then
        PHASE = "E"
        phase_keys = nil
        phase_keys = createIterator(groundgroupsDb) -- focus phase_keys on groundgroupsDb -- QUESTO?!?!?!?!
        phase_index = phase_keys[1]
        if AIEN.config.AIEN_debugProcessDetail then
            env.info((tostring(ModuleName) .. ", AIEN.changePhase, new PHASE: " .. tostring(PHASE)))
        end          

    elseif PHASE == "E" then
        PHASE = "F"
        phase_keys = nil
        phase_keys = createIterator(groundgroupsDb) -- focus phase_keys on groundgroupsDb
        phase_index = phase_keys[1]
        if AIEN.config.AIEN_debugProcessDetail then
            env.info((tostring(ModuleName) .. ", AIEN.changePhase, new PHASE: " .. tostring(PHASE)))
        end           
    
    elseif PHASE == "F" then
        PHASE = "Z" -- LAST STEP
        AIEN.changePhase()

    elseif PHASE == "Z" then

        if AIEN.config.AIEN_debugProcessDetail then
            env.info((tostring(ModuleName) .. ", AIEN.changePhase: movingGroups reset. Value was: " .. tostring(movingGroups) .. ", max allowed: " .. tostring(AIEN.config.maxGroupInMovement)))
        end        
        movingGroups = 0 -- reset movingGroups counter        

        PHASE = "A"
        phase_keys = nil
        phase_keys = createIterator(groundgroupsDb) -- focus phase_keys on groundgroupsDb
        phase_index = phase_keys[1]
        if AIEN.config.AIEN_debugProcessDetail then
            env.info((tostring(ModuleName) .. ", AIEN.changePhase, new PHASE: " .. tostring(PHASE)))
        end


    end
end

function AIEN.performPhaseCycle()

    if PHASE == "Initialization" then
        populate_Db()
        phase_keys = nil
        phase_keys = createIterator(groundgroupsDb) -- focus phase_keys on groundgroupsDb
        phase_index = phase_keys[1]        
        AIEN.changePhase()
        timer.scheduleFunction(AIEN.performPhaseCycle, {}, timer.getTime() + phaseCycleTimer)

    elseif PHASE == "A" then
        update_GROUND()

    elseif PHASE == "B" then
        update_ISR()

    elseif PHASE == "C" then
        update_DRONE()

    elseif PHASE == "D" then
        update_ARTY()

    elseif PHASE == "E" then
        update_TACTICAL()      

    elseif PHASE == "F" then
        update_INITIATIVE()   

    end
end

--###### EVENT HANDLER FUNCTIONS ###################################################################

-- I believe this is self explanatory. Still, the event_hit function holds a lot on reactions and decision making. I'm sorry if it appear confuse, but currently it fits my condition XD.

    local function event_hit(unit, shooter, weapon) -- this functions run eacht time a unit gets an hit. Unit only, no statics. That's basically the core for reactions
        if not unit and not shooter then
            env.info("AIEN.event_hit: both unit and shooter nil")
            return
        end
        if AIEN.config.reactions == true then
    
            local ugrp = nil
            local unitCat = nil
            
            if unit then
                local ok, g = pcall(Unit.getGroup, unit)
                if ok and g and g:isExist() then
                    ugrp = g
                    --env.info("AIEN.event_hit: group from unit -> "..g:getName())
                end
            end
            
            if ugrp then
                local ok, c = pcall(Object.getCategory, unit)
                if ok and c then
                    --env.info("AIEN.event_hit: category from unit -> "..tostring(c))
                    unitCat = c
                end
            end
    
            if not unitCat then
                return
            end
    
            local shooterCat = pcallGetCategory(shooter)
            if unitCat == 1 and shooterCat == 1 then
    
                local vehicle       = unit:hasAttribute("Vehicles")
                local infantry      = unit:hasAttribute("Infantry")
                local armoured      = unit:hasAttribute("Armored vehicles")
                local position      = unit:getPoint()
    
                local ground_unit   = nil
                if vehicle == true then --  or infantry == true
                    ground_unit = true
                end
    
                if ground_unit then
                    local group     = unit:getGroup()
                
                    if group and group:isExist() and groupAllowedForAI(group) == true then -- filtering both for existance and for exclusion tag being not there
                        
                        local AI_consent = true
    
                        -- filter for coalition
                        if group:getCoalition() == 2 and AIEN.config.blueAI == false then
                            AI_consent = false
                        end
                        if group:getCoalition() == 1 and AIEN.config.redAI == false then
                            AI_consent = false
                        end  
    
                        if AIEN.config.AIEN_debugProcessDetail == true then
                            env.info(("AIEN.event_hit, S_EVENT_HIT, coalition check return AI_consent " .. tostring(AI_consent) ))
                        end	
    
                        if AI_consent == true then
                            if AIEN.config.AIEN_zoneFilter and AIEN.config.AIEN_zoneFilter ~= "" then
                                AI_consent = groupInZone(group)
                                if AIEN.config.AIEN_debugProcessDetail == true then
                                    env.info(("AIEN.event_hit, S_EVENT_HIT, group zone check return AI_consent " .. tostring(AI_consent) ))
                                end	
                            end
                        end
                        
                        if AI_consent == true then
    
                            trigger.action.groupStopMoving(group)
    
                            -- suppression part
                            if AIEN.config.suppression == true and armoured then
                                local suppressEffects = false
                                if shooter:hasAttribute("Air") or shooter:hasAttribute("Ships") or shooter:hasAttribute("Indirect fire") then
                                    suppressEffects = true
                                end
                                if suppressEffects == true then
                                    if AIEN.config.AIEN_debugProcessDetail == true then
                                        env.info(("AIEN.event_hit, S_EVENT_HIT, group is suppressed: " .. tostring(group:getName()) ))
                                    end		
                                    groupSuppress(group)
                                end
                            end
    
                            -- dismount part
                            if AIEN.config.dismount == true then
                                if not underAttack[group:getID()] then
                                    if shooter:hasAttribute("Air") then
                                        timer.scheduleFunction(groupDeployManpad, group, timer.getTime() + aie_random(8, 15))
                                        if AIEN.config.AIEN_debugProcessDetail == true then
                                            env.info(("AIEN.event_hit, S_EVENT_HIT, shooter is airborne, manpad dismount happens"))
                                        end	 
                                    elseif shooter:hasAttribute("Ground Units") then
                                        local d = AIEN.config.infantrySearchDist
                                        local dist = getDist(shooter:getPoint(), position)
                                        if dist < d then
                                            timer.scheduleFunction(groupDeployTroop, group, timer.getTime() + aie_random(8, 15))
                                            if AIEN.config.AIEN_debugProcessDetail == true then
                                                env.info(("AIEN.event_hit, S_EVENT_HIT, distance is close, infantry dismount happens"))
                                            end	    
                                        end                            
                                    end
                                end
                            end
    
                            -- reaction part
                            local choosenAct = nil
                            if not underAttack[group:getID()] then -- if a group has already been identified as "attacked", it won't repeat all the whole process every time or it could became a freaking mess in case of multiple hits
                                
                                if AIEN.config.AIEN_debugProcessDetail == true then
                                    env.info(("AIEN.event_hit, S_EVENT_HIT, group " .. tostring(group:getName()) ))
                                end					
    
                                -- retrieve SA & Controller
                                local con = group:getController()
                                local db_group = groundgroupsDb[group:getID()]
                                if con and db_group and db_group.sa then
    
                                    -- define if the attacker is known and and with what details
                                    local s_detected, s_visible, s_lastTime, s_type, s_distance, s_lastPos, s_lastVel, s_cat, w_cat, o_cat, s_indirect, s_close, s_fireMis, a_pos, o_cls, s_cls, o_pos
                                    w_cat       = 0
                                    s_cat       = nil
                                    s_indirect  = 0
                                    s_close     = 0
                                    s_fireMis   = 0
                                    o_cls       = db_group.sa.cls
                                    s_cls       = "UNKN"
                                    o_pos       = unit:getPoint()
                                    
                                    -- define weapon info, used to identify arty attack
                                    if weapon and weapon:isExist() then
                                        w_cat = weapon:getDesc().category
                                        --[[-- 
                                            Weapon.Category
                                            SHELL     0
                                            MISSILE   1
                                            ROCKET    2
                                            BOMB      3
                                        --]]--
                                        if AIEN.config.AIEN_debugProcessDetail == true then
                                            env.info(("AIEN.event_hit, S_EVENT_HIT, group " .. tostring(group:getName()) .. ", w_cat: " .. tostring(w_cat) ))
                                        end								
                                    end
    
                                    if shooter and con then
                                        if AIEN.config.AIEN_debugProcessDetail == true then
                                            env.info(("AIEN.event_hit, S_EVENT_HIT, shooter known"))
                                        end	
    
                                        -- revise a_pos
                                        a_pos = shooter:getPoint()
    
                                        -- parameters identification
                                        s_detected , s_visible , s_lastTime , s_type , s_distance , s_lastPos , s_lastVel = con:isTargetDetected(shooter)
    
                                        o_cat, s_cat = shooter:getCategory()
                                        s_cls = getUnitClass(shooter)
    
    
                                        --[[ o_cat: 
                                            UNIT    1
                                            WEAPON  2
                                            STATIC  3
                                            BASE    4
                                            SCENERY 5
                                            Cargo   6
                                        --]]--                                        
                                        
                                        --[[ s_cat: 
                                            AIRPLANE      = 0,
                                            HELICOPTER    = 1,
                                            GROUND_UNIT   = 2,
                                            SHIP          = 3,
                                            STRUCTURE     = 4
                                        --]]--
                                        
                                        -- shooter is indirect fire
                                        if shooter:hasAttribute("Indirect fire") then
                                            s_indirect = 1
                                        end
    
                                        -- shooter is close
                                        if a_pos and position then
                                            local d = db_group.sa.rng or 1500
                                            local dist = getDist(a_pos, position)
                                            if dist < d then
                                                s_close = 1
                                            end
                                        end      
    
                                        -- position and speed
                                        --[[ removed cause of issues with isTargetDetected function returned variables
                                        if a_pos and s_lastVel and s_lastTime then
                                            if timer.getTime() - s_lastTime < 30 and s_lastVel < 1 then
                                                s_fireMis = 1
                                            end
                                        end
                                        --]]--
                                        local rnd = math.random(1,100)
                                        if rnd > 70 then
                                            s_fireMis = 1
                                        end
    
    
                                    else -- try to address things when the shooter is unknown, based on weapon and effects
                                        if AIEN.config.AIEN_debugProcessDetail == true then
                                            env.info(("AIEN.event_hit, S_EVENT_HIT, shooter unknown"))
                                        end	 
    
                                        if w_cat then
                                            --[[-- 
                                                Weapon.Category
                                                SHELL     0
                                                MISSILE   1
                                                ROCKET    2
                                                BOMB      3
                                            --]]--
                                            if w_cat == 0 or w_cat == 2 then -- shooter is unknown, and the weapon is a shell or a rocket: artillery is possibile
                                                s_indirect = 1
                                                if AIEN.config.AIEN_debugProcessDetail == true then
                                                    env.info(("AIEN.event_hit, S_EVENT_HIT, shooter unknown but arty fire possibile"))
                                                end	 
                                            elseif w_cat == 1 or w_cat == 3 then -- shooter is unknown, and the weapon is a missile or a bomb: airborne threat is possibile
                                                s_cls = "ARBN"
                                                if AIEN.config.AIEN_debugProcessDetail == true then
                                                    env.info(("AIEN.event_hit, S_EVENT_HIT, shooter unknown but airborne fire possibile"))
                                                end	 
                                            end
    
                                        end
                                    end
    
                                    if AIEN.config.AIEN_debugProcessDetail == true then
                                        env.info(("AIEN.event_hit, S_EVENT_HIT, group " .. tostring(group:getName()) .. ", w_cat: " .. tostring(w_cat) ))
                                        env.info(("AIEN.event_hit, S_EVENT_HIT, group " .. tostring(group:getName()) .. ", s_cat: " .. tostring(s_cat) ))
                                        env.info(("AIEN.event_hit, S_EVENT_HIT, group " .. tostring(group:getName()) .. ", s_indirect: " .. tostring(s_indirect) ))
                                        env.info(("AIEN.event_hit, S_EVENT_HIT, group " .. tostring(group:getName()) .. ", s_close: " .. tostring(s_close) ))
                                        env.info(("AIEN.event_hit, S_EVENT_HIT, group " .. tostring(group:getName()) .. ", s_fireMis: " .. tostring(s_fireMis) ))
                                        env.info(("AIEN.event_hit, S_EVENT_HIT, group " .. tostring(group:getName()) .. ", o_cls: " .. tostring(o_cls) ))
                                        env.info(("AIEN.event_hit, S_EVENT_HIT, group " .. tostring(group:getName()) .. ", s_cls: " .. tostring(s_cls) ))
                                        env.info(("AIEN.event_hit, S_EVENT_HIT, group " .. tostring(group:getName()) .. ", a_pos: " .. tostring(a_pos) ))
                                    end	
    
                                    local av_ac = deepCopy(reactionsDb) 
    
                                    -- remove not doable actions due to missin informations
                                    if s_fireMis < 1 or AI_consent == false then -- shooter position is not sufficiently recent
                                    if AIEN.config.AIEN_debugProcessDetail == true then
                                            env.info(("AIEN.event_hit, S_EVENT_HIT, s_fireMis is 0, won't be able to call fire support"))
                                        end	                                  
                                        av_ac[8] = nil
                                    end
                                    if db_group.class == "ARTY" or db_group.class == "MISSILE" or db_group.class == "MLRS" then -- group is an arty or mlrs
                                        if AIEN.config.AIEN_debugProcessDetail == true then
                                            env.info(("AIEN.event_hit, S_EVENT_HIT, ally is an arty or mlrs, won't be able to move toward the enemy"))
                                        end	                                  
                                        av_ac[5] = nil
                                    end
                                    if not a_pos or not s_detected then -- enemy position unknown
                                        if AIEN.config.AIEN_debugProcessDetail == true then
                                            env.info(("AIEN.event_hit, S_EVENT_HIT, enemy not detected, won't be able to move toward the enemy"))
                                        end	                                  
                                        av_ac[6] = nil
                                        av_ac[8] = nil
                                        av_ac[10] = nil
                                    end
                                    if s_cat == 1 then -- shooter is helicopter
                                        if AIEN.config.AIEN_debugProcessDetail == true then
                                            env.info(("AIEN.event_hit, S_EVENT_HIT, shooter is Helo, removing less sensed decision"))
                                        end	                                  
                                        av_ac[8] = nil -- remove ground support
                                        av_ac[3] = nil -- remove disperse

                                    end
                                    if s_cat == 0 then -- shooter is airborne
                                    if AIEN.config.AIEN_debugProcessDetail == true then
                                            env.info(("AIEN.event_hit, S_EVENT_HIT, shooter is plane, removing less sensed decision"))
                                        end	                                  
                                        av_ac[6] = nil -- remove attack
                                        av_ac[8] = nil -- remove ground support
                                        av_ac[3] = nil -- remove disperse
                                        av_ac[10] = nil -- remove fire
                                    end
                                    if s_cls ~= "ARBN" then -- shooter is not airborne
                                        av_ac[9] = nil -- remove counter ADS
                                    end
                                    if not unit:hasAttribute("Armored vehicles") then
                                        av_ac[4] = nil -- remove drop smoke
                                    end
                                    if AIEN.config.AIEN_debugProcessDetail then
                                        env.info( string.format(
                                            "%s, skill level for %s = %d",ModuleName,group:getName(),db_group.skill or -1))
                                    end
                                    -- filter available actions by skill
                                     local filter = db_group.skill
                                     if AIEN.config.skill_action_const == false then
                                         filter = filter * 2
                                       end
                                         for aSk, action in pairs(av_ac) do
                                         if aSk > filter then
                                             av_ac[aSk] = nil
                                         end
                                    end
                                    if AIEN.config.AIEN_debugProcessDetail == true then
                                        env.info(("AIEN.event_hit, S_EVENT_HIT, available actions " .. tostring(#av_ac) ))
                                    end
                                    
                                    -- calculate points for each remaining actions
                                    local bc_ac = {}
                                    for _, aData in pairs(av_ac) do
                                        local points = 0
                                        local px1 = aData["w_cat"][w_cat] or 0
                                        local px2 = aData["s_cat"][s_cat] or 0
                                        local px3 = aData["s_indirect"][s_indirect] or 0
                                        local px4 = aData["s_close"][s_close] or 0
                                        local px5 = aData["s_fireMis"][s_fireMis] or 0
                                        local px6 = aData["o_cls"][o_cls] or 0
                                        local px7 = aData["s_cls"][s_cls] or 0
    
                                        points = px1 + px2 + px3 + px4 + px5 + px6 + px7 
                                        if AIEN.config.AIEN_debugProcessDetail == true then
                                            --env.info(("AIEN.event_hit, S_EVENT_HIT," .. tostring(aData.name) ..  ", points for w_cat: " .. tostring(aData["w_cat"][w_cat])))
                                            --env.info(("AIEN.event_hit, S_EVENT_HIT," .. tostring(aData.name) ..  ", points for s_cat: " .. tostring(aData["s_cat"][s_cat])))
                                            --env.info(("AIEN.event_hit, S_EVENT_HIT," .. tostring(aData.name) ..  ", points for s_indirect: " .. tostring(aData["s_indirect"][s_indirect])))
                                            --env.info(("AIEN.event_hit, S_EVENT_HIT," .. tostring(aData.name) ..  ", points for s_close: " .. tostring(aData["s_close"][s_close])))
                                            --env.info(("AIEN.event_hit, S_EVENT_HIT," .. tostring(aData.name) ..  ", points for s_fireMis: " .. tostring(aData["s_fireMis"][s_fireMis])))
                                            --env.info(("AIEN.event_hit, S_EVENT_HIT," .. tostring(aData.name) ..  ", points for o_cls: " .. tostring(aData["o_cls"][o_cls])))
                                            --env.info(("AIEN.event_hit, S_EVENT_HIT," .. tostring(aData.name) ..  ", points for s_cls: " .. tostring(aData["s_cls"][s_cls])))
                                            env.info(("AIEN.event_hit, S_EVENT_HIT," .. tostring(aData.name) ..  ", points total: " .. tostring(points)))
                                        end	
    
                                        bc_ac[#bc_ac+1] = {name = aData.name, action = aData.action, rank = points}
                                    end
                                    table.sort(bc_ac, function(a,b)
                                        if a.rank and b.rank then
                                            return a.rank > b.rank 
                                        end
                                    end)
    
                                    -- record the attack, for preventing phases to act for 10 mins
                                    underAttack[group:getID()] = timer.getTime()
    
                                    choosenAct = executeReactions(group, o_pos, a_pos, bc_ac, db_group.sa, db_group.skill)
    
                                end
    
                            end
    
                            -- counter battery part
                            if choosenAct ~= "ac_fireMissionOnShooter" then
                                if AIEN.config.firemissions == true then
                                    if shooter:getPoint() and position then
                                        counterBattery(position, shooter:getPoint(), group:getCoalition())
                                    end
                                end
                            end
    
                        else
                            if AIEN.config.AIEN_debugProcessDetail == true then
                                env.info(("AIEN.event_hit, S_EVENT_HIT, AI consent is false"))
                            end	
                        end
                    end
                else
                    if AIEN.config.AIEN_debugProcessDetail == true then
                        env.info(("AIEN.event_hit, missing unit"))
                    end	                
                end
            else
                if AIEN.config.AIEN_debugProcessDetail == true then
                    env.info(("AIEN.event_hit, either shooter or unit are not valid units"))
                end	                
            end
        end
    
    end

local function event_birth(initiator)

    local check = pcallGetCategory(initiator)
    
    if check then
        local objCat = nil
        local subCat = nil
        
        objCat, subCat = initiator:getCategory()
        if objCat == 1 and subCat == 2 then -- unit, ground unit
            local gp = initiator:getGroup()
            local gpName  = gp:getName()
                if gp and gpName and string.find(gpName, "^CTLD_CARGO_Scout") then
                    droneunitDb[gp:getID()] = {group = gp, class = "UAV", n = gpName, coa = gp:getCoalition(), sa = {}}
                env.info('AIEN.event_birth: adding scout drone ' .. gpName)
                return
            end    
            if not initiator:hasAttribute("Infantry") then
                if gp then
                    if not groundgroupsDb[gp:getID()] then -- since event is launched for each unit, this prevent re-adding the same group multiple times
                        local c = getGroupClass(gp)
                        local det, thr = getRanges(gp)
                        local s = getGroupSkillNum(gp)
                        groupPreventDisperse(gp)
                        --env.info((tostring(ModuleName) .. ", event_birth: s " .. tostring(s)))
                        groundgroupsDb[gp:getID()] = {group = gp, class = c, n = gpName, coa = gp:getCoalition(), detection = det, threat = thr, tasked = false, skill = s, sa = {} }
                        if c == "ARTY" or c == "MLRS" then
                            --env.info(("ARTYDBG "..tostring(gpName)))
                            phase_keys = createIterator(groundgroupsDb)
                        end                      
                    end
                end
            end
        elseif objCat == 1 and subCat == 0 then -- unit, plane unit (drone)	
            local gp = initiator:getGroup()
            local gpName  = gp:getName()
            if gp then				
                local c = nil
                if gpName == "jtacDroneColdwar1" or gpName == "jtacDroneColdwar2" or gpName == "JTAC9lineamColdwar" or gpName == "JTAC9linefmColdwar" then
                    c = "UAV"
                else
                    if gp:getUnits() and #gp:getUnits() > 0 then
                        for _, un in pairs(gp:getUnits()) do
                            if un:hasAttribute("UAVs") then -- drone only
                                c = "UAV"
                            end
                        end
                    end
                end
                if c then
                    if AIEN.config.AIEN_debugProcessDetail == true then
                        --env.info((tostring(ModuleName) .. ", event_birth: adding to droneunitDb " .. tostring(gp:getName() )))
                    end
                    
                    droneunitDb[gp:getID()] = {group = gp, class = c, n = gpName, coa = gp:getCoalition(), sa = {}}
                end                        					
            end
        end	
    end
end

local function event_dead(initiator)
    if not initiator then return end

    local objCat, subCat = nil, nil
    local ok, c1, c2 = pcall(Object.getCategory, initiator)
    if ok then
        objCat, subCat = c1, c2
    else
        env.info("AIEN.event_dead: getCategory failed -> "..tostring(c1))
    end

    if objCat == 1 and subCat == 2 then
        mountedDb[initiator:getID()]   = nil
        infcarrierDb[initiator:getID()] = nil
    end
end


--## EVENTS HANDLING CALLS

AIEN.eventHandler = {} -- define event based real time unit reactions. I prefer to have 1 single handler that then will route itself on the right directions event based.
function AIEN.eventHandler:onEvent(event)	

    if event.id == world.event.S_EVENT_HIT then 
        local u = event.target
        local s = event.initiator
		local w	= event.weapon 

        event_hit(u, s, w)

    elseif event.id == world.event.S_EVENT_BIRTH then 
        local i = event.initiator
        if i then
            event_birth(i)
        end

    elseif event.id == world.event.S_EVENT_DEAD or event.id == world.event.S_EVENT_UNIT_LOST then 
        local i = event.initiator
        if i then
            event_dead(i)
        end

    end
end
world.addEventHandler(AIEN.eventHandler)



--## INIT SCRIPT
if AIEN.config.dontInitialize then
	env.info((ModuleName .. ": Loaded (BUT NOT INITIALIZED) " .. MainVersion .. "." .. SubVersion .. "." .. Build .. ", released " .. Date))
else
	AIEN.performPhaseCycle()
	env.info((ModuleName .. ": Loaded " .. MainVersion .. "." .. SubVersion .. "." .. Build .. ", released " .. Date))
end


--~=
