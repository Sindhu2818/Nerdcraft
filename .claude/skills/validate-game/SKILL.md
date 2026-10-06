---
name: validate-game
description: Run headless Godot 4 project compilation, autoload check, and smoke validation
---

# Validate Game (Headless Godot 4)

Executes headless engine compilation and validation to ensure all GDScript files, scenes, and autoloads compile cleanly without syntax errors, missing singletons, or broken dependencies.

## Workflow

1. Run headless engine verification:
   ```bash
   godot --headless --path . --quit
   ```
2. Interpret the output:
   - **Exit code 0**: Project compiled and initialized cleanly.
   - **SCRIPT ERROR / Compile Error**: Identify the file and line number where the compilation error occurred.
   - **Resource loader / scene errors**: Identify missing or broken sub-resources.
3. If errors are found, fix the offending GDScript file or scene, then re-run validation.
