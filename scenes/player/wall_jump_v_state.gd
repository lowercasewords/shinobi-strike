class_name WallJumpVState extends WallState

const JUMP_SPEED_INITIAL: Vector2 = Vector2(-200, -400)
const JUMP_ACCELERATION: float = AirborneState.AIRBONE_ACCELERATION/2
const JUMP_FRICTION: float = AirborneState.AIRBONE_FRICTION/3

func enter():
	super.enter()
	var input_direction = sidewalls_collision_direction()
	if not player.state_machine.current_state is WallJumpVState:
		player.animated_sprite.play("wall_jump_v_windup")
	elif abs(input_direction) == 1:
		jump_off_the_wall(-input_direction)

#func exit():
	#jump_off_the_wall(-player.input_direction)

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	basic_movement(_delta, player.SPEED)
	
	apply_gravity(_delta)
	friction = JUMP_FRICTION
	acceleration = JUMP_ACCELERATION
	
	var input_direction = sidewalls_collision_direction()
	if player.is_on_floor():
		transitioned.emit(self, StateMachine.LAND)
	if abs(input_direction) == 1:
		if player.is_jumping:
			jump_off_the_wall(-input_direction)
		else:
			transitioned.emit(self, StateMachine.WALLCLINGV)

func jump_off_the_wall(input_direction: float):
	player.animated_sprite.play("wall_jump_v")
	player.velocity.x = JUMP_SPEED_INITIAL.x * -input_direction
	player.velocity.y = JUMP_SPEED_INITIAL.y

func _on_animation_finished():
	var input_direction = sidewalls_collision_direction()
	if player.animated_sprite.animation == "wall_jump_v_windup" and abs(input_direction) == 1:
		jump_off_the_wall(-input_direction)
