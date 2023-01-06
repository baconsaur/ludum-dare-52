extends Control

var pause_menu = preload("res://scenes/ui/PauseMenu.tscn")


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and not get_tree().paused:
		pause()


func pause():
	var pause_instance = pause_menu.instance()
	add_child(pause_instance)
	get_tree().paused = true
