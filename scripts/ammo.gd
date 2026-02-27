extends StaticBody3D

@rpc("any_peer", "reliable", "call_local")
func interact(player_path: String):
	var player := get_node(player_path)
	player.weapon.add_ammo(30)
	queue_free()
