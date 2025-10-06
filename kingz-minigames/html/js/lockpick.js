// Lockpick minigame

let lockpickPins = [];
let currentPin = 0;
let lockpickRotation = 0;
let lockpickDirection = 1;
let lockpickSpeed = 1;
let lockpickSweetSpotSize = 10;
let lockpickAttempts = 0;
let lockpickMaxAttempts = 3;
let lockpickSuccess = false;

// Initialize the lockpick minigame
function initLockpick(options) {
    // Reset variables
    lockpickPins = [];
    currentPin = 0;
    lockpickRotation = 0;
    lockpickDirection = 1;
    lockpickAttempts = 0;
    lockpickSuccess = false;
    
    // Set options
    lockpickSpeed = options.difficulty === 'easy' ? 0.5 : (options.difficulty === 'hard' ? 1.5 : 1);
    lockpickSweetSpotSize = options.difficulty === 'easy' ? 15 : (options.difficulty === 'hard' ? 5 : 10);
    lockpickMaxAttempts = options.maxAttempts || 3;
    
    // Create pins
    const pinsContainer = document.querySelector('.lockpick-pins');
    pinsContainer.innerHTML = '';
    
    const numPins = options.pins || 5;
    
    for (let i = 0; i < numPins; i++) {
        const pin = document.createElement('div');
        pin.className = 'lockpick-pin';
        
        // Create sweet spot
        const sweetSpot = document.createElement('div');
        sweetSpot.className = 'lockpick-pin-sweet-spot';
        
        // Random position for sweet spot
        const sweetSpotPosition = Math.floor(Math.random() * (100 - lockpickSweetSpotSize));
        sweetSpot.style.top = `${sweetSpotPosition}%`;
        sweetSpot.style.height = `${lockpickSweetSpotSize}%`;
        
        pin.appendChild(sweetSpot);
        pinsContainer.appendChild(pin);
        
        lockpickPins.push({
            element: pin,
            sweetSpot: sweetSpot,
            position: sweetSpotPosition,
            size: lockpickSweetSpotSize,
            solved: false
        });
    }
    
    // Start the lockpick animation
    requestAnimationFrame(updateLockpick);
    
    // Add click event listener
    document.addEventListener('mousedown', tryLockpick);
}

// Update the lockpick animation
function updateLockpick() {
    if (currentGame !== 'lockpick') return;
    
    // Update rotation
    lockpickRotation += lockpickSpeed * lockpickDirection;
    
    // Reverse direction at limits
    if (lockpickRotation >= 90 || lockpickRotation <= -90) {
        lockpickDirection *= -1;
    }
    
    // Update tool position
    const tool = document.querySelector('.lockpick-tool');
    tool.style.transform = `rotate(${lockpickRotation}deg)`;
    
    // Continue animation
    requestAnimationFrame(updateLockpick);
}

// Try to pick the current pin
function tryLockpick() {
    if (currentGame !== 'lockpick') return;
    
    // Calculate current position percentage
    const normalizedRotation = (lockpickRotation + 90) / 180 * 100;
    
    // Check if within sweet spot
    const pin = lockpickPins[currentPin];
    const sweetSpotStart = pin.position;
    const sweetSpotEnd = pin.position + pin.size;
    
    if (normalizedRotation >= sweetSpotStart && normalizedRotation <= sweetSpotEnd) {
        // Success!
        playSound('success');
        pin.element.style.backgroundColor = '#2ecc71';
        pin.solved = true;
        
        // Move to next pin
        currentPin++;
        
        // Check if all pins are solved
        if (currentPin >= lockpickPins.length) {
            // All pins solved, success!
            lockpickSuccess = true;
            setTimeout(() => {
                closeMinigame(true);
            }, 500);
        }
    } else {
        // Failed
        playSound('fail');
        lockpickAttempts++;
        
        // Check if max attempts reached
        if (lockpickAttempts >= lockpickMaxAttempts) {
            // Too many attempts, fail
            setTimeout(() => {
                closeMinigame(false);
            }, 500);
        }
    }
    
    // Remove event listener to prevent spam
    document.removeEventListener('mousedown', tryLockpick);
    
    // Add it back after a short delay
    setTimeout(() => {
        if (currentGame === 'lockpick' && !lockpickSuccess && lockpickAttempts < lockpickMaxAttempts) {
            document.addEventListener('mousedown', tryLockpick);
        }
    }, 500);
}
