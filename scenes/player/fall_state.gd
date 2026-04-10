class_name FallState extends AirboneState

const VERTICAL_FALL_SPEED_THRESHOLD: float = 5.0

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	if check_airbone_transitions() == "":
		if abs(player.velocity.x) > VERTICAL_FALL_SPEED_THRESHOLD:
			if player.animated_sprite.animation != "fall":  
				player.animated_sprite.play("fall")
		elif player.animated_sprite.animation != "fall_vertical":
			player.animated_sprite.play("fall_vertical")
		basic_movement(_delta, player.SPEED)
