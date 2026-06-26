class_name JumpState extends State

#const MARIO_JUMP_TIME: float = 1
const MARIO_JUMP_STRENGTH: float = -8
@onready var mario_jump_timer: Timer = $Timer

func enter() -> void:
	super.enter()
	if ninja_owner.check_grounded():
		play_animation("jump_windup")
	else:
		windup_finsh()
	
func windup_finsh() -> void:
	if ninja_owner.check_grounded():
		mario_jump_timer.start()
		play_animation('jump')
		ninja_owner.velocity.y = DEFAULT_JUMP_THURST

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	
	allow_movement(delta)
	mario_jump_update(delta, mario_jump_timer, MARIO_JUMP_STRENGTH)
	apply_gravity(delta)
	
	if wall_cling_v_state_triggered():
		switch_state(StateMachine.WALLCLINGV)
	elif fall_state_triggered():
		switch_state(StateMachine.FALL)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.AIRBORNE
	
func on_owner_animation_finished(animation_name: String) -> void:
	if ninja_owner.animated_sprite.animation == 'jump_windup':
		windup_finsh()
