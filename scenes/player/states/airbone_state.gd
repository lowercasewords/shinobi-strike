class_name AirboneState extends State

var AIRBONE_ACCELERATION = ACCELERATION*3
func physics_update(_delta: float) -> void:
	acceleration = AIRBONE_ACCELERATION
	
func check_airbone_transitions() -> String:
	var current_state_name: String = player.state_machine.current_state.name.to_lower()

	if player.just_landed and current_state_name != StateMachine.LAND:
		transitioned.emit(self, StateMachine.LAND)
		return StateMachine.LAND
		
	if fall_state_triggered():
		transitioned.emit(self, StateMachine.FALL)
		return StateMachine.FALL
		
	return ""
