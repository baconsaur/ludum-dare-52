extends MarginContainer


onready var back_button = $NinePatchRect/MarginContainer/ContentContainer/ButtonContainer/BackButton
onready var title = $NinePatchRect/MarginContainer/ContentContainer/Title
onready var hint = $NinePatchRect/MarginContainer/ContentContainer/Hint

func _ready():
	back_button.grab_focus()

func set_up(title_text, hint_text):
	title.text = title_text
	hint.text = hint_text
	get_tree().paused = true

func _on_Button_pressed():
	queue_free()


func _on_InfoModal_tree_exiting():
	get_tree().paused = false
