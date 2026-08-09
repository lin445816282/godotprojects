extends Node

# Debug Helper: 在Godot编辑器中作为工具脚本运行
# 输出所有场景树和脚本错误到 res://debug_report.txt

func _ready():
	var f = FileAccess.open("res://debug_report.txt", FileAccess.WRITE)
	
	# List all autoloads
	f.store_string("=== Autoloads ===\n")
	for child in get_tree().root.get_children():
		f.store_string("  " + child.name + " (" + child.get_class() + ")\n")
	
	# List all scripts and their errors
	f.store_string("\n=== Scene Tree ===\n")
	_print_tree(get_tree().root, f, 0)
	
	f.store_string("\n=== Project Settings ===\n")
	f.store_string("config_version: " + str(ProjectSettings.get_setting("application/config/version")) + "\n")
	
	f.close()
	print("Debug report written to res://debug_report.txt")
	get_tree().quit()

func _print_tree(node, file, depth):
	var indent = "  ".repeat(depth)
	var script = node.get_script()
	var script_path = "none"
	if script:
		script_path = script.resource_path
	file.store_string(indent + node.name + " [" + node.get_class() + "] script=" + script_path + "\n")
	for child in node.get_children():
		_print_tree(child, file, depth + 1)
