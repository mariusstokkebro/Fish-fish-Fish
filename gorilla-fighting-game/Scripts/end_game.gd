extends Node2D

@onready var winner_sprite: Sprite2D = $WinnerSprite2D
@onready var tie_sprite: Sprite2D = $TieSprite2D2

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _stop_game(is_winner: bool) -> void:
	get_tree().paused = true
	
	if (is_winner):
		winner_sprite.visible = true
	else:
		tie_sprite.visible = true
