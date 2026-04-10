class_name LandState extends GroundedState

func enter() -> void:
	player.animated_sprite.play("land")
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	if turn_state_triggered():
		transitioned.emit(self, StateMachine.TURN)
	elif jump_state_triggered():
		transitioned.emit(self, StateMachine.JUMP)
	basic_movement(_delta, player.SPEED)

func _on_animation_finished():
	if player.state_machine.current_state.name.to_lower() == StateMachine.LAND:
		if check_grounded_transitions() == "":
			# Just in case to not get stuck in this land state
			transitioned.emit(self, StateMachine.IDLE)
		
