extends KinematicBody2D

enum State {
	MOVING,
	INTERACTING,
}
export var max_velocity: float = 10
export var speed: float = 10
export var friction: float = 1

var state: int setget set_state
var velocity: Vector2
var last_direction: Vector2
onready var raycast := $RayCast2D as RayCast2D


func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("interact") and raycast.is_colliding():
		_interact(raycast.get_collider())


func _physics_process(delta: float) -> void:
	
	if state == State.INTERACTING:
		return
	
	_move(delta)


func _on_Area_interaction_finished(area: Area2D) -> void:
	state = State.MOVING
	area.disconnect("interacion_finished", self, "_on_Area_interaction_finished")


func _interact(collider: Area2D) -> void:
	
	if collider.connect("interacion_finished", self, "_on_Area_interaction_finished", [collider]) != OK:
		push_error("Wouldn't able to connect %s to %s." % [collider, self])
	
	self.state = State.INTERACTING
	collider.interact()


func _move(delta: float) -> void:
	
	var input_axis := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	_set_animation(input_axis)
	velocity = move_and_slide(_get_motion(input_axis, delta))


func _set_animation(input_axis: Vector2) -> void:
	
	if input_axis != Vector2.ZERO and input_axis != last_direction:
		_direction_change(input_axis)


func _direction_change(direction: Vector2) -> void:
	raycast.cast_to = direction * 32
	$FlashLight.rotation = direction.angle() + PI / 2


func _get_motion(input_axis: Vector2, delta: float) -> Vector2:
	var motion: Vector2 = input_axis * speed
	
	motion += velocity
	motion = motion.move_toward(Vector2.ZERO, delta * pow(speed, friction))
	motion = motion.clamped(max_velocity)
	
	return motion


func set_state(value: int) -> void:
	state = value
