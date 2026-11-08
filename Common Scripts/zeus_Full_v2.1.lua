----------------------- INIT -------------------------------------------------------------
-- Version: 1.3 - Optimized
local evento = {};
zeus = {};
zeus.target = {};

groundUnitDB ={}

napalmCounter = 1

options = {
  ["napalm"] = false, 
  ["phosphor"] = false, 
}

-- Text exclusion system - Add patterns here to ignore in F10 marker events
local excludedTextPatterns = {
    "upgradeallred",
    "upgradeallblue",
    "debughelp",
    "help",
    "buy",
    "buy:item",
    "status",
    "stats",
    "top",
    "mystats",
    "missions",
    "spawn",
    "rensa",
    "capture",
    "maxxa",
    "event",
    "event:",
    "addfunds:",
    "debug:",
    "addshop:",
    "removeshop:",
    "-code:",
    -- Add more patterns here as needed
    -- "debugmode",
    -- "testcommand",
}

-- Function to check if text should be ignored
local function isTextExcluded(text)
    if not text then return false end
    
    for _, pattern in ipairs(excludedTextPatterns) do
        if string.match(text, pattern) ~= nil then
            return true
        end
    end
    return false
end

airUnitDB =
    {
    {AAName = "mig29"},
    {AAName = "mig23"},
    {AAName = "mig21"},
    {AAName = "j11"},
    {AAName = "m2k"},
    {AAName = "f14"},
    {AAName = "f15"},
    {AAName = "f16"},
    {AAName = "f18"},
    {AAName = "f1"},
    {AAName = "f5"},
    {AAName = "f4"},
    {AAName = "mig28"},
    {AAName = "jtac"},
    {AAName = "texaco"},
    {AAName = "arco"},
    {AAName = "p51"},
    {AAName = "spit"},
    {AAName = "mossie"},
    {AAName = "bf109"},
    {AAName = "fw190d9"},
    {AAName = "fw190a8"},
    {AAName = "ju88"},
    }

