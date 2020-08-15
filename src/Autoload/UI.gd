"""
General-Purpose Script that Pack some Classes that deals with some UI behaviors
"""
extends "res://src/Autoload/UIBase.gd".Video


func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("reload"):
		reload()
		get_tree().set_input_as_handled()


func reload() -> void:
	get_tree().reload_current_scene()
