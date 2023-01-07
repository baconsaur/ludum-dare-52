extends Area2D

var seed_type
var growth_stage = 0
var plant_data

onready var plant_sprite = $PlantSprite


func _ready():
	plant_data = get_node("/root/Globals").plant_data

func has_plant():
	if seed_type:
		return true

func reset():
	seed_type = null
	plant_sprite.set_sprite_frames(null)
	growth_stage = 0

func plant(seed_type_name):
	seed_type = seed_type_name
	plant_sprite.set_sprite_frames(load(plant_data[seed_type]["animation_frames"]))
	plant_sprite.play("stage0")

func step():
	if not seed_type:
		return
	if plant_data[seed_type]["growth_time"] > growth_stage:
		growth_stage += 1
		plant_sprite.play("stage" + str(growth_stage))

func harvest():
	if not seed_type:
		return
	var this_plant = plant_data[seed_type]
	if growth_stage < this_plant["growth_time"]:
		return
	var item = seed_type
	reset()
	return item

func _on_Planter_body_entered(body):
	if body.name == "Player":
		body.set_planter(self)


func _on_Planter_body_exited(body):
	if body.name == "Player":
		body.set_planter(null)
