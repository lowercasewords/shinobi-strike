class_name WallRunVState extends WallState

const SPRITE_SHIFT_AMOUNT = -12
const WALL_RUN_SPEED: float = -200
const WALL_FRICTION: float = FRICTION/10

func enter() -> void:
	super.enter()
	var wall_direction = sidewalls_collision_direction()
	var sprites_shift_amount = SPRITE_SHIFT_AMOUNT
	
	# Account for one pixel of rotation
	if wall_direction < 0:
		sprites_shift_amount += 1
	state_entity_owner.animated_sprite.play("wall_run_v")
	state_entity_owner.velocity.y = WALL_RUN_SPEED
	state_entity_owner.animated_sprite.position.x = sprites_shift_amount * wall_direction
	
func exit() -> void:
	super.exit()
	state_entity_owner.animated_sprite.position.x = 0.0

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	var wall_direction = sidewalls_collision_direction()
	
	if check_default_exit(wall_direction) == "":
		if state_entity_owner.ninja_controller.get_input_pressing_jump():
			#state_entity_owner.velocity.x = 15*wall_direction
			transitioned.emit(self, StateMachine.WALLJUMPV)
		elif state_entity_owner.ninja_controller.get_input_direction_h() == 0:
			transitioned.emit(self, StateMachine.WALLCLINGV)
		elif state_entity_owner.ninja_controller.get_input_direction_h() == wall_direction:
			state_entity_owner.velocity.y = move_toward(state_entity_owner.velocity.y, 0, WALL_FRICTION * _delta)
			state_entity_owner.velocity.x = 0
	#else:
		#state_entity_owner.velocity.y = -305
		#state_entity_owner.velocity.x = 5*wall_direction
		#transitioned.emit(self, StateMachine.FALL)
