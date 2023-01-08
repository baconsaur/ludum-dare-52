extends Control

export var menu_scene = "res://scenes/ui/MainMenu.tscn"

var options_menu = preload("res://scenes/ui/OptionsMenu.tscn")
var focused = true
var options

onready var resume_button = $NinePatchRect/MarginContainer/ContentContainer/ButtonContainer/ResumeButton

func _ready():
	resume_button.grab_focus()


func _process(delta):
	if Input.is_action_just_pressed("pause"):
		unpause()
		
	if focused and Input.is_action_just_pressed("ui_cancel"):
		unpause()


func _on_OptionsButton_pressed():
	options = options_menu.instance()
	options.connect("tree_exited", self, "refocus")
	get_parent().add_child(options)
	focused = false


func _on_ResumeButton_pressed():
	unpause()


func _on_MainMenuButton_pressed():
	unpause()
	get_tree().change_scene(menu_scene)


func unpause():
	get_tree().paused = false
	queue_free()
	
	if is_instance_valid(options):
		options.queue_free()

func refocus():
	focused = true
	resume_button.grab_focus()
