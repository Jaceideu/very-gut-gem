extends CSGCombiner3D

@export_multiline() var question_text: String
@export_multiline() var answers_texts: Array[String]
@export var correct_index: int
@export_file("*.tscn") var correct_level_path: String

@export var rooms: Array[PLRoom]

var fail_level_path: String = "res://scenes/levels/you_are_an_idiot.tscn"

@onready var question_label: Label3D = %Question

func _ready() -> void:
	assert(!question_text.is_empty(), "Empty Question")
	assert(answers_texts.size() == 4, "Incorrect amount of answers")
	
	question_label.text = question_text

	assert(rooms.size() == 4, "Incorrect amount of rooms")
	assert(correct_index >= 0 and correct_index < 4, "WTF is the correct answer?")
	
	
	for i in range(4):
		var level_path := fail_level_path
		if i == correct_index:
			level_path = correct_level_path
		
		rooms[i].initialize(answers_texts[i], level_path)