-- Aircraft configuration database
local aircraftConfigs = {
    -- JTAC/Drone Configuration
    ["jtac"] = {
        template = "drone",
        type = "MQ-9 Reaper",
        livery = "'camo' scheme",
        altitude = 7620,
        speed = 61.666666666667,
        frequency = 251,
        payload = {
            pylons = {},
            fuel = 1300,
            flare = 0,
            chaff = 0,
            gun = 100
        }
    },
    
    -- Fighter Aircraft - Modern Jets
    ["mig29"] = {
        template = "fighter",
        type = "MiG-29S",
        livery = "Air Force Standard",
        altitude = 8534.4,
        speed = 220.97222222222,
        frequency = 124,
        payload = {
            pylons = {
                [1] = {["CLSID"] = "{FBC29BFE-3D24-4C64-B81D-941239D12249}"},
                [2] = {["CLSID"] = "{B4C01D60-A8A3-4237-BD72-CA7655BC0FE9}"},
                [3] = {["CLSID"] = "{B79C379A-9E87-4E50-A1EE-7F7E29C2E87A}"},
                [4] = {["CLSID"] = "{2BEC576B-CDF5-4B7F-961F-B0FA4312B841}"},
                [5] = {["CLSID"] = "{B79C379A-9E87-4E50-A1EE-7F7E29C2E87A}"},
                [6] = {["CLSID"] = "{B4C01D60-A8A3-4237-BD72-CA7655BC0FE9}"},
                [7] = {["CLSID"] = "{FBC29BFE-3D24-4C64-B81D-941239D12249}"}
            },
            fuel = "3493",
            flare = 30,
            chaff = 30,
            gun = 100
        }
    },
    
    ["mig21"] = {
        template = "fighter",
        type = "MiG-21Bis",
        livery = "vvs - metal",
        altitude = 7620,
        speed = 220.97222222222,
        frequency = 124,
        payload = {
            pylons = {
                [1] = {["CLSID"] = "{R-60 2L}"},
                [2] = {["CLSID"] = "{R-3R}"},
                [3] = {["CLSID"] = "{PTB_800_MIG21}"},
                [4] = {["CLSID"] = "{R-3R}"},
                [5] = {["CLSID"] = "{R-60 2R}"},
                [6] = {["CLSID"] = "{ASO-2}"}
            },
            fuel = 2280,
            flare = 40,
            ammo_type = 1,
            chaff = 18,
            gun = 100
        }
    },
    
    ["mig23"] = {
        template = "fighter",
        type = "MiG-23MLD",
        livery = "af standard",
        altitude = 7620,
        speed = 210.69444444444,
        frequency = 251,
        payload = {
            pylons = {
                [2] = {["CLSID"] = "{6980735A-44CC-4BB9-A1B5-591532F1DC69}"},
                [3] = {["CLSID"] = "{B0DBC591-0F52-4F7D-AD7B-51E67725FB81}"},
                [4] = {["CLSID"] = "{A5BAEAB7-6FAF-4236-AF72-0FD900F493F9}"},
                [5] = {["CLSID"] = "{275A2855-4A79-4B2D-B082-91EA2ADF4691}"},
                [6] = {["CLSID"] = "{CCF898C9-5BC7-49A4-9D1E-C3ED3D5166A1}"}
            },
            fuel = "3800",
            flare = 60,
            chaff = 60,
            gun = 100
        }
    },
    
    ["j11"] = {
        template = "fighter",
        type = "J-11A",
        livery = "plaaf 14th ad",
        altitude = 7620,
        speed = 169.58333333333,
        frequency = 127.5,
        payload = {
            pylons = {
                [1] = {["CLSID"] = "{RKL609_L}"},
                [2] = {["CLSID"] = "{FBC29BFE-3D24-4C64-B81D-941239D12249}"},
                [3] = {["CLSID"] = "{B79C379A-9E87-4E50-A1EE-7F7E29C2E87A}"},
                [4] = {["CLSID"] = "{B4C01D60-A8A3-4237-BD72-CA7655BC0FE9}"},
                [7] = {["CLSID"] = "{B4C01D60-A8A3-4237-BD72-CA7655BC0FE9}"},
                [8] = {["CLSID"] = "{B79C379A-9E87-4E50-A1EE-7F7E29C2E87A}"},
                [9] = {["CLSID"] = "{FBC29BFE-3D24-4C64-B81D-941239D12249}"},
                [10] = {["CLSID"] = "{RKL609_R}"}
            },
            fuel = 9400,
            flare = 96,
            chaff = 96,
            gun = 100
        }
    },
    
    ["m2k"] = {
        template = "fighter",
        type = "M-2000C",
        livery = "M2000C-N_2-30_NoeZ",
        altitude = 7620,
        speed = 251.80555555556,
        frequency = 251,
        payload = {
            pylons = {
                [1] = {["CLSID"] = "{MMagicII}"},
                [2] = {["CLSID"] = "{Matra_S530D}"},
                [5] = {["CLSID"] = "{M2KC_RPL_522}"},
                [8] = {["CLSID"] = "{Matra_S530D}"},
                [9] = {["CLSID"] = "{MMagicII}"},
                [10] = {["CLSID"] = "{Eclair}"}
            },
            fuel = 3165,
            flare = 64,
            ammo_type = 1,
            chaff = 234,
            gun = 100
        },
        addProp = {
            ["ReadyALCM"] = true,
            ["WpBullseye"] = 0,
            ["LoadNVGCase"] = false,
            ["ForceINSRules"] = false,
            ["InitHotDrift"] = 0,
            ["EnableTAF"] = true
        }
    },
    
    ["f14"] = {
        template = "fighter",
        type = "F-14B",
        livery = "rogue nation(top gun - maverick)",
        altitude = 8534.4,
        speed = 220.97222222222,
        frequency = 124,
        payload = {
            pylons = {
                [1] = {["CLSID"] = "{LAU-138 wtip - AIM-9M}"},
                [2] = {["CLSID"] = "{SHOULDER AIM-7P}"},
                [3] = {["CLSID"] = "{F14-300gal}"},
                [4] = {["CLSID"] = "{AIM_54C_Mk60}"},
                [5] = {["CLSID"] = "{AIM_54C_Mk60}"},
                [6] = {["CLSID"] = "{AIM_54C_Mk60}"},
                [7] = {["CLSID"] = "{AIM_54C_Mk60}"},
                [8] = {["CLSID"] = "{F14-300gal}"},
                [9] = {["CLSID"] = "{SHOULDER AIM-7P}"},
                [10] = {["CLSID"] = "{LAU-138 wtip - AIM-9M}"}
            },
            fuel = 7348,
            flare = 60,
            ammo_type = 1,
            chaff = 140,
            gun = 100
        }
    },
    
    ["f15"] = {
        template = "fighter_link16",
        type = "F-15C",
        livery = "65th Aggressor SQN (WA) Flanker",
        altitude = 7620,
        speed = 220.97222222222,
        frequency = 124,
        payload = {
            pylons = {
                [1] = {["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}"},
                [3] = {["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}"},
                [4] = {["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}"},
                [5] = {["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}"},
                [6] = {["CLSID"] = "{E1F29B21-F291-4589-9FD8-3272EEC69506}"},
                [7] = {["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}"},
                [8] = {["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}"},
                [9] = {["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}"},
                [11] = {["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}"}
            },
            fuel = "6103",
            flare = 60,
            chaff = 120,
            gun = 100
        },
        addProp = {
            ["VoiceCallsignLabel"] = "ED",
            ["VoiceCallsignNumber"] = "11",
            ["STN_L16"] = "00201"
        }
    },
    
    ["f16"] = {
        template = "fighter_link16",
        type = "F-16C_50",
        livery = "default",
        altitude = 8534.4,
        speed = 220.97222222222,
        frequency = 305,
        payload = {
            ["pylons"] = {
                [1] = 
                {
                    ["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}",
                }, -- end of [1]
                [2] = 
                {
                    ["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}",
                }, -- end of [2]
                [3] = 
                {
                    ["CLSID"] = "{5CE2FF2A-645A-4197-B48D-8720AC69394F}",
                    ["settings"] = 
                    {
                        ["NFP_VIS_DrawArgNo_57"] = 0.1,
                        ["NFP_PRESID"] = "MDRN_M_A_AIM9",
                    }, -- end of ["settings"]
                }, -- end of [3]
                [4] = 
                {
                    ["CLSID"] = "{F376DBEE-4CAE-41BA-ADD9-B2910AC95DEC}",
                }, -- end of [4]
                [5] = 
                {
                    ["CLSID"] = "<CLEAN>",
                }, -- end of [5]
                [6] = 
                {
                    ["CLSID"] = "{F376DBEE-4CAE-41BA-ADD9-B2910AC95DEC}",
                }, -- end of [6]
                [7] = 
                {
                    ["CLSID"] = "{5CE2FF2A-645A-4197-B48D-8720AC69394F}",
                    ["settings"] = 
                    {
                        ["NFP_VIS_DrawArgNo_57"] = 0.1,
                        ["NFP_PRESID"] = "MDRN_M_A_AIM9",
                    }, -- end of ["settings"]
                }, -- end of [7]
                [8] = 
                {
                    ["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}",
                }, -- end of [8]
                [9] = 
                {
                    ["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}",
                }, -- end of [9]
            },
            fuel = 3249,
            flare = 60,
            ammo_type = 5,
            chaff = 60,
            gun = 100
        },
        addProp = {
            ["STN_L16"] = "00203",
            ["VoiceCallsignNumber"] = "11",
            ["VoiceCallsignLabel"] = "UI"
        }
    },
    
    ["f18"] = {
        template = "fighter_link16",
        type = "FA-18C_hornet",
        livery = "fictional russia air force",
        altitude = 8534.4,
        speed = 179.86111111111,
        frequency = 305,
        payload = {
            pylons = {
                [1] = {["CLSID"] = "{5CE2FF2A-645A-4197-B48D-8720AC69394F}"},
                [2] = {["CLSID"] = "LAU-115_2*LAU-127_AIM-120C"},
                [3] = {["CLSID"] = "<CLEAN>"},
                [4] = {["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}"},
                [5] = {["CLSID"] = "{FPU_8A_FUEL_TANK}"},
                [6] = {["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}"},
                [7] = {["CLSID"] = "<CLEAN>"},
                [8] = {["CLSID"] = "LAU-115_2*LAU-127_AIM-120C"},
                [9] = {["CLSID"] = "{5CE2FF2A-645A-4197-B48D-8720AC69394F}"}
            },
            fuel = 4900,
            flare = 60,
            ammo_type = 1,
            chaff = 60,
            gun = 100
        },
        addProp = {
            ["VoiceCallsignLabel"] = "CT",
            ["VoiceCallsignNumber"] = "11",
            ["STN_L16"] = "00204"
        }
    },
    
    ["f1"] = {
        template = "fighter",
        type = "Mirage-F1CE",
        livery = "iriaf 3-6205 _ 2010s asia minor (eq variant)",
        altitude = 6096,
        speed = 254.91922185783,
        frequency = 127.5,
        payload = {
            pylons = {
                [1] = {["CLSID"] = "{AIM-9JULI}"},
                [3] = {["CLSID"] = "{R530F_IR}"},
                [4] = {["CLSID"] = "PTB-1200-F1"},
                [5] = {["CLSID"] = "{R530F_IR}"},
                [7] = {["CLSID"] = "{AIM-9JULI}"}
            },
            fuel = 3356,
            flare = 15,
            chaff = 30,
            gun = 100
        }
    },
    
    ["f5"] = {
        template = "fighter",
        type = "F-5E-3",
        livery = "aggressor desert scheme",
        altitude = 7620,
        speed = 174.72222222222,
        frequency = 305,
        payload = {
            pylons = {
                [1] = {["CLSID"] = "{AIM-9P5}"},
                [7] = {["CLSID"] = "{AIM-9P5}"}
            },
            fuel = 2046,
            flare = 15,
            ammo_type = 2,
            chaff = 30,
            gun = 100
        }
    },
    
    ["mig28"] = {
        template = "fighter",
        type = "F-5E-3",
        livery = "black 'Mig-28'",
        altitude = 7620,
        speed = 174.72222222222,
        frequency = 305,
        payload = {
            pylons = {
                [1] = {["CLSID"] = "{AIM-9P5}"},
                [7] = {["CLSID"] = "{AIM-9P5}"}
            },
            fuel = 2046,
            flare = 15,
            ammo_type = 2,
            chaff = 30,
            gun = 100
        }
    },
    
    ["f4"] = {
        template = "fighter",
        type = "F-4E-45MC",
        livery = "iriaf-3-6643",
        altitude = 6096,
        speed = 256.94444444444,
        frequency = 305,
        payload = {
            pylons = {
                [1] = {["CLSID"] = "{F4_SARGENT_TANK_370_GAL}"},
                [2] = {["CLSID"] = "{AIM-9J}"},
                [4] = {["CLSID"] = "{AIM-9J}"},
                [5] = {["CLSID"] = "{HB_F4E_AIM-7E}"},
                [6] = {["CLSID"] = "{HB_ALQ-131_ON_ADAPTER_IN_AERO7}"},
                [8] = {["CLSID"] = "{HB_F4E_AIM-7E}"},
                [9] = {["CLSID"] = "{HB_F4E_AIM-7E}"},
                [10] = {["CLSID"] = "{AIM-9J}"},
                [12] = {["CLSID"] = "{AIM-9J}"},
                [13] = {["CLSID"] = "{F4_SARGENT_TANK_370_GAL_R}"},
                [14] = {["CLSID"] = "{HB_ALE_40_30_60}"}
            },
            fuel = 5510.5,
            flare = 30,
            ammo_type = 1,
            chaff = 120,
            gun = 100
        }
    },
    
    -- Tanker Aircraft
    ["texaco"] = {
        template = "tanker",
        type = "KC135MPRS",
        livery = "22nd arw",
        altitude = 7315.2,
        speed = 207.02274359335,
        frequency = 283,
        callsign_name = "Texaco51",
        beacon = {channel = 68, callsign = "TEX", frequency = 1155000000},
        payload = {
            pylons = {},
            fuel = 90700,
            flare = 60,
            chaff = 120,
            gun = 100
        }
    },
    
    ["arco"] = {
        template = "tanker",
        type = "KC-135",
        livery = "standard usaf",
        altitude = 6096,
        speed = 210.33622240736,
        frequency = 140.35,
        callsign_name = "Arco51",
        beacon = {channel = 69, callsign = "ARC", frequency = 1156000000},
        payload = {
            pylons = {},
            fuel = 90700,
            flare = 0,
            chaff = 0,
            gun = 100
        },
        addProp = {
            ["VoiceCallsignLabel"] = "AO",
            ["VoiceCallsignNumber"] = "11",
            ["STN_L16"] = "00202"
        }
    },
    
    -- WWII Aircraft
    ["p51"] = {
        template = "wwii",
        type = "P-51D-30-NA",
        livery = "USAF 363rd FS, 357th FG DESERT RAT",
        altitude = 1524,
        speed = 92.5,
        frequency = 124,
        payload = {
            pylons = {},
            fuel = 732,
            flare = 0,
            ammo_type = 1,
            chaff = 0,
            gun = 100
        }
    },
    
    ["spit"] = {
        template = "wwii",
        type = "SpitfireLFMkIX",
        livery = "403 rcaf beurling",
        altitude = 1524,
        speed = 92.5,
        frequency = 124,
        payload = {
            pylons = {},
            fuel = 247,
            flare = 0,
            ammo_type = 1,
            chaff = 0,
            gun = 100
        }
    },
    
    ["mossie"] = {
        template = "wwii",
        type = "MosquitoFBMkVI",
        livery = "305sqn july",
        altitude = 1524,
        speed = 113.05555555556,
        frequency = 124,
        payload = {
            pylons = {},
            fuel = 1483,
            flare = 0,
            ammo_type = 1,
            chaff = 0,
            gun = 100
        },
        addProp = {
            ["ResinLights"] = 0.15,
            ["SoloFlight"] = false
        }
    },
    
    ["bf109"] = {
        template = "wwii",
        type = "Bf-109K-4",
        livery = "Bf-109 K4 Jagdgeschwader 53",
        altitude = 1524,
        speed = 92.5,
        frequency = 40,
        payload = {
            pylons = {},
            fuel = 296,
            flare = 0,
            ammo_type = 1,
            chaff = 0,
            gun = 100
        },
        addProp = {
            ["MW50TankContents"] = 1
        }
    },
    
    ["fw190a8"] = {
        template = "wwii",
        type = "FW-190A8",
        livery = "FW-190A8_2.JG 54",
        altitude = 1524,
        speed = 92.5,
        frequency = 38.4,
        payload = {
            pylons = {},
            fuel = 409,
            flare = 0,
            ammo_type = 1,
            chaff = 0,
            gun = 100
        }
    },
    
    ["fw190d9"] = {
        template = "wwii",
        type = "FW-190D9",
        livery = "FW-190D9_13.JG 51_Heinz Marquardt",
        altitude = 1524,
        speed = 92.5,
        frequency = 38.4,
        payload = {
            pylons = {},
            fuel = 388,
            flare = 0,
            ammo_type = 1,
            chaff = 0,
            gun = 100
        }
    },
    
    ["ju88"] = {
        template = "bomber",
        type = "Ju-88A4",
        livery = "ju-88a4",
        altitude = 1524,
        speed = 113.05555555556,
        frequency = 251,
        payload = {
            pylons = {},
            fuel = 2120,
            flare = 0,
            chaff = 0,
            gun = 100
        }
    }
}

----------------------- VARIABLES -------------------------------------------------------------

zeus.target.aircraftName = "";
zeus.target.aircraftPos = nil;
zeus.target.markerPos = nil;

---------------------- FUNCTIONS ----------------------------------------------------------------------

-- Template generation functions
local function createDroneTemplate(config, owngroupID, callname)
    return {
        ["modulation"] = 0,
        ["tasks"] = {},
        ["radioSet"] = false,
        ["task"] = "AFAC",
        ["uncontrolled"] = false,
        ["route"] = {
            ["points"] = {
                [1] = {
                    ["alt"] = config.altitude,
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["properties"] = {["addopt"] = {}},
                    ["speed"] = config.speed,
                    ["task"] = {
                        ["id"] = "ComboTask",
                        ["params"] = {
                            ["tasks"] = {
                                [1] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "FAC",
                                    ["number"] = 1,
                                    ["params"] = {
                                        ["number"] = 1,
                                        ["designation"] = "Auto",
                                        ["modulation"] = 0,
                                        ["callname"] = callname,
                                        ["datalink"] = true,
                                        ["frequency"] = 134000000
                                    }
                                },
                                [2] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 2,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "EPLRS",
                                            ["params"] = {
                                                ["value"] = true,
                                                ["groupId"] = owngroupID
                                            }
                                        }
                                    }
                                },
                                [3] = {
                                    ["number"] = 3,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["enabled"] = true,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "SetInvisible",
                                            ["params"] = {["value"] = true}
                                        }
                                    }
                                },
                                [4] = {
                                    ["number"] = 4,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["enabled"] = true,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "SetImmortal",
                                            ["params"] = {["value"] = true}
                                        }
                                    }
                                }
                            }
                        }
                    },
                    ["type"] = "Turning Point",
                    ["ETA"] = 0,
                    ["ETA_locked"] = true,
                    ["y"] = zeus.target.aircraftPos.z + 1000,
                    ["x"] = zeus.target.aircraftPos.x + 1000,
                    ["name"] = "Initial Point",
                    ["speed_locked"] = true,
                    ["formation_template"] = ""
                },
                [2] = {
                    ["alt"] = config.altitude,
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["properties"] = {["addopt"] = {}},
                    ["speed"] = config.speed,
                    ["task"] = {
                        ["id"] = "ComboTask",
                        ["params"] = {
                            ["tasks"] = {
                                [1] = {
                                    ["number"] = 1,
                                    ["auto"] = false,
                                    ["id"] = "Orbit",
                                    ["enabled"] = true,
                                    ["params"] = {
                                        ["altitude"] = config.altitude,
                                        ["pattern"] = "Circle",
                                        ["speed"] = 55.555555555556
                                    }
                                }
                            }
                        }
                    },
                    ["type"] = "Turning Point",
                    ["ETA"] = 96.011094947238,
                    ["ETA_locked"] = false,
                    ["y"] = zeus.target.aircraftPos.z,
                    ["x"] = zeus.target.aircraftPos.x,
                    ["name"] = "spot",
                    ["speed_locked"] = true,
                    ["formation_template"] = ""
                }
            }
        },
        ["groupId"] = owngroupID,
        ["hidden"] = false,
        ["units"] = {
            [1] = {
                ["alt"] = config.altitude,
                ["alt_type"] = "BARO",
                ["livery_id"] = config.livery,
                ["skill"] = "High",
                ["speed"] = config.speed,
                ["type"] = config.type,
                ["unitId"] = 1,
                ["psi"] = 0,
                ["onboard_num"] = "010",
                ["y"] = zeus.target.aircraftPos.z + 1000,
                ["x"] = zeus.target.aircraftPos.x + 1000,
                ["name"] = zeus.target.aircraftName,
                ["payload"] = config.payload,
                ["heading"] = 0,
                ["callsign"] = {
                    [1] = 3,
                    [2] = 1,
                    ["name"] = zeus.target.aircraftName,
                    [3] = 1
                }
            }
        },
        ["y"] = zeus.target.aircraftPos.z + 1000,
        ["x"] = zeus.target.aircraftPos.x + 1000,
        ["name"] = zeus.target.aircraftName,
        ["communication"] = true,
        ["start_time"] = 0,
        ["frequency"] = config.frequency
    }
end

local function createFighterTemplate(config, owngroupID)
    return {
        ["modulation"] = 0,
        ["tasks"] = {},
        ["radioSet"] = false,
        ["task"] = "CAP",
        ["uncontrolled"] = false,
        ["route"] = {
            ["points"] = {
                [1] = {
                    ["alt"] = config.altitude,
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["properties"] = {["addopt"] = {}},
                    ["speed"] = config.speed,
                    ["task"] = {
                        ["id"] = "ComboTask",
                        ["params"] = {
                            ["tasks"] = {
                                [1] = {
                                    ["enabled"] = true,
                                    ["key"] = "CAP",
                                    ["id"] = "EngageTargets",
                                    ["number"] = 1,
                                    ["auto"] = true,
                                    ["params"] = {
                                        ["targetTypes"] = {[1] = "Air"},
                                        ["priority"] = 0
                                    }
                                },
                                [2] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 2,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "Option",
                                            ["params"] = {
                                                ["value"] = true,
                                                ["name"] = 17
                                            }
                                        }
                                    }
                                },
                                [3] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 3,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "Option",
                                            ["params"] = {
                                                ["value"] = 4,
                                                ["name"] = 18
                                            }
                                        }
                                    }
                                },
                                [4] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 4,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "Option",
                                            ["params"] = {
                                                ["value"] = true,
                                                ["name"] = 19
                                            }
                                        }
                                    }
                                },
                                [5] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 5,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "Option",
                                            ["params"] = {
                                                ["targetTypes"] = {},
                                                ["name"] = 21,
                                                ["value"] = "none;",
                                                ["noTargetTypes"] = {
                                                    [1] = "Fighters", [2] = "Multirole fighters", [3] = "Bombers",
                                                    [4] = "Helicopters", [5] = "UAVs", [6] = "Infantry",
                                                    [7] = "Fortifications", [8] = "Tanks", [9] = "IFV",
                                                    [10] = "APC", [11] = "Artillery", [12] = "Unarmed vehicles",
                                                    [13] = "AAA", [14] = "SR SAM", [15] = "MR SAM",
                                                    [16] = "LR SAM", [17] = "Aircraft Carriers", [18] = "Cruisers",
                                                    [19] = "Destroyers", [20] = "Frigates", [21] = "Corvettes",
                                                    [22] = "Light armed ships", [23] = "Unarmed ships", [24] = "Submarines",
                                                    [25] = "Cruise missiles", [26] = "Antiship Missiles", [27] = "AA Missiles",
                                                    [28] = "AG Missiles", [29] = "SA Missiles"
                                                }
                                            }
                                        }
                                    }
                                },
                                [6] = {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "Orbit",
                                    ["number"] = 6,
                                    ["params"] = {
                                        ["altitude"] = config.altitude,
                                        ["pattern"] = "Circle",
                                        ["speed"] = 138.88888888889
                                    }
                                },
                                [7] = {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "EngageTargets",
                                    ["number"] = 7,
                                    ["params"] = {
                                        ["targetTypes"] = {[1] = "Planes"},
                                        ["noTargetTypes"] = {
                                            [1] = "Helicopters", [2] = "UAVs", [3] = "Cruise missiles",
                                            [4] = "Antiship Missiles", [5] = "AA Missiles", [6] = "AG Missiles",
                                            [7] = "SA Missiles"
                                        },
                                        ["value"] = "Planes;",
                                        ["priority"] = 0,
                                        ["maxDistEnabled"] = false,
                                        ["maxDist"] = 15000
                                    }
                                }
                            }
                        }
                    },
                    ["type"] = "Turning Point",
                    ["ETA"] = 0,
                    ["ETA_locked"] = true,
                    ["y"] = zeus.target.aircraftPos.z,
                    ["x"] = zeus.target.aircraftPos.x,
                    ["speed_locked"] = true,
                    ["formation_template"] = ""
                }
            }
        },
        ["groupId"] = owngroupID,
        ["hidden"] = false,
        ["units"] = {
            [1] = {
                ["alt"] = config.altitude,
                ["hardpoint_racks"] = true,
                ["alt_type"] = "BARO",
                ["livery_id"] = config.livery,
                ["skill"] = "Excellent",
                ["speed"] = config.speed,
                ["type"] = config.type,
                ["unitId"] = 1,
                ["psi"] = 0,
                ["onboard_num"] = "010",
                ["y"] = zeus.target.aircraftPos.z,
                ["x"] = zeus.target.aircraftPos.x,
                ["name"] = zeus.target.aircraftName,
                ["payload"] = config.payload,
                ["heading"] = 0,
                ["callsign"] = 100,
                ["AddPropAircraft"] = config.addProp or {}
            }
        },
        ["y"] = zeus.target.aircraftPos.z,
        ["x"] = zeus.target.aircraftPos.x,
        ["name"] = zeus.target.aircraftName,
        ["communication"] = true,
        ["start_time"] = 0,
        ["frequency"] = config.frequency
    }
