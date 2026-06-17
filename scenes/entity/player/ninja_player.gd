class_name NinjaPlayer extends Ninja

const SPEED = 200.0
const JUMP_VELOCITY_INITIAL_THURST = -300.0
const MAX_ATTACK_INPUT_BUFFER_SIZE: int = 10

signal area2d_enter(area2d: Area2D)
signal area2d_exit(area2d: Area2D)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var camera: Camera2D = $Camera2D
@onready var wall_cast: ShapeCast2D = $ShapeCast2D
@onready var coyote_timer: Timer = $CoyoteTimer

# input_direction overrides requested by external sources (such as the states) 
var forward_direction: float = 1
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

var is_pressed_light_attack: bool = false
var is_pressed_heavy_attack: bool = false

# Push/Pop Queue for Combo Inputs
var attack_input_buffer: Array
	
func _ready():
	super._ready()
	#area2d_enter.connect(_on_wall_entered)
	#area2d_exit.connect(_on_wall_exited)
	is_landed = is_on_floor()
	state_machine.start_state_machine()
	
func _physics_process(delta):
	# Get input input_direction (-1, 0, 1) and handle movement/deceleration
	var last_direction = input_direction
	var last_jumping: bool = is_jumping

	input_direction = Input.get_axis("ui_left", "ui_right")
	if input_direction != 0:
		forward_direction = input_direction
	direction_v = Input.get_axis("ui_down", "ui_up")
	
	is_jumping = Input.is_action_pressed("ui_accept")
	
	is_pressed_light_attack = false
	is_pressed_heavy_attack = false
	# Enforce buffer size limit
	if attack_input_buffer.size() > MAX_ATTACK_INPUT_BUFFER_SIZE:
		attack_input_buffer.resize(MAX_ATTACK_INPUT_BUFFER_SIZE)
	# Buffer a light attack
	if Input.is_action_just_pressed("light_attack"):
		attack_input_buffer.push_front(ComboState.ATTACK_TYPE.LIGHT)
		is_pressed_light_attack = true
	# Buffer a heavy attack
	if Input.is_action_just_pressed("heavy_attack"):
		attack_input_buffer.push_front(ComboState.ATTACK_TYPE.HEAVY)
		is_pressed_heavy_attack = true
	
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
	if velocity.normalized().x * forward_direction < 0:
		just_changed_directions = !changing_direction
		changing_direction = true
	# If wanting to go the same way to the current's velocity
	else:
		changing_direction = false
		just_changed_directions = false
		
	move_and_slide()
	
func _on_hitbox_body_entered(body: Node2D): 
	if body is Ninja:
		var ninja: Ninja = (body as Ninja)
		ninja.take_damage(0)

func _on_sensor_body_entered(area):
	just_entered_wallbg = true

func _on_sensor_body_exited(body):
	just_entered_wallbg = false
