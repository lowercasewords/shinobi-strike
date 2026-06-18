class_name IdleState extends GroundedState

func enter() -> void:
	super.enter()
	# Play idle animation here if you have one
	if not state_entity_owner.is_node_ready():
		await state_entity_owner.ready
	state_entity_owner.animated_sprite.play("idle")

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	check_grounded_transitions()

func _on_animation_finished():
	if state_entity_owner.state_machine.current_state.name.to_lower() == StateMachine.IDLE and (state_entity_owner.animated_sprite.animation == "walk_windup"):
		state_entity_owner.animated_sprite.play("idle")
