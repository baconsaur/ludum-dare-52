extends Control

export var menu_scene = "res://scenes/ui/MainMenu.tscn"

var options_menu = preload("res://scenes/ui/OptionsMenu.tscn")
var focused = true


func _process(delta):
	if focused and Input.is_action_just_pressed("ui_cancel"):
		unpause()


func _on_OptionsButton_pressed():
	var options = options_menu.instance()
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


func refocus():
	focused = true
