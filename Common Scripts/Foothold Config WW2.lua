-- Version V1.0.8
-- ** CHANGE LOG **
--
-- Added CsarPilotSpawnWithoutCreditsChance,  - V1.0.3
-- Added CasDifficulty setting Advanced settings. - V1.0.3
-- Added SeadDifficulty setting with Advanced settings. - V1.0.3
-- Added RunwayStrikeDifficulty setting Advanced settings. - V1.0.3
-- Added MH-60R. Added CSAR Restore amounts - V1.0.4.
-- Added Escort allowed plane types. Added DisableMantis option. - V1.0.5
-- Added FootholdLocale language option. - V1.0.6
-- Added load error message for the config. - V1.0.7
-- Added support for Foothold WW2.lua
-- Use Notepad++ and use compare tool to see the changes.
--
--
-- DO NOT TOUCH THIS BLOCK
--
local savePath = (lfs and lfs.writedir and (lfs.writedir() .. "Missions\\Saves")) or nil
local saveFile = "Foothold Config WW2.lua"
local externalConfigChunk = nil
-- Add new top-level config tables here so an omitted external table triggers the warning.
FootholdConfigTrackedTableNames = {
    "CapLimitStages",
    "RedCasLimitStages",
    "RedRunwayStrikeLimitStages",
    "BlueCapSupportStages",
    "BlueCasSupportStages",
    "AddWeightToPlaneRed",
    "AddWeightToPlaneBlue",
    "CapCountIgnoreTypes",
    "RedCasCountIgnoreTypes",
    "BlueCasCountIgnoreTypes",
    "RedReactiveConfig",
    "MessageOfTheDay",
    "CallsignOverrides",
    "AllowedToCarrySupplies",
    "ShopPrices",
    "ShopRankRequirements",
    "RewardContribution",
    "AllowedCsar",
    "AllowedFlightTimeReward",
    "ewrs_specialPlaneTypes",
    "AllowedWW2Planes",
}

local function applyExternalConfigWithFallbackWarning()
    local internalTableDefaults = {}
    for _, tableName in ipairs(FootholdConfigTrackedTableNames) do
        internalTableDefaults[tableName] = _G[tableName]
    end

    externalConfigChunk()

    local internalDefaultsApplied = false
    for tableName, internalDefault in pairs(internalTableDefaults) do
        if _G[tableName] == internalDefault then
            internalDefaultsApplied = true
            break
        end
    end
    if not internalDefaultsApplied then return end

    env.warning("[FOOTHOLD_CONFIG_EXTERNAL_OUTDATED] External Foothold config is outdated. Internal defaults were applied where required.")

    local warningCount = 0
    SCHEDULER:New(nil, function()
        warningCount = warningCount + 1
        trigger.action.outText(FootholdLocalization:Get("FOOTHOLD_CONFIG_EXTERNAL_OUTDATED"), 9)
        if warningCount >= 12 then return false end
    end, {}, 1, 10)
end

local function reportFootholdConfigLoadError(err)
    FootholdConfigLoadError = tostring(err or "unknown error")
    env.info("Foothold config external load failed: " .. FootholdConfigLoadError)
    if not FootholdConfigLoadErrorSchedulerStarted then
        FootholdConfigLoadErrorSchedulerStarted = true
        SCHEDULER:New(nil, function()
            trigger.action.outText("FOOTHOLD CONFIG ERROR: Foothold config did not load correctly, Check syntax.", 30)
        end, {}, 1, 30)
    end
end

if savePath and not FootholdConfigLoaded and UTILS.CheckFileExists(savePath, saveFile) then
    local externalConfigPath = savePath .. "\\" .. saveFile
    local chunk, err = loadfile(externalConfigPath)
    if chunk then
        externalConfigChunk = chunk
    else
        reportFootholdConfigLoadError(err)
    end
end

if externalConfigChunk then
    FootholdConfigLoaded = true
    FootholdConfigLoadedOk = nil
end
--
-- End of do not touch
--
-- ============================================================================
-- Mission Rules
-- ============================================================================

-- Global language use for Foothold.
-- This does not set the menu's language as it can be changed in the players radio menu.
-- This will be the language used for on screen messages and other global text.
-- Set FootholdLocale to one of:
--   "EN"    English
--   "DE"    German / Deutsch
--   "FR"    French / Français
--   "ES"    Spanish / Español
--   "RU"    Russian / Русский
--   "PT-BR" Brazilian Portuguese / Português (Brasil)
--   "TR"    Turkish / Türkçe
--   "IT"    Italian / Italiano
--   "zh-CN" Simplified Chinese (Mainland China) / 简体中文
--   "zh-TW" Traditional Chinese (Taiwan) / 繁體中文
FootholdLocale = "EN"
if FootholdLocalization then
    FootholdLocalization:SetLocale(FootholdLocale)
end
 
