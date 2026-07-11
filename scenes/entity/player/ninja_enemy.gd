class_name NinjaEnemy extends Ninja

signal eradication_finished

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

## Is this enemy alive enough to be eradicated?
func get_can_be_eradicated() -> bool:
	return not (not (body.has_arms or body.has_legs) or not (body.has_arms or body.has_head) or not (body.has_legs or body.has_head))

## Returns true if this enemy is missing any type of the body part
func is_missing_limb() -> bool:
	return not (body.has_arms and body.has_legs and body.has_head)

## This variation of animation player automatically plays the varied animation depending
## on how intact this enemy's body is
func play_animation(animation: String):
	super.play_animation(get_animation_varied(animation, self))

## Played when the player initiates the finisher move on this enemy, 
## forcing this enemy to be finished
func get_eradicated(player_forward_direction_h: int, eradication_animation: String, eradication_type: Eradication, eradication_finished_callback: Callable) -> void:
	
	set_forward_direction_h(player_forward_direction_h)
	
	play_animation(eradication_animation)
	
	if not eradication_finished.is_connected(eradication_finished_callback):
		eradication_finished.connect(eradication_finished_callback)

## Enemy is now supposed to receive damage, so decide how this incoming damage 
## will be registered
func detecting_incoming_damage(attacker: Ninja, attack_node: ComboNode):
	super.detecting_incoming_damage(attacker, attack_node)
	
	var attacker_direction: int = attacker.forward_direction_h
	var has_changed_direction: bool = set_forward_direction_h(-attacker_direction)
	
	if not get_can_be_eradicated():
		apply_death()
	else:
		apply_incoming_damage(attacker, attack_node)

## Apply logic so that this enemy dies now
func apply_death() -> void:
	self.disable_mode = DisableMode.DISABLE_MODE_MAKE_STATIC

## Applies damage to this enemy
func apply_incoming_damage(attacker: Ninja, attack_node: ComboNode):
	var chance: float = randf()
	
	var arms_chopped_chance: float = attack_node.arms_cut_chance
	var legs_chopped_chance: float = arms_chopped_chance + attack_node.legs_cut_chance
	var head_chopped_chance: float = legs_chopped_chance + attack_node.head_cut_chance
	
	var ninja_relative_offset: Vector2 = Vector2(15*attacker.forward_direction_h, 0)
	var ninja_thrust_velocity: Vector2 = Vector2.ZERO
	
	position += ninja_relative_offset
	
	# Chopping off the arms
	if chance < arms_chopped_chance and body.has_arms:
		body.has_arms = false
		play_animation("lost_arms")
		
		#chop_piece_off("sword", piece_linear_velocity * )
		
		#chop_limb_off("arm", piece_linear_velocity)
		#chop_limb_off("arm", -piece_linear_velocity)
		
		ninja_thrust_velocity = Vector2(300*forward_direction_h, 0)
		override_velocity(ninja_thrust_velocity)
	# Chopping off the legs
	elif chance < legs_chopped_chance and body.has_legs:
		play_animation("lost_legs")
		
		#chop_limb_off("leg", piece_linear_velocity)
		#chop_limb_off("leg", piece_linear_velocity)
		
		ninja_thrust_velocity = Vector2(350*forward_direction_h, -150)
		override_velocity(ninja_thrust_velocity)
		
		body.has_legs = false
	# Chopping off the head
	elif chance < head_chopped_chance and (body.has_head):
		apply_death()
		
		play_animation("lost_head")
		
		#chop_limb_off("head", piece_linear_velocity)
		
		body.has_head = false
		
		## If arm was not already present
		#if not body.has_arms:
			#chop_limb_off("head", -1)
	else:
		play_animation("hurt")

func _on_animation_finished(animation_name: String) -> void:
	# Signifies that this enemy has finished being eradicated
	if animation_name.begins_with("era"):
		eradication_finished.emit()
		current_eradication = null
