extends KinematicBody

# 移动平台：在两点间往返移动，把站在上面的物体一起带走
export var speed = 2.0
export var dist = 3.0
var base = Vector3.ZERO
var phase = 0.0
var attached = null

func _ready():
	base = global_transform.origin

func _ready():
	base = global_transform.origin
	var a = get_node_or_null("PlatArea")
	if a:
		a.connect("body_entered", self, "_on_Area_body_entered")
		a.connect("body_exited", self, "_on_Area_body_exited")

func _physics_process(dt):
	phase += dt * speed
	var target = base + Vector3(sin(phase), 0, 0) * dist
	var motion = target - global_transform.origin
	# 带动附着的玩家/物体
	if attached and is_instance_valid(attached):
		attached.global_transform.origin += motion
	move_and_slide(motion, Vector3.UP)

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		attached = body

func _on_Area_body_exited(body):
	if body == attached:
		attached = null
