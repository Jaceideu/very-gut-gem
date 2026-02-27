extends Node

@export var spongebob: Enemy

var targets: Array[DestroyableWall]

func _on_wall_destroyed():
	if !multiplayer.is_server(): return
	
	if targets.size() > 0:
		spongebob.chased_target = targets.pop_front()

func _on_spongebob_died():
	if !multiplayer.is_server(): return
	
	for player in get_tree().get_nodes_in_group("players"):
		player.damage.rpc(99999, get_path())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.chased_target = spongebob
		enemy.always_chase = true
	
	if !multiplayer.is_server(): return
	targets.assign(get_tree().get_nodes_in_group("destroyable_walls"))

	
	for target in targets:
		target.destroyed.connect(_on_wall_destroyed)
	
	targets.sort_custom(func(a, b): return a.id < b.id)
	spongebob.died.connect(_on_spongebob_died)
	spongebob.chased_target = targets.pop_front()
	
