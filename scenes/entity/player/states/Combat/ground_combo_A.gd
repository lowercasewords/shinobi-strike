class_name GroundComboA extends ComboState

@onready var t: Timer = $Timer

func enter() -> void:
	super.enter()
	player.animated_sprite.play("ground_combo_A")
