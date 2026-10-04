extends Node2D

@onready var menuSound: AudioStreamPlayer = $MenuMusic
@onready var gameMusic: AudioStreamPlayer = $Autoplayed/MusicPlayer
@onready var gameAmbience: AudioStreamPlayer = $Autoplayed/AmbiencePlayer
@onready var transition: AudioStreamPlayer = $TransitionSound

var is_playing = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		menuSound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.inMenu == false and is_playing == false:
		switchSongs()

func switchSongs():
	menuSound.stop()
	print("GAME")
	transition.play()
	gameMusic.play()
	gameAmbience.play()
	is_playing = true
