class_name WalkState extends GroundedState

#const MAX_SPEED: float = 300.0
var windup_movement = 100.0
@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

func enter() -> void:
	super.enter()
	# Play walk animation here if you have one
	if state_entity_owner.state_machine.current_state.name.to_lower() == StateMachine.IDLE:
		state_entity_owner.animated_sprite.play("walk_windup")
	else:
		state_entity_owner.animated_sprite.play("walk")

func windup_finsh() -> void:
	if state_entity_owner.is_on_floor():
		state_entity_owner.animated_sprite.play("walk")
		
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	basic_movement(_delta, state_entity_owner.DEFAULT_SPEED)
	
	if state_entity_owner.animated_sprite.frame == 0 and not audio_stream.playing:
		audio_stream.volume_db = randf_range(-5.0, 1.0)
		audio_stream.play()

	# Scale the walking animation depending on the speed
	if state_entity_owner.animated_sprite.animation == "walk":
		var speed_ratio = max(abs(state_entity_owner.velocity.x) / state_entity_owner.DEFAULT_SPEED, 0.5)
		state_entity_owner.animated_sprite.speed_scale = speed_ratio
	
	#if wall_cling_v_state_triggerd():
		#transitioned.emit(self, StateMachine.WALLCLINGV)
	if not wall_cling_v_state_triggerd():
		# Stopping with a smooth animation
		var new_state: String = check_grounded_transitions()
		if new_state == StateMachine.IDLE:
			state_entity_owner.animated_sprite.play_backwards("walk_windup")
		
	

func _on_animation_finished():
	if state_entity_owner.state_machine.current_state.name.to_lower() == StateMachine.WALK and state_entity_owner.animated_sprite.animation == "walk_windup":
		windup_finsh()
