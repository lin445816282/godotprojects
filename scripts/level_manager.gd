extends Node

# 关卡管理：切换关卡、解锁、最高分持久化
const SAVE_PATH = "user://save.json"
const LEVEL_COUNT = 5

var unlocked = 1  # 已解锁关卡数
var best_scores = {}  # level_idx -> best score

func _ready():
	load_save()

func load_save():
	var f = File.new()
	if f.file_exists(SAVE_PATH):
		f.open(SAVE_PATH, File.READ)
		var data = parse_json(f.get_as_text())
		f.close()
		if data is Dictionary:
			if data.has("unlocked"):
				unlocked = int(data["unlocked"])
			if data.has("best"):
				best_scores = data["best"]

func save():
	var f = File.new()
	f.open(SAVE_PATH, File.WRITE)
	f.store_string(to_json({
		"unlocked": unlocked,
		"best": best_scores
	}))
	f.close()

func unlock_next():
	if unlocked < LEVEL_COUNT:
		unlocked += 1
		save()

func record_score(level_idx, score):
	if not best_scores.has(str(level_idx)) or score > int(best_scores[str(level_idx)]):
		best_scores[str(level_idx)] = score
		save()
		return true
	return false

func best_for(level_idx):
	return int(best_scores.get(str(level_idx), 0))
