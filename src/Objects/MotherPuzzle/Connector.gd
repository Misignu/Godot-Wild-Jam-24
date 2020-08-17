extends Node2D

var animate: bool
var tween_state: bool

onready var tween: Tween = $Tween
onready var timer: Timer = $Timer
onready var shape: Polygon2D = $Shape


# animate the rotation of the connector
func _on_Button_pressed() -> void:
	if timer.is_stopped():
		timer.wait_time = 0.5
		animate = tween.interpolate_property(self, "rotation", rotation, rotation + PI/2, 0.5)
		
		if not tween.is_active():
			tween_state = tween.start()
		
		timer.start()

# wait for the answer verification
func wait():
	timer.wait_time = 0.7
	timer.start()
