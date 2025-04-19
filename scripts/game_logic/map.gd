class_name Map
extends Node2D


signal cell_opened(cell_type: CellType, open_obj: Node)
signal cell_closed(pos)
signal cell_marked(value: bool)


enum CellType {
	EMPTY = 0,
	ENEMY = 1,
}


const ENEMY_COLLECTION_ID = 1


@export var cell_tile: Vector2i
@export var mark_tile: Vector2i
@export var empty_tiles: Array[Vector2i]

var size: Vector2i = Vector2i(0, 0)
var _directions: Array[Vector2i] = []
var _enemies: Dictionary[Vector2i, Enemy] = {}

@onready var board: TileMapLayer = $Board
@onready var cells: TileMapLayer = $Cells


func _ready() -> void:
	build_directions()


func reset_cells() -> void:
	cells.clear()
	assert(size.x != 0 && size.y != 0)
	for x in range(size.x):
		for y in range(size.y):
			cells.set_cell(Vector2i(x,y), 0, cell_tile)


func reset_board() -> void:
	board.clear()
	assert(size.x != 0 && size.y != 0)
	for x in range(size.x):
		for y in range(size.y):
			board.set_cell(Vector2i(x,y), 0, empty_tiles[0])
	_enemies.clear()


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


func open_cell_at_global_position(global_pos: Vector2) -> bool:
	var tile_pos = cells.local_to_map(cells.to_local(global_pos))
	if cells.get_cell_source_id(tile_pos) != -1 \
		&& is_cell_marked(tile_pos) == false:
		var command = OpenCellsCommand.new(self, tile_pos)
		#TODO some other way to send commands
		get_tree().get_first_node_in_group("GameManager").turn_queue.add_command(command)
		return true
	return false


func open_cell(pos: Vector2i) -> Array[Vector2i]:
	print("Map: open cell: " + str(pos))
	
	var opened_cells: Array[Vector2i] = []
	if cells.get_cell_atlas_coords(pos) == cell_tile:
		cells.erase_cell(pos)
		opened_cells.append(pos)
		#print("Map: cells opened: " + str(opened_cells))
		var cell_type = get_cell_type(pos)
		if cell_type == CellType.ENEMY:
			cell_opened.emit(cell_type, _enemies[pos])
		else:
			var tile_atlas_coords = board.get_cell_atlas_coords(pos)
			if tile_atlas_coords == empty_tiles[0]:
				var res = reveal_empty_neighbours(pos)
				opened_cells.append_array(res)
			cell_opened.emit(cell_type)
	return opened_cells


func close_cell(pos: Vector2i) -> void:
	print("Map: close cell: " + str(pos))
	if cells.get_cell_source_id(pos) == -1 && board.get_cell_source_id(pos) != -1:
		cells.set_cell(pos, 0, cell_tile)
		cell_closed.emit(pos)


func reveal_empty_neighbours(pos: Vector2i) -> Array[Vector2i]:
	var opened_cells: Array[Vector2i] = []
	var stack: Array[Vector2i] = []
	stack.append_array(get_neighbour_cells(pos, [cell_tile]))
	
	while stack.is_empty() == false:
		var cur_cell = stack.pop_back()
		if cells.get_cell_source_id(cur_cell) == -1:
			continue
		cells.erase_cell(cur_cell)
		opened_cells.append(cur_cell)
		if board.get_cell_atlas_coords(cur_cell) == empty_tiles[0]:
			var neighbour_cells = get_neighbour_cells(cur_cell, [cell_tile])
			stack.append_array(neighbour_cells)
	
	return opened_cells


func mark_cell(pos: Vector2i) -> void:
	if cells.get_cell_atlas_coords(pos) == cell_tile:
		print("Cell marked: " + str(pos))
		cells.set_cell(pos, 0, mark_tile)
		cell_marked.emit(true)
	elif cells.get_cell_atlas_coords(pos) == mark_tile:
		print("Cell unmarked: " + str(pos))
		cells.set_cell(pos, 0, cell_tile)
		cell_marked.emit(false)


func mark_cell_global_position(global_pos: Vector2) -> void:
	var tile_pos = cells.local_to_map(cells.to_local(global_pos))
	if cells.get_cell_source_id(tile_pos) != -1:
		var command: MarkCellCommand = MarkCellCommand.new(self, tile_pos)
		get_tree().get_first_node_in_group("GameManager").turn_queue.add_command(command)


func is_cell_marked(pos: Vector2i) -> bool:
	if cells.get_cell_atlas_coords(pos) == mark_tile:
		return true
	else:
		return false


func get_cells_total() -> int:
	return size.x * size.y


func get_closed_cells_count() -> int:
	var closed_cells_count = cells.get_used_cells().size()
	return closed_cells_count


func get_closed_cells() -> Array[Vector2i]:
	var closed_cells = cells.get_used_cells()
	return closed_cells


func get_enemis_cells() -> Array[Vector2i]:
	var enemies_cells = _enemies.keys()
	return enemies_cells


func get_cell_pos(global_pos: Vector2) -> Vector2i:
	var tile_pos = cells.local_to_map(cells.to_local(global_pos))
	if cells.get_cell_source_id(tile_pos) != -1:
		return tile_pos
	else:
		return Vector2i(-1, -1)


func is_pos_on_board(cell_pos: Vector2i) -> bool:
	if cell_pos.x < 0 || cell_pos.x >= size.x || \
			cell_pos.y < 0 || cell_pos.y >= size.y:
		return false
	var cell_type = board.get_cell_atlas_coords(cell_pos)
	if cell_type in empty_tiles or cell_pos in _enemies:
		return true
	return false


func is_cell_empty(cell_pos: Vector2i) -> bool:
	var source_id = board.get_cell_source_id(cell_pos)
	var enemy_on_cell = source_id == ENEMY_COLLECTION_ID \
			&& board.get_cell_alternative_tile(cell_pos) >= 1
	
	return not enemy_on_cell


func get_cell_type(cell_pos: Vector2i) -> CellType:
	var tile_atlas_coords = board.get_cell_atlas_coords(cell_pos)
	var tile_source_id = board.get_cell_source_id(cell_pos)
	if tile_source_id == 0 && tile_atlas_coords in empty_tiles:
		return CellType.EMPTY
	else:
		return CellType.ENEMY


func start_hide() -> void:
	var final_color = modulate
	final_color.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate", final_color, 0.2)
	tween.play()


func start_show() -> void:
	var final_color = modulate
	final_color.a = 1
	var tween = create_tween()
	tween.tween_property(self, "modulate", final_color, 0.2)
	tween.play()
