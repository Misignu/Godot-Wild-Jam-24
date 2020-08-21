extends Node

const ANIM = "out"

export var start_scene: PackedScene
onready var options: WindowDialog = $Options
onready var pause_overlay: Node = $PauseOverlay


func _ready():
	($MainMenu/VBoxContainer/MenuOptions/Start as ToolButton).grab_focus()
	($PauseOverlay as Node).set_process_input(false)


func _on_Start_pressed() -> void:
	
	if get_tree().change_scene_to(start_scene) != OK:
		push_error("Woldn't able to change to scene %s." % [start_scene])


func _on_Options_pressed():
	options.popup()


func _on_Exit_pressed() -> void:
	pause_overlay.fade_in()
