class_name GroundComboA extends ComboState

func enter() -> void:
	super.enter()
	start_hit_A()

func start_hit_A() -> bool:
	player.animated_sprite.play("ground_combo_A_A")
	return true

func start_hit_B() -> bool:
	player.animated_sprite.play("ground_combo_A_B")
	return true
	
func start_hit_C() -> bool:
	player.animated_sprite.play("ground_combo_A_C")
	return true

func _on_animation_finished():
	change_state()

func _on_input_window_timeout():
	change_state()
	
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
