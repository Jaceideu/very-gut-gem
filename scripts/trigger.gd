@tool
extends Area3D
class_name Trigger

@export var target: String
@export var target_path: NodePath
	
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	for t in get_tree().get_nodes_in_group("activeable"):
		if t.targetname == target:
			target_path = t.get_path()
			break

func _on_body_entered(player: Node3D):
	if !is_multiplayer_authority():
		return
	
	if target_path.is_empty():
		return
	
	var t: Node = get_node(target_path)
	if !t:
		return
	
	if t.has_method("trigger"):
		t.trigger.rpc(player.get_path())
