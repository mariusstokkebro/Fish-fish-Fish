extends Area2D

@onready var sound_score: AudioStreamPlayer = $ScoreSoundPlayer
@onready var sound_powerUp: AudioStreamPlayer = $PowerUpSound
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(onBodyEntered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func onBodyEntered(body: CharacterBody2D):
	if body.hooked == true:
		if "powerup_type" in body:
			var catcher = body.currentBait.player
			var is_player1 = (catcher.name == "PorcupineBody")
			
			match body.powerup_type:
				"sardine":
					if catcher.has_method("apply_speed_boost"):
						catcher.apply_speed_boost()
						sound_powerUp.play()
				"shrimp":
					if is_player1:
						WinManager.player1_score += 1
					else:
						WinManager.player2_score += 1
					sound_score.play()
					
			body.queue_free() 
			return
			
		sound_score.play()
		if body.name == "PorcupineBody":
			WinManager.player2_score += 1
			WinManager.reset = true
		if body.name == "PorcupineBody2":
			WinManager.player1_score += 1
			WinManager.reset = true
