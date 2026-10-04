extends Node2D

@onready var green: CPUParticles2D = $green
@onready var pink: CPUParticles2D = $pink
@onready var blue: CPUParticles2D = $blue
@onready var yellow: CPUParticles2D = $yellow

# Called when the node enters the scene tree for the first time.
func throw_confetti() -> void:
	green.emitting = true
	pink.emitting = true
	blue.emitting = true
	yellow.emitting = true
