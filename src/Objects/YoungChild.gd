extends KinematicBody2D

const MOVE_SPEED = .125

var grid_size: int = 16
var inputs = {
	"move_up": Vector2.UP,
	"move_down": Vector2.DOWN,
	"move_left": Vector2.LEFT,
	"move_right": Vector2.RIGHT,
}
onready var raycast: = $RayCast2D as RayCast2D
onready var tween := $Tween as Tween


func _unhandled_input(event: InputEvent) -> void:
	
	for direction in inputs.keys():
		
		if event.is_action_pressed(direction):
			move(direction)


func move(key: String) -> void:
	var direction: Vector2 = inputs[key] * grid_size
	var collider: Node2D
	
	raycast.cast_to = direction
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		collider = raycast.get_collider()
		
		if collider.is_in_group("boxes"):
			
			if collider.move(key):
				_slide(direction)
		
	else:
		_slide(direction)


func _slide(direction: Vector2) -> void:
	
	if not(
		tween.interpolate_property(
				self, "position", position, position + direction, MOVE_SPEED,
				Tween.TRANS_SINE
		) and tween.start()
	):
		push_error("Wouldn't able to interpolate property 'position' at %s." % self)
