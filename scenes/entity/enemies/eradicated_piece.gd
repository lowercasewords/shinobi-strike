# Ripped piece of an enemy 
class_name EradicatedPiece extends RigidBody2D

enum Piece {
	Arm,
	Leg,
	Head,
	Sword,
	Torso
}

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	particles.one_shot = true

func spawn_blood() -> void:
	particles.one_shot = true
	particles.emitting = true
