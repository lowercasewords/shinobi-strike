class_name JumpState extends State

#const MARIO_JUMP_TIME: float = 1
const MARIO_JUMP_STRENGTH: float = -8
@onready var mario_jump_timer: Timer = $Timer

func enter() -> void:
	super.enter()
	if state_owner.check_grounded():
		owner.animated_sprite.play("jump_windup")
	else:
		windup_finsh()
	
func windup_finsh() -> void:
	if state_owner.check_grounded():
		mario_jump_timer.start()
		owner.animated_sprite.play('jump')
		state_owner.velocity.y = DEFAULT_JUMP_THURST

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	
	horizontal_movement(delta)
	mario_jump_update(delta, mario_jump_timer, MARIO_JUMP_STRENGTH)
	apply_gravity(delta)
	
	if wall_cling_v_state_triggered():
		switch_state(StateMachine.WALLCLINGV)
	elif fall_state_triggered():
		switch_state(StateMachine.FALL)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.AIRBORNE
	
func _on_animation_finished():
	if state_owner.animated_sprite.animation == 'jump_windup':
		windup_finsh()
