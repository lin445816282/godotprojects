extends Area3D

enum State { PATROL, CHASE, RETURN }
@export var patrol_speed = 2.0
@export var chase_speed = 4.0
@export var wait_time = 0.8
@export var detect_range = 4.0
@export var attack_cooldown = 1.0
@export var sprint = false
@export var sprint_mult = 1.8
var state = State.PATROL
var wps = []
var idx = 0
var waiting = false
var wtimer = 0.0
var origin = Vector3.ZERO
var pulse = 0.0
var player = null
var attack_timer = 0.0

func _ready():
	add_to_group("enemies")
	body_entered.connect(_hit)
	GameManager.game_started.connect(_on_game_started)
	_setup_glow()

func _setup_glow():
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(1, 0.15, 0.15, 1)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.emission_enabled = true
	m.emission = Color(1, 0.2, 0.2, 1)
	m.emission_energy_multiplier = 2.0
	$Mesh.material_override = m
	for c in get_children():
		if c is Marker3D and c.name.begins_with("WP"):
			wps.append(c.global_position)
	origin = global_position

func _on_game_started():
	if not is_inside_tree():
		return
	state = State.PATROL
	idx = 0
	waiting = false
	wtimer = 0.0
	pulse = 0.0
	player = null
	global_position = origin
	if $Mesh.material_override: $Mesh.material_override.albedo_color = Color(1, 0.15, 0.15, 1)

func _process(dt):
	pulse += dt
	var sc = 1.0 + sin(pulse * 4.0) * 0.08
	$Mesh.scale = Vector3(sc, 1.0, sc)
	attack_timer = max(attack_timer - dt, 0.0)
	if GameManager.state != GameManager.State.PLAYING:
		return

	find_player()
	var dist_to_player = distance_to_player()

	# State transitions
	if state == State.CHASE:
		if dist_to_player > detect_range * 1.5:
			state = State.RETURN
			if $Mesh.material_override: $Mesh.material_override.albedo_color = Color(1, 0.5, 0.1, 1)
		elif dist_to_player <= 0.8 and attack_timer <= 0.0:
			_hit(player)
			attack_timer = attack_cooldown
			return
	elif state == State.PATROL:
		if player and dist_to_player < detect_range:
			state = State.CHASE
			if $Mesh.material_override: $Mesh.material_override.albedo_color = Color(1, 0.05, 0.05, 1)
	elif state == State.RETURN:
		if dist_to_player < detect_range:
			state = State.CHASE
			if $Mesh.material_override: $Mesh.material_override.albedo_color = Color(1, 0.05, 0.05, 1)
		if dist_to_origin() < 0.3:
			state = State.PATROL
			if $Mesh.material_override: $Mesh.material_override.albedo_color = Color(1, 0.15, 0.15, 1)
			idx = find_nearest_waypoint()

	match state:
		State.PATROL:
			do_patrol(dt)
		State.CHASE:
			do_chase(dt)
		State.RETURN:
			do_return(dt)

func attack_dir() -> Vector3:
	if player:
		return (global_position - player.global_position).normalized()
	return Vector3.ZERO

var _find_timer = 0.0

func find_player():
	_find_timer -= 0.0
	if _find_timer > 0 and player and is_instance_valid(player):
		return
	_find_timer = 0.5
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func distance_to_player():
	if not player:
		return 9999.0
	return (global_position - player.global_position).length()

func dist_to_origin():
	return (global_position - origin).length()

func find_nearest_waypoint():
	if wps.is_empty():
		return 0
	var best = 0
	var best_dist = 9999.0
	for i in range(wps.size()):
		var d = (global_position - wps[i]).length()
		if d < best_dist:
			best_dist = d
			best = i
	return best

func do_patrol(dt):
	if wps.is_empty():
		return
	if waiting:
		wtimer -= dt
		if wtimer <= 0:
			waiting = false
			idx = (idx + 1) % wps.size()
		return
	var tp = wps[idx]
	var pos = global_position
	var dir = Vector3(tp.x - pos.x, 0, tp.z - pos.z)
	if dir.length() < 0.4:
		waiting = true
		wtimer = wait_time
	else:
		dir = dir.normalized()
		move_in_dir(dir, patrol_speed, dt)

func do_chase(dt):
	if not player:
		return
	var dir = player.global_position - global_position
	dir.y = 0
	if dir.length() < 0.4:
		return
	dir = dir.normalized()
	var spd = chase_speed * (sprint_mult if sprint else 1.0)
	move_in_dir(dir, spd, dt)

func do_return(dt):
	var dir = origin - global_position
	dir.y = 0
	if dir.length() < 0.3:
		global_position = origin
		return
	dir = dir.normalized()
	move_in_dir(dir, patrol_speed * 1.5, dt)

func move_in_dir(dir, spd, dt):
	var pos = global_position
	pos.x += dir.x * spd * dt
	pos.z += dir.z * spd * dt
	pos.y = 0.7
	# Clamp within level bounds (prevent walking through walls)
	# Dynamically determine half-size from ground mesh if available
	var half_size = 8.0
	var ground = get_tree().current_scene.get_node_or_null("Ground")
	if ground and ground.mesh:
		var mesh_size = ground.mesh.size
		half_size = min(abs(mesh_size.x), abs(mesh_size.z)) / 2.0 - 2.0
	pos.x = clamp(pos.x, -half_size, half_size)
	pos.z = clamp(pos.z, -half_size, half_size)
	global_position = pos
	rotation.y = atan2(dir.x, dir.z)

func _hit(body):
	if body.is_in_group("player") and body.has_method("take_hit"):
		# Check if player is above (stomp kill)
		if body.global_position.y > global_position.y + 1.0:
			kill()
		else:
			body.take_hit(attack_dir())

func kill():
	# Death effect
	var dp = CPUParticles3D.new()
	dp.one_shot = true
	dp.emitting = true
	dp.amount = 25
	dp.lifetime = 0.6
	dp.local_coords = true
	dp.direction = Vector3(0, 2, 0)
	dp.spread = 120.0
	dp.gravity = Vector3(0, -6, 0)
	dp.velocity_min = 2.0
	dp.color = Color(1, 0.3, 0.1, 1)
	dp.position = Vector3(0, 1, 0)
	add_child(dp)
	AudioManager.play("death")
	GameManager.add_score(3)
	$Mesh.visible = false
	$Col.set_deferred("disabled", true)
	await get_tree().create_timer(1.0).timeout
	queue_free()
