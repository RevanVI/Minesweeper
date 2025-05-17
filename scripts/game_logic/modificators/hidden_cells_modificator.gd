class_name HiddenCellsModificator
extends Modificator


@export var hidden_cell_value: int = 5


var _prev_value: int


func apply(map: Map) -> void:
	_prev_value = map._hidden_cell_value
	map._hidden_cell_value = min(hidden_cell_value, _prev_value)


func revert(map: Map) -> void:
	map._hidden_cell_value = _prev_value
