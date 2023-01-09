extends Area2D

export var tutorial_name = ""

func _on_TutorialTrigger_body_entered(body):
	if body.name == "Player":
		body.trigger_tutorial(tutorial_name)
		queue_free()
