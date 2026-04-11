class_name WallRunVState extends WallState

const SPRITE_SHIFT_AMOUNT = 12
const WALL_RUN_SPEED: float = -200

func enter() -> void:
	var wall_direction = sidewalls_collision_direction()
	var sprites_shift_amount = SPRITE_SHIFT_AMOUNT
	# Account for one pixel of rotation
	if wall_direction > 0:
		sprites_shift_amount += 1
	player.animated_sprite.play("wall_run_v")
	player.animated_sprite.position.x = sprites_shift_amount * wall_direction
	
func exit() -> void:
	player.animated_sprite.position.x = 0.0

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	var wall_direction = sidewalls_collision_direction()
	#if player.velocity.y == 0:
		#player.velocity.x = 5*wall_direction
		#transitioned.emit(self, StateMachine.FALL)
	#if player.is_jumping:
		#player.velocity.x = 15*wall_direction
		#transitioned.emit(self, StateMachine.JUMP)
	if player.is_on_wall() and -player.direction == wall_direction:
		player.velocity.y = WALL_RUN_SPEED
	else:
		player.velocity.y = -305
		player.velocity.x = 5*wall_direction
		transitioned.emit(self, StateMachine.FALL)
