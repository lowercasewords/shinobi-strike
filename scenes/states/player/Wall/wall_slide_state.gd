## State for sliding down a vertical wall
class_name WallSlideState extends WallBaseState

func enter():
	super.enter()
	set_physics_wallcrawl()
	set_animation("wall_slide_v")
	
	ninja_owner.velocity.y /= 2

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	var input_x: float = ninja_owner.ninja_controller.get_input_direction_h()
	var input_jump: bool = ninja_owner.ninja_controller.get_input_pressed_jump()
	var wall_direction: int = get_wall_direction()
	
	# Apply gravity while sliding, clamped to max slide speed
	ninja_owner.velocity.y = clamp(
		move_toward(ninja_owner.velocity.y, MAX_SLIDE_SPEED, SLIDE_GRAVITY * _delta),
		0,
		MAX_SLIDE_SPEED
	)
	
	# Check for exit conditions
	if check_wall_exit():
		return
	
	# Check for state transitions
	if input_jump:
		switch_state(StateMachine.WALLJUMP)
	elif input_x == 0:  # No horizontal input, return to cling
		switch_state(StateMachine.WALLCLING)
	elif input_x == -wall_direction:  # Input pulling away from wall, moving upward
		switch_state(StateMachine.WALLRUN)

func on_owner_animation_finished(_animation_name: String) -> void:
	pass
