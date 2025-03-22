extends Command
class_name GameOverCommand

var undo_callback: Callable

func execute() -> void:
	print("Game lost")


func undo() -> void:
	undo_callback.call()
