class_name Crosshair
extends Control
## Crosshair drawn at the cannon's aim screen position: the mouse cursor on desktop, where the
## barrel points under touch controls (see Cannon). Hidden when the barrel points behind the
## camera. The OS cursor is hidden while it exists. Without a cannon it follows the mouse.
## Implements: design/game-brief.md, MVP feature 4 (story-003-canhao-mira-disparo).

## Cannon whose aim screen position is drawn. Optional; the mouse position is used when unset.
@export var cannon: Cannon
## Colour of the lines.
@export var color: Color = Color(1, 1, 1, 0.9)
## Gap between the centre and each line (pixels).
@export var gap: float = 5.0
## Length of each line (pixels).
@export var length: float = 10.0
## Line thickness (pixels).
@export var thickness: float = 2.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var c: Vector2 = get_local_mouse_position()
	if cannon:
		if not cannon.is_aim_on_screen():
			return
		c = get_global_transform_with_canvas().affine_inverse() * cannon.get_aim_screen_position()
	for dir: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		draw_line(c + dir * gap, c + dir * (gap + length), color, thickness)
