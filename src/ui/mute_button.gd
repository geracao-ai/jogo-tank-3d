class_name MuteButton
extends Control
## On-screen mute toggle for touch: a round speaker icon drawn in code, in the top-right corner
## (clear of the tank and the bottom joysticks). Tapping it toggles AudioManager's mute.
## Implements: design/game-brief.md, MVP feature 7 (story-007-visual-ghibli-e-som).
## Reacts to touch only: on desktop a mouse click would also fire the cannon, and M mutes there.
## The mute state lives in AudioManager; this control only shows it and asks to toggle it.

## Audio manager whose mute state this shows and toggles.
@export var audio: AudioManager

var _tuning: AudioTuning


func _ready() -> void:
	_tuning = audio.tuning
	mouse_filter = Control.MOUSE_FILTER_STOP
	audio.mute_changed.connect(_on_mute_changed)
	get_viewport().size_changed.connect(_layout)
	_layout()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		accept_event()
		audio.toggle_mute()


func _draw() -> void:
	var c: Vector2 = size * 0.5
	var u: float = size.x
	var color: Color = _tuning.mute_icon_muted_color if audio.is_muted() else _tuning.mute_icon_color
	draw_circle(c, u * 0.5, _tuning.mute_button_background)
	# Speaker: a small box and a cone.
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-0.24, -0.1) * u, c + Vector2(-0.12, -0.1) * u, c + Vector2(0.02, -0.22) * u,
		c + Vector2(0.02, 0.22) * u, c + Vector2(-0.12, 0.1) * u, c + Vector2(-0.24, 0.1) * u]), color)
	if audio.is_muted():
		draw_line(c + Vector2(0.1, -0.12) * u, c + Vector2(0.3, 0.12) * u, color, u * 0.05)
		draw_line(c + Vector2(0.1, 0.12) * u, c + Vector2(0.3, -0.12) * u, color, u * 0.05)
	else:
		draw_arc(c + Vector2(0.02, 0.0) * u, u * 0.16, -0.9, 0.9, 12, color, u * 0.04)
		draw_arc(c + Vector2(0.02, 0.0) * u, u * 0.26, -0.9, 0.9, 12, color, u * 0.04)


func _layout() -> void:
	var view: Vector2 = get_viewport().get_visible_rect().size
	var side: float = _tuning.mute_button_size * view.y
	size = Vector2(side, side)
	position = Vector2(view.x - side - _tuning.mute_button_margin * view.y, _tuning.mute_button_margin * view.y)
	queue_redraw()


func _on_mute_changed(_muted: bool) -> void:
	queue_redraw()
