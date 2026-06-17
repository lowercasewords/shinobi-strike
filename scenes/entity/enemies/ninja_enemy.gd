class_name NinjaEnemy extends Ninja

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	super._ready()

func _on_hitbox_body_entered(body: Node2D):
	super._on_hitbox_body_entered(body)
	
func take_damage(damage: int):
	super.take_damage(damage)
	animated_sprite.play("hurt_still")
