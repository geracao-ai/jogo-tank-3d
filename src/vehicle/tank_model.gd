class_name TankModel
extends Node
## Builds the tank's look from primitives merged into one vertex-coloured mesh per moving part,
## so the whole tank stays at three draw calls. Collision and handling live elsewhere.
## Implements: story-008-estilo-da-cidade.
##
## A part is [shape, size, position, colour, tilt_x_deg]. shape "box" takes size (x, y, z);
## "cyl" is a cylinder with size (radius x, height, radius z) standing on Y; "rod" is the same
## cylinder lying along X and "tube" lying along Z. Front of the tank is -Z.

## Mesh nodes to fill, in their own local space.
@export var hull: MeshInstance3D
@export var turret: MeshInstance3D
@export var barrel: MeshInstance3D

const OLIVE := Color(0.5, 0.56, 0.33)
const OLIVE_LIGHT := Color(0.64, 0.68, 0.42)
const OLIVE_DARK := Color(0.37, 0.42, 0.28)
const TRACK := Color(0.27, 0.25, 0.27)
const WHEEL := Color(0.72, 0.66, 0.52)
const CREAM := Color(0.93, 0.87, 0.71)
const RUST := Color(0.73, 0.38, 0.27)
const LAMP := Color(0.98, 0.84, 0.46)
const METAL := Color(0.45, 0.43, 0.42)


func _ready() -> void:
	hull.mesh = _merge(_hull_parts())
	turret.mesh = _merge(_turret_parts())
	barrel.mesh = _merge(_barrel_parts())


func _hull_parts() -> Array:
	var parts: Array = [
		["box", Vector3(1.5, 0.55, 3.7), Vector3(0, -0.12, 0), OLIVE_DARK],
		["box", Vector3(2.05, 0.34, 2.75), Vector3(0, 0.3, 0.25), OLIVE],
		["box", Vector3(2.0, 0.12, 1.25), Vector3(0, 0.12, -1.62), OLIVE_LIGHT, 24.0],
		["box", Vector3(1.55, 0.26, 0.95), Vector3(0, 0.56, 1.25), OLIVE_DARK],
		["box", Vector3(2.08, 0.05, 0.3), Vector3(0, 0.48, -0.75), CREAM],
		["cyl", Vector3(0.1, 0.55, 0.1), Vector3(0.62, 0.92, 1.45), METAL],
		["cyl", Vector3(0.13, 0.08, 0.13), Vector3(0.62, 1.22, 1.45), RUST],
		["box", Vector3(0.5, 0.28, 0.3), Vector3(-0.6, 0.62, 0.45), RUST],
	]
	for i: int in 3:
		parts.append(["box", Vector3(1.2, 0.03, 0.09), Vector3(0, 0.7, 0.95 + i * 0.28), TRACK])
	for side: float in [-1.0, 1.0]:
		parts.append(["box", Vector3(0.5, 0.48, 3.85), Vector3(side, -0.26, 0), TRACK])
		parts.append(["rod", Vector3(0.25, 0.5, 0.25), Vector3(side, -0.26, -1.93), TRACK])
		parts.append(["rod", Vector3(0.25, 0.5, 0.25), Vector3(side, -0.26, 1.93), TRACK])
		parts.append(["box", Vector3(0.6, 0.06, 4.15), Vector3(side, 0.02, 0), OLIVE_LIGHT])
		parts.append(["cyl", Vector3(0.11, 0.12, 0.11), Vector3(side * 0.75, 0.3, -1.42), LAMP])
		for i: int in 5:
			parts.append(["rod", Vector3(0.19, 0.08, 0.19), Vector3(side * 1.27, -0.28, -1.52 + i * 0.76), WHEEL])
	return parts


func _turret_parts() -> Array:
	return [
		["cyl", Vector3(0.86, 0.56, 1.0), Vector3(0, 0, 0.02), OLIVE],
		["cyl", Vector3(0.88, 0.1, 1.02), Vector3(0, -0.14, 0.02), CREAM],
		["cyl", Vector3(0.66, 0.1, 0.78), Vector3(0, 0.32, 0.02), OLIVE_LIGHT],
		["cyl", Vector3(0.3, 0.14, 0.3), Vector3(0.22, 0.42, 0.18), RUST],
		["box", Vector3(0.72, 0.42, 0.34), Vector3(0, 0.0, -0.9), OLIVE_DARK],
		["box", Vector3(0.05, 1.1, 0.05), Vector3(-0.45, 0.8, 0.7), METAL],
		["box", Vector3(0.46, 0.24, 0.16), Vector3(0, 0.08, 1.08), OLIVE_DARK],
	]


func _barrel_parts() -> Array:
	return [
		["tube", Vector3(0.09, 2.0, 0.09), Vector3.ZERO, OLIVE_LIGHT],
		["tube", Vector3(0.14, 0.75, 0.14), Vector3(0, 0, 0.62), OLIVE_DARK],
		["tube", Vector3(0.1, 0.06, 0.1), Vector3(0, 0, -0.1), CREAM],
		["tube", Vector3(0.15, 0.32, 0.15), Vector3(0, 0, -0.88), METAL],
	]


func _merge(parts: Array) -> ArrayMesh:
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	for part: Array in parts:
		var form: Transform3D = _part_transform(part)
		var arrays: Array = _primitive(part).get_mesh_arrays()
		var base: int = verts.size()
		var color: Color = part[3]
		var normal_basis: Basis = form.basis.inverse().transposed()
		var part_verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var part_normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		for i: int in part_verts.size():
			verts.append(form * part_verts[i])
			normals.append((normal_basis * part_normals[i]).normalized())
			colors.append(color)
		for index: int in arrays[Mesh.ARRAY_INDEX]:
			indices.append(base + index)
	var out: Array = []
	out.resize(Mesh.ARRAY_MAX)
	out[Mesh.ARRAY_VERTEX] = verts
	out[Mesh.ARRAY_NORMAL] = normals
	out[Mesh.ARRAY_COLOR] = colors
	out[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, out)
	return mesh


func _primitive(part: Array) -> PrimitiveMesh:
	if part[0] == "box":
		var box := BoxMesh.new()
		box.size = part[1]
		return box
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 1.0
	cylinder.bottom_radius = 1.0
	cylinder.height = 1.0
	cylinder.radial_segments = 14
	cylinder.rings = 1
	return cylinder


func _part_transform(part: Array) -> Transform3D:
	var size: Vector3 = part[1]
	var position: Vector3 = part[2]
	match part[0]:
		"cyl":
			return Transform3D(Basis.from_scale(size), position)
		"rod":
			return Transform3D(Basis(Vector3.BACK, PI * 0.5) * Basis.from_scale(size), position)
		"tube":
			return Transform3D(Basis(Vector3.RIGHT, PI * 0.5) * Basis.from_scale(size), position)
	var tilt: float = part[4] if part.size() > 4 else 0.0
	return Transform3D(Basis(Vector3.RIGHT, deg_to_rad(tilt)), position)
