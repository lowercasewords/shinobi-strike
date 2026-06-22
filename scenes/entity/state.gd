## Each State acts as a simple, self-contained "Brain" for the state_owner (such as player).
class_name State extends Node2D

signal transitioned

## The default continuous walking speed 
const DEFAULT_SPEED = 200.0
## The default jump strength (upwards)
const DEFAULT_JUMP_THURST = -300.0

const DEFAULT_AIRBONE_ACCELERATION = DEFAULT_GROUNDED_ACCELERATION*3
const DEFAULT_AIRBONE_FRICTION = DEFAULT_GROUNDED_FRICTION/3

const DEFAULT_GROUNDED_ACCELERATION: float = 200.0
const DEFAULT_GROUNDED_FRICTION: float = 840.0
const WALL_CLING_SPEED_THRESHOLD: float = 100.0

const TURN_SPEED_THRESHOLD: float = 5

## Defines where the state is in the space
enum STATE_SPACE {
	UNKNOWN,
	GROUNDED,
	AIRBORNE,
	WALLCRAWL,
	CEILINGCRAWL
}
@onready var state_owner: Ninja = owner

## The name of the current state
var sname: String
## The name for the current animations
var max_speed: float = 0.0
var friction: float = 0.0
var acceleration: float = 0.0

## Called upon by the state machine on _ready
func enter(): 
	if not state_owner.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		state_owner.animated_sprite.animation_finished.connect(_on_animation_finished)
	
	if get_state_space() == STATE_SPACE.GROUNDED:
		set_physics_grounded()
	elif get_state_space() == STATE_SPACE.AIRBORNE:
		set_physics_airborne()
		
## Called upon by the state machine on _exit_tree
func exit():
	if state_owner.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		state_owner.animated_sprite.animation_finished.disconnect(_on_animation_finished)

## Called upon by the state machine on _update
func update(_delta: float): pass
## Called upon by the state machine on _physics_update
func physics_update(_delta: float) -> void:
	state_owner.animated_sprite.speed_scale = 1
	
func switch_state(state_name: String):
	state_owner.state_machine.transition_state(self, state_name)

## Defines the space this state is supposed to occupy
func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.UNKNOWN
	
func windup_finsh() -> void: pass
func _on_animation_finished(): 
	if state_owner != null and state_owner.animated_sprite != null and state_owner.animated_sprite.animation != null:
		on_owner_animation_finished(state_owner.animated_sprite.animation)
func on_owner_animation_finished(animation_name: String) -> void:
	## Modified version for `_on_animation_finished`, supplying the animation name of the state owner automatically
	pass

func set_physics_grounded() -> void:
	friction = DEFAULT_GROUNDED_FRICTION
	acceleration = DEFAULT_AIRBONE_ACCELERATION
	max_speed = DEFAULT_SPEED
	
func set_physics_airborne() -> void:
	friction = DEFAULT_AIRBONE_FRICTION
	acceleration = DEFAULT_AIRBONE_ACCELERATION
	max_speed = DEFAULT_SPEED

func apply_gravity(_delta) -> float:
	var gravity_applied = 0
	if not state_owner.is_on_floor():
		gravity_applied = state_owner.gravity * _delta
		state_owner.velocity.y += gravity_applied
	return gravity_applied

func mario_jump_update(_delta: float, mario_jump_timer: Timer, MARIO_JUMP_STRENGTH: float) -> void:
	# Stop mario jump because owner stopped holding jump button 
	if not state_owner.ninja_controller.get_input_pressing_jump() and mario_jump_timer.time_left > 0:
		mario_jump_timer.stop()
		mario_jump_timer.timeout.emit()
		
	# Mario jump is applied
	if not mario_jump_timer.is_stopped():
		if not state_owner.is_on_floor():
			state_owner.velocity.y += MARIO_JUMP_STRENGTH

