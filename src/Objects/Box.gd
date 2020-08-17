tool
extends KinematicBody2D

signal sliding_started
signal sliding_finished

const MOVE_SPEED: float = .125

export var path_finder_path: NodePath setget set_path_finder_path
var state: int
var grid_size: int = 16
var last_position: Vector2
var path_finder: TileMap
var inputs = {
	"move_up": Vector2.UP,
	"move_down": Vector2.DOWN,
	"move_left": Vector2.LEFT,
	"move_right": Vector2.RIGHT,
}
onready var raycast := $RayCast2D as RayCast2D
onready var tween := $Tween as Tween


func _ready() -> void:
	
	if Engine.is_editor_hint() or path_finder_path.is_empty():
		set_process(false)
		
	else:
		_setup()


func _get_configuration_warning() -> String:
	var warning: String
	
	if path_finder_path.is_empty():
		warning = "The var [path_finder_path: NodePath] can't be empty."
		
	elif not get_node(path_finder_path) is TileMap:
		warning = str(warning, "The var [path_finder_path] should point to a node of type Tilemap.")
	
	return warning


func _on_Tween_tween_all_completed() -> void:
	path_finder.remove_obstacle(last_position)
	emit_signal("sliding_finished")


func move(key: String) -> bool:
	var direction: Vector2 = inputs[key] * grid_size
	var could_move: bool
	
	raycast.cast_to = direction
	raycast.force_raycast_update()
	
	if not raycast.is_colliding():
		_slide(direction)
		could_move = true
	
	return could_move


func _slide(direction: Vector2) -> void:
	var target_position: Vector2 = global_position + direction
	
	if not(
		tween.interpolate_property(
				self, "global_position", global_position, target_position, MOVE_SPEED,
				Tween.TRANS_SINE
		) and tween.start()
	):
		push_error("Wouldn't able to interpolate property 'global_position' at %s." % self)
	
	last_position = global_position
	path_finder.add_obstacle(target_position)
	emit_signal("sliding_started")


func _setup() -> void:
	
	path_finder = get_node(path_finder_path)
	path_finder.add_obstacle(global_position)


func set_path_finder_path(value: NodePath) -> void:
	path_finder_path = value
	update_configuration_warning()
