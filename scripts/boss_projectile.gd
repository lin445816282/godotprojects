extends Spatial

var direction = Vector3.FORWARD
var speed = 6.0
var lifetime = 3.0

func _ready():
	add_to_group("boss_projectiles")

func _process(dt):
	lifetime -= dt
	if lifetime <= 0:
		queue_free()
		return
	var pos = global_transform.origin
	pos += direction * speed * dt
	global_transform.origin = pos
