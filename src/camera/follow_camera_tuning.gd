class_name FollowCameraTuning
extends Resource
## Tuning values for the third-person follow camera.
## Implements: design/game-brief.md, MVP feature 2 (story-002-camera-terceira-pessoa).
## Edit the .tres, not the code.

## Horizontal distance behind the tank (m).
@export var distance: float = 9.0
## Camera height above the tank origin (m).
@export var height: float = 5.0
## Aim point height above the tank origin (m).
@export var look_height: float = 1.0
## How far ahead of the tank the camera aims along its heading (m). Shows the road ahead.
@export var look_ahead: float = 6.0
## How quickly the camera position catches up with the tank (1/s). Lower = looser.
@export var position_smoothing: float = 6.0
## How quickly the camera swings behind the tank's heading when it turns (1/s). Lower = looser.
@export var rotation_smoothing: float = 3.5
## Lowest world Y the camera may reach, keeps it above the ground plane (m).
@export var min_camera_y: float = 1.0
## Radius of the sphere swept from the tank to the camera; also the gap kept from walls (m).
@export var collision_margin: float = 0.5
## How quickly the camera eases back out after a wall stops blocking it (1/s). Pulling in is immediate.
@export var release_smoothing: float = 2.5
## Physics layers the camera treats as walls.
@export_flags_3d_physics var collision_mask: int = 1
