extends CharacterBody3D

# 移动平台：在两点间往返移动，把站在上面的物体一起带走
@export var speed = 2.0
@export var dist = 3.0
@export var vertical = false
var base = Vector3.ZERO
var phase = 0.0
var attached = null

func _ready():
	base = global_position
	var a = get_node_or_null("PlatArea")
	if a:
		a.body_entered.connect(_on_Area_body_entered)
		a.body_exited.connect(_on_Area_body_exited)
	# 给平台添加可见材质
	if has_node("Mesh") and not $Mesh.material_override:
		var plat_mat = StandardMaterial3D.new()
		plat_mat.albedo_color = Color(0.55, 0.35, 0.2, 1)
		plat_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		$Mesh.material_override = plat_mat

func _physics_process(dt):
	phase += dt * speed
	var offset = Vector3(sin(phase), 0, 0) * dist
	if vertical:
		offset = Vector3(0, sin(phase), 0) * dist
	var target = base + offset
	var motion = target - global_position
	velocity = motion
	# 带动附着的玩家/物体
	if attached and is_instance_valid(attached):
		attached.global_position += motion
	var _vel = move_and_slide()

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		attached = body

func _on_Area_body_exited(body):
	if body == attached:
		attached = null
