## Collects the inputs to be used to control an arbitrary entity (such as ninja state_entity_owner or enemy bots)
class_name NinjaController extends Node2D

## Error message for a non-overriden input function
const UNIMPLEMENTED_ERROR: String = "Input Not implemented! Function must be overridden."

func get_input_direction_h() -> float: 
	## The normalized horizontal input direction of this entity (between -1.0 <-> left and 1.0 <-> right)
	return raise_unimplemented(0)
func get_input_direction_v() -> float: 
	## The normalized vertical input direction of this entity (between -1.0 <-> up and 1.0 <-> down)
	return raise_unimplemented(0)
func get_input_pressing_jump() -> bool: 
	## Does this entity input the jump button continuously during this tic?
	return raise_unimplemented(false)
func get_input_pressed_jump() -> bool: 
	## Does this entity just input the jump button this tic?
	return raise_unimplemented(false)
func get_input_pressed_light_attack() -> bool: 
	## Did this entity just input the light attack this tic?
	return raise_unimplemented(false)
func get_input_pressed_heavy_attack() -> bool: 
	## Did this entity just input the light attack this tic?
	return raise_unimplemented(false)

func ready() -> void:
	## NON-SIGNAL, i.e must be manually invoked by Entity Script
	## Entering the scene tree, simulating `_ready` signal handler
	pass

func exit() -> void:
	## NON-SIGNAL, i.e must be manually invoked by Entity Script
	## Exiting the scene tree, simulating `_exit_tree` signal handler
	pass
	
func raise_unimplemented(value): 
	## Raises an error if the get function wasn't overriden by the sub-class
	push_error(UNIMPLEMENTED_ERROR)
	return value
