extends Sprite3D
const GOLDEN_POOP = preload("uid://cfxn8yw1x3go3")

@onready var nickname_label: Label3D = %nickname_label

func set_nickname(new_name: String, is_shiny: bool):
	nickname_label.text = new_name
	if is_shiny:
		texture = GOLDEN_POOP
