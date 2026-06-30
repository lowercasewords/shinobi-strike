class_name WallClingVState extends State

const CLING_FRICTION = 10000.0    # How aggressively the wall eats their momentum

## 
#@onready var cling_timer: Timer = $Timer
@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

#func _ready():
	#cling_timer.connect("timeout", _on_cling_cling_timeout)
	
func enter():
	super.enter()
	var wall_direction: float = sidewalls_collision_direction()
	
	ninja_owner.animated_sprite.play("wall_cling_v_windup")
	audio_stream.volume_db = randf_range(-5.0, 5.0)
	#cling_timer.start()
	audio_stream.play()
	#ninja_owner.overriden_direction(wall_direction)
	ninja_owner.forward_direction_h = int(wall_direction)

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	#var overriden_state: String = check_wall_transitions()
	
	ninja_owner.velocity.y = move_toward(ninja_owner.velocity.y, 0.0, CLING_FRICTION * _delta)

func _on_animation_finished():
	var wall_direction: int = sidewalls_collision_direction()
	var inpux_x: float = ninja_owner.ninja_controller.get_input_direction_h()
	var _pressing_jump: float = ninja_owner.ninja_controller.get_input_pressed_jump()
	
	ninja_owner.forward_direction_h = wall_direction
	
	if inpux_x != wall_direction:
		switch_state(StateMachine.WALLJUMPV)
	elif ninja_owner.is_on_floor():
		switch_state(StateMachine.LAND)
	elif inpux_x == wall_direction:
		switch_state(StateMachine.WALLRUNV)
	elif inpux_x == 0:
		switch_state(StateMachine.WALLSLIDEV)
	else:
		switch_state(StateMachine.FALL)
	#if animation_name == "wall_cling_v_windup":
		#ninja_owner.animated_sprite.play("wall_cling_v")
