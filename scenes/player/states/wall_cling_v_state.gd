class_name WallClingStateV extends WallState

const CLING_FRICTION = 900.0    # How aggressively the wall eats their momentum
const SLIDE_GRAVITY = 400.0     # How fast they accelerate downwards once sliding
const MAX_SLIDE_SPEED = 120.0   # The terminal velocity of the slide

@onready var cling_cling_timer: Timer = $Timer
@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

#func _ready():
	#cling_cling_timer.connect("timeout", _on_cling_cling_timeout)
	
func enter():
	player.animated_sprite.play("wall_cling_v_windup")
	audio_stream.volume_db = randf_range(-5.0, 5.0)
	cling_cling_timer.start()
	audio_stream.play()
	player.velocity.y /= 2

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	var wall_direction: float = sidewalls_collision_direction()
	
	#if cling_cling_timer.is_stopped():
	#if -player.direction != wall_direction:
		#transitioned.emit(self, StateMachine.FALL)
	player.velocity.y = move_toward(player.velocity.y, 0.0, CLING_FRICTION * _delta)
	
	if cling_cling_timer.is_stopped():
		if player.direction == 0:
			player.animated_sprite.play("wall_slide_v")
			player.velocity.y = min(player.velocity.y + (SLIDE_GRAVITY * _delta), MAX_SLIDE_SPEED)
		elif player.direction == wall_direction:
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

#func _on_cling_cling_timeout():
	#pass

func _on_animation_finished():
	if player.animated_sprite.animation == "wall_cling_v_windup":
		player.animated_sprite.play("wall_cling_v")
