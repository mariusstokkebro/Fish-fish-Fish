extends CharacterBody2D
const SPEED = 300.0

func _process(delta: float) -> void:
	print_debug(velocity.x)
	var directionY := Input.get_axis("ui_up","ui_down")
	if directionY:
		velocity.y = directionY * SPEED
	else:
		velocity.y = move_toward(velocity.y,0,SPEED)
	
	var directionX := Input.get_axis("ui_left", "ui_right")
	if directionX:
		velocity.x = directionX * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
