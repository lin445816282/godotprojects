extends Node

# 设置管理：灵敏度等简单键值持久化
const PATH = "user://settings.json"
var data = {}

func _ready():
	load_settings()
	apply()

func load_settings():
	var f = File.new()
	if f.file_exists(PATH):
		f.open(PATH, File.READ)
		var d = parse_json(f.get_as_text())
		f.close()
		if d is Dictionary:
			data = d

func save():
	var f = File.new()
	f.open(PATH, File.WRITE)
	f.store_string(to_json(data))
	f.close()

func has(key):
	return data.has(key)

func get(key, default = null):
	return data.get(key, default)

func set(key, value):
	data[key] = value
	save()

# 音量
func get_volume(kind, default_db = 0.0):
	return data.get(kind, default_db)

func set_volume(kind, db):
	data[kind] = db
	save()

# 键位：保存按键scancode并应用到InputMap
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

func set_key(action, scancode):
	var map = data.get("keys", {})
	map[action] = scancode
	data["keys"] = map
	apply()
	save()

func apply():
	var map = data.get("keys", {})
	for action in ACTIONS:
		var sc = ACTIONS[action]
		if map.has(action):
			sc = int(map[action])
		InputMap.action_erase_events(action)
		var ev = InputEventKey.new()
		ev.scancode = sc
		InputMap.action_add_event(action, ev)

