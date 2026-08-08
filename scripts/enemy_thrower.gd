extends Spatial

# 投掷型敌人：固定在某个位置，周期性向玩家发射投射物
export var fire_rate = 2.0
export var bullet_speed = 6.0
var timer = 0.0
var player = null

func _ready():
	GameManager.connect("game_started", self, "_on_game_started")

func _on_game_started():
	timer = fire_rate * randf()

func _process(dt):
	if GameManager.state != GameManager.State.PLAYING:
		return
	find_player()
	if not player:
		return
	timer -= dt
	if timer <= 0:
		timer = fire_rate
		fire()

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func fire():
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	var b = Area.new()
	b.translation = global_transform.origin + Vector3(0, 0.8, 0)
	var mesh = MeshInstance.new()
	var sm = SphereMesh.new()
	sm.radius = 0.2
	sm.height = 0.4
	mesh.mesh = sm
	var mat = SpatialMaterial.new()
	mat.albedo_color = Color(1, 0.3, 0.1, 1)
	mat.emission_enabled = true
	mat.emission_color = Color(1, 0.2, 0.0, 1)
	mat.emission_energy = 1.5
	mesh.material_override = mat
	b.add_child(mesh)
	var col = CollisionShape.new()
	var cs = SphereShape.new()
	cs.radius = 0.25
	col.shape = cs
	b.add_child(col)
	b.connect("body_entered", self, "_bullet_hit", [b])
	b.set_meta("vel", dir * bullet_speed)
	b.set_meta("life", 4.0)
	b.add_to_group("thrower_bullets")
	get_parent().add_child(b)

func _bullet_hit(body, bullet):
	if body.is_in_group("player") and body.has_method("take_hit"):
		body.take_hit(Vector3(0, 0, 1))
	if is_instance_valid(bullet):
		bullet.queue_free()
