class_name EnemyEnteredCommand
extends Command

var _character: Character
var _enemy: Enemy
var _damage: int


func _init(character: Character, enemy: Enemy) -> void:
	super()
	_character = character
	_enemy = enemy


func execute() -> void:
	_damage = _enemy.get_damage()
	_character.take_damage(_damage)


func undo() -> void:
	_character.restore_hp(_damage)
