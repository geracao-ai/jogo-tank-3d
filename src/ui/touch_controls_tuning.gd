class_name TouchControlsTuning
extends Resource
## Tuning values for the on-screen touch controls (sizes, positions, sensitivity).
## Implements: design/game-brief.md, post-MVP (story-005b-controles-de-toque).
## Sizes and margins are fractions of the viewport HEIGHT and positions are fractions of the
## viewport, so any canvas size works. Edit the .tres, not the code.

## Distance from the screen edges to the controls (fraction of viewport height).
@export_range(0.0, 0.2, 0.005) var edge_margin: float = 0.05
## Diameter of both joysticks (fraction of viewport height).
@export_range(0.1, 0.8, 0.005) var joystick_diameter: float = 0.4
## Joystick tip diameter, relative to the joystick diameter.
@export_range(0.1, 1.0, 0.01) var joystick_tip_ratio: float = 0.45
## Joystick dead zone (fraction of its radius) below which no action is pressed.
@export_range(0.0, 0.5, 0.01) var joystick_deadzone: float = 0.1
## Diameter of both fire buttons (fraction of viewport height).
@export_range(0.05, 0.6, 0.005) var fire_diameter: float = 0.18
## Gap between each joystick and the fire button above it (fraction of viewport height).
@export_range(0.0, 0.2, 0.005) var button_gap: float = 0.03
## Fill colour of the buttons when idle.
@export var button_color: Color = Color(1, 1, 1, 0.25)
## Fill colour of the buttons while pressed.
@export var button_pressed_color: Color = Color(1, 1, 1, 0.5)
## Turret speed with the right joystick fully pushed, as a fraction of the cannon's turn_speed.
@export_range(0.05, 1.0, 0.05) var turret_speed: float = 0.6
## Barrel elevation gauge side (fraction of viewport height).
@export_range(0.03, 0.3, 0.005) var gauge_size: float = 0.14
## Gauge distance from the top edge (fraction of viewport height).
@export_range(0.0, 0.2, 0.005) var gauge_top_margin: float = 0.03
## Gauge distance from the right edge: leaves room for the mute button (fraction of viewport height).
@export_range(0.0, 0.6, 0.005) var gauge_right_offset: float = 0.19
## Gauge background disc and tank drawing colours.
@export var gauge_background: Color = Color(1, 1, 1, 0.3)
@export var gauge_color: Color = Color(0.25, 0.3, 0.4, 0.9)
