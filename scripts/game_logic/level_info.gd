class_name LevelInfo
extends Resource

@export var title: String
@export var enemies: Dictionary[PackedScene, int]

func get_enemy_count() -> int:
	var count = 0
	for enemy in enemies:
		count += enemies[enemy]
	return count
