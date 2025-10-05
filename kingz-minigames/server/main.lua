-- Kingz Minigames
-- Copyright (C) 2024 Kingz

local QBCore = exports['qb-core']:GetCoreObject()

-- Function to award XP for minigame completion
local function AwardMinigameXP(source, gameType, success)
    if not Config.UseSkills then return end
    
    local xpConfig = Config.XPRewards[gameType]
    if not xpConfig then return end
    
    local xpAmount = success and xpConfig.success or xpConfig.failure
    local reason = success and (gameType .. " completed") or (gameType .. " attempted")
    
    -- Award XP using kingz-skills export
    exports['kingz-skills']:AddSkillXP(source, xpConfig.skill, xpAmount, reason)
    
    -- Notify client
    TriggerClientEvent('kingz-minigames:awardXP', source, gameType, success)
end

-- Register server events for each minigame type
RegisterNetEvent('kingz-minigames:server:firewallComplete')
AddEventHandler('kingz-minigames:server:firewallComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'Firewall', success)
end)

RegisterNetEvent('kingz-minigames:server:backdoorComplete')
AddEventHandler('kingz-minigames:server:backdoorComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'Backdoor', success)
end)

RegisterNetEvent('kingz-minigames:server:varHackComplete')
AddEventHandler('kingz-minigames:server:varHackComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'VarHack', success)
end)

RegisterNetEvent('kingz-minigames:server:bruteForceComplete')
AddEventHandler('kingz-minigames:server:bruteForceComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'BruteForce', success)
end)

RegisterNetEvent('kingz-minigames:server:dataCrackComplete')
AddEventHandler('kingz-minigames:server:dataCrackComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'DataCrack', success)
end)

RegisterNetEvent('kingz-minigames:server:lockpickComplete')
AddEventHandler('kingz-minigames:server:lockpickComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'Lockpick', success)
end)

RegisterNetEvent('kingz-minigames:server:circuitBreakerComplete')
AddEventHandler('kingz-minigames:server:circuitBreakerComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'CircuitBreaker', success)
end)

RegisterNetEvent('kingz-minigames:server:circuitRhythmComplete')
AddEventHandler('kingz-minigames:server:circuitRhythmComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'CircuitRhythm', success)
end)

RegisterNetEvent('kingz-minigames:server:drillingComplete')
AddEventHandler('kingz-minigames:server:drillingComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'Drilling', success)
end)

RegisterNetEvent('kingz-minigames:server:plasmaDrillingComplete')
AddEventHandler('kingz-minigames:server:plasmaDrillingComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'PlasmaDrilling', success)
end)

-- Additional minigame events
RegisterNetEvent('kingz-minigames:server:wireCutComplete')
AddEventHandler('kingz-minigames:server:wireCutComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'WireCut', success)
end)

RegisterNetEvent('kingz-minigames:server:safeHackComplete')
AddEventHandler('kingz-minigames:server:safeHackComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'SafeHack', success)
end)

RegisterNetEvent('kingz-minigames:server:memoryGameComplete')
AddEventHandler('kingz-minigames:server:memoryGameComplete', function(success)
    local src = source
    AwardMinigameXP(src, 'MemoryGame', success)
end)

RegisterNetEvent('kingz-minigames:server:skillBarComplete')
AddEventHandler('kingz-minigames:server:skillBarComplete', function(success, skillType)
    local src = source
    
    -- Map skill type to XP reward type
    local gameType = 'SkillBar'
    if skillType == 'hacking' then
        gameType = 'SkillBarHacking'
    elseif skillType == 'lockpicking' then
        gameType = 'SkillBarLockpicking'
    elseif skillType == 'drilling' then
        gameType = 'SkillBarDrilling'
    end
    
    AwardMinigameXP(src, gameType, success)
end)

-- Command to test XP rewards (admin only)
QBCore.Commands.Add('testminigamexp', 'Test minigame XP rewards (Admin Only)', {
    {name = 'gameType', help = 'Minigame type (Firewall, Lockpick, etc.)'},
    {name = 'success', help = 'true/false'}
}, true, function(source, args)
    local src = source
    local gameType = args[1]
    local success = args[2] == 'true'
    
    if not Config.XPRewards[gameType] then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid game type', 'error')
        return
    end
    
    AwardMinigameXP(src, gameType, success)
    TriggerClientEvent('QBCore:Notify', src, 'XP awarded for ' .. gameType, 'success')
end, 'admin')
