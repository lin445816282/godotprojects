extends CharacterBody3D

@export var speed = 6.0
@export var jump_speed = 8.0
@export var gravity = 20.0

var dead = false
var left_arm: MeshInstance3D = null
var right_arm: MeshInstance3D = null
var left_leg: MeshInstance3D = null
var right_leg: MeshInstance3D = null
var head: MeshInstance3D = null
var torso: MeshInstance3D = null
var anim_time = 0.0
var is_moving = false
var is_jumping = false
var invuln_timer = 0.0
var hit_flash = 0.0
var hits_taken = 0
var dust_timer = 0.0
var jumps_left = 1

# Powerups
var has_shield = false
var speed_boost_timer = 0.0
var magnet_timer = 0.0
var magnet_ring: MeshInstance3D = null

func _ready():
	GameManager.game_started.connect(_on_game_started)
	add_to_group("player")
	build_body()
	make_magnet_ring()
	reset()

func build_body():
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.15, 0.45, 0.9, 1)
	torso = MeshInstance3D.new()
	var tm = BoxMesh.new()
	tm.size = Vector3(0.9, 0.8, 0.5)
	torso.mesh = tm
	torso.material_override = body_mat
	torso.position = Vector3(0, 0.5, 0)
	add_child(torso)
	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.25, 0.6, 1.0, 1)
	head = MeshInstance3D.new()
	var hm = SphereMesh.new()
	hm.radius = 0.35
	hm.height = 0.6
	head.mesh = hm
	head.material_override = head_mat
	head.position = Vector3(0, 1.2, 0)
	add_child(head)
	var eye_mat = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.05, 1)
	var em = SphereMesh.new()
	em.radius = 0.07
	em.height = 0.1
	for ox in [-0.12, 0.12]:
		var eye = MeshInstance3D.new()
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ox, 1.28, -0.3)
		add_child(eye)
	var arm_mat = StandardMaterial3D.new()
	arm_mat.albedo_color = Color(0.12, 0.4, 0.85, 1)
	var am = BoxMesh.new()
	am.size = Vector3(0.22, 0.6, 0.22)
	left_arm = MeshInstance3D.new()
	left_arm.mesh = am
	left_arm.material_override = arm_mat
	left_arm.position = Vector3(-0.6, 0.3, 0)
	add_child(left_arm)
	right_arm = MeshInstance3D.new()
	right_arm.mesh = am
	right_arm.material_override = arm_mat
	right_arm.position = Vector3(0.6, 0.3, 0)
	add_child(right_arm)
	var leg_mat = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.08, 0.25, 0.6, 1)
	var lm = BoxMesh.new()
	lm.size = Vector3(0.24, 0.5, 0.24)
	left_leg = MeshInstance3D.new()
	left_leg.mesh = lm
	left_leg.material_override = leg_mat
	left_leg.position = Vector3(-0.2, -0.5, 0)
	add_child(left_leg)
	right_leg = MeshInstance3D.new()
	right_leg.mesh = lm
	right_leg.material_override = leg_mat
	right_leg.position = Vector3(0.2, -0.5, 0)
	add_child(right_leg)

func make_magnet_ring():
	magnet_ring = MeshInstance3D.new()
	var ring = CylinderMesh.new()
	ring.top_radius = 3.5
	ring.bottom_radius = 3.5
	ring.height = 0.05
	magnet_ring.mesh = ring
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.3, 0.8, 0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	magnet_ring.material_override = mat
	magnet_ring.position = Vector3(0, 0.1, 0)
	magnet_ring.visible = false
	add_child(magnet_ring)

func reset():
	dead = false
	velocity = Vector3.ZERO
	position = Vector3(0, 2.0, 0)
	rotation_degrees = Vector3.ZERO
	anim_time = 0.0
	is_moving = false
	is_jumping = false
	invuln_timer = 0.0
	hit_flash = 0.0
	hits_taken = 0
	jumps_left = 1
	has_shield = false
	speed_boost_timer = 0.0
	magnet_timer = 0.0
	set_body_visible(true)
	if magnet_ring:
		magnet_ring.visible = false

func activate_shield():
	has_shield = true

func activate_speed():
	speed_boost_timer = 5.0

func activate_magnet():
	magnet_timer = 5.0
	if magnet_ring:
		magnet_ring.visible = true

func set_body_visible(v):
	if torso: torso.visible = v
	if head: head.visible = v
	if left_arm: left_arm.visible = v
	if right_arm: right_arm.visible = v
	if left_leg: left_leg.visible = v
	if right_leg: right_leg.visible = v

