class_name WalkState extends GroundedState

#const MAX_SPEED: float = 300.0
var windup_movement = 100.0
@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

func enter() -> void:
	# Play walk animation here if you have one
	if player.state_machine.current_state.name == StateMachine.IDLE:
		player.animated_sprite.play("walk_windup")
	else:
		player.animated_sprite.play("walk")

func windup_finsh() -> void:
	if player.is_on_floor():
		player.animated_sprite.play("walk")
		
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	if player.animated_sprite.frame == 0 and not audio_stream.playing:
		audio_stream.volume_db = randf_range(-5.0, 1.0)
		audio_stream.play()

	# Scale the walking animation depending on the speed
	if player.animated_sprite.animation == "walk":
		var speed_ratio = max(abs(player.velocity.x) / player.SPEED, 0.5)
		player.animated_sprite.speed_scale = speed_ratio
	
	if wall_run_v_state_triggerd():
		transitioned.emit(self, StateMachine.WALLRUNV)
	else:
		# Stopping with a smooth animation
		var new_state: String = check_grounded_transitions()
		if new_state == StateMachine.IDLE:
			player.animated_sprite.play_backwards("walk_windup")
		
	basic_movement(_delta, player.SPEED)

func _on_animation_finished():
	if player.state_machine.current_state.name.to_lower() == StateMachine.WALK and player.animated_sprite.animation == "walk_windup":
		windup_finsh()
