# The Light Hero: Light of the Last Page

A polished 2D indie pixel-art action-platformer built in **Godot 4** (`GL Compatibility` mode, itch.io web export ready), featuring a **Tri-Hero Party System**, dynamic 2D lighting, comic onomatopoeia popups, void beacon wave-defense spawners, and multi-stage boss combat.

---

## 🌟 Game Overview & Lore

When the Void descended upon the kingdom, ancient **Void Beacons** were driven into the earth, draining reality of its color and casting the world into perpetual gloom. From the corrupted shadows emerged relentless Void Beasts led by the **Demon King Avatar**.

Three champions answer the call to restore the light before the last page of history fades forever:
1. **Alex (The Light Hero)**: Wielder of radiant energy. Specializes in piercing light blasts and emergency **Radiant Healing** to sustain the party.
2. **Athena (The Fire Wielder)**: Master of sacred pyromancy. Unleashes high-damage fiery blasts and a devastating **Flame Dash Nova** that bursts through enemy formations.
3. **Kiri (The Wind Spirit)**: Guardian of the zephyrs. Possesses high agility, double jump, slow falling glide, and a **Cyclone Launch** skill that knocks back surrounding void fiends.

---

## 🎮 Gameplay Features

### 1. Tri-Hero Party Mechanics
* **Seamless Hero Swapping**: Switch between Alex, Athena, and Kiri anytime with `[Tab]`, `[Q]`, or keys `[1]`, `[2]`, `[3]`. Position and momentum transfer instantaneously.
* **Companion / Familiar AI**: Uncontrolled party members trail behind the active leader, illuminate dark zones with their personal light auras, jump over obstacles, and automatically target and fire at nearby monsters.
* **Shared Health & Dynamic Energy**: The party shares a health reserve. Each hero possesses a unique primary attack and a specialized high-impact elemental skill.

### 2. Void Stones & Wave-Defense Spawners
* **Corrupted Beacons**: Each stage features heavy-HP Void Stones that pulse with dark energy and periodically spawn waves of **Void Lurkers** and armored **Void Brutes**.
* **Dynamic Lighting Restoration**: Stages begin steeped in pitch darkness (`CanvasModulate`). Shattering each Void Stone triggers an intense screen shake, a comic "SHATTER!" burst, and permanently restores daylight to the realm.

### 3. Comic Book Presentation
* **Story Prologue Cutscene**: An episodic introductory comic sequence introducing the fall of the kingdom and the rise of the champions before Stage 1.
* **Dynamic Onomatopoeia Popups**: Kinetic popups (`"SHATTER!"`, `"BOOM!"`, `"WHOOSH!"`, `"CRACK!"`, `"LIGHT!"`) celebrate critical hits, skill activations, and stone destruction.

### 4. Three Distinct Stages
* **Stage 1: The Arrival / Ruins**: Introductory stage with 2 Void Stones, ruined stone architecture, and Void Lurker waves.
* **Stage 2: Deep Shadow Chasm**: Platforming gauntlet with moving platforms, bottomless chasm death zones with checkpoint recovery, 3 Void Stones, and tanky Void Brutes.
* **Stage 3: The Void Core Chamber**: Boss arena containing the central 180-HP Void Core and the **Demon King Avatar** featuring 3-way dark energy barrages, shadow teleportation, and minion summoning.

---

## 🕹️ Controls

| Action | Primary Key | Secondary Key | Controller / Mouse |
|---|---|---|---|
| **Move Left / Right** | `A` / `D` | `←` / `→` | Left Stick / D-Pad |
| **Jump** | `W` / `Space` | `↑` | Button A |
| **Attack (Primary)** | `J` | `Z` | Left Mouse Button |
| **Special Skill** | `K` | `X` | Right Mouse Button |
| **Dash (Athena)** | `L` | `C` | Shift |
| **Next Hero** | `Tab` / `E` | — | Right Bumper |
| **Previous Hero** | `Q` | — | Left Bumper |
| **Direct Hero Pick** | `1` (Alex) | `2` (Athena) | `3` (Kiri) |

---

## 🛠️ Technical Specifications

* **Engine**: Godot 4.7.2
* **Renderer**: `gl_compatibility` (GL Compatibility mode ensures zero WebGL2 issues when published to itch.io).
* **Pixel Resolution**: 640x360 retro resolution with `canvas_items` stretch mode and `default_texture_filter=0` (nearest-neighbor) for razor-sharp pixel rendering at any display resolution.
* **Audio**: Custom synthesized 8-bit sound effects (sfx_light_blast, sfx_flame_burst, sfx_wind_dash, sfx_shatter, sfx_jump, sfx_switch, sfx_victory) and looping adventure BGM.

---

## 🚀 How to Run & Play

### Run in Godot Editor
```bash
godot --path .
```

### Launch Headless Playtest
```bash
godot --headless --path . "scenes/levels/level1.tscn"
```

### Export for Web (itch.io)
1. Open the Godot Editor.
2. Select **Project -> Export...**.
3. Select the pre-configured **Web** preset (defined in `export_presets.cfg`).
4. Click **Export Project** to compile to `build/web/index.html`.
5. Zip the contents of `build/web/` and upload directly to itch.io with "This file will be played in the browser" enabled!
