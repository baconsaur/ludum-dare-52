extends Node2D

signal checkpoint_activated

onready var checkpoint = $Checkpoint
onready var spawn = $Spawn

func _ready():
	checkpoint.connect("activated", self, "activate_checkpoint")

func activate_checkpoint():
	emit_signal("checkpoint_activated")
