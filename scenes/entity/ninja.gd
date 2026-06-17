class_name Ninja extends CharacterBody2D

@onready var attack_area: Area2D = $AttackArea


func _ready():
	attack_area.collision_layer = 0
	deactivate_attack_area()
	attack_area.body_entered.connect(_on_hitbox_body_entered)

func get_attack_active_mask() -> int: return 0

func activate_attack_area() -> void:
	attack_area.show()
	attack_area.collision_mask = get_attack_active_mask()
	#attack_area.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE

func deactivate_attack_area() -> void:
	attack_area.hide()
	attack_area.collision_mask = 0
	#attack_area.disable_mode = CollisionObject2D.DISABLE_MODE_MAKE_STATIC
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	self.take_damage(1)

func deal_damage(damage: int):
	pass

func take_damage(damage: int):
	pass
