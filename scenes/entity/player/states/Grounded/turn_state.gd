class_name TurnState extends State

const TURN_ACCELERATION = DEFAULT_GROUNDED_ACCELERATION*1.1
const TURN_FRICTION = DEFAULT_GROUNDED_FRICTION*1.1

@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

func enter() -> void:
	super.enter()
	# Changing walking get_input_direction_h() 
	ninja_owner.animated_sprite.play("turn")
	ninja_owner.velocity.x /= 10
	
	acceleration = TURN_ACCELERATION
	friction = TURN_FRICTION
	
func exit():
	super.exit()
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	if not ninja_owner.is_grounded:
		apply_gravity(_delta)
		
	allow_movement(_delta)
	
	# Turn sound
	if ninja_owner.animated_sprite.frame == 0 and not audio_stream.playing:
		audio_stream.volume_db = randf_range(5.0, 10.0)
		audio_stream.play()
		
	if jump_state_triggered():
		switch_state(StateMachine.JUMP)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED

func on_owner_animation_finished(animation_name: String) -> void:
	if walk_state_triggered():
		switch_state(StateMachine.WALK)
	elif idle_state_triggered():
		switch_state(StateMachine.IDLE)
