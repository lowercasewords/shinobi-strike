class_name JumpState extends AirboneState

const JUMP_VELOCITY_INITIAL_THURST = -300.0
const MARIO_JUMP_TIME: float = 1
const MARIO_JUMP_STRENGTH: float = -8
var mario_jump_timer: Timer

func _init():
	mario_jump_timer = Timer.new()
	mario_jump_timer.one_shot = true
	self.add_child(mario_jump_timer)
	
func enter() -> void:
	if player.is_on_floor():
		player.animated_sprite.play("jump_windup")
	else:
		windup_finsh()
	
func windup_finsh() -> void:
	if player.is_on_floor():
		mario_jump_timer.start(MARIO_JUMP_TIME)
		player.animated_sprite.play('jump')
		player.velocity.y += JUMP_VELOCITY_INITIAL_THURST
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	#player.velocity.y += player.gravity * _delta
	if not check_airbone_transitions():
		basic_movement(_delta, player.SPEED)
		
		# Stop mario jump because player stopped holding jump button 
		if not player.is_jumping and mario_jump_timer.time_left > 0:
			mario_jump_timer.stop()
			mario_jump_timer.timeout.emit()
			
		# Mario jump is applied
		if not mario_jump_timer.is_stopped() and not player.is_on_floor():
			player.velocity.y += MARIO_JUMP_STRENGTH
	#print(player.velocity.y)

func _on_animation_finished():
	if player.animated_sprite.animation == 'jump_windup':
		windup_finsh()
