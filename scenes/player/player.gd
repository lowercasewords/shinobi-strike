class_name Player extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY_INITIAL_THURST = -300.0

signal area2d_enter(area2d: Area2D)
signal area2d_exit(area2d: Area2D)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var camera: Camera2D = $Camera2D
@onready var wall_cast: ShapeCast2D = $ShapeCast2D
@onready var coyote_timer: Timer = $CoyoteTimer

# input_direction overrides requested by external sources (such as the states) 
var actual_direction: float = 0
var input_direction: float = 0
var direction_v: float = 0
var just_changed_directions: bool = false
var changing_direction: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_landed: bool = false
var just_landed: bool = false
var just_entered_wallbg: bool = false
var is_jumping: bool = false
var just_jumped: bool = false
var was_on_ground: bool = false

func _ready():
	#area2d_enter.connect(_on_wall_entered)
	#area2d_exit.connect(_on_wall_exited)
	is_landed = is_on_floor()
	state_machine.start_state_machine()
	
func _physics_process(delta):
	# Get input input_direction (-1, 0, 1) and handle movement/deceleration
	var last_direction = input_direction
	var last_jumping: bool = is_jumping

	input_direction = Input.get_axis("ui_left", "ui_right")
	actual_direction = input_direction
	direction_v = Input.get_axis("ui_down", "ui_up")
	
	is_jumping = Input.is_action_pressed("ui_accept")
	
	if not last_jumping and is_jumping:
		just_jumped = true
	else:
		just_jumped = false
	
	if is_on_floor():
		was_on_ground = true
		coyote_timer.stop()
	elif not is_on_floor() and was_on_ground:
		was_on_ground = false
		coyote_timer.start()
	
	just_landed = false
	if not is_landed and is_on_floor():
		just_landed = true
		is_landed = true
	elif is_landed and not is_on_floor():
		is_landed = false
	
	# Calculate state physics
	state_machine.physics_process(delta)
	
	# If wanting to go opposite to the current's velocity
	if velocity.normalized().x * actual_direction < 0 or actual_direction != input_direction:
		just_changed_directions = !changing_direction
		changing_direction = true
	# If wanting to go the same way to the current's velocity
	else:
		changing_direction = false
		just_changed_directions = false
		
	move_and_slide()

func _on_sensor_body_entered(area):
	just_entered_wallbg = true

func _on_sensor_body_exited(body):
	just_entered_wallbg = false
