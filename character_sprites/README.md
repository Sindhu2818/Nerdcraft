# Character sprite concepts

Transparent PNGs extracted from `initial_animations.png` and arranged into fixed cells.

- Each character spritesheet is 1536 × 256 px: six 256 × 256 cells in one horizontal row.
- Individual PNGs are also 256 × 256 px with transparent backgrounds.
- Cells use nearest-neighbor pixel scaling and share a fixed canvas for straightforward slicing.

## Frame order

| Character | Frames, left to right |
| --- | --- |
| Alex | idle, walk_1, walk_2, walk_3, jump, cast |
| Athena | idle, walk_1, walk_2, walk_3, jump, cast |
| Kiri | idle, hover_up, hover_down, dart, gust, spin |

These are concept sprites extracted from a generated reference sheet. Check frame alignment and refine silhouette details before using them in a shipped build; the final cast, animation timing, and exact game resolution are project decisions.
