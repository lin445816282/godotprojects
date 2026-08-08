extends Node

# 护盾视觉效果：半透明球体围绕玩家
var player = null
var sphere: MeshInstance = null

func _ready():
	player = get_parent()
	if not sphere:
		sphere = MeshInstance.new()
		var sm = SphereMesh.new()
		sm.radius = 0.7
		sm.height = 1.4
		sphere.mesh = sm
		var mat = SpatialMaterial.new()
		mat.albedo_color = Color(0.2, 0.8, 0.2, 0.3)
		mat.flags_transparent = true
		mat.emission_enabled = true
		mat.emission_color = Color(0.2, 0.8, 0.2, 0.3)
		sphere.material_override = mat
		sphere.translation = Vector3(0, 0.8, 0)
		player.add_child(sphere)
	sphere.visible = false

func _process(_dt):
	if player and sphere:
		sphere.visible = player.has_shield
		if sphere.visible:
			sphere.rotate_y(0.03)
