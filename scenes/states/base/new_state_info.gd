class_name NewStateInfo extends GDScript

var new_state_name: String
var new_args: Array

func _init(new_state_name: String, new_args: Array):
	self.new_state_name = new_state_name
	self.new_args = new_args

func get_new_state_name() -> String : return new_state_name
func get_new_args() -> Array: return new_args
