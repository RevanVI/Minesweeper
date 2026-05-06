extends Node2D

@export var map_generator: MapGenerator
@export var level_info: LevelInfo
@export var map: Map
@export var camera_controller: CameraController
@export var seed_edit: LineEdit
@export var map_size_x_edit: LineEdit
@export var map_size_y_edit: LineEdit
@export var enemies_count_edit: LineEdit
@export var maps_count_edit: LineEdit
@export var errors_count_label: Label
@export var generator_options: OptionButton

var map_generators_list: Array[MapGenerator] = [MapGenerator.new()]
var _map_size: Vector2i
var _enemies_count: int
var _maps_count: int
var _seed: int


func _ready() -> void:
	_fill_generator_options()


func generate_map() -> void:
	_get_test_params()
	level_info.generate_level(0)
	var modifier_list = ModifiersList.new()
	modifier_list.add_modifiers(level_info.modifiers)
	var enemies_data: Dictionary[PackedScene, int] = level_info.get_enemies_data()
	enemies_data[enemies_data.keys()[0]] = _enemies_count
	map_generator.generate_empty_map(map, _map_size, enemies_data, modifier_list, _seed)
	var success: bool = map_generator.populate_map(map, level_info.map_size / 2)
	map.cells.hide()
	camera_controller.pos_limits = map.get_limits()
	camera_controller.calc_start_position()

	if success:
		errors_count_label.text = "Failed maps count: 0"
	else:
		errors_count_label.text = "Failed maps count: 1"


func _get_test_params() -> void:
	_seed = int(seed_edit.text)
	var map_x: int = int(map_size_x_edit.text)
	var map_y: int = int(map_size_y_edit.text)
	_map_size = Vector2i(map_x, map_y)
	_enemies_count = int(enemies_count_edit.text)
	_maps_count = int(maps_count_edit.text)


func _fill_generator_options() -> void:
	generator_options.clear()
	for generator in map_generators_list:
		generator_options.add_item(generator.generator_name)


func _on_generate_button_pressed() -> void:
	generate_map()


func _on_generator_option_button_item_selected(index: int) -> void:
	map_generator = map_generators_list[index]
