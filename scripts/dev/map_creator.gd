@tool
class_name MapCreator
extends Node2D

@export var map: TileMapLayer

@export var map_name_edit: LineEdit
@export var map_size_label: Label
@export var playable_cells_label: Label

@export var tile_type_dict: Dictionary[Vector2i, MapResource.CellData] = {}
@export var type_tile_dict: Dictionary[MapResource.CellData, Vector2i] = {}
@export var map_dir: String
var _map_res: MapResource

@export_tool_button("Import map", "Callable") var import_button = on_import_button_pressed
@export_tool_button("Export map", "Callable") var export_button = export_map


func export_map() -> void:
    _map_res = parse_map()
    var dialog: EditorFileDialog = EditorFileDialog.new()
    dialog.add_filter("*.tres", "Resource")
    dialog.current_file = _map_res.map_name + ".tres"
    dialog.current_dir = map_dir
    dialog.file_selected.connect(on_file_selected)
    get_window().get_viewport().add_child(dialog)
    dialog.popup_file_dialog()


func on_file_selected(filename: String):
    _map_res.take_over_path(filename)
    var res: int = ResourceSaver.save(_map_res, filename)
    print("Saving file " + str(filename) + ": " + str(res))


func parse_map() -> MapResource:
    print("Parsing map...")
    var map_rect: Rect2i = map.get_used_rect()

    var map_res: MapResource = MapResource.new()
    var map_data: Array[Array]

    for x in range(map_rect.position.x, map_rect.end.x):
        var map_col: Array[int] = []

        for y in range(map_rect.position.y, map_rect.end.y):
            var cell_tile_coords: Vector2i = map.get_cell_atlas_coords(Vector2i(x, y))
            if cell_tile_coords == Vector2i(-1, -1):
                map_col.append(MapResource.CellData.NOT_PLAYABLE)
            else:
                map_col.append(tile_type_dict[cell_tile_coords])
        map_data.append(map_col)
    
    map_res.map_data = map_data
    map_res.map_name = map_name_edit.text
    map_res.update_map_data()
    print("Map parsed. ")
    print("Map size: " + str(map_res.map_size))
    print("Map playable cells: " + str(map_res.playable_cells_count))

    map_size_label.text = "Map size: " + str(map_res.map_size)
    playable_cells_label.text = "Playable cells: " + str(map_res.playable_cells_count)
            
    return map_res


func on_import_button_pressed() -> void:
    var dialog: EditorFileDialog = EditorFileDialog.new()
    dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
    dialog.add_filter("*.tres", "Resource")
    dialog.current_dir = map_dir
    dialog.file_selected.connect(import_map)
    get_window().get_viewport().add_child(dialog)
    dialog.popup_file_dialog()


func import_map(filepath: String) -> void:
    _map_res = ResourceLoader.load(filepath)
    if _map_res == null:
        print("Failed to load " + str(filepath))
    
    map_name_edit.text = _map_res.map_name
    map_size_label.text = "Map size: " + str(_map_res.map_size)
    playable_cells_label.text = "Playable cells: " + str(_map_res.playable_cells_count)
  
    map.clear()
    for x in range(0, _map_res.map_size.x):
        for y in range(0, _map_res.map_size.y):
            map.set_cell(Vector2i(x, y), 0, type_tile_dict[_map_res.map_data[x][y]])
    print("Loaded " + str(filepath))