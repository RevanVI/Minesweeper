extends Node2D
class_name Enemy

@export var damage: Vector2i

#
#func _init() -> void:
	#print('enemy init here')
#
#func _ready() -> void:
	#print('enemy ready here')

func get_damage() -> int:
	return randi_range(damage[0], damage[1])
