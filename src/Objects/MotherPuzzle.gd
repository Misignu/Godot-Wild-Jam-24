extends Node

var energy_in_charged: = []
var output_index: int = -1
var output_percentage: = ["25%\n", "75%\n"]

onready var button: Button = $VBoxContainer/MarginContainer/VBoxContainer2/HBoxContainer/Button
onready var output: RichTextLabel = $VBoxContainer/MarginContainer/VBoxContainer2/Panel/MarginContainer/RichTextLabel
onready var timer: Timer = $Timer
onready var energy_in_1: Polygon2D = $VBoxContainer/CenterContainer/InterestPoints/EnergyIn1
onready var energy_in_2: Polygon2D = $VBoxContainer/CenterContainer/InterestPoints/EnergyIn2
onready var energy_in_3: Polygon2D = $VBoxContainer/CenterContainer/InterestPoints/EnergyIn3


func _ready() -> void:
	energy_in_1.connect("EnergyIn_full_charged", self, "on_EnergyIn_full_charged")
	energy_in_2.connect("EnergyIn_full_charged", self, "on_EnergyIn_full_charged")
	energy_in_3.connect("EnergyIn_full_charged", self, "on_EnergyIn_full_charged")


func _on_Button_pressed() -> void:
	button.disabled = true
	get_tree().call_group("connector_button", "switch_enabled")
	output.text += "--- Compilation process started ---\n"
	timer.wait_time = 1
	get_tree().call_group("energy_out", "turn_on")
	timer.start()


func _on_Timer_timeout() -> void:
	output_index += 1
	
	if output_index < 2:
		output.text += output_percentage[output_index]
		timer.wait_time = 1
		timer.start()

	elif output_index == 2:
		get_tree().call_group("shapes", "verify_energy")
	
	else:
		reset()


func on_EnergyIn_full_charged(state: bool) -> void:
	energy_in_charged.append(state)
	
	if energy_in_charged.size() == 3:
		if energy_in_charged[0] and energy_in_charged[1] and energy_in_charged[2]:
			success_message()
		else:
			error_message()


func success_message():
	output.text += "Hacking successful!"
	timer.set_process(false)


func error_message():
	output.text += "Compilation error!"
	timer.wait_time = 1
	timer.start()


func reset() -> void:
	energy_in_charged = []
	button.disabled = false
	output.text = ""
	output_index = -1
	
	get_tree().call_group("shapes", "reset")
	get_tree().call_group("energy_out", "reset")
	get_tree().call_group("connector_button", "switch_enabled")
