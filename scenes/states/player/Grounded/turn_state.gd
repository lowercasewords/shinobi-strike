class_name TurnState extends State

const TURN_ACCELERATION = DEFAULT_GROUNDED_ACCELERATION*1.1
const TURN_FRICTION = DEFAULT_GROUNDED_FRICTION*1.1

@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

func enter() -> void:
	super.enter()
	
	# Changing walking get_input_direction_h() 
	var input_direction: int = int(ninja_owner.ninja_controller.get_input_direction_h())
	var _new_direction: int = update_forward_direction_h(input_direction)
	
	set_animation("walk_turn")
	velocity_requested.emit(Vector2(ninja_owner.velocity.x / 10, ninja_owner.velocity.y))
	
	acceleration = TURN_ACCELERATION
	friction = TURN_FRICTION
	
func exit():
	super.exit()
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	if not ninja_owner.is_grounded:
		apply_gravity(_delta)
		
	allow_movement(_delta)
	apply_gravity(_delta)
	
	# Turn sound
	#if ninja_owner.animation_player.started and not audio_stream.playing:
		#audio_stream.volume_db = randf_range(5.0, 10.0)
		#audio_stream.play()
		
	if jump_state_triggered():
		switch_state(StateMachine.JUMP)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED

func on_owner_animation_finished(_animation_name: String) -> void:
	if walk_state_triggered():
		switch_state(StateMachine.WALK)
	elif idle_state_triggered():
		switch_state(StateMachine.IDLE)
