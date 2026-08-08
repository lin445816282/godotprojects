extends Node3D

# 关卡4：冰原 — 低摩擦移动平台、大量旋转障碍、磁铁道具密集
func _ready():
	GameManager.current_level = 3
	GameManager.target = 18
	GameManager.duration = 55.0
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
			var c = Color(0.55, 0.75, 0.95).linear_interpolate(Color(0.8, 0.9, 1.0), t)
			for x in range(w):
				img.set_pixel(x, y, c)
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		sky.panorama = tex
		env.background_sky = sky
