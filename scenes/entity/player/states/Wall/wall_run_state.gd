class_name WallRunState extends WallState

func enter():
	super.enter()
	state_entity_owner.animated_sprite.play("wall_run")
	state_entity_owner.coyote_timer.stop()

func exit():
	super.exit()
	state_entity_owner.coyote_timer.stop()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	state_entity_owner.velocity.y = 0

	if not state_entity_owner.just_entered_wallbg or not state_entity_owner.ninja_controller.get_input_pressing_jump():
		state_entity_owner.coyote_timer.start()
		transitioned.emit(self, StateMachine.FALL)
