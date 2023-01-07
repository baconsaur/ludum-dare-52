extends Node2D

export(Array, PackedScene) var levels = []
export var player_spawn = Vector2.ZERO

var current_level = 0
var loaded_level
var step_plant_growth = false

onready var ui = $CanvasLayer/UI
onready var seed_select = $CanvasLayer/UI/SeedSelect
onready var player = $Player
onready var greenhouse = $Greenhouse

func _ready():
	player.connect("add_seed", seed_select, "add_seed")
	player.connect("plant_seed", self, "plant_seed")

func _process(_delta):
	if Input.is_action_just_pressed("select_left"):
		seed_select.select_left()
	elif Input.is_action_just_pressed("select_right"):
		seed_select.select_right()

func enter_greenhouse():
	seed_select.reset()
	seed_select.show()
	call_deferred("add_child", greenhouse)
	player.spawn(player_spawn)

func complete_level():
	loaded_level.queue_free()
	current_level += 1
	step_plant_growth = true
	enter_greenhouse()

func enter_exploration():
	seed_select.hide()
	call_deferred("remove_child", greenhouse)
	loaded_level = levels[current_level].instance()
	call_deferred("add_child", loaded_level)
	loaded_level.connect("checkpoint_activated", self, "complete_level")
	player.spawn(loaded_level.spawn_position)

func plant_seed(planter):
	var current_seed = seed_select.pop_current_seed()
	if current_seed:
		planter.plant(current_seed)

func _on_Greenhouse_checkpoint_activated():
	enter_exploration()


func _on_Greenhouse_child_entered_tree(node):
	if node.is_in_group("planters") and step_plant_growth:
		node.step()
