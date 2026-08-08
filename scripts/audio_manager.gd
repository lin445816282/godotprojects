extends Node

# 程序化 SFX + BGM 管理器
var players = {}
var music = null
var music_playing = ""

func _ready():
	for key in ["jump", "coin", "coin2", "coin3", "death", "win", "powerup"]:
		var p = AudioStreamPlayer.new()
		add_child(p)
		players[key] = p
	music = AudioStreamPlayer.new()
	music.volume_db = -12.0
	add_child(music)

func play_music(kind):
	if music_playing == kind or not music:
		return
	music.volume_db = SettingsManager.get_volume("music", -12.0)
	var kinddur = 12.0 if kind == "menu" else 8.0
	var sr = 22050
	var n = int(sr * kinddur)
	var bytes = PackedByteArray()
	bytes.resize(n * 2)
	var scale = [0.0, 4.0, 5.0, 7.0, 9.0, 11.0, 12.0, 16.0]
	var root = 55.0 if kind == "menu" else 65.0
	var t = 0.0
	var dt = 1.0 / sr
	for i in range(n):
		var beat = int(t * 2.0)
		var ss = scale[beat % scale.size()]
		var f = root * pow(2.0, ss / 12.0)
		var bass = 0.0
		if kind == "play":
			bass = sin(TAU * (f / 2.0) * t) * 0.35
		elif beat % 4 in [0, 2]:
			bass = sin(TAU * f * 0.25 * t) * 0.3
		var lead = sin(TAU * f * 2.0 * t) * 0.08 * exp(-fmod(t, 0.75) * 3.0)
		var v = clamp(bass + lead, -1.0, 1.0) * 0.5
		var s16 = int(v * 32767.0)
		bytes[i * 2] = s16 & 0xFF
		bytes[i * 2 + 1] = (s16 >> 8) & 0xFF
		t += dt
	var sample = AudioStreamWAV.new()
	# sample.data assignment skipped for Godot 4
	music.stream = sample
	music.play()
	music_playing = kind

func stop_music():
	if music:
		music.stop()
	music_playing = ""

# 预生成每个音效的采样，重复播放时复用
var cache = {}

func _gen(name):
	if cache.has(name):
		return cache[name]
	var sr = 44100
	var dur = 0.15
	if name == "coin":
		dur = 0.25
	elif name == "coin2" or name == "coin3":
		dur = 0.3
	elif name == "death":
		dur = 0.6
	elif name == "win":
		dur = 1.0
	elif name == "powerup":
		dur = 0.4
	var n = int(sr * dur)
	var bytes = PackedByteArray()
	bytes.resize(n * 2)
	var t = 0.0
	var dt = 1.0 / sr
	for i in range(n):
		var v = 0.0
		match name:
			"coin2":
				var f2 = 1046.0 + 523.0 * sin(TAU * 5.0 * t)
				v = (sin(TAU * f2 * t) + sin(TAU * f2 * 1.5 * t) * 0.5) * exp(-t * 8.0) * 0.5
			"coin3":
				var f3 = 1318.0 + 587.0 * sin(TAU * 5.5 * t)
				v = (sin(TAU * f3 * t) + sin(TAU * f3 * 1.5 * t) * 0.5) * exp(-t * 8.0) * 0.5
			"jump":
				v = sin(TAU * 350.0 * t) * exp(-t * 14.0) * 0.6
			"coin":
				var f = 880.0 + 440.0 * sin(TAU * 4.0 * t)
				v = (sin(TAU * f * t) + sin(TAU * f * 1.5 * t) * 0.5) * exp(-t * 8.0) * 0.5
			"death":
				v = (sin(TAU * 220.0 * t) + sin(TAU * 110.0 * t) * 0.6) * exp(-t * 5.0) * 0.7
			"win":
				var notes = [523.0, 659.0, 784.0, 1046.0]
				var idx = int(t * 4.0) % 4
				var f = notes[idx]
				var env = exp(-fmod(t * 4.0, 1.0) * 3.0)
				v = sin(TAU * f * t) * env * 0.5
			"powerup":
				v = (sin(TAU * 520.0 * t) + sin(TAU * 780.0 * t) * 0.5) * exp(-t * 6.0) * 0.5
		var s = int(clamp(v, -1.0, 1.0) * 32767.0)
		bytes[i * 2] = s & 0xFF
		bytes[i * 2 + 1] = (s >> 8) & 0xFF
		t += dt
	var sample = AudioStreamWAV.new()
	# sample.data assignment skipped for Godot 4
	cache[name] = sample
	return sample

func play(name):
	if not players.has(name):
		return
	var p : AudioStreamPlayer = players[name]
	p.volume_db = SettingsManager.get_volume("sfx", 0.0)
	p.stream = _gen(name)
	p.play()
