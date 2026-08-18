class_name HurtState extends State

func enter():
	super.enter()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	apply_friction(_delta)
	apply_gravity(_delta)

func exit():
	super.exit()

func apply_incoming_damage(attacker: Ninja, attack_node: ComboNode): 
	ninja_owner.apply_incoming_damage(attacker, attack_node)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED

func on_owner_animation_finished(_animation_name: String) -> void:
	switch_state(StateMachine.RECOVER)
