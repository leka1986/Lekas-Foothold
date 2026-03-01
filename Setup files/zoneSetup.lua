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
	carrier = {
		blue = {'bShip','bShip'},
		red = {}
	},
	airfield = {
		blue = {'bInfantry','bArmor','bluePD2','bluePD1','blueHAWK','bArmor'},
		red = {'rInfantry','Red SAM AAA','Red Armored group','Red SAM SA-3','Red SAM SA-6','Red SAM SHORAD SA-15','Red SAM SHORAD SA-15'}
	},
	farp = {
		blue = {'bInfantry','bArmor','bluePD2'},
		red = {'rInfantry','Red Armored group','Red SAM AAA','Red SAM AAA 2','Red SAM SA-3','Red SAM SHORAD SA-15'}
	},
	regularzone = {
		blue = {'bInfantry','bArmor','bSamIR',},
		red = {'rInfantry','Red Armored group','Red SAM AAA','Red SAM AAA 2','Red SAM SHORAD SA-13'}
	},
	specialSAM = {
		blue = {'bInfantry','bSamIR','bInfantry','bInfantry','bluePD1'},
		red = {'Red SAM SHORAD SA-13','Red SAM SHORAD SA-15','Red SAM AAA','rInfantry','Red SAM AAA 2','Red SAM SA-2','Red Armored group'}
	},
	specialKrasnodar = {
		blue = {'bInfantry','bSamIR','bluePD2','blueHAWK','bluePD1'},
		red = {'rInfantry','Red SAM AAA','Red SAM AAA 2','Red SAM SA-6','Red SAM SHORAD SA-15','Red SAM SHORAD SA-15','Red SAM SA-2','Red SAM SA-11'}
	},
	convoy = {
		blue = {'bInfantry'},
		red = {'Red SAM AAA','rInfantry','Red Armored group'}
	}
}


flavor = {
	anapa = 'WPT 1\nHome base',
	carrier = 'Carrier group',
	alpha='WPT 2\nDefensive position next to the town of Natuhaevskaya',
	bravo='WPT 3\nFARP next to the town of Damanka.\nWill let us launch helicopter attacks from a bit closer to the action.',
	charlie='WPT 4\nDefensive position next to an old TV tower.\nWill provide allied air patrol to help capture Bravo',
	convoy='WPT 5\nSupply convoy detained north of Bravo.\nKeep damage to the trucks to a minimum while liberating this area.\nWe could really use the supplies.',
	krymsk='WPT 7\nAirbase next to the city of Krymsk.\nCapturing it will provide us with valuable aircraft to use for our cause.',
	radio='WPT 8\nRadio atenna on the outskirts of Krymsk.\nIf we capture it, we can launch AWACS from the nearby airport\nto get some much needed intel on the enemy.',
	oilfields='WPT 6\nOil extraction and Refinery north of Krymsk.\nCapture it to get a steady stream of income, or just destroy it to put a hole in the enemy wallet.',
	delta='WPT 10\nDefensive position out in the middle of nowhere',
	factory='WPT 9\nWeapon factory next to the town of Homskiy.\nWe can use it to resupply nearby bases.\nIt will also provide a steady stream of income.',
	samsite='WPT 11\nHome to an old SA-2 site.\nIf we capture it, we might be able to get some use out of it.',
	foxtrot='WPT 13\nDefensive position with a nice view of a lake',
	echo='WPT 12\nFARP next to the city of Krasnodar.\nCapturing it will let us operate our helicopters in the area.',
	krasnodar='WPT 14\nAirbase next to the city of Krasnodar.\nThe home base of our enemy. Capture it to deprive them of their most valuable asset.'
}

local filepath = 'foothold_Classic_by_leka.lua'
if lfs then 
	local dir = lfs.writedir()..'Missions/Saves/'
	lfs.mkdir(dir)
	filepath = dir..filepath
	env.info('Foothold - Save file path: '..filepath)
end

WaypointList = {
    Anapa = ' (1)',
    Alpha = ' (2)',
    Bravo = ' (3)',
    Charlie = ' (4)',
    Convoy = ' (5)',
    ["Oil Fields"] = ' (6)',
    Krymsk = ' (7)',
    ["Radio Tower"] = ' (8)',
    Factory = ' (9)',
    Delta = ' (10)',
    ["SAM Site"] = ' (11)',
    Echo = ' (12)',
    Foxtrot = ' (13)',
    Krasnodar = ' (14)'
}

bc = BattleCommander:new(filepath, 10, 60)
zones = {
anapa = ZoneCommander:new({zone='Anapa', side=2, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.anapa}),
carrier = ZoneCommander:new({zone='Carrier Group', side=2, level=20, upgrades=upgrades.carrier, crates={}, flavorText=flavor.carrier}),
alpha = ZoneCommander:new({zone='Alpha', side=0, level=20, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.alpha}),
bravo = ZoneCommander:new({zone='Bravo', side=1, level=20, upgrades=upgrades.farp, crates={}, flavorText=flavor.bravo}),
charlie = ZoneCommander:new({zone='Charlie', side=0, level=20, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.charlie}),
convoy = ZoneCommander:new({zone='Convoy', side=1, level=20, upgrades=upgrades.convoy, crates={}, flavorText=flavor.convoy}),
krymsk = ZoneCommander:new({zone='Krymsk', side=1, level=20, upgrades=upgrades.airfield, crates={}, flavorText=flavor.krymsk}),
oilfields = ZoneCommander:new({zone='Oil Fields', side=1, level=20, upgrades=upgrades.farp, crates={}, flavorText=flavor.oilfields, income=2}),
radio = ZoneCommander:new({zone='Radio Tower', side=1, level=20, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.radio}),
delta = ZoneCommander:new({zone='Delta', side=1, level=20, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.delta}),
factory = ZoneCommander:new({zone='Factory', side=1, level=20, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.factory, income=2}),
samsite = ZoneCommander:new({zone='SAM Site', side=0, level=20, upgrades=upgrades.specialSAM, crates={}, flavorText=flavor.samsite}),
foxtrot = ZoneCommander:new({zone='Foxtrot', side=1, level=20, upgrades=upgrades.regularzone, crates={}, flavorText=flavor.foxtrot}),
echo = ZoneCommander:new({zone='Echo', side=1, level=20, upgrades=upgrades.farp, crates={}, flavorText=flavor.echo}),
krasnodar = ZoneCommander:new({zone='Krasnodar', side=1, level=20, upgrades=upgrades.specialKrasnodar, crates={}, flavorText=flavor.krasnodar, income=2})
}
zones.radio:addCriticalObject('RadioTower')
zones.samsite:addCriticalObject('CommandCenter')
zones.factory:addCriticalObject('FactoryBuilding1')
zones.factory:addCriticalObject('FactoryBuilding2')
zones.convoy:addCriticalObject('convoy1')
zones.convoy:addCriticalObject('convoy2')
zones.convoy:addCriticalObject('convoy3')
zones.convoy:addCriticalObject('convoy4')

