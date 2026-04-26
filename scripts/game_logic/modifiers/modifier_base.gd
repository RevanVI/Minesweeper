class_name ModifierBase
extends Resource

enum ModifierTag {
	BASE = 0,
    HIDE_CELLS = 1,
    UNDO_BLOCKED = 2,
}


@export var tags: Array[ModifierTag]
