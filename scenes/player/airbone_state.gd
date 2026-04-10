class_name AirboneState extends State

func check_airbone_transitions() -> bool:
	if player.just_landed:
		transitioned.emit(self, StateMachine.LAND)
		return true
	return false
