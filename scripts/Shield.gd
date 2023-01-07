extends Area2D

export var duration = 1

var time_left = duration

func _process(delta):
	time_left -= delta
	if time_left <= 0:
		queue_free()
