-- Kingz Minigames
-- Copyright (C) 2024 Kingz

local QBCore = exports['qb-core']:GetCoreObject()
local isHacking = false
local successCount = 0
local isSequencing = false
local sequenceSuccessCount = 0
local disableMovementControls = false
local callback = nil

local deathCheckThreadId = nil

local function cleanupMinigame()
    isHacking = false
    isSequencing = false
    disableMovementControls = false
    SetNuiFocus(false, false)
    EnableAllControlActions(0)
end

local function cancelMinigameOnDeath()
    SetNuiFocus(false, false)
    
    SendNUIMessage({ action = 'end', forced = true })
    Citizen.Wait(50)
    SendNUIMessage({ action = 'endSequence', forced = true })
    Citizen.Wait(50)
    SendNUIMessage({ action = 'endRhythm', forced = true })
    Citizen.Wait(50)
    SendNUIMessage({ action = 'endKeymash', forced = true })
    Citizen.Wait(50)
    SendNUIMessage({ action = 'endVarHack', forced = true })
    
    TriggerEvent('firewall-pulse:completeHack', false)
    TriggerEvent('backdoor-sequence:completeHack', false)
    TriggerEvent('circuit-rhythm:completeGame', false)
    
    SendNUIMessage({ 
        action = 'forceClose',
        reason = 'playerDied',
        playerId = GetPlayerServerId(PlayerId())
    })
    
    cleanupMinigame()
    
    if callback then
        callback(false)
        callback = nil
    end
end

local function startDeathCheck()
    if deathCheckThreadId then return end
    
    deathCheckThreadId = Citizen.CreateThread(function()
        while isHacking or isSequencing do
            if IsEntityDead(PlayerPedId()) then
                cancelMinigameOnDeath()
                break
            end
            Citizen.Wait(500)
        end
        deathCheckThreadId = nil
    end)
end

RegisterNUICallback('hackSuccess', function(data, cb)
    cleanupMinigame()
    if callback then
        callback(true)
        TriggerServerEvent('kingz-minigames:server:firewallComplete', true)
    end
    cb('ok')
end)

RegisterNUICallback('hackFail', function(data, cb)
    cleanupMinigame()
    if callback then
        callback(false)
        TriggerServerEvent('kingz-minigames:server:firewallComplete', false)
    end
    cb('ok')
end)

RegisterNUICallback('sequenceResult', function(data, cb)
    cleanupMinigame()
    if callback then
        callback(data.success)
        TriggerServerEvent('kingz-minigames:server:backdoorComplete', data.success)
    end
    cb('ok')
end)

RegisterNUICallback('rhythmResult', function(data, cb)
    cleanupMinigame()
    if callback then
        callback(data.success, data.score, data.maxCombo)
        TriggerServerEvent('kingz-minigames:server:circuitRhythmComplete', data.success)
    else
        print("Warning: rhythmResult callback was called when callback was nil")
    end
    cb('ok')
end)

RegisterNUICallback('keymashResult', function(data, cb)
    cleanupMinigame()
    
    if callback then
        callback(data.success)
    end
    
    cb('ok')
end)

RegisterNUICallback('varHackResult', function(data, cb)
    cleanupMinigame()
    if callback then
        callback(data.success)
        TriggerServerEvent('kingz-minigames:server:varHackComplete', data.success)
    end
    cb('ok')
end)

RegisterNUICallback('playerDied', function(_, cb)
    cb('ok')
end)

RegisterNUICallback('surgeClose', function(data, cb)
    cleanupMinigame()
    cb('ok')
end)

RegisterNUICallback('varHackClose', function(data, cb)
    cleanupMinigame()
    cb('ok')
end)

RegisterNetEvent('firewall-pulse:startHack')
AddEventHandler('firewall-pulse:startHack', function()
    if not isHacking then
        isHacking = true
        successCount = 0
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'start' })
        startDeathCheck()
    end
end)

RegisterNetEvent('firewall-pulse:endHack')
AddEventHandler('firewall-pulse:endHack', function()
    isHacking = false
    disableMovementControls = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'end' })
    
    successCount = 0
end)

