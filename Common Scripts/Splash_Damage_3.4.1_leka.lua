if SplashDamage == true then
--[[-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=
                                                                Latest Changes                                       
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-	  

Forum Thread:
https://forum.dcs.world/topic/370261-splash-damage-3x-script-now-with-more-explosions-version-33-napalm-edition/
User Files:
https://www.digitalcombatsimulator.com/en/files/3344761/

Any issues/suggestions etc feel free to post on the forum or DM me in Discord - stevey9062

    4th July 2025 - 3.4

          - this is a 3.4.1 version for leka's foothold

		(Stevey666) 
		
	  - Added in optional kill feed feature, this will try to display kills from DCS engine and kills from the additional explosions by checking pre/post scans of the explosion area
			    --SPLASH KILL FEED WORKS IN MP ONLY (you can host your local SP mission as MP if you want to see it)
	  - Added in Lekas Foothold Integration to allow splash kills to count towards the points, killfeed is required to be enabled for this
	  - Added AGM_45B to expl table
	  - Added instant phosphor/signal flares option to cook off events
	  - Added in missing JF17/JAS39 weapons as per Kurdes
	  - Added killfeed to napalm and cluster features.  Note, it may not support all features in this script but should work with splashdamage by dropping bombs, the new CBU cluster feature and napalm.
	  - New Feature: A-10 Murder Mode, Named Unit Murder Mode (disabled by default) 
			- adds a configurable sized explosion to every hit event with the a10 or the named unit with the name MurderMode in it as an initiator
	  - New Feature: Tactical Explosion, a configurable blast effect that can be assigned to a weapon in a table or as an override
	  - New Feature: Critical Component.  % chance on a hit event of triggering an explosion at unit level
	  - New Feature: Ground Unit Explosion On Death. 
			- If a vehicle is flaming it takes time to pop, this will trigger an explosion with a %chance when its begins to flame (when it does not "exist" but has not triggerd a killed/dead event)
			- There's a % chance settable
			- You can also trigger this to happen if the unit has "GUED" in its name even if chance is set to 0
	  - New Feature: CBU Bomblet Hit Spread - On a Hit event from a cluster bomb, it will scan the local area for nearby vehicles and trigger an additional explosion
			- This features aims to help wipe out areas, but it works by scanning 20 meters radius (adjustable) for any vehicles nearby the hit vehicle and then 20m (adjustable) from those vehicles
			- Max of 1 additional explosion will spawn on the vehicles. Not enabled for CBU_97/CBU_105 due to them already being effective.
			- The spread mechanic could miss vehicles in the area still if one doesnt get hit, or theyre at opposite sides of the visible area and not within 20m (adjustable)
			- There is % chance to hit per unit found in the area, % chance for that hit to be indirect, and armour damage modifiers
	  - New Feature: Strobe Marker - generates a tiny explosion above a unit, no smoke but sound + light appears - can be used as a marker for planes
			- Generates on an active and living unit with "Strobe" in the name
			- Good: Visible to eye/FLIR(TV mode)
			- Not good: Not visible in IR, audible explosions if you're close to the unit
	  - New Feature: All Unit Cook/off smoke chances and advanced sequences
			- It's possible to assign a % chance to allunits having smoke/cookoffs
			- Advanced sequences allow for having multiple smoke/fire sizes of multiple lengths of time - and have smoke for example indefinitely burn
	  - New trigger for cookoff - Cookoff with the allunits settings can be enabled for specific units by the having "CargoCookoffTarget" in the name
	  - Reworked how cookoff works, cookoffs will now follow a moving vehicle as it travels instead of just going off where it was.  Flames/smoke will trigger when the vehicle stops.
			- You can have a chance of cookoff, smoke with a cookoff and also a chance of smoke only
			- Added chance options to the flares for cookoffs also
	  - Effects (i.e cookoff) no longer only bound by damage from tracked weapons.  Gun cannon kills will now count!  May time until the unit pops before it triggers a cookoff
	  - Giant explosion effects now tracked on events instead of checking the unit every second
	  - Jogaredi's suggestion added - ["only_players_weapons"] = true, --track only weapons launch by players, this will be defaulted to false
	  - Due to ED boosting damage values for MK82s and a few others, added the ability to skip larger_explosion and damage_model by having a specific entry in the explosive table
			- Example below, you would need to add this to each weapon that you need this for (or I can do it in the base script if multiple people think its a good idea)
			- ["Mk_82"] = { explosive = 100, Skip_larger_explosions = true, Skip_damage_model = true },
				
	  
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-	  
                                                                Full Changelog at the bottom of the script
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-	  	  


-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-
                                                                ##### SCRIPT CONFIGURATION #####
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-]]
splash_damage_options = {
    ---------------------------------------------------------------------- Debug and Messages ----------------------------------------------------------------
    ["game_messages"] = false, --enable some messages on screen
    ["debug"] = false,  --enable debugging messages 
    ["weapon_missing_message"] = false, --false disables messages alerting you to weapons missing from the explTable
    ["track_pre_explosion_debug"] = false, --Toggle to enable/disable pre-explosion tracking debugging
    ["track_groundunitordnance_debug"] = false, --Enable detailed debug messages for ground unit ordnance tracking
    ["napalm_unitdamage_debug"] = false, --Enable detailed debug messages for napalm unit damage tracking
    ["damage_model_game_messages"] = false, --ground unit movement and weapons disabled notification
    ["killfeed_debug"] = false, --Enable detailed debug messages for killfeed
    ["events_debug"] = false, --enable debugging for event handling (logevent function) - you will get a lot of logs if you set this to true
    ["MurderMode_debug"] = false,
    ["cargocookoff_debug"] = false,	--Debug mode for cargo cookoff
    ["CriticalComponent_debug"] = false, --Toggle debug logging
    ["GU_Explode_debug"] = false, --Toggle debug logging
    ["CBU_Bomblet_Hit_debug"] = false, --Toggle debug logging
    ["StrobeMarker_debug"] = false, --Logging for StrobeMarker
	
    ---------------------------------------------------------------------- Basic Splash Settings -------------------------------------------------------------
    ["static_damage_boost"] = 2000, --apply extra damage to Unit.Category.STRUCTUREs with wave explosions
    ["wave_explosions"] = true, --secondary explosions on top of game objects, radiating outward from the impact point and scaled based on size of object and distance from weapon impact point
    ["larger_explosions"] = false, --secondary explosions on top of weapon impact points, dictated by the values in the explTable
    ["damage_model"] = false, --allow blast wave to affect ground unit movement and weapons
    ["blast_search_radius"] = 90, --this is the max size of any blast wave radius, since we will only find objects within this zone.  Only used if dynamic is not enabled
    ["use_dynamic_blast_radius"] = true,   --if true, blast radius is calculated from explosion power; if false, blast_search_radius (90) is used
    ["dynamic_blast_radius_modifier"] = 1.5,  --multiplier for the blast radius
    ["blast_stun"] = false, --not implemented
    ["overall_scaling"] = 1,    --overall scaling for explosive power
	["only_players_weapons"] = true, --track only weapons launched by players
	
    ---------------------------------------------------------------------- Units -----------------------------------------------------------------------------
    ["unit_disabled_health"] = 10, --if health is below this value after our explosions, disable its movement 
    ["unit_cant_fire_health"] = 30, --if health is below this value after our explosions, set ROE to HOLD to simulate damage weapon systems
    ["infantry_cant_fire_health"] = 30,  --if health is below this value after our explosions, set ROE to HOLD to simulate severe injury
	

    ---------------------------------------------------------------------- Rockets ---------------------------------------------------------------------------
    ["rocket_multiplier"] = 1.3, --multiplied by the explTable value for rockets

    ---------------------------------------------------------------------- Shaped Charge ---------------------------------------------------------------------    
    ["apply_shaped_charge_effects"] = true, --apply reduction in blastwave etc for shaped charge munitions
    ["shaped_charge_multiplier"] = 0.2,  --multiplier that reduces blast radius and explosion power for shaped charge munitions.
    

    ---------------------------------------------------------------------- Cascading -------------------------------------------------------------------------  
    ["cascade_scaling"] = 1.5,    --multiplier for secondary (cascade) blast damage, 1 damage fades out too soon, 2 or 3 damage seems a good balance
    ["cascade_damage_threshold"] = 0.1, --if the calculated blast damage doesn't exceed this value, there will be no secondary explosion damage on the unit. If this value is too small, the appearance of explosions far outside of an expected radius looks incorrect.
    ["cascade_explode_threshold"] = 60,   --only trigger cascade explosion if the unit's current health is <= this percent of its maximum, setting can help blow nearby jeeps but not tanks
    ["always_cascade_explode"] = false, --switch if you want everything to explode like with the original script
    
	
    ---------------------------------------------------------------------- Cargo Cook Off/Fuel Explosion  ----------------------------------------------------
    --track_pre_explosion/enable_cargo_effects should both be the same value--
    
    ["track_pre_explosion"] = true, --Toggle to enable/disable pre-explosion tracking
    ["enable_cargo_effects"] = true, --Toggle for enabling/disabling cargo explosions and cook-offs  
    ["cargo_effects_chance"] = 1, -- Chance of cargo effects occurring. 0.1 = 10%, 1 = 100%
    ["cargo_damage_threshold"] = 25, --Health % below which cargo explodes (0 = destroyed only)
    ["debris_effects"] = true, --Enable debris from cargo cook-offs
    ["debris_power"] = 1, --Power of each debris explosion
    ["debris_count_min"] = 6, --Minimum debris pieces per cook-off
    ["debris_count_max"] = 12, --Maximum debris pieces per cook-off
    ["debris_max_distance"] = 8, --Max distance debris can travel (meters), the min distance from the vehicle will be 10% of this
	
    ["cookoff_flares_enabled"] = true, --Enable/disable flare effects for cook-offs, this applies to allvehicles too.
    ["cookoff_flare_color"] = 2, 
    ["cookoff_flare_instant"] = true, --If true, spawns flares instantly using napalm phosphor style; if false, spawns over time
    ["cookoff_flare_instant_min"] = 2, --Minimum number of instant flares when cookoff_flare_instant is true
    ["cookoff_flare_instant_max"] = 5, --Maximum number of instant flares when cookoff_flare_instant is true
    ["cookoff_flare_count_modifier"] = 1, --Multiplier for non instant flare count (e.g., 1x, 2x cookOffCount from the vehicle table)
    ["cookoff_flare_offset"] = 0.5, --Max offset distance for flares in meters (horizontal)
    ["cookoff_flare_chance"] = 0.5, --Chance - where 1 = 100% 0.4 = 40% chance of the flares firing out

    --All Vehicles Section
		--If a Unit is called CookOffTarget it will trigger a cookoff with the below effects
		
    ["smokeandcookoffeffectallvehicles"] = true, --Enable effects for all ground vehicles not in cargoUnits vehicle table
    ["allunits_enable_smoke"] = true, -- Enable /disable smoke effects if smokeandcookoffeffectallvehicles is true
    ["allunits_enable_cookoff"] = true, -- Enable /disable cookoffs if smokeandcookoffeffectallvehicles is true
    ["allunits_damage_threshold"] = 25, --Health % below which cargo/smoke attempts to trigger
    ["allunits_explode_power"] = 40, --Initial power of vehicle exploding
    ["allunits_default_flame_size"] = 6, --Default smoke size (called flame here in the code, but it'll be smoke) 5 = small smoke, 6 = medium smoke, 7 = large smoke,  8 = huge smoke 
    ["allunits_default_flame_duration"] = 240, --Default smoke (called flame here in the code, but it's smoke) duration in seconds for non-cargoUnits vehicles
    ["allunits_cookoff_count"] = 4, --number of cookoff explosions to schedule
    ["allunits_cookoff_duration"] = 30, --max time window of cookoffs (will be scheduled randomly between 0 seconds and this figure)
    ["allunits_cookoff_power"] = 10, --power of the cookoff explosions
    ["allunits_cookoff_powerrandom"] = 50, --percentage higher or lower of the cookoff power figure
    ["allunits_cookoff_chance"] = 0.4, --Chance of cookoff effects occurring for all vehicles. 0.6 = 60%, 1 = 100%
    ["allunits_smokewithcookoff"] = true, --Automatically smoke along with cookoff, or leave it to chance
    ["allunits_smoke_chance"] = 0.7, --Chance of smoke effect, 1 = 100%, 0.5 = 50%
    ["allunits_explode_on_smoke_only"] = true, --If its a smoke only effect, add an explosion to finish the vehicle off (allunits_explode_power)
	
    ["allunits_advanced_effect_sequence"] = true,  --When set to true, its possible for units to be trigger an advanced effect sequence.  This will take precedence over the standard allunits cookoff. it will ignore the previous settings for smoke/flame size and duration and instead it will let you program a specific sequence of smoke/flame effects
    ["allunits_advanced_effect_sequence_chance"] = 0.2, --Chance of the script picking the advanced effect instead of the standard all unit effect. 1 = 100%, 0.5 = 50%
    ["allunits_advanced_effect_force_on_name"] = true,  --Regardless of chance, if the unit has "SmokeEffects" in its name it will trigger the advanced sequence
    ["allunits_advanced_effect_order"] = {"2", "7", "6", "5"},  --List of flame and smoke : sizes, 1 = small smoke and fire, 2 = med, 3 = large, 4 = huge.  5 = small smoke only, 6 = medium, 7 = large,  8 = huge 
    ["allunits_advanced_effect_timing"] = {"30", "90", "120", "600"}, --How many seconds per effect in the order config key above
    ["allunits_advanced_effect_cookoff_chance"] = 1, --Chance of cookoff effects occurring for the advanced effect sequence
    ["allunits_advanced_effect_cookoff_count"] = 4, --number of cookoff explosions to schedule
    ["allunits_advanced_effect_cookoff_duration"] = 30, --max time window of cookoffs (will be scheduled randomly between 0 seconds and this figure)
    ["allunits_advanced_effect_cookoff_power"] = 10, --power of the cookoff explosions
    ["allunits_advanced_effect_cookoff_powerrandom"] = 50, --percentage higher or lower of the cookoff power figure
    ["allunits_advanced_effect_cookoff_flares_enabled"] = true, --Enable or disable phospor like signal flares, number etc taken from cookoff_flare_instant_count
    ["allunits_advanced_effect_explode_power"] = 40, --Initial power of vehicle exploding
	
    ---------------------------------------------------------------------- Ordnance Protection  --------------------------------------------------------------	
    ["ordnance_protection"] = false, --Toggle ordinance protection features
    ["ordnance_protection_radius"] = 20, --Distance in meters to protect nearby bombs
    ["detect_ordnance_destruction"] = true, --Toggle detection of ordnance destroyed by large explosions
    ["snap_to_ground_if_destroyed_by_large_explosion"] = true, --If the ordnance protection fails or is disabled we can snap larger_explosions to the ground (if enabled - power as set in weapon list) - so an explosion still does hit the ground
    ["max_snapped_height"] = 80, --max height it will snap to ground from
    ["recent_large_explosion_snap"] = true, --enable looking for a recent large_explosion generated by the script
    ["recent_large_explosion_range"] = 100, --range its looking for in meters for a recent large_explosion generated by the script
    ["recent_large_explosion_time"] = 4, --in seconds how long ago there was a recent large_explosion generated by the script

    ---------------------------------------------------------------------- Cluster Bombs Spread Mimic  -------------------------------------------------------
    ["cluster_enabled"] = false,
    ["cluster_base_length"] = 150,           --Base forward spread (meters)
    ["cluster_base_width"] = 200,            --Base lateral spread (meters)
    ["cluster_max_length"] = 300,            --Max forward spread (meters)
    ["cluster_max_width"] = 400,             --Max lateral spread (meters)
    ["cluster_min_length"] = 100,            --Min forward spread
    ["cluster_min_width"] = 150,             --Min lateral spread
    ["cluster_bomblet_reductionmodifier"] = true, --Use equation to reduce number of bomblets (to make it look better)
    ["cluster_bomblet_damage_modifier"] = 1,  --Adjustable global modifier for bomblet explosive power

    ---------------------------------------------------------------------- Giant Explosions ------------------------------------------------------------------
    	--Remember, any target you want to blow up needs to be named "GiantExplosionTarget(X)"  (X) being any value/name etc
    ["giant_explosion_enabled"] = false,  --Toggle to enable/disable Giant Explosion
    ["giant_explosion_power"] = 6000,    --Power in kg of TNT (default 8 tons)
    ["giant_explosion_scale"] = 1,     --Size scale factor (default 1)
    ["giant_explosion_duration"] = 3.0,  --Total duration in seconds (default 3s)
    ["giant_explosion_count"] = 250,      --Number of explosions (default 250)
    ["giantexplosion_ondamage"] = true,   --Trigger explosion when unit is damaged
    ["giantexplosion_ondeath"] = true,    --Trigger explosion when unit is destroyed
    ["giantexplosion_testmode"] = true,  --Enable test mode with separate array for radio commands	
    

    ---------------------------------------------------------------------- Ground/Ship Ordnance  -------------------------------------------------------------
    ["track_groundunitordnance"] = true, --Enable tracking of ground unit ordnance for larger explosion function and blastwave cookoffs etc (shells)
    ["groundunitordnance_damage_modifier"] = 1.0, --Multiplier for ground unit ordnance explosive power
    ["groundunitordnance_blastwave_modifier"] = 4.0, --Additional multiplier for blast wave intensity of ground unit ordnance
    ["groundunitordnance_maxtrackedcount"] = 100, --Maximum number of ground ordnance shells tracked at once to prevent overload
    ["scan_50m_for_groundordnance"] = true, --If true, uses a 50m scan radius for ground ordnance instead of dynamic blast radius
	

    ---------------------------------------------------------------------- Napalm  ---------------------------------------------------------------------------
    ["napalm_mk77_enabled"] = true, --Enable napalm effects for MK77mod0-WPN and MK77mod1-WPN
    ["napalmoverride_enabled"] = false, --If true, enables napalm effects for weapons in napalm_override_weapons
    ["napalm_override_weapons"] = "Mk_82,SAMP125LD", --Comma-separated list of weapons to override as napalm when overrides enabled, i.e Mk_82,SAMP125LD.  Do not pick CBUs
 
    ["napalm_spread_points"] = 4, --Number of points of explosion per each bomb (aka spawns of dummy fuel tank), so 1 bomb can have 4 fireballs as such.  The MK77 0 is bigger and will do a % more by default (i.e 5 instead of 4)
    ["napalm_spread_spacing"] = 25, --Distance m between the points
    ["napalm_phosphor_enabled"] = true, --If true, enables phosphor flare effects for napalm weapons
    ["napalm_phosphor_multiplier"] = 0.5, --Multiplier for number of phosphor flares that shoot out, there is a level of randomisation in the code already
    ["napalm_addflame"] = true, --Enable flame effects at napalm spawn points
    ["napalm_addflame_size"] = 3, --Flame size (1-8, 4 = huge smoke and  fire)
    ["napalm_addflame_duration"] = 180, --Flame duration in seconds napalm_destroy_delay
    ["napalm_flame_delay"] = 0.01, --Delay in seconds before flame effect
    ["napalm_explode_delay"] = 0.01, --Delay in seconds before putting an exlode on the ground to blow up the spawned fuel tank, original script had this as 0.1
    ["napalm_destroy_delay"] = 0.02, --Delay in seconds before it destroys the fuel tank object, original script had this as 0.12
	
    ["napalm_doublewide_enabled"] = false, --Toggle for double-wide napalm (two points per spread point, ~28m width)
    ["napalm_doublewide_spread"] = 15, --Meters either side of bomb vector either side to spawn a fuel tank
	
    ["napalm_unitdamage_enable"] = true, --Enable/disable napalm unit damage
    ["napalm_unitdamage_scandistance"] = 70, --Scan radius in meters
    ["napalm_unitdamage_startdelay"] = 0.1, --Seconds between Napalm exploding and explosion occurring (can be 0 for no delay)
    ["napalm_unitdamage_spreaddelay"] = 0, --If startdelay is greater than 0, explosions are ordered by distance with this gap between each unit
	
    ---------------------------------------------------------------------- Kill Feed  ------------------------------------------------------------------------
    ["killfeed_enable"] = true, --Enable killfeed, required for lekas foothold
    ["killfeed_game_messages"] = false, --Show killfeed SPLASH KILL FEED WORKS IN MP ONLY (you can host your local SP mission as MP for now)
    ["killfeed_game_message_duration"] = 15, --Duration in seconds for game messages (killfeed and SplashKillFeed) - note the message will be delayed to let DCS catch up as per next option
    ["killfeed_splashdelay"] = 8, --Duration in seconds delay to allow dcs to see that units are dead before saying the splash damage got them instead of the the players weapon
    ["killfeed_lekas_foothold_integration"] = true, --Enable Lekas Foothold integration
    ["killfeed_lekas_contribution_delay"] = 0, -- Additional delay before applying splash kills to Foothold contributions after killfeed dedupe

    ---------------------------------------------------------------------- Murder Mode  ----------------------------------------------------------------------	
    ["A10MurderMode"] = false, --This tracks hit events, if the initiator is an A10 it will spawn and explosion on the target
    ["A10MurderMode_Power"] = 5,  --Power of the explosion
    ["A10MurderMode__Chance"] = 1, -- Percent chance a vehicle explodes on hit (0.05 = 5%, 0.5 = 50%)
    ["NamedUnitMurderMode"] = false, --This tracks hit events, if the initiator has "MurderMode" in their name, every hit event from them will put an explosion of the below power at the target's coords
    ["NamedUnitMurderMode_Power"] = 5,  --Power of the explosion from the named unit
    ["NamedUnitMurderMode_Chance"] = 1, -- Percent chance a vehicle explodes on hit (0.05 = 5%, 0.5 = 50%)
	
							
    ---------------------------------------------------------------------- Critical Component ----------------------------------------------------------------
    ["CriticalComponent"] = false, -- Toggle to enable CriticalComponent Feature - % Chance a vehicle is destroyed from a single hit
    ["CriticalComponent_Chance"] = 0.01, -- Percent chance a vehicle explodes on hit (0.01 = 1%, 0.5 = 50%)
    ["CriticalComponent_Explosion_Power"] = 50, --Explosion power for CriticalComponent
    ["CriticalComponent_Specific_Weapons_Only"] = {"GAU8_30_HE", "GAU8_30_AP", "GAU8_30_TP"}, -- {} means all weapons.  List of specific weapons to trigger CriticalComponent, i.e {"GAU8_30_HE", "GAU8_30_AP", "GAU8_30_TP"}

    ---------------------------------------------------------------------- Ground Unit Explosion On Death ----------------------------------------------------
		--You can also trigger this to happen if the unit has "GUED" in its name - so you can set the chance to 0 and still have them go off for specific units
    ["GU_Explode_on_Death"] = true,  --If a vehicle is dead and has had no other effects on it, trigger an explosion - This is at the start of its on fire for a bit before popping stage if you've hit it or on pop if its a dead event
    ["GU_Explode_on_Death_Chance"] = 0.5, --Percent chance a vehicle explodes on death (0.05 = 5%, 0.5 = 50%)
    ["GU_Explode_on_Death_Explosion_Power"] = 30, --Explosion power for explode on death	
    ["GU_Explode_on_Death_Height"] = 1, --Height above coords of the vehicle.  Close to ground throws up more dirt, higher up more of a puff of smoke
    ["GU_Explode_Exclude_Infantry"] = true,  --Set to false to make infantry blow up too
		
    ---------------------------------------------------------------------- CBU Bomblet Hit Explosion ---------------------------------------------------------
    ["CBU_Bomblet_Hit_Explosion"] = false, --ONLY TESTED WITH JSOW-A - Enable/Disable - on a hit even by a bomblet it can do extra damage AND/OR scan around the unit to deal damage with additional explosions of the power set in the cluster table
    ["CBU_Bomblet_Hit_Explosion_Scaling"] = 35, --Overall Multiplier for the final bomblet damage result.  Default 35 to get the effects we want when the ground level is less than 1.6 - WHEN TESTED WITH JSOW-A
    ["CBU_Bomblet_Hit_Mimic_Spread"] = true, --Enable/Disable - Mimic spread of clusterbomb warheads by scanning an area around the target that was hit and triggering an explosion against any unit or structure (unitIds can only be hit once by this weaponid)
    ["CBU_Bomblet_Hit_Spread"] = 50, --Scan radius m to look for units to hit
	
    ["CBU_Bomblet_Hit_Spread_SecondaryScan"] = 50, --Scan radius m to look for units to hit
    ["CBU_Bomblet_Hit_Spread_Duration"] = 2, --Schedule additional unit explosions over this many seconds
    ["CBU_Bomblet_NonArmored_Dmg_Modifier"] = 1.0, --Multiplier damage for NonArmored units (e.g., Infantry, trucks), vulnerable to bomblets
    ["CBU_Bomblet_LightlyArmored_Dmg_Modifier"] = 0.8, --Multiplier damage for LightlyArmored units. 0.3 = 30% of damage (e.g., BTR-80, ZSU-23-4, moderately vulnerable (e.g., BLU-97B, PTAB-10-5)
    ["CBU_Bomblet_Armored_Dmg_Modifier"] = 0.6, --Multiplier for damage for Armored units. 0.3 = 30% of damage (e.g., T-90, BMP-3), highly resistant (e.g., Mk 118, HEAT)
    ["CBU_Bomblet_Hit_Chance"] = 0.8, --Chance that a unit gets hit.  0.8 = 80%.
    ["CBU_Bomblet_Indirect_Hit_Chance"] = 0.2, --Chance that the direct hit was actually indirect or less critical, 0.5% = 20% chance
    ["CBU_Bomblet_Indirect_Dmg_Modifier"] = 0.4, --Multiplier for if its an indirect or less critical hit 0.4 = 40% of damage/60% reduction
    ["CBU_Bomblet_Explosion_Height"] = 0.1, -- Explosions at ground height do less damage and typically kick up more dirt, increase height by this much
	
    ---------------------------------------------------------------------- Strobe Marker / Beacon ------------------------------------------------------------
    	--Only enable one of the strobe methods at a time
    ["StrobeMarker_allstrobeunits"] = false, --Constantly fire off strobe for all living, active units and not invisible units with Strobe in the name
    ["StrobeMarker_individuals"] = false, --Ability to enable or diable the strobing via radio commands for indiviudual "Strobe" units
    ["StrobeMarker_interval"] = 2, --Default interval in seconds for strobing explosions
	
	

	---------------------------------------------------------------------- Tactical Explosion ----------------------------------------------------
    ["tactical_explosion"] = false, --Enable tactical explosion effects
    ["tactical_explosion_override_enabled"] = true, --Set this to true to enable override weapons in the key below
    ["tactical_explosion_override_weapons"] = "SCUD_RAKETA", --Comma-separated list of weapons to override as tactical explosion, can be changed as needed.  Needs to be enabled in the key above.  Current has tomahawks and mk82 bombs there as examples
    ["tactical_explosion_max_height"] = 40, --Max height above ground for tactical explosion to trigger (meters)
    ["tactical_explosion_scaling"] = 1, --Scaling of explosion powers, counts, radius
    ["tactical_explosion_central_power"] = 4000, --Power of central explosion
    ["tactical_explosion_explosion_power"] = 1000, --Base power for secondary explosions
    ["tactical_explosion_explosion_count_min"] = 35, --Min number of secondary explosions
    ["tactical_explosion_explosion_count_max"] = 35, --Max number of secondary explosions
    ["tactical_explosion_radius"] = 100, --Max radius for secondary explosions (meters)
    ["tactical_explosion_explosion_delay_max"] = 0.4, --Max delay multiplier for secondary explosions
    ["tactical_explosion_fueltankspawn"] = false, --Spawn a fuel tank at the explosion location for effect/smoke
    
}

local script_enable = 1
refreshRate = 0.1
----[[ ##### End of SCRIPT CONFIGURATION ##### ]]----

--Helper function: Trim whitespace.



local function trim(s)
    return s:match("^%s*(.-)%s*$")
end
 
cargoUnits = {

--[[
flamesize:

 1 = small smoke and fire
 2 = medium smoke and fire
 3 = large smoke and fire
 4 = huge smoke and fire
 5 = small smoke
 6 = medium smoke 
 7 = large smoke
 8 = huge smoke 
]]--	

    --1) M92 R11 Volvo driveable (Fuel Truck Tanker)
    ["r11_volvo_drivable"] = { 
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 0,
        cookOffPower = 0,
        cookOffDuration = 0,
        cookOffRandomTiming = false,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 3,
        flameDuration = 5,
    },

    --2) Refueler ATMZ-5
    ["ATMZ-5"] = {
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 0,
        cookOffPower = 0,
        cookOffDuration = 0,
        cookOffRandomTiming = false,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 3,
        flameDuration = 5,
    },

    --3) Refueler ATZ-10
    ["ATZ-10"] = {
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 0,
        cookOffPower = 0,
        cookOffDuration = 0,
        cookOffRandomTiming = false,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 3,
        flameDuration = 5,
    },

    --4) Refueler ATZ-5 
    ["ATZ-5"] = {
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 0,
        cookOffPower = 0,
        cookOffDuration = 0,
        cookOffRandomTiming = false,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 3,
        flameDuration = 5,
    },

    --5) Refueler M978 HEMTT (Fuel truck tanker)
    ["M978 HEMTT Tanker"] = {
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 0,
        cookOffPower = 0,
        cookOffDuration = 0,
        cookOffRandomTiming = false,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 3,
        flameDuration = 5,
    },

    --##### AMMO CARRIERS #####
    ["GAZ-66"] = {
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = true,
        cookOffCount = 4,
        cookOffPower = 1,
        cookOffDuration = 20,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = false,
        flameSize = 1,
        flameDuration = 30,
    },
--#Technically this is both ammo and fuel looking at the model
--#Called Ural-4320 in game, but in code its Ural-375
    ["Ural-375"] = {
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = true,
        cookOffCount = 4,
        cookOffPower = 1,
        cookOffDuration = 20,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 1,
        flameDuration = 30,
    },

    ["ZIL-135"] = {
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = true,
        cookOffCount = 6,
        cookOffPower = 1,
        cookOffDuration = 24,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = false,
        flameSize = 1,
        flameDuration = 30,
    },
	
	--#Ammo Boxes etc
	
	--#Long ammo box
	
	    ["Cargo06"] = {
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = true,
        cookOffCount = 5,
        cookOffPower = 1,
        cookOffDuration = 10,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = false,
        flameSize = 1,
        flameDuration = 30,
    },

		--#ammo boxes
	
	    ["Cargo03"] = {
        cargoExplosion = true,
		cargoExplosionPower = 10,
        cargoCookOff = true,
        cookOffCount = 10,
        cookOffPower = 1,
        cookOffDuration = 20,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 0,
        isTanker = false,
        flameSize = 1,
        flameDuration = 30,
    },
	
		--FuelBarrels
	
	    ["Cargo05"] = {
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 2,
        cookOffPower = 1,
        cookOffDuration = 10,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 2,
        flameDuration = 30,
    },
	
		--APFC fuel
	
	    ["APFC fuel"] = {
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 2,
        cookOffPower = 1,
        cookOffDuration = 10,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 2,
        flameDuration = 30,
    },
	
		--Oil Barrel
	
	    ["Oil Barrel"] = {
        cargoExplosion = true,
		cargoExplosionPower = 20,
        cargoCookOff = false,
        cookOffCount = 0,
        cookOffPower = 1,
        cookOffDuration = 10,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 1,
        flameDuration = 20,
    },
	
	
		--FARP Ammo Dump Coating
	
	    ["FARP Ammo Dump Coating"] = {
        cargoExplosion = true,
		cargoExplosionPower = 50,
        cargoCookOff = true,
        cookOffCount = 5,
        cookOffPower = 1,
        cookOffDuration = 20,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = false,
        flameSize = 1,
        flameDuration = 20,
    },
}
--[[


-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-
                                                                Weapon Explosive Table             
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-]]

--If you want to the specific weapon to skip the damage_model (blastwave damage) or the larger_explosion you can modify the entry like so:
    --["Mk_82"] = { explosive = 100, Skip_larger_explosions = true, Skip_damage_model = true },