-- When the mission is completed, if you want the server to restart automatically and reset everything, then set this to true.
-- If false, you will have a menu where you can choose to restart the mission. 
AutoRestart = false

-- PVE_Only is a flag where you can decide if you want to disable players from spawning in red zones.
-- This is when the player chooses Red coalition.
PVE_Only = false -- If true, players can not spawn in red coalition zones.

-- If true, when players die their coalition loses 100 credits per death.
CreditLosewhenKilled = false

-- If you want to change the amount, you can do it here.
CreditLosewhenKilledAmount = 100

-- If true, when players die they lose 100 rank credits (only if RankingSystem == true).
RankLoseWhenKilled = true

-- If you want to change the amount, you can do it here.
RankLoseWhenKilledAmount = 100

-- If true, loads enhanced bomb blast effects (may cause stutters).
SplashDamage = true -- true by default in Normandy.

ShowKills = false -- If true, show Foothold kill messages.

-- If true, limit shop purchases by personal credits earned (rank gates):
--   >  250 cost requires   100 earned
--   > 1000 cost requires  1000 earned
--   > 2000 cost requires  2000 earned
--   > 3000 cost requires  3000 earned
StoreLimit = false

-- If false, everyone can access the full shop.
RankingSystem = true

-- friendly fire ranking penalty
FriendlyFireRankPenalty = 500

-- ============================================================================
-- Difficulty
-- ============================================================================
GlobalSettings = GlobalSettings or {}
-- Foothold non-supply spawn/respawn speed scaling (multiplier).
-- This value multiplies AI respawn timers for attack/patrol missions.
-- 1.0 = default (no change)
-- < 1.0 = faster spawns (shorter timers)   | 0.5 = 2x faster
-- > 1.0 = slower spawns (longer timers)    | 1.5 = 50% slower
--
-- Side index:
-- [1] = RED coalition
-- [2] = BLUE coalition
--
-- Examples:
-- Blue spawns twice as fast:  GlobalSettings.difficultyScaling = { [1]=1.0, [2]=0.5 }
-- Red spawns 30% slower:      GlobalSettings.difficultyScaling = { [1]=1.3, [2]=1.0 }
-- This does not affect the supply missions.
-- < 1.0 = faster spawns (shorter timers)   | 0.5 = 2x faster
-- > 1.0 = slower spawns (longer timers)    | 1.5 = 50% slower
GlobalSettings.difficultyScaling = { [1]=1.0, [2]=1.0 }

-- Supply-only spawn/respawn speed scaling (multiplier).
-- This value multiplies AI respawn timers for supply missions only.
-- < 1.0 = faster spawns (shorter timers)   | 0.5 = 2x faster
-- > 1.0 = slower spawns (longer timers)    | 1.5 = 50% slower
GlobalSettings.supplyDifficultyScaling = { [1]=1.0, [2]=1.0 }

-- @gui label="Red AI Plane Skill" validValues="Average=Average | Good=Good | High=High | Excellent=Excellent | Random=Random"
AiPlaneSkill            = "Random" -- AI skill used for spawned airplanes Red only (MOOSE SPAWN:InitSkill).

-- Valid: "Average", "Good", "High", "Excellent", "Random" (case-insensitive). Unknown values become "High".
RedAiGroundSkill        = "Excellent" -- AI skill used for spawned RED zone ground defenses (MOOSE SPAWN:InitSkill).

-- Valid: "Average", "Good", "High", "Excellent", "Random" (case-insensitive). Unknown values become "High".
BlueAiGroundSkill       = "Excellent" -- AI skill used for spawned BLUE zone ground defenses (MOOSE SPAWN:InitSkill).

-- Valid values: "easy" | "medium" | "hard"
-- Here, you can adjust how many cap should spawn. medium, is the default (Balanaced)
CapDifficulty           = "medium" -- RED CAP amount.  This can be further custommized in the advance section.
CasDifficulty           = "medium" -- RED CAS amount.  This can be further custommized in the advance section.

FriendlyCapSupport      = "medium" -- BLUE CAP support limit. This can be further custommized in the advance section.
FriendlyCasSupport      = "medium" -- BLUE CAS support limit.  This can be further custommized in the advance section.
RunwayStrikeDifficulty  = "medium" -- RED RUNWAYSTRIKE amount.  This can be further custommized in the advance section.

-- ============================================================================
-- Difficulty advanced
-- ============================================================================

