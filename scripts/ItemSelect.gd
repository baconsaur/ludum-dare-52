extends Control

signal select_item


var items = {}
var selected_item = null
var select_enabled = false

func disable_select():
	select_item(null)
	select_enabled = false

func enable_select():
	select_enabled = true
	select_first_child()

func select_next():
	if not select_enabled:
		return
	var child_count = get_child_count()
	if not child_count:
		return

	var next_index = 0
	if selected_item:
		for i in range(child_count):
			if get_child(i) == selected_item and i + 1 < child_count:
				next_index = i + 1
				break
	select_item(get_child(next_index))

func add(item_data, count=1):
	var item_name = item_data["name"]
	if item_data["name"] in items:
		items[item_name]["count"] += count
		update_item(items[item_name])
	else:
		items[item_name] = item_data
		items[item_name]["count"] = count
		add_new(items[item_name])

func add_new(item_data):
	var icon = load(item_data["icon"]).instance()
	add_child(icon)
	icon.setup(item_data["name"], item_data["count"] if item_data["count"] > 0 else "")
	item_data["instance"] = icon
	if not selected_item:
		select_item(icon)

func remove(item_name):
	if item_name in items:
		if items[item_name]["count"] > 0:
			items[item_name]["count"] -= 1
			update_item(items[item_name])

func update_item(item):
	if item["count"] > 0:
		item["instance"].update_count(item["count"])
	elif item["count"] < 0:
		item["instance"].update_count("")
	else:
		item["instance"].queue_free()
		items.erase(item["name"])
		call_deferred("select_first_child")

func select_first_child():
	if get_child_count():
		select_item(get_child(0))
	else:
		select_item(null)

func select_item(instance):
	if not select_enabled:
		return

	if selected_item == instance:
		return
	if is_instance_valid(selected_item):
		selected_item.deselect()

	selected_item = instance
	if instance:
		instance.select()
		emit_signal("select_item", instance.item_name)
	else:
		emit_signal("select_item", null)
