extends Control

@onready var settings_layer: CanvasLayer = %Settings
@onready var click_sound: AudioStreamPlayer = %click_sound

func _ready() -> void:
	GlobalSettings.was_game_loaded = true
	GlobalSettings.load_save()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	click_sound.play()

func _on_play_single_button_down() -> void:
	click_sound.play()
	Lobby.load_game("res://scenes/levels/1.tscn")
	
func _on_play_multi_button_down() -> void:
	click_sound.play()
	get_tree().change_scene_to_file("res://scenes/menu_lobby.tscn")
	
func _on_option_button_down() -> void:
	click_sound.play()
	settings_layer.show()


func _on_quit_button_down() -> void:
	click_sound.play()
	get_tree().quit()


func _on_back_button_down() -> void:
	click_sound.play()
	settings_layer.hide()


func _on_fullscreen_button_down() -> void:
	click_sound.play()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func _on_window_button_down() -> void:
	click_sound.play()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
func set_mouse_sensitivity(sensitivity: float):
	click_sound.play()
	GlobalSettings.mouse_sensitivity = sensitivity
	
func enable_vsync():
	click_sound.play()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	Engine.max_fps = 0

func set_max_fps(max: int):
	click_sound.play()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = max
	

func _on_mute_button_down() -> void:
	get_tree().quit()


func _on_skins_button_down() -> void:
	click_sound.play()
	get_tree().change_scene_to_file("res://scenes/skin_menu.tscn")
