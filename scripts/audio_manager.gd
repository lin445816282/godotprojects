extends Node

# 程序化 SFX 管理器：实时合成短音效，无需外部素材
var players = {}

func _ready():
	for key in ["jump", "coin", "death", "win", "powerup"]:
		var p = AudioStreamPlayer.new()
		add_child(p)
		players[key] = p

# 预生成每个音效的采样，重复播放时复用
var cache = {}

func _gen(name):
	if cache.has(name):
		return cache[name]
	var sr = 44100
	var dur = 0.15
	if name == "coin":
		dur = 0.25
	elif name == "death":
		dur = 0.6
	elif name == "win":
		dur = 1.0
	elif name == "powerup":
		dur = 0.4
	var n = int(sr * dur)
	var bytes = PoolByteArray()
	bytes.resize(n * 2)
	var t = 0.0
	var dt = 1.0 / sr
	for i in range(n):
		var v = 0.0
		match name:
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
	var sample = AudioStreamSample.new()
	sample.format = AudioStreamSample.FORMAT_16_BITS
	sample.mix_rate = sr
	sample.stereo = false
	sample.data = bytes
	cache[name] = sample
	return sample

func play(name):
	if not players.has(name):
		return
	var p : AudioStreamPlayer = players[name]
	p.stream = _gen(name)
	p.play()
