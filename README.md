# CoinQuest - 3D Platformer Game

Built with Godot 4 + GDScript. Deployed with Godogen runtime.

## What's built

- 3D platformer with WASD movement + jump
- 5 levels with progression
- Coin/key collectibles and gates
- Enemies (patrol, jumper, thrower variants)
- Moving platforms, teleporters, spinners
- Powerups (shield FX, speed)
- HUD with coin counter and health
- Main menu with settings
- Settings manager (volume, language)
- Achievements system
- i18n (multi-language support)
- Audio manager with BGM/SFX
- Camera orbit

## What's left / ideas

- [ ] Boss fights
- [ ] More powerup types
- [ ] Save/load system
- [ ] Particle effects polish
- [ ] More levels (6+)
- [ ] Mobile touch controls

## Asset table

| Asset | Type | Source |
|-------|------|--------|
| Player model | MeshInstance3D | procedural (capsule) |
| Coins | MeshInstance3D | procedural (cylinder) |
| Keys | MeshInstance3D | procedural |
| Enemies | MeshInstance3D | procedural |
| Platforms | MeshInstance3D | procedural (box) |
| Ground | MeshInstance3D | procedural (plane/box) |

## Running

Open in Godot 4 editor or: `godot --path .`
