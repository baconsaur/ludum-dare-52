extends Node2D

export(Array, PackedScene) var levels = []
export var player_spawn = Vector2.ZERO

var current_level = 0
var loaded_level
var step_plant_growth = false
var new_seeds = []
var ability_data
var weapon_inventory = []
var ability_inventory = []
var active_tutorials = []
var seen_ability_tutorial = false
var seen_items = []

onready var ui = $CanvasLayer/UI
onready var hud = $CanvasLayer/UI/HUD
onready var player_hp = $CanvasLayer/UI/HUD/HP
onready var seed_select = $CanvasLayer/UI/HUD/SeedSelect
onready var ability_select = $CanvasLayer/UI/HUD/AbilitySelect
onready var weapon_select = $CanvasLayer/UI/HUD/WeaponSelect
onready var player = $Player
onready var greenhouse = $Greenhouse
onready var change_item_sound = $ChangeItem
onready var info_modal_obj = preload("res://scenes/ui/InfoModal.tscn")

func _ready():
	player.connect("add_seed", self, "add_seed")
	player.connect("plant_seed", self, "plant_seed")
	player.connect("die", self, "handle_death")
	player.connect("hp_change", self, "handle_hp_change")
	player.connect("harvest_item", self, "handle_harvest_item")
	player.connect("use_weapon", weapon_select, "remove")
	player.connect("use_ability", ability_select, "remove")
#	player.connect("movement", self, "handle_player_first_move", [], CONNECT_ONESHOT)
	player.connect("trigger_tutorial", self, "show_tutorial")
	
	seed_select.connect("change_selection", change_item_sound, "play")
	
	ability_data = get_node("/root/Globals").ability_data.duplicate(true)
	weapon_select.add(ability_data["default"], -1)
	
	weapon_select.connect("select_item", player, "set_active_weapon")
	ability_select.connect("select_item", player, "set_active_ability")

func _process(_delta):
	if Input.is_action_just_pressed("select_left"):
		if loaded_level:
			ability_select.select_next()
		else:
			seed_select.select_left()
	elif Input.is_action_just_pressed("select_right"):
		if loaded_level:
			weapon_select.select_next()
		else:
			seed_select.select_right()

func enter_greenhouse():
	for seed_type in new_seeds:
		seed_select.add_seed(seed_type)
	new_seeds = []
	seed_select.reset()
	player_hp.hide()
	seed_select.show()
	call_deferred("add_child", greenhouse)
	call_deferred("spawn_player", greenhouse, false)
	weapon_select.disable_select()
	ability_select.disable_select()
	if not greenhouse.plant_tutorial_activated and seed_select.seed_container.get_child_count():
		greenhouse.enable_plant_tutorial()

func complete_level():
	loaded_level.queue_free()
	loaded_level = null
	current_level += 1
	step_plant_growth = true
	clear_tutorials()
	enter_greenhouse()
	if current_level == levels.size():
		greenhouse.checkpoint.queue_free()
		var modal = info_modal_obj.instance()
		ui.add_child(modal)
		modal.set_up("You Win!", "You finished all the levels I had time for. Congrats, and thanks for playing!")

func enter_exploration():
	player_hp.show()
	seed_select.hide()
	call_deferred("remove_child", greenhouse)
	loaded_level = levels[current_level].instance()
	call_deferred("add_child", loaded_level)
	call_deferred("spawn_player", loaded_level, true)
	loaded_level.connect("checkpoint_activated", self, "complete_level")
	
	if not seen_ability_tutorial and ability_select.item_container.get_child_count():
		show_tutorial("AbilityTutorial")
		seen_ability_tutorial = true
	
	for inst in [weapon_select, ability_select]:
		inst.enable_select()
		inst.save_state()

func spawn_player(level, exploring):
	player.spawn(level.spawn.position, exploring)
	if current_level == 0:
		see_item("default")

func add_seed(seed_type):
	new_seeds.append(seed_type)

func plant_seed(planter):
	var current_seed = seed_select.pop_current_seed()
	if current_seed:
		planter.plant(current_seed)
		player.plant_seed()

func handle_hp_change(value):
	player_hp.update_value(value)

func handle_death():
	clear_tutorials()
	# TODO fade to black or something
	if loaded_level:
		loaded_level.queue_free()
	new_seeds = []
	step_plant_growth = false
	for inst in [weapon_select, ability_select]:
		inst.restore_state()
	enter_greenhouse()

func handle_harvest_item(item_name):
	see_item(item_name)
	
	var item = ability_data[item_name]
	if item["type"] == "weapon":
		weapon_select.add(item)
	elif item["type"] == "ability":
		ability_select.add(item)
		ability_select.add(item)

#func handle_player_first_move():
#	var move_tutorial = player.tutorials.get_node_or_null("MovementTutorial")
#	if move_tutorial and is_instance_valid(move_tutorial):
#		move_tutorial.dismiss()

func show_tutorial(tutorial_name):
	var tutorial = player.tutorials.get_node_or_null(tutorial_name)
	if not tutorial:
		return
	tutorial.show()
	active_tutorials.append(tutorial)
	
	if tutorial_name == "ShootTutorial":
		player.connect("use_weapon", tutorial, "dismiss", [], CONNECT_ONESHOT)
	elif tutorial_name == "PlantTutorial":
		player.connect("plant_seed", tutorial, "dismiss", [], CONNECT_ONESHOT)
	elif tutorial_name == "AbilityTutorial":
		player.connect("use_ability", tutorial, "dismiss", [], CONNECT_ONESHOT)
	elif tutorial_name == "HarvestTutorial":
		player.connect("harvest_item", tutorial, "dismiss", [], CONNECT_ONESHOT)

func clear_tutorials():
	for tutorial in active_tutorials:
		if is_instance_valid(tutorial):
			tutorial.queue_free()
	active_tutorials.clear()

func see_item(item_name):
	if item_name in seen_items:
		return
	seen_items.append(item_name)
	var modal = info_modal_obj.instance()
	ui.add_child(modal)
	var pretty_name = item_name.capitalize()
	if item_name == "default":
		pretty_name = "Energy Ball"
	elif item_name == "plasma":
		pretty_name = "Plasma Burst"
	modal.set_up(pretty_name, ability_data[item_name]["hint"])

func _on_Greenhouse_checkpoint_activated():
	clear_tutorials()
	enter_exploration()


func _on_Greenhouse_child_entered_tree(node):
	if node.is_in_group("planters"):
		if step_plant_growth:
			node.step()
			if not greenhouse.harvest_tutorial_activated and node.grown:
				greenhouse.enable_harvest_tutorial()
