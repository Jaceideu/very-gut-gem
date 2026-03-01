extends Node

@onready var shoot_timer: Timer = %ShootTimer
const PEA = preload("uid://6jb4a2xsew7j")
var is_activated := false

@onready var shooter := get_parent()

func _on_shoot_timer_timeout() -> void:
	var new_pea := PEA.instantiate()
	get_tree().current_scene.add_child(new_pea, true)
	new_pea.global_position = shooter.global_position
	new_pea.global_rotation.y = atan2(shooter.dir.x, shooter.dir.z)


func _on_peashooter_detected_player() -> void:
	if !multiplayer.is_server(): return
	
	shoot_timer.start()
