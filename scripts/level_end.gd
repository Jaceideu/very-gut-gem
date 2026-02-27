extends Area3D

@export_file("*.tscn") var level_path: String

var was_touched: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:	
	var player := body as Player
	if !player: return
	if was_touched: return
	was_touched = true
	if level_path.is_empty(): return
	
	Lobby.loaded_player_count = 0
	call_deferred("queue_free")
	
	if !multiplayer.is_server(): return
	
	
	Lobby.load_game.rpc(level_path)
	
