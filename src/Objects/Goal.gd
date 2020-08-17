extends Area2D

signal occupation_shifted(was_occupied)
var is_occupied: bool setget set_is_occupied


func _on_Goal_body_entered(body: PhysicsBody2D) -> void:
	
	if body.is_in_group("boxes"):
		
		if body.connect("sliding_finished", self, "_on_Box_slide_finished", [body]) != OK:
			push_error("%s wouldn't able to connect to %s." % [body, self])


# Caso o corpo saia antes de reiniciar a animação.
func _on_Goal_body_exited(body: PhysicsBody2D) -> void:
	
	if body.is_in_group("boxes") and is_occupied:
		
		if body.is_connected("sliding_finished", self, "_box_out"):
			body.disconnect("sliding_finished", self, "_on_Box_slide_finished")
			_box_out(body)
			
		else:
			self.is_occupied = false


func _on_Box_slide_finished(body: PhysicsBody2D) -> void:
	
	self.is_occupied = true
	emit_signal("occupation_shifted", is_occupied)
	body.disconnect("sliding_finished", self, "_on_Box_slide_finished")
	
	if body.connect("sliding_started", self, "_box_out", [body]) != OK:
		push_error("%s wouldn't able to connect to %s." % [body, self])


func _box_out(body: PhysicsBody2D) -> void:
	self.is_occupied = false
	body.disconnect("sliding_started", self, "_box_out")


func set_is_occupied(value: bool) -> void:
	is_occupied = value
	emit_signal("occupation_shifted", value)
