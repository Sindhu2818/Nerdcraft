---
name: new-entity
description: Scaffold a new gameplay entity (enemy, companion, or obstacle) following project architecture
---

# New Entity Generator

Creates a standard gameplay entity conforming to the architecture and conventions of *The Light Hero: Light of the Last Page*.

## Architectural Standards

When implementing a new entity (e.g. enemy, hazard, or interactive element):

1. **Collision Layers & Masks**:
   - Layer 1: World / Environment geometry
   - Layer 2: Player & Hero Party
   - Layer 3: Enemies (Lurkers, Brutes, Bosses)
   - Layer 4: Player Projectiles & Attack Hitboxes
   - Layer 5: Enemy Projectiles & Hazard Hitboxes
   - Layer 6: Collectibles / Triggers / Void Beacons

2. **GDScript 2.0 Conventions**:
   - Strict static typing on all variable definitions, parameters, and return types (`var hp: int = 50`, `func take_damage(amount: int) -> void:`).
   - Use `class_name` where appropriate.
   - Cache node references with `@onready var sprite: Sprite2D = $Sprite2D`.
   - Avoid `print()` in hot loops; rely on signals for decoupled communication.

3. **Audio & Combat Effects**:
   - Trigger procedural audio via global autoload `AudioManager.play_sfx(name)`.
   - Spawn comic onomatopoeia popups on impact/destruction (e.g. `"CRACK!"`, `"BOOM!"`, `"SHATTER!"`).
   - Clean up nodes with `queue_free()` and disconnect or clean up dynamic tweens.

4. **Verification**:
   - Validate project syntax after generating the entity:
     ```bash
     godot --headless --path . --quit
     ```
