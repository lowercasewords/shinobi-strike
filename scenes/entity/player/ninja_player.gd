class_name NinjaPlayer extends Ninja



func initialite_eradication(overlapping_ninja_body: NinjaEnemy) -> void:
	hide()
	#animation_player.sprite
	overlapping_ninja_body.get_obliterated(on_eradication_finished)


func on_eradication_finished() -> void:
	show()
	
#func _on_animation_finished():
	#show()
