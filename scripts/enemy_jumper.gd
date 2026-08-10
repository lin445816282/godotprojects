extends Area3D

# 跳跃型敌人：上下弹跳阻塞跳跃线路，触碰到玩家造成伤害
@export var hop_amp = 1.5
@export var hop_freq = 1.0
var base_y = 0.0
var t = 0.0
var hit_cooldown = 0.0

func _ready():
	body_entered.connect(_hit)
	GameManager.game_started.connect(_on_game_started)
	base_y = global_position.y

func _process(dt):
	if GameManager.state != GameManager.State.PLAYING:
		return
	t += dt
	hit_cooldown = max(hit_cooldown - dt, 0.0)
	var pos = global_position
	pos.y = base_y + abs(sin(t * hop_freq)) * hop_amp
	global_position = pos

func _hit(body):
	if body.is_in_group("player") and body.has_method("take_hit") and hit_cooldown <= 0.0:
		if body.global_position.y > global_position.y + 1.0:
			kill()
		else:
			body.take_hit(Vector3(0, 0, 0))
			hit_cooldown = 0.5

func kill():
	var dp = CPUParticles3D.new()
	dp.one_shot = true
	dp.emitting = true
	dp.amount = 20
	dp.lifetime = 0.5
	dp.local_coords = true
	dp.direction = Vector3(0, 2, 0)
	dp.spread = 100.0
	dp.gravity = Vector3(0, -5, 0)
	dp.velocity_min = 2.0
	dp.color = Color(0.2, 0.8, 0.9, 1)
	dp.position = Vector3(0, 0.5, 0)
	add_child(dp)
	AudioManager.play("death")
	GameManager.add_score(2)
	$Mesh.visible = false
	$Col.set_deferred("disabled", true)
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_game_started():
	if not is_inside_tree():
		return
	t = 0.0
	hit_cooldown = 0.0
	global_position.y = base_y
