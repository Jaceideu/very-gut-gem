extends Node

@onready var vbox := %VBoxContainer
@onready var line_edit: LineEdit = %LineEdit

func _ready() -> void:	
	Lobby.player_added.connect(_on_player_added)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	
func _on_player_added(player: Dictionary):
	if !multiplayer.is_server(): return
	
	for mess in vbox.get_children():
		add_message.rpc_id(player.id, mess.text)
		
	
	add_message.rpc("connected", player.id, player.nickname)

	
func _on_peer_disconnected(id: int):
	if multiplayer.is_server():
		add_message.rpc("disconnected", id)

@rpc("any_peer", "call_local", "reliable")
func add_message(message: String, id: int = 0, nickname: String = ""):
	
	if message.is_empty(): return
	
	var new_message_scene := Label.new()
	
	if id == 0:
		new_message_scene.text = "%s" % message
	elif nickname.is_empty():
		new_message_scene.text = "[%s]: %s" % [id, message]
	else:
		new_message_scene.text = "%s[%s]: %s" % [nickname, id, message]
	
	vbox.add_child(new_message_scene)


func _on_line_edit_text_submitted(new_text: String) -> void:
	add_message.rpc(new_text, multiplayer.get_unique_id(), Lobby.local_nickname)
	line_edit.text = ""
