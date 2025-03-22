extends RefCounted
class_name TurnData

var turn_number: int
var commands: Array[Command]


func _init(turn: int, command_list: Array[Command]) -> void:
	turn_number = turn
	commands = command_list
