extends Control


@export var hp_color: Color
@export var hp_color_low: Color


var game_manager: GameManager
var low_hp_limit: float = 0.5


@onready var level_label: Label = $Panel/LevelLabel
@onready var time_label: Label = $Panel/TimeLabel
@onready var turn_label: Label = $Panel/TurnLabel
@onready var mark_label: Label = $Panel/MarkLabel
@onready var undo_label: Label = $Panel/UndoLabel
@onready var undo_button: Button = $Panel/UndoButton
@onready var hp_label: Label = $Panel/HpLabel
@onready var pause_button: Button = $Panel/PauseButton
@onready var restart_button: Button = $Panel/RestartButton


func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("GameManager")
	game_manager.battle_time_changed.connect(update_time)
	game_manager.mark_count_changed.connect(update_mark)
	game_manager.turn_changed.connect(update_turn)
	game_manager.undo_count_changed.connect(update_undo_count)
	game_manager.character.hp_changed.connect(update_hp)
	game_manager.level_changed.connect(update_level)
	game_manager.level_completed.connect(_on_level_end)
	game_manager.level_lost.connect(_on_level_end)
	game_manager.game_state_changed.connect(_on_game_state_changed)
	
	
	update_time(game_manager.battle_time)
	update_mark(game_manager.mark_count)
	update_undo_count(game_manager.undo_count)
	update_hp(game_manager.character._hp, game_manager.character._max_hp)


func update_time(time: int) -> void:
	time_label.text = "Time: " + str(time)


func update_mark(mark_count: int) -> void:
	mark_label.text = "Marks: " + str(mark_count)


func update_turn(turn_count: int) -> void:
	turn_label.text = "Turn: " + str(turn_count)


func update_hp(hp: int, max_hp: int) -> void:
	var color = hp_color if hp > max_hp * low_hp_limit else hp_color_low
	hp_label.text = "HP: " + str(hp) + "/" + str(max_hp)
	hp_label.self_modulate = color


func update_undo_count(undo_count: int) -> void:
	undo_label.text = "Undo left: " + str(undo_count)
	if undo_count <= 0:
		undo_button.disabled = true
	else:
		undo_button.disabled = false


func update_level(level: String) -> void:
	level_label.text = level


func _on_button_pressed() -> void:
	game_manager.restart_game()


func _on_undo_button_pressed() -> void:
	game_manager.undo()


func _on_pause_button_pressed() -> void:
	game_manager.pause()


func _on_game_manager_paused() -> void:
	undo_button.disabled = true


func _on_game_manager_unpaused() -> void:
	undo_button.disabled = false


func _on_level_end() -> void:
	undo_button.disabled = true
	pause_button.disabled = true
	restart_button.disabled = true


func _on_game_state_changed(game_state: GameManager.GameState) -> void:
	if game_state == GameManager.GameState.START:
		undo_button.disabled = false
		pause_button.disabled = false
		restart_button.disabled = false
