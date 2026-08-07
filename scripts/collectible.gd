extends Area

enum Tier { COPPER, SILVER, GOLD }
export(Tier) var tier = Tier.COPPER
export var worth = 1
var taken = false
var base_y = 0.0
var atime = 0.0
var ptimer = 0.0

func burst_particles():
	var cp = CPUParticles.new()
	cp.one_shot = true
	cp.emitting = true
	cp.amount = 20
	cp.lifetime = 0.6
	cp.local_coords = true
	cp.direction = Vector3(0, 1, 0)
	cp.spread = 45.0
	cp.gravity = Vector3(0, -9, 0)
	cp.initial_velocity = 4.0
	cp.scale_amount = 0.08
	cp.color = Color(1, 0.85, 0.1, 1)
	add_child(cp)
	yield(get_tree().create_timer(0.7), "timeout")
	cp.queue_free()

func _ready():
	connect("body_entered", self, "_pick")
	GameManager.connect("game_started", self, "_on_game_started")
	add_to_group("coins")
	base_y = global_transform.origin.y
	atime = randf() * TAU
	_apply_tier()

func _apply_tier():
	var col = Color(1, 0.6, 0.1, 1)
	match tier:
		Tier.SILVER:
			col = Color(0.85, 0.85, 0.9, 1)
			worth = 3
		Tier.GOLD:
			col = Color(1, 0.8, 0.1, 1)
			worth = 5
		_:
			col = Color(1, 0.6, 0.1, 1)
			worth = 1
	var m
	if $Mesh.material_override == null:
		m = SpatialMaterial.new()
	else:
		m = $Mesh.material_override.duplicate()
	m.albedo_color = col
	m.emission_enabled = true
	m.emission_color = col
	m.emission_energy = 1.5
	$Mesh.material_override = m

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
	var near = false
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		near = (global_transform.origin - players[0].global_transform.origin).length() < 5.0
	if not near:
		var pos = global_transform.origin
		pos.y = base_y + sin(atime * 3.0) * 0.2
		global_transform.origin = pos
	rotate_y(dt * 2.5)
	check_proximity_collect()

func check_proximity_collect():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return
	var p = players[0]
	var dist = (global_transform.origin - p.global_transform.origin).length()
	if dist < 0.8:
		_pick(p)

func _pick(body):
	if taken or not body.is_in_group("player"):
		return
	taken = true
	ptimer = 0.25
	AudioManager.play("coin" if tier == Tier.COPPER else "coin2" if tier == Tier.SILVER else "coin3")
	GameManager.add_score(worth)
	burst_particles()
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
