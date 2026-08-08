extends Node

# 设置管理：灵敏度等简单键值持久化
const PATH = "user://settings.json"
var data = {}

func _ready():
	load_settings()
	apply()

func load_settings():
	if FileAccess.file_exists(PATH):
		var f = FileAccess.open(PATH, FileAccess.READ)
		var d = JSON.parse_string(f.get_as_text())
		f.close()
		if d is Dictionary:
			data = d

func save():
	var f = FileAccess.open(PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()

func has(key):
	return data.has(key)

func get_setting(key, default_val = null):
	return data.get(key, default_val)

func _set_setting(key, value):
	data[key] = value
	save()

# 音量
func get_volume(kind, default_db = 0.0):
	return data.get(kind, default_db)

func set_volume(kind, db):
	data[kind] = db
	save()

# 键位
const ACTIONS = {
	"move_forward": 87,
	"move_backward": 83,
	"move_left": 65,
	"move_right": 68,
	"jump": 32,
}

func default_keys():
	return ACTIONS

func get_key(action):
	var map = data.get("keys", {})
	if map.has(action):
		return int(map[action])
	return ACTIONS[action]

func set_key(action, keycode):
	var map = data.get("keys", {})
	map[action] = keycode
	data["keys"] = map
	apply()
	save()

func apply():
	var map = data.get("keys", {})
	for action in ACTIONS:
		var kc = ACTIONS[action]
		if map.has(action):
			kc = int(map[action])
		InputMap.action_erase_events(action)
		var ev = InputEventKey.new()
		ev.keycode = kc
		InputMap.action_add_event(action, ev)
