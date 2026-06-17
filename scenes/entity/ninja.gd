class_name Ninja extends CharacterBody2D

@onready var attack_area: Area2D = $AttackArea
@onready var hitbox_area: Area2D = $Hitbox

func activate_attack_area() -> void:
	attack_area.show()

func deactivate_attack_area() -> void:
	attack_area.hide()

func deal_damage(damage: int):
	pass

func take_damage(damage: int):
	pass