end

local function createFighterLink16Template(config, owngroupID)
    local template = createFighterTemplate(config, owngroupID)
    
    -- Add EPLRS task
    table.insert(template.route.points[1].task.params.tasks, 6, {
        ["enabled"] = true,
        ["auto"] = true,
        ["id"] = "WrappedAction",
        ["number"] = 6,
        ["params"] = {
            ["action"] = {
                ["id"] = "EPLRS",
                ["params"] = {
                    ["value"] = true,
                    ["groupId"] = owngroupID
                }
            }
        }
    })
    
    -- Renumber subsequent tasks
    template.route.points[1].task.params.tasks[7].number = 7
    template.route.points[1].task.params.tasks[8].number = 8
    
    -- Add datalinks if F-16 or F-18
    if config.type == "F-16C_50" then
        template.units[1].datalinks = {
            ["Link16"] = {
                ["settings"] = {
                    ["flightLead"] = true,
                    ["transmitPower"] = 3,
                    ["specialChannel"] = 1,
                    ["fighterChannel"] = 1,
                    ["missionChannel"] = 1
                },
                ["network"] = {
                    ["teamMembers"] = {
                        [1] = {
                            ["TDOA"] = true,
                            ["missionUnitId"] = 3
                        }
                    },
                    ["donors"] = {}
                }
            }
        }
    elseif config.type == "FA-18C_hornet" then
        template.units[1].dataCartridge = {
            ["GroupsPoints"] = {
                ["Initial Point"] = {},
                ["Sequence 2 Red"] = {},
                ["PB"] = {},
                ["Sequence 1 Blue"] = {},
                ["Sequence 3 Yellow"] = {},
                ["A/A Waypoint"] = {},
                ["PP"] = {},
                ["Start Location"] = {}
            },
            ["Points"] = {}
        }
        template.units[1].datalinks = {
            ["Link16"] = {
                ["settings"] = {
                    ["FF1_Channel"] = 2,
                    ["FF2_Channel"] = 3,
                    ["transmitPower"] = 0,
                    ["AIC_Channel"] = 1,
                    ["VOCA_Channel"] = 4,
                    ["VOCB_Channel"] = 5
                },
                ["network"] = {
                    ["teamMembers"] = {
                        [1] = {["missionUnitId"] = 4}
                    },
                    ["donors"] = {}
                }
            }
        }
    end
    
    return template
