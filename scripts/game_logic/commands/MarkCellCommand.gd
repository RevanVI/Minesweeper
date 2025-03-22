extends Command
class_name MarkCellCommand

var mark_pos: Vector2i
var map: Map


func _init(map_ref: Map, pos: Vector2i) -> void:
	super()
	map = map_ref
	mark_pos = pos


func execute() -> void:
	map.mark_cell(mark_pos)


func undo() -> void:
	map.mark_cell(mark_pos)
