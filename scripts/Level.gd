extends Node2D

signal checkpoint_activated

export var spawn_position = Vector2.ZERO

onready var checkpoint = $Checkpoint

func _ready():
	checkpoint.connect("activated", self, "activate_checkpoint")

func activate_checkpoint():
	emit_signal("checkpoint_activated")
