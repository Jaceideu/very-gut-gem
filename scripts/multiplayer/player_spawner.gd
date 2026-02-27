extends MultiplayerSpawner

signal leaderboards_changed
signal player_died(attacker_id: int)
signal player_respawned(id: int)

@export var offline_player: Player
@export var enable_pvp := false
@export var spawn_points: Array[Node3D]

const PLAYER = preload("uid://ca5cvww1u7iq1")


@rpc("authority", "call_local", "reliable")
func player_died_inform(attacker_id: int):
	player_died.emit(attacker_id)

@rpc("any_peer", "call_local", "reliable")
func update_leaderboards(id: int, kills_diff: int, deaths_diff: int):
	var player_data := Lobby.get_player_data(id)
	player_data.kills += kills_diff
	player_data.deaths += deaths_diff
	
	leaderboards_changed.emit()
	

func remove_player(player_path: String):
	var to_remove: Node = get_node(player_path)
	if to_remove:
		to_remove.queue_free()

@rpc("any_peer", "call_local", "reliable")
func _on_player_respawn_requested(id: int, attacker_id: int):
	print_debug("respawn requested, %s" % id)
	update_leaderboards.rpc(id, 0, 1)
	if attacker_id > 0 and id != attacker_id:
		update_leaderboards.rpc(attacker_id, 1, 0)
		player_died_inform.rpc_id(id, attacker_id)
	
	await get_tree().create_timer(2.0).timeout
	spawn(Lobby.get_player_data(id))

func _on_player_removed(id: int):
	remove_player(str(id))
	update_leaderboards.rpc(1, 0, 0)

func spawn_player(player_data: Dictionary):
	var new_player := PLAYER.instantiate()
	new_player.name = str(player_data.id)
	new_player.nickname = player_data.nickname
	
	if enable_pvp:
		new_player.collision_layer |= 4
		new_player.should_respawn = true
		new_player.has_infinite_ammo = true
		new_player.weapon_damage_multiplier = 5.0
	if multiplayer.is_server():
		new_player.respawn_requested.connect(_on_player_respawn_requested)
		
	if spawn_points.size() > 0:
		var chosen_spawn = spawn_points.pick_random()
		new_player.position = chosen_spawn.global_position
		new_player.rotation = chosen_spawn.global_rotation
	
	player_respawned.emit(player_data.id)
	print_debug("on: %s player %s spawned" % [multiplayer.get_unique_id(), player_data.id])
	return new_player

func _ready() -> void:
	
	for spawn_point in get_tree().get_nodes_in_group("spawn_points"):
		spawn_points.push_back(spawn_point)
	
	if offline_player:
		if Lobby.online_mode:
			offline_player.queue_free()
		elif enable_pvp:
			offline_player.global_position = spawn_points.pick_random().global_position
		
		

		
	spawn_function = spawn_player
	
	if multiplayer.is_server():
		Lobby.all_players_loaded.connect(_on_all_players_loaded)
		Lobby.player_removed.connect(_on_player_removed)
	
func _on_all_players_loaded():
	for player in Lobby.players:
		spawn(player)
	if Lobby.online_mode:	
		update_leaderboards.rpc(1, 0, 0)
