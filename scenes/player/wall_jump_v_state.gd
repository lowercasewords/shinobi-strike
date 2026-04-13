class_name WallJumpVState extends WallState

const JUMP_SPEED_INITIAL: Vector2 = Vector2(-150, 150)

func enter():
	var direction = sidewalls_collision_direction()
	if not player.state_machine.current_state is WallJumpVState:
		player.animated_sprite.play("wall_jump_v_windup")
	else:
		jump()

func jump():
	player.animated_sprite.play("wall_jump_v")
	player.velocity += JUMP_SPEED_INITIAL

func _on_animation_finished():
	if player.animated_sprite.animation == "wall_jump_v_windup":
		jump()
