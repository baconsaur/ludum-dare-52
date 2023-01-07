extends Node

var plant_data = {
	"plasma": {
		"growth_time": 1,
		"animation_frames": "res://sprites/plant_animations/plasma_seed.tres",
		"icon": "res://sprites/plasma_seed.png",
		"object": "res://scenes/seeds/PlasmaSeed.tscn",
	},
	"shield": {
		"growth_time": 1,
		"animation_frames": "res://sprites/plant_animations/shield_seed.tres",
		"icon": "res://sprites/shield_seed.png",
		"object": "res://scenes/seeds/ShieldSeed.tscn",
	},
}

var enemy_data = {
	"plasma": {
		"touch_damage": 1,
		"seed_type": "plasma",
		"ability_type": "plasma",
		"ability_cooldown": 2,
		"max_hp": 1,
	},
	"shield": {
		"touch_damage": 1,
		"seed_type": "shield",
		"ability_type": "shield",
		"ability_cooldown": 2,
		"max_hp": 1,
	}
}
