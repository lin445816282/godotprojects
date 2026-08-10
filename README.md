# CoinQuest - 3D Platformer Game

Built with Godot 4.7 + GDScript. 5 levels, procedurally generated assets, full audio, achievements.

## Current State (审计30轮后)

### Core
- WASD + mouse orbit camera, double-jump, controller support
- 5 levels: Grassland → Floating Isles → Castle → Frozen → Boss Arena
- AI enemies: Patrol/Chase/Return, Jumper, Thrower, Boss (3-phase bullet hell)
- Coins with 12s respawn mechanism
- Powerups: Shield, Speed Boost, Magnet
- Keys + Gates, Teleporters, Moving Platforms, Spinners
- Health bar UI (3 hits), death particles, hit knockback

### Systems
- GameManager: countdown, win/lose, pause, level switching with loading screen
- LevelManager: unlock progression, best-score persist
- AudioManager: procedural BGM + SFX with pooling
- SettingsManager: volume, sensitivity, key rebinding with value sync
- Achievements: 5 types (first_win, three_wins, sprinter, no_hit, collector)
- HUD: coin count, timer, health bars, damage flash
- i18n: 51 keys, Chinese/English full coverage

### Visual
- Per-level environment tuning (colors, fog, ambient)
- Player body animation (arm/leg swing, jump pose)
- Dust particles on movement, death explosion
- Procedural skybox, checkerboard ground textures

## Running

Open in Godot 4 editor: `godot --path .`
Or run: `godot`

## Credit

Built with Codex + Godot 4.
