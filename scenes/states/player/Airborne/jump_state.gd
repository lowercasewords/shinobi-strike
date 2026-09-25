class_name JumpState extends State

const MARIO_JUMP_STRENGTH: float = -8

func enter() -> void:
	super.enter()
	
	var input_direction: int = int(ninja_owner.ninja_controller.get_input_direction_h())
	var _new_direction: int = update_forward_direction_h(input_direction)

	
	if ninja_owner.get_state_previous() is WallBaseState and not ninja_owner.get_state_current() is WallJumpState:
		set_animation("jump_curl")
	elif ninja_owner.is_grounded:
		set_animation("jump_windup")
	else:
		windup_finsh()

## Flexible grounded rules
func is_ninja_grounded_flex() -> bool:
	return ninja_owner.get_ninja_grounded() or ninja_owner.get_state_previous() is EnemyStepState

func windup_finsh() -> void:
	if is_ninja_grounded_flex():
		ninja_owner.mario_jump_timer.start()
		set_animation('jump')
		velocity_delta_requested.emit(Vector2(0, DEFAULT_JUMP_THURST - ninja_owner.velocity.y))

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	
	allow_movement(delta)
	mario_jump_update(delta, MARIO_JUMP_STRENGTH)
	apply_gravity(delta)
	
	match true:
		_ when enemy_step_state_triggered():
			switch_state(StateMachine.ENEMYSTEP)
		_ when wall_state_triggered():
			switch_state(StateMachine.WALLCLING)
		_ when land_state_triggered():
			switch_state(StateMachine.LAND)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.AIRBORNE
	
func on_owner_animation_finished(animation_name: String) -> void:
	match animation_name:
		'jump_windup':
			windup_finsh()
