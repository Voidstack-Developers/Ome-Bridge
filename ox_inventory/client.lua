-- Ome Framework Bridge for ox_inventory
local OmeClient = nil

-- Wait for Ome Framework to be ready
CreateThread(function()
    while GetResourceState('Ome-Framework') ~= 'started' do
        Wait(100)
    end

    -- Get Ome client API
    OmeClient = exports['Ome-Framework']:getOmeAPI()
end)

-- Handle player logout
RegisterNetEvent('ome:client:playerUnloaded', client.onLogout)

-- Handle job changes (ox_inventory uses groups for job-based stashes)
RegisterNetEvent('ome:client:jobUpdate', function(newJob, oldJob)
    if not PlayerData then return end
    PlayerData.groups = PlayerData.groups or {}
    PlayerData.groups[newJob.name] = newJob.grade
    OnPlayerData('groups')
end)

-- Handle permission group changes
RegisterNetEvent('ome:client:groupUpdate', function(newGroup, oldGroup)
    if not PlayerData then return end
    PlayerData.groups = PlayerData.groups or {}
    PlayerData.groups[newGroup] = 1
    OnPlayerData('groups')
end)

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerStatus(values)
    for name, value in pairs(values) do
        -- Thanks to having status values setup out of 1000000 (matching esx_status's standard)
        -- we need to awkwardly change the value
        if value > 100 or value < -100 then
            -- Hunger and thirst start at 0 and go up to 100 as you get hungry/thirsty (inverse of ESX)
            if (name == 'hunger' or name == 'thirst') then
                value = -value
            end

            value = value * 0.0001
        end

        -- Trigger status update event to Ome Framework
        TriggerEvent('ome:client:updateStatus', name, value)
    end
end
