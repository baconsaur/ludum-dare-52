extends KinematicBody2D

signal add_seed
signal plant_seed
signal hp_change
signal die

export var max_hp = 10
export var move_speed = 100
export var jump_power = 400
export var fall_gravity_modifier = 2

var gravity = 981
var falling = false
var velocity = Vector2.ZERO
var equipment = []
var focused_planter
var current_hp = max_hp

onready var sprite = $Sprite


func _physics_process(delta):
	if Input.is_action_just_pressed("debug"):
		hit(1)
		
	if Input.is_action_just_pressed("interact"):
		interact()

	if Input.is_action_just_pressed("up") and is_on_floor():
		sprite.play("jump")
		velocity.y = -jump_power
	
	var effective_gravity = gravity if not falling else gravity * fall_gravity_modifier
	if velocity.y > 0:
		effective_gravity += gravity * fall_gravity_modifier
	elif velocity.y < 0 and falling:
		effective_gravity += gravity
		
	velocity.y += effective_gravity * delta

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * move_speed
		if direction < 0:
			sprite.set_flip_h(true)
		else:
			sprite.set_flip_h(false)
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		falling = false

	if velocity.y > 0 and not is_on_floor():
		sprite.play("fall")
		falling = true
	elif is_on_floor() and velocity.x != 0:
		sprite.play("run")
	elif is_on_floor():
		sprite.play("idle")

func pickup(seed_name):
	emit_signal("add_seed", seed_name)

func spawn(pos):
	current_hp = max_hp
	emit_signal("hp_change", current_hp)
	position = pos

func hit(damage):
	if damage <= 0:
		return

	current_hp -= damage
	emit_signal("hp_change", current_hp)
	if current_hp <= 0:
		emit_signal("die")

func set_planter(planter):
	focused_planter = planter

func interact():
	if focused_planter:
		if focused_planter.has_plant():
			var item = focused_planter.harvest()
			if item:
				equipment.append(item)
		else:
			emit_signal("plant_seed", focused_planter)
