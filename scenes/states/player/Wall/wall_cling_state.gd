## State for clinging to a vertical wall with minimal movement
class_name WallClingState extends WallBaseState

func enter():
	super.enter()
	set_animation("wall_cling_v")
	
	var wall_direction: int = get_wall_direction()
	if wall_direction == 0:
		# No wall detected, exit to jump state
		switch_state(StateMachine.JUMP)
		return
	
	# Orient player away from wall
	update_forward_direction_h(-wall_direction)
	velocity_requested.emit(Vector2(0, ninja_owner.velocity.y / 2))

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	var input_x: float = ninja_owner.ninja_controller.get_input_direction_h()
	var input_jump: bool = ninja_owner.ninja_controller.get_input_pressed_jump()
	var wall_direction: int = get_wall_direction()
	
	# Maintain cling position
	velocity_requested.emit(Vector2(ninja_owner.velocity.x, 0))
	
	# Check for state transitions
	if input_jump:
		switch_state(StateMachine.WALLJUMP)
	elif input_x == wall_direction:  # Input pushing into wall
		switch_state(StateMachine.WALLSLIDE)
	elif input_x == -wall_direction:  # Input pulling away from wall, moving upward
		switch_state(StateMachine.WALLRUN)

func on_owner_animation_finished(_animation_name: String) -> void:
	pass
