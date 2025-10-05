-- Kingz Minigames
-- Copyright (C) 2024 Kingz

PlasmaDrilling = {}

PlasmaDrilling.DisabledControls = {30,31,32,33,34,35}
PlasmaDrilling.CameraHandle = nil
PlasmaDrilling.ControlsNotificationId = nil

PlasmaDrilling.Start = function(callback)
    if not PlasmaDrilling.Active then
        PlasmaDrilling.Active = true
        PlasmaDrilling.Init()
        PlasmaDrilling.Update(callback)
    end
end

PlasmaDrilling.Init = function()
  if PlasmaDrilling.Scaleform then
    Scaleforms.UnloadMovie(PlasmaDrilling.Scaleform)
  end

  PlasmaDrilling.Scaleform = Scaleforms.LoadMovie(PlasmaDrilling.Type)
  if PlasmaDrilling.Type == 'VAULT_LASER' then
    extra = "SET_LASER_WIDTH"
  else
    extra = "SET_SPEED"
  end
  
  -- Apply skill modifiers if enabled
  local drillingModifier = 1.0
  
  if Config.UseSkills then
      drillingModifier = exports['kingz-minigames']:GetDrillingModifier('PlasmaDrilling')
      
      -- Drilling speed and temperature are affected by skill level
      PlasmaDrilling.DrillSpeed = 0.0
      PlasmaDrilling.DrillPos = 0.0
      PlasmaDrilling.DrillTemp = 0.0 / drillingModifier -- Lower temperature rise with higher skill
      PlasmaDrilling.HoleDepth = 0.0
  else
      PlasmaDrilling.DrillSpeed = 0.0
      PlasmaDrilling.DrillPos = 0.0
      PlasmaDrilling.DrillTemp = 0.0
      PlasmaDrilling.HoleDepth = 0.0
  end

  Scaleforms.PopVoid(PlasmaDrilling.Scaleform, "REVEAL")
  Scaleforms.PopFloat(PlasmaDrilling.Scaleform, extra,     0.0)
  Scaleforms.PopFloat(PlasmaDrilling.Scaleform,"SET_DRILL_POSITION",  0.0)
  Scaleforms.PopFloat(PlasmaDrilling.Scaleform,"SET_TEMPERATURE",     0.0)
  Scaleforms.PopFloat(PlasmaDrilling.Scaleform,"SET_HOLE_DEPTH",      0.0)
  Scaleforms.PopInt(PlasmaDrilling.Scaleform,"SET_NUM_DISCS",      6)
end

PlasmaDrilling.Update = function(callback)
  while PlasmaDrilling.Active do
    PlasmaDrilling.Draw()
    PlasmaDrilling.DisableControls()
    
    if IsEntityDead(PlayerPedId()) then
      print("Plasma drilling cancelled - player died")
      PlasmaDrilling.Result = false
      PlasmaDrilling.Active = false
      
      Scaleforms.PopVoid(PlasmaDrilling.Scaleform, "RESET")
      
      break
    end
    
    PlasmaDrilling.HandleControls()
    Wait(0)
  end
  callback(PlasmaDrilling.Result)
end

PlasmaDrilling.Draw = function()
  DrawScaleformMovieFullscreen(PlasmaDrilling.Scaleform,255,255,255,255,255)
end

