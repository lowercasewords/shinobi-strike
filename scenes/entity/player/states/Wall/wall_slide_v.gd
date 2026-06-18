class_name WallSlideVState extends WallState

const SLIDE_GRAVITY: float = 30.0     # How fast they accelerate downwards once sliding
const SLIDE_GAVITY_HASTE: float = SLIDE_GRAVITY*10
const MAX_SLIDE_SPEED: float = 50.0   # The terminal velocity of the slide
const MAX_SLIDE_SPEED_HASTE: float = MAX_SLIDE_SPEED*4   # The terminal velocity of the slide

var slide_gravity: float = SLIDE_GRAVITY
var max_slide_speed: float = MAX_SLIDE_SPEED

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	# NinjaPlayer wants the state_entity_owner to go down
	if state_entity_owner.ninja_controller.input_direction_v < 0:
		slide_gravity = SLIDE_GAVITY_HASTE
		max_slide_speed = MAX_SLIDE_SPEED_HASTE
	# NinjaPlayer wants to stay in place
	else:
		# Stabilize the state_entity_owner by reduce the falling speed
		if state_entity_owner.velocity.y > MAX_SLIDE_SPEED:
			slide_gravity = SLIDE_GAVITY_HASTE
		else:
			slide_gravity = SLIDE_GRAVITY
		max_slide_speed = MAX_SLIDE_SPEED
		
	state_entity_owner.velocity.y = move_toward(state_entity_owner.velocity.y, max_slide_speed, slide_gravity * _delta)
	
	var wall_direction: float = sidewalls_collision_direction()
	if state_entity_owner.is_on_floor():
		transitioned.emit(self, StateMachine.LAND)
	elif wall_direction == 0:
		transitioned.emit(self, StateMachine.FALL)
	elif state_entity_owner.ninja_controller.get_input_pressing_jump():
		transitioned.emit(self, StateMachine.WALLJUMPV)
	elif state_entity_owner.ninja_controller.get_input_direction_h() == wall_direction:
		transitioned.emit(self, StateMachine.WALLCLINGV)
	

func enter() -> void:
	super.enter()
	state_entity_owner.animated_sprite.play("wall_slide_v")
