class_name AirborneState extends State

# 1. Design your perfect jump in the Inspector
#@export var jump_height: float = 64.0 # e.g., Jump 2 tiles high (32x32 tiles)
#@export var jump_time_to_peak: float = 0.3 # Feels snappy and responsive
#
## 2. Let the engine calculate the perfect physics
#@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
#@onready var custom_gravity: float = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)

#func enter() -> void:
	## If we transitioned here because we pressed Jump in the Ground state:
	#if Input.is_action_just_pressed("ui_accept"):
		#player.velocity.y = jump_velocity

var AIRBONE_ACCELERATION = ACCELERATION*3
var AIRBONE_FRICTION = FRICTION/3

func wall_run_state_triggered():
	for i in player.get_slide_collision_count():
		var collision: KinematicCollision2D = player.get_slide_collision(i)
		var collider: Object = collision.get_collider()
		print(collision)
		# Check collision layer of the other object (e.g., layer 2)
		#if collider != null and collider.name == "TestWallBg" and collider.get_collision_layer_value(2):
			#return true
	return false

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	apply_gravity(_delta)
	
	friction = AIRBONE_FRICTION
	acceleration = AIRBONE_ACCELERATION

func exit():
	friction = FRICTION
	acceleration = ACCELERATION
	
func check_airbone_transitions() -> String:
	var current_state_name: String = player.state_machine.current_state.name.to_lower()

	if wall_run_state_triggered():
		transitioned.emit(self, StateMachine.WALLRUN)
		return StateMachine.WALLRUN
		
	if wall_cling_v_state_triggerd():
		transitioned.emit(self, StateMachine.WALLCLINGV)
		return StateMachine.WALLCLINGV
		
	if player.just_landed and current_state_name != StateMachine.LAND:
		transitioned.emit(self, StateMachine.LAND)
		return StateMachine.LAND
	
	if fall_state_triggered():
		transitioned.emit(self, StateMachine.FALL)
		return StateMachine.FALL
		
	return ""
