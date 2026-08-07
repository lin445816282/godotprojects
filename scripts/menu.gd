extends Control

onready var title = $Panel/Title
onready var info = $Panel/Info
onready var start = $Panel/StartBtn
onready var restart = $Panel/RestartBtn
onready var quit = $Panel/QuitBtn

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameManager.connect("state_changed", self, "_st")
	start.connect("pressed", GameManager, "start_game")
	restart.connect("pressed", GameManager, "start_game")
	quit.connect("pressed", GameManager, "quit_game")
	_show()

func _st(st):
	if st == GameManager.State.MENU:
		_show()
	elif st == GameManager.State.PLAYING:
		visible = false
	elif st == GameManager.State.PAUSED:
		_pause()
	elif st == GameManager.State.WIN:
		_end("You Win!", "Score: " + str(GameManager.score))
	elif st == GameManager.State.LOSE:
		_end("Game Over", "Score: " + str(GameManager.score) + "/" + str(GameManager.target))

func _pause():
	visible = true
	title.text = "Paused"
	info.text = "ESC = Resume"
	start.visible = false
	restart.visible = false
	quit.visible = true

func _show():
	visible = true
	title.text = "Coin Quest"
	var best1 = LevelManager.best_for(0)
	info.text = "Unlocked: " + str(LevelManager.unlocked) + "/" + str(LevelManager.LEVEL_COUNT) + "\nBest Lv1: " + str(best1) + " pts\nWASD = Move  Space = Jump"
	start.visible = true
	start.text = "Play Level 1"
	restart.visible = false
	quit.visible = false

func _end(txt, inf):
	visible = true
	title.text = txt
	var b = LevelManager.best_for(GameManager.current_level)
	info.text = inf + "\nBest Lv" + str(GameManager.current_level + 1) + ": " + str(b) + " pts"
	start.visible = false
	restart.visible = true
	quit.visible = true