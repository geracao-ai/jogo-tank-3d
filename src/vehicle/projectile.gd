class_name Projectile
extends Node3D
## Cannon shell. Moves each physics tick and sweeps a ray from the previous to the new
## position, so a fast shot cannot tunnel through thin geometry.
## Ends on hitting anything (emits impacted) or on travelling max_range (no event).
## Implements: design/game-brief.md, MVP feature 4 (story-003-canhao-mira-disparo).
## Knows nothing about destruction; listeners connect to impacted (or Cannon.projectile_impacted).

## Emitted once when the shell hits something. normal points away from the surface.
signal impacted(position: Vector3, normal: Vector3, collider: Node3D)

var _velocity: Vector3
var _gravity: float
var _range_left: float
var _exclude: Array[RID]


## Places the shell at origin and starts it moving. Call right after adding it to the tree.
## exclude: bodies the shell passes through (the firing tank).
func launch(origin: Vector3, velocity: Vector3, tuning: CannonTuning, exclude: Array[RID]) -> void:
	global_position = origin
	_velocity = velocity
	_gravity = tuning.projectile_gravity
	_range_left = tuning.max_range
	_exclude = exclude


func _physics_process(delta: float) -> void:
	_velocity.y -= _gravity * delta
	var from: Vector3 = global_position
	var to: Vector3 = from + _velocity * delta
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = _exclude
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		global_position = hit.position
		impacted.emit(hit.position, hit.normal, hit.collider)
		queue_free()
		return
	_range_left -= from.distance_to(to)
	global_position = to
	if _range_left <= 0.0:
		queue_free()
