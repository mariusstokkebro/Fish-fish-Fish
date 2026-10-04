extends Node2D
var player1_score: int = 0
var player2_score: int = 0
@export var player1: CharacterBody2D
@export var player2: CharacterBody2D 
var reset = false
var timer = 0.0

@export var gameTime:float = 300
@export var penguin1_sprite: Sprite2D
@export var penguin2_sprite: Sprite2D

@onready var winner_sprite: Sprite2D = $WinnerSprite2D
@onready var tie_sprite: Sprite2D = $TieSprite2D
@onready var win_penguin_sprite: Sprite2D = $PenguinSprite2D
@onready var player_1_sprite: Sprite2D = $Player1Sprite2D
@onready var player_2_sprite: Sprite2D = $Player2Sprite2D
@onready var confetti_left: Node2D = $ConfettiLeft
@onready var confetti_right: Node2D = $ConfettiRight
@onready var win_sound: AudioStreamPlayer2D = $WinSound

var is_game_stop = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	is_game_stop = false


func _process(delta: float) -> void:
	if reset == true:
		await get_tree().create_timer(2).timeout
		reset = false
	timer += delta
	
	if is_game_stop == false:
		if timer > gameTime:
			print_debug("Game is over")
			if (player1_score > player2_score):
				_stop_game(true, true)
			elif (player1_score < player2_score):
				_stop_game(true, false)
			elif (player1_score == player2_score):
				_stop_game(false, false)
		elif player1_score > 9:
			_stop_game(true, true)
		elif player2_score > 9: 
			_stop_game(true, false)
	
	if is_game_stop == true and (Input.is_action_just_pressed("p1_confirm") or Input.is_action_just_pressed("p2_confirm")):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://Scenes/character_selector.tscn")
		


func _stop_game(is_winner: bool, is_player1: bool) -> void:
	is_game_stop = true
	
	if (is_winner):
		win_sound.play()
		winner_sprite.visible = true
		
		if (is_player1):
			player_1_sprite.visible = true 
			win_penguin_sprite.texture = penguin1_sprite.texture
		else:
			player_2_sprite.visible = true
			win_penguin_sprite.texture = penguin2_sprite.texture
		
		confetti_left.throw_confetti()
		confetti_right.throw_confetti()
		win_penguin_sprite.visible = true
	else:
		tie_sprite.visible = true
		
	print(is_winner)
		
	get_tree().paused = true
