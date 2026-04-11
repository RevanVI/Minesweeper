class_name Character
extends RefCounted

signal hp_changed(hp: int, max_hp: int)
signal damaged()
signal died()

var _max_hp: int = 5
var _hp: int = 5
var _max_undo_count: int = 3
var _undo_count: int = 3


func _init(max_hp: int = 5, max_undo_count: int = 3):
	_max_hp = max_hp
	_hp = _max_hp
	_max_undo_count = max_undo_count
	_undo_count = _max_undo_count


func take_damage(damage: int) -> void:
	_hp -= damage
	hp_changed.emit(_hp, _max_hp)
	damaged.emit()
	print("Character: damage taken " + str(damage))
	if _hp <= 0:
		died.emit()


func restore_hp(amount: int) -> void:
	_hp += amount
	_hp = min(_hp, _max_hp)
	print("Character: hp restored" + str(amount))
	hp_changed.emit(_hp, _max_hp)


func reset() -> void:
	_hp = _max_hp
	_undo_count = _max_undo_count
	hp_changed.emit(_hp, _max_hp)


func get_undo_count() -> int:
	return _undo_count


func set_undo_count(value: int) -> void:
	_undo_count = value
