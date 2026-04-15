class_name WallClingStateV extends WallState

const CLING_FRICTION = 10000.0    # How aggressively the wall eats their momentum

@onready var cling_timer: Timer = $Timer
@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

#func _ready():
	#cling_timer.connect("timeout", _on_cling_cling_timeout)
	
func enter():
	super.enter()
	var wall_direction: float = sidewalls_collision_direction()
	
	player.animated_sprite.play("wall_cling_v_windup")
	audio_stream.volume_db = randf_range(-5.0, 5.0)
	cling_timer.start()
	audio_stream.play()
	player.overriden_direction(wall_direction)

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	#var overriden_state: String = check_wall_transitions()
	var wall_direction: float = sidewalls_collision_direction()

	player.velocity.y = move_toward(player.velocity.y, 0.0, CLING_FRICTION * _delta)

	# If not exited the wall state yet
	if check_default_exit(wall_direction) == "":
		
		if player.is_jumping:
			transitioned.emit(self, StateMachine.WALLJUMPV)
		elif cling_timer.is_stopped():
			if player.is_on_floor():
				transitioned.emit(self, StateMachine.LAND)
			elif player.direction == wall_direction:
				transitioned.emit(self, StateMachine.WALLRUNV)
			elif player.direction == -wall_direction:
				transitioned.emit(self, StateMachine.FALL)
			if player.direction == 0:
				transitioned.emit(self, StateMachine.WALLSLIDEV)

func _on_animation_finished():
	if player.animated_sprite.animation == "wall_cling_v_windup":
		player.animated_sprite.play("wall_cling_v")
