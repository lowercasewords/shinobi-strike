## Each State acts as a simple, self-contained "Brain" for the ninja_owner (such as player).
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
@onready var ninja_owner: Ninja = owner

## The name of the current state
var sname: String
## The name for the current animations
var max_speed: float = 0.0
var friction: float = 0.0
var acceleration: float = 0.0

## Called upon by the state machine on _ready
func enter(): 
	if get_state_space() == STATE_SPACE.GROUNDED:
		set_physics_grounded()
	elif get_state_space() == STATE_SPACE.AIRBORNE:
		set_physics_airborne()
		
## Called upon by the state machine on _exit_tree
func exit():
	pass

## Called upon by the state machine on _update
func update(_delta: float): pass
## Called upon by the state machine on _physics_update
func physics_update(_delta: float) -> void:
	ninja_owner.animation_player.speed_scale = 1
	
func switch_state(state_name: String):
	ninja_owner.state_machine.transition_state(self, state_name)

## Defines the space this state is supposed to occupy
func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.UNKNOWN
	
func windup_finsh() -> void: pass
func on_owner_animation_finished(animation_name: String) -> void:
	## Modified version for `_on_animation_finished`, supplying the animation name of the state owner automatically
	pass
func on_owner_frame_changed(): pass
	
func play_animation(animation: String):
	ninja_owner.play_animation(animation)

func set_physics_grounded() -> void:
	friction = DEFAULT_GROUNDED_FRICTION
	acceleration = DEFAULT_AIRBONE_ACCELERATION
	max_speed = DEFAULT_SPEED
	
func set_physics_airborne() -> void:
	friction = DEFAULT_AIRBONE_FRICTION
	acceleration = DEFAULT_AIRBONE_ACCELERATION
	max_speed = DEFAULT_SPEED

func apply_gravity(_delta) -> void:
	pass ## This should be removed

## Similar to the `allow_movement`, but only applies friction without player movement and acceleration
func apply_friction(delta: float) -> float:
	var applied_force = move_toward(ninja_owner.velocity.x, 0, friction * delta)
	ninja_owner.velocity.x = applied_force
	
	return applied_force

func mario_jump_update(_delta: float, mario_jump_timer: Timer, MARIO_JUMP_STRENGTH: float) -> void:
	# Stop mario jump because owner stopped holding jump button 
	if not ninja_owner.ninja_controller.get_input_pressing_jump() and mario_jump_timer.time_left > 0:
		mario_jump_timer.stop()
		mario_jump_timer.timeout.emit()
		
	# Mario jump is applied
	if not mario_jump_timer.is_stopped():
		if not ninja_owner.is_on_floor():
			ninja_owner.velocity.y += MARIO_JUMP_STRENGTH

# Flips the sprite horizontally based on the owner's get_input_direction_h()
# Returns: Whether the flip was made
func direction_flip_horiz() -> bool:
	var previous_flip: float = ninja_owner.scale.x
	# Flip the sprite if get_input_direction_h() is negative (left)
	if ninja_owner.ninja_controller.get_input_direction_h() != 0:
		ninja_owner.scale.x = ninja_owner.ninja_controller.get_input_direction_h()
	return previous_flip != ninja_owner.scale.x
	
func allow_movement(delta: float) -> float:
	var input_x: float = ninja_owner.ninja_controller.get_input_direction_h()
	# Determine target velocity
	var target_velocity = input_x * max_speed
	## Use friction when not pressing on the movement button but accelerating otherwise
	var extra_force = friction if input_x == 0 else acceleration
	var applied_force: float = 0.0
	
	applied_force = move_toward(ninja_owner.velocity.x, target_velocity, extra_force * delta)
	
	ninja_owner.velocity.x = applied_force
	
	direction_flip_horiz()
	
	return applied_force

func check_wall_exit(wall_direction: float) -> String:
	var input_direction_h: float = ninja_owner.ninja_controller.get_input_direction_h()
	if ninja_owner.just_grounded:
		return StateMachine.LAND
	elif wall_direction == 0:
		return StateMachine.FALL
	return ""

func sidewalls_collision_direction() -> float:
	# Force the cast to update immediately (prevents 1-frame lag bugs)
	ninja_owner.wall_cast.force_shapecast_update()
	
	var wall_direction: float = 0
	# Are we hitting a valid wall?
	if ninja_owner.wall_cast.is_colliding():
		# Grab the normal from the very first thing the cast hit (index 0)
		var wall_normal = ninja_owner.wall_cast.get_collision_normal(0)
		wall_direction = -sign(wall_normal.x)
		
	#print("p: ", ninja_owner.ninja_controller.get_input_direction_h())
	#print("w: ", wall_direction)
	return wall_direction

# -------- 
# -------- State Trigger Checks
# -------- 

func land_state_triggered() -> bool:
	return ninja_owner.just_grounded and sname != StateMachine.LAND

func fall_state_triggered() -> bool:
	return ninja_owner.velocity.y > 0 and sname != StateMachine.FALL

func attack_triggered() -> bool:
	var input_buffer = ninja_owner.ninja_controller.attack_input_buffer
	var left_attacks_buffered: bool = input_buffer.size() > 0
	var valid_attack_is_next: bool  = left_attacks_buffered and input_buffer[0] != AttackState.ATTACK_TYPE.UNKNOWN
	
	return valid_attack_is_next
	
func wallrun_state_triggered() -> bool: 
	return ninja_owner.just_entered_wallbg and ninja_owner.ninja_controller.get_input_pressed_jump()

func idle_state_triggered() -> bool:
	return ninja_owner.ninja_controller.get_input_direction_h() == 0 and sname != StateMachine.IDLE

func jump_state_triggered() -> bool:
	## Is jump state triggered this tic?
	var is_jumping: bool = ninja_owner.ninja_controller.get_input_pressing_jump() and sname != StateMachine.JUMP
	return is_jumping

func walk_state_triggered() -> bool:
	return ninja_owner.ninja_controller.get_input_direction_h() != 0 and sname != StateMachine.WALK
	
func turn_state_triggered() -> bool:
	## Is turn state triggered this tic?
	var has_switched_movement_direction : bool = ninja_owner.just_changed_directions
	var fast_enough: bool = abs(ninja_owner.velocity.x) > TURN_SPEED_THRESHOLD 
	var not_turning_already: bool = sname != StateMachine.TURN
	
	return has_switched_movement_direction and fast_enough and not_turning_already

func wall_cling_v_state_triggered() -> bool:
	var input_direction_h = ninja_owner.ninja_controller.get_input_direction_h()
	return not get_state_space() == STATE_SPACE.WALLCRAWL and sidewalls_collision_direction() == input_direction_h and input_direction_h != 0
