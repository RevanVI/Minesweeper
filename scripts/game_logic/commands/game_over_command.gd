class_name GameOverCommand
extends Command


var undo_callback: Callable

func _execute() -> void:
	print("Game lost")


func _undo() -> void:
	undo_callback.call()
