extends Control

onready var s = $Score
onready var t = $Timer
onready var count = $Countdown
onready var lvl = $LevelLabel
var pulse = 0.0
var hits = 3

func _ready():
	GameManager.connect("score_changed", self, "_sc")
	GameManager.connect("timer_changed", self, "_tm")
	GameManager.connect("state_changed", self, "_st")
	GameManager.connect("game_started", self, "_gs")
	GameManager.connect("countdown_tick", self, "_ct")
	GameManager.connect("countdown_done", self, "_gd")
	if count:
		count.visible = false
	visible = false

func _process(dt):
	if visible:
		pulse += dt
		_sync_hits()

func _sync_hits():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].has_method("get_hits"):
		var v = players[0].get_hits()
		if v != hits:
			hits = v
			_update_level()

func _sc(v):
	s.text = "Coins: " + str(v) + "/" + str(GameManager.target)

func _tm(v):
	var sec = int(ceil(v))
	t.text = "Time: " + str(sec) + "s"
	if v <= 10.0:
		var c = abs(sin(pulse * 6.0))
		t.add_color_override("font_color", Color(1, c * 0.5, c * 0.5, 1))
	else:
		t.add_color_override("font_color", Color(1, 1, 1, 1))

func _st(st):
	visible = (st == GameManager.State.PLAYING)

func _ct(v):
	if count:
		if v > 0:
			count.text = str(v)
		else:
			count.text = "GO!"
		count.visible = true

func _gd():
	if count:
		count.visible = false

func _update_level():
	if lvl:
		var cur = GameManager.current_level
		lvl.text = "Level " + str(cur + 1) + "   Hits left: " + str(max(hits, 0))
		lvl.visible = true

func _gs():
	_update_level()
	s.text = "Coins: 0/" + str(GameManager.target)
	t.text = "Time: " + str(int(GameManager.duration)) + "s"
	t.add_color_override("font_color", Color(1, 1, 1, 1))