RegisterNetEvent('backdoor-sequence:startHack')
AddEventHandler('backdoor-sequence:startHack', function()
    if not isSequencing then
        isSequencing = true
        sequenceSuccessCount = 0
        SetNuiFocus(false, true)
        SendNUIMessage({ action = 'startSequence' })
        startDeathCheck()
    end
end)

RegisterNetEvent('backdoor-sequence:endHack')
AddEventHandler('backdoor-sequence:endHack', function()
    isSequencing = false
    disableMovementControls = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'endSequence' })
    
    sequenceSuccessCount = 0
end)

-- Firewall Pulse Minigame
exports('StartFirewallPulse', function(requiredHacks, initialSpeed, maxSpeed, timeLimit, safeZoneMinWidth, safeZoneMaxWidth, safeZoneShrinkAmount)
    local p = promise.new()
    
    if isHacking then return false end
    
    -- Apply skill modifiers if enabled
    local hackingModifier = 1.0
    local timeBonus = 1.0
    
    if Config.UseSkills then
        hackingModifier = exports['kingz-minigames']:GetHackingModifier('Firewall')
        
        -- Apply modifier to make game easier based on skill level
        if safeZoneMinWidth then
            safeZoneMinWidth = safeZoneMinWidth * hackingModifier
        end
        
        if safeZoneMaxWidth then
            safeZoneMaxWidth = safeZoneMaxWidth * hackingModifier
        end
        
        -- Apply time bonus
        if timeLimit then
            timeLimit = timeLimit * CalculateTimeBonus('hacking', 'Firewall')
        end
    end
    
    local hackConfig = {
        requiredHacks = requiredHacks or 3,
        initialSpeed = initialSpeed or 2,
        maxSpeed = maxSpeed or 10,
        timeLimit = timeLimit or 10,
        safeZoneMinWidth = safeZoneMinWidth or 40,
        safeZoneMaxWidth = safeZoneMaxWidth or 120,
        safeZoneShrinkAmount = safeZoneShrinkAmount or 10
    }
    
    isHacking = true
    disableMovementControls = true
    SetNuiFocus(true, true)
    
    callback = function(success)
        TriggerServerEvent('kingz-minigames:server:firewallComplete', success)
        p:resolve(success)
        callback = nil
    end
    
    SendNUIMessage({ 
        action = 'start',
        config = hackConfig
    })
    
    startDeathCheck()
    return Citizen.Await(p)
end)

-- Backdoor Sequence Minigame
exports('StartBackdoorSequence', function(requiredSequences, sequenceLength, timeLimit, maxAttempts, timePenalty, minSimultaneousKeys, maxSimultaneousKeys, customKeys, keyHintText)
    local p = promise.new()
    
    if isHacking or isSequencing then return false end
    
    -- Apply skill modifiers if enabled
    local hackingModifier = 1.0
    local timeBonus = 1.0
    
    if Config.UseSkills then
        hackingModifier = exports['kingz-minigames']:GetHackingModifier('Backdoor')
        
        -- Apply modifier to make game easier based on skill level
        if sequenceLength then
            sequenceLength = math.max(1, math.floor(sequenceLength / hackingModifier))
        end
        
        -- Apply time bonus
        if timeLimit then
            timeLimit = timeLimit * CalculateTimeBonus('hacking', 'Backdoor')
        end
    end
    
    local sequenceConfig = {
        requiredSequences = requiredSequences or 3,
        sequenceLength = sequenceLength or 5,
        timeLimit = timeLimit or 15,
        maxAttempts = maxAttempts or 3,
        timePenalty = timePenalty or 1.0,
        minSimultaneousKeys = minSimultaneousKeys or 1,
        maxSimultaneousKeys = maxSimultaneousKeys or 3,
        possibleKeys = customKeys,
        keyHintText = keyHintText
    }
    
    callback = function(success)
        TriggerServerEvent('kingz-minigames:server:backdoorComplete', success)
        p:resolve(success)
        callback = nil
    end
    
    isSequencing = true
    disableMovementControls = true
    SetNuiFocus(true, false)
    SendNUIMessage({ 
        action = 'startSequence',
        config = sequenceConfig
    })
    
    startDeathCheck()
    return Citizen.Await(p)
end)

