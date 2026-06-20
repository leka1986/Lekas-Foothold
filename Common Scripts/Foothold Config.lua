-- Version V1.0.7
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
-- Use Notepad++ and use compare tool to see the changes.
--
--
-- DO NOT TOUCH THIS BLOCK
--
local savePath = (lfs and lfs.writedir and (lfs.writedir() .. "Missions\\Saves")) or nil
local saveFile = "Foothold Config.lua"

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
        FootholdConfigLoaded = true
        chunk()
        FootholdConfigLoadedOk = true
        SCHEDULER:New(nil, function() trigger.action.outText("Loaded Foothold config externally.", 30) end, {}, 1)
        return
    else
        reportFootholdConfigLoadError(err)
    end
end
--
-- End of do not touch
--
-- ============================================================================
-- Mission Rules
-- ============================================================================
--
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
-- "Modern" or "Coldwar" ("Gulfwar" if the map is Iraq).
-- In the editor, Don't copy to all ships, make sure all planes in every warehouse are set to LIMITED!!!
Era = "Modern" -- does not work in Afghanistan or kola

-- ONLY VALID ON CAUCASUS, PERSIAN GULF, SYRIA AND AFGHANISTAN.
-- if false, the mission will start from the other end. Carrier zone will be disabled.
StartNormal = true
 
-- When the mission is completed, if you want the server to restart automatically and reset everything, then set this to true.
-- If false, you will have a menu where you can choose to restart the mission. 
AutoRestart = false

NoSA10AndSA11 = false -- If true: remove SA-10 and SA-11 (replaced by older SAMs).

-- There is no Pantsir or Tor M2 in the coldwar Era, but in modern, you can stil replace them.
NoTorM2AndPantsir = false -- If true: Pantsir and Tor M2 will be replaced with random groups, including SA-15, SA-19, SA-8 and SA-13.

NoSA15 = false -- If true: SA-15 will be replaced by random groups, including SA-19, SA-8, SA-13 and SA-9.

-- Modular, Automatic and Network capable Targeting and Interception System for Air Defenses. (MANTIS)
-- Once the player is within, the sam system will turn on. If you fire HARP, Talds or Jsaw, they will turn off and move.
-- Their movement depends if they are able to move, like the SA-6 and SA-11.
DisableMantis = false -- MANTIS is based on Early warning radars (EWR) for detectiion. they will be off until players are detected by the EWR.