end

local function createTankerTemplate(config, owngroupID)
    return {
        ["modulation"] = 0,
        ["tasks"] = {},
        ["radioSet"] = true,
        ["task"] = "Refueling",
        ["uncontrolled"] = false,
        ["route"] = {
            ["points"] = {
                [1] = {
                    ["alt"] = config.altitude,
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["properties"] = {["addopt"] = {}},
                    ["speed"] = config.speed,
                    ["task"] = {
                        ["id"] = "ComboTask",
                        ["params"] = {
                            ["tasks"] = {
                                [1] = {
                                    ["number"] = 1,
                                    ["auto"] = true,
                                    ["id"] = "Tanker",
                                    ["enabled"] = true,
                                    ["params"] = {}
                                },
                                [2] = {
                                    ["number"] = 2,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["enabled"] = true,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "ActivateBeacon",
                                            ["params"] = {
                                                ["type"] = 4,
                                                ["AA"] = false,
                                                ["callsign"] = config.beacon.callsign,
                                                ["system"] = 4,
                                                ["channel"] = config.beacon.channel,
                                                ["modeChannel"] = "X",
                                                ["unitId"] = 1,
                                                ["bearing"] = true,
                                                ["frequency"] = config.beacon.frequency
                                            }
                                        }
                                    }
                                },
                                [3] = {
                                    ["number"] = 3,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["enabled"] = true,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "EPLRS",
                                            ["params"] = {
                                                ["value"] = true,
                                                ["groupId"] = owngroupID
                                            }
                                        }
                                    }
                                },
                                [4] = {
                                    ["number"] = 4,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["enabled"] = true,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "SetInvisible",
                                            ["params"] = {["value"] = true}
                                        }
                                    }
                                },
                                [5] = {
                                    ["number"] = 5,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["enabled"] = true,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "SetImmortal",
                                            ["params"] = {["value"] = true}
                                        }
                                    }
                                }
                            }
                        }
                    },
                    ["type"] = "Turning Point",
                    ["ETA"] = 0,
                    ["ETA_locked"] = true,
                    ["y"] = zeus.target.aircraftPos.z,
                    ["x"] = zeus.target.aircraftPos.x,
                    ["speed_locked"] = true,
                    ["formation_template"] = ""
                },
                [2] = {
                    ["alt"] = config.altitude,
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["properties"] = {["addopt"] = {}},
                    ["speed"] = config.speed,
                    ["task"] = {
                        ["id"] = "ComboTask",
                        ["params"] = {
                            ["tasks"] = {
                                [1] = {
                                    ["number"] = 1,
                                    ["auto"] = false,
                                    ["id"] = "Orbit",
                                    ["enabled"] = true,
                                    ["params"] = {
                                        ["altitude"] = config.altitude,
                                        ["pattern"] = "Race-Track",
                                        ["speed"] = config.speed,
                                        ["speedEdited"] = true
                                    }
                                }
                            }
                        }
                    },
                    ["type"] = "Turning Point",
                    ["ETA"] = 56.622391387966,
                    ["ETA_locked"] = false,
                    ["y"] = zeus.target.aircraftPos.z + 1000,
                    ["x"] = zeus.target.aircraftPos.x,
                    ["speed_locked"] = true,
                    ["formation_template"] = ""
                },
                [3] = {
                    ["alt"] = config.altitude,
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["properties"] = {["addopt"] = {}},
                    ["speed"] = config.speed,
                    ["task"] = {
                        ["id"] = "ComboTask",
                        ["params"] = {["tasks"] = {}}
                    },
                    ["type"] = "Turning Point",
                    ["ETA"] = 444.43347384281,
                    ["ETA_locked"] = false,
                    ["y"] = zeus.target.aircraftPos.z + 75000,
                    ["x"] = zeus.target.aircraftPos.x,
                    ["speed_locked"] = true,
                    ["formation_template"] = ""
                }
            }
        },
        ["groupId"] = owngroupID,
        ["hidden"] = false,
        ["units"] = {
            [1] = {
                ["alt"] = config.altitude,
                ["alt_type"] = "BARO",
                ["livery_id"] = config.livery,
                ["skill"] = "Excellent",
                ["speed"] = config.speed,
                ["type"] = config.type,
                ["unitId"] = 1,
                ["psi"] = -1.5707963267949,
                ["onboard_num"] = "010",
                ["y"] = zeus.target.aircraftPos.z,
                ["x"] = zeus.target.aircraftPos.x,
                ["name"] = zeus.target.aircraftName,
                ["payload"] = config.payload,
                ["heading"] = 1.5707963267949,
                ["callsign"] = {
                    [1] = 1,
                    [2] = 5,
                    ["name"] = config.callsign_name,
                    [3] = 1
                },
                ["AddPropAircraft"] = config.addProp or {}
            }
        },
        ["y"] = zeus.target.aircraftPos.z,
        ["x"] = zeus.target.aircraftPos.x,
        ["name"] = zeus.target.aircraftName,
        ["communication"] = true,
        ["start_time"] = 0,
        ["frequency"] = config.frequency
    }
