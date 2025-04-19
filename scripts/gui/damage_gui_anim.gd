extends TextureRect


var _color: Color


func _ready() -> void:
	visible = true
	
	_color = self_modulate
	var start_color = _color
	start_color.a = 0
	self_modulate = start_color


func start_anim() -> void:
	var start_color = _color
	start_color.a = 0
	self_modulate = start_color
	
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(self, "self_modulate", _color, 0.1)
	tween.tween_property(self, "self_modulate", start_color, 0.1)
	tween.play()


func _on_character_damaged() -> void:
	start_anim()
