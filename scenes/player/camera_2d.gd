## camera_lookahead.gd
extends Camera2D
#
#@export var lookahead_distance: float = 60.0 
#@export var smooth_speed: float = 3.0 
#@export var switch_delay: float = 0.3 # NEW: Wait 0.3 seconds before panning
#
#var target_offset_x: float = 0.0
#var current_direction: float = 1.0 # Keeps track of which way we are officially looking
#var time_facing_direction: float = 0.0 # Our built-in stopwatch
#
#@onready var player: Player = owner
#
#func _process(delta: float) -> void:
	#var direction = player.direction
	#if player.is_on_wall():
		#direction *= -1
		#print("foo")
		#
	## 1. Did the player press a button?
	#if direction != 0:
		#var input_direction = sign(direction)
		#
		## 2. Did they change direction?
		#if input_direction != current_direction:
			## They turned around! Reset the stopwatch, but DO NOT move the camera yet.
			#current_direction = input_direction
			#time_facing_direction = 0.0
		#else:
			## They are holding the same direction. Keep counting up.
			#time_facing_direction += delta
			#
	## 3. THE COMMITMENT CHECK
	## Only change the target offset if they held the button past our delay threshold
	#if time_facing_direction >= switch_delay:
		#target_offset_x = lookahead_distance * current_direction
		#
	## 4. Smoothly glide the camera (same as before!)
	#offset.x = lerp(offset.x, target_offset_x, smooth_speed * delta)
