class_name IdleState extends GroundedState

func enter() -> void:
	# Play idle animation here if you have one
	if not player.is_node_ready():
		await player.ready
	player.animated_sprite.play("idle")

func physics_update(_delta: float) -> void:
	check_grounded_transitions()

func _on_animation_finished():
	if player.state_machine.current_state.name.to_lower() == StateMachine.IDLE and (player.animated_sprite.animation == "walk_windup"):
		player.animated_sprite.play("idle")
