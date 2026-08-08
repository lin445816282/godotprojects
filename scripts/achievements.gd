extends Node

# 简易成就系统
signal unlocked(name)

const ACH = {
	"first_win": "First Win - 首次通关任意关卡",
	"three_wins": "Hat Trick - 至少通关2个不同关卡",
	"sprinter": "Sprinter - 任一关卡用时<25秒",
	"no_hit": "Untouchable - 无伤通关",
	"collector": "Collector - 收集所有金币通关",
}

var earned = {}

func _ready():
	if SettingsManager.has("achievements"):
		earned = SettingsManager.get("achievements", {})

func unlock(name):
	if earned.has(name):
		return
	earned[name] = true
	SettingsManager.set("achievements", earned)
	emit_signal("unlocked", name)
