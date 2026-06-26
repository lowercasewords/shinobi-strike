class_name WalkState extends State

#const MAX_SPEED: float = 300.0
var windup_movement = 100.0
@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

func enter() -> void:
	super.enter()
	var prev_state_name: String = ninja_owner.state_machine.psnameprev
	if prev_state_name == StateMachine.TURN:
		start_walking()
	else:
		start_windup()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)

	allow_movement(_delta)
	
	if not ninja_owner.is_grounded:
		apply_gravity(_delta)
	
	# Scale the walking animation depending on the speed
	if ninja_owner.animated_sprite.animation == "walk":
		var speed_ratio = max(abs(ninja_owner.velocity.x) / max_speed, 0.5)
		ninja_owner.animated_sprite.speed_scale = speed_ratio
	
	if ninja_owner.animated_sprite.frame == 0 and not audio_stream.playing:
		audio_stream.volume_db = randf_range(-5.0, 1.0)
		audio_stream.play()
	
	if combo_A_triggered():
		switch_state(StateMachine.ATTACK)
	elif fall_state_triggered():
		switch_state(StateMachine.FALL)
	elif jump_state_triggered():
		switch_state(StateMachine.JUMP)
	elif turn_state_triggered():
		switch_state(StateMachine.TURN)
	elif idle_state_triggered():
		switch_state(StateMachine.IDLE)
		ninja_owner.animated_sprite.play_backwards("walk_windup")
	#else:
		## Stopping with a smooth animation
		#var new_state: String = check_grounded_transitions()
		#if new_state == StateMachine.IDLE:
			#

func start_walking() -> void:
	ninja_owner.animated_sprite.play("walk")
func start_windup() -> void:
	ninja_owner.animated_sprite.play("walk_windup")
func end_windup() -> void:
	## Fired when the walk windup is finished
	if ninja_owner.is_on_floor():
		start_walking()
		
func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED

func on_owner_animation_finished(animation_name: String) -> void: 
	if animation_name == "walk_windup":
		end_windup()
