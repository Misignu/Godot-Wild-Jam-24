tool
extends Sprite

enum States {
	IDLE,
	FOLLOW,
}
const MASS: float = 10.0
const ARRIVE_DISTANCE: float = .5

export var speed: float = 200
export var path_finder_path: NodePath setget set_path_finder_path

var state: int setget set_state
var target_point: Vector2
var target_position: Vector2
var velocity: Vector2
var path: PoolVector2Array
var path_finder: TileMap


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


func _process(delta: float) -> void:
	
	if state != States.FOLLOW:
		return
	
	if _move_to(target_point, delta):
		path.remove(0)
		
		if len(path) == 0:
			self.state = States.IDLE
			
		else:
			target_point = path[0]


# WATCH
func _unhandled_input(event: InputEvent) -> void:
	
	if not event is InputEventMouseButton or (
			event.button_index != BUTTON_LEFT or not event.pressed
	):
		return
	
	if Input.is_key_pressed(KEY_SHIFT):
		global_position = event.position
		global_position = event.position
		
	else:
		target_position = event.position
	
	self.state = States.FOLLOW
	get_tree().set_input_as_handled()
	

func move_to(next_position: Vector2) -> bool:
	return _move_to(next_position, get_process_delta_time())


func _move_to(next_position: Vector2, delta: float) -> bool:
	
	var desired_velocity: Vector2 = (next_position - position).normalized() * speed
	var steering: Vector2 = desired_velocity - velocity
	velocity += steering / MASS
	position += velocity * delta
	
	return position.distance_to(next_position) < ARRIVE_DISTANCE


func _setup() -> void:
	
	path_finder = get_node(path_finder_path)
	self.state = States.IDLE
	
	if path_finder.connect("obstacles_moved", self, "_on_PathFinder_obstacles_moved") != OK:
		push_error("Wouldn't able to connect %s to %s." % [self, path_finder])


func _on_PathFinder_obstacles_moved() -> void:
	print('moved')
	if state == States.FOLLOW:
		_set_state_follow()


func _set_state_follow() -> void:
	
	path = path_finder.find_path(position, target_position)
	
	if not path or len(path) == 1:
		self.state = States.IDLE
		
	else:
		target_point = path[1]


func set_path_finder_path(value: NodePath) -> void:
	path_finder_path = value
	update_configuration_warning()


func set_state(new_state: int) -> void:
	
	if new_state == States.FOLLOW:
		_set_state_follow()
	
	state = new_state
