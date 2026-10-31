class_name CannonTuning
extends Resource
## Tuning values for the tank cannon and its projectile.
## Implements: design/game-brief.md, MVP feature 4 (story-003-canhao-mira-disparo).
## Edit the .tres, not the code.

## Minimum time between two shots (seconds).
@export var reload_interval: float = 1.2
## Projectile muzzle speed (m/s).
@export var projectile_speed: float = 90.0
## Downward acceleration on the projectile (m/s^2). 0 = flat trajectory.
@export var projectile_gravity: float = 4.0
## Distance a projectile can travel before it ends without an impact (m).
@export var max_range: float = 200.0
## How fast the turret yaws and the barrel pitches (degrees/s).
@export var turn_speed: float = 120.0
## Lowest barrel pitch (degrees, negative = down).
@export var pitch_min: float = -8.0
## Highest barrel pitch (degrees).
@export var pitch_max: float = 30.0
## Length of the camera ray that finds the aim point (m). Beyond this the aim point is a point at this distance.
@export var aim_ray_length: float = 300.0
