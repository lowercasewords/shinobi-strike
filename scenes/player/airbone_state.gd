class_name AirboneState extends State

func check_airbone_transitions() -> String:
	var current_state_name: String = player.state_machine.current_state.name.to_lower()
	
	if player.just_landed and current_state_name != StateMachine.LAND:
		transitioned.emit(self, StateMachine.LAND)
		return StateMachine.LAND
		
	if player.velocity.y > 0 and current_state_name != StateMachine.FALL:
		transitioned.emit(self, StateMachine.FALL)
		return StateMachine.FALL
	return ""
