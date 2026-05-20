class_name MainMenu
extends Control


signal init_done()


func _ready() -> void:
	init_done.emit()


func _on_endless_mode_btn_pressed() -> void:
	SceneSwitcherGlobal.switch_scene("res://scenes/modes/endless_mode.tscn")


func _on_exit_btn_pressed() -> void:
	get_tree().quit()


func _on_classic_mode_btn_pressed() -> void:
	SceneSwitcherGlobal.switch_scene("res://scenes/modes/classic_mode.tscn")


func cleanup() -> void:
	visible = false
	queue_free()