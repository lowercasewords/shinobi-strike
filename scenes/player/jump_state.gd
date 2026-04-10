class_name JumpState extends AirboneState

func enter() -> void:
	player.animated_sprite.play("jump_windup")
	player.animated_sprite.animation_finished.connect(windup_finsh)
	
func windup_finsh() -> void:
	player.animated_sprite.play('jump')
	player.velocity.y += player.JUMP_VELOCITY

func physics_update(_delta: float) -> void:
	if not check_airbone_transitions():
		if player.just_landed:
			transitioned.emit(self, StateMachine.WALK)
