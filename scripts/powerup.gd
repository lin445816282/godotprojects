extends Area

enum Type { SHIELD, SPEED, MAGNET }
export(Type) var power_type = Type.MAGNET
var taken = false
var float_time = 0.0
var base_y = 0.0

func _ready():
	connect("body_entered", self, "_pick")
	GameManager.connect("game_started", self, "_on_game_started")
	base_y = global_transform.origin.y
	float_time = randf() * TAU
	set_mesh_color()

func set_mesh_color():
	var c
	match power_type:
		Type.SHIELD:  c = Color(0.2, 0.8, 0.2, 1)
		Type.SPEED:   c = Color(0.8, 0.8, 0.1, 1)
		Type.MAGNET:  c = Color(0.8, 0.3, 0.8, 1)
	$Mesh.material_override.albedo_color = c

func _process(dt):
	if taken:
		$Mesh.visible = false
		return
	float_time += dt
	var pos = global_transform.origin
	pos.y = base_y + sin(float_time * 2.0) * 0.3
	global_transform.origin = pos
	rotate_y(dt * 2.0)

func _pick(body):
	if taken or not body.is_in_group("player"):
		return
	taken = true
	match power_type:
		Type.SHIELD:  body.activate_shield()
		Type.SPEED:   body.activate_speed()
		Type.MAGNET:  body.activate_magnet()
	$Mesh.visible = false

func _on_game_started():
	taken = false
	$Mesh.visible = true
	float_time = randf() * TAU
	global_transform.origin.y = base_y