-- The "amount" field in the case of CAP, 1 amount equals to 1 CAP Patrol and 1 CAP Attack. so 1 amount equal 2 groups.
-- players in the table below are counted as active players if they are not in the CapCountIgnoreTypes.
-- @gui label="RED CAP Limit"
-- @gui linkedSetting="CapDifficulty"
-- @gui installPolicy="keepTable"
CapLimitStages = {
	easy = {
		{ player = 0,   amount = 0 },
		{ player = 1,   amount = 1 },
		{ player = 2,   amount = 1 },
		{ player = 3,   amount = 2 },
		{ player = 4,   amount = 3 },
		{ player = 6,   amount = 4 },
		{ player = 10,  amount = 5 },
		{ player = 999, amount = 6 },
	},
	medium = {
		{ player = 0,   amount = 1 },
		{ player = 1,   amount = 1 },
		{ player = 2, amount = 1 },
		{ player = 3, amount = 2 },
		{ player = 4, amount = 2 },
		{ player = 5, amount = 3 },
		{ player = 9,   amount = 5 },
		{ player = 10,  amount = 6 },
		{ player = 999, amount = 7 },
	},
	hard = {
		{ player = 0,   amount = 1 },
		{ player = 1,   amount = 2 },
		{ player = 2,   amount = 3 },
		{ player = 3,   amount = 4 },
		{ player = 4,   amount = 5 },
		{ player = 6,   amount = 5 },
		{ player = 9,   amount = 6 },
		{ player = 10,  amount = 7 },
		{ player = 999, amount = 8 },
	},
}

-- Advance settings for CasDifficulty.
-- Players in the table below are counted as active players if they are not in the RedCasCountIgnoreTypes.
-- The "amount" field in the table below is the amount of CAS flights that can be active at the same time.
-- @gui label="RED CAS Limit"
-- @gui linkedSetting="CasDifficulty"
-- @gui installPolicy="keepTable"
RedCasLimitStages = {
	easy = {
		{ player = 0,   amount = 0 },
		{ player = 1,   amount = 0 },
		{ player = 2,   amount = 1 },
		{ player = 3,   amount = 1 },
		{ player = 4,   amount = 2 },
		{ player = 5,   amount = 2 },
		{ player = 999, amount = 3 },
	},
	medium = {
		{ player = 0,   amount = 1 },
		{ player = 1,   amount = 1 },
		{ player = 2, amount = 1 },
		{ player = 3,   amount = 2 },
		{ player = 4,   amount = 3 },
		{ player = 5,   amount = 3 },
		{ player = 9,   amount = 4 },
		{ player = 999, amount = 4 },
	},
	hard = {
		{ player = 0,   amount = 1 },
		{ player = 1,   amount = 2 },
		{ player = 2,   amount = 2 },
		{ player = 3,   amount = 3 },
		{ player = 4,   amount = 4 },
		{ player = 5,   amount = 4 },
		{ player = 9,   amount = 6 },
		{ player = 999, amount = 7 },
	},
}

-- Advance settings for RunwayStrikeDifficulty.
-- Players in the table below are counted as active players if they are not in the RedCasCountIgnoreTypes.
-- The "amount" field in the table below is the amount of Runway Strike flights that can be active at the same time.
-- @gui label="RED Runway Strike Limit"
-- @gui linkedSetting="RunwayStrikeDifficulty"
-- @gui installPolicy="keepTable"
RedRunwayStrikeLimitStages = {
	easy = {
		{ player = 0,   amount = 0 },
		{ player = 1,   amount = 0 },
		{ player = 2,   amount = 1 },
		{ player = 3,   amount = 1 },
		{ player = 4,   amount = 2 },
		{ player = 5,   amount = 2 },
		{ player = 999, amount = 3 },
	},
	medium = {
		{ player = 0,   amount = 0 },
		{ player = 1,   amount = 0 },
		{ player = 2,   amount = 1 },
		{ player = 3,   amount = 2 },
		{ player = 4,   amount = 3 },
		{ player = 5,   amount = 3 },
		{ player = 9,   amount = 4 },
		{ player = 999, amount = 4 },
	},
	hard = {
		{ player = 0,   amount = 0 },
		{ player = 1,   amount = 1 },
		{ player = 2,   amount = 2 },
		{ player = 3,   amount = 3 },
		{ player = 4,   amount = 4 },
		{ player = 5,   amount = 4 },
		{ player = 9,   amount = 6 },
		{ player = 999, amount = 7 },
	},
}

