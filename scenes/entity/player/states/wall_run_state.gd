class_name WallRunState extends WallState

func enter():
	super.enter()
	player.animated_sprite.play("wall_run")
	player.coyote_timer.stop()

func exit():
	super.exit()
	player.coyote_timer.stop()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	player.velocity.y = 0

	if not player.just_entered_wallbg or not player.is_jumping:
		player.coyote_timer.start()
		transitioned.emit(self, StateMachine.FALL)
