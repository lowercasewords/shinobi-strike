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
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	apply_gravity(_delta)
	
	acceleration = AIRBONE_ACCELERATION
	
func check_airbone_transitions() -> String:
	var current_state_name: String = player.state_machine.current_state.name.to_lower()

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
