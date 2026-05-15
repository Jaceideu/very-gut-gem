extends Marker3D

@export var targetname: String
@export var ignore_x: bool
@export var ignore_y: bool
@export var ignore_z: bool

@rpc("any_peer", "call_local", "reliable")
func trigger(player_path: NodePath):
	var player: Player = get_node(player_path)
	if !player:
		return
	
	var new_position: Vector3 = Vector3(
		player.global_position.x if ignore_y else global_position.x,
		player.global_position.y if ignore_z else global_position.y,
		player.global_position.z if ignore_x else global_position.z	
	)
	player.global_position = new_position
