extends Area3D

enum Type { SHIELD, SPEED, MAGNET }
@export var power_type: Type = Type.MAGNET
var taken = false
var float_time = 0.0
var base_y = 0.0

func _ready():
	body_entered.connect(_pick)
	GameManager.game_started.connect(_on_game_started)
	base_y = global_position.y
	float_time = randf() * TAU
	var pc = Color(0.8, 0.3, 0.8, 1)
	if power_type == Type.SHIELD:
		pc = Color(0.2, 0.8, 0.2, 1)
	elif power_type == Type.SPEED:
		pc = Color(0.8, 0.8, 0.1, 1)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = pc
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.emission_enabled = true
	mat.emission = pc
	mat.emission_energy_multiplier = 1.3
	$Mesh.material_override = mat

func _process(dt):
	if taken:
		$Mesh.visible = false
		return
	float_time += dt
	var pos = global_position
	pos.y = base_y + sin(float_time * 2.0) * 0.3
	global_position = pos
	rotate_y(dt * 2.0)

func _pick(body):
	if taken or not body.is_in_group("player"):
		return
	taken = true
	AudioManager.play("powerup")
	match power_type:
		Type.SHIELD:  body.activate_shield()
		Type.SPEED:   body.activate_speed()
		Type.MAGNET:  body.activate_magnet()
	$Mesh.visible = false

func _on_game_started():
	taken = false
	$Mesh.visible = true
	float_time = randf() * TAU
	global_position.y = base_y
