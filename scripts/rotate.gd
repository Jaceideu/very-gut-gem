extends Node2D

@export var speed: float
@export var reverse: bool

func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "rotation", -1 if reverse else 1, speed).as_relative()
	tween.set_loops(0)
