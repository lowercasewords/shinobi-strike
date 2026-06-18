extends Area2D

func  _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	

func _on_body_entered(body: Node2D):
	if body is NinjaPlayer:
		var state_entity_owner: NinjaPlayer = body as NinjaPlayer
		state_entity_owner.area2d_enter.emit(self)
	
func _on_body_exited(body: Node2D):
	if body is NinjaPlayer:
		var state_entity_owner: NinjaPlayer = body as NinjaPlayer
		state_entity_owner.area2d_exit.emit(self)
