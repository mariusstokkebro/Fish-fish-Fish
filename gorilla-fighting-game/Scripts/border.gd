extends Area2D

@onready var score_sound: AudioStreamPlayer = $"ScoreSoundPlayer"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(onBodyEntered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func onBodyEntered(body:CharacterBody2D):
	print_debug(body.name)
	if body.hooked == true:
		score_sound.play()
		if body.name == "PorcupineBody":
			WinManager.player2_score += 1
			WinManager.reset = true
		if body.name == "PorcupineBody2":
			WinManager.player1_score += 1
			WinManager.reset = true
