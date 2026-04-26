class_name MainMenu
extends Control




func _on_endless_mode_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/modes/endless_mode.tscn")


func _on_exit_btn_pressed() -> void:
	get_tree().quit()


func _on_classic_mode_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/modes/classic_mode.tscn")
