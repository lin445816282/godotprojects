extends Spatial

# 关卡5：Boss关 — 单一Boss敌人、窄小场地、生存+收集
func _ready():
	GameManager.current_level = 4
	GameManager.target = 10
	GameManager.duration = 40.0
