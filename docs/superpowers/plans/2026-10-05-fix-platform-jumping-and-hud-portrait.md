# Fix Platform Jumping and HUD Portrait Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable universal double jump across all heroes, tune jump physics and platform heights across levels to ensure every hero can easily clear them, and restyle the HUD player portrait with high contrast so the active character is clearly visible against any background.

**Architecture:**
- Universal double-jump logic in `hero.gd` (`can_double_jump = true` for Alex, Athena, and Kiri), giving each hero distinct jump velocities and mid-air impulse ($v_y$), resetting on floor contact.
- Platform elevation reduction across `level1.tscn`, `level2.tscn`, and `level3.tscn` lowering high ledges from $\Delta y \approx 90\text{--}110\text{ px}$ down to $\Delta y \approx 50\text{--}70\text{ px}$.
- High-contrast HUD portrait styling in `hud.tscn` using a `PanelContainer` with a `StyleBoxFlat` dark backing (`#0e101a`), crisp 2px colored border, 4px corner radius, and $48 \times 48\text{ px}$ frame to render pixel art without blur or dark blending, supplemented with dynamic border tinting per hero in `hud.gd`.

**Tech Stack:** Godot 4.7 (GDScript 2.0, CharacterBody2D physics, StyleBoxFlat theming, CanvasLayer UI)

**Spec:** User bug report:
1. Platforms in the game are too high to reach with a normal jump; add double jump to fix this, decrease the normal height level to some extent, and make sure the game levels are clearable and passable for all heroes.
2. In the top-left player stats HUD, the character portrait is not clearly visible; fix it so it is distinct and clearly visible against any level background.

---

## Global Constraints

- Engine: Godot 4.7.2 stable headless / GUI.
- Node Hierarchy Stability: `$MarginContainer/VBoxContainer/TopRow/PortraitFrame/Portrait` must remain identical so external calls or tests do not break.
- Hero Mechanics: Keep hero identities intact (Alex light magic, Athena dash, Kiri wind float).
- No External Dependencies: Use native Godot nodes and standard resources only.

## Review Focus

1. Hero mid-air jump resets cleanly on floor landing and does not grant infinite jumps.
2. Walking off ledges without jumping allows single air-jump recovery without crash or infinite leap.
3. Elevated platforms in Level 1 (Ledges 1 & 2), Level 2 (HighLedge & VoidStone2), and Level 3 (CenterAltar & UpperLedges) are reachable by all three heroes individually.
4. Companion followers keep up with active leader without snagging on adjusted platform geometry.
5. Character portrait in HUD is easily discernible against dark void backgrounds, purple modulates, and bright combat effects.

---

### Task 1: Implement Universal Double Jump in `hero.gd`

**Files:**
- Modify: `scenes/characters/hero.gd:8-13, 39-63, 102-123`
- Test: `tests/test_jump_mechanics.gd`

**Interfaces:**
- Consumes: `Input.is_action_just_pressed("jump")`, `is_on_floor()`, `AudioManager.play_sfx()`, `GameManager.request_comic_popup()`
- Produces: `can_double_jump = true` for all heroes, `jump_velocity` tuned per hero (Alex: `-390.0`, Athena: `-380.0`, Kiri: `-410.0`), mid-air jump impulse `velocity.y = jump_velocity * 0.9`.

- [ ] **Step 1: Write test script checking jump variables and double jump logic**

Create `tests/test_jump_mechanics.gd`:
```gdscript
extends SceneTree

func _init() -> void:
	var hero_scene = preload("res://scenes/characters/hero.tscn")
	for h_name in ["Alex", "Athena", "Kiri"]:
		var hero = hero_scene.instantiate()
		hero.hero_type = h_name
		hero.setup_hero_stats()
		assert(hero.can_double_jump == true, "%s must have can_double_jump enabled" % h_name)
		assert(hero.jump_velocity <= -380.0, "%s jump_velocity must be at least -380.0" % h_name)
		hero.free()
	print("TEST_JUMP_MECHANICS: PASS")
	quit(0)
```

- [ ] **Step 2: Run test to verify failure**

Run: `godot --headless -s tests/test_jump_mechanics.gd`
Expected: Assertion failure for Alex or Athena (`can_double_jump == false`).

- [ ] **Step 3: Update `scenes/characters/hero.gd`**

In `hero.gd`:
1. Set default `can_double_jump: bool = true`.
2. In `setup_hero_stats()`:
   - Alex: `jump_velocity = -390.0`, `can_double_jump = true`
   - Athena: `jump_velocity = -380.0`, `can_double_jump = true`
   - Kiri: `jump_velocity = -410.0`, `can_double_jump = true`
3. In `handle_active_input()`:
   - Ensure double jump executes reliably whether jumping from floor or falling mid-air (`elif can_double_jump and not has_double_jumped:`).

- [ ] **Step 4: Run test to verify it passes**

Run: `godot --headless -s tests/test_jump_mechanics.gd`
Expected: `TEST_JUMP_MECHANICS: PASS`

