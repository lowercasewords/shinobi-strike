class_name WallRunState extends WallState

func _ready():
	player.area2d_enter.connect(_on_wall_entered)
	player.area2d_exit.connect(_on_wall_exited)
	
func _on_wall_entered(area2d: Area2D):
	pass
func _on_wall_exited(area2d: Area2D):
	pass
