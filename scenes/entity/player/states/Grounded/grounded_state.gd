class_name GroundedState extends State

#var coyote_timer: Timer
#func _ready():
	#coyote_timer = Timer.new()
	#self.add_child(coyote_timer)
const TURN_SPEED_THRESHOLD: float = 5

func _physics_process(delta):
	direction_flip_horiz()
	
func combo_A_triggered() -> bool:
	return state_entity_owner.attack_input_buffer.size() > 0 and state_entity_owner.attack_input_buffer[0] == ComboState.ATTACK_TYPE.LIGHT
	
func jump_state_triggered() -> bool:
	"""
	Is jump state triggered this tic?
	"""
	return state_entity_owner.ninja_controller.get_input_pressing_jump() and state_entity_owner.state_machine.current_state.name.to_lower() != StateMachine.JUMP
	
func turn_state_triggered() -> bool:
	"""
	Is turn state triggered this tic?
	"""
	return (state_entity_owner.velocity.normalized().x*state_entity_owner.ninja_controller.get_input_direction_h() < 0 or state_entity_owner.just_changed_directions) and abs(state_entity_owner.velocity.x) > TURN_SPEED_THRESHOLD and state_entity_owner.state_machine.current_state.name.to_lower() != StateMachine.TURN

func check_grounded_transitions() -> String:
	var current_state_name: String = state_entity_owner.state_machine.current_state.name.to_lower()
	
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
	
	if state_entity_owner.ninja_controller.get_input_direction_h() != 0 and current_state_name != StateMachine.WALK:
		transitioned.emit(self, StateMachine.WALK)
		return StateMachine.WALK
	
	if state_entity_owner.ninja_controller.get_input_direction_h() == 0 and state_entity_owner.velocity.x == 0 and current_state_name != StateMachine.IDLE:
		transitioned.emit(self, StateMachine.IDLE)
		return StateMachine.IDLE
		
	return ""

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	apply_gravity(_delta)
