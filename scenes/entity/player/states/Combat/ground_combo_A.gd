## LIGHT ATTACK -> LIGHT ATTACK -> HEAVY ATTACK
class_name GroundComboAState extends AttackState

@export var sword_whoosh: AudioStreamPlayer2D = null

func enter() -> void:
	super.enter()
	try_continue_combo()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	var animated_sprite = state_owner.animated_sprite
	var animation: String = animated_sprite.animation
	var frame_index: int = animated_sprite.frame 
	var total_frames: int = animated_sprite.sprite_frames.get_frame_count(animation)
	# Make sure that the attack that continues the combo doesn't start immediately after the last attack ended,
	# othrewise it is too fast for the state_owner to register their combo flow
	var frame_progress_threshold: float = 0.2
	
	# During last frame
	if frame_index == total_frames-1 and animated_sprite.frame_progress > frame_progress_threshold:
		var was_combo_continued: bool = try_continue_combo()
		if not was_combo_continued:
			pass

func try_continue_combo() -> bool:
	"""
	Dequeues the current combo input buffer to attempt to continue the combo with the next attack
	
	Returns:
		 Whether the combo was continued or not
	"""
	var current_attack: ATTACK_TYPE = pop_attack()
	var dequeued_attack: bool = combo_next_attack(current_attack)
	if dequeued_attack:
		state_owner.deactivate_attack_area()

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
	state_owner.animated_sprite.play("ground_combo_A_A")
	state_owner.velocity.x = state_owner.forward_direction_h * DEFAULT_H_THURST*2
	sword_whoosh.play()
	return true

func start_attack_B() -> bool:
	state_owner.animated_sprite.play("ground_combo_A_B")
	state_owner.velocity.x = state_owner.forward_direction_h * DEFAULT_H_THURST
	sword_whoosh.play()
	return true
	
func start_attack_C() -> bool:
	state_owner.animated_sprite.play("ground_combo_A_C")
	state_owner.velocity.x = -state_owner.forward_direction_h * DEFAULT_H_THURST/10
	sword_whoosh.play()
	return true

func _on_animation_finished():
	super._on_animation_finished()
	state_owner.deactivate_attack_area()
	change_state()
	
#func _on_last_attack_lag_timeout():
	#super._on_last_attack_lag_timeout()
	#
	#var was_combo_continued: bool = try_continue_combo()
	#if not was_combo_continued:
	
func _on_last_frame(animated_sprite: AnimatedSprite2D):
	super._on_last_frame(animated_sprite)
	state_owner.velocity.x = 0
	
	state_owner.activate_attack_area()
	
	#var is_animated_backward: bool = animated_sprite.(animated_sprite.animation)
	#last_attack_lag.start(animated_sprite.frame_progress < 0.5)
		
	
func change_state() -> String:
	var current_state_name: String = state_owner.state_machine.current_state.name.to_lower()
	
	if fall_state_triggered():
		switch_state(StateMachine.FALL)
		return StateMachine.FALL
	
	if current_state_name != StateMachine.WALK:
		switch_state(StateMachine.WALK)
		return StateMachine.WALK
	
	if state_owner.ninja_controller.get_input_direction_h() == 0 and state_owner.velocity.x == 0 and current_state_name != StateMachine.IDLE:
		switch_state(StateMachine.IDLE)
		return StateMachine.IDLE
	
	return ""
