class_name NinjaPlayer extends Ninja

signal area2d_enter(area2d: Area2D)
signal area2d_exit(area2d: Area2D)

# get_input_direction_h() overrides requested by external sources (such as the states) 

func _ready():
	super._ready()
	#area2d_enter.connect(_on_wall_entered)
	#area2d_exit.connect(_on_wall_exited)
