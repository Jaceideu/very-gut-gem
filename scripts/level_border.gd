extends Area3D

const DESTINATION_SCENE = preload("uid://qdys5rfnf2ia")

func _on_body_entered(body: Node3D) -> void:
	if body is not Player: return
	
	if body.is_multiplayer_authority():
		Lobby.end_networking()
		get_tree().call_deferred("change_scene_to_packed", DESTINATION_SCENE)
	
