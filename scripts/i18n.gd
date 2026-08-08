extends Node

# 简易国际化：键值对翻译
var lang = "en"
var strings = {
	"en": {
		"coin_quest": "Coin Quest",
		"play": "Play",
		"restart": "Restart",
		"quit": "Quit",
		"win": "You Win!",
		"lose": "Game Over",
		"paused": "Paused",
		"coins": "Coins",
		"time": "Time",
		"level": "Level",
	},
	"zh": {
		"coin_quest": "金币探险",
		"play": "开始",
		"restart": "重来",
		"quit": "退出",
		"win": "胜利!",
		"lose": "失败",
		"paused": "已暂停",
		"coins": "金币",
		"time": "时间",
		"level": "关卡",
	}
}

func t(key):
	return strings.get(lang, strings["en"]).get(key, key)

func set_lang(l):
	if strings.has(l):
		lang = l
