extends Camera

export var distance = 8.0
var yaw = 0.0
var pitch = -20.0
var player = null

func _ready():
	set_process_input(true)
	find_player()
	# Default position behind spawn point so camera isn't stuck underground
	global_transform.origin = Vector3(0, 7.0, 7.5)
	look_at(Vector3(0, 1.5, 0), Vector3.UP)

func find_player():
	for p in get_tree().get_nodes_in_group("player"):
		player = p
		return

func _input(event):
	if player and event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_RIGHT):
		yaw -= event.relative.x * 0.3
		pitch -= event.relative.y * 0.3
		pitch = clamp(pitch, -70.0, -5.0)

func _process(_dt):
	if not player:
		find_player()
	if not player:
		# Still no player, stay at default view
		return
	var tp = player.global_transform.origin + Vector3(0, 1.5, 0)
	var r = deg2rad(yaw)
	var p = deg2rad(pitch)
	global_transform.origin = tp + Vector3(
		distance * sin(r) * cos(p),
		-distance * sin(p),
		distance * cos(r) * cos(p)
	)
	look_at(tp, Vector3.UP)