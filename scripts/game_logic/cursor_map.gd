class_name CursorMap
extends Node2D

var _map: Map
var _last_cursor_pos: Vector2i = Vector2i(-1, -1)

@onready var cursor_layer: TileMapLayer = $Cursor


func _unhandled_input(__event: InputEvent) -> void:
	var global_pos: Vector2 = get_global_mouse_position()
	var cell_pos = cursor_layer.local_to_map(cursor_layer.to_local(global_pos))

	if cell_pos != _last_cursor_pos:
		cursor_layer.clear()
		var map_pos: Vector2i = _map.get_cell_pos_from_global(global_pos)
		if map_pos != Vector2i(-1, -1) and _map.is_pos_playable(map_pos):
			cursor_layer.set_cell(cell_pos, 0, Vector2i(0, 3))
			_last_cursor_pos = cell_pos
		else:
			_last_cursor_pos = Vector2i(-1, -1)


func set_mine_type(mine_type: MineType):
	cursor_layer.tile_set = mine_type.tile_set


func set_map(map: Map) -> void:
	_map = map
