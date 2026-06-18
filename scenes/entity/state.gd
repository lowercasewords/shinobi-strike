class_name State extends Node2D

@onready var state_entity_owner: Ninja = owner 

# Base state class for entities that need complex states

const ACCELERATION: float = 300.0
const FRICTION: float = 740.0
const WALL_CLING_SPEED_THRESHOLD: float = 100.0
var friction: float = FRICTION
var acceleration: float = ACCELERATION
	
signal transitioned(new_state_name: String)
func enter(): 
	if not state_entity_owner.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		state_entity_owner.animated_sprite.animation_finished.connect(_on_animation_finished)
func exit():
	if state_entity_owner.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		state_entity_owner.animated_sprite.animation_finished.disconnect(_on_animation_finished)
func update(_delta: float): pass
func physics_update(_delta: float) -> void:
	state_entity_owner.animated_sprite.speed_scale = 1
func windup_finsh() -> void: pass
func _on_animation_finished(): pass

func check_grounded() -> bool:
	return state_entity_owner.is_on_floor() or (state_entity_owner.coyote_timer != null and not state_entity_owner.coyote_timer.is_stopped())
	
func fall_state_triggered() -> bool:
	return not check_grounded() and state_entity_owner.state_machine.current_state.name.to_lower() != StateMachine.FALL

func sidewalls_collision_direction() -> float:
	# Force the cast to update immediately (prevents 1-frame lag bugs)
	state_entity_owner.wall_cast.force_shapecast_update()
	
	var wall_direction: float = 0
	# Are we hitting a valid wall?
	if state_entity_owner.wall_cast.is_colliding():
		# Grab the normal from the very first thing the cast hit (index 0)
		var wall_normal = state_entity_owner.wall_cast.get_collision_normal(0)
		wall_direction = -sign(wall_normal.x)
		
	#print("p: ", state_entity_owner.ninja_controller.get_input_direction_h())
	#print("w: ", wall_direction)
	return wall_direction
	
func wall_cling_v_state_triggerd() -> bool:
	var input_direction_h = state_entity_owner.ninja_controller.get_input_direction_h()
	return not state_entity_owner.state_machine.current_state is WallState and sidewalls_collision_direction() == input_direction_h and input_direction_h != 0

func apply_gravity(_delta) -> float:
	var gravity_applied = 0
	if not state_entity_owner.is_on_floor():
		gravity_applied = state_entity_owner.gravity * _delta
		state_entity_owner.velocity.y += gravity_applied
	return gravity_applied

func mario_jump_update(_delta: float, mario_jump_timer: Timer, MARIO_JUMP_STRENGTH: float) -> void:
		# Stop mario jump because state_entity_owner stopped holding jump button 
	if not state_entity_owner.ninja_controller.get_input_pressing_jump() and mario_jump_timer.time_left > 0:
		mario_jump_timer.stop()
		mario_jump_timer.timeout.emit()
		
	# Mario jump is applied
	if not mario_jump_timer.is_stopped():
		if not state_entity_owner.is_on_floor():
			state_entity_owner.velocity.y += MARIO_JUMP_STRENGTH

# Flips the sprite horizontally based on the state_entity_owner's get_input_direction_h()
# Returns: Whether the flip was made
func direction_flip_horiz() -> bool:
	var previous_flip: bool = state_entity_owner.animated_sprite.flip_h
	# Flip the sprite if get_input_direction_h() is negative (left)
	if state_entity_owner.ninja_controller.get_input_direction_h() != 0:
		state_entity_owner.animated_sprite.flip_h = state_entity_owner.ninja_controller.get_input_direction_h() != 1
	return previous_flip != state_entity_owner.animated_sprite.flip_h
	
func basic_movement(delta: float, max_speed: float):
	# Determine target velocity
	var target_velocity = state_entity_owner.ninja_controller.get_input_direction_h() * max_speed
	# NinjaPlayer wants to move
	if state_entity_owner.ninja_controller.get_input_direction_h() != 0:
		state_entity_owner.velocity.x = move_toward(state_entity_owner.velocity.x, target_velocity, acceleration * delta)
	else:
		# Apply friction (slow down)
		state_entity_owner.velocity.x = move_toward(state_entity_owner.velocity.x, 0, friction * delta)
	
