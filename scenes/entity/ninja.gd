## Entity Class that encapsulates all logic for an in-game entity, players and bots alike.
## Handles the most basic logic, while subroutines like StateMachine and Controllers do the heavy lifting.
class_name Ninja 
extends CharacterBody2D

## Maximum number of buffered attack inputs at the time as a safeguard
const MAX_ATTACK_INPUT_BUFFER_SIZE: int = 10
const STRIKE_DISTANCE_H: float = 200

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
@export var animated_sprite: AnimatedSprite2D
@export var camera: PlayerCamera
@export var wall_cast: ShapeCast2D
@export var coyote_timer: Timer
@export var wall_sensor: Area2D

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
	
	update_attack_buffer()
	
	state_machine.process(delta)
	
	
# Calculate state physics
func _physics_process(delta):
	state_machine.physics_process(delta)
	
	# Update the effects on the owner by the environment
	update_environment()
	
	apply_gravity(delta)
	
	# Apply movement
	move_and_slide()

func apply_gravity(_delta) -> float:
	var gravity_applied = 0
	if not is_on_floor():
		gravity_applied = gravity * _delta
		velocity.y += gravity_applied
	return gravity_applied
	
## Returns True if the sprite is flipped
func set_forward_direction_h(direction: int = 0) -> bool:
	var previous_flip: int = forward_direction_h
	var normalized_direction: int = previous_flip if direction == 0 else direction
	
	if previous_flip != normalized_direction:
		animated_sprite.flip_h = normalized_direction != 1
	return animated_sprite.flip_h

## Checks if the animation name exists for this entity
func has_animation(animation: String) -> bool:
	return animated_sprite.sprite_frames.has_animation(animation)

func detecting_incoming_damage(_attacker: Ninja, _attack_node: ComboNode): pass

## Returns the varied animation, the variety depends on the dismemberment state of the enemy
func get_animation_varied(animation: String, enemy_ninja: NinjaEnemy) -> String:
	var animation_no_arms_variant: String = animation + VARIED_ANIMATION_ENDINGS.NO_ARMS
	var animation_no_legs_variant: String = animation + VARIED_ANIMATION_ENDINGS.NO_LEGS
	var animation_no_head_variant: String = animation + VARIED_ANIMATION_ENDINGS.NO_HEAD
	
	var animation_to_play: String = animation
	# The body of the enemy to judge the dismemberment state
	var body: Dictionary[String, bool] = enemy_ninja.body
	
	# Just missing the Arms
	if not body.has_arms and (body.has_legs and body.has_head) and has_animation(animation_no_arms_variant):
		animation_to_play = animation_no_arms_variant
	# Just missing the Legs
	elif not body.has_legs and (body.has_arms and body.has_head) and has_animation(animation_no_legs_variant):
		animation_to_play = animation_no_legs_variant
	# Just missing the Head
	elif not body.has_head and (body.has_arms and body.has_legs) and has_animation(animation_no_head_variant):
		pass
	
	return animation_to_play

func play_animation(animation: String):
	animated_sprite.play(animation)
	
func apply_thrust(applied_force: Vector2) -> void:
	velocity = applied_force
	
func apply_death() -> void: pass

# --- Get Functions ---
func get_attack_area_collision_layer() -> int: return attack_area_collision_layer
func get_attack_area_collision_mask() -> int: return attack_area_collision_mask
# ---------------------

## Check if the player is considered to be on the ground
func check_grounded() -> bool: return self.is_on_floor() or (coyote_timer != null and not coyote_timer.is_stopped())

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
	var _last_forward_direction_h: float = forward_direction_h
	var _last_input_pressing_jump: bool  = ninja_controller.get_input_pressing_jump()
	var _input_pressing_jump: bool       = ninja_controller.get_input_pressing_jump()
	var input_direction_h: float        = ninja_controller.get_input_direction_h()
	var _input_direction_v: float        = ninja_controller.get_input_direction_v()
	
	if input_direction_h != 0.0:
		forward_direction_h = int(input_direction_h)
	
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
			(ninja.state_machine.current_state as HurtState).detecting_incoming_damage(self, applied_attack_info)

func _on_animation_finished(): 
	if state_machine != null and state_machine.current_state != null and animated_sprite != null and animated_sprite.animation != null:
		state_machine.current_state.on_owner_animation_finished(animated_sprite.animation)
	
func _on_frame_changed():
	if state_machine != null and state_machine.current_state != null and animated_sprite != null and animated_sprite.animation != null:
		state_machine.current_state.on_owner_frame_changed()
	
func _on_sensor_body_entered(_area):
	just_entered_wallbg = true

func _on_sensor_body_exited(_body):
	just_entered_wallbg = false
