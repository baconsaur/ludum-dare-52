extends "res://scripts/Projectile.gd"

export var fall_speed = 100
export var bomb_offset = Vector2(0, -2)
export var fall_acceleration = 1.5
export var terminal_speed = 170

var bomb_sprite
var is_ready = false

onready var shoot_sound = $Shoot
onready var explosion_obj = preload("res://scenes/abilities/Explosion.tscn")


func real_process(delta):
	if not is_ready:
		if bomb_sprite:
			if bomb_sprite.animation == "action" and bomb_sprite.frame < 4:
				return
			actual_setup()
	.real_process(delta)
	position.y += delta * fall_speed
	if fall_speed < terminal_speed:
		fall_speed *= fall_acceleration

func setup_instance(owner):
	is_friendly = owner.name == "Player"
	owner.get_parent().add_child(self)
	
	if not is_friendly:
		# Fall straight down
		move_speed = 0
		bomb_sprite = owner.sprite
		position = owner.position - bomb_offset
	else:
		actual_setup()
		move_speed *= owner.look_direction
		fall_speed = 1
		position = Vector2(owner.position + owner.projectile_spawn[owner.look_direction])

func actual_setup():
	show()
	is_ready = true
	shoot_sound.play()

func destroy():
	var explosion = explosion_obj.instance()
	explosion.position = position
	get_parent().call_deferred("add_child", explosion)
	.destroy()
