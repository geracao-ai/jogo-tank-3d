class_name FollowCamera
extends Camera3D
## Third-person follow camera: sits behind and above the target, looks slightly ahead of it.
## Implements: design/game-brief.md, MVP feature 2 (story-002-camera-terceira-pessoa).
## Follows the target's HEADING, not its velocity, so reversing does not swing the camera:
## the tank backs up toward the camera and the view keeps facing the same way.
## Ground: camera Y is clamped to tuning.min_camera_y (above the flat ground by construction).
## Walls: a sphere is swept from the tank to the desired position; if a body is in the way
## (tank excluded) the camera is pulled in, with tuning.collision_margin to spare. Pulling in is
## immediate, easing back out is smoothed (tuning.release_smoothing), so it does not pop.
## Story 005 (camera does not cross building walls).

## Node to follow (the Tank).
@export var target: Node3D
## Tuning resource (see follow_camera_tuning.gd / follow_camera_tuning.tres).
@export var tuning: FollowCameraTuning

var _yaw: float = 0.0 # smoothed heading of the camera, radians
var _clear_fraction: float = 1.0 # 0..1 share of the tank->desired line that is free of walls
var _sphere: SphereShape3D = SphereShape3D.new()


func _ready() -> void:
	top_level = true # ignore parent transform; we place ourselves in world space
	_yaw = target.global_rotation.y
	global_position = _desired_position()
	_aim()


# Physics tick, same as the tank, so the target never moves between camera updates.
func _physics_process(delta: float) -> void:
	_yaw = lerp_angle(_yaw, target.global_rotation.y, 1.0 - exp(-tuning.rotation_smoothing * delta))
	var origin: Vector3 = _sweep_origin()
	var desired: Vector3 = _desired_position()
	var free: float = _free_fraction(origin, desired)
	if free < _clear_fraction:
		_clear_fraction = free
	else:
		_clear_fraction = lerpf(_clear_fraction, free, 1.0 - exp(-tuning.release_smoothing * delta))
	desired = origin.lerp(desired, _clear_fraction)
	var next: Vector3 = global_position.lerp(desired, 1.0 - exp(-tuning.position_smoothing * delta))
	# The eased path can still cut a corner: never let the final position be behind a wall.
	next = origin.lerp(next, _free_fraction(origin, next))
	global_position = next
	global_position.y = maxf(global_position.y, tuning.min_camera_y)
	_aim()


## World position behind and above the target for the current smoothed yaw.
func _desired_position() -> Vector3:
	var back: Vector3 = Vector3(sin(_yaw), 0.0, cos(_yaw)) # +Z rotated by yaw = behind
	var pos: Vector3 = target.global_position + back * tuning.distance
	pos.y = target.global_position.y + tuning.height
	pos.y = maxf(pos.y, tuning.min_camera_y)
	return pos


## Point on the tank the camera is swept from (aim height).
func _sweep_origin() -> Vector3:
	return target.global_position + Vector3.UP * tuning.look_height


## Fraction (0..1) of the line from -> to that a sphere of collision_margin radius can travel
## before touching a body other than the target.
func _free_fraction(from: Vector3, to: Vector3) -> float:
	_sphere.radius = tuning.collision_margin
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _sphere
	query.transform = Transform3D(Basis.IDENTITY, from)
	query.motion = to - from
	query.collision_mask = tuning.collision_mask
	if target is CollisionObject3D:
		query.exclude = [(target as CollisionObject3D).get_rid()]
	var result: PackedFloat32Array = get_world_3d().direct_space_state.cast_motion(query)
	return result[0] if result.size() > 0 else 1.0


func _aim() -> void:
	var ahead: Vector3 = Vector3(-sin(_yaw), 0.0, -cos(_yaw))
	var point: Vector3 = target.global_position + ahead * tuning.look_ahead + Vector3.UP * tuning.look_height
	look_at(point, Vector3.UP)