local oilbuildings = {'oilref1','oilref2'}
for i,v in ipairs(oilbuildings) do
	zones.oilfields:addCriticalObject(v)
end

zones.krymsk:addGroups({
	GroupCommander:new({name='krymsk-supply-Bravo', mission='supply', targetzone='Bravo'}),
	GroupCommander:new({name='krymsk-attack-Bravo', mission='attack', targetzone='Bravo'}),
	GroupCommander:new({name='krymsk-patrol-Bravo', mission='patrol',MissionType='CAP', targetzone='Bravo'}),
	GroupCommander:new({name='krymsk-patrol-Krymsk', mission='patrol',MissionType='CAP', targetzone='Krymsk'}),
	GroupCommander:new({name='krymsk-supply-Radio-Tower', mission='supply', targetzone='Radio Tower'}),
	GroupCommander:new({name='krymsk-attack-Radio-Tower', mission='attack', targetzone='Radio Tower'}),
	GroupCommander:new({name='krymsk-patrol-bravo-blue', mission='patrol', targetzone='Bravo'}),
	GroupCommander:new({name='krymsk-patrol-Krymsk-blue', mission='patrol', targetzone='Krymsk'}),
	GroupCommander:new({name='krymsk-supply-Bravo-blue', mission='supply', targetzone='Bravo'}),
	GroupCommander:new({name='krymsk-supply-Radio-Tower-blue', mission='supply', targetzone='Radio Tower'}),
	GroupCommander:new({name='krymsk-supply-Delta', mission='supply', targetzone='Delta'}),
	GroupCommander:new({name='krymsk-attack-Delta', mission='attack', targetzone='Delta'}),
	GroupCommander:new({name='krymsk-supply-Factory', mission='supply', targetzone='Factory'}),
	GroupCommander:new({name='krymsk-attack-Factory', mission='attack', targetzone='Factory'}),
	GroupCommander:new({name='krymsk-supply-Delta-Blue', mission='supply', targetzone='Delta'}),
	GroupCommander:new({name='krymsk-supply-Factory-blue', mission='supply', targetzone='Factory'}),
	GroupCommander:new({name='krymsk-supply-Sam-Site-blue', mission='supply', targetzone='SAM Site'}),
	GroupCommander:new({name='krymsk-supply-Sam-Site', mission='supply', targetzone='SAM Site'}),
	GroupCommander:new({name='krymsk-attack-SAM-Site', mission='attack', targetzone='SAM Site'}),
	GroupCommander:new({name='krymsk-patrol-Delta-blue', mission='patrol', targetzone='Delta'}),
	GroupCommander:new({name='krymsk-supply-Oil-Fields-blue', mission='supply', targetzone='Oil Fields'}),
	GroupCommander:new({name='krymsk-supply-Oil-Fields', mission='supply', targetzone='Oil Fields'}),
	GroupCommander:new({name='krymsk-attack-oil-fields', mission='attack', targetzone='Oil Fields'}),
	GroupCommander:new({name='krymsk-attack-Bravo-Ground', mission='attack', targetzone='Bravo', type='surface'})
})

zones.bravo:addGroups({
	GroupCommander:new({name='bravo-supply-Alpha', mission='supply', targetzone='Alpha'}),
	GroupCommander:new({name='bravo-attack-Alpha', mission='attack', targetzone='Alpha'}),
	GroupCommander:new({name='bravo-supply-Charlie', mission='supply', targetzone='Charlie'}),
	GroupCommander:new({name='bravo-attack-Charlie', mission='attack', targetzone='Charlie'}),
	GroupCommander:new({name='bravo-supply-krymsk', mission='supply', targetzone='Krymsk'}),
	GroupCommander:new({name='bravo-attack-krymsk', mission='attack', targetzone='Krymsk'}),
	GroupCommander:new({name='bravo-supply-Krymsk-blue', mission='supply', targetzone='Krymsk'}),
	GroupCommander:new({name='bravo-supply-Charlie-blue', mission='supply', targetzone='Charlie'}),
	GroupCommander:new({name='bravo-supply-Alpha-blue', mission='supply', targetzone='Alpha'}),
	GroupCommander:new({name='bravo-supply-Oil-Fields-blue', mission='supply', targetzone='Oil Fields'}),
	GroupCommander:new({name='bravo-supply-Oil-Fields', mission='supply', targetzone='Oil Fields'}),
	GroupCommander:new({name='bravo-attack-Oil-Fields', mission='attack', targetzone='Oil Fields'}),
	GroupCommander:new({name='bravo-supply-Convoy-Ground-blue', mission='supply', targetzone='Convoy', type='surface'})
})

zones.anapa:addGroups({
	GroupCommander:new({name='anapa-supply-Alpha-blue', mission='supply', targetzone='Alpha'}),
	GroupCommander:new({name='anapa-supply-Bravo-blue', mission='supply', targetzone='Bravo'}),
	GroupCommander:new({name='anapa-supply-Charlie-Blue', mission='supply', targetzone='Charlie'}),
	GroupCommander:new({name='anapa-patrol-Bravo-blue', mission='patrol', targetzone='Bravo'})
})

zones.charlie:addGroups({
	GroupCommander:new({name='anapa-attack-Bravo-blue', mission='attack', targetzone='Bravo'})
})

