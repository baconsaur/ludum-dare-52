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

var ability_data = {
	"default": {
		"seed": null,
		"type": "weapon",
		"name": "default",
		"icon": "res://scenes/ui/DefaultWeaponInfo.tscn",
		"object": "res://scenes/abilities/DefaultProjectile.tscn",
		"cooldown": 0.5,
	},
	"plasma": {
		"seed": plant_data["plasma"],
		"type": "weapon",
		"name": "plasma",
		"icon": "res://scenes/ui/PlasmaWeaponInfo.tscn",
		"object": "res://scenes/abilities/Plasma.tscn",
		"cooldown": 2,
	},
	"shield": {
		"seed": plant_data["shield"],
		"type": "ability",
		"name": "shield",
		"icon": "res://scenes/ui/ShieldAbilityInfo.tscn",
		"object": "res://scenes/abilities/Shield.tscn",
		"cooldown": 3,
	}
}

var enemy_data = {
	"plasma": {
		"touch_damage": 3,
		"ability": ability_data["plasma"],
		"max_hp": 1,
	},
	"shield": {
		"touch_damage": 3,
		"ability": ability_data["shield"],
		"max_hp": 1,
	}
}
