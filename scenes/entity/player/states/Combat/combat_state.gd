class_name ComboState extends State

enum ATTACK_TYPE { LIGHT, HEAVY, UNKNOWN }

const LAST_ATTACK_LAG_TIME: float = 0.2

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
		
	if not player.animated_sprite.frame_changed.is_connected(_on_frame_changed):
		player.animated_sprite.frame_changed.connect(_on_frame_changed)
	
func exit() -> void:
	super.exit()
	if last_attack_lag.timeout.is_connected(_on_last_attack_lag_timeout):
		last_attack_lag.timeout.disconnect(_on_last_attack_lag_timeout)
		
	if player.animated_sprite.frame_changed.is_connected(_on_frame_changed):
		player.animated_sprite.frame_changed.disconnect(_on_frame_changed)
	
	attack_input_buffer.clear()
		
func pop_attack() -> ATTACK_TYPE:
	"""
	Pop the Attack Input (Light/Heavy) from the player input buffer 
	and
	Push said Attack Input to the combo specific buffer
	"""
	var popped_attack: ATTACK_TYPE = ATTACK_TYPE.UNKNOWN
	if player.attack_input_buffer.size() > 0:
		popped_attack = player.attack_input_buffer.pop_back()
	if popped_attack == null:
		popped_attack = ATTACK_TYPE.UNKNOWN
	
	attack_input_buffer.push_front(popped_attack)
	return popped_attack

func _on_last_attack_lag_timeout(): pass
func _on_frame_changed():
	var current_frame_index: int = player.animated_sprite.frame 
	var total_frames: int = player.animated_sprite.sprite_frames.get_frame_count(player.animated_sprite.animation)
	
	if current_frame_index == total_frames - 1:
		_on_last_frame(player.animated_sprite.animation)
	
	
func _on_last_frame(animation: String): 
	"""
	Called when the player reaches the last frame of the animation
	Args:
		animation (String): the name of the current animation
	"""
	pass
