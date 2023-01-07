extends Control

var last_pressed
var plant_data


func _ready():
	plant_data = get_node("/root/Globals").plant_data
	for button in get_children():
		button.connect("toggled", self, "_on_Button_toggled", [button])

func update_inventory(inventory):
	last_pressed = null
	for child in get_children():
		child.queue_free()

	for item in inventory:
		var button = TextureButton.new()
		button.set_normal_texture(load(plant_data[item].icon))
		add_child(button)

func _on_Button_toggled(is_pressed, button):
	if is_pressed:
		button.modulate = Color.black
		if last_pressed:
			last_pressed.modulate = Color.white
	
	if last_pressed == button:
		button.pressed = false
		last_pressed = null
		button.modulate = Color.white
	else:
		last_pressed = button