-- Circuit Rhythm Minigame
exports('StartCircuitRhythm', function(lanes, keys, noteSpeed, noteSpawnRate, requiredNotes, difficulty, maxWrongKeys, maxMissedNotes)
    local p = promise.new()
    
    if isHacking or isSequencing then return false end
    
    -- Apply skill modifiers if enabled
    local electronicsModifier = 1.0
    local timeBonus = 1.0
    
    if Config.UseSkills then
        electronicsModifier = exports['kingz-minigames']:GetElectronicsModifier('CircuitRhythm')
        
        -- Apply modifier to make game easier based on skill level
        if noteSpeed then
            noteSpeed = noteSpeed / electronicsModifier -- Slower notes = easier
        end
        
        if requiredNotes then
            requiredNotes = math.max(1, math.floor(requiredNotes / electronicsModifier))
        end
        
        if maxWrongKeys then
            maxWrongKeys = math.floor(maxWrongKeys * electronicsModifier)
        end
        
        if maxMissedNotes then
            maxMissedNotes = math.floor(maxMissedNotes * electronicsModifier)
        end
    end
    
    local rhythmConfig = {
        lanes = lanes or 4,
        keys = keys,
        noteSpeed = noteSpeed or 150,
        noteSpawnRate = noteSpawnRate or 1000,
        requiredNotes = requiredNotes or 20,
        difficulty = difficulty or "normal",
        maxWrongKeys = maxWrongKeys or 5,
        maxMissedNotes = maxMissedNotes or 3
    }
    
    callback = function(success, score, maxCombo)
        local resultDetails = {success = success, score = score or 0, maxCombo = maxCombo or 0}
        TriggerServerEvent('kingz-minigames:server:circuitRhythmComplete', success)
        p:resolve(success)
        callback = nil
    end
    
    isHacking = true
    disableMovementControls = true
    SetNuiFocus(true, false)
    SendNUIMessage({ 
        action = 'startRhythm',
        config = rhythmConfig
    })
    
    startDeathCheck()
    return Citizen.Await(p)
end)

-- Surge Override (Keymash) Minigame
exports('StartSurgeOverride', function(possibleKeys, requiredPresses, decayRate)
    local p = promise.new()
    
    if isHacking or isSequencing then return false end
    
    if not possibleKeys or #possibleKeys == 0 then
        possibleKeys = {'E'}
    end
    
    -- Apply skill modifiers if enabled
    local electronicsModifier = 1.0
    
    if Config.UseSkills then
        electronicsModifier = exports['kingz-minigames']:GetElectronicsModifier('SurgeOverride')
        
        -- Apply modifier to make game easier based on skill level
        if requiredPresses then
            requiredPresses = math.max(1, math.floor(requiredPresses / electronicsModifier))
        end
        
        if decayRate then
            decayRate = decayRate / electronicsModifier -- Slower decay = easier
        end
    end
    
    local keymashConfig = {
        possibleKeys = possibleKeys,
        keyPressValue = 100 / (requiredPresses or 50),
        decayRate = decayRate or 2
    }
    
    callback = function(success)
        p:resolve(success)
        callback = nil
    end
    
    isHacking = true
    disableMovementControls = true
    SetNuiFocus(true, false)
    SendNUIMessage({
        action = 'startKeymash',
        config = keymashConfig
    })
    
    startDeathCheck()
    return Citizen.Await(p)
end)

-- VAR Hack Minigame
exports('StartVarHack', function(blocks, speed)
    local p = promise.new()
    
    if isHacking then return false end
    
    -- Apply skill modifiers if enabled
    local hackingModifier = 1.0
    local timeBonus = 1.0
    
    if Config.UseSkills then
        hackingModifier = exports['kingz-minigames']:GetHackingModifier('VarHack')
        
        -- Apply modifier to make game easier based on skill level
        if blocks then
            blocks = math.max(1, math.floor(blocks / hackingModifier))
        end
        
        if speed then
            speed = speed * CalculateTimeBonus('hacking', 'VarHack')
        end
    end
    
    local varConfig = {
        blocks = blocks or 5,
        speed = speed or 5
    }
    
    callback = function(success)
        TriggerServerEvent('kingz-minigames:server:varHackComplete', success)
        p:resolve(success)
        callback = nil
    end
    
    isHacking = true
    disableMovementControls = true
    SetNuiFocus(true, true)
    SendNUIMessage({ 
        action = 'startVarHack',
        config = varConfig
    })
    
    startDeathCheck()
    return Citizen.Await(p)
end)

