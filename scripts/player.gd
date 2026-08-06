extends KinematicBody

export var speed = 6.0
export var jump_speed = 8.0
export var gravity = 20.0
var velocity = Vector3.ZERO
var dead = false
var left_arm: MeshInstance = null
var right_arm: MeshInstance = null
var left_leg: MeshInstance = null
var right_leg: MeshInstance = null
var anim_time = 0.0
var is_moving = false
var is_jumping = false

func _ready():
	GameManager.connect("game_started", self, "_on_game_started")
	add_to_group("player")
	add_body_parts()
	reset()

func add_body_parts():
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
	var arm_mesh = CubeMesh.new()
	arm_mesh.size = Vector3(0.18, 0.5, 0.18)
	var body_mat = SpatialMaterial.new()
	body_mat.albedo_color = Color(0.15, 0.45, 0.9, 1)
	left_arm = MeshInstance.new()
	left_arm.mesh = arm_mesh
	left_arm.material_override = body_mat
	left_arm.translation = Vector3(-0.4, 1.0, 0)
	add_child(left_arm)
	right_arm = MeshInstance.new()
	right_arm.mesh = arm_mesh
	right_arm.material_override = body_mat
	right_arm.translation = Vector3(0.4, 1.0, 0)
	add_child(right_arm)
	var leg_mesh = CubeMesh.new()
	leg_mesh.size = Vector3(0.2, 0.45, 0.2)
	var leg_mat = SpatialMaterial.new()
	leg_mat.albedo_color = Color(0.1, 0.3, 0.65, 1)
	left_leg = MeshInstance.new()
	left_leg.mesh = leg_mesh
	left_leg.material_override = leg_mat
	left_leg.translation = Vector3(-0.15, 0.15, 0)
	add_child(left_leg)
	right_leg = MeshInstance.new()
	right_leg.mesh = leg_mesh
	right_leg.material_override = leg_mat
	right_leg.translation = Vector3(0.15, 0.15, 0)
	add_child(right_leg)

func reset():
	dead = false
	velocity = Vector3.ZERO
	transform.origin = Vector3(0, 2.0, 0)
	rotation_degrees = Vector3.ZERO
	anim_time = 0.0
	is_moving = false
	is_jumping = false
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
			is_moving = true
		else:
			velocity.x = 0
			velocity.z = 0
			is_moving = false
	else:
		velocity.x = 0
		velocity.z = 0
		is_moving = false
	is_jumping = not is_on_floor()
	velocity = move_and_slide(velocity, Vector3.UP)
	update_animation(dt)

func update_animation(dt):
	if not left_arm or not right_arm or not left_leg or not right_leg:
		return
	anim_time += dt
	if is_jumping:
		left_arm.rotation_degrees.x = lerp(left_arm.rotation_degrees.x, -50.0, 8.0 * dt)
		right_arm.rotation_degrees.x = lerp(right_arm.rotation_degrees.x, -50.0, 8.0 * dt)
		left_leg.rotation_degrees.x = lerp(left_leg.rotation_degrees.x, 35.0, 8.0 * dt)
		right_leg.rotation_degrees.x = lerp(right_leg.rotation_degrees.x, -35.0, 8.0 * dt)
	elif is_moving:
		var swing = sin(anim_time * 12.0)
		left_arm.rotation_degrees.x = swing * 30.0
		right_arm.rotation_degrees.x = -swing * 30.0
		left_leg.rotation_degrees.x = -swing * 25.0
		right_leg.rotation_degrees.x = swing * 25.0
	else:
		left_arm.rotation_degrees.x = lerp(left_arm.rotation_degrees.x, 0.0, 8.0 * dt)
		right_arm.rotation_degrees.x = lerp(right_arm.rotation_degrees.x, 0.0, 8.0 * dt)
		left_leg.rotation_degrees.x = lerp(left_leg.rotation_degrees.x, 0.0, 8.0 * dt)
		right_leg.rotation_degrees.x = lerp(right_leg.rotation_degrees.x, 0.0, 8.0 * dt)

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