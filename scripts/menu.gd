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
@onready var mute_btn = $Panel/MuteBtn
@onready var lang_btn = $Panel/LangBtn

func _ready():
	GameManager.state_changed.connect(_st)
	var ls_btn = get_node_or_null("Panel/LevelSelectBtn")
	if ls_btn:
		ls_btn.pressed.connect(_show_level_select)
	if mute_btn:
		mute_btn.pressed.connect(_toggle_mute)
	if lang_btn:
		lang_btn.pressed.connect(_toggle_lang)
	_connect_signals()
	for a in ["move_forward", "move_backward", "move_left", "move_right", "jump"]:
		var b = get_node_or_null("Panel/" + a + "Btn")
		if b:
			b.pressed.connect(start_listen.bind(a))
			keybtns.append(a)
	_style_buttons()
	_show()

func _connect_signals():
	if start and not start.pressed.is_connected(GameManager.start_game):
		start.pressed.connect(GameManager.start_game)
	if restart and not restart.pressed.is_connected(GameManager.start_game):
		restart.pressed.connect(GameManager.start_game)
	if quit_btn and not quit_btn.pressed.is_connected(GameManager.quit_game):
		quit_btn.pressed.connect(GameManager.quit_game)
	if lvl2 and not lvl2.pressed.is_connected(_go_lvl2):
		lvl2.pressed.connect(_go_lvl2)
	if backmenu and not backmenu.pressed.is_connected(_back_to_menu):
		backmenu.pressed.connect(_back_to_menu)
	if next and not next.pressed.is_connected(_go_next):
		next.pressed.connect(_go_next)
	if lvl3 and not lvl3.pressed.is_connected(_go_lvl3):
		lvl3.pressed.connect(_go_lvl3)
	if sens and not sens.value_changed.is_connected(_sens_changed):
		sens.value_changed.connect(_sens_changed)
	if sfx and not sfx.value_changed.is_connected(_sfx_changed):
		sfx.value_changed.connect(_sfx_changed)
	if music and not music.value_changed.is_connected(_music_changed):
		music.value_changed.connect(_music_changed)

func _style_buttons():
	var buttons = [start, restart, quit_btn, lvl2, lvl3, next, backmenu]
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.15, 0.15, 0.2, 1)
	normal_style.border_width_left = 1
	normal_style.border_width_right = 1
	normal_style.border_width_top = 1
	normal_style.border_width_bottom = 1
	normal_style.border_color = Color(0.3, 0.3, 0.4, 1)
	normal_style.set_corner_radius_all(6)
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.25, 0.25, 0.35, 1)
	hover_style.border_width_left = 1
	hover_style.border_width_right = 1
	hover_style.border_width_top = 1
	hover_style.border_width_bottom = 1
	hover_style.border_color = Color(0.5, 0.5, 0.6, 1)
	hover_style.set_corner_radius_all(6)
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.1, 0.1, 0.15, 1)
	pressed_style.border_width_left = 1
	pressed_style.border_width_right = 1
	pressed_style.border_width_top = 1
	pressed_style.border_width_bottom = 1
	pressed_style.border_color = Color(0.4, 0.4, 0.5, 1)
	pressed_style.set_corner_radius_all(6)
	for btn in buttons:
		if btn:
			btn.add_theme_stylebox_override("normal", normal_style)
			btn.add_theme_stylebox_override("hover", hover_style)
			btn.add_theme_stylebox_override("pressed", pressed_style)
			btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95, 1))
			btn.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
			btn.add_theme_color_override("font_pressed_color", Color(0.7, 0.7, 0.75, 1))
			btn.add_theme_font_size_override("font_size", 16)

func setup_nodes():
	title = get_node_or_null("Panel/Title")
	info = get_node_or_null("Panel/Info")
	start = get_node_or_null("Panel/StartBtn")
	restart = get_node_or_null("Panel/RestartBtn")
	quit_btn = get_node_or_null("Panel/QuitBtn")
	lvl2 = get_node_or_null("Panel/Level2Btn")
	backmenu = get_node_or_null("Panel/BackMenuBtn")
	next = get_node_or_null("Panel/NextBtn")
	lvl3 = get_node_or_null("Panel/Level3Btn")
	sens = get_node_or_null("Panel/SensSlider")
	sfx = get_node_or_null("Panel/SfxSlider")
	music = get_node_or_null("Panel/MusicSlider")
	_connect_signals()

func _st(st):
	if st == GameManager.State.MENU:
		_style_buttons()
		_show()
	elif st == GameManager.State.PLAYING or st == GameManager.State.COUNTDOWN:
		visible = false
	elif st == GameManager.State.PAUSED:
		_pause()
	elif st == GameManager.State.WIN:
		_end(I18n.t("win"), "Score: " + str(GameManager.score), true)
	elif st == GameManager.State.LOSE:
		_end(I18n.t("lose"), "Score: " + str(GameManager.score) + "/" + str(GameManager.target), false)

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


func _show_tutorial():
	var tut = Control.new()
	tut.name = "TutorialOverlay"
	tut.anchor_right = 1.0
	tut.anchor_bottom = 1.0
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	tut.add_child(bg)
	
	var label = Label.new()
	label.text = I18n.t("tutorial_text")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
	label.add_theme_font_size_override("font_size", 24)
	tut.add_child(label)
	
	var ok_btn = Button.new()
	ok_btn.text = I18n.t("tutorial_got_it")
	ok_btn.anchor_left = 0.4
	ok_btn.anchor_right = 0.6
	ok_btn.anchor_top = 0.7
	ok_btn.anchor_bottom = 0.7
	ok_btn.pressed.connect(func():
		SettingsManager.set_setting("tutorial_done", true)
		tut.queue_free()
	)
	tut.add_child(ok_btn)
	
	add_child(tut)



