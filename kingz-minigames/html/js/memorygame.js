// Kingz Minigames
// Copyright (C) 2024 Kingz

let memoryGameActive = false;
let memoryGameTimer = null;
let memoryGameTimeLeft = 0;
let memoryGridSize = 5;
let memoryNumItems = 6;
let memoryItems = [];
let memorySelected = [];
let memoryCorrect = [];

function startMemoryGame(config) {
    if (memoryGameActive) return;
    
    memoryGameActive = true;
    memoryGridSize = config.gridSize || 5;
    memoryGameTimeLeft = config.time || 10;
    memoryNumItems = config.items || 6;
    memoryItems = [];
    memorySelected = [];
    memoryCorrect = [];
    
    // Create memory game UI
    const container = document.createElement('div');
    container.id = 'memorygame-container';
    container.className = 'game-container';
    
    const title = document.createElement('h2');
    title.textContent = 'Memory Game';
    container.appendChild(title);
    
    const gridContainer = document.createElement('div');
    gridContainer.className = 'memory-grid';
    gridContainer.style.gridTemplateColumns = `repeat(${memoryGridSize}, 1fr)`;
    
    // Generate grid
    for (let i = 0; i < memoryGridSize * memoryGridSize; i++) {
        const cell = document.createElement('div');
        cell.className = 'memory-cell';
        cell.dataset.cellId = i;
        
        cell.addEventListener('click', function() {
            if (!memoryGameActive || memoryItems.length > 0) return;
            cellClick(parseInt(this.dataset.cellId));
        });
        
        gridContainer.appendChild(cell);
    }
    
    container.appendChild(gridContainer);
    
    const info = document.createElement('div');
    info.id = 'memorygame-info';
    info.textContent = 'Memorize the pattern';
    container.appendChild(info);
    
    const timer = document.createElement('div');
    timer.id = 'memorygame-timer';
    timer.textContent = `Time: ${memoryGameTimeLeft}s`;
    container.appendChild(timer);
    
    document.body.appendChild(container);
    
    // Generate random items
    const totalCells = memoryGridSize * memoryGridSize;
    while (memoryItems.length < memoryNumItems) {
        const randomCell = Math.floor(Math.random() * totalCells);
        if (!memoryItems.includes(randomCell)) {
            memoryItems.push(randomCell);
        }
    }
    
    // Show items
    showItems();
    
    // Start timer
    memoryGameTimer = setInterval(() => {
        memoryGameTimeLeft--;
        document.getElementById('memorygame-timer').textContent = `Time: ${memoryGameTimeLeft}s`;
        
        if (memoryGameTimeLeft <= 0) {
            clearInterval(memoryGameTimer);
            endMemoryGame(false);
        }
    }, 1000);
}

function showItems() {
    for (let i = 0; i < memoryItems.length; i++) {
        const cellId = memoryItems[i];
        const cell = document.querySelector(`.memory-cell[data-cell-id="${cellId}"]`);
        cell.classList.add('active');
    }
    
    // Hide items after delay
    setTimeout(() => {
        for (let i = 0; i < memoryItems.length; i++) {
            const cellId = memoryItems[i];
            const cell = document.querySelector(`.memory-cell[data-cell-id="${cellId}"]`);
            cell.classList.remove('active');
        }
        
        document.getElementById('memorygame-info').textContent = 'Select the highlighted cells';
        memoryItems = [...memoryItems]; // Copy array
    }, memoryGameTimeLeft * 500); // Show for half the time
}

function cellClick(cellId) {
    if (!memoryGameActive || memoryItems.length === 0) return;
    
    const cell = document.querySelector(`.memory-cell[data-cell-id="${cellId}"]`);
    
    // Check if already selected
    if (memorySelected.includes(cellId)) {
        return;
    }
    
    memorySelected.push(cellId);
    
    // Check if correct
    if (memoryItems.includes(cellId)) {
        cell.classList.add('correct');
        memoryCorrect.push(cellId);
        playSound('click');
        
        // Check if all correct items found
        if (memoryCorrect.length === memoryItems.length) {
            document.getElementById('memorygame-info').textContent = 'All items found!';
            playSound('success');
            
            setTimeout(() => {
                endMemoryGame(true);
            }, 1000);
        }
    } else {
        cell.classList.add('incorrect');
        playSound('failure');
        
        setTimeout(() => {
            endMemoryGame(false);
        }, 1000);
    }
}

function endMemoryGame(success) {
    memoryGameActive = false;
    clearInterval(memoryGameTimer);
    
    // Remove memory game UI
    const container = document.getElementById('memorygame-container');
    if (container) {
        document.body.removeChild(container);
    }
    
    // Send result to client
    fetch('https://kingz-minigames/memoryGameResult', {
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
    
    if (data.action === 'startMemoryGame') {
        startMemoryGame(data);
    }
});
