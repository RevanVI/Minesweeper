class_name TransitionAnim
extends CanvasLayer 


signal fade_in_completed()
signal fade_out_completed()


@onready var animation_player: AnimationPlayer = $Control/ColorRect/AnimationPlayer
@onready var control_node: Control = $Control


func play_transition_in(callback: Callable) -> void:
	print("TransitionAnim.play_transition_in")
	control_node.mouse_filter = Control.MOUSE_FILTER_STOP
	animation_player.play('transition_fade')
	await animation_player.animation_finished
	fade_in_completed.emit()
	if callback.is_null() == false:
		callback.call()


func play_transition_out() -> void:
	print("TransitionAnim.play_transition_out")
	animation_player.play_backwards('transition_fade')
	await animation_player.animation_finished
	control_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_out_completed.emit()


func play_loading_screen_anim() -> void:
	print("TransitionAnim.play_loading_screen_anim")
	animation_player.play('loading')