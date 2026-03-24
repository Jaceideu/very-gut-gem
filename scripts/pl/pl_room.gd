extends CSGBox3D
class_name PLRoom

@onready var question_label: Label3D = %Question
@onready var level_end: Area3D = %LevelEnd

func initialize(text: String, destination: String):
	question_label.text = text
	level_end.level_path = destination
