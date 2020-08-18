extends Node

onready var text_box: MarginContainer = $TextBox
onready var puzzle: MarginContainer = $MotherPuzzle
onready var success_timer: Timer = $SuccessTimer


func _ready() -> void:
	if text_box.connect("hacking_time", self, "on_hacking_time") != OK:
		push_error("unable to connect %s to %s." % [self, text_box])
	
	if puzzle.connect("success", self, "on_success") != OK:
		push_error("unable to connect %s to %s." % [self, puzzle])


func _on_Timer_timeout() -> void:
	text_box.show_pop_up()


func on_hacking_time() -> void:
	puzzle.switch_visible()


func on_success():
	success_timer.start()


func _on_SuccessTimer_timeout() -> void:
	puzzle.switch_visible()
	text_box.show_pop_up()
