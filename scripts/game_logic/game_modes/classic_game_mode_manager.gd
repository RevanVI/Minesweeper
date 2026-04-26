class_name ClassicGameModeManager
extends GameModeManager


func _ready() -> void:
	battle_manager = $"GameManager"
	character = Character.new(1, 0)

	start_mode()
	init_done.emit()


func start_mode() -> void:
	generate_level()
	battle_manager.prepare_battle(level_info, character)


func generate_level() -> void:
	#TODO: level generation algorithm
	level_info.generate_level(0)


func is_undo_supported() -> bool:
	return false


func prepare_next_level() -> void:
	print("prepare_next_level")
	restart_mode()


func restart_mode() -> void:
	print("restart mode")
	# TODO some animations here?
	generate_level()
	character.reset()
	battle_manager.prepare_battle(level_info, character)
