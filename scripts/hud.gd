extends Control

@onready var s = $Score
@onready var t = $Timer
@onready var count = $Countdown
@onready var lvl = $LevelLabel
var pulse = 0.0
var hits = 3
var flash_timer = 0.0
var red_flash = null

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

func _process(dt):
	if visible:
		pulse += dt
		_sync_hits()
		if red_flash and flash_timer > 0.0:
			flash_timer -= dt
			red_flash.color.a = flash_timer / 0.3 * 0.4

func _sync_hits():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].has_method("get_hits"):
		var v = players[0].get_hits()
		if v != hits:
			hits = v
			_update_level()

func _sc(v):
	var prev = 0
	if "/" in s.text:
		var parts = s.text.split("Coins: ")[1].split("/")[0]
		prev = int(parts)
	if v > prev:
		spawn_feedback(v - prev)
	s.text = "Coins: " + str(v) + "/" + str(GameManager.target)

func spawn_feedback(delta):
	var lbl = Label.new()
	lbl.text = "+" + str(delta)
	lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.1, 1))
	lbl.anchor_left = 0.5
	lbl.anchor_top = 0.5
	lbl.anchor_right = 0.5
	lbl.anchor_bottom = 0.5
	lbl.offset_left = -40
	lbl.offset_top = -20
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(lbl)
	var tw = create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 60, 0.7)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.7)
	tw.tween_callback(lbl.queue_free)

func _tm(v):
	var sec = int(ceil(v))
	t.text = "Time: " + str(sec) + "s"
	if v <= 10.0:
		t.add_theme_color_override("font_color", Color(1, 0.5, 0.5, 1))
	else:
		t.add_theme_color_override("font_color", Color(1, 1, 1, 1))

func damage_flash():
	if not red_flash:
		red_flash = ColorRect.new()
		red_flash.color = Color(1, 0.1, 0.1, 0)
		red_flash.anchor_right = 1.0
		red_flash.anchor_bottom = 1.0
		red_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(red_flash)
	red_flash.color.a = 0.4
	flash_timer = 0.3

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
		lvl.text = "Level " + str(cur + 1) + "   Hits left: " + str(max(0, 3 - hits))
		lvl.visible = true

func _gs():
	_update_level()
	s.text = "Coins: 0/" + str(GameManager.target)
	t.text = "Time: " + str(int(GameManager.duration)) + "s"
	t.add_theme_color_override("font_color", Color(1, 1, 1, 1))
