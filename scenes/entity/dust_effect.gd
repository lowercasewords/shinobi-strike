class_name DustEffect extends Node2D

## Animation player
@export var dust_player: AnimationPlayer

func vanish() -> void:
	queue_free()

func _on_dust_player_animation_changed(old_name: String, _new_name: String):
	if old_name == "spawn":
		vanish()
