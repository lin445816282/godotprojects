extends Area3D

enum Tier { COPPER, SILVER, GOLD }
@export var tier: Tier = Tier.COPPER
@export var worth = 1
@export var respawn_time = 12.0
var taken = false
var base_y = 0.0
var atime = 0.0
var ptimer = 0.0

func burst_particles():
	var cp = CPUParticles3D.new()
	cp.one_shot = true
	cp.emitting = true
	cp.amount = 20
	cp.lifetime = 0.6
	cp.local_coords = true
	cp.direction = Vector3(0, 1, 0)
	cp.spread = 45.0
	cp.gravity = Vector3(0, -9, 0)
	cp.velocity_min = 4.0
	cp.scale_amount_min = 0.08
	cp.color = Color(1, 0.85, 0.1, 1)
	add_child(cp)
	await get_tree().create_timer(0.7).timeout
	cp.queue_free()

func _ready():
	body_entered.connect(_pick)
	GameManager.game_started.connect(_on_game_started)
	add_to_group("coins")
	base_y = global_position.y
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
	var m = StandardMaterial3D.new()
	m.albedo_color = col
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.emission_enabled = true
	m.emission = col
	m.emission_energy_multiplier = 1.5
	$Mesh.material_override = m

func _process(dt):
	if taken:
		ptimer -= dt
		if ptimer > 0:
			var t = ptimer / 0.25
			var sx = 1.0 + t * 0.8
			scale = Vector3(sx, sx, sx)
		elif ptimer <= 0 and ptimer > -respawn_time:
			if $Mesh.visible:
				$Mesh.visible = false
		elif ptimer <= -respawn_time:
			taken = false
			ptimer = 0.0
			scale = Vector3(1, 1, 1)
			$Mesh.visible = true
			$Col.set_deferred("disabled", false)
		return
	atime += dt
	var near = false
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		near = (global_position - players[0].global_position).length() < 5.0
	if not near:
		var pos = global_position
		pos.y = base_y + sin(atime * 3.0) * 0.2
		global_position = pos
	rotate_y(dt * 2.5)
	check_proximity_collect()

func check_proximity_collect():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return
	var p = players[0]
	var dist = (global_position - p.global_position).length()
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
	$Col.set_deferred("disabled", true)

func _on_game_started():
	if not is_inside_tree():
		return
	taken = false
	ptimer = 0.0
	scale = Vector3(1, 1, 1)
	$Mesh.visible = true
	$Col.set_deferred("disabled", false)
	base_y = global_position.y
