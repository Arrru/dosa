# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**괴담 도서관(도사)** — A Godot 4.6 point-and-click + dialogue-choice game (Korean horror/creature visual novel). MVP prototype: player is a new library assistant surviving among strange patrons. Target: browser (web export) and desktop, ages 12–15.

## Running and Exporting

- **Open project**: Launch Godot 4.6, open `/data/dosa_prototype/project.godot`
- **Run in editor**: Press F5 or the Play button (entry point: `project/scenes/bootstrap.tscn`)
- **Web export**: Use `Project > Export... > Web` preset; output goes to `docs/index.html`. All files in `docs/` must be served together.
- No external addons. No build scripts. No test runner.

## Architecture

### Autoload Singletons (the backbone)

All four are registered in `project.godot` and available globally:

| Autoload | File | Role |
|---|---|---|
| `GameState` | `project/autoload/game_state.gd` | All runtime state: player name, day/phase, actions, affection, skills, unlocked IDs, flags |
| `SaveManager` | `project/autoload/save_manager.gd` | Read/write `user://slot_N.json`; 3 slots; web persistence warnings |
| `ContentDB` | `project/autoload/content_db.gd` | All game data: views, hotspots, dialogues, codex/manual entries, theme colors |
| `SceneRouter` | `project/autoload/scene_router.gd` | Scene transitions via `call_deferred("change_scene_to_file", ...)` |

### Scene Flow

```
bootstrap → intro → title_menu → save_slots_menu → name_entry → game_root
```

- `bootstrap.gd`: immediately calls `SceneRouter.to_intro()`
- `intro.gd`: plays `.ogv` video if present; falls back to animated candle; routes to title
- `title_menu.gd`: main menu with overlay panel for records/settings/credits
- `save_slots_menu.gd`: slot selection for new game or continue
- `name_entry.gd`: player name input (confirmed name cannot change)
- `game_root.gd`: main gameplay loop — directional navigation, hotspot clicks, dialogue/choice overlays, collection viewer

### UI Construction Pattern

All UI nodes are **instantiated procedurally in `_build_ui()`** — `.tscn` files are minimal wrappers. Never rely on scene-tree-placed nodes; always reference variables set in `_build_ui()`.

`UIThemeHelper` (`project/scripts/ui_theme_helper.gd`) applies NanumGothic font to any `Control` root. Call `UI_THEME_HELPER.apply_ui_theme(self)` at the top of `_ready()` in each scene script.

### Content Data (ContentDB)

All game content lives as Dictionary constants in `content_db.gd`:

- **`view_data`**: Four views (`north`, `east`, `west`, `south`) — each has title, colors, navigation directions, and a `hotspots` list.
- **`hotspot_data`**: Click targets — each has a label, `Rect2` position, and `dialogue_id`.
- **`dialogue_data`**: Dialogue nodes — each has speaker, portrait path, text, and `choices` array.
- **`codex_entries`** / **`manual_entries`**: Collection items with title, subtitle, source, page_label, body.

To add content, add entries to these dictionaries. No registration elsewhere needed.

### Effects System

Dialogue choices carry an `effects` Dictionary applied via `GameState.apply_effects()`. Supported keys:

```gdscript
{
  "affection": {"catalog_warden": 1},
  "skills": {"research": 1, "empathy": 1, "nerve": 1},
  "unlock_codex": ["entry_id"],
  "unlock_manual": ["entry_id"],
  "flags": {"flag_name": true},
  "goto_view": "east",
  "spend_time": 1   # also advances phase/day
}
```

### Time Loop

`GameState` tracks `phase_index` (0=낮, 1=밤, 2=자유시간) and `actions_remaining` (2 per phase). `spend_actions()` decrements and calls `advance_phase()` when exhausted, which wraps phase and increments `day_number`.

### Save Format

Saves are JSON at `user://slot_N.json`. `GameState.to_dict()` / `load_from_dict()` handle serialization. In web builds, these map to browser storage — warn users of persistence limits via `SaveManager.get_persistence_warning()`.

### Web Considerations

- Rendering is set to `gl_compatibility` for browser compatibility.
- Video intro requires user interaction to start on web (handled in `intro.gd`).
- `quit()` is blocked on web; show a notice instead (handled in `title_menu.gd`).
- Window resize uses fullscreen request only on web.

### Mobile (Android / iOS)

- **Orientation**: locked to landscape via `project.godot` `window/handheld/orientation`.
- **Virtual keyboard** (`name_entry.gd`): `_process` polls `DisplayServer.virtual_keyboard_get_height()` only while `LineEdit` has focus. Height is converted from physical pixels to canvas pixels via `get_viewport().get_final_transform().get_scale().y`, then the panel is shifted up to stay above the keyboard.
- **Touch swipe navigation** (`game_root.gd`): `_unhandled_input` tracks `InputEventScreenTouch`. A release delta ≥ `_SWIPE_THRESHOLD` (60 canvas px) triggers `_change_view()`; shorter deltas pass through as normal taps to underlying Buttons.
- **Touch target sizes**: `UIThemeHelper.is_mobile()` detects `mobile`/`android`/`ios` feature tags. Nav buttons → 88×64, menu bar buttons → 88×52, menu/confirm/back buttons → 64 height minimum on mobile.
- **Persistence warning**: `SaveManager.get_persistence_warning()` now returns a warning for mobile (app data deletion) in addition to web (browser storage).
- **Export presets**: Android (preset.1) and iOS (preset.2) are configured in `export_presets.cfg`. Both require Godot export templates installed. iOS requires Xcode on macOS to produce a signed build; `application/export_project_only=true` produces an Xcode project. Update `package/unique_name` and `application/bundle_identifier` before distributing.
- **`emulate_touch_from_mouse=true`** is set in `project.godot` for editor playtesting of touch flows on desktop.
