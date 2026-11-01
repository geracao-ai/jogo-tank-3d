class_name CityBuilder
extends Node3D
## Builds the Porto Sereno city at load from a JSON layout (streets, lots, sea, walls).
## Implements: design/game-brief.md, MVP feature 3 (story-005-cidade-costeira-completa).
##
## All sizes, colours, positions and hit tuning come from the layout file
## (default src/world/porto_sereno_city.json; its "_doc" field explains the format).
## Each lot becomes a Destructible (story 004) with Intact/Damaged/Destroyed stages built from
## size-parameterised boxes. Meshes, shapes and materials are shared between objects that
## have the same size/colour, to keep draw calls and memory low on phones.
## Everything is flat: ground top at y=0, street strips are visual only (no collision),
## so nothing snags the tank. The sea (+X side) is a plane with an invisible wall at the shoreline.

## Emitted once the city exists. total is the number of destructible objects.
signal city_built(total: int)

## Layout file (JSON).
@export_file("*.json") var layout_path: String = "res://src/world/porto_sereno_city.json"
## Tank to place at the layout's tank_start (optional).
@export var tank: Node3D

var _meshes: Dictionary = {}
var _shapes: Dictionary = {}
var _materials: Dictionary = {}
var _counts: Dictionary = {}
var _layout: Dictionary = {}
var _toon_shader: Shader = preload("res://src/rendering/toon.gdshader")


func _ready() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(layout_path))
	if not parsed is Dictionary:
		push_error("CityBuilder: cannot read layout %s" % layout_path)
		return
	_layout = parsed
	build()


## Number of destructible objects built, by type name (e.g. {"shop": 13}).
func get_counts() -> Dictionary:
	return _counts


## Builds everything from the loaded layout. Called by _ready().
func build() -> void:
	_build_ground_and_streets()
	_build_sea_and_walls()
	var total: int = 0
	var lots: Array = _layout["lots"]
	for lot: Dictionary in lots:
		_build_lot(lot, total)
		total += 1
	_place_tank()
	city_built.emit(total)


# --- layout geometry -------------------------------------------------------------------------

func _grid() -> Vector2i:
	var g: Array = _layout["grid"]
	return Vector2i(int(g[0]), int(g[1]))


func _block_size() -> Vector2:
	return _v2(_layout["block_size"])


## Size of the street grid (outer edge to outer edge), x and z.
func _city_size() -> Vector2:
	var g: Vector2i = _grid()
	var s: float = _layout["street_width"]
	var b: Vector2 = _block_size()
	return Vector2(g.x * b.x + (g.x + 1) * s, g.y * b.y + (g.y + 1) * s)


func _block_center(block: Array) -> Vector2:
	var s: float = _layout["street_width"]
	var b: Vector2 = _block_size()
	var c: Vector2 = _city_size() * -0.5
	return Vector2(
		c.x + s + b.x * 0.5 + int(block[0]) * (b.x + s),
		c.y + s + b.y * 0.5 + int(block[1]) * (b.y + s))


func _build_ground_and_streets() -> void:
	var city: Vector2 = _city_size()
	var margin: float = _layout["land_margin"]
	var shore_x: float = city.x * 0.5 + float(_layout["shore_gap"])
	var west_x: float = -city.x * 0.5 - margin
	var land := Vector2(shore_x - west_x, city.y + 2.0 * margin)
	var land_center := Vector3((shore_x + west_x) * 0.5, 0.0, 0.0)

	var ground := StaticBody3D.new()
	ground.name = "Ground"
	add_child(ground)
	var shape := CollisionShape3D.new()
	shape.name = "CollisionShape3D"
	shape.shape = _box_shape(Vector3(land.x, 1.0, land.y))
	shape.position = land_center + Vector3(0, -0.5, 0)
	ground.add_child(shape)
	_add_plane(ground, "Land", land, land_center, _color(_layout["ground_color"]))

	var streets := Node3D.new()
	streets.name = "Streets"
	add_child(streets)
	var street_color: Color = _color(_layout["street_color"])
	var y: float = _layout["street_y"]
	var w: float = _layout["street_width"]
	var b: Vector2 = _block_size()
	var g: Vector2i = _grid()
	for i: int in g.x + 1:
		var x: float = -city.x * 0.5 + w * 0.5 + i * (b.x + w)
		_add_plane(streets, "StreetNS%d" % i, Vector2(w, city.y), Vector3(x, y, 0), street_color)
	for j: int in g.y + 1:
		var z: float = -city.y * 0.5 + w * 0.5 + j * (b.y + w)
		_add_plane(streets, "StreetEW%d" % j, Vector2(city.x, w), Vector3(0, y, z), street_color)


