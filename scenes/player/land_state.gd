class_name LandState extends GroundedState

@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

func enter() -> void:
	player.animated_sprite.play("land")
	audio_stream.volume_db = randf_range(-5.0, 9.0)
	audio_stream.play()
	

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	if turn_state_triggered():
		transitioned.emit(self, StateMachine.TURN)
	elif jump_state_triggered():
		transitioned.emit(self, StateMachine.JUMP)
		
	basic_movement(_delta, player.SPEED)

func _on_animation_finished():
	if player.state_machine.current_state.name.to_lower() == StateMachine.LAND:
		if check_grounded_transitions() == "":
			# Just in case to not get stuck in this land state
			transitioned.emit(self, StateMachine.IDLE)
		