zones.factory:addGroups({
	GroupCommander:new({name='factory-supply-Krymsk-blue', mission='supply', targetzone='Krymsk'}),
	GroupCommander:new({name='factory-supply-Krymsk', mission='supply', targetzone='Krymsk'}),
	GroupCommander:new({name='factory-supply-Delta-blue', mission='supply', targetzone='Delta'}),
	GroupCommander:new({name='factory-supply-Delta', mission='supply', targetzone='Delta'}),
	GroupCommander:new({name='factory-supply-Foxtrot-blue', mission='supply', targetzone='Foxtrot'}),
	GroupCommander:new({name='factory-supply-Foxtrot', mission='supply', targetzone='Foxtrot'}),
	GroupCommander:new({name='factory-supply-Echo-Blue', mission='supply', targetzone='Echo'}),
	GroupCommander:new({name='factory-supply-Echo', mission='supply', targetzone='Echo'}),
	GroupCommander:new({name='factory-krymsk-supply', mission='supply', targetzone='Krymsk', type='surface'}),
	GroupCommander:new({name='factory-delta-supply', mission='supply', targetzone='Delta', type='surface'}),
	GroupCommander:new({name='factory-echo-supply', mission='supply', targetzone='Echo', type='surface'}),
	GroupCommander:new({name='factory-foxtrot-supply', mission='supply', targetzone='Foxtrot', type='surface'})
})

zones.echo:addGroups({
	GroupCommander:new({name='echo-supply-Sam-Site', mission='supply', targetzone='SAM Site'}),
	GroupCommander:new({name='echo-supply-Sam-Site-blue', mission='supply', targetzone='SAM Site'}),
	GroupCommander:new({name='echo-attack-Delta', mission='attack', targetzone='Delta'}),
	GroupCommander:new({name='echo-supply-Delta', mission='supply', targetzone='Delta'}),
	GroupCommander:new({name='echo-supply-Delta-blue', mission='supply', targetzone='Delta'}),
	GroupCommander:new({name='echo-supply-Factory', mission='supply', targetzone='Factory'}),
	GroupCommander:new({name='echo-supply-Factory-blue', mission='supply', targetzone='Factory'}),
	GroupCommander:new({name='echo-attack-Factory', mission='attack', targetzone='Factory'}),
	GroupCommander:new({name='echo-supply-Foxtrot', mission='supply', targetzone='Foxtrot'}),
	GroupCommander:new({name='echo-supply-Foxtrot-blue', mission='supply', targetzone='Foxtrot'}),
	GroupCommander:new({name='echo-attack-Foxtrot', mission='attack', targetzone='Foxtrot'}),
	GroupCommander:new({name='echo-supply-Krasnodar', mission='supply', targetzone='Krasnodar'}),
	GroupCommander:new({name='echo-supply-Krasnodar-blue', mission='supply', targetzone='Krasnodar'}),
	GroupCommander:new({name='echo-attack-Krasnodar', mission='attack', targetzone='Krasnodar'})
})

zones.krasnodar:addGroups({
	GroupCommander:new({name='krasnodar-supply-Echo', mission='supply', targetzone='Echo'}),
	GroupCommander:new({name='krasnodar-supply-Echo-blue', mission='supply', targetzone='Echo'}),
	GroupCommander:new({name='krasnodar-supply-Foxtrot', mission='supply', targetzone='Foxtrot'}),
	GroupCommander:new({name='krasnodar-supply-Foxtrot-blue', mission='supply', targetzone='Foxtrot'}),
	GroupCommander:new({name='krasnodar-attack-SAM-Site', mission='attack', targetzone='SAM Site'}),
	GroupCommander:new({name='krasnodar-attack-Krymsk', mission='attack', targetzone='Krymsk'}),
	GroupCommander:new({name='krasnodar-attack-Radio-Tower', mission='attack', targetzone='Radio Tower'}),
	GroupCommander:new({name='krasnodar-attack-Factory', mission='attack', targetzone='Factory'}),
	GroupCommander:new({name='krasnodar-attack-Echo', mission='attack', targetzone='Echo'}),
	GroupCommander:new({name='krasnodar-attack-Foxtrot', mission='attack', targetzone='Foxtrot'}),
	GroupCommander:new({name='krasnodar-patrol-Echo', mission='patrol',MissionType='CAP', targetzone='Echo'}),
	GroupCommander:new({name='krasnodar-patrol-Delta', mission='patrol', MissionType='CAP', targetzone='Delta'}),
	GroupCommander:new({name='krasnodar-patrol-Factory', mission='patrol', MissionType='CAP', targetzone='Factory'})
})

zones.foxtrot:addGroups({
	--GroupCommander:new({name='foxtrot-krymsk-attack', mission='attack', targetzone='Krymsk', type='surface'}),
	GroupCommander:new({name='foxtrot-echo-attack', mission='attack', targetzone='Echo', type='surface'})
})

zones.oilfields:addGroups({
	GroupCommander:new({name='oil-krymsk-supply', mission='supply', targetzone='Krymsk', type='surface'})
})

for i,v in pairs(zones) do
	bc:addZone(v)
end

bc:addConnection("Anapa","Alpha")
bc:addConnection("Alpha","Bravo")
bc:addConnection("Bravo","Krymsk")
bc:addConnection("Bravo","Charlie")
bc:addConnection("Bravo","Convoy")
bc:addConnection("Anapa","Charlie")
bc:addConnection("Bravo","Oil Fields")
bc:addConnection("Krymsk","Oil Fields")
bc:addConnection("Krymsk","Radio Tower")
bc:addConnection("Krymsk","Factory")
bc:addConnection("Krymsk","Delta")
bc:addConnection("Factory","Delta")
bc:addConnection("Factory","Foxtrot")
bc:addConnection("Factory","Echo")
bc:addConnection("Delta","Echo")
bc:addConnection("Foxtrot","Krasnodar")
bc:addConnection("Echo","Krasnodar")
bc:addConnection("Echo","SAM Site")
bc:addConnection("Krymsk","SAM Site")

zones.anapa.isHeloSpawn = true
zones.anapa.airbaseName = 'Anapa-Vityazevo'

zones.carrier.isHeloSpawn = true

zones.krymsk.isHeloSpawn = true
zones.krymsk.airbaseName = 'Krymsk'

zones.krasnodar.isHeloSpawn = true
zones.krasnodar.airbaseName = 'Krasnodar-Pashkovsky'

zones.echo.isHeloSpawn = true
zones.echo.airbaseName = 'Echo'

zones.bravo.isHeloSpawn = true
zones.bravo.airbaseName = 'Bravo'

