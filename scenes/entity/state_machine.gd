class_name StateMachine extends Node2D

@export var initial_state: State

var current_state: State = null
## The name of the previous state
var psnameprev: String

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
	
	# Get the first state
	if not initial_state:
		initial_state = get_children()[0]
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state
		set_current_state(current_state)

func process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func transition_state(state: State, new_state_name: String) -> void:
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
		
	set_current_state(new_state)
	new_state.enter()

func set_current_state(new_state: State) -> void:
	var current_state_name: String = current_state.name.to_lower()
	var new_state_name: String = new_state.name.to_lower()
	
	psnameprev = current_state_name
	current_state = new_state
	current_state.sname = new_state_name
