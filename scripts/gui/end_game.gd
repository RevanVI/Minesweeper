extends Control


var game_manager: GameManager


@onready var win_panel: Panel = $WinPanel
@onready var loose_panel: Panel = $LoosePanel
@onready var undo_btn: Button = $LoosePanel/undo_btn


func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("GameManager")
	game_manager.level_completed.connect(_on_level_completed)
	game_manager.level_lost.connect(_on_level_lost)


func _on_level_completed() -> void:
	win_panel.visible = true
	win_panel.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_level_lost() -> void:
	loose_panel.visible = true
	loose_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	if game_manager.undo_count > 0:
		undo_btn.disabled = false
	else:
		undo_btn.disabled = true


func _on_next_level_btn_pressed() -> void:
	game_manager.call_deferred("start_next_level")
	win_panel.visible = false
	win_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_restart_btn_pressed() -> void:
	game_manager.call_deferred("restart_game")
	loose_panel.visible = false
	loose_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_undo_btn_pressed() -> void:
	game_manager.call_deferred("undo")
	loose_panel.visible = false
	loose_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