PlasmaDrilling.HandleControls = function()
  if IsControlJustPressed(0, 200) or IsControlJustPressed(0, 177) then -- ESC key
    PlasmaDrilling.Result = false
    PlasmaDrilling.Active = false
    Scaleforms.PopVoid(PlasmaDrilling.Scaleform, "RESET")
    return
  end
  
  -- Apply skill modifiers if enabled
  local drillingModifier = 1.0
  local heatModifier = 1.0
  
  if Config.UseSkills then
      drillingModifier = exports['kingz-minigames']:GetDrillingModifier('PlasmaDrilling')
      heatModifier = 1.0 / drillingModifier -- Lower heat generation with higher skill
  end
  
  local last_pos = PlasmaDrilling.DrillPos
  if IsControlJustPressed(0,188) then -- (UP)
    PlasmaDrilling.DrillPos = math.min(1.0,PlasmaDrilling.DrillPos + 0.01)
    Scaleforms.PopVoid(PlasmaDrilling.Scaleform,"burstOutSparks")
  elseif IsControlPressed(0,188) then -- (UP)
    local speedFactor = 0.1 * GetFrameTime() / (math.max(0.1,PlasmaDrilling.DrillTemp) * 10)
    -- Apply drilling skill modifier to speed
    speedFactor = speedFactor * drillingModifier
    PlasmaDrilling.DrillPos = math.min(1.0,PlasmaDrilling.DrillPos + speedFactor)
  elseif IsControlJustPressed(0,187) then -- (DOWN)
    PlasmaDrilling.DrillPos = math.max(0.0,PlasmaDrilling.DrillPos - 0.01)
  elseif IsControlPressed(0,187) then -- (DOWN)
    PlasmaDrilling.DrillPos = math.max(0.0,PlasmaDrilling.DrillPos - (0.1 * GetFrameTime()))
  end

  local last_speed = PlasmaDrilling.DrillSpeed
  if IsControlJustPressed(0,190) then -- (RIGHT)
    -- Apply drilling skill modifier to max speed
    local maxSpeed = 1.0 * drillingModifier
    PlasmaDrilling.DrillSpeed = math.min(maxSpeed, PlasmaDrilling.DrillSpeed + 0.05)
  elseif IsControlPressed(0,190) then -- (RIGHT)
    local maxSpeed = 1.0 * drillingModifier
    PlasmaDrilling.DrillSpeed = math.min(maxSpeed, PlasmaDrilling.DrillSpeed + (0.5 * GetFrameTime()))
  elseif IsControlJustPressed(0,189) then -- (LEFT)
    PlasmaDrilling.DrillSpeed = math.max(0.0,PlasmaDrilling.DrillSpeed - 0.05)
  elseif IsControlPressed(0,189) then -- (LEFT)
    PlasmaDrilling.DrillSpeed = math.max(0.0,PlasmaDrilling.DrillSpeed - (0.5 * GetFrameTime()))
  end

  local last_temp = PlasmaDrilling.DrillTemp
  if last_pos < PlasmaDrilling.DrillPos then
    if PlasmaDrilling.DrillSpeed > 0.4 then
      -- Apply heat modifier based on skill level
      local heatRate = (0.05 * GetFrameTime()) * (PlasmaDrilling.DrillSpeed * 10) * heatModifier
      PlasmaDrilling.DrillTemp = math.min(1.0, PlasmaDrilling.DrillTemp + heatRate)
      Scaleforms.PopFloat(PlasmaDrilling.Scaleform,"SET_DRILL_POSITION",PlasmaDrilling.DrillPos)
    else
      if PlasmaDrilling.DrillPos < 0.1 or PlasmaDrilling.DrillPos < PlasmaDrilling.HoleDepth then
        Scaleforms.PopFloat(PlasmaDrilling.Scaleform,"SET_DRILL_POSITION",PlasmaDrilling.DrillPos)
      else
        PlasmaDrilling.DrillPos = last_pos
        PlasmaDrilling.DrillTemp = math.min(1.0,PlasmaDrilling.DrillTemp + (0.01 * GetFrameTime()))
      end
    end
  elseif not IsControlPressed(0, 188) then
    -- Apply cooling modifier based on skill level
    local coolingRate = (0.05 * GetFrameTime()) * math.max(0.005,(PlasmaDrilling.DrillSpeed * 10) /2) * drillingModifier
    PlasmaDrilling.DrillTemp = math.max(0.0, PlasmaDrilling.DrillTemp - coolingRate)
    
    if PlasmaDrilling.DrillPos ~= PlasmaDrilling.HoleDepth then
      Scaleforms.PopFloat(PlasmaDrilling.Scaleform,"SET_DRILL_POSITION",PlasmaDrilling.DrillPos)
    end
  else
    if PlasmaDrilling.DrillPos < PlasmaDrilling.HoleDepth then
      -- Apply cooling modifier based on skill level
      local coolingRate = (0.05 * GetFrameTime()) * math.max(0.005,(PlasmaDrilling.DrillSpeed * 10) /2) * drillingModifier
      PlasmaDrilling.DrillTemp = math.max(0.0, PlasmaDrilling.DrillTemp - coolingRate)
    end

    if PlasmaDrilling.DrillPos ~= PlasmaDrilling.HoleDepth then
      Scaleforms.PopFloat(PlasmaDrilling.Scaleform,"SET_DRILL_POSITION",PlasmaDrilling.DrillPos)
    end
  end

  if last_speed ~= PlasmaDrilling.DrillSpeed then
    Scaleforms.PopFloat(PlasmaDrilling.Scaleform,extra,PlasmaDrilling.DrillSpeed)
  end

  if last_temp ~= PlasmaDrilling.DrillTemp then    
    Scaleforms.PopFloat(PlasmaDrilling.Scaleform,"SET_TEMPERATURE",PlasmaDrilling.DrillTemp)
  end

  if PlasmaDrilling.DrillTemp >= 1.0 then
    PlasmaDrilling.Result = false
    PlasmaDrilling.Active = false
    Scaleforms.PopVoid(PlasmaDrilling.Scaleform, "RESET")
  elseif PlasmaDrilling.DrillPos >= 1.0 then
    PlasmaDrilling.Result = true
    PlasmaDrilling.Active = false
    Scaleforms.PopVoid(PlasmaDrilling.Scaleform, "RESET")
  end

  PlasmaDrilling.HoleDepth = (PlasmaDrilling.DrillPos > PlasmaDrilling.HoleDepth and PlasmaDrilling.DrillPos or PlasmaDrilling.HoleDepth)
