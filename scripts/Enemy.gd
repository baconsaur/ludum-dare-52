extends Area2D

export var enemy_type = "plasma"
export var stun_cooldown = 2
export var drop_range = 30
export var drop_offset_y = 12
export var drop_offset_x = 8
export var projectile_spawn = {
	1:	Vector2(0, 0),
	-1: Vector2(0, 0),
}

var max_hp
var current_hp
var touch_damage
var ability_type
var ability_cooldown
var seed_obj
var stunned = false
var stun_countdown = 0
var ability_countdown = 0
var dead = false
var dropped_seed = false
var player = null
var look_direction = -1
var spawn_cooldown = 0.5
var ready = false

var ability_obj

onready var sprite = $AnimatedSprite
onready var collider = $CollisionShape2D


func _ready():
	randomize()
	
	var enemy_data = get_node("/root/Globals").enemy_data[enemy_type].duplicate(true)
	
	seed_obj = load(enemy_data["ability"]["seed"]["object"])
	ability_obj = load(enemy_data["ability"]["object"])
	
	ability_type = enemy_data["ability"]["name"]
	ability_cooldown = enemy_data["ability"]["cooldown"]

	touch_damage = enemy_data["touch_damage"]
	max_hp = enemy_data["max_hp"]
	current_hp = max_hp
	
	sprite.play("idle")

func _process(delta):
	if dead:
		return

	if stunned:
		stun_countdown -= delta
		if stun_countdown <= 0:
			stunned = false
			if sprite.is_connected("animation_finished", self, "transition_animation"):
				sprite.disconnect("animation_finished", self, "transition_animation")
			sprite.play("recover")
			sprite.connect("animation_finished", self, "transition_animation", ["recover", "idle"], CONNECT_ONESHOT)
		return
	
	if not ready and spawn_cooldown >= 0:
		# Hacky bug fix I just don't have time to figure this one out
		spawn_cooldown -= delta
		return
	
	if not player:
		return
	
	if position.x - player.position.x < 0:
		look_direction = 1
	else:
		look_direction = -1
	
	ability_countdown -= delta
	if ability_countdown <= 0:
		sprite.play("action")
		if sprite.is_connected("animation_finished", self, "transition_animation"):
				sprite.disconnect("animation_finished", self, "transition_animation")
		sprite.connect("animation_finished", self, "transition_animation", ["action", "idle"], CONNECT_ONESHOT)
		var ability = ability_obj.instance()
		ability.setup_instance(self)
		ability_countdown = ability_cooldown

func stun():
	if dead or stunned:
		return

	sprite.play("stunned")
	call_deferred("drop_seeds")
	stunned = true
	stun_countdown = stun_cooldown

func hit(damage):
	if dead or damage <= 0:
		return

	current_hp -= damage
	if current_hp <= 0:
		die()
	else:
		sprite.play("hit")
		if sprite.is_connected("animation_finished", self, "transition_animation"):
				sprite.disconnect("animation_finished", self, "transition_animation")
		sprite.connect("animation_finished", self, "transition_animation", ["hit", "idle"], CONNECT_ONESHOT)
		call_deferred("drop_seeds")

func die():
	sprite.play("die")
	dead = true
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
	for _i in range(num_drops):
		# TODO nice drop animation
		var drop_x = randi() % drop_range - drop_range / 2
		drop_x += drop_offset_x if drop_x > 0 else -drop_offset_x
		var seed_instance = seed_obj.instance()
		seed_instance.position = Vector2(position.x + drop_x, position.y + drop_offset_y)
		get_parent().add_child(seed_instance)

func transition_animation(last, next):
	if sprite.animation != last:
		return
	sprite.play(next)

func _on_Enemy_body_entered(body):
	if dead:
		return

	if body.name != "Player":
		return
	if touch_damage and not stunned:
		body.hit(touch_damage)
		body.knockback(look_direction)


func _on_SightRange_body_entered(body):
	if body.name != "Player":
		return
	player = body


func _on_SightRange_body_exited(body):
	if body.name != "Player":
		return
	player = null
