extends CharacterBody2D

const SPEED = 300.0

enum Player {
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

@export var current_player: Player = Player.PLAYER_1

func _physics_process(_delta: float) -> void:
	var up = "p%d_move_up" % current_player
	var down = "p%d_move_down" % current_player
	var left = "p%d_move_left" % current_player
	var right = "p%d_move_right" % current_player

	var directionY := Input.get_axis(up, down)
	if directionY:
		velocity.y = directionY * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	var directionX := Input.get_axis(left, right)
	if directionX:
		velocity.x = directionX * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func getMoved(movement:Vector2):
	set_global_position(movement)
	