explTable = {
    --*** WWII BOMBS ***
    ["British_GP_250LB_Bomb_Mk1"] = { explosive = 100 },
    ["British_GP_250LB_Bomb_Mk4"] = { explosive = 100 },
    ["British_GP_250LB_Bomb_Mk5"] = { explosive = 100 },
    ["British_GP_500LB_Bomb_Mk1"] = { explosive = 213 },
    ["British_GP_500LB_Bomb_Mk4"] = { explosive = 213 },
    ["British_GP_500LB_Bomb_Mk4_Short"] = { explosive = 213 },
    ["British_GP_500LB_Bomb_Mk5"] = { explosive = 213 },
    ["British_MC_250LB_Bomb_Mk1"] = { explosive = 100 },
    ["British_MC_250LB_Bomb_Mk2"] = { explosive = 100 },
    ["British_MC_500LB_Bomb_Mk1_Short"] = { explosive = 213 },
    ["British_MC_500LB_Bomb_Mk2"] = { explosive = 213 },
    ["British_SAP_250LB_Bomb_Mk5"] = { explosive = 100 },
    ["British_SAP_500LB_Bomb_Mk5"] = { explosive = 213 },
    ["British_AP_25LBNo1_3INCHNo1"] = { explosive = 4 },
    ["British_HE_60LBSAPNo2_3INCHNo1"] = { explosive = 4 },
    ["British_HE_60LBFNo1_3INCHNo1"] = { explosive = 4 },
  
    ["SC_50"] = { explosive = 20 },
    ["ER_4_SC50"] = { explosive = 20 },
    ["SC_250_T1_L2"] = { explosive = 100 },
    ["SC_501_SC250"] = { explosive = 100 },
    ["Schloss500XIIC1_SC_250_T3_J"] = { explosive = 100 },
    ["SC_501_SC500"] = { explosive = 213 },
    ["SC_500_L2"] = { explosive = 213 },
    ["SD_250_Stg"] = { explosive = 100 },
    ["SD_500_A"] = { explosive = 213 },
  
    --*** WWII CBU ***
    ["AB_250_2_SD_2"] = { explosive = 100 },
    ["AB_250_2_SD_10A"] = { explosive = 100 },
    ["AB_500_1_SD_10A"] = { explosive = 213 },
  
    --*** WWII ROCKETS ***
    ["3xM8_ROCKETS_IN_TUBES"] = { explosive = 4 },
    ["WGr21"] = { explosive = 4 },
  
    --*** UNGUIDED BOMBS (UGB) ***
    ["M_117"] = { explosive = 201 },
    ["AN_M30A1"] = { explosive = 45 },
    ["AN_M57"] = { explosive = 100 },
    ["AN_M64"] = { explosive = 121 },
    ["AN_M65"] = { explosive = 400 },
    ["AN_M66"] = { explosive = 800 },
    ["AN-M66A2"] = { explosive = 536 },
    ["AN-M81"] = { explosive = 100 },
    ["AN-M88"] = { explosive = 100 },
  
    ["Mk_81"] = { explosive = 60 },
    ["MK-81SE"] = { explosive = 60 },
	["Mk_82"] = { explosive = 100},
    ["MK_82AIR"] = { explosive = 100 },
    ["MK_82SNAKEYE"] = { explosive = 100 },
    ["Mk_83"] = { explosive = 274 },
    ["Mk_84"] = { explosive = 582 },
  
    ["HEBOMB"] = { explosive = 40 },
    ["HEBOMBD"] = { explosive = 40 },
  
    ["SAMP125LD"] = { explosive = 60 },
    ["SAMP250LD"] = { explosive = 118 },
    ["SAMP250HD"] = { explosive = 118 },
    ["SAMP400LD"] = { explosive = 274 },
    ["SAMP400HD"] = { explosive = 274 },
  
    ["BR_250"] = { explosive = 100 },
    ["BR_500"] = { explosive = 100 },
  
    ["FAB_100"] = { explosive = 45 },
    ["FAB_250"] = { explosive = 118 },
    ["FAB_250M54TU"] = { explosive = 118 },
    ["FAB-250-M62"] = { explosive = 118 },
    ["FAB_500"] = { explosive = 213 },
    ["FAB_1500"] = { explosive = 675 },
  
    --*** UNGUIDED BOMBS WITH PENETRATOR / ANTI-RUNWAY ***
    ["Durandal"] = { explosive = 64 },
    ["BLU107B_DURANDAL"] = { explosive = 64 },
    ["BAP_100"] = { explosive = 32 },
    ["BAP-100"] = { explosive = 32 },
    ["BAT-120"] = { explosive = 32 },
    ["TYPE-200A"] = { explosive = 107 },
    ["BetAB_500"] = { explosive = 98 },
    ["BetAB_500ShP"] = { explosive = 107 },
    
    --*** GUIDED BOMBS (GBU) ***
    ["GBU_10"] = { explosive = 582 },
    ["GBU_12"] = { explosive = 100 }, 
    ["GBU_16"] = { explosive = 274 },
    ["GBU_24"] = { explosive = 582 },
    ["KAB_1500Kr"] = { explosive = 675 },
    ["KAB_500Kr"] = { explosive = 213 },
    ["KAB_500"] = { explosive = 213 },
  
    --*** CLUSTER BOMBS (CBU) ***
	--I don't have most of these so can't test them with debug on
	--For the CBU_Bomblet_Hit_Explosion feature, see a different table called "clusterSubMunTable"
    ["MK77mod0-WPN"] = { explosive = 0, cluster = false, submunition_count = 132, submunition_explosive = 0.1, submunition_name = "BLU_1B" }, --napalm skyhawk, have set to cluster (false) for napalm purposes
    ["MK77mod1-WPN"] = { explosive = 0, cluster = false, submunition_count = 132, submunition_explosive = 0.1, submunition_name = "BLU_1B" }, --napalm skyhawk, have set to cluster (false) for napalm purposes
    ["CBU_99"] = { explosive = 0, cluster = true, submunition_count = 247, submunition_explosive = 2, submunition_name = "Mk 118" }, --Mk 20 Rockeye variant, confirmed 247 Mk 118 bomblets
    ["ROCKEYE"] = { explosive = 0, cluster = true, submunition_count = 247, submunition_explosive = 2, submunition_name = "Mk 118" }, --Mk 20 Rockeye, confirmed 247 Mk 118 bomblets
    ["BLU_3B_GROUP"] = { explosive = 0, cluster = true, submunition_count = 19, submunition_explosive = 0.2, submunition_name = "BLU_3B" }, --Not in datamine, possibly custom or outdated; submunition name guessed
    ["CBU_87"] = { explosive = 0, cluster = true, submunition_count = 202, submunition_explosive = 0.5, submunition_name = "BLU_97B" }, --Confirmed 202 BLU-97/B bomblets
    ["CBU_103"] = { explosive = 0, cluster = true, submunition_count = 202, submunition_explosive = 0.5, submunition_name = "BLU_97B" }, --WCMD variant of CBU-87, confirmed 202 BLU-97/B bomblets
    ["CBU_97"] = { explosive = 0, cluster = true, submunition_count = 10, submunition_explosive = 15, submunition_name = "BLU_108" }, --Confirmed 10 BLU-108 submunitions, each with 4 skeets
    ["CBU_105"] = { explosive = 0, cluster = true, submunition_count = 10, submunition_explosive = 15, submunition_name = "BLU_108" }, --WCMD variant of CBU-97, confirmed 10 BLU-108 submunitions
    ["BELOUGA"] = { explosive = 0, cluster = true, submunition_count = 151, submunition_explosive = 0.3, submunition_name = "grenade_AC" }, --Confirmed 151 grenade_AC bomblets (French BLG-66)
    ["BLG66_BELOUGA"] = { explosive = 0, cluster = true, submunition_count = 151, submunition_explosive = 0.3, submunition_name = "grenade_AC" }, --Alias for BELOUGA, confirmed 151 grenade_AC bomblets
    ["BL_755"] = { explosive = 0, cluster = true, submunition_count = 147, submunition_explosive = 0.4, submunition_name = "BL_755_bomblet" }, --Confirmed 147 bomblets, submunition name from your table
    ["RBK_250"] = { explosive = 0, cluster = true, submunition_count = 60, submunition_explosive = 0.5, submunition_name = "PTAB_25M" }, --Confirmed 60 PTAB-2.5M anti-tank bomblets
    ["RBK_250_275_AO_1SCH"] = { explosive = 0, cluster = true, submunition_count = 150, submunition_explosive = 0.2, submunition_name = "AO_1SCh" }, --Confirmed 150 AO-1SCh fragmentation bomblets
    ["RBK_500"] = { explosive = 0, cluster = true, submunition_count = 108, submunition_explosive = 0.5, submunition_name = "PTAB_10_5" }, --Confirmed 108 PTAB-10-5 anti-tank bomblets
    ["RBK_500U"] = { explosive = 0, cluster = true, submunition_count = 352, submunition_explosive = 0.2, submunition_name = "OAB_25RT" }, --Confirmed 352 OAB-2.5RT fragmentation bomblets
    ["RBK_500AO"] = { explosive = 0, cluster = true, submunition_count = 108, submunition_explosive = 0.5, submunition_name = "AO_25RT" }, --Confirmed 108 AO-2.5RT fragmentation bomblets
    ["RBK_500U_OAB_2_5RT"] = { explosive = 0, cluster = true, submunition_count = 352, submunition_explosive = 0.2, submunition_name = "OAB_25RT" }, --Confirmed 352 OAB-2.5RT fragmentation bomblets
    ["RBK_500_255_PTO_1M"] = { explosive = 0, cluster = true, submunition_count = 126, submunition_explosive = 0.5, submunition_name = "PTO_1M" },
    ["RBK_500_255_ShO"] = { explosive = 0, cluster = true, submunition_count = 565, submunition_explosive = 0.1, submunition_name = "ShO" },  

    --*** INS/GPS BOMBS (JDAM) ***
    ["GBU_31"] = { explosive = 582 },
    ["GBU_31_V_3B"] = { explosive = 582 },
    ["GBU_31_V_2B"] = { explosive = 582 },
    ["GBU_31_V_4B"] = { explosive = 582 },
    ["GBU_32_V_2B"] = { explosive = 202 },
    ["GBU_38"] = { explosive = 100 },
    ["GBU_54_V_1B"] = { explosive = 100 },
  
    --*** GLIDE BOMBS (JSOW) ***
    ["AGM_154A"] = { explosive = 0, cluster = true, submunition_count = 145, submunition_explosive = 2, submunition_name = "BLU-97/B" }, --JSOW-A, confirmed 145 BLU-97 bomblets from datamine
    ["AGM_154C"] = { explosive = 305 },
    ["AGM_154"] = { explosive = 305 },
    ["BK90_MJ1"] = { explosive = 0 },
    ["BK90_MJ1_MJ2"] = { explosive = 0 },
    ["BK90_MJ2"] = { explosive = 0 },
  
    ["LS-6-100"] = { explosive = 45 },
    ["LS-6-250"] = { explosive = 100 },
    ["LS-6-500"] = { explosive = 274 },
    ["GB-6"]    = { explosive = 0 },
    ["GB-6-HE"] = { explosive = 0 },
    ["GB-6-SFW"] = { explosive = 0 },
  
    --*** AIR GROUND MISSILE (AGM) ***
    ["AGM_62"] = { explosive = 400 },
    ["AGM_65D"] = { explosive = 38, shaped_charge = true },
    ["AGM_65E"] = { explosive = 80, shaped_charge = true },
    ["AGM_65F"] = { explosive = 80, shaped_charge = true },
    ["AGM_65G"] = { explosive = 80, shaped_charge = true },
    ["AGM_65H"] = { explosive = 38, shaped_charge = true },
    ["AGM_65K"] = { explosive = 80, shaped_charge = true },
    ["AGM_65L"] = { explosive = 80, shaped_charge = true },
    ["AGM_123"] = { explosive = 274 },
    ["AGM_130"] = { explosive = 582 },
    ["AGM_119"] = { explosive = 176 },
    ["AGM_114"] = { explosive = 10, shaped_charge = true },
    ["AGM_114K"] = { explosive = 10, shaped_charge = true },
  
    ["Rb 05A"] = { explosive = 217 },
    ["RB75"] = { explosive = 38 },
    ["RB75A"] = { explosive = 38 },
    ["RB75B"] = { explosive = 38 },
    ["RB75T"] = { explosive = 80 },
    ["HOT3_MBDA"] = { explosive = 15 },
    ["C-701T"] = { explosive = 38 },
    ["C-701IR"] = { explosive = 38 },
  
    ["Vikhr_M"] = { explosive = 11 },
    ["Vikhr_9M127_1"] = { explosive = 11 },
    ["AT_6"] = { explosive = 11 },
    ["Ataka_9M120"] = { explosive = 11 },
    ["Ataka_9M120F"] = { explosive = 11 },
    ["P_9M117"] = { explosive = 0 },
    
    ["KH-66_Grom"] = { explosive = 108 },
    ["X_23"] = { explosive = 111 },
    ["X_23L"] = { explosive = 111 },
    ["X_28"] = { explosive = 160 },
    ["X_25ML"] = { explosive = 89 },
    ["X_25MR"] = { explosive = 140 },
    ["X_29L"] = { explosive = 320 },
    ["X_29T"] = { explosive = 320 },
    ["X_29TE"] = { explosive = 320 },
	
    ["AKD-10"] = { explosive = 10 }, --drone
	
    --*** ANTI-RADAR MISSILE (ARM) ***
    ["AGM_88C"] = { explosive = 69 },
    ["AGM_88"] = { explosive = 69 },
    ["AGM_122"] = { explosive = 12 },
    ["LD-10"] = { explosive = 75 },
    ["AGM_45A"] = { explosive = 66 },
	["AGM_45B"] = { explosive = 66 },
    ["X_58"] = { explosive = 149 },
    ["X_25MP"] = { explosive = 90 },
    ["X_31P"]    = { explosive = 90,  shaped_charge = false },
  
    --*** ANTI-SHIP MISSILE (ASh) ***
    ["AGM_84D"] = { explosive = 488 },
    ["Rb 15F"] = { explosive = 500 },
    ["C-802AK"] = { explosive = 500 },
    ["X_31A"]    = { explosive = 89,  shaped_charge = false }, --KH-31A ASh
    ["X_22"]    = { explosive = 1200,  shaped_charge = false }, --Ash 1ton RDX = 1600KG TNT
    ["X_35"]    = { explosive = 145,  shaped_charge = true }, --ASh 145KG
	
    --*** CRUISE MISSILE ***
    ["CM-802AKG"] = { explosive = 240 },
    ["AGM_84E"] = { explosive = 360 },
    ["AGM_84H"] = { explosive = 380 },
    ["X_59M"] = { explosive = 340 },
    ["X_65"] = { explosive = 545 },
  
    --*** ROCKETS ***
    ["HYDRA_70M15"] = { explosive = 5 },
    ["HYDRA_70_MK1"] = { explosive = 5 },
    ["HYDRA_70_MK5"] = { explosive = 8 },
    ["HYDRA_70_M151"] = { explosive = 5 },
    ["HYDRA_70_M151_M433"] = { explosive = 5 },
    ["HYDRA_70_M229"] = { explosive = 10 },
    ["FFAR Mk1 HE"] = { explosive = 5 },
    ["FFAR Mk5 HEAT"] = { explosive = 8 },
    ["HVAR"] = { explosive = 5 },
    ["Zuni_127"] = { explosive = 8 },
    ["ARAKM70BHE"] = { explosive = 5 },
    ["ARAKM70BAP"] = { explosive = 8 },
    ["SNEB_TYPE251_F1B"] = { explosive = 4 },
    ["SNEB_TYPE252_F1B"] = { explosive = 4 },
    ["SNEB_TYPE253_F1B"] = { explosive = 5 },
    ["SNEB_TYPE256_F1B"] = { explosive = 6 },
    ["SNEB_TYPE257_F1B"] = { explosive = 8 },
    ["SNEB_TYPE251_F4B"] = { explosive = 4 },
    ["SNEB_TYPE252_F4B"] = { explosive = 4 },
    ["SNEB_TYPE253_F4B"] = { explosive = 5 },
    ["SNEB_TYPE256_F4B"] = { explosive = 6 },
    ["SNEB_TYPE257_F4B"] = { explosive = 8 },
    ["SNEB_TYPE251_H1"] = { explosive = 4 },
    ["SNEB_TYPE252_H1"] = { explosive = 4 },
    ["SNEB_TYPE253_H1"] = { explosive = 5 },
    ["SNEB_TYPE256_H1"] = { explosive = 6 },
    ["SNEB_TYPE257_H1"] = { explosive = 8 },
    ["MATRA_F4_SNEBT251"] = { explosive = 8 },
    ["MATRA_F4_SNEBT253"] = { explosive = 8 },
    ["MATRA_F4_SNEBT256"] = { explosive = 8 },
    ["MATRA_F1_SNEBT253"] = { explosive = 8 },
    ["MATRA_F1_SNEBT256"] = { explosive = 8 },
    ["TELSON8_SNEBT251"] = { explosive = 4 },
    ["TELSON8_SNEBT253"] = { explosive = 8 },
    ["TELSON8_SNEBT256"] = { explosive = 4 },
    ["TELSON8_SNEBT257"] = { explosive = 6 },
    ["ARF8M3API"] = { explosive = 8 },
    ["UG_90MM"] = { explosive = 8 },
    ["S-24A"] = { explosive = 24 },
    ["S-25OF"] = { explosive = 194 },
    ["S-25OFM"] = { explosive = 150 },
    ["S-25O"] = { explosive = 150 },
    ["S-25-O"] = { explosive = 150 },
    ["S_25L"] = { explosive = 190 },
    ["S-5M"] = { explosive = 3 },
    ["C_5"] = { explosive = 8 },
    ["C5"] = { explosive = 5 },
    ["C_8"] = { explosive = 5 },
    ["C_8OFP2"] = { explosive = 5 },
    ["C_13"] = { explosive = 21 },
    ["C_24"] = { explosive = 123 },
    ["C_25"] = { explosive = 151 },
  
    --*** LASER ROCKETS ***
    ["AGR_20"] = { explosive = 8 },
    ["AGR_20A"] = { explosive = 8 },
    ["AGR_20_M282"] = { explosive = 8 },
    ["Hydra_70_M282_MPP"] = { explosive = 5, shaped_charge = true },
    ["BRM-1_90MM"] = { explosive = 8 },

    --*** JF17 weapons changes as per Kurdes ***
    ["C_701T"] = { explosive = 38 },
    ["C_701IR"] = { explosive = 38 },
    ["LS_6_100"] = { explosive = 45 },
    ["LS_6"] = { explosive = 100 },
    ["LS_6_500"] = { explosive = 274 },
    ["Type_200A"] = { explosive = 107 },
    ["C_802AK"] = { explosive = 500 },
    ["CM_802AKG"] = { explosive = 240 },    
    
    --*** JF39 Mod by Whisky.Actual as per Kurdes ***
    ["Brimstone Laser Guided Missile x3"] = { explosive = 38, shaped_charge = true },    
    ["MAR-1 High Speed Anti-Radiation Missile"] = { explosive = 75 },
    ["GBU-39 SDB 285lb Guided Glide-Bomb"] = { explosive = 45 },
    ["SPEAR-3 Air-to-Ground Glide Missile"] = { explosive = 38 },
    ["Spear EW"] = { explosive = 0 },
	
    --==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
	                        --*** Vehicle/Ship based ***--	
    --==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
    
	--*** Rocketry ***
    ["9M22U"] = { explosive = 25, groundordnance = true }, --122mm HE rocket, BM-21 Grad (~20-30 kg TNT equiv)
    ["GRAD_9M22U"] = { explosive = 25, groundordnance = true }, --122mm HE rocket, BM-21 Grad (~20-30 kg TNT equiv)
       -- ["M26"] = { explosive = 0, groundordnance = true}, --227mm cluster rocket, M270 MLRS (adjusted for cluster)
    ["M26"] = { explosive = 0, cluster = true, submunition_count = 644, submunition_explosive = 0.1, submunition_name = "M77", groundordnance = true }, --227mm cluster rocket, M270 MLRS (adjusted for cluster)
    ["SCUD_RAKETA"] = { explosive = 985, groundordnance = true },
    ["SMERCH_9M55F"] = { explosive = 46, groundordnance = true }, --220mm HE rocket, (~25-45 kg TNT equiv)
	
	["TOW2"] = { explosive = 6.5, shaped_charge = true, groundordnance = true },  --ATGM
	
	--*** Shells ***
	["weapons.shells.M_105mm_HE"] = { explosive = 12, groundordnance = true }, --105mm HE shell, M119/M102 (~10-15 kg TNT equiv)
	["weapons.shells.M_155mm_HE"] = { explosive = 60, groundordnance = true }, --155mm HE shell, M777/M109 (~50-70 kg TNT equiv)
	["weapons.shells.2A60_120"] = { explosive = 18, groundordnance = true }, --120mm HE shell, 2B11 mortar (~15-20 kg TNT equiv)
	["weapons.shells.2A18_122"] = { explosive = 22, groundordnance = true }, --122mm HE shell, D-30 (~20-25 kg TNT equiv)
	["weapons.shells.2A33_152"] = { explosive = 50, groundordnance = true }, --152mm HE shell, SAU Akatsia (~40-60 kg TNT equiv)
	["weapons.shells.PLZ_155_HE"] = { explosive = 60, groundordnance = true }, --155mm HE shell, PLZ05 (~50-70 kg TNT equiv)
	["weapons.shells.M185_155"] = { explosive = 60, groundordnance = true }, --155mm HE shell, M109 (~50-70 kg TNT equiv)
	["weapons.shells.2A64_152"] = { explosive = 50, groundordnance = true }, --152mm HE shell, SAU Msta (~40-60 kg TNT equiv) 
	
	["weapons.shells.2A46M_125_HE"] = { explosive = 5, groundordnance = true }, --125mm HE shell, T-90 (~5-6 kg TNT equiv)
	["weapons.shells.HESH_105"] = { explosive = 6, groundordnance = true }, --105mm HESH shell, M1128 Stryker (~4-6 kg TNT equiv)
	
	---*** Naval ***
	["BGM_109B"] = { explosive = 450, groundordnance = true }, -- Tomahawk
	["AGM_84S"] = { explosive = 225, groundordnance = true }, --Harpoon missile, Ticonderoga (~200-250 kg TNT equiv)
	["P_500"] = { explosive = 500, groundordnance = true }, --P-500 Bazalt missile, Moscow (~450-550 kg TNT equiv)	
	
	["weapons.shells.AK176_76"] = { explosive = 1, groundordnance = true }, --76mm HE shell, AK-176 (~0.7-1 kg TNT equiv)
	["weapons.shells.A222_130"] = { explosive = 5, groundordnance = true }, --130mm HE shell, A-222 Bereg (~4-5 kg TNT equiv)
	["weapons.shells.53-UBR-281U"] = { explosive = 5, groundordnance = true }, --130mm HE shell, SM-2-1 (~4-5 kg TNT equiv)
	["weapons.shells.PJ87_100_PFHE"] = { explosive = 3, groundordnance = true }, --100mm HE-PF shell, Type 052B (~2.4-3.4 kg TNT equiv)
	["weapons.shells.AK100_100"] = { explosive = 3, groundordnance = true }, --100mm HE shell, AK-100 (~2.5-3.5 kg TNT equiv) AK-100 100mm (e.g., on Project 1135 Krivak-class)
	["weapons.shells.AK130_130"] = { explosive = 5, groundordnance = true }, --130mm HE shell, AK-130 (~4-5 kg TNT equiv) AK-130 130mm (e.g., on Project 956 Sovremenny-class)
	["weapons.shells.2A70_100"] = { explosive = 3, groundordnance = true }, --100mm HE shell, 2A70 (~3-3.5 kg TNT equiv) 2A70 100mm (e.g., on Project 775 Ropucha-class)
	["weapons.shells.OTO_76"] = { explosive = 1, groundordnance = true }, --76mm HE shell, OTO Melara (~0.8-1.1 kg TNT equiv) OTO Melara 76mm (e.g., on NATO frigates like Oliver Hazard Perry-class)
	["weapons.shells.MK45_127"] = { explosive = 5, groundordnance = true }, --127mm HE shell, Mark 45 (~4.8-5.6 kg TNT equiv) Mark 45 127mm (e.g., on Arleigh Burke-class destroyers)
	["weapons.shells.PJ26_76_PFHE"] = { explosive = 1, groundordnance = true }, --76mm HE-PF shell, PJ-26 (~0.8-1.1 kg TNT equiv)
	["weapons.shells.53-UOR-281U"] = { explosive = 5, groundordnance = true }, --130mm HE shell, SM-2-1 (~4-5 kg TNT equiv)
	["weapons.shells.MK75_76"] = { explosive = 1, groundordnance = true }, --76mm HE shell, Mk 75 (~0.8-1.1 kg TNT equiv)
	
	--*** Bismark Mod Weapon ***
    ["weapons.shells.Breda_37_HE"] = { explosive = 70, groundordnance = true }, --380mm HE shell, 38 cm SK C/34 (~60-75 kg TNT equiv)
	--*** Bismark Mod Weapons ***
	["weapons.shells.380mm_HE"] = { explosive = 70, groundordnance = true }, --380mm HE shell, 38 cm SK C/34 (~60-75 kg TNT equiv)
	["weapons.shells.SK_C_33_105_HE"] = { explosive = 15, groundordnance = true }, --105mm HE shell, SK C/33 (~12-16 kg TNT equiv)

}

napalm_unitcat_tabl = {
    ["Infantry"] = { maxDamageDistance = 50, explosionPower = 0.5 }, 
    ["Tank"] = { maxDamageDistance = 30, explosionPower = 5 }, 
    ["Artillery"] = { maxDamageDistance = 40, explosionPower = 5 }, 
    ["Armored Vehicle"] = { maxDamageDistance = 35, explosionPower = 5 }, 
    ["Anti-Air"] = { maxDamageDistance = 35, explosionPower = 5 }, 
    ["Helicopter"] = { maxDamageDistance = 45, explosionPower = 5 }, 
    ["Airplane"] = { maxDamageDistance = 40, explosionPower = 5 },
    ["Structure"] = { maxDamageDistance = 60, explosionPower = 60 }
}

--Table for cluster submunitions
clusterSubMunTable = {
    ["Mk 118"] = { explosive = 2 }, --Rockeye/CBU99, 247 bomblets, 0.18 kg TNT, expected to damage: infantry, light vehicles, light armor (up to ~190 mm penetration)
    ["BLU-97B"] = { explosive = 3 }, --CBU_87/CBU_103, 202 bomblets, 0.45 kg TNT, expected to damage: infantry, light vehicles, light to medium armor, soft structures
    ["BLU-97/B"] = { explosive = 3 }, --AGM 154s, variable bomblets, 0.45 kg TNT, expected to damage: infantry, light vehicles, light to medium armor, soft structures
    --["BLU-108"] = { explosive = 9.0 }, --CBU_97/CBU_105, 40 bomblets, 3.4 kg TNT, expected to damage: medium to heavy armor, vehicles, fortifications **DISABLED DUE TO BEING AFFECTIVE ALREADY**
    ["AO-2-5"] = { explosive = 2.5 }, --RBK_500AO, 96 bomblets, 0.37 kg TNT, expected to damage: infantry, light vehicles, light armor
    ["BLU-3"] = { explosive = 1 }, --Heatblur F4 BLU-3_GROUP, 426 bomblets, 0.08 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["BLU-3B"] = { explosive = 1 }, --Heatblur F4, 426 bomblets, 0.08 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["BLU-4B"] = { explosive = 1 }, --Heatblur F4, 96 bomblets, 0.1 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["HEAT"] = { explosive = 1.5 }, --BL_755, 147 bomblets, 0.6 kg TNT, expected to damage: infantry, light vehicles, light to medium armor
    ["MJ2"] = { explosive = 1 }, --Mjolnir, 72 bomblets, 0.1 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["MJ1"] = { explosive = 1 }, --Gripen/DWS Mjolnir, 72 bomblets, 0.1 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["GR_66_AC"] = { explosive = 1 }, --BL66_BELOUGA, 49 bomblets, 0.1 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["9N235"] = { explosive = 1.85 }, --sMERCH 9m55K, 30 bomblets, 0.18 kg TNT, expected to damage: infantry, light vehicles, light armor
    ["GB-06"] = { explosive = 2 }, --GB6 glide bomb, variable bomblets, 0.3 kg TNT, expected to damage: infantry, light vehicles, light armor
    ["SD-10A"] = { explosive = 1 }, --WW2 German cluster/AB_500_1_SD_10A, 78 bomblets, 0.07 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["PTAB-2.5KO"] = { explosive = 1 }, --PBKF - 12 x PTAB-2.5KO, 12 bomblets, 0.25 kg TNT, expected to damage: infantry, light vehicles, light armor
    ["PTAB-10-5"] = { explosive = 2.5 }, --RBK_500AO, 96 bomblets, 0.5 kg TNT, expected to damage: infantry, light vehicles, light to medium armor
    ["OAB-2-5RT"] = { explosive = 1 }, --RBK_500U_OAB_2_5RT, 126 bomblets, 0.1 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["AO-1SCh"] = { explosive = 1 }, --RBK_250_275_AO_1SCH, 275 bomblets, 0.1 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["MM-06"] = { explosive = 1.5 }, --GB-6-SFW, variable bomblets, 0.3 kg TNT, expected to damage: infantry, light vehicles, light armor
    ["BETAB-M"] = { explosive = 5.0 }, --RBK_500U_BETAB_M, 25 bomblets, 0.76 kg TNT, expected to damage: medium armor, fortifications, concrete structures
    ["MJ1-MJ2"] = { explosive = 1 }, --BK90_MJ1_MJ2, 72 bomblets, 0.1 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["BLU-61"] = { explosive = 1 }, --CBU_52B, 72 bomblets, 0.12 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["BLG-66 AC"] = { explosive = 1 }, --BLG66, 49 bomblets, 0.1 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["PTAB-2-5"] = { explosive = 1 }, --KMGU_2_PTAB_2_5KO, 96 bomblets, 0.25 kg TNT, expected to damage: infantry, light vehicles, light armor
    ["AO-2.5RT"] = { explosive = 1 }, --BKF_AO2_5RT, 126 bomblets, 0.1 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["M77"] = { explosive = 1 }, --M26, 600 bomblets, 0.09 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["SD-2"] = { explosive = 1 }, --AB_250_2_SD_2, 140 bomblets, 0.06 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
    ["BLG-66 EG"] = { explosive = 1 }, --BLG66_EG, 49 bomblets, 0.1 kg TNT, expected to damage: infantry, unarmored vehicles, soft targets
}

--currently unused
unitTypeTable = {
    ["Infantry"] = { damageModifier = 1.0 }, -- Unarmored, highly vulnerable to explosives and napalm
    ["Tank"] = { damageModifier = 0.3 }, -- Heavy armor, resistant to most bomblets and napalm
    ["Artillery"] = { damageModifier = 0.5 }, -- Moderate armor, vulnerable to precise hits
    ["Armored Vehicle"] = { damageModifier = 0.4 }, -- Light to medium armor, moderately resistant
    ["Anti-Air"] = { damageModifier = 0.5 }, -- Light armor, exposed systems vulnerable
    ["Helicopter"] = { damageModifier = 0.6 }, -- Lightly armored, susceptible to fire and shrapnel
    ["Airplane"] = { damageModifier = 0.5 }, -- Grounded, moderate resilience but vulnerable to fire
    ["Structure"] = { damageModifier = 0.8 }, -- Varies, but often vulnerable to sustained damage (e.g., napalm, BETAB-M)
    ["Unarmored Vehicle"] = { damageModifier = 0.9 }, -- Soft-skinned, highly vulnerable to explosives
}

--Weapons tracked for tactical uses
tacticalwpn_tabl = {
    -- F22 AGM Nuke
    ["AGM_88G_N_ARM"] = { nuke = 50000 }, -- Anti-radiation nuke (nuke value unused currently)

	
}

local effectSmokeId = 1

