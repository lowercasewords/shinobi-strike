class_name WallJumpVState extends State

const JUMP_SPEED_INITIAL: Vector2 = Vector2(-200, -400)
const JUMP_ACCELERATION: float = DEFAULT_AIRBONE_ACCELERATION/2
const JUMP_FRICTION: float = DEFAULT_AIRBONE_FRICTION/3

const MARIO_JUMP_STRENGTH: float = -4
@onready var mario_jump_timer: Timer = $Timer

func enter():
	super.enter()
	
	friction = JUMP_FRICTION
	acceleration = JUMP_ACCELERATION
	
	var input_direction_h = sidewalls_collision_direction()
	if not ninja_owner.state_machine.current_state is WallJumpVState:
		ninja_owner.animated_sprite.play("wall_jump_v_windup")
	elif abs(input_direction_h) == 1:
		jump_off_the_wall(-input_direction_h)

#func exit():
	#jump_off_the_wall(-ninja_owner.ninja_controller.get_input_direction_h())

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	allow_movement(_delta)
	
	apply_gravity(_delta)
	
	mario_jump_update(_delta, mario_jump_timer, MARIO_JUMP_STRENGTH)
	
	var input_direction_h = sidewalls_collision_direction()
	if ninja_owner.is_on_floor():
		switch_state(StateMachine.LAND)
	if abs(input_direction_h) == 1:
		if ninja_owner.ninja_controller.get_input_pressing_jump():
			jump_off_the_wall(-input_direction_h)
		else:
			switch_state(StateMachine.WALLCLINGV)

func jump_off_the_wall(input_direction_h: float):
	mario_jump_timer.start()
	ninja_owner.animated_sprite.play("wall_jump_v")
	ninja_owner.velocity.x = JUMP_SPEED_INITIAL.x * -input_direction_h
	ninja_owner.velocity.y = JUMP_SPEED_INITIAL.y

func _on_animation_finished():
	var input_direction_h = sidewalls_collision_direction()
	if ninja_owner.animated_sprite.animation == "wall_jump_v_windup" and abs(input_direction_h) == 1:
		jump_off_the_wall(-input_direction_h)
