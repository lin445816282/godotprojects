extends MeshInstance

# 用棋盘格纹理替换纯色地面材质（运行时应用，无需素材）
func _ready():
	var img = Image.new()
	var n = 16
	img.create(n, n, false, Image.FORMAT_RGB8)
	for y in range(n):
		for x in range(n):
			var c = Color(0.35, 0.6, 0.35) if (x + y) % 2 == 0 else Color(0.2, 0.4, 0.2)
			img.set_pixel(x, y, c)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	var mat = SpatialMaterial.new()
	mat.albedo_texture = tex
	mat.flags_unshaded = false
	material_override = mat
