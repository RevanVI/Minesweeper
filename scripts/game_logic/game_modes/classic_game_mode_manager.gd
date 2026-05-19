class_name ClassicGameModeManager
extends GameModeManager


enum Diffuculty {
	EASY = 0,
	MEDIUM = 1,
	HARD = 2,
}

@export var current_level: int = Diffuculty.EASY

func _ready() -> void:
	battle_manager = $"GameManager"
	character = Character.new(1, 0)

	start_mode()
	init_done.emit()


func start_mode() -> void:
	assert(current_level in levels_data.keys())
	generate_level()
	battle_manager.prepare_battle(levels_data[current_level], character)


func generate_level() -> void:
	#TODO: level generation algorithm
	levels_data[current_level].generate_level(0)


func prepare_next_level() -> void:
	print("prepare_next_level")
	restart_mode()


func restart_mode() -> void:
	print("restart mode")
	# TODO some animations here?
	generate_level()
	character.reset()
	battle_manager.prepare_battle(levels_data[current_level], character)