-- Brute Force Minigame
exports('StartBruteForce', function(numLives)
    local p = promise.new()
    
    -- Apply skill modifiers if enabled
    local hackingModifier = 1.0
    
    if Config.UseSkills then
        hackingModifier = exports['kingz-minigames']:GetHackingModifier('BruteForce')
        
        -- Apply modifier to make game easier based on skill level
        if numLives then
            numLives = math.floor(numLives * hackingModifier)
        end
    end
    
    local success = StartHackConnect(numLives)
    
    -- Award XP based on result
    TriggerServerEvent('kingz-minigames:server:bruteForceComplete', success)
    
    return success
end)

-- Data Crack Minigame
exports('StartDataCrack', function(difficulty)
    local p = promise.new()
    
    -- Apply skill modifiers if enabled
    local hackingModifier = 1.0
    
    if Config.UseSkills then
        hackingModifier = exports['kingz-minigames']:GetHackingModifier('DataCrack')
        
        -- Apply modifier to make game easier based on skill level
        if difficulty then
            difficulty = math.max(1, math.floor(difficulty / hackingModifier))
        end
    end
    
    local success = StartDataCrack(difficulty)
    
    -- Award XP based on result
    TriggerServerEvent('kingz-minigames:server:dataCrackComplete', success)
    
    return success
end)

-- Drilling Minigame
exports('StartDrilling', function()
    local p = promise.new()
    
    -- Apply skill modifiers if enabled
    -- Note: Drilling modifiers are applied directly in the drilling.lua file
    
    Drilling.Start(function(success)
        -- Award XP based on result
        TriggerServerEvent('kingz-minigames:server:drillingComplete', success)
        p:resolve(success)
    end)
    
    return Citizen.Await(p)
end)

-- Plasma Drilling Minigame
exports('StartPlasmaDrilling', function(difficultyOrCallback, optionalCallback)
    local p = promise.new()
    
    -- Apply skill modifiers if enabled
    local drillingModifier = 1.0
    local difficulty = 5
    
    if type(difficultyOrCallback) == 'number' then
        difficulty = difficultyOrCallback
    end
    
    if Config.UseSkills then
        drillingModifier = exports['kingz-minigames']:GetDrillingModifier('PlasmaDrilling')
        
        -- Apply modifier to make game easier based on skill level
        difficulty = math.max(1, math.floor(difficulty / drillingModifier))
    end
    
    if type(difficultyOrCallback) == 'function' then
        beginnDrilling(function(success)
            TriggerServerEvent('kingz-minigames:server:plasmaDrillingComplete', success)
            difficultyOrCallback(success)
        end)
        return
    else
        beginnDrilling(function(success)
            TriggerServerEvent('kingz-minigames:server:plasmaDrillingComplete', success)
            if optionalCallback then
                optionalCallback(success)
            end
            p:resolve(success)
        end)
        return Citizen.Await(p)
    end
end)

