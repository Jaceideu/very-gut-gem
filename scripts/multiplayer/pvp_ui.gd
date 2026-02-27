extends CanvasLayer

@onready var leaderboards: VBoxContainer = %Leaderboards
@onready var death_label: Label = %DeathLabel

func _on_player_respawned(id: int):
	if multiplayer.get_unique_id() == id:
		death_label.hide()

func _on_player_died(attacker_id: int):
	var attacker_data := Lobby.get_player_data(attacker_id)
	if !attacker_data: return
	
	death_label.text = "u got pwned by %s" % attacker_data.nickname
	death_label.show()

func update_leaderboards():
	for player in leaderboards.get_children():
		player.queue_free()
	
	var player_stats = Lobby.players.duplicate()
	player_stats.sort_custom(\
		func(a, b):
			return a.kills > b.kills)
			
	for player in player_stats:
		var new_label := Label.new()
		new_label.text = "%s, %s/%s" % [player.nickname, player.kills, player.deaths]
		leaderboards.add_child(new_label)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().leaderboards_changed.connect(update_leaderboards)
	get_parent().player_died.connect(_on_player_died)
	get_parent().player_respawned.connect(_on_player_respawned)
	
