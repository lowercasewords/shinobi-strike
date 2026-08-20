class_name StateMachine extends Node2D

@export var initial_state: State

var state_current: State = null
## The name of the previous state
var state_previous: State = null

const IDLE = "idlestate"
const WALK = "walkstate"
const JUMP = "jumpstate"
const LAND = "landstate"
const TURN = "turnstate"
const WALLCLING = "wallclingstate"
const WALLSLIDE = "wallslidestate"
const WALLJUMP = "walljumpstate"
const WALLRUN = "wallrunstate"
const ATTACK = "attackstate"
const RECOVER = "recoverstate"
const HURT = "hurtstate"

######
#public state state_current;
# on update
#-> input ->
#switch state.run -> run()
######

# Mapping of state nodes to their string names
var states: Dictionary = {}

func _ready() -> void:
	_register_states()

func _register_states() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			var transition_handler := _on_transition_requested.bind(child)
			if not child.transition_requested.is_connected(transition_handler):
				child.transition_requested.connect(transition_handler)

func start_state_machine() -> void:
	_register_states()
	
	# Get the first state
	if not initial_state:
		initial_state = get_children()[0]
	
	if initial_state:
		initial_state.enter()
		state_current = initial_state
		set_state_current(state_current)

func process(delta: float) -> void:
	if state_current:
		state_current.update(delta)

func physics_process(delta: float) -> void:
	if state_current:
		state_current.physics_update(delta)

func transition_state(state: State, new_state_name: String) -> void:
	# Ignore if a state that isn't currently active tries to transition
	if state != state_current:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		push_warning("State not found: ", new_state_name)
		return
		
	# Clean up the old state, boot up the new one
	if state_current:
		state_current.exit()
		
	set_state_current(new_state)
	new_state.enter()

func _on_transition_requested(new_state_name: String, requesting_state: State) -> void:
	transition_state(requesting_state, new_state_name)

func set_state_current(new_state: State) -> void:
	state_previous = state_current
	state_current = new_state
