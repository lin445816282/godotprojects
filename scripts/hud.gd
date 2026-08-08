extends Control

onready var s = $Score
onready var t = $Timer
onready var count = $Countdown
onready var lvl = $LevelLabel
var pulse = 0.0
var hits = 3
var flash_timer = 0.0

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


func _sync_hits():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].has_method("get_hits"):
		var v = players[0].get_hits()
		if v != hits:
			hits = v
			_update_level()

var popup_text = ""

func _sc(v):
	var prev = int(s.text.split("//")[0].replace("Coins: ", "").split("/")[0]) if "/" in s.text else 0
	if v > prev:
		spawn_feedback(v - prev)
	s.text = "Coins: " + str(v) + "/" + str(GameManager.target)

func spawn_feedback(delta):
	var lbl = Label.new()
	lbl.text = "+" + str(delta)
	lbl.add_color_override("font_color", Color(1, 0.85, 0.1, 1))
	lbl.anchor_left = 0.5
	lbl.anchor_top = 0.5
	lbl.anchor_right = 0.5
	lbl.anchor_bottom = 0.5
	margin = -0.0
	lbl.rect_position = Vector2(-40, -20)
	lbl.align = 1
	add_child(lbl)
	yield(get_tree().create_timer(0.1), "timeout")
	if lbl:
		var t = 0.0
		while t < 0.7 and is_instance_valid(lbl):
			t += get_process_delta_time()
			lbl.rect_position.y -= 1.2
			lbl.modulate.a = 1.0 - t / 0.7
		lbl.queue_free()

func _tm(v):
	var sec = int(ceil(v))
	t.text = "Time: " + str(sec) + "s"
	if v <= 10.0:
		var c = abs(sin(pulse * 6.0))
		t.add_color_override("font_color", Color(1, c * 0.5, c * 0.5, 1))
	else:
		t.add_color_override("font_color", Color(1, 1, 1, 1))

var red_flash = null

func damage_flash():
	if not red_flash:
		red_flash = ColorRect.new()
		red_flash.color = Color(1, 0.1, 0.1, 0)
		red_flash.anchor_right = 1.0
		red_flash.anchor_bottom = 1.0
		red_flash.mouse_filter = 2
		add_child(red_flash)
	red_flash.color.a = 0.4
	red_flash.color.r = 1.0
	red_flash.color.g = 0.1
	red_flash.color.b = 0.1
	flash_timer = 0.3

func _process(dt):
	if visible:
		pulse += dt
		_sync_hits()
		if red_flash and flash_timer > 0.0:
			flash_timer -= dt
			red_flash.color.a = flash_timer / 0.3 * 0.4

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
