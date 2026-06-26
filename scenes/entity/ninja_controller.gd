## Collects the inputs to be used to control an arbitrary entity (such as ninja owner or enemy bots)
class_name NinjaController extends Node2D

## Error message for a non-overriden input function
const UNIMPLEMENTED_ERROR: String = "Input Not implemented! Function must be overridden."

var attack_input_buffer: Array[AttackState.ATTACK_TYPE]

var _input_direction_h: float = 0.0
var _input_direction_v: float = 0.0
var _input_pressing_jump: bool = false
var _input_pressed_jump: bool = false
var _input_pressed_light_attack: bool = false
var _input_pressed_heavy_attack: bool = false

func get_input_direction_h() -> float: 
	## The normalized horizontal input direction of this entity (between -1.0 <-> left and 1.0 <-> right)
	return _input_direction_h
func get_input_direction_v() -> float: 
	## The normalized vertical input direction of this entity (between -1.0 <-> up and 1.0 <-> down)
	return _input_direction_v
func get_input_pressing_jump() -> bool: 
	## Does this entity input the jump button continuously during this tic?
	return _input_pressing_jump
func get_input_pressed_jump() -> bool: 
	## Does this entity just input the jump button this tic?
	return _input_pressed_jump
func get_input_pressed_light_attack() -> bool: 
	## Did this entity just input the light attack this tic?
	return _input_pressed_light_attack
func get_input_pressed_heavy_attack() -> bool: 
	## Did this entity just input the light attack this tic?
	return _input_pressed_heavy_attack

func set_input_direction_h() -> void: 
	return raise_unimplemented()
func set_input_direction_v() -> void: 
	return raise_unimplemented()
func set_input_pressing_jump() -> void: 
	return raise_unimplemented()
func set_input_pressed_jump() -> void: 
	return raise_unimplemented()
func set_input_pressed_light_attack() -> void: 
	return raise_unimplemented()
func set_input_pressed_heavy_attack() -> void: 
	return raise_unimplemented()

func ready() -> void:
	## NON-SIGNAL, i.e must be manually invoked by Entity Script
	## Entering the scene tree, simulating `_ready` signal handler
	pass

func process(delta):
	## NON-SIGNAL, i.e must be manually invoked by Entity Script
	## Every tic processing, simulating `_process` signal handler
	set_input_direction_h()
	set_input_direction_v()
	set_input_pressing_jump()
	set_input_pressed_jump()
	set_input_pressed_light_attack()
	set_input_pressed_heavy_attack()
	
func get_buffered_input() -> AttackState.ATTACK_TYPE:
	var current_attack: Variant = attack_input_buffer.pop_back()
	if current_attack == null:
		current_attack = AttackState.ATTACK_TYPE.UNKNOWN
	return current_attack

func exit() -> void:
	## NON-SIGNAL, i.e must be manually invoked by Entity Script
	## Exiting the scene tree, simulating `_exit_tree` signal handler
	pass
	
func raise_unimplemented(): 
	## Raises an error if the get function wasn't overriden by the sub-class
	push_error(UNIMPLEMENTED_ERROR)
