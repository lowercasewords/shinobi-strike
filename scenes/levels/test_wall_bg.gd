extends Sprite2D
@onready var area: Area2D = $Area2D

func _ready():
	if region_enabled:
		area.apply_scale(region_rect.size/16)
