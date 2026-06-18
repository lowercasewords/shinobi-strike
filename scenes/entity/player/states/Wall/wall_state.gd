class_name WallState extends State
	
func check_default_exit(wall_direction: float):
	var input_direction_h: float = state_entity_owner.ninja_controller.get_input_direction_h()
	if state_entity_owner.just_grounded:
		#input_direction_h = -wall_direction
		transitioned.emit(self, StateMachine.LAND)
		return StateMachine.LAND
	elif wall_direction == 0:
		transitioned.emit(self, StateMachine.FALL)
		return StateMachine.FALL
	return ""
			
#func check_wall_transitions() -> String:
	#var current_state_name: String = state_entity_owner.state_machine.current_state.name.to_lower()
#
	#if state_entity_owner.just_grounded and current_state_name != StateMachine.LAND:
		#transitioned.emit(self, StacteMachine.LAND)
		#return StateMachine.LAND
	#return ""
