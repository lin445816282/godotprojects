extends Node3D

# Level 2 — procedurally generated
func _ready():
	GameManager.current_level = 1
	GameManager.target = 15
	GameManager.duration = 50.0
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
			var tt = float(y) / h
			var c = Color(0.2, 0.4, 0.9).linear_interpolate(Color(0.6, 0.8, 1.0), tt)
			for x in range(w):
				img.set_pixel(x, y, c)
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		sky.panorama = tex
		env.background_sky = sky
