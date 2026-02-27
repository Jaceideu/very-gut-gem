@tool
extends MeshInstance3D

@export_file("*.tscn") var weapon_scene_path: String

func _func_godot_apply_properties(properties):
	weapon_scene_path = "res://scenes/weapons/%s.tscn" % properties.get("weapon")
	if weapon_scene_path.is_empty(): return
	var material := get_active_material(0)
	var new_mat := material.duplicate()
	var pickup_tex := load("res://gut textures/weapons/%s.png" % properties.get("weapon"))
	new_mat.albedo_texture = pickup_tex
	set_surface_override_material(0, new_mat)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !multiplayer.is_server(): return
	
	var player := body as Player
	if player:
		player.add_weapon.rpc(weapon_scene_path)
