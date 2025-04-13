class_name LevelInfo
extends Resource

@export var title: String
@export var enemies: Dictionary[PackedScene, int]
@export var map_x: Vector2i = Vector2i(10, 10)
@export var map_y: Vector2i = Vector2i(10, 10)


func get_enemy_count() -> int:
	var count = 0
	for enemy in enemies:
		count += enemies[enemy]
	return count
