extends Area3D

# 跳跃型敌人：上下弹跳阻塞跳跃线路，触碰到玩家造成伤害
@export var hop_amp = 1.5
@export var hop_freq = 1.0
var base_y = 0.0
var t = 0.0

func _ready():
	body_entered.connect(_hit)
	GameManager.game_started.connect(_on_game_started)
	base_y = global_position.y

func _process(dt):
	if GameManager.state != GameManager.State.PLAYING:
		return
	t += dt
	var pos = global_position
	pos.y = base_y + abs(sin(t * hop_freq)) * hop_amp
	global_position = pos

func _hit(body):
	if body.is_in_group("player") and body.has_method("take_hit"):
		body.take_hit(Vector3(0, 0, 0))

func _on_game_started():
	if not is_inside_tree():
		return
	t = 0.0
	global_position.y = base_y
