class_name WallClingStateV extends WallState

@onready var cling_fall_timer: Timer = $Timer
@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

func enter():
	player.animated_sprite.play("wall_cling_v_windup")
	audio_stream.volume_db = randf_range(-5.0, 5.0)
	audio_stream.play()
	player.velocity.y /= 2

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	var wall_direction: float = sidewalls_collision_direction()
	
	player.velocity.y = move_toward(player.velocity.y, 0, friction * _delta)
	
	#if -player.direction != wall_direction:
		#transitioned.emit(self, StateMachine.FALL)
	if player.animated_sprite.animation == "wall_cling_v":
		transitioned.emit(self, StateMachine.WALLRUNV)
	#elif not cling_fall_timer.is_stopped():
	
	## While in animation
	#elif player.animated_sprite.animation == "wall_cling_v":
		## While clinging
		#if not player.animated_sprite.is_playing():
			#if not cling_fall_timer.is_stopped():
				#if player.direction == wall_direction:
					#transitioned.emit(self, StateMachine.WALLRUNV)
				#else:
					## Slide down the wall while clinged
					#player.velocity.y /= 2
			#else:
				#transitioned.emit(self, StateMachine.FALL)
		## While clinged
		#else:
			#player.velocity.y = 0
			
func _on_animation_finished():
	if player.animated_sprite.animation == "wall_cling_v_windup":
		player.animated_sprite.play("wall_cling_v")
		cling_fall_timer.start()
