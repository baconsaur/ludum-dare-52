extends CPUParticles2D

export var area_damage = 3

onready var collider = $EffectArea

func _ready():
	if not emitting:
		emitting = true
		get_tree().create_timer(lifetime * (2 - explosiveness), false).connect("timeout", self, "queue_free")
	get_tree().create_timer(0.5, false).connect("timeout", collider, "queue_free")


func _on_EffectArea_area_entered(area):
	if area.is_in_group("enemies"):
		area.hit(area_damage)


func _on_EffectArea_body_entered(body):
	if body.name == "Player":
		body.hit(area_damage)
