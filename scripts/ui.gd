extends Control

@onready var ammo_label: Label = %ammo
@onready var hp_lablel: Label = %hp
@onready var screen_flash: ColorRect = %screen_flash
@onready var game_over_screen: CanvasLayer = %game_over
@onready var over_sound: AudioStreamPlayer = %over_sound
@onready var credit_label: Label = %credit
@onready var credit_flash: TextureRect = %credit_flash
@onready var credit_add_label: Label = %credit_add_label
@onready var correct_sound: AudioStreamPlayer = %correct_sound
@onready var minus_credit_flash: TextureRect = %minus_credit_flash
@onready var credit_remove_label: Label = %credit_remove_label
@onready var incorrect_sound: AudioStreamPlayer = %incorrect_sound
@onready var weapon_list: Label = %weapon_list
@onready var starman_flash: ColorRect = %starman_flash
@onready var starman_blink_timer: Timer = %starman_blink_timer
@onready var map_name_label: Label = %MapNameLabel


func _ready():
	map_name_label.text = "levele is %s" % get_tree().current_scene.name

func _process(delta):
	if Input.is_action_just_pressed("escape") && !Lobby.online_mode:
		show_gameover_screen()
		
	if starman_flash.visible:
		starman_flash.color.h += 0.01

func show_gameover_screen():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_over_screen.show()
	over_sound.play()
	



func _on_player_ammo_changed(new_amount: int) -> void:
	ammo_label.text = str(new_amount)


func _on_player_health_changed(new_health: int) -> void:
	hp_lablel.text = str(new_health)
	
	if new_health <= 0 && !Lobby.online_mode:
		show_gameover_screen()


func _on_player_received_damage(damage: int) -> void:
	screen_flash.show()
	await get_tree().create_timer(0.05).timeout
	screen_flash.hide()


func _on_play_button_down() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_button_down() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
#
func _on_player_credit_changed(new_credit: int) -> void:
	credit_label.text = str(new_credit)


func _on_player_credit_added(amount: int) -> void:
	if amount > 0:
		correct_sound.play()
		credit_add_label.text = str(amount)
		credit_flash.show()
		await get_tree().create_timer(0.3).timeout
		credit_flash.hide()
	else:
		incorrect_sound.play()
		credit_remove_label.text = str(amount)
		minus_credit_flash.show()
		await get_tree().create_timer(0.3).timeout
		minus_credit_flash.hide()
		
		


func _on_player_weapons_changed(names: Array[String]) -> void:
	var i: int = 1
	weapon_list.text = ""
	for wpn_name in names:
		weapon_list.text += str(i) + " " + wpn_name + "\n"
		i+=1


func _on_player_starman_started() -> void:
	starman_flash.show()


func _on_player_starman_ended() -> void:
	starman_flash.hide()