end

local function createWWIITemplate(config, owngroupID)
    return {
        ["modulation"] = 0,
        ["tasks"] = {},
        ["radioSet"] = false,
        ["task"] = "CAP",
        ["uncontrolled"] = false,
        ["route"] = {
            ["points"] = {
                [1] = {
                    ["alt"] = config.altitude,
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["properties"] = {["addopt"] = {}},
                    ["speed"] = config.speed,
                    ["task"] = {
                        ["id"] = "ComboTask",
                        ["params"] = {
                            ["tasks"] = {
                                [1] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "EngageTargets",
                                    ["number"] = 1,
                                    ["key"] = "CAP",
                                    ["params"] = {
                                        ["targetTypes"] = {[1] = "Air"},
                                        ["priority"] = 0
                                    }
                                }
                            }
                        }
                    },
                    ["type"] = "Turning Point",
                    ["ETA"] = 0,
                    ["ETA_locked"] = true,
                    ["y"] = zeus.target.aircraftPos.z,
                    ["x"] = zeus.target.aircraftPos.x,
                    ["speed_locked"] = true,
                    ["formation_template"] = ""
                }
            }
        },
        ["groupId"] = owngroupID,
        ["hidden"] = false,
        ["units"] = {
            [1] = {
                ["alt"] = config.altitude,
                ["alt_type"] = "BARO",
                ["livery_id"] = config.livery,
                ["skill"] = "Excellent",
                ["speed"] = config.speed,
                ["type"] = config.type,
                ["unitId"] = 1,
                ["psi"] = 0,
                ["onboard_num"] = "010",
                ["y"] = zeus.target.aircraftPos.z,
                ["x"] = zeus.target.aircraftPos.x,
                ["name"] = zeus.target.aircraftName,
                ["payload"] = config.payload,
                ["heading"] = 0,
                ["callsign"] = {
                    [1] = 1,
                    [2] = 1,
                    ["name"] = zeus.target.aircraftName,
                    [3] = 1
                },
                ["AddPropAircraft"] = config.addProp or {}
            }
        },
        ["y"] = zeus.target.aircraftPos.z,
        ["x"] = zeus.target.aircraftPos.x,
        ["name"] = zeus.target.aircraftName,
        ["communication"] = true,
        ["start_time"] = 0,
        ["frequency"] = config.frequency
    }
