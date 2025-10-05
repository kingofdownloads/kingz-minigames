-- Kingz Minigames
-- Copyright (C) 2024 Kingz

Config = {}

-- Debug settings
Config.DebugCommands = false -- Set to true to enable debug commands

-- Notification settings
Config.NotificationSystem = 'qb' -- Options: 'qb', 'esx', 'custom'

-- Skills Integration
Config.UseSkills = true -- Set to false to disable skills integration

-- XP Rewards for different minigames
Config.XPRewards = {
    -- Hacking skill
    Firewall = {
        skill = 'hacking',
        base = 25,
        success = 50,
        failure = 5
    },
    Backdoor = {
        skill = 'hacking',
        base = 30,
        success = 60,
        failure = 8
    },
    VarHack = {
        skill = 'hacking',
        base = 40,
        success = 80,
        failure = 10
    },
    BruteForce = {
        skill = 'hacking',
        base = 35,
        success = 70,
        failure = 7
    },
    DataCrack = {
        skill = 'hacking',
        base = 30,
        success = 60,
        failure = 6
    },
    
    -- Lockpicking skill
    Lockpick = {
        skill = 'lockpicking',
        base = 20,
        success = 40,
        failure = 5
    },
    
    -- Electronics skill
    CircuitBreaker = {
        skill = 'electronics',
        base = 30,
        success = 60,
        failure = 8
    },
    CircuitRhythm = {
        skill = 'electronics',
        base = 25,
        success = 50,
        failure = 5
    },
    
    -- Drilling skill
    Drilling = {
        skill = 'drilling',
        base = 35,
        success = 70,
        failure = 10
    },
    PlasmaDrilling = {
        skill = 'drilling',
        base = 45,
        success = 90,
        failure = 15
    },
      -- Additional minigames
    WireCut = {
        skill = 'electronics',
        base = 15,
        success = 30,
        failure = 5
    },
    SafeHack = {
        skill = 'hacking',
        base = 25,
        success = 50,
        failure = 8
    },
    MemoryGame = {
        skill = 'hacking',
        base = 20,
        success = 40,
        failure = 5
    },
    SkillBar = {
        skill = 'electronics',
        base = 10,
        success = 20,
        failure = 3
    },
    SkillBarHacking = {
        skill = 'hacking',
        base = 10,
        success = 20,
        failure = 3
    },
    SkillBarLockpicking = {
        skill = 'lockpicking',
        base = 10,
        success = 20,
        failure = 3
    },
    SkillBarDrilling = {
        skill = 'drilling',
        base = 10,
        success = 20,
        failure = 3
    }
}

-- Skill modifiers - how much each skill level affects minigame difficulty
Config.SkillModifiers = {
    Hacking = {
        baseModifier = 0.003, -- 0.3% per level
        maxModifier = 0.30,   -- 30% max at level 100
        affectsDifficulty = true,
        affectsSpeed = true,
        affectsTime = true
    },
    Lockpicking = {
        baseModifier = 0.004, -- 0.4% per level
        maxModifier = 0.40,   -- 40% max at level 100
        affectsDifficulty = true,
        affectsSpeed = false,
        affectsTime = false
    },
    Electronics = {
        baseModifier = 0.003, -- 0.3% per level
        maxModifier = 0.30,   -- 30% max at level 100
        affectsDifficulty = true,
        affectsSpeed = true,
        affectsTime = true
    },
    Drilling = {
        baseModifier = 0.004, -- 0.4% per level
        maxModifier = 0.40,   -- 40% max at level 100
        affectsDifficulty = true,
        affectsSpeed = false,
        affectsTime = true
    }
}

-- Perk effects - specific perks that affect minigames
Config.PerkEffects = {
    -- Hacking perks
    master_hacker = {
        timeBonus = 0.15,      -- 15% more time
        difficultyReduction = 0.10 -- 10% easier
    },
    firewall_specialist = {
        specificGame = 'Firewall',
        difficultyReduction = 0.20 -- 20% easier for Firewall game only
    },
    
    -- Lockpicking perks
    locksmith = {
        difficultyReduction = 0.15 -- 15% easier lockpicking
    },
    
    -- Electronics perks
    circuit_wizard = {
        specificGame = 'CircuitBreaker',
        difficultyReduction = 0.20 -- 20% easier for Circuit Breaker game only
    },
    
    -- Drilling perks
    master_driller = {
        timeBonus = 0.20,      -- 20% more time
        difficultyReduction = 0.10 -- 10% easier
    }
}

-- Function to show notifications based on the selected system
function ShowNotification(title, message, duration, type)
    if Config.NotificationSystem == 'qb' then
        -- QBCore notification
        exports['qb-core']:GetCoreObject().Functions.Notify(message, type, duration)
    elseif Config.NotificationSystem == 'esx' then
        -- ESX notification
        exports['esx']:ShowNotification(message)
    elseif Config.NotificationSystem == 'custom' then
        -- Custom notification system
        -- Replace with your custom notification system
        print(title .. ': ' .. message)
    else
        -- Fallback to basic notification
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        DrawNotification(false, false)
    end
end
