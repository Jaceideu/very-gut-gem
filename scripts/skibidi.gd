extends CharacterBody3D
class_name Enemy

signal detected_player
signal died

@export var move_speed: float = 5.0;
@export var health: int = 5
@export var attack_damage: int = 1
@export var credit_reward: int = 50
@export var chased_target: Node3D = null
@export var is_crasher := false
@export var dont_change_targets := false
var attacked_target: Node3D = null


@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var player_detector: Area3D = %player_detector
@onready var target_change_timer: Timer = %TargetChangeTimer

@rpc("any_peer", "call_local", "reliable")
func kill_mult(player_path: String):
	var target := get_node(player_path)
	if target and target.has_method("add_credit"):
		target.add_credit(credit_reward)
	
	died.emit()
	queue_free()

@rpc("any_peer", "call_local", "reliable")
func damage(amount: int, player_path: String):
	
	mesh.set_instance_shader_parameter("albedo", Color.RED)
	await get_tree().create_timer(0.1).timeout
	mesh.set_instance_shader_parameter("albedo", Color.WHITE)
	
	if !multiplayer.is_server(): return
	
	health -= amount
	if health <= 0:
		kill_mult.rpc(player_path)
		
	


func _physics_process(delta: float) -> void:
	
	if (!multiplayer.is_server()): return
	
	if attacked_target:
		if attacked_target is Player and attacked_target.has_starman:
			damage.rpc(9999, attacked_target.get_path())
		else:
			attacked_target.damage.rpc(attack_damage, get_path())
	
	if !chased_target:
		return
	
	var dir: Vector3 = chased_target.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	velocity = Vector3(0, 0, move_speed).rotated(Vector3.UP, atan2(dir.x, dir.z))

	move_and_slide()


func _on_hurt_box_body_entered(body: Node3D) -> void:
	if (!multiplayer.is_server()): return
	
	if body == self:
		return
	
	if is_crasher:
		get_tree().quit()
	
	attacked_target = body


func _on_hurt_box_body_exited(body: Node3D) -> void:
	if (!multiplayer.is_server()): return
	attacked_target = null

@rpc("any_peer", "call_local", "reliable")
func set_target(player_path: String):
	chased_target = get_node(player_path)


func _on_player_detector_body_entered(body: Node3D) -> void:
	if (!multiplayer.is_server()): return
	if dont_change_targets: return
	if body == chased_target: return
	
	
	if chased_target:
		if is_instance_valid(chased_target):
			var current_target_squared_distance := chased_target.global_position.distance_squared_to(global_position)
			var new_target_squared_distance := body.global_position.distance_squared_to(global_position)
			if new_target_squared_distance >= current_target_squared_distance: return
	else:
		target_change_timer.start()
	
	set_target.rpc(body.get_path())
	detected_player.emit()


func _on_target_change_timer_timeout() -> void:
	if (!multiplayer.is_server()): return
	if (!is_instance_valid(chased_target)): return
	
	var current_target_squared_distance := chased_target.global_position.distance_squared_to(global_position)
	
	var bodies := player_detector.get_overlapping_bodies()
	for body in bodies:
		var new_target_squared_distance := body.global_position.distance_squared_to(global_position)
		if new_target_squared_distance < current_target_squared_distance:
			set_target.rpc(body.get_path())
