extends Node2D

@onready var menuMusic: AudioStreamPlayer = $Menu/MenuMusic
@onready var titleDrop: AudioStreamPlayer = $Menu/TitleDrop
@onready var gameMusic: AudioStreamPlayer = $Autoplayed/MusicPlayer
@onready var gameAmbience: AudioStreamPlayer = $Autoplayed/AmbiencePlayer
@onready var transition: AudioStreamPlayer = $TransitionSound

var is_playing = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		menuMusic.play()
		titleDrop.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.inMenu == false and is_playing == false:
		switchSongs()

func switchSongs():
	menuMusic.stop()
	titleDrop.stop()
	print("GAME")
	transition.play()
	gameMusic.play()
	gameAmbience.play()
	is_playing = true
