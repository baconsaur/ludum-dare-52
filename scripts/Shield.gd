extends Area2D

export var duration = 1

var time_left = duration
var is_friendly = false

func _process(delta):
	time_left -= delta
	if time_left <= 0:
		queue_free()

func setup_instance(owner):
	is_friendly = owner.name == "Player"
	owner.add_child(self)
