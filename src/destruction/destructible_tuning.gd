class_name DestructibleTuning
extends Resource
## Tuning for one type of destructible object (one .tres per object type).
## Implements: design/game-brief.md, MVP feature 5 (story-004-destruicao-em-estagios).
## Edit the .tres, not the code.

## Total hits received for the object to change from INTACT to DAMAGED.
@export_range(1, 100) var hits_to_damaged: int = 2
## Total hits received (counted from the start, not from DAMAGED) for the object to become DESTROYED.
## Keep it greater than hits_to_damaged.
@export_range(1, 100) var hits_to_destroyed: int = 4
