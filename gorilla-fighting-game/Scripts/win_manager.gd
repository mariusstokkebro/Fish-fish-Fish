extends Node2D
var player1_score: int = 0
var player2_score: int = 0

var timer = 0.0
@export var gameTime:float = 240

func _process(delta: float) -> void:
	timer += delta
	
	if timer > gameTime:
		print_debug("Game is over")
