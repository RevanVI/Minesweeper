extends Node2D
class_name Enemy

#
#func _init() -> void:
	#print('enemy init here')
#
#func _ready() -> void:
	#print('enemy ready here')

func get_damage() -> int:
	return randi_range(1, 4)
