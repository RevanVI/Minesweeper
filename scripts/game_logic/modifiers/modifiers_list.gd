class_name ModifiersList
extends RefCounted

var _modifiers: Array[ModifierBase]


func add_modifier(modifier: ModifierBase) -> void:
	if _check_modifier_match(modifier):
		_modifiers.append(modifier)
	# TODO print errors or assert if failed?


func add_modifiers(modifiers: Array[ModifierBase]) -> void:
	for modifier in modifiers:
		add_modifier(modifier)


func get_modifier_by_tag(tag: ModifierBase.ModifierTag) -> ModifierBase:
	for i in _modifiers:
		if tag in i.tags:
			return i
	return null


func get_all_tags() -> Array[ModifierBase.ModifierTag]:
	var all_tags: Array[ModifierBase.ModifierTag] = []
	for i in _modifiers:
		for tag in i.tags:
			if tag not in all_tags:
				all_tags.append(tag)
	return all_tags


func _check_modifier_match(modifier: ModifierBase) -> bool:
	var all_tags: Array[ModifierBase.ModifierTag] = get_all_tags()
	for tag in modifier.tags:
		if tag in all_tags:
			return false
	return true
