tool
extends Sprite

# TODO -> Implementar IA..
enum States {
	IDLE,
	MOVING,
}
const MASS: float = 10.0
const ARRIVE_DISTANCE: float = .5
const MOVE_SPEED = .125
const PATH_TO_POSITION = NodePath(":global_position")

export var speed: float = 200
export var path_finder_path: NodePath setget set_path_finder_path

var state: int
var target_point: Vector2
var target_position: Vector2 setget set_target_position
var path: PoolVector2Array
var path_finder: TileMap
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


func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	
	if not(object == self and key == PATH_TO_POSITION):
		return
	
	if path:
		path.remove(0)
	state = States.IDLE
	
	# WATCH -> Garante que o ponto de partida não seja considerado.
	if len(path) > 1:
		target_point = path[1]


func step(location: Vector2) -> void:
	
	if target_position != location:
		self.target_position = location
	
	_slide()


func _slide(direction: Vector2 = target_point) -> void:
	
	if not(
		tween.interpolate_property(
				self, PATH_TO_POSITION, global_position, direction, MOVE_SPEED,
				Tween.TRANS_SINE
		) and tween.start()
	):
		push_error("Wouldn't able to interpolate property 'global_position' at %s." % self)
	
	state = States.MOVING


func _update_path() -> void:
	path = path_finder.find_path(global_position, target_position)
	
	if len(path) > 1:
		target_point = path[1]


func _setup() -> void:
	path_finder = get_node(path_finder_path)
	
	if path_finder.connect("obstacle_moved", self, "_on_PathFinder_obstacle_moved") != OK:
		push_error("Wouldn't able to connect %s to %s." % [self, path_finder])


# WATCH -> Verificar a passagem do ponto.
func _on_PathFinder_obstacle_moved(_point: Vector2) -> void:
	_update_path()


func set_target_position(value: Vector2) -> void:
	
	target_position = value
	_update_path()


func set_path_finder_path(value: NodePath) -> void:
	path_finder_path = value
	update_configuration_warning()
