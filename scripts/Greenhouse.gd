extends Node2D

signal checkpoint_activated

var plant_tutorial_activated = false
var harvest_tutorial_activated = false

onready var checkpoint = $Checkpoint
onready var spawn = $Spawn

func _ready():
	checkpoint.connect("activated", self, "activate_checkpoint")

func activate_checkpoint():
	emit_signal("checkpoint_activated")

func enable_plant_tutorial():
	get_node_or_null("TutorialTrigger").monitoring = true
	plant_tutorial_activated = true

func enable_harvest_tutorial():
	get_node_or_null("TutorialTrigger2").monitoring = true
	harvest_tutorial_activated = true
