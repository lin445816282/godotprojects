extends Node

# 简易国际化：键值对翻译
var lang = "en"
var strings = {
	"en": {
		"coin_quest": "Coin Quest",
		"play": "Play",
		"play_level_1": "Play Level 1",
		"restart": "Restart",
		"quit": "Quit",
		"win": "You Win!",
		"lose": "Game Over",
		"paused": "Paused",
		"coins": "Coins",
		"time": "Time",
		"level": "Level",
		"hits_left": "Hits left",
		"next_level": "Next Level",
		"back_to_menu": "Back to Menu",
		"level_select": "Level Select",
		"mute": "Mute",
		"unmute": "Unmute",
		"settings": "Settings",
		"sfx_volume": "SFX Volume",
		"music_volume": "Music Volume",
		"sensitivity": "Sensitivity",
		"tutorial_text": "WASD = Move\\nSpace = Jump\\nRight-Click = Look\\nESC = Pause",
		"tutorial_got_it": "Got it!",
		"pause_controls": "Controls:\\nWASD = Move | Space = Jump\\nRight-Click = Look | ESC = Resume",
		"loading": "Loading...",
		"entering_level": "Entering Level ",
		"level_names": ["Grasslands", "Floating Isles", "Fortress", "Frozen Wastes", "Boss Arena"],
		"best": "Best: ",
		"locked": "Locked",
		"resume": "ESC = Resume",
		"lang_en": "English",
		"lang_zh": "中文",
		"wasd_hint": "WASD = Move  Space = Jump",
		"coins_prefix": "Coins: ",
		"time_prefix": "Time: ",
		"level_prefix": "Level ",
		"hits_left_prefix": "Hits left: ",
		"go_text": "GO!",
		"loading_text": "Loading...",
		"entering_level_text": "Entering Level ",
		"score_text": "Score: ",
		"press_a_key": "Press a key: ",
		"unlocked_text": "Unlocked: ",
	},
	"zh": {
		"coin_quest": "金币探险",
		"play": "开始",
		"play_level_1": "第一关",
		"restart": "重新开始",
		"quit": "退出",
		"win": "胜利!",
		"lose": "游戏结束",
		"paused": "已暂停",
		"coins": "金币",
		"time": "时间",
		"level": "关卡",
		"hits_left": "剩余生命",
		"next_level": "下一关",
		"back_to_menu": "返回主菜单",
		"level_select": "选关",
		"mute": "静音",
		"unmute": "取消静音",
		"settings": "设置",
		"sfx_volume": "音效音量",
		"music_volume": "音乐音量",
		"sensitivity": "灵敏度",
		"tutorial_text": "WASD = 移动\\n空格 = 跳跃\\n右键 = 视角\\nESC = 暂停",
		"tutorial_got_it": "知道了!",
		"pause_controls": "操作:\\nWASD = 移动 | 空格 = 跳跃\\n右键 = 视角 | ESC = 恢复",
		"loading": "加载中...",
		"entering_level": "进入第 ",
		"level_names": ["草原", "浮空岛", "城堡", "冰原", "Boss"],
		"best": "最高: ",
		"locked": "未解锁",
		"resume": "ESC = 恢复",
		"lang_en": "English",
		"lang_zh": "中文",
		"wasd_hint": "WASD = 移动  空格 = 跳跃",
		"coins_prefix": "金币: ",
		"time_prefix": "时间: ",
		"level_prefix": "关卡 ",
		"hits_left_prefix": "剩余生命: ",
		"go_text": "开始!",
		"loading_text": "加载中...",
		"entering_level_text": "进入第 ",
		"score_text": "分数: ",
		"press_a_key": "请按键: ",
		"unlocked_text": "已解锁: ",
	}
}

func t(key):
	var table = strings.get(lang, strings["en"])
	var val = table.get(key, key)
	return val

func t_arr(key):
	var table = strings.get(lang, strings["en"])
	var val = table.get(key, [])
	return val

func set_lang(l):
	if strings.has(l):
		lang = l
		SettingsManager.set_setting("language", l)
		# Reload scene to apply
		get_tree().reload_current_scene()
