extends Area2D

export var damage = 1
export var stun = false
export var move_speed = 350
export var max_distance = 200
export var piercing = false

var distance_traveled = 0
var is_friendly = false


func _process(delta):
	var frame_distance = delta * move_speed
	position.x += frame_distance
	
	distance_traveled += frame_distance
	if distance_traveled > max_distance:
		destroy()

func set_start(start_pos, direction, friendly=false):
	move_speed *= direction
	position = Vector2(start_pos.x + (5 * direction), start_pos.y)
	is_friendly = friendly

func destroy():
	# TODO add a nice explosion?
	queue_free()


func _on_Projectile_body_entered(body):
	if body.name != "Player":
		destroy()
	elif not is_friendly:
		body.hit(damage)
		destroy()


func _on_Projectile_area_entered(area):
	if is_friendly and area.is_in_group("enemies"):
		if stun:
			area.stun()
		elif damage:
			area.hit(damage)
		destroy()
	if area.is_in_group("shields") and not piercing:
		destroy()
