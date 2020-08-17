tool
extends Navigation2D

export var target_path: NodePath setget set_target_path
var target: Node2D


func _ready() -> void:
	
	if not target:
		set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	
	if not event is InputEventMouseButton or (
			event.button_index != BUTTON_LEFT or not event.pressed
	):
		return
	
	target.path = _get_fixed_path(event.position)
	get_tree().set_input_as_handled()


func _get_configuration_warning() -> String:
	var warning: String
	
	if target_path.is_empty():
		return warning
	
	if not get_node(target_path) is Node2D:
		warning = "'target_path' must target a valid Node2D node."
		
	elif not target.has_method("set_path"):
		warning = "'target_path' must target a Node2D with a valid 'path':[set_path(PoolVector2Array)'] property."
	
	return warning


func _get_fixed_path(to: Vector2) -> PoolVector2Array:
	var new_path := PoolVector2Array()
	
	# WATCH -> Quase lá !!!
	for point in get_simple_path(target.global_position, to):
		new_path.append(point.snapped(Vector2.ONE * 16))
	
	# Will print path on debugg build
	if OS.is_debug_build():
		var line: Line2D
		
		if not has_node("DebugLine"):
			
			line = load("res://src/Tools/DebugLine.tscn").instance()
			add_child(line)
			
		else:
			line = get_node("DebugLine")
		
		line.points = new_path
	
	return new_path


func set_target_path(value: NodePath) -> void:
	target_path = value
	update_configuration_warning()
	
	if value.is_empty():
		target = null
		set_process_unhandled_input(false)
		
	else:
		call_deferred("_deffered_set_target_from_path", value)


func _deffered_set_target_from_path(path: NodePath) -> void:
	
	assert(get_node(target_path) is Node2D)
	target = get_node(path)
	set_process_unhandled_input(true)
