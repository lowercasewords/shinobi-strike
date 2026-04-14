class_name WallSlideV extends WallState

const SLIDE_GRAVITY: float = 30.0     # How fast they accelerate downwards once sliding
const SLIDE_GAVITY_HASTE: float = SLIDE_GRAVITY*10
const MAX_SLIDE_SPEED: float = 200.0   # The terminal velocity of the slide
const MAX_SLIDE_SPEED_HASTE: float = MAX_SLIDE_SPEED*1.1   # The terminal velocity of the slide

var slide_gravity: float = SLIDE_GRAVITY
var max_slide_speed: float = MAX_SLIDE_SPEED

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	if player.direction_v < 0:
		slide_gravity = SLIDE_GAVITY_HASTE
		max_slide_speed = MAX_SLIDE_SPEED_HASTE
	else:
		slide_gravity = SLIDE_GRAVITY
		max_slide_speed = MAX_SLIDE_SPEED
		
	player.velocity.y = move_toward(player.velocity.y, max_slide_speed, slide_gravity * _delta)
	
	var wall_direction: float = sidewalls_collision_direction()
	if player.is_on_floor():
		transitioned.emit(self, StateMachine.LAND)
	elif wall_direction == 0:
		transitioned.emit(self, StateMachine.FALL)
	elif player.is_jumping:
		transitioned.emit(self, StateMachine.WALLJUMPV)
	elif player.direction == wall_direction:
		transitioned.emit(self, StateMachine.WALLCLINGV)
	

func enter() -> void:
	player.animated_sprite.play("wall_slide_v")
