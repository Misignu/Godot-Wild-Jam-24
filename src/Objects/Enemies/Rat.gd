tool
extends "res://src/Objects/Enemy.gd"

enum States {
	IDLE,
	WANDER,
	FOLLOW,
	ATTACK,
	RETURN,
}
const BASE_SIZE: float = 16.0
var state: int
onready var wander_controller: Node2D = $Axis/WanderController
onready var raycast := $Axis/RayCast2D as RayCast2D


func _setup() -> void:
	._setup()
	call_deferred("_on_lights_turned", _are_lights_on)


func _on_lights_turned(value: bool) -> void:
	
	._on_lights_turned(value)
	self.target_position = wander_controller.start_position
	raycast.enabled = not value


func _on_target_achieved() -> void:
	
	match state:
		
		States.RETURN:
			state = States.IDLE
			continue
		
		States.IDLE:
			return
		
		States.FOLLOW:
			
			if player_detection.player != null:
				_attack(player_detection.player)
				state = States.ATTACK
	
	if not player_detection.can_see_player():
		wander_controller.start_wander_timer()
		state = States.IDLE


func _attack(player: Node2D) -> void:
	player.take_damage()
	state = States.IDLE


func step(location: Vector2) -> void:
	
	if state == States.ATTACK:
		return
	
	if _are_lights_on:
		_step_on_light(location)
		
	else:
		_step_on_dark(location)


func _step_on_light(location: Vector2) -> void:
	
	if not player_detection.can_see_player():
		_wander()
		return
	
	self.target_position = location
	_follow_path()
	state = States.FOLLOW


func _follow_path() -> void:
	_slide()
	
	if OS.is_debug_build() and len(path) != 0:
		var line: Line2D = UI.get_tool("DebugLine")
		var points := PoolVector2Array()
		
		for point in path:
			points.append(Vector2(point.x, point.y) + (Vector2.ONE * BASE_SIZE)/ 2)
		
		line.points = points
		line.default_color = Color.red + Color(0, 0, 0, line.default_color.a - 1)


func _step_on_dark(location: Vector2) -> void:
	var started_following: bool
	
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		state = States.FOLLOW
		started_following = true
	
	match state:
		
		States.IDLE:
			return
		
		States.FOLLOW:
			
			if started_following or len(path) > 1:
				self.target_position = location
				
			else:
				_attack(player_detection.player)
				state = States.ATTACK
		
		States.RETURN:
			pass
		
		_:
			state = States.RETURN
			self.target_position = wander_controller.start_position
	
	if len(path) > 1:
		_follow_path()


func _wander() -> void:
	
	if (state == States.IDLE and not wander_controller.is_updating()) or (
			len(path) <= 1
	):
		# WATCH
		wander_controller.update_target_position()
		self.target_position = wander_controller.target_position
	
	_slide()
	state = States.WANDER
	
	if OS.is_debug_build() and len(path) != 0:
		var line: Line2D = UI.get_tool("DebugLine")
		var points := PoolVector2Array()
		
		for point in path:
			points.append(Vector2(point.x, point.y) + (Vector2.ONE * BASE_SIZE)/ 2)
		
		line.points = points
		line.default_color = Color.purple + Color(0, 0, 0, line.default_color.a - 1)
