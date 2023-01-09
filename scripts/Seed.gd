extends Area2D

export var seed_type = "seed"
export var fall_speed = 100
export var fall_acceleration = 1.3
export var terminal_speed = 150

var falling = true

func _process(delta):
	if not falling:
		return
	position.y += delta * fall_speed
	if fall_speed < terminal_speed:
		fall_speed *= fall_acceleration


func _on_Seed_body_entered(body):
	if body.name == "Player":
		body.pickup(seed_type)
		queue_free()
	falling = false