zones.convoy:registerTrigger('lost', function (event, sender)
	local convoyItems = {'convoy1','convoy2','convoy3', 'convoy4'}
	
	local message = "Convoy liberated"
	local totalLost = 0
	for i,v in ipairs(convoyItems) do
		if not StaticObject.getByName(v) then
			totalLost = totalLost+1
		end
	end
	
	if totalLost>0 then
		local percentLost = math.ceil((totalLost/#convoyItems)*100)
		percentLost = math.min(percentLost,100)
		percentLost = math.max(percentLost,1)
		message = message..' but we lost '..percentLost..'% of the trucks.'
	else
		message = message..'. We recovered all of the supplies.'
	end
	
	local creditsEarned = (#convoyItems - totalLost) * 250
	message = message..'\n\n+'..creditsEarned..' credits'
	
	bc:addFunds(2, creditsEarned)
	
	trigger.action.outTextForCoalition(2, message, 15)
end, 'convoyLost', 1)

local showCredIncrease = function(event, sender)
	trigger.action.outTextForCoalition(sender.side, '+'..math.floor(sender.income*360)..' Credits/Hour', 5)
end

zones.oilfields:registerTrigger('captured', showCredIncrease, 'oilfieldcaptured')
zones.factory:registerTrigger('captured', showCredIncrease, 'factorycaptured')

zones.krymsk:registerTrigger('captured', function(event,sender)
	local kr = bc:getZoneByName('Krymsk')
	if kr.side == 1 then
		local krforces = { 'krymsk-gforce-1','krymsk-gforce-2','krymsk-gforce-3','krymsk-tforce-1' }
		for _,v in ipairs(krforces) do
			local g = Group.getByName(v)
			if g then
				g:destroy()
			end
		end
	end
end, 'krymskcaptured')

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

	bc:roamGroupsToLocalSubZone({
		"Red Armored group #",
		"Red SAM AAA #",
		"Red SAM AAA 2 #",
		"Red SAM SHORAD SA-15 #",
		"Red SAM SHORAD SA-13 #",
	}, 30)
end,{},5,0)

--bc:addFunds(1,0)
--bc:addFunds(2,0)

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
			trigger.action.outTextForCoalition(2,'Reaper drone deployed over '..target..' - JTACs active '..#jtacQueue..' / 2',15)
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
		trigger.action.outTextForCoalition(2,'Reaper drone deployed over '..params.zone.zone..' - JTACs active '..#jtacQueue..' / 2',15)
	else
		return 'Can only target enemy zone'
	end
end)


local smoketargets = function(tz)
	if not tz or not tz.built then return end
	local units = {}
	for i,v in pairs(tz.built) do
		local g = Group.getByName(v)
		if g and g:isExist() then
			local gUnits = g:getUnits()
			if gUnits then
				for i2,v2 in ipairs(gUnits) do
					table.insert(units,v2)
				end
			end
		end
	end
	local tgts = {}
	for i=1,3,1 do
		if #units > 0 then
			local selected = math.random(1,#units)
			table.insert(tgts,units[selected])
			table.remove(units,selected)
		end
	end
	for i,v in ipairs(tgts) do
		if v and v:isExist() then
			local pos = v:getPosition().p
			trigger.action.smoke(pos,1)
		end
	end
end

local flaretargets = function(tz)
	if not tz or not tz.built then return end
	local units = {}
	for i,v in pairs(tz.built) do
		local g = Group.getByName(v)
		if g and g:isExist() then
			local gUnits = g:getUnits()
			if gUnits then
				for i2,v2 in ipairs(gUnits) do
					table.insert(units,v2)
				end
			end
		end
	end
		local tgts = {}
	for i=1,3,1 do
		if #units > 0 then
			local selected = math.random(1,#units)
			table.insert(tgts,units[selected])
			table.remove(units,selected)
		end
	end
	for _,v in ipairs(tgts) do
		if v and v:isExist() then
			local pos = v:getPosition().p
			for burst=0,2 do
				local flarePoint = { x = pos.x, y = pos.y, z = pos.z }
				timer.scheduleFunction(function(args, t)
					trigger.action.signalFlare(args.point, trigger.flareColor.Red, math.random(0,359))
					return nil
				end, { point = flarePoint }, timer.getTime() + (burst * 5))
			end
		end
	end
end

local illumtargets = function(tz)
	if not tz or not tz.built then return end
	local groups, units, statics = {}, {}, {}
	for i,v in pairs(tz.built) do
		local g = Group.getByName(v)
		if g and g:isExist() then
			table.insert(groups, g)
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
			end
		end
	end
	local illumAltitude = 600
	local illumPower = 400000

	local targets = {}
	local function addPos(p)
		if p then table.insert(targets, p) end
	end
	local function addGroupLeaderPos(g)
		if not g then return end
		local u = g:getUnit(1)
		if u and u:isExist() then
			local p = u:getPosition().p
			addPos(p)
		end
	end
	local function addRandomUnitPos(pool)
		if not pool or #pool == 0 then return end
		local idx = math.random(1, #pool)
		local u = pool[idx]
		if u and u:isExist() then
			local p = u:getPosition().p
			addPos(p)
		end
		table.remove(pool, idx)
	end

	if #groups >= 3 then
		local gpool = {}
		for _,g in ipairs(groups) do table.insert(gpool, g) end
		for i=1,3 do
			local idx = math.random(1, #gpool)
			addGroupLeaderPos(gpool[idx])
			table.remove(gpool, idx)
		end
	elseif #groups == 2 then
		addGroupLeaderPos(groups[1])
		addGroupLeaderPos(groups[2])
		local upool = {}
		for _,u in ipairs(units) do table.insert(upool, u) end
		if #upool > 0 then
			addRandomUnitPos(upool)
		elseif #statics > 0 then
			local s = statics[math.random(1, #statics)]
			addPos(s:getPoint())
		end
	elseif #groups == 1 then
		local gUnits = groups[1]:getUnits() or {}
		local upool = {}
		for _,u in ipairs(gUnits) do table.insert(upool, u) end
		if #upool == 0 then
			for _,u in ipairs(units) do table.insert(upool, u) end
		end
		for i=1,3 do
			if #upool == 0 then break end
			addRandomUnitPos(upool)
		end
	else
		local spoints = {}
		for _,s in ipairs(statics) do
			local p = s:getPoint()
			if p then table.insert(spoints, p) end
		end
		for i=1,3 do
			if #spoints == 0 then break end
			local idx = math.random(1, #spoints)
			addPos(spoints[idx])
			table.remove(spoints, idx)
		end
	end

	for _,p in ipairs(targets) do
		local bombPoint = { x = p.x, y = p.y + illumAltitude, z = p.z }
		trigger.action.illuminationBomb(bombPoint, illumPower)
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
	if params.zone and params.zone.side == 1 then
		smoketargets(params.zone)
		trigger.action.outTextForCoalition(2, 'Targets marked with RED smoke at '..params.zone.zone, 15)
	else
		return 'Can only target enemy zone'
	end
end)

local flareTargetMenu = nil
bc:registerShopItem('flare', 'Flare markers ', 20, function(sender)
	if flareTargetMenu then
		return 'Choose target zone from F10 menu'
	end
	
	local launchAttack = function(target)
		if flareTargetMenu then
			local tz = bc:getZoneByName(target)
			flaretargets(tz)
			flareTargetMenu = nil
			trigger.action.outTextForCoalition(2, 'Targets marked with RED flare at '..target, 15)
		end
	end
	
	flareTargetMenu = bc:showTargetZoneMenu(2, 'Flare marker target', launchAttack, 1)
	
	trigger.action.outTextForCoalition(2, 'Choose target zone from F10 menu ', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 1 then
		flaretargets(params.zone)
		trigger.action.outTextForCoalition(2, 'Targets marked with RED flare at '..params.zone.zone, 15)
	else
		return 'Can only target enemy zone'
	end
end)

local illumTargetMenu = nil
bc:registerShopItem('illum', 'Illumination bomb', 100, function(sender)
	if illumTargetMenu then
		return 'Choose target zone from F10 menu'
	end
	
	local launchAttack = function(target)
		if illumTargetMenu then
			local tz = bc:getZoneByName(target)
			illumtargets(tz)
			illumTargetMenu = nil
			trigger.action.outTextForCoalition(2, 'Targets illuminated at '..target, 15)
		end
	end
	
	illumTargetMenu = bc:showTargetZoneMenu(2, 'Illumination target', launchAttack, 1)
	
	trigger.action.outTextForCoalition(2, 'Choose target zone from F10 menu ', 15)
end,
function(sender, params)
	if params.zone and params.zone.side == 1 then
		illumtargets(params.zone)
		trigger.action.outTextForCoalition(2, 'Targets illuminated at '..params.zone.zone, 15)
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
    if params.zone and params.zone.side == 1 then
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
            if zone and (zone.side == 0 or not zone.active) then
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
bc:registerShopItem('capture','Capture neutral zone',500,
function(sender)
	if NoAIBlueSupplies == true then 
		return 'Blue AI supplies are disabled' 
	end
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
    --return 'Choose a zone from F10 menu'
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


bc:registerShopItem('dynamiccap', 'Dynamic CAP', 250, function(sender)
    if capActive then
        return 'CAP mission still in progress'
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

bc:registerShopItem('dynamiccas', 'Dynamic CAS', 250,
function(sender)
    if casActive then
        return 'CAS mission still in progress'
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

bc:registerShopItem('dynamicdecoy', 'Dynamic Decoy', 250,
function(sender)
    if decoyActive then
        return 'Decoy mission still in progress'
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


bc:registerShopItem('dynamicsead', 'Dynamic SEAD', 250,
function(sender)
    if seadActive then
        return 'SEAD mission still in progress'
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

bc:registerShopItem('dynamicbomb', 'Dynamic Bomb run', 250,
function(sender)
    if bomberActive then
        return 'Bomb mission still in progress'
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

local intelMenu=nil
bc:registerShopItem('intel','Intel on enemy zone',150,function(sender)
	if intelMenu then
		return 'Already choosing a zone'
	end
	local pickZone = function(targetZoneName)
		if intelMenu then
			local zoneObj = bc:getZoneByName(targetZoneName)
			if not zoneObj or zoneObj.side ~= 1 then
				return 'Must pick an enemy zone'
			end
			intelActiveZones[targetZoneName] = true
			trigger.action.outTextForCoalition(2, 'Intel available for '..targetZoneName..'. Check Zone status. Valid for 1 hour', 15)
			timer.scheduleFunction(function(args)
				local zName = args[1]
				local zn = bc:getZoneByName(zName)
				if not zn or zn.side ~= 1 then return end
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
	if params.zone and params.zone.side == 1 then
		intelActiveZones[params.zone.zone] = true
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

local infMenu=nil
bc:registerShopItem('zinf','Add infantry group to zone',500,function(sender)
	if infMenu then
		return 'Already choosing a zone'
	end
	local pickZone=function(zName)
		if infMenu then
			local z=bc:getZoneByName(zName)
			if not z or z.side~=2 then
				return 'Must pick friendly zone'
			end
			if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
				return 'Zone already upgraded'
			end
			z:addExtraSlot('bInfantry')
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
		params.zone:addExtraSlot('bInfantry')
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
			if not z or z.side~=2 then
				return 'Must pick friendly zone'
			end
		if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
			return 'Zone already upgraded'
		end
            local slot = (Era == 'Coldwar') and 'blueHAWK' or 'bluePD1'
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
		params.zone:addExtraSlot((Era == 'Coldwar') and 'blueHAWK' or 'bluePD1')
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

local armMenu=nil
bc:registerShopItem('zarm','Add armor group to a zone',1000,function(sender)
	if armMenu then
		return 'Already choosing a zone'
	end
	local pickZone=function(zName)
		if armMenu then
			local z=bc:getZoneByName(zName)
			if not z or z.side~=2 then
				return 'Must pick friendly zone'
			end
			if z.upgradesUsed >= (1 + (bc.globalExtraUnlock and 1 or 0)) then
				return 'Zone already upgraded'
			end
			local slotID = (Era == 'Coldwar') and 'bArmor_CW' or 'bArmor'
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
		local slotID = (Era == 'Coldwar') and 'bArmor_CW' or 'bArmor'
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

------------------------------------------- End of Zone upgrades ----------------------------------------

bc:addShopItem(2, 'supplies', -1,13)
bc:addShopItem(2, 'supplies2', -1,12)
bc:addShopItem(2, 'jtac', -1,1)
bc:addShopItem(2, 'armor', -1,18)
bc:addShopItem(2, 'artillery', -1,19)
bc:addShopItem(2, 'recon', -1,20)
bc:addShopItem(2, 'airdef', -1,21)
bc:addShopItem(2, '9lineam', -1,22)
bc:addShopItem(2, '9linefm', -1,23)
bc:addShopItem(2, 'capture', -1,7)
bc:addShopItem(2, 'smoke', -1,8)
bc:addShopItem(2, 'flare', -1,9)
bc:addShopItem(2, 'illum', -1,10)
bc:addShopItem(2, 'intel', -1,11)
bc:addShopItem(2, 'dynamiccap', -1,2)
bc:addShopItem(2, 'dynamiccas', -1,3)
bc:addShopItem(2, 'dynamicdecoy', -1,6)
bc:addShopItem(2, 'dynamicbomb', -1,4)
bc:addShopItem(2, 'dynamicsead', -1,5)
if UseStatics == true then
bc:addShopItem(2, 'Dynamicstatic', -1,7)
end
bc:addShopItem(2,'zinf',-1,14)
bc:addShopItem(2,'zarm',-1,15)
bc:addShopItem(2,'zsam',-1,16)
bc:addShopItem(2,'gslot',1,17)


--red support
Group.getByName('redcas1'):destroy()
bc:registerShopItem('redcas1', 'Red Cas', 1000, function(sender) 
	local gr = Group.getByName('redcas1')
	if gr and gr:getSize()>0 and gr:getController():hasTask() then 
		return 'still alive'
	end
	RespawnGroup('redcas1')
	trigger.action.outTextForCoalition(2,'The enemy has deployed a couple of Su-34 against our ground forces',15)
end)

Group.getByName('redcap1'):destroy()
bc:registerShopItem('redcap1', 'Red Cap', 1000, function(sender) 
	local gr = Group.getByName('redcap1')
	if gr and gr:getSize()>0 and gr:getController():hasTask() then 
		return 'still alive'
	end
	RespawnGroup('redcap1')
	trigger.action.outTextForCoalition(2,'Enemy MiG-31 interceptors, coming in from the South-East',15)
end)

Group.getByName('redsead1'):destroy()
bc:registerShopItem('redsead1', 'Red Sead', 1000, function(sender) 
	local gr = Group.getByName('redsead1')
	if gr and gr:getSize()>0 and gr:getController():hasTask() then 
		return 'still alive'
	end
	RespawnGroup('redsead1')
	trigger.action.outTextForCoalition(2,'The enemy has launched an attack from the North-East on our air defenses',15)
end)

Group.getByName('redmlrs1'):destroy()
bc:registerShopItem('redmlrs1', 'spawn Red mlrs', 1000, function(sender) 
	local zn = bc:getZoneByName('Foxtrot')
	if zn.side == 1 and zn.active then
		local gr = Group.getByName('redmlrs1')
		if gr then
			local full = true
			for i,v in ipairs(gr:getUnits()) do
				local uAmmo = v:getAmmo()
				if uAmmo then
					for i2,v2 in ipairs(uAmmo) do
						if v2.count < 3 then
							full = false
							break
						end
					end
				else
					full = false
				end
				if not full then 
					break
				end
			end
			
			if full and gr:getSize()==gr:getInitialSize() then
				return 'ammo full'
			end
			
			trigger.action.outTextForCoalition(2,'The enemy has resupplied its artillery near Foxtrot',15)
		end
		
		RespawnGroup('redmlrs1')
		bc:removeShopItem(1,'redmlrs1fire')
		bc:addShopItem(1, 'redmlrs1fire', 3)
	else
		return 'zone not red'
	end
end)

bc:registerShopItem('redmlrs1fire', 'fire red mlrs', 200, function(sender) 
	local gr = Group.getByName('redmlrs1')
	if gr then
		local targetzones = {'Echo', 'Delta', 'SAM Site', 'Factory', 'Radio Tower', 'Krymsk'}
		local viabletargets = {}
		for i,v in ipairs(targetzones) do
			local z = bc:getZoneByName(v)
			
			if z and z.side == 2 then
				table.insert(viabletargets, v)
			end
		end

		if #viabletargets==0 then
			return 'no targets'
		end
		
		local targetzn = viabletargets[math.random(1,#viabletargets)]
		
		local err = bc:fireAtZone(targetzn, 'redmlrs1', true, 3, 6)
		
		if not err then
			trigger.action.outTextForCoalition(2,'Enemy artillery near Foxtrot has begun preparations to fire on '..targetzn,15)
		else
			return err
		end
	else
		return 'buy first'
	end
end)


Group.getByName('intercept1'):destroy()
Group.getByName('intercept2'):destroy()
local cargoDieEvent = nil
bc:registerShopItem('intercept1', 'Red intercept', 1000, function(sender) 
	local grt = Group.getByName('intercept1')
	local gre = Group.getByName('intercept2')
	if gre and gre:getSize()>0 and gre:getController():hasTask() then 
		return 'still alive'
	end
	
	if grt and grt:getSize()>0 and grt:getController():hasTask() then 
		return 'still alive'
	end
	
	RespawnGroup('intercept1')
	RespawnGroup('intercept2')
	
	if not cargoDieEvent then
		cargoDieEvent = EVENT:New()
			function cargoDieEvent:OnEventDead(EventData)
				if EventData.IniGroup and EventData.IniGroup:GetName() then
					local name = EventData.IniGroup:GetName()
					if type(name) == 'string' and name:find('^intercept1') then
						self:UnHandleEvent(EVENTS.Dead)
						cargoDieEvent = nil
						trigger.action.outTextForCoalition(2, 'Enemy cargo transport destroyed.\n+500 credits', 15)
						bc:addFunds(2, 500)
					end
				end
			end
		
		cargoDieEvent:HandleEvent(EVENTS.Dead)
	end
end)

Group.getByName('escort1'):destroy()
Group.getByName('antiescort1'):destroy()
Group.getByName('antiescort2'):destroy()
bc:registerShopItem('escort1', 'Red antiescort', 1000, function(sender) 
	local gr = Group.getByName('escort1')
	if gr and gr:getSize()>0 and gr:getController():hasTask() then 
		return 'still alive'
	end
	
	RespawnGroup('escort1')
	
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
	
	local timers = {math.random(3*60,15*60), math.random(8*60,15*60)}
		timer.scheduleFunction(spawnIntercept, {'antiescort1'}, timer.getTime() + timers[1])
		timer.scheduleFunction(spawnIntercept, {'antiescort2'}, timer.getTime() + timers[2])
end)

krymskForce = {
	'krymsk-force-1',
	'krymsk-force-2',
	'krymsk-force-3',
	'krymsk-gforce-1',
	'krymsk-gforce-2',
	'krymsk-gforce-3',
	'krymsk-tforce-1',
	'krymsk-aforce-1',
	'krymsk-aforce-2',
	'krymsk-aforce-3',
}

for _,v in ipairs(krymskForce) do Group.getByName(v):destroy() end

bc:registerShopItem('krymskForce', 'Krymsk Assault', 1000, function(sender) 
	for _,v in ipairs(krymskForce) do
		local gr = Group.getByName(v)
		if gr and gr:getSize()>0 and gr:getController():hasTask() then 
			return 'still alive'
		end
	end
	
	if bc:getZoneByName('Echo').side==1 and bc:getZoneByName('Krymsk').side==2 then
		for _,v in ipairs(krymskForce) do
			RespawnGroup('krymsk-force-1')
			RespawnGroup('krymsk-force-2')
			RespawnGroup('krymsk-force-3')

			if bc:getZoneByName('Delta').side==1 then
				RespawnGroup('krymsk-tforce-1')
			end

			RespawnGroup('krymsk-aforce-1')
			RespawnGroup('krymsk-aforce-2')
			RespawnGroup('krymsk-aforce-3')
		end
	else
		return 'zone no match'
	end
end)


Group.getByName('foxtrot-krymsk-attack'):destroy()

bc:registerShopItem('foxtrotAttack', 'Foxtrot Assault', 1000, function(sender)

	local gr = Group.getByName('foxtrot-krymsk-attack')
	if gr and gr:getSize() > 0 and gr:getController():hasTask() then
		return 'still alive'
	end

	if bc:getZoneByName('Foxtrot').side == 1 and bc:getZoneByName('Krymsk').side == 2 then
		RespawnGroup('foxtrot-krymsk-attack')
	else
		return 'zone no match'
	end
end)

bc:addShopItem(1, 'redcas1', -1)
bc:addShopItem(1, 'redcap1', -1)
bc:addShopItem(1, 'redsead1', -1)
bc:addShopItem(1, 'redmlrs1', -1)
bc:addShopItem(1, 'intercept1', -1)
bc:addShopItem(1, 'escort1', -1)
bc:addShopItem(1, 'krymskForce', -1)
bc:addShopItem(1, 'foxtrotAttack', -1)

budgetAI = BudgetCommander:new({ battleCommander = bc, side=1, decissionFrequency=20*60, decissionVariance=10*60, skipChance = 10})
budgetAI:init()
--end red support

supplyZones = {
    "Anapa",
    "Carrier Group",
    "Alpha",
    "Bravo",
    "Charlie",
    "Convoy",
    "Krymsk",
    "Oil Fields",
    "Radio Tower",
    "Delta",
    "Factory",
    "SAM Site",
    "Foxtrot",
    "Echo",
    "Krasnodar"
}


lc = LogisticCommander:new({battleCommander = bc, supplyZones = supplyZones})
lc:init()
bc:loadFromDisk() --will load and overwrite default zone levels, sides, funds and available shop items
bc:init()
bc:startRewardPlayerContribution(15,{infantry = 10, ground = 10, sam = 30, airplane = 30, ship = 250, helicopter=30, crate=100, rescue = 300, ['Zone upgrade'] = 100, ['Zone capture'] = 200, ['CAP mission'] = true, ['CAS mission'] = true})
bc:buildZoneDistanceCache()
buildSubZoneRoadCache()
bc:buildConnectionMap()
local HuntNumber = SplashDamage and math.random(8,15) or math.random(4,10)
bc:initHunter(HuntNumber)

mc = MissionCommander:new({side = 2, battleCommander = bc, checkFrequency = 60})

mc:trackMission({
	title = "Escort",
	description = "Friendly cargo transport has entered the airspace from the south. Protect it from the enemy.",
	messageStart = "New mission: Escort",
	messageEnd = "Mission ended: Escort",
	startAction = function() trigger.action.outSoundForCoalition(2,"ding.ogg") end,
	endAction = function() 
		trigger.action.outSoundForCoalition(2,"cancel.ogg")
	end,
	isActive = function()
		if Group.getByName('escort1') then return true end
		
		return false
	end
})

mc:trackMission({
	title = "Intercept",
	description = "Enemy cargo transport has entered the airspace from the south. Intercept and destroy it before it escapes.",
	messageStart = "New mission: Intercept",
	messageEnd = "Mission ended: Intercept",
	startAction = function() trigger.action.outSoundForCoalition(2,"ding.ogg") end,
	endAction = function() 
		trigger.action.outSoundForCoalition(2,"cancel.ogg")
	end,
	isActive = function()
		if Group.getByName('intercept1') then return true end
		
		return false
	end
})

mc:trackMission({
	title = "Destroy artillery",
	description = "The enemy has deployed artillery near Foxtrot. Destroy it before it has a chance to fire",
	messageStart = "New mission: Destroy artillery",
	messageEnd = "Mission ended: Destroy artillery",
	startAction = function() trigger.action.outSoundForCoalition(2,"ding.ogg") end,
	endAction = function() 
		trigger.action.outSoundForCoalition(2,"cancel.ogg")
	end,
	isActive = function()
		if Group.getByName('redmlrs1') then return true end
		
		return false
	end
})

mc:trackMission({
	title = "Defend Krymsk",
	description = "The enemy has launched an all out attack on Krymsk.\nDefend the airfield at all cost.",
	messageStart = "New mission: Defend Krymsk",
	messageEnd = "Mission ended: Defend Krymsk",
	startAction = function() trigger.action.outSoundForCoalition(2,"ding.ogg") end,
	endAction = function() 
		trigger.action.outSoundForCoalition(2,"cancel.ogg")
	end,
	isActive = function()
		for _,v in ipairs(krymskForce) do
			local gr = Group.getByName(v)
			if gr and gr:getSize()>0 and gr:getController():hasTask() then 
				return true
			end
		end
		
		return false
	end
})


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
    local wp=WaypointList[runwayTarget] or ""
      if #runwayNames>1 then
        return 'New mission: Bomb all runways at '..runwayTargetZone..wp
      else
        return 'New mission: Bomb runway at '..runwayTargetZone..wp
      end
    end,
    messageEnd = function()
    trigger.action.outSoundForCoalition(2,'cancel.ogg')
        if runwayTargetZone then
            return 'Mission ended: Bomb runway at '..runwayTargetZone..(bomberName and (' by '..bomberName) or '')
        else
            return 'Mission ended: Bomb runway'
        end
    end,
	startAction = function()
	ActiveCurrentMission[runwayTargetZone] = ActiveCurrentMission[runwayTargetZone] or {}
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
	RUNWAY_ZONE_COOLDOWN[runwayTargetZone]=timer.getTime()+1800
	runwayCooldown = timer.getTime()+900
	local t = ActiveCurrentMission[runwayTargetZone]
	if t then
		t["Bomb runway"] = nil
		if not next(t) then ActiveCurrentMission[runwayTargetZone] = nil end
	end
	local z = bc:getZoneByName(runwayTargetZone) if z then z:updateLabel() end
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
    if seadTarget then return true end
    if not attackTarget then return false end

    local function isSEADZone(zone)
        local lname = zone.zone:lower()
        return zone.side == 1 and zone.active and lname:find('sam')
    end

	local validSEADZones = {}
	local attackZone = bc:getZoneByName(attackTarget)

	if attackZone and attackZone.zone then
		local znA = attackZone.zone
		for _, zone in ipairs(bc.zones) do
			local znB = zone.zone
			local dist = ZONE_DISTANCES[znA] and ZONE_DISTANCES[znA][znB]
			if isSEADZone(zone) and dist and dist <= 24000 then
				table.insert(validSEADZones, zone.zone)
			end
		end
	end

    if #validSEADZones == 0 then
        for _, connection in ipairs(bc.connections) do
            local from = bc:getZoneByName(connection.from)
            local to = bc:getZoneByName(connection.to)

            if from.side ~= to.side and from.side ~= 0 and to.side ~= 0 then
                if isSEADZone(from) then
                    table.insert(validSEADZones, from.zone)
                end
                if isSEADZone(to) then
                    table.insert(validSEADZones, to.zone)
                end
            end
        end
    end

    if #validSEADZones == 0 then return false end

    seadTarget = validSEADZones[math.random(#validSEADZones)]
    return true
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
        return zn and zn.side == 1
    end
})

function generateCaptureMission()
    if captureTarget ~= nil then return true end
    
    local validzones = {}
    for _, v in ipairs(bc.zones) do
        if v.active and v.side == 0 and (not v.NeutralAtStart or v.firstCaptureByRed) and 
           not string.find(v.zone, "Hidden") then
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
    if attackTarget ~= nil then return true end

    local validzones = {}
    for _, v in ipairs(bc.connections) do
        local to = bc:getZoneByName(v.to)
        local from = bc:getZoneByName(v.from)

        local function checkValid(zone)
			local lname = zone.zone:lower()
            return zone.side == 1 and zone.active and not isZoneUnderSEADMission(zone.zone)
			and not lname:find('sam') and not lname:find('defence')
        end

        if from.side ~= to.side and from.side ~= 0 and to.side ~= 0 then
            if checkValid(from) then table.insert(validzones, from.zone) end
            if checkValid(to)   then table.insert(validzones, to.zone)   end
        end
    end

    if #validzones == 0 then return false end

    local choice = math.random(1, #validzones)
    attackTarget = validzones[choice]
    return true
end

function generateSupplyMission()
	if resupplyTarget ~= nil then return true end
		
	local validzones = {}
	for _,v in ipairs(bc.zones) do
		if v.side == 2 and v:canRecieveSupply() then
			table.insert(validzones, v.zone)
		end
	end
	
	if #validzones == 0 then return false end
	
	local choice = math.random(1, #validzones)
	if validzones[choice] then
		resupplyTarget = validzones[choice]
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
    messageEnd = '',
    startAction = function()
        if not missionCompleted then
            trigger.action.outSoundForCoalition(2, "ding.ogg")
        end
    end,
	endAction = function()
        if capWinner then
            local reward = capTargetPlanes * 100
            local pname  = capWinner
            bc.playerContributions[2][pname] = (bc.playerContributions[2][pname] or 0) + reward
            bc:addTempStat(pname,'CAP mission',1)
            trigger.action.outTextForCoalition(2,"["..pname.."] completed the CAP mission!\nReward pending: "..reward.." credits (land to redeem).",20)
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
            local reward = casTargetKills*50
            local pname  = casWinner
            bc.playerContributions[2][pname] = (bc.playerContributions[2][pname] or 0) + reward
            bc:addTempStat(pname,'CAS mission',1)

            trigger.action.outTextForCoalition(2,'['..pname..'] completed the CAS mission!\nReward pending: '..reward..' credits (land to redeem).',20)
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

buildingCache = buildingCache or {}
for _, z in ipairs(bc:getZones()) do
	local c = CustomZone:getByName(z.zone)
	if c then c:getZoneBuildings() end
end


function checkZoneFlags()

    if trigger.misc.getUserFlag("1") == 0 and zones.delta.wasBlue and zones.krymsk.wasBlue then
        trigger.action.setUserFlag("1", true)
		trigger.action.setUserFlag("2", false)
    end
	if trigger.misc.getUserFlag("1") == 1 and zones.krymsk.side == 0 then
        trigger.action.setUserFlag("2", true)
		trigger.action.setUserFlag("1", false)
    end
end 

timer.scheduleFunction(function()
    checkZoneFlags()
    return timer.getTime() + 30
end, {}, timer.getTime() + 3)
mc:init()

--[[ bc.playerContributions[2]['[MA] Leka'] = (bc.playerContributions[2]['[MA] Leka'] or 0) + 1000
bc:addTempStat('[MA] Leka','CAP mission',1) ]]
