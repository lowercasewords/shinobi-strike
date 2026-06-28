class_name NinjaEnemy extends Ninja

signal eradication_finished

const DISMEMBERED_PIECE_SCENE = preload("res://scenes/entity/enemies/EradicatedPiece.tscn")

const NO_ARMS_ENDING = "_na"
const NO_LEGS_ENDING = "_nl"
const NO_ARMS_AND_LEGS_ENDING = "_nal"

var body: Dictionary[String, bool] = {
	"has_arms": true,
	"has_legs": true,
	"has_head": true
}

## Returns true if this enemy is missing any type of the body part
func is_missing_limb() -> bool:
	return not (body.has_arms and body.has_legs and body.has_head)

## Checks if the animation name exists for this entity
func has_animation(animation: String) -> bool:
	return animation_player.sprite_frames.has_animation(animation)

## Play animation accounting for the missing limbs
func play_animation(animation: String):
	var animation_no_arms_variant: String = animation + NO_ARMS_ENDING
	var animation_no_legs_variant: String = animation + NO_LEGS_ENDING
	
	if not body.has_arms and has_animation(animation_no_arms_variant):
		super.play_animation(animation_no_arms_variant)
	if not body.has_legs and has_animation(animation_no_legs_variant):
		super.play_animation(animation_no_legs_variant)
	else:
		super.play_animation(animation)

func get_obliterated(eradication_finished_callback: Callable) -> void:
	play_animation("obl")
	eradication_finished.connect(eradication_finished_callback)

func _on_animation_finished() -> void:
	if animation_player.animation.begins_with("obl"):
		eradication_finished.emit()

func get_hurt(attack_node: ComboNode):
	super.get_hurt(attack_node)
	var chance: float = randf()
	
	var ninja_thrust_velocity: Vector2 = Vector2.ZERO
	var arms_chopped_chance: float = attack_node.arms_cut_chance
	var legs_chopped_chance: float = arms_chopped_chance + attack_node.legs_cut_chance
	var head_chopped_chance: float = legs_chopped_chance + attack_node.head_cut_chance
	
	if chance < arms_chopped_chance and body.has_arms:
		play_animation("lost_arms")
		
		chop_piece_off("sword", 1)
		
		chop_limb_off("arm", 1)
		chop_limb_off("arm", -1)
		
		ninja_thrust_velocity = Vector2(300*forward_direction_h, 0)
		apply_thrust(ninja_thrust_velocity)
		
		body.has_arms = false
	elif chance < legs_chopped_chance:
		play_animation("lost_legs")
		
		chop_piece_off("sword", 1)
		
		chop_limb_off("leg", 1)
		chop_limb_off("leg", -1)
		
		ninja_thrust_velocity = Vector2(350*forward_direction_h, -150)
		apply_thrust(ninja_thrust_velocity)
		
		body.has_legs = false
	else:
		play_animation("hurt")

## Chops any piece off the enemy, could be a limb or a sword
func chop_piece_off(animation: String, direction: int = 1) -> EradicatedPiece:
	var piece: EradicatedPiece = DISMEMBERED_PIECE_SCENE.instantiate()
	var piece_linear_velocity: Vector2 = Vector2(randi_range(50, 200) * direction, randi_range(-100, -250))
	var piece_angular_velocity: float = randi_range(5, 50)
	
	self.get_parent().add_sibling(piece)
	
	piece.global_position = self.global_position
	piece.linear_velocity = piece_linear_velocity
	piece.angular_velocity = piece_angular_velocity
	piece.animation_player.play(animation)
	
	return piece
	
## Specifically chops off the enemy limb
func chop_limb_off(animation: String, direction: int = 1) -> EradicatedPiece:
	var piece: EradicatedPiece = chop_piece_off(animation, direction)
	
	piece.spawn_blood()
	return piece
