class_name FallState extends AirboneState

func enter() -> void:
	# Play walk animation here if you have one
	player.animated_sprite.play("fall")

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	if not check_airbone_transitions():
		basic_movement(_delta, player.SPEED)
