class_name WallRunState extends State

func enter():
	super.enter()
	ninja_owner.animated_sprite.play("wall_run")
	ninja_owner.coyote_timer.stop()

func exit():
	super.exit()
	ninja_owner.coyote_timer.stop()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	ninja_owner.velocity.y = 0

	if not ninja_owner.just_entered_wallbg or not ninja_owner.ninja_controller.get_input_pressing_jump():
		ninja_owner.coyote_timer.start()
		switch_state(StateMachine.FALL)
