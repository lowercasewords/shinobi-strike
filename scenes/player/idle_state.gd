class_name IdleState extends GroundedState

func enter() -> void:
	# Play idle animation here if you have one
	if not player.is_node_ready():
		await player.ready
	player.animated_sprite.play("idle")

func physics_update(_delta: float) -> void:
	var transitioned_via_grounded: bool = check_grounded_transitions()
