extends Marker3D

@export var displacement: Vector3
@export var targetname: String

@rpc("any_peer", "call_local", "reliable")
func trigger(player_path: NodePath):
	var player: Player = get_node(player_path)
	if !player:
		return
	
	player.global_position += displacement
