extends Node3D
class_name Weapon

@export var ammo: int = 100
@export var damage: int = 1
@export var automatic: bool = true
@export var shake_strength: float = 3.0
@export var shake_duration: float = 0.3
@export var has_infinite_ammo := false
@export var does_flashing := true
@export var does_swinging := false


var is_shooting: bool = false
var player: Player

signal ammo_changed(new_amount: int)
signal interact(object: Node3D)
signal shake_camera(shake_strength: float, shake_duration: float)

@onready var flash: Node3D = $flash
@onready var shoot_timer: Timer = $shoot
@onready var shoot_sound: AudioStreamPlayer = $shoot_sound
@onready var ammo_sound: AudioStreamPlayer = $ammo_sound
@onready var cast: RayCast3D = $shootcast
@onready var light_flash: OmniLight3D = $light_flash
@onready var rot_pivot: Node3D = %RotPivot
@onready var sprite: Sprite3D = %sprite

@rpc("any_peer", "call_local", "reliable")
func set_skin(id: int):
	sprite.set_instance_shader_parameter("skinId", id)

func swap_to():
	ammo_changed.emit(ammo)
	is_shooting = false
	#shoot_timer.stop()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	ammo_changed.emit(ammo)
	
	
func add_ammo(amount: int):
	ammo += amount
	ammo_changed.emit(ammo)
	ammo_sound.pitch_scale = randf_range(0.1, 2.0)
	ammo_sound.play()

@rpc("any_peer", "call_local")
func shoot_effects():
	shoot_sound.pitch_scale = randf_range(0.1, 2.0)
	shoot_sound.play()

	if does_swinging:
		var tween := create_tween()
		tween.tween_property(rot_pivot, "rotation_degrees:z", 60, 0.1).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(rot_pivot, "rotation_degrees:z", 0, 0.1).set_trans(Tween.TRANS_CUBIC)
		
	
	if does_flashing:
		light_flash.show()
		flash.show()
		await get_tree().create_timer(0.05).timeout
		flash.hide()
		light_flash.hide()

func shoot():
	
	
	if ammo <= 0 && !player.has_infinite_ammo && !has_infinite_ammo:
		return
	
	shake_camera.emit(shake_strength, shake_duration)
	
	if !has_infinite_ammo:
		ammo -= 1
	
	
	
	var col = cast.get_collider()
	if col:
		if col.has_method("damage") and !col.is_in_group("immune_to_players"):
			col.damage.rpc(damage * player.weapon_damage_multiplier, player.get_path())
			
	ammo_changed.emit(ammo)
	
	shoot_effects.rpc()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if !is_multiplayer_authority() && Lobby.online_mode: return
	
	var fire_input_pressed := Input.is_action_just_pressed("fire") if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.is_action_just_pressed("fire_touch")
	var fire_input_released := Input.is_action_just_released("fire") if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.is_action_just_released("fire_touch")
	
	if fire_input_pressed and !is_shooting:
		is_shooting = true
		shoot_timer.start()
		shoot()
	if fire_input_released:
		if automatic:
			is_shooting = false
			shoot_timer.stop()
		
	if Input.is_action_just_pressed("interact"):
		
		if has_infinite_ammo:
			return
		
		var col = cast.get_collider()
		if col:
			if col.has_method("interact"):
				interact.emit(col)


func _on_shoot_timeout() -> void:
	if is_physics_processing():
		if automatic:
			shoot()
			return
			
		is_shooting = false
		shoot_timer.stop()
