extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(onBodyEntered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func onBodyEntered(body:CharacterBody2D):
	if body.name == "PorcupineBody":
		print_debug("player 2 plus one point")
	
	if body.name == "PorcupineBody2":
		print_debug("player 1 plus one point")
	body.tpBackToOrigin()
