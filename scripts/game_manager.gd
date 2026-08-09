extends Node

enum State { MENU, COUNTDOWN, PLAYING, PAUSED, WIN, LOSE }
signal state_changed(s)
signal score_changed(v)
signal timer_changed(t)
signal game_started
signal paused(p)
signal countdown_tick(t)
signal countdown_done

@export var duration = 60.0
@export var target = 11
@export var countdown_time = 3.0
var state = State.MENU
var countdown_left = 0.0
var current_level = 0
var score = 0
var time_left = 0.0

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") or (event is InputEventJoypadButton and event.button_index == 7 and event.pressed):
		toggle_pause()

func _process(dt):
	# Boss projectile movement
	if state == State.PLAYING:
		for b in get_tree().get_nodes_in_group("boss_projectiles"):
			var d = b.get_meta("dir", Vector3.FORWARD)
			var spd = b.get_meta("speed", 6.0)
			var life = b.get_meta("life", 3.0)
			life -= dt
			b.set_meta("life", life)
			if life <= 0:
				b.queue_free()
				continue
			b.global_position += d * spd * dt
		# Thrower bullets
		for b in get_tree().get_nodes_in_group("thrower_bullets"):
			var vel = b.get_meta("vel", Vector3.FORWARD * 6.0)
			var life = b.get_meta("life", 4.0)
			life -= dt
			b.set_meta("life", life)
			if life <= 0:
				b.queue_free()
				continue
			b.global_position += vel * dt
	if state == State.COUNTDOWN:
		countdown_left -= dt
		emit_signal("countdown_tick", int(ceil(countdown_left)))
		if countdown_left <= 0.0:
			emit_signal("countdown_done")
			emit_signal("game_started")
			_change(State.PLAYING)
		return
	if state == State.PLAYING:
		time_left -= dt
		emit_signal("timer_changed", time_left)
		if time_left <= 0:
			time_left = 0
			if score >= target:
				AudioManager.play("win")
				_on_level_complete()
				_change(State.WIN)
			else:
				_change(State.LOSE)

var wins_total = 0

func start_game():
	score = 0
	time_left = duration
	emit_signal("score_changed", 0)
	emit_signal("timer_changed", duration)
	countdown_left = countdown_time
	emit_signal("countdown_tick", int(ceil(countdown_left)))
	_change(State.COUNTDOWN)

func add_score(n = 1):
	if state != State.PLAYING:
		return
	score += n
	emit_signal("score_changed", score)
	if score >= target:
		AudioManager.play("win")
		_on_level_complete()
		_change(State.WIN)

func _on_level_complete():
	LevelManager.record_score(current_level, score)
	LevelManager.unlock_next()
	_check_achievements()

func _check_achievements():
	wins_total += 1
	if wins_total >= 1:
		Achievements.unlock("first_win")
	if wins_total >= 2:
		Achievements.unlock("three_wins")
	if time_left >= duration - 25.0:
		Achievements.unlock("sprinter")

func player_died():
	if state == State.PLAYING:
		_change(State.LOSE)

func toggle_pause():
	if state == State.PLAYING:
		_change(State.PAUSED)
	elif state == State.PAUSED:
		_change(State.PLAYING)

const LEVELS = ["res://scene.tscn", "res://scenes/level_2.tscn", "res://scenes/level_3.tscn", "res://scenes/level_4.tscn", "res://scenes/level_5.tscn"]

func show_loading(idx):
	if idx < 0 or idx >= LEVELS.size():
		return
	var layer = CanvasLayer.new()
	layer.name = "LoadingLayer"
	layer.layer = 128
	get_tree().current_scene.add_child(layer)
	
	var loading = ColorRect.new()
	loading.name = "LoadingOverlay"
	loading.color = Color(0, 0, 0, 0.85)
	loading.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(loading)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.offset_left = -150
	vbox.offset_top = -50
	vbox.offset_right = 150
	vbox.offset_bottom = 50
	loading.add_child(vbox)
	
	var text = Label.new()
	var names = I18n.t_arr("level_names")
	text.text = names[idx]
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.add_theme_color_override("font_color", Color(1, 0.85, 0.1, 1))
	text.add_theme_font_size_override("font_size", 28)
	vbox.add_child(text)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(spacer)
	
	var progress = ProgressBar.new()
	progress.name = "LoadProgress"
	progress.custom_minimum_size = Vector2(260, 22)
	progress.value = 0.0
	vbox.add_child(progress)
	
	var label = Label.new()
	label.name = "LoadLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	label.add_theme_font_size_override("font_size", 14)
	label.text = "0%"
	vbox.add_child(label)
	
	var tween = loading.create_tween()
	tween.tween_property(progress, "value", 1.0, 0.7).set_ease(Tween.EASE_IN_OUT)
	var timer = 0.0
	while timer < 0.7 and is_instance_valid(layer):
		timer += get_process_delta_time()
		var pct = min(timer / 0.7 * 100.0, 99.0)
		if is_instance_valid(label):
			label.text = str(int(pct)) + "%"
		await get_tree().process_frame
	if is_instance_valid(label):
		label.text = "100%"
	await get_tree().process_frame

func load_level(idx):
	show_loading(idx)
	
	if idx == -1 or idx >= LEVELS.size():
		current_level = 0
		get_tree().reload_current_scene()
		_change(State.MENU)
	else:
		current_level = idx
		get_tree().change_scene_to_file(LEVELS[idx])
		_change(State.COUNTDOWN)

func start_level_countdown():
	score = 0
	time_left = duration
	countdown_left = countdown_time
	emit_signal("score_changed", 0)
	emit_signal("timer_changed", duration)
	emit_signal("countdown_tick", int(ceil(countdown_left)))
	_change(State.COUNTDOWN)

func quit_game():
	get_tree().quit()

func _change(s):
	if state != s:
		state = s
		emit_signal("state_changed", s)
		_update_music()

func _update_music():
	if state == State.PLAYING or state == State.COUNTDOWN or state == State.PAUSED:
		AudioManager.play_music("play")
	else:
		AudioManager.play_music("menu")
