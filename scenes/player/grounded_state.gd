class_name GroundedState extends State

#var coyote_timer: Timer
#func _ready():
	#coyote_timer = Timer.new()
	#self.add_child(coyote_timer)

func jump_state_triggered() -> bool:
	"""
	Is jump state triggered this tic?
	"""
	return player.is_jumping and player.state_machine.current_state.name.to_lower() != StateMachine.JUMP
	
func turn_state_triggered() -> bool:
	"""
	Is turn state triggered this tic?
	"""
	return player.just_changed_directions and player.state_machine.current_state.name.to_lower() != StateMachine.TURN
	
func check_grounded_transitions() -> String:
	var current_state_name: String = player.state_machine.current_state.name.to_lower()
	
	if jump_state_triggered():
		transitioned.emit(self, StateMachine.JUMP)
		return StateMachine.JUMP
	
	if turn_state_triggered():
		transitioned.emit(self, StateMachine.TURN)
		return StateMachine.TURN
	
	if player.direction != 0 and current_state_name != StateMachine.WALK:
		transitioned.emit(self, StateMachine.WALK)
		return StateMachine.WALK
	
	if player.direction == 0 and player.velocity.x == 0 and current_state_name != StateMachine.IDLE:
		transitioned.emit(self, StateMachine.IDLE)
		return StateMachine.IDLE
		
	return ""
