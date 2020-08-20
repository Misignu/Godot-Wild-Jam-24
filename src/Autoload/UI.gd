"""
General-Purpose Script that Pack some Classes that deals with some UI behaviors
"""
extends "res://src/Autoload/UIBase.gd".Video


func _ready() -> void:
	randomize()


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


func get_tool(tool_name: String, target_node: Node = self) -> Node:
	var tool_node: Node
	
	if target_node.has_node(tool_name):
		tool_node = target_node.get_node(tool_name) as Node
		
	else:
		tool_node = (load("res://src/Tools/%s.tscn" % tool_name) as PackedScene).instance() as Node
		target_node.add_child(tool_node)
	
	return tool_node
