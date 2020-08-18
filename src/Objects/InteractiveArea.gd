extends Area2D

signal interacion_finished


func interact() -> void:
	_finish_interaction()


func _finish_interaction() -> void:
	emit_signal("interacion_finished")