func _build_sea_and_walls() -> void:
	var city: Vector2 = _city_size()
	var margin: float = _layout["land_margin"]
	var shore_x: float = city.x * 0.5 + float(_layout["shore_gap"])
	var west_x: float = -city.x * 0.5 - margin
	var t: float = _layout["wall_thickness"]
	var h: float = _layout["wall_height"]
	var land_z: float = city.y + 2.0 * margin

	var sea: Dictionary = _layout["sea"]
	var length: float = sea["length"]
	var sea_node := Node3D.new()
	sea_node.name = "Sea"
	add_child(sea_node)
	_add_plane(sea_node, "Water", Vector2(length, sea["width"]),
		Vector3(shore_x + length * 0.5, -float(sea["depth"]), 0), _color(sea["color"]), true)

	# Invisible walls: the shoreline (east) keeps the tank out of the sea, the others keep it on the land.
	_add_wall("SeaBarrier", Vector3(shore_x + t * 0.5, h * 0.5, 0), Vector3(t, h, land_z + 2.0 * t))
	_add_wall("WallWest", Vector3(west_x - t * 0.5, h * 0.5, 0), Vector3(t, h, land_z + 2.0 * t))
	var mid_x: float = (shore_x + west_x) * 0.5
	var len_x: float = shore_x - west_x
	_add_wall("WallNorth", Vector3(mid_x, h * 0.5, -land_z * 0.5 - t * 0.5), Vector3(len_x, h, t))
	_add_wall("WallSouth", Vector3(mid_x, h * 0.5, land_z * 0.5 + t * 0.5), Vector3(len_x, h, t))


