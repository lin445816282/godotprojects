extends Node

# 程序生成棋盘格纹理，供地面使用，替代纯色
static func checker(rows = 8, cols = 8, a = Color(0.35, 0.6, 0.35), b = Color(0.2, 0.4, 0.2)):
	var img = Image.new()
	img.create(rows, cols, false, Image.FORMAT_RGB8)
	for y in range(cols):
		for x in range(rows):
			var c = a if (x + y) % 2 == 0 else b
			img.set_pixel(x, y, c)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat
