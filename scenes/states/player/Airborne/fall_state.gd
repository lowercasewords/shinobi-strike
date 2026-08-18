class_name FallState extends State

const VERTICAL_FALL_SPEED_THRESHOLD: float = 5.0

func enter():
	super.enter()
	
	
	#else:
		#play_fall_animation()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	allow_movement(_delta)
	apply_gravity(_delta)
	
	
	if wall_state_triggered():
		switch_state(StateMachine.WALLCLING)
	elif land_state_triggered():
		switch_state(StateMachine.LAND)
		
func play_fall_animation() -> void:
	var animation: String = ninja_owner.animation_player.current_animation
	if abs(ninja_owner.velocity.x) > VERTICAL_FALL_SPEED_THRESHOLD:
		if animation != "fall":
			ninja_owner.animation_player.play("fall")
	else:
		if animation != "fall_v":
			ninja_owner.animation_player.play("fall_v")
			
func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.AIRBORNE
