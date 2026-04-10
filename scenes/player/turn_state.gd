class_name TurnState extends GroundedState

const TURN_ACCELERATION = ACCELERATION
const TURN_SPEED_THRESHOLD = 10

func enter() -> void:
	# Changing walking direction 
	player.animated_sprite.play("turn")
	player.velocity.x /= 2
	
func exit():
	acceleration = ACCELERATION
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	# While turning
	if player.animated_sprite.animation == "turn" and player.animated_sprite.is_playing():
		# Friction is adjusted during turning
		acceleration = TURN_ACCELERATION
		
		if jump_state_triggered():
			transitioned.emit(self, StateMachine.JUMP)
	# Done with turning
	else:
		check_grounded_transitions()
	
	basic_movement(_delta, player.SPEED)
