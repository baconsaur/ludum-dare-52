extends KinematicBody2D

signal add_seed
signal plant_seed
signal hp_change
signal die
signal harvest_item
signal use_weapon
signal use_ability
#signal movement
signal trigger_tutorial

export var max_hp = 10
export var move_speed = 300
export var jump_power = 375
export var fall_gravity_modifier = 2
export var knockback_velocity = 250
export var projectile_spawn = {
	1:	Vector2(10, 3),
	-1: Vector2(-11, 3),
}
export var spawn_cooldown = 0.15
export var move_threshold = 17
export var max_velocity = 210
export var invulnerable_cooldown = 0.25

var gravity = 981
var falling = false
var velocity = Vector2.ZERO
var focused_planter
var current_hp = max_hp
var is_exploring = false
var ability_data
var current_ability
var current_weapon
var attack_countdown = 0
var ability_countdown = 0
var last_animation = "idle"
var dead = false
var stunned = false
var spawn_countdown = spawn_cooldown
var is_grounded = true
var is_invulnerable = false
var invulnerable_countdown = 0

onready var sprite = $Sprite
onready var jump_sound = $Jump
onready var hit_sound = $Hit
onready var die_sound = $Die
onready var spawn_sound = $Spawn
onready var change_item_sound = $ChangeItem
onready var pickup_sound = $Pickup
onready var plant_sound = $Plant
onready var camera = $Camera
onready var tutorials = $Tutorial
onready var coyote_collider = $CoyoteCollider
onready var floor_collider = $FloorCollider

func _ready():
	ability_data = get_node("/root/Globals").ability_data.duplicate(true)
	sprite.connect("animation_finished", self, "on_animation_finished")

func _physics_process(delta):
	process_shared_actions(delta)

	if dead or stunned:
		return

	if is_invulnerable and invulnerable_countdown > 0:
		invulnerable_countdown -= delta
	else:
		is_invulnerable = false
		
	process_exploring_actions(delta)
	process_greenhouse_actions(delta)

func process_greenhouse_actions(delta):
	if is_exploring:
		return
	if Input.is_action_just_pressed("fire"):
		interact()

func process_exploring_actions(delta):
	if not is_exploring:
		return

	if attack_countdown >= 0:
		attack_countdown -= delta
	elif Input.is_action_just_pressed("fire"):
		fire()
	
	if ability_countdown >= 0:
		ability_countdown -= delta
	elif Input.is_action_just_pressed("use_ability"):
		use_ability()

func process_shared_actions(delta):
	var effective_gravity = gravity if not falling else gravity * fall_gravity_modifier
	if velocity.y > 0:
		effective_gravity += gravity * fall_gravity_modifier
	elif velocity.y < 0 and falling:
		effective_gravity += gravity

	velocity.y += effective_gravity * delta
	
	if not dead and not stunned and spawn_countdown <= 0:
		if Input.is_action_just_pressed("up") and (is_on_floor() or is_grounded):
			sprite.play("jump")
			jump_sound.play()
			velocity.y = -jump_power
#			emit_signal("movement")
			falling = false
			if is_a_parent_of(coyote_collider):
				remove_child(coyote_collider)
		var direction = Input.get_axis("left", "right")
		if direction:
			var effective_move_speed = move_speed if is_on_floor() else move_speed * 0.7
			velocity.x = clamp(velocity.x + direction * effective_move_speed, -max_velocity, max_velocity)
			flip_direction(direction)
#			emit_signal("movement")
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
	elif spawn_countdown > 0:
		spawn_countdown -= delta

	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		falling = false
		if not is_a_parent_of(coyote_collider):
			add_child(coyote_collider)

	if velocity.y > 0 and not is_on_floor():
		play_sprite_anim("fall")
		falling = true
	elif is_on_floor() and (velocity.x > move_threshold or velocity.x < -move_threshold):
		play_sprite_anim("run")
	elif is_on_floor():
		play_sprite_anim("idle")

func get_look_direction():
	if sprite.flip_h:
		return -1
	return 1

func play_sprite_anim(anim_name):
	if sprite.animation in ["die", "hit"]:
		return
	# Prevents overriding compound action animations with their base action, ex. shoot_idle won't transition to idle
	if not anim_name in sprite.animation or not sprite.is_playing():
		sprite.play(anim_name)

func pickup(seed_name):
	pickup_sound.play()
	emit_signal("add_seed", seed_name)