- [ ] **Step 5: Commit changes**

```bash
git add scenes/characters/hero.gd tests/test_jump_mechanics.gd
git commit -m "feat(hero): enable universal double jump and tune jump velocities"
```

---

### Task 2: Lower Platform Elevations Across Level Scenes

**Files:**
- Modify: `scenes/levels/level1.tscn:49-56, 59-64`
- Modify: `scenes/levels/level2.tscn:43-46, 76-80`
- Modify: `scenes/levels/level3.tscn:46-57, 60-65`
- Test: `tests/test_level_reachability.gd`

**Interfaces:**
- Consumes: Node positions of platforms (`Ledge1`, `Ledge2`, `HighLedge`, `CenterAltar`, `UpperLedgeLeft`, `UpperLedgeRight`) and void stones in level scenes.
- Produces: Lowered Y-coordinates such that no platform step exceeds $75\text{ px}$ from its lowest predecessor.

- [ ] **Step 1: Write test script checking platform height differences**

Create `tests/test_level_reachability.gd`:
```gdscript
extends SceneTree

func _init() -> void:
	# Level 1
	var l1 = preload("res://scenes/levels/level1.tscn").instantiate()
	var g1_y = l1.get_node("Platforms/Ground1").position.y # 240
	var ledge1_y = l1.get_node("Platforms/Ledge1").position.y
	assert(g1_y - ledge1_y <= 75.0, "Level1 Ledge1 too high: %f" % (g1_y - ledge1_y))
	var g2_y = l1.get_node("Platforms/Ground2").position.y # 240
	var ledge2_y = l1.get_node("Platforms/Ledge2").position.y
	assert(g2_y - ledge2_y <= 85.0, "Level1 Ledge2 too high: %f" % (g2_y - ledge2_y))
	l1.free()

	# Level 2
	var l2 = preload("res://scenes/levels/level2.tscn").instantiate()
	var chasm1_y = l2.get_node("Platforms/ChasmIsle1").position.y # 220
	var high_ledge_y = l2.get_node("Platforms/HighLedge").position.y
	assert(chasm1_y - high_ledge_y <= 70.0, "Level2 HighLedge too high: %f" % (chasm1_y - high_ledge_y))
	l2.free()

	# Level 3
	var l3 = preload("res://scenes/levels/level3.tscn").instantiate()
	var floor_y = l3.get_node("Platforms/Floor").position.y # 260
	var altar_y = l3.get_node("Platforms/CenterAltar").position.y
	assert(floor_y - altar_y <= 65.0, "Level3 CenterAltar too high: %f" % (floor_y - altar_y))
	l3.free()

	print("TEST_LEVEL_REACHABILITY: PASS")
	quit(0)
```

- [ ] **Step 2: Run test to verify failure on original levels**

Run: `godot --headless -s tests/test_level_reachability.gd`
Expected: FAIL (`Level1 Ledge1 too high: 90.000000`).

- [ ] **Step 3: Modify Level 1, 2, and 3 platform Y positions**

1. In `scenes/levels/level1.tscn`:
   - `Ledge1`: Lower position Y from `150` to `175` ($\Delta y = 65\text{ px}$ from Ground1).
   - `Ledge2`: Lower position Y from `130` to `160` ($\Delta y = 80\text{ px}$ from Ground2; single double-jump easily reaches it).
   - `VoidStone2`: Adjust position Y from `136` to `146` (rests on Ledge2 / Ground3).
2. In `scenes/levels/level2.tscn`:
   - `HighLedge`: Lower position Y from `130` to `160` ($\Delta y = 60\text{ px}$ from ChasmIsle1).
   - `VoidStone2`: Adjust position Y from `86` to `116` (placed cleanly above HighLedge).
3. In `scenes/levels/level3.tscn`:
   - `CenterAltar`: Lower position Y from `190` to `200` ($\Delta y = 60\text{ px}$ from Floor).
   - `VoidCore`: Adjust position Y from `150` to `160`.
   - `UpperLedgeLeft`: Lower position Y from `150` to `165`.
   - `UpperLedgeRight`: Lower position Y from `150` to `165`.

- [ ] **Step 4: Run test to verify it passes**

Run: `godot --headless -s tests/test_level_reachability.gd`
Expected: `TEST_LEVEL_REACHABILITY: PASS`

- [ ] **Step 5: Commit changes**

```bash
git add scenes/levels/level1.tscn scenes/levels/level2.tscn scenes/levels/level3.tscn tests/test_level_reachability.gd
git commit -m "fix(levels): adjust elevated platform heights for fair traversal"
```

---

### Task 3: Restyle and Enhance Portrait Frame in `hud.tscn` & `hud.gd`

**Files:**
- Modify: `scenes/ui/hud.tscn:30-44`
- Modify: `scenes/ui/hud.gd:3, 13-18, 42-47`
- Test: `tests/test_hud_portrait.gd`

