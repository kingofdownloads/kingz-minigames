-- Kingz Minigames
-- Copyright (C) 2024 Kingz

local QBCore = exports['qb-core']:GetCoreObject()

-- Memory game minigame
local function StartMemoryGame(gridSize, timeLimit, numItems)
    local p = promise.new()
    
    -- Apply skill modifiers if enabled
    if Config.UseSkills then
        local hackingModifier = exports['kingz-minigames']:GetHackingModifier('MemoryGame')
        
        -- Apply modifier to make game easier based on skill level
        if numItems then
            numItems = math.max(1, math.floor(numItems / hackingModifier))
        end
        
        if timeLimit then
            timeLimit = timeLimit * hackingModifier
        end
    end
    
    gridSize = gridSize or 5
    timeLimit = timeLimit or 10
    numItems = numItems or 6
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "startMemoryGame",
        gridSize = gridSize,
        time = timeLimit,
        items = numItems
    })
    
    RegisterNUICallback('memoryGameResult', function(data, cb)
        SetNuiFocus(false, false)
        
        -- Award XP based on result
        TriggerServerEvent('kingz-minigames:server:memoryGameComplete', data.success)
        
        p:resolve(data.success)
        cb('ok')
    end)
    
    return Citizen.Await(p)
end

exports('MemoryGame', function(gridSize, timeLimit, numItems)
    return StartMemoryGame(gridSize, timeLimit, numItems)
end)

if Config.DebugCommands then
    RegisterCommand('testmemorygame', function()
        local success = exports['kingz-minigames']:MemoryGame(5, 10, 6)
        print("MemoryGame result: " .. tostring(success))
    end, false)
end
