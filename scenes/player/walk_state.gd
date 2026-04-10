class_name WalkState extends GroundedState

const TURN_ACCELERATION = ACCELERATION*3
const TURN_SPEED_THRESHOLD = 10
#const MAX_SPEED: float = 300.0
var windup_movement = 100.0

func enter() -> void:
	# Play walk animation here if you have one
	player.animated_sprite.play("walk_windup")

func windup_finsh() -> void:
	if player.is_on_floor():
		player.animated_sprite.play("walk")
		
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)

	# Scale the walking animation depending on the speed
	if player.animated_sprite.animation == "walk":
		var speed_ratio = max(abs(player.velocity.x) / player.SPEED, 0.5)
		player.animated_sprite.speed_scale = speed_ratio
	
	# Changing walking direction 
	if player.just_changed_directions and abs(player.velocity.x) > TURN_SPEED_THRESHOLD/3:
		player.animated_sprite.play("walk_turn")
		
	# Friction is adjusted during turning
	if player.animated_sprite.animation == "walk_turn" and player.animated_sprite.is_playing():
		acceleration = TURN_ACCELERATION
	else:
		acceleration = FRICTION
	
	# Stopping with a smooth animation
	var new_state: String = check_grounded_transitions()
	if new_state == StateMachine.IDLE:
		player.animated_sprite.play_backwards("walk_windup")
		
	basic_movement(_delta, player.SPEED)

func _on_animation_finished():
	if player.state_machine.current_state.name.to_lower() == StateMachine.WALK and (player.animated_sprite.animation == "walk_windup" or player.animated_sprite.animation == "walk_turn"):
		windup_finsh()
