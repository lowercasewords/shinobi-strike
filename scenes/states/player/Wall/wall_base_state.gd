## Base class for wall states providing shared wall mechanics
class_name WallBaseState extends State

const SPRITE_SHIFT_AMOUNT = -12
const WALL_RUN_SPEED: float = -200
const WALL_RUN_ACCELERATION: float = 400
const WALL_FRICTION: float = DEFAULT_GROUNDED_FRICTION/10

const SLIDE_GRAVITY: float = 200.0
const MAX_SLIDE_SPEED: float = 300.0

const JUMP_SPEED_INITIAL: Vector2 = Vector2(-200, -400)
const JUMP_ACCELERATION: float = DEFAULT_AIRBONE_ACCELERATION/2
const JUMP_FRICTION: float = DEFAULT_AIRBONE_FRICTION/3
const MARIO_JUMP_STRENGTH: float = -4

func set_physics_wallcrawl():
	friction = WALL_FRICTION
	acceleration = WALL_RUN_ACCELERATION
	max_speed = WALL_RUN_SPEED

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.WALLCRAWL

## Checks for universal rules to switch from wall states to other states
func check_wall_exit() -> bool:
	var wall_direction: int = get_wall_direction()
	var switched: bool = false
	
	if land_state_triggered():
		switch_state(StateMachine.LAND)
		switched = true
	elif wall_direction == 0 and sname != StateMachine.WALLJUMP:
		switch_state(StateMachine.JUMP)
		switched = true
	
	return switched
