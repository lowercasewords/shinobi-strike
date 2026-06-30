class_name NinjaPlayer extends Ninja

const eradication_zoom: float = 1.2
const eradication_impact_zoom: float = eradication_zoom + 0.5

var current_eradication: Eradication

func initialite_eradication(overlapping_ninja_body: NinjaEnemy) -> void:
	global_position = overlapping_ninja_body.global_position
	velocity = Vector2.ZERO
	
	current_eradication = load("res://scenes/entity/player/states/Eradications/era_na.tres")
	
	play_animation("era_na")
	
	overlapping_ninja_body.get_obliterated(on_eradication_finished)

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
