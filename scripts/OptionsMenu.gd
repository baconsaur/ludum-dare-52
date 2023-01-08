extends Control

onready var music_bus = AudioServer.get_bus_index("Music")
onready var sounds_bus = AudioServer.get_bus_index("Sound")
onready var sound_slider = $NinePatchRect/MarginContainer/ContentContainer/ButtonContainer/SoundVolumeControl/SoundSlider
onready var music_slider = $NinePatchRect/MarginContainer/ContentContainer/ButtonContainer/MusicVolumeControl/MusicSlider

func _ready():
	sound_slider.grab_focus()
	sound_slider.value = db2linear(AudioServer.get_bus_volume_db(sounds_bus))
	music_slider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()

func _on_BackButton_pressed():
	queue_free()


func _on_SoundSlider_value_changed(value):
	AudioServer.set_bus_volume_db(sounds_bus, linear2db(value))


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, linear2db(value))
