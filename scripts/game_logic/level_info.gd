class_name LevelInfo
extends Resource

@export var base_title: String
@export var title: String

@export var map_generator: MapGenerator
# enemies dict. key - enemy scene, value - vector2i with min and max enemy count
@export var enemies: Dictionary[PackedScene, Vector2i]
# final enemies count
@export var enemies_count: int
# possible random_modifiers list
@export var random_modifiers: Array[ModifierBase]
# count of random_modifiers to choose
@export var modifiers_count: int
# not used for now. POtentially will be used for text and art selections
@export var mine_type: int 


var _enemies: Dictionary[PackedScene, int]
var _modifiers: Array[ModifierBase]
var _rng: RandomNumberGenerator


func get_enemy_count() -> int:
	return enemies_count


func get_enemies_data() -> Dictionary[PackedScene, int]:
	return _enemies


func get_modifiers_data() -> Array[ModifierBase]:
	return _modifiers


func get_generation_seed() -> int:
	if _rng:
		return _rng.seed
	return -1



func generate_level(index: int, gen_seed: int = -1) -> void:
	print("LevelInfo: Generate level")
	_rng = RandomNumberGenerator.new()
	if gen_seed != -1:
		_rng.seed = gen_seed
	else:
		_rng.seed = randi()

	title = base_title + str(index)

	# randomize enemies
	_enemies.clear()
	for enemy in enemies:
		var count = _rng.randi_range(enemies[enemy][0], enemies[enemy][1])
		_enemies[enemy] = count
		enemies_count += count
		assert(count != 0)

	# randomize modifiers
	_modifiers.clear()
	if modifiers_count >= random_modifiers.size():
		_modifiers.append_array(random_modifiers)
	else:
		for i in range(0, modifiers_count):
			var rand_index: int = _rng.randi_range(0, random_modifiers.size() - 1)
			var modif: ModifierBase = random_modifiers[rand_index]
			random_modifiers.remove_at(rand_index)
			_modifiers.append(modif)
	
