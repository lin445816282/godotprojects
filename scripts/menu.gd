extends Control

var time = 0.0
var state_anim = false

@onready var title = $Panel/Title
@onready var info = $Panel/Info
@onready var start = $Panel/StartBtn
@onready var restart = $Panel/RestartBtn
@onready var quit = $Panel/QuitBtn
@onready var lvl2 = $Panel/Level2Btn
@onready var backmenu = $Panel/BackMenuBtn
@onready var next = $Panel/NextBtn
@onready var lvl3 = $Panel/Level3Btn
@onready var shade = $"..//Shade"
@onready var sens = $Panel/SensSlider
@onready var sfx = $Panel/SfxSlider
@onready var music = $Panel/MusicSlider
var keybtns = []
var listening_action = ""


func _build_ui():
	var shade_rect = ColorRect.new()
	shade_rect.name = "Shade"
	shade_rect.anchor_right = 1.0
	shade_rect.anchor_bottom = 1.0
	add_child(shade_rect)
	var panel = Panel.new()
	panel.name = "Panel"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.margin_left = -200
	panel.margin_top = -150
	panel.margin_right = 200
	panel.margin_bottom = 150
	add_child(panel)
	for item in [["Title", "Label", 0, 20, 400, 50], ["Info", "Label", 0, 60, 400, 100],
	             ["StartBtn", "Button", 100, 160, 200, 40], ["Level2Btn", "Button", 100, 210, 200, 40],
	             ["Level3Btn", "Button", 100, 260, 200, 40], ["NextBtn", "Button", 100, 310, 200, 40],
	             ["BackMenuBtn", "Button", 100, 360, 200, 40], ["QuitBtn", "Button", 100, 410, 200, 40],
	             ["RestartBtn", "Button", 100, 460, 200, 40],
	             ["move_forwardBtn", "Button", 10, 510, 70, 30], ["move_backwardBtn", "Button", 85, 510, 70, 30],
	             ["move_leftBtn", "Button", 160, 510, 70, 30], ["move_rightBtn", "Button", 235, 510, 70, 30],
	             ["jumpBtn", "Button", 310, 510, 70, 30],
	             ["SfxSlider", "HSlider", 10, 550, 180, 20], ["MusicSlider", "HSlider", 210, 550, 180, 20],
	             ["VolLabel", "Label", 10, 575, 180, 20], ["SensLabel", "Label", 210, 575, 180, 20],
	             ["SensSlider", "HSlider", 10, 600, 380, 20]]:
		var node: Control
		if item[1] == "Button":
			node = Button.new()
		elif item[1] == "HSlider":
			node = HSlider.new()
		else:
			node = Label.new()
		node.name = item[0]
		node.position = Vector2(item[2], item[3])
		node.size = Vector2(item[4], item[5])
		panel.add_child(node)

func _ready():
	if not $Panel:
		_build_ui()
	# Re-get references
	title = $Panel/Title if has_node("Panel/Title") else null
	info = $Panel/Info if has_node("Panel/Info") else null
	start = $Panel/StartBtn if has_node("Panel/StartBtn") else null
	restart = $Panel/RestartBtn if has_node("Panel/RestartBtn") else null
	quitbtn = $Panel/QuitBtn if has_node("Panel/QuitBtn") else null
	lvl2 = $Panel/Level2Btn if has_node("Panel/Level2Btn") else null
	backmenu = $Panel/BackMenuBtn if has_node("Panel/BackMenuBtn") else null
	next = $Panel/NextBtn if has_node("Panel/NextBtn") else null
	lvl3 = $Panel/Level3Btn if has_node("Panel/Level3Btn") else null
	shade = get_node_or_null("Shade")
	sens = $Panel/SensSlider if has_node("Panel/SensSlider") else null
	sfx = $Panel/SfxSlider if has_node("Panel/SfxSlider") else null
	music = $Panel/MusicSlider if has_node("Panel/MusicSlider") else null
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameManager.state_changed.connect(_st)
	start.connect("pressed", GameManager, "start_game")
	restart.connect("pressed", GameManager, "start_game")
	quitbtn.connect("pressed", GameManager, "quit_game")
	if lvl2:
		lvl2.pressed.connect(_go_lvl2)
	if backmenu:
		backmenu.pressed.connect(_back_to_menu)
	if next:
		next.pressed.connect(_go_next)
	if lvl3:
		lvl3.pressed.connect(_go_lvl3)
	if sens:
		sens.value_changed.connect(_sens_changed)
	if sfx:
		sfx.value_changed.connect(_sfx_changed)
	if music:
		music.value_changed.connect(_music_changed)
	for a in ["move_forward", "move_backward", "move_left", "move_right", "jump"]:
		var b = get_node_or_null("Panel/" + a + "Btn")
		if b:
			b.connect("pressed", self, "start_listen", [a])
			keybtns.append(a)
	_show()

