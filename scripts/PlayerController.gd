extends KinematicBody2D


export var move_speed = 100
export var jump_power = 400
export var fall_gravity_modifier = 2
var gravity = 981
var falling = false
var velocity = Vector2.ZERO

onready var sprite = $Sprite


func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
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
