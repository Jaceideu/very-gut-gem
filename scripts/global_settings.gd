extends Node

const SAVE_PATH := "user://save.kys"
var was_game_loaded := false
var mouse_sensitivity: float = 0.003
var scene_to_load_path: String = ""
var equipped_skins: Dictionary[String, int] = {}
var inventory: Dictionary[String, Array] = {}

func add_skin(weapon_name: String, skin_id: int):
	var skin_ids: Array = inventory.get(weapon_name, [])
	if !skin_ids.has(skin_id):
		skin_ids.push_back(skin_id)
	inventory[weapon_name] = skin_ids

func has_skin(weapon_name: String, skin_id: int):
	var skin_ids: Array[int]
	skin_ids.assign(inventory.get(weapon_name, []))
	return skin_ids.has(skin_id)

func save():
	for key in inventory:
		inventory[key] = inventory[key] as Array[int]
	
	var json := JSON.stringify(inventory)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(json)

func load_save():
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if !file: return
	
	var text := file.get_as_text()
	if text.is_empty(): return
	
	inventory.assign(JSON.parse_string(text))
