class_name Map
extends Node2D

signal cell_opened(cell_type: CellType, open_obj: Node)
signal cell_closed(pos)
signal cell_marked(value: bool)

enum CellType {
	EMPTY = 0,
	ENEMY = 1,
	LOOT = 2,
}

const ENEMY_COLLECTION_ID = 1

@export var cell_tile: Vector2i
@export var mark_tile: Vector2i
@export var empty_tiles: Array[Vector2i]
@export var hidden_tile: Vector2i

var size: Vector2i = Vector2i(0, 0)
var _directions: Array[Vector2i] = []
var _enemies: Dictionary[PackedScene, int] = { }
var _enemies_on_map: Dictionary[Vector2i, Enemy] = { }
var _map_data: Array[Array]
var _modifier_list: ModifiersList

@onready var board: TileMapLayer = $Board
@onready var cells: TileMapLayer = $Cells


func _ready() -> void:
	_build_directions()


func reset_map() -> void:
	cells.clear()
	board.clear()
	_enemies = { }
	_enemies_on_map = { }


func update_visual_map() -> void:
	cells.clear()
	board.clear()
	for x in range(size.x):
		for y in range(size.y):
			var tile_data: MapTileData = _map_data[x][y]
			var pos: Vector2i = Vector2i(x, y)

			if not tile_data.opened:
				cells.set_cell(pos, 0, cell_tile)
			if tile_data.marked:
				cells.set_cell(pos, 0, mark_tile)
			if tile_data.playable:
				var hide_modifier: ModifierHiddenCells = null
				if _modifier_list:
					hide_modifier = _modifier_list.get_modifier_by_tag(ModifierBase.ModifierTag.HIDE_CELLS)
				if hide_modifier and tile_data.enemies_count in hide_modifier.hidden_values:
					board.set_cell(pos, 0, hidden_tile)
				else:
					board.set_cell(pos, 0, empty_tiles[tile_data.enemies_count])


func reset_cells() -> void:
	cells.clear()
	assert(size.x != 0 && size.y != 0)
	for x in range(size.x):
		for y in range(size.y):
			if _map_data[x][y].playable:
				_map_data[x][y].opened = false
				_map_data[x][y].marked = false
				cells.set_cell(Vector2i(x, y), 0, cell_tile)


func reset_board() -> void:
	board.clear()
	assert(size.x != 0 && size.y != 0)
	for x in range(size.x):
		for y in range(size.y):
			if _map_data[x][y].playable:
				_map_data[x][y].enemies_count = 0
				_map_data[x][y].type = CellType.EMPTY
				board.set_cell(Vector2i(x, y), 0, empty_tiles[0])
	_enemies_on_map.clear()


func get_neighbour_cells(pos: Vector2i, filter_cell: Array[Vector2i] = []) -> Array[Vector2i]:
	# TODO: refactor to remove reading tile texture for filter
	var neighbours: Array[Vector2i] = []
	for dir in _directions:
		var new_pos = pos + dir

		#outside map borders
		if new_pos.x < 0 || new_pos.x >= size.x || \
		new_pos.y < 0 || new_pos.y >= size.y:
			continue

		if _map_data[new_pos.x][new_pos.y].playable == false:
			continue

		var cell_type = cells.get_cell_atlas_coords(new_pos)
		if filter_cell.is_empty() == true || cell_type in filter_cell:
			neighbours.append(new_pos)

	return neighbours


func get_empty_neighbour_cells(pos: Vector2i) -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = []
	for dir in _directions:
		var new_pos = pos + dir

		#outside map borders
		if new_pos.x < 0 || new_pos.x >= size.x || \
		new_pos.y < 0 || new_pos.y >= size.y:
			continue

		if _map_data[new_pos.x][new_pos.y].playable == false:
			continue

		if _map_data[new_pos.x][new_pos.y].type == CellType.EMPTY:
			neighbours.append(new_pos)

	return neighbours


func open_cell_at_global_position(global_pos: Vector2) -> bool:
	var coords = cells.local_to_map(cells.to_local(global_pos))
	if is_pos_valid(coords) == false:
		return false
	if _map_data[coords.x][coords.y].opened == false and \
	_map_data[coords.x][coords.y].marked == false:
		var command = OpenCellsCommand.new(self, coords)
		# TODO: some other way to send commands
		get_tree().get_first_node_in_group("GameManager").turn_queue.add_command(command)
		return true
	return false


