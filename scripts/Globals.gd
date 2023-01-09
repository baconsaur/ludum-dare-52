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
	"bomb": {
		"growth_time": 1,
		"animation_frames": "res://sprites/plant_animations/bomb_seed.tres",
		"icon": "res://sprites/bomb_seed.png",
		"object": "res://scenes/seeds/BombSeed.tscn",
	},
}

var ability_data = {
	"default": {
		"seed": null,
		"type": "weapon",
		"name": "default",
		"icon": "res://scenes/ui/DefaultWeaponInfo.tscn",
		"object": "res://scenes/abilities/DefaultProjectile.tscn",
		"player_cooldown": 0.4,
	},
	"plasma": {
		"seed": plant_data["plasma"],
		"type": "weapon",
		"name": "plasma",
		"icon": "res://scenes/ui/PlasmaWeaponInfo.tscn",
		"object": "res://scenes/abilities/Plasma.tscn",
		"player_cooldown": 0.7,
		"enemy_cooldown": 2,
	},
	"shield": {
		"seed": plant_data["shield"],
		"type": "ability",
		"name": "shield",
		"icon": "res://scenes/ui/ShieldAbilityInfo.tscn",
		"object": "res://scenes/abilities/Shield.tscn",
		"player_cooldown": 2.75,
		"enemy_cooldown": 3.75,
	},
	"bomb": {
		"seed": plant_data["bomb"],
		"type": "ability",
		"name": "bomb",
		"icon": "res://scenes/ui/BombWeaponInfo.tscn",
		"object": "res://scenes/abilities/Bomb.tscn",
		"player_cooldown": 1.5,
		"enemy_cooldown": 3,
	}
}

var enemy_data = {
	"plasma": {
		"touch_damage": 3,
		"ability": ability_data["plasma"],
		"max_hp": 1,
		"max_drops": 4,
	},
	"shield": {
		"touch_damage": 3,
		"ability": ability_data["shield"],
		"max_hp": 1,
		"max_drops": 3,
	},
	"bomb": {
		"touch_damage": 2,
		"ability": ability_data["bomb"],
		"max_hp": 1,
		"max_drops": 2,
	}
}
