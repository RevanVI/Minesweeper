class_name EnemyEnteredCommand
extends Command

var _character: Character
var _enemy: Enemy
var _damage: int


func _init(character: Character, enemy: Enemy) -> void:
	super()
	_character = character
	_enemy = enemy


func _execute() -> void:
	_damage = _enemy.get_damage()
	_character.take_damage(_damage)


func _undo() -> void:
	_character.restore_hp(_damage)
