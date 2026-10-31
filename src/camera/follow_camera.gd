class_name FollowCamera
extends Camera3D
## Third-person follow camera: sits behind and above the target, looks slightly ahead of it.
## Implements: design/game-brief.md, MVP feature 2 (story-002-camera-terceira-pessoa).
## Follows the target's HEADING, not its velocity, so reversing does not swing the camera:
## the tank backs up toward the camera and the view keeps facing the same way.
## Ground: camera Y is clamped to tuning.min_camera_y (above the flat ground by construction).
## Building collision is story 005; cannon aim is story 003.

## Node to follow (the Tank).
@export var target: Node3D
## Tuning resource (see follow_camera_tuning.gd / follow_camera_tuning.tres).
@export var tuning: FollowCameraTuning

var _yaw: float = 0.0 # smoothed heading of the camera, radians


func _ready() -> void:
	top_level = true # ignore parent transform; we place ourselves in world space
	_yaw = target.global_rotation.y
	global_position = _desired_position()
	_aim()


# Physics tick, same as the tank, so the target never moves between camera updates.
func _physics_process(delta: float) -> void:
	_yaw = lerp_angle(_yaw, target.global_rotation.y, 1.0 - exp(-tuning.rotation_smoothing * delta))
	global_position = global_position.lerp(_desired_position(), 1.0 - exp(-tuning.position_smoothing * delta))
	global_position.y = maxf(global_position.y, tuning.min_camera_y)
	_aim()


## World position behind and above the target for the current smoothed yaw.
func _desired_position() -> Vector3:
	var back: Vector3 = Vector3(sin(_yaw), 0.0, cos(_yaw)) # +Z rotated by yaw = behind
	var pos: Vector3 = target.global_position + back * tuning.distance
	pos.y = target.global_position.y + tuning.height
	pos.y = maxf(pos.y, tuning.min_camera_y)
	return pos


func _aim() -> void:
	var ahead: Vector3 = Vector3(-sin(_yaw), 0.0, -cos(_yaw))
	var point: Vector3 = target.global_position + ahead * tuning.look_ahead + Vector3.UP * tuning.look_height
	look_at(point, Vector3.UP)
