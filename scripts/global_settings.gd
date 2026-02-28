extends Node

var mouse_sensitivity: float = 0.003
var scene_to_load_path: String = ""
var equipped_skins: Dictionary[String, int] = {}
var inventory: Dictionary[String, Array] = {}

func add_skin(weapon_name: String, skin_id: int):
	var skin_ids: Array[int] = inventory.get(weapon_name, [] as Array[int])
	if !skin_ids.has(skin_id):
		skin_ids.push_back(skin_id)
	inventory[weapon_name] = skin_ids

func has_skin(weapon_name: String, skin_id: int):
	var skin_ids: Array[int] = inventory.get(weapon_name, [] as Array[int])
	return skin_ids.has(skin_id)
