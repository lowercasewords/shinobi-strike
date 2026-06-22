class_name WallRunState extends State

func enter():
	super.enter()
	state_owner.animated_sprite.play("wall_run")
	state_owner.coyote_timer.stop()

func exit():
	super.exit()
	state_owner.coyote_timer.stop()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	state_owner.velocity.y = 0

	if not state_owner.just_entered_wallbg or not state_owner.ninja_controller.get_input_pressing_jump():
		state_owner.coyote_timer.start()
		switch_state(StateMachine.FALL)
