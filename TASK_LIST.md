# CoinQuest 完整任务列表

> 最后更新: 2026-08-10
> 分支: master
> 已推送: 6a4827b

---

## 阶段 A — UI 完善

### A1. Panel 样式美化
- [x] 场景分析完成
- [ ] scene.tscn: Panel 添加 `self_modulate = Color(0, 0, 0, 0.75)` 半透明深色背景
- [ ] 所有 level 脚本: `panel.self_modulate = Color(0, 0, 0, 0.75)`
- [ ] Title 字体颜色改为金色 `Color(1, 0.85, 0.1)`
- [ ] Info 字体颜色改为浅灰 `Color(0.7, 0.7, 0.7)`
- [ ] 按钮添加 `theme_override` 样式（hover 亮色、pressed 缩放 0.95）

### A2. 面板切换动画
- [ ] menu.gd: `_show()` 时 Panel 从 0.9 缩放到 1.0 (tween)
- [ ] menu.gd: `_end()` 时 Panel 淡入 (modulate.a 从 0 到 1)
- [ ] 面板切换时 Title 文字渐变金色

### A3. 设置面板启用
- [ ] menu.gd: `_show()` 使 SensSlider/SfxSlider/MusicSlider visible=true
- [ ] 添加设置标签(SFX/Music/Sensitivity)的 Label
- [ ] scene.tscn: 滑块移到按钮下方合理位置
- [ ] level 脚本: buttons_data 增加设置控件创建

### A4. 关卡选择画面
- [ ] 新增 `level_select.gd` 脚本
- [ ] 网格布局显示 5 关卡片(名称/最高分/锁定状态)
- [ ] 卡片点击跳转关卡
- [ ] menu.gd: 添加 "Level Select" 按钮替换 Level2Btn/Level3Btn
- [ ] 锁定关卡显示灰色+锁图标

### A5. 移动端触摸适配
- [ ] project.godot: 添加 `window/stretch/mode=canvas_items`
- [ ] 新增 `touch_joystick.gd`: 左下虚拟摇杆
- [ ] 新增 `touch_button.gd`: 右下跳跃按钮
- [ ] scene.tscn: 添加 TouchJoystick + JumpButton 节点(自动检测平台)
- [ ] level 脚本: 条件加载触摸控件
- [ ] 修改 player.gd: 读取虚拟摇杆输入
- [ ] HUD 字体根据窗口大小缩放

---

## 阶段 B — 用户体验

### B1. 首次教程
- [ ] 新增 `tutorial.gd`: 首次启动时显示操作提示
- [ ] 动画提示: WASD 键高亮闪烁
- [ ] 完成后保存标记到 user://tutorial_done

### B2. 加载画面
- [ ] game_manager.gd: `load_level()` 前显示 Loading 遮罩
- [ ] 居中文字 "Entering Level X..." 
- [ ] 场景加载完成后淡出

### B3. 音效/音乐开关
- [ ] menu.gd: Mute 复选框
- [ ] AudioManager: 静音时停止所有播放

### B4. 暂停菜单完善
- [ ] 暂停时显示操作键位提示表
- [ ] Resume / Back to Menu / Quit 三按钮

---

## 阶段 C — 视觉打磨

### C1. 地面纹理升级
- [ ] 各关卡独立棋盘格配色(绿/蓝/灰/红)
- [ ] 添加地面法线贴图效果(如有)

### C2. 粒子效果增强
- [ ] 敌人死亡爆炸粒子
- [ ] Boss 弹幕拖尾粒子
- [ ] 金币旋转光晕

### C3. 环境光调整
- [ ] 各关卡 DirectionalLight energy 调整(当前全 8.0/4.0)
- [ ] 添加第二盏补光(背光)

---

## 阶段 D — 游戏性

### D1. 难度递增
- [ ] 关卡参数表: 敌人数/速度/金币价值/时间
- [ ] Level1-5 渐进: 敌人从 1→4, 速度从 2→5
- [ ] Boss 血量随阶段增加

### D2. Boss 强化
- [ ] enemy_boss.gd: 近战冲撞技能
- [ ] 血量 < 50% 召小兵
- [ ] 死亡动画(爆炸+粒子)

### D3. 评分系统
- [ ] 通关后显示 ★/★★/★★★
- [ ] 星级 = f(收集率, 用时, 受伤次数)

### D4. 新道具
- [ ] 二段跳(boots)
- [ ] 无敌星(短暂无敌)
- [ ] 减速钟(敌人减速)

---
*每完成一项勾选 `[x]`，每完成一个模块提交一次*

### A1. Panel 样式美化 ✅
- [x] scene.tscn: Panel 半透明深色 + Title 金色 + Info 浅灰
- [x] level 脚本: panel.self_modulate 统一
- [x] 按钮圆角 + hover/pressed 颜色反馈
- [x] commit: 06c8497
