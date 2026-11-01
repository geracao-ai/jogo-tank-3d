class_name TouchControls
extends CanvasLayer
## On-screen touch controls: left joystick drives the tank, right joystick turns the cannon,
## and a fire button sits above each joystick. Braking is the left joystick pushed the opposite
## way, which Tank already does.
## Implements: design/game-brief.md, post-MVP (story-005b-controles-de-toque).
## Reuses the existing input actions (tank_*, cannon_fire), so Tank and Cannon keep one input
## path. Only shown on touchscreen devices; elsewhere the node frees itself and nothing changes.

const AIM_LEFT: StringName = &"touch_aim_left"
const AIM_RIGHT: StringName = &"touch_aim_right"
const AIM_UP: StringName = &"touch_aim_up"
const AIM_DOWN: StringName = &"touch_aim_down"

## Tuning resource (see touch_controls_tuning.gd / touch_controls_tuning.tres).
@export var tuning: TouchControlsTuning
## Cannon the right joystick turns.
@export var cannon: Cannon
## Show the controls even without a touchscreen (desktop verification only).
@export var force_visible: bool = false

var _dial: TurretDial

@onready var _drive_joystick: VirtualJoystick = $DriveJoystick
@onready var _aim_joystick: VirtualJoystick = $AimJoystick
@onready var _left_fire: TouchScreenButton = $LeftFireButton
@onready var _right_fire: TouchScreenButton = $RightFireButton


func _ready() -> void:
	if not (force_visible or DisplayServer.is_touchscreen_available()):
		# _process reads aim actions that are only registered below.
		process_mode = Node.PROCESS_MODE_DISABLED
		queue_free()
		return
	for action: StringName in [AIM_LEFT, AIM_RIGHT, AIM_UP, AIM_DOWN]:
		if not InputMap.has_action(action):
			# Dead zone 0: the joystick applies its own, and get_vector would add a second one.
			InputMap.add_action(action, 0.0)
	_bind_joystick(_drive_joystick, &"tank_left", &"tank_right", &"tank_forward", &"tank_back")
	_bind_joystick(_aim_joystick, AIM_LEFT, AIM_RIGHT, AIM_UP, AIM_DOWN)
	_left_fire.action = &"cannon_fire"
	_right_fire.action = &"cannon_fire"
	# Both buttons share one action, and releasing either one clears it.
	_left_fire.released.connect(_keep_firing.bind(_right_fire))
	_right_fire.released.connect(_keep_firing.bind(_left_fire))
	cannon.set_manual_turn(Vector2.ZERO)
	_dial = TurretDial.new()
	_dial.cannon = cannon
	_dial.color = tuning.dial_color
	_aim_joystick.add_child(_dial)
	get_viewport().size_changed.connect(_layout)
	_layout()


func _process(_delta: float) -> void:
	var push: Vector2 = Input.get_vector(AIM_LEFT, AIM_RIGHT, AIM_UP, AIM_DOWN)
	cannon.set_manual_turn(Vector2(push.x, -push.y) * tuning.turret_speed)


func _keep_firing(other: TouchScreenButton) -> void:
	if other.is_pressed():
		Input.action_press(&"cannon_fire")


func _bind_joystick(joystick: VirtualJoystick, left: StringName, right: StringName, up: StringName, down: StringName) -> void:
	joystick.action_left = left
	joystick.action_right = right
	joystick.action_up = up
	joystick.action_down = down
	joystick.deadzone_ratio = tuning.joystick_deadzone


func _layout() -> void:
	var size: Vector2 = get_viewport().get_visible_rect().size
	var unit: float = size.y
	var margin: float = tuning.edge_margin * unit
	var joy: float = tuning.joystick_diameter * unit
	var fire: float = tuning.fire_diameter * unit
	var joy_top: float = size.y - margin - joy
	var fire_top: float = joy_top - tuning.button_gap * unit - fire

	_place_joystick(_drive_joystick, Vector2(margin, joy_top), joy)
	_place_joystick(_aim_joystick, Vector2(size.x - margin - joy, joy_top), joy)
	_dial.size = Vector2(joy, joy)
	_dial.radius = joy * 0.5
	_dial.marker_radius = joy * tuning.dial_marker_ratio
	# Each fire button is centred above its joystick.
	_place_button(_left_fire, fire, Vector2(margin + (joy - fire) * 0.5, fire_top))
	_place_button(_right_fire, fire, Vector2(size.x - margin - joy + (joy - fire) * 0.5, fire_top))


func _place_joystick(joystick: VirtualJoystick, top_left: Vector2, diameter: float) -> void:
	joystick.position = top_left
	joystick.size = Vector2(diameter, diameter)
	joystick.joystick_size = int(diameter)
	joystick.tip_size = int(diameter * tuning.joystick_tip_ratio)


func _place_button(button: TouchScreenButton, diameter: float, top_left: Vector2) -> void:
	var radius: float = diameter * 0.5
	button.texture_normal = _make_disc(int(diameter), tuning.button_color)
	button.texture_pressed = _make_disc(int(diameter), tuning.button_pressed_color)
	var shape := CircleShape2D.new()
	shape.radius = radius
	button.shape = shape
	button.shape_centered = true
	button.position = top_left


## Flat filled circle texture (placeholder look, no art assets).
func _make_disc(diameter: int, color: Color) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.98, 1.0])
	gradient.colors = PackedColorArray([color, color, Color(color, 0.0)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = diameter
	texture.height = diameter
	return texture
