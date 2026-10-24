-- Version V1.0.9
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
-- Added support for Foothold WW2.lua. V1.0.8
-- Added Bunch off shit to the config. V1.0.9
-- Use Notepad++ and use compare tool to see the changes.
--
--
--
-- DO NOT TOUCH THIS BLOCK
--
local savePath = (lfs and lfs.writedir and (lfs.writedir() .. "Missions\\Saves")) or nil
local ww2Maps = {
    Normandy = true,
}
local saveFile = ww2Maps[env.mission.theatre] and "Foothold Config WW2.lua" or "Foothold Config.lua"
local mizConfigPath = ww2Maps[env.mission.theatre] and ("l10n/DEFAULT/" .. saveFile) or nil
local externalConfigChunk = nil
-- Add new top-level config tables here so an omitted external table triggers the warning.
FootholdConfigTrackedTableNames = {
    "AdminCommandAliases",
    "StartupFunds",
    "RedTemplateEnabled",
    "RedCapPlaneEnabled",
    "BlueCapPlaneEnabled",
    "RedCasPlaneEnabled",
    "BlueCasPlaneEnabled",
    "RedSeadPlaneEnabled",
    "BlueSeadPlaneEnabled",
    "RedRunwayStrikePlaneEnabled",
    "RedEnemyStrikePlaneEnabled",
    "RedCasHeloEnabled",
    "BlueCasHeloEnabled",
    "RedSupplyHeloEnabled",
    "BlueSupplyHeloEnabled",
    "CapLimitStages",
    "RedCasLimitStages",
    "RedSeadLimitStages",
    "RedRunwayStrikeLimitStages",
    "BlueCapSupportStages",
    "BlueCasSupportStages",
    "BlueSeadSupportStages",
    "CapCountIgnoreTypes",
    "RedCasCountIgnoreTypes",
    "BlueCasCountIgnoreTypes",
    "MessageOfTheDay",
    "CallsignOverrides",
    "EscortTypeByPlayerType",
    "WarehouseWeaponCaps",
    "AllowedToCarrySupplies",
    "ZoneSupplyTakeoffWarningTypes",
    "AvailableShopItems",
    "ShopPrices",
    "ShopRankRequirements",
    "RewardContribution",
    "CTLDPrices",
    "MAX_AT_SPAWN",
    "CTLDUnitCapabilities",
    "AllowedCsar",
    "AllowedFlightTimeReward",
    "ewrs_specialPlaneTypes",
    "allowedPlanes",
    "allowedPlanesSharedColdwarPvP",
    "allowedPlanesBlueColdwarPvP",
    "allowedPlanesRed",
    "allowedPlanesRedColdwarPvP",
    "allowedPlanesVietnam",
    "allowedPlanesSharedVietnamPvP",
    "allowedPlanesBlueVietnamPvP",
    "allowedPlanesRedVietnam",
    "allowedPlanesRedVietnamPvP",
    "allowedPlanesModern",
    "allowedPlanesRedModern",
    "restockAircraft",
    "restrictedWeapons",
    "restrictedWeaponsVietnam",
    "ForbiddWeaponsInAllEra",
}
-- Add new top-level scalar settings here so an omitted external setting triggers the warning.
FootholdConfigTrackedScalarNames = {
    "AdminCommands",
    "PvPSeparateAircraftLists",
    "ewrs_enabled",
    "PlayerZoneSuppliesConsumeStock",
    "RadioMenuStopSupplies",
    "ZoneCaptureBuildSeconds",
    "NormalSupplyCapacity",
    "WarehouseSupplyCapacity",
    "CTLDSupplyCapacity",
    "ExtraRedRepairTimeLowPlayerCountPercent",
}

