## State for jumping off a vertical wall with momentum
class_name WallJumpState extends WallBaseState

func enter():
	super.enter()
	
	var wall_direction: int = get_wall_direction()
	
	if abs(wall_direction) != 1:
		# No wall, switch to jump state
		switch_state(StateMachine.JUMP)
		return
	
	# Orient player away from wall
	update_forward_direction_h(-wall_direction)
	
	# Set initial jump velocity
	set_animation("wall_jump_windup_v")
	#ninja_owner.mario_jump_timer.start()
	velocity_requested.emit(Vector2(
		JUMP_SPEED_INITIAL.x * ninja_owner.forward_direction_h,
		JUMP_SPEED_INITIAL.y
	))
#
#func physics_update(_delta: float) -> void:
	#super.physics_update(_delta)
	#
	#var input_x: float = ninja_owner.ninja_controller.get_input_direction_h()
	#var input_jump: bool = ninja_owner.ninja_controller.get_input_pressed_jump()
	#var wall_direction: int = get_wall_direction()
	#
	## Apply movement and gravity
	#allow_movement(_delta)
	#mario_jump_update(_delta, MARIO_JUMP_STRENGTH)
	#apply_gravity(_delta)
	#
	## Check for exit conditions first
	#if check_wall_exit():
		#return
	#
	## If we re-touch a wall while jumping
	#if wall_direction != 0:
		## Re-enter cling state if jumping has ended
		#if ninja_owner.mario_jump_timer.is_stopped():
			#set_animation("wall_jump_cling_v")
			#velocity_requested.emit(Vector2(0, ninja_owner.velocity.y / 2))
			#switch_state(StateMachine.WALLCLING)
#
func on_owner_animation_finished(_animation_name: String) -> void:
	match _animation_name:
		"wall_jump_windup_v":
			switch_state(StateMachine.JUMP)
