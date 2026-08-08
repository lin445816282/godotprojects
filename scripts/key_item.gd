extends Area3D

# 钥匙：拾取后通知门解锁
var taken = false
var base_y = 0.0
var ftime = 0.0

func _ready():
	connect("body_entered", self, "_pick")
	base_y = global_position.y
	ftime = randf() * TAU

func _process(dt):
	if taken:
		return
	ftime += dt
	var pos = global_position
	pos.y = base_y + sin(ftime * 2.0) * 0.15
	global_position = pos
	rotate_y(dt * 1.5)

func _pick(body):
	if taken or not body.is_in_group("player"):
		return
	taken = true
	# 通知关卡里的门解锁
	for n in get_tree().get_nodes_in_group("gates"):
		if n.has_method("unlock"):
			n.unlock()
	$Mesh.visible = false
	$Col.disabled = true
	AudioManager.play("coin3")
