class_name WallState extends State

enum Substate {
	CLING,
	SLIDE,
	JUMP,
	RUN
}

const CLING_FRICTION = 10000.0    # How aggressively the wall eats their momentum

const SPRITE_SHIFT_AMOUNT = -12
const WALL_RUN_SPEED: float = -200
const WALL_RUN_ACCELERATION: float = 400

const WALL_FRICTION: float = DEFAULT_GROUNDED_FRICTION/10

const SLIDE_GRAVITY: float = 200.0     # How fast they accelerate downwards once sliding
#const SLIDE_GAVITY_HASTE: float = SLIDE_GRAVITY*10
const MAX_SLIDE_SPEED: float = 300.0   # The terminal velocity of the slide
#const MAX_SLIDE_SPEED_HASTE: float = MAX_SLIDE_SPEED*4   # The terminal velocity of the slide

const JUMP_SPEED_INITIAL: Vector2 = Vector2(-200, -400)
const JUMP_ACCELERATION: float = DEFAULT_AIRBONE_ACCELERATION/2
const JUMP_FRICTION: float = DEFAULT_AIRBONE_FRICTION/3

const MARIO_JUMP_STRENGTH: float = -4

#var slide_gravity: float = 20
#var max_slide_speed: float = 0.0

@onready var audio_stream: AudioStreamPlayer2D #$AudioStreamPlayer2D

var current_substate: Substate = Substate.CLING

func set_physics_wallcrawl():
	friction = WALL_FRICTION
	acceleration = WALL_RUN_ACCELERATION
	max_speed = WALL_RUN_SPEED

func enter():
	super.enter()
	#if get_state_space() == STATE_SPACE.WALLCRAWL:
	set_physics_wallcrawl()
	#max_speed = 500
	
	var has_clinged: bool = attempt_cling_v()

func exit():
	super.exit()

## Attempts to cling to the vertical wall
func attempt_cling_v(animation: String = "wall_cling_v") -> bool:
	
	var wall_direction: int = get_wall_direction()
	
	if wall_direction == 0:
		return false
	
	ninja_owner.animation_player.play(animation)
	update_forward_direction_h(-wall_direction)
	
	ninja_owner.velocity.x = 0
	ninja_owner.velocity.y /= 2
	
	current_substate = Substate.CLING
	
	return true
	
## Continues the jump after the windup
func continue_jump_v() -> bool:
	
	#set_animation("wall_jump_v")
	
	return true
	
## Attempts to perform a jump in the direction (left or right) on a vertical
func attempt_jump_v() -> bool:
	var wall_direction = get_wall_direction()
	
	if abs(wall_direction) != 1:
		return false
	
	update_forward_direction_h(-wall_direction)
	set_animation("wall_jump_windup_v")
	
	ninja_owner.mario_jump_timer.start()
	
	ninja_owner.velocity.x = JUMP_SPEED_INITIAL.x * ninja_owner.forward_direction_h
	ninja_owner.velocity.y = JUMP_SPEED_INITIAL.y
	
	current_substate = Substate.JUMP
	
	
	return true

## Attempts to perform a slide on a vertical wall
func attempt_slide_v() -> bool:
	set_animation("wall_slide_v")
	
	ninja_owner.velocity.y /= 2
	
	current_substate = Substate.SLIDE
	
	return true

## Attempts to perform a wall run on a vertical wall
func attempt_run_v() -> bool:
	#var sprites_shift_amount = SPRITE_SHIFT_AMOUNT
	var wall_direction: int = get_wall_direction()
	
	ninja_owner.velocity.y /= 2
	
	set_animation("wall_run_v")
	#ninja_owner.coyote_timer.stop()
	
	# Account for one pixel of rotation
	#if wall_direction < 0:
		#sprites_shift_amount += 1
	
	#ninja_owner.posi.x = sprites_shift_amount * wall_direction
	
	current_substate = Substate.RUN
	
	return true

## Physics during the jump on a vertical wall
func physics_jump_v(delta: float) -> void:
	var wall_direction: int = get_wall_direction()
	
	allow_movement(delta)
	mario_jump_update(delta, MARIO_JUMP_STRENGTH)
	apply_gravity(delta)

