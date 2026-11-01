class_name CityBuilder
extends Node3D
## Builds the Porto Sereno city at load from a JSON layout (streets, lots, sea, walls).
## Implements: design/game-brief.md, MVP feature 3 (story-005-cidade-costeira-completa).
##
## All sizes, colours, positions and hit tuning come from the layout file
## (default src/world/porto_sereno_city.json; its "_doc" field explains the format).
## Each lot becomes a Destructible (story 004): a kit model fitted to the lot, recoloured by a
## palette, whose damaged and destroyed stages are the same model cut off by a shader. Scenery
## (hills, clouds), decor (trees, boats, fences) and poles come from the same file and are drawn
## by shared MultiMeshes, to keep draw calls and memory low on phones (story-008-estilo-da-cidade).
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
var _model_meshes: Dictionary = {}
var _decor_ready: Dictionary = {}
var _palettes: Dictionary = {}
var _ruins: Dictionary = {}
var _surfaces: Dictionary = {}
var _shadows: Array[Transform3D] = []
var _shadow_multimesh: MultiMesh = null
var _shadow_parts: Array[Array] = []
var _rubble_forms: Dictionary = {}
var _rubble_multimeshes: Dictionary = {}
var _spans: Array[Dictionary] = []
var _wires: ArrayMesh = null
var _toon_shader: Shader = preload("res://src/rendering/toon.gdshader")
var _ruin_shader: Shader = preload("res://src/rendering/ruined_building.gdshader")
var _shadow_shader: Shader = preload("res://src/rendering/ground_shadow.gdshader")


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
	_build_scenery()
	_build_decor()
	_build_pier()
	_build_ground_shadows()
	_build_rubble_multimeshes()
	_place_tank()
	_prewarm_ruin_shader()
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
	_add_plane(ground, "Land", land, land_center, _surface_material("land", _color(_layout["ground_color"])))

	var streets := Node3D.new()
	streets.name = "Streets"
	add_child(streets)
	var y: float = _layout["street_y"]
	var w: float = _layout["street_width"]
	var walk: float = _layout["sidewalk_width"]
	var b: Vector2 = _block_size()
	var g: Vector2i = _grid()
	var street_strips: Array[Rect2] = []
	var walk_strips: Array[Rect2] = []
	# Each sidewalk is a wider strip just under its street, so the crossings need no extra pieces.
	for i: int in g.x + 1:
		var x: float = -city.x * 0.5 + w * 0.5 + i * (b.x + w)
		street_strips.append(Rect2(x - w * 0.5, -city.y * 0.5, w, city.y))
		walk_strips.append(Rect2(x - w * 0.5 - walk, -city.y * 0.5 - walk, w + walk * 2.0, city.y + walk * 2.0))
	for j: int in g.y + 1:
		var z: float = -city.y * 0.5 + w * 0.5 + j * (b.y + w)
		street_strips.append(Rect2(-city.x * 0.5, z - w * 0.5, city.x, w))
		walk_strips.append(Rect2(-city.x * 0.5 - walk, z - w * 0.5 - walk, city.x + walk * 2.0, w + walk * 2.0))
	_add_strips("Streets", street_strips, y, _surface_material("street", _color(_layout["street_color"])))
	_add_strips("Sidewalks", walk_strips, y * 0.5, _surface_material("walk", _color(_layout["sidewalk_color"])))


