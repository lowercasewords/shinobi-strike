class_name State extends Node2D

@onready var player: Player = owner 

# Abstract class for entities that need complex states

signal transitioned(new_state_name: String)
func enter(): pass
func exit(): pass
func update(_delta: float): pass
func physics_update(_delta: float): pass
func windup_finsh() -> void: pass
func _on_animation_finished(): pass

func _ready():
	if not player.is_node_ready():
		await player.ready
		player.animated_sprite.animation_finished.connect(_on_animation_finished)

const ACCELERATION: float = 300.0
const FRICTION: float = 1200.0
var friction: float = FRICTION
var acceleration: float = ACCELERATION

func basic_movement(delta: float, max_speed: float):
	if player.direction:
		# 2. Determine target velocity
		var target_velocity = player.direction * max_speed
		
		if player.direction != 0:
			# 3. Accelerate towards target
			player.velocity.x = move_toward(player.velocity.x, target_velocity, acceleration * delta)
		else:
			# 4. Apply friction (slow down)
			player.velocity.x = move_toward(player.velocity.x, 0, friction * delta)
		
	else:
		# Smoothly slow down
		player.velocity.x = move_toward(player.velocity.x, 0, max_speed * delta)
