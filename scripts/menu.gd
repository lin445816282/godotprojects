extends Control

var time = 0.0
var state_anim = false
var keybtns = []
var listening_action = ""

@onready var title = $Panel/Title
@onready var info = $Panel/Info
@onready var start = $Panel/StartBtn
@onready var restart = $Panel/RestartBtn
@onready var quit_btn = $Panel/QuitBtn
@onready var lvl2 = $Panel/Level2Btn
@onready var backmenu = $Panel/BackMenuBtn
@onready var next = $Panel/NextBtn
@onready var lvl3 = $Panel/Level3Btn
@onready var shade = $Shade
@onready var sens = $Panel/SensSlider
@onready var sfx = $Panel/SfxSlider
@onready var music = $Panel/MusicSlider

func _ready():
	GameManager.state_changed.connect(_st)
	start.pressed.connect(GameManager.start_game)
	restart.pressed.connect(GameManager.start_game)
	quit_btn.pressed.connect(GameManager.quit_game)
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
			b.pressed.connect(start_listen.bind(a))
			keybtns.append(a)
	_show()

func _st(st):
	if st == GameManager.State.MENU:
		_show()
	elif st == GameManager.State.PLAYING or st == GameManager.State.COUNTDOWN:
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
	visible = true
	title.text = "Paused"
	info.text = "ESC = Resume"
	start.visible = false
	restart.visible = false
	quit_btn.visible = true
	if backmenu:
		backmenu.visible = true

func _process(dt):
	if visible and state_anim:
		time += dt
		var s = 0.9 + sin(time * 2.0) * 0.1
		title.scale = Vector2(s, s)

func _sens_changed(v):
	SettingsManager.set_setting("sensitivity", v)

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
	if listening_action == "" and event.is_action_pressed("ui_cancel") and visible:
		GameManager.toggle_pause()

func _show():
	state_anim = true
	time = 0.0
	visible = true
	if sens:
		sens.value = SettingsManager.get_setting("sensitivity", 0.3)
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
	quit_btn.visible = false
	if lvl2:
		lvl2.visible = LevelManager.unlocked > 1
		lvl2.disabled = LevelManager.unlocked <= 1
	if lvl3:
		lvl3.visible = LevelManager.unlocked > 2
		lvl3.disabled = LevelManager.unlocked <= 2

func _end(txt, inf, can_next):
	visible = true
	title.text = txt
	info.text = inf
	start.visible = false
	restart.visible = true
	quit_btn.visible = true
	if next:
		next.visible = can_next
	if lvl2:
		lvl2.visible = false
	if lvl3:
		lvl3.visible = false
