extends Node

enum State { MENU, PLAYING, WIN, LOSE }
signal state_changed(s)
signal score_changed(v)
signal timer_changed(t)
signal game_started

export var duration = 60.0
export var target = 5
var state = State.MENU
var score = 0
var time_left = 0.0

func _process(dt):
	if state == State.PLAYING:
		time_left -= dt
		emit_signal("timer_changed", time_left)
		if time_left <= 0:
			time_left = 0
			if score >= target:
				AudioManager.play("win")
				_change(State.WIN)
			else:
				_change(State.LOSE)

func start_game():
	score = 0
	time_left = duration
	emit_signal("score_changed", 0)
	emit_signal("timer_changed", duration)
	emit_signal("game_started")
	_change(State.PLAYING)

func add_score(n = 1):
	if state != State.PLAYING:
		return
	score += n
	emit_signal("score_changed", score)
	if score >= target:
		_change(State.WIN)

func player_died():
	if state == State.PLAYING:
		_change(State.LOSE)

func quit_game():
	get_tree().quit()

func _change(s):
	if state != s:
		state = s
		emit_signal("state_changed", s)