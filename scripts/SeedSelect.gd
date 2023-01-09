extends Control

signal change_selection

var plant_data
var selected_seed = 0

onready var seed_button_obj = preload("res://scenes/ui/SeedButton.tscn")
onready var seed_container = $SeedContainer
onready var left = $LeftIndicator
onready var left_label = $LeftIndicator/Label
onready var right = $RightIndicator
onready var right_label = $RightIndicator/Label


func _ready():
	plant_data = get_node("/root/Globals").plant_data.duplicate(true)
	if not Input.get_connected_joypads():
		left_label.text = ""
		right_label.text = ""

func reset():
	select_seed(0)

func remove_seed(index):
	var to_remove = seed_container.get_child(index)
	to_remove.connect("tree_exited", self, "select_seed", [index])
	to_remove.queue_free()
	if seed_container.get_child_count() <= 1:
		left.hide()
		right.hide()

func add_seed(item):
	var button = seed_button_obj.instance()
	button.setup(item, plant_data[item].icon)
	button.connect("pressed", self, "select_seed", [seed_container.get_child_count()])
	seed_container.add_child(button)
	if not left.visible:
		left.show()
		right.show()

func select_seed(index):
	var children = seed_container.get_children()
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
	if not seed_container.get_child_count():
		return

	var seed_type = seed_container.get_child(selected_seed).seed_type
	remove_seed(selected_seed)
	return seed_type
