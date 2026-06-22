## Entity Class that encapsulates all logic for an in-game entity, players and bots alike.
## Handles the most basic logic, while subroutines like StateMachine and Controllers do the heavy lifting.
class_name Ninja 
extends CharacterBody2D

## Maximum number of buffered attack inputs at the time as a safeguard
const MAX_ATTACK_INPUT_BUFFER_SIZE: int = 10

## Initializes the states as scene tree nodes and allows those states to communicate with each other
## in order to support complex state switching behavior via inheritance and polymorphism
@onready var state_machine: StateMachine = $StateMachine
## Dictates the inputs to this entity, like Player Keyboard/Controller or Bot Inputs
@onready var ninja_controller: NinjaController = $NinjaController
## The 2D Area where the attack will be registered
@onready var attack_area: Area2D = $AttackArea
## The animated sprite of this entity
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D
@onready var wall_cast: ShapeCast2D
@onready var coyote_timer: Timer
@onready var wall_sensor: Area2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

## The original collision mask of the AttackArea2D as set in the Scene Editor
var attack_area_collision_mask: int = 0
## The original collision layer of the AttackArea2D as set in the Scene Editor
var attack_area_collision_layer: int = 0 

## Where the entity currently looking at?
var forward_direction_h: float = 1.0

## Is this entity on the floor continuously (not just landed on the floor)
var is_grounded: bool = false
## Has this entity just landed on the floor
var just_grounded: bool = false
## Has this entity entered an area where the backround wall became interactable? For example, to perform wall running move
var just_entered_wallbg: bool = false
var just_changed_directions: bool = false
var changing_direction: bool = false

## Push/Pop Queue for Attack Inputs to pre-input combo strings
var attack_input_buffer: Array

# Entering the scene tree
func _ready() -> void:
	
	camera = $Camera2D
	wall_cast = $ShapeCast2D
	coyote_timer = $CoyoteTimer
	wall_sensor = $WallSensor
	
	# Attack Area initialization
	attack_area_collision_mask = attack_area.collision_mask
	attack_area_collision_layer = attack_area.collision_layer
	deactivate_attack_area()
	
	is_grounded = is_on_floor()
	
	# Activate state machine
	state_machine.start_state_machine()
	
	connect_all_signals()

# Exiting the scene tree
func _exit_tree() -> void:
	disconnect_all_signals()

# Receive current inputs for this entity
func _process(delta):
	ninja_controller.process(delta)
	state_machine.process(delta)
	
# Calculate state physics
func _physics_process(delta):
	state_machine.physics_process(delta)
	
	# Update the effects on the owner by the environment
	update_environment()
	
	update_attack_buffer()
	# Apply movement
	move_and_slide()

# --- Get Functions ---
func get_attack_area_collision_layer() -> int: return attack_area_collision_layer
func get_attack_area_collision_mask() -> int: return attack_area_collision_mask
# ---------------------

func check_grounded() -> bool:
	## Check if the player is considered to be on the ground
	return self.is_on_floor() or (coyote_timer != null and not coyote_timer.is_stopped())

## Connects all signals of this classs. 
## Typically used upon entering the scene tree.
func connect_all_signals() -> void:
	if not attack_area.body_entered.is_connected(_on_hitbox_body_entered):
		attack_area.body_entered.connect(_on_hitbox_body_entered)
	if not wall_sensor.body_entered.is_connected(_on_sensor_body_entered):
		wall_sensor.body_entered.connect(_on_sensor_body_entered)
	if not wall_sensor.body_exited.is_connected(_on_sensor_body_exited):
		wall_sensor.body_exited.connect(_on_sensor_body_exited)

func disconnect_all_signals() -> void:
	## Disconnects all signals of this classs. Typically used upon exiting the scene tree
	if attack_area.body_entered.is_connected(_on_hitbox_body_entered):
		attack_area.body_entered.disconnect(_on_hitbox_body_entered)
	if wall_sensor.body_entered.is_connected(_on_sensor_body_entered):
		wall_sensor.body_entered.disconnect(_on_sensor_body_entered)
	if wall_sensor.body_exited.is_connected(_on_sensor_body_exited):
		wall_sensor.body_exited.disconnect(_on_sensor_body_exited)
		
func update_environment() -> void:
	# Get input get_input_direction_h() [-1.0, 1.0] and handle movement/deceleration
	var last_forward_direction_h: float = forward_direction_h
	var last_input_pressing_jump: bool  = ninja_controller.get_input_pressing_jump()
	var input_pressing_jump: bool       = ninja_controller.get_input_pressing_jump()
	var input_direction_h: float        = ninja_controller.get_input_direction_h()
	var input_direction_v: float        = ninja_controller.get_input_direction_v()
	
	if input_direction_h != 0.0:
		forward_direction_h = input_direction_h
	
	just_grounded = false
	if not is_grounded and is_on_floor():
		just_grounded = true
		is_grounded = true
		if coyote_timer != null:
			coyote_timer.stop()
	elif is_grounded and not is_on_floor():
		is_grounded = false
		if coyote_timer != null:
			coyote_timer.start()
	
	# If wanting to go opposite to the current's velocity
	if velocity.normalized().x * forward_direction_h < 0:
		just_changed_directions = !changing_direction
		changing_direction = true
	# If wanting to go the same way to the current's velocity
	else:
		changing_direction = false
		just_changed_directions = false

func update_attack_buffer():
	# Enforce buffer size limit
	if attack_input_buffer.size() > MAX_ATTACK_INPUT_BUFFER_SIZE:
		attack_input_buffer.resize(MAX_ATTACK_INPUT_BUFFER_SIZE)
	# Buffer a light attack
	if ninja_controller.get_input_pressed_light_attack():
		attack_input_buffer.push_front(AttackState.ATTACK_TYPE.LIGHT)
	# Buffer a heavy attack
	if ninja_controller.get_input_pressed_heavy_attack():
		attack_input_buffer.push_front(AttackState.ATTACK_TYPE.HEAVY)

func activate_attack_area() -> void:
	## Makes the Attack Area interactable as this entity is attacking 
	attack_area.collision_mask = get_attack_area_collision_mask()
	attack_area_collision_layer = get_attack_area_collision_layer()

func deactivate_attack_area() -> void:
	## Makes the Attack Area non-interactable as this entity is not currently attacking 
	attack_area.collision_mask = 0
	attack_area_collision_layer = 0


func deal_damage(damage: int): pass

func take_damage(damage: int): pass

func _on_hitbox_body_entered(body: Node2D):
	if body is Ninja:
		var ninja: Ninja = (body as Ninja)
		ninja.take_damage(0)

func _on_sensor_body_entered(area):
	just_entered_wallbg = true

func _on_sensor_body_exited(body):
	just_entered_wallbg = false
