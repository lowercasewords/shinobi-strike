class_name LandState extends State

@export var audio_stream: AudioStreamPlayer2D

func enter() -> void:
	super.enter()
	set_animation("land")
	
	var input_direction: int = int(ninja_owner.ninja_controller.get_input_direction_h())
	var _new_direction: int = update_forward_direction_h(input_direction)

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	allow_movement(_delta)
	if not ninja_owner.is_grounded:
		apply_gravity(_delta)
	
	if attack_triggered():
		switch_state(StateMachine.ATTACK)
	elif turn_state_triggered():
		switch_state(StateMachine.TURN)
	elif jump_state_triggered():
		switch_state(StateMachine.JUMP)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED

func on_owner_animation_finished(_animation_name: String) -> void:
	if idle_state_triggered():
		switch_state(StateMachine.IDLE)
	elif walk_state_triggered():
		switch_state(StateMachine.WALK)
	#if ninja_owner.state_machine.state_current.name.to_lower() == StateMachine.LAND:
		#if get_ninja_grounded_transitions() == "":
			# Just in case to not get stuck in this land state
			#switch_state(StateMachine.IDLE)
		
