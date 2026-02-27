extends Area3D

@export var duration: float = 10.0

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("start_starman"):
		body.start_starman(duration)
		queue_free()
