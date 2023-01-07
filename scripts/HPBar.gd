extends HBoxContainer

onready var bar = $Bar

func update_value(value):
	bar.value = value
