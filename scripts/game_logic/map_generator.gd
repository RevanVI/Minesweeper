class_name MapGenerator
extends Node2D


var map_size: Vector2i = Vector2i(10, 10)
var mines_count: int = 10
var map: Map


func generate_map(map_ref: Map, start_pos: Vector2i) -> void:
	map = map_ref
	if map.is_cell_valid_board(start_pos) == false:
		return
	map.size = map_size
	map.reset_board()
	map.reset_cells()
	spawn_mines(start_pos)


func spawn_mines(start_pos: Vector2i) -> void:
	var excluded_tiles = map.get_neighbour_cells(start_pos)
	excluded_tiles.append(start_pos)
	
	var all_empty_tiles = map.board.get_used_cells_by_id(0, map.empty_tiles[0])
	
	var i = 0
	while i < mines_count:
		var random_pos = all_empty_tiles.pick_random()
		all_empty_tiles.erase(random_pos)
		if random_pos in excluded_tiles:
			continue
		if is_tile_mine_valid(random_pos):
			spawn_mine_at_pos(random_pos)
			i += 1


func is_tile_mine_valid(pos) -> bool:
	var tile_data = map.board.get_cell_atlas_coords(pos)
	if tile_data == map.mine_tile:
		return false
	else:
		return true


func spawn_mine_at_pos(pos) -> void:
	map.board.set_cell(pos, 0, map.mine_tile)
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 && y == 0:
				continue
			var neighbour_pos = Vector2i(pos.x + x, pos.y + y)
			var atlas_pos = map.board.get_cell_atlas_coords(neighbour_pos)
			if atlas_pos != map.mine_tile:
				atlas_pos = Vector2i(atlas_pos.x + 1, atlas_pos.y)
				map.board.set_cell(neighbour_pos, 0, atlas_pos)
