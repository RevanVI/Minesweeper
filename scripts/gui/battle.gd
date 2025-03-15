extends Control


@onready var time_label: Label = $Panel/TimeLabel
@onready var turn_label: Label = $Panel/TurnLabel
@onready var mark_label: Label = $Panel/MarkLabel

var game_manager: GameManager


func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("GameManager")
	game_manager.battle_time_changed.connect(update_time)
	game_manager.mark_count_changed.connect(update_mark)
	game_manager.turn_changed.connect(update_turn)
	
	update_time(game_manager.battle_time)
	update_mark(game_manager.mark_count)
	update_turn(game_manager.turn_count)


func update_time(time: int) -> void:
	time_label.text = "Time: " + str(time)


func update_mark(mark_count: int) -> void:
	mark_label.text = "Marks: " + str(mark_count)


func update_turn(turn_count: int) -> void:
	turn_label.text = "Turn: " + str(turn_count)


func _on_button_pressed() -> void:
	game_manager.restart()
