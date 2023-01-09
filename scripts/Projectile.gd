extends Area2D

export var damage = 1
export var stun = false
export var move_speed = 350
export var max_distance = 200
export var piercing = false

var distance_traveled = 0
var is_friendly = false


func _process(delta):
	# Hand off processing to a function I can override 
	real_process(delta)

func real_process(delta):
	var frame_distance = delta * move_speed
	position.x += frame_distance
	
	distance_traveled += frame_distance
	if distance_traveled > max_distance:
		destroy()

func setup_instance(owner):
	move_speed *= owner.look_direction
	position = Vector2(owner.position + owner.projectile_spawn[owner.look_direction])
	is_friendly = owner.name == "Player"
	owner.get_parent().add_child(self)

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
		if area.dead:
			return
		if stun:
			area.stun()
		elif damage:
			area.hit(damage)
		destroy()
	if area.is_in_group("shields") and not piercing:
		if is_friendly != area.is_friendly:
			destroy()
