class_name ComboNode extends Resource

@export var animation_name: StringName
@export var hitbox_id: int
@export var impact_key_frame_index: int = 2
@export var impact_frames: int = 1

@export_range(0.0, 1.0, 0.01) var arms_cut_chance: float = 0.1
@export_range(0.0, 1.0, 0.01) var legs_cut_chance: float = 0.1
@export_range(0.0, 1.0, 0.01) var head_cut_chance: float = 0.1

@export var thrust_forward: Vector2 = Vector2.ZERO

# The branches leading to the next attack. 
# Key: StringName (e.g., "light", "heavy", "delay"), Value: ComboNode
@export var next_attacks: Dictionary[AttackState.ATTACK_TYPE, ComboNode]
