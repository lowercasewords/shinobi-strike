## Entity Class that encapsulates all logic for an in-game entity, players and bots alike.
## Handles the most basic logic, while subroutines like StateMachine and Controllers do the heavy lifting.
class_name Ninja 
extends CharacterBody2D

## Maximum number of buffered attack inputs at the time as a safeguard
const MAX_ATTACK_INPUT_BUFFER_SIZE: int = 10

## Initializes the states as scene tree nodes and allows those states to communicate with each other
## in order to support complex state switching behavior via inheritance and polymorphism
@export var state_machine: StateMachine
## Dictates the inputs to this entity, like Player Keyboard/Controller or Bot Inputs
@export var ninja_controller: NinjaController
## The 2D Area where the attack will be registered
@export var attack_area: Area2D
## The animated sprite of this entity
@export var animated_sprite: AnimatedSprite2D
@export var camera: Camera2D
@export var wall_cast: ShapeCast2D
@export var coyote_timer: Timer
@export var wall_sensor: Area2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

## The original collision mask of the AttackArea2D as set in the Scene Editor
var attack_area_collision_mask: int = 0
## The original collision layer of the AttackArea2D as set in the Scene Editor
var attack_area_collision_layer: int = 0 

## Where the entity currently looking at?
var forward_direction_h: int = 1.0

## Is this entity on the floor continuously (not just landed on the floor)
var is_grounded: bool = false
## Has this entity just landed on the floor
var just_grounded: bool = false
## Has this entity entered an area where the backround wall became interactable? For example, to perform wall running move
var just_entered_wallbg: bool = false
var just_changed_directions: bool = false
var changing_direction: bool = false

# Entering the scene tree
func _ready() -> void:
	# Attack Area initialization
	attack_area_collision_mask = attack_area.collision_mask
	attack_area_collision_layer = attack_area.collision_layer
	
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
	connect_signal(wall_sensor.body_entered, _on_sensor_body_entered)
	connect_signal(wall_sensor.body_exited, _on_sensor_body_exited)
	connect_signal(animated_sprite.animation_finished, _on_animation_finished)
	connect_signal(animated_sprite.frame_changed, _on_frame_changed)

func disconnect_all_signals() -> void:
	## Disconnects all signals of this classs. Typically used upon exiting the scene tree
	disconnect_signal(wall_sensor.body_entered, _on_sensor_body_entered)
	disconnect_signal(wall_sensor.body_exited, _on_sensor_body_exited)
	disconnect_signal(animated_sprite.animation_finished, _on_animation_finished)
	disconnect_signal(animated_sprite.frame_changed, _on_frame_changed)

## Returns if the signal needed to be connected
func connect_signal(signal_instance: Signal, callable: Callable) -> bool:
	var should_connect: bool = not signal_instance.is_connected(callable)
	if should_connect:
		signal_instance.connect(callable)
	return should_connect
	
## Returns if the signal needed to be disconnected
func disconnect_signal(signal_instance: Signal, callable: Callable) -> bool:
	var should_connect: bool = signal_instance.is_connected(callable)
	if should_connect:
		signal_instance.disconnect(callable)
	return should_connect
	
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
	var buffer: Array = ninja_controller.attack_input_buffer
	# Enforce buffer size limit
	if buffer.size() > MAX_ATTACK_INPUT_BUFFER_SIZE:
		buffer.resize(MAX_ATTACK_INPUT_BUFFER_SIZE)
	# Buffer a light attack
	if ninja_controller.get_input_pressed_light_attack():
		buffer.push_front(AttackState.ATTACK_TYPE.LIGHT)
	# Buffer a heavy attack
	if ninja_controller.get_input_pressed_heavy_attack():
		buffer.push_front(AttackState.ATTACK_TYPE.HEAVY)

func activate_attack_area(applied_attack_info: ComboNode) -> void:
	# 2. Grab everything inside the area instantly
	var overlapping_bodies: Array[Node2D] = attack_area.get_overlapping_bodies()
	
	# 3. Hit each enemy exactly once
	for body in overlapping_bodies:
		# Pass this object to your hit logic
		on_attack_registered(body, applied_attack_info) 

func on_attack_registered(body: Node2D, applied_attack_info: ComboNode):
	if body is Ninja:
		var ninja: Ninja = (body as Ninja)
		if ninja.state_machine.current_state != HurtState:
			ninja.state_machine.current_state.switch_state(state_machine.HURT)
			(ninja.state_machine.current_state as HurtState).get_hurt(applied_attack_info)

func _on_animation_finished(): 
	if state_machine != null and state_machine.current_state != null and animated_sprite != null and animated_sprite.animation != null:
		state_machine.current_state.on_owner_animation_finished(animated_sprite.animation)
	
func _on_frame_changed():
	if state_machine != null and state_machine.current_state != null and animated_sprite != null and animated_sprite.animation != null:
		state_machine.current_state.on_owner_frame_changed()
	
		
func _on_sensor_body_entered(area):
	just_entered_wallbg = true

func _on_sensor_body_exited(body):
	just_entered_wallbg = false
