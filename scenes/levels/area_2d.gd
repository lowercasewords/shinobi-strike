extends Area2D

func  _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	

func _on_body_entered(body: Node2D):
	if body is Player:
		var player: Player = body as Player
		player.area2d_enter.emit(self)
	
func _on_body_exited(body: Node2D):
	if body is Player:
		var player: Player = body as Player
		player.area2d_exit.emit(self)
