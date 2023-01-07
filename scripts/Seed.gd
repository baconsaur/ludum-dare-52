extends Area2D

export var seed_type = "seed"


func _on_Seed_body_entered(body):
	body.pickup(seed_type)
	queue_free()
