class_name GroundedState extends State

#var coyote_timer: Timer
#func _ready():
	#coyote_timer = Timer.new()
	#self.add_child(coyote_timer)

func check_grounded_transitions() -> String:
	var current_state_name: String = player.state_machine.current_state.name.to_lower()
	
	if not player.is_on_floor() and current_state_name != StateMachine.FALL:
		transitioned.emit(self, StateMachine.FALL)
		return StateMachine.FALL
		
	if Input.is_action_just_pressed("ui_accept") and current_state_name != StateMachine.JUMP:
		transitioned.emit(self, StateMachine.JUMP)
		return StateMachine.JUMP
	
	# While landing, grounded states won't start
	if player.animated_sprite.animation != "land" or (player.animated_sprite.animation == "land" and not player.animated_sprite.is_playing()):
		if player.direction != 0 and current_state_name != StateMachine.WALK:
			transitioned.emit(self, StateMachine.WALK)
			#print(player.state_machidne.current_state)
			return StateMachine.WALK
		elif player.direction == 0 and player.velocity.x == 0 and current_state_name != StateMachine.IDLE:
			transitioned.emit(self, StateMachine.IDLE)
			return StateMachine.IDLE
	return ""
