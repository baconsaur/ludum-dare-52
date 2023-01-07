extends Area2D

signal activated


func _on_Checkpoint_body_entered(body):
	if body.name == "Player":
		emit_signal("activated")
