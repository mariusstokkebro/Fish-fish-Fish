extends Node2D
var player1_score: int = 0
var player2_score: int = 0
@export var player1: CharacterBody2D
@export var player2: CharacterBody2D 
var reset = false
var timer = 0.0
@export var gameTime:float = 300

func _process(delta: float) -> void:
	if reset == true:
		await get_tree().create_timer(2).timeout
		reset = false
	timer += delta
	
	if timer > gameTime:
		print_debug("Game is over")
	
	if player1_score > 9:
		print_debug("player one wins")
		
	if player2_score > 9: 
		print_debug("player two wins")
