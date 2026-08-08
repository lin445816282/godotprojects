extends Node3D

# 关卡1：草地 — 教学关，基础平台跳跃和收集
func _ready():
	GameManager.current_level = 0
	GameManager.target = 9
	GameManager.duration = 60.0
	# Apply skybox
	var we = get_node_or_null("WorldEnv")
	if we and we.environment:
		var env = we.environment
		env.background_mode = Environment.BG_SKY
		var sky = PanoramaSky.new()
		var img = Image.new()
		var w = 256
		var h = 128
		img.create(w, h, false, Image.FORMAT_RGB8)
		for y in range(h):
			var t = float(y) / h
			var horizon = 0.45
			var c: Color
			if t < horizon:
				c = Color(0.2, 0.4, 0.9).linear_interpolate(Color(0.6, 0.8, 1.0), t / horizon)
			else:
				c = Color(0.6, 0.8, 1.0).linear_interpolate(Color(0.3, 0.5, 0.4), (t - horizon) / (1.0 - horizon))
			for x in range(w):
				img.set_pixel(x, y, c)
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		sky.panorama = tex
		env.background_sky = sky
