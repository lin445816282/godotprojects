extends Node

# 设置管理：灵敏度等简单键值持久化
const PATH = "user://settings.json"
var data = {}

func _ready():
	load_settings()

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
