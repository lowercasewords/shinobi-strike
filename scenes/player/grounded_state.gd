class_name GroundedState extends State

func check_grounded_transitions() -> bool:
	var current_state_name: String = player.state_machine.current_state.name.to_lower()
	
	if player.is_on_floor():
		if player.just_landed and current_state_name != StateMachine.LAND:
			transitioned.emit(self, StateMachine.LAND)
			return true
			
		if Input.is_action_just_pressed("ui_accept") and current_state_name != StateMachine.JUMP:
			transitioned.emit(self, StateMachine.JUMP)
			return true
		
		# While landing, grounded states won't start
		if player.animated_sprite.animation != "land" or (player.animated_sprite.animation == "land" and not player.animated_sprite.is_playing()):
			if player.direction != 0 and current_state_name != StateMachine.WALK:
				transitioned.emit(self, StateMachine.WALK)
				#print(player.state_machidne.current_state)
				return true
			elif player.velocity.x == 0 and current_state_name != StateMachine.IDLE:
				transitioned.emit(self, StateMachine.IDLE)
				return true
					
	return false
