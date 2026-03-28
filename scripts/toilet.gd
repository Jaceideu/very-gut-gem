extends StaticBody3D

@onready var sfx: AudioStreamPlayer3D = %sfx

@rpc("any_peer", "reliable", "call_local")
func interact(player_path: String):
	var player: Player = get_node(player_path)
	player.poop = 0.0
	sfx.play()
