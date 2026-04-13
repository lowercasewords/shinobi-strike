class_name WallSlideV extends WallState

const SLIDE_GRAVITY = 30     # How fast they accelerate downwards once sliding
const MAX_SLIDE_SPEED = 200.0   # The terminal velocity of the slide

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	player.velocity.y = move_toward(player.velocity.y, MAX_SLIDE_SPEED, SLIDE_GRAVITY * _delta)
	
	var wall_direction: float = sidewalls_collision_direction()
	if player.is_on_floor():
		transitioned.emit(self, StateMachine.LAND)
	elif player.direction == wall_direction:
		transitioned.emit(self, StateMachine.WALLCLINGV)

func enter() -> void:
	player.animated_sprite.play("wall_slide_v")
