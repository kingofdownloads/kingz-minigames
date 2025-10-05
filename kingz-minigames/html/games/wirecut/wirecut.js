// Kingz Minigames
// Copyright (C) 2024 Kingz

let wireCutActive = false;
let wireCutTimer = null;
let wireCutTimeLeft = 0;
let correctWire = 0;
let totalWires = 6;

function startWireCut(config) {
    if (wireCutActive) return;
    
    wireCutActive = true;
    correctWire = config.correct || Math.floor(Math.random() * config.wires) + 1;
    totalWires = config.wires || 6;
    wireCutTimeLeft = config.time || 10;
    
    // Create wire cut UI
    const container = document.createElement('div');
    container.id = 'wirecut-container';
    container.className = 'game-container';
    
    const title = document.createElement('h2');
    title.textContent = 'Cut the correct wire';
    container.appendChild(title);
    
    const wiresContainer = document.createElement('div');
    wiresContainer.className = 'wires-container';
    
    for (let i = 1; i <= totalWires; i++) {
        const wire = document.createElement('div');
        wire.className = 'wire';
        wire.dataset.wireId = i;
        wire.style.backgroundColor = getRandomColor();
        
        wire.addEventListener('click', function() {
            cutWire(parseInt(this.dataset.wireId));
        });
        
        wiresContainer.appendChild(wire);
    }
    
    container.appendChild(wiresContainer);
    
    const timer = document.createElement('div');
    timer.id = 'wirecut-timer';
    timer.textContent = `Time: ${wireCutTimeLeft}s`;
    container.appendChild(timer);
    
    document.body.appendChild(container);
    
    // Start timer
    wireCutTimer = setInterval(() => {
        wireCutTimeLeft--;
        document.getElementById('wirecut-timer').textContent = `Time: ${wireCutTimeLeft}s`;
        
        if (wireCutTimeLeft <= 0) {
            clearInterval(wireCutTimer);
            endWireCut(false);
        }
    }, 1000);
}

function cutWire(wireId) {
    if (!wireCutActive) return;
    
    clearInterval(wireCutTimer);
    
    const success = wireId === correctWire;
    const wire = document.querySelector(`.wire[data-wire-id="${wireId}"]`);
    
    if (success) {
        wire.style.backgroundColor = '#2ecc71';
        playSound('success');
    } else {
        wire.style.backgroundColor = '#e74c3c';
        playSound('failure');
    }
    
    setTimeout(() => {
        endWireCut(success);
    }, 1000);
}

function endWireCut(success) {
    wireCutActive = false;
    
    // Remove wire cut UI
    const container = document.getElementById('wirecut-container');
    if (container) {
        document.body.removeChild(container);
    }
    
    // Send result to client
    fetch('https://kingz-minigames/wireCutResult', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            success: success
        })
    });
}

function getRandomColor() {
    const colors = ['#e74c3c', '#3498db', '#2ecc71', '#f1c40f', '#9b59b6', '#e67e22'];
    return colors[Math.floor(Math.random() * colors.length)];
}

// Register NUI callback
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'startWireCut') {
        startWireCut(data);
    }
});
