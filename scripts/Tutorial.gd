extends Control

export var keyboard_control = ""
export var gamepad_control = ""

func _ready():
	var label = get_node_or_null("Label")
	if label:
		if Input.get_connected_joypads():
			label.text = gamepad_control
		else:
			label.text = keyboard_control
	elif Input.get_connected_joypads():
		queue_free()

func enable():
	show()

func dismiss(_arg=null):
	fade()

func fade():
	while(modulate.a > 0):
		modulate.a -= 0.01
		yield(get_tree().create_timer(0.01), "timeout")
	queue_free()
