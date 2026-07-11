# Ripped piece of an enemy 
class_name EradicatedPiece extends RigidBody2D

enum Piece {
	Arm,
	Leg,
	Head,
	Sword,
	Torso
}

@export var launch_linear_velocity: Vector2 = Vector2.UP
@export var launch_angular_velocity: float = 2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var particles: GPUParticles2D = $BloodDrops

func _ready() -> void:
	self.linear_velocity = launch_linear_velocity
	self.angular_velocity = launch_angular_velocity
	
	particles.one_shot = true

func spawn_blood() -> void:
	particles.one_shot = true
	particles.emitting = true
