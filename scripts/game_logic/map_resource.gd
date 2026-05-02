class_name MapResource
extends Resource

enum CellData {
	NOT_PLAYABLE = 0,
	EMPTY = 1,
	ENEMY = 2,
}

@export var map_name: String
@export var map_size: Vector2i
@export var enemies_position_stored: bool
@export var playable_cells_count: int
@export var map_data: Array[Array]


func _init(mname: String = "map", data: Array[Array] = [[]]):
	map_name = mname
	map_data = data
	update_map_data()


func calc_map_size() -> void:
	if map_data.size() > 0:
		map_size = Vector2i(map_data.size(), map_data[0].size())
	else:
		map_size = Vector2i(0, 0)


func calc_playable_cells() -> void:
	playable_cells_count = 0
	for x in range(0, map_data.size()):
		for y in range(0, map_data[x].size()):
			if map_data[x][y] != CellData.NOT_PLAYABLE:
				playable_cells_count += 1


func check_if_enemies_stored() -> void:
	for x in range(0, map_data.size()):
		var res: int = map_data[x].find(CellData.ENEMY)
		if res != -1:
			enemies_position_stored = true
			return
	enemies_position_stored = false


func update_map_data() -> void:
	calc_map_size()
	check_if_enemies_stored()
	calc_playable_cells()
