class_name MapGenerator
extends Node2D

var map_size: Vector2i = Vector2i(10, 10)
var map: Map
# enemy scene: enemies count
var enemies_info: Dictionary[PackedScene, int] = { }


func set_enemies_info(data: Dictionary[PackedScene, int]) -> void:
	enemies_info = data


func set_map_data(map_x: int, map_y: int) -> void:
	map_size = Vector2i(map_x, map_y)


func generate_empty_map(map_ref: Map, size: Vector2i, enemies_data: Dictionary[PackedScene, int]) -> void:
	map = map_ref
	map.reset_map()
	map_size = size
	map.size = map_size
	enemies_info = enemies_data

	var map_data: Array[Array] = []
	for x in range(map_size.x):
		map_data.append([])
		for y in range(map_size.y):
			var tile_data: Map.MapTileData = Map.MapTileData.new()
			map_data[x].append(tile_data)

	map.set_map_data(map_data)
	map.update_visual_map()


func populate_map(map_ref: Map, start_pos: Vector2i) -> void:
	map = map_ref
	if map.is_pos_valid(start_pos) == false:
		return

	map.create_enemy_collection(enemies_info.keys())
	spawn_enemies(start_pos)


func spawn_enemies(start_pos: Vector2i) -> void:
	var excluded_tiles = map.get_neighbour_cells(start_pos)
	excluded_tiles.append(start_pos)

	var all_empty_tiles = map.get_empty_cells()
	for excluded_tile in excluded_tiles:
		all_empty_tiles.erase(excluded_tile)

	var total_enemy_count: int = 0
	for count in enemies_info.values():
		total_enemy_count += count
	assert(all_empty_tiles.size() > total_enemy_count)

	for enemy_scene in enemies_info:
		var enemy_count = enemies_info[enemy_scene]
		for i: int in range(0, enemy_count):
			# TODO: change random here
			var random_pos = all_empty_tiles.pick_random()
			all_empty_tiles.erase(random_pos)
			map.add_enemy(random_pos, enemy_scene)
