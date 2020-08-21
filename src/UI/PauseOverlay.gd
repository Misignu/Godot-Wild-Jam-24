extends Node

const PATH_TO_SHADER_AMOUNT := NodePath("Control/Blurpanel:material:shader_param/amount")
const PATH_TO_SHADER_TINT := NodePath("Control/Blurpanel:material:shader_param/tint")
const FADE_DURATION: float = .3

onready var popup := $Popup as Popup
onready var tween := $Tween as Tween
onready var confirmation_dialog := $Popup/ConfirmationDialog as ConfirmationDialog
onready var blur_panel := $Popup/Blurpanel as Panel


func _ready() -> void:
	
	if UI.connect("game_paused", self, "fade_in") != OK:
		push_error("Wouldn't able to connect %s to %s." % [UI, self])


func _on_ConfirmationDialog_confirmed():
	get_tree().quit()


func fade_in() -> void:
	_fade_panel(0, 2)
	
	popup.popup()
	confirmation_dialog.modulate.a = 0
	confirmation_dialog.popup()
	
	if not (
		tween.stop(confirmation_dialog, "modulate:a") and
		tween.interpolate_property(confirmation_dialog, "modulate:a", 0, 1, FADE_DURATION) and
		tween.start()
	):
		push_error("Wouldn't able to interpolate property modulate:a at %s." % confirmation_dialog)


func fade_out() -> void:
	_fade_panel(2, 0)
	
	yield(tween, "tween_completed")
	UI.set_paused(false)
	popup.hide()


func _fade_panel(from: float, to: float) -> void:
	
	if not (tween.stop(blur_panel, PATH_TO_SHADER_AMOUNT.get_as_property_path()) and
		tween.interpolate_property(
			blur_panel, PATH_TO_SHADER_AMOUNT.get_concatenated_subnames(), from, to, FADE_DURATION,
			Tween.TRANS_SINE, Tween.EASE_OUT
	) and tween.start()):
		push_error("Wouldn't able to interpolate %s." % PATH_TO_SHADER_AMOUNT)
