class_name Player extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine

var direction: float = 0
var just_changed_directions: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_landed: bool = false
var just_landed: bool = false

func _ready():
	is_landed = is_on_floor()
	just_landed = false
	
func _physics_process(delta):
	# Get input direction (-1, 0, 1) and handle movement/deceleration
	var last_direction = direction
	direction = Input.get_axis("ui_left", "ui_right")
	if last_direction != direction and direction != 0:
		just_changed_directions = true
	else:
		just_changed_directions = false
	
	just_landed = false
	if not is_landed and is_on_floor():
		just_landed = true
		is_landed = true
	elif is_landed and not is_on_floor():
		is_landed = false
	
	# Flip the sprite left or right
	if direction < 0:
		animated_sprite.flip_h = true
	elif direction > 0:
		animated_sprite.flip_h = false
			
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Calculate state physics

	state_machine.current_state.physics_update(delta)
	
	move_and_slide()
