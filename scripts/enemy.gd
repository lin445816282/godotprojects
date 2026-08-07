extends Area

enum State { PATROL, CHASE, RETURN }
export var patrol_speed = 2.0
export var chase_speed = 4.0
export var wait_time = 0.8
export var detect_range = 4.0
export var attack_cooldown = 1.0
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
	connect("body_entered", self, "_hit")
	GameManager.connect("game_started", self, "_on_game_started")
	_setup_glow()

func _setup_glow():
	if $Mesh.material_override:
		var m = $Mesh.material_override.duplicate()
		m.emission_enabled = true
		m.emission_color = Color(1, 0.2, 0.2, 1)
		m.emission_energy = 2.0
		$Mesh.material_override = m
	for c in get_children():
		if c is Position3D and c.name.begins_with("WP"):
			wps.append(c.global_transform.origin)
	origin = global_transform.origin

func _on_game_started():
	state = State.PATROL
	idx = 0
	waiting = false
	wtimer = 0.0
	pulse = 0.0
	player = null
	global_transform.origin = origin
	$Mesh.material_override.albedo_color = Color(1, 0.15, 0.15, 1)

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
			$Mesh.material_override.albedo_color = Color(1, 0.5, 0.1, 1)
		elif dist_to_player <= 0.8 and attack_timer <= 0.0:
			_hit(player)
			attack_timer = attack_cooldown
			return
	elif state == State.PATROL:
		if player and dist_to_player < detect_range:
			state = State.CHASE
			$Mesh.material_override.albedo_color = Color(1, 0.05, 0.05, 1)
	elif state == State.RETURN:
		if dist_to_player < detect_range:
			state = State.CHASE
			$Mesh.material_override.albedo_color = Color(1, 0.05, 0.05, 1)
		if dist_to_origin() < 0.3:
			state = State.PATROL
			$Mesh.material_override.albedo_color = Color(1, 0.15, 0.15, 1)
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
		return (global_transform.origin - player.global_transform.origin).normalized()
	return Vector3.ZERO

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func distance_to_player():
	if not player:
		return 9999.0
	return (global_transform.origin - player.global_transform.origin).length()

func dist_to_origin():
	return (global_transform.origin - origin).length()

func find_nearest_waypoint():
	if wps.empty():
		return 0
	var best = 0
	var best_dist = 9999.0
	for i in range(wps.size()):
		var d = (global_transform.origin - wps[i]).length()
		if d < best_dist:
			best_dist = d
			best = i
	return best

func do_patrol(dt):
	if wps.empty():
		return
	if waiting:
		wtimer -= dt
		if wtimer <= 0:
			waiting = false
			idx = (idx + 1) % wps.size()
		return
	var tp = wps[idx]
	var pos = global_transform.origin
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
	var dir = player.global_transform.origin - global_transform.origin
	dir.y = 0
	if dir.length() < 0.4:
		return
	dir = dir.normalized()
	move_in_dir(dir, chase_speed, dt)

func do_return(dt):
	var dir = origin - global_transform.origin
	dir.y = 0
	if dir.length() < 0.3:
		global_transform.origin = origin
		return
	dir = dir.normalized()
	move_in_dir(dir, patrol_speed * 1.5, dt)

func move_in_dir(dir, spd, dt):
	var pos = global_transform.origin
	pos.x += dir.x * spd * dt
	pos.z += dir.z * spd * dt
	pos.y = 0.7
	global_transform.origin = pos
	rotation.y = atan2(dir.x, dir.z)

func _hit(body):
	if body.is_in_group("player") and body.has_method("take_hit"):
		body.take_hit(attack_dir())