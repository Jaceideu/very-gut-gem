extends Control

@export var weapon_names: Array[String]
var current_weapon_index: int = 0
@onready var weapon_preview: Sprite3D = %weapon_preview
@onready var click_sound: AudioStreamPlayer = %click_sound
@onready var skin_buttons_container: VBoxContainer = %skin_buttons_container
var current_skin_index: int = 0

const NO = preload("uid://cydmvpwy3rys5")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		_on_back_pressed()
	if event.is_action_pressed("weapon_next"):
		_on_next_pressed()
	if event.is_action_pressed("weapon_prev"):
		_on_prev_pressed()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	click_sound.play()
	load_weapon_preview(0)
	
	
func create_skin_buttons(weapon_name: String, weapon_material: ShaderMaterial):
	for btn in skin_buttons_container.get_children():
		btn.queue_free()
	
	var skin_ids: Array = GlobalSettings.inventory.get(weapon_name, [])
	

		
	var empty_button := TextureButton.new()
	empty_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	empty_button.texture_normal = NO
	skin_buttons_container.add_child(empty_button)
	empty_button.pressed.connect(_on_skin_button_pressed.bind(-1))
	empty_button.set_meta("skin_id", -1)
		
		
	if skin_ids.is_empty():
		return
		
	var skin_textures: Array = weapon_material.get_shader_parameter("skin_textures")
	
	
	for skin_id in skin_ids:
		var new_button := TextureButton.new()
		new_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		new_button.texture_normal = skin_textures[skin_id]
		skin_buttons_container.add_child(new_button)
		new_button.pressed.connect(_on_skin_button_pressed.bind(skin_id))
		new_button.set_meta("skin_id", skin_id)
		
		
func load_weapon_preview(index: int):
	var weapon_material := load("materials/weapons/%s.tres" % weapon_names[index])
	if !weapon_material:
		print_debug("Failed to load weapon material")
		return
	
	weapon_preview.material_override = weapon_material
	
	var equipped_skin_id: int = GlobalSettings.equipped_skins.get(weapon_names[index], -1)
	set_skin_preview(equipped_skin_id)
	create_skin_buttons(weapon_names[current_weapon_index], weapon_material)
		

func set_skin_preview(skin_id: int):
	weapon_preview.set_instance_shader_parameter("skinId", skin_id)
	
func _on_skin_button_pressed(skin_id: int):
	click_sound.play()
	set_skin_preview(skin_id)
	GlobalSettings.equipped_skins[weapon_names[current_weapon_index]] = skin_id

func _on_prev_pressed() -> void:
	click_sound.play()
	if current_weapon_index > 0:
		current_weapon_index -= 1	
		load_weapon_preview(current_weapon_index)


func _on_next_pressed() -> void:
	click_sound.play()
	if current_weapon_index < weapon_names.size() - 1:
		current_weapon_index += 1
		load_weapon_preview(current_weapon_index)
	


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
