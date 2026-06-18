## Collects bot inputs to be used to control the Ninja Entity controlled by the (enemy) bot
class_name NinjaEnemyController extends NinjaController


func get_input_direction_h() -> float:         return 0
func get_input_direction_v() -> float:         return 0
func get_input_pressing_jump() -> bool:        return false
func get_input_pressed_light_attack() -> bool: return false
func get_input_pressed_heavy_attack() -> bool: return false
