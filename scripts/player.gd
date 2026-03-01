extends CharacterBody3D
class_name Player


static var dead_count: int = 0

var jump_velocity: float = 10.0


var mouse_sensitivity: float = 0.003
var joypad_sensitivity: float = 3
var joypad_deadzone: float = 0.1
var jump_buffer_time: float = 0.5
var coyote_time := 0.1
@export var can_move: bool = true
@export var should_respawn := false
@export var meshes: Array[MeshInstance3D]
@export var disable_hud := false
@export var is_invincible := false

var run_speed: float = 12.0
var sneak_speed: float = 8.0

var cam_accel: int = 40
var jump_buffer_timer: float = 0.0
var coyote_timer := 0.0
var camera_skew: float = 0.0

var is_crouching: bool = false
var normal_head_height: float = 1
var head_height: float = 1
var crouch_head_height: float = 0.4

var input_delay: float = 0.0

var speed_modifier: float = 1.0
var jump_modifier: float = 1.0

var internal_velocity: Vector3

var health: int = 100
var credit: int = 0

var current_weapon_id: int = 0

var has_starman := false
var nickname := "stoopid guy"
var has_infinite_ammo := false
var weapon_damage_multiplier := 1.0

@onready var camera = %Head/Camera3D
@onready var head = %Head
@onready var hurt_sound = %hurt_sound
@onready var weapons = %Weapons
@onready var weapon: Weapon
@onready var ui: Control = %Ui
@onready var starman_timer: Timer = %starman_timer
@onready var starman_sound: AudioStreamPlayer3D = %starman_sound
@onready var nickname_label: Label3D = %nickname_label
@onready var pvp_hitbox: Area3D = %pvp_hitbox


signal health_changed(new_health: int)
signal received_damage(damage: int)
signal credit_changed(new_credit: int)
signal credit_added(amount: int)
signal weapons_changed(names: Array[String])
signal starman_started
signal starman_ended
signal ammo_changed(new_amount: int)
signal respawn_requested(id: int, attacker_id: int)
signal skin_found

func heal():
	health = 100
	health_changed.emit(health)

func add_credit(amount: int):
	credit += amount
	credit_changed.emit(credit)
	credit_added.emit(amount)

@rpc("any_peer", "call_local", "reliable")
func damage(amount: int, attacker_path: String):
	
	if has_starman or is_invincible: return
	

	
	health -= amount
	health_changed.emit(health)
	received_damage.emit(amount)
	hurt_sound.play()
	
	if health <= 0:
		die(attacker_path)
	
	for mesh in meshes:
		mesh.get_active_material(0).albedo_color = Color.RED
	await get_tree().create_timer(0.1).timeout
	for mesh in meshes:
		mesh.get_active_material(0).albedo_color = Color.WHITE
	


func die(attacker_path: String):
	if Lobby.online_mode:
		
		var attacker := get_node(attacker_path) as Player
		if attacker:
			attacker.add_credit(50)
		
		if multiplayer.is_server():
			dead_count += 1
			if !should_respawn && dead_count >= Lobby.players.size():
				Lobby.load_game.rpc(get_tree().current_scene.scene_file_path)
				
			var attacker_id := 0
			if attacker:
				attacker_id = attacker.name.to_int()
				
			respawn_requested.emit(name.to_int(), attacker_id)
			queue_free()
	else:
		can_move = false
	

func _unhandled_input(event: InputEvent) -> void:
	
	if !is_multiplayer_authority(): return
	
	if event.is_action_pressed("escape") && Lobby.online_mode:
		damage.rpc(10000, get_path())
			
	if event is InputEventMouseMotion:
		
		if !Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			return
			
		if !can_move:
			return
		
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		rotate_y(-event.relative.x * mouse_sensitivity)
		#head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))
		
	if event is InputEventScreenDrag:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		
func _enter_tree() -> void:
	if Lobby.online_mode:
		set_multiplayer_authority(name.to_int())
		