-- Advance settings for FriendlyCapSupport.
-- Players in the table below are counted as active players if they are not in the CapCountIgnoreTypes.
-- The logic here, The less the players, the more AI will help you. The list in CapCountIgnoreTypes, is types that doesn't count as active players.
-- @gui label="BLUE CAP Support"
-- @gui linkedSetting="FriendlyCapSupport"
-- @gui installPolicy="keepTable"
BlueCapSupportStages = {
	easy = {
		{ player = 0,   amount = 2 },
		{ player = 1,   amount = 2 },
		{ player = 999, amount = 1 },
	},
	medium = {
		{ player = 0,   amount = 1 },
		{ player = 1,   amount = 1 },
		{ player = 999, amount = 0 },
	},
	hard = {
		{ player = 999, amount = 0 },
	},
}
-- Advance settings for FriendlyCasSupport.
-- Players in the table below are counted as active players if they are not in the BlueCasCountIgnoreTypes.
-- The logic here, The less the players, the more AI will help you. The list in BlueCasCountIgnoreTypes, is types that doesn't count as active players.
-- @gui label="BLUE CAS Support"
-- @gui linkedSetting="FriendlyCasSupport"
-- @gui installPolicy="keepTable"
BlueCasSupportStages = {
	easy = {
		{ player = 0,   amount = 2 },
		{ player = 1,   amount = 2 },
		{ player = 999, amount = 1 },
	},
	medium = {
		{ player = 0,   amount = 1 },
		{ player = 1,   amount = 1 },
		{ player = 999, amount = 0 },
	},
	hard = {
		{ player = 999, amount = 0 },
	},
}

-- Extra internal cargo weight added to RED WWII aircraft.
-- Tick enabled to apply extra weight, then set the weight value.
-- @gui label="RED Plane Extra Weight" editor="fieldTable" fields="enabled:Enabled:boolean | weight:Weight:number"
AddWeightToPlaneRed = {
    ["FW-190D9"] = { enabled = true, weight = 1000 },
    ["Bf-109K-4"] = { enabled = true, weight = 1750 },
    ["Ju-88A4"] = { enabled = true, weight = 1000 },
    ["C-47"] = { enabled = true, weight = 1000 },

}

-- Extra internal cargo weight added to BLUE WWII aircraft.
-- Tick enabled to apply extra weight, then set the weight value.
-- @gui label="BLUE Plane Extra Weight" editor="fieldTable" fields="enabled:Enabled:boolean | weight:Weight:number"
AddWeightToPlaneBlue = {
    ["P-51D-30-NA"] = { enabled = true, weight = 750 },
    ["SpitfireLFMkIX"] = { enabled = true, weight = 550 },
    ["P-47D-40"] = { enabled = true, weight = 500 },
    ["MosquitoFBMkVI"] = { enabled = true, weight = 650 },
    ["A-20G"] = { enabled = true, weight = 1000 },
    ["F4U-1D"] = { enabled = true, weight = 400 },
    ["C-47"] = { enabled = true, weight = 2000 },
    ["B-17G"] = { enabled = true, weight = 2000 },
}

-- Units that will NOT be counted when calculating how many players are "active"
-- (used for CAP/CAS/SEAD scaling).
-- If you set a type to true, it will not be counting that player, because C-130 for example can't fight A/A. This will make
-- the Red CAP for example not spawn a jet for that player, because it's set to true in the ignore list.
-- SAME for the CAS. For the Blue cas, you want to be ignored if your flying C-130, so Blue cas WILL help you.
-- For the red CAS, they will NOT see you as a player so they will lay back and not spawn as often.
-- removing or adding more planes here will change the amount of cap since they will
-- be counted as active players or not.

CapCountIgnoreTypes = {
}

RedCasCountIgnoreTypes = {
}

BlueCasCountIgnoreTypes = {
}

-- ============================================================================
-- RED Reactive Counterpressure
-- ============================================================================
-- RED Reactive Counterpressure (simple explanation):
-- When BLUE players get close to RED frontline zones, RED starts reacting.
-- RED reaction has 2 parts:
-- 1) Soft reaction: RED speeds up some supply and Patrolling CAP groups for pressured RED zones.
-- 2) Hard reaction: RED can force-spawn attack groups to strike BLUE zones.
-- If you do NOT want red supplies groups to be boosted in speed to spawn faster, set softSupplyBoostPerZone to 0.
-- If you do NOT want red CAP groups to be boosted in speed to spawn faster, set softCapBoostPerZone to 0.
-- The coolDownSec is how often this stuff triggers, you can increase / decrease.
-- Valid values: "easy" | "medium" | "hard"
RedReactiveDifficulty   = "medium" -- RED reactive counterpressure difficulty.

