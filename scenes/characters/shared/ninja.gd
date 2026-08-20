## Entity Class that encapsulates all logic for an in-game entity, players and bots alike.
## Handles the most basic logic, while subroutines like StateMachine and Controllers do the heavy lifting.
class_name Ninja 
extends CharacterBody2D

## Maximum number of buffered attack inputs at the time as a safeguard
const MAX_ATTACK_INPUT_BUFFER_SIZE: int = 10
const STRIKE_DISTANCE_H: float = 200

## When the player is landing on the ground, this dust is spawned on the ground for visual feedback
const DUST_EFFECT_SCENE: PackedScene = preload("res://scenes/systems/effects/dust_effect.tscn")

## Many animations can be different depending on how "intact" the enemy's body is,
## For example, if enemy is fully intact it will play "idle" animation, but if missing 
## arms the enemy will play "idle_na" animation instead.
## This is primarely used for all enemy animations, but also used for player for 
## eradication technique because play animation delivers different finishers depending
## on how "intact" enemy is
const VARIED_ANIMATION_ENDINGS: Dictionary[String, String] = {
	"NO_ARMS": "_na",
	"NO_LEGS": "_nl",
	"NO_HEAD": "_nh",
	"NO_ARMS_HEAD": "_nah",
	"NO_LEGS_HEAD": "_nlh",
	"NO_ARMS_LEGS": "_nal"
}

## Initializes the states as scene tree nodes and allows those states to communicate with each other
## in order to support complex state switching behavior via inheritance and polymorphism
@export var state_machine: StateMachine
## Dictates the inputs to this entity, like Player Keyboard/Controller or Bot Inputs
@export var ninja_controller: NinjaController
## The 2D Area where the attack will be registered
@export var attack_area: Area2D
## The animated sprite of this entity
@export var animation_player: AnimationPlayer
@export var camera: PlayerCamera
@export var wall_cast: ShapeCast2D
@export var coyote_timer: Timer
@export var flippable: Node2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

## The original collision mask of the AttackArea2D as set in the Scene Editor
var attack_area_collision_mask: int = 0
## The original collision layer of the AttackArea2D as set in the Scene Editor
var attack_area_collision_layer: int = 0 

## Where the entity currently looking at?
var forward_direction_h: int = 1

## Is this entity on the floor continuously (not just landed on the floor)
var is_grounded: bool = false
## Has this entity just landed on the floor
var just_grounded: bool = false
## Has this entity entered an area where the backround wall became interactable? For example, to perform wall running move
var just_entered_wallbg: bool = false
var just_changed_directions: bool = false
var changing_direction: bool = false

### ----------------------------
### ----------------------------
### ----------------------------
###
### Apply functions
###
### ----------------------------
### ----------------------------
### ----------------------------


func apply_gravity(_delta) -> float:
	var gravity_applied = 0
	if not is_on_floor():
		gravity_applied = gravity * _delta
		velocity.y += gravity_applied
	return gravity_applied

## Overrides the velocity all the same, but x-axis portion of the velocity is affected by the forward direction 
func apply_velocity_forward(applied_velocity: Vector2):
	applied_velocity.x *= forward_direction_h
	apply_velocity(applied_velocity)

## Overrides the velocity
func apply_velocity(applied_velocity: Vector2) -> void:
	velocity = applied_velocity
	
func apply_death() -> void: pass

func apply_attack_area() -> void:
	
	var attack_info: ComboNode = get_current_attack_node()
	
	if attack_info != null:
		## Grab everything inside the area instantly
		var overlapping_bodies: Array[Node2D] = attack_area.get_overlapping_bodies()
		
		## Hit each enemy exactly once
		for body in overlapping_bodies:
			# Pass this object to your hit logic
			if body is Ninja:
				on_attack_registered(body, attack_info) 

func apply_incoming_damage(_attacker: Ninja, _attack_node: ComboNode): pass

### ----------------------------
### ----------------------------
### ----------------------------
###
### Get & Set functions
###
### ----------------------------
### ----------------------------
### ----------------------------