func _ready() -> void:
	
	if multiplayer.is_server():
		dead_count -= 1
		if dead_count < 0:
			dead_count = 0
	
	if is_multiplayer_authority():	
		camera.make_current()
		nickname_label.queue_free()
	else:
		nickname_label.text = nickname
		
	if !is_multiplayer_authority() or disable_hud:
		ui.queue_free()
	
	if !OS.has_feature("mobile") && !OS.has_feature("web_android") && !OS.has_feature("web_ios"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if !(collision_layer & 4):
		pvp_hitbox.queue_free()

	await get_tree().process_frame
	mouse_sensitivity = GlobalSettings.mouse_sensitivity
	health_changed.emit(health)
	credit_changed.emit(credit)
	refresh_weapon_list()
	
	for mesh in meshes:
		mesh.get_active_material(0).albedo_color = Color.WHITE
	
func refresh_weapon_list():
	var weapon_names: Array[String]
	for wpn in weapons.get_children():
		wpn.set_physics_process(false)
		wpn.hide()
		weapon_names.push_back(wpn.name)
	weapons_changed.emit(weapon_names)

@rpc("any_peer", "call_local", "reliable")
func add_weapon(weapon_path: String):
	var new_weapon_scene := load(weapon_path)
	var new_weapon: Weapon = new_weapon_scene.instantiate()
	
	for wpn in weapons.get_children():
		if wpn.name == new_weapon.name:
			new_weapon.free()
			return
	
	new_weapon.set_multiplayer_authority(name.to_int())
	weapons.add_child(new_weapon)
	
	new_weapon.interact.connect(_on_weapon_interact)
	new_weapon.shake_camera.connect(_shake_camera)
	new_weapon.ammo_changed.connect(_on_weapon_ammo_changed)
	refresh_weapon_list()
	set_weapon(0, true)
	
	if is_multiplayer_authority():
		var skin_id: int = GlobalSettings.equipped_skins.get(new_weapon.name, -1)
		if skin_id >= 0:
			new_weapon.set_skin.rpc(skin_id)

@rpc("any_peer", "call_local", "reliable")
func set_weapon(id: int, forced: bool = false):
	
	
	if id == current_weapon_id && !forced:
		return
	
	if weapon:
		weapon.set_physics_process(false)
		weapon.hide()
	current_weapon_id = id
	weapon = weapons.get_child(current_weapon_id)
	weapon.set_physics_process(true)
	weapon.swap_to()
	weapon.player = self
	weapon.show()
	
	
func _process(delta: float) -> void:
	
	if !is_multiplayer_authority(): return
	
	if input_delay > 0.0:
		input_delay -= delta
		return
	
	if !can_move:
		return
	
	#if abs(Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)) > joypad_deadzone or abs(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)) > joypad_deadzone:		
		#head.rotate_x(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) * joypad_sensitivity * delta)
		#rotate_y(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * joypad_sensitivity * delta)
		#head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80.0), deg_to_rad(80.0))	
		
	for i in range(0, weapons.get_child_count()):
		if Input.is_action_just_pressed(str(i + 1)):
			set_weapon.rpc(i)
	

func _physics_process(delta: float) -> void:
	
	if !is_multiplayer_authority(): return
	
	if not is_on_floor():
		internal_velocity += get_gravity() * delta

	if !can_move or input_delay > 0.0:
		return
		
	
	is_crouching = false
	if Input.is_action_pressed("crouch"):
		is_crouching = true

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
		
	if is_on_floor():
		coyote_timer = coyote_time
		
	if coyote_timer > 0.0 and jump_buffer_timer > 0.0:
		internal_velocity.y = jump_velocity * jump_modifier
		internal_velocity.x *= 1.05
		internal_velocity.z *= 1.051
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
	else:
		coyote_timer -= delta
		jump_buffer_timer -= delta
		

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	var move_speed: float = sneak_speed if Input.is_action_pressed("sneak") or is_crouching else run_speed
	
	if input_dir.x > 0.0:
		internal_velocity.x += max(input_dir.x * move_speed * speed_modifier - internal_velocity.x, 0.0)
	elif input_dir.x < 0.0:
		internal_velocity.x += min(input_dir.x * move_speed * speed_modifier - internal_velocity.x, 0.0)
	else:
		internal_velocity.x = 0.0
		
	if input_dir.y > 0.0:
		internal_velocity.z += max(input_dir.y * move_speed * speed_modifier - internal_velocity.z, 0.0)
	elif input_dir.y < 0.0:
		internal_velocity.z += min(input_dir.y * move_speed * speed_modifier - internal_velocity.z, 0.0)
	else:
		internal_velocity.z = 0.0
	
	if coyote_timer > 0.0:
		internal_velocity.x = move_toward(internal_velocity.x, input_dir.x * move_speed * speed_modifier, 0.5)
		internal_velocity.z = move_toward(internal_velocity.z, input_dir.y * move_speed * speed_modifier, 0.5)
	
	
	var skew_strength: float = PI / 20
	var skew_increase: float = 0.02
	
		
	if input_dir.x > 0.0:
		camera_skew = clamp(camera_skew - skew_increase, -skew_strength, skew_strength)
	elif input_dir.x < 0.0:
		camera_skew = clamp(camera_skew + skew_increase, -skew_strength, skew_strength)
	else: 
		camera_skew = clamp(move_toward(camera_skew, 0.0, skew_increase), -skew_strength, skew_strength)
		
	head.rotation.z = camera_skew
	
	var crouch_speed: float = 0.1
	
	if is_crouching:
		head_height = clamp(head_height - crouch_speed, crouch_head_height, normal_head_height)
	else:
		head_height = clamp(head_height + crouch_speed, crouch_head_height, normal_head_height)
		
	head.position.y = head_height
	
	velocity = internal_velocity.rotated(Vector3.UP, rotation.y)

	move_and_slide()

@rpc("any_peer", "call_local", "reliable")
func interact(object_path: String):
	var object: Node3D = get_node(object_path)
	object.interact(get_path())
	
func start_starman(time: float):
	starman_timer.wait_time = time
	speed_modifier = 2.0
	has_starman = true
	starman_sound.play()
	starman_timer.start()
	starman_started.emit()

func _on_weapon_interact(object: Node3D) -> void:
	if !is_multiplayer_authority(): return
	interact.rpc(object.get_path())
	
func _shake_camera(shake_strength: float, shake_duration: float):
	if !is_multiplayer_authority(): return
	camera.start_shake(shake_strength, shake_duration)

func _on_starman_timer_timeout() -> void:
	has_starman = false
	speed_modifier = 1.0
	starman_sound.stop()
	starman_ended.emit()
	
func _on_weapon_ammo_changed(new_amount: int):
	ammo_changed.emit(new_amount)


func _on_pvp_hitbox_got_hit(amount: int, player_path: String) -> void:
	damage(amount, player_path)