## Flat upward rectangles (x, z) as one mesh: one draw call however many strips there are.
func _add_strips(node_name: String, strips: Array[Rect2], y: float, material: Material) -> void:
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	for strip: Rect2 in strips:
		var base: int = verts.size()
		verts.append(Vector3(strip.position.x, y, strip.position.y))
		verts.append(Vector3(strip.end.x, y, strip.position.y))
		verts.append(Vector3(strip.end.x, y, strip.end.y))
		verts.append(Vector3(strip.position.x, y, strip.end.y))
		for k: int in 4:
			normals.append(Vector3.UP)
		indices.append_array(PackedInt32Array([base, base + 1, base + 2, base, base + 2, base + 3]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	add_child(mi)


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
		Vector3(shore_x + length * 0.5, -float(sea["depth"]), 0), _sea_material(_color(sea["color"])))

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
	var footprint: Vector3 = _v3(lot["size"])
	var center: Vector2 = _block_center(lot["block"]) + _v2(lot["offset"])

	# The model fills the lot's footprint without distortion; stretch_y adds height on purpose.
	var model: Mesh = _model_mesh(lot["model"])
	var box: AABB = model.get_aabb()
	var fit: float = minf(footprint.x / box.size.x, footprint.z / box.size.z)
	var stretch: float = float(lot.get("stretch_y", 1.0))
	var model_scale := Vector3(fit, fit * stretch, fit)
	var mid: Vector3 = box.get_center()
	var form := Transform3D(Basis.from_scale(model_scale),
		Vector3(-mid.x * fit, -box.position.y * model_scale.y, -mid.z * fit))
	var size: Vector3 = box.size * model_scale
	var palette: int = int(lot.get("palette", 0))

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

	_add_model(intact, "Model", model, form, _palette_material(palette))
	_add_collision(obj, "IntactCollision", size, Vector3(0, size.y * 0.5, 0))
	_build_details(obj, intact, def, size)

	# Ruins: the same model cut at a height in model units, so all of them lose roof and top floor.
	var cut: float = float(_layout["damaged"]["clip_y"])
	var low_y: float = minf((cut - box.position.y) * model_scale.y, size.y)
	_add_model(damaged, "Model", model, form, _ruin_material(palette, cut))
	damaged.set_meta("top", low_y)
	_add_collision(obj, "DamagedCollision", Vector3(size.x, low_y, size.z), Vector3(0, low_y * 0.5, 0))
	cut = float(_layout["destroyed"]["clip_y"])
	_add_model(destroyed, "Model", model, form, _ruin_material(palette, cut))
	destroyed.set_meta("top", (cut - box.position.y) * model_scale.y)
	var rubble_first: int = _add_rubble(type_name, obj.transform, size)

	var shadow: int = _add_shadow(center, size)
	obj.stage_changed.connect(_on_lot_stage_changed.bind(shadow, type_name, rubble_first))
	add_child(obj) # after the stage nodes exist: Destructible resolves them in _ready()
	_counts[type_name] = int(_counts.get(type_name, 0)) + 1


## A destroyed lot loses its shadow and shows its rubble.
func _on_lot_stage_changed(stage: Destructible.Stage, shadow: int, type_name: String, rubble_first: int) -> void:
	if stage != Destructible.Stage.DESTROYED:
		return
	_shadow_multimesh.set_instance_transform(shadow, _hidden())
	var forms: Array = _rubble_forms[type_name]
	var multimesh: MultiMesh = _rubble_multimeshes[type_name]
	for i: int in range(rubble_first, rubble_first + (_layout["rubble"] as Array).size()):
		multimesh.set_instance_transform(i, forms[i])


func _hidden() -> Transform3D:
	return Transform3D(Basis.from_scale(Vector3.ZERO), Vector3.ZERO)


func _add_model(stage: Node3D, node_name: String, mesh: Mesh, form: Transform3D, material: Material) -> void:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.material_override = material
	mi.transform = form
	stage.add_child(mi)


## What tells a lot's type apart on the street: shop awnings and signs, the bank's portico.
func _build_details(obj: Destructible, stage: Node3D, def: Dictionary, size: Vector3) -> void:
	if def.has("awning"):
		var a: Dictionary = def["awning"]
		var over: float = a["overhang"]
		var thick: float = a["thickness"]
		_add_box(stage, "Awning", Vector3(size.x * float(a["width_frac"]), thick, over * 2.0),
			Vector3(0, a["y"], size.z * 0.5), _color(a["color"]))
	if def.has("sign"):
		var s: Dictionary = def["sign"]
		var sign_size := Vector3(size.x * float(s["width_frac"]), s["height"], s["thickness"])
		_add_box(stage, "Sign", sign_size,
			Vector3(0, s["y"], size.z * 0.5 + float(s["forward"])), _color(s["color"]))
	if def.has("portico"):
		var p: Dictionary = def["portico"]
		var color: Color = _color(p["color"])
		var height: float = p["height"]
		var depth: float = p["depth"]
		var count: int = p["columns"]
		var width: float = size.x * float(p["width_frac"])
		var front: float = size.z * 0.5 + depth
		_add_collision(obj, "IntactCollision2", Vector3(width, height, depth),
			Vector3(0, height * 0.5, size.z * 0.5 + depth * 0.5))
		_add_box(stage, "PorticoRoof", Vector3(width + 1.0, p["roof"], depth + 1.0),
			Vector3(0, height + float(p["roof"]) * 0.5, size.z * 0.5 + depth * 0.5), color)
		_add_box(stage, "PorticoStep", Vector3(width + 1.0, 0.4, depth + 1.0),
			Vector3(0, 0.2, size.z * 0.5 + depth * 0.5), color)
		for i: int in count:
			var x: float = lerpf(-width * 0.5, width * 0.5, float(i) / (count - 1))
			_add_box(stage, "Column%d" % i, Vector3(0.8, height, 0.8), Vector3(x, height * 0.5, front), color)


## Records a lot's rubble and returns where its pieces start. Rubble of a type shares one
## MultiMesh, a single draw call, and stays hidden until the lot is destroyed.
func _add_rubble(type_name: String, lot_form: Transform3D, size: Vector3) -> int:
	if not _rubble_forms.has(type_name):
		_rubble_forms[type_name] = []
	var forms: Array = _rubble_forms[type_name]
	var first: int = forms.size()
	for piece: Dictionary in _layout["rubble"]:
		var p: Vector2 = _v2(piece["pos"])
		var s: Vector3 = _v3(piece["size"])
		var box := Vector3(s.x * size.x, s.y, s.z * size.z)
		var yaw: float = deg_to_rad(float(piece["yaw_deg"]))
		forms.append(lot_form * Transform3D(Basis(Vector3.UP, yaw).scaled(box),
			Vector3(p.x * size.x, box.y * 0.5, p.y * size.z)))
	return first


# Deliberately no collision for rubble: the tank drives over it (see Destructible doc).
func _build_rubble_multimeshes() -> void:
	for type_name: String in _rubble_forms:
		var box := BoxMesh.new()
		box.material = _material(_color(_layout["types"][type_name]["rubble_color"]))
		var hidden: Array[Transform3D] = []
		hidden.resize((_rubble_forms[type_name] as Array).size())
		hidden.fill(_hidden())
		_rubble_multimeshes[type_name] = _add_multimesh("Rubble_" + type_name, box, hidden)


## Draws a speck with the ruin shader while the city loads. Otherwise a phone compiles it on the
## first hit, and the game freezes right as the player sees the shot land.
func _prewarm_ruin_shader() -> void:
	if tank == null:
		return
	var speck := MeshInstance3D.new()
	speck.mesh = _model_mesh(_layout["lots"][0]["model"])
	speck.material_override = _ruin_material(int(_layout["lots"][0].get("palette", 0)), float(_layout["destroyed"]["clip_y"]))
	speck.scale = Vector3.ONE * 0.001
	speck.position = tank.global_position + Vector3.UP
	add_child(speck)
	await get_tree().create_timer(0.5).timeout
	speck.queue_free()


# --- scenery ---------------------------------------------------------------------------------

## Land out to the horizon, hills in hazy layers (one draw per colour) and big cumulus clouds.
func _build_scenery() -> void:
	var cfg: Dictionary = _layout["scenery"]
	var far: Dictionary = cfg["far_land"]
	_add_plane(self, "FarLand", _v2(far["size"]), _v3(far["pos"]), _surface_material("land", _color(far["color"])))

	var layers: Dictionary = {}
	for hill: Dictionary in cfg["hills"]:
		var key: String = hill["layer"]
		if not layers.has(key):
			layers[key] = [] as Array[Transform3D]
		layers[key].append(Transform3D(Basis.from_scale(_v3(hill["size"])), _v3(hill["pos"])))
	for key: String in layers:
		var dome := SphereMesh.new()
		dome.radial_segments = 12
		dome.rings = 4
		dome.material = _material(_color(cfg["hill_colors"][key]))
		_add_multimesh("Hills_" + key, dome, layers[key])

	var i: int = 0
	for cloud: Dictionary in cfg["clouds"]:
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_texture = load(cloud["texture"])
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
		var quad := QuadMesh.new()
		quad.size = _v2(cloud["size"])
		quad.material = mat
		var mi := MeshInstance3D.new()
		mi.name = "Cloud%d" % i
		mi.mesh = quad
		mi.position = _v3(cloud["pos"])
		add_child(mi)
		i += 1


func _build_decor() -> void:
	var groups: Dictionary = {}
	for item: Dictionary in _layout["decor"]:
		if not groups.has(item["type"]):
			groups[item["type"]] = [] as Array[Dictionary]
		groups[item["type"]].append(item)
	for type_name: String in groups:
		_build_decor_group(type_name, groups[type_name])
	_build_poles()


func _build_decor_group(type_name: String, items: Array[Dictionary]) -> void:
	var def: Dictionary = _layout["decor_types"][type_name]
	var forms: Array[Transform3D] = []
	var shadows: Array[int] = []
	for item: Dictionary in items:
		var size: float = float(def["scale"]) * float(item.get("scale", 1.0))
		var p: Vector2 = _v2(item["pos"])
		var yaw: float = deg_to_rad(float(item.get("yaw_deg", 0.0)))
		forms.append(Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * size),
			Vector3(p.x, float(item.get("y", 0.0)), p.y)))
		var shadow: int = -1
		if def.has("shadow"):
			var r: float = float(def["shadow"]) * size
			shadow = _shadows.size()
			_shadows.append(Transform3D(Basis.from_scale(Vector3(r, 1.0, r * 1.5)),
				Vector3(p.x, float(_layout["shadow"]["y"]), p.y - r * 0.4)))
		shadows.append(shadow)
	var multimesh: MultiMesh = _add_multimesh(type_name, _decor_mesh(def), forms)
	if not def.has("collision"):
		return
	var cfg: Dictionary = def["collision"]
	for i: int in forms.size():
		var prop: CityProp = _add_prop("%s%d" % [type_name, i], forms[i].origin, cfg["radius"], cfg["height"])
		prop.add_part(multimesh, i)
		if shadows[i] >= 0:
			_shadow_parts.append([prop, shadows[i]])
		if def.get("sinks", false):
			prop.fall_style = CityProp.Fall.SINK


