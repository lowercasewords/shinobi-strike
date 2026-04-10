class_name GroundedState extends State

func check_grounded_transitions() -> bool:
	if player.is_on_floor():
		if player.just_landed and player.state_machine.current_state != LandState:
			transitioned.emit(self, StateMachine.LAND)
			return true
			
		if Input.is_action_just_pressed("ui_accept") and player.state_machine.current_state != JumpState:
			transitioned.emit(self, StateMachine.JUMP)
			return true
		
		# While landing, grounded states won't start
		if player.animated_sprite.animation != "land" or (player.animated_sprite.animation == "land" and not player.animated_sprite.is_playing()):
			if player.direction != 0 and player.state_machine.current_state != WalkState:
				transitioned.emit(self, StateMachine.WALK)
				return true
			elif player.velocity.x == 0 and player.state_machine.current_state != IdleState:
				transitioned.emit(self, StateMachine.IDLE)
				return true
	
	
	return false
