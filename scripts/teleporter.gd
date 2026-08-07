extends Area

# 传送门：玩家进入后传送到目标点
export(NodePath) var target = null
var dest = null

func _ready():
	connect("body_entered", self, "_teleport")
	if target:
		dest = get_node(target)

func _teleport(body):
	if not body.is_in_group("player"):
		return
	if dest:
		body.global_transform.origin = dest.global_transform.origin + Vector3(0, 1, 0)
		AudioManager.play("powerup")
