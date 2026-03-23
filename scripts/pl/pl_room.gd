extends CSGBox3D
class_name PLRoom

@onready var question_label: Label3D = %Question

func initialize(text: String, destination: String):
	question_label.text = text
