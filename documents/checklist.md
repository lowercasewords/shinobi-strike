# Checklist & Scope

## Scope

- Enemies loose a limb after 1 or 3 hits 
- A finisher animation can be perform on an enemy without a limb, killing them in a process

## Checklist

### Player
[X] Idle
[] Walk
	[X] Acceleration/Deceleration
		[X] During turning
	[] Animation speed (fps) affected by speed
[] Run
[] Jump
	[] Coyote Time: Allows a small window of time (e.g., 2-5 frames) for a player to jump after leaving a ledge, making movement feel forgiving.
	[] Jump Buffering: If a player presses jump right before landing, the game registers this input and jumps immediately upon touching the ground.
	[] Variable Jump Height: Jump height corresponds to how long the button is pressed, allowing for both precise platforming and high jumps.
	[] Fast Deceleration/Stopping: While acceleration can feel smooth, rapid deceleration prevents a "slippery" feeling, making movement feel tighter.
	[X] Air Control: Allowing players to change direction or momentum while in the air to prevent feeling locked into a jump trajectory.
	[] Corner Correction: Automatically pushing the player slightly if their head grazes a corner, preventing frustration from barely missing a jump. 
[X] Land
[] Fall
[] Wall-jump
[] Wall-run

### Enemies
### Maps
### Sound & Music
### Menu & UI
