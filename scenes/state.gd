class_name State extends Node2D

@onready var player: Player = owner 

# Base state class for entities that need complex states

const ACCELERATION: float = 300.0
const FRICTION: float = 740.0
const WALL_CLING_SPEED_THRESHOLD: float = 100.0
var friction: float = FRICTION
var acceleration: float = ACCELERATION
	
signal transitioned(new_state_name: String)
func enter(): pass
func exit(): pass
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
		
	#print("p: ", player.direction)
	#print("w: ", wall_direction)
	return wall_direction
	
func wall_cling_v_state_triggerd() -> bool:
	return not player.state_machine.current_state is WallState and sidewalls_collision_direction() == player.direction and player.direction != 0

func apply_gravity(_delta) -> float:
	var gravity_applied = 0
	if not player.is_on_floor():
		gravity_applied = player.gravity * _delta
		player.velocity.y += gravity_applied
	return gravity_applied

func _ready():
	if not player.is_node_ready():
		await player.ready
		player.animated_sprite.animation_finished.connect(_on_animation_finished)

func basic_movement(delta: float, max_speed: float):
	
	# Flip the sprite left or right
	if player.direction < 0:
		player.animated_sprite.flip_h = true
	elif player.direction > 0:
		player.animated_sprite.flip_h = false
			
	# Determine target velocity
	var target_velocity = player.direction * max_speed
	# Player wants to move
	if player.direction != 0:
		player.velocity.x = move_toward(player.velocity.x, target_velocity, acceleration * delta)
	else:
		# Apply friction (slow down)
		player.velocity.x = move_toward(player.velocity.x, 0, friction * delta)
	
