extends StaticBody3D

func interact(player_path: String):
	var player: Player = get_node(player_path)
	if player.credit >= 100:
		player.add_credit(-100)
		player.heal()
