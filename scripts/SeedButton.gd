extends TextureButton

var seed_type

onready var cursor = $Cursor

func setup(seed_name, icon):
	seed_type = seed_name
	set_normal_texture(load(icon))

func select():
	cursor.show()

func deselect():
	cursor.hide()
