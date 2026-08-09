extends Control

# Jump button for mobile — bottom-right corner
# Emulates space/jump input

var touch_index = -1
var is_pressed = false
var radius = 50.0
var center = Vector2.ZERO

func _ready():
	if not OS.has_feature("mobile") and not OS.has_feature("web_android") and not OS.has_feature("web_ios"):
		visible = false
		set_process(false)
		return
	
	anchor_left = 0.85
	anchor_top = 0.70
	anchor_right = 0.85
	anchor_bottom = 0.70
	center = Vector2(radius + 10, radius + 10)
	size = Vector2(radius * 2 + 20, radius * 2 + 20)

func _draw():
	if not visible:
		return
	
	# Draw jump button
	var color = Color(0.15, 0.15, 0.25, 0.6)
	if is_pressed:
		color = Color(0.3, 0.3, 0.5, 0.8)
	
	draw_circle(center, radius, color)
	draw_arc(center, radius, 0, TAU, 64, Color(0.4, 0.4, 0.6, 0.5), 3.0)
	
	# Draw arrow
	var arrow_size = radius * 0.4
	var points = [
		center + Vector2(0, -arrow_size),
		center + Vector2(-arrow_size * 0.6, arrow_size * 0.3),
		center + Vector2(arrow_size * 0.6, arrow_size * 0.3),
	]
	draw_polygon(points, [Color(0.7, 0.7, 0.9, 0.8)])

func _input(event):
	if not visible:
		return
	
	if event is InputEventScreenTouch:
		_handle_touch(event)

func _handle_touch(event):
	# Check if touch is in right half of screen
	var touch = event.position
	var my_pos = center + global_position
	var dist = (touch - my_pos).length()
	
	if event.pressed and dist < radius * 1.5 and touch_index == -1:
		touch_index = event.index
		is_pressed = true
		Input.action_press("jump")
		queue_redraw()
	elif not event.pressed and event.index == touch_index:
		touch_index = -1
		is_pressed = false
		Input.action_release("jump")
		queue_redraw()
