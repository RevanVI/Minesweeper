extends Control


@export var hp_color: Color
@export var hp_color_low: Color


var game_mode_manager: GameModeManager
var game_manager: GameManager


@onready var level_label: Label = $Panel/LevelLabel
@onready var time_label: Label = $Panel/TimeLabel
@onready var turn_label: Label = $Panel/TurnLabel
@onready var mark_label: Label = $Panel/MarkLabel
@onready var pause_button: Button = $Panel/PauseButton
@onready var restart_button: Button = $Panel/RestartButton


func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("GameManager")
	game_mode_manager = get_tree().get_first_node_in_group("GameModeManager")

	game_manager.battle_time_changed.connect(update_time)
	game_manager.mark_count_changed.connect(update_mark)
	game_manager.turn_changed.connect(update_turn)
	game_manager.level_changed.connect(update_level)
	game_manager.level_completed.connect(_on_level_end)
	game_manager.level_lost.connect(_on_level_end)
	game_manager.game_state_changed.connect(_on_game_state_changed)
	
	update_time(game_manager.battle_time)
	update_mark(game_manager.mark_count)
	

func update_time(time: int) -> void:
	time_label.text = "Time: " + str(time)


func update_mark(mark_count: int) -> void:
	mark_label.text = "Marks: " + str(mark_count)


func update_turn(turn_count: int) -> void:
	turn_label.text = "Turn: " + str(turn_count)


func update_level(level: String) -> void:
	level_label.text = level


func _on_button_pressed() -> void:
	game_mode_manager.restart_mode()


func _on_undo_button_pressed() -> void:
	game_manager.undo()


func _on_pause_button_pressed() -> void:
	game_manager.pause()


func _on_level_end() -> void:
	pause_button.disabled = true
	restart_button.disabled = true


func _on_game_state_changed(game_state: GameManager.GameState) -> void:
	if game_state == GameManager.GameState.START:
		pause_button.disabled = false
		restart_button.disabled = false
