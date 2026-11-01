class_name CityProp
extends StaticBody3D
## One-hit scenery drawn by shared MultiMeshes: trees, palms, poles and boats.
## Implements: story-008-estilo-da-cidade.
##
## A shell or the tank fells it once. Land props tip over and stay lying as a permanent mark;
## boats sink. Its collision goes away, so nothing snags the tank afterwards.

## Emitted when the prop starts to fall.
signal felled(prop: CityProp)

## How a prop leaves: tipped over on land, or sinking in the water.
enum Fall { TIP, SINK }

## Seconds the fall takes.
var fall_time: float = 0.7
## Final tilt of a fall, in degrees.
var fall_angle_deg: float = 86.0
## How far a boat sinks, in metres.
var sink_depth: float = 2.5
## Fall style.
var fall_style: Fall = Fall.TIP

var _parts: Array[Dictionary] = []
var _shadow: MultiMesh = null
var _shadow_index: int = -1
var _felled: bool = false


## Registers one MultiMesh instance that belongs to this prop.
func add_part(multimesh: MultiMesh, index: int) -> void:
	_parts.append({"multimesh": multimesh, "index": index, "base": multimesh.get_instance_transform(index)})


## Sets the ground shadow instance to hide when the prop falls.
func set_shadow(multimesh: MultiMesh, index: int) -> void:
	_shadow = multimesh
	_shadow_index = index


## True once the prop has been felled.
func is_felled() -> bool:
	return _felled


## Fells the prop, away from the point `from` (the impact, or the tank). Later calls do nothing.
func take_hit(from: Vector3) -> void:
	if _felled:
		return
	_felled = true
	# Deferred: this can run inside the physics step.
	for child: Node in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", true)
	if _shadow != null:
		_shadow.set_instance_transform(_shadow_index, Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO))
	var away: Vector3 = (global_position - from) * Vector3(1, 0, 1)
	if away.length_squared() < 0.0001:
		away = Vector3.FORWARD
	var axis: Vector3 = Vector3.UP.cross(away.normalized()).normalized()
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_method(_pose.bind(axis), 0.0, 1.0, fall_time)
	felled.emit(self)


func _pose(amount: float, axis: Vector3) -> void:
	var pivot: Vector3 = global_position
	var angle: float = deg_to_rad(fall_angle_deg) * amount
	var drop := Vector3.ZERO
	if fall_style == Fall.SINK:
		angle *= 0.3
		drop = Vector3.DOWN * sink_depth * amount
	var turn := Transform3D(Basis(axis, angle), pivot + drop) * Transform3D(Basis.IDENTITY, -pivot)
	for part: Dictionary in _parts:
		(part["multimesh"] as MultiMesh).set_instance_transform(part["index"], turn * (part["base"] as Transform3D))
