class_name WalkState extends State

@onready var player: Player = owner 

func enter() -> void:
	# Play idle animation here if you have one
	player.animated_sprite.play("walk")

func physics_update(_delta: float) -> void:
	if player.direction:
		player.velocity.x = player.direction * player.SPEED
	else:
		# Smoothly slow down
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED * 0.1)
	if player.velocity.x == 0:
		transitioned.emit(self, StateMachine.IDLE)
