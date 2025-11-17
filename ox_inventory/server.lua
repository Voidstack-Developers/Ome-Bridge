-- Ome Framework Bridge for ox_inventory (Server)
local OmeAPI = nil

-- Wait for Ome Framework to be ready
CreateThread(function()
    while GetResourceState('Ome-Framework') ~= 'started' do
        Wait(100)
    end

    -- Get Ome server API
    OmeAPI = exports['Ome-Framework']:getOmeAPI()
end)

local Inventory = require 'modules.inventory.server'

-- Handle player disconnect
AddEventHandler('playerDropped', server.playerDropped)

-- Handle job changes
AddEventHandler('ome:server:jobUpdate', function(source, newJob, oldJob)
    local inventory = Inventory(source)

    if not inventory then return end

    inventory.player.groups = inventory.player.groups or {}
    inventory.player.groups[newJob.name] = newJob.grade
end)

-- Handle group changes
AddEventHandler('ome:server:groupUpdate', function(source, newGroup, oldGroup)
    local inventory = Inventory(source)

    if not inventory then return end

    inventory.player.groups = inventory.player.groups or {}
    inventory.player.groups[newGroup] = 1
end)

---@diagnostic disable-next-line: duplicate-set-field
function server.setPlayerData(player)
    local omePlayer = OmeAPI and OmeAPI.GetPlayer(player.source)

    if not omePlayer then return player end

    -- Setup groups structure for ox_inventory
    -- ox_inventory uses groups for both jobs and permission groups
    player.groups = {}

    -- Add job as a group
    if omePlayer.job then
        player.groups[omePlayer.job.name] = omePlayer.job.grade
    end

    -- Add permission group
    if omePlayer.group then
        player.groups[omePlayer.group] = 1
    end

    return player
end

---@diagnostic disable-next-line: duplicate-set-field
function server.hasLicense(inv, name)
    local player = OmeAPI and OmeAPI.GetPlayer(inv.id)

    if not player then return false end

    -- Check if player has license in metadata
    local licenses = player.metadata and player.metadata.licenses or {}
    return licenses[name] == true
end

---@diagnostic disable-next-line: duplicate-set-field
function server.buyLicense(inv, license)
    local player = OmeAPI and OmeAPI.GetPlayer(inv.id)

    if not player then return false, 'player_not_found' end

    -- Initialize licenses in metadata if not exists
    player.metadata.licenses = player.metadata.licenses or {}

    if player.metadata.licenses[license.name] then
        return false, 'already_have'
    elseif Inventory.GetItemCount(inv, 'money') < license.price then
        return false, 'can_not_afford'
    end

    Inventory.RemoveItem(inv, 'money', license.price)
    player.metadata.licenses[license.name] = true

    -- Trigger event for logging/tracking
    TriggerEvent('ome:server:licenseAcquired', inv.id, license.name)

    return true, 'have_purchased'
end

---@diagnostic disable-next-line: duplicate-set-field
function server.isPlayerBoss(playerId, group, grade)
    local player = OmeAPI and OmeAPI.GetPlayer(playerId)

    if not player then return false end

    -- Check if player has the specified job and sufficient grade
    if player.job.name ~= group then return false end

    -- Get job data to check boss grade
    local jobData = OmeAPI and OmeAPI.GetJob(group)

    if not jobData then return false end

    -- Check if player's grade is boss grade (typically highest grade)
    local bossGrade = jobData.bossGrade or 4 -- Default boss grade

    return player.job.grade >= bossGrade
end

---@param entityId number
---@return number | string
---@diagnostic disable-next-line: duplicate-set-field
function server.getOwnedVehicleId(entityId)
    -- This requires integration with your vehicle system
    -- You may need to implement this based on your vehicle ownership system
    -- For now, return the network ID
    local netId = NetworkGetNetworkIdFromEntity(entityId)

    -- Trigger event to get vehicle ownership data if you have a garage system
    -- Example: return exports['your-garage']:getVehicleId(netId)

    return netId
end
