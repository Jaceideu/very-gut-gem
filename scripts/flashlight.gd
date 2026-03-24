extends SpotLight3D

@onready var burst: Timer = %burst

func _ready() -> void:
	set_burst()
	
func set_burst():
	burst.wait_time = randf_range(0.5, 3.0)
	burst.start()

func _on_timer_timeout() -> void:
	visible = false
	await get_tree().create_timer(0.1).timeout
	visible = true
	await get_tree().create_timer(0.05).timeout
	visible = false
	await get_tree().create_timer(0.5).timeout
	visible = true
	set_burst()
