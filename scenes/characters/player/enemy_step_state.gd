class_name EnemyStepState extends AirborneState

const DEFAULT_JUMP_DELAY_TIME: float = 0.2

@export var jump_delay: Timer

func _ready():
	jump_delay = Timer.new()
	jump_delay.one_shot = true
	self.add_child(jump_delay)
	jump_delay.timeout.connect(_on_jump_delay_timeout)
	
func enter():
	super.enter()
	
	var ninja_player: NinjaPlayer = (ninja_owner as NinjaPlayer)
	var enemy_target: NinjaEnemy = null
	if ninja_player != null:
		enemy_target = ninja_player.get_enemy_step_target()
	
	if enemy_target != null:
		global_position_requested.emit(enemy_target.global_position + Vector2.UP * 8)
		gravity_requested.emit(0)
		velocity_requested.emit(Vector2.ZERO)
		animation_requested.emit("enemy_step")
		jump_delay.start(DEFAULT_JUMP_DELAY_TIME)
	# Switch back from the enemey step as no enemy was found
	else:
		switch_state(StateMachine.JUMP)

func _on_jump_delay_timeout():
	if ninja_owner.ninja_controller.get_input_pressing_jump():
		switch_state(StateMachine.JUMP)
	else:
		switch_state(StateMachine.IDLE)
