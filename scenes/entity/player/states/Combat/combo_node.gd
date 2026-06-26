class_name ComboNode extends Resource

@export var animation_name: StringName
@export var hitbox_id: int
@export var impact_key_frame_index: int = 2
@export var impact_frames: int = 1

@export var arms_cut_chance: float = 1.0
@export var legs_cut_chance: float = 1.0

@export var thrust_forward: Vector2 = Vector2.ZERO

# The branches leading to the next attack. 
# Key: StringName (e.g., "light", "heavy", "delay"), Value: ComboNode
@export var next_attacks: Dictionary[AttackState.ATTACK_TYPE, ComboNode]
