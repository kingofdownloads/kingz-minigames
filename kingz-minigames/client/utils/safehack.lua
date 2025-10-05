-- Kingz Minigames
-- Copyright (C) 2024 Kingz

local QBCore = exports['qb-core']:GetCoreObject()

-- Safe hacking minigame
local function StartSafeHack(levels, timeLimit)
    local p = promise.new()
    
    -- Apply skill modifiers if enabled
    if Config.UseSkills then
        local hackingModifier = exports['kingz-minigames']:GetHackingModifier('SafeHack')
        
        -- Apply modifier to make game easier based on skill level
        if levels then
            levels = math.max(1, math.floor(levels / hackingModifier))
        end
        
        if timeLimit then
            timeLimit = timeLimit * hackingModifier
        end
    end
    
    levels = levels or 3
    timeLimit = timeLimit or 30
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "startSafeHack",
        levels = levels,
        time = timeLimit
    })
    
    RegisterNUICallback('safeHackResult', function(data, cb)
        SetNuiFocus(false, false)
        
        -- Award XP based on result
        TriggerServerEvent('kingz-minigames:server:safeHackComplete', data.success)
        
        p:resolve(data.success)
        cb('ok')
    end)
    
    return Citizen.Await(p)
end

exports('SafeHack', function(levels, timeLimit)
    return StartSafeHack(levels, timeLimit)
end)

if Config.DebugCommands then
    RegisterCommand('testsafehack', function()
        local success = exports['kingz-minigames']:SafeHack(3, 30)
        print("SafeHack result: " .. tostring(success))
    end, false)
end
