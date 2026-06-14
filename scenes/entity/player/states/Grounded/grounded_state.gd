class_name GroundedState extends State

#var coyote_timer: Timer
#func _ready():
	#coyote_timer = Timer.new()
	#self.add_child(coyote_timer)
const TURN_SPEED_THRESHOLD: float = 5

func _physics_process(delta):
	direction_flip_horiz()
	
func combo_A_triggered() -> bool:
	return player.attack_input_buffer.size() > 0 and player.attack_input_buffer[0] == ComboState.ATTACK_TYPE.LIGHT
	
func jump_state_triggered() -> bool:
	"""
	Is jump state triggered this tic?
	"""
	return player.is_jumping and player.state_machine.current_state.name.to_lower() != StateMachine.JUMP
	
func turn_state_triggered() -> bool:
	"""
	Is turn state triggered this tic?
	"""
	return (player.velocity.normalized().x*player.actual_direction < 0 or player.just_changed_directions) and abs(player.velocity.x) > TURN_SPEED_THRESHOLD and player.state_machine.current_state.name.to_lower() != StateMachine.TURN

func check_grounded_transitions() -> String:
	var current_state_name: String = player.state_machine.current_state.name.to_lower()
	
	if combo_A_triggered():
		transitioned.emit(self, StateMachine.GROUNDCOMBOA)
		return StateMachine.GROUNDCOMBOA
		
	if fall_state_triggered():
		transitioned.emit(self, StateMachine.FALL)
		return StateMachine.FALL
		
	if jump_state_triggered():
		transitioned.emit(self, StateMachine.JUMP)
		return StateMachine.JUMP
	
	if turn_state_triggered():
		transitioned.emit(self, StateMachine.TURN)
		return StateMachine.TURN
	
	if player.input_direction != 0 and current_state_name != StateMachine.WALK:
		transitioned.emit(self, StateMachine.WALK)
		return StateMachine.WALK
	
	if player.input_direction == 0 and player.velocity.x == 0 and current_state_name != StateMachine.IDLE:
		transitioned.emit(self, StateMachine.IDLE)
		return StateMachine.IDLE
		
	return ""

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	apply_gravity(_delta)
