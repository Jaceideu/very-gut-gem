extends CSGCombiner3D

@export_multiline() var question_text: String
@export_multiline() var answers_texts: Array[String]
@export var rooms: Array[PLRoom]

@onready var question_label: Label3D = %Question

func _ready() -> void:
	assert(!question_text.is_empty(), "Empty Question")
	assert(answers_texts.size() == 4, "Incorrect amount of answers")
	
	question_label.text = question_text

	assert(rooms.size() == 4, "Incorrect amount of rooms")
	
	
	for i in range(4):
		rooms[i].initialize(answers_texts[i], "")