local function applyExternalConfigWithFallbackWarning()
    local internalTableDefaults = {}
    for _, tableName in ipairs(FootholdConfigTrackedTableNames) do
        internalTableDefaults[tableName] = _G[tableName]
    end
    local trackedScalarNames = FootholdConfigTrackedScalarNames

    local externalAssignments = {}
    local externalEnvironment = setmetatable({}, {
        __index = _G,
        __newindex = function(_, key, value)
            externalAssignments[key] = true
            rawset(_G, key, value)
        end,
    })
    setfenv(externalConfigChunk, externalEnvironment)
    externalConfigChunk()
    setfenv(externalConfigChunk, _G)

    local missingConfigNames = {}
    for tableName, internalDefault in pairs(internalTableDefaults) do
        if _G[tableName] == internalDefault then
            missingConfigNames[#missingConfigNames + 1] = tableName
        end
    end
    for _, settingName in ipairs(trackedScalarNames) do
        if not externalAssignments[settingName] then
            missingConfigNames[#missingConfigNames + 1] = settingName
        end
    end
    if #missingConfigNames == 0 then return end
    table.sort(missingConfigNames)

    env.warning("[FOOTHOLD_CONFIG_EXTERNAL_OUTDATED] External Foothold config is outdated. Internal defaults were applied for: " .. table.concat(missingConfigNames, ", "))

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

if mizConfigPath and not FootholdConfigLoaded then
    local chunk, err = loadfile(mizConfigPath)
    if chunk then
        FootholdConfigLoaded = true
        chunk()
        if externalConfigChunk then
            FootholdConfigLoadedOk = nil
            applyExternalConfigWithFallbackWarning()
            if FootholdLocalization then
                FootholdLocalization:SetLocale(FootholdLocale)
            end
            SCHEDULER:New(nil, function() trigger.action.outText("Loaded " .. saveFile .. " externally.", 30) end, {}, 1)
        else
            SCHEDULER:New(nil, function() trigger.action.outText("Loaded " .. saveFile .. " from mission.", 30) end, {}, 1)
        end
        if env.mission.theatre ~= 'Caucasus' and env.mission.theatre ~= 'Syria' and env.mission.theatre ~= 'PersianGulf' then PvP = false end
        FootholdConfigLoadedOk = true
        return
    else
        reportFootholdConfigLoadError(err)
    end
end

if externalConfigChunk and not FootholdConfigLoaded then
    FootholdConfigLoaded = true
    FootholdConfigLoadedOk = nil
end
--
-- End of do not touch
--
-- ============================================================================
-- Mission Rules
-- ============================================================================

-- "Modern", "Coldwar", "Gulfwar" (Iraq Coldwar name), or "Vietnam".
-- In the editor, Don't copy to all ships, make sure all planes in every warehouse are set to LIMITED!!!
Era = "Modern"

-- Supported maps: Caucasus, Syria and Persian Gulf. Available in Modern, Coldwar and Vietnam.
-- @gui label="PvP"
PvP = false

-- ============================================================================
-- PvP settings
-- ============================================================================
-- Coalition credits at the start of a new/reset PvP round in Caucasus, Syria and Persian Gulf.
-- Enter an amount for each side; 0 starts that side without credits.
-- Existing campaigns retain their saved balances; restarting does not add these funds again.
-- @gui label="Startup Funds" visibleWhen="PvP:true" rowLabel="comment" installPolicy="mergeRows"
StartupFunds = {
    [1] = 1000, -- Red
    [2] = 1000, -- Blue
}

-- Starting share for EACH coalition; the selection shows Red, Blue and neutral percentages.
-- 20 =20% Red,20% Blue,60% neutral;30 =30% Red,30% Blue,40% neutral.
-- 40 =40% Red,40% Blue,20% neutral;50 divides all eligible territory between both sides.
-- Rounded to whole regular/SAM zones; applies to a new/reset PvP round, not an existing save.
-- @gui label="Starting Territory Per Coalition" visibleWhen="PvP:true" validValues="20% Red /20% Blue /60% neutral=20 | 30% Red /30% Blue /40% neutral=30 | 40% Red /40% Blue /20% neutral=40 | 50% Red /50% Blue /0% neutral=50"
PvPStartingTerritoryPercent = 50

-- @gui label="PvP AI Supplies" visibleWhen="PvP:true"
-- if true, Ai supplies on both sides will still run automated, otherwise only when bought.
-- @gui requiredValues="C-130J-30"
pvp_supplies = true


-- Enable the free two-fighter escort offer for eligible players on both sides in PvP.
-- @gui label="PvP Escorts" visibleWhen="PvP:true"
PvPEscorts = false

-- Chance in percent that AI air missions on either coalition may also engage enemy helicopters in PvP.
-- 0 disables helicopter targeting, 100 always allows it; InvisibleA10 takes precedence.
-- @gui label="PvP Chance AI Attack Helo" visibleWhen="PvP:true" disabledWhen="InvisibleA10:true"
PvPChanceAiAttackHelo = 0

-- Disable ordinary automatic combat flights for both coalitions. Paid support and supplies keep their own settings.
-- @gui label="Disable Automatic Combat AI" visibleWhen="PvP:true"
PvPDisableCombatAI = false

-- Positive values: total automatic fixed-wing combat groups per coalition, reduced by qualifying own player planes.
-- 0: balance player-plane counts, adding AI only to the side with fewer qualifying player planes.
-- Shared by combat roles; for example, 3 Blue players versus 1 Red allows up to 2 Red AI groups at 0.
-- @gui label="PvP Combat AI Group Limit" visibleWhen="PvP:true" disabledWhen="PvPDisableCombatAI:true"
PvPCombatAIGroupLimit = 10

-- ============================================================================
-- Mission Rules
-- ============================================================================
-- Choose which RED SAM templates are allowed when the mission replaces or randomizes SAM groups.
-- Untick a SAM type to prevent that template from being used.
-- @gui label="RED SAM templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select RED SAM templates based on Era?" installPolicy="replaceTable"
-- @gui untickRowsWhen="NoSA10AndSA11:true:SA-10|SA-11;NoTorM2AndPantsir:true:Tor M2|Pantsir S1;NoSA15:true:SA-15"
RedTemplateEnabled = {
    ["SA-2"] = true, -- eras=Modern|Coldwar|Vietnam; SA-2 [All]
    ["SA-3"] = true, -- eras=Modern|Coldwar|Vietnam; SA-3 [All]
    ["SA-5"] = true, -- eras=Modern|Coldwar; SA-5 [Modern/CW]
    ["SA-6"] = true, -- eras=Modern|Coldwar; SA-6 [Modern/CW]
    ["SA-8"] = true, -- eras=Modern|Coldwar; SA-8 [Modern/CW]
    ["SA-9"] = true, -- eras=Modern|Coldwar; SA-9 [Modern/CW]
    ["SA-13"] = true, -- eras=Modern|Coldwar; SA-13 [Modern/CW]
    ["SA-15"] = true, -- eras=Modern|Coldwar; SA-15 [Modern/CW]
    ["SA-19"] = true, -- eras=Modern|Coldwar; SA-19 [Modern/CW]
    ["SA-10"] = true, -- eras=Modern|Coldwar; SA-10 [Modern/CW]
    ["SA-11"] = true, -- eras=Modern|Coldwar; SA-11 [Modern/CW]
    ["Tor M2"] = true, -- eras=Modern; Tor M2 [Modern]
    ["Pantsir S1"] = true, -- eras=Modern; Pantsir S1 [Modern]
	["MANPAD"] = true, -- eras=Modern|Coldwar; MANPAD [Modern/CW]
}

-- AI aircraft templates used by missions that support config-driven template selection.
-- Rows with a checkmark are available for AI spawning.
-- @gui label="RED CAP Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable"
RedCapPlaneEnabled = {
    -- @gui requiredValues="MiG-29S"
    ["RED_MIG29S_CAP_R77x3_R27ET_R73x2"] = true, -- eras=Modern; MiG-29S Fox 3 CAP [Modern]
    -- @gui requiredValues="MiG-29S"
    ["RED_MIG29S_CAP_R77x2_R73x2_TANKSx3"] = true, -- eras=Modern; MiG-29S Fox 3 CAP [Modern]
    -- @gui requiredValues="Su-27"
    ["RED_SU27_CAP_R27Rx4_R27ER_R73x3_ECM"] = true, -- eras=Modern; Su-27 Fox 1 CAP [Modern]
    -- @gui requiredValues="Su-27"
    ["RED_SU27_CAP_R27ERx6_R73x2_ECM"] = true, -- eras=Modern; Su-27 Fox 1 CAP [Modern]
    -- @gui requiredValues="MiG-31"
    ["RED_MIG31_CAP_R33x4_R40Tx2"] = true, -- eras=Modern; MiG-31 Fox 1 CAP [Modern]
    -- @gui requiredValues="Mirage-F1CE"
    ["RED_MIRAGE_F1CE_CAP_S530Fx2_MAGIC2x2"] = true, -- eras=Modern|Coldwar; Mirage F1CE Fox 1 CAP [Modern/CW]
    -- @gui requiredValues="Mirage-F1CE"
    ["RED_MIRAGE_F1CE_CAP_R530F_EMx2_MAGIC2x2"] = true, -- eras=Modern|Coldwar; Mirage F1CE Fox 1 CAP [Modern/CW]
    -- @gui requiredValues="MiG-29 Fulcrum"
    ["RED_MIG29A_CAP_R73x4_R27R2x"] = true, -- eras=Modern|Coldwar; MiG-29A R-27R Fox 1 CAP [Modern/CW]
    -- @gui requiredValues="MiG-29 Fulcrum"
    ["RED_MIG29A_CAP_R73x4_R27ER2X"] = true, -- eras=Modern|Coldwar; MiG-29A R-27ER Fox 1 CAP [Modern/CW]
    -- @gui requiredValues="MiG-25PD"
    ["RED_MIG25PD_CAP_R40Rx2_R60Mx2"] = true, --eras=Modern|Coldwar; MiG-25PD Fox 1 CAP [Modern/CW]
    -- @gui requiredValues="Su-27"
    ["RED_SU27_CAP_R27ERx5_R73x3_ECM"] = true, -- eras=Modern|Coldwar; Su-27 Fox 1 CAP [Modern/CW]
    -- @gui requiredValues="MiG-23MLD"
    ["RED_MIG23MLD_CAP_R24Rx2_R60Mx2"] = true, -- eras=Modern|Coldwar; MiG-23MLD Fox 1 CAP [Modern/CW]
    -- @gui requiredValues="MiG-21Bis"
    ["RED_MIG21BIS_CAP_R3Rx4"] = false, -- eras=Coldwar|Vietnam; MiG-21bis Fox 1 CAP [CW/VN]
    -- @gui requiredValues="MiG-21Bis"
    ["RED_MIG21BIS_CAP_R3Rx2_R35x2"] = false, -- eras=Coldwar|Vietnam; MiG-21bis Fox 1 CAP [CW/VN]
    -- @gui requiredValues="MiG-15bis"
    ["RED_MIG15BIS_CAP_GUNS_TANKS"] = false, -- eras=Vietnam; MiG-15bis Guns CAP [VN]
    -- @gui requiredValues="MiG-19P"
    ["RED_MIG19P_CAP_K13A"] = false, -- eras=Vietnam; MiG-19P IR CAP [VN]
    -- @gui requiredValues="MiG-21Bis"
    ["RED_MIG21BIS_CAP_R3Rx2_R3Sx2"] = false, -- eras=Vietnam; MiG-21bis Fox 1 CAP [VN]
    -- @gui requiredValues="L-39C"
    ["RED_L39C_CAP_R3S2X"] = false, -- eras=Vietnam; L-39C Fox 2 CAP [VN]
}

-- @gui label="BLUE CAP Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable"
BlueCapPlaneEnabled = {
    -- @gui requiredValues="FA-18C_hornet"
    ["BLUE_FA18C_CAP_AIM120Cx6_AIM9Xx2"] = true, -- eras=Modern; F/A-18C Fox 3 CAP [Modern]
    -- @gui requiredValues="F-15C"
    ["BLUE_F15C_CAP_AIM120Bx3_AIM120Cx5"] = true, -- eras=Modern; F-15C Fox 3 CAP [Modern]
    -- @gui requiredValues="F-16C_50"
    ["BLUE_F16C_CAP_AIM120Bx4_AIM120C_AIM9M"] = true, -- eras=Modern; F-16C Fox 3 CAP [Modern]
    -- @gui requiredValues="F-16C_50"
    ["BLUE_F16_CAP_AIM120Cx5_AIM9Xx1"] = true, -- eras=Modern; 2x F-16C Fox 3 CAP [Modern]
    -- @gui requiredValues="F-14B"
    ["BLUE_F14B_CAP_AIM54A_MK47x4_AIM7Mx2_AIM9Mx2_TANKSx2"] = true, -- eras=Modern|Coldwar; F-14B AIM54A-MK47 [Modern/CW]
    -- @gui requiredValues="F-14B"
    ["BLUE_F14B_CAP_AIM54C_MK47x4_AIM7Mx2_AIM9Mx2_TANKSx2"] = true, -- eras=Modern|Coldwar; F-14B AIM54C-MK47 [Modern/CW]
    -- @gui requiredValues="F-14B"
    ["BLUE_F14B_CAP_AIM54C_MK60x4_AIM7Mx2_AIM9Mx2_TANKSx2"] = true, -- eras=Modern|Coldwar; F-14B AIM54C-MK60 [Modern/CW]
    -- @gui requiredValues="M-2000C"
    ["BLUE_M2000C_CAP_S530Dx2_MAGIC2x2"] = true, -- eras=Modern|Coldwar; M-2000C Fox 1 CAP [Modern/CW]
    -- @gui requiredValues="FA-18C_hornet"
    ["BLUE_FA18C_CAP_AIM7Mx6_AIM9Mx2"] = false, -- eras=Coldwar; F/A-18C Fox 1 CAP [CW]
    -- @gui requiredValues="F-15C"
    ["BLUE_F15C_CAP_AIM7Mx4_AIM9Mx4"] = false, -- eras=Coldwar; F-15C Fox 1 CAP [CW]
    -- @gui requiredValues="F-14A-135-GR"
    ["BLUE_F14A_CAP_AIM54A_MK47x6_AIM9Mx2_TANKSx2"] = false, -- eras=Coldwar; F-14A AIM54A-MK47x6 [CW]
    -- @gui requiredValues="F-14A-135-GR"
    ["BLUE_F14A_CAP_AIM54A_MK47x2_AIM7Fx3_AIM9Lx2_TANKSx2"] = false, -- eras=Coldwar; F-14A AIM54A-MK47/AIM7F [CW]
    -- @gui requiredValues="F-4E-45MC"
    ["BLUE_F4E_CAP_AIM7E2x4_AIM9Jx4_TANKSx3_ALE40"] = false, -- eras=Vietnam|Coldwar; F-4E Fox 1 CAP [VN/CW]
    -- @gui requiredValues="F-100D"
    ["BLUE_F100D_CAP_AIM9Ex2"] = false, -- eras=Vietnam; F-100D IR CAP [VN]
    -- @gui requiredValues="F-5E-3"
    ["BLUE_F5E3_CAP_AIM9Bx2"] = false, -- eras=Vietnam; F-5E-3 IR CAP [VN]
    -- @gui requiredValues="F-86F_FC"
    ["BLUE_F86F_CAP_GAR8x2"] = false, -- eras=Vietnam; F-86F IR CAP [VN]
}

-- @gui label="RED CAS Plane Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable"
RedCasPlaneEnabled = {
    -- @gui requiredValues="Su-25T"
    ["RED_SU25T_CAS_KH25MPx2_VIKHRx2_KH29Tx2_1SHIP"] = true, -- eras=Modern; Su-25T CAS [Modern]
    -- @gui requiredValues="Su-25T"
    ["RED_SU25T_CAS_KH25MLx4_KH29Tx2_1SHIP"] = true, -- eras=Modern; Su-25T CAS [Modern]
    -- @gui requiredValues="Su-25T"
    ["RED_SU25T_CAS_VIKHRx2_FAB500M62x2_KH29Tx2_1SHIP"] = true, -- eras=Modern; Su-25T CAS [Modern]
    -- @gui requiredValues="Su-25T"
    ["RED_SU25T_CAS_KH25MPx2_VIKHRx2_KH29Tx2_2SHIP"] = true, -- eras=Modern; 2x Su-25T CAS [Modern]
    -- @gui requiredValues="Su-25T"
    ["RED_SU25T_CAS_KH25MLx4_KH29Tx2_2SHIP"] = true, -- eras=Modern; 2x Su-25T CAS [Modern]
    -- @gui requiredValues="Su-25T"
    ["RED_SU25T_CAS_VIKHRx2_FAB500M62x2_KH29Tx2_2SHIP"] = true, -- eras=Modern; 2x Su-25T CAS [Modern]
    -- @gui requiredValues="MiG-21Bis"
    ["RED_MIG21BIS_CAS_RBK250x2_UB32x2_1SHIP"] = true, -- eras=Modern; MiG-21bis CAS [Modern]
    -- @gui requiredValues="MiG-21Bis"
    ["RED_MIG21BIS_CAS_RBK250x2_UB32x2_2SHIP"] = true, -- eras=Modern; 2x MiG-21bis CAS [Modern]
    -- @gui requiredValues="Su-25"
    ["RED_SU25_CAS_KH25ML_S25Lx2_FAB500M62x2_B8x2_SPPU_1SHIP"] = false, -- eras=Coldwar; Su-25 CAS [CW]
    -- @gui requiredValues="Su-25"
    ["RED_SU25_CAS_FAB250x2_FAB500M62x2_B8x2_S24Bx2_1SHIP"] = false, -- eras=Coldwar; Su-25 CAS [CW]
    -- @gui requiredValues="Su-25"
    ["RED_SU25_CAS_KH25MLx2_S25Lx2_FAB500M62x2_B13x2_1SHIP"] = false, -- eras=Coldwar; Su-25 CAS [CW]
    -- @gui requiredValues="Su-25"
    ["RED_SU25_CAS_KH25ML_S25Lx2_FAB500M62x2_B8x2_SPPU_2SHIP"] = false, -- eras=Coldwar; 2x Su-25 CAS [CW]
    -- @gui requiredValues="Su-25"
    ["RED_SU25_CAS_FAB250x2_FAB500M62x2_B8x2_S24Bx2_2SHIP"] = false, -- eras=Coldwar; 2x Su-25 CAS [CW]
    -- @gui requiredValues="Su-25"
    ["RED_SU25_CAS_KH25MLx2_S25Lx2_FAB500M62x2_B13x2_2SHIP"] = false, -- eras=Coldwar; 2x Su-25 CAS [CW]
    -- @gui requiredValues="Mirage-F1BQ"
    ["RED_MIRAGE_F1BQ_CAS_SAMP400x2_SAMP250x2_2SHIP"] = true, -- eras=Modern|Coldwar; 2x Mirage F1BQ CAS [Modern/CW]
    -- @gui requiredValues="Mirage-F1BQ"
    ["RED_MIRAGE_F1BQ_CAS_MIXED_SNEB_SAMP_2SHIP"] = true, -- eras=Modern|Coldwar; 2x Mirage F1BQ CAS [Modern/CW]
    -- @gui requiredValues="MiG-21Bis"
    ["RED_MIG21BIS_CAS_S24Bx4_1SHIP"] = false, -- eras=Coldwar; MiG-21bis S-24B CAS [CW]
    -- @gui requiredValues="MiG-21Bis"
    ["RED_MIG21BIS_CAS_S24Bx4_2SHIP"] = false, -- eras=Coldwar; 2x MiG-21bis S-24B CAS [CW]
    -- @gui requiredValues="MiG-21Bis"
    ["RED_MIG21BIS_CAS_KH66x2_FAB250x2_1SHIP"] = false, -- eras=Vietnam; MiG-21bis Kh-66 CAS [VN]
    -- @gui requiredValues="MiG-21Bis"
    ["RED_MIG21BIS_CAS_KH66x2_FAB250x2_2SHIP"] = false, -- eras=Vietnam; 2x MiG-21bis Kh-66 CAS [VN]
    -- @gui requiredValues="MiG-15bis"
    ["RED_MIG15BIS_CAS_FAB100Mx2_1SHIP"] = false, -- eras=Vietnam; MiG-15bis Bomb CAS [VN]
    -- @gui requiredValues="MiG-15bis"
    ["RED_MIG15BIS_CAS_FAB100Mx2_2SHIP"] = false, -- eras=Vietnam; 2x MiG-15bis Bomb CAS [VN]
    -- @gui requiredValues="MiG-19P"
    ["RED_MIG19P_CAS_K13Ax2_ORO57Kx2_PTB760x2_1SHIP"] = false, -- eras=Vietnam; MiG-19P Rocket CAS [VN]
    -- @gui requiredValues="MiG-19P"
    ["RED_MIG19P_CAS_K13Ax2_ORO57Kx2_PTB760x2_2SHIP"] = false, -- eras=Vietnam; 2x MiG-19P Rocket CAS [VN]
    -- @gui requiredValues="MiG-19P"
    ["RED_MIG19P_CAS_K13Ax2_FAB250x2_ORO57Kx2_1SHIP"] = false, -- eras=Vietnam; MiG-19P Bomb CAS [VN]
    -- @gui requiredValues="MiG-19P"
    ["RED_MIG19P_CAS_K13Ax2_FAB250x2_ORO57Kx2_2SHIP"] = false, -- eras=Vietnam; 2x MiG-19P Bomb CAS [VN]
    -- @gui requiredValues="L-39C"
    ["RED_L39C_CAS_S5M2XHE_1SHIP"] = false, -- eras=Vietnam; L-39C Rockets CAS [VN]
    -- @gui requiredValues="L-39C"
    ["RED_L39C_CAS_S5M2XHE_2SHIP"] = false, -- eras=Vietnam; 2x L-39C Rockets CAS [VN]
    -- @gui requiredValues="L-39C"
    ["RED_L39C_CAS_FAB100Mx2_1SHIP"] = false, -- eras=Vietnam; L-39C Bomb CAS [VN]
    -- @gui requiredValues="L-39C"
    ["RED_L39C_CAS_FAB100Mx2_2SHIP"] = false, -- eras=Vietnam; 2x L-39C Bomb CAS [VN]

}

-- @gui label="BLUE CAS Plane Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable"
BlueCasPlaneEnabled = {
    -- @gui requiredValues="F-4E-45MC"
    ["BLUE_F4E_CAS_WALLEYEIIx2_GBU12x2_PAVESPIKE_2SHIP"] = true, -- eras=Modern|Coldwar; 2x F-4E Guided CAS [Modern/CW]
    -- @gui requiredValues="F-4E-45MC"
    ["BLUE_F4E_CAS_AGM65Dx6_GBU12x2_PAVESPIKE_2SHIP"] = true, -- eras=Modern|Coldwar; 2x F-4E Maverick CAS [Modern/CW]
    -- @gui requiredValues="F-16C_50"
    ["BLUE_F16_CAS_AGM65Dx4_GBU12x2_PAVESPIKE_2SHIP"] = true, -- eras=Modern; 2x F-16C Maverick CAS [Modern]
    -- @gui requiredValues="F-86F Sabre"
    ["BLUE_F86F_CAS_AIM9Bx2_HVARx8_TANKSx2_2SHIP"] = false, -- eras=Vietnam; 2x F-86F Rocket CAS [VN]
    -- @gui requiredValues="F-86F Sabre"
    ["BLUE_F86F_CAS_AIM9Bx2_M117x2_2SHIP"] = false, -- eras=Vietnam; 2x F-86F M117 CAS [VN]
    -- @gui requiredValues="F-4E-45MC"
    ["BLUE_F4E_CAS_M117x12_AIM7E2x3_TANKSx2_ALQ131"] = false, -- eras=Vietnam|Coldwar; 2x F-4E M117 CAS [VN/CW]
    -- @gui requiredValues="F-4E-45MC"
    ["BLUE_F4E_CAS_AGM12Bx2_AIM7E2x3_TANK600_ALQ131"] = false, -- eras=Vietnam|Coldwar; 2x F-4E Bullpup CAS [VN/CW]
    -- @gui requiredValues="F-4E-45MC"
    ["BLUE_F4E_CAS_WALLEYEIx4_TANK600_ALQ131"] = false, -- eras=Vietnam|Coldwar; F-4E Walleye I CAS [VN/CW]
    -- @gui requiredValues="F-4E-45MC"
    ["BLUE_F4E_CAS_WALLEYEIx2_AGM65Ax4_TANK600_ALQ131"] = false, -- eras=Vietnam|Coldwar; F-4E Guided CAS [Late VN/CW]
    -- @gui requiredValues="F-100D"
    ["BLUE_F100D_CAS_MK82x8_TANKSx2_2SHIP"] = false, -- eras=Vietnam; 2x F-100D Mk-82 CAS [VN]
    -- @gui requiredValues="F-100D"
    ["BLUE_F100D_CAS_M117x6_TANKSx2_2SHIP"] = false, -- eras=Vietnam; 2x F-100D M117 CAS [VN]
    -- @gui requiredValues="F-5E-3"
    ["BLUE_F5E3_CAS_MK82LDx4_AIM9Bx2_TANK275_2SHIP"] = false, -- eras=Vietnam; 2x F-5E-3 Mk-82 CAS [VN]
    -- @gui requiredValues="F-5E-3"
    ["BLUE_F5E3_CAS_MK82SEx4_AIM9Bx2_TANK275_2SHIP"] = false, -- eras=Vietnam; 2x F-5E-3 Snakeye CAS [VN]
}

-- @gui label="RED SEAD Plane Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable"
RedSeadPlaneEnabled = {
    -- @gui requiredValues="JF-17"
    ["RED_JF17_SEAD_LD10x2_PL5EIIx2_SPJ_TANKSx2_1SHIP"] = true, -- eras=Modern; JF-17 SEAD [Modern]
    -- @gui requiredValues="JF-17"
    ["RED_JF17_SEAD_LD10x2_PL5EIIx2_SPJ_TANKSx2_2SHIP"] = true, -- eras=Modern; 2x JF-17 SEAD [Modern]
    -- @gui requiredValues="Su-25T"
    ["RED_SU25T_SEAD_KH58Ux2_KH25MPU_S24B_B13x2_R73x2_1SHIP"] = true, -- eras=Modern; Su-25T SEAD [Modern]
    -- @gui requiredValues="Su-25T"
    ["RED_SU25T_SEAD_KH58Ux2_KH25MPU_S24B_B13x2_R73x2_2SHIP"] = true, -- eras=Modern; 2x Su-25T SEAD [Modern]
    -- @gui requiredValues="Su-34"
    ["RED_SU34_SEAD_KH31Px4_R77x2_R27Rx2_R73x2_1SHIP"] = true, -- eras=Modern; Su-34 SEAD [Modern]
    -- @gui requiredValues="Su-34"
    ["RED_SU34_SEAD_KH31Px2_KH58Ux2_BETAB500SHP_R27ERx2_R27R_R73x2_1SHIP"] = true, -- eras=Modern; Su-34 SEAD [Modern]
    -- @gui requiredValues="Su-34"
    ["RED_SU34_SEAD_KH31Px4_R77x2_R27Rx2_R73x2_2SHIP"] = true, -- eras=Modern; 2x Su-34 SEAD [Modern]
    -- @gui requiredValues="Su-34"
    ["RED_SU34_SEAD_KH31Px2_KH58Ux2_BETAB500SHP_R27ERx2_R27R_R73x2_2SHIP"] = true, -- eras=Modern; 2x Su-34 SEAD [Modern]
    -- @gui requiredValues="Su-24M"
    ["RED_SU24M_SEAD_KH58x2_FAB1500M54_L081_R60Mx4_2SHIP"] = true, -- eras=Modern|Coldwar; 2x Su-24M SEAD [Modern/CW]
    -- @gui requiredValues="Su-24M"
    ["RED_SU24M_SEAD_KH31Px2_KH25MLx2_FAB1500M54_L081_1SHIP"] = true, -- eras=Modern|Coldwar; Su-24M SEAD [Modern/CW]
    -- @gui requiredValues="Su-17M4"
    ["RED_SU17M4_SEAD_KH25MRx4_R60x2_TANKSx2_1SHIP"] = false, -- eras=Vietnam|Coldwar; Su-17M4 SEAD [CW/VN]
    -- @gui requiredValues="Su-17M4"
    ["RED_SU17M4_SEAD_KH25MRx4_R60x2_TANKSx2_2SHIP"] = false, -- eras=Vietnam|Coldwar; 2x Su-17M4 SEAD [CW/VN]
}

-- @gui label="BLUE SEAD Plane Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable"
BlueSeadPlaneEnabled = {
    -- @gui requiredValues="F-16C_50"
    ["BLUE_F16_SEAD_AGM88Cx4_AIM120Cx2_AIM9Xx2"] = true, -- eras=Modern; 2x F-16C SEAD [Modern]
    -- @gui requiredValues="FA-18C_hornet"
    ["BLUE_F18_SEAD_AGM88Cx2_ADM141Ax6_AIM120Cx1_AIM9Xx2"] = true, -- eras=Modern; 2x F/A-18C SEAD [Modern]
    -- @gui requiredValues="FA-18C_hornet"
    ["BLUE_F18_SEAD_AGM88Cx2_AGM154CAx4_AIM120Cx1_AIM9Xx2"] = true, -- eras=Modern; 2x F/A-18C SEAD [Modern]
    -- @gui requiredValues="F-4E-45MC"
    ["BLUE_F4E_SEAD_AGM45Ax4_AIM7E2x3_TANK600_ALQ131"] = false, -- eras=Vietnam|Coldwar; 2x F-4E Shrike SEAD [VN/CW]
    -- @gui requiredValues="F-100D"
    ["BLUE_F100D_SEAD_AGM45Ax2_CBU7x2_TANKSx2_2SHIP"] = false, -- eras=Vietnam; 2x F-100D SEAD [VN]
}

-- @gui label="RED Runway Strike Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable"
RedRunwayStrikePlaneEnabled = {
    -- @gui requiredValues="Su-33"
    ["RED_SU33_RUNWAY_BETAB500x4_R27ERx4_R73x2_3SHIP"] = true, -- eras=Modern; 3x Su-33 Runway [Modern]
    -- @gui requiredValues="MiG-27K"
    ["RED_MIG27K_RUNWAY_BETAB500x2_FAB250x2_R60Mx4_3SHIP"] = true, -- eras=Modern|Coldwar; 3x MiG-27K Runway [Modern/CW]
    -- @gui requiredValues="Mirage-F1EE"
    ["RED_MIRAGE_F1EE_RUNWAY_DURANDALx6_S530Fx2_AIM9JULIx2_3SHIP"] = true, -- eras=Modern|Coldwar; 3x Mirage F1EE Runway [Modern/CW]
    -- @gui requiredValues="MiG-21Bis"
    ["RED_MIG21BIS_RUNWAY_BETAB500x2_R3Rx2_TANK490_3SHIP"] = false, -- eras=Vietnam; 3x MiG-21bis BetAB Runway [VN]
}

-- @gui label="RED Enemy Strike Plane Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable" disabledWhen="PvP:true"
RedEnemyStrikePlaneEnabled = {
    ["evt-attack"] = true, -- eras=Modern; 3x Su-34 Enemy Strike (each: 4x Kh-29T, 2x Kh-31P, 2x R-27ER, 2x R-73, 2x L-175V ECM) [Modern]
    ["evt-attackcw"] = true, -- eras=Modern|Coldwar; 3x Su-24M Enemy Strike (each: 2x Kh-25MPU, 2x KAB-500Kr, 2x R-60M, L-081 ELINT) [Modern/CW]
}

-- @gui label="RED CAS Helo Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable"
RedCasHeloEnabled = {
    -- @gui requiredValues="Mi-24P"
    ["RED_MI24P_CAS_9M114x8_B8x2_1SHIP"] = true, -- eras=Modern; Mi-24P CAS [Modern]
    -- @gui requiredValues="Mi-24P"
    ["RED_MI24P_CAS_9M114x8_B8x2_2SHIP"] = true, -- eras=Modern; 2x Mi-24P CAS [Modern]
    -- @gui requiredValues="Mi-24P"
    ["RED_MI24P_CAS_B13Lx2_B8x2_1SHIP"] = true, -- eras=Modern; Mi-24P B-13L/B-8 rocket CAS [Modern]
    -- @gui requiredValues="Mi-24P"
    ["RED_MI24P_CAS_B13Lx2_B8x2_2SHIP"] = true, -- eras=Modern; 2x Mi-24P B-13L/B-8 rocket CAS [Modern]
    -- @gui requiredValues="Mi-28N"
    ["RED_MI28N_CAS_9M120x8_9M120Fx8_B13x2_1SHIP"] = true, -- eras=Modern; Mi-28N CAS [Modern]
    -- @gui requiredValues="Mi-28N"
    ["RED_MI28N_CAS_9M114x8_B8x2_1SHIP"] = true, -- eras=Modern; Mi-28N CAS [Modern]
    -- @gui requiredValues="Mi-28N"
    ["RED_MI28N_CAS_9M114x8_B8x2_2SHIP"] = true, -- eras=Modern; 2x Mi-28N CAS [Modern]
    -- @gui requiredValues="Mi-28N"
    ["RED_MI28N_CAS_9M120x8_9M120Fx8_B13x2_2SHIP"] = true, -- eras=Modern; 2x Mi-28N CAS [Modern]
    -- @gui requiredValues="Mi-24V"
    ["RED_MI24V_CAS_B8x2_B13x2_1SHIP"] = false, -- eras=Coldwar; Mi-24V CAS [CW]
    -- @gui requiredValues="Mi-24V"
    ["RED_MI24V_CAS_B8x2_B13x2_2SHIP"] = false, -- eras=Coldwar; 2x Mi-24V CAS [CW]
    -- @gui requiredValues="Mi-8MT"
    ["RED_MI8_CAS_FAB100x4_UPK23x2_KORD_PKT_1SHIP"] = false, -- eras=Vietnam|Coldwar; Mi-8 FAB-100/UPK-23 gunpod CAS [VN/CW]
    -- @gui requiredValues="Mi-8MT"
    ["RED_MI8_CAS_FAB100x4_UPK23x2_KORD_PKT_2SHIP"] = false, -- eras=Vietnam|Coldwar; 2x Mi-8 FAB-100/UPK-23 gunpod CAS [VN/CW]
    -- @gui requiredValues="Mi-8MT"
    ["RED_MI8_CAS_GUV_YAKB_GSHPx2_KORD_PKT_1SHIP"] = false, -- eras=Vietnam|Coldwar; Mi-8 gunpod CAS [VN/CW]
    -- @gui requiredValues="Mi-8MT"
    ["RED_MI8_CAS_GUV_YAKB_GSHPx2_KORD_PKT_2SHIP"] = false, -- eras=Vietnam|Coldwar; 2x Mi-8 gunpod CAS [VN/CW]
}

-- @gui label="BLUE CAS Helo Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable"
BlueCasHeloEnabled = {
    -- @gui requiredValues="AH-64D_BLK_II"
    ["BLUE_AH64D_CAS_AGM114Kx4_AGM114Lx4_M261x2_FCR_1SHIP"] = true, -- eras=Modern; AH-64D CAS [Modern]
    -- @gui requiredValues="AH-64D_BLK_II"
    ["BLUE_AH64D_CAS_AGM114Kx4_AGM114Lx4_M261x2_FCR_2SHIP"] = true, -- eras=Modern; 2x AH-64D CAS [Modern]
    -- @gui requiredValues="AH-64D_BLK_II"
    ["BLUE_AH64D_CAS_AGM114Kx8_M261x2_1SHIP"] = true, -- eras=Modern; AH-64D CAS [Modern]
    -- @gui requiredValues="AH-64D_BLK_II"
    ["BLUE_AH64D_CAS_AGM114Kx8_M261x2_2SHIP"] = true, -- eras=Modern; 2x AH-64D CAS [Modern]
    -- @gui requiredValues="AH-1W"
    ["BLUE_AH1W_CAS_AGM114Kx8_M260x2_1SHIP"] = true, -- eras=Modern; AH-1W CAS [Modern]
    -- @gui requiredValues="SA342M"
    ["BLUE_SA342M_CAS_HOT3x4_1SHIP"] = true, -- eras=Modern; SA342M CAS [Modern]
    -- @gui requiredValues="SA342M"
    ["BLUE_SA342M_CAS_HOT3x4_2SHIP"] = true, -- eras=Modern; 2x SA342M CAS [Modern]
    -- @gui requiredValues="OH58D"
    ["BLUE_OH58D_CAS_AGM114x2_APKWS_1SHIP"] = true, -- eras=Modern; OH-58D CAS [Modern]
    -- @gui requiredValues="OH58D"
    ["BLUE_OH58D_CAS_AGM114x2_APKWS_2SHIP"] = true, -- eras=Modern; 2x OH-58D CAS [Modern]
    -- @gui requiredValues="UH-1H"
    ["BLUE_UH1H_CAS_XM158x2_M134x3_M60_1SHIP"] = false, -- eras=Coldwar|Vietnam; UH-1H CAS [CW/VN]
    -- @gui requiredValues="UH-1H"
    ["BLUE_UH1H_CAS_XM158x2_M134x3_M60_2SHIP"] = false, -- eras=Coldwar|Vietnam; 2x UH-1H CAS [CW/VN]
}

-- @gui label="RED Supply Helo Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable"
RedSupplyHeloEnabled = {
    -- @gui requiredValues="Mi-8MT"
    ["RED_MI8_SUPPLY_KORD"] = true, -- eras=Modern|Coldwar|Vietnam; Mi-8 Supply [All]
    -- @gui requiredValues="Mi-8MT"
    ["RED_MI8_SUPPLY_KORD_PKT"] = true, -- eras=Modern|Coldwar|Vietnam; Mi-8 Supply [All]
}

-- @gui label="BLUE Supply Helo Templates" editor="checkboxTable" rowLabel="comment" confirmSetRowsByEra="Select aircraft templates based on Era?" installPolicy="replaceTable"
BlueSupplyHeloEnabled = {
	-- @gui requiredValues="CH-47Fbl1"
	["BLUE_CH47_SUPPLY_M240Hx2"] = true, -- eras=Modern|Coldwar|Vietnam; CH-47 Supply [All]
	-- @gui requiredValues="CH-47Fbl1"
	["BLUE_CH47_SUPPLY_M60Dx3"] = true, -- eras=Modern|Coldwar|Vietnam; CH-47 Supply [All]
}

-- ============================================================================
-- Mission options
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

-- ONLY VALID ON CAUCASUS, PERSIAN GULF, SYRIA AND AFGHANISTAN.
-- if false, the mission will start from the other end. Carrier zone will be disabled.
StartNormal = true

-- SYRIA ONLY.
-- If true while StartNormal is true, the campaign starts from Incirlik instead of Akrotiri.
-- PvE only. PvP always uses Incirlik and Palmyra; StartNormal swaps their coalitions.
-- @gui label="Start From Incirlik" visibleWhen="StartNormal:true" disabledWhen="PvP:true"
StartFromIncirlik = false

-- SYRIA ONLY.
-- If true, removes the southern Syria zones from the campaign.
-- Current campaign progress is kept. If later set to false, the southern zones return using their default setup state.
-- In PvP, selects the reduced mainland layout; false selects the full mainland layout. Cyprus is excluded in both.
-- @gui label="Remove Southern Syria"
RemoveSouthSyria = false
 
-- When the mission is completed, if you want the server to restart automatically and reset everything, then set this to true.
-- If false, you will have a menu where you can choose to restart the mission. 
AutoRestart = false

-- Modular, Automatic and Network capable Targeting and Interception System for Air Defenses. (MANTIS)
-- Once the player is within, the sam system will turn on. If you fire HARP, Talds or Jsaw, they will turn off and move.
-- Their movement depends if they are able to move, like the SA-6 and SA-11.
DisableMantis = false -- MANTIS is based on Early warning radars (EWR) for detectiion. they will be off until players are detected by the EWR.

-- ammo depots, fuel tanks, factories).
UseStatics = true -- If true, include some static target types at certain zones (command centers,

-- PVE_Only is a flag where you can decide if you want to disable players from spawning in red zones.
-- This is when the player chooses Red coalition.
-- @gui disabledWhen="PvP:true"
PVE_Only = false -- If true, players can not spawn in red coalition zones.

-- If true, supports filling modded weapons via WarehouseLogistics
-- (not compatible with Coldwar/Gulfwar).
-- Keep in mind, adding mods midsession, while there is a save file, those weapons will not be added to current saved airbases.
-- this will be filled through time, from the AutoFillResources.
AllowMods = false -- Should NOT be used with the Coldwar or Gulfwar era.

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

-- ============================================================================
-- F10 Map
-- ============================================================================
-- Controls how supply connections are drawn on the F10 map.
-- "arrow" keeps the current arrow display. "line" draws dashed lines instead.
-- @gui label="Connection Display" validValues="Arrows=arrow | Lines=line"
ConnectionMapStyle = "line"

-- Controls the connection display color on the F10 map.
-- "dynamic" uses BLUE, RED, and neutral colors based on zone ownership.
-- "white" draws all connections white.
-- @gui label="Connection Color" validValues="Dynamic=dynamic | White=white"
ConnectionMapColor = "dynamic"

-- ============================================================================
-- Difficulty
-- ============================================================================
GlobalSettings = GlobalSettings or {}
-- Foothold non-supply spawn/respawn speed scaling.
-- This multiplier affects AI attack and patrol mission timers.
-- 1.0 = normal speed
-- 0.5 = twice as fast
-- 1.5 = 50% slower
--
-- [1] = RED coalition
-- [2] = BLUE coalition
-- @gui label="AI Spawn Speed Scaling" editor="sideMultiplier" min="0.10" max="5.00" step="0.05"
GlobalSettings.difficultyScaling = { [1]=1.0, [2]=1.0 }

-- @gui label="Red AI Plane Skill" validValues="Average=Average | Good=Good | High=High | Excellent=Excellent | Random=Random"
AiPlaneSkill            = "Random" -- AI skill used for spawned airplanes Red only (MOOSE SPAWN:InitSkill).

-- Valid: "Average", "Good", "High", "Excellent", "Random" (case-insensitive). Unknown values become "High".
RedAiGroundSkill        = "Excellent" -- AI skill used for spawned RED zone ground defenses (MOOSE SPAWN:InitSkill).

-- Valid: "Average", "Good", "High", "Excellent", "Random" (case-insensitive). Unknown values become "High".
BlueAiGroundSkill       = "Excellent" -- AI skill used for spawned BLUE zone ground defenses (MOOSE SPAWN:InitSkill).

-- Controls whether SAM groups are hidden on MFDs.
-- Valid values only: false | true | "random"
-- false    = always shown on MFD
-- true     = always hidden on MFD (default)
-- "random" = 50% chance hidden on each spawn
HideSAMOnMFD = true -- if random, use "random" (string)

-- Chance in percent that RED AI air missions may also engage helicopters in PvE.
-- 0 disables helicopter targeting, 100 always allows it.
-- Ignored in PvP (use PvP Chance AI Attack Helo), or when InvisibleA10 is true.
-- @gui disabledWhen="InvisibleA10|PvP:true"
ChanceAiAttackHelo = 0

-- Hunter is when you do a lot of damage to enemy units (both planes and ground), RED dispatches a 2-ship to hunt you down.
-- @gui disabledWhen="PvP:true"
EnableHunter = true

-- Lets the Director remember recent RED sortie and regular-supply outcomes and use them as soft planning influences.
-- This does not add groups, force launches, bypass cooldowns, or block a route.
-- @gui label="Director Battlefield Intelligence"
GlobalSettings.directorBattlefieldIntelligenceEnabled = true

-- Lets the Director remember recent air-combat results and use them as a small influence when redirecting an existing RED CAP.
-- This does not add aircraft or bypass normal CAP limits, cooldowns, or safety checks.
-- @gui label="Director Air-Combat Intelligence"
GlobalSettings.directorAirCombatIntelligenceEnabled = true

-- Valid values: "easy" | "medium" | "hard"
-- Here, you can adjust how many cap should spawn. medium, is the default (Balanaced)
-- @gui disabledWhen="PvP:true"
CapDifficulty           = "medium" -- RED CAP amount.  This can be further custommized in the advance section.
-- @gui disabledWhen="PvP:true"
CasDifficulty           = "medium" -- RED CAS amount.  This can be further custommized in the advance section.
-- @gui disabledWhen="PvP:true"
SeadDifficulty          = "medium" -- RED SEAD amount.  This can be further custommized in the advance section.
-- @gui disabledWhen="PvP:true"
RunwayStrikeDifficulty  = "medium" -- RED RUNWAYSTRIKE amount.  This can be further custommized in the advance section.
RedReactiveDifficulty   = "medium" -- RED reactive counterpressure difficulty.

-- @gui disabledWhen="PvP:true"
FriendlyCapSupport      = "medium" -- BLUE CAP support limit. This can be further custommized in the advance section.
-- @gui disabledWhen="PvP:true"
FriendlyCasSupport      = "medium" -- BLUE CAS support limit.  This can be further custommized in the advance section.
-- @gui disabledWhen="PvP:true"
FriendlySeadSupport     = "medium" -- BLUE SEAD support limit.  This can be further custommized in the advance section.


-- ============================================================================
-- Difficulty advanced
-- ============================================================================

-- The "amount" field in the case of CAP, 1 amount equals to 1 CAP Patrol and 1 CAP Attack. so 1 amount equal 2 groups.
-- players in the table below are counted as active players if they are not in the CapCountIgnoreTypes.
-- @gui label="RED CAP Limit"
-- @gui linkedSetting="CapDifficulty"
-- @gui installPolicy="keepTable"
-- @gui disabledWhen="PvP:true"
CapLimitStages = {
	easy = {
		{ player = 0, amount = 0 },
		{ player = 1, amount = 1 },
		{ player = 2, amount = 1 },
		{ player = 3, amount = 2 },
		{ player = 4, amount = 3 },
		{ player = 6, amount = 4 },
		{ player = 10, amount = 5 },
		{ player = 999, amount = 6 },
	},
	medium = {
		{ player = 0, amount = 1 },
		{ player = 1, amount = 1 },
		{ player = 2, amount = 1 },
		{ player = 3, amount = 2 },
		{ player = 4, amount = 2 },
		{ player = 5, amount = 3 },
		{ player = 9, amount = 4 },
		{ player = 10, amount = 6 },
		{ player = 999, amount = 7 },
	},
	hard = {
		{ player = 0, amount = 1 },
		{ player = 1, amount = 1 },
		{ player = 2, amount = 2 },
		{ player = 3, amount = 3 },
		{ player = 4, amount = 3 },
		{ player = 6, amount = 4 },
		{ player = 9, amount = 5 },
		{ player = 10, amount = 6 },
		{ player = 999, amount = 8 },
	},
}

-- Advance settings for CasDifficulty.
-- Players in the table below are counted as active players if they are not in the RedCasCountIgnoreTypes.
-- The "amount" field in the table below is the amount of CAS flights that can be active at the same time.
-- @gui label="RED CAS Limit"
-- @gui linkedSetting="CasDifficulty"
-- @gui installPolicy="keepTable"
-- @gui disabledWhen="PvP:true"
RedCasLimitStages = {
	easy = {
		{ player = 0, amount = 0 },
		{ player = 1, amount = 0 },
		{ player = 2, amount = 1 },
		{ player = 3, amount = 1 },
		{ player = 4, amount = 2 },
		{ player = 5, amount = 2 },
		{ player = 999, amount = 3 },
	},
	medium = {
		{ player = 0, amount = 1 },
		{ player = 1, amount = 1 },
		{ player = 2, amount = 1 },
		{ player = 3, amount = 2 },
		{ player = 4, amount = 2 },
		{ player = 5, amount = 3 },
		{ player = 9, amount = 3 },
		{ player = 999, amount = 4 },
	},
	hard = {
		{ player = 0, amount = 1 },
		{ player = 1, amount = 1 },
		{ player = 2, amount = 2 },
		{ player = 3, amount = 3 },
		{ player = 4, amount = 4 },
		{ player = 5, amount = 4 },
		{ player = 9, amount = 6 },
		{ player = 999, amount = 7 },
	},
}

-- Advance settings for SeadDifficulty..
-- Players in the table below are counted as active players if they are not in the RedCasCountIgnoreTypes.
-- The "amount" field in the table below is the amount of SEAD flights that can be active at the same time.
-- @gui label="RED SEAD Limit"
-- @gui linkedSetting="SeadDifficulty"
-- @gui installPolicy="keepTable"
-- @gui disabledWhen="PvP:true"
RedSeadLimitStages = {
	easy = {
		{ player = 0, amount = 0 },
		{ player = 1, amount = 0 },
		{ player = 2, amount = 1 },
		{ player = 3, amount = 1 },
		{ player = 4, amount = 2 },
		{ player = 5, amount = 2 },
		{ player = 999, amount = 3 },
	},
	medium = {
		{ player = 0, amount = 1 },
		{ player = 1, amount = 1 },
		{ player = 2, amount = 1 },
		{ player = 3, amount = 1 },
		{ player = 4, amount = 2 },
		{ player = 5, amount = 2 },
		{ player = 9, amount = 3 },
		{ player = 999, amount = 4 },
	},
	hard = {
		{ player = 0, amount = 1 },
		{ player = 1, amount = 1 },
		{ player = 2, amount = 1 },
		{ player = 3, amount = 2 },
		{ player = 4, amount = 3 },
		{ player = 5, amount = 3 },
		{ player = 9, amount = 6 },
		{ player = 999, amount = 7 },
	},
}

-- Advance settings for RunwayStrikeDifficulty.
-- Players in the table below are counted as active players if they are not in the RedCasCountIgnoreTypes.
-- The "amount" field in the table below is the amount of Runway Strike flights that can be active at the same time.
-- @gui label="RED Runway Strike Limit"
-- @gui linkedSetting="RunwayStrikeDifficulty"
-- @gui installPolicy="keepTable"
-- @gui disabledWhen="PvP:true"
RedRunwayStrikeLimitStages = {
	easy = {
		{ player = 0, amount = 0 },
		{ player = 1, amount = 0 },
		{ player = 2, amount = 1 },
		{ player = 3, amount = 1 },
		{ player = 4, amount = 2 },
		{ player = 5, amount = 2 },
		{ player = 999, amount = 3 },
	},
	medium = {
		{ player = 0, amount = 0 },
		{ player = 1, amount = 1 },
		{ player = 2, amount = 1 },
		{ player = 3, amount = 1 },
		{ player = 4, amount = 2 },
		{ player = 5, amount = 3 },
		{ player = 9, amount = 4 },
		{ player = 999, amount = 4 },
	},
	hard = {
		{ player = 0, amount = 0 },
		{ player = 1, amount = 1 },
		{ player = 2, amount = 2 },
		{ player = 3, amount = 3 },
		{ player = 4, amount = 4 },
		{ player = 5, amount = 4 },
		{ player = 9, amount = 6 },
		{ player = 999, amount = 7 },
	},
}

-- Advance settings for FriendlyCapSupport.
-- Players in the table below are counted as active players if they are not in the CapCountIgnoreTypes.
-- The logic here, The less the players, the more AI will help you. The list in CapCountIgnoreTypes, is types that doesn't count as active players.
-- @gui label="BLUE CAP Support"
-- @gui linkedSetting="FriendlyCapSupport"
-- @gui installPolicy="keepTable"
-- @gui disabledWhen="PvP:true"
BlueCapSupportStages = {
	easy = {
		{ player = 0, amount = 2 },
		{ player = 1, amount = 2 },
		{ player = 999, amount = 1 },
	},
	medium = {
		{ player = 0, amount = 1 },
		{ player = 1, amount = 1 },
		{ player = 1000, amount = 0 },
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
-- @gui disabledWhen="PvP:true"
BlueCasSupportStages = {
	easy = {
		{ player = 0, amount = 2 },
		{ player = 1, amount = 2 },
		{ player = 999, amount = 1 },
	},
	medium = {
		{ player = 0, amount = 1 },
		{ player = 1, amount = 1 },
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
-- @gui installPolicy="keepTable"
-- @gui disabledWhen="PvP:true"
BlueSeadSupportStages = {
	easy = {
		{ player = 0, amount = 2 },
		{ player = 1, amount = 2 },
		{ player = 999, amount = 1 },
	},
	medium = {
		{ player = 0, amount = 1 },
		{ player = 1, amount = 1 },
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

-- @gui editor="checkboxTable"
CapCountIgnoreTypes = {
	["A-10C_2"] = true,
	["Hercules"] = true,
	["A-10A"] = true,
	["A-10C"] = true,
	["AV8BNA"] = true,
	["AJS37"] = true,
	["C-130J-30"] = true,
}

-- @gui editor="checkboxTable"
RedCasCountIgnoreTypes = {
	["Hercules"] = true,
	["C-130J-30"] = true,
	["CH-47Fbl1"] = true,
}

-- @gui editor="checkboxTable"
BlueCasCountIgnoreTypes = {
	["Hercules"] = true,
	["C-130J-30"] = true,
	["CH-47Fbl1"] = true,
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
-- escortType: 1 = Hornet (F-18C in Coldwar or Gulfwar with AIM-7),
--             2 = Viper (F-15C in Coldwar or Gulfwar with AIM-7)
--             3 = MIG29S with R-77 (MiG-29A in Coldwar or Gulfwar with R-27ET)
-- The third value is how many feet above the player the escort follows.
-- Use 0 for the same altitude, or 1000 through 10000 in 1000-foot steps.
-- @gui installPolicy="mergeRows" disabledWhen="PvP:true;PvPEscorts:false"
EscortTypeByPlayerType = {
    ["C-130J-30"]      = { true, 1, 10000 },
    ["AV8BNA"]         = { true, 1, 5000 },
    ["A-10C_2"]        = { true, 1, 10000 },
    ["A-10C"]          = { true, 1, 10000 },
    ["A-10A"]          = { true, 1, 10000 },
    ["Hercules"]       = { true, 1, 10000 },
    ["F-15ESE"]        = { true, 2, 2000 },
    ["AJS37"]          = { true, 1, 10000 },
    ["MiG-29 Fulcrum"] = { false, 2, 2000 },
    ["F-16C_50"]       = { false, 2, 2000 },
    ["FA-18C_hornet"]  = { false, 2, 2000 },
    ["MiG-21Bis"]      = { false, 3, 2000 },
    ["Su-25T"]         = { false, 3, 5000 },
    ["Su-25"]          = { false, 3, 5000 },
    ["M-2000C"]        = { false, 2, 5000 },
    ["Bronco-OV-10A"]  = { false, 1, 5000 },
}

-- Plane escort option for takeoff from the ground.
-- @gui disabledWhen="PvP:true;PvPEscorts:false"
EscortTakeoffFromGround = true -- If true, the escort will takeoff from the ground instead of airspawn.

-- ============================================================================
-- Logistics / Warehouse
-- ============================================================================

-- If true, logistics/supply is done via warehouse + zone supplies only.
-- You can only carry supplies using the rearming menu, then load cargo, not the ctld menu nor logistics menu.
-- Neutral zones start without weapons; you must bring them or wait for AI delivery.
WarehouseLogistics = true

-- How many seconds a neutral-zone capture takes after a valid delivery arrives.
-- Set to 0 to capture immediately.
-- @gui label="Neutral Zone Capture Time" editor="seconds"
ZoneCaptureBuildSeconds = 120

-- How many ready supplies a normal zone produces before automatic production pauses.
-- Player-delivered supplies can still be stored above this amount.
-- @gui label="Normal Zone Supply Capacity" validValues="1=1 | 2=2 | 3=3"
NormalSupplyCapacity = 1

-- How many ready supplies a [WH] zone produces before automatic production pauses.
-- Player-delivered supplies can still be stored above this amount.
-- @gui label="Warehouse Supply Capacity" validValues="3=3 | 4=4 | 5=5 | 6=6"
WarehouseSupplyCapacity = 6

-- How many supplies a newly created CTLD FARP starts with.
-- Player-delivered supplies can still be stored above this amount.
-- @gui label="CTLD FARP Starting Supplies" validValues="1=1 | 2=2 | 3=3"
CTLDSupplyCapacity = 1

-- Supply mission and ready-supply production speed scaling.
-- This multiplier affects AI supply mission timers and ready-supply production times.
-- 1.0 = normal speed
-- 0.5 = twice as fast
-- 1.5 = 50% slower
--
-- [1] = RED coalition
-- [2] = BLUE coalition
-- @gui label="Supply Speed Scaling" editor="sideMultiplier" min="0.10" max="5.00" step="0.05" timePreviewRed="Normal zone:1200" timePreviewBlue="Normal zone:1200 | [WH]:600"
GlobalSettings.supplyDifficultyScaling = { [1]=1.0, [2]=1.0 }

-- Scales repair, rebuild, and installation time after supplies are available.
-- 0.5 = twice as fast
-- 1.0 = normal speed
-- 1.5 = 50% slower
--
-- PvE Red normal speed: 1 minute per unit, 3 minutes per SR/TR/STR, maximum 20 minutes.
-- Blue normal speed: 15 minute normal-zone base or 5 minute [WH] base + 2 minutes per unit or 3 minutes per SR/TR/STR, maximum 20 minutes.
-- Blue has a base time because Blue zones consume supplies directly from their own storage.
-- Red has no base time here because Red must first wait for supplies delivered from another zone.
-- PvP: both coalitions use the Blue timing policy above, each with its own multiplier.
-- Player, CTLD, airdropped, zsup3, and supplies2 supplies skip the Blue base time.
-- Supply production, dispatch, and travel times are not changed by this setting.
-- @gui label="Repair Time Scaling" editor="sideMultiplier" min="0.10" max="5.00" step="0.05" timePreviewSharedWhen="PvP:true" timePreview="Normal base:900 | [WH] base:300 | Expedited base:0 | Unit:120 | SR/TR/STR:180 | Maximum:1200" timePreviewRed="Unit:60 | SR/TR/STR:180 | Maximum:1200" timePreviewBlue="Normal base:900 | [WH] base:300 | Expedited base:0 | Unit:120 | SR/TR/STR:180 | Maximum:1200"
GlobalSettings.repairDifficultyScaling = { [1]=1, [2]=1 }

-- Extra time for Red repairs and construction when fewer than 2 eligible Blue CAS players are present.
-- Uses the cached CAS player list, excluding BlueCasCountIgnoreTypes, once when the job starts.
-- Adds to the scaled starting duration; later damage-driven timer updates remain unchanged.
-- 0 disables the extra time (default). Maximum 50% extra time. Blue and supply travel times are unchanged.
-- @gui label="Extra Red Repair Time — Low Player Count %" validValues="Disabled=0 | 5%=5 | 10%=10 | 15%=15 | 20%=20 | 25%=25 | 30%=30 | 35%=35 | 40%=40 | 45%=45 | 50%=50" disabledWhen="PvP:true"
ExtraRedRepairTimeLowPlayerCountPercent = 0

-- If true, player-picked Zone supplies consume one ready supply package from the campaign zone.
-- Returned or removed cargo restores that package; destroyed or delivered cargo does not.
-- Carrier and dynamic FARP pickups remain unlimited because they do not hold campaign-zone stock.
PlayerZoneSuppliesConsumeStock = true

-- If true, C-130J-30 AND Chinook! Use the internal (Ground crew for the Chinook and C-130 loading system only (not CTLD menu load).
UseC130LoadAndUnload = true -- need to be true if using Logisticsystem as the cargo need to be tracked.


-- If true, AI supply helicopters use cargo transport for warehouse deliveries.
SuppliesCargoTransport = true

-- How much AI delivery brings per supply run.
AIDeliveryamount = 20

-- Every 15 minutes, BLUE zones gain this many resources (covers AI usage).
AutoFillResources = 5

-- Permanently disable regular BLUE AI supply deliveries. Player and shop logistics remain available.
-- @gui disabledWhen="RadioMenuStopSupplies|PvP:true"
NoAIBlueSupplies = false

-- Allow BLUE players to enable or disable regular BLUE AI supply deliveries from the F10 radio menu.
-- @gui disabledWhen="NoAIBlueSupplies|PvP:true"
RadioMenuStopSupplies = false

-- This option is the legacy option. this won't be used if WarehouseLogistics = true
-- @gui installPolicy="mergeRows" editor="checkboxTable"
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
-- @gui installPolicy="mergeRows" editor="checkboxTable"
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

-- If true, smart weapons found in the WarehouseWeaponCaps table at the bottom, will be HALF what we add to the warehouse.
-- This is to make the smart weapons harder to get.
StrictSmartWeaponsInventory = false

-- This table will be used if StrictSmartWeaponsInventory is set to true.
-- Smart weapons in this table will be HALF what we add to the warehouse.
WarehouseWeaponCaps = {
}

-- ============================================================================
-- Shop / Rewards
-- ============================================================================

-- Get extra reward if player keeps the same aircraft after a successful credits redeem and then another sortie with another credits redeem.
-- Percentage of extra credits. 0 disables the reward, 10 is the default, and 50 is the maximum.
-- @gui label="Same Aircraft Extra Reward %" validValues="Disabled=0 | 5%=5 | 10%=10 | 15%=15 | 20%=20 | 25%=25 | 30%=30 | 35%=35 | 40%=40 | 45%=45 | 50%=50"
TurnaroundRewardPercent = 10

-- Advance Capture becomes available when an enemy zone has this percent or less of its upgrade groups remaining.
-- Percent of upgrade groups remaining before Advance Capture appears.
-- This makes the capture of a zone quicker as the supply takes off prior.
-- @gui label="Advance Capture Threshold %" validValues="20%=20 | 25%=25 | 30%=30 | 35%=35 | 40%=40 | 45%=45 | 50%=50 | 55%=55 | 60%=60"
AdvanceCaptureRemainingThreshold = 50

-- Available NEW shop purchases. False removes an item; true keeps its existing eligibility.
-- Mode, era, national template and operator restrictions still apply. Changes take effect on restart.
-- Existing owned services and accepted purchases remain; hidden finite stock is not retained.
-- @gui label="Shop Items" installPolicy="replaceTable" editor="linkedTable" fields="self:Available:boolean|ShopPrices:Price:number|ShopRankRequirements:Rank:number" rowLabel="comment"
AvailableShopItems = {
    ["supplies2"] = true, -- Resupply friendly Zone
    -- @gui visibleWhen="AllowScriptedSupplies:true"
    ["supplies"] = true, -- Fully Upgrade Friendly Zone
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false"
    ["armor"] = true, -- Deploy armor
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false"
    ["artillery"] = true, -- Deploy artillery
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false"
    ["recon"] = true, -- Deploy recon group
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false"
    ["airdef"] = true, -- Deploy air defence
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
    ["calav"] = true, -- Deploy LAV-25 group
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false;Era:Modern"
    ["camgs"] = true, -- Deploy M1128 MGS group
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false;Era:Modern"
    ["cadragoon"] = true, -- Deploy M1296 Dragoon group
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
    ["jtac"] = true, -- MQ-9 Reaper JTAC mission
    ["smoke"] = true, -- Smoke markers
    ["flare"] = true, -- Flare markers
    ["illum"] = true, -- Illumination bomb
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
    ["9lineam"] = true, -- Jtac 9line AM
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
    ["9linefm"] = true, -- Jtac 9line FM
    ["capture"] = true, -- Capture neutral zone
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false"
    ["advancecapture"] = true, -- Advance capture zone
    -- @gui requiredValues="F-16C_50"
    ["dynamiccap"] = true, -- CAP Flight
    -- @gui requiredValues="KC135MPRS"
    ["dynamicarco"] = true, -- Tanker (Drogue)
    -- @gui requiredValues="KC-135"
    ["dynamictexaco"] = true, -- Tanker (Boom)
    -- @gui visibleWhen="PvP:true"
    ["replaceawacs"] = true, -- Replace one lost AWACS
    -- @gui requiredValues="F-16C_50"
    ["dynamiccas"] = true, -- AI Attack CAS Flight
    -- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
    -- @gui requiredValues="FA-18C_hornet"
    ["dynamicdecoy"] = true, -- AI Attack TALD DECOY Flight
    -- @gui requiredValues="FA-18C_hornet"
    ["dynamicsead"] = true, -- AI Attack SEAD Flight
    -- @gui requiredValues="F-15E"
    ["dynamicbomb"] = true, -- AI AttackBomber Flight
    -- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
    -- @gui requiredValues="B-1B"
    ["strategicbomber"] = true, -- AI Attack Strategic bomber
    ["groundattack"] = true, -- AI Attack Ground attack
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false"
    ["dynamicstatic"] = true, -- AI Attack Static structure Flight
    ["intel"] = true, -- Satellite Intel
    ["zinf"] = true, -- Blue zone upgrade: Infantry
    -- @gui visibleWhen="Era:Modern"
    ["zsam"] = true, -- Blue zone upgrade: NASAMS
    ["zhawk"] = true, -- Blue zone upgrade: Hawk
    ["zavenger"] = true, -- Blue zone upgrade: Avenger
    ["zroland"] = true, -- Blue zone upgrade: Roland
    ["zgepard"] = true, -- Blue zone upgrade: Gepard
    ["zvulcan"] = true, -- Blue zone upgrade: Vulcan
    -- @gui visibleWhen="PvP:true;Era:Modern"
    -- @gui linkedKeys="ShopPrices:zcram;ShopRankRequirements:zcram"
    ["zpantsir"] = true, -- Blue zone upgrade: Pantsir
    -- @gui visibleWhen="Era:Modern"
    ["zcram"] = true, -- Blue zone upgrade: C-RAM
    -- @gui visibleWhen="Era:Modern"
    ["zhimars"] = true, -- Blue zone upgrade: HIMARS
    ["zlogc"] = true, -- Blue Logistic Center [WH]
    -- @gui linkedKeys="ShopRankRequirements:zlogc"
    ["zwhrepair"] = true, -- Repair Logistic Center (30 min)
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false"
    ["zsup3"] = true, -- Add 3 supplies to zone
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false"
    ["zwh50"] = true, -- Resupply warehouse with 50
    ["zarm"] = true, -- Blue zone upgrade: Armor
    -- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
    ["zpat"] = true, -- Blue zone upgrade: Patriot
    -- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
    ["zgci"] = true, -- Blue zone upgrade: GCI station
    -- @gui linkedKeys="ShopPrices:zgci;ShopRankRequirements:zgci"
    ["zewr"] = true, -- Blue zone upgrade: EWR
    ["gslot"] = true, -- Unlock extra upgrade slot
    ["farphere"] = true, -- Deploy FARP
    -- @gui disabledWhen="PvP:true" disabledValue="false"
    -- @gui visibleWhen="PvP:false"
    ["cruisemsl"] = true, -- Cruise Missile Strike
    -- @gui visibleWhen="PvP:true"
    -- @gui linkedKeys="ShopPrices:zinf;ShopRankRequirements:zinf"
    ["rzinf"] = true, -- Red zone upgrade: Ground forces (scouts/technicals)
    -- @gui visibleWhen="PvP:true"
    -- @gui linkedKeys="ShopPrices:zarm;ShopRankRequirements:zarm"
    ["rzarm1"] = true, -- Red zone upgrade: Armor group 1
    -- @gui visibleWhen="PvP:true"
    -- @gui linkedKeys="ShopPrices:zarm;ShopRankRequirements:zarm"
    ["rzarm2"] = true, -- Red zone upgrade: Armor group 2
    -- @gui visibleWhen="PvP:true"
    -- @gui linkedKeys="ShopPrices:zarm;ShopRankRequirements:zarm"
    ["rzarm3"] = true, -- Red zone upgrade: Armor group 3
    -- @gui visibleWhen="PvP:true"
    -- @gui linkedKeys="ShopPrices:zvulcan;ShopRankRequirements:zvulcan"
    ["rzaaa"] = true, -- Red zone upgrade: AAA
    -- @gui visibleWhen="PvP:true"
    -- @gui linkedKeys="ShopPrices:zhawk;ShopRankRequirements:zhawk"
    ["rzsa2"] = true, -- Red zone upgrade: SA-2
    -- @gui visibleWhen="PvP:true"
    -- @gui linkedKeys="ShopPrices:zhawk;ShopRankRequirements:zhawk"
    ["rzsa3"] = true, -- Red zone upgrade: SA-3
    -- @gui visibleWhen="PvP:true;Era:Modern|Coldwar|Gulfwar"
    -- @gui linkedKeys="ShopPrices:zhawk;ShopRankRequirements:zhawk"
    ["rzsa6"] = true, -- Red zone upgrade: SA-6
    -- @gui visibleWhen="PvP:true;Era:Modern|Coldwar|Gulfwar"
    -- @gui linkedKeys="ShopPrices:zpat;ShopRankRequirements:zpat"
    ["rzsa10"] = true, -- Red zone upgrade: SA-10
    -- @gui visibleWhen="PvP:true;Era:Modern|Coldwar|Gulfwar"
    -- @gui linkedKeys="ShopPrices:zsam;ShopRankRequirements:zsam"
    ["rzsa11"] = true, -- Red zone upgrade: SA-11
    -- @gui visibleWhen="PvP:true;Era:Modern|Coldwar|Gulfwar"
    -- @gui linkedKeys="ShopPrices:zavenger;ShopRankRequirements:zavenger"
    ["rzsa8"] = true, -- Red zone upgrade: SA-8
    -- @gui visibleWhen="PvP:true;Era:Modern|Coldwar|Gulfwar"
    -- @gui linkedKeys="ShopPrices:zavenger;ShopRankRequirements:zavenger"
    ["rzsa9"] = true, -- Red zone upgrade: SA-9
    -- @gui visibleWhen="PvP:true;Era:Modern|Coldwar|Gulfwar"
    -- @gui linkedKeys="ShopPrices:zavenger;ShopRankRequirements:zavenger"
    ["rzsa13"] = true, -- Red zone upgrade: SA-13
    -- @gui visibleWhen="PvP:true;Era:Modern|Coldwar|Gulfwar"
    -- @gui linkedKeys="ShopPrices:zroland;ShopRankRequirements:zroland"
    ["rzsa15"] = true, -- Red zone upgrade: SA-15
    -- @gui visibleWhen="PvP:true;Era:Modern|Coldwar|Gulfwar"
    -- @gui linkedKeys="ShopPrices:zavenger;ShopRankRequirements:zavenger"
    ["rzsa19"] = true, -- Red zone upgrade: SA-19
    -- @gui visibleWhen="PvP:true;Era:Modern"
    -- @gui linkedKeys="ShopPrices:zcram;ShopRankRequirements:zcram"
    ["rztorm2"] = true, -- Red zone upgrade: Tor M2
    -- @gui visibleWhen="PvP:true;Era:Modern|Coldwar|Gulfwar"
    -- @gui linkedKeys="ShopPrices:zavenger;ShopRankRequirements:zavenger"
    ["rzmanpad"] = true, -- Red zone upgrade: MANPAD/scout task force
    -- @gui visibleWhen="PvP:true;Era:Modern"
    -- @gui linkedKeys="ShopPrices:zgci;ShopRankRequirements:zgci"
    ["rzgci"] = true, -- Red zone upgrade: GCI station
    -- @gui visibleWhen="PvP:true"
    -- @gui linkedKeys="ShopPrices:zgci;ShopRankRequirements:zgci"
    ["rzewr"] = true, -- Red zone upgrade: EWR
    -- @gui visibleWhen="PvP:true;Era:Modern"
    -- @gui linkedKeys="ShopPrices:zhimars;ShopRankRequirements:zhimars"
    ["rzarty"] = true, -- Red zone upgrade: Grad

}

-- Shop prices.
-- @gui installPolicy="replaceTable" rowLabel="comment"
ShopPrices = {
	smoke         = 20,   -- Smoke markers
    flare         = 20,   -- Flare markers
	illum         = 100,  -- Illumination bomb
	dynamiccap    = 500,  -- CAP Flight
	dynamicarco   = 1000,  -- Tanker (Drogue)
	dynamictexaco = 1000,  -- Tanker (Boom)
	-- @gui visibleWhen="PvP:true"
	replaceawacs  = 1000, -- Replace one lost AWACS
	dynamiccas    = 1000, -- AI Attack CAS Flight
	-- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
	dynamicdecoy  = 300,  -- AI Attack TALD DECOY Flight
	dynamicsead   = 500,  -- AI Attack SEAD Flight
	groundattack  = 1000, -- AI Attack Ground attack
	dynamicbomb   = 500,  -- AI AttackBomber Flight
	-- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
	strategicbomber = 1500, -- AI Attack Strategic bomber
	-- @gui visibleWhen="PvP:false"
	dynamicstatic = 500,  -- AI Attack Static structure Flight
	-- @gui visibleWhen="PvP:false"
	cruisemsl     = 800,  -- Cruise Missile Strike
	supplies2     = 200,  -- Resupply friendly Zone
	supplies      = 1000, -- Fully Upgrade Friendly Zone
	-- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
	jtac          = 500,  -- MQ-9 Reaper JTAC mission
	-- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
	["9lineam"]   = 0,    -- Jtac 9line AM
	-- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
	["9linefm"]   = 0,    -- Jtac 9line FM
	-- @gui visibleWhen="PvP:false"
	armor         = 100,  -- Deploy armor
	-- @gui visibleWhen="PvP:false"
	artillery     = 100,  -- Deploy artillery
	-- @gui visibleWhen="PvP:false"
	recon         = 50,   -- Deploy recon group
	-- @gui visibleWhen="PvP:false"
	airdef        = 150,  -- Deploy air defence
	-- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
	calav         = 100,  -- Deploy LAV-25 group
	-- @gui visibleWhen="PvP:false;Era:Modern"
	camgs         = 100,  -- Deploy M1128 MGS group
	-- @gui visibleWhen="PvP:false;Era:Modern"
	cadragoon     = 100,  -- Deploy M1296 Dragoon group
	capture       = 500,  -- Capture neutral zone
	-- @gui visibleWhen="PvP:false"
	advancecapture = 500, -- Advance capture zone
	intel         = 150,  -- Satellite Intel
	zinf          = 500,  -- Blue zone upgrade: Infantry
	zhawk         = 2000, -- Blue zone upgrade: Hawk
	zavenger      = 1000, -- Blue zone upgrade: Avenger
	zroland       = 1000, -- Blue zone upgrade: Roland
	zgepard       = 750, -- Blue zone upgrade: Gepard
	zvulcan       = 500, -- Blue zone upgrade: Vulcan
	-- @gui visibleWhen="Era:Modern"
	zcram         = 1500, -- Blue zone upgrade: C-RAM
	-- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
	zsam          = 2000, -- Blue zone upgrade: NASAMS
	zlogc         = 5000, -- Blue Logistic Center [WH]
	zwhrepair     = 2000, -- Repair Logistic Center (30 min)
	-- @gui visibleWhen="PvP:false"
	zsup3         = 750,  -- Add 3 supplies to zone
	-- @gui visibleWhen="PvP:false"
	zwh50         = 500,  -- Resupply warehouse with 50
	zarm          = 1000, -- Blue zone upgrade: Armor
	-- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
	zpat          = 5000, -- Blue zone upgrade: Patriot
	zgci          = 500,  -- Blue zone upgrade: GCI station
	gslot         = 3000, -- Unlock extra upgrade slot
	farphere      = 1000, -- Deploy FARP
    -- @gui visibleWhen="Era:Modern"
    zhimars       = 2500, -- Blue zone upgrade: HIMARS
}

-- Shop ranks.
-- @gui installPolicy="replaceTable" rowLabel="comment"
ShopRankRequirements = {
	-- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
	jtac           = 2,  -- MQ-9 Reaper JTAC mission
	dynamiccap     = 2,  -- CAP Flight
	dynamiccas     = 5,  -- AI Attack CAS Flight
	dynamicbomb    = 4,  -- AI AttackBomber Flight
	-- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
	strategicbomber = 6, -- AI Attack Strategic bomber
	dynamicsead    = 4,  -- AI Attack SEAD Flight
	groundattack   = 5,  -- AI Attack Ground attack
	-- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
	dynamicdecoy   = 1,  -- AI Attack TALD DECOY Flight
	-- @gui visibleWhen="PvP:false"
	dynamicstatic  = 4,  -- AI Attack Static structure Flight
	dynamicarco    = 3,  -- Tanker (Drogue)
	dynamictexaco  = 3,  -- Tanker (Boom)
	-- @gui visibleWhen="PvP:true"
	replaceawacs   = 3, -- Replace one lost AWACS
	farphere       = 4,  -- Deploy FARP
	capture        = 1,  -- Capture neutral zone
	-- @gui visibleWhen="PvP:false"
	advancecapture = 1,  -- Advance capture zone
	smoke          = 1,  -- Smoke markers
	flare          = 1,  -- Flare markers
	illum          = 1,  -- Illumination bomb
	intel          = 5,  -- Satellite Intel
	supplies2      = 1,  -- Resupply friendly Zone
	supplies       = 6,  -- Fully Upgrade Friendly Zone
	zinf           = 5,  -- Blue zone upgrade: Infantry
	zarm           = 7,  -- Blue zone upgrade: Armor
	zhawk         = 6, -- Blue zone upgrade: Hawk
	zavenger      = 5, -- Blue zone upgrade: Avenger
	zroland       = 5, -- Blue zone upgrade: Roland
	zgepard       = 4, -- Blue zone upgrade: Gepard
	zvulcan       = 3, -- Blue zone upgrade: Vulcan
	-- @gui visibleWhen="Era:Modern"
	zcram         = 6, -- Blue zone upgrade: C-RAM
	-- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
	zsam          = 6,  -- Blue zone upgrade: NASAMS
	zlogc          = 1,  -- Blue Logistic Center [WH]
	-- @gui visibleWhen="PvP:false"
	zsup3          = 2,  -- Add 3 supplies to zone
	-- @gui visibleWhen="PvP:false"
	zwh50          = 2,  -- Resupply warehouse with 50
	gslot          = 9,  -- Unlock extra upgrade slot
	-- @gui visibleWhen="Era:Modern|Coldwar|Gulfwar"
	zpat           = 8,  -- Blue zone upgrade: Patriot
	zgci           = 3,  -- Blue zone upgrade: GCI station
	-- @gui visibleWhen="PvP:false"
	armor          = 3,  -- Deploy armor
	-- @gui visibleWhen="PvP:false"
	artillery      = 3,  -- Deploy artillery
	-- @gui visibleWhen="PvP:false"
	recon          = 3,  -- Deploy recon group
	-- @gui visibleWhen="PvP:false"
	airdef         = 3,  -- Deploy air defence
	-- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
	calav          = 3,  -- Deploy LAV-25 group
	-- @gui visibleWhen="PvP:false;Era:Modern"
	camgs          = 3,  -- Deploy M1128 MGS group
	-- @gui visibleWhen="PvP:false;Era:Modern"
	cadragoon      = 3,  -- Deploy M1296 Dragoon group
	-- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
	["9lineam"]    = 1,  -- Jtac 9line AM
	-- @gui visibleWhen="PvP:false;Era:Modern|Coldwar|Gulfwar"
	["9linefm"]    = 1,  -- Jtac 9line FM
	-- @gui visibleWhen="PvP:false"
	cruisemsl      = 10, -- Cruise Missile Strike
    -- @gui visibleWhen="Era:Modern"
    zhimars        = 8,  -- Blue zone upgrade: HIMARS
}

-- Earnings per target/event. Enemy pilot capture pays on delivery to a friendly zone.
-- @gui installPolicy="mergeRows"
RewardContribution = {
	infantry         = 10,
	ground           = 10,
	ctldGround       = 10, -- CTLD Units built by player reward Ground kill
	ctldAir          = 20, -- CTLD Units built by player reward Air kill
	sam              = 30,
	airplane         = 50,
	ship             = 200,
	helicopter       = 50,
	crate            = 100,
	rescue           = 200,
	enemyPilotCapture = 200, -- Per enemy pilot delivered; 0 disables capture credits, not Intel or statistics.
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

-- If false, CTLD crates/units are free.
CTLDCost = true

 -- If true, Red side can use CTLD on a basic level.
-- @gui disabledWhen="PvP:true" disabledValue="true"
Allow_Red_CTLD = false

-- Maximum distance in meters that unloaded CTLD troops can run toward a zone.
-- Use a value between 2000 and 15000.
MaxTroopsRunDistanceTowardZone = 5000

-- This is the prices for each CTLD unit and their required rank. Rank 1 is the lowest.
-- @gui label="CTLD Items" editor="linkedTable" fields="self.available:Available:boolean:true|self.price:Price:number:0|self.reqRank:Rank:number:0|MAX_AT_SPAWN:Max saved:number" installPolicy="mergeRows" rowLabel="comment"
CTLDPrices = {
  ["Engineer soldier"]       = { available = true, price = 50, reqRank = 1 }, -- Blue Engineer soldier
  ["Squad 8"]                = { available = true, price = 50, reqRank = 1 }, -- Blue Squad 8
  ["Platoon 16"]             = { available = true, price = 100, reqRank = 1 }, -- Blue Platoon 16
  ["Platoon 32"]             = { available = true, price = 200, reqRank = 1 }, -- Blue Platoon 32
  ["Anti-Air Soldiers"]      = { available = true, price = 100, reqRank = 1 }, -- Blue Anti-Air Soldiers
  ["Mortar Squad"]           = { available = true, price = 100, reqRank = 1 }, -- Blue Mortar Squad
  ["Zone Spy"]               = { available = true, price = 100, reqRank = 2 }, -- Blue Zone Spy
  ["Demolition Team"]        = { available = true, price = 100, reqRank = 2 }, -- Blue Demolition Team
  ["Mephisto"]               = { available = true, price = 250, reqRank = 2 }, -- Blue Mephisto
  ["Humvee"]                 = { available = true, price = 250, reqRank = 1 }, -- Blue Humvee
  ["Bradly"]                 = { available = true, price = 250, reqRank = 1 }, -- Blue Bradly
  ["L118"]                   = { available = true, price = 150, reqRank = 1 }, -- Blue L118
  ["Ammo Truck"]             = { available = true, price = 100, reqRank = 1 }, -- Ammo Truck
  ["Humvee scout"]           = { available = true, price = 100, reqRank = 1 }, -- Blue Humvee scout
  ["Linebacker"]             = { available = true, price = 300, reqRank = 2 }, -- Blue Linebacker
  ["Vulcan"]                 = { available = true, price = 300, reqRank = 2 }, -- Blue Vulcan
  ["HAWK System"]            = { available = true, price = 750, reqRank = 3 }, -- Blue HAWK System
  ["Hawk TR Add-on"]         = { available = true, price = 250, reqRank = 3 }, -- Blue Hawk TR Add-on
  ["Hawk SR Add-on"]         = { available = true, price = 250, reqRank = 3 }, -- Blue Hawk SR Add-on
  ["Hawk LN Add-on"]         = { available = true, price = 250, reqRank = 3 }, -- Blue Hawk LN Add-on
  ["NASAMS System"]          = { available = true, price = 750, reqRank = 3 }, -- Blue NASAMS System
  ["NASAMS C2 Add-on"]       = { available = true, price = 250, reqRank = 3 }, -- Blue NASAMS C2 Add-on
  ["NASAMS SR Add-on"]       = { available = true, price = 250, reqRank = 3 }, -- Blue NASAMS SR Add-on
  ["NASAMS LN Add-on"]       = { available = true, price = 250, reqRank = 3 }, -- Blue NASAMS LN Add-on
  ["FARP"]                   = { available = true, price = 500, reqRank = 1 }, -- FARP
  ["FARP with ZELL"]         = { available = true, price = 750, reqRank = 1 }, -- FARP with ZELL
  ["IRIS T STR Add-on"]      = { available = true, price = 750, reqRank = 3 }, -- Blue IRIS T STR Add-on
  ["IRIS T LN Add-on"]       = { available = true, price = 500, reqRank = 3 }, -- Blue IRIS T LN Add-on
  ["IRIS T C2 Add-on"]       = { available = true, price = 500, reqRank = 3 }, -- Blue IRIS T C2 Add-on
  ["IRIS T System"]          = { available = true, price = 1800, reqRank = 3 }, -- Blue IRIS T System
  ["C-RAM"]                  = { available = true, price = 500, reqRank = 2 }, -- Blue C-RAM
  -- @gui visibleWhen="PvP:true;Era:Modern"
  ["Pantsir S1"]             = { available = true, price = 500, reqRank = 2 }, -- Blue Pantsir S1
  -- @gui visibleWhen="PvP:true;Era:Modern"
  ["Tor M2"]                 = { available = true, price = 500, reqRank = 2 }, -- Red Tor M2
  ["HIMARS GMLRRS HE GUIDED"]= { available = true, price = 1000, reqRank = 3 }, -- Blue HIMARS GMLRRS HE GUIDED
  ["FV-107 Scimitar"]        = { available = true, price = 250, reqRank = 2 }, -- Blue FV-107 Scimitar
  ["FV-101 Scorpion"]        = { available = true, price = 250, reqRank = 2 }, -- Blue FV-101 Scorpion
  ["Avenger"]                = { available = true, price = 250, reqRank = 2 }, -- Blue Avenger
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Squad 4 AK47"] = { available = true, price = 25, reqRank = 1 }, -- Red Squad 4 AK47
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Squad 8 AK47"] = { available = true, price = 50, reqRank = 1 }, -- Red Squad 8 AK47
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Scout BRDM 2"] = { available = true, price = 100, reqRank = 1 }, -- Red Scout BRDM 2
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Arty SPH 253 Akatsia 8 NM"] = { available = true, price = 150, reqRank = 1 }, -- Red Arty SPH 253 Akatsia 8 NM
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Arty SPM 259 Nona 3 NM"] = { available = true, price = 150, reqRank = 1 }, -- Red Arty SPM 259 Nona 3 NM
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["MLRS LC 80 MM 2.2 NM"] = { available = true, price = 150, reqRank = 1 }, -- Red MLRS LC 80 MM 2.2 NM
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["ATGM AT-3 SAGGER"] = { available = true, price = 250, reqRank = 2 }, -- Red ATGM AT-3 SAGGER
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Kord 12.7 MM"] = { available = true, price = 100, reqRank = 1 }, -- Red Kord 12.7 MM
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["MRAP M-ATV"] = { available = true, price = 100, reqRank = 1 }, -- Red MRAP M-ATV
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Truck with ZU-23"] = { available = true, price = 300, reqRank = 2 }, -- Red Truck with ZU-23
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["SA-8"] = { available = true, price = 300, reqRank = 2 }, -- Red SA-8
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["SA-3 SAM system"] = { available = true, price = 750, reqRank = 3 }, -- Red SA-3 SAM system
}

-- MAX_AT_SPAWN is how many units of each should load from the save file after the last session.
-- @gui installPolicy="replaceTable" rowLabel="comment"
MAX_AT_SPAWN = {
    ["Engineer soldier"]        = 0, -- Blue Engineer soldier
    ["Mephisto"]                = 2, -- Blue Mephisto
    ["Humvee"]                  = 2, -- Blue Humvee
    ["Bradly"]                  = 2, -- Blue Bradly
    ["L118"]                    = 3, -- Blue L118
    ["Ammo Truck"]              = 3, -- Ammo Truck
    ["Humvee scout"]            = 1, -- Blue Humvee scout
    ["Squad 8"]                 = 0, -- Blue Squad 8
    ["Platoon 16"]              = 0, -- Blue Platoon 16
    ["Platoon 32"]              = 0, -- Blue Platoon 32
    ["Anti-Air Soldiers"]       = 2, -- Blue Anti-Air Soldiers
    ["Mortar Squad"]            = 2, -- Blue Mortar Squad
    ["Zone Spy"]                = 0, -- Blue Zone Spy
    ["Demolition Team"]         = 0, -- Blue Demolition Team
    ["Linebacker"]              = 2, -- Blue Linebacker
    ["Vulcan"]                  = 2, -- Blue Vulcan
    ["HAWK System"]             = 3, -- Blue HAWK System
    ["Hawk TR Add-on"]          = 3, -- Blue Hawk TR Add-on
    ["Hawk SR Add-on"]          = 3, -- Blue Hawk SR Add-on
    ["Hawk LN Add-on"]          = 8, -- Blue Hawk LN Add-on
    ["NASAMS System"]           = 3, -- Blue NASAMS System
    ["NASAMS C2 Add-on"]        = 3, -- Blue NASAMS C2 Add-on
    ["NASAMS SR Add-on"]        = 3, -- Blue NASAMS SR Add-on
    ["NASAMS LN Add-on"]        = 8, -- Blue NASAMS LN Add-on
    ["FARP"]                    = 3, -- FARP
    ["IRIS T STR Add-on"]       = 3, -- Blue IRIS T STR Add-on
    ["IRIS T LN Add-on"]        = 8, -- Blue IRIS T LN Add-on
    ["IRIS T C2 Add-on"]        = 3, -- Blue IRIS T C2 Add-on
    ["IRIS T System"]           = 2, -- Blue IRIS T System
    ["C-RAM"]                   = 4, -- Blue C-RAM
    -- @gui visibleWhen="PvP:true;Era:Modern"
    ["Pantsir S1"]              = 4, -- Blue Pantsir S1
    ["HIMARS GMLRRS HE GUIDED"] = 4, -- Blue HIMARS GMLRRS HE GUIDED
    ["FV-107 Scimitar"]         = 2, -- Blue FV-107 Scimitar
    ["FV-101 Scorpion"]         = 2, -- Blue FV-101 Scorpion
    ["Avenger"]                 = 2, -- Blue Avenger
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Squad 4 AK47"] = 0, -- Red Squad 4 AK47
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Squad 8 AK47"] = 0, -- Red Squad 8 AK47
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Scout BRDM 2"] = 1, -- Red Scout BRDM 2
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Arty SPH 253 Akatsia 8 NM"] = 3, -- Red Arty SPH 253 Akatsia 8 NM
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Arty SPM 259 Nona 3 NM"] = 3, -- Red Arty SPM 259 Nona 3 NM
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["MLRS LC 80 MM 2.2 NM"] = 3, -- Red MLRS LC 80 MM 2.2 NM
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["ATGM AT-3 SAGGER"] = 2, -- Red ATGM AT-3 SAGGER
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Kord 12.7 MM"] = 1, -- Red Kord 12.7 MM
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["MRAP M-ATV"] = 1, -- Red MRAP M-ATV
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["Truck with ZU-23"] = 2, -- Red Truck with ZU-23
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["SA-8"] = 2, -- Red SA-8
    -- @gui visibleWhen="PvP|Allow_Red_CTLD:true"
    ["SA-3 SAM system"] = 3, -- Red SA-3 SAM system
    -- @gui visibleWhen="PvP:true;Era:Modern"
    ["Tor M2"] = 4, -- Red Tor M2
}

-- If true, engineers can capture/upgrade zones via CTLD.
-- If false, only regular troops can capture/upgrade zones.
CaptureZoneWithEngineer = false


-- MAX_SAVED_FARPS is how many farps should load from the save file after the last session.
-- @gui disabledWhen="PvP:true"
MAX_SAVED_FARPS      = 3

-- IRIS merge behavior toggle.
-- true  = merge from full template (destroyed IRIS units can come back on merge).
-- false = merge from currently alive IRIS composition + the new added unit.
-- Note: this is session-only merge behavior; CTLD save/load logic is unchanged.
IRIS_RESTORE_UNIT_HEALTH_ON_MERGE = false

-- Define per-airframe CTLD load capabilities.
--
-- Each entry is:
--   { Crates, Troops, Crate limit, Troop limit, Length, Cargo weight }
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
-- @gui installPolicy="mergeRows" editor="checkboxTable"
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
	['F-14BU'] = false,
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

-- @gui label="Enable EWRS" validValues="Enabled=true | Disabled=false"
ewrs_enabled = true -- Enable EWRS reports and F10 menus. Requires mission restart; load the config before EWRS.lua.

-- @gui validValues="Style 1=1 | Style 2=2"
ewrs_defaultReportStyle = 2 -- Default EWRS report format. Style 1 keeps the current format. Style 2 uses compact separator lines. Players can change this via the F10 EWRS menu.

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
ewrs_maxFriendlyDisplay = 3 -- Max friendly aircraft shown in friendly picture reports. Set to 0 to show all.
ewrs_showType = true -- If true, EWRS reports aircraft type. If false, EWRS reports Unknown.
ewrs_mergedRangeNm = 5 -- Style 2 only. Hostile contacts under this range show Merged. Set to 0 to disable.
-- @gui installPolicy="mergeRows" editor="checkboxTable"
ewrs_specialPlaneTypes = { -- Aircraft typeNames that show friendlies by default. Players can still override this in their F10 EWRS menu.
  ["F-4E-45MC"] = true,
  ["MiG-29 Fulcrum"] = true,
  ["F-5E-3_FC"] = true,
  ["C-130J-30"] = true,
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
-- Aircraft / Weapons
-- ============================================================================

-- Optional national warehouse aircraft lists. Legacy era rules remain when disabled.
-- This controls warehouse aircraft availability, not Mission Editor client slots.
-- @gui label="Different aircraft per coalition (PvP)" visibleWhen="PvP:true"
PvPSeparateAircraftLists = false

-- Shared aircraft requirements for the Config Manager; Lua ignores these comments.
-- requiredSet defines reusable rules; requiredEach reads every row of its source table.
-- $ selects the current row, and {key} keeps the explanation linked to that row.
-- E-3A AWACS spawns in the air; its warehouse aircraft entries are optional.
-- Used by: allowedPlanesModern
-- @gui requiredSet="AircraftRequirements01" requiredValuesFrom="BlueCapPlaneEnabled|BlueCasPlaneEnabled|BlueSeadPlaneEnabled|BlueCasHeloEnabled|BlueSupplyHeloEnabled|AvailableShopItems.dynamiccap|AvailableShopItems.dynamiccas|AvailableShopItems.dynamicsead|AvailableShopItems.dynamicdecoy|AvailableShopItems.dynamicbomb|AvailableShopItems.strategicbomber|AvailableShopItems.dynamicarco|AvailableShopItems.dynamictexaco|pvp_supplies"
-- Used by: allowedPlanesModern, allowedPlanes, allowedPlanesSharedColdwarPvP, allowedPlanesBlueColdwarPvP
-- @gui requiredSet="AircraftRequirements02" requiredValues="S-3B Tanker" requiredReason="Caucasus BLUE carrier recovery tanker"
-- Used by: allowedPlanesModern, allowedPlanesRedModern, allowedPlanesSharedVietnamPvP, allowedPlanesBlueVietnamPvP, allowedPlanesRedVietnamPvP
-- @gui requiredSet="AircraftRequirements03" requiredValues="F-16C_50" requiredEach="EscortTypeByPlayerType" requiredWhen="PvPEscorts:true;$[1]:true;$[2]:2" requiredReason="Player escort for {key}"
-- @gui requiredSet="AircraftRequirements03" requiredValues="MiG-29S" requiredEach="EscortTypeByPlayerType" requiredWhen="PvPEscorts:true;$[1]:true;$[2]:3" requiredReason="Player escort for {key}"
-- Used by: allowedPlanesModern, allowedPlanesRedModern, allowedPlanesSharedColdwarPvP, allowedPlanesBlueColdwarPvP, allowedPlanesRedColdwarPvP, allowedPlanesSharedVietnamPvP, allowedPlanesBlueVietnamPvP, allowedPlanesRedVietnamPvP
-- @gui requiredSet="AircraftRequirements04" requiredValues="FA-18C_hornet" requiredEach="EscortTypeByPlayerType" requiredWhen="PvPEscorts:true;$[1]:true;$[2]!:2|3" requiredReason="Player escort for {key}"
-- Used by: allowedPlanesModern, allowedPlanes, allowedPlanesSharedColdwarPvP, allowedPlanesBlueColdwarPvP, allowedPlanesVietnam, allowedPlanesSharedVietnamPvP, allowedPlanesBlueVietnamPvP
-- @gui requiredSet="AircraftRequirements05" requiredValues="C-130J-30" requiredWhen="AvailableShopItems.supplies2:true;AllowScriptedSupplies:false" requiredSource="AvailableShopItems.supplies2" requiredReason="Paid plane-capable zone resupply"
-- @gui requiredSet="AircraftRequirements05" requiredValues="C-130J-30" requiredWhen="AvailableShopItems.capture:true" requiredSource="AvailableShopItems.capture" requiredReason="Paid plane-capable neutral capture"
-- Used by: allowedPlanesRedModern, allowedPlanesSharedColdwarPvP, allowedPlanesRedColdwarPvP, allowedPlanesSharedVietnamPvP, allowedPlanesRedVietnamPvP
-- @gui requiredSet="AircraftRequirements06" requiredValuesFrom="RedCapPlaneEnabled|RedCasPlaneEnabled|RedSeadPlaneEnabled|RedRunwayStrikePlaneEnabled|RedCasHeloEnabled|RedSupplyHeloEnabled"
-- @gui requiredSet="AircraftRequirements06" requiredValues="IL-76MD|An-30M" requiredWhen="AvailableShopItems.supplies2:true;AllowScriptedSupplies:false" requiredSource="AvailableShopItems.supplies2" requiredReason="Paid plane-capable zone resupply"
-- @gui requiredSet="AircraftRequirements06" requiredValues="IL-76MD|An-30M" requiredWhen="AvailableShopItems.capture:true" requiredSource="AvailableShopItems.capture" requiredReason="Paid plane-capable neutral capture"
-- Used by: allowedPlanesRedModern
-- @gui requiredSet="AircraftRequirements07" requiredValues="MiG-29S" requiredWhen="AvailableShopItems.dynamiccap:true" requiredSource="AvailableShopItems.dynamiccap" requiredReason="paid CAP"
-- @gui requiredSet="AircraftRequirements07" requiredValues="Su-25T" requiredWhen="AvailableShopItems.dynamiccas:true" requiredSource="AvailableShopItems.dynamiccas" requiredReason="paid CAS"
-- @gui requiredSet="AircraftRequirements07" requiredValues="JF-17" requiredWhen="AvailableShopItems.dynamicsead:true" requiredSource="AvailableShopItems.dynamicsead" requiredReason="paid SEAD"
-- @gui requiredSet="AircraftRequirements07" requiredValues="JF-17" requiredWhen="AvailableShopItems.dynamicbomb:true" requiredSource="AvailableShopItems.dynamicbomb" requiredReason="ordinary paid Bomber"
-- @gui requiredSet="AircraftRequirements07" requiredValues="Tu-22M3" requiredWhen="AvailableShopItems.strategicbomber:true" requiredSource="AvailableShopItems.strategicbomber" requiredReason="paid Strategic Bomber"
-- @gui requiredSet="AircraftRequirements07" requiredValues="KC135MPRS" requiredWhen="AvailableShopItems.dynamicarco:true" requiredSource="AvailableShopItems.dynamicarco" requiredReason="paid drogue tanker"
-- @gui requiredSet="AircraftRequirements07" requiredValues="KC-135" requiredWhen="AvailableShopItems.dynamictexaco:true" requiredSource="AvailableShopItems.dynamictexaco" requiredReason="paid boom tanker"
-- @gui requiredSet="AircraftRequirements07" requiredValues="IL-76MD|An-30M" requiredWhen="pvp_supplies:true" requiredSource="pvp_supplies" requiredReason="automatic regular fixed-wing supply"
-- Used by: allowedPlanesRedModern, allowedPlanesSharedColdwarPvP, allowedPlanesRedColdwarPvP
-- @gui requiredSet="AircraftRequirements08" requiredValues="A-50" requiredReason="Caucasus RED automatic AWACS"
-- Used by: allowedPlanes, allowedPlanesSharedColdwarPvP, allowedPlanesBlueColdwarPvP, allowedPlanesVietnam, allowedPlanesSharedVietnamPvP, allowedPlanesBlueVietnamPvP
-- @gui requiredSet="AircraftRequirements09" requiredValuesFrom="BlueCapPlaneEnabled|BlueCasPlaneEnabled|BlueSeadPlaneEnabled|BlueCasHeloEnabled|BlueSupplyHeloEnabled"
-- Used by: allowedPlanes, allowedPlanesSharedColdwarPvP, allowedPlanesBlueColdwarPvP
-- @gui requiredSet="AircraftRequirements10" requiredValues="F-14A-135-GR" requiredWhen="AvailableShopItems.dynamiccap:true" requiredSource="AvailableShopItems.dynamiccap" requiredReason="Coldwar CAP flight"
-- @gui requiredSet="AircraftRequirements10" requiredValues="F-4E-45MC" requiredWhen="AvailableShopItems.dynamiccas:true" requiredSource="AvailableShopItems.dynamiccas" requiredReason="Coldwar CAS flight"
-- @gui requiredSet="AircraftRequirements10" requiredValues="Tornado IDS" requiredWhen="AvailableShopItems.dynamicsead:true" requiredSource="AvailableShopItems.dynamicsead" requiredReason="Coldwar SEAD flight"
-- @gui requiredSet="AircraftRequirements10" requiredValues="F-14B" requiredWhen="AvailableShopItems.dynamicdecoy:true" requiredSource="AvailableShopItems.dynamicdecoy" requiredReason="Coldwar Decoy flight"
-- @gui requiredSet="AircraftRequirements10" requiredValues="F-4E-45MC" requiredWhen="AvailableShopItems.dynamicbomb:true" requiredSource="AvailableShopItems.dynamicbomb" requiredReason="Coldwar Bomber flight"
-- @gui requiredSet="AircraftRequirements10" requiredValues="B-52H" requiredWhen="AvailableShopItems.strategicbomber:true" requiredSource="AvailableShopItems.strategicbomber" requiredReason="Coldwar Strategic Bomber"
-- Used by: allowedPlanes, allowedPlanesSharedColdwarPvP, allowedPlanesBlueColdwarPvP, allowedPlanesRedColdwarPvP, allowedPlanesVietnam, allowedPlanesSharedVietnamPvP, allowedPlanesBlueVietnamPvP, allowedPlanesRedVietnamPvP
-- @gui requiredSet="AircraftRequirements11" requiredValues="KC135MPRS" requiredWhen="AvailableShopItems.dynamicarco:true" requiredSource="AvailableShopItems.dynamicarco" requiredReason="Drogue tanker"
-- @gui requiredSet="AircraftRequirements11" requiredValues="KC-135" requiredWhen="AvailableShopItems.dynamictexaco:true" requiredSource="AvailableShopItems.dynamictexaco" requiredReason="Boom tanker"
-- Used by: allowedPlanes, allowedPlanesVietnam
-- @gui requiredSet="AircraftRequirements12" requiredValues="F-4E-45MC" requiredWhen="AvailableShopItems.dynamicstatic:true" requiredSource="AvailableShopItems.dynamicstatic" requiredReason="Static building strike"
-- @gui requiredSet="AircraftRequirements12" requiredValues="F-14A-135-GR" requiredWhen="AvailableShopItems.jtac:true" requiredSource="AvailableShopItems.jtac" requiredReason="JTAC flight"
-- @gui requiredSet="AircraftRequirements12" requiredValues="F-14A-135-GR" requiredWhen="AvailableShopItems.9lineam:true" requiredSource="AvailableShopItems.9lineam" requiredReason="9-line AM JTAC"
-- @gui requiredSet="AircraftRequirements12" requiredValues="F-14A-135-GR" requiredWhen="AvailableShopItems.9linefm:true" requiredSource="AvailableShopItems.9linefm" requiredReason="9-line FM JTAC"
-- @gui requiredSet="AircraftRequirements12" requiredValues="C-130J-30" requiredWhen="NoAIBlueSupplies:false" requiredSource="NoAIBlueSupplies" requiredReason="Automatic regular fixed-wing supply"
-- @gui requiredSet="AircraftRequirements12" requiredValues="FA-18C_hornet" requiredEach="EscortTypeByPlayerType" requiredWhen="$[1]:true;$[2]!:2|3" requiredReason="Player escort for {key}"
-- @gui requiredSet="AircraftRequirements12" requiredValues="C-130J-30" requiredWhen="AvailableShopItems.advancecapture:true" requiredSource="AvailableShopItems.advancecapture" requiredReason="Paid plane-capable advance capture at eligible airbase target"
-- Used by: allowedPlanes
-- @gui requiredSet="AircraftRequirements13" requiredValues="F-15C" requiredEach="EscortTypeByPlayerType" requiredWhen="$[1]:true;$[2]:2" requiredReason="Player escort for {key}"
-- @gui requiredSet="AircraftRequirements13" requiredValues="MiG-29 Fulcrum" requiredEach="EscortTypeByPlayerType" requiredWhen="$[1]:true;$[2]:3" requiredReason="Player escort for {key}"
-- Used by: allowedPlanesSharedColdwarPvP, allowedPlanesBlueColdwarPvP, allowedPlanesSharedVietnamPvP, allowedPlanesBlueVietnamPvP
-- @gui requiredSet="AircraftRequirements14" requiredValues="C-130J-30" requiredWhen="pvp_supplies:true" requiredSource="pvp_supplies" requiredReason="Automatic regular fixed-wing supply"
-- Used by: allowedPlanesSharedColdwarPvP, allowedPlanesBlueColdwarPvP, allowedPlanesRedColdwarPvP
-- @gui requiredSet="AircraftRequirements15" requiredValues="F-15C" requiredEach="EscortTypeByPlayerType" requiredWhen="PvPEscorts:true;$[1]:true;$[2]:2" requiredReason="Player escort for {key}"
-- @gui requiredSet="AircraftRequirements15" requiredValues="MiG-29 Fulcrum" requiredEach="EscortTypeByPlayerType" requiredWhen="PvPEscorts:true;$[1]:true;$[2]:3" requiredReason="Player escort for {key}"
-- Used by: allowedPlanesSharedColdwarPvP, allowedPlanesRedColdwarPvP
-- @gui requiredSet="AircraftRequirements16" requiredValues="MiG-29 Fulcrum" requiredWhen="AvailableShopItems.dynamiccap:true" requiredSource="AvailableShopItems.dynamiccap" requiredReason="Coldwar CAP flight"
-- @gui requiredSet="AircraftRequirements16" requiredValues="Su-25" requiredWhen="AvailableShopItems.dynamiccas:true" requiredSource="AvailableShopItems.dynamiccas" requiredReason="Coldwar CAS flight"
-- @gui requiredSet="AircraftRequirements16" requiredValues="Su-24M" requiredWhen="AvailableShopItems.dynamicsead:true" requiredSource="AvailableShopItems.dynamicsead" requiredReason="Coldwar SEAD flight"
-- @gui requiredSet="AircraftRequirements16" requiredValues="Su-25" requiredWhen="AvailableShopItems.dynamicbomb:true" requiredSource="AvailableShopItems.dynamicbomb" requiredReason="Coldwar Bomber flight"
-- @gui requiredSet="AircraftRequirements16" requiredValues="Tu-95MS" requiredWhen="AvailableShopItems.strategicbomber:true" requiredSource="AvailableShopItems.strategicbomber" requiredReason="Coldwar Strategic Bomber"
-- Used by: allowedPlanesSharedColdwarPvP, allowedPlanesRedColdwarPvP, allowedPlanesSharedVietnamPvP, allowedPlanesRedVietnamPvP
-- @gui requiredSet="AircraftRequirements17" requiredValues="IL-76MD|An-30M" requiredWhen="pvp_supplies:true" requiredSource="pvp_supplies" requiredReason="Automatic regular fixed-wing supply"
-- Used by: allowedPlanesVietnam, allowedPlanesSharedVietnamPvP, allowedPlanesBlueVietnamPvP
-- @gui requiredSet="AircraftRequirements18" requiredValues="F-4E-45MC" requiredWhen="AvailableShopItems.dynamiccap:true" requiredSource="AvailableShopItems.dynamiccap" requiredReason="Vietnam CAP flight"
-- @gui requiredSet="AircraftRequirements18" requiredValues="F-4E-45MC" requiredWhen="AvailableShopItems.dynamiccas:true" requiredSource="AvailableShopItems.dynamiccas" requiredReason="Vietnam CAS flight"
-- @gui requiredSet="AircraftRequirements18" requiredValues="F-4E-45MC" requiredWhen="AvailableShopItems.dynamicsead:true" requiredSource="AvailableShopItems.dynamicsead" requiredReason="Vietnam SEAD flight"
-- @gui requiredSet="AircraftRequirements18" requiredValues="F-100D" requiredWhen="AvailableShopItems.dynamicbomb:true" requiredSource="AvailableShopItems.dynamicbomb" requiredReason="Vietnam Bomber flight"
-- @gui requiredSet="AircraftRequirements18" requiredValues="E-2C" requiredReason="Caucasus blue automatic AWACS"
-- Used by: allowedPlanesVietnam
-- @gui requiredSet="AircraftRequirements19" requiredValues="FA-18C_hornet" requiredWhen="AvailableShopItems.dynamicdecoy:true" requiredSource="AvailableShopItems.dynamicdecoy" requiredReason="Vietnam Decoy flight"
-- @gui requiredSet="AircraftRequirements19" requiredValues="F-16C_50" requiredEach="EscortTypeByPlayerType" requiredWhen="$[1]:true;$[2]:2" requiredReason="Player escort for {key}"
-- @gui requiredSet="AircraftRequirements19" requiredValues="MiG-29S" requiredEach="EscortTypeByPlayerType" requiredWhen="$[1]:true;$[2]:3" requiredReason="Player escort for {key}"
-- Used by: allowedPlanesSharedVietnamPvP, allowedPlanesRedVietnamPvP
-- @gui requiredSet="AircraftRequirements20" requiredValues="MiG-29 Fulcrum" requiredWhen="AvailableShopItems.dynamiccap:true" requiredSource="AvailableShopItems.dynamiccap" requiredReason="Vietnam CAP flight"
-- @gui requiredSet="AircraftRequirements20" requiredValues="MiG-19P" requiredWhen="AvailableShopItems.dynamiccas:true" requiredSource="AvailableShopItems.dynamiccas" requiredReason="Vietnam CAS flight"
-- @gui requiredSet="AircraftRequirements20" requiredValues="Su-17M4" requiredWhen="AvailableShopItems.dynamicsead:true" requiredSource="AvailableShopItems.dynamicsead" requiredReason="Vietnam SEAD flight"
-- @gui requiredSet="AircraftRequirements20" requiredValues="MiG-15bis" requiredWhen="AvailableShopItems.dynamicbomb:true" requiredSource="AvailableShopItems.dynamicbomb" requiredReason="Vietnam Bomber flight"
-- @gui requiredSet="AircraftRequirements20" requiredValues="A-50" requiredReason="Caucasus red automatic AWACS"

-- Allowed BLUE warehouse aircraft in Modern PvP when separate lists are enabled.
-- @gui label="Modern Allowed BLUE Aircraft" installPolicy="mergeRows" newItemPolicy="commentWhenVisible" editor="bucket" visibleWhen="Era:Modern;PvP:true;PvPSeparateAircraftLists:true"
-- @gui requiredSets="AircraftRequirements01|AircraftRequirements02|AircraftRequirements03|AircraftRequirements04|AircraftRequirements05" requiredWhen="Era:Modern;PvP:true;PvPSeparateAircraftLists:true"
allowedPlanesModern = {
    "A-10A",
    "A-10C",
    "A-10C_2",
    "AV8BNA",
    "F-14B",
    "F-15C",
    "F-15ESE",
    "F-16C_50",
    "FA-18C_hornet",
    "M-2000C",
    "AH-64D_BLK_II",
    "CH-47Fbl1",
    "C-130J-30",
    "UH-1H",
    "OH58D",
    "AH-1W",
    "B-1B",
    "E-3A",
    "F-15E",
    "F-4E-45MC",
    "KC-135",
    "KC135MPRS",
    "S-3B Tanker",
    "SA342M",
    --"MiG-29A",
    --"MiG-29S",
    --"MiG-29 Fulcrum",
    --"Su-27",
    --"Su-33",
    --"Su-25",
    --"Su-25T",
    --"MiG-21Bis",
    --"Mi-24P",
    --"Mi-8MT",
    --"Ka-50",
    --"Ka-50_3",
    --"L-39C",
    --"A-50",
    --"An-26B",
    --"An-30M",
    --"IL-76MD",
    --"JF-17",
    --"Mi-28N",
    --"MiG-23MLD",
    --"MiG-25PD",
    --"MiG-27K",
    --"MiG-31",
    --"Mirage-F1BQ",
    --"Mirage-F1CE",
    --"Mirage-F1EE",
    --"Su-24M",
    --"Su-34",
    --"Tu-22M3",
    --"Tu-95MS",
    --"A-4E-C",
    --"AH-6J",
    --"AJS37",
    --"Bronco-OV-10A",
    --"C-101CC",
    --"E-2C",
    --"F/A-18A",
    --"F-100D",
    --"F-14A",
    --"F-14A-135-GR",
    --"F-14A-135-GR-Early",
    --"F-14A-95-GR",
    --"F-14BU",
    --"F-16A MLU",
    --"F-5E-3",
    --"F-5E-3_FC",
    --"F-86F Sabre",
    --"Hercules",
    --"Ka-27",
    --"MB-339A",
    --"MB-339APAN",
    --"MH-60R",
    --"MH-6J",
    --"Mi-24V",
    --"Mi-28NE",
    --"MiG-15bis",
    --"MiG-15bis_FC",
    --"MiG-19P",
    --"Mirage-F1AD",
    --"Mirage-F1AZ",
    --"Mirage-F1B",
    --"Mirage-F1BD",
    --"Mirage-F1BE",
    --"Mirage-F1C",
    --"Mirage-F1C-200",
    --"Mirage-F1CG",
    --"Mirage-F1CH",
    --"Mirage-F1CJ",
    --"Mirage-F1CK",
    --"Mirage-F1CR",
    --"Mirage-F1CT",
    --"Mirage-F1CZ",
    --"Mirage-F1DDA",
    --"Mirage-F1ED",
    --"Mirage-F1EDA",
    --"Mirage-F1EH",
    --"Mirage-F1EQ",
    --"Mirage-F1M-CE",
    --"Mirage-F1M-EE",
    --"OH-6A",
    --"P3C_Orion",
    --"SA342L",
    --"SA342Minigun",
    --"SA342Mistral",
    --"SU22",
    --"Su-24MR",
    --"UH-60A",
    --"UH-60L",
    --"UH-60L_DAP",
    --"Su-17M4",
    --"A-29B",
    --"B-52H",
    --"Bell-47",
    --"EA-18G",
    --"Eurofighter",
    --"EurofighterT",
    --"F111C",
    --"F15EX",
    --"F16A",
    --"F16A_AA",
    --"F-22A",
    --"F-23A",
    --"FA-18E",
    --"FA-18ET",
    --"FA-18F",
    --"FA-18FT",
    --"JAS39Gripen",
    --"JAS39Gripen_AG",
    --"JAS39Gripen_BVR",
    --"M2000D",
    --"MiG-31BM",
    --"SK-60",
    --"Su-25SM3",
    --"Su-30MKA",
    --"Su-30MKI",
    --"Su-30MKM",
    --"Su-30SM",
    --"Su-35",
    --"PUCARA",
    --"Su-35S",
    --"T-45",
    --"F-86F_FC",
}

-- Allowed RED warehouse aircraft in Modern PvP when separate lists are enabled.
-- @gui label="Modern Allowed RED Aircraft" installPolicy="mergeRows" newItemPolicy="commentWhenVisible" editor="bucket" visibleWhen="Era:Modern;PvP:true;PvPSeparateAircraftLists:true"
-- @gui requiredSets="AircraftRequirements06|AircraftRequirements07|AircraftRequirements08|AircraftRequirements03|AircraftRequirements04" requiredWhen="Era:Modern;PvP:true;PvPSeparateAircraftLists:true"
allowedPlanesRedModern = {
    "MiG-29A",
    "MiG-29S",
    "MiG-29 Fulcrum",
    "Su-27",
    "Su-33",
    "Su-25",
    "Su-25T",
    "MiG-21Bis",
    "Mi-24P",
    "Mi-8MT",
    "Ka-50",
    "Ka-50_3",
    "L-39C",
    "A-50",
    "An-26B",
    "An-30M",
    "IL-76MD",
    "JF-17",
    "KC-135",
    "KC135MPRS",
    "Mi-28N",
    "MiG-23MLD",
    "MiG-25PD",
    "MiG-27K",
    "MiG-31",
    "Mirage-F1BQ",
    "Mirage-F1CE",
    "Mirage-F1EE",
    "Su-24M",
    "Su-34",
    "Tu-22M3",
    "Tu-95MS",
    --"A-10A",
    --"A-10C",
    --"A-10C_2",
    --"AV8BNA",
    --"F-14B",
    --"F-15C",
    --"F-15ESE",
    --"F-16C_50",
    --"FA-18C_hornet",
    --"M-2000C",
    --"AH-64D_BLK_II",
    --"CH-47Fbl1",
    --"C-130J-30",
    --"UH-1H",
    --"OH58D",
    --"AH-1W",
    --"B-1B",
    "E-3A",
    --"F-15E",
    --"F-4E-45MC",
    --"S-3B Tanker",
    --"SA342M",
    --"A-4E-C",
    --"AH-6J",
    --"AJS37",
    --"Bronco-OV-10A",
    --"C-101CC",
    --"E-2C",
    --"F/A-18A",
    --"F-100D",
    --"F-14A",
    --"F-14A-135-GR",
    --"F-14A-135-GR-Early",
    --"F-14A-95-GR",
    --"F-14BU",
    --"F-16A MLU",
    --"F-5E-3",
    --"F-5E-3_FC",
    --"F-86F Sabre",
    --"Hercules",
    --"Ka-27",
    --"MB-339A",
    --"MB-339APAN",
    --"MH-60R",
    --"MH-6J",
    --"Mi-24V",
    --"Mi-28NE",
    --"MiG-15bis",
    --"MiG-15bis_FC",
    --"MiG-19P",
    --"Mirage-F1AD",
    --"Mirage-F1AZ",
    --"Mirage-F1B",
    --"Mirage-F1BD",
    --"Mirage-F1BE",
    --"Mirage-F1C",
    --"Mirage-F1C-200",
    --"Mirage-F1CG",
    --"Mirage-F1CH",
    --"Mirage-F1CJ",
    --"Mirage-F1CK",
    --"Mirage-F1CR",
    --"Mirage-F1CT",
    --"Mirage-F1CZ",
    --"Mirage-F1DDA",
    --"Mirage-F1ED",
    --"Mirage-F1EDA",
    --"Mirage-F1EH",
    --"Mirage-F1EQ",
    --"Mirage-F1M-CE",
    --"Mirage-F1M-EE",
    --"OH-6A",
    --"P3C_Orion",
    --"SA342L",
    --"SA342Minigun",
    --"SA342Mistral",
    --"SU22",
    --"Su-24MR",
    --"UH-60A",
    --"UH-60L",
    --"UH-60L_DAP",
    --"Su-17M4",
    --"A-29B",
    --"B-52H",
    --"Bell-47",
    --"EA-18G",
    --"Eurofighter",
    --"EurofighterT",
    --"F111C",
    --"F15EX",
    --"F16A",
    --"F16A_AA",
    --"F-22A",
    --"F-23A",
    --"FA-18E",
    --"FA-18ET",
    --"FA-18F",
    --"FA-18FT",
    --"JAS39Gripen",
    --"JAS39Gripen_AG",
    --"JAS39Gripen_BVR",
    --"M2000D",
    --"MiG-31BM",
    --"SK-60",
    --"Su-25SM3",
    --"Su-30MKA",
    --"Su-30MKI",
    --"Su-30MKM",
    --"Su-30SM",
    --"Su-35",
    --"PUCARA",
    --"Su-35S",
    --"T-45",
}

-- In this list, you can either remove or add what is allowed in the Coldwar or Gulfwar era.
-- @gui label="Allowed Aircraft" installPolicy="mergeRows" newItemPolicy="commentWhenVisible" editor="bucket" visibleWhen="Era:Coldwar|Gulfwar;PvP:false"
-- @gui requiredSets="AircraftRequirements09|AircraftRequirements10|AircraftRequirements11|AircraftRequirements12|AircraftRequirements02|AircraftRequirements13|AircraftRequirements05" requiredWhen="Era:Coldwar|Gulfwar;PvP:false"
allowedPlanes = {
    "A-10A",
    "A-10C",
    --"A-10C_2",
    "A-4E-C",
    "AH-1W",
    --"AH-64D_BLK_II",
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
    --"F-14BU",
    "F-15C",
    "F-15E",
    "F-15ESE",
    "F-16A MLU",
    "F-16C_50",
    "F-4E-45MC",
    "F-5E-3",
    "F-5E-3_FC",
    "F-86F Sabre",
    --"FA-18C_hornet",
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

-- Shared Coldwar PvP warehouse aircraft for both coalitions when separate lists are disabled.
-- Saved independently from PvE; enabled AI services require their aircraft to remain active.
-- @gui label="Coldwar Allowed Aircraft (PvP)" installPolicy="keepTable" editor="bucket" visibleWhen="Era:Coldwar|Gulfwar;PvP:true;PvPSeparateAircraftLists:false"
-- @gui requiredSets="AircraftRequirements09|AircraftRequirements10|AircraftRequirements11|AircraftRequirements02|AircraftRequirements14|AircraftRequirements15|AircraftRequirements04|AircraftRequirements05|AircraftRequirements06|AircraftRequirements16|AircraftRequirements08|AircraftRequirements17" requiredWhen="Era:Coldwar|Gulfwar;PvP:true;PvPSeparateAircraftLists:false"
allowedPlanesSharedColdwarPvP = {
    "A-10A",
    "A-10C",
    "A-4E-C",
    "AH-1W",
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
    "AH-64D_BLK_II",
    "FA-18C_hornet",
    "B-52H",
    "E-3A",
    "KC-135",
    "KC135MPRS",
    "S-3B Tanker",
    "Tornado IDS",
    "A-50",
    "An-26B",
    "IL-76MD",
    "JF-17",
    "Mi-28N",
    "MiG-25PD",
    "MiG-27K",
    "MiG-29S",
    "MiG-31",
    "Su-24M",
    "Su-25T",
    "Su-27",
    "Su-33",
    "Su-34",
    "Tu-95MS",
    --"A-10C_2",
    --"F-14BU",
    --"F-86F_FC",
    --"Ka-50_3",
    --"Ka-50",
    --"Su-17M4",
}

-- BLUE Coldwar/Gulfwar warehouse aircraft when separate PvP lists are enabled.
-- Legacy aircraft rows remain unchanged; this override also includes enabled AI requirements.
-- @gui label="Coldwar Allowed BLUE Aircraft (PvP)" installPolicy="keepTable" editor="bucket" visibleWhen="Era:Coldwar|Gulfwar;PvP:true;PvPSeparateAircraftLists:true"
-- @gui requiredSets="AircraftRequirements09|AircraftRequirements10|AircraftRequirements11|AircraftRequirements02|AircraftRequirements14|AircraftRequirements15|AircraftRequirements04|AircraftRequirements05" requiredWhen="Era:Coldwar|Gulfwar;PvP:true;PvPSeparateAircraftLists:true"
allowedPlanesBlueColdwarPvP = {
    "A-10A",
    "A-10C",
    --"A-10C_2",
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
    --"F-14BU",
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
    "B-52H",
    "E-3A",
    "KC-135",
    "KC135MPRS",
    "S-3B Tanker",
    "Tornado IDS",
    --"F-86F_FC",
}

-- In this list, you can either remove or add what is allowed for the (RED SIDE) in the Coldwar or Gulfwar era.
-- Legacy compatibility values are retained; the Manager uses the dedicated PvP coalition lists.
-- @gui label="Allowed RED Aircraft" installPolicy="mergeRows" newItemPolicy="commentWhenVisible" editor="bucket" visibleWhen="Era:Coldwar|Gulfwar;PvP:true;PvPSeparateAircraftLists:true;PvP:false"
allowedPlanesRed = {
    "A-10A",
    "A-10C",
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
    "F-100D",
    "F-14A-135-GR",
    "F-14A-135-GR-Early",
    "F-14A-95-GR",
    --"F-14B",
    --"F-14BU",
    --"A-10C_2",
    "F-15C",
    "F-15ESE",
    "F-16C_50",
    "F-4E-45MC",
    "F-5E-3",
    "F-5E-3_FC",
    "F-86F Sabre",
    "FA-18C_hornet",
    "Hercules",
    "L-39C",
    "M-2000C",
    "MB-339A",
    "MB-339APAN",
    "MH-60R",
    "MH-6J",
    "Mi-24P",
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
    "Su-25",
    "UH-1H",
    "UH-60A",
    "UH-60L",
    "UH-60L_DAP",
    --"Ka-50_3",
    --"Ka-50",
}

-- RED Coldwar/Gulfwar warehouse aircraft when separate PvP lists are enabled.
-- Legacy aircraft rows remain unchanged; this override also includes enabled AI requirements.
-- @gui label="Coldwar Allowed RED Aircraft (PvP)" installPolicy="keepTable" editor="bucket" visibleWhen="Era:Coldwar|Gulfwar;PvP:true;PvPSeparateAircraftLists:true"
-- @gui requiredSets="AircraftRequirements06|AircraftRequirements16|AircraftRequirements11|AircraftRequirements08|AircraftRequirements17|AircraftRequirements15|AircraftRequirements04" requiredWhen="Era:Coldwar|Gulfwar;PvP:true;PvPSeparateAircraftLists:true"
allowedPlanesRedColdwarPvP = {
    "A-10A",
    "A-10C",
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
    "F-100D",
    "F-14A-135-GR",
    "F-14A-135-GR-Early",
    "F-14A-95-GR",
    --"F-14B",
    --"F-14BU",
    --"A-10C_2",
    "F-15C",
    "F-15ESE",
    "F-16C_50",
    "F-4E-45MC",
    "F-5E-3",
    "F-5E-3_FC",
    "F-86F Sabre",
    "FA-18C_hornet",
    "Hercules",
    "L-39C",
    "M-2000C",
    "MB-339A",
    "MB-339APAN",
    "MH-60R",
    "MH-6J",
    "Mi-24P",
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
    "Su-25",
    "UH-1H",
    "UH-60A",
    "UH-60L",
    "UH-60L_DAP",
    --"Ka-50_3",
    --"Ka-50",
    "A-50",
    "E-3A",
    "An-26B",
    "IL-76MD",
    "JF-17",
    "KC-135",
    "KC135MPRS",
    "Mi-28N",
    "MiG-25PD",
    "MiG-27K",
    "MiG-29S",
    "MiG-31",
    "Su-24M",
    "Su-25T",
    "Su-27",
    "Su-33",
    "Su-34",
    "Tu-95MS",
    --"Mi-24V",
    --"Su-17M4",
}

-- In this list, you can either remove or add what is allowed for BLUE warehouses in the Vietnam era.
-- @gui label="Vietnam Allowed Aircraft" installPolicy="mergeRows" newItemPolicy="commentWhenVisible" editor="bucket" visibleWhen="Era:Vietnam;PvP:false"
-- @gui requiredSets="AircraftRequirements09|AircraftRequirements18|AircraftRequirements11|AircraftRequirements19|AircraftRequirements12|AircraftRequirements05" requiredWhen="Era:Vietnam;PvP:false"
allowedPlanesVietnam = {
    "A-4E-C",
    "Bronco-OV-10A",
    "CH-47Fbl1",
    "F-100D",
    "F-14A",
    "F-14A-135-GR",
    "F-14A-135-GR-Early",
    "F-14A-95-GR",
    "F-4E-45MC",
    "F-5E-3",
    "F-86F Sabre",
    "OH-6A",
    "UH-1H",
    "Su-17M4",
    --"F-14B",
    --"F-14BU",
    -- "AH-1W",
    -- "C-130J-30",
    -- "F-5E-3_FC",
    -- "Hercules",
    -- "Mi-8MT",
    -- "MiG-15bis",
    -- "MiG-15bis_FC",
    -- "MiG-19P",
    -- "MiG-21Bis",
}

-- Shared Vietnam PvP warehouse aircraft for both coalitions when separate lists are disabled.
-- Saved independently from PvE; enabled AI services require their aircraft to remain active.
-- @gui label="Vietnam Allowed Aircraft (PvP)" installPolicy="keepTable" editor="bucket" visibleWhen="Era:Vietnam;PvP:true;PvPSeparateAircraftLists:false"
-- @gui requiredSets="AircraftRequirements09|AircraftRequirements18|AircraftRequirements11|AircraftRequirements14|AircraftRequirements03|AircraftRequirements04|AircraftRequirements05|AircraftRequirements06|AircraftRequirements20|AircraftRequirements17" requiredWhen="Era:Vietnam;PvP:true;PvPSeparateAircraftLists:false"
allowedPlanesSharedVietnamPvP = {
    "A-4E-C",
    "Bronco-OV-10A",
    "CH-47Fbl1",
    "F-100D",
    "F-14A",
    "F-14A-135-GR",
    "F-14A-135-GR-Early",
    "F-14A-95-GR",
    "F-4E-45MC",
    "F-5E-3",
    "F-86F Sabre",
    "OH-6A",
    "UH-1H",
    "Su-17M4",
    "F-14B",
    "AH-1W",
    "C-130J-30",
    "AH-64D_BLK_II",
    "E-2C",
    "F-15C",
    "F-16C_50",
    "FA-18C_hornet",
    "KC-135",
    "KC135MPRS",
    "M-2000C",
    "OH58D",
    "SA342M",
    "Mi-8MT",
    "MiG-15bis",
    "MiG-15bis_FC",
    "MiG-19P",
    "MiG-21Bis",
    "A-50",
    "E-3A",
    "An-26B",
    "An-30M",
    "IL-76MD",
    "JF-17",
    "Mi-24P",
    "Mi-28N",
    "MiG-23MLD",
    "MiG-25PD",
    "MiG-27K",
    "MiG-29 Fulcrum",
    "MiG-29S",
    "MiG-31",
    "Mirage-F1BQ",
    "Mirage-F1CE",
    "Mirage-F1EE",
    "Su-24M",
    "Su-25T",
    "Su-27",
    "Su-33",
    "Su-34",
    --"F-14BU",
    --"F-5E-3_FC",
    --"Hercules",
    --"F-86F_FC",
    --"SU22",
    --"L-39C",
    --"Mi-24V",
    --"Su-25",
}

-- BLUE Vietnam warehouse aircraft when separate PvP lists are enabled.
-- Legacy aircraft rows remain unchanged; this override also includes enabled AI requirements.
-- @gui label="Vietnam Allowed BLUE Aircraft (PvP)" installPolicy="keepTable" editor="bucket" visibleWhen="Era:Vietnam;PvP:true;PvPSeparateAircraftLists:true"
-- @gui requiredSets="AircraftRequirements09|AircraftRequirements18|AircraftRequirements11|AircraftRequirements14|AircraftRequirements03|AircraftRequirements04|AircraftRequirements05" requiredWhen="Era:Vietnam;PvP:true;PvPSeparateAircraftLists:true"
allowedPlanesBlueVietnamPvP = {
    "A-4E-C",
    "Bronco-OV-10A",
    "CH-47Fbl1",
    "F-100D",
    "F-14A",
    "F-14A-135-GR",
    "F-14A-135-GR-Early",
    "F-14A-95-GR",
    "F-4E-45MC",
    "F-5E-3",
    "F-86F Sabre",
    "OH-6A",
    "UH-1H",
    "Su-17M4",
    "F-14B",
    --"F-14BU",
    "AH-1W",
    "C-130J-30",
    -- "F-5E-3_FC",
    -- "Hercules",
    -- "Mi-8MT",
    -- "MiG-15bis",
    -- "MiG-15bis_FC",
    -- "MiG-19P",
    -- "MiG-21Bis",
    "AH-64D_BLK_II",
    "E-2C",
    "F-15C",
    "F-16C_50",
    "FA-18C_hornet",
    "KC-135",
    "KC135MPRS",
    "M-2000C",
    "OH58D",
    "SA342M",
    --"F-86F_FC",
    --"MiG-29S",
}

-- In this list, you can either remove or add what is allowed for RED warehouses in the Vietnam era.
-- Legacy compatibility values are retained; the Manager uses the dedicated PvP coalition lists.
-- @gui label="Vietnam Allowed RED Aircraft" installPolicy="mergeRows" newItemPolicy="commentWhenVisible" editor="bucket" visibleWhen="Era:Vietnam;PvP:true;PvPSeparateAircraftLists:true;PvP:false"
allowedPlanesRedVietnam = {
    "Mi-8MT",
    "MiG-15bis",
    "MiG-15bis_FC",
    "MiG-19P",
    "MiG-21Bis",
    -- "SU22",
    -- "A-4E-C",
    -- "Bronco-OV-10A",
    -- "CH-47Fbl1",
    -- "F-100D",
    -- "F-14A",
    -- "F-14A-135-GR",
    -- "F-14A-135-GR-Early",
    -- "F-14A-95-GR",
    -- "F-4E-45MC",
    -- "F-5E-3",
    -- "F-86F Sabre",
    -- "OH-6A",
    -- "UH-1H",
    -- "Su-17M4",
}

-- RED Vietnam warehouse aircraft when separate PvP lists are enabled.
-- Legacy aircraft rows remain unchanged; this override also includes enabled AI requirements.
-- @gui label="Vietnam Allowed RED Aircraft (PvP)" installPolicy="keepTable" editor="bucket" visibleWhen="Era:Vietnam;PvP:true;PvPSeparateAircraftLists:true"
-- @gui requiredSets="AircraftRequirements06|AircraftRequirements20|AircraftRequirements11|AircraftRequirements17|AircraftRequirements03|AircraftRequirements04" requiredWhen="Era:Vietnam;PvP:true;PvPSeparateAircraftLists:true"
allowedPlanesRedVietnamPvP = {
    "Mi-8MT",
    "MiG-15bis",
    "MiG-15bis_FC",
    "MiG-19P",
    "MiG-21Bis",
    -- "SU22",
    -- "A-4E-C",
    -- "Bronco-OV-10A",
    -- "CH-47Fbl1",
    -- "F-100D",
    -- "F-14A",
    -- "F-14A-135-GR",
    -- "F-14A-135-GR-Early",
    -- "F-14A-95-GR",
    -- "F-4E-45MC",
    -- "F-5E-3",
    -- "F-86F Sabre",
    -- "OH-6A",
    -- "UH-1H",
    "Su-17M4",
    "A-50",
    "E-3A",
    "An-26B",
    "An-30M",
    "IL-76MD",
    "JF-17",
    "KC-135",
    "KC135MPRS",
    "Mi-24P",
    "Mi-28N",
    "MiG-23MLD",
    "MiG-25PD",
    "MiG-27K",
    "MiG-29 Fulcrum",
    "MiG-29S",
    "MiG-31",
    "Mirage-F1BQ",
    "Mirage-F1CE",
    "Mirage-F1EE",
    "Su-24M",
    "Su-25T",
    "Su-27",
    "Su-33",
    "Su-34",
    --"L-39C",
    --"Mi-24V",
    --"Su-25",
    --"F-16C_50",
    --"FA-18C_hornet",
}
-- The list is applied if AllowMods are true and on Modern era.
-- Make sure you have the mods installed on the server and the client.
-- @gui label="Mods aircraft list" installPolicy="mergeRows" editor="bucket" visibleWhen="AllowMods:true"
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

-- In the Coldwar or Gulfwar era, you can add or remove what to restrict
-- Add "--" if you want to ALLOW a weapon, otherwise the weapon in the list below are removed from the warehouse.
-- @gui label="Cold War / Gulf War Restricted Weapons" installPolicy="mergeRows" newItemPolicy="commentWhenVisible" editor="bucket" visibleWhen="Era:Coldwar|Gulfwar"
restrictedWeapons = {
    -- Apache Radar
    "weapons.containers.ah-64d_radar",
    -- Missiles
    "weapons.missiles.F16V_GBU53",
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
    -- "weapons.containers.AN_ASQ_228",
    -- "weapons.containers.AAQ-28_LITENING",
    -- "weapons.containers.AN_AAQ_33",
    
	"weapons.missiles.AGR_20A", -- laser rockets
	"weapons.missiles.AGR_20_M282"} -- laser rockets

-- In the Vietnam era, you can add or remove what to restrict.
-- Add "--" if you want to ALLOW a weapon, otherwise weapons in the list below are removed from the warehouse.
-- @gui label="Vietnam Restricted Weapons" installPolicy="mergeRows" newItemPolicy="commentWhenVisible" editor="bucket" visibleWhen="Era:Vietnam"
restrictedWeaponsVietnam = {
    -- Guided weapon pods
    --"weapons.containers.HB_ORD_Pave_Spike",
    --"weapons.containers.HB_ORD_Pave_Spike_Fast",
    -- "weapons.containers.HB_ALE_40_0_0",
    -- "weapons.containers.HB_ALE_40_0_120",
    -- "weapons.containers.HB_ALE_40_15_90",
    -- "weapons.containers.HB_ALE_40_30_0",
    -- "weapons.containers.HB_ALE_40_30_60",


    -- Modern air-to-air missiles
    "weapons.missiles.AIM-7F",
    "weapons.missiles.AIM-9L",
    "weapons.missiles.AIM-9P",
    "weapons.missiles.AIM-9P3",
    "weapons.missiles.AIM-9P5",
    "weapons.missiles.AIM_7",
    "weapons.missiles.AIM_9",
    "weapons.missiles.CATM_9M",
    "weapons.missiles.P_60",
    "weapons.missiles.R-13M",
    "weapons.missiles.R-13M1",
    --"weapons.missiles.R-60",

    -- Modern air-to-ground missiles
    "weapons.missiles.AGM_65D",
    "weapons.missiles.AGM_65G",
    -- "weapons.missiles.AGM_65A",
    "weapons.missiles.AGM_65B",
    -- "weapons.missiles.X_25MR",
    "weapons.missiles.OH_6_FIM_92", -- OH-6A Stinger
    "weapons.missiles.AGM_114",
    "weapons.missiles.AGM_114K",
    "weapons.missiles.AGM_114L",
    "weapons.missiles.AGR_20A", -- APKWS
    "weapons.missiles.AGR_20_M282", -- APKWS
    -- "weapons.adapters.M260", -- Bronco modern Hydra pod

    -- Modern rockets
    -- "weapons.nurs.HYDRA_70_M151",
    -- "weapons.nurs.HYDRA_70_M156",
    -- "weapons.nurs.HYDRA_70_M257",
    -- "weapons.nurs.HYDRA_70_M274",
    "weapons.nurs.C_8",
    "weapons.nurs.C_8CM",
    "weapons.nurs.C_8CM_BU",
    "weapons.nurs.C_8CM_GN",
    "weapons.nurs.C_8CM_RD",
    "weapons.nurs.C_8CM_VT",
    "weapons.nurs.C_8CM_WH",
    "weapons.nurs.C_8CM_YE",
    "weapons.nurs.C_8OFP2",
    "weapons.nurs.C_8OM",

    -- Modern guided/cluster bombs
    -- "weapons.bombs.AGM_62",
    -- "weapons.bombs.AGM_62_I",
    "weapons.bombs.BDU_50LGB",
    "weapons.bombs.BL_755",
    "weapons.bombs.CBU_87",
    "weapons.bombs.GBU_8_B",
    --"weapons.bombs.GBU_10",
    --"weapons.bombs.GBU_12",
    "weapons.bombs.GBU_16",
    "weapons.bombs.GBU_24",
    "weapons.bombs.HB_F4E_GBU15V1",
    --"weapons.bombs.ROCKEYE",
    "weapons.bombs.SAMP250HD",
    "weapons.bombs.SAMP250LD",
    "weapons.bombs.Durandal",
    "weapons.bombs.MK_82AIR",
    "weapons.bombs.BDU_50HD",
    "weapons.bombs.BDU_50LD",
    "weapons.bombs.SAMP250HD",
    "weapons.bombs.SAMP250LD",
}

-- This list can be used to add weapons you want to forbidd, This will forbidd all in the table in Modern era as well.
-- For Coldwar or Gulfwar, you can still rely on restrictedWeapons.
-- @gui label="Forbidden Weapons All Eras" editor="bucket"
ForbiddWeaponsInAllEra = {
    "weapons.bombs.RN-24", -- Nukes for the Mig-21
    "weapons.bombs.RN-28", -- Nukes for the Mig-21
    -- "weapons.containers.ah-64d_radar",
    -- Missiles
    -- "weapons.missiles.P_27TE",
    -- "weapons.missiles.P_27ET",
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

-- ============================================================================
-- Testing
-- ============================================================================

-- @gui label="Testing" testing="true"
Testing = false

-- ============================================================================
-- Admin Commands
-- ============================================================================
-- Enable this option, then enter the command words below.
-- @gui label="Enable admin commands"
AdminCommands = false

-- Enter a command word for each action. Leave a field blank to disable that action.
-- Examples show the complete format; only the entered word is saved.
-- @gui label="Command words" layout="fields" visibleWhen="AdminCommands:true"
AdminCommandAliases = {
    -- Adjust the shared Blue account within its limits.
    -- @gui label="Add Blue coalition funds" exampleFormat="{value}:500"
    addBlueFunds = "",
    -- Adjust the shared Red account within its limits.
    -- @gui label="Add Red coalition funds" exampleFormat="{value}:500"
    addRedFunds = "",
    -- Add weapons to a ready zone or CTLD/FARP warehouse. Default amount: 50.
    -- @gui label="Add weapons to zone warehouse" exampleFormat="{value}:500"
    addZoneItems = "",
    -- Enter the command alone to list shop items, or append an item ID to purchase. Cost and availability requirements still apply.
    -- @gui label="List shop / purchase without rank check" exampleFormat="{value}:<shop-id>"
    buyWithoutRank = "",
    -- Build an ordinary FARP at the marker.
    -- @gui label="Build ordinary marker FARP" exampleFormat="{value}"
    createFarp = "",
    -- Capture an eligible neutral zone for Blue.
    -- @gui label="Capture eligible neutral zone for Blue" exampleFormat="{value}"
    captureNeutralBlue = "",
    -- Capture an eligible neutral zone for Red.
    -- @gui label="Capture eligible neutral zone for Red" exampleFormat="{value}"
    captureNeutralRed = "",
    -- Remove built assets from the zone.
    -- @gui label="Clear zone built assets" exampleFormat="{value}"
    clearZone = "",
    -- Upgrade or repair the zone once for its current owner.
    -- @gui label="Upgrade or repair zone once" exampleFormat="{value}"
    upgradeZone = "",
    -- Fully upgrade an eligible active zone for its current owner.
    -- @gui label="Fully upgrade current-owner zone" exampleFormat="{value}"
    fullyUpgradeZone = "",
    -- Trigger the mission restart command using flag181; the mission/server controls subsequent loading.
    -- @gui label="Restart mission" exampleFormat="{value}"
    restartMission = "",
    -- End the mission using the campaign reset/restart flow. AutoRestart selects automatic restart or the confirmation menu.
    -- @gui label="End mission and reset campaign" exampleFormat="{value}"
    endMission = "",
}

-- Don't touch this.
if externalConfigChunk then
    applyExternalConfigWithFallbackWarning()
    if FootholdLocalization then
        FootholdLocalization:SetLocale(FootholdLocale)
    end
    SCHEDULER:New(nil, function() trigger.action.outText("Loaded " .. saveFile .. " externally.", 30) end, {}, 1)
end

if env.mission.theatre ~= 'Caucasus' and env.mission.theatre ~= 'Syria' and env.mission.theatre ~= 'PersianGulf' then PvP = false end
FootholdConfigLoadedOk = true

-- ============================================================================
-- End of Foothold Config
-- ============================================================================
