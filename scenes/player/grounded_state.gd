class_name GroundedState extends State

func check_grounded_transitions() -> bool:
	if player.is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		transitioned.emit(self, "jump")
		return true
	
	return false
