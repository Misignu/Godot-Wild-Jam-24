"""
General-Purpose Script that Pack some Classes that deals with some UI behaviors
"""
extends "res://src/Autoload/UIBase.gd".Video


func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("reload"):
		reload()
		get_tree().set_input_as_handled()


func _unhandled_key_input(event: InputEventKey) -> void:
	
	if not event.is_pressed():
		return
	
	match event.scancode:
		KEY_F11:
			set_fullscreen()
			get_tree().set_input_as_handled()
			
		KEY_F3:
			decrease_volume()
			get_tree().set_input_as_handled()
			
		KEY_F4:
			increase_volume()
			get_tree().set_input_as_handled()


func reload() -> void:
	
	if get_tree().reload_current_scene() != OK:
		push_error("Wouldn't able to reload the current scene.")
