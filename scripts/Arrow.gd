extends Area2D


func _on_Arrow_body_entered(body):
	if body.name == "Player":
		queue_free()
