extends Area3D

# 传送门：玩家进入后传送到目标点
@export var target: NodePath
var dest = null

func _ready():
	body_entered.connect(_teleport)
	if target:
		dest = get_node(target)

func _teleport(body):
	if not body.is_in_group("player"):
		return
	if dest:
		body.global_position = dest.global_position + Vector3(0, 1, 0)
		AudioManager.play("powerup")
		_spawn_particles()

func _spawn_particles():
	var cp = CPUParticles3D.new()
	cp.one_shot = true
	cp.emitting = true
	cp.amount = 30
	cp.lifetime = 0.6
	cp.local_coords = true
	cp.direction = Vector3(0, 1, 0)
	cp.spread = 180.0
	cp.gravity = Vector3(0, -3, 0)
	cp.velocity_min = 3.0
	cp.scale_amount_min = 0.1
	cp.color = Color(0.2, 0.9, 1, 1)
	add_child(cp)
	await get_tree().create_timer(0.8).timeout
	cp.queue_free()
