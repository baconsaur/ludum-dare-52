extends Node2D

export(Array, PackedScene) var levels = []
export var player_spawn = Vector2.ZERO

var current_level = 0
var loaded_level
var step_plant_growth = false

onready var ui = $CanvasLayer/UI
onready var player = $Player
onready var greenhouse = $Greenhouse


func enter_greenhouse():
	call_deferred("add_child", greenhouse)
	player.position = player_spawn

func complete_level():
	loaded_level.queue_free()
	current_level += 1
	step_plant_growth = true
	enter_greenhouse()

func enter_exploration():
	call_deferred("remove_child", greenhouse)
	loaded_level = levels[current_level].instance()
	call_deferred("add_child", loaded_level)
	loaded_level.connect("checkpoint_activated", self, "complete_level")
	player.position = loaded_level.spawn_position


func _on_Greenhouse_checkpoint_activated():
	enter_exploration()


func _on_Greenhouse_child_entered_tree(node):
	if node.is_in_group("planters") and step_plant_growth:
		node.step()
