## State for running upward along a vertical wall
class_name WallRunState extends WallBaseState

func enter():
	super.enter()
	set_physics_wallcrawl()
	set_animation("wall_run_v")
	
	velocity_requested.emit(Vector2(ninja_owner.velocity.x, ninja_owner.velocity.y / 2))

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	var input_x: float = ninja_owner.ninja_controller.get_input_direction_h()
	var input_jump: bool = ninja_owner.ninja_controller.get_input_pressed_jump()
	var wall_direction: int = get_wall_direction()
	
	# Exited the wall - fall and push away
	if abs(wall_direction) != 1:
		velocity_requested.emit(Vector2(10, -250))
		apply_gravity(_delta)
		return
	
	# Running up the wall
	var run_velocity_y = move_toward(
		ninja_owner.velocity.y,
		WALL_RUN_SPEED,
		WALL_RUN_ACCELERATION * _delta
	)
	velocity_requested.emit(Vector2(0, run_velocity_y))
	
	# Check for exit conditions
	if check_wall_exit():
		return
	
	# Check for state transitions
	if input_jump:
		switch_state(StateMachine.WALLJUMP)
	elif input_x == 0:  # No horizontal input, return to cling
		switch_state(StateMachine.WALLCLING)
	elif input_x == wall_direction:  # Input pushing into wall
		switch_state(StateMachine.WALLSLIDE)

func on_owner_animation_finished(_animation_name: String) -> void:
	pass
