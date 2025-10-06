// Main script for handling minigames

// Global variables
let currentGame = null;
let gameOptions = {};
let gameTimer = null;
let timerInterval = null;

// Listen for messages from the game client
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'open') {
        openMinigame(data.game, data.options);
    }
});

// Function to open a minigame
function openMinigame(game, options) {
    currentGame = game;
    gameOptions = options || {};
    
    // Hide all minigame containers
    document.querySelectorAll('.minigame-container').forEach(container => {
        container.style.display = 'none';
    });
    
    // Show the selected minigame container
    const container = document.getElementById(`${game}-container`);
    if (container) {
        container.style.display = 'block';
    }
    
    // Start the timer
    startTimer(gameOptions.time || 30000);
    
    // Initialize the specific minigame
    switch (game) {
        case 'lockpick':
            initLockpick(gameOptions);
            break;
        case 'wirecut':
            initWireCut(gameOptions);
            break;
        case 'safehack':
            initSafeHack(gameOptions);
            break;
        case 'memorygame':
            initMemoryGame(gameOptions);
            break;
        case 'skillbar':
            initSkillBar(gameOptions);
            break;
    }
}

// Function to close a minigame
function closeMinigame(success) {
    // Clear timer
    clearTimeout(gameTimer);
    clearInterval(timerInterval);
    
    // Send result back to game client
    fetch('https://kingz-minigames/close', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            success: success
        })
    });
    
    // Reset variables
    currentGame = null;
    gameOptions = {};
}

// Function to start the timer
function startTimer(duration) {
    const timerBar = document.querySelector('.timer-progress');
    const startTime = Date.now();
    const endTime = startTime + duration;
    
    // Clear any existing timer
    clearTimeout(gameTimer);
    clearInterval(timerInterval);
    
    // Set up the timer
    timerBar.style.width = '100%';
    
    timerInterval = setInterval(() => {
        const now = Date.now();
        const remaining = endTime - now;
        const percentage = (remaining / duration) * 100;
        
        if (percentage <= 0) {
            clearInterval(timerInterval);
            timerBar.style.width = '0%';
        } else {
            timerBar.style.width = `${percentage}%`;
        }
    }, 10);
    
    // Set timeout for game end
    gameTimer = setTimeout(() => {
        // Time's up, fail the minigame
        closeMinigame(false);
    }, duration);
}

// Function to play a sound
function playSound(sound) {
    fetch('https://kingz-minigames/playSound', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            sound: sound
        })
    });
}

// Function to force close the minigame (emergency)
function forceClose() {
    fetch('https://kingz-minigames/forceClose', {
        method: 'POST'
    });
}

// Keyboard event listener for ESC key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        forceClose();
    }
});