# Flips the sprite horizontally based on the owner's get_input_direction_h()
# Returns: Whether the flip was made
func direction_flip_horiz() -> bool:
	var previous_flip: bool = state_owner.animated_sprite.flip_h
	# Flip the sprite if get_input_direction_h() is negative (left)
	if state_owner.ninja_controller.get_input_direction_h() != 0:
		state_owner.animated_sprite.flip_h = state_owner.ninja_controller.get_input_direction_h() != 1
	return previous_flip != state_owner.animated_sprite.flip_h
	
func horizontal_movement(delta: float) -> float:
	var input_x: float = state_owner.ninja_controller.get_input_direction_h()
	# Determine target velocity
	var target_velocity = input_x * max_speed
	## Use friction when not pressing on the movement button but accelerating otherwise
	var extra_force = friction if input_x == 0 else acceleration
	var applied_force: float = 0.0
	
	applied_force = move_toward(state_owner.velocity.x, target_velocity, extra_force * delta)
	
	state_owner.velocity.x = applied_force
	
	direction_flip_horiz()
	
	return applied_force
	
func check_wall_exit(wall_direction: float) -> String:
	var input_direction_h: float = state_owner.ninja_controller.get_input_direction_h()
	if state_owner.just_grounded:
		return StateMachine.LAND
	elif wall_direction == 0:
		return StateMachine.FALL
	return ""

func sidewalls_collision_direction() -> float:
	# Force the cast to update immediately (prevents 1-frame lag bugs)
	state_owner.wall_cast.force_shapecast_update()
	
	var wall_direction: float = 0
	# Are we hitting a valid wall?
	if state_owner.wall_cast.is_colliding():
		# Grab the normal from the very first thing the cast hit (index 0)
		var wall_normal = state_owner.wall_cast.get_collision_normal(0)
		wall_direction = -sign(wall_normal.x)
		
	#print("p: ", state_owner.ninja_controller.get_input_direction_h())
	#print("w: ", wall_direction)
	return wall_direction

# -------- 
# -------- State Trigger Checks
# -------- 
func land_state_triggered() -> bool:
	return state_owner.just_grounded and sname != StateMachine.LAND

func fall_state_triggered() -> bool:
	return state_owner.velocity.y > 0 and sname != StateMachine.FALL

func combo_A_triggered() -> bool:
	var left_attacks_buffered: bool = state_owner.attack_input_buffer.size() > 0
	var light_attack_is_next: bool  = left_attacks_buffered and state_owner.attack_input_buffer[0] == AttackState.ATTACK_TYPE.LIGHT
	
	return light_attack_is_next
	
func wallrun_state_triggered() -> bool: 
	return state_owner.just_entered_wallbg and state_owner.ninja_controller.get_input_pressed_jump()

func idle_state_triggered() -> bool:
	return state_owner.ninja_controller.get_input_direction_h() == 0 and sname != StateMachine.IDLE

func jump_state_triggered() -> bool:
	## Is jump state triggered this tic?
	var is_jumping: bool = state_owner.ninja_controller.get_input_pressing_jump() and sname != StateMachine.JUMP
	return is_jumping

func walk_state_triggered() -> bool:
	return state_owner.ninja_controller.get_input_direction_h() != 0 and sname != StateMachine.WALK
	
func turn_state_triggered() -> bool:
	## Is turn state triggered this tic?
	var has_switched_movement_direction : bool = state_owner.just_changed_directions
	var fast_enough: bool = abs(state_owner.velocity.x) > TURN_SPEED_THRESHOLD 
	var not_turning_already: bool = sname != StateMachine.TURN
	
	return has_switched_movement_direction and fast_enough and not_turning_already

func wall_cling_v_state_triggered() -> bool:
	var input_direction_h = state_owner.ninja_controller.get_input_direction_h()
	return not get_state_space() == STATE_SPACE.WALLCRAWL and sidewalls_collision_direction() == input_direction_h and input_direction_h != 0
