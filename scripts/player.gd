extends KinematicBody

export var speed = 6.0
export var jump_speed = 8.0
export var gravity = 20.0
var velocity = Vector3.ZERO
var dead = false

func _ready():
	GameManager.connect("game_started", self, "_on_game_started")
	add_to_group("player")
	add_eyes()
	reset()

func add_eyes():
	var eye_mat = SpatialMaterial.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.05, 1)
	var eye_shape = SphereMesh.new()
	eye_shape.radius = 0.08
	eye_shape.height = 0.12
	for x_offset in [-0.15, 0.15]:
		var eye = MeshInstance.new()
		eye.mesh = eye_shape
		eye.material_override = eye_mat
		eye.translation = Vector3(x_offset, 1.65, -0.32)
		add_child(eye)

func reset():
	dead = false
	velocity = Vector3.ZERO
	transform.origin = Vector3(0, 2.0, 0)
	rotation_degrees = Vector3.ZERO
	$Mesh.material_override.albedo_color = Color(0.15, 0.45, 0.9, 1)

func _physics_process(dt):
	if GameManager.state != GameManager.State.PLAYING:
		velocity = Vector3.ZERO
		transform.origin = Vector3(0, 2.0, 0)
		return
	if not is_on_floor():
		velocity.y -= gravity * dt
	if dead:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)
		velocity = move_and_slide(velocity, Vector3.UP)
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
	var d = Vector3()
	d.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	d.z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	d = d.normalized()
	var cam = get_viewport().get_camera()
	if cam:
		var fwd = -cam.global_transform.basis.z
		var rgt = cam.global_transform.basis.x
		fwd.y = 0
		rgt.y = 0
		var mv = fwd.normalized() * d.z + rgt.normalized() * d.x
		velocity.x = mv.x * speed
		velocity.z = mv.z * speed
		if mv.length() > 0.1:
			rotation.y = atan2(-mv.x, -mv.z)
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x = 0
		velocity.z = 0
	velocity = move_and_slide(velocity, Vector3.UP)

func die():
	if dead:
		return
	dead = true
	velocity = Vector3(0, 10, 0)
	$Mesh.material_override.albedo_color = Color(1, 0, 0, 1)
	yield(get_tree().create_timer(0.6), "timeout")
	if dead:
		GameManager.player_died()

func collect_coin_effect():
	pass

func _on_game_started():
	reset()