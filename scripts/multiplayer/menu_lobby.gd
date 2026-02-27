extends Control

@export_file("*.tscn") var debug_other_level: String

@onready var host: Button = %host
@onready var join: Button = %join
@onready var ip_edit: LineEdit = %ipEdit
@onready var click_sound: AudioStreamPlayer = %click_sound
@onready var start: Button = %start
@onready var players_label: Label = %players_label
@onready var nickname_edit: LineEdit = %nicknameEdit
@onready var pvp: Button = %pvp




func update_players_label():
	players_label.text = "pLayere: %s/32" % Lobby.players.size()

func _on_player_added(player: Dictionary):
	update_players_label()
	
func _on_player_removed(id: int):
	update_players_label()

func _ready() -> void:
	Lobby.player_added.connect(_on_player_added)
	Lobby.player_removed.connect(_on_player_removed)
	click_sound.play()

func hide_common():
	join.hide()
	host.hide()
	ip_edit.hide()
	nickname_edit.hide()

func _on_host_pressed() -> void:
	click_sound.play()
	hide_common()
	Lobby.create_server(nickname_edit.text)
	start.show()
	players_label.show()
	pvp.show()
	

func _on_join_pressed() -> void:
	click_sound.play()
	hide_common()
	var new_nick := nickname_edit.text
	if new_nick.is_empty(): new_nick = "Twój Stary"
	Lobby.create_client(ip_edit.text, new_nick)

func _on_start_pressed() -> void:
	var level_to_load := debug_other_level if !debug_other_level.is_empty() else "res://scenes/levels/1.tscn"
	Lobby.load_game.rpc(level_to_load)


func _on_menu_pressed() -> void:
	Lobby.end_networking()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_pvp_pressed() -> void:
	Lobby.load_game.rpc("res://scenes/levels/pvp_1.tscn")
