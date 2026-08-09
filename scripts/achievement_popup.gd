extends Control

# 成就弹窗：显示3秒后淡出
var achievements_queue = []
var showing = false

func _ready():
	Achievements.unlocked.connect(_on_achievement)

func _on_achievement(name):
	achievements_queue.append(name)
	if not showing:
		_show_next()

func _show_next():
	if achievements_queue.empty():
		showing = false
		return
	showing = true
	var name = achievements_queue.pop_front()
	var desc = Achievements.ACH.get(name, name)
	var panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.1
			panel.position.y = 0
		panel.self_modulate = Color(0, 0, 0, 0.85)
	add_child(panel)
	var label = Label.new()
	label.text = "Achievement Unlocked!\n" + desc
	label.align = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.add_theme_color_override("font_color", Color(1, 0.85, 0.1, 1))
	panel.add_child(label)
	# Fade out after 3s
	var t = 0.0
	while t < 3.0 and is_instance_valid(panel):
		t += get_process_delta_time()
		if t > 2.5:
			panel.modulate.a = (3.0 - t) / 0.5
		await get_tree().process_frame
	if is_instance_valid(panel):
		panel.queue_free()
	_show_next()