func spawn(pos, exploring):
	spawn_countdown = spawn_cooldown
	velocity = Vector2.ZERO
	dead = false
	stunned = false
	sprite.play("idle")
	spawn_sound.play()
	current_hp = max_hp
	emit_signal("hp_change", current_hp)
	position = pos
	attack_countdown = 0
	ability_countdown = 0
	is_exploring = exploring
	is_invulnerable = false

func hit(damage):
	if stunned or is_invulnerable or damage <= 0:
		return

	current_hp -= damage
	emit_signal("hp_change", current_hp)
	camera.shake()
	if current_hp <= 0:
		dead = true
		sprite.play("die")
		die_sound.play()
		velocity.x = 0
	else:
		stunned = true
		is_invulnerable = true
		invulnerable_countdown = invulnerable_cooldown
		flash()
		sprite.play("hit")
		hit_sound.play()

func knockback(direction):
	if dead:
		return
	if not stunned:
		stunned = true
		sprite.play("hit")
	velocity.x = knockback_velocity * direction
	velocity = move_and_slide(velocity, Vector2.UP)

func set_planter(planter):
	focused_planter = planter

func set_active_weapon(weapon_name):
	if weapon_name:
		if current_weapon and weapon_name != current_weapon["name"]:
			change_item_sound.play()
		current_weapon = ability_data[weapon_name]
	else:
		current_weapon = ability_data["default"]
	if not "loaded_object" in current_weapon:
		current_weapon["loaded_object"] = load(current_weapon["object"])

func set_active_ability(ability_name):
	if ability_name:
		current_ability = ability_data[ability_name]
		if not "loaded_object" in current_ability:
			current_ability["loaded_object"] = load(current_ability["object"])
	else:
		current_ability = null

func fire():
	var current_animation = sprite.animation
	if not current_animation in ["idle", "run", "jump", "fall"]:
		current_animation = "idle"
	sprite.play("shoot_" + current_animation)
	
	var projectile = current_weapon["loaded_object"].instance()
	projectile.setup_instance(self)
	attack_countdown = current_weapon["player_cooldown"]
	emit_signal("use_weapon", current_weapon["name"])

func use_ability():
	if not current_ability:
		return
	sprite.play("use_item_idle")
	var ability = current_ability["loaded_object"].instance()
	ability.setup_instance(self)
	ability_countdown = current_ability["player_cooldown"]
	emit_signal("use_ability", current_ability["name"])

func interact():
	if focused_planter:
		if focused_planter.has_plant():
			var item = focused_planter.harvest()
			if item:
				emit_signal("harvest_item", item)
				sprite.play("use_item_idle")
				pickup_sound.play()
		else:
			emit_signal("plant_seed", focused_planter)

func plant_seed():
	plant_sound.play()
	sprite.play("use_item_idle")

func on_animation_finished():
	if sprite.animation == "die":
		emit_signal("die")
	elif sprite.animation == "hit":
		stunned = false
		sprite.play("idle")
	elif "shoot" in sprite.animation:
		sprite.play(sprite.animation.replace("shoot_", ""))
	elif "use_item" in sprite.animation:
		sprite.play(sprite.animation.replace("use_item_", ""))
	else:
		sprite.play("idle")

func trigger_tutorial(tutorial_name):
	emit_signal("trigger_tutorial", tutorial_name)

func flip_direction(direction):
	if direction < 0 and not sprite.flip_h:
		velocity.x = 0
		sprite.set_flip_h(true)
		coyote_collider.position.x = 8
	elif direction > 0 and sprite.flip_h:
		velocity.x = 0
		sprite.set_flip_h(false)
		coyote_collider.position.x = -8

func flash():
	while(not dead and invulnerable_countdown > 0):
		sprite.modulate.a = 0
		yield(get_tree().create_timer(0.05), "timeout")
		sprite.modulate.a = 1
		yield(get_tree().create_timer(0.05), "timeout")
	sprite.modulate.a = 1

func _on_CoyoteCollider_body_entered(body):
	if body is TileMap:
		check_collider(coyote_collider)

func _on_CoyoteCollider_body_exited(body):
	if body is TileMap:
		check_collider(coyote_collider)

func _on_FloorCollider_body_entered(body):
	if body is TileMap:
		check_collider(floor_collider)

func _on_FloorCollider_body_exited(body):
	if body is TileMap:
		check_collider(floor_collider)

func check_collider(collider):
	is_grounded = not collider.get_overlapping_bodies().empty()
