class_name WallSlideVState extends State

const SLIDE_GRAVITY: float = 30.0     # How fast they accelerate downwards once sliding
const SLIDE_GAVITY_HASTE: float = SLIDE_GRAVITY*10
const MAX_SLIDE_SPEED: float = 50.0   # The terminal velocity of the slide
const MAX_SLIDE_SPEED_HASTE: float = MAX_SLIDE_SPEED*4   # The terminal velocity of the slide

var slide_gravity: float = 0.0
var max_slide_speed: float = 0.0

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	var input_y: float = ninja_owner.ninja_controller.get_input_direction_v()
	
	slide_gravity = SLIDE_GRAVITY
	max_slide_speed = MAX_SLIDE_SPEED
		
	# NinjaPlayer wants the ninja_owner to go down
	if input_y < 0:
		slide_gravity = SLIDE_GAVITY_HASTE
		max_slide_speed = MAX_SLIDE_SPEED_HASTE
	# NinjaPlayer wants to stay in place
	else:
		# Stabilize the ninja_owner by reduce the falling speed
		if ninja_owner.velocity.y > MAX_SLIDE_SPEED:
			slide_gravity = SLIDE_GAVITY_HASTE	
		
	ninja_owner.velocity.y = move_toward(ninja_owner.velocity.y, max_slide_speed, slide_gravity * _delta)
	
	var wall_direction: float = sidewalls_collision_direction()
	if land_state_triggered():
		switch_state(StateMachine.LAND)
	elif wall_direction == 0:
		switch_state(StateMachine.FALL)
	elif ninja_owner.ninja_controller.get_input_pressing_jump():
		switch_state(StateMachine.WALLJUMPV)
	elif ninja_owner.ninja_controller.get_input_direction_h() == wall_direction:
		switch_state(StateMachine.WALLCLINGV)
	

func enter() -> void:
	super.enter()
	ninja_owner.animation_player.play("wall_slide_v")
