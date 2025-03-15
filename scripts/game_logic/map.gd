extends Node2D

class_name Map

@export var cell_tile: Vector2i
@export var mark_tile: Vector2i
@export var mine_tile: Vector2i
@export var empty_tiles: Array[Vector2i]

@onready var board: TileMapLayer = $Board
@onready var cells: TileMapLayer = $Cells

var size: Vector2i = Vector2i(0, 0)
var _directions: Array[Vector2i] = []


signal cell_opened(board_tile_type)
signal cell_marked(value: bool)


func _ready() -> void:
	build_directions()


func reset_cells() -> void:
	for x in range(size.x):
		for y in range(size.y):
			cells.set_cell(Vector2i(x,y), 0, cell_tile)


func reset_board() -> void:
	for x in range(size.x):
		for y in range(size.y):
			board.set_cell(Vector2i(x,y), 0, empty_tiles[0])


func build_directions() -> void:
	_directions.clear()
	for x in range (-1, 2):
		for y in range (-1, 2):
			if x != 0 || y != 0:
				_directions.append(Vector2i(x, y))


func get_neighbour_cells(pos: Vector2i, filter: Array[Vector2i] = []) -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = []
	for dir in _directions:
		var new_pos = pos + dir
		
		#outside map borders
		if new_pos.x < 0 || new_pos.x >= size.x || \
			new_pos.y < 0 || new_pos.y >= size.y:
			continue
		
		var cell_type = cells.get_cell_atlas_coords(new_pos)
		if filter.is_empty() == false || cell_type in filter:
			neighbours.append(new_pos)
	
	return neighbours


func open_cell(pos: Vector2i) -> void:
	print("Map: open cell: " + str(pos))
	if cells.get_cell_atlas_coords(pos) == cell_tile:
		cells.erase_cell(pos)
		var board_tile_type = board.get_cell_atlas_coords(pos)
		if board_tile_type == empty_tiles[0]:
			reveal_empty_neighbours(pos)
		cell_opened.emit(board_tile_type)


func open_cell_at_global_position(global_pos: Vector2) -> void:
	var tile_pos = cells.local_to_map(cells.to_local(global_pos))
	if cells.get_cell_source_id(tile_pos) != -1:
		open_cell(tile_pos)


func reveal_empty_neighbours(pos: Vector2i) -> void:
	var stack: Array[Vector2i] = []
	stack.append_array(get_neighbour_cells(pos, [cell_tile]))
	
	while stack.is_empty() == false:
		var cur_cell = stack.pop_back()
		if cells.get_cell_source_id(cur_cell) == -1:
			continue	
		cells.erase_cell(cur_cell)
		if board.get_cell_atlas_coords(cur_cell) == empty_tiles[0]:
			var neighbour_cells = get_neighbour_cells(cur_cell, [cell_tile])
			stack.append_array(neighbour_cells)


func mark_cell(pos: Vector2i) -> void:
	if cells.get_cell_atlas_coords(pos) == cell_tile:
		cells.set_cell(pos, 0, mark_tile)
		cell_marked.emit(true)
	elif cells.get_cell_atlas_coords(pos) == mark_tile:
		cells.set_cell(pos, 0, cell_tile)
		cell_marked.emit(false)


func mark_cell_global_position(global_pos: Vector2) -> void:
	var tile_pos = cells.local_to_map(cells.to_local(global_pos))
	if cells.get_cell_source_id(tile_pos) != -1:
		mark_cell(tile_pos)


func get_cells_total() -> int:
	return size.x * size.y


func get_closed_cells() -> int:
	var closed_cells_count = cells.get_used_cells().size()
	return closed_cells_count


func get_cell_pos(global_pos: Vector2) -> Vector2i:
	var tile_pos = cells.local_to_map(cells.to_local(global_pos))
	if cells.get_cell_source_id(tile_pos) != -1:
		return tile_pos
	else:
		return Vector2i(-1, -1)


func is_cell_valid_board(cell_pos: Vector2i) -> bool:
	if cell_pos.x < 0 || cell_pos.x >= size.x || \
			cell_pos.y < 0 || cell_pos.y >= size.y:
		return false
	var cell_type = board.get_cell_atlas_coords(cell_pos)
	if cell_type in empty_tiles or cell_type == mine_tile:
		return true
	return false
