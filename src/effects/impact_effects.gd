class_name ImpactEffects
extends Node3D
## Short explosion at every shell impact: a brief flash plus a few smoke puffs.
## Implements: design/game-brief.md, MVP feature 7 (story-007-visual-ghibli-e-som).
##
## Listens only to Cannon.projectile_impacted; it does not know the destruction systems.
## Everything is pooled: tuning.pool_size flash quads and puff emitters are built once, and
## a new impact past the cap restarts the oldest one, so cost has a fixed ceiling.
## Keep this node at the scene root's origin: effects are placed in world coordinates.

## Cannon whose impacts spawn explosions.
@export var cannon: Cannon
## Effect tuning (see impact_effects_tuning.gd / impact_effects_tuning.tres).
@export var tuning: ImpactEffectsTuning

var _flashes: Array[MeshInstance3D] = []
var _puffs: Array[CPUParticles3D] = []
var _ages: PackedFloat32Array = PackedFloat32Array()
var _next: int = 0


func _ready() -> void:
	var texture := GradientTexture2D.new()
	var soft := Gradient.new()
	soft.set_color(0, Color.WHITE)
	soft.set_color(1, Color(Color.WHITE, 0.0))
	texture.gradient = soft
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)

	var quad := QuadMesh.new()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	material.albedo_texture = texture
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.billboard_keep_scale = true
	quad.material = material

	var flash_material: StandardMaterial3D = material.duplicate()
	flash_material.albedo_color = tuning.flash_color
	flash_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	var flash_quad := QuadMesh.new()
	flash_quad.material = flash_material

	var ramp := Gradient.new()
	ramp.set_color(0, tuning.puff_color)
	ramp.set_color(1, Color(tuning.puff_color, 0.0))

	for i: int in tuning.pool_size:
		var flash := MeshInstance3D.new()
		flash.mesh = flash_quad
		flash.visible = false
		add_child(flash)
		_flashes.append(flash)
		var puffs := CPUParticles3D.new()
		puffs.mesh = quad
		puffs.one_shot = true
		puffs.explosiveness = 1.0
		puffs.emitting = false
		puffs.amount = tuning.puff_count
		puffs.lifetime = tuning.puff_lifetime
		puffs.local_coords = false
		puffs.spread = 70.0
		puffs.gravity = Vector3.UP * tuning.puff_rise
		puffs.initial_velocity_min = tuning.puff_speed_min
		puffs.initial_velocity_max = tuning.puff_speed_max
		puffs.scale_amount_min = tuning.puff_size_min
		puffs.scale_amount_max = tuning.puff_size_max
		puffs.color_ramp = ramp
		add_child(puffs)
		_puffs.append(puffs)
	_ages.resize(tuning.pool_size)
	_ages.fill(-1.0)
	set_process(false)
	cannon.projectile_impacted.connect(_on_projectile_impacted)


## Number of explosions whose flash is still showing (never above tuning.pool_size).
func get_active_count() -> int:
	var count: int = 0
	for age: float in _ages:
		if age >= 0.0:
			count += 1
	return count


func _process(delta: float) -> void:
	var any: bool = false
	for i: int in _flashes.size():
		if _ages[i] < 0.0:
			continue
		_ages[i] += delta
		var t: float = _ages[i] / tuning.flash_duration
		if t >= 1.0:
			_ages[i] = -1.0
			_flashes[i].visible = false
			continue
		any = true
		var peak: float = tuning.flash_peak_time
		var grow: float = t / peak if t < peak else (1.0 - t) / (1.0 - peak)
		_flashes[i].scale = Vector3.ONE * tuning.flash_size * grow
	set_process(any)


func _on_projectile_impacted(position: Vector3, normal: Vector3, _collider: Node3D) -> void:
	var at: Vector3 = position + normal * tuning.surface_offset
	var i: int = _next
	_next = (_next + 1) % _flashes.size()
	_flashes[i].global_position = at
	_flashes[i].scale = Vector3.ZERO
	_flashes[i].visible = true
	_ages[i] = 0.0
	var puffs: CPUParticles3D = _puffs[i]
	puffs.global_position = at
	puffs.direction = normal
	puffs.restart()
	puffs.emitting = true
	set_process(true)
