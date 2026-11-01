class_name AudioTuning
extends Resource
## Tuning for sound (file paths, volumes) and the on-screen mute button.
## Implements: design/game-brief.md, MVP feature 7 (story-007-visual-ghibli-e-som).
## To replace a sound, drop a WAV/OGG over the file or change its path here. Edit the .tres.

## Master volume, 0 (silent) to 1 (full). Applied to the Master bus.
@export_range(0.0, 1.0, 0.01) var master_volume: float = 0.8
## Looping ambient (sea and cicadas).
@export_file("*.wav", "*.ogg") var ambient_path: String = "res://assets/audio/ambient_sea_cicadas.wav"
## Dry, loud cannon shot.
@export_file("*.wav", "*.ogg") var shot_path: String = "res://assets/audio/cannon_shot.wav"
## Shell explosion.
@export_file("*.wav", "*.ogg") var explosion_path: String = "res://assets/audio/explosion.wav"
## Looping tank engine rumble.
@export_file("*.wav", "*.ogg") var engine_path: String = "res://assets/audio/tank_engine.wav"
## Per-sound volume trims in dB (0 = as recorded). The ambient sits low so the shot cuts through.
@export_range(-60.0, 12.0, 0.5) var ambient_db: float = -12.0
@export_range(-60.0, 12.0, 0.5) var shot_db: float = 0.0
@export_range(-60.0, 12.0, 0.5) var explosion_db: float = -2.0
## Engine volume in dB when idle and at top speed.
@export_range(-60.0, 12.0, 0.5) var engine_idle_db: float = -16.0
@export_range(-60.0, 12.0, 0.5) var engine_full_db: float = -7.0
## Engine playback pitch when idle and at top speed (1 = as recorded).
@export_range(0.25, 4.0, 0.05) var engine_idle_pitch: float = 0.8
@export_range(0.25, 4.0, 0.05) var engine_full_pitch: float = 1.8
## How fast the engine follows the tank's speed (higher is snappier).
@export_range(0.5, 30.0, 0.5) var engine_response: float = 5.0
## Simultaneous one-shot voices (shots plus explosions). Past this the oldest voice is cut.
@export_range(1, 16) var one_shot_voices: int = 6

## Mute button side, as a fraction of the viewport height.
@export_range(0.03, 0.3, 0.005) var mute_button_size: float = 0.14
## Distance of the mute button from the top-right corner (fraction of viewport height).
@export_range(0.0, 0.2, 0.005) var mute_button_margin: float = 0.03
## Mute button background disc.
@export var mute_button_background: Color = Color(1, 1, 1, 0.3)
## Speaker icon colour when sound is on, and when muted.
@export var mute_icon_color: Color = Color(0.25, 0.3, 0.4, 0.9)
@export var mute_icon_muted_color: Color = Color(0.7, 0.35, 0.33, 0.95)
