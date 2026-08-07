extends Area

# 跳跃型敌人：上下弹跳阻塞跳跃线路，触碰到玩家造成伤害
export var hop_amp = 1.5
export var hop_freq = 1.0
var base_y = 0.0
var t = 0.0

func _ready():
	connect("body_entered", self, "_hit")
	GameManager.connect("game_started", self, "_on_game_started")
	base_y = global_transform.origin.y

func _process(dt):
	if GameManager.state != GameManager.State.PLAYING:
		return
	t += dt
	var pos = global_transform.origin
	pos.y = base_y + abs(sin(t * hop_freq)) * hop_amp
	global_transform.origin = pos

func _hit(body):
	if body.is_in_group("player") and body.has_method("take_hit"):
		body.take_hit(Vector3(0, 0, 0))

func _on_game_started():
	t = 0.0
	global_transform.origin.y = base_y
