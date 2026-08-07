extends Control

onready var s = $Score
onready var t = $Timer
onready var count = $Countdown
var pulse = 0.0

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

func _gs():
	s.text = "Coins: 0/" + str(GameManager.target)
	t.text = "Time: " + str(int(GameManager.duration)) + "s"
	t.add_color_override("font_color", Color(1, 1, 1, 1))