extends Area3D

# 投掷物：飞行→碰撞→消失
var velocity = Vector3.FORWARD * 6.0
var lifetime = 4.0

func _ready():
	connect("body_entered", self, "_hit")

func _physics_process(dt):
	lifetime -= dt
	if lifetime <= 0:
		queue_free()
		return
	var pos = global_position
	pos += velocity * dt
	global_position = pos

func _hit(body):
	if body.is_in_group("player") and body.has_method("take_hit"):
		body.take_hit(-velocity.normalized())
	queue_free()
