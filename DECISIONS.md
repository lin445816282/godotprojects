# Architecture Decisions Log

## 2026-08-09: Godot 4 迁移决策

**背景**: 项目代码全部使用 Godot 3.x 语法，但 `project.godot` 中 `config_version=4`（Godot 4 格式）。系统未安装 Godot。项目处于无法在任何版本运行的状态。

**决策**: 迁移到 Godot 4.3+。

**依据**:
- Godot 3.x 已于 2024 年停止维护，不再接收 bug 修复
- Godot 4 的 AssetLibrary、文档、社区资源远超 3.x
- 迁移工作量: 29 个脚本，约 2-3 轮对话可完成
- `project.godot` 已是 Godot 4 格式 → 说明原开发者**意图**是 Godot 4，只是脚本未跟进

**已考虑但拒绝的替代方案**:
- 回退到 Godot 3.5.2: 更简单（改 config_version=3 即可），但长期成本高（无维护、社区萎缩）
- 等待用户确认: 用户明确说"你来决策"，且本项目目标就是迭代到可上线

**权衡**:
- 短期: 迁移需要 2-3 轮对话，期间不能测试
- 长期: 获得更好的 API、物理引擎(Jolt)、渲染管线

## 2026-08-09: 关卡架构问题

**问题**: `GameManager.load_level()` 使用 `get_tree().change_scene()` 切换场景，但 level_2~5.tscn 缺少 Player/HUD/Menu 节点。

**根因**: 原开发者可能只通过 Godot 编辑器直接打开子场景测试，未经过菜单 → 关卡切换流程。

**待解决**: 迁移完成后重构关卡加载机制。候选方案:
- A) 每个关卡场景自包含 Player + UI（冗余但简单）
- B) Player/UI 作为 autoload 或独立场景叠加（避免重复但架构变复杂）

