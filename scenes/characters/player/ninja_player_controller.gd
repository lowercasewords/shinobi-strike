## Collects owner inputs to be used to control the Ninja Entity controlled by the Player
class_name NinjaPlayerController extends NinjaController

func set_input_direction_h() -> void:                    _input_direction_h = Input.get_axis("ui_left", "ui_right")
func set_input_direction_v() -> void:                    _input_direction_v = Input.get_axis("ui_down", "ui_up")
func set_input_pressing_jump() -> void:                _input_pressing_jump = Input.is_action_pressed("ui_accept")
func set_input_pressed_jump() -> void:                  _input_pressed_jump = Input.is_action_just_pressed("ui_accept")
func set_input_pressed_light_attack() -> void:  _input_pressed_light_attack = Input.is_action_just_pressed("light_attack")
func set_input_pressed_heavy_attack() -> void:  _input_pressed_heavy_attack = Input.is_action_just_pressed("heavy_attack")
