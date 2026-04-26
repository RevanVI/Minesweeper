class_name EndlessGameModeManager
extends GameModeManager


var _current_level: int = 0


func _ready() -> void:
	battle_manager = $"GameManager"
	character = Character.new()

	start_mode()
	init_done.emit()


func start_mode() -> void:
	generate_level()
	battle_manager.prepare_battle(level_info, character)


func generate_level() -> void:
	#TODO: level generation algorithm
	level_info.generate_level(_current_level)


func is_undo_supported() -> bool:
	return true


func prepare_next_level() -> void:
	print("prepare_next_level")
	_current_level += 1
	generate_level()
	battle_manager.prepare_battle(level_info, character)


func restart_mode() -> void:
	print("restart mode")
	# TODO some animations here?
	_current_level = 0
	generate_level()
	character.reset()
	battle_manager.prepare_battle(level_info, character)
