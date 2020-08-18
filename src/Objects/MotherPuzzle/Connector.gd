extends Node2D

var animate: bool
var tween_state: bool

onready var tween: Tween = $Tween
onready var timer: Timer = $Timer
onready var button: Button = $Button


# animate the rotation of the connector
func _on_Button_pressed() -> void:
	if timer.is_stopped():
		timer.wait_time = 0.5
		animate = tween.interpolate_property(self, "rotation", rotation, rotation + PI/2, 0.5)
		
		if not tween.is_active():
			tween_state = tween.start()
		
		timer.start()


func switch_enabled():
	button.disabled = not button.disabled
