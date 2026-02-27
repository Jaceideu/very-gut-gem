extends MeshInstance3D

@export var speed := 1.0

func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "rotation:y", 1.0, speed).as_relative()
	tween.set_loops(0)