func _add_wall(wall_name: String, center: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = wall_name
	body.position = center
	var shape := CollisionShape3D.new()
	shape.name = "CollisionShape3D"
	shape.shape = _box_shape(size)
	body.add_child(shape)
	add_child(body)


func _place_tank() -> void:
	if tank == null:
		return
	var start: Dictionary = _layout["tank_start"]
	var p: Vector2 = _v2(start["position"])
	tank.global_transform = Transform3D(
		Basis(Vector3.UP, deg_to_rad(float(start["yaw_deg"]))), Vector3(p.x, 0.0, p.y))


# --- destructible objects --------------------------------------------------------------------

func _build_lot(lot: Dictionary, index: int) -> void:
	var type_name: String = lot["type"]
	var def: Dictionary = _layout["types"][type_name]
	var size: Vector3 = _v3(lot["size"])
	var center: Vector2 = _block_center(lot["block"]) + _v2(lot["offset"])

	var obj := Destructible.new()
	obj.name = "%s%02d" % [type_name.capitalize(), index]
	obj.tuning = load(def["tuning"])
	obj.position = Vector3(center.x, 0.0, center.y)
	obj.rotation.y = deg_to_rad(float(lot.get("yaw_deg", 0.0)))

	var intact := Node3D.new()
	intact.name = "Intact"
	obj.add_child(intact)
	var damaged := Node3D.new()
	damaged.name = "Damaged"
	obj.add_child(damaged)
	var destroyed := Node3D.new()
	destroyed.name = "Destroyed"
	obj.add_child(destroyed)

	_build_intact(obj, intact, def, size)
	_build_damaged(obj, damaged, def, size)
	_build_destroyed(destroyed, def, size)

	add_child(obj) # after the stage nodes exist: Destructible resolves them in _ready()
	_counts[type_name] = int(_counts.get(type_name, 0)) + 1


func _build_intact(obj: Destructible, stage: Node3D, def: Dictionary, size: Vector3) -> void:
	var color: Color = _color(def["intact_color"])
	var mid := Vector3(0, size.y * 0.5, 0)
	_add_box(stage, "Block", size, mid, color)
	_add_collision(obj, "IntactCollision", size, mid)

	if def.has("awning"):
		var a: Dictionary = def["awning"]
		var over: float = a["overhang"]
		var thick: float = a["thickness"]
		_add_box(stage, "Awning", Vector3(size.x, thick, over * 2.0),
			Vector3(0, a["y"], size.z * 0.5), _color(a["color"]))
	if def.has("sign"):
		var s: Dictionary = def["sign"]
		var sign_size := Vector3(size.x * float(s["width_frac"]), s["height"], s["thickness"])
		var sign_y: float = size.y - float(s["top_gap"]) - sign_size.y * 0.5
		_add_box(stage, "Sign", sign_size,
			Vector3(0, sign_y, size.z * 0.5 + sign_size.z * 0.5), _color(s["color"]))

	var cfg: Dictionary = _layout["label"]
	if not cfg["show"]:
		return
	var label := Label3D.new()
	label.name = "Label"
	label.text = def["label"]
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = cfg["pixel_size"]
	label.font_size = int(cfg["font_size"])
	label.modulate = _color(cfg["color"])
	label.position = Vector3(0, size.y + float(cfg["height_offset"]), 0)
	stage.add_child(label)


func _build_damaged(obj: Destructible, stage: Node3D, def: Dictionary, size: Vector3) -> void:
	var cfg: Dictionary = _layout["damaged"]
	var color: Color = _color(def["damaged_color"])
	var low := Vector3(size.x, size.y * float(def["damaged_height_ratio"]), size.z)
	var low_mid := Vector3(0, low.y * 0.5, 0)
	_add_box(stage, "Block", low, low_mid, color)
	_add_collision(obj, "DamagedCollision", low, low_mid)

	var frac: Vector3 = _v3(cfg["chunk_size_frac"])
	var chunk := Vector3(size.x * frac.x, size.y * frac.y, size.z * frac.z)
	var off: Vector2 = _v2(cfg["chunk_offset_frac"])
	var chunk_pos := Vector3(size.x * off.x, low.y + chunk.y * 0.5 - float(cfg["chunk_sink"]), size.z * off.y)
	var yaw: float = deg_to_rad(float(cfg["chunk_yaw_deg"]))
	_add_box(stage, "Chunk", chunk, chunk_pos, color, yaw)
	_add_collision(obj, "DamagedCollision2", chunk, chunk_pos, yaw)


func _build_destroyed(stage: Node3D, def: Dictionary, size: Vector3) -> void:
	var color: Color = _color(def["rubble_color"])
	var pieces: Array = _layout["rubble"]
	var i: int = 0
	for piece: Dictionary in pieces:
		var p: Vector2 = _v2(piece["pos"])
		var s: Vector3 = _v3(piece["size"])
		var box := Vector3(s.x * size.x, s.y, s.z * size.z)
		_add_box(stage, "Rubble%d" % i, box, Vector3(p.x * size.x, box.y * 0.5, p.y * size.z),
			color, deg_to_rad(float(piece["yaw_deg"])))
		i += 1
	# Deliberately no collision: the tank drives over rubble (see Destructible doc).


# --- shared mesh/shape/material helpers ------------------------------------------------------

func _add_box(parent: Node3D, node_name: String, size: Vector3, pos: Vector3, color: Color, yaw: float = 0.0) -> void:
	var key: String = "%s|%s" % [size, color]
	if not _meshes.has(key):
		var mesh := BoxMesh.new()
		mesh.size = size
		mesh.material = _material(color)
		_meshes[key] = mesh
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = _meshes[key]
	mi.position = pos
	mi.rotation.y = yaw
	parent.add_child(mi)


func _add_plane(parent: Node3D, node_name: String, size: Vector2, pos: Vector3, color: Color, is_sea: bool = false) -> void:
	var mesh := PlaneMesh.new()
	mesh.size = size
	mesh.material = _sea_material(color) if is_sea else _material(color)
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.position = pos
	parent.add_child(mi)


func _add_collision(body: Destructible, node_name: String, size: Vector3, pos: Vector3, yaw: float = 0.0) -> void:
	var cs := CollisionShape3D.new()
	cs.name = node_name
	cs.shape = _box_shape(size)
	cs.position = pos
	cs.rotation.y = yaw
	body.add_child(cs)


func _box_shape(size: Vector3) -> BoxShape3D:
	if not _shapes.has(size):
		var shape := BoxShape3D.new()
		shape.size = size
		_shapes[size] = shape
	return _shapes[size]


## Shared toon material for a colour (see toon.gdshader; band values come from the layout's "toon").
func _material(color: Color) -> ShaderMaterial:
	if not _materials.has(color):
		var mat := ShaderMaterial.new()
		mat.shader = _toon_shader
		mat.set_shader_parameter("albedo", color)
		mat.set_shader_parameter("band_threshold", float(_layout["toon"]["band_threshold"]))
		mat.set_shader_parameter("band_softness", float(_layout["toon"]["band_softness"]))
		_materials[color] = mat
	return _materials[color]


## The sea's toon material: the same shader with the animated shimmer switched on.
func _sea_material(color: Color) -> ShaderMaterial:
	var sea: Dictionary = _layout["sea"]
	var mat: ShaderMaterial = _material(color).duplicate()
	mat.set_shader_parameter("shimmer_strength", float(sea["shimmer_strength"]))
	mat.set_shader_parameter("shimmer_color", _color(sea["shimmer_color"]))
	mat.set_shader_parameter("shimmer_scale", float(sea["shimmer_scale"]))
	mat.set_shader_parameter("shimmer_speed", float(sea["shimmer_speed"]))
	return mat


func _v2(a: Array) -> Vector2:
	return Vector2(float(a[0]), float(a[1]))


func _v3(a: Array) -> Vector3:
	return Vector3(float(a[0]), float(a[1]), float(a[2]))


func _color(a: Array) -> Color:
	return Color(float(a[0]), float(a[1]), float(a[2]))
