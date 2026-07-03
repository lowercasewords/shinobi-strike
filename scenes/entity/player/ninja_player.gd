class_name NinjaPlayer extends Ninja

const eradication_zoom: float = 1.2
const eradication_impact_zoom: float = eradication_zoom + 0.5

const ERADICATIONS: Dictionary[String, Eradication] = {
	"era_ground_na": preload("res://scenes/entity/player/states/Eradications/era_ground_na.tres"),
	"era_ground_nl": preload("res://scenes/entity/player/states/Eradications/era_ground_nl.tres")
}

var current_eradication: Eradication

func _process(delta):
	super._process(delta)
	
	var input_direction: int = ninja_controller.get_input_direction_h()
	if input_direction != forward_direction_h:
		set_forward_direction_h(input_direction)
	
## Starts the process of eradicating (finish animation) the enemy 
func initialize_eradication(target_ninja: NinjaEnemy) -> void:
	## Body parts of the enemy
	var body = target_ninja.body
	var eradication_animation: String = "era_ground"
	var eradication: Resource
	
	# Retrieve eradication data
	eradication_animation = get_animation_varied(eradication_animation, target_ninja)
	eradication = ERADICATIONS.get(eradication_animation)
	
	# If data found in the first place
	if eradication:
		play_animation(eradication_animation)
		
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

func _on_frame_changed():
	super._on_frame_changed()
	if current_eradication != null:
		if current_eradication.impact_frame_indecies.has(animated_sprite.frame):
			camera.eradication_zoom_in(eradication_impact_zoom)
		else:
			camera.eradication_zoom_in(eradication_zoom)
