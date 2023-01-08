extends VBoxContainer

var item_name

onready var cursor = $TextureRect/Cursor
onready var label = $Label

func setup(item, count):
	item_name = item
	update_count(count)

func update_count(count):
	label.text = str(count)

func select():
	cursor.show()

func deselect():
	cursor.hide()
