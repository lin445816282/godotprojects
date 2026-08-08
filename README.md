# CoinQuest - 3D Platformer Game

Built with Godot 4 + GDScript. 5 levels, procedurally generated assets, full audio, achievements.

## What's built

### Core
- WASD + mouse orbit camera, double-jump, controller support
- 5 levels: Grassland → Floating Isles → Castle → Frozen → Boss Arena
- AI enemies: Patrol/Chase/Return state machine, Jumper, Thrower, Boss (3-phase bullet hell)
- Collectibles: Copper/Silver/Gold coins with particle FX
- Powerups: Shield, Speed Boost, Magnet
- Keys + Gates, Teleporters, Moving Platforms, Spinners

### Systems
- GameManager: countdown, win/lose, pause, level switching
- LevelManager: unlock progression, best-score persist
- AudioManager: procedural BGM + SFX (no asset files)
- SettingsManager: volume, sensitivity, key rebinding
- Achievements: 5 achievements with popup notifications
- HUD: coin count, timer, hit flash, level label

### Visual
- Procedural skybox per level theme
- Checkerboard ground textures
- Player body animation (arm/leg swing, jump pose)
- Dust particles on movement
- Hit flash / invuln frames

## Running

Open in Godot 4 editor: `godot --path .`
Or run: `godot`

## Godogen workflow

This project uses [godogen](https://github.com/htdt/godogen) — describe a feature, the agent builds it, generates assets, runs Godot, and proves results.

See `AGENTS.md` and `godot.md` for the runtime guide.

## Credit

Built with Codex + Godot 4. godogen runtime by [@alex_erm](https://x.com/alex_erm).
