class_name IdleState extends State

func enter() -> void:
	super.enter()
	# Play idle animation here if you have one
	if not state_owner.is_node_ready():
		await state_owner.ready
	state_owner.animated_sprite.play("idle")

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	horizontal_movement(_delta)
	
	if not state_owner.is_grounded:
		apply_gravity(_delta)
	
	if fall_state_triggered():
		switch_state(StateMachine.FALL)
	elif walk_state_triggered():
		switch_state(StateMachine.WALK)
	elif jump_state_triggered():
		switch_state(StateMachine.JUMP)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED

func _on_animation_finished():
	if (state_owner.animated_sprite.animation == "walk_windup"):
		state_owner.animated_sprite.play("idle")
