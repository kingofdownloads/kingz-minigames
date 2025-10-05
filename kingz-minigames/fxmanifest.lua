fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'kingz-minigames'
author 'Kingz'
description 'Comprehensive minigames resource with skills integration'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua',
    'client/skills.lua',
    'client/bruteForce.lua',
    'client/dataCrack.lua',
    'client/fleecaDrilling.lua',
    'client/plasmaDrilling.lua',
    'client/scaleforms.lua',
    'client/circuit.lua',
    'client/circuitBreaker/init.lua',
    'client/circuitBreaker/globals.lua',
    'client/circuitBreaker/helper.lua',
    'client/circuitBreaker/class.lua',
    'client/circuitBreaker/cursor.lua',
    'client/circuitBreaker/generic.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js',
    'html/js/app.js',
    'html/js/keymash.js',
    'html/js/rhythm.js',
    'html/js/varHack.js',
    'html/js/lockpick.js',
    'html/js/wirecut.js',
    'html/js/safehack.js',
    'html/js/memorygame.js',
    'html/js/skillbar.js',
    'html/img/*.png',
    'html/sounds/*.ogg',
    'html/sounds/*.mp3'
}

exports {
    -- Minigame exports
    'StartFirewallPulse',
    'StartBackdoorSequence',
    'StartCircuitRhythm',
    'StartSurgeOverride',
    'StartVarHack',
    'StartBruteForce',
    'StartDataCrack',
    'StartDrilling',
    'StartPlasmaDrilling',
    'StartCircuitBreaker',
    'Lockpick',
    'WireCut',
    'SafeHack',
    'MemoryGame',
    'SkillBar',
    
    -- Skills integration exports
    'GetHackingModifier',
    'GetLockpickModifier',
    'GetDrillingModifier',
    'GetElectronicsModifier'
}

dependencies {
    'qb-core',
    'ox_lib',
    'kingz-skills'
}
