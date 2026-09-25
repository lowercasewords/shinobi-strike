class_name JumpState extends State

const MARIO_JUMP_STRENGTH: float = -8

func enter(args: Array) -> void:
	super.enter(args)
	
	var input_direction: int = int(ninja_owner.ninja_controller.get_input_direction_h())
	var _new_direction: int = update_forward_direction_h(input_direction)
	
	if ninja_owner.get_state_previous() is WallBaseState and not ninja_owner.get_state_current() is WallJumpState:
		set_animation("jump_curl")
	elif ninja_owner.get_state_previous() is EnemyStepState:
		set_animation("jump_windup")
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

## Returns true regardless whether there's a valid target to perform an enemy step on because such 
## enemy targed is checked and returned by the NinjaPlayer directly. This function just checks for inputs and positioning
func enemy_step_state_triggered() -> NinjaEnemy:
	var target = (owner as NinjaPlayer).get_enemy_step_target()
	return target
	
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
