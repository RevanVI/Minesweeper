class_name EndlessGameModeManager
extends GameModeManager


enum Diffuculty {
	EASY = 0,
	MEDIUM = 1,
	HARD = 2,
}


@export var current_level: int = Diffuculty.EASY


func _ready() -> void:
	battle_manager = $"GameManager"
	character = Character.new()

	start_mode()
	init_done.emit()


func start_mode() -> void:
	var data: Dictionary = SceneSwitcherGlobal.get_data("endless_mode_settings", true)
	if data.is_empty():
		current_level = 2
	else:
		current_level = data["difficulty_level"]

	assert(current_level in levels_data.keys())
	generate_level()
	battle_manager.prepare_battle(levels_data[current_level], character)
	battle_manager.change_game_state(GameManager.GameState.START)


func generate_level() -> void:
	#TODO: level generation algorithm
	levels_data[current_level].generate_level(current_level)


func is_undo_supported() -> bool:
	return true


func prepare_next_level() -> void:
	print("EndlessGameModeManager.prepare_next_level")
	generate_level()
	battle_manager.prepare_battle(levels_data[current_level], character)


func restart_mode() -> void:
	print("EndlessGameModeManager.restart_mode")
	# TODO some animations here?
	generate_level()
	character.reset()
	battle_manager.prepare_battle(levels_data[current_level], character)
