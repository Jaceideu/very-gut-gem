extends Area3D

@export var weapon_material: ShaderMaterial
@export var weapon_name: String
@export var skin_id: int
@onready var sprite: Sprite3D = %sprite



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalSettings.has_skin(weapon_name, skin_id): queue_free()
	
	sprite.material_override = weapon_material
	sprite.set_instance_shader_parameter("skinId", skin_id)


func _on_body_entered(body: Node3D) -> void:
	if body is not Player:
		return
	
	GlobalSettings.add_skin(weapon_name, skin_id)
	queue_free()
