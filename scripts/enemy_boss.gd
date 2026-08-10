extends Area3D

# Boss敌人：大块头、3阶段、弹幕攻击
@export var max_health = 30
var health = 30
var phase = 0           # 1,2,3
var player = null
var atk_cd = 0.0
var origin = Vector3.ZERO
var float_t = 0.0


func _ready():
	body_entered.connect(_hit)
	GameManager.game_started.connect(_on_game_started)
	origin = global_position
	if $Mesh.material_override:
		$Mesh.material_override = $Mesh.material_override.duplicate()
		$Mesh.material_override.albedo_color = Color(1, 0.1, 0.1, 1)
		$Mesh.material_override
		$Mesh.material_override.emission = Color(1, 0.05, 0.05, 1)
		$Mesh.material_override.emission_energy_multiplier = 3.0
	$Mesh.scale = Vector3(2.0, 2.5, 2.0)

func _on_game_started():
	if not is_inside_tree():
		return
	health = max_health
	phase = 1
	atk_cd = 2.0
	global_position = origin
	if $Mesh.material_override:
		$Mesh.material_override.albedo_color = Color(1, 0.1, 0.1, 1)
	$Mesh.visible = true
	$Col.set_deferred("disabled", false)

func _process(dt):
	if GameManager.state != GameManager.State.PLAYING:
		return
	find_player()
	float_t += dt
	var pos = global_position
	pos.y = origin.y + sin(float_t * 1.5) * 1.0
	global_position = pos
	atk_cd -= dt

	if not player:
		return

	var dir = player.global_position - global_position
	dir.y = 0
	rotation.y = atan2(dir.x, dir.z)

	# Phase transitions
	if health <= max_health * 0.66 and phase == 1:
		phase = 2
		if $Mesh.material_override:
			$Mesh.material_override.albedo_color = Color(1, 0.4, 0.1, 1)
	elif health <= max_health * 0.33 and phase == 2:
		phase = 3
		if $Mesh.material_override:
			$Mesh.material_override.albedo_color = Color(0.8, 0.8, 0.1, 1)

	if atk_cd <= 0:
		# Mix charge + shoot in higher phases
		if phase >= 2 and randi() % 3 == 0:
			_charge_attack()
		else:
			match phase:
				1: shoot_pattern(1, 1.5)
				2: shoot_pattern(3, 1.2)
				3: shoot_pattern(5, 1.0)


func _charge_attack():
	if not player:
		return
	atk_cd = 1.5
	var dir = (player.global_position - global_position).normalized()
	var tween = create_tween()
	tween.tween_property(self, "global_position", global_position + dir * 6.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.15).timeout
	if player and global_position.distance_to(player.global_position) < 2.5:
		if player.has_method("take_hit"):
			player.take_hit(-dir)

func shoot_pattern(count, cd):
	atk_cd = cd
	if not player:
		return
	var base_dir = (player.global_position - global_position).normalized()
	for i in range(count):
		var ang = deg_to_rad((i - (count - 1) / 2.0) * 20.0)
		var d = base_dir.rotated(Vector3.UP, ang)
		var b = Area3D.new()
		b.position = global_position + Vector3(0, 1.5, 0)
		# Bullet mesh
		var mesh = MeshInstance3D.new()
		var sm = SphereMesh.new()
		sm.radius = 0.25
		sm.height = 0.5
		mesh.mesh = sm
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(1, 0.2, 0.2, 1)
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.emission_enabled = true
		mat.emission = Color(1, 0.1, 0.1, 1)
		mat.emission_energy_multiplier = 2.0
		mesh.material_override = mat
		b.add_child(mesh)
		# Collision
		var col = CollisionShape3D.new()
		var cs = SphereShape3D.new()
		cs.radius = 0.3
		col.shape = cs
		b.add_child(col)
		b.body_entered.connect(_bullet_hit.bind(b))
		b.set_meta("dir", d)
		b.set_meta("speed", 6.0)
		b.set_meta("life", 3.0)
		get_parent().add_child(b)
		b.add_to_group("boss_projectiles")

func _bullet_hit(body, bullet):
	if body.is_in_group("player") and body.has_method("take_hit"):
		body.take_hit(Vector3(0, 0, 1))
		if is_instance_valid(bullet):
			bullet.queue_free()

var _find_timer = 0.0

func find_player():
	_find_timer -= 0.0
	if _find_timer > 0 and player and is_instance_valid(player):
		return
	_find_timer = 0.3
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _hit(body):
	if body.is_in_group("player") and body.has_method("take_hit"):
		if body.global_position.y > global_position.y + 1.5:
			take_damage(5)
		else:
			body.take_hit((body.global_position - global_position).normalized())

func take_damage(amount):
	if GameManager.state != GameManager.State.PLAYING or health <= 0:
		return
	health -= amount
	AudioManager.play("death")
	if health <= 0:
		$Mesh.visible = false
		$Col.set_deferred("disabled", true)
		for c in get_parent().get_children():
			if c.is_in_group("boss_projectiles"):
				c.queue_free()
		GameManager.add_score(10)
		await get_tree().create_timer(0.5).timeout
		GameManager.add_score(10)
		_on_level_complete_boss()

func _on_level_complete_boss():
	LevelManager.record_score(GameManager.current_level, GameManager.score)
	LevelManager.unlock_next()
	GameManager._change(GameManager.State.WIN)
