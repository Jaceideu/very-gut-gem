extends StaticBody3D

@onready var axis: Node3D = $Axis
@onready var col_shape: CollisionShape3D = $CollisionShape3D
@onready var sound: AudioStreamPlayer3D = $sound

var opened: bool = false
var locked: bool = false

func open():
	opened = true
	sound.play()
	col_shape.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(axis, "rotation_degrees:y", 90, 0.3)
	
func close():
	opened = false
	sound.play()
	col_shape.set_deferred("disabled", false)
	var tween = create_tween()
	tween.tween_property(axis, "rotation_degrees:y", 0, 0.3)
	locked = true

@rpc("any_peer", "reliable", "call_local")
func interact(player_path: String):
	
	if opened or locked: 
		return
	
	open()
	
	