RedReactiveConfig = {
easy = {
    enabled = true, -- Turn the reactive system on/off for this profile
    minPressureSoft = 16, -- Minimum pressure needed for RED soft reaction (supply/CAP boost). With CapDifficulty="medium", this is usually 3+ counted CAP players.
    minPressureHard = 15, -- Minimum pressure needed for RED hard reaction (attack push). With CapDifficulty="medium", this is usually 3+ counted CAP players.
    captureHardWindowSec = 120, -- If BLUE captured a zone recently, Red side can be angry for this long in seconds, and dispatch attack.
    hardZoneCooldownSec = 1800, -- After hard reaction is used for a pressured RED zone, wait this long before hard can happen there again
    maxZonesPerTick = 1, -- Max number of pressured RED zones processed per check
    softSupplyBoostPerZone = 0, -- Max number of RED supply groups to soft-boost per processed zone per check
    softCapBoostPerZone = 1, -- Max number of RED CAP groups to soft-boost per processed zone per check
    softSupplyCooldownSec = 1800, -- After a supply soft-boost in one RED zone, wait this long before supply soft-boost can happen there again
    softCapCooldownSec = 1800, -- After a CAP soft-boost in one RED zone, wait this long before CAP soft-boost can happen there again
    hardForcePerZone = 1, -- Max hard-forced attack groups for one processed pressured zone
    hardForceTotalPerTick = 1, -- Total hard-forced attack groups allowed per check (all zones together)
    groupReuseCooldownSec = 1600, -- After one attack group is hard-forced, wait this long before that same group can be hard-forced again
},

medium = {
    enabled = true, -- Turn the reactive system on/off for this profile
    minPressureSoft = 9, -- Minimum pressure needed for RED soft reaction (supply/CAP boost). With CapDifficulty="medium", this is usually 2-3 counted CAP players.
    minPressureHard = 9, -- Minimum pressure needed for RED hard reaction (attack push). With CapDifficulty="medium", this is usually 2-3 counted CAP players.
    captureHardWindowSec = 180, -- If BLUE captured a zone recently, Red side can be angry for this long in seconds, and dispatch attack.
    hardZoneCooldownSec = 1800, -- After hard reaction is used for a pressured RED zone, wait this long before hard can happen there again
    maxZonesPerTick = 1, -- Max number of pressured RED zones processed per check
    softSupplyBoostPerZone = 0, -- Set to 0 to disable RED supply soft reaction. Applied only when minPressureSoft is met.
    softCapBoostPerZone = 1, -- Set to 0 to disable RED CAP soft reaction. Applied only when minPressureSoft is met.
    softSupplyCooldownSec = 1500, -- After a supply soft-boost in one RED zone, wait this long before supply soft-boost can happen there again
    softCapCooldownSec = 900, -- After a CAP soft-boost in one RED zone, wait this long before CAP soft-boost can happen there again
    hardForcePerZone = 2, -- Max hard-forced attack groups for one processed pressured zone
    hardForceTotalPerTick = 2, -- Total hard-forced attack groups allowed per check (all zones together)
    groupReuseCooldownSec = 1200, -- After one attack group is hard-forced, wait this long before that same group can be hard-forced again
},

hard = {
    enabled = true, -- Turn the reactive system on/off for this profile
    startDelaySec = 120, -- Wait this many seconds after mission start before first reactive check
    minPressureSoft = 6, -- Minimum pressure needed for RED soft reaction (supply/CAP boost). In hard profile, this starts earlier than medium.
    minPressureHard = 9, -- Minimum pressure needed for RED hard reaction (attack push). This is usually around 2-3 counted CAP players.
    captureHardWindowSec = 240, -- If BLUE captured a zone recently, Red side can be angry for this long in seconds, and dispatch attack (Hard reaction)
    hardZoneCooldownSec = 900, -- After hard reaction is used for a pressured RED zone, wait this long before hard can happen there again
    maxZonesPerTick = 1, -- Max number of pressured RED zones processed per check
    softSupplyBoostPerZone = 1, -- Set to 0 to disable RED supply soft reaction. Applied only when minPressureSoft is met.
    softCapBoostPerZone = 2, -- Set to 0 to disable RED CAP soft reaction. Applied only when minPressureSoft is met.
    softSupplyCooldownSec = 1200, -- After a supply soft-boost in one RED zone, wait this long before supply soft-boost can happen there again
    softCapCooldownSec = 900, -- After a CAP soft-boost in one RED zone, wait this long before CAP soft-boost can happen there again
    hardForcePerZone = 3, -- Max hard-forced attack groups for one processed pressured zone
    hardForceTotalPerTick = 3, -- Total hard-forced attack groups allowed per check (all zones together)
    groupReuseCooldownSec = 900, -- After one attack group is hard-forced, wait this long before that same group can be hard-forced again
},
}
-- ============================================================================
-- Message Of The Day
-- ============================================================================

-- Shows one server message to all players, then repeats it on a timer.
MessageOfTheDay = {
    enabled = false, -- Set to true to show this message to everyone.
    durationSec = 15, -- How long the message stays on screen.
    intervalSec = 1800, -- How often the message repeats.
    text =
[[Welcome to our server.

Discord is here:
https://discord.gg/your-link

Please join us.]],
}
-- ============================================================================
-- Welcome Message Callsigns
-- ============================================================================

