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
var ability_type
var ability_cooldown
var seed_obj
var stunned = false
var stun_countdown = 0
var ability_countdown = 0
var dead = false
var dropped_seed = false
var player

# Abilities
var plasma_obj = preload("res://scenes/abilities/Plasma.tscn")
var shield_obj = preload("res://scenes/abilities/Shield.tscn")

onready var sprite = $AnimatedSprite
onready var collider = $CollisionShape2D


func _ready():
	randomize()
	
	var globals = get_node("/root/Globals")
	var enemy_data = globals.enemy_data[enemy_type]
	touch_damage = enemy_data["touch_damage"]
	seed_type = enemy_data["seed_type"]
	ability_type = enemy_data["ability_type"]
	ability_cooldown = enemy_data["ability_cooldown"]
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
	
	if not player:
		return
	
	if position.x - player.position.x < 0:
		sprite.set_flip_h(true)
	else:
		sprite.set_flip_h(false)
	
	ability_countdown -= delta
	if ability_countdown <= 0:
		call_deferred(ability_type)
		ability_countdown = ability_cooldown

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
	sprite.play("die")
	dead = true
	collider.disabled = true
	call_deferred("drop_seeds")

func drop_seeds():
	# Drop a max of one seed before death
	var num_drops = 0
	if dead:
		# Drop 1-2 on death
		num_drops = randi() % 2 + 1
	elif not dropped_seed:
		num_drops = 1
		dropped_seed = true
	for i in range(num_drops):
		# TODO nice drop animation
		var drop_x = randi() % drop_range - drop_range / 2
		drop_x += drop_offset_x if drop_x > 0 else -drop_offset_x
		var seed_instance = seed_obj.instance()
		seed_instance.position = Vector2(position.x + drop_x, position.y + drop_offset_y)
		get_parent().add_child(seed_instance)

func _on_Enemy_body_entered(body):
	if body.name != "Player":
		return
	if touch_damage and not stunned:
		body.hit(touch_damage)
		body.knockback()


func _on_SightRange_body_entered(body):
	if body.name != "Player":
		return
	player = body


func _on_SightRange_body_exited(body):
	if body.name != "Player":
		return
	player = null


### ABILITY FUNCTIONS (TODO: refactor this nightmare) ###

func plasma():
	var plasma = plasma_obj.instance()
	get_parent().add_child(plasma)
	var direction = 1 if sprite.flip_h else -1
	plasma.set_start(position, direction)

func shield():
	pass
