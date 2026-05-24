class_name MainMenu
extends Control


signal init_done()


func _ready() -> void:
	init_done.emit()


func _on_endless_mode_btn_pressed() -> void:
	var difficulty_level: int = randi_range(0, 2)
	var data: Dictionary = {"difficulty_level": difficulty_level}
	SceneSwitcherGlobal.switch_scene("res://scenes/modes/endless_mode.tscn", "endless_mode_settings", data)


func _on_exit_btn_pressed() -> void:
	get_tree().quit()


func _on_classic_mode_btn_pressed() -> void:
	var difficulty_level: int = randi_range(0, 2)
	var data: Dictionary = {"difficulty_level": difficulty_level}
	SceneSwitcherGlobal.switch_scene("res://scenes/modes/classic_mode.tscn", "classic_mode_settings", data)


func cleanup() -> void:
	visible = false
	queue_free()