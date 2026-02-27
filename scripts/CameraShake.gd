extends Camera3D

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_decay: float = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if shake_duration > 0:
		shake_duration -= delta
		var shake_amount = shake_intensity * shake_duration / shake_decay
		
		rotation_degrees = Vector3(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
	else:
		rotation_degrees = Vector3.ZERO
		
		
func start_shake(intensity: float, duration: float, decay: float = 1.0):
	shake_intensity = intensity
	shake_duration = duration
	shake_decay = decay
