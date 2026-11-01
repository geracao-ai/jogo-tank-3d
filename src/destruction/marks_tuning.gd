class_name MarksTuning
extends Resource
## Tuning for permanent marks: shell craters and smoke columns.
## Implements: design/game-brief.md, MVP feature 6 (story-006-marcas-permanentes).
## Edit the .tres, not the code.

## Most craters alive at once. Past this, the oldest crater node is reused for the newest impact.
@export_range(1, 500) var crater_cap: int = 60
## Smallest crater radius, metres.
@export_range(0.1, 10.0, 0.05) var crater_radius_min: float = 0.8
## Largest crater radius, metres.
@export_range(0.1, 10.0, 0.05) var crater_radius_max: float = 1.4
## Height of the disc above the hit point, metres. Must stay above the street strips of the
## city (street_y 0.03) so craters on streets are not hidden.
@export_range(0.0, 1.0, 0.005) var crater_y_offset: float = 0.06
## Crater colour.
@export var crater_color: Color = Color(0.12, 0.1, 0.09, 1)
## Smallest Y component of the hit normal that still counts as ground (1 = flat floor only).
@export_range(0.0, 1.0, 0.01) var crater_min_normal_y: float = 0.7

## Smoke particles for a DAMAGED object.
@export_range(1, 100) var smoke_amount_damaged: int = 16
## Smoke particles for a DESTROYED object (usually weaker).
@export_range(1, 100) var smoke_amount_destroyed: int = 8
## Seconds a smoke puff lives.
@export_range(0.5, 20.0, 0.1) var smoke_lifetime: float = 4.0
## Rise speed range of a puff, metres per second.
@export var smoke_velocity_min: float = 0.8
@export var smoke_velocity_max: float = 1.4
## Puff diameter as a fraction of the object's smaller footprint side.
@export_range(0.01, 2.0, 0.01) var smoke_size_ratio: float = 0.3
## Smallest puff diameter, metres (for thin objects such as lamp posts).
@export_range(0.1, 5.0, 0.05) var smoke_size_min: float = 0.6
## Emission area as a fraction of the object's footprint.
@export_range(0.0, 1.0, 0.01) var smoke_footprint_ratio: float = 0.6
## Height of the smoke source above the top of what is left of the object (metres).
@export_range(0.0, 20.0, 0.1) var smoke_start_height: float = 1.0
## Smoke colour; alpha is the peak opacity (it fades to 0 over the puff's life).
@export var smoke_color: Color = Color(0.6, 0.6, 0.62, 0.55)
