extends KinematicBody

export var speed = 6.0
export var jump_speed = 8.0
export var gravity = 20.0
var velocity = Vector3.ZERO
var dead = false
var invincible = false
var inv_timer = 0.0

var body_root: Spatial = null
var torso: MeshInstance = null
var head: MeshInstance = null
var left_arm: MeshInstance = null
var right_arm: MeshInstance = null
var left_leg: MeshInstance = null
var right_leg: MeshInstance = null
var particles: CPUParticles = null
var anim_time = 0.0
var is_moving = false
var is_jumping = false
var run_speed = 12.0
var arm_swing = 0.0
var leg_swing = 0.0
var bob_amount = 0.0

func _ready():
	GameManager.connect("game_started", self, "_on_game_started")
	add_to_group("player")
	if has_node("Mesh"):
		get_node("Mesh").queue_free()
	build_character()
	create_particles()
	reset()

func build_character():
	body_root = Spatial.new()
	body_root.name = "Character"
	add_child(body_root)

	# Torso
	var tm = CubeMesh.new()
	tm.size = Vector3(0.6, 0.7, 0.35)
	torso = MeshInstance.new()
	torso.mesh = tm
	var t_mat = SpatialMaterial.new()
	t_mat.albedo_color = Color(0.15, 0.45, 0.9, 1)
	torso.material_override = t_mat
	torso.translation = Vector3(0, 1.15, 0)
	body_root.add_child(torso)

	# Head
	var hm = SphereMesh.new()
	hm.radius = 0.25
	hm.height = 0.45
	head = MeshInstance.new()
	head.mesh = hm
	var h_mat = SpatialMaterial.new()
	h_mat.albedo_color = Color(0.25, 0.6, 1.0, 1)
	head.material_override = h_mat
	head.translation = Vector3(0, 1.72, 0)
	body_root.add_child(head)

	# Eyes
	var eyemat = SpatialMaterial.new()
	eyemat.albedo_color = Color(0.1, 0.1, 0.1, 1)
	var em = SphereMesh.new()
	em.radius = 0.05
	em.height = 0.1
	for ox in [-0.1, 0.1]:
		var eye = MeshInstance.new()
		eye.mesh = em
		eye.material_override = eyemat
		eye.translation = Vector3(ox, 1.76, -0.22)
		body_root.add_child(eye)

	# Arms
	var am = CubeMesh.new()
	am.size = Vector3(0.18, 0.6, 0.18)
	left_arm = MeshInstance.new()
	left_arm.mesh = am
	left_arm.material_override = t_mat.duplicate()
	left_arm.translation = Vector3(-0.4, 1.3, 0)
	body_root.add_child(left_arm)
	right_arm = MeshInstance.new()
	right_arm.mesh = am
	right_arm.material_override = t_mat.duplicate()
	right_arm.translation = Vector3(0.4, 1.3, 0)
	body_root.add_child(right_arm)

	# Legs
	var lm = CubeMesh.new()
	lm.size = Vector3(0.2, 0.5, 0.2)
	var l_mat = SpatialMaterial.new()
	l_mat.albedo_color = Color(0.1, 0.3, 0.7, 1)
	left_leg = MeshInstance.new()
	left_leg.mesh = lm
	left_leg.material_override = l_mat
	left_leg.translation = Vector3(-0.15, 0.55, 0)
	body_root.add_child(left_leg)
	right_leg = MeshInstance.new()
	right_leg.mesh = lm
	right_leg.material_override = l_mat
	right_leg.translation = Vector3(0.15, 0.55, 0)
	body_root.add_child(right_leg)

func create_particles():
	particles = CPUParticles.new()
	particles.name = "CoinParticles"
	particles.emitting = false
	particles.amount = 40
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.spread = 150.0
	particles.speed_scale = 5.0
	particles.color = Color(1, 0.85, 0.1, 1)
	add_child(particles)

func reset():
	dead = false
	invincible = false
	inv_timer = 0.0
	velocity = Vector3.ZERO
	transform.origin = Vector3(0, 2.0, 0)
	rotation_degrees = Vector3.ZERO
	anim_time = 0.0
	is_moving = false
	is_jumping = false
	bob_amount = 0.0
	if body_root:
		body_root.visible = true
	if particles:
		particles.emitting = false

func _physics_process(dt):
	if GameManager.state != GameManager.State.PLAYING:
		velocity = Vector3.ZERO
		transform.origin = Vector3(0, 2.0, 0)
		return
	if invincible:
		inv_timer -= dt
		if inv_timer <= 0:
			invincible = false
		if body_root:
			body_root.visible = fmod(inv_timer * 20.0, 1.0) > 0.5
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
	if not body_root or not left_arm or not right_arm or not left_leg or not right_leg:
		return
	anim_time += dt
	if is_jumping:
		arm_swing = lerp(arm_swing, 45.0, 8.0 * dt)
		leg_swing = lerp(leg_swing, -35.0, 8.0 * dt)
		bob_amount = lerp(bob_amount, 0.3, 8.0 * dt)
	elif is_moving:
		arm_swing = sin(anim_time * run_speed) * 35.0
		leg_swing = sin(anim_time * run_speed) * 30.0
		bob_amount = abs(sin(anim_time * run_speed * 2.0)) * 0.08
	else:
		arm_swing = lerp(arm_swing, 0.0, 5.0 * dt)
		leg_swing = lerp(leg_swing, 0.0, 5.0 * dt)
		bob_amount = lerp(bob_amount, 0.0, 5.0 * dt)
	left_arm.rotation_degrees.x = arm_swing
	right_arm.rotation_degrees.x = -arm_swing
	left_leg.rotation_degrees.x = -leg_swing
	right_leg.rotation_degrees.x = leg_swing
	body_root.translation.y = bob_amount

func collect_coin_effect():
	if particles:
		particles.emitting = false
		particles.emitting = true

func die():
	if dead or invincible:
		return
	dead = true
	velocity = Vector3(0, 10, 0)
	if particles:
		particles.emitting = false
		particles.emitting = true
	yield(get_tree().create_timer(0.6), "timeout")
	if dead:
		GameManager.player_died()

func _on_game_started():
	reset()
	invincible = true
	inv_timer = 2.0