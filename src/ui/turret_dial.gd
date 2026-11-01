class_name TurretDial
extends Control
## Compass marker on the aim joystick's ring: shows where the turret points relative to the
## tank's front (top of the ring = ahead, right = right, bottom = behind). Display only.
## Implements: design/game-brief.md, post-MVP (story-005b-controles-de-toque).

## Cannon whose turret angle is shown.
var cannon: Cannon
## Ring radius in pixels; the marker sits on it.
var radius: float
## Marker radius in pixels.
var marker_radius: float
## Marker colour.
var color: Color


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	queue_redraw()


## Marker centre in local pixels for the current turret angle.
func get_marker_position() -> Vector2:
	var yaw: float = cannon.get_turret_yaw()
	return size * 0.5 + Vector2(-sin(yaw), -cos(yaw)) * radius


func _draw() -> void:
	draw_circle(get_marker_position(), marker_radius, color)
