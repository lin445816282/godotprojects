extends Node3D

# Level 3 — procedurally generated
func _ready():
	GameManager.current_level = 2
	GameManager.target = 18
	GameManager.duration = 45.0
	var we = get_node_or_null("WorldEnv")
	if we and we.environment:
		var env = we.environment
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.25, 0.35, 0.55, 1)
		env.ambient_light_color = Color(0.3, 0.35, 0.45, 1)
		env.ambient_light_energy = 0.5
		env.fog_enabled = true
		env.fog_mode = Environment.FOG_MODE_DEPTH
		env.fog_density = 0.015
		env.fog_light_color = Color(0.35, 0.4, 0.55, 1)
		env.fog_depth_begin = 15.0
		env.fog_depth_end = 35.0

	# 确保 UI 存在
	if not has_node("UI"):
		_create_ui()
	# Start countdown AFTER UI is fully created
	await get_tree().process_frame
	# Difficulty: scale enemies for this level
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.has_method("set_difficulty"):
			e.patrol_speed = 3.0
			e.chase_speed = 5.5
			e.detect_range = 5.5
	GameManager.start_level_countdown()

func _create_ui():
	var ui = Control.new()
	ui.name = "UI"
	ui.anchor_right = 1.0
	ui.anchor_bottom = 1.0
	
	# HUD
	var hud = Control.new()
	hud.name = "HUD"
	hud.set_script(load("res://scripts/hud.gd"))
	hud.anchor_right = 1.0
	hud.anchor_bottom = 1.0
	ui.add_child(hud)
	
	var score_label = Label.new()
	score_label.name = "Score"
	score_label.anchor_left = 0.02
	score_label.anchor_top = 0.02
	score_label.text = "Coins: 0/5"
	hud.add_child(score_label)
	
	var timer_label = Label.new()
	timer_label.name = "Timer"
	timer_label.anchor_left = 0.98
	timer_label.anchor_top = 0.02
	timer_label.text = "Time: 60s"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hud.add_child(timer_label)
	
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.visible = true
	level_label.anchor_left = 0.02
	level_label.anchor_top = 0.07
	level_label.text = "Level 1   Hits left: 3"
	hud.add_child(level_label)
	
	var count_label = Label.new()
	count_label.name = "Countdown"
	count_label.visible = false
	count_label.anchor_left = 0.5
	count_label.anchor_top = 0.4
	count_label.anchor_right = 0.5
	count_label.anchor_bottom = 0.4
	count_label.add_theme_color_override("font_color", Color(1, 0.9, 0.1, 1))
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud.add_child(count_label)
	
	# Menu
	var menu = Control.new()
	menu.name = "Menu"
	menu.set_script(load("res://scripts/menu.gd"))
	menu.anchor_right = 1.0
	menu.anchor_bottom = 1.0
	
	var shade = ColorRect.new()
	shade.name = "Shade"
	shade.anchor_right = 1.0
	shade.anchor_bottom = 1.0
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.color = Color(1, 1, 1, 0)
	menu.add_child(shade)
	
	var panel = Panel.new()
	panel.name = "Panel"
	panel.anchor_left = 0.30
	panel.anchor_top = 0.15
	panel.anchor_right = 0.70
	panel.anchor_bottom = 0.85
	panel.self_modulate = Color(0.05, 0.05, 0.08, 0.88)
	menu.add_child(panel)
	
	var title = Label.new()
	title.name = "Title"
	title.anchor_left = 0.10
	title.anchor_top = 0.05
	title.anchor_right = 0.90
	title.anchor_bottom = 0.10
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.1, 1))
	title.add_theme_font_size_override("font_size", 28)
	title.text = "Coin Quest"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)
	
	var info = Label.new()
	info.name = "Info"
	info.anchor_left = 0.10
	info.anchor_top = 0.15
	info.anchor_right = 0.90
	info.anchor_bottom = 0.30
	info.add_theme_color_override("font_color", Color(0.65, 0.65, 0.7, 1))
	info.add_theme_font_size_override("font_size", 14)
	info.text = "WASD = Move  Space = Jump"
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(info)
	
	var buttons_data = {
		"StartBtn": {"text": I18n.t("play_level_1"), "pos": 0.38, "vis": true},
		"NextBtn": {"text": I18n.t("next_level"), "pos": 0.38, "vis": false},
		"RestartBtn": {"text": I18n.t("restart"), "pos": 0.47, "vis": false},
		"Level2Btn": {"text": I18n.t_arr("level_names")[1], "pos": 0.47, "vis": false},
		"Level3Btn": {"text": I18n.t_arr("level_names")[2], "pos": 0.56, "vis": false},
		"BackMenuBtn": {"text": I18n.t("back_to_menu"), "pos": 0.56, "vis": false},
		"QuitBtn": {"text": I18n.t("quit"), "pos": 0.67, "vis": false},
	}
	for btn_name in buttons_data:
		var d = buttons_data[btn_name]
		var btn = Button.new()
		btn.name = btn_name
		btn.anchor_left = 0.20
		btn.anchor_top = d["pos"]
		btn.anchor_right = 0.80
		btn.anchor_bottom = d["pos"]
		btn.text = d["text"]
		btn.visible = d["vis"]
		panel.add_child(btn)
	
	# Settings sliders with labels
	# SFX
	var sfl = Label.new()
	sfl.name = "SfxLabel"
	sfl.anchor_left = 0.05
	sfl.anchor_top = 0.93
	sfl.anchor_right = 0.50
	sfl.text = I18n.t("sfx_volume")
	sfl.visible = false
	panel.add_child(sfl)
	var sfxs = HSlider.new()
	sfxs.name = "SfxSlider"
	sfxs.anchor_left = 0.55
	sfxs.anchor_top = 0.93
	sfxs.anchor_right = 0.95
	sfxs.min_value = -30.0
	sfxs.max_value = 0.0
	sfxs.visible = false
	panel.add_child(sfxs)
	# Music
	var ml = Label.new()
	ml.name = "MusicLabel"
	ml.anchor_left = 0.05
	ml.anchor_top = 0.96
	ml.anchor_right = 0.50
	ml.text = I18n.t("music_volume")
	ml.visible = false
	panel.add_child(ml)
	var mus = HSlider.new()
	mus.name = "MusicSlider"
	mus.anchor_left = 0.55
	mus.anchor_top = 0.96
	mus.anchor_right = 0.95
	mus.min_value = -40.0
	mus.max_value = 0.0
	mus.value = -12.0
	mus.visible = false
	panel.add_child(mus)
	# Sensitivity
	var sl = Label.new()
	sl.name = "SensLabel"
	sl.anchor_left = 0.05
	sl.anchor_top = 0.90
	sl.anchor_right = 0.50
	sl.text = I18n.t("sensitivity")
	sl.visible = false
	panel.add_child(sl)
	var ss = HSlider.new()
	ss.name = "SensSlider"
	ss.anchor_left = 0.55
	ss.anchor_top = 0.90
	ss.anchor_right = 0.95
	ss.min_value = 0.05
	ss.max_value = 1.0
	ss.step = 0.05
	ss.value = 0.3
	ss.visible = false
	panel.add_child(ss)
	
		# Language toggle button
	var lb = Button.new()
	lb.name = "LangBtn"
	lb.anchor_left = 0.20
	lb.anchor_top = 0.90
	lb.anchor_right = 0.80
	lb.text = "中文"
	lb.visible = false
	panel.add_child(lb)
	
	for a in ["move_forward", "move_backward", "move_left", "move_right", "jump"]:
		var kb = Button.new()
		kb.name = a + "Btn"
		kb.visible = false
		panel.add_child(kb)
	
	ui.add_child(menu)
	add_child(ui)
	# Re-bind menu signals now that all buttons exist
	if menu.has_method("setup_nodes"):
		menu.setup_nodes()
	if menu.has_method("_style_buttons"):
		menu._style_buttons()
