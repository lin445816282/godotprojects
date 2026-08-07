extends Spatial

# 关卡3：城垒——小场地、高密度敌人、更多移动平台
func _ready():
	GameManager.current_level = 2
	GameManager.target = 20
	GameManager.duration = 45.0
