class_name FallState extends AirborneState

const VERTICAL_FALL_SPEED_THRESHOLD: float = 5.0

func enter():
	super.enter()


func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	basic_movement(_delta, state_entity_owner.DEFAULT_SPEED)
	if check_airbone_transitions() == "":
		if abs(state_entity_owner.velocity.x) > VERTICAL_FALL_SPEED_THRESHOLD:
			if state_entity_owner.animated_sprite.animation != "fall":  
				state_entity_owner.animated_sprite.play("fall")
		elif state_entity_owner.animated_sprite.animation != "fall_vertical":
			state_entity_owner.animated_sprite.play("fall_vertical")
		
