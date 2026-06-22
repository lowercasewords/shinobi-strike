class_name WallRunVState extends State

const SPRITE_SHIFT_AMOUNT = -12
const WALL_RUN_SPEED: float = -200
const WALL_FRICTION: float = DEFAULT_GROUNDED_FRICTION/10

func enter() -> void:
	super.enter()
	var wall_direction = sidewalls_collision_direction()
	var sprites_shift_amount = SPRITE_SHIFT_AMOUNT
	
	# Account for one pixel of rotation
	if wall_direction < 0:
		sprites_shift_amount += 1
	state_owner.animated_sprite.play("wall_run_v")
	state_owner.velocity.y = WALL_RUN_SPEED
	state_owner.animated_sprite.position.x = sprites_shift_amount * wall_direction
	
func exit() -> void:
	super.exit()
	state_owner.animated_sprite.position.x = 0.0

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	var wall_direction = sidewalls_collision_direction()
	
	if check_wall_exit(wall_direction) == "":
		if state_owner.ninja_controller.get_input_pressing_jump():
			#state_owner.velocity.x = 15*wall_direction
			switch_state(StateMachine.WALLJUMPV)
		elif state_owner.ninja_controller.get_input_direction_h() == 0:
			switch_state(StateMachine.WALLCLINGV)
		elif state_owner.ninja_controller.get_input_direction_h() == wall_direction:
			state_owner.velocity.y = move_toward(state_owner.velocity.y, 0, WALL_FRICTION * _delta)
			state_owner.velocity.x = 0
	#else:
		#state_owner.velocity.y = -305
		#state_owner.velocity.x = 5*wall_direction
		#switch_state(StateMachine.FALL)
