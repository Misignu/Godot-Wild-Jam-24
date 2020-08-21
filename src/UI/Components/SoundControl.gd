tool
extends MarginContainer

const CHANNELS := [
	"Master",
	"SFXs",
]
export(int, "Master", "SFXs") var channel: int setget set_channel

onready var mute_button := $HBoxContainer/Mute as CheckBox
onready var volume_slider := $HBoxContainer/VolumeSlider as HSlider


func _ready() -> void:
	_setup_slider()
	
	if Engine.is_editor_hint():
		return
	
	if UI.connect("mute_toggled", self, "_on_UI_mute_toggled") != OK or(
			UI.connect("volume_changed", self, "_on_UI_volume_changed") != OK
	):
		push_error("Wouldn't able to connect %s to %s." % [UI, self])


# WATCH
func _on_UI_mute_toggled(channel_id: int, is_muted: bool) -> void:
	
	if channel_id == channel and is_muted == mute_button.pressed:
		mute_button.pressed = not is_muted


# WATCH
func _on_UI_volume_changed(channel_id: int, volume: float) -> void:
	volume = db2linear(volume)
	
	if channel_id == channel and volume != volume_slider.value:
		volume_slider.value = volume


func _on_Mute_toggled(button_pressed: bool) -> void:
	
	if AudioServer.is_bus_mute(channel) == button_pressed:
		UI.mute_toggle(channel)


func _on_VolumeSlider_value_changed(volume: float) -> void:
	UI.set_volume(linear2db(volume), channel)


func _setup_slider() -> void:
	
	volume_slider.min_value = 0.0001
	volume_slider.max_value = 1
	volume_slider.step = 0.1
	volume_slider.value = db2linear(AudioServer.get_bus_volume_db(channel))


func set_channel(value: int) -> void:
	
	channel = value
	
	if mute_button:
		mute_button.text = CHANNELS[value]
