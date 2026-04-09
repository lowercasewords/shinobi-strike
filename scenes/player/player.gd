class_name Player extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine

var direction: float = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Get input direction (-1, 0, 1) and handle movement/deceleration
	direction = Input.get_axis("ui_left", "ui_right")
	
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
