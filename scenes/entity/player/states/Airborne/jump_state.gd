class_name JumpState extends AirborneState

const DEFAULT_JUMP_THURST = -300.0
#const MARIO_JUMP_TIME: float = 1
const MARIO_JUMP_STRENGTH: float = -8
@onready var mario_jump_timer: Timer = $Timer

func enter() -> void:
	super.enter()
	if check_grounded():
		state_entity_owner.animated_sprite.play("jump_windup")
	else:
		windup_finsh()
	
func windup_finsh() -> void:
	if check_grounded():
		mario_jump_timer.start()
		state_entity_owner.animated_sprite.play('jump')
		state_entity_owner.velocity.y = DEFAULT_JUMP_THURST

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	#state_entity_owner.velocity.y += state_entity_owner.gravity * _delta
	if not check_airbone_transitions():
		basic_movement(_delta, state_entity_owner.DEFAULT_SPEED)
		
		mario_jump_update(_delta, mario_jump_timer, MARIO_JUMP_STRENGTH)

func _on_animation_finished():
	if state_entity_owner.animated_sprite.animation == 'jump_windup':
		windup_finsh()
