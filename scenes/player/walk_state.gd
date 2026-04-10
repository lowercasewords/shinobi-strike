class_name WalkState extends GroundedState



func enter() -> void:
	# Play walk animation here if you have one
	player.animated_sprite.play("walk")

func physics_update(_delta: float) -> void:
	if not check_grounded_transitions():
		if player.direction:
			player.velocity.x = player.direction * player.SPEED
		else:
			# Smoothly slow down
			player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED * 0.1)
			
		if player.velocity.x == 0:
			transitioned.emit(self, StateMachine.IDLE)