func open_cell(pos: Vector2i) -> Array[Vector2i]:
	print("Map: open cell: " + str(pos))

	var opened_cells: Array[Vector2i] = []
	var cell_data: MapTileData = _map_data[pos.x][pos.y]
	if cell_data.opened == false:
		cell_data.opened = true
		cells.erase_cell(pos)
		opened_cells.append(pos)
		#print("Map: cells opened: " + str(opened_cells))
		if cell_data.type == CellType.ENEMY:
			cell_opened.emit(cell_data.type, _enemies_on_map[pos])
		else:
			if cell_data.enemies_count == 0:
				var res = reveal_empty_neighbours(pos)
				opened_cells.append_array(res)
			cell_opened.emit(cell_data.type)
	return opened_cells


func close_cell(pos: Vector2i) -> void:
	print("Map: close cell: " + str(pos))

	# TODO: check valid position?
	var cell_data: MapTileData = _map_data[pos.x][pos.y]
	cell_data.opened = false
	cells.set_cell(pos, 0, cell_tile)
	cell_closed.emit(pos)


func reveal_empty_neighbours(pos: Vector2i) -> Array[Vector2i]:
	var opened_cells: Array[Vector2i] = []
	var stack: Array[Vector2i] = []
	stack.append_array(get_neighbour_cells(pos, [cell_tile]))

	while stack.is_empty() == false:
		var cur_cell = stack.pop_back()
		var cell_data: MapTileData = _map_data[cur_cell.x][cur_cell.y]
		cell_data.opened = true
		cells.erase_cell(cur_cell)
		opened_cells.append(cur_cell)
		if cell_data.enemies_count == 0:
			var neighbour_cells = get_neighbour_cells(cur_cell, [cell_tile])
			stack.append_array(neighbour_cells)

	return opened_cells


func mark_cell(pos: Vector2i) -> void:
	var cell_data: MapTileData = _map_data[pos.x][pos.y]
	if cell_data.opened == false:
		print("Cell marked: " + str(pos))
		cell_data.marked = true
		cells.set_cell(pos, 0, mark_tile)
		cell_marked.emit(true)
	elif cell_data.marked == true:
		print("Cell unmarked: " + str(pos))
		cell_data.marked = false
		cells.set_cell(pos, 0, cell_tile)
		cell_marked.emit(false)


func mark_cell_global_position(global_pos: Vector2) -> void:
	var coords = cells.local_to_map(cells.to_local(global_pos))
	if is_pos_valid(coords) == false:
		return

	var command: MarkCellCommand = MarkCellCommand.new(self, coords)
	get_tree().get_first_node_in_group("GameManager").turn_queue.add_command(command)


func is_cell_marked(pos: Vector2i) -> bool:
	if is_pos_valid(pos) == false:
		return false

	var cell_data: MapTileData = _map_data[pos.x][pos.y]
	return cell_data.marked


func get_playable_cells_count() -> int:
	var playable_cells: Array[Vector2i] = []
	for x in range(size.x):
		for y in range(size.y):
			if _map_data[x][y].playable:
				playable_cells.append(Vector2i(x, y))
	return playable_cells.size()


func get_closed_cells_count() -> int:
	var closed_cells_count = get_closed_cells().size()
	return closed_cells_count


func get_closed_cells() -> Array[Vector2i]:
	var closed_cells: Array[Vector2i] = []
	for x in range(size.x):
		for y in range(size.y):
			if _map_data[x][y].playable && _map_data[x][y].opened == false:
				closed_cells.append(Vector2i(x, y))
	return closed_cells


func get_enemis_cells() -> Array[Vector2i]:
	var enemies_cells = _enemies_on_map.keys()
	return enemies_cells


func get_cell_pos(global_pos: Vector2) -> Vector2i:
	var cell_pos = cells.local_to_map(cells.to_local(global_pos))
	if is_pos_valid(cell_pos):
		return cell_pos
	return Vector2i(-1, -1)


