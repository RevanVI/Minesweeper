class_name Character
extends Node2D

signal hp_changed(hp: int, max_hp: int)
signal damaged()
signal died()


var _max_hp: int = 5
var _hp: int = 5


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
	hp_changed.emit(_hp, _max_hp)
