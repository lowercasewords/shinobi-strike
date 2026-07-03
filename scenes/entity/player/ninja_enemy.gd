class_name NinjaEnemy extends Ninja

signal eradication_finished

const DISMEMBERED_PIECE_SCENE = preload("res://scenes/entity/enemies/EradicatedPiece.tscn")
const MAX_HITS: int = 10
const MIN_HITS: int = 5

# How intact the enemy is
var body: Dictionary[String, bool] = {
	"has_arms": true,
	"has_legs": true,
	"has_head": true
}

## The eradication currently performing
var current_eradication: Eradication = null
## Represents the "health points" of this entity, dies upon reaching 0
var hit_pool: int = 1

func _ready() -> void:
	super._ready()
	hit_pool = randi_range(MIN_HITS, MAX_HITS)


func get_can_be_eradicated() -> bool:
	return not (not (body.has_arms or body.has_legs) or not (body.has_arms or body.has_head) or not (body.has_legs or body.has_head))

## Returns true if this enemy is missing any type of the body part
func is_missing_limb() -> bool:
	return not (body.has_arms and body.has_legs and body.has_head)

func play_animation(animation: String):
	super.play_animation(get_animation_varied(animation, self))

func get_eradicated(player_forward_direction_h: int, eradication_animation: String, eradication_type: Eradication, eradication_finished_callback: Callable) -> void:
	
	set_forward_direction_h(player_forward_direction_h)
	
	play_animation(eradication_animation)
	
	if not eradication_finished.is_connected(eradication_finished_callback):
		eradication_finished.connect(eradication_finished_callback)

func detecting_incoming_damage(attacker: Ninja, attack_node: ComboNode):
	super.detecting_incoming_damage(attacker, attack_node)
	
	var attacker_direction: int = attacker.forward_direction_h
	var has_changed_direction: bool = set_forward_direction_h(-attacker_direction)
	
	if not get_can_be_eradicated():
		apply_death()
	else:
		apply_incoming_damage(attacker, attack_node)

func apply_death() -> void:
	self.disable_mode = DisableMode.DISABLE_MODE_MAKE_STATIC

func apply_incoming_damage(attacker: Ninja, attack_node: ComboNode):
	var chance: float = randf()
	
	var arms_chopped_chance: float = attack_node.arms_cut_chance
	var legs_chopped_chance: float = arms_chopped_chance + attack_node.legs_cut_chance
	var head_chopped_chance: float = legs_chopped_chance + attack_node.head_cut_chance
	
	var ninja_relative_offset: Vector2 = Vector2(15*attacker.forward_direction_h, 0)
	var piece_linear_velocity: Vector2 = Vector2(randi_range(50, 200), randi_range(-100, -250))
	var ninja_thrust_velocity: Vector2 = Vector2.ZERO
	
	position += ninja_relative_offset
	
	# Chopping off the arms
	if chance < arms_chopped_chance and body.has_arms:
		body.has_arms = false
		play_animation("lost_arms")
		
		chop_piece_off("sword", piece_linear_velocity * (-1 if randi() % 2 == 1 else 1))
		
		chop_limb_off("arm", piece_linear_velocity)
		chop_limb_off("arm", -piece_linear_velocity)
		
		ninja_thrust_velocity = Vector2(300*forward_direction_h, 0)
		apply_thrust(ninja_thrust_velocity)
	# Chopping off the legs
	elif chance < legs_chopped_chance and body.has_legs:
		play_animation("lost_legs")
		
		chop_limb_off("leg", piece_linear_velocity)
		chop_limb_off("leg", piece_linear_velocity)
		
		ninja_thrust_velocity = Vector2(350*forward_direction_h, -150)
		apply_thrust(ninja_thrust_velocity)
		
		body.has_legs = false
	# Chopping off the head
	elif chance < head_chopped_chance and (body.has_head):
		apply_death()
		
		play_animation("lost_head")
		
		chop_limb_off("head", piece_linear_velocity)
		
		body.has_head = false
		
		## If arm was not already present
		#if not body.has_arms:
			#chop_limb_off("head", -1)
	else:
		play_animation("hurt")
	

## Chops any piece off the enemy, could be a limb or a sword
func chop_piece_off(animation: String, piece_linear_velocity: Vector2) -> EradicatedPiece:
	var piece: EradicatedPiece = DISMEMBERED_PIECE_SCENE.instantiate()
	var piece_angular_velocity: float = randi_range(5, 50)
	
	self.get_parent().add_sibling(piece)
	
	piece.global_position = self.global_position
	piece.linear_velocity = piece_linear_velocity
	piece.angular_velocity = piece_angular_velocity
	piece.animated_sprite.play(animation)
	
	return piece
	
## Specifically chops off the enemy limb
func chop_limb_off(animation: String, piece_linear_velocity: Vector2) -> EradicatedPiece:
	var piece: EradicatedPiece = chop_piece_off(animation, piece_linear_velocity)
	($SwordSlash).play()
	($BloodSplatter).play("default")
	piece.spawn_blood()
	return piece

func _on_animation_finished() -> void:
	# Signifies that this enemy has finished being eradicated
	if animated_sprite.animation.begins_with("era"):
		eradication_finished.emit()
		current_eradication = null
