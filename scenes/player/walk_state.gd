class_name WalkState extends GroundedState

func enter() -> void:
	# Play walk animation here if you have one
	player.animated_sprite.play("walk")

func physics_update(_delta: float) -> void:
	if not check_grounded_transitions():
		basic_movement(player.SPEED)
		if player.velocity.x == 0:
			transitioned.emit(self, StateMachine.IDLE)
