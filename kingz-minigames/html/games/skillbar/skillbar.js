// Kingz Minigames
// Copyright (C) 2024 Kingz

let skillBarActive = false;
let skillBarTimer = null;
let skillBarDifficulty = 10;
let skillBarCount = 3;
let currentSkill = 0;
let skillBarPosition = 0;
let skillBarDirection = 1;
let skillBarSpeed = 2;
let skillBarTargetPosition = 0;
let skillBarTargetSize = 0;
let skillType = 'electronics';

function startSkillBar(config) {
    if (skillBarActive) return;
    
    skillBarActive = true;
    skillBarDifficulty = config.difficulty || 10;
    skillBarCount = config.skillCount || 3;
    skillType = config.skillType || 'electronics';
    currentSkill = 0;
    
    // Create skill bar UI
    const container = document.createElement('div');
    container.id = 'skillbar-container';
    container.className = 'game-container';
    
    const title = document.createElement('h2');
    title.textContent = 'Skill Check';
    container.appendChild(title);
    
    const skillBarOuter = document.createElement('div');
    skillBarOuter.className = 'skillbar-outer';
    
    const skillBarInner = document.createElement('div');
    skillBarInner.className = 'skillbar-inner';
    
    const skillBarMarker = document.createElement('div');
    skillBarMarker.className = 'skillbar-marker';
    
    const skillBarTarget = document.createElement('div');
    skillBarTarget.className = 'skillbar-target';
    
    skillBarOuter.appendChild(skillBarInner);
    skillBarOuter.appendChild(skillBarTarget);
    skillBarOuter.appendChild(skillBarMarker);
    
    container.appendChild(skillBarOuter);
    
    const info = document.createElement('div');
    info.id = 'skillbar-info';
    info.textContent = 'Press SPACE when the marker is in the target zone';
    container.appendChild(info);
    
    const progress = document.createElement('div');
    progress.id = 'skillbar-progress';
    progress.textContent = `Progress: ${currentSkill}/${skillBarCount}`;
    container.appendChild(progress);
    
    document.body.appendChild(container);
    
    // Set up first skill check
    setupSkillCheck();
    
    // Add event listener for space key
    document.addEventListener('keydown', handleSkillBarKeydown);
}

function setupSkillCheck() {
    // Reset position
    skillBarPosition = 0;
    skillBarDirection = 1;
    
    // Set random target position and size based on difficulty
    skillBarTargetSize = Math.max(5, 30 - skillBarDifficulty * 2);
    skillBarTargetPosition = Math.random() * (100 - skillBarTargetSize);
    
    // Set speed based on difficulty
    skillBarSpeed = 1 + skillBarDifficulty * 0.2;
    
    // Update UI
    const target = document.querySelector('.skillbar-target');
    target.style.width = `${skillBarTargetSize}%`;
    target.style.left = `${skillBarTargetPosition}%`;
    
    const marker = document.querySelector('.skillbar-marker');
    marker.style.left = '0%';
    
    // Start animation
    if (skillBarTimer) {
        clearInterval(skillBarTimer);
    }
    
    skillBarTimer = setInterval(updateSkillBar, 16);
}

function updateSkillBar() {
    skillBarPosition += skillBarDirection * skillBarSpeed;
    
    // Bounce off edges
    if (skillBarPosition >= 100) {
        skillBarPosition = 100;
        skillBarDirection = -1;
    } else if (skillBarPosition <= 0) {
        skillBarPosition = 0;
        skillBarDirection = 1;
    }
    
    // Update marker position
    const marker = document.querySelector('.skillbar-marker');
    marker.style.left = `${skillBarPosition}%`;
}

function handleSkillBarKeydown(event) {
    if (!skillBarActive) return;
    
    if (event.code === 'Space') {
        checkSkillBarResult();
    }
}

function checkSkillBarResult() {
    // Check if marker is in target zone
    const success = skillBarPosition >= skillBarTargetPosition && 
                   skillBarPosition <= (skillBarTargetPosition + skillBarTargetSize);
    
    if (success) {
        // Success
        document.querySelector('.skillbar-marker').classList.add('success');
        playSound('click');
        
        currentSkill++;
        document.getElementById('skillbar-progress').textContent = `Progress: ${currentSkill}/${skillBarCount}`;
        
        if (currentSkill >= skillBarCount) {
            // All skills complete
            document.getElementById('skillbar-info').textContent = 'Success!';
            playSound('success');
            
            setTimeout(() => {
                endSkillBar(true);
            }, 1000);
        } else {
            // Next skill check
            setTimeout(() => {
                document.querySelector('.skillbar-marker').classList.remove('success');
                setupSkillCheck();
            }, 1000);
        }
    } else {
        // Failure
        document.querySelector('.skillbar-marker').classList.add('failure');
        document.getElementById('skillbar-info').textContent = 'Failed!';
        playSound('failure');
        
        setTimeout(() => {
            endSkillBar(false);
        }, 1000);
    }
    
    clearInterval(skillBarTimer);
}

function endSkillBar(success) {
    skillBarActive = false;
    
    // Remove event listener
    document.removeEventListener('keydown', handleSkillBarKeydown);
    
    // Remove skill bar UI
    const container = document.getElementById('skillbar-container');
    if (container) {
        document.body.removeChild(container);
    }
    
    // Send result to client
    fetch('https://kingz-minigames/skillBarResult', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            success: success,
            skillType: skillType
        })
    });
}

// Register NUI callback
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'startSkillBar') {
        startSkillBar(data);
    }
});
