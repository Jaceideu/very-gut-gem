extends Node3D

const SKIBIDI = preload("uid://mjwninu5ixcb")

@onready var timer: Timer = %Timer
@onready var spawn_markers: Node3D = %SpawnMarkers

@rpc("call_local", "authority", "reliable")
func spawn_skibids():
	for marker in spawn_markers.get_children():
		var new_skibidi := SKIBIDI.instantiate()
		new_skibidi.global_position = marker.global_position
		get_parent().get_parent().call_deferred("add_child", new_skibidi, true)
		

func _on_clippy_detected_player() -> void:
	if timer.is_stopped() && multiplayer.is_server():
		timer.start()


func _on_timer_timeout() -> void:	
	spawn_skibids.rpc()
