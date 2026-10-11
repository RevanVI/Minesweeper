class_name TopLayer
extends TileMapLayer

@export_exp_easing var fade_out_ease: float

#dict with  cells to fade out
#array: 0 - fade out time left, 1 - ease out factor, 2 - ease out speed
var _cells_to_fade_out: Dictionary[Vector2i, Array] = { }

var _cells_to_erase: Array[Vector2i] = []
var _last_delta: float = 0
var _rng: RandomNumberGenerator


func _ready() -> void:
	_rng = RandomNumberGenerator.new()


func _process(delta: float) -> void:
	_last_delta = delta
	notify_runtime_tile_data_update()
	_cleanup_cells()


func reset_layer() -> void:
	_cells_to_fade_out.clear()
	_cells_to_erase.clear()


func add_cells_to_fade_out(cells: Array[Vector2i]) -> void:
	for i in cells:
		assert(i not in _cells_to_fade_out.keys())
		_cells_to_fade_out[i] = [1.0, _rng.randf_range(-1.5, -3), _rng.randf_range(0.8, 1.5)]


func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if coords in _cells_to_fade_out:
		return true
	return false


func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	var current_time: float = _cells_to_fade_out[coords][0]
	var target_time = current_time - _cells_to_fade_out[coords][2] * _last_delta
	var applied_alpha = ease(target_time, _cells_to_fade_out[coords][1])
	tile_data.modulate.a = applied_alpha
	_cells_to_fade_out[coords][0] = target_time

	if target_time <= 0:
		_cells_to_erase.append(coords)
		_cells_to_fade_out.erase(coords)


func _cleanup_cells() -> void:
	if _cells_to_erase.size() == 0:
		return
	for i in _cells_to_erase:
		erase_cell(i)
	#print("TopLayer: " + str(_cells_to_erase.size()) + " cells erased")
	_cells_to_erase.clear()
