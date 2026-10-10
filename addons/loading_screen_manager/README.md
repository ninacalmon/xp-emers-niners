# Loading Screen Manager

A drop-in Godot 4 addon for changing scenes with a threaded (background)
load and an animated loading screen.

## Install

1. Copy the `addons/loading_screen_manager` folder into your project's
   `addons/` folder.
2. In Godot: **Project → Project Settings → Plugins** → enable
   **Loading Screen Manager**.
3. This automatically adds `LoadingManager` as an autoload singleton —
   you don't need to add it yourself.

## Usage

From any script, anywhere in your project:

```gdscript
LoadingManager.load_scene("res://levels/level_2.tscn")
```

That's it. It will:
1. Show the loading screen (fades in).
2. Load the target scene in a background thread.
3. Swap to the new scene once loading is done and the minimum
   display time (`min_load_time`, default 1 second) has elapsed.
4. Fade the loading screen back out and remove it.

### Signals

```gdscript
LoadingManager.loading_started.connect(func(path): print("started: ", path))
LoadingManager.loading_finished.connect(func(path): print("finished: ", path))
LoadingManager.loading_failed.connect(func(path): print("failed: ", path))
```

### Customizing

- `LoadingManager.min_load_time` — minimum seconds the screen stays up.
- `loading_screen.tscn` — edit freely: swap the background, fonts, add
  a logo/spinner, tweak the `fade_in`/`fade_out` animations. As long as
  the exported node paths on the root (`progress_bar`, `status_text`,
  `percent_text`, `anim`, `done_sound`) stay wired up in the Inspector,
  `loading_screen.gd` doesn't need to change.
- `done_sound` on the loading screen root is optional — assign an
  `AudioStream` to the `AudioStreamPlayer` node if you want a sound to
  play at 100%. It's unset by default so the addon has no required
  external assets.

## Files

```
addons/loading_screen_manager/
  plugin.cfg          addon metadata
  plugin.gd            registers LoadingManager as an autoload
  loading_manager.gd    the LoadingManager singleton (load logic)
  loading_screen.gd     controls the loading screen UI
  loading_screen.tscn   the loading screen scene
```
