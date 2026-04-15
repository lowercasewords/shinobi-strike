class_name WallJumpVState extends AirborneState

const JUMP_SPEED_INITIAL: Vector2 = Vector2(-200, -400)

func enter():
	super.enter()
	var direction = sidewalls_collision_direction()
	if not player.state_machine.current_state is WallJumpVState:
		player.animated_sprite.play("wall_jump_v_windup")
	elif abs(direction) == 1:
		jump_off_the_wall(-direction)

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	basic_movement(_delta, abs(JUMP_SPEED_INITIAL.x))
	var direction = sidewalls_collision_direction()
	if player.is_on_floor():
		transitioned.emit(self, StateMachine.LAND)
	if abs(direction) == 1:
		if player.is_jumping:
			jump_off_the_wall(-direction)
		else:
			transitioned.emit(self, StateMachine.WALLCLINGV)

func jump_off_the_wall(direction: float):
	player.animated_sprite.play("wall_jump_v")
	player.velocity.x = JUMP_SPEED_INITIAL.x * -direction
	player.velocity.y = JUMP_SPEED_INITIAL.y

func _on_animation_finished():
	var direction = sidewalls_collision_direction()
	if player.animated_sprite.animation == "wall_jump_v_windup" and abs(direction) == 1:
		jump_off_the_wall(-direction)
