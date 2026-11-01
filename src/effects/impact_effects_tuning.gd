class_name ImpactEffectsTuning
extends Resource
## Tuning for the shell-impact explosion effect (flash plus a few smoke puffs).
## Implements: design/game-brief.md, MVP feature 7 (story-007-visual-ghibli-e-som).
## Edit the .tres, not the code.

## Explosions that can be on screen at once. When all are busy, the oldest is restarted.
@export_range(1, 20) var pool_size: int = 6
## Lift of the effect along the hit normal, metres (keeps it out of the surface).
@export_range(0.0, 3.0, 0.05) var surface_offset: float = 0.4

## Seconds the flash lasts.
@export_range(0.02, 1.0, 0.01) var flash_duration: float = 0.18
## Flash diameter at its peak, metres.
@export_range(0.5, 20.0, 0.1) var flash_size: float = 5.0
## Fraction of the flash duration at which it is largest (it then shrinks to nothing).
@export_range(0.05, 0.95, 0.05) var flash_peak_time: float = 0.3
## Flash colour (soft, warm).
@export var flash_color: Color = Color(1.0, 0.92, 0.7, 1.0)

## Smoke puffs per explosion.
@export_range(1, 20) var puff_count: int = 6
## Seconds a puff lives.
@export_range(0.1, 5.0, 0.05) var puff_lifetime: float = 0.9
## Puff diameter range, metres.
@export var puff_size_min: float = 1.6
@export var puff_size_max: float = 2.6
## Outward speed range, metres per second.
@export var puff_speed_min: float = 2.0
@export var puff_speed_max: float = 4.5
## Upward drift of the puffs, metres per second squared.
@export var puff_rise: float = 1.5
## Puff colour at birth; it fades to transparent over the puff's life.
@export var puff_color: Color = Color(0.95, 0.88, 0.8, 0.85)
