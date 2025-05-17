class_name Modificator
extends Resource


enum TYPE {
	MAP = 0,
	GENERATION = 1,
	ENEMY = 2,
	PLAYER = 3,
}


@export var types: Array[TYPE] 
@export var excluded_modificators: Array[Modificator]
