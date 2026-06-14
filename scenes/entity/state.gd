class_name State extends Node2D

@onready var player: NinjaPlayer = owner 

# Base state class for entities that need complex states

const ACCELERATION: float = 300.0
const FRICTION: float = 740.0
const WALL_CLING_SPEED_THRESHOLD: float = 100.0
var friction: float = FRICTION
var acceleration: float = ACCELERATION
	
signal transitioned(new_state_name: String)
func enter(): 
	if not player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.connect(_on_animation_finished)
func exit():
	if player.animated_sprite.animation_finished.is_connected(_on_animation_finished):
		player.animated_sprite.animation_finished.disconnect(_on_animation_finished)
func update(_delta: float): pass
func physics_update(_delta: float) -> void:
	player.animated_sprite.speed_scale = 1
func windup_finsh() -> void: pass
func _on_animation_finished(): pass

func check_grounded() -> bool:
	return player.is_on_floor() or not player.coyote_timer.is_stopped()
	
func fall_state_triggered() -> bool:
	return not check_grounded() and player.state_machine.current_state.name.to_lower() != StateMachine.FALL

func sidewalls_collision_direction() -> float:
	# Force the cast to update immediately (prevents 1-frame lag bugs)
	player.wall_cast.force_shapecast_update()
	
	var wall_direction: float = 0
	# Are we hitting a valid wall?
	if player.wall_cast.is_colliding():
		# Grab the normal from the very first thing the cast hit (index 0)
		var wall_normal = player.wall_cast.get_collision_normal(0)
		wall_direction = -sign(wall_normal.x)
		
	#print("p: ", player.input_direction)
	#print("w: ", wall_direction)
	return wall_direction
	
func wall_cling_v_state_triggerd() -> bool:
	return not player.state_machine.current_state is WallState and sidewalls_collision_direction() == player.input_direction and player.input_direction != 0

func apply_gravity(_delta) -> float:
	var gravity_applied = 0
	if not player.is_on_floor():
		gravity_applied = player.gravity * _delta
		player.velocity.y += gravity_applied
	return gravity_applied

func mario_jump_update(_delta: float, mario_jump_timer: Timer, MARIO_JUMP_STRENGTH: float) -> void:
		# Stop mario jump because player stopped holding jump button 
	if not player.is_jumping and mario_jump_timer.time_left > 0:
		mario_jump_timer.stop()
		mario_jump_timer.timeout.emit()
		
	# Mario jump is applied
	if not mario_jump_timer.is_stopped():
		if not player.is_on_floor():
			player.velocity.y += MARIO_JUMP_STRENGTH

# Flips the sprite horizontally based on the player's input_direction
# Returns: Whether the flip was made
func direction_flip_horiz() -> bool:
	var previous_flip: bool = player.animated_sprite.flip_h
	# Flip the sprite if input_direction is negative (left)
	if player.input_direction != 0:
		player.animated_sprite.flip_h = player.input_direction != 1
	return previous_flip != player.animated_sprite.flip_h
	
func basic_movement(delta: float, max_speed: float):
	# Determine target velocity
	var target_velocity = player.input_direction * max_speed
	# NinjaPlayer wants to move
	if player.input_direction != 0:
		player.velocity.x = move_toward(player.velocity.x, target_velocity, acceleration * delta)
	else:
		# Apply friction (slow down)
		player.velocity.x = move_toward(player.velocity.x, 0, friction * delta)
	
