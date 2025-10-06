// Kingz Minigames
// Copyright (C) 2024 Kingz

let safeHackActive = false;
let safeHackTimer = null;
let safeHackTimeLeft = 0;
let safeHackLevels = 3;
let currentLevel = 0;
let safeHackPattern = [];
let playerPattern = [];

function startSafeHack(config) {
    if (safeHackActive) return;
    
    safeHackActive = true;
    safeHackLevels = config.levels || 3;
    safeHackTimeLeft = config.time || 30;
    currentLevel = 0;
    
    // Create safe hack UI
    const container = document.createElement('div');
    container.id = 'safehack-container';
    container.className = 'game-container';
    
    const title = document.createElement('h2');
    title.textContent = 'Hack the Safe';
    container.appendChild(title);
    
    const gridContainer = document.createElement('div');
    gridContainer.className = 'grid-container';
    
    for (let i = 0; i < 9; i++) {
        const cell = document.createElement('div');
        cell.className = 'grid-cell';
        cell.dataset.cellId = i;
        
        cell.addEventListener('click', function() {
            if (!safeHackActive || currentLevel === 0) return;
            cellClick(parseInt(this.dataset.cellId));
        });
        
        gridContainer.appendChild(cell);
    }
    
    container.appendChild(gridContainer);
    
    const info = document.createElement('div');
    info.id = 'safehack-info';
    info.textContent = 'Memorize the pattern';
    container.appendChild(info);
    
    const timer = document.createElement('div');
    timer.id = 'safehack-timer';
    timer.textContent = `Time: ${safeHackTimeLeft}s`;
    container.appendChild(timer);
    
    const progress = document.createElement('div');
    progress.id = 'safehack-progress';
    progress.textContent = `Level: 0/${safeHackLevels}`;
    container.appendChild(progress);
    
    document.body.appendChild(container);
    
    // Start timer
    safeHackTimer = setInterval(() => {
        safeHackTimeLeft--;
        document.getElementById('safehack-timer').textContent = `Time: ${safeHackTimeLeft}s`;
        
        if (safeHackTimeLeft <= 0) {
            clearInterval(safeHackTimer);
            endSafeHack(false);
        }
    }, 1000);
    
    // Start first level
    setTimeout(() => {
        nextLevel();
    }, 1000);
}

function nextLevel() {
    currentLevel++;
    document.getElementById('safehack-progress').textContent = `Level: ${currentLevel}/${safeHackLevels}`;
    
    // Generate pattern
    safeHackPattern = [];
    for (let i = 0; i < currentLevel + 2; i++) {
        safeHackPattern.push(Math.floor(Math.random() * 9));
    }
    
    // Show pattern
    document.getElementById('safehack-info').textContent = 'Memorize the pattern';
    showPattern(0);
}

function showPattern(index) {
    if (index >= safeHackPattern.length) {
        // Pattern complete, player's turn
        playerPattern = [];
        document.getElementById('safehack-info').textContent = 'Repeat the pattern';
        return;
    }
    
    const cellId = safeHackPattern[index];
    const cell = document.querySelector(`.grid-cell[data-cell-id="${cellId}"]`);
    
    cell.classList.add('active');
    playSound('buttonPress');
    
    setTimeout(() => {
        cell.classList.remove('active');
        
        setTimeout(() => {
            showPattern(index + 1);
        }, 200);
    }, 800);
}

function cellClick(cellId) {
    if (!safeHackActive || currentLevel === 0) return;
    
    const cell = document.querySelector(`.grid-cell[data-cell-id="${cellId}"]`);
    cell.classList.add('active');
    playSound('buttonPress');
    
    setTimeout(() => {
        cell.classList.remove('active');
    }, 300);
    
    playerPattern.push(cellId);
    
    // Check if pattern is correct so far
    if (playerPattern[playerPattern.length - 1] !== safeHackPattern[playerPattern.length - 1]) {
        // Wrong pattern
        document.getElementById('safehack-info').textContent = 'Wrong pattern!';
        playSound('failure');
        
        setTimeout(() => {
            endSafeHack(false);
        }, 1000);
        return;
    }
    
    // Check if pattern is complete
    if (playerPattern.length === safeHackPattern.length) {
        // Pattern complete
        document.getElementById('safehack-info').textContent = 'Correct pattern!';
        playSound('success');
        
        if (currentLevel >= safeHackLevels) {
            // All levels complete
            setTimeout(() => {
                endSafeHack(true);
            }, 1000);
        } else {
            // Next level
            setTimeout(() => {
                nextLevel();
            }, 1000);
        }
    }
}

function endSafeHack(success) {
    safeHackActive = false;
    clearInterval(safeHackTimer);
    
    // Remove safe hack UI
    const container = document.getElementById('safehack-container');
    if (container) {
        document.body.removeChild(container);
    }
    
    // Send result to client
    fetch('https://kingz-minigames/safeHackResult', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            success: success
        })
    });
}

// Register NUI callback
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'startSafeHack') {
        startSafeHack(data);
    }
});