end

PlasmaDrilling.DisableControls = function()
  for _,control in ipairs(PlasmaDrilling.DisabledControls) do
    DisableControlAction(0,control,true)
  end
end

PlasmaDrilling.EnableControls = function()
  for _,control in ipairs(PlasmaDrilling.DisabledControls) do
    DisableControlAction(0,control,true)
  end
end

function setupDrillingCamera()
    if PlasmaDrilling.CameraHandle then
        DestroyCam(PlasmaDrilling.CameraHandle, false)
        RenderScriptCams(false, false, 0, true, true)
        PlasmaDrilling.CameraHandle = nil
    end
    
    local playerPed = PlayerPedId()
    
    PlasmaDrilling.CameraHandle = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    AttachCamToEntity(PlasmaDrilling.CameraHandle, playerPed, 1, -0.65, 0.4, true)
    
    SetCamRot(PlasmaDrilling.CameraHandle, 0.0, 0.0, GetEntityHeading(playerPed) - -35.0, 2)
    SetCamFov(PlasmaDrilling.CameraHandle, 50.0)
    
    RenderScriptCams(true, true, 500, true, true)
end

function beginnDrilling(callback)
  local ped = PlayerPedId()
  local animDict = "anim@heists@fleeca_bank@drilling"
  local animLib = "drill_straight_idle"

  RequestAnimDict(animDict)
  while not HasAnimDictLoaded(animDict) do
      Wait(50)
  end
  
  SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
  Wait(500)

  local drillProp = GetHashKey('hei_prop_heist_drill')
  local boneIndex = GetPedBoneIndex(ped, 28422)

  RequestModel(drillProp)
  while not HasModelLoaded(drillProp) do
      Wait(100)
  end

  TaskPlayAnim(ped, animDict, animLib, 1.0, -1.0, -1, 2, 0, 0, 0, 0)
  local attachedDrill = CreateObject(drillProp, 1.0, 1.0, 1.0, true, true, false)
  AttachEntityToEntity(attachedDrill, ped, boneIndex, 0.0, 0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
  SetEntityAsMissionEntity(attachedDrill, true, true)

  setupDrillingCamera()

  ShowNotification('Plasma Drilling Controls', 'Up/Down Arrow - Move Drill\n‎ ‎ ‎ ‎ ‎ Left/Right Arrow - Speed Up\nESC - Cancel', 0, 'info')

  loadDrillSound()
  Wait(100)
  local soundId = GetSoundId()
  PlaySoundFromEntity(soundId, "Drill", attachedDrill, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)

  ShakeGameplayCam("SKY_DIVING_SHAKE", 0.6)

  PlasmaDrilling.Type = 'VAULT_LASER'
  PlasmaDrilling.Start(function(status)
      DeleteObject(attachedDrill)
      DeleteEntity(attachedDrill)
      ClearPedTasksImmediately(ped)
      StopSound(soundId)
      StopGameplayCamShaking(true)

      if PlasmaDrilling.CameraHandle then
          DestroyCam(PlasmaDrilling.CameraHandle, false)
          RenderScriptCams(false, false, 500, true, true)
          PlasmaDrilling.CameraHandle = nil
      end

      stopDrilling(status)
      if callback then
          callback(status)
      end
  end)
end

function robTimer()
	robTime = Config.RobberyTime * 60

	Citizen.CreateThread(function()
		repeat
			Citizen.Wait(1000)
			robTime = robTime - 1
		until robTime == 0
	end)
end

function stopDrilling(success)
  local ped = PlayerPedId()
  FreezeEntityPosition(ped, false)
  ClearPedTasks(ped)
  ClearPedSecondaryTask(ped)
  robTime = 0
  RobbingATM = false    

  if success then
      ShowNotification('Success', 'Plasma drilling complete!', 3000, 'success')
      TriggerEvent("kingz-minigames:plasmaDrillComplete", true)
  else
      ShowNotification('Failed', 'Plasma drilling failed!', 3000, 'error')
      TriggerEvent("kingz-minigames:plasmaDrillComplete", false)
  end
end

local function clamp(value, min, max)
  if value < min then return min end
  if value > max then return max end
  return value
end

exports('StartPlasmaDrilling', function(difficultyOrCallback, optionalCallback)
    if PlasmaDrilling.Active then return false end
    
    local success = false
    local completed = false
    local difficulty = 5
    local userCallback
    
    if type(difficultyOrCallback) == 'function' then
        userCallback = difficultyOrCallback
    elseif type(difficultyOrCallback) == 'number' then
        difficulty = difficultyOrCallback
        userCallback = optionalCallback
    end
    
    -- Apply skill modifiers if enabled
    if Config.UseSkills then
        local drillingModifier = exports['kingz-minigames']:GetDrillingModifier('PlasmaDrilling')
        difficulty = math.max(1, math.floor(difficulty / drillingModifier))
    end
    
    PlasmaDrilling.Difficulty = clamp(difficulty, 1, 10)
    
    beginnDrilling(function(result)
        success = result
        completed = true
        
        -- Trigger server event for XP reward
        TriggerServerEvent('kingz-minigames:server:plasmaDrillingComplete', result)
        
        if userCallback then
            userCallback(result)
            return
        end
    end)

    if not userCallback then
        while not completed do
            Wait(100)
        end
        
        return success
    end
end)

if Config.DebugCommands then 
  RegisterCommand('testplasma', function()
      local success = exports['kingz-minigames']:StartPlasmaDrilling(5)
      if success then
          print("Drilling successful!")
      else
          print("Drilling failed!")
      end
  end, false)
end
