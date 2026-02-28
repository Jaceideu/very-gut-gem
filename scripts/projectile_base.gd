extends Area3D
class_name Projectile

@export var move_speed := 10.0
@export var damage := 10

func _ready() -> void:
	if !multiplayer.is_server(): return
	
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if !multiplayer.is_server(): return
	
	position += basis.z * move_speed * delta


func _on_body_entered(body: Node3D) -> void:
	if !multiplayer.is_server(): return
	
	if body.has_method("damage"):
		body.damage.rpc(damage, get_path())
	queue_free()
