extends TextureButton


func _on_SeedButton_toggled(button_pressed):
	var button = group.get_pressed_button()
	if button_pressed:
		print(name + " on")
	else:
		print(name + " off")
