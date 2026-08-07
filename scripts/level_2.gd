extends Spatial

# 关卡2：浮岛平台跳跃，掉落后判定失败；金币更多、分值更高
func _ready():
	GameManager.current_level = 1
	GameManager.target = 15
	GameManager.duration = 50.0
