@tool
extends Node
class_name LikesKillingWall

@export var kill_threshold: int = 0

func _func_godot_apply_properties(properties: Dictionary):
	kill_threshold = properties.get("kill_threshold", 0)

func _on_new_max_kills_reached(kills: int):
	if kills == kill_threshold:
		queue_free()

func _ready() -> void:
	if !Engine.is_editor_hint():
		GlobalSignals.new_max_kills_reached.connect(_on_new_max_kills_reached)
