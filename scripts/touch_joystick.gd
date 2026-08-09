extends Control

# Virtual joystick for mobile — bottom-left corner
# Emulates keyboard input (move_forward/back/left/right)

var touch_index = -1
var base_center = Vector2.ZERO
var stick_pos = Vector2.ZERO
var radius = 60.0
var is_active = false

func _ready():
	# Only show on touch devices
	if not OS.has_feature("mobile") and not OS.has_feature("web_android") and not OS.has_feature("web_ios"):
		visible = false
		set_process(false)
		return
	
	anchor_left = 0.08
	anchor_top = 0.65
	anchor_right = 0.08
	anchor_bottom = 0.65
	base_center = Vector2(radius + 20, radius + 20)

func _draw():
	if not visible:
		return
	
	# Draw base circle
	draw_circle(base_center, radius, Color(0.15, 0.15, 0.2, 0.5))
	draw_arc(base_center, radius, 0, TAU, 64, Color(0.3, 0.3, 0.4, 0.6), 2.0)
	
	# Draw stick
	if is_active:
		var stick = base_center + stick_pos
		draw_circle(stick, radius * 0.5, Color(0.3, 0.3, 0.5, 0.7))
		draw_circle(stick, radius * 0.5, Color(0.5, 0.5, 0.7, 0.3))
	else:
		draw_circle(base_center, radius * 0.3, Color(0.2, 0.2, 0.3, 0.4))

func _input(event):
	if not visible:
		return
	
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event):
	if event.pressed and touch_index == -1:
		# Check if touch is in left half of screen
		if event.position.x < get_viewport().size.x * 0.4:
			touch_index = event.index
			is_active = true
			_update_stick(event.position)
			queue_redraw()
	elif not event.pressed and event.index == touch_index:
		touch_index = -1
		is_active = false
		stick_pos = Vector2.ZERO
		_reset_input()
		queue_redraw()

func _handle_drag(event):
	if event.index == touch_index:
		_update_stick(event.position)
		queue_redraw()

func _update_stick(touch_pos):
	var local_pos = touch_pos - (base_center + global_position)
	var dist = local_pos.length()
	if dist > radius:
		local_pos = local_pos.normalized() * radius
	stick_pos = local_pos
	
	# Emulate keyboard input
	var normalized = stick_pos / radius  # -1 to 1
	
	# Forward/Back
	if normalized.y < -0.2:
		Input.action_press("move_forward")
		Input.action_release("move_backward")
	elif normalized.y > 0.2:
		Input.action_press("move_backward")
		Input.action_release("move_forward")
	else:
		Input.action_release("move_forward")
		Input.action_release("move_backward")
	
	# Left/Right
	if normalized.x < -0.2:
		Input.action_press("move_left")
		Input.action_release("move_right")
	elif normalized.x > 0.2:
		Input.action_press("move_right")
		Input.action_release("move_left")
	else:
		Input.action_release("move_left")
		Input.action_release("move_right")

func _reset_input():
	Input.action_release("move_forward")
	Input.action_release("move_backward")
	Input.action_release("move_left")
	Input.action_release("move_right")
