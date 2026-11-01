class_name DestructionRouter
extends Node
## Connects a Cannon's impact signal to Destructible.take_hit(), so neither knows the other.
## Implements: design/game-brief.md, MVP feature 5 (story-004-destruicao-em-estagios).

## Cannon whose impacts are routed.
@export var cannon: Cannon


func _ready() -> void:
	cannon.projectile_impacted.connect(_on_projectile_impacted)


func _on_projectile_impacted(position: Vector3, _normal: Vector3, collider: Node3D) -> void:
	if collider is Destructible:
		(collider as Destructible).take_hit()
	elif collider is CityProp:
		(collider as CityProp).take_hit(position)
