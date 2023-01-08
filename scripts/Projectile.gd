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

func setup_instance(owner):
	var direction = -1 if owner.sprite.flip_h else 1
	move_speed *= direction
	position = Vector2(owner.position.x + (5 * direction), owner.position.y)
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
