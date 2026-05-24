class_name SceneSwitcher
extends Node

var _current_scene: Node = null
var _next_level_string: String = ""


func _ready() -> void:
	_current_scene = get_tree().current_scene


func switch_scene(new_scene) -> void:
	print("SceneSwitcher.switch_scene: switch to " + new_scene)
	_next_level_string = new_scene
	Transition.play_transition_in(on_anim_fade_in_ended)


func on_anim_fade_in_ended() -> void:
	assert(_current_scene.has_method("cleanup"))
	_current_scene.cleanup()

	
	Transition.play_loading_screen_anim()
	await get_tree().create_timer(2.0).timeout
	# TODO load async
	var new_scene = load(_next_level_string).instantiate()
	_current_scene = new_scene
	_current_scene.init_done.connect(on_init_done)
	get_tree().root.add_child(_current_scene)
	_next_level_string = ""


func on_init_done() -> void:
	Transition.play_transition_out()