## Get the reference to the current state node
func get_state_current() -> State: return state_machine.state_current 

## Get the reference to the previous state node
func get_state_previous() -> State: return state_machine.state_previous

## Returns the current attack node information for combos
func get_current_attack_node() -> ComboNode:
	var attack_state: AttackState = state_machine.state_current as AttackState
	var applied_attack_info: ComboNode = null
	if attack_state != null:
		applied_attack_info = attack_state.current_attack_node as ComboNode
	return applied_attack_info

## Returns the varied animation, the variety depends on the dismemberment state of the enemy
func get_animation_varied(animation: String, enemy_ninja: NinjaEnemy) -> String:
	var animation_no_arms_variant: String = animation + VARIED_ANIMATION_ENDINGS.NO_ARMS
	var animation_no_legs_variant: String = animation + VARIED_ANIMATION_ENDINGS.NO_LEGS
	var animation_no_head_variant: String = animation + VARIED_ANIMATION_ENDINGS.NO_HEAD
	
	var animation_to_play: String = animation
	# The body of the enemy to judge the dismemberment state
	var body: Dictionary[String, bool] = enemy_ninja.body
	
	# Just missing the Arms
	if not body.has_arms and (body.has_legs and body.has_head) and animation_player.has_animation(animation_no_arms_variant):
		animation_to_play = animation_no_arms_variant
	# Just missing the Legs
	elif not body.has_legs and (body.has_arms and body.has_head) and animation_player.has_animation(animation_no_legs_variant):
		animation_to_play = animation_no_legs_variant
	# Just missing the Head
	elif not body.has_head and (body.has_arms and body.has_legs) and animation_player.has_animation(animation_no_head_variant):
		pass
	
	return animation_to_play

## Returns True if the sprite is flipped
func set_forward_direction_h(new_direction: int = 0) -> bool:
	var previous_forward_direction_h: int = -1 if forward_direction_h < 0 else 1
	var new_normalized_direction: int = -1 if new_direction < 0 else 1 #previous_forward_direction_h if new_direction == 0 else new_direction
	
	forward_direction_h = new_normalized_direction
	
	if flippable != null:
		flippable.scale.x = forward_direction_h
	
	return previous_forward_direction_h == new_normalized_direction

func set_animation(animation: String):
	animation_player.play(animation)

func get_attack_area_collision_layer() -> int: return attack_area_collision_layer
func get_attack_area_collision_mask() -> int: return attack_area_collision_mask

### ----------------------------
### ----------------------------
### ----------------------------
###
### Update functions
###
### ----------------------------
### ----------------------------
### ----------------------------


func update_speed_scale(_delta):
	var state_max_speed: float = abs(state_machine.state_current.get_max_speed())
	var current_speed: Vector2 = abs(velocity)
	var highest_speed_scale = 1 + max(current_speed.x / state_max_speed, current_speed.y / state_max_speed) / 2
	#print(current_speed)
	#print(highest_speed_scale)
	animation_player.speed_scale = highest_speed_scale
	
func update_environment() -> void:
	# Get input get_input_direction_h() [-1.0, 1.0] and handle movement/deceleration
	var _last_forward_direction_h: float = forward_direction_h
	var _last_input_pressing_jump: bool  = ninja_controller.get_input_pressing_jump()
	var _input_pressing_jump: bool       = ninja_controller.get_input_pressing_jump()
	var _input_direction_h: float        = ninja_controller.get_input_direction_h()
	var _input_direction_v: float        = ninja_controller.get_input_direction_v()
	
	#if input_direction_h != 0.0:
		#forward_direction_h = int(input_direction_h)
	
	just_grounded = false
	if not is_grounded and is_on_floor():
		
		var effect: DustEffect = (DUST_EFFECT_SCENE.instantiate() as DustEffect)
		effect.global_position = global_position
		add_sibling(effect)
		
		#effect.dust_player.play("spawn")
		
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

## Check if the player is considered to be on the ground
func get_ninja_grounded() -> bool: return self.is_on_floor() or (coyote_timer != null and not coyote_timer.is_stopped())


