extends StaticBody3D

# 门：初始上锁（有碰撞），钥匙解锁后消失
var locked = true

func _ready():
	$Col.set_deferred("disabled", false)
	add_to_group("gates")

func unlock():
	if not locked:
		return
	locked = false
	$Col.set_deferred("disabled", true)
	$Mesh.visible = false
	AudioManager.play("win")
