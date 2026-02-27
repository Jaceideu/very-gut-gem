extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !OS.has_feature("mobile") && !OS.has_feature("web_android") && !OS.has_feature("web_ios") && !visible:
		queue_free()
	else:
		show()
