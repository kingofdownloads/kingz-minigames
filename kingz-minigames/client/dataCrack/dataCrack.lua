-- Kingz Minigames
-- Copyright (C) 2024 Kingz

local QBCore = exports['qb-core']:GetCoreObject()
local scaleform = nil
local gameStarted = false
local gameFinished = false
local gameResult = false
local difficulty = 3

local function loadScaleform()
    scaleform = RequestScaleformMovie("HACKING_PC")
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    return scaleform
end

local function unloadScaleform()
    SetScaleformMovieAsNoLongerNeeded(scaleform)
    scaleform = nil
end

local function setupScaleform()
    local sf = loadScaleform()
    
    BeginScaleformMovieMethod(sf, "SET_LABELS")
    ScaleformMovieMethodAddParamTextureNameString("Local")
    ScaleformMovieMethodAddParamTextureNameString("Target")
    ScaleformMovieMethodAddParamTextureNameString("IP")
    ScaleformMovieMethodAddParamTextureNameString("NET")
    ScaleformMovieMethodAddParamTextureNameString("LOADING")
    ScaleformMovieMethodAddParamTextureNameString("CONNECTING")
    EndScaleformMovieMethod()
    
    BeginScaleformMovieMethod(sf, "SET_BACKGROUND")
    ScaleformMovieMethodAddParamInt(1)
    EndScaleformMovieMethod()
    
    BeginScaleformMovieMethod(sf, "ADD_PROGRAM")
    ScaleformMovieMethodAddParamFloat(1.0)
    ScaleformMovieMethodAddParamFloat(4.0)
    ScaleformMovieMethodAddParamTextureNameString("My Computer")
    EndScaleformMovieMethod()
    
    BeginScaleformMovieMethod(sf, "ADD_PROGRAM")
    ScaleformMovieMethodAddParamFloat(6.0)
    ScaleformMovieMethodAddParamFloat(6.0)
    ScaleformMovieMethodAddParamTextureNameString("Power Off")
    EndScaleformMovieMethod()
    
    return sf
end

local function startHack()
    BeginScaleformMovieMethod(scaleform, "OPEN_APP")
    ScaleformMovieMethodAddParamFloat(1.0)
    EndScaleformMovieMethod()
    
    BeginScaleformMovieMethod(scaleform, "SET_DATACRACK_DIFFICULTY")
    ScaleformMovieMethodAddParamInt(difficulty)
    EndScaleformMovieMethod()
    
    Citizen.Wait(500)
    
    BeginScaleformMovieMethod(scaleform, "RUN_DATACRACK")
    EndScaleformMovieMethod()
    
    gameStarted = true
end

local function processInput()
    DisableControlAction(0, 24, true) -- Attack
    DisableControlAction(0, 25, true) -- Aim
    DisableControlAction(0, 47, true) -- Weapon
    DisableControlAction(0, 58, true) -- Weapon
    DisableControlAction(0, 263, true) -- Melee Attack 1
    DisableControlAction(0, 264, true) -- Melee Attack 2
    DisableControlAction(0, 257, true) -- Attack 2
    DisableControlAction(0, 140, true) -- Melee Attack Light
    DisableControlAction(0, 141, true) -- Melee Attack Heavy
    DisableControlAction(0, 142, true) -- Melee Attack Alternate
    DisableControlAction(0, 143, true) -- Melee Block
    DisableControlAction(0, 177, true) -- Escape
    DisableControlAction(0, 200, true) -- ESC
    DisableControlAction(0, 202, true) -- ESC
    DisableControlAction(0, 322, true) -- ESC
    
    if IsDisabledControlJustPressed(0, 172) then -- UP
        BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT_UP")
        EndScaleformMovieMethod()
    end
    
    if IsDisabledControlJustPressed(0, 173) then -- DOWN
        BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT_DOWN")
        EndScaleformMovieMethod()
    end
    
    if IsDisabledControlJustPressed(0, 174) then -- LEFT
        BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT_LEFT")
        EndScaleformMovieMethod()
    end
    
    if IsDisabledControlJustPressed(0, 175) then -- RIGHT
        BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT_RIGHT")
        EndScaleformMovieMethod()
    end
    
    if IsDisabledControlJustPressed(0, 24) then -- LEFT CLICK
        BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT_SELECT")
        EndScaleformMovieMethod()
    end
end

local function checkResult()
    BeginScaleformMovieMethod(scaleform, "GET_DATACRACK_RESULT")
    local result = EndScaleformMovieMethodReturnValue()
    
    while not IsScaleformMovieMethodReturnValueReady(result) do
        Citizen.Wait(0)
    end
    
    local outcome = GetScaleformMovieMethodReturnValueBool(result)
    
    if outcome then
        -- Success
        gameResult = true
        gameFinished = true
        ShowNotification('Success', 'Data cracked successfully!', 3000, 'success')
        PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
    else
        -- Check if still in progress
        BeginScaleformMovieMethod(scaleform, "IS_DATACRACK_ACTIVE")
        local activeResult = EndScaleformMovieMethodReturnValue()
        
        while not IsScaleformMovieMethodReturnValueReady(activeResult) do
            Citizen.Wait(0)
        end
        
        local isActive = GetScaleformMovieMethodReturnValueBool(activeResult)
        
        if not isActive then
            -- Failed
            gameResult = false
            gameFinished = true
            ShowNotification('Failed', 'Data crack failed!', 3000, 'error')
            PlaySoundFrontend(-1, "Hack_Failed", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
        end
    end
end

function StartDataCrack(difficultyLevel)
    -- Apply skill modifiers if enabled
    if Config.UseSkills then
        local hackingModifier = exports['kingz-minigames']:GetHackingModifier('DataCrack')
        difficultyLevel = math.max(1, math.floor((difficultyLevel or 3) / hackingModifier))
    else
        difficultyLevel = difficultyLevel or 3
    end
    
    difficulty = math.min(math.max(difficultyLevel, 1), 5)
    gameStarted = false
    gameFinished = false
    gameResult = false
    
    setupScaleform()
    startHack()
    
    SetNuiFocus(false, false)
    
    while not gameFinished do
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
        processInput()
        checkResult()
        Citizen.Wait(0)
    end
    
    Citizen.Wait(2000)
    unloadScaleform()
    
    return gameResult
end

exports('StartDataCrack', function(difficultyLevel)
    local success = StartDataCrack(difficultyLevel)
    TriggerServerEvent('kingz-minigames:server:dataCrackComplete', success)
    return success
end)

if Config.DebugCommands then
    RegisterCommand('testdatacrack', function()
        local success = exports['kingz-minigames']:StartDataCrack(3)
        print("DataCrack result: " .. tostring(success))
    end, false)
end
