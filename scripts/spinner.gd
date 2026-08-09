extends Area3D

# 旋转障碍物：围绕某个轴旋转，碰到玩家造成伤害
@export var spin_speed = 90.0
@export var damage = 1
var hit_cooldown = 0.0

func _ready():
	body_entered.connect(_hit)
	GameManager.game_started.connect(_on_game_started)
	# 给 spinner 添加可见材质
	if not $Mesh.material_override:
		var spin_mat = StandardMaterial3D.new()
		spin_mat.albedo_color = Color(0.55, 0.35, 0.2, 1)
		spin_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		$Mesh.material_override = spin_mat

func _process(dt):
	if GameManager.state != GameManager.State.PLAYING:
		return
	rotation_degrees.y += spin_speed * dt
	hit_cooldown = max(hit_cooldown - dt, 0.0)

func _hit(body):
	if body.is_in_group("player") and body.has_method("take_hit") and hit_cooldown <= 0.0:
		body.take_hit(Vector3(0, 0, 1))
		hit_cooldown = 0.5

func _on_game_started():
	if not is_inside_tree():
		return
	hit_cooldown = 0.0