-- ammo depots, fuel tanks, factories).
UseStatics = true -- If true, include some static target types at certain zones (command centers,

-- PVE_Only is a flag where you can decide if you want to disable players from spawning in red zones.
-- This is when the player chooses Red coalition.
PVE_Only = false -- If true, players can not spawn in red coalition zones.

 -- If true, Red side can use CTLD on a basic level.
Allow_Red_CTLD = false

-- If true, supports filling modded weapons via WarehouseLogistics
-- (not compatible with Coldwar/Gulfwar).
-- Keep in mind, adding mods midsession, while there is a save file, those weapons will not be added to current saved airbases.
-- this will be filled through time, from the AutoFillResources.
AllowMods = false -- Should NOT be used with coldwar era.

-- If true, when players die their coalition loses 100 credits per death.
CreditLosewhenKilled = false

-- If you want to change the amount, you can do it here.
CreditLosewhenKilledAmount = 100

-- If true, when players die they lose 100 rank credits (only if RankingSystem == true).
RankLoseWhenKilled = true

-- If you want to change the amount, you can do it here.
RankLoseWhenKilledAmount = 100

-- If true, loads enhanced bomb blast effects (may cause stutters).
SplashDamage = false

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

-- If true, A-10 is invisible to RED enemy planes.
InvisibleA10 = false

-- Some missions have carriers and those can be controlled to move to another place. 
-- If RankingSystem is true, then you can choose what level is required.
CarrierRankRequirement = 5

-- Works ONLY on Caucasus, Persian Gulf and Syria maps.
-- If true, blue players can move Tarawa with map marker commands.
-- tarawahere / tarawahereandstop sends Tarawa to the marker and stops there.
-- tarawahere1 followed by tarawahere2 creates a racetrack between the two marker positions.
-- tarawahelp displays the commands, or reports that Tarawa marker movement is disabled.
AllowTarawaToMoveFreely = false

-- If true, disables the friendly "Escort cargo plane" mission.
-- false keeps the mission enabled.
DisableFriendlyEscortMeMission = false

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

-- Chance in percent that RED AI air missions may also engage helicopters.
-- 0 disables helicopter targeting, 100 always allows it.
-- If InvisibleA10 is true, this setting is ignored.
ChanceAiAttackHelo = 0

-- Hunter is when you do a lot of damage to enemy units, RED dispatches a 2-ship to hunt you down.
EnableHunter = true

-- Valid: "Average", "Good", "High", "Excellent", "Random" (case-insensitive). Unknown values become "High".
AiPlaneSkill            = "Random" -- AI skill used for spawned airplanes Red only (MOOSE SPAWN:InitSkill).

-- Valid: "Average", "Good", "High", "Excellent", "Random" (case-insensitive). Unknown values become "High".
AiGroundSkill           = "Excellent" -- AI skill used for spawned non-airplane units Red and blue share the same config value (ground/ship/etc) (MOOSE SPAWN:InitSkill).

-- Controls whether SAM groups are hidden on MFDs.
-- Valid values only: false | true | "random"
-- false    = always shown on MFD
-- true     = always hidden on MFD (default)
-- "random" = 50% chance hidden on each spawn
HideSAMOnMFD = true -- if random, use "random" (string)

-- Valid values: "easy" | "medium" | "hard"
-- Here, you can adjust how many cap should spawn. medium, is the default (Balanaced)
CapDifficulty           = "medium" -- RED CAP amount.  This can be further custommized in the advance section.
CasDifficulty           = "medium" -- RED CAS amount.  This can be further custommized in the advance section.
SeadDifficulty          = "medium" -- RED SEAD amount.  This can be further custommized in the advance section.

FriendlyCapSupport      = "medium" -- BLUE CAP support limit. This can be further custommized in the advance section.
FriendlyCasSupport      = "medium" -- BLUE CAS support limit.  This can be further custommized in the advance section.
FriendlySeadSupport     = "medium" -- BLUE SEAD support limit.  This can be further custommized in the advance section.
RunwayStrikeDifficulty  = "medium" -- RED RUNWAYSTRIKE amount.  This can be further custommized in the advance section.

-- ============================================================================
-- Difficulty advanced
-- ============================================================================

-- The "amount" field in the case of CAP, 1 amount equals to 1 CAP Patrol and 1 CAP Attack. so 1 amount equal 2 groups.
-- players in the table below are counted as active players if they are not in the CapCountIgnoreTypes.
-- @gui label="RED CAP Limit"
-- @gui linkedSetting="CapDifficulty"
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
		{ player = 2,   amount = 2 },
		{ player = 3,   amount = 3 },
		{ player = 4,   amount = 3 },
		{ player = 6,   amount = 4 },
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
		{ player = 2,   amount = 2 },
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

-- Advance settings for SeadDifficulty..
-- Players in the table below are counted as active players if they are not in the RedCasCountIgnoreTypes.
-- The "amount" field in the table below is the amount of SEAD flights that can be active at the same time.
-- @gui label="RED SEAD Limit"
-- @gui linkedSetting="SeadDifficulty"
RedSeadLimitStages = {
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
		{ player = 1,   amount = 1 },
		{ player = 2,   amount = 1 },
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
-- players in the table below are counted as active players if they are not in the BlueCasCountIgnoreTypes.
-- The logic here, The less the players, the more AI will help you. The list in BlueCasCountIgnoreTypes, is types that doesn't count as active players.
-- Advance settings for FriendlySeadSupport.
-- @gui label="BLUE SEAD Support"
-- @gui linkedSetting="FriendlySeadSupport"
BlueSeadSupportStages = {
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

-- Units that will NOT be counted when calculating how many players are "active"
-- (used for CAP/CAS/SEAD scaling).
-- If you set a type to true, it will not be counting that player, because C-130 for example can't fight A/A. This will make
-- the Red CAP for example not spawn a jet for that player, because it's set to true in the ignore list.
-- SAME for the CAS. For the Blue cas, you want to be ignored if your flying C-130, so Blue cas WILL help you.
-- For the red CAS, they will NOT see you as a player so they will lay back and not spawn as often.
-- removing or adding more planes here will change the amount of cap since they will
-- be counted as active players or not.

CapCountIgnoreTypes = {
	["A-10C_2"] = true,
	["Hercules"] = true,
	["A-10A"] = true,
	["A-10C"] = true,
	["AV8BNA"] = true,
	["AJS37"] = true,
	["C-130J-30"] = true,
}

RedCasCountIgnoreTypes = {
	["Hercules"] = true,
	["C-130J-30"] = true,
	["CH-47Fbl1"] = true,
}

BlueCasCountIgnoreTypes = {
	["Hercules"] = true,
	["C-130J-30"] = true,
	["CH-47Fbl1"] = true,
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
-- @gui label="Welcome Message Callsigns"
CallsignOverrides = {
    ["F.A.18"] = {
        ["Arctic1"] = {1400, 1401, 1402, 1403},
        ["Bender2"] = {1404, 1405, 1406, 1407},
        ["Crimson3"] = {1410, 1411, 1412, 1413},
        ["Dusty4"] = {1300, 1301, 1302, 1303},
        ["Lion3"] = {1310, 1311, 1312, 1313},
    },
    ["F.16CM"] = {
        ["Indy9"] = {1500, 1501, 1502, 1503},
        ["Jester1"] = {1510, 1511, 1512, 1513},
        ["Venom4"] = {1610, 1611, 1612, 1613},
    },
    ["A.10C"] = {
        ["Hawg8"] = {1330, 1331, 1332, 1333},
        ["Tusk2"] = {1350, 1351, 1352, 1353},
        ["Pig7"] = {1340, 1341, 1342, 1343},
    },
    ["AH.64D"] = {
        ["Rage9"] = {1610, 1611, 1612, 1613},
        ["Salty1"] = {1620, 1621, 1622, 1623},
    },
    ["Ka.50.III"] = {
        ["Orca6"] = {1560, 1561, 1562, 1563},
    },
    ["AJS37"] = {
        ["Fenris6"] = {1060, 1061, 1062, 1063},
        ["Grim7"] = {1070, 1071, 1072, 1073},
    },
    ["UH.1H"] = {
        ["Nitro5"] = {1050, 1051, 1052, 1053},
    },
    ["CH.47F"] = {
        ["Greyhound3"] = {1370, 1371, 1372, 1373},
    },
    ["F.15E.S4"] = {
        ["Hitman3"] = {1360, 1361, 1362, 1363},
    },
    ["AV.8B"] = {
        ["Quarterback1"] = {1434, 1435, 1436, 1437},
    },
    ["M.2000"] = {
        ["Quebec8"] = {1600, 1601, 1602, 1603},
    },
    [".OH.58D"] = {
        ["Blackjack4"] = {1440, 1441, 1442, 1443},
    },
    ["F.14B"] = {
        ["Elvis5"] = {1100, 1101, 1102, 1103},
        ["Mustang4"] = {1104, 1105, 1106, 1107},
    },
    ["F.4E.45MC"] = {
        ["Savage1"] = {0120, 0121, 0122, 0123},
        ["Scary2"] = {0130, 0131, 0132, 0133},
    },
    ["MiG.29A.Fulcrum"] = {
        ["Wedge7"] = {0524, 0525, 0526, 0527},
    },
    ["Mi.24P"] = {
        ["Scorpion3"] = {0610, 0611, 0612, 0613},
    },
    ["C.130J.30"] = {
        ["Mighty1"] = {1160, 1161, 1162, 1163},
    },
}


-- ============================================================================
-- Escort
-- ============================================================================

-- Choose to have the option to get escorted by 2 jets. Recommended to A10 / C-130J, Harrier.
-- set to true for escort option available once spawned, false for no escort option.
-- escortType: 1 = Hornet (F-18C in Coldwar with AIM-7),
--             2 = Viper (F-15C in Coldwar with AIM-7)
--             3 = MIG29S with R-77 (MiG-29A in Coldwar with R-27ET)
-- @gui installPolicy="mergeRows"
EscortTypeByPlayerType = {
    ["C-130J-30"]      = { true, 1 },
    ["AV8BNA"]         = { true, 1 },
    ["A-10C_2"]        = { true, 1 },
    ["A-10C"]          = { true, 1 },
    ["A-10A"]          = { true, 1 },
    ["Hercules"]       = { true, 1 },
    ["F-15ESE"]        = { true, 2 },
    ["AJS37"]          = { true, 1 },
    ["MiG-29 Fulcrum"] = { false, 2 },
    ["F-16C_50"]       = { false, 2 },
    ["FA-18C_hornet"]  = { false, 2 },
    ["MiG-21Bis"]      = { false, 3 },
    ["Su-25T"]         = { false, 3 },
    ["Su-25"]          = { false, 3 },
    ["M-2000C"]        = { false, 2 },
    ["Bronco-OV-10A"]  = { false, 1 },
}

-- Plane escort option for takeoff from the ground.
EscortTakeoffFromGround = true -- If true, the escort will takeoff from the ground instead of airspawn.

-- ============================================================================
-- Logistics / Warehouse
-- ============================================================================

-- If true, logistics/supply is done via warehouse + zone supplies only.
-- You can only carry supplies using the rearming menu, then load cargo, not the ctld menu nor logistics menu.
-- Neutral zones start without weapons; you must bring them or wait for AI delivery.
WarehouseLogistics = true

-- If true, C-130J-30 AND Chinook! Use the internal (Ground crew for the Chinook and C-130 loading system only (not CTLD menu load).
UseC130LoadAndUnload = true -- need to be true if using Logisticsystem as the cargo need to be tracked.

-- How much AI delivery brings per supply run.
AIDeliveryamount = 20

-- If true, AI supply helicopters use cargo transport for warehouse deliveries.
SuppliesCargoTransport = true

-- If true, smart weapons found in the WarehouseWeaponCaps table at the bottom, will be HALF what we add to the warehouse.
-- This is to make the smart weapons harder to get.
StrictSmartWeaponsInventory = false

-- This table will be used if StrictSmartWeaponsInventory is set to true.
-- Smart weapons in this table will be HALF what we add to the warehouse.
WarehouseWeaponCaps = {
}

-- Every 15 minutes, BLUE zones gain this many resources (covers AI usage).
AutoFillResources = 5

-- If true, Blue AI will NOT deliver supplies, it will ONLY be done by the player.
NoAIBlueSupplies = false

-- This option is the legacy option. this won't be used if WarehouseLogistics = true
-- @gui installPolicy="mergeRows"
AllowedToCarrySupplies = {
    ["Ka-50"]         = false,
    ["Ka-50_3"]       = true,
    ["Mi-24P"]        = true,
    ["SA342Mistral"]  = false,
    ["SA342L"]        = false,
    ["SA342M"]        = false,
    ["SA342Minigun"]  = false,
    ["UH-60L"]        = true,
    ["UH-60L_DAP"]    = true,
    ["AH-64D_BLK_II"] = true,
    ["UH-1H"]         = true,
    ["Mi-8MT"]        = true,
    ["Hercules"]      = true,
    ["OH58D"]         = false,
    ["CH-47Fbl1"]     = true,
    ["Bronco-OV-10A"] = true,
    ["OH-6A"]         = true,
    ["C-130J-30"]     = true,
}

-- If false, the "Supplies not loaded" warning sound is disabled.
WarningNoSupplies = true

-- Aircraft that should receive the "Supplies not loaded" warning on takeoff.
-- Keep slingload-only aircraft set to false.
-- This does not mean supplies can now be carried.
-- This is if the aircraft can carry supplies, and no supplies is loaded, Then this will be a reminder.
-- @gui installPolicy="mergeRows"
ZoneSupplyTakeoffWarningTypes = {
    ["AH-64D_BLK_II"] = true,  -- This is for the legacy warehouse logistics or if you use troops to capture, with engineer.
    ["Bronco-OV-10A"] = true,  -- legacy mode
    ["C-130J-30"]     = true,
    ["CH-47Fbl1"]     = true,
    ["Ka-50_3"]       = true,  -- legacy mode
    ["MH-60R"]        = true,  -- legacy mode
    ["Mi-24P"]        = true,
    ["Mi-8MT"]        = true,
    ["OH-6A"]         = true,  -- legacy mode
    ["UH-1H"]         = true,
    ["UH-60L"]        = true,
    ["UH-60L_DAP"]    = true,
    ["AH-6J"]         = false,
    ["Ka-50"]         = false,
    ["MH-6J"]         = false,
    ["OH58D"]         = false,
    ["SA342L"]        = false,
    ["SA342M"]        = false,
    ["SA342Minigun"]  = false,
    ["SA342Mistral"]  = false,
    ["Hercules"]      = false,  -- should not be set to true if using WarehouseLogistics. can not detect that generic cargo
}

-- ============================================================================
-- Shop / Rewards
-- ============================================================================

-- Advance Capture becomes available when an enemy zone has this percent or less of its upgrade groups remaining.
-- Percent of upgrade groups remaining before Advance Capture appears.
-- This makes the capture of a zone quicker as the supply takes off prior.
-- @gui label="Advance Capture Threshold %" validValues="20%=20 | 25%=25 | 30%=30 | 35%=35 | 40%=40 | 45%=45 | 50%=50 | 55%=55 | 60%=60"
AdvanceCaptureRemainingThreshold = 50

-- Shop prices.
-- @gui installPolicy="mergeRows"
ShopPrices = {
	smoke         = 20,   -- Smoke markers
    flare         = 20,   -- Flare markers
	illum         = 100,  -- Illumination bomb
	dynamiccap    = 500,  -- CAP Flight
	dynamicarco   = 1000,  -- Dynamic Tanker (Drogue)
	dynamictexaco = 1000,  -- Dynamic Tanker (Boom)
	dynamiccas    = 1000, -- CAS Flight
	dynamicdecoy  = 300,  -- TALD DECOY Flight
	dynamicsead   = 500,  -- SEAD Flight
	groundattack  = 1000, -- Ground attack convoy
	dynamicbomb   = 500,  -- Bomber Flight
	dynamicstatic = 500,  -- Static structure Flight
	cruisemsl     = 800,  -- Cruise Missile Strike
	supplies2     = 200,  -- Resupply friendly Zone
	supplies      = 1000, -- Fully Upgrade Friendly Zone
	jtac          = 500,  -- MQ-9 Reaper JTAC mission
	["9lineam"]   = 0,    -- Jtac 9line AM
	["9linefm"]   = 0,    -- Jtac 9line FM
	jam           = 500,  -- Jam radars at zone
	armor         = 100,  -- Deploy armor
	artillery     = 100,  -- Deploy artillery
	recon         = 50,   -- Deploy recon group
	airdef        = 150,  -- Deploy air defence
	capture       = 500,  -- Capture neutral zone
	advancecapture = 500, -- Advance capture pressured enemy zone
	intel         = 150,  -- Intel on enemy zone
	zinf          = 500,  -- Add infantry squad to zone
	zsam          = 2000, -- Add Hawk/Nasams system to a zone
	zlogc         = 2000, -- Make a zone logistic center
	zwh50         = 500,  -- Resupply warehouse with 50
	zarm          = 1000, -- Add armor group to a zone
	zpat          = 5000, -- Add Patriot system to zone
	gslot         = 3000, -- Unlock extra upgrade slot
	farphere      = 1000, -- Deploy FARP
    zhimars       = 2500, -- Add HIMARS to a zone
}

-- Shop ranks.
-- @gui installPolicy="mergeRows"
ShopRankRequirements = {
	jtac           = 2,  -- MQ-9 Reaper JTAC mission
	dynamiccap     = 2,  -- CAP Flight
	dynamiccas     = 5,  -- CAS Flight
	dynamicbomb    = 4,  -- Bomber Flight
	dynamicsead    = 4,  -- SEAD Flight
	groundattack   = 5,  -- Ground attack convoy
	dynamicdecoy   = 1,  -- TALD DECOY Flight
	dynamicstatic  = 4,  -- Static structure Flight
	dynamicarco    = 3,  -- Dynamic Tanker (Drogue)
	dynamictexaco  = 3,  -- Dynamic Tanker (Boom)
	farphere       = 4,  -- Deploy FARP
	capture        = 1,  -- Capture neutral zone
	advancecapture = 1,  -- Advance capture pressured enemy zone
	smoke          = 1,  -- Smoke markers
	flare          = 1,  -- Flare markers
	illum          = 1,  -- Illumination bomb
	intel          = 5,  -- Intel on enemy zone
	supplies2      = 1,  -- Resupply friendly Zone
	supplies       = 6,  -- Fully Upgrade Friendly Zone
	zinf           = 5,  -- Add infantry squad to zone
	zarm           = 7,  -- Add armor group to a zone
	zsam           = 6,  -- Add Hawk/Nasams system to a zone
	zlogc          = 1,  -- Make a zone logistic center
	zwh50          = 2,  -- Resupply warehouse with 50
	gslot          = 9,  -- Unlock extra upgrade slot
	zpat           = 8,  -- Add Patriot system to zone
	armor          = 3,  -- Deploy armor
	artillery      = 3,  -- Deploy artillery
	recon          = 3,  -- Deploy recon group
	airdef         = 3,  -- Deploy air defence
	["9lineam"]    = 1,  -- Jtac 9line AM
	["9linefm"]    = 1,  -- Jtac 9line FM
	cruisemsl      = 10, -- Cruise Missile Strike -- This does not exist in some maps.
	jam            = 4,  -- Jam radars at zone
    zhimars        = 8,  -- Add HIMARS to a zone
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

-- Reward when done refueling, credits per 100 lbs.
RefuelReward = 2

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
-- CTLD
-- ============================================================================
--
-- If false, CTLD crates/units are free.
CTLDCost = true
--

-- This is the prices for each CTLD unit and their required rank. Rank 1 is the lowest.
-- @gui installPolicy="mergeRows"
CTLDPrices = {
  ["Engineer soldier"]       = { price = 50, reqRank = 1 },
  ["Squad 8"]                = { price = 50, reqRank = 1 },
  ["Platoon 16"]             = { price = 100, reqRank = 1 },
  ["Platoon 32"]             = { price = 200, reqRank = 1 },
  ["Anti-Air Soldiers"]      = { price = 100, reqRank = 1 },
  ["Mortar Squad"]           = { price = 100, reqRank = 1 },
  ["Mephisto"]               = { price = 250, reqRank = 2 },
  ["Humvee"]                 = { price = 250, reqRank = 1 },
  ["Bradly"]                 = { price = 250, reqRank = 1 },
  ["L118"]                   = { price = 150, reqRank = 1 },
  ["Ammo Truck"]             = { price = 100, reqRank = 1 },
  ["Humvee scout"]           = { price = 100, reqRank = 1 },
  ["Linebacker"]             = { price = 300, reqRank = 2 },
  ["Vulcan"]                 = { price = 300, reqRank = 2 },
  ["HAWK System"]            = { price = 750, reqRank = 3 },
  ["Hawk TR Add-on"]         = { price = 250, reqRank = 3 },
  ["Hawk SR Add-on"]         = { price = 250, reqRank = 3 },
  ["Hawk LN Add-on"]         = { price = 250, reqRank = 3 },
  ["NASAMS System"]          = { price = 750, reqRank = 3 },
  ["NASAMS C2 Add-on"]       = { price = 250, reqRank = 3 },
  ["NASAMS SR Add-on"]       = { price = 250, reqRank = 3 },
  ["NASAMS LN Add-on"]       = { price = 250, reqRank = 3 },
  ["FARP"]                   = { price = 500, reqRank = 1 },
  ["FARP with ZELL"]         = { price = 750, reqRank = 1 },
  ["IRIS T STR Add-on"]      = { price = 750, reqRank = 3 },
  ["IRIS T LN Add-on"]       = { price = 500, reqRank = 3 },
  ["IRIS T C2 Add-on"]       = { price = 500, reqRank = 3 },
  ["IRIS T System"]          = { price = 1800, reqRank = 3 },
  ["C-RAM"]                  = { price = 500, reqRank = 2 },
  ["HIMARS GMLRRS HE GUIDED"]= { price = 1000, reqRank = 3 },
  ["FV-107 Scimitar"]        = { price = 250, reqRank = 2 },
  ["FV-101 Scorpion"]        = { price = 250, reqRank = 2 },
  ["Avenger"]                = { price = 250, reqRank = 2 },
}

-- MAX_AT_SPAWN is how many units of each should load from the save file after the last session.
-- @gui installPolicy="mergeRows"
MAX_AT_SPAWN = {
    ["Engineer soldier"]        = 0,
    ["Mephisto"]                = 2,
    ["Humvee"]                  = 2,
    ["Bradly"]                  = 2,
    ["L118"]                    = 3,
    ["Ammo Truck"]              = 3,
    ["Humvee scout"]            = 1,
    ["Squad 8"]                 = 0,
    ["Platoon 16"]              = 0,
    ["Platoon 32"]              = 0,
    ["Anti-Air Soldiers"]       = 2,
    ["Mortar Squad"]            = 2,
    ["Linebacker"]              = 2,
    ["Vulcan"]                  = 2,
    ["HAWK System"]             = 3,
    ["Hawk TR Add-on"]          = 3,
    ["Hawk SR Add-on"]          = 3,
    ["Hawk LN Add-on"]          = 8,
    ["NASAMS System"]           = 3,
    ["NASAMS C2 Add-on"]        = 3,
    ["NASAMS SR Add-on"]        = 3,
    ["NASAMS LN Add-on"]        = 8,
    ["Tank Abrahams"]           = 0,
    ["FARP"]                    = 3,
    ["IRIS T STR Add-on"]       = 3,
    ["IRIS T LN Add-on"]        = 8,
    ["IRIS T C2 Add-on"]        = 3,
    ["IRIS T System"]           = 2,
    ["C-RAM"]                   = 4,
    ["HIMARS GMLRRS HE GUIDED"] = 4,
    ["FV-107 Scimitar"]         = 2,
    ["FV-101 Scorpion"]         = 2,
    ["Avenger"]                 = 2,
}

-- If true, engineers can capture/upgrade zones via CTLD.
-- If false, only regular troops can capture/upgrade zones.
CaptureZoneWithEngineer = false
--

-- MAX_SAVED_FARPS is how many farps should load from the save file after the last session.
MAX_SAVED_FARPS      = 3
--
-- IRIS merge behavior toggle.
-- true  = merge from full template (destroyed IRIS units can come back on merge).
-- false = merge from currently alive IRIS composition + the new added unit.
-- Note: this is session-only merge behavior; CTLD save/load logic is unchanged.
IRIS_RESTORE_UNIT_HEALTH_ON_MERGE = false

-- Define per-airframe CTLD load capabilities.
--
-- Each entry is:
--   { Cancrates, Cantroops, Cratelimit, Trooplimit, Length, Maxcargoweight }
--
-- Cancrates       = true/false  -- Can load CTLD crates.
-- Cantroops       = true/false  -- Can load CTLD troops.
-- Cratelimit      = number      -- Max number of crates this unit can carry.
-- Trooplimit      = number      -- Max number of troops this unit can carry.
-- Length          = number      -- Unit length (meters) used for load radius.
-- Maxcargoweight  = number      -- Max cargo weight (kg) this unit can carry.
--
-- CAUTION, CHANGING VALUES IN THE TABLE BELOW WILL MOSTLY HAVE NEGETIVE IMPACT ON THE CTLD CODE.
CTLDUnitCapabilities = {
    ["SA342Mistral"] = { false, true, 0, 2, 10, 400 },
    ["SA342L"] = { false, true, 0, 2, 10, 400 },
    ["SA342M"] = { false, true, 0, 2, 10, 400 },
    ["SA342Minigun"] = { false, true, 0, 2, 10, 400 },
    ["UH-1H"] = { true, true, 1, 8, 15, 800 },
    ["Mi-8MT"] = { true, true, 3, 16, 15, 6000 },
    ["Mi-8MTV2"] = { true, true, 3, 18, 15, 6000 },
    ["Ka-50"] = { false, false, 0, 0, 15, 400 },
    ["Ka-50_3"] = { false, false, 0, 0, 15, 400 },
    ["Mi-24P"] = { true, true, 2, 8, 15, 1000 },
    ["Mi-24V"] = { true, true, 2, 8, 15, 1000 },
    ["C-130J-30"] = { true, true, 7, 64, 35, 21500 },
    ["UH-60L"] = { true, true, 2, 20, 16, 3500 },
    ["UH-60L_DAP"] = { true, true, 2, 20, 16, 3500 },
    ["AH-64D_BLK_II"] = { false, false, 0, 0, 15, 400 },
    ["MH-60R"] = { true, true, 2, 20, 16, 3500 },
    ["CH-47Fbl1"] = { true, true, 5, 32, 20, 10800 },
    ["OH58D"] = { false, false, 0, 0, 14, 400 },
}

-- ============================================================================
-- CSAR
-- ============================================================================


-- If 0, the CSAR menu won't appear.
-- CSAR allowed typeName: value is number of pilots that can be carried.
-- @gui label="Allowed CSAR Aircraft" installPolicy="mergeRows"
AllowedCsar = {
    ["Ka-50"]         = 0,
    ["Ka-50_3"]       = 0,
    ["Mi-24P"]        = 8,
    ["SA342Mistral"]  = 3,
    ["SA342L"]        = 3,
    ["SA342M"]        = 3,
    ["SA342Minigun"]  = 3,
    ["UH-60L"]        = 11,
    ["UH-60L_DAP"]    = 11,
    ["AH-64D_BLK_II"] = 2,
    ["UH-1H"]         = 11,
    ["Mi-8MT"]        = 24,
    ["OH58D"]         = 1,
    ["CH-47Fbl1"]     = 32,
    ["Bronco-OV-10A"] = 5,
    ["OH-6A"]         = 2,
    ["C-130J-30"]     = 0,
    ["Hercules"]      = 0,
    ["MH-6J"]         = 4,
    ["AH-6J"]         = 4,
    ["MH-60R"]        = 10,
}

-- Chance (0-100) to spawn a downed pilot when the landing pilot has no credits. This applies both to players and AI.
CsarPilotSpawnWithoutCreditsChance = 50

-- Maximum number of downed pilot groups allowed on the map at once.
-- If a new CSAR pilot spawns after this limit is reached, the oldest pilot is removed.
Max_CSAR_At_Once = 10

-- Maximum number of saved downed pilot groups restored on mission load.
-- The newest pilots are kept first. If the save has more than this, the oldest saved pilots are skipped.
-- This value will never restore more than Max_CSAR_At_Once.
Max_CSAR_AT_Mission_Restart = 10

-- Default pilot weight used for CSAR / this weight will be added to the helicopter.
PilotWeight = 80

-- Distance (meters) from the survivor where the helicopter must hover.
CsarHoverDistance = 20

-- Distance where the pilot will be guided into position for hover pick up.
CsarGuidanceDistance = 70

-- Hover height (meters AGL) required to complete a CSAR pickup.
CsarHoverHeight = 60

-- How many seconds the helicopter must maintain the hover to complete pickup.
CsarHoverSeconds = 10

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
--
--
-- @gui installPolicy="mergeRows"
AllowedFlightTimeReward  = {
    ['Ka-50'] = false,
    ['Ka-50_3'] = false,
    ['Mi-24P'] = false,
    ['SA342Mistral'] = false,
    ['SA342L'] = false,
    ['SA342M'] = false,
    ['SA342Minigun'] = false,
    ['UH-60L'] = false,
    ['UH-60L_DAP'] = false,
    ['AH-64D_BLK_II'] = false,
    ['UH-1H'] = false,
    ['Mi-8MT'] = false,
    ['OH58D'] = false,
    ['Bronco-OV-10A'] = false,
    ['OH-6A'] = false,
    ['MH-6J'] = false,
    ['AH-6J'] = false,
    ['FA-18C_hornet'] = false,
	['F-16C_50'] = false,
	['F-14B'] = false,
	['MiG-29 Fulcrum'] = false,
	['C-130J-30'] = true,
	['CH-47Fbl1'] = true,
	['Hercules'] = true,
}

-- ============================================================================
-- Tankers
-- ============================================================================
-- Airforce tanker speed (knots)
TexacoSpeed = 286 -- orbit speed for texaco is hardcoded at 280, otherwise strange things happen.
-- Navy tanker speed (knots)
ArcoSpeed = 286 -- orbit speed for arco is hardcoded at 280, otherwise strange things happen.

-- ============================================================================
-- EWRS
-- ============================================================================

-- @gui validValues="Style 1=1 | Style 2=2"
ewrs_defaultReportStyle = 1 -- Default EWRS report format. Style 1 keeps the current format. Style 2 uses compact separator lines. Players can change this via the F10 EWRS menu.

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
-- @gui installPolicy="mergeRows"
ewrs_specialPlaneTypes = { -- Aircraft typeNames that show friendlies by default. Players can still override this in their F10 EWRS menu.
  ["F-4E-45MC"] = true,
  ["MiG-29 Fulcrum"] = true,
  ["F-5E-3_FC"] = true,
  ["C-130J-30"] = true,
}
ewrs_hiddenFriendlyReportingNames = { Sentry = true } -- Friendly reporting names hidden from friendly picture reports.

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
-- Aircraft / Weapons
-- ============================================================================
-- In this list, you can either remove or add what is allowed in the coldwar era.
-- @gui label="Allowed Aircraft" installPolicy="keepTable" editor="bucket"
allowedPlanes = {
    "A-10A",
    "A-10C",
    "A-10C_2",
    "A-4E-C",
    "AH-1W",
    "AH-64D_BLK_II",
    "AH-6J",
    "AJS37",
    "An-30M",
    "AV8BNA",
    "Bronco-OV-10A",
    "C-101CC",
    "C-130J-30",
    "CH-47Fbl1",
    "E-2C",
    "F/A-18A",
    "F-100D",
    "F-14A",
    "F-14A-135-GR",
    "F-14A-135-GR-Early",
    "F-14A-95-GR",
    "F-14B",
    "F-15C",
    "F-15E",
    "F-15ESE",
    "F-16A MLU",
    "F-16C_50",
    "F-4E-45MC",
    "F-5E-3",
    "F-5E-3_FC",
    "F-86F Sabre",
    "FA-18C_hornet",
    "Hercules",
    "Ka-27",
    "L-39C",
    "M-2000C",
    "MB-339A",
    "MB-339APAN",
    "MH-60R",
    "MH-6J",
    "Mi-24P",
    "Mi-24V",
    "Mi-28NE",
    "Mi-8MT",
    "MiG-15bis",
    "MiG-15bis_FC",
    "MiG-19P",
    "MiG-21Bis",
    "MiG-23MLD",
    "MiG-29 Fulcrum",
    "MiG-29A",
    "Mirage-F1AD",
    "Mirage-F1AZ",
    "Mirage-F1B",
    "Mirage-F1BD",
    "Mirage-F1BE",
    "Mirage-F1BQ",
    "Mirage-F1C",
    "Mirage-F1C-200",
    "Mirage-F1CE",
    "Mirage-F1CG",
    "Mirage-F1CH",
    "Mirage-F1CJ",
    "Mirage-F1CK",
    "Mirage-F1CR",
    "Mirage-F1CT",
    "Mirage-F1CZ",
    "Mirage-F1DDA",
    "Mirage-F1ED",
    "Mirage-F1EDA",
    "Mirage-F1EE",
    "Mirage-F1EH",
    "Mirage-F1EQ",
    "Mirage-F1M-CE",
    "Mirage-F1M-EE",
    "OH58D",
    "OH-6A",
    "P3C_Orion",
    "SA342L",
    "SA342M",
    "SA342Minigun",
    "SA342Mistral",
    "SU22",
    "Su-24MR",
    "Su-25",
    "UH-1H",
    "UH-60A",
    "UH-60L",
    "UH-60L_DAP",
}

-- In this list, you can either remove or add what is allowed for the (RED SIDE) in the coldwar era.
-- @gui label="Allowed RED Aircraft" installPolicy="keepTable" editor="bucket"
allowedPlanesRed = {
    "A-10A",
    "A-10C",
    "A-10C_2",
    "A-4E-C",
    "AH-1W",
    "AH-64D_BLK_II",
    "AH-6J",
    "AJS37",
    "An-30M",
    "AV8BNA",
    "Bronco-OV-10A",
    "C-101CC",
    "C-130J-30",
    "CH-47Fbl1",
    "E-2C",
    "F/A-18A",
    "F-100D",
    "F-14A",
    "F-14A-135-GR",
    "F-14A-135-GR-Early",
    "F-14A-95-GR",
    "F-14B",
    "F-15C",
    "F-15E",
    "F-15ESE",
    "F-16A MLU",
    "F-16C_50",
    "F-4E-45MC",
    "F-5E-3",
    "F-5E-3_FC",
    "F-86F Sabre",
    "FA-18C_hornet",
    "Hercules",
    "Ka-27",
    "L-39C",
    "M-2000C",
    "MB-339A",
    "MB-339APAN",
    "MH-60R",
    "MH-6J",
    "Mi-24P",
    "Mi-24V",
    "Mi-28NE",
    "Mi-8MT",
    "MiG-15bis",
    "MiG-15bis_FC",
    "MiG-19P",
    "MiG-21Bis",
    "MiG-23MLD",
    "MiG-29 Fulcrum",
    "MiG-29A",
    "Mirage-F1AD",
    "Mirage-F1AZ",
    "Mirage-F1B",
    "Mirage-F1BD",
    "Mirage-F1BE",
    "Mirage-F1BQ",
    "Mirage-F1C",
    "Mirage-F1C-200",
    "Mirage-F1CE",
    "Mirage-F1CG",
    "Mirage-F1CH",
    "Mirage-F1CJ",
    "Mirage-F1CK",
    "Mirage-F1CR",
    "Mirage-F1CT",
    "Mirage-F1CZ",
    "Mirage-F1DDA",
    "Mirage-F1ED",
    "Mirage-F1EDA",
    "Mirage-F1EE",
    "Mirage-F1EH",
    "Mirage-F1EQ",
    "Mirage-F1M-CE",
    "Mirage-F1M-EE",
    "OH58D",
    "OH-6A",
    "P3C_Orion",
    "SA342L",
    "SA342M",
    "SA342Minigun",
    "SA342Mistral",
    "SU22",
    "Su-24MR",
    "Su-25",
    "UH-1H",
    "UH-60A",
    "UH-60L",
    "UH-60L_DAP",
}
-- The list is applied if AllowMods are true and on Modern era.
-- Make sure you have the mods installed on the server and the client.
-- @gui label="Mods aircraft list" installPolicy="keepTable" editor="bucket"
restockAircraft = {
    "A-29B",
    "A-4E-C",
    "B-52H",
    "Bell-47",
    "Bronco-OV-10A",
    "EA-18G",
    "Eurofighter",
    "EurofighterT",
    "F111C",
    "F15EX",
    "F16A",
    "F16A_AA",
    "F-22A",
    "F-23A",
    "FA-18E",
    "FA-18ET",
    "FA-18F",
    "FA-18FT",
    "Hercules",
    "JAS39Gripen",
    "JAS39Gripen_AG",
    "JAS39Gripen_BVR",
    "M2000D",
    "Mi-28NE",
    "MiG-31BM",
    "SK-60",
    "SU22",
    "Su-25SM3",
    "Su-30MKA",
    "Su-30MKI",
    "Su-30MKM",
    "Su-30SM",
    "Su-35",
    "PUCARA",
    "Su-35S",
    "T-45",
}

-- In the coldwar era, you can add or remove what to restrict
-- Add "--" if you want to ALLOW a weapon, otherwise the weapon in the list below are removed from the warehouse.
-- @gui label="Cold War Restricted Weapons" installPolicy="keepTable" editor="bucket"
restrictedWeapons = {
    -- Apache Radar
    "weapons.containers.ah-64d_radar",
    -- Missiles
    "weapons.missiles.AIM_120C",
    "weapons.missiles.AIM_120",
    "weapons.missiles.AGM_154",
    "weapons.missiles.AIM_9X",
    "weapons.missiles.ADM_141B",
    "weapons.missiles.AGM_119",
    "weapons.missiles.AGM_130",
    "weapons.missiles.AGM_154A",
    "weapons.missiles.AGM_154B",
    "weapons.missiles.AGM_65G",
    "weapons.missiles.AGM_65H",
    "weapons.missiles.AGM_65K",
    "weapons.missiles.AGM_65L",
    "weapons.missiles.AGM_84E",
    "weapons.missiles.AGM_84H",
    "weapons.missiles.AGM_86C",
    "weapons.missiles.ALARM",
    "weapons.missiles.Ataka_9M120F",
    "weapons.missiles.Ataka_9M220",
    "weapons.missiles.Vikhr_M",
    "weapons.missiles.BK90_MJ1",
    "weapons.missiles.BK90_MJ2",
    "weapons.missiles.BK90_MJ1_MJ2",
    "weapons.missiles.BRM-1_90MM",
    "weapons.missiles.C_701T",
    "weapons.missiles.C_802AK",
    "weapons.missiles.CM-400AKG",
    "weapons.missiles.CM-802AKG",
    "weapons.missiles.DWS39_MJ1",
    "weapons.missiles.DWS39_MJ2",
    "weapons.missiles.DWS39_MJ1_MJ2",
    "weapons.missiles.GB-6",
    "weapons.missiles.GB-6-HE",
    "weapons.missiles.GB-6-SFW",
    "weapons.missiles.HJ-12",
    -- "weapons.missiles.HOT3_MBDA",
    "weapons.missiles.KD_20",
    "weapons.missiles.KD_63",
    "weapons.missiles.KD_63B",
    "weapons.missiles.LD-10",
    "weapons.missiles.LS_6",
    "weapons.missiles.LS_6_500",
    "weapons.missiles.MICA_R",
    "weapons.missiles.MICA_T",
    -- "weapons.missiles.Mistral",
    "weapons.missiles.PL-12",
    "weapons.missiles.PL-5EII",
    "weapons.missiles.PL-8B",
    "weapons.missiles.S_25L",
    "weapons.missiles.SD-10",
    "weapons.missiles.SPIKE_ER",
    "weapons.missiles.SPIKE_ER2",
    "weapons.missiles.TGM_65G",
    "weapons.missiles.TGM_65H",
    "weapons.missiles.X_35",
    "weapons.missiles.X_41",
    "weapons.missiles.X_59M",
    "weapons.missiles.YJ-12",
    "weapons.missiles.YJ-83",
    "weapons.containers.ALQ-184",
    "weapons.containers.alq-184long",
    -- "weapons.containers.AN_ASQ_228",
    "weapons.missiles.AGM_114L",
    "weapons.missiles.AGM_114",
    -- "weapons.missiles.AGM_114K",
    -- "weapons.missiles.AGM_65F",
    -- Bombs
    "weapons.bombs.GBU_31_V_4B",
    "weapons.bombs.CBU_105",
    "weapons.bombs.CBU_103",
    "weapons.bombs.CBU_97",
    "weapons.bombs.GBU_28",
    "weapons.bombs.GBU_31",
    "weapons.bombs.GBU_31_V_2B",
    "weapons.bombs.GBU_31_V_3B",
    "weapons.bombs.GBU_32_V_2B",
    "weapons.bombs.GBU_38",
    "weapons.bombs.GBU_39",
    "weapons.bombs.GBU_54_V_1B",
    "weapons.bombs.KAB_500S",
    "weapons.bombs.KAB_1500LG",
    "weapons.bombs.KAB_1500T",
    "weapons.bombs.LS_6_100",
    "weapons.bombs.GBU-43/B(MOAB)",
	"weapons.missiles.AGR_20A", -- laser rockets
	"weapons.missiles.AGR_20_M282"} -- laser rockets

-- This list can be used to add weapons you want to forbidd, This will forbidd all in the table in Modern era as well.
-- For coldwar, you can still rely on restrictedWeapons.
-- @gui label="Forbidden Weapons All Eras" editor="bucket"
ForbiddWeaponsInAllEra = {
    "weapons.bombs.RN-24", -- Nukes for the Mig-21
    "weapons.bombs.RN-28", -- Nukes for the Mig-21
    -- "weapons.containers.ah-64d_radar",
    -- Missiles
    -- "weapons.missiles.AIM_120C",
    -- "weapons.missiles.AIM_120",
    -- "weapons.missiles.AGM_154",
    -- "weapons.missiles.AIM_9X",
    -- "weapons.missiles.ADM_141B",
    -- "weapons.missiles.AGM_119",
    -- "weapons.missiles.AGM_130",
    -- "weapons.missiles.AGM_154A",
    -- "weapons.missiles.AGM_154B",
    -- "weapons.missiles.AGM_65G",
    -- "weapons.missiles.AGM_65H",
    -- "weapons.missiles.AGM_65K",
    -- "weapons.missiles.AGM_65L",
    -- "weapons.missiles.AGM_84E",
    -- "weapons.missiles.AGM_84H",
    -- "weapons.missiles.AGM_86C",
    -- "weapons.missiles.ALARM",
    -- "weapons.missiles.Ataka_9M120F",
    -- "weapons.missiles.Ataka_9M220",
    -- "weapons.missiles.Vikhr_M",
    -- "weapons.missiles.BK90_MJ1",
    -- "weapons.missiles.BK90_MJ2",
    -- "weapons.missiles.BK90_MJ1_MJ2",
    -- "weapons.missiles.BRM-1_90MM",
    -- "weapons.missiles.C_701T",
    -- "weapons.missiles.C_802AK",
    -- "weapons.missiles.CM-400AKG",
    -- "weapons.missiles.CM-802AKG",
    -- "weapons.missiles.DWS39_MJ1",
    -- "weapons.missiles.DWS39_MJ2",
    -- "weapons.missiles.DWS39_MJ1_MJ2",
    -- "weapons.missiles.GB-6",
    -- "weapons.missiles.GB-6-HE",
    -- "weapons.missiles.GB-6-SFW",
    -- "weapons.missiles.HJ-12",
    -- "weapons.missiles.HOT3_MBDA",
    -- "weapons.missiles.KD_20",
    -- "weapons.missiles.KD_63",
    -- "weapons.missiles.KD_63B",
    -- "weapons.missiles.LD-10",
    -- "weapons.missiles.LS_6",
    -- "weapons.missiles.LS_6_500",
    -- "weapons.missiles.MICA_R",
    -- "weapons.missiles.MICA_T",
    -- "weapons.missiles.Mistral",
    -- "weapons.missiles.PL-12",
    -- "weapons.missiles.PL-5EII",
    -- "weapons.missiles.PL-8B",
    -- "weapons.missiles.S_25L",
    -- "weapons.missiles.SD-10",
    -- "weapons.missiles.SPIKE_ER",
    -- "weapons.missiles.SPIKE_ER2",
    -- "weapons.missiles.TGM_65G",
    -- "weapons.missiles.TGM_65H",
    -- "weapons.missiles.X_35",
    -- "weapons.missiles.X_41",
    -- "weapons.missiles.X_59M",
    -- "weapons.missiles.YJ-12",
    -- "weapons.missiles.YJ-83",
    -- "weapons.containers.ALQ-184",
    -- "weapons.containers.alq-184long",
    -- "weapons.containers.AN_ASQ_228",
    -- "weapons.missiles.AGM_114L",
    -- "weapons.missiles.AGM_114",
    -- "weapons.missiles.AGM_114K",
    -- "weapons.missiles.AGM_65F",
    -- Bombs
    -- "weapons.bombs.GBU_31_V_4B",
    -- "weapons.bombs.CBU_105",
    -- "weapons.bombs.CBU_103",
    -- "weapons.bombs.CBU_97",
    -- "weapons.bombs.GBU_28",
    -- "weapons.bombs.GBU_31",
    -- "weapons.bombs.GBU_31_V_2B",
    -- "weapons.bombs.GBU_31_V_3B",
    -- "weapons.bombs.GBU_32_V_2B",
    -- "weapons.bombs.GBU_38",
    -- "weapons.bombs.GBU_39",
    -- "weapons.bombs.GBU_54_V_1B",
    -- "weapons.bombs.KAB_500S",
    -- "weapons.bombs.KAB_1500LG",
    -- "weapons.bombs.KAB_1500T",
    -- "weapons.bombs.LS_6_100",
    -- "weapons.bombs.GBU-43/B(MOAB)",
	-- "weapons.missiles.AGR_20A", -- laser rockets
	-- "weapons.missiles.AGR_20_M282" -- laser rockets
}

-- Don't touch this.
FootholdConfigLoadedOk = true

-- ============================================================================
-- End of Foothold Config
-- ============================================================================
