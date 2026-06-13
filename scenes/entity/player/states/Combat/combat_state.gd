class_name ComboState extends State

const DEFAULT_INPUT_WINDOW_TIME = 1

# While input window timer is playing, the current combo can be extended with an attack
@onready var input_window: Timer = $Timer

func enter() -> void:
	super.enter()
	if not input_window.timeout.is_connected(_on_input_window_timeout):
		input_window.timeout.connect(_on_input_window_timeout)
	
func exit() -> void:
	super.exit()
	if input_window.timeout.is_connected(_on_input_window_timeout):
		input_window.timeout.disconnect(_on_input_window_timeout)

func _on_input_window_timeout():
	pass
