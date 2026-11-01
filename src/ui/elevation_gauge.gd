class_name ElevationGauge
extends Control
## Small icon of the tank seen from the side, with the barrel drawn at its real elevation.
## Display only; sits beside the mute button. Implements: story-005b-controles-de-toque.

## Cannon whose barrel elevation is shown.
var cannon: Cannon
## Background disc colour.
var background: Color
## Tank drawing colour.
var color: Color


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var radius: float = size.x * 0.5
	var center: Vector2 = size * 0.5
	draw_circle(center, radius, background)
	var stroke: float = radius * 0.14
	# Side view: hull, turret, and the barrel from the turret pivot at the real angle.
	var pivot: Vector2 = center + Vector2(-0.2, 0.05) * radius
	var hull := Rect2(center + Vector2(-0.62, 0.22) * radius, Vector2(1.1, 0.3) * radius)
	draw_rect(hull, color)
	draw_rect(Rect2(pivot + Vector2(-0.28, -0.05) * radius, Vector2(0.5, 0.27) * radius), color)
	var pitch: float = cannon.get_barrel_pitch()
	draw_line(pivot, pivot + Vector2(cos(pitch), -sin(pitch)) * radius * 0.82, color, stroke)