func _add_prop(prop_name: String, pos: Vector3, radius: float, height: float) -> CityProp:
	var cfg: Dictionary = _layout["prop"]
	var prop := CityProp.new()
	prop.name = prop_name
	prop.position = pos
	prop.collision_layer = int(cfg["collision_layer"])
	prop.collision_mask = 0
	prop.fall_time = cfg["fall_time"]
	prop.fall_angle_deg = cfg["fall_angle_deg"]
	prop.sink_depth = cfg["sink_depth"]
	var key: Vector2 = Vector2(radius, height)
	if not _shapes.has(key):
		var cylinder := CylinderShape3D.new()
		cylinder.radius = radius
		cylinder.height = height
		_shapes[key] = cylinder
	var cs := CollisionShape3D.new()
	cs.shape = _shapes[key]
	cs.position = Vector3(0, height * 0.5, 0)
	prop.add_child(cs)
	add_child(prop)
	return prop


## Utility poles along the data's runs. All the wires are one mesh, rebuilt when a pole falls.
func _build_poles() -> void:
	var cfg: Dictionary = _layout["poles"]
	var h: float = cfg["height"]
	var arm: float = cfg["arm"]
	var color: Color = _color(cfg["color"])
	var pole := CylinderMesh.new()
	pole.top_radius = 0.12
	pole.bottom_radius = 0.18
	pole.height = h
	pole.radial_segments = 6
	pole.rings = 1
	pole.material = _material(color)
	var bar := BoxMesh.new()
	bar.size = Vector3(arm * 2.0, 0.14, 0.14)
	bar.material = pole.material

	var poles: Array[Transform3D] = []
	var bars: Array[Transform3D] = []
	var spots: Array[Vector2] = []
	var links: Array[Vector2i] = []
	for run: Dictionary in cfg["runs"]:
		var a: Vector2 = _v2(run["from"])
		var b: Vector2 = _v2(run["to"])
		var n: int = maxi(int(a.distance_to(b) / float(cfg["spacing"])), 1)
		var dir: Vector2 = (b - a).normalized()
		var yaw: float = atan2(dir.x, dir.y)
		var previous: int = -1
		for i: int in n + 1:
			var p: Vector2 = a.lerp(b, float(i) / n)
			if _on_street(p):
				continue
			poles.append(Transform3D(Basis.IDENTITY, Vector3(p.x, h * 0.5, p.y)))
			bars.append(Transform3D(Basis(Vector3.UP, yaw), Vector3(p.x, h - 0.5, p.y)))
			spots.append(p)
			if previous >= 0:
				links.append(Vector2i(previous, spots.size() - 1))
			previous = spots.size() - 1

	var pole_mm: MultiMesh = _add_multimesh("Poles", pole, poles)
	var bar_mm: MultiMesh = _add_multimesh("PoleBars", bar, bars)
	var props: Array[CityProp] = []
	for i: int in spots.size():
		var prop: CityProp = _add_prop("Pole%d" % i, Vector3(spots[i].x, 0, spots[i].y), 0.35, h)
		prop.add_part(pole_mm, i)
		prop.add_part(bar_mm, i)
		prop.felled.connect(_rebuild_wires.unbind(1))
		props.append(prop)
	for link: Vector2i in links:
		_spans.append({"ends": [props[link.x], props[link.y]], "verts": _span_verts(spots[link.x], spots[link.y], cfg)})

	_wires = ArrayMesh.new()
	var mi := MeshInstance3D.new()
	mi.name = "Wires"
	mi.mesh = _wires
	add_child(mi)
	_rebuild_wires()


