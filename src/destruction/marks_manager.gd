class_name MarksManager
extends Node3D
## Leaves permanent marks for the session: a crater where a shell hits the ground, and a
## continuous smoke column on every damaged or destroyed Destructible.
## Implements: design/game-brief.md, MVP feature 6 (story-006-marcas-permanentes).
## Rubble is not made here: it is the Destroyed stage of the Destructible itself.
##
## Listens only; Cannon, Destructible and CityBuilder do not know this node. Craters are a
## ring of reused flat discs (cap in tuning); nothing fades with time. Smoke is one
## CPUParticles3D per Destructible, kept until the game closes. No save.
## Keep this node at the scene root's origin: marks are placed in world coordinates.

## Cannon whose impacts leave craters.
@export var cannon: Cannon
## Node whose descendants include the Destructibles (the City node, or the scene root).
## Destructibles that already exist are picked up at once; if it has a city_built signal,
## the scan repeats when it fires, so build order does not matter.
@export var container: Node
## Marks tuning (see marks_tuning.gd / marks_tuning.tres).
@export var tuning: MarksTuning

var _craters: Array[MeshInstance3D] = []
var _next_crater: int = 0
var _smokes: Dictionary[Destructible, CPUParticles3D] = {}
var _crater_mesh: CylinderMesh
var _smoke_mesh: QuadMesh
var _smoke_gradient: Gradient
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_crater_mesh = CylinderMesh.new()
	_crater_mesh.top_radius = 1.0
	_crater_mesh.bottom_radius = 1.0
	_crater_mesh.height = 0.01
	_crater_mesh.radial_segments = 16
	_crater_mesh.rings = 1
	var crater_material := StandardMaterial3D.new()
	crater_material.albedo_color = tuning.crater_color
	_crater_mesh.material = crater_material

	# A camera-facing quad with a soft round texture: 2 triangles per puff, for phones.
	_smoke_mesh = QuadMesh.new()
	var puff := Gradient.new()
	puff.set_color(0, Color.WHITE)
	puff.set_color(1, Color(Color.WHITE, 0.0))
	var puff_texture := GradientTexture2D.new()
	puff_texture.gradient = puff
	puff_texture.fill = GradientTexture2D.FILL_RADIAL
	puff_texture.fill_from = Vector2(0.5, 0.5)
	puff_texture.fill_to = Vector2(1.0, 0.5)
	var smoke_material := StandardMaterial3D.new()
	smoke_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	smoke_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smoke_material.vertex_color_use_as_albedo = true
	smoke_material.albedo_texture = puff_texture
	smoke_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	smoke_material.billboard_keep_scale = true
	_smoke_mesh.material = smoke_material
	_smoke_gradient = Gradient.new()
	_smoke_gradient.set_color(0, tuning.smoke_color)
	_smoke_gradient.set_color(1, Color(tuning.smoke_color, 0.0))

	cannon.projectile_impacted.connect(_on_projectile_impacted)
	_scan()
	if container.has_signal("city_built"):
		container.connect("city_built", _scan.unbind(1))


## Number of craters currently placed (never above tuning.crater_cap).
func get_crater_count() -> int:
	return _craters.size()


## Number of smoke emitters (one per Destructible that has left INTACT).
func get_smoke_count() -> int:
	return _smokes.size()


## Connects every Destructible under container not yet known, and starts smoke on those
## already damaged or destroyed.
func _scan() -> void:
	for node: Node in container.find_children("*", "Destructible", true, false):
		var obj := node as Destructible
		if obj.stage_changed.is_connected(_on_stage_changed):
			continue
		obj.stage_changed.connect(_on_stage_changed.bind(obj))
		if obj.get_stage() != Destructible.Stage.INTACT:
			_on_stage_changed(obj.get_stage(), obj)


func _on_projectile_impacted(position: Vector3, normal: Vector3, collider: Node3D) -> void:
	if not collider is StaticBody3D or collider is Destructible:
		return
	if normal.y < tuning.crater_min_normal_y:
		return
	var crater: MeshInstance3D
	if _craters.size() < tuning.crater_cap:
		crater = MeshInstance3D.new()
		crater.mesh = _crater_mesh
		add_child(crater)
		_craters.append(crater)
	else:
		crater = _craters[_next_crater]
		_next_crater = (_next_crater + 1) % _craters.size()
	var radius: float = _rng.randf_range(tuning.crater_radius_min, tuning.crater_radius_max)
	crater.scale = Vector3(radius, 1.0, radius)
	crater.global_position = position + Vector3.UP * tuning.crater_y_offset


func _on_stage_changed(new_stage: Destructible.Stage, obj: Destructible) -> void:
	var smoke: CPUParticles3D = _smokes.get(obj)
	if smoke == null:
		smoke = _make_smoke(obj)
		_smokes[obj] = smoke
	smoke.amount = tuning.smoke_amount_damaged \
		if new_stage == Destructible.Stage.DAMAGED else tuning.smoke_amount_destroyed
	# From the top of what is left, or the column would stay hidden inside a tall block.
	var stage: Node3D = obj.get_node("Damaged" if new_stage == Destructible.Stage.DAMAGED else "Destroyed")
	smoke.global_position = obj.global_position + Vector3.UP * (_top(obj, stage) + tuning.smoke_start_height)


func _make_smoke(obj: Destructible) -> CPUParticles3D:
	var footprint: Vector2 = _footprint(obj)
	var size: float = maxf(minf(footprint.x, footprint.y) * tuning.smoke_size_ratio, tuning.smoke_size_min)
	var smoke := CPUParticles3D.new()
	smoke.mesh = _smoke_mesh
	smoke.lifetime = tuning.smoke_lifetime
	smoke.local_coords = false
	smoke.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	smoke.emission_box_extents = Vector3(footprint.x, 0.0, footprint.y) * 0.5 * tuning.smoke_footprint_ratio
	smoke.direction = Vector3.UP
	smoke.spread = 10.0
	smoke.gravity = Vector3.ZERO
	smoke.initial_velocity_min = tuning.smoke_velocity_min
	smoke.initial_velocity_max = tuning.smoke_velocity_max
	smoke.scale_amount_min = size * 0.8
	smoke.scale_amount_max = size * 1.2
	smoke.color_ramp = _smoke_gradient
	smoke.emitting = true
	add_child(smoke)
	return smoke


## Height of the highest mesh of a stage above the object's origin, in metres.
func _top(obj: Destructible, stage: Node3D) -> float:
	var top: float = 0.0
	var to_object: Transform3D = obj.global_transform.affine_inverse()
	for node: Node in stage.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		top = maxf(top, (to_object * mi.global_transform * mi.get_aabb()).end.y)
	return top


## Ground footprint (x, z) of the object's Intact stage meshes, in metres.
func _footprint(obj: Destructible) -> Vector2:
	var box := AABB()
	var first: bool = true
	for node: Node in obj.get_node("Intact").find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var part: AABB = mi.transform * mi.get_aabb()
		box = part if first else box.merge(part)
		first = false
	return Vector2(box.size.x, box.size.z)
