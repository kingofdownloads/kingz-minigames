-- Kingz Minigames
-- Copyright (C) 2024 Kingz

local QBCore = exports['qb-core']:GetCoreObject()

-- Wire cutting minigame
local function StartWireCut(numWires, timeLimit, correctWire)
    local p = promise.new()
    
    -- Apply skill modifiers if enabled
    if Config.UseSkills then
        local electronicsModifier = exports['kingz-minigames']:GetElectronicsModifier('WireCut')
        
        -- Apply modifier to make game easier based on skill level
        if timeLimit then
            timeLimit = timeLimit * electronicsModifier
        end
    end
    
    numWires = numWires or 6
    timeLimit = timeLimit or 10
    correctWire = correctWire or math.random(1, numWires)
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "startWireCut",
        wires = numWires,
        time = timeLimit,
        correct = correctWire
    })
    
    RegisterNUICallback('wireCutResult', function(data, cb)
        SetNuiFocus(false, false)
        
        -- Award XP based on result
        TriggerServerEvent('kingz-minigames:server:wireCutComplete', data.success)
        
        p:resolve(data.success)
        cb('ok')
    end)
    
    return Citizen.Await(p)
end

exports('WireCut', function(numWires, timeLimit, correctWire)
    return StartWireCut(numWires, timeLimit, correctWire)
end)

if Config.DebugCommands then
    RegisterCommand('testwirecut', function()
        local success = exports['kingz-minigames']:WireCut(6, 10)
        print("WireCut result: " .. tostring(success))
    end, false)
end
