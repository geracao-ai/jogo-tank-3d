class_name TankTuning
extends Resource
## Tuning values for the drivable tank.
## Implements: design/game-brief.md, build order 1 (tank that is good to drive).
## Edit the .tres, not the code.

## Forward acceleration while the throttle is held (m/s^2).
@export var acceleration: float = 6.0
## Maximum forward speed (m/s).
@export var max_forward_speed: float = 14.0
## Maximum reverse speed (m/s, positive number).
@export var max_reverse_speed: float = 5.0
## Deceleration while the brake is held, or while throttle opposes motion (m/s^2).
@export var brake_deceleration: float = 16.0
## Deceleration from drag when no throttle is held (m/s^2).
@export var coast_deceleration: float = 4.0
## Turn rate when nearly stopped (degrees/s).
@export var turn_rate_standstill: float = 70.0
## Turn rate at max speed (degrees/s). Lower than standstill = heavier at speed.
@export var turn_rate_full_speed: float = 30.0
## How quickly the actual turn rate follows steering input (1/s). Lower = heavier.
@export var turn_response: float = 5.0
