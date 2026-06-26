class_name FallState extends State

const VERTICAL_FALL_SPEED_THRESHOLD: float = 5.0

func enter():
	super.enter()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	allow_movement(_delta)
	apply_gravity(_delta)
	
	play_fall_animation()

	if wall_cling_v_state_triggered():
		switch_state(StateMachine.WALLCLINGV)
	elif land_state_triggered():
		switch_state(StateMachine.LAND)
		
func play_fall_animation() -> void:
	var animation: String = ninja_owner.animated_sprite.animation
	if abs(ninja_owner.velocity.x) > VERTICAL_FALL_SPEED_THRESHOLD:
		if animation != "fall":
			ninja_owner.animated_sprite.play("fall")
	else:
		if animation != "fall_vertical":
			ninja_owner.animated_sprite.play("fall_vertical")
			
func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.AIRBORNE
