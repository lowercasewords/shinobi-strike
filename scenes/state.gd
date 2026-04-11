class_name State extends Node2D

@onready var player: Player = owner 

# Base state class for entities that need complex states

const ACCELERATION: float = 200.0
const FRICTION: float = 740.0
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

func fall_state_triggered() -> bool:
	return not player.is_on_floor() and player.velocity.y > 0 and player.state_machine.current_state.name.to_lower() != StateMachine.FALL

func sidewalls_collision_direction() -> float:
	var wall_direction_horiz: float = 0
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		var normal = collision.get_normal()
		
		wall_direction_horiz = normal.x
	return wall_direction_horiz

func wall_run_v_state_triggerd() -> bool:
	return sidewalls_collision_direction() != 0
	
func _ready():
	if not player.is_node_ready():
		await player.ready
		player.animated_sprite.animation_finished.connect(_on_animation_finished)

func basic_movement(delta: float, max_speed: float):
	# Determine target velocity
	var target_velocity = player.direction * max_speed
	# Player wants to move
	if player.direction != 0:
		player.velocity.x = move_toward(player.velocity.x, target_velocity, acceleration * delta)
	else:
		# Apply friction (slow down)
		player.velocity.x = move_toward(player.velocity.x, 0, friction * delta)
	
