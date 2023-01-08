extends KinematicBody2D

signal add_seed
signal plant_seed
signal hp_change
signal die
signal harvest_item
signal use_weapon
signal use_ability

export var max_hp = 10
export var move_speed = 100
export var jump_power = 400
export var fall_gravity_modifier = 2
export var knockback_distance = 30
export var projectile_spawn = {
	1:	Vector2(10, 3),
	-1: Vector2(-11, 3),
}

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
var look_direction = 1

onready var sprite = $Sprite

func _ready():
	ability_data = get_node("/root/Globals").ability_data.duplicate(true)
	sprite.connect("animation_finished", self, "on_animation_finished")

func _physics_process(delta):
	process_exploring_actions(delta)
	process_greenhouse_actions(delta)
	process_shared_actions(delta)

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
			look_direction = -1
		else:
			sprite.set_flip_h(false)
			look_direction = 1
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		falling = false

	if velocity.y > 0 and not is_on_floor():
		play_sprite_anim("fall")
		falling = true
	elif is_on_floor() and velocity.x != 0:
		play_sprite_anim("run")
	elif is_on_floor():
		play_sprite_anim("idle")

func play_sprite_anim(anim_name):
	# Prevents overriding compound action animations with their base action, ex. shoot_idle won't transition to idle
	if not anim_name in sprite.animation or not sprite.is_playing():
		sprite.play(anim_name)

func pickup(seed_name):
	emit_signal("add_seed", seed_name)

func spawn(pos, exploring):
	current_hp = max_hp
	emit_signal("hp_change", current_hp)
	position = pos
	attack_countdown = 0
	ability_countdown = 0
	is_exploring = exploring

func hit(damage):
	if damage <= 0:
		return

	current_hp -= damage
	emit_signal("hp_change", current_hp)
	if current_hp <= 0:
		emit_signal("die")

func knockback(direction):
	# TODO make this smoother
	position.x += knockback_distance * direction

func set_planter(planter):
	focused_planter = planter

func set_active_weapon(weapon_name):
	if weapon_name:
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
	attack_countdown = current_weapon["cooldown"]
	emit_signal("use_weapon", current_weapon["name"])

func use_ability():
	if not current_ability:
		return
	sprite.play("use_item_idle")
	var ability = current_ability["loaded_object"].instance()
	ability.setup_instance(self)
	ability_countdown = current_ability["cooldown"]
	emit_signal("use_ability", current_ability["name"])

func interact():
	if focused_planter:
		if focused_planter.has_plant():
			var item = focused_planter.harvest()
			if item:
				emit_signal("harvest_item", item)
				sprite.play("use_item_idle")
		else:
			emit_signal("plant_seed", focused_planter)

func plant_seed():
	sprite.play("use_item_idle")

func on_animation_finished():
	if "shoot" in sprite.animation:
		sprite.play(sprite.animation.replace("shoot_", ""))
	elif "use_item" in sprite.animation:
		sprite.play(sprite.animation.replace("use_item_", ""))
