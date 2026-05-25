@tool
class_name CursorLight
extends PointLight2D

enum LightSize {
	L128 = 0,
	L192 = 1,
	L256 = 2,
}

@export var light_size: LightSize:
	set(new_light_size):
		light_size = new_light_size
		_update_light_size()
@export var light_enabled: bool = true:
	set(new_light_enabled):
		light_enabled = new_light_enabled
		_update_light_enabled()
@export var scene_darkened: bool = true:
	set(new_scene_darkened):
		scene_darkened = new_scene_darkened
		_update_scene_lighting()

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var canvas_modulate: CanvasModulate = $CanvasModulate


func _ready() -> void:
	_update_light_size()
	_update_light_enabled()
	_update_scene_lighting()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var mouse_world_pos: Vector2 = get_global_mouse_position()
	position = mouse_world_pos


func _update_light_size() -> void:
	print(LightSize.keys()[light_size])
	anim_player.play(str(LightSize.keys()[light_size]))


func _update_scene_lighting() -> void:
	canvas_modulate.visible = scene_darkened


func _update_light_enabled() -> void:
	enabled = light_enabled
