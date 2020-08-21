class Audio extends Node:
		# Classe de propósito geral que lida com gerenciamento do áudio.
	
	signal volume_changed(channel_id, volume)
	signal mute_toggled(channel_id, is_muted)
	
	const VOLUME_STEP = 0.1
	
	
	func increase_volume(channel: int = AudioServer.get_bus_index("Master")) -> void:
		set_volume(linear2db(db2linear(AudioServer.get_bus_volume_db(channel))  + VOLUME_STEP), channel)
	
	
	func decrease_volume(channel: int = AudioServer.get_bus_index("Master")) -> void:
		set_volume(linear2db(db2linear(AudioServer.get_bus_volume_db(channel))  - VOLUME_STEP), channel)
	
	
	func set_volume(value: float, channel: int = AudioServer.get_bus_index("Master")) -> void:
		
		var is_muted := AudioServer.is_bus_mute(channel)
		var mute := is_muted
		
		if value <= -80:
			
			if not is_muted:
				mute = true
			
		elif value <= 0:
			
			AudioServer.set_bus_volume_db(channel, value)
			emit_signal("volume_changed", channel, value)
			
			if is_muted:
				mute = false
		
		if is_muted != mute:
			
			mute_toggle(channel)
	
	
	func mute_toggle(channel: int = AudioServer.get_bus_index("Master")) -> void:
		var value = not AudioServer.is_bus_mute(channel)
		
		AudioServer.set_bus_mute(channel, value)
		emit_signal("mute_toggled", channel, value)


class Video extends Audio:
	# Classe de propósito geral que lida com gerenciamento do vídeo.
	signal fullscreen_mode_changed
	
	
	func set_fullscreen(mode: bool = !OS.window_fullscreen) -> void:
		
		OS.window_fullscreen = mode
		emit_signal("fullscreen_mode_changed")
