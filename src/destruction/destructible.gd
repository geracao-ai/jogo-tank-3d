class_name Destructible
extends StaticBody3D
## Reusable staged destructible (building, shop, bank, lamp post...).
## Implements: design/game-brief.md, MVP feature 5 (story-004-destruicao-em-estagios).
##
## Authoring: make a scene whose root is a StaticBody3D with this script and a tuning set.
## Give it three direct Node3D children named exactly Intact, Damaged and Destroyed, each holding
## that stage's MeshInstance3D(s). Collision goes separately: every CollisionShape3D must be a
## DIRECT child of the root, because a shape only registers with a CollisionObject3D that is its
## direct parent (one nested under a stage node gives the body no collision and no error).
## A shape belongs to a stage by name prefix: IntactCollision, DamagedCollision, DestroyedCollision.
## Extra shapes keep the prefix (IntactCollision2, the name the editor gives a duplicate). A stage
## may have no shape. A shape matching no prefix stays disabled in every stage.
## Changing stage swaps at once: the active stage is shown with its shapes enabled, the other two
## are hidden with their shapes disabled. No fracture, animation or debris.
## To reuse: duplicate the scene, swap the meshes/shapes, and point tuning at another .tres.
## Destroyed stage: normally give it NO shape, so the tank drives over the rubble instead of
## snagging on low boxes (the rubble is visual only, and shells pass through it).
## Routing: a DestructionRouter calls take_hit(); this class knows nothing about the cannon.

enum Stage { INTACT, DAMAGED, DESTROYED }

## Emitted after the stage changes (never for the initial INTACT, never for hits that change nothing).
signal stage_changed(new_stage: Stage)

## Hits needed per stage (see destructible_tuning.gd).
@export var tuning: DestructibleTuning

var _stage: Stage = Stage.INTACT
var _hits: int = 0

@onready var _stage_nodes: Dictionary[Stage, Node3D] = {
	Stage.INTACT: $Intact,
	Stage.DAMAGED: $Damaged,
	Stage.DESTROYED: $Destroyed,
}


func _ready() -> void:
	_show_stage(_stage)


## Current stage.
func get_stage() -> Stage:
	return _stage


## Registers one hit. Advances the stage when a threshold in tuning is reached.
## Does nothing once DESTROYED.
func take_hit() -> void:
	if _stage == Stage.DESTROYED:
		return
	_hits += 1
	var target: Stage = _stage
	if _hits >= tuning.hits_to_destroyed:
		target = Stage.DESTROYED
	elif _hits >= tuning.hits_to_damaged:
		target = Stage.DAMAGED
	if target != _stage:
		_stage = target
		_show_stage(_stage)
		stage_changed.emit(_stage)


func _show_stage(active: Stage) -> void:
	for stage: Stage in _stage_nodes:
		_stage_nodes[stage].visible = stage == active
	var prefix: String = _stage_nodes[active].name + "Collision"
	for child: Node in get_children():
		if child is CollisionShape3D:
			# Deferred: take_hit() runs inside the physics step (projectile ray query).
			child.set_deferred("disabled", not child.name.begins_with(prefix))
