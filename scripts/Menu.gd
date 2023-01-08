extends Control

export var game_scene = "res://scenes/Game.tscn"

var options_menu = preload("res://scenes/ui/OptionsMenu.tscn")

onready var start_button = $Menu/NinePatchRect/MarginContainer/ContentContainer/ButtonContainer/StartButton

func _ready():
	start_button.grab_focus()


func _on_StartButton_pressed():
	get_tree().change_scene(game_scene)


func _on_OptionsButton_pressed():
	var options = options_menu.instance()
	add_child(options)
	options.connect("tree_exited", start_button, "grab_focus")
