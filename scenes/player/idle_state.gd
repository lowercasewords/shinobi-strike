class_name IdleState extends State

@onready var player: Player = owner 

func enter() -> void:
	# Play idle animation here if you have one
	if not player.is_node_ready():
		await player.ready
	player.animated_sprite.play("idle")

func physics_update(_delta: float) -> void:
	# Handle Transitions
	if not player.is_on_floor():
		#transitioned.emit(self, "fall")
		pass
		
	elif Input.is_action_just_pressed("ui_accept"):
		#transitioned.emit(self, "jump")
		pass
		
	elif player.direction != 0:
		transitioned.emit(self, StateMachine.WALK)
