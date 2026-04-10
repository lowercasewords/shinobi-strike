class_name WalkState extends GroundedState

var windup_movement = 100.0
func enter() -> void:
	# Play walk animation here if you have one
	player.animated_sprite.play("walk_windup")

func windup_finsh() -> void:
	if player.is_on_floor():
		player.animated_sprite.play("walk")
		
func physics_update(_delta: float) -> void:
	if player.just_changed_directions:
		player.animated_sprite.play("walk_turn")
	
	check_grounded_transitions()
	basic_movement(_delta, player.SPEED)

func _on_animation_finished():
	if player.animated_sprite.animation == "walk_windup" or player.animated_sprite.animation == "walk_turn":
		windup_finsh()
