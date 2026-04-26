class_name CameraController
extends Camera2D

@export var zoom_limits: Vector2 = Vector2(0.5, 2.0)
@export var zoom_factor: float = 0.1
@export var zoom_duration: float = 0.2
@export var pos_limits: Rect2
@export var speed: float = 10.0

var _zoom_value: float = 1.0
var _zoom_tween: Tween
var _move_vector: Vector2
var _dragging: bool = false
var _last_mouse_position: Vector2


func _process(delta: float) -> void:
	if _dragging:
		var viewport_size: Vector2 = Vector2(get_viewport().size)
		var mouse_position = get_viewport().get_mouse_position()
		mouse_position = mouse_position.clamp(Vector2(0, 0), viewport_size)

		var diff: Vector2 = _last_mouse_position - mouse_position
		_last_mouse_position = mouse_position
		_move(diff * speed / 2.0 * _get_speed_modif() * delta)
		return

	_move_vector = Vector2.ZERO
	_move_vector = Input.get_vector("CameraLeft", "CameraRight", "CameraUp", "CameraDown")
	if _move_vector != Vector2.ZERO:
		_move_vector *= speed * delta
		_move(_move_vector * _get_speed_modif())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("CameraZoomIn"):
		_set_zoom(_zoom_value + zoom_factor)
	elif event.is_action_pressed("CameraZoomOut"):
		_set_zoom(_zoom_value - zoom_factor)
	elif event.is_action_pressed("CameraDrag"):
		_dragging = true
		_last_mouse_position = event.position
	elif event.is_action_released("CameraDrag"):
		_dragging = false


func _set_zoom(value: float) -> void:
	_zoom_value = clamp(value, zoom_limits[0], zoom_limits[1])
	_zoom_tween = create_tween()
	_zoom_tween.tween_property(self, "zoom", Vector2(_zoom_value, _zoom_value), zoom_duration)
	_zoom_tween.play()


func _move(value: Vector2) -> void:
	value = (value + position).clamp(pos_limits.position, pos_limits.end)
	position = value


func _get_speed_modif() -> float:
	# simple linear func by zoom
	# zoom 2.0 gets 0.5 speed
	# zoom 0.7 gets 1.15 speed
	var modif: float = -0.5 * _zoom_value + 1.5
	return modif


func calc_start_position() -> void:
	# TODO rethink it later. different viewport for ui and gameplay seems too much. 
	# Global constant? manual setup in generator?
	var ui_size: float = 0.65 # X anchor of ui control
	if pos_limits:
		var cam_offset: Vector2 = get_viewport().size * Vector2(0.5 - ui_size / 2, 0)
		position = pos_limits.get_center() + cam_offset
	else:
		position = Vector2(0, 0)