-- Below, you can change the callsigns in the welcome message and their IFF codes.
-- The IFF codes are only functional if you use LotATC and configure the same numbers there.
-- If IFF is not important to you, keep the numbers as-is and only change the callsigns.
-- @gui label="Welcome Message Callsigns" installPolicy="keepTable"
CallsignOverrides = {
    ["F4U.1D"] = {
        ["BlackSheep1"] = { 0, 0, 0, 0 },
    },
    ["Spitfire.LF.Mk"] = {
        ["Circus1"] = {0, 0, 0, 0},
    },
    ["Mosquito.FB.Mk"] = {
        ["Beer1"] = {0, 0, 0, 0},
    },
    ["P.47D"] = {
        ["Detroit1"] = {0, 0, 0, 0},
    },
    ["P.51D"] = {
        ["Mickey1"] = {0, 0, 0, 0},
    },
    ["Bf.109.K"] = {
        ["Schwarz1"] = {0, 0, 0, 0},
    },
    ["FW.190A.8"] = {
        ["Panther1"] = {0, 0, 0, 0},
    },
    ["FW.190D.9"] = { 
        ["Angriff1"] = {0, 0, 0, 0}, 
    },
    ["I.16"] = { 
        ["Berkut1"] = {0, 0, 0, 0},
    },
    ["Yak.52"] = {
        ["Medved1"] = {0, 0, 0, 0},
    },
    ["La.7"] = {
        ["Volk1"] = {0, 0, 0, 0},
    },
}

-- ============================================================================
-- Logistics / Warehouse
-- ============================================================================

-- If true, Blue AI will NOT deliver supplies, it will ONLY be done by the player.
NoAIBlueSupplies = false

-- This option is the legacy option. this won't be used if WarehouseLogistics = true
-- @gui installPolicy="mergeRows" editor="checkboxTable"
AllowedToCarrySupplies = {
	['P-51D-30-NA'] = true,
	['SpitfireLFMkIX'] = true,
	['MosquitoFBMkVI'] = true,
	['Bf-109K-4'] = true,
	['FW-190A8'] = true,
	['FW-190D9'] = true,
	['F4U-1D'] = true,
	['F4U-1D_CW'] = true,
	['I-16'] = true,
	['P-47D-30'] = true,
	['P-47D-30bl1'] = true,
	['P-47D-40'] = true,
	['P-51D'] = true,
	['SpitfireLFMkIXCW'] = true,
	['La-7'] = true,
}
-- ============================================================================
-- Shop / Rewards
-- ============================================================================

-- Shop prices.
-- @gui installPolicy="mergeRows"
ShopPrices = {
	smoke         = 20,   -- Smoke markers
    flare         = 20,   -- Flare markers
	illum         = 100,  -- Illumination bomb
	dynamiccap    = 500,  -- CAP Flight
	dynamiccas    = 1000, -- CAS Flight
	dynamicbomb   = 500,  -- Bomber Flight
	dynamicstatic = 500,  -- Static structure Flight
	supplies2     = 200,  -- Resupply friendly Zone
	supplies      = 1000, -- Fully Upgrade Friendly Zone
	capture       = 500,  -- Capture neutral zone
	advancecapture = 500, -- Advance capture pressured enemy zone
	intel         = 150,  -- Operational Intelligence (60 min)
	zinf          = 500,  -- Add infantry squad to zone
	zsam          = 1000, -- Add AA guns to a zone
	zarm          = 1000, -- Add armor group to a zone
	gslot         = 3000, -- Unlock extra upgrade slot
}

-- Shop ranks.
-- @gui installPolicy="mergeRows"
ShopRankRequirements = {
	dynamiccap     = 2,  -- CAP Flight
	dynamiccas     = 5,  -- CAS Flight
	dynamicbomb    = 4,  -- Bomber Flight
	dynamicstatic  = 4,  -- Static structure Flight
	capture        = 1,  -- Capture neutral zone
	advancecapture = 1, -- Advance capture pressured enemy zone
	smoke          = 1,  -- Smoke markers
	flare          = 1,  -- Flare markers
	illum          = 1,  -- Illumination bomb
	intel          = 5,  -- Operational Intelligence (60 min)
	supplies2      = 1,  -- Resupply friendly Zone
	supplies       = 6,  -- Fully Upgrade Friendly Zone
	zinf           = 5,  -- Add infantry squad to zone
	zsam           = 6,  -- Add AA guns to a zone
	zarm           = 7,  -- Add armor group to a zone
	gslot          = 9,  -- Unlock extra upgrade slot
}

-- Earning per kill by target type.
-- @gui installPolicy="mergeRows"
RewardContribution = {
	infantry         = 10,
	ground           = 10,
	sam              = 30,
	airplane         = 50,
	ship             = 200,
	helicopter       = 50,
	crate            = 100,
	rescue           = 200,
    structure        = 100,
	["Zone upgrade"] = 100,
	["Zone capture"] = 200,
    ["Warehouse delivery"] = 150,
}


-- If true, the AI attack groups will take off from ground instead of airspawn.
-- If false, AI will airspawn above friendly zone. Much faster engagements but less realistic.
AIAttackTakeoffFromGround = true
AIAttackTakeoffFromGroundExtraNM = 40 -- don't change this if you don't know what it is.

