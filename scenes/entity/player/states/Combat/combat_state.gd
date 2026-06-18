class_name ComboState extends State

enum ATTACK_TYPE { LIGHT, HEAVY, UNKNOWN }

const LAST_ATTACK_LAG_TIME: float = 1

const DEFAULT_H_THURST: float = 50
const DEFAULT_V_THURST: float = 1.0

# While input window timer is playing, the current combo can be extended with an attack
@onready var last_attack_lag: Timer = $Timer

var attack_input_buffer: Array[ATTACK_TYPE] = []

func enter() -> void:
	super.enter()
	last_attack_lag.one_shot = true
	last_attack_lag.wait_time = LAST_ATTACK_LAG_TIME
	
	if not last_attack_lag.timeout.is_connected(_on_last_attack_lag_timeout):
		last_attack_lag.timeout.connect(_on_last_attack_lag_timeout)
		
	if not state_entity_owner.animated_sprite.frame_changed.is_connected(_on_frame_changed):
		state_entity_owner.animated_sprite.frame_changed.connect(_on_frame_changed)
	
func exit() -> void:
	super.exit()
	if last_attack_lag.timeout.is_connected(_on_last_attack_lag_timeout):
		last_attack_lag.timeout.disconnect(_on_last_attack_lag_timeout)
		
	if state_entity_owner.animated_sprite.frame_changed.is_connected(_on_frame_changed):
		state_entity_owner.animated_sprite.frame_changed.disconnect(_on_frame_changed)
	
	attack_input_buffer.clear()
	
	state_entity_owner.deactivate_attack_area()
		
func pop_attack() -> ATTACK_TYPE:
	"""
	Pop the Attack Input (Light/Heavy) from the state_entity_owner input buffer 
	and
	Push said Attack Input to the combo specific buffer
	"""
	var popped_attack: ATTACK_TYPE = ATTACK_TYPE.UNKNOWN
	var foo = state_entity_owner.attack_input_buffer
	
	if not state_entity_owner.attack_input_buffer.is_empty():
		popped_attack = state_entity_owner.attack_input_buffer.pop_back()
		
		if popped_attack == null:
			popped_attack = ATTACK_TYPE.UNKNOWN
		
		if popped_attack != ATTACK_TYPE.UNKNOWN:
			attack_input_buffer.push_front(popped_attack)
			
	return popped_attack

func _on_last_attack_lag_timeout(): pass
func _on_frame_changed():
	var current_frame_index: int = state_entity_owner.animated_sprite.frame 
	var total_frames: int = state_entity_owner.animated_sprite.sprite_frames.get_frame_count(state_entity_owner.animated_sprite.animation)
	
	if current_frame_index == total_frames - 1:
		_on_last_frame(state_entity_owner.animated_sprite)
	
	
func _on_last_frame(animation: AnimatedSprite2D): 
	"""
	Called when the state_entity_owner reaches the last frame of the animation
	Args:
		animated_sprite (AnimatedSprite2D): the animation sprite for which the last frame is tracked
	"""
	pass