func _physics_process(dt):
	if GameManager.state == GameManager.State.PAUSED:
		velocity = Vector3.ZERO
		return
	if GameManager.state != GameManager.State.PLAYING:
		velocity = Vector3.ZERO
		if GameManager.state == GameManager.State.MENU or GameManager.state == GameManager.State.WIN or GameManager.state == GameManager.State.LOSE:
			position = Vector3(0, 2.0, 0)
		return

	# Update powerup timers
	invuln_timer = max(invuln_timer - dt, 0.0)
	hit_flash = max(hit_flash - dt, 0.0)
	if speed_boost_timer > 0:
		speed_boost_timer -= dt
	if magnet_timer > 0:
		magnet_timer -= dt
		if magnet_timer <= 0 and magnet_ring:
			magnet_ring.visible = false
		if magnet_ring:
			magnet_ring.rotate_y(dt * 3.0)
		pull_coins(dt)

	if not is_on_floor():
		velocity.y -= gravity * dt
	if dead:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)
		move_and_slide()
		return
	if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("gamepad_jump")) and is_on_floor():
		velocity.y = jump_speed
		jumps_left = 1
		AudioManager.play("jump")
	elif (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("gamepad_jump")) and jumps_left > 0:
		jumps_left -= 1
		velocity.y = jump_speed * 0.9
		AudioManager.play("jump")
	var d = Vector3()
	if Input.get_joy_axis(0, 0) != 0.0 or Input.get_joy_axis(0, 1) != 0.0:
		d.x = Input.get_joy_axis(0, 0)
		d.z = Input.get_joy_axis(0, 1)
	else:
		d.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		d.z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	d = d.normalized()
	var cam = get_viewport().get_camera_3d()
	if cam:
		var fwd = -cam.global_transform.basis.z
		var rgt = cam.global_transform.basis.x
		fwd.y = 0
		rgt.y = 0
		var mv = fwd.normalized() * d.z + rgt.normalized() * d.x
		var spd = speed * (2.0 if speed_boost_timer > 0 else 1.0)
		velocity.x = mv.x * spd
		velocity.z = mv.z * spd
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
	move_and_slide()
	update_animation(dt)
	update_dust(dt)
	if global_position.y < -8.0:
		die()
		return
	if hit_flash > 0.0:
		var on = int(floor(hit_flash * 12.0)) % 2 == 0
		set_body_visible(on)

func pull_coins(dt):
	var coins = get_tree().get_nodes_in_group("coins")
	for coin in coins:
		if coin.has_method("is_taken") and coin.taken:
			continue
		var d = global_position - coin.global_position
		var dist = d.length()
		if dist < 5.0 and dist > 0.5:
			d = d.normalized()
			coin.global_position += d * 8.0 * dt
		elif dist <= 0.5:
			coin.global_position = global_position

func update_animation(dt):
	if not left_arm or not right_arm or not left_leg or not right_leg:
		return
	anim_time += dt
	if is_jumping:
		left_arm.rotation_degrees.x = lerp(left_arm.rotation_degrees.x, -50.0, 8.0*dt)
		right_arm.rotation_degrees.x = lerp(right_arm.rotation_degrees.x, -50.0, 8.0*dt)
		left_leg.rotation_degrees.x = lerp(left_leg.rotation_degrees.x, 35.0, 8.0*dt)
		right_leg.rotation_degrees.x = lerp(right_leg.rotation_degrees.x, -35.0, 8.0*dt)
	elif is_moving:
		var sw = sin(anim_time*12.0)
		left_arm.rotation_degrees.x = sw*30.0
		right_arm.rotation_degrees.x = -sw*30.0
		left_leg.rotation_degrees.x = -sw*25.0
		right_leg.rotation_degrees.x = sw*25.0
	else:
		left_arm.rotation_degrees.x = lerp(left_arm.rotation_degrees.x, 0.0, 8.0*dt)
		right_arm.rotation_degrees.x = lerp(right_arm.rotation_degrees.x, 0.0, 8.0*dt)
		left_leg.rotation_degrees.x = lerp(left_leg.rotation_degrees.x, 0.0, 8.0*dt)
		right_leg.rotation_degrees.x = lerp(right_leg.rotation_degrees.x, 0.0, 8.0*dt)

func take_hit(from : Vector3):
	if dead or invuln_timer > 0.0:
		return
	if has_shield:
		has_shield = false
		AudioManager.play("powerup")
		invuln_timer = 1.0
		hit_flash = 1.0
		return
	hits_taken += 1
	invuln_timer = 1.0
	hit_flash = 1.0
	velocity = from * -8.0 + Vector3(0, 6.0, 0)
	_hud_flash()
	if hits_taken >= 3:
		die()

func _hud_flash():
	var hud = get_tree().current_scene.find_node("HUD", true, false)
	if hud and hud.has_method("damage_flash"):
		hud.damage_flash()

func die():
	if dead:
		return
	dead = true
	AudioManager.play("death")
	set_body_visible(false)
	await get_tree().create_timer(0.6).timeout
	if dead:
		GameManager.player_died()

func update_dust(dt):
	if is_moving and is_on_floor() and GameManager.state == GameManager.State.PLAYING:
		dust_timer -= dt
		if dust_timer <= 0.0:
			dust_timer = 0.08
			var cp = CPUParticles3D.new()
			cp.one_shot = true
			cp.emitting = true
			cp.amount = 6
			cp.lifetime = 0.4
			cp.local_coords = true
			cp.direction = Vector3(0, 1, 0)
			cp.spread = 60.0
			cp.gravity = Vector3(0, -2, 0)
			cp.initial_velocity = 1.5
			cp.scale_amount = 0.05
			cp.color = Color(0.75, 0.7, 0.6, 0.8)
			cp.position = Vector3(0, 0.05, 0)
			add_child(cp)
			await get_tree().create_timer(0.5).timeout
			cp.queue_free()
	else:
		dust_timer = 0.0

func get_hits():
	return hits_taken

func collect_coin_effect():
	pass

func _on_game_started():
	reset()
