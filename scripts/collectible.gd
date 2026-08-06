extends Area

var taken = false
var base_y = 0.0
var atime = 0.0
var ptimer = 0.0

func _ready():
	connect("body_entered", self, "_pick")
	GameManager.connect("game_started", self, "_on_game_started")
	add_to_group("coins")
	base_y = global_transform.origin.y
	atime = randf() * TAU

func _process(dt):
	if taken:
		ptimer -= dt
		if ptimer > 0:
			var t = ptimer / 0.25
			var sx = 1.0 + t * 0.8
			scale = Vector3(sx, sx, sx)
		elif $Mesh.visible and ptimer <= 0:
			$Mesh.visible = false
		return
	atime += dt
	var pos = global_transform.origin
	pos.y = base_y + sin(atime * 3.0) * 0.2
	global_transform.origin = pos
	rotate_y(dt * 2.5)

func _pick(body):
	if taken or not body.is_in_group("player"):
		return
	taken = true
	ptimer = 0.25
	GameManager.add_score(1)
	if body.has_method("collect_coin_effect"):
		body.collect_coin_effect()
	$Col.disabled = true

func _on_game_started():
	taken = false
	ptimer = 0.0
	scale = Vector3(1, 1, 1)
	$Mesh.visible = true
	$Col.disabled = false
	base_y = global_transform.origin.y