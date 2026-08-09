extends Camera3D

@export var distance = 8.0
@export var sensitivity = 0.3
var yaw = 0.0
var pitch = -20.0
var player = null

func _ready():
	# 从本地设置读取灵敏度
	if SettingsManager.has("sensitivity"):
		sensitivity = SettingsManager.get_setting("sensitivity")
	# Input handled via _input() callback
	find_player()
	# Default position behind spawn point so camera isn't stuck underground
	global_position = Vector3(0, 7.0, 7.5)
	look_at(Vector3(0, 1.5, 0), Vector3.UP)

func find_player():
	for p in get_tree().get_nodes_in_group("player"):
		player = p
		return

func _input(event):
	if player and event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, -70.0, -5.0)

func _process(_dt):
	if not player:
		find_player()
	if not player:
		# Still no player, stay at default view
		return
	var tp = player.global_position + Vector3(0, 1.5, 0)
	var r = deg_to_rad(yaw)
	var p = deg_to_rad(pitch)
	global_position = tp + Vector3(
		distance * sin(r) * cos(p),
		-distance * sin(p),
		distance * cos(r) * cos(p)
	)
	look_at(tp, Vector3.UP)