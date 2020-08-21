tool
extends Sprite

const MASS: float = 10.0
const ARRIVE_DISTANCE: float = .5
const MOVE_SPEED: float = .125
const PATH_TO_POSITION := NodePath(":global_position")

export var path_finder_path: NodePath setget set_path_finder_path

var _are_lights_on: bool = true setget _on_lights_turned
var target_point: Vector2
var target_position: Vector2 setget set_target_position
var path: PoolVector2Array
var path_finder: TileMap

onready var player_detection: Area2D = $Axis/PlayerDetectionArea
onready var tween := $Tween as Tween


func _ready() -> void:
	
	if Engine.is_editor_hint() or path_finder_path.is_empty():
		set_process(false)
		set_process_unhandled_input(false)
		
	else:
		_setup()


func _get_configuration_warning() -> String:
	var warning: String
	
	if path_finder_path.is_empty():
		warning = "The var [path_finder_path: NodePath] can't be empty."
		
	elif not get_node(path_finder_path) is TileMap:
		warning = str(warning, "The var [path_finder_path] should point to a node of type Tilemap.")
	
	return warning


func _on_lights_turned(value: bool) -> void:
	_are_lights_on = value


func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	
	if not(object == self and key == PATH_TO_POSITION):
		return
	
	if path:
		path.remove(0)
		_on_path_changed()
	
	#_on_steped() # WATCH


func step(_location: Vector2) -> void:
	pass


# WATCH
#func _on_steped() -> void:
#	pass 


func _on_path_changed() -> void:
	
	if len(path) > 1:
		target_point = path[1]
		
	else:
		_on_target_achieved()


func _on_target_achieved() -> void:
	pass


func _slide(direction: Vector2 = target_point) -> void:
	
	if not(
		tween.interpolate_property(
				self, PATH_TO_POSITION, global_position, direction, MOVE_SPEED,
				Tween.TRANS_SINE
		) and tween.start()
	):
		push_error("Wouldn't able to interpolate property 'global_position' at %s." % self)


func _update_path() -> void:
	path = path_finder.find_path(global_position, target_position)
	_on_path_changed()


func _setup() -> void:
	path_finder = get_node(path_finder_path)
	
	if path_finder.connect("obstacle_moved", self, "_on_PathFinder_obstacle_moved") != OK:
		push_error("Wouldn't able to connect %s to %s." % [self, path_finder])


# WATCH -> Verificar a passagem do ponto.
func _on_PathFinder_obstacle_moved(_point: Vector2) -> void:
	_update_path()


func set_target_position(value: Vector2) -> void:
	
	if target_position == value:
		return
	
	target_position = value
	_update_path()


func set_path_finder_path(value: NodePath) -> void:
	path_finder_path = value
	update_configuration_warning()
