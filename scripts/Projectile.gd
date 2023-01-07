extends Area2D

export var damage = 1
export var stun = false
export var move_speed = 350
export var max_distance = 200

var distance_traveled = 0


func _process(delta):
	var frame_distance = delta * move_speed
	position.x += frame_distance
	
	distance_traveled += frame_distance
	if distance_traveled > max_distance:
		destroy()

func set_direction(direction):
	move_speed *= direction

func destroy():
	# TODO add a nice explosion?
	queue_free()


func _on_Projectile_body_entered(body):
	if body.name != "Player":
		destroy()


func _on_Projectile_area_entered(area):
	if area.is_in_group("enemies"):
		if stun:
			area.stun()
		elif damage:
			area.hit(damage)
		destroy()
