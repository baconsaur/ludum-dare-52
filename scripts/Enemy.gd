extends Area2D

export var enemy_type = "plasma"
export var stun_cooldown = 2
export var drop_range = 30
export var drop_offset_y = 12
export var drop_offset_x = 8

var max_hp
var current_hp
var touch_damage
var seed_type
var action_type
var action_cooldown
var seed_obj
var stunned = false
var stun_countdown = 0
var action_countdown = 0
var dead = false

onready var sprite = $AnimatedSprite
onready var collider = $CollisionShape2D


func _ready():
	randomize()
	
	var globals = get_node("/root/Globals")
	var enemy_data = globals.enemy_data[enemy_type]
	touch_damage = enemy_data["touch_damage"]
	seed_type = enemy_data["seed_type"]
	action_type = enemy_data["action_type"]
	action_cooldown = enemy_data["action_cooldown"]
	max_hp = enemy_data["max_hp"]
	current_hp = max_hp
	
	var seed_data = globals.plant_data[seed_type]
	seed_obj = load(seed_data["object"])

func _process(delta):
	if dead:
		return

	if Input.is_action_just_pressed("debug"):
		hit(1)

	if stunned:
		stun_countdown -= delta
		if stun_countdown <= 0:
			stunned = false
			sprite.play("idle")
		else:
			return
	
	action_countdown -= delta
	if action_countdown <= 0:
		do_action()
		action_countdown = action_cooldown

func do_action():
	print(action_type)

func stun():
	sprite.play("stunned")
	call_deferred("drop_seeds")
	stunned = true
	stun_countdown = stun_cooldown

func hit(damage):
	if damage <= 0:
		return

	current_hp -= damage
	if current_hp <= 0:
		die()
	else:
		call_deferred("drop_seeds")

func die():
	call_deferred("drop_seeds")
	sprite.play("die")
	dead = true
	collider.disabled = true

func drop_seeds():
	# TODO add limit
	var drop_x = randi() % drop_range - drop_range / 2
	drop_x += drop_offset_x if drop_x > 0 else -drop_offset_x
	var seed_instance = seed_obj.instance()
	seed_instance.position = Vector2(position.x + drop_x, position.y + drop_offset_y)
	get_parent().add_child(seed_instance)

func _on_Enemy_body_entered(body):
	if body.name == "Player":
		if touch_damage and not stunned:
			body.hit(touch_damage)
			body.knockback()
