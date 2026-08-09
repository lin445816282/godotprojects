extends Node3D

# Level 1
func _ready():
	GameManager.current_level = 0
	GameManager.target = 5
	GameManager.duration = 60.0
