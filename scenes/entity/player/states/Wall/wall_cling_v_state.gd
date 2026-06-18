class_name WallClingVState extends WallState

const CLING_FRICTION = 10000.0    # How aggressively the wall eats their momentum

@onready var cling_timer: Timer = $Timer
@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

#func _ready():
	#cling_timer.connect("timeout", _on_cling_cling_timeout)
	
func enter():
	super.enter()
	var wall_direction: float = sidewalls_collision_direction()
	
	state_entity_owner.animated_sprite.play("wall_cling_v_windup")
	audio_stream.volume_db = randf_range(-5.0, 5.0)
	cling_timer.start()
	audio_stream.play()
	#state_entity_owner.overriden_direction(wall_direction)
	state_entity_owner.forward_direction_h = wall_direction

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	#var overriden_state: String = check_wall_transitions()
	var wall_direction: float = sidewalls_collision_direction()
	state_entity_owner.forward_direction_h = wall_direction
	
	state_entity_owner.velocity.y = move_toward(state_entity_owner.velocity.y, 0.0, CLING_FRICTION * _delta)
	
	# If not exited the wall state yet
	if check_default_exit(wall_direction) == "":
		
		if state_entity_owner.ninja_controller.get_input_pressing_jump():
			transitioned.emit(self, StateMachine.WALLJUMPV)
		elif cling_timer.is_stopped():
			if state_entity_owner.is_on_floor():
				transitioned.emit(self, StateMachine.LAND)
			elif state_entity_owner.ninja_controller.get_input_direction_h() == wall_direction:
				transitioned.emit(self, StateMachine.WALLRUNV)
			elif state_entity_owner.ninja_controller.get_input_direction_h() == -wall_direction:
				transitioned.emit(self, StateMachine.FALL)
			if state_entity_owner.ninja_controller.get_input_direction_h() == 0:
				transitioned.emit(self, StateMachine.WALLSLIDEV)

func _on_animation_finished():
	if state_entity_owner.animated_sprite.animation == "wall_cling_v_windup":
		state_entity_owner.animated_sprite.play("wall_cling_v")
