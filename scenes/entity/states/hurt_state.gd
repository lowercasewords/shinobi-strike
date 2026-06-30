class_name HurtState extends State

func enter():
	super.enter()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	apply_friction(_delta)

func exit():
	super.exit()

func get_hurt(attack_node: ComboNode):
	ninja_owner.get_hurt(attack_node)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED

func on_owner_animation_finished(_animation_name: String) -> void:
	switch_state(StateMachine.RECOVER)