-- if false, people can not use "adminbuy:cap" or "adminbuy:capture". need to use "buy".
-- adminbuy is to bypass the rank filter and can be used from the f10 map all though not in slot.
AllowAdminBuy = true

-- If true, you can buy supplies upgrades and they will spawn right away.
-- If false, they will be delivered by helicopter.
AllowScriptedSupplies = false

-- ============================================================================
-- CSAR
-- ============================================================================

-- If 0, the CSAR menu won't appear.
-- CSAR allowed typeName: value is number of pilots that can be carried.
-- @gui label="Allowed CSAR Aircraft" installPolicy="mergeRows"
AllowedCsar = {
	['P-51D-30-NA'] = 1,
	['SpitfireLFMkIX'] = 1,
	['MosquitoFBMkVI'] = 1,
	['Bf-109K-4'] = 1,
	['FW-190A8'] = 1,
	['FW-190D9'] = 1,
	['F4U-1D'] = 1,
	['F4U-1D_CW'] = 1,
	['I-16'] = 1,
	['P-47D-30'] = 1,
	['P-47D-30bl1'] = 1,
	['P-47D-40'] = 1,
	['P-51D'] = 1,
	['SpitfireLFMkIXCW'] = 1,
	['La-7'] = 1,
    ['TF-51D'] = 1,
}

-- Chance (0-100) to spawn a downed pilot when the landing pilot has no credits. This applies both to players and AI.
CsarPilotSpawnWithoutCreditsChance = 50

-- Default pilot weight used for CSAR / this weight will be added to the helicopter.
PilotWeight = 80

-- Chance (0-100) that hostile infantry will spawn at a CSAR location.
CsarHostileInfantryChance = 25
-- ============================================================================
-- Flight Time
-- ============================================================================

-- Here you can customize flight time reward, this will reward the player for each minute they are airborne.
-- It will start counting after 5 minutes and will count the first 5 as valid flight minutes.
-- The idea is the reward the Logistics people for longer flight time.
RewardFlightTime = true
--
-- Here you can define how much credits for each minutes flown.
-- Note, when you land, you'll see  "15 + Flight time", the 15 are minutes, not credits.
FlightTimeRewardPerMinute = 2
--
-- If you want to reward all players no mater what aircraft, then set this to true, if set to false, you can choose who get the reward.
-- in the AllowedFlightTimeReward table below.
RewardAllAircraft = false


-- @gui label="Allowed Flight Time Reward" installPolicy="mergeRows" editor="checkboxTable"
AllowedFlightTimeReward = {
    ['P-51D-30-NA'] = true,
	['SpitfireLFMkIX'] = true,
	['MosquitoFBMkVI'] = true,
	['Bf-109K-4'] = true,
	['FW-190A8'] = true,
	['FW-190D9'] = true,
	['F4U-1D'] = true,
	['F4U-1D_CW'] = true,
	['I-16'] = true,
	['P-47D-30'] = true,
	['P-47D-30bl1'] = true,
	['P-47D-40'] = true,
	['P-51D'] = true,
	['SpitfireLFMkIXCW'] = true,
	['La-7'] = true,
    ['TF-51D'] = true,
}

-- ============================================================================
-- EWRS
-- ============================================================================

-- @gui validValues="Style 1=1 | Style 2=2"
ewrs_defaultReportStyle = 2 -- Default EWRS report format. Style 1 keeps the current format. Style 2 uses compact separator lines. Players can change this via the F10 EWRS menu.

-- @gui validValues="Modern=modern | WWII=wwii"
ewrs_altitudeDisplayMode = "wwii" -- EWRS altitude display. Modern shows exact altitude; WWII shows Low, Medium, or High using <5000 ft, 5000-9999 ft, and 10000+ ft.

-- Maximum detection range choices shown in the player F10 EWRS menu.
-- Valid values: 10 | 20 | 40 | 60 | 80 | 100 | 150
ewrs_maxRangeKm = 150 -- Highest metric EWRS detection range option shown in the F10 menu.

-- Maximum detection range choices shown in the player F10 EWRS menu.
-- Valid values: 5 | 10 | 20 | 40 | 60 | 80 | 100
ewrs_maxRangeNm = 100 -- Highest imperial EWRS detection range option shown in the F10 menu.

ewrs_defaultAircraftRangeLimit = 60 -- Default EWRS detection range for fixed-wing aircraft, using the selected measurement units.
ewrs_defaultHelicopterRangeLimit = 20 -- Default EWRS detection range for helicopters, using the selected measurement units.

ewrs_messageUpdateInterval = 20 -- How often EWRS will update automated BRA messages (seconds).
ewrs_messageDisplayTime = 15 -- How long EWRS BRA messages will show for (seconds).
ewrs_restrictToOneReference = false -- If true, players cannot switch between own-aircraft and bullseye BRA reference.

