extends Area2D

export var duration: float = 2.5

var time_left = duration
var is_friendly = false

func _process(delta):
	time_left -= delta
	if time_left <= 0:
		queue_free()

func setup_instance(owner):
	is_friendly = owner.name == "Player"
	owner.add_child(self)


func _on_Shield_body_entered(body):
	var parent = get_parent()
	if body.name == "Player" and body != parent:
		body.knockback(parent.look_direction)
