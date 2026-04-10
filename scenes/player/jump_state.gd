class_name JumpState extends AirboneState

func enter() -> void:
	player.animated_sprite.play("jump_windup")	
	
func windup_finsh() -> void:
	if player.is_on_floor():
		player.animated_sprite.play('jump')
		player.velocity.y += player.JUMP_VELOCITY
	
func physics_update(_delta: float) -> void:
	if not check_airbone_transitions():
		basic_movement(_delta, player.SPEED)
		
		if player.just_landed:
			transitioned.emit(self, StateMachine.WALK)
		
func _on_animation_finished():
	if player.animated_sprite.animation == 'jump_windup':
		windup_finsh()
		
