extends Control

@onready var s = $Score
@onready var t = $Timer
@onready var count = $Countdown
@onready var lvl = $LevelLabel
var pulse = 0.0
var hits = 3
var flash_timer = 0.0

func _ready():
	GameManager.score_changed.connect(_sc)
	GameManager.timer_changed.connect(_tm)
	GameManager.state_changed.connect(_st)
	GameManager.game_started.connect(_gs)
	GameManager.countdown_tick.connect(_ct)
	GameManager.countdown_done.connect(_gd)
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
	s.text = I18n.t("coins_prefix") + str(v) + "/" + str(GameManager.target)

func spawn_feedback(delta):
	var lbl = Label.new()
	lbl.text = "+" + str(delta)
	lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.1, 1))
	lbl.anchor_left = 0.5
	lbl.anchor_top = 0.5
	lbl.anchor_right = 0.5
	lbl.anchor_bottom = 0.5
	lbl.position = Vector2(-40, -20)
	lbl.align = 1
	add_child(lbl)
	await get_tree().create_timer(0.1).timeout
	if lbl:
		var t = 0.0
		while t < 0.7 and is_instance_valid(lbl):
			t += get_process_delta_time()
			lbl.position.y -= 1.2
			lbl.modulate.a = 1.0 - t / 0.7
		lbl.queue_free()

func _tm(v):
	var sec = int(ceil(v))
	t.text = I18n.t("time_prefix") + str(sec) + "s"
	if v <= 10.0:
		var c = abs(sin(pulse * 6.0))
		t.add_theme_color_override("font_color", Color(1, c * 0.5, c * 0.5, 1))
	else:
		t.add_theme_color_override("font_color", Color(1, 1, 1, 1))

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
			count.text = I18n.t("go_text")
		count.visible = true

func _gd():
	if count:
		count.visible = false

func _update_level():
	if lvl:
		var cur = GameManager.current_level
		lvl.text = I18n.t("level_prefix") + str(cur + 1)
		lvl.visible = true
	_update_health_bars()

var health_bars = []

func _update_health_bars():
	var players = get_tree().get_nodes_in_group("player")
	var max_hits = 3
	var cur_hits = hits
	if players.size() > 0 and players[0].has_method("get_hits"):
		max_hits = 3
		cur_hits = players[0].get_hits()
	cur_hits = max(cur_hits, 0)
	# Remove old bars
	for b in health_bars:
		if is_instance_valid(b):
			b.queue_free()
	health_bars.clear()
	# Create health bar container
	var hbox = HBoxContainer.new()
	hbox.name = "HealthBars"
	hbox.anchor_left = 0.02
	hbox.anchor_top = 0.12
	hbox.custom_minimum_size = Vector2(120, 10)
	add_child(hbox)
	health_bars.append(hbox)
	for i in range(max_hits):
		var seg = ColorRect.new()
		seg.custom_minimum_size = Vector2(30, 8)
		if i < cur_hits:
			seg.color = Color(0.2, 0.9, 0.2, 1)
		else:
			seg.color = Color(0.3, 0.1, 0.1, 1)
		hbox.add_child(seg)
		var gap = ColorRect.new()
		gap.custom_minimum_size = Vector2(3, 8)
		gap.color = Color(0, 0, 0, 0)
		hbox.add_child(gap)
		health_bars.append(gap)

func _gs():
	_update_level()
	_update_health_bars()
	s.text = I18n.t("coins_prefix") + "0/" + str(GameManager.target)
	t.text = I18n.t("time_prefix") + str(int(GameManager.duration)) + "s"
	t.add_theme_color_override("font_color", Color(1, 1, 1, 1))
