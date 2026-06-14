class_name GroundComboA extends ComboState
"""
LIGHT ATTACK -> LIGHT ATTACK -> HEAVY ATTACK
"""

func enter() -> void:
	super.enter()
	decide_upon_attack_finish()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)

func decide_upon_attack_finish() -> bool:
	"""
	Either continue 
	"""
	if player.attack_input_buffer.size() > 0:
		var current_attack: ATTACK_TYPE = pop_attack()
		return try_dequeue_attack(current_attack)
	else:
		change_state()
		return false
	

func try_dequeue_attack(current_attack: ATTACK_TYPE) -> bool:
	var attack_activated: bool = false
	
	match attack_input_buffer.size():
		1:
			if current_attack == ATTACK_TYPE.LIGHT:
				attack_activated = start_attack_A()
		2: 
			if current_attack == ATTACK_TYPE.LIGHT:
				attack_activated = start_attack_B()
		3:
			if current_attack == ATTACK_TYPE.HEAVY:
				attack_activated = start_attack_C()
	
	return attack_activated
	
func start_attack_A() -> bool:
	player.animated_sprite.play("ground_combo_A_A")
	return true

func start_attack_B() -> bool:
	player.animated_sprite.play("ground_combo_A_B")
	return true
	
func start_attack_C() -> bool:
	player.animated_sprite.play("ground_combo_A_C")
	return true

func _on_animation_finished():
	input_window.start(DEFAULT_INPUT_WINDOW_TIME)
	
func _on_input_window_timeout():
	decide_upon_attack_finish()
	
func change_state() -> String:
	var current_state_name: String = player.state_machine.current_state.name.to_lower()
	
	if fall_state_triggered():
		transitioned.emit(self, StateMachine.FALL)
		return StateMachine.FALL
	
	if current_state_name != StateMachine.WALK:
		transitioned.emit(self, StateMachine.WALK)
		return StateMachine.WALK
	
	if player.input_direction == 0 and player.velocity.x == 0 and current_state_name != StateMachine.IDLE:
		transitioned.emit(self, StateMachine.IDLE)
		return StateMachine.IDLE
	
	return ""
