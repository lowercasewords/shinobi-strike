class_name JumpState extends AirborneState

const JUMP_VELOCITY_INITIAL_THURST = -300.0
#const MARIO_JUMP_TIME: float = 1
const MARIO_JUMP_STRENGTH: float = -8
@onready var mario_jump_timer: Timer = $Timer

func enter() -> void:
	super.enter()
	if check_grounded():
		player.animated_sprite.play("jump_windup")
	else:
		windup_finsh()
	
func windup_finsh() -> void:
	if check_grounded():
		mario_jump_timer.start()
		player.animated_sprite.play('jump')
		player.velocity.y = JUMP_VELOCITY_INITIAL_THURST

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	#player.velocity.y += player.gravity * _delta
	if not check_airbone_transitions():
		basic_movement(_delta, player.SPEED)
		
		mario_jump_update(_delta, mario_jump_timer, MARIO_JUMP_STRENGTH)

func _on_animation_finished():
	if player.animated_sprite.animation == 'jump_windup':
		windup_finsh()
