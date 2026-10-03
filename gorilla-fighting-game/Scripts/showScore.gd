extends Node2D
@export var ScoreSprite: Sprite2D
@export var player: int = 1
var numbers = [
	load("res://Sprites/numbers/0.png"),
	load("res://Sprites/numbers/1.png"),
	load("res://Sprites/numbers/2.png"),
	load("res://Sprites/numbers/3.png"),
	load("res://Sprites/numbers/4.png"),
	load("res://Sprites/numbers/5.png"),
	load("res://Sprites/numbers/6.png"),
	load("res://Sprites/numbers/7.png"),
	load("res://Sprites/numbers/8.png"),
	load("res://Sprites/numbers/9.png"),
]

func _process(delta: float) -> void:
	if player == 1:
		ScoreSprite.texture = numbers[WinManager.player1_score]
	if player == 2:
		ScoreSprite.texture = numbers[WinManager.player2_score]

	
