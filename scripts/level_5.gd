extends Node3D

# 关卡5：Boss关 — 单一Boss敌人、窄小场地、生存+收集
func _ready():
	GameManager.current_level = 4
	GameManager.target = 10
	GameManager.duration = 40.0
	var we = get_node_or_null("WorldEnv")
	if we and we.environment:
		var env = we.environment
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.6, 0.15, 0.15, 1)
		env.ambient_light_color = Color(0.3, 0.35, 0.45, 1)
		env.ambient_light_energy = 0.5
		env.fog_enabled = true
		env.fog_mode = Environment.FOG_MODE_DEPTH
		env.fog_density = 0.015
		env.fog_light_color = Color(0.55, 0.15, 0.2, 1)
		env.fog_depth_begin = 15.0
		env.fog_depth_end = 35.0

	# 确保 UI 存在
	if not has_node("UI"):
		_create_ui()
	# Start countdown AFTER UI is fully created
	await get_tree().process_frame
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
	panel.anchor_left = 0.20
	panel.anchor_top = 0.20
	panel.anchor_right = 0.80
	panel.anchor_bottom = 0.80
	menu.add_child(panel)
	
	var title = Label.new()
	title.name = "Title"
	title.anchor_left = 0.1
	title.anchor_top = 0.05
	title.anchor_right = 0.9
	title.anchor_bottom = 0.05
	title.text = "Coin Quest"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)
	
	var info = Label.new()
	info.name = "Info"
	info.anchor_left = 0.1
	info.anchor_top = 0.20
	info.anchor_right = 0.9
	info.anchor_bottom = 0.20
	info.text = "WASD = Move  Space = Jump"
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(info)
	
	var buttons_data = {
		"StartBtn": {"text": "Start Game", "pos": 0.42, "vis": true},
		"NextBtn": {"text": "Next Level", "pos": 0.42, "vis": false},
		"RestartBtn": {"text": "Restart", "pos": 0.50, "vis": false},
		"Level2Btn": {"text": "Level 2 (Floating)", "pos": 0.50, "vis": false},
		"Level3Btn": {"text": "Level 3 (Fortress)", "pos": 0.58, "vis": false},
		"BackMenuBtn": {"text": "Back to Menu", "pos": 0.66, "vis": false},
		"QuitBtn": {"text": "Quit", "pos": 0.74, "vis": false},
	}
	for btn_name in buttons_data:
		var d = buttons_data[btn_name]
		var btn = Button.new()
		btn.name = btn_name
		btn.anchor_left = 0.25
		btn.anchor_top = d["pos"]
		btn.anchor_right = 0.75
		btn.anchor_bottom = d["pos"]
		btn.text = d["text"]
		btn.visible = d["vis"]
		panel.add_child(btn)
	
	# Hidden settings
	for n in ["SensLabel", "SensSlider", "SfxSlider", "MusicSlider", "VolLabel"]:
		var ctrl = Control.new() if "Label" in n else HSlider.new() if "Slider" in n else Button.new()
		ctrl.name = n
		ctrl.visible = false
		panel.add_child(ctrl)
	
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
