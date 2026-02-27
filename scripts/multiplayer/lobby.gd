extends Node
const PORT := 42069

var players: Array[Dictionary]
var loaded_player_count := 0
var local_nickname := ""
var online_mode := false
var match_started := false
var is_loading_late := false

signal all_players_loaded
signal player_added(player: Dictionary)
signal player_removed(id: int)

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_client(ip: String, nickname: String = ""):
	loaded_player_count = 0
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer
	add_player(multiplayer.get_unique_id(), nickname)
	local_nickname = nickname
	online_mode = true
	
func create_server(nickname: String = "Server"):
	loaded_player_count = 0
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	if nickname.is_empty(): nickname = "Server"
	add_player(1, nickname)
	local_nickname = nickname
	online_mode = true

func end_networking():
	loaded_player_count = 0
	local_nickname = ""
	online_mode = false
	players.clear()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	
func get_player_data(id: int) -> Dictionary:
	var index := players.find_custom(func(p): return p.id == id)
	return players.get(index)
	
	
@rpc("any_peer", "call_local", "reliable")
func add_player(id: int, nickname: String = ""):
	var new_player := {}
	new_player.id = id
	new_player.nickname = nickname
	new_player.kills = 0
	new_player.deaths = 0
	players.push_back(new_player)
	player_added.emit(new_player)
	
func _on_peer_disconnected(id: int):
	if multiplayer.is_server():
		remove_player.rpc(id)

func _on_peer_connected(id: int):
	add_player.rpc_id(id, multiplayer.get_unique_id(), local_nickname)
	if multiplayer.is_server() and match_started:
		print_debug(get_tree().current_scene.get_path())
		late_load.rpc_id(id, get_tree().current_scene.scene_file_path)
		
		
func _on_server_disconnected():
	end_networking()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		loaded_player_count += 1
		if loaded_player_count >= players.size():
			all_players_loaded.emit()
			
@rpc("any_peer", "call_local", "reliable")	
func remove_player(id: int):
	players = players.filter(func(p): if p.id != id: return true)
	player_removed.emit(id)
	
@rpc("authority", "reliable")
func late_load(scene_path: String):
	is_loading_late = true
	load_game(scene_path)
	
@rpc("call_local", "reliable")
func load_game(game_scene_path: String):
	print_debug("on %s players: %s" % [multiplayer.get_unique_id(), players])
	loaded_player_count = 0
	GlobalSettings.scene_to_load_path = game_scene_path
	get_tree().call_deferred("change_scene_to_file", "res://scenes/loading_screen.tscn")