func is_pos_valid(cell_pos: Vector2i) -> bool:
	if cell_pos.x < 0 || cell_pos.x >= size.x || \
	cell_pos.y < 0 || cell_pos.y >= size.y:
		return false
	var cell_data: MapTileData = _map_data[cell_pos.x][cell_pos.y]
	return cell_data.playable


func is_cell_empty(cell_pos: Vector2i) -> bool:
	if is_pos_valid(cell_pos):
		return _map_data[cell_pos.x][cell_pos.y].type == CellType.EMPTY
	return false


func get_cell_type(cell_pos: Vector2i) -> CellType:
	if is_pos_valid(cell_pos):
		return _map_data[cell_pos.x][cell_pos.y].type
	return CellType.EMPTY


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


func set_map_data(map_data: Array[Array]) -> void:
	_map_data = map_data


func get_empty_cells() -> Array[Vector2i]:
	var empty_cells: Array[Vector2i] = []
	for x in range(size.x):
		for y in range(size.y):
			if _map_data[x][y].playable && _map_data[x][y].type == CellType.EMPTY:
				empty_cells.append(Vector2i(x, y))
	return empty_cells


func create_enemy_collection(enemies: Array[PackedScene]) -> void:
	_enemies.clear()
	var enemy_scene_collection = board.tile_set \
	.get_source(ENEMY_COLLECTION_ID) \
	as TileSetScenesCollectionSource
	for enemy_scene in enemies:
		var new_id = enemy_scene_collection.create_scene_tile(enemy_scene)
		_enemies[enemy_scene] = new_id


func add_enemy(pos: Vector2i, enemy_scene: PackedScene) -> void:
	#print("set cell here")
	var enemy_collection_id = _enemies[enemy_scene]
	_map_data[pos.x][pos.y].type = CellType.ENEMY

	# TODO: should it be here?
	board.set_cell(pos, ENEMY_COLLECTION_ID, Vector2i(0, 0), enemy_collection_id)

	# tilemap updates at the end of the frame
	# this means that _ready() on spawned scene will be called only then
	# we need to store ref to spawned scene so force tilemap update with update_internals()
	# TODO: can be heavy on perf. check on big map, make it better and frame independent?
	board.update_internals()

	var last_ind = board.get_child_count()
	var child_scene = board.get_children()[last_ind - 1] as Enemy
	_enemies_on_map[pos] = child_scene

	var neighbours: Array[Vector2i] = get_neighbour_cells(pos)
	for neighbour in neighbours:
		var data = _map_data[neighbour.x][neighbour.y]
		if data.type == CellType.EMPTY:
			data.enemies_count += 1

			# TODO: should it be here?
			var hide_modifier: ModifierHiddenCells = null
			if _modifier_list:
				hide_modifier = _modifier_list.get_modifier_by_tag(ModifierBase.ModifierTag.HIDE_CELLS)
			if hide_modifier and data.enemies_count in hide_modifier.hidden_values:
				board.set_cell(neighbour, 0, hidden_tile)
			else:
				board.set_cell(neighbour, 0, empty_tiles[data.enemies_count])


func set_modifiers(modifiers: ModifiersList) -> void:
	_modifier_list = modifiers


func get_limits() -> Rect2:
	var tile_limits: Rect2i = board.get_used_rect()

	var start_pos: Vector2 = board.map_to_local(tile_limits.position)
	start_pos = to_global(start_pos) - Vector2(board.tile_set.tile_size)
	var end_pos: Vector2 = board.map_to_local(tile_limits.end)
	end_pos = to_global(end_pos)
	var limit_size: Vector2 = Vector2(end_pos - start_pos)
	var global_limits: Rect2 = Rect2(start_pos, limit_size)
	return global_limits


func _build_directions() -> void:
	_directions.clear()
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x != 0 || y != 0:
				_directions.append(Vector2i(x, y))


class MapTileData:
	var playable: bool
	var opened: bool
	var marked: bool
	var enemies_count: int
	var type: CellType
	var effects: Array[int]


	func _init(
			i_playable: bool = true,
			i_opened: bool = false,
			i_marked: bool = false,
			i_enemis_count: int = 0,
			i_type: CellType = CellType.EMPTY,
			i_effects: Array[int] = [],
	) -> void:
		playable = i_playable
		opened = i_opened
		marked = i_marked
		enemies_count = i_enemis_count
		type = i_type
		effects = i_effects
