class_name IdleState extends State

func enter() -> void:
	super.enter()
	# Play idle animation here if you have one
	if not ninja_owner.is_node_ready():
		await ninja_owner.ready
	play_animation("idle")

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	allow_movement(_delta)
	
	if fall_state_triggered():
		switch_state(StateMachine.FALL)
	elif walk_state_triggered():
		switch_state(StateMachine.WALK)
	elif jump_state_triggered():
		switch_state(StateMachine.JUMP)
	elif attack_triggered():
		switch_state(StateMachine.ATTACK)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED

func on_owner_animation_finished(_animation_name: String) -> void:
	if (ninja_owner.animated_sprite.animation == "walk_windup"):
		play_animation("idle")