----[[ ##### HELPER/UTILITY FUNCTIONS/TABLES ##### ]]----


--Global tables and value setting
local processedUnitIds = {}
local killfeedTable = {}
local killfeedByUnitId = {}
local splashKillfeedTable = {}
local splashKillfeedByUnitId = {}
local splashKillfeedTemp = {}
local splashKillfeedTempByUnitId = {}
local HitEventTempTable = {}
local CargoCookoffPendingTable = {}
local processedCookoffs = {}
local tacticalFuelTankSpawnQueue = {}

local lastSpawnTime = 0
local SPAWN_INTERVAL = 0.1 --0.1s gap between spawns

local recentExplosions = {}
local strobeUnits = {}
local individualStrobeUnits = {}
local processedSmoke = {}
local giantExplosionTargets = {}
local giantExplosionTestTargets = {}
local cargoEffectsQueue = {}
WpnHandler = {}
local tracked_target_position = nil --Store the last known position of TargetUnit for giant explosion
local tracked_weapons = {}
local processedUnitsGlobal = {}
local GUProcessedUnits = {}
local napalmCounter = 1

local cbuProcessed  = {} --Table to track processed unitID-weaponID pairs for cbus
local cbuParentUnits = {}
local PLAYER_REGISTRY_REFRESH_INTERVAL_SECONDS = 5
local PROCESSED_STATE_RETENTION_SECONDS = 1800
local PENDING_STATE_RETENTION_SECONDS = 300
local PROCESSED_STATE_PRUNE_INTERVAL_SECONDS = 300
local playerRegistryByName = {}
local playerRegistryByUnitId = {}
local playerRegistryBySlotName = {}
local playerRegistryLastRefresh = -math.huge

-- Helper function to dump table contents (for undocumented event fields)
local function dumpTable(t, indent)
    indent = indent or ""
    local result = ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            result = result .. indent .. k .. ": {\n" .. dumpTable(v, indent .. "  ") .. indent .. "}\n"
        else
            result = result .. indent .. k .. ": " .. tostring(v) .. "\n"
        end
    end
    return result
end

--Helper function to approximate Gaussian random (since math.randomGaussian isn't available)
local function gaussRandom(mean, stdDev)
    local u1, u2 = math.random(), math.random()
    local z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    return mean + stdDev * z
end


--Function to safely get data with pcall
local function safeGet(func, default)
    local success, result = pcall(func)
    return success and result or default
end

local function killfeedRetentionSeconds()
    return math.max(
        splash_damage_options.killfeed_splashdelay or 0,
        splash_damage_options.killfeed_game_message_duration or 0,
        15
    ) + 10
end

local function removeKillfeedEntryByUnitId(unitId)
    local entry = killfeedByUnitId[unitId]
    if not entry then
        return nil
    end

    killfeedByUnitId[unitId] = nil
    for i = #killfeedTable, 1, -1 do
        if killfeedTable[i].unitID == unitId then
            table.remove(killfeedTable, i)
            break
        end
    end

    return entry
end

local function addKillfeedEntry(entry)
    local existing = killfeedByUnitId[entry.unitID]
    if existing then
        return existing
    end

    table.insert(killfeedTable, entry)
    killfeedByUnitId[entry.unitID] = entry
    return entry
end

local function removeSplashKillEntryByUnitId(unitId)
    local entry = splashKillfeedByUnitId[unitId]
    if not entry then
        return nil
    end

    splashKillfeedByUnitId[unitId] = nil
    for i = #splashKillfeedTable, 1, -1 do
        if splashKillfeedTable[i].unitId == unitId then
            table.remove(splashKillfeedTable, i)
            break
        end
    end

    return entry
end

local function addSplashKillEntry(entry)
    local existing = splashKillfeedByUnitId[entry.unitId]
    if existing then
        return existing
    end

    table.insert(splashKillfeedTable, entry)
    splashKillfeedByUnitId[entry.unitId] = entry
    return entry
end

local function removeSplashKillTempEntryByUnitId(unitId)
    local entry = splashKillfeedTempByUnitId[unitId]
    if not entry then
        return nil
    end

    splashKillfeedTempByUnitId[unitId] = nil
    for i = #splashKillfeedTemp, 1, -1 do
        if splashKillfeedTemp[i].unitId == unitId then
            table.remove(splashKillfeedTemp, i)
            break
        end
    end

    return entry
end

local function pruneKillfeedEntries(currentTime)
    local retention = killfeedRetentionSeconds()
    for i = #killfeedTable, 1, -1 do
        local entry = killfeedTable[i]
        if currentTime - (entry.time or currentTime) > retention then
            killfeedByUnitId[entry.unitID] = nil
            table.remove(killfeedTable, i)
        end
    end
end

local function refreshPlayerRegistry(force)
    local currentTime = timer.getTime()
    if not force and currentTime - playerRegistryLastRefresh < PLAYER_REGISTRY_REFRESH_INTERVAL_SECONDS then
        return
    end

    playerRegistryByName = {}
    playerRegistryByUnitId = {}
    playerRegistryBySlotName = {}

    local playerList = net.get_player_list() or {}
    for _, pid in ipairs(playerList) do
        local pinfo = net.get_player_info(pid)
        if pinfo and pinfo.ucid and pinfo.name and pinfo.name ~= "" then
            local playerName = pinfo.name
            local slot = pinfo.slot
            local slotId = tonumber(slot)

            playerRegistryByName[playerName] = true
            if slotId then
                playerRegistryByUnitId[slotId] = playerName
            end
            if slot ~= nil and slot ~= "" then
                playerRegistryBySlotName[tostring(slot)] = playerName
            end
        end
    end

    playerRegistryLastRefresh = currentTime
end

local function getPlayerNameFromSlot(unitId, slotName)
    refreshPlayerRegistry()

    if unitId then
        local playerName = playerRegistryByUnitId[unitId]
        if playerName then
            return playerName
        end
    end

    if slotName then
        local playerName = playerRegistryBySlotName[tostring(slotName)]
        if playerName then
            return playerName
        end
    end

    return "Unknown"
end

local function resolvePlayerName(source)
    if not source then
        return "Unknown"
    end

    local playerName = source.getPlayerName and safeGet(function() return source:getPlayerName() end, nil) or nil
    if playerName and playerName ~= "" then
        return playerName
    end

    local unitId = source.getID and safeGet(function() return source:getID() end, nil) or nil
    local slotName = source.getName and safeGet(function() return source:getName() end, nil) or nil
    if not unitId and not slotName then
        return "Unknown"
    end

    return getPlayerNameFromSlot(unitId, slotName)
end

local function resolvePlayerNameWithLauncherFallback(source)
    local playerName = resolvePlayerName(source)
    if playerName ~= "Unknown" then
        return playerName
    end

    if source and source.getTypeName and safeGet(function() return source:getTypeName() end, nil) == "BLU-97/B" then
        local launcher = safeGet(function() return Weapon.getLauncher(source) end, nil)
        if launcher then
            return resolvePlayerName(launcher)
        end
    end

    return "Unknown"
end

local function isConnectedPlayerName(playerName)
    if not playerName or playerName == "" or playerName == "Unknown" or playerName == "unknown" then
        return false
    end

    refreshPlayerRegistry()
    return playerRegistryByName[playerName] == true
end

local function getFootholdRewardDataForObject(object)
    if not object then
        return nil, nil
    end

    local rewardData = safeGet(function()
        local points, _, statName = bc:objectToRewardPoints2(object)
        return {
            statName = statName,
            points = points
        }
    end, nil)

    if not rewardData then
        return nil, nil
    end

    return rewardData.statName, rewardData.points
end

local function addSplashKillTempEntry(entry, object)
    local unitId = entry and entry.unitId
    if not unitId then
        return false
    end

    if splashKillfeedTempByUnitId[unitId] or splashKillfeedByUnitId[unitId] then
        return false
    end

    if entry.statName == nil or entry.points == nil then
        return false
    end

    table.insert(splashKillfeedTemp, entry)
    splashKillfeedTempByUnitId[unitId] = entry
    return true
end

local function isFootholdRewardPlayer(playerName)
    return playerName and playerName ~= "Unknown" and bc.playerContributions[2][playerName] ~= nil
end

local function markProcessedUnitGlobal(unitId, entry)
    local currentTime = timer.getTime()
    if type(entry) == "table" then
        entry.id = entry.id or unitId
        entry.time = entry.time or currentTime
        processedUnitsGlobal[unitId] = entry
        return
    end

    processedUnitsGlobal[unitId] = {
        id = unitId,
        time = currentTime
    }
end

local function markProcessedCookoff(unitId)
    processedCookoffs[unitId] = timer.getTime()
end

local function prunePendingStateTable(pendingTable, currentTime)
    for unitId, entry in pairs(pendingTable) do
        local entryTime = type(entry) == "table" and entry.startTime or nil
        if entryTime and currentTime - entryTime > PENDING_STATE_RETENTION_SECONDS then
            pendingTable[unitId] = nil
        end
    end
end

local function pruneProcessedStateTables(_, currentTime)
    currentTime = currentTime or timer.getTime()

    for unitId, entry in pairs(processedUnitsGlobal) do
        local entryTime = type(entry) == "table" and entry.time or nil
        if not entryTime then
            processedUnitsGlobal[unitId] = { id = unitId, time = currentTime }
        elseif currentTime - entryTime > PROCESSED_STATE_RETENTION_SECONDS then
            processedUnitsGlobal[unitId] = nil
        end
    end

    for unitId, entry in pairs(GUProcessedUnits) do
        local entryTime = type(entry) == "table" and entry.time or nil
        if not entryTime then
            GUProcessedUnits[unitId] = { id = unitId, time = currentTime }
        elseif currentTime - entryTime > PROCESSED_STATE_RETENTION_SECONDS then
            GUProcessedUnits[unitId] = nil
        end
    end

    for unitId, entryTime in pairs(processedCookoffs) do
        if type(entryTime) ~= "number" then
            processedCookoffs[unitId] = currentTime
            entryTime = currentTime
        end
        if currentTime - entryTime > PROCESSED_STATE_RETENTION_SECONDS then
            processedCookoffs[unitId] = nil
        end
    end

    prunePendingStateTable(CargoCookoffPendingTable, currentTime)

    return currentTime + PROCESSED_STATE_PRUNE_INTERVAL_SECONDS
end

--Function to clear processed unit IDs after a delay
function clearProcessedUnitIds(unitId)
    if processedUnitIds[unitId] then
        processedUnitIds[unitId] = nil
        if splash_damage_options.napalm_unitdamage_debug then
            env.info("scanUnitsForNapalm: Cleared unit ID " .. unitId .. " from processedUnitIds")
        end
    end
end

--Debug functions
local function debugMsg(str)
    if splash_damage_options.debug == true then
        debugCounter = (debugCounter or 0) + 1
        local uniqueStr = str .. " [" .. timer.getTime() .. " - " .. debugCounter .. "]"
        trigger.action.outText(uniqueStr, 5)
        env.info("DEBUG: " .. uniqueStr)
    end
end


local function debugCargoCookOff(str)
    if splash_damage_options.cargocookoff_debug then
        cargocookoffdebugCounter = (cargocookoffdebugCounter or 0) + 1
        local uniqueStr = str .. " [" .. timer.getTime() .. " - " .. cargocookoffdebugCounter .. "]"
        --trigger.action.outText(uniqueStr, 5) --uncomment to show messages ingame too
        env.info("[CargoCookoff Debug:] " .. uniqueStr)
    end
end

local function debugCBUBombletHit(str)
    if splash_damage_options.CBU_Bomblet_Hit_debug then
        cbubombletdebugCounter = (cbubombletdebugCounter or 0) + 1
        local uniqueStr = str .. "[" .. timer.getTime() .. " - " .. cbubombletdebugCounter .. "]"
        env.info("[CBU Bomblet Hit Debug:] " .. uniqueStr)
    end
end

local function debugStrobeMarker(str)
    if splash_damage_options.StrobeMarker_debug then
        strobeMarkerDebugCounter = (strobeMarkerDebugCounter or 0) + 1
        local uniqueStr = str .. " [" .. timer.getTime() .. " - " .. strobeMarkerDebugCounter .. "]"
        env.info("[StrobeMarker Debug:] " .. uniqueStr)
    end
end

function napalm_phosphor(vec3)
    local baseFlareCount = math.random(0, 8) --Wider range for variation
    local randomFactor = math.random(0.1, 1) --Random scaling per call
    local scaledFlareCount = math.max(1, math.floor(baseFlareCount * splash_damage_options.napalm_phosphor_multiplier * randomFactor))
    for i = 1, scaledFlareCount do
        local randomAzimuth = math.random(0, 359) --Random angle for scatter
        local offsetX = math.random(-15, 15) --Position offset (meters)
        local offsetZ = math.random(-15, 15)
        local flarePos = { x = vec3.x + offsetX, y = vec3.y, z = vec3.z + offsetZ }
        trigger.action.signalFlare(flarePos, 2, randomAzimuth)
    end
    if splash_damage_options.debug then
        debugMsg("Triggered " .. scaledFlareCount .. " napalm phosphor flares at X: " .. string.format("%.0f", vec3.x) .. ", Z: " .. string.format("%.0f", vec3.z))
    end
end

--getSpreadPoints function
local function getSpreadPoints(impactPoint, velocity, numPoints, spacing)
    local points = {}
    local mag = math.sqrt(velocity.x^2 + velocity.z^2)
    if mag == 0 then
        table.insert(points, {x = impactPoint.x, y = land.getHeight({x = impactPoint.x, y = impactPoint.z}), z = impactPoint.z})
        return points
    end
    local dir = {x = velocity.x / mag, z = velocity.z / mag}
    local perpDir = {x = -dir.z, z = dir.x} --Perpendicular to velocity direction
    local prevHeight = land.getHeight({x = impactPoint.x, y = impactPoint.z})
    for i = 1, numPoints do
        local offset = (i - 1) * spacing
        if splash_damage_options.napalm_doublewide_enabled then
            --Double-wide: two points with ±15m lateral offset
            local point1 = {
                x = impactPoint.x + dir.x * offset + perpDir.x * splash_damage_options.napalm_doublewide_spread,
                z = impactPoint.z + dir.z * offset + perpDir.z * splash_damage_options.napalm_doublewide_spread
            }
            local terrainHeight1 = land.getHeight({x = point1.x, y = point1.z})
            local heightDiff1 = terrainHeight1 - prevHeight
            point1.y = prevHeight + math.max(math.min(heightDiff1, 30), -30)
            table.insert(points, point1)
            local point2 = {
                x = impactPoint.x + dir.x * offset - perpDir.x * splash_damage_options.napalm_doublewide_spread,
                z = impactPoint.z + dir.z * offset - perpDir.z * splash_damage_options.napalm_doublewide_spread
            }
            local terrainHeight2 = land.getHeight({x = point2.x, y = point2.z})
            local heightDiff2 = terrainHeight2 - prevHeight
            point2.y = prevHeight + math.max(math.min(heightDiff2, 30), -30)
            table.insert(points, point2)
            prevHeight = (terrainHeight1 + terrainHeight2) / 2
        else
            --Single point, linear spread
            local point = {
                x = impactPoint.x + dir.x * offset,
                z = impactPoint.z + dir.z * offset
            }
            local terrainHeight = land.getHeight({x = point.x, y = point.z})
            local heightDiff = terrainHeight - prevHeight
            point.y = prevHeight + math.max(math.min(heightDiff, 30), -30)
            table.insert(points, point)
            prevHeight = terrainHeight
        end
    end
    return points
end


function explodeNapalm(vec3)
    local explosionPos = {
        x = vec3.x,
        y = vec3.y + 1.6, --Add 1.6m to the ground height
        z = vec3.z
    }
    trigger.action.explosion(explosionPos, 10)
end
 
--Helper function to calculate 2D distance
local function getDistance(point1, point2)
    local dX = math.abs(point1.x - point2.x)
    local dZ = math.abs(point1.z - point2.z)
    return math.sqrt(dX * dX + dZ * dZ)
end

--Scan for units around the napalm explosions and apply damage if required
function scanUnitsForNapalm(posX, posY, posZ, playerName)
    if not splash_damage_options.napalm_unitdamage_enable then 
        if splash_damage_options.napalm_unitdamage_debug then
            env.info("scanUnitsForNapalm: Napalm unit damage disabled, skipping scan")
        end
        return 
    end
    
    if splash_damage_options.napalm_unitdamage_debug then
        env.info("scanUnitsForNapalm: Starting scan at (X: " .. posX .. ", Y: " .. posY .. ", Z: " .. posZ .. ") with radius " .. splash_damage_options.napalm_unitdamage_scandistance)
    end
    
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = {x = posX, y = posY, z = posZ},
            radius = splash_damage_options.napalm_unitdamage_scandistance
        }
    }
    
    local foundUnits = {}
    local status, err = pcall(function()
        --Scan for units
        world.searchObjects(Object.Category.UNIT, volS, function(foundObject)
            local success, result = pcall(function()
                if foundObject:isExist() and foundObject:getCategory() == Object.Category.UNIT then
                    local unitType = foundObject:getTypeName() or "Unknown"
                    --Exclude Fuel tank
                    if unitType ~= "Fuel tank" then
                        local unitPos = foundObject:getPoint()
                        local distance = getDistance({x = posX, y = posY, z = posZ}, unitPos)
                        if distance <= splash_damage_options.napalm_unitdamage_scandistance then
                            local category = "Unknown"
                            local desc = foundObject:getDesc()
                            if desc and foundObject:hasAttribute("Infantry") then
                                category = "Infantry"
                            elseif desc and foundObject:hasAttribute("Tanks") then
                                category = "Tank"
                            elseif desc and foundObject:hasAttribute("Artillery") then
                                category = "Artillery"
                            elseif desc and foundObject:hasAttribute("Armored vehicles") then
                                category = "Armored Vehicle"
                            elseif desc and foundObject:hasAttribute("AA") then
                                category = "Anti-Air"
                            elseif desc and foundObject:hasAttribute("Helicopters") then
                                category = "Helicopter"
                            elseif desc and foundObject:hasAttribute("Planes") then
                                category = "Airplane"
                            end
                            local statName, points = getFootholdRewardDataForObject(foundObject)
                            table.insert(foundUnits, {
                                unit = foundObject,
                                id = foundObject:getID(),
                                type = unitType,
                                distance = distance,
                                category = category,
                                position = unitPos,
                                statName = statName,
                                points = points
                            })
                        end
                    end
                end
            end)
            if not success and splash_damage_options.napalm_unitdamage_debug then
                env.info("scanUnitsForNapalm: Error processing unit ID " .. (foundObject:getID() or "unknown") .. ": " .. tostring(result))
            end
            return true
        end)
        --Scan for static objects
        world.searchObjects(Object.Category.STATIC, volS, function(foundObject)
            local success, result = pcall(function()
                if foundObject:isExist() and foundObject:getCategory() == Object.Category.STATIC then
                    local unitType = foundObject:getTypeName() or "Unknown"
                    --Exclude Fuel tank
                    if unitType ~= "Fuel tank" then
                        local unitPos = foundObject:getPoint()
                        local distance = getDistance({x = posX, y = posY, z = posZ}, unitPos)
                        if distance <= splash_damage_options.napalm_unitdamage_scandistance then
                            local statName, points = getFootholdRewardDataForObject(foundObject)
                            table.insert(foundUnits, {
                                unit = foundObject,
                                id = foundObject:getID(),
                                type = unitType,
                                distance = distance,
                                category = "Structure",
                                position = unitPos,
                                statName = statName,
                                points = points
                            })
                        end
                    end
                end
            end)
            if not success and splash_damage_options.napalm_unitdamage_debug then
                env.info("scanUnitsForNapalm: Error processing static object ID " .. (foundObject:getID() or "unknown") .. ": " .. tostring(result))
            end
            return true
        end)
    end)
    
    if not status and splash_damage_options.napalm_unitdamage_debug then
        env.info("scanUnitsForNapalm: Error during scan: " .. tostring(err))
        return
    end
    
    table.sort(foundUnits, function(a, b) return a.distance < b.distance end)
    
    if splash_damage_options.napalm_unitdamage_debug then
        env.info("scanUnitsForNapalm: Scan completed, found " .. #foundUnits .. " objects within " .. splash_damage_options.napalm_unitdamage_scandistance .. " meters at position (X: " .. posX .. ", Y: " .. posY .. ", Z: " .. posZ .. ")")
        --Log all found objects
        for _, unitData in ipairs(foundUnits) do
            env.info("scanUnitsForNapalm: Found object ID " .. tostring(unitData.id) .. " of type: " .. unitData.type .. ", Category: " .. unitData.category .. ", Distance: " .. string.format("%.2f", unitData.distance) .. " meters, Position: (X: " .. string.format("%.2f", unitData.position.x) .. ", Y: " .. string.format("%.2f", unitData.position.y) .. ", Z: " .. string.format("%.2f", unitData.position.z) .. ")")
        end
    end
    
    if #foundUnits > 0 then
        local processedPositions = {} --Track processed coordinates for this scan
        local explosionIndex = 0
        for _, unitData in ipairs(foundUnits) do
            if napalm_unitcat_tabl[unitData.category] and unitData.distance <= napalm_unitcat_tabl[unitData.category].maxDamageDistance then
                --Check if unit ID has already been processed
                if not processedUnitIds[unitData.id] then
                    --Check for duplicate position (within 1 meter)
                    local posKey = string.format("%.0f_%.0f_%.0f", unitData.position.x, unitData.position.y, unitData.position.z)
                    if not processedPositions[posKey] then
                        --Check if unit is still alive (for units) or exists (for statics)
                        local isAlive = unitData.unit:isExist() and (unitData.category == "Structure" or unitData.unit:getLife() > 0)
                        if isAlive then
                            processedPositions[posKey] = true
                            processedUnitIds[unitData.id] = true
                            local power = napalm_unitcat_tabl[unitData.category].explosionPower
                            --Calculate delay
                            local delay = splash_damage_options.napalm_unitdamage_startdelay
                            if splash_damage_options.napalm_unitdamage_startdelay > 0 then
                                delay = delay + (explosionIndex * splash_damage_options.napalm_unitdamage_spreaddelay)
                                explosionIndex = explosionIndex + 1
                            end
                            --Adjust position for infantry to reduce ground interaction
                            local explosionPos = unitData.position
                            if unitData.category == "Infantry" then
                                explosionPos = {
                                    x = unitData.position.x,
                                    y = land.getHeight({x = unitData.position.x, y = unitData.position.z}) + 1.6,
                                    z = unitData.position.z
                                }
                            end
                            if splash_damage_options.napalm_unitdamage_debug then
                                env.info("scanUnitsForNapalm: Scheduling explosion on unit ID " .. tostring(unitData.id) .. " (" .. unitData.type .. ") at (X: " .. string.format("%.2f", explosionPos.x) .. ", Z: " .. string.format("%.2f", explosionPos.z) .. ") with power " .. power .. " after " .. string.format("%.2f", delay) .. "s")
                            end
                            --Record potential kills for kill feed
                            if splash_damage_options.killfeed_enable then
                                timer.scheduleFunction(function(params)
                                    local unit = params.unit
                                    local playerName = params.playerName or "unknown"
                                    local weaponName = params.weaponName or "Napalm"
                                    if splash_damage_options.napalm_unitdamage_debug then
                                        env.info("scanUnitsForNapalm: Checking killfeed for unit ID " .. tostring(params.unitId) .. " (" .. params.unitType .. "), player: " .. playerName .. ", exists: " .. tostring(unit:isExist()) .. ", life: " .. (unit:isExist() and unit:getLife() or "N/A"))
                                    end
                                    if not unit:isExist() or (unit:isExist() and unit:getLife() <= 0) then
                                        if splashKillfeedByUnitId[params.unitId] and splash_damage_options.napalm_unitdamage_debug then
                                            env.info("scanUnitsForNapalm: Unit ID " .. tostring(params.unitId) .. " already in splashKillfeedTable, skipping")
                                        end
                                        if isConnectedPlayerName(playerName) then
                                            local added = addSplashKillTempEntry({
                                                    playerName = playerName,
                                                    weaponName = weaponName,
                                                    unitName = params.unitName,
                                                    unitType = params.unitType,
                                                    unitId = params.unitId,
                                                    time = timer.getTime(),
                                                    position = params.position,
                                                    statName = params.statName,
                                                    points = params.points
                                                }, unit)
                                            if splash_damage_options.napalm_unitdamage_debug then
                                                env.info("scanUnitsForNapalm: Player validation for " .. playerName .. ": isPlayer=true, added=" .. tostring(added))
                                            end
                                            if added then
                                                if splash_damage_options.napalm_unitdamage_debug then
                                                    env.info("scanUnitsForNapalm: Added to splashKillfeedTemp: unit ID " .. tostring(params.unitId) .. " (" .. params.unitType .. ") destroyed by " .. playerName .. ", temp table size: " .. #splashKillfeedTemp)
                                                end
                                                if splash_damage_options.killfeed_game_messages then
                                                    local msg = string.format("%s destroyed by %s's %s", params.unitType, playerName, weaponName)
                                                    trigger.action.outTextForCoalition(2, msg, splash_damage_options.killfeed_game_message_duration)
                                                    if splash_damage_options.napalm_unitdamage_debug then
                                                        env.info("scanUnitsForNapalm: Displayed killfeed message for unit ID " .. tostring(params.unitId))
                                                    end
                                                end
                                            end
                                        elseif splash_damage_options.napalm_unitdamage_debug then
                                            env.info("scanUnitsForNapalm: Player validation for " .. playerName .. ": isPlayer=false")
                                        end
                                    else
                                        if splash_damage_options.napalm_unitdamage_debug then
                                            env.info("scanUnitsForNapalm: Skipped killfeed for unit ID " .. tostring(params.unitId) .. " (" .. params.unitType .. "), exists: " .. tostring(unit:isExist()) .. ", life: " .. (unit:isExist() and unit:getLife() or "N/A"))
                                        end
                                    end
                                    if splash_damage_options.napalm_unitdamage_debug then
                                        env.info("scanUnitsForNapalm: Scheduling splashKillFeed for unit ID " .. tostring(params.unitId) .. " at time " .. timer.getTime())
                                    end
                                    timer.scheduleFunction(splashKillFeed, {}, timer.getTime() + splash_damage_options.killfeed_splashdelay)
                                end, {
                                    unit = unitData.unit,
                                    playerName = playerName,
                                    weaponName = "Napalm",
                                    unitName = unitData.unit:getName() or "unknown",
                                    unitType = unitData.type,
                                    unitId = unitData.id,
                                    position = explosionPos,
                                    statName = unitData.statName,
                                    points = unitData.points
                                }, timer.getTime() + delay + 1) -- Increased to 2 seconds
                            end
                            timer.scheduleFunction(function(params)
                                trigger.action.explosion(params.position, params.power)
                            end, {position = explosionPos, power = power}, timer.getTime() + delay)
                            --Schedule cleanup for this unit ID 20 seconds after its explosion
                            timer.scheduleFunction(clearProcessedUnitIds, unitData.id, timer.getTime() + delay + 20)
                        elseif splash_damage_options.napalm_unitdamage_debug then
                            env.info("scanUnitsForNapalm: Skipped explosion for unit ID " .. tostring(unitData.id) .. " (" .. unitData.type .. ") at (X: " .. string.format("%.2f", unitData.position.x) .. ", Z: " .. string.format("%.2f", unitData.position.z) .. ") because unit is not alive (isExist: " .. tostring(unitData.unit:isExist()) .. ", life: " .. (unitData.category == "Structure" and "N/A" or tostring(unitData.unit:getLife())) .. ")")
                        end
                    elseif splash_damage_options.napalm_unitdamage_debug then
                        env.info("scanUnitsForNapalm: Skipped explosion for unit ID " .. tostring(unitData.id) .. " (" .. unitData.type .. ") at (X: " .. string.format("%.2f", unitData.position.x) .. ", Z: " .. string.format("%.2f", unitData.position.z) .. ") due to duplicate position")
                    end
                elseif splash_damage_options.napalm_unitdamage_debug then
                    env.info("scanUnitsForNapalm: Skipped explosion for unit ID " .. tostring(unitData.id) .. " (" .. unitData.type .. ") at (X: " .. string.format("%.2f", unitData.position.x) .. ", Z: " .. string.format("%.2f", unitData.position.z) .. ") due to already processed unit ID")
                end
            end
        end
    else
        if splash_damage_options.napalm_unitdamage_debug then
            env.info("scanUnitsForNapalm: No objects found in scan area")
        end
    end
end


function removeNapalm(staticName) 
    StaticObject.getByName(staticName):destroy()
end

local function tableHasKey(table, key)
    return table[key] ~= nil
end

  
local function gameMsg(str)
    if splash_damage_options.game_messages == true then
        trigger.action.outText(str, 5)
    end
end
  
local function getDistance(point1, point2)
    local x1 = point1.x
    local y1 = point1.y
    local z1 = point1.z
    local x2 = point2.x
    local y2 = point2.y
    local z2 = point2.z
    local dX = math.abs(x1 - x2)
    local dZ = math.abs(z1 - z2)
    local distance = math.sqrt(dX * dX + dZ * dZ)
    return distance
end
  
local function getDistance3D(point1, point2)
    local x1 = point1.x
    local y1 = point1.y
    local z1 = point1.z
    local x2 = point2.x
    local y2 = point2.y
    local z2 = point2.z
    local dX = math.abs(x1 - x2)
    local dY = math.abs(y1 - y2)
    local dZ = math.abs(z1 - z2)
    local distance = math.sqrt(dX * dX + dZ * dZ + dY * dY)
    return distance
end
  
local function vec3Mag(speedVec)
    return math.sqrt(speedVec.x^2 + speedVec.y^2 + speedVec.z^2)
end
  
local function lookahead(speedVec)
    local speed = vec3Mag(speedVec)
    local dist = speed * refreshRate * 1.5 
    return dist
end

function napalmOnImpact(impactPoint, velocity, weaponName, playerName)
    if not (splash_damage_options.napalmoverride_enabled or (splash_damage_options.napalm_mk77_enabled and (weaponName == "MK77mod0-WPN" or weaponName == "MK77mod1-WPN"))) then return end
    --For MK77 cluster munitions, snap impact point to ground
    local finalImpactPoint = impactPoint
    if splash_damage_options.napalm_mk77_enabled and (weaponName == "MK77mod0-WPN" or weaponName == "MK77mod1-WPN") then
        local groundHeight = land.getHeight({x = impactPoint.x, y = impactPoint.z})
                    finalImpactPoint = {
            x = impactPoint.x,
            y = groundHeight,
            z = impactPoint.z
                    }
                    if splash_damage_options.debug then
            debugMsg("Snapped MK77 " .. weaponName .. " impact to ground at X: " .. string.format("%.0f", finalImpactPoint.x) .. ", Z: " .. string.format("%.0f", finalImpactPoint.z))
        end
    else
        --For non-MK77, skip if more than 50m above ground
        local groundHeight = land.getHeight({x = impactPoint.x, y = impactPoint.z})
        if impactPoint.y - groundHeight > 50 then return end --Skip if more than 50m above ground
    end

    --Adjust spread points for MK77mod0-WPN (30% more)
    local spreadPointsCount = splash_damage_options.napalm_spread_points
    if weaponName == "MK77mod0-WPN" then
        spreadPointsCount = math.floor(spreadPointsCount * 1.3 + 0.5) --30% more, rounded
    end

    --Use horizontal velocity for MK77, full velocity for others
    local spreadVelocity = velocity
    if weaponName == "MK77mod0-WPN" or weaponName == "MK77mod1-WPN" then
        spreadVelocity = {x = velocity.x, z = velocity.z}
    end
    local spreadPoints = getSpreadPoints(finalImpactPoint, spreadVelocity, spreadPointsCount, splash_damage_options.napalm_spread_spacing)
    if splash_damage_options.debug then
        debugMsg("Generated " .. #spreadPoints .. " spread points for " .. weaponName .. " (expected " .. (splash_damage_options.napalm_doublewide_enabled and spreadPointsCount * 2 or spreadPointsCount) .. ")")
        for i, point in ipairs(spreadPoints) do
            debugMsg("Point " .. i .. ": X: " .. string.format("%.0f", point.x) .. ", Y: " .. string.format("%.0f", point.y) .. ", Z: " .. string.format("%.0f", point.z))
        end
    end
    local flamePositions = {} --Track flame coordinates to avoid duplicates
    if splash_damage_options.debug then
        debugMsg("napalmOnImpact: Using playerName: " .. tostring(playerName) .. " for weapon: " .. weaponName)
    end
    local function spawnAndExplode(pairIndex)
        if pairIndex > spreadPointsCount then return end
        local pointsToProcess = {}
        if splash_damage_options.napalm_doublewide_enabled then
            --Process two points (pair) at indices 2*pairIndex-1 and 2*pairIndex
            local idx1 = 2 * pairIndex - 1
            local idx2 = 2 * pairIndex
            if idx1 <= #spreadPoints then
                table.insert(pointsToProcess, spreadPoints[idx1])
            end
            if idx2 <= #spreadPoints then
                table.insert(pointsToProcess, spreadPoints[idx2])
            end
        else
            --Process single point at pairIndex
            if pairIndex <= #spreadPoints then
                table.insert(pointsToProcess, spreadPoints[pairIndex])
            end
        end
        for _, point in ipairs(pointsToProcess) do
        local napalmName = "napalmImpact" .. napalmCounter
        local currentCounter = napalmCounter
        napalmCounter = napalmCounter + 1
        local owngroupID = math.random(9999, 99999)
        local cvnunitID = math.random(9999, 99999)
        local _dataFuel = {
            ["groupId"] = owngroupID,
            ["category"] = "Fortifications",
            ["shape_name"] = "toplivo-bak",
            ["type"] = "Fuel tank",
            ["unitId"] = cvnunitID,
            ["rate"] = 100,
            ["y"] = point.z,
            ["x"] = point.x,
            ["name"] = napalmName,
            ["heading"] = 0,
            ["dead"] = false,
            ["hidden"] = true,
        }
        if splash_damage_options.debug then
            local staticCount = 0
            for _, coalitionId in pairs(coalition.side) do
                local statics = coalition.getStaticObjects(coalitionId)
                staticCount = staticCount + #statics
            end
            debugMsg("Spawning napalm object '" .. napalmName .. "' (Counter: " .. currentCounter .. ") at X: " .. string.format("%.0f", point.x) .. ", Y: " .. string.format("%.0f", point.y) .. ", Z: " .. string.format("%.0f", point.z) .. " (Active static objects: " .. staticCount .. ")")
        end
        local status, result = pcall(function()
            return coalition.addStaticObject(coalition.side.BLUE, _dataFuel)
        end)
        local spawnSuccess = status and result and StaticObject.getByName(napalmName) and StaticObject.getByName(napalmName):isExist()
            if not spawnSuccess then
                if splash_damage_options.debug then
                    debugMsg("Failed to spawn napalm object '" .. napalmName .. "' at X: " .. string.format("%.0f", point.x) .. ", Y: " .. string.format("%.0f", point.y) .. ", Z: " .. string.format("%.0f", point.z) .. ": " .. (status and "Object not found or does not exist" or tostring(result)))
                end
            else
                timer.scheduleFunction(explodeNapalm, point, timer.getTime() + splash_damage_options.napalm_explode_delay)
        timer.scheduleFunction(function(name)
            if splash_damage_options.debug then
                debugMsg("Destroying napalm object '" .. name .. "' at X: " .. string.format("%.0f", point.x) .. ", Z: " .. string.format("%.0f", point.z))
            end
            removeNapalm(name)
        end, napalmName, timer.getTime() + splash_damage_options.napalm_destroy_delay)
            end
            if splash_damage_options.napalm_phosphor_enabled then
            timer.scheduleFunction(napalm_phosphor, point, timer.getTime() + splash_damage_options.napalm_explode_delay)
            scanUnitsForNapalm(point.x, point.y, point.z, playerName) -- New: Pass playerName
        end
        --Add flame effect if enabled
        if splash_damage_options.napalm_addflame then
            local flameSize = splash_damage_options.napalm_addflame_size
            local flameDuration = splash_damage_options.napalm_addflame_duration
            local flameDensity = 1.0
            local effectId = effectSmokeId
            effectSmokeId = effectSmokeId + 1
            local isDuplicate = false
            for _, pos in pairs(flamePositions) do
                if getDistance3D(point, pos) < 3 then
                    isDuplicate = true
                    if splash_damage_options.debug then
                        debugMsg("Skipping duplicate flame for napalm object '" .. napalmName .. "' near X: " .. string.format("%.0f", pos.x) .. ", Z: " .. string.format("%.0f", pos.z))
                    end
                    break
                end
            end
            if not isDuplicate then
                if splash_damage_options.debug then
                    debugMsg("Adding flame effect for napalm object '" .. napalmName .. "' at X: " .. string.format("%.0f", point.x) .. ", Z: " .. string.format("%.0f", point.z) .. " (Size: " .. flameSize .. ", Duration: " .. flameDuration .. "s, ID: " .. effectId .. ")")
                end
                timer.scheduleFunction(function(params)
                    local terrainHeight = land.getHeight({x = params[1].x, y = params[1].z})
                    local adjustedCoords = {x = params[1].x, y = terrainHeight + 2, z = params[1].z}
                    trigger.action.effectSmokeBig(adjustedCoords, params[2], params[3], params[4])
                end, {point, flameSize, flameDensity, effectId}, timer.getTime() + splash_damage_options.napalm_flame_delay)
                timer.scheduleFunction(function(id)
                    if splash_damage_options.debug then
                        debugMsg("Stopping flame effect for napalm object (ID: " .. id .. ")")
                    end
                    trigger.action.effectSmokeStop(id)
                end, effectId, timer.getTime() + splash_damage_options.napalm_flame_delay + flameDuration)
                table.insert(flamePositions, point)
            end
        end
        end
        timer.scheduleFunction(spawnAndExplode, pairIndex + 1, timer.getTime() + 0.2)
    end
    spawnAndExplode(1)
end


local function normalizeVector(vec)
    local mag = math.sqrt(vec.x^2 + vec.z^2)
    if mag > 0 then
        return { x = vec.x / mag, z = vec.z / mag }
    else
        return { x = 1, z = 0 }
    end
end

local function calculate_drop_angle(velocity)
    local horizontal_speed = math.sqrt((velocity.x or 0)^2 + (velocity.z or 0)^2)
    local vertical_speed = math.abs(velocity.y or 0)
    if horizontal_speed == 0 then return 90 end
    local angle_rad = math.atan(vertical_speed / horizontal_speed)
    return math.deg(angle_rad)
end

local function calculate_dispersion(velocity, burst_altitude)
    local velocity_magnitude = math.sqrt((velocity.x or 0)^2 + (velocity.z or 0)^2)
    local drop_angle = calculate_drop_angle(velocity)
    local length = splash_damage_options.cluster_base_length * (1 + velocity_magnitude / 200)
    local width = splash_damage_options.cluster_base_width * (1 + burst_altitude / 6000)
    local length_jitter = length * (0.85 + math.random() * 0.3)
    local width_jitter = width * (0.85 + math.random() * 0.3)
    return math.max(splash_damage_options.cluster_min_length, math.min(splash_damage_options.cluster_max_length, length_jitter)),
           math.max(splash_damage_options.cluster_min_width, math.min(splash_damage_options.cluster_max_width, width_jitter))
end

--[[
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-
    ##### End of HELPER/UTILITY FUNCTIONS #####     ##### End of HELPER/UTILITY FUNCTIONS #####     ##### End of HELPER/UTILITY FUNCTIONS #####
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-]]

--Function to trigger tactical explosion
function TacticalExplosionTrigger(coords)
    if not splash_damage_options.tactical_explosion then
        if splash_damage_options.debug then
            env.info("TacticalExplosionTrigger: Disabled, skipping explosion at X: " .. (coords.x or "nil") .. ", Y: " .. (coords.y or "nil") .. ", Z: " .. (coords.z or "nil"))
        end
        return
    end
    if not coords or not coords.x or not coords.y or not coords.z then
        if splash_damage_options.debug then
            env.info("TacticalExplosionTrigger: Invalid coordinates, skipping explosion")
        end
        return
    end
    
    --Check height above ground
    local groundHeight = land.getHeight({x = coords.x, y = coords.z})
    local heightAboveGround = coords.y - groundHeight
    if heightAboveGround > splash_damage_options.tactical_explosion_max_height then
        if splash_damage_options.debug then
            env.info("TacticalExplosionTrigger: Explosion at height " .. heightAboveGround .. "m exceeds max height " .. splash_damage_options.tactical_explosion_max_height .. "m, skipping")
        end
        return
    end
    
    local scaling = splash_damage_options.tactical_explosion_scaling or 1
    if splash_damage_options.debug then
        env.info("TacticalExplosionTrigger: Processing at X: " .. coords.x .. ", Y: " .. coords.y .. ", Z: " .. coords.z .. " with " .. splash_damage_options.tactical_explosion_explosion_count_max .. " max explosions, central power: " .. (splash_damage_options.tactical_explosion_central_power * scaling) .. ", fuel tank spawn: " .. tostring(splash_damage_options.tactical_explosion_fueltankspawn) .. ", scaling: " .. scaling)
    end

    --Prepare fuel tank data if spawning is enabled
    local tacName = "TAC_FuelTank_" .. tostring(timer.getTime())
    if splash_damage_options.tactical_explosion_fueltankspawn then
        table.insert(tacticalFuelTankSpawnQueue, {coords = coords, tacName = tacName})
        if #tacticalFuelTankSpawnQueue == 1 then
            tacticalExplosionProcessSpawnQueue()
        end
    end

    --Generate explosion points
    local explosionPoints = {}
    local baseMinCount = splash_damage_options.tactical_explosion_explosion_count_min
    local baseMaxCount = splash_damage_options.tactical_explosion_explosion_count_max
    local explosionCount = math.random(math.floor(baseMinCount * scaling), math.floor(baseMaxCount * scaling))
    if explosionCount > 0 then
        --Central explosion
        local centralPoint = {
            x = coords.x,
            y = land.getHeight({x = coords.x, y = coords.z}) + 2,
            z = coords.z
        }
        table.insert(explosionPoints, {point = centralPoint, power = splash_damage_options.tactical_explosion_central_power * scaling, delay = 0.01})
        --Secondary explosions with Gaussian distribution
        for i = 1, explosionCount do
            local offsetX = gaussRandom(0, (splash_damage_options.tactical_explosion_radius * scaling) / 3) * (1 + (math.random() - 0.5) * 0.1)
            local offsetZ = gaussRandom(0, (splash_damage_options.tactical_explosion_radius * scaling) / 3) * (1 + (math.random() - 0.5) * 0.1)
            local point = {
                x = coords.x + offsetX,
                y = land.getHeight({x = coords.x + offsetX, y = coords.z + offsetZ}) + 1.3,
                z = coords.z + offsetZ
            }
            local basePower = splash_damage_options.tactical_explosion_explosion_power
            local power = (basePower * scaling)
            local delay = math.random() * splash_damage_options.tactical_explosion_explosion_delay_max
            table.insert(explosionPoints, {point = point, power = power, delay = delay})
        end
    end

    --Trigger explosions
    if #explosionPoints > 0 then
        if splash_damage_options.debug then
            env.info("TacticalExplosionTrigger: Scheduling " .. #explosionPoints .. " explosions")
        end
        for i, entry in ipairs(explosionPoints) do
            if splash_damage_options.debug then
                env.info("TacticalExplosionTrigger: Scheduling explosion #" .. i .. " at X: " .. entry.point.x .. ", Y: " .. entry.point.y .. ", Z: " .. entry.point.z .. " with power " .. entry.power .. " and delay " .. entry.delay)
            end
            timer.scheduleFunction(function(params)
                if splash_damage_options.debug then
                    env.info("TacticalExplosionTrigger: Triggering explosion #" .. params[3] .. " at X: " .. params[1].x .. ", Y: " .. params[1].y .. ", Z: " .. params[1].z .. " with power " .. params[2])
                end
                trigger.action.explosion(params[1], params[2])
            end, {entry.point, entry.power, i}, timer.getTime() + entry.delay)
        end
    end

    --Trigger blastWave for central explosion
    local centralPoint = {
        x = coords.x,
        y = land.getHeight({x = coords.x, y = coords.z}) + 0.5,
        z = coords.z
    }
    local dynamicRadius = math.pow(splash_damage_options.tactical_explosion_central_power * scaling, 1/3) * 5 * splash_damage_options.dynamic_blast_radius_modifier
    if splash_damage_options.debug then
        env.info("TacticalExplosionTrigger: Triggering blastWave at X: " .. centralPoint.x .. ", Y: " .. centralPoint.y .. ", Z: " .. centralPoint.z .. " with power " .. (splash_damage_options.tactical_explosion_central_power * scaling) .. " and dynamic radius " .. dynamicRadius)
    end
    timer.scheduleFunction(function(params)
        blastWave(params[1], params[2], params[3], params[4], params[5])
    end, {centralPoint, dynamicRadius, "TacticalExplosion", splash_damage_options.tactical_explosion_central_power * scaling, false}, timer.getTime() + 0.4)
end

--Function to process the spawn queue for tactical explosion fuel tanks
function tacticalExplosionProcessSpawnQueue()
    if #tacticalFuelTankSpawnQueue == 0 then return end

    local currentTime = timer.getTime()
    if currentTime < lastSpawnTime + SPAWN_INTERVAL then
        timer.scheduleFunction(tacticalExplosionProcessSpawnQueue, {}, currentTime + SPAWN_INTERVAL / 2)
        return
    end

    local task = table.remove(tacticalFuelTankSpawnQueue, 1)
    lastSpawnTime = currentTime

    local coords, tacName = task.coords, task.tacName
    if splash_damage_options.debug then
        env.info("TacticalExplosionTrigger: Spawning fuel tank at X: " .. coords.x .. ", Y: " .. coords.y .. ", Z: " .. coords.z)
    end

    local owngroupID = math.random(9999, 99999)
    local cvnunitID = math.random(9999, 99999)
    local _dataFuel = {
        ["groupId"] = owngroupID,
        ["category"] = "Fortifications",
        ["shape_name"] = "toplivo-bak",
        ["type"] = "Fuel tank",
        ["unitId"] = cvnunitID,
        ["rate"] = 100,
        ["y"] = coords.z,
        ["x"] = coords.x,
        ["name"] = tacName,
        ["heading"] = 0,
        ["dead"] = false,
        ["hidden"] = true,
    }

    --Attempt to spawn at original coordinates
    _dataFuel.y = coords.z
    _dataFuel.x = coords.x
    local spawnY = land.getHeight({x = coords.x, y = coords.z}) + 0.5
    _dataFuel.position = {x = coords.x, y = spawnY, z = coords.z}
    local status, result = pcall(function()
        return coalition.addStaticObject(coalition.side.BLUE, _dataFuel)
    end)
    local spawnSuccess = status and result and StaticObject.getByName(tacName) and StaticObject.getByName(tacName):isExist()

    if splash_damage_options.debug then
        env.info("TacticalExplosionTrigger: Fuel tank spawn attempt at original coords - " .. (spawnSuccess and "succeeded" or "failed"))
    end

    --Try offset positions if spawn fails
    if not spawnSuccess then
        if splash_damage_options.debug then
            env.info("TacticalExplosionTrigger: Failed to spawn fuel tank at original coords, attempting 1m offsets")
        end
        local offsets = {
            {x = coords.x + 1, z = coords.z},
            {x = coords.x - 1, z = coords.z},
            {x = coords.x, z = coords.z + 1},
            {x = coords.x, z = coords.z - 1}
        }
        for i, offset in ipairs(offsets) do
            _dataFuel.x = offset.x
            _dataFuel.y = offset.z
            _dataFuel.position = {x = offset.x, y = land.getHeight({x = offset.x, y = offset.z}) + 0.5, z = offset.z}
            _dataFuel.name = tacName .. "_offset" .. i
            status, result = pcall(function()
                return coalition.addStaticObject(coalition.side.BLUE, _dataFuel)
            end)
            spawnSuccess = status and result and StaticObject.getByName(_dataFuel.name) and StaticObject.getByName(_dataFuel.name):isExist()
            if spawnSuccess then
                coords.x = offset.x
                coords.z = offset.z
                tacName = _dataFuel.name
                if splash_damage_options.debug then
                    env.info("TacticalExplosionTrigger: Successfully spawned fuel tank at offset #" .. i .. " (X: " .. coords.x .. ", Y: " .. coords.y .. ", Z: " .. coords.z .. ")")
                end
                break
            end
        end
    end

    if not spawnSuccess and splash_damage_options.debug then
        env.info("TacticalExplosionTrigger: Failed to spawn fuel tank after all attempts")
    end

    --Schedule destruction
    if spawnSuccess then
        timer.scheduleFunction(function(name)
            if splash_damage_options.debug then
                env.info("TacticalExplosionTrigger: Attempting to destroy fuel tank " .. name)
            end
            local staticObj = StaticObject.getByName(name)
            if staticObj then
                local status, err = pcall(function()
                    staticObj:destroy()
                end)
                if splash_damage_options.debug then
                    env.info("TacticalExplosionTrigger: Fuel tank " .. name .. " destruction - " .. (status and "succeeded" or "failed: " .. tostring(err)))
                end
            else
                if splash_damage_options.debug then
                    env.info("TacticalExplosionTrigger: Fuel tank " .. name .. " not found for destruction")
                end
            end
        end, tacName, timer.getTime() + 0.5)
    end

    --Schedule next spawn if queue is not empty
    if #tacticalFuelTankSpawnQueue > 0 then
        timer.scheduleFunction(tacticalExplosionProcessSpawnQueue, {}, timer.getTime() + SPAWN_INTERVAL)
    end
end

--Function to trigger smoke effect with specified size and duration
local function triggerSmokeEffect(coords, flameSize, duration, effectId)
    local terrainHeight = land.getHeight({x = coords.x, y = coords.z})
    local adjustedCoords = {x = coords.x, y = terrainHeight + 2, z = coords.z}
    debugCargoCookOff("Spawning smoke effect at X: " .. adjustedCoords.x .. ", Z: " .. adjustedCoords.z .. " with size " .. flameSize .. " (ID: " .. effectId .. ")")
    trigger.action.effectSmokeBig(adjustedCoords, flameSize, 1, effectId)
    timer.scheduleFunction(function(id)
        debugCargoCookOff("Stopping smoke effect (ID: " .. id .. ")")
        trigger.action.effectSmokeStop(id)
    end, effectId, timer.getTime() + duration)
end

--Schedule advanced sequence cargo effects
local function scheduleAdvancedEffectSequence(unitID, coords, effectData, fromDeadEvent)
    local function triggerEffects(pos)
        processedSmoke[unitID] = true --Ensure unit is marked as processed
        local effectOrder = splash_damage_options.allunits_advanced_effect_order
        local effectTiming = splash_damage_options.allunits_advanced_effect_timing
        local cumulativeTime = 0
        effectSmokeId = effectSmokeId or 1 --Use global effectSmokeId, initialize if nil

        --Helper function to get current unit position
        local function getUnitPosition()
            local entry = CargoCookoffPendingTable[unitID]
            if entry and entry.unit then
                local success, newPos = pcall(function() return entry.unit:getPosition().p end)
                if success and newPos then
                    entry.coords = newPos
                    return newPos
                end
            end
            return pos
        end

        --Trigger initial explosion at 1.6m off the ground
        timer.scheduleFunction(function(params)
            local currentPos = getUnitPosition()
            local explosionCoords = {x = currentPos.x, y = land.getHeight({x = currentPos.x, y = currentPos.z}) + 1.6, z = currentPos.z}
            debugCargoCookOff("Executing initial explosion for unit ID " .. tostring(params.unitID or "nil") .. " at X: " .. explosionCoords.x .. ", Y: " .. explosionCoords.y .. ", Z: " .. explosionCoords.z)
            trigger.action.explosion(explosionCoords, params.power)
        end, {power = splash_damage_options.allunits_advanced_effect_explode_power, unitID = unitID}, timer.getTime() + 0.1)

        --Spawn first smoke effect immediately
        if #effectOrder > 0 then
            local flameSize = tonumber(effectOrder[1])
            local duration = tonumber(effectTiming[1]) or 99999999
            local effectId = effectSmokeId
            effectSmokeId = effectSmokeId + 1
            local smokeCoords = {x = pos.x, y = land.getHeight({x = pos.x, y = pos.z}) + 2, z = pos.z}
            debugCargoCookOff("Spawning immediate smoke effect for unit ID " .. tostring(unitID) .. " at X: " .. smokeCoords.x .. ", Y: " .. smokeCoords.y .. ", Z: " .. smokeCoords.z .. " with size " .. flameSize .. " (ID: " .. effectId .. ")")
            trigger.action.effectSmokeBig(smokeCoords, flameSize, 0.9, effectId)
            timer.scheduleFunction(function(id)
                debugCargoCookOff("Stopping smoke effect (ID: " .. id .. ")")
                trigger.action.effectSmokeStop(id)
            end, effectId, timer.getTime() + duration)
            cumulativeTime = cumulativeTime + duration
        end

        --Schedule remaining smoke effects
        for i = 2, #effectOrder do
            local duration = tonumber(effectTiming[i]) or 99999999
            local effectId = effectSmokeId
            effectSmokeId = effectSmokeId + 1
            timer.scheduleFunction(function(params)
                local currentPos = getUnitPosition()
                triggerSmokeEffect({x = currentPos.x, y = land.getHeight({x = currentPos.x, y = currentPos.z}) + 2, z = currentPos.z}, params.flameSize, params.duration, params.effectId)
            end, {flameSize = tonumber(effectOrder[i]), duration = duration, effectId = effectId}, timer.getTime() + cumulativeTime)
            cumulativeTime = cumulativeTime + duration
        end

        if effectData.cookOff and effectData.cookOffCount > 0 then
            if splash_damage_options.allunits_advanced_effect_cookoff_flares_enabled then
                timer.scheduleFunction(function(params)
                    local currentPos = getUnitPosition()
                    local flareCoords = {x = currentPos.x, y = land.getHeight({x = currentPos.x, y = currentPos.z}) + 1, z = currentPos.z}
                    debugCargoCookOff("Executing flares for unit ID " .. tostring(params[1].unitID or "nil") .. " at X: " .. flareCoords.x .. ", Y: " .. flareCoords.y .. ", Z: " .. flareCoords.z)
                    scheduleCookOffFlares(flareCoords, params[1].cookOffCount, params[1].cookOffDuration, params[2])
                end, {effectData, splash_damage_options.cookoff_flare_color}, timer.getTime() + 0.2)
            end
            for i = 1, effectData.cookOffCount do
                local delay = effectData.cookOffRandomTiming and math.random() * effectData.cookOffDuration or (i - 1) * (effectData.cookOffDuration / effectData.cookOffCount)
                local basePower = effectData.cookOffPower
                local powerVariation = effectData.cookOffPowerRandom / 100
                local cookOffPower = effectData.cookOffPowerRandom == 0 and basePower or basePower * (1 + powerVariation * (math.random() * 2 - 1))
                timer.scheduleFunction(function(params)
                    local currentPos = getUnitPosition()
                    local cookOffCoords = {x = currentPos.x, y = land.getHeight({x = currentPos.x, y = currentPos.z}) + 1, z = currentPos.z}
                    debugCargoCookOff("Executing cookoff explosion #" .. params[3] .. " for unit ID " .. tostring(params[1].unitID or "nil") .. " at X: " .. cookOffCoords.x .. ", Y: " .. cookOffCoords.y .. ", Z: " .. cookOffCoords.z)
                    trigger.action.explosion(cookOffCoords, params[2])
                end, {effectData, cookOffPower, i}, timer.getTime() + delay)
            end
            if splash_damage_options.debris_effects then
                local debrisCount = math.random(splash_damage_options.debris_count_min, splash_damage_options.debris_count_max)
                for j = 1, debrisCount do
                    local theta = math.random() * 2 * math.pi
                    local phi = math.acos(math.random() * 2 - 1)
                    local minDist = splash_damage_options.debris_max_distance * 0.1
                    local maxDist = splash_damage_options.debris_max_distance
                    local r = math.random() * (maxDist - minDist) + minDist
                    local debrisDelay = (j - 1) * (effectData.cookOffDuration / debrisCount)
                    timer.scheduleFunction(function(debrisArgs)
                        local currentPos = getUnitPosition()
                        local debrisBaseCoords = {x = currentPos.x, y = land.getHeight({x = currentPos.x, y = currentPos.z}) + 1, z = currentPos.z}
                        debugCargoCookOff("Executing debris explosion #" .. debrisArgs[3] .. " for unit ID " .. tostring(debrisArgs[1].unitID or "nil") .. " at X: " .. debrisBaseCoords.x .. ", Y: " .. debrisBaseCoords.y .. ", Z: " .. debrisBaseCoords.z)
                        local debrisX = debrisBaseCoords.x + r * math.sin(phi) * math.cos(theta)
                        local debrisZ = debrisBaseCoords.z + r * math.sin(phi) * math.sin(theta)
                        local terrainY = land.getHeight({x = debrisX, y = debrisZ})
                        local debrisY = terrainY + math.random() * maxDist
                        local debrisPos = {x = debrisX, y = debrisY, z = debrisZ}
                        trigger.action.explosion(debrisPos, debrisArgs[2])
                    end, {effectData, splash_damage_options.debris_power, j}, timer.getTime() + debrisDelay)
                end
            end
        end
    end

    local function checkMovement(params)
        local entry = CargoCookoffPendingTable[params.unitID]
        if not entry then
            debugCargoCookOff("Stopped tracking movement for unit ID " .. tostring(params.unitID) .. ": no entry in CargoCookoffPendingTable")
            --Create fallback entry and trigger effects
            CargoCookoffPendingTable[params.unitID] = {
                coords = coords,
                prevCoords = coords,
                unit = nil
            }
            triggerEffects(coords)
            return
        end
        if processedSmoke[params.unitID] then
            debugCargoCookOff("Stopped tracking movement for unit ID " .. tostring(params.unitID) .. ": smoke already processed")
            return
        end
        local newPos = entry.coords
        if entry.unit then
            local success, pos = pcall(function() return entry.unit:getPosition().p end)
            if success and pos then
                newPos = pos
                debugCargoCookOff("Updated position for unit ID " .. tostring(params.unitID) .. " to X: " .. pos.x .. ", Z: " .. pos.z)
            else
                debugCargoCookOff("Failed to get position for unit ID " .. tostring(params.unitID) .. ", using last known coords X: " .. newPos.x .. ", Z: " .. newPos.z)
            end
        else
            debugCargoCookOff("Unit ID " .. tostring(params.unitID) .. " is gone, using last known coords X: " .. newPos.x .. ", Z: " .. newPos.z)
        end
        local hasStopped = math.abs(newPos.x - entry.prevCoords.x) < 0.1 and
                           math.abs(newPos.y - entry.prevCoords.y) < 0.1 and
                           math.abs(newPos.z - entry.prevCoords.z) < 0.1
        debugCargoCookOff("Checking movement for unit ID " .. tostring(params.unitID) .. ": stopped=" .. tostring(hasStopped) .. ", newPos X=" .. newPos.x .. ", Z=" .. newPos.z)
        if hasStopped or fromDeadEvent then
            entry.coords = newPos
            triggerEffects(newPos)
            return
        end
        entry.prevCoords = newPos
        entry.coords = newPos
        timer.scheduleFunction(checkMovement, params, timer.getTime() + 0.1)
    end

    --Ensure table entry exists before scheduling movement check
    local entry = CargoCookoffPendingTable[unitID]
    if not entry then
        CargoCookoffPendingTable[unitID] = {
            coords = coords,
            prevCoords = coords,
            unit = Unit.getByName(effectData.name) -- Attempt to get unit, may be nil for DEAD events
        }
        entry = CargoCookoffPendingTable[unitID]
    end
    entry.prevCoords = coords
    timer.scheduleFunction(checkMovement, {unitID = unitID}, timer.getTime() + 0.1)
end


--Schedule cargo effects
local function scheduleCargoEffects(unitType, unitName, unitID, effectIndex, fromDeadEvent)
    if not unitID then
        debugCargoCookOff("scheduleCargoEffects: Skipping call with nil unitID")
        return
    end
    debugCargoCookOff("scheduleCargoEffects called for unit ID " .. tostring(unitID) .. ", unitType: " .. unitType .. ", fromDeadEvent: " .. tostring(fromDeadEvent))
    
    local cargoData = cargoUnits[unitType] or {
        cargoExplosionPower = splash_damage_options.allunits_explode_power,
        cargoExplosion = true,
        cookOff = splash_damage_options.allunits_enable_cookoff,
        cookOffCount = splash_damage_options.allunits_cookoff_count,
        cookOffPower = splash_damage_options.allunits_cookoff_power,
        cookOffDuration = splash_damage_options.allunits_cookoff_duration,
        cookOffRandomTiming = true,
        cookOffPowerRandom = splash_damage_options.allunits_cookoff_powerrandom,
        isTanker = splash_damage_options.allunits_enable_smoke,
        flameSize = splash_damage_options.allunits_default_flame_size,
        flameDuration = splash_damage_options.allunits_default_flame_duration
    }
    cargoData.cookOff = cargoUnits[unitType] and cargoUnits[unitType].cargoCookOff ~= nil and cargoUnits[unitType].cargoCookOff or cargoData.cookOff
    debugCargoCookOff("Using cargoData for unitType " .. unitType .. ": cookOff=" .. tostring(cargoData.cookOff))

    local isAllUnitsVehicle = not cargoUnits[unitType] and splash_damage_options.smokeandcookoffeffectallvehicles
    local useAdvancedSequence = false

    if isAllUnitsVehicle and splash_damage_options.allunits_advanced_effect_sequence then
        if splash_damage_options.allunits_advanced_effect_force_on_name and unitName:find("SmokeEffects") then
            useAdvancedSequence = true
            debugCargoCookOff("Forcing advanced effect sequence for unit ID " .. tostring(unitID) .. " due to SmokeEffects in name")
        elseif math.random() <= splash_damage_options.allunits_advanced_effect_sequence_chance then
            useAdvancedSequence = true
            debugCargoCookOff("Selected advanced effect sequence for unit ID " .. tostring(unitID) .. " based on chance")
        else
            debugCargoCookOff("Using standard sequence for unit ID " .. tostring(unitID) .. ", name: " .. tostring(unitName) .. ", chance: " .. tostring(splash_damage_options.allunits_advanced_effect_sequence_chance))
        end
    end

    local effect = {
        name = unitType,
        distance = 0,
        coords = {x = 0, y = 0, z = 0},
        power = cargoData.cargoExplosionPower or splash_damage_options.allunits_explode_power,
        explosion = cargoData.cargoExplosion,
        cookOff = cargoData.cookOff, -- Initially set, may be modified
        cookOffCount = useAdvancedSequence and splash_damage_options.allunits_advanced_effect_cookoff_count or cargoData.cookOffCount,
        cookOffPower = useAdvancedSequence and splash_damage_options.allunits_advanced_effect_cookoff_power or cargoData.cookOffPower,
        cookOffDuration = useAdvancedSequence and splash_damage_options.allunits_advanced_effect_cookoff_duration or cargoData.cookOffDuration,
        cookOffRandomTiming = true,
        cookOffPowerRandom = useAdvancedSequence and splash_damage_options.allunits_advanced_effect_cookoff_powerrandom or cargoData.cookOffPowerRandom,
        isTanker = cargoData.isTanker, --Initially set, may be modified
        flameSize = cargoData.flameSize,
        flameDuration = cargoData.flameDuration,
        unitID = unitID
    }

    local entry = CargoCookoffPendingTable[unitID]
    if entry then
        effect.coords = entry.coords
        debugCargoCookOff("Using coords from CargoCookoffPendingTable for unit ID " .. tostring(unitID) .. ": X=" .. effect.coords.x .. ", Z=" .. effect.coords.z)
    end

    if useAdvancedSequence then
        --Apply advanced sequence cook-off chance
        effect.cookOff = math.random() <= splash_damage_options.allunits_advanced_effect_cookoff_chance
        debugCargoCookOff("Scheduling advanced effect sequence for unit ID " .. tostring(unitID))
        scheduleAdvancedEffectSequence(unitID, effect.coords, effect, fromDeadEvent)
        return
    end

    --Standard sequence: Apply cook-off and smoke chances
    if isAllUnitsVehicle then
        local cookoffChance = splash_damage_options.allunits_cookoff_chance or 1
        if splash_damage_options.allunits_enable_cookoff and math.random() <= cookoffChance then
            debugCargoCookOff("scheduleCargoEffects: Triggering cook-off effects for all-units unit ID " .. tostring(unitID) .. " with allunits_cookoff_chance (" .. cookoffChance .. ")")
            effect.cookOff = true
            effect.isTanker = splash_damage_options.allunits_enable_smoke and splash_damage_options.allunits_smokewithcookoff
        else
            debugCargoCookOff("scheduleCargoEffects: Skipped cook-off effects for all-units unit ID " .. tostring(unitID) .. " due to allunits_cookoff_chance (" .. cookoffChance .. ")")
            effect.cookOff = false
            effect.isTanker = splash_damage_options.allunits_enable_smoke and math.random() <= splash_damage_options.allunits_smoke_chance
            if not effect.isTanker and not effect.cookOff then
                debugCargoCookOff("scheduleCargoEffects: Skipped smoke effects for unit ID " .. tostring(unitID) .. " due to allunits_smoke_chance (" .. splash_damage_options.allunits_smoke_chance .. ")")
                return
            end
        end
    end

    table.insert(cargoEffectsQueue, effect)
    debugCargoCookOff("Queued effects for unit ID " .. tostring(unitID) .. " at X: " .. effect.coords.x .. ", Z: " .. effect.coords.z)

    local processedCargoUnits = {}
    local flamePositions = {}
    for _, eff in ipairs(cargoEffectsQueue) do
        local unitKey = eff.name .. "_" .. eff.coords.x .. "_" .. eff.coords.z
        if not processedCargoUnits[unitKey] then
            local function getUnitPosition(params)
                local id = params.unitID or (params[1] and params[1].unitID)
                local pos = params.coords or (params[1] and params[1].coords)
                if not id then
                    debugCargoCookOff("Error: No unitID provided in getUnitPosition")
                    return pos or {x = 0, y = land.getHeight({x = 0, y = 0}) + 1, z = 0}
                end
                local entry = CargoCookoffPendingTable[id]
                if entry then
                    if entry.unit then
                        local success, newPos = pcall(function() return entry.unit:getPosition().p end)
                        if success and newPos then
                            entry.coords = newPos
                            pos = newPos
                            debugCargoCookOff("Updated position for unit ID " .. id .. " to X: " .. pos.x .. ", Z: " .. pos.z)
                        else
                            debugCargoCookOff("Failed to get position for unit ID " .. id .. ", using last known coords X: " .. pos.x .. ", Z: " .. pos.z)
                        end
                    else
                        debugCargoCookOff("No unit for unit ID " .. id .. ", using last known coords X: " .. pos.x .. ", Z: " .. pos.z)
                    end
                else
                    debugCargoCookOff("No entry for unit ID " .. id .. ", using coords X: " .. pos.x .. ", Z: " .. pos.z)
                end
                --Always adjust y-coordinate to ground level
                pos.y = land.getHeight({x = pos.x, y = pos.z}) + 1.6
                debugCargoCookOff("Adjusted position for unit ID " .. id .. " to Y: " .. pos.y)
                return pos
            end

            if eff.explosion then
                timer.scheduleFunction(function(params)
                    local coords = getUnitPosition(params)
                    debugCargoCookOff("Executing explosion for unit ID " .. tostring(params.unitID or "nil") .. " at X: " .. coords.x .. ", Y: " .. coords.y .. ", Z: " .. coords.z)
                    trigger.action.explosion(coords, params.power)
                end, eff, timer.getTime() + effectIndex + 0.1)
            end
            if eff.cookOff and eff.cookOffCount > 0 then
                timer.scheduleFunction(function(params)
                    local coords = getUnitPosition(params[1])
                    debugCargoCookOff("Executing flares for unit ID " .. tostring(params[1].unitID or "nil") .. " at X: " .. coords.x .. ", Y: " .. coords.y .. ", Z: " .. coords.z)
                    scheduleCookOffFlares(coords, params[1].cookOffCount, params[1].cookOffDuration, params[2])
                end, {eff, splash_damage_options.cookoff_flare_color}, timer.getTime() + 0.2)
                for i = 1, eff.cookOffCount do
                    local delay = eff.cookOffRandomTiming and math.random() * eff.cookOffDuration or (i - 1) * (eff.cookOffDuration / eff.cookOffCount)
                    local basePower = eff.cookOffPower
                    local powerVariation = eff.cookOffPowerRandom / 100
                    local cookOffPower = eff.cookOffPowerRandom == 0 and basePower or basePower * (1 + powerVariation * (math.random() * 2 - 1))
                    timer.scheduleFunction(function(params)
                        local coords = getUnitPosition(params[1])
                        debugCargoCookOff("Executing cookoff explosion #" .. params[3] .. " for unit ID " .. tostring(params[1].unitID or "nil") .. " at X: " .. coords.x .. ", Y: " .. coords.y .. ", Z: " .. coords.z)
                        trigger.action.explosion(coords, params[2])
                    end, {eff, cookOffPower, i}, timer.getTime() + effectIndex + delay)
                end
                if splash_damage_options.debris_effects then
                    local debrisCount = math.random(splash_damage_options.debris_count_min, splash_damage_options.debris_count_max)
                    for j = 1, debrisCount do
                        local theta = math.random() * 2 * math.pi
                        local phi = math.acos(math.random() * 2 - 1)
                        local minDist = splash_damage_options.debris_max_distance * 0.1
                        local maxDist = splash_damage_options.debris_max_distance
                        local r = math.random() * (maxDist - minDist) + minDist
                        local debrisDelay = (j - 1) * (eff.cookOffDuration / debrisCount)
                        timer.scheduleFunction(function(debrisArgs)
                            local coords = getUnitPosition(debrisArgs[1])
                            debugCargoCookOff("Executing debris explosion #" .. debrisArgs[3] .. " for unit ID " .. tostring(debrisArgs[1].unitID or "nil") .. " at X: " .. coords.x .. ", Y: " .. coords.y .. ", Z: " .. coords.z)
                            local debrisX = coords.x + r * math.sin(phi) * math.cos(theta)
                            local debrisZ = coords.z + r * math.sin(phi) * math.sin(theta)
                            local terrainY = land.getHeight({x = debrisX, y = debrisZ})
                            local debrisY = terrainY + math.random() * maxDist
                            local debrisPos = {x = debrisX, y = debrisY, z = debrisZ}
                            trigger.action.explosion(debrisPos, debrisArgs[2])
                        end, {eff, splash_damage_options.debris_power, j}, timer.getTime() + effectIndex + debrisDelay)
                    end
                end
            end
            processedCargoUnits[unitKey] = true
            effectIndex = effectIndex + 3
        end
    end
    cargoEffectsQueue = {}

    --Handle smoke spawning for non-advanced sequence
    if effect.isTanker and entry and not processedSmoke[unitID] then
        local terrainHeight = land.getHeight({x = effect.coords.x, y = effect.coords.z})
        local adjustedCoords = {x = effect.coords.x, y = terrainHeight + 2, z = effect.coords.z}
        if fromDeadEvent then
            --For DEAD events, spawn smoke immediately without movement tracking
            processedSmoke[unitID] = true
            debugCargoCookOff("Spawning immediate smoke for unit ID " .. tostring(unitID) .. " from DEAD event at X: " .. adjustedCoords.x .. ", Z: " .. adjustedCoords.z)
            if not effect.cookOff and splash_damage_options.allunits_explode_on_smoke_only then
                debugCargoCookOff("Triggering explosion for smoke-only unit ID " .. tostring(unitID) .. " at X: " .. adjustedCoords.x .. ", Z: " .. adjustedCoords.z)
                trigger.action.explosion(adjustedCoords, splash_damage_options.allunits_explode_power)
            end
            debugCargoCookOff("Triggered additional explosion for unit ID " .. tostring(unitID) .. " at X: " .. adjustedCoords.x .. ", Z: " .. adjustedCoords.z)
            trigger.action.effectSmokeBig(adjustedCoords, effect.flameSize or 3, 1.0, effectSmokeId)
            effectSmokeId = effectSmokeId + 1
            timer.scheduleFunction(function(id)
                trigger.action.effectSmokeStop(id)
            end, effectSmokeId - 1, timer.getTime() + (effect.flameDuration or splash_damage_options.allunits_default_flame_duration))
        else
            --For HIT/KILL events, track movement until stationary
            local function checkMovement(params)
                local entry = CargoCookoffPendingTable[params.unitID]
                if not entry then
                    debugCargoCookOff("Stopped tracking movement for unit ID " .. tostring(params.unitID) .. ": no entry in CargoCookoffPendingTable")
                    return
                end
                if processedSmoke[params.unitID] then
                    debugCargoCookOff("Stopped tracking movement for unit ID " .. tostring(params.unitID) .. ": smoke already processed")
                    return
                end
                local newPos = entry.coords
                if entry.unit then
                    local success, pos = pcall(function() return entry.unit:getPosition().p end)
                    if success and pos then
                        newPos = pos
                        debugCargoCookOff("Updated position for unit ID " .. tostring(params.unitID) .. " to X: " .. pos.x .. ", Z: " .. pos.z)
                    else
                        debugCargoCookOff("Failed to get position for unit ID " .. tostring(params.unitID) .. ", using last known coords X: " .. newPos.x .. ", Z: " .. newPos.z)
                    end
                else
                    debugCargoCookOff("Unit ID " .. tostring(params.unitID) .. " is gone, using last known coords X: " .. newPos.x .. ", Z: " .. newPos.z)
                end
                local hasStopped = math.abs(newPos.x - entry.prevCoords.x) < 0.1 and
                                   math.abs(newPos.y - entry.prevCoords.y) < 0.1 and
                                   math.abs(newPos.z - entry.prevCoords.z) < 0.1
                debugCargoCookOff("Checking movement for unit ID " .. tostring(params.unitID) .. ": stopped=" .. tostring(hasStopped) .. ", newPos X=" .. newPos.x .. ", Z=" .. newPos.z)
                if hasStopped then
                    processedSmoke[params.unitID] = true
                    entry.coords = newPos
                    local terrainHeight = land.getHeight({x = newPos.x, y = newPos.z})
                    local adjustedCoords = {x = newPos.x, y = terrainHeight + 2, z = newPos.z}
                    debugCargoCookOff("Spawning smoke for unit ID " .. tostring(params.unitID) .. " at X: " .. adjustedCoords.x .. ", Z: " .. adjustedCoords.z)
                    if not params.cookOff and splash_damage_options.allunits_explode_on_smoke_only then
                        debugCargoCookOff("Triggering explosion for smoke-only unit ID " .. tostring(params.unitID) .. " at X: " .. adjustedCoords.x .. ", Z: " .. adjustedCoords.z)
                        trigger.action.explosion(adjustedCoords, splash_damage_options.allunits_explode_power)
                    end
                    debugCargoCookOff("Triggered additional explosion for unit ID " .. tostring(params.unitID) .. " at X: " .. adjustedCoords.x .. ", Z: " .. adjustedCoords.z)
                    trigger.action.effectSmokeBig(adjustedCoords, params.flameSize or 3, 1.0, effectSmokeId)
                    effectSmokeId = effectSmokeId + 1
                    timer.scheduleFunction(function(id)
                        trigger.action.effectSmokeStop(id)
                    end, effectSmokeId - 1, timer.getTime() + (params.flameDuration or splash_damage_options.allunits_default_flame_duration))
                    return
                end
                entry.prevCoords = newPos
                entry.coords = newPos
                timer.scheduleFunction(checkMovement, params, timer.getTime() + 0.3)
            end
            timer.scheduleFunction(checkMovement, effect, timer.getTime() + 0.3)
        end
    end
end

--Giant Explosion Function
function triggerGiantExplosion(params)
    if not splash_damage_options.giant_explosion_enabled then
        debugMsg("Giant Explosion is disabled in options.")
        return
    end

    local initialPos = params.pos or {x = 0, y = 0, z = 0}
    local explosionPower = params.power or splash_damage_options.giant_explosion_power
    local sizeScale = params.scale or splash_damage_options.giant_explosion_scale
    local totalDuration = params.duration or splash_damage_options.giant_explosion_duration
    local explosionCount = params.count or splash_damage_options.giant_explosion_count

    if not initialPos.x or not initialPos.y or not initialPos.z then
        gameMsg("Error: Invalid position for giant explosion!")
        debugMsg("No valid initial position set for giant explosion!")
        return
    end

    debugMsg("Triggering giant fireball at X: " .. initialPos.x .. ", Y: " .. initialPos.y .. ", Z: " .. initialPos.z)

    local function scheduleExplosion(pos, delay)
        if not pos or not pos.x or not pos.y or not pos.z then
            debugMsg("Error: Invalid position for explosion - pos: " .. tostring(pos))
            return
        end
        timer.scheduleFunction(function(p)
            if p and p.x and p.y and p.z then
                trigger.action.explosion(p, explosionPower)
            end
        end, pos, timer.getTime() + delay)
    end

    --Pre-explosion scan for cargo units
    local scanRadius = 1500 * sizeScale --1500m base radius, scaled by sizeScale
    local preExplosionTargets = {}
    if splash_damage_options.enable_cargo_effects then
        local volS = {
            id = world.VolumeType.SPHERE,
            params = { point = initialPos, radius = scanRadius }
        }
        local ifFound = function(foundObject)
            if foundObject:isExist() then
                local category = foundObject:getCategory()
                if (category == Object.Category.UNIT and foundObject:getDesc().category == Unit.Category.GROUND_UNIT) or
                   category == Object.Category.STATIC then
                    table.insert(preExplosionTargets, {
                        name = foundObject:getTypeName(),
                        health = foundObject:getLife() or 0,
                        position = foundObject:getPoint(),
                        maxHealth = (category == Object.Category.UNIT and foundObject:getDesc().life) or foundObject:getLife() or 0,
                        unit = foundObject
                    })
                end
            end
            return true
        end
        world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, volS, ifFound)
        debugMsg("Pre-explosion scan for Giant Explosion: " .. #preExplosionTargets .. " targets found within " .. scanRadius .. "m")
    end
    --Trigger the explosion
    local maxRadius = 200 * sizeScale
    local maxHeight = 500 * sizeScale
    local adjustedExplosionCount = math.floor(explosionCount * (sizeScale ^ 2.5))
    local stepTime = totalDuration / adjustedExplosionCount
    local variance = 0.25 --Fixed at 25%

    for i = 1, adjustedExplosionCount do
        local progress = i / adjustedExplosionCount
        local currentRadius = maxRadius * progress
        local r = currentRadius * (0.9 + math.random() * 0.1)
        local theta = math.random() * 2 * math.pi
        local phi = math.acos(math.random())

        local offsetX = r * math.sin(phi) * math.cos(theta)
        local offsetZ = r * math.sin(phi) * math.sin(theta)
        local offsetY = r * math.cos(phi)

        offsetX = offsetX * (1 + (math.random() - 0.5) * variance)
        offsetZ = offsetZ * (1 + (math.random() - 0.5) * variance)
        offsetY = offsetY * (1 + (math.random() - 0.5) * variance * 0.5)

        local blastPos = {
            x = initialPos.x + offsetX,
            y = land.getHeight({x = initialPos.x, y = initialPos.z}) + offsetY,
            z = initialPos.z + offsetZ
        }
        if blastPos.y < land.getHeight({x = blastPos.x, y = blastPos.z}) then
            blastPos.y = land.getHeight({x = blastPos.x, y = blastPos.z})
        end

        local delay = (i - 1) * stepTime + (math.random() - 0.5) * stepTime * variance
        scheduleExplosion(blastPos, delay)
    end

    gameMsg("Expanding giant fireball over " .. totalDuration .. "s (scale " .. sizeScale .. ")!")

    --Post-explosion scan and cargo cook-off queuing
    if splash_damage_options.enable_cargo_effects then
        timer.scheduleFunction(function(args)
            local centerPos = args[1]
            local radius = args[2]
            local preTargets = args[3]

            local postExplosionTargets = {}
            local volS = {
                id = world.VolumeType.SPHERE,
                params = { point = centerPos, radius = radius }
            }
            local ifFound = function(foundObject)
                if foundObject:isExist() then
                    local category = foundObject:getCategory()
                    if (category == Object.Category.UNIT and foundObject:getDesc().category == Unit.Category.GROUND_UNIT) or
                       category == Object.Category.STATIC then
                        table.insert(postExplosionTargets, {
                            name = foundObject:getTypeName(),
                            health = foundObject:getLife() or 0,
                            position = foundObject:getPoint(),
                            maxHealth = (category == Object.Category.UNIT and foundObject:getDesc().life) or foundObject:getLife() or 0
                        })
                    end
                end
                return true
            end
            world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, volS, ifFound)
            debugMsg("Post-explosion scan for Giant Explosion: " .. #postExplosionTargets .. " targets found within " .. radius .. "m")

            --Compare pre- and post-explosion targets
            for _, preTarget in ipairs(preTargets) do
                local found = false
                local postHealth = 0
                for _, postTarget in ipairs(postExplosionTargets) do
                    if preTarget.name == postTarget.name and getDistance(preTarget.position, postTarget.position) < 1 then
                        found = true
                        postHealth = postTarget.health
                        break
                    end
                end

                local cargoData = cargoUnits[preTarget.name]
                if cargoData and (not found or postHealth <= 0) then
                    local distance = getDistance(initialPos, preTarget.position)
                    if distance <= radius then
                        local cargoPower = cargoData.cargoExplosionPower or explosionPower
                        table.insert(cargoEffectsQueue, {
                            name = preTarget.name,
                            distance = distance,
                            coords = preTarget.position,
                            power = cargoPower,
                            explosion = cargoData.cargoExplosion,
                            cookOff = cargoData.cargoCookOff,
                            cookOffCount = cargoData.cookOffCount,
                            cookOffPower = cargoData.cookOffPower,
                            cookOffDuration = cargoData.cookOffDuration,
                            cookOffRandomTiming = cargoData.cookOffRandomTiming,
                            cookOffPowerRandom = cargoData.cookOffPowerRandom,
                            isTanker = cargoData.isTanker,
                            flameSize = cargoData.flameSize,
                            flameDuration = cargoData.flameDuration
                        })
                        debugMsg("Queued cargo effect for " .. preTarget.name .. " destroyed by Giant Explosion at " .. string.format("%.1f", distance) .. "m")
                    end
                end
            end

            --Process queued cargo effects with prioritized flames
            if #cargoEffectsQueue > 0 then
                local flameIndex = 0 --Separate index for flames
                local otherIndex = 0 --Index for explosions, cook-offs, debris
                local processedCargoUnits = {}
                local flamePositions = {}
                for _, effect in ipairs(cargoEffectsQueue) do
                    local unitKey = effect.name .. "_" .. effect.coords.x .. "_" .. effect.coords.z
                    if not processedUnitsGlobal[unitKey] and not processedCargoUnits[unitKey] then
                        --Handle tanker flames first with minimal delay
                        if effect.isTanker and effect.explosion then
                            debugMsg("Triggering cargo explosion for tanker " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m with power " .. effect.power .. " scheduled at " .. flameIndex .. "s")
                            timer.scheduleFunction(function(params)
                                debugMsg("Executing cargo explosion at X: " .. string.format("%.0f", params[1].x) .. ", Y: " .. string.format("%.0f", params[1].y) .. ", Z: " .. string.format("%.0f", params[1].z) .. " with power " .. params[2])
                                trigger.action.explosion(params[1], params[2])
                            end, {effect.coords, effect.power}, timer.getTime() + flameIndex + 0.1)

                            local flameSize = effect.flameSize or 3
                            local flameDuration = effect.flameDuration
                            local flameDensity = 1.0
                            local effectId = effectSmokeId
                            effectSmokeId = effectSmokeId + 1
                            local isDuplicate = false
                            for _, pos in pairs(flamePositions) do
                                if getDistance3D(effect.coords, pos) < 3 then
                                    isDuplicate = true
                                    debugMsg("Skipping duplicate flame for " .. effect.name .. " near X: " .. string.format("%.0f", pos.x) .. ", Y: " .. string.format("%.0f", pos.y) .. ", Z: " .. string.format("%.0f", pos.z))
                                    break
                                end
                            end
                            if not isDuplicate then
                                debugMsg("Adding flame effect for tanker " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m (Size: " .. flameSize .. ", Duration: " .. flameDuration .. "s, ID: " .. effectId .. ") scheduled at " .. flameIndex .. "s")
                                timer.scheduleFunction(function(params)
                                    local terrainHeight = land.getHeight({x = params[1].x, y = params[1].z})
                                    local adjustedCoords = {x = params[1].x, y = terrainHeight + 2, z = params[1].z}
                                    debugMsg("Spawning flame effect at X: " .. string.format("%.0f", adjustedCoords.x) .. ", Y: " .. string.format("%.0f", adjustedCoords.y) .. ", Z: " .. string.format("%.0f", adjustedCoords.z))
                                    trigger.action.explosion(adjustedCoords, 10) --Small trigger explosion
                                    trigger.action.effectSmokeBig(adjustedCoords, params[2], params[3], params[4])
                                end, {effect.coords, flameSize, flameDensity, effectId}, timer.getTime() + flameIndex + 0.2)
                                timer.scheduleFunction(function(id)
                                    debugMsg("Stopping flame effect for " .. effect.name .. " (ID: " .. id .. ")")
                                    trigger.action.effectSmokeStop(id)
                                end, effectId, timer.getTime() + flameIndex + flameDuration + 0.2)
                                table.insert(flamePositions, effect.coords)
                            end
                            flameIndex = flameIndex + 0.5 --Fast spacing for flames (0.5s)
                        end
                        --Handle non-tanker explosions, cook-offs, and debris
                        if not effect.isTanker or (effect.explosion and not effect.isTanker) then
                            if effect.explosion then
                                debugMsg("Triggering cargo explosion for " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m with power " .. effect.power .. " scheduled at " .. otherIndex .. "s")
                                timer.scheduleFunction(function(params)
                                    debugMsg("Executing cargo explosion at X: " .. string.format("%.0f", params[1].x) .. ", Y: " .. string.format("%.0f", params[1].y) .. ", Z: " .. string.format("%.0f", params[1].z) .. " with power " .. params[2])
                                    trigger.action.explosion(params[1], params[2])
                                end, {effect.coords, effect.power}, timer.getTime() + otherIndex + 0.1)
                            end
                            if effect.cookOff and effect.cookOffCount > 0 then
                                debugMsg("Scheduling " .. effect.cookOffCount .. " cook-off explosions for " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m over " .. effect.cookOffDuration .. "s starting at " .. otherIndex .. "s")
                                for i = 1, effect.cookOffCount do
                                    local delay = effect.cookOffRandomTiming and math.random() * effect.cookOffDuration or (i - 1) * (effect.cookOffDuration / effect.cookOffCount)
                                    local basePower = effect.cookOffPower
                                    local powerVariation = effect.cookOffPowerRandom / 100
                                    local cookOffPower = effect.cookOffPowerRandom == 0 and basePower or basePower * (1 + powerVariation * (math.random() * 2 - 1))
                                    debugMsg("Cook-off #" .. i .. " for " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m scheduled at " .. string.format("%.3f", delay) .. "s with power " .. string.format("%.2f", cookOffPower))
                                    timer.scheduleFunction(function(params)
                                        debugMsg("Executing cook-off at X: " .. string.format("%.0f", params[1].x) .. ", Y: " .. string.format("%.0f", params[1].y) .. ", Z: " .. string.format("%.0f", params[1].z) .. " with power " .. params[2])
                                        trigger.action.explosion(params[1], params[2])
                                    end, {effect.coords, cookOffPower}, timer.getTime() + otherIndex + delay)
                                end
                                if splash_damage_options.debris_effects then
                                    local debrisCount = math.random(splash_damage_options.debris_count_min, splash_damage_options.debris_count_max)
                                    for j = 1, debrisCount do
                                        local theta = math.random() * 2 * math.pi
                                        local phi = math.acos(math.random() * 2 - 1)
                                        local minDist = splash_damage_options.debris_max_distance * 0.1
                                        local maxDist = splash_damage_options.debris_max_distance
                                        local r = math.random() * (maxDist - minDist) + minDist
                                        local debrisX = effect.coords.x + r * math.sin(phi) * math.cos(theta)
                                        local debrisZ = effect.coords.z + r * math.sin(phi) * math.sin(theta)
                                        local terrainY = land.getHeight({x = debrisX, y = debrisZ})
                                        local debrisY = terrainY + math.random() * maxDist
                                        local debrisPos = {x = debrisX, y = debrisY, z = debrisZ}
                                        local debrisPower = splash_damage_options.debris_power
                                        local debrisDelay = (j - 1) * (effect.cookOffDuration / debrisCount)
                                        timer.scheduleFunction(function(debrisArgs)
                                            debugMsg("Debris explosion at X: " .. string.format("%.0f", debrisArgs[1].x) .. ", Y: " .. string.format("%.0f", debrisArgs[1].y) .. ", Z: " .. string.format("%.0f", debrisArgs[1].z) .. " with power " .. debrisArgs[2])
                                            trigger.action.explosion(debrisArgs[1], debrisArgs[2])
                                        end, {debrisPos, debrisPower}, timer.getTime() + otherIndex + debrisDelay)
                                    end
                                end
                            end
                            otherIndex = otherIndex + 1 --Slower spacing for non-flame effects (1s)
                        end
                        processedCargoUnits[unitKey] = true
                        markProcessedUnitGlobal(unitKey)
                    end
                end
                cargoEffectsQueue = {} --Clear the queue after processing
            end
        end, {initialPos, scanRadius, preExplosionTargets}, timer.getTime() + totalDuration + 1.0)
    end
end

function getWeaponExplosive(name)
    local weaponData = explTable[name]
    if weaponData then
        return weaponData.explosive, weaponData.shaped_charge
    else
        return 0, false
    end
end
  
function track_wpns_cluster_scan(args)
    local parentPos = args[1]
    local parentDir = args[2]
    local parentName = args[3]
    local subName = args[4]
    local subCount = args[5]
    local subPower = args[6]
    local parentVel = args[7]
    local attempt = args[8] or 1
    local maxAttempts = 3
    local scanVol = {
        id = world.VolumeType.SPHERE,
        params = { point = parentPos, radius = 400 }
    }
    local bombletsFound = {}
    local allWeaponsFound = {}
    --General scan for all weapons
    world.searchObjects(Object.Category.WEAPON, scanVol, function(wpn)
        if wpn:isExist() then
            local wpnId = wpn.id_
            local wpnType = wpn:getTypeName()
            local wpnPos = wpn:getPosition().p
            table.insert(allWeaponsFound, { id = wpnId, type = wpnType, x = wpnPos.x, y = wpnPos.y, z = wpnPos.z })
            if wpnType == subName and not tracked_weapons[wpnId] then
                tracked_weapons[wpnId] = {
                    wpn = wpn,
                    pos = wpnPos,
                    speed = wpn:getVelocity(),
                    name = wpnType,
                    parent = parentName,
                    parentVelocity = parentVel
                }
                table.insert(bombletsFound, wpnId)
                debugMsg("Detected expected submunition '" .. wpnType .. "' from '" .. parentName .. "' at X: " .. string.format("%.0f", wpnPos.x) .. ", Y: " .. string.format("%.0f", wpnPos.y) .. ", Z: " .. string.format("%.0f", wpnPos.z) .. " (Attempt " .. attempt .. ")")
            end
        end
        return true
    end)
    --Log results
    debugMsg("Scanned for submunition '" .. subName .. "' bomblets from '" .. parentName .. "': " .. #bombletsFound .. " found (Attempt " .. attempt .. ")")
    if #allWeaponsFound > 0 then
        local msg = "General scan for '" .. parentName .. "': " .. #allWeaponsFound .. " bomblets released, expected " .. subCount .. " '" .. subName .. "'"
        local typeMismatch = false
        for _, wpn in ipairs(allWeaponsFound) do
            if wpn.type ~= subName then
                typeMismatch = true
                break
            end
        end
        if typeMismatch then
            msg = msg .. " - Mismatch detected! Actual bomblets: "
            for _, wpn in ipairs(allWeaponsFound) do
                msg = msg .. "'" .. wpn.type .. "' (X: " .. string.format("%.0f", wpn.x) .. ", Y: " .. string.format("%.0f", wpn.y) .. ", Z: " .. string.format("%.0f", wpn.z) .. ") "
            end
            msg = msg .. "Script may need changing."
        end
        debugMsg(msg)
    elseif #bombletsFound == 0 and #allWeaponsFound == 0 then
        debugMsg("No bomblets of any type detected for '" .. parentName .. "' (Attempt " .. attempt .. ")")
    end
    --Retry if no expected submunitions found
    if #bombletsFound == 0 and attempt < maxAttempts then
        debugMsg("No expected submunition '" .. subName .. "' found on attempt " .. attempt .. ", retrying in 0.5s")
        timer.scheduleFunction(track_wpns_cluster_scan, {parentPos, parentDir, parentName, subName, subCount, subPower, parentVel, attempt + 1}, timer.getTime() + 0.5)
    elseif #bombletsFound == 0 and attempt == maxAttempts then
        debugMsg("No submunition '" .. subName .. "' spawned by DCS for '" .. parentName .. "' after " .. maxAttempts .. " attempts - skipping additional explosions")
    end
end


--function to schedule flares for cook-offs
function scheduleCookOffFlares(coords, cookOffCount, cookOffDuration, flareColor)
    if not splash_damage_options.cookoff_flares_enabled then return end --Skip if flares disabled
    if math.random() > splash_damage_options.cookoff_flare_chance then return end --Skip if chance fails

    local flareCount = math.floor(cookOffCount * splash_damage_options.cookoff_flare_count_modifier)
    if flareCount < 1 then return end --Skip if no flares
    debugCargoCookOff("Scheduling flares for cook-off at X: " .. string.format("%.0f", coords.x) .. ", Z: " .. string.format("%.0f", coords.z))
    
    if splash_damage_options.cookoff_flare_instant then
        --Use evenly distributed azimuths for instant flares
        local scaledFlareCount = math.random(splash_damage_options.cookoff_flare_instant_min, splash_damage_options.cookoff_flare_instant_max)
        debugCargoCookOff("Spawning " .. scaledFlareCount .. " instant flares")
        local angleStep = 360 / scaledFlareCount --Divide circle into equal segments
        for i = 1, scaledFlareCount do
            --Base azimuth for this flare, with a small random offset within ±20 degrees
            local baseAzimuth = (i - 1) * angleStep
            local randomAzimuth = baseAzimuth + math.random(-33, 40)
            randomAzimuth = randomAzimuth % 360 --Normalize to [0, 359]
            local offsetX = math.random(-splash_damage_options.cookoff_flare_offset, splash_damage_options.cookoff_flare_offset)
            local offsetZ = math.random(-splash_damage_options.cookoff_flare_offset, splash_damage_options.cookoff_flare_offset)
            local flarePos = { x = coords.x + offsetX, y = coords.y, z = coords.z + offsetZ }
            debugCargoCookOff("Spawning instant flare #" .. i .. " at X: " .. string.format("%.0f", flarePos.x) .. ", Z: " .. string.format("%.0f", flarePos.z) .. " with color " .. flareColor .. " and azimuth " .. randomAzimuth)
            trigger.action.signalFlare(flarePos, flareColor, randomAzimuth)
        end
    else
        --Original time-based flare spawning
        debugCargoCookOff("Spawning " .. flareCount .. " flares over " .. cookOffDuration .. " seconds")
        for i = 1, flareCount do
            local delay = math.random() * cookOffDuration --Random time within cook-off duration
            local terrainHeight = land.getHeight({x = coords.x, y = coords.z})
            local offset = {
                x = coords.x + math.random(-splash_damage_options.cookoff_flare_offset, splash_damage_options.cookoff_flare_offset),
                y = terrainHeight, --Start at ground level
                z = coords.z + math.random(-splash_damage_options.cookoff_flare_offset, splash_damage_options.cookoff_flare_offset)
            }
            local azimuth = math.random(1, 360) --Random direction
            timer.scheduleFunction(function(params)
                debugCargoCookOff("Spawning flare #" .. params[1] .. " at X: " .. string.format("%.0f", params[2].x) .. ", Y: " .. string.format("%.0f", params[2].y) .. ", Z: " .. string.format("%.0f", params[2].z) .. " with color " .. params[3])
                trigger.action.signalFlare(params[2], params[3], params[4])
            end, {i, offset, flareColor, azimuth}, timer.getTime() + delay)
        end
    end
end


function track_wpns()
    local weaponsToRemove = {} --Delay removal to ensure all weapons are checked
    for wpn_id_, wpnData in pairs(tracked_weapons) do   
		--Skip ground ordnance if track_groundunitordnance is disabled
        if wpnData.isGroundUnitOrdnance and not splash_damage_options.track_groundunitordnance then
            debugMsg("Ground unit ordnance weapon, track_groundunitordnance set to false, skipping tracking + effects")
            table.insert(weaponsToRemove, wpn_id_)
        else
            local weaponExists = safeGet(function() return wpnData.wpn:isExist() end, false)
            if weaponExists then
                local weaponPosition = safeGet(function() return wpnData.wpn:getPosition() end, nil)
                local weaponVelocity = safeGet(function() return wpnData.wpn:getVelocity() end, nil)
                if not weaponPosition or not weaponPosition.p or not weaponPosition.x or not weaponVelocity then
                    if splash_damage_options.debug then
                        debugMsg("track_wpns: Failed to refresh weapon state for '" .. (wpnData.name or "unknown weapon") .. "', removing weapon from tracking")
                    end
                    table.insert(weaponsToRemove, wpn_id_)
                else
                --Update position, direction, speed
                wpnData.pos = weaponPosition.p
                wpnData.dir = weaponPosition.x
                wpnData.speed = weaponVelocity
                --Scan potential blast zone in the last frame before impact
                if splash_damage_options.track_pre_explosion then
                    local ip = land.getIP(wpnData.pos, wpnData.dir, lookahead(wpnData.speed))
                    local predictedImpact = ip or wpnData.pos

                    local base_explosive, isShapedCharge = getWeaponExplosive(wpnData.name)
                    base_explosive = base_explosive * splash_damage_options.overall_scaling
                    if splash_damage_options.rocket_multiplier and wpnData.cat == Weapon.Category.ROCKET then
                        base_explosive = base_explosive * splash_damage_options.rocket_multiplier
                    end
                    if wpnData.isGroundUnitOrdnance and splash_damage_options.track_groundunitordnance then
                        base_explosive = base_explosive * splash_damage_options.groundunitordnance_damage_modifier
                    end

                    local explosionPower = base_explosive
                    if splash_damage_options.apply_shaped_charge_effects and isShapedCharge then
                        explosionPower = explosionPower * splash_damage_options.shaped_charge_multiplier
                    end

                    local blastRadius = splash_damage_options.blast_search_radius * 2 --Wider post-scan (180m default)
                    if splash_damage_options.use_dynamic_blast_radius then
                        blastRadius = math.pow(explosionPower, 1/3) * 10 * splash_damage_options.dynamic_blast_radius_modifier 
                    end

                    --Set tightRadius, use 50m for ground ordnance if enabled
                    local tightRadius = blastRadius
                    if wpnData.isGroundUnitOrdnance and splash_damage_options.scan_50m_for_groundordnance then
                        tightRadius = 50 --Fixed 50m radius for ground ordnance
                        if splash_damage_options.track_groundunitordnance_debug then
                            debugMsg("Using 50m scan radius for ground ordnance " .. wpnData.name)
                        end
                    end
                    local volS = {
                        id = world.VolumeType.SPHERE,
                        params = { 
                            point = wpnData.pos, --Use current pos
                            radius = tightRadius 
                        }
                    }
                    local tightTargets = {}
                    local ifFound = function(foundObject, targets, center)
                        if foundObject:isExist() then
                            local category = foundObject:getCategory()
                            if (category == Object.Category.UNIT and (foundObject:getDesc().category == Unit.Category.GROUND_UNIT or foundObject:getDesc().category == Unit.Category.AIRPLANE)) or
                               category == Object.Category.STATIC then
                                local statName, points = getFootholdRewardDataForObject(foundObject)
                                table.insert(targets, {
                                    name = foundObject:getTypeName(),
                                    distance = getDistance(center, foundObject:getPoint()),
                                    health = foundObject:getLife() or 0,
                                    position = foundObject:getPoint(),
                                    maxHealth = (category == Object.Category.UNIT and foundObject:getDesc().life) or foundObject:getLife() or 0,
                                    unit = foundObject,
                                    id = foundObject:getID(),
                                    unitName = foundObject:getName() or "Unknown",
                                    statName = statName,
                                    points = points
                                })
                            end
                        end
                        return true
                    end
                    if splash_damage_options.track_pre_explosion_debug then
                        debugMsg("Scanning tight radius " .. tightRadius .. "m at current pos while weapon exists")
                    end
                    world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, volS, function(obj) ifFound(obj, tightTargets, wpnData.pos) end)
                    wpnData.tightTargets = tightTargets --Store for impact

                    --Wider scan for lastKnownTargets
                    volS.params.point = predictedImpact
                    volS.params.radius = blastRadius
                    local foundTargets = {}
                    world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, volS, function(obj) ifFound(obj, foundTargets, predictedImpact) end)
                    wpnData.lastKnownTargets = foundTargets
                end
                --Submunition impact handling
                local weaponData = explTable[wpnData.parent or wpnData.name] or { submunition_name = "unknown" }
                if wpnData.name == weaponData.submunition_name then
                    local groundHeight = land.getHeight({x = wpnData.pos.x, y = wpnData.pos.z})
                    if wpnData.pos.y - groundHeight < 50 then --Impact threshold like old script
                        if splash_damage_options.debug then
                            debugMsg("Submunition '" .. wpnData.name .. "' from '" .. (wpnData.parent or "unknown") .. "' impacted at X: " .. string.format("%.0f", wpnData.pos.x) .. ", Z: " .. string.format("%.0f", wpnData.pos.z))
                        end
                        local parentWeaponData = explTable[wpnData.parent] or { submunition_count = 30, submunition_explosive = 1 }
                        local submunitionCount = parentWeaponData.submunition_count or 30
                        local submunitionPower = (parentWeaponData.submunition_explosive or 1) * splash_damage_options.cluster_bomblet_damage_modifier * splash_damage_options.overall_scaling
                        if splash_damage_options.cluster_bomblet_reductionmodifier then
                            if submunitionCount > 35 then
                                local reductionFactor = (60 - 35) / (247 - 35)
                                submunitionCount = 35 + math.floor((submunitionCount - 35) * reductionFactor)
                                if submunitionCount > 60 then submunitionCount = 60 end
                            end
                        end
                        --Use parent velocity if available, else submunition speed
                        local parentDir = wpnData.parentVelocity or wpnData.speed
                        local dispersionLength, dispersionWidth = calculate_dispersion(parentDir, 2000) --Match original 2000m
                        local dirMag = math.sqrt(parentDir.x^2 + parentDir.z^2)
                        local dir = dirMag > 0 and {x = parentDir.x / dirMag, z = parentDir.z / dirMag} or {x = 1, z = 0}
                        if splash_damage_options.debug then
                            debugMsg("Simulating " .. submunitionCount .. " bomblets for submunition '" .. wpnData.name .. "' from '" .. (wpnData.parent or "unknown") .. "' over " .. string.format("%.0f", dispersionLength) .. "m x " .. string.format("%.0f", dispersionWidth) .. "m")
                        end
                        for i = 1, submunitionCount do
                            local theta = math.random() * 2 * math.pi
                            local r = math.sqrt(math.random())
                            local xOffset = r * dispersionLength * 0.5 * math.cos(theta)
                            local zOffset = r * dispersionWidth * 0.5 * math.sin(theta)
                            local subPos = {
                                x = wpnData.pos.x + (xOffset * dir.x - zOffset * dir.z),
                                z = wpnData.pos.z + (xOffset * dir.z + zOffset * dir.x)
                            }
                            subPos.y = land.getHeight({x = subPos.x, y = subPos.z})
                            if splash_damage_options.debug then
                                debugMsg("Triggering bomblet #" .. i .. " for submunition '" .. wpnData.name .. "' at X: " .. string.format("%.0f", subPos.x) .. ", Z: " .. string.format("%.0f", subPos.z) .. " with power " .. submunitionPower)
                            end
                            trigger.action.explosion(subPos, submunitionPower)
                        end
                        table.insert(weaponsToRemove, wpn_id_)
                    end
                end
                end
            else
                --Weapon has impacted
                if splash_damage_options.debug then
                    debugMsg("Weapon " .. wpnData.name .. " no longer exists at " .. timer.getTime() .. "s")
                end
                local ip = land.getIP(wpnData.pos, wpnData.dir, lookahead(wpnData.speed))  --terrain intersection point with weapon's nose
                local explosionPoint
                if not ip then --use last calculated IP
                    explosionPoint = wpnData.pos
                else --use intersection point
                    explosionPoint = ip
                end
                if wpnData.isGroundUnitOrdnance and splash_damage_options.track_groundunitordnance_debug then
                    local base_explosive, isShapedCharge = getWeaponExplosive(wpnData.name)
                    base_explosive = base_explosive * splash_damage_options.overall_scaling
                    if splash_damage_options.rocket_multiplier and wpnData.cat == Weapon.Category.ROCKET then
                        base_explosive = base_explosive * splash_damage_options.rocket_multiplier
                    end
                    if wpnData.isGroundUnitOrdnance and splash_damage_options.track_groundunitordnance then
                        base_explosive = base_explosive * splash_damage_options.groundunitordnance_damage_modifier
                    end
                    local explosionPower = base_explosive
                    if splash_damage_options.apply_shaped_charge_effects and isShapedCharge then
                        explosionPower = explosionPower * splash_damage_options.shaped_charge_multiplier
                    end
                    debugMsg("Ground unit ordnance " .. wpnData.name .. " impacted at X: " .. string.format("%.0f", explosionPoint.x) .. ", Y: " .. string.format("%.0f", explosionPoint.y) .. ", Z: " .. string.format("%.0f", explosionPoint.z) .. " with power " .. explosionPower)
                end
                local chosenTargets = wpnData.tightTargets or {}
                local safeToBlast = true
                --Check for tactical explosion conditions
                local isTactical = false
                --Check tactical weapons table
                if tacticalwpn_tabl[wpnData.name] then
                    isTactical = true
                    if splash_damage_options.debug then
                        debugMsg("Tactical explosion triggered for weapon: " .. wpnData.name .. " at X: " .. explosionPoint.x .. ", Z: " .. explosionPoint.z)
                    end
                    TacticalExplosionTrigger(explosionPoint)
                    table.insert(weaponsToRemove, wpn_id_)
                end
                --Check tactical override weapons
                if splash_damage_options.tactical_explosion and splash_damage_options.tactical_explosion_override_enabled then
                    local tacticalWeapons = {}
                    for weapon in splash_damage_options.tactical_explosion_override_weapons:gmatch("[^,]+") do
                        tacticalWeapons[trim(weapon:upper())] = true -- Normalize to uppercase
                    end
                    if tacticalWeapons[wpnData.name:upper()] then -- Compare in uppercase
                        isTactical = true
                        if splash_damage_options.debug then
                            debugMsg("Tactical explosion override triggered for " .. wpnData.name .. " at X: " .. explosionPoint.x .. ", Z: " .. explosionPoint.z)
                        end
                        TacticalExplosionTrigger(explosionPoint)
                        table.insert(weaponsToRemove, wpn_id_)
                    end
                end
                --Check if weapon is napalm
                local isNapalm = false
                --Check for napalm override weapons
                if splash_damage_options.napalmoverride_enabled then
                    local napalmWeapons = {}
                    for weapon in splash_damage_options.napalm_override_weapons:gmatch("[^,]+") do
                        napalmWeapons[trim(weapon)] = true
                    end
                    if napalmWeapons[wpnData.name] then
                        isNapalm = true
                        if splash_damage_options.debug then
                            debugMsg("Napalm override triggered for " .. wpnData.name .. " at X: " .. string.format("%.0f", explosionPoint.x) .. ", Z: " .. string.format("%.0f", explosionPoint.z) .. ", playerName: " .. tostring(wpnData.initiatorPilotName or wpnData.init or "unknown"))
                        end
                        napalmOnImpact(explosionPoint, wpnData.speed, wpnData.name, wpnData.initiatorPilotName or wpnData.init or "unknown") -- Pass initiatorPilotName
                        table.insert(weaponsToRemove, wpn_id_)
                    end
                end
                --Check for MK77 weapons independently
                if splash_damage_options.napalm_mk77_enabled and (wpnData.name == "MK77mod0-WPN" or wpnData.name == "MK77mod1-WPN") then
                    isNapalm = true
                    if splash_damage_options.debug then
                        debugMsg("MK77 napalm triggered for " .. wpnData.name .. " at X: " .. string.format("%.0f", explosionPoint.x) .. ", Z: " .. string.format("%.0f", explosionPoint.z) .. ", playerName: " .. tostring(wpnData.initiatorPilotName or wpnData.init or "unknown"))
                    end
                    napalmOnImpact(explosionPoint, wpnData.speed, wpnData.name, wpnData.initiatorPilotName or wpnData.init or "unknown") -- Pass initiatorPilotName
                    table.insert(weaponsToRemove, wpn_id_)
                end
                if not isNapalm and not isTactical then
                    if splash_damage_options.ordnance_protection then
                        local checkVol = { id = world.VolumeType.SPHERE, params = { point = explosionPoint, radius = splash_damage_options.ordnance_protection_radius } }
                        if splash_damage_options.debug then
                            debugMsg("Checking ordnance protection for '" .. wpnData.name .. "' at X: " .. explosionPoint.x .. ", Y: " .. explosionPoint.y .. ", Z: " .. explosionPoint.z .. " with radius " .. splash_damage_options.ordnance_protection_radius .. "m")
                        end
                        world.searchObjects(Object.Category.WEAPON, checkVol, function(obj)
                            if safeGet(function() return obj:isExist() end, false) and tracked_weapons[obj.id_] then
                                safeToBlast = false
                                if splash_damage_options.debug then
                                    debugMsg("Skipping explosion for '" .. wpnData.name .. "' - nearby bomb '" .. tracked_weapons[obj.id_].name .. "' within " .. splash_damage_options.ordnance_protection_radius .. "m")
                                end
                                return false
                            end
                            return true
                        end)
                    end
                    if safeToBlast then
                        if splash_damage_options.debug then
                            debugMsg("FinalPos Check for '" .. wpnData.name .. "': X: " .. string.format("%.0f", explosionPoint.x) .. ", Y: " .. string.format("%.0f", explosionPoint.y) .. ", Z: " .. string.format("%.0f", explosionPoint.z) .. ")")
                        end
                        local base_explosive, isShapedCharge = getWeaponExplosive(wpnData.name)
                        base_explosive = base_explosive * splash_damage_options.overall_scaling
                        if splash_damage_options.rocket_multiplier and wpnData.cat == Weapon.Category.ROCKET then
                            base_explosive = base_explosive * splash_damage_options.rocket_multiplier
                        end
                        if wpnData.isGroundUnitOrdnance and splash_damage_options.track_groundunitordnance then
                            base_explosive = base_explosive * splash_damage_options.groundunitordnance_damage_modifier
                            if splash_damage_options.track_groundunitordnance_debug then
                                debugMsg("Applying ground unit ordnance damage modifier " .. splash_damage_options.groundunitordnance_damage_modifier .. " to " .. wpnData.name .. ", base explosive power: " .. base_explosive)
                            end
                        end

                        local explosionPower = base_explosive
                        if splash_damage_options.apply_shaped_charge_effects and isShapedCharge then
                            explosionPower = explosionPower * splash_damage_options.shaped_charge_multiplier
                        end
                        local blastRadius = splash_damage_options.blast_search_radius * 2 --Wider post-scan (180m default)
                        if splash_damage_options.use_dynamic_blast_radius then
                            blastRadius = math.pow(explosionPower, 1/3) * 10 * splash_damage_options.dynamic_blast_radius_modifier
                        end
                        --Store pre-explosion state of all tracked weapons for detection
                        local preExplosionWeapons = {}
                        if splash_damage_options.ordnance_protection and splash_damage_options.detect_ordnance_destruction and splash_damage_options.larger_explosions then
                            for id, data in pairs(tracked_weapons) do
                                local otherWeaponPos = safeGet(function() return data.wpn:getPosition().p end, nil)
                                if safeGet(function() return data.wpn:isExist() end, false) and otherWeaponPos then
                                    preExplosionWeapons[id] = {
                                        name = data.name,
                                        pos = otherWeaponPos,
                                        distance = getDistance3D(explosionPoint, otherWeaponPos),
                                        explosive = getWeaponExplosive(data.name) --Store the explosive power
                                    }
                                end
                            end
                        end
                        --Cluster Bomb Handling
                        local weaponData = explTable[wpnData.name] or { explosive = 0, shaped_charge = false, Skip_larger_explosions = false, Skip_damage_model = false }
                        local isCluster = weaponData.cluster or false
                        if splash_damage_options.cluster_enabled and isCluster then
                            local submunitionCount = weaponData.submunition_count or 30
                            local submunitionPower = (weaponData.submunition_explosive or 1) * splash_damage_options.cluster_bomblet_damage_modifier * splash_damage_options.overall_scaling
                            local submunitionName = weaponData.submunition_name or "unknown"
                            --Apply bomblet reduction logic if enabled
                            if splash_damage_options.cluster_bomblet_reductionmodifier then
                                if submunitionCount > 35 then  
                                    local reductionFactor = (60 - 35) / (247 - 35)
                                    submunitionCount = 35 + math.floor((submunitionCount - 35) * reductionFactor)
                                    if submunitionCount > 60 then submunitionCount = 60 end --Cap at 60
                                end
                            end
                            --Extended scan with general bomblet detection
                            timer.scheduleFunction(track_wpns_cluster_scan, {explosionPoint, wpnData.dir, wpnData.name, submunitionName, submunitionCount, submunitionPower, wpnData.speed}, timer.getTime() + 0.3)
                        else
                            --Standard explosion handling
                            if splash_damage_options.larger_explosions and not (weaponData.Skip_larger_explosions or false) then
                                if splash_damage_options.debug then
                                    debugMsg("Triggering initial explosion for '" .. wpnData.name .. "' at power " .. explosionPower)
                                end
                                trigger.action.explosion(explosionPoint, explosionPower)
                                table.insert(recentExplosions, { pos = explosionPoint, time = timer.getTime(), radius = blastRadius })
                                if splash_damage_options.debug then
                                    debugMsg("Added to recentExplosions for '" .. wpnData.name .. "': X: " .. explosionPoint.x .. ", Y: " .. explosionPoint.y .. ", Z: " .. explosionPoint.z .. ", Time: " .. timer.getTime())
                                end
                                --Check for units destroyed by initial explosion
                                local playerName = wpnData.init or "unknown"
                                for _, target in ipairs(chosenTargets) do
                                    if target.unit:isExist() and target.health > 0 and target.unit:getLife() <= 0 then
                                        if splash_damage_options.debug then
                                            debugMsg("Unit " .. target.name .. " destroyed by initial explosion, credited to player: " .. playerName)
                                        end
                                    end
                                end
                            elseif splash_damage_options.debug and (weaponData.Skip_larger_explosions or false) then
                                debugMsg("Skipped larger explosion for '" .. wpnData.name .. "' due to Skip_larger_explosions = true")
                            end
                            if not (weaponData.Skip_damage_model or false) then
                                blastWave(explosionPoint, splash_damage_options.blast_search_radius, wpnData.name, explosionPower, isShapedCharge)
                            elseif splash_damage_options.debug then
                                debugMsg("Skipped damage model for '" .. wpnData.name .. "' due to Skip_damage_model = true")
                            end
                        end
                        --detect_ordnance_destruction comes before recent_large_explosion_snap in original
                        if splash_damage_options.ordnance_protection and splash_damage_options.detect_ordnance_destruction and splash_damage_options.larger_explosions and not (weaponData.Skip_larger_explosions or false) then
                            timer.scheduleFunction(function(args)
                                local explosionPoint = args[1]
                                local blastRadius = args[2]
                                local triggeringWeapon = args[3]
                                local preExplosionWeapons = args[4]
                                for id, preData in pairs(preExplosionWeapons) do
                                    local trackedWeapon = tracked_weapons[id]
                                    if trackedWeapon and not safeGet(function() return trackedWeapon.wpn:isExist() end, false) then
                                        if preData.distance <= blastRadius then
                                            local msg = "WARNING: " .. preData.name .. " destroyed by large explosion from " .. triggeringWeapon .. " at " .. string.format("X: %.0f, Y: %.0f, Z: %.0f", explosionPoint.x, explosionPoint.y, explosionPoint.z)
                                            gameMsg(msg)
                                            if splash_damage_options.debug then
                                                debugMsg(msg)
                                            end
                                            env.info(msg)
                                            if splash_damage_options.snap_to_ground_if_destroyed_by_large_explosion then
                                                local groundPos = {
                                                    x = preData.pos.x,
                                                    y = land.getHeight({x = preData.pos.x, y = preData.pos.z}),
                                                    z = preData.pos.z
                                                }
                                                local destroyedWeaponPower, isShapedCharge = preData.explosive
                                                destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.overall_scaling
                                                if splash_damage_options.rocket_multiplier and tracked_weapons[id].cat == Weapon.Category.ROCKET then
                                                    destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.rocket_multiplier
                                                end
                                                if splash_damage_options.apply_shaped_charge_effects and isShapedCharge then
                                                    destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.shaped_charge_multiplier
                                                end
                                                if splash_damage_options.debug then
                                                    debugMsg("Triggering ground explosion for destroyed " .. preData.name .. " (detect_ordnance_destruction) at X: " .. string.format("%.0f", groundPos.x) .. ", Y: " .. string.format("%.0f", groundPos.y) .. ", Z: " .. string.format("%.0f", groundPos.z) .. " with power " .. destroyedWeaponPower)
                                                end
                                                trigger.action.explosion(groundPos, destroyedWeaponPower)
                                            end
                                        end
                                    end
                                end
                            end, {explosionPoint, blastRadius, wpnData.name, preExplosionWeapons}, timer.getTime() + 0.2)
                        end
                        --recent_large_explosion_snap comes after main explosion and detect_ordnance_destruction
                        if splash_damage_options.ordnance_protection and splash_damage_options.larger_explosions and splash_damage_options.recent_large_explosion_snap and splash_damage_options.snap_to_ground_if_destroyed_by_large_explosion and not (weaponData.Skip_larger_explosions or false) then
                            local currentTime = timer.getTime()
                            for id, data in pairs(tracked_weapons) do
                                if id ~= wpn_id_ and not safeGet(function() return data.wpn:isExist() end, false) then
                                    local terrainHeight = land.getHeight({x = data.pos.x, y = data.pos.z})
                                    local weaponHeight = data.pos.y - terrainHeight --Calculate height above ground
                                    local isMidAir = weaponHeight > 5 --Still checks if above ground
                                    local snapTriggered = false
                                    for _, explosion in ipairs(recentExplosions) do
                                        local timeDiff = currentTime - explosion.time
                                        local distance = getDistance3D(data.pos, explosion.pos)
                                        if splash_damage_options.debug then
                                            debugMsg("Checking " .. data.name .. " at X: " .. data.pos.x .. ", Y: " .. data.pos.y .. ", Z: " .. data.pos.z .. " against explosion at X: " .. explosion.pos.x .. ", Y: " .. explosion.pos.y .. ", Z: " .. explosion.pos.z .. " - Distance: " .. distance .. "m, TimeDiff: " .. timeDiff .. "s")
                                        end
                                        if timeDiff <= splash_damage_options.recent_large_explosion_time and distance <= splash_damage_options.recent_large_explosion_range then
                                            if isMidAir and weaponHeight <= splash_damage_options.max_snapped_height then --New height check
                                                local groundPos = { x = data.pos.x, y = terrainHeight, z = data.pos.z }
                                                local destroyedWeaponPower, isShapedCharge = getWeaponExplosive(data.name)
                                                destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.overall_scaling
                                                if splash_damage_options.rocket_multiplier and data.cat == Weapon.Category.ROCKET then
                                                    destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.rocket_multiplier
                                                end
                                                if splash_damage_options.apply_shaped_charge_effects and isShapedCharge then
                                                    destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.shaped_charge_multiplier
                                                end
                                                if splash_damage_options.debug then
                                                    debugMsg("Weapon " .. data.name .. " detected recent large explosion within " .. splash_damage_options.recent_large_explosion_range .. "m and " .. splash_damage_options.recent_large_explosion_time .. "s, snapping to ground at X: " .. string.format("%.0f", groundPos.x) .. ", Y: " .. string.format("%.0f", groundPos.y) .. ", Z: " .. string.format("%.0f", groundPos.z) .. " with power " .. destroyedWeaponPower .. " (Height: " .. string.format("%.0f", weaponHeight) .. "m)")
                                                end
                                                trigger.action.explosion(groundPos, destroyedWeaponPower)
                                                snapTriggered = true
                                                table.insert(weaponsToRemove, id)
                                                break
                                            elseif isMidAir then
                                                if splash_damage_options.debug then
                                                    debugMsg("Weapon " .. data.name .. " destroyed above max_snapped_height (" .. splash_damage_options.max_snapped_height .. "m) at " .. string.format("%.0f", weaponHeight) .. "m, skipping snap")
                                                end
                                            else
                                                if splash_damage_options.debug then
                                                    debugMsg("Weapon " .. data.name .. " impacted ground within recent_large_explosion_range (" .. splash_damage_options.recent_large_explosion_range .. "m) and time (" .. splash_damage_options.recent_large_explosion_time .. "s), no snap needed")
                                                end
                                                snapTriggered = true
                                                break
                                            end
                                        end
                                    end
                                    if not snapTriggered then
                                        if isMidAir then
                                            if splash_damage_options.debug then
                                                debugMsg("Weapon " .. data.name .. " destroyed in air, but no recent large explosion within " .. splash_damage_options.recent_large_explosion_range .. "m or " .. splash_damage_options.recent_large_explosion_time .. "s")
                                            end
                                        else
                                            if splash_damage_options.debug then
                                                debugMsg("Weapon " .. data.name .. " impacted ground, not processed by recent large explosion settings")
                                            end
                                        end
                                    end
                                end
                            end
                            local newExplosions = {}
                            for _, explosion in ipairs(recentExplosions) do
                                if currentTime - explosion.time <= splash_damage_options.recent_large_explosion_time then
                                    table.insert(newExplosions, explosion)
                                end
                            end
                            recentExplosions = newExplosions
                        end
                        --Mark units as destroyed to avoid MiST accessing them
                        local destroyedUnits = {}
                        for _, target in ipairs(chosenTargets) do
                            if target.unit:isExist() and target.health > 0 and target.unit:getLife() <= 0 then
                                destroyedUnits[target.name] = true
                                if splash_damage_options.debug then
                                    debugMsg("Marked " .. target.name .. " as destroyed pre-impact")
                                end
                            end
                        end
                        --Schedule explosion handling with original 0.1-second delay, enhanced error handling
                        timer.scheduleFunction(function(args)
                            local finalPos = args[1]
                            local explosionPoint = args[2]
                            local explosionPower = args[3]
                            local isShapedCharge = args[4]
                            local blastRadius = args[5]
                            local chosenTargets = args[6]
                            local weaponName = args[7]
                            local wpnData = args[8]
                            if splash_damage_options.debug then
                                debugMsg("Starting impact handling for " .. weaponName .. " at " .. timer.getTime() .. "s")
                            end
                            local status, err = pcall(function()
                                --Log pre-explosion targets
                                --Sort pre-explosion targets by distance
                                table.sort(chosenTargets, function(a, b) return a.distance < b.distance end)
                                if splash_damage_options.track_pre_explosion then
                                    if #chosenTargets > 0 then
                                        local msg = "Targets in blast zone for " .. weaponName .. " BEFORE explosion (last frame, using finalPos):\n"
                                        for i, target in ipairs(chosenTargets) do
                                            msg = msg .. "- " .. target.name .. " (ID: " .. target.id .. ", Dist: " .. string.format("%.1f", target.distance) .. "m, Health: " .. target.health .. ")\n"
                                        end
                                        if splash_damage_options.debug then
                                            debugMsg(msg)
                                            env.info("SplashDamage Pre-Explosion (Last Frame): " .. msg)
                                        end
                                    else
                                        if splash_damage_options.debug then
                                            debugMsg("No targets in blast zone for " .. weaponName .. " BEFORE explosion (last frame)")
                                            env.info("SplashDamage Pre-Explosion (Last Frame): No targets in blast zone for " .. weaponName)
                                        end
                                    end
                                end
                                if not (weaponData.Skip_damage_model or false) then
                                    blastWave(explosionPoint, splash_damage_options.blast_search_radius, wpnData.name, explosionPower, isShapedCharge)
                                elseif splash_damage_options.debug then
                                    debugMsg("Skipped damage model for '" .. wpnData.name .. "' due to Skip_damage_model = true in scheduled explosion handling")
                                end
                                --Post-explosion analysis
                                if splash_damage_options.track_pre_explosion then
                                    timer.scheduleFunction(function(innerArgs)
                                        local impactPoint = innerArgs[1]
                                        local blastRadius = innerArgs[2]
                                        local preExplosionTargets = innerArgs[3] or {}
                                        local weaponName = innerArgs[4]
                                        local weaponPower = innerArgs[5]
                                        local playerName = innerArgs[6]
                                        if splash_damage_options.debug then
                                            debugMsg("Starting post-explosion analysis for " .. weaponName .. " at " .. timer.getTime() .. "s")
                                        end
                                        --Scan all units in wider radius
                                        local postExplosionTargets = {}
                                        local volS = {
                                            id = world.VolumeType.SPHERE,
                                            params = {
                                                point = impactPoint,
                                                radius = blastRadius
                                            }
                                        }
                                        local ifFound = function(foundObject)
                                            if foundObject:isExist() then
                                                local category = foundObject:getCategory()
                                                if (category == Object.Category.UNIT and (foundObject:getDesc().category == Unit.Category.GROUND_UNIT or foundObject:getDesc().category == Unit.Category.AIRPLANE)) or
                                                   category == Object.Category.STATIC then
                                                    local distance = getDistance(impactPoint, foundObject:getPoint())
                                                    table.insert(postExplosionTargets, {
                                                        name = foundObject:getTypeName(),
                                                        health = foundObject:getLife() or 0,
                                                        position = foundObject:getPoint(),
                                                        maxHealth = (category == Object.Category.UNIT and foundObject:getDesc().life) or foundObject:getLife() or 0,
                                                        distance = distance,
                                                        id = foundObject:getID(),
                                                        unitName = foundObject:getName() or "Unknown",
                                                        unit = foundObject
                                                    })
                                                end
                                            end
                                            return true
                                        end
                                        world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, volS, ifFound)
                                        --Sort post-explosion targets by distance
                                        table.sort(postExplosionTargets, function(a, b) return a.distance < b.distance end)
                                        local msg = "Post-explosion analysis for " .. weaponName .. ":\n"
                                        --Match pre-detected units
                                        for _, preTarget in ipairs(preExplosionTargets) do
                                            local found = false
                                            local postHealth = 0
                                            local postPosition = nil
                                            local postDistance = 0
                                            local postUnit = nil
                                            local postId = nil
                                            local postUnitName = nil
                                            for _, postTarget in ipairs(postExplosionTargets) do
                                                if preTarget.name == postTarget.name and getDistance(preTarget.position, postTarget.position) < 1 then
                                                    found = true
                                                    postHealth = postTarget.health
                                                    postPosition = postTarget.position
                                                    postDistance = postTarget.distance
                                                    postUnit = postTarget.unit
                                                    postId = postTarget.id
                                                    postUnitName = postTarget.unitName
                                                    break
                                                end
                                            end
                                            local healthPercent = preTarget.maxHealth > 0 and (postHealth / preTarget.maxHealth * 100) or 0
                                            local status = ""
                                            local wasFullyDestroyed = not found or postHealth <= 0
                                            if wasFullyDestroyed then
                                                status = "WAS FULLY DESTROYED"
                                            elseif healthPercent < splash_damage_options.cargo_damage_threshold then
                                                status = "WAS DAMAGED BELOW THRESHOLD"
                                                -- Trigger effects for units below threshold if in cargoUnits
                                                if splash_damage_options.enable_cargo_effects and not processedCookoffs[preTarget.id] and cargoUnits[preTarget.name] then
                                                    markProcessedCookoff(preTarget.id)
                                                    debugCargoCookOff("Track_WPNs: Added unit ID " .. preTarget.id .. " to processedCookoffs, triggering effects")
                                                    if not CargoCookoffPendingTable[preTarget.id] then
                                                        CargoCookoffPendingTable[preTarget.id] = {
                                                            id = preTarget.id,
                                                            name = preTarget.unitName,
                                                            type = preTarget.name,
                                                            coords = preTarget.position,
                                                            prevCoords = preTarget.position,
                                                            unit = preTarget.unit,
                                                            startTime = timer.getTime(),
                                                            isCargoCookoff = true,
                                                            isDead = postHealth <= 0
                                                        }
                                                        debugCargoCookOff("Track_WPNs: Added unit ID " .. preTarget.id .. " to CargoCookoffPendingTable")
                                                    end
                                                    scheduleCargoEffects(preTarget.name, preTarget.unitName, preTarget.id, 0)
                                                end
                                            else
                                                status = "SURVIVED (Health: " .. postHealth .. ")"
                                            end
                                            --Killfeed logic
                                            if wasFullyDestroyed and splash_damage_options.killfeed_enable and explTable[weaponName] and isConnectedPlayerName(playerName) then
                                                addSplashKillTempEntry({
                                                        playerName = playerName,
                                                        weaponName = weaponName,
                                                        unitName = preTarget.unitName,
                                                        unitType = preTarget.name,
                                                        unitId = preTarget.id,
                                                        time = timer.getTime(),
                                                        position = postPosition or preTarget.position,
                                                        statName = preTarget.statName,
                                                        points = preTarget.points
                                                    }, preTarget.unit)
                                            end
                                            local coords = found and postPosition or preTarget.position
                                            msg = msg .. "- " .. preTarget.name .. " (ID: " .. preTarget.id .. ") " .. status .. " AT " .. string.format("X: %.0f, Y: %.0f, Z: %.0f", coords.x, coords.y, coords.z) .. " (Dist: " .. string.format("%.1f", postDistance) .. "m, Pre: " .. preTarget.health .. ", Post: " .. postHealth .. ")\n"
                                        end
                                        --Check for additional units
                                        for _, postTarget in ipairs(postExplosionTargets) do
                                            local isPreDetected = false
                                            for _, preTarget in ipairs(preExplosionTargets) do
                                                if preTarget.name == postTarget.name and getDistance(preTarget.position, postTarget.position) < 1 then
                                                    isPreDetected = true
                                                    break
                                                end
                                            end
                                            if not isPreDetected then
                                                local coords = postTarget.position
                                                local healthPercent = postTarget.maxHealth > 0 and (postTarget.health / postTarget.maxHealth * 100) or 0
                                               local status = postTarget.health <= 0 and "WAS FULLY DESTROYED" or 
                                                              (healthPercent < splash_damage_options.cargo_damage_threshold and "WAS DAMAGED BELOW THRESHOLD" or 
                                                              "SURVIVED (Health: " .. postTarget.health .. ")")
                                                -- Trigger effects for new units below threshold if in cargoUnits
                                                if splash_damage_options.enable_cargo_effects and status == "WAS DAMAGED BELOW THRESHOLD" and not processedCookoffs[postTarget.id] and cargoUnits[postTarget.name] then
                                                    markProcessedCookoff(postTarget.id)
                                                    debugCargoCookOff("Track_WPNs: Added unit ID " .. postTarget.id .. " to processedCookoffs, triggering effects")
                                                    if not CargoCookoffPendingTable[postTarget.id] then
                                                        CargoCookoffPendingTable[postTarget.id] = {
                                                            id = postTarget.id,
                                                            name = postTarget.unitName,
                                                            type = postTarget.name,
                                                            coords = postTarget.position,
                                                            prevCoords = postTarget.position,
                                                            unit = postTarget.unit,
                                                            startTime = timer.getTime(),
                                                            isCargoCookoff = true,
                                                            isDead = postTarget.health <= 0
                                                        }
                                                        debugCargoCookOff("Added unit ID " .. postTarget.id .. " to CargoCookoffPendingTable")
                                                    end
                                                    scheduleCargoEffects(postTarget.name, postTarget.unitName, postTarget.id, 0)
                                                end
                                                msg = msg .. "- " .. postTarget.name .. " " .. status .. " AT " .. string.format("X: %.0f, Y: %.0f, Z: %.0f", coords.x, coords.y, coords.z) .. " (Dist: " .. string.format("%.1f", postTarget.distance) .. "m, Pre: Unknown, Post: " .. postTarget.health .. ")\n"
                                            end
                                        end
                                        if splash_damage_options.debug then
                                            debugMsg(msg)
                                            env.info("SplashDamage Post-Explosion: " .. msg)
                                        end
                                        --Schedule splashKillFeed if there are entries
                                        if #splashKillfeedTemp > 0 and splash_damage_options.killfeed_enable then
                                            timer.scheduleFunction(splashKillFeed, {}, timer.getTime() + splash_damage_options.killfeed_splashdelay)
                                        end
                                    end, {finalPos, blastRadius, chosenTargets, weaponName, explosionPower, wpnData.init}, timer.getTime() + 1)
                                end
                            end)
                            if not status then
                                if splash_damage_options.debug then
                                    debugMsg("Impact handling error for '" .. weaponName .. "': " .. err)
                                end
                            end
                        end, {explosionPoint, explosionPoint, explosionPower, isShapedCharge, blastRadius, chosenTargets, wpnData.name, wpnData}, timer.getTime() + 0.1)
                    else
                        if splash_damage_options.debug then
                            debugMsg("Explosion skipped due to ordnance protection for '" .. wpnData.name .. "'")
                        end
                        if splash_damage_options.larger_explosions and not (weaponData.Skip_larger_explosions or false) then
                            table.insert(recentExplosions, { pos = explosionPoint, time = timer.getTime(), radius = blastRadius })
                            if splash_damage_options.debug then
                                debugMsg("Skipped explosion logged for snap check for '" .. wpnData.name .. "': X: " .. explosionPoint.x .. ", Y: " .. explosionPoint.y .. ", Z: " .. explosionPoint.z .. ", Time: " .. timer.getTime())
                            end
                        elseif splash_damage_options.debug then
                            debugMsg("Skipped recentExplosions logging for '" .. wpnData.name .. "' due to Skip_larger_explosions = true")
                        end
                    end
                    table.insert(weaponsToRemove, wpn_id_) -- Ensure removal even if safeToBlast is false
                end
                table.insert(weaponsToRemove, wpn_id_) -- Ensure removal after processing impact
            end
        end
    end
    --Perform all removals after iteration
    for _, id in ipairs(weaponsToRemove) do
        tracked_weapons[id] = nil
    end
    return timer.getTime() + refreshRate
end



function onWpnEvent(event)
    if event.id == world.event.S_EVENT_SHOT then
        if event.weapon then
            local ordnance = event.weapon
            --verify isExist and getDesc
            local isValid = false
            local status, desc = pcall(function() return ordnance:isExist() and ordnance:getDesc() end)
            if status and desc then
                isValid = true
            end
            if not isValid then
                if splash_damage_options.debug then
                    env.info("SplashDamage: Invalid weapon object in S_EVENT_SHOT")
                    debugMsg("Invalid weapon object in S_EVENT_SHOT")
                end
                return
            end
            --Safely get typeName with pcall
            local status, typeName = pcall(function() return trim(ordnance:getTypeName()) end)
            if not status or not typeName then
                if splash_damage_options.debug then
                    env.info("SplashDamage: Failed to get weapon typeName: " .. tostring(typeName))
                    debugMsg("Failed to get weapon typeName: " .. tostring(typeName))
                end
                return
            end

            local playerName = "Unknown"
            if event.initiator then
                playerName = resolvePlayerName(event.initiator)
            end
            if splash_damage_options.debug then
                env.info("Weapon [" .. typeName .. "] fired by player " .. playerName)
                debugMsg("Weapon [" .. typeName .. "] fired by player " .. playerName)
            end
            --Skip non-player weapons if only_players_weapons is enabled
            if splash_damage_options.only_players_weapons and playerName == "Unknown" then
                if splash_damage_options.debug then
                    env.info("SplashDamage: Skipping non-player weapon [" .. typeName .. "]")
                    debugMsg("Skipping non-player weapon [" .. typeName .. "]")
                end
                return
            end
		local isNapalm = false
		if splash_damage_options.napalmoverride_enabled then
			local napalmWeapons = {}
			for weapon in splash_damage_options.napalm_override_weapons:gmatch("[^,]+") do
				napalmWeapons[trim(weapon)] = true
			end
			if napalmWeapons[typeName] then
				isNapalm = true
				if splash_damage_options.debug then
					debugMsg("Tracking napalm override weapon: [" .. typeName .. "]")
				end
			end
		end
		if splash_damage_options.napalm_mk77_enabled and (typeName == "MK77mod0-WPN" or typeName == "MK77mod1-WPN") then
			isNapalm = true
			if splash_damage_options.debug then
				debugMsg("Tracking MK77 napalm weapon: [" .. typeName .. "]")
			end
		end
		if isNapalm then
			tracked_weapons[event.weapon.id_] = { 
				wpn = ordnance, 
                    init = playerName, 
				pos = ordnance:getPoint(), 
				dir = ordnance:getPosition().x, 
				name = typeName, 
				speed = ordnance:getVelocity(), 
				cat = ordnance:getCategory()
			}
			return
		end
            --Debug the exact typeName and explTable lookup
            if splash_damage_options.debug then
                debugMsg("Checking explTable for typeName: [" .. typeName .. "]")
            end
            local weaponData = explTable[typeName]
            if splash_damage_options.debug then
            if weaponData then
                    debugMsg("Found in explTable: explosive=" .. weaponData.explosive .. ", groundordnance=" .. tostring(weaponData.groundordnance))
                else
                    debugMsg("Not found in explTable: [" .. typeName .. "]")
                end
            end
                --Handle ground ordnance explicitly
            if weaponData and weaponData.groundordnance then
                if splash_damage_options.track_groundunitordnance then
                    --Count tracked ground ordnance
                    local groundOrdnanceCount = 0
                    for _, wpnData in pairs(tracked_weapons) do
                        if wpnData.isGroundUnitOrdnance then
                            groundOrdnanceCount = groundOrdnanceCount + 1
                        end
                    end
                    if groundOrdnanceCount >= splash_damage_options.groundunitordnance_maxtrackedcount then
                        if splash_damage_options.debug then
                            debugMsg("Skipping tracking for " .. typeName .. ": ground ordnance limit reached (" .. groundOrdnanceCount .. "/" .. splash_damage_options.groundunitordnance_maxtrackedcount .. ")")
                            env.info("SplashDamage: Skipping tracking for " .. typeName .. ": ground ordnance limit reached (" .. groundOrdnanceCount .. "/" .. splash_damage_options.groundunitordnance_maxtrackedcount .. ")")
                        end
                        return
                    end
                    if splash_damage_options.track_groundunitordnance_debug then
                        debugMsg("Tracking ground unit ordnance: " .. typeName .. " fired by " .. (event.initiator and event.initiator:getTypeName() or "unknown"))
                        env.info("SplashDamage: Tracking ground unit ordnance: " .. typeName .. " (" .. (event.initiator and event.initiator:getTypeName() or "no initiator") .. ")")
                    end
                    tracked_weapons[event.weapon.id_] = { 
                        wpn = ordnance, 
                        init = playerName, 
                        pos = ordnance:getPoint(), 
                        dir = ordnance:getPosition().x, 
                        name = typeName, 
                        speed = ordnance:getVelocity(), 
                        cat = ordnance:getCategory(),
                        isGroundUnitOrdnance = true --Flag for ground ordnance
                    }
                elseif splash_damage_options.track_groundunitordnance_debug then
                    debugMsg("Event shot, but not tracking ground unit ordnance: " .. typeName)
                    env.info("SplashDamage: event shot, but not tracking ground unit ordnance: " .. typeName .. " (" .. (event.initiator and event.initiator:getTypeName() or "no initiator") .. ")")
                end
                return
            end
            --Handle other tracked weapons in explTable
            if weaponData then
                if (ordnance:getDesc().category ~= 0) and event.initiator then
                    if ordnance:getDesc().category == 1 then --Missiles
                        if (ordnance:getDesc().MissileCategory ~= 1 and ordnance:getDesc().MissileCategory ~= 2) then --Exclude AAM and SAM
                            tracked_weapons[event.weapon.id_] = { 
                                wpn = ordnance, 
                                init = playerName, 
                                pos = ordnance:getPoint(), 
                                dir = ordnance:getPosition().x, 
                                name = typeName, 
                                speed = ordnance:getVelocity(), 
                                cat = ordnance:getCategory() 
                            }
                        end
                    else --Rockets, bombs, etc.
                        tracked_weapons[event.weapon.id_] = { 
                            wpn = ordnance, 
                            init = playerName, 
                            pos = ordnance:getPoint(), 
                            dir = ordnance:getPosition().x, 
                            name = typeName, 
                            speed = ordnance:getVelocity(), 
                            cat = ordnance:getCategory() 
                        }
                    end
                end
                return --Exit after handling known weapons
            end
            --Handle unknown weapons or non-tracked shells
                if string.find(typeName, "weapons.shells") then 
                if splash_damage_options.debug then
                    debugMsg("Event shot, but not tracking: " .. typeName)
                    env.info("SplashDamage: event shot, but not tracking: " .. typeName .. " (" .. (event.initiator and event.initiator:getTypeName() or "no initiator") .. ")")
		end
                    return
                end

            --Log missing weapons
            env.info("SplashDamage: " .. typeName .. " missing from script (" .. (event.initiator and event.initiator:getTypeName() or "no initiator") .. ")")
            if splash_damage_options.weapon_missing_message then
                        trigger.action.outText("SplashDamage: " .. typeName .. " missing from script (" .. (event.initiator and event.initiator:isExist() and event.initiator:getTypeName() or "no initiator") .. ")", 3)
                        env.info("Current keys in explTable:")
                        for k, v in pairs(explTable) do
                            env.info("Key: [" .. k .. "]")
                end
  
                    end
                end
            end
        end



function splashKillFeed()
    if not splash_damage_options.killfeed_enable then return end

    local tempTable = splashKillfeedTemp
    local processedBatch = {}
    local currentTime = timer.getTime()
    splashKillfeedTemp = {}
    splashKillfeedTempByUnitId = {}

    pruneKillfeedEntries(currentTime)

    for _, entry in ipairs(tempTable) do
        local unitId = entry.unitId
        local unitType = entry.unitType
        local playerName = entry.playerName
        local weaponName = entry.weaponName

        if unitType == "Unknown" then
            if splash_damage_options.killfeed_debug then
                env.info(string.format("SplashKillFeed: Skipped unit ID %s with unknown type at %.2f", unitId, currentTime))
            end
        elseif processedBatch[unitId] then
            if splash_damage_options.killfeed_debug then
                env.info(string.format("SplashKillFeed: Skipped duplicate splash kill in batch for unit ID %s (%s) by %s with %s at %.2f",
                    unitId, unitType, playerName, weaponName, currentTime))
            end
        else
            processedBatch[unitId] = true

            local object = Unit.getByName(entry.unitName) or StaticObject.getByName(entry.unitName)
            local unitExists = object and safeGet(function() return object:isExist() end, false)
            local unitLife = object and object.getLife and safeGet(function() return object:getLife() end, 0) or 0
            if unitExists and unitLife >= 1 then
                if splash_damage_options.killfeed_debug then
                    env.info(string.format("SplashKillFeed: Unit ID %s (%s) still alive (life=%.2f), skipping splash kill at %.2f",
                        unitId, unitType, unitLife, currentTime))
                end
            else
                local killEntry = killfeedByUnitId[unitId]
                local shouldAddSplashEntry = true

                if killEntry then
                    if killEntry.killer == "Unknown" and playerName ~= "Unknown" then
                        removeKillfeedEntryByUnitId(unitId)
                        if splash_damage_options.killfeed_debug then
                            env.info(string.format("SplashKillFeed: Replaced Unknown killfeed entry for unit ID %s (%s) with splash kill by %s at %.2f",
                                unitId, unitType, playerName, currentTime))
                        end
                    else
                        shouldAddSplashEntry = false
                        if splash_damage_options.killfeed_debug then
                            env.info(string.format("SplashKillFeed: Direct killfeed already recorded unit ID %s (%s), skipping splash attribution at %.2f",
                                unitId, unitType, currentTime))
                        end
                    end
                end

                if shouldAddSplashEntry then
                    if splashKillfeedByUnitId[unitId] then
                        if splash_damage_options.killfeed_debug then
                            env.info(string.format("SplashKillFeed: Skipped duplicate splash kill for unit ID %s (%s) by %s with %s at %.2f",
                                unitId, unitType, playerName, weaponName, currentTime))
                        end
                    else
                        entry.time = currentTime
                        addSplashKillEntry(entry)
                        if splash_damage_options.killfeed_game_messages then
                            local msg = string.format("%s destroyed by %s's %s Splash Damage", unitType, playerName, weaponName)
                            trigger.action.outTextForCoalition(2, msg, splash_damage_options.killfeed_game_message_duration)
                        end
                        if splash_damage_options.killfeed_debug then
                            env.info(string.format("SplashKillFeed: %s destroyed by %s's %s Splash Damage [ID: %s] at %.2f",
                                unitType, playerName, weaponName, unitId, currentTime))
                        end
                    end
                end
            end
        end
    end
end


local function processSplashKillfeed()
    if not splash_damage_options.killfeed_enable or not splash_damage_options.killfeed_lekas_foothold_integration then
        if splash_damage_options.killfeed_debug then
            env.info("SplashDamage: processSplashKillfeed skipped")
        end
        return timer.getTime() + 60
    end

    local currentTime = timer.getTime()
    local processedCount = 0
    local nextDelay = #splashKillfeedTable > 0 and 5 or 60

    pruneKillfeedEntries(currentTime)

    if splash_damage_options.killfeed_debug then
        env.info("SplashDamage: processSplashKillfeed started at " .. string.format("%.2f", currentTime))
    end

    for i = #splashKillfeedTable, 1, -1 do
        local entry = splashKillfeedTable[i]
        if currentTime - entry.time >= splash_damage_options.killfeed_lekas_contribution_delay then
            local playerName = entry.playerName
            local unitId = entry.unitId
            local statName = entry.statName
            local points = entry.points

            if isFootholdRewardPlayer(playerName) and statName and points then
                bc:addTempStat(playerName, statName, 1)
                bc:addContribution(playerName, 2, points)
                processedCount = processedCount + 1
                if splash_damage_options.killfeed_debug then
                    env.info(string.format("SplashDamage: Processed splash kill for %s by %s: stat=%s, points=%d, unitId=%s",
                        entry.unitType, playerName, statName, points, unitId))
                end
            elseif splash_damage_options.killfeed_debug then
                env.info(string.format("SplashDamage: Skipped splash contribution for unitId=%s, player=%s, stat=%s, points=%s",
                    tostring(unitId), tostring(playerName), tostring(statName), tostring(points)))
            end
            removeSplashKillEntryByUnitId(unitId)
        end
    end

    if splash_damage_options.killfeed_debug then
        if bc.tempStats and type(bc.tempStats) == "table" then
            env.info("SplashDamage: tempStats contents:")
            for playerName, stats in pairs(bc.tempStats) do
                local statStr = ""
                for statKey, value in pairs(stats) do
                    statStr = statStr .. statKey .. "=" .. tostring(value) .. ", "
                end
                env.info("SplashDamage:   " .. playerName .. ": " .. (statStr ~= "" and statStr or "empty"))
            end
            if not next(bc.tempStats) then
                env.info("SplashDamage:   tempStats is empty")
            end
        else
            env.info("SplashDamage: bc.tempStats is nil or not a table")
        end
    end

    if splash_damage_options.killfeed_debug and processedCount > 0 then
        env.info("SplashDamage: Processed " .. processedCount .. " splash kills, remaining: " .. #splashKillfeedTable)
    end

    if #splashKillfeedTable == 0 then
        nextDelay = 60
    end

    return timer.getTime() + nextDelay
end

--Scan for Strobe units
local function scanStrobeUnits()
    strobeUnits = {}
    for coa = 0, 2 do
        local groups = coalition.getGroups(coa)
        if groups then
            for _, group in pairs(groups) do
                local units = group:getUnits()
                if units then
                    for _, unit in ipairs(units) do
                        if unit:isExist() then
                            local unitName = unit:getName()
                            if unitName:find("Strobe") then
                                table.insert(strobeUnits, { unit = unit, name = unitName, id = unit:getID() })
                                debugStrobeMarker("Found Strobe unit: " .. unitName .. " (ID: " .. unit:getID() .. ")")
                            end
                        end
                    end
                end
            end
        end
    end
    debugStrobeMarker("Total Strobe units found: " .. #strobeUnits)
end

--StrobeMarker function
local function triggerStrobeMarker()
    if not splash_damage_options.StrobeMarker_allstrobeunits then
        debugStrobeMarker("StrobeMarker disabled, skipping execution")
        return timer.getTime() + splash_damage_options.StrobeMarker_interval
    end

    local explosionPower = 0.000001 --Minimal explosion strength
    local heightOffset = 3 --Height above unit in meters

    for _, strobeData in ipairs(strobeUnits) do
        local unit = strobeData.unit
        local status, err = pcall(function()
            if unit:isExist() and unit:isActive() and not unit:getDesc().isInvisible then
                local life = unit:getLife() or 0
                if life > 0 then
                    local pos = unit:getPosition().p
                    pos.y = pos.y + heightOffset
					--[[pos.z = pos.z + heightOffset
					pos.x = pos.x + heightOffset]]--
                    debugStrobeMarker("Triggering explosion for unit " .. strobeData.name .. " (ID: " .. strobeData.id .. ") at X: " .. pos.x .. ", Y: " .. pos.y .. ", Z: " .. pos.z .. " with power " .. explosionPower)
                    trigger.action.explosion(pos, explosionPower)
				--[[	local pos = unit:getPosition().p
                    pos.y = pos.y + heightOffset
					pos.z = pos.z - heightOffset
					pos.x = pos.x - heightOffset
					trigger.action.explosion(pos, explosionPower)
					local pos = unit:getPosition().p
                    pos.y = pos.y + heightOffset
					pos.z = pos.z - heightOffset
					pos.x = pos.x + heightOffset
					trigger.action.explosion(pos, explosionPower)
					local pos = unit:getPosition().p
                    pos.y = pos.y + heightOffset
					pos.z = pos.z + heightOffset
					pos.x = pos.x - heightOffset
					trigger.action.explosion(pos, explosionPower)]]--
					
                else
                    debugStrobeMarker("Skipping unit " .. strobeData.name .. " (ID: " .. strobeData.id .. "): Unit is dead (life: " .. life .. ")")
                end
            else
                debugStrobeMarker("Skipping unit " .. strobeData.name .. " (ID: " .. strobeData.id .. "): Not exist, inactive, or invisible")
            end
        end)
        if not status then
            debugStrobeMarker("Error triggering explosion for unit " .. strobeData.name .. " (ID: " .. strobeData.id .. "): " .. tostring(err))
        end
    end

    return timer.getTime() + splash_damage_options.StrobeMarker_interval
end

--Function for individual unit strobing
local function triggerIndividualStrobe(unitId)
    local strobeData = individualStrobeUnits[unitId]
    if not strobeData or not strobeData.enabled then
        return timer.getTime() + (strobeData and strobeData.interval or splash_damage_options.StrobeMarker_interval)
    end

    local unit = strobeData.unit
    local status, err = pcall(function()
        if unit:isExist() and unit:isActive() and not unit:getDesc().isInvisible then
            local life = unit:getLife() or 0
            if life > 0 then
                local pos = unit:getPosition().p
                local explosionPower = 0.000001
                local heightOffset = 3
                pos.y = pos.y + heightOffset
                pos.z = pos.z + heightOffset
                pos.x = pos.x + heightOffset
                trigger.action.explosion(pos, explosionPower)
                pos = unit:getPosition().p
                pos.y = pos.y + heightOffset
                pos.z = pos.z - heightOffset
                pos.x = pos.x - heightOffset
                trigger.action.explosion(pos, explosionPower)
                pos = unit:getPosition().p
                pos.y = pos.y + heightOffset
                pos.z = pos.z - heightOffset
                pos.x = pos.x + heightOffset
                trigger.action.explosion(pos, explosionPower)
                pos = unit:getPosition().p
                pos.y = pos.y + heightOffset
                pos.z = pos.z + heightOffset
                pos.x = pos.x - heightOffset
                trigger.action.explosion(pos, explosionPower)
            end
        end
    end)
    if not status then
        debugStrobeMarker("Error triggering individual strobe for unit ID " .. unitId .. ": " .. tostring(err))
    end

    return timer.getTime() + strobeData.interval
end

--toggle individual strobe
local function toggleIndividualStrobe(args)
    local unitId, enable = args.unitId, args.enable
    if individualStrobeUnits[unitId] then
        individualStrobeUnits[unitId].enabled = enable
        if enable then
            timer.scheduleFunction(triggerIndividualStrobe, unitId, timer.getTime() + individualStrobeUnits[unitId].interval)
        end
        debugStrobeMarker("Strobe for unit ID " .. unitId .. " " .. (enable and "enabled" or "disabled"))
    end
end
--set individual strobe interval
local function setIndividualStrobeInterval(args)
    local unitId, interval = args.unitId, args.interval
    if individualStrobeUnits[unitId] then
        individualStrobeUnits[unitId].interval = interval
        if individualStrobeUnits[unitId].enabled then
            timer.scheduleFunction(triggerIndividualStrobe, unitId, timer.getTime() + interval)
        end
        debugStrobeMarker("Strobe interval for unit ID " .. unitId .. " set to " .. interval .. " seconds")
    end
end

--Create strobe radio menu
local function createStrobeRadioMenu()
    missionCommands.removeItem({"Strobe Control"})
    local mainMenu = missionCommands.addSubMenu("Strobe Control")

    --Scan for Strobe/Beacon units
    local strobeTargets = {}
    local function processObject(obj)
        if obj:isExist() then
            local name = obj:getName()
            if string.find(name:lower(), "strobe") or string.find(name:lower(), "beacon") then
                table.insert(strobeTargets, {name = name, id = obj:getID(), unit = obj})
                debugStrobeMarker("Found Strobe/Beacon unit: " .. name)
            end
        end
    end
    for coa = 0, 2 do
        local groups = coalition.getGroups(coa)
        if groups then
            for _, group in pairs(groups) do
                local units = group:getUnits()
                if units then
                    for _, unit in pairs(units) do
                        processObject(unit)
                    end
                end
            end
        end
        local statics = coalition.getStaticObjects(coa)
        if statics then
            for _, static in pairs(statics) do
                processObject(static)
            end
        end
    end

    if #strobeTargets == 0 then
        --("No Strobe or Beacon units found!")
        return
    end

    --Create menu for each found unit
    for _, target in ipairs(strobeTargets) do
        local unitId = target.id
        --Initialize individual strobe unit if not already
        if not individualStrobeUnits[unitId] then
            individualStrobeUnits[unitId] = {
                unit = target.unit,
                enabled = false,
                interval = splash_damage_options.StrobeMarker_interval,
            }
        end
        local unitMenu = missionCommands.addSubMenu(target.name, mainMenu)
        missionCommands.addCommand("Enable Strobe", unitMenu, toggleIndividualStrobe, {unitId = unitId, enable = true})
        missionCommands.addCommand("Disable Strobe", unitMenu, toggleIndividualStrobe, {unitId = unitId, enable = false})
        local intervalMenu = missionCommands.addSubMenu("Set Interval", unitMenu)
        for _, interval in ipairs({1, 2, 3, 5, 10}) do
            missionCommands.addCommand(interval .. " seconds", intervalMenu, setIndividualStrobeInterval, {unitId = unitId, interval = interval})
        end
    end
end

--Initialize individual strobe units
local function initIndividualStrobeUnits()
    individualStrobeUnits = {}
    for _, strobeData in ipairs(strobeUnits) do
        individualStrobeUnits[strobeData.id] = {
            unit = strobeData.unit,
            enabled = false,
            interval = splash_damage_options.StrobeMarker_interval,
        }
    end
end


--Function to trigger CriticalComponent explosion
function CriticalComponent(coords, weaponName, initiator, unitName, unitID, unitType)
    if not splash_damage_options.CriticalComponent then
        if splash_damage_options.CriticalComponent_debug then
            env.info("CriticalComponent: Disabled, skipping explosion at X: " .. (coords.x or "nil") .. ", Z: " .. (coords.z or "nil"))
        end
        return
    end
    if not coords or not coords.x or not coords.y or not coords.z then
        if splash_damage_options.CriticalComponent_debug then
            env.info("CriticalComponent: Invalid coordinates, skipping explosion")
        end
        return
    end
    if splash_damage_options.CriticalComponent_Specific_Weapons_Only and #splash_damage_options.CriticalComponent_Specific_Weapons_Only > 0 then
        local validWeapon = false
        for _, wpn in ipairs(splash_damage_options.CriticalComponent_Specific_Weapons_Only) do
            if weaponName == wpn then
                validWeapon = true
                break
            end
        end
        if not validWeapon then
            if splash_damage_options.CriticalComponent_debug then
                env.info("CriticalComponent: Weapon " .. (weaponName or "nil") .. " not in CriticalComponent_Specific_Weapons_Only, skipping")
            end
            return
        end
    end
    local chance = splash_damage_options.CriticalComponent_Chance or 0.1
    if math.random() >= chance then
        if splash_damage_options.CriticalComponent_debug then
            env.info("CriticalComponent: Chance check failed")
        end
        return
    end
    local explosionPower = splash_damage_options.CriticalComponent_Explosion_Power or 100
    if splash_damage_options.CriticalComponent_debug then
        env.info("CriticalComponent: Triggering explosion at X: " .. coords.x .. ", Y: " .. coords.y .. ", Z: " .. coords.z .. " with power " .. explosionPower .. " for unit " .. unitName .. " (ID: " .. unitID .. ")")
    end
    trigger.action.explosion(coords, explosionPower)

end

--Function to trigger A-10 Murder Mode explosion
function A10MurderMode(coords)
    if not splash_damage_options.A10MurderMode then
        if splash_damage_options.MurderMode_debug then
            env.info("A10MurderMode: Disabled, skipping explosion at X: " .. (coords.x or "nil") .. ", Z: " .. (coords.z or "nil"))
        end
        return
    end
    if not coords or not coords.x or not coords.y or not coords.z then
        if splash_damage_options.MurderMode_debug then
            env.info("A10MurderMode: Invalid coordinates, skipping explosion")
        end
        return
    end
    if splash_damage_options.MurderMode_debug then
        env.info("A10MurderMode: Triggering explosion at X: " .. coords.x .. ", Y: " .. coords.y .. ", Z: " .. coords.z .. " with power " .. splash_damage_options.A10MurderMode_Power)
    end
    trigger.action.explosion(coords, splash_damage_options.A10MurderMode_Power)
end

--Function to trigger Named Unit Murder Mode explosion
function NamedUnitMurderMode(coords)
    if not splash_damage_options.NamedUnitMurderMode then
        if splash_damage_options.MurderMode_debug then
            env.info("NamedUnitMurderMode: Disabled, skipping explosion at X: " .. (coords.x or "nil") .. ", Z: " .. (coords.z or "nil"))
        end
        return
    end
    if not coords or not coords.x or not coords.y or not coords.z then
        if splash_damage_options.MurderMode_debug then
            env.info("NamedUnitMurderMode: Invalid coordinates, skipping explosion")
        end
        return
    end
    if splash_damage_options.MurderMode_debug then
        env.info("NamedUnitMurderMode: Triggering explosion at X: " .. coords.x .. ", Y: " .. coords.y .. ", Z: " .. coords.z .. " with power " .. splash_damage_options.NamedUnitMurderMode_Power)
    end
    trigger.action.explosion(coords, splash_damage_options.NamedUnitMurderMode_Power)
end

--Function for CBU Bomblet Additional Explosion
function CBUBombletHitExplosion(coords, unitName, unitID, weaponName, weaponID, submunitionPower, initiator)
    if not splash_damage_options.CBU_Bomblet_Hit_Explosion then
        debugCBUBombletHit("CBUBomblet: Disabled, skipping explosion at X: " .. (coords.x or "nil") .. ", Z: " .. (coords.z or "nil") .. " for unit " .. unitName .. " (ID: " .. unitID .. ")")
        return
    end
    if not coords or not coords.x or not coords.y or not coords.z then
        debugCBUBombletHit("Invalid coordinates, skipping explosion for unit " .. unitName .. " (ID: " .. unitID .. ")")
        return
    end
    local explosionPower = (submunitionPower or 1) * splash_damage_options.CBU_Bomblet_Hit_Explosion_Scaling * splash_damage_options.overall_scaling
    local key = unitID .. "-" .. weaponID
    local explosionHeight = splash_damage_options.CBU_Bomblet_Explosion_Height or 1.6 --Default to 1.6m
    local adjustedCoords = { x = coords.x, y = land.getHeight({x = coords.x, z = coords.z}) + explosionHeight, z = coords.z }

    --Mimic spread if enabled
    if splash_damage_options.CBU_Bomblet_Hit_Mimic_Spread then
        local scanRadius = splash_damage_options.CBU_Bomblet_Hit_Spread
        local secondaryScanRadius = splash_damage_options.CBU_Bomblet_Hit_Spread_SecondaryScan or scanRadius
        local spreadDuration = splash_damage_options.CBU_Bomblet_Hit_Spread_Duration or 2
        local volS = {
            id = world.VolumeType.SPHERE,
            params = {
                point = adjustedCoords,
                radius = scanRadius
            }
        }
        local foundUnits = {}
        local seenUnitIDs = {} --Track unique unit IDs to avoid duplicates
        local ifFound = function(obj)
            local targetUnitID = safeGet(function() return obj:getID() end, "unavailable")
            local targetUnitName = safeGet(function() return obj:getName() end, "unknown")
            local targetUnitType = safeGet(function() return obj:getTypeName() end, "unknown")
            local targetCoords = safeGet(function() return obj:getPosition().p end, nil)
            local targetHealth = safeGet(function() return obj:getLife() end, 0)
            local targetAttrs = safeGet(function() return obj:getDesc().attributes end, {})
            local statName, points = getFootholdRewardDataForObject(obj)
            if targetUnitID ~= "unavailable" and targetCoords and not seenUnitIDs[targetUnitID] then
                seenUnitIDs[targetUnitID] = true
                local distance = math.sqrt((coords.x - targetCoords.x)^2 + (coords.z - targetCoords.z)^2)
                table.insert(foundUnits, {id = targetUnitID, name = targetUnitName, type = targetUnitType, coords = targetCoords, health = targetHealth, distance = distance, attributes = targetAttrs, object = obj, statName = statName, points = points})
            end
        end
        debugCBUBombletHit("Primary scan for objects within " .. scanRadius .. "m radius")
        world.searchObjects(Object.Category.UNIT, volS, ifFound)
        world.searchObjects(Object.Category.STATIC, volS, ifFound)
        world.searchObjects(Object.Category.SCENERY, volS, ifFound)
        world.searchObjects(Object.Category.CARGO, volS, ifFound)

        --Secondary scans for each found unit
        for _, unit in ipairs(foundUnits) do
            local secondaryVolS = {
                id = world.VolumeType.SPHERE,
                params = {
                    point = unit.coords,
                    radius = secondaryScanRadius
                }
            }
			debugCBUBombletHit("Secondary widening scan within " .. scanRadius .. "m radius of found units")
            world.searchObjects(Object.Category.UNIT, secondaryVolS, ifFound)
            world.searchObjects(Object.Category.STATIC, secondaryVolS, ifFound)
            world.searchObjects(Object.Category.SCENERY, secondaryVolS, ifFound)
            world.searchObjects(Object.Category.CARGO, secondaryVolS, ifFound)
        end

        --Sort by distance and display scan results
        table.sort(foundUnits, function(a, b) return a.distance < b.distance end)
        local unitDetails = {}
        for _, unit in ipairs(foundUnits) do
            table.insert(unitDetails, string.format("%s (ID: %s, Type: %s, Health: %.1f, Distance: %.1fm)", unit.name, unit.id, unit.type, unit.health, unit.distance))
        end
        debugCBUBombletHit("CBUBomblet: Found " .. #foundUnits .. " unique objects: " .. (#unitDetails > 0 and table.concat(unitDetails, ", ") or "none"))

        --Schedule explosions for found units
        for i, unit in ipairs(foundUnits) do
            local key = unit.id .. "-" .. weaponID
            if not cbuProcessed[key] then
                if math.random() <= splash_damage_options.CBU_Bomblet_Hit_Chance then
                    debugCBUBombletHit("CBUBomblet: hit chance passed for unit " .. unit.name .. " (ID: " .. unit.id .. ")")
                    local isIndirect = math.random() < splash_damage_options.CBU_Bomblet_Indirect_Hit_Chance
                    local indirectMod = isIndirect and splash_damage_options.CBU_Bomblet_Indirect_Dmg_Modifier or 1.0
                    debugCBUBombletHit("CBUBomblet: Indirect hit check: " .. (isIndirect and "Indirect (by def 30% chance, 50% damage)" or "Direct (100% damage)") .. " for spread unit " .. unit.name)
                    local armorMod = 1.0
                    local armorType = "Unknown"
                    if unit.attributes["NonArmoredUnits"] then
                        armorMod = splash_damage_options.CBU_Bomblet_NonArmored_Dmg_Modifier
                        armorType = "NonArmored"
                    elseif unit.attributes["LightArmoredUnits"] or unit.attributes["NonAndLightArmoredUnits"] then
                        armorMod = splash_damage_options.CBU_Bomblet_LightlyArmored_Dmg_Modifier
                        armorType = "LightlyArmored"
                    elseif unit.attributes["ArmoredUnits"] or unit.attributes["Tanks"] then
                        armorMod = splash_damage_options.CBU_Bomblet_Armored_Dmg_Modifier
                        armorType = "Armored"
                    end
                    debugCBUBombletHit("CBUBomblet: unit " .. unit.name .. " identified as " .. armorType .. " with armor modifier " .. armorMod)
                    local finalPower = explosionPower * indirectMod * armorMod
					if unit.attributes["Infantry"] then
					finalPower = 1 --Set explosion power to 1 for infantry
					explosionHeight = 2
					end
                    cbuProcessed[key] = true
                local adjustedUnitCoords = { x = unit.coords.x, y = land.getHeight({x = unit.coords.x, z = unit.coords.z}) + explosionHeight, z = unit.coords.z }
				
				
                    local delay = (i - 1) * (spreadDuration / math.max(1, #foundUnits)) --Evenly spread over duration
                debugCBUBombletHit("CBUBomblet: Scheduling explosion for unit " .. unit.name .. " (ID: " .. unit.id .. ") at X: " .. adjustedUnitCoords.x .. ", Y: " .. adjustedUnitCoords.y .. ", Z: " .. adjustedUnitCoords.z .. " with final power " .. finalPower .. " (indirectMod: " .. indirectMod .. ", armorMod: " .. armorMod .. ") in " .. string.format("%.2f", delay) .. "s")
                    timer.scheduleFunction(function()
                    debugCBUBombletHit("CBUBomblet: Explosion triggered for unit " .. unit.name .. " (ID: " .. unit.id .. ") at X: " .. adjustedUnitCoords.x .. ", Y: " .. adjustedUnitCoords.y .. ", Z: " .. adjustedUnitCoords.z .. " with power " .. finalPower .. " due to weapon " .. weaponName)
                        trigger.action.explosion(adjustedUnitCoords, finalPower)
                    end, {name = unit.name, id = unit.id, coords = unit.coords}, timer.getTime() + delay)
                else
					cbuProcessed[key] = true
                    debugCBUBombletHit("CBUBomblet: Hit chance failed for  unit " .. unit.name .. " (ID: " .. unit.id .. "), skipping explosion")
                end
            end
        end

        --Post-scan for killfeed with 200m radius around first unit
        if splash_damage_options.killfeed_enable and #foundUnits > 0 then
            local playerName = resolvePlayerNameWithLauncherFallback(initiator)
            debugCBUBombletHit("CBUBomblet: Final playerName: " .. playerName)
            if isConnectedPlayerName(playerName) then
                debugCBUBombletHit("CBUBomblet: Player validation, isPlayer=true")
                local function performKillfeedScan(args)
                    local attempt = args.attempt
                        local killfeedScanRadius = 200
                        local firstUnit = foundUnits[1]
                        debugCBUBombletHit("CBUBomblet: Starting killfeed scan (attempt " .. attempt .. "), first unit: " .. tostring(firstUnit.name) .. ", coords: X=" .. firstUnit.coords.x .. ", Z=" .. firstUnit.coords.z)
                        local killfeedVolS = {
                            id = world.VolumeType.SPHERE,
                            params = {
                                point = firstUnit.coords,
                                radius = killfeedScanRadius
                            }
                        }
                        local secondScanUnits = {}
                        local secondSeenUnitIDs = {}
                        local ifKillfeedFound = function(obj)
                            local targetUnitID = safeGet(function() return obj:getID() end, "unavailable")
                            local targetHealth = safeGet(function() return obj:getLife() end, 0)
                            local isExist = safeGet(function() return obj:isExist() end, false)
                            if targetUnitID ~= "unavailable" then
                                if isExist and targetHealth > 0 then
                                    secondSeenUnitIDs[targetUnitID] = true
                                    debugCBUBombletHit("CBUBomblet: Killfeed scan (attempt " .. attempt .. ") found unit ID: " .. targetUnitID .. " (Health: " .. targetHealth .. ", isExist: " .. tostring(isExist) .. ")")
                                else
                                    debugCBUBombletHit("CBUBomblet: Killfeed scan (attempt " .. attempt .. ") found unit ID: " .. targetUnitID .. " marked as dead (Health: " .. targetHealth .. ", isExist: " .. tostring(isExist) .. ")")
                                end
                            end
                        end
                        debugCBUBombletHit("CBUBomblet: Killfeed scan for objects within " .. killfeedScanRadius .. "m radius around first unit (attempt " .. attempt .. ")")
                        world.searchObjects(Object.Category.UNIT, killfeedVolS, ifKillfeedFound)
                        world.searchObjects(Object.Category.STATIC, killfeedVolS, ifKillfeedFound)
                        world.searchObjects(Object.Category.SCENERY, killfeedVolS, ifKillfeedFound)
                        world.searchObjects(Object.Category.CARGO, killfeedVolS, ifKillfeedFound)

                        --Custom function to get table keys
                        local keys = {}
                        for k in pairs(secondSeenUnitIDs) do
                            table.insert(keys, k)
                        end
                        debugCBUBombletHit("CBUBomblet: Post-scan unit IDs (attempt " .. attempt .. "): " .. table.concat(keys, ", "))
                        for _, unit in ipairs(foundUnits) do
                            debugCBUBombletHit("CBUBomblet: Checking unit " .. unit.name .. " (ID: " .. unit.id .. ") for splash killfeed (attempt " .. attempt .. ")")
                            if not secondSeenUnitIDs[unit.id] then
                                if splashKillfeedByUnitId[unit.id] then
                                    debugCBUBombletHit("CBUBomblet: Unit " .. unit.name .. " (ID: " .. unit.id .. ") already in splashKillfeedTable, skipping (attempt " .. attempt .. ")")
                                else
                                    local added = addSplashKillTempEntry({
                                        unitName = unit.name,
                                        unitType = unit.type,
                                        unitId = unit.id,
                                        playerName = playerName,
                                        weaponName = weaponName,
                                        time = timer.getTime(),
                                        position = unit.coords,
                                        statName = unit.statName,
                                        points = unit.points
                                    }, unit.object)
                                    if added then
                                        debugCBUBombletHit("CBUBomblet: Added to splashKillfeed: " .. unit.name .. " destroyed by " .. playerName .. " (attempt " .. attempt .. ")")
                                        if splash_damage_options.killfeed_game_messages then
                                            local msg = string.format("%s destroyed by %s's %s Splash Damage", unit.type, playerName, weaponName)
                                            trigger.action.outTextForCoalition(2, msg, splash_damage_options.killfeed_game_message_duration)
                                        end
                                    end
                                end
                            else
                                debugCBUBombletHit("CBUBomblet: Unit " .. unit.name .. " (ID: " .. unit.id .. ") still alive, not added to splashKillfeed (attempt " .. attempt .. ")")
                            end
                        end
                        debugCBUBombletHit("CBUBomblet: splashKillfeedTemp size: " .. #splashKillfeedTemp .. " (attempt " .. attempt .. ")")
                        --Schedule retry if first attempt and no kills added
                        if attempt == 1 and #splashKillfeedTemp == 0 then
                            debugCBUBombletHit("CBUBomblet: No kills added on first scan, scheduling retry in 5 seconds")
                            timer.scheduleFunction(performKillfeedScan, {attempt = 2}, timer.getTime() + 5)
                        end
                end
                timer.scheduleFunction(performKillfeedScan, {attempt = 1}, timer.getTime() + 30)
            else
                debugCBUBombletHit("CBUBomblet: Killfeed scan skipped, playerName is Unknown")
            end
        else
            debugCBUBombletHit("CBUBomblet: Killfeed scan skipped, no units found or killfeed disabled")
        end
    end
end


--A10 MurderMode action block
function logEvent(eventName, eventData)
    local logStr = "\n---EVENT: " .. eventName .. " ---\n"

    --Debug logging if enabled
    if splash_damage_options.events_debug then
        --Core event details
        logStr = logStr .. "  Event Name: " .. eventName .. "\n"
        logStr = logStr .. "  Event ID: " .. tostring(eventData.id or "unknown") .. "\n"
        logStr = logStr .. "  Time: " .. tostring(eventData.time or "unknown") .. "\n"

        --Initiator details
        local initiatorID = "unavailable"
        local initiatorName = "unknown"
        local initiatorType = "unknown"
        local initiatorGroup = "unknown"
        local initiatorCoalition = "unknown"
        local initiatorPosition = "unavailable"
        if eventData.initiator then
            initiatorID = safeGet(function() return eventData.initiator:getID() end, "unavailable")
            initiatorName = safeGet(function() return eventData.initiator:getName() end, "unknown")
            initiatorType = safeGet(function() return eventData.initiator:getTypeName() end, "unknown")
            initiatorCoalition = safeGet(function() return eventData.initiator:getCoalition() end, "unknown")
            initiatorGroup = safeGet(function() return eventData.initiator:getGroup():getName() end, "unknown")
            initiatorPosition = safeGet(function()
                local pos = eventData.initiator:getPosition().p
                return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
            end, "unavailable")
        end
        logStr = logStr .. "  Initiator:\n"
        logStr = logStr .. "    ID: " .. initiatorID .. "\n"
        logStr = logStr .. "    Name: " .. initiatorName .. "\n"
        logStr = logStr .. "    Type: " .. initiatorType .. "\n"
        logStr = logStr .. "    Coalition: " .. initiatorCoalition .. "\n"
        logStr = logStr .. "    Position: " .. initiatorPosition .. "\n"
        logStr = logStr .. "    Group: " .. initiatorGroup .. "\n"

        --Target details
        local targetID = "unavailable"
        local targetName = "unknown"
        local targetType = "unknown"
        local targetCategory = "unknown"
        local targetCoalition = "unknown"
        local targetPosition = "unavailable"
        local targetCountry = "unknown"
        local targetLife = 0
        local targetGroup = "unknown"
        if eventData.target then
            targetID = safeGet(function() return eventData.target:getID() end, "unavailable")
            targetName = safeGet(function() return eventData.target:getName() end, "unknown")
            targetType = safeGet(function() return eventData.target:getTypeName() end, "unknown")
            targetCategory = safeGet(function() return eventData.target:getDesc().category end, "unknown")
            targetCoalition = safeGet(function() return eventData.target:getCoalition() end, 3)
            targetPosition = safeGet(function()
                local pos = eventData.target:getPosition().p
                return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
            end, "unavailable")
            targetCountry = safeGet(function() return eventData.target:getCountry() end, "unknown")
            targetLife = safeGet(function() return eventData.target:getLife() end, 0)
            targetGroup = safeGet(function() return eventData.target:getGroup():getName() end, "unknown")
        end
        logStr = logStr .. "  Target:\n"
        logStr = logStr .. "    ID: " .. targetID .. "\n"
        logStr = logStr .. "    Name: " .. targetName .. "\n"
        logStr = logStr .. "    Type: " .. targetType .. "\n"
        logStr = logStr .. "    Category: " .. targetCategory .. "\n"
        logStr = logStr .. "    Coalition: " .. targetCoalition .. "\n"
        logStr = logStr .. "    Position: " .. targetPosition .. "\n"
        logStr = logStr .. "    Country: " .. targetCountry .. "\n"
        logStr = logStr .. "    Life: " .. targetLife .. "\n"
        logStr = logStr .. "    Group: " .. targetGroup .. "\n"

        --Full event data dump
        logStr = logStr .. "  Full eventData:\n" .. dumpTable(eventData, "    ")
        env.info(logStr)
    end

    --Skip all DEAD events with invalid initiator
    if eventName == "DEAD" then
        if not eventData.initiator then
            if splash_damage_options.events_debug then
                env.info("Eventlog: Skipping DEAD event with no initiator")
            end
            return
        else
            local initiatorID = safeGet(function() return eventData.initiator:getID() end, "unavailable")
            local initiatorName = safeGet(function() return eventData.initiator:getName() end, "unknown")
            local initiatorType = safeGet(function() return eventData.initiator:getTypeName() end, "unknown")
            if initiatorID == "unavailable" or type(initiatorName) ~= "string" then
                if splash_damage_options.events_debug then
                    env.info("Eventlog: Skipping DEAD event for invalid initiator (ID: " .. tostring(initiatorID) .. ", Name: " .. tostring(initiatorName) .. ", Type: " .. tostring(initiatorType) .. ")")
                end
                debugCBUBombletHit("CBUBomblet: Player validation, isPlayer=false")
                return
            else
                debugCBUBombletHit("CBUBomblet: Player validation, isPlayer=true")
            end
        end
    end

    --Process GiantExplosionTarget units if enabled
    if splash_damage_options.giant_explosion_enabled then
        local checkName = (eventName == "HIT" or eventName == "KILL") and eventData.target and safeGet(function() return eventData.target:getName() end, "unknown") or
                          (eventName == "DEAD") and eventData.initiator and safeGet(function() return eventData.initiator:getName() end, "unknown") or "unknown"
        if type(checkName) == "string" and checkName:find("GiantExplosionTarget") then
            local unitID, unitName, unitType, unitPosition, unitLife, rawCoords
            local status, err = pcall(function()
                if eventName == "HIT" or eventName == "KILL" then
                    local tgt = eventData.target or eventData.object
                    unitID = safeGet(function() return tgt:getID() end, "unavailable")
                    unitName = safeGet(function() return tgt:getName() end, "unknown")
                    unitType = safeGet(function() return tgt:getTypeName() end, "unknown")
                    unitPosition = safeGet(function()
                        local pos = tgt:getPosition().p
                        return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
                    end, "unavailable")
                    rawCoords = safeGet(function()
                        local pos = tgt:getPosition().p
                        return {x = pos.x, y = pos.y, z = pos.z}
                    end, {x = 0, y = 0, z = 0})
                    unitLife = safeGet(function() return tgt:getLife() end, "Alive")
                elseif eventName == "DEAD" then
                    unitID = safeGet(function() return eventData.initiator:getID() end, "unavailable")
                    unitName = safeGet(function() return eventData.initiator:getName() end, "unknown")
                    unitType = safeGet(function() return eventData.initiator:getTypeName() end, "unknown")
                    unitPosition = safeGet(function()
                        local pos = eventData.initiator:getPosition().p
                        return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
                    end, "unavailable")
                    rawCoords = safeGet(function()
                        local pos = eventData.initiator:getPosition().p
                        return {x = pos.x, y = pos.y, z = pos.z}
                    end, {x = 0, y = 0, z = 0})
                    unitLife = safeGet(function() return eventData.initiator:getLife() end, 0)
                end
            end)
            if not status then
                debugMsg("GiantExplosionTrigger: Error extracting unit data for event " .. eventName .. ": " .. tostring(err))
            elseif unitID == "unavailable" then
                debugMsg("GiantExplosionTrigger: Skipping event " .. eventName .. " for invalid unit ID: " .. tostring(unitID))
            else
                if processedUnitsGlobal[unitID] then
                    debugMsg("GiantExplosionTrigger: Unit ID " .. unitID .. " (" .. unitName .. ") already processed, skipping")
                else
                    local shouldTrigger = false
                    if eventName == "HIT" and splash_damage_options.giantexplosion_ondamage then
                        shouldTrigger = true
                        debugMsg("GiantExplosionTrigger: Unit " .. unitName .. " hit, triggering explosion")
                    elseif (eventName == "KILL" or eventName == "DEAD") and splash_damage_options.giantexplosion_ondeath then
                        shouldTrigger = true
                        debugMsg("GiantExplosionTrigger: Unit " .. unitName .. " killed/dead, triggering explosion")
                    end
                    if shouldTrigger then
                        markProcessedUnitGlobal(unitID, {
                            id = unitID,
                            name = unitName,
                            type = unitType,
                            position = unitPosition,
                            life = unitLife,
                            event = eventName,
                            time = timer.getTime()
                        })
                        triggerGiantExplosion({
                            pos = rawCoords,
                            power = splash_damage_options.giant_explosion_power,
                            scale = splash_damage_options.giant_explosion_scale,
                            duration = splash_damage_options.giant_explosion_duration,
                            count = splash_damage_options.giant_explosion_count
                        })
                        return --Skip further processing
                    end
                end
            end
        end
    end

    --Handle A10MurderMode
    if splash_damage_options.A10MurderMode and eventName == "HIT" and eventData.initiator then
        local initiatorType = safeGet(function() return eventData.initiator:getTypeName() end, "unknown")
        --Extract unit data for A10MurderMode
        local unitID, unitName, unitType, unitPosition, unitLife, rawCoords
        local status, err = pcall(function()
            local tgt = eventData.target
            unitID = safeGet(function() return tgt:getID() end, "unavailable")
            unitName = safeGet(function() return tgt:getName() end, "unknown")
            unitType = safeGet(function() return tgt:getTypeName() end, "unknown")
            unitPosition = safeGet(function()
                local pos = tgt:getPosition().p
                return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
            end, "unavailable")
            rawCoords = safeGet(function()
                local pos = tgt:getPosition().p
                return {x = pos.x, y = pos.y, z = pos.z}
            end, {x = 0, y = 0, z = 0})
            unitLife = safeGet(function() return tgt:getLife() end, "Alive")
        end)
        if not status and splash_damage_options.MurderMode_debug then
            env.info("A10MurderMode: Error extracting unit data for HIT event: " .. tostring(err))
        end
        if splash_damage_options.MurderMode_debug then
            env.info("A10MurderMode: Checking initiator type: " .. initiatorType .. " for target: " .. unitName)
        end
        if initiatorType:match("A%-10") then
            local coords = {
                x = tonumber(unitPosition:match("x=(.-),")),
                y = tonumber(unitPosition:match("y=(.-),")),
                z = tonumber(unitPosition:match("z=(.-)$"))
            }
            if coords.x and coords.y and coords.z then
                if splash_damage_options.MurderMode_debug then
                    env.info("A10MurderMode: A-10 initiator detected, triggering explosion for target: " .. unitName)
                end
                A10MurderMode(coords)
            elseif splash_damage_options.MurderMode_debug then
                env.info("A10MurderMode: Invalid coordinates for target: " .. unitName .. ", skipping explosion")
            end
        elseif splash_damage_options.MurderMode_debug then
            env.info("A10MurderMode: Initiator not an A-10, skipping for target: " .. unitName)
        end
    end
    
    --Handle NamedUnitMurderMode
    if splash_damage_options.NamedUnitMurderMode and eventName == "HIT" and eventData.initiator then
        local initiatorName = tostring(safeGet(function() return eventData.initiator:getName() end, "unknown"))
        --Extract unit data for NamedUnitMurderMode
        local unitID, unitName, unitType, unitPosition, unitLife, rawCoords
        local status, err = pcall(function()
            local tgt = eventData.target
            unitID = safeGet(function() return tgt:getID() end, "unavailable")
            unitName = safeGet(function() return tgt:getName() end, "unknown")
            unitType = safeGet(function() return tgt:getTypeName() end, "unknown")
            unitPosition = safeGet(function()
                local pos = tgt:getPosition().p
                return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
            end, "unavailable")
            rawCoords = safeGet(function()
                local pos = tgt:getPosition().p
                return {x = pos.x, y = pos.y, z = pos.z}
            end, {x = 0, y = 0, z = 0})
            unitLife = safeGet(function() return tgt:getLife() end, "Alive")
        end)
        if not status and splash_damage_options.MurderMode_debug then
            env.info("NamedUnitMurderMode: Error extracting unit data for HIT event: " .. tostring(err))
        end
        if splash_damage_options.MurderMode_debug then
            env.info("NamedUnitMurderMode: Checking initiator name: " .. initiatorName .. " for target: " .. unitName)
        end
        if initiatorName:find("MurderMode") then
            local coords = {
                x = tonumber(unitPosition:match("x=(.-),")),
                y = tonumber(unitPosition:match("y=(.-),")),
                z = tonumber(unitPosition:match("z=(.-)$"))
            }
            if coords.x and coords.y and coords.z then
                if splash_damage_options.MurderMode_debug then
                    env.info("NamedUnitMurderMode: Initiator with 'MurderMode' detected, triggering explosion for target: " .. unitName)
                end
                NamedUnitMurderMode(coords)
            elseif splash_damage_options.MurderMode_debug then
                env.info("NamedUnitMurderMode: Invalid coordinates for target: " .. unitName .. ", skipping explosion")
            end
        elseif splash_damage_options.MurderMode_debug then
            env.info("NamedUnitMurderMode: Initiator name does not contain 'MurderMode', skipping for target: " .. unitName)
        end
    end

		--Handle CriticalComponent
		if splash_damage_options.CriticalComponent and eventName == "HIT" and eventData.initiator then
			local initiatorType = safeGet(function() return eventData.initiator:getTypeName() end, "unknown")
			--Extract unit data for CriticalComponent
			local unitID, unitName, unitType, unitPosition, rawCoords, weaponName
			local status, err = pcall(function()
				local tgt = eventData.target
				unitID = safeGet(function() return tgt:getID() end, "unavailable")
				unitName = safeGet(function() return tgt:getName() end, "unknown")
				unitType = safeGet(function() return tgt:getTypeName() end, "unknown")
				unitPosition = safeGet(function()
					local pos = tgt:getPosition().p
					return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
				end, "unavailable")
				rawCoords = safeGet(function()
					local pos = tgt:getPosition().p
					return {x = pos.x, y = pos.y, z = pos.z}
				end, {x = 0, y = 0, z = 0})
				weaponName = safeGet(function()
					local fullName = eventData.weapon:getTypeName()
					return fullName:match(".*%.(.*)") or fullName
				end, "unknown")
			end)
			if not status and splash_damage_options.CriticalComponent_debug then
				env.info("CriticalComponent: Error extracting unit data for HIT event: " .. tostring(err))
			end
			if splash_damage_options.CriticalComponent_debug then
				env.info("CriticalComponent: Checking initiator type: " .. initiatorType .. " for target: " .. unitName)
			end
			if eventData.weapon then
				if unitID == "unavailable" then
					if splash_damage_options.CriticalComponent_debug then
						env.info("CriticalComponent: Skipping event HIT for invalid unit ID: " .. tostring(unitID))
					end
				else
					if splash_damage_options.CriticalComponent_Specific_Weapons_Only and #splash_damage_options.CriticalComponent_Specific_Weapons_Only > 0 then
						local validWeapon = false
						for _, wpn in ipairs(splash_damage_options.CriticalComponent_Specific_Weapons_Only) do
							if weaponName == wpn then
								validWeapon = true
								break
							end
						end
						if not validWeapon then
							if splash_damage_options.CriticalComponent_debug then
								env.info("CriticalComponent: Weapon " .. (weaponName or "nil") .. " not in CriticalComponent_Specific_Weapons_Only, skipping")
							end
						else
							local coords = {
								x = tonumber(unitPosition:match("x=(.-),")),
								y = tonumber(unitPosition:match("y=(.-),")),
								z = tonumber(unitPosition:match("z=(.-)$"))
							}
							if coords.x and coords.y and coords.z then
								if splash_damage_options.CriticalComponent_debug then
									env.info("CriticalComponent: Valid weapon detected, triggering explosion for target: " .. unitName .. " with weapon: " .. (weaponName or "nil"))
								end
								CriticalComponent(coords, weaponName, eventData.initiator, unitName, unitID, unitType)
							elseif splash_damage_options.CriticalComponent_debug then
								env.info("CriticalComponent: Invalid coordinates for target: " .. unitName .. ", skipping explosion")
							end
						end
					else
						local coords = {
							x = tonumber(unitPosition:match("x=(.-),")),
							y = tonumber(unitPosition:match("y=(.-),")),
							z = tonumber(unitPosition:match("z=(.-)$"))
						}
						if coords.x and coords.y and coords.z then
							if splash_damage_options.CriticalComponent_debug then
								env.info("CriticalComponent: Valid weapon detected, triggering explosion for target: " .. unitName .. " with weapon: " .. (weaponName or "nil"))
							end
							CriticalComponent(coords, weaponName, eventData.initiator, unitName, unitID, unitType)
						elseif splash_damage_options.CriticalComponent_debug then
							env.info("CriticalComponent: Invalid coordinates for target: " .. unitName .. ", skipping explosion")
						end
					end
				end
			elseif splash_damage_options.CriticalComponent_debug then
				env.info("CriticalComponent: No valid weapon, skipping for target: " .. unitName)
			end
		end
		
		
		--Process GU_Explode_on_Death for ground units
		if splash_damage_options.GU_Explode_on_Death then
			local unit, unitID, unitName, unitType, unitPosition, rawCoords, unitCategory
			local status, err = pcall(function()
				unit = eventName == "DEAD" and eventData.initiator or eventData.target
				unitID = safeGet(function() return unit:getID() end, "unavailable")
				unitName = safeGet(function() return unit:getName() end, "unknown")
				unitType = safeGet(function() return unit:getTypeName() end, "unknown")
				unitCategory = safeGet(function() return unit:getDesc().category end, "unknown")
				unitPosition = safeGet(function()
					local pos = unit:getPosition().p
					return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
				end, "unavailable")
				rawCoords = safeGet(function()
					local pos = unit:getPosition().p
					return {x = pos.x, y = pos.y, z = pos.z}
				end, {x = 0, y = 0, z = 0})
				--Fallback to CargoCookoffPendingTable coords if available for DEAD event
				if eventName == "DEAD" and (rawCoords.x == 0 and rawCoords.y == 0 and rawCoords.z == 0) then
					local pendingEntry = CargoCookoffPendingTable[unitID]
					if pendingEntry and pendingEntry.coords then
						rawCoords = pendingEntry.coords
						unitPosition = string.format("x=%.0f, y=%.0f, z=%.0f", rawCoords.x, rawCoords.y, rawCoords.z)
						if splash_damage_options.GU_Explode_debug then
                    				env.info("GU_Explode_on_Death: Using coords from CargoCookoffPendingTable for unit ID " .. unitID .. ": X=" .. rawCoords.x .. ", Y=" .. rawCoords.y .. ", Z=" .. rawCoords.z)
						end
					end
				end
			end)
			if not status and splash_damage_options.GU_Explode_debug then
				env.info("GU_Explode_on_Death: Error extracting unit data for " .. eventName .. " event: " .. tostring(err))
			end
			local isInfantry = safeGet(function() return unit:hasAttribute("Infantry") end, false)
			if unitID ~= "unavailable" and type(unitName) == "string" and unitCategory == Unit.Category.GROUND_UNIT and (not splash_damage_options.GU_Explode_Exclude_Infantry or not isInfantry) then
        if GUProcessedUnits[unitID] then
            if splash_damage_options.GU_Explode_debug then
                env.info("GU_Explode_on_Death: Unit ID " .. unitID .. " (" .. unitName .. ") already processed, skipping event " .. eventName)
            end
				else
					local function checkUnitStatus(params)
                if GUProcessedUnits[params.id] then
							if splash_damage_options.GU_Explode_debug then
								env.info("GU_Explode_on_Death: Unit ID " .. params.id .. " (" .. params.name .. ") already processed after 0.1s check, skipping")
							end
                    return
                end
							local u = Unit.getByName(params.name)
							local isAlive = u and u:isExist() and safeGet(function() return u:getLife() end, 0) > 0
                local terrainHeight = land.getHeight({x = params.coords.x, y = params.coords.z})
                local heightAboveGround = params.coords.y - terrainHeight
							if splash_damage_options.GU_Explode_debug then
                    env.info("GU_Explode_on_Death: Checking unit " .. params.name .. " (ID: " .. params.id .. ") after 0.1s, alive: " .. tostring(isAlive) .. ", raw Y: " .. string.format("%.1f", params.coords.y) .. ", terrain height: " .. string.format("%.1f", terrainHeight) .. ", height above ground: " .. string.format("%.1f", heightAboveGround) .. "m, event: " .. params.event)
							end
							if not isAlive then
                    if params.coords.x == 0 and params.coords.z == 0 then
                        if splash_damage_options.GU_Explode_debug then
                            env.info("GU_Explode_on_Death: Invalid coordinates for unit " .. params.name .. " (ID: " .. params.id .. "), skipping explosion")
                        end
                        return
                    end
                    if heightAboveGround > 5 then
                        if splash_damage_options.GU_Explode_debug then
                            env.info("GU_Explode_on_Death: Unit " .. params.name .. " (ID: " .. params.id .. ") is " .. string.format("%.1f", heightAboveGround) .. "m above ground, forcing to terrain height")
                        end
                    end
                    if params.name:find("GUED") or math.random() <= splash_damage_options.GU_Explode_on_Death_Chance then
                        local explosionCoords = {
                            x = params.coords.x,
                            y = terrainHeight + (splash_damage_options.GU_Explode_on_Death_Height or 0),
                            z = params.coords.z
                        }
                        GUProcessedUnits[params.id] = {
									id = params.id,
									name = params.name,
									type = params.type,
									position = params.position,
									life = 0,
									event = params.event,
									time = timer.getTime()
                        }
									trigger.action.explosion(explosionCoords, splash_damage_options.GU_Explode_on_Death_Explosion_Power)
									if splash_damage_options.GU_Explode_debug then
                            local reason = params.name:find("GUED") and "GUED in name" or "chance check passed"
                            env.info("GU_Explode_on_Death: Triggered explosion for unit " .. params.name .. " (ID: " .. params.id .. ") at X: " .. string.format("%.1f", explosionCoords.x) .. ", Y: " .. string.format("%.1f", explosionCoords.y) .. ", Z: " .. string.format("%.1f", explosionCoords.z) .. " with power " .. splash_damage_options.GU_Explode_on_Death_Explosion_Power .. " (" .. reason .. ")")
									end
								else
									if splash_damage_options.GU_Explode_debug then
										env.info("GU_Explode_on_Death: Chance check failed for unit " .. params.name .. " (ID: " .. params.id .. ")")
									end
								end
							end
						end
					if eventName == "HIT" then
						timer.scheduleFunction(checkUnitStatus, {
							id = unitID,
							name = unitName,
							type = unitType,
							position = unitPosition,
							coords = rawCoords,
							event = "HIT"
						}, timer.getTime() + 0.1)
					elseif eventName == "DEAD" then
						checkUnitStatus({
							id = unitID,
							name = unitName,
							type = unitType,
							position = unitPosition,
							coords = rawCoords,
							event = "DEAD"
						})
					end
				end
			elseif splash_damage_options.GU_Explode_debug then
				env.info("GU_Explode_on_Death: Skipping non-ground unit, invalid unit, or excluded infantry (ID: " .. tostring(unitID) .. ", Name: " .. tostring(unitName) .. ")")
			end
		end


    --CBU Bomblet Hit Explosion handling
if eventName == "SHOT" and eventData.initiator and eventData.weapon then
    local weaponName = safeGet(function() return eventData.weapon:getTypeName():match(".*%.(.*)") or eventData.weapon:getTypeName() end, "unknown")
    local weaponID = safeGet(function() return eventData.weapon:getID() end, "unknown")
    --Check if the weapon is in clusterSubMunTable
    if clusterSubMunTable[weaponName] then
        cbuParentUnits[weaponID] = eventData.initiator
        debugCBUBombletHit("CBUBomblet: Stored parent unit for weapon " .. weaponName .. " (ID: " .. weaponID .. ")")
    end
end
    if splash_damage_options.CBU_Bomblet_Hit_Explosion and eventName == "HIT" and eventData.initiator and eventData.target and eventData.weapon then
        local status, err = pcall(function()
            local unitID = safeGet(function() return eventData.target:getID() end, "unavailable")
            local unitName = safeGet(function() return eventData.target:getName() end, "unknown")
            local weaponName = safeGet(function() return eventData.weapon:getTypeName():match(".*%.(.*)") or eventData.weapon:getTypeName() end, "unknown")
            local weaponID = safeGet(function() return eventData.weapon:getID() end, "unknown")
            local rawCoords = safeGet(function() return eventData.target:getPosition().p end, {x = 0, y = 0, z = 0})
            local initiator = eventData.initiator
        --If initiator is a submunition, try to find the parent unit
        if clusterSubMunTable[weaponName] then
            for storedWeaponID, parentInitiator in pairs(cbuParentUnits) do
                if parentInitiator and parentInitiator:isExist() then
                    initiator = parentInitiator
                    debugCBUBombletHit("CBUBomblet: Using parent unit for submunition " .. weaponName .. " (ID: " .. weaponID .. ")")
                    break
                end
            end
        end

            if unitID == "unavailable" or type(unitName) ~= "string" then
                debugCBUBombletHit("CBUBomblet: Skipping HIT event for invalid unit (ID: " .. tostring(unitID) .. ", Name: " .. tostring(unitName) .. ")")
            else
                --Check if weapon is a submunition in clusterSubMunTable
                local submunitionData = clusterSubMunTable[weaponName]
                if submunitionData then
                    local key = unitID .. "-" .. weaponID
                    if not cbuProcessed[key] then
                        if not splash_damage_options.CBU_Bomblet_Hit_OriginUnit_Twice then
                            cbuProcessed[key] = true
                        end
                        debugCBUBombletHit("CBUBomblet: Submunition " .. weaponName .. " detected for unit " .. unitName .. " (ID: " .. unitID .. ")")
                        CBUBombletHitExplosion(rawCoords, unitName, unitID, weaponName, weaponID, submunitionData.explosive, initiator)
                    else
                        debugCBUBombletHit("CBUBomblet: Unit " .. unitName .. " (ID: " .. unitID .. ") already processed for weapon " .. weaponName)
                    end
                else
                    debugCBUBombletHit("CBUBomblet: Weapon " .. weaponName .. " is not a submunition in clusterSubMunTable, skipping for unit " .. unitName .. " (ID: " .. unitID .. ")")
                end
            end
        end)
        if not status then
            debugCBUBombletHit("CBUBomblet: Error processing HIT event: " .. tostring(err))
        end
    end
	
		--Process Cargo Cookoff units
		if splash_damage_options.enable_cargo_effects then
			local unit, unitID, unitName, unitType, unitPosition, unitLife, maxHealth, rawCoords
			local isCargoCandidate = false
			local isCargoUnit = false
			local status, err = pcall(function()
				if eventName == "HIT" or eventName == "KILL" then
					unit = eventData.target
					unitID = safeGet(function() return unit:getID() end, "unavailable")
					unitName = safeGet(function() return unit:getName() end, "unknown")
					unitType = safeGet(function() return unit:getTypeName() end, "unknown")
					unitPosition = safeGet(function()
						local pos = unit:getPosition().p
						return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
					end, "unavailable")
					rawCoords = safeGet(function()
						local pos = unit:getPosition().p
						return {x = pos.x, y = pos.y, z = pos.z}
					end, {x = 0, y = 0, z = 0})
					unitLife = safeGet(function() return unit:getLife() end, 0)
					maxHealth = safeGet(function() return unit:getDesc().life end, 1)
				elseif eventName == "DEAD" then
					unit = eventData.initiator
					unitID = safeGet(function() return unit:getID() end, "unavailable")
					unitName = safeGet(function() return unit:getName() end, "unknown")
					unitType = safeGet(function() return unit:getTypeName() end, "unknown")
					unitPosition = safeGet(function()
						local pos = unit:getPosition().p
						return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
					end, "unavailable")
					rawCoords = safeGet(function()
						local pos = unit:getPosition().p
						return {x = pos.x, y = pos.y, z = pos.z}
					end, {x = 0, y = 0, z = 0})
					--Fallback to CargoCookoffPendingTable coords if available
					if rawCoords.x == 0 and rawCoords.y == 0 and rawCoords.z == 0 then
						local pendingEntry = CargoCookoffPendingTable[unitID]
						if pendingEntry and pendingEntry.coords then
							rawCoords = pendingEntry.coords
							unitPosition = string.format("x=%.0f, y=%.0f, z=%.0f", rawCoords.x, rawCoords.y, rawCoords.z)
							debugCargoCookOff("Using coords from CargoCookoffPendingTable for unit ID " .. unitID .. ": X=" .. rawCoords.x .. ", Z=" .. rawCoords.z)
						end
					end
					unitLife = safeGet(function() return unit:getLife() end, 0)
					maxHealth = safeGet(function() return unit:getDesc().life end, 1)
				end
				unitName = tostring(unitName)
				--Exclude static objects and fortifications unless explicitly in cargoUnits or named CargoCookoffTarget
				local objectCategory = safeGet(function() return Object.getCategory(unit) end, "unknown")
					if (objectCategory == Object.Category.STATIC or objectCategory == Object.Category.FORTIFICATION) and not (cargoUnits[unitType] or unitName:find("CargoCookoffTarget")) then
						debugCargoCookOff("Unit ID " .. unitID .. " is a static object or fortification (" .. unitType .. "), skipping unless in cargoUnits or CargoCookoffTarget")
						return false
					end
				if cargoUnits[unitType] then
					isCargoCandidate = true
					isCargoUnit = true
					debugCargoCookOff("Unit ID " .. unitID .. " identified as cargo candidate via cargoUnits table")
				elseif unitName:find("CargoCookoffTarget") then
					isCargoCandidate = true
					debugCargoCookOff("Unit ID " .. unitID .. " identified as cargo candidate via CargoCookoffTarget name")
				elseif splash_damage_options.smokeandcookoffeffectallvehicles then
					local isTruck = safeGet(function() return unit:hasAttribute("Trucks") end, false)
					local isUnarmedVehicle = safeGet(function() return unit:hasAttribute("Unarmed vehicles") end, false)
					if isTruck and isUnarmedVehicle then
						isCargoCandidate = true
						debugCargoCookOff("Unit ID " .. unitID .. " identified as cargo candidate via smokeandcookoffeffectallvehicles (truck/unarmed)")
					end
				end
				return true
			end)
			if not status or err == false then
				debugCargoCookOff("Error extracting unit data for event " .. eventName .. ": " .. tostring(err))
			elseif unitID == "unavailable" then
				debugCargoCookOff("Skipping event " .. eventName .. " for invalid unit ID: " .. tostring(unitID))
			elseif processedCookoffs[unitID] then
				debugCargoCookOff("Unit ID " .. unitID .. " already triggered cookoff for event " .. eventName .. ", skipping")
			elseif not isCargoCandidate then
				debugCargoCookOff("Unit ID " .. unitID .. " not a cargo candidate, skipping")
			else
				if eventName == "HIT" then
					local healthPercent = maxHealth > 0 and (unitLife / maxHealth * 100) or 0
					debugCargoCookOff("Unit ID " .. unitID .. " hit, health: " .. unitLife .. "/" .. maxHealth .. " (" .. string.format("%.2f", healthPercent) .. "%)")
			            local damageThreshold = isCargoUnit and splash_damage_options.cargo_damage_threshold or splash_damage_options.allunits_damage_threshold
			            if healthPercent <= damageThreshold or unitLife <= 0 then
						CargoCookoffPendingTable[unitID] = {
							id = unitID,
							name = unitName,
							type = unitType,
							coords = rawCoords,
							prevCoords = rawCoords,
							unit = unit,
							startTime = timer.getTime(),
							isCargoCookoff = true,
							isDead = unitLife <= 0
						}
						markProcessedUnitGlobal(unitID, {
							id = unitID,
							name = unitName,
							
							type = unitType,
							position = unitPosition,
							life = unitLife,
							event = eventName,
							time = timer.getTime()
						})
						markProcessedCookoff(unitID)
						debugCargoCookOff("Added unit ID " .. unitID .. " to CargoCookoffPendingTable")
						debugCargoCookOff("Marked unit ID " .. unitID .. " as processed in processedUnitsGlobal and processedCookoffs")
						debugCargoCookOff("Triggering cookoff for unit ID " .. unitID .. ", isCargoUnit: " .. tostring(isCargoUnit))
						scheduleCargoEffects(unitType, unitName, unitID, 0, false) --Pass fromDeadEvent = false
					end
				elseif eventName == "KILL" then
					debugCargoCookOff("Unit ID " .. unitID .. " triggered KILL, processing")
					CargoCookoffPendingTable[unitID] = {
						id = unitID,
						name = unitName,
						type = unitType,
						coords = rawCoords,
						prevCoords = rawCoords,
						unit = unit,
						startTime = timer.getTime(),
						isCargoCookoff = true,
						isDead = true
					}
					markProcessedUnitGlobal(unitID, {
						id = unitID,
						name = unitName,
						type = unitType,
						position = unitPosition,
						life = unitLife,
						event = eventName,
						time = timer.getTime()
					})
					markProcessedCookoff(unitID)
					debugCargoCookOff("Added unit ID " .. unitID .. " to CargoCookoffPendingTable")
					debugCargoCookOff("Marked unit ID " .. unitID .. " as processed in processedUnitsGlobal and processedCookoffs")
					debugCargoCookOff("Triggering cookoff for unit ID " .. unitID .. ", isCargoUnit: " .. tostring(isCargoUnit))
					scheduleCargoEffects(unitType, unitName, unitID, 0, false) --Pass fromDeadEvent = false
				elseif eventName == "DEAD" then
					debugCargoCookOff("Unit ID " .. unitID .. " triggered DEAD, processing")
					local coords = CargoCookoffPendingTable[unitID] and CargoCookoffPendingTable[unitID].coords or rawCoords
					if unitPosition ~= "unavailable" and coords.x == 0 and coords.y == 0 and coords.z == 0 then
						local newCoords = {
							x = tonumber(unitPosition:match("x=(.-),")) or 0,
							y = tonumber(unitPosition:match("y=(.-),")) or 0,
							z = tonumber(unitPosition:match("z=(.-)$")) or 0
						}
						if newCoords.x ~= 0 or newCoords.y ~= 0 or newCoords.z ~= 0 then
							coords = newCoords
							debugCargoCookOff("Updated coords from unitPosition for unit ID " .. unitID .. ": X=" .. coords.x .. ", Z=" .. coords.z)
						end
					end
					if not coords or (coords.x == 0 and coords.y == 0 and coords.z == 0) then
						debugCargoCookOff("Skipping cookoff for unit ID " .. unitID .. " due to invalid coordinates (X: 0, Z: 0)")
					else
						CargoCookoffPendingTable[unitID] = {
							id = unitID,
							name = unitName,
							type = unitType,
							coords = coords,
							prevCoords = coords,
							unit = nil, --Unit is dead
							startTime = timer.getTime(),
							isCargoCookoff = true,
							isDead = true
						}
						markProcessedUnitGlobal(unitID, {
							id = unitID,
							name = unitName,
							type = unitType,
							position = unitPosition,
							life = unitLife,
							event = eventName,
							time = timer.getTime()
						})
						markProcessedCookoff(unitID)
						debugCargoCookOff("Marked unit ID " .. unitID .. " as processed in processedUnitsGlobal and processedCookoffs")
						debugCargoCookOff("Triggering cookoff for unit ID " .. unitID .. " at X: " .. coords.x .. ", Z: " .. coords.z .. ", isCargoUnit: " .. tostring(isCargoUnit))
						scheduleCargoEffects(unitType, unitName, unitID, 0, true) --Pass fromDeadEvent = true
						CargoCookoffPendingTable[unitID] = nil
					end
				end
			end
		end
 	
	
	
end



function WpnHandler:onEvent(event)
	onWpnEvent(event)
		if event.id == world.event.S_EVENT_HIT then
			logEvent("HIT", event)
		elseif event.id == world.event.S_EVENT_KILL then
			logEvent("KILL", event)
			onKillEvent(event)
		elseif event.id == world.event.S_EVENT_DEAD then
			logEvent("DEAD", event)
            onDeadEvent(event)
    end
end

--kill feed event function
function onKillEvent(event)
    if not splash_damage_options.killfeed_enable or event.id ~= world.event.S_EVENT_KILL then return end
    local killedUnit = event.target
    local killer = event.initiator
    local currentTime = timer.getTime()

    if not killedUnit then
        if splash_damage_options.killfeed_debug then
            env.info(string.format("KillFeed: Skipped, no target at %.2f", currentTime))
        end
        return
    end

    local unitName = safeGet(function() return killedUnit:getName() end, "unknown")
    local unitType = safeGet(function() return killedUnit:getTypeName() end, "unknown")
    local unitID = safeGet(function() return killedUnit:getID() end, "unavailable")
    local position = safeGet(function()
        local pos = killedUnit:getPoint()
        return {x = pos.x, y = pos.y, z = pos.z}
    end, {x = 0, y = 0, z = 0})

    if unitName == "unknown" or unitType == "unknown" or unitID == "unavailable" or unitID == 0 then
        return
    end

    pruneKillfeedEntries(currentTime)

    if killfeedByUnitId[unitID] then
        if splash_damage_options.killfeed_debug then
            env.info(string.format("KillFeed: Skipped unit ID %s (%s) already in killfeedTable at %.2f", unitID, unitType, currentTime))
        end
        return
    end

    local killerName = resolvePlayerName(killer)
    local killerUnitName = safeGet(function() return killer:getName() end, "Unknown")
    if splash_damage_options.killfeed_debug then
        env.info(string.format("KillFeed: Killer UnitName: %s, PlayerName: %s, UnitID: %s, Type: %s",
            killerUnitName, killerName, unitID, unitType))
    end

    if splashKillfeedByUnitId[unitID] then
        local dupeMsg = string.format("Duplicate kill: %s (%s) [ID: %s]", unitName, unitType, unitID)
        if splash_damage_options.killfeed_debug then
            env.info(string.format("KillFeed: %s at %.2f", dupeMsg, currentTime))
        end
        removeSplashKillEntryByUnitId(unitID)
        if splash_damage_options.killfeed_debug then
            env.info(string.format("SplashKillFeed: Removed duplicate entry for unit ID %s (%s) at %.2f",
                unitID, unitType, currentTime))
        end
    end

    addKillfeedEntry({
        unitName = unitName,
        unitType = unitType,
        unitID = unitID,
        killer = killerName,
        time = currentTime,
        position = position
    })

    if splash_damage_options.killfeed_debug then
        env.info(string.format("KillFeed: Recorded %s destroyed by %s [ID: %s] at %.2f",
            unitType, killerName, unitID, currentTime))
    end
end


--kill feed event function
function onDeadEvent(event)
    if not splash_damage_options.killfeed_enable or event.id ~= world.event.S_EVENT_DEAD then return end
    local deadUnit = event.initiator
    local currentTime = timer.getTime()

    if not deadUnit then
        if splash_damage_options.killfeed_debug then
            env.info(string.format("DeadFeed: Skipped, no initiator at %.2f", currentTime))
        end
        return
    end

    local unitID = safeGet(function() return deadUnit:getID() end, "unavailable")
    local unitName = safeGet(function() return deadUnit:getName() end, "unknown")
    local unitType = safeGet(function() return deadUnit:getTypeName() end, "unknown")
    local position = safeGet(function()
        local pos = deadUnit:getPoint()
        return {x = pos.x, y = pos.y, z = pos.z}
    end, {x = 0, y = 0, z = 0})

    if unitName == "unknown" or unitType == "unknown" or unitID == "unavailable" or unitID == 0 then
        if splash_damage_options.killfeed_debug then
            env.info(string.format("DeadFeed: Skipped unit ID %s with name %s and type %s at %.2f", tostring(unitID), unitName, unitType, currentTime))
        end
        return
    end

    pruneKillfeedEntries(currentTime)

    if killfeedByUnitId[unitID] then
        if splash_damage_options.killfeed_debug then
            env.info(string.format("DeadFeed: Skipped unit ID %s (%s) already in killfeedTable at %.2f", unitID, unitType, currentTime))
        end
        return
    end

    timer.scheduleFunction(function(params)
        local unitID = params.unitID
        local unitName = params.unitName
        local unitType = params.unitType
        local position = params.position
        local currentTime = timer.getTime()

        pruneKillfeedEntries(currentTime)
        if killfeedByUnitId[unitID] then
            if splash_damage_options.killfeed_debug then
                env.info(string.format("DeadFeed: Skipped unit ID %s (%s) already in killfeedTable at %.2f", unitID, unitType, currentTime))
            end
            return
        end

        if splashKillfeedByUnitId[unitID] or splashKillfeedTempByUnitId[unitID] then
            if splash_damage_options.killfeed_debug then
                env.info(string.format("DeadFeed: Preserving splash attribution for unit ID %s (%s) at %.2f", unitID, unitType, currentTime))
            end
            return
        end

        addKillfeedEntry({
            unitName = unitName,
            unitType = unitType,
            unitID = unitID,
            killer = "Unknown",
            time = currentTime,
            position = position
        })

        if splash_damage_options.killfeed_game_messages then
            local msg = string.format("%s destroyed", unitType)
            trigger.action.outTextForCoalition(2, msg, splash_damage_options.killfeed_game_message_duration)
        end

        if splash_damage_options.killfeed_debug then
            env.info(string.format("DeadFeed: Recorded %s destroyed [ID: %s] at %.2f", unitType, unitID, currentTime))
        end
    end, {
        unitID = unitID,
        unitName = unitName,
        unitType = unitType,
        position = position
    }, timer.getTime() + 2)
end



function explodeObject(args)
    local point = args[1]
    local distance = args[2]
    local power = args[3]
    trigger.action.explosion(point, power)
end
  
function blastWave(_point, _radius, weapon, power, isShapedCharge)
    local weaponData = explTable[weapon] or { Skip_damage_model = false, Skip_larger_explosions = false }
    if isShapedCharge then
        _radius = _radius * splash_damage_options.shaped_charge_multiplier
    end
    if splash_damage_options.use_dynamic_blast_radius then
        local dynamicRadius = math.pow(power, 1/3) * 5 * splash_damage_options.dynamic_blast_radius_modifier
        _radius = isShapedCharge and dynamicRadius * splash_damage_options.shaped_charge_multiplier or dynamicRadius
    end
    if splash_damage_options.debug then
        debugMsg("blastWave called for weapon '" .. weapon .. "' at X: " .. _point.x .. ", Y: " .. _point.y .. ", Z: " .. _point.z .. " with power " .. power .. " and radius " .. _radius .. "m")
    end
    
    local foundUnits = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = _point,
            radius = _radius
        }
    }
  
    local ifFound = function(foundObject, val)
        if foundObject:getDesc().category == Unit.Category.GROUND_UNIT and foundObject:getCategory() == Object.Category.UNIT then
            foundUnits[#foundUnits + 1] = foundObject
        end
        if foundObject:getDesc().category == Unit.Category.GROUND_UNIT and splash_damage_options.blast_stun then
            --suppressUnit(foundObject, 2, weapon) --Not implemented, commented out
        end
        if splash_damage_options.wave_explosions then
            local obj = foundObject
            local obj_location = obj:getPoint()
            local dist = getDistance(_point, obj_location)
            if dist > 1 then --Avoid re-exploding at exact impact point
            local timing = dist / 500
            if obj:isExist() and tableHasKey(obj:getDesc(), "box") then
                local length = (obj:getDesc().box.max.x + math.abs(obj:getDesc().box.min.x))
                local height = (obj:getDesc().box.max.y + math.abs(obj:getDesc().box.min.y))
                local depth = (obj:getDesc().box.max.z + math.abs(obj:getDesc().box.min.z))
                local _length = length
                local _depth = depth
                if depth > length then 
                    _length = depth 
                    _depth = length
                end
                local surface_distance = dist - _depth / 2
                local scaled_power_factor = 0.006 * power + 1
                local intensity = (power * scaled_power_factor) / (4 * math.pi * surface_distance^2)
                --Apply ground ordnance blastwave modifier
                local weaponData = explTable[weapon] or {}
                if splash_damage_options.track_groundunitordnance and weaponData.groundordnance then
                    intensity = intensity * splash_damage_options.groundunitordnance_blastwave_modifier
                    if splash_damage_options.track_groundunitordnance_debug then
                        debugMsg("Applied groundunitordnance_blastwave_modifier " .. splash_damage_options.groundunitordnance_blastwave_modifier .. " to " .. weapon .. ", intensity now: " .. intensity)
                    end
                end
                local surface_area = _length * height
                local damage_for_surface = intensity * surface_area
                    if splash_damage_options.debug then
                        debugMsg("Processing unit '" .. obj:getTypeName() .. "' at dist=" .. string.format("%.1f", dist) .. "m: intensity=" .. string.format("%.4f", intensity) .. ", surface_area=" .. string.format("%.2f", surface_area) .. ", damage_for_surface=" .. string.format("%.4f", damage_for_surface))
                    end
                if damage_for_surface > splash_damage_options.cascade_damage_threshold then
                    local explosion_size = damage_for_surface
                    if obj:getDesc().category == Unit.Category.STRUCTURE then
                        explosion_size = intensity * splash_damage_options.static_damage_boost
                    end
                    if explosion_size > power then explosion_size = power end
                    local triggerExplosion = false
                    if splash_damage_options.always_cascade_explode then
                            triggerExplosion = true
                            if splash_damage_options.debug then
                                debugMsg("Triggering secondary explosion for '" .. obj:getTypeName() .. "' due to always_cascade_explode")
                            end
                        else
                            if obj:getDesc().life then
                                local health = obj:getLife() or 0
                                local maxHealth = obj:getDesc().life or 1
                                local healthPercent = (health / maxHealth) * 100
                                if splash_damage_options.debug then
                                    debugMsg("Health check for '" .. obj:getTypeName() .. "': " .. health .. "/" .. maxHealth .. " (" .. string.format("%.2f", healthPercent) .. "%) vs threshold " .. splash_damage_options.cascade_explode_threshold)
                                end
                                if healthPercent <= splash_damage_options.cascade_explode_threshold then
                                    triggerExplosion = true
                                end
                            else
                                triggerExplosion = true
                                if splash_damage_options.debug then
                                    debugMsg("Triggering secondary explosion for '" .. obj:getTypeName() .. "' (no life data)")
                                end
                            end
                            if not triggerExplosion and obj:getDesc().category == Unit.Category.GROUND_UNIT then
                                local health = obj:getLife() or 0
                                if health <= 0 then
                                    triggerExplosion = true
                                    if splash_damage_options.debug then
                                        debugMsg("Triggering secondary explosion for '" .. obj:getTypeName() .. "' (health <= 0)")
                                    end
                                end
                            end
                        end
                            --Queue cargo effects for units below
                        if obj:getDesc().life then
                            local healthPercent = (obj:getLife() / obj:getDesc().life) * 100
                            local cargoData = cargoUnits[obj:getTypeName()]
                            if cargoData and healthPercent <= splash_damage_options.cargo_damage_threshold and splash_damage_options.enable_cargo_effects then
                                local cargoPower = power
                                table.insert(cargoEffectsQueue, {
                                    name = obj:getTypeName(),
                                    distance = dist,
                                    coords = obj_location,
                                    power = cargoPower,
                                    explosion = cargoData.cargoExplosion,
                                    cookOff = cargoData.cargoCookOff,
                                    cookOffCount = cargoData.cookOffCount,
                                    cookOffPower = cargoData.cookOffPower,
                                    cookOffDuration = cargoData.cookOffDuration,
                                    cookOffRandomTiming = cargoData.cookOffRandomTiming,
                                    cookOffPowerRandom = cargoData.cookOffPowerRandom,
                                    isTanker = cargoData.isTanker,
                                    flameSize = cargoData.flameSize,
                                    flameDuration = cargoData.flameDuration
                                })
                                if splash_damage_options.debug then
                                    debugMsg("Queued cargo effect for '" .. obj:getTypeName() .. "' with power " .. cargoPower)
                                end
                            end
                    end
                    if triggerExplosion then
                            local final_power = explosion_size * splash_damage_options.cascade_scaling
                            if splash_damage_options.debug then
                                debugMsg("Scheduling secondary explosion for '" .. obj:getTypeName() .. "' at X: " .. obj_location.x .. ", Y: " .. obj_location.y .. ", Z: " .. obj_location.z .. ", dist=" .. string.format("%.1f", dist) .. "m, power=" .. string.format("%.2f", final_power))
                            end
                            if splash_damage_options.track_groundunitordnance_debug and weaponData.groundordnance then
                                debugMsg("Calculated power for '" .. obj:getTypeName() .. "' at X: " .. obj_location.x .. ", Y: " .. obj_location.y .. ", Z: " .. obj_location.z .. ", distance " .. dist .. "m: " .. final_power)
                            end
                            local playerName = tracked_weapons[weapon] and tracked_weapons[weapon].init or "unknown"
                            timer.scheduleFunction(function(args)
                                local obj = args[1]
                                local playerName = args[2]
                                if obj:isExist() and obj:getLife() <= 0 then
                                    debugMsg("Unit '" .. obj:getTypeName() .. "' destroyed by secondary explosion, credited to player: " .. playerName)
                                end
                            end, {obj, playerName}, timer.getTime() + timing + 0.1)
                            timer.scheduleFunction(explodeObject, {obj_location, dist, final_power}, timer.getTime() + timing)
                        else
                            if splash_damage_options.debug then
                                debugMsg("No secondary explosion for '" .. obj:getTypeName() .. "': health above threshold (" .. string.format("%.2f", (obj:getLife() / obj:getDesc().life) * 100) .. "% > " .. splash_damage_options.cascade_explode_threshold .. "%)")
                            end
                        end
                    else
                        if splash_damage_options.debug then
                            debugMsg("No secondary explosion for '" .. obj:getTypeName() .. "': damage_for_surface=" .. string.format("%.4f", damage_for_surface) .. " below threshold " .. splash_damage_options.cascade_damage_threshold)
                        end
                    end
                end
            end
        end
        return true
    end
  
    --Search all relevant object categories
    if splash_damage_options.debug then
        debugMsg("Scanning for objects within " .. _radius .. "m radius")
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    world.searchObjects(Object.Category.STATIC, volS, ifFound)
    world.searchObjects(Object.Category.SCENERY, volS, ifFound)
    world.searchObjects(Object.Category.CARGO, volS, ifFound)
    if splash_damage_options.debug then
        debugMsg("Found " .. #foundUnits .. " ground units for damage modeling")
    end
--[[     --Apply damage model if enabled and not skipped
    if splash_damage_options.damage_model and not (weaponData.Skip_damage_model or false) then
        timer.scheduleFunction(modelUnitDamage, foundUnits, timer.getTime() + 1.5)
    elseif splash_damage_options.debug and (weaponData.Skip_damage_model or false) then
        debugMsg("Skipped damage model application for '" .. weapon .. "' due to Skip_damage_model = true")
    end ]]
end
 
 
function modelUnitDamage(units)
    for i, unit in ipairs(units) do
        if unit:isExist() then
            local health = (unit:getLife() / unit:getDesc().life) * 100
            if unit:hasAttribute("Infantry") and health > 0 then
                if health <= splash_damage_options.infantry_cant_fire_health then
                    unit:getController():setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
                end
            end
            if unit:getDesc().category == Unit.Category.GROUND_UNIT and (not unit:hasAttribute("Infantry")) and health > 0 then
                if health <= splash_damage_options.unit_cant_fire_health then
                    unit:getController():setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
                    --gameMsg(unit:getTypeName() .. " weapons disabled")
                end
                if health <= splash_damage_options.unit_disabled_health and health > 0 then
                    unit:getController():setTask({id = 'Hold', params = {}})
                    unit:getController():setOnOff(false)
                    --gameMsg(unit:getTypeName() .. " disabled")
                end
            end
        end
    end
end

if (script_enable == 1) then
    gameMsg("SPLASH DAMAGE 3.4 SCRIPT RUNNING")
    env.info("SPLASH DAMAGE 3.4 SCRIPT RUNNING")

	timer.scheduleFunction(function()
        track_wpns()
        return timer.getTime() + refreshRate
    end, {}, timer.getTime() + refreshRate)

    world.addEventHandler(WpnHandler)
    timer.scheduleFunction(pruneProcessedStateTables, {}, timer.getTime() + PROCESSED_STATE_PRUNE_INTERVAL_SECONDS)
	
	--Lekas integration
	if splash_damage_options.killfeed_enable and splash_damage_options.killfeed_lekas_foothold_integration then
		timer.scheduleFunction(processSplashKillfeed, {}, timer.getTime() + 60)
		if splash_damage_options.killfeed_debug then
			env.info("SplashDamage: Scheduled process SplashKillfeed for Lekas Foothold integration")
		end
	end	
	
	--Strobe
	if splash_damage_options.StrobeMarker_allstrobeunits then
		scanStrobeUnits()
		timer.scheduleFunction(triggerStrobeMarker, {}, timer.getTime() + splash_damage_options.StrobeMarker_interval)
		--env.info("SPLASH DAMAGE: StrobeMarker initialized with interval " .. splash_damage_options.StrobeMarker_interval .. " seconds")
	end

	if splash_damage_options.StrobeMarker_individuals then
		scanStrobeUnits()
		initIndividualStrobeUnits()
		createStrobeRadioMenu()
		--env.info("SPLASH DAMAGE: Individual StrobeMarker initialized")
	end


end

end

--[[-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=
                            		##### Changelog #####
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =--=-=-=-=-=-=-=
   
    24th May 2025 - 3.3

		(Stevey666) 
		
	  - Added some naval weapons into weapon/expl table
	  - Added some ground unit ordnance to explosive table and allowing a wider area to be tracked
	  - Game_mesages defaulted to false in the non debug script.
			-Please be advised that the non debug script has these two defaulted to false, so that users don't see that the script is in use nor can they access the test/config radio options.  
			-Set either to true as required.   The notice that the Splash Damage 3.x is running uses game_messsages.
	  - Added optional cook-off effect - signal flares firing at random throughout the cook-off (see cookoff_flares_enabled). Not sure if I like this one so leaving in as optional
	  - Reduced cargo cook off initial explosion values as they were a little too high
	  - New feature: Napalm. MK77 A4 Skyhawk Napalm and Optional Napalm weapon override - Allows napalm effects, overriding specific weapons set in options is possible too.
	  		- This feature has been adapated from titi69's Napalm script https://www.digitalcombatsimulator.com/en/files/3340469/ , credit to him and the Olympus mod team for the Napalm method

	    (Sniex)
	    
	  - Added weapon types in the weapon/expl
	  - Adjusted some rocket explosive power numbers (+1 or 2)
	  - Adjusted explosive power for anti radar, ship missile, cruise missile and some others
	  - Increased script readability
	  
	    (Kurdes)
	    
	  - Added changed/missing JF17 ordnance to weapons table
	  - Added JF29 mod ordnance to the weapons table
	  
    10 May 2025 (Stevey666) - 3.2
	  - New feature (user request): ground ordnance tracking, this tracks ground artillery etc if in the explosives table, set to false by default.
	  - New feature (user request): option to create additional smoke and cargo cookoff effect for all ground vehicles initially destroyed by your ordnance or the script, set to false by default.
	  - Adjusted blastwave explosion
	  - Changes to debug output, ordering by vehicle distance
	  - Thanks to tae. for the report, adjusted Ural-4320 in vehicle table, had incorrect name so wasn't triggering cook off.
	  - Fixed error popup when using Mig 21's SPRD-99
	  - Added Cargo Cook off / fireball to some static objects i.e crates/barrels
	  - Reworked Giant Explosion tracking - no mission editor trigger needed, just name static unit or unit "GiantExplosionTarget[X]"
	  - Allow for Giant Explosion trigger on damage or on death

    04 April 2025 (Stevey666) - 3.1
	  - Set default cluster munitions option to false, set this to true in the options if you want it
      - Added missing radio commands for Cascade Scaling
	  - Adjust default cascading to 2 (from 1)
	  - Adjusted Ural-4320 to be a tanker and ammo carrier for cargo cookoff
	  - Prevent weapons not in the list from being tracked
	  - Moved some logging behind the debug mode flag
	  - Ordnance Protection, added a max height ordnance protection will snap explosion to ground
	  - Ordnance Protection, fixed enable/disable option
	  - Added Giant Explosion feature
	  - Adjusted some hydra70 values on recom. from ETBSmorgan
	  
	  
    09 March 2025 (Stevey666) - 3.0
      - Added ordinance protection gives a few options - stop the additional larger_explosion that tends to blow up your own bombs if theyre dropped at the same place if its within x m
	  - Additional ordnance protection option that will cause a snap to ground larger_explosion if its within x meters of a recent larger explosion and within x seconds (can set in options)
      - Added vehicle scanning around a weapon to allow for..
	  - Cook offs - you can set vehicles that will cook off i.e ammo trucks, number of explosions, debris explosions, power adjustable
	  - Fuel/Tanker explosion and flames - when a fuel tanker blows it will through up a big flame - adjustable in the scripts
	  - Added section for vehicles for the above
	  - Added radio commands for everything
	  - Added in cluster munitions changes (note: barely tested, its not particularly accurate or that useful at this point so leaving disabled)
	  - Potential bug - testing, stacking too many units together may cause a MIST error if you're using mist
	  
	  - Setting this as 3.0 as I'd like to be responsive to requests, updates etc - creating a new fork to track this
	

    10 Feb 2025 (Stevey666) - 2.0.7
      - Fixed AGM 154/Adjusted weapons
      - Added overall damage scaling 
      - Added modifier for shaped charges (i.e. Mavericks), adjusted weapon list accordingly
      - Adjusted blast radius and damage calculations, created option for dynamic blast radius
      - Adjusted cascading explosions, added additional "cascade_scaling" modifier and cascade explode threshold modifier. Units wont explode on initial impact unless health drops under threshold
      - Added always_cascade_explode option so you can set it to the old ways of making everything in the blast wave go kaboom
      - Added in game radio commands to change the new options ingame without having to reload everything in mission editor to test it out

    12 November 2024 (by JGi | Quéton 1-1)
    - Tweak down radius 100>90 (Thanks Arhibeau)
    - Tweak down some values

    20 January 2024 (by JGi | Quéton 1-1)
    - Added missing weapons to explTable
    - Sort weapons in explTable by type
    - Added aircraft type in log when missing

    03 May 2023 (KERV)
      Correction AGM 154 (https://forum.dcs.world/topic/289290-splash-damage-20-script-make-explosions-better/page/5/#comment-5207760)
  
    06 March 2023 (Kerv)
    - Add some data for new ammunition

    16 April 2022
      spencershepard (GRIMM):
      - Added new/missing weapons to explTable
      - Added new option rocket_multiplier

    31 December 2021
      spencershepard (GRIMM):
      - Added many new weapons
      - Added filter for weapons.shells events
      - Fixed mission weapon message option
      - Changed default for damage_model option
  
    21 December 2021
      spencershepard (GRIMM):
      SPLASH DAMAGE 2.0:
      - Added blast wave effect to add timed and scaled secondary explosions on top of game objects
      - Object geometry within blast wave changes damage intensity
      - Damage boost for structures since they are hard to kill, even if very close to large explosions
      - Increased some rocket values in explTable
      - Missing weapons from explTable will display message to user and log to DCS.log so that we can add what's missing
      - Damage model for ground units that will disable their weapons and ability to move with partial damage before they are killed
      - Added options table to allow easy adjustments before release
      - General refactoring and restructure

    28 October 2020
      FrozenDroid: 
      - Uncommented error logging, actually made it an error log which shows a message box on error.
      - Fixed the too restrictive weapon filter (took out the HE warhead requirement)

    2 October 2020
      FrozenDroid:
      - Added error handling to all event handler and scheduled functions. Lua script errors can no longer bring the server down.
      - Added some extra checks to which weapons to handle, make sure they actually have a warhead (how come S-8KOM's don't have a warhead field...?)

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=
                            		##### END of Changelog #####
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-]]
