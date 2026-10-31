class_name Tank
extends CharacterBody3D
## Drivable tank: gradual acceleration, brake, reverse, speed-dependent turning.
## Implements: design/game-brief.md, build order 1 (story-001-tanque-dirigivel).
## Arcade model on CharacterBody3D (not a rigid-body vehicle) for predictable feel.
## Controls: WASD / arrows, Space = brake; gamepad left stick, RT/LT, A = brake.
## No hover/mouse needed (web target).

## Emitted every physics frame with signed forward speed (m/s); for later HUD/camera.
signal speed_changed(forward_speed: float)

## Tuning resource (see tank_tuning.gd / tank_tuning.tres).
@export var tuning: TankTuning

var _forward_speed: float = 0.0
var _turn_rate: float = 0.0 # rad/s, smoothed


func _ready() -> void:
	_register_input_actions()


func _physics_process(delta: float) -> void:
	var throttle: float = Input.get_action_strength("tank_forward") - Input.get_action_strength("tank_back")
	var steer: float = Input.get_axis("tank_right", "tank_left")
	var braking: bool = Input.is_action_pressed("tank_brake")

	_forward_speed = _update_speed(throttle, braking, delta)

	# Turn rate shrinks with speed, and eases toward the target so the hull has weight.
	var speed_ratio: float = clampf(absf(_forward_speed) / tuning.max_forward_speed, 0.0, 1.0)
	var max_rate: float = deg_to_rad(lerpf(tuning.turn_rate_standstill, tuning.turn_rate_full_speed, speed_ratio))
	_turn_rate = lerpf(_turn_rate, steer * max_rate, 1.0 - exp(-tuning.turn_response * delta))
	rotate_y(_turn_rate * delta)

	var forward: Vector3 = -global_transform.basis.z
	velocity.x = forward.x * _forward_speed
	velocity.z = forward.z * _forward_speed
	velocity.y = 0.0 if is_on_floor() else velocity.y + get_gravity().y * delta
	move_and_slide()
	speed_changed.emit(_forward_speed)


## Returns the new signed forward speed for this frame.
func _update_speed(throttle: float, braking: bool, delta: float) -> float:
	var speed: float = _forward_speed
	var opposes: bool = throttle != 0.0 and speed != 0.0 and signf(throttle) != signf(speed)
	if braking or opposes:
		speed = move_toward(speed, 0.0, tuning.brake_deceleration * delta)
	elif throttle > 0.0:
		speed = move_toward(speed, tuning.max_forward_speed * throttle, tuning.acceleration * delta)
	elif throttle < 0.0:
		speed = move_toward(speed, tuning.max_reverse_speed * throttle, tuning.acceleration * delta)
	else:
		speed = move_toward(speed, 0.0, tuning.coast_deceleration * delta)
	return speed


func _register_input_actions() -> void:
	_add_action("tank_forward", [_key(KEY_W), _key(KEY_UP), _axis(JOY_AXIS_TRIGGER_RIGHT, 1.0), _axis(JOY_AXIS_LEFT_Y, -1.0)])
	_add_action("tank_back", [_key(KEY_S), _key(KEY_DOWN), _axis(JOY_AXIS_TRIGGER_LEFT, 1.0), _axis(JOY_AXIS_LEFT_Y, 1.0)])
	_add_action("tank_left", [_key(KEY_A), _key(KEY_LEFT), _axis(JOY_AXIS_LEFT_X, -1.0)])
	_add_action("tank_right", [_key(KEY_D), _key(KEY_RIGHT), _axis(JOY_AXIS_LEFT_X, 1.0)])
	_add_action("tank_brake", [_key(KEY_SPACE), _button(JOY_BUTTON_A)])


func _add_action(action: StringName, events: Array[InputEvent]) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action, 0.2)
	for event: InputEvent in events:
		InputMap.action_add_event(action, event)


func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	return e


func _axis(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var e := InputEventJoypadMotion.new()
	e.axis = axis
	e.axis_value = value
	return e


func _button(index: JoyButton) -> InputEventJoypadButton:
	var e := InputEventJoypadButton.new()
	e.button_index = index
	return e
