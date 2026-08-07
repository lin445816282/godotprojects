extends Control

var time = 0.0
var state_anim = false

onready var title = $Panel/Title
onready var info = $Panel/Info
onready var start = $Panel/StartBtn
onready var restart = $Panel/RestartBtn
onready var quit = $Panel/QuitBtn
onready var lvl2 = $Panel/Level2Btn
onready var backmenu = $Panel/BackMenuBtn
onready var next = $Panel/NextBtn
onready var lvl3 = $Panel/Level3Btn
onready var shade = $"..//Shade"
onready var sens = $Panel/SensSlider
var keybtns = []
var listening_action = ""

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameManager.connect("state_changed", self, "_st")
	start.connect("pressed", GameManager, "start_game")
	restart.connect("pressed", GameManager, "start_game")
	quit.connect("pressed", GameManager, "quit_game")
	if lvl2:
		lvl2.connect("pressed", self, "_go_lvl2")
	if backmenu:
		backmenu.connect("pressed", self, "_back_to_menu")
	if next:
		next.connect("pressed", self, "_go_next")
	if lvl3:
		lvl3.connect("pressed", self, "_go_lvl3")
	if sens:
		sens.connect("value_changed", self, "_sens_changed")
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

func start_listen(action):
	listening_action = action
	info.text = "Press a key for: " + action

func _unhandled_input(event):
	if listening_action != "" and event is InputEventKey:
		SettingsManager.set_key(listening_action, event.scancode)
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
			var nm = OS.get_scancode_string(sc)
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
	info.text = inf + "\nBest Lv" + str(GameManager.current_level + 1) + ": " + str(b) + " pts"
	start.visible = false
	restart.visible = true
	quit.visible = true
	if next:
		next.visible = can_next and GameManager.current_level + 1 < LevelManager.LEVEL_COUNT and LevelManager.unlocked > GameManager.current_level + 1
	if lvl2:
		lvl2.visible = false
	if lvl3:
		lvl3.visible = false
