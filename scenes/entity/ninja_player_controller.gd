## Collects state_entity_owner inputs to be used to control the Ninja Entity controlled by the Player
class_name NinjaPlayerController extends NinjaController

func get_input_direction_h() -> float:         return Input.get_axis("ui_left", "ui_right")
func get_input_direction_v() -> float:         return Input.get_axis("ui_down", "ui_up")
func get_input_pressing_jump() -> bool:        return Input.is_action_pressed("ui_accept")
func get_input_pressed_jump() -> bool:           return Input.is_action_just_pressed("ui_accept")
func get_input_pressed_light_attack() -> bool: return Input.is_action_just_pressed("light_attack")
func get_input_pressed_heavy_attack() -> bool: return Input.is_action_just_pressed("heavy_attack")
