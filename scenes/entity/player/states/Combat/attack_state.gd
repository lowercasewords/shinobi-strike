class_name AttackState extends State

enum ATTACK_TYPE 
{ 
	LIGHT, HEAVY,
	BACK, FORWARD, UPWARD, DOWNWARD, # Directional movement keys to modify the combo
	DELAY, # Player waited just a bit before pressing any attack button to modify the combo
	UNKNOWN,
}

const DEFAULT_H_THURST: float = 50
const DEFAULT_V_THURST: float = 1.0

@export var sword_whoosh: AudioStreamPlayer2D
@onready var _root_combo: ComboNode = preload("res://scenes/entity/player/states/Combat/Combo/combo_neutral.tres")

var current_attack_node: ComboNode

## The velocity of the entity before entering the attacking state.
var before_combo_velocity: Vector2

func set_thurst(thrust_velocity: Vector2 = Vector2(200, 0)) -> void:
	ninja_owner.apply_velocity(thrust_velocity)

func attempt_eradication(ninja_enemy: NinjaEnemy) -> void:
	if ninja_owner is NinjaPlayer:
		current_attack_node = null
		(ninja_owner as NinjaPlayer).initialize_eradication(ninja_enemy)

func get_state_space() -> STATE_SPACE:
	return STATE_SPACE.GROUNDED
	
func enter() -> void:
	super.enter()
	before_combo_velocity = abs(ninja_owner.velocity)
	current_attack_node = _root_combo
	var success: bool = attempt_next_attack()
	if not success:
		switch_to_next_state()

func exit() -> void:
	super.exit()
	ninja_owner.velocity = before_combo_velocity/2
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	
	apply_friction(_delta)
	
	if not ninja_owner.is_grounded:
		apply_gravity(_delta)
		
func apply_attack_area() -> void:
	ninja_owner.apply_attack_area()

## Attempts to perform either the first attack or continue combo
func attempt_next_attack() -> bool:
	## Check the controller for an input (e.g., "light", "heavy", "forward_light")
	var attempted_input: ATTACK_TYPE = ninja_owner.ninja_controller.get_buffered_input()
	var attacked: bool = false
	## Grab everything inside the area instantly
	var overlapping_bodies: Array[Node2D] = ninja_owner.attack_area.get_overlapping_bodies()
	var overlapping_ninja_enemy: NinjaEnemy = null
	
	if not overlapping_bodies.is_empty():
		overlapping_bodies.get(0) as NinjaEnemy
	
	if overlapping_ninja_enemy != null and overlapping_ninja_enemy.get_can_be_eradicated() and current_attack_node == _root_combo and attempted_input == ATTACK_TYPE.HEAVY and overlapping_ninja_enemy.is_missing_limb():
		attempt_eradication(overlapping_ninja_enemy)
		attacked = true
	elif attempted_input != ATTACK_TYPE.UNKNOWN and current_attack_node != null and current_attack_node.next_attacks.has(attempted_input):
		# Step down the tree branch
		current_attack_node = current_attack_node.next_attacks[attempted_input]
		execute_current_attack()
		attacked = true
	
	return attacked

func execute_current_attack():
	#var direction: Vector2 = Vector2.RIGHT * ninja_owner.forward_direction_h
	#var extra_thrust: Vector2 = current_attack_node.thrust_forward if current_attack_node != null else Vector2.ZERO
	#var _existing_velocity: Vector2 = before_combo_velocity if ninja_owner.ninja_controller.get_input_direction_h() != direction.x else Vector2.ZERO
	
	#ninja_owner.velocity = extra_thrust * direction
	
	#print("Velocity: " + str(ninja_owner.velocity))
	
	set_animation(current_attack_node.animation_name)
	sword_whoosh.play()

func switch_to_next_state():
	
	if fall_state_triggered():
		switch_state(StateMachine.FALL)
	elif walk_state_triggered():
		switch_state(StateMachine.WALK)
	
	switch_state(StateMachine.IDLE)
#
#func on_owner_frame_changed(): 
	#if current_attack_node != null:
		#
		#var frame_index: int = ninja_owner.animation_player.frame
		#var key_frame_index: int = current_attack_node.impact_key_frame_index
		#
		#if frame_index == key_frame_index:
			#on_keyframe_invoked(ninja_owner.animation_player.current_animation, ninja_owner.animation_player.frame)
		#elif frame_index == key_frame_index+1:
			#on_after_keyframe_invoked(ninja_owner.animation_player.current_animation, ninja_owner.animation_player.frame)
	#
#func on_keyframe_invoked(_animation: String, _frame_index: int): 
	#
	#ninja_owner.velocity /= 10
	##attempt_next_attack()
	##apply_attack_area()
	#
#func on_after_keyframe_invoked(_animation: String, _frame_index: int): 
	#attempt_next_attack()

func on_owner_animation_finished(_animation_name: String) -> void:
	#switch_to_next_state()
	var success: bool = attempt_next_attack()
	if not success:
		switch_to_next_state()
