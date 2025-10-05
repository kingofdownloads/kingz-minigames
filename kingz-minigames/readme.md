# Kingz Minigames

A comprehensive minigames resource for FiveM servers with skills integration.

## Features

- Multiple minigames for various activities
- Full integration with kingz-skills system
- XP rewards for completing minigames
- Skill-based difficulty adjustments
- Perk effects for additional bonuses

## Minigames Included

### Hacking Minigames
- Firewall Pulse - Click to stop the pulse in the safe zone
- Backdoor Sequence - Input key sequences in the correct order
- VAR Hack - Memory-based number sequence game
- Brute Force - Connect to the network by selecting the correct nodes
- Data Crack - Navigate through a maze to crack data
- Safe Hack - Remember and repeat patterns to hack a safe
- Memory Game - Memorize and select highlighted cells

### Lockpicking Minigames
- Lockpick - Pick locks by aligning pins correctly

### Electronics Minigames
- Circuit Breaker - Navigate through a circuit without disconnecting
- Circuit Rhythm - Hit notes in sync with the beat
- Surge Override - Rapidly press keys to override a surge
- Wire Cut - Cut the correct wire to disarm a system

### Drilling Minigames
- Drilling - Drill through a safe by managing speed and temperature
- Plasma Drilling - Use a plasma cutter to breach a vault

### General Minigames
- Skill Bar - Time-based skill check for various activities

## Skills Integration

This resource integrates with the kingz-skills system to provide:

1. XP rewards for completing minigames
2. Skill-based difficulty adjustments
3. Perk effects for additional bonuses

### Skills Used

- Hacking - Affects hacking minigames
- Lockpicking - Affects lockpicking minigames
- Electronics - Affects electronics minigames
- Drilling - Affects drilling minigames

### Perks Support

The system checks for the following perks:

- master_hacker - Provides time bonus and difficulty reduction for hacking minigames
- firewall_specialist - Makes Firewall Pulse minigame specifically easier
- locksmith - Makes lockpicking easier
- circuit_wizard - Makes Circuit Breaker minigame specifically easier
- master_driller - Provides time bonus and difficulty reduction for drilling minigames

## Installation

1. Place the `kingz-minigames` folder in your server's resources directory
2. Ensure you have the required dependencies:
   - QBCore Framework
   - ox_lib
   - oxmysql
   - kingz-skills
3. Add the following to your server.cfg:
4. Configure the notification system and skill rewards in `config.lua` to match your server's setup

## Usage Examples

```lua
-- Lockpick a door with skill integration
local success = exports['kingz-minigames']:Lockpick({strength = 0.75, difficulty = 2, pins = 4})
if success then
 -- Door unlocked
 -- XP is automatically awarded through the server event
else
 -- Failed to unlock
 -- Small amount of XP still awarded for the attempt
end

-- Hack a computer with skill integration
local success = exports['kingz-minigames']:StartFirewallPulse(3, 2, 10, 8, 30, 120, 40)
if success then
 -- Computer hacked
 -- XP is automatically awarded through the server event
else
 -- Failed to hack
 -- Small amount of XP still awarded for the attempt
end

Available Exports
lua


-- Hacking minigames
exports['kingz-minigames']:StartFirewallPulse(requiredHacks, initialSpeed, maxSpeed, timeLimit, safeZoneMinWidth, safeZoneMaxWidth, safeZoneShrinkAmount)
exports['kingz-minigames']:StartBackdoorSequence(requiredSequences, sequenceLength, timeLimit, maxAttempts, timePenalty, minSimultaneousKeys, maxSimultaneousKeys, customKeys, keyHintText)
exports['kingz-minigames']:StartVarHack(blocks, speed)
exports['kingz-minigames']:StartBruteForce(numLives)
exports['kingz-minigames']:StartDataCrack(difficulty)
exports['kingz-minigames']:SafeHack(levels, timeLimit)
exports['kingz-minigames']:MemoryGame(gridSize, timeLimit, numItems)

-- Lockpicking minigames
exports['kingz-minigames']:Lockpick(options, cb) -- options: {strength, difficulty, pins}

-- Electronics minigames
exports['kingz-minigames']:StartCircuitBreaker(levelNumber, difficultyLevel)
exports['kingz-minigames']:StartCircuitRhythm(lanes, keys, noteSpeed, noteSpawnRate, requiredNotes, difficulty, maxWrongKeys, maxMissedNotes)
exports['kingz-minigames']:StartSurgeOverride(possibleKeys, requiredPresses, decayRate)
exports['kingz-minigames']:WireCut(numWires, timeLimit, correctWire)

-- Drilling minigames
exports['kingz-minigames']:StartDrilling()
exports['kingz-minigames']:StartPlasmaDrilling(difficulty)

-- General minigames
exports['kingz-minigames']:SkillBar(difficulty, skillCount, skillType)

-- Skills integration exports
exports['kingz-minigames']:GetHackingModifier(gameType)
exports['kingz-minigames']:GetLockpickModifier()
exports['kingz-minigames']:GetDrillingModifier(gameType)
exports['kingz-minigames']:GetElectronicsModifier(gameType)
Configuration
You can configure various aspects of the minigames in the config.lua file:

Notification system
XP rewards for minigames
Skill modifiers
Perk effects
Credits
Kingz Development Team
code



This completes the full file structure for the kingz-minigames resource with skills integration. The resource now includes a comprehensive set of minigames that are fully integrated with your kingz-skills system, allowing players to earn XP and benefit from their skill levels when performing various activities in your server.