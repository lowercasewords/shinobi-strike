class_name Player extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY_INITIAL_THURST = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var camera: Camera2D = $Camera2D
@onready var wall_cast: ShapeCast2D = $ShapeCast2D

var direction: float = 0
var just_changed_directions: bool = false
var changing_direction: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_landed: bool = false
var just_landed: bool = false
var is_jumping: bool = false

func _ready():
	is_landed = is_on_floor()
	just_landed = false
	
func _physics_process(delta):
	# Get input direction (-1, 0, 1) and handle movement/deceleration
	var last_direction = direction
	direction = Input.get_axis("ui_left", "ui_right")
	is_jumping = Input.is_action_pressed("ui_accept")
	
	# If wanting to go opposite to the current's velocity
	if velocity.normalized().x * direction < 0:
		just_changed_directions = !changing_direction
		changing_direction = true
	# If wanting to go the same way to the current's velocity
	else:
		changing_direction = false
		just_changed_directions = false
	
	just_landed = false
	if not is_landed and is_on_floor():
		just_landed = true
		is_landed = true
	elif is_landed and not is_on_floor():
		is_landed = false
	
	# Calculate state physics
	state_machine.physics_process(delta)
	print(velocity.y)
	move_and_slide()
