extends Node
class_name TurnQueue

var turn_queue: Array[TurnData]
var current_turn: int
var turn_commands: Array[Command]

var is_turn_processing: bool = false

signal turn_changed(current_turn: int)
signal undo_started()
signal undo_ended()


func _init() -> void:
	turn_queue = []
	current_turn = 0


func add_command(command: Command) -> void:
	print("Add command started")
	is_turn_processing = true
	command.execute()
	turn_commands.append(command)
	
	if command is EndTurnCommand:
		print("EndTurn. Commands at turn: " + str(turn_commands.size()))
		var turn_data = TurnData.new(current_turn, turn_commands)
		turn_commands = []
		turn_queue.append(turn_data)
		current_turn += 1
		turn_changed.emit(current_turn)
	
	is_turn_processing = false
	print("Add command ended")


func reset() -> void:
	turn_queue.clear()
	turn_commands.clear()
	current_turn = 0
	turn_changed.emit(current_turn)


func undo(count: int) -> void:
	#revert all commands since last EndTurnCommand
	#this can be done any time
	is_turn_processing = true
	var TURN_PAUSE = 0.2
	undo_started.emit()
	
	count = min(count, current_turn)
	
	while turn_commands.size() > 0 || count > 0:
		print('Turn commands undo')
		for i in range(turn_commands.size() - 1, -1, -1):
			turn_commands[i].undo()
			await get_tree().create_timer(TURN_PAUSE).timeout
		turn_commands.clear()
		
		if count > 0:
			turn_commands = turn_queue[current_turn - 1].commands
			count -= 1
			current_turn -= 1
			turn_changed.emit(current_turn)
	
	turn_queue.resize(current_turn)
	is_turn_processing = false
	undo_ended.emit()
