tool
extends "res://src/Objects/Enemy.gd"

enum States {
	IDLE,
	WANDER,
	FOLLOW,
	ATTACK,
}
const BASE_SIZE: float = 16.0
var state: int
onready var wander_controller: Node2D = $Axis/WanderController


func _on_target_achieved() -> void:
	
	if player_detection.can_see_player():
		_attack(player_detection.player)
		state = States.ATTACK
		
	else:
		wander_controller.start_wander_timer()
		state = States.IDLE


func _attack(player: Node2D) -> void:
	player.take_damage()


func step(location: Vector2) -> void:
	
	if state == States.ATTACK:
		return
	
	if not player_detection.can_see_player():
		_wander()
		return
	
	self.target_position = location
	_slide()
	state = States.FOLLOW
	
	if OS.is_debug_build() and len(path) != 0:
		var line: Line2D = UI.get_tool("DebugLine")
		var points := PoolVector2Array()
		
		for point in path:
			points.append(Vector2(point.x, point.y) + (Vector2.ONE * BASE_SIZE)/ 2)
		
		line.points = points
		line.default_color = Color.red + Color(0, 0, 0, line.default_color.a - 1)


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
