class_name Ninja extends CharacterBody2D

@onready var attack_area: Area2D = $AttackArea

var attack_collision_mask: int = 0
var attack_collision_layer: int = 0

func _ready():
	attack_collision_mask = attack_area.collision_mask
	attack_collision_layer = attack_area.collision_layer
	deactivate_attack_area()
	if not attack_area.body_entered.is_connected(_on_hitbox_body_entered):
		attack_area.body_entered.connect(_on_hitbox_body_entered)

func get_attack_collision_layer() -> int: return attack_collision_layer
func get_attack_collision_mask() -> int: return attack_collision_mask

func _exit_tree():
	if attack_area.body_entered.is_connected(_on_hitbox_body_entered):
		attack_area.body_entered.disconnect(_on_hitbox_body_entered)

func activate_attack_area() -> void:
	#attack_area.show()
	attack_area.collision_mask = get_attack_collision_mask()
	attack_collision_layer = get_attack_collision_layer()
	#attack_area.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE

func deactivate_attack_area() -> void:
	#attack_area.hide()
	attack_area.collision_mask = 0
	#attack_area.disable_mode = CollisionObject2D.DISABLE_MODE_MAKE_STATIC
	
func _on_hitbox_body_entered(_body: Node2D): pass

func deal_damage(_damage: int): pass

func take_damage(_damage: int): pass
