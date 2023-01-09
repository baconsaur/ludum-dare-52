extends Control

signal change_selection

var plant_data
var selected_seed = 0

onready var seed_button_obj = preload("res://scenes/ui/SeedButton.tscn")


func _ready():
	plant_data = get_node("/root/Globals").plant_data.duplicate(true)

func reset():
	select_seed(0)

func remove_seed(index):
	var to_remove = get_child(index)
	to_remove.connect("tree_exited", self, "select_seed", [index])
	to_remove.queue_free()

func add_seed(item):
	var button = seed_button_obj.instance()
	button.setup(item, plant_data[item].icon)
	button.connect("pressed", self, "select_seed", [get_child_count()])
	add_child(button)

func select_seed(index):
	var children = get_children()
	if not children:
		selected_seed = 0
		return
	var last_seed = selected_seed
	selected_seed = clamp(index, 0, children.size() - 1)
	
	for i in range(children.size()):
		if i == selected_seed:
			children[i].select()
		else:
			children[i].deselect()
	if last_seed != selected_seed:
		emit_signal("change_selection")

func select_left():
	select_seed(selected_seed - 1)

func select_right():
	select_seed(selected_seed + 1)

func pop_current_seed():
	if not get_child_count():
		return

	var seed_type = get_child(selected_seed).seed_type
	remove_seed(selected_seed)
	return seed_type
