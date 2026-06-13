class_name WallState extends State
	
func check_default_exit(wall_direction: float):
	if player.just_landed:
		player.input_direction = -wall_direction
		transitioned.emit(self, StateMachine.LAND)
		return StateMachine.LAND
	elif wall_direction == 0:
		transitioned.emit(self, StateMachine.FALL)
		return StateMachine.FALL
	return ""
			
#func check_wall_transitions() -> String:
	#var current_state_name: String = player.state_machine.current_state.name.to_lower()
#
	#if player.just_landed and current_state_name != StateMachine.LAND:
		#transitioned.emit(self, StacteMachine.LAND)
		#return StateMachine.LAND
	#return ""
