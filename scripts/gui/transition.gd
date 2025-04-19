class_name TransitionAnim
extends CanvasLayer 


signal fade_in_completed()
signal fade_out_completed()


@onready var animation_player: AnimationPlayer = $Control/ColorRect/AnimationPlayer


func play_transition_in(callback: Callable) -> void:
	print("Play transition in")
	animation_player.play('transition_fade')
	await animation_player.animation_finished
	fade_in_completed.emit()
	if callback.is_null() == false:
		callback.call()
	play_transition_out()


func play_transition_out() -> void:
	print("Play transition out")
	animation_player.play_backwards('transition_fade')
	await animation_player.animation_finished
	fade_out_completed.emit()