-- Circuit Breaker Minigame
exports('StartCircuitBreaker', function(levelNumber, difficultyLevel, delayStartMs, minFailureDelayTimeMs, maxFailureDelayTimeMs, disconnectChance, disconnectCheckRateMs, minReconnectTimeMs, maxReconnectTimeMs)
    -- Apply skill modifiers if enabled
    local electronicsModifier = 1.0
    
    if Config.UseSkills then
        electronicsModifier = exports['kingz-minigames']:GetElectronicsModifier('CircuitBreaker')
        
        -- Apply modifier to make game easier based on skill level
        if difficultyLevel then
            difficultyLevel = math.max(0, math.floor(difficultyLevel / electronicsModifier))
        end
        
        if disconnectChance then
            disconnectChance = disconnectChance / electronicsModifier
        end
    end
    
    levelNumber = levelNumber or math.random(1, 6)
    difficultyLevel = difficultyLevel or 0
    delayStartMs = delayStartMs or defaultDelayStartTimeMs
    minFailureDelayTimeMs = minFailureDelayTimeMs or minDelayEndGameTimeMs
    maxFailureDelayTimeMs = maxFailureDelayTimeMs or maxDelayEndGameTimeMs
    disconnectChance = disconnectChance or getDisconnectChanceFromDifficulty(difficultyLevel)
    disconnectCheckRateMs = disconnectCheckRateMs or getDisconnectCheckRateMsFromDifficulty(difficultyLevel)
    minReconnectTimeMs = minReconnectTimeMs or defaultMinReconnectTimeMs
    maxReconnectTimeMs = maxReconnectTimeMs or defaultMaxReconnectTimeMs
    
    local success = runMiniGame(levelNumber, difficultyLevel, delayStartMs, minFailureDelayTimeMs, maxFailureDelayTimeMs, disconnectChance, disconnectCheckRateMs, minReconnectTimeMs, maxReconnectTimeMs)
    
    -- Award XP based on result
    TriggerServerEvent('kingz-minigames:server:circuitBreakerComplete', success)
    
    return success
end)

-- Lockpick Minigame
exports('Lockpick', function(options, cb)
    local strength = options and options.strength or 0.5
    local difficulty = options and options.difficulty or Config.DefaultDifficulty
    local pins = options and options.pins or Config.DefaultPinAmount
    
    -- Apply skill modifiers if enabled
    local lockpickModifier = 1.0
    
    if Config.UseSkills then
        lockpickModifier = exports['kingz-minigames']:GetLockpickModifier()
        
        -- Apply modifier to make game easier based on skill level
        strength = math.min(1.0, strength * lockpickModifier)
        difficulty = math.max(1, math.floor(difficulty / lockpickModifier))
    end
    
    local success = exports["t3_lockpick"]:startLockpick(strength, difficulty, pins)
    
    -- Award XP based on result
    TriggerServerEvent('kingz-minigames:server:lockpickComplete', success)
    
    if cb then
        cb(success)
    end
    
    return success
end)

if Config.DebugCommands then 
    RegisterCommand('testsurge', function()
        local success = exports['kingz-minigames']:StartSurgeOverride({'E', 'F'}, 30, 2)
        print("Result: ", success)
    end, false)

    RegisterCommand('testfirewall', function()
        local success = exports['kingz-minigames']:StartFirewallPulse(3, 2, 10, 8, 30, 120, 40)
        print("Result: ", success)
    end, false)

    RegisterCommand('testsequence', function()
        local success = exports['kingz-minigames']:StartBackdoorSequence(3, 20, 20, 3, 2.0, 3, 6, {'W', 'A', 'S', 'D'}, 'W, A, S, D only')
        print("Result: ", success)
    end, false)

    RegisterCommand('testrhythm', function()
        local result = exports['kingz-minigames']:StartCircuitRhythm(4, {'A','S','D','F'}, 150, 800, 15, "normal", 5, 3)
        print("Result: ", result)
    end, false)

    RegisterCommand('testvarhack', function()
        local success = exports['kingz-minigames']:StartVarHack(5, 25)
        print("Result: ", success)
    end, false)
    
    RegisterCommand('testlockpick', function()
        local success = exports['kingz-minigames']:Lockpick({strength = 0.75, difficulty = 2, pins = 4})
        print("Result: ", success)
    end, false)
    
    RegisterCommand('testbruteforce', function()
        local success = exports['kingz-minigames']:StartBruteForce(5)
        print("Result: ", success)
    end, false)
    
    RegisterCommand('testdatacrack', function()
        local success = exports['kingz-minigames']:StartDataCrack(3)
        print("Result: ", success)
    end, false)
    
    RegisterCommand('testdrill', function()
        local success = exports['kingz-minigames']:StartDrilling()
        print("Result: ", success)
    end, false)
    
    RegisterCommand('testplasma', function()
        local success = exports['kingz-minigames']:StartPlasmaDrilling(5)
        print("Result: ", success)
    end, false)
    
    RegisterCommand('testcircuit', function()
        local success = exports['kingz-minigames']:StartCircuitBreaker(1, 0)
        print("Result: ", success)
    end, false)
