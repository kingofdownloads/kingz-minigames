-- Kingz Minigames
-- Copyright (C) 2024 Kingz

local QBCore = exports['qb-core']:GetCoreObject()

-- Cache for skill levels and modifiers
local skillCache = {
    hacking = 0,
    lockpicking = 0,
    electronics = 0,
    drilling = 0
}

-- Cache for player perks
local playerPerks = {}

-- Function to refresh skill cache
local function RefreshSkillCache()
    if not Config.UseSkills then 
        return 
    end
    
    -- Get skill levels from kingz-skills
    local hasSkillSystem = pcall(function()
        skillCache.hacking = exports['kingz-skills']:GetSkillLevel(PlayerId(), 'hacking') or 0
        skillCache.lockpicking = exports['kingz-skills']:GetSkillLevel(PlayerId(), 'lockpicking') or 0
        skillCache.electronics = exports['kingz-skills']:GetSkillLevel(PlayerId(), 'electronics') or 0
        skillCache.drilling = exports['kingz-skills']:GetSkillLevel(PlayerId(), 'drilling') or 0
    end)
    
    if not hasSkillSystem then
        print("Warning: kingz-skills not found or GetSkillLevel function not available")
        return
    end
    
    -- Get player perks
    local hasPerkSystem = pcall(function()
        local perksFunction = exports['kingz-skills'].Perks_Has
        if perksFunction then
            playerPerks.master_hacker = exports['kingz-skills']:Perks_Has(PlayerId(), 'master_hacker') or false
            playerPerks.firewall_specialist = exports['kingz-skills']:Perks_Has(PlayerId(), 'firewall_specialist') or false
            playerPerks.locksmith = exports['kingz-skills']:Perks_Has(PlayerId(), 'locksmith') or false
            playerPerks.circuit_wizard = exports['kingz-skills']:Perks_Has(PlayerId(), 'circuit_wizard') or false
            playerPerks.master_driller = exports['kingz-skills']:Perks_Has(PlayerId(), 'master_driller') or false
        end
    end)
    
    if not hasPerkSystem then
        print("Warning: kingz-skills perks system not found or Perks_Has function not available")
    end
end

-- Calculate modifier based on skill level and perks
local function CalculateModifier(skill, gameType)
    if not Config.UseSkills then return 1.0 end
    
    -- Refresh cache to ensure we have latest data
    RefreshSkillCache()
    
    local skillLevel = skillCache[skill] or 0
    local baseModifier = 1.0
    local configModifier = Config.SkillModifiers.Hacking
    
    -- Select the right modifier config based on skill
    if skill == 'lockpicking' then
        configModifier = Config.SkillModifiers.Lockpicking
    elseif skill == 'electronics' then
        configModifier = Config.SkillModifiers.Electronics
    elseif skill == 'drilling' then
        configModifier = Config.SkillModifiers.Drilling
    end
    
    -- Calculate base modifier from skill level
    local skillModifier = math.min(skillLevel * configModifier.baseModifier, configModifier.maxModifier)
    baseModifier = baseModifier + skillModifier
    
    -- Apply perk effects
    for perk, hasIt in pairs(playerPerks) do
        if hasIt and Config.PerkEffects[perk] then
            local perkEffect = Config.PerkEffects[perk]
            
            -- Check if perk is for a specific game
            if not perkEffect.specificGame or perkEffect.specificGame == gameType then
                if perkEffect.difficultyReduction then
                    baseModifier = baseModifier + perkEffect.difficultyReduction
                end
            end
        end
    end
    
    return baseModifier
end

-- Calculate time bonus based on skill level and perks
local function CalculateTimeBonus(skill, gameType)
    if not Config.UseSkills then return 1.0 end
    
    -- Refresh cache to ensure we have latest data
    RefreshSkillCache()
    
    local timeBonus = 1.0
    
    -- Apply perk effects for time bonuses
    for perk, hasIt in pairs(playerPerks) do
        if hasIt and Config.PerkEffects[perk] then
            local perkEffect = Config.PerkEffects[perk]
            
            -- Check if perk is for a specific game
            if not perkEffect.specificGame or perkEffect.specificGame == gameType then
                if perkEffect.timeBonus then
                    timeBonus = timeBonus + perkEffect.timeBonus
                end
            end
        end
    end
    
    return timeBonus
end

-- Export functions for other resources to use
function GetHackingModifier(gameType)
    return CalculateModifier('hacking', gameType)
end

function GetLockpickModifier()
    return CalculateModifier('lockpicking', 'Lockpick')
end

function GetDrillingModifier(gameType)
    return CalculateModifier('drilling', gameType)
end

function GetElectronicsModifier(gameType)
    return CalculateModifier('electronics', gameType)
end

-- Register event to award XP after minigame completion
RegisterNetEvent('kingz-minigames:awardXP')
AddEventHandler('kingz-minigames:awardXP', function(gameType, success)
    -- This is just a client-side event handler that will show a notification
    -- The actual XP awarding happens server-side
    
    if not Config.UseSkills then return end
    
    local xpConfig = Config.XPRewards[gameType]
    if not xpConfig then return end
    
    local xpAmount = success and xpConfig.success or xpConfig.failure
    local skillName = xpConfig.skill:gsub("^%l", string.upper) -- Capitalize first letter
    
    if success then
        ShowNotification('Skill XP', 'You gained ' .. xpAmount .. ' ' .. skillName .. ' XP!', 3000, 'success')
    end
end)

-- Initialize skills cache when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(2000) -- Wait for other resources to load
        RefreshSkillCache()
    end
end)

-- Refresh skills cache when player loads
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000) -- Wait for other resources to load
    RefreshSkillCache()
end)

-- Refresh skills cache periodically
CreateThread(function()
    while true do
        Wait(60000) -- Refresh every minute
        RefreshSkillCache()
    end
end)

-- Export the functions
exports('GetHackingModifier', GetHackingModifier)
exports('GetLockpickModifier', GetLockpickModifier)
exports('GetDrillingModifier', GetDrillingModifier)
exports('GetElectronicsModifier', GetElectronicsModifier)
