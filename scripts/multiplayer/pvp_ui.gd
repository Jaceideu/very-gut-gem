extends CanvasLayer

@onready var leaderboards: VBoxContainer = %Leaderboards
@onready var death_label: Label = %DeathLabel
@onready var killstreak_label: Label = %killstreak

var current_killstreak := 0: 
	set(new_killstreak):
		current_killstreak = new_killstreak
		killstreak_label.text = "unalive streek: " + str(new_killstreak)

func _on_player_respawned(id: int):
	if multiplayer.get_unique_id() == id:
		death_label.hide()

func _on_player_died(attacker_id: int):
	current_killstreak = 0
	
	if attacker_id < 1: return
	var attacker_data := Lobby.get_player_data(attacker_id)
	
	death_label.text = "u got pwned by %s" % attacker_data.nickname
	death_label.show()

func _on_player_killed(killed_id: int):
	current_killstreak += 1
	if current_killstreak == 10 and !GlobalSettings.has_skin("rifle2", 0):
		Lobby.local_player.skin_found.emit()
		GlobalSettings.add_skin("rifle2", 0)
		GlobalSettings.save()
	if current_killstreak == 25 and !GlobalSettings.has_skin("rifle2", 1):
		Lobby.local_player.skin_found.emit()
		GlobalSettings.add_skin("rifle2", 1)
		GlobalSettings.save()

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
	current_killstreak = 0
	get_parent().leaderboards_changed.connect(update_leaderboards)
	get_parent().player_died.connect(_on_player_died)
	get_parent().player_respawned.connect(_on_player_respawned)
	get_parent().player_killed.connect(_on_player_killed)
