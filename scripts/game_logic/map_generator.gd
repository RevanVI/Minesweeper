class_name MapGenerator
extends Node2D


var map_size: Vector2i = Vector2i(10, 10)
var map: Map
var enemies_info: Dictionary[PackedScene, int] = {}
var _enemy_id: Dictionary[PackedScene, int] = {}


func set_enemies_info(data: Dictionary[PackedScene, int]) -> void:
	enemies_info = data


func set_map_data(map_x_limits: Vector2i, map_y_limits: Vector2i) -> void:
	var x = randi_range(map_x_limits[0], map_x_limits[1])
	var y = randi_range(map_y_limits[0], map_y_limits[1])
	map_size = Vector2i(x, y)


func generate_empty_map(map_ref: Map) -> void:
	map = map_ref
	map.size = map_size
	map.reset_board()
	map.reset_cells()


func fill_map(map_ref: Map, start_pos: Vector2i) -> void:
	map = map_ref
	if map.is_pos_on_board(start_pos) == false:
		return
	
	_enemy_id.clear()
	var enemy_scene_collection = map.board.tile_set\
		.get_source(map.ENEMY_COLLECTION_ID) \
		as TileSetScenesCollectionSource 
	for enemy_scene in enemies_info.keys():
		var new_id = enemy_scene_collection.create_scene_tile(enemy_scene)
		_enemy_id[enemy_scene] = new_id

	spawn_enemies(start_pos)
	
	print(map._enemies)


func spawn_enemies(start_pos: Vector2i) -> void:
	var excluded_tiles = map.get_neighbour_cells(start_pos)
	excluded_tiles.append(start_pos)
	
	var all_empty_tiles = map.board.get_used_cells_by_id(0, map.empty_tiles[0])
	
	for enemy_scene in enemies_info:
		var enemy_count = enemies_info[enemy_scene]
		
		for i in range(0, enemy_count):
			var random_pos = all_empty_tiles.pick_random()
			all_empty_tiles.erase(random_pos)
			if random_pos in excluded_tiles:
				continue
			if is_tile_mine_valid(random_pos):
				spawn_enemy_at_pos(random_pos, enemy_scene)


func is_tile_mine_valid(pos) -> bool:
	return map.is_cell_empty(pos)


func spawn_enemy_at_pos(pos, enemy_scene: PackedScene) -> void:
	#print("set cell here")
	var enemy_collection_id = _enemy_id[enemy_scene]
	map.board.set_cell(pos, map.ENEMY_COLLECTION_ID, Vector2i(0, 0), enemy_collection_id)
	
	#tilemap updates at the end of the frame
	#this mean that _ready() on spawned scene will be called only then
	#direct call update_internals() forcing tilemap update
	#this can cause problems on big maps 
	#TODO: check on big map, make it better and frame independent?
	map.board.update_internals()
	
	var last_ind = map.board.get_child_count()
	var child_scene = map.board.get_children()[last_ind - 1] as Enemy
	map._enemies[pos] = child_scene
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 && y == 0:
				continue
			var neighbour_pos = Vector2i(pos.x + x, pos.y + y)
			if map.is_cell_empty(neighbour_pos):
				var atlas_pos = map.board.get_cell_atlas_coords(neighbour_pos)
				atlas_pos = Vector2i(atlas_pos.x + 1, atlas_pos.y)
				map.board.set_cell(neighbour_pos, 0, atlas_pos)
	#print("end spawn here")
