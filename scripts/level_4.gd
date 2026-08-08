extends Spatial

# 关卡4：冰原 — 低摩擦移动平台、大量旋转障碍、磁铁道具密集
func _ready():
	GameManager.current_level = 3
	GameManager.target = 18
	GameManager.duration = 55.0