### ----------------------------
### ----------------------------
### ----------------------------
###
### Event Handlers
###
### ----------------------------
### ----------------------------
### ----------------------------


# Entering the scene tree
func _ready() -> void:
	# Attack Area initialization
	attack_area_collision_mask = attack_area.collision_mask
	attack_area_collision_layer = attack_area.collision_layer
	
	is_grounded = is_on_floor()
	connect_state_signals()
	
	# Activate state machine
	state_machine.start_state_machine()
	
	connect_all_signals()

# Exiting the scene tree
func _exit_tree() -> void:
	disconnect_all_signals()

# Receive current inputs for this entity
func _process(delta):
	ninja_controller.process(delta)
	
	update_attack_buffer()
	
	state_machine.process(delta)
# Calculate state physics
func _physics_process(delta):
	state_machine.physics_process(delta)
	
	update_speed_scale(delta)
	
	# Update the effects on the owner by the environment
	update_environment()
	
	# Apply movement
	move_and_slide()

## Connects all signals of this classs. 
## Typically used upon entering the scene tree.
func connect_all_signals() -> void:
	#connect_signal(wall_cast.body_entered, on_sensor_body_entered)
	#connect_signal(wall_cast.body_exited, on_sensor_body_exited)
	connect_signal(animation_player.animation_finished, on_animation_finished)
	#connect_signal(animation_player.frame_changed, _on_frame_changed)

func connect_state_signals() -> void:
	for state in state_machine.states.values():
		connect_signal(state.animation_requested, _on_state_animation_requested)
		connect_signal(state.animation_backwards_requested, _on_state_animation_backwards_requested)
		connect_signal(state.velocity_requested, _on_state_velocity_requested)
		connect_signal(state.velocity_delta_requested, _on_state_velocity_delta_requested)
		connect_signal(state.forward_direction_requested, _on_state_forward_direction_requested)
		connect_signal(state.gravity_requested, _on_state_gravity_requested)
		connect_signal(state.attack_area_requested, _on_state_attack_area_requested)
		if state is HurtState:
			connect_signal(state.damage_received, _on_state_damage_received)

func disconnect_all_signals() -> void:
	## Disconnects all signals of this classs. Typically used upon exiting the scene tree
	#disconnect_signal(wall_cast.body_entered, on_sensor_body_entered)
	#disconnect_signal(wall_cast.body_exited, on_sensor_body_exited)
	disconnect_signal(animation_player.animation_finished, on_animation_finished)
	#disconnect_signal(animation_player.frame_changed, _on_frame_changed)

func _on_state_animation_requested(animation_name: String) -> void:
	set_animation(animation_name)

func _on_state_animation_backwards_requested(animation_name: String) -> void:
	animation_player.play_backwards(animation_name)

func _on_state_velocity_requested(new_velocity: Vector2) -> void:
	velocity = new_velocity

func _on_state_velocity_delta_requested(delta_velocity: Vector2) -> void:
	velocity += delta_velocity

func _on_state_forward_direction_requested(direction: int) -> void:
	set_forward_direction_h(direction)

func _on_state_gravity_requested(delta: float) -> void:
	apply_gravity(delta)

func _on_state_attack_area_requested() -> void:
	apply_attack_area()

func _on_state_damage_received(attacker: Ninja, attack_node: ComboNode) -> void:
	apply_incoming_damage(attacker, attack_node)

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
	
func on_attack_registered(body: Node2D, applied_attack_info: ComboNode):
	if body is Ninja:
		var ninja: Ninja = (body as Ninja)
		if ninja.state_machine.state_current != HurtState:
			ninja.state_machine.state_current.switch_state(state_machine.HURT)
			(ninja.state_machine.state_current as HurtState).apply_incoming_damage(self, applied_attack_info)

func on_animation_finished(animation_name: String): 
	if state_machine != null and state_machine.state_current != null and animation_player != null:
		state_machine.state_current.on_owner_animation_finished(animation_name)
	
func on_sensor_body_entered(_area):
	just_entered_wallbg = true

func on_sensor_body_exited(_body):
	just_entered_wallbg = false
