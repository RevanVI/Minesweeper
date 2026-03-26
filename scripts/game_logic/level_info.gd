class_name LevelInfo
extends Resource


@export var title: String
@export var level_range: Vector2i
@export var enemies: Dictionary[PackedScene, Vector2i]
@export var map_x: Vector2i = Vector2i(10, 10)
@export var map_y: Vector2i = Vector2i(10, 10)

var _enemies: Dictionary[PackedScene, int]
var map_size: Vector2i


func get_enemy_count() -> int:
	var count = 0
	for enemy in _enemies:
		count += _enemies[enemy]
	return count


func get_enemies_data() -> Dictionary[PackedScene, int]:
	return _enemies


func generate_level(index: int) -> void:
	print("LevelInfo: Generate level")
	title = title + str(index)
	# TODO: make random generator with seed input?
	var x: int = randi_range(map_x[0], map_x[1])
	var y: int = randi_range(map_y[0], map_y[1])
	map_size = Vector2i(x, y)
	
	_enemies.clear()
	for enemy in enemies:
		var count = randi_range(enemies[enemy][0], enemies[enemy][1])
		_enemies[enemy] = count
		assert(count != 0)
