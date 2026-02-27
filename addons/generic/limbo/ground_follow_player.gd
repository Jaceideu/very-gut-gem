extends StaticBody3D

@export var target: Node3D

func _physics_process(delta: float) -> void:
	if abs(target.position.x) > 10:
		global_position.x = target.global_position.x
		target.position.x = 0.0
	if abs(target.position.z) > 10:
		global_position.z = target.global_position.z
		target.position.z = 0.0
#
