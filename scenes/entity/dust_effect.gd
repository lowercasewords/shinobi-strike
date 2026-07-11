class_name DustEffect extends Node2D

@export var dust_player: AnimationPlayer

func vanish() -> void:
	queue_free()
