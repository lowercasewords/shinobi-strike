class_name NinjaPlayer extends Ninja

@export var mario_jump_timer: Timer

const eradication_zoom: float = 1.2
const eradication_impact_zoom: float = eradication_zoom + 0.5

const ERADICATIONS: Dictionary[String, Eradication] = {
	"era_ground_na": preload("res://scenes/states/player/Eradications/era_ground_na.tres"),
	"era_ground_nl": preload("res://scenes/states/player/Eradications/era_ground_nl.tres")
}

var current_eradication: Eradication

func _process(delta):
	super._process(delta)
	
func _physics_process(delta):
	super._physics_process(delta)
	
## Starts the process of eradicating (finish animation) the enemy 
func initialize_eradication(target_ninja: NinjaEnemy) -> void:
	## Body parts of the enemy
	var _body = target_ninja.body
	var eradication_animation: String = "era_ground"
	var eradication: Resource
	
	# Retrieve eradication data
	eradication_animation = get_animation_varied(eradication_animation, target_ninja)
	eradication = ERADICATIONS.get(eradication_animation)
	
	# If data found in the first place
	if eradication:
		set_animation(eradication_animation)
		
		# Align the player for the syncronous eradication animation with the enemy
		global_position = target_ninja.global_position
		velocity = Vector2.ZERO
		
		# Alert the enemy about the eradication
		target_ninja.get_eradicated(forward_direction_h, eradication_animation, eradication, on_eradication_finished)
	else:
		pass

func on_eradication_finished() -> void:
	camera.eradication_zoom_out()
	current_eradication = null
