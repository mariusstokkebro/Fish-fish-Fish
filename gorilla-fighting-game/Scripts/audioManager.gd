extends Node2D

@onready var menuSound: AudioStreamPlayer = $MenuMusic
@onready var gameMusic: AudioStreamPlayer = $Autoplayed/MusicPlayer
@onready var gameAmbience: AudioStreamPlayer = $Autoplayed/AmbiencePlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if Global.inMenu == true:
		print("MENU")
		menuSound.play()
	else:
		print("GAME")
		gameMusic.play()
		gameAmbience.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