-- Valid values: "self" | "bulls"
ewrs_defaultReference = "self" -- Default BRA reference. "self" means the player's own aircraft.

-- Valid values: "imperial" | "metric"
ewrs_defaultMeasurements = "imperial" -- Default EWRS units. Players can change this via the F10 EWRS menu.
ewrs_defaultShowTankers = false -- Show tanker contacts by default in picture reports.
ewrs_enableRedTeam = true -- Enables EWRS for red coalition players.
ewrs_enableBlueTeam = true -- Enables EWRS for blue coalition players.
ewrs_disableMessageWhenNoThreats = true -- Hides automated "no threats detected" messages. Has no effect when on-demand mode is enabled.
ewrs_onDemand = false -- If true, disables automated EWRS reports and adds F10 request options instead.
ewrs_maxThreatDisplay = 5 -- Max threats shown in picture reports. Set to 0 to show all.
ewrs_allowBogeyDope = true -- Allows pilots to request closest-threat bogey dope even when automated reports are running.
ewrs_allowFriendlyPicture = true -- Allows pilots to request a friendly aircraft picture.
ewrs_maxFriendlyDisplay = 5 -- Max friendly aircraft shown in friendly picture reports. Set to 0 to show all.
ewrs_showType = true -- If true, EWRS reports aircraft type. If false, EWRS reports Unknown.
ewrs_mergedRangeNm = 5 -- Style 2 only. Hostile contacts under this range show Merged. Set to 0 to disable.
-- @gui installPolicy="mergeRows" editor="checkboxTable"
ewrs_specialPlaneTypes = { -- Aircraft typeNames that show friendlies by default. Players can still override this in their F10 EWRS menu.
    ['P-51D-30-NA'] = true,
	['SpitfireLFMkIX'] = true,
	['MosquitoFBMkVI'] = true,
	['Bf-109K-4'] = true,
	['FW-190A8'] = true,
	['FW-190D9'] = true,
	['F4U-1D'] = true,
	['F4U-1D_CW'] = true,
	['I-16'] = true,
	['P-47D-30'] = true,
	['P-47D-30bl1'] = true,
	['P-47D-40'] = true,
	['P-51D'] = true,
	['SpitfireLFMkIXCW'] = true,
	['La-7'] = true,
    ['TF-51D'] = true,
}
-- ============================================================================
-- AIEN
-- ============================================================================

AIEN = AIEN or {}
AIEN.config = AIEN.config or {}

AIEN.config.dontInitialize = false -- set to true to disable AIEN.

AIEN.config.blueAI 		        = true -- set to false to disable reactions for the blue coalition and their messages if they get hit by enemy.
AIEN.config.redAI			    = true -- set to false to disable reactions for the red coalition and their messages if they get hit by enemy.

AIEN.config.dismount 			= true -- set to false if you want trucks, APC not to dismount troops when hit but not killed.
AIEN.config.message_feed	    = true -- set to false if you want to disable the message feed when an AI get hit.

AIEN.config.initiative			= true -- set to false if you want to disable the initiative system where AI can move to the enemy if they detect one.

-- Increase these only if you have performance issues (start with Active, then Idle).
phaseCycleTimerMin = 0.2       -- Affects initialization only. Raise to 0.3-0.5 if init is spiking.
phaseCycleTimerActive = 0.04   -- Main runtime cadence when work is pending. Try 0.06-0.08.
phaseCycleTimerIdle = 0.5      -- Relaxed cadence when idle. Raise to 0.8-1.0 if needed.


-- ============================================================================
-- Aircraft
-- ============================================================================
-- Aircraft that remain available in Normandy/WW2 warehouse aircraft stocks.
-- @gui label="Allowed WW2 Warehouse Aircraft" installPolicy="mergeRows" editor="bucket"
AllowedWW2Planes = {
	"Bf-109K-4",
	"F4U-1D",
	"F4U-1D_CW",
	"FW-190A8",
	"FW-190D9",
	"I-16",
	"La-7",
	"MosquitoFBMkVI",
	"P-47D-30",
	"P-47D-30bl1",
	"P-47D-40",
	"P-51D",
	"P-51D-25-NA",
	"P-51D-30-NA",
	"SpitfireLFMkIX",
	"SpitfireLFMkIXCW",
	"TF-51D",
	"Yak-52",
	"Ju-88A4",
	"B-17G",
}

-- Don't touch this.
if externalConfigChunk then
    applyExternalConfigWithFallbackWarning()
    if FootholdLocalization then
        FootholdLocalization:SetLocale(FootholdLocale)
    end
    SCHEDULER:New(nil, function() trigger.action.outText("Loaded " .. saveFile .. " externally.", 30) end, {}, 1)
end

FootholdConfigLoadedOk = true

-- ============================================================================
-- End of Foothold Config
-- ============================================================================
