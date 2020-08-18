extends MarginContainer

var energy_in_charged: = []
var output_index: int = -1
var output_percentage: = ["25%\n", "75%\n"]

onready var button: Button = $PopupPanel/VBoxContainer/MarginContainer/VBoxContainer2/HBoxContainer/Button
onready var output: RichTextLabel = $PopupPanel/VBoxContainer/MarginContainer/VBoxContainer2/Panel/MarginContainer/RichTextLabel
onready var timer: Timer = $Timer
onready var energy_in_1: Polygon2D = $PopupPanel/VBoxContainer/CenterContainer/InterestPoints/EnergyIn1
onready var energy_in_2: Polygon2D = $PopupPanel/VBoxContainer/CenterContainer/InterestPoints/EnergyIn2
onready var energy_in_3: Polygon2D = $PopupPanel/VBoxContainer/CenterContainer/InterestPoints/EnergyIn3
onready var pop_up: PopupPanel = $PopupPanel

signal success


func _ready() -> void:
	if energy_in_1.connect("EnergyIn_full_charged", self, "on_EnergyIn_full_charged") != OK:
		push_error("unable to connect %s to %s." % [self, energy_in_1])
	
	if energy_in_2.connect("EnergyIn_full_charged", self, "on_EnergyIn_full_charged") != OK:
		push_error("unable to connect %s to %s." % [self, energy_in_2])
	
	if energy_in_3.connect("EnergyIn_full_charged", self, "on_EnergyIn_full_charged") != OK:
		push_error("unable to connect %s to %s." % [self, energy_in_3])


func _on_Button_pressed() -> void:
	button.disabled = true
	timer.wait_time = 1
	timer.start()
	output.text += "--- Compilation process started ---\n"
	
	get_tree().call_group("connector_button", "switch_enabled")
	get_tree().call_group("energy_out", "turn_on")


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


func success_message() -> void:
	output.text += "Hacking successful!"
	emit_signal("success")


func error_message() -> void:
	output.text += "Compilation error!"
	timer.wait_time = 1.5
	timer.start()


func reset() -> void:
	energy_in_charged = []
	button.disabled = false
	output.text = ""
	output_index = -1
	
	get_tree().call_group("shapes", "reset")
	get_tree().call_group("energy_out", "reset")
	get_tree().call_group("connector_button", "switch_enabled")


func switch_visible() -> void:
	pop_up.visible = not pop_up.visible
