extends Control

@onready var loading_bar: ProgressBar = %loading_bar
var loaded_packed_scene: PackedScene = null
var progress_ratio_array: Array[float] = []

@rpc("any_peer", "call_local", "reliable")
func change_to_loaded_scene():
	Lobby.loaded_player_count = 0
	get_tree().call_deferred("change_scene_to_packed", loaded_packed_scene)

func _on_all_players_loaded():
	change_to_loaded_scene.rpc()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Lobby.all_players_loaded.connect(_on_all_players_loaded)
	ResourceLoader.load_threaded_request(GlobalSettings.scene_to_load_path)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ResourceLoader.load_threaded_get_status(GlobalSettings.scene_to_load_path, progress_ratio_array)
	if is_equal_approx(progress_ratio_array[0], 1.0):
		loaded_packed_scene = ResourceLoader.load_threaded_get(GlobalSettings.scene_to_load_path)
		Lobby.player_loaded.rpc()
		set_process(false)
	else:
		loading_bar.value = progress_ratio_array[0] * 100.0
