extends Node2D

export var wonder_range: float = 30.0
onready var start_position: Vector2 = global_position
onready var target_position: Vector2
onready var timer := $Timer as Timer


func _ready() -> void:
	update_target_position()


func update_target_position() -> void:
	var target := Vector2(
			rand_range(-wonder_range, wonder_range),
			rand_range(-wonder_range, wonder_range)
	)
	target_position = start_position + target


func start_wander_timer(duration: int = timer.wait_time) -> void:
	timer.start(duration)


func is_updating() -> bool:
	return timer.time_left > 0
