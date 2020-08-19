extends TileMap

signal obstacle_moved(point)

const OBSTACLES_ID = 1
export var astar_map_size := Vector2(20, 11)

var path_start_position: Vector2 setget _set_path_start_position
var path_end_position: Vector2 setget _set_path_end_position
# WATCH
var path_points := PoolVector3Array()

var astar := AStar.new()
onready var obstacles: Array = get_used_cells_by_id(OBSTACLES_ID)


func _ready() -> void:
	var walkable_cells: Array = astar_add_walkable_cells()
	astar_connect_walkable_cells(walkable_cells)


func astar_add_walkable_cells() -> Array:
	var point: Vector2
	var points := Array()
	
	for y in range(astar_map_size.y):
		
		for x in range(astar_map_size.x):
			point = Vector2(x, y)
			
			if point in obstacles:
				continue
			
			points.append(point)
			astar.add_point(get_point_index(x, y), Vector3(point.x, point.y, 0.0))
	
	return points


func astar_connect_walkable_cells(points: Array) -> void:
	
	for point in points:
		astar_connect_cell(point.x, point.y)


func astar_connect_cell(x: int, y: int) -> void:
	var point_index: int = get_point_index(x, y)
	var relative_points: PoolVector2Array
	var relative_point_index: int
	
	relative_points = PoolVector2Array([
		Vector2(x + 1, y),
		Vector2(x - 1, y),
		Vector2(x, y + 1),
		Vector2(x, y - 1),
	])
	
	for relative_point in relative_points:
		relative_point_index = get_point_index(relative_point.x, relative_point.y)
		
		if is_out_of_bounds(relative_point) or not astar.has_point(relative_point_index):
			continue
		
		# WATCH -> Modo bilateral desativado.
		astar.connect_points(point_index, relative_point_index, false)


func find_path(world_start: Vector2, world_end: Vector2) -> PoolVector2Array:
	
	var point_global_position: Vector2
	var path := PoolVector2Array()
	self.path_start_position = world_to_map(world_start)
	self.path_end_position = world_to_map(world_end)
	 # WATCH -> Essa chamada pode ser uma duplicata.
	_update_path()
	
	for point in path_points:
		
		point_global_position = map_to_world(Vector2(point.x, point.y))
		path.append(point_global_position)
	
	return path


func add_obstacle(point: Vector2) -> void:
	# WATCH -> Verificação de segurança.
	point = world_to_map(point)
	assert(not point in obstacles)
	
	if is_out_of_bounds(point):
		return
	
	obstacles.append(point)
	astar.remove_point(get_point_index(point.x as int, point.y as int))
	
	if path_end_position and path_end_position != path_start_position:
		_update_path()
		pass
	
	emit_signal("obstacle_moved", point)


func remove_obstacle(point: Vector2) -> void:
	point = world_to_map(point)
	var x := point.x as int
	var y := point.y as int
	var relative_points := PoolVector2Array([
		Vector2(x + 1, y),
		Vector2(x - 1, y),
		Vector2(x, y + 1),
		Vector2(x, y - 1),
	])
	
	obstacles.erase(point)
	astar.add_point(
			get_point_index(x, y),
			Vector3(point.x, point.y, 0.0)
	)
	
	for relative_point in relative_points:
		
		if is_out_of_bounds(relative_point) or not astar.has_point(
				get_point_index(relative_point.x, relative_point.y)
		):
			continue
		
		astar_connect_cell(relative_point.x, relative_point.y)
	
	if path_end_position and path_end_position != path_start_position:
		_update_path()
		pass
	
	emit_signal("obstacle_moved", point)


func _update_path() -> void:
	
	path_points = astar.get_point_path(
			get_point_index(path_start_position.x as int, path_start_position.y as int),
			get_point_index(path_end_position.x as int, path_end_position.y as int)
	)
	
	if OS.is_debug_build() and len(path_points) != 0:
		var line: Line2D
		var points := PoolVector2Array()
		
		if has_node("DebugLine"):
			line = get_node("DebugLine") as Line2D
			
		else:
			line = (load("res://src/Tools/DebugLine.tscn") as PackedScene).instance() as Line2D
			add_child(line)
		
		for point in path_points:
			points.append(Vector2(point.x, point.y) * cell_size + cell_size / 2)
		
		line.points = points


func is_out_of_bounds(point: Vector2) -> bool:
	return point.x < 0 or point.y < 0 or point.x >= astar_map_size.x or point.y >= astar_map_size.y


func get_point_index(x: int, y: int) -> int:
	return int(x + astar_map_size.x * y)


func _set_path_start_position(value: Vector2) -> void:
	
	if value in obstacles or is_out_of_bounds(value):
		return
	
	path_start_position = value
	
	if path_end_position and path_end_position != path_start_position:
		_update_path()
		pass


func _set_path_end_position(value: Vector2) -> void:
	
	if value in obstacles or is_out_of_bounds(value):
		return
	
	path_end_position = value
	
	if path_start_position != value:
		_update_path()
		pass
