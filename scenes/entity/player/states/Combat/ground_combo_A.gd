class_name GroundComboA extends ComboState
"""
LIGHT ATTACK -> LIGHT ATTACK -> HEAVY ATTACK
"""

func enter() -> void:
	super.enter()
	try_continue_combo()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)

func try_continue_combo() -> bool:
	"""
	Dequeues the current combo input buffer to attempt to continue the combo with the next attack
	
	Returns:
		 Whether the combo was continued or not
	"""
	var current_attack: ATTACK_TYPE = pop_attack()
	var dequeued_attack: bool = combo_next_attack(current_attack)

	return dequeued_attack
	
func combo_next_attack(current_attack: ATTACK_TYPE) -> bool:
	"""
	Attemps to continue combo based on the move provided as an argument
	"""
	var combo_continued: bool = false
	
	match attack_input_buffer.size():
		1:
			if current_attack == ATTACK_TYPE.LIGHT:
				combo_continued = start_attack_A()
		2: 
			if current_attack == ATTACK_TYPE.LIGHT:
				combo_continued = start_attack_B()
		3:
			if current_attack == ATTACK_TYPE.HEAVY:
				combo_continued = start_attack_C()
	
	return combo_continued
	
func start_attack_A() -> bool:
	player.animated_sprite.play("ground_combo_A_A")
	player.velocity.x += player.forward_direction * DEFAULT_H_THURST*2
	return true

func start_attack_B() -> bool:
	player.animated_sprite.play("ground_combo_A_B")
	player.velocity.x += player.forward_direction * DEFAULT_H_THURST
	return true
	
func start_attack_C() -> bool:
	player.animated_sprite.play("ground_combo_A_C")
	player.velocity.x += player.forward_direction * DEFAULT_H_THURST/10
	return true

func _on_animation_finished():
	var was_combo_continued: bool = try_continue_combo()
		
	if not was_combo_continued:
		last_attack_lag.start(LAST_ATTACK_LAG_TIME)
	
func _on_last_attack_lag_timeout():
	change_state()
	
func _on_last_frame(animation: String):
	super._on_last_frame(animation)
	player.velocity.x = 0
	
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
