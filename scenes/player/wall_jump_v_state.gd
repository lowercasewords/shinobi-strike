class_name WallJumpVState extends WallState

const JUMP_SPEED_INITIAL: Vector2 = Vector2(-150, 150)

func enter():
	var direction = sidewalls_collision_direction()
	player.animated_sprite.play("wall_jump_v")
	player.velocity += JUMP_SPEED_INITIAL
