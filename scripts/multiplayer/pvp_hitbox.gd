extends Area3D

signal got_hit(amount: int, player_path: String)

@rpc("any_peer", "call_local", "reliable")
func damage(amount: int, player_path: String):
	got_hit.emit(amount, player_path)
