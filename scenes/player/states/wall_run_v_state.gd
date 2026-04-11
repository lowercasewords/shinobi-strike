class_name WallRunVState extends WallState


func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	var wall_direction_horiz: float = 0
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		var normal = collision.get_normal()
		
		wall_direction_horiz = 1
		
	print(wall_direction_horiz)
	if player.is_on_wall() and player.direction != 0:
		transitioned.emit(self, StateMachine.WALLRUNV)