end 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isHacking or isSequencing then
            if IsControlJustPressed(0, 177) then -- BACKSPACE key
                if isHacking then
                    isHacking = false
                    SetNuiFocus(false, false)
                    SendNUIMessage({ action = 'end' })
                    TriggerServerEvent('firewall-pulse:completeHack', false)
                elseif isSequencing then
                    isSequencing = false
                    SetNuiFocus(false, false)
                    SendNUIMessage({ action = 'endSequence' })
                    TriggerServerEvent('backdoor-sequence:completeHack', false)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if disableMovementControls or isHacking then
            -- Disable player movement controls
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 30, true) -- MoveLeftRight
            DisableControlAction(0, 31, true) -- MoveUpDown
            DisableControlAction(0, 32, true) -- W
            DisableControlAction(0, 33, true) -- S
            DisableControlAction(0, 34, true) -- A
            DisableControlAction(0, 35, true) -- D
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
            
            -- Disable ALL movement controls
            DisableControlAction(0, 36, true) -- Enter Vehicle
            DisableControlAction(0, 44, true) -- Cover
            DisableControlAction(0, 37, true) -- Select Weapon
            DisableControlAction(0, 288, true) -- Phone
            DisableControlAction(0, 289, true) -- Inventory
            DisableControlAction(0, 170, true) -- F3 Menu
            DisableControlAction(0, 166, true) -- F5 Menu
            DisableControlAction(0, 167, true) -- F6 Menu
            DisableControlAction(0, 168, true) -- F7 Menu
            DisableControlAction(0, 169, true) -- F8 Menu
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isHacking then
            -- Mapping of FiveM control codes to JS keyCodes
            local keyMap = {
                [38] = 69,  -- E
                [22] = 32,  -- SPACE
                [23] = 70,  -- F
                [44] = 81,  -- Q
                [45] = 82,  -- R
                [245] = 84, -- T
                [246] = 89, -- Y
                [303] = 85, -- U
                [304] = 73, -- I
                [24] = 79,  -- O
                [25] = 80,  -- P
                [34] = 65,  -- A
                [8] = 83,   -- S
                [9] = 68,   -- D
                [47] = 71,  -- G
                [74] = 72,  -- H
                [311] = 74, -- J
                [311] = 75, -- K
                [182] = 76, -- L
                [20] = 90,  -- Z
                [73] = 88,  -- X
                [26] = 67,  -- C
                [0] = 86,   -- V
                [29] = 66,  -- B
                [249] = 78, -- N
                [244] = 77, -- M
                [157] = 49, -- 1
                [158] = 50, -- 2
                [160] = 51, -- 3
                [164] = 52, -- 4
                [165] = 53, -- 5
                [159] = 54, -- 6
                [161] = 55, -- 7
                [162] = 56, -- 8
                [163] = 57, -- 9
                [163] = 48  -- 0
            }
            
            for fivemCode, jsCode in pairs(keyMap) do
                if IsControlJustPressed(0, fivemCode) then
                    SendNUIMessage({
                        action = 'keyPress',
                        keyCode = jsCode
                    })
                end
            end
        end
    end
end)

RegisterNetEvent('firewall-pulse:completeHack')
AddEventHandler('firewall-pulse:completeHack', function(success)
    cleanupMinigame()
    SendNUIMessage({ action = 'end' })
    successCount = 0
end)

RegisterNetEvent('backdoor-sequence:completeHack')
AddEventHandler('backdoor-sequence:completeHack', function(success)
    cleanupMinigame()
    SendNUIMessage({ action = 'endSequence' })
    sequenceSuccessCount = 0
end)

RegisterNetEvent('circuit-rhythm:completeGame')
AddEventHandler('circuit-rhythm:completeGame', function(success)
    cleanupMinigame()
    SendNUIMessage({ action = 'endRhythm' })
end)