func _span_verts(p: Vector2, q: Vector2, cfg: Dictionary) -> PackedVector3Array:
	const SEGMENTS: int = 8
	var dir: Vector2 = (q - p).normalized()
	var side := Vector3(dir.y, 0, -dir.x) * float(cfg["arm"]) * 0.85
	var verts := PackedVector3Array()
	for offset: Vector3 in [side, -side, Vector3.ZERO]:
		for k: int in SEGMENTS:
			verts.append(_wire_point(p, q, float(k) / SEGMENTS, offset, cfg))
			verts.append(_wire_point(p, q, float(k + 1) / SEGMENTS, offset, cfg))
	return verts


func _wire_point(p: Vector2, q: Vector2, t: float, offset: Vector3, cfg: Dictionary) -> Vector3:
	var m: Vector2 = p.lerp(q, t)
	var y: float = float(cfg["height"]) - 0.45 - float(cfg["sag"]) * 4.0 * t * (1.0 - t)
	return Vector3(m.x, y, m.y) + offset


func _rebuild_wires() -> void:
	var verts := PackedVector3Array()
	for span: Dictionary in _spans:
		var ends: Array = span["ends"]
		if not (ends[0] as CityProp).is_felled() and not (ends[1] as CityProp).is_felled():
			verts.append_array(span["verts"])
	_wires.clear_surfaces()
	if verts.is_empty():
		return
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	_wires.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = _color(_layout["poles"]["wire_color"])
	_wires.surface_set_material(0, mat)


