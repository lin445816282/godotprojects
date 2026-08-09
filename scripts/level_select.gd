extends Control

var cards = []

func _ready():
	GameManager.state_changed.connect(_on_state)
	visible = false
	_build_cards()

func _build_cards():
	# Remove old cards
	for c in cards:
		if is_instance_valid(c):
			c.queue_free()
	cards.clear()
	
	# Grid container for level cards
	var grid = HBoxContainer.new()
	grid.name = "CardGrid"
	grid.anchor_left = 0.15
	grid.anchor_right = 0.85
	grid.anchor_top = 0.25
	grid.anchor_bottom = 0.75
	grid.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(grid)
	
	var level_names = ["Grasslands", "Floating Isles", "Fortress", "Frozen Wastes", "Boss Arena"]
	
	for i in range(LevelManager.LEVEL_COUNT):
		var card = Panel.new()
		card.custom_minimum_size = Vector2(140, 180)
		
		# Locked/unlocked styling
		var is_unlocked = LevelManager.unlocked > i
		if is_unlocked:
			card.self_modulate = Color(0.1, 0.1, 0.15, 0.9)
		else:
			card.self_modulate = Color(0.05, 0.05, 0.05, 0.7)
		
		var vbox = VBoxContainer.new()
		vbox.anchor_right = 1.0
		vbox.anchor_bottom = 1.0
		card.add_child(vbox)
		
		# Level number
		var num_label = Label.new()
		num_label.text = str(i + 1)
		num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num_label.add_theme_font_size_override("font_size", 32)
		num_label.add_theme_color_override("font_color", Color(1, 0.85, 0.1, 1) if is_unlocked else Color(0.3, 0.3, 0.3, 1))
		vbox.add_child(num_label)
		
		# Level name
		var name_label = Label.new()
		name_label.text = level_names[i]
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75, 1) if is_unlocked else Color(0.3, 0.3, 0.3, 1))
		vbox.add_child(name_label)
		
		# Best score
		var score_label = Label.new()
		var best = LevelManager.best_for(i)
		score_label.text = "Best: " + str(best) if is_unlocked else "Locked"
		score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		score_label.add_theme_font_size_override("font_size", 11)
		score_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55, 1) if is_unlocked else Color(0.2, 0.2, 0.2, 1))
		vbox.add_child(score_label)
		
		# Play button
		if is_unlocked:
			var btn = Button.new()
			btn.text = "Play"
			btn.add_theme_font_size_override("font_size", 14)
			var level_idx = i
			btn.pressed.connect(func(): _play_level(level_idx))
			vbox.add_child(btn)
			cards.append(btn)
		
		grid.add_child(card)
		cards.append(card)
	
	# Back button
	var back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.anchor_left = 0.4
	back_btn.anchor_right = 0.6
	back_btn.anchor_top = 0.82
	back_btn.anchor_bottom = 0.82
	back_btn.pressed.connect(_hide)
	back_btn.add_theme_font_size_override("font_size", 16)
	add_child(back_btn)
	cards.append(back_btn)

func _on_state(st):
	if st == GameManager.State.MENU and visible:
		_build_cards()  # Refresh scores

func _show():
	visible = true
	_build_cards()

func _hide():
	visible = false
	_build_cards()

func _play_level(idx):
	GameManager.load_level(idx)
	visible = false
