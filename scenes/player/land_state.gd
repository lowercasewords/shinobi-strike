class_name LandState extends GroundedState

func enter() -> void:
	player.animated_sprite.play("land")
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	check_grounded_transitions()
	basic_movement(_delta, player.SPEED)