func _on_street(p: Vector2) -> bool:
	var s: float = _layout["street_width"]
	var pitch: Vector2 = _block_size() + Vector2.ONE * s
	var first: Vector2 = _city_size() * -0.5 + Vector2.ONE * s * 0.5
	var d: Vector2 = (p - first).posmodv(pitch)
	var half: float = (s + 1.0) * 0.5
	return minf(d.x, pitch.x - d.x) < half or minf(d.y, pitch.y - d.y) < half


func _build_pier() -> void:
	var node := Node3D.new()
	node.name = "Pier"
	add_child(node)
	var color: Color = _color(_layout["pier"]["color"])
	var i: int = 0
	for b: Dictionary in _layout["pier"]["boxes"]:
		_add_box(node, "Plank%d" % i, _v3(b["size"]), _v3(b["pos"]), color)
		i += 1


func _add_shadow(center: Vector2, size: Vector3) -> int:
	var cfg: Dictionary = _layout["shadow"]
	var length: float = size.y * float(cfg["length"])
	var margin: float = cfg["margin"]
	_shadows.append(Transform3D(Basis.from_scale(Vector3(size.x + margin, 1.0, size.z + length + margin)),
		Vector3(center.x, float(cfg["y"]), center.y - length * 0.5)))
	return _shadows.size() - 1


## All ground shadows in one draw. Built last: lots and decor add to the list as they are made.
func _build_ground_shadows() -> void:
	var quad := PlaneMesh.new()
	quad.size = Vector2.ONE
	var mat := ShaderMaterial.new()
	mat.shader = _shadow_shader
	var c: Array = _layout["shadow"]["color"]
	mat.set_shader_parameter("color", Color(float(c[0]), float(c[1]), float(c[2]), float(c[3])))
	quad.material = mat
	_shadow_multimesh = _add_multimesh("GroundShadows", quad, _shadows)
	for part: Array in _shadow_parts:
		(part[0] as CityProp).set_shadow(_shadow_multimesh, part[1])


