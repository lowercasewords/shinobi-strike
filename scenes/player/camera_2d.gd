extends Camera2D

# Expose these so you can easily tweak them in the Inspector
@export var min_zoom: float = 0.2  # How far out they can see
@export var max_zoom: float = 1.0  # How close in they can look
@export var zoom_step: float = 0.2 # How much one key press zooms
@export var zoom_speed: float = 10.0 # How fast the camera glides to the new zoom

# We store what the zoom *should* be, so lerp can smoothly chase it
var target_zoom: float = 1.0

func _ready() -> void:
	# Initialize target_zoom to whatever the camera starts at
	target_zoom = zoom.x

func _process(delta: float) -> void:
	handle_zoom_input()
	
	# Smoothly glide the actual camera zoom toward our target
	var current_zoom = lerp(zoom.x, target_zoom, zoom_speed * delta)
	zoom = Vector2(current_zoom, current_zoom)

func handle_zoom_input() -> void:
	# Note: On a standard keyboard, the '+' key is technically the '=' key 
	# unless you hold shift. We check for KEY_EQUAL to catch the unshifted press!
	
	if Input.is_action_just_pressed("zoom_in"):
		# Zoom In
		target_zoom += zoom_step
	elif Input.is_action_just_pressed("zoom_out"):
		# Zoom Out
		target_zoom -= zoom_step

	# CRITICAL: Clamp the zoom so it never exceeds your min/max limits
	target_zoom = clamp(target_zoom, min_zoom, max_zoom)

## camera_lookahead.gd
#extends Camera2D
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
	#var input_direction = player.input_direction
	#if player.is_on_wall():
		#input_direction *= -1
		#print("foo")
		#
	## 1. Did the player press a button?
	#if input_direction != 0:
		#var input_direction = sign(input_direction)
		#
		## 2. Did they change input_direction?
		#if input_direction != current_direction:
			## They turned around! Reset the stopwatch, but DO NOT move the camera yet.
			#current_direction = input_direction
			#time_facing_direction = 0.0
		#else:
			## They are holding the same input_direction. Keep counting up.
			#time_facing_direction += delta
			#
	## 3. THE COMMITMENT CHECK
	## Only change the target offset if they held the button past our delay threshold
	#if time_facing_direction >= switch_delay:
		#target_offset_x = lookahead_distance * current_direction
		#
	## 4. Smoothly glide the camera (same as before!)
	#offset.x = lerp(offset.x, target_offset_x, smooth_speed * delta)
