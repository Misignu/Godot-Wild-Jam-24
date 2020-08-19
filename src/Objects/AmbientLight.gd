extends CanvasModulate

export var _is_on: bool = true


func _ready() -> void:
	visible = true
	_set_is_on(_is_on)
	
	if _is_on:
		color = Color.white
		
	else:
		color = Color.black


func turn_lights(to_on: bool) -> void:
	($AnimationPlayer as AnimationPlayer).play("fade_in" if to_on else "fade_out")


func _set_is_on(value: bool) -> void:
	_is_on = value
	get_tree().call_group("enemies", "_on_lights_turned", _is_on)
