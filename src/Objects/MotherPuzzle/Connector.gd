extends Node2D

onready var tween: Tween = $Tween
onready var timer: Timer = $Timer
onready var button: Button = $Button


# animate the rotation of the connector
func _on_Button_pressed() -> void:
	var _err: bool
	
	if timer.is_stopped():
		timer.wait_time = 0.5
		_err = tween.interpolate_property(self, "rotation", rotation, rotation + PI/2, 0.5)
		
		if not tween.is_active():
			_err = tween.start()
		
		timer.start()


func switch_enabled() -> void:
	button.disabled = not button.disabled
