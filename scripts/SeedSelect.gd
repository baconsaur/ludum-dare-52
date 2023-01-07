extends Control

var plant_data
var selected_seed = 0

onready var SeedButton = load("res://scripts/SeedButton.gd")


func _ready():
	plant_data = get_node("/root/Globals").plant_data

func reset():
	select_seed(0)

func remove_seed(index):
	var to_remove = get_child(index)
	to_remove.connect("tree_exited", self, "select_seed", [index])
	to_remove.queue_free()

func add_seed(item):
	var button = SeedButton.new()
	button.setup(item, plant_data[item].icon)
	button.connect("pressed", self, "select_seed", [button])
	add_child(button)

func select_seed(index):
	var children = get_children()
	if not children:
		selected_seed = 0
		return
	selected_seed = clamp(index, 0, children.size() - 1)

	for i in range(children.size()):
		if i == selected_seed:
			show_selection(children[i])
		else:
			show_deselection(children[i])

func show_selection(button):
	button.modulate = Color.black

func show_deselection(button):
	button.modulate = Color.white

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
