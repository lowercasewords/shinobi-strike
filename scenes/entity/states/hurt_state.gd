class_name HurtState extends State

const DISMEMBERED_PIECE_SCENE = preload("res://scenes/entity/enemies/DismemberedPiece.tscn")

func enter():
	super.enter()

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	apply_friction(_delta)

func exit():
	super.exit()

func get_hurt(attack_node: ComboNode):
	var chance: float = randf()
	
	var arms_chopped_chance: float = attack_node.arms_cut_chance
	var legs_chopped_chance: float = arms_chopped_chance + attack_node.legs_cut_chance
	var head_chopped_chance: float = legs_chopped_chance + attack_node.head_cut_chance
	
	if chance < arms_chopped_chance:
		play_animation("arms_chopped_off")
		chop_piece_off("sword", 1)
		
		chop_limb_off("arm", 1)
		chop_limb_off("arm", -1)
	else:
		play_animation("hurt_still")

func chop_piece_off(animation: String, direction: int = 1) -> DismemberedPiece:
	
	apply_thrust(Vector2(200*ninja_owner.forward_direction_h, 0))
	
	var linear_velocity: Vector2 = Vector2(randi_range(50, 200) * direction, randi_range(-100, -250))
	var angular_velocity: float = randi_range(5, 50)
	var piece: DismemberedPiece = DISMEMBERED_PIECE_SCENE.instantiate()
	
	ninja_owner.get_parent().add_sibling(piece)
	
	piece.global_position = ninja_owner.global_position
	piece.linear_velocity = linear_velocity
	piece.angular_velocity = angular_velocity
	piece.animated_sprite.play(animation)
	
	return piece
	
func chop_limb_off(animation: String, direction: int = 1) -> DismemberedPiece:
	var piece: DismemberedPiece = chop_piece_off(animation, direction)
	piece.spawn_blood()
	return piece
	

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED

func on_owner_animation_finished(animation_name: String) -> void:
	switch_state(StateMachine.RECOVER)
