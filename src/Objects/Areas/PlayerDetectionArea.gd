extends Area2D

var player: PhysicsBody2D


func can_see_player() -> bool:
	return player != null


func _on_PlayerDetection_body_entered(body: PhysicsBody2D) -> void:
	player = body


func _on_PlayerDetection_body_exited(_body: PhysicsBody2D) -> void:
	player = null
