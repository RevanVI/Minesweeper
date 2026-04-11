class_name GameModeManager
extends Node2D


signal init_done()


@export var level_info: LevelInfo

var character: Character
var battle_manager: GameManager


func start_mode() -> void:
	pass


func generate_level() -> void:
	pass


func start_battle() -> void:
	pass


func is_undo_supported() -> bool:
	return false


func restart_mode() -> void:
	pass


func exit_to_menu() -> void:
	pass
