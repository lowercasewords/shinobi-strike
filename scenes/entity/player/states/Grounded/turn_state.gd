class_name TurnState extends GroundedState

const TURN_ACCELERATION = ACCELERATION*1.1

@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

func enter() -> void:
	super.enter()
	# Changing walking get_input_direction_h() 
	state_entity_owner.animated_sprite.play("turn")
	state_entity_owner.velocity.x /= 3
	
func exit():
	super.exit()
	acceleration = ACCELERATION
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	basic_movement(_delta, state_entity_owner.DEFAULT_SPEED)
	# Turn sound
	if state_entity_owner.animated_sprite.frame == 0 and not audio_stream.playing:
		audio_stream.volume_db = randf_range(5.0, 10.0)
		audio_stream.play()
		
	# While turning
	if state_entity_owner.animated_sprite.animation == "turn" and state_entity_owner.animated_sprite.is_playing():
		# Friction is adjusted during turning
		acceleration = TURN_ACCELERATION
		
		if jump_state_triggered():
			transitioned.emit(self, StateMachine.JUMP)
	# Done with turning
	else:
		check_grounded_transitions()
	
	
