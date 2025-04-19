class_name LevelInfo
extends Resource


@export var title: String
@export var level_range: Vector2i
@export var enemies: Dictionary[PackedScene, Vector2i]
@export var map_x: Vector2i = Vector2i(10, 10)
@export var map_y: Vector2i = Vector2i(10, 10)


var _title: String
var _enemies: Dictionary[PackedScene, int]
var _map_x: int
var _map_y: int


func get_enemy_count() -> int:
	var count = 0
	for enemy in _enemies:
		count += _enemies[enemy]
	return count


func generate_level(index: int) -> void:
	print("LevelInfo: Generate level")
	_title = title + str(index)
	_map_x = randi_range(map_x[0], map_x[1])
	_map_y = randi_range(map_y[0], map_y[1])
	
	_enemies.clear()
	for enemy in enemies:
		var count = randi_range(enemies[enemy][0], enemies[enemy][1])
		_enemies[enemy] = count
		assert(count != 0)
