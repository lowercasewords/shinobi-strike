class_name DismembermentMachine extends Node

const DISMEMBERED_PIECE_SCENE = preload("res://scenes/entity/enemies/EradicatedPiece.tscn")

func get_default_linear_velocity() -> Vector2:
	return Vector2(randi_range(50, 200), randi_range(-100, -250))
	
func get_default_angular_velocity() -> float:
	return randi_range(5, 50) * get_random_direction()
	
## Returns either 1 or -1
func get_random_direction() -> int:
	return 1 if (randi() % 2) == 0 else -1

## Chops any piece off the enemy, could be a limb or a sword.
## [br]
## Args:
## [br]
## animation (String): Actual sprite of the piece, such as arm, leg, head, sword, etc.
## [br]
## piece_linear_velocity (Vector2): The linear velocity of the piece on spawn
## [br]
## piece_angular_velocity (float): The angular velocity of the piece on spawn
func _chop_piece_off(animation: String, piece_linear_velocity: Vector2, piece_angular_velocity: float) -> EradicatedPiece:
	var piece: EradicatedPiece = DISMEMBERED_PIECE_SCENE.instantiate()
	
	owner.add_sibling(piece)
	
	piece.global_position = owner.global_position
	piece.linear_velocity = piece_linear_velocity
	piece.angular_velocity = piece_angular_velocity
	piece.animated_sprite.play(animation)
	
	return piece

## Specifically chops off the enemy limbs [br][br]
## Args: [br]
## animation (String): Actual sprite of the piece, such as arm, leg, head, sword, etc. [br]
## direction (int): Piece flies off either left (-1) or right (1)  [br][br]
## Returns: [br]
## EradicatedPiece: spawned eradicated piece
func chop_limb_off(animation: String, direction: int = 1) -> EradicatedPiece:
	var linear_velocity: Vector2 = get_default_linear_velocity()
	direction = clamp(direction, -1, 1)
	linear_velocity.x *= direction
	
	var piece: EradicatedPiece = _chop_piece_off(animation, linear_velocity, get_default_angular_velocity())
	
	piece.spawn_blood()
	return piece

func chop_both_limbs_off(animation: String) -> Array[EradicatedPiece]:
	return [chop_limb_off(animation, 1), chop_limb_off(animation, -1)]
