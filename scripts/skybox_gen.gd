extends Node

# 程序化天空盒生成：在WorldEnvironment中应用渐变天空
static func apply_gradient_sky(env: Environment, top_color = Color(0.2, 0.4, 0.9), horizon_color = Color(0.6, 0.8, 1.0), bottom_color = Color(0.3, 0.5, 0.4)):
	var sky = Sky.new()
	var img = Image.new()
	var w = 256
	var h = 128
	img.create(w, h, false, Image.FORMAT_RGB8)
	for y in range(h):
		var t = float(y) / h
		var horizon = 0.45
		var c: Color
		if t < horizon:
			c = top_color.lerp(horizon_color, t / horizon)
		else:
			c = horizon_color.lerp(bottom_color, (t - horizon) / (1.0 - horizon))
		for x in range(w):
			img.set_pixel(x, y, c)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	sky.panorama = tex
	env.sky = sky
	env.background_mode = Environment.BG_SKY
