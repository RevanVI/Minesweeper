class_name MapGeneratorPremade
extends MapGenerator

@export var premade_maps: Array[MapResource]
@export var use_stored_enemy_position: bool = false

var chosen_map: int = -1


func generate_empty_map(map_ref: Map, enemies_data: Dictionary[PackedScene, int], modifiers: ModifiersList, gen_seed: int = -1) -> void:
	_rng = RandomNumberGenerator.new()
	if gen_seed != -1:
		_rng.seed = gen_seed
	else:
		_rng.seed = randi()

	assert(premade_maps.size() > 0)
	chosen_map = _rng.randi_range(0, premade_maps.size() - 1)

	map = map_ref
	map.reset_map()
	map.size = premade_maps[chosen_map].map_size
	enemies_info = enemies_data
	_modifier_list = modifiers

	var map_data: Array[Array] = []
	for x in range(map.size.x):
		map_data.append([])
		for y in range(map.size.y):
			var tile_data: Map.MapTileData = Map.MapTileData.new()
			tile_data.playable = premade_maps[chosen_map].map_data[x][y] != MapResource.CellData.NOT_PLAYABLE
			map_data[x].append(tile_data)

	map.set_map_data(map_data)
	map.update_visual_map()


func spawn_enemies(start_pos: Vector2i) -> bool:
	var possible_cells: Array[Vector2i] = []
	if use_stored_enemy_position and premade_maps[chosen_map].enemies_position_stored:
		for x in range(map.size.x):
			for y in range(map.size.y):
				if premade_maps[chosen_map].map_data[x][y] == MapResource.CellData.ENEMY:
					possible_cells.append(Vector2i(x, y))
	else:
		possible_cells = map.get_empty_cells()

	# exclude 3x3 zone on start position from any enemies spawn
	var excluded_cells = map.get_neighbour_cells(start_pos)
	excluded_cells.append(start_pos)
	for excluded_tile in excluded_cells:
		possible_cells.erase(excluded_tile)

	var total_enemy_count: int = 0
	for count in enemies_info.values():
		total_enemy_count += count
	assert(possible_cells.size() >= total_enemy_count, "Not enough possible places for enemeies")

	var enemies_placed: int = 0

	for enemy_scene in enemies_info:
		var enemies_to_place = enemies_info[enemy_scene]
		while enemies_to_place > 0 and possible_cells.size() >= (total_enemy_count - enemies_placed):
			var ind: int = _rng.randi_range(0, possible_cells.size() - 1)
			var random_pos = possible_cells[ind]
			possible_cells.erase(random_pos)

			if not use_stored_enemy_position and not premade_maps[chosen_map].enemies_position_stored:
				if validate_enemy_placement(random_pos) == false:
					continue

			map.add_enemy(random_pos, enemy_scene)
			enemies_placed += 1
			enemies_to_place -= 1

	if enemies_placed < total_enemy_count:
		print("Error: cannot place all enemies on map")
		return false
	return true
