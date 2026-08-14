class_name IdleState extends State

func enter() -> void:
	super.enter()
	# Play idle animation here if you have one
	if not ninja_owner.is_node_ready():
		await ninja_owner.ready
		
	if abs(ninja_owner.velocity.x) > 0:
		ninja_owner.animation_player.play_backwards("walk_windup")
	else:
		set_animation("idle")
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	apply_gravity(_delta)
	allow_movement(_delta)
	
	if walk_state_triggered():
		switch_state(StateMachine.WALK)
	elif jump_state_triggered():
		switch_state(StateMachine.JUMP)
	elif attack_triggered():
		switch_state(StateMachine.ATTACK)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED

func on_owner_animation_finished(animation_name: String) -> void:
	if animation_name == "walk_windup":
		set_animation("idle")
