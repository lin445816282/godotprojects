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
		var sky = Sky.new()
	var sky_mat = PanoramaSkyMaterial.new()
	sky_mat.panorama = tex
	sky.sky_material = sky_mat
	env.sky = sky
