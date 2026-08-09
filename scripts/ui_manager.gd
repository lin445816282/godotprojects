extends CanvasLayer

# UIManager autoload — 跨场景管理 HUD 和 Menu
# 场景切换时自动重新挂载 UI 到当前场景

var hud_instance = null
var menu_instance = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_rebuild_ui()

func _rebuild_ui():
	# 清理旧 UI
	for child in get_children():
		child.queue_free()
	
	# 创建 HUD
	hud_instance = Control.new()
	hud_instance.name = "HUD"
	hud_instance.set_script(load("res://scripts/hud.gd"))
	hud_instance.anchor_right = 1.0
	hud_instance.anchor_bottom = 1.0
	
	# 创建 HUD 子节点
	var score_label = Label.new()
	score_label.name = "Score"
	score_label.anchor_left = 0.02
	score_label.anchor_top = 0.02
	score_label.text = "Coins: 0/5"
	hud_instance.add_child(score_label)
	
	var timer_label = Label.new()
	timer_label.name = "Timer"
	timer_label.anchor_top = 0.02
	timer_label.anchor_right = 0.98
	timer_label.anchor_left = 0.98
	timer_label.text = "Time: 60s"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hud_instance.add_child(timer_label)
	
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.visible = false
	level_label.anchor_left = 0.02
	level_label.anchor_top = 0.07
	level_label.text = "Level 1   Hits left: 3"
	hud_instance.add_child(level_label)
	
	var countdown_label = Label.new()
	countdown_label.name = "Countdown"
	countdown_label.visible = false
	countdown_label.anchor_left = 0.5
	countdown_label.anchor_top = 0.4
	countdown_label.anchor_right = 0.5
	countdown_label.anchor_bottom = 0.4
	countdown_label.add_theme_color_override("font_color", Color(1, 0.9, 0.1, 1))
	countdown_label.text = "3"
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud_instance.add_child(countdown_label)
	
	add_child(hud_instance)
	
	# 创建 Menu
	menu_instance = Control.new()
	menu_instance.name = "Menu"
	menu_instance.set_script(load("res://scripts/menu.gd"))
	menu_instance.anchor_right = 1.0
	menu_instance.anchor_bottom = 1.0
	
	# 创建 Shade
	var shade = ColorRect.new()
	shade.name = "Shade"
	shade.anchor_right = 1.0
	shade.anchor_bottom = 1.0
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.color = Color(1, 1, 1, 0)
	menu_instance.add_child(shade)
	
	# 创建 Panel
	var panel = Panel.new()
	panel.name = "Panel"
	panel.anchor_left = 0.20
	panel.anchor_top = 0.20
	panel.anchor_right = 0.80
	panel.anchor_bottom = 0.80
	menu_instance.add_child(panel)
	
	# 创建菜单子元素
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
	info.text = "WASD = Move  Space = Jump\\nRight-Click = Look"
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(info)
	
	# 创建所有按钮
	var buttons = {
		"StartBtn":   {"text": "Start Game",           "pos": 0.32, "visible": true},
		"RestartBtn": {"text": "Restart",               "pos": 0.42, "visible": false},
		"QuitBtn":    {"text": "Quit",                  "pos": 0.82, "visible": false},
		"Level2Btn":  {"text": "Level 2 (Floating)",    "pos": 0.52, "visible": false},
		"Level3Btn":  {"text": "Level 3 (Fortress)",    "pos": 0.62, "visible": false},
		"NextBtn":    {"text": "Next Level",            "pos": 0.32, "visible": false},
		"BackMenuBtn":{"text": "Back to Menu",          "pos": 0.72, "visible": false},
	}
	
	for btn_name in buttons:
		var cfg = buttons[btn_name]
		var btn = Button.new()
		btn.name = btn_name
		btn.anchor_left = 0.25
		btn.anchor_top = cfg["pos"]
		btn.anchor_right = 0.75
		btn.anchor_bottom = cfg["pos"]
		btn.text = cfg["text"]
		btn.visible = cfg["visible"]
		panel.add_child(btn)
	
	var sens_label = Label.new()
	sens_label.name = "SensLabel"
	sens_label.anchor_left = 0.05
	sens_label.anchor_top = 0.95
	sens_label.text = ""
	sens_label.visible = false
	panel.add_child(sens_label)
	
	var sens_slider = HSlider.new()
	sens_slider.name = "SensSlider"
	sens_slider.anchor_left = 0.05
	sens_slider.anchor_top = 0.95
	sens_slider.anchor_right = 0.95
	sens_slider.min_value = 0.05
	sens_slider.max_value = 1.0
	sens_slider.step = 0.05
	sens_slider.value = 0.3
	sens_slider.visible = false
	panel.add_child(sens_slider)
	
	var sfx_slider = HSlider.new()
	sfx_slider.name = "SfxSlider"
	sfx_slider.anchor_left = 0.55
	sfx_slider.anchor_top = 0.95
	sfx_slider.anchor_right = 0.95
	sfx_slider.min_value = -30.0
	sfx_slider.max_value = 0.0
	sfx_slider.visible = false
	panel.add_child(sfx_slider)
	
	var music_slider = HSlider.new()
	music_slider.name = "MusicSlider"
	music_slider.anchor_left = 0.55
	music_slider.anchor_top = 0.95
	music_slider.anchor_right = 0.95
	music_slider.min_value = -40.0
	music_slider.max_value = 0.0
	music_slider.value = -12.0
	music_slider.visible = false
	panel.add_child(music_slider)
	
	var vol_label = Label.new()
	vol_label.name = "VolLabel"
	vol_label.anchor_left = 0.55
	vol_label.anchor_top = 0.95
	vol_label.text = ""
	vol_label.visible = false
	panel.add_child(vol_label)
	
	# 创建键位按钮 (隐藏)
	for action in ["move_forward", "move_backward", "move_left", "move_right", "jump"]:
		var kb = Button.new()
		kb.name = action + "Btn"
		kb.visible = false
		panel.add_child(kb)
	
	add_child(menu_instance)

