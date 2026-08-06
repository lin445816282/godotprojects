extends Area

export var speed = 2.0
export var wait_time = 0.8
var wps = []
var idx = 0
var waiting = false
var wtimer = 0.0
var origin = Vector3.ZERO
var pulse = 0.0

func _ready():
	connect("body_entered", self, "_hit")
	GameManager.connect("game_started", self, "_on_game_started")
	for c in get_children():
		if c is Position3D and c.name.begins_with("WP"):
			wps.append(c.global_transform.origin)
	origin = global_transform.origin

func _on_game_started():
	idx = 0
	waiting = false
	wtimer = 0.0
	pulse = 0.0
	global_transform.origin = origin
	$Mesh.material_override.albedo_color = Color(1, 0.15, 0.15, 1)

func _process(dt):
	pulse += dt
	var sc = 1.0 + sin(pulse * 4.0) * 0.08
	$Mesh.scale = Vector3(sc, 1.0, sc)
	if wps.empty() or GameManager.state != GameManager.State.PLAYING:
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
	var dist = dir.length()
	if dist < 0.4:
		waiting = true
		wtimer = wait_time
	else:
		dir = dir.normalized()
		pos.x += dir.x * speed * dt
		pos.z += dir.z * speed * dt
		pos.y = 0.7
		global_transform.origin = pos
		rotation.y = atan2(dir.x, dir.z)

func _hit(body):
	if body.is_in_group("player") and body.has_method("die"):
		body.die()