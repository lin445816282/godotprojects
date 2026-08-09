extends Node

# 金币拾取特效：一圈粒子向上扩散
static func spawn(at: Vector3, parent: Node, color = Color(1, 0.85, 0.1)):
	var cp = CPUParticles3D.new()
	cp.one_shot = true
	cp.emitting = true
	cp.amount = 15
	cp.lifetime = 0.5
	cp.local_coords = false
	cp.position = at
	cp.direction = Vector3(0, 1, 0)
	cp.spread = 40.0
	cp.gravity = Vector3(0, -8, 0)
	cp.initial_velocity_min = 3.0
	cp.scale_amount_min = 0.06
	cp.color = color
	parent.add_child(cp)
	cp.get_tree().create_timer(0.6).timeout.connect(cp.queue_free)
