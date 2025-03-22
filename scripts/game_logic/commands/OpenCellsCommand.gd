extends Command
class_name OpenCellsCommand

var cell_positions: Array[Vector2i]
var map: Map


func _init(map_ref: Map, position: Vector2i) -> void:
	super()
	map = map_ref
	cell_positions = [position]


func execute() -> void:
	var opened_cells = map.open_cell(cell_positions[0])
	cell_positions = opened_cells


func undo() -> void:
	for pos in cell_positions:
		map.close_cell(pos)
