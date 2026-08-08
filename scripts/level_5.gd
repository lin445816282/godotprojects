extends Spatial

# 关卡5：Boss关 — 单一Boss敌人、窄小场地、生存+收集
func _ready():
	GameManager.current_level = 4
	GameManager.target = 10
	GameManager.duration = 40.0
	var we = get_node_or_null("WorldEnv")
	if we and we.environment:
		var env = we.environment
		env.background_mode = Environment.BG_SKY
		env.ambient_light_energy = 0.3
		var sky = PanoramaSky.new()
		var img = Image.new()
		var w = 256
		var h = 128
		img.create(w, h, false, Image.FORMAT_RGB8)
		for y in range(h):
			var t = float(y) / h
			var c = Color(0.05, 0.02, 0.1).linear_interpolate(Color(0.2, 0.05, 0.1), t)
			for x in range(w):
				img.set_pixel(x, y, c)
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		sky.panorama = tex
		env.background_sky = sky
