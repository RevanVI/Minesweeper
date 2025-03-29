class_name EnemyEnteredCommand
extends Command

var _enemy: Enemy
var _damage: int


func _init(enemy: Enemy) -> void:
	super()
	_enemy = enemy


func _execute() -> void:
	#map.mark_cell(mark_pos)
	_damage = _enemy.get_damage()
	print("Damage taken: "  + str(_damage))


func _undo() -> void:
	print("Damage returned: " + str(_damage))
