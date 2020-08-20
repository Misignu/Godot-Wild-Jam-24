extends RayCast2D

var is_casting: bool setget set_is_casting
onready var line := $Line2D as Line2D
onready var tween := $Tween as Tween


func _ready() -> void:
	set_physics_process(false)
	line.points[1] = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		self.is_casting = event.pressed


func _physics_process(_delta: float) -> void:
	var cast_point: Vector2 = cast_to
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
	
	line.points[1] = cast_point


func set_is_casting(value: bool) -> void:
	is_casting = value
	set_physics_process(is_casting)
	
	if is_casting:
		appear()
		
	else:
		disappear()


func appear() -> void:
	_animate_line(0, 1)


func disappear() -> void:
	_animate_line(1, 0)


func _animate_line(from: float, to: float) -> void:
	
	if not(
			tween.stop_all() and
			tween.interpolate_property(line, "width", from, to, 0.2) and
			tween.start()
	):
		push_error("Wouldn't able to interpolate 'width' in %s." % line)