func _toggle_lang():
	if I18n.lang == "en":
		I18n.set_lang("zh")
	else:
		I18n.set_lang("en")

func _toggle_mute():
	var muted = AudioManager.is_muted if AudioManager.has_method("is_muted") else false
	if muted:
		AudioManager.unmute()
		if mute_btn: mute_btn.text = I18n.t("mute")
	else:
		AudioManager.mute()
		if mute_btn: mute_btn.text = I18n.t("unmute")


func _calc_stars() -> String:
	var score = GameManager.score
	var target = GameManager.target
	var ratio = float(score) / float(target)
	var stars = 1
	if ratio >= 2.0:
		stars = 3
	elif ratio >= 1.3:
		stars = 2
	var s = ""
	for i in range(3):
		if i < stars:
			s += "*"
		else:
			s += "."
	return s

func _show_level_select():
	var ls = get_node_or_null("../LevelSelect")
	if ls and ls.has_method("_show"):
		ls._show()

func _back_to_menu():
	GameManager.load_level(-1)

func _pause():
	visible = true
	modulate.a = 0.0
	var panel = get_node_or_null("Panel")
	if panel:
		panel.modulate.a = 0.0
	title.text = I18n.t("paused")
	info.text = I18n.t("pause_controls")
	start.visible = false
	restart.visible = false
	quit_btn.visible = true
	if backmenu:
		backmenu.visible = true
	if next:
		next.visible = false
	if lvl2:
		lvl2.visible = false
	if lvl3:
		lvl3.visible = false
	if sens: sens.visible = false
	if sfx: sfx.visible = false
	if music: music.visible = false
	var t = create_tween().set_parallel(true)
	t.tween_property(self, "modulate:a", 1.0, 0.2)
	if panel:
		t.tween_property(panel, "modulate:a", 1.0, 0.25)

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
	info.text = I18n.t("press_a_key") + action

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
	modulate.a = 0.0
	var panel = get_node_or_null("Panel")
	if panel:
		panel.modulate.a = 0.0
		panel.pivot_offset = panel.size / 2.0
		panel.scale = Vector2(0.85, 0.85)
	# Show settings sliders
	if sens:
		sens.visible = true
		var sl = get_node_or_null("Panel/SensLabel")
		if sl: sl.visible = true
	if sfx:
		sfx.visible = true
		var sfl = get_node_or_null("Panel/SfxLabel")
		if sfl: sfl.visible = true
	if music:
		music.visible = true
		var ml = get_node_or_null("Panel/MusicLabel")
		if ml: ml.visible = true
	if backmenu:
		backmenu.visible = false
	if next:
		next.visible = false
	title.text = I18n.t("coin_quest")
	var best1 = LevelManager.best_for(0)
	info.text = I18n.t("wasd_hint")
	start.visible = true
	start.text = I18n.t("play_level_1")
	restart.visible = false
	quit_btn.visible = false
	if lvl2:
		lvl2.visible = LevelManager.unlocked > 1
		lvl2.disabled = LevelManager.unlocked <= 1
		lvl2.text = I18n.t_arr("level_names")[1]
	if lvl3:
		lvl3.visible = LevelManager.unlocked > 2
		lvl3.disabled = LevelManager.unlocked <= 2
		lvl3.text = I18n.t_arr("level_names")[2]
	# Show Level Select button (replaces individual level buttons functionality)
	var ls_btn = get_node_or_null("Panel/LevelSelectBtn")
	if ls_btn:
		ls_btn.visible = true
		ls_btn.text = I18n.t("level_select")
	if mute_btn:
		mute_btn.visible = true
		mute_btn.text = I18n.t("mute")
	if lang_btn:
		lang_btn.visible = true
		lang_btn.text = I18n.t("lang_zh") if I18n.lang == "en" else I18n.t("lang_en")
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.25)
	if panel:
		tw.tween_property(panel, "modulate:a", 1.0, 0.3)
		tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# First-time tutorial
	if not SettingsManager.has("tutorial_done"):
		call_deferred("_show_tutorial")

func _end(txt, inf, can_next):
	visible = true
	modulate.a = 0.0
	var panel = get_node_or_null("Panel")
	if panel:
		panel.modulate.a = 0.0
	title.text = txt
	# Append star rating
	var stars = _calc_stars()
	info.text = I18n.t("score_text") + str(GameManager.score) + "\n" + stars
	start.visible = false
	restart.visible = true
	quit_btn.visible = true
	if next:
		next.visible = can_next
	if lvl2:
		lvl2.visible = false
	if lvl3:
		lvl3.visible = false
	var ls_btn = get_node_or_null("Panel/LevelSelectBtn")
	if ls_btn:
		ls_btn.visible = false
	if mute_btn:
		mute_btn.visible = true
		mute_btn.text = I18n.t("mute")
	if lang_btn:
		lang_btn.visible = true
		lang_btn.text = I18n.t("lang_zh") if I18n.lang == "en" else I18n.t("lang_en")
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.2)
	if panel:
		tw.tween_property(panel, "modulate:a", 1.0, 0.25)