func _add_multimesh(node_name: String, mesh: Mesh, forms: Array[Transform3D]) -> MultiMesh:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = forms.size()
	for i: int in forms.size():
		multimesh.set_instance_transform(i, forms[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.name = node_name
	mmi.multimesh = multimesh
	add_child(mmi)
	return multimesh


# --- shared mesh/shape/material helpers ------------------------------------------------------

func _add_box(parent: Node3D, node_name: String, size: Vector3, pos: Vector3, color: Color) -> void:
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
	parent.add_child(mi)


func _add_plane(parent: Node3D, node_name: String, size: Vector2, pos: Vector3, material: Material) -> void:
	var mesh := PlaneMesh.new()
	mesh.size = size
	mesh.material = material
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.position = pos
	parent.add_child(mi)


func _add_collision(body: Destructible, node_name: String, size: Vector3, pos: Vector3) -> void:
	var cs := CollisionShape3D.new()
	cs.name = node_name
	cs.shape = _box_shape(size)
	cs.position = pos
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


## First mesh of an imported model, loaded once.
func _model_mesh(model_path: String) -> Mesh:
	if not _model_meshes.has(model_path):
		var scene: Node = (load(model_path) as PackedScene).instantiate()
		var mi: MeshInstance3D = scene.find_children("*", "MeshInstance3D", true, false)[0]
		_model_meshes[model_path] = mi.mesh
		scene.free()
	return _model_meshes[model_path]


## Toon material of kit buildings for one of the layout's palettes.
func _palette_material(index: int) -> ShaderMaterial:
	if not _palettes.has(index):
		var mat: ShaderMaterial = _material(Color.WHITE).duplicate()
		var paint: Dictionary = _layout["paint"]
		mat.set_shader_parameter("albedo_tex", load(_layout["palettes"][index]))
		mat.set_shader_parameter("ground_tint", float(paint["ground_tint"]))
		mat.set_shader_parameter("ground_tint_height", float(paint["ground_tint_height"]))
		_palettes[index] = mat
	return _palettes[index]


## Ruin material for a palette and cut height, shared by every ruin that matches.
func _ruin_material(palette: int, clip_y: float) -> ShaderMaterial:
	var key: String = "%d|%s" % [palette, clip_y]
	if not _ruins.has(key):
		var mat := ShaderMaterial.new()
		mat.shader = _ruin_shader
		mat.set_shader_parameter("albedo_tex", load(_layout["palettes"][palette]))
		mat.set_shader_parameter("clip_y", clip_y)
		mat.set_shader_parameter("band_threshold", float(_layout["toon"]["band_threshold"]))
		mat.set_shader_parameter("band_softness", float(_layout["toon"]["band_softness"]))
		_ruins[key] = mat
	return _ruins[key]


## Ground material with a tiled painted texture (key in the layout's "surfaces").
func _surface_material(key: String, color: Color) -> ShaderMaterial:
	var cache_key: String = "%s|%s" % [key, color]
	if not _surfaces.has(cache_key):
		var cfg: Dictionary = _layout["surfaces"][key]
		var mat: ShaderMaterial = _material(color).duplicate()
		mat.set_shader_parameter("world_tex", load(cfg["texture"]))
		mat.set_shader_parameter("world_tex_scale", float(cfg["scale"]))
		_surfaces[cache_key] = mat
	return _surfaces[cache_key]


## A decor type's mesh with toon materials. Colours come from the kit, or from the layout by
## material name; a "palette" gives the kit's texture recoloured instead.
func _decor_mesh(def: Dictionary) -> Mesh:
	var mesh: Mesh = _model_mesh(def["model"])
	if _decor_ready.has(def["model"]):
		return mesh
	_decor_ready[def["model"]] = true
	var colors: Dictionary = _layout["decor_colors"].duplicate()
	colors.merge(def.get("colors", {}), true)
	for s: int in mesh.get_surface_count():
		if def.has("palette"):
			mesh.surface_set_material(s, _palette_material(int(def["palette"])))
			continue
		var kit: StandardMaterial3D = mesh.surface_get_material(s)
		var color: Color = kit.albedo_color
		if colors.has(kit.resource_name):
			color = _color(colors[kit.resource_name])
		mesh.surface_set_material(s, _material(color))
	return mesh


func _v2(a: Array) -> Vector2:
	return Vector2(float(a[0]), float(a[1]))


func _v3(a: Array) -> Vector3:
	return Vector3(float(a[0]), float(a[1]), float(a[2]))


func _color(a: Array) -> Color:
	return Color(float(a[0]), float(a[1]), float(a[2]))