## Physics during the slide on a vertical wall
func physics_slide_v(_delta) -> void:
	var is_jump_triggered: bool = ninja_owner.ninja_controller.get_input_pressed_jump()
	var wall_direction: int = get_wall_direction()
	
	ninja_owner.velocity.y = clamp(move_toward(ninja_owner.velocity.y, MAX_SLIDE_SPEED, SLIDE_GRAVITY * _delta), 0, MAX_SLIDE_SPEED)

## Physics during the cling on a vertical wall
func physics_cling_v(_delta) -> void:
	var input_x: float = ninja_owner.ninja_controller.get_input_direction_h()
	var started_sliding = false
	
	if not started_sliding:
		ninja_owner.velocity.y = 0
	
## Physics during the run on a vertical wall
func physics_run_v(_delta) -> void:
	var wall_direction: int = get_wall_direction()
	
	# Exited the wall
	if abs(wall_direction) != 1:
		ninja_owner.velocity.y = -250
		ninja_owner.velocity.x = 10
	# Running up the wall
	else:
		ninja_owner.velocity.y = move_toward(ninja_owner.velocity.y, WALL_RUN_SPEED, WALL_RUN_ACCELERATION * _delta)
		ninja_owner.velocity.x = 0

## Checks for universal rules to switch from the wall state
func default_state_switch() -> bool:
	var wall_direction: int = get_wall_direction()
	var switched: bool = true
	
	if land_state_triggered():
		switch_state(StateMachine.LAND)
	elif wall_direction == 0 and current_substate != Substate.JUMP:
		switch_state(StateMachine.JUMP)
	else:
		switched = false
	
	return switched

## Check for wall substate switches and immediately switch if available
func wall_substate_switch() -> void:
	var wall_direction: int = get_wall_direction()
	
	if abs(wall_direction) != 1:
		return
		
	var input_x: float = ninja_owner.ninja_controller.get_input_direction_h()
	var input_space: bool = ninja_owner.ninja_controller.get_input_pressing_jump()
	
	var is_cling_input: bool = input_x == 0 and current_substate != Substate.CLING
	var is_jump_input: bool = input_space and current_substate != Substate.JUMP
	var is_run_input: bool = input_x == -wall_direction and current_substate != Substate.RUN
	var is_slide_input: bool = input_x == wall_direction and current_substate != Substate.SLIDE
	var is_jump_cling_triggered: bool = current_substate == Substate.JUMP
	
	var jump_clinged: bool = false
	var jumped: bool = false
	var slid: bool = false
	var ran: bool = false
	var clinged: bool = false
	var next: bool = false

	if is_jump_input and not next:
		jumped = attempt_jump_v()
		next = jumped
		
	if is_jump_cling_triggered and not next:
		jump_clinged = attempt_cling_v("wall_jump_cling_v")
		next = jump_clinged
		
	if current_substate != Substate.JUMP:
	
		if is_slide_input and not next:
			slid = attempt_slide_v()
			next = slid
			
		if is_run_input and not next:
			ran = attempt_run_v()
			next = ran
		
		if is_cling_input and not next:
			clinged = attempt_cling_v()
			next = clinged
		
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	match current_substate:
		Substate.RUN:
			physics_run_v(_delta)
		Substate.CLING:
			physics_cling_v(_delta)
		Substate.SLIDE:
			physics_slide_v(_delta)
		Substate.JUMP:
			physics_jump_v(_delta)
	
	# Check and try to switch off wall state first to some other state, otherwise check and try to switch off to a new wall substate
	if not default_state_switch():
		wall_substate_switch()
	
	#ninja_owner.velocity.y = move_toward(ninja_owner.velocity.y, 0.0, CLING_FRICTION * _delta)

func on_owner_animation_finished(_animation_name: String) -> void:
	#match current_substate:
		#Substate.CLING:
			#var _has_started_sliding = attempt_slide_v()
			
	#match _animation_name:
		#"wall_jump_windup_v":
				#continue_jump_v()
	pass
			

func get_state_space() -> STATE_SPACE:
	var state_space: STATE_SPACE
	
	match current_substate:
		Substate.JUMP:
			state_space = STATE_SPACE.AIRBORNE
		_:
			state_space = STATE_SPACE.WALLCRAWL
			
	return state_space
