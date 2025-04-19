extends TextureRect


func _ready() -> void:
	visible = false
	var start_color = Color(0.59, 0.78, 0.71, 0.3)
	var final_color = start_color
	final_color.a = 0.45
	
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(self, "modulate", final_color, 0.2)
	tween.tween_property(self, "modulate", start_color, 0.2)
	tween.set_loops()
	tween.play()


func start_anim() -> void:
	visible = true


func stop_anim() -> void:
	visible = false
