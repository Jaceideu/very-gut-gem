@tool
extends Area3D

const idiot_level_path: String = "res://scenes/levels/you_are_an_idiot.tscn"
@export_file("*.tscn") var level_path: String

var was_touched: bool = false

func _func_godot_apply_properties(properties: Dictionary):
	var destination_path: String = properties.get("destination", "")
	if destination_path.is_empty() or !FileAccess.file_exists(destination_path):
		destination_path = idiot_level_path
	
	level_path = destination_path

func _on_body_entered(body: Node3D) -> void:	
	var player := body as Player
	if !player: return
	if was_touched: return
	was_touched = true
	if level_path.is_empty(): return
	
	Lobby.loaded_player_count = 0
	call_deferred("queue_free")
	
	if !multiplayer.is_server(): return
	
	if level_path.find("levels/") == -1:
		Lobby.end_networking()
	
	Lobby.load_game.rpc(level_path)
	
