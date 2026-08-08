extends Node3D

# Level 3 — procedurally generated
func _ready():
	GameManager.current_level = 2
	GameManager.target = 20
	GameManager.duration = 45.0
	var we = get_node_or_null("WorldEnv")
	if we and we.environment:
		var env = we.environment
		env.background_mode = Environment.BG_SKY
		var sky = Sky.new()
	var sky_mat = PanoramaSkyMaterial.new()
	sky_mat.panorama = tex
	sky.sky_material = sky_mat
	env.sky = sky
