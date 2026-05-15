extends Node

@export var targetname: String
@export var message: String

@rpc("any_peer", "call_local", "reliable")
func trigger(player_path: NodePath):
	print(message)
