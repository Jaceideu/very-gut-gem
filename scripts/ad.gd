extends MeshInstance3D

@export var max_index := 0

	
func _ready() -> void:
	set_instance_shader_parameter("rand_index", max_index)
	
