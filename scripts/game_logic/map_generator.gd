class_name MapGenerator
extends Resource

@export var generator_name: String = "Base"

var map: Map
# dict. key - enemy scene, value - enemies count
var enemies_info: Dictionary[PackedScene, int] = { }
# constraints
# how many empty cells should be around new enemy at least
var valid_empty_cells_required: int = 2
# how many empty cells should be around neighbouring empty cells at least (including processed cell)
var near_empty_cells_required: int = 3
# how many empty cells should be around neighbouring enemy cells at least (including processed cell)
var enemy_near_empty_cells_required: int = 3
var _modifier_list: ModifiersList
var _rng: RandomNumberGenerator


func generate_empty_map(map_ref: Map, size: Vector2i, enemies_data: Dictionary[PackedScene, int], modifiers: ModifiersList, gen_seed: int = -1) -> void:
	_rng = RandomNumberGenerator.new()
	if gen_seed != -1:
		_rng.seed = gen_seed
	else:
		_rng.seed = randi()

	map = map_ref
	map.reset_map()
	map.size = size
	enemies_info = enemies_data
	_modifier_list = modifiers

	var map_data: Array[Array] = []
	for x in range(size.x):
		map_data.append([])
		for y in range(size.y):
			var tile_data: Map.MapTileData = Map.MapTileData.new()
			map_data[x].append(tile_data)

	map.set_map_data(map_data)
	map.update_visual_map()


func populate_map(map_ref: Map, start_pos: Vector2i) -> bool:
	map = map_ref
	if map.is_pos_valid(start_pos) == false:
		return false

	map.create_enemy_collection(enemies_info.keys())

	var success: bool = false
	var max_generation_attempts: int = 5
	var iter: int = 0
	while iter < max_generation_attempts and success == false:
		success = spawn_enemies(start_pos)

	return success


func spawn_enemies(start_pos: Vector2i) -> bool:
	var possible_cells = map.get_empty_cells()

	# exclude 3x3 zone on start position from any enemies spawn
	var excluded_cells = map.get_neighbour_cells(start_pos)
	excluded_cells.append(start_pos)
	for excluded_tile in excluded_cells:
		possible_cells.erase(excluded_tile)

	var total_enemy_count: int = 0
	for count in enemies_info.values():
		total_enemy_count += count
	assert(possible_cells.size() > total_enemy_count)

	var enemies_placed: int = 0

	for enemy_scene in enemies_info:
		var enemies_to_place = enemies_info[enemy_scene]
		while enemies_to_place > 0 and possible_cells.size() >= (total_enemy_count - enemies_placed):
			var ind: int = _rng.randi_range(0, possible_cells.size() - 1)
			var random_pos = possible_cells[ind]
			possible_cells.erase(random_pos)

			var neighbours: Array[Vector2i] = map.get_neighbour_cells(random_pos)

			var valid_empty_cells: int = 0
			var valid_enemy_cells: int = 0
			var neighbour_enemies_count: int = 0

			for cell in neighbours:
				# empty cells around possible enemy position have enough empty space
				if map.is_cell_empty(cell):
					if map.get_empty_neighbour_cells(cell).size() >= near_empty_cells_required:
						valid_empty_cells += 1

				# enemy cells around possible enemy position still valid
				else:
					neighbour_enemies_count += 1
					if map.get_empty_neighbour_cells(cell).size() >= enemy_near_empty_cells_required:
						valid_enemy_cells += 1

			if valid_empty_cells < valid_empty_cells_required or valid_enemy_cells < neighbour_enemies_count:
				continue

			map.add_enemy(random_pos, enemy_scene)
			enemies_placed += 1
			enemies_to_place -= 1

	if enemies_placed < total_enemy_count:
		print("Error: cannot place all enemies on map")
		return false
	return true
