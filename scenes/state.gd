class_name State extends Node2D

@onready var player: Player = owner 

# Abstract class for entities that need complex states

signal transitioned(new_state_name: String)
func enter(): pass
func exit(): pass
func update(_delta: float): pass
func physics_update(_delta: float): pass
