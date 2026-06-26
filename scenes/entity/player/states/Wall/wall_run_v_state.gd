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
	ninja_owner.animated_sprite.play("wall_run_v")
	ninja_owner.velocity.y = WALL_RUN_SPEED
	ninja_owner.animated_sprite.position.x = sprites_shift_amount * wall_direction
	
func exit() -> void:
	super.exit()
	ninja_owner.animated_sprite.position.x = 0.0

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	var wall_direction = sidewalls_collision_direction()
	
	if check_wall_exit(wall_direction) == "":
		if ninja_owner.ninja_controller.get_input_pressing_jump():
			#ninja_owner.velocity.x = 15*wall_direction
			switch_state(StateMachine.WALLJUMPV)
		elif ninja_owner.ninja_controller.get_input_direction_h() == 0:
			switch_state(StateMachine.WALLCLINGV)
		elif ninja_owner.ninja_controller.get_input_direction_h() == wall_direction:
			ninja_owner.velocity.y = move_toward(ninja_owner.velocity.y, 0, WALL_FRICTION * _delta)
			ninja_owner.velocity.x = 0
	#else:
		#ninja_owner.velocity.y = -305
		#ninja_owner.velocity.x = 5*wall_direction
		#switch_state(StateMachine.FALL)
