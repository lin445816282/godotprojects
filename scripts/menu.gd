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

func _show():
	state_anim = true
	time = 0.0
	visible = true
	if backmenu:
		backmenu.visible = false
	title.text = "Coin Quest"
	var best1 = LevelManager.best_for(0)
	info.text = "Unlocked: " + str(LevelManager.unlocked) + "/" + str(LevelManager.LEVEL_COUNT) + "\nBest Lv1: " + str(best1) + " pts\nWASD = Move  Space = Jump"
	start.visible = true
	start.text = "Play Level 1"
	restart.visible = false
	quit.visible = false

func _end(txt, inf, can_next):
	visible = true
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