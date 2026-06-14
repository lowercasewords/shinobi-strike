class_name ComboState extends State

enum ATTACK_TYPE { LIGHT, HEAVY, UNKNOWN }

const DEFAULT_INPUT_WINDOW_TIME: float = 0.2

# While input window timer is playing, the current combo can be extended with an attack
@onready var input_window: Timer = $Timer

var attack_input_buffer: Array[ATTACK_TYPE] = []

func enter() -> void:
	super.enter()
	if not input_window.timeout.is_connected(_on_input_window_timeout):
		input_window.timeout.connect(_on_input_window_timeout)
	
func exit() -> void:
	super.exit()
	if input_window.timeout.is_connected(_on_input_window_timeout):
		input_window.timeout.disconnect(_on_input_window_timeout)
	attack_input_buffer.clear()
		
func pop_attack() -> ATTACK_TYPE:
	var popped_attack: ATTACK_TYPE = player.attack_input_buffer.pop_back()
	if popped_attack == null:
		popped_attack = ATTACK_TYPE.UNKNOWN
	
	attack_input_buffer.push_front(popped_attack)
	return popped_attack

func _on_input_window_timeout():
	pass
