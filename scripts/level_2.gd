extends Node3D

# Level 2 — procedurally generated
func _ready():
	GameManager.current_level = 1
	GameManager.target = 14
	GameManager.duration = 50.0
	var we = get_node_or_null("WorldEnv")
	if we and we.environment:
		var env = we.environment
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.15, 0.35, 0.6, 1)
		env.ambient_light_color = Color(0.3, 0.35, 0.45, 1)
		env.ambient_light_energy = 0.5
		env.fog_enabled = true
		env.fog_mode = Environment.FOG_MODE_DEPTH
		env.fog_density = 0.015
		env.fog_light_color = Color(0.25, 0.35, 0.55, 1)
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
			e.patrol_speed = 2.5
			e.chase_speed = 4.5
			e.detect_range = 4.5
	_spawn_powerup(Vector3(-5, 1, -4), 1)
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
	score_label.text = I18n.t("coins_prefix") + "0/" + str(GameManager.target)
	hud.add_child(score_label)
	
	var timer_label = Label.new()
	timer_label.name = "Timer"
	timer_label.anchor_left = 0.98
	timer_label.anchor_top = 0.02
	timer_label.text = I18n.t("time_prefix") + str(int(GameManager.duration)) + "s"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hud.add_child(timer_label)
	
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.visible = true
	level_label.anchor_left = 0.02
	level_label.anchor_top = 0.07
	level_label.text = I18n.t("level_prefix") + str(GameManager.current_level + 1) + "   " + I18n.t("hits_left_prefix") + "3"
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
	title.text = I18n.t("coin_quest")
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
	info.text = I18n.t("wasd_hint")
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
	sfl.anchor_top = 0.82
	sfl.anchor_right = 0.50
	sfl.text = I18n.t("sfx_volume")
	sfl.visible = false
	panel.add_child(sfl)
	var sfxs = HSlider.new()
	sfxs.name = "SfxSlider"
	sfxs.anchor_left = 0.55
	sfxs.anchor_top = 0.82
	sfxs.anchor_right = 0.95
	sfxs.min_value = -30.0
	sfxs.max_value = 0.0
	sfxs.visible = false
	panel.add_child(sfxs)
	# Music
	var ml = Label.new()
	ml.name = "MusicLabel"
	ml.anchor_left = 0.05
	ml.anchor_top = 0.86
	ml.anchor_right = 0.50
	ml.text = I18n.t("music_volume")
	ml.visible = false
	panel.add_child(ml)
	var mus = HSlider.new()
	mus.name = "MusicSlider"
	mus.anchor_left = 0.55
	mus.anchor_top = 0.86
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
	sl.anchor_top = 0.78
	sl.anchor_right = 0.50
	sl.text = I18n.t("sensitivity")
	sl.visible = false
	panel.add_child(sl)
	var ss = HSlider.new()
	ss.name = "SensSlider"
	ss.anchor_left = 0.55
	ss.anchor_top = 0.78
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
	lb.anchor_top = 0.71
	lb.anchor_right = 0.80
	lb.text = I18n.t("lang_zh") if I18n.lang == "en" else I18n.t("lang_en")
	lb.visible = false
	panel.add_child(lb)
	
	for a in ["move_forward", "jump", "move_left", "move_backward", "move_right"]:
		var kb = Button.new()
		kb.name = a + "Btn"
		kb.visible = false
		match a:
			"move_forward":  kb.anchor_left = 0.20; kb.anchor_right = 0.42; kb.anchor_top = 0.60; kb.anchor_bottom = 0.65
			"jump":          kb.anchor_left = 0.43; kb.anchor_right = 0.80; kb.anchor_top = 0.60; kb.anchor_bottom = 0.65
			"move_left":     kb.anchor_left = 0.05; kb.anchor_right = 0.27; kb.anchor_top = 0.66; kb.anchor_bottom = 0.71
			"move_backward": kb.anchor_left = 0.20; kb.anchor_right = 0.42; kb.anchor_top = 0.66; kb.anchor_bottom = 0.71
			"move_right":    kb.anchor_left = 0.35; kb.anchor_right = 0.57; kb.anchor_top = 0.66; kb.anchor_bottom = 0.71
		panel.add_child(kb)
	
	ui.add_child(menu)
	
	# Touch controls
	var joystick = Control.new()
	joystick.name = "TouchJoystick"
	joystick.set_script(load("res://scripts/touch_joystick.gd"))
	ui.add_child(joystick)
	var jbtn = Control.new()
	jbtn.name = "JumpButton"
	jbtn.set_script(load("res://scripts/touch_button.gd"))
	ui.add_child(jbtn)
	
	add_child(ui)
	# Re-bind menu signals now that all buttons exist
	if menu.has_method("setup_nodes"):
		menu.setup_nodes()
	if menu.has_method("_style_buttons"):
		menu._style_buttons()

func _spawn_powerup(pos, ptype):
	var p = Area3D.new()
	p.name = "Powerup"
	p.position = pos
	var scr = load("res://scripts/powerup.gd")
	p.set_script(scr)
	p.power_type = ptype
	var mesh = MeshInstance3D.new()
	mesh.name = "Mesh"
	var sm = SphereMesh.new()
	sm.radius = 0.4
	sm.height = 0.8
	mesh.mesh = sm
	var mat = StandardMaterial3D.new()
	match ptype:
		0: mat.albedo_color = Color(0.2, 0.8, 0.2, 1)
		1: mat.albedo_color = Color(0.8, 0.8, 0.1, 1)
		2: mat.albedo_color = Color(0.8, 0.3, 0.8, 1)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.emission_enabled = true
	mat.emission = mat.albedo_color
	mat.emission_energy_multiplier = 1.3
	mesh.material_override = mat
	p.add_child(mesh)
	var col = CollisionShape3D.new()
	col.name = "Col"
	var shape = SphereShape3D.new()
	shape.radius = 0.5
	col.shape = shape
	p.add_child(col)
	add_child(p)
