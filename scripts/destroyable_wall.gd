@tool
extends Node3D
class_name DestroyableWall
signal destroyed


@export var health := 30
@export var id := 0
@onready var mesh: MeshInstance3D = get_child(0)


func _func_godot_apply_properties(properties: Dictionary):
	id = properties.id
	if properties["immune_to_players"]:
		add_to_group("immune_to_players", true)
		health *= 10

@rpc("authority", "call_local", "reliable")
func mul_destroy():
	destroyed.emit()
	queue_free()

@rpc("any_peer", "call_local", "reliable")
func damage(amount: int, player_path: String):
	
	if multiplayer.is_server():	
		health -= amount
		if health <= 0:
			mul_destroy.rpc()
			
	mesh.set_instance_shader_parameter("albedo", Color.RED)
	await get_tree().create_timer(0.1).timeout
	mesh.set_instance_shader_parameter("albedo", Color.WHITE)
