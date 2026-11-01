class_name Cannon
extends Node3D
## Tank cannon: the turret (this node) yaws and the Pitch child pitches toward the aim point,
## independent of hull heading; fires projectiles along the barrel.
## Implements: design/game-brief.md, MVP feature 4 (story-003-canhao-mira-disparo).
## Aim: each physics tick a ray from the active camera through the mouse position; the first
## hit is the aim point (or a point aim_ray_length away). The barrel turns toward it at
## tuning.turn_speed, so the shot follows the BARREL, which may lag the cursor.
## Touch: set_manual_turn() turns the turret directly instead, ignoring the mouse, and the
## crosshair then shows where the barrel points.
## Controls: left mouse button / Space / gamepad right shoulder. Read in _physics_process, so a paused
## tree never fires.

## Re-emitted from every projectile this cannon fired, so a listener (story 004) connects once
## here instead of to short-lived projectiles. Never emitted for a shot that only reaches range.
signal projectile_impacted(position: Vector3, normal: Vector3, collider: Node3D)
## Emitted each time the cannon fires, before the shell (or the point-blank hit) resolves.
signal fired

## Tuning resource (see cannon_tuning.gd / cannon_tuning.tres).
@export var tuning: CannonTuning
## Scene of the shell (root script: Projectile).
@export var projectile_scene: PackedScene

var _cooldown: float = 0.0
var _manual: bool = false
var _manual_turn: Vector2

@onready var _tank: CollisionObject3D = get_parent()
@onready var _pitch: Node3D = $Pitch
@onready var _muzzle: Node3D = $Pitch/Muzzle


func _ready() -> void:
	_register_input_actions()


func _physics_process(delta: float) -> void:
	if _manual:
		_turn_manually(delta)
	else:
		_aim(_find_aim_point(), delta)
	_cooldown = maxf(_cooldown - delta, 0.0)
	if _cooldown <= 0.0 and Input.is_action_pressed("cannon_fire"):
		_fire()


## Turns the turret directly, from now on ignoring the mouse. [param turn] is -1..1 of
## tuning.turn_speed: x positive turns right, y positive raises the barrel.
func set_manual_turn(turn: Vector2) -> void:
	_manual = true
	_manual_turn = turn


## Barrel elevation in radians: 0 is level, positive is up.
func get_barrel_pitch() -> float:
	return _pitch.rotation.x


## False when the barrel points behind the camera, where no crosshair can show it.
func is_aim_on_screen() -> bool:
	return not _manual or not get_viewport().get_camera_3d().is_position_behind(_barrel_point())


## Screen position (viewport pixels) of the aim: where the barrel points under manual turn,
## else the mouse cursor.
func get_aim_screen_position() -> Vector2:
	if _manual:
		return get_viewport().get_camera_3d().unproject_position(_barrel_point())
	return get_viewport().get_mouse_position()


func _turn_manually(delta: float) -> void:
	var step: float = deg_to_rad(tuning.turn_speed) * delta
	rotation.y -= _manual_turn.x * step
	_pitch.rotation.x = clampf(_pitch.rotation.x + _manual_turn.y * step,
		deg_to_rad(tuning.pitch_min), deg_to_rad(tuning.pitch_max))


## First surface along the barrel (tank excluded), or the end of the shell's range.
func _barrel_point() -> Vector3:
	var from: Vector3 = _pitch.global_position
	var to: Vector3 = from - _muzzle.global_basis.z * tuning.max_range
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [_tank.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return hit.position if not hit.is_empty() else to


## World point under the aim screen position (first surface hit, tank excluded).
func _find_aim_point() -> Vector3:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var mouse: Vector2 = get_aim_screen_position()
	var from: Vector3 = camera.project_ray_origin(mouse)
	var to: Vector3 = from + camera.project_ray_normal(mouse) * tuning.aim_ray_length
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [_tank.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return hit.position if not hit.is_empty() else to


func _aim(point: Vector3, delta: float) -> void:
	var step: float = deg_to_rad(tuning.turn_speed) * delta
	var dir: Vector3 = (point - global_position).normalized()
	# Yaw in the hull's frame, so the turret turns relative to a rotating hull.
	var local_dir: Vector3 = get_parent_node_3d().global_basis.inverse() * dir
	var want_yaw: float = atan2(-local_dir.x, -local_dir.z)
	rotation.y += clampf(angle_difference(rotation.y, want_yaw), -step, step)
	var want_pitch: float = clampf(
		atan2(dir.y, Vector2(dir.x, dir.z).length()),
		deg_to_rad(tuning.pitch_min), deg_to_rad(tuning.pitch_max))
	_pitch.rotation.x = move_toward(_pitch.rotation.x, want_pitch, step)


func _fire() -> void:
	_cooldown = tuning.reload_interval
	fired.emit()
	var exclude: Array[RID] = [_tank.get_rid()]
	# The barrel can poke through a wall the tank touches, and a shell's ray starting inside a
	# body misses it, so the shot resolves here when something is between pivot and muzzle.
	var query := PhysicsRayQueryParameters3D.create(_pitch.global_position, _muzzle.global_position)
	query.exclude = exclude
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		projectile_impacted.emit(hit.position, hit.normal, hit.collider)
		return
	var shell: Projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(shell)
	shell.launch(_muzzle.global_position, -_muzzle.global_basis.z * tuning.projectile_speed, tuning, exclude)
	shell.impacted.connect(projectile_impacted.emit)


func _register_input_actions() -> void:
	if InputMap.has_action("cannon_fire"):
		return
	InputMap.add_action("cannon_fire", 0.2)
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("cannon_fire", mouse)
	var key := InputEventKey.new()
	key.physical_keycode = KEY_SPACE
	InputMap.action_add_event("cannon_fire", key)
	var pad := InputEventJoypadButton.new()
	pad.button_index = JOY_BUTTON_RIGHT_SHOULDER
	InputMap.action_add_event("cannon_fire", pad)