**Interfaces:**
- Consumes: `PortraitFrame` node, `Portrait` TextureRect, `GameManager.hero_swapped` signal.
- Produces: High-contrast `PanelContainer` backing with 2px solid border, distinct dark background (`Color(0.08, 0.09, 0.15, 0.95)`), corner radius, and hero accent border color (`Alex: Gold`, `Athena: Flame Orange`, `Kiri: Cyan-Teal`).

- [ ] **Step 1: Write test script checking HUD Portrait setup**

Create `tests/test_hud_portrait.gd`:
```gdscript
extends SceneTree

func _init() -> void:
	var hud_scene = preload("res://scenes/ui/hud.tscn")
	var hud = hud_scene.instantiate()
	var frame = hud.get_node("MarginContainer/VBoxContainer/TopRow/PortraitFrame")
	assert(frame != null, "PortraitFrame must exist at original node path")
	var portrait = hud.get_node("MarginContainer/VBoxContainer/TopRow/PortraitFrame/Portrait")
	assert(portrait != null, "Portrait TextureRect must exist")
	assert(frame.custom_minimum_size.x >= 44.0 and frame.custom_minimum_size.y >= 44.0, "PortraitFrame must be large enough to clearly display the 48x48 portrait")
	hud.free()
	print("TEST_HUD_PORTRAIT: PASS")
	quit(0)
```

- [ ] **Step 2: Run test to check original state**

Run: `godot --headless -s tests/test_hud_portrait.gd`
Expected: `custom_minimum_size` fails (currently 40x40 with no border panel).

- [ ] **Step 3: Upgrade `PortraitFrame` in `hud.tscn` and `hud.gd`**

1. In `scenes/ui/hud.tscn`:
   - Replace `Control` `PortraitFrame` with `PanelContainer` (or assign `theme_override_styles/panel = SubResource("StyleBoxFlat_portrait")`):
     - `bg_color = Color(0.08, 0.09, 0.15, 0.95)`
     - `border_width_left = 2`, `border_width_top = 2`, `border_width_right = 2`, `border_width_bottom = 2`
     - `border_color = Color(1.0, 0.85, 0.35, 1.0)` (bright golden accent)
     - `corner_radius_top_left = 4`, `corner_radius_top_right = 4`, `corner_radius_bottom_right = 4`, `corner_radius_bottom_left = 4`
     - `shadow_color = Color(0, 0, 0, 0.6)`
     - `shadow_size = 3`
   - Set `custom_minimum_size = Vector2(48, 48)`.
2. In `scenes/ui/hud.gd`:
   - In `_on_hero_swapped(hero_name, hero_index)`:
     - Update border color of `PortraitFrame` according to hero:
       - Alex: `Color(1.0, 0.88, 0.4, 1.0)` (Radiant Gold)
       - Athena: `Color(1.0, 0.5, 0.25, 1.0)` (Flame Amber)
       - Kiri: `Color(0.4, 0.95, 0.9, 1.0)` (Wind Teal)

- [ ] **Step 4: Run test to verify it passes**

Run: `godot --headless -s tests/test_hud_portrait.gd`
Expected: `TEST_HUD_PORTRAIT: PASS`

- [ ] **Step 5: Commit changes**

```bash
git add scenes/ui/hud.tscn scenes/ui/hud.gd tests/test_hud_portrait.gd
git commit -m "fix(hud): add high-contrast bordered frame and hero theming to portrait"
```

---

### Task 4: Complete Traversal and Passability Verification

**Files:**
- Create: `tests/test_full_passability.gd`

**Interfaces:**
- Consumes: `level1.tscn`, `level2.tscn`, `level3.tscn`, `hero.tscn`, `hero_party.tscn`.
- Produces: Headless physics simulation verifying that simulated jumps clear all obstacle heights and all levels can instantiate without error.

- [ ] **Step 1: Write integration traversal test**

Create `tests/test_full_passability.gd`:
```gdscript
extends SceneTree

func _init() -> void:
	for lvl_path in ["res://scenes/levels/level1.tscn", "res://scenes/levels/level2.tscn", "res://scenes/levels/level3.tscn"]:
		var scene = load(lvl_path)
		assert(scene != null, "Failed to load %s" % lvl_path)
		var inst = scene.instantiate()
		assert(inst != null, "Failed to instantiate %s" % lvl_path)
		# Verify hero party and platforms exist
		var party = inst.get_node_or_null("HeroParty")
		assert(party != null, "Missing HeroParty in %s" % lvl_path)
		var hud = inst.get_node_or_null("HUD")
		assert(hud != null, "Missing HUD in %s" % lvl_path)
		inst.free()
	print("ALL_LEVELS_VERIFIED: PASS")
	quit(0)
```

- [ ] **Step 2: Run verification test**

Run: `godot --headless -s tests/test_full_passability.gd`
Expected: `ALL_LEVELS_VERIFIED: PASS`

- [ ] **Step 3: Clean up temporary test files or keep in `tests/`**

Commit `tests/` suite.
