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
@export var target = 9
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

func load_level(idx):
	if idx == -1 or idx >= LEVELS.size():
		current_level = 0
		get_tree().reload_current_scene()
		_change(State.MENU)
	else:
		current_level = idx
		score = 0
		time_left = duration
		countdown_left = countdown_time
		emit_signal("score_changed", 0)
		emit_signal("timer_changed", duration)
		emit_signal("countdown_tick", int(ceil(countdown_left)))
		get_tree().change_scene_to_file(LEVELS[idx])
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