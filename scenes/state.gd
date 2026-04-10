class_name State extends Node2D

@onready var player: Player = owner 

# Abstract class for entities that need complex states

signal transitioned(new_state_name: String)
func enter(): pass
func exit(): pass
func update(_delta: float): pass
func physics_update(_delta: float): pass

func basic_movement(speed: float):
	if player.direction:
		player.velocity.x = player.direction * speed
	else:
		# Smoothly slow down
		player.velocity.x = move_toward(player.velocity.x, 0, speed * 0.1)