end

local function createBomberTemplate(config, owngroupID)
    return {
        ["modulation"] = 0,
        ["tasks"] = {},
        ["radioSet"] = false,
        ["task"] = "Ground Attack",
        ["uncontrolled"] = false,
        ["route"] = {
            ["points"] = {
                [1] = {
                    ["alt"] = config.altitude,
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["properties"] = {["addopt"] = {}},
                    ["speed"] = config.speed,
                    ["task"] = {
                        ["id"] = "ComboTask",
                        ["params"] = {
                            ["tasks"] = {
                                [1] = {
                                    ["number"] = 1,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["enabled"] = true,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "Option",
                                            ["params"] = {
                                                ["value"] = 1,
                                                ["name"] = 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    },
                    ["type"] = "Turning Point",
                    ["ETA"] = 0,
                    ["ETA_locked"] = true,
                    ["y"] = zeus.target.aircraftPos.z,
                    ["x"] = zeus.target.aircraftPos.x,
                    ["speed_locked"] = true,
                    ["formation_template"] = ""
                }
            }
        },
        ["groupId"] = owngroupID,
        ["hidden"] = false,
        ["units"] = {
            [1] = {
                ["alt"] = config.altitude,
                ["alt_type"] = "BARO",
                ["livery_id"] = config.livery,
                ["skill"] = "Excellent",
                ["speed"] = config.speed,
                ["type"] = config.type,
                ["unitId"] = 1,
                ["psi"] = 0,
                ["onboard_num"] = "013",
                ["y"] = zeus.target.aircraftPos.z,
                ["x"] = zeus.target.aircraftPos.x,
                ["name"] = zeus.target.aircraftName,
                ["payload"] = config.payload,
                ["heading"] = 0,
                ["callsign"] = {
                    [1] = 4,
                    [2] = 1,
                    ["name"] = "Colt11",
                    [3] = 1
                },
                ["AddPropAircraft"] = config.addProp or {}
            }
        },
        ["y"] = zeus.target.aircraftPos.z,
        ["x"] = zeus.target.aircraftPos.x,
        ["name"] = zeus.target.aircraftName,
        ["communication"] = true,
        ["start_time"] = 0,
        ["frequency"] = config.frequency
    }
end

local dashDestroyZoneCount = 0
local dashDestroyVehicleZoneCount = 0

local function handleDashDestroyRequest(coord)
    local name = string.format("destroy %d", dashDestroyZoneCount)
    local zone = ZONE_RADIUS:New(name, coord:GetVec2(), 500)
    dashDestroyZoneCount = dashDestroyZoneCount + 1
    zone:SearchZone(function(u) u:Destroy() return true end, Object.Category.UNIT)
end

local function handleDashDestroyVehicleRequest(coord)
    local name = string.format("destroy %d", dashDestroyVehicleZoneCount)
    local zone = ZONE_RADIUS:New(name, coord:GetVec2(), 1000)
    dashDestroyVehicleZoneCount = dashDestroyVehicleZoneCount + 1
    zone:SearchZone(function(u) u:Destroy() return true end, Object.Category.UNIT)
end

local function handleDashClearRequest(coord)
    local name = string.format("destroy %d", dashDestroyZoneCount)
    local zone = ZONE_RADIUS:New(name, coord:GetVec2(), 10000)
    dashDestroyZoneCount = dashDestroyZoneCount + 1
    zone:SearchZone(function(u) u:Destroy() return true end, Object.Category.UNIT)
end

local function handleDashExplodeRequest(text, coord)
    local power, delay = 100, 0
    local p1, p2 = string.match(text, "-explode (%d+) ?(%d*)")
    if p1 then power = tonumber(p1) end
    if p2 and p2 ~= "" then delay = tonumber(p2) end
    coord:Explosion(power, delay)
end

local function handleDashSmokeRequest(text, coord)
    local color = (string.match(text, "-smoke (%a+)") or "red"):lower()
    if color == "red" then coord:SmokeRed()
    elseif color == "blue" then coord:SmokeBlue()
    elseif color == "green" then coord:SmokeGreen()
    elseif color == "orange" then coord:SmokeOrange()
    elseif color == "white" then coord:SmokeWhite()
    else coord:SmokeRed() end
end

local function dispatchDashCommand(event)
    if not (event.text and event.text:sub(1, 1) == "-") then return false end
    local text = event.text:lower()
    local vec3 = {x = event.pos.x, y = event.pos.y, z = event.pos.z}
    local coord = COORDINATE:NewFromVec3(vec3)
    coord.y = coord:GetLandHeight()

    if text:find("-destroy1") then handleDashDestroyRequest(coord)
    elseif text:find("-destroy2") then handleDashDestroyVehicleRequest(coord)
    elseif text:find("-destroy3") then handleDashDestroyVehicleRequest(coord)
    elseif text:find("-destroy4") then handleDashClearRequest(coord)
    elseif text:find("-explode") then handleDashExplodeRequest(text, coord)
    elseif text == "-illuminate" then
        coord.y = coord.y + 1000
        coord:IlluminationBomb(700000)
    elseif text:find("-smoke") then handleDashSmokeRequest(text, coord)
    else return false end

    trigger.action.removeMark(event.idx)
    return true
end

function evento:onEvent(event)
    if (world.event.S_EVENT_MARK_ADDED == event.id or world.event.S_EVENT_MARK_CHANGE == event.id) then
        -- Check if the marker text should be ignored
        if isTextExcluded(event.text) then
            return
        end

        if dispatchDashCommand(event) then return end
        if world.event.S_EVENT_MARK_ADDED == event.id then return end
        
        local s = event.text
        -- Check for three-part format: model;unitname;coalition
        local model, unitname, coalitionOverride = s:match("(.+);(.+);(.+)")
        if not model then
            -- Fall back to two-part format: model;unitname
            model, unitname = s:match("(.+);(.+)")
        end
        if not model then
            return
        end
        
        if (string.match(event.text, model) ~= nil) and isValidAircraft(model) == true then
            if coalition.getPlayers(coalition.side.RED)[1] ~= nil or coalition.getPlayers(coalition.side.BLUE)[1] ~= nil then
                local index1 = string.find(event.text, ";", 0)
                local remainingText = string.sub(event.text, index1 + 1, string.len(event.text))
                
                -- Check if there's a second semicolon for coalition override
                local index2 = string.find(remainingText, ";", 0)
                if index2 then
                    zeus.target.aircraftName = zeus.trim(string.sub(remainingText, 1, index2 - 1))
                    local coalitionColor = zeus.trim(string.sub(remainingText, index2 + 1))
                    coalitionOverride = coalitionColor
                else
                    zeus.target.aircraftName = zeus.trim(remainingText)
                    coalitionOverride = nil
                end
                
                zeus.target.aircraftPos = event.pos
                if zeus.target.aircraftPos ~= nil then
                    zeus.createAircraft(model, coalitionOverride)
                    trigger.action.outText("spawn succeeded ", 10, false)
                else
                    trigger.action.outText("INFO: You need to create a mark: aircraft_type:unitname in F10 map", 10, false)
                end
            else
                trigger.action.outText("There is no player in the mission. You Can't talk to zeus", 10, false)
            end
        elseif (string.match(event.text, "destroy;") ~= nil) then
            local index1 = string.find(event.text, ";", 0)
            local spawnname = zeus.trim(string.sub(event.text, index1 + 1, string.len(event.text)))
            zeus.dismissPackage(spawnname)
        elseif (string.match(event.text, "illumin;") ~= nil) then
            zeus.target.markerPos = event.pos
            zeus.illuminationBombOnMark(zeus.target.markerPos)
        elseif (string.match(event.text, "smoke;") ~= nil) then
            zeus.target.markerPos = event.pos
            local index1 = string.find(event.text, ";", 0)
            local colors = zeus.trim(string.sub(event.text, index1 + 1, string.len(event.text)))
            zeus.triggerSmoke(zeus.target.markerPos, colors)
        elseif (string.match(event.text, "strike;") ~= nil) then
            zeus.target.markerPos = event.pos
            zeus.strikeOnMark(zeus.target.markerPos)
        end
    end
end

function zeus.trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function zeus.dismissPackage(spawnname)
    if Group.getByName(spawnname):getUnit(1) ~= nil then
        Group.getByName(spawnname):destroy()
    end
end

function isValidAircraft(pmodel)
    for i, aircraft in ipairs(airUnitDB) do
        if aircraft.AAName == pmodel then
            return true
        end
    end
    return false
end

function zeus.illuminationBombOnMark(position)
    timer.scheduleFunction(zeus.illuminationBombOnMarkDelay, position, timer.getTime() + 15)
end

function zeus.triggerIllumBomb(mark)
    trigger.action.illuminationBomb(mark, 1000000 )
end

function zeus.illuminationBombOnMarkDelay(position)
    local altitude = math.random(600, 1200)
    local r1 = math.random(200, 300)
    local r2 = math.random(50, 150)

    local mark0 = {x = position.x, y = altitude, z = position.z}
    local mark1 = {x = position.x + r1, y = altitude, z = position.z}
    local mark2 = {x = position.x + r2, y = altitude, z = position.z}
    local mark3 = {x = position.x - r2, y = altitude, z = position.z}
    local mark4 = {x = position.x - r1, y = altitude, z = position.z}

    timer.scheduleFunction(zeus.triggerIllumBomb, mark1, timer.getTime() + 5)
    timer.scheduleFunction(zeus.triggerIllumBomb, mark2, timer.getTime() + 7)
    timer.scheduleFunction(zeus.triggerIllumBomb, mark0, timer.getTime() + 9)
    timer.scheduleFunction(zeus.triggerIllumBomb, mark3, timer.getTime() + 11)
    timer.scheduleFunction(zeus.triggerIllumBomb, mark4, timer.getTime() + 13)
end

function zeus.strikeOnMark(position)
    for i = 5, 20 do
        timer.scheduleFunction(zeus.triggerExplosion, position, timer.getTime() + i)
    end
end

function zeus.explodeNapalm(vec3)
    trigger.action.explosion(vec3, 10)
end

function zeus.removeNapalm(staticName) 
    StaticObject.getByName(staticName):destroy()
end

function zeus.phosphor(vec3) 
    for i =1,math.random(3, 10) do 
        azimuth = 30 * i
        trigger.action.signalFlare(vec3, 2, azimuth)
    end
end

function zeus.triggerExplosion(position)
    local impact = {x = position.x + math.random(-30,30), y = position.y + math.random(0,5), z = position.z + math.random(-30,30)}
    trigger.action.explosion(impact, math.random(50,200))
    
    local napalmName = "napalmImpact" .. napalmCounter
    napalmCounter = napalmCounter + 1
    local owngroupID = math.random(9999,99999)
    local cvnunitID = math.random(9999,99999)
    _dataFuel = {
        ["groupId"] = owngroupID,
        ["category"] = "Fortifications",
        ["shape_name"] = "toplivo-bak",
        ["type"] = "Fuel tank",
        ["unitId"] = cvnunitID,
        ["rate"] = 100,
        ["y"] = impact.z,
        ["x"] = impact.x,
        ["name"] = napalmName,
        ["heading"] = 0,
        ["dead"] = false,
        ["hidden"] = true
    }
    
    if options.napalm == true then
        coalition.addStaticObject(country.id.CJTF_BLUE, _dataFuel )
        timer.scheduleFunction(zeus.explodeNapalm, impact, timer.getTime() + 0.1)
        timer.scheduleFunction(zeus.removeNapalm, napalmName, timer.getTime() + 0.12)
    end
    
    if options.phosphor == true then
        timer.scheduleFunction(zeus.phosphor, impact, timer.getTime() + 0.12)
    end
end

function zeus.triggerSmoke(position, colors)
    if colors == "red" then
        trigger.action.smoke(position , trigger.smokeColor.Red)
    elseif colors == "green" then
        trigger.action.smoke(position , trigger.smokeColor.Green)
    elseif colors == "white" then
        trigger.action.smoke(position , trigger.smokeColor.White)
    elseif colors == "orange" then
        trigger.action.smoke(position , trigger.smokeColor.Orange)
    elseif colors == "blue" then
        trigger.action.smoke(position , trigger.smokeColor.Blue)
    end
end

-- Main aircraft creation function - optimized to use configuration database
function zeus.createAircraft(pmodel, coalitionOverride)
    local config = aircraftConfigs[pmodel]
    if not config then
        trigger.action.outText("Unknown aircraft model: " .. pmodel, 10, false)
        return
    end
    
    local owngroupID = math.random(10000, 99999)
    local templateType = config.template
    local template = nil
    
    -- Generate appropriate template based on aircraft type
    if templateType == "drone" then
        template = createDroneTemplate(config, owngroupID, zeus.target.aircraftName)
    elseif templateType == "fighter" then
        template = createFighterTemplate(config, owngroupID)
    elseif templateType == "fighter_link16" then
        template = createFighterLink16Template(config, owngroupID)
    elseif templateType == "tanker" then
        template = createTankerTemplate(config, owngroupID)
    elseif templateType == "wwii" then
        template = createWWIITemplate(config, owngroupID)
    elseif templateType == "bomber" then
        template = createBomberTemplate(config, owngroupID)
    else
        trigger.action.outText("Unknown template type: " .. templateType, 10, false)
        return
    end
    
    if template then
        local _country = country.id.CJTF_BLUE
        
        -- Check if coalition override is provided
        if coalitionOverride then
            local coalitionColor = string.lower(coalitionOverride)
            if coalitionColor == "red" then
                _country = country.id.CJTF_RED
                trigger.action.outText("Coalition override: spawning in RED coalition", 5, false)
            elseif coalitionColor == "blue" then
                _country = country.id.CJTF_BLUE
                trigger.action.outText("Coalition override: spawning in BLUE coalition", 5, false)
            else
                trigger.action.outText("Invalid coalition color: " .. coalitionOverride .. ". Using default logic.", 5, false)
                coalitionOverride = nil  -- Fall back to default logic
            end
        end
        
        -- Use default coalition logic if no valid override provided
        if not coalitionOverride then
            if pmodel == "jtac" or pmodel == "texaco" or pmodel == "arco" then
                -- Support units spawn on same coalition as player
                if coalition.getPlayers(coalition.side.RED)[1] ~= nil then
                    _country = country.id.CJTF_RED
                elseif coalition.getPlayers(coalition.side.BLUE)[1] ~= nil then
                    _country = country.id.CJTF_BLUE
                end
            else
                -- All other aircraft spawn as adversaries (opposite coalition)
                if coalition.getPlayers(coalition.side.RED)[1] ~= nil then
                    _country = country.id.CJTF_BLUE
                elseif coalition.getPlayers(coalition.side.BLUE)[1] ~= nil then
                    _country = country.id.CJTF_RED
                end
            end
        end
        
        coalition.addGroup(_country, Group.Category.AIRPLANE, template)
        
        -- Determine coalition name for message
        local coalitionName = "BLUE"
        if _country == country.id.CJTF_RED then
            coalitionName = "RED"
        end
        
        trigger.action.outText("Spawned " .. config.type .. " (" .. zeus.target.aircraftName .. ") in " .. coalitionName .. " coalition", 10, false)
    end
end

----------------------- EVENTS -------------------------------------------------------------

world.addEventHandler(evento)
trigger.action.outText("zeus V2.0 optimized - Script LOADED!", 10)
env.info("zeus V2.0 optimized - Script LOADED!", 10)
