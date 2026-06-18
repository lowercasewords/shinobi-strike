class_name StateMachine extends Node2D

@export var initial_state: State

var current_state: State

const IDLE = "idlestate"
const WALK = "walkstate"
const JUMP = "jumpstate"
const LAND = "landstate"
const FALL = "fallstate"
const TURN = "turnstate"
const WALLRUN = "wallrunstate"
const WALLRUNV = "wallrunvstate"
const WALLJUMPV = "walljumpvstate"
const WALLCLINGV = "wallclingvstate"
const WALLSLIDEV = "wallslidevstate"
const GROUNDCOMBOA = "groundcomboastate"

######
#public state current_state;
# on update
#-> input ->
#switch state.run -> run()
######

# Mapping of state nodes to their string names
var states: Dictionary = {}

func start_state_machine() -> void:
	# Loop through all children and add them to the dictionary
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transitioned)
	
	# Get the first state
	if not initial_state:
		initial_state = get_children()[0]
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func on_child_transitioned(state: State, new_state_name: String) -> void:
	# Ignore if a state that isn't currently active tries to transition
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		push_warning("State not found: ", new_state_name)
		return
		
	# Clean up the old state, boot up the new one
	if current_state:
		current_state.exit()
		
	new_state.enter()
	current_state = new_state
