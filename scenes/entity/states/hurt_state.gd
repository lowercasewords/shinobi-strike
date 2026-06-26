class_name HurtState extends State

func enter():
	super.enter()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	apply_friction(_delta)

func exit():
	super.exit()
	#switch_state(StateMachine.RECOVER)

func get_hurt(attack_node: ComboNode):
	if attack_node.arms_cut_chance == 1.0:
		play_animation("arms_chopped_off")
		apply_thrust(Vector2(200*ninja_owner.forward_direction_h, 0))
	else:
		play_animation("hurt_still")

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED

func on_owner_animation_finished(animation_name: String) -> void:
	switch_state(StateMachine.RECOVER)