func _st(st):
	if st == GameManager.State.MENU:
		_show()
	elif st == GameManager.State.PLAYING:
		visible = false
	elif st == GameManager.State.PAUSED:
		_pause()
	elif st == GameManager.State.WIN:
		_end("You Win!", "Score: " + str(GameManager.score), true)
	elif st == GameManager.State.LOSE:
		_end("Game Over", "Score: " + str(GameManager.score) + "/" + str(GameManager.target), false)

func _go_lvl2():
	GameManager.load_level(1)

func _go_lvl3():
	GameManager.load_level(2)

func _go_next():
	var n = GameManager.current_level + 1
	if n < LevelManager.LEVEL_COUNT and LevelManager.unlocked > n:
		GameManager.load_level(n)
	else:
		GameManager.load_level(-1)

func _back_to_menu():
	GameManager.load_level(-1)

func _pause():
	_shd(0, 0, 0, 0)
	state_anim = false
	title.rect_scale = Vector2(1, 1)
	title.modulate = Color(1, 1, 1, 1)
	visible = true
	title.text = "Paused"
	info.text = "ESC = Resume"
	start.visible = false
	restart.visible = false
	quit.visible = true
	if backmenu:
		backmenu.visible = true

func _process(dt):
	if visible and state_anim:
		time += dt
		var s = 0.9 + sin(time * 2.0) * 0.1
		title.rect_scale = Vector2(s, s)
		title.modulate = Color(1, 1, 0.6 + 0.4 * sin(time * 2.0), 1)

func _sens_changed(v):
	SettingsManager.set("sensitivity", v)

func _sfx_changed(v):
	SettingsManager.set_volume("sfx", v)
	AudioManager.play("coin")

func _music_changed(v):
	SettingsManager.set_volume("music", v)
	AudioManager.play_music("menu")

func start_listen(action):
	listening_action = action
	info.text = "Press a key for: " + action

func _unhandled_input(event):
	if listening_action != "" and event is InputEventKey:
		SettingsManager.set_key(listening_action, event.keycode)
		listening_action = ""
		_show()
		return
	if listening_action == "" and event.is_action_pressed("ui_cancel") and state_anim:
		GameManager.toggle_pause()

func _show():
	_shd(0, 0, 0, 0)
	state_anim = true
	time = 0.0
	visible = true
	if sens:
		sens.value = SettingsManager.get("sensitivity", 0.3)
	if sfx:
		sfx.value = SettingsManager.get_volume("sfx", 0.0)
	if music:
		music.value = SettingsManager.get_volume("music", -12.0)
	if backmenu:
		backmenu.visible = false
	title.text = "Coin Quest"
	var best1 = LevelManager.best_for(0)
	info.text = "Unlocked: " + str(LevelManager.unlocked) + "/" + str(LevelManager.LEVEL_COUNT) + "\nBest Lv1: " + str(best1) + " pts\nWASD = Move  Space = Jump"
	start.visible = true
	start.text = "Play Level 1"
	restart.visible = false
	quit.visible = false
	if lvl2:
		lvl2.visible = LevelManager.unlocked > 1
		lvl2.disabled = LevelManager.unlocked <= 1
	if lvl3:
		lvl3.visible = LevelManager.unlocked > 2
		lvl3.disabled = LevelManager.unlocked <= 2
	_refresh_keys()

func _refresh_keys():
	for a in keybtns:
		var b = get_node_or_null("Panel/" + a + "Btn")
		if b:
			var sc = SettingsManager.get_key(a)
			var nm = OS.get_keycode_string(sc)
			b.text = a.replace("move_", "").replace("_", " ").replace("backward", "back") + ": " + nm

func _shd(r, g, b, a):
	if shade:
		shade.color = Color(r, g, b, a)

func _end(txt, inf, can_next):
	visible = true
	if can_next:
		_shd(1, 0.9, 0.3, 0.16)
	else:
		_shd(0.8, 0.1, 0.1, 0.18)
	if backmenu:
		backmenu.visible = false
	title.text = txt
	var b = LevelManager.best_for(GameManager.current_level)
	var time_s = str(int(GameManager.duration - GameManager.time_left))
	var stat = "\nBest Lv" + str(GameManager.current_level + 1) + ": " + str(b) + " pts   Time: " + time_s + "s"
	info.text = inf + stat
	start.visible = false
	restart.visible = true
	quit.visible = true
	if next:
		next.visible = can_next and GameManager.current_level + 1 < LevelManager.LEVEL_COUNT and LevelManager.unlocked > GameManager.current_level + 1
	if lvl2:
		lvl2.visible = false
	if lvl3:
		lvl3.visible = false
