extends Node3D

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
		var sky = Sky.new()
	var sky_mat = PanoramaSkyMaterial.new()
	sky_mat.panorama = tex
	sky.sky_material = sky_mat
	env.sky = sky
